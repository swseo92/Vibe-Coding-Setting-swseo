# Google Gemini-Specific Prompting Guide

Provider-specific optimizations, constraints, and best practices for Google Gemini models (Pro, Flash, Ultra).

**Based on Official Documentation:**
- ai.google.dev/gemini-api/docs/prompting-strategies (2025)
- cloud.google.com/vertex-ai/generative-ai/docs/learn/prompts (2025)
- Gemini for Google Workspace Prompting Guide (October 2024)

---

## Model Comparison

| Model | Context | Best For | Multimodal | Speed | Cost |
|-------|---------|----------|------------|-------|------|
| **Gemini 2.0 Ultra** | 1M tokens | Complex reasoning, long context | Yes (advanced) | Slow | Highest |
| **Gemini 2.0 Pro** | 1M tokens | General tasks, long documents | Yes | Medium | Medium |
| **Gemini 1.5 Pro** | 1M tokens | Production workloads | Yes | Medium | Medium |
| **Gemini 1.5 Flash** | 1M tokens | Fast, efficient tasks | Yes | Fast | Low |

**Note:** All Gemini models support multimodal (text, images, video, audio)

---

## Four Core Elements (Official Framework)

### Official Guidance:
> "Prompt design involves creating structured requests that elicit desired responses"

The official documentation emphasizes **four key components:**

### 1. **Persona (Who)**

**Definition:** Who the AI should be

**Examples:**

```markdown
✅ Good Personas:
- "You are an expert Python developer specializing in data pipelines"
- "You are a technical writer creating documentation for developers"
- "You are a senior security engineer reviewing code"

❌ Vague Personas:
- "You are helpful"
- "You are smart"
```

**For Workspace:**
```markdown
You are a professional business analyst preparing executive reports.
Your audience is C-level executives who need concise insights.
```

---

### 2. **Task (What)**

**Definition:** What you want the model to do

**Be specific and actionable:**

```markdown
✅ Good Tasks:
- "Write a Python function that validates email addresses"
- "Summarize this document in 3 bullet points"
- "Analyze this code for security vulnerabilities"

❌ Vague Tasks:
- "Help with Python"
- "Look at this"
- "Do something with this code"
```

**Task Decomposition:**
```markdown
Instead of: "Build a web app"

Break down:
Task 1: "Design the database schema for user management"
Task 2: "Write API endpoints for user CRUD operations"
Task 3: "Create frontend components for user dashboard"
```

---

### 3. **Context (Background)**

**Definition:** Relevant background information

**What to include:**
- Input data structure
- Constraints and requirements
- Environment details
- Previous attempts or known issues

**Example:**

```markdown
CONTEXT:
- Input: CSV file with columns [id, name, email, status, created_at]
- System: Python 3.10, pandas available
- Constraint: File can be up to 10MB (100k rows)
- Requirement: Must handle missing values gracefully
- Known issue: 'created_at' format inconsistent (some ISO, some MM/DD/YYYY)
```

---

### 4. **Format (Output Structure)**

**Definition:** How the output should be structured

**Official Recommendation: Use prefixes**

```markdown
Input: user_data.csv
Output: cleaned_dataframe

Input: "2025-01-29"
Output: datetime object

JSON: {"name": "...", "age": ...}
Markdown: ## Section Title
```

**Detailed Format Specification:**

```markdown
FORMAT YOUR RESPONSE AS:

## Analysis
- Finding 1
- Finding 2
- Finding 3

## Recommendations
1. Recommendation with rationale
2. Recommendation with rationale

## Implementation
```python
# Complete code here
```

## Testing
```python
# Test cases
```
```

---

## Official Best Practice: Few-Shot Examples

### Critical Guidance:
> "We recommend to always include few-shot examples in your prompts. Prompts without few-shot examples are likely to be less effective."

**Why it matters:**
- Gemini models respond exceptionally well to examples
- Examples define format better than descriptions
- Reduces ambiguity significantly

**Few-Shot Pattern:**

```markdown
Convert dates to ISO format (YYYY-MM-DD).

Example 1:
Input: "January 15, 2025"
Output: "2025-01-15"

Example 2:
Input: "03/20/2025"
Output: "2025-03-20"

Example 3:
Input: "15.04.2025"
Output: "2025-04-15"

Now convert: {user input}
```

**For Complex Tasks:**

```markdown
Extract user information from text.

Example 1:
Input: "John Smith, john@example.com, age 30, works at Google"
Output:
```json
{
  "name": "John Smith",
  "email": "john@example.com",
  "age": 30,
  "company": "Google"
}
```

Example 2:
Input: "Contact: Mary Johnson (mary.j@corp.com), 25 years old"
Output:
```json
{
  "name": "Mary Johnson",
  "email": "mary.j@corp.com",
  "age": 25,
  "company": null
}
```

Now extract from: {user input}
```

---

## Prefixes for Structure (Official Pattern)

**From official documentation:**
> "Prefixes signal semantic parts and output format"

### Input/Output Prefixes

```markdown
English: "Hello, how are you?"
French: "Bonjour, comment allez-vous?"

English: "Good morning"
French:
```

### Format Prefixes

```markdown
Question: What is the capital of France?
Answer: Paris

Question: What is 2+2?
Answer: 4

Question: {user question}
Answer:
```

### Semantic Prefixes

```markdown
Task: Analyze this code for bugs
Code:
```python
def process_data(data):
    return data.sort()
```

Issues:
- Problem 1: {description}
- Problem 2: {description}

Fixed Code:
```python
{corrected implementation}
```
```

---

## Parameter Optimization

### Official Parameters:

1. **Temperature** (0.0 - 2.0)
   - **0**: Deterministic, consistent (factual tasks)
   - **0.5-1.0**: Balanced creativity and consistency
   - **1.5-2.0**: High creativity, more variation

2. **Top-K** (1 - 40)
   - Restricts sampling to top K probable tokens
   - Lower = more focused
   - Higher = more diverse

3. **Top-P** (0.0 - 1.0)
   - Cumulative probability threshold
   - Default: 0.95
   - Lower = more focused
   - Higher = more diverse

4. **Max Output Tokens**
   - ~100 tokens ≈ 60-80 words
   - Set appropriate limit for task

5. **Stop Sequences**
   - Halt generation at specific strings
   - Useful for structured output

**Recommended Combinations:**

| Task Type | Temperature | Top-K | Top-P |
|-----------|-------------|-------|-------|
| Code generation | 0.0-0.2 | 10-20 | 0.8 |
| Data extraction | 0.0 | 10 | 0.8 |
| Technical writing | 0.3-0.5 | 20-30 | 0.9 |
| Creative writing | 0.7-0.9 | 30-40 | 0.95 |
| Brainstorming | 1.0-1.5 | 40 | 1.0 |

---

## Multimodal Prompting

**Gemini's Key Strength:** Native multimodal support

### Image + Text

```markdown
Analyze this code screenshot and:
1. Identify the programming language
2. Explain what the code does
3. Suggest improvements

[Image: screenshot.png]

Focus on readability and performance.
```

### Video Analysis

```markdown
Watch this video and:
1. Summarize key points (3 bullet points)
2. Extract action items mentioned
3. Note any technical terms used

[Video: tutorial.mp4]

Output as structured markdown.
```

### Document Understanding

```markdown
Read this PDF and answer:
1. What is the main topic?
2. What are the key findings?
3. What recommendations are made?

[PDF: research_paper.pdf]

Provide citations with page numbers.
```

---

## System Instructions (Vertex AI)

**From official docs:**
> "System instructions control style, tone, and behavioral constraints"

**Usage:**

```python
# Via systemInstruction parameter
system_instruction = """
You are a helpful coding assistant.
- Always explain your reasoning
- Provide complete, runnable code
- Include error handling
- Follow PEP 8 for Python
- Never make assumptions about missing information
"""
```

**Examples:**

```markdown
# For code review:
You are a senior developer reviewing code.
- Focus on security, performance, and maintainability
- Provide specific line-by-line feedback
- Suggest concrete improvements with code examples
- Explain the reasoning behind each suggestion

# For data analysis:
You are a data scientist analyzing datasets.
- Start with exploratory analysis
- Identify patterns and anomalies
- Provide statistical insights
- Visualize findings when possible
- Explain methodology clearly

# For documentation:
You are a technical writer.
- Use clear, concise language
- Organize with proper headings
- Include code examples
- Add troubleshooting sections
- Write for intermediate developers
```

---

## Iteration Strategies

**Official Guidance:**
> "When initial attempts fail, try alternative approaches"

### 1. Rephrase

```markdown
❌ First attempt: "Fix this code"

✅ Rephrased: "Identify bugs in this code and provide corrected version with explanations"
```

### 2. Analogous Task

```markdown
❌ First attempt: "Optimize this query" (too vague)

✅ Analogous: "This query takes 5 seconds. Make it run in under 1 second by:
- Adding appropriate indexes
- Rewriting joins
- Optimizing subqueries"
```

### 3. Reorder Components

```markdown
❌ First attempt:
Examples → Task → Context → Format

✅ Reordered:
Context → Task → Format → Examples
(Sometimes works better for complex tasks)
```

---

## Workspace Integration

**From Gemini for Workspace Guide:**

### Email (Gmail)

```markdown
PERSONA: Professional email writer
TASK: Draft reply to customer inquiry
CONTEXT: Customer asking about product pricing and delivery time
FORMAT: Professional tone, 3 short paragraphs, include call-to-action
```

### Documents (Google Docs)

```markdown
PERSONA: Technical writer
TASK: Create API documentation
CONTEXT: REST API with 5 endpoints (CRUD operations)
FORMAT: Markdown with code examples, organized by endpoint
```

### Sheets (Google Sheets)

```markdown
PERSONA: Data analyst
TASK: Analyze sales data and create pivot table
CONTEXT: Spreadsheet with columns: date, product, quantity, revenue
FORMAT: Summary table + 3 key insights
```

### Slides (Google Slides)

```markdown
PERSONA: Presentation designer
TASK: Create 5-slide pitch deck
CONTEXT: Startup product launch, target: investors
FORMAT: Title slide + Problem + Solution + Market + Ask
```

---

## Handling Fallback Responses

**Issue:** Model returns generic/unhelpful response

**Official Solution:**
> "If model responds with fallback response, try increasing temperature"

**Why:** Temperature 0 can trigger safety filters → fallback response

**Fix:**

```markdown
# If getting fallback responses:
1. Increase temperature from 0 → 0.3
2. Rephrase to avoid triggering safety filters
3. Add more context to clarify intent
4. Use examples to show desired output
```

---

## Context Window Optimization

### Effective Use of 1M Token Window

**Strategies:**

1. **Long Document Analysis**
   ```markdown
   [Upload 500-page PDF]

   Analyze this document and:
   1. Create table of contents with page numbers
   2. Summarize each chapter (100 words each)
   3. Extract all action items
   4. List key terminology with definitions
   ```

2. **Codebase Understanding**
   ```markdown
   [Attach multiple code files]

   Understand this codebase and:
   1. Explain architecture
   2. Map data flow
   3. Identify potential issues
   4. Suggest improvements
   ```

3. **Multi-document Synthesis**
   ```markdown
   [Attach documents A, B, C]

   Compare these documents:
   1. Common themes
   2. Contradictions
   3. Unique insights from each
   4. Synthesized recommendations
   ```

---

## Common Gemini Patterns

### Pattern 1: Structured Extraction

```markdown
Extract information from this text using the format below.

Input: {text}

Output format:
Field 1: {value}
Field 2: {value}
Field 3: {value}

Example:
Input: "John Smith works at Google, email john@google.com, joined 2020"
Output format:
Name: John Smith
Company: Google
Email: john@google.com
Year: 2020

Now extract from: {new text}
```

### Pattern 2: Classification

```markdown
Classify the following text into one category.

Categories:
- Bug Report
- Feature Request
- Question
- Feedback

Examples:
Text: "The app crashes when I click Save"
Category: Bug Report

Text: "Can you add dark mode?"
Category: Feature Request

Text: "How do I export data?"
Category: Question

Now classify: {user text}
Category:
```

### Pattern 3: Transform

```markdown
Transform the input data to the specified format.

Input format: CSV
Output format: JSON

Example:
Input: id,name,age
1,John,30
2,Mary,25

Output:
```json
[
  {"id": 1, "name": "John", "age": 30},
  {"id": 2, "name": "Mary", "age": 25}
]
```

Now transform: {user data}
```

---

## Safety and Content Filtering

**Gemini includes built-in safety filters for:**
- Hate speech
- Harassment
- Sexually explicit content
- Dangerous content

**Best Practices:**

1. **If legitimate request triggers filters:**
   ```markdown
   # Be more specific about context
   ❌ "How to hack"
   ✅ "Explain common web security vulnerabilities for educational purposes in a cybersecurity course"
   ```

2. **Academic/Research Context:**
   ```markdown
   CONTEXT: This is for academic research on {topic}
   TASK: Analyze {sensitive topic} from scholarly perspective
   FORMAT: Objective, factual analysis with citations
   ```

3. **Increase Temperature:**
   - Sometimes temperature 0 triggers filters
   - Try 0.3-0.5 if getting fallback responses

---

## Performance Tips

### For Best Quality:
- Always include few-shot examples
- Use all 4 elements (Persona, Task, Context, Format)
- Provide rich context
- Specify output format with prefixes
- Use appropriate temperature

### For Speed:
- Use Gemini Flash model
- Reduce context size
- Use shorter prompts
- Set lower max output tokens

### For Consistency:
- Temperature 0
- Detailed examples
- Explicit format specification
- Stop sequences for structured output

---

## Gemini-Optimized Template

```markdown
# PERSONA
You are {specific role with expertise}.
{Additional persona details if needed.}

# TASK
{Specific, actionable task description}

# CONTEXT
- Input: {format and structure}
- Constraints: {limitations}
- Requirements: {must-haves}
- Environment: {technical details}

# FORMAT
Structure your response as:

Section 1: {description}
{prefix format}

Section 2: {description}
{prefix format}

# EXAMPLES
Example 1:
Input: {sample}
Output: {expected result}

Example 2:
Input: {sample}
Output: {expected result}

Example 3:
Input: {sample}
Output: {expected result}

# YOUR TASK
Input: {actual user input}
Output:
```

---

## Testing Checklist

Before deploying Gemini prompts:

- [ ] All 4 elements present (Persona, Task, Context, Format)
- [ ] Few-shot examples included (official recommendation)
- [ ] Prefixes used for structure (Input:, Output:, etc.)
- [ ] Temperature appropriate (0 for factual, higher for creative)
- [ ] Output format explicitly specified
- [ ] System instructions set (if using Vertex AI)
- [ ] Tested with various inputs
- [ ] Fallback responses handled (increase temp if needed)
- [ ] Context within 1M token limit

---

## Comparison: Gemini vs OpenAI

| Aspect | Gemini | OpenAI GPT |
|--------|--------|------------|
| **Structure** | 4 elements (PTCF) | 6 strategies |
| **Examples** | Strongly recommended | Recommended |
| **Prefixes** | Emphasized | Less emphasized |
| **Multimodal** | Native, advanced | Available (GPT-4V) |
| **Context** | 1M tokens (all models) | 1M (GPT-4.1), 128k (GPT-4 Turbo) |
| **Temperature** | 0-2.0 | 0-2.0 |
| **Best For** | Multimodal, long context, workspace | Tool calling, reasoning, code |

---

## Resources

**Official Documentation:**
- Main Guide: ai.google.dev/gemini-api/docs/prompting-strategies
- Vertex AI: cloud.google.com/vertex-ai/generative-ai/docs/learn/prompts
- Workspace Guide: workspace.google.com/learning/content/gemini-prompt-guide

**API Documentation:**
- Gemini API: ai.google.dev/gemini-api/docs
- Prompt Gallery: ai.google.dev/gemini-api/prompts

---

**Version:** 1.0 (Phase 2)
**Last Updated:** 2025-01-29
**Based on:** Google Gemini Official Documentation (2025)
