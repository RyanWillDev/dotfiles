---
name: software-design-philosophy
description: Guiding principles for software design decisions. Load this proactively — whenever you open, read, write, edit, or review a code file in any language. Also load when choosing between implementation approaches, adding abstractions or workarounds, encountering friction with existing code, or fixing errors, warnings, or test failures. Any time you're deciding HOW to respond to a problem — not just WHAT to build — or judging whether code is the right shape, these principles apply. When in doubt, load it: the cost is low and it catches design mistakes (and softened review feedback) early. This skill applies to ALL languages and codebases.
---

# Software Design Philosophy

Principles that guide how to think about code, not what syntax to use. These are language-agnostic and apply whenever you're making a design decision.

## When to Consult This Skill

**Always** — reading or writing code in any language:
- Opening, reading, or exploring a code file
- Writing new code or editing existing code
- Any task where code appears in the context

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

**Writing a comment well:**

- **Name the subject explicitly.** Don't use pronouns or vague references. "retry_budget is also decremented here" is immediately parseable; "also decremented here" leaves the reader guessing what "it" is.
- **Put volatile context in parentheticals.** When a comment references current implementation state that could change, parenthesize it. The invariant — the *why* — should stand on its own; the parenthetical gives orientation without making the comment load-bearing on details that may rot.
- **Clarity is not the same as brevity.** Trimming a comment until the subject is ambiguous is not an improvement. A comment that's slightly longer but unambiguous is better than one that's terse but forces the reader to infer what's being said.

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

### 7. Name the Nothing (Active Nothing)

The nothing in your domain is already there — a real participant that reveals its presence by the absence of code. When you write a nil-check, you aren't guarding against an edge case; you're encountering a concept that doesn't have a name yet. Zero didn't exist for most of human history. Before we named it, there were things we couldn't do. Your domain has zeros — absences that are actually something once named.

A nil-check at a call site is how an unnamed concept announces itself. (Sandi Metz, RailsConf 2015; Bruce Anderson, "Active Nothing".)

**Conditions breed.** One nil-check means there will be more — scattered across every caller, every future caller, every path through the system. The fix: don't check for nothing; give nothing a representation that participates in the same operations as something. Call sites stop branching because both paths behave the same way.

**This is not OOP-specific.** Every paradigm has the same problem and a native form of the fix:

- **OOP (Null Object pattern):** Make "nothing" an object with the same interface as the real thing. `NullDuck` implements `quack`; callers never branch.

  ```ruby
  find_duck || NullDuck.new  # .quack is unconditional — NullDuck owns its behavior
  ```

- **FP (same-type value):** Return a value of the *same type* that participates in the same operations — not a wrapper that requires unwrapping. `Maybe`/`Option` defers the branch to the edge (`or_else`, `unwrap_or`); it doesn't eliminate it.

  When "nothing" should be transparent, return the **identity element** for the operation (`fn x -> x end`, `0`, `[]`). When it has domain-specific behavior, return a concrete value with the right defaults.

  ```elixir
  # Transparent: a discount that changes nothing (identity)
  find_discount(order) || &Function.identity/1

  # Domain-specific: a missing animal with defined behavior
  find_animal(id) || %Animal{sound: "...", name: "Unknown"}
  ```

  The empty list is the canonical case — `map`/`filter`/`reduce` over `[]` produce correct results with no guard; returning `[]` instead of `nil` eliminates every empty-check at call sites.

**When the nil comes from an external API you don't control:** wrap the API in your own adapter — catch the message, make the external call, handle the nil there, and return a domain object. Callers talk to your adapter; they never touch the external API or see a nil. One place owns the condition.

```ruby
# OOP — adapter calls the external API and returns a real domain object
class AnimalService
  def find(id)
    ExternalApi.find_animal(id) || NullAnimal.new
  end
end
# callers: AnimalService.new.find(id).name — never a branch
```

```elixir
# FP — one function owns the external call and the nil case
defmodule AnimalService do
  def find(id) do
    case ExternalApi.find_animal(id) do
      nil    -> missing_animal()
      animal -> animal
    end
  end
end
```

**When to apply it:**

- A nil-check (or `present?`, `exists?`, empty-guard) exists at a call site — even one is the concept announcing itself
- A function returns `nil`/`null`/`None` to mean "no result" and callers branch on it
- A collection can be empty and every consumer has a separate empty-guard
- An external API is untrustworthy and callers scatter guards around every call to it

**The design insight:** the named nothing is not a workaround — it is the concept that was missing. This is Principle 1 applied to the case where what's being checked is absence itself.

### 8. Specialization Is by Definition at Least Two Things

The urge to subclass is a signal, not a solution. When you feel it, you've already found two things: the variant *and* the default — even if the default "looks like nothing." Both are real. The mistake is to name only the variant and hide the default inside the parent class, where it becomes invisible.

Metz's lesson from the House that Jack Built: once you have Random House and Echo House as subclasses, you can't combine them. Inheritance worked for one specialization, then broke at two. The failure was in assuming the thing that varied (order, formatting) belonged *inside* the class rather than *outside* it as an injectable role.

**The move:** isolate what varies → name it → define a role → inject the players.

**OOP:** the role becomes an interface; players are objects injected at construction or call time.

```ruby
# Before: House subclassed for ordering; can't compose ordering + formatting
class RandomHouse < House
  def data = super.shuffle
end

# After: ordering is a named role, injected — composes freely
House.new(order: RandomOrder.new, format: EchoFormat.new).recite
```

**FP:** the role is a function parameter; players are functions passed as arguments. Branching on a variant *inside* a function is the FP equivalent of subclassing — the fix is the same.

```elixir
# Before: dispatch on a variant — ordering hidden inside the function
def recite(data, :random),   do: data |> Enum.shuffle() |> build_lines()
def recite(data, :in_order), do: data |> build_lines()
# can't combine :random with :echo — same problem as inheritance

# After: order is a named parameter (a function); players are just functions
def recite(data, order \\ &Function.identity/1, format \\ &identity_format/1) do
  data |> order.() |> format.() |> build_lines()
end

recite(data, &Enum.shuffle/1, &echo/1)  # random + echo — free composition
```

The naming discipline is the same across paradigms: what you name, you can vary independently.

The subclass felt easy because the *name* (Random House) seemed to describe a thing. The name was misleading — what actually varied was *order*, a role that any house could accept. Naming it correctly made the combination obvious and free.

**The signal:** you subclass to specialize one thing and immediately realize you need another subclass for a second thing, and can't combine them. That's the moment to find what varies, name it, and inject it.

**The connection:** Principle 7 (Active Nothing) is a specific case of this. The null object *is* the default specialization — the one that "looks like nothing." Before you name it, you compensate with conditions. After you name it, you inject it like any other player. Both patterns are the same idea: unnamed roles breed conditions; named roles enable composition.
