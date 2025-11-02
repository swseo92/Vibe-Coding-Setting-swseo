#!/usr/bin/env bash

# AI Collaborative Solver V2.0 - Simplified
# No pre-clarification (handled by Claude Code)
# Focus: Execute debate only

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
DEBATE_DIR=".debate-reports"
TIMESTAMP=$(date +%Y-%m-%d-%H-%M)

# Default values
MODEL="auto"
MODE="balanced"
PROBLEM=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --model)
            MODEL="$2"
            shift 2
            ;;
        --mode)
            MODE="$2"
            shift 2
            ;;
        --auto)
            MODEL="auto"
            shift
            ;;
        --help|-h)
            cat << EOF
AI Collaborative Solver V2.0 - Simplified

Usage: $0 "<problem description>" [options]

Options:
  --model <codex|claude|gemini|auto>  Choose AI model (default: auto)
  --mode <simple|balanced|deep>       Debate mode (default: balanced)
  --auto                              Auto-select best model for problem
  --help, -h                          Show this help

Examples:
  # Auto-select model (recommended)
  $0 "Django vs FastAPI with full context" --auto

  # Specific model
  $0 "Performance optimization problem" --model codex --mode balanced

Modes:
  simple   - 3 rounds, ~5-8 minutes
  balanced - 4 rounds, ~10-15 minutes (default)
  deep     - 6 rounds, ~15-25 minutes

Models:
  codex  - Best for: Code, architecture, performance
  claude - Best for: Writing, reasoning, analysis
  gemini - Best for: Latest trends, research
  auto   - Automatically select based on problem type

Note: This is V2.0 - pre-clarification handled by Claude Code.
      Provide enriched problem statement with full context.

EOF
            exit 0
            ;;
        *)
            if [[ -z "$PROBLEM" ]]; then
                PROBLEM="$1"
            else
                echo "Error: Unknown option: $1" >&2
                exit 1
            fi
            shift
            ;;
    esac
done

# Validate problem
if [[ -z "$PROBLEM" ]]; then
    echo "Error: Problem description required" >&2
    echo "Usage: $0 \"<problem>\" [options]" >&2
    echo "Try: $0 --help" >&2
    exit 1
fi

# Validate mode
VALID_MODES=("simple" "balanced" "deep")
if [[ ! " ${VALID_MODES[@]} " =~ " ${MODE} " ]]; then
    echo "Error: Invalid mode: $MODE" >&2
    echo "Available modes: simple, balanced, deep" >&2
    exit 1
fi

# Create debate reports directory
mkdir -p "$DEBATE_DIR"

echo "=================================================="
echo "AI Collaborative Solver V2.0"
echo "=================================================="
echo "Problem: $PROBLEM"
echo "Model: $MODEL"
echo "Mode: $MODE"
echo "Report: $DEBATE_DIR/${TIMESTAMP}-ai-debate-${MODEL}.md"
echo "=================================================="
echo ""

# Auto-select model if needed
if [[ "$MODEL" == "auto" ]]; then
    echo "Auto-selecting model based on problem type..."
    echo ""

    # Simple keyword-based selection
    # (Can be enhanced later with registry.yaml)

    if echo "$PROBLEM" | grep -qiE "code|코드|review|리뷰|bug|버그|performance|성능|optimize|최적화|database|데이터베이스"; then
        MODEL="codex"
        echo "Selected: Codex (technical/code problems)"
    elif echo "$PROBLEM" | grep -qiE "write|작성|document|문서|explain|설명|reason|추론|analyze|분석"; then
        MODEL="claude"
        echo "Selected: Claude (writing/reasoning)"
    elif echo "$PROBLEM" | grep -qiE "2025|2024|latest|최신|trend|트렌드|search|검색|research|조사"; then
        MODEL="gemini"
        echo "Selected: Gemini (current trends/research)"
    else
        MODEL="codex"
        echo "Selected: Codex (default for technical problems)"
    fi

    echo ""
fi

# Validate model
VALID_MODELS=("codex" "claude" "gemini")
if [[ ! " ${VALID_MODELS[@]} " =~ " ${MODEL} " ]]; then
    echo "Error: Invalid model: $MODEL" >&2
    echo "Available models: codex, claude, gemini, auto" >&2
    exit 1
fi

# Output file
REPORT_FILE="$DEBATE_DIR/${TIMESTAMP}-ai-debate-${MODEL}.md"

# Initialize report
cat > "$REPORT_FILE" << EOF
# AI Collaborative Debate Report (V2.0)

**Generated:** $(date +"%Y-%m-%d %H:%M:%S")
**Model:** $MODEL
**Mode:** $MODE

## Problem Statement

$PROBLEM

---

EOF

# Execute based on model
case "$MODEL" in
    codex)
        echo "Running Codex debate..."
        echo ""
        echo "Note: Codex adapter not yet implemented in V2.0"
        echo "This is a placeholder for Codex integration."
        echo ""
        echo "Expected: Call Codex CLI with problem and mode"

        cat >> "$REPORT_FILE" << EOF
## Codex Analysis

[Placeholder: Codex integration pending]

Problem received: $PROBLEM
Mode: $MODE

Expected implementation:
1. Call Codex CLI with structured prompt
2. Run $MODE mode debate (rounds configured per mode)
3. Capture output
4. Format results

---

EOF
        ;;

    claude)
        echo "Running Claude debate..."
        echo ""
        echo "Note: Claude adapter not yet implemented in V2.0"
        echo "This is a placeholder for Claude integration."

        cat >> "$REPORT_FILE" << EOF
## Claude Analysis

[Placeholder: Claude integration pending]

Problem received: $PROBLEM
Mode: $MODE

---

EOF
        ;;

    gemini)
        echo "Running Gemini debate..."
        echo ""
        echo "Note: Gemini adapter not yet implemented in V2.0"
        echo "This is a placeholder for Gemini integration."

        cat >> "$REPORT_FILE" << EOF
## Gemini Analysis

[Placeholder: Gemini integration pending]

Problem received: $PROBLEM
Mode: $MODE

---

EOF
        ;;
esac

# Finalize report
cat >> "$REPORT_FILE" << EOF

## Metadata

- **Total Duration:** $(date +"%Y-%m-%d %H:%M:%S")
- **Model:** $MODEL
- **Mode:** $MODE
- **Version:** 2.0.0 (Simplified)

---

**Note:** This is a V2.0 placeholder. Full model integration coming next.
**Focus:** Pre-clarification workflow validation first.

EOF

echo "=================================================="
echo "Debate Complete!"
echo "=================================================="
echo "Report saved to: $REPORT_FILE"
echo ""
echo "Next steps:"
echo "1. Review the report"
echo "2. Validate pre-clarification workflow worked correctly"
echo "3. Once validated, integrate actual model adapters"
echo ""
