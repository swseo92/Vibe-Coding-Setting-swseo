# OpenAI Codex Integration Guide

**Complete guide to using OpenAI Codex CLI for LLM-as-Judge code reviews in Claude Code**

Last Updated: 2025-01-27

---

## 📋 Table of Contents

1. [What is OpenAI Codex?](#what-is-openai-codex)
2. [Setup Guide](#setup-guide)
3. [Usage Examples](#usage-examples)
4. [Cost Information](#cost-information)
5. [Best Practices](#best-practices)
6. [Troubleshooting](#troubleshooting)

---

## What is OpenAI Codex?

### History

**Original Codex API (2021-2023)** ❌ DEPRECATED
- Code-specialized GPT model
- GitHub Copilot's original engine
- Shut down March 23, 2023

**New Codex CLI (2025)** ✅ CURRENT
- Autonomous coding agent
- Built on o3/GPT-4 architecture
- CLI tool + API access
- Released May 2025

**GPT-5-Codex** 🆕
- Code review specialized model
- Integrated into GitHub Copilot
- Deep codebase analysis + test execution

### Why Use Codex for Code Review?

**Benefits:**
- ✅ Get **OpenAI's perspective** as second opinion
- ✅ **Structured scoring** (0-100) for LLM-as-Judge
- ✅ **Autonomous fixing** capabilities
- ✅ **Alternative model** to avoid single-LLM bias
- ✅ **GitHub integration** (via GPT-5-Codex)

**Considerations:**
- ❌ Requires **$20/month** subscription (ChatGPT Plus)
- ❌ Separate from Claude Code (external process)
- ❌ Additional complexity in workflow

---

## Setup Guide

### Step 1: Install Codex CLI

```bash
# npm (cross-platform)
npm i -g @openai/codex

# Homebrew (macOS only)
brew install --cask codex

# Verify installation
codex --version
```

### Step 2: Authenticate

```bash
# Run once to authenticate
codex

# Sign in with ChatGPT Plus/Pro account
# (Requires active subscription)
```

### Step 3: Enable Skill in Claude Code

The skill is already available at:
```
.claude/skills/codex-integration/
```

**Usage:**
```
"codex로 코드 리뷰해줘"
"use codex to review"
"codex fix this bug"
```

### Platform Support

- ✅ **macOS**: Full support
- ✅ **Linux**: Full support
- ⚠️  **Windows**: Experimental (use WSL recommended)

---

## Usage Examples

### Example 1: Basic Code Review

**User request:**
```
codex로 커밋 전 코드 리뷰해줘
```

**What happens:**
1. Claude gets staged diff: `git diff --staged`
2. Calls Codex CLI: `codex exec "Review this diff..."`
3. Parses Codex response
4. Saves to `.code-reviews/YYYY-MM-DD-HH-MM-codex-review.md`
5. Shows summary

**Output:**
```
📋 Codex Review Complete!

Overall Score: 72/100

🚨 Critical Issues: 1
⚠️  Warnings: 3
💡 Suggestions: 5

Top Issues:
1. [CRITICAL] SQL injection in user.py:45
2. [WARNING] Missing error handling in api.py:120
3. [WARNING] Complex function needs splitting (auth.py:50-95)

🔴 Recommendation: NEEDS_WORK

📄 Full review: .code-reviews/2025-01-27-15-30-codex-review.md
```

---

### Example 2: Korean Language Review

**User request:**
```
한글로 코드 리뷰 받고 싶어
```

**What happens:**
1. Claude uses Korean prompt templates
   - `system-prompt-ko.md` - Review guidelines
   - `report-template-ko.md` - Output format
2. Calls Codex CLI with Korean instructions
3. Gets comprehensive Korean report

**Command:**
```bash
codex exec "system-prompt-ko.md를 따라서 리뷰해줘. 한글로 작성."
```

**Output:**
```markdown
# 코드 리뷰 보고서

## 기본 정보
전체 점수: 35/100
치명적 이슈: 1개
경고: 1개

## 치명적 이슈
### 1. [server.py:92] JSON 모드 미지원 모델 사용
**심각도** ❌ 치명적
**분류** 버그

**문제:** gpt-4-turbo-preview 모델은 JSON 모드를 지원하지 않습니다...
**수정 방법:**
```python
model: str = "gpt-4-1106-preview"  # JSON 지원 모델
```
```

---

### Example 3: Auto-fix with Codex

**User request:**
```
codex한테 SQL injection 자동으로 고쳐달라고 해줘
```

**What happens:**

```bash
# Claude calls Codex in auto-edit mode
codex exec --mode auto-edit "Fix SQL injection vulnerability in user.py line 45. Use parameterized queries."

# Codex autonomously edits file:
# BEFORE:
def get_user(id):
    return db.query(f"SELECT * FROM users WHERE id = {id}")

# AFTER:
def get_user(id: int) -> Optional[User]:
    """Get user by ID from database.

    Args:
        id: User ID

    Returns:
        User object if found, None otherwise
    """
    return db.query("SELECT * FROM users WHERE id = ?", [id])

# Claude verifies changes
✅ Codex fixed SQL injection
✅ Added type hints (bonus)
✅ Added docstring (bonus)

Please review the changes before committing.
```

---

### Example 4: Dual Review (Claude + Codex)

**User request:**
```
Claude와 Codex 둘 다로 리뷰해줘
```

**Workflow:**

```bash
# 1. Claude's built-in review
<Uses pre-commit-code-reviewer skill>
→ Score: 78/100, 2 warnings, 4 suggestions

# 2. Codex CLI review
<Uses codex-integration skill>
→ Score: 72/100, 1 critical, 3 warnings

# 3. Merge results
- Critical: SQL injection (both agree)
- Warning: Type hints (both agree)
- Warning: Complex function (both agree)

# 4. Final report
📊 Consensus Review (2 LLMs)

Average Score: 75/100

🚨 CRITICAL (both agree):
- SQL injection vulnerability (user.py:45)

⚠️  WARNINGS (both agree):
- Missing type hints (user.py:1-20)
- Complex function should be split (user.py:50-95)

💡 SUGGESTIONS:
- Add docstrings
- Extract constants
- Improve error messages

🔴 Final Recommendation: NEEDS_WORK
Fix SQL injection before commit.
```

---

## Cost Information

### Codex CLI Pricing

| Plan | Cost | Limits |
|------|------|--------|
| ChatGPT Plus | $20/month | Fair use policy |
| ChatGPT Pro | $200/month | Higher limits |
| ChatGPT Team | $30/user/month | Team features |

**Typical review cost:** Included in subscription (unlimited reviews)

### Is It Worth It?

**✅ Good value if:**
- You already have ChatGPT Plus
- You do frequent code reviews (>10/month)
- You want autonomous code editing
- You value OpenAI's perspective

**❌ May not be worth if:**
- You only review occasionally
- Claude's review is sufficient
- Budget is tight

**Alternative:** Use Claude Code's built-in review (free, no subscription)

---

## Best Practices

### Do's ✅

1. **Use as Second Opinion**
   - Don't replace Claude's review
   - Use Codex for critical code
   - Compare both perspectives

2. **Verify Auto-fixes**
   - Never commit Codex edits blindly
   - Review all changes
   - Run tests after auto-fix

3. **Save Review Reports**
   - Keep `.code-reviews/` in git
   - Track quality trends over time
   - Learn from past issues

4. **Structured Prompts**
   - Request specific format
   - Ask for scores (0-100)
   - Categorize issues (critical/warning/suggestion)

5. **Use Korean Templates**
   - `system-prompt-ko.md` for guidelines
   - `report-template-ko.md` for format
   - Consistent, professional Korean output

### Don'ts ❌

1. **Don't Trust Blindly**
   - LLMs make mistakes
   - Verify suggestions
   - Use critical thinking

2. **Don't Use Full-Auto in Production**
   - `--mode full-auto` is risky
   - Always review changes
   - Test before commit

3. **Don't Skip Tests**
   - LLM reviews ≠ testing
   - Run actual tests
   - Verify functionality

4. **Don't Overload Context**
   - Keep diffs focused
   - Review file-by-file for large changes
   - Break down huge PRs

---

## Workflow Recommendations

### For Solo Developers

```
1. Write code
2. git add files
3. Claude review (fast, built-in)
4. If critical code → Codex CLI review (second opinion)
5. Fix issues
6. git commit
```

**Tools:** Codex CLI (part of ChatGPT Plus)

---

### For Teams

```
1. Developer writes code
2. git add files
3. Pre-commit hook → Automated review
   - Claude review (built-in)
   - Codex CLI review (if available)
4. Consensus score < 70 → Block commit
5. Developer fixes issues
6. Re-review until passing
7. git commit
8. Create PR
9. Human review (final approval)
```

**Tools:** Claude + Codex for comprehensive coverage

---

## Troubleshooting

### Common Issues

**Error: "command not found: codex"**

```bash
# Install Codex CLI
npm i -g @openai/codex

# Verify
codex --version
```

**Error: "Authentication required"**

```bash
# Run once to authenticate
codex

# Sign in with ChatGPT account
# Requires active Plus/Pro subscription
```

**Error: "Subscription required"**

- Codex CLI needs ChatGPT Plus ($20/month)
- Verify your subscription is active
- Check https://chatgpt.com/settings

**Windows: "Codex not working"**

```bash
# Use WSL (recommended)
wsl
npm i -g @openai/codex
```

**Korean output not working**

Make sure to explicitly request Korean:
```bash
codex exec "...한글로 작성."
# Or use Korean prompt templates
codex exec "system-prompt-ko.md를 따라서..."
```

---

## Comparison: Claude vs Codex

| Feature | Claude Built-in | Codex CLI |
|---------|----------------|-----------|
| **Model** | Claude 3.5 Sonnet | GPT-4/o3 |
| **Cost** | Included | $20/month |
| **Setup** | None | `npm install` |
| **Speed** | Fast | Medium |
| **Auto-fix** | Via Claude | Native ✅ |
| **Context Awareness** | Full ✅ | Limited |
| **LLM-as-Judge Score** | Manual | Yes ✅ |
| **Korean Support** | Native | Via templates |

**Recommendation:**
- **Start with:** Claude built-in (free, integrated)
- **Add:** Codex CLI (if you have ChatGPT Plus)
- **Use both:** For critical code requiring multiple perspectives

---

## Resources

### Official Documentation

- [OpenAI Codex CLI](https://developers.openai.com/codex/cli/)
- [Codex GitHub](https://github.com/openai/codex)
- [ChatGPT Plus](https://openai.com/chatgpt/pricing)

### Related Files

- Codex CLI Skill: `.claude/skills/codex-integration/`
- Korean Prompts: `.claude/skills/pre-commit-code-reviewer/prompts/`
  - `system-prompt-ko.md` - Review guidelines
  - `report-template-ko.md` - Output format
  - `README.md` - Usage guide

### Community

- [OpenAI Developer Forum](https://community.openai.com/)
- [Hacker News: Codex](https://news.ycombinator.com/item?id=35242069)

---

## FAQ

**Q: Is the old Codex API still available?**
A: No, deprecated in March 2023. Use new Codex CLI (2025) instead.

**Q: Do I need ChatGPT Plus for Codex CLI?**
A: Yes, $20/month minimum. No alternative for Codex CLI.

**Q: Can Codex replace human code review?**
A: No! Use as assistant, not replacement. Always verify suggestions.

**Q: Which is better: Claude or Codex?**
A: Different perspectives! Use both for comprehensive review.

**Q: Is Codex better than GitHub Copilot?**
A: Different tools. Copilot = autocomplete, Codex = autonomous agent.

**Q: Can I use Codex offline?**
A: No, requires internet connection to OpenAI servers.

**Q: Is my code sent to OpenAI?**
A: Yes. Review [OpenAI Privacy Policy](https://openai.com/policies/privacy-policy).

**Q: How do I get Korean reviews?**
A: Use Korean prompt templates in `.claude/skills/pre-commit-code-reviewer/prompts/`

---

**Last Updated:** 2025-01-27
**Maintained by:** swseo
**Repository:** [Vibe-Coding-Setting-swseo](https://github.com/swseo92/Vibe-Coding-Setting-swseo)
