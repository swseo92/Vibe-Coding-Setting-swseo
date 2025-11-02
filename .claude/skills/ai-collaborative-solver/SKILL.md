---
name: ai-collaborative-solver
description: This skill should be used when users request technical comparisons ("X vs Y"), architecture decisions, or AI-assisted problem solving. Triggers: "Should I use", "AI debate", or decision requests.
---

# AI Collaborative Solver

**Unified Multi-Model Debate System**

*Registry-Based Model Selection | 3 AI Models | V3.0 Quality Framework*

---

## Overview

Orchestrate multi-model debates across three leading AI engines: **Codex, Claude, and Gemini**. Built on Codex V3.0's proven architecture, automatically select models, run hybrid debates, and maintain consistent quality standards through a unified interface.

**Key Innovation:** Model-agnostic orchestration with registry-based auto-selection to leverage the best AI for each problem type while maintaining Codex V3.0 quality standards.

---

## When to Use This Skill

Use this skill for:

- **Technical Stack Decisions:** Choose between frameworks, databases, architectures, or tools
- **Performance Analysis:** Evaluate scalability, optimization strategies, caching approaches
- **Security Evaluation:** Assess security trade-offs, compliance requirements
- **Multi-Perspective Problems:** Resolve complex decisions requiring diverse AI reasoning

**Common Scenarios:**
- Technology selection (language, framework, database)
- System design and architecture planning
- Migration planning (monolith to microservices, database changes)
- Performance optimization strategies
- Security and compliance decisions

**How to activate:**

When users request AI debate or technical comparisons:

1. **Pre-Clarification Stage (V3.0)**:
   - If problem statement has missing information → Script generates 1-3 clarifying questions
   - If problem statement is complete → Script shows understanding summary and asks for confirmation (y/n/a)
   - User interaction happens automatically through the script

2. **Execute the debate**:
   ```bash
   bash .claude/skills/ai-collaborative-solver/scripts/ai-debate.sh "<problem>" --auto --mode balanced
   ```

   **Important**: Do NOT add `--skip-clarify` flag unless user explicitly requests to skip clarification. The pre-clarification stage improves debate quality by gathering context.

3. **The script will**:
   - Run pre-clarification (question mode or understanding confirmation)
   - Auto-select best AI model based on problem type
   - Execute multi-round debate
   - Generate report in `.debate-reports/`

**Example flow:**
```
User: "Django performance issue (2s → 500ms, 1 week, no DBA)"
→ Script detects complete information
→ Shows understanding confirmation: "My understanding: ..."
→ Asks: "Is this correct? (y/n/a)"
→ User confirms → Starts debate with enriched context
```

---

## Supported AI Models

### Codex (GPT-5-Codex via OpenAI)
- **Best for:** Code review, architecture, implementation details, security analysis
- **Strengths:** Deep code analysis, technical accuracy, debugging, performance optimization
- **Model:** GPT-5-Codex (state-of-the-art agentic coding model)
- **Capabilities:** chat, json, tool, debate, code_execution, thread_continuity
- **Cost:** $20/month (ChatGPT Plus required)
- **Context:** 128k tokens
- **Quality Tier:** Premium

### Claude (Sonnet 4.5 via Claude Code)
- **Best for:** Writing, reasoning, analysis, documentation, explanation
- **Strengths:** Excellent at reasoning, long-form writing, thoughtful analysis, clarity
- **Model:** Claude Sonnet 4.5 (best coding model in the world - Sep 2025)
- **Via:** Claude Code CLI (login-based, no API key needed)
- **Capabilities:** chat, json, tool, debate, long_context
- **Cost:** ~$0.03-0.08 per debate (Claude Pro/Max subscription)
- **Context:** 200k tokens
- **Quality Tier:** Premium

### Gemini (2.5 Pro via Google)
- **Best for:** Current trends, research, latest information (2024-2025)
- **Strengths:** Google Search integration, free tier, massive context, grounding
- **Capabilities:** chat, json, debate, grounding, large_context
- **Cost:** FREE (60 req/min, 1000 req/day)
- **Context:** 1M tokens
- **Quality Tier:** Standard

### Hybrid (Multiple Models)
- **Best for:** Critical decisions, comprehensive analysis, complex problems
- **Strengths:** Multiple perspectives, consensus building, validation
- **Cost:** Combined (choose any combination)
- **Models:** Codex + Claude + Gemini (any combination)

---

## Architecture

```
AI Collaborative Solver (V1.0)
│
├── Unified Orchestrator (ai-debate.sh)
│   ├── Registry Integration (capability-based selection)
│   ├── Model Selection (auto/manual via registry)
│   ├── Mode Configuration (simple/balanced/deep)
│   └── Output Management (reports, metadata, logging)
│
├── Capability Registry (registry.yaml)
│   ├── Model Definitions (costs, capabilities, limits)
│   ├── Selection Rules (pattern-based auto-selection)
│   ├── Cost Presets (minimal/balanced/premium/hybrid)
│   └── Fallback Chains (model availability handling)
│
├── Model Adapters (V3.0 Enhanced)
│   ├── Codex Adapter (OpenAI GPT-4/o3)
│   │   ├── Metadata extraction (confidence, evidence tiers)
│   │   ├── Quality gates integration
│   │   └── V3.0 facilitator preparation
│   │
│   ├── Claude Adapter (Anthropic Claude 3.5 Sonnet)
│   │   ├── API/CLI integration
│   │   ├── Conversation history management
│   │   └── Structured reasoning prompts
│   │
│   ├── Gemini Adapter (Google Gemini 2.5 Pro)
│   │   ├── Multi-agent roles (6 perspectives)
│   │   ├── Google Search grounding
│   │   └── Context window optimization (1M tokens)
│   │
│   └── [Future: Enhanced Facilitator integration]
│
├── Utilities
│   ├── Model Selector V2 (registry-based, 13 rules)
│   └── Hybrid Orchestrator (multi-model synthesis)
│
└── Quality Frameworks (from Codex V3.0)
    ├── Coverage Monitor (8 dimensions)
    ├── Evidence Tiers (T1/T2/T3 markers)
    ├── Anti-Pattern Detection
    └── Quality Gates (prepared for V3.0 integration)
```

---

## Modes

### Simple Mode (3 rounds, ~5-8 min)
**Purpose:** Quick analysis for straightforward problems

**Process:**
1. **Explorer**: Generate 3-5 diverse approaches
2. **Critic**: Reality-check feasibility
3. **Synthesizer**: Recommend solution

**Use when:**
- Time-sensitive decisions
- Binary choices (A vs B)
- Simple architecture decisions

**Example:** "Should we use REST or GraphQL?"

---

### Balanced Mode (4 rounds, ~10-15 min) - Default
**Purpose:** Thorough analysis for most problems

**Process:**
1. **Explorer**: Generate diverse approaches
2. **Critic**: Reality-check feasibility
3. **Synthesizer**: Recommend solution
4. **Security Analyst**: Risk analysis

**Use when:**
- Architecture decisions
- Technology stack selection
- Most general problems

**Example:** "Design authentication system for SaaS"

---

### Deep Mode (6 rounds, ~15-25 min)
**Purpose:** Comprehensive analysis for complex problems

**Process:**
1. **Explorer**: Generate diverse approaches
2. **Critic**: Reality-check feasibility
3. **Synthesizer**: Recommend solution
4. **Security Analyst**: Security & risk analysis
5. **Performance Specialist**: Scalability analysis
6. **Integrator**: Final comprehensive synthesis

**Use when:**
- Complex system architecture
- High-stakes decisions
- Security/performance critical

**Example:** "Design payment processing with PCI compliance"

---

## Usage

### Basic Usage (Auto-Select Model)

```bash
./.claude/skills/ai-collaborative-solver/scripts/ai-debate.sh "Problem description" --auto
```

Automatically selects the best AI model based on problem type.

---

### Specify Model

**Using Codex (Code/Architecture):**
```bash
./ai-debate.sh "Code review needed for auth module" --model codex --mode balanced
```

**Using Claude (Writing/Reasoning):**
```bash
./ai-debate.sh "Write technical documentation for API" --model claude --mode balanced
```

**Using Gemini (Research/Trends):**
```bash
./ai-debate.sh "Latest 2025 React best practices" --model gemini --search
```

---

### Hybrid Mode (Multiple Models)

**Two Models:**
```bash
./ai-debate.sh "Microservices vs Monolith architecture" --models codex,claude --mode balanced
```

**Three Models (Comprehensive):**
```bash
./ai-debate.sh "Critical decision: Database selection" --models codex,claude,gemini --mode deep
```

**Output:** Comparison report with all perspectives, synthesis, and consensus

---

### Through Claude Code

**Activation via Claude Code:**

When activated through a user request like "AI 토론해서 Django vs FastAPI 비교해줘", the skill automatically:

1. Analyzes problem type
2. Auto-selects best model (or prompts for clarification if uncertain)
3. Runs the debate
4. Summarizes results

---

## Auto Model Selection Rules

Automatically choose the best model based on keywords (13 rules in registry):

| Problem Type | Keywords | Selected Model | Reason |
|--------------|----------|----------------|--------|
| **Code Analysis** | 코드, code, 리뷰, review, 버그, bug | **Codex** | Deep technical understanding |
| **Writing/Docs** | write, 작성, document, 문서 | **Claude** | Excellent at writing & explanations |
| **Reasoning** | reason, 추론, analyze, 분석, think | **Claude** | Strong reasoning capabilities |
| **Current Trends** | 2025, 최신, latest, 트렌드, trend | **Gemini** | Google Search for latest info |
| **Research** | 검색, search, 조사, research, find | **Gemini** | Google Search grounding |
| **Architecture** | 아키텍처, architecture, 설계, design | **Codex** | Technical reasoning |
| **Architecture + Trends** | architecture + 2025/latest | **Gemini** | Need current trends |
| **Comparisons** | vs, compare, 비교, 선택 | **Gemini** (general)<br/>**Codex** (technical) | Context-dependent |
| **Security Code** | 보안 + 코드 | **Codex** | Precise code analysis |
| **Security Research** | 보안 + 조사/트렌드 | **Gemini** | Current threat intel |
| **Performance** | 성능, performance, 최적화, optimize | **Codex** | Code expertise |
| **Database** | 데이터베이스, database, SQL, query | **Codex** | Technical precision |
| **Framework + Latest** | framework/library + 2025/latest | **Gemini** | Latest trends |

**Priority:** Rules are evaluated in order. Later rules can override earlier ones.

**Default:** If no rule matches, selects **Codex** (most comprehensive technical capability)

---

## Model Comparison

| Feature | Codex | Claude | Gemini |
|---------|-------|--------|--------|
| **Model** | GPT-5-Codex | Claude Sonnet 4.5 | Gemini 2.5 Pro |
| **Provider** | OpenAI | Anthropic | Google |
| **Cost** | $20/month | ~$0.03-0.08/debate | FREE |
| **Context** | 128k tokens | 200k tokens | 1M tokens |
| **Code Analysis** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Writing** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Reasoning** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Research** | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Current Info (2025)** | ⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Google Search** | ❌ | ❌ | ✅ |
| **Speed** | Medium | Fast | Fast |
| **Quality Framework** | V3.0 (Enhanced) | V3.0 (Enhanced) | V3.0 (Enhanced) |
| **Best Use Case** | Code/Architecture | Writing/Reasoning | Trends/Research |

**Recommendation:** Use `--auto` to enable automatic model selection based on the problem type.

**For detailed model specifications, pricing, and performance benchmarks, see:** [`references/model-comparison.md`](references/model-comparison.md)

---

## Examples

### Example 1: Auto-Select (Code Review)

**Input:**
```bash
./ai-debate.sh "코드 리뷰 필요: 인증 모듈" --auto
```

**What happens:**
1. Keywords detected: "코드 리뷰" → Auto-select **Codex**
2. Mode: balanced (default)
3. Codex analyzes code-level details
4. Report saved to `.debate-reports/`

**For more detailed examples, see:** [`references/examples.md`](references/examples.md)

---

### Example 5: Through Claude Code

**User:** "AI로 토론해서 PostgreSQL vs MongoDB 결정해줘"

**Claude:**
1. Activates AI Collaborative Solver skill
2. Analyzes: Database comparison → **Auto-select Codex**
3. Runs: `./ai-debate.sh "PostgreSQL vs MongoDB" --model codex --mode balanced`
4. Summarizes key findings

**Claude's response:**
```
Codex 토론 결과:

**추천:** PostgreSQL
**신뢰도:** 85%

**주요 근거:**
- 관계형 데이터 구조 (user profiles)
- ACID 보장 필요
- 팀 경험 (PostgreSQL)

**구현 단계:**
1. 스키마 설계 (정규화)
2. 인덱스 최적화
3. Connection pooling

**리스크:**
- 초기 스키마 설계 중요 → 마이그레이션 계획
- 복잡한 쿼리 시 성능 → 인덱스 전략

전체 리포트: .debate-reports/2025-10-31-XX-XX-ai-debate-codex.md
```

---

## Advanced Usage

For advanced features including custom mode configuration, registry customization, and adding new models, see:
- [`references/advanced-usage.md`](references/advanced-usage.md) - Custom modes, CI/CD integration, performance optimization
- [`references/registry-config.md`](references/registry-config.md) - Model registry configuration, adding new models

---

## Output Format

Save reports to `.debate-reports/` with structure:

```markdown
# AI Collaborative Debate Report

**Generated:** 2025-10-31 10:30:00
**Model:** codex (auto-selected)
**Mode:** balanced

## Problem Statement
...

## Round 1: Explorer
...

## Round 2: Critic
...

## Round 3: Synthesizer
...

## Round 4: Security Analyst
...

## Final Summary

1. **Recommended Solution:** [Clear recommendation]
2. **Key Rationale:** [Why this solution]
3. **Implementation Steps:** [3-5 concrete steps]
4. **Risks & Mitigations:** [Top 3 risks]
5. **Confidence Level:** [0-100%]

## Metadata
- Total Duration: 12 minutes
- Model: codex
- Mode: balanced
```

---

## Best Practices

### ✅ Do's

1. **Use Auto-Select for Most Cases**
   ```bash
   ./ai-debate.sh "Problem" --auto
   ```
   Enable automatic model selection

2. **Provide Full Context**
   ```bash
   ./ai-debate.sh "Django vs FastAPI. Team 5, 3 month timeline, REST API" --auto
   ```

3. **Use Hybrid for Critical Decisions**
   ```bash
   ./ai-debate.sh "Problem" --models codex,gemini
   ```

4. **Enable Search for Current Info**
   ```bash
   ./ai-debate.sh "2025 trends" --model gemini --search
   ```

5. **Check Model Selection**
   Review auto-selected model makes sense for problem

---

### ❌ Don'ts

1. **Don't Force Wrong Model**
   - ❌ `--model gemini` for code review
   - ✅ `--auto` or `--model codex`

2. **Don't Skip Context**
   - ❌ "Which database?"
   - ✅ "PostgreSQL vs MongoDB for user data, team 3, relational structure"

3. **Don't Ignore Hybrid Disagreements**
   - If Codex and Gemini disagree, understand why
   - Different perspectives = valuable trade-offs

4. **Don't Trust Blindly**
   - Always validate recommendations
   - Check confidence levels

---

## Troubleshooting

For solutions to common issues (CLI installation, authentication, model selection, performance), see: [`references/troubleshooting.md`](references/troubleshooting.md)

---

## Integration with Codex V3.0

This skill builds on Codex V3.0's architecture:

**Inherited:**
- ✅ Quality modes (simple/balanced/deep)
- ✅ Agent roles (explorer/critic/synthesizer)
- ✅ Facilitator concepts
- ✅ Coverage dimensions
- ✅ Quality gates

**New:**
- 🆕 Model abstraction layer
- 🆕 Auto model selection
- 🆕 Hybrid multi-model debates
- 🆕 Gemini integration
- 🆕 Unified interface

**Backward Compatible:**
- Codex V3.0 workflows still work
- Existing playbooks can be used
- Quality frameworks maintained

---

## Comparison: Old vs New

| Feature | Codex-Only (V3.0) | AI Collaborative |
|---------|-------------------|------------------|
| **Models** | Codex only | Codex + Gemini + more |
| **Selection** | Manual | Auto + manual |
| **Cost** | $20/mo | $0-20/mo (Gemini free) |
| **Use Cases** | Code-focused | All problem types |
| **Interface** | Codex-specific | Model-agnostic |
| **Hybrid** | ❌ | ✅ |

---

## Future Enhancements

**Planned:**
- [ ] Claude adapter (MCP-based)
- [ ] DeepSeek adapter
- [ ] Copilot adapter (GitHub)
- [ ] 3+ model hybrid debates
- [ ] Consensus confidence scoring
- [ ] Automated playbook generation
- [ ] Web UI for debate visualization

---

## Quick Reference

### Choose Model

```bash
# Auto (recommended)
./ai-debate.sh "Problem" --auto

# Codex (code/architecture)
./ai-debate.sh "Problem" --model codex

# Gemini (trends/research)
./ai-debate.sh "Problem" --model gemini --search

# Hybrid (critical decisions)
./ai-debate.sh "Problem" --models codex,gemini
```

### Choose Mode

```bash
# Simple (5-8 min)
--mode simple

# Balanced (10-15 min) - Default
--mode balanced

# Deep (15-25 min)
--mode deep
```

---

## Related Documentation

- **Codex V3.0:** `.claude/skills/codex-collaborative-solver/SKILL.md`
- **Gemini Solver:** `.claude/skills/gemini-collaborative-solver/SKILL.md`
- **OpenAI Codex Guide:** `docs/openai-codex-guide.md`
- **Gemini Solver Guide:** `docs/gemini-solver-guide.md`

---

**Version:** 1.0.0
**Status:** Stable
**Created:** 2025-10-31
**Based On:** Codex V3.0 + Gemini Solver 1.0
**Models:** Codex (GPT-4/o3) + Gemini 2.5 Pro
