---
name: debugging
description: Discipline for diagnosing bugs and failures — root-cause analysis, hypothesis isolation, problem simplification, and disciplined use of intuition. Invoke when debugging or diagnosing ANY error, warning, or unexpected behavior (compiler / type-checker / linter errors, test failures, runtime exceptions, "why does this happen?"), when explaining the cause of a bug, or when about to assert why something broke or why a fix worked. Core stance — intuitions and assumptions are necessary and valuable; the discipline is to make them explicit, surface load-bearing ones to the human, and test what's load-bearing or cheap before committing to a cause.
---

# Debugging

Discipline for *diagnosis* — figuring out why something is broken and proving you're right — as distinct from *design* (what shape the fix should take; see the `software-design-philosophy` skill). A good fix on a wrong diagnosis is luck, not understanding.

## When to Consult This Skill

- Diagnosing any error, warning, or failure: compiler, type-checker (e.g. dialyzer), linter, test failure, runtime exception.
- Explaining *why* a bug happens, or *why* a change fixed it.
- Any moment you're about to write "the cause is…", "this happens because…", or "confirmed."

## The Core Discipline: Make Assumptions Visible and Accountable

Intuition, heuristics, and assumptions are *essential* to debugging — they generate hypotheses, decide what to look at first, and let you skip the implausible. Good debuggers lean on them constantly and are often right. The goal is **not** to verify every belief before acting; that's paralysis, and it's the over-rigorous trap.

The failure mode is the *silent, unexamined* assumption — the one you act on without noticing you made it, so when it's wrong it quietly steers the whole investigation off course. A wrong belief that *sounds* rigorous is the hardest kind to catch.

So the discipline is to keep assumptions **visible and accountable**, not to eliminate them:

- **Name it.** When leaning on an intuition or heuristic, say so: "I'm assuming X", "my hunch is Y", "heuristically this looks like Z." A labeled assumption can be challenged; a silent one can't.
- **Flag when it's load-bearing, and raise it to the human.** If the next step depends on the assumption holding — being wrong would send us down the wrong path or cost real work — call that out explicitly to the human. They often have cheap context that confirms or kills it in one reply. (Surface the ones that carry weight or are expensive if wrong; don't spam every micro-assumption.)
- **Test what's load-bearing or cheap.** Verify the consequential ones, and any that take seconds to check (read the spec, eval the expression, print the value). Let low-stakes hunches ride — just keep them labeled.
- **Hold it loosely.** An assumption you've surfaced and are tracking is fine to act on. An assumption you've *forgotten you made* is the liability.

The bar tightens specifically when you're about to **commit to a cause or a fix**: can you point to the line, spec, or observed value that makes it true *and* would look different if it were false? If you can't yet disprove a rival, you have *a candidate*, not the cause.

## Principles

### 1. Isolate one variable before claiming causation
A fix that changes two things and makes the error vanish proves the *bundle* worked — not *which* change mattered, and not *why*. If two edits could each explain the result, change one, observe, then the other. The isolating experiment is the one that earns a causal claim — run it *before* asserting the mechanism, not after someone pushes back. The operational test of a cause (Zeller's experimental definition): remove the suspected cause and the failure must disappear; restore it and the failure must return. If you can't make it come and go on demand, you haven't isolated it.

### 2. Simplify the failing case
Strip the reproduction to the minimum that still fails — smallest input, fewest steps, narrowest state, smallest diff from a working version. Every part you can remove *without* the failure going away was never the cause; what remains is concentrated signal. Simplification is not cleanup you do after understanding the bug — it is *how* you find it, and it often shrinks the search until the cause is obvious. (This is the core of Zeller's delta debugging: mechanically minimize the failing case, and minimize the *difference* between a passing and a failing run.)

### 3. A passing fix is not a confirmed explanation
"The error went away" and "I understand the cause" are different facts. Treating the first as the second is how a wrong mechanism gets locked in. After a green result, ask: does this *distinguish* my explanation from the alternatives, or is it consistent with several?

### 4. Verify against the source, not your memory of it
When a belief is load-bearing — or cheap to check — go to the actual definition rather than trusting recall: stdlib specs, type definitions, library behavior, framework lifecycles. "I'm fairly sure `f` is specced as…" is a hypothesis. Open the file / print the spec / eval it. Memory is where you *generate* hypotheses, not where you confirm the ones that matter.

### 5. Separate the symptom's locus from its cause — the defect / infection / failure chain
A *failure* is what you observe. It was caused by an *infection* — erroneous program state — that propagated from a *defect*, the actual faulty code (Zeller's vocabulary). Where the failure surfaces is rarely where the defect lives; the infection may have travelled far first (a cascade — a `no_return`, a null that propagated, an exception rethrown). Identifying the locus ("this branch collapsed") is progress, but bolting a guessed cause onto a correct locus produces a confident wrong answer. Trace the chain *backward* — failure → infection → defect — until you reach the thing you can change to make the symptom provably disappear (Principle 1).

### 6. Heed disconfirming evidence you already have
If something you observed earlier contradicts the explanation you're now forming, stop. Don't talk past your own data. The earlier observation is evidence; the new theory is a hypothesis. The hypothesis loses.

### 7. Surface load-bearing assumptions to the human — don't go silent
Debugging with a human is a collaboration. When your next move rests on an assumption that would be costly to get wrong, say it *before* acting on it: "I'm proceeding as if X — flag if that's off." The human frequently holds context — recent changes, environment quirks, original intent — that confirms or kills the assumption far cheaper than an experiment would. Going silent and acting on a private hunch forfeits that, and is how a wrong turn goes unnoticed until it's expensive. This is not a license to offload every decision: name the assumption, state your default, and proceed unless they redirect.

### 8. Calibrate your language to your evidence
Say "I think" / "likely" / "one candidate is" for unverified claims. Reserve "confirmed" / "the cause is" for things you have isolated and proven. Dressing a guess in the vocabulary of rigor (citing principles, naming mechanisms) is worse than plainly flagging uncertainty — it disguises the very thing a reviewer needs to catch.

### 9. See it fail first — prove your check can't pass vacuously
A verification means something only if it could have come out the other way. Borrow the test-writer's move — flipping `assert`↔`refute` to catch a test that would pass without exercising anything — and apply it to every debugging check:
- **Before fixing:** reproduce the bug and *watch it fail*. A repro you've never actually seen fail may not exercise the bug at all — then you "fix" something unrelated, see green, and declare victory.
- **After fixing:** confirm the check goes red *without* your change — back the fix out, or flip the asserted condition, and watch the failure return (Principle 1's counterfactual, run as a control). A check that's green both with and without your change is measuring nothing.

Green is evidence only when red was reachable.

### 10. Ship the minimal change you've proven necessary
The narrowing has a payload: the smallest change that makes the failure provably disappear. Ship that and nothing more. The defensive guards, debug logging, and "while I'm here" edits accumulated while hunting — back them out unless you can show each is load-bearing. This is the cause-isolation discipline (Principle 1) applied to the fix, and it is the point of all the narrowing: anything extra is unverified, and an unverified extra in the diff misinforms the next reader about what actually mattered. (General principle: see the `software-design-philosophy` skill — subtractive solutions, and extra change as misinformation.)

## Worked Example

A dialyzer cascade reported `pattern_match` (a `{:ok, _}` clause "can never match") and `unused_fun` in a controller.

- **Guess presented as fact (wrong):** the `get_in(started, [Access.key(:metadata), …])` call, with `started` possibly `nil`, made the function `no_return`. Cited the style guide; ran a fix that reverted `get_in` *and* added a type field; saw dialyzer pass; called it "confirmed."
- **What that skipped:** the fix changed two things (Principle 1), so passing proved nothing about the mechanism (Principle 3). The spec of `get_in` was never read — it's `get_in(Access.t(), …) :: term()` and `Access.t()` includes `any()`, so `nil` is fine (Principle 4). An earlier turn had *already* shown `get_in(nil, …) => nil` empirically — disconfirming evidence that got ignored (Principle 6).
- **Actual cause, once isolated:** the `@spec` returned a *closed* map type missing the `workflow_id` key the function now produced. Declared and actual maps were disjoint, so the `{:ok, …}` branch intersected to `none()` and the success type collapsed to `{:error, :not_found}` — which is *why* the caller's `{:ok, _}` couldn't match (Principle 5). Restoring `get_in` and adding only the missing key, then re-running, confirmed it.

The locus was right from the start; the cause was a guess. Isolating the variable — restore `get_in`, change only the type — is what turned a guess into knowledge.

## Theoretical Grounding

This discipline is the practitioner core of Andreas Zeller, *Why Programs Fail: A Guide to Systematic Debugging* (Morgan Kaufmann; 1st ed. 2005, 2nd ed. 2009). Three of its ideas anchor the principles above:

- **The defect → infection → failure chain.** A defect (faulty code) causes an infection (erroneous state) that propagates into an observable failure. Debugging is tracing that chain backward (Principle 5).
- **Cause defined experimentally.** Something is a cause only if removing it makes the effect disappear — established by experiment, not assertion (Principle 1).
- **Simplification as a search method.** Reduce the failing input and the passing/failing difference to the minimum — the basis of delta debugging (Principle 2).

Zeller frames the whole process as the scientific method (explicit hypothesis → prediction → experiment → observation, iterated) and summarizes it as **TRAFFIC**: Track, Reproduce, Automate (and simplify the test case), Find origins, Focus, Isolate, Correct. Reproduce first; observe actual state rather than reasoning about it.

## Growing This Skill

Keep it narrow: diagnosis discipline only. As recurring debugging practices emerge (minimal reproduction, bisecting a regression, making an intermittent failure deterministic, reading the actual error text before theorizing), add them here or split into a `topics/` directory with progressive disclosure, mirroring the `elixir` skill's `style/` layout.
