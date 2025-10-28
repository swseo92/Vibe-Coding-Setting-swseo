# LangGraph TDD: Mock-First vs VCR-Based Comparison

**Side-by-side comparison of the two approaches**

---

## Scenario: Building a Research-Writer Workflow

**Requirements:**
- Node 1: Researcher - Takes a query, calls LLM to research, returns findings
- Node 2: Writer - Takes research findings, calls LLM to write article, returns draft
- Workflow: query → researcher → writer → END

---

## Approach A: Mock-First TDD (Current Method)

### Timeline

**Day 1 (Morning): Design & Mock Implementation**

#### state_schema.py
```python
from pydantic import BaseModel, Field

class WorkflowState(BaseModel):
    query: str = ""
    research_results: list[str] = Field(default_factory=list)
    draft: str = ""
    errors: list[dict] = Field(default_factory=list)
    completed_branches: set[str] = Field(default_factory=set)

    class Config:
        arbitrary_types_allowed = True
```

#### nodes/researcher.py
```python
"""Researcher Node - Mock Implementation"""

IMPLEMENTED = False  # Phase 2: Start with mock

def researcher_node(state: WorkflowState) -> WorkflowState:
    """Research a topic using LLM"""

    if not IMPLEMENTED:
        # Phase 2: Mock - returns fixed output for topology testing
        return state.model_copy(update={
            "research_results": ["Mock research about quantum computing"],
            "completed_branches": state.completed_branches | {"researcher"}
        })

    # Phase 4: Real implementation (will be added later)
    from langchain_openai import ChatOpenAI
    llm = ChatOpenAI(model="gpt-4")
    response = llm.invoke(f"Research: {state.query}")

    return state.model_copy(update={
        "research_results": [response.content],
        "completed_branches": state.completed_branches | {"researcher"}
    })
```

#### nodes/writer.py
```python
"""Writer Node - Mock Implementation"""

IMPLEMENTED = False  # Phase 2: Start with mock

def writer_node(state: WorkflowState) -> WorkflowState:
    """Write article based on research"""

    if not IMPLEMENTED:
        # Phase 2: Mock - returns fixed output
        return state.model_copy(update={
            "draft": "Mock article draft",
            "completed_branches": state.completed_branches | {"writer"}
        })

    # Phase 4: Real implementation (will be added later)
    from langchain_openai import ChatOpenAI
    llm = ChatOpenAI(model="gpt-4")

    research = "\n".join(state.research_results)
    response = llm.invoke(f"Write article based on: {research}")

    return state.model_copy(update={
        "draft": response.content,
        "completed_branches": state.completed_branches | {"writer"}
    })
```

#### tests/test_topology.py
```python
"""Test workflow topology with mocks"""
from langgraph.graph import StateGraph, START, END
from nodes.researcher import researcher_node
from nodes.writer import writer_node
from state_schema import WorkflowState

def test_workflow_structure():
    """Test graph structure with all mock nodes"""
    workflow = StateGraph(WorkflowState)

    workflow.add_node("researcher", researcher_node)
    workflow.add_node("writer", writer_node)
    workflow.add_edge(START, "researcher")
    workflow.add_edge("researcher", "writer")
    workflow.add_edge("writer", END)

    graph = workflow.compile()

    # Test execution with mocks
    result = graph.invoke(WorkflowState(query="quantum computing"))

    # Assertions on mock outputs
    assert "researcher" in result.completed_branches
    assert "writer" in result.completed_branches
    assert result.research_results == ["Mock research about quantum computing"]
    assert result.draft == "Mock article draft"

# Output: ✅ PASSED (0.5 seconds)
```

**Status after Day 1 Morning:**
- ✅ Topology validated
- ✅ All tests passing
- ❌ No real API validation
- ❌ Unknown if real implementation will work

---

**Day 1 (Afternoon): Write Tests for Real Implementation**

#### tests/test_researcher.py
```python
"""Tests for researcher node"""
import pytest
from nodes.researcher import researcher_node, IMPLEMENTED
from state_schema import WorkflowState

def test_researcher_mock():
    """Test with mock (Phase 2)"""
    state = WorkflowState(query="quantum computing")
    result = researcher_node(state)

    # Mock assertions
    assert result.research_results == ["Mock research about quantum computing"]
    assert "researcher" in result.completed_branches

@pytest.mark.skipif(not IMPLEMENTED, reason="Not implemented yet")
def test_researcher_real_api():
    """Test with real API (Phase 4 - currently skipped)"""
    state = WorkflowState(query="quantum computing")
    result = researcher_node(state)

    # Real API assertions (not tested yet!)
    assert len(result.research_results) > 0
    assert "quantum" in result.research_results[0].lower()

# Output:
# test_researcher_mock ✅ PASSED
# test_researcher_real_api ⚠️ SKIPPED (IMPLEMENTED=False)
```

---

**Day 2: Implement Real Logic**

#### nodes/researcher.py (updated)
```python
"""Researcher Node - Real Implementation"""

IMPLEMENTED = True  # Phase 4: Now implementing real logic

def researcher_node(state: WorkflowState) -> WorkflowState:
    """Research a topic using LLM"""

    if not IMPLEMENTED:
        # Mock (no longer used)
        return state.model_copy(update={
            "research_results": ["Mock research about quantum computing"],
            "completed_branches": state.completed_branches | {"researcher"}
        })

    # Phase 4: Real implementation
    from langchain_openai import ChatOpenAI
    llm = ChatOpenAI(model="gpt-4")
    response = llm.invoke(f"Research: {state.query}")

    return state.model_copy(update={
        "research_results": [response.content],
        "completed_branches": state.completed_branches | {"researcher"}
    })
```

**Run tests:**
```bash
pytest tests/test_researcher.py -v

# Output:
# test_researcher_mock ✅ PASSED (mock still passes)
# test_researcher_real_api ✅ PASSED (first time tested!)
#   - But what if it failed? We're on Day 2, lots of time wasted!
```

**Problem discovered:** Real API returns different structure than mock!

```python
# Mock returned:
["Mock research about quantum computing"]

# Real API returned:
["Quantum computing is a type of computation that harnesses..."]
# ✅ Works, but purely by luck - structure matched

# What if real API returned:
[{"content": "...", "sources": [...]}]  # Different structure!
# ❌ Would fail, but only discovered on Day 2
```

---

**Day 3-4: Repeat for Writer Node**

Same process: mock → test mock → implement real → test real

**Total time: 4 days**
**First real API test: Day 2**
**Confidence in production readiness: 60%** (mocks passed, real tests eventually passed)

---

## Approach B: VCR-Based TDD (Recommended Method)

### Timeline

**Day 1 (Morning): Design & Setup**

#### Install VCR
```bash
uv add pytest-vcr --dev
```

#### tests/conftest.py
```python
import pytest

@pytest.fixture(scope="module")
def vcr_config():
    return {
        "filter_headers": ["authorization"],
        "record_mode": "once",
        "cassette_library_dir": "tests/cassettes",
    }
```

#### state_schema.py
```python
# Same as Approach A
from pydantic import BaseModel, Field

class WorkflowState(BaseModel):
    query: str = ""
    research_results: list[str] = Field(default_factory=list)
    draft: str = ""
    errors: list[dict] = Field(default_factory=list)
    completed_branches: set[str] = Field(default_factory=set)

    class Config:
        arbitrary_types_allowed = True
```

---

**Day 1 (Afternoon): Researcher Node TDD**

#### Phase 1: Write Failing Test (RED)

**tests/test_researcher.py:**
```python
"""Tests for researcher node - VCR approach"""
import pytest
from nodes.researcher import researcher_node  # Import will fail - not created yet!
from state_schema import WorkflowState

@pytest.mark.vcr()
def test_researcher_finds_relevant_content():
    """Test researcher with REAL API (first run records, subsequent replays)"""
    state = WorkflowState(query="quantum computing applications")
    result = researcher_node(state)

    # Assertions on real API behavior
    assert len(result.research_results) > 0
    assert len(result.research_results[0]) > 50  # Substantial content
    assert "quantum" in result.research_results[0].lower()
    assert "researcher" in result.completed_branches
```

**Run test:**
```bash
export OPENAI_API_KEY=sk-...
pytest tests/test_researcher.py -v

# Output: ❌ FAILED (ImportError: cannot import name 'researcher_node')
```

**TDD Step: RED** ✅ (test fails as expected)

---

#### Phase 2: Minimal Implementation (GREEN)

**nodes/researcher.py:**
```python
"""Researcher Node - Real Implementation (Day 1!)"""
from langchain_openai import ChatOpenAI

def researcher_node(state: WorkflowState) -> WorkflowState:
    """Research a topic using OpenAI GPT-4"""

    # Minimal implementation to make test pass
    llm = ChatOpenAI(model="gpt-4")
    response = llm.invoke(f"Research: {state.query}")

    return state.model_copy(update={
        "research_results": [response.content],
        "completed_branches": state.completed_branches | {"researcher"}
    })
```

**Run test:**
```bash
pytest tests/test_researcher.py -v

# Output:
# ✅ PASSED (5 seconds - real API call)
# Created: tests/cassettes/test_researcher_finds_relevant_content.yaml
```

**TDD Step: GREEN** ✅ (test passes with real API!)

**Cassette created:**
```yaml
# tests/cassettes/test_researcher_finds_relevant_content.yaml
interactions:
- request:
    method: POST
    uri: https://api.openai.com/v1/chat/completions
    body: '{"model": "gpt-4", "messages": [{"role": "user", "content": "Research: quantum computing applications"}]}'
  response:
    status: {code: 200, message: OK}
    body:
      string: '{"choices": [{"message": {"content": "Quantum computing applications include drug discovery, cryptography, optimization problems..."}}]}'
```

**Subsequent test runs:**
```bash
unset OPENAI_API_KEY  # No API key needed!
pytest tests/test_researcher.py -v

# Output: ✅ PASSED (0.1 seconds - cassette replay)
```

---

#### Phase 3: Add Edge Cases

**tests/test_researcher.py (continued):**
```python
@pytest.mark.vcr()
def test_researcher_handles_empty_query():
    """Test edge case: empty query"""
    state = WorkflowState(query="")
    result = researcher_node(state)

    assert "researcher" in result.completed_branches
    # May return empty or error message (test real behavior)
```

**Run test:**
```bash
pytest tests/test_researcher.py::test_researcher_handles_empty_query -v

# Output: ❌ FAILED (real API returned unexpected response)
# "I need a topic to research. Please provide a query."
```

**Refactor implementation:**
```python
def researcher_node(state: WorkflowState) -> WorkflowState:
    """Research a topic using OpenAI GPT-4"""

    # Handle empty query
    if not state.query or not state.query.strip():
        return state.model_copy(update={
            "research_results": [],
            "completed_branches": state.completed_branches | {"researcher"}
        })

    llm = ChatOpenAI(model="gpt-4")
    response = llm.invoke(f"Research: {state.query}")

    return state.model_copy(update={
        "research_results": [response.content],
        "completed_branches": state.completed_branches | {"researcher"}
    })
```

**Run test:**
```bash
pytest tests/test_researcher.py::test_researcher_handles_empty_query -v

# Output: ✅ PASSED (0.1 seconds - cassette replay)
```

**TDD Step: REFACTOR** ✅ (improved handling, test still passes)

---

**Day 2: Writer Node TDD**

Same TDD process: Write failing test → Implement → Refactor

**tests/test_writer.py:**
```python
@pytest.mark.vcr()
def test_writer_creates_article():
    """Test writer with real API"""
    state = WorkflowState(
        research_results=["Quantum computing uses qubits..."]
    )
    result = writer_node(state)

    assert len(result.draft) > 100
    assert "quantum" in result.draft.lower()
```

**nodes/writer.py:**
```python
def writer_node(state: WorkflowState) -> WorkflowState:
    """Write article based on research"""

    llm = ChatOpenAI(model="gpt-4")
    research = "\n".join(state.research_results)
    response = llm.invoke(f"Write article: {research}")

    return state.model_copy(update={
        "draft": response.content,
        "completed_branches": state.completed_branches | {"writer"}
    })
```

**Run test:**
```bash
pytest tests/test_writer.py -v

# Output: ✅ PASSED (first run: 5 sec, subsequent: 0.1 sec)
```

---

**Day 2 (Afternoon): Integration Test**

**tests/test_workflow.py:**
```python
@pytest.mark.vcr()
def test_complete_workflow():
    """Test full workflow end-to-end with real APIs"""
    workflow = StateGraph(WorkflowState)
    workflow.add_node("researcher", researcher_node)
    workflow.add_node("writer", writer_node)
    workflow.add_edge(START, "researcher")
    workflow.add_edge("researcher", "writer")
    workflow.add_edge("writer", END)

    graph = workflow.compile()

    # Test with real APIs (recorded to cassette)
    result = graph.invoke(WorkflowState(query="quantum computing"))

    # Validate complete execution
    assert len(result.research_results) > 0
    assert len(result.draft) > 100
    assert "researcher" in result.completed_branches
    assert "writer" in result.completed_branches
```

**Run test:**
```bash
pytest tests/test_workflow.py -v

# Output: ✅ PASSED (first run: 10 sec, subsequent: 0.2 sec)
```

---

**Day 3: Error Handling & Edge Cases**

**tests/test_researcher.py (continued):**
```python
@pytest.mark.vcr("cassettes/researcher_api_error.yaml")
def test_researcher_handles_api_error():
    """Test error handling (manually edited cassette)"""
    state = WorkflowState(query="test")
    result = researcher_node(state)

    assert "researcher" in result.completed_branches
    assert len(result.errors) > 0  # Error recorded
```

**Update implementation:**
```python
def researcher_node(state: WorkflowState) -> WorkflowState:
    """Research a topic using OpenAI GPT-4"""

    if not state.query or not state.query.strip():
        return state.model_copy(update={
            "research_results": [],
            "completed_branches": state.completed_branches | {"researcher"}
        })

    try:
        llm = ChatOpenAI(model="gpt-4")
        response = llm.invoke(f"Research: {state.query}")

        return state.model_copy(update={
            "research_results": [response.content],
            "completed_branches": state.completed_branches | {"researcher"}
        })
    except Exception as e:
        # Graceful error handling
        return state.model_copy(update={
            "errors": state.errors + [{"node": "researcher", "error": str(e)}],
            "completed_branches": state.completed_branches | {"researcher"}
        })
```

**Total time: 3 days** (1 day faster!)
**First real API test: Day 1 Afternoon**
**Confidence in production readiness: 95%** (all tests validate real API behavior)

---

## Side-by-Side Comparison

### Development Timeline

| Milestone | Mock-First | VCR-Based | Difference |
|-----------|------------|-----------|------------|
| **Setup** | 1 hour | 1.5 hours (+30 min for VCR) | +30 min |
| **First real API test** | Day 2 | Day 1 afternoon | **24 hours earlier** |
| **Researcher complete** | Day 2 | Day 1 end | **1 day faster** |
| **Writer complete** | Day 3 | Day 2 | **1 day faster** |
| **Integration test** | Day 4 | Day 2 afternoon | **1.5 days faster** |
| **Total time** | 4 days | 3 days | **25% faster** |

### Test Coverage

| Test Type | Mock-First | VCR-Based |
|-----------|------------|-----------|
| **Topology** | ✅ (mock) | ✅ (real) |
| **Unit tests** | ✅ (mock) | ✅ (real) |
| **Integration** | ✅ (real, day 4) | ✅ (real, day 2) |
| **Edge cases** | ⚠️ (mock only) | ✅ (real) |
| **Error handling** | ⚠️ (assumed) | ✅ (validated) |

### Cost Analysis

| Phase | Mock-First | VCR-Based |
|-------|------------|-----------|
| **Initial recording** | $0 | $2-5 (one-time) |
| **Development testing** | $10-20 (day 2-4) | $0 (cassette replay) |
| **CI/CD runs** | $0 (mock) or $50+ (real) | $0 (cassette) |
| **Total** | $10-20 or $60+ | **$2-5** |

### Confidence Level

| Aspect | Mock-First | VCR-Based |
|--------|------------|-----------|
| **Topology correct** | 100% | 100% |
| **Node logic works** | 80% (mocks passed) | 95% (real API passed) |
| **API integration** | 0% (day 1), 90% (day 2+) | **95% (day 1)** |
| **Error handling** | 40% (assumed) | 90% (tested) |
| **Production ready** | 60% | **95%** |

---

## Key Insights

### Mock-First Problems Revealed

1. **False confidence on Day 1**
   - All tests green with mocks
   - Zero validation of real API behavior
   - "It works!" → Actually, no idea if it works

2. **Late discovery of issues**
   - API structure mismatch discovered Day 2
   - Error handling bugs found Day 3
   - Integration issues found Day 4

3. **Wasted time on mocks**
   - Writing mock implementation (Day 1)
   - Writing tests for mocks (Day 1)
   - Debugging mock tests (Day 1)
   - Then rewriting for real implementation (Day 2)
   - **Double work!**

4. **IMPLEMENTED flag complexity**
   - Adds conditional logic to every node
   - Easy to forget to flip flag
   - Leaves dead code in production

### VCR-Based Advantages

1. **Immediate real API validation**
   - First test runs against real API
   - Discover integration issues on Day 1
   - No surprises later

2. **True TDD red → green cycle**
   - Test fails (no implementation)
   - Implement minimal code
   - Test passes (real API works!)

3. **Fast feedback loop**
   - First run: 5 seconds (real API)
   - Subsequent: 0.1 seconds (cassette)
   - CI/CD: 0.1 seconds (cassette)

4. **No mock maintenance**
   - No IMPLEMENTED flags
   - No mock logic to maintain
   - Single implementation path

5. **CI/CD efficiency**
   - No API keys needed in CI
   - Deterministic tests (same cassette)
   - Fast execution (cassette replay)

---

## Real-World Example: Bug Caught Early

### Scenario: API Returns Unexpected Format

**Mock-First Approach:**

**Day 1:** Mock returns `["Research result"]`
```python
IMPLEMENTED = False
def researcher_node(state):
    if not IMPLEMENTED:
        return state | {"research_results": ["Mock result"]}
```

**Day 1:** Test passes ✅
```python
def test_researcher():
    result = researcher_node(state)
    assert result.research_results == ["Mock result"]  # ✅ PASSES
```

**Day 2:** Real implementation
```python
IMPLEMENTED = True
def researcher_node(state):
    llm = ChatOpenAI()
    response = llm.invoke(f"Research: {state.query}")
    return state | {"research_results": [response.content]}  # Oops! response.content might be dict!
```

**Day 2:** Test fails! ❌
```python
# Real API returned: [{"content": "...", "role": "assistant"}]
# Expected: ["string content"]
# TypeError: expected str, got dict
```

**Result:** 1 day wasted debugging

---

**VCR-Based Approach:**

**Day 1 Afternoon:** Write test for real API
```python
@pytest.mark.vcr()
def test_researcher():
    result = researcher_node(state)
    assert isinstance(result.research_results[0], str)  # Type check
    assert len(result.research_results[0]) > 0
```

**Day 1 Afternoon:** Implement
```python
def researcher_node(state):
    llm = ChatOpenAI()
    response = llm.invoke(f"Research: {state.query}")
    return state | {"research_results": [response.content]}
```

**Day 1 Afternoon:** Run test → Immediate feedback
```bash
pytest tests/test_researcher.py -v

# If response.content is dict:
# ❌ FAILS immediately with TypeError
# Fix on Day 1, not Day 2!

# If response.content is str:
# ✅ PASSES, cassette created
```

**Result:** Bug caught same day, no wasted time

---

## Migration Path

### For Existing Mock-First Projects

**Step 1:** Install VCR (5 minutes)
```bash
uv add pytest-vcr --dev
```

**Step 2:** Configure VCR (10 minutes)
```python
# tests/conftest.py
@pytest.fixture(scope="module")
def vcr_config():
    return {
        "filter_headers": ["authorization"],
        "record_mode": "once",
        "cassette_library_dir": "tests/cassettes",
    }
```

**Step 3:** Convert one node as pilot (1 hour)
```python
# Before
def test_researcher_mock():
    with patch('nodes.researcher.ChatOpenAI'):
        result = researcher_node(state)
        assert result.research_results == ["Mock"]

# After
@pytest.mark.vcr()
def test_researcher_real():
    result = researcher_node(state)
    assert len(result.research_results) > 0
```

**Step 4:** Remove IMPLEMENTED flag (30 minutes)
```python
# Before
IMPLEMENTED = True
def researcher_node(state):
    if not IMPLEMENTED:
        return state | {"research_results": ["Mock"]}
    # Real implementation

# After
def researcher_node(state):
    # Just real implementation
    ...
```

**Step 5:** Record cassettes (5 minutes)
```bash
export OPENAI_API_KEY=sk-...
pytest tests/test_researcher.py -v
```

**Step 6:** Commit and verify (10 minutes)
```bash
git add tests/cassettes/ nodes/researcher.py tests/test_researcher.py
git commit -m "Migrate researcher node to VCR testing"

# Verify works without API key
unset OPENAI_API_KEY
pytest tests/test_researcher.py -v  # Should still pass!
```

**Total migration time per node: 2 hours**

---

## Conclusion

### When to Use Mock-First

- **Prototyping only** (not production code)
- **No API access yet** (design phase)
- **Teaching/learning** (focus on structure, not behavior)

### When to Use VCR-Based (Recommended)

- **All production LangGraph projects**
- **Any project with LLM integration**
- **Team environments** (deterministic tests)
- **CI/CD pipelines** (fast, reliable, no API keys)

### Bottom Line

**Mock-First:** Good for topology, poor for validation
**VCR-Based:** Good for topology AND validation, same speed after first run

**The user is right:** Tests should validate real API behavior from Day 1, not mock assumptions that may be wrong.

---

**Next Steps:**

1. Review this comparison with team
2. Decide on migration plan (pilot one node first?)
3. Update agent instructions to use VCR approach
4. Celebrate faster, more confident development! 🎉
