# AI Collaborative Solver - Troubleshooting Guide

This document contains solutions to common issues when using the AI Collaborative Solver skill.

---

## Issue: "codex CLI not found"

**Solution:**
```bash
npm install -g @openai/codex
codex  # Authenticate (requires ChatGPT Plus)
```

---

## Issue: "gemini-cli not found"

**Solution:**
```bash
npm install -g @google/gemini-cli
gemini-cli  # Authenticate (free Google account)
```

---

## Issue: "Claude Code CLI not found"

**Solution:**

Install and authenticate Claude Code:

```bash
# 1. Install Claude Code
# Download from: https://claude.ai/download

# 2. Run claude to authenticate
claude

# 3. Login with your Claude account
# Follow the authentication prompts

# 4. Verify authentication
claude --version
```

**Requirements:**
- Claude account (free)
- Claude Pro/Max subscription (recommended for unlimited usage)

---

## Issue: Auto-select chose wrong model

**Solution:**
```bash
# Override with specific model
./ai-debate.sh "Problem" --model codex
# OR add keywords to problem description
./ai-debate.sh "코드 리뷰: Problem" --auto  # Will select Codex
```

---

## Issue: Hybrid mode too slow

**Solution:**
```bash
# Use simple mode (faster)
./ai-debate.sh "Problem" --models codex,gemini --mode simple

# Or run models sequentially
./ai-debate.sh "Problem" --model codex
./ai-debate.sh "Problem" --model gemini
# Compare manually
```

---

**Back to:** [Main Documentation](../SKILL.md)
