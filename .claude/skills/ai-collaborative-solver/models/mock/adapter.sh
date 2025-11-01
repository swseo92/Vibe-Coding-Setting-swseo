#!/usr/bin/env bash
# Mock adapter for testing facilitator
# Does not make real AI calls - returns dummy responses

set -euo pipefail

PROBLEM="$1"
MODE="$2"
STATE_DIR="$3"

mkdir -p "$STATE_DIR"

# Simulate different responses based on context
if [[ -n "${DEBATE_CONTEXT:-}" ]]; then
    # This is a follow-up round
    RESPONSE="Mock Response (with context):

After reviewing the previous discussion, I maintain my analysis:

**Refined Analysis:**
- Point 1: Building on previous insights
- Point 2: Addressing concerns raised by other models
- Point 3: New perspective on $PROBLEM

**Updated Recommendation:**
Based on the multi-round discussion, I recommend proceeding with a balanced approach.

**Confidence:** 85% (+10% from last round due to convergence)"
else
    # This is the first round
    RESPONSE="Mock Response (initial):

Analysis of: $PROBLEM

**Initial Assessment:**
- Point 1: This is a common problem in distributed systems
- Point 2: Multiple approaches are viable depending on constraints
- Point 3: Performance vs Complexity tradeoff is key

**Potential Solutions:**
1. Solution A: Fast but complex
2. Solution B: Simple but slower
3. Solution C: Balanced approach

**Initial Recommendation:**
I recommend starting with Solution C (balanced approach) to minimize risk.

**Confidence:** 75%"
fi

# Output to both stdout and state file
echo "$RESPONSE"
echo "$RESPONSE" > "$STATE_DIR/last_response.txt"

# Simulate successful execution
exit 0
