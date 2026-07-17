---
name: validate-claim
description: Validate a factual claim by dispatching a background agent. The agent searches source code, docs, or the web depending on the claim type. Invoked explicitly by the user or automatically by Claude when asserting something that should be verified. Findings are written to the active task's artifacts/ if a task environment is set for this session; otherwise reported inline.
---

# Validate Claim

Dispatches a background agent to verify a claim. Used explicitly or automatically when Claude makes an assertion worth checking.

## Invocation Modes

**Explicit** (`/validate-claim <claim>`): Present source options first, confirm with the user, then launch.

**Autonomous** (Claude-initiated): Skip the source selection step. Pick the most appropriate strategy based on the claim, note what was chosen, and launch immediately. Don't interrupt the current work.

## Explicit Mode: Source Selection

Present options based on what the claim is about. Not all options apply to every claim — surface the ones that do:

- **Dependency source** — read the library or framework source code directly
- **Official docs** — fetch the relevant documentation page
- **Web search** — broader search for behavior, changelogs, known issues
- **Local codebase** — check how this is actually used or implemented here

Ask which to use (or which to try first if multiple apply). Then launch.

## Agent Prompt

Pass the agent:

1. The claim verbatim
2. The chosen strategy and any specific sources (file paths, URLs, search terms)
3. Instructions to approach skeptically — the goal is to find out if the claim is wrong, not to confirm it

The agent should return:
- **Verdict**: Confirmed / Refuted / Partial / Inconclusive
- **Evidence**: what was found and where
- **Confidence**: high / medium / low, with a reason if low

## Output Destination

Check whether a task environment was declared in this session (look for a `**Task environment:**` line in the conversation context).

- **Task environment present**: write findings to `<task-path>/artifacts/validated-claims.md`, appending if the file exists.
- **No task environment**: report findings inline.

## Artifact Format

```markdown
## <short claim summary> — <verdict>

**Claim:** <full claim>
**Strategy:** <what was checked>
**Evidence:** <what was found, with sources>
**Confidence:** <high/medium/low> — <reason if not high>
**Date:** <date checked>
```
