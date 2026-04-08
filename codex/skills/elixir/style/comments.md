# Comments & Documentation
> See also: software-design-philosophy skill, Principle 2 "Comments Mean 'Why', Not 'How'"

Follow the *Philosophy of Software Design* approach: **focus on "why" not "how"**. Comments should explain things that aren't obvious from reading the code—the reasoning, constraints, and design decisions.

## Comment Value Test

Before adding any comment, ask: **"Does this comment convey information that cannot be determined by reading the code?"**

- ✅ Add: Explains a constraint, business rule, assumption, or *why* a decision was made this way
- ❌ Skip: Restates what the code already clearly says
- ❌ Skip: Repeats the name of a describe block, function, or module

## Section Dividers in Tests

- **Do not use banner/divider comments** that duplicate what describe blocks already communicate
  ```elixir
  # BAD: Comment just repeats the describe name — no new information
  # ---------------------------------------------------------------------------
  # prebatch/1
  # ---------------------------------------------------------------------------
  describe "prebatch/1" do

  # GOOD: No comment needed — the describe block is self-documenting
  describe "prebatch/1" do
  ```
- If a comment is needed above a describe block, it should explain *why* the tests are structured that way, a constraint, or a non-obvious assumption — not *what* is being tested (the describe name already says that)

## Comment Placement
- **Place comments inline with the specific thing they explain**, not above a larger block
  ```elixir
  # GOOD: Comment directly on the option it explains
  Task.async_stream(items, &process/1,
    on_timeout: :kill_task,
    # zip_input_on_exit includes the input in :exit tuples so we can log which item failed
    zip_input_on_exit: true
  )

  # BAD: Comment above the whole call leaves reader guessing which part it refers to
  # zip_input_on_exit includes the input in :exit tuples so we can log which item failed
  Task.async_stream(items, &process/1,
    on_timeout: :kill_task,
    zip_input_on_exit: true
  )
  ```

## Inline Comments
- **Add contextual comments** for business logic and important decisions
  - Example: Explaining why batching isn't implemented yet with ticket reference
  - Example: Explaining temporary workarounds with TODO for removal

### Good: Inline Logic with Explanation
```elixir
# Until batching is implemented in PLATENG-1293, we will always send single events at a time.
events: [event]
```

## Error Handling Comments
- **Expand on error handling philosophy** in comments
  - Explain *why* we rescue vs crash
  - Clarify what types of errors are expected
  - Document the failure isolation strategy
  - Example: Multi-line comment explaining per-event resilience vs infrastructure failure handling

## Questioning Abstractions
> See also: software-design-philosophy skill, Principle 1 "Prefer Subtractive Solutions"

- **Validate necessity before adding helpers or abstractions**
  - Ask "why is this needed?" before extracting a helper function
  - Simple inline code is often clearer than an abstraction with a name to learn
  - Only extract when there's clear reuse or the abstraction genuinely clarifies

## Rationale Documentation

When making architectural decisions, document:
1. **What** the code does (inline comments)
2. **Why** we chose this approach (expanded comments for non-obvious decisions)
3. **Future changes** planned (TODO comments with ticket references)
