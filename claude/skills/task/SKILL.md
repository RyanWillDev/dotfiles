---
name: task
description: Start work on a new task or ticket by creating an isolated git worktree, feature branch, and task record; finish a task (remove its worktree, archive its record); or list ongoing tasks. Invoke on /task, when the user says to start/begin/finish/wrap up a ticket, feature, or task, or asks what tasks are in progress/ongoing/active.
hooks:
  UserPromptSubmit:
    - hooks:
        - type: command
          command: |
            jq -n '{hookSpecificOutput:{hookEventName:"UserPromptSubmit",additionalContext:"If this session is working on a task from the task skill, make any record edits before writing any reply text. Update CONTEXT.md, PROGRESS.md, or DECISIONS.md in ~/tasks/<slug>/ only for what this turn settles (decisions, status changes, confirmed facts); open questions go in SCRATCHPAD.md. If nothing needs updating, or no task is in progress, just reply."}}'
---

# Task

Sets up a task directory at `~/tasks/<slug>/` that holds every document pertaining to the task
and, for each git repo the task touches, a worktree of that repo at `~/tasks/<slug>/<repo>/`.
Code and notes sit in one tree, and the record sits beside the worktrees rather than inside them,
so removing a worktree doesn't touch it. This is the durable record for the task, not Claude's memory: any
new session (yours or another) must be able
to pick up the task from these files alone, and a human must be able to audit them without
any tool.

These documents are artifacts: the primary way to capture and share information with the
user, not just an internal log written for a future session. Markdown files and Mermaid diagrams
are the default, but reach for whatever format communicates best — a table, an ASCII sketch,
an exported data file, anything else useful — rather than forcing everything into prose.

Most tasks are coding-adjacent enough to also warrant `software-design-philosophy` (code-shape
decisions) and `solution-design-practice` (the design work before code exists — problem
statements, decision matrices). Consider both when starting a task; skip only when the task is
clearly outside their scope.

The record splits by audience:

- **`CONTEXT.md`, `PROGRESS.md`, `DECISIONS.md`** — the audit trail. Write these plainly —
  run drafts through `writing-for-humans` before saving. Never let raw reasoning, dead
  ends, or working notes leak into them; that goes in `SCRATCHPAD.md` instead.
  - **`CONTEXT.md`** — what the task is: ticket summary, key files, links, constraints, and —
    when the problem isn't already obvious from the ticket — a problem statement (see
    `solution-design-practice`). Read this first to get oriented.
  - **`PROGRESS.md`** — a todo list: what's done, what's current, what's next. Completed items stay, never deleted — it's the record of how the task moved, not just its state.
  - **`DECISIONS.md`** — an append-only decision log: what was decided and why, in the style of a lightweight ADR. Never edit or delete a past entry; if a decision is reversed, add a new entry that says so.
  - **`GLOSSARY.md`** (optional, ad hoc) — not one of the four created at setup. Add it later,
    directly in `~/tasks/<slug>/`, only once the task's vocabulary is actually ambiguous enough
    to need it (see `solution-design-practice`). One definition per term, in one place; no
    fixed template. Fix or drop an entry the moment it stops fitting rather than let it go stale.

  A subtask with real weight of its own gets its own `CONTEXT.md`/`DECISIONS.md` under
  `subtasks/<slug>/` (see Maintaining, below) — so reviewing one piece of the plan doesn't
  require reading the whole task.

  Reach for a Mermaid diagram in `CONTEXT.md` or a `DECISIONS.md` entry any time it'll show
  architecture, flow, or the relationship between files or components more clearly than
  prose would (syntax in Reference) — it renders in most markdown viewers and still reads
  fine as plain text otherwise, no tool required, same as everything else in the record.
- **`SCRATCHPAD.md`** — your working notes, for you. Whatever format is fastest to think
  in — fragments, dense shorthand, half-formed hypotheses, dead ends. No `writing-for-humans`
  pass, no obligation to be tidy or even correct. Don't move things out of it into the other
  three unless they've become a real fact, a real decision, or a real status change.

Invoking this skill registers a `UserPromptSubmit` hook (in frontmatter above) for the rest
of the session. Alongside every user prompt it adds a reminder as context you see: if this
session is working on a task, update `CONTEXT.md`, `PROGRESS.md`, or `DECISIONS.md` in
`~/tasks/<slug>/` for what the turn settles, before writing any reply text. Doing the edits
first keeps the reply the last thing in the turn; a `Stop` hook would reopen the turn after
the reply and leave bookkeeping output below it. The hook doesn't know the slug; you do, from
the `/task` invocation in this conversation. If a session resumes without it, run
`/task <slug>` again.

## Steps

1. **Derive the slug and branch name** from the invocation argument.
   - Ticket-shaped (`[A-Za-z]+-[0-9]+`, e.g. `abc-42`, `ABC-42`): uppercase it for the slug and branch — `ABC-42` — regardless of the case given.
   - Free-text description, no ticket: compress it to a short kebab-case slug, 2–4 words, that still reads as the task — not a full slugified sentence (e.g. "fix the bug where login redirects to the wrong page after SSO" → `fix-login-redirect`).
   - No argument: ask what the task is before continuing.

   Branch name is always `feature/<slug>`.

2. **Locate the repo.** Try `git rev-parse --show-toplevel`.
   - **Inside a git repo** — `<root>` is its output and `<repo>` is its basename. The worktree will be `~/tasks/<slug>/<repo>`.
   - **Not inside a git repo** — if the user named a repo, use its checkout as `<root>`. Otherwise ask which repo the task needs, or whether it needs none. With no repo there's no worktree, branch, or diff to isolate: only the record is created, and nothing is made in the current directory.

3. **Check for a pre-existing task** at `~/tasks/<slug>/` or `~/tasks/archive/<slug>/`. If it's archived, reopen it first: if the shell is inside the archived record, `cd ~/tasks` before the move and `cd ~/tasks/<slug>` after it; `mv ~/tasks/archive/<slug> ~/tasks/<slug>`, add `**Reopened:** <date>` to the `CONTEXT.md` header fields, and add a "Task reopened" entry under Current in `PROGRESS.md`. Then resume it instead of creating anything: for each `Worktree` in `CONTEXT.md` that isn't `none` and is missing, recreate it with the existing-branch form in step 4; then `cd ~/tasks/<slug>`; report the record path (plus branch and worktree, if any) and stop. Never overwrite existing record files.

4. **Set up the record and workspace.** `mkdir -p ~/tasks/<slug>`. Then, in a git repo, create the worktree, branching from current `HEAD`:
   ```
   git -C <root> worktree add -b feature/<slug> ~/tasks/<slug>/<repo>
   ```
   If that fails because `feature/<slug>` already exists (e.g. the worktree was removed earlier but the branch survived), attach the worktree to the existing branch instead:
   ```
   git -C <root> worktree add ~/tasks/<slug>/<repo> feature/<slug>
   ```

5. **Create `CONTEXT.md`, `PROGRESS.md`, `DECISIONS.md`, and `SCRATCHPAD.md`** in `~/tasks/<slug>/` (templates below). Populate `CONTEXT.md` from whatever is known now — ticket ID, the user's own description, nothing invented; set `Location` to `<root>` (or the current directory when there's no repo), mark `Branch`/`Worktree` as `none` when there's no repo, and omit the Problem Statement section unless the task's problem isn't already clear from the ticket. `PROGRESS.md` starts with a single Current entry; `DECISIONS.md` and `SCRATCHPAD.md` start empty — don't invent a first decision or note.

6. **Report** the record path (plus branch and worktree, if any). `cd ~/tasks/<slug>` and work from there for the rest of the session.
   The task directory isn't a git repo, so run git, build, and test commands from inside the worktree
   (`cd <repo> && ...` or `git -C <repo> ...`).

## Completion criterion

`~/tasks/<slug>/` exists with all four of `{CONTEXT,PROGRESS,DECISIONS,SCRATCHPAD}.md`; with a repo, a worktree on `feature/<slug>` (new or reattached) exists at `~/tasks/<slug>/<repo>`; and the user has been told where they are.

## Maintaining the record after setup

This is the task's memory — not the assistant's. Every session working on this task, including this one, keeps it current:

- **CONTEXT.md** — update whenever a new fact worth resuming from surfaces: a file that turned out to matter, a constraint discovered mid-task, a linked ticket. Edit in place; it describes current understanding, not history.
- **PROGRESS.md** — move items between Todo / Current / Done as work actually moves. Never delete a Done entry. When a Todo or Current item turns out to have real steps, break it into subtasks: nested `- [ ]` lines under it, added as soon as the breakdown is known rather than after the fact. Check off each subtask independently as it's done; the parent only moves to Done once every subtask under it is checked. PROGRESS.md stays the one place to see status for all of them — that doesn't change.
- **Subtask docs** — when a subtask accumulates enough of its own context or decisions that burying them in the parent's `CONTEXT.md`/`DECISIONS.md` would make either harder to review, give it `subtasks/<subtask-slug>/CONTEXT.md` and `DECISIONS.md` (same format and rules as the parent's, scoped to just that subtask) and link them from its PROGRESS.md line. Most subtasks don't need this — it's for the ones with real weight, so a person picking up just that piece can read its own docs instead of the whole task's.
- **DECISIONS.md** — append a new entry the moment a real decision gets made (a choice between approaches, a tradeoff accepted, a constraint that shaped the plan) — not for routine steps that only have one reasonable way to do them. For a decision weighty enough to warrant comparing multiple approaches side by side, build the matrix per `solution-design-practice` and fold it into the entry (template below) rather than skipping straight to a conclusion.
- **SCRATCHPAD.md** — write to it freely, any time thinking-out-loud helps: exploring an approach, working through why something broke, listing options before picking one. This is not read for audit; the other three are. If something there turns out to matter for resuming or auditing the task, promote it into `CONTEXT.md`, `PROGRESS.md`, or `DECISIONS.md` — don't leave the audit trail depending on the scratchpad.
- **Another repo** — if the task turns out to need a second repo, add its worktree with step 4's commands as another sibling `~/tasks/<slug>/<repo>/`, and add a `Location`/`Worktree` pair for it to `CONTEXT.md`.
- The record lives in `~/tasks/<slug>/` (moved to `~/tasks/archive/<slug>/` once finished), beside the worktrees rather than inside them, so it never pollutes a branch's diff and survives worktree removal. Open the files directly, no tooling required.

## Finishing a task

On `/task done <slug>`, in order:

1. **Remove each worktree** listed in `CONTEXT.md` (skip any `Worktree` that's `none`). If the shell is inside one, `cd ~/tasks/<slug>` first. Run `git -C <Location> worktree remove <Worktree>` without `--force`. If git refuses (uncommitted changes), report why and stop — the task stays active, nothing is forced. Leave the branch alone.
2. **Close the record**: add `**Finished:** <date>` to the `CONTEXT.md` header fields, and move remaining Current items to Done with a final "Task finished" entry. Unfinished Todo items stay as they are.
3. **Archive the record.** Every worktree must be gone first, because git records each worktree's absolute path and moving a live one breaks the link. If the shell is inside `~/tasks/<slug>/` (the usual case), `cd ~/tasks` first and stay there. Then `mkdir -p ~/tasks/archive && mv ~/tasks/<slug> ~/tasks/archive/<slug>`. Never merge into or overwrite an existing `~/tasks/archive/<slug>/`; if one exists, report it and stop with the record left in `~/tasks/<slug>/`.
4. **Report** that the record is kept at `~/tasks/archive/<slug>/` (`/task <slug>` reopens it) and the branch `feature/<slug>` is not deleted.

## Listing ongoing tasks

`ls ~/tasks/` — one directory per active task, except `archive/`, which holds finished ones. For each active task, read `CONTEXT.md`'s Location and `PROGRESS.md`'s Current entry (and `CONTEXT.md`'s Summary if more detail helps), so the answer is one line per task — slug, Location, Current entry — not a bare list of directory names. List only active tasks unless the user asks about finished ones; then list `~/tasks/archive/` the same way, with each task's `Finished` date.

## Reference

### CONTEXT.md template

```markdown
# Context

**Ticket:** <ID and link, if any>
**Location:** <repo root or directory the work happens in>
**Branch:** feature/<slug> — or `none` with no repo
**Worktree:** ~/tasks/<slug>/<repo> — or `none` with no repo
**Started:** <date>

## Summary
<the task as given — ticket summary or the user's own description>

## Problem Statement
<optional — only when the ticket doesn't already give you one: the unmet objective and the
obstacle, not the symptom (that's Summary) or the remedy. See `solution-design-practice`.>

## Key Files
- <path> — <why it matters>

## Notes
<constraints, related work, anything else needed to resume cold>
```

### PROGRESS.md template

```markdown
# Progress

## Current
- [ ] Task started — not yet planned

## Todo
(none yet)

## Done
(nothing yet)
```

A Todo or Current item broken into subtasks, nested one level under it:

```markdown
## Current
- [ ] Add retry logic to job queue
  - [x] Identify all call sites
  - [ ] Add backoff config
  - [ ] Update tests
```

A subtask with its own docs, linked from its line:

```markdown
## Current
- [ ] Add retry logic to job queue — see [subtasks/retry-logic/](subtasks/retry-logic/CONTEXT.md)
  - [x] Identify all call sites
  - [ ] Add backoff config
  - [ ] Update tests
```

### subtasks/\<slug\>/ (as needed)

Same rules and format as the parent's — `CONTEXT.md` and `DECISIONS.md` only, scoped to
that subtask. Use the same templates as the parent's (this Reference section), just
narrower in scope. No `PROGRESS.md` or `SCRATCHPAD.md` here: status stays in the parent's
`PROGRESS.md`, and scratch thinking stays in the parent's `SCRATCHPAD.md`, so there's still
exactly one place to check either.

### DECISIONS.md template

```markdown
# Decisions

<!-- One entry per decision, oldest first. Never edit a past entry — append a new one if reversed. -->
```

Each entry, once a decision is made:

```markdown
## <date> — <what was being decided>
**Decision:** <what was chosen>
**Reasoning:** <why — the factors that made it the right call>
**Alternatives considered:** <other options and why not, if any>
```

For a decision weighty enough to compare approaches side by side, fold the matrix in under
the entry instead of just listing alternatives (see `solution-design-practice`):

```markdown
## <date> — <what was being decided>
**Decision:** <what was chosen>
**Reasoning:** <why — the factors that made it the right call>
**Tradeoffs accepted:** <what's given up by this choice, even for the winner>

<details>
<summary>Decision matrix</summary>

| Criterion | Approach A | Approach B |
|---|---|---|
| ... | ✅ ... | ⚠️ ... |

</details>
```

### SCRATCHPAD.md template

```markdown
# Scratchpad

<!-- Yours. No format required — write however is fastest to think in. -->
```

### Diagrams

A fenced `mermaid` block, dropped directly into `CONTEXT.md` or a `DECISIONS.md` entry:

````markdown
```mermaid
graph TD
  Client --> API
  API --> DB[(Database)]
```
````
