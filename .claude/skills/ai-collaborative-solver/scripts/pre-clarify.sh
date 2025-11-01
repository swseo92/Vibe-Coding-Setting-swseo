#!/usr/bin/env bash

# Pre-Clarification Stage
# Analyzes problem statement and generates clarifying questions
# to reduce ambiguity before starting multi-AI debate

set -euo pipefail

PROBLEM="${1:-}"
OUTPUT_FILE="${2:-}"

if [[ -z "$PROBLEM" ]]; then
    echo "Usage: $0 <problem_statement> [output_file]" >&2
    exit 1
fi

echo "=================================================="
echo "Pre-Clarification Stage"
echo "=================================================="
echo ""
echo "Analyzing problem for potential ambiguities..."
echo ""

# Generate clarification questions using Claude
CLARIFICATION_PROMPT="Analyze this problem statement and identify any ambiguities or missing information:

**Problem:** $PROBLEM

**Your Task:**
1. Identify 3-5 key ambiguities or missing constraints
2. Generate specific clarifying questions
3. Format as a numbered list

**Focus on:**
- Missing constraints (performance, cost, timeline)
- Unclear goals (what does 'better' mean?)
- Context gaps (current system, team skills, scale)
- Implicit assumptions that should be explicit

**Output Format:**
1. [Question about constraint/context]
2. [Question about goals/metrics]
3. [Question about assumptions]
...

Keep questions concise and actionable."

# Call Claude to generate questions
if command -v claude &> /dev/null; then
    QUESTIONS=$(echo "$CLARIFICATION_PROMPT" | claude --print 2>/dev/null || echo "")
else
    echo "Warning: Claude CLI not found. Using default questions." >&2
    QUESTIONS="1. What are your primary constraints (performance, cost, timeline)?
2. How do you define success for this decision?
3. What is your current system/context?"
fi

# Validate output
if [[ -z "$QUESTIONS" ]]; then
    echo "Error: Failed to generate clarification questions" >&2
    QUESTIONS="1. What are your primary constraints?
2. What is your success criteria?
3. What is your current context?"
fi

# Present questions to user
echo "=================================================="
echo "Clarification Questions"
echo "=================================================="
echo ""
echo "$QUESTIONS"
echo ""
echo "=================================================="
echo ""

# Check if running in interactive mode
if [[ -t 0 ]]; then
    # Interactive mode - ask user for responses
    echo "Please answer the questions above (or press Enter to skip):"
    echo ""

    read -p "Your response (multi-line, Ctrl+D to finish): " -d $'\04' USER_RESPONSE || USER_RESPONSE=""
    echo ""
else
    # Non-interactive mode - skip clarification
    echo "Non-interactive mode detected. Skipping clarification."
    USER_RESPONSE="[Clarification skipped - non-interactive mode]"
fi

# Build enriched problem statement
ENRICHED_PROBLEM="**Original Problem:**
$PROBLEM

**Clarification Context:**"

if [[ -n "$USER_RESPONSE" && "$USER_RESPONSE" != "[Clarification skipped - non-interactive mode]" ]]; then
    ENRICHED_PROBLEM+="
$USER_RESPONSE"
else
    ENRICHED_PROBLEM+="
[No additional clarification provided]"
fi

# Output enriched problem
echo ""
echo "=================================================="
echo "Enriched Problem Statement"
echo "=================================================="
echo ""
echo "$ENRICHED_PROBLEM"
echo ""

# Save to file if specified
if [[ -n "$OUTPUT_FILE" ]]; then
    echo "$ENRICHED_PROBLEM" > "$OUTPUT_FILE"
    echo "Enriched problem saved to: $OUTPUT_FILE"
fi

# Return enriched problem (for script chaining)
echo "$ENRICHED_PROBLEM"
