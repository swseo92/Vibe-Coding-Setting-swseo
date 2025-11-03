---
name: ai-collaborative-solver-v2.0
description: AI debate skill with pre-clarification. Use when users request "AI 토론", "AI debate", or technical comparisons. V2.0 focuses on clarification quality first.
---

# AI Collaborative Solver V2.0

**Phase 1: Pre-Clarification Only**

---

## When to Use

Trigger when users request:
- "AI 토론" / "AI debate"
- "토론해서" / "debate"
- Technical comparisons ("Django vs FastAPI")
- Architecture decisions
- Performance optimization advice

---

## How to Activate

**Step 1: Always Start with Pre-Clarification**

Before doing anything else, gather context from the user.

### If Information is Missing

Ask 2-3 clarifying questions:

**Template:**
```
AI 토론을 위해 몇 가지 확인하고 싶습니다:

1. [Tech stack / versions]
2. [Timeline / budget / team constraints]
3. [Goals / success criteria]
```

**Example:**
```
User: "Django vs FastAPI 선택 고민"

You: "AI 토론을 위해 몇 가지 확인하고 싶습니다:

1. 프로젝트 규모와 유형은? (팀 크기, 예상 사용자 수)
2. 팀의 기술 스택 경험은? (Python 수준, 프레임워크 경험)
3. 주요 우선순위는? (개발 속도, 성능, 학습곡선 중 중요한 것)"
```

### If Information is Complete

Show understanding summary and confirm:

**Template:**
```
📋 **제 이해:**
- [Main problem/goal]

🎯 **파악한 제약사항:**
- [Constraint 1]
- [Constraint 2]

🔍 **전제 조건:**
- [Assumption 1]

맞나요? 추가하거나 수정할 내용이 있나요?
```

**Example:**
```
User: "Django 4.2 + PostgreSQL 14 성능 개선 (2초→500ms, 1주일, DBA 없음)"

You: "📋 **제 이해:**
- Django 4.2 API 응답시간을 2초에서 500ms로 개선

🎯 **파악한 제약사항:**
- 기한: 1주일
- 인력: DBA 없음 (개발자 수준 최적화만 가능)
- 기술: Django 4.2, PostgreSQL 14

🔍 **전제 조건:**
- ORM N+1 쿼리 문제 가능성
- 코드 레벨 최적화 위주
- 인프라 변경 범위 제한적

맞나요? 추가하거나 수정할 내용이 있나요?"
```

---

## Step 2: After Clarification - Execute Debate

After clarification is complete and user confirms, proceed to **Phase 2: Independent Opinion Collection**.

### Phase 2: Independent Opinion Collection (Optimized)

**New approach:** You (main Claude) generate your own opinion first, then collect Codex's independent opinion. This eliminates the 34-second overhead of spawning a separate Claude Code session.

#### 2.1 Generate Your Own Independent Opinion

**CRITICAL:** Generate your analysis BEFORE calling Codex. This ensures independence.

Using the clarified context from Phase 1, provide your independent analysis:

**Your Analysis Structure:**
```markdown
## Claude Code Analysis

### Key Points (3-5 main insights)
[Your key insights based on the clarified question and context]

### Pros (advantages/supporting arguments)
- [Pro 1 with reasoning]
- [Pro 2 with reasoning]
- [Pro 3 with reasoning]

### Cons (disadvantages/opposing arguments)
- [Con 1 with reasoning]
- [Con 2 with reasoning]
- [Con 3 with reasoning]

### Recommendation
[Your conclusion with clear reasoning]
```

**Important notes:**
- Be specific and objective
- Base analysis on the clarified constraints from Phase 1
- Don't wait for Codex's opinion - generate yours independently first
- Save your analysis to a variable or session output directory

#### 2.2 Collect Codex Opinion (Single Agent)

Now execute Codex to get an independent second opinion:

```bash
# Get script path
SCRIPTS_DIR="$HOME/.claude/skills/ai-collaborative-solver-v2.0/scripts"

# Build prompt for Codex with full context
CODEX_PROMPT="You are an independent expert analyst. You have NOT seen any other AI's opinion yet.

## Clarified Question
[Insert question from Phase 1]

## Context & Constraints
[Insert all gathered context from Phase 1]

## Your Task
Provide your independent analysis:

1. **Key Points** (3-5 main insights)
2. **Pros** (advantages/supporting arguments)
3. **Cons** (disadvantages/opposing arguments)
4. **Recommendation** (your conclusion with reasoning)

Be specific and provide clear reasoning for each point."

# Execute Codex only (fast, no file creation)
CODEX_OPINION=$(bash "$SCRIPTS_DIR/codex-session.sh" new "$CODEX_PROMPT" --stdout-only --quiet 2>&1)

echo "Codex opinion collected successfully"
```

**Performance improvements vs old approach:**
- **Old:** 2 agents in parallel (Codex + Claude Code) = 55s
- **New:** 1 agent only (Codex) = ~13s
- **Speedup:** 75% faster! (42 seconds saved)
- No separate Claude Code session spawn overhead
- No file I/O overhead (uses --stdout-only)

#### 2.3 Compare Your Opinion with Codex's Opinion

Now you have two independent opinions:
1. **Your analysis** (from 2.1) - already generated
2. **Codex's opinion** (from 2.2) - captured in `$CODEX_OPINION`

Read both carefully and prepare for synthesis.

#### 2.4 Analyze and Synthesize

**IMPORTANT**: Perform this analysis systematically and objectively. Compare your opinion (from 2.1) with Codex's opinion (from 2.2).

**Step 1: Identify Common Ground**

Review both opinions and extract points of agreement:

```
Action: Read through both opinions carefully
Look for:
  - Similar key points or insights
  - Matching recommendations
  - Shared concerns or priorities
  - Common technical assessments

Example:
Your opinion: "Django provides better admin interface"
Codex opinion: "Django's built-in admin is a major advantage"
→ Common ground: Both agree Django admin is valuable
```

**Step 2: Highlight Differences**

Identify where opinions diverge and understand why:

```
Action: Compare contrasting viewpoints
Look for:
  - Different recommendations
  - Opposing priorities (speed vs stability, etc.)
  - Conflicting technical assessments
  - Different risk evaluations

Example:
Your opinion: "FastAPI is better for this team (async expertise)"
Codex opinion: "Django is better for this team (proven stability)"
→ Difference: Trade-off between modern features vs proven reliability
→ Root cause: Different weighting of team skill vs project risk
```

**Step 3: Extract Unique Insights**

Find what each perspective uniquely contributes:

```
Your unique insights:
  - What did you emphasize that Codex didn't?
  - What angle did you take that's distinctive?
  - Example: "You focused on team morale and modern tech stack appeal"

Codex unique insights:
  - What did Codex highlight that you missed?
  - What novel consideration did Codex raise?
  - Example: "Codex emphasized ecosystem maturity and hiring pool"

Why these insights matter:
  - Unique insights reveal blind spots
  - They enrich the final analysis
  - They show the value of multiple perspectives
```

**Step 4: Synthesize Final Recommendation**

Create a balanced recommendation that considers both perspectives:

```
Process:
1. Count agreement vs disagreement points
   - If 70%+ agreement → High confidence, synthesize toward consensus
   - If 40-70% agreement → Medium confidence, present balanced view
   - If <40% agreement → Low confidence, present options

2. Weight the opinions:
   - If both strongly agree → Strong recommendation
   - If one strong, one weak → Moderate recommendation
   - If both disagree → Present trade-offs, let user decide

3. Address conflicts explicitly:
   - "While [your opinion] suggests X, [Codex] raises concern about Y"
   - "The trade-off is between [benefit A] and [cost B]"
   - "This depends on whether [assumption 1] or [assumption 2] holds"

4. Formulate final recommendation:
   - State clear conclusion
   - Explain reasoning (why this balances both views)
   - Provide confidence level (High/Medium/Low)
   - Give actionable next steps

Example synthesis:
"Given the 3-month timeline and team's lack of async experience, Django
is the safer choice despite FastAPI's performance benefits. While your
analysis correctly identifies FastAPI's modern advantages, Codex's concern
about learning curve risk is more critical given the timeline constraint.
Confidence: High (both agree timeline is tight, prioritize stability)."
```

#### 2.5 Present Results to User

**IMPORTANT**: Format the complete analysis using the template below. Fill each section with content from your Phase 2.4 synthesis.

**How to fill the template:**

**Section 1: Question & Context**
```
1. Question: Copy the clarified question from Phase 1
2. Context Summary: List 3-5 key constraints/requirements
   - Timeline, budget, team size, technical constraints
   - Keep it brief (2-3 sentences max)
```

**Section 2: Independent Opinions**
```
Your Analysis:
  - Copy your complete opinion from Phase 2.1
  - Add "Key Strengths" (2-3 strongest points you made)
  - Example strengths: "Strong emphasis on timeline risk", "Detailed performance analysis"

Codex Analysis:
  - Copy Codex's complete opinion from Phase 2.2
  - Add "Key Strengths" (2-3 strongest points from Codex)
  - Example strengths: "Comprehensive ecosystem assessment", "Practical migration considerations"
```

**Section 3: Synthesis**
```
Areas of Agreement ✅:
  - List all common ground points from Phase 2.4 Step 1
  - Format: Bullet points, 3-5 items
  - Example: "Both agree Django's admin interface is valuable for rapid development"

Areas of Disagreement ⚠️:
  - List all differences from Phase 2.4 Step 2
  - Format: Each disagreement with explanation
  - Example: "Performance: Your analysis prioritizes async capabilities, while Codex emphasizes proven stability"

Unique Insights 💡:
  - Your perspective: From Phase 2.4 Step 3 (your unique insights)
  - Codex perspective: From Phase 2.4 Step 3 (Codex unique insights)
  - Format: 1-2 sentences each
```

**Section 4: Final Recommendation**
```
Recommendation:
  - Use the synthesis from Phase 2.4 Step 4
  - State clear conclusion (1-2 paragraphs)
  - Explain the reasoning

Confidence Level:
  - High: 70%+ agreement, strong consensus
  - Medium: 40-70% agreement, balanced trade-offs
  - Low: <40% agreement, conflicting views

Reasoning:
  - Why this recommendation balances both views (2-3 sentences)
  - Reference specific points from both opinions

Next Steps:
  - 3-5 actionable steps
  - Specific and implementable
  - Example: "1. Set up Django 5.0 project structure", "2. Configure PostgreSQL database"
```

**Complete Output Template:**
```markdown
# AI Debate Results

## Question
[Copy clarified question from Phase 1]

## Context Summary
[List 3-5 key constraints: timeline, team, scale, priorities]

---

## Independent Opinions

### Your Analysis (Claude Code)
[Paste your complete opinion from Phase 2.1]

**Key Strengths:**
- [Strength 1: e.g., "Thorough async performance analysis"]
- [Strength 2: e.g., "Strong focus on team skillset"]

---

### Codex Analysis
[Paste Codex complete opinion from Phase 2.2]

**Key Strengths:**
- [Strength 1: e.g., "Comprehensive ecosystem assessment"]
- [Strength 2: e.g., "Practical migration concerns"]

---

## Synthesis

### Areas of Agreement ✅
[From Phase 2.4 Step 1 - List common ground points]
- [Agreement point 1]
- [Agreement point 2]
- [Agreement point 3]

### Areas of Disagreement ⚠️
[From Phase 2.4 Step 2 - List differences with explanations]
- **[Topic]**: Your view vs Codex view, root cause of difference
- **[Topic]**: Your view vs Codex view, root cause of difference

### Unique Insights 💡
- **Your perspective:** [From Phase 2.4 Step 3 - Your unique angle]
- **Codex's perspective:** [From Phase 2.4 Step 3 - Codex unique insights]

---

## Final Recommendation

[From Phase 2.4 Step 4 - State clear conclusion with reasoning]

**Confidence Level:** [High/Medium/Low]

**Reasoning:** [Explain why this balances both viewpoints, 2-3 sentences]

**Next Steps:**
1. [Specific actionable step]
2. [Specific actionable step]
3. [Specific actionable step]
```

**CRITICAL**: Actually output this formatted markdown to the user. Don't just describe it - present the complete analysis.

---

**🤔 ASK USER: Proceed to deeper analysis?**

Use the AskUserQuestion tool to ask if the user wants Phase 3-4:

```
AskUserQuestion({
  "questions": [{
    "question": "📊 Phase 2 (기본 분석) 완료! 추가로 더 깊은 분석을 진행할까요?",
    "header": "추가 분석",
    "multiSelect": false,
    "options": [
      {
        "label": "예, Phase 3-4 진행",
        "description": "양쪽 의견의 약점 발견, 실제 데이터로 검증, 더 정교한 결론 (추가 40-60초)"
      },
      {
        "label": "아니오, 충분함",
        "description": "현재 분석으로 충분합니다. Phase 2 결과로 결정하겠습니다."
      }
    ]
  }]
})
```

**If user selects "예, Phase 3-4 진행"**: Continue to Phase 3 below.

**If user selects "아니오, 충분함"**: End the debate here. Output a final message:
```
✅ AI 토론 완료! Phase 2 분석 결과를 참고하여 결정하세요.

궁금한 점이 있으면 언제든 추가 질문 주세요! 😊
```

---

### Phase 3: Round 2 - Constructive Challenge (v4.0)

**Objective**: Each agent reviews the other's opinion and provides constructive criticism to identify strengths, weaknesses, and areas needing clarification or evidence.

**IMPORTANT**: This phase enables true debate dynamics - not "rebuttal for rebuttal's sake", but productive challenge that refines thinking and exposes blind spots.

#### 3.1 Main Claude Challenges Codex Opinion

**When to execute**: Only when user selected "예, Phase 3-4 진행" above.

**Your task**: Review Codex's opinion and provide CONSTRUCTIVE challenge.

**Guidelines - Follow this structure exactly**:

```markdown
## Main Claude's Challenge to Codex

✅ **Strengths Acknowledged** (2-3 points)
What did Codex get right? Which arguments are solid and well-reasoned?

1. [Strength 1 - specific point from Codex opinion]
2. [Strength 2 - why this argument is valid]
3. [Strength 3 - technical merit or insight]

⚠️ **Clarifying Questions** (2-3 questions)
NOT rhetorical attacks - genuine gaps in understanding or specification.

1. [Question 1 - about edge case, constraint, or assumption]
   - Context: Why this matters for the decision
   - Example: "You mentioned X, but what about scenario Y?"

2. [Question 2 - about missing consideration]
   - Context: Why this could affect the recommendation

❌ **Weak Spots Identified** (1-3 issues)
Logical inconsistencies, overlooked risks, or unsupported claims.

1. [Issue 1 - what's problematic]
   - Why it's a problem: [logical flaw or missing consideration]
   - Alternative view: [counter-argument or risk]

2. [Issue 2 - if applicable]
   - Impact: [how this affects the conclusion]

📊 **Evidence Requested** (if applicable)
Claims that need data, benchmarks, or case studies to validate.

1. [Claim 1 from Codex] - What evidence would support or refute this?
   - Suggested search: "[benchmark/comparison/case study]"

2. [Claim 2] - What data is needed?
```

**Example**:

```markdown
## Main Claude's Challenge to Codex

✅ **Strengths Acknowledged:**
1. Codex correctly identifies FastAPI's async performance advantage - this is well-documented
2. The point about type safety and modern Python features is valid and important
3. Strong emphasis on developer experience and ecosystem growth is insightful

⚠️ **Clarifying Questions:**
1. You recommend FastAPI for "modern async patterns" - does the team actually have async/await experience?
   - Context: If not, this becomes a learning curve liability in a 3-month timeline

2. You mention "ecosystem maturity" concerns for Django - but isn't Django 15+ years old with massive ecosystem?
   - Clarification needed: Are you referring to async-specific ecosystem?

❌ **Weak Spots Identified:**
1. **Performance claim oversimplified**
   - You cite "5x faster" but at 10k DAU (daily active users), not concurrent users
   - Impact: At this scale, both frameworks handle load fine - performance difference may not matter

2. **Learning curve minimized**
   - FastAPI + async + Pydantic + SQLAlchemy is 4 new concepts for a team used to Django
   - Risk: 3-month timeline is tight for learning + building

📊 **Evidence Requested:**
1. "FastAPI is 5x faster" - need benchmark at 10k concurrent (not just req/s tests)
   - Suggested search: "FastAPI vs Django benchmark 10000 concurrent users real-world"

2. "Smaller ecosystem" concern - quantify: how many fewer libraries/integrations?
   - Suggested search: "Django REST Framework packages vs FastAPI ecosystem 2024"
```

**Execution**:
You don't need to call any script - you are Main Claude, so analyze and write directly.

---

#### 3.2 Codex Challenges Main Claude Opinion

**When to execute**: In parallel with 3.1 (or immediately after), to get Codex's perspective on your opinion.

**How to execute**: Use codex-session.sh with challenge prompt.

**Command**:

```bash
SCRIPTS_DIR="$HOME/.claude/skills/ai-collaborative-solver-v2.0/scripts"

# Build challenge prompt for Codex
CODEX_CHALLENGE_PROMPT="You are reviewing Main Claude's technical opinion and providing constructive challenge.

**CRITICAL**: Follow this EXACT structure. Use these emoji markers:
✅ Strengths Acknowledged (2-3 points)
⚠️ Clarifying Questions (2-3 questions)
❌ Weak Spots Identified (1-3 issues)
📊 Evidence Requested (if applicable)

## Context
Question: [Insert clarified question from Phase 1]
Constraints: [Insert key constraints]

## Main Claude's Opinion
[Paste your complete Phase 2.1 opinion here]

## Your Task
Provide constructive challenge following the structure above:

1. ✅ **Strengths**: What did Main Claude get right? (2-3 specific points)

2. ⚠️ **Questions**: Genuine gaps or missing considerations (2-3 questions with context)

3. ❌ **Weak Spots**: Logical flaws, overlooked risks, unsupported claims (1-3 issues with impact)

4. 📊 **Evidence Requested**: Claims needing data/benchmarks (if any)

Be specific, constructive, and focus on improving the final recommendation."

# Execute Codex challenge (parallel with your challenge, or sequential)
CODEX_CHALLENGE=$(bash "$SCRIPTS_DIR/codex-session.sh" new "$CODEX_CHALLENGE_PROMPT" --stdout-only --quiet 2>&1)

echo "Codex challenge collected successfully"
```

**Performance**:
- Phase 3.1 (your challenge): ~5-10s (text generation)
- Phase 3.2 (Codex challenge): ~15-20s (API call)
- **Total if parallel**: ~20s (overlapped)
- **Total if sequential**: ~25-30s

**Note**: For v4.0, run sequentially (simpler). For v4.1+, optimize with parallel execution.

---

#### 3.3 Review Challenges

Now you have:
1. **Your challenge to Codex** (from 3.1)
2. **Codex's challenge to you** (from 3.2)

Read both challenges carefully. These will be addressed in Phase 4.

**Quick sanity check**:
- Are the challenges constructive, not adversarial?
- Do they ask genuine questions (not rhetorical)?
- Do they identify real weaknesses (not nitpicking)?
- Is evidence requested for claims (not trivial points)?

If challenges seem unproductive or generic, you may need to refine the prompts in future iterations.

**Proceed to Phase 4**: Evidence-Based Refinement

---

### Phase 4: Round 3 - Evidence-Based Refinement (v4.0)

**Objective**: Respond to challenges from Phase 3, provide evidence for claims, acknowledge valid criticisms, and refine original positions.

**IMPORTANT**: This phase transforms debate into collaborative improvement - not defending positions, but finding truth through evidence and reasoning.

#### 4.1 Main Claude Responds to Codex's Challenge

**Input**: Codex's challenge to your opinion (from Phase 3.2)

**Your task**: Address each section of Codex's challenge systematically.

**Response Structure**:

```markdown
## Main Claude's Response to Codex's Challenge

### Addressing Questions

**Q1: [Codex's question]**
A: [Your answer OR "Valid point - I don't have enough information. This needs clarification from user."]

**Q2: [Codex's question]**
A: [Your answer with reasoning]

### Addressing Weak Spots

**Issue 1: [Codex identified issue]**
✅ **Acknowledged** OR ⚠️ **Counter-argument**

If acknowledged:
- Why it's valid: [explain]
- How it changes view: [updated position]

If counter-argument:
- Why the criticism doesn't hold: [reasoning]
- Supporting evidence: [if available]

**Issue 2: [If applicable]**
[Same structure]

### Evidence Gathering

**Claim 1: [Codex requested evidence for]**
🔍 **Evidence Search**: [If needed, use WebSearch tool]
📊 **Found**:
- [Evidence source 1]: [Summary]
- [Evidence source 2]: [Summary]
✅ **Conclusion**: [How evidence supports/refutes claim]

**Claim 2: [If applicable]**
[Same structure]

### Updated Position

**Original**: [Your Phase 2.1 recommendation]
**After addressing challenges**: [Refined recommendation]
**Changes**:
- [What changed and why]
- [What remains the same]

**Confidence**: [Original level] → [New level] (Higher/Same/Lower)
**Reasoning**: [Why confidence changed or stayed]
```

**WebSearch Integration**:

When Codex requests evidence, use the WebSearch tool:

```
If challenge includes "📊 Evidence Requested", determine what to search:

Example:
Codex asks: "Need benchmark for FastAPI vs Django at 10k concurrent users"

Action:
1. Use WebSearch tool with query: "FastAPI Django benchmark 10000 concurrent users performance"
2. Review top 3 results
3. Summarize findings with sources

Format:
🔍 **Evidence Search**: "FastAPI Django benchmark 10k concurrent"
📊 **Found**:
- TechEmpower Benchmarks (techempower.com): FastAPI 25k req/s, Django 5k req/s
- Real Python article (realpython.com): "At 10k DAU, both handle load fine"
- Stack Overflow discussion: "Performance difference negligible at <50k concurrent"

✅ **Conclusion**: Codex was correct on raw performance (5x faster), but at 10k DAU scale, difference is not a deciding factor. Both frameworks sufficient.
```

**Example Response**:

```markdown
## Main Claude's Response to Codex's Challenge

### Addressing Questions

**Q1: Does the team actually have async/await experience?**
A: ✅ **Valid point** - I assumed team Python experience = async experience. This needs user clarification.
   - If NO async experience → Django safer (Codex concern justified)
   - If YES async experience → FastAPI feasible

**Critical follow-up**: User, does your team have async/await experience in Python?

**Q2: "Ecosystem maturity" concern - clarify async-specific or general?**
A: You're right to push back. Django has massive ecosystem overall. I meant async-specific ecosystem (e.g., async-compatible libraries). Updated: "Django's async ecosystem is less mature than FastAPI's, but sync ecosystem is larger."

### Addressing Weak Spots

**Issue 1: Performance claim oversimplified (10k DAU vs concurrent)**
✅ **Acknowledged**: You're absolutely correct.

🔍 **Evidence Search**: "FastAPI Django 10k daily active users"
📊 **Found**:
- TechEmpower: FastAPI 25k req/s vs Django 5k req/s (raw benchmarks)
- Real Python: "At 10k DAU (~500 concurrent), both handle easily"

✅ **Refined**: Performance advantage exists but NOT critical at this scale. Both sufficient for 10k DAU.

**Issue 2: Learning curve minimized**
⚠️ **Partially acknowledged**:
- True: FastAPI + async + Pydantic is 3 new concepts
- But: If team already knows SQLAlchemy, only 2 new concepts
- Counter: Django + DRF also has learning curve (serializers, viewsets, etc.)

📊 **Evidence**:
- FastAPI tutorial: ~3 days for basic CRUD (official docs)
- DRF tutorial: ~2 days for basic CRUD (official docs)

✅ **Refined**: Learning curves comparable (FastAPI: 3 days, DRF: 2 days). 3-month timeline accommodates either.

### Evidence Gathering

**Claim: "Smaller ecosystem"**
🔍 **Evidence Search**: "Django REST Framework vs FastAPI ecosystem size 2024"
📊 **Found**:
- Django packages: 4,000+ on djangopackages.org
- FastAPI integrations: 500+ on awesome-fastapi GitHub
- But: FastAPI uses standard Python libs (not framework-specific)

✅ **Conclusion**: Django has 8x more framework-specific packages, but FastAPI leverages broader Python ecosystem. "Smaller" is context-dependent.

### Updated Position

**Original**: Django recommended (emphasis on stability + timeline)
**After addressing challenges**:
- IF team lacks async experience → Django (Codex point valid)
- IF team has async experience → FastAPI feasible

**Changes**:
- Added conditional: async experience is decisive factor
- Performance argument weakened (not critical at 10k DAU)
- Learning curve reassessed (comparable, not blocking)

**Confidence**: Medium (60%) → Medium-High (70%)
**Reasoning**: Codex challenges refined analysis, but added conditionality rather than changing core recommendation.
```

---

#### 4.2 Codex Responds to Main Claude's Challenge

**When to execute**: In parallel with 4.1 (or sequentially)

**How to execute**: Use codex-session.sh with response prompt

**Command**:

```bash
SCRIPTS_DIR="$HOME/.claude/skills/ai-collaborative-solver-v2.0/scripts"

# Build response prompt for Codex
CODEX_RESPONSE_PROMPT="You received constructive challenge from Main Claude. Now respond systematically.

**CRITICAL**: Follow this structure:

## Codex's Response to Main Claude's Challenge

### Addressing Questions
[Answer each question Main Claude raised]

### Addressing Weak Spots
[For each issue: Acknowledge OR provide counter-argument]

### Evidence Gathering
[If Main Claude requested evidence, provide it with sources]

### Updated Position
[Original → Refined recommendation, confidence change]

---

## Context
Question: [Insert original question]
Constraints: [Insert key constraints]

## Your Original Opinion
[Paste Codex Phase 2.2 opinion]

## Main Claude's Challenge to You
[Paste Main Claude's Phase 3.1 challenge]

---

## Your Task

Respond to Main Claude's challenge following the structure above:

1. **Addressing Questions**: Answer each question or admit uncertainty
2. **Addressing Weak Spots**: Acknowledge valid points OR explain why criticism doesn't hold
3. **Evidence Gathering**: If evidence was requested, provide:
   - Search query used (if WebSearch available)
   - Findings with sources
   - How evidence affects your position
4. **Updated Position**: Refine recommendation based on challenges
   - What changed
   - Confidence evolution

Be honest: if Main Claude exposed a real gap, acknowledge it and update your view."

# Execute Codex response
CODEX_RESPONSE=$(bash "$SCRIPTS_DIR/codex-session.sh" new "$CODEX_RESPONSE_PROMPT" --stdout-only --quiet 2>&1)

echo "Codex response collected successfully"
```

**Performance**:
- Phase 4.1 (your response): ~10-20s (with WebSearch) or ~5s (no search)
- Phase 4.2 (Codex response): ~15-25s (API call + potential search)
- **Total if parallel**: ~20-30s
- **Total if sequential**: ~30-50s

**Note**: WebSearch may add 10-20s per evidence request. Budget accordingly.

---

#### 4.3 Review Refined Positions

Now you have:
1. **Your refined opinion** (from 4.1) - after addressing Codex challenges
2. **Codex's refined opinion** (from 4.2) - after addressing your challenges

**Quick assessment**:
- Did opinions converge (more agreement now)?
- Did new evidence change recommendations?
- Are there still unresolved differences?
- Is more evidence needed, or is analysis sufficient?

**Decision point**:
- If **converged**: Proceed to Phase 5 (User Intervention) or Phase 6 (Final Synthesis)
- If **still divergent but evidence-backed**: Proceed to Phase 5 for user input
- If **evidence insufficient**: Consider another evidence-gathering round (rare, v4.1+ feature)

**Proceed to Phase 5**: User Intervention Point

---

### Phase 5: Dynamic Q&A + User Intervention (v5.0)

**Objective**: Enable content-driven user participation during debate + provide multi-round control after Phase 4

**IMPORTANT**: This phase has TWO distinct components that work together:
1. **Dynamic Q&A** (Throughout phases 2-4): Ask user for critical information when needed
2. **User Intervention** (After Phase 4): Let user decide next steps

---

#### 5.1 Dynamic Q&A (Content-Driven Checkpoints)

**When to trigger**: Whenever you encounter uncertainty or need user-specific information during Phase 2-4

**Trigger conditions** (check continuously):

```markdown
**Uncertainty Markers** to watch for:
- "I don't know..."
- "It depends on..."
- "Assuming that..."
- "If the team has..."
- "Unclear whether..."

**When detected**: Immediately pause and ask user for clarification
```

**How to ask** (use AskUserQuestion tool):

```
**Pattern:**

[You detect uncertainty in your analysis]
"I notice that [specific aspect] is unclear. Let me ask the user."

AskUserQuestion({
  "questions": [{
    "question": "[Clear, specific question about the uncertainty]",
    "header": "[Short label, 8-12 chars]",
    "multiSelect": false,
    "options": [
      {"label": "[Option 1]", "description": "[What this means]"},
      {"label": "[Option 2]", "description": "[What this means]"},
      {"label": "[Option 3]", "description": "[What this means]"}
    ]
  }]
})

[After receiving answer]
"Thank you! Based on [user answer], I can now [adjust analysis]..."
```

---

**Example 1: Phase 2 - Team Experience Uncertainty**

```markdown
### Your Analysis (Phase 2.1)

While generating opinion:
"FastAPI is great for async workloads, but **I don't know if the team has async/await experience**..."

[Pause and Ask]
❓ AskUserQuestion({
  "question": "Does your team have Python async/await experience?",
  "header": "Async exp",
  "options": [
    {"label": "Yes (1+ year)", "description": "Production experience with async code"},
    {"label": "Some (tutorials)", "description": "Basic understanding, no production use"},
    {"label": "None", "description": "Never used async/await"}
  ]
})

[User answers: "None"]

✅ "Thank you! Since team has NO async experience, I'll adjust my recommendation:
- FastAPI's async benefits are offset by learning curve
- Django's synchronous model is safer for your team"

[Continue with enriched context]
```

---

**Example 2: Phase 3 - Challenge Based on Missing Info**

```markdown
### Phase 3.1 Challenge

Codex mentioned:
"Team should be able to handle Django Channels complexity"

[You detect assumption]
"Codex is **assuming WebSocket experience**, but I'm not sure..."

[Pause and Ask]
❓ AskUserQuestion({
  "question": "Does your team have real-time communication (WebSocket, SSE) experience?",
  "header": "Realtime exp",
  "options": [
    {"label": "Yes (production)", "description": "Built production WebSocket/SSE apps"},
    {"label": "Yes (prototypes)", "description": "Experimented but not in production"},
    {"label": "No", "description": "No real-time experience"}
  ]
})

[User answers: "No"]

✅ "Thank you! This is important for the challenge:

**Challenge to Codex**:
❌ Weak Spot: You assumed WebSocket experience, but team has NONE.
- Django Channels learning curve: 2-3 weeks
- This significantly impacts the recommendation"

[Continue Phase 3 with real context]
```

---

**Example 3: Phase 4 - Evidence Validation**

```markdown
### Phase 4.1 Evidence Gathering

🔍 WebSearch: "Django Channels learning curve"
📊 Found: "Average learning time: 2-3 weeks for experienced Django developers"

[You need context to interpret this]
"Is 2-3 weeks acceptable for this project's timeline?"

[Pause and Ask]
❓ AskUserQuestion({
  "question": "Your project timeline is 3 months. Is 2-3 weeks for Channels learning acceptable?",
  "header": "Timeline fit",
  "options": [
    {"label": "Yes, fine", "description": "We have buffer time"},
    {"label": "Tight", "description": "Doable but risky"},
    {"label": "Too risky", "description": "Can't afford this delay"}
  ]
})

[User answers: "Too risky"]

✅ "Thank you! This changes the recommendation:

**Evidence Conclusion**:
❌ 2-3 weeks learning is TOO RISKY for your 3-month timeline
→ FastAPI WebSocket (1 week learning) is safer choice
→ Confidence adjustment: Django 90% → 60%, FastAPI 10% → 40%"

[Continue with adjusted view]
```

---

**Example 4: Priority Clarification**

```markdown
### Phase 2 Synthesis

"There's a trade-off: FastAPI is faster (5x) but Django is more productive (2x faster dev)"

[Need user priority]
"Which is more important depends on user's priorities..."

[Pause and Ask]
❓ AskUserQuestion({
  "question": "For this project, which is more critical?",
  "header": "Priority",
  "options": [
    {"label": "Performance", "description": "Response speed is top priority"},
    {"label": "Speed to market", "description": "Fast development & launch"},
    {"label": "Balance", "description": "Both are important"}
  ]
})

[User answers: "Speed to market"]

✅ "Thank you! With speed-to-market as priority:
- Django's productivity advantage is MORE valuable
- FastAPI's performance edge is LESS critical
→ Stronger Django recommendation (90% → 95%)"

[Adjust synthesis accordingly]
```

---

#### 5.2 User Intervention Point (After Phase 4)

**When to execute**: After Phase 4.3 (Review Refined Positions) completes

**Purpose**: Let user decide whether to:
- Conclude debate (proceed to Phase 6)
- Dig deeper on specific point (repeat Phase 3-4)
- Add new constraints (restart from Phase 1)

---

**Step 1: Summarize Current State**

```markdown
## 📊 Phase 4 Complete - Debate Summary

**Original Question**: [Phase 1 question]

**Round 1 (Phase 2)**:
- Your initial view: [Summary]
- Codex initial view: [Summary]
- Agreement level: [X%]

**Round 2 (Phase 3-4)**:
- Key challenges raised: [2-3 bullets]
- Evidence gathered: [2-3 bullets]
- Confidence changes:
  - Your view: [Original X%] → [New Y%]
  - Codex view: [Original X%] → [New Y%]

**Current Recommendation**: [Which option, confidence level]

**Key Insights Discovered**:
1. [Insight 1]
2. [Insight 2]
3. [Insight 3]
```

---

**Step 2: Ask User What to Do Next**

```
AskUserQuestion({
  "questions": [{
    "question": "How would you like to proceed?",
    "header": "Next step",
    "multiSelect": false,
    "options": [
      {
        "label": "Conclude debate",
        "description": "Current analysis is sufficient. Generate final recommendation (Phase 6)"
      },
      {
        "label": "Dig deeper",
        "description": "Focus on specific aspect with another evidence-gathering round"
      },
      {
        "label": "Add constraint",
        "description": "I have new requirements. Let's restart with updated context"
      }
    ]
  }]
})
```

---

**Step 3: Handle User Choice**

**Option A: "Conclude debate"**
```markdown
✅ User chose to conclude.

Proceeding to Phase 6: Final Synthesis...
```
→ Go to Phase 6

---

**Option B: "Dig deeper"**
```markdown
✅ User wants to dig deeper.

Ask which aspect to focus on:

AskUserQuestion({
  "question": "Which aspect should we investigate more deeply?",
  "options": [
    {"label": "[Aspect 1]", "description": "[Why this matters]"},
    {"label": "[Aspect 2]", "description": "[Why this matters]"},
    {"label": "Other", "description": "Specify custom aspect"}
  ]
})

[After user selects aspect]

**Focused Analysis Round 2**:
1. Reformulate challenges focusing on [selected aspect]
2. Gather MORE evidence on [selected aspect]
3. Return to Phase 3 with narrowed focus

[Execute Phase 3-4 again with focused scope]
→ After completion, return to Phase 5.2 (this step) for next decision
```

---

**Option C: "Add constraint"**
```markdown
✅ User has new constraints.

Ask what changed:

AskUserQuestion({
  "question": "What new constraint or requirement should we consider?",
  "options": [
    {"label": "Timeline changed", "description": "Deadline moved"},
    {"label": "Budget constraint", "description": "Cost became factor"},
    {"label": "Team changed", "description": "Team size/experience shifted"},
    {"label": "New requirement", "description": "Feature/requirement added"},
    {"label": "Other", "description": "Different constraint"}
  ]
})

[After user explains new constraint]

✅ "Thank you! Let's restart analysis with this new constraint..."

**Restart from Phase 1**:
1. Incorporate new constraint into clarification
2. Re-run Phase 2-4 with updated context
3. Compare new results with previous round

→ Execute Phase 1 again with [original context + new constraint]
→ Track this as "Round 2" in Phase 6 history
```

---

#### 5.3 Round Tracking (for Phase 6)

**IMPORTANT**: Track all debate rounds for Phase 6 synthesis

```markdown
**Round History** (internal tracking):

Round 1:
- Phase 2 opinions: [Your X%, Codex Y%]
- Phase 3 challenges: [Summary]
- Phase 4 evidence: [Summary]
- Confidence after: [Your A%, Codex B%]
- User decision: [Dig deeper on Z aspect]

Round 2 (if user chose "Dig deeper" or "Add constraint"):
- Focus: [Specific aspect OR new constraint]
- Phase 2 (re-run): [Updated opinions]
- Phase 3-4 (focused): [Focused analysis]
- Confidence after: [Your C%, Codex D%]
- User decision: [Conclude OR dig more]

... (continue if more rounds)
```

This history will feed into Phase 6 for comprehensive synthesis.

---

### Phase 6: Multi-round Final Synthesis (v5.0)

**Objective**: Integrate ALL debate rounds into a comprehensive, evidence-backed final recommendation

**When to execute**: After user selects "Conclude debate" in Phase 5.2

---

#### 6.1 Collect Round History

**Step 1: Review all rounds**

```markdown
**Internal Review** (don't output yet):

How many rounds did we complete?
- Round 1: Always present (Phase 2-4 initial)
- Round 2+: Only if user chose "Dig deeper" or "Add constraint"

For each round, what changed?
- Opinion shifts
- New evidence discovered
- Confidence adjustments
- Key insights gained
```

---

#### 6.2 Synthesize Multi-Round Insights

**Step 2: Identify evolution patterns**

```markdown
**Evolution Analysis**:

1. **Confidence Trajectory**:
   - Round 1: Your view [X%], Codex [Y%]
   - Round 2: Your view [A%], Codex [B%]
   - ... (if more rounds)
   - Pattern: [Converging / Diverging / Stable]

2. **Key Insight Accumulation**:
   - Round 1 insights: [List]
   - Round 2 additional insights: [List]
   - Total unique insights: [N]

3. **Evidence Quality**:
   - Round 1 evidence: [Qualitative description]
   - Round 2 evidence: [Did we get better/more specific evidence?]
   - Total evidence strength: [Weak / Moderate / Strong]

4. **Agreement Evolution**:
   - Round 1 agreement: [X%]
   - Round 2 agreement: [Y%]
   - Trend: [Increasing / Decreasing / Fluctuating]
```

---

#### 6.3 Generate Final Output

**Step 3: Present comprehensive final recommendation**

```markdown
# 🎯 Final AI Debate Recommendation

## Question
[Original Phase 1 question]

## Context
[Phase 1 context summary + any constraints added in later rounds]

---

## Multi-Round Debate History

### Round 1: Initial Analysis
**Phase 2 Opinions**:
- Your view: [Framework X] ([confidence]%)
  - Key reasoning: [1-2 sentences]
- Codex view: [Framework Y] ([confidence]%)
  - Key reasoning: [1-2 sentences]
- Agreement: [Z%]

**Phase 3-4 Challenges & Evidence**:
- Challenges raised: [2-3 key challenges]
- Evidence gathered: [2-3 key evidence pieces]
- Confidence after: Your [A%], Codex [B%]

**Key Insights**:
1. [Insight 1 from Round 1]
2. [Insight 2 from Round 1]

---

[If Round 2+ exists]
### Round 2: Deep Dive on [Aspect]
**Focus**: [What we investigated deeper]

**Updated Opinions**:
- Your view: [Change description], confidence [X% → Y%]
- Codex view: [Change description], confidence [X% → Y%]

**Additional Evidence**:
- [New evidence from Round 2]

**New Insights**:
1. [Insight discovered in Round 2]

---

[Repeat for each round]

---

## Confidence Evolution

```
Round 1:  Your [X%] ████████░░  Codex [Y%] ████████░░
Round 2:  Your [A%] ██████████  Codex [B%] ██████░░░░
Final:    Your [C%] ███████████ Codex [D%] ███████░░░
```

**Interpretation**:
- Your confidence [increased/decreased/stable] because [reason]
- Codex confidence [increased/decreased/stable] because [reason]
- Overall agreement [converged/diverged/remained stable]

---

## Final Recommendation

**Winner**: [Framework name]

**Final Confidence**: [X%]

**Reasoning** (synthesizing ALL rounds):
[2-3 paragraphs explaining:
- Why this option after considering ALL evidence
- How insights from multiple rounds support this
- What trade-offs were acknowledged and accepted
- Why alternatives were ruled out]

**Key Decision Factors** (from all rounds):
1. [Factor 1 - why it mattered]
2. [Factor 2 - why it mattered]
3. [Factor 3 - why it mattered]

---

## Implementation Roadmap

**Phase 1 (Weeks 1-2)**:
1. [Specific action based on recommendation]
2. [Specific action]

**Phase 2 (Weeks 3-6)**:
1. [Next steps]
2. [Next steps]

**Phase 3 (Weeks 7-12)**:
1. [Long-term actions]

**Risk Mitigation**:
- Risk 1: [How to handle]
- Risk 2: [How to handle]

---

## What We Learned

**Debate Highlights**:
- [Most surprising finding]
- [Most valuable evidence]
- [Biggest assumption we challenged]

**If You Change Your Mind** (alternative path):
"If [specific condition changes], consider switching to [alternative option] because [reason]"

---

✅ **Debate Complete!**

[Total rounds: N]
[Total time: ~X seconds]
[Evidence pieces reviewed: Y]
[Confidence final: Z%]

**Thank you for using AI Collaborative Debate!** 🎉
```

---

## Phase 5-6 Summary

**Phase 5 adds**:
1. ✅ Dynamic Q&A throughout Phase 2-4 (content-driven)
2. ✅ User intervention point after Phase 4 (process control)
3. ✅ Multi-round capability (dig deeper / add constraints)
4. ✅ Round tracking for Phase 6

**Phase 6 adds**:
1. ✅ Multi-round history integration
2. ✅ Confidence evolution visualization
3. ✅ Comprehensive final synthesis
4. ✅ Implementation roadmap
5. ✅ Learnings summary

**Expected time**:
- Single round (Phase 2-4 only): 56-90s
- With Phase 5-6: +20-30s per round
- Total with 2 rounds: ~120-150s

---

## Best Practices

### ✅ Do's

**Phase 1 (Clarification):**
1. **Always clarify first** - Even if it seems obvious
2. **Use the templates** - Maintains consistency
3. **Wait for user response** - Don't assume or skip
4. **Summarize if info is complete** - Builds trust

**Phase 2 (Debate):**
1. **Generate your opinion FIRST** - Before calling Codex, ensures independence
2. **Include all Phase 1 context** - Pass clarified info to Codex prompt
3. **Use fast mode (--stdout-only --quiet)** - Minimize overhead
4. **Analyze objectively** - Compare your opinion with Codex fairly
5. **Highlight both agreement and disagreement** - Both are valuable

### ❌ Don'ts

**Phase 1 (Clarification):**
1. **Don't skip to debate** - Clarification is mandatory
2. **Don't ask too many questions** - 2-3 max
3. **Don't make assumptions** - Ask or state clearly
4. **Don't proceed without confirmation** - Wait for user "yes"

**Phase 2 (Debate):**
1. **Don't wait for Codex before generating your opinion** - Generate yours first
2. **Don't cherry-pick opinions** - Present both viewpoints fairly
3. **Don't ignore unique insights** - Both perspectives are valuable
4. **Don't skip synthesis** - Users need actionable conclusions

---

## Examples

### Example 1: Minimal Info → Ask Questions

```
User: "Redis vs Memcached"

You: "AI 토론을 위해 몇 가지 확인하고 싶습니다:

1. 주요 사용 목적은? (캐싱, 세션 저장, 메시지 큐 등)
2. 예상 규모는? (초당 요청 수, 데이터 크기)
3. 팀의 운영 경험은? (Redis/Memcached 사용 경험 유무)"

User: "세션 저장용이고, 초당 1000 req, 데이터는 작음. Redis 경험 없음."

You: "감사합니다. 이제 AI 토론을 시작하겠습니다.

먼저 제 분석부터 드리겠습니다...
[Your analysis]

이제 Codex의 독립적인 의견을 수집하겠습니다...
[Calls Codex]

두 의견을 비교 분석한 결과...
[Synthesis]"
```

### Example 2: Complete Info → Confirm Understanding

```
User: "Next.js 14 vs Remix, 5인 팀, React 경험 많음, SEO 중요, 3개월 타임라인"

You: "📋 **제 이해:**
- Next.js 14와 Remix 중 선택

🎯 **파악한 제약사항:**
- 팀: 5명, React 경험 풍부
- 요구사항: SEO 중요
- 기한: 3개월

🔍 **전제 조건:**
- SSR/SSG 필요
- 팀 학습곡선 고려 필요
- 프로덕션 안정성 중요

맞나요?"

User: "네 맞습니다"

You: "좋습니다. 이제 AI 토론을 진행하겠습니다.

## Your Analysis (Claude Code)
[Generate and present your complete analysis]

이제 Codex의 독립적인 의견을 수집하겠습니다...
[Execute Codex]

## Synthesis
[Compare and synthesize both opinions]"
```

---

## Testing & Validation

### Phase 1 (Clarification) - ✅ Complete

**Success Criteria:**
- [x] Consistently detects when clarification is needed
- [x] Asks appropriate 2-3 questions
- [x] Shows understanding summary when info is complete
- [x] Waits for user confirmation
- [x] No errors or confusion in flow

### Phase 2 (Debate) - ✅ Complete

**Success Criteria:**
- [x] Main Claude generates independent opinion first (Phase 2.1)
- [x] Successfully launches Codex session (Phase 2.2)
- [x] Codex opinion is properly collected (Phase 2.3)
- [x] Synthesis identifies agreement/disagreement correctly (Phase 2.4 - ✅ Implemented)
- [x] Output is clear and actionable (Phase 2.5 - ✅ Implemented)

**Implementation Status:**
- Phase 2.1-2.3: ✅ Complete (opinion collection)
- Phase 2.4: ✅ Complete (4-step synthesis with concrete instructions)
- Phase 2.5: ✅ Complete (structured output template with fill instructions)

**Performance:**
- Old v2.0: 54s (2 agents in parallel)
- New v3.1: ~26s (Main Claude + Codex, with synthesis)
- Improvement: 52% faster!

---

## Bundled Scripts

This skill includes helper scripts in the `scripts/` directory:

### Session Manager (Active)
- **`codex-session.sh`** - Manages stateful Codex CLI sessions
  - Supports `--stdout-only --quiet` for fast, minimal-overhead execution
  - API: `new`, `continue`, `info`, `list`, `clean`
  - Used by main Claude to collect Codex's independent opinion

### Legacy Scripts (Not Used in v3.0)
- **`claude-code-session.sh`** - Previously used for spawning separate Claude sessions (removed in v3.0 for performance)
- **`gemini-cli-session.sh`** - Previously used for 3-agent debates (removed due to reliability issues)
- **`collect-opinions.sh`** - Old parallel orchestrator (replaced by direct main Claude opinion generation)

**Usage**: Only `codex-session.sh` is actively used in Phase 2.2. Main Claude generates its own opinion directly without spawning a separate session.

---

**Version:** 3.1.0-complete
**Status:** ✅ All Phases Complete (Phase 1 + Phase 2.1-2.5)
**Features:**
- Phase 1: Pre-Clarification (ensures context quality)
- Phase 2.1-2.3: Independent opinion collection (Main Claude + Codex)
- Phase 2.4: 4-step systematic synthesis (common ground, differences, unique insights, recommendation)
- Phase 2.5: Structured markdown output (complete debate summary)
**Opinions:** Main Claude (self-generated) + Codex (via script)
**Performance:** ~26s total execution time (52% faster than v2.0, includes synthesis)
**Created:** 2025-11-02
**Updated:** 2025-11-04 (v3.1: Implemented Phase 2.4-2.5 with concrete synthesis instructions)
