# Linear MCP Tools Reference

This document catalogs all available Linear MCP tools, their parameters, and usage examples. Consult this when selecting which tool to use for a specific operation.

## Tool Naming Convention

Linear MCP tools follow the pattern: `mcp__linear__{action}_{entity}`

- **Action**: `list`, `get`, `create`, `update`, `delete`, `search`
- **Entity**: `projects`, `issues`, `teams`, `comments`, etc.

## Quick Reference Table

| Task | Tool | Common Parameters |
|------|------|-------------------|
| List all projects | `mcp__linear__list_projects` | team_id (optional) |
| Get project details | `mcp__linear__get_project` | project_id |
| List issues | `mcp__linear__list_issues` | project_id, team_id, state |
| Create issue | `mcp__linear__create_issue` | title, description, project_id |
| Update issue | `mcp__linear__update_issue` | issue_id, state, assignee_id |
| Search issues | `mcp__linear__search_issues` | query, project_id |
| List teams | `mcp__linear__list_teams` | - |
| Add comment | `mcp__linear__create_comment` | issue_id, body |

## Project Tools

### `mcp__linear__list_projects`

**Purpose**: Retrieve all projects in the workspace

**Parameters**:
```json
{
  "team_id": "string (optional)",
  "state": "string (optional)", // "planned", "started", "paused", "completed", "canceled"
  "include_archived": "boolean (optional, default: false)"
}
```

**Returns**: Array of projects with:
- `id`: Project ID
- `name`: Project name
- `description`: Project description
- `state`: Current state
- `progress`: Completion percentage
- `lead_id`: Project lead user ID
- `target_date`: Target completion date
- `created_at`: Creation timestamp

**Example**:
```javascript
// List all active projects
mcp__linear__list_projects({})

// List projects for specific team
mcp__linear__list_projects({ team_id: "team_123" })

// List only started projects
mcp__linear__list_projects({ state: "started" })
```

### `mcp__linear__get_project`

**Purpose**: Get detailed information about a specific project

**Parameters**:
```json
{
  "project_id": "string (required)"
}
```

**Returns**: Project object with:
- All fields from `list_projects`
- `issue_count`: Total number of issues
- `completed_issue_count`: Number of completed issues
- `members`: Array of team member IDs

**Example**:
```javascript
mcp__linear__get_project({ project_id: "proj_abc123" })
```

## Issue Tools

### `mcp__linear__list_issues`

**Purpose**: Retrieve issues with filtering options

**Parameters**:
```json
{
  "project_id": "string (optional)",
  "team_id": "string (optional)",
  "assignee_id": "string (optional)",
  "state": "string (optional)", // "backlog", "todo", "in_progress", "in_review", "done", "canceled"
  "priority": "number (optional)", // 0=None, 1=Urgent, 2=High, 3=Medium, 4=Low
  "label_ids": "array of strings (optional)",
  "limit": "number (optional, default: 50)"
}
```

**Returns**: Array of issues with:
- `id`: Issue ID
- `identifier`: Human-readable ID (e.g., "ENG-123")
- `title`: Issue title
- `description`: Issue description
- `state`: Current state
- `priority`: Priority level
- `assignee_id`: Assigned user ID
- `project_id`: Parent project ID
- `created_at`: Creation timestamp
- `updated_at`: Last update timestamp

**Example**:
```javascript
// List all issues in a project
mcp__linear__list_issues({ project_id: "proj_abc123" })

// List my assigned issues that are in progress
mcp__linear__list_issues({
  assignee_id: "user_xyz",
  state: "in_progress"
})

// List high-priority bugs
mcp__linear__list_issues({
  priority: 2,
  label_ids: ["label_bug"]
})
```

### `mcp__linear__get_issue`

**Purpose**: Get detailed information about a specific issue

**Parameters**:
```json
{
  "issue_id": "string (required)"
}
```

**Alternative** (by identifier):
```json
{
  "identifier": "string (required)" // e.g., "ENG-123"
}
```

**Returns**: Issue object with:
- All fields from `list_issues`
- `comments`: Array of comment objects
- `attachments`: Array of attachment objects
- `children`: Array of sub-issue IDs
- `parent_id`: Parent issue ID (if sub-issue)

**Example**:
```javascript
mcp__linear__get_issue({ issue_id: "issue_123" })
mcp__linear__get_issue({ identifier: "ENG-123" })
```

### `mcp__linear__create_issue`

**Purpose**: Create a new issue

**Parameters**:
```json
{
  "title": "string (required)",
  "description": "string (optional)",
  "team_id": "string (required)",
  "project_id": "string (optional)",
  "assignee_id": "string (optional)",
  "priority": "number (optional)", // 0=None, 1=Urgent, 2=High, 3=Medium, 4=Low
  "state_id": "string (optional)", // defaults to team's default state
  "label_ids": "array of strings (optional)",
  "parent_id": "string (optional)", // for creating sub-issues
  "due_date": "string (optional)" // ISO 8601 format
}
```

**Returns**: Created issue object

**Example**:
```javascript
// Create simple bug issue
mcp__linear__create_issue({
  title: "Login button not working",
  description: "Users cannot click the login button on mobile",
  team_id: "team_eng",
  project_id: "proj_mobile",
  priority: 2, // High
  label_ids: ["label_bug", "label_mobile"]
})

// Create assigned feature
mcp__linear__create_issue({
  title: "Add dark mode support",
  description: "Implement dark mode theme throughout the app",
  team_id: "team_frontend",
  assignee_id: "user_alice",
  priority: 3 // Medium
})
```

### `mcp__linear__update_issue`

**Purpose**: Update an existing issue

**Parameters**:
```json
{
  "issue_id": "string (required)",
  "title": "string (optional)",
  "description": "string (optional)",
  "state_id": "string (optional)",
  "assignee_id": "string (optional)",
  "priority": "number (optional)",
  "project_id": "string (optional)",
  "label_ids": "array of strings (optional)"
}
```

**Returns**: Updated issue object

**Example**:
```javascript
// Move issue to in progress
mcp__linear__update_issue({
  issue_id: "issue_123",
  state_id: "state_in_progress"
})

// Change assignee and priority
mcp__linear__update_issue({
  issue_id: "issue_123",
  assignee_id: "user_bob",
  priority: 1 // Urgent
})

// Add to project
mcp__linear__update_issue({
  issue_id: "issue_123",
  project_id: "proj_sprint24"
})
```

### `mcp__linear__search_issues`

**Purpose**: Full-text search across issues

**Parameters**:
```json
{
  "query": "string (required)",
  "team_id": "string (optional)",
  "project_id": "string (optional)",
  "limit": "number (optional, default: 25)"
}
```

**Returns**: Array of matching issues

**Example**:
```javascript
// Search for issues mentioning "authentication"
mcp__linear__search_issues({ query: "authentication" })

// Search within specific project
mcp__linear__search_issues({
  query: "login bug",
  project_id: "proj_mobile"
})
```

## Team Tools

### `mcp__linear__list_teams`

**Purpose**: Retrieve all teams in the workspace

**Parameters**: None

**Returns**: Array of teams with:
- `id`: Team ID
- `key`: Team key (e.g., "ENG")
- `name`: Team name
- `description`: Team description

**Example**:
```javascript
mcp__linear__list_teams({})
```

### `mcp__linear__get_team`

**Purpose**: Get detailed information about a specific team

**Parameters**:
```json
{
  "team_id": "string (required)"
}
```

**Returns**: Team object with workflow states

**Example**:
```javascript
mcp__linear__get_team({ team_id: "team_eng" })
```

## Comment Tools

### `mcp__linear__create_comment`

**Purpose**: Add a comment to an issue

**Parameters**:
```json
{
  "issue_id": "string (required)",
  "body": "string (required)", // Markdown supported
  "create_as_user": "boolean (optional, default: false)"
}
```

**Returns**: Created comment object

**Example**:
```javascript
mcp__linear__create_comment({
  issue_id: "issue_123",
  body: "I've started working on this. ETA: 2 days."
})

// Comment with mentions and code
mcp__linear__create_comment({
  issue_id: "issue_123",
  body: "@alice Can you review this approach?\n\n```python\ndef fix_login():\n    pass\n```"
})
```

## User Tools

### `mcp__linear__list_users`

**Purpose**: Retrieve all users in the workspace

**Parameters**:
```json
{
  "team_id": "string (optional)" // filter by team membership
}
```

**Returns**: Array of users with:
- `id`: User ID
- `name`: Full name
- `email`: Email address
- `display_name`: Display name

**Example**:
```javascript
mcp__linear__list_users({})
mcp__linear__list_users({ team_id: "team_eng" })
```

## Label Tools

### `mcp__linear__list_labels`

**Purpose**: Retrieve all labels in the workspace

**Parameters**:
```json
{
  "team_id": "string (optional)"
}
```

**Returns**: Array of labels with:
- `id`: Label ID
- `name`: Label name
- `color`: Label color hex code

**Example**:
```javascript
mcp__linear__list_labels({})
```

## Workflow State Tools

### `mcp__linear__list_workflow_states`

**Purpose**: Retrieve workflow states for a team

**Parameters**:
```json
{
  "team_id": "string (required)"
}
```

**Returns**: Array of workflow states with:
- `id`: State ID
- `name`: State name (e.g., "In Progress")
- `type`: State type ("unstarted", "started", "completed", "canceled")
- `position`: Sort order

**Example**:
```javascript
mcp__linear__list_workflow_states({ team_id: "team_eng" })
```

## Common Patterns

### Pattern 1: Project-Scoped Operations

```javascript
// 1. Get project
const project = mcp__linear__get_project({ project_id: "proj_123" })

// 2. List project issues
const issues = mcp__linear__list_issues({ project_id: "proj_123" })

// 3. Create issue in project
mcp__linear__create_issue({
  title: "New feature",
  team_id: project.team_id,
  project_id: "proj_123"
})
```

### Pattern 2: State Transitions

```javascript
// 1. Get team's workflow states
const states = mcp__linear__list_workflow_states({ team_id: "team_eng" })

// 2. Find target state
const inProgressState = states.find(s => s.name === "In Progress")

// 3. Update issue state
mcp__linear__update_issue({
  issue_id: "issue_123",
  state_id: inProgressState.id
})
```

### Pattern 3: User Assignment

```javascript
// 1. List team users
const users = mcp__linear__list_users({ team_id: "team_eng" })

// 2. Find user
const alice = users.find(u => u.email === "alice@example.com")

// 3. Assign issue
mcp__linear__update_issue({
  issue_id: "issue_123",
  assignee_id: alice.id
})
```

## Error Handling

Common error responses:

- **404 Not Found**: Entity doesn't exist or no access
- **400 Bad Request**: Invalid parameters
- **403 Forbidden**: Insufficient permissions
- **429 Too Many Requests**: Rate limit exceeded

Always handle these gracefully and provide user-friendly error messages.

## Rate Limits

Linear API has rate limits:
- **Authenticated requests**: 1000/hour
- **Burst limit**: 100/minute

Implement exponential backoff for retries if rate limited.

## Best Practices

1. **Batch operations**: Use list endpoints instead of multiple get calls
2. **Cache team/user data**: These rarely change, cache for session
3. **Use identifiers**: Prefer issue identifiers (e.g., "ENG-123") for user-facing operations
4. **Include context**: When creating issues, always provide description and project
5. **Check permissions**: Verify user has access before operations
6. **Handle states properly**: Use team's actual workflow states, don't hardcode

## Debugging Tips

1. **Check IDs**: Ensure team_id, project_id, etc. are valid
2. **Verify permissions**: User must have access to entities
3. **Test incrementally**: Try operations in sequence to isolate failures
4. **Log responses**: Inspect actual tool responses for debugging
5. **Use search**: When uncertain, search issues to find examples
