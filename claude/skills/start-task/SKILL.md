---
name: start-task
description: Start a new long-running task — sets up a task directory and worktree, then runs five pre-implementation stages before any code is written.
---

# Start Task

Five ordered stages, each ending at a hard gate. After each STOP, wait for an explicit user response before proceeding — any acknowledgment clears the gate; silence does not.

## Setup

1. Derive a kebab-case slug. Prefix any ticket number: `plateng-1234-auth-refactor`.
2. Create `~/.claude/tasks/active/<slug>/` with `context.md`, `status.md`, and `artifacts/` (templates in Reference below).
3. Populate `context.md` from the user's description.
4. If in a git repo:
   - Run `git rev-parse --show-toplevel` to find the repo root.
   - Run `git worktree add <repo-root>/.worktrees/<slug>`.
   - Record the worktree path in `context.md` under `## Worktree`.
   - Write `<worktree-root>/.claude-task` containing the task directory path.
5. Declare the environment:
   > **Task:** `~/.claude/tasks/active/<slug>/`
   > **Worktree:** `<repo-root>/.worktrees/<slug>/` *(or "no worktree — not in a git repo")*

Then proceed through the stages in order.

---

## Stage 1 — Gather Context

Invoke the `gather-context` skill. It pulls from Jira tickets, GitHub refs, URLs, and local code paths mentioned in the task description, and writes `artifacts/context-gathered.md`.

**STOP.** Summarize what was gathered in 2–3 sentences. Ask: "Are there other sources to query before we move on?"

---

## Stage 2 — Align Understanding

Invoke the `align-understanding` skill. It discovers domain terms, applies conceptual engineering to examine and revise them, and produces:

- `artifacts/glossary.md` — agreed definitions for every term used in the plan
- `artifacts/concept-map.md` — mermaid diagram of concept relationships

**STOP.** Write one sentence describing the task using only glossary terms. If a required word is absent from the glossary, add it before proceeding. Ask: "Does the glossary cover everything? Any term that still feels imprecise?"

---

## Stage 3 — Build Brief

Write `artifacts/task-brief.md` using the template in Reference. Apply `writing-for-humans` style. For spatially complex domains, add a system diagram or data-flow diagram in mermaid.

Ask whether to publish the brief as an Artifact and await confirmation before doing so.

**STOP.** Ask: "Does the brief accurately represent the task? Anything missing or wrong?"

---

## Stage 4 — Construct Plan

Write `artifacts/plan.md`. Every step must name its dependency and its output. Use only glossary terms.

```markdown
### Step N: <name>
**Depends on:** <step, or "nothing">
**Produces:** <artifact or observable change>
<description>
```

**STOP.** Present the plan. Ask: "Does the ordering make sense? Any step vague enough to mean multiple things?"

---

## Stage 5 — Review

Present `artifacts/plan.md` alongside the task brief. Ask:

1. Does the plan reflect the actual goal?
2. Is any step ordered wrong or missing a dependency?
3. Is any step vague enough to mean multiple things in the glossary?

Iterate on Stage 4 until the user explicitly signs off ("looks good", "let's go", or equivalent).

After sign-off, update `status.md`: mark planning complete, set the first implementation step as Next Steps.

---

## Reference

### task-brief.md template

```markdown
# Task Brief: <Task Name>

## What We're Building
<one paragraph: goal in plain language>

## Why It Matters
<motivation, constraints, deadline if any>

## Key Concepts
<link to glossary or inline 2–3 most important terms>

## Scope
**In:** <what this task changes>
**Out:** <what this task deliberately does not change>

## Open Questions
<unresolved questions that don't block planning>
```

### context.md template

```markdown
# <Task Name>

## Goal
<what we're trying to achieve and why>

## Background
<constraints, relevant tickets, links, prior decisions>

## Worktree
<repo-root>/.worktrees/<slug>/

## Key Files
<paths to important code, configs, or docs>

## Decisions
(none yet)
```

### status.md template

```markdown
# Status: In Progress

## Done
(nothing yet)

## Next Steps
Stage 1: Gather Context

## Blockers
(none)
```
