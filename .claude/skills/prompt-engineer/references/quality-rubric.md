# Prompt Quality Rubric

Systematic checklist for evaluating prompt quality based on official OpenAI and Google Gemini guidelines.

## Scoring System

**Scale: 0-10 for each criterion**
- 10: Excellent - fully addresses criterion
- 7-9: Good - mostly addresses with minor gaps
- 4-6: Acceptable - partially addresses, needs improvement
- 1-3: Poor - barely addresses criterion
- 0: Missing - criterion not addressed

**Overall Score Interpretation:**
- 9.0-10.0: Excellent prompt, ready to use
- 7.0-8.9: Good prompt, minor refinements recommended
- 5.0-6.9: Acceptable, significant improvements needed
- Below 5.0: Poor, major revision required

## Essential Criteria (Must Have)

### 1. Clear Objective (10 points)

**What to check:**
- [ ] Task is explicitly stated
- [ ] Objective is specific and unambiguous
- [ ] Success criteria are clear

**Examples:**

❌ Poor (Score: 2/10):
```
"Help me with Python"
```

✅ Excellent (Score: 10/10):
```
"Write a Python function that validates email addresses using regex,
returns True for valid emails and False for invalid ones"
```

**Scoring Guide:**
- 10: Task, purpose, and success criteria crystal clear
- 7: Task clear, minor ambiguity in expected outcome
- 4: Task somewhat clear, significant ambiguity
- 0: Task is vague or missing

---

### 2. Sufficient Context (10 points)

**What to check:**
- [ ] Background information provided
- [ ] Input format/structure specified
- [ ] Constraints and requirements stated
- [ ] Environment/platform mentioned (if relevant)

**Examples:**

❌ Poor (Score: 2/10):
```
"Parse this data"
```

✅ Excellent (Score: 10/10):
```
"Parse CSV data with columns: id, name, email, status.
Input: text/csv format with headers
Output: List of dictionaries
Constraint: Handle missing values gracefully"
```

**Scoring Guide:**
- 10: Complete context, nothing assumed
- 7: Most context provided, minor details missing
- 4: Partial context, significant gaps
- 0: No context provided

---

### 3. Output Format Specified (10 points)

**What to check:**
- [ ] Structure of output is clear
- [ ] Format is explicitly stated (JSON, markdown, code, etc.)
- [ ] Examples of output shown (if applicable)

**Examples:**

❌ Poor (Score: 2/10):
```
"Analyze this code"
```

✅ Excellent (Score: 10/10):
```
"Analyze this code and provide:
1. List of issues (bullet points)
2. Severity rating (high/medium/low)
3. Suggested fixes (code snippets)
4. Updated implementation

Format as markdown with clear sections."
```

**Scoring Guide:**
- 10: Output format completely specified with structure
- 7: Format specified, minor structural details missing
- 4: Format mentioned but structure unclear
- 0: No format specification

---

## Recommended Criteria (Should Have)

### 4. Examples Included (10 points)

**What to check:**
- [ ] Input examples provided
- [ ] Output examples provided
- [ ] Edge case examples (if applicable)

**Official Guidance:**
- **Gemini:** "We recommend to always include few-shot examples in your prompts."
- **OpenAI:** "Provide examples" (Strategy #1: Write clear instructions)

**Examples:**

❌ Poor (Score: 2/10):
```
"Convert dates to ISO format"
```

✅ Excellent (Score: 10/10):
```
"Convert dates to ISO format.

Examples:
Input: "Jan 15, 2025" → Output: "2025-01-15"
Input: "03/20/2025" → Output: "2025-03-20"
Input: "15.04.2025" → Output: "2025-04-15"
```

**Scoring Guide:**
- 10: Multiple examples with input/output pairs
- 7: At least one example provided
- 4: Example mentioned but incomplete
- 0: No examples

---

### 5. Role/Persona Defined (10 points)

**What to check:**
- [ ] Clear persona stated (expert developer, analyst, etc.)
- [ ] Expertise level specified
- [ ] Perspective defined (reviewer, implementer, etc.)

**Official Guidance:**
- **Gemini:** "Persona (who the AI should be)" - one of 4 core elements

**Examples:**

❌ Poor (Score: 2/10):
```
"Review this code"
```

✅ Excellent (Score: 10/10):
```
"You are a senior Python developer with 10+ years experience
in backend systems. Review this code for performance issues,
focusing on database query optimization."
```

**Scoring Guide:**
- 10: Clear role with relevant expertise
- 7: Role defined, expertise implied
- 4: Vague role mentioned
- 0: No role specified

---

### 6. Model-Appropriate Task (10 points)

**What to check:**
- [ ] Task suits model's capabilities
- [ ] Context size within limits
- [ ] Complexity matches model capacity
- [ ] Provider-specific features utilized (if applicable)

**Model Constraints:**

| Model | Context Limit | Best For |
|-------|---------------|----------|
| GPT-4 Turbo | 128k tokens | Long context, complex reasoning |
| GPT-4 | 8k/32k tokens | General tasks, high quality |
| GPT-3.5 Turbo | 16k tokens | Simple tasks, fast responses |
| Gemini Pro | 32k tokens | Multimodal, workspace integration |
| Gemini Ultra | 1M tokens | Very long context |

**Scoring Guide:**
- 10: Task perfectly suited to model
- 7: Task appropriate, not fully optimized
- 4: Task somewhat suitable, potential issues
- 0: Task inappropriate for model

---

## Advanced Criteria (Nice to Have)

### 7. Thinking/Reasoning Prompted (10 points)

**What to check:**
- [ ] "Think step by step" or similar included
- [ ] Asks model to explain reasoning
- [ ] Prompts for planning before execution

**Official Guidance:**
- **OpenAI Strategy #4:** "Give GPTs time to think"
- **GPT-4.1:** "Prompt explicit step-by-step reasoning"

**Examples:**

❌ Basic (Score: 5/10):
```
"Write a function to sort users"
```

✅ Excellent (Score: 10/10):
```
"Write a function to sort users.

Before implementing:
1. What sorting criteria should we consider?
2. What edge cases need handling?
3. What's the most efficient algorithm?

Then provide your implementation."
```

**Scoring Guide:**
- 10: Explicit thinking prompts with structure
- 7: Basic "think step by step" included
- 4: Implicit thinking required, not prompted
- 0: No reasoning prompt

---

### 8. Constraints Specified (10 points)

**What to check:**
- [ ] Time/length constraints stated
- [ ] Style/tone requirements
- [ ] Technical constraints (language version, libraries, etc.)
- [ ] What NOT to do (if applicable)

**Examples:**

✅ Excellent (Score: 10/10):
```
"Requirements:
- Python 3.10+ only
- No external libraries (stdlib only)
- Maximum 50 lines
- PEP 8 compliant
- Do not use deprecated functions"
```

**Scoring Guide:**
- 10: Comprehensive constraints clearly stated
- 7: Key constraints mentioned
- 4: Some constraints implied
- 0: No constraints specified

---

### 9. Success Criteria Defined (10 points)

**What to check:**
- [ ] How to evaluate output
- [ ] What makes a good response
- [ ] Testing requirements (if code)

**Examples:**

✅ Excellent (Score: 10/10):
```
"Success criteria:
- Function passes all provided test cases
- Handles edge cases without errors
- Performance: O(n log n) or better
- Code readability score: 8/10+"
```

**Scoring Guide:**
- 10: Clear, measurable success criteria
- 7: Basic success indicators provided
- 4: Implicit criteria only
- 0: No success criteria

---

## Quick Checklist

Use this for rapid assessment:

```
Essential (Must Have):
[ ] Clear objective (what to do)
[ ] Sufficient context (background, inputs, constraints)
[ ] Output format specified (structure, format)

Recommended (Should Have):
[ ] Examples included (input/output samples)
[ ] Role/persona defined (who AI should be)
[ ] Model-appropriate (within capabilities)

Advanced (Nice to Have):
[ ] Thinking prompted (step-by-step reasoning)
[ ] Constraints specified (requirements, limits)
[ ] Success criteria (how to evaluate)
```

## Scoring Template

```markdown
| Criterion | Score | Notes |
|-----------|-------|-------|
| Clear objective | X/10 | [reason] |
| Sufficient context | X/10 | [reason] |
| Output format specified | X/10 | [reason] |
| Examples included | X/10 | [reason] |
| Role/persona defined | X/10 | [reason] |
| Model-appropriate | X/10 | [reason] |
| Thinking prompted | X/10 | [reason] |
| Constraints specified | X/10 | [reason] |
| Success criteria | X/10 | [reason] |

**Total Score: X.X/10**

**Assessment:** [Excellent / Good / Acceptable / Poor]

**Recommendations:**
- [Improvement 1]
- [Improvement 2]
- [Improvement 3]
```

## Provider-Specific Adjustments

### OpenAI (GPT Models)

Additional checks:
- [ ] Reference text provided (if knowledge required)
- [ ] Complex tasks decomposed into subtasks
- [ ] Temperature appropriate for task type (0 for factual)
- [ ] For GPT-4.1: Instructions at both beginning and end (long context)

### Google Gemini

Additional checks:
- [ ] Four elements present (Persona, Task, Context, Format)
- [ ] Few-shot examples included (official recommendation)
- [ ] Prefixes used for structure (Input:, Output:, JSON:)
- [ ] Multimodal inputs structured properly (if applicable)

## Common Issues

### Issue: Prompt scores high but results are poor

**Possible causes:**
1. Task is beyond model capabilities
2. Context is too long (exceeds effective attention)
3. Temperature setting inappropriate
4. Conflicting instructions

**Solution:** Review model selection and simplify task.

### Issue: Prompt scores low but results are acceptable

**Possible cause:**
- Simple task doesn't require elaborate prompting
- Model has strong priors for this task type

**Action:** Consider if elaborate prompting is necessary.

### Issue: Inconsistent results across runs

**Causes:**
- Temperature too high for factual tasks
- Insufficient constraints
- Missing examples
- Ambiguous instructions

**Solution:** Lower temperature, add examples, clarify instructions.

## References

**Official Guidelines:**
- OpenAI: platform.openai.com/docs/guides/prompt-engineering
- Gemini: ai.google.dev/gemini-api/docs/prompting-strategies
- GPT-4.1: cookbook.openai.com/examples/gpt4-1_prompting_guide

**This rubric is based on official documentation from OpenAI and Google (2025).**
