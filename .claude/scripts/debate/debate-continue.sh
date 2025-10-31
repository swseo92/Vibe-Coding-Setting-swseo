#!/usr/bin/env bash
# debate-continue.sh — resume a Codex debate session or restart if state is invalid.
set -euo pipefail
IFS=$'\n\t'

SCRIPT_NAME=$(basename "$0")
tmp_file=""

cleanup_tmp() {
  if [[ -n "$tmp_file" && -f "$tmp_file" ]]; then
    rm -f "$tmp_file"
  fi
}
trap cleanup_tmp EXIT

on_error() {
  local line=$1
  echo "[$SCRIPT_NAME] command failed near line $line." >&2
}
trap 'on_error $LINENO' ERR

abort() {
  local msg=$1
  local code=${2:-1}
  echo "[$SCRIPT_NAME] $msg" >&2
  exit "$code"
}

usage() {
  cat <<'USAGE'
Usage: debate-continue.sh [options]

Continues an existing Codex session (created via debate-start.sh) or starts a fresh one if the stored state is missing or rejected.

Options:
  -m, --message TEXT         Prompt to send. Use -- to pass text with leading dashes.
  -f, --message-file FILE    Read the prompt from FILE.
  -s, --session-file FILE    Override the metadata file path.
  -d, --state-dir DIR        Override the state directory (default honors XDG/OS conventions).
      --auto-compact-flag F  Override the auto-compaction flag; defaults to saved value or --auto-compact.
      --no-auto-compact      Disable auto-compaction flag entirely.
      --restart              Ignore existing metadata and start a brand-new session.
      --skip-restart         Do not auto-restart; fail instead if the session is invalid.
  -h, --help                 Show this message.

If no message is provided via -m/--message/--message-file, the script reads from STDIN.
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

choose_python() {
  if [[ -n "${PYTHON_BIN:-}" ]]; then
    if command -v "$PYTHON_BIN" >/dev/null 2>&1; then
      printf '%s\n' "$PYTHON_BIN"
      return
    fi
    abort "Requested Python interpreter '$PYTHON_BIN' not found."
  fi
  for candidate in python3 python; do
    if command -v "$candidate" >/dev/null 2>&1; then
      printf '%s\n' "$candidate"
      return
    fi
  done
  abort "Python 3.x is required but not available on PATH."
}

STATE_DIR=""
SESSION_FILE=""
MESSAGE=""
MESSAGE_FILE=""
AUTO_COMPACT_FLAG="${CODEX_AUTO_COMPACT_FLAG:---auto-compact}"
FORCE_RESTART=0
SKIP_AUTORESTART=0
SESSION_PATH=""
SESSION_ID=""
STORED_AUTO_FLAG=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -m|--message)
      [[ $# -ge 2 ]] || abort "Missing argument for $1."
      MESSAGE="$2"
      shift 2
      ;;
    -f|--message-file)
      [[ $# -ge 2 ]] || abort "Missing argument for $1."
      MESSAGE_FILE="$2"
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
    --auto-compact-flag)
      [[ $# -ge 2 ]] || abort "Missing argument for $1."
      AUTO_COMPACT_FLAG="$2"
      shift 2
      ;;
    --no-auto-compact)
      AUTO_COMPACT_FLAG=""
      shift
      ;;
    --restart)
      FORCE_RESTART=1
      shift
      ;;
    --skip-restart)
      SKIP_AUTORESTART=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      if [[ $# -eq 0 ]]; then
        abort "Message expected after -- delimiter."
      fi
      MESSAGE="$*"
      break
      ;;
    *)
      abort "Unknown argument: $1"
      ;;
  esac
done

if [[ -n "$MESSAGE" && -n "${MESSAGE_FILE:-}" ]]; then
  abort "Provide the prompt via one source (--message, --message-file, or STDIN)."
fi

if [[ -z "$MESSAGE" ]]; then
  if [[ -n "${MESSAGE_FILE:-}" ]]; then
    [[ -f "$MESSAGE_FILE" ]] || abort "Message file not found: $MESSAGE_FILE"
    MESSAGE="$(<"$MESSAGE_FILE")"
  else
    if [[ -t 0 ]]; then
      abort "No prompt provided. Use --message/--message-file or pipe via STDIN."
    fi
    MESSAGE="$(cat)"
  fi
fi

if [[ -z "${MESSAGE//[[:space:]]/}" ]]; then
  abort "Prompt is empty after stripping whitespace."
fi

# 한글 응답 요청 (기본 설정)
# CODEX_LANG=en 환경변수로 영어 모드 전환 가능
if [[ "${CODEX_LANG:-ko}" == "ko" ]]; then
  KOREAN_PREFIX="Please continue in Korean (한글) with English technical terms in parentheses.

Format:
- Korean explanations: \"캐싱(caching) 전략...\"
- English code/function names
- Technical terms: \"지연 시간(latency)\"

Continuing discussion:
"
  MESSAGE="${KOREAN_PREFIX}${MESSAGE}"
fi

if [[ -z "$STATE_DIR" ]]; then
  STATE_DIR="$(resolve_state_dir)"
fi
[[ -n "$STATE_DIR" ]] || abort "Failed to resolve session state directory."
if ! mkdir -p "$STATE_DIR"; then
  abort "Unable to create state directory: $STATE_DIR"
fi

if [[ -z "$SESSION_FILE" ]]; then
  SESSION_FILE="${STATE_DIR}/session.json"
fi
SESSION_DIRNAME=$(dirname "$SESSION_FILE")
if ! mkdir -p "$SESSION_DIRNAME"; then
  abort "Unable to create directory for session file: $SESSION_DIRNAME"
fi

command -v codex >/dev/null 2>&1 || abort "codex CLI not found on PATH."
PYTHON_BIN=$(choose_python)

generate_metadata_from_json() {
  local json_payload=$1
  local metadata
  metadata="$(
    printf '%s' "$json_payload" | env DEBATE_AUTO_FLAG="${AUTO_COMPACT_FLAG:-}" DEBATE_LAST_PROMPT="$MESSAGE" "$PYTHON_BIN" -c '
import json, sys, datetime, os

def pick(data, *keys):
    for key in keys:
        val = data.get(key)
        if isinstance(val, str):
            stripped = val.strip()
            if stripped:
                return stripped
        elif val:
            return val
    return None

try:
    raw = json.load(sys.stdin)
except ValueError as exc:
    sys.stderr.write("Failed to parse Codex JSON: {}\n".format(exc))
    raise SystemExit(1)

session = raw.get("session") or {}
path = pick(raw, "session_path", "sessionPath") or pick(session, "path", "session_path", "sessionPath")
if not path:
    sys.stderr.write("Codex response did not include a session path.\n")
    raise SystemExit(1)

sid = pick(raw, "session_id", "sessionId", "sessionID") or pick(session, "id", "session_id", "sessionId")

meta = {
    "session_path": path,
    "session_id": sid,
    "created_at": raw.get("created_at"),
    "updated_at": datetime.datetime.utcnow().replace(microsecond=0).isoformat() + "Z",
    "auto_compact_flag": os.environ.get("DEBATE_AUTO_FLAG") or None,
    "last_prompt": os.environ.get("DEBATE_LAST_PROMPT"),
    "raw": raw,
}
json.dump(meta, sys.stdout, indent=2, sort_keys=True)
sys.stdout.write("\n")
'
  )" || return 1

  SESSION_PARSE="$(
    printf '%s' "$json_payload" | "$PYTHON_BIN" -c '
import json, sys

def pick(data, *keys):
    for key in keys:
        val = data.get(key)
        if isinstance(val, str):
            stripped = val.strip()
            if stripped:
                return stripped
        elif val:
            return val
    return None

try:
    raw = json.load(sys.stdin)
except ValueError as exc:
    sys.stderr.write("Failed to parse Codex JSON: {}\n".format(exc))
    raise SystemExit(1)

session = raw.get("session") or {}
path = pick(raw, "session_path", "sessionPath") or pick(session, "path", "session_path", "sessionPath")
if not path:
    sys.stderr.write("Codex response did not include a session path.\n")
    raise SystemExit(1)

sid = pick(raw, "session_id", "sessionId", "sessionID") or pick(session, "id", "session_id", "sessionId")
sys.stdout.write(str(path).replace("\t", " "))
sys.stdout.write("\t")
sys.stdout.write((str(sid) if sid is not None else "").replace("\t", " "))
sys.stdout.write("\n")
'
  )" || return 1

  IFS=$'\t' read -r SESSION_PATH SESSION_ID <<<"$SESSION_PARSE"
  [[ -n "${SESSION_PATH:-}" ]] || return 1

  umask 077
  tmp_file="${SESSION_FILE}.tmp.$$"
  printf '%s' "$metadata" > "$tmp_file"
  mv "$tmp_file" "$SESSION_FILE"
  tmp_file=""
  return 0
}

start_new_session() {
  {
    echo "[$SCRIPT_NAME] starting a new Codex session..."
  } >&2

  CODEX_ARGS=(exec --json)
  if [[ -n "${AUTO_COMPACT_FLAG:-}" ]]; then
    # shellcheck disable=SC2206
    AUTO_COMPACT_TOKENS=($AUTO_COMPACT_FLAG)
    CODEX_ARGS+=("${AUTO_COMPACT_TOKENS[@]}")
  fi
  CODEX_ARGS+=(-- "$MESSAGE")

  if ! NEW_SESSION_JSON="$(codex "${CODEX_ARGS[@]}")"; then
    abort "codex exec failed while creating a new session. Review the error output above."
  fi

  if ! generate_metadata_from_json "$NEW_SESSION_JSON"; then
    abort "Unable to parse Codex response for the new session."
  fi

  {
    echo "Started Codex session."
    echo "  session_path: $SESSION_PATH"
    if [[ -n "${SESSION_ID:-}" ]]; then
      echo "  session_id: $SESSION_ID"
    fi
    echo "Metadata saved to: $SESSION_FILE"
  } >&2
  if [[ -n "${AUTO_COMPACT_FLAG:-}" ]]; then
    echo "Auto-compaction flag: $AUTO_COMPACT_FLAG" >&2
  fi
}

if (( FORCE_RESTART )); then
  start_new_session
  exit 0
fi

if [[ -r "$SESSION_FILE" ]]; then
  SESSION_INFO="$(
    "$PYTHON_BIN" -c '
import json, sys

if len(sys.argv) < 2:
    raise SystemExit(1)
path = sys.argv[1]
with open(path, "r", encoding="utf-8") as fh:
    data = json.load(fh)

session_path = data.get("session_path") or data.get("sessionPath")
session_id = data.get("session_id") or data.get("sessionId") or ""
auto_flag = data.get("auto_compact_flag") or ""

if not session_path:
    raise SystemExit(1)

print("{}\t{}\t{}".format(str(session_path).replace("\t", " "),
                          str(session_id).replace("\t", " "),
                          str(auto_flag).replace("\t", " ")))
' "$SESSION_FILE"
  )" || SESSION_INFO=""
else
  SESSION_INFO=""
fi

if [[ -z "$SESSION_INFO" ]]; then
  if (( SKIP_AUTORESTART )); then
    abort "Stored session metadata missing or invalid and --skip-restart requested."
  fi
  {
    echo "[$SCRIPT_NAME] existing session metadata missing or invalid; creating a new session."
  } >&2
  start_new_session
  exit 0
fi

IFS=$'\t' read -r SESSION_PATH SESSION_ID STORED_AUTO_FLAG <<<"$SESSION_INFO"

if [[ -z "${AUTO_COMPACT_FLAG:-}" && -n "${STORED_AUTO_FLAG:-}" ]]; then
  AUTO_COMPACT_FLAG="$STORED_AUTO_FLAG"
fi

CODEX_ARGS=(--continue --session "$SESSION_PATH")
if [[ -n "${AUTO_COMPACT_FLAG:-}" ]]; then
  # shellcheck disable=SC2206
  AUTO_COMPACT_TOKENS=($AUTO_COMPACT_FLAG)
  CODEX_ARGS+=("${AUTO_COMPACT_TOKENS[@]}")
fi
CODEX_ARGS+=(-- "$MESSAGE")

if ! codex "${CODEX_ARGS[@]}"; then
  if (( SKIP_AUTORESTART )); then
    abort "codex refused the stored session and auto-restart is disabled."
  fi
  {
    echo "[$SCRIPT_NAME] stored session rejected; restarting the debate with a fresh session."
  } >&2
  start_new_session
  exit 0
fi

if UPDATED_METADATA="$(
  env DEBATE_LAST_PROMPT="$MESSAGE" DEBATE_AUTO_FLAG="${AUTO_COMPACT_FLAG:-}" "$PYTHON_BIN" - "$SESSION_FILE" <<'PY'
import json, sys, datetime, os

path = sys.argv[1]
try:
    with open(path, "r", encoding="utf-8") as fh:
        data = json.load(fh)
except Exception as exc:
    sys.stderr.write("Failed to reload metadata '{}': {}\n".format(path, exc))
    raise SystemExit(1)

message = os.environ.get("DEBATE_LAST_PROMPT")
if message is not None:
    data["last_prompt"] = message

auto_flag = os.environ.get("DEBATE_AUTO_FLAG")
if auto_flag:
    data["auto_compact_flag"] = auto_flag

data["updated_at"] = datetime.datetime.utcnow().replace(microsecond=0).isoformat() + "Z"

json.dump(data, sys.stdout, indent=2, sort_keys=True)
sys.stdout.write("\n")
PY
)"; then
  umask 077
  tmp_file="${SESSION_FILE}.tmp.$$"
  printf '%s' "$UPDATED_METADATA" > "$tmp_file"
  mv "$tmp_file" "$SESSION_FILE"
  tmp_file=""
else
  {
    echo "[$SCRIPT_NAME] warning: failed to refresh metadata file; leaving original in place."
  } >&2
fi

{
  echo "Continued Codex session."
  echo "  session_path: $SESSION_PATH"
  if [[ -n "${SESSION_ID:-}" ]]; then
    echo "  session_id: $SESSION_ID"
  fi
  echo "Metadata updated at: $SESSION_FILE"
} >&2
if [[ -n "${AUTO_COMPACT_FLAG:-}" ]]; then
  echo "Auto-compaction flag: $AUTO_COMPACT_FLAG" >&2
fi
