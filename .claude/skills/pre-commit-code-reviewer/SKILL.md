---
name: pre-commit-code-reviewer
description: This skill should be used when user requests code review before git commit. Trigger when user says "커밋 리뷰", "commit review", "pre-commit review", "review before commit", "코드 리뷰해줘", or "커밋 전에 리뷰". Uses OpenAI Codex with project-specific checklists for scored reviews (0-100).
---

# Pre-Commit Code Reviewer

Use OpenAI Codex to review staged changes before commit with project-specific quality standards.

---

## When to Use

Trigger when user requests:

**Korean:**
- "커밋 전에 코드 리뷰 해줘"
- "이 코드 커밋해도 괜찮을까?"
- "커밋 리뷰"
- "pre-commit review"

**English:**
- "review my code before commit"
- "is this code ready to commit?"
- "check before commit"
- "review staged changes"

---

## Prerequisites

**Required:**
- OpenAI Codex CLI: `npm i -g @openai/codex`
- ChatGPT Plus/Pro subscription
- Git repository with staged changes

**Verify installation:**
```bash
codex --version
# Should show: codex-cli 0.50.0 or higher
```

---

## Core Review Workflow

### Step 1: Verify Prerequisites

**Check 1: Codex session script**
```bash
ls ~/.claude/scripts/codex-session.sh
```

If not found, **STOP and inform user**:
```
❌ Codex session script not found.

Required: ~/.claude/scripts/codex-session.sh
This script is part of Vibe-Coding-Setting.

To fix:
1. Clone/update Vibe-Coding-Setting repository
2. Run /apply-settings or /sync-workspace
3. Verify: ls ~/.claude/scripts/codex-session.sh
```

**Check 2: Codex CLI**
```bash
codex --version
```

If not installed, inform user:
```
❌ Codex CLI not found.

Install: npm i -g @openai/codex
Authenticate: codex (sign in with ChatGPT Plus account)
```

### Step 2: Check for Staged Changes

```bash
git diff --staged --name-only
```

If no files staged, inform user to stage files first.

### Step 3: Detect Project Checklist

Check if project has custom checklist (in priority order):

1. `.code-review/checklist.md` (project-specific)
2. `.code-review/checklist-{language}.md` (auto-detect language)
3. Built-in default (no checklist file)

**Auto-detect language:**
- Mostly `.py` files → python
- Mostly `.js/.ts` files → javascript
- Mostly `.sh` files → bash
- Mixed or other → default

### Step 4: Call Codex for Review

**With project checklist:**
```bash
~/.claude/scripts/codex-session.sh new "Review my staged changes following the checklist in .code-review/checklist.md

For each checklist item, report:
- ✅ PASS or ❌ FAIL
- If FAIL: file:line, description, and fix recommendation

Then provide:
- Overall score (0-100)
- Top 3 issues
- Recommendation: commit | needs_work | major_refactor
- 2-3 sentence summary

**IMPORTANT: Write all findings in Korean (한국어로 모든 결과를 작성해주세요)**"
```

**Without checklist (default):**
```bash
~/.claude/scripts/codex-session.sh new "Review my staged changes for commit readiness.

Focus on: security, bugs, performance, code quality, tests, documentation.

Provide:
- Overall score (0-100)
- Critical issues (must fix)
- Warnings (should fix)
- Suggestions (nice to have)
- Recommendation: commit | needs_work | major_refactor
- 2-3 sentence summary

**IMPORTANT: Write all findings in Korean (한국어로 모든 결과를 작성해주세요)**"
```

**Note:** Codex is a full agent - it will:
- Detect staged changes automatically
- Read full files for context (not just diffs)
- Apply critical review standards
- Find problems, not give praise

### Step 5: Save Review Report

Create `.code-reviews/` directory if needed and save report:

```bash
mkdir -p .code-reviews
# Save to: .code-reviews/YYYY-MM-DD-HH-MM-review.md
```

### Step 6: Present Findings

Display console summary:

```
📋 Code Review Complete!

📊 Overall Score: X/100

🚨 Critical Issues: X
⚠️  Warnings: X
💡 Suggestions: X

Top 3 Issues:
1. [Type] Description (file:line)
2. [Type] Description (file:line)
3. [Type] Description (file:line)

[✅ COMMIT | 🔴 NEEDS WORK | 🔥 MAJOR REFACTOR]

📄 Full report: .code-reviews/YYYY-MM-DD-HH-MM-review.md
```

---

## Checklist System

### Using Project Checklist

Projects can maintain quality standards in `.code-review/checklist.md`:

**Benefits:**
- Consistent review criteria across all commits
- Team-specific standards
- Language-specific best practices
- Evolves with project (version controlled)

**Checklist format:**
- Markdown file with checkbox items
- Organized by severity (Critical/Warning/Suggestion)
- Each item has clear pass/fail criteria

See `references/checklist-guide.md` for checklist design principles.

### Creating Project Checklist

**Option 1: Copy starter template**
```bash
mkdir -p .code-review
cp ~/.claude/skills/pre-commit-code-reviewer/assets/checklists/python.md \
   .code-review/checklist.md
```

**Option 2: Generate with Codex**
```bash
~/.claude/scripts/codex-session.sh new "Create a code review checklist for my project.
Analyze the codebase and create .code-review/checklist.md with:
- Project-specific quality standards
- Language best practices
- Security requirements
- Testing expectations

**Write checklist in Korean (한국어로 체크리스트 작성)**"
```

Customize the generated checklist for your team's needs.

### Available Starter Templates

See `assets/checklists/` for language-specific templates:

- `python.md` - Python projects (PEP 8, type hints, pytest)
- `javascript.md` - JavaScript/TypeScript (ESLint, Jest)
- `bash.md` - Shell scripts (shellcheck, error handling)
- `security.md` - Security-focused (OWASP, secrets, auth)
- `docs.md` - Documentation (markdown, clarity, accuracy)

Copy and customize for your project.

---

## Review Philosophy

**Core principle:** Be critical, not complimentary.

Codex is instructed to:
- Find problems, not praise code
- Apply high standards
- Question design decisions
- Treat code as potentially problematic
- Default stance: "What could go wrong?"

See `references/review-philosophy.md` for detailed philosophy and examples.

### Pass Criteria

**All must be true:**
- ✅ Score ≥ 70/100
- ✅ No critical security issues
- ✅ No obvious bugs
- ✅ Error handling present
- ✅ Basic documentation exists

**Anything less = NEEDS WORK**

Critical issues always block commit regardless of score.

---

## Scoring System

| Score | Grade | Meaning | Action |
|-------|-------|---------|--------|
| 90-100 | A | Excellent | ✅ Commit ready |
| 80-89 | B | Good | ✅ Commit with minor notes |
| 70-79 | C | Acceptable | ⚠️ Commit, improve soon |
| 60-69 | D | Needs work | 🔴 Fix issues first |
| 0-59 | F | Poor | 🔴 Major refactoring needed |

See `references/scoring-system.md` for detailed scoring breakdown.

---

## Advanced Usage

### Multiple Checklists

Combine general and specialized checklists:

```bash
~/.claude/scripts/codex-session.sh new "Review staged changes using:
1. .code-review/checklist.md (general standards)
2. .code-review/checklist-security.md (security focus)

Combine results and provide overall assessment.

**Write all findings in Korean (한국어로 작성)**"
```

### Language-Specific Auto-Selection

```bash
~/.claude/scripts/codex-session.sh new "Review staged changes.
Auto-select appropriate checklist from .code-review/ based on file types:
- .py files → checklist-python.md
- .js/.ts files → checklist-javascript.md
- .sh files → checklist-bash.md
- .md files → checklist-docs.md

Use most relevant checklist for each file.

**Write all findings in Korean (한국어로 작성)**"
```

### Specific Aspect Focus

```bash
# Security only
~/.claude/scripts/codex-session.sh new "Review staged changes for security vulnerabilities only.
Use .code-review/checklist-security.md

**Write all findings in Korean (한국어로 작성)**"

# Performance only
~/.claude/scripts/codex-session.sh new "Review staged changes for performance issues only.
Focus on algorithm complexity, N+1 queries, caching.

**Write all findings in Korean (한국어로 작성)**"
```

---

## Best Practices

**Do's ✅**

1. **Review before every commit**
   - Make it a habit
   - Catch issues early
   - Maintain quality

2. **Maintain project checklist**
   - Keep `.code-review/checklist.md` updated
   - Evolve with project learnings
   - Version control the checklist

3. **Trust but verify**
   - Codex is good but not perfect
   - Apply human judgment
   - Verify critical suggestions

4. **Fix critical issues immediately**
   - Never commit with critical security issues
   - Address bugs before production
   - Don't accumulate technical debt

**Don'ts ❌**

1. **Don't skip reviews**
   - Even for "small" changes
   - Security issues don't discriminate by size

2. **Don't ignore warnings**
   - Today's warning = tomorrow's bug
   - Code quality compounds

3. **Don't commit on red**
   - If recommendation is "needs_work", don't commit
   - Fix critical issues first

4. **Don't review huge diffs**
   - Break large changes into smaller commits
   - Large diffs = missed issues

---

## Troubleshooting

### "codex: command not found"

**Solution:**
```bash
npm i -g @openai/codex
codex --version
```

### "Authentication required"

**Solution:**
```bash
codex  # Run once to authenticate
# Sign in with ChatGPT Plus account
```

### "No staged changes"

**Solution:**
```bash
git add file1.py file2.py
# Or: git add .
```

### "Review output unclear"

**Possible causes:**
- Checklist items ambiguous
- Diff too large
- Mixed languages

**Solution:**
- Clarify checklist wording
- Break into smaller commits
- Use language-specific checklists

---

## Resources

### References

Detailed documentation for deep understanding:

- **`references/review-philosophy.md`** - Critical review approach, pass criteria
- **`references/scoring-system.md`** - Score breakdown, examples
- **`references/checklist-guide.md`** - How to write effective checklists
- **`references/codex-usage.md`** - Codex CLI tips and tricks

### Checklist Templates

Starter templates for common languages:

- **`assets/checklists/python.md`** - Python best practices
- **`assets/checklists/javascript.md`** - JS/TS standards
- **`assets/checklists/bash.md`** - Shell script quality
- **`assets/checklists/security.md`** - Security checklist
- **`assets/checklists/docs.md`** - Documentation quality

Copy to your project and customize.

### Related Documentation

- [OpenAI Codex CLI](https://developers.openai.com/codex/cli/)
- [OpenAI Codex Guide](../../docs/openai-codex-guide.md)
- [Codex Session Management](../../docs/codex-session-management.md)

---

## Limitations

**This skill cannot:**
- Execute code or run tests (use pytest separately)
- Replace linters (use alongside, not instead)
- Auto-fix code (use Codex `--mode auto-edit` separately)
- Review untracked/unstaged changes
- Detect all runtime issues
- Replace human review for complex changes

**Best practice:** Combine Codex + Claude + Human review for critical code.

---

**Version:** 3.0 (Checklist-Based)
**Last Updated:** 2025-11-02
**Previous Version:** `skill.md.v2.backup`
