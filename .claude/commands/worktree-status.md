---
description: Show detailed status of a specific cloned directory
argument-hint: [branch-name]
allowed-tools: Bash(git:*)
---

Display detailed status information for the specified cloned directory:

1. Verify the clone exists at `clone/$1/`
2. Show git status (staged, unstaged, untracked files)
3. Show commit history relative to base branch
4. Show branch tracking information

Clone to check: $1

Execute the following commands:
!cd clone/$1 && git status
!cd clone/$1 && git log --oneline -10
!cd clone/$1 && git diff --stat
!cd clone/$1 && git branch -vv

Provide a comprehensive summary including:
- Current branch and tracking information
- Number of commits ahead/behind origin branch
- Modified, staged, and untracked files
- Overall clone health status
