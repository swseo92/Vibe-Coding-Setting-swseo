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

## Step 2: After Clarification

**Currently in Phase 1:** After gathering clarification, inform the user:

```
"명확화가 완료되었습니다. 현재 V2.0 Phase 1이라 실제 AI 토론 기능은 개발 중입니다.
하지만 명확화 프로세스가 잘 작동하는지 확인했습니다!"
```

**Future (Phase 2+):** Will execute actual AI debate with the enriched context.

---

## Best Practices

### ✅ Do's

1. **Always clarify first** - Even if it seems obvious
2. **Use the templates** - Maintains consistency
3. **Wait for user response** - Don't assume or skip
4. **Summarize if info is complete** - Builds trust

### ❌ Don'ts

1. **Don't skip to debate** - Clarification is mandatory
2. **Don't ask too many questions** - 2-3 max
3. **Don't make assumptions** - Ask or state clearly
4. **Don't proceed without confirmation** - Wait for user "yes"

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

## Phase 1 Testing

**Goal:** Validate clarification workflow only

**Success Criteria:**
- [ ] Consistently detects when clarification is needed
- [ ] Asks appropriate 2-3 questions
- [ ] Shows understanding summary when info is complete
- [ ] Waits for user confirmation
- [ ] No errors or confusion in flow

**Next Phase:** Add actual AI debate execution after Phase 1 validates

---

**Version:** 2.0.0-phase1
**Status:** Testing (Clarification only)
**Focus:** Get clarification right before adding debate logic
**Created:** 2025-11-02
