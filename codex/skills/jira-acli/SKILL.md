---
name: jira-acli
description: Use when the user asks about Jira tickets, work items, project planning, or implementing work described in Jira. Prefer the `acli` command-line tool for searching, viewing, creating, editing, transitioning, and commenting on Jira items.
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
# Basic creation with summary
acli jira workitem create --summary "Fix login bug" --project "PROJ" --type "Bug"

# Create with full details
acli jira workitem create \
  --summary "Implement user authentication" \
  --project "TEAM" \
  --type "Story" \
  --assignee "user@example.com" \
  --description "Add OAuth2 authentication flow" \
  --label "security,auth"

# Create and assign to self
acli jira workitem create --summary "Review PR" --project "PROJ" --type "Task" --assignee "@me"

# Create with parent (for subtasks)
acli jira workitem create --summary "Write unit tests" --project "PROJ" --type "Subtask" --parent "PROJ-123"

# Create from file
acli jira workitem create --from-file "description.txt" --project "PROJ" --type "Bug"

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
acli jira workitem edit --jql "project = TEAM AND status = 'To Do'" --assignee "@me"

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

## Working with Descriptions: Atlassian Document Format (ADF)

**IMPORTANT:** Jira descriptions use **Atlassian Document Format (ADF)**, not markdown or plain text. When creating or editing ticket descriptions, you must use proper ADF JSON structure to ensure formatting is preserved and editable in the Jira UI.

### Why ADF Matters

- **Plain text** in descriptions will appear unformatted and break when edited in Jira UI
- **Markdown** is not supported and will display as raw text
- **ADF** is a JSON structure that preserves headings, lists, bold text, and other formatting

### Creating Tickets with ADF Descriptions

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

1. **Brief description** - Concise but complete overview of the work
2. **Acceptance Criteria** (h3 heading) - Ordered list of requirements
3. **Considerations** (h2 heading, if applicable) - Important implementation notes
4. **QA Notes** (h3 heading) - Testing guidance for QA team

### ADF Structure Reference

**Basic elements:**

```json
{
  "type": "doc",
  "version": 1,
  "content": [
    {
      "type": "paragraph",
      "content": [
        {
          "type": "text",
          "text": "Regular paragraph text"
        }
      ]
    },
    {
      "type": "heading",
      "attrs": {
        "level": 3
      },
      "content": [
        {
          "type": "text",
          "text": "Heading Text"
        }
      ]
    },
    {
      "type": "orderedList",
      "attrs": {
        "order": 1
      },
      "content": [
        {
          "type": "listItem",
          "content": [
            {
              "type": "paragraph",
              "content": [
                {
                  "type": "text",
                  "text": "List item text"
                }
              ]
            }
          ]
        }
      ]
    },
    {
      "type": "paragraph",
      "content": [
        {
          "type": "text",
          "text": "Bold text:",
          "marks": [
            {
              "type": "strong"
            }
          ]
        },
        {
          "type": "text",
          "text": " regular text"
        }
      ]
    }
  ]
}
```

**Nested lists:**

```json
{
  "type": "listItem",
  "content": [
    {
      "type": "paragraph",
      "content": [
        {
          "type": "text",
          "text": "Parent item"
        }
      ]
    },
    {
      "type": "orderedList",
      "attrs": {
        "order": 1
      },
      "content": [
        {
          "type": "listItem",
          "content": [
            {
              "type": "paragraph",
              "content": [
                {
                  "type": "text",
                  "text": "Nested item"
                }
              ]
            }
          ]
        }
      ]
    }
  ]
}
```

### Complete Ticket Template Example

```json
{
  "summary": "Implement feature X",
  "project": "PROJ",
  "type": "Story",
  "parent": "PROJ-123",
  "assignee": "@me",
  "description": {
    "type": "doc",
    "version": 1,
    "content": [
      {
        "type": "paragraph",
        "content": [
          {
            "type": "text",
            "text": "Implement feature X to improve user workflow. This feature allows users to..."
          }
        ]
      },
      {
        "type": "heading",
        "attrs": {
          "level": 3
        },
        "content": [
          {
            "type": "text",
            "text": "Acceptance Criteria:"
          }
        ]
      },
      {
        "type": "orderedList",
        "attrs": {
          "order": 1
        },
        "content": [
          {
            "type": "listItem",
            "content": [
              {
                "type": "paragraph",
                "content": [
                  {
                    "type": "text",
                    "text": "Requirement 1 is met"
                  }
                ]
              },
              {
                "type": "orderedList",
                "attrs": {
                  "order": 1
                },
                "content": [
                  {
                    "type": "listItem",
                    "content": [
                      {
                        "type": "paragraph",
                        "content": [
                          {
                            "type": "text",
                            "text": "Sub-requirement 1a"
                          }
                        ]
                      }
                    ]
                  }
                ]
              }
            ]
          },
          {
            "type": "listItem",
            "content": [
              {
                "type": "paragraph",
                "content": [
                  {
                    "type": "text",
                    "text": "Requirement 2 is met"
                  }
                ]
              }
            ]
          }
        ]
      },
      {
        "type": "heading",
        "attrs": {
          "level": 2
        },
        "content": [
          {
            "type": "text",
            "text": "Considerations:"
          }
        ]
      },
      {
        "type": "orderedList",
        "attrs": {
          "order": 1
        },
        "content": [
          {
            "type": "listItem",
            "content": [
              {
                "type": "paragraph",
                "content": [
                  {
                    "type": "text",
                    "text": "Database indexes needed on fields X, Y"
                  }
                ]
              }
            ]
          },
          {
            "type": "listItem",
            "content": [
              {
                "type": "paragraph",
                "content": [
                  {
                    "type": "text",
                    "text": "Impacts existing module Z - coordinate with team"
                  }
                ]
              }
            ]
          }
        ]
      },
      {
        "type": "heading",
        "attrs": {
          "level": 3
        },
        "content": [
          {
            "type": "text",
            "text": "QA Notes:"
          }
        ]
      },
      {
        "type": "paragraph",
        "content": [
          {
            "type": "text",
            "text": "Feature:",
            "marks": [
              {
                "type": "strong"
              }
            ]
          },
          {
            "type": "text",
            "text": " Test scenarios A, B, C. Verify edge case handling."
          }
        ]
      },
      {
        "type": "paragraph",
        "content": [
          {
            "type": "text",
            "text": "Regression:",
            "marks": [
              {
                "type": "strong"
              }
            ]
          },
          {
            "type": "text",
            "text": " Ensure existing feature Y still works correctly."
          }
        ]
      }
    ]
  }
}
```

### Best Practices for ADF Descriptions

1. **Always create ADF JSON in a temp file** (`/tmp/ticket-adf.json`)
2. **Use proper heading levels**: h3 for subsections, h2 for major sections
3. **Use ordered lists** for numbered requirements
4. **Use strong marks** for emphasis (bold text)
5. **Test formatting** by viewing ticket in web browser after creation
6. **Never use plain text** for `--description` flag - always use `--from-json` with ADF

### Common Mistakes to Avoid

❌ **DON'T** use `--description "text"` - creates unformatted plain text
❌ **DON'T** use markdown syntax - Jira doesn't support it
❌ **DON'T** use `--description-file` with markdown - still creates plain text

✅ **DO** use `--from-json` with proper ADF structure
✅ **DO** structure descriptions with standard template

### Transitioning Work Items

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

**IMPORTANT: Only add comments when explicitly requested by the user.**

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

**Create and manage links between work items**
```bash
# Create link between items
acli jira workitem link create --from "KEY-1" --to "KEY-2" --type "Blocks"

# List all links for a work item
acli jira workitem link list KEY-1

# Get available link types
acli jira workitem link type

# Delete a link
acli jira workitem link delete --from "KEY-1" --to "KEY-2"
```

### Projects

**List and manage projects**
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

# Create project
acli jira project create --key "NEWPROJ" --name "New Project" --type "software"
```

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

## Workflow Best Practices

### When Planning Feature Implementation

1. **Search for related work items**:
   ```bash
   acli jira workitem search --jql "project = PROJ AND text ~ 'feature-name'" --json
   ```

2. **View full details**:
   ```bash
   acli jira workitem view KEY-123 --fields "*all"
   ```

3. **Create implementation tasks if needed**:
   ```bash
   acli jira workitem create --summary "Implement X feature" --project "PROJ" --type "Task" --parent "KEY-123"
   ```

4. **Update status when starting work**:
   ```bash
   acli jira workitem transition --key "KEY-123" --status "In Progress"
   ```

### When Implementing Features Described in Jira

1. First, fetch the work item details to understand requirements
2. Parse JSON output for programmatic access
3. Update status to reflect current work (e.g., "In Progress")
4. Transition to "Done" when complete (only if explicitly requested)

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

## Tips

1. **Use JSON output** for parsing and automation: `--json`
2. **Paginate large result sets** to get all items: `--paginate`
3. **Filter fields** to reduce output: `--fields "key,summary,status"`
4. **Use JQL** for complex queries instead of filtering after fetch
5. **Self-assign with**: `--assignee "@me"`
6. **Default assignee**: `--assignee "default"`
7. **Read from files** for long descriptions: `--description-file` or `--from-file`
8. **Generate templates** with: `--generate-json`

## Security Notes

- The acli tool requires authentication via `acli jira auth`
- Credentials are stored securely by the CLI
- Ensure proper permissions before bulk operations
- Use `--yes` flag carefully in scripts to avoid unintended changes
