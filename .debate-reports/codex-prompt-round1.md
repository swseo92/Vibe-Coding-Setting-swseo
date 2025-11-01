# Codex Round 1 Prompt

You are participating in a technical debate with Claude about git worktree + PyCharm workflow design.

## Your Role

- **Reality Check**: Validate Claude's proposals with practical experience
- **Windows Expert**: Focus on Windows-specific considerations
- **PyCharm Specialist**: Best practices for IDE integration
- **Edge Case Hunter**: Find failure modes and overlooked scenarios

## Context

**Problem:** Design parallel development environment using git worktree for Python projects in PyCharm (Windows)

**User Requirements:**
- Scenario: Multiple features in parallel + experimental branches + code review workflow
- Tech: Python with isolated `.venv` per worktree
- IDE: PyCharm on Windows
- DB: Shared by default, independent when schema changes
- Environment: Independent `.env` (copied from original)
- Team: Solo developer, git worktree beginner

## Claude's Proposals

Claude suggested 3 approaches:

### A: Multi-Project Window
- Each worktree = separate PyCharm project
- Pros: Full isolation, no indexing conflicts
- Cons: Multiple PyCharm instances (memory), window switching

### B: Attached Directory
- Single PyCharm project with worktrees as attached directories
- Pros: One window, easy comparison
- Cons: Indexing confusion, environment variable complexity

### C: Hybrid - Smart Symlink (Claude's recommendation)
- Workspace structure with smart symlinks for shared resources
- Automated script for worktree creation:
  - `git worktree add`
  - `uv venv && uv sync`
  - Copy + customize `.env`
  - Symlink or copy DB based on flag
  - Auto-generate PyCharm config
- PyCharm usage: Open as separate projects, use built-in comparison tools

## Your Task

Please evaluate these proposals and answer:

1. **PyCharm Indexing Reality Check:**
   - Real performance difference: Multi-project vs Single-project with attached directories?
   - How does PyCharm handle git worktrees? Any known issues?
   - Indexing optimization tips for worktree structure?

2. **Windows-Specific Concerns:**
   - Symlinks on Windows: Developer Mode requirement? Alternatives?
   - Junction vs Symlink for this use case?
   - Path length limitations with nested worktree structure?

3. **Approach C Critique:**
   - What edge cases did Claude miss in the automation script?
   - Is `uv` the best choice for worktree environments? Alternatives?
   - Any issues with the proposed directory structure?

4. **Database Strategy:**
   - SQLite file locking when shared across worktrees?
   - Can we auto-detect schema changes to trigger DB copy?
   - Better alternatives to symlink/copy approach?

5. **Missing Coverage:**
   - How should git hooks (pre-commit, etc.) work across worktrees?
   - Testing isolation strategy for each worktree?
   - Sensitive data in `.env`: Security considerations when copying?
   - PyCharm plugin settings: Share or isolate?

6. **Your Recommendation:**
   - Which approach (A/B/C) would you recommend? Why?
   - What modifications would you make?
   - Any completely different approach we should consider?

## Output Format

Please structure your response as:

1. **Quick Take**: Which approach you prefer (A/B/C or hybrid)
2. **Critical Issues**: Top 3 problems with Claude's proposals
3. **Windows Reality**: Specific Windows/PyCharm gotchas
4. **Improved Design**: Your concrete suggestions
5. **Implementation Notes**: Key considerations for automation script
6. **Confidence**: Rate your confidence on each recommendation (Low/Medium/High)

Focus on **practical implementation details** over theory. We need a working solution for a Windows + PyCharm + Python environment.
