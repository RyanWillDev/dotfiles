# Ecto Patterns

## Embedded Schemas
- **Prefer embedded schemas when the value is a known and consistent type**
  - ✅ `embeds_many :delivery_attempts, DeliveryAttempt` when structure is well-defined
  - `{:array, :map}` is fine for truly dynamic/unknown structures
  - Embedded schemas provide type safety, changesets, and clear documentation

## Queries
- **Use `Repo.exists?/1` for existence checks** — don't fetch a full record when you only need a boolean
  - ✅ `from(u in User, where: u.email == ^email) |> Repo.exists?()`
  - ❌ `Repo.get_by(User, email: email) |> is_nil() |> Kernel.not()`

- **Prefer `insert_all` + fetch over get-or-create loops** for batch ensuring records exist
  - ✅ `Repo.insert_all(Schema, entries, on_conflict: :nothing)` then `Repo.all(query)`
  - ❌ `Enum.reduce(items, %{}, fn item, acc -> get_or_create(item) ... end)`

## Migrations & Indexes

When writing Ecto migrations that add indexes, invoke the **postgres** skill for guidance on index type selection and column ordering. See `~/.claude/skills/postgres/SKILL.md`.
