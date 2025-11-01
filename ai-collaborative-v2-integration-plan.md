# AI Collaborative Solver V2.0 통합 계획

**목표:** Codex V3.0의 모든 풀스펙을 AI Collaborative Solver에 통합하여 진짜 토론 시스템 구축

**버전:** AI Collaborative Solver V1.0 → V2.0
**기간:** 4-6주 (Phase별 분할 가능)
**작성일:** 2025-10-31

---

## 📋 전체 개요

### 현재 상태 (V1.0)
```
❌ 병렬 독립 분석 (토론 아님)
❌ Facilitator 없음
❌ Quality framework 없음
✅ Multi-model support (Codex/Claude/Gemini)
✅ Registry-based selection
```

### 목표 상태 (V2.0)
```
✅ Round-by-round 진짜 토론
✅ Claude Facilitator orchestration
✅ V3.0 Quality framework 전체
✅ Multi-model support 유지
✅ Pre-clarification stage
✅ Coverage monitoring (8 dimensions)
✅ Quality gate + Stress pass
```

---

## 📂 Codex V3.0 전체 파일 구조

```
.claude/skills/codex-collaborative-solver/
├── SKILL.md                              # 메인 스킬 정의
├── README.md                             # 사용 가이드
│
├── facilitator/                          # 🔴 P0 - Facilitator System
│   ├── cli-flags.md                      # CLI 플래그 정의
│   ├── mid-debate-heuristic.md           # 중간 개입 휴리스틱
│   ├── quality-gate.md                   # 최종 품질 검증
│   ├── reasoning-log-integration.md      # 로그 통합 가이드
│   │
│   ├── rules/                            # Rule 정의
│   │   ├── anti-patterns.yaml            # 안티패턴 감지 규칙
│   │   ├── coverage-monitor.yaml         # 8차원 커버리지
│   │   └── scarcity-thresholds.yaml      # 정보 부족 임계값
│   │
│   └── prompts/                          # Facilitator 프롬프트
│       ├── ai-escalation.md              # AI 개입 프롬프트
│       └── mid-debate-user-input.md      # 사용자 개입 프롬프트
│
├── modes/                                # 🟡 P1 - Mode System
│   ├── exploration.yaml                  # 탐색 모드
│   ├── balanced.yaml                     # 균형 모드
│   └── execution.yaml                    # 실행 모드
│
├── playbooks/                            # 🔵 P3 - Playbook System
│   ├── _template.md                      # 플레이북 템플릿
│   └── database-optimization.md          # DB 최적화 예제
│
├── references/                           # 참고 문서
│   ├── v2-vs-v3-comparison.md            # V2 vs V3 비교
│   └── v3-design-debate.md               # V3 디자인 토론
│
└── schemas/                              # (없음 - 문서로만 정의됨)
    └── debate-log.json                   # (예정) 토론 로그 스키마
```

---

## 🎯 Phase별 통합 계획

---

## Phase 0: 사전 준비 (1일)

### 작업 내용
1. 디렉토리 구조 생성
2. Codex 파일 복사 (수정 없이)
3. 기존 코드 백업

### 생성할 디렉토리
```bash
.claude/skills/ai-collaborative-solver/
├── facilitator/
│   ├── rules/
│   └── prompts/
├── modes/
├── playbooks/
└── schemas/
```

### 복사할 파일
```bash
# Facilitator system
cp codex-collaborative-solver/facilitator/*.md ai-collaborative-solver/facilitator/
cp codex-collaborative-solver/facilitator/rules/*.yaml ai-collaborative-solver/facilitator/rules/
cp codex-collaborative-solver/facilitator/prompts/*.md ai-collaborative-solver/facilitator/prompts/

# Modes
cp codex-collaborative-solver/modes/*.yaml ai-collaborative-solver/modes/

# Playbooks
cp codex-collaborative-solver/playbooks/*.md ai-collaborative-solver/playbooks/

# References
cp codex-collaborative-solver/references/*.md ai-collaborative-solver/references/
```

---

## 🔴 Phase 1: Facilitator Core (P0 - 1주)

**목표:** Claude가 facilitator로서 토론 orchestrate

### 1.1 Facilitator 기본 구조

#### 참조 파일
- `codex-collaborative-solver/SKILL.md` (라인 60-110: "Hybrid Facilitator System")
- `codex-collaborative-solver/facilitator/quality-gate.md`

#### 구현할 것
1. **Facilitator 스크립트 생성**
   ```bash
   .claude/skills/ai-collaborative-solver/scripts/facilitator.sh
   ```

2. **Facilitator 역할**
   - Round orchestration (순서 제어)
   - Agent prompt 생성
   - Response 수집 및 전달
   - Quality monitoring

3. **수정할 파일**
   - `scripts/ai-debate.sh` - Facilitator 호출 추가
   - `models/*/adapter.sh` - Facilitator와 통신

#### 구현 예시
```bash
# facilitator.sh (새 파일)
#!/usr/bin/env bash

PROBLEM="$1"
MODELS="$2"  # "codex,gemini" or "codex" or "all"
MODE="$3"

# Round 1: Initial analysis from each model
for model in $MODELS; do
    run_model_adapter "$model" "Round 1: Analyze problem" "$PROBLEM"
done

# Round 2: Cross-examination
for model in $MODELS; do
    # Get OTHER models' responses
    other_responses=$(get_other_model_responses "$model")

    # Send to model with context
    run_model_adapter "$model" "Round 2: Respond to others" "$PROBLEM" "$other_responses"
done

# Round 3+: Convergence
# ...
```

---

### 1.2 Round-by-Round Debate Structure

#### 참조 파일
- `codex-collaborative-solver/SKILL.md` (라인 459-476: "Round Loop")

#### 구현할 것
1. **Round state management**
   ```bash
   $STATE_DIR/rounds/
   ├── round1/
   │   ├── codex_input.txt
   │   ├── codex_output.txt
   │   ├── gemini_input.txt
   │   └── gemini_output.txt
   ├── round2/
   └── ...
   ```

2. **Context passing between rounds**
   - 이전 라운드 응답을 다음 라운드 입력에 포함
   - 각 모델이 다른 모델의 응답을 볼 수 있게

3. **수정할 파일**
   - `models/codex/adapter.sh` - Context parameter 추가
   - `models/claude/adapter.sh` - Context parameter 추가
   - `models/gemini/adapter.sh` - Context parameter 추가

#### 구현 예시
```bash
# Round 2 prompt example
ROUND2_PROMPT="Previous responses:

**Codex said:**
$CODEX_ROUND1_RESPONSE

**Gemini said:**
$GEMINI_ROUND1_RESPONSE

Now, please respond to their points and provide your perspective..."
```

---

### 1.3 Adapter 수정 (Context Support)

#### 참조 파일
- 현재 `models/*/adapter.sh` 파일들

#### 구현할 것
1. **새 parameter 추가**
   ```bash
   # Before
   adapter.sh <problem> <mode> <state_dir>

   # After
   adapter.sh <problem> <mode> <state_dir> <context>
   ```

2. **Context injection**
   - Codex: debate-continue.sh에 context 전달
   - Claude: Session에 context 추가
   - Gemini: Prompt에 context 포함

3. **수정할 파일**
   - `models/codex/adapter.sh`
   - `models/claude/adapter.sh`
   - `models/gemini/adapter.sh`

---

## 🟡 Phase 2: Quality Framework (P1 - 1주)

### 2.1 Pre-Clarification Stage

#### 참조 파일
- `codex-collaborative-solver/SKILL.md` (라인 249-304: "Pre-Debate Clarification Stage")

#### 구현할 것
1. **Clarification 스크립트**
   ```bash
   .claude/skills/ai-collaborative-solver/scripts/pre-clarify.sh
   ```

2. **Clarification 로직**
   ```bash
   # 1. Problem 분석 (Claude)
   # 2. 질문 생성 (1-3개)
   # 3. 사용자 응답 대기
   # 4. 응답을 context에 추가
   ```

3. **수정할 파일**
   - `scripts/ai-debate.sh` - Pre-clarification stage 추가
   - `SKILL.md` - 사용법 업데이트

#### 구현 예시
```bash
# pre-clarify.sh (새 파일)
#!/usr/bin/env bash

PROBLEM="$1"

# Ask Claude to generate clarification questions
QUESTIONS=$(echo "Analyze this problem and generate 1-3 clarification questions:
$PROBLEM

Focus on: constraints, goals, context" | claude --print)

# Present to user
echo "명확화 질문:"
echo "$QUESTIONS"

# Read user response
read -p "답변: " USER_RESPONSE

# Return enriched context
echo "Original: $PROBLEM

Clarification:
$USER_RESPONSE"
```

---

### 2.2 Coverage Monitoring (8 Dimensions)

#### 참조 파일
- `codex-collaborative-solver/facilitator/rules/coverage-monitor.yaml`
- `codex-collaborative-solver/SKILL.md` (라인 66-69: "Coverage Tracker")

#### 구현할 것
1. **Coverage 체크 스크립트**
   ```bash
   .claude/skills/ai-collaborative-solver/scripts/check-coverage.sh
   ```

2. **8 Dimensions**
   ```yaml
   dimensions:
     - architecture
     - security
     - performance
     - ux
     - testing
     - ops
     - cost
     - compliance
   ```

3. **Round별 체크**
   - 각 라운드 후 coverage 분석
   - 빠진 차원 플래그
   - Facilitator가 다음 라운드에서 탐색 요청

#### 구현 예시
```bash
# check-coverage.sh (새 파일)
#!/usr/bin/env bash

ROUND_OUTPUT="$1"
COVERAGE_FILE="$2"

# Load coverage rules
DIMENSIONS=$(yq '.dimensions[]' facilitator/rules/coverage-monitor.yaml)

for dim in $DIMENSIONS; do
    # Check if dimension mentioned
    if echo "$ROUND_OUTPUT" | grep -qi "$dim"; then
        echo "$dim: ✅ covered" >> "$COVERAGE_FILE"
    else
        echo "$dim: ❌ missing" >> "$COVERAGE_FILE"
    fi
done

# Return missing dimensions
grep "❌" "$COVERAGE_FILE" | cut -d: -f1
```

---

### 2.3 Quality Gate

#### 참조 파일
- `codex-collaborative-solver/facilitator/quality-gate.md`
- `codex-collaborative-solver/SKILL.md` (라인 484-487: "Quality Gate")

#### 구현할 것
1. **Quality gate 체크리스트**
   ```markdown
   - [ ] Verified assumptions or marked as assumptions?
   - [ ] User constraints honored?
   - [ ] Risks surfaced with mitigation?
   - [ ] Next actions concrete and executable?
   - [ ] Confidence level explicit?
   ```

2. **Gate 검증 스크립트**
   ```bash
   .claude/skills/ai-collaborative-solver/scripts/quality-gate.sh
   ```

3. **수정할 파일**
   - `scripts/ai-debate.sh` - Finalization 전 gate 체크

#### 구현 예시
```bash
# quality-gate.sh (새 파일)
#!/usr/bin/env bash

FINAL_REPORT="$1"

# Check each criterion
echo "Quality Gate Check:"

# 1. Assumptions check
if grep -qi "assumption" "$FINAL_REPORT"; then
    echo "✅ Assumptions marked"
else
    echo "❌ No assumptions mentioned - are there any?"
    exit 1
fi

# 2. Constraints check
# 3. Risks check
# 4. Actions check
# 5. Confidence check

echo "✅ Quality gate passed"
```

---

## 🟢 Phase 3: Advanced Features (P2 - 1주)

### 3.1 Stress Pass

#### 참조 파일
- `codex-collaborative-solver/SKILL.md` (라인 187-189: "Stress Pass")

#### 구현할 것
1. **합의 전 검증**
   - 마지막 endorsing agent에게 failure modes 요청
   - 응답 없으면 finalization 차단

2. **수정할 파일**
   - `scripts/facilitator.sh` - Stress pass 라운드 추가

#### 구현 예시
```bash
# In facilitator.sh
if consensus_reached; then
    # Stress pass
    LAST_AGENT=$(get_last_endorsing_agent)

    STRESS_PROMPT="You endorsed this solution.
    Please enumerate 3-5 failure modes and mitigation strategies."

    STRESS_RESPONSE=$(run_model_adapter "$LAST_AGENT" "Stress Pass" "$STRESS_PROMPT")

    if [ -z "$STRESS_RESPONSE" ]; then
        echo "❌ Stress pass failed - no failure modes provided"
        exit 1
    fi
fi
```

---

### 3.2 Anti-Pattern Detection

#### 참조 파일
- `codex-collaborative-solver/facilitator/rules/anti-patterns.yaml`
- `codex-collaborative-solver/SKILL.md` (라인 70-74: "Anti-Pattern Detector")

#### 구현할 것
1. **감지할 패턴**
   ```yaml
   patterns:
     circular_reasoning:
       description: "Same point repeated 2+ times"
       threshold: 2

     premature_convergence:
       description: "Agreement in <2 rounds"
       threshold: 2

     information_starvation:
       description: "Too many assumptions"
       threshold: "assumption:fact > 2:1"

     dominance:
       description: "One agent dominates"
       threshold: "response_length_ratio > 3:1"
   ```

2. **Detection 스크립트**
   ```bash
   .claude/skills/ai-collaborative-solver/scripts/detect-anti-patterns.sh
   ```

3. **수정할 파일**
   - `scripts/facilitator.sh` - 각 라운드 후 체크

---

### 3.3 Information Scarcity Protocol

#### 참조 파일
- `codex-collaborative-solver/facilitator/rules/scarcity-thresholds.yaml`
- `codex-collaborative-solver/SKILL.md` (라인 213-232: "Information Scarcity Protocol")

#### 구현할 것
1. **Abort 조건**
   ```yaml
   thresholds:
     critical_unknowns: 2
     assumption_fact_ratio: 2.0
   ```

2. **Scarcity 체크 스크립트**
   ```bash
   .claude/skills/ai-collaborative-solver/scripts/check-scarcity.sh
   ```

3. **중단 및 사용자 쿼리**
   - 임계값 초과 시 토론 일시중단
   - 구체적인 질문 생성
   - 사용자 응답 후 재개

---

### 3.4 Mid-Debate User Input

#### 참조 파일
- `codex-collaborative-solver/facilitator/mid-debate-heuristic.md`
- `codex-collaborative-solver/facilitator/prompts/mid-debate-user-input.md`
- `codex-collaborative-solver/SKILL.md` (라인 327-457: "Mid-Debate User Input")

#### 구현할 것
1. **Trigger 조건 (4가지)**
   ```yaml
   triggers:
     - information_deficit: "confidence < 50%"
     - preference_fork: "clear trade-off detected"
     - new_constraint: "constraint not in pre-clarification"
     - long_deadlock: "3+ rounds without convergence"
   ```

2. **사용자 입력 스크립트**
   ```bash
   .claude/skills/ai-collaborative-solver/scripts/mid-debate-input.sh
   ```

3. **CLI 플래그**
   ```bash
   --no-mid-input          # Disable completely
   --interactive           # Ask after every round
   --mid-input-frequency   # minimal/balanced/frequent
   ```

---

## 🔵 Phase 4: Playbook System (P3 - 1주)

### 4.1 Playbook Loading

#### 참조 파일
- `codex-collaborative-solver/playbooks/_template.md`
- `codex-collaborative-solver/playbooks/database-optimization.md`

#### 구현할 것
1. **Playbook 구조**
   ```markdown
   # Playbook: Database Optimization

   ## Problem Signature
   - Keywords: database, slow, query, performance
   - Contexts: Django, PostgreSQL, MySQL, MongoDB

   ## Key Questions
   1. Current response time vs target?
   2. Database version and configuration?
   3. Constraints (budget, time, team)?

   ## Common Tradeoffs
   - Indexing: Speed vs Storage
   - Caching: Complexity vs Performance
   - Connection pooling: Connections vs Memory

   ## Evidence Sources
   - [Django docs](...)
   - [PostgreSQL performance](...)

   ## Success Metrics
   - Response time improvement
   - Implementation complexity
   ```

2. **Playbook matching**
   ```bash
   .claude/skills/ai-collaborative-solver/scripts/match-playbook.sh
   ```

3. **Playbook injection**
   - 매칭된 playbook을 facilitator context에 추가

---

### 4.2 Playbook Auto-Generation (Future)

#### 참조 파일
- `codex-collaborative-solver/SKILL.md` (라인 142-162: "Automated Playbook Pipeline")

#### 구현할 것 (나중에)
1. Debate log 구조화
2. Nightly clustering
3. Success metrics 추적
4. LLM-based playbook generation

---

## 📝 Phase 5: Documentation & Testing (1주)

### 5.1 Documentation

#### 작업 내용
1. **SKILL.md 업데이트**
   - V2.0 기능 전체 문서화
   - 사용 예제 추가
   - Troubleshooting 가이드

2. **README.md 작성**
   - Quick start guide
   - Architecture overview
   - Configuration guide

3. **Migration guide**
   - V1.0 → V2.0 마이그레이션 가이드

---

### 5.2 Testing

#### 테스트 시나리오
1. **Basic debate**
   ```bash
   # Single model
   ai-debate.sh "Django vs FastAPI" --model codex --mode simple

   # Multi-model
   ai-debate.sh "Django vs FastAPI" --model codex,gemini --mode balanced
   ```

2. **Pre-clarification**
   ```bash
   # Should trigger clarification
   ai-debate.sh "API 느려"

   # Should skip clarification
   ai-debate.sh "Django 4.2 API 성능 (2s→500ms, PostgreSQL, 1주일)"
   ```

3. **Quality gate**
   ```bash
   # Should pass
   ai-debate.sh "..." --mode balanced

   # Should fail (missing info)
   ai-debate.sh "..." --mode balanced --force-incomplete
   ```

4. **Anti-pattern detection**
   ```bash
   # Should detect circular reasoning
   # (manual test - verify logs)
   ```

---

## 📊 구현 체크리스트

### Phase 0: 준비 (1일)
- [ ] 디렉토리 구조 생성
- [ ] Codex 파일 복사
- [ ] 기존 코드 백업

### Phase 1: Facilitator Core (1주)
- [ ] Facilitator 기본 스크립트 (`facilitator.sh`)
- [ ] Round-by-round debate structure
- [ ] Adapter context support (codex/claude/gemini)
- [ ] State management (rounds directory)

### Phase 2: Quality Framework (1주)
- [ ] Pre-clarification stage (`pre-clarify.sh`)
- [ ] Coverage monitoring (`check-coverage.sh`)
- [ ] Quality gate (`quality-gate.sh`)
- [ ] 8-dimension tracking

### Phase 3: Advanced Features (1주)
- [ ] Stress pass implementation
- [ ] Anti-pattern detection (`detect-anti-patterns.sh`)
- [ ] Information scarcity check (`check-scarcity.sh`)
- [ ] Mid-debate user input (`mid-debate-input.sh`)

### Phase 4: Playbook System (1주)
- [ ] Playbook template structure
- [ ] Playbook matching (`match-playbook.sh`)
- [ ] Playbook injection into context
- [ ] 3-5 example playbooks

### Phase 5: Documentation & Testing (1주)
- [ ] SKILL.md 업데이트
- [ ] README.md 작성
- [ ] Migration guide
- [ ] 10+ test scenarios

---

## 🔧 구현 우선순위 요약

### 🔴 Must Have (Phase 1-2)
1. Facilitator system
2. Round-by-round debate
3. Pre-clarification
4. Quality gate

### 🟡 Should Have (Phase 3)
5. Coverage monitoring
6. Stress pass
7. Anti-pattern detection
8. Information scarcity

### 🟢 Nice to Have (Phase 3-4)
9. Mid-debate user input
10. Playbook system

---

## 🚀 Quick Start (Phase 1만 먼저)

만약 전체 구현이 부담스럽다면, **Phase 1만** 먼저 구현:

```bash
# 1. Facilitator 기본만
.claude/skills/ai-collaborative-solver/scripts/facilitator.sh

# 2. Round-by-round structure
# 3. Adapter context support
```

**이것만으로도 "진짜 토론"이 가능해집니다!**

---

## 📌 다음 단계

**지금 시작할 것:**
1. Phase 0 실행 (디렉토리 생성 + 파일 복사)
2. Phase 1.1 시작 (Facilitator 기본 구조)

**선택지:**
- **A. 전체 진행** - Phase 0 → Phase 5 순차 진행
- **B. Phase 1만** - 핵심 토론 구조만 빠르게
- **C. 문서 검토** - 계획 검토 후 조정

어떤 방향으로 진행할까요?
