#!/usr/bin/env bash
# AI Collaborative Debate - Simple Interactive Wrapper
# Usage: ./ai-debate.sh "Your topic here"

set -euo pipefail

if [[ $# -eq 0 ]]; then
    echo "Usage: ./ai-debate.sh \"topic\""
    echo "Example: ./ai-debate.sh \"Redis vs Memcached\""
    exit 1
fi

TOPIC="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Generate session directory with timestamp
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
SESSION_DIR="$SCRIPT_DIR/sessions/$TIMESTAMP"

echo ""
echo "=================================================="
echo "AI Collaborative Debate - Interactive Mode"
echo "=================================================="
echo "Topic: $TOPIC"
echo "Session: $SESSION_DIR"
echo ""
echo "Press Ctrl+C to cancel, or Enter to start..."
read -r

# Run facilitator in interactive mode (no piping)
cd "$SCRIPT_DIR"
bash scripts/facilitator.sh "$TOPIC" claude simple "$SESSION_DIR"

echo ""
echo "=================================================="
echo "Debate Complete"
echo "=================================================="
echo "Results saved to: $SESSION_DIR"
echo ""
