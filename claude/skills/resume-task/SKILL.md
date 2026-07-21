---
name: resume-task
description: Continue a /start-task task by slug. Invoke when the user asks to resume an in-progress task.
---

# Resume Task

## Steps

1. **Resolve slug.** If no slug provided:
   - In a git repo: `git rev-parse --show-toplevel` → root; list directories under `<root>/.worktrees/` that contain `.claude/status.md`. Present names and their one-line status; ask which to resume.
   - Not in a git repo: list `~/.claude/tasks/active/`; ask which task to resume.

   Wait for selection before continuing.

2. **Load.**
   - In a git repo: read `<root>/.worktrees/<slug>/.claude/context.md` and `status.md`. Scan `<root>/.worktrees/<slug>/.claude/artifacts/` for prior outputs relevant to the next step.
   - Fallback: read `~/.claude/tasks/active/<slug>/context.md` and `status.md`. Scan `artifacts/`.

3. **Orient.** State the current position in one sentence: what the task is and where it left off.

4. **STOP.** Ask what to do next. Wait for a response before beginning work.

## Session maintenance

- Update `status.md` at end of session: decisions made, next steps, blockers.
- To close a task: set `status.md` to `Status: Complete` with a brief summary. Remove the worktree with `git worktree remove <root>/.worktrees/<slug>` once merged or no longer needed.
