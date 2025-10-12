---
description: Create a pull request from a worktree branch
argument-hint: [branch-name]
allowed-tools: Bash(git:*), Bash(gh:*)
---

Create a pull request for the specified worktree branch:

1. Navigate to the worktree directory at `worktree/$1/`
2. Check the current git status and commits
3. Get the commit history from the base branch
4. Create a PR with auto-generated summary based on commits
5. Return to the original directory

Branch to create PR for: $1

Execute the following commands in the worktree directory:
!cd worktree/$1 && git status
!cd worktree/$1 && git log --oneline -10
!cd worktree/$1 && gh pr create --fill

Provide a summary including:
- PR title and description
- Number of commits included
- PR URL
- Any conflicts or issues detected
