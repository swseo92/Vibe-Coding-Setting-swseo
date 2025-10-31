# Mid-Debate User Input 설계

**Date:** 2025-10-31
**Session ID:** 019a39bb-801f-79e3-8915-8cdbb37bc097
**Status:** Designed, Ready for Implementation

---

## Summary

V3.0 Codex Collaborative Solver에 "토론 중간 사용자 의견 묻기(mid-debate user input)" 기능을 추가하기로 결정. Claude와 Codex가 Option C (Smart Prompting) + Option B (Manual Flag) 하이브리드 구성에 합의.

---

## Design Consensus (Claude + Codex)

### 최종 설계: Hybrid Approach

**Primary:** Option C (Smart Prompting) - Agent-driven, 필요시만 질문
**Secondary:** Option B (Manual Flag) - Power user를 위한 `--interactive` 플래그

### Core Philosophy Alignment

✅ **"Scripts Assist, Agents Judge"**
- Agent가 critical decision point 판단
- No rigid rules, no keyword matching
- V3.0 철학 완벽 유지

✅ **Pre-clarification과 상호보완**
- Pre: 토론 시작 전 초기 컨텍스트
- Mid: 토론 중 불확실성 해결
- 역할이 다르므로 중복 아님

---

## Implementation Spec

### 1. Critical Decision Point Heuristics

**Agent가 다음 조건에서 사용자 의견을 묻습니다:**

#### Condition 1: Information Deficit (정보 부족)
```
Trigger:
- Claude confidence < 50% AND Codex confidence < 50%
- 또는 둘 중 하나가 "I need user input" 명시

Action:
- 현재 토론 상태 요약 제공
- 구체적 질문 (1-2개)
- 왜 필요한지 이유 설명
```

#### Condition 2: Preference Fork (선호도 갈림길)
```
Trigger:
- Trade-off 발견 (예: 성능 vs 복잡도)
- 두 접근법 모두 valid + 사용자 선호 필요

Action:
- Trade-off matrix 제시
- 각 옵션의 장단점 명시
- 사용자 우선순위 질문
```

#### Condition 3: New Constraint Discovery (새 제약 발견)
```
Trigger:
- 토론 중 예상 못한 제약사항 발견
- 기존 pre-clarification에 없던 정보 필요

Action:
- 발견된 제약사항 설명
- 이것이 솔루션에 미치는 영향
- 사용자 확인 요청
```

#### Condition 4: Long-running Deadlock (장시간 교착)
```
Trigger:
- 3 라운드 이상 진행
- 합의 도달 실패 (disagreement score > threshold)

Action:
- 핵심 논쟁점 요약
- 각 AI의 입장 정리
- 사용자가 tie-breaker 역할
```

### 2. Decision Heuristic Module

**구조:**
```python
class MidDebateHeuristic:
    def __init__(self):
        self.confidence_threshold = 0.5
        self.disagreement_threshold = 0.7
        self.round_limit = 3
        self.min_interval_seconds = 300  # 5분

    def should_ask_user(self, context: DebateContext) -> bool:
        """Agent가 사용자 의견이 필요한지 판단"""

        # Check interval (너무 자주 묻지 않기)
        if context.time_since_last_question < self.min_interval_seconds:
            return False

        # Condition 1: Information Deficit
        if (context.claude_confidence < self.confidence_threshold and
            context.codex_confidence < self.confidence_threshold):
            return True

        # Condition 2: Preference Fork
        if context.has_tradeoff and context.both_valid:
            return True

        # Condition 3: New Constraint
        if context.new_constraint_discovered:
            return True

        # Condition 4: Long-running Deadlock
        if (context.round_count >= self.round_limit and
            context.disagreement_score > self.disagreement_threshold):
            return True

        return False

    def generate_question(self, context: DebateContext) -> UserPrompt:
        """사용자에게 보여줄 질문 생성"""
        return UserPrompt(
            state_summary=self._summarize_debate(context),
            reason=self._explain_why_asking(context),
            questions=self._generate_specific_questions(context),
            options=self._provide_options_if_applicable(context)
        )
```

### 3. User Control Options

#### Option 1: Global Setting (권장)
```bash
# ~/.claude/settings.json
{
  "codex_debate": {
    "mid_debate_input": {
      "enabled": true,           # 기본: 활성화
      "frequency": "as_needed",  # "as_needed" | "frequent" | "minimal"
      "min_interval": 300        # 초 단위 (5분)
    }
  }
}
```

#### Option 2: Command-line Flag
```bash
# 특정 세션만 비활성화
codex와 토론해줘 --no-mid-input

# 특정 세션만 활성화 (power user)
codex와 토론해줘 --interactive

# 빈도 조정
codex와 토론해줘 --mid-input-frequency=minimal
```

### 4. UX Flow

#### 정상 흐름 (자동 진행)
```
Round 1: Claude → Codex
    ↓
Heuristic: No user input needed
    ↓
Round 2: Claude → Codex
    ↓
Heuristic: No user input needed
    ↓
Round 3: Consensus reached
```

#### Mid-debate input 발생
```
Round 1: Claude → Codex
    ↓
Round 2: Claude → Codex
    ↓
Heuristic: Information deficit detected!
    ↓
╔════════════════════════════════════════╗
║ 🤔 Mid-Debate User Input Required     ║
╠════════════════════════════════════════╣
║ Current State:                         ║
║ Claude와 Codex가 두 가지 접근법을      ║
║ 논의 중입니다. 둘 다 장단점이 있어     ║
║ 사용자 우선순위가 필요합니다.          ║
║                                        ║
║ Question:                              ║
║ 성능과 유지보수성 중 어느 것이 더      ║
║ 중요한가요?                            ║
║                                        ║
║ Options:                               ║
║ 1. 성능 우선 (복잡도 증가)             ║
║ 2. 유지보수성 우선 (성능 trade-off)    ║
║ 3. 균형 (중간 접근)                    ║
║                                        ║
║ [1] [2] [3] [Skip and continue]       ║
╚════════════════════════════════════════╝
    ↓
User: 2 (유지보수성 우선)
    ↓
Round 3: Claude → Codex (with user preference)
    ↓
Consensus reached
```

### 5. State Summary Template

**사용자에게 보여줄 요약 형식:**

```markdown
## 🤔 Mid-Debate User Input

**Round:** {round_number} / 5
**Time Elapsed:** {elapsed_time}

### Current Discussion

{1-2 문장으로 현재 토론 핵심 요약}

### Why We're Asking

{왜 사용자 의견이 필요한지 명확히}

### Your Input Needed

{구체적 질문 1-3개}

### Options (if applicable)

- Option A: {설명} (Pros: X, Cons: Y)
- Option B: {설명} (Pros: X, Cons: Y)
- Skip: Continue debate without input

---
**Note:** 답변하지 않으면 AI들이 최선을 다해 진행합니다.
```

### 6. Reasoning Log Integration

**사용자 응답을 토론에 반영:**

```python
class DebateSession:
    def incorporate_user_input(self, user_response: UserResponse):
        """사용자 응답을 reasoning log에 명시적 반영"""

        # Add to context
        self.context.user_preferences.append({
            "round": self.current_round,
            "question": user_response.question,
            "answer": user_response.answer,
            "timestamp": datetime.now()
        })

        # Inject into next round prompts
        next_prompt = f"""
        User clarification (Round {self.current_round}):
        Q: {user_response.question}
        A: {user_response.answer}

        Please incorporate this preference into your analysis.
        """

        # Prevent same question
        self.asked_questions.add(user_response.question_hash)
```

---

## Benefits

### 1. Fewer Assumptions
- Pre-clarification만으로 부족한 경우 보완
- 토론 중 발견된 gaps 해결

### 2. Better Constraint Adherence
- 실시간 제약사항 반영
- 사용자 우선순위 명확화

### 3. Faster Convergence
- 교착 상태 즉시 해결
- 불필요한 라운드 감소

### 4. Improved Confidence
- 사용자 피드백 반영 → 높은 신뢰도
- 최종 솔루션의 적합성 향상

---

## Implementation Checklist

- [ ] Decision heuristic module 구현
- [ ] UserPrompt 템플릿 생성
- [ ] State summary generator 구현
- [ ] Settings integration (global + CLI flags)
- [ ] Reasoning log에 user response 통합
- [ ] UX mock-up 생성
- [ ] Internal playtest 실행
- [ ] Feedback loop 수집 메커니즘 (opt-in)
- [ ] Documentation 업데이트
  - [ ] skill.md에 Mid-debate Input 섹션 추가
  - [ ] Usage examples 업데이트
  - [ ] Best practices 추가
- [ ] Quality gate에 통합
  - [ ] Section 추가: "Mid-debate User Input Appropriateness"

---

## Codex Additional Insights

### State Summary 중요성
> "사용자에게 질문을 던질 때, 현재 토론 상태 요약(state summary)과 왜 질문이 필요한지 이유를 1-2문장으로 제공하면 신뢰도와 반응률이 올라갑니다."

→ **Action:** State summary를 항상 포함하도록 템플릿 설계

### Feedback Loop for Improvement
> "필요 시 토론 종료 후 피드백 로그를 수집(Opt-in)해 질문 타이밍이 적절했는지 self-evaluation에 활용하면 heuristic을 지속 개선할 수 있습니다."

→ **Action:** Feedback collection 메커니즘 구현 (Phase 2)

### Frequency Tuning
> "단순 온/오프 외에 빈도 옵션(frequency setting)이나 최소 간격(min interval) 등을 제공하면 반복 질문 부담을 줄일 수 있습니다."

→ **Action:** `min_interval` + `frequency` 설정 추가

---

## Next Steps

### Phase 1: Core Implementation (Priority)
1. Decision heuristic module
2. UserPrompt generation
3. Basic CLI flag support (`--no-mid-input`)
4. Reasoning log integration

### Phase 2: UX Enhancement
1. State summary template
2. Options formatting
3. Interval tuning
4. Frequency settings

### Phase 3: Continuous Improvement
1. Feedback collection
2. Heuristic refinement
3. A/B testing different thresholds
4. Analytics dashboard

---

## Philosophy Alignment Check

✅ **"Scripts Assist, Agents Judge"**
- Agent가 언제 물을지 판단 ✓
- No rigid rules ✓
- Context-aware ✓

✅ **User Control Preserved**
- `--no-mid-input` 플래그 ✓
- Global settings ✓
- Frequency tuning ✓

✅ **Pre-clarification과 일관성**
- 둘 다 agent-driven ✓
- 역할 명확히 구분 ✓
- 상호보완 관계 ✓

✅ **최소 방해 원칙**
- Default: 자동 진행 ✓
- 필요시만 질문 ✓
- Interval 제한 ✓

---

## File Locations

**Design Document:**
```
.debate-reports/2025-10-31-mid-debate-user-input-design.md
```

**To be Updated:**
```
.claude/skills/codex-collaborative-solver/SKILL.md
.claude/skills/codex-collaborative-solver/facilitator/quality-gate.md
```

**To be Created:**
```
.claude/skills/codex-collaborative-solver/facilitator/mid-debate-heuristic.py
.claude/skills/codex-collaborative-solver/facilitator/prompts/user-input-template.md
```

---

**Design By:** Claude + Codex
**Debate Session:** 019a39bb-801f-79e3-8915-8cdbb37bc097
**Tokens Used:** 1,675 (Codex Round 1)
**Ready for Implementation:** Yes

---

## Appendix: Full Codex Response

<details>
<summary>Codex Round 1 전체 응답 (클릭하여 펼치기)</summary>

**핵심 의견**
- Option C(Smart Prompting)가 V3.0 철학과 가장 잘 맞습니다. Agent가 상황(Context)을 평가해서 mid-debate input을 요청하도록 하면 사용자를 불필요하게 방해하지 않고, 기존 pre-clarification 흐름과도 자연스럽게 이어집니다.
- Option A(Automatic Pause)는 trigger condition을 정확히 맞추기 어렵고 false positive로 토론 흐름이 깨질 위험이 큽니다. Option B(Manual Flag)는 일부 power user에게는 유용하지만 기본 경험으로 삼기에는 사용자가 플래그를 기억하고 설정해야 한다는 부담이 있습니다. 결과적으로 Option C를 기본으로, Option B를 보조 설정으로 병행 지원하는 하이브리드 구성이 가장 유연합니다.

**Critical Decision Point 기준**
- **정보 부족 신호(Information deficit)**: Agent가 핵심 가설이나 솔루션을 비교할 때 판단 근거가 부족하다고 감지(예: reasoning module에서 confidence score가 임계값 이하).
- **선호도/우선순위 갈림길(Preference fork)**: 해결책이 사용자 선호나 리스크 허용도에 따라 달라질 때(예: trade-off matrix).
- **새로운 변수 감지(New constraint)**: 토론 중 다른 Agent가 사용자에게 확인해야 할 새로운 제약 조건을 제시했을 때.
- **장시간 진행(Long-running)**: 논의가 일정 길이 이상 지속되고도 합의에 도달하지 못한 경우(예: step counter 기반).
이를 위해 Agent 내부에 decision heuristic 모듈을 두어 실시간 신뢰도(confidence), 가설 다양성(solution diversity), unresolved issue count 등을 추적하고 threshold를 넘으면 사용자에게 질문하도록 합니다.

**사용자 제어(User Control)**
- 기능은 기본 활성화하되, 사용자 설정(preference panel 또는 run-level flag)으로 끌 수 있게 해야 합니다.
- 단순 온/오프 외에 빈도 옵션(frequency setting)이나 최소 간격(min interval) 등을 제공하면 반복 질문 부담을 줄일 수 있습니다.
- 특정 세션에서만 끄고 싶은 경우를 대비해 명령줄 플래그(예: `--no-mid-input`)나 API 파라미터를 지원하는 것이 좋습니다.

**Pre-clarification과의 관계**
- 상호보완 관계입니다. Pre-clarification은 초기 컨텍스트 확보가 목적이고, mid-debate input은 토론 중간에 등장하는 불확실성 해결이 목적이므로 역할이 다릅니다.
- 다만 pre-clarification에서 이미 충분한 정보를 받았다면 mid-debate heuristic이 낮게 평가되어 질문이 거의 나오지 않도록 설계해야 중복감을 줄일 수 있습니다.
- 토론이 짧거나 난이도가 낮은 경우 pre-clarification으로 충분할 수 있으므로 mid-debate 모듈이 상황을 판단해 "질문 없음(no prompt)"을 합리적으로 선택할 수 있어야 합니다.

**추가 제안**
- 사용자에게 질문을 던질 때, 현재 토론 상태 요약(state summary)과 왜 질문이 필요한지 이유를 1-2문장으로 제공하면 신뢰도와 반응률이 올라갑니다.
- Mid-debate input을 받은 뒤에는 Agent reasoning log에 사용자 응답을 명시적으로 반영해 이후 단계에서 같은 의문이 반복되지 않도록 합니다.
- 필요 시 토론 종료 후 피드백 로그를 수집(Opt-in)해 질문 타이밍이 적절했는지 self-evaluation에 활용하면 heuristic을 지속 개선할 수 있습니다.

**다음 단계 제안**
1. Critical decision point heuristic 초안 정의 및 프로토타입 시뮬레이션.
2. 사용자 설정 스펙(온/오프, 빈도 옵션, 플래그) 구체화.
3. UX mock-up 생성 후 내부 플레이테스트로 질문 빈도/톤 검증.

</details>
