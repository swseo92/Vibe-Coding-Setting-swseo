# AI Collaborative Solver - Quick Start Guide

## 간단한 사용법 (Interactive Mode)

**Mid-debate User Input 기능을 테스트하려면 독립 터미널에서 실행하세요!**

### Windows (CMD/PowerShell)

```cmd
cd .claude\skills\ai-collaborative-solver
ai-debate.cmd "Redis vs Memcached"
```

### Unix/Linux/Mac

```bash
cd .claude/skills/ai-collaborative-solver
./ai-debate.sh "Redis vs Memcached"
```

---

## Interactive Mode란?

**Interactive Mode에서만 Mid-debate User Input이 작동합니다:**

- ✅ **독립 터미널**에서 직접 실행: Interactive mode
- ❌ Claude Code에서 파이프(`|`) 사용: Non-interactive mode
- ❌ 백그라운드(`&`) 실행: Non-interactive mode

---

## Mid-debate User Input 동작 방식

### 1. Debate 진행
```
## Round 1: Initial Analysis
  - AI가 문제 분석 중...

## Round 2: Cross-Examination & Refinement
  - AI가 Round 1 결과를 검토 중...
```

### 2. Heuristic 감지 (Round 2 이후)

AI 응답에서 다음 키워드가 감지되면:
- `unclear`, `uncertain`, `depends on`, `assume` → 낮은 확신도 감지
- `however`, `disagree`, `alternatively` → 교착상태 감지 (Round 3+)

### 3. 사용자 입력 프롬프트 표시

```
==================================================
🤔 Mid-Debate User Input Opportunity
==================================================
Round: 2 / 3

The debate has identified areas where your input could help:

Options:
  1) Provide additional context or clarification
  2) Skip and let the debate continue

Your choice (1-2, default: 2):
```

### 4. 사용자 선택

**Option 1 선택 시:**
```
Please provide your input (press Ctrl+D when done):
---
(여기에 추가 정보 입력)
(Ctrl+D로 입력 종료)
---

Thank you! Incorporating your input into the next round...
```

**Option 2 선택 시 (또는 Enter):**
```
Skipping user input. Debate will continue with AI judgment.
```

---

## 예시 시나리오

### 불확실성이 높은 문제

```bash
./ai-debate.sh "우리 팀 프로젝트에 어떤 데이터베이스를 선택해야 할까요?"
```

**예상 동작:**
1. Round 1: AI가 일반적인 권장사항 제시
2. Round 2: "unclear", "depends on"과 같은 키워드 감지
3. **Heuristic 트리거**: "🤔 Mid-Debate User Input Opportunity" 표시
4. 사용자가 팀 규모, 예상 트래픽 등 추가 정보 제공
5. Round 3: 사용자 입력을 반영한 구체적인 권장사항

### 명확한 문제

```bash
./ai-debate.sh "PostgreSQL과 MySQL의 차이점은?"
```

**예상 동작:**
1. Round 1-3: AI가 자신 있게 답변
2. **Heuristic 미트리거**: 확신도 높은 응답 → 사용자 입력 건너뜀
3. 자동으로 Final Synthesis까지 완료

---

## 결과 확인

Debate 완료 후:

```
==================================================
Debate Complete
==================================================
Results saved to: ./sessions/20251101-140530
```

**생성 파일:**
```
sessions/20251101-140530/
├── rounds/
│   ├── round1_claude_response.txt
│   ├── round2_claude_response.txt
│   ├── round2_user_input.txt         ← 사용자 입력 (있는 경우)
│   ├── round3_claude_response.txt
│   └── final_claude_response.txt
├── debate_summary.md
└── session_info.txt
```

---

## Troubleshooting

### "Non-interactive mode" 메시지가 나타남

**원인:** stdin이 터미널에 연결되지 않음

**해결:**
```bash
# ❌ 잘못된 방법 (파이프 사용)
./ai-debate.sh "topic" | tee output.log

# ✅ 올바른 방법 (직접 실행)
./ai-debate.sh "topic"
```

### Mid-debate 프롬프트가 나타나지 않음

**확인사항:**
1. **Interactive mode인가?** (파이프 없이 직접 실행)
2. **Heuristic 키워드가 있는가?** (응답 파일 확인)
   ```bash
   grep -i "unclear\|uncertain\|disagree" sessions/*/rounds/round2_claude_response.txt
   ```
3. **Round 2 이후인가?** (Round 1에서는 트리거 안 됨)

---

## 고급 사용법

### 특정 모델 사용

facilitator.sh를 직접 호출:
```bash
bash scripts/facilitator.sh "topic" codex simple ./my-session
```

### 모드 변경

```bash
bash scripts/facilitator.sh "topic" claude balanced ./my-session
```

**사용 가능한 모드:**
- `simple` - 3 rounds (기본)
- `balanced` - 5 rounds
- `deep` - 7 rounds

---

## 다음 단계

Mid-debate User Input을 테스트해보셨다면:

1. **실제 문제에 적용**: 팀의 기술 의사결정에 활용
2. **다른 기능 탐색**: Stress-pass Questions, Anti-pattern Detection (Coming soon)
3. **피드백 제공**: 개선 아이디어를 공유해주세요!

---

## Devil's Advocate (Phase 3.2)

**Phase 3.2: Stress-pass Questions / Devil's Advocate**가 토론 품질을 자동으로 향상시킵니다.

### 작동 방식

**Round 2 이후 자동 감지:**
- 합의율 >80% 감지
- 지배적 패턴 감지 (한쪽이 너무 쉽게 동의)

**자동 개입:**
```
💡 Devil's Advocate challenge added to next round

### 🎯 Devil's Advocate Challenge (Round 3)

**Pattern Detected:** High agreement rate in recent rounds.

Before we proceed, please consider:

1. **Potential Issues or Edge Cases**: Are there any scenarios we haven't fully explored?
2. **What Could Go Wrong**: What are the risks or unintended consequences?
3. **Alternative Approaches**: Have we sufficiently explored other viable options?
4. **Hidden Assumptions**: Are we making incorrect assumptions?
5. **Trade-offs**: What are we giving up by choosing this approach?
```

**사용 예시:**
```bash
cd .claude/skills/ai-collaborative-solver
bash scripts/facilitator.sh "Docker vs Kubernetes" claude simple ./test-session
```

**결과 확인:**
```bash
cat ./test-session/rounds/round3_claude_response.txt
# Devil's Advocate 질문에 대한 답변 포함
```

---

## Anti-pattern Detection (Phase 3.3)

**Phase 3.3**는 4가지 토론 품질 문제를 자동 감지합니다.

### 1. Information Starvation (정보 결핍) ⚠️

**감지 조건:**
- 불확실성 단어 ≥5개 (probably, might be, could be, perhaps, assuming...)
- 가정 단어 ≥3개 (assume, assumption, guessing, estimate...)

**출력 예시:**
```
⚠️  Information Starvation detected in claude response
[Information Starvation] Hedging: 7, Assumptions: 4 (thresholds: 5, 3)
```

**의미:** AI가 너무 많은 추측을 하고 있음 → 사용자에게 명확한 정보 요청 필요

### 2. Rapid Turn (빠른 턴) ⏱️

**감지 조건:**
- 2개 연속 라운드에서 <50 단어

**출력 예시:**
```
⏱️  Rapid Turn detected - debate may need more depth
[Rapid Turn] 3 consecutive short responses (<50 words)
```

**의미:** 토론이 너무 얕음 → 더 깊은 탐색 필요

### 3. Policy Trigger (정책/윤리 트리거) 📋

**감지 조건:**
- 정책/윤리 키워드 감지 (ethics, legal, policy, regulation, privacy, GDPR, HIPAA...)

**출력 예시:**
```
📋 Policy/Ethical considerations detected in claude response
[Policy Trigger] 3 policy/ethical keywords detected
```

**의미:** 윤리적/법적 고려사항 발견 → 인간 판단 필요

### 4. Premature Convergence (조기 합의) 🚨

**감지 조건:**
- 라운드 ≤2에서 합의율 >70%

**출력 예시:**
```
🚨 Premature Convergence detected - consider exploring alternatives
[Premature Convergence] Agreement rate: 85% in Round 2 (threshold: 70% in ≤2 rounds)
```

**의미:** 대안 탐색 없이 너무 빠른 합의 → 더 많은 옵션 검토 필요

### 통합 사용 예시

모든 패턴은 자동으로 감지되어 터미널에 출력됩니다:

```bash
cd .claude/skills/ai-collaborative-solver
bash scripts/facilitator.sh "우리 팀 프로젝트에 적합한 데이터베이스는?" claude simple ./test-session

# 출력 예시:
## Round 2: Cross-Examination & Refinement

### claude
⚠️  Information Starvation detected in claude response
  [Information Starvation] Hedging: 6, Assumptions: 4 (thresholds: 5, 3)

## Round 3: Cross-Examination & Refinement

### claude
🚨 Premature Convergence detected - consider exploring alternatives
  [Premature Convergence] Agreement rate: 75% in Round 2 (threshold: 70% in ≤2 rounds)
```

---

**Happy Debating! 🎯**
