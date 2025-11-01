#!/usr/bin/env bash

# Facilitator Script V2.0
# Claude orchestrates round-by-round debate between multiple AI models
# Based on Codex V3.0 facilitator architecture

set -euo pipefail

PROBLEM="${1:-}"
MODELS="${2:-codex}"  # Comma-separated: "codex,gemini" or "codex" or "all"
MODE="${3:-balanced}"
STATE_DIR="${4:-./debate-session/facilitated}"

if [[ -z "$PROBLEM" ]]; then
    echo "Usage: $0 <problem> [models] [mode] [state_dir]" >&2
    echo "" >&2
    echo "Examples:" >&2
    echo "  $0 \"Django vs FastAPI\" codex balanced" >&2
    echo "  $0 \"Redis vs Memcached\" codex,gemini balanced" >&2
    echo "  $0 \"Performance issue\" all deep" >&2
    exit 1
fi

# Get script directory for relative paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"

# Load mode configuration
MODE_CONFIG="$SKILL_DIR/modes/${MODE}.yaml"
if [[ ! -f "$MODE_CONFIG" ]]; then
    echo "Warning: Mode config not found: $MODE_CONFIG" >&2
    echo "Using default settings" >&2
    ROUNDS=3
else
    # Extract rounds from YAML
    ROUNDS=$(grep "rounds:" "$MODE_CONFIG" | sed 's/.*rounds: *\([0-9]*\).*/\1/' || echo "3")
fi

# Create state directories
mkdir -p "$STATE_DIR"
mkdir -p "$STATE_DIR/rounds"
mkdir -p "$STATE_DIR/metadata"

# Parse models
if [[ "$MODELS" == "all" ]]; then
    MODEL_LIST=("codex" "claude" "gemini")
else
    IFS=',' read -ra MODEL_LIST <<< "$MODELS"
fi

echo "=================================================="
echo "AI Collaborative Solver - Facilitator V2.0"
echo "=================================================="
echo "Problem: $PROBLEM"
echo "Models: ${MODEL_LIST[*]}"
echo "Mode: $MODE (${ROUNDS} rounds)"
echo "State Dir: $STATE_DIR"
echo "=================================================="
echo ""

# Stage 0: Pre-Clarification (Optional)
# Run pre-clarify to reduce ambiguity in problem statement
PRE_CLARIFY_SCRIPT="$SCRIPT_DIR/pre-clarify.sh"
CLARIFIED_PROBLEM="$PROBLEM"

if [[ -f "$PRE_CLARIFY_SCRIPT" ]] && [[ -t 0 ]]; then
    # Interactive mode - run pre-clarification
    echo "Stage 0: Pre-Clarification"
    echo ""

    CLARIFIED_OUTPUT_FILE="$STATE_DIR/clarified_problem.txt"

    # Run pre-clarify script (it will handle user interaction)
    if bash "$PRE_CLARIFY_SCRIPT" "$PROBLEM" "$CLARIFIED_OUTPUT_FILE" > "$STATE_DIR/pre-clarify-log.txt" 2>&1; then
        # Use clarified problem if available
        if [[ -f "$CLARIFIED_OUTPUT_FILE" ]]; then
            CLARIFIED_PROBLEM=$(cat "$CLARIFIED_OUTPUT_FILE")
            echo "Pre-clarification completed. Using enriched problem statement."
        else
            echo "Pre-clarification skipped (no output file)."
        fi
    else
        echo "Warning: Pre-clarification failed. Using original problem." >&2
    fi

    echo ""
else
    # Non-interactive mode or pre-clarify script not found
    if [[ ! -f "$PRE_CLARIFY_SCRIPT" ]]; then
        echo "Info: Pre-clarification script not found, skipping."
    else
        echo "Info: Non-interactive mode, skipping pre-clarification."
    fi
    echo ""
fi

# Function: Run model adapter with context
run_model_with_context() {
    local model="$1"
    local round_num="$2"
    local prompt="$3"
    local context="${4:-}"  # Optional context from other models

    local model_state_dir="$STATE_DIR/$model"
    local adapter_script="$SKILL_DIR/models/$model/adapter.sh"

    if [[ ! -f "$adapter_script" ]]; then
        echo "Error: Adapter not found: $adapter_script" >&2
        return 1
    fi

    # Build full prompt with context
    local full_prompt="$prompt"
    if [[ -n "$context" ]]; then
        full_prompt="## Context from Other Models:

$context

---

## Your Task:
$prompt"
    fi

    echo "  Running $model adapter..."

    # Call adapter with full prompt
    # Note: Each adapter handles its own rounds internally
    # We pass context as an environment variable
    # IMPORTANT: Set FACILITATOR_MODE=true to ensure adapter responds in facilitator mode
    FACILITATOR_MODE=true DEBATE_CONTEXT="$context" bash "$adapter_script" "$full_prompt" "$MODE" "$model_state_dir" 2>&1

    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        echo "  Warning: $model adapter failed with exit code $exit_code" >&2
    fi

    # Extract output from last round
    local output_file="$model_state_dir/last_response.txt"
    if [[ -f "$output_file" ]]; then
        cat "$output_file"
    else
        echo "  Warning: No output file found for $model" >&2
        echo "[No response from $model]"
    fi
}

# Function: Collect responses from all models (with context filtering)
collect_all_responses() {
    local round_num="$1"
    local responses=""

    for model in "${MODEL_LIST[@]}"; do
        local response_file="$STATE_DIR/rounds/round${round_num}_${model}_response.txt"
        if [[ -f "$response_file" ]]; then
            # Extract only actual response content (skip embedded context to prevent duplication)
            # Strategy: Take first 30 lines (summary) to avoid including nested context
            local response_summary=$(head -30 "$response_file")

            responses+="### $model:

$response_summary

... (full response in $response_file)

---

"
        fi
    done

    echo "$responses"
}

# Function: Check if user input is needed (Mid-debate heuristic)
# Returns 0 if user input needed, 1 otherwise
check_need_user_input() {
    local round_num="$1"
    local context="$2"

    # Skip for Round 1 (too early)
    if [[ $round_num -le 1 ]]; then
        return 1
    fi

    # Skip if non-interactive mode
    if [[ ! -t 0 ]]; then
        return 1
    fi

    # Heuristic 1: Check for deadlock (Round 3+)
    if [[ $round_num -ge 3 ]]; then
        # Simple heuristic: if responses contain conflicting keywords
        if echo "$context" | grep -qi "however\|disagree\|alternatively" > /dev/null 2>&1; then
            echo "  [Mid-debate Heuristic] Detected potential deadlock - multiple perspectives diverging" >&2
            return 0
        fi
    fi

    # Heuristic 2: Check for low confidence markers
    if echo "$context" | grep -Eqi "unclear|uncertain|depends on|need.*information|assume" > /dev/null 2>&1; then
        echo "  [Mid-debate Heuristic] Detected low confidence or missing information" >&2
        return 0
    fi

    # Default: no user input needed
    return 1
}

# Function: Request user input during debate
request_user_input() {
    local round_num="$1"
    local context="$2"

    echo ""
    echo "=================================================="
    echo "🤔 Mid-Debate User Input Opportunity"
    echo "=================================================="
    echo "Round: $round_num / $ROUNDS"
    echo ""
    echo "The debate has identified areas where your input could help:"
    echo ""
    echo "Options:"
    echo "  1) Provide additional context or clarification"
    echo "  2) Skip and let the debate continue"
    echo ""
    read -p "Your choice (1-2, default: 2): " choice

    case "$choice" in
        1)
            echo ""
            echo "Please provide your input (press Ctrl+D when done):"
            echo "---"
            local user_input=$(cat)
            echo "---"
            echo ""
            echo "Thank you! Incorporating your input into the next round..."
            echo "$user_input"
            ;;
        *)
            echo ""
            echo "Skipping user input. Debate will continue with AI judgment."
            echo "[User skipped mid-debate input]"
            ;;
    esac

    echo ""
}

# ==============================================================
# Devil's Advocate Functions (Phase 3.2: Stress-pass Questions)
# ==============================================================

# Function: Detect agreement/disagreement pattern in response
# Returns: "agree" | "disagree" | "mixed"
detect_agreement_pattern() {
    local response_content="$1"

    # Agreement markers (case insensitive)
    local agree_count=$(echo "$response_content" | grep -Eio "agree|동의|맞습니다|correct|right|yes|exactly|precisely" | wc -l)

    # Disagreement markers
    local disagree_count=$(echo "$response_content" | grep -Eio "however|but|disagree|alternatively|대신|반대|instead|different|challenge" | wc -l)

    # Determine pattern
    if [[ $agree_count -gt $((disagree_count * 2)) ]]; then
        echo "agree"
    elif [[ $disagree_count -gt $((agree_count * 2)) ]]; then
        echo "disagree"
    else
        echo "mixed"
    fi
}

# Function: Check for dominance pattern (one agent dominating without challenge)
# Returns 0 if dominance detected, 1 otherwise
check_dominance_pattern() {
    local round_num="$1"
    local state_dir="$2"

    # Skip if Round < 3 (need at least 2 previous rounds to check pattern)
    if [[ $round_num -lt 3 ]]; then
        return 1
    fi

    # Check last 2 rounds for agreement imbalance
    local window_start=$((round_num - 1))
    local agree_rounds=0
    local total_checked=0

    # Count agreement patterns in recent rounds
    for check_round in $(seq $window_start $((round_num - 1))); do
        # Check both models' responses
        for model in "${MODEL_LIST[@]}"; do
            local response_file="$state_dir/rounds/round${check_round}_${model}_response.txt"

            if [[ -f "$response_file" ]]; then
                local pattern=$(detect_agreement_pattern "$(cat "$response_file")")

                if [[ "$pattern" == "agree" ]]; then
                    ((agree_rounds++))
                fi
                ((total_checked++))
            fi
        done
    done

    # Calculate agreement rate
    if [[ $total_checked -eq 0 ]]; then
        return 1
    fi

    local agreement_rate=$((agree_rounds * 100 / total_checked))

    # Dominance threshold: >80% agreement
    if [[ $agreement_rate -gt 80 ]]; then
        echo "  [Dominance Pattern] Agreement rate: ${agreement_rate}% (threshold: 80%)" >&2
        return 0
    fi

    return 1
}

# Function: Generate devil's advocate prompt
inject_devils_advocate() {
    local round_num="$1"
    local models_string="$2"

    # Devil's advocate prompt (from ai-escalation.md template)
    cat <<EOF

### 🎯 Devil's Advocate Challenge (Round $round_num)

**Pattern Detected:** High agreement rate in recent rounds. Before finalizing, let's ensure thorough critical evaluation.

**To All Participants:**

Before we proceed, please consider:

1. **Potential Issues or Edge Cases**: Are there any scenarios we haven't fully explored where this approach might fail?

2. **What Could Go Wrong**: What are the risks, downsides, or unintended consequences of this recommendation?

3. **Alternative Approaches**: Have we sufficiently explored other viable options? What might we be overlooking?

4. **Hidden Assumptions**: Are we making any assumptions that could be incorrect? What if those assumptions don't hold?

5. **Trade-offs**: What are we giving up by choosing this approach? Are those trade-offs acceptable?

**Note:** It's perfectly acceptable to maintain your position if you believe it's sound, but please demonstrate critical evaluation of these questions.

---
EOF
}

# =============================================================================
# Phase 3.3: Anti-pattern Detection Functions
# =============================================================================

# Function: Detect information starvation (too many assumptions/hedging words)
# Returns 0 if pattern detected, 1 otherwise
detect_information_starvation() {
    local response_content="$1"

    # Hedging language patterns (from anti-patterns.yaml)
    local hedging_words=$(echo "$response_content" | grep -Eio "probably|might be|could be|perhaps|assuming|maybe|possibly|likely|uncertain|unclear|depends on" | wc -l)

    # Assumption markers
    local assumption_words=$(echo "$response_content" | grep -Eio "assume|assumption|supposing|guessing|estimate" | wc -l)

    # Threshold: ≥5 hedging words OR ≥3 assumptions in single round (from anti-patterns.yaml)
    if [[ $hedging_words -ge 5 ]] || [[ $assumption_words -ge 3 ]]; then
        echo "  [Information Starvation] Hedging: $hedging_words, Assumptions: $assumption_words (thresholds: 5, 3)" >&2
        return 0
    fi

    return 1
}

# Function: Detect rapid turn (very short rounds indicating shallow exploration)
# Returns 0 if pattern detected, 1 otherwise
detect_rapid_turn() {
    local round_num="$1"
    local state_dir="$2"

    # Skip if Round < 2 (need history to check consecutive rounds)
    if [[ $round_num -lt 2 ]]; then
        return 1
    fi

    # Check last 2 rounds for short responses
    local min_words=50  # From anti-patterns.yaml
    local short_count=0

    # Check current and previous round
    for check_round in $(seq $((round_num - 1)) $round_num); do
        for model in "${MODEL_LIST[@]}"; do
            local response_file="$state_dir/rounds/round${check_round}_${model}_response.txt"

            if [[ -f "$response_file" ]]; then
                local word_count=$(cat "$response_file" | wc -w)

                if [[ $word_count -lt $min_words ]]; then
                    ((short_count++))
                fi
            fi
        done
    done

    # Rapid turn if ≥2 consecutive short responses (from anti-patterns.yaml)
    if [[ $short_count -ge 2 ]]; then
        echo "  [Rapid Turn] $short_count consecutive short responses (<$min_words words)" >&2
        return 0
    fi

    return 1
}

# Function: Detect policy/ethical considerations
# Returns 0 if pattern detected, 1 otherwise
detect_policy_trigger() {
    local response_content="$1"

    # Policy keywords (from anti-patterns.yaml)
    local policy_count=$(echo "$response_content" | grep -Eio "ethics|ethical|legal|policy|regulation|regulatory|moral|compliance|privacy|gdpr|hipaa" | wc -l)

    # Trigger if any policy keyword detected
    if [[ $policy_count -gt 0 ]]; then
        echo "  [Policy Trigger] $policy_count policy/ethical keywords detected" >&2
        return 0
    fi

    return 1
}

# Function: Detect premature convergence (agreement too quickly)
# Returns 0 if pattern detected, 1 otherwise
detect_premature_convergence() {
    local round_num="$1"
    local state_dir="$2"

    # Only check in Round 2 or earlier (from anti-patterns.yaml: max_rounds: 2)
    if [[ $round_num -gt 2 ]]; then
        return 1
    fi

    # Count agreement patterns in all rounds up to current
    local agree_count=0
    local total_responses=0

    for check_round in $(seq 1 $round_num); do
        for model in "${MODEL_LIST[@]}"; do
            local response_file="$state_dir/rounds/round${check_round}_${model}_response.txt"

            if [[ -f "$response_file" ]]; then
                local pattern=$(detect_agreement_pattern "$(cat "$response_file")")

                if [[ "$pattern" == "agree" ]]; then
                    ((agree_count++))
                fi
                ((total_responses++))
            fi
        done
    done

    # Calculate agreement rate
    if [[ $total_responses -eq 0 ]]; then
        return 1
    fi

    local agreement_rate=$((agree_count * 100 / total_responses))

    # Premature convergence if >70% agreement in ≤2 rounds
    if [[ $round_num -le 2 ]] && [[ $agreement_rate -gt 70 ]]; then
        echo "  [Premature Convergence] Agreement rate: ${agreement_rate}% in Round $round_num (threshold: 70% in ≤2 rounds)" >&2
        return 0
    fi

    return 1
}

# Save session info
cat > "$STATE_DIR/session_info.txt" <<EOF
Original Problem: $PROBLEM
Clarified Problem: $CLARIFIED_PROBLEM
Models: ${MODEL_LIST[*]}
Mode: $MODE
Rounds: $ROUNDS
Started: $(date)
EOF

# ============================================================
# Round 1: Initial Analysis
# ============================================================
echo "## Round 1: Initial Analysis"
echo ""

ROUND1_PROMPT="You are participating in a multi-model AI debate to solve this problem:

**Problem:** $CLARIFIED_PROBLEM

**Your Task (Round 1):**
1. Analyze the problem from your unique perspective
2. Generate 3-5 potential approaches or solutions
3. Highlight key considerations and tradeoffs
4. Provide initial recommendation with confidence level (0-100%)

**Mode:** $MODE
**Round:** 1 of $ROUNDS

Be thorough but concise. This is the initial exploration phase."

for model in "${MODEL_LIST[@]}"; do
    echo "### $model"

    response=$(run_model_with_context "$model" 1 "$ROUND1_PROMPT" "")

    # Save response
    echo "$response" > "$STATE_DIR/rounds/round1_${model}_response.txt"

    echo ""
    echo "---"
    echo ""
done

# ============================================================
# Round 2+: Cross-Examination & Convergence
# ============================================================
for round in $(seq 2 "$ROUNDS"); do
    echo "## Round $round: Cross-Examination & Refinement"
    echo ""

    # Collect all previous responses as context
    prev_round=$((round-1))
    CONTEXT=$(collect_all_responses $prev_round)

    ROUND_PROMPT="**Previous Round Responses:**

$CONTEXT

---

**Your Task (Round $round of $ROUNDS):**
1. Review the responses from other AI models above
2. Identify agreements, disagreements, and gaps
3. Respond to points raised by others
4. Refine your position based on the discussion
5. Update your recommendation and confidence level

**Focus:**
- Build on good ideas from others
- Challenge weak arguments constructively
- Fill gaps that others missed
- Converge toward a practical solution

Be direct and specific. Reference other models' points when relevant."

    for model in "${MODEL_LIST[@]}"; do
        echo "### $model"

        response=$(run_model_with_context "$model" "$round" "$ROUND_PROMPT" "$CONTEXT")

        # Save response
        echo "$response" > "$STATE_DIR/rounds/round${round}_${model}_response.txt"

        echo ""
        echo "---"
        echo ""
    done

    # Check if user input is needed (Mid-debate heuristic)
    if check_need_user_input "$round" "$CONTEXT"; then
        USER_INPUT=$(request_user_input "$round" "$CONTEXT")

        # Save user input for next round
        if [[ -n "$USER_INPUT" ]] && [[ "$USER_INPUT" != *"[User skipped"* ]]; then
            echo "$USER_INPUT" > "$STATE_DIR/rounds/round${round}_user_input.txt"

            # Add to context for next round
            CONTEXT="$CONTEXT

### User Input (After Round $round):

$USER_INPUT

---
"
        fi
    fi

    # Check for dominance pattern and inject devil's advocate (Phase 3.2)
    if check_dominance_pattern "$round" "$STATE_DIR"; then
        DEVILS_ADVOCATE=$(inject_devils_advocate "$round" "${MODEL_LIST[*]}")

        # Add devil's advocate challenge to context
        CONTEXT="$CONTEXT
$DEVILS_ADVOCATE
"
        echo "  💡 Devil's Advocate challenge added to next round"
    fi

    # =================================================================
    # Phase 3.3: Anti-pattern Detection
    # =================================================================

    # Check all responses in this round for anti-patterns
    for model in "${MODEL_LIST[@]}"; do
        response_file="$STATE_DIR/rounds/round${round}_${model}_response.txt"

        if [[ -f "$response_file" ]]; then
            response_content=$(cat "$response_file")

            # Check for information starvation (too many assumptions)
            if detect_information_starvation "$response_content"; then
                echo "  ⚠️  Information Starvation detected in $model response"
                # Future: Could prompt user for clarification
            fi

            # Check for policy/ethical considerations
            if detect_policy_trigger "$response_content"; then
                echo "  📋 Policy/Ethical considerations detected in $model response"
                # Future: Could escalate to user for decision
            fi
        fi
    done

    # Check for rapid turn (shallow exploration)
    if detect_rapid_turn "$round" "$STATE_DIR"; then
        echo "  ⏱️  Rapid Turn detected - debate may need more depth"
        # Future: Could suggest extending rounds
    fi

    # Check for premature convergence (agreement too quickly)
    if detect_premature_convergence "$round" "$STATE_DIR"; then
        echo "  🚨 Premature Convergence detected - consider exploring alternatives"
        # Future: Could inject alternative exploration prompt
    fi
done

# ============================================================
# Final Synthesis
# ============================================================
echo "## Final Synthesis"
echo ""

# Collect ALL round responses
ALL_CONTEXT=""
for r in $(seq 1 "$ROUNDS"); do
    ALL_CONTEXT+="### Round $r:

$(collect_all_responses $r)

"
done

SYNTHESIS_PROMPT="**Complete Debate History:**

$ALL_CONTEXT

---

**Your Task: Final Synthesis**

Based on the entire multi-round debate above, provide:

1. **Recommended Solution:** Clear, actionable recommendation (1-2 paragraphs)
2. **Key Rationale:** Why this solution is best (3-5 bullet points)
3. **Implementation Steps:** Concrete next steps (3-5 steps, prioritized)
4. **Risks & Mitigations:** Top 3 risks with specific mitigation strategies
5. **Confidence Level:** Your final confidence (0-100%) with justification

**Format:** Executive summary style - decisive, practical, evidence-based."

echo "### Final Recommendations"
echo ""

for model in "${MODEL_LIST[@]}"; do
    echo "#### $model Final Position:"
    echo ""

    response=$(run_model_with_context "$model" "final" "$SYNTHESIS_PROMPT" "$ALL_CONTEXT")

    # Save final response
    echo "$response" > "$STATE_DIR/rounds/final_${model}_response.txt"

    echo ""
    echo "---"
    echo ""
done

# ============================================================
# Generate Debate Summary
# ============================================================
SUMMARY_FILE="$STATE_DIR/debate_summary.md"

cat > "$SUMMARY_FILE" <<EOF
# AI Collaborative Debate Summary

**Original Problem:** $PROBLEM
**Clarified Problem:** $CLARIFIED_PROBLEM
**Models:** ${MODEL_LIST[*]}
**Mode:** $MODE ($ROUNDS rounds)
**Date:** $(date)

---

## Round-by-Round Summary

EOF

for r in $(seq 1 "$ROUNDS"); do
    echo "### Round $r" >> "$SUMMARY_FILE"
    echo "" >> "$SUMMARY_FILE"

    for model in "${MODEL_LIST[@]}"; do
        response_file="$STATE_DIR/rounds/round${r}_${model}_response.txt"
        if [[ -f "$response_file" ]]; then
            echo "#### $model:" >> "$SUMMARY_FILE"
            echo "" >> "$SUMMARY_FILE"
            head -10 "$response_file" >> "$SUMMARY_FILE"
            echo "" >> "$SUMMARY_FILE"
            echo "..." >> "$SUMMARY_FILE"
            echo "" >> "$SUMMARY_FILE"
        fi
    done

    echo "---" >> "$SUMMARY_FILE"
    echo "" >> "$SUMMARY_FILE"
done

echo "## Final Recommendations" >> "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"

for model in "${MODEL_LIST[@]}"; do
    final_file="$STATE_DIR/rounds/final_${model}_response.txt"
    if [[ -f "$final_file" ]]; then
        echo "### $model:" >> "$SUMMARY_FILE"
        echo "" >> "$SUMMARY_FILE"
        cat "$final_file" >> "$SUMMARY_FILE"
        echo "" >> "$SUMMARY_FILE"
        echo "---" >> "$SUMMARY_FILE"
        echo "" >> "$SUMMARY_FILE"
    fi
done

echo "=================================================="
echo "Debate Complete"
echo "=================================================="
echo "Summary saved to: $SUMMARY_FILE"
echo "Full debate saved to: $STATE_DIR/rounds/"
echo ""
echo "Next steps:"
echo "  - Review: $SUMMARY_FILE"
echo "  - Full details: $STATE_DIR/rounds/"
echo ""
