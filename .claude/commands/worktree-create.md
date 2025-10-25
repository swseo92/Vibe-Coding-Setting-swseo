---
description: Create a new cloned directory with full working environment
argument-hint: [branch-name]
allowed-tools: Bash(git:*), Bash(mkdir:*), Bash(uv:*), Bash(python:*)
---

Create a new cloned directory with complete working environment.

Branch name to create: $1

## SAFETY CHECKS (Run these first and STOP if any fail)

1. Check remote GitHub configuration:
!git remote -v

2. Check current branch is main or master:
!git branch --show-current

3. Check commit history exists (to prevent orphan branches):
!git log --oneline -1

**IMPORTANT**: Before proceeding, verify:
- ✅ Remote origin exists and points to github.com
- ✅ Current branch is "main" or "master"
- ✅ At least one commit exists

**If ANY check fails, STOP and warn the user with appropriate message:**
- No remote: "⚠️ No GitHub remote configured. Please set up remote origin first: `git remote add origin <url>`"
- Wrong branch: "⚠️ Not on main/master branch. Please switch to main/master before creating worktree: `git checkout main`"
- No commits: "⚠️ No commits found. Please create initial commit first: `git add . && git commit -m 'Initial commit'`"

## WORKTREE CREATION (Only run if all safety checks pass)

Execute the following commands:
!mkdir -p clone
!python -c "import shutil; import os; shutil.copytree('.', 'clone/$1', ignore=shutil.ignore_patterns('node_modules', '__pycache__', '.venv', 'venv', 'dist', 'build', '.pytest_cache', '.mypy_cache', 'clone', '.idea', '*.pyc', '*.pyo', '*.pyd', '.DS_Store'), dirs_exist_ok=False)"
!cd clone/$1 && git checkout -b $1
!cd clone/$1 && uv venv
!cd clone/$1 && (uv sync 2>/dev/null || echo "No pyproject.toml found, skipping sync")
!cd clone/$1 && (uv pip install -e . 2>/dev/null || echo "No setup.py/pyproject.toml found, skipping editable install")
!cd clone/$1 && git status --short && git branch -vv

Provide a summary of the created clone including:
- Branch name
- Clone directory path
- What was copied (including uncommitted changes and untracked files)
- Virtual environment status
- Dependencies installation status (uv sync)
- Editable install status (uv pip install -e .)
- Current git status
