# AI Collaborative Solver

**Unified Multi-Model Debate System**

One interface, multiple AI models (Codex + Gemini + more)

---

## Quick Start

```bash
# Auto-select best model
./.claude/skills/ai-collaborative-solver/scripts/ai-debate.sh "Your problem" --auto

# Use Codex (code-focused)
./ai-debate.sh "Code review needed" --model codex

# Use Gemini (trends/research)
./ai-debate.sh "2025 React trends" --model gemini --search

# Hybrid (compare multiple models)
./ai-debate.sh "Architecture decision" --models codex,gemini
```

---

## What's New?

### Phase 3: Advanced Debate Quality (2025-11-01)
- **🤔 Mid-debate User Input**: AI detects uncertainty and asks for clarification
- **💡 Devil's Advocate**: Automatic critical challenges when consensus is too easy
- **⚠️ Anti-pattern Detection**: 4 automated quality checks
  - Information Starvation (excessive assumptions)
  - Rapid Turn (shallow exploration)
  - Policy Trigger (ethical/legal issues)
  - Premature Convergence (quick agreement without alternatives)

### Unified Interface
- One command for all AI models
- Auto-select best model for problem
- Consistent output format

### Multiple Models
- **Codex** (GPT-5-Codex): Code analysis, architecture
- **Claude** (Sonnet 4.5): Writing, reasoning, documentation
- **Gemini** (2.5 Pro): Latest trends, Google Search
- **Hybrid**: Run multiple models, compare results

### Intelligent Selection
- Keywords → Auto-select best model
- "코드 리뷰" → Codex
- "2025 트렌드" → Gemini
- "비교" → Hybrid

---

## Features

### Core Features
| Feature | Description |
|---------|-------------|
| **Auto Model Selection** | Keywords → Best model |
| **3 Quality Modes** | simple (5min), balanced (10min), deep (15min) |
| **Hybrid Debates** | Multiple models in parallel |
| **Free Option** | Gemini = FREE (1000 req/day) |
| **Codex V3.0 Quality** | Proven framework from V3.0 |

### Phase 3: Advanced Debate Quality (NEW)
| Feature | Description | Status |
|---------|-------------|--------|
| **Mid-debate User Input** 🤔 | Interactive clarification when AI detects uncertainty | ✅ Implemented |
| **Devil's Advocate** 💡 | Automatic critical challenges when agreement dominates | ✅ Implemented |
| **Anti-pattern Detection** ⚠️ | Detects 4 debate quality issues automatically | ✅ Implemented |
| **Information Starvation** | Flags excessive assumptions/hedging (≥5 hedging words) | ✅ Implemented |
| **Rapid Turn Detection** | Identifies shallow exploration (<50 words) | ✅ Implemented |
| **Policy Trigger** | Escalates ethical/legal considerations to user | ✅ Implemented |
| **Premature Convergence** | Warns when agreement happens too quickly (>70% in ≤2 rounds) | ✅ Implemented |

---

## Directory Structure

```
ai-collaborative-solver/
├── SKILL.md              # Full documentation
├── README.md             # This file
│
├── scripts/
│   ├── ai-debate.sh      # 🌟 Main orchestrator
│   └── utils/
│       ├── model-selector.sh      # Auto-selection
│       └── hybrid-orchestrator.sh # Multi-model
│
├── models/               # Model adapters
│   ├── codex/adapter.sh
│   └── gemini/adapter.sh
│
└── modes/                # Quality modes
    ├── simple.yaml
    ├── balanced.yaml
    └── deep.yaml
```

---

## Usage Examples

### Auto-Select (Recommended)

```bash
./ai-debate.sh "Django vs FastAPI for REST API" --auto
# → Auto-selects Codex (architecture decision)

./ai-debate.sh "Latest 2025 Next.js practices" --auto
# → Auto-selects Gemini (current trends)
```

### Specify Model

```bash
# Codex: Code/architecture
./ai-debate.sh "Review auth module code" --model codex --mode balanced

# Gemini: Trends/research
./ai-debate.sh "2025 serverless trends" --model gemini --search --mode simple
```

### Hybrid: Multiple Models

```bash
./ai-debate.sh "Microservices vs Monolith" --models codex,gemini --mode balanced
```

**Output:** Comparison report with both Codex and Gemini perspectives

---

## Through Claude Code

```
User: "AI 토론해서 PostgreSQL vs MongoDB 결정해줘"
→ Claude activates this skill automatically
```

---

## Model Comparison

| | Codex | Claude | Gemini |
|-|-------|--------|--------|
| **Model** | GPT-5-Codex | Sonnet 4.5 | 2.5 Pro |
| **Cost** | $20/mo | ~$0.05/debate | FREE |
| **Best For** | Code, architecture | Writing, reasoning | Trends, research |
| **Google Search** | ❌ | ❌ | ✅ |
| **Context** | 128k | 200k | 1M |
| **Quality** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |

---

## Installation

### Prerequisites

**For Codex:**
```bash
npm install -g @openai/codex
codex  # Authenticate (requires ChatGPT Plus $20/mo)
```

**For Claude:**
```bash
# Install Claude Code from: https://claude.ai/download
# Run claude to authenticate
claude
# Login with your Claude account (free)
# Recommended: Claude Pro/Max subscription
```

**For Gemini:**
```bash
npm install -g @google/gemini-cli
gemini-cli  # Authenticate (FREE Google account)
```

---

## Documentation

- **SKILL.md**: Complete documentation
- **examples/**: Usage examples
- **modes/**: Mode configurations

---

## FAQ

**Q: Which model should I use?**
A: Use `--auto` and let the system decide!

**Q: Is Gemini really free?**
A: Yes! 60 req/min, 1000 req/day with Google account.

**Q: Can I use both models?**
A: Yes! Use `--models codex,gemini` for hybrid mode.

**Q: What if auto-select chooses wrong model?**
A: Override with `--model codex` or `--model gemini`

---

**Version:** 2.0.0 (Phase 3 완료)
**Status:** Stable
**Created:** 2025-10-31
**Last Updated:** 2025-11-01
