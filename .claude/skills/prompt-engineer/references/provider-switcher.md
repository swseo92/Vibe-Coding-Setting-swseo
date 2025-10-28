# Provider Switcher

Convert prompts between different AI providers while maintaining intent and optimizing for each provider's strengths.

**Supported Providers:**
- OpenAI (GPT-3.5, GPT-4, GPT-4 Turbo, GPT-4.1)
- Google Gemini (Pro, Flash, Ultra)
- Claude (Sonnet, Opus) - Basic support

---

## Why Provider-Specific Optimization Matters

Different providers have:
- Different prompting philosophies
- Different optimal structures
- Different parameter ranges
- Different strengths/weaknesses

**Example Impact:**
- Same intent → 20-30% quality difference with optimized prompts
- Provider-specific features utilized
- Avoids anti-patterns specific to each provider

---

## Conversion Patterns

### Pattern 1: Code Generation

#### Original Intent
"Write a Python function to filter active users and sort by date"

---

#### OpenAI Version (GPT-4)

**Optimizations Applied:**
- Chain-of-thought prompting
- Explicit step-by-step instruction
- Reference to PEP 8
- Temperature 0 (official recommendation)

```markdown
You are an expert Python developer.

TASK:
Write a Python function with the following specification.

**Before implementing, think through:**
1. What edge cases need handling?
2. What's the most efficient approach?
3. What errors could occur?

**Specification:**
- Function name: `filter_active_users`
- Input: List[Dict] with keys: id, status, created_at
- Processing:
  - Filter where status == 'active'
  - Sort by created_at descending
- Output: Filtered and sorted List[Dict]
- Requirements:
  - Type hints (Python 3.10+)
  - Docstring (Google style)
  - Error handling (missing keys, invalid dates)
  - PEP 8 compliant

**INPUT EXAMPLE:**
```python
users = [
    {'id': 1, 'status': 'active', 'created_at': '2025-01-15'},
    {'id': 2, 'status': 'inactive', 'created_at': '2025-01-14'},
    {'id': 3, 'status': 'active', 'created_at': '2025-01-16'}
]
```

**EXPECTED OUTPUT:**
```python
[
    {'id': 3, 'status': 'active', 'created_at': '2025-01-16'},
    {'id': 1, 'status': 'active', 'created_at': '2025-01-15'}
]
```

Provide complete implementation with type hints and docstring.

**Settings:** Temperature 0.0
```

---

#### Gemini Version

**Optimizations Applied:**
- 4-element structure (Persona, Task, Context, Format)
- Multiple few-shot examples (official strong recommendation)
- Input/Output prefixes
- Temperature 0.0

```markdown
PERSONA:
You are an expert Python developer specializing in data processing.

TASK:
Write a function that filters and sorts user data.

CONTEXT:
- Input format: List of dictionaries
- Required keys: id (int), status (str), created_at (str in YYYY-MM-DD)
- Filter criteria: status == 'active'
- Sort criteria: created_at descending (newest first)
- Must include: type hints, docstring, error handling

FORMAT:
Provide response as:

1. Function implementation (complete, runnable code)
2. Usage example
3. Test cases

EXAMPLES:

Example 1:
Input:
```python
[{'id': 1, 'status': 'active', 'created_at': '2025-01-15'},
 {'id': 2, 'status': 'inactive', 'created_at': '2025-01-14'}]
```

Output:
```python
[{'id': 1, 'status': 'active', 'created_at': '2025-01-15'}]
```

Example 2:
Input:
```python
[{'id': 3, 'status': 'active', 'created_at': '2025-01-16'},
 {'id': 1, 'status': 'active', 'created_at': '2025-01-15'}]
```

Output:
```python
[{'id': 3, 'status': 'active', 'created_at': '2025-01-16'},
 {'id': 1, 'status': 'active', 'created_at': '2025-01-15'}]
```

Example 3 (edge case):
Input: []
Output: []

YOUR TASK:
Write the complete function implementation:

**Settings:** Temperature 0.0
```

---

#### Claude Version

**Optimizations Applied:**
- XML tags for structure
- Detailed context
- Clear examples with edge cases

```markdown
You are an expert Python developer.

<task>
Write a Python function that filters active users and sorts by date
</task>

<specification>
- Function: filter_active_users
- Input: List[Dict] with id, status, created_at
- Output: Filtered list (status='active'), sorted by created_at desc
- Include: Type hints, docstring, error handling
</specification>

<examples>
<example>
<input>
[{'id': 1, 'status': 'active', 'created_at': '2025-01-15'},
 {'id': 2, 'status': 'inactive', 'created_at': '2025-01-14'}]
</input>
<output>
[{'id': 1, 'status': 'active', 'created_at': '2025-01-15'}]
</output>
</example>

<example type="edge_case">
<input>[]</input>
<output>[]</output>
</example>
</examples>

<requirements>
- Python 3.10+
- PEP 8 compliant
- Handle missing keys gracefully
- Include comprehensive docstring
</requirements>

Provide complete implementation.

**Settings:** Temperature 0.0
```

---

### Pattern 2: Data Extraction

#### Original Intent
"Extract name, email, and age from text"

---

#### OpenAI Version (GPT-4)

```markdown
You are a data extraction specialist.

TASK:
Extract structured information from unstructured text.

REFERENCE TEXT PATTERN:
The input text contains person information in various formats.
Extract: name, email, age

EXAMPLES:
Text: "John Smith, john@example.com, 30 years old"
Output:
```json
{"name": "John Smith", "email": "john@example.com", "age": 30}
```

Text: "Contact Mary (mary@corp.com), age 25"
Output:
```json
{"name": "Mary", "email": "mary@corp.com", "age": 25}
```

Text: "Bob, no email, 35"
Output:
```json
{"name": "Bob", "email": null, "age": 35}
```

INSTRUCTIONS:
1. Parse the input text carefully
2. Extract available fields
3. Use null for missing data
4. Return valid JSON only

Now extract from: {user input}

**Settings:** Temperature 0.0 (factual extraction)
```

---

#### Gemini Version

```markdown
PERSONA: Data extraction specialist

TASK: Extract person information to JSON

CONTEXT:
- Input: Natural language text (varied formats)
- Extract: name, email, age
- Handle: Missing fields (use null)
- Output: Valid JSON only

FORMAT:
JSON: {"name": "...", "email": "...", "age": ...}

EXAMPLES:

Example 1:
Input: "John Smith, john@example.com, 30 years old"
JSON: {"name": "John Smith", "email": "john@example.com", "age": 30}

Example 2:
Input: "Contact Mary (mary@corp.com), age 25"
JSON: {"name": "Mary", "email": "mary@corp.com", "age": 25}

Example 3:
Input: "Bob works here, 35 years old"
JSON: {"name": "Bob", "email": null, "age": 35}

Example 4:
Input: "alice@test.com, 28"
JSON: {"name": null, "email": "alice@test.com", "age": 28}

Example 5 (all missing):
Input: "Someone is here"
JSON: {"name": null, "email": null, "age": null}

Now extract:
Input: {user input}
JSON:

**Settings:** Temperature 0.0
```

**Note:** Gemini version has MORE examples (official recommendation: "always include few-shot examples")

---

### Pattern 3: Code Review

#### OpenAI Version (GPT-4.1)

```markdown
# ROLE AND OBJECTIVE
You are a senior software engineer with expertise in Python and system design.
Your goal is to provide thorough code review feedback.

# INSTRUCTIONS

## Review Focus
- Security vulnerabilities
- Performance issues
- Code maintainability
- Best practices compliance

## Analysis Process
Before providing feedback:
1. Read the code completely
2. Identify patterns and architecture
3. Check for common anti-patterns
4. Assess test coverage implications

# OUTPUT FORMAT
Structure your review as:

## Summary
[Brief overview of code quality]

## Issues Found
### High Priority
- [Issue with line number and explanation]

### Medium Priority
- [Issue with line number and explanation]

### Low Priority
- [Issue with line number and explanation]

## Recommendations
1. [Specific improvement with code example]
2. [Specific improvement with code example]

## Refactored Code
```python
[Improved implementation if major changes needed]
```

# CODE TO REVIEW
```python
{user code}
```

# FINAL REMINDER
Provide specific, actionable feedback with examples.

**Settings:** Temperature 0.3 (some creativity in suggestions)
```

---

#### Gemini Version

```markdown
PERSONA:
You are a senior Python engineer conducting code review.
Focus on security, performance, and maintainability.

TASK:
Review the provided code and identify issues with concrete improvements.

CONTEXT:
- Language: Python
- Focus areas: Security, Performance, Maintainability
- Provide: Specific line-by-line feedback
- Include: Refactored code examples

FORMAT:
Your review should follow this structure:

## Overview
{brief assessment}

## Issues
- **Line X:** {issue} → Severity: {High/Medium/Low}
- **Line Y:** {issue} → Severity: {High/Medium/Low}

## Recommendations
1. {recommendation with code example}
2. {recommendation with code example}

## Refactored Code
```python
{improved version}
```

EXAMPLES:

Example 1:
Code:
```python
def get_user(id):
    return db.query(f"SELECT * FROM users WHERE id={id}")
```

Review:
## Overview
Critical security vulnerability (SQL injection)

## Issues
- **Line 2:** SQL injection risk → Severity: High
- **Line 1:** Missing type hints → Severity: Low

## Recommendations
1. Use parameterized queries to prevent SQL injection
```python
def get_user(user_id: int) -> dict:
    return db.query("SELECT * FROM users WHERE id=%s", (user_id,))
```

YOUR TASK:
Code to review:
```python
{user code}
```

Review:

**Settings:** Temperature 0.3
```

---

## Provider Selection Guide

### Choose OpenAI (GPT-4) When:
✅ Complex multi-step reasoning required
✅ Tool/function calling needed
✅ Agentic workflows
✅ Code generation (especially with GPT-4.1)
✅ Systematic problem decomposition

### Choose Gemini When:
✅ Multimodal inputs (images, video, audio)
✅ Very long context (1M tokens efficiently)
✅ Google Workspace integration
✅ Need for consistent structured output
✅ Cost-effective for simple tasks (Flash)

### Choose Claude When:
✅ Very long-form analysis
✅ Document understanding
✅ Nuanced ethical reasoning
✅ Complex written content
✅ XML-structured tasks

---

## Conversion Checklist

When converting prompts between providers:

### OpenAI → Gemini
- [ ] Restructure to 4 elements (Persona, Task, Context, Format)
- [ ] Add more few-shot examples (2-3 minimum, 5+ ideal)
- [ ] Use Input:/Output: prefixes
- [ ] Remove OpenAI-specific tactics (unless applicable)
- [ ] Adjust temperature if needed

### Gemini → OpenAI
- [ ] Incorporate chain-of-thought if reasoning needed
- [ ] Structure with markdown sections
- [ ] Consider tool calling if applicable
- [ ] Add "think step by step" for complex tasks
- [ ] Place critical instructions at end (GPT-4.1)

### Either → Claude
- [ ] Use XML tags for structure
- [ ] Provide extensive context
- [ ] Use clear delimiters
- [ ] Include detailed examples
- [ ] Explain reasoning requirements

---

## Quick Conversion Template

```markdown
# ORIGINAL INTENT
{What you want the AI to do}

# OPENAI VERSION
{Apply: CoT, step-by-step, markdown structure, temperature 0 for facts}

# GEMINI VERSION
{Apply: 4 elements, multiple examples, prefixes, temperature 0 for facts}

# CLAUDE VERSION
{Apply: XML tags, detailed context, extensive examples}

# SETTINGS COMPARISON
OpenAI: Temperature {X}, Max tokens {Y}
Gemini: Temperature {X}, Top-K {Y}, Top-P {Z}, Max tokens {W}
Claude: Temperature {X}, Max tokens {Y}
```

---

## Provider-Specific Features

### OpenAI Unique Features
- Function/tool calling (GPT-4.1 optimized)
- GPT-4.1 diff generation (V4A format)
- Agentic workflows (with persistence prompting)
- Long context at END placement (GPT-4.1)

### Gemini Unique Features
- Native multimodal (image, video, audio)
- 1M context efficiently used
- Google Workspace native integration
- Top-K and Top-P parameters
- Fallback response handling (increase temp)

### Claude Unique Features
- Constitutional AI alignment
- Extended thinking mode
- XML tag understanding
- Document analysis strength
- Contextual memory

---

## Example Comparison

### Same Task, Three Providers

**Task:** "Analyze this image and extract text"

**OpenAI GPT-4V:**
```markdown
Analyze this image and extract all visible text.

INSTRUCTIONS:
1. Identify all text regions
2. Extract text preserving layout
3. Note any unclear/ambiguous text
4. Provide confidence scores if uncertain

IMAGE: [image.png]

OUTPUT FORMAT:
```json
{
  "text_regions": [
    {"text": "...", "location": "...", "confidence": "high|medium|low"}
  ],
  "layout": "description",
  "notes": "any issues"
}
```
```

**Gemini Pro:**
```markdown
PERSONA: OCR and image analysis specialist

TASK: Extract all text from image with layout preservation

CONTEXT:
- Input: Image (any format)
- Extract: All visible text
- Preserve: Layout structure
- Note: Unclear or ambiguous regions

FORMAT:
JSON: {
  "text_regions": [...],
  "layout_description": "...",
  "notes": "..."
}

EXAMPLES:

Example 1:
Image: [Receipt image]
JSON: {
  "text_regions": [
    {"text": "Store Name", "location": "top", "confidence": "high"},
    {"text": "$12.99", "location": "bottom", "confidence": "high"}
  ],
  "layout_description": "Receipt format, vertical layout",
  "notes": "Some numbers slightly blurred"
}

YOUR TASK:
Image: [user image]
JSON:

**Note:** Gemini excels at multimodal with examples
```

**Claude:**
```markdown
<task>
Extract text from the provided image
</task>

<instructions>
1. Identify all text regions in the image
2. Extract text while preserving spatial layout
3. Note any ambiguous or unclear text
4. Provide structured output
</instructions>

<image>
[image.png]
</image>

<output_format>
{
  "extracted_text": [...],
  "layout_notes": "...",
  "quality_assessment": "..."
}
</output_format>

Provide comprehensive extraction with layout context.
```

---

## Resources

- OpenAI Guide: `references/openai-specifics.md`
- Gemini Guide: `references/gemini-specifics.md`
- Quality Rubric: `references/quality-rubric.md`
- Anti-Patterns: `references/anti-patterns.md`

---

**Version:** 1.0 (Phase 2)
**Last Updated:** 2025-01-29
**Purpose:** Cross-provider prompt optimization
