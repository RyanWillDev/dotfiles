---
name: gh-cli
description: Use when working with GitHub repositories, pull requests, issues, reviews, or links to GitHub. Prefer the `gh` command-line tool for viewing, creating, and managing GitHub resources and for codebase research against remote repositories.
---

# GitHub CLI (gh) Skill

This skill enables interaction with GitHub using the `gh` command-line interface. Use this skill when users want to:
- View, search, and clone GitHub repositories
- Review, create, and manage pull requests
- Perform code reviews and view PR diffs
- View, create, and manage GitHub issues
- Research codebases hosted on GitHub
- Check CI/CD status and workflow runs
- Fetch and analyze code from GitHub repositories

## Prerequisites

The `gh` tool must be installed and authenticated. Users should have already run `gh auth login` to authenticate with GitHub.

## Important Guidelines

**NEVER create reviews, comments, or feedback in GitHub on the user's behalf.** When asked to review code or PRs:
1. Use gh commands to inspect the PR (view details, diffs, checks, files)
2. Analyze the code changes locally
3. Provide the review feedback directly to the user in the conversation
4. DO NOT use `gh pr review`, `gh pr comment`, or `gh issue comment` unless the user explicitly asks to post something to GitHub

The skill's role is to fetch and analyze GitHub content, then deliver insights to the user - not to post content back to GitHub.

## Core Commands

### Repository Operations

**View repository information**
```bash
# View current repository
gh repo view

# View specific repository
gh repo view owner/repo

# View repository in browser
gh repo view owner/repo --web

# View repository with JSON output
gh repo view owner/repo --json name,description,url,isPrivate,stargazerCount
```

**Clone repositories**
```bash
# Clone a repository
gh repo clone owner/repo

# Clone to specific directory
gh repo clone owner/repo /path/to/dir
```

**List repositories**
```bash
# List your repositories
gh repo list

# List repositories for a user/org
gh repo list owner

# List with filters
gh repo list owner --limit 50 --language python --json name,description,url

# List public repositories only
gh repo list owner --visibility public
```

**Fork repositories**
```bash
# Fork current repository
gh repo fork

# Fork specific repository
gh repo fork owner/repo

# Fork and clone
gh repo fork owner/repo --clone
```

**Repository settings**
```bash
# Set default repository for current directory
gh repo set-default owner/repo

# View repository settings
gh repo view --json defaultBranchRef,hasIssuesEnabled,hasWikiEnabled
```

### Pull Request Operations

**View pull requests**
```bash
# List PRs in current repository
gh pr list

# List PRs with filters
gh pr list --state open --label bug --author username

# List PRs with JSON output
gh pr list --json number,title,author,state,url

# View specific PR
gh pr view 123

# View PR with full details
gh pr view 123 --json title,body,author,state,reviews,comments

# View PR in browser
gh pr view 123 --web

# View PR diff
gh pr diff 123

# View PR with comments
gh pr view 123 --comments
```

**Create pull requests**
```bash
# Create PR interactively
gh pr create

# Create PR with title and body
gh pr create --title "Fix bug" --body "This fixes the authentication bug"

# Create PR and fill from commits
gh pr create --fill

# Create PR to specific branch
gh pr create --base main --head feature-branch

# Create draft PR
gh pr create --draft

# Create PR and open in browser
gh pr create --web
```

**Checkout pull requests**
```bash
# Checkout PR by number
gh pr checkout 123

# Checkout PR by branch name
gh pr checkout feature-branch

# Checkout PR by URL
gh pr checkout https://github.com/owner/repo/pull/123
```

**Inspect pull requests for review**

**When reviewing PRs, use these commands to inspect and analyze, then provide feedback to the user:**

```bash
# View PR checks/CI status
gh pr checks 123

# View existing PR reviews from others
gh pr view 123 --json reviews

# View PR files changed
gh pr view 123 --json files

# View PR diff to analyze code changes
gh pr diff 123

# Checkout PR locally for testing
gh pr checkout 123
```

**Post reviews to GitHub (only when explicitly requested by user):**
```bash
# Approve a PR (only when user explicitly requests)
gh pr review 123 --approve --body "Looks good"

# Request changes (only when user explicitly requests)
gh pr review 123 --request-changes --body "Please add tests"

# Add comment (only when user explicitly requests)
gh pr comment 123 --body "Great work!"
```

**Manage pull requests**
```bash
# Close PR
gh pr close 123

# Reopen PR
gh pr reopen 123

# Merge PR
gh pr merge 123

# Merge with specific strategy
gh pr merge 123 --squash
gh pr merge 123 --rebase
gh pr merge 123 --merge

# Merge and delete branch
gh pr merge 123 --delete-branch

# Mark draft PR as ready
gh pr ready 123

# Edit PR
gh pr edit 123 --title "New title" --body "New description"
```

### Issue Operations

**View issues**
```bash
# List issues
gh issue list

# List with filters
gh issue list --state open --label bug --assignee username

# List with JSON output
gh issue list --json number,title,author,state,labels

# View specific issue
gh issue view 456

# View issue with comments
gh issue view 456 --comments

# View issue in browser
gh issue view 456 --web
```

**Create issues**
```bash
# Create issue interactively
gh issue create

# Create with title and body
gh issue create --title "Bug report" --body "Description of the bug"

# Create with labels and assignees
gh issue create --title "Feature request" --label enhancement --assignee username

# Create and open in browser
gh issue create --web
```

**Manage issues**
```bash
# Close issue
gh issue close 456

# Reopen issue
gh issue reopen 456

# Edit issue
gh issue edit 456 --title "Updated title" --add-label bug

# Add comment (only when user explicitly requests)
gh issue comment 456 --body "Working on this now"

# Transfer issue to another repo
gh issue transfer 456 owner/other-repo
```

### Code Review Workflow

**Reviewing a PR comprehensively**

Use these commands to inspect the PR, then provide your review feedback directly to the user:

```bash
# 1. View PR details
gh pr view 123 --json title,body,author,labels,reviews

# 2. View the diff
gh pr diff 123

# 3. Check CI status
gh pr checks 123

# 4. View changed files
gh pr view 123 --json files

# 5. Checkout locally for testing
gh pr checkout 123
```

After inspection, provide your code review analysis directly to the user in the conversation. Do NOT post reviews to GitHub unless explicitly requested.

**Research workflow for PRs**
```bash
# Find PRs by author
gh pr list --author username

# Find PRs with specific label
gh pr list --label security

# Search for PRs with text
gh pr list --search "authentication"

# View all PR comments and reviews
gh pr view 123 --json comments,reviews
```

### GitHub Actions & Workflows

**View workflow runs**
```bash
# List workflow runs
gh run list

# List runs for specific workflow
gh run list --workflow ci.yml

# View specific run
gh run view 12345

# View run logs
gh run view 12345 --log

# Watch a run in real-time
gh run watch 12345

# Re-run a workflow
gh run rerun 12345

# Cancel a run
gh run cancel 12345
```

**View workflow files**
```bash
# List workflows
gh workflow list

# View workflow details
gh workflow view ci.yml

# Enable/disable workflow
gh workflow enable ci.yml
gh workflow disable ci.yml
```

### Search Operations

**Search repositories**
```bash
# Search for repositories
gh search repos "machine learning" --language python

# Search with filters
gh search repos "web framework" --stars ">1000" --language javascript

# Search with JSON output
gh search repos "react" --json name,description,stars,url --limit 10
```

**Search code**
```bash
# Search code in GitHub
gh search code "function authenticate" --repo owner/repo

# Search across multiple repos
gh search code "api endpoint" --owner owner

# Search with language filter
gh search code "class User" --language python
```

**Search issues and PRs**
```bash
# Search issues
gh search issues "bug" --repo owner/repo --state open

# Search PRs
gh search prs "feature" --repo owner/repo --author username
```

### API Access

**Make direct API calls**
```bash
# GET request
gh api repos/owner/repo

# GET with specific fields
gh api repos/owner/repo --jq '.stargazers_count'

# GET paginated results
gh api repos/owner/repo/issues --paginate

# POST request
gh api repos/owner/repo/issues --method POST --field title="New issue"

# Use with jq for parsing
gh api repos/owner/repo/pulls --jq '.[] | {number, title, state}'
```

### Status and Notifications

**Check GitHub status**
```bash
# View status of your work
gh status

# View notifications
gh api notifications
```

## Common Workflows

### Code Review Workflow

**When asked to review a PR:**

1. **Fetch PR details**:
   ```bash
   gh pr view 123 --json title,body,author,labels,state,reviewDecision
   ```

2. **View the code changes**:
   ```bash
   gh pr diff 123
   ```

3. **Check CI/test status**:
   ```bash
   gh pr checks 123
   ```

4. **View changed files**:
   ```bash
   gh pr view 123 --json files
   ```

5. **Checkout locally if needed for testing**:
   ```bash
   gh pr checkout 123
   # Run tests, lint, etc.
   ```

6. **Analyze the code and provide review feedback directly to the user**
   - DO NOT post the review to GitHub
   - Provide your analysis, findings, and recommendations in the conversation
   - Only if the user explicitly asks to post the review, use:
     ```bash
     gh pr review 123 --approve --body "Reviewed and approved"
     # or
     gh pr review 123 --request-changes --body "Please address these concerns"
     ```

### Repository Research Workflow

**When researching a codebase:**

1. **View repository overview**:
   ```bash
   gh repo view owner/repo --json description,languages,topics,url
   ```

2. **Clone repository**:
   ```bash
   gh repo clone owner/repo
   ```

3. **Check recent PRs and issues**:
   ```bash
   gh pr list --repo owner/repo --limit 10 --json number,title,author,createdAt
   gh issue list --repo owner/repo --limit 10 --json number,title,labels
   ```

4. **Search code for specific patterns**:
   ```bash
   gh search code "function name" --repo owner/repo
   ```

### Implementation from GitHub Issue

**When implementing a feature from an issue:**

1. **Fetch issue details**:
   ```bash
   gh issue view 456 --json title,body,labels,assignees
   ```

2. **Create branch and work on it**

3. **Create PR when ready**:
   ```bash
   gh pr create --title "Implement feature from #456" --body "Closes #456"
   ```

4. **Reference the issue in PR** (automatically closes issue when merged)

## Output Format Options

Most commands support multiple output formats:
- **Default**: Human-readable table/text format
- **--json**: JSON format for parsing (specify fields with --json field1,field2)
- **--jq**: Use jq expressions directly (requires --json)
- **--template**: Use Go templates for custom formatting
- **--web**: Open in web browser

## Integration with jq

For advanced JSON processing, combine gh with jq:

```bash
# Extract specific PR information
gh pr list --json number,title,author --jq '.[] | select(.author.login=="username")'

# Get PR numbers only
gh pr list --json number --jq '.[].number'

# Complex filtering and transformation
gh api repos/owner/repo/pulls --jq '.[] | {pr: .number, author: .user.login, status: .state}'
```

## Best Practices

1. **Use JSON output for parsing**: Add `--json` flag and specify fields for programmatic access
2. **Specify repositories**: Use `-R owner/repo` flag when not in a repository directory
3. **Filter at query time**: Use filters like `--state`, `--label`, `--author` instead of post-processing
4. **Paginate large results**: Use `--limit` to control result size
5. **Use --web for quick viewing**: Open items in browser with `--web` flag
6. **Check API limits**: Use `gh api rate_limit` to check remaining API calls

## Tips for Code Reviews

- Use `gh pr diff 123 > review.diff` to save diff for detailed review
- Combine with other tools: `gh pr diff 123 | grep "TODO"`
- Check file-specific changes: `gh pr view 123 --json files --jq '.files[].filename'`
- View only changed files: `gh pr diff 123 --name-only`

## Security Notes

- The gh tool requires authentication via `gh auth login`
- Credentials are stored securely by the CLI
- Use `gh auth status` to check authentication status
- For CI/CD, use `GITHUB_TOKEN` environment variable

## Error Handling

- Check if you're in a git repository: `gh repo view` will fail if not
- Specify repository explicitly with `-R owner/repo` flag
- Use `gh auth status` to verify authentication
- Check API rate limits: `gh api rate_limit`

## When to Use This Skill

Activate this skill whenever the user:
- Mentions GitHub, repos, repositories, or gh CLI
- Wants to review, create, or manage pull requests
- Needs to perform code reviews
- Wants to view or manage GitHub issues
- Needs to research or analyze GitHub codebases
- Mentions cloning or forking repositories
- Wants to check CI/CD status or GitHub Actions
- Needs to search code on GitHub
