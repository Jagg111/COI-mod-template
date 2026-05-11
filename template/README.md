# {{MOD_DISPLAY_NAME}}

{{MOD_DESCRIPTION_LONG}}

---

## 🛠️ How to work on the mod

Open this folder in **Claude Desktop's Code mode** (`Ctrl+3` inside the app - not Chat, not Cowork). From there, just **tell Claude what you want** in plain English. The more specific the better:

- *"Add a button labeled 'Paint' to the top toolbar"*
- *"Why isn't my mod loading?"*
- *"What does this code do?"*

A few tips if Claude Code is new to you:

- **Click Allow on permission prompts.** The first time Claude wants to run a command or edit a file, it'll ask. That's how it does work for you.
- **It's safe to experiment.** Claude saves your work as it goes (per your mode), so if something feels wrong just say *"undo that last change"*.
- **Test in-game often.** Every time Claude builds, your mod auto-deploys to Captain of Industry. Launch the game, load any save, and try your changes.
- **If something breaks**, type `/it-broke` and Claude will read the game logs, diagnose what went wrong, and propose a fix. You don't need to look at logs yourself.
- **End each working session with `/wrap-up`.** It saves your progress and writes a quick handoff note so the next session picks up cleanly.

> 🎚️ You're working with Claude in **{{USER_MODE}}** mode (see `CLAUDE.md` for what that means and what to expect). You can change modes later by editing the `## User Profile` section there.

---

## ⚙️ Built-in skills

This project ships with four built-in skills you can summon in Claude Desktop's Code mode by typing `/<name>`:

| Skill | When to use it |
|---|---|
| 🩺 `/it-broke` | Something's not working - game won't launch, build fails, mod loads but misbehaves. Claude reads the game log + recent changes, diagnoses the issue, and proposes a fix. |
| 🚢 `/ship-it` | Ready to release a new version. Walks through version bump, changelog draft, and packaging the release zip for the [COI Mod Hub](https://hub.coigame.com). |
| 🔄 `/game-version-check` | Run after Captain of Industry updates. Diagnoses what broke from the new version and helps fix it. |
| 🌅 `/wrap-up` | End of a working session. Saves any uncommitted work and writes a short handoff note (`NEXT-SESSION.md`) for next time. |

> 💬 **Everything else is just chat.** You don't need a slash command to ask Claude to explain code, save your work, check the build, or roll back a change - just ask in plain English.

---

## 📁 What's in this folder

| File | What it is |
|---|---|
| `{{MOD_ID}}.cs` | Your mod's main code |
| `manifest.json` | Mod metadata (name, version, description shown on the Hub) |
| `changelog.txt` | Auto-filled by `/ship-it` on each release |
| `MODDING-REFERENCE.md` | Claude's growing reference of Captain of Industry game APIs and gotchas - it adds to this as you build |
| `CLAUDE.md` | Instructions Claude reads on every session; defines your working style, project rules, etc. |
| `NEXT-SESSION.md` | *(Created by `/wrap-up`)* Handoff notes from your last working session |

---

## 🔧 Build (technical detail)

You don't need to run this manually - Claude builds when needed. But for reference:

```
dotnet build {{MOD_ID}}.sln
```

Requires .NET 8 SDK (installed during setup) and the `COI_ROOT` environment variable pointing to your Captain of Industry install. COI runs on .NET Framework 4.8 internally - if you see `net48` in build output, that's expected. The .NET 8 SDK handles both; you don't need to install anything extra. The mod auto-deploys to `%APPDATA%\Captain of Industry\Mods\{{MOD_ID}}\` on every build.

---

## 📦 Distribution

This mod is distributed via the [COI Mod Hub](https://hub.coigame.com). When you're ready to ship a new version, type `/ship-it` and Claude will package the release zip and walk you through the upload.

---

## 🌱 Built with

Bootstrapped from the [COI Mod Template](https://github.com/Jagg111/COI-mod-template) by [@Jagg111](https://github.com/Jagg111).
