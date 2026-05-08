# Captain of Industry Mod Template

**Make a Captain of Industry mod with the help of an AI coding assistant — no programming experience required.**

You'll spend a couple of minutes installing one app, then paste one prompt. From there, Claude handles everything: installing the tools you need, finding your game install, cloning this template, and walking you through setup. Total time to a working mod project: about 10 minutes.

---

## ⚠️ Important — read this first

**This template is Windows-only.** It will not work on macOS or Linux.

You will need to use **Claude Desktop in Code mode** specifically — not Chat mode, and not Cowork mode. Code mode is the only one with the file and shell tools Claude needs to actually do work for you. Press **Ctrl+3** inside Claude Desktop to switch into Code mode. If you're in any other mode, this won't work.

---

## 🐙 Required: a GitHub account

You'll need a free GitHub account for this. Two reasons:
1. **Privacy-preserving commits** — without an account, we can't generate the email format that keeps your real address out of public commit history.
2. **Backup** — your mod's code lives on GitHub. Without it, a hard drive failure = your mod is gone.

If you already have one, you're set — move on to Setup below.

If you don't:

- **Make one now at [github.com/signup](https://github.com/signup)** — takes about **5–10 minutes**, mostly because GitHub now requires two-factor authentication (2FA). You'll need an authenticator app on your phone like Google Authenticator, Microsoft Authenticator, Authy, or 1Password. GitHub will also have you solve a quick puzzle and verify your email.
- **Or let Claude walk you through it during setup** — same steps, but inline with the rest of onboarding. Adds ~5–10 minutes to the whole flow.

---

## 🚀 Setup — three steps

### 1. Install Claude Desktop

Download and install Claude Desktop from **https://claude.ai/download**. You'll need a Claude account; free tier works to start, but for serious modding work you'll likely want a paid plan since AI conversations have per-message costs.

### 2. Open Claude Desktop and switch to Code mode

After installing, open the app and press **Ctrl+3**. The window should change to show a coding interface. If it doesn't, look for a "Code" tab/mode selector — make sure that's what you're in.

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

1. **Quick inventory** of what's already on your machine (Git, .NET SDK, GitHub CLI). Anything missing, Claude offers to install for you. You'll see Windows permission prompts (UAC) — click **Yes** to approve each.
2. **Auto-detect Captain of Industry** via Steam, so the build knows where to find it.
3. **Where do you want your mod work to live?** Default is `C:\Code` (Claude will create it if needed), but you can pick any folder or drive — `D:\Modding`, `C:\Projects`, wherever you keep your dev work. The launchpad and your future mods all live under that one folder.
4. **A short wizard** asks a few questions: your mod's name and description, how you want to work with Claude (three modes), and whether you want a GitHub repo for the mod (recommended). If yes, the repo gets created as `COI-<your-mod-name>` so all your COI mods are easy to spot in your repo list later.
5. **Confirmation gate.** Before anything gets created or pushed, Claude shows you a blueprint table of every choice you made — mod name, location, GitHub repo public/private, work style, etc. You type `yes` to start construction, or tell Claude what to change. Nothing is committed until you confirm.
6. **Construction.** Claude creates the project folder, copies the template, personalizes everything, sets up git, optionally creates and pushes the GitHub repo, runs a test build, and deploys the hello-world mod to your game's mods folder.
7. **Handoff.** When it's done, Claude tells you to close this session and start a fresh Claude Desktop session pointed at your new mod folder. From there you build the actual mod by chatting with Claude — using plain English, no commands needed.

Throughout the process, Claude Desktop will ask permission the first time it tries to do something new (run a command, edit a file, fetch a URL). **Click "Allow"** when prompted — those permissions are how Claude does work for you. You can review and tighten them later in Claude Desktop's settings.

---

## 🔧 Troubleshooting

**"I'm not in Code mode."**
Press Ctrl+3 in Claude Desktop. If that does nothing, you may have an older version — update via the app's settings or reinstall from https://claude.ai/download.

**"Claude is asking me to type commands in PowerShell."**
You shouldn't have to. If Claude asks you to run anything in a terminal yourself, paste the prompt above again and tell Claude *"please run that for me — I shouldn't be in a terminal."* Code mode has all the tools needed.

**"Claude said it can't find Captain of Industry."**
Make sure you've actually launched COI at least once after installing it (so Steam registers the install path). If it still can't find it, just tell Claude where it is — paste the install folder path.

**Something else.**
Once your mod project is set up, you can use the `/it-broke` skill — type that into Claude in your mod folder and explain what's wrong.

---

## 🙏 Credits

This template was assembled from lessons learned building [ResearchQueue](https://hub.coigame.com/Mod/17). That mod started as an experiment to see if I could actually build a mod without knowing how to code myself with Claude. I was so happy with the end result that I made this template to help reduce the barrier to entry for other players who aspire to make mods too but don't know how to code.  Thanks to MaFi Games for the modding policy that makes any of this possible.

License: MIT (see `LICENSE`). Spawned mods inherit MIT by default but you can change theirs during setup.
