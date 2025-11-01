#!/usr/bin/env bash

# Codex Model Adapter (V3.0 Enhanced)
# Wraps OpenAI Codex (GPT-5-Codex) CLI for unified AI collaborative interface
# Prepared for Facilitator integration with metadata extraction

set -euo pipefail

PROBLEM="${1:-}"
MODE="${2:-balanced}"
STATE_DIR="${3:-./debate-session/codex}"

if [[ -z "$PROBLEM" ]]; then
    echo "Usage: $0 <problem> [mode] [state_dir]" >&2
    exit 1
fi

# Check if codex CLI is available
if ! command -v codex &> /dev/null; then
    echo "Error: codex CLI not found" >&2
    echo "Install: npm install -g @openai/codex" >&2
    echo "Requires: ChatGPT Plus subscription ($20/month)" >&2
    echo "Model: GPT-5-Codex (best agentic coding model)" >&2
    exit 1
fi

mkdir -p "$STATE_DIR"
mkdir -p "$STATE_DIR/metadata"

echo "=================================================="
echo "Codex Model Adapter (V3.0 Enhanced)"
echo "=================================================="
echo "Model: GPT-5-Codex"
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
    QUALITY_GATES="false"
else
    # Extract configuration from YAML
    ROUNDS=$(grep "rounds:" "$MODE_CONFIG" | sed 's/.*rounds: *\([0-9]*\).*/\1/' || echo "4")
    QUALITY_GATES=$(grep -A2 "quality:" "$MODE_CONFIG" | grep "coverage_required" | grep -q "true" && echo "true" || echo "false")
fi

echo "Rounds: $ROUNDS"
echo "Quality Gates: $QUALITY_GATES"
echo ""

# Function to extract metadata from response
extract_metadata() {
    local output="$1"
    local round="$2"
    local meta_file="$STATE_DIR/metadata/round${round}.json"

    # Extract confidence (if present)
    local confidence=$(echo "$output" | grep -oP "(?i)confidence[: ]*([0-9]{1,3})%" | grep -oP "[0-9]{1,3}" | head -1 || echo "0")

    # Detect evidence markers (T1/T2/T3)
    local has_t1=$(echo "$output" | grep -qi "\[T1\]" && echo "true" || echo "false")
    local has_t2=$(echo "$output" | grep -qi "\[T2\]" && echo "true" || echo "false")
    local has_t3=$(echo "$output" | grep -qi "\[T3\]" && echo "true" || echo "false")

    # Count code blocks and citations (sanitize to ensure numeric values)
    local code_blocks=$(echo "$output" | grep -c '```' 2>/dev/null || echo 0)
    code_blocks=$(echo "$code_blocks" | tr -d '\n\r' | grep -o '[0-9]*' | head -1)
    code_blocks=${code_blocks:-0}

    local citations=$(echo "$output" | grep -c '\[.*\]' 2>/dev/null || echo 0)
    citations=$(echo "$citations" | tr -d '\n\r' | grep -o '[0-9]*' | head -1)
    citations=${citations:-0}

    # Save metadata
    cat > "$meta_file" <<EOF
{
    "round": $round,
    "confidence": $confidence,
    "evidence": {
        "t1_present": $has_t1,
        "t2_present": $has_t2,
        "t3_present": $has_t3
    },
    "metrics": {
        "code_blocks": $((code_blocks / 2)),
        "citations": $citations
    },
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

    echo "  [Metadata: Confidence=${confidence}%, Evidence=T1:$has_t1/T2:$has_t2/T3:$has_t3]"
}

# Start debate session
echo "Starting Codex debate session..."
echo ""

# Round 1: Start debate
if ! DEBATE_STATE_DIR="$STATE_DIR" .claude/scripts/codex-debate/debate-start.sh "$PROBLEM" > /dev/null 2>&1; then
    echo "Error: Failed to start Codex debate session" >&2
    exit 1
fi

if [[ ! -f "$STATE_DIR/thread_id.txt" ]]; then
    echo "Error: No thread ID found. Debate may have failed." >&2
    exit 1
fi

THREAD_ID=$(cat "$STATE_DIR/thread_id.txt")
echo "Session ID: $THREAD_ID"
echo ""

# Get initial response
ROUND1_OUTPUT=$(tail -20 "$STATE_DIR/last-output.jsonl" | grep '"content"' | tail -1 | sed 's/.*"content":"\(.*\)".*/\1/' | sed 's/\\n/\n/g' || echo "Error reading output")

echo "## Round 1: Codex Initial Analysis"
echo ""
echo "$ROUND1_OUTPUT"
extract_metadata "$ROUND1_OUTPUT" 1
echo ""
echo "---"
echo ""

# Save round output for future processing
echo "$ROUND1_OUTPUT" > "$STATE_DIR/round1.txt"

# Additional rounds based on mode
for ((i=2; i<=ROUNDS; i++)); do
    echo "## Round $i: Codex Refinement"
    echo ""

    # Build refinement prompt based on previous rounds
    REFINEMENT_PROMPT="Please refine your analysis. Consider:
1) Alternative approaches not yet explored
2) Edge cases and limitations
3) Implementation risks and trade-offs
4) Evidence to support recommendations (use [T1], [T2], [T3] markers)

This is Round $i of $ROUNDS. Build upon previous responses."

    # Continue debate with refinement prompt
    if ! DEBATE_STATE_DIR="$STATE_DIR" .claude/scripts/codex-debate/debate-continue.sh "$REFINEMENT_PROMPT" > /dev/null 2>&1; then
        echo "Warning: Round $i failed, continuing..." >&2
    fi

    # Extract output
    ROUND_OUTPUT=$(tail -20 "$STATE_DIR/last-output.jsonl" | grep '"content"' | tail -1 | sed 's/.*"content":"\(.*\)".*/\1/' | sed 's/\\n/\n/g' || echo "Error reading output")

    echo "$ROUND_OUTPUT"
    extract_metadata "$ROUND_OUTPUT" "$i"
    echo ""
    echo "---"
    echo ""

    # Save round output
    echo "$ROUND_OUTPUT" > "$STATE_DIR/round${i}.txt"
done

# Final summary with structured format
echo "## Codex Final Summary"
echo ""

SUMMARY_PROMPT="Provide a comprehensive final summary with:

1. **Recommended Solution:** Clear, actionable recommendation
2. **Key Rationale:** Why this is the best approach (3-5 points)
3. **Implementation Steps:** Concrete steps to execute (3-5 steps)
4. **Risks & Mitigations:** Top 3 risks with specific mitigations
5. **Confidence Level:** 0-100% with justification
6. **Evidence Quality:** Mark your evidence with [T1] (documented), [T2] (proven), [T3] (expert consensus)

Be decisive and practical."

DEBATE_STATE_DIR="$STATE_DIR" .claude/scripts/codex-debate/debate-continue.sh "$SUMMARY_PROMPT" > /dev/null 2>&1

SUMMARY=$(tail -30 "$STATE_DIR/last-output.jsonl" | grep '"content"' | tail -1 | sed 's/.*"content":"\(.*\)".*/\1/' | sed 's/\\n/\n/g' || echo "Error reading summary")

echo "$SUMMARY"
extract_metadata "$SUMMARY" "final"
echo ""

# Save final summary
echo "$SUMMARY" > "$STATE_DIR/final_summary.txt"

# Generate aggregate metadata
cat > "$STATE_DIR/metadata/aggregate.json" <<EOF
{
    "session_id": "$THREAD_ID",
    "model": "codex",
    "mode": "$MODE",
    "rounds": $ROUNDS,
    "quality_gates_enabled": $QUALITY_GATES,
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

echo "=================================================="
echo "Codex Analysis Complete"
echo "=================================================="
echo "Session ID: $THREAD_ID"
echo "State saved to: $STATE_DIR"
echo "Metadata saved to: $STATE_DIR/metadata/"
echo ""
echo "Next steps:"
echo "  - Review: $STATE_DIR/final_summary.txt"
echo "  - Metadata: $STATE_DIR/metadata/aggregate.json"
echo ""
