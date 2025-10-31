# AI Facilitator Escalation Prompts

These prompts are used when the rule-based monitor flags issues that require nuanced interpretation.

---

## Circular Reasoning Detected

```
FACILITATOR ALERT: Circular Reasoning

Pattern detected: {agent_name} has made similar arguments in rounds {round_numbers}.

Previous argument (Round {n}):
"{previous_argument}"

Current argument (Round {n+2}):
"{current_argument}"

Semantic similarity: {similarity_score}%

ACTION REQUIRED:
The debate appears to be looping without new evidence or perspectives.

Options:
1. Pivot to unexplored aspect: {suggested_alternatives}
2. Request new evidence to support the repeated claim
3. Acknowledge this is a fundamental assumption and move forward
4. Escalate to user for input

What should we do?
```

---

## Premature Convergence

```
FACILITATOR ALERT: Premature Convergence

Consensus reached in round {round_number}, but minimum exploration threshold not met.

Converged on: "{consensus_summary}"

Alternatives discussed: {alternatives_count} (minimum recommended: 2)
Rounds of exploration: {rounds} (minimum recommended: 2)

CONCERN:
Quick consensus might indicate:
- Obvious solution (good)
- Groupthink without exploration (bad)
- Missing perspectives

ACTION REQUIRED:
Before finalizing, consider:

Unexplored alternatives:
1. {alternative_1}
2. {alternative_2}
3. {alternative_3}

Unexplored dimensions:
- {uncovered_dimensions}

Should we:
A) Explore these alternatives (1-2 more rounds)
B) Proceed with consensus (document why alternatives rejected)
C) Escalate to user

Recommendation: {a|b|c}
```

---

## Coverage Gap Detected

```
FACILITATOR ALERT: Coverage Gap

Round {round_number} completed. Coverage assessment:

Addressed dimensions:
✅ {covered_dimension_1}
✅ {covered_dimension_2}
✅ {covered_dimension_3}

Missing dimensions:
❌ {missing_dimension_1} - {why_important}
❌ {missing_dimension_2} - {why_important}

Coverage score: {score}/8 ({percentage}%)
Minimum required: 5/8 (62.5%)

ACTION REQUIRED:
The following critical dimensions have not been addressed:

{missing_critical_dimensions}

Prompts to address gaps:

For {dimension_1}:
"{sample_question_1}"

For {dimension_2}:
"{sample_question_2}"

Should facilitator:
A) Prompt agents to address these dimensions
B) Mark dimensions as N/A (with justification)
C) Escalate to user

Recommendation: {a|b|c}
```

---

## Scope Drift

```
FACILITATOR ALERT: Scope Drift

Original problem:
"{original_problem_statement}"

Current discussion topic (Round {round_number}):
"{current_topic}"

Topic similarity to original: {similarity_score}% (threshold: 30%)

CONCERN:
Discussion has drifted from the original problem. This could be:
- Valuable tangent discovering root cause (good)
- Distraction from actual problem (bad)

ACTION REQUIRED:
Evaluate drift:

Is current topic:
- A root cause of original problem? Y/N
- A prerequisite to solving original problem? Y/N
- A valuable related consideration? Y/N
- An unrelated tangent? Y/N

Recommendation:
{recommendation_text}

Options:
A) Refocus on original problem
B) Acknowledge topic change, update problem statement
C) Split into two separate discussions

Recommendation: {a|b|c}
```

---

## Dominance Detected

```
FACILITATOR ALERT: Dominance Pattern

Round {round_number} analysis:

{agent_1} agreement rate: {percentage_1}%
{agent_2} agreement rate: {percentage_2}%

Imbalance: {agent_2} agreeing with {agent_1} at {imbalance_percentage}% over last {window} rounds.

CONCERN:
One perspective may be dominating without sufficient challenge. Healthy debate requires:
- Critical evaluation of all proposals
- Alternative perspectives explored
- Assumptions questioned

ACTION REQUIRED:
Prompt to {underdog_agent}:

"{underdog_agent}, you've agreed with most of {dominant_agent}'s points in the last {window} rounds. Before we finalize, consider:

1. Are there any potential issues or edge cases we're missing?
2. What could go wrong with this approach?
3. Are there alternative approaches we haven't fully explored?
4. What assumptions are we making that might be wrong?

It's OK to agree if you genuinely think the approach is sound, but ensure we've done due diligence."
```

---

## Information Starvation (Pre-Abort)

```
FACILITATOR ALERT: Information Starvation

Round {round_number} analysis:

Assumptions detected: {assumption_count}
Hedging language frequency: {hedging_count}
Assumption:fact ratio: {ratio} (threshold: 2.0)

Key assumptions being made:
1. {assumption_1}
2. {assumption_2}
3. {assumption_3}

CONCERN:
Agents are making too many guesses. This indicates insufficient information to make a quality recommendation.

Missing information that blocks risk evaluation:
1. {missing_fact_1} - needed for {reason_1}
2. {missing_fact_2} - needed for {reason_2}

ACTION REQUIRED:
Prepare to ABORT and query user.

Before aborting, attempt fallback chain:
1. Can we derive from first principles? {yes|no}
2. Can we run quick experiment? {yes|no}
3. Can assumptions be made explicit with confidence penalty? {yes|no}

If all NO:
ABORT with prompt:

"Debate paused due to insufficient information.

We need clarification on:
{specific_questions_list}

Without this information, we can only provide a recommendation with {low_confidence}% confidence, based primarily on assumptions.

Please provide the requested information, OR acknowledge that the decision must be made under high uncertainty."
```

---

## High-Friction Pattern

```
FACILITATOR ALERT: High-Friction Pattern

Pattern: {pattern_type}

Details:
{pattern_details}

Examples:
{examples}

CONCERN:
This pattern suggests:
- Emotional/policy considerations (requires human judgment)
- Fundamental disagreement on priorities
- Deep technical complexity
- Incomplete problem framing

ACTION REQUIRED:
IMMEDIATE ESCALATION TO USER

Escalation prompt:

"The debate has encountered {pattern_type}.

Summary:
{summary_of_disagreement}

This appears to involve {human_judgment_aspect} that requires your input.

Claude's position: {claude_summary}
Codex's position: {codex_summary}

Question for you:
{specific_question_for_user}

How would you like to proceed?"
```

---

## Mode Misclassification

```
FACILITATOR ALERT: Mode Misclassification

Detected mode: {detected_mode}
Current mode: {current_mode}
Confidence in detection: {confidence}%

Analysis:
{analysis_text}

Indicators of {detected_mode}:
- {indicator_1}
- {indicator_2}
- {indicator_3}

ACTION REQUIRED:
Mode mismatch may lead to suboptimal debate structure.

Recommendation: Switch to {detected_mode}

Impact of switch:
- Rounds: {current_rounds} → {new_rounds}
- Claude weighting: {current_claude} → {new_claude}
- Codex weighting: {current_codex} → {new_codex}

Options:
A) Auto-switch to {detected_mode}
B) Continue with {current_mode}
C) Ask user for confirmation

Recommendation: {a|b|c}
```

---

## Facilitator Intervention Limit

```
FACILITATOR ALERT: Intervention Limit Approaching

Current interventions: {count}/5 (limit: 5 per debate)

Interventions so far:
1. Round {n}: {intervention_type_1}
2. Round {n}: {intervention_type_2}
...

CONCERN:
High intervention frequency suggests:
- Poorly framed problem
- Mismatched mode
- Agents struggling with complexity
- Insufficient information

ACTION REQUIRED:
After next intervention, escalate to user:

"The facilitator has intervened {count} times in this debate, indicating potential issues:

{diagnosed_issues}

Options:
A) Continue with facilitator assistance (may exceed intervention limit)
B) Pause to reframe problem
C) Gather more information before resuming
D) Accept current best-effort recommendation with caveats

What would you prefer?"
```

---

## Facilitator Prompts Ignored

```
FACILITATOR ALERT: Prompts Ignored

Prompts issued: {count}
Prompts addressed: {addressed_count}
Ignored prompts: {ignored_count}

Ignored prompt details:
1. Round {n}: "{prompt_1}" - Status: Ignored
2. Round {n}: "{prompt_2}" - Status: Ignored

CONCERN:
Agents not responding to facilitator guidance suggests:
- Prompts not relevant (facilitator error)
- Agents focused on different priority
- Complexity beyond facilitator's model

ACTION REQUIRED:
If ≥2 prompts ignored:
ESCALATE TO USER with handoff:

"The facilitator has issued guidance that hasn't been addressed:

{ignored_prompts_summary}

This suggests either:
1. Facilitator guidance is off-base (you can override)
2. Agents are prioritizing differently (may be valid)
3. Problem complexity exceeds facilitator model

Transferring control to you. How should we proceed?"
```

---

## Usage

These prompts are templates. The facilitator fills in `{placeholders}` with actual data from the debate context.

**AI Facilitator Model:** Should be lightweight (e.g., Claude Haiku, GPT-4o mini) to minimize latency and cost.

**Escalation Priority:**
1. **High-friction patterns** → Immediate user escalation
2. **Information starvation** → Immediate abort
3. **Other patterns** → AI facilitator interpretation first
4. **AI facilitator limits** → User escalation

**Logging:** All facilitator interventions are logged to structured debate log for playbook generation and heuristic tuning.
