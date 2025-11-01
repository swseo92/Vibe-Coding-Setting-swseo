---
name: git-worktree-manager
description: This skill should be used to manage parallel development workflows using git worktree for Python projects in PyCharm on Windows. Trigger when user says "create worktree", "워크트리 생성", "worktree 생성", "merge branch", "브랜치 병합", "기능 브랜치 merge", "resolve conflict", "충돌 해결", "cleanup worktree", or "워크트리 정리". Optimized for solo developers working on Python projects with pytest test suites.
---

# Git Worktree Manager

Manage parallel development workflows using git worktree for Python projects on Windows.

---

## When to Use This Skill

Use this skill when users request:

**English triggers:**
- "Create a new worktree for feature development"
- "Merge my feature branch to main"
- "Deploy a hotfix urgently"
- "Resolve merge conflicts"
- "Clean up worktrees"
- "Setup PyCharm for worktree"

**Korean triggers:**
- "워크트리 생성" / "worktree 생성"
- "브랜치로 worktree 만들어줘"
- "feature 브랜치 merge" / "기능 브랜치 병합"
- "hotfix 배포" / "긴급 수정"
- "conflict 해결" / "충돌 해결"
- "워크트리 정리" / "worktree cleanup"

**Appropriate scenarios:**
1. Parallel feature development
2. Experimental branches
3. Code review workflow
4. Hotfix deployment

---

## Core Architecture

Each worktree is an independent PyCharm project with separate venv, environment variables, and database.

**Directory structure:**
```
C:\ws\my-project\
├── main\          # Main worktree
│   ├── .git\      # Shared git repository
│   ├── .venv\     # Independent environment
│   └── src\
├── feature-auth\  # Feature worktree
│   ├── .git       # Worktree link
│   ├── .venv\     # Independent environment
│   └── src\
```

See `references/architecture-decision.md` for detailed rationale and Windows optimizations.

---

## Workflows

### 1. Create Worktree

Execute `scripts/worktree-create.ps1`:

```powershell
.\worktree-create.ps1 -BranchName feature-auth
```

Creates git worktree with independent venv, environment, and database.

Guide users through PyCharm setup using `references/pycharm-integration.md`.

### 2. Merge Worktree

Execute `scripts/merge-simple.ps1`:

```powershell
# Preview changes first
.\merge-simple.ps1 -FeatureBranch feature-auth -DryRun

# Perform merge
.\merge-simple.ps1 -FeatureBranch feature-auth
```

Rebases feature onto main, runs tests, and performs fast-forward merge.

See `references/merge-strategy.md` for rebase-first workflow details.

### 3. Hotfix Deployment

Execute `scripts/hotfix-merge.ps1`:

```powershell
.\hotfix-merge.ps1 -HotfixBranch hotfix-security
```

Fast-track merge with smoke tests, auto-tagging, and immediate push.

### 4. Conflict Resolution

**Priority order:**

1. **Git Rerere (Automatic)** - Reuses recorded resolutions
2. **PyCharm Merge Tool** - Visual 3-way merge
3. **AI Suggestion** - Educational only, manual application

Execute `scripts/conflict-helper.ps1` for assistance:

```powershell
.\conflict-helper.ps1 conflicted-file.py
```

See `references/conflict-resolution.md` for detailed git rerere setup and ROI analysis.

### 5. Cleanup Worktree

Execute `scripts/cleanup-worktree.ps1`:

```powershell
.\cleanup-worktree.ps1 -BranchName feature-auth
```

Archives database, removes git worktree, and cleans filesystem.

### 6. Update All Worktrees

Execute `scripts/update-all-worktrees.ps1`:

```powershell
.\update-all-worktrees.ps1
```

Syncs main worktree and offers to rebase all feature worktrees.

---

## Quick Start

**First-time setup:**

```powershell
# 1. Enable long paths (Admin, one-time)
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -Name 'LongPathsEnabled' -Value 1

# 2. Enable git rerere (one-time)
git config --global rerere.enabled true
git config --global rerere.autoupdate true

# 3. Scripts available in skill directory
# .claude/skills/git-worktree-manager/scripts/
```

**Daily workflow:**

```powershell
# Create worktree
.\worktree-create.ps1 -BranchName feature-name

# Work in PyCharm: File > Open > C:\ws\project\feature-name

# Merge when done
.\merge-simple.ps1 -FeatureBranch feature-name -DryRun
.\merge-simple.ps1 -FeatureBranch feature-name

# Cleanup
.\cleanup-worktree.ps1 -BranchName feature-name
```

---

## Scripts Summary

| Script | Purpose | Reference |
|--------|---------|-----------|
| `worktree-create.ps1` | Create worktree with venv, env, DB | `architecture-decision.md` |
| `merge-simple.ps1` | Rebase-first merge to main | `merge-strategy.md` |
| `hotfix-merge.ps1` | Fast-track emergency deployment | `merge-strategy.md` |
| `cleanup-worktree.ps1` | Safe worktree removal | - |
| `update-all-worktrees.ps1` | Sync all worktrees with main | - |
| `conflict-helper.ps1` | Conflict resolution assistance | `conflict-resolution.md` |

---

## Best Practices

Follow `references/best-practices.md` for comprehensive guidelines.

**Essential do's:**
- Enable git rerere (one-time setup)
- Rebase frequently (daily or before merge)
- Use dry-run mode before merging
- Test before pushing

**Critical don'ts:**
- Don't skip tests
- Don't trust AI auto-resolve
- Don't delete worktree while PyCharm open
- Don't force push to main

---

## Troubleshooting

See `references/pycharm-integration.md` for IDE-specific issues:
- Wrong Python interpreter
- Multiple VCS roots
- Tests not discovered
- Environment variables not loaded
- Import errors
- PyCharm indexing slow

---

## References

Detailed documentation for each workflow aspect:

- **`references/architecture-decision.md`** - Multi-project approach, Windows optimizations
- **`references/merge-strategy.md`** - Rebase-first workflow, 3 merge scenarios
- **`references/conflict-resolution.md`** - Git rerere vs AI, ROI analysis
- **`references/pycharm-integration.md`** - IDE setup, daily workflow, troubleshooting
- **`references/best-practices.md`** - Comprehensive do's/don'ts, design philosophy
- **`references/implementation-guide.md`** - Technical implementation details

---

## Limitations

Optimized for:
- ✅ Python projects
- ✅ Windows environment
- ✅ PyCharm IDE
- ✅ Solo developers
- ✅ pytest test suites

May require adaptation for:
- ⚠️ Team environments
- ⚠️ Non-Python projects
- ⚠️ Linux/Mac (bash equivalents needed)
- ⚠️ Large teams (CI/CD integration)

---

**Version:** 1.0.0
**Based on:** Claude vs Codex debate (4 rounds, 2025-11-01)
**Confidence:** 85-90% (High)
**Status:** Production ready
