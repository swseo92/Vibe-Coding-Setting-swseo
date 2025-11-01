# Merge Strategy: Rebase-First Workflow

**Based on:** Claude vs Codex Debate Round 3 (2025-11-01)
**Decision:** Rebase-first with fast-forward-only merge
**Confidence:** High (85%)

---

## Core Principle

**Always rebase before merging** to maintain linear history.

```
Feature branch:  A---B---C (feature)
                /
Main:           D---E---F (main)

After rebase:           A'--B'--C' (feature)
                       /
Main:           D---E---F (main)

After FF merge: D---E---F---A'--B'--C' (main, feature)
```

---

## Three Merge Scenarios

### Scenario 1: Feature Merge (Standard)

**Use Case:** Merge completed feature to main

**Script:** `merge-simple.ps1`

**Workflow:**
```powershell
# 1. Dry run (preview changes)
.\merge-simple.ps1 -FeatureBranch feature-auth -DryRun

# 2. Actual merge
.\merge-simple.ps1 -FeatureBranch feature-auth
```

**Steps:**
1. **Validate feature branch**
   - Working tree clean?
   - All tests pass?
   - Commits since main?

2. **Rebase onto origin/main**
   ```bash
   cd feature-auth
   git fetch origin
   git rebase origin/main
   ```

3. **Update main worktree**
   ```bash
   cd main
   git pull --ff-only
   ```

4. **Fast-forward merge**
   ```bash
   git merge --ff-only feature-auth
   ```

5. **Post-merge tests**
   ```bash
   pytest
   ```

6. **Push to origin**
   ```bash
   git push origin main
   ```

7. **Cleanup prompt**
   - Optionally delete feature worktree

**Why rebase first?**
- ✅ Linear history (no merge commits)
- ✅ Easier to bisect and rollback
- ✅ Cleaner `git log`

---

### Scenario 2: Hotfix Deployment (Fast-Track)

**Use Case:** Emergency fix needs immediate deployment

**Script:** `hotfix-merge.ps1`

**Workflow:**
```powershell
.\hotfix-merge.ps1 -HotfixBranch hotfix-security
```

**Steps:**
1. **Rebase hotfix onto main**
2. **Attempt fast-forward merge**
3. **Fallback to merge commit if FF fails**
4. **Smoke tests only** (skip full test suite)
5. **Auto-tag for rollback** (`hotfix-YYYYMMDD-HHMMSS`)
6. **Push immediately**

**Differences from Feature Merge:**
- ⚡ **Speed priority** - Smoke tests only
- 🏷️ **Auto-tagging** - Easy rollback
- ⚠️ **Merge commit fallback** - If main diverged, don't delay for rebase

**Fallback Strategy:**
```bash
# If FF merge fails
git merge hotfix-branch  # Creates merge commit
git push origin main
git tag "hotfix-$(date +%Y%m%d-%H%M%S)"
git push --tags
```

---

### Scenario 3: Conflict Resolution

**Use Case:** Rebase encounters conflicts

**Priority Order:**

**Tier 1: Git Rerere (Automatic) ⭐ Recommended**
```bash
# One-time global setup
git config --global rerere.enabled true
git config --global rerere.autoupdate true
```

**How it works:**
- Git records how you resolved conflicts
- Automatically applies same resolution on next rebase
- 100% safe, zero effort after setup

**Example:**
```
First rebase conflict:
<<<<<<< HEAD
old code
=======
new code
>>>>>>> feature

You resolve: → new code

Next time same conflict occurs: → Automatically resolved to "new code"
```

**Tier 2: PyCharm Merge Tool (Visual)**
- 3-way merge view
- Syntax highlighting
- 2-5 minutes resolution time
- Default for most conflicts

**Tier 3: AI Suggestion (Optional)**

Script: `conflict-helper.ps1`

```powershell
.\conflict-helper.ps1 conflicted-file.py
```

Options:
1. Open in PyCharm (recommended)
2. Get AI suggestion (manual apply only)
3. Manual resolution

**CRITICAL:** Never auto-apply AI suggestions
- Always review suggested resolution
- Run tests after applying
- Use for learning, not automation

**See `conflict-resolution.md` for detailed ROI analysis**

---

## Why Not Merge Commits by Default?

### Linear History Benefits

**With rebase (linear):**
```
git log --oneline
a3b4c5d Fix authentication bug
b4c5d6e Add password reset
c5d6e7f Update user model
d6e7f8g Initial user service
```

**With merge commits (branching):**
```
git log --oneline
a3b4c5d Merge branch 'feature-auth'
├─ b4c5d6e Fix authentication bug
├─ c5d6e7f Add password reset
│
d6e7f8g Merge branch 'feature-payment'
├─ e7f8g9h Add payment processing
├─ f8g9h0i Update billing model
```

**Why linear is better:**
- ✅ Easier to bisect (`git bisect` finds bug faster)
- ✅ Cleaner rollback (`git revert` simpler)
- ✅ Clearer history reading
- ✅ CI/CD simpler (every commit is testable state)

---

## When Rebase Fails: Manual Resolution

### Common Conflict Patterns

**1. Both modified same line**
```python
# main
def authenticate(user, password):
    return check_password_hash(user.password, password)

# feature
def authenticate(user, password):
    return bcrypt.verify(password, user.password_hash)

# Conflict: Choose one or merge logic
```

**Resolution:**
```python
def authenticate(user, password):
    # Use new bcrypt method
    return bcrypt.verify(password, user.password_hash)
```

**2. File renamed in one branch, modified in other**
```
main: renamed auth.py → authentication.py
feature: modified auth.py

Git doesn't know: Apply changes to authentication.py
```

**Resolution:**
```bash
# Accept rename, apply changes manually
git add authentication.py
git rm auth.py
# Manually copy changes from feature to authentication.py
git rebase --continue
```

**3. Import conflicts after rebase**
```python
# After rebase, import paths may break
from auth import authenticate  # File renamed!

# Fix:
from authentication import authenticate
```

---

## Post-Merge Validation

### Required Tests

**Before push:**
```powershell
# Run full test suite
pytest

# Check linting
flake8 src/
black --check src/

# Type checking
mypy src/
```

**If tests fail:**
```powershell
# Rollback merge
git reset --hard origin/main

# Fix in feature worktree
cd ..\feature-auth
# Fix issues
git add .
git commit -m "Fix test failures"

# Try merge again
cd ..\main
.\merge-simple.ps1 -FeatureBranch feature-auth
```

---

## Dry Run Benefits

**Always preview first:**
```powershell
.\merge-simple.ps1 -FeatureBranch feature-auth -DryRun
```

**Shows:**
- Commits to be merged
- Files changed
- Test results (runs tests on feature branch)
- Rebase conflicts (if any)

**Benefits:**
- ✅ No surprises
- ✅ Can prepare for conflicts
- ✅ Can abort if not ready
- ✅ Shows exactly what will happen

---

## Squash Commits: When and Why

### When to Squash (Before Merge)

**Scenarios:**
1. **WIP commits** - "wip", "fix typo", "oops"
2. **Review fixup** - "address review comments"
3. **Experimental commits** - Multiple attempts at same fix

**How:**
```bash
cd feature-auth
git rebase -i HEAD~5  # Interactive rebase last 5 commits

# In editor:
pick a1b2c3d Add authentication
squash b2c3d4e Fix typo
squash c3d4e5f Address review comments
pick d4e5f6g Add password reset
```

**Result:**
```
Before: 5 commits (some are WIP/fixups)
After: 2 commits (clean, atomic changes)
```

### When NOT to Squash

**Preserve history for:**
1. **Logical progression** - "Add model" → "Add service" → "Add API"
2. **Separate concerns** - "Fix bug" vs "Add feature"
3. **Bisect-ability** - Each commit is testable state

**Default:** Don't squash unless commits are truly WIP/fixup

---

## Update All Worktrees

**Script:** `update-all-worktrees.ps1`

**When to use:** Main branch updated, need to sync all feature worktrees

**Workflow:**
```powershell
.\update-all-worktrees.ps1
```

**Actions:**
1. **Main worktree:** `git pull --ff-only`
2. **Feature worktrees:** Offers to rebase onto origin/main

**Interactive prompts:**
```
Worktree: feature-auth
Last updated: 3 days ago
Rebase onto origin/main? (Y/N)
```

**Benefits:**
- ✅ Keep all worktrees up-to-date
- ✅ Minimize merge conflicts later
- ✅ See which worktrees are stale

---

## Best Practices

### Do's ✅

1. **Rebase frequently** - Daily or before merge
2. **Use --ff-only** - Ensures clean rebase
3. **Run tests before push** - Broken main is disaster
4. **Enable git rerere** - One-time setup, lifetime benefit
5. **Dry-run first** - Preview changes before merge

### Don'ts ❌

1. **Don't rebase published branches** - If pushed to shared remote
2. **Don't skip tests** - False confidence dangerous
3. **Don't force push to main** - Ever
4. **Don't merge without rebase** - Defeats linear history goal
5. **Don't squash by default** - Preserve logical commits

---

## Rollback Strategies

### If Merge Breaks Main

**Immediate rollback:**
```bash
git reset --hard origin/main
```

**If already pushed:**
```bash
git revert HEAD
git push origin main
```

**For hotfix:**
```bash
git reset --hard hotfix-20250101-143022  # Use auto-tag
```

---

## See Also

- **`architecture-decision.md`** - Why multi-project approach
- **`conflict-resolution.md`** - Git rerere vs AI detailed analysis
- **`best-practices.md`** - Comprehensive workflow guidelines

---

**Last Updated:** 2025-11-01
**Status:** Production validated
