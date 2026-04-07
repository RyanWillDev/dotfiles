# State Management

## Avoid the Process Dictionary
- **The process dictionary is a last resort** — do not use it for configuration, test overrides, or passing implicit state
  - It creates hidden global mutable state within a process, making data flow invisible
  - It couples callers and callees through a shared side channel instead of explicit arguments
  - It breaks referential transparency — the same function call can return different results depending on hidden state
  - It makes tests order-dependent and harder to run concurrently

- **Prefer dependency injection via opts or function arguments**
  - Pass overridable values through an `opts \\ []` keyword list
  - Tests supply the override explicitly; production callers use the default
  ```elixir
  # GOOD: Explicit opts
  def load_and_validate(opts \\ []) do
    path = Keyword.get(opts, :config_path, default_config_path())
    # ...
  end

  # In tests:
  Config.load_and_validate(config_path: tmp_path)

  # BAD: Process dictionary
  def load_and_validate do
    path =
      case Process.get(:config_path_override) do
        nil -> default_config_path()
        p -> p
      end
    # ...
  end

  # In tests:
  Process.put(:config_path_override, tmp_path)
  Config.load_and_validate()
  ```

- **When you encounter process dictionary usage**, refactor it to opts or explicit arguments before building on top of it

- **Acceptable (rare) uses**: `:logger` metadata, tracing/telemetry correlation IDs — cases where the value is truly cross-cutting and threading it through every call would be impractical. Even then, prefer structured approaches like `Logger.metadata/1` over raw `Process.put/2`.
