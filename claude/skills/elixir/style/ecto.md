# Ecto Patterns

## Embedded Schemas
- **Prefer embedded schemas when the value is a known and consistent type**
  - ✅ `embeds_many :delivery_attempts, DeliveryAttempt` when structure is well-defined
  - `{:array, :map}` is fine for truly dynamic/unknown structures
  - Embedded schemas provide type safety, changesets, and clear documentation
