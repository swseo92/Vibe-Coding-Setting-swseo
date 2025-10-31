# Reasoning Log Integration for Mid-Debate User Input

**Purpose:** Ensure user responses are properly incorporated into debate reasoning and prevent repeated questions.

---

## Overview

When user provides input during debate:
1. **Capture** the question and answer
2. **Log** to reasoning context
3. **Inject** into next debate round
4. **Track** to avoid re-asking
5. **Reference** in final report

---

## Data Structure

### User Input Record

```json
{
  "session_id": "019a39bb-801f-79e3-8915-8cdbb37bc097",
  "round_number": 2,
  "timestamp": "2025-10-31T18:45:30Z",
  "condition_triggered": "information_deficit",
  "question": {
    "type": "information_deficit",
    "text": "Do you need cached data to survive server restarts?",
    "options": [
      "Yes, persistence required",
      "No, ephemeral cache is fine",
      "Skip"
    ]
  },
  "user_response": {
    "selected_option": 1,
    "text": "Yes, persistence required",
    "additional_context": "We need session data to survive restarts"
  },
  "time_to_respond": 45,  // seconds
  "impact": "Changed recommendation from Memcached to Redis"
}
```

---

## Integration Points

### 1. Capture User Response

**After user answers:**

```markdown
User selected: Option 1 - "Yes, persistence required"
Additional context: "We need session data to survive restarts"

✓ Input captured. Thank you!
```

**Internal logging:**
```python
user_input = {
    "round": current_round,
    "question_hash": hash(question_text),  # Prevent re-asking
    "question": question_text,
    "answer": user_answer,
    "context": additional_context,
    "timestamp": now()
}

debate_session.user_inputs.append(user_input)
```

---

### 2. Inject into Next Round

**Format for Codex (next round):**

```bash
# Round 3 prompt to Codex
codex exec "Continuing debate (Round 3)

## Previous Rounds Summary
[Brief summary of Rounds 1-2]

## User Clarification (Round 2)
The user provided important input:

**Question:** Do you need cached data to survive server restarts?
**Answer:** Yes, persistence required
**Context:** We need session data to survive restarts

**Impact on Analysis:**
This clarifies that Redis is preferred over Memcached due to persistence requirements.

## Your Turn
Given this user preference, please:
1. Re-evaluate your position if needed
2. Incorporate this constraint
3. Continue the analysis

[Continue with Round 3 discussion]"
```

**Claude's internal note:**
```markdown
📝 Note to self: User wants persistence.
   - Redis: ✓ Supports persistence
   - Memcached: ✗ Ephemeral only
   - Decision: Redis is correct choice
```

---

### 3. Track Asked Questions

**Purpose:** Prevent asking same/similar question twice.

**Implementation:**

```python
class DebateSession:
    def __init__(self):
        self.asked_questions = set()  # Store question hashes
        self.user_preferences = {}     # Store answers

    def has_asked_about(self, topic: str) -> bool:
        """Check if we've already asked about this topic"""
        topic_hash = self._hash_topic(topic)
        return topic_hash in self.asked_questions

    def record_question(self, question: str, answer: str):
        """Record that we asked this question"""
        q_hash = self._hash_topic(question)
        self.asked_questions.add(q_hash)
        self.user_preferences[q_hash] = answer

    def _hash_topic(self, text: str) -> str:
        """Generate semantic hash for topic"""
        # Normalize: lowercase, remove punctuation
        normalized = text.lower().strip('?!.,')

        # Extract key terms
        keywords = ['persistence', 'performance', 'cost', 'timeline', etc.]

        # Simple hash based on key terms present
        return '_'.join(sorted([k for k in keywords if k in normalized]))
```

**Example:**
```python
# Round 2
session.record_question(
    "Do you need persistence?",
    "Yes, required"
)

# Later rounds
if session.has_asked_about("Do cached objects need to survive restarts?"):
    # Same topic, different wording
    skip_question = True
    use_previous_answer = session.user_preferences['persistence']
```

---

### 4. Reference in Debate Transcript

**Claude's reasoning (visible to user):**

```markdown
## Round 3 Analysis

Based on user input from Round 2:
- ✓ Persistence IS required
- Therefore: Redis > Memcached

[Continue analysis with this constraint...]
```

**Codex's response (Round 3):**

```markdown
Agreed with Claude. Given user's persistence requirement,
Redis is the clear choice.

Additional benefits of Redis in this context:
- [list benefits]
```

---

### 5. Include in Final Report

**Debate Report Section:**

```markdown
## User Input During Debate

### Round 2: Clarification Request
**Condition:** Information Deficit
**Question:** Do you need cached data to survive server restarts?
**Answer:** Yes, persistence required
**Impact:** This eliminated Memcached from consideration and confirmed Redis as the solution.

### No further user input requested
Subsequent rounds proceeded automatically with sufficient context.
```

---

## Preventing Repeated Questions

### Semantic Matching

**Problem:** Asking same thing in different words.

**Solution:** Semantic topic matching

```python
def are_questions_similar(q1: str, q2: str) -> bool:
    """Check if two questions ask about the same thing"""

    # Extract topic keywords
    topics_q1 = extract_topics(q1)
    topics_q2 = extract_topics(q2)

    # Calculate overlap
    overlap = len(topics_q1.intersection(topics_q2))
    total = len(topics_q1.union(topics_q2))

    similarity = overlap / total if total > 0 else 0

    return similarity > 0.6  # 60% similarity threshold
```

**Example:**
```python
q1 = "Do you need cached data to survive server restarts?"
q2 = "Should cache persist across reboots?"

are_questions_similar(q1, q2)  # → True (same topic)
# Don't ask q2 if we already asked q1
```

---

### Time-Based Expiry

**Rule:** If asked >2 rounds ago and context changed significantly, may re-ask.

```python
def can_reask(question_hash: str, current_round: int) -> bool:
    """Check if enough rounds passed to re-ask"""

    original_round = session.question_rounds[question_hash]
    rounds_since = current_round - original_round

    # Re-ask if:
    # - 3+ rounds passed AND
    # - Context changed significantly (e.g., different approach now)
    if rounds_since >= 3 and context_changed_significantly():
        return True

    return False
```

---

## User Response Types

### Type 1: Direct Answer

```markdown
User: "Option 2 - No, ephemeral cache is fine"

Action: Record answer, continue debate
Log: {"answer": "ephemeral_ok", "confidence": "high"}
```

### Type 2: Answer + Context

```markdown
User: "Option 1 - Yes, persistence required
       Context: We store user sessions that must survive restarts"

Action: Record answer AND additional context
Log: {
  "answer": "persistence_required",
  "context": "user_sessions_must_survive",
  "confidence": "high"
}
```

### Type 3: Skip

```markdown
User: "Skip"

Action: Use default assumption, note lower confidence
Log: {
  "answer": "skipped",
  "assumption": "will_use_redis_for_safety",
  "confidence": "medium"
}
```

### Type 4: Provide Different Context

```markdown
User: "Actually, we can't use Redis - it's not approved by our IT dept"

Action: Record as NEW CONSTRAINT, adjust approach
Log: {
  "answer": "constraint_change",
  "constraint": "redis_not_approved",
  "impact": "must_use_memcached_or_alternative",
  "re_evaluate": true
}
```

---

## Integration with Pre-Clarification

### Avoid Redundancy

**Check:** Does pre-clarification already cover this?

```python
def is_covered_by_preclarification(question: str) -> bool:
    """Check if pre-clarification answered this"""

    preclarification_topics = session.preclarification_answers.keys()

    question_topic = extract_topic(question)

    return question_topic in preclarification_topics
```

**Example:**
```python
# Pre-clarification asked:
# "What's your tech stack?"
# Answer: "Django 4.2, PostgreSQL 14, Redis"

# Mid-debate considers asking:
# "Do you have Redis available?"

if is_covered_by_preclarification("redis availability"):
    # Already answered in pre-clarification
    skip_question = True
    use_preclarification_answer("redis available")
```

---

## State Management

### Session State

```python
class DebateSessionState:
    def __init__(self):
        # Pre-debate
        self.preclarification_answers = {}

        # During debate
        self.current_round = 1
        self.user_inputs = []
        self.asked_questions = set()
        self.last_question_time = None

        # Constraints discovered
        self.initial_constraints = []
        self.discovered_constraints = []

        # Preferences learned
        self.user_preferences = {
            'performance_vs_maintainability': None,
            'cost_sensitive': None,
            'timeline': None,
            # ... etc
        }

    def add_user_input(self, round_num, question, answer, context=None):
        """Add user input to session state"""
        self.user_inputs.append({
            'round': round_num,
            'question': question,
            'answer': answer,
            'context': context,
            'timestamp': datetime.now()
        })

        # Update preferences if applicable
        self._extract_preferences(question, answer)

        # Mark question as asked
        self.asked_questions.add(self._hash_question(question))

        self.last_question_time = datetime.now()

    def get_user_input_summary(self) -> str:
        """Generate summary of all user inputs for report"""
        if not self.user_inputs:
            return "No user input requested during debate."

        summary = "## User Input During Debate\n\n"
        for inp in self.user_inputs:
            summary += f"### Round {inp['round']}\n"
            summary += f"**Q:** {inp['question']}\n"
            summary += f"**A:** {inp['answer']}\n"
            if inp.get('context'):
                summary += f"**Context:** {inp['context']}\n"
            summary += "\n"

        return summary
```

---

## Example: Full Integration Flow

### Debate Session Example

```markdown
## Debate Start (Round 1)

Claude: Analyzing problem... suggests eager loading
Codex: Analyzing problem... suggests lazy + caching

## Round 1 Complete

Heuristic evaluation:
- Condition: Preference Fork (performance vs flexibility)
- Confidence: Claude 55%, Codex 60% (both medium)
- Decision: ASK USER

## User Prompt (Round 1 → 2)

🤔 Mid-Debate User Input Required

**Question:** What's your highest priority?

**Options:**
1. Performance (faster, simpler)
2. Flexibility (more complex setup)

User: "Option 1 - Performance"

## Logging

```python
session.add_user_input(
    round_num=1,
    question="performance vs flexibility priority",
    answer="performance",
    context=None
)

# Update state
session.user_preferences['performance_vs_maintainability'] = 'performance'
```

## Round 2 Start

**Inject to Codex:**
```
User clarified (Round 1): Performance is the priority.

Given this, re-evaluate lazy+caching vs eager loading...
```

**Claude's reasoning:**
```
📝 User wants performance → Eager loading is correct.
   Proceeding with this approach...
```

## Round 2-5

Continue debate with user preference applied.
No further questions needed (confidence high, converging).

## Final Report

### User Input Summary
Round 1: User prioritized performance over flexibility.
Impact: This guided us toward eager loading approach.

### Solution
[Final solution incorporating user's performance priority]
```

---

## Quality Metrics

### Track Effectiveness

**After debate, log:**

```json
{
  "mid_debate_effectiveness": {
    "questions_asked": 1,
    "questions_answered": 1,
    "questions_skipped": 0,
    "confidence_before": 0.55,
    "confidence_after": 0.85,
    "user_satisfaction": "assumed_high",  // or actual feedback
    "solution_aligned_with_input": true
  }
}
```

**Use for:**
- Calibrating heuristics (asking too much/little?)
- Improving question quality
- Measuring impact on confidence
- Continuous improvement

---

## Best Practices

### DO ✅

1. **Always log user input immediately**
2. **Reference user input in subsequent rounds**
3. **Check asked_questions before prompting**
4. **Include in final report for transparency**
5. **Extract preferences for future use**

### DON'T ❌

1. **Don't lose user input** (always persist)
2. **Don't re-ask same question** (check history)
3. **Don't ignore user context** (additional notes matter)
4. **Don't forget to inject into next round**
5. **Don't make assumptions contradicting user input**

---

**Version:** 1.0
**Last Updated:** 2025-10-31
**Integration Points:** 5 core + quality metrics
