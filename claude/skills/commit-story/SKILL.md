---
name: commit-story
description: Split the working tree into a sequence of commits that tells a story, then verify every commit passes the project's checks. Invoke on /commit-story.
disable-model-invocation: true
---

# Commit Story

Turns uncommitted changes into an ordered, bisectable commit sequence.
Invoking this skill is the authorization to commit; it never pushes.

## Story rules

1. **Tidy First.** Structural changes (renames, extractions, moves, formatting) and behavioral changes never share a commit.
   Structural commits come before the behavioral commits that need them.
2. **Dependency order.** A schema, migration, or new module lands before the code that uses it.
3. **Tests with code.** Each behavioral commit pairs the behavior with the tests that cover it.
4. **Bisectable.** Every commit passes the project's checks on its own.
5. **Messages explain why.** Follow `writing-for-humans` and match the conventions in recent `git log` (ticket prefixes, tense).

## Check categories

Every commit runs whichever of these the project has:

1. **Build** with warnings as errors
2. **Format check**
3. **Lint**
4. **Type check**
5. **Affected tests:** the toolchain's affected-tests mode if it has one, else the test files the commit touches

Resolve commands from a `Commit checks` section in the project's CLAUDE.md.
If there is none, infer them from project files (`mix.exs` aliases, `package.json` scripts, `Makefile`, `pyproject.toml`).
Example for an Elixir project: `mix compile --warnings-as-errors`, `mix format --check-formatted`, `mix credo --strict`,
`mix dialyzer`, `mix test --stale`.

## Steps

### 1. Plan

Record the base: `git rev-parse HEAD`.
Read `git status` and the full diff, including untracked files.
Present the plan:

- Each commit: title, structural or behavioral, and the files or hunks it contains
- The resolved check command for each category
- Any changes left out of the sequence, and why

**Done when** every changed line and untracked file is assigned to exactly one commit or explicitly listed as left out.

### 2. Approve

Wait for Ryan to approve or adjust the plan.

**Done when** Ryan has approved a plan; repeat step 1 for any requested change.

### 3. Commit

Build each commit in the index without touching the working tree:

- **Whole files:** `git add <path>`
- **Subset of hunks:** write a patch with only those hunks, then `git apply --cached --recount <patch>`
- **Intermediate content** (the file at this commit matches neither base nor final):
  write that version to a temp file, then `git hash-object -w <tmp>` and
  `git update-index --cacheinfo <mode>,<sha>,<path>` (add `--add` for new files)

Before each `git commit`, compare `git diff --cached --stat` against the plan.
If any changes were left out, commit them last as a temporary `WIP: excluded` commit so the tree is clean for step 4.

**Done when** `git status` is clean and `git log <base>..HEAD` matches the approved plan one-to-one.

### 4. Verify

Delegate to a Haiku agent.
Brief it with the commit SHAs (oldest first, excluding `WIP: excluded`), the check commands, and the branch name.
For each SHA it runs `git checkout --detach <sha>`, runs every check, and records each check's wall-clock time.
It finishes with `git checkout <branch>`.
It reports, per commit: pass or fail per check, the tool's summary line verbatim, failures (name, `file:line`, error; max ~10), and timings.

If a summary line's counts don't match the failures reported, rerun that check yourself.
Once verification ends, undo the temporary commit with `git reset HEAD~1` if one exists.

**Done when** every planned commit has a result for every check, and the branch is checked out again.

### 5. Report or redo

All pass: report the commit list and timings.
Flag any check that took over ~3 minutes per commit as a candidate for running on HEAD only.

A failure that also fails at HEAD is a code problem, not a split problem.
Stop and report it; fixing code is out of scope.

A failure only in an intermediate commit means the split is wrong.
`git reset <base>` (keeps the working tree, clears the index), revise the plan, show Ryan the change, and return to step 3.

**Done when** every commit passes every check, or Ryan has a report of a HEAD-level failure.
