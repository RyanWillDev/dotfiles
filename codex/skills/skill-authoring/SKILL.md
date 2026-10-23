---
name: skill-authoring
description: "Write, edit, review, or diagnose Codex skills. Use when authoring a new skill, improving an existing one, or investigating why a skill produces inconsistent results."
---

# Skill Authoring

A skill exists to wrangle determinism out of a stochastic system. **Predictability** — the agent taking the same _process_ every run — is the root virtue. Every lever below serves it.

Bold terms are defined in [GLOSSARY.md](GLOSSARY.md).

## Invocation

Two choices trade different costs:

- **Model-invoked**: keep a discriminating `description`; automatic invocation remains enabled by default. This costs context because the description is visible every turn. Front-load the **leading word**, cover each meaningful **branch**, and avoid synonyms that merely restate a trigger.
- **User-invoked**: set `policy.allow_implicit_invocation: false` in `agents/openai.yaml`. The human can still invoke `$skill-name`, but Codex will not load it automatically. This reduces context cost and increases cognitive load; when explicit-only skills multiply, add a router skill.

Choose model invocation only when Codex should reach the skill autonomously. Preserve an existing invocation policy unless the user asks to change it.

## Information hierarchy

Four rungs, ranked by how immediately the agent needs the material:

1. **In-skill steps** — ordered actions in `SKILL.md`. Each ends on a **completion criterion**: checkable (can the agent tell done from not-done?) and exhaustive ("every modified model accounted for", not "produce a change list"). Vague criteria invite **premature completion**.
2. **In-skill reference** — definitions and rules in `SKILL.md`, consulted on demand.
3. **Disclosed reference** — a sibling file (e.g. `GLOSSARY.md`) reached by a **context pointer** in the body. The pointer's wording decides when and how reliably the agent loads it.
4. **External reference** — a file outside the skill system, any skill can point at it.

**Progressive disclosure**: move reference down the ladder so the top stays legible. Inline what every **branch** needs; push behind a pointer what only some branches need. If a pointer fires unreliably on must-have material, sharpen the wording before pulling it back inline.

## Leading words

A **leading word** is a compact pretrained concept that anchors a whole region of behaviour in fewer tokens by recruiting priors the model already holds (e.g. _falsify_, _tracer bullets_, _red loop_). Repeat the token, never the meaning.

Hunt for triads and restatements begging to collapse: "fast, deterministic, low-overhead" → _tight_. You win twice — fewer tokens, sharper hook. A weak leading word (_be thorough_) is a **no-op**; the fix is a stronger word (_relentless_), not a different technique.

## Pruning

**Single source of truth**: each meaning in one place. Test every line with the no-op test — does it change behaviour versus the model's default? If not, delete the sentence. Be aggressive: most prose that fails should go, not be rewritten.

Hunt in order:
- **Duplication** — same meaning in two places
- **Sediment** — stale lines that accumulated because removing felt risky
- **No-ops** — instructions the model already follows by default
- **Sprawl** — length itself, even when every line is live and unique (cure: disclose reference, split by branch)

## Failure modes

Use these to diagnose a skill that isn't working:

- **Premature completion** — agent ends a step before it's done. Fix: sharpen the completion criterion. Only split the sequence if the criterion is irreducibly fuzzy and you still observe the rush.
- **Negation** — "don't do X" makes X more available, not less. Fix: state the positive target behaviour. Keep a prohibition only as a hard guardrail you can't phrase positively.
- **Duplication** — same meaning in two places. Fix: collapse to one source of truth.
- **Sediment** — stale accumulation. Fix: prune on a schedule, not just when adding.
- **No-op** — pays load to say nothing. Fix: delete the sentence.
- **Sprawl** — too long even with live, unique lines. Fix: disclose reference, split by branch.
