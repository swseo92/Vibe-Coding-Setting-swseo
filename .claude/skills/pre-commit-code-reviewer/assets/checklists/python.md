# Python Code Review Checklist

Use this checklist to ensure Python code quality before commit.

---

## 🔐 Security (Critical)

- [ ] No hardcoded secrets (API keys, passwords, tokens, database credentials)
- [ ] SQL queries use parameterized statements (no f-strings in SQL)
- [ ] User input is validated and sanitized
- [ ] File paths are validated (prevent path traversal)
- [ ] Dependencies have pinned versions in requirements.txt or pyproject.toml

---

## 🐛 Bugs & Correctness (Critical)

- [ ] No obvious logic errors or incorrect algorithms
- [ ] Edge cases handled (None, empty collections, zero, negative numbers)
- [ ] Type hints present for function signatures
- [ ] No unused imports or variables
- [ ] Proper error handling with try/except where needed
- [ ] No silent failures (errors are logged or raised)

---

## ⚡ Performance (Warning)

- [ ] No N+1 database query patterns
- [ ] Expensive operations are cached if called repeatedly
- [ ] List/dict comprehensions used instead of loops where appropriate
- [ ] No unnecessary deep copies or object creation
- [ ] File handles and database connections are properly closed

---

## ✨ Code Quality (Warning)

- [ ] Functions are focused and < 50 lines
- [ ] Cyclomatic complexity is reasonable (< 10 per function)
- [ ] No code duplication (DRY principle)
- [ ] Descriptive variable and function names
- [ ] No magic numbers (use named constants)
- [ ] No commented-out code

---

## 🏗️ File & Folder Structure (Warning)

- [ ] No single file exceeds 500 lines (300+ lines: consider splitting)
- [ ] Related functionality grouped in subdirectories (models/, services/, utils/)
- [ ] Clear layer separation (API → Service → Repository → DB)
- [ ] No circular import dependencies (A imports B, B imports A)
- [ ] Source code organized in src/ directory (not project root)
- [ ] Consistent module naming (lowercase_with_underscores.py)
- [ ] No flat structure with 20+ files in one directory
- [ ] Imports organized (stdlib → third-party → local)

---

## 📚 Best Practices (Suggestion)

- [ ] Follows PEP 8 style guide
- [ ] Docstrings for all public functions and classes
- [ ] Type hints for function parameters and return values
- [ ] Logging used instead of print statements
- [ ] Constants in UPPER_CASE
- [ ] Class names in PascalCase, functions in snake_case

---

## 🧪 Testing (Warning)

- [ ] New functions have corresponding tests
- [ ] Edge cases are covered in tests
- [ ] Tests use meaningful assertions (not just "no error thrown")
- [ ] External dependencies are mocked
- [ ] Test names clearly describe what is being tested

---

## 📝 Project Documentation (Suggestion)

- [ ] README.md updated if public API, installation, or usage changed
- [ ] CLAUDE.md updated if project structure, workflows, or rules changed

---

## 🎯 Commit Quality (Warning)

- [ ] Commit contains single logical change
- [ ] No debug print() statements
- [ ] No temporary or test files (unless intentional)
- [ ] No IDE-specific files (.vscode/, .idea/)

---

## Scoring Guide

**Pass Criteria:**
- All Critical items PASS
- At least 80% of Warning items PASS
- Score ≥ 70/100

**Score Ranges:**
- 90-100: Excellent (all items pass)
- 70-89: Good (critical + most warnings pass)
- < 70: Needs work (critical issues or too many warnings)
