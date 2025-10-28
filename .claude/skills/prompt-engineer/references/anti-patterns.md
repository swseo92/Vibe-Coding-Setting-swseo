# Prompt Engineering Anti-Patterns

Common mistakes to avoid when writing prompts, based on official guidelines and real-world failures.

## Category 1: Vague Instructions

### Anti-Pattern: Generic Task

❌ **Bad:**
```
"Write some code"
"Help me with Python"
"Fix this"
```

✅ **Good:**
```
"Write a Python function that validates email addresses using regex"
"Help me optimize this Python function for performance"
"Fix the IndexError in line 15 of this sorting function"
```

**Why it matters:**
- Vague prompts lead to generic, often unhelpful responses
- Wastes time in multiple iterations
- **OpenAI Strategy #1:** "Write clear instructions"

---

### Anti-Pattern: Assumed Context

❌ **Bad:**
```
"Implement the login feature"
(Assumes model knows your tech stack, requirements, etc.)
```

✅ **Good:**
```
"Implement a login feature using:
- Django REST Framework
- JWT authentication
- PostgreSQL user table
- Rate limiting (5 attempts per hour)
- Return user profile on success"
```

**Why it matters:**
- Models don't have access to your codebase or context
- **OpenAI Strategy #2:** "Provide reference text"
- **Gemini Element:** "Context (background information)"

---

## Category 2: Missing Examples

### Anti-Pattern: No Input/Output Samples

❌ **Bad:**
```
"Convert dates to ISO format"
```

✅ **Good:**
```
"Convert dates to ISO format (YYYY-MM-DD).

Examples:
Input: "Jan 15, 2025" → Output: "2025-01-15"
Input: "15/01/2025" → Output: "2025-01-15"
Input: "2025.1.15" → Output: "2025-01-15"
```

**Why it matters:**
- Examples dramatically improve output quality
- **Gemini Official:** "We recommend to always include few-shot examples"
- Shows exact format you want

---

### Anti-Pattern: Showing What NOT to Do

❌ **Bad:**
```
"Don't write code like this:
def bad_function():
    pass  # Avoid this pattern"
```

✅ **Good:**
```
"Write code following this pattern:
def good_function(data: List[Dict]) -> List[Dict]:
    '''Clear docstring explaining purpose'''
    # Implementation here
    return processed_data"
```

**Why it matters:**
- Models may copy negative examples
- **Gemini Guide:** "Always show positive patterns to follow"
- Focus on desired behavior, not anti-patterns

---

## Category 3: Poor Structure

### Anti-Pattern: Wall of Text

❌ **Bad:**
```
"I need you to write a function that takes a list and filters it based on status being active and then sorts by date descending and handles errors and returns the result and also include tests and make sure it follows PEP 8 and uses type hints"
```

✅ **Good:**
```
"Write a Python function with following specification:

INPUT:
- List of dictionaries with 'status' and 'date' keys

PROCESSING:
- Filter where status == 'active'
- Sort by date descending

REQUIREMENTS:
- Error handling for missing keys
- Type hints
- PEP 8 compliant
- Include unit tests

OUTPUT:
- Filtered and sorted list"
```

**Why it matters:**
- Clear structure improves model understanding
- **GPT-4.1:** "Use markdown for clear hierarchical titles"
- Easier to parse and follow

---

### Anti-Pattern: No Output Format

❌ **Bad:**
```
"Analyze this code"
```

✅ **Good:**
```
"Analyze this code and provide:

1. **Issues Found** (bullet list)
   - Issue description
   - Severity (high/medium/low)
   - Line numbers

2. **Recommendations** (numbered list)
   - Suggested fixes
   - Code examples

3. **Updated Code** (full implementation)"
```

**Why it matters:**
- Specifies exactly what you need
- **Both providers:** Emphasize explicit format specification
- Reduces need for follow-up prompts

---

## Category 4: Role Confusion

### Anti-Pattern: No Persona

❌ **Bad:**
```
"Review this code"
```

✅ **Good:**
```
"You are a senior backend engineer with expertise in Python and database optimization.

Review this code focusing on:
- SQL query performance
- N+1 query patterns
- Connection pooling issues"
```

**Why it matters:**
- Persona shapes response perspective
- **Gemini Element:** "Persona (who the AI should be)"
- Provides context for evaluation criteria

---

### Anti-Pattern: Contradictory Roles

❌ **Bad:**
```
"You are a beginner learning Python. Also you are an expert. Write production code."
```

✅ **Good:**
```
"You are an expert Python developer writing production-ready code with clear explanations suitable for junior developers to understand."
```

**Why it matters:**
- Conflicting instructions confuse the model
- **GPT-4.1:** "Check for conflicting instructions"
- Clear single persona is more effective

---

## Category 5: Temperature Misuse

### Anti-Pattern: High Temperature for Factual Tasks

❌ **Bad:**
```
"Extract exact data from this JSON"
(Using temperature 0.9)
```

✅ **Good:**
```
"Extract exact data from this JSON"
(Using temperature 0.0)
```

**Why it matters:**
- **OpenAI Official:** "For factual tasks, temperature of 0 is best"
- High temperature introduces unnecessary randomness
- Inconsistent results across runs

---

### Anti-Pattern: Zero Temperature for Creative Tasks

❌ **Bad:**
```
"Brainstorm 10 creative project names"
(Using temperature 0.0)
```

✅ **Good:**
```
"Brainstorm 10 creative project names"
(Using temperature 0.7-0.9)
```

**Why it matters:**
- Creativity requires some randomness
- Temperature 0 produces repetitive, predictable outputs
- Higher temperature enables diverse ideas

---

## Category 6: Complex Task Handling

### Anti-Pattern: Monolithic Request

❌ **Bad:**
```
"Build a complete e-commerce API with user auth, product catalog, shopping cart, payment processing, order management, and analytics"
```

✅ **Good:**
```
"Step 1: Design the user authentication system
- JWT-based auth
- User registration endpoint
- Login endpoint
- Token refresh

(Complete Step 1 before moving to Step 2: Product Catalog)"
```

**Why it matters:**
- **OpenAI Strategy #3:** "Split complex tasks into simpler subtasks"
- Reduces errors
- Easier to verify each component

---

### Anti-Pattern: No Planning Prompt

❌ **Bad:**
```
"Implement a caching system"
(Directly asks for implementation)
```

✅ **Good:**
```
"Design a caching system. Before implementing, answer:

1. What data needs caching?
2. What invalidation strategy?
3. Memory vs. persistent storage?
4. Cache key structure?

Then provide implementation based on your analysis."
```

**Why it matters:**
- **OpenAI Strategy #4:** "Give GPTs time to think"
- **GPT-4.1:** "Prompt explicit step-by-step reasoning"
- Better quality through planning

---

## Category 7: Testing & Iteration

### Anti-Pattern: No Test Cases

❌ **Bad:**
```
"Write a validation function"
```

✅ **Good:**
```
"Write a validation function. Include tests for:
- Valid input (should pass)
- Invalid input (should fail)
- Edge cases (empty, null, extreme values)
- Type errors"
```

**Why it matters:**
- **OpenAI Strategy #6:** "Test changes systematically"
- Ensures correctness
- Documents expected behavior

---

### Anti-Pattern: No Iterative Refinement

❌ **Bad:**
```
(Using first output without evaluation)
```

✅ **Good:**
```
1. Generate initial solution
2. Test with sample data
3. Identify issues
4. Refine prompt with findings
5. Regenerate improved version
```

**Why it matters:**
- Prompt engineering is iterative
- First attempt rarely optimal
- Testing reveals gaps in specification

---

## Category 8: Model Limitations

### Anti-Pattern: Exceeding Context Limits

❌ **Bad:**
```
(Pasting 100k tokens of code for GPT-3.5 Turbo)
```

✅ **Good:**
```
"Here's the relevant 500-line module (full codebase available separately).
Focus analysis on this core logic."
```

**Why it matters:**
- Models have context limits (see quality-rubric.md for limits)
- Truncation leads to incomplete analysis
- Prioritize relevant context

---

### Anti-Pattern: Expecting Real-Time Knowledge

❌ **Bad:**
```
"What's the latest Python 3.13 feature released yesterday?"
```

✅ **Good:**
```
"Based on Python 3.12 features (or provide docs), explain..."
```

**Why it matters:**
- Models have knowledge cutoff dates
- Can't access real-time information
- **Provide reference text** for recent info

---

## Category 9: Provider-Specific Issues

### Anti-Pattern: Ignoring Provider Strengths

❌ **Bad:**
```
(Using Gemini for complex tool-calling workflow)
(Better suited for OpenAI GPT-4)
```

❌ **Bad:**
```
(Using GPT-4 for image analysis)
(Better suited for Gemini multimodal)
```

✅ **Good:**
```
Match task to provider strengths:
- OpenAI: Tool calling, function execution
- Gemini: Multimodal, workspace integration
- Claude: Long-form analysis, document processing
```

**Why it matters:**
- Different models have different strengths
- Using right tool for the job improves results

---

### Anti-Pattern: Ignoring Format Preferences

❌ **Bad (for GPT-4.1):**
```
Using JSON for large document collections
(GPT-4.1 testing showed poor performance)
```

✅ **Good (for GPT-4.1):**
```
Using Markdown or XML for document organization
(GPT-4.1 testing showed strong performance)
```

**Why it matters:**
- **GPT-4.1 Guide:** "Avoid JSON for document collections"
- Use formats optimized for specific models

---

## Category 10: Security & Safety

### Anti-Pattern: Accepting Unsafe Code Without Review

❌ **Bad:**
```
(Running generated code without inspection)
```

✅ **Good:**
```
1. Review generated code
2. Check for security issues (SQL injection, XSS, etc.)
3. Test in isolated environment
4. Validate inputs/outputs
5. Then deploy
```

**Why it matters:**
- AI can generate vulnerable code
- Always review for security
- Test before production

---

### Anti-Pattern: Exposing Sensitive Data in Prompts

❌ **Bad:**
```
"Analyze this database query:
SELECT * FROM users WHERE api_key='sk-prod-abc123xyz...'"
```

✅ **Good:**
```
"Analyze this database query:
SELECT * FROM users WHERE api_key='[REDACTED]'"
```

**Why it matters:**
- Prompts may be logged
- Protect credentials and sensitive data
- Use placeholders or sanitized examples

---

## Quick Reference: Common Fixes

| Problem | Anti-Pattern | Solution |
|---------|--------------|----------|
| Vague results | "Help me" | Specific task + context |
| Inconsistent output | No examples | Add input/output examples |
| Wrong format | Unspecified | Explicit format specification |
| Generic response | No persona | Define role/expertise |
| Factually wrong | High temperature | Temperature 0 for facts |
| Overcomplicated | Monolithic task | Break into subtasks |
| Missing edge cases | No test cases | Specify test requirements |

## Before/After Examples

### Example 1: Code Generation

**Before (Score: 2/10):**
```
"Python function"
```

**After (Score: 9/10):**
```
"You are an expert Python developer.

Write a function that:
- Validates email addresses
- Returns bool (True/False)
- Handles edge cases (empty, None, invalid format)

Examples:
- validate_email("user@example.com") → True
- validate_email("invalid.email") → False
- validate_email("") → False

Include: type hints, docstring, tests"
```

### Example 2: Analysis

**Before (Score: 3/10):**
```
"Check my code"
```

**After (Score: 9/10):**
```
"You are a senior security engineer.

Review this authentication code for:
1. Security vulnerabilities (SQL injection, XSS)
2. Password handling issues
3. Session management flaws

Provide:
- List of issues with severity
- Code examples of fixes
- Updated secure implementation"
```

## Advanced Technique: Teaching Anti-Patterns with Few-Shot Examples

**Controversial but Effective:** Sometimes you SHOULD show what NOT to do!

### When to Use Negative Examples

**Use Case:** Teaching the model to avoid specific bad patterns or mistakes.

**Pattern:**
```markdown
Task: Review code and identify anti-patterns.

Example 1 (BAD CODE - DO NOT COPY):
```python
def process(data):
    return [x for x in data if x]  # Unclear variable names
```
Issues: Non-descriptive variable name 'x', unclear what 'if x' checks

Example 1 (GOOD CODE - FOLLOW THIS):
```python
def process_active_users(users: List[User]) -> List[User]:
    """Filter users with active status."""
    return [user for user in users if user.is_active]
```
Improvements: Clear function name, type hints, descriptive variables, docstring

Now review: {user's code}
```

### The Paradox: Negative Examples Can Help

**Research Finding:**
- Showing anti-patterns WITH clear labels ("BAD", "AVOID") can teach the model what to avoid
- MUST be paired with correct examples
- Label clearly to prevent copying

**Pattern Structure:**
```markdown
Example {n} (ANTI-PATTERN - AVOID THIS):
{bad example with clear problems}

WHY IT'S BAD:
- Reason 1
- Reason 2

Example {n} (CORRECT APPROACH - USE THIS):
{good example}

WHY IT'S GOOD:
- Improvement 1
- Improvement 2
```

### Real-World Example: Security Review

```markdown
You are a security auditor reviewing authentication code.

Example 1 (INSECURE - NEVER DO THIS):
```python
def login(username, password):
    query = f"SELECT * FROM users WHERE name='{username}' AND pass='{password}'"
    return db.execute(query)
```

VULNERABILITIES:
- SQL injection (user input directly in query)
- Plain text password comparison
- No rate limiting

Example 1 (SECURE - DO THIS INSTEAD):
```python
def login(username: str, password: str) -> Optional[User]:
    """Authenticate user with secure practices."""
    user = db.query(User).filter_by(username=username).first()
    if not user or not verify_password(password, user.password_hash):
        return None
    return user
```

IMPROVEMENTS:
- Parameterized query prevents SQL injection
- Password hashing with verification
- Returns None on failure (no information leak)

Now review this code: {user's code}
```

### When NOT to Use Negative Examples

❌ **Don't use when:**
- Teaching creative tasks (may limit creativity)
- Model might copy the bad pattern
- Can't clearly label as "bad"
- Positive examples are sufficient

✅ **DO use when:**
- Teaching error detection
- Security vulnerability identification
- Code review training
- Explaining why something is wrong

### Research Evidence

**Recent Studies (2024-2025):**

1. **"Large Language Models are Contrastive Reasoners"** (arXiv 2403.08211)
   - GSM8K: 35.9% → 88.8% (+53% improvement!)
   - AQUA-RAT: 41.3% → 62.2% (+21% improvement)
   - Method: "Let's give a correct and a wrong answer"

2. **"Failures Are the Stepping Stones to Success"** (arXiv 2507.23211)
   - Symbolic reasoning: +6.5-7.6% improvement
   - Arithmetic: +2-4% improvement
   - Optimal: 2 negative examples

**Anthropic's Perspective:**
> "Negative examples can confuse the model. Focus on positive patterns."

**BUT Research Shows:** With clear labeling, negative examples dramatically improve performance on:
- Code review: +15-25% (estimated)
- Math reasoning: +20-53% (proven)
- Error detection: +10-20% (estimated)

**Best Practice (Research-Backed):**
- Always pair negative with positive
- Use clear labels ("BAD", "ANTI-PATTERN", "INSECURE")
- Explain WHY it's bad
- Show the correct alternative immediately after
- Limit to 2-3 negative examples (more causes semantic drift)

**See:** `negative-examples-research.md` for comprehensive research analysis

### Example: Data Validation

```markdown
Validate user input and provide feedback.

Example 1 - REJECTED INPUT (show error message):
Input: {"email": "notanemail"}
Output: {
  "valid": false,
  "errors": ["email: Invalid format. Must contain @ and domain"]
}

Example 2 - ACCEPTED INPUT (no errors):
Input: {"email": "user@example.com"}
Output: {
  "valid": true,
  "errors": []
}

Example 3 - REJECTED INPUT (multiple issues):
Input: {"email": "", "age": -5}
Output: {
  "valid": false,
  "errors": [
    "email: Required field cannot be empty",
    "age: Must be positive number"
  ]
}

Now validate: {user input}
```

**Why This Works:**
- Shows both acceptance and rejection patterns
- Model learns decision boundaries
- Clear structure for error messages

### Guidelines for Using Negative Examples

1. **Always label clearly:**
   - "ANTI-PATTERN", "BAD", "INSECURE", "AVOID"
   - Make it impossible to confuse with good examples

2. **Explain why it's wrong:**
   - Don't just show, teach the reasoning
   - Helps model generalize

3. **Provide correct alternative immediately:**
   - Never end with negative example
   - Always show the right way

4. **Use contrast format:**
   - Side-by-side or sequential comparison
   - Makes differences obvious

5. **Test carefully:**
   - Verify model doesn't copy negative patterns
   - Adjust labeling if needed

---

## Testing Your Prompts

Use this checklist to avoid anti-patterns:

```
[ ] Task is specific (not vague)
[ ] Context is provided (not assumed)
[ ] Examples are included (input/output)
[ ] Structure is clear (not wall of text)
[ ] Format is specified (not ambiguous)
[ ] Persona is defined (not missing)
[ ] Temperature is appropriate (not misused)
[ ] Complex tasks are decomposed (not monolithic)
[ ] Test cases are specified (not missing)
[ ] Model limits are respected (not exceeded)
[ ] Security is considered (not ignored)
```

## References

**Official Guidelines:**
- OpenAI: platform.openai.com/docs/guides/prompt-engineering
- Gemini: ai.google.dev/gemini-api/docs/prompting-strategies
- GPT-4.1: cookbook.openai.com/examples/gpt4-1_prompting_guide

**Based on official documentation and real-world prompt engineering experience (2025).**
