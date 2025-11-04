---
name: pre-commit-full
description: Comprehensive pre-commit validation (code quality + documentation + claude.md check)
tags: [commit, validation, quality, gitignored]
---

# Pre-Commit Full Validation

**Execute comprehensive validation checks before committing code.**

Run three validation skills in sequence to ensure code quality, documentation completeness, and project consistency.

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

### Step 3: Code Documentation Check

**Invoke the `documentation-manager` skill:**

Verify code documentation quality:
- Check docstring coverage
- Verify comment quality and clarity
- Review API documentation completeness
- Validate CHANGELOG entries (if applicable)

**Evaluation threshold**: Minimum 60% docstring coverage recommended.

---

## Final Report

After all three skills complete, generate a comprehensive summary:

**Format:**
```
📊 Pre-Commit Validation Results

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

## Notes

- **Execution time**: Approximately 30-60 seconds total (10-20s per skill)
- **Error handling**: If any skill fails to execute, report error and continue to next skill
- **Customization**: User can run individual skills separately if needed
- **Context preservation**: Each skill's findings are accumulated for final summary

## Individual Skill Usage

If user wants to run specific checks only:
- Code review only: Use `pre-commit-code-reviewer` skill directly
- Documentation only: Use `claude-md-manager` skill directly
- Docstrings only: Use `documentation-manager` skill directly
