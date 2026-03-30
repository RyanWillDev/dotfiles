# Index Column Ordering

These principles apply to any multi-column index — composite, covering, or otherwise.

## Column Ordering Rule

When choosing column order, follow this priority:

1. **WHERE clause columns first** (equality before ranges)
2. **ORDER BY columns next**
3. **Additional SELECT columns last** (or use `INCLUDE` — see `covering.md`)

```sql
-- For: WHERE user_id = X ORDER BY updated_at SELECT patient_id
CREATE INDEX idx_optimal ON table (user_id, updated_at DESC) INCLUDE (patient_id);
```

## Principles

### 1. Equality predicates before range predicates

Equality (`=`, `IN`) pins a column to a known value, allowing Postgres to descend directly to the right leaf node and continue using the next column. Range predicates (`>`, `<`, `BETWEEN`, `!=`, `IS NULL OR`) scan a portion of the index — columns after a range predicate cannot be used for seeking.

```sql
-- Query: WHERE status = 'active' AND created_at > '2026-01-01'
-- ✅ (status, created_at) — equality first, then range
-- ❌ (created_at, status) — range first breaks index use for status
```

### 2. Negation and OR predicates behave like range predicates

`!=`, `NOT IN`, and `col IS NULL OR col = value` are not equality checks. They match multiple distinct values, so Postgres must scan multiple index subtrees or ranges. Treat these as range predicates for ordering purposes.

```sql
-- Query: WHERE is_deleted != true AND start_time > NOW()
-- is_deleted != true  → matches false AND NULL → range-like (2 of 3 possible values)
-- start_time > NOW()  → range

-- Both are range predicates. Apply principle 3 (sort alignment) or 4 (selectivity).
```

### 3. Align the leading column with ORDER BY when possible

When a column appears in both WHERE and ORDER BY, placing it first lets Postgres satisfy the sort directly from the index scan — no separate sort step needed.

```sql
-- Query: WHERE is_deleted != true AND start_time > NOW() ORDER BY start_time
-- ✅ (start_time, is_deleted) — range scan starts at NOW(), results pre-sorted
-- ❌ (is_deleted, start_time) — must scan false + NULL groups and merge-sort
```

### 4. More selective columns first (when other rules don't apply)

When two columns are used with the same predicate type and neither is in ORDER BY, lead with the column that eliminates more rows.

```sql
-- Table: 1M rows, 10 distinct categories, 500K distinct user_ids
-- Query: WHERE category = 'books' AND user_id = 42
-- ✅ (user_id, category) — user_id narrows to ~2 rows, category filters within
-- ❌ (category, user_id) — category narrows to ~100K rows, then seeks user_id
```

## Decision Flowchart

```
For each column in the WHERE/ORDER BY:

1. Is it an equality predicate (=, IN)?
   → Group these first, ordered by selectivity (most selective first)

2. Is it a range predicate (>, <, !=, BETWEEN, IS NULL OR ...)?
   → Place after all equality columns

3. Among range predicates, does one appear in ORDER BY?
   → Lead with that one (avoids a sort step)

4. Among remaining range predicates, which is more selective?
   → Place more selective first

5. Are there SELECT columns not yet in the index?
   → Add via INCLUDE for a covering index (see covering.md)
```
