# Code Review Report - {DATE_TIME}

**Reviewer**: OpenAI Codex (GPT-5-Codex)
**Date**: {YYYY-MM-DD HH:MM}
**Overall Score**: {SCORE}/100
**Recommendation**: {COMMIT ✅ | NEEDS WORK 🔴 | MAJOR REFACTOR 🔥}

---

## Summary

{CODEX_SUMMARY}

---

## Score Breakdown

| Metric | Score | Status |
|--------|-------|--------|
| Overall Quality | {SCORE}/100 | {✅ PASS / 🔴 FAIL} |
| Critical Issues | {COUNT} | {🚨 if >0, ✅ if 0} |
| Warnings | {COUNT} | {⚠️ if >3, ✅ if ≤3} |
| Suggestions | {COUNT} | 💡 |

**Pass Threshold**: ≥70/100 with 0 critical issues

**Assessment**:
- {PASS/FAIL}: {REASON}

---

## Files Reviewed

{FOR_EACH_FILE}
- `{FILE_PATH}` ({STATUS})
{END_FOR}

Example:
- `src/api/user.py` (Modified)
- `src/models/user_model.py` (Modified)
- `tests/test_user.py` (New)

---

## 🚨 Critical Issues

**These MUST be fixed before commit:**

{IF_NO_CRITICAL_ISSUES}
✅ **No critical issues found.**
{ELSE}

{FOR_EACH_CRITICAL_ISSUE}
### {NUMBER}. [{FILE}:{LINE}] {ISSUE_TITLE}

**Severity**: 🚨 Critical
**Category**: {Security / Bug / Data Loss}

**Description**:
{DETAILED_DESCRIPTION}

**Impact**:
{WHAT_COULD_GO_WRONG}

**Fix**:
{HOW_TO_FIX}

**Code Reference**:
```python
{CODE_SNIPPET_IF_AVAILABLE}
```

---
{END_FOR}
{ENDIF}

---

## ⚠️ Warnings

**These SHOULD be fixed:**

{IF_NO_WARNINGS}
✅ **No warnings.**
{ELSE}

{FOR_EACH_WARNING}
### {NUMBER}. [{FILE}:{LINE}] {ISSUE_TITLE}

**Severity**: ⚠️ Warning
**Category**: {Code Quality / Performance / Maintainability}

**Description**:
{DESCRIPTION}

**Why This Matters**:
{EXPLANATION}

**Suggestion**:
{HOW_TO_IMPROVE}

---
{END_FOR}
{ENDIF}

---

## 💡 Suggestions

**Nice to have improvements:**

{IF_NO_SUGGESTIONS}
✅ **No additional suggestions.**
{ELSE}

{FOR_EACH_SUGGESTION}
### {NUMBER}. [{FILE}:{LINE}] {SUGGESTION_TITLE}

**Category**: {Style / Refactoring / Enhancement}

**Description**:
{DESCRIPTION}

**Benefit**:
{WHY_THIS_HELPS}

---
{END_FOR}
{ENDIF}

---

## Recommendation

### {COMMIT ✅ | NEEDS WORK 🔴 | MAJOR REFACTOR 🔥}

**Reasoning**:
{EXPLANATION_BASED_ON_SCORE_AND_ISSUES}

**Decision Logic**:
- Score ≥ 70 AND 0 critical issues → ✅ COMMIT
- Score 50-69 OR 1-2 critical issues → 🔴 NEEDS WORK
- Score < 50 OR 3+ critical issues → 🔥 MAJOR REFACTOR

---

## Next Steps

**Before Committing**:
- [ ] {ACTION_ITEM_1}
- [ ] {ACTION_ITEM_2}
- [ ] {ACTION_ITEM_3}

**Future Improvements** (non-blocking):
- {FUTURE_IMPROVEMENT_1}
- {FUTURE_IMPROVEMENT_2}

---

## Full Codex Output

<details>
<summary>Click to expand complete Codex CLI output</summary>

```
{COMPLETE_CODEX_CLI_OUTPUT}
```

</details>

---

## Appendix: Issue Severity Guide

### 🚨 Critical (Must Fix)
Blocks commit. Must be resolved before merging.

**Examples**:
- Security vulnerabilities (SQL injection, XSS, hardcoded secrets)
- Critical bugs (data loss, crashes, logic errors)
- Breaking changes without migration path
- Undefined dependencies causing NameError

### ⚠️ Warning (Should Fix)
Doesn't block commit but should be addressed soon.

**Examples**:
- Missing type hints
- Insufficient test coverage
- Missing error handling
- Performance issues (O(n²) algorithms)
- SOLID principle violations
- Code complexity issues

### 💡 Suggestion (Nice to Have)
Optional improvements. Consider for future refactoring.

**Examples**:
- Style improvements
- Docstring additions
- Refactoring opportunities
- Minor optimizations
- Better naming conventions

---

## Scoring Rubric

Codex evaluates code on these dimensions:

| Dimension | Weight | Description |
|-----------|--------|-------------|
| **Security** | 20% | Vulnerabilities, auth, input validation |
| **Correctness** | 20% | Bugs, logic errors, edge cases |
| **Quality** | 15% | Code smells, complexity, DRY |
| **Testing** | 15% | Coverage, edge cases, mocking |
| **Performance** | 10% | Algorithm efficiency, memory |
| **Maintainability** | 10% | Readability, type hints, docs |
| **Best Practices** | 10% | SOLID, error handling, logging |

**Formula**: Weighted average of all dimensions with penalties for critical issues.

---

## Review Methodology

**Tool**: OpenAI Codex CLI v{VERSION}
**Model**: GPT-5-Codex (specialized for code review)
**Approach**: LLM-as-Judge with structured scoring

**Process**:
1. Analyze git staged changes
2. Evaluate against best practices
3. Categorize issues by severity
4. Generate objective score (0-100)
5. Provide actionable recommendations

**Note**: This is an automated review. Always combine with:
- Human code review for complex logic
- Actual testing (unit, integration, e2e)
- Security scanning tools
- Static analysis (linters, type checkers)

---

## References

**Documentation**:
- [OpenAI Codex CLI](https://developers.openai.com/codex/cli/)
- [Python Best Practices](../../references/python-best-practices.md)
- [SOLID Principles](../../references/solid-principles.md)
- [Testing Guidelines](../../references/testing-checklist.md)

**Standards**:
- [PEP 8 - Python Style Guide](https://pep8.org/)
- [PEP 484 - Type Hints](https://www.python.org/dev/peps/pep-0484/)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)

---

**Generated By**: Pre-Commit Code Reviewer (Codex-Powered) v2.0
**Report Location**: `.code-reviews/{FILENAME}`
**Session ID**: {TIMESTAMP}
