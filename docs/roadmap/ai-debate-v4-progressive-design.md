# AI Debate v4.0: Progressive Constructive Debate

**Design Document**

**Version**: 4.0.0-design
**Date**: 2025-11-04
**Status**: 📋 Design Phase
**Author**: Claude Code + User
**Current Version**: 3.1.0-complete

---

## Executive Summary

**Problem**: Current AI debate (v3.1) collects independent opinions and synthesizes them, but lacks true debate dynamics - no rebuttal, no evidence-based argumentation, no progressive refinement.

**Solution**: Introduce "Progressive Constructive Debate" - a multi-round system where agents constructively challenge each other's opinions, provide evidence, and progressively refine solutions while avoiding unproductive back-and-forth.

**Key Goals**:
1. **Progressive refinement**: Iterate toward better solutions through multiple rounds
2. **Diverse perspectives**: Deep exploration from multiple angles (pros/cons/risks)
3. **Constructive criticism**: Challenge weak points without "debate for debate's sake"
4. **Evidence-based**: Back claims with data/benchmarks/case studies
5. **User-guided**: Allow user intervention to steer discussion

**Expected Outcome**:
- Deeper, evidence-backed analysis
- Identification and resolution of logical gaps
- User participates in refining the debate direction
- Trade-off: 2-3x slower (26s → 56-86s)

---

## 1. Current State Analysis

### v3.1.0 Architecture (Current)

```
Phase 1: Pre-Clarification
  ↓
Phase 2.1: Main Claude generates opinion (0.7s)
  ↓
Phase 2.2: Codex generates opinion (19s) [parallel]
  ↓
Phase 2.3: Wait for completion
  ↓
Phase 2.4: Synthesis (identify agreement/disagreement)
  ↓
Phase 2.5: Present structured output
  ↓
[END] - Single round, 26s total
```

### Limitations of v3.1

| Limitation | Impact | Example |
|------------|--------|---------|
| **No rebuttal** | Opinions remain unchallenged | Agent A says "Django is stable", Agent B says "FastAPI is fast" - no one questions if stability matters more than speed in this context |
| **No evidence** | Claims lack backing | "Django is more mature" - but how much more? By what metrics? |
| **No refinement** | First answer is final | Initial opinion may have logical gaps that never get addressed |
| **No user steering** | User can't guide discussion | User realizes "team async experience" is critical but can't interject |
| **Surface-level** | Analysis doesn't go deep | Stops at obvious pros/cons, doesn't explore edge cases or second-order effects |

### What Users Want (Requirements from /clarify)

**Goals:**
1. ✅ Optimal solution derivation (progressive improvement)
2. ✅ Diverse perspective exploration (deep multi-angle analysis)
3. ✅ Collaborative refinement (agents complement each other)

**Concerns:**
- ⚠️ Avoid "rebuttal for rebuttal's sake" (unproductive argument)
- ⚠️ Avoid unanimous agreement (defeats purpose of debate)
- → Need: **Constructive Challenge** approach

**Desired Features:**
- ✅ Attack weak points + evidence-based argumentation
- ✅ Real-time user feedback (mid-debate intervention)

---

## 2. Design Goals

### Primary Goals

**G1: Progressive Refinement**
- Each round should produce incrementally better analysis
- Identify and address logical gaps
- Converge toward robust recommendation

**G2: Constructive Challenge**
- Agents acknowledge each other's strengths (avoid pure opposition)
- Ask clarifying questions (not rhetorical attacks)
- Point out genuine weak spots (logical flaws, missed risks)
- Demand evidence for claims (cite sources, benchmarks, case studies)

**G3: User Participation**
- User can interject with new constraints or priorities
- User can request deep-dive on specific aspects
- User decides when analysis is sufficient

**G4: Maintain Performance**
- Total time: 56-86s (acceptable for deep analysis)
- Avoid exponential blowup (max 3 rounds)
- Allow "quick mode" (skip to final synthesis)

### Non-Goals

**NG1: Unlimited Debate**
- Not designing a infinite-round system (cap at 3 rounds)

**NG2: Real-time Streaming**
- Phase 4 feature, not v4.0 core

**NG3: Multi-agent (3+ agents)**
- Gemini excluded (too slow), stick with Main Claude + Codex

---

## 3. Architecture Overview

### High-Level Flow

```
┌─────────────────────────────────────────────────────────┐
│ Phase 1: Pre-Clarification                              │
│ (existing, unchanged)                                   │
└─────────────────┬───────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────────────────────┐
│ Phase 2: Round 1 - Independent Analysis                 │
│ ├─ 2.1: Main Claude generates opinion (0.7s)           │
│ ├─ 2.2: Codex generates opinion (19s)                  │
│ └─ 2.3: Wait for completion                            │
└─────────────────┬───────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────────────────────┐
│ Phase 3: Round 2 - Constructive Challenge (NEW)         │
│ ├─ 3.1: Main Claude challenges Codex opinion           │
│ │      ✅ Acknowledge strengths                         │
│ │      ⚠️ Ask clarifying questions                      │
│ │      ❌ Point out weak spots                          │
│ │      📊 Request evidence                              │
│ ├─ 3.2: Codex challenges Main Claude opinion           │
│ │      (same structure)                                │
│ └─ [Parallel execution: 30s]                           │
└─────────────────┬───────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────────────────────┐
│ Phase 4: Round 3 - Evidence & Refinement (NEW)          │
│ ├─ 4.1: Respond to challenges                          │
│ │      - Provide evidence (WebSearch if needed)        │
│ │      - Acknowledge valid points                      │
│ │      - Refine original opinion                       │
│ ├─ 4.2: Update positions                               │
│ └─ [30-50s depending on evidence gathering]            │
└─────────────────┬───────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────────────────────┐
│ Phase 5: User Intervention Point (NEW)                  │
│ ├─ 5.1: Show debate summary so far                     │
│ ├─ 5.2: Present options:                               │
│ │      - "Deep dive on [specific topic]"               │
│ │      - "Add new constraint: [X]"                     │
│ │      - "Sufficient, proceed to conclusion"           │
│ └─ [User input: 10-30s]                                │
└─────────────────┬───────────────────────────────────────┘
                  ↓
         ┌────────┴────────┐
         │                 │
    [Loop back to      [Proceed to
     Phase 3 with       Phase 6]
     new focus]             │
         │                 │
         └─────────────────┘
                  ↓
┌─────────────────────────────────────────────────────────┐
│ Phase 6: Final Synthesis                                 │
│ ├─ 6.1: Synthesize all rounds                          │
│ ├─ 6.2: Re-evaluate confidence level                   │
│ ├─ 6.3: Present refined recommendation                 │
│ └─ [2s]                                                 │
└─────────────────────────────────────────────────────────┘
```

### Performance Budget

| Phase | Time | Bottleneck |
|-------|------|------------|
| Phase 1: Clarification | 5-10s | User input (conditional) |
| Phase 2: Round 1 | 26s | Codex API (19s) |
| Phase 3: Challenge | 30s | Parallel Codex + Main Claude |
| Phase 4: Evidence | 20-50s | WebSearch (conditional) |
| Phase 5: User Input | 10-30s | User decision |
| Phase 6: Synthesis | 2s | Text generation |
| **Total** | **56-86s** | **Evidence gathering + user input** |

---

## 4. Detailed Phase Design

### Phase 3: Constructive Challenge

**Objective**: Each agent analyzes the other's opinion and provides constructive criticism.

#### 3.1 Main Claude → Codex Challenge

**Input**:
- Main Claude's own opinion (from Phase 2.1)
- Codex's opinion (from Phase 2.2)

**Process**:
```markdown
You are reviewing Codex's opinion on [question].
Your task: Provide CONSTRUCTIVE challenge, not adversarial debate.

Guidelines:
1. ✅ Acknowledge Strengths (2-3 points)
   - What did Codex get right?
   - Which arguments are solid?

2. ⚠️ Ask Clarifying Questions (2-3 questions)
   - Not rhetorical, genuine gaps in understanding
   - Example: "You mentioned X, but what about edge case Y?"

3. ❌ Point Out Weak Spots (1-3 issues)
   - Logical inconsistencies
   - Overlooked risks
   - Unsupported claims

4. 📊 Request Evidence (if applicable)
   - "You claim X is faster - by how much?"
   - "What's the data on adoption rates?"

Codex's Opinion:
[Insert Codex opinion]

Your Response:
```

**Output Template**:
```markdown
## Main Claude's Challenge to Codex

✅ **Strengths Acknowledged:**
1. [Strength 1]
2. [Strength 2]

⚠️ **Clarifying Questions:**
1. [Question 1]
2. [Question 2]

❌ **Weak Spots Identified:**
1. [Issue 1 - why it's problematic]
2. [Issue 2 - alternative view]

📊 **Evidence Requested:**
1. [Claim 1 - what data would support/refute this]
2. [Claim 2 - benchmarks needed]
```

#### 3.2 Codex → Main Claude Challenge

**Same structure**, but executed via `codex-session.sh`:

```bash
codex-session.sh new "
You are reviewing Main Claude's opinion on [question].
Provide constructive challenge following this structure:
✅ Strengths (2-3)
⚠️ Questions (2-3)
❌ Weak spots (1-3)
📊 Evidence requests (if any)

Main Claude's Opinion:
[Insert opinion]
" --stdout-only --quiet
```

**Execution**: 3.1 and 3.2 run in **parallel** (30s total, not 60s).

---

### Phase 4: Evidence & Refinement

**Objective**: Respond to challenges, provide evidence, refine positions.

#### 4.1 Main Claude Responds to Codex's Challenge

**Input**:
- Original Main Claude opinion
- Codex's challenge (from Phase 3.2)

**Process**:
1. **For each question**: Provide answer or admit uncertainty
2. **For each weak spot**:
   - Acknowledge if valid
   - Provide counterargument if not
3. **For evidence requests**:
   - Use WebSearch to find data/benchmarks
   - Cite sources
4. **Refine opinion**: Update recommendation if challenges are valid

**Example**:
```markdown
## Main Claude's Response

### Addressing Codex's Questions

**Q1: What about Django's async views in 4.1+?**
A: Valid point. Django 4.1+ does support async views. However, the ecosystem (DRF, many plugins) is still primarily sync. For a 3-month project, relying on cutting-edge async Django may introduce compatibility risks.

**Q2: Team's async experience?**
A: [Searches context] Not specified. **Follow-up needed**: If team has strong async/await experience, FastAPI becomes more viable.

### Addressing Weak Spots

**Issue 1: DRF also has learning curve**
✅ **Acknowledged**: This is true. My original "Django = less learning curve" argument was oversimplified.
📊 **Evidence**: [WebSearch] "Django REST Framework tutorial" → typical setup: 2-3 days for basic CRUD.

**Issue 2: 10k users - performance matters?**
🔍 **Evidence Gathering**: [WebSearch] "Django vs FastAPI benchmark 10k concurrent users"
📊 **Found**:
- FastAPI: 25k req/s
- Django: 5k req/s
- **BUT**: At 10k DAU (not concurrent), both handle load fine
✅ **Refined**: Performance difference exists but not critical at this scale.

### Updated Position

**Original**: "Django recommended"
**Refined**: "Django recommended IF team lacks async experience. FastAPI recommended IF team has async expertise AND expects >50k concurrent users."
**Confidence**: Medium → Medium-High (more nuanced)
```

#### 4.2 Codex Responds

**Same process via codex-session**:
```bash
codex-session.sh continue "
Here's Main Claude's challenge to your opinion:
[Insert challenge]

Respond to:
1. Questions raised
2. Weak spots identified
3. Provide evidence for claims (cite sources)
4. Refine your recommendation if needed
" --stdout-only --quiet
```

**WebSearch Integration** (Optional):
```python
# If evidence request detected
if "📊" in challenge:
    query = extract_search_query(challenge)
    results = web_search(query)
    evidence = summarize_results(results)
    response = f"Evidence: {evidence}\nSource: {results[0].url}"
```

---

### Phase 5: User Intervention Point

**Objective**: Show user the debate progress and allow steering.

#### 5.1 Present Debate Summary

**Output to user**:
```markdown
# 💬 Debate Progress Summary

## Round 1: Initial Opinions
- **Main Claude**: Recommends Django (stability focus)
- **Codex**: Recommends FastAPI (performance focus)

## Round 2: Challenges & Evidence
- **Key Contention**: Learning curve vs performance trade-off
- **Evidence Found**:
  - FastAPI 5x faster at scale
  - Django 4.1 async views exist but ecosystem lag
  - 10k DAU ≠ 10k concurrent (both handle fine)

- **Refined Positions**:
  - Main Claude: "Django unless team has async expertise"
  - Codex: "FastAPI if growth to 50k+ expected"

## Identified Gaps
⚠️ **Unresolved**: Team's async/await experience level not clarified
⚠️ **Unresolved**: Growth expectations (will 10k → 50k in 6 months?)

---

## What would you like to do next?

**Option 1: Deep Dive**
Focus on a specific aspect for another round:
- [ ] Team skillset and training cost
- [ ] Long-term scalability (6-12 months out)
- [ ] Migration path (Django → FastAPI later?)

**Option 2: Add New Constraint**
Introduce new information:
- Example: "Team lead has FastAPI experience"
- Example: "Budget for training: $5k"

**Option 3: Conclude**
Proceed to final synthesis with current analysis.

[User selects option]
```

#### 5.2 Handle User Input

```python
def handle_user_input(choice):
    if choice == "deep_dive":
        topic = user.select_topic()
        return restart_phase3(focus=topic)  # Loop back

    elif choice == "add_constraint":
        new_constraint = user.provide_constraint()
        return restart_phase2(context=updated_context)  # Re-analyze

    elif choice == "conclude":
        return proceed_to_phase6()
```

---

### Phase 6: Final Synthesis

**Objective**: Integrate all rounds into cohesive recommendation.

**Process**:
1. **Synthesize Evolution**:
   ```
   Round 1: Django vs FastAPI (stability vs speed)
   Round 2: Nuanced - depends on team async experience
   Round 3: [If user added constraint] With team lead's FastAPI exp, FastAPI feasible
   ```

2. **Re-Evaluate Confidence**:
   ```
   Initial: Medium (60%)
   After evidence: Medium-High (75%)
   After user constraint: High (85%)
   ```

3. **Provide Final Recommendation**:
   ```markdown
   ## Final Recommendation

   **Decision**: FastAPI

   **Reasoning**:
   - Team lead has FastAPI experience (reduces learning curve)
   - 10k → 50k growth expected (performance advantage matters)
   - Evidence: FastAPI 5x faster at scale
   - Django's async views insufficient (ecosystem lag)

   **Confidence**: High (85%)

   **Next Steps**:
   1. Assign team lead as FastAPI mentor
   2. Allocate 1 week for team async/await training
   3. Start with FastAPI + SQLAlchemy (familiar ORM)
   4. Benchmark at 20k users, revisit if issues

   **Risks Mitigated**:
   - Learning curve → Team lead mentorship
   - Unfamiliar patterns → Training week
   - Premature optimization → Benchmark plan
   ```

---

## 5. Implementation Plan

### Phase 1: Core Infrastructure (Week 1)

**Tasks**:
1. ✅ Refactor skill.md to support multi-round structure
2. ✅ Add `phase3_constructive_challenge()` function
3. ✅ Add `phase4_evidence_refinement()` function
4. ✅ Create challenge/response templates
5. ✅ Test with mock data (no API calls)

**Deliverables**:
- Updated `skill.md` with Phase 3-4 templates
- Test script: `tmp/test-multi-round.sh`

**Time**: 3-4 hours

---

### Phase 2: WebSearch Integration (Week 1)

**Tasks**:
1. ✅ Detect evidence requests in challenges
2. ✅ Extract search queries from text
3. ✅ Integrate WebSearch tool
4. ✅ Format search results as evidence
5. ✅ Handle "no results" gracefully

**Deliverables**:
- `scripts/web-search-helper.sh` (if needed)
- Evidence formatting templates

**Time**: 2-3 hours

---

### Phase 3: User Intervention UI (Week 2)

**Tasks**:
1. ✅ Create debate summary template
2. ✅ Use `AskUserQuestion` tool for options
3. ✅ Implement loop-back logic (deep dive → Phase 3)
4. ✅ Implement constraint injection (add info → Phase 2)
5. ✅ Test user flow end-to-end

**Deliverables**:
- Phase 5 implementation in skill.md
- User flow test script

**Time**: 3-4 hours

---

### Phase 4: Testing & Refinement (Week 2)

**Tasks**:
1. ✅ End-to-end test with real questions
2. ✅ Measure performance (target: <90s)
3. ✅ Refine templates based on output quality
4. ✅ Edge case handling (unanimous agreement, no challenges, etc.)
5. ✅ Documentation update

**Deliverables**:
- Test suite: `tmp/test-ai-debate-v4.sh`
- Performance report
- Updated `skill.md` documentation

**Time**: 2-3 hours

---

### Phase 5: Deployment (Week 2)

**Tasks**:
1. ✅ Git commit changes
2. ✅ `/apply-settings` to global
3. ✅ Verify in test project
4. ✅ User guide update
5. ✅ Changelog

**Time**: 1 hour

---

## 6. Performance Analysis

### Time Breakdown (Projected)

| Phase | Best Case | Worst Case | Notes |
|-------|-----------|------------|-------|
| Phase 1: Clarify | 0s | 10s | If user bypasses |
| Phase 2: Round 1 | 26s | 26s | Fixed (Codex API) |
| Phase 3: Challenge | 30s | 35s | Parallel execution |
| Phase 4: Evidence | 10s | 50s | WebSearch conditional |
| Phase 5: User Input | 5s | 60s | User think time |
| Phase 6: Synthesis | 2s | 5s | Text generation |
| **Total** | **73s** | **186s** | **Avg: 86s** |

### Optimization Strategies

**O1: Quick Mode**
```
Skip Phase 4 (no evidence) → Save 20-50s
Skip Phase 5 (no user input) → Save 10-30s
Total: 56s (2x faster than full mode)
```

**O2: Parallel Phase 4**
```
Both agents gather evidence simultaneously → Save 15-25s
```

**O3: Caching**
```
Cache WebSearch results (question hash) → Save 10-20s on repeat
```

### Comparison with v3.1

| Metric | v3.1 (Current) | v4.0 (Proposed) | Delta |
|--------|----------------|-----------------|-------|
| **Total Time** | 26s | 56-186s (avg 86s) | +231% |
| **Depth** | Surface | Deep | ✅ |
| **Evidence** | None | Web-backed | ✅ |
| **User Control** | None | Full | ✅ |
| **Refinement** | 1-shot | Progressive | ✅ |

**Trade-off Justified?**
- ✅ YES for complex decisions (architecture, tech stack, etc.)
- ❌ NO for simple questions ("which Python version?")
- → Solution: Provide "quick mode" flag

---

## 7. Risk Analysis

### R1: Unproductive Back-and-Forth

**Risk**: Agents engage in "rebuttal for rebuttal's sake"

**Mitigation**:
1. ✅ Enforce "acknowledge strengths" in every challenge
2. ✅ Limit to 3 rounds max
3. ✅ Require evidence for continued disagreement
4. ✅ User can terminate debate early (Phase 5)

**Likelihood**: Medium
**Impact**: High (wastes time)
**Priority**: 🔴 High

---

### R2: Performance Degradation

**Risk**: >3 minutes total time → user abandons

**Mitigation**:
1. ✅ Quick mode (skip Phase 4-5)
2. ✅ Parallel execution where possible
3. ✅ Cache WebSearch results
4. ✅ Provide progress indicators ("Round 2/3...")

**Likelihood**: Low (with optimizations)
**Impact**: Medium
**Priority**: 🟡 Medium

---

### R3: Evidence Quality

**Risk**: WebSearch returns irrelevant/low-quality data

**Mitigation**:
1. ✅ Use multiple search results (top 3)
2. ✅ Agents cite sources (user can verify)
3. ✅ Fallback: "Evidence not found, proceeding with analysis"
4. ✅ User can challenge evidence in Phase 5

**Likelihood**: Medium
**Impact**: Medium
**Priority**: 🟡 Medium

---

### R4: Complexity

**Risk**: Users find multi-round too complicated

**Mitigation**:
1. ✅ Clear progress indicators
2. ✅ "Quick mode" for simple cases
3. ✅ User guide with examples
4. ✅ Can skip Phase 5 (auto-conclude)

**Likelihood**: Low
**Impact**: Low
**Priority**: 🟢 Low

---

## 8. Success Metrics

### Quantitative

**M1: Time Performance**
- Target: <90s average
- Measurement: Log phase timings

**M2: User Satisfaction**
- Target: 80%+ find it useful
- Measurement: Optional feedback prompt

**M3: Recommendation Quality**
- Target: 85%+ confidence level
- Measurement: Track confidence evolution

### Qualitative

**M4: Depth of Analysis**
- Metric: Number of evidence-backed claims
- Target: 50%+ claims have evidence

**M5: User Engagement**
- Metric: % of sessions with Phase 5 intervention
- Target: 20-30% (indicates useful feature, not overused)

**M6: Refinement Effectiveness**
- Metric: % of opinions that change after challenges
- Target: 30-50% (shows challenges are impactful)

---

## 9. Future Enhancements (Post-v4.0)

### E1: Streaming Output (v4.1)

**Current**: Wait for full round before showing results
**Enhanced**: Stream each agent's response as it arrives

**Benefit**: Feels 2x faster (better UX)
**Time**: 3-4 hours implementation

---

### E2: Caching System (v4.2)

**Current**: Re-run everything for repeat questions
**Enhanced**: Cache Codex responses + WebSearch results

**Benefit**: 26s → 5s for cached questions
**Time**: 2-3 hours implementation

---

### E3: Judgment Agent (v4.3)

**Current**: User evaluates debate quality
**Enhanced**: 3rd agent (Judge) evaluates arguments, scores points

**Benefit**: More objective evaluation
**Time**: 4-5 hours implementation
**Caveat**: Adds another agent (performance hit)

---

### E4: Multi-Agent Expansion (v5.0)

**Current**: 2 agents (Main Claude + Codex)
**Enhanced**: 3+ agents with assigned roles (Optimist, Pessimist, Pragmatist)

**Benefit**: Richer perspectives
**Time**: 1-2 weeks
**Risk**: Complexity explosion

---

## 10. Decision Points

### DP1: Quick Mode Implementation

**Question**: Implement quick mode in v4.0 or defer to v4.1?

**Options**:
- A: Include in v4.0 (adds 1 hour, provides flexibility)
- B: Defer to v4.1 (ship faster, add if users request)

**Recommendation**: **Option A** - Quick mode is low-cost, high-value

---

### DP2: WebSearch Integration Scope

**Question**: Which evidence types to support?

**Options**:
- A: Any web search (broad, may return noise)
- B: Curated sources only (Stack Overflow, official docs, research papers)
- C: Both (flag for "trusted sources only" mode)

**Recommendation**: **Option A for v4.0** (simplicity), Option C for v4.1

---

### DP3: User Intervention Frequency

**Question**: How often to prompt user?

**Options**:
- A: After every round (max control, may be annoying)
- B: After Round 2 only (balanced)
- C: User-initiated (flag to enable intervention)

**Recommendation**: **Option B** - One intervention point (Phase 5)

---

## 11. Open Questions

**Q1**: Should we support "devil's advocate" mode where one agent intentionally takes opposing stance?
- **Status**: ⏳ TBD, discuss with user

**Q2**: Maximum number of rounds?
- **Current**: 3 (Round 1: opinions, Round 2: challenges, Round 3: evidence)
- **Alternative**: Allow 4-5 if user keeps requesting deep dives
- **Status**: ✅ Cap at 3 for v4.0

**Q3**: How to handle unanimous agreement?
- **Scenario**: Both agents agree completely in Round 1
- **Options**:
  - Skip Phase 3-4 (no challenges needed)
  - Force dissent ("find at least one concern")
- **Status**: ⏳ TBD, likely skip to Phase 6

**Q4**: Evidence source whitelist?
- **Status**: ⏳ v4.1 feature, not v4.0

---

## 12. Approval Checklist

Before implementation begins, confirm:

- [ ] User approves overall architecture (Phase 3-6 design)
- [ ] User approves time budget (56-186s acceptable)
- [ ] User approves challenge structure (✅⚠️❌📊 format)
- [ ] User approves WebSearch integration scope
- [ ] User approves intervention point (Phase 5)
- [ ] Decision made on Quick Mode (DP1)
- [ ] Decision made on Evidence scope (DP2)
- [ ] Decision made on Intervention frequency (DP3)

**Next Step After Approval**: Begin Phase 1 implementation (Week 1 tasks)

---

## Appendix A: Example Session (Full)

**User**: AI 토론: Django vs FastAPI for REST API (5 devs, 10k users, 3 months)

### Phase 1: Clarification
```
[Skipped - question already clear]
```

### Phase 2: Round 1
```
Main Claude Opinion: Django (stability, ecosystem, 3-month timeline critical)
Codex Opinion: FastAPI (performance, modern async, type safety)
[26s]
```

### Phase 3: Round 2 - Challenge
```
Main Claude → Codex:
✅ Strengths: Correct on performance, async advantages valid
⚠️ Questions: What about team's async experience? Migration path from Django later?
❌ Weak spots: "Modern" ≠ "better" for this timeline, ecosystem still immature
📊 Evidence: Need benchmarks for 10k DAU (not concurrent)

Codex → Main Claude:
✅ Strengths: Timeline concern valid, DRF is proven
⚠️ Questions: Django 4.1 async views - why not leverage those?
❌ Weak spots: "Stability" argument weak - FastAPI is 4 years old, battle-tested
📊 Evidence: Need data on FastAPI adoption in production

[30s parallel]
```

### Phase 4: Round 3 - Evidence
```
Main Claude Response:
📊 WebSearch: "FastAPI production adoption"
   - Used by Microsoft, Uber, Netflix [Source: fastapi.tiangolo.com]
   - ✅ Acknowledged: More battle-tested than I thought
   - Refined: Django still safer for 3-month timeline IF team lacks async exp

Codex Response:
📊 WebSearch: "Django REST Framework vs FastAPI benchmark"
   - DRF: 5k req/s, FastAPI: 25k req/s [Source: techempower.com]
   - ✅ Acknowledged: Performance gap is real
   - Refined: BUT at 10k DAU, both handle load fine. Performance not deciding factor here.

[40s with WebSearch]
```

### Phase 5: User Intervention
```
💬 Debate Summary:
- Round 1: Django (stable) vs FastAPI (fast)
- Round 2: Challenges on maturity, timeline, performance relevance
- Round 3: Evidence shows FastAPI is production-ready, performance overkill at this scale

Unresolved:
⚠️ Team's async/await experience level

What would you like to do?
1. Deep dive: Team skillset analysis
2. Add constraint: [e.g., "Team lead has FastAPI exp"]
3. Conclude with current analysis

User selects: "Add constraint: Team lead has FastAPI experience, can mentor team"

[+10s user input]
```

### Phase 6: Final Synthesis
```
## Final Recommendation

**Decision**: FastAPI

**Reasoning**:
- Team lead mentorship mitigates learning curve risk (Main Claude's concern)
- Performance advantage exists but not critical at 10k DAU (Codex's point refined)
- Modern async patterns benefit long-term if growth continues (Codex's strength)
- 3-month timeline feasible with mentorship (Main Claude's concern addressed)

**Confidence**: High (85%)
- Increased from Medium (60%) after:
  - Evidence on FastAPI production use
  - User clarification on team lead expertise

**Next Steps**:
1. Allocate 1 week for async/await training (team lead leads)
2. Start with simple CRUD endpoints (familiar patterns)
3. Benchmark at 5k users, validate performance assumptions
4. Document async patterns for team consistency

**Trade-offs Acknowledged**:
- Smaller ecosystem vs Django (accepted risk)
- Newer patterns (mitigated by mentorship)
- Less "just works" magic (team must understand async)

[2s]
```

**Total Time**: 26 + 30 + 40 + 10 + 2 = **108s** (1m 48s)

---

## Appendix B: Quick Mode Example

**User**: AI 토론 --quick: Should I use Redis or Memcached?

```
[Skips Phase 3-5]

Phase 2: Round 1 (26s)
Phase 6: Basic synthesis (2s)

Result: "Redis recommended (richer data types, persistence)"
Total: 28s (minimal overhead)
```

---

## Document History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 0.1 | 2025-11-04 | Initial draft | Claude Code |
| 0.2 | 2025-11-04 | Added user requirements from /clarify | Claude Code |
| 1.0 | 2025-11-04 | Complete design document | Claude Code |

**Status**: 📋 Awaiting User Approval

**Next Step**: Review with user, address open questions, obtain approval for implementation.
