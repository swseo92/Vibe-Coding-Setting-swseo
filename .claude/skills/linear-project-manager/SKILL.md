---
name: linear-project-manager
description: Manage Linear projects and issues using MCP integration. Use this skill when users request project-based task management in Linear, including creating/viewing/updating issues within specific projects. Provides comprehensive Linear usage guidance for beginners, including workflow best practices and MCP tool references.
---

# Linear Project Manager

## Overview

This skill enables project-centric Linear workflow management through MCP (Model Context Protocol) integration. It orchestrates multi-step Linear operations while providing contextual guidance for users unfamiliar with Linear's project management system.

**Key capabilities:**
- Project-based issue management (create, view, update)
- Structured workflows for common Linear operations
- Beginner-friendly Linear usage guidance
- MCP tool reference and examples

## When to Use This Skill

Activate this skill when users request:

- **Project management**: "Show me all projects" / "What projects do we have?"
- **Issue operations**: "Create a bug in project X" / "List issues in the mobile app project"
- **Issue updates**: "Change issue SWS-123 status to In Progress"
- **Linear guidance**: "How do I use Linear?" / "What's the difference between projects and issues?"
- **Workflow assistance**: "Walk me through creating a feature request"

**Trigger keywords**: Linear, project, issue, bug, task, feature request, sprint, milestone

## Core Workflows

### Workflow 1: Understanding Linear (For Beginners)

When users express unfamiliarity with Linear or ask basic questions:

1. **Load context** from `references/linear-basics.md`
2. **Explain relevant concepts** based on their question
3. **Show practical examples** using their workspace data
4. **Suggest next steps** for their workflow

**Example interaction:**
```
User: "I don't know how Linear works"
→ Read references/linear-basics.md
→ Explain projects, issues, states, and workflows
→ Show their current projects as examples
→ Suggest: "Would you like to create your first issue?"
```

### Workflow 2: Project-Based Issue Management

For creating, viewing, or updating issues within a specific project context:

#### 2.1 List Projects

1. Use MCP tool to fetch all projects
2. Display projects with key information (name, state, progress)
3. Ask which project to work with

#### 2.2 View Project Issues

1. Get project ID or name from user
2. Use MCP tool to fetch project issues
3. Display issues grouped by state (Todo, In Progress, Done)
4. Show issue identifiers, titles, assignees, priority

#### 2.3 Create Issue in Project

1. **Identify project** - Ask user or infer from context
2. **Gather issue details**:
   - Title (required)
   - Description (optional, use template from `assets/issue-templates/`)
   - Priority (optional: No Priority, Urgent, High, Medium, Low)
   - Assignee (optional)
   - Labels (optional)
3. **Use MCP tool** to create issue
4. **Confirm creation** with issue identifier and URL

**Template usage:**
- For bug reports: Use `assets/issue-templates/bug-report.md`
- For features: Use `assets/issue-templates/feature-request.md`
- For tasks: Use `assets/issue-templates/task.md`

Load templates into context when creating issues of those types to ensure consistent, well-structured descriptions.

#### 2.4 Update Issue

1. **Identify issue** by ID (e.g., "SWS-123") or title
2. **Determine update type**:
   - Status change (Todo → In Progress → Done)
   - Assignee change
   - Priority change
   - Description update
   - Add comment
3. **Use appropriate MCP tool** for the update
4. **Confirm changes** made

### Workflow 3: MCP Tool Discovery

When uncertain which Linear MCP tool to use:

1. **Consult** `references/mcp-tools-reference.md`
2. **Identify** the appropriate tool for the operation
3. **Review parameters** and examples
4. **Execute** with proper arguments

**Common tool patterns:**
- List operations: `mcp__linear__list_*`
- Create operations: `mcp__linear__create_*`
- Update operations: `mcp__linear__update_*`
- Search operations: `mcp__linear__search_*`

### Workflow 4: Best Practice Workflows

For users asking "how should I do X in Linear?":

1. **Load** `references/workflows.md`
2. **Identify** matching workflow pattern
3. **Guide user** through step-by-step process
4. **Execute** Linear operations as needed

## Reference Files

### `references/linear-basics.md`

Load when:
- User asks about Linear concepts
- User is unfamiliar with Linear terminology
- Explaining project/issue/state relationships

Contains:
- Linear core concepts (Projects, Issues, States, Labels)
- Terminology glossary
- Common workflows overview
- Team collaboration patterns

### `references/mcp-tools-reference.md`

Load when:
- Uncertain which MCP tool to use
- Need parameter details for a tool
- Want to see tool usage examples

Contains:
- Complete Linear MCP tool catalog
- Tool parameters and types
- Usage examples for each tool
- Common patterns and best practices

### `references/workflows.md`

Load when:
- User asks "how do I...?" questions
- Planning multi-step Linear operations
- Need best practice guidance

Contains:
- Project setup workflows
- Issue lifecycle management
- Team collaboration patterns
- Sprint/milestone planning guides

## Assets (Templates)

### `assets/issue-templates/`

Use when creating issues to ensure well-structured, complete descriptions:

- **`bug-report.md`**: Template for bug issues
  - Steps to reproduce
  - Expected vs actual behavior
  - Environment details

- **`feature-request.md`**: Template for feature issues
  - User story format
  - Acceptance criteria
  - Design considerations

- **`task.md`**: Template for task issues
  - Objective
  - Checklist
  - Dependencies

**Usage pattern:**
```
User: "Create a bug report for login issue"
→ Read assets/issue-templates/bug-report.md
→ Fill template with user-provided details
→ Create issue with structured description
```

## Best Practices

1. **Always work within project context** - Ask which project when ambiguous
2. **Use templates** for consistent issue quality
3. **Explain as you go** - Users are learning Linear
4. **Show, don't just tell** - Execute operations, not just describe them
5. **Leverage references** - Don't duplicate content, load as needed
6. **Confirm actions** - Always show what was created/updated

## Example Interactions

**Example 1: Create bug in project**
```
User: "Create a bug in the mobile app project: login button doesn't work"

Steps:
1. List projects to find "mobile app" project ID
2. Load assets/issue-templates/bug-report.md
3. Ask user for reproduction steps
4. Create issue with template-based description
5. Confirm: "Created issue MOB-45: Login button doesn't work"
```

**Example 2: View project status**
```
User: "What's the status of our web redesign project?"

Steps:
1. Find "web redesign" project
2. Fetch all project issues
3. Group by state (Todo: 12, In Progress: 5, Done: 23)
4. Highlight blockers or high-priority items
5. Suggest next actions
```

**Example 3: Linear beginner help**
```
User: "I'm new to Linear, how do I get started?"

Steps:
1. Read references/linear-basics.md
2. Explain: Projects contain Issues, Issues have States
3. Show their current projects as examples
4. Offer to create their first issue together
5. Reference references/workflows.md for next steps
```

## Limitations

- Cannot create new projects (admin operation, outside MCP scope)
- Cannot modify team permissions
- Cannot access archived projects by default
- MCP tools require valid Linear API authentication

For operations outside this skill's scope, guide users to Linear's web interface with specific instructions.
