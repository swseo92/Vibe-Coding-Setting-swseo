# Codex Collaborative Solver V3.0 vs AI Collaborative Solver V1.0 비교

## 핵심 차이점

| 기능 | Codex V3.0 | AI Collaborative V1.0 | 상태 |
|------|-----------|---------------------|------|
| **토론 구조** | ✅ 진짜 토론 (Round-by-round) | ❌ 병렬 독립 분석 | **🔴 중요** |
| **Facilitator** | ✅ Claude가 직접 orchestrate | ❌ 없음 (스크립트만) | **🔴 중요** |
| **Pre-Clarification** | ✅ 토론 전 명확화 질문 | ❌ 없음 | **🟡 중요** |
| **Mid-Debate Input** | ✅ 토론 중 사용자 개입 | ❌ 없음 | 🟢 Nice-to-have |
| **Coverage Monitoring** | ✅ 8개 차원 체크 | ❌ 없음 | **🟡 중요** |
| **Quality Gate** | ✅ 최종 검증 체크리스트 | ❌ 없음 | **🟡 중요** |
| **Stress Pass** | ✅ 합의 전 실패 모드 열거 | ❌ 없음 | 🟢 Nice-to-have |
| **Anti-Pattern Detection** | ✅ 순환 논리, 조기 합의 감지 | ❌ 없음 | 🟢 Nice-to-have |
| **Playbook System** | ✅ 과거 토론 학습 | ❌ 없음 | 🟢 Future |
| **Evidence Tiers** | ✅ T1/T2/T3 증거 등급 | ✅ 있음 (메타데이터) | ✅ 동일 |
| **Mode System** | ✅ 3가지 (exploration/balanced/execution) | ✅ 3가지 (simple/balanced/deep) | ✅ 유사 |
| **Multi-Model Support** | ❌ Codex만 | ✅ Codex/Claude/Gemini | ✅ AI가 우수 |

---

## 🔴 치명적 차이점: 토론 구조

### Codex V3.0 (진짜 토론)
```
Round 1: Claude가 문제 분석 → Codex에게 전달
         ↓
         Codex 응답 (3-5가지 접근법)
         ↓
Round 2: Claude가 Codex 응답 분석 → 반박/질문 생성 → Codex에게 전달
         ↓
         Codex 반박에 응답
         ↓
Round 3: Claude가 synthesis → 최종 결론
```

**핵심:** Claude와 Codex가 **서로 응답을 보고** 반응함

### AI Collaborative V1.0 (병렬 분석)
```
Codex Adapter:
  Round 1 → Round 2 → Round 3 (독립적)

Claude Adapter:
  Round 1 → Round 2 → Round 3 (독립적)

Gemini Adapter:
  Round 1 → Round 2 → Round 3 (독립적)
```

**문제:** 각 모델이 **독립적으로** 실행, 서로 대화 안 함

---

## 빠진 핵심 기능들

### 1. 🔴 Facilitator System (가장 중요!)

**Codex V3.0:**
```yaml
facilitator/
  ├── rules/
  │   ├── coverage-monitor.yaml      # 8개 차원 체크
  │   ├── anti-patterns.yaml         # 순환 논리 감지
  │   └── scarcity-thresholds.yaml   # 중단 조건
  ├── prompts/
  │   ├── ai-escalation.md           # AI 개입 프롬프트
  │   └── mid-debate-user-input.md   # 사용자 개입
  └── quality-gate.md                # 최종 검증
```

**역할:**
- Coverage tracking (8 dimensions)
- Anti-pattern detection
- Information scarcity detection
- Quality gate enforcement

**AI Collaborative V1.0:** 없음

---

### 2. 🟡 Pre-Clarification Stage

**Codex V3.0:**
```
User: "Django API 느려"

Claude (Clarification):
"명확화 질문:
1. 현재/목표 응답 시간은?
2. 기술 스택은?
3. 예산/시간/팀 제약은?"

User: "현재 2초, 목표 500ms. Django 4.2 + PostgreSQL. 1주일."

→ 이제 명확한 컨텍스트로 토론 시작
```

**AI Collaborative V1.0:** 없음

---

### 3. 🟡 Coverage Monitoring (8 Dimensions)

**Codex V3.0:**
```yaml
dimensions:
  - architecture  # 아키텍처 고려됨?
  - security      # 보안 검토됨?
  - performance   # 성능 분석됨?
  - ux            # UX 영향 고려됨?
  - testing       # 테스트 전략 있음?
  - ops           # 운영/배포 고려됨?
  - cost          # 비용 분석됨?
  - compliance    # 규정 준수 체크됨?
```

**After each round:**
- 빠진 차원 플래그
- 에이전트에게 탐색 요청

**AI Collaborative V1.0:** 없음

---

### 4. 🟡 Quality Gate (최종 검증)

**Codex V3.0:**
```markdown
## Quality Gate Checklist
- [ ] Verified assumptions or marked as assumptions?
- [ ] User constraints honored?
- [ ] Risks surfaced with mitigation?
- [ ] Next actions concrete and executable?
- [ ] Confidence level explicit?
```

**Finalization 전에 체크 → 통과 못하면 차단**

**AI Collaborative V1.0:** 없음

---

### 5. 🟢 Stress Pass

**Codex V3.0:**
합의 전에 마지막 endorsing agent가 **failure modes** 열거해야 함

```
Codex: "이 솔루션은 좋습니다"
Claude (Facilitator): "잠깐! Stress pass 필요"
Codex: "Failure modes:
  1. DB 연결 풀 고갈 시 → 재시도 로직 필요
  2. 캐시 미스 시 → 폴백 전략 필요
  3. ..."
```

**AI Collaborative V1.0:** 없음

---

### 6. 🟢 Anti-Pattern Detection

**Codex V3.0:**
```yaml
patterns:
  circular_reasoning:
    threshold: 2+ rounds same point
    action: AI facilitator suggests pivot

  premature_convergence:
    threshold: Agreement in <2 rounds
    action: Force alternative exploration

  information_starvation:
    threshold: assumption:fact ratio > 2:1
    action: Abort, query user

  dominance:
    threshold: One agent's view accepted without challenge
    action: Prompt underrepresented agent
```

**AI Collaborative V1.0:** 없음

---

## 가져와야 할 우선순위

### 🔴 P0 (필수)
1. **Facilitator System** - Claude가 직접 토론 orchestrate
2. **Round-by-round Debate** - 모델 간 실제 대화 구조

### 🟡 P1 (중요)
3. **Pre-Clarification Stage** - 토론 전 명확화
4. **Coverage Monitoring** - 8개 차원 체크
5. **Quality Gate** - 최종 검증

### 🟢 P2 (Nice-to-have)
6. **Stress Pass** - 실패 모드 열거
7. **Anti-Pattern Detection** - 순환 논리 감지
8. **Mid-Debate User Input** - 토론 중 개입

### 🔵 P3 (Future)
9. **Playbook System** - 과거 토론 학습
10. **Mode Auto-Detection** - 키워드 기반 모드 자동 선택

---

## 권장 통합 방안

### Phase 1: 토론 구조 개선 (P0)
```bash
# 현재
각 어댑터 독립 실행 → 병렬 분석

# 목표
Claude facilitator → Codex/Gemini와 round-by-round 토론
```

**구현:**
1. Claude가 facilitator role
2. Round 1: Claude 분석 → Codex에게 전달
3. Round 2: Codex 응답 → Claude 반박/질문 생성 → Codex에게 전달
4. Round N: Synthesis

### Phase 2: Quality Framework (P1)
1. Pre-clarification stage 추가
2. Coverage monitoring 8 dimensions
3. Quality gate checklist

### Phase 3: Advanced Features (P2)
1. Stress pass
2. Anti-pattern detection
3. Mid-debate user input

---

## 현재 AI Collaborative의 장점 (유지)

1. ✅ **Multi-model support** - Codex/Claude/Gemini (Codex V3.0은 Codex만)
2. ✅ **Registry-based selection** - 자동 모델 선택
3. ✅ **Cost presets** - 비용 최적화
4. ✅ **Metadata extraction** - 신뢰도, 증거 티어

---

## 결론

**AI Collaborative V1.0의 가장 큰 문제:**
- ❌ 진짜 토론이 아님 (병렬 독립 분석)
- ❌ Facilitator 없음
- ❌ Quality assurance 없음

**해결 방법:**
1. Claude가 facilitator 역할 수행
2. Round-by-round 실제 토론 구조
3. Codex V3.0의 quality framework 통합

**최종 목표:**
```
AI Collaborative V2.0 =
  AI Collaborative V1.0 (Multi-model support) +
  Codex V3.0 (Facilitator + Quality framework)
```
