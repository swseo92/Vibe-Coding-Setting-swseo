# Universal Prompt Engineering Principles

A unified framework synthesizing official best practices from **OpenAI, Google Gemini, and Anthropic** that work across **all AI providers**.

**Key Insight:** 90%+ of prompting best practices are **provider-agnostic**. The core principles work universally for ChatGPT, Gemini, Claude, and other LLMs.

---

## The Universal Framework

### Core Insight

All three major AI providers emphasize the same fundamental principles, just structured differently:

**OpenAI's 6 Strategies ↔ Gemini's 4 Elements ↔ Anthropic's 9 Techniques**

The remarkable overlap reveals **universal truths** about effective prompting:

```
OpenAI Strategy #1 (Clear Instructions) ≈ Gemini Task ≈ Anthropic "Be Clear & Direct"
OpenAI Tactic (Adopt persona) ≈ Gemini Persona ≈ Anthropic "System Prompts"
OpenAI Strategy #2 (Reference text) ≈ Gemini Context ≈ Anthropic (implicit)
OpenAI Tactic (Specify format) ≈ Gemini Format ≈ Anthropic "XML Tags + Prefilling"
OpenAI Tactic (Provide examples) ≈ Gemini Few-shot ≈ Anthropic "Multishot Prompting"
OpenAI Strategy #3 (Split tasks) ≈ Gemini (implied) ≈ Anthropic "Prompt Chaining"
OpenAI Strategy #4 (Time to think) ≈ Gemini (supported) ≈ Anthropic "Chain of Thought"

Result: Three major AI labs independently reached the same conclusions
```

---

## The 7 Universal Principles

### 1. Role Clarity (WHO)

**Define who the AI should be**

**OpenAI phrasing:**
> "Ask model to adopt a persona"

**Gemini phrasing:**
> "Persona (who the AI should be)"

**Anthropic phrasing:**
> "Give Claude a Role (System Prompts)" - assign context and perspective

**Universal principle:**
Clear role definition improves response quality across ALL models.

**Example (works everywhere):**
```markdown
You are a senior Python developer with 10+ years experience in backend systems.
```

**Why it's universal:**
- All LLMs are trained on diverse text
- Role priming activates relevant knowledge
- Works on GPT, Gemini, Claude, Llama, etc.

---

### 2. Task Specificity (WHAT)

**Be explicit about what you want**

**OpenAI phrasing:**
> "Include details in your query to get more relevant answers"

**Gemini phrasing:**
> "Task (what you want the model to do) - be specific and actionable"

**Anthropic phrasing:**
> "Be Clear and Direct" - use explicit, straightforward language

**Universal principle:**
Vague requests = vague responses (all models)

**Example (works everywhere):**
```markdown
❌ "Write a function"
✅ "Write a Python function that validates email addresses using regex,
   returns True/False, handles edge cases"
```

**Why it's universal:**
- Fundamental to how LLMs process instructions
- Specificity reduces ambiguity space
- Not model-specific behavior

---

### 3. Context Provision (BACKGROUND)

**Provide necessary information**

**OpenAI phrasing:**
> "Provide reference text" (Strategy #2)

**Gemini phrasing:**
> "Context (background information)"

**Anthropic phrasing:**
> Context is implicit but emphasized through structured prompts

**Universal principle:**
Models don't have access to your specific context - you must provide it.

**Example (works everywhere):**
```markdown
CONTEXT:
- Input: CSV with columns [id, name, email, status]
- System: Python 3.10, pandas available
- Constraint: Files up to 10MB
- Known issue: Inconsistent date formats
```

**Why it's universal:**
- All models have knowledge cutoffs
- None have access to your specific data
- Grounding is universally necessary

---

### 4. Examples (SHOW, DON'T JUST TELL)

**Demonstrate desired output**

**OpenAI phrasing:**
> "Provide examples" (Tactic under Strategy #1)

**Gemini phrasing:**
> "We recommend to **always** include few-shot examples" (official emphasis)

**Anthropic phrasing:**
> "Multishot Prompting" - provide multiple input-output examples showing desired patterns

**Universal principle:**
Examples are the most powerful way to specify format and style.

**Example (works everywhere):**
```markdown
Extract person info to JSON.

Example 1:
Input: "John Smith, john@example.com, 30 years old"
Output: {"name": "John Smith", "email": "john@example.com", "age": 30}

Example 2:
Input: "Contact Mary (mary@corp.com), age 25"
Output: {"name": "Mary", "email": "mary@corp.com", "age": 25}
```

**Why it's universal:**
- All LLMs are trained with in-context learning
- Examples work across GPT, Gemini, Claude, etc.
- More effective than descriptions alone

**Advanced Technique: Negative Examples**
```markdown
Example 1 (BAD - AVOID THIS):
Input: "notanemail"
Output: Error

Example 1 (GOOD - DO THIS):
Input: "user@example.com"
Output: Valid
```

**When to use:**
- Code review (show vulnerabilities)
- Error detection (show rejection patterns)
- Security audits (show insecure code)

**Critical rules:**
- Always label clearly ("BAD", "INSECURE", "AVOID")
- Always pair with correct alternative
- Explain WHY it's wrong

See `anti-patterns.md` for detailed guidance.

---

### 5. Output Format (STRUCTURE)

**Specify how output should be structured**

**OpenAI phrasing:**
> "Specify the desired length" (Tactic)
> "Use delimiters to clearly indicate distinct parts"

**Gemini phrasing:**
> "Format (output structure)" - one of 4 core elements
> "Use prefixes (Input:, Output:, JSON:)"

**Anthropic phrasing:**
> "Use XML Tags" - structure information with semantic markup
> "Prefill Claude's Response" - guide output format by starting it

**Universal principle:**
Explicit format specification = consistent output structure.

**Example (works everywhere):**
```markdown
FORMAT YOUR RESPONSE AS:

## Analysis
- Finding 1
- Finding 2

## Recommendations
1. Specific recommendation
2. Specific recommendation

## Implementation
```python
# Code here
```
```

**Why it's universal:**
- All models can follow structural instructions
- Markdown, JSON, XML work across providers
- Not dependent on specific model architecture

---

### 6. Decomposition (BREAK IT DOWN)

**Split complex tasks into simpler subtasks**

**OpenAI phrasing:**
> "Split complex tasks into simpler subtasks" (Strategy #3)
> "Complex tasks have higher error rates"

**Gemini phrasing:**
> "Breaking down complexity" - decompose into single-purpose prompts
> "Chain sequential prompts"

**Anthropic phrasing:**
> "Chain Complex Prompts" - break sophisticated tasks into sequential prompts

**Universal principle:**
Complexity increases errors universally - simplify through decomposition.

**Example (works everywhere):**
```markdown
Instead of: "Build complete REST API"

Break down:
Step 1: "Design data models"
Step 2: "Implement authentication"
Step 3: "Create CRUD endpoints for User model"
Step 4: "Add validation logic"
```

**Why it's universal:**
- Fundamental cognitive science principle
- Reduces error propagation
- Works for all reasoning systems

---

### 7. Reasoning Prompt (THINK FIRST)

**Give the model time to think**

**OpenAI phrasing:**
> "Instruct the model to work out solution before concluding" (Strategy #4)
> "Use inner monologue or chain of queries"

**Gemini phrasing:**
> Less explicit, but supported through task structure
> Thinking can be embedded in format

**Anthropic phrasing:**
> "Let Claude Think (Chain of Thought)" - request step-by-step reasoning explicitly
> "Thinking through the problem improves accuracy on complex tasks"

**Universal principle:**
Prompting for step-by-step reasoning improves quality.

**Example (works everywhere):**
```markdown
Before implementing, think through:
1. What edge cases need handling?
2. What's the most efficient approach?
3. What errors could occur?

Then provide your implementation.
```

**Why it's universal:**
- Chain-of-thought (CoT) is proven technique
- Works across GPT, Gemini, Claude, PaLM
- Research-backed for multiple model families

---

## The Universal Template

This template works for **any AI provider:**

```markdown
# ROLE (Who)
You are {specific role with relevant expertise}.

# TASK (What)
{Clear, specific, actionable task description}

# CONTEXT (Background)
- Input: {format and structure}
- Requirements: {must-haves}
- Constraints: {limitations}
- Environment: {relevant technical details}

# EXAMPLES (Show)
Example 1:
Input: {sample}
Output: {expected result}

Example 2:
Input: {sample}
Output: {expected result}

# FORMAT (Structure)
Provide response structured as:

{Explicit output format specification}

# REASONING (Think)
Before responding:
1. {Analytical step}
2. {Analytical step}

Then provide your answer.
```

**This template achieves:**
- ✅ OpenAI Strategy #1, #2, #3, #4 compliance
- ✅ Gemini 4-element framework compliance
- ✅ Anthropic 9-technique coverage (clear, examples, CoT, structure, role, chaining)
- ✅ Works on Claude, GPT, Gemini, Llama, etc.

---

## Provider-Agnostic vs Provider-Specific

### Universal (90%+)

These work **identically** across all providers:

✅ Role/persona definition
✅ Task clarity and specificity
✅ Context provision
✅ Few-shot examples
✅ Output format specification
✅ Task decomposition
✅ Chain-of-thought reasoning
✅ Explicit constraints
✅ Delimiters for structure (markdown, XML, JSON)

### Provider-Specific (< 10%)

Only these require provider customization:

**OpenAI-specific:**
- Function calling API syntax
- GPT-4.1 long context END placement
- Specific tool integration format

**Gemini-specific:**
- Top-K and Top-P parameters (unique to Google)
- Native multimodal syntax
- Workspace-specific formatting

**Claude-specific:**
- XML tag preferences (strong preference for semantic markup)
- Response prefilling (unique to Claude API)
- Constitutional AI interactions
- Extended thinking tokens
- Long context optimization (specialized tips for extended documents)

---

## Temperature (Universal Guideline)

**Remarkable alignment across all three providers:**

| Task Type | OpenAI Official | Gemini Pattern | Anthropic | Universal Rec |
|-----------|----------------|----------------|-----------|---------------|
| **Factual/Code** | 0 | 0 | Low | **0** |
| **Data extraction** | 0 | 0 | Low | **0** |
| **Analysis** | - | - | Medium | **0.3-0.5** |
| **Creative** | - | Higher | Higher | **0.7-0.9** |

**Official OpenAI quote:**
> "For factual use cases such as data extraction and truthful Q&A, the temperature of 0 is best."

**Gemini documentation:**
> "Temperature 0 = deterministic"

**Anthropic guidance:**
> Lower temperature for deterministic tasks, higher for creative outputs

**Universal principle:**
- Temperature 0 for factual/deterministic tasks
- Higher temperature for creative/diverse outputs
- **This applies to ALL temperature-based models**

---

## Common Anti-Patterns (Universal)

These mistakes hurt quality **regardless of provider:**

❌ **Vague instructions**
```
"Help me with code" → Works poorly everywhere
```

❌ **No examples**
```
"Convert dates" → Ambiguous for all models
```

❌ **Missing context**
```
"Fix this" → Models don't know your context
```

❌ **No format specification**
```
"Analyze this" → Structure unclear for all models
```

❌ **Monolithic complex tasks**
```
"Build everything" → Error-prone universally
```

---

## The Synthesis: Best of All Three Worlds

Combining OpenAI, Gemini, and Anthropic creates the **strongest universal framework:**

### From OpenAI
- ✅ Systematic 6-strategy structure
- ✅ Emphasis on testing and iteration
- ✅ Tool integration philosophy
- ✅ Decomposition strategy

### From Gemini
- ✅ Simple 4-element mnemonic (PTCF)
- ✅ Strong emphasis on examples ("always include")
- ✅ Prefix pattern for clarity
- ✅ Multimodal guidance

### From Anthropic
- ✅ XML structuring for clarity
- ✅ Response prefilling technique
- ✅ Explicit Chain of Thought emphasis
- ✅ Long context optimization
- ✅ Prompt chaining for complex workflows

### Unified Result
A framework that:
- Works across all providers (90%+ overlap)
- Easier to remember (combines best of all three)
- More complete (complementary strengths)
- Research-backed (three major AI labs independently converging)

---

## Practical Application: Universal Prompting

### Example: Code Generation

**Universal approach (works on GPT, Gemini, Claude):**

```markdown
# ROLE
You are an expert Python developer.

# TASK
Write a function that validates email addresses using regex.

# CONTEXT
- Return: True for valid, False for invalid
- Handle: empty strings, None, malformed emails
- Style: PEP 8 compliant

# EXAMPLES
Example 1:
Input: "user@example.com"
Output: True

Example 2:
Input: "invalid.email"
Output: False

Example 3:
Input: ""
Output: False

# FORMAT
Provide:
1. Function with type hints and docstring
2. Usage example
3. Test cases

# REASONING
Consider edge cases before implementing.

# IMPLEMENTATION
[Your code here]
```

**Result quality:**
- OpenAI GPT-4: Excellent
- Google Gemini: Excellent
- Claude: Excellent
- **Why:** Uses universal principles only

---

### Example: Data Extraction

**Universal approach:**

```markdown
# ROLE
Data extraction specialist

# TASK
Extract name, email, age from text to JSON

# CONTEXT
- Input: Natural language (varied formats)
- Missing fields: use null
- Output: Valid JSON only

# EXAMPLES
Example 1:
Text: "John Smith, john@example.com, 30"
JSON: {"name": "John Smith", "email": "john@example.com", "age": 30}

Example 2:
Text: "Mary (mary@corp.com), 25 years old"
JSON: {"name": "Mary", "email": "mary@corp.com", "age": 25}

Example 3:
Text: "Bob, no email, 35"
JSON: {"name": "Bob", "email": null, "age": 35}

# FORMAT
Output only valid JSON, no explanations.

# YOUR TASK
Text: {user input}
JSON:
```

**Works universally because:**
- Clear role (all models understand)
- Specific task (unambiguous)
- Rich examples (pattern is clear)
- Explicit format (JSON structure)
- No provider-specific features

---

## When to Use Provider-Specific Features

### Stick to Universal (Default)

Use universal principles when:
- ✅ Prompt needs to work across multiple AI tools
- ✅ Team uses different providers
- ✅ Experimenting/comparing providers
- ✅ Building portable prompts
- ✅ Teaching/learning (universal patterns)

### Use Provider-Specific (Advanced)

Only add provider-specific optimizations when:
- ⚠️ Locked into one provider
- ⚠️ Need absolute maximum performance
- ⚠️ Using unique features (multimodal, tools, etc.)
- ⚠️ Performance-critical production use

**Rule of thumb:**
Start universal → Optimize for provider only if needed.

---

## The 90/10 Rule

**90% of prompting success comes from:**
- Clear role definition ✅ Universal
- Specific task description ✅ Universal
- Sufficient context ✅ Universal
- Good examples ✅ Universal
- Format specification ✅ Universal
- Task decomposition ✅ Universal
- Reasoning prompts ✅ Universal

**10% of improvement comes from:**
- Provider-specific syntax
- Model-specific quirks
- Parameter tuning
- API-specific features

**Focus on the 90% first!**

---

## Convergence Evidence

### Why All Three Companies Agree

The remarkable convergence of OpenAI, Google, and Anthropic guidelines suggests:

1. **Empirical validation**
   - All three tested extensively with real users
   - Independent research teams found same patterns
   - Best practices are evidence-based, not theoretical

2. **Fundamental LLM properties**
   - All transformer-based models
   - Similar training approaches (self-supervised learning)
   - Common underlying mechanics (attention, context)

3. **User research**
   - All providers observe millions of real interactions
   - Successful patterns emerge consistently
   - Guidelines reflect what actually works in production

4. **Independent convergence**
   - Three separate companies reached same conclusions
   - No coordination between research teams
   - Validates universality of principles

**Conclusion:** Universal principles reflect **fundamental truths** about how LLMs work, not provider quirks or marketing preferences.

---

## Quick Reference: Universal Checklist

Use this for **any AI provider:**

```markdown
[ ] Clear role/persona defined
[ ] Task is specific and actionable
[ ] Sufficient context provided
[ ] 2-3+ examples included
[ ] Output format explicitly specified
[ ] Complex task decomposed into steps
[ ] Reasoning prompted (if needed)
[ ] Temperature appropriate (0 for factual)
[ ] Delimiters used for structure
[ ] Tested and iterated
```

**If all checked → High-quality prompt for ANY provider**

---

## The Bottom Line

### Universal Truth

> 90% of effective prompting is provider-agnostic.
> Master universal principles first, optimize for providers second.

### Practical Approach

1. **Start universal** - Use principles that work everywhere
2. **Test quality** - See if it meets requirements
3. **Add provider-specific** - Only if needed for 10% gain

### Future-Proof

Universal prompts are:
- ✅ Portable across providers
- ✅ Easier to maintain
- ✅ Better for collaboration
- ✅ Resilient to model updates
- ✅ Based on fundamental principles

---

## Resources

**Universal Principles Derived From:**
- **OpenAI:** platform.openai.com/docs/guides/prompt-engineering
- **Google Gemini:** ai.google.dev/gemini-api/docs/prompting-strategies
- **Anthropic Claude:** docs.claude.com/en/docs/build-with-claude/prompt-engineering/overview
- **Research:** Chain-of-Thought, Few-Shot Learning papers
- **Practice:** Real-world usage patterns across millions of users

**This Document:**
- Synthesizes official guidance from all three major providers
- Extracts universal principles (90%+)
- Provides provider-agnostic templates
- Focuses on what works everywhere
- Validates convergence through independent sources

---

**Version:** 2.0
**Created:** 2025-01-29
**Updated:** 2025-01-29 (Added Anthropic integration)
**Purpose:** Universal prompting framework for all AI providers
