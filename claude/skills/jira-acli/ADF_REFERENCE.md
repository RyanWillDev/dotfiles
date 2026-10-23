# ADF JSON Reference

Supporting reference for the `jira-acli` skill's ADF section in SKILL.md. Load this before hand-building a `--from-json` payload — don't guess the ADF shape from memory.

## ADF Structure Reference

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

**Links (other tickets, precise code lines, and other resources):**

Reference other tickets and specific code with real hyperlinks, not bare text.

**Never combine a `code` mark with a `link` mark on the same text node — confirmed empirically (not documented in Atlassian's ADF spec) to corrupt the ticket in the Jira web editor:** the node renders on view, but opening the ticket for editing breaks. When a piece of text needs to be both a code-styled identifier and a link, drop the `code` mark and keep only `link` — a plain hyperlink is better than a broken ticket:

```json
{
  "type": "text",
  "text": "some_function/2",
  "marks": [
    { "type": "link", "attrs": { "href": "https://github.com/ORG/REPO/blob/<full-sha>/path/to/file.ext#L10-L20" } }
  ]
}
```

A `link` mark alongside `strong` is fine — this issue is specific to pairing `code` with `link`.

```json
{
  "type": "text",
  "text": "PROJ-123",
  "marks": [
    { "type": "link", "attrs": { "href": "https://<jira-host>/browse/PROJ-123" } }
  ]
}
```

## Complete Ticket Template Example

```json
{
  "summary": "Implement feature X",
  "projectKey": "PROJ",
  "type": "Story",
  "parentIssueId": "PROJ-123",
  "assignee": "user@example.com",
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
          "level": 2
        },
        "content": [
          {
            "type": "text",
            "text": "Background"
          }
        ]
      },
      {
        "type": "paragraph",
        "content": [
          {
            "type": "text",
            "text": "Only add sections like this one when there's context, a design decision, or a domain rule the reader needs before the Acceptance Criteria make sense. Give each one its own heading rather than folding it into the intro paragraph. Omit entirely for simple tickets."
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
            "text": "Acceptance Criteria"
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
            "text": "Considerations"
          }
        ]
      },
      {
        "type": "bulletList",
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
          "level": 2
        },
        "content": [
          {
            "type": "text",
            "text": "Open Questions"
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
                    "text": "Should X apply to archived records too?"
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
                    "text": "Who owns the follow-up for Y?"
                  }
                ]
              }
            ]
          }
        ]
      }
    ]
  }
}
```
