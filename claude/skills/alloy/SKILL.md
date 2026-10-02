---
name: alloy
description: Mental model and discipline for working with Alloy 6 formal models. Load when reading, writing, or reviewing .als files, designing model extensions, debugging unexpected sat/unsat results, or running the CLI to collaborate on a concept model with the user. Covers the declarative mental shift, temporal modeling, validation discipline (Pattern 1/2, preservation checks), CLI-driven counterexample collaboration, and the recurring traps that bite regardless of experience level.
---

# Alloy

Discipline for thinking in Alloy — a relational, declarative logic with a finite-model finder. The hardest part of Alloy is not syntax; it is the mental shift from *programs that run* to *worlds that exist*. Every other trap flows from incomplete commitment to that shift.

## The Core Mental Shift

In an imperative language you write a sequence of steps and ask: "what does this produce?" In Alloy you write a set of constraints and ask: "does a world exist where all of these are true simultaneously?" There is no execution order. There is no null. There is no loop. There is just a solver exploring every configuration within scope until it finds one that satisfies the constraints — or proves none exists.

Four reframings that must stick before anything else makes sense:

| Imperative instinct | Alloy equivalent |
|---|---|
| "Run this and see what happens" | "Does a world like this exist? (`run`)" |
| "Assert this is always true" | "Is there any world where it's false? (`check`)" |
| "This function has a precondition" | "This predicate is a guard on an action" |
| "Null-check before using x" | "Empty set — set operations are total; subtracting ∅ is a no-op" |

**The solver is your oracle.** `run P` being sat means "I found a world where P holds." `check A` returning no counterexample means "within this scope, I couldn't find a world where A fails." Neither is a proof about unlimited-size worlds — but both are precise, machine-checked claims about the scope you specified.

## Building Blocks

### Sigs and Fields

**`extends` vs `in`:** `extends` creates a subtype — atoms of the child sig are distinct from atoms of other children, and subtypes are disjoint by default. `in` creates a *subset sig* — atoms that may or may not be members based on constraints, not on what they fundamentally are. Use `in` for properties that vary (`var sig Active in Thing {}`); use `extends` for distinct structural kinds with different fields.

**Multiplicity keywords:** `one` (exactly 1), `lone` (0 or 1), `some` (≥1), `set` (any). These constrain the cardinality of a field relation. `lone Item` means the field has at most one element — which includes zero.

**`disj` on a field:** across all atoms of the containing sig, no two share a value for that field. It's a pairwise disjointness constraint, active before any facts are written.

### Facts, Predicates, and the Difference

**`fact`** — always true in every world the solver considers. The solver can assume it for free. Making something a fact *vacuates* any `check` of that property: if the solver is told P is always true, it won't look for worlds where P fails — that class of worlds is eliminated from consideration.

**`pred`** — a named constraint you opt into. Use for:
- Invariants you want to *verify* rather than assume (so the `check` has teeth)
- Guards on actions
- Shape descriptions for `run`

**Rule of thumb:** definitional/structural constraints (this field is always a subset of that set) → `fact`; properties you want to check or assume at specific call sites → `pred`. When in doubt, use `pred` — the assumption stays visible where it's used, and a `check` built on it is meaningful.

### Relational Join

Navigation in Alloy is relational. `a.b.c` means: start with `a`, follow the `b` relation to get an intermediate set, then follow the `c` relation — unioning all results. This gives you a *set*; it loses per-element cardinality. If you need "each element of `a.b` has exactly one `c`," you need `all x : a.b | one x.c`, not `one a.b.c`.

**Reverse join:** if `r` is a relation from A to B, then `r.b` (given a B atom `b`) navigates backward to find the A atoms that relate to `b` via `r`. You don't need a separate back-pointer field.

## Temporal Modeling

`var` marks a relation that can differ between time steps. Alloy traces are infinite: a finite prefix followed by a loop back to some earlier state (a *lasso*). The operators:

| Operator | Meaning |
|---|---|
| `always P` | P holds at every state in the trace |
| `eventually P` | P holds at some state |
| `after P` | P holds at the *next* state |
| `X'` | X in the next state (used in action effects) |

**Temporal operators bind tighter than boolean connectives.** `eventually A and B and after C` parses as `(eventually A) and B and (after C)`. Always brace multi-part temporal assertions: `eventually { A and B and after C }`.

### The Guard / Effect / Frame Trio

Every action predicate must consciously answer three questions:

1. **Guard** — what states is this action legal from? (Constraints on the *current* state)
2. **Effect** — what does the *next* state look like? (Constraints on primed variables `X'`)
3. **Frame** — what `var` fields *don't* change? (Explicit `X' = X` for everything not touched by the effect)

Missing guard → the action can fire from illegal states. Missing frame → unmentioned `var` fields can spontaneously take any value the solver finds convenient. Every time a new `var` field is added, update `stutter` (the do-nothing action) to pin it.

### Single Assignment per Primed Variable

A primed variable like `S'` is one set — you can assign it only once per case. Writing separate implications over individual elements produces contradictions when their required next-states differ:

```alloy
-- WRONG: each implication demands a different S', solver sees contradiction
all x : group | x in S implies S' = S - x
```

Instead, compute the full target set first and assign once per mutually exclusive case:

```alloy
-- RIGHT
let toChange = group + group.related {
    someCondition implies S' = S - toChange
    not someCondition implies S' = S + toChange
}
```

The cases must be mutually exclusive (only one fires per state) and exhaustive (at least one always fires, otherwise `S'` is unconstrained — a frame trap in disguise).

## The Recurring Traps

These surface in every non-trivial Alloy model. Know them by name.

### Vacuous Truth

**The shape:** `X in Y` is true when `X = none`. `A implies B` is true when `A` is false. A `lone` field inside an `in`-expression is almost always a vacuous-truth trap.

**Where it bites:**
- `s.field in SomeSet` — true when `s.field` has no elements
- `someCondition implies someProperty` — true when `someCondition` never holds (e.g., when the relevant set is empty)
- A constraint that looks like it's checking a property but fires vacuously on every empty case, letting bad states through

**The fix:** to say "this lone field is set *and* has the property," write `some (s.field & SomeSet)` or `some s.field and s.field in SomeSet`. After writing any constraint involving a `lone` field, explicitly ask: "what happens when this field is empty? Does the constraint still say what I meant?"

**Why it's pernicious:** vacuous-truth worlds look consistent to the solver. A guard that's vacuously true accepts states it was meant to reject, and an effect can then produce a genuinely bad post-state. The model appears correct until a preservation check finds the counterexample you didn't write a test for.

### Programming Reflexes Producing Wrong Shapes

**`and` is symmetric, not short-circuit.** In programming, `A && B` short-circuits: B is evaluated only if A is true, so you use it to guard B. In Alloy, `A and B` requires both, unconditionally. To say "B holds only when A holds," write `A implies B`. Writing `some x and P[x]` as a guard means the action is *forbidden* in worlds with no `x` — it doesn't say "check P only when x exists."

**Set operations are total; don't null-guard them.** `S - x` is correct whether `x` is empty or not — `S - ∅ = S`. Writing `some x implies S' = S - x` leaves `S'` unconstrained when the antecedent is false (frame trap). The "skip when empty" intention is a *legality* concern — it belongs in the **guard** (`some x` as a guard clause), not embedded in the effect via `implies`.

**Translation table:**

| Programming intent | Programming idiom | Alloy equivalent |
|---|---|---|
| Guard second clause on first | `A && B` | `A implies B` |
| Both must hold unconditionally | `A && B` | `A and B` |
| Temporal scope over conjunction | n/a | `eventually { A and B }` |
| Skip operation when empty | `if x { S -= x }` | Guard: `some x`; Effect: `S' = S - x` |

### The Name / Body Mismatch

The comment is your understanding; the body is what Alloy enforces. They must agree. Common forms:
- A predicate named "X is consistent" whose body is `X implies X` (a tautology)
- A guard comment saying "not a member of any group" whose body intersects the groups (`&`, always empty) instead of unioning them (`+`) and checking membership
- An `implies` where an `and` was intended, silently stripping the consequent's force in some worlds

After writing any fact or predicate, read the body as if you've never seen the comment. Does it say what the comment says?

### The Lasso-End Match

Alloy traces loop. When `eventually { action[x] and after P }` is sat, the matched state may be a no-op firing at the lasso tail, not a meaningful earlier transition. The solver picks the cheapest witness — a degenerate firing that satisfies the formula without exercising the case you care about.

**Fix:** pin the case by describing the state at the moment the action fires, rather than wrapping everything in `eventually`:

```alloy
-- Pinned: the action must fire as the very first (or only meaningful) step
<preconditions on current state>
action[x]
after <what should be true>
```

Avoid conjoining multiple action predicates in a single `eventually` — each action constrains the post-state, and two actions in the same step contradict each other. Let the trace fact and scope find the preamble; describe only the bug-moment.

### Scope Is Not a Proof

"No counterexample within scope" ≠ "no counterexample exists." Two failure modes:

**The scope is too small for the bug shape.** If structural constraints require at least N atoms of some sig (e.g., `#s.options > 1` means you need ≥2 items per group), running at the default scope of 3 may make the bug world structurally impossible — the check passes not because the model is correct, but because the counterexample can't be constructed. Before trusting a green check, compute the minimum atom count the bad shape requires and verify the scope covers it.

**`for N steps` does not raise sig scope.** Writing `check foo for 12 steps` overrides only the step count; sig scopes silently fall back to the default (usually 3). Always state both dimensions explicitly: `for 4 but 4 Thing, 12 steps`.

## The Validation Discipline

For every action predicate, work through this sequence. None of the steps subsumes the others.

### Pattern 1 — Find the Interesting World

`run` the shape the action is supposed to produce. If unsat: either the guard is too restrictive, the effect doesn't produce what you think, or the world you wanted is structurally unreachable — check scope first, then the guard, then the effect.

Use the Skolem witness to verify the solver found the *intended* witness, not a cheaper degenerate one. If it picked a convenient world that bypasses the real concern (e.g., an entity with no attached children when you meant to test interaction with children), constrain the existential to force a harder witness.

For temporal patterns, pin the case (lasso-end trap above) rather than relying on `eventually`.

### Pattern 2 — Forbid the Bad World

`run` the shape the action should prevent. Expect unsat.

**Consistency-protecting Pattern 2:** the forbidden operation would violate an invariant. Assert the bad post-condition explicitly: `eventually { action and after <bad state> }`. Unsat means the bad state is unreachable under the real guard.

**Rule-only Pattern 2:** the operation is forbidden by design, but firing it wouldn't violate any invariant. No bad post-condition to assert. Just `eventually action` — expect unsat from the guard alone. Don't bolt on a post-condition just to mirror the consistency-protecting form; a spurious post-condition can make the run unsat for unrelated reasons and mask whether the guard is doing its job.

### Positive-Twin Validation

Before trusting a Pattern 2 unsat, copy it and flip only the post-condition to the correct form. If the positive twin is sat: the setup is reachable and the bad post-condition is genuinely forbidden — unsat is meaningful. If the positive twin is also unsat: the setup itself is unreachable — fix the existential bindings or preconditions before trusting the result.

### Mutation Testing the Guard

Deliberately relax or remove the guard clause you believe is doing the work. Pattern 2 should flip to sat. If it stays unsat, either something else is preventing it (investigate what) or the Pattern 2 setup was vacuous from the start.

### Preservation Check

Per-action Pattern 1/2 tests cover only the scenarios you thought to write. The preservation check quantifies over *every* legal initial state and *every* legal trace within scope:

```alloy
check preserveInvariant {
    always myInvariant
} for 4 but 4 Thing, 8 steps
```

Use `always invariant` without a "some action happens" antecedent — stutter (doing nothing) can't introduce inconsistency, so restricting to action-only traces would only weaken the check.

**After any new action: re-run the preservation check.** The check finds starting states and execution paths you didn't think to test. Bugs frequently hide in states that look consistent only because a constraint fires vacuously — the preservation check finds them because it explores configurations you didn't write test cases for.

**Mutation-test the preservation check** at least once: deliberately break an action's effect, confirm you get a counterexample. A green check on broken code means the check isn't exercising the relevant behavior.

## The CLI Is the Collaboration Medium

Running a model isn't a debugging afterthought — it's how you and the human argue about the concept. A design question ("can this state exist?", "does this invariant survive the new action?") gets answered by invoking the analyzer, not by reasoning it out in prose first.

**Invoke directly, headless, no GUI:**

```sh
java --enable-native-access=ALL-UNNAMED -jar "$ALLOY_JAR" exec -o - -t text -c <command> <file.als>
```

`-o -` streams the full trace to stdout — every sig's extent per state, skolem witnesses, the loop point — nothing written to disk. Read that output directly. Don't reach for `alloy.nvim`'s on-disk `.md`/`receipt.json` artifacts when you're the one parsing the result: verified that the CLI's own per-solution markdown renders only the top-level skolemized sig and silently drops base-relation tuples — a counterexample's actual violating relation was present in `-t text`/`-t json` output but absent from the `.md`. Add `-r N` to pull multiple distinct witnesses in one call when triangulating what's structurally common across several counterexamples, rather than generalizing from one.

**Translate, don't report.** "Check X failed" is a verdict, not an argument. Read the printed trace, name the actual atoms and relation tuples the solver constructed, and describe that world in English — that description, not a restatement of the invariant, is what the two of you discuss and refine next. This is Pattern 1/Pattern 2 (above) performed live: every counterexample is a candidate bug in the *model*, not automatically a fact about the *concept* — the conversation is about which one it is.

## The Spec Is for the Implementer

Alloy specs are communication artifacts, not just checker inputs. A clause that's "logically redundant given some other invariant" can still be operationally necessary because the implementer reads the spec to derive what checks their code must perform. Forcing the implementer to re-derive a guard from a chain of invariants is a bug-attractor.

When a guard clause seems redundant in one direction of an action (enabled vs. disabled, add vs. remove), ask: "Would an implementer who reads only this predicate know to check this?" If not, keep the clause and note why in a comment.

## Mentor Mode

The role when working with someone learning Alloy is mentor, not code-writer.

**Don't hand over corrected code unless explicitly asked.** Surface the concept, operator, or pattern to investigate; let the learner write the fix. Ask probing questions when their English description doesn't match what the Alloy actually enforces.

**Watch for the name/body trap on every predicate.** Call it out every time.

**Own mistakes immediately.** The worst mentor error is saving face — it models exactly the wrong epistemic behavior for someone learning to reason precisely.

**The most productive question when a check goes wrong:** "What world does Alloy need to construct for that to fail? What atoms would it need? Can that world exist at your current scope?" Walking through scope requirements catches both vacuous unsat (scope too small) and surprising sat (a world you forgot was possible).

**Recurring traps to name on sight:**
- Vacuous truth — name it, point to the lone/in combination
- `and` where `implies` was meant — name the programming-reflex shape
- Frame condition missing — name it
- Multiple assignments to one primed variable — name it
- Lasso-end match in `eventually` — name it, ask for the pinned version
- Scope too small for the bug shape — compute the minimum atoms together

**When the learner describes a design in English before touching the model:** probe the semantics first. "What should be true when condition X holds but Y hasn't happened yet?" is more valuable than a skeleton predicate — because the answer determines the guard, the effect, and whether a new fact is needed.
