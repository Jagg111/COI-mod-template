---
name: it-broke
description: The "help me fix this" button. Reads the latest game log + recent code changes, identifies the actual error, explains it in plain English, and offers a fix.
disable-model-invocation: true
---

This is the highest-leverage skill in the project. The user is stuck and demoralized. Your job is to turn that into a clear next step.

## Behavior

1. **Acknowledge briefly.** One sentence — "Let me take a look at the logs." or, when it fits, a Captain-of-Industry-flavored beat like "Heading down to the engine room — let me check the logs." Don't make them wait silently while you read. Don't overdo the flavor; once is enough.

2. **Read the latest game log.** Find the newest log file in `%APPDATA%\Captain of Industry\Logs\`:
   ```powershell
   powershell.exe -ExecutionPolicy Bypass -Command "& { $p = Join-Path ([System.Environment]::GetFolderPath('ApplicationData')) 'Captain of Industry\Logs'; Get-ChildItem $p -File | Sort-Object LastWriteTime -Descending | Select-Object -First 1 -ExpandProperty FullName }"
   ```
   Read the file. Focus on:
   - Lines with `E ` prefix (errors) or `W ` prefix (warnings)
   - Lines mentioning the mod ID (read from `manifest.json`)
   - Stack traces (multi-line blocks indented after a header)
   - The `=== Health Check ===` block if present

3. **Read recent code changes.** What did the user just change?
   ```
   git log -5 --oneline
   git diff HEAD~1 HEAD
   git status --porcelain  # uncommitted stuff
   git diff  # what's currently uncommitted
   ```
   Cross-reference: does the latest error correlate with what they just changed?

4. **Diagnose.** Form a hypothesis. Common categories:

   | Category | Symptom | Action |
   |---|---|---|
   | **Build error** | Game log doesn't even mention the mod | The mod didn't load. Run `dotnet build` and read that error instead. |
   | **Reflection target broken** | `NullReferenceException` near a reflection call, or "type X not found" | Run `scripts\check-reflection-targets.ps1` and `inspect_dll.ps1` on the affected type. |
   | **Code change introduced bug** | Error appeared right after a recent change | Compare against the previous commit; explain what changed and what to revert or fix. |
   | **Game updated** | Things that worked yesterday now fail | Suggest running `/game-version-check`. |
   | **Mod isn't enabled** | No mod log entries at all | Check the in-game mod menu; the mod may need to be enabled. |
   | **COI_ROOT or build issue** | "Type or namespace not found" at build time | Check the env var and the build output. |

5. **Explain in plain English.** No stack traces dumped at the user. Use the User Profile's verbosity level, but always:
   - Say what you think went wrong, in one or two sentences.
   - Say what file and line is involved (if you know).
   - Propose a fix.

   Example (Captain's Chair):
   > It looks like the game updated and renamed the `IronForge` type to `Foundry`. Your mod is still asking for the old name on line 42 of `MyMod.cs`. I can fix this — should I update it?

   Example (Show Your Work):
   > **What happened:** A `NullReferenceException` was thrown on line 42 of `MyMod.cs`. The reflection call is asking for a field called `m_oldName` on `IronForge`, which doesn't exist anymore.
   >
   > **Why:** The game update renamed `IronForge` to `Foundry` and `m_oldName` to `m_displayName`. Reflection silently returns null when a field isn't found, then your code crashes when it tries to use the null value.
   >
   > **Proposed fix:** Update the `ReflectionProbe` call on line 42 to use the new names. I'll show you the diff before applying.

6. **Offer to fix.** Behavior depends on User Profile:
   - **Captain's Chair / Learning the Ropes:** Just propose and apply if they say yes.
   - **Show Your Work / Expert:** Show the proposed change first, get approval, then apply.

7. **After fixing:** Suggest the next sanity check:
   - "Want to do a quick build to make sure it compiles? `dotnet build <SLN_FILE>`"
   - Or run `/checkup`.

8. **Before declaring done — document what you learned.** If your investigation surfaced anything not already in `MODDING-REFERENCE.md` — a renamed type, a field that moved, a confusing error pattern, a non-obvious gotcha — append it to the reference now. Debugging mode is the highest-yield discovery path in the project; if you skip this, future-you (or a different session) will redo the investigation. This is non-negotiable per the Documentation Rules in CLAUDE.md.

## When you can't figure it out

If after reading logs and code you genuinely don't have a clear hypothesis:

- Don't fake confidence. Say so.
- Show the user the most relevant 5-10 log lines and ask them what they were doing when it broke.
- Suggest they post on the [COI Mod Hub forum](https://hub.coigame.com/Forum) or Discord `#modding-dev-general` with the error details. Offer to help draft the post.

## Notes

- Don't dump raw stack traces at the user. Translate.
- If the error is in a part of the codebase the user wrote (not a reflection or game-API issue), still explain it in plain English. Avoid jargon like "null reference exception" without defining it.
- It's okay to say "I'm not 100% sure but my best guess is X" — wrong-but-honest beats falsely-confident.
