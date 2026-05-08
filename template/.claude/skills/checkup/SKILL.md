---
name: checkup
description: Health check across the project. Verifies environment, builds the mod, runs reflection diagnostics, validates manifest, and reports a green/yellow/red summary in plain English.
disable-model-invocation: true
---

This is the "is everything OK?" button. Run it whenever the user feels uneasy or before/after big changes.

## Behavior

Run the checks below silently and gather results. Then present a single readable summary at the end. Don't dump raw output line-by-line — the goal is reassurance, not a wall of text.

Each check has three states: **PASS** ✅, **WARN** ⚠️, **FAIL** ❌.

## Checks

### 1. Environment

- **`COI_ROOT` env var set:**
  ```powershell
  $r = [System.Environment]::GetEnvironmentVariable('COI_ROOT','User'); if (-not $r) { $r = [System.Environment]::GetEnvironmentVariable('COI_ROOT','Machine') }; $r
  ```
  - PASS if non-empty AND the path exists AND contains `Captain of Industry_Data\Managed`
  - FAIL otherwise (with specific reason)

- **`dotnet` on PATH:** `dotnet --version` returns successfully → PASS, else FAIL.

- **`git` on PATH:** `git --version` succeeds → PASS, else WARN (mod still works, just no version control).

### 2. Project structure

- **`manifest.json` exists, is valid JSON, has required fields** (`id`, `version`, `primary_dlls`):
  - PASS / FAIL (with specific reason)

- **`.csproj` and `.sln` exist and match the mod ID:**
  - PASS / WARN if names mismatch (still buildable but inconsistent)

- **`changelog.txt` exists:** PASS / WARN.

### 3. Build

Run a Debug build:
```
dotnet build <MOD_ID>.sln -c Debug
```
- PASS if exit code is 0.
- FAIL if not. Capture the first error message.

If build passes, also confirm the deployed DLL exists:
```
%APPDATA%\Captain of Industry\Mods\<MOD_ID>\<MOD_ID>.dll
```
- PASS if present.
- WARN if missing (deploy step might not have run).

### 4. Reflection targets (if applicable)

```
powershell -ExecutionPolicy Bypass -File scripts\check-reflection-targets.ps1
```
- PASS if all targets pass (or 0 targets found — that's also fine).
- WARN if some are SKIP-only (dynamic checks, expected).
- FAIL if any FAIL.

### 5. Manifest field limits

- `display_name` ≤ 50 chars: PASS / FAIL
- `description_short` ≤ 180 chars: PASS / FAIL

## Output

Show a tidy summary like:

```
🩺 Health Check for <MOD_DISPLAY_NAME>

Environment       ✅ all good
Project structure ✅ all good
Build             ✅ compiled successfully (Debug, 0 warnings, 0 errors)
Deployment        ✅ DLL deployed to mods folder
Reflection        ✅ 14 targets pass, 2 skip (dynamic — expected)
Manifest limits   ✅ within Hub limits

Overall: 🟢 All clear. The mod is in good shape.
```

If anything is yellow or red, surface it clearly with the specific issue and suggested fix.

```
🩺 Health Check for <MOD_DISPLAY_NAME>

Environment       ✅ all good
Project structure ✅ all good
Build             ❌ FAILED
   → Error: 'Foundry' could not be found in <file>:42
Deployment        — skipped (build failed)
Reflection        — skipped (build failed)
Manifest limits   ✅ within Hub limits

Overall: 🔴 Build is broken. Try running `/it-broke` to diagnose.
```

## Notes

- This skill is read-only. Never modifies files.
- Keep it fast — if the build takes a long time, that's just how it is, but don't add slow steps.
- Tone: reassuring, not alarming. The friend runs this when they're nervous; the goal is to either say "you're fine" or "here's exactly what's wrong."
