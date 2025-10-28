# LangGraph VCR Testing - Quick Reference

**One-page cheat sheet for developers**

---

## What is VCR?

VCR records real API calls and replays them in tests.

```
First run: Real API → Record → Cassette file
Next runs: Cassette → Instant replay (0.1s)
```

---

## Setup (One-Time)

```bash
# Install VCR
uv add pytest-vcr --dev

# Configure (add to tests/conftest.py)
import pytest

@pytest.fixture(scope="module")
def vcr_config():
    return {
        "filter_headers": ["authorization"],
        "record_mode": "once",
        "cassette_library_dir": "tests/cassettes",
    }
```

---

## Writing Tests

### Before (Mock-First) ❌

```python
from unittest.mock import patch

def test_researcher():
    with patch('nodes.researcher.ChatOpenAI') as mock:
        mock.return_value.invoke.return_value.content = "Mock"
        result = researcher_node(state)
        assert result.research_results == ["Mock"]
```

### After (VCR-Based) ✅

```python
import pytest

@pytest.mark.vcr()  # Just add this decorator!
def test_researcher():
    result = researcher_node(state)
    # Test real API behavior
    assert len(result.research_results) > 0
    assert "quantum" in result.research_results[0].lower()
```

---

## Running Tests

```bash
# First run: Records cassettes
export OPENAI_API_KEY=sk-...
pytest tests/test_researcher.py -v
# Creates: tests/cassettes/test_researcher.yaml

# Subsequent runs: Replays cassettes (instant, no API key!)
unset OPENAI_API_KEY
pytest tests/test_researcher.py -v
# Uses cassette → 0.1 seconds
```

---

## Common Patterns

### Test with Real API

```python
@pytest.mark.vcr()
def test_happy_path():
    """First run: real API, Next: cassette"""
    result = my_node(state)
    assert len(result.output) > 0
```

### Custom Cassette Name

```python
@pytest.mark.vcr("cassettes/my_custom_name.yaml")
def test_edge_case():
    """Use specific cassette file"""
    result = my_node(state)
    assert result.completed_branches
```

### Test Error Handling

```python
@pytest.mark.vcr("cassettes/api_error.yaml")
def test_handles_error():
    """Edit cassette to inject 500 error"""
    result = my_node(state)
    assert len(result.errors) > 0
```

### Parametrized Tests

```python
@pytest.mark.parametrize("query", ["quantum", "AI", "blockchain"])
@pytest.mark.vcr()
def test_various_topics(query):
    """Each parameter gets its own cassette"""
    result = researcher_node(WorkflowState(query=query))
    assert query.lower() in result.research_results[0].lower()
```

---

## Managing Cassettes

### Re-record Single Cassette

```bash
rm tests/cassettes/test_researcher.yaml
pytest tests/test_researcher.py -v
```

### Re-record All Cassettes

```bash
rm -rf tests/cassettes/
pytest tests/ -v
```

### Use CLI Flags

```bash
# Never record (CI mode)
pytest tests/ --vcr-record=none

# Always re-record
pytest tests/ --vcr-record=all

# Add new, keep existing
pytest tests/ --vcr-record=new_episodes
```

---

## Cassette Example

```yaml
# tests/cassettes/test_researcher.yaml
interactions:
- request:
    method: POST
    uri: https://api.openai.com/v1/chat/completions
    body: '{"model": "gpt-4", "messages": [...]}'
  response:
    status: {code: 200, message: OK}
    body:
      string: '{"choices": [{"message": {"content": "Quantum computing..."}}]}'
```

---

## TDD Workflow

### Traditional Mock-First ❌

```
1. Write mock → Test passes (validates nothing)
2. Write real code → Hope it works
3. Test real → Discover issues late
```

### VCR-Based TDD ✅

```
1. Write VCR test → RED (no implementation)
2. Write real code → GREEN (real API works!)
3. Cassette created → Fast feedback forever
```

---

## Troubleshooting

### "No cassette found"

```bash
# Solution: Record cassette with API key
export OPENAI_API_KEY=sk-...
pytest tests/test_researcher.py -v
```

### "Cannot match request"

```bash
# Solution: Re-record cassette (request changed)
rm tests/cassettes/test_researcher.yaml
pytest tests/test_researcher.py -v
```

### "Cassette has sensitive data"

```python
# Solution: Filter headers in conftest.py
@pytest.fixture(scope="module")
def vcr_config():
    return {
        "filter_headers": ["authorization", "x-api-key"],
        # ...
    }
```

### "Tests still call real API"

```bash
# Solution: Use --vcr-record=none to enforce cassette mode
pytest tests/ --vcr-record=none
```

---

## CI/CD Configuration

```yaml
# .github/workflows/test.yml
- name: Run tests with cassettes
  run: pytest tests/ --vcr-record=none
  # No API key needed! Uses cassettes only
```

---

## Node Implementation Pattern

### Before (Mock-First) ❌

```python
IMPLEMENTED = False

def researcher_node(state):
    if not IMPLEMENTED:
        return state | {"research_results": ["Mock"]}
    # Real code here
```

### After (VCR-Based) ✅

```python
def researcher_node(state):
    """Just real implementation, no flags"""
    try:
        llm = ChatOpenAI(model="gpt-4")
        response = llm.invoke(f"Research: {state.query}")
        return state.model_copy(update={
            "research_results": [response.content],
            "completed_branches": state.completed_branches | {"researcher"}
        })
    except Exception as e:
        return state.model_copy(update={
            "errors": state.errors + [{"node": "researcher", "error": str(e)}],
            "completed_branches": state.completed_branches | {"researcher"}
        })
```

---

## Assertions for LLM Outputs

### Bad (Exact Match) ❌

```python
assert result.draft == "Quantum computing is..."  # Fails on variations
```

### Good (Property-Based) ✅

```python
# Check properties, not exact content
assert len(result.draft) > 100  # Has substantial content
assert "quantum" in result.draft.lower()  # Contains key term
assert result.draft.count(".") > 3  # Multiple sentences
```

---

## Cost & Speed

| Test Type | First Run | Subsequent Runs |
|-----------|-----------|----------------|
| **Mock** | 0.5s, $0 | 0.5s, $0 |
| **Real API** | 5s, $0.01 | 5s, $0.01 |
| **VCR** | 5s, $0.01 | **0.1s, $0** |

**VCR wins after first run!**

---

## When to Re-record

- ✅ Monthly (automated refresh)
- ✅ When API behavior changes
- ✅ When test logic changes
- ✅ When adding new test cases
- ❌ Not every commit (use cassettes!)

---

## Git Workflow

```bash
# Always commit cassettes!
git add tests/cassettes/
git commit -m "Add VCR cassettes for researcher tests"

# Do NOT add to .gitignore:
# tests/cassettes/  ❌ Wrong!
```

---

## Cheat Sheet

| Action | Command |
|--------|---------|
| **Install VCR** | `uv add pytest-vcr --dev` |
| **First recording** | `export OPENAI_API_KEY=sk-... && pytest tests/ -v` |
| **Replay tests** | `pytest tests/ -v` |
| **Re-record one** | `rm tests/cassettes/test_X.yaml && pytest tests/test_X.py -v` |
| **Re-record all** | `rm -rf tests/cassettes/ && pytest tests/ -v` |
| **CI mode** | `pytest tests/ --vcr-record=none` |
| **Force record** | `pytest tests/ --vcr-record=all` |

---

## Decision Tree

```
Need to test LangGraph node?
├─ Pure logic test (no API)
│  └─ Use mock: @patch('...')
│
└─ LLM/API integration test
   └─ Use VCR: @pytest.mark.vcr()
```

---

## Benefits Recap

| Metric | Mock-First | VCR-Based |
|--------|-----------|-----------|
| **Validates real API** | ❌ No | ✅ Yes |
| **Test speed** | 0.5s | 0.1s (after first) |
| **API cost** | $0 or $30+ | $2-5 one-time |
| **CI friendly** | ❓ Mixed | ✅ Yes |
| **Confidence** | 60% | 95% |

---

## More Info

- **Full Analysis**: `docs/langgraph-tdd-analysis-real-vs-mock-api.md`
- **Migration Guide**: `docs/langgraph-vcr-migration-guide.md`
- **Comparison**: `docs/langgraph-tdd-comparison-example.md`
- **pytest-vcr docs**: https://pytest-vcr.readthedocs.io/

---

## TL;DR

1. Add `@pytest.mark.vcr()` to tests
2. Write real assertions (not mock outputs)
3. First run records API responses
4. Next runs replay instantly
5. Commit cassettes to git
6. Done! 🎉

**Bottom line:** VCR = Real API validation + Mock-like speed

---

**Print this page and keep it handy!**
