# Mid-Debate User Input Heuristic

**Purpose:** Guide Claude's decision-making on when to pause debate and request user input during Claude-Codex collaborative problem solving.

**Philosophy:** Agent-driven judgment. Claude evaluates debate context after each round and decides whether user clarification would improve the solution.

---

## When to Request User Input

### Condition 1: Information Deficit (정보 부족)

**Trigger:**
- Both Claude and Codex express low confidence (<50%)
- OR either explicitly states "I need user input to proceed"
- OR critical assumption identified that could invalidate solution

**Example Scenarios:**
```
❌ Bad: "We think Option A is slightly better"
✅ Good: "We cannot confidently choose between Option A and B without knowing user's performance vs maintainability priority"
```

**What to Ask:**
- Specific missing information
- User's priority when trade-offs exist
- Clarification of ambiguous requirements

**Template:**
```markdown
## 🤔 User Input Needed (Information Deficit)

**Current State:** We've identified two valid approaches but lack information to choose.

**Why:** [Explain the gap]

**Question:** [Specific question about missing information]

**Options:**
1. [Option A]: [Brief description]
2. [Option B]: [Brief description]
3. Skip and let us decide based on assumptions
```

---

### Condition 2: Preference Fork (선호도 갈림길)

**Trigger:**
- Clear trade-off discovered (e.g., performance vs complexity)
- Both options technically valid
- Decision depends on user's priorities or risk tolerance

**Example Scenarios:**
```
Trade-off: Fast implementation vs maintainable code
Trade-off: Higher cost vs better performance
Trade-off: Simple but limited vs complex but flexible
```

**What to Ask:**
- Which value is more important?
- What's the acceptable trade-off range?
- Long-term vs short-term priority?

**Template:**
```markdown
## 🤔 User Input Needed (Preference Fork)

**Current State:** Both approaches are technically sound but optimize for different goals.

**Trade-off Matrix:**
| Aspect | Option A | Option B |
|--------|----------|----------|
| [Dimension 1] | [Value] | [Value] |
| [Dimension 2] | [Value] | [Value] |

**Question:** Which aspect is more important for your use case?

**Options:**
1. Prioritize [Aspect 1]
2. Prioritize [Aspect 2]
3. Balanced approach (some compromise)
```

---

### Condition 3: New Constraint Discovery (새 제약 발견)

**Trigger:**
- Debate reveals constraint not mentioned in pre-clarification
- New technical limitation discovered
- Unexpected dependency or requirement surfaced

**Example Scenarios:**
```
"We discovered this requires PostgreSQL 14+, but pre-clarification said PostgreSQL 12"
"This approach needs admin privileges - is that acceptable?"
"Implementation would take 2 weeks, but timeline was 1 week"
```

**What to Ask:**
- Is the new constraint acceptable?
- Can we relax previous constraints?
- Is there additional context we're missing?

**Template:**
```markdown
## 🤔 User Input Needed (New Constraint)

**Current State:** We discovered a constraint that affects our approach.

**Discovered Constraint:** [Describe the constraint]

**Impact:** [How this changes the solution]

**Question:** [Ask about constraint acceptability or alternatives]

**Options:**
1. Accept constraint and adjust approach
2. Find workaround (with trade-offs: [list])
3. Re-evaluate requirements
```

---

### Condition 4: Long-Running Deadlock (장시간 교착)

**Trigger:**
- 3+ rounds of debate without converging
- High disagreement score (fundamental difference in approach)
- Circular reasoning detected

**Example Scenarios:**
```
Round 3: Still debating microservices vs monolith
Round 4: Cannot agree on database choice
Round 3: Stuck on whether to refactor or rewrite
```

**What to Ask:**
- User's tie-breaker input
- Additional context that might break deadlock
- Preference between contested options

**Template:**
```markdown
## 🤔 User Input Needed (Deadlock)

**Current State:** After {N} rounds, we have not reached consensus.

**Core Disagreement:**
- **Claude's position:** [Summary]
- **Codex's position:** [Summary]

**Both have valid points:**
- Claude emphasizes: [Key argument]
- Codex emphasizes: [Key argument]

**Question:** Which perspective aligns better with your priorities?

**Options:**
1. Go with Claude's approach
2. Go with Codex's approach
3. Provide additional context to help us converge
```

---

## When NOT to Request User Input

### ✅ Auto-Continue Scenarios

1. **High Confidence:**
   - Both Claude and Codex agree with >70% confidence
   - Clear winner based on evidence

2. **Making Progress:**
   - Each round adding value
   - Converging toward solution
   - No blockers identified

3. **Recent Question:**
   - Asked user within last 5 minutes (avoid spam)
   - User already provided relevant input this session

4. **Trivial Decisions:**
   - Minor implementation details
   - Doesn't affect core solution
   - Can be changed later easily

5. **Sufficient Pre-Clarification:**
   - Pre-debate clarification already covered this
   - No new information would change recommendation

---

## Decision Process (After Each Round)

```
After Round N:
    ↓
1. Evaluate debate state:
   - Confidence levels?
   - Agreement score?
   - Unresolved issues?
   - New constraints?
    ↓
2. Check conditions:
   - Information deficit? → Consider asking
   - Preference fork? → Consider asking
   - New constraint? → Consider asking
   - Deadlock (N≥3)? → Consider asking
    ↓
3. Check interval:
   - Asked recently? → Skip
   - < 5 min since last? → Skip
    ↓
4. Evaluate value:
   - Would user input improve solution significantly?
   - OR would it just interrupt flow?
    ↓
5. Decision:
   - If YES → Generate UserPrompt
   - If NO → Continue debate
```

---

## Heuristic Thresholds

### Confidence Scoring
- **High:** >70% - Strong evidence, clear path
- **Medium:** 40-70% - Reasonable but some uncertainty
- **Low:** <40% - Insufficient information or high risk

### Disagreement Scoring
- **Low:** <30% - Minor differences, easily resolved
- **Medium:** 30-60% - Significant but not fundamental
- **High:** >60% - Core approach differs, hard to reconcile

### Round Limits
- **Early (1-2 rounds):** Only ask if critical information missing
- **Mid (3-4 rounds):** Consider asking if deadlocked
- **Late (5 rounds):** Must make decision, summarize options for user

---

## Generating User Prompt

**Required Elements:**

1. **State Summary** (1-2 sentences)
   - Where are we in the debate?
   - What have we discussed?

2. **Reason** (1 sentence)
   - Why do we need user input?
   - What gap does it fill?

3. **Question** (Clear and specific)
   - Not vague: ❌ "What do you think?"
   - Specific: ✅ "Should we prioritize performance or maintainability?"

4. **Options** (If applicable)
   - 2-3 concrete choices
   - Brief pros/cons for each
   - Always include "Skip" option

5. **Note** (Reassurance)
   - "If you skip, we'll proceed with our best judgment"
   - "Your input helps us provide a better solution"

---

## Integration with Workflow

### Pre-Debate Clarification
- **Purpose:** Initial context gathering
- **Timing:** Before debate starts
- **Scope:** Broad (tech stack, goals, constraints)

### Mid-Debate User Input
- **Purpose:** Resolve specific uncertainties during debate
- **Timing:** Between rounds, as needed
- **Scope:** Narrow (specific choice, priority, validation)

**Relationship:**
- If pre-clarification was thorough → Less mid-debate input needed
- If pre-clarification was shallow → More mid-debate input may be required
- Complementary, not redundant

---

## Examples

### Example 1: Information Deficit

**Debate Context:**
- Round 2
- Discussing caching strategy
- Both Redis and Memcached viable
- Missing: Usage patterns, data persistence needs

**Heuristic Evaluation:**
```
Condition 1: ✅ Information deficit detected
Condition 2: ✅ Preference fork (trade-off present)
Confidence: Claude 45%, Codex 50%
Recent question: No (none yet)
Value: High (changes recommendation significantly)

Decision: ASK USER
```

**Generated Prompt:**
```markdown
## 🤔 User Input Needed

**Current State:** We're evaluating Redis vs Memcached for caching.

**Why:** Both are valid, but the best choice depends on your data persistence needs.

**Question:** Do you need cached data to survive server restarts?

**Options:**
1. Yes, persistence required → Redis (more features, slightly slower)
2. No, ephemeral cache is fine → Memcached (faster, simpler)
3. Skip (we'll recommend Redis for flexibility)
```

---

### Example 2: Auto-Continue (No Question)

**Debate Context:**
- Round 2
- Discussing database indexing
- Both Claude and Codex agree on B-tree indexes
- No trade-offs or uncertainties

**Heuristic Evaluation:**
```
Condition 1: ❌ No information deficit
Condition 2: ❌ No preference fork
Condition 3: ❌ No new constraints
Condition 4: ❌ Not deadlocked (only Round 2)
Confidence: Claude 85%, Codex 80%
Agreement: High (>90%)

Decision: CONTINUE AUTOMATICALLY
```

**Action:** Proceed to Round 3 without interrupting user.

---

## Calibration Tips

### Too Many Questions (Annoying)
**Symptom:** User skips most prompts, expresses frustration

**Fix:**
- Raise confidence threshold (e.g., 50% → 40%)
- Increase min interval (5min → 10min)
- Only ask for critical decisions

### Too Few Questions (Missed Opportunities)
**Symptom:** Final solution doesn't match user needs, assumptions were wrong

**Fix:**
- Lower confidence threshold (50% → 60%)
- Be more proactive with preference forks
- Ask earlier in debate (don't wait for deadlock)

### Good Balance (Target)
- 0-2 questions per debate session
- Only when genuinely valuable
- User responds (not skipping)
- Final solution alignment improves

---

## Quality Gate Integration

**After debate completes**, verify mid-debate input quality:

- [ ] If user input was requested, was it appropriate?
- [ ] If no user input requested, was that correct?
- [ ] Did user responses improve the solution?
- [ ] Were questions clear and actionable?

**Log for continuous improvement:**
- When: Round number, condition triggered
- What: Question asked
- Response: User answer or skip
- Outcome: Did it help? (retrospective judgment)

---

**Version:** 1.0
**Last Updated:** 2025-10-31
**Philosophy:** Agent-driven, minimal interruption, maximum value
