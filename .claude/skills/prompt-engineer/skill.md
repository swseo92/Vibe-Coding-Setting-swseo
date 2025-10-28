# Prompt Engineer

## Overview

Generate high-quality prompts based on official best practices from **OpenAI, Google Gemini, and Anthropic Claude**. This skill synthesizes guidance from official documentation to help you create effective prompts for any AI task.

**Based on Official Documentation:**
- OpenAI: Prompt Engineering Guide, GPT-4.1 Guide (2025)
- Google Gemini: Prompt Design Strategies, Vertex AI Guide (2025)
- Anthropic Claude: Prompt Engineering Overview (2025)

## When to Use This Skill

Activate when users request:
- "프롬프트 만들어줘" / "create a prompt for..."
- "이 작업에 맞는 프롬프트 생성해줘" / "generate prompt for this task"
- "프롬프트 개선해줘" / "improve this prompt"
- "ChatGPT/Gemini/Claude용 프롬프트 최적화" / "optimize for ChatGPT/Gemini/Claude"

**Appropriate use cases:**
- Code generation (write, refactor, debug)
- Data extraction and parsing
- Analysis and review (code review, performance)
- Creative tasks (documentation, naming)
- Reasoning tasks (architecture decisions)

## Quick Start (30 seconds)

For simple prompts, ask three questions:

1. **What's your goal?**
   - Code generation / Analysis / Data extraction / Creative / Reasoning

2. **Which AI?**
   - OpenAI (ChatGPT, GPT-4) / Google (Gemini) / Other (Claude, etc.)

3. **Any constraints?**
   - Output format / Language / Style / Length

Then generate optimized prompt based on official best practices.

## Decision Tree Workflow

### Step 1: What outcome do you need?

Ask user to select their primary goal:

```
1. Code Generation
   - Write new code (function, class, script)
   - Refactor existing code
   - Debug/fix code issues

2. Data Extraction & Parsing
   - Extract information from text
   - Parse structured data (JSON, CSV)
   - Transform data format

3. Analysis & Review
   - Code review
   - Performance analysis
   - Security audit
   - Quality assessment

4. Creative Tasks
   - Documentation writing
   - Naming (variables, functions, projects)
   - Brainstorming ideas
   - Content generation

5. Reasoning & Decision
   - Architecture decisions
   - Trade-off analysis
   - Problem solving
   - Planning
```

### Step 2: What constraints exist?

Gather information about:

```
1. AI Provider/Model
   - OpenAI (GPT-4, GPT-4 Turbo, GPT-3.5)
   - Google Gemini (Pro, Ultra, Flash)
   - Claude / Other

2. Context Size
   - Small (<1000 tokens)
   - Medium (1K-10K tokens)
   - Large (10K-100K tokens)
   - Very Large (100K+ tokens)

3. Response Format
   - Plain text
   - JSON / Structured data
   - Markdown
   - Code only
   - Table format

4. Special Requirements
   - Language (Korean, English, etc.)
   - Tone (formal, casual, technical)
   - Length constraints
   - Time/cost constraints
```

### Step 3: How much guidance do you have?

Assess detail level:

```
1. Just Goal (Minimal)
   → Need examples, context, and structure

2. Partial Context
   → Have some details, need refinement

3. Rich Specification
   → Well-defined task, optimize for best practices
```

### Step 4: Generate Optimized Prompt

Based on Steps 1-3, assemble prompt using appropriate blocks:

1. **Load relevant blocks** from `blocks/` directory
2. **Apply provider-specific optimizations** from `references/`
3. **Assemble complete prompt** following official best practices
4. **Run quality check** using rubric

### Step 5: Quality Check & Refinement

Run prompt through quality rubric:
- ✓ Clear objective?
- ✓ Sufficient context?
- ✓ Examples included (if needed)?
- ✓ Output format specified?
- ✓ Model-appropriate?

Offer improvements if score < 7/9.

## Universal Principles (NEW!)

**KEY INSIGHT:** 90%+ of prompting best practices are **provider-agnostic**!

OpenAI, Gemini, and Anthropic guidelines overlap significantly, revealing **universal truths** about effective prompting that work across ALL AI providers (ChatGPT, Gemini, Claude, etc.).

### The 7 Universal Principles

These work identically for ANY AI provider:

1. **Role Clarity** - Define who the AI should be
2. **Task Specificity** - Be explicit about what you want
3. **Context Provision** - Provide necessary background
4. **Examples** - Show, don't just tell (most powerful!)
5. **Output Format** - Specify structure explicitly
6. **Decomposition** - Break complex tasks into steps
7. **Reasoning Prompt** - Give time to think step-by-step

**See:** `references/universal-principles.md` for complete synthesis of all three providers

### The 90/10 Rule

**90% of prompting success:**
- ✅ Universal principles above (work everywhere)
- ✅ Provider-agnostic best practices
- ✅ Fundamental to how LLMs work

**10% of improvement:**
- ⚠️ Provider-specific optimizations
- ⚠️ Model-specific quirks
- ⚠️ API-specific features

**Focus on the 90% first!** Only optimize for specific providers if you need that extra 10%.

**Official validation:** All three major AI providers (OpenAI, Google, Anthropic) independently reached the same conclusions through empirical testing.

---

## Provider-Specific Guides

For the remaining 10% optimization:

### OpenAI Six Strategies

**Source:** platform.openai.com/docs/guides/prompt-engineering (2025)

1. **Write Clear Instructions**
   - Be specific and detailed
   - Specify steps to complete task
   - Provide examples
   - Specify desired length

2. **Provide Reference Text**
   - Instruct model to answer using reference
   - Include citations from reference
   - Ground answers in provided information

3. **Split Complex Tasks into Simpler Subtasks**
   - Decompose workflows
   - Use intent classification for dialogue
   - Summarize long documents piecewise

4. **Give GPTs Time to "Think"**
   - Instruct model to work out solution before concluding
   - Use inner monologue/chain of queries
   - Ask if model missed anything on previous pass

5. **Use External Tools**
   - Use embeddings-based search for knowledge retrieval
   - Use code execution for accurate calculation
   - Give model access to specific functions

6. **Test Changes Systematically**
   - Evaluate performance with reference to gold-standard answers
   - Measure performance across representative examples

### Google Gemini Four Elements

**Source:** ai.google.dev/gemini-api/docs/prompting-strategies (2025)

1. **Persona (Role)**
   - Define who the AI should be
   - Example: "You are an expert Python developer"

2. **Task (Clear Instruction)**
   - What you want the model to do
   - Be specific and actionable
   - Example: "Write a function that filters active users"

3. **Context (Background Information)**
   - Provide relevant background
   - Include constraints
   - Show input data structure

4. **Format (Output Structure)**
   - Specify how output should look
   - Include prefixes (Input:, Output:, JSON:)
   - Show pattern with examples

**Key Gemini Recommendation:**
> "We recommend to always include few-shot examples in your prompts. Prompts without few-shot examples are likely to be less effective."

### GPT-4.1 Specific Guidance

**Source:** cookbook.openai.com/examples/gpt4-1_prompting_guide (April 2025)

**For Agentic Workflows:**
1. **Persistence**: Model understands multi-turn interaction
2. **Tool-calling**: Encourage full tool utilization
3. **Planning**: Prompt explicit step-by-step reasoning

**Long Context (1M tokens):**
- Place instructions at BOTH beginning AND end of context
- Better performance with dual-placement

**Structure Template:**
```
# Role and Objective
# Instructions
## Sub-categories for detailed guidance
# Reasoning Steps
# Output Format
# Examples
# Context
# Final step-by-step thinking prompt
```

**Delimiter Recommendations:**
- Markdown: Best starting point (clear hierarchy)
- XML: Strong for nested structures
- JSON: Avoid for document collections (poor performance)

### Temperature Settings

**From official docs:**

- **OpenAI:** "For factual use cases such as data extraction and truthful Q&A, the temperature of 0 is best."
- **Gemini:** "Temperature controls randomness (0 = deterministic; higher = more creative)"

**Recommendations:**
- Code generation: 0-0.2
- Data extraction: 0
- Analysis: 0.3-0.5
- Creative tasks: 0.7-0.9
- Brainstorming: 0.8-1.0

## Block System

Reusable prompt components in `blocks/` directory:

- `role.md` - Persona definitions
- `task.md` - Task instruction templates
- `context.md` - Context structure patterns
- `examples.md` - Few-shot example formats
- `output-format.md` - Output structure templates
- `constraints.md` - Common constraints
- `index.yml` - Standard block combinations

See `blocks/index.yml` for preset combinations.

## Templates

Pre-built templates in `templates/` directory:

- `code-generation.md` - Complete end-to-end example
- More templates added in Phase 2+

## Provider-Specific Optimizations (Phase 2)

**NEW in Phase 2:** Comprehensive provider-specific guides with model comparisons, parameter recommendations, and cross-provider prompt conversion.

See `references/` directory:

- `openai-specifics.md` - **OpenAI comprehensive guide**
  - 6 core strategies in detail
  - GPT-4.1, GPT-4 Turbo, GPT-3.5 optimizations
  - Temperature guidelines (official: 0 for factual)
  - Tool calling best practices
  - Long context handling (1M tokens)

- `gemini-specifics.md` - **Gemini comprehensive guide**
  - 4-element framework (Persona, Task, Context, Format)
  - Few-shot examples (official: always include)
  - Multimodal prompting (images, video, audio)
  - Prefix patterns (Input:, Output:, JSON:)
  - Parameter optimization (temperature, top-K, top-P)

- `anthropic-specifics.md` - **⭐ NEW: Anthropic comprehensive guide**
  - 9 techniques (recommended order)
  - XML tags (strong preference for Claude)
  - Response prefilling (unique to Claude)
  - Chain of Thought emphasis
  - Long context optimization

- `provider-switcher.md` - **Cross-provider conversion**
  - Convert prompts between OpenAI, Gemini, Claude
  - Provider selection guide
  - Side-by-side comparisons
  - Conversion checklists

- `quality-rubric.md` - Prompt quality checklist (9 criteria)
- `anti-patterns.md` - Common mistakes to avoid (40+ patterns)

### Quick Provider Selection

**Choose OpenAI when:**
- Complex reasoning, tool calling, agentic workflows
- Code generation (especially GPT-4.1)
- Systematic problem decomposition

**Choose Gemini when:**
- Multimodal inputs (images, video)
- Very long context (1M tokens efficiently)
- Google Workspace integration
- Cost-effective simple tasks

**Choose Claude when:**
- Long-form analysis, document understanding
- Nuanced reasoning, ethical considerations
- Very long context (200K tokens native)
- Structured data extraction with XML

## Example: Code Generation Workflow

**User Request:** "Python 함수 만들어줘"

**Skill Response:**

```
Step 1: Let me understand your goal.
→ You selected: Code Generation

Step 2: More details needed.
What should this function do? Be specific:
- Input parameters?
- Output/return value?
- Any special requirements?

[User provides: "리스트에서 'status'가 'active'인 항목만 필터링하고 'created_at'으로 정렬"]

Step 3: Which AI are you using?
→ ChatGPT (GPT-4)

Step 4: Generating optimized prompt...

=== Generated Prompt ===

You are an expert Python developer writing production-quality code.

TASK:
Write a Python function that:
- Takes a list of dictionaries as input
- Filters items where 'status' == 'active'
- Returns sorted by 'created_at' descending
- Include type hints and comprehensive docstring
- Handle edge cases (empty list, None values, missing keys)

INPUT EXAMPLE:
```python
users = [
    {'id': 1, 'status': 'active', 'created_at': '2025-01-15'},
    {'id': 2, 'status': 'inactive', 'created_at': '2025-01-14'},
    {'id': 3, 'status': 'active', 'created_at': '2025-01-16'}
]
```

OUTPUT EXAMPLE:
```python
[
    {'id': 3, 'status': 'active', 'created_at': '2025-01-16'},
    {'id': 1, 'status': 'active', 'created_at': '2025-01-15'}
]
```

REQUIREMENTS:
- Use Python 3.10+ features
- Follow PEP 8 style guide
- Include error handling
- Add unit test example

OUTPUT FORMAT:
Provide complete function implementation with:
1. Type hints
2. Docstring (Google style)
3. Implementation
4. Usage example
5. One unit test

Think step by step about edge cases before implementing.

=== Quality Check ===
✓ Clear objective (8/10)
✓ Sufficient context (9/10)
✓ Examples included (10/10)
✓ Output format specified (9/10)
✓ Model-appropriate (10/10)

Score: 9/10 - Excellent

=== Optimizations Applied ===
- OpenAI: Temperature 0 for code (factual task)
- Added "Think step by step" (GPT-4 CoT prompting)
- Included input/output examples (Gemini best practice)
- Structured with clear sections (GPT-4.1 template)
- Specified format explicitly (both providers recommend)
```

## Common Anti-Patterns

From `references/anti-patterns.md`:

❌ **Vague Task**
```
"Write some Python code"
```

✅ **Specific Task**
```
"Write a Python function that validates email addresses using regex"
```

---

❌ **No Examples**
```
"Convert this data to JSON"
```

✅ **With Examples**
```
"Convert this data to JSON format.

Input: name=John, age=30
Output: {"name": "John", "age": 30}
```

---

❌ **Ambiguous Role**
```
"Help me with this code"
```

✅ **Clear Role**
```
"You are a senior Python developer reviewing code for performance issues."
```

---

❌ **Missing Output Format**
```
"Analyze this code"
```

✅ **Specified Format**
```
"Analyze this code and provide:
1. List of issues
2. Severity (high/medium/low)
3. Suggested fixes
4. Updated code"
```

## Advanced Features

### Iterative Refinement (Phase 4)

1. Generate initial prompt
2. Test with actual AI
3. Evaluate results
4. Suggest improvements
5. Regenerate optimized version

### Provider Switcher (Phase 2)

Show how same intent differs across providers:
- OpenAI version (emphasize CoT, structured output)
- Gemini version (4-element structure, prefixes)
- Claude version (XML, detailed context)

### Prompt Library (Phase 4)

Save successful prompts for reuse:
```
.prompt-engineer/
└── saved-prompts/
    ├── code-generation/
    ├── data-extraction/
    └── analysis/
```

## Troubleshooting

### "Generated prompt is too long"

- Use simpler language
- Remove unnecessary examples
- Focus on essential context
- Consider model's context limit

### "Results are inconsistent"

- Lower temperature (especially for factual tasks)
- Add more specific constraints
- Include more few-shot examples
- Use explicit output format

### "Model doesn't follow instructions"

- Put instructions at END of prompt (GPT-4.1 tip)
- Use delimiters (###, ---, <tags>)
- Repeat critical instructions
- Add "Think step by step" for complex tasks

## Best Practices Summary

✅ **Do:**
- Always include examples (Gemini official recommendation)
- Specify output format explicitly
- Use temperature 0 for factual tasks (OpenAI official)
- Break complex tasks into subtasks (OpenAI strategy #3)
- Test systematically (OpenAI strategy #6)
- Use clear delimiters (Markdown/XML for GPT-4.1)

❌ **Don't:**
- Assume model has knowledge without providing context
- Use JSON for document collections (GPT-4.1 tested poorly)
- Force tool calls without context (causes hallucination)
- Rely on "bribery" tactics unless necessary
- Forget to specify constraints

## Resources

### Official Documentation

**OpenAI:**
- Main Guide: platform.openai.com/docs/guides/prompt-engineering
- GPT-4.1: cookbook.openai.com/examples/gpt4-1_prompting_guide
- Best Practices: help.openai.com/en/articles/6654000

**Google Gemini:**
- Main Guide: ai.google.dev/gemini-api/docs/prompting-strategies
- Vertex AI: cloud.google.com/vertex-ai/generative-ai/docs/learn/prompts

**Anthropic Claude:**
- Main Guide: docs.claude.com/en/docs/build-with-claude/prompt-engineering/overview
- Interactive Tutorial: github.com/anthropics/prompt-eng-interactive-tutorial

### Skill Components

- `blocks/` - Reusable prompt components
- `templates/` - Complete prompt templates
- `references/` - Provider-specific guides
- `examples/` - Real-world examples

## Limitations

This skill cannot:
- Guarantee perfect results (prompting is iterative)
- Replace domain expertise
- Test prompts automatically (user must test)
- Access real-time model updates

**Remember:** Prompt engineering is an iterative process. Start with generated prompt, test, and refine based on results.

---

**Version:** 2.0 (Phase 2 Complete + Anthropic Integration)
**Created:** 2025-01-29
**Last Updated:** 2025-01-29
**Based on:** OpenAI, Google Gemini & Anthropic Claude Official Documentation (2025)
