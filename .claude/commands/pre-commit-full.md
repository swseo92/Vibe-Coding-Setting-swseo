---
name: pre-commit-full
description: Comprehensive pre-commit validation (code quality + documentation + claude.md check)
tags: [commit, validation, quality, gitignored]
---

# Pre-Commit Full Validation

**Execute comprehensive validation checks before committing code.**

Run three validation skills in sequence to ensure code quality, documentation completeness, and project consistency.

**New Feature**: Incremental validation - only checks commits since last validation to save time.

## State Management

### Check Last Validation State

**Before starting validation, check if previous validation exists:**

1. Read state file: `.claude/state/pre-commit-full.json`
2. If file exists, extract `lastValidatedCommit` hash
3. Calculate commit range: `lastValidatedCommit..HEAD`
4. Count commits in range: `git rev-list --count <range>`

**State file format:**
```json
{
  "lastValidatedCommit": "abc123def456",
  "lastValidatedAt": "2025-11-08T10:30:00Z",
  "totalCommitsValidated": 42
}
```

**If state file doesn't exist**: This is first run, validate all uncommitted changes.

**Display to user:**
```
🔍 Incremental Validation
📊 마지막 검증: [lastValidatedAt] ([lastValidatedCommit 앞 7자리])
📈 검증할 커밋: [count]개

검증 시작...
```

**If no new commits since last validation:**
```
✅ 마지막 검증 이후 새로운 커밋이 없습니다.
   마지막 검증: [lastValidatedAt]

강제 검증을 원하시면 말씀해주세요.
```
Then exit without running skills.

### Force Full Validation

**If user requests `--force` or "전체 검증":**
- Ignore state file
- Validate all changes
- Update state after completion

## Execution Workflow

### Step 1: Code Quality Review

**Invoke the `pre-commit-code-reviewer` skill:**

Analyze code changes for quality issues:
- Check for code smells and anti-patterns
- Verify language-specific best practices
- Get quality score (0-100)
- Identify improvement areas

**Evaluation threshold**: Minimum 70 points recommended.

**If score < 70**: Report critical issues but continue to next steps (user decides whether to proceed).

---

### Step 2: Documentation Validation

**Invoke the `claude-md-manager` skill:**

Validate project `claude.md` against language-specific templates:
- Auto-detect project language (Python, JavaScript, Go, Rust, etc.)
- Load corresponding template from `templates/{language}/claude.md`
- Compare project claude.md with template requirements
- Report missing required sections
- Generate dry-run preview of changes

**Auto-fix capability**: If missing sections found, offer to add them with user approval (append-only, preserves customizations).

---

### Step 3: Documentation Validation

**Invoke the `documentation-manager` skill in comprehensive validation mode:**

The `documentation-manager` skill will automatically execute **ALL available documentation checks**. No need to specify what to check - the skill manages its own validation logic.

**Checks performed** (see documentation-manager skill for details):
- Core review (docstrings, comments, README, CHANGELOG via Codex)
- README completeness (.readme-config.json compliance)
- README freshness (detect stale documentation)
- Central index up-to-date check (docs/index.md)
- Auto-fix suggestions for found issues
- **Any future checks** added to documentation-manager (automatic)

**Key benefit**: When documentation-manager adds new validation features, they automatically run here without updating this command.

**Invocation:**
```
Request comprehensive documentation validation from documentation-manager skill.
```

The skill returns a structured report with:
- Overall status (PASS/PASS WITH WARNINGS/FAIL)
- Detailed findings per check
- Auto-fix recommendations
- Quality scores and thresholds

---

## Final Report

After all three skills complete, generate a comprehensive summary:

**Format:**
```
📊 Pre-Commit Validation Results

📈 검증 통계:
   - 검증한 커밋: [count]개
   - 커밋 범위: [lastValidatedCommit 앞 7자리]..HEAD
   - 검증 시작: [startTime]
   - 소요 시간: [duration]초

✅ Code Quality: [score]/100 ([PASS/WARNING/FAIL])
✅ Documentation: [status]
✅ Docstrings: [coverage]% ([PASS/WARNING])

🔍 Details:
- [pre-commit-code-reviewer] [summary]
- [claude-md-manager] [summary]
- [documentation-manager] [summary]

💡 Recommendations:
[List of actionable items to fix]

✅ Safe to commit? [YES/YES with warnings/NO]
```

## User Decision Point

After presenting the report, ask the user:

**If all checks pass:**
- "All validations passed. Proceed with commit?"

**If warnings present:**
- "Validation completed with warnings. Options:
  1. Proceed with commit (warnings acceptable)
  2. Fix issues first
  3. View detailed findings from specific skill"

**If critical failures:**
- "Critical issues found. Recommend fixing before commit. Proceed anyway?"

## State Update

**After successful validation (regardless of pass/fail), update state file:**

1. Get current HEAD commit hash: `git rev-parse HEAD`
2. Get current timestamp (ISO 8601)
3. Calculate total commits validated (from previous + current count)
4. Write to `.claude/state/pre-commit-full.json`:

```json
{
  "lastValidatedCommit": "<current HEAD hash>",
  "lastValidatedAt": "<ISO 8601 timestamp>",
  "totalCommitsValidated": <cumulative count>
}
```

**IMPORTANT**: Only update state if validation completes successfully (all 3 skills run to completion, even if they found issues).

**Do NOT update state if:**
- User cancels mid-validation
- Skills fail to execute (error/crash)
- User runs with `--force` but decides not to commit

**Confirmation message:**
```
💾 검증 상태 저장 완료
   - 다음 검증 시 [current HEAD 앞 7자리] 이후 커밋부터 체크합니다
```

## Notes

- **Execution time**: Approximately 30-60 seconds total (10-20s per skill)
  - **Performance improvement**: With incremental validation, typically only validates 5-10 commits instead of entire history
- **Error handling**: If any skill fails to execute, report error and continue to next skill
- **Customization**: User can run individual skills separately if needed
- **Context preservation**: Each skill's findings are accumulated for final summary
- **State persistence**: Validation state is stored in `.claude/state/` (gitignored)
- **Fresh start**: Delete `.claude/state/pre-commit-full.json` to reset validation history

## Individual Skill Usage

If user wants to run specific checks only:
- Code review only: Use `pre-commit-code-reviewer` skill directly
- Documentation only: Use `claude-md-manager` skill directly
- Docstrings only: Use `documentation-manager` skill directly

## Usage Examples

### First-time usage
```
user: /pre-commit-full
assistant:
🔍 Incremental Validation
📊 상태 파일이 없습니다 (첫 실행)
📈 검증 대상: 현재 변경사항

검증 시작...
[validation runs]
💾 검증 상태 저장 완료
   - 다음 검증 시 abc123d 이후 커밋부터 체크합니다
```

### Incremental validation (5 new commits)
```
user: /pre-commit-full
assistant:
🔍 Incremental Validation
📊 마지막 검증: 2025-11-08 10:30 (abc123d)
📈 검증할 커밋: 5개

검증 시작...
[validation runs]

📊 Pre-Commit Validation Results

📈 검증 통계:
   - 검증한 커밋: 5개
   - 커밋 범위: abc123d..HEAD
   - 검증 시작: 2025-11-08 15:20
   - 소요 시간: 45초

✅ Code Quality: 85/100 (PASS)
...

💾 검증 상태 저장 완료
   - 다음 검증 시 xyz789a 이후 커밋부터 체크합니다
```

### No new commits
```
user: /pre-commit-full
assistant:
✅ 마지막 검증 이후 새로운 커밋이 없습니다.
   마지막 검증: 2025-11-08 15:20

강제 검증을 원하시면 말씀해주세요.
```

### Force full validation
```
user: 전체 검증해줘
assistant:
🔍 Full Validation (--force)
📊 상태 파일 무시
📈 검증 대상: 전체 변경사항

검증 시작...
[validation runs all changes]
```

## Troubleshooting

### Reset validation history
If you want to start fresh:
```bash
rm .claude/state/pre-commit-full.json
```

### Check current state
```bash
cat .claude/state/pre-commit-full.json
```

### Manual commit range check
```bash
# See commits since last validation
git log <lastValidatedCommit>..HEAD --oneline
```
