# Linear API Integration Guide

Complete guide for using Linear API to complement MCP functionality.

---

## When to Use MCP vs API

### Use Linear MCP for:

**Read Operations:**
- Listing projects, issues, teams, cycles
- Getting project/issue details
- Searching issues by filters
- Viewing comments, labels, milestones

**Basic Write Operations:**
- Creating issues
- Updating issue fields (title, description, status, assignee, priority)
- Creating comments
- Creating labels
- Updating projects (name, description, status)

### Use Linear API for:

**Advanced Write Operations:**
- **Deleting** issues, comments, projects (MCP doesn't support)
- **Archiving** issues, projects, cycles (MCP doesn't support)
- **Cycle management**: Creating, updating, archiving cycles (MCP read-only)
- **Attachment management**: Adding/removing file attachments (MCP doesn't support)
- **Webhook management**: Creating/managing webhooks (MCP doesn't support)
- **Custom View management**: Creating custom filtered views (MCP doesn't support)
- **Workflow customization**: Adding custom workflow states (MCP doesn't support)

**Quick Reference Table:**

| Feature | MCP | API | Notes |
|---------|-----|-----|-------|
| List Issues | ✅ | ✅ | MCP recommended |
| Create Issue | ✅ | ✅ | MCP recommended |
| Update Issue | ✅ | ✅ | MCP recommended |
| Delete Issue | ❌ | ✅ | API only |
| Archive Issue | ❌ | ✅ | API only |
| List Cycles | ✅ | ✅ | MCP recommended |
| Create Cycle | ❌ | ✅ | API only |
| Update Cycle | ❌ | ✅ | API only |
| Archive Cycle | ❌ | ✅ | API only |
| Comments (create) | ✅ | ✅ | MCP recommended |
| Comments (update/delete) | ❌ | ✅ | API only |
| Attachments | ❌ | ✅ | API only |
| Webhooks | ❌ | ✅ | API only |
| Custom Views | ❌ | ✅ | API only |

---

## Setup: LINEAR_API_KEY Environment Variable

### 1. Generate API Key

**Option A: Manual (Web Browser)**
1. Navigate to https://linear.app/settings/api
2. Click "Create key" under "Personal API keys"
3. Copy the generated key (starts with `lin_api_`)

**Option B: Automated (Playwright)**
```bash
# Trigger web-automation skill
"Generate Linear API key using browser automation"
```

The Playwright automation:
- Navigates to Linear settings
- Uses persistent Google session for login
- Generates and retrieves API key automatically

### 2. Add to .env File

```bash
# .env (project root)
LINEAR_API_KEY=lin_api_YOUR_KEY_HERE
```

**Security:**
- ⚠️ Never commit `.env` to Git
- ✅ `.env` is in `.gitignore` by default
- ✅ Use `.env.example` as template

### 3. Validate Environment Variable

```bash
# Run validation script
python .claude/scripts/validate-env.py

# Strict mode (checks optional vars too)
python .claude/scripts/validate-env.py --strict
```

**Expected output:**
```
[OK] All environment variables are valid!
```

**If LINEAR_API_KEY has wrong format:**
```
ERROR: LINEAR_API_KEY has invalid format: Linear API key (should start with 'lin_api_')
```

---

## Using Linear API Client

### CLI Usage

**Document Operations:**
```bash
# Create document
python .claude/scripts/linear-api-client.py document create \
  --title "API Integration Guide" \
  --content "# Linear API\n\nGuide content here"

# Update document
python .claude/scripts/linear-api-client.py document update \
  --id DOC-123 \
  --content "# Updated Content"

# Delete document
python .claude/scripts/linear-api-client.py document delete --id DOC-123

# Archive document
python .claude/scripts/linear-api-client.py document archive --id DOC-123
```

**Issue Operations (Delete/Archive):**
```bash
# Archive issue
python .claude/scripts/linear-api-client.py issue archive --id ISSUE-ID

# Unarchive issue
python .claude/scripts/linear-api-client.py issue unarchive --id ISSUE-ID

# Delete issue (permanent!)
python .claude/scripts/linear-api-client.py issue delete --id ISSUE-ID
```

**Comment Operations:**
```bash
# Update comment
python .claude/scripts/linear-api-client.py comment update \
  --id COMMENT-ID \
  --body "Updated comment text"

# Delete comment
python .claude/scripts/linear-api-client.py comment delete --id COMMENT-ID
```

**Cycle Operations:**
```bash
# Create cycle
python .claude/scripts/linear-api-client.py cycle create \
  --team TEAM-ID \
  --name "Sprint 42" \
  --starts-at "2025-11-09T00:00:00Z" \
  --ends-at "2025-11-23T00:00:00Z"

# Update cycle
python .claude/scripts/linear-api-client.py cycle update \
  --id CYCLE-ID \
  --name "Sprint 42 Extended" \
  --ends-at "2025-11-30T00:00:00Z"

# Archive cycle
python .claude/scripts/linear-api-client.py cycle archive --id CYCLE-ID
```

**Attachment Operations:**
```bash
# Create attachment (GitHub PR link)
python .claude/scripts/linear-api-client.py attachment create \
  --issue ISSUE-ID \
  --url "https://github.com/org/repo/pull/456" \
  --title "Fix authentication bug"

# Update attachment
python .claude/scripts/linear-api-client.py attachment update \
  --id ATTACHMENT-ID \
  --title "Updated title"

# Delete attachment
python .claude/scripts/linear-api-client.py attachment delete --id ATTACHMENT-ID
```

**Webhook Operations:**
```bash
# Create webhook
python .claude/scripts/linear-api-client.py webhook create \
  --url "https://api.myapp.com/webhook" \
  --types Issue Comment \
  --label "My App Webhook"

# Update webhook
python .claude/scripts/linear-api-client.py webhook update \
  --id WEBHOOK-ID \
  --enabled true

# Delete webhook
python .claude/scripts/linear-api-client.py webhook delete --id WEBHOOK-ID
```

### Python Code Usage

```python
import os
import sys
from dotenv import load_dotenv

# Add .claude/scripts to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '.claude', 'scripts'))

from linear_api_client import LinearAPIClient

# Load environment variables
load_dotenv()
api_key = os.getenv("LINEAR_API_KEY")

# Create client
client = LinearAPIClient(api_key)

# Archive completed issue
client.archive_issue("ISSUE-123")

# Create cycle for next sprint
cycle = client.create_cycle(
    team_id="TEAM-456",
    name="Sprint 43",
    starts_at="2025-11-23T00:00:00Z",
    ends_at="2025-12-07T00:00:00Z"
)

# Add PR link to issue
client.create_attachment(
    issue_id="ISSUE-789",
    url="https://github.com/org/repo/pull/123",
    title="Implementation PR"
)
```

---

## Hybrid Workflows (MCP + API)

Leverage both MCP and API for optimal workflows:

### Workflow 1: Clean Up Completed Work

```python
# 1. MCP: Find completed issues
completed_issues = mcp__linear_server__list_issues(
    state="Done",
    limit=50
)

# 2. API: Archive them
for issue in completed_issues:
    client.archive_issue(issue['id'])
    print(f"Archived: {issue['identifier']}")
```

### Workflow 2: Sprint Planning with Cycles

```python
# 1. MCP: Get team information
team = mcp__linear_server__get_team(query="Backend Team")

# 2. API: Create cycle for new sprint
cycle = client.create_cycle(
    team_id=team['id'],
    name="Sprint 44",
    starts_at="2025-12-07T00:00:00Z",
    ends_at="2025-12-21T00:00:00Z"
)

# 3. MCP: Create issues in the cycle
mcp__linear_server__create_issue(
    title="Implement caching layer",
    team=team['id'],
    cycle=cycle['cycle']['id']
)
```

### Workflow 3: GitHub PR Integration

```python
# 1. MCP: Get issue details
issue = mcp__linear_server__get_issue(id="ISSUE-456")

# 2. Create GitHub PR (external)
pr_url = create_github_pr(...)

# 3. API: Attach PR to Linear issue
client.create_attachment(
    issue_id=issue['id'],
    url=pr_url,
    title=f"PR: {issue['title']}"
)

# 4. MCP: Add comment
mcp__linear_server__create_comment(
    issueId=issue['id'],
    body=f"PR created: {pr_url}"
)
```

### Workflow 4: Webhook for External Integration

```python
# 1. API: Create webhook for high-priority issues
webhook = client.create_webhook(
    url="https://api.slack.com/webhooks/...",
    resource_types=["Issue"],
    label="Slack Alert for Urgent Issues"
)

# 2. MCP: Create high-priority issue (triggers webhook)
mcp__linear_server__create_issue(
    title="Production outage: Database timeout",
    team="TEAM-123",
    priority=1,  # Urgent
    labels=["incident"]
)
# → Webhook automatically sends Slack notification
```

---

## Common Patterns

### Pattern 1: Cleanup After Completion

**Use case**: Archive all issues in "Done" state for a completed project

```bash
# 1. MCP: List done issues
issues=$(mcp list-issues --state Done --project PROJECT-123)

# 2. API: Archive each
for issue_id in $issues; do
  python .claude/scripts/linear-api-client.py issue archive --id $issue_id
done
```

### Pattern 2: Cycle Lifecycle Management

**Use case**: Create cycle, add issues, archive when complete

```python
# Create
cycle = client.create_cycle(team_id="...", name="Sprint 1")

# Update (extend deadline)
client.update_cycle(cycle_id=cycle_id, ends_at="2025-12-31")

# Archive (sprint complete)
client.archive_cycle(cycle_id=cycle_id)
```

### Pattern 3: Comment Management

**Use case**: Fix typo in comment or remove sensitive information

```bash
# Update comment
python .claude/scripts/linear-api-client.py comment update \
  --id COMMENT-ID \
  --body "Corrected information here"

# Delete comment (if sensitive data leaked)
python .claude/scripts/linear-api-client.py comment delete --id COMMENT-ID
```

---

## Troubleshooting

### API Key Issues

**Error: "LINEAR_API_KEY not found"**
```bash
# Check .env file
cat .env | grep LINEAR_API_KEY

# Validate
python .claude/scripts/validate-env.py
```

**Error: "API request failed: 401 - Unauthorized"**
- API key expired or invalid
- Regenerate key at https://linear.app/settings/api

### Workspace Access Issues

**Error: "Entity not found: Issue"**
- API key belongs to different workspace
- Check which workspace the key was created in:
```python
# Test viewer query
query = '{ viewer { name email } }'
# Shows which account/workspace the API key is for
```

### GraphQL Validation Errors

**Error: "Cannot query field 'url' on type 'Cycle'"**
- API schema has changed
- Update `.claude/scripts/linear-api-client.py` mutation

---

## Best Practices

1. **Use MCP for reads, API for advanced writes**
   - MCP is simpler and more reliable for common operations
   - Use API only when MCP doesn't support the operation

2. **Validate environment variables on project init**
   ```bash
   python .claude/scripts/validate-env.py
   ```

3. **Archive instead of delete when possible**
   - Archiving is reversible
   - Deleting is permanent (30-day grace period)

4. **Use hybrid workflows**
   - Combine MCP's convenience with API's power
   - Example: MCP to find issues, API to archive them

5. **Secure API keys**
   - Never commit `.env` to Git
   - Rotate keys periodically
   - Use separate keys for dev/prod environments

6. **Handle rate limits**
   - Personal API keys: 1,500 requests/hour
   - Implement exponential backoff on 429 errors

---

## API Client Implementation

The Linear API client is located at `.claude/scripts/linear-api-client.py`.

**Features:**
- 13 resource types (Document, Issue, Comment, Project, Cycle, etc.)
- 50+ methods covering all CRUD operations
- CLI interface with `resource action --options` pattern
- Comprehensive error handling

**Architecture:**
```python
class LinearAPIClient:
    def _execute_query(self, query: str, variables: Dict) -> Dict:
        # GraphQL query execution with error handling

    # Resource-specific methods
    def archive_issue(self, issue_id: str) -> Dict: ...
    def create_cycle(self, team_id: str, ...) -> Dict: ...
    def create_attachment(self, issue_id: str, ...) -> Dict: ...
    # ... 50+ methods
```

---

## Related Documentation

- **Linear API Docs**: https://developers.linear.app/docs/graphql
- **MCP vs API Comparison**: `docs/linear-mcp-vs-api-comparison.md`
- **API Quick Reference**: `docs/linear-api-quick-reference.md`
- **Integration Guide**: `docs/linear-api-integration.md`

---

Last updated: 2025-11-09
