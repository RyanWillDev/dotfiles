---
name: jira-acli
description: "Use when the user asks about Jira tickets, work items, project planning, or implementing work described in Jira. Prefer the `acli` command-line tool for searching, viewing, creating, editing, transitioning, and commenting on Jira items."
---

# Jira ACLI Skill

This skill enables interaction with Atlassian Jira using the `acli` command-line interface. Use this skill when users want to:
- View, search, create, or edit Jira work items (issues, stories, tasks, bugs, epics)
- Plan or implement features described in Jira tickets
- Query Jira for project information
- Manage work item transitions and links
- View comments (but never add comments unless explicitly requested)
- List projects and filters

## Prerequisites

The `acli` tool must be installed and authenticated. Users should have already run `acli jira auth` to authenticate.

## Important Guidelines

**NEVER add comments to Jira work items unless explicitly requested by the user.** Comments should only be created when the user specifically asks to add a comment. Viewing and listing comments is fine, but creating comments requires explicit user permission.

**Default to Story tickets. NEVER create a Bug unless the user explicitly asks for one.** If the user doesn't specify a work item type, use `--type "Story"`. Don't infer "Bug" from words like "fix," "broken," or "crash" in the request — only use `--type "Bug"` when the user actually says they want a bug (or equivalent explicit ask).

**Link direction is counterintuitive and the tool doesn't confirm it — always verify after creating a link.** `acli`'s `--out`/`--in` flags do not map onto "outward"/"inward" the way their names suggest (confirmed backwards in practice — see Linking Work Items below). Never trust the flags or the success message; always re-view the issue's `issuelinks` field and confirm the direction reads the way the user asked before calling the task done.

**Always link a new or edited ticket to any other ticket you already know is related, including ones from earlier in the same session — this is not optional, and not something to wait for the user to request.** The goal is to leave breadcrumbs so a future reader can trace how tickets connect without being told separately. See Breadcrumb Links under Linking Work Items below for the two cases this covers and the exact command syntax.

**Always confirm labels before creating a ticket, and components if the project has that field. Use the structured question UI when available so the user picks from real values instead of free-typing; otherwise ask one concise plain-text question.** Don't guess or silently skip either. See Ticket Fields: Labels, Components, and QA Notes below for how to check whether Components applies to a given project, how to source real values for both prompts, and for the same field-existence check to run before deciding whether QA Notes goes in a dedicated custom field or just the description.

**Unless the user says otherwise, assign every ticket you create to the user and move it to `Refining`.**
Assign with the user's email from the `Email:` line of `acli jira auth status` (`--assignee "<email>"`, or `"assignee": "<email>"` in a `--from-json` payload).
Jira can't set status at creation, so run `acli jira workitem transition --key "KEY-1" --status "Refining" --yes` right after `create`.

**It's fine to transition a ticket to "In Progress" when you start work on it; only transition to "Done" (or any other terminal/complete status) when the user explicitly asks.** Marking something done is a visible, easy-to-get-wrong action — don't infer completion from context.

**Never run `acli jira project create`.** Project creation is out of scope for this skill and outside this skill's authorized command scope — see Projects below.

## Core Commands

### Searching Work Items

**Search by JQL (Jira Query Language)**
```bash
# Search with JQL query
acli jira workitem search --jql "project = TEAM AND status = 'In Progress'"

# Search with specific fields
acli jira workitem search --jql "assignee = currentUser()" --fields "key,summary,status,assignee"

# Get count of matching items
acli jira workitem search --jql "project = TEAM" --count

# Paginate through all results
acli jira workitem search --jql "project = TEAM" --paginate

# Output as JSON for parsing
acli jira workitem search --jql "project = TEAM" --json

# Output as CSV
acli jira workitem search --jql "project = TEAM" --csv
```

**Search by Filter ID**
```bash
acli jira workitem search --filter 10001
```

### Viewing Work Items

**View a specific work item**
```bash
# View with default fields
acli jira workitem view KEY-123

# View with specific fields
acli jira workitem view KEY-123 --fields "summary,description,status,assignee,comment"

# View all fields
acli jira workitem view KEY-123 --fields "*all"

# View as JSON
acli jira workitem view KEY-123 --json

# Open in web browser
acli jira workitem view KEY-123 --web
```

### Creating Work Items

**Create a new work item**
```bash
# Basic creation with summary (default type: Story — see Important Guidelines)
acli jira workitem create --summary "Add password reset flow" --project "PROJ" --type "Story"

# Only use --type "Bug" when the user explicitly asks for a bug ticket
acli jira workitem create --summary "Fix login crash on empty password" --project "PROJ" --type "Bug"

# Create with full details
acli jira workitem create \
  --summary "Implement user authentication" \
  --project "TEAM" \
  --type "Story" \
  --assignee "user@example.com" \
  --description "Add OAuth2 authentication flow" \
  --label "security,auth"

# Create and assign to self — use the user's email address; "@me" silently falls back to the project's default assignee instead of erroring
acli jira workitem create --summary "Review PR" --project "PROJ" --type "Task" --assignee "user@example.com"

# Assign to the project's configured default assignee
acli jira workitem create --summary "Triage inbound request" --project "PROJ" --type "Task" --assignee "default"

# Create with parent (for subtasks)
acli jira workitem create --summary "Write unit tests" --project "PROJ" --type "Subtask" --parent "PROJ-123"

# Create from file
acli jira workitem create --from-file "description.txt" --project "PROJ" --type "Story"

# Create from JSON
acli jira workitem create --from-json "workitem.json"

# Generate JSON template
acli jira workitem create --generate-json
```

### Editing Work Items

**Edit existing work items**
```bash
# Edit by key
acli jira workitem edit --key "KEY-1" --summary "Updated summary"

# Edit multiple items
acli jira workitem edit --key "KEY-1,KEY-2" --assignee "user@example.com"

# Edit by JQL query
acli jira workitem edit --jql "project = TEAM AND status = 'To Do'" --assignee "user@example.com"

# Edit description from file
acli jira workitem edit --key "KEY-1" --description-file "updated-desc.txt"

# Remove assignee
acli jira workitem edit --key "KEY-1" --remove-assignee

# Add/remove labels
acli jira workitem edit --key "KEY-1" --labels "bug,urgent"
acli jira workitem edit --key "KEY-1" --remove-labels "wontfix"

# Auto-confirm without prompting
acli jira workitem edit --key "KEY-1" --summary "New summary" --yes

# Edit from JSON
acli jira workitem edit --from-json "update.json"
```

### Ticket Fields: Labels, Components, and QA Notes

Before creating (or editing) a ticket, check these rather than guessing or silently omitting them:

**Labels — fixed org taxonomy of 4 values, always confirm with the user.** This is a closed set, not something to sample or guess at:
- `Roadmap` — planned work formally incorporated into the team's product/technical roadmap.
- `Maintenance` — planned work paying down tech debt or otherwise improving technical posture.
- `UnplannedWork` — unplanned work taken on outside planned capacity (post-incident fixes, urgent requests, etc.). May relate to Roadmap or Maintenance work, but track it separately — the point is visibility into work beyond expected capacity.
- `DevTested` — not a classification value; see below.

`Roadmap`, `Maintenance`, and `UnplannedWork` are mutually exclusive — every ticket gets exactly one. Confirm which one applies before creating (or editing) a ticket, unless the user already stated it: ask a single-select question, header "Work Type", and those three as options using the descriptions above. Don't infer this silently from ticket type or summary text, and don't propose labels outside this set.

`DevTested` is additive, not exclusive with the other three — it can be added alongside whichever of `Roadmap`/`Maintenance`/`UnplannedWork` already applies. It marks the ticket as using the dev-tested path instead of the QA workflow: an engineer adds it when moving the ticket to `In QA` status, in place of routing through QA, for low-risk, unit-tested, or hard-to-test work. Don't add it at ticket-creation time — prompt for it when the user is transitioning a ticket to `In QA` and indicates they (not QA) are testing it (see Transitioning Work Items below). When adding it, use `acli jira workitem edit --key KEY --labels "DevTested"`, which is additive and won't remove the existing classification label.

**Components — track the product "area" a ticket's work is in.** Confirm with the user only if the field exists on the project. Unlike labels (a fixed set you already know from above), valid component values are project-specific — Components also aren't enabled for every project. Check the project's actual component list — this doubles as the existence check and the source of real values:
```bash
acli jira project view --key PROJ --json
```
Look at the top-level `components` array. Empty means the project has no components configured — don't ask. Non-empty gives you the exact valid names (each entry's `name` field) — never guess or paraphrase one. Like the label set, this list is complete, so you always know the full option set even when a project has more components than the structured question UI can show at once. If present, `Other Domain` is a special value meaning the ticket's work belongs to another team's area, not this project's own ownership — treat it as a candidate whenever the ticket's content points outside the project's own domain.

**Infer a likely value from the ticket's summary/description, but always confirm with the user before creating — don't just pick your guess.** Limit the choice to exactly one component and label the question "Components". If there are 3 or fewer real components, offer them all as options. If there are more, first send a short plain-text message listing every valid component name, then limit the structured question to the 3 names — led with your best guess — that most plausibly match the ticket's content. Since the user already has the full list, they can accurately pick another value through the UI's free-form option instead of guessing at spelling. If structured input is unavailable, ask one concise plain-text question using the verified names.

**Setting the value has a real, hard-to-reverse side effect if the name is wrong — verified empirically, not documented anywhere in `acli`'s own help or `--generate-json` output:**
- Components can only be set at creation time, via `acli jira workitem create --from-json`, using the undocumented key `additionalAttributes.components: [{"name": "<exact component name>"}]`. A top-level `components` key is rejected outright (`json: unknown field "components"`), and `--generate-json` never shows this field at all — this nested form is the only way that works.
- **The name must exactly match one of the real values from `project view`, or the user's own explicit answer.** If it doesn't match any existing component, Jira silently creates a brand-new component with that exact name in the project and attaches it to the ticket — there's no `acli jira component` subcommand to delete it afterward, only the Jira web UI. A typo or a "close enough" guessed name permanently pollutes the project's component list, not just this one ticket. Never pass a name to `additionalAttributes.components` that didn't come directly from the user's answer or the verified `project view` list.
- If the user's answer doesn't match anything in the real list, that's a deliberate request to add a new component (the org does allow adding more as needed) — say so explicitly and confirm they mean to create a new one before proceeding, rather than silently letting a near-match typo through as if it were an existing value.
- **Components cannot be changed after creation.** `acli jira workitem edit --from-json` rejects both a top-level `components` key and an `additionalAttributes` wrapper as unknown fields — there is no edit-time path at all. If an existing ticket needs a component added or corrected, tell the user to do it manually in the Jira web UI; don't imply `acli` can fix it.

**QA Notes — use the dedicated custom field when one exists, not just the description section.** Some projects have a "QA Notes" (or similarly named) custom field on the create/edit screen, distinct from the QA Notes section in the Standard Ticket Template below. Check for it by viewing an existing ticket of the same type with `--fields "*all" --json` and looking for a `customfield_XXXXX` whose field name is QA Notes / Testing Notes / similar. If it exists:
- Populate it via `--from-json` as its own top-level key alongside `description` — match its actual format (plain string vs. ADF doc); don't assume it takes ADF just because `description` does.
- Leave testing guidance out of the description body once the dedicated field exists, so there's one source of truth instead of two copies that can drift.

If no such custom field exists for the project, fall back to the QA Notes section under the description, as in the Standard Ticket Template.

## Working with Descriptions: Atlassian Document Format (ADF)

**IMPORTANT:** Jira descriptions use **Atlassian Document Format (ADF)**, not markdown or plain text. When creating or editing ticket descriptions, you must use proper ADF JSON structure to ensure formatting is preserved and editable in the Jira UI.

### Why ADF Matters

- **Plain text** in descriptions will appear unformatted and break when edited in Jira UI
- **Markdown** is not supported and will display as raw text
- **ADF** is a JSON structure that preserves headings, lists, bold text, and other formatting

### Creating Tickets with ADF Descriptions

**IMPORTANT: Always verify the expected JSON schema with `acli jira workitem create --generate-json` before constructing a `--from-json` payload.** The correct top-level field names are `projectKey` (not `project`) and `parentIssueId` (not `parent`). Do NOT use Python or other tools to inspect the schema — use `--generate-json` directly.

**Always use `--from-json` with proper ADF structure for descriptions:**

```bash
# 1. Create ADF JSON file
cat > /tmp/ticket.json <<'EOF'
{
  "issues": ["PROJ-123"],
  "description": {
    "type": "doc",
    "version": 1,
    "content": [
      {
        "type": "paragraph",
        "content": [
          {
            "type": "text",
            "text": "Brief description of the ticket."
          }
        ]
      }
    ]
  }
}
EOF

# 2. Create or edit ticket using the JSON file
acli jira workitem create --from-json "/tmp/ticket.json"
acli jira workitem edit --from-json "/tmp/ticket.json" --yes
```

### Standard Ticket Template

Use this structure for all tickets:

1. **Brief description** - Concise but complete overview of the work. Ground it in specifics (relevant files, config, related tickets, dates) rather than generic language.
2. **Extra context sections** (h2/h3 headings, as needed) - If there's background, a design decision, or a domain rule the reader needs before the Acceptance Criteria make sense, give it its own headed section instead of folding it into the intro paragraph. Use h2 for a major section and h3 for its subsections.
3. **Acceptance Criteria** (h3 heading) - **Numbered** (ordered list). Each item should be specific and independently verifiable, not a vague one-liner — break multi-part requirements into nested sub-lists rather than cramming them into one bullet.
4. **Considerations** (h2 heading, only when there's a decision to be made) - Bullet list (not numbered) of open questions, tradeoffs, or things the implementer/reviewer needs to decide or watch for — e.g. scope boundaries, cross-references to related tickets or docs. Omit this section if there's nothing left undecided.
5. **QA Notes** (h3 heading, if applicable) - Testing guidance for QA, often broken into labeled scenarios (bold labels like "Feature:", "Regression:", "Repro:"). Check first whether the project has a dedicated QA Notes custom field (see Ticket Fields: Labels, Components, and QA Notes, above) — if it does, put this content there instead of in the description.

### ADF Structure Reference and Links

Full JSON shapes for paragraphs, headings, ordered/nested lists, and strong/code/link marks (including the ticket-link and GitHub-link examples) are in [ADF_REFERENCE.md](ADF_REFERENCE.md) — load it before hand-building a `--from-json` payload rather than guessing the shape from memory.

**Rules for links specifically** (see ADF_REFERENCE.md for the JSON shape):

- **Ticket links:** don't use `view`'s `self` field to get the host — confirmed empirically that on Jira Cloud it returns an internal REST host (e.g. `jira-prod-us-72-3.prod.atl-paas.net`) that differs from the real browsable site and produces a dead link. Instead run `acli jira auth status`, which prints the real `Site:` host (e.g. `yoursite.atlassian.net`), and build `https://<site>/browse/KEY`. Do this for every ticket key mentioned in a description instead of leaving it as plain text.
- **GitHub code links:** use a full commit SHA (`git rev-parse HEAD`), not a branch name, so the link keeps pointing at the exact lines even after the branch moves. Confirm the line range against the actual file before embedding it (`grep -n` or `sed -n '<range>p'`) — a link to the wrong lines is worse than no link. Only do this when it meaningfully helps the reader jump to the referenced behavior (a specific function, the exact failing branch) — not for every file mention.
- **Never fabricate either kind of URL.** Only build one from data you've actually confirmed this session: a real `self` field for Jira, a real SHA + grep-verified line numbers for GitHub. If you can't verify a host or line range, leave the reference as plain `code`-marked text instead of guessing a link.

### Complete Ticket Template Example

A full example payload assembling all of the above (summary, description with headings, nested acceptance criteria, considerations, QA notes) is in [ADF_REFERENCE.md](ADF_REFERENCE.md#complete-ticket-template-example).

### Best Practices for ADF Descriptions

1. **Always create ADF JSON in a temp file** (`/tmp/ticket-adf.json`)
2. **Use proper heading levels**: h3 for subsections, h2 for major sections
3. **Use ordered lists** for numbered requirements
4. **Use strong marks** for emphasis (bold text)
5. **Use `code` marks for every identifier** — function/module names, file names, column names, error/status strings (e.g. `reminder_label_id can't be blank`). Writing these as plain text is a common miss; a reader should be able to tell "this is a symbol from the codebase" at a glance.
6. **Link ticket keys and precise code references** instead of leaving them as bare text — see Links, above. Use a plain `link` mark, not `code` + `link` combined on the same text node — see the warning in ADF_REFERENCE.md.
7. **Keep the preamble tight** — one or two dense paragraphs stating the root cause and its consequence, not three-plus paragraphs that restate the same fact from different angles. Cut any sentence that doesn't add new information; ground claims in the specific file/line/column instead of generic description.
8. **Test formatting** by viewing ticket in web browser after creation
9. **Never use plain text** for `--description` or `--description-file` — both produce unformatted text; always use `--from-json` with ADF for anything that needs formatting

### Transitioning Work Items

**Transitioning to `In QA`: check for the dev-tested path.** If the user is skipping the QA workflow to test the ticket themselves (typically for low-risk, unit-tested, or hard-to-test work — see `DevTested` under Ticket Fields: Labels, Components, and QA Notes above), add the `DevTested` label alongside the transition:
```bash
acli jira workitem edit --key "KEY-1" --labels "DevTested"
acli jira workitem transition --key "KEY-1" --status "In QA"
```
Don't assume this path — if it's not already clear from context, ask before adding the label. Remind the user that the ticket still needs to move to `Testing Approved` once they've finished testing.

**Move work items between statuses**
```bash
# Transition by key
acli jira workitem transition --key "KEY-1" --status "In Progress"

# Transition multiple items
acli jira workitem transition --key "KEY-1,KEY-2" --status "Done"

# Transition by JQL query
acli jira workitem transition --jql "project = TEAM AND assignee = currentUser()" --status "In Review"

# Transition by filter
acli jira workitem transition --filter 10001 --status "Done" --yes
```

### Comments

**IMPORTANT: Only add comments when explicitly requested by the user.** `comment create` is outside this skill's default command scope, so creating one always requires your explicit approval at the permission prompt — never route around that (e.g. via a broader Bash allowance, or by batching it in with other already-approved commands).

**Add comments to work items** (only when user explicitly requests)
```bash
# Comment with inline text
acli jira workitem comment create --key "KEY-1" --body "This looks good to me"

# Comment from file
acli jira workitem comment create --key "KEY-1" --body-file "comment.txt"

# Comment on multiple items via JQL
acli jira workitem comment create --jql "project = TEAM" --body "Bulk update: reviewing all items"

# Edit last comment from same author
acli jira workitem comment create --key "KEY-1" --body "Updated comment" --edit-last

# List comments on work item
acli jira workitem comment list KEY-1
```

### Linking Work Items

**Breadcrumb links — create these proactively, without being asked:**
- **Bug caused by a known ticket:** if you're creating a bug and the ticket/change that introduced it is known (from conversation context, a commit, or a prior search), link the new bug as caused by that ticket using the `Problem/Incident` type (see direction rules below) before considering the ticket done.
- **Multiple tickets from one source:** if you create more than one ticket out of the same source issue, investigation, or reported behavior, link every pair of those new tickets to each other using `Relates` (or whatever the project's generic relation type is named — confirm with `acli jira workitem link type`), not just each one back to the source.

**Flags are `--out`/`--in`, not `--from`/`--to`** (confirmed via `acli jira workitem link create --help` — `--from`/`--to` are not real flags).

```bash
# Create link between items
acli jira workitem link create --out "KEY-1" --in "KEY-2" --type "Blocks"

# List all links for a work item
acli jira workitem link list KEY-1

# Get available link types (names only, e.g. "Blocks", "Problem/Incident" — no inward/outward wording)
acli jira workitem link type

# Delete a link — takes the numeric link id, not issue keys
acli jira workitem link delete --id 12345 --yes
```

**`--type` takes the link type's *name* (e.g. `"Blocks"`, `"Problem/Incident"`), not an inward/outward phrase** — despite `link create --help` claiming it "Accepts outward descriptions." Passing a phrase like `"causes"` or `"is caused by"` fails with `No issue link type with name '<phrase>' found`.

`acli jira workitem link type` only lists type names. To learn a type's actual inward/outward wording (e.g. that `Problem/Incident` has outward `"causes"` / inward `"is caused by"`), find an existing issue that already uses it and inspect its `issuelinks`:
```bash
acli jira workitem view SOME-KEY --fields "issuelinks" --json
```
Each entry has `type.inward`/`type.outward` plus either an `inwardIssue` or `outwardIssue` key naming the other issue. Read it as: "`<this issue>` `<type.inward or .outward, whichever key is present>` `<the named issue>`".

**`--out`/`--in` are inverted from what their names suggest — verified empirically, not documented anywhere.** For a type with inward `"is caused by"` / outward `"causes"`, to make `A` read as "**A** is caused by **B**", the working command is:
```bash
acli jira workitem link create --out "A" --in "B" --type "Problem/Incident" --yes
```
i.e. the issue that should read via the *inward* description goes in `--out`, and the one that reads via the *outward* description goes in `--in` — backwards from the flag names. Passing them the "intuitive" way (cause via `--out`, effect via `--in`) silently creates the reverse relationship instead of erroring.

**Always verify direction after creating — the success message doesn't tell you which side landed where:**
```bash
acli jira workitem view KEY-1 --fields "issuelinks" --json
```
Check which key (`inwardIssue` or `outwardIssue`) points at the other issue and read it against `type.inward`/`type.outward`. If it's backwards, delete and recreate with `--out`/`--in` swapped:
```bash
acli jira workitem link delete --id <link-id> --yes
acli jira workitem link create --out "B" --in "A" --type "Problem/Incident" --yes
```

### Projects

**List and view projects** (project creation is out of scope for this skill — see below)
```bash
# List recent projects
acli jira project list --recent

# List all projects with pagination
acli jira project list --paginate

# List with limit
acli jira project list --limit 50

# List as JSON
acli jira project list --json

# View specific project
acli jira project view PROJ
```

**Never run `acli jira project create`.** Creating a project is a heavier, harder-to-reverse action than anything else in this skill; it's outside this skill's authorized command scope. If a user wants a new project, point them to doing it directly in Jira rather than running the command yourself.

### Filters

**Work with saved Jira filters**
```bash
# Search for filters
acli jira filter search

# Use filter in searches
acli jira workitem search --filter 10001
```

## Common JQL Query Patterns

Use these JQL patterns for searching:

```
# Current user's work
assignee = currentUser()

# Specific project
project = TEAM

# Status queries
status = "In Progress"
status IN ("To Do", "In Progress")
status != Done

# Date queries
created >= -7d
updated >= startOfWeek()

# Combination queries
project = TEAM AND assignee = currentUser() AND status != Done
project = TEAM AND type = Bug AND priority = High
```

## Output Format Options

Most commands support multiple output formats:
- **Default**: Human-readable table format
- **--json**: JSON format for parsing
- **--csv**: CSV format for spreadsheet export
- **--web**: Open in web browser

## Error Handling

- Use `--ignore-errors` flag when bulk editing to continue on errors
- Use `--yes` flag to skip confirmation prompts in scripts
- Check exit codes for success/failure in automation
