---
description: Sync a worktree branch with the base branch
argument-hint: [branch-name]
allowed-tools: Bash(git:*)
---

Synchronize the specified worktree branch with its base branch:

1. Get the current branch of the root directory (base branch)
2. Navigate to the worktree at `worktree/$1/`
3. Fetch latest changes from remote
4. Merge or rebase the base branch into the worktree branch
5. Display any conflicts or issues

Branch to sync: $1

Execute the following commands:
!git branch --show-current
!cd worktree/$1 && git fetch origin
!cd worktree/$1 && git merge origin/$(git -C ../.. branch --show-current)
!cd worktree/$1 && git status

Provide a summary including:
- Base branch name
- Number of commits merged
- Any merge conflicts detected
- Current status of the worktree

Note: If there are conflicts, you will need to resolve them manually in the worktree directory.
