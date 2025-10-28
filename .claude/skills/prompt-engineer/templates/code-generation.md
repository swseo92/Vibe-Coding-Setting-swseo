# Code Generation Template

Complete end-to-end example demonstrating prompt engineering best practices for code generation tasks.

## Use Case

Generate production-quality code based on requirements.

## User Request Example

"Python 함수 만들어줘 - 리스트에서 active 상태인 항목만 필터링하고 날짜순 정렬"

## Workflow

### Step 1: Gather Requirements

**Questions to ask:**
1. What programming language?
2. What should the code do? (Be specific)
3. Input/output format?
4. Any special requirements? (error handling, performance, style)
5. Which AI are you using?

**Example Answers:**
- Language: Python 3.10+
- Function: Filter active users, sort by date
- Input: List of dictionaries
- Output: Filtered and sorted list
- Requirements: Type hints, docstring, error handling
- AI: ChatGPT (GPT-4)

### Step 2: Generate Optimized Prompt

Based on official best practices:

```markdown
=== OPTIMIZED PROMPT ===

You are an expert Python developer writing production-quality code.

TASK:
Write a Python function with the following specification:

**Function Purpose:**
Filter a list of user dictionaries to include only active users, then sort by creation date in descending order.

**Input:**
- Parameter name: `users`
- Type: `List[Dict[str, Any]]`
- Structure:
  ```python
  [
      {'id': int, 'status': str, 'created_at': str, ...},
      {'id': int, 'status': str, 'created_at': str, ...}
  ]
  ```

**Output:**
- Return type: `List[Dict[str, Any]]`
- Filtered list (only status='active')
- Sorted by 'created_at' descending (newest first)

**INPUT EXAMPLE:**
```python
users = [
    {'id': 1, 'name': 'Alice', 'status': 'active', 'created_at': '2025-01-15'},
    {'id': 2, 'name': 'Bob', 'status': 'inactive', 'created_at': '2025-01-14'},
    {'id': 3, 'name': 'Charlie', 'status': 'active', 'created_at': '2025-01-16'},
    {'id': 4, 'name': 'David', 'status': 'active', 'created_at': '2025-01-10'}
]
```

**EXPECTED OUTPUT:**
```python
[
    {'id': 3, 'name': 'Charlie', 'status': 'active', 'created_at': '2025-01-16'},
    {'id': 1, 'name': 'Alice', 'status': 'active', 'created_at': '2025-01-15'},
    {'id': 4, 'name': 'David', 'status': 'active', 'created_at': '2025-01-10'}
]
```

**REQUIREMENTS:**
1. Use Python 3.10+ features (type hints with Union/Optional if needed)
2. Follow PEP 8 style guide
3. Include comprehensive docstring (Google style)
4. Handle edge cases:
   - Empty list input
   - None values
   - Missing 'status' or 'created_at' keys
   - Invalid date formats
5. Consider performance (efficient filtering and sorting)
6. Add error handling with appropriate exceptions

**OUTPUT FORMAT:**
Provide the complete solution including:

1. **Function Implementation** with:
   - Type hints
   - Docstring (Google style with Args, Returns, Raises sections)
   - Error handling
   - Clean, readable code

2. **Usage Example** showing how to call the function

3. **Unit Test Example** (using pytest) covering:
   - Normal case
   - Empty list
   - Missing keys
   - Edge cases

**APPROACH:**
Before writing code, think step by step:
1. What edge cases need handling?
2. What validation is needed?
3. What's the most efficient approach?
4. What error types are appropriate?

Then provide your complete implementation.

=== END PROMPT ===
```

### Step 3: Quality Check

**Using official rubric:**

| Criterion | Score | Notes |
|-----------|-------|-------|
| Clear objective | 10/10 | Specific function purpose stated |
| Sufficient context | 10/10 | Input/output format, requirements clear |
| Examples included | 10/10 | Input and expected output provided |
| Output format specified | 10/10 | Detailed structure for response |
| Model-appropriate | 10/10 | Suitable for GPT-4 capabilities |
| Role defined | 10/10 | "Expert Python developer" |
| Constraints clear | 9/10 | Style, error handling, edge cases |
| Success criteria | 9/10 | Requirements and tests specified |
| Thinking prompted | 10/10 | "Think step by step" included |

**Total Score: 9.8/10 - Excellent**

### Step 4: Optimizations Applied

**From OpenAI Guidelines:**
- ✅ Clear instructions (Strategy #1): Specific task breakdown
- ✅ Reference text (Strategy #2): Example input/output provided
- ✅ Think step by step (Strategy #4): "Before writing code, think..."
- ✅ Temperature 0: Recommended for code generation (factual task)

**From Gemini Guidelines:**
- ✅ Persona: "Expert Python developer"
- ✅ Task: Clearly defined with specification
- ✅ Context: Input structure, requirements, constraints
- ✅ Format: Explicit output structure (implementation + example + test)
- ✅ Few-shot: Example input/output provided

**From GPT-4.1 Guidelines:**
- ✅ Structured format: Role → Task → Examples → Requirements → Format
- ✅ Long context handling: Instructions at beginning (end not needed for short prompt)
- ✅ Clear delimiters: Markdown sections for organization

## Expected Result Quality

**Before (naive prompt):**
```
"Python 함수 만들어줘"
```
Result: Vague, may not include error handling, unclear requirements, multiple iterations needed.

**After (optimized prompt):**
Complete, production-ready function with:
- Type hints
- Comprehensive docstring
- Error handling
- Edge case coverage
- Unit tests
- Usage examples

**Time Saved:**
- Without optimization: 3-5 iterations, 10-15 minutes
- With optimization: 1 iteration, 2-3 minutes
- **Savings: 70-80% time reduction**

## Variations for Different Languages

### JavaScript/TypeScript
Replace Python-specific elements:
- TypeScript interfaces instead of type hints
- JSDoc instead of Google-style docstring
- Jest instead of pytest
- Consider async/await if applicable

### Go
Adjust for Go conventions:
- Struct definitions
- Error return values (result, error pattern)
- Go testing package
- Naming conventions (camelCase)

### Rust
Rust-specific features:
- Result<T, E> types
- Ownership and borrowing notes
- Rust testing framework
- Cargo conventions

## Model-Specific Adjustments

### For GPT-3.5
- Simplify requirements (less complex edge cases)
- More explicit step-by-step guidance
- Shorter context

### For GPT-4 Turbo
- Can handle longer context
- More sophisticated requirements
- Multiple related functions

### For Gemini Pro
- Emphasize 4-element structure more explicitly
- Use prefixes (Input:, Output:)
- May need more few-shot examples

## Common Issues & Solutions

### Issue: Generated code lacks error handling

**Solution:** Add explicit requirement:
```
REQUIREMENTS:
- Include try-except blocks for:
  - Missing keys (KeyError)
  - Invalid date formats (ValueError)
  - Type mismatches (TypeError)
- Provide meaningful error messages
```

### Issue: Inconsistent code style

**Solution:** Reference specific style guide:
```
STYLE REQUIREMENTS:
- Follow PEP 8 (link: python.org/dev/peps/pep-0008/)
- Use black formatter defaults
- Maximum line length: 88 characters
- Use double quotes for strings
```

### Issue: Missing test cases

**Solution:** Specify test coverage:
```
TESTING:
Include pytest tests covering:
1. Happy path (valid input)
2. Empty list
3. All items filtered out
4. Missing 'status' key → should raise ValueError
5. Missing 'created_at' key → should raise ValueError
6. Invalid date format → should raise ValueError
7. None input → should raise TypeError
```

## Best Practices Summary

✅ **Always Include:**
1. Clear role/persona
2. Specific task description
3. Input/output examples
4. Requirements list
5. Output format specification
6. Edge case handling
7. "Think step by step" prompt

❌ **Avoid:**
1. Vague requirements
2. Missing examples
3. Unspecified output format
4. Ignoring edge cases
5. No error handling requirements

## References

**Official Documentation:**
- OpenAI Guide: platform.openai.com/docs/guides/prompt-engineering
- GPT-4.1 Guide: cookbook.openai.com/examples/gpt4-1_prompting_guide
- Gemini Guide: ai.google.dev/gemini-api/docs/prompting-strategies

**This template demonstrates Phase 1 MVP - complete end-to-end prompt engineering workflow based on official best practices.**
