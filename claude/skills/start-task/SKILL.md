---
name: start-task
description: Start a new long-running task. Creates a persistent task directory, then runs five pre-implementation stages — gather context, align shared language, build artifacts, construct a plan, review — before any code is written.
---

# Start Task

Creates a persistent task directory and runs five staged preparation phases before
implementation begins. Each stage has a human checkpoint; do not advance without it.

## Setup

1. Derive a short kebab-case slug. If a ticket number appears (e.g. `PLATENG-1234`),
   prefix it: `plateng-1234-auth-refactor`.
2. Create `~/.claude/tasks/active/<slug>/` with:
   - `context.md` — populated from the user's description
   - `status.md` — initialized as shown below
   - `artifacts/` — empty directory for stage outputs
3. Populate `context.md` from what the user provided.
4. Declare the task environment — output this line exactly:

   > **Task environment:** `~/.claude/tasks/active/<slug>/`

Then proceed through the stages in order.

---

## Stage 1 — Gather Context

*Goal: bring in everything known before forming opinions.*

Invoke the `gather-context` skill. It pulls from any Jira tickets, GitHub refs, URLs, or
local code paths mentioned in the task description and writes to `artifacts/context-gathered.md`.

**Checkpoint:** Summarize what was gathered in 2–3 sentences. Ask: "Are there other
sources I should query before we move on?"

---

## Stage 2 — Align Understanding

*Goal: shared language before shared plans.*

Invoke the `align-understanding` skill. It discovers domain terms, applies conceptual
engineering to examine and revise them, structures core design concepts (Jackson-style),
and produces:

- `artifacts/glossary.md` — agreed definitions for every term used in the plan
- `artifacts/concept-map.md` — mermaid diagram of concept relationships

**Do not skip this stage.** Plans built on misaligned vocabulary are wrong before
implementation begins. If Ryan and Claude are using the same word for different things,
the plan will encode that disagreement invisibly.

**Checkpoint:** Write one sentence describing the task using only glossary terms. If it
requires a word not in the glossary, go back and add it. Ask: "Does the glossary cover
everything? Any term that still feels imprecise?"

---

## Stage 3 — Build Artifacts

*Goal: make the context tangible.*

Produce a task brief in `artifacts/task-brief.md`: a 1-page structured summary combining
context, shared vocabulary, and any diagrams. Apply `writing-for-humans` conventions.

```markdown
# Task Brief: <Task Name>

## What We're Building
<one paragraph: the goal, in plain language>

## Why It Matters
<motivation, constraints, deadline if any>

## Key Concepts
<link to glossary or inline the 2-3 most important terms>

## Scope
**In:** <what this task changes>
**Out:** <what this task deliberately does not change>

## Open Questions
<unresolved questions that don't block planning>
```

Optionally, if the domain is complex or spatial, add:
- **System diagram** — key components and their relationships (mermaid)
- **Data flow** — how information moves through the system

Publish the task brief using the Artifact tool so it's available as a visual reference
during the session.

**Checkpoint:** Ask: "Does the brief accurately represent the task? Anything missing or wrong?"

---

## Stage 4 — Construct Plan

*Goal: a sequential breakdown with explicit dependencies.*

Use the Plan agent or reason through the plan inline. Every step must:

- Be discrete and independently verifiable
- Name its dependency (what must be true before this step begins)
- Name its output (the artifact or observable change it produces)

```markdown
## Plan

### Step 1: <name>
**Depends on:** nothing
**Produces:** <artifact or observable>
<description>

### Step 2: <name>
**Depends on:** Step 1
**Produces:** <artifact or observable>
<description>
```

Write to `artifacts/plan.md`. Use only glossary terms when naming steps and describing
what they produce.

**Checkpoint:** Present the plan. Ask: "Does the ordering make sense? Any step that's
vague or could mean multiple things?"

---

## Stage 5 — Review

*Goal: explicit sign-off before any implementation.*

Present `artifacts/plan.md` alongside the task brief. Ask:

1. Does the plan reflect the actual goal?
2. Is any step ordered wrong or missing a dependency?
3. Is any step vague enough that it could mean multiple things in the glossary?

If revision is needed: update `artifacts/plan.md`, re-read it, and repeat this stage.

**Do not proceed until Ryan explicitly signs off.** "Looks good" or "let's go" is
sufficient. If there's hesitation, that's a signal to go back to Stage 4.

After sign-off: update `status.md` to reflect that planning is complete and list the
first implementation step as Next Steps.

---

## Implementation (Stage 6)

Implementation begins in the normal workflow, not inside this skill. The pattern:

1. Take one step from `artifacts/plan.md`
2. Do the work
3. Run `/verify` to confirm the step produced what was promised
4. Pause and align: does the next step still make sense, or did this step reveal
   something that changes the plan?
5. Update `status.md`
6. Move to the next step

Use `/resume-task <slug>` to re-enter the task in a new session.

---

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
Stage 1: Gather Context

## Blockers
(none)
```
