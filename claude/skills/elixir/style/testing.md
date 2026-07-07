# Testing Patterns

## Test File Organization
- **One test file per schema** - don't combine multiple schema tests in one file
  - ✅ `location_partner_webhook_event_test.exs` and `location_partner_webhook_event_batch_test.exs`
  - ❌ Both schemas tested in a single file

- **Use concise describe block names** - module name provides context
  - ✅ `describe "changeset"` in `LocationPartnerWebhookEventBatchTest`
  - ❌ `describe "LocationPartnerWebhookEventBatch changeset"` - redundant with module name

## Test Data Setup
- **Create all data variations in setup**, avoid mutating setup data in individual tests
  - ✅ Create both enabled and disabled partners in setup
  - ✅ Create partners with and without subscriptions in setup
  - ❌ Create enabled partner in setup, then disable it in a test
  - ❌ Create partner with subscription in setup, then delete subscription in a test
  - Benefits: Tests are more independent, setup clearly documents all scenarios

### Good: Create All Variations in Setup
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

## Test Data Factories (ExMachina)
- **Use ExMachina factories** for reusable test data creation
  - Keep setup blocks concise and scannable - don't bury the lede
  - Define factories in `test/support/*_factory.ex` modules
  - Factories should accept keyword lists for flexibility
  - Use composite factories for complex setups (e.g., `partner_with_endpoint`)
  - Example: `partner_with_endpoint(location_id: id, event_type: "test")`

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

### Don't Test the Factory Itself
- **Never write a dedicated `describe "factory"` block** asserting that `build(:thing)` returns a struct, accepts overrides, or persists via `Repo.insert!`.
  - Factories are test infrastructure. Every downstream test that calls `build(:thing)` exercises the factory; if it's broken, those tests fail.
  - A dedicated factory describe block duplicates that signal without adding coverage and mostly exercises ExMachina + Ecto, not anything you wrote.
- **Schema tests should use direct struct construction**, not `build(:x)`, when the goal is to exercise the schema's own changeset/insert behavior — keep the factory and the schema-under-test independent.
  - ✅ `%Widget{} |> Widget.changeset(attrs) |> Repo.insert()`
  - ❌ `build(:widget) |> Repo.insert!()` (in a schema test — fine in feature/integration tests)
- The factory's existence as a ticket acceptance criterion is satisfied by writing it. It doesn't need a test to prove it works.

## Pattern Matching in Assertions
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

## Unordered Collections
- **Use MapSet for comparing unordered collections**
  - ✅ `MapSet.new(actual_ids)` vs `MapSet.new(expected_ids)` - semantically clear
  - ❌ `Enum.sort(actual_ids)` vs `Enum.sort(expected_ids)` - obscures intent
  - MapSet communicates that order doesn't matter

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

## Query Organization
- **Wrap queries directly in Repo functions** for cleaner composition
  - ✅ `Repo.delete_all(from s in Schema, where: ...)`
  - ❌ `from(s in Schema, where: ...) |> Repo.delete_all()` - unnecessary pipeline
  - Direct wrapping is more concise when not chaining multiple operations

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

## Async and Global State

- **Use `async: false` when a test mutates process-global / VM-wide shared state.**
  The Ecto sandbox isolates DB writes per test, but it does **not** isolate global
  state. With `async: true`, ExUnit runs that module concurrently with others, so a
  mutated global value can bleed into — or be clobbered by — tests in another module.
- State that requires `async: false` when mutated:
  - `Application.put_env/3` / `Application.delete_env/2` (app config)
  - `System.put_env/2` (environment variables)
  - `Application.put_env`-backed feature flags, `:persistent_term`, `:ets` tables you own
  - Mox in `:global` mode, or any named process whose state you swap
- **Always restore the original value** in `setup` via `on_exit/1`, even with `async: false`
  — otherwise the mutation leaks forward to later tests in the same module/run.
- `async: false` is about *what you mutate*, not *whether another module happens to read it
  today*. Don't reason from "only this module reads this key" — that coupling is invisible and
  can change. If you mutate global state, the module is `async: false`.

### Good: `async: false` + restore for an Application config override
```elixir
defmodule MyApp.TokenTest do
  use ExUnit.Case, async: false

  describe "generate/1 with a missing secret" do
    setup do
      original = Application.get_env(:my_app, Token)
      Application.put_env(:my_app, Token, secret: nil)
      on_exit(fn -> Application.put_env(:my_app, Token, original) end)
      :ok
    end
  end
end
```

### Bad: mutating Application state under `async: true`
```elixir
use ExUnit.Case, async: true  # ❌ concurrent modules race on the same global key

setup do
  Application.put_env(:my_app, Token, secret: nil)  # ❌ no restore, leaks forward
end
```
