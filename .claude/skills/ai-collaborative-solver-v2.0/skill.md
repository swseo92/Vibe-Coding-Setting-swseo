---
name: ai-collaborative-solver-v2.0
description: AI debate skill with agent-driven pre-clarification. Use when users request technical comparisons, architecture decisions, or "AI debate/토론" for problem solving. V2.0 focuses on simplicity and clarity.
---

# AI Collaborative Solver V2.0

**Simple, Agent-Driven Multi-Model Debate**

*V2.0 Design Philosophy: Start simple, add incrementally*

---

## When to Use This Skill

Use when users request:
- "AI 토론" / "AI debate"
- Technical comparisons ("Django vs FastAPI", "Redis vs Memcached")
- Architecture decisions
- Performance optimization strategies
- Technology selection with trade-off analysis

**Trigger keywords:** "ai 토론", "ai debate", "토론해서", "비교해줘", "should I use"

---

## How to Activate (V2.0 Simplified)

### Step 1: Pre-Clarification (You handle this)

**Always start by gathering context before running the debate.**

#### If user provides minimal information:

**Ask 2-3 clarifying questions:**

```
To run an effective AI debate, I need to clarify:

1. **Constraints & Context:**
   - Tech stack, versions?
   - Timeline, budget, team size?

2. **Goals:**
   - What problem are you solving?
   - What does success look like?

3. **Current State:**
   - What's your current situation?
   - Any specific pain points?
```

**Example:**
```
User: "Django vs FastAPI 선택"

You: "AI 토론을 위해 몇 가지 확인하고 싶습니다:
1. 프로젝트 규모와 팀 구성은? (팀 크기, 경험 수준)
2. 주요 요구사항은? (성능, 생산성, 학습곡선 중 우선순위)
3. 기존 스택이 있나요? (Python 버전, 현재 프레임워크)"

User: [답변]
```

#### If user provides complete information:

**Show understanding summary and confirm:**

```
📋 **My Understanding:**
- [Main problem/decision]

🎯 **Key Constraints:**
- [Constraint 1]
- [Constraint 2]

🔍 **Assumptions:**
- [Assumption 1]

**Is this correct? Anything to add or correct?**
```

**Example:**
```
User: "Django 4.2 + PostgreSQL 14 성능 개선 (2초→500ms, 1주일, DBA 없음)"

You: "📋 My Understanding:
- Optimize Django 4.2 API: 2s → 500ms (75% improvement)

🎯 Key Constraints:
- Timeline: 1 week
- No DBA (developer-level optimizations only)
- Tech stack: Django 4.2, PostgreSQL 14

🔍 Assumptions:
- Likely ORM N+1 query issues
- Infrastructure changes not in scope
- Code-level optimizations prioritized

Is this correct?"

User: "네 맞습니다"
```

---

### Step 2: Execute AI Debate

Build enriched problem statement from clarification, then run:

```bash
bash .claude/skills/ai-collaborative-solver-v2.0/scripts/ai-debate.sh \
  "<problem with all context>" \
  --auto \
  --mode balanced
```

**Problem statement format:**
```
"<Original problem>. Context: <tech stack, versions>. Constraints: <timeline, team, budget>. Goals: <success criteria>. Current state: <pain points, bottlenecks>."
```

**Example:**
```bash
bash .claude/skills/ai-collaborative-solver-v2.0/scripts/ai-debate.sh \
  "Django 4.2 + PostgreSQL 14 API performance optimization: 2s → 500ms. Context: Django 4.2, PostgreSQL 14, typical ORM usage. Constraints: 1 week timeline, no DBA available (developer-level changes only). Goals: Achieve 75% response time reduction with code-level optimizations. Current state: Suspected N+1 queries, no query optimization yet." \
  --auto \
  --mode balanced
```

---

### Step 3: Summarize Results

After debate completes:
1. Read the report from `.debate-reports/`
2. Summarize key findings:
   - Recommended solution
   - Key rationale (why this approach)
   - Implementation steps (3-5 concrete actions)
   - Risks & mitigations
   - Confidence level

---

## Modes

- `simple`: 3 rounds, ~5-8 min (quick decisions)
- `balanced`: 4 rounds, ~10-15 min (default, recommended)
- `deep`: 6 rounds, ~15-25 min (complex problems)

---

## Best Practices

### ✅ Do's

1. **Always clarify first** - Don't skip to debate without context
2. **Use the templates** - 2-3 questions or understanding summary
3. **Build enriched problem statement** - Include all clarified context
4. **Summarize for user** - Don't just show raw report

### ❌ Don'ts

1. **Don't skip clarification** - Even if it seems obvious
2. **Don't run debate without context** - Quality depends on input quality
3. **Don't assume** - When in doubt, ask user
4. **Don't forget to summarize** - Raw report is too long

---

## V2.0 Design Notes

**What's different from V1.0:**
- ❌ No pre-clarify.sh script (too complex, stdin/TTY issues)
- ❌ No complex facilitator logic (keep simple for now)
- ✅ Agent-driven clarification (Claude Code handles it)
- ✅ Single script: ai-debate.sh (just run the debate)
- ✅ Focus: Get clarification right first, add features later

**Next steps (not in V2.0 yet):**
- Mid-debate user input
- Coverage monitoring
- Quality gates
- Playbook system

**Philosophy:** Start simple, validate, then iterate.

---

## Example Complete Flow

```
User: "Redis vs Memcached 선택 고민"

You: "AI 토론을 위해 몇 가지 확인하고 싶습니다:
1. 주요 사용 용도는? (캐싱, 세션 저장, 메시지 큐 등)
2. 예상 규모는? (초당 요청 수, 데이터 크기, TTL 요구사항)
3. 팀의 운영 경험은? (Redis/Memcached 경험 유무)"

User: "세션 저장용이고요, 초당 1000 req 정도, 데이터는 작지만 TTL 30분 필요. 팀은 Redis 경험 없음."

You: "감사합니다. AI 토론을 시작하겠습니다."

[Runs debate with enriched context]

You: "토론 결과 요약:

**추천:** Memcached
**이유:**
- 세션 저장 단순 용도에 충분
- Redis 운영 학습곡선 불필요
- 더 가벼움 (메모리 효율)

**구현 단계:**
1. Memcached 설치 및 기본 설정
2. Django cache backend 연결
3. 세션 middleware 설정

**주의사항:**
- 장애 복구 전략 필요 (Memcached는 persistence 없음)
- 향후 복잡한 기능 필요시 Redis 전환 고려

전체 리포트: .debate-reports/2025-11-02-XX-XX-ai-debate-codex.md"
```

---

**Version:** 2.0.0
**Status:** Experimental (Simplified redesign)
**Focus:** Agent-driven pre-clarification only
**Created:** 2025-11-02
