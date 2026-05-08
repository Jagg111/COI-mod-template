# {{MOD_DISPLAY_NAME}}

> {{MOD_DESCRIPTION_SHORT}}

---

## 📖 About

{{MOD_DESCRIPTION_LONG}}

---

## 🛠️ How to keep building

To work on this mod with Claude:

1. **Open this folder in Claude Desktop's Code mode** (`Ctrl+3` inside the app — not Chat, not Cowork).
2. **Tell Claude what you want to build, fix, or learn.** Plain English works:
   - *"Make my hello message show up as a button in the game's top toolbar"*
   - *"Why isn't my mod loading?"*
   - *"What does this code do?"*
3. **Test in-game often.** Every time Claude builds your mod, it auto-deploys to Captain of Industry. Launch the game, load any save, and check `%APPDATA%\Captain of Industry\Logs\` for lines starting with `{{MOD_ID}}:` — those are messages from your mod.

> 🎚️ You're working with Claude in **{{USER_MODE}}** mode (see `CLAUDE.md` for what that means and what to expect). You can change modes later by editing the `## User Profile` section there.

---

## ⚙️ Built-in skills

This project ships with four built-in skills you can summon in Claude Desktop's Code mode by typing `/<name>`:

| Skill | When to use it |
|---|---|
| 🩺 `/it-broke` | Something's not working — game won't launch, build fails, mod loads but misbehaves. Claude reads the game log + recent changes, diagnoses the issue, and proposes a fix. |
| 🚢 `/ship-it` | Ready to release a new version. Walks through version bump, changelog draft, and packaging the release zip for the [COI Mod Hub](https://hub.coigame.com). |
| 🔄 `/game-version-check` | Run after Captain of Industry updates. Diagnoses what broke from the new version and helps fix it. |
| 🌅 `/wrap-up` | End of a working session. Saves any uncommitted work and writes a short handoff note (`NEXT-SESSION.md`) for next time. |

> 💬 **Everything else is just chat.** You don't need a slash command to ask Claude to explain code, save your work, check the build, or roll back a change — just ask in plain English.

---

## 📁 What's in this folder

| File | What it is |
|---|---|
| `{{MOD_ID}}.cs` | Your mod's main code |
| `manifest.json` | Mod metadata (name, version, description shown on the Hub) |
| `changelog.txt` | Auto-filled by `/ship-it` on each release |
| `MODDING-REFERENCE.md` | Claude's growing reference of Captain of Industry game APIs and gotchas — it adds to this as you build |
| `CLAUDE.md` | Instructions Claude reads on every session; defines your working style, project rules, etc. |
| `NEXT-SESSION.md` | *(Created by `/wrap-up`)* Handoff notes from your last working session |

---

## 🔧 Build (technical detail)

You don't need to run this manually — Claude builds when needed. But for reference:

```
dotnet build {{MOD_ID}}.sln
```

Requires .NET 8 SDK and the `COI_ROOT` environment variable pointing to your Captain of Industry install. The mod auto-deploys to `%APPDATA%\Captain of Industry\Mods\{{MOD_ID}}\` on every build.

---

## 📦 Distribution

This mod is distributed via the [COI Mod Hub](https://hub.coigame.com). When you're ready to ship a new version, type `/ship-it` and Claude will package the release zip and walk you through the upload.

---

## ✍️ Author

{{MOD_AUTHOR}}

## 🌱 Built with

Bootstrapped from the [COI Mod Template](https://github.com/Jagg111/COI-mod-template) by [@Jagg111](https://github.com/Jagg111).

## 📜 License

MIT for the mod's own code. See `LICENSE` for the Captain of Industry game code carve-out.
