# COI Mod Template - Launchpad

## What this repo is

A **launchpad**, not a workspace. Users clone this repo, run `/kickoff`, and get their own fresh mod project spawned in a separate folder. This launchpad itself is intentionally never modified during normal use.

If you're reading this, you're either:
- A maintainer working on improving the template, OR
- A user who accidentally opened the wrong folder - if so, you want to be in your *spawned* mod folder, not here.

## Repo structure

```
README.md                      # Human-facing onboarding (the user reads this first)
.claude/skills/kickoff/        # The /kickoff onboarding skill (the marquee piece)
template/                      # The skeleton mod that gets copied + personalized by /kickoff
  ├── {{MOD_ID}}.cs            # Mod entry point skeleton (with placeholders)
  ├── {{MOD_ID}}.csproj        # Build config (with placeholders)
  ├── {{MOD_ID}}.sln           # Solution file (with placeholders)
  ├── manifest.json            # Mod manifest (with placeholders)
  ├── CLAUDE.md                # Spawned project's CLAUDE.md (with {{USER_PROFILE_BLOCK}})
  ├── README.md                # Spawned project's README
  ├── MODDING-REFERENCE.md     # Living game API reference (universal-only seed)
  ├── CLAUDE-FIRST-SESSION.md  # First-session orientation for Claude
  ├── changelog.txt            # Empty changelog seed
  ├── LICENSE                  # MIT + COI carve-out
  ├── .gitignore
  ├── scripts/                 # Build/release/diagnostic PowerShell scripts
  └── .claude/skills/          # Skills that ship with every spawned mod
       ├── ship-it/
       ├── game-updated/
       ├── snapshot/
       ├── rewind/
       ├── it-broke/
       ├── wrap-up/
       ├── checkup/
       └── explain-this/
```

## Placeholder convention

Files in `template/` use `{{LIKE_THIS}}` placeholders that `/kickoff` substitutes during spawning. Filenames AND contents both get substitutions applied. The full list:

| Placeholder | Replaced with |
|---|---|
| `{{MOD_ID}}` | The mod's internal ID (e.g. `BetterLogistics`) |
| `{{MOD_DISPLAY_NAME}}` | Human-readable name (e.g. `Better Logistics`) |
| `{{MOD_DESCRIPTION_SHORT}}` | ≤180 char tagline for Hub listings |
| `{{MOD_DESCRIPTION_LONG}}` | Full mod description for Hub mod page |
| `{{MOD_AUTHOR}}` | Author's name or handle |
| `{{GITHUB_USERNAME}}` | GitHub username (or empty) |
| `{{YEAR}}` | Current year (for LICENSE copyright) |
| `{{USER_MODE}}` | The mode they picked: Just Build It / Build It + Teach Me / Teach Me Everything |
| `{{USER_PROFILE_BLOCK}}` | The full markdown block matching their mode (defined in `kickoff/SKILL.md`) |
| `{{MODDING_REPO_PATH}}` | Local path to the official MaFi modding examples repo |
| `{{LAUNCHPAD_PATH}}` | Absolute path to this launchpad |
| `{{PROJECT_GUID}}` | Fresh GUID for the .csproj/.sln |

## Maintainer notes

- **Don't accidentally trigger placeholders during edits.** If you're editing a file in `template/` and need to write a literal `{{` or `}}`, you'll need to escape it somehow at substitution time. So far this hasn't come up in practice.
- **The spawned `CLAUDE.md` is the most important file.** Everything that affects how Claude behaves with the spawned project lives there. Test changes by spawning a real project (run `/kickoff` against a throwaway folder) and verifying the resulting `CLAUDE.md` reads correctly.
- **Changes to skills carry through to all *future* spawned projects.** Existing spawned projects don't auto-update - they own their copies. That's deliberate; don't try to make skills central.
- **The launchpad is `master`-branched.** Tag releases of the template if it stabilizes.

## Working style

This repo is small. No CI yet, no automated tests. Manual verification:

1. After meaningful changes, run `/kickoff` against a throwaway target folder.
2. Confirm the spawned project builds (`dotnet build <MOD_ID>.sln`).
3. Confirm the placeholders all got substituted (no `{{` left in the spawned files).
4. Spot-check the spawned `CLAUDE.md` for the right User Profile block.
5. Delete the throwaway folder.

That's it. Keep changes small, ship the template, iterate.
