# Composite Indexes

A composite (multi-column) B-tree index stores rows sorted by the first column, then by the second within each first-column group, and so on. Postgres can only use a column in the index if all columns to its left are constrained.

For column ordering principles, see `ordering.md`.

## Common Patterns

### Soft-delete + time range + sort

Common in migration queries that filter out deleted records and select a time window.

```sql
-- Query: WHERE is_deleted != true AND start_time > NOW() ORDER BY start_time, id
-- is_deleted: negation (range-like), low selectivity (most rows aren't deleted)
-- start_time: range, high selectivity, also the ORDER BY column

-- ✅ (start_time, is_deleted)
-- Postgres range-scans from NOW() forward, filters is_deleted per entry,
-- results are already sorted by start_time.
```

### Equality + range + sort on the range column

```sql
-- Query: WHERE tenant_id = $1 AND created_at > $2 ORDER BY created_at
-- ✅ (tenant_id, created_at) — equality pins tenant, then range+sort on created_at
```

### Multiple equality columns

```sql
-- Query: WHERE calendar_id = $1 AND date = $2 AND patient_id = $3
-- All equality — order by selectivity (most distinct values first)
-- ✅ (patient_id, calendar_id, date) if patient_id is most selective
-- Alternatively: match the most common query pattern for partial index use
```

## Leftmost Prefix Rule

Postgres can use a composite index for queries that constrain a leftmost prefix of the index columns. A `(a, b, c)` index serves queries on `(a)`, `(a, b)`, and `(a, b, c)` — but not `(b, c)` alone.

Design composite indexes so the most commonly queried subset of columns is a leftmost prefix.
