# LangGraph VCR Migration Guide

**Practical guide for migrating from mock-first to VCR-based TDD**

---

## Quick Start (5 Minutes)

### 1. Install VCR

```bash
# Add to pyproject.toml
uv add pytest-vcr --dev

# Or with pip
pip install pytest-vcr
```

### 2. Configure VCR

Create or update `tests/conftest.py`:

```python
import pytest
import os

# Configure VCR for all tests
@pytest.fixture(scope="module")
def vcr_config():
    """VCR configuration for recording/replaying API calls"""
    return {
        # Hide sensitive headers
        "filter_headers": [
            "authorization",
            "x-api-key",
            "api-key",
        ],

        # Record mode options:
        # - "once": Record once, replay thereafter (default)
        # - "new_episodes": Add new interactions, keep existing
        # - "none": Never record, fail if cassette missing
        # - "all": Always re-record
        "record_mode": "once",

        # Match requests on these attributes
        "match_on": ["method", "scheme", "host", "port", "path", "query", "body"],

        # Where to store cassettes
        "cassette_library_dir": "tests/cassettes",

        # Decode compressed responses for readability
        "decode_compressed_response": True,
    }

# Ensure API keys are set for first recording
@pytest.fixture(scope="session", autouse=True)
def ensure_api_keys():
    """Verify API keys are available for recording"""
    if not os.getenv("OPENAI_API_KEY"):
        pytest.skip("OPENAI_API_KEY not set - required for initial recording")
```

### 3. Convert First Test

**Before (mock-based):**
```python
from unittest.mock import Mock, patch

def test_researcher_node():
    """Test with mocked OpenAI API"""
    with patch('nodes.researcher.ChatOpenAI') as mock_llm:
        mock_llm.return_value.invoke.return_value.content = "Mock research"

        state = WorkflowState(query="quantum computing")
        result = researcher_node(state)

        assert result.research_results == ["Mock research"]
        assert "researcher" in result.completed_branches
```

**After (VCR-based):**
```python
import pytest

@pytest.mark.vcr()  # Automatically records/replays
def test_researcher_node():
    """Test with real OpenAI API (first run), cassette replay (subsequent)"""
    state = WorkflowState(query="quantum computing")
    result = researcher_node(state)

    # Assert on real API behavior (not mock output)
    assert len(result.research_results) > 0
    assert "quantum" in result.research_results[0].lower()
    assert "researcher" in result.completed_branches
```

### 4. Run and Commit

```bash
# First run: Records cassette
export OPENAI_API_KEY=sk-...  # Set your API key
pytest tests/test_researcher.py -v

# Check cassette was created
ls tests/cassettes/
# test_researcher_node.yaml

# Commit cassette to git
git add tests/cassettes/test_researcher_node.yaml
git commit -m "Add VCR cassette for researcher node"

# Subsequent runs: Instant replay (no API key needed!)
unset OPENAI_API_KEY
pytest tests/test_researcher.py -v  # Still passes!
```

---

## Complete Example: Researcher Node

### Original Implementation (Mock-First)

**nodes/researcher.py:**
```python
"""Researcher Node - Mock-first approach"""

IMPLEMENTED = False

def researcher_node(state: WorkflowState) -> WorkflowState:
    """Research a topic using LLM"""

    # Phase 2: Mock implementation
    if not IMPLEMENTED:
        return state.model_copy(update={
            "research_results": ["mock research result"],
            "completed_branches": state.completed_branches | {"researcher"}
        })

    # Phase 4: Real implementation (later)
    from langchain_openai import ChatOpenAI
    llm = ChatOpenAI(model="gpt-4")
    response = llm.invoke(f"Research: {state.query}")

    return state.model_copy(update={
        "research_results": [response.content],
        "completed_branches": state.completed_branches | {"researcher"}
    })
```

**tests/test_researcher.py:**
```python
"""Test researcher node - Mock-first approach"""
from nodes.researcher import researcher_node, IMPLEMENTED

def test_researcher_happy_path():
    """Test with mock (always passes)"""
    state = WorkflowState(query="quantum computing")
    result = researcher_node(state)

    # Mock-based assertion
    assert result.research_results == ["mock research result"]
    assert "researcher" in result.completed_branches

@pytest.mark.skipif(not IMPLEMENTED, reason="Not implemented yet")
def test_researcher_with_real_llm():
    """Test with real LLM (skipped until IMPLEMENTED=True)"""
    state = WorkflowState(query="quantum computing")
    result = researcher_node(state)

    assert len(result.research_results) > 0
```

**Problems:**
1. First test always passes (mock)
2. Real API test is skipped initially
3. No validation until Phase 4
4. IMPLEMENTED flag adds complexity

---

### Migrated Implementation (VCR-Based)

**nodes/researcher.py:**
```python
"""Researcher Node - VCR-based TDD approach"""
from langchain_openai import ChatOpenAI
from langchain_core.messages import HumanMessage, SystemMessage

def researcher_node(state: WorkflowState) -> WorkflowState:
    """
    Research a topic using OpenAI GPT-4.

    Args:
        state: WorkflowState with 'query' field

    Returns:
        Updated state with 'research_results' populated
    """
    try:
        # Validate input
        if not state.query or not state.query.strip():
            return state.model_copy(update={
                "research_results": [],
                "completed_branches": state.completed_branches | {"researcher"}
            })

        # Call LLM
        llm = ChatOpenAI(model="gpt-4", temperature=0.7)
        response = llm.invoke([
            SystemMessage(content="You are a research assistant. Provide concise, factual information."),
            HumanMessage(content=f"Research this topic: {state.query}")
        ])

        # Update state
        return state.model_copy(update={
            "research_results": [response.content],
            "completed_branches": state.completed_branches | {"researcher"}
        })

    except Exception as e:
        # Graceful error handling
        error_record = {
            "node": "researcher",
            "error": str(e),
            "query": state.query
        }
        return state.model_copy(update={
            "errors": state.errors + [error_record],
            "completed_branches": state.completed_branches | {"researcher"}
        })
```

**tests/test_researcher.py:**
```python
"""Test researcher node - VCR-based TDD approach"""
import pytest
from nodes.researcher import researcher_node
from state_schema import WorkflowState

@pytest.mark.vcr()
def test_researcher_finds_relevant_content():
    """
    Test researcher node returns relevant content for valid query.

    First run: Calls real OpenAI API and records response
    Subsequent runs: Replays cassette (instant, no API call)
    """
    state = WorkflowState(query="quantum computing applications")
    result = researcher_node(state)

    # Assert on real API behavior
    assert len(result.research_results) > 0, "Should return research results"
    assert len(result.research_results[0]) > 50, "Result should have substantial content"
    assert "quantum" in result.research_results[0].lower(), "Should mention quantum"
    assert "researcher" in result.completed_branches, "Should mark completion"
    assert len(result.errors) == 0, "Should not have errors"


@pytest.mark.vcr()
def test_researcher_handles_empty_query():
    """Test researcher gracefully handles empty query"""
    state = WorkflowState(query="")
    result = researcher_node(state)

    assert result.research_results == [], "Should return empty list for empty query"
    assert "researcher" in result.completed_branches, "Should still mark completion"


@pytest.mark.vcr()
def test_researcher_handles_whitespace_query():
    """Test researcher handles whitespace-only query"""
    state = WorkflowState(query="   \n\t  ")
    result = researcher_node(state)

    assert result.research_results == [], "Should treat whitespace as empty"
    assert "researcher" in result.completed_branches


@pytest.mark.vcr("cassettes/researcher_complex_query.yaml")
def test_researcher_handles_complex_query():
    """Test researcher with multi-part query"""
    state = WorkflowState(
        query="Compare quantum annealing vs gate-based quantum computing for optimization problems"
    )
    result = researcher_node(state)

    # Check structure
    assert len(result.research_results) > 0
    content = result.research_results[0].lower()

    # Check key terms present
    assert "quantum" in content or "optimization" in content
    assert len(content) > 100, "Complex query should yield detailed response"


@pytest.mark.vcr("cassettes/researcher_error.yaml")
def test_researcher_handles_api_error():
    """
    Test error handling (manually edit cassette to inject 500 error).

    To create error cassette:
    1. Run test normally to record successful cassette
    2. Copy cassette to researcher_error.yaml
    3. Edit YAML: change status code to 500, add error message
    4. Re-run test to verify error handling
    """
    state = WorkflowState(query="test query")
    result = researcher_node(state)

    # Should record error gracefully
    assert "researcher" in result.completed_branches, "Should mark completion even on error"
    # Either has error recorded OR empty results (depending on error type)
    assert len(result.errors) > 0 or len(result.research_results) == 0


# Advanced: Test with different models (if needed)
@pytest.mark.vcr("cassettes/researcher_gpt35.yaml")
def test_researcher_with_gpt35():
    """Test researcher using GPT-3.5 (faster, cheaper)"""
    # Temporarily modify node to use gpt-3.5-turbo
    # Or use dependency injection / config parameter
    state = WorkflowState(query="brief summary of quantum computing")
    result = researcher_node(state)

    assert len(result.research_results) > 0
```

**Benefits:**
1. All tests run against real API behavior
2. No IMPLEMENTED flag needed
3. First run validates real implementation
4. Cassettes enable fast replay
5. More comprehensive test coverage

---

## Cassette Management

### Viewing Cassettes

Cassettes are stored as human-readable YAML:

```yaml
# tests/cassettes/test_researcher_finds_relevant_content.yaml
interactions:
- request:
    body: '{"model": "gpt-4", "messages": [{"role": "system", "content": "You are
      a research assistant..."}, {"role": "user", "content": "Research this topic:
      quantum computing applications"}], "temperature": 0.7}'
    headers:
      Accept:
      - application/json
      Content-Type:
      - application/json
    method: POST
    uri: https://api.openai.com/v1/chat/completions
  response:
    body:
      string: '{"id": "chatcmpl-abc123", "object": "chat.completion", "created": 1234567890,
        "model": "gpt-4", "choices": [{"index": 0, "message": {"role": "assistant",
        "content": "Quantum computing applications span multiple fields including..."}}],
        "usage": {"prompt_tokens": 45, "completion_tokens": 250, "total_tokens": 295}}'
    headers:
      Content-Type:
      - application/json
    status:
      code: 200
      message: OK
version: 1
```

### Re-recording Cassettes

When API behavior changes or you want fresh recordings:

```bash
# Option 1: Delete specific cassette
rm tests/cassettes/test_researcher_finds_relevant_content.yaml
pytest tests/test_researcher.py::test_researcher_finds_relevant_content -v

# Option 2: Delete all cassettes
rm -rf tests/cassettes/
pytest tests/ -v

# Option 3: Use record mode flag
pytest tests/ -v --vcr-record=all  # Re-record everything

# Option 4: Use new_episodes mode (add to existing cassettes)
pytest tests/ -v --vcr-record=new_episodes
```

### Editing Cassettes for Error Testing

To test error handling without triggering real errors:

```bash
# 1. Record successful cassette
pytest tests/test_researcher.py::test_researcher_handles_api_error -v

# 2. Copy to error cassette
cp tests/cassettes/test_researcher_handles_api_error.yaml \
   tests/cassettes/researcher_error.yaml

# 3. Edit YAML to inject error
nano tests/cassettes/researcher_error.yaml
```

**Change:**
```yaml
  response:
    status:
      code: 200  # Change to 500
      message: OK  # Change to Internal Server Error
    body:
      string: '{"error": {"message": "Model overloaded", "type": "server_error"}}'
```

**Update test:**
```python
@pytest.mark.vcr("cassettes/researcher_error.yaml")
def test_researcher_handles_api_error():
    # Now uses manually edited cassette with 500 error
    ...
```

---

## CI/CD Integration

### GitHub Actions Workflow

```yaml
# .github/workflows/test.yml
name: Tests

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'

    - name: Install dependencies
      run: |
        pip install uv
        uv sync

    - name: Run tests (VCR replay mode)
      run: |
        # Use cassettes only, never record
        pytest tests/ -v --vcr-record=none
      env:
        # API key NOT needed (uses cassettes)
        # If key is set, VCR still won't use it with --vcr-record=none

    - name: Check cassette coverage
      run: |
        # Ensure all tests have cassettes
        python scripts/check_cassette_coverage.py

  # Optional: Nightly job to refresh cassettes
  refresh-cassettes:
    runs-on: ubuntu-latest
    if: github.event_name == 'schedule'  # Run on schedule only

    steps:
    - uses: actions/checkout@v3

    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'

    - name: Install dependencies
      run: |
        pip install uv
        uv sync

    - name: Re-record cassettes
      run: |
        rm -rf tests/cassettes/
        pytest tests/ -v
      env:
        OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}

    - name: Commit updated cassettes
      run: |
        git config user.name "GitHub Actions"
        git config user.email "actions@github.com"
        git add tests/cassettes/
        git commit -m "chore: Refresh VCR cassettes (automated)"
        git push
```

### Pre-commit Hook

```yaml
# .pre-commit-config.yaml
repos:
  - repo: local
    hooks:
      - id: pytest-fast
        name: Run fast tests (with VCR)
        entry: pytest tests/unit/ tests/integration/ --vcr-record=none -x
        language: system
        pass_filenames: false
        always_run: true
```

---

## Common Patterns

### Pattern 1: Parametrized Tests with VCR

```python
@pytest.mark.parametrize("query,expected_keywords", [
    ("quantum computing", ["quantum", "computing", "qubit"]),
    ("machine learning", ["machine", "learning", "algorithm"]),
    ("blockchain", ["blockchain", "distributed", "ledger"]),
])
@pytest.mark.vcr()
def test_researcher_various_topics(query, expected_keywords):
    """Test researcher with multiple topics (each gets its own cassette)"""
    state = WorkflowState(query=query)
    result = researcher_node(state)

    content = result.research_results[0].lower()
    assert any(keyword in content for keyword in expected_keywords)
```

**Cassettes created:**
```
tests/cassettes/
├── test_researcher_various_topics[quantum_computing-expected_keywords0].yaml
├── test_researcher_various_topics[machine_learning-expected_keywords1].yaml
└── test_researcher_various_topics[blockchain-expected_keywords2].yaml
```

### Pattern 2: Fixtures with VCR

```python
@pytest.fixture
def research_state():
    """Fixture for common research state"""
    return WorkflowState(
        query="quantum computing",
        completed_branches=set(),
        errors=[]
    )

@pytest.mark.vcr()
def test_researcher_with_fixture(research_state):
    """Test using fixture (VCR still works)"""
    result = researcher_node(research_state)
    assert len(result.research_results) > 0
```

### Pattern 3: Multiple API Calls in One Test

```python
@pytest.mark.vcr()
def test_researcher_multiple_queries():
    """Test multiple sequential queries (all recorded in one cassette)"""
    # First query
    state1 = WorkflowState(query="quantum computing")
    result1 = researcher_node(state1)
    assert len(result1.research_results) > 0

    # Second query (different topic)
    state2 = WorkflowState(query="artificial intelligence")
    result2 = researcher_node(state2)
    assert len(result2.research_results) > 0

    # Results should be different
    assert result1.research_results[0] != result2.research_results[0]
```

**Cassette contains both interactions:**
```yaml
interactions:
- request:  # First query
    body: '..."quantum computing"...'
  response:
    body: '..."Quantum computing is..."...'
- request:  # Second query
    body: '..."artificial intelligence"...'
  response:
    body: '..."Artificial intelligence is..."...'
```

### Pattern 4: Async Nodes with VCR

```python
@pytest.mark.vcr()
@pytest.mark.asyncio
async def test_async_researcher_node():
    """Test async node with VCR"""
    state = WorkflowState(query="quantum computing")
    result = await async_researcher_node(state)

    assert len(result.research_results) > 0
```

---

## Troubleshooting

### Issue: "No cassette found"

```
vcrpy.errors.CannotOverwriteExistingCassetteException:
Can't find cassette 'tests/cassettes/test_researcher.yaml'
```

**Solution:**
```bash
# First run with API key to record
export OPENAI_API_KEY=sk-...
pytest tests/test_researcher.py -v

# Or use explicit record mode
pytest tests/test_researcher.py -v --vcr-record=once
```

### Issue: Cassette mismatch

```
vcr.errors.UnhandledHTTPRequest:
The request does not match any known cassette interactions
```

**Cause**: Request parameters changed (different body, headers, query params)

**Solution:**
```bash
# Re-record cassette
rm tests/cassettes/test_researcher.yaml
pytest tests/test_researcher.py -v
```

### Issue: Sensitive data in cassettes

```yaml
# Cassette contains API key!
headers:
  Authorization: Bearer sk-abc123...
```

**Solution**: Configure VCR to filter headers
```python
@pytest.fixture(scope="module")
def vcr_config():
    return {
        "filter_headers": ["authorization", "x-api-key"],
        # Or use custom filter function
        "before_record_response": filter_sensitive_data,
    }

def filter_sensitive_data(response):
    """Custom filter to remove sensitive data"""
    # Remove API keys from response body
    if "api_key" in response["body"]["string"]:
        response["body"]["string"] = response["body"]["string"].replace(
            os.getenv("OPENAI_API_KEY", ""), "REDACTED"
        )
    return response
```

### Issue: Flaky tests (sometimes pass, sometimes fail)

**Cause**: Test assertions too strict for non-deterministic LLM outputs

**Solution**: Use property-based assertions
```python
# ❌ Bad: Exact match
assert result.research_results[0] == "Quantum computing is..."

# ✅ Good: Property checks
assert len(result.research_results[0]) > 50
assert "quantum" in result.research_results[0].lower()
```

### Issue: Cassettes too large (>1MB)

**Cause**: LLM responses very long, or many interactions

**Solution 1**: Compress cassettes
```python
@pytest.fixture(scope="module")
def vcr_config():
    return {
        "decode_compressed_response": True,  # Compress response bodies
    }
```

**Solution 2**: Filter response data
```python
def filter_large_responses(response):
    """Truncate large response bodies"""
    body = response["body"]["string"]
    if len(body) > 1000:
        response["body"]["string"] = body[:1000] + "...[truncated]"
    return response

@pytest.fixture(scope="module")
def vcr_config():
    return {
        "before_record_response": filter_large_responses,
    }
```

**Solution 3**: Use Git LFS for large cassettes
```bash
# .gitattributes
tests/cassettes/*.yaml filter=lfs diff=lfs merge=lfs -text
```

---

## Migration Checklist

Use this checklist when migrating an existing LangGraph project:

- [ ] **Install VCR**
  ```bash
  uv add pytest-vcr --dev
  ```

- [ ] **Configure VCR in conftest.py**
  - Add `vcr_config` fixture
  - Filter sensitive headers
  - Set cassette directory

- [ ] **Update .gitignore (ensure cassettes are tracked)**
  ```
  # Do NOT add this line:
  # tests/cassettes/  ❌
  ```

- [ ] **Convert test files one by one**
  - Remove `@patch` decorators
  - Add `@pytest.mark.vcr()` decorators
  - Update assertions for real API behavior

- [ ] **Remove IMPLEMENTED flags from nodes**
  - Delete `IMPLEMENTED = False` pattern
  - Remove conditional mock logic
  - Implement real logic directly

- [ ] **Record cassettes**
  ```bash
  export OPENAI_API_KEY=sk-...
  pytest tests/ -v
  ```

- [ ] **Commit cassettes to git**
  ```bash
  git add tests/cassettes/
  git commit -m "Add VCR cassettes for all tests"
  ```

- [ ] **Verify CI/CD works without API keys**
  ```bash
  unset OPENAI_API_KEY
  pytest tests/ -v --vcr-record=none
  ```

- [ ] **Update documentation**
  - README: Mention VCR usage
  - Contributing guide: How to record cassettes
  - Testing guidelines: VCR best practices

- [ ] **Set up cassette refresh workflow (optional)**
  - Add GitHub Actions schedule job
  - Or manual refresh cadence (weekly/monthly)

---

## Next Steps

After successful migration:

1. **Monitor cassette freshness**: Set calendar reminder to refresh cassettes quarterly
2. **Educate team**: Share this guide with all developers
3. **Extend to other nodes**: Apply VCR pattern to all LangGraph nodes
4. **Consider tiered testing**: Add Layer 1 (mock) for ultra-fast unit tests
5. **Optimize CI**: Split fast/slow tests for better feedback loops

---

## Resources

- **pytest-vcr docs**: https://pytest-vcr.readthedocs.io/
- **vcrpy docs**: https://vcrpy.readthedocs.io/
- **LangChain testing guide**: https://python.langchain.com/docs/contributing/testing
- **LangGraph docs**: https://langchain-ai.github.io/langgraph/

---

**Questions?** Open an issue or ask in #langgraph-tdd Slack channel.
