# Prompt Engineer Skill

Generate high-quality prompts based on official best practices from **OpenAI, Google Gemini, and Anthropic Claude**.

## Quick Start

Just say:
```
"프롬프트 만들어줘 - Python 함수 작성용"
"Create a prompt for code review"
"Optimize this prompt for ChatGPT"
```

## What This Skill Does

**NEW: Universal Approach (90/10 Rule)**

This skill focuses on **universal principles** that work across ALL AI providers:

1. **Extracts universal best practices** (90%+) from OpenAI + Gemini + Anthropic
2. **Asks smart questions** to understand your goal
3. **Generates provider-agnostic prompts** that work everywhere
4. **Checks quality** using universal rubrics
5. **Optionally optimizes** for specific providers (that extra 10%)

**Key Insight:** All three major AI providers (OpenAI, Google, Anthropic) independently reached the same conclusions! The same prompt works great on ChatGPT, Gemini, and Claude.

## Files Structure

```
prompt-engineer/
├── skill.md                        # Main guide (START HERE)
├── README.md                       # This file
│
├── blocks/
│   └── index.yml                  # Reusable prompt components
│
├── templates/
│   ├── universal-template.md     # ⭐ NEW: Works on ALL providers
│   └── code-generation.md         # Complete end-to-end example
│
└── references/
    ├── universal-principles.md        # ⭐ 90% that works everywhere
    ├── openai-specifics.md            # OpenAI 10% optimization
    ├── gemini-specifics.md            # Gemini 10% optimization
    ├── anthropic-specifics.md         # ⭐ Anthropic 10% optimization
    ├── provider-switcher.md           # Cross-provider conversion
    ├── quality-rubric.md              # How to evaluate prompts
    ├── anti-patterns.md               # Common mistakes to avoid
    └── negative-examples-research.md  # ⭐ NEW: Research on negative few-shot
```

## Example Usage

### Before
```
User: "Python 함수 만들어줘"
AI: (Vague, unclear implementation)
```

### After (Using This Skill)
```
User: "프롬프트 만들어줘 - Python 함수 작성용"

Skill:
1. What should the function do? → "Filter active users, sort by date"
2. Which AI? → "ChatGPT"
3. Any constraints? → "Type hints, tests required"

Generated Prompt:
---
You are an expert Python developer.

TASK:
Write a function that:
- Filters users where status='active'
- Sorts by created_at descending
- Includes type hints and docstring
- Handles edge cases

INPUT EXAMPLE:
[{'id': 1, 'status': 'active', 'created_at': '2025-01-15'}, ...]

OUTPUT EXAMPLE:
[{'id': 3, ...}, {'id': 1, ...}]

REQUIREMENTS:
- PEP 8 compliant
- Error handling
- Include unit test

Think step by step before implementing.
---

Quality Score: 9/10 ✓

Result: Production-ready code in one iteration!
```

## Based On Official Documentation

**Sources (2025):**
- ✅ OpenAI Prompt Engineering Guide
- ✅ OpenAI GPT-4.1 Prompting Guide
- ✅ Google Gemini Prompt Design Strategies
- ✅ Google Vertex AI Prompting Guide
- ✅ Anthropic Claude Prompt Engineering Overview

## Key Features

### 1. Universal Principles (NEW!)
- **7 Universal Principles** that work across ALL providers:
  1. Role Clarity
  2. Task Specificity
  3. Context Provision
  4. Examples (most powerful!)
  5. Output Format
  6. Decomposition
  7. Reasoning Prompt

- **90/10 Rule:** 90% universal, 10% provider-specific
- **Single template** works on ChatGPT, Gemini, Claude

### 2. Official Best Practices
- **OpenAI 6 Strategies:** Clear instructions, reference text, split tasks, think step-by-step, external tools, systematic testing
- **Gemini 4 Elements:** Persona, Task, Context, Format
- **Anthropic 9 Techniques:** Clear & direct, multishot examples, Chain of Thought, XML tags, system prompts, prefilling, chaining, long context
- **Convergence:** All three independently reached the same 90%+ conclusions!

### 3. Provider Optimization (10%)
- OpenAI-specific tips (CoT, tool calling)
- Gemini-specific tips (few-shot examples, prefixes)
- Anthropic-specific tips (XML tags, response prefilling, long context)
- Model constraints (context limits, capabilities)

### 4. Quality Assurance
- 9-point rubric (Essential + Recommended + Advanced)
- Score 0-10 with detailed feedback
- Improvement suggestions

### 5. Anti-Pattern Detection & Research
- Identifies common mistakes
- Provides before/after examples
- Explains why each matters
- **Research-backed:** Using negative examples in few-shot prompts
  - Math reasoning: **+20-53%** improvement (proven)
  - Code review: **+15-25%** improvement (estimated)
  - Symbolic tasks: **+6-10%** improvement (proven)

## Use Cases

✅ **Code Generation** - Write, refactor, debug code
✅ **Data Extraction** - Parse, extract, transform data
✅ **Code Review** - Analyze quality, performance, security
✅ **Analysis** - Technical evaluation and insights
✅ **Creative** - Documentation, naming, brainstorming
✅ **Reasoning** - Architecture decisions, trade-offs

## Development Status

**Phase 1: MVP (COMPLETED) ✅**
- ✅ Core skill.md with decision tree
- ✅ blocks/index.yml (reusable components)
- ✅ templates/code-generation.md (end-to-end example)
- ✅ references/quality-rubric.md
- ✅ references/anti-patterns.md

**Phase 2: Provider Specialization (COMPLETED) ✅**
- ✅ references/universal-principles.md - **Universal framework (v2.0)**
  - Synthesis of OpenAI + Gemini + Anthropic best practices
  - 7 principles that work everywhere
  - 90/10 rule (universal vs provider-specific)
  - Evidence of convergence between all three providers
- ✅ references/openai-specifics.md - OpenAI 10% optimization
  - 6 strategies in detail
  - Model-specific tips (GPT-4.1, Turbo, 3.5)
  - Temperature guidelines, tool calling, long context
- ✅ references/gemini-specifics.md - Gemini 10% optimization
  - 4-element framework
  - Multimodal prompting
  - Parameter optimization
- ✅ references/anthropic-specifics.md - **⭐ NEW: Anthropic 10% optimization**
  - 9 techniques (XML tags, prefilling, long context)
  - Claude-specific best practices
  - Response structure guidance
- ✅ references/provider-switcher.md - Cross-provider conversion
  - OpenAI ↔ Gemini ↔ Claude
  - Side-by-side comparisons
  - When to use provider-specific features
- ✅ templates/universal-template.md - **Provider-agnostic template**
  - Works on ChatGPT, Gemini, Claude
  - 3 complete examples
  - Variations (minimal, standard, comprehensive)

**Phase 3: Quality Management (TODO)**
- [ ] Automated quality scoring
- [ ] Interactive refinement
- [ ] More templates (data extraction, analysis, creative)

**Phase 4: Advanced (FUTURE)**
- [ ] Iterative refinement workflow
- [ ] Prompt library
- [ ] Version tracking
- [ ] A/B testing support

## Quick Reference

### Temperature Settings (Official Guidelines)

| Task Type | Temperature | Source |
|-----------|-------------|--------|
| Code generation | 0.0-0.2 | OpenAI official |
| Data extraction | 0.0 | OpenAI official |
| Analysis | 0.3-0.5 | Common practice |
| Creative writing | 0.7-0.9 | Both providers |
| Brainstorming | 0.8-1.0 | Both providers |

### Essential Checklist

Every good prompt should have:
- [ ] Clear objective (what to do)
- [ ] Sufficient context (background, inputs)
- [ ] Output format specified
- [ ] Examples (input/output)
- [ ] Role/persona defined

### Common Anti-Patterns

❌ Vague: "Write some code"
❌ No examples: "Convert data"
❌ No format: "Analyze this"
❌ No role: "Help me"
❌ Wrong temperature: High for factual tasks

✅ Specific: "Write Python email validator"
✅ With examples: Input → Output shown
✅ With format: Structured sections specified
✅ With role: "You are an expert..."
✅ Right temperature: 0 for code/facts

## Testing

To test this skill:

1. **Simple test:**
   ```
   "프롬프트 만들어줘 - 간단한 Python 함수"
   ```

2. **Complex test:**
   ```
   "ChatGPT용 코드 리뷰 프롬프트 만들어줘
   - 성능과 보안 중점
   - 상세한 피드백 필요
   - 개선 코드 포함"
   ```

3. **Improvement test:**
   ```
   "이 프롬프트 개선해줘: '파이썬 함수 만들어줘'"
   ```

Expected: Detailed prompts with examples, structure, and high quality scores.

## Contributing

To improve this skill:

1. Test with real use cases
2. Add more templates (templates/)
3. Document provider-specific tips (references/)
4. Share successful prompts as examples

## Support

**Documentation:**
- Main guide: `skill.md`
- Example: `templates/code-generation.md`
- Quality check: `references/quality-rubric.md`
- Avoid mistakes: `references/anti-patterns.md`

**Official Sources:**
- OpenAI: platform.openai.com/docs/guides/prompt-engineering
- Gemini: ai.google.dev/gemini-api/docs/prompting-strategies
- Anthropic: docs.claude.com/en/docs/build-with-claude/prompt-engineering/overview

## License

This skill is based on publicly available official documentation from OpenAI, Google, and Anthropic.

## Version

- **Version:** 2.0 (Phase 2 Complete + Anthropic Integration)
- **Created:** 2025-01-29
- **Updated:** 2025-01-29
- **Status:** Production-ready
- **Next:** Phase 3 (Quality Management)

---

**Start with:** Read `skill.md` for full guide, or try `templates/code-generation.md` for a complete example!
