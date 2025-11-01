# AI Collaborative Solver

**Unified Multi-Model Debate System**

*Registry-Based Model Selection | 3 AI Models | V3.0 Quality Framework*

---

## Overview

AI Collaborative Solver is a unified framework that enables debate and collaboration across three leading AI models: **Codex, Claude, and Gemini**. Built on Codex V3.0's proven architecture, it provides intelligent auto-selection, hybrid multi-model debates, and consistent quality standards through a single interface.

**Key Innovation:** Model-agnostic orchestration with registry-based auto-selection, allowing you to leverage the best AI for each specific problem type while maintaining quality standards from Codex V3.0.

---

## When to Use This Skill

**Automatically activate when users request:**
- Technical comparisons: "X vs Y 어떤 걸 써야할까?" / "Should I use X or Y?"
- Architecture decisions: "Django vs FastAPI", "PostgreSQL vs MongoDB"
- Technology selection: "어느 프레임워크를 선택할까?" / "Which framework should I choose?"
- "AI 토론해서 해결해줘" / "AI debate to solve this"
- "Codex로 분석해줘" / "analyze with Codex"
- "Claude로 작성해줘" / "write with Claude"
- "Gemini로 조사해줘" / "research with Gemini"
- "여러 AI로 비교해줘" / "compare with multiple AIs"
- Complex problems requiring multi-perspective analysis
- Performance/scalability analysis
- Security evaluation

**How to activate:**
You MUST use the Bash tool to execute `.claude/skills/ai-collaborative-solver/scripts/ai-debate.sh` directly.

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

The system automatically selects the best AI model based on problem type.

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

Just ask Claude:

```
User: "AI 토론해서 Django vs FastAPI 비교해줘"
Claude: (Automatically activates this skill)
```

Claude will:
1. Analyze problem type
2. Auto-select best model (or ask if uncertain)
3. Run debate
4. Summarize results

---

## Auto Model Selection Rules

The system automatically chooses the best model based on keywords (13 rules in registry):

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

**Recommendation:** Use `--auto` and let the system choose based on your problem type!

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

---

### Example 2: Specify Gemini (Latest Trends)

**Input:**
```bash
./ai-debate.sh "2025년 Next.js 최신 베스트 프랙티스" --model gemini --search
```

**What happens:**
1. Gemini selected (specified)
2. Google Search enabled (--search)
3. Finds latest Next.js 15 documentation
4. Cites sources in report

---

### Example 3: Claude for Writing

**Input:**
```bash
./ai-debate.sh "Write API documentation for payment endpoint" --model claude --mode balanced
```

**What happens:**
1. Keywords detected: "write" + "documentation" → Claude
2. Claude excels at clear, structured writing
3. Produces well-organized documentation
4. Multiple refinement rounds improve clarity

---

### Example 4: Hybrid (Critical Decision)

**Input:**
```bash
./ai-debate.sh "Microservices vs Monolith for e-commerce" --models codex,claude,gemini --mode deep
```

**What happens:**
1. All three models analyze in parallel:
   - **Codex**: Technical implementation details
   - **Claude**: Reasoning about trade-offs
   - **Gemini**: Latest industry trends (2025)
2. **Codex perspective:** Code/architecture focus
3. **Gemini perspective:** Current trends (2025)
4. Synthesis compares both views
5. Report shows consensus and differences

2. Hybrid orchestrator combines perspectives
3. Generates synthesis report

**Output:**
```markdown
## Codex Analysis
Recommendation: Start with modular monolith
Confidence: 80%
Reasoning: Team size, faster development...

## Claude Analysis
Recommendation: Modular monolith with migration plan
Confidence: 85%
Reasoning: Balanced approach, clear trade-offs...

## Gemini Analysis
Recommendation: Microservices with service mesh
Confidence: 75%
Reasoning: 2025 trend, cloud-native...

## Synthesis
Consensus: Phased approach (monolith → microservices)
All three agree: Start simple, plan for migration
Key difference: Timeline (Claude suggests 18mo, others 12mo)
```

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

### Custom Mode Configuration

Edit mode files in `.claude/skills/ai-collaborative-solver/modes/`:

```yaml
# modes/custom.yaml
name: custom
rounds: 5
agents:
  - explorer
  - critic
  - security
  - performance
  - synthesizer
```

---

### Registry Configuration

The capability registry (`config/registry.yaml`) defines all models:

```yaml
models:
  - id: openai.codex
    capabilities: [chat, json, tool, debate, code_execution]
    cost: {prompt_per_1k: 0.005, completion_per_1k: 0.015}

  - id: anthropic.claude-sonnet
    capabilities: [chat, json, tool, debate, long_context]
    cost: {prompt_per_1k: 0.003, completion_per_1k: 0.015}

  - id: google.gemini-pro
    capabilities: [chat, json, debate, grounding]
    cost: {prompt_per_1k: 0.001, completion_per_1k: 0.005, free_tier: true}
```

**To add a new model:**
1. Add to `registry.yaml`
2. Create adapter in `models/{name}/adapter.sh`
3. Model selector will automatically recognize it

---

## Output Format

Reports saved to `.debate-reports/` with structure:

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
   Let the system choose the best model

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

### Issue: "codex CLI not found"

**Solution:**
```bash
npm install -g @openai/codex
codex  # Authenticate (requires ChatGPT Plus)
```

---

### Issue: "gemini-cli not found"

**Solution:**
```bash
npm install -g @google/gemini-cli
gemini-cli  # Authenticate (free Google account)
```

---

### Issue: "Claude Code CLI not found"

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

### Issue: Auto-select chose wrong model

**Solution:**
```bash
# Override with specific model
./ai-debate.sh "Problem" --model codex
# OR add keywords to problem description
./ai-debate.sh "코드 리뷰: Problem" --auto  # Will select Codex
```

---

### Issue: Hybrid mode too slow

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
