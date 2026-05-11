---
name: ship-it
description: Run when code changes are ready to release. Handles pre-flight checks, version bump, AI-drafted What's New bullets (reviewed in-session), changelog.txt update, packaging, and COI Hub upload reminder.
disable-model-invocation: true
---

Walk through each step in order. Stop and report clearly if anything fails.

## What this does and why

When the user is ready to publish a new version of the mod, this skill walks through the full release process. It checks that the code is clean and on the right branch, helps pick a version number, writes player-friendly release notes, updates the changelog, packages the zip, and reminds the user to upload to the COI Mod Hub.

## Key files

| File | What it does |
|------|-------------|
| `manifest.json` | Mod ID and version - source of truth for release tags and titles. Read once at the start to learn the mod ID. |
| `changelog.txt` | Cumulative player-facing changelog; updated each release and bundled inside the mod ZIP. |
| `bin/pkg/whats-new.md` | Release notes draft - written during this workflow as a working buffer. |
| `scripts/package-release.ps1` | Packaging script that builds the zip for Hub upload. |

**Test mode:** If the user invoked `/ship-it --test`, follow all steps but:
- Do NOT write `bin/pkg/whats-new.md`
- Do NOT edit `manifest.json` or `changelog.txt`
- Do NOT run `scripts/package-release.ps1`
- Instead, show what *would* happen at each of those steps and label the output clearly with `[TEST RUN -- not applied]`

At the end of a test run, say "Test run complete -- nothing was written or committed."

---

## Step 0 -- Stale notes guard and identity

Before talking to the user, read `manifest.json` to learn the mod ID. You'll use this as the project name throughout.

Check whether `bin/pkg/whats-new.md` already exists.

- If it does **not** exist: continue to Step 1.
- If it **does** exist: show the user its contents and ask: "A `whats-new.md` from a previous run exists. What would you like to do -- use it as a starting point, discard it, or cancel?"
  - **Use it** -- load its contents as the draft bullets in Step 3; skip the research phase and go straight to "Any tweaks?"
  - **Discard it** -- delete the file and continue normally from Step 1
  - **Cancel** -- stop here, do nothing

---

## Step 1 -- Pre-flight checks

Make sure the workspace is in a clean state and ready to release.

Run both checks. If either fails, report what's wrong and stop -- do not continue.

1. Run `git status --porcelain` -- output must be empty (clean working tree)
2. Run `git branch --show-current` -- must output `main`

If either fails:
- Dirty working tree: tell the user clearly what's uncommitted and ask them to commit or stash before continuing.
- Wrong branch: ask the user to switch to `main` first.

If everything passes, say "Pre-flight checks passed." and continue.

---

## Step 2 -- Version bump decision

Show the user what's changed since the last release so they can pick the right version bump.

1. Read `manifest.json` and show the user the current version
2. Run `git tag --sort=-creatordate` to find the most recent tag (call it `$prevTag`). If no tags exist, note that this will be the first release.
3. Run `git log $prevTag..HEAD --pretty=format:"%s%n%b"` (or `git log HEAD --pretty=format:"%s%n%b"` if no tags) to capture both subject and body of each commit
4. Show the user the raw commit list, including any issue references found in commit bodies

Then ask the user which version bump to apply. Show the current version and these options:
- **Patch (0.0.X)** -- bug fixes and small tweaks. When in doubt, use this.
- **Minor (0.X.0)** -- new features a player would notice. Resets patch to 0.
- **Major (X.0.0)** -- reserved for major milestones or game-update-forced rewrites. Resets minor and patch to 0.

Wait for the user to choose before continuing.

---

## Step 3 -- Draft What's New bullets

Research what actually changed in the code so the release notes are accurate, not just based on commit messages.

Before writing bullets, do deep research on every player-visible commit:

1. **For every issue number (`#N`) found in any commit subject or body:** if `gh` is available, run `gh issue view N` to get the issue title, description, and comments.
2. **For every player-visible commit:** run `git show <hash>` (filtered to relevant source files) to read the actual code diff. Use this to understand exactly what changed, not just what the commit message says.
3. **Group commits by issue.** All commits referencing the same `#N` belong to one bullet. Commits with no issue reference get their own bullet if player-visible -- always read the code diff for these too.

Then write the bullets using these rules:
- Write for players, not developers. "Queues now carry over between game sessions" not "refactor queue persistence layer"
- Use the issue details AND the code diff to write a concise but meaningful description
- Omit commits that have no player-visible effect (build changes, README edits, code cleanup, docs, comment fixes)
- One bullet per GitHub issue maximum. Merge all commits for that issue into a single bullet.
- If a GitHub repo is configured (read `links` in manifest.json or `git remote get-url origin`), append the issue link at the end of the bullet: `([#N](https://github.com/owner/repo/issues/N))`. If no GitHub repo is configured, just append `(#N)` plain.
- No em dashes anywhere
- No headers, no sections -- just the bullet list

**Show the bullets inline in the conversation** and ask: "Any tweaks before I save these?"

Apply any edits the user requests. Once they approve:

1. Write the final bullets to `bin/pkg/whats-new.md` (create the folder if needed).
2. Prepend a new entry to `changelog.txt` in the project root using the Hub format:
   ```
   vX.X.X | YYYY-MM-DD
   * Bullet one
   * Bullet two
   ```
   - Use today's date in `YYYY-MM-DD` format
   - Convert `-` bullet markers to `*`
   - Strip any markdown link syntax from bullets (plain text only - the Hub renders changelog.txt as plain text)
   - Leave a blank line between this new entry and the previous one
3. Confirm both files were written.

---

## Step 4 -- Bump version and commit

Update the version number and commit everything together.

1. Calculate the new version from the user's choice in Step 2 and edit `manifest.json` with the new version string
2. Suggest a commit message following the project's style:
   - Single line, no body text
   - Example: `Version bump to 1.2.3`
   - If the release closes or fixes a GitHub issue, append `Fixes #N` or `Closes #N`

3. **Behavior depends on the user's mode (read CLAUDE.md User Profile block):**
   - **Captain's Chair / Apprentice** - auto-commit, auto-tag, auto-push:
     ```
     git add manifest.json changelog.txt
     git commit -m "<suggested message>"
     git tag v<version>
     git push && git push --tags
     ```
   - **Master** - auto-commit and auto-tag, then **show the push commands and wait** for the user. This is a teaching moment about publishing:
     ```
     git add manifest.json changelog.txt
     git commit -m "<suggested message>"
     git tag v<version>
     ```
     Then explain what's next: *"Now your release is committed and tagged locally. To publish, run these - `git push` sends the commit, `git push --tags` sends the version tag separately so people downloading the source can find this exact release. Want me to run them, or do you want to type them yourself?"*

   The git tag is for source archaeology only - the COI Hub is the actual release channel. Tags do not trigger any distribution.

---

## Step 5 -- Package the release

Build and package the mod zip for Hub upload.

Run:

```
.\scripts\package-release.ps1
```

The script builds the DLL, stages the mod files into the zip, and outputs the final zip path.

Stream the output. If the script fails, show the full error and stop.

---

## Step 6 -- Upload to COI Hub

The COI Hub is the exclusive distribution channel. Players download and install updates manually from there.

Read the mod ID and version from `manifest.json`. Tell the user:

> 🚢 Cargo's loaded - `<MOD_ID>` v<version> is ready to ship.
>
> Your release zip is at `bin\pkg\<MOD_ID>-v<version>.zip`.
>
> Upload it to the [COI Mod Hub](https://hub.coigame.com) via "upload new version" on your mod's page. (First release? Create a new mod listing first.)
>
> - The Hub auto-parses `changelog.txt` from inside the zip - no copy-paste needed.
> - License is set once at first upload and persists across versions.
> - Mark the version as **Stable** (or **Beta** if it's a pre-release).

Conclude with something fun and lighthearted - a "she's seaworthy" / "all hands celebrated" / "v<version> is on the shipping lane" beat works well. Sprinkle, don't pour.

---

## Notes

- The What's New bullets are written for players, not developers. Commits that only affect build scripts, docs, or code comments are intentionally left out of the release notes.
- `changelog.txt` is plain text - strip markdown link syntax when writing to it. The Hub does not render markdown.
- `scripts/package-release.ps1` can also be run standalone outside of this workflow if needed, as long as `changelog.txt` exists and is up to date.
- The COI Hub does NOT provide automatic updates to players. Players must manually download and install each new version.
