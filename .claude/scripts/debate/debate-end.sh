#!/usr/bin/env bash
# debate-end.sh — close a Codex debate session and clean up state.
set -euo pipefail
IFS=$'\n\t'

SCRIPT_NAME=$(basename "$0")

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
Usage: debate-end.sh [options]

Attempts to close the current Codex session and removes the saved metadata.

Options:
  -s, --session-file FILE    Override the metadata file path.
  -d, --state-dir DIR        Override the state directory (default honors XDG/OS conventions).
      --skip-remote          Skip remote Codex session termination; only delete local files.
  -h, --help                 Show this message.
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

STATE_DIR=""
SESSION_FILE=""
SKIP_REMOTE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
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
    --skip-remote)
      SKIP_REMOTE=1
      shift
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

if [[ -z "$STATE_DIR" ]]; then
  STATE_DIR="$(resolve_state_dir)"
fi
[[ -n "$STATE_DIR" ]] || abort "Failed to resolve session state directory."

if [[ -z "$SESSION_FILE" ]]; then
  SESSION_FILE="${STATE_DIR}/session.json"
fi

if [[ ! -f "$SESSION_FILE" ]]; then
  echo "[$SCRIPT_NAME] no session file found at $SESSION_FILE; nothing to clean." >&2
  exit 0
fi

PYTHON_BIN=""
if command -v python3 >/dev/null 2>&1; then
  PYTHON_BIN="python3"
elif command -v python >/dev/null 2>&1; then
  PYTHON_BIN="python"
else
  abort "Python 3.x is required to parse session metadata."
fi

SESSION_INFO="$(
  "$PYTHON_BIN" -c '
import json, sys

path = sys.argv[1]
with open(path, "r", encoding="utf-8") as fh:
    data = json.load(fh)

session_path = data.get("session_path") or data.get("sessionPath") or ""
session_id = data.get("session_id") or data.get("sessionId") or ""
print("{}\t{}".format(str(session_path).replace("\t", " "),
                      str(session_id).replace("\t", " ")))
' "$SESSION_FILE"
)" || abort "Failed to parse session metadata ($SESSION_FILE)."

IFS=$'\t' read -r SESSION_PATH SESSION_ID <<<"$SESSION_INFO"

if (( SKIP_REMOTE )); then
  echo "[$SCRIPT_NAME] skipping remote termination as requested." >&2
else
  if [[ -n "${SESSION_PATH:-}" ]]; then
    if codex sessions close --session "$SESSION_PATH" >/dev/null 2>&1; then
      echo "[$SCRIPT_NAME] closed remote session via 'codex sessions close'." >&2
    elif codex --continue --session "$SESSION_PATH" --end >/dev/null 2>&1; then
      echo "[$SCRIPT_NAME] closed remote session via '--end'." >&2
    else
      echo "[$SCRIPT_NAME] warning: unable to auto-close remote session; please verify manually." >&2
    fi
  else
    echo "[$SCRIPT_NAME] warning: metadata missing session_path; skipping remote termination." >&2
  fi
fi

if rm -f "$SESSION_FILE"; then
  echo "[$SCRIPT_NAME] removed local session file: $SESSION_FILE" >&2
else
  echo "[$SCRIPT_NAME] warning: failed to remove $SESSION_FILE" >&2
fi

if [[ -d "$STATE_DIR" ]]; then
  if rmdir "$STATE_DIR" 2>/dev/null; then
    echo "[$SCRIPT_NAME] removed empty state directory: $STATE_DIR" >&2
  fi
fi

{
  echo "Ended Codex session cleanup."
  if [[ -n "${SESSION_ID:-}" ]]; then
    echo "  session_id: $SESSION_ID"
  fi
  if [[ -n "${SESSION_PATH:-}" ]]; then
    echo "  session_path: $SESSION_PATH"
  fi
} >&2
