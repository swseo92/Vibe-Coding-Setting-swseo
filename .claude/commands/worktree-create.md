---
description: Create a new cloned directory with full working environment
argument-hint: [branch-name]
allowed-tools: Bash(git:*), Bash(mkdir:*), Bash(uv:*), Bash(python:*)
---

Create a new cloned directory with complete working environment:

1. Create clone directory if it doesn't exist
2. Copy entire working directory to `clone/$1/` (including uncommitted changes, .claude, .specify, etc.)
3. Exclude large/generated directories: node_modules, __pycache__, .venv, venv, dist, build, .pytest_cache, .mypy_cache, .idea
4. Navigate to the cloned directory, reset tracked files to clean main state (keep untracked files), and create a new branch `$1`
5. Create a new uv virtual environment
6. Install dependencies with uv sync
7. Install package in editable mode with uv pip install -e .
8. Display the created clone information

Branch name to create: $1

Execute the following commands:
!mkdir -p clone
!python -c "import shutil; import os; shutil.copytree('.', 'clone/$1', ignore=shutil.ignore_patterns('node_modules', '__pycache__', '.venv', 'venv', 'dist', 'build', '.pytest_cache', '.mypy_cache', 'clone', '.idea', '*.pyc', '*.pyo', '*.pyd', '.DS_Store'), dirs_exist_ok=False)"
!cd clone/$1 && (git checkout master 2>/dev/null || git checkout main) && git reset --hard HEAD && git checkout -b $1
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
