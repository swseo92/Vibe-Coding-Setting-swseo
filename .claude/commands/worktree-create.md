---
description: Create a new cloned directory with full working environment
argument-hint: [branch-name]
allowed-tools: Bash(git:*), Bash(mkdir:*), Bash(uv:*), Bash(python:*)
---

Create a new cloned directory with complete working environment:

1. Create clone directory if it doesn't exist
2. Copy entire working directory to `clone/$1/` (including uncommitted changes, .claude, .specify, etc.)
3. Exclude large/generated directories: node_modules, __pycache__, .venv, venv, dist, build, .pytest_cache, .mypy_cache, .idea
4. Navigate to the cloned directory and create a new branch `$1` from main
5. Create a new uv virtual environment
6. Install dependencies with uv
7. Display the created clone information

Branch name to create: $1

Execute the following commands:
!mkdir -p clone
!python -c "import shutil; import os; shutil.copytree('.', 'clone/$1', ignore=shutil.ignore_patterns('node_modules', '__pycache__', '.venv', 'venv', 'dist', 'build', '.pytest_cache', '.mypy_cache', 'clone', '.idea', '*.pyc', '*.pyo', '*.pyd', '.DS_Store'), dirs_exist_ok=False)"
!cd clone/$1 && (git checkout master 2>/dev/null || git checkout main) && git checkout -b $1
!cd clone/$1 && uv venv && (uv sync 2>/dev/null || uv pip install -r ../../requirements.txt 2>/dev/null || echo "No dependencies file found")
!cd clone/$1 && git status --short && git branch -vv

Provide a summary of the created clone including:
- Branch name
- Clone directory path
- What was copied (including uncommitted changes)
- Virtual environment status
- Current git status
