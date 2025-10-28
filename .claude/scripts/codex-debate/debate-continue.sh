#!/usr/bin/env bash
# debate-continue-v3.sh - Ultra-simple version
set -euo pipefail

STATE_DIR="${DEBATE_STATE_DIR:-./debate-session}"
MESSAGE="${1:-}"

if [[ -z "$MESSAGE" ]]; then
  echo "Usage: $0 <message>" >&2
  exit 1
fi

if [[ ! -f "$STATE_DIR/thread_id.txt" ]]; then
  echo "Error: No session found. Run debate-start-v3.sh first" >&2
  exit 1
fi

THREAD_ID=$(cat "$STATE_DIR/thread_id.txt")

echo "Resuming session: $THREAD_ID" >&2

# Use codex exec with thread_id config to continue the session
codex exec -c "thread_id=\"$THREAD_ID\"" "$MESSAGE" | tee -a "$STATE_DIR/last-output.jsonl"

echo "" >&2
echo "✓ Session continued: $THREAD_ID" >&2
