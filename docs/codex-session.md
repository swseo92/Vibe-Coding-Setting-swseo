# Codex Session Manager Usage Guide

**범용 Codex Stateful Session 관리 도구**

다른 스크립트와 에이전트에서 Codex와의 multi-round 대화를 쉽게 구현할 수 있습니다.

---

## 개요

### 목적

`codex-session.sh`는 Codex CLI와의 stateful 대화를 관리하는 범용 스크립트입니다:

- ✅ **세션 ID 자동 추적**: Codex 내부 세션 ID를 자동으로 캡처
- ✅ **Multi-round 대화**: 이전 컨텍스트를 유지하며 여러 라운드 진행
- ✅ **파일 기반 관리**: 각 라운드의 입출력을 파일로 저장
- ✅ **에러 핸들링**: 로그 파일에 에러 자동 기록
- ✅ **Cross-platform**: Windows Git Bash, Mac, Linux 호환

### 사용 사례

1. **AI 토론 시스템**: Multi-round 토론 및 분석
2. **코드 리뷰**: 여러 단계에 걸친 코드 검토
3. **문서 작성**: 점진적 문서 개선
4. **아키텍처 분석**: 단계별 시스템 설계 검토

---

## 기본 사용법 (직접 실행)

### 1. 새 세션 시작

```bash
SESSION_ID=$(bash .claude/scripts/codex-session.sh new "Initial prompt")
echo "Session ID: $SESSION_ID"
```

**출력 예시:**
```
[INFO] Starting new Codex session: 3f1058b6-cd23-40cb-a0bc-80c9c15d8de0
[INFO] Session created: .codex-sessions/3f1058b6-cd23-40cb-a0bc-80c9c15d8de0
[INFO] Round 1 completed
3f1058b6-cd23-40cb-a0bc-80c9c15d8de0
```

### 2. 세션 이어가기

```bash
bash .claude/scripts/codex-session.sh continue "$SESSION_ID" "Next question"
bash .claude/scripts/codex-session.sh continue "$SESSION_ID" "Another question"
```

### 3. 세션 정보 조회

```bash
bash .claude/scripts/codex-session.sh info "$SESSION_ID"
```

**출력 예시:**
```
===================================================
Session: 3f1058b6-cd23-40cb-a0bc-80c9c15d8de0
===================================================
Location: .codex-sessions/3f1058b6-cd23-40cb-a0bc-80c9c15d8de0

Metadata:
{
  "session_id": "3f1058b6-cd23-40cb-a0bc-80c9c15d8de0",
  "created_at": "2025-11-03 00:14:15",
  "round_count": 3,
  "status": "active"
}

Rounds:
  - round-001.txt (245 bytes)
  - round-002.txt (312 bytes)
  - round-003.txt (198 bytes)

Codex Session ID: 019a4522-cb3e-7011-a138-68949126239c
```

### 4. 전체 세션 목록

```bash
bash .claude/scripts/codex-session.sh list
```

### 5. 세션 삭제

```bash
bash .claude/scripts/codex-session.sh clean "$SESSION_ID"
```

---

## 스크립트에서 통합하기

### 패턴 1: 간단한 Multi-Round 대화

```bash
#!/usr/bin/env bash

CODEX_SESSION=".claude/scripts/codex-session.sh"
PROBLEM="$1"

# Round 1: 새 세션 시작
SESSION_ID=$(bash "$CODEX_SESSION" new "$PROBLEM")

# Round 2-4: 계속
bash "$CODEX_SESSION" continue "$SESSION_ID" "Deepen the analysis"
bash "$CODEX_SESSION" continue "$SESSION_ID" "Consider edge cases"
bash "$CODEX_SESSION" continue "$SESSION_ID" "Provide final recommendation"

# 결과 출력
bash "$CODEX_SESSION" info "$SESSION_ID"
```

### 패턴 2: 조건부 라운드 (토론 모드별)

```bash
#!/usr/bin/env bash

CODEX_SESSION=".claude/scripts/codex-session.sh"
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
SESSION_ID=$(bash "$CODEX_SESSION" new "Problem: $PROBLEM

Analyze this problem. Round 1 of $ROUNDS.")

# Round 2+
for ((i=2; i<=ROUNDS; i++)); do
    echo "Round $i of $ROUNDS..."
    bash "$CODEX_SESSION" continue "$SESSION_ID" "Continue analysis. Round $i of $ROUNDS."
done

echo "Analysis complete!"
bash "$CODEX_SESSION" info "$SESSION_ID"
```

### 패턴 3: 출력 처리 및 리포트 생성

```bash
#!/usr/bin/env bash

CODEX_SESSION=".claude/scripts/codex-session.sh"
PROBLEM="$1"
REPORT_FILE="debate-report.md"

# 세션 시작
SESSION_ID=$(bash "$CODEX_SESSION" new "$PROBLEM" --output-dir ".debate-reports")

# Multi-round
bash "$CODEX_SESSION" continue "$SESSION_ID" "Round 2 prompt"
bash "$CODEX_SESSION" continue "$SESSION_ID" "Round 3 prompt"

# 세션 디렉토리 가져오기
SESSION_DIR=".codex-sessions/$SESSION_ID"

# 리포트 생성
cat > "$REPORT_FILE" <<EOF
# AI Analysis Report

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

EOF

echo "Report saved to: $REPORT_FILE"
```

### 패턴 4: 에러 핸들링

```bash
#!/usr/bin/env bash

set -euo pipefail

CODEX_SESSION=".claude/scripts/codex-session.sh"
PROBLEM="$1"

# 세션 시작 (에러 핸들링)
if ! SESSION_ID=$(bash "$CODEX_SESSION" new "$PROBLEM" 2>&1); then
    echo "ERROR: Failed to create session"
    echo "$SESSION_ID"
    exit 1
fi

echo "Session created: $SESSION_ID"

# 각 라운드 에러 체크
for round in 2 3 4; do
    if ! bash "$CODEX_SESSION" continue "$SESSION_ID" "Round $round"; then
        echo "ERROR: Round $round failed"
        # 로그 확인
        cat ".codex-sessions/$SESSION_ID/round-$(printf '%03d' $round).log"
        exit 1
    fi
done

echo "All rounds completed successfully"
```

---

## AI 토론 스킬 통합 예시

### V2.0 토론 스크립트 (speckit 기반)

```bash
#!/usr/bin/env bash
# .claude/skills/ai-collaborative-solver-v2.0/scripts/debate.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CODEX_SESSION="$SCRIPT_DIR/../../../scripts/codex-session.sh"

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
echo "AI Debate Session ($MODE mode, $ROUNDS rounds)"
echo "=================================================="
echo ""

# Round 1: Initial analysis
echo "[Round 1/$ROUNDS] Initial Analysis..."
SESSION_ID=$(bash "$CODEX_SESSION" new \
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

    bash "$CODEX_SESSION" continue "$SESSION_ID" \
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
bash "$CODEX_SESSION" info "$SESSION_ID"

# Generate final report
SESSION_DIR=".codex-sessions/$SESSION_ID"
REPORT_FILE=".debate-reports/final-report.md"

cat > "$REPORT_FILE" <<EOF
# AI Debate Report

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

echo ""
echo "Final report: $REPORT_FILE"
```

---

## API 레퍼런스

### `new` - 새 세션 시작

**사용법:**
```bash
SESSION_ID=$(bash codex-session.sh new "prompt" [options])
```

**옵션:**
- `--output-dir <dir>`: 출력 디렉토리 (기본: `.codex-sessions`)
- `--output-format <fmt>`: 출력 형식 `text|json` (기본: `text`)
- `--sandbox <mode>`: 샌드박스 모드 (기본: `workspace-write`)
  - `read-only`: 읽기 전용
  - `workspace-write`: 워크스페이스 쓰기 허용
  - `danger-full-access`: 전체 접근
- `--model <model>`: Codex 모델 (기본: config.toml 설정 사용)
- `--quiet`: 진행 메시지 숨김
- `--debug`: 디버그 출력

**반환값:** 세션 ID (stdout)

**예시:**
```bash
# 기본
SESSION_ID=$(bash codex-session.sh new "Explain Python decorators")

# 커스텀 출력 디렉토리
SESSION_ID=$(bash codex-session.sh new "Problem..." --output-dir ".my-sessions")

# 디버그 모드
SESSION_ID=$(bash codex-session.sh new "Problem..." --debug)
```

### `continue` - 세션 이어가기

**사용법:**
```bash
bash codex-session.sh continue <session-id> "prompt"
```

**예시:**
```bash
bash codex-session.sh continue "$SESSION_ID" "Provide examples"
bash codex-session.sh continue "$SESSION_ID" "What are common pitfalls?"
```

### `info` - 세션 정보 조회

**사용법:**
```bash
bash codex-session.sh info <session-id>
```

**출력:**
- 세션 위치
- 메타데이터 (생성일, 라운드 수, 상태)
- 라운드 목록
- Codex 세션 ID

### `list` - 전체 세션 목록

**사용법:**
```bash
bash codex-session.sh list
```

**출력:** 모든 세션의 요약 정보

### `clean` - 세션 삭제

**사용법:**
```bash
bash codex-session.sh clean <session-id>
```

**경고:** 세션 디렉토리가 완전히 삭제됩니다.

---

## 파일 구조

### 세션 디렉토리 구조

```
.codex-sessions/
└── 3f1058b6-cd23-40cb-a0bc-80c9c15d8de0/
    ├── codex_session_id.txt    # Codex 내부 세션 ID
    ├── metadata.json            # 세션 메타데이터
    ├── problem.txt              # 초기 문제 설명
    ├── round-001.txt            # Round 1 Codex 응답
    ├── round-001.log            # Round 1 실행 로그
    ├── round-002.txt            # Round 2 Codex 응답
    ├── round-002.log            # Round 2 실행 로그
    └── ...
```

### metadata.json 형식

```json
{
  "session_id": "3f1058b6-cd23-40cb-a0bc-80c9c15d8de0",
  "created_at": "2025-11-03 00:14:15",
  "round_count": 3,
  "status": "active"
}
```

### 출력 파일

- **round-XXX.txt**: Codex의 응답 (순수 텍스트)
- **round-XXX.log**: Codex CLI 실행 로그 (세션 정보, 토큰 사용량 등)

---

## 환경 변수

### `CODEX_SESSIONS_DIR`

세션 저장 디렉토리를 변경합니다.

**예시:**
```bash
export CODEX_SESSIONS_DIR="/tmp/my-codex-sessions"
bash codex-session.sh new "Problem..."
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

**원인:** Codex CLI 로그 형식이 예상과 다를 수 있습니다.

**확인:**
```bash
cat .codex-sessions/<session-id>/round-001.log | grep -i "session id"
```

**해결:** 로그에서 session ID가 보이면 스크립트가 정상 작동합니다. 보이지 않으면 `--last` fallback이 사용됩니다.

### 3. "codex command not found"

**원인:** Codex CLI가 설치되지 않았습니다.

**해결:**
```bash
# Codex CLI 설치
npm install -g @openai/codex

# 로그인
codex
```

### 4. Round 2+ 실행 실패

**원인:** Codex session ID가 캡처되지 않아 `--last` fallback 사용 중

**확인:**
```bash
cat .codex-sessions/<session-id>/codex_session_id.txt
```

**해결:** Session ID가 없어도 `codex exec resume --last`로 작동하지만, 동시 다중 세션은 불가능합니다.

### 5. 출력 파일이 비어있음

**원인:** Codex 실행 중 에러 발생

**확인:**
```bash
cat .codex-sessions/<session-id>/round-XXX.log
```

로그 파일에서 에러 메시지를 확인하세요.

---

## 모범 사례

### 1. 명확한 프롬프트 구조

```bash
SESSION_ID=$(bash codex-session.sh new \
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
bash codex-session.sh continue "$SESSION_ID" \
"Round 2: Focus on ORM query optimization. Provide specific code examples."

bash codex-session.sh continue "$SESSION_ID" \
"Round 3: Consider caching strategies. Compare Redis vs in-memory cache."
```

### 3. 중간 결과 확인

```bash
for round in 1 2 3; do
    round_label=$(printf "%03d" $round)
    echo "=== Round $round ==="
    cat ".codex-sessions/$SESSION_ID/round-${round_label}.txt"
    echo ""
done
```

### 4. 에러 로깅

```bash
bash codex-session.sh continue "$SESSION_ID" "prompt" 2>&1 | tee -a debug.log
```

---

## 성능 고려사항

### 토큰 사용량

각 라운드마다 전체 대화 히스토리가 포함되므로 토큰 사용량이 증가합니다.

**예상 비용 (gpt-5-codex 기준):**
- Round 1: ~500 tokens
- Round 2: ~1,000 tokens (누적)
- Round 3: ~1,500 tokens (누적)
- Round 6: ~3,000 tokens (누적)

**권장:**
- Simple mode (3 rounds): 간단한 질문
- Balanced mode (4 rounds): 일반적 사용
- Deep mode (6 rounds): 복잡한 분석

### 실행 시간

각 라운드당 약 10-30초 소요 (Codex 응답 시간 포함)

---

## 관련 문서

- [Codex CLI 공식 문서](https://openai.com/codex)
- [AI Collaborative Solver V2.0 스킬](../.claude/skills/ai-collaborative-solver-v2.0/skill.md)
- [Testing Guidelines](./python/testing_guidelines.md)

---

**버전:** 1.0.0
**최종 업데이트:** 2025-11-03
**작성자:** AI with swseo
