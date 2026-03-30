---
name: software-design-philosophy
description: Guiding principles for software design decisions. Invoke when writing new code, refactoring existing code, choosing between implementation approaches, adding abstractions or workarounds, encountering friction with existing code, or fixing errors and warnings. Any time you're deciding HOW to respond to a problem — not just WHAT to build — these principles apply. This skill applies to ALL languages and codebases.
---

# Software Design Philosophy

Principles that guide how to think about code, not what syntax to use. These are language-agnostic and apply whenever you're making a design decision.

## When to Consult This Skill

**Proactive** — building or changing code:
- Choosing between two implementation approaches
- Extracting a helper, utility, or abstraction
- Adding a comment that explains *why* code is written a certain way (signal to pause and reconsider)

**Reactive** — responding to problems:
- Fixing an error, warning, or test failure — the choice of *how* to fix it is a design decision
- Encountering friction with existing code (something doesn't fit, a side effect fires incorrectly, an abstraction leaks)
- About to add a workaround, suppression, shim, or compatibility layer

**Planning & debugging** — understanding before acting:
- Debugging a chain of failures — trace to the root cause before deciding on a fix
- Weighing whether to fix locally or address an upstream design issue

## Principles

### 1. Prefer Subtractive Solutions

Research shows humans have a cognitive bias toward addition — when solving problems, subtraction simply doesn't come to mind as readily, even when it's the better answer. In Leidy Klotz's Lego experiment, participants were shown a bridge with one support tower taller than the other. Most added blocks to the shorter tower. The optimal solution was to remove a block from the taller one.

This bias is especially strong in code. When existing code causes friction, the instinct is to add: a wrapper, a transaction, a special-case function, a compatibility shim. Each addition is code that exists only to compensate for a design problem — and it has to be understood, tested, and maintained forever.

**Before adding, ask whether you can subtract.** Split an overloaded function. Remove a responsibility that doesn't belong. Narrow an interface. The best solution often has less code than what you started with.

**The signal that you're adding when you should subtract:** your solution needs a comment explaining *why* it exists. That comment is compensating for a design problem upstream.

Example: A shared `changeset/2` had side-effect callbacks that only applied on update but fired on both insert and update. The side effects crashed on insert because the record had no id yet.

- Additive: Wrap insert + update in a transaction to work around the crash
- Additive: Create a near-duplicate changeset function that skips the callbacks
- Subtractive: Split `changeset/2` into `insert_changeset/1` and `update_changeset/2` — the side effects structurally cannot fire on insert

The subtractive solution had less code than any workaround and left the module better designed than before.

**Ask yourself:**
- "Why can this even happen?" before "How do I work around this?"
- "Is the existing abstraction doing too much?" before "What do I add on top?"
- "Can I solve this by splitting or removing something?" before reaching for new code

**Corollary — earn your abstractions.** The additive bias also shows up as premature extraction. Before creating a helper, wrapper, or utility, ask "why is this needed?" Simple inline code is often clearer than an abstraction with a name to learn. Only extract when there's clear reuse or the abstraction genuinely clarifies. Three similar lines of code is better than a premature abstraction.

### 2. Comments Mean "Why", Not "How"

Follow the *Philosophy of Software Design* approach: comments should explain things that aren't obvious from reading the code — the reasoning, constraints, and design decisions.

**Before adding any comment, ask:** "Does this comment convey information that cannot be determined by reading the code?"

- **Add:** Explains a constraint, business rule, assumption, or *why* a decision was made this way
- **Skip:** Restates what the code already clearly says
- **Skip:** Repeats the name of a function, class, or test group

Good comments explain the forces that shaped the code — why this approach over an alternative, what constraint makes this necessary, what would break if you changed it. Bad comments narrate what the code does, which the reader can already see.

### 3. Consistency Over Personal Preference

When working in an existing codebase, match what's there. Introducing a different style — even a "better" one — creates two patterns where there was one, and every reader now has to understand both.

This applies to naming conventions, error handling patterns, test structure, abstraction levels, and architectural decisions. If the codebase uses pattern A and you prefer pattern B, use pattern A. The cost of inconsistency (cognitive load for every future reader) almost always exceeds the benefit of the "better" pattern.

The exception is when the existing pattern is actively harmful (security issues, correctness bugs, unmaintainable complexity). In that case, refactor broadly rather than introducing a second pattern in one place.

### 4. Simplest Sufficient Return Type

Don't add structure that doesn't carry information. If an atom conveys the meaning, don't wrap it in a tuple.

- ✅ `:ok | :duplicate`
- ❌ `{:ok, :no_duplicate} | {:skip, :duplicate_appointment}`

The tagged tuple adds two names (`:no_duplicate`, `:duplicate_appointment`) that restate what the caller already knows from the tag. The simpler form is easier to match on and harder to get wrong.

This is a corollary of Principle 1 — the extra structure is something you can subtract.

### 5. Find the Golden Mean of Type Specificity

Types and specs should be specific enough to communicate intent but general enough to remain useful. Think Postel's Law: be liberal in what you accept, conservative in what you produce — but don't be so liberal that your types say nothing.

An untyped dictionary as a parameter tells the caller nothing about what a function expects. A rigid struct with every field locks you into implementation details. The golden mean is somewhere between — name the expected keys and their types so callers know what to pass, without over-constraining the internal representation.

- Too loose: `attrs: dict` / `attrs: map` — what keys? what types?
- Too tight: a dedicated struct or class for a bag of attributes passed once
- Right: a type that names the keys and their expected shapes

This also applies to function behavior. Don't hide decisions inside a function that the caller should own. If a behavior is sometimes desired and sometimes not (e.g., setting a timestamp, activating a flag), make it an explicit argument — don't default it internally. Let the caller state their intent; let the function do the work.

Clojure's spec library is a good reference point: describe the shape of data at boundaries without creating rigid types that couple everything together. Specs live at the edges, not in the core.
