# Claude Code — Global Preferences

## About Ryan

Senior software engineer at Instinct (veterinary practice management). Primary stacks: Elixir/Phoenix, PostgreSQL. Works across multiple backend services. Daily tools: Jira (`acli`), GitHub (`gh`).

## Working Style

**Be direct.** State a recommendation, not a survey. If you have a view, lead with it and note the key tradeoff. Skip the "here are all the options" preamble when the answer is clear.

**Scope tightly.** Don't expand beyond what was asked. Surface a tangential issue as a brief note at the end — don't fold it into the work. Bug fix ≠ refactor opportunity.

**Pragmatic over robust.** Prefer simple solutions over theoretically general ones. No error handling for impossible scenarios, no backwards-compat shims, no feature flags unless asked.

**No explanatory comments.** Only comment when the *why* is non-obvious. Never comment what the code does.

**Trust internals.** Validate at system boundaries (user input, external APIs). Trust framework guarantees and internal contracts.

**Think operationally.** When reasoning about code, think about *where* it runs — which service, which process, what environment. Correctness in context, not in the abstract.

## Memory System

**Global** — `~/.claude/memory/` — preferences, feedback, and patterns that apply everywhere. Index at `~/.claude/memory/MEMORY.md`. Read this at the start of any session.

**Project** — `<project-root>/.claude/memory/` — project-specific context, ongoing work, decisions. Index at `<project-root>/.claude/memory/MEMORY.md`.

When saving a memory, ask Ryan which scope if it's not obvious from context. Ryan controls where memories are written.

## Task System

Long-running tasks that span sessions live at `~/.claude/tasks/active/<slug>/`:

```
~/.claude/tasks/active/<slug>/
  context.md    # background, goal, constraints, key files/links
  status.md     # current state, decisions made, next steps, blockers
  artifacts/    # outputs: code, notes, queries, scratch files
```

Use `/start-task` to create this structure for a new task.
Use `/resume-task` to pick up an existing task by slug.
Completed tasks move to `~/.claude/tasks/archive/`.

When resuming a task, read `context.md` and `status.md` before doing anything else, then restate where things stand in one sentence before asking what to do next.
