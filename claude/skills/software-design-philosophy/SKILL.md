---
name: software-design-philosophy
description: Guiding principles for software design decisions. Load this proactively — whenever writing or refactoring code, reviewing code or a diff/PR (yours or someone else's), choosing between implementation approaches, adding abstractions or workarounds, encountering friction with existing code, or fixing errors, warnings, or test failures. Any time you're deciding HOW to respond to a problem — not just WHAT to build — or judging whether code is the right shape, these principles apply. When in doubt, load it: the cost is low and it catches design mistakes (and softened review feedback) early. This skill applies to ALL languages and codebases.
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
- For diagnosis *method* — isolating causes, simplifying repros, verifying hypotheses — see the `debugging` skill; this skill covers the design decisions a diagnosis surfaces (how to fix, what shape), not how to find the bug.

**Reviewing** — judging code, not just writing it:
- Reviewing a diff, PR, or change — judge the *shape*, not just whether it's correct within the structure as given
- Reviewing your own change before presenting it
- Catching yourself about to call a finding "tidiness"/"minor" or to offer an "option A or B" menu (see Principle 6)

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

This is the keystone principle. Three corollaries follow from it — *earn your abstractions* and *the minimal change carries information* (both below), plus **1a** (promoted to its own numbered subsection because it's referenced by anchor elsewhere and carries a code example). Principles 4 and 6 are also applications of it.

**Corollary — earn your abstractions.** The additive bias also shows up as premature extraction. Before creating a helper, wrapper, or utility, ask "why is this needed?" Simple inline code is often clearer than an abstraction with a name to learn. Only extract when there's clear reuse or the abstraction genuinely clarifies. Three similar lines of code is better than a premature abstraction.

The mirror image is just as real: when a block reappears with only the nouns swapped — same operation, different field/source/label — that is earned reuse, and copying it instead of collapsing it is the additive mistake. When you do collapse it, parameterize over the **values that differ** (pass the extracted list, the lookup source, the label), not over a **discriminator you branch on inside the helper**. A `case kind do …` inside the "shared" function hasn't removed the branch, only relocated it (see 1a) — the values are what vary, so the values are what you pass.

**Corollary — the minimal change carries information; extra is misinformation.** A change should include only what the job demonstrably needs. A diff is read as a *claim about what mattered* — a reviewer, a `git bisect`, and a future debugger all trust that the change *is* the change. Every incidental edit (a drive-by rename, an unrelated reformat, a "while I'm here" tweak, a defensive guard you never proved necessary) is a false signal: it tells the next reader "this was required," when it wasn't, and it buries the load-bearing edit in noise. So narrow the change to what you can show is essential — if you can remove a line and the goal still holds, it was never part of the job. Work that's genuinely worth doing but isn't part of *this* job belongs in its own change.

### 1a. Explicit Branching Is Not Noise

A corollary to Principle 1: resist refactoring explicit branching into indirection just to eliminate a `case` or `if`. Keeping a decision's arms together — in one `case` statement — is almost always clearer than distributing them across function clauses or helpers that must be read in combination to understand the decision.

```elixir
# GOOD: the decision and its outcomes are co-located
case items do
  [item] -> resolve(item) || default
  _      -> default   # zero or multiple: always fall back
end

# LESS GOOD: looks simpler, but hides the branching across two clauses
defp try_resolve([item]), do: resolve(item)
defp try_resolve(_),      do: nil

try_resolve(items) || default
```

The second form appears to eliminate the `case`, but it has only moved the branching — a reader now has to hold two function clauses in mind to understand a single decision. The `case` was not the problem; it was the honest expression of the logic.

**The signal that you've over-refactored:** a helper whose only purpose is to return `nil` for the uninteresting case, so the caller can use `||` to reach a default. That nil is doing the work the `case` arm was already doing explicitly.

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

### 6. Name the Design Smell; Don't Soften It

When reviewing code — yours or someone else's — judge whether the structure is the right *shape*, not just whether the change is correct within the structure as given. The trap is anchoring on what's in front of you ("is this diff correct?") instead of questioning the frame ("is this the right shape?").

Two signals in your own writing mean you've spotted a design problem and are softening it into a style note:

- **Calling something "tidiness," "minor," or "nitpick."** You're usually treating a symptom while ignoring the root cause it points to. Example: flagging a repeated `to_string(value)` conversion as "tidiness to DRY up" — when the real issue is that `value` shouldn't be that type at all if every consumer converts it. The fix isn't to hide the conversion in a helper; it's to subtract the wrong representation (Principle 1).
- **Offering "option A or option B."** You usually already have an opinion on which is better and are offloading the decision to avoid committing. A menu reads as thorough but is weaker review — say which one and why.

When you catch either phrase forming, stop and ask whether you've found a design issue. If so, name it directly and recommend.

This is Principle 1 applied to review: "tidiness" is the additive instinct (hide the symptom) where subtraction (fix the representation) is the better answer.
