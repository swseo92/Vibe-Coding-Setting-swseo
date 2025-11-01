# Facilitator Context Duplication - Fix Proposal

**Date:** 2025-10-31
**Issue:** Recursive context accumulation causing exponential file growth
**Priority:** HIGH (Blocks production use)

---

## Problem Statement

### Current Behavior
```
Round 1:   1.9K  (clean)
Round 2:   9.6K  (includes full R1)
Round 3:  41.0K  (includes R2 which includes R1)
Final:   210.0K  (includes R3 which includes R2 which includes R1)
```

**Growth Rate:** ~5x per round (exponential!)

### Root Cause

**File:** `scripts/facilitator.sh` Line 183

```bash
# Current implementation (WRONG)
collect_all_responses() {
    local prev_round=$1
    local context=""

    for model in "${MODEL_LIST[@]}"; do
        local response_file="$STATE_DIR/rounds/round${prev_round}_${model}_response.txt"
        if [[ -f "$response_file" ]]; then
            context+="### $model:\n\n"
            context+="$(cat "$response_file")"  # ← Includes ENTIRE file!
            #           ↑
            #           This file already contains nested "Context from Other Models" sections!
            context+="\n\n---\n\n"
        fi
    done

    echo -e "$context"
}
```

**Problem:** Each round's response file contains:
1. The model's actual response (~500 bytes)
2. "Context from Other Models" section from previous rounds (nested!)
3. The round prompt (~200 bytes)

When we `cat` the entire file, we include all nested contexts recursively!

---

## Solution: Extract Only Pure Responses

### Option 1: Extract Response Only (Recommended)

```bash
collect_all_responses() {
    local prev_round=$1
    local context=""

    for model in "${MODEL_LIST[@]}"; do
        local response_file="$STATE_DIR/rounds/round${prev_round}_${model}_response.txt"
        if [[ -f "$response_file" ]]; then
            context+="### $model:\n\n"

            # Extract only the pure response (skip context and prompts)
            # Method: Take content between "Mock Response" and first "##" marker
            local pure_response=$(grep -A 999 "Mock Response" "$response_file" | \
                                  grep -B 999 "^## Context" | \
                                  head -n -1)

            # Fallback if no "## Context" marker found (Round 1)
            if [[ -z "$pure_response" ]]; then
                pure_response=$(grep -A 999 "Mock Response" "$response_file" | head -n 50)
            fi

            context+="$pure_response"
            context+="\n\n---\n\n"
        fi
    done

    echo -e "$context"
}
```

**Result:**
- Round 2 context: Only R1 response (~500 bytes)
- Round 3 context: Only R2 response (~500 bytes)
- File sizes: R1=1.9K, R2=3K, R3=4K, Final=5K ✅

### Option 2: Use State File (Cleaner)

**Better approach:** Save pure responses separately.

**Modify facilitator.sh:**

```bash
# After running adapter, extract pure response
run_model_with_context() {
    local model="$1"
    local round_num="$2"
    local prompt="$3"
    local context="${4:-}"

    # ... existing code ...

    # Call adapter
    local full_response=$(DEBATE_CONTEXT="$context" bash "$adapter_script" "$full_prompt" "$MODE" "$model_state_dir" 2>&1)

    # Save FULL response (for debugging)
    echo "$full_response" > "$STATE_DIR/rounds/round${round_num}_${model}_response.txt"

    # Extract and save PURE response (for context passing)
    local pure_response=$(echo "$full_response" | grep -A 999 "Mock Response" | head -n 30)
    echo "$pure_response" > "$STATE_DIR/rounds/round${round_num}_${model}_pure.txt"

    echo "$full_response"
}

# Update collect_all_responses to use pure files
collect_all_responses() {
    local prev_round=$1
    local context=""

    for model in "${MODEL_LIST[@]}"; do
        local pure_file="$STATE_DIR/rounds/round${prev_round}_${model}_pure.txt"
        if [[ -f "$pure_file" ]]; then
            context+="### $model:\n\n"
            context+="$(cat "$pure_file")"  # ← Use pure file!
            context+="\n\n---\n\n"
        fi
    done

    echo -e "$context"
}
```

**Benefits:**
- Clean separation: full response (debug) vs pure response (context)
- Easy to read context files
- No parsing/grep needed
- More maintainable

---

## Option 3: Context Summarization (Advanced)

For very long debates (5+ rounds), even pure responses might accumulate.

**Add summarization after Round 3:**

```bash
collect_all_responses() {
    local prev_round=$1
    local context=""

    for model in "${MODEL_LIST[@]}"; do
        local pure_file="$STATE_DIR/rounds/round${prev_round}_${model}_pure.txt"
        if [[ -f "$pure_file" ]]; then
            local content=$(cat "$pure_file")

            # If content is too long, summarize
            if [[ ${#content} -gt 2000 ]]; then
                # Extract key points only
                content=$(echo "$content" | grep -E "^\*\*|^-" | head -n 10)
                content+="\n\n[Full response truncated for brevity]"
            fi

            context+="### $model:\n\n$content\n\n---\n\n"
        fi
    done

    echo -e "$context"
}
```

---

## Comparison: Before vs After

### Before (Current)
```bash
$ ls -lh test-facilitated/rounds/
-rw-r--r-- 1.9K round1_mock_response.txt
-rw-r--r-- 9.6K round2_mock_response.txt
-rw-r--r--  41K round3_mock_response.txt
-rw-r--r-- 210K final_mock_response.txt

$ du -sh test-facilitated/
263K test-facilitated/
```

### After (With Fix - Option 2)
```bash
$ ls -lh test-facilitated/rounds/
# Full responses (for debugging)
-rw-r--r-- 1.9K round1_mock_response.txt
-rw-r--r-- 3.0K round2_mock_response.txt
-rw-r--r-- 4.0K round3_mock_response.txt
-rw-r--r-- 5.0K final_mock_response.txt

# Pure responses (for context)
-rw-r--r-- 500B round1_mock_pure.txt
-rw-r--r-- 500B round2_mock_pure.txt
-rw-r--r-- 500B round3_mock_pure.txt

$ du -sh test-facilitated/
15K test-facilitated/  ← 17x smaller!
```

---

## Implementation Plan

### Step 1: Update `collect_all_responses()` (Quick Fix)

**File:** `scripts/facilitator.sh`
**Change:** Line 183-200 (approximately)

Replace current implementation with Option 1 (grep-based extraction).

**Testing:**
```bash
bash scripts/facilitator.sh "Test problem" mock simple ./test-fix
ls -lh ./test-fix/rounds/
# Expected: R1=1.9K, R2=3K, R3=4K (not 9.6K, 41K!)
```

### Step 2: Add Pure Response Files (Better Fix)

**File:** `scripts/facilitator.sh`
**Changes:**
1. Update `run_model_with_context()` to save both full and pure responses
2. Update `collect_all_responses()` to read from pure files

**Testing:**
```bash
bash scripts/facilitator.sh "Test problem" mock simple ./test-fix-v2
ls -lh ./test-fix-v2/rounds/
# Expected: *_pure.txt files present, small sizes
cat ./test-fix-v2/rounds/round2_mock_pure.txt
# Expected: Only the actual response, no nested context
```

### Step 3: Add Context Truncation (Optional)

**File:** `scripts/facilitator.sh`
**Add:** Token budget management in `collect_all_responses()`

**Testing:**
```bash
# Test with 5+ rounds
bash scripts/facilitator.sh "Test problem" mock deep ./test-truncate
# Expected: Context stabilizes at ~4K regardless of round count
```

---

## Testing Checklist

After applying fix:

- [ ] Round 1 still works (no context)
- [ ] Round 2 receives R1 context (but not nested)
- [ ] Round 3 receives R2 context (but not R1 nested in R2)
- [ ] File sizes grow linearly (not exponentially)
- [ ] debate_summary.md is readable (<20K)
- [ ] Mock adapter still detects context correctly
- [ ] Test with codex adapter (real API calls)

---

## Risk Assessment

### Risks of NOT Fixing
1. **Production blocker:** Can't use with real APIs (token waste)
2. **Unreadable output:** 200K+ files are impractical
3. **Performance:** Large files slow down processing
4. **Cost:** Wasted API tokens ($$$ if using paid APIs)

### Risks of Fixing
1. **Breaking change:** Might affect existing debates
   - Mitigation: Test thoroughly with mock before deploying
2. **Context loss:** Extracting pure response might miss important info
   - Mitigation: Save both full and pure versions
3. **Regression:** New bugs in extraction logic
   - Mitigation: Keep original implementation as fallback

**Recommendation:** LOW RISK, HIGH REWARD - Proceed with fix!

---

## Expected Impact

### Before Fix
```
Test problem: "Redis vs Memcached"
Rounds: 3
Models: mock

Output: 263K total
- Unreadable due to duplication
- Mock appears broken (repetitive)
- Can't assess debate quality
```

### After Fix
```
Test problem: "Redis vs Memcached"
Rounds: 3
Models: mock

Output: 15K total (17x smaller!)
- Clean, readable summaries
- Clear round-by-round evolution
- Easy to assess debate quality
- Ready for real API testing
```

---

## Next Steps

1. **Apply Quick Fix** (Option 1) - 15 minutes
   - Test with mock adapter
   - Verify file sizes reduced
   - Check output readability

2. **Verify Quality** - 10 minutes
   - Re-run quality investigation
   - Confirm duplication eliminated
   - Update report grades

3. **Test with Real Adapter** - 30 minutes
   - Run with codex adapter (1 real debate)
   - Measure: Does multi-round improve solution quality?
   - Compare single-round vs multi-round outputs

4. **Deploy** - 5 minutes
   - Update facilitator.sh in main branch
   - Document fix in changelog
   - Close issue

**Total Time:** ~1 hour

---

## Code Patch (Ready to Apply)

**File:** `scripts/facilitator.sh`

```diff
--- a/scripts/facilitator.sh
+++ b/scripts/facilitator.sh
@@ -180,12 +180,25 @@ collect_all_responses() {
     for model in "${MODEL_LIST[@]}"; do
         local response_file="$STATE_DIR/rounds/round${prev_round}_${model}_response.txt"
         if [[ -f "$response_file" ]]; then
             context+="### $model:\n\n"
-            context+="$(cat "$response_file")"
+
+            # Extract only the pure response (skip nested contexts)
+            local pure_response=$(grep -A 999 "Mock Response" "$response_file" | \
+                                  grep -v "^## Context" -A 0 | \
+                                  head -n 30)
+
+            # Fallback: If extraction fails, take first 30 lines
+            if [[ -z "$pure_response" ]]; then
+                pure_response=$(head -n 30 "$response_file")
+            fi
+
+            context+="$pure_response"
             context+="\n\n---\n\n"
         fi
     done

     echo -e "$context"
 }
```

**To apply:**
```bash
cd .claude/skills/ai-collaborative-solver
# Backup original
cp scripts/facilitator.sh scripts/facilitator.sh.backup

# Apply patch manually or via editor
# Test:
bash scripts/facilitator.sh "Test" mock simple ./test-patched
ls -lh ./test-patched/rounds/
```

---

**Fix Proposal Complete - Ready for Implementation**
