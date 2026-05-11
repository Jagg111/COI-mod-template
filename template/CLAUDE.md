# {{MOD_DISPLAY_NAME}} - Captain of Industry Mod

## Project Overview

This is a C# mod for the game **Captain of Industry** (COI), built on the official Mafi modding framework. The user is building this mod with your help - you (Claude) are their AI co-pilot.

This project was bootstrapped from the [COI Mod Template](https://github.com/Jagg111/COI-mod-template) launchpad. Machine-specific paths (your local launchpad, the official modding examples repo) live in `.claude/local-paths.md` - that file is gitignored, so it stays on your machine and never lands in this public repo.

## Mod Identity

- **Display name:** {{MOD_DISPLAY_NAME}}
- **Mod ID:** `{{MOD_ID}}`
- **Author:** {{MOD_AUTHOR}}
- **GitHub:** `{{GITHUB_USERNAME}}/COI-{{MOD_ID}}`
- **Game:** Captain of Industry
- **Framework:** Mafi (.NET 4.8)
- **Mod type:** `IMod`

## What this mod does

{{MOD_DESCRIPTION_LONG}}

(This will evolve - keep this section in sync with what the mod actually does as it grows.)

---

{{USER_PROFILE_BLOCK}}

---

## Research Protocol - when the user asks how to do something

This is the most important rule for working in this codebase. Captain of Industry has a large internal API and the user will frequently ask "how do I do X?" Follow this order - strictly:

1. **First**, check `MODDING-REFERENCE.md` in this repo. It's verified, fast, and curated.
2. **If not found there**, search the official Captain of Industry modding examples repo. The path is in `.claude/local-paths.md` (gitignored - machine-specific). If that file doesn't exist or the path is missing, ask the user where their clone is and write it into `.claude/local-paths.md` for next time. These are real working examples maintained by the game devs - grep for relevant types, read example mods, look for working patterns.
3. **If still not found**, inspect the game DLLs directly using reflection or `inspect_dll.ps1`. The DLLs live at `$env:COI_ROOT\Captain of Industry_Data\Managed\`.
4. **Whenever step 2 or 3 yields something useful, append it to `MODDING-REFERENCE.md`** with a short note on context. The reference is a living document that grows with this project.

Do not skip step 1 to go straight to the game DLLs. The reference exists precisely so you don't have to redo discovery work.

## Reflection Safety

Anything that uses reflection on game internals (`GetField`, `GetProperty`, `GetMethod`, `GetType("...")`) must go through the `ReflectionProbe` helper if and when one is added to this project. If the user is just starting and there's no `ReflectionProbe` yet, that's fine - but as soon as we touch reflection, build that helper first. It keeps `/game-updated` automatically in sync with reality and prevents silent breakage on game updates.

See the ResearchQueue mod's source for a reference implementation if you need one - but copy the pattern, not the specific reflection targets.

## Build & Deploy

### Environment Variables Required
- `COI_ROOT` - path to the Captain of Industry game install directory (e.g., Steam folder)

### Build
```
dotnet build {{MOD_ID}}.sln
```
Note: always specify `{{MOD_ID}}.sln` explicitly. Do not pass `/p:LangVersion=latest` - it breaks argument parsing with `dotnet build`.

On build, the mod is automatically deployed to `%APPDATA%\Captain of Industry\Mods\{{MOD_ID}}\`.

### What gets deployed
- `{{MOD_ID}}.dll` - compiled mod
- `manifest.json` - mod metadata
- `{{MOD_ID}}.pdb` - debug symbols (Debug builds only)

## Project Structure

```
{{MOD_ID}}.sln          # Visual Studio solution
{{MOD_ID}}.csproj       # Project file (build config, references, auto-deploy)
{{MOD_ID}}.cs           # Main mod entry point
manifest.json           # Mod metadata
changelog.txt           # Cumulative player-facing changelog
MODDING-REFERENCE.md    # Living technical reference for game APIs
CLAUDE-FIRST-SESSION.md # First-session orientation (auto-deleted by /wrap-up)
scripts/                # Build/release/diagnostic scripts
.claude/skills/         # Custom skills available in this project
```

## Distribution

- **Exclusive channel:** [COI Mod Hub](https://hub.coigame.com). Players download and install updates manually. The Hub does NOT auto-update.
- **GitHub repo:** source only. Not a player-facing channel.
- **License:** MIT for the mod's own code, with a Captain of Industry game-code carve-out (see `LICENSE`).

## Manifest Fields (Hub limits worth knowing)

These cannot be edited after a version is uploaded:
- `display_name` - max 50 chars
- `description_short` - max 180 chars

Always verify before packaging a release.

## Versioning

Semantic versioning (`MAJOR.MINOR.PATCH`):

- **Patch (0.0.X)** - bug fixes and small tweaks. **When in doubt, bump this.**
- **Minor (0.X.0)** - new features a player would notice. Resets patch to 0.
- **Major (X.0.0)** - major milestones or breaking changes. Resets minor and patch to 0.

Do not bump for docs-only, build script, or comment-only changes. `manifest.json` version is the source of truth.

## Available Skills

This project ships with these custom skills. Tell the user about them when relevant - they don't know what's available unless you mention it:

| Skill | What it does |
|---|---|
| `/ship-it` | Full release workflow: version bump, draft release notes, package zip, Hub upload reminder |
| `/game-updated` | Run after a COI game update. Diagnoses what broke and helps fix it. |
| `/it-broke` | Reads the game log + recent changes, explains what went wrong, offers a fix |
| `/wrap-up` | Wrap the current session: summarize, commit uncommitted work, write `NEXT-SESSION.md` handoff |

**Everything else is just chat.** Saving work, going back to a previous version, explaining code, checking that the build's healthy - none of those need a slash command. The user can ask in plain English (*"save my work"*, *"go back to before I broke the button"*, *"what does this code do?"*, *"is everything okay?"*) and you handle it. Auto-commit behavior is dictated by their User Profile mode above. Don't make them learn slash commands they don't need.

## Helping the User Manage Cost and Context

Long sessions get expensive and slow. At natural breakpoints (after a feature lands, after a release, after a debugging thread resolves), gently suggest `/wrap-up` so the user can start a fresh session. Mention this **at most once per session** and **only at clean breakpoints** - never mid-debugging.

If the user is doing something simple (small edit, rename, doc tweak), it's fine to mention they could switch to a cheaper model. Don't nag.

## Documentation Rules

Whenever you discover something new about how the game works, its APIs, type signatures, or modding patterns, **always update `MODDING-REFERENCE.md` without being asked**. This is non-negotiable. The reference is the project's encyclopedia.

If project-level info changes (mod scope, structure, identity), update this file too.

## Commit Messages

Single line describing what changed in plain English. No body text. No emoji. No "Generated by Claude" footer. Examples:
- `Add hello world button to top toolbar`
- `Fix queue panel not showing on small screens`
- `Update max verified game version to 0.8.5`

If the work closes a GitHub issue, append `Fixes #N` (bug) or `Closes #N` (feature).
