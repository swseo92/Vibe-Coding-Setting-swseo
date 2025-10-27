# Node Specification: [Node Name]

## Purpose

[1-2 sentences describing what this node does and why it exists in the workflow]

## Input/Output Contract

### Input State (from WorkflowState)

```python
# Required fields this node reads from state
{
    "field_name": type,  # Description
    "another_field": type,  # Description
    # ...
}
```

### Output State (updates to WorkflowState)

```python
# Fields this node adds or modifies in state
{
    "result_field": type,  # Description
    "updated_field": type,  # Description
    "completed_branches": set[str],  # Add this node's name
    # ...
}
```

## Dependencies

- **LLM**: [ChatOpenAI / ChatAnthropic / None]
- **Tools**: [List any tools this node uses]
- **External APIs**: [List any external services]
- **Internal Dependencies**: [Other modules or utilities]

## Behavior Specification

Step-by-step logic this node should implement:

1. [First step - e.g., "Extract query from state"]
2. [Second step - e.g., "Call LLM with formatted prompt"]
3. [Third step - e.g., "Parse LLM response"]
4. [Fourth step - e.g., "Update state with results"]
5. [Error handling - e.g., "On error, add to state.errors list"]

### Error Handling

- **Validation errors**: [How to handle invalid input state]
- **LLM failures**: [Retry strategy, fallback behavior]
- **API errors**: [How to handle external service failures]

## Test Requirements

Minimum test cases that must be implemented:

### Unit Tests

1. **Happy path**: [Description of normal execution test]
2. **Edge case 1**: [Description - e.g., empty input]
3. **Edge case 2**: [Description - e.g., malformed data]
4. **Error case**: [Description - e.g., LLM timeout]

### Test Fixtures

```python
# Example input state for testing
test_input_state = {
    "field_name": "example value",
    # ...
}

# Expected output state
expected_output_state = {
    "result_field": "expected value",
    "completed_branches": {"node_name"},
    # ...
}
```

## Expected Mock Output (Phase 2)

For topology testing before real implementation:

```python
# Mock output when IMPLEMENTED = False
{
    "result_field": "mock result",
    "completed_branches": state.completed_branches | {"node_name"},
    # ... other fixed values
}
```

## Implementation Notes

### Performance Considerations
- [Any caching, rate limiting, or optimization requirements]

### Configuration
- [Environment variables, model parameters, etc.]

### Provenance Tracking
- [If part of split/merge pattern, how to track execution]

---

## Agent Implementation Checklist

When implementing this node, ensure:

- [ ] Follow IMPLEMENTED flag pattern (start with `IMPLEMENTED = False`)
- [ ] Create file: `nodes/[node_name].py`
- [ ] Create tests: `tests/test_[node_name].py` (pytest format)
- [ ] Implement mock logic first (returns expected mock output)
- [ ] Write all unit tests (use fixtures above)
- [ ] Verify tests pass with mock implementation
- [ ] Implement real logic
- [ ] Set `IMPLEMENTED = True`
- [ ] Verify all tests still pass
- [ ] Document any deviations from spec in comments

---

**Version**: 1.0
**Created**: [Date]
**State Schema Reference**: `state_schema.py`
**Graph Topology Reference**: `graph_topology.py`
