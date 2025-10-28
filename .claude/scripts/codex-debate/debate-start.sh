#!/usr/bin/env bash
# debate-start-v3.sh - Ultra-simple version
set -euo pipefail

STATE_DIR="${DEBATE_STATE_DIR:-./debate-session}"
MESSAGE="${1:-}"

if [[ -z "$MESSAGE" ]]; then
  echo "Usage: $0 <message>" >&2
  exit 1
fi

mkdir -p "$STATE_DIR"

# Run codex and save output
echo "Running codex..." >&2
codex exec --json "$MESSAGE" | tee "$STATE_DIR/last-output.jsonl"

# Extract thread_id using grep and sed (no Python needed!)
THREAD_ID=$(grep '"thread_id"' "$STATE_DIR/last-output.jsonl" | head -1 | sed 's/.*"thread_id":"\([^"]*\)".*/\1/')

echo "" >&2
echo "✓ Session started: $THREAD_ID" >&2
echo "$THREAD_ID" > "$STATE_DIR/thread_id.txt"
date -u +%Y-%m-%dT%H:%M:%SZ > "$STATE_DIR/created_at.txt"
