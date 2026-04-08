# Dialyzer & Type Specs

## Approach

- **Never suppress dialyzer warnings without first tracing to the root cause.** Dialyzer errors cascade — a single type mismatch can produce `no_return`, which propagates `pattern_match` warnings in callers. Always find the originating error before considering suppression.

## Changeset Function Specs

- **Use `%__MODULE__{}` instead of `t()` for changeset function specs.** The `@type t` on Ecto schemas describes a fully-loaded record (non-nil id, populated fields). A freshly built `%Schema{}` has nil fields and won't match `t()`. Changeset functions accept bare structs, so the spec should reflect that:
  ```elixir
  # BAD: %Schema{} has id: nil which doesn't satisfy t()
  # Dialyzer flags the call as contract-breaking → no_return cascade
  @spec changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()

  # GOOD: Accepts any field values including nil
  @spec changeset(%__MODULE__{} | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  ```

## Default Arguments

- **Remove default arguments when the spec requires specific keys.** A default like `def create(attrs \\ %{})` generates a zero-arity function. If the spec requires keys in the map, dialyzer will flag `create/0` since `%{}` can't satisfy the spec. Remove the default if callers always pass arguments.
