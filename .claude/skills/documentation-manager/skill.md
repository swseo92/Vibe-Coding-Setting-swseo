---
name: documentation-manager
description: This skill reviews code documentation quality (docstrings, comments, CHANGELOG, API docs) using OpenAI Codex. Trigger when user requests "문서 리뷰", "docstring 체크", "문서화 검토", "review documentation", or "check docs quality".
---

# Documentation Manager

Review and improve code documentation quality using OpenAI Codex.

---

## When to Use

Trigger when user requests:

**Korean:**
- "문서 리뷰 해줘"
- "docstring 체크해줘"
- "문서화 품질 확인"
- "주석 검토"

**English:**
- "review documentation"
- "check docstring quality"
- "review code comments"
- "check documentation completeness"

---

## Prerequisites

**Required:**
- OpenAI Codex CLI: `npm i -g @openai/codex`
- ChatGPT Plus/Pro subscription
- Codex session script: `~/.claude/scripts/codex-session.sh`

**Verify installation:**
```bash
codex --version
ls ~/.claude/scripts/codex-session.sh
```

---

## Core Review Workflow

### Step 1: Detect Scope

Ask user which documentation to review:
- **All** - Complete documentation audit
- **Docstrings** - Function/class/module docstrings only
- **Comments** - Inline code comments
- **Project Docs** - README, CHANGELOG, API docs
- **Specific Files** - User-specified files

### Step 2: Call Codex for Review

**Full Documentation Audit:**
```bash
~/.claude/scripts/codex-session.sh new "Perform comprehensive documentation review.

Check all aspects:

## Docstrings (Critical)
- [ ] All public functions have docstrings (Google Style)
- [ ] All public classes have docstrings
- [ ] All public modules have module docstring
- [ ] Docstrings include Args, Returns, Raises, Examples
- [ ] Type hints present and documented
- [ ] Examples actually work (can be executed)

## Code Comments (Warning)
- [ ] Comments explain 'why' not 'what'
- [ ] No outdated or incorrect comments
- [ ] Complex logic has explanatory comments
- [ ] Workarounds are documented with reason
- [ ] Security considerations documented
- [ ] Performance optimizations explained

## README.md (Critical)
- [ ] Installation instructions current
- [ ] Usage examples work
- [ ] New features documented
- [ ] Configuration options documented
- [ ] Dependencies list updated
- [ ] Quick Start section exists

## CHANGELOG.md (Warning)
- [ ] User-facing changes listed
- [ ] Breaking changes marked
- [ ] Bug fixes documented
- [ ] Security fixes highlighted
- [ ] Links to issues/PRs included

## TODO Comments (Suggestion)
- [ ] TODOs are actionable (not vague)
- [ ] TODOs have assignee or issue link
- [ ] No TODOs older than 6 months

## API Documentation (if applicable)
- [ ] New endpoints documented
- [ ] Request/response formats shown
- [ ] Authentication requirements clear
- [ ] Error responses documented

Provide:
- Overall score (0-100)
- Critical issues (must fix)
- Warnings (should fix)
- Suggestions (nice to have)
- Top 5 most important improvements
- File-specific findings (file:line)

**IMPORTANT: Write all findings in Korean (한국어로 모든 결과를 작성해주세요)**"
```

**Docstrings Only:**
```bash
~/.claude/scripts/codex-session.sh new "Review docstring quality for all public functions and classes.

Focus on:
- Google Style format compliance
- Completeness (Args, Returns, Raises, Examples)
- Type hints present and accurate
- Examples that actually work
- Edge cases documented

For each missing or poor docstring, provide:
- file:line location
- Current state (missing, incomplete, incorrect)
- Suggested improvement

Score: 0-100 based on coverage and quality

**IMPORTANT: Write all findings in Korean (한국어로 작성)**"
```

**Comments Only:**
```bash
~/.claude/scripts/codex-session.sh new "Review inline code comments quality.

Check for:
- Comments explaining 'why' (not 'what')
- Outdated comments that don't match code
- Complex logic without explanation
- Workarounds documented
- TODO quality (actionable, tracked)

Flag anti-patterns:
- Obvious comments (counter += 1 # increment counter)
- Commented-out code
- Vague TODOs (# TODO: fix this)

Provide file:line for each issue

**IMPORTANT: Write all findings in Korean (한국어로 작성)**"
```

**Project Docs Only:**
```bash
~/.claude/scripts/codex-session.sh new "Review project documentation (README, CHANGELOG, API docs).

README.md:
- [ ] Installation steps work
- [ ] Usage examples are current
- [ ] Configuration documented
- [ ] API reference linked
- [ ] Contributing guidelines exist

CHANGELOG.md:
- [ ] Recent changes documented
- [ ] Breaking changes marked
- [ ] Version format correct

API Documentation (if exists):
- [ ] All endpoints documented
- [ ] Request/response formats clear
- [ ] Authentication requirements shown

List missing or outdated sections

**IMPORTANT: Write all findings in Korean (한국어로 작성)**"
```

### Step 3: Save Review Report

```bash
mkdir -p .doc-reviews
# Save to: .doc-reviews/YYYY-MM-DD-HH-MM-docs-review.md
```

### Step 4: Present Findings

```
📚 Documentation Review Complete!

📊 Overall Score: X/100

🚨 Critical Issues: X
⚠️  Warnings: X
💡 Suggestions: X

Top 5 Improvements:
1. [File] Issue description (file:line)
2. [File] Issue description (file:line)
3. [File] Issue description (file:line)
4. [File] Issue description (file:line)
5. [File] Issue description (file:line)

📄 Full report: .doc-reviews/YYYY-MM-DD-HH-MM-docs-review.md
```

---

## Documentation Standards

### Google Style Docstrings (Recommended)

**Function:**
```python
def calculate_total(items: List[float], tax_rate: float = 0.1) -> float:
    """Calculate total price with tax.

    Calculates the sum of all items and applies tax.

    Args:
        items: List of item prices
        tax_rate: Tax rate as decimal (default: 0.1 for 10%)

    Returns:
        Total price after tax

    Raises:
        ValueError: If tax_rate is negative

    Examples:
        >>> calculate_total([10.0, 20.0], tax_rate=0.1)
        33.0

    Note:
        Tax is applied to the subtotal.
    """
```

**Class:**
```python
class UserService:
    """Service for managing user operations.

    Handles user creation, validation, and persistence.

    Attributes:
        database: Database connection
        email_service: Email service for notifications

    Example:
        >>> service = UserService(database, email_service)
        >>> user = service.create_user("Alice", "alice@example.com")
    """
```

**Module:**
```python
"""User management module.

This module provides functionality for user creation, validation,
and persistence.

Typical usage example:

    user_service = UserService(database)
    user = user_service.create_user("Alice", "alice@example.com")
"""
```

### Good Comments vs Bad Comments

```python
# ❌ Bad - states the obvious
# Increment counter by 1
counter += 1

# ✅ Good - explains why
# Increment retry counter to trigger exponential backoff
counter += 1

# ✅ Good - business rule
# Users must wait 24 hours between password changes
# to prevent rapid password cycling attacks
if user.last_password_change > datetime.now() - timedelta(hours=24):
    raise PasswordChangeTooSoonError()

# ✅ Good - workaround
# Workaround for bug in library v1.2.3 where connection
# isn't properly closed. Fixed in v1.3.0.
# TODO: Remove after upgrading to v1.3.0
connection.close()
```

### TODO Comment Standards

```python
# ✅ Good - actionable and tracked
# TODO(alice): Optimize query performance (JIRA-123)
# TODO: Add validation for negative numbers before v2.0 release
# TODO(bob): Handle timezone conversion (see issue #456)

# ❌ Bad - vague and untracked
# TODO: fix this
# TODO: make better
# TODO: refactor
```

---

## Scoring System

| Score | Grade | Meaning | Action |
|-------|-------|---------|--------|
| 90-100 | A | Excellent documentation | ✅ Well documented |
| 80-89 | B | Good documentation | ✅ Minor improvements |
| 70-79 | C | Acceptable | ⚠️ Improve key areas |
| 60-69 | D | Poor documentation | 🔴 Significant work needed |
| 0-59 | F | Severely lacking | 🔴 Major documentation effort |

**Pass Criteria:**
- Score ≥ 70/100
- All public API documented
- README installation/usage current
- No critical documentation gaps

---

## Common Issues to Flag

### Critical (Must Fix)
1. **Missing docstrings** for public functions/classes
2. **README outdated** - installation steps don't work
3. **Undocumented breaking changes**
4. **Missing type hints** on public API
5. **Non-working examples** in documentation

### Warnings (Should Fix)
6. **Incomplete docstrings** - missing Args, Returns, Raises
7. **Outdated comments** that don't match code
8. **No CHANGELOG entry** for user-facing changes
9. **Vague TODOs** without assignee/issue
10. **Complex logic** without explanation

### Suggestions (Nice to Have)
11. **Missing examples** for complex functions
12. **No module docstrings**
13. **Comments stating obvious**
14. **No API documentation** for web services
15. **Missing edge case documentation**

---

## Advanced Usage

### Review Specific Module
```bash
~/.claude/scripts/codex-session.sh new "Review documentation in src/services/user_service.py

Check docstrings, comments, and type hints for this module only.

**Write findings in Korean (한국어로 작성)**"
```

### Generate Documentation
```bash
~/.claude/scripts/codex-session.sh new "Generate missing docstrings for all public functions in src/models/

Use Google Style format with Args, Returns, Examples.

**Write in Korean (한국어로 작성)**"
```

### Update CHANGELOG
```bash
~/.claude/scripts/codex-session.sh new "Review recent commits and update CHANGELOG.md

Categorize changes into Added, Changed, Fixed, Deprecated, Security.

**Write in Korean (한국어로 작성)**"
```

---

## Best Practices

**Do's ✅**

1. **Document public API first**
   - All public functions, classes, modules
   - Type hints on all parameters and returns

2. **Write examples that work**
   - Test examples in docstrings
   - Use doctests when possible

3. **Explain "why" not "what"**
   - Comments should add value
   - Code should be self-explanatory

4. **Keep docs in sync**
   - Update docs when code changes
   - Review documentation in code reviews

**Don'ts ❌**

1. **Don't write obvious comments**
   - `counter += 1  # increment counter` ❌

2. **Don't leave outdated docs**
   - Update or remove if no longer valid

3. **Don't write vague TODOs**
   - Add assignee and issue link

4. **Don't forget CHANGELOG**
   - User-facing changes need changelog entry

---

## Troubleshooting

### "No docstrings found"
- Verify files have Python docstrings
- Check if functions are public (not starting with _)

### "Examples don't work"
- Test docstring examples manually
- Use pytest --doctest-modules to verify

### "Outdated documentation"
- Compare code changes with docs
- Update README/CHANGELOG for each release

---

## Integration with Pre-Commit Review

Use both skills together:

1. **Pre-commit review** - Code quality, structure, security
2. **Documentation manager** - Documentation completeness, quality

```bash
# First: code review
/pre-commit-code-reviewer

# Then: documentation review
/documentation-manager
```

Or use documentation review for major features:
- Before release
- After significant refactoring
- For new public APIs

---

## Recursive README Generation (NEW)

**Automatically generate and maintain README files for folder structure.**

### Quick Start

Generate READMEs for your project folders using Claude + Codex cross-validation:

```bash
# Initialize configuration
/documentation-manager --init-config

# Generate/update READMEs
/documentation-manager --recursive-readme

# Check existing READMEs
/documentation-manager --check-recursive
```

### Key Features

- **Configuration-driven** - Control which folders via `.readme-config.json`
- **Cross-validation** - Claude writes, Codex reviews, Claude refines
- **Adaptive rounds** - Critical folders get 3 rounds, standard get 2
- **Cost-efficient** - ~$0.05/folder with caching and smart detection
- **CI-friendly** - Integrates with GitHub Actions, GitLab CI, etc.

### Example Cost

- **15 folders**: $1-5/month
- **50 folders**: $5-10/month (⚠️ monitor carefully)

### When to Use

- Project has 5-50 folders needing documentation
- README maintenance burden is high
- Team wants consistent documentation format
- Willing to review 10% monthly for quality

**For detailed guides, configuration reference, troubleshooting, and CI integration:**

📖 **See `references/recursive-readme.md`**

---

## Limitations

**This skill cannot:**
- Auto-generate perfect docstrings (review only)
- Run doctests (use pytest separately)
- Replace human review for complex docs
- Detect all documentation issues
- Guarantee 100% accurate READMEs (LLM limitations)
- Scale to 100+ folders economically

**Best practice:** Use as a checklist, verify critical findings manually.

---

**Version:** 1.1 (Added Recursive README)
**Last Updated:** 2025-11-04
