# OpenAI Codex Integration Guide

**Complete guide to using OpenAI Codex for LLM-as-Judge code reviews in Claude Code**

Last Updated: 2025-01-27

---

## 📋 Table of Contents

1. [What is OpenAI Codex?](#what-is-openai-codex)
2. [Integration Options](#integration-options)
3. [Setup Guide](#setup-guide)
4. [Usage Examples](#usage-examples)
5. [Cost Comparison](#cost-comparison)
6. [Best Practices](#best-practices)

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

## Integration Options

We provide **3 methods** to integrate OpenAI Codex:

### Option 1: Codex CLI Integration ⭐ **Recommended**

**What:** Call OpenAI's official Codex CLI from Claude Code

**Pros:**
- ✅ Official OpenAI tool
- ✅ Simplest setup (just install CLI)
- ✅ Autonomous code editing
- ✅ No API key management (uses ChatGPT login)

**Cons:**
- ❌ Requires ChatGPT Plus subscription ($20/month)
- ❌ CLI only (no programmatic API)
- ❌ Output parsing required

**Best for:** Users who want official Codex with minimal setup

**File:** `.claude/skills/codex-integration/`

---

### Option 2: OpenAI API MCP Server

**What:** Custom MCP server calling OpenAI API directly

**Pros:**
- ✅ Programmatic control
- ✅ Structured JSON responses
- ✅ Multiple tools (review, compare, suggest)
- ✅ Choice of models (GPT-4, GPT-3.5, o1)
- ✅ Pay-per-use (cheaper for occasional use)

**Cons:**
- ❌ Requires OpenAI API key
- ❌ More setup (MCP server + dependencies)
- ❌ No autonomous editing (analysis only)

**Best for:** Developers who want fine-grained control and structured output

**File:** `mcp-servers/openai-judge/`

---

### Option 3: Hybrid Approach 🎯 **Best of Both Worlds**

**What:** Use both Codex CLI (for fixing) + MCP server (for analysis)

**Workflow:**
1. MCP server analyzes code → structured review
2. Codex CLI fixes issues → autonomous edits
3. Claude verifies → final approval

**Best for:** Production teams wanting comprehensive review

---

## Setup Guide

### Option 1: Codex CLI Integration

#### Step 1: Install Codex CLI

```bash
# npm (cross-platform)
npm i -g @openai/codex

# Homebrew (macOS only)
brew install --cask codex

# Verify installation
codex --version
```

#### Step 2: Authenticate

```bash
# Run once to authenticate
codex

# Sign in with ChatGPT Plus/Pro account
# (Requires active subscription)
```

#### Step 3: Enable Skill in Claude Code

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

#### Platform Support

- ✅ **macOS**: Full support
- ✅ **Linux**: Full support
- ⚠️  **Windows**: Experimental (use WSL recommended)

---

### Option 2: OpenAI API MCP Server

#### Step 1: Get OpenAI API Key

1. Go to https://platform.openai.com/api-keys
2. Create new API key
3. Copy key (starts with `sk-...`)

#### Step 2: Setup MCP Server

```bash
cd mcp-servers/openai-judge

# Install dependencies
uv sync

# Configure API key
cp .env.example .env
# Edit .env and paste your API key:
# OPENAI_API_KEY=sk-...
```

#### Step 3: Add to MCP Configuration

Edit your project's `.mcp.json`:

```json
{
  "mcpServers": {
    "openai-judge": {
      "command": "uv",
      "args": [
        "--directory",
        "C:\\absolute\\path\\to\\mcp-servers\\openai-judge",
        "run",
        "server.py"
      ]
    }
  }
}
```

**Replace path:**
- Windows: `C:\\Users\\...\\mcp-servers\\openai-judge`
- macOS/Linux: `/Users/.../mcp-servers/openai-judge`

#### Step 4: Restart Claude Code

```bash
# Exit Claude Code and restart
exit
claude
```

#### Step 5: Verify MCP Server

In Claude Code, you should now have access to:
- `mcp__openai-judge__review_code`
- `mcp__openai-judge__compare_code_versions`
- `mcp__openai-judge__suggest_improvements`

---

## Usage Examples

### Example 1: CLI Code Review (Codex CLI)

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

### Example 2: MCP Structured Review (API Server)

**User request:**
```
OpenAI API로 이 코드 리뷰해줘
```

**What happens:**
1. Claude reads staged diff
2. Calls MCP tool: `review_code(code=diff, model="gpt-4-turbo-preview")`
3. Gets structured JSON response
4. Formats and displays

**MCP Call:**
```python
mcp__openai-judge__review_code(
    code="""
    def get_user(id):
        return db.query(f"SELECT * FROM users WHERE id = {id}")
    """,
    context="File: user_service.py - Get user by ID",
    model="gpt-4-turbo-preview",
    review_aspects="bugs,security,performance,readability,best-practices"
)
```

**Response:**
```json
{
  "overall_score": 35,
  "severity_counts": {
    "critical": 1,
    "warning": 2,
    "suggestion": 3
  },
  "issues": [
    {
      "severity": "critical",
      "aspect": "security",
      "line": 2,
      "description": "SQL injection vulnerability - user input directly interpolated into query",
      "suggestion": "Use parameterized queries: db.query('SELECT * FROM users WHERE id = ?', [id])"
    },
    {
      "severity": "warning",
      "aspect": "best-practices",
      "line": 1,
      "description": "Missing type hints for parameters and return value",
      "suggestion": "Add type hints: def get_user(id: int) -> Optional[User]:"
    }
  ],
  "recommendation": "needs_work",
  "summary": "Critical security vulnerability must be fixed before commit. Code also lacks type safety."
}
```

---

### Example 3: Hybrid Review (Claude + Codex + OpenAI API)

**User request:**
```
모든 방법으로 종합 리뷰해줘
```

**Workflow:**

```bash
# 1. Claude's built-in review
<Uses pre-commit-code-reviewer skill>
→ Score: 78/100, 2 warnings, 4 suggestions

# 2. Codex CLI review
<Uses codex-integration skill>
→ Score: 72/100, 1 critical, 3 warnings

# 3. OpenAI API review
<Uses openai-judge MCP server>
→ Score: 75/100, 1 critical, 2 warnings

# 4. Merge results
- Critical: SQL injection (Codex + OpenAI)
- Warning: Type hints (all 3 agree)
- Warning: Complex function (Claude + Codex)

# 5. Final report
📊 Consensus Review (3 LLMs)

Average Score: 75/100

🚨 CRITICAL (2/3 agree):
- SQL injection vulnerability (user.py:45)

⚠️  WARNINGS (all agree):
- Missing type hints (user.py:1-20)

⚠️  WARNINGS (2/3 agree):
- Complex function should be split (user.py:50-95)

💡 SUGGESTIONS:
- Add docstrings
- Extract constants
- Improve error messages

🔴 Final Recommendation: NEEDS_WORK
Fix SQL injection before commit.
```

---

### Example 4: Auto-fix with Codex

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

## Cost Comparison

### Codex CLI (Option 1)

| Plan | Cost | Limits |
|------|------|--------|
| ChatGPT Plus | $20/month | Fair use policy |
| ChatGPT Pro | $200/month | Higher limits |
| ChatGPT Team | $30/user/month | Team features |
| API (pay-per-use) | $1.50/1M tokens | No subscription |

**Typical review cost:** Included in subscription (unlimited reviews)

---

### OpenAI API (Option 2)

| Model | Input | Output | Per Review Cost |
|-------|-------|--------|-----------------|
| GPT-4 Turbo | $0.01/1K | $0.03/1K | ~$0.01-0.05 |
| GPT-3.5 Turbo | $0.001/1K | $0.002/1K | ~$0.001-0.005 |
| o1-preview | $0.015/1K | $0.06/1K | ~$0.05-0.20 |

**Estimated reviews per dollar:**
- GPT-4 Turbo: ~20-100 reviews/$1
- GPT-3.5 Turbo: ~200-1000 reviews/$1

---

### Which to Choose?

**Use Codex CLI if:**
- ✅ You already have ChatGPT Plus
- ✅ You want unlimited reviews
- ✅ You need autonomous code editing
- ✅ You prefer simple setup

**Use OpenAI API if:**
- ✅ You only review occasionally (<100/month)
- ✅ You want programmatic control
- ✅ You need structured JSON output
- ✅ You want to choose specific models

**Use Both if:**
- ✅ You want best of both worlds
- ✅ Budget allows
- ✅ Production code requires multiple opinions

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

3. **Choose Right Model**
   - GPT-3.5: Quick, cheap reviews
   - GPT-4: Comprehensive reviews
   - o1: Complex architectural analysis

4. **Save Review Reports**
   - Keep `.code-reviews/` in git
   - Track quality trends over time
   - Learn from past issues

5. **Structured Prompts**
   - Request specific format
   - Ask for scores (0-100)
   - Categorize issues (critical/warning/suggestion)

### Don'ts ❌

1. **Don't Trust Blindly**
   - LLMs make mistakes
   - Verify suggestions
   - Use critical thinking

2. **Don't Use Full-Auto in Production**
   - `--mode full-auto` is risky
   - Always review changes
   - Test before commit

3. **Don't Ignore Costs**
   - Monitor API usage
   - Set billing alerts
   - Use GPT-3.5 for simple reviews

4. **Don't Skip Tests**
   - LLM reviews ≠ testing
   - Run actual tests
   - Verify functionality

5. **Don't Overload Context**
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

**Tools:** Codex CLI only (part of ChatGPT Plus you already have)

---

### For Teams

```
1. Developer writes code
2. git add files
3. Pre-commit hook → Automated review
   - Claude review (built-in)
   - OpenAI API review (MCP server)
   - Codex CLI review (if available)
4. Consensus score < 70 → Block commit
5. Developer fixes issues
6. Re-review until passing
7. git commit
8. Create PR
9. Human review (final approval)
```

**Tools:** All 3 methods for comprehensive coverage

---

### For Open Source

```
1. Contributor submits PR
2. CI/CD runs automated reviews
   - OpenAI API (pay-per-use, cost-effective)
   - Claude review
3. Generate review report in PR comments
4. Contributor addresses feedback
5. Maintainer final review
6. Merge
```

**Tools:** OpenAI API (no subscription needed, pay only for PR reviews)

---

## Troubleshooting

### Codex CLI Issues

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
- Or use OpenAI API instead (pay-per-use)

**Windows: "Codex not working"**

```bash
# Use WSL (recommended)
wsl
npm i -g @openai/codex
```

---

### MCP Server Issues

**Error: "OpenAI API key not found"**

```bash
cd mcp-servers/openai-judge

# Create .env file
cp .env.example .env

# Edit .env and add key
# OPENAI_API_KEY=sk-...
```

**Error: "MCP server not loading"**

1. Check `.mcp.json` has absolute path
2. Verify `uv sync` completed
3. Restart Claude Code
4. Check server logs

**Error: "Invalid model"**

Use valid model names:
- `gpt-4-turbo-preview`
- `gpt-3.5-turbo`
- `o1-preview`

---

## Comparison Table

| Feature | Claude Built-in | Codex CLI | OpenAI API MCP |
|---------|----------------|-----------|----------------|
| **Model** | Claude 3.5 Sonnet | GPT-4/o3 | GPT-4/3.5/o1 |
| **Cost** | Included | $20/month | Pay-per-use |
| **Setup** | None | `npm install` | MCP server setup |
| **Speed** | Fast | Medium | Medium |
| **Structured Output** | Manual | Manual | JSON ✅ |
| **Auto-fix** | Via Claude | Yes ✅ | No |
| **Context Awareness** | Full ✅ | Limited | Limited |
| **LLM-as-Judge Score** | No | Yes ✅ | Yes ✅ |
| **Offline** | No | No | No |

**Recommendation:**
- **Start with:** Claude built-in (free, integrated)
- **Add:** Codex CLI (if you have ChatGPT Plus)
- **Advanced:** OpenAI API MCP (for production teams)

---

## Resources

### Official Documentation

- [OpenAI Codex CLI](https://developers.openai.com/codex/cli/)
- [Codex GitHub](https://github.com/openai/codex)
- [OpenAI API Docs](https://platform.openai.com/docs/api-reference)
- [MCP Documentation](https://modelcontextprotocol.io/)

### Related Files

- Codex CLI Skill: `.claude/skills/codex-integration/`
- OpenAI MCP Server: `mcp-servers/openai-judge/`
- MCP Config Example: `templates/common/.mcp.json.codex-example`

### Community

- [OpenAI Developer Forum](https://community.openai.com/)
- [Hacker News: Codex](https://news.ycombinator.com/item?id=35242069)

---

## FAQ

**Q: Is the old Codex API still available?**
A: No, deprecated in March 2023. Use new Codex CLI (2025) or GPT-4 API.

**Q: Do I need ChatGPT Plus for Codex CLI?**
A: Yes, $20/month minimum. Or use OpenAI API pay-per-use instead.

**Q: Can Codex replace human code review?**
A: No! Use as assistant, not replacement. Always verify suggestions.

**Q: Which is better: Claude or Codex?**
A: Different perspectives! Use both for comprehensive review.

**Q: Is Codex better than GitHub Copilot?**
A: Different tools. Copilot = autocomplete, Codex = autonomous agent.

**Q: How to use Codex without ChatGPT Plus?**
A: Use OpenAI API MCP server (pay-per-use, no subscription).

**Q: Can I use Codex offline?**
A: No, requires internet connection to OpenAI servers.

**Q: Is my code sent to OpenAI?**
A: Yes. Review [OpenAI Privacy Policy](https://openai.com/policies/privacy-policy).

---

**Last Updated:** 2025-01-27
**Maintained by:** swseo
**Repository:** [Vibe-Coding-Setting-swseo](https://github.com/swseo92/Vibe-Coding-Setting-swseo)
