#!/usr/bin/env bash

# AI Collaborative Solver - Unified Orchestrator
# Supports multiple AI models: Codex, Claude, Gemini, and hybrid mode
# Registry-based model selection and validation

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
REGISTRY="$SKILL_DIR/config/registry.yaml"
DEBATE_DIR=".debate-reports"
TIMESTAMP=$(date +%Y-%m-%d-%H-%M)

# Default values
MODEL="auto"
MODE="balanced"
ENABLE_SEARCH=false
SKIP_CLARIFY=false
PROBLEM=""

# Check registry exists
if [[ ! -f "$REGISTRY" ]]; then
    echo "Warning: Capability registry not found at $REGISTRY" >&2
    echo "Model validation disabled" >&2
fi

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --model)
            MODEL="$2"
            shift 2
            ;;
        --models)
            MODEL="hybrid"
            HYBRID_MODELS="$2"
            shift 2
            ;;
        --mode)
            MODE="$2"
            shift 2
            ;;
        --search)
            ENABLE_SEARCH=true
            shift
            ;;
        --auto)
            MODEL="auto"
            shift
            ;;
        --skip-clarify)
            SKIP_CLARIFY=true
            shift
            ;;
        --help|-h)
            cat << EOF
AI Collaborative Solver - Unified Multi-Model Debate System

Usage: $0 "problem description" [options]

Options:
  --model <codex|claude|gemini|auto>  Choose AI model (default: auto)
  --models <codex,claude,gemini>      Hybrid mode (multiple models)
  --mode <simple|balanced|deep>       Debate mode (default: balanced)
  --search                            Enable Google Search (Gemini only)
  --auto                              Auto-select best model for problem
  --skip-clarify                      Skip pre-clarification questions
  --help, -h                          Show this help

Examples:
  # Auto-select model (recommended)
  $0 "Django vs FastAPI 2025" --auto

  # Use specific model
  $0 "Code review needed" --model codex --mode balanced
  $0 "Latest React trends" --model gemini --search
  $0 "Write technical documentation" --model claude

  # Hybrid mode (multiple models)
  $0 "Architecture decision" --models codex,claude --mode balanced
  $0 "Comprehensive analysis" --models codex,claude,gemini --mode deep

Modes:
  simple   - 3 rounds, ~5-8 minutes (quick decisions)
  balanced - 4 rounds, ~10-15 minutes (default, recommended)
  deep     - 6 rounds, ~15-25 minutes (complex problems)

Models:
  codex  - OpenAI Codex (GPT-5-Codex) - Code analysis, architecture (\$20/mo)
  claude - Claude Sonnet 4.5 - Reasoning, writing, analysis (CLI login)
  gemini - Gemini 2.5 Pro - Current trends, research (FREE!)
  auto   - Automatically select best model for problem type
  hybrid - Run multiple models and compare results

Model Selection Guide:
  - Code/architecture → codex
  - Writing/reasoning → claude
  - Latest trends/research → gemini
  - Not sure? Use --auto!

Authentication:
  - Codex: npm install -g @openai/codex, then 'codex' to login
  - Claude: Install Claude Code, then 'claude' to login (no API key!)
  - Gemini: npm install -g @google/gemini-cli, then 'gemini-cli' to login

Cost Comparison (per debate):
  - Gemini: FREE (1000 requests/day)
  - Claude: ~\$0.03-0.08 (Claude Pro/Max subscription)
  - Codex: ~\$0.05-0.15 (ChatGPT Plus \$20/mo)

See registry for detailed capabilities:
  $REGISTRY

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
    echo "Usage: $0 \"problem description\" [options]" >&2
    echo "Try: $0 --help" >&2
    exit 1
fi

# Validate mode
if [[ ! -f "$SKILL_DIR/modes/${MODE}.yaml" ]]; then
    echo "Error: Invalid mode: $MODE" >&2
    echo "Available modes: simple, balanced, deep" >&2
    exit 1
fi

# Create debate reports directory
mkdir -p "$DEBATE_DIR"

# ============================================================
# Pre-Clarification Stage (V3.0)
# ============================================================
# Note: Always run unless explicitly skipped (even in Claude Code environment)
if [[ "$SKIP_CLARIFY" == "false" ]]; then
    # Clarification enabled (will handle interactivity internally)
    PRE_CLARIFY_SCRIPT="$SCRIPT_DIR/pre-clarify.sh"

    if [[ -f "$PRE_CLARIFY_SCRIPT" ]]; then
        echo "=================================================="
        echo "Pre-Clarification Stage V3.0"
        echo "=================================================="
        echo ""

        # Run pre-clarify (it handles auto-skip internally)
        CLARIFIED_PROBLEM=$(bash "$PRE_CLARIFY_SCRIPT" "$PROBLEM" "" "$SKIP_CLARIFY" 2>&1 | tee /dev/tty)

        # Use clarified problem if different
        if [[ -n "$CLARIFIED_PROBLEM" ]] && [[ "$CLARIFIED_PROBLEM" != "$PROBLEM" ]]; then
            PROBLEM="$CLARIFIED_PROBLEM"
            echo ""
            echo "✓ Using enriched problem statement for debate."
            echo ""
        fi
    fi
fi

# Output file
REPORT_FILE="$DEBATE_DIR/${TIMESTAMP}-ai-debate-${MODEL}.md"

echo "=================================================="
echo "AI Collaborative Solver"
echo "=================================================="
echo "Problem: $PROBLEM"
echo "Model: $MODEL"
echo "Mode: $MODE"
echo "Google Search: $([ "$ENABLE_SEARCH" = true ] && echo "Enabled" || echo "Disabled")"
echo "Clarification: $([ "$SKIP_CLARIFY" = true ] && echo "Skipped" || echo "Enabled")"
echo "Report: $REPORT_FILE"
echo "=================================================="
echo ""

# Auto-select model if needed
if [[ "$MODEL" == "auto" ]]; then
    echo "Auto-selecting model based on problem type..."
    echo "Using registry: $REGISTRY"

    # Try v2 selector first (registry-based), fallback to v1
    if [[ -f "$SCRIPT_DIR/utils/model-selector-v2.sh" ]]; then
        MODEL=$("$SCRIPT_DIR/utils/model-selector-v2.sh" "$PROBLEM")
    elif [[ -f "$SCRIPT_DIR/utils/model-selector.sh" ]]; then
        MODEL=$("$SCRIPT_DIR/utils/model-selector.sh" "$PROBLEM")
    else
        echo "Warning: Model selector not found, defaulting to codex" >&2
        MODEL="codex"
    fi

    echo "Selected: $MODEL"
    echo "Reason: See model-selector output above"
    echo ""
fi

# Validate model availability (registry-based)
if [[ -f "$REGISTRY" ]] && [[ "$MODEL" != "hybrid" ]] && [[ "$MODEL" != "auto" ]]; then
    MODEL_ID=""
    case "$MODEL" in
        codex) MODEL_ID="openai.codex" ;;
        claude) MODEL_ID="anthropic.claude-sonnet" ;;
        gemini) MODEL_ID="google.gemini-pro" ;;
    esac

    if [[ -n "$MODEL_ID" ]]; then
        # Check if model is in registry
        if ! grep -q "id: $MODEL_ID" "$REGISTRY"; then
            echo "Warning: Model $MODEL not found in registry" >&2
        fi
    fi
fi

# Initialize report
cat > "$REPORT_FILE" << EOF
# AI Collaborative Debate Report

**Generated:** $(date +"%Y-%m-%d %H:%M:%S")
**Model:** $MODEL
**Mode:** $MODE
**Google Search:** $([ "$ENABLE_SEARCH" = true ] && echo "Enabled" || echo "Disabled")

## Problem Statement

$PROBLEM

---

EOF

# Execute based on model
case "$MODEL" in
    codex)
        echo "Running Codex analysis..."
        echo ""

        # Run Codex adapter
        CODEX_OUTPUT=$("$SKILL_DIR/models/codex/adapter.sh" "$PROBLEM" "$MODE" "./debate-session/codex" 2>&1)

        cat >> "$REPORT_FILE" << EOF
## Codex Analysis (GPT-4/o3)

$CODEX_OUTPUT

---

EOF

        echo "$CODEX_OUTPUT"
        ;;

    claude)
        echo "Running Claude analysis..."
        echo ""

        # Run Claude adapter
        CLAUDE_OUTPUT=$("$SKILL_DIR/models/claude/adapter.sh" "$PROBLEM" "$MODE" "./debate-session/claude" 2>&1)

        cat >> "$REPORT_FILE" << EOF
## Claude Analysis (Claude 3.5 Sonnet)

$CLAUDE_OUTPUT

---

EOF

        echo "$CLAUDE_OUTPUT"
        ;;

    gemini)
        echo "Running Gemini analysis..."
        echo ""

        # Run Gemini adapter
        GEMINI_OUTPUT=$("$SKILL_DIR/models/gemini/adapter.sh" "$PROBLEM" "$MODE" "$ENABLE_SEARCH" "./debate-session/gemini" 2>&1)

        cat >> "$REPORT_FILE" << EOF
## Gemini Analysis (Gemini 2.5 Pro)

$GEMINI_OUTPUT

---

EOF

        echo "$GEMINI_OUTPUT"
        ;;

    hybrid)
        echo "Running hybrid analysis (multiple models)..."
        echo ""

        # Run hybrid orchestrator
        "$SCRIPT_DIR/utils/hybrid-orchestrator.sh" "$PROBLEM" "${HYBRID_MODELS:-codex,claude,gemini}" "$MODE" "$REPORT_FILE"
        ;;

    *)
        echo "Error: Unknown model: $MODEL" >&2
        echo "Available models: codex, claude, gemini, auto, hybrid" >&2
        exit 1
        ;;
esac

# Finalize report
cat >> "$REPORT_FILE" << EOF

## Metadata

- **Total Duration:** $(date +"%Y-%m-%d %H:%M:%S")
- **Model:** $MODEL
- **Mode:** $MODE
- **Google Search:** $([ "$ENABLE_SEARCH" = true ] && echo "Enabled" || echo "Disabled")
- **Command:** \`$0 "$PROBLEM" --model $MODEL --mode $MODE $([ "$ENABLE_SEARCH" = true ] && echo "--search" || echo "")\`

EOF

echo ""
echo "=================================================="
echo "Debate Complete!"
echo "=================================================="
echo "Report saved to: $REPORT_FILE"
echo ""
echo "Review the report and validate recommendations before implementing."
echo ""

# Open report in editor if available
if command -v code &> /dev/null; then
    echo "Opening report in VS Code..."
    code "$REPORT_FILE"
elif [[ -n "${EDITOR:-}" ]]; then
    echo "Opening report in $EDITOR..."
    "$EDITOR" "$REPORT_FILE"
fi
