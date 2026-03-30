---
name: elixir-development
description: **CRITICAL - This skill MUST be invoked before ANY work on or review of .ex or .exs files.** Expert guidance for Elixir development following project-specific style conventions. Invoke IMMEDIATELY when reading .ex or .exs files with intent to modify them, writing new .ex or .exs files, debugging Elixir code, reviewing Elixir code, or ANY task that involves Elixir code changes. Do NOT proceed with Elixir file modifications without invoking this skill first. Uses progressive disclosure by referencing style.md for on-demand pattern guidance.
allowed-tools: Bash(mix:*)
---

# Elixir Development

This skill provides expert guidance for Elixir development in this codebase, following project-specific style conventions and idiomatic patterns.

## CRITICAL: Automatic Invocation Required

**This skill MUST be invoked before ANY work on .ex or .exs files.**

### Invoke IMMEDIATELY when:

- Reading .ex or .exs files with intent to modify them
- Writing new .ex or .exs files
- Debugging Elixir code
- Reviewing Elixir code
- ANY task that involves Elixir code changes

### Do NOT proceed with Elixir file modifications without invoking this skill first.

### Examples of Required Invocation:

**Example 1:**

- User: "Fix the bug in partners.ex"
- **MUST invoke elixir skill first**

**Example 2:**

- User: "Add a new function to token.ex"
- **MUST invoke elixir skill first**

**Example 3:**

- User: "Refactor the Partner module"
- **MUST invoke elixir skill first**

**Example 4:**

- User: "Create a new ApplicationScope schema"
- **MUST invoke elixir skill first**

**Example 5:**

- User: "Update the tests in token_test.exs"
- **MUST invoke elixir skill first**

## Progressive Disclosure Strategy

**CRITICAL**: This skill uses progressive disclosure through the `style.md` file located in the same directory. Do NOT try to memorize all style rules upfront. Instead, READ `style.md` sections on-demand when you need guidance.

### When to Read style.md

Use the Read tool to access `style.md` in these situations:

| Task                        | Read This File                       |
| --------------------------- | ------------------------------------ |
| Writing new functions       | `style/naming-and-organization.md`   |
| Using pipes, maps, patterns | `style/expression-patterns.md`       |
| Writing or modifying tests  | `style/testing.md`                   |
| Adding metrics/logging      | `style/observability.md`             |
| Adding comments             | `style/comments.md`                  |
| Working with Ecto schemas   | `style/ecto.md`                      |
| Fixing dialyzer warnings    | `style/dialyzer.md`                  |
| Unsure about a pattern      | Check `style.md` index for the right file |

### Workflow

```
User requests Elixir task
  ↓
Identify what you'll be writing (functions, tests, metrics, etc.)
  ↓
Read relevant sections of style.md using the Read tool
  ↓
Implement following the documented patterns
  ↓
If you discover a new pattern worth documenting, suggest adding it to style.md
```

## Core Patterns

### Pattern Matching

- Prefer pattern matching over conditional logic
- Use pattern matching in function heads for clarity
- Combine pattern matching with assertions in tests
- Pin operator `^` references value bound BEFORE the pattern match

Example from style.md:

```elixir
# Validate structure, check known values, extract unknowns
event_payload_id = "test-123"
assert %{"id" => event_id, "type" => @event_type, "data" => %{"id" => ^event_payload_id}} = payload
assert String.match?(event_id, ~r/uuid-pattern/)
```

### Error Handling

- Use tagged tuples `{:ok, result}` / `{:error, reason}` for expected failures
- Use exceptions for infrastructure failures that should crash and retry
- Document error handling philosophy in comments
- Consider failure isolation strategy (per-item vs all-or-nothing)

### Testing

**Always reference style.md for current testing patterns.** Key points:

- Use pattern matching in assertions (not multiple Map.has_key? calls)
- Create all test data variations in setup, avoid mutating in tests
- Use ExMachina factories for reusable test data
- Use MapSet for unordered collection comparisons
- Wrap queries directly in Repo functions

### Observability

**Always check style.md before adding metrics or logging.**

Metrics:

- Use tagged metrics with status/result (not separate metric names)
- Include relevant context in tags (partner_id, location_id, event_type, status)
- Emit metrics for both success and failure paths

Logging:

- Include structured metadata with log messages
- Inline simple logging calls (don't create helper functions)
- Use appropriate log levels

### Common Tasks

- Writing Ecto queries and schemas
- Adding metrics and observability
- Writing comprehensive tests

## Elixir Idioms

### Prefer

- Pipeline operator `|>` for data transformations
- Pattern matching over conditionals
- With statements for happy path sequences
- Tagged tuples for results
- Protocols for polymorphism
- Behaviours for contracts

### Avoid

- Deeply nested conditionals
- Mutating data structures
- Long parameter lists (use maps/structs)
- God modules
- Leaky abstractions

## Pre-Flight Checklist

Before finalizing any Elixir code:

- [ ] Read relevant style.md sections
- [ ] Followed project naming conventions
- [ ] Added appropriate metrics with tags
- [ ] Included error handling with philosophy comments
- [ ] Wrote tests using pattern matching assertions
- [ ] Created all test data in setup (not mutated in tests)
- [ ] Added inline comments for business logic
- [ ] Aliased all referenced modules explicitly
- [ ] Used tagged metrics (not separate metric names)
- [ ] Ran tests and verified they pass

## Example: Writing a New Feature

```
User: "Add a new webhook validation function"

1. Read style.md sections:
   - "Function Organization" → understand helper function patterns
   - "Error Handling Comments" → learn how to document error handling
   - "Metrics & Observability" → learn tagged metrics pattern

2. Implement following those patterns

3. Add tests:
   - Read "Testing Patterns" from style.md
   - Use pattern matching in assertions
   - Create all test data in setup

4. Review and suggest style.md updates if you used a new pattern
```

## Important Reminders

> For language-agnostic design principles, see the **software-design-philosophy** skill.

1. **Always read style.md sections before implementing** - Don't guess at patterns
2. **Follow existing code patterns** - Consistency matters more than personal preference (see philosophy Principle 3)
3. **Test thoroughly** - This project values comprehensive test coverage
4. **Document decisions** - Explain non-obvious choices in comments (see philosophy Principle 2)
5. **Keep it simple** - Prefer subtractive solutions over additive workarounds (see philosophy Principle 1)
6. **Update style.md** - Document new patterns as they emerge

## Maintaining This Skill

This skill and style.md exist to bridge the gap between Claude's learned Elixir patterns and the user's preferred patterns. When using this skill, actively identify and document these differences.

### Purpose

Claude's training includes Elixir code from many sources, which may differ from this project's conventions. The skill + style.md system captures these divergences to ensure consistent, preferred patterns.

### Common Divergences to Watch For

Claude's natural tendencies vs this project's preferences:

| Claude's Default                                          | This Project Prefers                                   | Document In                            |
| --------------------------------------------------------- | ------------------------------------------------------ | -------------------------------------- |
| Multiple separate assertions                              | Pattern matching in single assertion                   | style.md - Testing Patterns            |
| `Map.has_key?()` checks                                   | Pattern matching with implicit key validation          | style.md - Testing Patterns            |
| Separate metric names per outcome                         | Tagged metrics with status                             | style.md - Metrics & Observability     |
| Helper functions for logging                              | Inline logging calls                                   | style.md - Logging                     |
| Sorting for unordered comparisons                         | MapSet for semantic clarity                            | style.md - Unordered Collections       |
| Piping queries to Repo                                    | Wrapping queries directly in Repo                      | style.md - Query Organization          |
| `@impl true` on behaviour callbacks                       | `@impl BehaviourModule` for explicit attribution       | style.md - Behaviour Implementations   |
| Banner/divider comments before describe blocks            | No dividers; describe blocks are self-documenting      | style.md - Section Dividers in Tests   |
| Naming maps by value type (`patients`)                    | Name by key structure (`patients_by_pims_id`)          | style.md - Variable Naming             |
| Multi-pass `map \|> reject \|> uniq` for unique sets      | Single-pass `Enum.reduce(MapSet.new(), ...)`           | style.md - Building Unique Collections |
| Chained field access with upstream nil filtering          | `get_in` with `Access.key/1` for safe nested access    | style.md - Safe Nested Struct Access   |
| Suppressing dialyzer warnings (ignore files, `@dialyzer`) | Trace cascading errors to root cause and fix the types | style.md - Dialyzer & Type Specs       |

### When Mismatches Occur

**Recognition Pattern:**

1. You implement code following your learned patterns
2. User provides feedback: "I prefer X instead of Y"
3. This is a learning opportunity

**Response Process:**

1. **Acknowledge the divergence** - "I used [pattern] which is common in Elixir, but I see you prefer [pattern]"
2. **Understand the reasoning** - Ask why if not clear from context
3. **Update style.md** - Add the pattern to the appropriate section with Good/Bad examples
4. **Update this skill if needed** - Add to "Common Divergences" table if it's a fundamental difference

### Example: Discovering a New Preference

```
Scenario: User provides feedback on code you wrote

You wrote:
  assert [event_payload] = job.args["events"]
  assert Map.has_key?(event_payload, "id")
  assert Map.has_key?(event_payload, "type")
  assert event_payload["type"] == "test_event"

User feedback: "I prefer using pattern matching in a single assertion"

Response:
1. "I used multiple separate assertions, which is a common pattern, but I see
   you prefer combining these into a single pattern match for conciseness."

2. Update style.md:
   - Add to "Pattern Matching in Assertions" section
   - Include Good example (their preference)
   - Include Bad example (what you did)
   - Explain the benefit (conciseness, idiomatic)

3. Rewrite code following their pattern:
   assert %{"id" => event_id, "type" => "test_event"} = event_payload

4. Add to "Common Divergences" table in this skill if it's a recurring pattern
```

### Maintenance Workflow

**When writing new Elixir code:**

1. Read style.md for existing patterns
2. If no guidance exists, use your best judgment
3. Be prepared to learn the user's preference
4. Document the preference when revealed

**When receiving feedback:**

1. Recognize it as a preference signal
2. Ask clarifying questions if the reasoning isn't clear
3. Update style.md immediately with the pattern
4. Reference the new style.md section in your revision

**Periodic review:**

- The "Common Divergences" table should grow as patterns are discovered
- When a divergence appears 3+ times, it should be documented in style.md
- This skill file should be updated to reflect major pattern categories

### Philosophy

- **Your defaults aren't wrong** - They're just different from this project's conventions
- **Every mismatch is valuable** - It reveals an undocumented preference
- **style.md is living documentation** - It should grow with every discovered preference
- **Progressive improvement** - The more mismatches you document, the fewer you'll make

### Red Flags

Watch for these signs that maintenance is needed:

- User frequently corrects the same pattern → Add to style.md
- You're unsure which of two valid patterns to use → Check style.md or ask
- User says "like we did in [other file]" → Extract pattern to style.md
- You notice inconsistency across the codebase → Suggest documenting the preferred approach

## Style Guide Reference

The style guide lives in the `style/` subdirectory, indexed by `style.md`. Each file covers a focused topic:

- `style/naming-and-organization.md` — variables, functions, modules, aliases
- `style/expression-patterns.md` — pipes, maps, collections, conditionals
- `style/testing.md` — test setup, factories, assertions, examples
- `style/observability.md` — metrics, logging
- `style/comments.md` — documentation, rationale, error handling comments
- `style/ecto.md` — schemas, embedded schemas
- `style/dialyzer.md` — type specs, changeset signatures, cascading errors

**Read only the file relevant to your current task.** Do not load all files at once.
