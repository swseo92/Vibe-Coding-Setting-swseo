---
description: Delete a cloned directory
argument-hint: [branch-name]
allowed-tools: Bash(rm:*), Bash(ls:*)
---

Delete the specified cloned directory with the following steps:

1. Check if the clone exists at `clone/$1/`
2. Remove the entire cloned directory
3. Display the result

Clone directory to delete: $1

Execute the following commands:
!ls -la clone/ 2>/dev/null || echo "clone directory not found"
!rm -rf clone/$1
!ls -la clone/ 2>/dev/null || echo "clone directory is now empty"

Provide a summary of the deletion including:
- Whether the clone was successfully removed
- Disk space freed
- Current list of remaining clones

Note: This deletes the entire cloned repository including all uncommitted changes. Make sure to push any important changes before deleting.
