---
name: writing-for-humans
description: |
  Apply when producing user-facing prose — READMEs, guides, tutorials, commit messages,
  PR descriptions — to cut LLM tics and improve scannability. Other skills load this as
  a post-processing step after drafting.
---

# Writing for Humans

Rewrite LLM-generated documentation into text humans actually read.

## Scope

User-facing prose: READMEs, guides, tutorials, commit messages, PR descriptions. Not code, config files, or internal specs.

## Integration Pattern

Other skills load this as a post-processing step. The calling skill produces a draft, then a sub-agent rewrites it.

```
Task tool:
  subagent_type: general-purpose
  description: "Rewrite draft for readability"
  prompt: |
    Read: ~/.claude/skills/writing-for-humans/SKILL.md

    Rewrite the following text using the writing-for-humans methodology.
    Return ONLY the rewritten text — no meta-commentary, no explanations.

    ---
    [paste draft here]
```

## Core Principles

Five rules that drive every rewrite decision:

1. **79% scan, 21% read** — Most readers scan. Front-load key information. Use headings, bold, and lists as scan anchors.
2. **7 ± 2 chunks** — Group related items into 5–9 chunks. Split longer lists into categorized sub-lists.
3. **BLUF** — Lead with the conclusion, recommendation, or action. Context follows.
4. **Active voice** — The subject acts. "The server processes requests" not "Requests are processed by the server."
5. **Concrete claims** — Specific numbers, names, and examples. "Reduces build time by 40%" not "Significantly improves performance."

## Quick Diagnostic Checklist

Scan for these issues. Mark the top 3 to fix first.

### Vocabulary
- [ ] Banned words present (see list below)
- [ ] Hedging: "might", "could potentially", "it seems"
- [ ] Corporate buzzwords: "synergy", "paradigm", "best-in-class"
- [ ] Intensifiers: "very", "extremely", "incredibly"

### Structure
- [ ] Context before answer (buried lede)
- [ ] Paragraphs longer than 4 sentences
- [ ] Lists with more than 9 items, not split
- [ ] Nesting deeper than 2 levels
- [ ] Generic headings: "Overview", "Introduction", "Background"

### Readability
- [ ] Sentences longer than 25 words
- [ ] Passive voice in more than 20% of sentences
- [ ] Nominalizations: "make a decision" instead of "decide"
- [ ] Abstract claims without evidence

## Workflow

### Phase 1: Diagnose

Scan with the checklist above. Identify the top 3 issues by frequency and severity. Diagnose only — do not rewrite yet.

### Phase 2: Structural Rewrite

1. **Apply BLUF** — Move the conclusion or action to the first sentence of each section. Cut or relocate the preamble.
2. **Front-load paragraphs** — The first sentence carries the point. Supporting detail follows.
3. **Break long lists** — Split lists over 7 items into categorized sub-lists with descriptive headings.
4. **Flatten nesting** — Two levels maximum. Promote deeply nested content to its own section.
5. **Replace generic headings** — "Overview" → "What this does". "Background" → a specific claim.

### Phase 3: Sentence-Level Rewrite

1. **Delete filler** — Remove words that add no meaning. See [conciseness-techniques.md](references/conciseness-techniques.md) for the full table.
2. **Activate voice** — Convert passive to active. Find the actor and make them the subject.
3. **Replace weak verbs** — "utilize" → "use". "facilitate" → "help". Full table in [conciseness-techniques.md](references/conciseness-techniques.md).
4. **Reverse nominalizations** — "make an improvement" → "improve". "perform an analysis" → "analyze".
5. **Split long sentences** — Break sentences over 25 words at natural clause boundaries.
6. **Cut hedging** — Remove "basically", "essentially", "it's worth noting that". State the fact directly.

### Phase 4: Format

1. **Use markdown** — Bold key terms on first use. Code formatting for technical names.
2. **Add headings** — One heading per ~300 words. Specific and actionable.
3. **Use whitespace** — Blank lines between sections. 2–4 sentences per paragraph.
4. **Prefer tables for comparisons** — Side-by-side data reads faster than prose.

### Phase 5: Validate

- [ ] 30–50% shorter than original (word count)
- [ ] Skim test: headings and bold alone convey the gist
- [ ] No banned words remain
- [ ] 80%+ of sentences use active voice
- [ ] No paragraph exceeds 4 sentences
- [ ] No uncategorized list exceeds 9 items
- [ ] Every heading is specific — not "Overview" or "Details"
- [ ] Flesch-Kincaid grade 8–10 — accessible to a broad technical audience

## Banned Words

Remove or replace every instance:

delve · leverage (→ "use" or "apply") · robust (→ "tested", "validated", "fault-tolerant") · comprehensive (→ "complete" or "full", or cut) · streamline (→ "simplify" or "speed up") · utilize (→ "use") · facilitate (→ "help" or "enable") · moreover · furthermore · nonetheless · paradigm · synergy · optimize (unless discussing actual performance) · empower · foster · holistic · innovative · seamless (→ "smooth" or describe the actual behavior)

For filler phrases and full word replacement tables, load [conciseness-techniques.md](references/conciseness-techniques.md).

## Output Format

Return the rewritten text only — no explanations, no before/after comparisons, no meta-commentary. If the original is already concise and scannable, return it unchanged with no comment.

## Reference Files

| Topic | File | Load when |
|-------|------|-----------|
| LLM anti-patterns | [llm-anti-patterns.md](references/llm-anti-patterns.md) | Diagnosing why text reads like AI output |
| Conciseness techniques | [conciseness-techniques.md](references/conciseness-techniques.md) | Filler phrases, word replacements, active voice mechanics |

Load references only when the diagnostic reveals issues in that area. Most rewrites need only this SKILL.md.
