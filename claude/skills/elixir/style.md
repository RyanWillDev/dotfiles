# Elixir Style Preferences

This document tracks stylistic preferences for writing Elixir code in this project.

## General Code Style

### Variable Naming
- **Prefer full variable names** over abbreviations
  - ✅ `exception`
  - ❌ `e`

- **Name maps and collections to communicate their key structure**, not just the value type
  - ✅ `patients_by_pims_id` — tells the reader what the map is keyed by
  - ❌ `patients` — tells the reader what the values are, but not how to look things up
  - Applies to any lookup map where the key is non-obvious from the value type alone

### Function Organization
- **Inline simple helper functions** rather than creating separate private functions
  - If a helper is only used once and is simple (1-3 lines), inline it at the call site
  - Example: Instead of `defp log_error(event, reason)`, inline the `Logger.error` call directly

- **Extract complex anonymous functions** into named functions
  - If an anonymous function is substantial (multiple operations, business logic), extract it
  - Named functions are easier to test, read, and reference
  - ✅ `Task.async_stream(items, &process_item(&1, context), ...)`
  - ❌ `Task.async_stream(items, fn item -> ... 20 lines of logic ... end, ...)`

### Variable Assignments
- **Avoid single-use intermediate variables** when the value is immediately consumed by a function
  - ✅ Pipe directly into the consuming function
  - ❌ Assign to variable only to use it once on the next line
  ```elixir
  # GOOD: Direct piping into functions
  items
  |> Task.async_stream(&process/1)
  |> Enum.reduce(%{}, &collect_results/2)

  # BAD: Unnecessary intermediate variable
  stream = Task.async_stream(items, &process/1)
  Enum.reduce(stream, %{}, &collect_results/2)
  ```
  - **Exception**: Always assign before control flow (`case`, `if`, `cond`, `with`) - see "DO NOT pipe into case statements" above
  - **Exception**: Assign when the variable name documents intent or improves readability

### Module Organization
- **Order of declarations:**
  1. `use` statements
  2. `import` statements
  3. `alias` statements
  4. `require` statements (e.g., `require Logger`)
  5. Module attributes
  6. Functions

### Alias Declarations
- **Declare all module aliases explicitly**, even for frequently referenced modules
  - Every module referenced in the file should have a corresponding alias
  - Avoids mixing fully-qualified and aliased references
  - Makes module dependencies immediately visible at the top of the file

- **Alias modules more than 2 levels deep** (aligns with Styler's formatting)
  - ✅ `alias Ecto.Association.NotLoaded` then use `NotLoaded.t()`
  - ❌ `Ecto.Association.NotLoaded.t()` inline
  - Two levels like `Ecto.Changeset` are fine without aliasing

### Pipeline Usage
- **Avoid over-using the pipe operator** - Claude tends to "fetishize pipes"
  - Use pipes for clear data transformations, not just to chain everything
  - Don't create pipelines just because you can

- **Prefer direct function wrapping over single-step pipes**
  - ✅ `NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)`
  - ❌ `NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)`
  - A single pipe doesn't add clarity; direct wrapping is more concise

- **DO NOT pipe into case statements**
  - ✅ Assign to variable, then use case
  - ❌ `results |> case do`

  ```elixir
  # GOOD: Assign then case
  result = compute_something(data)

  case result do
    {:ok, value} -> handle_success(value)
    {:error, reason} -> handle_error(reason)
  end

  # BAD: Piping into case
  compute_something(data)
  |> case do
    {:ok, value} -> handle_success(value)
    {:error, reason} -> handle_error(reason)
  end
  ```

### Map Construction
- **Use `Map.new/2` instead of `Enum.into/3`** when building maps from enumerables
  - ✅ `Map.new(list, fn {k, v} -> {k, v} end)`
  - ❌ `Enum.into(list, %{}, fn {k, v} -> {k, v} end)`
  - `Map.new/2` is more direct and communicates intent clearly

- **Use the capture shorthand for simple key-value map building**
  - ✅ `Map.new(patients, &{&1.pims_code, &1})`
  - ❌ `Map.new(patients, fn p -> {p.pims_code, p} end)`

### Building Unique Collections
- **Use `Enum.reduce` with `MapSet.new()` for single-pass unique collection building** instead of chaining `Enum.map |> Enum.reject |> Enum.uniq`
  - Single pass is more efficient and `MapSet` structurally expresses deduplication intent
  - Nil-handling can be consolidated inside the reduce body
  ```elixir
  # GOOD: Single pass, nil handling and deduplication in one step
  items
  |> Enum.reduce(MapSet.new(), fn item, acc ->
    value = get_in(item, [Access.key(:nested), Access.key(:field)])
    if value, do: MapSet.put(acc, value), else: acc
  end)
  |> MapSet.to_list()

  # BAD: Multiple passes over the collection
  items
  |> Enum.map(& &1.nested)
  |> Enum.reject(&is_nil/1)
  |> Enum.map(& &1.field)
  |> Enum.reject(&is_nil/1)
  |> Enum.uniq()
  ```

### Safe Nested Struct Access
- **Use `get_in` with `Access.key/1` for safe nil-tolerant nested struct access**
  - Short-circuits to `nil` at any level without requiring upstream `Enum.reject(&is_nil/1)`
  - ✅ `get_in(record, [Access.key(:association), Access.key(:field)])`
  - ❌ Chaining `record.association.field` after filtering nils with `Enum.reject`

### Unused Variables
- **Prefix unused variables with underscore** in pattern matches
  - ✅ `case result do _error -> ...` when error isn't used
  - ❌ `case result do error -> ...` when error isn't used
  - Signals to readers (and the compiler) that the variable is intentionally unused

### Conditional Simplification
- **Omit explicit `else: nil`** in if/unless statements (nil is the default)
  - ✅ `if condition, do: value`
  - ❌ `if condition, do: value, else: nil`
  - Reduces noise when nil is the intended fallback

### Behaviour Implementations
- **Use `@impl BehaviourModule` instead of `@impl true`** when implementing a behaviour callback
  - Makes it explicit which behaviour the function satisfies — useful when a module implements multiple behaviours
  - ✅ `@impl MyApp.SomeBehaviour`
  - ❌ `@impl true`

### Function Definition Format
- **Only use shorthand `def/defp func, do:` syntax when it fits on a single line**
  - If the formatter would wrap it to multiple lines, use `do`/`end` blocks instead
  - ✅ `defp get_label(nil), do: nil` - fits on one line
  - ❌ `defp format_error_message(%{input: input}, field) when input in [nil, ""], do: "#{field} is required"` - too long
  - ✅ Use multi-line format:
    ```elixir
    defp format_error_message(%{input: input}, field) when input in [nil, ""] do
      "#{field} is required"
    end
    ```

## Metrics & Observability

### Metric Naming
- **Use tagged metrics** with status/result instead of separate metric names per outcome
  - ✅ `emit_metric("webhook.event.processing", %{status: :error})`
  - ✅ `emit_metric("webhook.job.validation", %{partner: id, status: :success})`
  - ❌ `emit_metric("webhook.event.processing_error")`
  - ❌ `emit_metric("webhook.job.validation_error")`

### Logging
- **Inline simple logging calls** rather than creating helper functions
  - ✅ Direct `Logger.error("message", metadata)` at call site
  - ❌ `defp log_error(event, reason)` wrapper for simple cases

## Comments & Documentation
> See also: software-design-philosophy skill, Principle 2 "Comments Mean 'Why', Not 'How'"

Follow the *Philosophy of Software Design* approach: **focus on "why" not "how"**. Comments should explain things that aren't obvious from reading the code—the reasoning, constraints, and design decisions.

### Comment Value Test

Before adding any comment, ask: **"Does this comment convey information that cannot be determined by reading the code?"**

- ✅ Add: Explains a constraint, business rule, assumption, or *why* a decision was made this way
- ❌ Skip: Restates what the code already clearly says
- ❌ Skip: Repeats the name of a describe block, function, or module

### Section Dividers in Tests

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

### Comment Placement
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

### Inline Comments
- **Add contextual comments** for business logic and important decisions
  - Example: Explaining why batching isn't implemented yet with ticket reference
  - Example: Explaining temporary workarounds with TODO for removal

### Error Handling Comments
- **Expand on error handling philosophy** in comments
  - Explain *why* we rescue vs crash
  - Clarify what types of errors are expected
  - Document the failure isolation strategy
  - Example: Multi-line comment explaining per-event resilience vs infrastructure failure handling

### Questioning Abstractions
> See also: software-design-philosophy skill, Principle 1 "Prefer Subtractive Solutions"

- **Validate necessity before adding helpers or abstractions**
  - Ask "why is this needed?" before extracting a helper function
  - Simple inline code is often clearer than an abstraction with a name to learn
  - Only extract when there's clear reuse or the abstraction genuinely clarifies

## Specific Patterns

### Metric Emission
- **Simple signature without defaults**
  ```elixir
  defp emit_metric(metric_name, tags) do
    Metrics.increment(metric_name, 1, tags)
  end
  ```

### Ecto Schemas
- **Prefer embedded schemas when the value is a known and consistent type**
  - ✅ `embeds_many :delivery_attempts, DeliveryAttempt` when structure is well-defined
  - `{:array, :map}` is fine for truly dynamic/unknown structures
  - Embedded schemas provide type safety, changesets, and clear documentation

### Dialyzer & Type Specs

- **Never suppress dialyzer warnings without first tracing to the root cause.** Dialyzer errors cascade — a single type mismatch can produce `no_return`, which propagates `pattern_match` warnings in callers. Always find the originating error before considering suppression.

- **Use `%__MODULE__{}` instead of `t()` for changeset function specs.** The `@type t` on Ecto schemas describes a fully-loaded record (non-nil id, populated fields). A freshly built `%Schema{}` has nil fields and won't match `t()`. Changeset functions accept bare structs, so the spec should reflect that:
  ```elixir
  # BAD: %Schema{} has id: nil which doesn't satisfy t()
  # Dialyzer flags the call as contract-breaking → no_return cascade
  @spec changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()

  # GOOD: Accepts any field values including nil
  @spec changeset(%__MODULE__{} | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  ```

- **Remove default arguments when the spec requires specific keys.** A default like `def create(attrs \\ %{})` generates a zero-arity function. If the spec requires keys in the map, dialyzer will flag `create/0` since `%{}` can't satisfy the spec. Remove the default if callers always pass arguments.

## Testing Patterns

### Test File Organization
- **One test file per schema** - don't combine multiple schema tests in one file
  - ✅ `location_partner_webhook_event_test.exs` and `location_partner_webhook_event_batch_test.exs`
  - ❌ Both schemas tested in a single file

- **Use concise describe block names** - module name provides context
  - ✅ `describe "changeset"` in `LocationPartnerWebhookEventBatchTest`
  - ❌ `describe "LocationPartnerWebhookEventBatch changeset"` - redundant with module name

### Test Data Setup
- **Create all data variations in setup**, avoid mutating setup data in individual tests
  - ✅ Create both enabled and disabled partners in setup
  - ✅ Create partners with and without subscriptions in setup
  - ❌ Create enabled partner in setup, then disable it in a test
  - ❌ Create partner with subscription in setup, then delete subscription in a test
  - Benefits: Tests are more independent, setup clearly documents all scenarios

### Test Data Factories (ExMachina)
- **Use ExMachina factories** for reusable test data creation
  - Keep setup blocks concise and scannable - don't bury the lede
  - Define factories in `test/support/*_factory.ex` modules
  - Factories should accept keyword lists for flexibility
  - Use composite factories for complex setups (e.g., `partner_with_endpoint`)
  - Example: `partner_with_endpoint(location_id: id, event_type: "test")`

### Pattern Matching in Assertions
- **Combine assertions with pattern matching** for cleaner, more idiomatic tests
  - ✅ `assert [job] = all_enqueued(worker: Worker)` - asserts count AND binds result
  - ✅ `assert [] = all_enqueued(worker: Worker)` - asserts empty list
  - ❌ `jobs = all_enqueued(...); assert length(jobs) == 1; job = hd(jobs)` - verbose
  - ❌ `assert length(jobs) == 0` - less idiomatic than pattern matching

- **Use pin operator with complex patterns** to validate and extract in one assertion
  - Pattern can both validate known values (with `^`) and capture new values
  - Pin operator references value bound BEFORE the pattern match, not intermediate rebindings
  - ✅ `assert %{"id" => uuid, "data" => %{"id" => ^expected_id}} = payload` - validates data, captures uuid
  - ❌ Multiple separate assertions for structure, extraction, and validation

### Unordered Collections
- **Use MapSet for comparing unordered collections**
  - ✅ `MapSet.new(actual_ids)` vs `MapSet.new(expected_ids)` - semantically clear
  - ❌ `Enum.sort(actual_ids)` vs `Enum.sort(expected_ids)` - obscures intent
  - MapSet communicates that order doesn't matter

### Query Organization
- **Wrap queries directly in Repo functions** for cleaner composition
  - ✅ `Repo.delete_all(from s in Schema, where: ...)`
  - ❌ `from(s in Schema, where: ...) |> Repo.delete_all()` - unnecessary pipeline
  - Direct wrapping is more concise when not chaining multiple operations

## Rationale Documentation

When making architectural decisions, document:
1. **What** the code does (inline comments)
2. **Why** we chose this approach (expanded comments for non-obvious decisions)
3. **Future changes** planned (TODO comments with ticket references)

## Examples

### Good: Tagged Metrics with Status
```elixir
if changeset.valid? do
  emit_metric("webhook.job.validation", %{partner: id, status: :success})
  [changeset]
else
  emit_metric("webhook.job.validation", %{partner: id, status: :error})
  []
end
```

### Good: Inline Logging with Context
```elixir
Logger.error("Invalid webhook job for endpoint",
  location_partner_id: endpoint.location_partner_id,
  errors: inspect(changeset.errors)
)
```

### Good: Inline Logic with Explanation
```elixir
# Until batching is implemented in PLATENG-1293, we will always send single events at a time.
events: [event]
```

### Good: Pattern Matching Assertions
```elixir
# Single result - asserts count and binds in one step
assert [job] = all_enqueued(worker: OutboundWebhookWorker)
assert job.args["domain"] == "https://example.com"

# Empty result - pattern match on empty list
assert [] = all_enqueued(worker: OutboundWebhookWorker)
```

### Good: Advanced Pattern Matching with Pin Operator
```elixir
# Validate structure, check known values, and extract unknowns in one assertion
event_payload_id = "test-123"

assert %{"id" => event_id, "type" => @event_type, "data" => %{"id" => ^event_payload_id}} = event_payload

# After pattern match:
# - event_id contains the captured UUID
# - @event_type was validated
# - data["id"] was validated to equal "test-123"

assert String.match?(event_id, ~r/^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i)
```

### Bad: Verbose Assertion Style
```elixir
# Unnecessarily verbose - use pattern matching instead
jobs = all_enqueued(worker: OutboundWebhookWorker)
assert length(jobs) == 1
job = hd(jobs)
assert job.args["domain"] == "https://example.com"

# Checking for empty - use pattern matching instead
jobs = all_enqueued(worker: OutboundWebhookWorker)
assert length(jobs) == 0

# Multiple separate assertions - use pattern matching instead
assert [event_payload] = job.args["events"]
assert Map.has_key?(event_payload, "id")
assert Map.has_key?(event_payload, "type")
assert Map.has_key?(event_payload, "data")
assert is_binary(event_payload["id"])
assert event_payload["type"] == "test_event"
assert event_payload["data"] == %{"id" => "test-123"}
assert String.match?(event_payload["id"], ~r/.../)
```

### Good: MapSet for Unordered Comparison
```elixir
job_partner_ids = MapSet.new(jobs, & &1.args["location_partner_id"])
expected_partner_ids = MapSet.new([partner1.id, partner2.id])
assert job_partner_ids == expected_partner_ids
```

### Bad: Sorting for Unordered Comparison
```elixir
# Obscures that order doesn't matter
job_partner_ids = Enum.map(jobs, & &1.args["location_partner_id"]) |> Enum.sort()
expected_partner_ids = [partner1.id, partner2.id] |> Enum.sort()
assert job_partner_ids == expected_partner_ids
```

### Good: Direct Query Wrapping
```elixir
Repo.delete_all(
  from(s in LocationPartnerSubscription,
    where: s.location_partner_id == ^partner_id and s.event_type == "test_event"
  )
)
```

### Bad: Unnecessary Pipeline for Single Operation
```elixir
from(s in LocationPartnerSubscription,
  where: s.location_partner_id == ^partner_id and s.event_type == "test_event"
)
|> Repo.delete_all()
```

### Good: Create All Test Data Variations in Setup
```elixir
describe "partner filtering" do
  setup do
    location_id = Ecto.UUID.generate()

    # Create all scenarios upfront
    enabled_partner = insert(:partner, location_id: location_id, is_enabled: true)
    disabled_partner = insert(:partner, location_id: location_id, is_enabled: false)
    partner_with_subscription = insert(:partner, location_id: location_id)
    partner_without_subscription = insert(:partner, location_id: location_id)

    insert(:subscription, partner_id: partner_with_subscription.id)

    %{
      enabled_partner: enabled_partner,
      disabled_partner: disabled_partner,
      partner_with_subscription: partner_with_subscription,
      partner_without_subscription: partner_without_subscription
    }
  end

  test "processes enabled partners", %{enabled_partner: partner} do
    # Test uses data as-is from setup
  end

  test "skips disabled partners", %{disabled_partner: partner} do
    # Test uses data as-is from setup
  end
end
```

### Bad: Mutating Setup Data in Tests
```elixir
describe "partner filtering" do
  setup do
    partner = insert(:partner, is_enabled: true)
    insert(:subscription, partner_id: partner.id)

    %{partner: partner}
  end

  test "skips disabled partners", %{partner: partner} do
    # BAD: Modifying setup data within test
    partner |> Ecto.Changeset.change(is_enabled: false) |> Repo.update!()
    # ...
  end

  test "skips partners without subscription", %{partner: partner} do
    # BAD: Deleting setup data within test
    Repo.delete_all(from s in Subscription, where: s.partner_id == ^partner.id)
    # ...
  end
end
```

### Good: Concise Setup with ExMachina Factories
```elixir
# Setup is scannable - immediately see all test scenarios
describe "partner filtering" do
  setup do
    location_id = Ecto.UUID.generate()

    enabled = partner_with_endpoint(location_id: location_id, global_partner_id: "enabled", event_type: "test")
    disabled = partner_with_endpoint(location_id: location_id, global_partner_id: "disabled", is_enabled: false, event_type: "test")
    no_subscription = partner_with_endpoint(location_id: location_id, global_partner_id: "no-sub")

    %{enabled: enabled, disabled: disabled, no_subscription: no_subscription}
  end

  # Tests use data as-is from setup
end

# Factory defined in test/support/webhooks_factory.ex (reusable across test files)
def partner_with_endpoint(attrs \\ []) do
  attrs = if is_map(attrs), do: Map.to_list(attrs), else: attrs

  location_id = Keyword.get(attrs, :location_id, Ecto.UUID.generate())
  event_type = Keyword.get(attrs, :event_type)

  partner = insert(:location_partner, location_id: location_id, ...)
  insert(:location_partner_endpoint, location_partner_id: partner.id, ...)
  if event_type, do: insert(:location_partner_subscription, ...)

  partner
end
```

### Bad: Verbose, Repetitive Setup
```elixir
describe "partner filtering" do
  setup do
    location_id = Ecto.UUID.generate()

    # 15+ lines per partner repeated 5 times = 75+ lines of setup
    partner1 = Repo.insert!(%Partner{location_id: location_id, ...})
    Repo.insert!(%Endpoint{partner_id: partner1.id, domain: "...", ...})
    Repo.insert!(%Subscription{partner_id: partner1.id, ...})

    partner2 = Repo.insert!(%Partner{location_id: location_id, ...})
    Repo.insert!(%Endpoint{partner_id: partner2.id, domain: "...", ...})
    Repo.insert!(%Subscription{partner_id: partner2.id, ...})

    # ... 3 more partners with similar boilerplate

    %{partner1: partner1, partner2: partner2, ...}
  end

  # Finally, the actual tests (buried after 100+ lines)
end
```
