---
description: Show detailed status of a specific worktree
argument-hint: [branch-name]
allowed-tools: Bash(git:*)
---

Display detailed status information for the specified worktree:

1. Verify the worktree exists at `worktree/$1/`
2. Show git status (staged, unstaged, untracked files)
3. Show commit history relative to base branch
4. Show branch tracking information

Worktree to check: $1

Execute the following commands:
!cd worktree/$1 && git status
!cd worktree/$1 && git log --oneline -10
!cd worktree/$1 && git diff --stat
!cd worktree/$1 && git branch -vv

Provide a comprehensive summary including:
- Current branch and tracking information
- Number of commits ahead/behind base branch
- Modified, staged, and untracked files
- Overall worktree health status
