# Anthropic Claude Prompt Engineering Guide

Comprehensive guide to Claude-specific optimizations based on official Anthropic documentation (10% differentiation).

**Official Source:** docs.claude.com/en/docs/build-with-claude/prompt-engineering/overview

---

## Overview: Why Prompt Engineering Over Fine-Tuning

Anthropic emphasizes that **prompt engineering is far faster** than alternatives:

**Benefits:**
- ✅ Nearly instantaneous results (vs hours of GPU training)
- ✅ Resource efficiency without high-end hardware requirements
- ✅ Full transparency in what information the model receives
- ✅ Preservation of general knowledge capabilities
- ✅ Compatibility across model updates
- ✅ Lower costs than fine-tuning approaches

---

## The 9 Core Techniques (Anthropic's Recommended Order)

Try these sequentially, from most to least broadly effective:

### 1. Prompt Generator
### 2. Be Clear and Direct *(Universal)*
### 3. Multishot Prompting *(Universal)*
### 4. Chain of Thought *(Universal)*
### 5. **XML Tags** ⭐ *Claude-Specific*
### 6. System Prompts *(Universal)*
### 7. **Response Prefilling** ⭐ *Claude-Specific*
### 8. Prompt Chaining *(Universal)*
### 9. **Long Context Tips** ⭐ *Claude-Specific*

---

## Claude-Specific Optimizations (10%)

### XML Tags for Structure

**Why Claude Prefers XML:**
Claude has a strong preference for XML over other delimiter systems.

**Pattern:**
```xml
<instructions>
Analyze the code for performance issues.
Focus on time complexity and memory usage.
</instructions>

<code>
def process_data(items):
    result = []
    for item in items:
        for other in items:
            if item != other:
                result.append((item, other))
    return result
</code>

<output_format>
1. Time complexity analysis
2. Bottlenecks identified
3. Optimized implementation
</output_format>
```

**Common Tags:**
- `<instructions>` - What to do
- `<context>` - Background information
- `<example>` - Sample input/output
- `<code>` - Code to analyze
- `<document>` - Long text content
- `<output_format>` - Expected structure
- `<thinking>` - Reasoning space

**Benefits:**
- Clear semantic boundaries
- Hierarchical structure
- Easy to reference specific sections
- Reduces ambiguity between instructions and content

---

### Response Prefilling

**Unique to Claude API:**
Start Claude's response to guide format and tone.

**How It Works:**
```markdown
User: "Analyze this code for security issues."