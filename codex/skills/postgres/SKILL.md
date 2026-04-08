---
name: postgres
description: Use when making PostgreSQL design decisions involving migrations, indexes, schemas, constraints, queries, or performance. Read the relevant topic file on demand for index selection, index ordering, composite indexes, and covering indexes.
---

# PostgreSQL

This skill provides expert guidance for PostgreSQL design decisions in this codebase, covering indexes, queries, schema design, and performance.

## When to Invoke

### Invoke when:

- Writing or reviewing database migrations
- Adding or modifying indexes
- Designing table schemas or constraints
- Optimizing query performance
- Debugging slow queries or query plans
- Making decisions about data types, nullability, or uniqueness

## Progressive Disclosure Strategy

**CRITICAL**: This skill uses progressive disclosure through topic-specific files. Do NOT try to memorize all rules upfront. Instead, READ the relevant file on-demand when you need guidance.

### When to Read Reference Files

Read the relevant file in these situations:

| Task                                      | Read This File           |
| ----------------------------------------- | ------------------------ |
| Choosing an index type                    | `indexes/README.md`      |
| Ordering columns in a multi-column index  | `indexes/ordering.md`    |
| Adding composite/multi-column indexes     | `indexes/composite.md`   |
| Using INCLUDE for index-only scans        | `indexes/covering.md`    |

### Workflow

```
User requests database task
  ↓
Identify what you'll be working on (indexes, schema, queries, etc.)
  ↓
Read the relevant reference file
  ↓
Implement following the documented patterns
  ↓
If you discover a new pattern worth documenting, suggest adding it
```

## Reference Guide

The reference files live in topic-specific subdirectories:

- `indexes/README.md` — when to use which index type (B-tree, partial, composite, covering, GIN, etc.)
- `indexes/ordering.md` — column ordering principles, decision flowchart
- `indexes/composite.md` — composite-specific patterns, common query shapes
- `indexes/covering.md` — INCLUDE clause, index-only scans

**Read only the file relevant to your current task.** Do not load all files at once.

## Maintaining This Skill

This skill exists to capture PostgreSQL design patterns and preferences specific to this project. When using this skill, actively identify patterns worth documenting.

### When Mismatches Occur

1. **Acknowledge the divergence** — "I used [pattern], but I see you prefer [pattern]"
2. **Understand the reasoning** — Ask why if not clear from context
3. **Update the relevant reference file** — Add the pattern with Good/Bad examples
4. **Update this skill if needed** — Add new reference files to the table above

### Red Flags

- User corrects the same pattern repeatedly → Add to reference files
- You're unsure which of two valid approaches to use → Check reference files or ask
- User says "like we did in [other migration]" → Extract pattern to reference files
