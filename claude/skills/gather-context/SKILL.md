---
name: gather-context
description: |
  Pulls task context from external and local sources — Jira tickets, GitHub refs, URLs,
  local code — and synthesizes it into a structured artifact. Used by start-task during
  Stage 1 and can be invoked standalone when new information surfaces mid-task.
---

# Gather Context

Assembles task context from multiple sources before any design or planning begins.

## When to Use

- **Stage 1 of start-task** — always
- **Mid-task** — when a related PR merges, a new ticket appears, or an external doc is referenced

## Source Detection

Scan the task description and context.md for known signals. Match each to a source type and handler:

| Signal | Source type | Handler |
|--------|-------------|---------|
| Ticket ID (`PLATENG-1234`, `ENG-42`) | Jira | `jira-acli` skill |
| GitHub URL, `#123`, or `org/repo` ref | GitHub | `gh-cli` skill |
| `http://` or `https://` URL | Web page | Fetch directly |
| File path or local repo name | Local code | Read / grep |
| No explicit source | Unknown | Present options, ask |

Query all detected sources. If none are detected, present the options above and ask which apply.

## Per-Source Extraction

### Jira

Invoke the `jira-acli` skill. Extract:

- Ticket summary, type, status, and assignee
- Full description and acceptance criteria
- Comments that contain decisions or constraints
- Linked tickets: blockers, related, sub-tasks

### GitHub

Invoke the `gh-cli` skill. Extract based on ref type:

**PR:** title, description, changed files (list), review comments with decisions, CI status
**Issue:** description, labels, comments with decisions
**Repo:** README summary, key directory structure if the task is architectural

### Web page

Fetch the URL. Extract the section relevant to the task — not the entire page. Note the URL and date.

### Local code

Read or grep the relevant files. Focus on:

- Interface definitions (function signatures, types, module APIs)
- Existing tests (what behavior is already proven)
- Recent git log for files in scope: `git log --oneline -10 <path>`
- Any comments that explain non-obvious constraints

## Output

Write to `<task-path>/artifacts/context-gathered.md`. Append if the file exists — do not overwrite prior context.

```markdown
# Gathered Context

## Sources Queried

| Source | Type | Date |
|--------|------|------|
| PLATENG-1234 | Jira | YYYY-MM-DD |
| github.com/org/repo/pull/42 | GitHub PR | YYYY-MM-DD |

---

## <Source 1 type>: <ref> — <summary>

<Extracted key information, using the source's own terminology>

**Decisions recorded:**
- <decision with context>

**Constraints:**
- <constraint with source>

---

## <Source 2 type>: ...

---

## Open Questions Surfaced

Questions raised by the source material that need resolution:

- <question>
```

## After Writing

Tell the user:
1. What was gathered (sources and what each contributed)
2. What was skipped (and why — returned nothing useful, access denied, etc.)
3. Any open questions the source material raised

Do not interpret or form opinions at this stage. Report what was found.
