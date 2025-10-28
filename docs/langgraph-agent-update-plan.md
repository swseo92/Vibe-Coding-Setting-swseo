# LangGraph Node Implementer Agent Update Plan

**Concrete plan for transitioning from mock-first to VCR-based TDD**

---

## Summary

Based on analysis in `langgraph-tdd-analysis-real-vs-mock-api.md`, we recommend updating the `langgraph-node-implementer` agent to use **Hybrid VCR-Based TDD** instead of mock-first approach.

**Key Change:** Tests call real APIs from the start, with VCR recording/replaying responses for fast feedback and cost efficiency.

---

## Phase 1: Update Agent Instructions

### File to Update

`.claude/agents/langgraph-node-implementer.md`

### Changes Required

#### 1. Remove IMPLEMENTED Flag Pattern

**Current (lines 33-44):**
```markdown
4. **Implement Mock Node**: Create node file with IMPLEMENTED flag pattern:
   - Start with `IMPLEMENTED = False`
   - Return fixed mock output from specification
   - Ensure mock passes topology tests
   - Track provenance with `completed_branches`

5. **Implement Real Logic**: Replace mock with actual implementation:
   - Use langchain_openai by default (unless spec specifies otherwise)
   - Handle LLM calls with proper error handling
   - Update state following Pydantic contracts
   - Set `IMPLEMENTED = True` when complete
```

**Replace with:**
```markdown
4. **Implement Real Node with VCR Testing**: Create node file with real implementation:
   - Write tests with `@pytest.mark.vcr()` decorator (records first run, replays thereafter)
   - Implement real logic directly (no mock phase)
   - Use langchain_openai by default (unless spec specifies otherwise)
   - Handle LLM calls with proper error handling
   - Update state following Pydantic contracts
   - First test run records API responses (cassettes)
   - Subsequent runs replay cassettes (instant, free)
```

#### 2. Update Methodology Section

**Current Phase 2 (lines 71-108):**
```markdown
### Phase 2: Write Tests First (5-7 minutes)

1. **Create test file**: `tests/test_{node_name}.py`
2. **Import requirements**:
   ```python
   import pytest
   from nodes.{node_name} import {node_name}_node, IMPLEMENTED
   from state_schema import WorkflowState
   ```
3. **Write test cases** (following testing_guidelines.md):
   [Mock-based examples]
```

**Replace with:**
```markdown
### Phase 2: Write Tests First (5-7 minutes)

1. **Ensure VCR is installed and configured**:
   ```bash
   # Should already be in project dependencies
   uv add pytest-vcr --dev
   ```

2. **Verify conftest.py has VCR configuration**:
   ```python
   # tests/conftest.py
   import pytest

   @pytest.fixture(scope="module")
   def vcr_config():
       return {
           "filter_headers": ["authorization", "x-api-key"],
           "record_mode": "once",
           "cassette_library_dir": "tests/cassettes",
       }
   ```

3. **Create test file**: `tests/test_{node_name}.py`

4. **Import requirements**:
   ```python
   import pytest
   from nodes.{node_name} import {node_name}_node
   from state_schema import WorkflowState
   # No need to import IMPLEMENTED flag!
   ```

5. **Write test cases with VCR** (following testing_guidelines.md):
   ```python
   @pytest.mark.vcr()  # Automatic API recording/replay
   def test_{node_name}_happy_path():
       """Test normal execution with REAL API"""
       state = WorkflowState(
           field1="value1",
           field2="value2"
       )
       result = {node_name}_node(state)

       # Assert on REAL API behavior (not mock output!)
       assert result.output_field is not None
       assert len(result.output_field) > 0  # Check real content
       assert "{node_name}" in result.completed_branches

   @pytest.mark.vcr()
   def test_{node_name}_edge_case():
       """Test edge case with real API"""
       state = WorkflowState(field1="")  # Empty input
       result = {node_name}_node(state)

       # Verify graceful handling
       assert "{node_name}" in result.completed_branches
       # May have empty output or error - test real behavior

   @pytest.mark.vcr("cassettes/{node_name}_error.yaml")
   def test_{node_name}_handles_error():
       """Test error handling (edit cassette to inject error)"""
       state = WorkflowState(field1="trigger error")
       result = {node_name}_node(state)

       assert "{node_name}" in result.completed_branches
       assert len(result.errors) > 0 or result.output_field is None
   ```

6. **Run tests** → Should FAIL (NotImplementedError - no node yet)
   ```bash
   export OPENAI_API_KEY=sk-...  # Set API key for first recording
   pytest tests/test_{node_name}.py -v
   # Expected: FAILED (ImportError or NotImplementedError)
   ```

**This is the RED phase of TDD** - test fails as expected!
```

**Current Phase 3 (lines 110-156):**
```markdown
### Phase 3: Implement Mock Node (3-5 minutes)
[Mock implementation instructions]
```

**Replace with:**
```markdown
### Phase 3: Implement Real Node (10-15 minutes)

1. **Create node file**: `nodes/{node_name}.py`

2. **Implement with real logic immediately** (no mock phase):
   ```python
   """
   {Node Name} Node

   Purpose: [from specification]

   Input State:
   - field1: type
   - field2: type

   Output State:
   - result_field: type
   - completed_branches: set[str]
   """

   from langchain_openai import ChatOpenAI
   from langchain_core.messages import HumanMessage, SystemMessage

   def {node_name}_node(state: WorkflowState) -> WorkflowState:
       """
       [Purpose from specification]

       Args:
           state: Current workflow state

       Returns:
           Updated state with {node_name} results
       """
       try:
           # Step 1: Validate input
           if not state.field1 or not state.field1.strip():
               return state.model_copy(update={
                   "result_field": None,
                   "completed_branches": state.completed_branches | {"{node_name}"}
               })

           # Step 2: Call LLM
           llm = ChatOpenAI(model="gpt-4", temperature=0.7)
           response = llm.invoke([
               SystemMessage(content="[System prompt from spec]"),
               HumanMessage(content=f"[User prompt with {state.field1}]")
           ])

           # Step 3: Process response
           result_value = response.content

           # Step 4: Update state
           return state.model_copy(update={
               "result_field": result_value,
               "completed_branches": state.completed_branches | {"{node_name}"}
           })

       except Exception as e:
           # Step 5: Error handling (graceful degradation)
           error_record = {
               "node": "{node_name}",
               "error": str(e),
               "input": state.field1
           }
           return state.model_copy(update={
               "errors": state.errors + [error_record],
               "completed_branches": state.completed_branches | {"{node_name}"}
           })
   ```

3. **Run tests** → Should PASS (real API call, cassette created)
   ```bash
   pytest tests/test_{node_name}.py -v

   # Expected output:
   # test_{node_name}_happy_path ✅ PASSED (5 sec - real API call)
   # Creates: tests/cassettes/test_{node_name}_happy_path.yaml
   #
   # test_{node_name}_edge_case ✅ PASSED (3 sec - real API call)
   # Creates: tests/cassettes/test_{node_name}_edge_case.yaml
   ```

**This is the GREEN phase of TDD** - tests pass with real implementation!

4. **Verify cassettes created**:
   ```bash
   ls tests/cassettes/test_{node_name}*
   # Should see .yaml files for each test
   ```

5. **Run tests again** → Should be INSTANT (cassette replay)
   ```bash
   unset OPENAI_API_KEY  # No API key needed for replay!
   pytest tests/test_{node_name}.py -v

   # Expected output:
   # test_{node_name}_happy_path ✅ PASSED (0.1 sec - cassette replay)
   # test_{node_name}_edge_case ✅ PASSED (0.1 sec - cassette replay)
   ```
```

**Remove old Phase 4 (Real Implementation)** - no longer needed as we implement real from the start

**Update Phase 4 to Phase 5 (Verification):**
```markdown
### Phase 4: Verify and Commit (2-3 minutes)

1. **Run all tests**:
   ```bash
   pytest tests/test_{node_name}.py -v
   ```

2. **Check coverage** (if pytest-cov available):
   ```bash
   pytest tests/test_{node_name}.py --cov=nodes.{node_name} --cov-report=term-missing
   ```

3. **Commit code AND cassettes**:
   ```bash
   git add nodes/{node_name}.py tests/test_{node_name}.py tests/cassettes/
   git commit -m "Implement {node_name} node with VCR tests"
   ```

4. **Report results**:
   - List all tests passed
   - Show cassettes created
   - Document implementation decisions
   - Note any deviations from spec
```

#### 3. Update Output Format Section

**Current (lines 238-265):**
```markdown
### Files Created
- `nodes/{node_name}.py` (IMPLEMENTED = True)
- `tests/test_{node_name}.py`
```

**Replace with:**
```markdown
### Files Created
- `nodes/{node_name}.py` (real implementation)
- `tests/test_{node_name}.py` (VCR-based tests)
- `tests/cassettes/test_{node_name}_*.yaml` (recorded API responses)
```

#### 4. Update Example Section

**Current Workflow Example (lines 310-365):**
Replace entire example with VCR-based workflow showing:
- Phase 1: Write failing test with @pytest.mark.vcr()
- Phase 2: Implement real node
- Phase 3: Test passes, cassette created
- Phase 4: Subsequent runs use cassette

#### 5. Add VCR Prerequisites Section

Add new section after "Core Responsibilities":

```markdown
## Prerequisites

Before implementing nodes, ensure the project has VCR configured:

### 1. Install pytest-vcr

```bash
uv add pytest-vcr --dev
# Or: pip install pytest-vcr
```

### 2. Configure VCR in conftest.py

Ensure `tests/conftest.py` contains:

```python
import pytest
import os

@pytest.fixture(scope="module")
def vcr_config():
    """VCR configuration for recording/replaying API calls"""
    return {
        # Hide sensitive headers from cassettes
        "filter_headers": [
            "authorization",
            "x-api-key",
            "api-key",
        ],

        # Record mode:
        # - "once": Record once, replay thereafter (default)
        # - "new_episodes": Add new interactions, keep existing
        # - "none": Never record, fail if cassette missing
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
    """Verify API keys are available for initial recording"""
    if not os.getenv("OPENAI_API_KEY"):
        pytest.skip("OPENAI_API_KEY not set - required for initial recording")
```

### 3. Ensure .gitignore does NOT exclude cassettes

**Important:** Cassettes must be committed to git!

```bash
# .gitignore should NOT contain:
# tests/cassettes/  ❌ Do NOT add this line!
```

### 4. Set API key for first recording

```bash
export OPENAI_API_KEY=sk-...
# Or: add to .env file
```

After first recording, API key is not needed (tests use cassettes).
```

---

## Phase 2: Update Testing Guidelines

### File to Update

`docs/python/testing_guidelines.md` (or `templates/python/docs/testing_guidelines.md`)

### Changes Required

Add new section after "모킹 가이드라인":

```markdown
## VCR 기반 API 테스팅 (LangGraph 노드용)

LangGraph 노드는 LLM API를 호출하므로, 실제 API를 테스트하면서도 빠른 피드백을 위해 VCR(Video Cassette Recorder) 패턴을 사용합니다.

### 설치

```bash
uv add pytest-vcr --dev
```

### 설정 (conftest.py)

```python
# tests/conftest.py
import pytest

@pytest.fixture(scope="module")
def vcr_config():
    """VCR 설정 - API 호출 기록/재생"""
    return {
        "filter_headers": ["authorization", "x-api-key"],  # 민감 정보 제거
        "record_mode": "once",  # 처음만 기록, 이후 재생
        "cassette_library_dir": "tests/cassettes",
    }
```

### 테스트 작성

```python
import pytest

@pytest.mark.vcr()  # VCR 자동 기록/재생
def test_researcher_node():
    """
    첫 실행: 실제 OpenAI API 호출 및 응답 기록
    이후 실행: cassette에서 응답 재생 (즉시, 무료)
    """
    state = WorkflowState(query="quantum computing")
    result = researcher_node(state)

    # 실제 API 동작 검증
    assert len(result.research_results) > 0
    assert "quantum" in result.research_results[0].lower()
```

### 실행

```bash
# 첫 실행: 실제 API 호출 + 기록
export OPENAI_API_KEY=sk-...
pytest tests/test_researcher.py -v
# 생성: tests/cassettes/test_researcher_node.yaml

# 이후 실행: cassette 재생 (API 키 불필요!)
unset OPENAI_API_KEY
pytest tests/test_researcher.py -v  # 즉시 완료 (0.1초)
```

### Cassette 관리

```bash
# Cassette 재기록 (API 변경 시)
rm tests/cassettes/test_researcher_node.yaml
pytest tests/test_researcher.py -v

# 모든 cassette 재기록
rm -rf tests/cassettes/
pytest tests/ -v
```

### 에러 케이스 테스트

```python
# 방법 1: Cassette 수동 편집
@pytest.mark.vcr("cassettes/researcher_error.yaml")
def test_handles_api_error():
    # YAML 파일에서 status code를 500으로 수정
    result = researcher_node(state)
    assert len(result.errors) > 0

# 방법 2: 실제 에러 기록 (처음만)
@pytest.mark.vcr(record_mode="new_episodes")
def test_handles_rate_limit():
    # 실제 rate limit 에러 발생시키기
    ...
```

### 주의사항

- ✅ Cassette은 git에 커밋해야 함 (CI/CD에서 사용)
- ✅ 첫 실행 시 API 키 필수, 이후 불필요
- ✅ CI/CD에서는 `--vcr-record=none` 사용 (cassette만 사용)
- ❌ Cassette에 민감 정보 포함 금지 (filter_headers 사용)
```

---

## Phase 3: Update Templates

### 1. Update Node Specification Template

**File:** `.claude/skills/langgraph-tdd-workflow/assets/templates/node_spec_template.md`

**Changes:**

**Remove section (lines 83-94):**
```markdown
## Expected Mock Output (Phase 2)

For topology testing before real implementation:
[Mock output example]
```

**Replace with:**
```markdown
## Expected API Behavior (for VCR Testing)

For real API testing with VCR recording:

```python
# First test run: Real API call, record to cassette
# Subsequent runs: Instant replay from cassette

# Expected properties of API response:
{
    "result_field": str,  # Type: string
    "length": "> 50 characters",  # Minimum content length
    "keywords": ["keyword1", "keyword2"],  # Must contain these terms
    "completed_branches": set,  # Contains this node's name
}
```

### VCR Test Template

```python
@pytest.mark.vcr()
def test_{node_name}_with_real_api():
    """Test with real API (first run), cassette replay (subsequent runs)"""
    state = WorkflowState(field1="test input")
    result = {node_name}_node(state)

    # Assert on real API response properties
    assert isinstance(result.result_field, str)
    assert len(result.result_field) > 50
    assert any(kw in result.result_field.lower() for kw in ["keyword1", "keyword2"])
    assert "{node_name}" in result.completed_branches
```
```

**Update Implementation Checklist (lines 109-123):**

**Replace:**
```markdown
- [ ] Follow IMPLEMENTED flag pattern (start with `IMPLEMENTED = False`)
- [ ] Implement mock logic first (returns expected mock output)
- [ ] Verify tests pass with mock implementation
- [ ] Implement real logic
- [ ] Set `IMPLEMENTED = True`
```

**With:**
```markdown
- [ ] Ensure pytest-vcr is installed (`uv add pytest-vcr --dev`)
- [ ] Verify tests/conftest.py has VCR configuration
- [ ] Write tests with `@pytest.mark.vcr()` decorator
- [ ] Run tests (should FAIL - RED phase of TDD)
- [ ] Implement real logic (no mock phase)
- [ ] Run tests with API key (should PASS - GREEN phase, cassettes created)
- [ ] Run tests again without API key (should PASS - uses cassettes)
- [ ] Commit code, tests, AND cassettes to git
```

### 2. Update Complete Example

**File:** `.claude/skills/langgraph-tdd-workflow/assets/templates/complete_example.py`

**Changes:**

1. Remove all `IMPLEMENTED` flags and conditional mock logic
2. Add VCR imports and decorators
3. Update test examples to use `@pytest.mark.vcr()`
4. Show real implementation from the start

**Example replacement:**

**Old code (lines 34-52):**
```python
# Node 1: Researcher
RESEARCHER_IMPLEMENTED = False

def researcher_node(state: WorkflowState) -> WorkflowState:
    if not RESEARCHER_IMPLEMENTED:
        # Mock - fixed output
        return state | {
            "research_results": ["mock research result"],
            "completed_branches": state.completed_branches | {"researcher"}
        }

    # Real implementation (when RESEARCHER_IMPLEMENTED = True)
    from langchain_openai import ChatOpenAI
    llm = ChatOpenAI()
    result = llm.invoke(f"Research: {state.query}")
    ...
```

**New code:**
```python
# Node 1: Researcher (Real implementation from the start)
def researcher_node(state: WorkflowState) -> WorkflowState:
    """Research a topic using OpenAI GPT-4"""
    try:
        if not state.query or not state.query.strip():
            return state.model_copy(update={
                "research_results": [],
                "completed_branches": state.completed_branches | {"researcher"}
            })

        from langchain_openai import ChatOpenAI
        llm = ChatOpenAI(model="gpt-4", temperature=0.7)
        result = llm.invoke(f"Research: {state.query}")

        return state.model_copy(update={
            "research_results": [result.content],
            "completed_branches": state.completed_branches | {"researcher"}
        })
    except Exception as e:
        return state.model_copy(update={
            "errors": state.errors + [{"node": "researcher", "error": str(e)}],
            "completed_branches": state.completed_branches | {"researcher"}
        })
```

**Update tests section:**
```python
# Test with VCR
@pytest.mark.vcr()
def test_workflow_with_real_apis():
    """
    Test graph with all real APIs

    First run: Calls real APIs, records to cassette
    Subsequent runs: Replays from cassette (instant)
    """
    workflow = build_workflow()

    result = workflow.invoke(WorkflowState(query="quantum computing"))

    # Validate real API execution
    assert len(result.research_results) > 0
    assert len(result.draft) > 100
    assert result.approved in [True, False]  # Boolean from real reviewer
    assert "researcher" in result.completed_branches
    assert "writer" in result.completed_branches
    assert "reviewer" in result.completed_branches
```

---

## Phase 4: Update LangGraph TDD Workflow Skill

### File to Update

`.claude/skills/langgraph-tdd-workflow/skill.md`

### Changes Required

**Update Phase 2 section (lines 73-91):**

**Current:**
```markdown
### Phase 2: Mock Implementation

**1. Create Mock Nodes**
- Implement ALL nodes as mocks initially
- Use `IMPLEMENTED = False` flag pattern
- Return fixed output matching node contract
```

**Replace with:**
```markdown
### Phase 2: VCR Setup and Initial Testing

**1. Setup VCR for the project**
- Install: `uv add pytest-vcr --dev`
- Configure in `tests/conftest.py` (vcr_config fixture)
- Ensure cassette directory exists: `mkdir -p tests/cassettes`

**2. Create Mock Nodes (Optional, for topology testing only)**
- If you need to validate graph topology before implementing nodes:
  - Create minimal mock nodes that only update `completed_branches`
  - Use for topology tests ONLY
  - Then proceed to real implementation with VCR

**OR (Recommended): Skip mocks entirely**
- Write VCR tests immediately
- Implement real nodes directly
- First test run validates both topology AND behavior
```

**Update Phase 3 section (lines 93-160):**

Add VCR guidance to both Option A and Option B:

```markdown
### Phase 3: Progressive Implementation with VCR

**Choose approach based on workflow size:**

#### Option A: Sequential (Main Claude) - For 1-2 nodes

**1. Select Node to Implement**
- Start with simplest/most independent node
- Or start with critical path nodes

**2. Write Node Tests with VCR**
- Use `@pytest.mark.vcr()` decorator
- Test with various input states
- Verify output state transformations
- Test edge cases and errors
- **First run records real API responses to cassettes**

**3. Implement Real Node**
- No mock phase - implement real logic directly
- Run tests with API key (first time - records to cassette)
- Run tests again (replays cassette - instant)

**4. Repeat** for each remaining node

#### Option B: Parallel (Agent Orchestration) ⚡ - For 3+ nodes

**Dispatch node implementations to specialized agents in parallel:**

Each agent will:
1. Read specification and state schema
2. Setup VCR (ensure pytest-vcr installed)
3. Write pytest tests with @pytest.mark.vcr()
4. Implement real logic (no mock phase)
5. Run tests with API key (records cassettes)
6. Commit code + tests + cassettes
7. Provide implementation notes

**Main Claude:**
- Creates all node specifications (Phase 1.4)
- Launches parallel agents
- Reviews outputs
- Runs integration tests
- Verifies cassettes committed
```

---

## Phase 5: Create Migration Guide

### New File to Create

`docs/langgraph-tdd-migration-checklist.md`

**Content:**

```markdown
# Migration Checklist: Mock-First → VCR-Based TDD

Use this checklist when migrating existing LangGraph projects to VCR-based testing.

## Pre-Migration

- [ ] Read analysis: `docs/langgraph-tdd-analysis-real-vs-mock-api.md`
- [ ] Review comparison: `docs/langgraph-tdd-comparison-example.md`
- [ ] Read migration guide: `docs/langgraph-vcr-migration-guide.md`
- [ ] Backup current codebase: `git tag pre-vcr-migration`

## Setup

- [ ] Install VCR: `uv add pytest-vcr --dev`
- [ ] Add VCR config to `tests/conftest.py`
- [ ] Create cassette directory: `mkdir -p tests/cassettes`
- [ ] Ensure `.gitignore` does NOT exclude `tests/cassettes/`
- [ ] Set API key: `export OPENAI_API_KEY=sk-...`

## Migration (Per Node)

- [ ] **Backup current test file**: `cp tests/test_{node}.py tests/test_{node}.py.backup`
- [ ] **Remove mock logic from node**:
  - [ ] Delete `IMPLEMENTED = False` flag
  - [ ] Delete `if not IMPLEMENTED:` conditional
  - [ ] Keep only real implementation
- [ ] **Update test file**:
  - [ ] Remove `from unittest.mock import patch`
  - [ ] Remove `IMPLEMENTED` import
  - [ ] Add `@pytest.mark.vcr()` to all test functions
  - [ ] Update assertions to test real API behavior (not mock output)
  - [ ] Remove `@pytest.mark.skipif(not IMPLEMENTED, ...)` decorators
- [ ] **Record cassettes**:
  - [ ] Run tests: `pytest tests/test_{node}.py -v`
  - [ ] Verify cassettes created: `ls tests/cassettes/test_{node}*`
- [ ] **Test cassette replay**:
  - [ ] Unset API key: `unset OPENAI_API_KEY`
  - [ ] Run tests again: `pytest tests/test_{node}.py -v`
  - [ ] Should pass using cassettes (instant)
- [ ] **Commit changes**:
  - [ ] `git add nodes/{node}.py tests/test_{node}.py tests/cassettes/`
  - [ ] `git commit -m "Migrate {node} to VCR testing"`
- [ ] **Delete backup**: `rm tests/test_{node}.py.backup`

## Post-Migration

- [ ] Update project README with VCR usage
- [ ] Update CI/CD to use `--vcr-record=none` flag
- [ ] Document cassette refresh policy (weekly/monthly)
- [ ] Train team on VCR workflow
- [ ] Celebrate! 🎉

## Rollback (If Needed)

```bash
git reset --hard pre-vcr-migration
git tag -d pre-vcr-migration
```

## Troubleshooting

**Tests fail after migration:**
- Check API key is set for first recording
- Verify conftest.py has vcr_config fixture
- Check cassettes directory exists

**Cassettes not replaying:**
- Ensure cassettes are committed to git
- Verify cassette paths match test names
- Check vcr_config record_mode is "once"

**API calls still happening:**
- Run with `--vcr-record=none` to enforce cassette-only mode
- Check if cassette matching criteria changed

## Questions?

See `docs/langgraph-vcr-migration-guide.md` or ask in #langgraph-tdd
```

---

## Phase 6: Update Project Template

### File to Update

`templates/python/pyproject.toml`

### Changes Required

Add pytest-vcr to dev dependencies:

```toml
[project.optional-dependencies]
dev = [
    "pytest>=7.0.0",
    "pytest-cov>=4.0.0",
    "pytest-vcr>=1.0.2",  # Add this line
    "pytest-asyncio>=0.21.0",
]
```

### New File to Create

`templates/python/tests/conftest.py`

**Content:**

```python
"""
Pytest configuration for LangGraph projects with VCR support
"""
import pytest
import os

# VCR Configuration
@pytest.fixture(scope="module")
def vcr_config():
    """
    VCR configuration for recording/replaying API calls.

    First test run: Records real API responses to cassettes/
    Subsequent runs: Replays from cassettes (instant, no API key needed)
    """
    return {
        # Hide sensitive headers from recorded cassettes
        "filter_headers": [
            "authorization",
            "x-api-key",
            "api-key",
            "openai-api-key",
        ],

        # Record mode:
        # - "once": Record once, replay thereafter (default)
        # - "new_episodes": Add new interactions, keep existing
        # - "none": Never record, fail if cassette missing (CI/CD)
        # - "all": Always re-record
        "record_mode": "once",

        # Match requests on these attributes
        "match_on": ["method", "scheme", "host", "port", "path", "query", "body"],

        # Where to store cassettes
        "cassette_library_dir": "tests/cassettes",

        # Decode compressed responses for readability
        "decode_compressed_response": True,

        # Allow playback repeats (same cassette used multiple times)
        "allow_playback_repeats": True,
    }

# Ensure API keys for initial recording
@pytest.fixture(scope="session", autouse=True)
def check_api_keys():
    """
    Verify API keys are available for initial cassette recording.

    Skips tests if:
    - No cassettes exist AND
    - No API key provided

    This allows CI/CD to run with cassettes only (no API keys).
    """
    cassettes_exist = os.path.exists("tests/cassettes") and \
                      len(os.listdir("tests/cassettes")) > 0

    api_key_set = bool(os.getenv("OPENAI_API_KEY"))

    if not cassettes_exist and not api_key_set:
        pytest.skip(
            "No cassettes found and OPENAI_API_KEY not set. "
            "For initial recording, set OPENAI_API_KEY environment variable."
        )

# Optional: Set test environment variables
@pytest.fixture(scope="session", autouse=True)
def test_environment():
    """Set environment variables for testing"""
    os.environ["TEST_MODE"] = "true"
    yield
    # Cleanup after all tests
    if "TEST_MODE" in os.environ:
        del os.environ["TEST_MODE"]
```

---

## Phase 7: Rollout Plan

### Week 1: Internal Testing

1. **Update agent instructions** (Phase 1)
2. **Create test project** with new approach
3. **Build 3-node workflow** using updated agent
4. **Document any issues** encountered
5. **Refine instructions** based on findings

### Week 2: Documentation

1. **Finalize all documentation** (Phases 2-6)
2. **Create tutorial video** (optional)
3. **Update CLAUDE.md** to mention VCR approach
4. **Prepare announcement** for users

### Week 3: Gradual Rollout

1. **Announce change** to users
2. **Provide migration guide** for existing projects
3. **Offer migration support** (pair programming sessions)
4. **Collect feedback** and iterate

### Week 4: Full Adoption

1. **Update default templates** to use VCR
2. **Archive old mock-first examples** (keep for reference)
3. **Update training materials**
4. **Celebrate successful migration!** 🎉

---

## Success Metrics

Track these metrics to measure success:

| Metric | Before (Mock-First) | Target (VCR-Based) |
|--------|--------------------|--------------------|
| **Time to first real API test** | Day 2+ | Day 1 |
| **Test execution time** | 0.5s (mock) / 5+ min (real) | 0.1s (cassette) |
| **API cost per dev cycle** | $10-30 | $2-5 (one-time) |
| **CI/CD test time** | 1-5 min | 10-30 sec |
| **Confidence in production** | 60% | 95% |
| **Bug discovery timing** | Day 2-4 | Day 1 |

---

## Risk Mitigation

### Risk 1: VCR Learning Curve

**Mitigation:**
- Comprehensive documentation (✅ Created)
- Video tutorial (TODO)
- Pair programming sessions for first migration
- Clear examples in templates

### Risk 2: Cassette Management Complexity

**Mitigation:**
- Automated cassette refresh workflow (GitHub Actions)
- Clear guidelines on when to re-record
- Scripts to check cassette freshness
- Documentation on cassette editing for error cases

### Risk 3: Team Resistance to Change

**Mitigation:**
- Show concrete benefits (faster feedback, higher confidence)
- Provide migration support (not forcing immediate change)
- Keep old approach documented for reference
- Gradual rollout (not big bang)

### Risk 4: Cassette Repository Size

**Mitigation:**
- Use Git LFS for large cassettes (if needed)
- Compress cassette responses (VCR config option)
- Prune old cassettes periodically
- Monitor repository size

---

## Open Questions

1. **Should we support both approaches?**
   - Option A: VCR only (recommended)
   - Option B: Let users choose (more complexity)
   - **Recommendation:** VCR only, document mock-first as "legacy" approach

2. **How often to refresh cassettes?**
   - Weekly? Monthly? Quarterly?
   - **Recommendation:** Monthly automated refresh via GitHub Actions

3. **Should cassettes be required in CI?**
   - `--vcr-record=none` enforces cassette-only mode
   - **Recommendation:** Yes, enforce in CI to ensure cassettes committed

4. **What about very expensive models (e.g., GPT-4-32k)?**
   - VCR still helps (one-time cost)
   - Consider using cheaper model for tests if feasible
   - **Recommendation:** Document cost considerations in node specs

---

## Next Steps

1. **Review this plan** with team
2. **Decide on rollout timeline**
3. **Begin Phase 1** (update agent instructions)
4. **Test internally** (Week 1)
5. **Roll out gradually** (Weeks 2-4)
6. **Measure success** (track metrics)
7. **Iterate based on feedback**

---

**Questions or concerns?** Open an issue or discuss in #langgraph-tdd channel.
