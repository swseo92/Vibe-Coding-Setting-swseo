---
description: Create a new git worktree with uv virtual environment
argument-hint: [branch-name]
allowed-tools: Bash(git:*), Bash(mkdir:*), Bash(uv:*)
---

Create a new git worktree with the following steps:

1. Check if worktree directory exists, if not create it
2. Get the current branch name as the base branch
3. Create a new worktree at `worktree/$1/` with a new branch `$1` based on the current branch
4. Navigate to the new worktree directory
5. Create a new uv virtual environment
6. If pyproject.toml exists in root, run `uv sync`, otherwise if requirements.txt exists, run `uv pip install -r ../../requirements.txt`
7. Display the created worktree path and branch information

Branch name to create: $1

Execute the following commands:
!mkdir -p worktree
!git worktree add -b $1 worktree/$1
!cd worktree/$1 && uv venv && (uv sync 2>/dev/null || uv pip install -r ../../requirements.txt 2>/dev/null || echo "No dependencies file found")
!git worktree list

Provide a summary of the created worktree including:
- Branch name
- Worktree path
- Virtual environment status
