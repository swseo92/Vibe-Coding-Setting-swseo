---
name: codex-integration
description: Use OpenAI Codex CLI for code review, bug fixing, and autonomous coding tasks. Trigger when user says "codex로 리뷰해줘", "use codex", or "codex fix this".
---

# OpenAI Codex CLI Integration

## Overview

This skill integrates OpenAI's Codex CLI (2025 version) directly into Claude Code workflows. Use Codex as an LLM judge for code review or as an autonomous coding agent.

## Prerequisites

**Required:**
- OpenAI Codex CLI installed: `npm i -g @openai/codex`
- ChatGPT Plus/Pro subscription (or API access)
- Authenticated: Run `codex` once to authenticate

**Verify installation:**
```bash
codex --version
```

## When to Use This Skill

Activate when user says:
- "codex로 코드 리뷰해줘" / "review with codex"
- "codex 사용해서 고쳐줘" / "use codex to fix"
- "codex에게 물어봐" / "ask codex"
- "openai codex 사용" / "use openai codex"

## Core Capabilities

### 1. Code Review (LLM as Judge)

Use Codex to review staged git changes:

```bash
# Get staged diff
git diff --staged > /tmp/review.diff

# Review with Codex
codex exec "Review this git diff for bugs, security issues, and code quality. Provide scored assessment (0-100) and categorize issues as critical/warning/suggestion: $(cat /tmp/review.diff)"
```

**Output format requested:**
- Overall score: 0-100
- Critical issues (must fix)
- Warnings (should fix)
- Suggestions (nice to have)
- Recommendation: commit / needs_work / major_refactor

### 2. Autonomous Bug Fixing

Let Codex autonomously fix issues:

```bash
# Auto-fix mode (will edit files automatically)
codex exec --mode auto-edit "Fix the SQL injection vulnerability in user_service.py line 45"
```

### 3. Code Explanation

```bash
codex exec "Explain what this function does and identify potential bugs: $(cat path/to/file.py)"
```

### 4. Interactive Session

For complex tasks, start interactive mode:

```bash
codex
# Then chat naturally about code tasks
```

## Approval Modes

Choose based on trust level:

**For Code Review (Read-only):**
```bash
codex exec --mode suggest "Review this code..."
```
- Safe, no file modifications
- Codex only analyzes and reports

**For Auto-fixing (Write access):**
```bash
codex exec --mode auto-edit "Fix security issues in..."
```
- Codex edits files automatically
- Still asks before running commands

**Full Autonomy:**
```bash
codex exec --mode full-auto "Refactor user module to use dependency injection"
```
- Complete autonomy
- Use with caution!

## Workflow: Pre-Commit Review with Codex

### Step 1: Check Staged Changes

```bash
git diff --staged --name-only
```

If no files staged, stop and inform user.

### Step 2: Get Detailed Diff

```bash
git diff --staged > /tmp/staged.diff
```

### Step 3: Codex Review

```bash
codex exec "Act as an LLM judge and review this git diff.

Review aspects:
- Bugs and correctness
- Security vulnerabilities
- Performance issues
- Code quality and readability
- Best practices adherence

Provide response in this format:

OVERALL SCORE: X/100

CRITICAL ISSUES (must fix before commit):
- [Issue 1]
- [Issue 2]

WARNINGS (should fix):
- [Warning 1]

SUGGESTIONS (nice to have):
- [Suggestion 1]

RECOMMENDATION: [commit | needs_work | major_refactor]

SUMMARY: [Brief assessment]

Here's the diff:
$(cat /tmp/staged.diff)
"
```

### Step 4: Parse and Present Results

Extract key metrics:
- Overall score
- Issue counts
- Top 3 critical issues
- Recommendation

### Step 5: Save Review Report

Save Codex output to:
```
.code-reviews/YYYY-MM-DD-HH-MM-codex-review.md
```

## Example Usage

**User:** "codex로 커밋 전 리뷰해줘"

**Claude Response:**
```
Reviewing staged changes with OpenAI Codex...

Found 2 staged files:
- src/api/user.py
- tests/test_user.py

Calling Codex CLI for review...

📋 Codex Review Complete!

Overall Score: 65/100

🚨 Critical Issues: 1
- SQL injection vulnerability (user.py:45)

⚠️  Warnings: 3
- Missing type hints (user.py:15-20)
- Insufficient test coverage (test_user.py)
- Complex function should be split (user.py:50-85)

💡 Suggestions: 4
- Use dataclass for User model
- Add docstrings
- Extract validation logic
- Use constant for magic numbers

🔴 Recommendation: NEEDS_WORK

Fix critical SQL injection before committing.

📄 Full review: .code-reviews/2025-01-27-15-30-codex-review.md
```

## Comparison vs Built-in Review

| Feature | Codex CLI | Built-in Claude Review |
|---------|-----------|------------------------|
| Model | GPT-4/o3 (OpenAI) | Claude 3.5 Sonnet |
| Speed | Medium | Fast |
| Autonomous Fixes | Yes ✅ | No |
| Cost | $20/month subscription | Included |
| File Editing | Yes ✅ | Via Claude Code |
| LLM Judge Score | Yes ✅ | Manual implementation |

**When to use Codex:**
- Want GPT-4/o3 perspective as second opinion
- Need autonomous code fixing
- Prefer structured scoring (LLM judge)

**When to use built-in:**
- Fast, no-cost reviews
- Integration with Claude's workflow
- Full context awareness

## Best Practices

### Do's
- ✅ Use for second opinions on critical code
- ✅ Leverage autonomous fixing for simple bugs
- ✅ Combine with Claude's review for best coverage
- ✅ Use `--mode suggest` for read-only reviews
- ✅ Save Codex reviews to `.code-reviews/` directory

### Don'ts
- ❌ Don't use `--mode full-auto` on production code without review
- ❌ Don't assume Codex is always right (it's another opinion)
- ❌ Don't skip Claude's review (use both!)
- ❌ Don't commit files Codex modified without verifying

## Troubleshooting

### "Command not found: codex"

Install Codex CLI:
```bash
npm i -g @openai/codex
```

### "Authentication required"

Run once to authenticate:
```bash
codex
# Follow authentication prompts
```

### "Subscription required"

Codex requires ChatGPT Plus ($20/month) or API access.

### Windows Issues

Codex CLI is experimental on Windows. Use WSL:
```bash
wsl
npm i -g @openai/codex
```

## Integration Examples

### Hybrid Review (Claude + Codex)

```bash
# 1. Claude's review first
<Use pre-commit-code-reviewer skill>

# 2. Codex second opinion
<Use codex-integration skill>

# 3. Compare and merge findings
```

### Auto-fix Pipeline

```bash
# 1. Codex identifies issues
codex exec --mode suggest "Review and list all issues in user.py"

# 2. User approves fixes
# 3. Codex auto-fixes
codex exec --mode auto-edit "Fix the issues you identified in user.py"

# 4. Claude verifies fixes
<Re-run pre-commit review>
```

## Limitations

- Requires OpenAI subscription ($20/month minimum)
- CLI experimental on Windows (use WSL)
- Can't access full Claude Code context automatically
- Requires manual output parsing (no structured JSON yet)

## Resources

- [Codex CLI Docs](https://developers.openai.com/codex/cli/)
- [Codex GitHub](https://github.com/openai/codex)
- [OpenAI Codex Quickstart](https://developers.openai.com/codex/quickstart/)

## Notes

**OpenAI Codex (2025) vs Old Codex API:**
- Old Codex API (2021-2023): ❌ Deprecated
- New Codex CLI (2025): ✅ Current, autonomous agent
- GPT-5-Codex: GitHub Copilot integration

This skill uses the **new Codex CLI (2025)**, not the deprecated API.
