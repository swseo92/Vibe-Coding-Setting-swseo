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
