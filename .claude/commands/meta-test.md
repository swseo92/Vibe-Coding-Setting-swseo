---
description: Test commands in isolated session with natural language
argument-hint: [test description in natural language]
---

Use the meta-tester agent to test commands or functionality based on your natural language description.

Test request: $ARGUMENTS

Launch a meta-tester agent in an isolated Claude Code session to:
1. Understand the test requirements from the natural language description
2. Execute the necessary commands or tests
3. Verify the results match expectations
4. Clean up any test resources created (if requested or necessary)
5. Report detailed findings including successes, failures, and recommendations

The meta-tester agent will interpret your request and perform appropriate testing in a separate session to avoid interfering with your current work.

Examples:
- Test if worktree-create properly creates a new worktree with virtual environment
- Verify worktree-list shows all current worktrees correctly
- Create a worktree, make changes, and test if worktree-pr can create a pull request
- Check if worktree-sync handles merge conflicts properly
