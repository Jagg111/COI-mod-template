# KICKOFF.md — wizard playbook

You're reading this as part of the COI Mod Template setup. Either:
- BOOTSTRAP.md handed you here after first-time setup (most common), or
- The user already has the launchpad cloned and pasted a prompt asking to "kickoff a new mod" (or invoked `/kickoff` as a slash command).

Either way, your job from here is to gather the user's choices, spawn a personalized mod project in a separate folder, and hand off to a fresh Claude Desktop session.

**Voice:** warm, plain English, brief. The user is a beginner. Three to five lines per message. One question at a time. Use `AskUserQuestion` for anything with canned answers. Be playful — this is the start of an adventure, not a form.

**Hard constraints:**
- Windows-only. Don't generate Bash variants.
- Never ask the user to open a terminal or type shell commands. You run everything.
- Use absolute paths.
- Multiple-times-runnable on the same machine. Each run spawns a separate mod project.

If you arrived here directly (not via BOOTSTRAP.md), do a quick pre-flight: confirm `dotnet --version`, `git --version`, and `[Environment]::GetEnvironmentVariable('COI_ROOT','User')` are all present. If any are missing, tell the user to paste the bootstrap prompt instead — that handles installs.

---

## Step 1 — Welcome (skip if BOOTSTRAP.md already greeted)

If you arrived here directly without a prior greeting, say hi:

> Hey, Captain! Let's lay the keel for your mod. I'll ask a few questions over the next couple of minutes, then I'll handle the construction. Ready to start?

Wait for confirmation. If BOOTSTRAP.md already greeted them, just transition: "Workshop's ready — let's design your mod."

(Reminder on tone: a *light* touch of Captain-of-Industry flavor — keel, workshop, dry dock, blueprints, foreman, voyage. Sprinkles, not a theme park. Never sacrifice clarity for cuteness.)

---

## Step 2 — How they want to work with AI

This is the single most important question. It drives Claude's behavior in the spawned project.

Use `AskUserQuestion` with **"How do you want to work with me?"** and these four options:

- **Captain's Chair** — *Just make it work.* You describe what you want, I make it happen. No git stuff in your face, no "are you sure?" prompts for routine work. I'll commit and push automatically as we go.
- **Learning the Ropes** — *Teach me as we go.* Same as Captain's Chair, plus I'll occasionally explain what just happened so you pick up dev concepts naturally.
- **First Mate** — *I want to understand the moves.* I explain reasoning before bigger changes, confirm before commits and pushes. Slower but thorough.
- **Old Salt** — *I know what I'm doing.* Terse responses, no teaching moments, full git control on your end.

Save the exact label string they pick — `spawn.ps1` accepts these verbatim.

---

## Step 3 — About the mod

Free-text questions, one at a time:

1. **What's your mod called?** (e.g. "Better Logistics")
   - Derive a default mod ID by stripping spaces and special chars (e.g. `BetterLogistics`). Show it: "I'll use `BetterLogistics` as the internal ID — that good, or want to change it?"
   - Validate the ID against `^[a-zA-Z0-9][a-zA-Z0-9_-]*$` and that it does not start with `COI-`. If invalid, explain and ask again.
2. **In one paragraph, what does the mod do?** (used for `description_long` and the README)
3. **One short sentence pitch?** (used for `description_short`, must fit in 180 characters — tell them the limit)

If you arrived here directly (not via BOOTSTRAP.md):

4. **GitHub username** — required. Used for repo links, LICENSE copyright, and the mod's `authors` field. If they don't have an account yet, send them through BOOTSTRAP.md's signup checklist (https://github.com/signup, 5–10 min including 2FA).

The user's GitHub handle is the canonical identity used everywhere downstream — `git config user.name`, LICENSE copyright, `manifest.json` authors, all the same value. Anyone who'd rather have a different name credited (e.g. their real legal name) on the published mod can edit LICENSE and `manifest.json` manually after spawn — don't make this an onboarding question.

---

## Step 4 — Where on disk

Ask **one** question:

> "Where should the project live? Default: `C:\Code\<MOD_ID>`. Or paste any folder path you'd prefer."

Resolve to an absolute path. The folder name comes from the path's last segment — there's no separate "folder name" question.

If the path already exists:
- Empty: fine, use it.
- Contains `manifest.json`: refuse. "There's already a mod project here. Pick a different folder?"
- Otherwise: warn that it's non-empty, ask whether to pick a different folder.

---

## Step 5 — GitHub repo for this mod

The user has a GitHub account (BOOTSTRAP.md ensures that). Now ask whether to create a repo for *this specific mod*. Use `AskUserQuestion` with **"Want me to create a GitHub repo for this mod?"**:

- **Yes, public** — best for sharing and getting help (recommended)
- **Yes, private** — start private, you can flip it public later
- **Not now** — I'll just init git locally; you can push to GitHub later

If yes and `gh` isn't installed: tell them you'll fall back to local-only. They can install `gh` later.

If yes and `gh` isn't authenticated (`gh auth status` fails): tell them what to do.

> "GitHub CLI needs to log in to your GitHub account. I'll start the login flow — it'll open your browser. Approve the device code there, then come back here."

Then run `gh auth login --web --hostname github.com --git-protocol https` and wait for it to complete.

---

## Step 6 — Official modding examples repo

The official Captain of Industry modding repo is incredibly useful for AI to reference when building features. Strongly recommend cloning.

Use `AskUserQuestion` with **"Want me to clone the official modding examples repo?"**:

- **Yes please** — strongly recommended; gives me real working code to reference
- **I already have it cloned** — tell me where, I'll just point at it
- **Skip for now** — fine, can do this later

If yes:
1. Default location: `C:\Code\Captain-of-industry-modding`.
2. If that path exists and is a git repo: just use it (do `git pull` to update).
3. Otherwise clone from `https://github.com/MaFi-Games/Captain-of-industry-modding`.

If "I already have it cloned": ask for the path. Verify it exists, has a `.git` folder, AND has a top-level `src/` folder (the official repo has one — better signal than just a README). If not, re-ask.

Save the path for the spawn.

---

## Step 7 — Confirm the blueprint, then spawn

### 7a. Show the blueprint and ask before building

**Don't skip this step.** Once `spawn.ps1` runs, the project folder is created, files are committed, and (if they chose a public GitHub repo) the description goes live publicly. The user needs a chance to course-correct on any of the inputs.

Show a tidy table of everything you've gathered, then ask one explicit question:

> Here's the blueprint before I lay the keel:
>
> | Field | Value |
> |---|---|
> | **Mod name** | <display-name> |
> | **Mod ID** | <mod-id> |
> | **Short pitch** | <short> |
> | **Description** | <long> |
> | **Location** | <target-path> |
> | **GitHub repo** | <Public/Private/Not now> — `<github-username>/<mod-id>` (if creating) |
> | **Work style** | <user-mode> |
> | **Modding examples** | <modding-repo-path or "Skipped"> |
>
> Look right? Reply `yes` / `looks good` to start construction, or tell me what to change (e.g. "make it private", "rename to FooBar", "the description should be...").

Wait for an affirmative response. If they ask to change something, apply the change and re-show the table. Loop until they confirm. **Critical:** never auto-proceed from showing the blueprint to spawning — even if they seem clearly ready, wait for an explicit go.

**Phrasing rule for the chat UI:** never tell the user to "press Enter" to accept a default. In a chat window, an empty Enter does nothing — the user must type something to send. When proposing a default, phrase the question so a one-word answer works: *"Default: `C:\Code\HelloWorld`. Type `yes` to use that, or paste a different folder."* Or even more naturally: *"I'll use `C:\Code\HelloWorld` unless you'd rather pick somewhere else — what's your call?"* This rule applies in **every** step of the wizard that offers a default.

### 7b. Run the spawn script

Once they confirm, run the script. Always invoke via `powershell -NoProfile -ExecutionPolicy Bypass -File` (Windows' default execution policy blocks running `.ps1` files directly).

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Code\COI-mod-template\scripts\spawn.ps1" `
    -LaunchpadPath "C:\Code\COI-mod-template" `
    -TargetPath "<target-abs-path>" `
    -ModId "<mod-id>" `
    -ModDisplayName "<display-name>" `
    -ModDescriptionShort "<short>" `
    -ModDescriptionLong "<long>" `
    -ModAuthor "<github-username>" `
    -GithubUsername "<github-username>" `
    -UserMode "<one of: Captain's Chair, Learning the Ropes, First Mate, Old Salt>" `
    -ModdingRepoPath "<modding-repo-path-or-(not cloned)>"
```

The script handles file copy, placeholder substitution (filenames + contents), UTF-8 no-BOM encoding, CRLF line endings, fresh GUID generation, profile-block injection, and a final no-leftover-tokens check.

Narrate as you go (one short line each):

> "Creating your project folder..."
> "Copying the template and personalizing it for `<MOD_ID>`..."
> "Setting up git..."
> "Doing a test build to make sure everything works..."

After the script returns successfully, do these in the spawned folder:

### 7c. Initialize git

```powershell
cd <target>
git init -b main
git add -A
git commit -m "Initial commit from COI-mod-template"
```

### 7d. Create the GitHub repo (if they chose that in Step 5)

Pass the user's `description_short` so the repo gets a tagline on GitHub instead of an empty description:

```powershell
gh repo create <MOD_ID> --public --description "<description-short>"   # or --private
git push -u origin main
```

### 7e. Test build

```powershell
cd <target>
dotnet build <MOD_ID>.sln
```

If this fails, surface the error clearly. Most likely cause: `COI_ROOT` not set or wrong (it should point to the folder containing `Captain of Industry_Data\`). Don't proceed past this — fix it before declaring success.

The same `-ExecutionPolicy Bypass` wrapping applies to the spawned project's other PowerShell scripts (`scripts/package-release.ps1`, etc.) when run from skills later. Always wrap with that flag rather than expecting `.\foo.ps1` to work.

---

## Step 8 — The handoff

This is critical. The user must close this Claude Desktop session and start a fresh one pointed at the new mod folder. Don't let them keep working in the onboarding session — the launchpad has none of their mod's tooling, and the spawned project's `CLAUDE.md` won't load until they open Claude Desktop pointed at the new folder.

Be explicit: non-tech users will absolutely try to just keep chatting here.

Sample wording (adapt freely, but keep all the substance):

> 🚢 **The keel's laid, Captain — your shipyard is open.**
>
> Your mod lives at `C:\Code\<MOD_ID>`. We're done in *this* dock — **don't keep chatting in this window. Open a fresh Claude Desktop session pointed at your new mod folder instead.** Here's how to weigh anchor:
>
> 1. Close this Claude Desktop window.
> 2. Open Claude Desktop again, hit **Ctrl+3** for Code mode.
> 3. When it asks what folder to work in (or in the folder picker), point it at `C:\Code\<MOD_ID>`.
> 4. When the new session greets you, tell it what you want to build. Something like: *"Let's launch the game and check that my hello-world message shows up in the log."*
>
> A few things worth knowing before you set sail:
> - The mod's already been built and shipped to your game's mods folder. Launch the game, load any save, and look in `%APPDATA%\Captain of Industry\Logs\` for a line starting with `<MOD_ID>:` — that's your hello.
> - You can delete `C:\Code\COI-mod-template` anytime — it's done its job. Or keep it around in case you want to spawn another mod later.
> - In your new mod session, type `/explain-this` anytime you're confused. I'll translate.

End with something playful and warm — they've just done the hardest part. A "fair winds, Captain" or "now go build something fun" beat works well.

---

## Notes for you

- If anything fails mid-spawn, leave the partial mod folder in place but tell the user clearly what failed. Don't auto-rollback — the user might want to inspect.
- If the user wants to abort mid-flow, that's fine. They can re-run the bootstrap prompt anytime.
- The spawn script refuses to overwrite an existing `manifest.json`, so re-running on the same target folder is safe.
- The launchpad itself should remain untouched at the end. We're spawning a new project, not transforming the launchpad.
- Profile blocks live in `.claude/skills/kickoff/profile-blocks/` (one file per mode). The spawn script reads them automatically — you don't inline them.
