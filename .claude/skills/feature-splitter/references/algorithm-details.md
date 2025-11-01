# Feature Splitter: Algorithm Details

This document provides a deep dive into the 6-step decomposition algorithm.

---

## Algorithm Overview

```
Input: User goal (e.g., "Add OAuth authentication")
Output: Structured decomposition plan with dependencies

Step 1: Clarify → Capture goal, constraints, preferences
Step 2: Inventory → Analyze codebase, detect components
Step 3: Map Seams → Identify architectural boundaries
Step 4: Derive Packages → Create subtasks from seams + capabilities
Step 5: Sequence → Build dependency graph, topological sort
Step 6: Validate → Apply guardrails, flag risks
```

---

## Step 1: Clarify Goal & Constraints

### Objective
Capture clear requirements and user preferences to guide decomposition.

### Questions Asked

#### 1. Goal Summary
**Question**: "What's the high-level feature you want to implement?"

**Purpose**: Establish scope and intent

**Examples**:
- "Add OAuth authentication"
- "Implement background job processing"
- "Add full-text search to products"

#### 2. Existing Infrastructure
**Question**: "Does similar functionality already exist?"

**Options**: yes | no | partial

**Purpose**: Detect replacement vs addition patterns

**Examples**:
- "yes" → OAuth replaces existing JWT → More complex migration
- "no" → Greenfield implementation → Simpler, fewer dependencies
- "partial" → Hybrid approach → Need careful integration planning

#### 3. Database Changes
**Question**: "Will this require database schema changes?"

**Options**: yes | no | unsure

**Purpose**: Flag migration dependencies early

**Impact**:
- `yes` → Separate migration subtask, schema-first sequencing
- `no` → More parallelizable, lower risk
- `unsure` → Inspect models during Inventory phase

#### 4. Environment Targeting
**Question**: "Target environment: staging, production, or both?"

**Purpose**: Detect deployment complexity

**Impact**:
- `staging only` → Can test more aggressively
- `production` → Extra validation, security review
- `both` → Coordination between environments

#### 5. Security Review
**Question**: "Is security review required?"

**Options**: yes | no

**Purpose**: Flag high-risk changes early

**Impact**:
- `yes` → Add security checklist, isolate auth changes
- `no` → Standard validation workflow

#### 6. Preferred Sequencing
**Question**: "Preferred implementation order?"

**Options**:
- `schema-first` → DB changes before logic (safer)
- `api-first` → Logic before persistence (faster prototyping)
- `parallel` → Maximize concurrency where safe

**Purpose**: Align plan with user's workflow preferences

### Output

**Structured Context Object:**
```json
{
  "goal": "Add OAuth authentication",
  "existing_auth": "yes (JWT)",
  "db_changes": "yes",
  "environment": "both",
  "security_review": true,
  "sequencing": "parallel"
}
```

---

## Step 2: Inventory Capabilities

### Objective
Analyze codebase to identify affected components and existing assets.

### Framework Detection

#### Django Detection
**Signals:**
- File exists: `manage.py`
- Import pattern: `from django.*`
- Directory: `apps/`, `settings.py`

**Capabilities Detected:**
- App structure: `apps/auth/`, `apps/users/`
- Models: `apps/*/models.py`
- Migrations: `apps/*/migrations/`
- Views: `apps/*/views.py`, `viewsets.py`
- Serializers: `apps/*/serializers.py`
- URLs: `apps/*/urls.py`
- Admin: `apps/*/admin.py`
- Signals: `apps/*/signals.py`
- Middleware: `middleware.py`
- Settings: `settings.py`, `settings/*.py`

#### FastAPI Detection
**Signals:**
- Import pattern: `from fastapi import`
- File exists: `main.py`
- Directory: `routers/`, `schemas/`, `dependencies.py`

**Capabilities Detected:**
- Routers: `routers/*.py`
- Schemas: `schemas/*.py`, Pydantic models
- Dependencies: `dependencies.py`, dependency injection
- Services: `services/*.py`, business logic
- Background tasks: `tasks.py`, `workers/`
- Config: `config.py`, `settings.py`
- Database: `database.py`, SQLAlchemy models

### Component Analysis

**Models/Schemas:**
- List existing models: `User`, `Session`, `Token`
- Detect related models (foreign keys, references)
- Identify shared vs isolated models

**Migrations:**
- Count pending migrations
- Detect recent schema changes (last 7 days)
- Flag tables touched by multiple migrations

**Configuration:**
- Enumerate `.env` keys: `DATABASE_URL`, `SECRET_KEY`
- Detect settings modules: `config.py`, `settings/*.py`
- Identify feature toggles

**Tests:**
- Test structure: `tests/unit/`, `tests/integration/`
- Coverage tools: `pytest`, `coverage.py`
- Fixtures: `conftest.py`, `factories.py`

**Dependencies:**
- Parse `pyproject.toml`, `requirements.txt`
- Detect auth libraries: `authlib`, `python-jose`, `passlib`
- Identify third-party integrations

### Output

**Component Inventory:**
```json
{
  "framework": "fastapi",
  "auth_modules": ["routers/auth.py", "dependencies.py"],
  "models": ["models/user.py", "models/session.py"],
  "migrations": ["alembic/versions/001_users.py"],
  "config": ["config.py", ".env"],
  "tests": ["tests/auth/", "tests/integration/"],
  "dependencies": ["authlib", "python-jose"]
}
```

---

## Step 3: Map Architectural Seams

### Objective
Identify natural split points based on system boundaries and architectural layers.

### Seam Categories

#### 1. Persistence Layer
**Boundary**: Data storage and schema

**Django Seams:**
- Models (`models.py`)
- Migrations (`migrations/`)
- Database config (`settings.DATABASES`)

**FastAPI Seams:**
- SQLAlchemy models (`models.py`)
- Alembic migrations (`alembic/versions/`)
- Database connection (`database.py`)

**Subtask Examples:**
- "oauth-schema" (add tables)
- "oauth-migration" (data migration)

#### 2. API Layer
**Boundary**: HTTP endpoints and routing

**Django Seams:**
- Views (`views.py`, `viewsets.py`)
- URLs (`urls.py`)
- Serializers (`serializers.py`)

**FastAPI Seams:**
- Routers (`routers/*.py`)
- Schemas (`schemas/*.py`)
- Dependencies (`dependencies.py`)

**Subtask Examples:**
- "oauth-endpoints" (login, callback, refresh)
- "oauth-validation" (token verification)

#### 3. Business Logic Layer
**Boundary**: Core application logic

**Django Seams:**
- Services (`services/`)
- Utils (`utils/`)
- Signals (`signals.py`)

**FastAPI Seams:**
- Services (`services/*.py`)
- Background tasks (`tasks.py`)
- Workers (`workers/`)

**Subtask Examples:**
- "oauth-provider" (handshake logic)
- "oauth-token-refresh" (background job)

#### 4. Configuration Layer
**Boundary**: Settings and environment

**Seams:**
- Settings files (`settings.py`, `config.py`)
- Environment variables (`.env`)
- Feature toggles
- Secret management

**Subtask Examples:**
- "oauth-config" (provider credentials)
- "oauth-secrets" (vault setup)

#### 5. Testing Layer
**Boundary**: Test code and fixtures

**Seams:**
- Unit tests (`tests/unit/`)
- Integration tests (`tests/integration/`)
- Fixtures (`conftest.py`, `factories.py`)
- E2E tests (`tests/e2e/`)

**Subtask Examples:**
- "oauth-unit-tests" (logic validation)
- "oauth-integration-tests" (API endpoints)

### Seam Validation

**Independence Check:**
- Can this seam be developed in isolation?
- Does it have clear inputs/outputs?
- Can it be tested independently?

**Coupling Analysis:**
- Shared models? (coupling)
- Shared settings? (coupling)
- Independent config? (decoupled)
- Separate migrations? (decoupled)

### Output

**Seam Map:**
```json
{
  "persistence": ["oauth-schema", "oauth-migration"],
  "api": ["oauth-endpoints", "oauth-validation"],
  "business_logic": ["oauth-provider", "oauth-token-refresh"],
  "configuration": ["oauth-config"],
  "testing": ["oauth-tests"]
}
```

---

## Step 4: Derive Work Packages

### Objective
Combine seams and capabilities into concrete subtasks with clear deliverables.

### Subtask Creation Rules

#### Rule 1: Single Purpose
Each subtask achieves exactly one user-facing outcome.

**Good:**
- "Add OAuth token storage tables" (one purpose: persistence)

**Bad:**
- "Add OAuth tables and implement login endpoint" (two purposes: persistence + API)

#### Rule 2: Reviewable Size
Subtask scope fits in 1-2 focused PRs.

**Heuristic:** 1 engineer-day = ~200-400 lines of code

**Too Small:**
- "Add one field to User model" (<1 hour)
- **Action**: Merge with related task

**Too Large:**
- "Implement entire OAuth system" (>3 days)
- **Action**: Split into multiple subtasks

**Just Right:**
- "Implement OAuth handshake logic" (~1 day)

#### Rule 3: Minimal Coupling
Subtasks touch disjoint file sets where possible.

**Resource Matrix:**
```
Subtask             | models.py | config.py | auth.py | tests/
--------------------|-----------|-----------|---------|-------
oauth-schema        | X         |           |         |
oauth-config        |           | X         |         |
oauth-provider      |           |           | X       |
oauth-tests         |           |           |         | X
```

**Analysis:**
- No column has multiple X's → Good isolation
- If `config.py` touched by multiple → Flag conflict risk

#### Rule 4: Risk Isolation
High-risk changes separated for focused review.

**High-Risk Indicators:**
- Security: auth, encryption, permissions
- Schema: migrations, model changes
- Third-party: API integrations, webhooks

**Action:**
- Isolate security changes to dedicated subtask
- Separate schema migrations
- Flag for extra validation

#### Rule 5: Testable
Each subtask can be independently validated.

**Checklist:**
- Can I write unit tests for this?
- Can I verify in isolation?
- Is success criteria clear?

### Subtask Template

```markdown
## Subtask: {name}

**Goal**: {one-sentence deliverable}

**Files**:
- {file1}
- {file2}

**Tests**:
- {test_file1}

**Dependency**: {predecessor subtasks or "None"}

**Effort**: {0.5d | 1d | 2d | 3d}

**Risk**: {Low | Medium | High}

**Success Criteria**:
- [ ] {criterion 1}
- [ ] {criterion 2}

**Notes**:
- {pitfalls, gotchas, special considerations}
```

### Example Derivation

**Goal**: Add OAuth authentication

**Seams Identified**:
- Persistence: schema, migration
- Config: provider credentials
- API: login endpoint, callback
- Logic: handshake, token refresh
- Testing: unit, integration

**Derived Subtasks**:

1. **oauth-schema**
   - Goal: Add OAuth token storage
   - Seam: Persistence
   - Files: `models/oauth.py`, `alembic/versions/XXX.py`
   - Risk: Medium (schema change)

2. **oauth-config**
   - Goal: Configure OAuth provider
   - Seam: Configuration
   - Files: `config.py`, `.env`
   - Risk: Low

3. **oauth-provider**
   - Goal: Implement OAuth handshake
   - Seam: Business Logic
   - Files: `services/oauth.py`
   - Risk: High (third-party integration)

4. **oauth-endpoints**
   - Goal: Add login/callback routes
   - Seam: API
   - Files: `routers/auth.py`
   - Risk: Medium (security)

5. **oauth-tests**
   - Goal: Validate OAuth flow
   - Seam: Testing
   - Files: `tests/auth/test_oauth.py`
   - Risk: Low

### Output

**Work Packages:**
```json
[
  {
    "name": "oauth-schema",
    "goal": "Add OAuth token storage tables",
    "seam": "persistence",
    "files": ["models/oauth.py", "alembic/versions/XXX_oauth.py"],
    "effort": "0.5d",
    "risk": "medium"
  },
  ...
]
```

---

## Step 5: Sequence & Dependency Check

### Objective
Build dependency graph and determine merge order.

### Dependency Detection

#### 1. Data Flow Dependencies
**Rule**: B reads data written by A → B depends on A

**Example**:
- `oauth-provider` reads from `oauth_tokens` table
- → `oauth-provider` depends on `oauth-schema`

**Detection**:
- Analyze imports: does B import A's models?
- Check database queries: does B query A's tables?
- Inspect function calls: does B call A's functions?

#### 2. Shared State Dependencies
**Rule**: Both modify same resource → Coordinate or sequence

**Example**:
- `oauth-config` modifies `settings.py`
- `oauth-provider` also modifies `settings.py`
- → Flag potential conflict, suggest merge order

**Detection**:
- Build file modification matrix
- Flag files touched by multiple subtasks
- Suggest sequential merge if conflict likely

#### 3. Configuration Dependencies
**Rule**: B needs env vars/settings added by A → B depends on A

**Example**:
- `oauth-provider` needs `OAUTH_CLIENT_ID` env var
- `oauth-config` adds `OAUTH_CLIENT_ID`
- → `oauth-provider` depends on `oauth-config`

**Detection**:
- Parse env var usage in code
- Match with env var additions
- Create dependency edge

#### 4. Logical Dependencies
**Rule**: A validates assumptions needed by B → B depends on A

**Example**:
- `oauth-schema` creates user-oauth relationship
- `oauth-provider` assumes this relationship exists
- → `oauth-provider` depends on `oauth-schema`

**Detection**:
- Harder to automate (requires domain knowledge)
- Fallback to interactive prompts: "Does B depend on A?"

### Graph Construction

**Representation:**
```python
graph = {
  "oauth-schema": [],  # No dependencies
  "oauth-config": ["oauth-schema"],  # Depends on schema
  "oauth-provider": ["oauth-config"],  # Depends on config
  "oauth-endpoints": ["oauth-provider"],  # Depends on provider
  "oauth-tests": ["oauth-endpoints"]  # Depends on endpoints
}
```

**Topological Sort:**
```python
order = ["oauth-schema", "oauth-config", "oauth-provider", "oauth-endpoints", "oauth-tests"]
```

### Parallel Clusters

**Identify Independent Subtasks:**

**Rule**: If A and B have no dependency path → Can be parallel

**Example**:
```
        schema
       ↙      ↘
   config    migration
       ↓
   provider
```

- `config` and `migration` both depend on `schema`
- No dependency between `config` and `migration`
- → `config` and `migration` can be parallel after `schema` merges

**Cluster Output:**
```json
{
  "cluster_1": ["schema"],  // Sequential (foundation)
  "cluster_2": ["config", "migration"],  // Parallel
  "cluster_3": ["provider"]  // Sequential (depends on cluster_2)
}
```

### Circular Dependency Detection

**Example of Problem:**
- A depends on B
- B depends on A
- → Circular, invalid plan

**Action**:
- Flag circular dependency
- Prompt user to refine task breakdown
- Suggest merging A and B into single subtask

### Output

**Dependency Graph:**
```json
{
  "nodes": [
    {"id": "oauth-schema", "effort": "0.5d"},
    {"id": "oauth-config", "effort": "0.5d"},
    {"id": "oauth-provider", "effort": "1d"}
  ],
  "edges": [
    {"from": "oauth-schema", "to": "oauth-config"},
    {"from": "oauth-config", "to": "oauth-provider"}
  ],
  "parallel_clusters": [
    ["oauth-schema"],
    ["oauth-config", "oauth-migration"],
    ["oauth-provider"]
  ],
  "merge_order": [
    "oauth-schema",
    "oauth-config OR oauth-migration (parallel)",
    "oauth-provider"
  ]
}
```

---

## Step 6: Validate Against Guardrails

### Objective
Apply safety checks and flag risks before presenting plan.

### Validation Rules

#### 1. Worktree Count Limit

**Rule**: Max 4-5 concurrent worktrees

**Check**:
```python
if len(subtasks) > 5:
    warn("Plan exceeds 5 worktrees, consider consolidating")
    suggest_merge(smallest_subtasks)
```

**Action**:
- Warn at 4 worktrees
- Require confirmation at 5+
- Suggest merging small subtasks (<1 day)

#### 2. Subtask Size Validation

**Min Size**: 1 engineer-day (unless trivial)

**Check**:
```python
for task in subtasks:
    if task.effort < "1d":
        flag_for_merge(task)
```

**Max Size**: 3 engineer-days

**Check**:
```python
for task in subtasks:
    if task.effort > "3d":
        suggest_split(task)
```

#### 3. Shared File Conflict Detection

**Rule**: Multiple subtasks modifying same file → Flag

**Check**:
```python
file_map = {}
for task in subtasks:
    for file in task.files:
        file_map[file] = file_map.get(file, []) + [task.name]

conflicts = {f: tasks for f, tasks in file_map.items() if len(tasks) > 1}
```

**Action**:
- Warn user of potential conflicts
- Suggest sequential merge order
- Recommend Git rerere for repeated conflicts

#### 4. High-Risk Change Flagging

**Categories**:
- **Security**: auth, encryption, permissions
- **Schema**: migrations, model changes
- **Integration**: third-party APIs, webhooks

**Check**:
```python
for task in subtasks:
    if "auth" in task.files or "security" in task.goal:
        task.risk = "high"
        task.requires_security_review = True
```

**Action**:
- Flag for security review
- Suggest extra validation
- Isolate in separate subtask if bundled

#### 5. Approval Requirements

**Triggers**:
- 3+ concurrent worktrees
- High-risk security changes
- Complex migrations

**Check**:
```python
if concurrent_worktrees >= 3 or high_risk_count > 0:
    require_approval = True
```

**Action**:
- Pause before executing plan
- Prompt user: "Proceed with 3 concurrent worktrees?"
- Display risk summary

### Validation Output

**Guardrail Report:**
```markdown
## Guardrail Validation

✅ Worktree count: 3 (within limit)
✅ Subtask sizing: All 0.5-2 days (appropriate)
⚠️  Shared files: 2 conflicts detected
    - `config.py` touched by oauth-config, oauth-provider
    - Recommendation: Merge oauth-config first
⚠️  High-risk changes: 1 detected
    - oauth-provider (third-party integration)
    - Action: Security review required
⚠️  Approval required: Yes (high-risk change detected)
```

---

## Complete Algorithm Example

**Input:**
```
User: "I want to add OAuth authentication to my FastAPI API"
```

**Step 1: Clarify**
```
Q1: Existing auth? → "Yes, JWT"
Q2: DB changes? → "Yes, need token storage"
Q3: Environment? → "Both staging and production"
Q4: Security review? → "Yes"
Q5: Sequencing? → "Parallel where possible"
```

**Step 2: Inventory**
```
Framework: FastAPI
Auth modules: routers/auth.py, dependencies.py
Models: models/user.py
Migrations: alembic/versions/
Config: config.py, .env
Tests: tests/auth/
```

**Step 3: Map Seams**
```
Persistence: oauth-schema, oauth-migration
Config: oauth-config
Business Logic: oauth-provider
API: oauth-endpoints
Testing: oauth-tests
```

**Step 4: Derive Packages**
```
1. oauth-schema (0.5d, medium risk)
2. oauth-config (0.5d, low risk)
3. oauth-provider (1d, high risk)
4. oauth-endpoints (1d, medium risk)
5. oauth-tests (1d, low risk)
```

**Step 5: Sequence**
```
Dependencies:
- oauth-config depends on oauth-schema
- oauth-provider depends on oauth-config
- oauth-endpoints depends on oauth-provider
- oauth-tests depends on oauth-endpoints

Merge order:
1. oauth-schema (sequential)
2. oauth-config (sequential)
3. oauth-provider (sequential)
4. oauth-endpoints, oauth-tests (parallel)
```

**Step 6: Validate**
```
✅ Worktree count: 5 (acceptable)
✅ Subtask sizing: All 0.5-1 day
⚠️  High-risk: oauth-provider (security review)
⚠️  Approval required: Yes
```

**Output:**
```markdown
## Feature Decomposition: Add OAuth Authentication

| # | Subtask | Dependency | Worktree | Effort | Risk |
|---|---------|------------|----------|--------|------|
| 1 | oauth-schema | – | feature/oauth-schema | 0.5d | Medium |
| 2 | oauth-config | 1 | feature/oauth-config | 0.5d | Low |
| 3 | oauth-provider | 2 | feature/oauth-provider | 1d | High |
| 4 | oauth-endpoints | 3 | feature/oauth-endpoints | 1d | Medium |
| 5 | oauth-tests | 4 | feature/oauth-tests | 1d | Low |

### Worktree Creation Commands

/worktree-create feature/oauth-schema
/worktree-create feature/oauth-config  # After 1 merges
/worktree-create feature/oauth-provider  # After 2 merges
/worktree-create feature/oauth-endpoints  # After 3 merges
/worktree-create feature/oauth-tests  # Parallel with 4
```

---

## Algorithm Complexity

**Time Complexity:**
- Clarify: O(1) - fixed questions
- Inventory: O(n) - scan files
- Map Seams: O(n) - categorize files
- Derive Packages: O(m) - m = number of subtasks
- Sequence: O(m²) - dependency checking
- Validate: O(m) - guardrail checks

**Overall**: O(n + m²) where n = files, m = subtasks

**Typical Values:**
- n = 100-500 files
- m = 3-10 subtasks
- Runtime: <1 second for analysis

---

**Document Version**: 1.0.0
**Last Updated**: 2025-11-01
**Status**: Reference Complete
