---
name: resume-task
description: Continue a /start-task task by slug. Invoke when the user asks to resume an in-progress task.
---

# Resume Task

## Steps

1. **Resolve slug.** If no slug provided, list `~/.claude/tasks/active/` and ask which task to resume. Wait for selection before continuing.
2. **Load.** Read `~/.claude/tasks/active/<slug>/context.md` and `status.md`. Scan `artifacts/` for prior outputs relevant to the next step.
3. **Orient.** State the current position in one sentence: what the task is and where it left off.
4. **STOP.** Ask what to do next. Wait for a response before beginning work.

## Session maintenance

- Update `status.md` at end of session: decisions made, next steps, blockers.
- To close a task: move `~/.claude/tasks/active/<slug>/` to `~/.claude/tasks/archive/<slug>/` and set `status.md` to `Status: Complete` with a brief summary.
