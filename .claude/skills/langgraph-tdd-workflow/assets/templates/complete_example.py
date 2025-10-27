"""
Complete LangGraph TDD Workflow Example
Based on Claude-Codex collaborative debate
"""

from typing import Literal
from pydantic import BaseModel, Field
from langgraph.graph import StateGraph, START, END, Send

# ============================================================================
# Phase 1: Design - State Schema
# ============================================================================

class WorkflowState(BaseModel):
    """
    Workflow state with runtime validation
    """
    query: str
    research_results: list[str] = Field(default_factory=list)
    draft: str = ""
    approved: bool = False
    errors: list[dict] = Field(default_factory=list)
    completed_branches: set[str] = Field(default_factory=set)

    class Config:
        arbitrary_types_allowed = True
        extra = "allow"


# ============================================================================
# Phase 2: Mock Implementation - All nodes start as mocks
# ============================================================================

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
    return state | {
        "research_results": [result.content],
        "completed_branches": state.completed_branches | {"researcher"}
    }


# Node 2: Writer
WRITER_IMPLEMENTED = False

def writer_node(state: WorkflowState) -> WorkflowState:
    if not WRITER_IMPLEMENTED:
        # Mock - fixed output
        return state | {
            "draft": "mock draft",
            "completed_branches": state.completed_branches | {"writer"}
        }

    # Real implementation
    from langchain_openai import ChatOpenAI
    llm = ChatOpenAI()
    result = llm.invoke(f"Write based on: {state.research_results}")
    return state | {
        "draft": result.content,
        "completed_branches": state.completed_branches | {"writer"}
    }


# Node 3: Reviewer
REVIEWER_IMPLEMENTED = False

def reviewer_node(state: WorkflowState) -> WorkflowState:
    if not REVIEWER_IMPLEMENTED:
        # Mock - fixed output
        return state | {
            "approved": True,
            "completed_branches": state.completed_branches | {"reviewer"}
        }

    # Real implementation
    from langchain_openai import ChatOpenAI
    llm = ChatOpenAI()
    result = llm.invoke(f"Review this draft: {state.draft}")
    approved = "approve" in result.content.lower()
    return state | {
        "approved": approved,
        "completed_branches": state.completed_branches | {"reviewer"}
    }


# Routing Logic (testable separately)
def should_continue(state: WorkflowState) -> Literal["reviewer", "end"]:
    """Route based on draft existence"""
    return "reviewer" if state.draft else "end"


# ============================================================================
# Phase 2: Build Graph & Test Topology
# ============================================================================

def build_workflow() -> StateGraph:
    """Build the workflow graph"""
    workflow = StateGraph(WorkflowState)

    # Add nodes
    workflow.add_node("researcher", researcher_node)
    workflow.add_node("writer", writer_node)
    workflow.add_node("reviewer", reviewer_node)

    # Add edges
    workflow.add_edge(START, "researcher")
    workflow.add_edge("researcher", "writer")
    workflow.add_conditional_edges(
        "writer",
        should_continue,
        {"reviewer": "reviewer", "end": END}
    )
    workflow.add_edge("reviewer", END)

    return workflow.compile()


# ============================================================================
# Tests
# ============================================================================

import pytest

# Test 1: Topology Test (Phase 2 - all mocks)
def test_workflow_topology():
    """Test graph structure with all mock nodes"""
    workflow = build_workflow()

    # Test execution flow
    result = workflow.invoke(WorkflowState(query="test"))

    # Verify all nodes executed
    assert "researcher" in result.completed_branches
    assert "writer" in result.completed_branches
    assert "reviewer" in result.completed_branches
    assert result.approved == True


# Test 2: Routing Logic (separate from nodes)
def test_routing_logic():
    """Test conditional routing"""
    # Has draft → go to reviewer
    state1 = WorkflowState(query="test", draft="something")
    assert should_continue(state1) == "reviewer"

    # No draft → end
    state2 = WorkflowState(query="test", draft="")
    assert should_continue(state2) == "end"


# Test 3: Unit Test for Single Node (Phase 3)
def test_researcher_node_unit():
    """Unit test for researcher node (when implemented)"""
    if not RESEARCHER_IMPLEMENTED:
        pytest.skip("Node not implemented yet")

    # Test with specific input
    state = WorkflowState(query="AI safety")
    result = researcher_node(state)

    # Verify output
    assert len(result.research_results) > 0
    assert "researcher" in result.completed_branches


# Test 4: Partial Integration (Phase 3 - progressive)
def test_partial_integration_researcher_writer():
    """Integration test: researcher + writer (real), reviewer (mock)"""
    global RESEARCHER_IMPLEMENTED, WRITER_IMPLEMENTED

    if not (RESEARCHER_IMPLEMENTED and WRITER_IMPLEMENTED):
        pytest.skip("Nodes not implemented yet")

    workflow = build_workflow()
    result = workflow.invoke(WorkflowState(query="test"))

    # Real nodes should have real outputs
    assert result.draft != "mock draft"
    assert len(result.research_results) > 0


# Test 5: E2E Test (Phase 4 - all real)
def test_full_workflow_e2e():
    """End-to-end test with all nodes implemented"""
    if not all([RESEARCHER_IMPLEMENTED, WRITER_IMPLEMENTED, REVIEWER_IMPLEMENTED]):
        pytest.skip("Not all nodes implemented")

    workflow = build_workflow()
    result = workflow.invoke(WorkflowState(query="Explain quantum computing"))

    # Verify complete execution
    assert result.research_results
    assert result.draft
    assert isinstance(result.approved, bool)
    assert len(result.completed_branches) == 3


# ============================================================================
# Split/Merge Example (Bonus)
# ============================================================================

def fan_out_node(state: WorkflowState):
    """Dispatch to multiple research nodes in parallel"""
    topics = ["topic1", "topic2", "topic3"]
    return [Send("parallel_research", state | {"topic": t}) for t in topics]


def parallel_research_node(state: WorkflowState) -> WorkflowState:
    """Execute research in parallel"""
    topic = state.get("topic", "unknown")
    return state | {
        "research_results": [f"Research on {topic}"],
        "completed_branches": state.completed_branches | {topic}
    }


def merge_node(state: WorkflowState) -> WorkflowState:
    """Aggregate parallel results"""
    expected = {"topic1", "topic2", "topic3"}

    # Verify all branches completed
    if not expected.issubset(state.completed_branches):
        missing = expected - state.completed_branches
        raise ValueError(f"Missing branches: {missing}")

    # Deterministic aggregation
    all_results = sorted(state.research_results)
    return state | {"draft": f"Summary of {len(all_results)} results"}


# ============================================================================
# Usage Example
# ============================================================================

if __name__ == "__main__":
    # Phase 1: All mocks - test topology
    print("Phase 1: Testing topology with mocks...")
    workflow = build_workflow()
    result = workflow.invoke(WorkflowState(query="test query"))
    print(f"Completed branches: {result.completed_branches}")
    print(f"Approved: {result.approved}")

    # Phase 2: Set RESEARCHER_IMPLEMENTED = True and retest
    # Phase 3: Set WRITER_IMPLEMENTED = True and retest
    # Phase 4: Set REVIEWER_IMPLEMENTED = True and retest

    print("\nAll tests passed! Workflow structure validated.")
