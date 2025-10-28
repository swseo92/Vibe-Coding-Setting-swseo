# Linear Workflows and Best Practices

This document provides step-by-step workflows for common Linear operations. Use this when users ask "how do I...?" questions or need guidance on best practices.

## Quick Start Workflows

### Workflow 1: Your First Issue

**Scenario**: Brand new to Linear, want to create your first task

**Steps**:
1. **Choose a team**: Find which team you're on
   ```
   → Use mcp__linear__list_teams
   → Identify your team by name or ask user
   ```

2. **Create a simple issue**:
   ```
   → Use mcp__linear__create_issue with:
     - title: "My first task"
     - description: "Testing Linear"
     - team_id: (from step 1)
   ```

3. **View your issue**:
   ```
   → Note the identifier (e.g., "ENG-1")
   → Share the identifier with user
   → Explain: "This is your issue number. You can reference it anywhere."
   ```

**Next steps**: Move it to "In Progress", add a comment, mark as done

### Workflow 2: Check Your Work

**Scenario**: "What am I working on?" / "Show my tasks"

**Steps**:
1. **Get user ID**: Usually available from context or ask
2. **List assigned issues**:
   ```
   → Use mcp__linear__list_issues with:
     - assignee_id: (user's ID)
     - state: "in_progress" (for active work)
   ```

3. **Display results**: Group by project, show priorities

**Variations**:
- All my work (any state): Omit `state` parameter
- Just my backlog: `state: "todo"`
- Recently completed: `state: "done"` + filter by date

## Project Management Workflows

### Workflow 3: Start a New Project

**Scenario**: "Let's plan the mobile app redesign project"

**Steps**:
1. **Note**: Projects can only be created through Linear UI (not MCP)
   - Guide user to Linear web/desktop app
   - Or work with existing projects

2. **Once project exists, populate it**:
   ```
   → Get project ID: mcp__linear__get_project or mcp__linear__list_projects
   → Create issues with project_id
   ```

3. **Structure the work**:
   - Break down into epics (parent issues)
   - Create sub-issues for each epic
   - Set priorities and assignments

**Best practices**:
- Start with 5-10 high-level issues
- Break down further as needed
- Assign a project lead

### Workflow 4: Track Project Progress

**Scenario**: "How's the Q1 launch project doing?"

**Steps**:
1. **Find the project**:
   ```
   → Use mcp__linear__search_issues or mcp__linear__list_projects
   → Identify by name match
   ```

2. **Get project details**:
   ```
   → Use mcp__linear__get_project with project_id
   → Note: progress, target_date, state
   ```

3. **List project issues**:
   ```
   → Use mcp__linear__list_issues with project_id
   → Group by state (backlog, todo, in_progress, done)
   ```

4. **Analyze and report**:
   ```
   Summary:
   - Progress: 45% complete (12/27 issues done)
   - In Progress: 5 issues
   - Blocked: 2 high-priority items
   - Target: Feb 15 (2 weeks away)
   ```

**Insights to provide**:
- Completion percentage
- Issues at risk (high priority + not started)
- Recently completed work
- Upcoming due dates

### Workflow 5: Sprint/Milestone Planning

**Scenario**: "Let's plan Sprint 24"

**Steps**:
1. **Create a project** (or use existing sprint structure)
2. **Review backlog**:
   ```
   → Use mcp__linear__list_issues with:
     - team_id: (team)
     - state: "backlog" or "todo"
     - No project_id (unassigned issues)
   ```

3. **Prioritize and assign to sprint**:
   ```
   For each issue to include:
   → mcp__linear__update_issue with:
     - project_id: (sprint project)
     - state_id: "todo"
     - assignee_id: (team member)
     - priority: (based on discussion)
   ```

4. **Capacity check**:
   - Count issues per person
   - Estimate story points if used
   - Warn if overloaded

**Best practices**:
- Include stretch goals
- Leave buffer for bugs
- Have a clear sprint goal

## Issue Management Workflows

### Workflow 6: Create a Well-Structured Issue

**Scenario**: "We need to fix the login bug properly documented"

**Steps**:
1. **Choose issue type**: Bug, feature, or task
2. **Use appropriate template**:
   ```
   For bugs:
   → Read assets/issue-templates/bug-report.md
   → Fill template sections with user input

   For features:
   → Read assets/issue-templates/feature-request.md
   → Use user story format

   For tasks:
   → Read assets/issue-templates/task.md
   → Break down into checklist
   ```

3. **Gather metadata**:
   - **Team**: Which team owns this?
   - **Project**: Does this belong to a specific project?
   - **Priority**: How urgent? (Ask if unclear)
   - **Assignee**: Who should work on this? (Can be unassigned)
   - **Labels**: bug, feature, backend, frontend, etc.

4. **Create the issue**:
   ```
   → Use mcp__linear__create_issue with all gathered info
   ```

5. **Confirm and link**:
   ```
   "Created ENG-234: Fix login button on mobile
   Priority: High
   Assigned to: Alice
   View: linear.app/issue/ENG-234"
   ```

**Quality checklist**:
- [ ] Clear, actionable title
- [ ] Context in description
- [ ] Acceptance criteria (for features)
- [ ] Steps to reproduce (for bugs)
- [ ] Appropriate labels

### Workflow 7: Update Issue Progress

**Scenario**: "I'm starting work on ENG-123"

**Steps**:
1. **Get current issue state**:
   ```
   → Use mcp__linear__get_issue with identifier "ENG-123"
   → Check current state
   ```

2. **Get workflow states** (if needed):
   ```
   → Use mcp__linear__list_workflow_states for team
   → Find "In Progress" state ID
   ```

3. **Update issue**:
   ```
   → Use mcp__linear__update_issue with:
     - issue_id: (from step 1)
     - state_id: (In Progress state)
     - assignee_id: (user, if not already assigned)
   ```

4. **Optional: Add comment**:
   ```
   → Use mcp__linear__create_comment with:
     - issue_id
     - body: "Starting work on this now. ETA: 2 days."
   ```

**State transition guide**:
- Backlog → Todo: "I'll work on this soon"
- Todo → In Progress: "Starting now"
- In Progress → In Review: "Ready for review"
- In Review → Done: "Approved and merged"
- Any → Canceled: "Won't do this"

### Workflow 8: Triage New Issues

**Scenario**: "Let's go through the backlog and prioritize"

**Steps**:
1. **List unprioritized issues**:
   ```
   → Use mcp__linear__list_issues with:
     - state: "backlog"
     - priority: 0 (No Priority)
   ```

2. **For each issue**:
   ```
   a. Review title and description
   b. Ask: "Is this urgent, high, medium, or low priority?"
   c. Ask: "Should this be assigned to anyone?"
   d. Ask: "Does this belong to a project?"

   → Update with mcp__linear__update_issue
   ```

3. **Move to Todo when ready**:
   ```
   → Change state to "todo" for items ready to work on
   ```

**Prioritization framework**:
- **Urgent**: Production bugs, blockers
- **High**: Sprint commitments, customer requests
- **Medium**: Normal feature work
- **Low**: Nice-to-haves, tech debt
- **No Priority**: Needs more discussion

## Team Collaboration Workflows

### Workflow 9: Hand Off Work

**Scenario**: "Alice, can you take over this issue?"

**Steps**:
1. **Get issue**:
   ```
   → Use mcp__linear__get_issue
   ```

2. **Find new assignee**:
   ```
   → Use mcp__linear__list_users
   → Find Alice's user ID
   ```

3. **Update assignment**:
   ```
   → Use mcp__linear__update_issue with:
     - assignee_id: (Alice)
   ```

4. **Add context comment**:
   ```
   → Use mcp__linear__create_comment with:
     - body: "@alice Taking over this one. Current status: 50% done. Next step: implement API endpoint."
   ```

**Handoff checklist**:
- [ ] Update assignee
- [ ] Add handoff comment with context
- [ ] Share relevant links/docs
- [ ] Update state if needed

### Workflow 10: Request Review

**Scenario**: "This is ready for code review"

**Steps**:
1. **Move to review state**:
   ```
   → Get team's "In Review" state
   → Update issue state
   ```

2. **Add review comment**:
   ```
   → Create comment with:
     - PR link
     - What to review
     - Any context needed
     - Mention reviewer (@reviewer)
   ```

**Review comment template**:
```markdown
Ready for review! @alice

**Changes:**
- Implemented login flow
- Added unit tests
- Updated documentation

**PR:** https://github.com/org/repo/pull/123

**Testing:** Follow steps in PR description
```

## Reporting Workflows

### Workflow 11: Generate Progress Report

**Scenario**: "What did the team accomplish this week?"

**Steps**:
1. **Define time range**: Usually last 7 days
2. **List completed issues**:
   ```
   → Use mcp__linear__list_issues with:
     - team_id
     - state: "done"
     - Filter by updated_at in application logic
   ```

3. **Group and summarize**:
   ```
   Completed this week (12 issues):
   - Features (4): [list titles]
   - Bugs (6): [list titles]
   - Tasks (2): [list titles]

   By project:
   - Mobile Redesign: 5 issues
   - API v2: 4 issues
   - Bug fixes: 3 issues
   ```

4. **Highlight key wins**: Pick most impactful completions

**Report variations**:
- Daily standup: Today's progress
- Weekly summary: Week's achievements
- Sprint retrospective: Sprint stats
- Monthly review: Trends and metrics

### Workflow 12: Find Related Work

**Scenario**: "Show me all login-related issues"

**Steps**:
1. **Search issues**:
   ```
   → Use mcp__linear__search_issues with:
     - query: "login"
   ```

2. **Refine if needed**:
   ```
   → Add filters:
     - project_id: (if scoped to project)
     - team_id: (if scoped to team)
   ```

3. **Organize results**:
   ```
   Found 8 login-related issues:

   Open (3):
   - ENG-234: Fix login button [High, In Progress]
   - ENG-189: Add SSO login [Medium, Todo]
   - ENG-156: Login audit logs [Low, Backlog]

   Completed (5):
   - [list completed work]
   ```

**Search tips**:
- Use specific keywords
- Search within project for focused results
- Look at labels for categorization

## Advanced Workflows

### Workflow 13: Epic Management

**Scenario**: "Let's track the auth system epic"

**Steps**:
1. **Create parent issue** (the epic):
   ```
   → Use mcp__linear__create_issue with:
     - title: "[Epic] User Authentication System"
     - description: Overview and requirements
     - No project (or umbrella project)
   ```

2. **Create sub-issues**:
   ```
   For each component:
   → Use mcp__linear__create_issue with:
     - parent_id: (epic issue ID)
     - title: Specific sub-task
     - project_id: (actual sprint project)
   ```

3. **Track epic progress**:
   ```
   → Get parent issue
   → List children: issue.children
   → Calculate completion: done_children / total_children
   ```

**Epic structure example**:
```
[Epic] User Authentication System
├── Design auth database schema
├── Implement JWT token service
├── Create login API endpoint
├── Build login UI component
└── Add auth middleware
```

### Workflow 14: Dependency Management

**Scenario**: "Issue A blocks issue B"

**Linear doesn't have built-in blocking, so use these approaches**:

**Option 1: Comments and labels**
```
On blocked issue:
→ Add comment: "Blocked by ENG-123"
→ Add label: "blocked"
→ Keep in "Todo" state until unblocked
```

**Option 2: Parent-child relationships**
```
Make blocker the parent:
→ Set blocker as parent_id of blocked issue
→ Work through parent first
```

**Option 3: Project sequencing**
```
Create two projects:
- "Phase 1 - Prerequisites"
- "Phase 2 - Dependent Work"
Assign issues accordingly
```

## Best Practices Summary

### Issue Creation
- ✅ Use descriptive titles (not "Fix bug")
- ✅ Add context in description
- ✅ Set appropriate priority
- ✅ Use labels consistently
- ✅ Link to related issues
- ❌ Don't create duplicates (search first)
- ❌ Don't leave issues unassigned indefinitely

### Project Management
- ✅ Use projects for goals, not categories
- ✅ Set realistic target dates
- ✅ Review progress regularly
- ✅ Archive completed projects
- ❌ Don't create too many projects
- ❌ Don't let projects go stale

### Team Collaboration
- ✅ Update issue states promptly
- ✅ Add comments for context
- ✅ Mention teammates (@username)
- ✅ Keep issues focused
- ❌ Don't let issues get stale
- ❌ Don't have unclear ownership

### Workflow Discipline
- ✅ Move issues through states
- ✅ Close completed work
- ✅ Triage backlog regularly
- ✅ Keep descriptions updated
- ❌ Don't skip states
- ❌ Don't hoard issues

## Troubleshooting Common Scenarios

### "I can't find my issue"
1. Check if you're in the right team
2. Use search instead of browse
3. Check if issue was archived
4. Verify your access permissions

### "Project progress seems wrong"
1. Check for issues in wrong states
2. Look for unclosed sub-issues
3. Verify all work is in the project
4. Consider archived issues

### "Too many issues in backlog"
1. Archive old/irrelevant issues
2. Bulk prioritize (triage session)
3. Create projects to organize
4. Use labels to categorize

### "Team not using Linear consistently"
1. Establish team conventions
2. Regular triage meetings
3. Make it part of daily standup
4. Lead by example

## Integration Workflows

### Workflow 15: Code-Issue Linking

**Scenario**: "Connecting commits to Linear issues"

**Best practice**:
```
Git commit messages:
"Fix login validation [ENG-234]"

Pull request title:
"Implement SSO login (ENG-189)"
```

**In Linear**:
- Add PR link in issue comment
- Link shows up automatically if GitHub integration enabled
- Mark "In Review" when PR opened
- Mark "Done" when PR merged

### Workflow 16: Slack-Linear Workflow

**If Slack integration enabled**:
- Share issue links in Slack
- Use Linear unfurl to show preview
- Create issues from Slack messages
- Get notifications in channels

**Manual workflow**:
- Copy issue identifier (ENG-123)
- Share Linear URL in Slack
- Add comments in both places
- Keep teams synchronized

## Conclusion

These workflows cover the most common Linear operations. As you use Linear more, you'll develop your own patterns and shortcuts. The key is consistency: establish team conventions and stick to them.

Remember:
- Linear is flexible - adapt these workflows to your team
- Start simple - don't over-complicate early on
- Build habits - consistent usage beats perfect structure
- Iterate - improve workflows based on what works

For questions not covered here, consult Linear's official documentation or ask your team lead about established practices.
