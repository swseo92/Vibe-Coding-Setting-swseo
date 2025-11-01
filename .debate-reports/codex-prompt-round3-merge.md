# Codex Round 3 Prompt: Merge Strategy Evaluation

## Context

This is Round 3 of the git worktree + PyCharm debate. Rounds 1-2 established the worktree architecture. Now we're discussing **merge strategies** for integrating changes back to main.

**User Context (from Rounds 1-2):**
- 1-person Python project
- Windows + PyCharm
- Git worktree environment (each worktree = independent project)
- Scenarios: Multiple features in parallel + experiments + code review + hotfixes

## Claude's Proposal: "Adaptive Merge Strategy"

Claude proposed **5 different strategies for 5 scenarios:**

### Strategy Matrix

| Scenario | Commits | Approach | Method |
|----------|---------|----------|--------|
| **Feature** | 3-10, clean | Squash Merge | `git merge --squash` |
| **Experiment** | 15+, messy | Interactive Rebase + Squash | `git rebase -i` → squash |
| **Hotfix** | 1-2, urgent | Fast-Forward | `git merge --ff-only` |
| **Code Review** | N/A | No Merge | Read-only, cleanup |
| **Long-running** | 20+, weeks | Periodic Rebase | `git rebase origin/main` |

### Detailed Proposals

#### 1. Feature Development: Squash Merge

**Process:**
1. Pre-merge validation in feature worktree (tests, linting)
2. Switch to main worktree
3. Update main (`git pull --rebase`)
4. Squash merge: `git merge --squash feature-auth`
5. Craft single commit message with summary
6. Post-merge validation in main context
7. Push to origin
8. Cleanup feature worktree

**Automation:** `merge-feature.ps1` (provided)
- Phases: Pre-validation → Update main → Squash → Commit → Post-validation → Push → Cleanup
- Error handling with rollback
- Interactive commit message editing

**Rationale:**
- Linear history for 1-person project
- Single meaningful commit per feature
- Easy rollback if needed

#### 2. Experimental Branch: Interactive Rebase + Squash

**Process:**
1. In experiment worktree: `git rebase -i main`
2. Squash/fixup failed attempts, keep successful ones
3. Run tests after rebase
4. Use `merge-feature.ps1` for final merge

**Rationale:**
- Hide trial-and-error commits
- Keep only meaningful milestones
- Bisect-friendly history

**Claude's assumption:** Force-push OK for 1-person project

#### 3. Hotfix: Fast-Forward Merge

**Process:**
1. Create hotfix worktree
2. Make 1-2 commits with clear fix
3. Fast-forward merge: `git merge --ff-only hotfix-security`
4. Quick smoke tests
5. Push immediately
6. Cleanup

**Automation:** `merge-hotfix.ps1` (provided)
- Simplified validation (smoke tests only)
- Auto-push after merge
- No interactive steps (speed priority)

**Rationale:**
- Preserve commit identity (for audit trail)
- Fast deployment
- No merge commits (clean history)

#### 4. Code Review: Read-Only Worktree

**Process:**
1. `git worktree add review-pr-123 origin/pr-123`
2. Review, test locally
3. No merge
4. `git worktree remove review-pr-123`

**Rationale:**
- Temporary workspace
- No automation needed

#### 5. Long-Running Branch: Periodic Rebase

**Process:**
- Daily/weekly: `git fetch && git rebase origin/main`
- Keep feature branch up-to-date with main
- Resolve conflicts incrementally

**Automation:** `sync-with-main.ps1` (provided)
- Auto-stash before rebase
- Detect conflicts and pause

**Rationale:**
- Avoid massive conflict resolution at merge time
- Stay compatible with latest main changes

## Your Task: Critical Evaluation

### 1. Strategy Validity

For each of Claude's 5 strategies:
- **Strengths:** What works well?
- **Weaknesses:** What's problematic?
- **Edge Cases:** What scenarios break this?

### 2. Squash Merge Critique

**Claude's preference:** Squash merge for most features

**Questions:**
- Is losing individual commit history a problem for 1-person projects?
- Bisecting bugs: harder with squashed commits?
- What if feature is partially good, partially bad? (hard to revert)
- Alternative: Keep commits but merge commit?

### 3. Rebase Safety

**Claude's assumption:** Rebase is safe for 1-person projects

**Reality check:**
- Force-push risks on shared branches?
- Rebase during active work in multiple worktrees?
- Conflict resolution during rebase - can break intermediate states?
- Better alternative for cleaning history?

### 4. Hotfix Fast-Forward

**Claude's approach:** `git merge --ff-only`

**Questions:**
- What if main diverged during hotfix work? (FF fails)
- Should hotfixes create merge commits for clarity?
- Tag-based deployment - does FF matter?
- Emergency rollback strategy?

### 5. Script Robustness

**Claude provided 3 PowerShell scripts:**
- `merge-feature.ps1` (complex, ~200 lines)
- `merge-hotfix.ps1` (simple, fast-track)
- `sync-with-main.ps1` (periodic rebase)

**Critique:**
- Missing error scenarios?
- Windows/PyCharm-specific issues?
- Database migration handling during merge?
- Dependency conflicts after merge?
- How to test merge scripts without breaking repo?

### 6. Missing Scenarios

**What Claude didn't cover:**
- Merge conflicts in DB schema migrations?
- Merging when dependencies changed in both branches?
- Merging with breaking changes in main?
- Rollback after bad merge + push?
- Cherry-picking commits instead of full merge?

### 7. Worktree-Specific Concerns

**Unique to worktree environment:**
- Merging while both worktrees open in PyCharm?
- Database state conflicts between worktrees after merge?
- When to delete source worktree - before or after push?
- How to update other worktrees after main changes?

### 8. PyCharm Integration

**Git operations in PyCharm vs CLI:**
- Should merges be done via PyCharm GUI?
- PyCharm's "Update Project" vs `git pull --rebase`?
- Conflict resolution: PyCharm merge tool vs CLI?
- Does PyCharm handle squash merges well?

### 9. 1-Person Workflow Reality

**For solo developer:**
- Is this over-engineered?
- Simpler approach: Just `git merge` everything?
- When does history cleanliness actually matter?
- Code review skipped - implications for merge strategy?

### 10. Your Recommendation

**Pick one:**
- **Accept Claude's adaptive strategy** - Use different strategies per scenario
- **Simplify to single strategy** - One approach for all scenarios
- **Hybrid compromise** - Fewer strategies, clearer rules
- **Completely different approach** - What would you do?

## Output Format

1. **Overall Assessment**: Accept / Conditional Accept / Reject
2. **Top 5 Issues**: Critical problems with Claude's proposal
3. **Strategy Preferences**: Which strategies work, which don't?
4. **Script Improvements**: Concrete fixes for PowerShell scripts
5. **Simplified Workflow**: Your recommended workflow (if different)
6. **Worktree-Merge Integration**: Specific guidance for worktree context
7. **Confidence Level**: High / Medium / Low on each strategy

Focus on **practical usability** for a solo Windows developer. Will this actually work day-to-day?
