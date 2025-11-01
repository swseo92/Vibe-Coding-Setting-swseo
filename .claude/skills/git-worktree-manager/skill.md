---
name: git-worktree-manager
description: Manage parallel development workflows using git worktree for Python projects in PyCharm on Windows. Use this skill when users need to create independent development environments for multiple features, handle merge conflicts, or manage worktree lifecycle (create/merge/cleanup). Optimized for solo developers working on Python projects with pytest test suites.
---

# Git Worktree Manager

This skill provides a complete workflow for managing parallel development using git worktree, specifically optimized for Python projects in PyCharm on Windows.

## When to Use This Skill

Activate this skill when users request:

- **"Create a new worktree for feature development"** - Set up independent development environment
- **"Merge my feature branch to main"** - Rebase-first merge workflow
- **"Deploy a hotfix urgently"** - Fast-track emergency fixes
- **"Resolve merge conflicts"** - Conflict resolution guidance
- **"Clean up worktrees"** - Safe worktree management
- **"Setup PyCharm for worktree"** - IDE integration help
- **"What's the best merge strategy?"** - Workflow guidance

**Appropriate scenarios:**
1. **Parallel feature development** - Multiple features in progress simultaneously
2. **Experimental branches** - Test ideas without affecting main work
3. **Code review workflow** - Review PRs while continuing feature work
4. **Hotfix deployment** - Urgent fixes without disrupting feature branches

## Core Architecture

### Multi-Project Approach

Each worktree = independent PyCharm project with:
- ✅ Independent `.venv` (Python virtual environment)
- ✅ Independent `.env.local` (environment variables, secrets scrubbed)
- ✅ Independent DB copy (avoid SQLite locking)
- ✅ Shared git repository (via worktree link)
- ✅ Centralized git hooks (`core.hooksPath`)

**Directory structure:**
```
C:\ws\my-project\
├── main\                    # Main branch worktree
│   ├── .git\               # Shared git repo
│   ├── .venv\
│   └── src\
├── feature-auth\            # Feature worktree
│   ├── .git                # Worktree link
│   ├── .venv\              # Independent
│   └── src\
```

**Key decisions:**
- Short paths (`C:\ws\`) - Avoid Windows 260-char limit
- `venv` over `uv` - Windows stability
- DB copy default - Avoid locking conflicts
- Minimal symlinks - Windows fragility

Reference: `references/architecture-decision.md` for detailed rationale.

## Workflows

### 1. Create Worktree (Feature Development)

**Script:** `scripts/worktree-create.ps1`

```powershell
.\worktree-create.ps1 -BranchName feature-auth
```

**What it does:**
1. Validates environment (long paths, Python, Git)
2. Creates git worktree
3. Sets up independent `.venv` with dependencies
4. Copies `.env` → `.env.local` (masks secrets)
5. Copies DB (independent by default)
6. Configures git hooks
7. Generates `README-worktree.md` with setup instructions
8. Runs smoke tests

**PyCharm integration:**
```
File > Open > C:\ws\my-project\feature-auth
Settings > Python Interpreter > .venv\Scripts\python.exe
Settings > Plugins > Install "EnvFile" (for .env.local)
```

Reference: `references/pycharm-integration.md` for detailed setup.

### 2. Merge Worktree (Rebase-First)

**Script:** `scripts/merge-simple.ps1`

```powershell
# Dry run first (recommended)
.\merge-simple.ps1 -FeatureBranch feature-auth -DryRun

# Actual merge
.\merge-simple.ps1 -FeatureBranch feature-auth
```

**Workflow:**
1. Validates feature branch (clean, tests pass)
2. Rebases feature onto origin/main
3. Updates main worktree
4. Fast-forward merge
5. Post-merge tests
6. Push to origin
7. Cleanup prompt

**Key principle:** Rebase + FF-only for linear history

Reference: `references/merge-strategy.md` for 3 merge scenarios.

### 3. Hotfix Deployment (Fast-Track)

**Script:** `scripts/hotfix-merge.ps1`

```powershell
.\hotfix-merge.ps1 -HotfixBranch hotfix-security
```

**Workflow:**
1. Rebase hotfix onto main
2. Attempt FF merge
3. Fallback to merge commit if FF fails
4. Smoke tests only (speed priority)
5. Auto-tag for rollback
6. Push immediately

**Fallback strategy:** If FF fails, creates merge commit with verbose message.

### 4. Conflict Resolution

**Priority order:**

**Tier 1: Git Rerere (Auto)** ⭐ Recommended
```powershell
# One-time setup
git config --global rerere.enabled true
git config --global rerere.autoupdate true
```
- Automatically reuses past conflict resolutions
- 100% safe
- Zero effort after setup

**Tier 2: PyCharm Merge Tool (Visual)**
- Default for most conflicts
- 3-way merge view
- 2-5 minutes resolution time

**Tier 3: AI Suggestion (Optional)**

**Script:** `scripts/conflict-helper.ps1`

```powershell
.\conflict-helper.ps1 auth.py
```

Options:
1. Open in PyCharm (recommended)
2. Get AI suggestion (manual apply only)
3. Manual resolution

**CRITICAL:** Never auto-apply AI suggestions. Use for learning only.

**Why not AI auto-resolve?**
- ROI doesn't justify complexity (1-person projects)
- Confidence scores unreliable
- Test coverage assumptions risky
- User fatigue from prompts

Reference: `references/conflict-resolution.md` for detailed analysis.

### 5. Cleanup Worktree

**Script:** `scripts/cleanup-worktree.ps1`

```powershell
.\cleanup-worktree.ps1 -BranchName feature-auth
```

**What it does:**
1. Archives DB (optional)
2. Handles file locks gracefully
3. Removes git worktree
4. Cleans filesystem

**Safety features:**
- Confirmation prompts
- Retry logic for locked files
- DB archiving to `db-archives/`

### 6. Update All Worktrees

**Script:** `scripts/update-all-worktrees.ps1`

```powershell
.\update-all-worktrees.ps1
```

**Use when:** Main branch updated, need to sync all feature worktrees

**Workflow:**
- Main worktree: `git pull --ff-only`
- Feature worktrees: Offers to rebase onto origin/main

## Best Practices

### Do's ✅

1. **Enable git rerere** - One-time setup, lifetime benefit
2. **Rebase frequently** - Daily or before merge to minimize conflicts
3. **Use dry-run** - Always preview merge changes
4. **Short paths** - `C:\ws\` to avoid 260-char limit
5. **Independent DBs** - Default to copies, share only when safe
6. **Test before/after** - Merge validation critical

### Don'ts ❌

1. **Don't squash by default** - Preserve commit history
2. **Don't trust AI auto-resolve** - ROI negative for solo devs
3. **Don't skip tests** - False confidence dangerous
4. **Don't share symlinks** - Windows fragility (except git hooks)
5. **Don't delete worktree while PyCharm open** - File locks

Reference: `references/best-practices.md` for comprehensive guide.

## Troubleshooting

### Path length errors
```powershell
# Enable long paths (Admin)
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -Name 'LongPathsEnabled' -Value 1
# Restart required
```

### Rebase conflicts
```powershell
# Fix conflicts
git add .
git rebase --continue

# Or abort
git rebase --abort
```

### FF merge fails
```powershell
# Main diverged - use regular merge
git merge feature-branch

# Or rebase feature again
cd ..\feature-branch
git rebase origin/main
cd ..\main
git merge --ff-only feature-branch
```

### Tests fail after merge
```powershell
# Rollback
git reset --hard origin/main

# Fix in feature worktree and re-merge
```

Reference: `references/pycharm-integration.md` for IDE-specific issues.

## Script Usage Summary

| Script | Purpose | Frequency |
|--------|---------|-----------|
| `worktree-create.ps1` | Create new worktree | Per feature |
| `merge-simple.ps1` | Merge feature to main | Per feature |
| `hotfix-merge.ps1` | Emergency deployment | As needed |
| `cleanup-worktree.ps1` | Remove worktree | Per feature |
| `update-all-worktrees.ps1` | Sync after main changes | Weekly |
| `conflict-helper.ps1` | Conflict assistance | Rarely |

## References

For detailed technical background and design decisions:

- **`references/architecture-decision.md`** - Rounds 1-2: Why Multi-Project, Windows optimizations
- **`references/merge-strategy.md`** - Round 3: Rebase-first workflow, 3 scenarios
- **`references/conflict-resolution.md`** - Round 4: Git rerere vs AI, ROI analysis
- **`references/pycharm-integration.md`** - IDE setup, daily workflow, troubleshooting
- **`references/best-practices.md`** - Comprehensive do's/don'ts, performance tips

## Quick Start

**First time setup:**
```powershell
# 1. Enable long paths (Admin)
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -Name 'LongPathsEnabled' -Value 1

# 2. Enable git rerere
git config --global rerere.enabled true

# 3. Copy scripts to project root
# (Scripts are in .claude/skills/git-worktree-manager/scripts/)
```

**Daily workflow:**
```powershell
# Create worktree
.\worktree-create.ps1 -BranchName feature-name

# Work in PyCharm (File > Open > C:\ws\project\feature-name)

# Merge when done
.\merge-simple.ps1 -FeatureBranch feature-name -DryRun
.\merge-simple.ps1 -FeatureBranch feature-name

# Cleanup
.\cleanup-worktree.ps1 -BranchName feature-name
```

## Limitations

This skill is optimized for:
- ✅ Python projects
- ✅ Windows environment
- ✅ PyCharm IDE
- ✅ Solo developers
- ✅ pytest test suites

May require adaptation for:
- ⚠️ Team environments (adjust for code review)
- ⚠️ Non-Python projects (script logic changes)
- ⚠️ Linux/Mac (bash equivalents needed)
- ⚠️ Large teams (CI/CD integration)

## Design Philosophy

1. **Safety First** - Rollback mechanisms, validation, dry-run modes
2. **Pragmatic ROI** - Only automate what saves significant time
3. **Windows-Optimized** - Address platform-specific pain points
4. **Test-Driven** - Validation critical, but not sufficient alone
5. **Progressive Disclosure** - Simple defaults, advanced options available

---

**Version:** 1.0.0
**Based on:** Claude vs Codex debate (4 rounds, 2025-11-01)
**Confidence:** 85-90% (High)
**Status:** Production ready
