---
name: snapshot
description: Save the user's current work as a git commit so they can experiment freely without losing it. Designed for users who don't know git — wraps "git add + git commit" in plain English.
disable-model-invocation: true
---

This skill is "save my work right now" for non-coders. It's a plain-English wrapper around `git add -A && git commit`.

## Behavior

1. **Read the User Profile in CLAUDE.md** to know how chatty to be.

2. **Check if there's anything to save:**
   ```
   git status --porcelain
   ```
   If empty: tell the user there's nothing new to save, everything's already saved. End.

3. **Check for accidentally-included secrets.** Look for any files matching: `.env`, `*.key`, `*.pem`, `secrets.*`, `credentials.*`. If found, warn the user clearly and stop — ask whether to add them to `.gitignore` first or proceed anyway.

4. **Decide on a commit message:**
   - If the user passed a message after `/snapshot` (e.g. `/snapshot trying out blue button`), use it as-is.
   - Otherwise: look at what's changed (`git diff --stat`) and propose a plain-English message describing what was changed. One line, no jargon. Examples: "Try out blue button", "Fix mod not loading", "Update changelog".
   - In **all three modes**, just use the proposed message — don't pause to ask for approval. Auto-commit is the floor across the board.

5. **Commit:**
   ```
   git add -A
   git commit -m "<message>"
   ```

6. **Push behavior depends on mode:**
   - **Captain's Chair / Apprentice (auto-push):** if a remote is configured, run `git push` automatically.
     ```
     git push
     ```
     If push fails, don't panic the user — explain calmly that the snapshot saved locally but didn't reach GitHub yet, and offer to retry or look at the error.
   - **Master (manual push):** do NOT auto-push. Tell the user the snapshot saved locally and that pushing to GitHub is their call. First time per session, take a moment to explain what `push` does and why we keep it manual: *"`git push` is what sends your local commits up to GitHub — committing saves locally, pushing makes it visible online. We keep this manual in Master mode so you decide when work is ready to share."* Then offer: *"Want me to push now? Or hold off?"*

7. **Confirm to the user** in friendly language. A light Captain-of-Industry beat is welcome here: "Logged in the captain's log: '<message>'." or "Snapshot saved — '<message>'." Pick what fits. If pushed, add "Also backed up to GitHub." If only local, mention that. Don't be cute every time — it loses its charm fast.

8. **Teaching beats by mode** (drop the first time per session, then move on):
   - **Apprentice:** one-sentence ELI5 — "(by the way, what I just did is called a 'commit' — it's a checkpoint you can come back to later with `/rewind`.)"
   - **Master:** a slightly deeper concept moment — what a commit actually is (a snapshot of the whole project tied to a unique hash), how git uses commits to let you move backwards/forwards in history, and why that's powerful for experimentation. Two or three sentences, not a lecture.
   - **Captain's Chair:** no teaching beat. Move on.

## Notes

- This skill is intentionally low-ceremony. The friend uses it many times per session.
- Never refuse to snapshot because the work is "incomplete" or "untested" — the whole point is letting them save freely. The commit doesn't have to be perfect.
- If the user has uncommitted work spanning multiple unrelated changes, that's fine — bundle it all together. We're not trying to teach atomic commits here.
