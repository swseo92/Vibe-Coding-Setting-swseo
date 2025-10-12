---
description: List all git worktrees with their status
allowed-tools: Bash(git:*)
---

Display all git worktrees in this repository with detailed information:

Execute the following commands:
!git worktree list
!git branch -vv

Provide a formatted summary including:
- List of all worktrees with their paths
- Associated branches
- Current HEAD commit
- Whether each worktree has uncommitted changes
