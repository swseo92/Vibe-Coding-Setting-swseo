#!/usr/bin/env bash
# post-round-check.sh - 라운드 후 coverage 체크를 위한 발화 추출 및 포맷팅
set -euo pipefail

SCRIPT_NAME=$(basename "$0")

abort() {
  echo "[$SCRIPT_NAME] $1" >&2
  exit "${2:-1}"
}

usage() {
  cat <<'USAGE'
사용법: post-round-check.sh [옵션]

각 라운드 후 발화 내용을 추출하고 facilitator를 위한 프롬프트를 생성합니다.

옵션:
  -r, --round NUMBER        라운드 번호 (필수)
  -s, --session-file FILE   세션 메타데이터 파일 경로
  -d, --state-dir DIR       상태 디렉토리 (기본: XDG/OS 규칙 준수)
  -h, --help                도움말 표시

예시:
  post-round-check.sh -r 2
  post-round-check.sh --round 3 --session-file ./session.json
USAGE
}

resolve_state_dir() {
  if [[ -n "${DEBATE_STATE_DIR:-}" ]]; then
    printf '%s\n' "$DEBATE_STATE_DIR"
    return
  fi
  if [[ -n "${XDG_STATE_HOME:-}" ]]; then
    printf '%s\n' "${XDG_STATE_HOME}/codex-debates"
    return
  fi
  case "${OSTYPE:-}" in
    darwin*) printf '%s\n' "${HOME}/Library/Application Support/codex-debates";;
    msys*|cygwin*) printf '%s\n' "${LOCALAPPDATA:-${HOME}/AppData/Local}/codex-debates";;
    *) printf '%s\n' "${HOME}/.local/state/codex-debates";;
  esac
}

# 인자 파싱
ROUND_NUMBER=""
STATE_DIR=""
SESSION_FILE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -r|--round)
      [[ $# -ge 2 ]] || abort "Missing argument for $1."
      ROUND_NUMBER="$2"
      shift 2
      ;;
    -s|--session-file)
      [[ $# -ge 2 ]] || abort "Missing argument for $1."
      SESSION_FILE="$2"
      shift 2
      ;;
    -d|--state-dir)
      [[ $# -ge 2 ]] || abort "Missing argument for $1."
      STATE_DIR="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      abort "Unknown argument: $1"
      ;;
  esac
done

[[ -n "$ROUND_NUMBER" ]] || abort "라운드 번호가 필요합니다 (-r/--round)."

if [[ -z "$STATE_DIR" ]]; then
  STATE_DIR="$(resolve_state_dir)"
fi

if [[ -z "$SESSION_FILE" ]]; then
  SESSION_FILE="${STATE_DIR}/session.json"
fi

[[ -f "$SESSION_FILE" ]] || abort "세션 파일을 찾을 수 없습니다: $SESSION_FILE"

# Python으로 세션 경로 추출 및 transcript 파싱
PYTHON_BIN=$(command -v python3 || command -v python || abort "Python이 필요합니다.")

FORMATTED_OUTPUT=$("$PYTHON_BIN" - "$SESSION_FILE" "$ROUND_NUMBER" <<'PYTHON_SCRIPT'
import json
import sys
import os
import re

def extract_statements_from_transcript(transcript_text):
    """
    Transcript에서 발화 내용 추출

    Codex CLI의 transcript 형식을 파싱하여 speaker별 발화를 추출합니다.
    """
    statements = []

    # 패턴 1: JSON 형식 (codex exec --json 출력)
    try:
        lines = transcript_text.strip().split('\n')
        for line in lines:
            if not line.strip():
                continue
            try:
                data = json.loads(line)
                if data.get('type') == 'item.completed':
                    item = data.get('item', {})
                    if item.get('type') == 'agent_message':
                        text = item.get('text', '').strip()
                        if text:
                            statements.append({
                                'speaker': 'Codex',
                                'text': text
                            })
            except json.JSONDecodeError:
                continue
    except:
        pass

    # 패턴 2: 일반 텍스트 형식 (speaker: message)
    if not statements:
        pattern = r'^(Claude|Codex|User):\s*(.+)$'
        for line in transcript_text.split('\n'):
            match = re.match(pattern, line.strip(), re.IGNORECASE)
            if match:
                statements.append({
                    'speaker': match.group(1),
                    'text': match.group(2).strip()
                })

    return statements

def format_for_facilitator(statements, round_number):
    """
    Facilitator를 위한 프롬프트 생성
    """
    output = []
    output.append("=" * 70)
    output.append(f"라운드 {round_number} Coverage 체크")
    output.append("=" * 70)
    output.append("")
    output.append("발화 내용:")
    output.append("-" * 70)

    for i, stmt in enumerate(statements, 1):
        speaker = stmt['speaker']
        text = stmt['text']

        # 긴 텍스트는 들여쓰기로 보기 좋게
        lines = text.split('\n')
        output.append(f"\n[{i}] {speaker}:")
        for line in lines:
            if line.strip():
                output.append(f"    {line}")

    output.append("")
    output.append("-" * 70)
    output.append("")
    output.append("Facilitator 질문:")
    output.append("")
    output.append("1. 어떤 차원들이 논의되었나요?")
    output.append("   (architecture, security, performance, UX, testing, ops, cost, compliance)")
    output.append("")
    output.append("2. 이 문제 유형에서 중요한데 빠진 부분이 있나요?")
    output.append("")
    output.append("3. 계속 탐색해야 할까요, 아니면 수렴을 시작할까요?")
    output.append("")
    output.append("4. 기존 차원에 맞지 않는 새로운 주제가 있나요?")
    output.append("")
    output.append("=" * 70)
    output.append("")
    output.append("응답:")
    output.append("")

    return '\n'.join(output)

def main(session_file_path, round_number):
    # 세션 파일에서 transcript 경로 읽기
    with open(session_file_path, 'r', encoding='utf-8') as f:
        session_data = json.load(f)

    session_path = session_data.get('session_path')
    if not session_path:
        print("세션 경로를 찾을 수 없습니다.", file=sys.stderr)
        return 1

    # Transcript 파일 읽기 시도
    transcript_text = ""

    # 1. 세션 디렉토리에서 transcript 파일 찾기
    if os.path.isdir(session_path):
        transcript_file = os.path.join(session_path, 'transcript.txt')
        if os.path.exists(transcript_file):
            with open(transcript_file, 'r', encoding='utf-8') as f:
                transcript_text = f.read()

    # 2. raw 데이터에서 추출 시도
    if not transcript_text:
        raw_data = session_data.get('raw', {})
        if raw_data:
            transcript_text = json.dumps(raw_data, indent=2)

    if not transcript_text:
        print("Transcript를 찾을 수 없습니다.", file=sys.stderr)
        print("\n참고: 이 스크립트는 실제 Codex 세션 transcript가 필요합니다.", file=sys.stderr)
        print("데모 출력을 생성합니다...\n", file=sys.stderr)

        # 데모 데이터
        demo_statements = [
            {
                'speaker': 'Claude',
                'text': 'API 게이트웨이에서 rate limiting을 구현하는 것이 좋을 것 같습니다. 이를 통해 DDoS 공격을 방지할 수 있습니다.'
            },
            {
                'speaker': 'Codex',
                'text': '동의합니다. 하지만 Redis를 사용한 분산 rate limiting을 고려해야 합니다. 단일 서버 메모리 기반은 확장성이 떨어집니다.'
            },
            {
                'speaker': 'Claude',
                'text': '좋은 지적입니다. 추가로 데이터베이스 쿼리 최적화도 필요합니다. 현재 N+1 쿼리 문제가 있어 보입니다.'
            }
        ]

        print(format_for_facilitator(demo_statements, round_number))
        return 0

    # 발화 추출
    statements = extract_statements_from_transcript(transcript_text)

    if not statements:
        print("발화 내용을 추출할 수 없습니다.", file=sys.stderr)
        return 1

    # 포맷팅 및 출력
    print(format_for_facilitator(statements, round_number))
    return 0

if __name__ == '__main__':
    session_file = sys.argv[1]
    round_num = sys.argv[2]
    sys.exit(main(session_file, round_num))
PYTHON_SCRIPT
)

echo "$FORMATTED_OUTPUT"
