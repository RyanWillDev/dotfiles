---
name: solution-design-practice
description: "Use for solution design before code exists: clarify a symptom, complaint, or feature request; state the actual problem; compare viable directions; and choose an approach. Not for code-shape decisions, root-cause debugging, or conversation style."
---

# Solution Design Practice

The practice of going from "something should be different" to a chosen, stated direction — what's the actual problem, what are the real candidate directions, and how you choose one without just going with the first idea that came to mind. (Code shape once you're writing it is `software-design-philosophy`'s job; root-causing a failure is `debugging`'s.)

Adapted from Rich Hickey's "Design, Composition, and Performance" talk on design-in-practice, reshaped for markdown artifacts and the `task` workflow rather than live spreadsheets.

The work happens by editing a document, not by narrating it in chat — see Artifacts.

## Phases

Not a checklist to complete in order — a map of where to look when you're unsure what to do next. Progress isn't monotonic: you'll backtrack. When you do, say so ("we thought X, then found Y, so we're back to direction") instead of quietly revising history.

### 1. Describe

Write down what's actually being observed — symptoms, complaints, requests — without yet naming the cause or the fix. "The dashboard takes 8 seconds to load," not "the cache is misconfigured." A stated cause from someone else ("I think the problem is...") is itself just another symptom to record, not a fact to accept yet.

Output: a situation summary, written into the file per Artifacts below.

### 2. Diagnose → Problem Statement

Cross from symptom to cause. Two distinct cases:

- **A bug or failure.** This is `debugging`'s job — hypothesis, isolate, simplify. Don't duplicate that discipline here; diagnose the bug there, then bring the resulting cause back here to state as a problem.
- **A feature ask.** Never itself a problem statement. "We don't have X" is not a problem — dig for the actual intention (what does the requester wish were true?) and the obstacle in the way. Nobody asked for a touchscreen; "make it easy to adjust the radio while driving" is the real ask, and a touchscreen may not even answer it.

Once you have a cause, state it succinctly as a **problem statement** — see Artifacts below.

### 3. Direction

Two things, in this order:

- **Use cases first, "how" second.** Capture what the stakeholder wishes were true — intentions, not implementation. "I want the radio louder," not "add a volume knob." Leave the "how" column blank until a direction is chosen; filling it in early smuggles a decision into what should still be an open question. "Stakeholder" here isn't limited to end users — it's whoever's intention the decision serves, including another team, an on-call engineer, or the system's own operators.
- **Decision matrix.** Generate at least two real candidate directions and choose between them with the matrix — see Artifacts below. If you can't name what the second candidate would have looked like, you haven't designed yet, you've transcribed your first instinct.

### 4. Implementation Decisions

Same tool, smaller scope: once a direction is chosen, use lighter matrices (a few minutes, not a project) for decisions like API shape or data model. Go back and fill in the "how" column on the use cases from Phase 3 now that there's a real answer.

### 5. Decide / Scope

Not a phase — an option available at every point above. "No approach covers more than 80% of this," "there's no time for the automated version," "this is out of scope for now" are all real decisions. Make them explicitly and say so, rather than letting scope silently shrink.

## Artifacts

Every artifact below is a file — see Where Artifacts Live for where it lives, with or without a task. Draft it by editing that file directly, never as chat prose offered up for a look first. Report *what changed* ("added a deployment-consistency row to the matrix — see DESIGN.md"), not the artifact's content re-typed into the conversation. Catching yourself composing a problem statement or matrix as a chat message is the signal to stop and write it to the file instead.

### Problem Statement

Names the unmet objective and the obstacle — nothing else. Contains neither the symptom (already captured in the situation description) nor the remedy (that's what direction and implementation decide). If reading the problem statement already tells you what you're going to build, the solution leaked in — strip it back out.

- Bad: "We should add a caching layer because the dashboard is slow." (remedy, not problem)
- Bad: "The dashboard takes 8 seconds to load." (symptom — belongs in the situation description)
- Good: "Users lose their place in what they were checking before the dashboard finishes loading."

A feature request is never itself a problem statement — see Phase 2.

### Decision Matrix

A markdown table: rows are criteria, columns are candidate approaches, cells state how each approach fares against each criterion.

**Rules:**

- **Always include at least two approaches.** Include the current/status-quo approach as a column only when modifying an existing system — for a greenfield decision, skip it; every column is a real candidate.
- **Criteria are rows**, chosen for being *salient* (stands out) and *relevant* (matters to this decision) — never an exhaustive checklist. Add a row the moment it becomes useful; reorder so the most distinguishing criteria sit at the top.
- **Criteria are noun phrases** ("Event durability," "Ease of configuration"), never questions — so an actual open question you're still tracking doesn't get lost among them.
- **Cells get a symbol plus real text:** ✅ (handles it well) / ⚠️ (works, with a real tradeoff) / ❌ (blocking or absent). State *how* an approach does something, not just *that* it does — "yes" and "no" tell a reader nothing they can compare. Never a bare link — a citation can supplement the sentence, not replace it.
- **Watch for these anti-patterns:**
  - *All-green column* — nothing is free of tradeoffs; an all-green column means you're rationalizing. Find the downside.
  - *Undistinguished columns* — if two approaches look identical across every row, you're missing the criterion that actually separates them. Find it before concluding they're equivalent.
  - *Shopping instead of synthesizing* — the exercise isn't picking from a fixed list. A good matrix session often produces a new hybrid approach as a column that didn't exist when you started.

**Write-up order:** decision and reasoning first, matrix after. The reasoning is a summary written *after* the decision is made — distilled from the matrix, not a re-derivation of it — so a future reader gets "what and why" without re-evaluating every row. The matrix stays underneath as the audit trail, folded out of the way:

```markdown
## 2026-03-14 — Caching approach for the dashboard read path
**Decision:** In-process LRU cache
**Reasoning:** Faster to ship than a shared cache, and the read pattern is per-node anyway —
cross-node consistency was never a real requirement.
**Tradeoffs accepted:** cache is cold on every deploy; nodes can briefly disagree.

<details>
<summary>Decision matrix</summary>

| Criterion | Current (no cache) | In-process LRU | Shared cache (Redis) |
|---|---|---|---|
| Warm-start cost | ✅ none | ⚠️ cold per deploy, per node | ✅ shared, survives deploys |
| Operational surface | ✅ nothing to run | ✅ nothing to run | ❌ new service to operate |
| Cross-node consistency | ✅ n/a, no cache | ⚠️ nodes can disagree briefly | ✅ single source |

</details>
```

### Glossary

Only start one when a project introduces enough shared vocabulary that people would otherwise mean different things by the same word — not every task needs one. Once it exists: one definition per term, in one place; use the term consistently everywhere after; the moment a definition turns out wrong or the term stops fitting, fix it or drop it — a stale glossary actively misleads, which is worse than having none.

Established during design, when new vocabulary starts appearing — maintained for the life of the project, not just up front.

## Reflective Inquiry

Two axes to check whether you're actually progressing or just spinning, usable at any point in the process:

- **Understanding:** What do you know? What do you need to know?
- **Action:** Where are you going? What are you doing?

Run this before writing a `PROGRESS.md` update. If you can't answer "what do you need to know" or "where are you going," there's no real next step yet — just busywork.

## Where Artifacts Live

When a `.task/` directory exists (see the `task` skill), these artifacts have a home:

- **Situation** → `CONTEXT.md`'s Summary
- **Problem statement** → `CONTEXT.md`'s Problem Statement subsection — filled in only when the ticket doesn't already hand you a clear one
- **Decision matrix + decision** → a `DECISIONS.md` entry, matrix folded in a `<details>` block per the format above
- **Reflective inquiry** → the check to run before touching `PROGRESS.md`
- **Glossary** → an optional `GLOSSARY.md`, only for tasks with real shared vocabulary at stake

Outside a task directory, the same discipline still needs a fixed home: create `DESIGN.md` in the current directory the moment Phase 1 starts, and give each artifact its own heading there — Situation, Problem Statement, Decision Matrix, Glossary if one's warranted — appended to as the design moves through phases.
