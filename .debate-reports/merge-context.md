# Commit Merge 전략 토론 - Context

## Background

**기존 환경 (Round 1-2 결과):**
- Git worktree로 병렬 작업 환경 구축
- 각 worktree = 독립 PyCharm 프로젝트
- 독립 `.venv`, `.env.local`, DB 복사

## New Problem: Merge Strategy

**시나리오:**

### Scenario 1: Feature Development (일반 기능 개발)
```
main (C:\ws\project\main)
├── feature-auth (C:\ws\project\feature-auth)
│   ├── 5 commits over 2 days
│   ├── 3 files changed, +200/-50 lines
│   └── All tests passing
└── How to merge back to main?
```

### Scenario 2: Experimental Branch (실험적 변경)
```
main
├── experiment-perf (성능 최적화 실험)
│   ├── 15 commits (trial & error)
│   ├── 10 files changed, +500/-300 lines
│   ├── Some commits broken, some working
│   └── Final state works well
└── How to integrate without messy history?
```

### Scenario 3: Code Review Workflow (코드 리뷰 병행)
```
main (working on feature-a)
├── review-teammate-pr (코드 리뷰 중)
│   ├── Reviewing PR #123
│   ├── Need to test locally
│   └── Want to return to feature-a after review
└── How to manage parallel workflows?
```

### Scenario 4: Hotfix (긴급 수정)
```
main (stable, deployed)
├── feature-new-ui (in progress, not ready)
├── hotfix-security (urgent fix needed)
│   └── Must merge to main ASAP
└── How to handle without disrupting feature work?
```

## User Context (1인 개발자)

**특성:**
- Team size: 1 (혼자)
- Code review: Self-review or skip
- CI/CD: May or may not exist
- History preference: TBD (linear vs branching)
- Merge frequency: TBD (daily vs feature-complete)

**Pain Points (추정):**
- Merge conflicts when working on multiple features
- Messy history from experimental commits
- Forgetting which branch has what changes
- Manual merge process prone to errors

## Questions to Explore

### 1. Merge Method

**Options:**
- **Merge Commit** (`git merge feature-auth`)
  - Pros: Preserves full history, shows branch structure
  - Cons: Non-linear history, "merge bubble"

- **Squash Merge** (`git merge --squash feature-auth`)
  - Pros: Clean single commit, linear history
  - Cons: Loses individual commit messages, harder to revert

- **Rebase + FF** (`git rebase main` → `git merge --ff-only`)
  - Pros: Linear history, all commits preserved
  - Cons: Rewriting history, conflicts per commit

- **Hybrid** (different strategy per scenario)
  - Feature: Squash
  - Hotfix: FF merge
  - Experiment: Interactive rebase + squash

### 2. Pre-Merge Validation

**What to check before merging?**
- Tests pass in feature branch?
- Tests pass after merging to main?
- Linting/formatting checks?
- DB migrations compatible?
- Dependencies synchronized?

### 3. Conflict Resolution

**In worktree environment:**
- Merge in feature worktree or main worktree?
- How to test conflict resolution?
- Tools: CLI, PyCharm, external merge tool?

### 4. Automation Level

**Manual vs Scripted:**
- Fully manual: `git merge` by hand
- Semi-automated: Script with validation checks
- Fully automated: CI/CD pipeline (overkill for 1 person?)

### 5. History Management

**For 1-person project:**
- Is linear history important?
- Need to preserve detailed commit history?
- Bisect-friendly commits?
- Or: Just "working state" snapshots?

### 6. Integration with Worktree Workflow

**Specific considerations:**
- Merge while both worktrees open in PyCharm?
- DB schema conflicts between worktrees?
- When to delete merged worktree?
- How to sync changes from main to other worktrees?

## Desired Outcome

**A practical merge workflow that:**
1. ✅ Minimizes manual errors
2. ✅ Handles common scenarios (feature/experiment/hotfix)
3. ✅ Works well with PyCharm + Windows
4. ✅ Balances history cleanliness vs traceability
5. ✅ Integrates with worktree lifecycle (create → work → merge → cleanup)

## Constraints

- 1인 개발 (no formal code review)
- Windows environment
- PyCharm IDE
- Python project (tests, linting)
- Git worktree setup from Round 1-2
