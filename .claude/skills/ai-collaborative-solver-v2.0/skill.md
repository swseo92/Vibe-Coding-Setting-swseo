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

### Phase 2: Independent Opinion Collection

Execute parallel debate with 2 AI agents (Codex, Claude Code) to get unbiased independent opinions.

#### 2.1 Build Independent Analysis Prompt

Create a structured prompt that includes:
- The clarified question
- All gathered context (constraints, assumptions, requirements)
- Clear instruction for independent analysis

**Prompt Template:**
```
You are an independent expert analyst. You have NOT seen any other AI's opinion yet.

## Clarified Question
[Question from Phase 1]

## Context & Constraints
[All gathered information from Phase 1]

## Your Task
Provide your independent analysis:

1. **Key Points** (3-5 main insights)
2. **Pros** (advantages/supporting arguments)
3. **Cons** (disadvantages/opposing arguments)
4. **Recommendation** (your conclusion with reasoning)

Be specific and provide clear reasoning for each point.
```

#### 2.2 Execute Parallel Collection

Use the bundled `collect-opinions.sh` helper script that manages everything:

```bash
# Get script path
SCRIPTS_DIR="$HOME/.claude/skills/ai-collaborative-solver-v2.0/scripts"

# Execute parallel collection (all-in-one)
RESULT=$(bash "$SCRIPTS_DIR/collect-opinions.sh" "$PROMPT")

# Parse results
SESSION_OUTPUT=$(echo "$RESULT" | grep "SESSION_OUTPUT=" | cut -d= -f2)
CODEX_SESSION=$(echo "$RESULT" | grep "CODEX_SESSION=" | cut -d= -f2)
CLAUDE_SESSION=$(echo "$RESULT" | grep "CLAUDE_SESSION=" | cut -d= -f2)
GEMINI_SESSION=$(echo "$RESULT" | grep "GEMINI_SESSION=" | cut -d= -f2)
SUCCESS_COUNT=$(echo "$RESULT" | grep "SUCCESS_COUNT=" | cut -d= -f2)

echo "Collection complete: $SUCCESS_COUNT/3 agents succeeded"
echo "Results saved to: $SESSION_OUTPUT"
```

**What the helper script does:**
- Launches Codex and Claude Code in parallel (fast mode)
- Each agent runs with `--stdout-only --quiet` (no intermediate files)
- Waits for both to complete
- Outputs directly to final opinion files
- Saves only 3 essential files to `.ai-debate-output/session-TIMESTAMP/`
- Returns output directory path and success count

**Output directory structure (optimized - 3 files only):**
```
.ai-debate-output/
└── session-20251103-013000/
    ├── prompt.txt              # Original prompt
    ├── codex-opinion.txt       # Codex opinion (direct output)
    └── claude-opinion.txt      # Claude opinion (direct output)
```

**Performance improvements:**
- File I/O: 25 files → 3 files (88% reduction)
- No intermediate logs or session files
- Direct stdout capture to final files
- 2 reliable agents (Codex + Claude Code)
- Estimated 50-70% speed improvement

#### 2.3 Read Collected Opinions

The helper script outputs directly to final files. Just read them:

```bash
# Read opinions (always available after successful execution)
CODEX_OPINION=$(cat "$SESSION_OUTPUT/codex-opinion.txt")
CLAUDE_OPINION=$(cat "$SESSION_OUTPUT/claude-opinion.txt")

# Both opinions are guaranteed to exist (error placeholders if agent failed)
```

#### 2.4 Analyze and Synthesize

Compare the two independent opinions:

1. **Identify Common Ground**
   - What do both agents agree on?
   - Shared key points and recommendations

2. **Highlight Differences**
   - Where do opinions diverge?
   - Different priorities or concerns

3. **Extract Unique Insights**
   - Unique perspective from each agent (Codex vs Claude)
   - Novel arguments or considerations

4. **Synthesize Recommendation**
   - Weighted synthesis based on agreement
   - Address conflicting viewpoints
   - Provide balanced final recommendation

#### 2.5 Present Results to User

Format the analysis as a comprehensive debate summary:

**Output Template:**
```markdown
# AI Debate Results

## Question
[Original clarified question]

## Context Summary
[Brief recap of constraints from Phase 1]

---

## Independent Opinions

### Codex Analysis
[Codex's complete opinion]

**Key Strengths:** [Highlight 2-3 strong points]

---

### Claude Code Analysis
[Claude's complete opinion]

**Key Strengths:** [Highlight 2-3 strong points]

---

## Synthesis

### Areas of Agreement ✅
[Points where both agents agree]

### Areas of Disagreement ⚠️
[Points where opinions diverge, with explanations]

### Unique Insights 💡
- **Codex:** [Unique perspective]
- **Claude Code:** [Unique perspective]

---

## Final Recommendation

[Synthesized recommendation considering both viewpoints]

**Confidence Level:** [High/Medium based on agreement]

**Next Steps:**
1. [Actionable step 1]
2. [Actionable step 2]
```

---

## Best Practices

### ✅ Do's

**Phase 1 (Clarification):**
1. **Always clarify first** - Even if it seems obvious
2. **Use the templates** - Maintains consistency
3. **Wait for user response** - Don't assume or skip
4. **Summarize if info is complete** - Builds trust

**Phase 2 (Debate):**
1. **Include all Phase 1 context in prompts** - Don't lose clarified info
2. **Use parallel execution** - Launch both agents with `&` and `wait`
3. **Use fast mode (--stdout-only)** - Minimize file I/O for speed
4. **Analyze objectively** - Don't bias toward any single agent
5. **Highlight both agreement and disagreement** - Both are valuable

### ❌ Don'ts

**Phase 1 (Clarification):**
1. **Don't skip to debate** - Clarification is mandatory
2. **Don't ask too many questions** - 2-3 max
3. **Don't make assumptions** - Ask or state clearly
4. **Don't proceed without confirmation** - Wait for user "yes"

**Phase 2 (Debate):**
1. **Don't run sessions sequentially** - Use parallel execution for unbiased opinions
2. **Don't cherry-pick opinions** - Present all viewpoints fairly
3. **Don't ignore minority opinions** - Unique insights are valuable
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

You: "감사합니다. 명확화가 완료되었습니다.
(V2.0 Phase 1이라 실제 토론 기능은 개발 중입니다.)"
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

You: "감사합니다. 명확화가 완료되었습니다.
(V2.0 Phase 1이라 실제 토론 기능은 개발 중입니다.)"
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
- [x] Successfully launches 3 sessions in parallel
- [x] All sessions complete without errors
- [x] Results are properly collected
- [ ] Synthesis identifies agreement/disagreement correctly (TODO: Phase 2.4-2.5)
- [ ] Output is clear and actionable (TODO: Phase 2.4-2.5)

---

## Bundled Scripts

This skill includes helper scripts in the `scripts/` directory:

### Session Managers
- **`codex-session.sh`** - Manages stateful Codex CLI sessions (supports --stdout-only fast mode)
- **`claude-code-session.sh`** - Manages stateful Claude Code CLI sessions (supports --stdout-only fast mode)
- **`gemini-cli-session.sh`** - Manages stateful Gemini CLI sessions (available but not used in v2.0-optimized)

All session managers provide identical API: `new`, `continue`, `info`, `list`, `clean`

### Orchestration
- **`collect-opinions.sh`** - Main orchestrator that:
  - Launches 2 AI agents (Codex + Claude Code) in parallel
  - Uses --stdout-only --quiet for minimal file I/O
  - Waits for both to complete
  - Outputs directly to 3 final files (prompt + 2 opinions)
  - Returns structured output with session path and success count

**Usage**: Scripts are executed by Claude during Phase 2 debate workflow. See section 2.2 for details.

---

**Version:** 2.0.0-phase2-optimized
**Status:** Phase 2.1-2.3 Optimized (2-agent fast mode, 88% fewer files, 50-70% faster)
**Next:** Phase 2.4-2.5 (Analysis & Synthesis)
**Agents:** Codex + Claude Code (Gemini removed due to reliability issues)
**Created:** 2025-11-02
**Updated:** 2025-11-03 (Speed optimization: minimal file I/O, 2 reliable agents)
