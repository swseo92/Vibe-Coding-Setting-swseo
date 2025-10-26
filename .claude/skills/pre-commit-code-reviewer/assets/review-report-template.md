# Code Review Report

**Date**: {CURRENT_DATE}
**Time**: {CURRENT_TIME}
**Reviewer**: Claude Code Assistant
**Commit**: {COMMIT_HASH or "Staged Changes"}

---

## Summary

**Overall Assessment**: {PASS/NEEDS_WORK/CRITICAL_ISSUES}

- **Files Reviewed**: {COUNT}
- **Critical Issues**: {COUNT} 🚨
- **Warnings**: {COUNT} ⚠️
- **Suggestions**: {COUNT} 💡

**Recommendation**: {COMMIT_READY/FIX_CRITICAL/FIX_WARNINGS_FIRST}

**Note**: This is an objective technical assessment. Issues are flagged based on industry standards and best practices, not personal preference.

---

## Files Reviewed

{LIST_OF_FILES_WITH_STATUS}

Example:
- ✅ `src/models/user.py` - No issues
- ⚠️ `src/services/user_service.py` - 2 warnings
- 🚨 `src/api/routes.py` - 1 critical issue

---

## Critical Issues (Must Fix Before Commit)

{IF_NO_CRITICAL_ISSUES}
✅ No critical issues found.
{ENDIF}

{FOR_EACH_CRITICAL_ISSUE}
### 🚨 {ISSUE_NUMBER}: {ISSUE_TITLE}

**File**: `{FILE_PATH}:{LINE_NUMBER}`
**Category**: {SECURITY/BUG/DATA_LOSS}
**Severity**: Critical

**Issue**:
{DETAILED_DESCRIPTION}

**Code**:
```python
{CODE_SNIPPET}
```

**Why This Is Critical**:
{EXPLANATION_OF_IMPACT}

**Recommended Fix**:
```python
{SUGGESTED_FIX}
```

**References**:
- {LINK_TO_DOCUMENTATION}
- {RELATED_BEST_PRACTICE}

---
{END_FOR_EACH}

---

## Warnings (Should Fix)

{IF_NO_WARNINGS}
✅ No warnings.
{ENDIF}

{FOR_EACH_WARNING}
### ⚠️ {ISSUE_NUMBER}: {ISSUE_TITLE}

**File**: `{FILE_PATH}:{LINE_NUMBER}`
**Category**: {CODE_QUALITY/PERFORMANCE/MAINTAINABILITY}
**Severity**: Warning

**Issue**:
{DESCRIPTION}

**Code**:
```python
{CODE_SNIPPET}
```

**Why This Matters**:
{EXPLANATION}

**Suggested Improvement**:
```python
{SUGGESTED_IMPROVEMENT}
```

---
{END_FOR_EACH}

---

## Suggestions (Nice to Have)

{IF_NO_SUGGESTIONS}
✅ No additional suggestions.
{ENDIF}

{FOR_EACH_SUGGESTION}
### 💡 {ISSUE_NUMBER}: {SUGGESTION_TITLE}

**File**: `{FILE_PATH}:{LINE_NUMBER}`
**Category**: {STYLE/REFACTORING/ENHANCEMENT}

**Suggestion**:
{DESCRIPTION}

**Benefit**:
{WHY_THIS_WOULD_HELP}

**Optional Change**:
```python
{SUGGESTED_CODE}
```

---
{END_FOR_EACH}

---

## Review Checklist

{CHECKLIST_TABLE}

| Category | Status | Notes |
|----------|--------|-------|
| **Documentation** | {PASS/FAIL/PARTIAL} | {NOTES} |
| **Bug Possibilities** | {PASS/FAIL/PARTIAL} | {NOTES} |
| **Test Coverage** | {PASS/FAIL/PARTIAL} | {NOTES} |
| **Clean Code** | {PASS/FAIL/PARTIAL} | {NOTES} |
| **SOLID Principles** | {PASS/FAIL/PARTIAL} | {NOTES} |
| **File Structure** | {PASS/FAIL/PARTIAL} | {NOTES} |
| **Type Hints** | {PASS/FAIL/PARTIAL} | {NOTES} |
| **Error Handling** | {PASS/FAIL/PARTIAL} | {NOTES} |
| **Security** | {PASS/FAIL/PARTIAL} | {NOTES} |
| **Performance** | {PASS/FAIL/PARTIAL} | {NOTES} |
| **Readability** | {PASS/FAIL/PARTIAL} | {NOTES} |
| **Reusability** | {PASS/FAIL/PARTIAL} | {NOTES} |

**Legend**:
- ✅ **PASS**: Meets standards
- ⚠️ **PARTIAL**: Some issues, not critical
- ❌ **FAIL**: Significant issues found

---

## Detailed Analysis by Category

### 1. Documentation Updates

{PASS/FAIL/PARTIAL}: {SUMMARY}

**Findings**:
- {FINDING_1}
- {FINDING_2}

**Action Items**:
- {ACTION_1}
- {ACTION_2}

---

### 2. Bug Possibilities

{PASS/FAIL/PARTIAL}: {SUMMARY}

**Potential Bugs Identified**:
- {BUG_1}
- {BUG_2}

**Recommendations**:
- {RECOMMENDATION_1}

---

### 3. Test Coverage

{PASS/FAIL/PARTIAL}: {SUMMARY}

**Coverage Analysis**:
- New functions tested: {YES/NO}
- Edge cases covered: {YES/NO}
- Integration tests: {YES/NO}

**Missing Tests**:
- {MISSING_TEST_1}
- {MISSING_TEST_2}

---

### 4. Clean Code Principles

{PASS/FAIL/PARTIAL}: {SUMMARY}

**Adherence**:
- Meaningful names: {PASS/FAIL}
- Function size: {PASS/FAIL} (avg: {AVG_LINES} lines)
- DRY principle: {PASS/FAIL}

**Violations**:
- {VIOLATION_1}

---

### 5. SOLID Principles

{PASS/FAIL/PARTIAL}: {SUMMARY}

**Assessment**:
- Single Responsibility: {PASS/FAIL}
- Open/Closed: {PASS/FAIL}
- Liskov Substitution: {PASS/FAIL}
- Interface Segregation: {PASS/FAIL}
- Dependency Inversion: {PASS/FAIL}

**Notes**:
{DETAILED_NOTES}

---

### 6. File & Folder Structure

{PASS/FAIL/PARTIAL}: {SUMMARY}

**Structure Check**:
- Proper organization: {YES/NO}
- Naming conventions: {YES/NO}
- Import organization: {YES/NO}
- Circular dependencies: {NONE/DETECTED}

---

### 7. Type Hints

{PASS/FAIL/PARTIAL}: {SUMMARY}

**Coverage**:
- Functions with type hints: {PERCENTAGE}%
- Return types specified: {PERCENTAGE}%

**Missing Type Hints**:
- {FUNCTION_1}
- {FUNCTION_2}

---

### 8. Error Handling

{PASS/FAIL/PARTIAL}: {SUMMARY}

**Assessment**:
- Appropriate exceptions: {YES/NO}
- Resource cleanup: {YES/NO}
- Error messages: {CLEAR/UNCLEAR}

---

### 9. Security

{PASS/FAIL/PARTIAL}: {SUMMARY}

**Security Checks**:
- No hardcoded secrets: {PASS/FAIL}
- SQL injection prevention: {PASS/FAIL}
- Input validation: {PASS/FAIL}

**Vulnerabilities**:
- {VULNERABILITY_1}

---

### 10. Performance

{PASS/FAIL/PARTIAL}: {SUMMARY}

**Performance Analysis**:
- Algorithm complexity: {ACCEPTABLE/CONCERNING}
- Database queries: {OPTIMIZED/NEEDS_WORK}
- Memory usage: {EFFICIENT/INEFFICIENT}

---

### 11. Readability

{PASS/FAIL/PARTIAL}: {SUMMARY}

**Readability Score**: {SCORE}/10

**Factors**:
- Code complexity: {LOW/MEDIUM/HIGH}
- Logical flow: {CLEAR/CONFUSING}
- Formatting: {CONSISTENT/INCONSISTENT}

---

### 12. Reusability

{PASS/FAIL/PARTIAL}: {SUMMARY}

**Reusability Assessment**:
- Functions designed for reuse: {YES/NO}
- Hard-coded values extracted: {YES/NO}
- Dependency injection used: {YES/NO}

**Improvements**:
- {IMPROVEMENT_1}

---

## Top Priority Action Items

1. **{PRIORITY_1}** - {DESCRIPTION}
   File: `{FILE}:{LINE}`

2. **{PRIORITY_2}** - {DESCRIPTION}
   File: `{FILE}:{LINE}`

3. **{PRIORITY_3}** - {DESCRIPTION}
   File: `{FILE}:{LINE}`

---

## Strengths (If Any)

{OBJECTIVE_ASSESSMENT_OF_GOOD_PRACTICES}

**Note**: Strengths are noted objectively, but do not offset issues found. Meeting standards is expected, not exceptional.

Examples (only if genuinely present):
- Adequate test coverage for critical paths (>80%)
- Type hints present where required
- Error handling implemented correctly
- Security considerations addressed

---

## Next Steps

### Before Committing:
- [ ] {ACTION_ITEM_1}
- [ ] {ACTION_ITEM_2}
- [ ] {ACTION_ITEM_3}

### Future Improvements:
- {FUTURE_IMPROVEMENT_1}
- {FUTURE_IMPROVEMENT_2}

---

## Appendix: Issue Severity Guide

### 🚨 Critical (Must Fix)
- Security vulnerabilities
- Data loss risks
- Critical bugs
- Breaking changes without migration

### ⚠️ Warning (Should Fix)
- Code quality issues
- Performance problems
- Incomplete test coverage
- SOLID principle violations

### 💡 Suggestion (Nice to Have)
- Style improvements
- Refactoring opportunities
- Documentation enhancements
- Minor optimizations

---

## References

{REFERENCES_USED}

Example:
- [PEP 8 - Style Guide for Python](https://pep8.org/)
- [Clean Code Principles](references/clean-code-principles.md)
- [SOLID Principles](references/solid-principles.md)

---

**Review Generated By**: Claude Code Assistant (pre-commit-code-reviewer skill)
**Report Location**: `.code-reviews/{FILENAME}`
