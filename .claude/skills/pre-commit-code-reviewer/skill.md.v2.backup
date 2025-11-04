---
name: pre-commit-code-reviewer
description: Perform comprehensive code review using OpenAI Codex (GPT-5-Codex) as LLM judge before git commit for Python projects. Analyze staged changes for bugs, security, performance, readability, and best practices. Generate scored reviews (0-100) with detailed markdown reports saved to .code-reviews/ directory.
---

# Pre-Commit Code Reviewer (Codex-Powered)

## Overview

This skill uses **OpenAI Codex CLI** (GPT-5-Codex model) as an LLM judge to perform comprehensive code reviews before commit. Get objective, scored assessments (0-100) with categorized issues (critical/warning/suggestion) and detailed improvement recommendations.

## Prerequisites

**Required:**
- OpenAI Codex CLI installed: `npm i -g @openai/codex`
- ChatGPT Plus/Pro subscription (or OpenAI API access)
- Git repository with staged changes

**Verify:**
```bash
codex --version
# Should show: codex-cli 0.50.0 or higher
```

## When to Use This Skill

Activate this skill when:
- User says "커밋 전에 코드 리뷰 해줘" or "review my code before commit"
- User says "이 코드 커밋해도 괜찮을까?" or "is this code ready to commit?"
- User explicitly requests code review before committing changes
- User wants to check if changes follow best practices
- User says "pre-commit review" or "check before commit"

Trigger keywords: code review, commit review, 커밋 리뷰, pre-commit, review changes, check code

## Review Mindset: Be Critical, Not Complimentary

**IMPORTANT**: This is a CODE REVIEW, not a praise session. Codex is configured to FIND PROBLEMS.

### Critical Review Principles

Codex is instructed to:
- Actively look for bugs, security issues, and code smells
- Question design decisions and implementation choices
- Apply high standards without being apologetic
- Find issues even in "good-looking" code
- Treat every line of code as potentially problematic

**Default stance**: "What could go wrong with this code?"

### Quality Bar

**PASS criteria** (all must be true):
- ✅ Score ≥ 70/100
- ✅ No critical security vulnerabilities
- ✅ No obvious bugs
- ✅ Adequate test coverage
- ✅ Documentation present
- ✅ Error handling present

**Anything less = NEEDS WORK**

## Core Review Process

Follow this workflow for every code review request:

### Step 1: Verify Codex CLI Installation

```bash
codex --version
```

If not installed, inform user:
```
❌ Codex CLI not found.

Install with:
  npm i -g @openai/codex

Then authenticate with ChatGPT Plus account:
  codex
```

### Step 2: Identify Staged Changes

```bash
# Get list of staged files
git diff --staged --name-only

# Get detailed diff
git diff --staged
```

If no files are staged:
- Inform user: "No staged changes found. Use 'git add <files>' to stage changes first."
- Stop the review process

### Step 3: Call Codex CLI for Review

Execute Codex CLI with structured prompt:

```bash
codex exec "Act as an expert LLM judge performing critical code review for commit readiness.

Review the following aspects with HIGH STANDARDS:
- Bugs and correctness
- Security vulnerabilities (SQL injection, XSS, auth issues, etc.)
- Performance issues (algorithm complexity, N+1 queries, memory leaks)
- Code quality and readability (naming, complexity, duplication)
- Best practices adherence (SOLID, DRY, type hints, error handling)
- Test coverage (do tests exist for new code?)
- Documentation (docstrings, comments, README updates)

Your role is to FIND PROBLEMS, not to praise. Be critical and thorough.

Provide response in this EXACT format:

OVERALL SCORE: X/100

CRITICAL ISSUES (must fix before commit):
- [file:line] Description and impact
- [file:line] Description and impact

WARNINGS (should fix):
- [file:line] Description
- [file:line] Description

SUGGESTIONS (nice to have):
- [file:line] Description
- [file:line] Description

RECOMMENDATION: [commit | needs_work | major_refactor]

SUMMARY: [2-3 sentence critical assessment]

Here's the git diff to review:
$(git diff --staged)
"
```

**Important flags:**
- Default mode is `--mode suggest` (read-only, safe)
- Codex won't modify files during review
- Review only, no auto-fixing

### Step 4: Parse Codex Response

Extract key information:
- Overall score (0-100)
- Critical issue count
- Warning count
- Suggestion count
- Recommendation (commit/needs_work/major_refactor)
- Summary

**Example Codex output:**
```
OVERALL SCORE: 65/100

CRITICAL ISSUES (must fix before commit):
- [user.py:45] SQL injection risk: f-string allows arbitrary SQL execution

WARNINGS (should fix):
- [user.py:15] Missing type hints reduces type safety
- [test_user.py:20] Insufficient test coverage for error cases

SUGGESTIONS (nice to have):
- [user.py:50] Function too complex, consider splitting
- [user.py:1] Add module-level docstring

RECOMMENDATION: needs_work

SUMMARY: Critical SQL injection vulnerability must be addressed before commit. Code also lacks type hints and comprehensive tests. Fix security issue and add type safety before merging.
```

### Step 5: Generate Review Report

Create comprehensive markdown report using template:

**Template structure:**
```markdown
# Code Review Report - [Date Time]

**Reviewer:** OpenAI Codex (GPT-5-Codex)
**Date:** YYYY-MM-DD HH:MM
**Overall Score:** X/100
**Recommendation:** [COMMIT | NEEDS WORK | MAJOR REFACTOR]

---

## Summary

[Codex's summary]

---

## Score Breakdown

| Metric | Score | Status |
|--------|-------|--------|
| Overall Quality | X/100 | [Pass/Fail] |
| Critical Issues | X | [🚨 if >0, ✅ if 0] |
| Warnings | X | [⚠️ if >3, ✅ if ≤3] |
| Suggestions | X | [💡] |

**Pass Threshold:** ≥70/100 with 0 critical issues

---

## Files Reviewed

- file1.py (Modified)
- file2.py (New)
- test_file.py (Modified)

---

## 🚨 Critical Issues

**These MUST be fixed before commit:**

1. **[file:line] Issue title**
   - **Severity:** Critical
   - **Description:** [Full description]
   - **Impact:** [What could go wrong]
   - **Fix:** [How to fix]

---

## ⚠️ Warnings

**These SHOULD be fixed:**

1. **[file:line] Issue title**
   - **Severity:** Warning
   - **Description:** [Full description]
   - **Suggestion:** [How to improve]

---

## 💡 Suggestions

**Nice to have improvements:**

1. **[file:line] Issue title**
   - **Description:** [Full description]
   - **Benefit:** [Why this helps]

---

## Recommendation

[COMMIT ✅ | NEEDS WORK 🔴 | MAJOR REFACTOR 🔥]

**Reasoning:**
[Explanation based on score and issues]

**Next Steps:**
- [ ] Fix critical issue: [description]
- [ ] Address warning: [description]
- [ ] Consider suggestion: [description]

---

## Full Codex Output

```
[Complete Codex CLI output for reference]
```

---

**Generated by:** Pre-Commit Code Reviewer (Codex-Powered)
**Model:** GPT-5-Codex via OpenAI Codex CLI
**Session:** [timestamp]
```

### Step 6: Save Review Report

Save to `.code-reviews/` directory:

```bash
# Create directory if needed
mkdir -p .code-reviews

# Save report
.code-reviews/YYYY-MM-DD-HH-MM-codex-review.md
```

**Example filename:** `.code-reviews/2025-01-27-16-30-codex-review.md`

Add to `.gitignore` if needed (optional):
```bash
# Option 1: Keep reviews in repo (recommended for team learning)
# .code-reviews/ is committed

# Option 2: Local reviews only
echo ".code-reviews/" >> .gitignore
```

### Step 7: Present Findings to User

**Console output format:**

```
📋 Codex Code Review Complete!

📁 Files Reviewed: 3
  - src/api/user.py (Modified)
  - src/models/user_model.py (Modified)
  - tests/test_user.py (New)

📊 Overall Score: 65/100

🚨 Critical Issues: 1
⚠️  Warnings: 3
💡 Suggestions: 5

---

Top 3 Issues to Address:

1. 🚨 [CRITICAL] SQL injection vulnerability (user.py:45)
   → f-string allows arbitrary SQL execution
   → FIX: Use parameterized queries

2. ⚠️  [WARNING] Missing type hints (user.py:15-20)
   → Reduces type safety
   → ADD: def get_user(id: int) -> Optional[User]:

3. ⚠️  [WARNING] Insufficient test coverage (test_user.py)
   → Error cases not tested
   → ADD: Test for None inputs, database failures

---

🔴 Recommendation: NEEDS WORK

Fix the critical SQL injection vulnerability before committing.
Address type hints and test coverage in near future.

📄 Full report saved to:
   .code-reviews/2025-01-27-16-30-codex-review.md

---

Would you like me to:
1. Show the full Codex analysis?
2. Help fix the SQL injection issue?
3. Generate improved code with Codex auto-fix?
```

## Codex Review Dimensions

Codex analyzes these aspects automatically:

### 1. Security
- SQL injection, XSS, CSRF
- Authentication/authorization issues
- Hardcoded secrets
- Input validation
- Dependency vulnerabilities

### 2. Bugs & Correctness
- Logic errors
- Edge case handling
- None/null pointer issues
- Type mismatches
- Off-by-one errors
- Resource leaks

### 3. Performance
- Algorithm complexity (O(n²) vs O(n))
- Database N+1 queries
- Memory leaks
- Unnecessary computations
- Missing caching

### 4. Code Quality
- Function length and complexity
- Code duplication (DRY)
- Naming conventions
- Magic numbers
- Dead code

### 5. Best Practices
- SOLID principles
- Type hints (Python)
- Error handling
- Logging
- Documentation

### 6. Testing
- Test coverage for new code
- Edge cases covered
- Mocking appropriately
- Test naming

### 7. Documentation
- Docstrings
- Comments (why, not what)
- README updates
- API docs

## Scoring System

Codex uses this scale:

| Score | Grade | Meaning | Action |
|-------|-------|---------|--------|
| 90-100 | A | Excellent | ✅ Commit ready |
| 80-89 | B | Good | ✅ Commit with minor notes |
| 70-79 | C | Acceptable | ⚠️ Commit, but improve soon |
| 60-69 | D | Needs work | 🔴 Fix issues before commit |
| 0-59 | F | Poor | 🔴 Major refactoring needed |

**Critical issues always block commit, regardless of score.**

## Advanced Usage

### Option 1: Quick Review (Default)

```bash
# Standard review mode
codex exec "Review this diff: $(git diff --staged)"
```

### Option 2: Detailed Review

```bash
# Request more detailed analysis
codex exec "Perform VERY thorough code review with detailed explanations for each issue. Include code examples for fixes: $(git diff --staged)"
```

### Option 3: Specific Aspect Review

```bash
# Focus on security only
codex exec "Review this diff ONLY for security vulnerabilities. Be extremely thorough: $(git diff --staged)"

# Focus on performance only
codex exec "Review this diff ONLY for performance issues and algorithm complexity: $(git diff --staged)"
```

### Option 4: Compare with Auto-fix

```bash
# 1. Get review
codex exec "Review: $(git diff --staged)"

# 2. If issues found, ask Codex to fix
codex exec --mode auto-edit "Fix the SQL injection and add type hints in user.py"

# 3. Review again
codex exec "Review the fixed version: $(git diff --staged)"
```

## Integration with Git Hooks

### Pre-commit Hook (Optional)

Create `.git/hooks/pre-commit`:

```bash
#!/bin/bash

echo "🔍 Running Codex code review..."

# Check if there are staged changes
if git diff --staged --quiet; then
    echo "No staged changes to review."
    exit 0
fi

# Run Codex review
REVIEW=$(codex exec "Quick review, score only: $(git diff --staged)")

# Extract score (basic parsing)
SCORE=$(echo "$REVIEW" | grep -oP 'OVERALL SCORE: \K\d+')

if [ -z "$SCORE" ]; then
    echo "⚠️  Could not determine score, allowing commit"
    exit 0
fi

# Block commit if score < 70
if [ "$SCORE" -lt 70 ]; then
    echo "❌ Code review failed (Score: $SCORE/100)"
    echo "Fix issues before committing."
    exit 1
fi

echo "✅ Code review passed (Score: $SCORE/100)"
exit 0
```

Make executable:
```bash
chmod +x .git/hooks/pre-commit
```

## Best Practices

### Do's ✅

1. **Always review before commit**
   - Make it a habit
   - Catch issues early
   - Improve code quality over time

2. **Trust but verify**
   - Codex is very good but not perfect
   - Review Codex's suggestions critically
   - Use your judgment

3. **Fix critical issues immediately**
   - Never commit with critical security issues
   - Address bugs before they reach production
   - Don't accumulate technical debt

4. **Track review history**
   - Keep `.code-reviews/` in git
   - Learn from past issues
   - Measure quality trends

5. **Use specific prompts**
   - Ask for detailed explanations when needed
   - Focus on specific aspects (security, performance)
   - Request code examples for fixes

### Don'ts ❌

1. **Don't skip reviews for "small" changes**
   - Small changes can have big bugs
   - Security issues don't discriminate by LOC
   - Build the habit

2. **Don't ignore warnings**
   - Today's warning = tomorrow's bug
   - Code quality compounds
   - Fix early, fix often

3. **Don't commit on red**
   - If recommendation is "needs_work", don't commit
   - If critical issues exist, fix first
   - Never compromise on security

4. **Don't review huge diffs**
   - Break large changes into smaller commits
   - Review file-by-file if needed
   - Large diffs = missed issues

5. **Don't disable the skill**
   - Consistency is key
   - Quality requires discipline
   - Make it non-negotiable

## Comparison: Codex vs Claude Review

| Feature | Codex (This Skill) | Claude Built-in |
|---------|-------------------|-----------------|
| **Model** | GPT-5-Codex | Claude 3.5 Sonnet |
| **Scoring** | 0-100 (LLM Judge) | Manual |
| **Format** | Structured | Flexible |
| **Speed** | Medium (~5-10s) | Fast (~2-5s) |
| **Cost** | $20/mo (ChatGPT Plus) | Included |
| **Strictness** | Very strict | Configurable |
| **Auto-fix** | Yes (separate mode) | Via Claude |

**Recommendation:** Use both for comprehensive review!

## Troubleshooting

### Error: "codex: command not found"

**Solution:**
```bash
# Install Codex CLI
npm i -g @openai/codex

# Verify
codex --version
```

### Error: "Authentication required"

**Solution:**
```bash
# Run once to authenticate
codex

# Sign in with ChatGPT Plus account
```

### Error: "No staged changes found"

**Solution:**
```bash
# Stage files first
git add file1.py file2.py

# Or stage all
git add .

# Then request review
```

### Warning: "Score could not be determined"

**Possible causes:**
- Codex output format unexpected
- Network issues
- Rate limiting

**Solution:**
- Retry the review
- Check internet connection
- Verify Codex CLI is up to date

### Issue: "Review too slow"

**Solutions:**
- Review smaller diffs (break into multiple commits)
- Use Quick Review mode
- Check network speed

### Issue: "Codex missed an obvious bug"

**Remember:**
- No LLM is perfect
- Always use critical thinking
- Combine Codex + Claude + Human review
- Report patterns to improve prompts

## Example Usage

### Example 1: Basic Review

**User:** "커밋 전에 코드 리뷰 해줘"

**Claude:**
```
Checking staged changes...

Found 2 staged files:
- src/user_service.py (Modified)
- tests/test_user_service.py (New)

Running Codex code review...
[Calls Codex CLI]

📋 Codex Code Review Complete!

📊 Overall Score: 78/100

🚨 Critical Issues: 0
⚠️  Warnings: 2
💡 Suggestions: 3

Top Issues:
1. ⚠️  Missing type hints (user_service.py:15)
2. ⚠️  Error handling could be more specific (user_service.py:30)
3. 💡 Consider using dataclass for User model

✅ Recommendation: COMMIT

Code is production-ready. Address warnings in future refactoring.

📄 Full report: .code-reviews/2025-01-27-16-45-codex-review.md
```

### Example 2: Critical Issues Found

**User:** "Is this ready to commit?"

**Claude:**
```
Reviewing staged changes with Codex...

📋 Codex Code Review Complete!

📊 Overall Score: 35/100

🚨 Critical Issues: 2
⚠️  Warnings: 4
💡 Suggestions: 6

Top Issues:
1. 🚨 [CRITICAL] SQL injection (user.py:45)
   Severity: High - allows arbitrary SQL execution

2. 🚨 [CRITICAL] Hardcoded API key (config.py:12)
   Severity: High - security credential exposed

3. ⚠️  Missing error handling (api.py:67)

🔴 Recommendation: NEEDS WORK

DO NOT COMMIT until critical security issues are fixed.

Would you like me to help fix these issues?
```

## Cost Considerations

**Codex CLI Pricing:**
- **ChatGPT Plus:** $20/month (unlimited reviews)
- **ChatGPT Pro:** $200/month (higher limits)
- **API:** Pay-per-use (~$0.01-0.05/review)

**Typical usage:**
- Solo developer: ~10-50 reviews/day → ChatGPT Plus sufficient
- Team: ~100+ reviews/day → ChatGPT Team or API

**Free alternative:**
- Use built-in Claude review (no Codex)
- See: `.claude/skills/pre-commit-code-reviewer/skill.md.backup`

## Resources

### Documentation
- [OpenAI Codex CLI](https://developers.openai.com/codex/cli/)
- [Codex GitHub](https://github.com/openai/codex)
- [OpenAI Codex Guide](../../docs/openai-codex-guide.md)

### Related Skills
- `codex-integration` - General Codex usage
- Original Claude review: `skill.md.backup`

### Templates
- Review report template: `assets/review-report-template.md`
- Git hook examples: `.git/hooks/pre-commit`

## Limitations

This skill cannot:
- Execute code or run tests (use pytest separately)
- Access external linters (use alongside, not replace)
- Modify code automatically (use `--mode auto-edit` separately)
- Review changes not yet staged
- Detect all runtime-only issues
- Replace human code review for complex changes

**Always combine:** Codex + Claude + Human review for critical code

---

**Version:** 2.0 (Codex-Powered)
**Last Updated:** 2025-01-27
**Model:** GPT-5-Codex via OpenAI Codex CLI
**Backup:** Original Claude-based version saved to `skill.md.backup`
