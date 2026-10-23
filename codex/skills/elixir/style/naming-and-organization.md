# Naming & Organization

## Variable Naming
- **Prefer full variable names** over abbreviations
  - ✅ `exception`
  - ❌ `e`

- **Name maps and collections to communicate their key structure**, not just the value type
  - ✅ `patients_by_pims_id` — tells the reader what the map is keyed by
  - ❌ `patients` — tells the reader what the values are, but not how to look things up
  - Applies to any lookup map where the key is non-obvious from the value type alone

## Function Naming

- **Name functions for what they do, not what they return**

  A function's name should tell the caller something they can't already see. Return type is usually visible from context — what isn't visible is the approach, source, or strategy. Naming by return type repeats information the caller already has; naming by approach gives them something new.

  ```elixir
  # GOOD: names describe the approach — distinguishes the two functions
  defp from_cache(key), do: Cache.get(key)
  defp from_database(key), do: Repo.get_by(Record, key: key)

  # BAD: names describe the return type — says nothing about how they differ
  defp cached_record(key), do: Cache.get(key)
  defp database_record(key), do: Repo.get_by(Record, key: key)
  ```

  This is most apparent when functions are parallel alternatives that all return the same type — naming by return type is especially unhelpful when the return is identical.

## Function Organization
- **Inline simple helper functions** rather than creating separate private functions
  - If a helper is only used once and is simple (1-3 lines), inline it at the call site
  - Example: Instead of `defp log_error(event, reason)`, inline the `Logger.error` call directly

- **Extract complex anonymous functions** into named functions
  - If an anonymous function is substantial (multiple operations, business logic), extract it
  - Named functions are easier to test, read, and reference
  - ✅ `Task.async_stream(items, &process_item(&1, context), ...)`
  - ❌ `Task.async_stream(items, fn item -> ... 20 lines of logic ... end, ...)`

## Variable Assignments
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
  - **Exception**: Always assign before control flow (`case`, `if`, `cond`, `with`) - see Pipeline Usage
  - **Exception**: Assign when the variable name documents intent or improves readability

## Module Organization
- **Order of declarations:**
  1. `use` statements
  2. `import` statements
  3. `alias` statements
  4. `require` statements (e.g., `require Logger`)
  5. Module attributes
  6. Functions

## Alias Declarations
- **Declare all module aliases explicitly**, even for frequently referenced modules
  - Every module referenced in the file should have a corresponding alias
  - Avoids mixing fully-qualified and aliased references
  - Makes module dependencies immediately visible at the top of the file

- **Alias modules more than 2 levels deep** (aligns with Styler's formatting)
  - ✅ `alias Ecto.Association.NotLoaded` then use `NotLoaded.t()`
  - ❌ `Ecto.Association.NotLoaded.t()` inline
  - Two levels like `Ecto.Changeset` are fine without aliasing

## Behaviour Implementations
- **Use `@impl BehaviourModule` instead of `@impl true`** when implementing a behaviour callback
  - Makes it explicit which behaviour the function satisfies — useful when a module implements multiple behaviours
  - ✅ `@impl MyApp.SomeBehaviour`
  - ❌ `@impl true`

## Unused Variables
- **Prefix unused variables with underscore** in pattern matches
  - ✅ `case result do _error -> ...` when error isn't used
  - ❌ `case result do error -> ...` when error isn't used
  - Signals to readers (and the compiler) that the variable is intentionally unused
