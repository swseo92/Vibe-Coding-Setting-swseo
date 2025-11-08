---
name: linear-project-manager
description: Manage Linear projects and issues using MCP integration and Linear API. Use this skill when users request project-based task management in Linear, including creating/viewing/updating issues within specific projects, or advanced operations like archiving, cycle management, and webhooks. Provides comprehensive Linear usage guidance for beginners, including workflow best practices, MCP tool references, and API integration patterns. Includes 8-week implementation roadmap for progressive automation (commit linking, metrics, retrospectives).
---

# Linear Project Manager

## Overview

This skill enables project-centric Linear workflow management through MCP (Model Context Protocol) integration and Linear GraphQL API. It orchestrates multi-step Linear operations while providing contextual guidance for users unfamiliar with Linear's project management system.

**Key capabilities:**
- Project-based issue management (create, view, update)
- Advanced operations via API (archive, delete, cycle management, webhooks)
- Structured workflows for common Linear operations
- Beginner-friendly Linear usage guidance
- MCP tool reference and API integration examples
- Hybrid workflows combining MCP + API strengths
- 8-week implementation roadmap for progressive automation

## When to Use This Skill

Activate this skill when users request:

- **Project management**: "Show me all projects" / "What projects do we have?"
- **Issue operations**: "Create a bug in project X" / "List issues in the mobile app project"
- **Issue updates**: "Change issue SWS-123 status to In Progress"
- **Linear guidance**: "How do I use Linear?" / "What's the difference between projects and issues?"
- **Workflow assistance**: "Walk me through creating a feature request"
- **Advanced operations**: "Archive completed issues" / "Delete issue SWS-456" / "Create a new sprint cycle"
- **API setup**: "How do I use Linear API?" / "Set up LINEAR_API_KEY"
- **Hybrid workflows**: "Archive all done issues and create next sprint"

**Trigger keywords**: Linear, project, issue, bug, task, feature request, sprint, milestone, archive, cycle, webhook, API

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

### Workflow 5: Linear API Operations

When users need operations not supported by MCP (archive, delete, cycles, webhooks):

1. **Determine operation type** - Consult `references/linear-api-guide.md` for MCP vs API decision
2. **Check LINEAR_API_KEY** - Validate environment variable is set
3. **Execute via linear-api-client.py**:
   - CLI: `python .claude/scripts/linear-api-client.py <resource> <action> --options`
   - Python: Import LinearAPIClient and call methods directly

**Common API-only operations:**

**Archive/Delete Issues:**
```bash
# Archive completed issue
python .claude/scripts/linear-api-client.py issue archive --id ISSUE-ID

# Delete issue permanently (30-day grace period)
python .claude/scripts/linear-api-client.py issue delete --id ISSUE-ID
```

**Cycle Management:**
```bash
# Create sprint cycle
python .claude/scripts/linear-api-client.py cycle create \
  --team TEAM-ID \
  --name "Sprint 42" \
  --starts-at "2025-11-09T00:00:00Z" \
  --ends-at "2025-11-23T00:00:00Z"

# Archive completed cycle
python .claude/scripts/linear-api-client.py cycle archive --id CYCLE-ID
```

**Webhook Integration:**
```bash
# Create webhook for Slack notifications
python .claude/scripts/linear-api-client.py webhook create \
  --url "https://hooks.slack.com/..." \
  --types Issue Comment \
  --label "Slack Alerts"
```

**Hybrid Workflow Example (MCP + API):**
1. Use MCP to find completed issues: `mcp__linear_server__list_issues(state="Done")`
2. Use API to archive them: `linear-api-client.py issue archive --id <each-id>`
3. Use MCP to create comment: `mcp__linear_server__create_comment(...)`

**When to use which:**
- **MCP**: Read operations, basic CRUD (create, update), comments
- **API**: Delete, archive, cycles, webhooks, attachments

Load `references/linear-api-guide.md` for comprehensive decision matrix and setup instructions.

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

### `references/linear-api-guide.md`

Load when:
- User needs operations beyond MCP capabilities (archive, delete, cycles, webhooks)
- Setting up LINEAR_API_KEY environment variable
- Deciding between MCP vs API for a specific operation
- Need hybrid workflow examples combining MCP + API

Contains:
- Complete MCP vs API comparison table
- LINEAR_API_KEY setup guide (manual + Playwright automation)
- Linear API client usage (CLI and Python)
- 13 resource types with 50+ API methods
- Hybrid workflow patterns (4 detailed examples)
- Troubleshooting guide (API keys, workspaces, GraphQL errors)
- Best practices for API integration

**Key sections:**
- "When to Use MCP vs API" - Decision matrix for choosing the right tool
- "Setup: LINEAR_API_KEY Environment Variable" - Complete setup instructions
- "Using Linear API Client" - CLI and Python code examples
- "Hybrid Workflows (MCP + API)" - Real-world patterns combining both approaches
- "Troubleshooting" - Common issues and solutions

### `references/label-guide.md`

Load when:
- User asks "어떤 라벨을 써야 하나?" or "What labels should I use?"
- Creating issues and uncertain which label to apply
- Need to understand when to use feature vs bug vs refactor
- Weekly label review (Week 1 Friday)

Contains:
- 5 core label types (type:feature, bug, refactor, docs, learning)
- When to use each label (scenarios and examples)
- Label combination guide (which combinations make sense)
- Best practices and anti-patterns
- Filtering techniques using labels
- Label evolution strategy (when to add new labels)
- Weekly label usage review template

**Key sections:**
- Each label type with detailed use cases
- "Label Combination Guide" - When to use multiple labels
- "Filtering with MCP" - Query patterns for label-based searches
- "Label Evolution Strategy" - When to add priority/status labels (Week 3+)
- "Weekly Label Review" - Analyze label usage patterns

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

**Example 4: Archive completed issues (Hybrid MCP + API)**
```
User: "Archive all completed issues from last sprint"

Steps:
1. Read references/linear-api-guide.md for hybrid workflow pattern
2. Validate LINEAR_API_KEY is set (check .env)
3. Use MCP to find completed issues:
   - mcp__linear_server__list_issues(state="Done", cycle="Sprint 41")
4. Use API to archive each issue:
   - python .claude/scripts/linear-api-client.py issue archive --id <issue-id>
5. Confirm: "Archived 23 issues from Sprint 41"
```

**Example 5: Create next sprint cycle**
```
User: "Create Sprint 42 starting next Monday for 2 weeks"

Steps:
1. Calculate dates (next Monday + 14 days)
2. Get team ID using MCP: mcp__linear_server__get_team(query="Backend Team")
3. Use API to create cycle:
   - python .claude/scripts/linear-api-client.py cycle create \
     --team TEAM-ID \
     --name "Sprint 42" \
     --starts-at "2025-11-11T00:00:00Z" \
     --ends-at "2025-11-25T00:00:00Z"
4. Confirm cycle creation with ID and dates
```

## Limitations

**MCP-only limitations (can be overcome with Linear API):**
- Cannot archive/delete issues (use API: `linear-api-client.py issue archive/delete`)
- Cannot create/manage cycles (use API: `linear-api-client.py cycle create/update/archive`)
- Cannot manage webhooks (use API: `linear-api-client.py webhook create/update/delete`)
- Cannot add/remove attachments (use API: `linear-api-client.py attachment create/delete`)
- Cannot update/delete comments (use API: `linear-api-client.py comment update/delete`)

**Persistent limitations (API also cannot do):**
- Cannot create new projects (requires admin permissions via web interface)
- Cannot modify team permissions (admin-only operation)
- Cannot customize workflow states (admin-only operation)

**Requirements:**
- MCP tools require valid Linear MCP authentication
- API operations require LINEAR_API_KEY environment variable

For admin operations, guide users to Linear's web interface with specific instructions. For operations beyond MCP, use the Linear API via Workflow 5.

## Implementation Roadmap

**This skill supports progressive automation through an 8-week implementation roadmap.**

Current workflows (1-5) focus on **manual Linear usage**. Future workflows will add **automated background processes** as you implement them.

### Roadmap Overview

**Week 1-2: Baseline (Current)**
- Establish CLI-centric workflow
- Daily reflection and pain point identification
- Baseline metrics: 55 min/day manual overhead

**Week 3-4: Commit Automation**
- Post-commit hook + background worker
- Auto-update Linear issues from commits
- Workflow 6 will be added after implementation

**Week 5-6: Metrics and Retrospectives**
- Daily metrics auto-collection
- Weekly retrospective automation
- Workflow 7 will be added after implementation

**Week 7-8: Refinement**
- AI matching tuning
- Metrics rotation
- Best practices documentation

### Roadmap Documents

Complete implementation guides are in the `roadmap/` folder:
- `roadmap/00-overview.md` - Full 8-week plan and architecture decisions
- `roadmap/01-week1-2-baseline.md` - Current week detailed guide
- `roadmap/02-week3-4-automation.md` - To be created after Week 2
- `roadmap/03-week5-6-metrics.md` - To be created after Week 4

### How This Skill Evolves

**Now (Manual workflows):**
- Workflow 1-5: Help users interact with Linear manually via MCP/API

**Week 3-4 (After commit automation):**
- Add Workflow 6: Guide background processes for commit linking
- Update examples with automation scenarios

**Week 5-6 (After metrics automation):**
- Add Workflow 7: Guide metrics collection and retrospectives
- Update references with automation patterns

**Week 7-8 (After refinement):**
- Document best practices learned from 6 weeks of usage
- Finalize automation tuning guidelines

This progressive approach ensures the skill stays synchronized with your actual implementation progress.
