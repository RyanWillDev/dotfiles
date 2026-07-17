---
name: start-task
description: Start a new long-running task with persistent context. Creates a task directory at ~/.claude/tasks/active/<slug>/ with context.md, status.md, and artifacts/. Use when starting work that will span multiple sessions or benefit from a dedicated background agent.
---

# Start Task

Creates a persistent task directory so work survives session boundaries.

## Steps

1. Derive a short kebab-case slug from the task name. If a ticket number was provided (e.g. PLATENG-1234), prefix the slug with it: `plateng-1234-auth-refactor`.
2. Create the directory structure at `~/.claude/tasks/active/<slug>/`:
   - `context.md` — background, goal, constraints, relevant ticket links, key file paths
   - `status.md` — initialized to "Status: In Progress" with empty sections
   - `artifacts/` — empty directory for outputs
3. Populate `context.md` from the user's description and any provided context.
4. Ask: should this start a background agent now, or are you jumping in interactively?
5. Report the slug and full path.

## context.md template

```markdown
# <Task Name>

## Goal
<what we're trying to achieve and why>

## Background
<constraints, relevant tickets, links, prior decisions>

## Key Files
<paths to important code, configs, or docs>

## Decisions
(none yet)
```

## status.md template

```markdown
# Status: In Progress

## Done
(nothing yet)

## Next Steps
<first concrete step>

## Blockers
(none)
```
