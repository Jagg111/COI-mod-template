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
   - In **Captain's Chair** or **Learning the Ropes** mode, just use the proposed message.
   - In **First Mate** or **Old Salt** mode, show the proposed message and ask for approval.

5. **Commit:**
   ```
   git add -A
   git commit -m "<message>"
   ```

6. **If a remote is configured AND mode is Captain's Chair or Learning the Ropes,** push automatically:
   ```
   git push
   ```
   If push fails, don't panic the user — explain calmly that the snapshot saved locally but didn't reach GitHub yet, and offer to retry or look at the error.

7. **Confirm to the user** in friendly language. A light Captain-of-Industry beat is welcome here: "Logged in the captain's log: '<message>'." or "Snapshot saved — '<message>'." Pick what fits. If pushed, add "Also backed up to GitHub." If only local, mention that. Don't be cute every time — it loses its charm fast.

8. **In Learning the Ropes mode**, drop a one-sentence teaching moment the first time per session: "(by the way, what I just did is called a 'commit' — it's a checkpoint you can come back to later with `/rewind`.)"

## Notes

- This skill is intentionally low-ceremony. The friend uses it many times per session.
- Never refuse to snapshot because the work is "incomplete" or "untested" — the whole point is letting them save freely. The commit doesn't have to be perfect.
- If the user has uncommitted work spanning multiple unrelated changes, that's fine — bundle it all together. We're not trying to teach atomic commits here.
