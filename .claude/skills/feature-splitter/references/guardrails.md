# Feature Splitter: Guardrails Reference

Complete specification of validation rules, safety checks, and approval mechanisms.

---

## Overview

Guardrails prevent common mistakes in parallel worktree development by:
- Limiting complexity (worktree count, subtask size)
- Detecting conflicts (shared files, concurrent modifications)
- Flagging risks (security, schema, integration)
- Requiring approvals (high-risk changes)

---

## Guardrail 1: Worktree Count Limit

### Rule

**Maximum concurrent worktrees: 4-5**

### Rationale

**Why limit?**
- **Cognitive load**: More worktrees = more context switching
- **Merge conflicts**: Probability increases with concurrent changes
- **Focus**: Solo developers work best with 2-3 parallel tasks
- **Management overhead**: Each worktree needs monitoring

### Thresholds

| Count | Status | Action |
|-------|--------|--------|
| 1-2   | ✅ Optimal | Proceed |
| 3     | ✅ Good | Proceed |
| 4     | ⚠️ Warning | Warn user, proceed |
| 5     | ⚠️ High | Require confirmation |
| 6+    | 🚫 Excessive | Strong discouragement, suggest consolidation |

### Implementation

```python
def validate_worktree_count(subtasks):
    count = len(subtasks)

    if count <= 3:
        return {"status": "ok"}

    if count == 4:
        return {
            "status": "warning",
            "message": "4 worktrees is manageable but consider your bandwidth",
            "action": "proceed_with_caution"
        }

    if count == 5:
        return {
            "status": "high_risk",
            "message": "5 worktrees may be challenging for solo development",
            "action": "require_confirmation",
            "prompt": "Are you sure you want to proceed with 5 concurrent worktrees?"
        }

    # 6+
    return {
        "status": "excessive",
        "message": f"{count} worktrees exceeds recommended limit",
        "action": "suggest_consolidation",
        "suggestions": [
            "Merge smallest subtasks",
            "Sequence more aggressively (reduce parallelism)",
            "Split feature into phases"
        ]
    }
```

### Consolidation Strategies

**When count > 5:**

**Option 1: Merge Small Subtasks**
```
Before:
- oauth-schema (0.5d)
- oauth-config (0.5d)  ← Merge these
- oauth-provider (1d)

After:
- oauth-foundation (1d) = schema + config
- oauth-provider (1d)
```

**Option 2: Reduce Parallelism**
```
Before:
- Subtasks 1, 2, 3, 4, 5 all parallel

After:
- Sequential: 1 → 2 → 3
- Then parallel: 4, 5
```

**Option 3: Phase Splitting**
```
Phase 1 (Weeks 1-2):
- Core functionality (3 worktrees)

Phase 2 (Weeks 3-4):
- Extensions and tests (2 worktrees)
```

---

## Guardrail 2: Subtask Size Validation

### Rule

**Minimum size: 1 engineer-day**
**Maximum size: 3 engineer-days**
**Optimal range: 1-2 days**

### Rationale

**Why minimum 1 day?**
- Worktree overhead (creation, .venv, DB copy) ~10-15 min
- Small tasks don't justify overhead
- Better to batch with related work

**Why maximum 3 days?**
- Reduces merge conflicts (longer = more drift)
- Keeps PRs reviewable
- Limits blast radius if issues found
- Maintains momentum (frequent merges)

### Thresholds

| Effort | Status | Action |
|--------|--------|--------|
| <0.5d  | 🚫 Too Small | Merge with related task |
| 0.5d   | ⚠️ Small | Consider merging, but acceptable |
| 1-2d   | ✅ Optimal | Proceed |
| 2.5-3d | ✅ Large | Acceptable, consider splitting |
| >3d    | ⚠️ Too Large | Suggest splitting |

### Implementation

```python
def validate_subtask_size(subtask):
    effort_hours = parse_effort(subtask.effort)  # "1d" → 8, "2.5d" → 20

    if effort_hours < 4:  # <0.5 days
        return {
            "status": "too_small",
            "message": f"{subtask.name} is too small ({subtask.effort})",
            "action": "suggest_merge",
            "suggestions": find_related_subtasks(subtask)
        }

    if effort_hours <= 16:  # 0.5-2 days
        return {"status": "ok"}

    if effort_hours <= 24:  # 2-3 days
        return {
            "status": "large_but_ok",
            "message": f"{subtask.name} is large ({subtask.effort}), consider splitting",
            "action": "proceed_with_note"
        }

    # >3 days
    return {
        "status": "too_large",
        "message": f"{subtask.name} is too large ({subtask.effort})",
        "action": "suggest_split",
        "suggestions": suggest_splits(subtask)
    }
```

### Effort Estimation

**Heuristics:**

| Task Type | Effort Estimate |
|-----------|-----------------|
| Add simple model | 0.5d |
| Add migration | 0.5d |
| Implement API endpoint | 1d |
| Complex business logic | 1-2d |
| Third-party integration | 1-2d |
| E2E test suite | 1d |
| Performance optimization | 1-3d |

**Adjustment Factors:**
- Unfamiliar tech: +50%
- High complexity: +30%
- Security-critical: +20% (extra care)
- Well-defined spec: -20%

---

## Guardrail 3: Shared File Conflict Detection

### Rule

**Warn when multiple subtasks modify the same file**

### Rationale

**Why detect?**
- Concurrent modifications → merge conflicts
- Coordination needed
- Sequential merging may be safer

**Exception**: Some shared files are expected:
- `tests/conftest.py` (fixtures)
- `pyproject.toml` (dependencies)
- `README.md` (documentation)

### Conflict Severity

| File Type | Severity | Action |
|-----------|----------|--------|
| Core models | 🚨 High | Warn, suggest sequencing |
| `settings.py` | 🚨 High | Warn, suggest sequencing |
| Migrations | 🚨 High | Warn, coordination critical |
| Routers/views | ⚠️ Medium | Warn, but may be manageable |
| Tests | ⚠️ Medium | Warn, Git rerere helps |
| `conftest.py` | ✅ Low | Acceptable |
| `README.md` | ✅ Low | Acceptable |

### Implementation

```python
def detect_shared_files(subtasks):
    file_map = {}

    for task in subtasks:
        for file in task.files:
            if file not in file_map:
                file_map[file] = []
            file_map[file].append(task.name)

    conflicts = {}
    for file, tasks in file_map.items():
        if len(tasks) > 1:
            severity = classify_conflict_severity(file)
            conflicts[file] = {
                "tasks": tasks,
                "severity": severity
            }

    return conflicts

def classify_conflict_severity(file):
    high_risk_patterns = [
        "models.py", "settings.py", "config.py",
        "migrations/", "alembic/versions/"
    ]

    medium_risk_patterns = [
        "routers/", "views.py", "tests/"
    ]

    low_risk_patterns = [
        "conftest.py", "README.md", "pyproject.toml"
    ]

    if any(pattern in file for pattern in high_risk_patterns):
        return "high"
    elif any(pattern in file for pattern in medium_risk_patterns):
        return "medium"
    else:
        return "low"
```

### Conflict Resolution Strategies

**High Severity:**
```markdown
⚠️ High-risk conflict detected

File: `models/user.py`
Touched by: oauth-schema, user-profile

Recommendation:
1. Sequence these tasks (oauth-schema → user-profile)
2. OR: Coordinate closely, use Git rerere
3. OR: Merge into single subtask if tightly coupled
```

**Medium Severity:**
```markdown
⚠️ Potential conflict detected

File: `routers/auth.py`
Touched by: oauth-login, password-reset

Recommendation:
1. Git rerere will handle if conflict is repetitive
2. Coordinate on function boundaries
3. Merge order: oauth-login → password-reset
```

**Low Severity:**
```markdown
ℹ️ Shared file usage (acceptable)

File: `conftest.py`
Touched by: oauth-tests, user-tests

Note: Test fixtures are commonly shared
Action: Use Git rerere, proceed normally
```

---

## Guardrail 4: High-Risk Change Flagging

### Rule

**Identify and flag security, schema, and integration changes**

### Risk Categories

#### 1. Security-Critical Changes

**Indicators:**
- Authentication/authorization logic
- Password handling
- Token generation/validation
- Encryption/decryption
- Permission checks
- Session management

**Examples:**
- "oauth-provider" (OAuth handshake)
- "jwt-validation" (token verification)
- "password-reset" (security-sensitive)

**Actions:**
- Flag for security review
- Suggest security checklist
- Isolate in dedicated subtask
- Require extra testing

#### 2. Schema Changes

**Indicators:**
- Database migrations
- Model field additions/removals
- Index changes
- Foreign key modifications
- Table renames/drops

**Examples:**
- "oauth-schema" (new tables)
- "user-migration" (model changes)

**Actions:**
- Flag for migration review
- Suggest rollback testing
- Warn about data loss risks
- Recommend backup

#### 3. Third-Party Integrations

**Indicators:**
- External API calls
- Webhook endpoints
- OAuth providers
- Payment processing
- Email/SMS services

**Examples:**
- "stripe-integration" (payment API)
- "sendgrid-emails" (email service)

**Actions:**
- Flag for integration testing
- Suggest staging validation
- Recommend error handling
- Check API limits/quotas

### Risk Scoring

```python
def calculate_risk_score(subtask):
    score = 0

    # Security keywords
    security_keywords = ["auth", "password", "token", "session", "encrypt", "permission"]
    if any(kw in subtask.goal.lower() for kw in security_keywords):
        score += 30

    # Schema keywords
    schema_keywords = ["migration", "model", "schema", "database", "table"]
    if any(kw in subtask.goal.lower() for kw in schema_keywords):
        score += 20

    # Integration keywords
    integration_keywords = ["api", "webhook", "oauth", "stripe", "sendgrid", "third-party"]
    if any(kw in subtask.goal.lower() for kw in integration_keywords):
        score += 25

    # Files touched
    if "migrations/" in str(subtask.files):
        score += 20
    if "models.py" in str(subtask.files):
        score += 15

    return score

def classify_risk(score):
    if score >= 50:
        return "high"
    elif score >= 25:
        return "medium"
    else:
        return "low"
```

### Risk Thresholds

| Score | Risk Level | Action |
|-------|------------|--------|
| 0-24  | Low ✅ | Standard validation |
| 25-49 | Medium ⚠️ | Extra testing recommended |
| 50+   | High 🚨 | Security review required |

### High-Risk Subtask Template

```markdown
## Subtask: {name} 🚨 HIGH RISK

**Risk Category**: {Security | Schema | Integration}

**Risk Score**: {score}/100

**Checklist:**
- [ ] Security review completed
- [ ] Staging environment tested
- [ ] Rollback plan documented
- [ ] Error handling comprehensive
- [ ] Monitoring/logging in place
- [ ] Documentation updated

**Extra Validation:**
- [ ] Penetration testing (if security)
- [ ] Migration rollback tested (if schema)
- [ ] Third-party sandbox tested (if integration)
```

---

## Guardrail 5: Approval Requirements

### Rule

**Require explicit user approval before proceeding with high-risk plans**

### Approval Triggers

| Trigger | Threshold | Reason |
|---------|-----------|--------|
| Worktree count | ≥3 | Complexity management |
| High-risk subtasks | ≥1 | Security/schema concerns |
| Shared file conflicts | ≥2 (high severity) | Merge conflict risk |
| Total effort | >10 days | Scope validation |

### Approval Flow

```python
def requires_approval(plan):
    triggers = []

    if len(plan.subtasks) >= 3:
        triggers.append({
            "reason": "3+ concurrent worktrees",
            "severity": "medium"
        })

    high_risk_count = sum(1 for task in plan.subtasks if task.risk == "high")
    if high_risk_count > 0:
        triggers.append({
            "reason": f"{high_risk_count} high-risk subtask(s)",
            "severity": "high"
        })

    high_conflicts = sum(1 for c in plan.conflicts.values() if c["severity"] == "high")
    if high_conflicts >= 2:
        triggers.append({
            "reason": f"{high_conflicts} high-severity file conflicts",
            "severity": "high"
        })

    total_effort = sum(parse_effort(task.effort) for task in plan.subtasks)
    if total_effort > 80:  # >10 days
        triggers.append({
            "reason": f"Total effort {total_effort}h (>10 days)",
            "severity": "medium"
        })

    return triggers
```

### Approval Prompt

```markdown
⚠️ APPROVAL REQUIRED

The following triggers require your approval:

1. 🚨 HIGH: 2 high-risk subtask(s)
   - oauth-provider (third-party integration)
   - password-reset (security-critical)

2. ⚠️ MEDIUM: 4 concurrent worktrees
   - May increase context switching

3. ⚠️ MEDIUM: 2 high-severity file conflicts
   - models/user.py (oauth-schema, user-profile)
   - settings.py (oauth-config, email-config)

Risk Summary:
- Total subtasks: 4
- High-risk: 2
- Shared files: 2 (high severity)
- Estimated effort: 6 days

Proceed with this plan? [Yes / No / Modify]
```

### User Responses

**Yes**: Proceed with plan as-is
**No**: Abort, return to clarification
**Modify**: Allow user to adjust plan (merge subtasks, change sequencing)

---

## Combined Validation Report

### Example Output

```markdown
## Guardrail Validation Report

### Worktree Count
✅ Status: OK (3 worktrees)
- Within recommended limit
- Action: Proceed

### Subtask Sizing
✅ Status: OK
- oauth-schema: 0.5d ✅
- oauth-config: 0.5d ✅
- oauth-provider: 1d ✅
- oauth-tests: 1d ✅

All subtasks within optimal range (0.5-2 days)

### Shared File Conflicts
⚠️ Status: WARNING (1 conflict detected)

File: `settings.py`
- Touched by: oauth-config, oauth-provider
- Severity: HIGH
- Recommendation: Merge oauth-config first, then oauth-provider

### High-Risk Changes
🚨 Status: HIGH RISK (1 high-risk subtask)

Subtask: oauth-provider
- Risk Category: Security + Integration
- Risk Score: 55/100
- Actions Required:
  - Security review before merge
  - Test in staging environment
  - Document rollback plan

### Approval Decision
🚨 APPROVAL REQUIRED

Triggers:
1. High-risk subtask detected (oauth-provider)
2. High-severity file conflict (settings.py)

Proceed? [Yes / No / Modify]
```

---

## Guardrail Overrides

### When to Override

Users may override guardrails in specific scenarios:

**Override Worktree Limit:**
- Experienced with worktree workflow
- Features truly independent
- Accept increased complexity

**Override Size Limits:**
- Small task is isolated experiment
- Large task is well-defined, low-risk

**Override Conflict Warnings:**
- User plans to coordinate manually
- Git rerere is configured
- Conflicts are trivial (e.g., comments)

### Override Prompt

```markdown
⚠️ Guardrail Warning

Issue: Plan exceeds 5 worktrees (6 requested)

Recommendation: Consolidate subtasks

Override this warning? [Yes / No]

If Yes, confirm you understand:
- ✅ I'm comfortable managing 6 concurrent worktrees
- ✅ I'll actively monitor for merge conflicts
- ✅ I'll merge incrementally to reduce drift

Proceed with override? [Confirm / Cancel]
```

---

## Best Practices for Guardrail Design

### 1. Sensible Defaults
- Rules should work well for 80% of cases
- Allow overrides for edge cases

### 2. Clear Explanations
- Every warning should explain "why"
- Suggest concrete remediation

### 3. Progressive Escalation
- Info → Warning → Error
- Don't block prematurely

### 4. User Empowerment
- Provide options, not mandates
- Trust experienced users

### 5. Learn from Feedback
- Track which guardrails trigger most
- Adjust thresholds based on user behavior

---

**Document Version**: 1.0.0
**Last Updated**: 2025-11-01
**Status**: Reference Complete
