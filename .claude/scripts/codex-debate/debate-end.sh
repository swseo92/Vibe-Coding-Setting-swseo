#!/usr/bin/env bash
# debate-end-v2.sh - End and cleanup a Codex debate session
set -euo pipefail

STATE_DIR="${DEBATE_STATE_DIR:-./debate-session}"

if [[ ! -d "$STATE_DIR" ]]; then
  echo "No session found at $STATE_DIR" >&2
  exit 0
fi

if [[ -f "$STATE_DIR/thread_id.txt" ]]; then
  THREAD_ID=$(cat "$STATE_DIR/thread_id.txt")
  echo "✓ Cleaning up session" >&2
  echo "  thread_id: $THREAD_ID" >&2
fi

rm -rf "$STATE_DIR"
echo "✓ Session cleaned up" >&2
