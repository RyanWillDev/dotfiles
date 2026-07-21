---
name: start-task
description: Start a new long-running task — sets up a task directory and worktree, then runs interactive pre-implementation stages to establish invariants and a verified plan before any code is written. Supports lite mode for simpler tasks.
---

# Start Task

## Modes

| Mode | When | Stages |
|------|------|--------|
| **lite** | "lite" in the invocation | Gather → Invariants → Plan → Implement |
| **standard** | default | Gather → Align → Brief → Invariants → Plan → Implement |

## Pattern

**Elicit, don't propose.** Each stage builds agreement through short exchanges, then writes a record. Ask one narrow question, get an answer, propose something specific, confirm, move on. Write artifacts last — they record what was settled, not something to review.

---

## Setup

1. Derive a kebab-case slug. Prefix any ticket number: `plateng-1234-auth-refactor`.
2. **In a git repo:**
   - `git rev-parse --show-toplevel` → repo root
   - `git worktree add <root>/.worktrees/<TICKET_NUMBER|SLUG>`; name branch `feature/<TICKET_NUMBER>` if given a ticket
   - Create `<worktree-root>/.claude/` with `context.md`, `status.md`, and `artifacts/` (templates in Reference)
   - Populate `context.md` from the user's description
   - Declare:
     > **Task:** `<worktree-root>/.claude/`
     > **Worktree:** `<root>/.worktrees/<slug>/`
     > **Mode:** lite *or* standard
3. **Not in a git repo (fallback):**
   - Create `~/.claude/tasks/active/<slug>/` with `context.md`, `status.md`, and `artifacts/`
   - Populate `context.md` from the user's description
   - Declare:
     > **Task:** `~/.claude/tasks/active/<slug>/`
     > **Worktree:** none
     > **Mode:** lite *or* standard

---

## Stage 1 — Gather Context *(both modes)*

1. Name every source detected in the task description — Jira tickets, GitHub refs, URLs, local paths. Ask: "Anything else to pull before I start?"

   *Proceed only after the user confirms the source list.*

2. Invoke the `gather-context` skill to retrieve.

3. After each source: surface one key finding as a statement, then ask one confirmation question. "The ticket says the main constraint is X — is that still accurate?" Adjust if corrected.

   *Proceed to the next source only after the user confirms or corrects the finding.*

4. Write `artifacts/context-gathered.md` — a record of confirmed findings, not a raw dump.

**STOP.** "Anything missing before we move on?"

---

## Stage 2 — Align Understanding *(standard only)*

Invoke `align-understanding`. It surfaces ambiguous terms one at a time, proposes definitions, and records the glossary as agreement is reached.

**STOP.** Write one sentence describing the task using only glossary terms. Every word in that sentence must be in the glossary. Ask: "Any term that still feels imprecise?"

---

## Stage 3 — Build Brief *(standard only)*

Ask these four questions in order. Write only after all four are answered.

1. "What's the main thing we're building?" *(becomes the lede)*
2. "What's driving it — deadline, constraint, business reason?" *(if none, say so)*
3. "What's explicitly out of scope?"
4. "Any open questions that don't block planning?"

Write `artifacts/task-brief.md` from the answers. Apply `writing-for-humans` style.

Ask whether to publish the brief as an Artifact. Await confirmation before publishing.

**STOP.** "Anything missing or wrong in the brief?"

---

## Stage 4 — Invariants & Verification *(both modes)*

**Anchor** what must not break and how done is verified — before any code is written.

**Invariants:**

Ask: "What must remain true throughout this work?" Seed with the obvious ones:
- Existing test suite passes
- Public API surface unchanged *(if applicable)*

Per invariant named: propose a check. "I'd verify that with `<command>`. Right check?" Confirm before moving on.

*Every invariant has a confirmed check command before proceeding.*

**Acceptance criteria:**

Ask: "What needs to be true when this is finished?" Per criterion, propose a concrete check. Push back on vague criteria — if it can't be checked, it goes in Open Questions, not criteria.

*Every acceptance criterion has a runnable check before proceeding.*

Write `artifacts/invariants.md` (template in Reference).

**STOP.** "Any invariant we'd feel bad about breaking that isn't listed?"

---

## Stage 5 — Construct Plan *(both modes)*

Propose steps in batches of 2–3. Confirm each batch before continuing. Write `artifacts/plan.md` only after all steps are agreed.

Each step:

```
Step N: <name>
Depends on: <step, or "nothing">
Produces: <artifact or observable change>
Verify: <command from invariants.md — what a passing result looks like>
```

A step without `Verify` is incomplete. Either identify the check or note explicitly that it's verified only at the end and why.

After each batch: "Does this ordering make sense? Anything that should come first?"

**STOP.** Write `artifacts/plan.md`. Update `status.md`: planning complete, first step as Next Steps. Ask: "Any step vague enough to mean two different things?"

---

## Stage 6 — Implementation *(both modes)*

Execute one step at a time. No pause between steps unless something breaks.

Per step:

1. **Announce.** One sentence: what it is, what it produces.
2. **Implement.** Only what this step describes — nothing from later steps.
3. **Verify.** Run the step's `Verify` command and any invariants in `artifacts/invariants.md` that apply. Report: passed / failed / skipped and why.
4. **Update `status.md`.** Step to Done, next step to Next Steps. After every step, not batched.
5. Proceed immediately.

**On failure:** Fix before advancing. If the fix changes the plan, update `artifacts/plan.md` inline before continuing.

No git commits without explicit user confirmation. When all steps are done, update `status.md` as complete.

**STOP.** Summarize: what was built, which steps passed verification, anything adjusted. "Does everything look right? Ready to commit?"

---

## Session Maintenance

- Update `status.md` whenever the session ends mid-task: decisions made, current state, next steps, blockers.
- To close a task: set `status.md` to `Status: Complete` with a brief summary. Run `git worktree remove <root>/.worktrees/<slug>` once the branch is merged or no longer needed.

---

## Reference

### invariants.md template

```markdown
# Invariants & Verification

## Invariants

| What must not break | Check | When |
|---------------------|-------|------|
| <invariant> | `<command>` | each step / end only |

## Acceptance Criteria

| Done when | Check |
|-----------|-------|
| <criterion> | `<command>` |

## Open Questions
<criteria that can't yet be checked — resolve before implementation>
```

### context.md template

```markdown
# <Task Name>

## Goal
<what we're trying to achieve and why>

## Why It Matters
<motivation, constraints, deadline if any>

## Scope
**In:** <what this task changes>
**Out:** <what this task deliberately does not change>

## Background
<constraints, relevant tickets, links, prior decisions>

## Worktree
<repo-root>/.worktrees/<slug>/

## Key Files
<paths to important code, configs, or docs>

## Open Questions
<unresolved questions that don't block planning>

## Decisions
(none yet)
```

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
