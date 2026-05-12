---
name: game-updated
description: Run after a Captain of Industry game update. Compares game version, runs reflection diagnostics, guides manual in-game testing, analyzes logs, and prompts for version bump if needed.
disable-model-invocation: true
---

Walk through each step in order. Stop and report clearly if anything fails.

## What this does and why

This mod likely depends on internal game code that isn't part of any official modding API. When the game updates, those internal references can change - renamed, moved, or removed entirely. This skill runs a full compatibility check: it verifies the game version, checks all internal references offline, walks the user through manual in-game testing, then analyzes the game log to confirm everything lines up.

If your mod doesn't use reflection at all, the offline diagnostic will report 0 targets and that's fine - proceed straight to manual testing.

## Key files

| File | What it does |
|------|-------------|
| Game's `changelog.txt` | The game's own changelog at `$env:COI_ROOT\changelog.txt`. The first line is always the current version (e.g. `v0.8.2c | 2026-03-23`), including hotfix letter suffixes. |
| `scripts/check-reflection-targets.ps1` | Diagnostic script. Scans every `*.cs` file for `ReflectionProbe.*` calls and verifies them against the actual game DLLs. |
| `scripts/inspect_dll.ps1` | Deeper inspection tool. When something breaks, this shows what a game type looks like now. |
| `manifest.json` | Reads `max_verified_game_version` to compare against. |

---

## Step 0 -- Determine game version and compare

> ⚠️ Use the **PowerShell tool** (not Bash) for all commands in this skill - the Bash tool strips `$` variable references and will fail.

1. Read the first line of the game's `changelog.txt`:
   ```powershell
   powershell.exe -ExecutionPolicy Bypass -Command "& { $r = [System.Environment]::GetEnvironmentVariable('COI_ROOT','User'); if (-not $r) { $r = [System.Environment]::GetEnvironmentVariable('COI_ROOT','Machine') }; Get-Content (Join-Path $r 'changelog.txt') | Select-Object -First 1 }"
   ```
   Returns a line like `v0.8.2c | 2026-03-23`. Strip the leading `v` and everything from ` | ` onward to get the canonical game version (e.g. `0.8.2c`).

2. If `COI_ROOT` is not set or the file is not found, ask the user: "I couldn't read the game version from the install directory. What version of Captain of Industry are you running? (You can find this on the game's main menu.)"

3. Read `manifest.json` and extract `max_verified_game_version`. If the field is missing entirely, treat it as "never verified" - that's an automatic version mismatch.

4. Show the user a clear comparison:
   - **Current game version:** (what you found, e.g. `0.8.2c`)
   - **Max verified version in manifest:** (what manifest says, or "(not set)")
   - **Match?** Yes / No - note that `0.8.2c` vs `0.8.2` is a **No** (hotfix suffix differences count as a mismatch)

5. Remember whether these versions match - needed in Step 5.

Continue to Step 1.

---

## Step 1 -- Run reflection checks

Run the offline diagnostic to see if the mod's internal game references still resolve.

```
powershell -ExecutionPolicy Bypass -File scripts\check-reflection-targets.ps1
```

Always show the user the full output. The results break down into:

- **PASS** - the mod can find this internal game reference.
- **FAIL** - the game changed and the mod can't find this anymore. Needs a code fix.
- **SKIP** - uses a dynamic type that can only be checked by actually running the game. The mod's built-in health check (in the game log at startup) verifies these.
- **0 targets found** - either this mod doesn't use reflection, or doesn't use the `ReflectionProbe` helper pattern. Both fine. Continue to Step 2.

### If everything passes

Tell the user the offline checks look good, and continue to Step 2.

### If something fails

Explain to the user in plain language what broke. For each failed target:

1. Run `inspect_dll.ps1` on the affected type:
   ```
   powershell -File scripts\inspect_dll.ps1 <TypeName> <DllName>
   ```

2. Compare the output to the member that failed. Explain what likely happened:
   - **Renamed:** Update the name string in the `ReflectionProbe` call in code.
   - **Moved:** Update the type reference in the `ReflectionProbe` call.
   - **Removed:** The mod feature tied to it needs a new approach, or stays disabled. If you have a graceful degradation system, it'll auto-disable just that feature.

3. After making fixes, rebuild and re-run:
   ```
   dotnet build <SLN_FILE>
   powershell -ExecutionPolicy Bypass -File scripts\check-reflection-targets.ps1
   ```
   (Read the `.sln` filename from the directory - it'll match the mod ID.)

4. Repeat until all static checks pass. Only then continue to Step 2.

---

## Step 2 -- Manual in-game testing

Time to test the mod in the actual game. The exact checklist depends on what this mod does - read `CLAUDE.md` and `README.md` to figure out what features need testing, then build a checklist tailored to this mod.

For a mod that hasn't had in-game features built yet, the minimum checklist is:
1. Launch the game.
2. Open the mod list — confirm the mod shows a green checkmark (not a red X).
3. Load any save and confirm the game doesn't crash.

For mods with in-game features, write a feature-by-feature checklist like:

> 1. Feature A behaves as expected when X
> 2. Feature B doesn't break when Y
> 3. ... etc.

Present the checklist and ask the user to work through it, then report back ("all clear" or list any issues).

Wait for the user to respond before continuing.

---

## Step 3 -- Analyze game log

Immediately after receiving the user's manual test feedback, pull the latest log file. Do NOT prompt the user again.

1. Find the newest log file:
   ```
   powershell.exe -ExecutionPolicy Bypass -Command "& { $p = Join-Path ([System.Environment]::GetFolderPath('ApplicationData')) 'Captain of Industry\Logs'; Get-ChildItem $p -File | Sort-Object LastWriteTime -Descending | Select-Object -First 1 -ExpandProperty FullName }"
   ```

2. Read the mod ID from `manifest.json`. Extract all log lines containing `<mod-id>:`.

3. If a `=== Health Check ===` block exists in the log:
   - "All N reflection targets resolved" → full pass.
   - "N/total reflection targets missing" → partial pass. Note which features are disabled.
   - "CRITICAL reflection targets missing" → critical failure.

4. Look for any WARNING (`W` prefix) or ERROR (`E` prefix) lines mentioning the mod. List them.

5. Cross-reference against the user's manual test feedback:
   - User reported failure → check log for related errors.
   - User said all good but log shows warnings → flag the discrepancy.
   - Both clean → say so.

6. Present a clear summary:
   - **Health check:** PASS / PARTIAL / FAIL (with details, or "(no health check found)")
   - **Warnings found:** (list, or "None")
   - **Errors found:** (list, or "None")
   - **Manual vs. log alignment:** Do they match?

Continue to Step 4.

---

## Step 4 -- Resolution loop

If there are any failures or discrepancies from Steps 1, 2, or 3:
- Investigate each issue with the user.
- Make code fixes as needed, rebuild, re-run the reflection check.
- For manual-test issues, ask the user to re-test just the failing items.
- Pull the log again after re-testing.
- Continue until all issues are resolved.

If everything passed cleanly, skip this step and declare: "All clear - the mod is fully compatible with this game version."

**Before continuing - document what you learned.** Any rename, type move, signature change, or new gotcha you discovered while diagnosing belongs in `MODDING-REFERENCE.md`. Game-update findings are especially valuable because they tend to recur across game updates. Add an entry with the old name, the new name, and one line of context. This is non-negotiable per the Documentation Rules in CLAUDE.md.

Continue to Step 5.

---

## Step 5 -- Version bump (conditional)

**Only run this step if the game version from Step 0 is different from the `max_verified_game_version` in `manifest.json`.** If they already match, skip and end with something fun.

If they differ and all checks passed:

1. Tell the user: "The game version has changed and all compatibility checks passed. Let's update the mod to reflect the new verified version."

2. Update `manifest.json`: change (or add) `max_verified_game_version` to the new full version string including any hotfix letter (e.g. `"0.8.2c"`).

3. If the README references a verified version anywhere, update it too.

4. Commit (auto-commit in all modes):
   ```
   git add manifest.json README.md
   git commit -m "Update max verified game version to <version>"
   ```
   Push behavior follows mode:
   - **Just Build It / Build It + Teach Me:** auto-push if a remote is configured.
   - **Teach Me Everything:** do NOT auto-push. Tell the user it's saved locally and offer to push (*"want me to push, or hold off?"*) - first time per session, briefly explain that committing saves locally and pushing makes it visible online.

5. Tell the user: "Version reference updated. You can now run `/ship-it` to publish a new release. Once the release is out, don't forget to update the max-verified-game-version on your Hub listing - that step is manual."

---

## Edge cases

If the mod uses a `ReflectionProbe` helper, it likely has built-in safety:

1. **Health check log** - On startup, the mod writes a report to the game log showing exactly what resolved and what's missing. Look for the `=== Health Check ===` block.
2. **Graceful degradation** - If some features can't work, the mod can disable just those features instead of crashing.

If the mod has neither, suggest adding them - they make the next game update much less stressful.

## Notes

- Some targets are marked SKIP because they depend on types that only exist at runtime. The offline diagnostic can't check these - the in-game health check handles them.
