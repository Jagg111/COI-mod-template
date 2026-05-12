# Captain of Industry Mod Template

**Make a Captain of Industry mod with the help of an AI coding assistant. No programming experience required.**

You'll spend a couple of minutes installing one app, then paste one prompt. From there, Claude handles everything: installing the tools you need, finding your game install, cloning this template, and walking you through setup. Total time to a working mod project: about 10 minutes.

---

## 🎮 What can you build?

Mods for Captain of Industry are C# programs, but you don't write the C# - Claude does. You describe what you want in plain English, Claude figures out the code. To get your imagination going, here are some starting ideas - but the only real limit is what the game's modding API supports, so don't be afraid to experiment:

- **Balance tweaks** - adjust production rates, resource costs, or yields for any building or recipe
- **Automation** - things you'd click through repeatedly in the base game, done automatically
- **New research nodes** - add entries to the tech tree with custom unlock conditions and rewards
- **New recipes** - add production options to existing buildings (no new graphics needed)
- **UI additions** - extra panels, labels, or information displays added to existing game screens
- **Player settings** - configurable toggles and sliders players adjust in the mod settings panel

When you're ready to ship, your mod goes on the **[COI Mod Hub](https://hub.coigame.com)** - the official mod library where every Captain of Industry player can find and install it.

No mods built with this template are on the Hub yet - it's brand new. But the template was inspired by **[ResearchQueue](https://hub.coigame.com/Mod/17)**, a mod I built with Claude before this template existed, with no coding knowledge. That experience is proof the approach works. If you ship something using this template, drop a comment on the [community thread](https://UPDATEME) and I'll add it here.

---

## ⚠️ Important: read this first

**A paid Claude subscription is required** (Pro or higher). Code mode is not on the free plan. If you're on free, upgrade before starting or you'll get stuck at step 2.

You will need to use **Claude Desktop in Code mode** specifically, not Chat mode, and not Cowork mode. Code mode is the only one with the file and shell tools Claude needs to actually do work for you. If you're in any other mode, this won't work.

**This template is designed to work on Windows only.**

---

## 🐙 Strongly recommended: a GitHub account

GitHub is a free service that acts as an off-site backup and home for your mod's code. You don't need it to get started, but **without it, your mod only exists on your computer** — a hard drive failure or Windows reinstall could wipe it out. It also makes it easy to share your mod with others or get help if something goes wrong.

If you already have one, you're set. Move on to Setup below.

If you don't, you have two options:

- **Make one now at [github.com/signup](https://github.com/signup).** Takes about **5–10 minutes**, mostly because GitHub now requires two-factor authentication (2FA). You'll need an authenticator app on your phone like Google Authenticator, Microsoft Authenticator, Authy, or 1Password. GitHub will also have you solve a quick puzzle and verify your email.
- **Skip it for now.** Claude will warn you about the risk, set up a basic local identity, and let you keep going. You can add GitHub any time later — just ask Claude to help you set it up from inside your mod folder.

Either way, Claude will walk you through it during setup.

---

## 🚀 Setup: three steps

### 1. Install Claude Desktop (paid plan required)

Download and install Claude Desktop from **https://claude.ai/download**. You'll need a Claude account *and* a **paid subscription** (Pro at minimum). Claude Code / Code mode is **not available on the free plan**. The free tier only gets you regular Chat, which doesn't let you use Claude Code, and Claude Code is what this template runs on. If you try to follow these steps on a free account, you'll hit a wall at step 2 when Code mode can't be activated.

### 2. Open Claude Desktop and switch to Code mode

Code mode is what lets Claude actually *do* things on your computer - run commands, create files, build and deploy your mod - rather than just talking about them. Chat mode and Cowork mode can give advice but can't take action, so this template won't work in either of them.

After installing, open the app and press **Ctrl+3**. The window should change to show a coding interface. If it doesn't, look for a "Code" tab/mode selector and make sure that's what you're in.

### 3. Paste this prompt and hit enter

Copy the prompt below exactly as written, paste it into the chat, and send.

```
I want to build a Captain of Industry mod and I'm a beginner. I'm on Windows
and I'm in Claude Desktop's Code mode (Ctrl+3). Please read this file and
follow it as my onboarding playbook:

https://raw.githubusercontent.com/Jagg111/COI-mod-template/main/BOOTSTRAP.md
```

That's it. Claude will take it from there.

---

## ⚙️ What happens next

Once you paste that prompt, Claude takes over. Here's the play-by-play:

1. **Quick inventory** of what's already on your machine (Git, .NET SDK, GitHub CLI). Anything missing, Claude offers to install for you. You'll see Windows permission prompts (UAC). Click **Yes** to approve each.
2. **Auto-detect Captain of Industry** via Steam, so the build knows where to find it.
3. **Where do you want your mod work to live?** Default is `C:\Code` (Claude will create it if needed), but you can pick any folder or drive (`D:\Modding`, `C:\Projects`, wherever you keep your dev work). The launchpad and your future mods all live under that one folder.
4. **A short wizard** asks a few questions: your mod's name and description, how you want to work with Claude (three modes), and whether you want a GitHub repo for the mod (recommended). If yes, the repo gets created as `COI-<your-mod-name>` so all your COI mods are easy to spot in your repo list later.
5. **Confirmation gate.** Before anything gets created or pushed, Claude shows you a blueprint table of every choice you made (mod name, location, GitHub repo public/private, work style, etc.). You type `yes` to start construction, or tell Claude what to change. Nothing is committed until you confirm.
6. **Construction.** Claude creates the project folder, copies the template, personalizes everything, sets up git, optionally creates and pushes the GitHub repo, runs a test build, and deploys the mod skeleton to your game's mods folder.
7. **Handoff.** When it's done, Claude tells you to close this session and start a fresh Claude Desktop session pointed at your new mod folder. From there you build the actual mod by chatting with Claude in plain English, no commands needed.

Throughout the process, Claude Desktop will ask permission the first time it tries to do something new (run a command, edit a file, fetch a URL). **Click "Allow"** when prompted. Those permissions are how Claude does work for you. You can review and tighten them later in Claude Desktop's settings.

---

## 🔧 Troubleshooting

**"I'm not in Code mode."**
Press Ctrl+3 in Claude Desktop. If that does nothing, you may have an older version. Update via the app's settings or reinstall from https://claude.ai/download.

**"Claude is asking me to type commands in PowerShell."**
You shouldn't have to. If Claude asks you to run anything in a terminal yourself, paste the prompt above again and tell Claude *"please run that for me, I shouldn't be in a terminal."* Code mode has all the tools needed.

**"Claude said it can't find Captain of Industry."**
Make sure you've actually launched COI at least once after installing it (so Steam registers the install path). If it still can't find it, just tell Claude where it is by pasting the install folder path.

**"Claude keeps describing what to do instead of actually doing it."**
You're in Chat or Cowork mode, not Code mode. Both give Claude language skills without the tools to take action. Press Ctrl+3 to switch, then paste the prompt again.

**Something else.**
Once your mod project is set up, you can use the `/it-broke` skill. Type that into Claude in your mod folder and explain what's wrong.

---

## 🙏 Credits

Built out of [ResearchQueue](https://hub.coigame.com/Mod/17) - a real, published mod made with Claude without knowing how to code. The template grew from that experiment as a way to lower the barrier for other players who want to mod but don't know how to code. Thanks to MaFi Games for the modding policy that makes any of this possible.

License: MIT (see `LICENSE`). Spawned mods inherit MIT by default but you can change theirs during setup.
