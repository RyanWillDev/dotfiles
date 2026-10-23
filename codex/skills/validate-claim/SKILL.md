---
name: validate-claim
description: "Verify a factual claim with an independent sub-agent. Use when asserting library behavior, API contracts, or code behavior without direct evidence, or when the user explicitly asks to validate a claim."
---

# Validate Claim

## Mode

**Explicit** (`/validate-claim <claim>`): Present source options below, confirm choice, then launch.

**Autonomous**: Pick the best strategy, note the choice, launch immediately.

## Source options (explicit mode)

Surface only those that fit the claim:

- **Dependency source** — library or framework source directly
- **Official docs** — the relevant documentation page
- **Web search** — changelogs, known issues, broader behavior
- **Local codebase** — how this is actually used or implemented here

## Agent prompt

Send:

1. The claim verbatim
2. Chosen strategy with specific sources (paths, URLs, search terms)
3. Objective: falsify — treat the claim as a hypothesis to disprove, not confirm

Agent returns:
- **Verdict**: Confirmed / Refuted / Partial / Inconclusive
- **Evidence**: what was found and where
- **Confidence**: high / medium / low, with reason if low

## Output

Check for `**Task environment:**` in conversation context.

- **Present**: append findings to `<task-path>/artifacts/validated-claims.md`
- **Absent**: report inline

### Artifact format

```markdown
## <short claim summary> — <verdict>

**Claim:** <full claim>
**Strategy:** <what was checked>
**Evidence:** <what was found, with sources>
**Confidence:** <high/medium/low> — <reason if not high>
**Date:** <date checked>
```
