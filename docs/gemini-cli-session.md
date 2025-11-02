# Gemini CLI Session Manager Usage Guide

**범용 Gemini CLI Stateful Session 관리 도구**

다른 스크립트와 에이전트에서 Gemini CLI와의 multi-round 대화를 쉽게 구현할 수 있습니다.

---

## 개요

### 목적

`gemini-cli-session.sh`는 Gemini CLI와의 stateful 대화를 관리하는 범용 스크립트입니다:

- ✅ **수동 컨텍스트 관리**: 대화 이력을 프롬프트에 포함하여 컨텍스트 유지
- ✅ **Multi-round 대화**: 이전 대화를 참조하며 여러 라운드 진행
- ✅ **파일 기반 관리**: 각 라운드의 입출력을 파일로 저장
- ✅ **JSON 메타데이터**: 전체 응답 정보를 JSON으로 보존
- ✅ **Cross-platform**: Windows Git Bash, Mac, Linux 호환

### 사용 사례

1. **AI 토론 시스템**: Multi-round 토론 및 분석
2. **코드 리뷰**: 여러 단계에 걸친 코드 검토
3. **문서 작성**: 점진적 문서 개선
4. **아키텍처 분석**: 단계별 시스템 설계 검토

### 다른 Session Manager와의 차이점

| 특징 | codex-session.sh | claude-code-session.sh | gemini-cli-session.sh |
|------|------------------|------------------------|-----------------------|
| CLI 명령어 | `codex exec` | `claude --print` | `gemini -o json` |
| 세션 재개 | `codex exec resume` | `claude --resume` | **수동 컨텍스트 빌드** |
| 출력 파싱 | 로그 파일 정규식 | JSON 파싱 | JSON 파싱 |
| 네이티브 세션 | ✅ | ✅ | ❌ (스크립트가 관리) |
| 컨텍스트 관리 | 자동 | 자동 | 수동 (last 3 rounds) |
| 메타데이터 | 로그 파일 | JSON + 텍스트 | JSON + 텍스트 |

**주요 차이점:**
- Gemini CLI는 네이티브 세션 관리를 제공하지 않음
- 스크립트가 직접 이전 대화를 프롬프트에 포함하여 컨텍스트 관리
- 메모리 효율을 위해 마지막 3 라운드만 컨텍스트에 포함

---

## 기본 사용법 (직접 실행)

### 1. 새 세션 시작

```bash
SESSION_ID=$(bash .claude/scripts/gemini-cli-session.sh new "Initial prompt")
echo "Session ID: $SESSION_ID"
```

**출력 예시:**
```
[INFO] Starting new Gemini CLI session: f7d0c107-e1cd-49b6-a6c5-e396b80dd49e
[INFO] Session created: .gemini-cli-sessions/f7d0c107-e1cd-49b6-a6c5-e396b80dd49e
[INFO] Round 1 completed
f7d0c107-e1cd-49b6-a6c5-e396b80dd49e
```

### 2. 세션 이어가기

```bash
bash .claude/scripts/gemini-cli-session.sh continue "$SESSION_ID" "Next question"
bash .claude/scripts/gemini-cli-session.sh continue "$SESSION_ID" "Another question"
```

**컨텍스트 빌드 방식:**
```
Previous conversation:

User: What is 2+2?
Assistant: Four

User: What is that number multiplied by 3?
Assistant: Twelve

Current user message: What is that number divided by 4?
```

### 3. 세션 정보 조회

```bash
bash .claude/scripts/gemini-cli-session.sh info "$SESSION_ID"
```

**출력 예시:**
```
===================================================
Session: f7d0c107-e1cd-49b6-a6c5-e396b80dd49e
===================================================
Location: .gemini-cli-sessions/f7d0c107-e1cd-49b6-a6c5-e396b80dd49e

Metadata:
{
  "session_id": "f7d0c107-e1cd-49b6-a6c5-e396b80dd49e",
  "created_at": "2025-11-03 01:12:36",
  "round_count": 3,
  "status": "active"
}

Rounds:
  - round-001.txt (5 bytes)
  - round-002.txt (7 bytes)
  - round-003.txt (6 bytes)
```

### 4. 전체 세션 목록

```bash
bash .claude/scripts/gemini-cli-session.sh list
```

### 5. 세션 삭제

```bash
bash .claude/scripts/gemini-cli-session.sh clean "$SESSION_ID"
```

---

## API 레퍼런스

### Commands

#### `new "prompt" [options]`

새 세션을 시작하고 첫 번째 라운드를 실행합니다.

**파라미터:**
- `prompt`: 초기 프롬프트 (필수)

**옵션:**
- `--output-dir <dir>`: 출력 디렉토리 (기본: `.gemini-cli-sessions`)
- `--output-format <fmt>`: 출력 형식 - `text|json` (기본: `text`)
- `--model <model>`: 모델 (기본: `gemini-2.0-flash-exp`)
- `--quiet`: 진행 메시지 숨기기
- `--debug`: 디버그 출력 활성화

**반환값:**
- stdout: 세션 ID (UUID)
- stderr: 진행 로그

**예시:**
```bash
SESSION_ID=$(bash gemini-cli-session.sh new "Explain Python decorators")
```

#### `continue <session-id> "prompt"`

기존 세션을 이어서 다음 라운드를 실행합니다.

**파라미터:**
- `session-id`: 세션 ID (필수)
- `prompt`: 다음 프롬프트 (필수)

**예시:**
```bash
bash gemini-cli-session.sh continue "$SESSION_ID" "Provide examples"
```

**컨텍스트 관리:**
- 마지막 3 라운드의 대화를 프롬프트에 자동 포함
- 토큰 제한을 고려한 컨텍스트 윈도우 관리

#### `info <session-id>`

세션 정보를 출력합니다.

**파라미터:**
- `session-id`: 세션 ID (필수)

**출력:**
- 세션 위치
- 메타데이터 (JSON)
- 라운드 목록

#### `list`

모든 세션 목록을 출력합니다.

**출력:**
- 각 세션의 ID, 라운드 수, 생성 시간

#### `clean <session-id>`

세션을 삭제합니다.

**파라미터:**
- `session-id`: 세션 ID (필수)

---

## 파일 구조

### 디렉토리 레이아웃

```
.gemini-cli-sessions/
└── <session-id>/
    ├── metadata.json                 # 세션 메타데이터
    ├── problem.txt                   # 초기 문제
    ├── round-001.txt                 # 라운드 1 응답 (텍스트)
    ├── round-001.json                # 라운드 1 전체 출력 (JSON)
    ├── round-001-prompt.txt          # 라운드 1 프롬프트
    ├── round-002.txt                 # 라운드 2 응답
    ├── round-002.json                # 라운드 2 전체 출력
    ├── round-002-prompt.txt          # 라운드 2 프롬프트
    └── ...
```

### metadata.json 구조

```json
{
  "session_id": "f7d0c107-e1cd-49b6-a6c5-e396b80dd49e",
  "created_at": "2025-11-03 01:12:36",
  "round_count": 3,
  "status": "active"
}
```

### round-NNN.json 구조 (Gemini CLI 출력)

```json
{
  "response": "Four\n",
  "stats": {
    "models": {
      "gemini-2.0-flash-exp": {
        "api": {
          "totalRequests": 1,
          "totalErrors": 0,
          "totalLatencyMs": 1120
        },
        "tokens": {
          "prompt": 5076,
          "candidates": 2,
          "total": 5078,
          "cached": 0,
          "thoughts": 0,
          "tool": 0
        }
      }
    },
    "tools": {
      "totalCalls": 0,
      "totalSuccess": 0,
      "totalFail": 0,
      "totalDurationMs": 0
    }
  }
}
```

---

## 통합 패턴

### 패턴 1: Shell 스크립트 통합

```bash
#!/usr/bin/env bash

# 새 세션 시작
SESSION_ID=$(bash gemini-cli-session.sh new "Analyze this codebase")

# 여러 라운드 실행
bash gemini-cli-session.sh continue "$SESSION_ID" "What are the main components?"
bash gemini-cli-session.sh continue "$SESSION_ID" "Are there any issues?"

# 결과 읽기
cat ".gemini-cli-sessions/$SESSION_ID/round-001.txt"
cat ".gemini-cli-sessions/$SESSION_ID/round-002.txt"
cat ".gemini-cli-sessions/$SESSION_ID/round-003.txt"

# 정리
bash gemini-cli-session.sh clean "$SESSION_ID"
```

### 패턴 2: Python 통합

```python
import subprocess
import json
import os

class GeminiSession:
    def __init__(self, script_path=".claude/scripts/gemini-cli-session.sh"):
        self.script = script_path
        self.session_id = None
        self.sessions_dir = ".gemini-cli-sessions"

    def new(self, prompt: str) -> str:
        """새 세션 시작"""
        result = subprocess.run(
            ["bash", self.script, "new", prompt],
            capture_output=True,
            text=True,
            check=True
        )
        self.session_id = result.stdout.strip().split('\n')[-1]
        return self.session_id

    def continue_session(self, prompt: str) -> str:
        """세션 이어가기"""
        subprocess.run(
            ["bash", self.script, "continue", self.session_id, prompt],
            check=True
        )
        return self.get_latest_response()

    def get_latest_response(self) -> str:
        """최신 응답 가져오기"""
        metadata = self.get_metadata()
        round_num = metadata["round_count"]
        round_file = f"{self.sessions_dir}/{self.session_id}/round-{round_num:03d}.txt"
        with open(round_file) as f:
            return f.read().strip()

    def get_metadata(self) -> dict:
        """세션 메타데이터 가져오기"""
        metadata_file = f"{self.sessions_dir}/{self.session_id}/metadata.json"
        with open(metadata_file) as f:
            return json.load(f)

    def get_round_json(self, round_num: int) -> dict:
        """특정 라운드의 전체 JSON 가져오기"""
        json_file = f"{self.sessions_dir}/{self.session_id}/round-{round_num:03d}.json"
        with open(json_file) as f:
            return json.load(f)

    def clean(self):
        """세션 삭제"""
        subprocess.run(["bash", self.script, "clean", self.session_id])

# 사용 예시
session = GeminiSession()
session.new("What is Python?")
print(session.get_latest_response())

response = session.continue_session("Explain decorators")
print(response)

# 토큰 사용량 확인
round1_stats = session.get_round_json(1)
print(f"Tokens: {round1_stats['stats']['models']['gemini-2.0-flash-exp']['tokens']['total']}")

session.clean()
```

### 패턴 3: JSON 메타데이터 활용

```bash
# 특정 라운드의 토큰 사용량 추출
python << EOF
import json
data = json.load(open('.gemini-cli-sessions/$SESSION_ID/round-001.json'))
tokens = data['stats']['models']['gemini-2.0-flash-exp']['tokens']
print(f"Prompt: {tokens['prompt']}, Response: {tokens['candidates']}, Total: {tokens['total']}")
EOF

# 모든 라운드의 토큰 합계
total_tokens=0
for json_file in .gemini-cli-sessions/$SESSION_ID/round-*.json; do
    tokens=$(python -c "import json; data=json.load(open('$json_file')); print(data['stats']['models']['gemini-2.0-flash-exp']['tokens']['total'])")
    total_tokens=$((total_tokens + tokens))
done
echo "Total tokens across all rounds: $total_tokens"
```

### 패턴 4: AI 토론 시스템 통합

```bash
#!/usr/bin/env bash

TOPIC="Should we use TypeScript or JavaScript for this project?"

# Position A (Gemini)
GEMINI_SESSION=$(bash gemini-cli-session.sh new "You are debating FOR TypeScript. Argue why: $TOPIC")

# Position B (Claude Code)
CLAUDE_SESSION=$(bash claude-code-session.sh new "You are debating FOR JavaScript. Argue why: $TOPIC")

# Multi-round debate
for round in {1..3}; do
    echo "=== Round $round ==="

    # Gemini responds
    gemini_response=$(cat ".gemini-cli-sessions/$GEMINI_SESSION/round-$(printf '%03d' $round).txt")
    echo "Gemini (Pro TypeScript): $gemini_response"

    # Claude counters
    bash claude-code-session.sh continue "$CLAUDE_SESSION" "Respond to this TypeScript argument: $gemini_response"
    claude_response=$(cat ".claude-code-sessions/$CLAUDE_SESSION/round-$(printf '%03d' $((round + 1))).txt")
    echo "Claude (Pro JavaScript): $claude_response"

    # Gemini counters
    if [[ $round -lt 3 ]]; then
        bash gemini-cli-session.sh continue "$GEMINI_SESSION" "Respond to this JavaScript argument: $claude_response"
    fi
done

# Cleanup
bash gemini-cli-session.sh clean "$GEMINI_SESSION"
bash claude-code-session.sh clean "$CLAUDE_SESSION"
```

---

## 설정 및 요구사항

### API Key 설정

**방법 1: settings.json (권장)**
```json
{
  "auth": {
    "apiKey": "YOUR_GEMINI_API_KEY"
  }
}
```

파일 위치:
- Windows: `C:\Users\<USERNAME>\.gemini\settings.json`
- Mac/Linux: `~/.gemini/settings.json`

**방법 2: 환경 변수**
```bash
export GEMINI_API_KEY="YOUR_GEMINI_API_KEY"
bash gemini-cli-session.sh new "Test"
```

스크립트는 자동으로 다음 순서로 API Key를 찾습니다:
1. `GEMINI_API_KEY` 환경 변수
2. `~/.gemini/settings.json` 파일
3. `C:/Users/EST/.gemini/settings.json` (Windows)

### 모델 선택

기본 모델: `gemini-2.0-flash-exp`

다른 모델 사용:
```bash
bash gemini-cli-session.sh new "prompt" --model gemini-pro
```

### 환경 변수

```bash
# 세션 디렉토리 변경
export GEMINI_CLI_SESSIONS_DIR="./custom-sessions"
bash gemini-cli-session.sh new "Test"
```

---

## 문제 해결

### API Key 오류

**증상:**
```
[ERROR] GEMINI_API_KEY not set. Please configure it in ~/.gemini/settings.json or export GEMINI_API_KEY
```

**해결:**
1. `~/.gemini/settings.json` 파일 존재 확인
2. JSON 형식이 올바른지 확인
3. `auth.apiKey` 필드가 있는지 확인
4. 또는 환경 변수로 설정: `export GEMINI_API_KEY="..."`

### 컨텍스트 누락

**증상:**
Round 2 이후 이전 대화 내용을 기억하지 못함

**원인:**
- `build_context_prompt` 함수가 round 파일을 찾지 못함
- `-prompt.txt` 파일이 없음

**해결:**
```bash
# 세션 디렉토리 확인
ls -la .gemini-cli-sessions/<session-id>/

# 다음 파일들이 있어야 함:
# - round-001.txt
# - round-001-prompt.txt
# - round-002.txt
# - round-002-prompt.txt
```

### 긴 대화의 토큰 제한

**증상:**
Round 5-6 이후부터 응답이 느려지거나 에러 발생

**원인:**
컨텍스트 빌드 시 마지막 3 라운드만 포함하지만, 각 라운드의 응답이 매우 긴 경우 토큰 제한 초과 가능

**해결:**
```bash
# 수동으로 컨텍스트 윈도우 조정 (스크립트 수정 필요)
# build_context_prompt 함수에서 tail -3을 tail -2로 변경
```

---

## 성능 고려사항

### 컨텍스트 윈도우 관리

**현재 설정:**
- 마지막 **3 라운드**의 대화만 프롬프트에 포함
- 토큰 사용량: ~5000-7000 tokens/round (평균)

**장단점:**

**장점:**
- ✅ 토큰 비용 절감
- ✅ 응답 속도 향상
- ✅ 긴 세션에서도 안정적

**단점:**
- ❌ Round 1-2의 컨텍스트가 Round 6 이후에는 누락됨
- ❌ 장기 컨텍스트가 필요한 작업에는 부적합

### 비용 예상

**Gemini 2.0 Flash 가격 (2025년 기준):**
- Input: $0.075 / 1M tokens
- Output: $0.30 / 1M tokens

**세션 예상 비용 (10 라운드, 평균 응답 길이):**
- Input tokens: ~50,000 (5000/round × 10)
- Output tokens: ~20,000 (2000/round × 10)
- **총 비용: ~$0.01** (매우 저렴!)

**Claude Sonnet 3.5 비교:**
- 같은 세션: ~$0.15
- **Gemini가 약 15배 저렴**

---

## 고급 사용법

### 커스텀 출력 디렉토리

```bash
# 프로젝트별 세션 관리
bash gemini-cli-session.sh new "Analyze API" --output-dir "./project-a-sessions"
bash gemini-cli-session.sh new "Review docs" --output-dir "./project-b-sessions"
```

### 디버그 모드

```bash
# 상세 로그 출력
bash gemini-cli-session.sh new "Test" --debug
```

### Quiet 모드 (스크립트 통합용)

```bash
# 진행 메시지 없이 세션 ID만 반환
SESSION_ID=$(bash gemini-cli-session.sh new "Test" --quiet)
echo "Created: $SESSION_ID"
```

---

## 비교: Gemini vs Claude Code vs Codex

| 항목 | Gemini CLI | Claude Code | OpenAI Codex |
|------|------------|-------------|--------------|
| **세션 관리** | 수동 (스크립트) | 네이티브 | 네이티브 |
| **컨텍스트** | Last 3 rounds | 전체 세션 | 전체 세션 |
| **비용** | 매우 저렴 (~$0.01/10 rounds) | 중간 (~$0.15/10 rounds) | 저렴 (~$20/mo flat) |
| **속도** | 빠름 (~1-2초) | 중간 (~3-5초) | 빠름 (~2-3초) |
| **출력 형식** | JSON | JSON | 로그 파일 |
| **파싱 안정성** | 높음 (JSON) | 높음 (JSON) | 중간 (regex) |
| **장기 세션** | 제한적 (컨텍스트 윈도우) | 우수 (전체 히스토리) | 우수 (전체 히스토리) |

**추천 사용 시나리오:**

- **Gemini CLI**: 단기 토론, 비용 민감, 빠른 응답 필요
- **Claude Code**: 장기 프로젝트, 코드 생성, 전체 컨텍스트 필요
- **Codex**: 코드 중심 작업, 고정 비용 선호

---

## 참고 자료

- [Gemini CLI GitHub](https://github.com/google/generative-ai-cli)
- [Gemini API 문서](https://ai.google.dev/docs)
- [codex-session.sh 가이드](./codex-session.md)
- [claude-code-session.sh 가이드](./claude-code-session.md)

---

**마지막 업데이트**: 2025-11-03
**버전**: 1.0.0
**작성자**: swseo
