---
name: explain-this
description: Explain code, concepts, or game internals in plain English. Three modes — pointed at a file/region, at a concept in the user's own code, or at a game term in MODDING-REFERENCE. Aimed at a non-coder learning by exposure.
disable-model-invocation: true
---

The friend looks at their own code or some piece of jargon and goes "wait, what is this?" This skill is "answer that question without making me feel dumb."

## Behavior

The user invokes this in one of three ways. Identify which:

### Mode A — Pointed at code

> `/explain-this MyMod.cs`
> `/explain-this lines 40-60 of MyMod.cs`
> `/explain-this what's happening on line 42`

Read the file (or the specified region) and explain in plain English what it does. Approach:

1. **Start with the punchline.** One sentence about what the whole thing does.
2. **Break it down by section.** Each section gets a sentence or two.
3. **Skip the obvious.** Don't explain `using System;` to anyone.
4. **Define jargon inline.** First time you say "constructor", say "(the special function that runs when the class is created)". Reuse the term freely after.
5. **Suggest what they could change.** End with: "Most people who modify this end up changing X — let me know if you want to try."

### Mode B — Concept in their own codebase

> `/explain-this what is ReflectionProbe`
> `/explain-this why do we have a ModJsonConfig`
> `/explain-this the difference between Initialize and EarlyInit`

Search the codebase and `MODDING-REFERENCE.md` for the term. Explain:
1. What it is.
2. Why it's used in this project.
3. Where it shows up (one or two file:line references).
4. Whether they should care about it usually, or not.

### Mode C — Game term or API question

> `/explain-this what is ResearchManager`
> `/explain-this how does the prototype system work`
> `/explain-this Option<T>`

Use the **Research Protocol** from CLAUDE.md:
1. Check `MODDING-REFERENCE.md` first.
2. If not there, look at the official modding examples repo (path is in CLAUDE.md).
3. If not there, inspect the game DLLs.

Explain:
1. What it is in one sentence.
2. A small example of how mods use it.
3. Common gotchas (especially anything in the "Critical Gotchas" or "Dead Ends" sections of `MODDING-REFERENCE.md`).
4. Whether their mod would likely need this. (Honest assessment: "probably yes if you ever do X" or "probably never — mostly internal.")

**If you discover anything new during Mode C research that isn't already in `MODDING-REFERENCE.md`, append it.** That's the documentation rule.

## Tone

- **Captain's Chair / Learning the Ropes** — friendly, conversational, examples > theory.
- **First Mate** — same as above but you can go deeper.
- **Old Salt** — terse, accurate, no hand-holding.

Default to conversational unless told otherwise.

## What NOT to do

- Don't lecture. The user asked a question — answer it.
- Don't explain *everything* — explain what they asked.
- Don't paste long blocks of code "for context" unless they specifically asked. Reference line numbers instead.
- Don't reach for analogies that don't fit just to seem accessible. Plain language beats forced metaphors.

## Length guidance

A typical answer is 4-12 lines. If you find yourself writing more than that, stop and ask: "Want me to keep going? I've got more I could say about X." — let them pull more if they want it, instead of dumping it all.
