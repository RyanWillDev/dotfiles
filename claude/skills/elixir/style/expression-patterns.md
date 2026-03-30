# Expression Patterns

## Pipeline Usage
- **Avoid over-using the pipe operator** - Claude tends to "fetishize pipes"
  - Use pipes for clear data transformations, not just to chain everything
  - Don't create pipelines just because you can

- **Prefer direct function wrapping over single-step pipes**
  - ✅ `NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)`
  - ❌ `NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)`
  - A single pipe doesn't add clarity; direct wrapping is more concise

- **If piping, pipe from the start** — don't mix function-wrapping and piping in the same chain
  - ✅ `query |> Repo.all() |> Map.new(&{&1.key, &1})`
  - ❌ `Repo.all(query) |> Map.new(&{&1.key, &1})`
  - The first form makes the data flow uniform; the second hides the starting value inside a function call

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

## Map Construction
- **Use `Map.new/2` instead of `Enum.into/3`** when building maps from enumerables
  - ✅ `Map.new(list, fn {k, v} -> {k, v} end)`
  - ❌ `Enum.into(list, %{}, fn {k, v} -> {k, v} end)`
  - `Map.new/2` is more direct and communicates intent clearly

- **Use the capture shorthand for simple key-value map building**
  - ✅ `Map.new(patients, &{&1.pims_code, &1})`
  - ❌ `Map.new(patients, fn p -> {p.pims_code, p} end)`

## Building Unique Collections
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

## Safe Nested Struct Access
- **Use `get_in` with `Access.key/1` for safe nil-tolerant nested struct access**
  - Short-circuits to `nil` at any level without requiring upstream `Enum.reject(&is_nil/1)`
  - ✅ `get_in(record, [Access.key(:association), Access.key(:field)])`
  - ❌ Chaining `record.association.field` after filtering nils with `Enum.reject`

## Collection Pipeline Visibility
- **Keep `Enum` pipelines at the call site** — don't wrap them in single-use named functions
  - `Enum.filter |> Enum.map` already describes the transformation
  - ✅ Inline the pipeline where it's used
  - ❌ `defp extract_provider_ids(items), do: items |> Enum.filter(...) |> Enum.map(...)`

## Conditional Simplification
- **Omit explicit `else: nil`** in if/unless statements (nil is the default)
  - ✅ `if condition, do: value`
  - ❌ `if condition, do: value, else: nil`
  - Reduces noise when nil is the intended fallback

## Function Definition Format
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
