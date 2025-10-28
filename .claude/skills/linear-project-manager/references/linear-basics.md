# Linear Basics: Core Concepts and Terminology

This document explains Linear's core concepts for beginners. Use this as context when users are unfamiliar with Linear or ask basic questions.

## What is Linear?

Linear is a project management tool designed for software development teams. It helps track work through **Issues** organized into **Projects** with customizable **Workflows**.

## Core Concepts

### 1. Workspaces

- **Definition**: Top-level container for your organization
- **Contains**: All teams, projects, and issues
- **Example**: "Acme Inc Workspace"

### 2. Teams

- **Definition**: Groups of people working together
- **Purpose**: Organize work by department, product, or function
- **Examples**: "Engineering", "Mobile Team", "Backend"
- **Key feature**: Each team has its own issue workflow states

### 3. Projects

**Definition**: Collections of related issues working toward a common goal

**Types**:
- **Timeboxed**: Projects with start/end dates (sprints, milestones)
- **Ongoing**: Continuous projects without deadlines

**Common uses**:
- Feature development ("Mobile App Redesign")
- Sprint planning ("Sprint 24 - Q1 2025")
- Epic tracking ("User Authentication System")
- Bug tracking ("Production Bugs - January")

**Project States**:
- **Planned**: Not yet started
- **Started**: Active work in progress
- **Paused**: Temporarily on hold
- **Completed**: Finished
- **Canceled**: Abandoned

**Key properties**:
- Name
- Description
- Lead (person responsible)
- Target date
- Progress (calculated from issue states)

### 4. Issues

**Definition**: Individual units of work (tasks, bugs, features)

**Anatomy of an Issue**:
- **Identifier**: Unique ID (e.g., "SWS-123")
  - Format: `{TEAM_KEY}-{NUMBER}`
  - Example: "ENG-456" = Engineering team, issue #456
- **Title**: Brief description
- **Description**: Detailed explanation (supports Markdown)
- **State**: Current status (see Workflow States below)
- **Assignee**: Person responsible
- **Priority**: Urgency level
- **Labels**: Tags for categorization
- **Project**: Parent project (optional)
- **Due Date**: Deadline (optional)

**Issue Hierarchy**:
```
Epic (Parent Issue)
  ├── Sub-issue 1
  ├── Sub-issue 2
  └── Sub-issue 3
```

### 5. Workflow States

**Definition**: Stages an issue progresses through

**Default workflow**:
1. **Backlog**: Unstarted, not prioritized
2. **Todo**: Ready to start, prioritized
3. **In Progress**: Active development
4. **In Review**: Code review / QA
5. **Done**: Completed
6. **Canceled**: Won't be done

**State types**:
- **Unstarted**: Backlog, Todo
- **Started**: In Progress, In Review
- **Completed**: Done
- **Canceled**: Canceled

**Custom states**: Teams can customize their workflow states

### 6. Priority Levels

- **Urgent**: Drop everything
- **High**: Do soon
- **Medium**: Normal priority
- **Low**: When there's time
- **No Priority**: Not yet prioritized (default)

### 7. Labels

- **Purpose**: Categorize and filter issues
- **Examples**: `bug`, `feature`, `technical-debt`, `frontend`, `backend`
- **Usage**: Issues can have multiple labels
- **Organization**: Help with reporting and filtering

### 8. Assignees

- **Definition**: Person(s) responsible for an issue
- **Single vs Multiple**: Issues typically have one assignee, but can have multiple
- **Unassigned**: Issues without an assignee are in the backlog

### 9. Comments

- **Purpose**: Discussion, updates, questions
- **Features**:
  - Markdown support
  - Mentions (@username)
  - File attachments
  - Code blocks

### 10. Cycles (Sprints)

- **Definition**: Fixed time periods for planning work (usually 1-2 weeks)
- **Purpose**: Structured iteration planning
- **Example**: "Cycle 24 - Jan 15-29"
- **Optional**: Not all teams use cycles

## Linear Workflow Overview

### Typical Issue Lifecycle

```
1. Create Issue
   ↓
2. Add to Project (optional)
   ↓
3. Prioritize (set priority, add to Todo)
   ↓
4. Assign to team member
   ↓
5. Move to In Progress (work starts)
   ↓
6. Move to In Review (code review)
   ↓
7. Move to Done (work complete)
```

### Project-Based Workflow

```
1. Create Project
   ↓
2. Add Issues to Project
   ↓
3. Track Progress (states, completion %)
   ↓
4. Complete Project when all issues done
```

## Key Terminology

| Term | Definition | Example |
|------|------------|---------|
| **Workspace** | Your organization's Linear account | "Acme Inc" |
| **Team** | Group within workspace | "Engineering" |
| **Project** | Collection of related issues | "Q1 Mobile Redesign" |
| **Issue** | Single unit of work | "Fix login button" |
| **State** | Current status of issue | "In Progress" |
| **Priority** | Importance level | "High" |
| **Label** | Category tag | "bug", "frontend" |
| **Assignee** | Responsible person | "@alice" |
| **Cycle** | Sprint / iteration | "Cycle 24" |
| **Identifier** | Unique issue ID | "ENG-123" |

## Common Questions

### Q: What's the difference between a Project and an Issue?
**A**: Projects are containers for related issues. Think of a project as a goal (e.g., "Launch mobile app") and issues as the individual tasks needed to achieve that goal (e.g., "Design login screen", "Implement authentication").

### Q: Do I need to use Projects?
**A**: No, projects are optional. You can manage issues without projects, but projects help organize work toward common goals.

### Q: What's the difference between Backlog and Todo?
**A**:
- **Backlog**: Issues that aren't ready or prioritized yet
- **Todo**: Issues that are prioritized and ready to work on

### Q: Can an issue belong to multiple projects?
**A**: No, an issue can only belong to one project at a time. Use labels or parent-child relationships for cross-project visibility.

### Q: What happens when I complete all issues in a project?
**A**: The project's progress will show 100%, and you can mark the project as "Completed" state.

## Best Practices for Beginners

1. **Start simple**: Create issues, assign them, track with states
2. **Use projects for goals**: Group issues working toward the same outcome
3. **Prioritize ruthlessly**: Not everything can be high priority
4. **Write clear titles**: Make issues understandable at a glance
5. **Add context**: Use descriptions for details, context, acceptance criteria
6. **Keep issues small**: Break large work into smaller, manageable issues
7. **Update states**: Keep issue states current for accurate project tracking
8. **Use labels consistently**: Establish team conventions for labeling

## Next Steps

After understanding these basics:
1. Explore your team's current projects
2. Create your first issue
3. Practice moving issues through states
4. Learn your team's specific workflows and conventions

## Resources

- **Linear Docs**: https://linear.app/docs
- **Keyboard Shortcuts**: Press `?` in Linear web app
- **API Docs**: https://developers.linear.app/docs
