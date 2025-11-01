#!/usr/bin/env bash

# Gemini Model Adapter (Enhanced)
# Wraps Gemini CLI for unified AI collaborative interface
# With Google Search grounding and metadata extraction

set -euo pipefail

PROBLEM="${1:-}"
MODE="${2:-balanced}"
ENABLE_SEARCH="${3:-false}"
STATE_DIR="${4:-./debate-session/gemini}"

if [[ -z "$PROBLEM" ]]; then
    echo "Usage: $0 <problem> [mode] [search] [state_dir]" >&2
    exit 1
fi

# Check API key
if [[ -z "${GEMINI_API_KEY:-}" ]]; then
    # Try to load from settings.json
    if [[ -f "$HOME/.gemini/settings.json" ]]; then
        GEMINI_API_KEY=$(grep -oP '"apiKey":\s*"\K[^"]+' "$HOME/.gemini/settings.json" 2>/dev/null || echo "")
    fi

    if [[ -z "$GEMINI_API_KEY" ]]; then
        echo "Error: GEMINI_API_KEY not set" >&2
        echo "" >&2
        echo "Set API key in one of these ways:" >&2
        echo "  1. export GEMINI_API_KEY='your-key'" >&2
        echo "  2. Add to ~/.gemini/settings.json: {\"auth\":{\"apiKey\":\"your-key\"}}" >&2
        echo "  3. Get free API key: https://aistudio.google.com/app/apikey" >&2
        exit 1
    fi
fi

# Export API key for gemini CLI
export GEMINI_API_KEY

# Check if Gemini CLI is available
GEMINI_CMD=""
if command -v gemini &> /dev/null; then
    GEMINI_CMD="gemini"
elif command -v npx &> /dev/null; then
    GEMINI_CMD="npx -y @google/gemini-cli"
else
    echo "Error: Neither gemini nor npx is available" >&2
    echo "Install: npm install -g @google/gemini-cli" >&2
    echo "Or ensure npx is available (comes with Node.js)" >&2
    exit 1
fi

mkdir -p "$STATE_DIR"
mkdir -p "$STATE_DIR/metadata"

echo "=================================================="
echo "Gemini Model Adapter (Enhanced)"
echo "=================================================="
echo "Model: Gemini 2.5 Pro"
echo "Problem: $PROBLEM"
echo "Mode: $MODE"
echo "Google Search: $([ "$ENABLE_SEARCH" = true ] && echo "Enabled" || echo "Disabled")"
echo "Context: 1M tokens"
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

# Generate session ID
SESSION_ID="gemini-$(date +%Y%m%d-%H%M%S)"
echo "$SESSION_ID" > "$STATE_DIR/session_id.txt"

# Function to extract metadata from response
extract_metadata() {
    local output="$1"
    local round="$2"
    local agent="$3"
    local meta_file="$STATE_DIR/metadata/round${round}.json"

    # Extract confidence (if present)
    local confidence=$(echo "$output" | grep -oP "(?i)confidence[: ]*([0-9]{1,3})%" | grep -oP "[0-9]{1,3}" | head -1 || echo "0")

    # Detect search usage
    local used_search=$(echo "$output" | grep -qi "search\|source\|according to" && echo "true" || echo "false")

    # Count sources and citations (sanitize to ensure numeric values)
    local sources=$(echo "$output" | grep -c "http" 2>/dev/null || echo 0)
    sources=$(echo "$sources" | tr -d '\n\r' | grep -o '[0-9]*' | head -1)
    sources=${sources:-0}

    local citations=$(echo "$output" | grep -c '\[.*\]' 2>/dev/null || echo 0)
    citations=$(echo "$citations" | tr -d '\n\r' | grep -o '[0-9]*' | head -1)
    citations=${citations:-0}

    # Detect evidence markers
    local has_t1=$(echo "$output" | grep -qi "\[T1\]" && echo "true" || echo "false")
    local has_t2=$(echo "$output" | grep -qi "\[T2\]" && echo "true" || echo "false")
    local has_t3=$(echo "$output" | grep -qi "\[T3\]" && echo "true" || echo "false")

    # Save metadata
    cat > "$meta_file" <<EOF
{
    "round": $round,
    "agent": "$agent",
    "confidence": $confidence,
    "search": {
        "enabled": $ENABLE_SEARCH,
        "used": $used_search,
        "sources_found": $sources
    },
    "evidence": {
        "t1_present": $has_t1,
        "t2_present": $has_t2,
        "t3_present": $has_t3
    },
    "metrics": {
        "citations": $citations
    },
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

    echo "  [Metadata: Agent=$agent, Confidence=${confidence}%, Search=$used_search, Sources=$sources]"
}

# Agent roles for each round
AGENTS=("explorer" "critic" "synthesizer" "security" "performance" "integrator")

# Run debate rounds
for ((i=1; i<=ROUNDS && i<=6; i++)); do
    AGENT="${AGENTS[$((i-1))]}"
    AGENT_NAME=""
    AGENT_PROMPT=""

    case "$AGENT" in
        explorer)
            AGENT_NAME="Creative Explorer"
            AGENT_PROMPT="Generate 3-5 diverse approaches to solve this problem. Think creatively and explore broadly. Mark documented evidence with [T1]."
            ;;
        critic)
            AGENT_NAME="Critical Evaluator"
            AGENT_PROMPT="Review the previous ideas critically. Identify potential issues, risks, and feasibility concerns. Be constructive but rigorous. Mark proven evidence with [T2]."
            ;;
        synthesizer)
            AGENT_NAME="Solution Synthesizer"
            AGENT_PROMPT="Synthesize the Explorer's ideas and Critic's feedback. Identify the most promising approaches. Balance creativity with feasibility. Use evidence markers [T1]/[T2]/[T3]."
            ;;
        security)
            AGENT_NAME="Security Analyst"
            AGENT_PROMPT="Analyze from security and risk perspective. Identify vulnerabilities and suggest mitigations. Cite security standards with [T3]."
            ;;
        performance)
            AGENT_NAME="Performance Specialist"
            AGENT_PROMPT="Evaluate performance implications. Consider scalability, resource usage, and bottlenecks. Cite benchmarks with [T2]."
            ;;
        integrator)
            AGENT_NAME="Final Integrator"
            AGENT_PROMPT="Integrate all perspectives. Provide comprehensive final recommendation with confidence level (0-100%). Use [T1]/[T2]/[T3] markers."
            ;;
    esac

    echo "## Round $i: $AGENT_NAME"
    echo ""

    # Read previous context
    CONTEXT=""
    if [[ -f "$STATE_DIR/round$((i-1)).txt" ]]; then
        CONTEXT=$(cat "$STATE_DIR/round$((i-1)).txt")
    fi

    # Build prompt with enhanced instructions
    FULL_PROMPT="You are a $AGENT_NAME in a multi-agent debate system.

**Problem:** $PROBLEM

**Your Role:** $AGENT_NAME
**Current Round:** $i of $ROUNDS

**Instructions:** $AGENT_PROMPT

$([ -n "$CONTEXT" ] && echo "**Previous Discussion:**
$CONTEXT" || echo "**This is the first round.**")

$([ "$ENABLE_SEARCH" = true ] && echo "**IMPORTANT:** Use Google Search to find latest information (2024-2025). Cite sources!" || echo "")

**Output Format:**
1. **Your Perspective**: Your unique viewpoint
2. **Key Points**: 3-5 main insights
3. **Evidence/Reasoning**: Support with facts, mark with:
   - [T1] = Documented (official docs, specs)
   - [T2] = Proven (benchmarks, case studies)
   - [T3] = Expert consensus (industry standards)
4. **Questions/Concerns**: What needs clarification

**Be concise but thorough. Prioritize actionable insights.**"

    # Run Gemini with error handling
    if ROUND_OUTPUT=$($GEMINI_CMD "$FULL_PROMPT" 2>&1); then
        echo "$ROUND_OUTPUT"
        extract_metadata "$ROUND_OUTPUT" "$i" "$AGENT"
    else
        echo "Error: Gemini CLI failed for round $i"
        echo "$ROUND_OUTPUT" >&2
        # Continue with partial results
    fi

    echo ""
    echo "---"
    echo ""

    # Save round output
    echo "$ROUND_OUTPUT" > "$STATE_DIR/round${i}.txt"

    # Update context for next round (last 2 rounds only for context management)
    if [[ $i -lt $ROUNDS ]]; then
        if [[ $i -ge 2 ]]; then
            # Keep only last 2 rounds in context to manage context window
            cat "$STATE_DIR/round$((i-1)).txt" "$STATE_DIR/round${i}.txt" > "$STATE_DIR/context.txt"
        else
            cat "$STATE_DIR"/round*.txt > "$STATE_DIR/context.txt"
        fi
    fi
done

# Final summary
echo "## Gemini Final Summary"
echo ""

CONTEXT=$(cat "$STATE_DIR"/round*.txt 2>/dev/null || echo "")

SUMMARY_PROMPT="Based on the entire multi-agent debate above, provide a comprehensive executive summary:

**Full Debate Context:**
$CONTEXT

**Your Task:** Synthesize ALL perspectives and provide:

1. **Recommended Solution**: Clear, actionable recommendation (1-2 paragraphs)
2. **Key Rationale**: Why this solution is best (3-5 bullet points)
3. **Implementation Steps**: Concrete next steps (3-5 steps, prioritized)
4. **Risks & Mitigations**: Top 3 risks with specific mitigation strategies
5. **Confidence Level**: Your confidence (0-100%) with justification
6. **Evidence Quality**: Mark your strongest evidence with [T1]/[T2]/[T3]
7. **Sources**: List all sources cited (if Google Search was used)

$([ "$ENABLE_SEARCH" = true ] && echo "**IMPORTANT:** Reference specific sources found via Google Search." || echo "")

**Format:** Executive summary style - decisive, practical, evidence-based.
**Length:** Concise but comprehensive (aim for clarity over length)."

if SUMMARY=$($GEMINI_CMD "$SUMMARY_PROMPT" 2>&1); then
    echo "$SUMMARY"
    extract_metadata "$SUMMARY" "final" "synthesizer"
else
    echo "Error: Summary generation failed"
    echo "$SUMMARY" >&2
    SUMMARY="Error: Failed to generate summary"
fi

echo ""

# Save final summary
echo "$SUMMARY" > "$STATE_DIR/final_summary.txt"

# Generate aggregate metadata
cat > "$STATE_DIR/metadata/aggregate.json" <<EOF
{
    "session_id": "$SESSION_ID",
    "model": "gemini",
    "provider": "google",
    "mode": "$MODE",
    "rounds": $ROUNDS,
    "quality_gates_enabled": $QUALITY_GATES,
    "search_enabled": $ENABLE_SEARCH,
    "context_window": 1000000,
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "cost": {
        "estimated_tokens": "calculated_at_runtime",
        "tier": "free"
    }
}
EOF

echo "=================================================="
echo "Gemini Analysis Complete"
echo "=================================================="
echo "Session ID: $SESSION_ID"
echo "Total Rounds: $ROUNDS"
echo "Google Search: $([ "$ENABLE_SEARCH" = true ] && echo "Used" || echo "Not used")"
echo "State saved to: $STATE_DIR"
echo "Metadata saved to: $STATE_DIR/metadata/"
echo ""
echo "Next steps:"
echo "  - Review: $STATE_DIR/final_summary.txt"
echo "  - Metadata: $STATE_DIR/metadata/aggregate.json"
echo "  - Context: $STATE_DIR/context.txt"
echo ""
