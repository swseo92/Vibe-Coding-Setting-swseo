# Debate Report: Speckit + Worktree Optimization

**Date:** 2025-10-31
**Participants:** Claude (Anthropic) vs Codex (OpenAI GPT-5)
**Topic:** Optimal implementation for Speckit + Git Worktree parallel development

---

## Problem Statement

**Question:** What is the optimal implementation for enabling parallel feature development with Speckit + Claude Code?

**Current Implementation:**
- Uses `shutil.copytree()` to create full directory copies
- Each "worktree" is an independent copy with its own `.git`
- Slow (30-60s), disk-intensive (500MB+ per copy)

**Alternative:**
- Use native `git worktree` feature
- Shares `.git` via hard links
- Fast (1-2s), efficient (90% disk savings)

**Key Constraints:**
- Must support Windows, Mac, Linux
- Must integrate with Speckit spec-driven workflow
- Must allow parallel Claude Code sessions
- Must handle uncommitted changes (occasionally)

---

## Debate Summary

### Round 1: Initial Positions

**Claude's Position:**
- Proposed hybrid approach: Git worktree (default) + Copy mode (--copy flag)
- Recognized tradeoffs of each approach
- Suggested letting users choose based on use case

**Codex's Response:**
- **Strong pushback on hybrid approach:** "Dual path adds cognitive load"
- Identified critical safety issue: "Copy mode silently forks the reflog/remote config"
- Recommended: Git worktree as default (99%), --copy as rare exception (1%)
- Emphasized single source of truth

**Key Insight:**
Codex caught a major flaw Claude missed: copying `.git` creates diverging remotes, allowing developers to push to different repositories without noticing. This is a **critical safety issue**.

### Round 2: Refinement

**Claude's Revised Position:**
- Agreed with Codex's critique
- Abandoned equal hybrid approach
- Proposed: Worktree first, then rsync uncommitted changes if needed
- Preserves single `.git` authority

**Codex's Detailed Guidance:**
1. **Spec file strategy:**
   - `.specify/features/`: Branch-local (committed)
   - `.specify/features/_scratch/`: Experimental (ignored)
   - `.specify/memory/`: Shared (protected)
   - `.specify/templates/`: Infrastructure (versioned)

2. **Implementation choice:**
   - **Option A (worktree + rsync): PREFERRED**
   - Keeps single authoritative `.git`
   - Inherits remotes/hooks/GC settings
   - Appears in `git worktree list`
   - Option B (`git clone --shared`) creates second `.git/config` → dangerous

3. **File watcher limits:**
   - Mac/Linux: 6-8 worktrees stable
   - Windows: 10 worktrees (CPU spikes after 8)
   - 12+: Requires explicit limit increases

4. **Pre-flight checks:**
   - Provided complete bash script
   - Git version (≥2.37)
   - Windows long paths
   - Symlink support
   - File watcher limits

---

## Final Consensus

### ✅ Agreed Implementation

#### 1. Default Mode (99% cases)

```bash
/worktree-create feature-auth

# Executes:
1. Pre-flight checks (Git version, OS compatibility)
2. git worktree add ../clone/feature-auth -b feature-auth
3. cd ../clone/feature-auth && uv venv && uv sync
4. Create .vscode/settings.json with watcher exclusions
5. Echo PyCharm setup instructions
```

**Why:**
- Fast (1-2 seconds)
- Disk efficient (90% savings)
- Git native integration
- Single source of truth (safe)
- Automatic sync

#### 2. Exception Mode (1% cases)

```bash
/worktree-create feature-auth --include-uncommitted

# Executes:
1. Pre-flight checks
2. git worktree add ../clone/feature-auth -b feature-auth
3. rsync -av --exclude='.git' ./ _transfer/
4. mv _transfer/* ../clone/feature-auth/
5. Log copied files to .worktree-copy-log
6. Setup venv and sync
```

**When to use:**
- Need to preserve WIP uncommitted changes
- Experimental code not ready to commit
- Quick prototyping across branches

**Safety measures:**
- Worktree created FIRST (preserves single .git)
- Rsync to temporary dir, then atomic move
- Log all copied files for transparency

#### 3. Speckit File Strategy

```
.specify/
├── memory/              # SHARED (committed, protected)
│   ├── constitution.md  # Single source of truth
│   └── cache/          # .gitignore (local cache)
│
├── features/           # BRANCH-LOCAL (committed)
│   ├── feature-auth/   # Feature name == branch name
│   │   ├── spec.md
│   │   ├── plan.md
│   │   └── tasks.md
│   └── _scratch/       # .gitignore (experiments)
│       └── jwt-alt/    # Can promote to features/ later
│
└── templates/          # SHARED (infrastructure)
    ├── spec-template.md  # Version controlled
    └── plan-template.md
```

**Principles:**
- `memory/`: Global agent context, requires PR review
- `features/`: Per-branch specs, merged with feature
- `_scratch/`: Throwaway experiments, can promote
- `templates/`: Infrastructure, versioned

**Workflow:**
```bash
# Main branch: Define canonical spec
/speckit.specify "JWT authentication"

# feature-auth branch: Experiment with variants
cd clone/feature-auth
/speckit.specify "JWT with refresh tokens" --scratch

# Promote if successful
speckit promote --from _scratch/jwt-alt --to features/feature-auth
```

#### 4. File Watcher Management

**Automatic VS Code config:**
```json
// .vscode/settings.json (auto-generated)
{
  "files.watcherExclude": {
    "**/.git/worktrees/**": true,
    "**/.git/modules/**": true,
    "**/.specify/memory/**": true,
    "**/.specify/features/_scratch/**": true,
    "**/node_modules/**": true,
    "**/dist/**": true
  }
}
```

**PyCharm instructions (echoed):**
```
⚠️  PyCharm Setup Required:
Settings → Advanced Settings → File Watching
→ Increase 'Maximum number of watched files' to 1048576
→ Add .specify/**/_scratch/** to "Ignored Files and Folders"
```

**Practical limits:**
- **Safe zone:** 6-8 worktrees
- **Warning zone:** 8-10 worktrees (monitor CPU)
- **Danger zone:** 12+ worktrees (requires system tuning)

#### 5. Pre-flight Checks

Complete bash script provided by Codex (see implementation section below).

**Checks:**
- ✅ Git version ≥2.37
- ✅ Windows long paths enabled
- ✅ Symlink support
- ✅ File watcher limits (OS-specific)

**Location:** `.claude/scripts/worktree-preflight.sh`

---

## Implementation Plan

### Phase 1: Infrastructure (Week 1)

1. **Create pre-flight script**
   ```bash
   # .claude/scripts/worktree-preflight.sh
   # (Full script provided by Codex in Round 2)
   ```

2. **Update .gitignore**
   ```gitignore
   .specify/features/_scratch/
   .specify/memory/cache/
   .worktree-copy-log
   ```

3. **Create .specify/README.md**
   ```markdown
   # Speckit Directory Structure

   ## Committed vs Scratch Conventions

   - `features/`: Branch-local specs (committed)
   - `features/_scratch/`: Experiments (ignored)
   - `memory/`: Global context (protected)
   - `templates/`: Infrastructure (versioned)
   ```

### Phase 2: CLI Update (Week 2)

1. **Update `/worktree-create` command**
   ```bash
   # .claude/commands/worktree-create.md

   ## Pre-flight checks
   !bash .claude/scripts/worktree-preflight.sh

   ## Create worktree (default mode)
   !git worktree add ../clone/$1 -b $1
   !cd ../clone/$1 && uv venv && uv sync

   ## Setup IDE configs
   !echo '{"files.watcherExclude": {...}}' > ../clone/$1/.vscode/settings.json
   !echo "⚠️ PyCharm setup required: ..."
   ```

2. **Add `--include-uncommitted` flag**
   ```bash
   if [[ "$2" == "--include-uncommitted" ]]; then
     # Worktree first
     !git worktree add ../clone/$1 -b $1

     # Rsync uncommitted changes
     !rsync -av --exclude='.git' ./ _transfer/
     !mv _transfer/* ../clone/$1/
     !ls -la _transfer/ >> .worktree-copy-log

     # Cleanup
     !rm -rf _transfer/
   fi
   ```

### Phase 3: Documentation (Week 3)

1. **Update CLAUDE.md**
   - Add worktree usage guide
   - Document Speckit file strategy
   - Explain when to use --include-uncommitted

2. **Add troubleshooting guide**
   - File watcher issues
   - Windows long path problems
   - Worktree cleanup (`git worktree prune`)

3. **Create migration guide**
   - How to move from copy-based to worktree-based
   - How to clean up old clone/ directories
   - How to set up existing projects

### Phase 4: Testing (Week 4)

1. **Cross-platform testing**
   - [ ] Windows 10/11
   - [ ] macOS (Intel + ARM)
   - [ ] Linux (Ubuntu, Fedora)

2. **Scale testing**
   - [ ] 5 concurrent worktrees
   - [ ] 10 concurrent worktrees
   - [ ] 15 concurrent worktrees

3. **Integration testing**
   - [ ] With Speckit workflow
   - [ ] With VS Code + Claude Code
   - [ ] With PyCharm
   - [ ] CI/CD pipelines

---

## Tradeoffs Analysis

### Git Worktree Approach

**Pros:**
- ✅ Fast creation (1-2s vs 30-60s)
- ✅ Disk efficient (90% savings)
- ✅ Native Git integration
- ✅ Single source of truth (safe)
- ✅ Automatic sync
- ✅ Scales to 10+ worktrees

**Cons:**
- ❌ Doesn't include uncommitted changes by default
- ❌ Shared .git (potential hook collisions)
- ❌ Git 2.5+ dependency
- ❌ Learning curve for users

**Mitigations:**
- --include-uncommitted flag for rare cases
- Pre-flight checks for Git version
- Documentation and examples
- Wrapper commands hide complexity

### Copy-Based Approach (deprecated)

**Pros:**
- ✅ Complete isolation
- ✅ Includes uncommitted changes
- ✅ Simple to understand
- ✅ No Git version dependency

**Cons:**
- ❌ Slow (30-60s)
- ❌ Disk waste (500MB+ per copy)
- ❌ **CRITICAL: Forks remote config (safety issue)**
- ❌ No Git tooling integration
- ❌ Manual sync required

**Verdict:** Too many downsides, especially the safety issue. Deprecated in favor of worktree + rsync when needed.

---

## Risk Assessment

### High Risk (Mitigated)

1. **Forked remote config (copy mode)**
   - **Risk:** Developers push to wrong remote
   - **Mitigation:** Deprecate copy mode, use worktree + rsync
   - **Status:** ✅ Resolved

2. **Git version incompatibility**
   - **Risk:** Old Git doesn't support worktree properly
   - **Mitigation:** Pre-flight check (Git ≥2.37)
   - **Status:** ✅ Mitigated

### Medium Risk (Monitored)

3. **File watcher limits**
   - **Risk:** IDEs slow down with many worktrees
   - **Mitigation:** Automatic watcher exclusions, document limits
   - **Status:** ⚠️ Monitored

4. **Shared .git hook collisions**
   - **Risk:** Git hooks run in all worktrees
   - **Mitigation:** Document worktree-aware hooks
   - **Status:** ⚠️ Monitored

### Low Risk (Acceptable)

5. **Windows long path issues**
   - **Risk:** Deep paths fail on Windows
   - **Mitigation:** Pre-flight check, documentation
   - **Status:** ℹ️ Acceptable

6. **Learning curve**
   - **Risk:** Users unfamiliar with worktrees
   - **Mitigation:** Wrapper commands, documentation
   - **Status:** ℹ️ Acceptable

---

## Success Metrics

### Performance Metrics

**Before (Copy-based):**
- Creation time: 30-60 seconds
- Disk usage: 500MB × N worktrees
- Sync time: Manual (git pull)

**After (Worktree-based):**
- Creation time: 1-2 seconds (**95% improvement**)
- Disk usage: 50MB × N worktrees (**90% reduction**)
- Sync time: Automatic (shared .git)

### Quality Metrics

1. **Safety:** Single .git eliminates remote fork risk
2. **Integration:** Native Git tooling support
3. **Scalability:** 10+ concurrent worktrees supported
4. **User Experience:** Wrapper commands hide complexity

---

## Dissenting Opinions

### None

Both Claude and Codex reached full consensus on:
- Git worktree as default
- Worktree + rsync for uncommitted changes
- Speckit file strategy
- Pre-flight checks
- File watcher management

The only adjustment was Claude's initial hybrid proposal being refined to "default + rare exception" based on Codex's feedback.

---

## Lessons Learned

### What Worked Well

1. **Structured debate format**
   - Clear problem definition
   - Evidence-based arguments
   - Concrete implementation details

2. **Cross-validation**
   - Codex caught critical safety issue Claude missed
   - Both AIs reinforced each other's correct points
   - Resulted in more robust solution

3. **Specificity**
   - Concrete examples (file paths, commands)
   - Actual code snippets
   - OS-specific guidance

### What Could Be Improved

1. **Earlier exploration of alternatives**
   - Could have researched `git clone --shared` sooner
   - More upfront investigation of Git worktree internals

2. **Testing plan detail**
   - Should define test cases earlier in debate
   - Specify exact scenarios to validate

---

## Next Actions

### Immediate (This Week)

1. [ ] Create `.claude/scripts/worktree-preflight.sh`
2. [ ] Update `.gitignore`
3. [ ] Create `.specify/README.md`
4. [ ] Test preflight script on Windows/Mac/Linux

### Short-term (Next 2 Weeks)

5. [ ] Update `/worktree-create` command
6. [ ] Add `--include-uncommitted` support
7. [ ] Create VS Code settings template
8. [ ] Document PyCharm setup

### Long-term (Next Month)

9. [ ] Complete documentation updates
10. [ ] Cross-platform testing
11. [ ] Scale testing (10+ worktrees)
12. [ ] Migration guide for existing projects

---

## Conclusion

**Consensus reached:** Git worktree is the optimal solution for Speckit + parallel development.

**Key decision:** Single source of truth (shared .git) with escape hatch (--include-uncommitted) for rare edge cases.

**Implementation confidence:** High. Codex provided complete pre-flight script, detailed file strategy, and concrete implementation guidance.

**Recommendation:** Proceed with implementation following the phased plan above.

---

**Debate Participants:**
- **Claude (Anthropic):** Initial analysis, synthesis, documentation
- **Codex (OpenAI GPT-5):** Critical review, safety analysis, implementation details

**Total Rounds:** 2 (reached consensus early)
**Token Usage:** ~9,000 tokens (stateful session)
**Time to Consensus:** ~15 minutes

**Session ID:** 019a37a4-781e-7740-a4eb-19ed2dc29be2
