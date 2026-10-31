# ADF JSON Reference

ADF shapes for `--from-json` descriptions, referenced from SKILL.md.

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

## Collapsible Sections (expand)

Use an `expand` node for supporting sections and the Agent Implementation Guide (see SKILL.md, Writing the description). The section name goes in `attrs.title`, not in a heading inside the node. The body is ordinary block content, and inline marks work as usual, so identifiers still get `code` marks rather than literal backticks:

```json
{
  "type": "expand",
  "attrs": { "title": "How it was confirmed" },
  "content": [
    {
      "type": "bulletList",
      "content": [
        {
          "type": "listItem",
          "content": [
            {
              "type": "paragraph",
              "content": [
                { "type": "text", "text": "The stack trace shows every worker blocked in " },
                { "type": "text", "text": "fetch_records/2", "marks": [{ "type": "code" }] },
                { "type": "text", "text": "." }
              ]
            }
          ]
        }
      ]
    }
  ]
}
```

Verified: `--from-json` accepts a top-level `expand`, and it renders and edits normally in the Jira web editor.

Placement rules (from the ADF schema):

- **Put `expand` directly in the doc's top-level `content`.** It can't go inside a list, a table cell, or another `expand`. Tables use the separate `nestedExpand` node, which this skill doesn't need.
- **Inside it, use paragraphs, bullet or ordered lists, headings, code blocks or tables.** One `expand` per supporting section. Don't wrap the whole description in one.

## Description skeleton

The top-level `content` order for a full ticket (see SKILL.md, Writing the description). Build each piece from the shapes above:

```
paragraph+                                   summary
heading(2) + blocks | expand(title)          context, one per section
heading(3) "Acceptance Criteria" + orderedList
heading(2) "Considerations" + bulletList     if any
expand("Agent Implementation Guide")         optional
heading(2) "Open Questions" + orderedList    if any
```
