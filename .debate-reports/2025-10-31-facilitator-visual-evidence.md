# Facilitator Context Passing - Visual Evidence

**Date:** 2025-10-31
**Purpose:** Show concrete proof that context passing works AND the duplication issue

---

## Evidence #1: Context Detection in Mock Adapter

### Mock Adapter Code (adapter.sh)
```bash
#!/usr/bin/env bash
set -euo pipefail

# Check if context was passed (from other models)
CONTEXT="${DEBATE_CONTEXT:-}"

# Generate response based on whether we have context
if [[ -z "$CONTEXT" ]]; then
    # Round 1: No context
    RESPONSE="Mock Response (initial):

**Initial Assessment:**
...
**Confidence:** 75%"
else
    # Round 2+: Has context from other models
    RESPONSE="Mock Response (with context):

After reviewing the previous discussion, I maintain my analysis:

**Refined Analysis:**
- Point 1: Building on previous insights
- Point 2: Addressing concerns raised by other models
...
**Confidence:** 85% (+10% from last round due to convergence)"
fi

echo "$RESPONSE"
```

### Proof: Different Outputs

**Round 1 Output (No Context):**
```
Mock Response (initial):

Analysis of: You are participating in a multi-model AI debate...

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

**Confidence:** 75%
```

**Round 2 Output (WITH Context):**
```
Mock Response (with context):

After reviewing the previous discussion, I maintain my analysis:

**Refined Analysis:**
- Point 1: Building on previous insights
- Point 2: Addressing concerns raised by other models
- Point 3: New perspective on ## Context from Other Models:

### mock:
[... Round 1 content shown here ...]

**Updated Recommendation:**
Based on the multi-round discussion, I recommend proceeding with a balanced approach.

**Confidence:** 85% (+10% from last round due to convergence)
```

**PROOF:** Adapter detects context presence and changes behavior!

---

## Evidence #2: File Size Explosion

### Actual File Sizes
```bash
$ ls -lh test-facilitated/rounds/

-rw-r--r-- 1 swseo 1049089  1.9K round1_mock_response.txt  ← Clean
-rw-r--r-- 1 swseo 1049089  9.6K round2_mock_response.txt  ← 5x larger!
-rw-r--r-- 1 swseo 1049089   41K round3_mock_response.txt  ← 4x larger!
-rw-r--r-- 1 swseo 1049089  210K final_mock_response.txt   ← 5x larger!
```

### Growth Pattern (Exponential!)
```
Round 1:   1.9K  (baseline)
Round 2:   9.6K  (× 5.0)
Round 3:  41.0K  (× 4.3)
Final:   210.0K  (× 5.1)
```

Average growth: **~4.8x per round**

---

## Evidence #3: Duplication Structure

### Round 1 (Clean - 1.9K)
```
  Running mock adapter...
Mock Response (initial):

Analysis of: [Problem statement]

**Initial Assessment:**
[3 bullet points]

**Potential Solutions:**
[3 solutions]

**Confidence:** 75%
```

### Round 2 (Includes R1 - 9.6K)
```
  Running mock adapter...
Mock Response (with context):

After reviewing the previous discussion...

**Refined Analysis:**
[3 bullet points]

## Context from Other Models:     ← Context starts here

### mock:

  Running mock adapter...          ← R1 content repeated!
Mock Response (initial):

Analysis of: [Problem statement]

**Initial Assessment:**
[3 bullet points]

**Potential Solutions:**
[3 solutions]

**Confidence:** 75%
[... R1 repeated in full ...]

---

## Your Task:
[Round 2 prompt]

**Confidence:** 85%
```

**Structure:**
- New response (500 bytes)
- Context from R1 (1.9K)
- Round 2 prompt (200 bytes)
- Total: 9.6K (includes duplicated R1)

### Round 3 (Includes R2 which includes R1 - 41K)
```
  Running mock adapter...
Mock Response (with context):

After reviewing the previous discussion...

**Refined Analysis:**
[3 bullet points]

## Context from Other Models:     ← Context starts here

### mock:

  Running mock adapter...          ← R2 content repeated!
Mock Response (with context):     ← R2 itself contains R1!

After reviewing the previous discussion...

## Context from Other Models:     ← Nested context!

### mock:

  Running mock adapter...          ← R1 content (nested 2 levels deep!)
Mock Response (initial):

Analysis of: [Problem statement]
[... R1 repeated AGAIN ...]

---

[... R2 continued ...]

---

## Your Task:
[Round 3 prompt]

**Confidence:** 85%
```

**Structure:**
- New response (500 bytes)
- Context from R2 (9.6K)
  - Which contains R1 (1.9K nested inside)
- Round 3 prompt (200 bytes)
- Total: 41K (includes R2 + nested R1)

**Duplication Count:**
- Round 1 content appears: **1 time** in Round 1
- Round 1 content appears: **2 times** in Round 2 (original + context)
- Round 1 content appears: **4 times** in Round 3 (original + in R2 context + in R3 context + nested)

---

## Evidence #4: Context Passing Mechanism

### Facilitator Code (facilitator.sh)

**Round 1 - No Context:**
```bash
ROUND1_PROMPT="You are participating in a multi-model AI debate...

**Your Task (Round 1):**
1. Analyze the problem from your unique perspective
..."

for model in "${MODEL_LIST[@]}"; do
    response=$(run_model_with_context "$model" 1 "$ROUND1_PROMPT" "")
    #                                                              ↑
    #                                                         Empty context!
done
```

**Round 2+ - WITH Context:**
```bash
for ((round=2; round<=ROUNDS; round++)); do
    # Collect all previous responses as context
    CONTEXT=$(collect_all_responses $((round-1)))
    #         ↑
    #         Gets ENTIRE previous round file (including nested contexts!)

    ROUND_PROMPT="**Previous Round Responses:**

$CONTEXT
        ↑
        Full context injected here!

---

**Your Task (Round $round of $ROUNDS):**
1. Review the responses from other AI models above
..."

    for model in "${MODEL_LIST[@]}"; do
        response=$(run_model_with_context "$model" $round "$ROUND_PROMPT" "$CONTEXT")
        #                                                                    ↑
        #                                                         Context passed here!
    done
done
```

**Inside `run_model_with_context()`:**
```bash
run_model_with_context() {
    local model="$1"
    local round_num="$2"
    local prompt="$3"
    local context="${4:-}"  # Optional context

    # Build full prompt with context
    local full_prompt="$prompt"
    if [[ -n "$context" ]]; then
        full_prompt="## Context from Other Models:

$context

---

## Your Task:
$prompt"
    fi

    # Pass context as environment variable
    DEBATE_CONTEXT="$context" bash "$adapter_script" "$full_prompt" "$MODE" "$model_state_dir"
    #                ↑
    #         Environment variable set here!
}
```

**Adapter receives:**
```bash
# In adapter.sh
CONTEXT="${DEBATE_CONTEXT:-}"
#         ↑
#         Environment variable available!

if [[ -z "$CONTEXT" ]]; then
    echo "No context - Round 1"
else
    echo "Has context - Round 2+"
    echo "Context preview: $(echo "$CONTEXT" | head -5)"
fi
```

---

## Evidence #5: Actual Context Content (Round 2)

### What Round 2 Adapter Sees in `$DEBATE_CONTEXT`

**First 20 lines:**
```
  Running mock adapter...
Mock Response (initial):

Analysis of: You are participating in a multi-model AI debate to solve this problem:

**Problem:** Redis vs Memcached for caching

**Your Task (Round 1):**
1. Analyze the problem from your unique perspective
2. Generate 3-5 potential approaches or solutions
3. Highlight key considerations and tradeoffs
4. Provide initial recommendation with confidence level (0-100%)

**Mode:** simple
**Round:** 1 of 3

Be thorough but concise. This is the initial exploration phase.

**Initial Assessment:**
- Point 1: This is a common problem in distributed systems
- Point 2: Multiple approaches are viable depending on constraints
```

**Analysis:**
- ✅ Context contains Round 1's full response
- ✅ Adapter can parse this to extract insights
- ⚠️ Context is verbose (includes prompt text)
- ⚠️ But it DOES contain the actual analysis

**Conclusion:** Context passing works! Adapter receives meaningful previous round content.

---

## Visual Summary: The Duplication Problem

### Diagram: Context Nesting
```
Round 1 File (1.9K):
┌─────────────────────────┐
│ "Initial Analysis"      │
│ Confidence: 75%         │
└─────────────────────────┘

Round 2 File (9.6K):
┌─────────────────────────────────────────┐
│ "After reviewing..."                    │
│ Confidence: 85%                         │
│                                         │
│ Context from Other Models:              │
│ ┌─────────────────────────┐            │
│ │ "Initial Analysis"      │ ← R1 copy  │
│ │ Confidence: 75%         │            │
│ └─────────────────────────┘            │
└─────────────────────────────────────────┘

Round 3 File (41K):
┌───────────────────────────────────────────────────────────┐
│ "After reviewing..."                                      │
│ Confidence: 85%                                           │
│                                                           │
│ Context from Other Models:                                │
│ ┌─────────────────────────────────────────┐              │
│ │ "After reviewing..."                    │ ← R2 copy    │
│ │ Confidence: 85%                         │              │
│ │                                         │              │
│ │ Context from Other Models:              │              │
│ │ ┌─────────────────────────┐            │              │
│ │ │ "Initial Analysis"      │ ← R1 copy  │              │
│ │ │ Confidence: 75%         │   (nested!)│              │
│ │ └─────────────────────────┘            │              │
│ └─────────────────────────────────────────┘              │
└───────────────────────────────────────────────────────────┘
```

**Growth Explanation:**
- Round 1: Just the response (1.9K)
- Round 2: Response + R1 context (9.6K = 1.9K × 5)
- Round 3: Response + R2 context which includes R1 (41K = 9.6K × 4.3)
- Final: Response + R3 context which includes R2 which includes R1 (210K!)

**Each round includes ALL previous rounds nested recursively!**

---

## Conclusion

### What We Proved
1. ✅ **Context passing WORKS** - Adapter receives and detects context correctly
2. ✅ **Round-by-round structure WORKS** - Sequential execution is clean
3. ✅ **Mechanism is SOUND** - Environment variable passing is reliable
4. ❌ **Duplication BUG EXISTS** - Context accumulates nested copies

### The Fix
```bash
# Current (Wrong):
collect_all_responses() {
    cat "$STATE_DIR/rounds/round${round}_${model}_response.txt"
    #   ↑ Includes entire file (with nested contexts!)
}

# Fixed (Right):
collect_all_responses() {
    # Extract only the model's actual response
    # Skip "## Context from Other Models:" sections
    grep -A 999 "Mock Response" "$STATE_DIR/rounds/round${round}_${model}_response.txt" | \
    grep -B 999 "^---$" | \
    head -n 50  # Limit to first 50 lines of actual response
}
```

**Expected Result After Fix:**
- Round 1: 1.9K ✅
- Round 2: ~3K (not 9.6K)
- Round 3: ~4K (not 41K)
- Final: ~5K (not 210K!)

---

**Visual Evidence Complete**
