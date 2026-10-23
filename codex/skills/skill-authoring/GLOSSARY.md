# Glossary — Skill Authoring

Domain model for what makes a skill great. Every term is a lever on **Predictability**.

Terms grouped by axis: **Invocation**, **Information Hierarchy**, **Steering**, **Pruning**.

---

## Predictability

The degree to which a skill makes the agent behave the same _way_ on every run — the same process, not the same output. The root virtue every other term serves.

---

## Invocation

### Model-Invoked
A skill that keeps its `description`, so the agent can fire it autonomously and other skills can reach it. Pays **context load** permanently in exchange for discoverability.

### User-Invoked
A skill with `policy.allow_implicit_invocation: false` in `agents/openai.yaml` — excluded from automatic selection but still reachable through explicit `$skill-name` invocation. Zero **context load**, but costs **cognitive load**.

### Description
The skill's machine-readable trigger. Its presence makes a skill model-invoked; deleting it makes the skill user-invoked. The source of a model-invoked skill's **context load**.

### Context Pointer
A reference held in the agent's context naming out-of-context material and encoding the condition for reaching it. Its wording — not its target — decides when and how reliably the agent loads the material.

### Context Load
The cost a model-invoked skill imposes on the context window — its description, always loaded.

### Cognitive Load
The cost a user-invoked skill imposes on the human — what they must remember about which skills exist and when to use them.

### Router Skill
A user-invoked skill that names the other user-invoked skills and when to reach for each. The cure for cognitive load when user-invoked skills multiply.

### Granularity
How finely you divide skills. More model-invoked skills spend context load; more user-invoked skills spend cognitive load. Two cuts: by invocation (split off a model-invoked skill when you have a distinct leading word) and by sequence (split steps when post-completion steps tempt premature completion).

---

## Information Hierarchy

### Information Hierarchy
A skill's content ranked by how immediately the agent needs it: steps (primary) → in-skill reference → disclosed reference → external reference.

### Steps
Ordered actions the agent performs. Every step ends on a **completion criterion**.

### Reference
Material the agent consults on demand — definitions, facts, examples, conditional instructions. The prime candidate for progressive disclosure.

### External Reference
Reference outside the skill system — a plain file any skill can point at. The only shared home two user-invoked skills can use (neither can fire the other).

### Progressive Disclosure
Moving reference down the hierarchy — out of `SKILL.md` and behind a context pointer — so the top stays legible. Inline what every branch needs; disclose what only some branches need.

### Co-location
Keeping a concept's definition, rules, and caveats under one heading so reading one part brings its neighbours. The within-file companion to the information hierarchy.

### Sprawl
_Failure mode._ A skill too long even when every line is live and unique. Costs readability, maintainability, and tokens. Cure: disclose reference, split by branch or sequence.

---

## Steering

### Branch
A distinct way a skill can be invoked — a case with its own path through the skill.

### Leading Word
A compact pretrained concept that anchors a region of behaviour in the fewest tokens by recruiting priors the model already holds (e.g. _falsify_, _tracer bullets_, _red loop_). Repeated as a token, never as a meaning. Serves predictability twice: anchors execution in the body, anchors invocation in the description.

### Completion Criterion
The condition that tells the agent a step is done. Two properties matter: **clarity** (checkable: can the agent tell done from not-done?) resists premature completion; **demand** (exhaustiveness: "every modified model accounted for") drives legwork. Applies to flat reference too — "every rule applied" binds a reference skill just as "step done" binds a sequence.

### Legwork
Work the agent does within a step — reading files, exploring, digging — controlled by the completion criterion's demand. Raised by a strong leading word or an exhaustive completion criterion. Not a step itself; latent in the wording.

### Post-Completion Steps
The steps that follow the current one. Visible, they pull the agent toward premature completion. Hiding them (by splitting the sequence) removes the pull.

### Premature Completion
_Failure mode._ Ending a step before it's done because attention slips to being done. A tug-of-war between visible post-completion steps (pull) and the completion criterion's clarity (resistance). Fix in order: sharpen the criterion first; only split the sequence if the criterion is irreducibly fuzzy and the rush persists.

### Negation
_Failure mode._ Steering by prohibition. "Don't think of an elephant" makes the elephant more available. Cure: state the positive target behaviour. Keep a prohibition only as a hard guardrail you can't phrase positively, and pair it with what to do instead.

---

## Pruning

### Single Source of Truth
Each meaning in exactly one authoritative place. **Duplication** is its violation.

### Duplication
_Failure mode._ The same meaning in more than one place. Costs maintenance and tokens, inflates prominence.

### Relevance
Whether a line still bears on what the skill does. A line loses relevance by going stale or by never bearing on the task.

### Sediment
_Failure mode._ Stale lines that accumulate because adding feels safe and removing feels risky. The default fate of any skill without a pruning discipline.

### No-Op
_Failure mode._ An instruction the model already follows by default — pays load to say nothing. Test: does this line change behaviour versus the default? A leading word too weak to beat the default is a no-op; the fix is a stronger word, not a different technique.
