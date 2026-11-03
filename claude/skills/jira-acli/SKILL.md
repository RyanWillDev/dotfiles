---
name: jira-acli
description: Use the acli command-line tool to view, search, create, edit, link, and transition Jira work items and projects. Activate when the user mentions Jira, tickets, issues, epics, or sprints, or asks to implement or plan work described there.
allowed-tools: Bash(acli jira workitem search:*), Bash(acli jira workitem view:*), Bash(acli jira workitem create:*), Bash(acli jira workitem edit:*), Bash(acli jira workitem transition:*), Bash(acli jira workitem link:*), Bash(acli jira workitem comment list:*), Bash(acli jira project list:*), Bash(acli jira project view:*), Bash(acli jira filter search:*), Bash(acli jira auth status:*)
---

# Jira ACLI

For flags not covered here, run `acli jira <command> --help`.
This file holds only what `--help` gets wrong or leaves out, plus this org's conventions.

## Guardrails

- **Comments:** create one only when the user asks. `comment create` is deliberately missing from `allowed-tools`, so every comment goes through a permission prompt. Never route around that prompt (e.g. with a broader Bash allowance, or by batching the command in with approved ones).
- **Type:** use `Story` unless the user names another type. Use `Bug` only when the user explicitly asks for a bug. Words like "fix", "broken" or "crash" don't count.
- **New tickets:** unless the user says otherwise, assign every ticket you create to the user and move it to `Refining`.
  Jira can't set status at creation, so run `acli jira workitem transition --key KEY-1 --status "Refining" --yes` right after `create`.
- **Status:** moving a ticket to `In Progress` when you start work is fine. Move it to `Done` or any other terminal status only when the user asks.
- **Projects:** never run `acli jira project create`. It's deliberately missing from `allowed-tools`. Point the user to the Jira UI.
- **QA notes:** leave them out of both the description and the `QA Notes` field. Testing guidance belongs to whoever owns QA.

## Creating and editing

- **Descriptions are ADF JSON.** Always write them with `--from-json`. `--description` and `--description-file` produce unformatted text.
- **Payload shape:** get it from `acli jira workitem create --generate-json`, not from another tool.
  - Create payloads use `projectKey` (not `project`) and `parentIssueId` (not `parent`).
  - Edit payloads name their targets with `"issues": ["KEY-1"]`. Run them with `acli jira workitem edit --from-json <file> --yes`.
- **Assign to the user by email**, taken from the `Email:` line of `acli jira auth status`.
  In a `--from-json` payload, set `"assignee": "<email>"`.
  `--assignee "@me"` silently falls back to the project's default assignee instead of erroring.

## Labels and components

Confirm both before creating a ticket. Ask with AskUserQuestion, single-select, so the user picks from real values.

**Labels: pick exactly one classification label** (header "Work Type"):
- `Roadmap`: planned work on the team's product or technical roadmap.
- `Maintenance`: planned work paying down tech debt or improving technical posture.
- `UnplannedWork`: work outside planned capacity (post-incident fixes, urgent requests). Track it separately even when it relates to Roadmap or Maintenance work.

Skip either question when the user already stated the value (for a component, only once it matches the real list).
`DevTested` is not a classification label. It's added at transition time (see Transitions).

**Components** (header "Components"): read the project's real list with `acli jira project view --key PROJ --json` (the top-level `components[].name`).
- **Empty list:** the project doesn't use components, so don't ask.
- **Up to 4 components:** offer them all.
- **More than 4:** first send a plain message listing every name. Then offer the 3–4 likeliest, best guess first, so the user can type any other name via "Other".
- **`Other Domain`** means the work belongs to another team's area. Offer it when the ticket points outside the project.

**Setting a component (verified; not in `--help` or `--generate-json`):**
- It can only be set at creation, via `--from-json` with `"additionalAttributes": {"components": [{"name": "<exact name>"}]}`. A top-level `components` key is rejected.
- Pass only a name from the `project view` list or the user's own answer. An unknown name silently creates a new component in the project, and only the Jira web UI can delete it. If the user's answer isn't in the list, confirm they mean to create a new component.
- It can't be changed after creation: `edit --from-json` rejects every `components` form. Send the user to the web UI.

## Writing the description

**Specify behavior, not implementation.** Let the Acceptance Criteria imply the code changes rather than walking through them. A good AC says what's true when the work is done ("a missing file is skipped and writes no log line"), not which functions to edit. Two kinds of detail are requirements even though they look like implementation:
- **Contracts other work depends on** (metric names and tags, API shapes, config keys). State them exactly in the ACs.
- **Constraints the ACs don't rule out** ("keep the cache module; other callers use it"). Put them in Considerations.

**Sections, in order** (ADF shapes in [ADF_REFERENCE.md](ADF_REFERENCE.md); load it before building a payload):
1. **Summary:** one or two dense paragraphs stating the cause and its consequence. Ground claims in specific files, config, tickets and dates.
2. **Context:** background, a design decision, or a domain rule the reader needs before the ACs make sense.
   - If it tells the reader what to do or know, use an h2 heading.
   - If it justifies the ticket (how a diagnosis was confirmed, why an approach is safe, evidence, cost analysis, alternatives), put it in a collapsed `expand` titled with the section name.
3. **Acceptance Criteria** (h3): a numbered list of independently checkable items. Use nested lists for multi-part items.
4. **Considerations** (h2, if any): bullets covering tradeoffs, dependencies, constraints, scope boundaries, related tickets and docs. Anything that isn't a requirement goes here.
5. **Agent Implementation Guide** (optional, a collapsed `expand` with that title): files and functions involved, code paths that go away, patterns to follow, tests to touch.
   - Include it only when an investigation already produced this context.
   - It must add no requirement the ACs don't already imply.
6. **Open Questions** (h2, if any): numbered, so each can be referenced as "Open Question 2". Keep them out of Considerations.

ACs, Considerations and Open Questions are never collapsed.

**Formatting:**
- Give every identifier a `code` mark: functions, modules, files, columns, error strings.
- Never put `code` and `link` marks on the same text. It corrupts the ticket in the web editor. Keep only the `link`.

**Links:**
- **Every ticket key in a description gets a link.** Build it as `https://<site>/browse/KEY`, where `<site>` comes from `acli jira auth status`. `view`'s `self` field returns an internal REST host, which makes a dead link.
- **GitHub links only when they save a real search** (a specific function or branch). Pin them to a full SHA from `git rev-parse HEAD`, and check the line range with `sed -n`.
- **Build a URL only from data confirmed this session.** Otherwise leave the reference as `code` text.

## Transitions

When the user moves a ticket to `In QA` and is testing it themselves rather than QA (typically low-risk, unit-tested or hard-to-test work), add the `DevTested` label:

```bash
acli jira workitem edit --key KEY-1 --labels "DevTested"   # additive; keeps the classification label
acli jira workitem transition --key KEY-1 --status "In QA"
```

If it isn't clear who's testing, ask before adding the label.
Remind the user that the ticket still needs to move to `Testing Approved` after their testing.

## Linking

**Create breadcrumb links without being asked:**
- **A new bug whose cause is a known ticket:** link it as caused by that ticket, using `Problem/Incident`.
- **Several tickets created from one source:** link every pair with `Relates`, not just each one back to the source. Check the project's relation-type name with `acli jira workitem link type`.
- **A known related ticket from earlier in the session:** link it too.

**`link create` is backwards from its flag names (verified):**
- The flags are `--out` and `--in`. `--from` and `--to` don't exist.
- `--type` takes the type *name* (`Blocks`, `Problem/Incident`, `Relates`), not a phrase like "causes".
- The issue that should read with the type's **inward** wording goes in `--out`. For example, for "A is caused by B", use `--out A --in B --type "Problem/Incident" --yes`. For "A is blocked by B", use `--out A --in B --type Blocks --yes`.

**Verify every link afterward.** The success message doesn't show the direction. Run `acli jira workitem view KEY --fields issuelinks --json` and read each entry as "this issue <the wording of whichever `inwardIssue`/`outwardIssue` key is present> <that issue>". If the direction is wrong, run `acli jira workitem link delete --id <id> --yes` and recreate the link with `--out` and `--in` swapped.
