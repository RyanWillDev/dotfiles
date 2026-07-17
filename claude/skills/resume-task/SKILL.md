---
name: resume-task
description: Resume a long-running task that was started with /start-task. Lists active tasks or loads a specific task by slug, reads its context and status, then picks up from where it left off.
---

# Resume Task

## Steps

1. **If no slug provided**: list directories under `~/.claude/tasks/active/` and ask which task to resume.
2. **With a slug**: read `~/.claude/tasks/active/<slug>/context.md` and `status.md` immediately — before doing anything else.
3. Restate the current state in one sentence (what the task is, where it left off).
4. Ask what to do next — don't assume.

## Notes

- Check `artifacts/` for any prior outputs that are relevant before starting new work.
- When work is complete, move the task directory to `~/.claude/tasks/archive/<slug>/` and update `status.md` to "Status: Complete" with a brief summary of what was accomplished.
- Update `status.md` at the end of each working session — the next session depends on it being current.
