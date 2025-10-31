# Codex Collaborative Solver V3.0

**Quality-First Debate Architecture with Self-Improving Facilitator**

## Overview

V3.0 introduces a fundamental paradigm shift: from "facilitating debates" to "ensuring quality outcomes through intelligent facilitation." This version features a 3-layer hybrid facilitator system, automated knowledge extraction via playbooks, and adaptive quality modes.

**Key Innovation:** Meta-monitoring layer that detects coverage gaps, anti-patterns, and information scarcity, automatically improving debate quality over time.

## When to Use This Skill

Activate when users request:
- "codex와 토론해서 해결해줘" / "debate with codex to solve this"
- "claude랑 codex 협업으로 답 찾아줘" / "claude and codex collaborate"
- "두 AI의 의견을 들어보고 싶어" / "want opinions from both AIs"
- Complex problems requiring multi-perspective analysis

**Appropriate problem types:**

1. **Architecture Decisions** - "Should we use microservices or monolith?"
2. **Bug Investigation** - "What's causing this memory leak?"
3. **Algorithm Optimization** - "Can we improve from O(n²) to O(n log n)?"
4. **Design Pattern Selection** - "Which design pattern fits this scenario?"

## Prerequisites

**Required:**
- OpenAI Codex CLI installed: `npm i -g @openai/codex`
- ChatGPT Plus/Pro subscription
- Codex authenticated: Run `codex` once

**Verify installation:**
```bash
codex --version
```

## What's New in V3.0

### 🎯 Core Improvements

| Feature | V2.0 | V3.0 |
|---------|------|------|
| **Quality Assurance** | Manual | 3-layer Facilitator (auto) |
| **Knowledge Reuse** | None | Automated Playbook Pipeline |
| **Adaptability** | Fixed process | 3 Quality Modes |
| **Evidence** | Implicit | Tiered (with confidence) |
| **Coverage** | Ad-hoc | 8-dimension monitoring |
| **Failure Detection** | None | 10 explicit mechanisms |

### 📊 Expected Quality Gains

- **Actionability**: 60% → 90%
- **Confidence Clarity**: 10% → 100%
- **Coverage Completeness**: 4/8 → 7/8 dimensions
- **Appropriate Pauses**: 0% → 20-30% (when info missing)

## V3.0 Architecture

### 1. Hybrid Facilitator System (THE KEYSTONE)

**Why it matters:** Without meta-monitoring, all other improvements fail. The facilitator is the quality control layer.

#### Layer 1: Rule-Based Monitor (Every Round)

**Coverage Tracker**
- Monitors 8 dimensions: {architecture, security, performance, UX, testing, ops, cost, compliance}
- After each round, flags uncovered areas
- Example: "Neither agent addressed testing strategy - should we explore this?"

**Anti-Pattern Detector**
- Circular reasoning (same point repeated 2+ times)
- Premature convergence (agreement in <2 rounds without exploring alternatives)
- Information starvation (agents guessing instead of asking user)
- Dominance (one agent's view accepted without challenge)

**Scarcity Detector**
- Tracks assumption:fact ratio
- Counts critical unknowns
- **Abort Thresholds:**
  - ≥2 critical decision axes unknown after exploration pass
  - OR assumption:fact ratio > 2:1
  - Logs specific missing facts for re-engagement

**Mode Validator**
- Re-scores debate intent after each round
- Auto-switches modes if confidence drops
- Prevents mode misclassification

Configuration: `facilitator/rules/`

#### Layer 2: AI Escalation (On Flags)

Lightweight third AI agent handles non-trivial situations:
- "Circular reasoning detected between rounds 2-3" → Suggests pivot to unexplored aspect
- "Neither agent addressed compliance" → Prompts regulatory exploration
- High-friction patterns (rapid-turn, high disagreement, policy triggers) → Escalates to user

Prompts: `facilitator/prompts/ai-escalation.md`

#### Layer 3: Quality Gate (Pre-Finalization)

Mandatory checklist before finalizing:
- [ ] Verified assumptions or marked as assumptions?
- [ ] User constraints honored?
- [ ] Risks surfaced with mitigation?
- [ ] Next actions concrete and executable?
- [ ] Confidence level explicit?

Template: `facilitator/quality-gate.md`

### 2. Quality Mode System

Users can specify (or auto-detected from keywords):

```yaml
Mode: exploration
  Purpose: Creative idea generation
  Claude weighting: Breadth + creativity (high)
  Codex weighting: Feasibility checks (soft)
  Rounds: 5-7
  Use when: "Explore architecture options", "Brainstorm approaches"

Mode: balanced (default)
  Purpose: Balanced decision-making
  Claude weighting: Standard
  Codex weighting: Standard
  Rounds: 3-5
  Use when: "Choose technology stack", "Architecture decision"

Mode: execution
  Purpose: Fast, actionable answers
  Claude weighting: User alignment
  Codex weighting: Implementation detail (high)
  Rounds: 2-3
  Use when: "Fix this bug", "Quick implementation approach"
```

Mode definitions: `modes/`

### 3. Automated Playbook Pipeline

**Turning Debates into Organizational Knowledge**

```
Debate Session
    ↓
Structured Logs (problem, assumptions, options, decisions)
    ↓
Auto-Tagging (shallow NLP, taxonomy labels)
    ↓
Nightly Clustering (similar problem signatures)
    ↓
Success Metrics Promotion (repeated patterns)
    ↓
LLM Summarizer (drafts playbook, cites sources)
    ↓
Human/Agent Validation (spot-check)
    ↓
Canonical Playbooks (60-day validity)
```

**Playbook Structure:**
- Problem signature (when to apply)
- Key questions to explore
- Common tradeoffs
- Evidence sources
- Past debate references
- Success metrics
- Expiration date

Examples: `playbooks/`
Template: `playbooks/_template.md`

### 4. Role Division

**Exploration Phase (Rounds 1-2):**
- **Claude**: Generate 3-5 diverse approaches (including wild ones)
- **Codex**: Reality-check feasibility ("This won't work because...")
- **Facilitator**: Ensure edge cases explored

**Convergence Phase (Rounds 3-5):**
- **Claude**: User alignment verification ("Solves actual problem?")
- **Codex**: Implementation feasibility ("Can we build this?")
- **Facilitator**: Force stress test before consensus

**Stress Pass (Before Consensus):**
- Last endorsing agent must enumerate failure modes
- No rubber-stamp escapes allowed

### 5. Tiered Evidence System

**Tier 1: Direct Evidence (High Confidence 90-100%)**
- Repo artifacts, actual code examples
- Real benchmarks, metrics
- Documented case studies
- Verifiable facts

**Tier 2: Reasoned Analogies (Medium Confidence 60-80%)**
- Similar problems, extrapolated patterns
- Industry best practices
- Documented tradeoffs
- Expert consensus

**Tier 3: Explicit Assumptions (Low Confidence 30-50%)**
- Clearly marked as assumptions
- Justified reasoning provided
- Confidence penalty applied
- Requires validation

**Never:** Fabricate data or present speculation as fact

### 6. Information Scarcity Protocol

**Fallback Chain:**
```
Evidence unavailable?
  ↓
1. Derivable from first principles? → Reasoned analogy (Tier 2)
  ↓
2. User can answer? → Ask clarifying question (PAUSE)
  ↓
3. Quick prototype/test possible? → Suggest experiment
  ↓
4. Last resort: Make assumption + mark clearly + Tier 3 + confidence penalty
```

**When to ABORT and query user:**
- ≥2 critical decision axes unknown after exploration pass
- OR assumption:fact ratio > 2:1
- Facilitator logs which missing facts block risk evaluation
- Re-engagement prompt is specific

### 7. Edge Case Mitigations (10 Failure Modes)

1. **Circular Reasoning** → Anti-pattern detector flags → AI facilitator suggests pivot
2. **Premature Convergence** → Requires 2+ rounds + alternative exploration
3. **Information Starvation** → Scarcity detector → abort and query user
4. **Dominance** → Balance checker → prompt underrepresented agent
5. **Mode Misclassification** → Post-round re-scoring → auto-switch
6. **Coverage Drift** → Nightly telemetry → propose new dimensions
7. **Playbook Staleness** → 60-day expiry → re-validation required
8. **Facilitator Myopia** → High-friction patterns → escalate to user
9. **Log Integrity** → Heartbeat + replay buffer → graceful pause
10. **Facilitator Failure** → 7-round limit, 2-ignore threshold → user override

## V3.0 Workflow

### Pre-Debate

1. **Mode Selection**
   - User specifies: "Use exploration mode"
   - OR auto-detect from keywords
   - Default: balanced

2. **Playbook Loading**
   - Facilitator checks if relevant playbook exists
   - Loads playbook if available
   - Example: "database-migration.md" for DB questions

3. **Coverage Initialization**
   - Coverage monitor initializes 8-dimension checklist
   - Sets mode-specific thresholds

### Round Loop (1-7 rounds, or until convergence)

**Each Round:**

A. **Role-Based Work**
   - Rounds 1-2 (Exploration): Claude diverges → Codex reality-checks
   - Rounds 3+ (Convergence): Claude aligns → Codex validates

B. **Facilitator Checks (Every Round)**
   - Anti-pattern detection → AI escalates if needed
   - Scarcity check → Abort if thresholds crossed
   - Coverage gaps → Prompt agents
   - Mode re-evaluation → Auto-switch if mismatch

C. **Stress Pass (Before Consensus)**
   - Last endorsing agent enumerates failure modes
   - Prevents rubber-stamping

D. **Escalation Conditions**
   - 7 rounds exceeded → Flag to user
   - Facilitator prompts ignored 2+ times → Hand control to user
   - High-friction patterns → Immediate user escalation

### Post-Debate

1. **Quality Gate** (Mandatory)
   - Run checklist from `facilitator/quality-gate.md`
   - Block finalization if criteria not met

2. **Structured Logging**
   - Generate debate log (schema: `schemas/debate-log.json`)
   - Store for playbook pipeline
   - Include metrics: confidence, evidence tiers, coverage

3. **Report Generation**
   - Use template from V2.0 (still valid)
   - Add V3.0 enhancements:
     - Confidence levels
     - Coverage matrix
     - Evidence tier breakdown
     - Facilitator interventions log

4. **Cleanup**
   - Run debate-end.sh
   - Archive session

### Async (Background)

- **Nightly**: Playbook extraction from debate logs
- **Weekly**: User feedback integration → heuristic tuning
- **Monthly**: Playbook validity re-validation

## Usage Examples

### Basic Usage (Auto-Mode)

```
User: "codex와 토론해서 이 성능 문제 해결해줘. DB 쿼리가 느려."

Claude:
1. Auto-detects mode: balanced (tech decision)
2. Loads playbook: database-optimization.md
3. Initializes coverage: {query patterns, indexing, caching, schema, ...}
4. Starts debate...

Round 1: Claude explores 3 approaches → Codex reality-checks
Facilitator: Flags "compliance not addressed"

Round 2: Compliance explored → Scarcity detector finds 2 unknowns
Facilitator: ABORTS - "Need: 1) Current query patterns 2) Expected scale"

User provides data...

Round 3: Solution converges → Stress pass
Facilitator: Quality gate passes

Output: "Add indexes (immediate), eager loading (eliminates N+1),
        Django cache (before Redis). Confidence: 85%"
```

### Explicit Mode Selection

```
User: "Use exploration mode - codex와 함께 새로운 아키텍처 패턴 탐색해줘"

Claude:
1. Mode: exploration (5-7 rounds, creativity weighted)
2. No playbook (novel exploration)
3. Rounds 1-3: Divergent ideation
4. Rounds 4-5: Reality-check + synthesis
5. Output: Multiple options with tradeoffs, no single recommendation
```

### User Override

```
During debate:

User: "/debate-override Skip security discussion, focus on performance only"

Facilitator: Acknowledges override, updates coverage monitor
Debate continues with adjusted focus
```

## Scripts Location

V3.0 **reuses V2.0 scripts** for Codex interaction:
- `.claude/scripts/codex-debate/debate-start.sh`
- `.claude/scripts/codex-debate/debate-continue.sh`
- `.claude/scripts/codex-debate/debate-end.sh`

**New V3.0 scripts** (facilitator automation):
- `scripts/facilitator/check-coverage.py` (planned)
- `scripts/facilitator/detect-anti-patterns.py` (planned)
- `scripts/facilitator/generate-playbook.py` (planned)

## Configuration Files

### Facilitator Rules

- `facilitator/rules/coverage-monitor.yaml` - 8-dimension checklist
- `facilitator/rules/anti-patterns.yaml` - Detection patterns
- `facilitator/rules/scarcity-thresholds.yaml` - Abort conditions

### Mode Definitions

- `modes/exploration.yaml` - Creative mode settings
- `modes/balanced.yaml` - Default mode settings
- `modes/execution.yaml` - Fast execution settings

### Schemas

- `schemas/debate-log.json` - Structured log format
- `schemas/playbook-schema.json` - Playbook structure
- `schemas/metrics.json` - Quality metrics

## Comparison: V2.0 vs V3.0

See `references/v2-vs-v3-comparison.md` for detailed comparison.

**Quick Summary:**

| Aspect | V2.0 | V3.0 |
|--------|------|------|
| **Philosophy** | Facilitate debates | Ensure quality outcomes |
| **Quality Control** | Manual | Automated (3-layer facilitator) |
| **Adaptability** | One-size-fits-all | 3 modes (exploration/balanced/execution) |
| **Knowledge Reuse** | None | Automated playbook pipeline |
| **Failure Handling** | Hope for the best | 10 explicit mechanisms |
| **Evidence** | Implicit | Tiered with confidence levels |
| **Coverage** | Ad-hoc | 8-dimension systematic monitoring |
| **Consensus** | Accept at face value | Stress pass required |

## Best Practices

### Do's ✅

1. **Trust the Facilitator** - If it aborts for missing info, provide the info
2. **Specify Mode When Needed** - Exploration for novel problems, execution for urgent fixes
3. **Review Playbooks** - If loaded, verify it matches your context
4. **Check Confidence Levels** - Low confidence = validate before implementing
5. **Save Debate Reports** - Future playbooks depend on this data

### Don'ts ❌

1. **Don't Skip Quality Gate** - If it flags issues, address them
2. **Don't Ignore Facilitator Warnings** - They catch real problems
3. **Don't Expect Perfection** - V3.0 is designed to be explicit about uncertainty
4. **Don't Override Lightly** - Facilitator has reasons for its checks
5. **Don't Implement Low-Confidence Solutions** - Validate first

## Troubleshooting

### "Facilitator keeps aborting"

Check scarcity detector output - you likely have insufficient information. Provide the requested data or acknowledge the decision must be made under uncertainty.

### "Debate stuck in exploration"

Mode might be misclassified. Use `/debate-override Switch to execution mode` to force convergence.

### "Playbook doesn't match my problem"

Playbooks are templates, not straitjackets. If mismatch is severe, use `/debate-override Ignore playbook` to proceed without it.

### "Quality gate blocking finalization"

Review checklist - one or more criteria not met. Either address the issue or document why it's acceptable to proceed without meeting it.

## Limitations

V3.0 Cannot:
- Replace human judgment (AI recommendation requires approval)
- Execute code or run tests (propose solutions, don't implement)
- Access external APIs or databases
- Guarantee "correct" answer (provides perspectives + confidence)
- Work offline (requires OpenAI API access)
- Function without Codex CLI installed

**Remember:** V3.0 is a tool for quality assurance and exploration, not a replacement for human decision-making.

## Meta-Learning

V3.0 improves itself through:
1. **Playbook accumulation** - Each debate potentially creates new playbooks
2. **Heuristic tuning** - User feedback adjusts facilitator thresholds
3. **Coverage expansion** - Telemetry discovers missing dimensions
4. **Mode calibration** - Success metrics refine mode selection

**Review cycle**: After 50 debates (~3-6 months), analyze metrics and update facilitator rules.

## References

- V2.0 Documentation: `~/.claude/skills/codex-collaborative-solver/skill.md`
- V3.0 Design Debate: `references/v3-design-debate.md`
- Comparison Guide: `references/v2-vs-v3-comparison.md`
- Facilitator Protocol: `facilitator/README.md`
- Playbook Guide: `playbooks/README.md`

## Appendix: Quick Start Checklist

**First Time Using V3.0:**
- [ ] Codex CLI installed and authenticated
- [ ] Read `references/v2-vs-v3-comparison.md`
- [ ] Understand 3 quality modes
- [ ] Know when facilitator will abort (scarcity thresholds)
- [ ] Aware of 8 coverage dimensions

**Before Each Debate:**
- [ ] Choose mode (or let auto-detect)
- [ ] Check if playbook exists for problem type
- [ ] Prepare to provide missing info if facilitator aborts

**After Each Debate:**
- [ ] Review confidence levels
- [ ] Validate low-confidence recommendations
- [ ] Check coverage matrix - any gaps?
- [ ] Provide feedback if quality unexpected

---

**Version:** 3.0.0
**Status:** Experimental (Test vs V2.0)
**Last Updated:** 2025-10-31
**Based On:** Meta-debate design session (Session ID: 019a37e1-6dc5-7d91-824e-52cae43772eb)
**Models:** Claude 3.5 Sonnet (Anthropic) + GPT-5 Codex via Codex CLI (OpenAI)
