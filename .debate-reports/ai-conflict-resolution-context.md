# AI-Assisted Conflict Resolution - Context

## Background

**Existing Workflow (Round 3 결과):**
- Rebase-first merge strategy
- Manual conflict resolution required
- User resolves → `git add .` → `git rebase --continue`

## New Proposal

**User Suggestion:** AI agent가 conflict를 판단하고 자동으로 수정해서 merge

## Scenarios

### Scenario 1: Simple Conflict (Auto-resolvable)

```python
# Base (main)
def calculate_total(items):
    return sum(item.price for item in items)

# Feature Branch A (your worktree)
def calculate_total(items):
    """Calculate total price of items"""
    return sum(item.price for item in items)

# Feature Branch B (already merged to main)
def calculate_total(items):
    tax_rate = 0.1
    return sum(item.price for item in items) * (1 + tax_rate)

# CONFLICT:
<<<<<<< HEAD
def calculate_total(items):
    tax_rate = 0.1
    return sum(item.price for item in items) * (1 + tax_rate)
=======
def calculate_total(items):
    """Calculate total price of items"""
    return sum(item.price for item in items)
>>>>>>> feature-docs

# AI Resolution: Combine both changes
def calculate_total(items):
    """Calculate total price of items"""
    tax_rate = 0.1
    return sum(item.price for item in items) * (1 + tax_rate)
```

**Complexity:** Low
**AI Confidence:** High (90%+)
**Safe to auto-resolve?** Likely YES

---

### Scenario 2: Semantic Conflict (Risky)

```python
# Base
def process_payment(amount):
    return payment_gateway.charge(amount)

# Your Branch
def process_payment(amount):
    # Changed to async
    return await payment_gateway.charge_async(amount)

# Main (already merged)
def process_payment(amount, currency="USD"):
    # Added currency parameter
    return payment_gateway.charge(amount, currency)

# CONFLICT:
<<<<<<< HEAD
def process_payment(amount, currency="USD"):
    return payment_gateway.charge(amount, currency)
=======
def process_payment(amount):
    return await payment_gateway.charge_async(amount)
>>>>>>> feature-async

# AI Resolution: ???
# Option 1: Combine (RISKY - might break signature)
def process_payment(amount, currency="USD"):
    return await payment_gateway.charge_async(amount, currency)

# Option 2: Ask user which to keep
# Option 3: Create both and let user choose
```

**Complexity:** High
**AI Confidence:** Low (40-60%)
**Safe to auto-resolve?** NO - Ask user

---

### Scenario 3: Whitespace/Formatting Conflict (Trivial)

```python
# Base
def foo():
    bar = 1
    baz = 2
    return bar + baz

# Your Branch (black formatted)
def foo():
    bar = 1
    baz = 2
    return bar + baz

# Main (different formatting)
def foo():
  bar = 1
  baz = 2
  return bar+baz

# CONFLICT: Pure formatting difference
```

**Complexity:** Trivial
**AI Confidence:** High (95%+)
**Safe to auto-resolve?** YES - Apply formatter

---

### Scenario 4: Logic Conflict (Dangerous)

```python
# Base
def validate_user(user):
    if user.age >= 18:
        return True
    return False

# Your Branch
def validate_user(user):
    # Changed business logic
    if user.age >= 21:
        return True
    return False

# Main
def validate_user(user):
    # Added email validation
    if user.age >= 18 and user.email:
        return True
    return False

# CONFLICT:
<<<<<<< HEAD
def validate_user(user):
    if user.age >= 18 and user.email:
        return True
    return False
=======
def validate_user(user):
    if user.age >= 21:
        return True
    return False
>>>>>>> feature-age-check

# AI Resolution: ???
# This is a BUSINESS LOGIC conflict - AI should NOT auto-resolve
```

**Complexity:** Critical
**AI Confidence:** Low (20-30%)
**Safe to auto-resolve?** **NEVER** - User must decide

---

## Questions to Explore

### 1. Feasibility

**Technical:**
- Can Codex CLI resolve conflicts programmatically?
- How to feed conflict context to AI?
- How to validate AI resolution?
- Rollback if AI resolution is wrong?

**Safety:**
- How to detect "safe" vs "risky" conflicts?
- Confidence threshold for auto-resolution?
- Test suite required before accepting AI resolution?

### 2. Categories of Conflicts

**Which conflicts are AI-resolvable?**

| Type | Example | AI Confidence | Auto-resolve? |
|------|---------|---------------|---------------|
| **Whitespace** | Indentation, formatting | 95%+ | ✅ YES |
| **Documentation** | Docstrings, comments | 90%+ | ✅ YES (with review) |
| **Imports** | Different import orders | 85%+ | ✅ YES |
| **Non-overlapping** | Different parts of function | 80%+ | ⚠️ MAYBE (with tests) |
| **Overlapping logic** | Same lines changed differently | 50-70% | ❌ NO (ask user) |
| **Business logic** | Validation rules, algorithms | 20-40% | ❌ NEVER |

### 3. Implementation Approaches

**Option A: Codex CLI Integration**
```powershell
# Detect conflict
git merge feature-branch
# Conflict detected

# Feed to Codex
codex exec "Resolve this merge conflict: $(cat conflicted-file.py)"
# Codex suggests resolution

# Validate with tests
pytest

# Apply if tests pass
git add .
git rebase --continue
```

**Option B: Claude Code MCP**
```powershell
# Use Claude Code's edit capability
# - Read conflicted file
# - Analyze conflict markers
# - Propose resolution
# - Edit file
# - Run tests
# - Commit if safe
```

**Option C: Hybrid (Conservative)**
```powershell
# 1. Auto-resolve trivial conflicts (whitespace, imports)
# 2. AI suggests resolution for medium conflicts
# 3. Ask user for risky conflicts
# 4. Always run tests after resolution
```

### 4. Safety Mechanisms

**Required safeguards:**
- ✅ Pre-resolution backup (git stash)
- ✅ Test suite execution (mandatory)
- ✅ User review for low-confidence resolutions
- ✅ Rollback if tests fail
- ✅ Diff preview before applying
- ✅ Confidence score display

### 5. User Experience

**Interactive workflow:**
```
Conflict detected in src/auth.py (3 conflicts)

Analyzing conflicts...
├─ Conflict 1: Whitespace (trivial) - Auto-resolved ✓
├─ Conflict 2: Docstring addition (low risk)
│  AI Suggestion (confidence: 85%):
│  """Authenticate user with JWT token"""
│  Accept? (Y/n/Review)
└─ Conflict 3: Logic change (high risk)
   Cannot auto-resolve - business logic conflict
   Please resolve manually:
   - Your change: age >= 21
   - Main change: age >= 18 and user.email

   Options:
   1. Keep yours
   2. Keep theirs
   3. Open in editor
```

### 6. Worktree-Specific Considerations

**In worktree environment:**
- Conflict in feature worktree during rebase
- AI resolution in feature worktree
- Validate in both feature and main contexts
- Update other worktrees after resolution

### 7. Risk Assessment

**What could go wrong?**
- ❌ AI misunderstands intent → Wrong resolution
- ❌ Tests pass but logic is subtly broken
- ❌ Security implications of auto-resolution
- ❌ AI hallucinates non-existent functions
- ❌ Merge creates inconsistent state across files

**Mitigation:**
- ✅ Conservative confidence thresholds
- ✅ Mandatory test execution
- ✅ User review for medium/high risk
- ✅ Rollback mechanism
- ✅ Logging all AI decisions

### 8. Integration with Existing Scripts

**Enhance `merge-simple.ps1`:**
```powershell
# New flag: -AIResolve
.\merge-simple.ps1 -FeatureBranch feature-auth -AIResolve

# Workflow:
# 1. Attempt rebase
# 2. On conflict:
#    a. Analyze conflict complexity
#    b. Auto-resolve trivial conflicts
#    c. AI-suggest medium conflicts
#    d. Ask user for risky conflicts
# 3. Run tests after each resolution
# 4. Continue or abort
```

## Desired Outcome

**A practical AI-assisted conflict resolution strategy that:**
1. ✅ Safely auto-resolves trivial conflicts
2. ✅ Suggests resolutions for medium-risk conflicts
3. ✅ Escalates risky conflicts to user
4. ✅ Validates all resolutions with tests
5. ✅ Maintains rollback capability
6. ✅ Integrates with worktree workflow

## Constraints

- 1인 개발 (no second reviewer)
- Windows + PyCharm + Python
- Codex CLI available
- Test suite exists (pytest)
- Safety-first approach (no auto-commit without validation)
