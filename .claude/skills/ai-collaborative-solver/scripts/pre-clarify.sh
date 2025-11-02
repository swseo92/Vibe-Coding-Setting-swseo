#!/usr/bin/env bash

# Pre-Clarification Stage V3.0
# Agent-driven complexity analysis and dynamic question generation
# Based on Codex V3.0 philosophy: "Scripts Assist, Agents Judge"

set -euo pipefail

PROBLEM="${1:-}"
OUTPUT_FILE="${2:-}"
SKIP_CLARIFY="${3:-false}"  # Optional: --skip-clarify flag

if [[ -z "$PROBLEM" ]]; then
    echo "Usage: $0 <problem_statement> [output_file] [skip_clarify]" >&2
    exit 1
fi

# Check skip flag
if [[ "$SKIP_CLARIFY" == "true" ]]; then
    echo "Clarification skipped (--skip-clarify flag)" >&2
    if [[ -n "$OUTPUT_FILE" ]]; then
        echo "$PROBLEM" > "$OUTPUT_FILE"
    fi
    echo "$PROBLEM"
    exit 0
fi

echo "=================================================="
echo "Pre-Clarification Stage V3.0"
echo "=================================================="
echo ""
echo "Agent-driven complexity analysis..."
echo ""

# Step 1: Agent-driven complexity judgment
# Claude analyzes if clarification is needed and how many questions
COMPLEXITY_PROMPT="You are analyzing a problem statement to determine if clarification is needed before starting a multi-AI debate.

**Problem Statement:**
$PROBLEM

**Your Task:**
Analyze the problem and determine:
1. Is the problem statement clear and complete? (YES/NO)
2. How many clarification questions are needed? (0-3)

**Decision Criteria:**

**Need 0 questions (Skip Clarification) if:**
- All constraints mentioned (tech stack, budget, timeline, team)
- Goals and success criteria clear
- Context provided (current system, scale, why this matters)

**Need 1-2 questions if:**
- Missing 1-2 key constraints
- Goals somewhat clear but could be more specific
- Some context provided

**Need 3 questions if:**
- Missing most constraints
- Goals unclear or vague
- Little to no context

**Output Format (JSON):**
{
  \"needs_clarification\": true/false,
  \"question_count\": 0-3,
  \"reason\": \"Brief explanation of why\"
}

Respond ONLY with valid JSON."

# Call Claude for complexity analysis
if command -v claude &> /dev/null; then
    COMPLEXITY_JSON=$(echo "$COMPLEXITY_PROMPT" | claude --print 2>/dev/null || echo "{\"needs_clarification\": true, \"question_count\": 2, \"reason\": \"Default (Claude CLI failed)\"}")
else
    echo "Warning: Claude CLI not found. Using default complexity." >&2
    COMPLEXITY_JSON="{\"needs_clarification\": true, \"question_count\": 2, \"reason\": \"Default (no CLI)\"}"
fi

# Parse JSON (simple grep-based extraction)
NEEDS_CLARIFICATION=$(echo "$COMPLEXITY_JSON" | grep -o '"needs_clarification": *[^,}]*' | sed 's/.*: *//' | tr -d ' "')
QUESTION_COUNT=$(echo "$COMPLEXITY_JSON" | grep -o '"question_count": *[^,}]*' | sed 's/.*: *//' | tr -d ' "')
REASON=$(echo "$COMPLEXITY_JSON" | grep -o '"reason": *"[^"]*"' | sed 's/.*: *"\(.*\)"/\1/')

echo "Complexity Analysis:"
echo "  Needs clarification: $NEEDS_CLARIFICATION"
echo "  Question count: $QUESTION_COUNT"
echo "  Reason: $REASON"
echo ""

# Understanding Confirmation Mode (instead of auto-skip)
if [[ "$NEEDS_CLARIFICATION" == "false" ]] || [[ "$QUESTION_COUNT" == "0" ]]; then
    echo "✓ Problem statement appears complete."
    echo ""
    echo "=================================================="
    echo "Understanding Confirmation"
    echo "=================================================="
    echo ""

    # Generate understanding summary using Claude
    UNDERSTANDING_PROMPT="You have received this problem statement:

**Problem:** $PROBLEM

The statement appears complete with sufficient information. Please:
1. Summarize your understanding of the problem
2. List key constraints and assumptions you identified
3. State what decision or solution is being requested

**Output Format:**
📋 **My Understanding:**
- [Main problem/decision]

🎯 **Identified Constraints:**
- [Constraint 1]
- [Constraint 2]
...

🔍 **Assumptions I'm Making:**
- [Assumption 1]
- [Assumption 2]
...

Keep it concise (3-5 bullet points each)."

    # Call Claude for understanding summary
    if command -v claude &> /dev/null; then
        UNDERSTANDING=$(echo "$UNDERSTANDING_PROMPT" | claude --print 2>/dev/null || echo "")
    else
        UNDERSTANDING="[Claude CLI not available - proceeding with original problem]"
    fi

    # Validate output
    if [[ -z "$UNDERSTANDING" ]]; then
        UNDERSTANDING="📋 Problem: $PROBLEM
🎯 Constraints: [Will be identified during debate]
🔍 Assumptions: [Will be validated during debate]"
    fi

    echo "$UNDERSTANDING"
    echo ""
    echo "=================================================="
    echo ""

    # Check if running in interactive mode
    if [[ -t 0 ]]; then
        # Ask for confirmation
        echo "Is this understanding correct? (y/n/add info)"
        read -p "Your choice [y/n/a]: " -n 1 -r CONFIRM
        echo ""
        echo ""

        case "$CONFIRM" in
            n|N)
                echo "Let me ask clarifying questions instead..."
                echo ""
                # Force question mode
                QUESTION_COUNT=2
                ;;
            a|A)
                echo "Please provide additional information or corrections:"
                echo "(Press Ctrl+D when done)"
                echo "---"
                ADDITIONAL_INFO=$(cat)
                echo "---"
                echo ""

                # Build enriched problem
                ENRICHED_PROBLEM="**Original Problem:**
$PROBLEM

**Your Clarification:**
$ADDITIONAL_INFO

**AI Understanding:**
$UNDERSTANDING"

                if [[ -n "$OUTPUT_FILE" ]]; then
                    echo "$ENRICHED_PROBLEM" > "$OUTPUT_FILE"
                fi

                echo "✓ Using enriched problem with your clarifications."
                echo ""
                echo "$ENRICHED_PROBLEM"
                exit 0
                ;;
            *)
                # y/Y or default - confirmed
                echo "✓ Understanding confirmed. Proceeding with debate..."
                echo ""

                # Build enriched problem with understanding
                ENRICHED_PROBLEM="**Problem:**
$PROBLEM

**Confirmed Understanding:**
$UNDERSTANDING"

                if [[ -n "$OUTPUT_FILE" ]]; then
                    echo "$ENRICHED_PROBLEM" > "$OUTPUT_FILE"
                fi

                echo "$ENRICHED_PROBLEM"
                exit 0
                ;;
        esac
    else
        # Non-interactive mode - proceed without confirmation
        echo "Non-interactive mode - proceeding with debate..."

        if [[ -n "$OUTPUT_FILE" ]]; then
            echo "$PROBLEM" > "$OUTPUT_FILE"
        fi

        echo "$PROBLEM"
        exit 0
    fi
fi

# Step 2: Generate dynamic questions based on problem type
QUESTION_PROMPT="Generate exactly $QUESTION_COUNT clarification questions for this problem:

**Problem:** $PROBLEM

**Question Categories (Essential):**
- **Constraints**: Tech stack, budget, timeline, team capability
- **Goals**: Success criteria, target metrics, what defines 'solved'
- **Context**: Current system, scale, why this problem matters

**Question Categories (Conditional - based on problem type):**
- **Performance**: Target metrics, current profiling data
- **Architecture**: Existing system, integration concerns
- **Security**: Compliance requirements, threat model
- **Bug**: Reproduction steps, error logs

**Output Format:**
1. [First question - most critical]
2. [Second question - important]
3. [Third question - helpful]

Generate EXACTLY $QUESTION_COUNT questions.
Keep questions concise (1-2 sentences).
Focus on information that would significantly impact the recommendation."

# Call Claude to generate questions
if command -v claude &> /dev/null; then
    QUESTIONS=$(echo "$QUESTION_PROMPT" | claude --print 2>/dev/null || echo "")
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
