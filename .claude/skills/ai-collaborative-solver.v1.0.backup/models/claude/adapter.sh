#!/usr/bin/env bash

# Claude Model Adapter (Claude Code CLI)
# Wraps Claude Sonnet 4.5 via Claude Code CLI for unified AI collaborative interface

set -euo pipefail

PROBLEM="${1:-}"
MODE="${2:-balanced}"
STATE_DIR="${3:-./debate-session/claude}"

if [[ -z "$PROBLEM" ]]; then
    echo "Usage: $0 <problem> [mode] [state_dir]" >&2
    exit 1
fi

# Check if Claude Code CLI is available and authenticated
if ! command -v claude &> /dev/null; then
    echo "Error: Claude Code CLI not found" >&2
    echo "" >&2
    echo "Claude Code must be installed and authenticated:" >&2
    echo "  1. Install Claude Code from: https://claude.ai/download" >&2
    echo "  2. Run 'claude' to authenticate" >&2
    echo "  3. Login with your Claude account" >&2
    echo "" >&2
    echo "Recommended: Claude Pro/Max subscription" >&2
    exit 1
fi

mkdir -p "$STATE_DIR"
mkdir -p "$STATE_DIR/metadata"

echo "=================================================="
echo "Claude Model Adapter (Claude Code CLI)"
echo "=================================================="
echo "Model: Claude Sonnet 4.5"
echo "Via: Claude Code CLI (authenticated)"
echo "Problem: $PROBLEM"
echo "Mode: $MODE"
echo "State Dir: $STATE_DIR"
echo "=================================================="
echo ""

# Load mode configuration
MODE_CONFIG=".claude/skills/ai-collaborative-solver/modes/${MODE}.yaml"
if [[ ! -f "$MODE_CONFIG" ]]; then
    echo "Warning: Mode config not found: $MODE_CONFIG" >&2
    echo "Using default settings" >&2
    ROUNDS=4
else
    # Extract rounds from YAML (basic parsing)
    ROUNDS=$(grep "rounds:" "$MODE_CONFIG" | sed 's/.*rounds: *\([0-9]*\).*/\1/' || echo "4")
fi

echo "Rounds: $ROUNDS"
echo ""

# Generate UUID for session ID (Claude requires UUID format)
# Use a simple UUID v4 generation or let Claude create one
SESSION_ID_FILE="$STATE_DIR/session_id.txt"
SESSION_ID=""

# Generate a UUID-like session ID
generate_uuid() {
    # Simple UUID v4 generation (works on most systems)
    if command -v uuidgen &> /dev/null; then
        uuidgen
    elif command -v python3 &> /dev/null; then
        python3 -c "import uuid; print(uuid.uuid4())"
    else
        # Fallback: pseudo-random UUID format
        printf '%08x-%04x-%04x-%04x-%012x\n' $RANDOM $RANDOM $RANDOM $RANDOM $RANDOM$RANDOM
    fi
}

SESSION_ID=$(generate_uuid)
echo "$SESSION_ID" > "$SESSION_ID_FILE"

echo "Session ID: $SESSION_ID"
echo ""

# Function to call Claude via CLI with session management
call_claude() {
    local prompt="$1"
    local round_num="$2"
    local is_first_round="$3"

    local response=""
    local output_file="$STATE_DIR/round${round_num}_output.txt"

    if [[ "$is_first_round" == "true" ]]; then
        # First round: Start new session with specific session ID
        response=$(echo "$prompt" | claude --print --session-id "$SESSION_ID" 2>&1 || echo "Error: Claude CLI call failed")
    else
        # Subsequent rounds: Resume the same session by session ID
        response=$(echo "$prompt" | claude --print --resume "$SESSION_ID" 2>&1 || echo "Error: Claude CLI call failed")
    fi

    # Save output for debugging
    echo "$response" > "$output_file"

    echo "$response"
}

# Round 1: Initial analysis
echo "## Round 1: Claude Initial Analysis"
echo ""

ROUND1_PROMPT="You are participating in a structured debate to solve this problem:

**Problem:** $PROBLEM

**Your task:** Provide an initial analysis covering:
1. Problem understanding and clarification
2. 3-5 potential approaches
3. Key considerations and constraints
4. Initial recommendation with rationale

Be comprehensive but concise. This is Round 1 of $ROUNDS."

# Save user prompt to history
echo "{\"role\":\"user\",\"content\":\"$ROUND1_PROMPT\"}" >> "$CONVERSATION_FILE"

ROUND1_OUTPUT=$(call_claude "$ROUND1_PROMPT" 1 "true")

echo "$ROUND1_OUTPUT"
echo ""
echo "---"
echo ""

# Additional rounds based on mode
for ((i=2; i<=ROUNDS; i++)); do
    echo "## Round $i: Claude Refinement"
    echo ""

    REFINE_PROMPT="Please refine your previous analysis. Consider:
1. Alternative approaches not yet explored
2. Edge cases and limitations
3. Implementation risks and trade-offs
4. Evidence for your recommendations

This is Round $i of $ROUNDS. Build upon your previous responses."

    echo "{\"role\":\"user\",\"content\":\"$REFINE_PROMPT\"}" >> "$CONVERSATION_FILE"

    ROUND_OUTPUT=$(call_claude "$REFINE_PROMPT" "$i" "false")

    echo "$ROUND_OUTPUT"
    echo ""
    echo "---"
    echo ""
done

# Final summary
echo "## Claude Final Summary"
echo ""

SUMMARY_PROMPT="Provide a final comprehensive summary with:

1. **Recommended Solution:** Clear, actionable recommendation
2. **Key Rationale:** Why this is the best approach (3-5 points)
3. **Implementation Steps:** Concrete steps to execute (3-5 steps)
4. **Risks & Mitigations:** Top 3 risks with specific mitigations
5. **Confidence Level:** 0-100% with justification

Be decisive and practical."

echo "{\"role\":\"user\",\"content\":\"$SUMMARY_PROMPT\"}" >> "$CONVERSATION_FILE"

SUMMARY=$(call_claude "$SUMMARY_PROMPT" "final" "false")

echo "$SUMMARY"
echo ""

echo "=================================================="
echo "Claude Analysis Complete"
echo "=================================================="
echo "Session ID: $SESSION_ID"
echo "State saved to: $STATE_DIR"
echo "Conversation history: $CONVERSATION_FILE"
echo ""
