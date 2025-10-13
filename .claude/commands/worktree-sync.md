---
description: Sync a cloned directory with the original repository
argument-hint: [branch-name]
allowed-tools: Bash(git:*)
---

Synchronize the specified cloned directory with the original repository:

1. Get the current branch of the root directory (base branch)
2. Navigate to the clone at `clone/$1/`
3. Fetch latest changes from origin (the original local repository)
4. Merge the base branch from origin into the clone's branch
5. Display any conflicts or issues

Clone to sync: $1

Execute the following commands:
!git branch --show-current
!cd clone/$1 && git fetch origin
!cd clone/$1 && git merge origin/$(git -C ../.. branch --show-current)
!cd clone/$1 && git status

Provide a summary including:
- Base branch name
- Number of commits merged
- Any merge conflicts detected
- Current status of the clone

Note: If there are conflicts, you will need to resolve them manually in the clone directory.
The clone's origin points to the original local repository, so this fetches changes from there.
