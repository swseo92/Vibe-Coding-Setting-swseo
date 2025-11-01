# Codex Round 2 Prompt

## Context

You provided excellent Round 1 feedback on Claude's git worktree + PyCharm proposals. Claude has now revised the design based on your input.

## Claude's Revised Proposal (Round 2)

Claude **accepted all your major recommendations**:

### Core Changes from Round 1

1. ✅ **Approach A Adopted** - Multi-Project Window (separate PyCharm per worktree)
2. ✅ **`venv` over `uv`** - Using `python -m venv` for stability
3. ✅ **DB Copy Default** - Independent DB per worktree (sharing is optional)
4. ✅ **Short Paths** - `C:\ws\{project}\{branch}` structure
5. ✅ **Minimal Symlinks** - Only for git hooks (`core.hooksPath`)
6. ✅ **`.idea` Hands-off** - Let PyCharm generate, don't script it
7. ✅ **Sensitive Data Scrubbing** - `.env` → `.env.local` with masking
8. ✅ **Long Path Validation** - Check registry setting in script
9. ✅ **Smoke Tests** - Integrated in automation

### Final Architecture: "Simplified Multi-Project"

**Directory Structure:**
```
C:\ws\my-project\
├── main\
│   ├── .git\
│   ├── .venv\
│   ├── .env
│   ├── db.sqlite3
│   └── src\
├── feature-auth\
│   ├── .git (worktree link)
│   ├── .venv\
│   ├── .env.local
│   ├── db-feature-auth.sqlite3
│   ├── README-worktree.md
│   └── src\
```

**Git Hooks Centralization:**
```
main\.git\hooks-shared\
git config core.hooksPath .git/hooks-shared
```

### Automation Scripts

Claude provided two PowerShell scripts:

1. **`worktree-create.ps1`** - Creates worktree with:
   - Environment validation (long paths, Python, Git)
   - `python -m venv .venv` + dependency install
   - `.env` → `.env.local` with secret masking
   - Independent DB copy (or optional sharing)
   - Git hooks setup via `core.hooksPath`
   - `README-worktree.md` generation
   - Smoke test execution

2. **`cleanup-worktree.ps1`** - Removes worktree with:
   - Optional DB archiving
   - `git worktree remove`
   - Filesystem cleanup

## Your Task

Please perform a **Stress Pass** evaluation:

### 1. Failure Modes

Enumerate potential failure scenarios:
- What can go wrong with this design?
- Edge cases in the PowerShell scripts?
- Windows-specific pitfalls still not addressed?
- PyCharm quirks that could break the workflow?

### 2. Script Critique

Review the `worktree-create.ps1` logic:
- Missing error handling?
- Incorrect PowerShell usage?
- Steps that should be atomic/transactional?
- Rollback strategy if creation fails midway?

### 3. Missing Pieces

What's still not covered?
- How to handle existing worktrees (recreate vs reuse)?
- What if user forgets to activate venv in PyCharm?
- How to update all worktrees when dependencies change?
- Migration path from current single-branch workflow?

### 4. PyCharm Integration Details

Specific PyCharm considerations:
- Auto-detection of `.venv` - does it always work?
- How to ensure Run Configurations use `.env.local`?
- VCS root detection - manual intervention still needed?
- Indexing conflicts when multiple PyCharm instances share `.git`?

### 5. Real-World Usage Patterns

For the user's scenarios:
- **Multiple features in parallel**: Any workflow bottlenecks?
- **Experimental branches**: How to promote experiment to main?
- **Code review workflow**: Best practice for reviewing across worktrees?

### 6. Your Final Recommendation

- **Accept as-is**: If design is solid
- **Accept with minor tweaks**: Suggest specific improvements
- **Needs major revision**: Identify fundamental issues

## Output Format

1. **Stress Pass Summary**: Pass / Conditional Pass / Fail
2. **Critical Failure Modes**: Top 5 scenarios where this breaks
3. **Script Improvements**: Concrete PowerShell fixes
4. **PyCharm Best Practices**: Must-know tips for this workflow
5. **Workflow Enhancements**: Optional but valuable additions
6. **Confidence Level**: High / Medium / Low on final recommendation

Focus on **real-world reliability** - will this work for a Windows developer using PyCharm daily?
