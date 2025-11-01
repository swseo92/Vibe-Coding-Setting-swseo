# Best Practices for Git Worktree Management

Comprehensive guide for optimal worktree workflows on Windows with Python projects.

---

## Do's ✅

### 1. Enable Git Rerere (One-Time Setup)

**Command:**
```bash
git config --global rerere.enabled true
git config --global rerere.autoupdate true
```

**Benefit:** Automatic conflict resolution for repeated patterns

**Time Investment:** 30 seconds setup → Saves hours over time

### 2. Rebase Frequently

**Daily rebase:**
```powershell
cd C:\ws\my-project\feature-auth
git fetch origin
git rebase origin/main
```

**Benefits:**
- ✅ Smaller conflicts (recent changes only)
- ✅ Easier resolution (changes fresh in memory)
- ✅ Git rerere builds resolution history

**Recommendation:** Rebase daily or before starting work

### 3. Use Dry-Run Before Merging

**Always preview:**
```powershell
.\merge-simple.ps1 -FeatureBranch feature-auth -DryRun
```

**Shows:**
- Commits to be merged
- Files changed
- Test results
- Potential conflicts

**Benefits:**
- ✅ No surprises
- ✅ Can prepare for conflicts
- ✅ Can abort if not ready

### 4. Use Short Paths

**Good:**
```
C:\ws\my-project\feature-auth\
└── 30 characters
```

**Bad:**
```
C:\Users\username\Documents\Projects\MyAwesomeProject\worktrees\feature-authentication\
└── 95 characters (approaching Windows 260-char limit)
```

**Recommendation:** Use `C:\ws\` as workspace root

### 5. Copy DB by Default

**Default behavior:**
```powershell
.\worktree-create.ps1 -BranchName feature-auth
# Creates independent db-feature-auth.sqlite3
```

**Only use ShareDB when:**
- Read-only access needed
- Developer Mode enabled
- Aware of locking issues

### 6. Test Before Pushing

**Always run:**
```powershell
# Full test suite
pytest

# Linting
flake8 src/

# Type checking (if using)
mypy src/
```

**Broken main is disaster:** One broken commit blocks entire team

### 7. Clean Up Old Worktrees

**Regular cleanup:**
```powershell
.\cleanup-worktree.ps1 -BranchName old-feature
```

**Frequency:** After feature merged or abandoned

**Benefit:** Save disk space, reduce clutter

### 8. Use Independent venv

**Always create:**
```powershell
python -m venv .venv
```

**Never share:** venv across worktrees causes dependency conflicts

### 9. Enable Long Paths

**One-time (Admin):**
```powershell
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -Name 'LongPathsEnabled' -Value 1
# Restart required
```

**Prevents:** Path too long errors on deep directory structures

### 10. Commit Often, Push Carefully

**Commit frequently:**
- Small, atomic commits
- Easy to revert if needed

**Push after validation:**
- Tests pass
- Linting clean
- Feature complete (or reasonable checkpoint)

---

## Don'ts ❌

### 1. Don't Squash by Default

**Preserve logical commits:**
```
✅ Good commit history:
- Add user authentication
- Add password reset
- Add email verification

❌ Bad squash:
- Implement authentication feature (all changes)
```

**Exception:** Squash WIP commits before merge
```
Before:
- Add auth
- Fix typo
- Fix another typo
- Add tests

After squash:
- Add user authentication with tests
```

### 2. Don't Trust AI Auto-Resolve

**Never auto-apply AI suggestions**

**Problem:**
- Confidence scores unreliable (60-80% accuracy)
- Missing business context
- False confidence dangerous

**Safe approach:**
- Use AI for learning
- Manually review all suggestions
- Apply manually after understanding

### 3. Don't Skip Tests

**Always run tests before:**
- Pushing to remote
- Merging to main
- Creating pull request

**False confidence is dangerous:**
```
"It compiles, ship it!" ❌
vs.
"Tests pass, ship it!" ✅
```

### 4. Don't Share Symlinks (Except Hooks)

**Avoid symlinking:**
- ❌ `.venv` - Dependency conflicts
- ❌ Database files - Locking issues
- ❌ Source code - Defeats isolation purpose

**Only symlink:**
- ✅ Git hooks - Read-only, DRY updates

**Windows symlinks fragile:** Permissions, junction points, file system issues

### 5. Don't Delete Worktree While PyCharm Open

**Problem:**
```
PyCharm has files open
→ Delete fails with "Access denied"
→ Manual cleanup required
```

**Correct workflow:**
```
1. Close PyCharm project
2. Run cleanup-worktree.ps1
3. Wait for completion
4. Open other project if needed
```

### 6. Don't Rebase Published Branches

**Never rebase if:**
- Branch pushed to shared remote
- Other developers working on it
- Pull request already created

**Safe to rebase:**
- Local-only branches
- Feature branches (before PR)
- Your personal remote branches

**Why:** Rebasing rewrites history, breaks others' work

### 7. Don't Force Push to Main

**Never ever:**
```bash
git push --force origin main  # DISASTER
```

**Why:**
- Deletes others' commits
- Breaks CI/CD
- Team loses work

**Exception:** None. Never force push to main.

### 8. Don't Mix Worktree Approaches

**Choose one:**
- ✅ Multi-project (each worktree = separate PyCharm project)
- ❌ Single project with multiple roots (conflicts)

**Mixing causes:**
- Interpreter confusion
- Run configuration conflicts
- VCS root issues

### 9. Don't Forget to Update All Worktrees

**After main changes:**
```powershell
.\update-all-worktrees.ps1
```

**Prevents:**
- Stale feature branches
- Larger conflicts later
- Confusion about current state

### 10. Don't Commit .env with Secrets

**Always use .env.local:**
```bash
# .gitignore
.env.local
*.local

# Committed
.env.example  # Template without secrets
```

**worktree-create.ps1 masks secrets automatically:**
```bash
# main/.env
SECRET_KEY=real-secret-123

# feature/.env.local
# MASKED - SET MANUALLY: SECRET_KEY=***
```

---

## Design Philosophy

### 1. Safety First

**Principle:** Rollback mechanisms at every step

**Examples:**
- Dry-run mode before merge
- Automatic rollback on test failure
- DB archiving before cleanup
- Confirmation prompts for destructive operations

**Trade-off:** Slight overhead for massive safety gain

### 2. Pragmatic ROI

**Principle:** Only automate what saves significant time

**Examples:**
- ✅ Git rerere (2 min setup → saves hours)
- ✅ Script automation (standardized workflows)
- ❌ AI auto-resolve (complex setup, unreliable)

**Rule:** If setup time > time saved in 6 months, don't automate

### 3. Windows-Optimized

**Principle:** Address platform-specific pain points

**Examples:**
- Short paths (`C:\ws\`)
- Long path registry setting
- PowerShell scripts (native)
- venv over uv (stability)
- Minimal symlinks (fragility)

**Why:** Windows has unique quirks, embrace them

### 4. Test-Driven

**Principle:** Tests are critical but not sufficient

**Examples:**
- ✅ Run tests before/after merge
- ✅ Smoke tests after hotfix
- ⚠️ Tests can't catch business logic errors
- ⚠️ Human review still needed

**Balance:** Automation + human judgment

### 5. Progressive Disclosure

**Principle:** Simple defaults, advanced options available

**Examples:**
- Default: Copy DB (safe, simple)
- Advanced: `--ShareDB` flag (expert mode)
- Default: Full tests (thorough)
- Advanced: `--SkipTests` flag (speed when safe)

**User Experience:** Works out of box, customizable for experts

---

## Performance Tips

### 1. Exclude Large Directories from PyCharm

```
Right-click:
- .venv/ → Mark as Excluded
- node_modules/ → Mark as Excluded
- __pycache__/ → Mark as Excluded
```

**Result:** Faster indexing, less memory usage

### 2. Use SSD for Worktrees

**HDD:**
- Slow venv creation (5-10 min)
- Slow test runs
- Slow PyCharm indexing

**SSD:**
- Fast venv creation (30-60 sec)
- Fast test runs
- Fast PyCharm indexing

**Investment:** Worth it for daily use

### 3. Limit Concurrent Worktrees

**Recommendation:** 3-5 active worktrees max

**Why:**
- Each venv ~50-200MB
- PyCharm memory per project
- Mental overhead tracking many features

**Practice:** Delete merged/abandoned worktrees promptly

### 4. Use pytest-xdist for Parallel Tests

```powershell
pip install pytest-xdist
pytest -n auto  # Run tests in parallel
```

**Speedup:** 2-4x faster on multi-core machines

### 5. Cache pip Packages

```powershell
# Set PIP_CACHE_DIR once
$env:PIP_CACHE_DIR = "C:\pip-cache"

# Now pip installs faster (downloads cached)
pip install -r requirements.txt
```

**Benefit:** Faster venv creation across worktrees

---

## Workflow Optimization

### Morning Routine

```powershell
# 1. Update main
cd C:\ws\my-project\main
git pull --ff-only

# 2. Rebase all features
cd ..\feature-auth
git rebase origin/main

cd ..\feature-payment
git rebase origin/main

# Or use script:
.\update-all-worktrees.ps1
```

**Time:** 2-5 minutes
**Benefit:** Start day with clean state

### Pre-Merge Checklist

- [ ] All tests pass
- [ ] Linting clean
- [ ] Type checking passes (if using)
- [ ] Dry-run successful
- [ ] Code reviewed (if team)
- [ ] Documentation updated
- [ ] Migration scripts work (if DB changes)

### Post-Merge Checklist

- [ ] Tests pass in main
- [ ] Push successful
- [ ] CI/CD green (if applicable)
- [ ] Feature worktree cleaned up
- [ ] Team notified (if applicable)

---

## Common Mistakes and Fixes

### Mistake 1: Forgetting to Activate venv

**Symptom:**
```powershell
pytest  # ModuleNotFoundError
```

**Fix:**
```powershell
.\.venv\Scripts\Activate.ps1
pytest  # Now works
```

**Prevention:** PyCharm terminal auto-activates

### Mistake 2: Pushing to Wrong Branch

**Symptom:**
```
Feature changes appear in main
```

**Fix:**
```bash
# Undo push (if caught immediately)
git reset --hard HEAD~1
git push --force origin feature-auth

# Move commits to correct branch
git cherry-pick <commit-hash>
```

**Prevention:** Check branch before commit
```bash
git branch  # Show current branch
```

### Mistake 3: Deleting Wrong Worktree

**Symptom:**
```
Deleted main worktree by accident
```

**Fix:**
```bash
# If .git still exists
git worktree add main main

# Recreate venv
python -m venv .venv
pip install -r requirements.txt
```

**Prevention:** Confirmation prompts in scripts

---

## See Also

- **`architecture-decision.md`** - Design rationale
- **`merge-strategy.md`** - Rebase-first workflow
- **`conflict-resolution.md`** - Git rerere setup
- **`pycharm-integration.md`** - IDE optimization

---

**Last Updated:** 2025-11-01
**Status:** Production validated
