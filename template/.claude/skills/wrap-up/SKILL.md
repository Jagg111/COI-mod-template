---
name: wrap-up
description: Wrap the current session at a clean breakpoint. Summarizes what was done, commits any uncommitted work, writes a handoff note for the next session, and tells the user how to start fresh.
disable-model-invocation: true
---

Long sessions get expensive and slow. This skill is the clean exit ramp. Run it when the user is at a natural breakpoint, OR when you (Claude) suggest wrapping up because the session has gone long.

## Behavior

1. **Read the User Profile** in CLAUDE.md.

2. **Summarize what got accomplished.** Look at:
   - Commits made this session (`git log --since="<session start>"` is approximate; just use the last several commits)
   - Files changed
   - Notable conversations

   Write a 2-4 line plain-English summary. Examples:
   > This session: added a hello-world button to the top toolbar, fixed the button not appearing on small resolutions, and confirmed the mod loads cleanly in-game. Two snapshots saved.

3. **Handle uncommitted work.** If `git status --porcelain` is non-empty, auto-commit via `/snapshot` logic with a descriptive message ("Wrap-up snapshot: <summary>"). The `/snapshot` skill handles per-mode push behavior — auto-push for Captain's Chair / Apprentice, manual push for Master.

4. **Write a handoff note** to a file at the repo root called `NEXT-SESSION.md`. Overwrite if it exists. Format:

   ```markdown
   # Next Session Notes

   *Last updated: <date>*

   ## What we just finished

   <2-4 line summary from step 2>

   ## What to do next

   <1-3 suggested next steps based on the conversation. If the user mentioned plans, capture them. If not, suggest something obvious like "test the latest changes in-game" or "decide what feature to build next".>

   ## Anything to remember

   <Notes about decisions made, gotchas discovered, things half-finished. Empty if nothing notable.>
   ```

   This file is git-tracked. It's how a fresh Claude session in a new conversation picks up the thread. CLAUDE.md instructs Claude to read this on session start if it exists.

5. **Print the handoff message:**

   > 🛠️ Pulling into port. Here's the day's haul:
   >
   > <summary>
   >
   > Notes are tucked in `NEXT-SESSION.md` for next time. To pick this back up later, open a new Claude session in this folder and say "continue where we left off" — I'll catch up from the logbook.
   >
   > Fair winds, Captain. <one short closing line — something fun, lightly nautical/industrial when it fits, never forced.>

   Examples of a good closing line: "The factory hums on without us." / "Save the world another day." / "Steam up, see you next shift." Don't reuse the same one twice in a row.

6. **Don't actually close anything.** This skill doesn't kill the session — that's the user's call. It just wraps things up cleanly so they *can* close.

## When to suggest this skill (without being asked)

Per the User Profile cost-management guidance: at natural breakpoints, you can suggest `/wrap-up` to the user. Once per session max. Never mid-debugging. Good moments:

- Right after a feature lands and you've verified it works
- Right after a release ships
- After resolving a debugging thread
- When the conversation has covered 3+ clearly distinct topics

Never suggest wrap-up:
- In the middle of fixing something
- When the user is mid-thought
- When you've already suggested it once this session

## Notes

- `NEXT-SESSION.md` is the project's living "where were we" document. It evolves over time. It's intentionally short — long handoffs don't get read.
- If `NEXT-SESSION.md` exists at the start of a session, the next Claude should read it as part of orienting.
