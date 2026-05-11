---
name: kickoff
description: Onboarding wizard for the COI Mod Template. Spawns a personalized mod project in a new folder. The full instructions live in KICKOFF.md at the launchpad root - this file just delegates to it.
disable-model-invocation: true
---

The full kickoff playbook lives at the launchpad root: **`KICKOFF.md`**. Read that file (it's a few hundred lines, well-organized) and follow it as the wizard.

Why split it out: the same playbook also runs from a fresh Claude Desktop session that was handed off by `BOOTSTRAP.md`, which doesn't have access to slash commands. Keeping the playbook at the repo root means both entry paths execute identical logic.

If you arrived here via the `/kickoff` slash command (i.e., the user is already inside the cloned launchpad and invoked it manually), do a quick pre-flight before reading `KICKOFF.md`:

- Confirm `dotnet --version`, `git --version` work.
- Confirm `[Environment]::GetEnvironmentVariable('COI_ROOT','User')` is set.

If anything's missing, tell the user that the bootstrap prompt (in the launchpad's `README.md`) handles installs and they should paste that instead. Then stop. Don't try to fix the environment from here - that's `BOOTSTRAP.md`'s job.

Otherwise, read and follow `KICKOFF.md` from the launchpad root.
