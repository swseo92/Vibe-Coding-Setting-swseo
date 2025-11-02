# Claude Code Session Manager Usage Guide

**범용 Claude Code Stateful Session 관리 도구**

다른 스크립트와 에이전트에서 Claude Code와의 multi-round 대화를 쉽게 구현할 수 있습니다.

---

## 개요

### 목적

`claude-code-session.sh`는 Claude Code CLI와의 stateful 대화를 관리하는 범용 스크립트입니다:

- ✅ **세션 ID 자동 추적**: Claude Code 내부 세션 ID를 자동으로 캡처
- ✅ **Multi-round 대화**: 이전 컨텍스트를 유지하며 여러 라운드 진행
- ✅ **파일 기반 관리**: 각 라운드의 입출력을 파일로 저장
- ✅ **JSON 메타데이터**: 전체 응답 정보를 JSON으로 보존
- ✅ **Cross-platform**: Windows Git Bash, Mac, Linux 호환

### 사용 사례

1. **AI 토론 시스템**: Multi-round 토론 및 분석
2. **코드 리뷰**: 여러 단계에 걸친 코드 검토
3. **문서 작성**: 점진적 문서 개선
4. **아키텍처 분석**: 단계별 시스템 설계 검토

### Codex와의 차이점

| 특징 | codex-session.sh | claude-code-session.sh |
|------|------------------|------------------------|
| CLI 명령어 | `codex exec` | `claude --print` |
| 세션 재개 | `codex exec resume` | `claude --resume` |
| 출력 파싱 | 로그 파일 정규식 | JSON 파싱 (더 정확) |
| 비용 | ChatGPT Plus ($20/mo) | Claude 구독 (Pro/Max) |
| 메타데이터 | 로그 파일 | JSON + 텍스트 파일 |

---

## 기본 사용법 (직접 실행)

### 1. 새 세션 시작

```bash
SESSION_ID=$(bash .claude/scripts/claude-code-session.sh new "Initial prompt")
echo "Session ID: $SESSION_ID"
```

**출력 예시:**
```
[INFO] Starting new Claude Code session: e33a9e57-30b3-4baa-986f-9d97257db966
[INFO] Session created: .claude-code-sessions/e33a9e57-30b3-4baa-986f-9d97257db966
[INFO] Round 1 completed
e33a9e57-30b3-4baa-986f-9d97257db966
```

### 2. 세션 이어가기

```bash
bash .claude/scripts/claude-code-session.sh continue "$SESSION_ID" "Next question"
bash .claude/scripts/claude-code-session.sh continue "$SESSION_ID" "Another question"
```

### 3. 세션 정보 조회

```bash
bash .claude/scripts/claude-code-session.sh info "$SESSION_ID"
```

**출력 예시:**
```
===================================================
Session: e33a9e57-30b3-4baa-986f-9d97257db966
===================================================
Location: .claude-code-sessions/e33a9e57-30b3-4baa-986f-9d97257db966

Metadata:
{
  "session_id": "e33a9e57-30b3-4baa-986f-9d97257db966",
  "created_at": "2025-11-03 00:42:33",
  "round_count": 3,
  "status": "active"
}

Rounds:
  - round-001.txt (245 bytes)
  - round-002.txt (312 bytes)
  - round-003.txt (198 bytes)

Claude Code Session ID: 30876403-fefe-42d6-a65c-02046eb65887
```

### 4. 전체 세션 목록

```bash
bash .claude/scripts/claude-code-session.sh list
```

### 5. 세션 삭제

```bash
bash .claude/scripts/claude-code-session.sh clean "$SESSION_ID"
```

---

## 스크립트에서 통합하기

### 패턴 1: 간단한 Multi-Round 대화

```bash
#!/usr/bin/env bash

CLAUDE_SESSION=".claude/scripts/claude-code-session.sh"
PROBLEM="$1"

# Round 1: 새 세션 시작
SESSION_ID=$(bash "$CLAUDE_SESSION" new "$PROBLEM")

# Round 2-4: 계속
bash "$CLAUDE_SESSION" continue "$SESSION_ID" "Deepen the analysis"
bash "$CLAUDE_SESSION" continue "$SESSION_ID" "Consider edge cases"
bash "$CLAUDE_SESSION" continue "$SESSION_ID" "Provide final recommendation"

# 결과 출력
bash "$CLAUDE_SESSION" info "$SESSION_ID"
```

### 패턴 2: 조건부 라운드 (토론 모드별)

```bash
#!/usr/bin/env bash

CLAUDE_SESSION=".claude/scripts/claude-code-session.sh"
PROBLEM="$1"
MODE="${2:-balanced}"  # simple/balanced/deep

# 모드별 라운드 수 결정
case "$MODE" in
    simple) ROUNDS=3 ;;
    balanced) ROUNDS=4 ;;
    deep) ROUNDS=6 ;;
esac

echo "Starting $MODE mode with $ROUNDS rounds..."

# Round 1
SESSION_ID=$(bash "$CLAUDE_SESSION" new "Problem: $PROBLEM

Analyze this problem. Round 1 of $ROUNDS.")

# Round 2+
for ((i=2; i<=ROUNDS; i++)); do
    echo "Round $i of $ROUNDS..."
    bash "$CLAUDE_SESSION" continue "$SESSION_ID" "Continue analysis. Round $i of $ROUNDS."
done

echo "Analysis complete!"
bash "$CLAUDE_SESSION" info "$SESSION_ID"
```

### 패턴 3: JSON 메타데이터 활용

```bash
#!/usr/bin/env bash

CLAUDE_SESSION=".claude/scripts/claude-code-session.sh"
PROBLEM="$1"

# 세션 시작
SESSION_ID=$(bash "$CLAUDE_SESSION" new "$PROBLEM")

# JSON 메타데이터 읽기
SESSION_DIR=".claude-code-sessions/$SESSION_ID"

# 토큰 사용량 추출
TOKENS=$(python3 -c "
import json
data = json.load(open('$SESSION_DIR/round-001.json'))
usage = data.get('usage', {})
print(f\"Input: {usage.get('input_tokens', 0)}, Output: {usage.get('output_tokens', 0)}\")
")

echo "Token usage: $TOKENS"

# 비용 추출
COST=$(python3 -c "
import json
data = json.load(open('$SESSION_DIR/round-001.json'))
print(data.get('total_cost_usd', 0))
")

echo "Cost: \$$COST USD"
```

### 패턴 4: 출력 처리 및 리포트 생성

```bash
#!/usr/bin/env bash

CLAUDE_SESSION=".claude/scripts/claude-code-session.sh"
PROBLEM="$1"
REPORT_FILE="debate-report.md"

# 세션 시작
SESSION_ID=$(bash "$CLAUDE_SESSION" new "$PROBLEM" --output-dir ".debate-reports")

# Multi-round
bash "$CLAUDE_SESSION" continue "$SESSION_ID" "Round 2 prompt"
bash "$CLAUDE_SESSION" continue "$SESSION_ID" "Round 3 prompt"

# 세션 디렉토리 가져오기
SESSION_DIR=".claude-code-sessions/$SESSION_ID"

# 리포트 생성
cat > "$REPORT_FILE" <<EOF
# AI Analysis Report (Claude Code)

**Problem:** $PROBLEM
**Session ID:** $SESSION_ID
**Date:** $(date)

---

## Round 1

$(cat "$SESSION_DIR/round-001.txt")

---

## Round 2

$(cat "$SESSION_DIR/round-002.txt")

---

## Round 3

$(cat "$SESSION_DIR/round-003.txt")

---

## Metadata

\`\`\`json
$(cat "$SESSION_DIR/round-003.json" | python3 -m json.tool)
\`\`\`

EOF

echo "Report saved to: $REPORT_FILE"
```

---

## AI 토론 스킬 통합 예시

### V2.0 토론 스크립트 (Claude Code 버전)

```bash
#!/usr/bin/env bash
# .claude/skills/ai-collaborative-solver-v2.0/scripts/claude-debate.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_SESSION="$SCRIPT_DIR/../../../scripts/claude-code-session.sh"

# Input (from clarification stage)
CLARIFIED_PROBLEM="$1"
MODE="${2:-balanced}"

# Determine rounds
case "$MODE" in
    simple) ROUNDS=3 ;;
    balanced) ROUNDS=4 ;;
    deep) ROUNDS=6 ;;
esac

echo "=================================================="
echo "AI Debate Session - Claude Code ($MODE mode, $ROUNDS rounds)"
echo "=================================================="
echo ""

# Round 1: Initial analysis
echo "[Round 1/$ROUNDS] Initial Analysis..."
SESSION_ID=$(bash "$CLAUDE_SESSION" new \
    "AI Debate Analysis:

Problem: $CLARIFIED_PROBLEM

Provide:
1. Key considerations
2. Possible approaches
3. Trade-offs

Keep analysis concise and structured." \
    --output-dir ".debate-reports")

# Round 2+: Progressive refinement
for ((i=2; i<=ROUNDS; i++)); do
    echo "[Round $i/$ROUNDS] Deepening analysis..."

    bash "$CLAUDE_SESSION" continue "$SESSION_ID" \
        "Round $i of $ROUNDS:

- Challenge previous assumptions
- Consider edge cases
- Deepen technical analysis
- Provide concrete recommendations"
done

echo ""
echo "=================================================="
echo "Debate Complete!"
echo "=================================================="

# Show session info
bash "$CLAUDE_SESSION" info "$SESSION_ID"

# Generate final report with metadata
SESSION_DIR=".claude-code-sessions/$SESSION_ID"
REPORT_FILE=".debate-reports/claude-final-report.md"

cat > "$REPORT_FILE" <<EOF
# AI Debate Report (Claude Code)

**Problem:** $CLARIFIED_PROBLEM
**Mode:** $MODE ($ROUNDS rounds)
**Session ID:** $SESSION_ID
**Generated:** $(date)

---

EOF

for ((i=1; i<=ROUNDS; i++)); do
    round_label=$(printf "%03d" $i)
    cat >> "$REPORT_FILE" <<EOF
## Round $i

$(cat "$SESSION_DIR/round-${round_label}.txt")

---

EOF
done

# Add cost summary
cat >> "$REPORT_FILE" <<EOF

## Cost Summary

\`\`\`json
$(python3 -c "
import json
total_cost = 0
for i in range(1, $ROUNDS + 1):
    path = '$SESSION_DIR/round-' + str(i).zfill(3) + '.json'
    try:
        data = json.load(open(path))
        cost = data.get('total_cost_usd', 0)
        total_cost += cost
        print(f'Round {i}: \${cost:.5f}')
    except:
        pass
print(f'Total: \${total_cost:.5f}')
")
\`\`\`

EOF

echo ""
echo "Final report: $REPORT_FILE"
```

---

## API 레퍼런스

### `new` - 새 세션 시작

**사용법:**
```bash
SESSION_ID=$(bash claude-code-session.sh new "prompt" [options])
```

**옵션:**
- `--output-dir <dir>`: 출력 디렉토리 (기본: `.claude-code-sessions`)
- `--output-format <fmt>`: 출력 형식 `text|json` (기본: `text`)
- `--model <model>`: Claude Code 모델 (기본: auto)
- `--quiet`: 진행 메시지 숨김
- `--debug`: 디버그 출력

**반환값:** 세션 ID (stdout)

**예시:**
```bash
# 기본
SESSION_ID=$(bash claude-code-session.sh new "Explain Python decorators")

# 커스텀 출력 디렉토리
SESSION_ID=$(bash claude-code-session.sh new "Problem..." --output-dir ".my-sessions")

# 디버그 모드
SESSION_ID=$(bash claude-code-session.sh new "Problem..." --debug)
```

### `continue` - 세션 이어가기

**사용법:**
```bash
bash claude-code-session.sh continue <session-id> "prompt"
```

**예시:**
```bash
bash claude-code-session.sh continue "$SESSION_ID" "Provide examples"
bash claude-code-session.sh continue "$SESSION_ID" "What are common pitfalls?"
```

### `info` - 세션 정보 조회

**사용법:**
```bash
bash claude-code-session.sh info <session-id>
```

**출력:**
- 세션 위치
- 메타데이터 (생성일, 라운드 수, 상태)
- 라운드 목록
- Claude Code 세션 ID

### `list` - 전체 세션 목록

**사용법:**
```bash
bash claude-code-session.sh list
```

**출력:** 모든 세션의 요약 정보

### `clean` - 세션 삭제

**사용법:**
```bash
bash claude-code-session.sh clean <session-id>
```

**경고:** 세션 디렉토리가 완전히 삭제됩니다.

---

## 파일 구조

### 세션 디렉토리 구조

```
.claude-code-sessions/
└── e33a9e57-30b3-4baa-986f-9d97257db966/
    ├── claude_session_id.txt    # Claude Code 내부 세션 ID
    ├── metadata.json             # 세션 메타데이터
    ├── problem.txt               # 초기 문제 설명
    ├── round-001.txt             # Round 1 텍스트 응답
    ├── round-001.json            # Round 1 전체 JSON (토큰, 비용 등)
    ├── round-002.txt             # Round 2 텍스트 응답
    ├── round-002.json            # Round 2 전체 JSON
    └── ...
```

### metadata.json 형식

```json
{
  "session_id": "e33a9e57-30b3-4baa-986f-9d97257db966",
  "created_at": "2025-11-03 00:42:33",
  "round_count": 3,
  "status": "active"
}
```

### round-XXX.json 형식 (Claude Code 응답)

```json
{
  "type": "result",
  "subtype": "success",
  "is_error": false,
  "duration_ms": 13216,
  "result": "텍스트 응답...",
  "session_id": "30876403-fefe-42d6-a65c-02046eb65887",
  "total_cost_usd": 0.00695,
  "usage": {
    "input_tokens": 3,
    "cache_creation_input_tokens": 37085,
    "cache_read_input_tokens": 0,
    "output_tokens": 132
  }
}
```

---

## 환경 변수

### `CLAUDE_CODE_SESSIONS_DIR`

세션 저장 디렉토리를 변경합니다.

**예시:**
```bash
export CLAUDE_CODE_SESSIONS_DIR="/tmp/my-claude-sessions"
bash claude-code-session.sh new "Problem..."
```

---

## 문제 해결

### 1. "python/python3 required" 에러

**원인:** JSON 파싱을 위해 Python이 필요합니다.

**해결:**
```bash
# Python 설치 확인
python --version
# 또는
python3 --version
```

Windows Git Bash에서는 보통 `python` 명령이 작동합니다.

### 2. Session ID 캡처 실패

**원인:** JSON 파싱 실패

**확인:**
```bash
cat .claude-code-sessions/<session-id>/round-001.json | python3 -m json.tool
```

**해결:** JSON 파일이 유효한지 확인. Claude Code가 정상적으로 응답했는지 체크.

### 3. "claude command not found"

**원인:** Claude Code CLI가 설치되지 않았습니다.

**해결:**
```bash
# Claude Code 설치 확인
claude --version

# 업데이트
claude update
```

### 4. Round 2+ 실행 실패

**원인:** Claude Code session ID가 캡처되지 않아 `--continue` fallback 사용 중

**확인:**
```bash
cat .claude-code-sessions/<session-id>/claude_session_id.txt
```

**해결:** Session ID가 없어도 `claude --continue`로 작동하지만, 동시 다중 세션은 불가능합니다.

### 5. 출력 파일이 비어있음

**원인:** Claude Code 실행 중 에러 발생

**확인:**
```bash
cat .claude-code-sessions/<session-id>/round-XXX.json
# 또는
cat .claude-code-sessions/<session-id>/error.log
```

JSON 파일에서 `is_error: true` 확인.

---

## 모범 사례

### 1. 명확한 프롬프트 구조

```bash
SESSION_ID=$(bash claude-code-session.sh new \
"Context: Django 4.2 API performance issue

Problem: API response time is 2 seconds, need to reduce to 500ms

Constraints:
- 1 week timeline
- No DBA available
- PostgreSQL 14

Task: Provide optimization recommendations")
```

### 2. 라운드별 명확한 목표

```bash
bash claude-code-session.sh continue "$SESSION_ID" \
"Round 2: Focus on ORM query optimization. Provide specific code examples."

bash claude-code-session.sh continue "$SESSION_ID" \
"Round 3: Consider caching strategies. Compare Redis vs in-memory cache."
```

### 3. JSON 메타데이터 활용

```bash
# 비용 추적
for i in {1..4}; do
    round_label=$(printf "%03d" $i)
    cost=$(python3 -c "import json; print(json.load(open('.claude-code-sessions/$SESSION_ID/round-${round_label}.json')).get('total_cost_usd', 0))")
    echo "Round $i cost: \$$cost"
done
```

### 4. 에러 로깅

```bash
bash claude-code-session.sh continue "$SESSION_ID" "prompt" 2>&1 | tee -a debug.log
```

---

## 성능 고려사항

### 토큰 사용량

각 라운드마다 전체 대화 히스토리가 포함되므로 토큰 사용량이 증가합니다.

**예상 토큰 (Claude Sonnet 4.5 기준):**
- Round 1: ~500 tokens
- Round 2: ~1,000 tokens (누적)
- Round 3: ~1,500 tokens (누적)
- Round 6: ~3,000 tokens (누적)

**비용 (Claude Code 기준):**
- Input: $3/M tokens
- Output: $15/M tokens
- Round당 평균: $0.005 - $0.02

**권장:**
- Simple mode (3 rounds): 간단한 질문
- Balanced mode (4 rounds): 일반적 사용
- Deep mode (6 rounds): 복잡한 분석

### 실행 시간

각 라운드당 약 10-30초 소요 (Claude Code 응답 시간 포함)

### 프롬프트 캐싱

Claude Code는 자동으로 프롬프트 캐싱을 사용합니다:
- `cache_creation_input_tokens`: 첫 실행 시 캐시 생성
- `cache_read_input_tokens`: 재사용 시 무료

이를 활용하면 비용을 90% 절감할 수 있습니다!

---

## Codex와 비교

### 언제 Claude Code를 사용할까?

**Claude Code 사용 권장:**
- ✅ 복잡한 추론과 분석
- ✅ 문서 작성 및 설명
- ✅ 아키텍처 설계
- ✅ 코드 리뷰 (논리 검증)

**Codex 사용 권장:**
- ✅ 코드 생성 및 구현
- ✅ 버그 수정
- ✅ 알고리즘 최적화
- ✅ 기술 스택 결정 (구현 중심)

### 비용 비교

| 항목 | Claude Code | Codex |
|------|-------------|-------|
| 구독 | Claude Pro/Max | ChatGPT Plus |
| 비용 | $20-60/월 | $20/월 |
| 토큰당 비용 | $3-15/M | $0.15-0.60/M |
| 캐싱 | ✅ 자동 (90% 절감) | ❌ 없음 |
| 세션 관리 | ✅ 네이티브 | ✅ 네이티브 |

---

## 관련 문서

- [Codex Session Manager](./codex-session.md)
- [Claude Code 공식 문서](https://docs.claude.com/claude-code)
- [AI Collaborative Solver V2.0 스킬](../.claude/skills/ai-collaborative-solver-v2.0/skill.md)

---

**버전:** 1.0.0
**최종 업데이트:** 2025-11-03
**작성자:** AI with swseo
