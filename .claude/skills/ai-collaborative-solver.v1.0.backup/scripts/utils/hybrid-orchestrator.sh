#!/usr/bin/env bash

# Hybrid Orchestrator
# Runs multiple AI models in parallel and synthesizes results

set -euo pipefail

PROBLEM="${1:-}"
MODELS="${2:-codex,gemini}"
MODE="${3:-balanced}"
REPORT_FILE="${4:-}"

if [[ -z "$PROBLEM" ]]; then
    echo "Error: Problem description required" >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"

echo "=================================================="
echo "Hybrid Analysis (Multiple AI Models)"
echo "=================================================="
echo "Models: $MODELS"
echo "Problem: $PROBLEM"
echo "Mode: $MODE"
echo "=================================================="
echo ""

# Split models
IFS=',' read -ra MODEL_ARRAY <<< "$MODELS"

# Run each model in parallel (save to temp files)
PIDS=()
TEMP_DIR="./debate-session/hybrid-$$"
mkdir -p "$TEMP_DIR"

for model in "${MODEL_ARRAY[@]}"; do
    model=$(echo "$model" | xargs) # trim whitespace

    echo "Starting $model analysis in background..."

    (
        OUTPUT_FILE="$TEMP_DIR/${model}-output.txt"

        case "$model" in
            codex)
                "$SKILL_DIR/models/codex/adapter.sh" "$PROBLEM" "$MODE" "./debate-session/hybrid-codex" > "$OUTPUT_FILE" 2>&1
                ;;
            gemini)
                "$SKILL_DIR/models/gemini/adapter.sh" "$PROBLEM" "$MODE" "false" "./debate-session/hybrid-gemini" > "$OUTPUT_FILE" 2>&1
                ;;
            *)
                echo "Error: Unknown model: $model" > "$OUTPUT_FILE"
                ;;
        esac

        echo "$model analysis complete" >&2
    ) &

    PIDS+=($!)
done

echo "Waiting for all models to complete..."
echo ""

# Wait for all models
for pid in "${PIDS[@]}"; do
    wait "$pid"
done

echo ""
echo "All analyses complete!"
echo ""
echo "=================================================="
echo "Results Comparison"
echo "=================================================="
echo ""

# Display results from each model
for model in "${MODEL_ARRAY[@]}"; do
    model=$(echo "$model" | xargs)
    OUTPUT_FILE="$TEMP_DIR/${model}-output.txt"

    echo "## $model Analysis"
    echo ""

    if [[ -f "$OUTPUT_FILE" ]]; then
        cat "$OUTPUT_FILE"
    else
        echo "Error: Output file not found for $model"
    fi

    echo ""
    echo "---"
    echo ""

    # Append to report if provided
    if [[ -n "$REPORT_FILE" ]]; then
        cat >> "$REPORT_FILE" << EOF
## $model Analysis

$(cat "$OUTPUT_FILE" 2>/dev/null || echo "Error: Output not available")

---

EOF
    fi
done

# Synthesize results
echo "## Synthesis: Comparing All Models"
echo ""
echo "Analyzing consensus and differences between models..."
echo ""

# Count models
NUM_MODELS=${#MODEL_ARRAY[@]}

# Try to extract key recommendations from each model
echo "### Individual Recommendations"
echo ""

for model in "${MODEL_ARRAY[@]}"; do
    model=$(echo "$model" | xargs)
    OUTPUT_FILE="$TEMP_DIR/${model}-output.txt"

    echo "**$model:**"

    # Extract lines containing "recommend", "solution", or "confidence"
    grep -iE "recommend|solution|confidence" "$OUTPUT_FILE" 2>/dev/null | head -5 || echo "  (No clear recommendation found)"

    echo ""
done

echo "### Consensus Analysis"
echo ""

# Simple consensus check: look for common words in recommendations
echo "Analyzing common themes..."
echo ""

# Combine all outputs
ALL_OUTPUTS=$(cat "$TEMP_DIR"/*.txt 2>/dev/null)

# Look for common keywords (basic frequency analysis)
echo "**Common Keywords:**"
echo "$ALL_OUTPUTS" | tr '[:space:]' '\n' | tr '[:upper:]' '[:lower:]' | grep -E '^[a-z]{4,}$' | sort | uniq -c | sort -rn | head -10

echo ""
echo "### Recommendations"
echo ""

if [[ $NUM_MODELS -eq 2 ]]; then
    echo "**With 2 models:**"
    echo "- If models agree: High confidence in recommendation"
    echo "- If models differ: Explore trade-offs between perspectives"
    echo "- Consider: Codex for code/architecture, Gemini for latest info"
elif [[ $NUM_MODELS -gt 2 ]]; then
    echo "**With $NUM_MODELS models:**"
    echo "- Look for consensus (majority agreement)"
    echo "- Minority views may highlight risks or edge cases"
    echo "- Synthesize best insights from each model"
fi

echo ""
echo "=================================================="
echo "Hybrid Analysis Complete"
echo "=================================================="
echo ""
echo "Review individual analyses above and synthesize based on:"
echo "1. Consensus areas (all models agree)"
echo "2. Divergent perspectives (models disagree - why?)"
echo "3. Unique insights from each model"
echo "4. Your context and constraints"
echo ""

# Append synthesis to report
if [[ -n "$REPORT_FILE" ]]; then
    cat >> "$REPORT_FILE" << EOF
## Synthesis: Comparing All Models

### Individual Recommendations

$(for model in "${MODEL_ARRAY[@]}"; do
    model=$(echo "$model" | xargs)
    OUTPUT_FILE="$TEMP_DIR/${model}-output.txt"
    echo "**$model:**"
    grep -iE "recommend|solution|confidence" "$OUTPUT_FILE" 2>/dev/null | head -5 || echo "(No clear recommendation found)"
    echo ""
done)

### Consensus Analysis

Analyzing common themes...

**Common Keywords:**
$(echo "$ALL_OUTPUTS" | tr '[:space:]' '\n' | tr '[:upper:]' '[:lower:]' | grep -E '^[a-z]{4,}$' | sort | uniq -c | sort -rn | head -10)

### Recommendations

- **Consensus areas:** Points where all models agree
- **Divergent perspectives:** Areas where models disagree (explore trade-offs)
- **Unique insights:** Leverage each model's strengths

Review individual analyses and synthesize based on your context.

---

EOF
fi

# Cleanup
# rm -rf "$TEMP_DIR" 2>/dev/null || true

echo "Temporary files saved in: $TEMP_DIR"
echo "(You can delete this directory after reviewing)"
