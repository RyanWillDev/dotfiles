# Indexes

## Choosing the Right Index Type

Use this guide to pick the right index strategy, then read the linked file for implementation details.

### Decision Table

| Situation | Index Type | Reference |
|---|---|---|
| Filtering/sorting on a single column | **B-tree** (default) | — |
| Filtering/sorting across multiple columns | **Composite B-tree** | `composite.md` |
| Query only needs a subset of rows (e.g., non-deleted) | **Partial index** | — |
| Query selects columns beyond the filter/sort | **Covering index** (`INCLUDE`) | `covering.md` |
| Full-text search, array/JSONB containment | **GIN** | — |
| Geometric/spatial queries | **GiST** | — |
| High-cardinality equality-only lookups (no range/sort) | **Hash** | — |

### When to Use Composite vs Separate Indexes

Use a **composite index** when:
- Queries consistently filter on the same set of columns together
- You need the index to satisfy both a WHERE and ORDER BY in one scan
- An equality predicate on one column narrows the range scan on another

Use **separate single-column indexes** when:
- Columns are queried independently in different queries
- Postgres can combine them via BitmapAnd/BitmapOr (less efficient but more flexible)

### When to Use Partial Indexes

A partial index includes only rows matching a WHERE clause, making it smaller and faster.

```sql
-- Only index non-deleted appointments — the common query case
CREATE INDEX idx_active_appointments ON appointments (start_time)
  WHERE deleted_at IS NULL;
```

Use when:
- Most queries filter on the same condition (e.g., `WHERE deleted_at IS NULL`)
- The filtered subset is significantly smaller than the full table
- You want to enforce a unique constraint on a subset of rows

### Column Ordering

All multi-column indexes depend on correct column ordering. See `ordering.md` for the principles that apply across composite and covering indexes.
