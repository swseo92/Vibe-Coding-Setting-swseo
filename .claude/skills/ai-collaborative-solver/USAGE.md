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

**Happy Debating! 🎯**
