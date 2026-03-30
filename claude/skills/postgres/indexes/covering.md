# Covering Indexes

A covering index includes all columns a query needs, enabling an **index-only scan** — Postgres reads the index without touching the heap (table) at all.

## INCLUDE Clause

Use `INCLUDE` to add columns that the query selects but does not filter or sort on. `INCLUDE` columns are stored in the index leaf pages but not in the B-tree structure, so they don't bloat the tree or affect ordering.

```sql
-- Query: WHERE user_id = $1 ORDER BY updated_at DESC LIMIT 10
-- Needs: patient_id in SELECT

-- ✅ INCLUDE keeps patient_id out of the sort key
CREATE INDEX idx_user_recent ON table (user_id, updated_at DESC) INCLUDE (patient_id);

-- ❌ Adding patient_id to the key changes the sort order needlessly
CREATE INDEX idx_user_recent ON table (user_id, updated_at DESC, patient_id);
```

## When to Use

- The query has a small, stable set of SELECT columns beyond the WHERE/ORDER BY columns
- The table is large enough that heap access is a measurable cost
- The included columns are not used in WHERE or ORDER BY (otherwise they belong in the key)

## When Not to Use

- The query selects many columns or `SELECT *` — the index would duplicate most of the table
- The included columns change frequently — index maintenance cost increases
- The table is small enough that heap access is negligible
