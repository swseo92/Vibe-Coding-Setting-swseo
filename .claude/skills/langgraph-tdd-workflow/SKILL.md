---
name: langgraph-tdd-workflow
description: Build testable LangGraph workflows using Test-Driven Development. This skill provides a systematic workflow for designing State schemas, implementing mock nodes, testing topology, and progressively implementing real nodes with comprehensive test coverage. Use when creating new LangGraph workflows or improving testability of existing ones.
---

# LangGraph TDD Workflow

Build maintainable, testable LangGraph workflows using Test-Driven Development principles.

## When to Use This Skill

Trigger this skill when:
- Creating a new LangGraph workflow from scratch
- Refactoring existing workflow to improve testability
- User asks for "LangGraph TDD", "testable workflow", or "how to test LangGraph"
- Building complex multi-agent systems with LangGraph
- Implementing workflows with parallel execution (split/merge patterns)

## Core Workflow

### Phase 1: Design & Documentation (Top-Down)

**1. Identify Nodes and Edges**
- List all required nodes (agents, tools, decision points)
- Define edge relationships (direct edges, conditional edges)
- Identify parallel execution points (fan-out/fan-in)

**2. Design State Schema**
- Use Pydantic for runtime validation
- Define all state fields with types
- Include metadata fields (completed_branches, errors, etc.)
- Save to `state_schema.py`

See `references/state-schema-pattern.md` for detailed patterns.

**3. Design Graph Topology**
- Document node connections
- Define routing logic (conditional edges)
- Sketch execution flow
- Save to `graph_topology.py` or design doc

**4. Create Node Specifications** 📝 (For Agent Orchestration)

For each node, create a specification document:

```
nodes/{node_name}_spec.md
```

**Template:** Use `assets/templates/node_spec_template.md`

**Why?** These specifications enable parallel agent execution in Phase 3.

**Include:**
- Purpose (1-2 sentences)
- Input/Output contract (precise types from State schema)
- Dependencies (LLM, tools, APIs)
- Behavior specification (step-by-step logic)
- Test requirements (minimum test cases)
- Expected mock output (for Phase 2)

**Example structure:**
```
project/
├── state_schema.py         # Phase 1.2
├── graph_topology.py       # Phase 1.3
└── nodes/                  # Phase 1.4
    ├── researcher_spec.md
    ├── writer_spec.md
    └── reviewer_spec.md
```

### Phase 2: Mock Implementation

**1. Create Mock Nodes**
- Implement ALL nodes as mocks initially
- Use `IMPLEMENTED = False` flag pattern
- Return fixed output matching node contract

**2. Build Graph Structure**
- Wire nodes with add_node()
- Add edges (direct and conditional)
- Compile graph

**3. Test Topology**
- Verify graph.nodes contains expected nodes
- Verify graph.edges matches design
- Run end-to-end with mock nodes
- Verify execution flow

See `references/topology-testing.md` for examples.

### Phase 3: Progressive Implementation

**Choose approach based on workflow size:**

#### Option A: Sequential (Main Claude) - For 1-2 nodes
**1. Select Node to Implement**
- Start with simplest/most independent node
- Or start with critical path nodes

**2. Write Node Unit Tests**
- Test with various input states
- Verify output state transformations
- Test edge cases and errors

**3. Implement Real Node**
- Change `IMPLEMENTED = True`
- Replace mock with real logic
- Run tests until passing

**4. Repeat** for each remaining node

#### Option B: Parallel (Agent Orchestration) ⚡ - For 3+ nodes

**Dispatch node implementations to specialized agents in parallel:**

Uses the dedicated `langgraph-node-implementer` agent (`.claude/agents/langgraph-node-implementer.md`) which is specifically designed for TDD-based node implementation.

```python
# For each node specification created in Phase 1
for spec_file in glob("nodes/*_spec.md"):
    node_name = spec_file.replace("nodes/", "").replace("_spec.md", "")

    agent = Task(
        subagent_type="langgraph-node-implementer",
        description=f"Implement {node_name} node",
        prompt=f"""
        Implement LangGraph node based on specification.

        Specification: {spec_file}
        State schema: state_schema.py
        Testing guidelines: docs/python/testing_guidelines.md (or testing_guidelines.md)

        The agent will:
        1. Read specification and state schema
        2. Write pytest tests first (in tests/)
        3. Implement mock node (IMPLEMENTED = False)
        4. Implement real logic (IMPLEMENTED = True)
        5. Run tests and verify all pass
        6. Provide implementation notes

        Use langchain_openai by default unless spec specifies otherwise.
        """
    )
    # Agents run in parallel automatically
```

**Benefits:**
- **Time savings:** 3 nodes = 3x speedup (10 min vs 30 min)
- **Context efficiency:** Each agent focuses on 1 node only
- **Independent work:** Nodes can be implemented simultaneously
- **Main orchestrates only:** Review and integration

**Workflow:**
1. Main Claude creates all node specifications (Phase 1.4)
2. Launch parallel agents for each node
3. Each agent: reads spec → writes tests → implements node
4. Main Claude: reviews outputs → runs integration tests

### Phase 4: Integration Testing

**1. After Each Node**
- Run partial integration (real + mocks)
- Verify node interactions

**2. Test Split/Merge Patterns**
- Verify parallel execution
- Test result aggregation
- Handle partial failures

See `references/split-merge-testing.md` for concrete examples.

**3. Final E2E Tests**
- All nodes real
- Test complete workflows
- Verify end results

## Test Pyramid

Follow this distribution:
- **40% Unit Tests** - Individual node logic
- **40% Integration Tests** - Node connections, routing, partial workflows
- **20% E2E Tests** - Complete workflow with mocked LLMs

## Key Patterns

### Mock Node with Flag

```python
# nodes/researcher.py
IMPLEMENTED = False  # Change to True when implementing

def researcher_node(state: WorkflowState) -> WorkflowState:
    if not IMPLEMENTED:
        # Mock - return fixed output
        return state | {"research_done": True, "results": ["mock"]}

    # Real implementation
    llm = ChatOpenAI()
    results = llm.invoke(state["query"])
    return state | {"research_done": True, "results": [results]}
```

### Pydantic State Schema

```python
from pydantic import BaseModel, Field

class WorkflowState(BaseModel):
    query: str
    results: list[str] = Field(default_factory=list)
    errors: list[dict] = Field(default_factory=list)
    completed_branches: set[str] = Field(default_factory=set)

    class Config:
        arbitrary_types_allowed = True
```

### Topology Test

```python
def test_workflow_topology():
    workflow = StateGraph(WorkflowState)
    workflow.add_node("researcher", researcher_node)
    workflow.add_node("writer", writer_node)
    workflow.add_edge("researcher", "writer")

    graph = workflow.compile()

    # Assert structure
    assert "researcher" in graph.nodes
    assert "writer" in graph.nodes

    # Test flow (all mocks)
    result = graph.invoke({"query": "test"})
    assert result["research_done"] == True
```

## Templates

Use templates in `assets/templates/` for quick scaffolding:
- `node_spec_template.md` - Node specification template (for Phase 1.4)
- `complete_example.py` - Full workflow example with all phases
- `state_schema.py` - Pydantic State template
- `mock_node.py` - Mock node pattern
- `test_topology.py` - Topology test template
- `test_split_merge.py` - Parallel execution test

## Progressive Workflow Summary

```
Day 1: Design
├─ Define State schema (Pydantic)
├─ Design graph topology
├─ Implement ALL nodes as mocks
└─ Test topology (graph structure + mock execution)

Day 2-4: Implementation
├─ For each node:
│  ├─ Write unit tests
│  ├─ Implement real logic (IMPLEMENTED = True)
│  ├─ Run tests
│  └─ Integration test (partial workflow)
└─ Iterate

Day 5: Integration
├─ Test split/merge patterns
├─ Test routing logic
├─ E2E tests
└─ Production ready
```

## References

Load these as needed for detailed guidance:
- `references/state-schema-pattern.md` - Pydantic patterns and validation
- `references/topology-testing.md` - Graph structure testing
- `references/split-merge-testing.md` - Parallel execution patterns
- `references/best-practices.md` - Claude & Codex consensus

## Best Practices

1. **Always start with topology test** - Catch wiring issues early
2. **Use IMPLEMENTED flags** - Clear visibility of progress
3. **Test routing separately** - Isolate conditional logic
4. **Validate all branches complete** - In merge nodes, check provenance
5. **Progressive integration** - Test after each node implementation
6. **Fail fast in development** - Graceful degradation only in production

---

**Version:** 1.0
**Based on:** Claude-Codex collaborative TDD debate
**Test Pyramid:** 40/40/20 (Unit/Integration/E2E)
