---
description: Delete a git worktree and its branch
argument-hint: [branch-name]
allowed-tools: Bash(git:*), Bash(rm:*)
---

Delete the specified git worktree with the following steps:

1. Check if the worktree exists at `worktree/$1/`
2. Remove the worktree using git worktree remove
3. Delete the branch if it exists
4. Remove the worktree directory if it still exists
5. Display the result

Branch/worktree to delete: $1

Execute the following commands:
!git worktree list
!git worktree remove worktree/$1 --force
!git branch -D $1
!git worktree list

Provide a summary of the deletion including:
- Whether the worktree was successfully removed
- Whether the branch was deleted
- Current list of remaining worktrees
