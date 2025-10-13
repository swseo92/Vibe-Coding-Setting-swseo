---
description: Create a pull request from a cloned directory branch
argument-hint: [branch-name]
allowed-tools: Bash(git:*), Bash(gh:*)
---

Create a pull request for the specified cloned directory branch:

1. Navigate to the clone directory at `clone/$1/`
2. Check the current git status and commits
3. Get the commit history from the base branch
4. Create a PR with auto-generated summary based on commits
5. Return to the original directory

Branch to create PR for: $1

Execute the following commands in the clone directory:
!cd clone/$1 && git status
!cd clone/$1 && git log --oneline -10
!cd clone/$1 && gh pr create --fill

Provide a summary including:
- PR title and description
- Number of commits included
- PR URL
- Any conflicts or issues detected
