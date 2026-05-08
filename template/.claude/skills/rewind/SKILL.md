---
name: rewind
description: Go back to a previous snapshot. Lists recent commits in plain English and lets the user pick one. Designed for non-coders who don't know git reset/checkout.
disable-model-invocation: true
---

This skill is "go back to before I broke it" for non-coders. It hides git-reset/checkout behind plain English.

## Behavior

1. **Read the User Profile in CLAUDE.md** to calibrate tone.

2. **Check for uncommitted work first.** Run `git status --porcelain`. If there's uncommitted stuff, warn clearly:

   > Heads up — you have unsaved changes. If you rewind now, those will be lost. Want to save them first as a snapshot, or rewind anyway and lose them?

   Offer three options:
   - **Save them as a snapshot first** — invoke `/snapshot` (or do the equivalent inline) before rewinding.
   - **Rewind anyway, lose the changes** — proceed.
   - **Cancel** — stop.

3. **List recent snapshots in human terms:**
   ```
   git log --oneline -20 --pretty=format:"%h | %ar | %s"
   ```
   Format the output for the user as a numbered list:
   ```
   1. 5 minutes ago — Try out blue button
   2. 1 hour ago — Fix mod not loading
   3. yesterday — Update changelog
   4. 2 days ago — Add hello world button
   ...
   ```
   Show maximum 20 entries. Tell them they can pick by number, or paste a commit hash if they want something older.

4. **Wait for the user's choice.** If they pick number N, use the corresponding commit hash.

5. **Confirm before doing anything destructive:**

   > About to rewind to: "Try out blue button" (5 minutes ago).
   >
   > Everything you've changed since then will be gone. This can be undone but it's a hassle.
   >
   > Continue? (yes/no)

   In **Captain's Chair** mode, only ask once and accept any affirmative answer. In other modes, be more thorough.

6. **Do the rewind:**
   ```
   git reset --hard <commit-hash>
   ```

   This is one of the few places we use `--hard`. The User Profile safety floor says destructive operations always confirm, which we did in step 5.

7. **If a remote is configured and the user has already pushed work past this point**, that's a complication. After the reset, **do not** auto-push (that would be a force push). Tell the user:

   > Local rewind done. GitHub still has your old work though — if you want GitHub to match this rewind too, you'll need a force-push, which is a more advanced operation. Want me to walk you through that, or leave GitHub alone for now?

   Default to leaving GitHub alone unless they explicitly ask.

8. **Confirm in friendly terms:**

   > Course corrected — you're back at "Try out blue button" (5 minutes ago). The mod is in the state it was in then. Rebuild to see the rewound version in-game.

   Or just "Done — back to <X>." Pick what fits the moment; don't milk the metaphor.

9. **In Learning the Ropes mode**, drop a one-sentence teaching moment first time: "(by the way, going back to a previous commit is called a 'reset' — git keeps the history of every snapshot you ever made, so we can move between them.)"

## Notes

- Never silently force-push to a remote. Force-pushing past published work is destructive and easy to do wrong.
- If the user picks a commit and immediately regrets it, `git reflog` shows where they came from — they can recover. Mention this if they sound nervous.
- If there are no commits yet (brand new repo with only the kickoff commit), tell them there's nothing to rewind to.
