# OpenAI-Specific Prompting Guide

Provider-specific optimizations, constraints, and best practices for OpenAI models (GPT-3.5, GPT-4, GPT-4 Turbo, GPT-4.1).

**Based on Official Documentation:**
- platform.openai.com/docs/guides/prompt-engineering (2025)
- cookbook.openai.com/examples/gpt4-1_prompting_guide (April 2025)
- help.openai.com/en/articles/6654000-best-practices-for-prompt-engineering

---

## Model Comparison

| Model | Context | Best For | Temperature Rec | Cost |
|-------|---------|----------|-----------------|------|
| **GPT-4.1** | 1M tokens | Agentic workflows, SWE tasks, long context | 0-0.2 code, 0.5-0.7 reasoning | Highest |
| **GPT-4 Turbo** | 128k tokens | Complex reasoning, long documents | 0 factual, 0.7 creative | High |
| **GPT-4** | 8k/32k | High-quality general tasks | 0 factual, 0.7 creative | High |
| **GPT-3.5 Turbo** | 16k tokens | Simple tasks, fast responses | 0 factual, 0.8 creative | Low |

---

## Six Core Strategies (Official)

### Strategy #1: Write Clear Instructions

**Official Guidance:**
> "Include details in your query to get more relevant answers"

**Tactics:**

1. **Include details in query**
   ```
   ❌ Bad: "Write a function"

   ✅ Good: "Write a Python function that:
   - Takes list of dicts
   - Filters by 'active' status
   - Sorts by 'created_at' desc
   - Returns filtered list
   - Handles missing keys with ValueError"
   ```

2. **Ask model to adopt a persona**
   ```
   "You are a senior Python developer with 10+ years experience
   in high-performance backend systems."
   ```

3. **Use delimiters**
   - **GPT-4.1 tested:** Markdown > XML > JSON (for documents)
   ```markdown
   ### Input
   {user data}

   ### Requirements
   {specifications}

   ### Output Format
   {expected structure}
   ```

4. **Specify steps**
   ```
   "To complete this task:
   1. Parse the input data
   2. Validate each field
   3. Transform to target format
   4. Return result with status code"
   ```

5. **Provide examples**
   ```
   "Examples:
   Input: {'name': 'John', 'age': '30'}
   Output: {'name': 'John', 'age': 30, 'valid': True}"
   ```

6. **Specify desired length**
   ```
   "Provide response in approximately 100 words"
   "Limit explanation to 3 paragraphs"
   ```

---

### Strategy #2: Provide Reference Text

**Official Guidance:**
> "Instruct the model to answer using a reference text"

**When to use:**
- Task requires specific knowledge
- Need citations/sources
- Want to ground answers in specific documents

**Examples:**

```markdown
REFERENCE TEXT:
"""
[Documentation/specs/code here]
"""

TASK:
Answer the following question using ONLY the reference text above.
Cite specific sections in your answer.

Question: {user question}
```

**For code:**
```markdown
CODEBASE CONTEXT:
```python
# Existing implementation
def existing_function():
    ...
```

TASK:
Write a new function that integrates with the above codebase.
Follow the same patterns and conventions.
```

---

### Strategy #3: Split Complex Tasks

**Official Guidance:**
> "Complex tasks have higher error rates than simpler tasks"

**Decomposition approach:**

```markdown
# Instead of monolithic request:
❌ "Build a complete REST API with auth, CRUD, validation, and tests"

# Break into subtasks:
✅ Step 1: "Design the data models and schemas"
✅ Step 2: "Implement authentication endpoints"
✅ Step 3: "Implement CRUD operations for User model"
✅ Step 4: "Add validation logic"
✅ Step 5: "Write unit tests for auth"
```

**Intent classification for dialogue:**
```markdown
Step 1: Classify user intent (query, command, feedback, etc.)
Step 2: Based on intent, route to appropriate handler
Step 3: Generate response using intent-specific logic
```

**Recursive summarization:**
```markdown
For long documents:
1. Summarize each section (max 100 words)
2. Combine section summaries
3. Create final summary from combined text
```

---

### Strategy #4: Give GPTs Time to "Think"

**Official Guidance:**
> "Instruct the model to work out its own solution before rushing to a conclusion"

**Chain of Thought (CoT):**

```markdown
Before providing your final answer:

1. **Analyze the problem:**
   - What are the inputs?
   - What are the constraints?
   - What edge cases exist?

2. **Consider approaches:**
   - What are 2-3 possible solutions?
   - What are pros/cons of each?

3. **Select best approach:**
   - Which approach best meets requirements?
   - Why is it optimal?

4. **Implement:**
   - Provide your solution
   - Explain key decisions
```

**For GPT-4.1 (Official recommendation):**
```markdown
# Agentic Workflow Reminders
You are in a multi-turn interaction. Before responding:

1. **Plan your approach** (explicit step-by-step)
2. **Use tools when needed** (don't hallucinate)
3. **Persist through the task** (don't yield prematurely)

Then provide your response.
```

**Inner monologue:**
```markdown
Think through this step-by-step in <thinking> tags:
<thinking>
[Your reasoning process]
</thinking>

Then provide final answer:
<answer>
[Your final solution]
</answer>
```

---

### Strategy #5: Use External Tools

**Official Guidance:**
> "Compensate for GPTs' weaknesses by feeding them outputs from other tools"

**Common tool integrations:**

1. **Code execution** (for calculations)
   ```
   Use Python tool to calculate exact values
   Don't approximate complex math
   ```

2. **Knowledge retrieval** (embeddings-based search)
   ```
   Search documentation before answering
   Use vector DB for relevant context
   ```

3. **Function calling** (API interactions)
   ```
   Available functions:
   - get_weather(location)
   - search_database(query)
   - send_email(to, subject, body)

   Use appropriate function rather than guessing.
   ```

**GPT-4.1 Tool Calling Best Practices:**
- Use API's `tools` field (not manual injection)
- Clear tool names and descriptions
- Don't force tool calls without context (causes hallucination)

---

### Strategy #6: Test Changes Systematically

**Official Guidance:**
> "Evaluate performance with reference to gold-standard answers"

**Evaluation approach:**

1. **Create test cases**
   ```
   Test Case 1:
   Input: {sample input}
   Expected: {gold standard output}
   Actual: {model output}
   Pass/Fail: {comparison result}
   ```

2. **Measure performance**
   - Accuracy on representative examples
   - Consistency across multiple runs
   - Edge case handling

3. **Compare prompt variations**
   ```
   Prompt A: [version 1]
   Prompt B: [version 2]

   Test on 10 examples → which performs better?
   ```

---

## Model-Specific Optimizations

### GPT-4.1 (Released April 2025)

**Key Characteristics:**
- "Trained to follow instructions more closely and literally"
- 1M token context window
- State-of-the-art on SWE-bench (55% pass rate)
- Enhanced tool calling

**Specific Recommendations:**

1. **Long Context Handling**
   ```markdown
   # IMPORTANT INSTRUCTIONS
   {key requirements at START}

   ... [large context 100k+ tokens] ...

   # IMPORTANT INSTRUCTIONS (REPEATED)
   {same key requirements at END}
   ```
   **Why:** Instructions at both beginning AND end improve performance

2. **Prompt Structure Template**
   ```markdown
   # Role and Objective
   You are {role}. Your goal is to {objective}.

   # Instructions
   ## Category 1
   - Specific guideline 1
   - Specific guideline 2

   ## Category 2
   - Specific guideline 3

   # Reasoning Steps
   Before responding, think through:
   1. {step 1}
   2. {step 2}

   # Output Format
   Structure your response as:
   {format specification}

   # Examples
   {few-shot examples}

   # Context
   {relevant background}

   # Final Reminder
   Think step by step before providing your answer.
   ```

3. **Delimiter Preferences** (from official testing)
   - ✅ **Markdown:** Best for hierarchical organization
   - ✅ **XML:** Strong for nested structures
   - ❌ **JSON:** Poor for document collections

4. **Diff Generation** (new capability)
   ```markdown
   Use V4A diff format for code changes:

   <<<<<<< SEARCH
   {exact existing code to find}
   =======
   {replacement code}
   >>>>>>> REPLACE
   ```

5. **Agentic Workflows** (20% improvement observed)
   ```markdown
   SYSTEM INSTRUCTIONS:
   1. You are persistent - continue multi-turn interaction
   2. Use tools fully - don't hallucinate answers
   3. Plan explicitly - show step-by-step reasoning between tool calls
   ```

---

### GPT-4 Turbo (128k context)

**Best For:**
- Long documents
- Complex reasoning
- Multi-step workflows

**Optimizations:**
```markdown
# For long context:
1. Organize with clear sections
2. Use markdown headers for navigation
3. Place critical info at beginning
4. Summarize key points at end

# For complex reasoning:
- Enable chain-of-thought
- Break into subtasks
- Provide intermediate checkpoints
```

---

### GPT-4 (8k/32k context)

**Best For:**
- High-quality general tasks
- Balanced cost/performance

**Optimizations:**
```markdown
# Context management:
- Prioritize most relevant information
- Summarize background
- Keep prompts focused

# Quality over speed:
- Allow thinking time
- Request detailed explanations
- Use examples liberally
```

---

### GPT-3.5 Turbo (16k context)

**Best For:**
- Simple, straightforward tasks
- Fast iteration
- Cost-sensitive applications

**Optimizations:**
```markdown
# Simplification:
- More explicit instructions
- Simpler language
- Smaller context
- More examples

# Avoid:
- Complex multi-step reasoning
- Nuanced tasks
- Large context windows
```

---

## Temperature Guidelines (Official)

**From official documentation:**
> "For factual use cases such as data extraction and truthful Q&A, the temperature of 0 is best."

| Task Type | Recommended Temperature | Rationale |
|-----------|------------------------|-----------|
| **Code generation** | 0.0 | Factual, deterministic output needed |
| **Data extraction** | 0.0 | Exact accuracy required |
| **Math/Logic** | 0.0 | Precise calculations |
| **Q&A (factual)** | 0.0 | Consistent, accurate answers |
| **Analysis** | 0.3-0.5 | Some creativity in insights |
| **Writing (technical)** | 0.5-0.7 | Clarity + some variation |
| **Creative writing** | 0.7-0.9 | Diverse, interesting output |
| **Brainstorming** | 0.8-1.0 | Maximum variety |

---

## Context Length Management

### Effective Context Windows

Models have theoretical and *effective* attention spans:

| Model | Theoretical | Effective (High Quality) |
|-------|-------------|-------------------------|
| GPT-4.1 | 1M tokens | ~500k tokens |
| GPT-4 Turbo | 128k tokens | ~64k tokens |
| GPT-4 | 32k tokens | ~16k tokens |
| GPT-3.5 Turbo | 16k tokens | ~8k tokens |

**Best Practices:**
1. Keep within effective limits
2. Prioritize relevant context
3. Use summarization for long documents
4. Test quality at different lengths

---

## Function/Tool Calling

### Official Best Practices

**From GPT-4.1 Guide:**
> "Use the API's `tools` field rather than manually injecting tool descriptions"
> "Observed 2% increase in SWE-bench performance"

**Good Function Definition:**
```python
{
    "name": "get_active_users",
    "description": "Retrieves all users with 'active' status from the database. Returns user ID, name, email, and last_login timestamp. Use this when you need current active user information.",
    "parameters": {
        "type": "object",
        "properties": {
            "limit": {
                "type": "integer",
                "description": "Maximum number of users to return (default: 100, max: 1000)"
            },
            "sort_by": {
                "type": "string",
                "enum": ["name", "email", "last_login"],
                "description": "Field to sort results by"
            }
        }
    }
}
```

**Key Elements:**
- Clear, descriptive name
- Detailed description (when to use)
- Well-documented parameters
- Constraints and defaults specified

---

## Common Pitfalls (OpenAI-Specific)

### 1. Conflicting Instructions

❌ **Problem:**
```markdown
Use simple language.
... [large context] ...
Use technical terminology and be precise.
```

**Solution:** GPT-4.1 follows instructions closer to end
```markdown
# Core Instructions (place at END for GPT-4.1)
- Use technical terminology
- Be precise and detailed
```

---

### 2. Excessive Prose

❌ **Problem:**
```
Model produces long explanations when you want concise code
```

**Solution:**
```markdown
Provide ONLY the code implementation.
Do not include explanations unless specifically requested.
No comments except where critical.
```

---

### 3. Repetitive Sample Phrases

❌ **Problem:**
```
Model keeps using same phrases like "It's important to note that..."
```

**Solution:**
```markdown
Vary your language. Avoid repetitive phrases.
Use different sentence structures across sections.
```

---

### 4. Forcing Tool Calls

❌ **Problem:**
```
Forcing mandatory tool use without context causes hallucination
```

**Solution:**
```markdown
Use available tools WHEN APPROPRIATE.
If tools aren't needed for this task, you can answer directly.
```

---

## Performance Optimization

### For Speed
- Use GPT-3.5 Turbo for simple tasks
- Reduce context size
- Use lower temperature (faster sampling)
- Streaming responses

### For Quality
- Use GPT-4.1 or GPT-4 Turbo
- Provide rich context
- Enable chain-of-thought
- Multiple sampling (temperature > 0, generate multiple, select best)

### For Cost
- Use GPT-3.5 Turbo where possible
- Optimize prompt length (remove redundancy)
- Cache common prompts
- Use function calling to reduce context

---

## Prompt Template (OpenAI-Optimized)

```markdown
# ROLE
You are {specific role with expertise}.

# TASK
{Clear, specific task description}

# CONTEXT
{Relevant background information}

# REFERENCE
{Any documentation, code, or specs to use}

# CONSTRAINTS
- {Constraint 1}
- {Constraint 2}
- {Constraint 3}

# THINKING PROCESS
Before responding, consider:
1. {Analytical step 1}
2. {Analytical step 2}
3. {Analytical step 3}

# OUTPUT FORMAT
Structure your response as:
{Explicit format specification}

# EXAMPLES
Example 1:
Input: {sample input}
Output: {expected output}

Example 2:
Input: {sample input}
Output: {expected output}

# FINAL INSTRUCTION
{Most critical requirement - place at end for GPT-4.1}

Think step by step, then provide your response.
```

---

## Testing Checklist

Before deploying OpenAI prompts:

- [ ] Temperature appropriate for task (0 for factual)
- [ ] Context within effective limit
- [ ] Examples provided (especially for GPT-3.5)
- [ ] Delimiters used (markdown/XML)
- [ ] Chain-of-thought prompted (if reasoning needed)
- [ ] Output format specified
- [ ] Tool descriptions clear (if using functions)
- [ ] Tested on edge cases
- [ ] Critical instructions at END (for GPT-4.1 long context)

---

## Resources

**Official Documentation:**
- Main Guide: platform.openai.com/docs/guides/prompt-engineering
- GPT-4.1 Guide: cookbook.openai.com/examples/gpt4-1_prompting_guide
- Best Practices: help.openai.com/en/articles/6654000

**Model Information:**
- Pricing: openai.com/pricing
- API Reference: platform.openai.com/docs/api-reference

---

**Version:** 1.0 (Phase 2)
**Last Updated:** 2025-01-29
**Based on:** OpenAI Official Documentation (2025)
