# Implementation Partner Agent MVP: Refined Plan

> **버전**: 2.0 (Codex 피드백 반영)
> **일시**: 2025-11-01
> **상태**: REFINE (프로토타입 전)
> **검토자**: Claude + Codex

---

## Executive Summary

**결론**: Phase 1 MVP를 **즉시 시작하지 않음**. 먼저 **프로토타입 + 계약 정의** 단계를 거침.

**이유**: Codex가 지적한 중요한 리스크와 누락 사항 존재:
- Guardrails 미정의 (어떤 리포/언어 허용?)
- Task hand-off 스펙 불명확
- 실패 처리 경로 부재
- MCP 통합 미검증

**새로운 로드맵**:
```
Week 1-2: Prototype & Contract Definition (NEW!)
Week 3-4: MVP Implementation (adjusted)
Week 5-6: Integration & Testing
```

---

## Codex의 핵심 피드백

### 1. MVP 스코프에 누락된 Guardrails

**문제**:
```yaml
# 현재 (불충분)
- Consume pytest-test-writer tasks ✓
- Generate minimal code ✓
- Run targeted tests ✓
- Iterate on failures ✓
- Post results to MCP ✓
```

**누락**:
- ❌ 어떤 repos/languages를 다룰 수 있는가?
- ❌ 리포 컨텍스트를 어떻게 획득하는가?
- ❌ "Minimal code" 변경의 명확한 스펙은?
- ❌ 반복 실패 후 에러 처리 경로는?
- ❌ 사람 편집과 충돌 시 어떻게 관리?

### 2. 타임라인 재평가

**원래 계획**: 2주 (너무 빡빡!)

**현실적 추정**:
```
MCP 플러밍 구축: 3-4일
pytest-test-writer 계약 정렬: 2-3일
Execution sandbox 안정화: 3-4일
Agent 프롬프트 작성/테스트: 2-3일
통합 테스트: 2-3일
Total: 12-17일 = 3-4주
```

**조정**: Phase 1을 **3-4주**로 재설정

### 3. 주요 리스크 (Codex 지적)

| 리스크 | 설명 | 대응 |
|--------|------|------|
| **Brittle task hand-off** | pytest-test-writer ↔ implementation-partner 통신이 깨지기 쉬움 | 명확한 계약 스펙 정의 |
| **Unclear authority** | 다른 agent와 권한 경계 모호 | Allowlist 기반 제한 |
| **Flaky tests** | 타겟 테스트가 불안정할 수 있음 | 재시도 로직 + 타임아웃 |
| **Non-deterministic iteration** | 반복 횟수 예측 불가 | 최대 3회 제한 |
| **MCP state drift** | 상태가 sync 안 됨 | Atomic write + 버전 관리 |
| **Incorrect schema changes** | API 변경이 잘못될 수 있음 | Dry-run 모드 + 사람 승인 |

### 4. 프로토타입 필수 (Vertical Slice)

**Codex 추천**:
> "Build a vertical slice where the agent handles a single constrained task in a throwaway repo"

**목적**:
- MCP 메시지 플로우 검증
- 테스트 선택 로직 검증
- 컨텍스트 전달 갭 발견
- 프로덕션 워크플로우 통합 전에 문제 해결

### 5. 최종 추천: REFINE

**Codex**:
> "Tighten the MVP contract (scope, safeguards, failure policy) and validate the integration path with a spike/prototype before moving to full execution."

**Action Items**:
1. Task contract 작성 (pytest-test-writer ↔ implementation-partner)
2. Prototype sandbox + MCP loop 생성
3. Phase 1 재평가

---

## 수정된 Phase 0: Prototype & Contract (Week 1-2)

### Objective
프로덕션 구현 전에 **vertical slice 검증** + **계약 정의**

### Deliverables

#### 1. Task Contract Specification

**파일**: `docs/agents/contracts/pytest-to-implementation.schema.json`

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "pytest-test-writer → implementation-partner Task Contract",
  "type": "object",
  "required": ["task_id", "created_by", "test_paths", "target_module", "intent"],
  "properties": {
    "task_id": {
      "type": "string",
      "format": "uuid",
      "description": "Unique task identifier"
    },
    "created_by": {
      "type": "string",
      "const": "pytest-test-writer"
    },
    "created_at": {
      "type": "string",
      "format": "date-time"
    },
    "schema_version": {
      "type": "string",
      "const": "1.0"
    },
    "language": {
      "type": "string",
      "enum": ["python"],
      "description": "Target language (MVP: Python only)"
    },
    "test_paths": {
      "type": "array",
      "items": {
        "type": "string",
        "pattern": "^tests/.*\\.py$"
      },
      "description": "List of test files to make pass",
      "minItems": 1
    },
    "target_module": {
      "type": "string",
      "pattern": "^src/.*\\.py$",
      "description": "Module to implement/modify"
    },
    "intent": {
      "type": "string",
      "minLength": 10,
      "maxLength": 500,
      "description": "High-level intent (what functionality to implement)"
    },
    "failing_tests": {
      "type": "array",
      "items": {"type": "string"},
      "description": "List of failing test names (e.g., test_login, test_validate)"
    },
    "repo_context": {
      "type": "object",
      "properties": {
        "project_root": {"type": "string"},
        "test_framework": {"type": "string", "const": "pytest"},
        "python_version": {"type": "string"},
        "dependencies": {"type": "array", "items": {"type": "string"}}
      }
    },
    "constraints": {
      "type": "object",
      "properties": {
        "max_lines_changed": {
          "type": "integer",
          "minimum": 1,
          "maximum": 200,
          "description": "Maximum lines of code to add/modify"
        },
        "allowed_dependencies": {
          "type": "array",
          "items": {"type": "string"},
          "description": "Libraries agent can import (allowlist)"
        },
        "forbidden_patterns": {
          "type": "array",
          "items": {"type": "string"},
          "description": "Code patterns to avoid (e.g., eval, exec)"
        }
      }
    }
  }
}
```

**핵심 추가 사항** (Codex 피드백 반영):
- `language`: Python만 (MVP)
- `repo_context`: 리포 정보 명시
- `constraints`: Guardrails 정의
  - `max_lines_changed`: 과도한 변경 방지
  - `allowed_dependencies`: 허용된 라이브러리만
  - `forbidden_patterns`: eval/exec 금지

#### 2. Guardrails Specification

**파일**: `docs/agents/implementation-partner-guardrails.md`

```markdown
# Implementation Partner Agent: Guardrails

## Scope Constraints

### Allowed Repositories
- Type: Python projects only
- Structure: Must have `tests/` and `src/` directories
- Test Framework: pytest only
- Version Control: Git required

### Allowed Languages
- Python 3.9+ (MVP)
- Future: JavaScript, Go (Phase 2+)

### Allowed File Operations
- ✅ CREATE: `src/**/*.py` (new modules)
- ✅ MODIFY: `src/**/*.py` (existing modules)
- ❌ DELETE: Any files (forbidden)
- ❌ MODIFY: `tests/**/*.py` (test files read-only)
- ❌ MODIFY: `pyproject.toml`, `requirements.txt` (dependency changes forbidden)

## Code Change Constraints

### Minimal Code Definition
"Minimal code" means:
- Implements ONLY what tests require (no extra features)
- No premature optimization
- No refactoring of unrelated code
- Max 200 lines added/modified per task

### Allowed Code Patterns
- ✅ Function definitions
- ✅ Class definitions (with type hints)
- ✅ Standard library imports
- ✅ Allowlisted third-party imports (from task contract)
- ✅ Exception handling (try/except)
- ✅ Type annotations

### Forbidden Code Patterns
- ❌ `eval()`, `exec()`, `compile()`
- ❌ `os.system()`, `subprocess` (security risk)
- ❌ File I/O outside project directory
- ❌ Network requests (unless explicitly allowed)
- ❌ Database modifications (unless explicitly allowed)
- ❌ Global state mutations

## Error Handling Policy

### Iteration Limits
- **Max iterations**: 3
- **Per-iteration timeout**: 60 seconds (pytest execution)
- **Total task timeout**: 5 minutes

### Failure Escalation Path
```
Iteration 1: Attempt implementation
  ↓ (test fails)
Iteration 2: Analyze failure, adjust code
  ↓ (test fails again)
Iteration 3: Last attempt with different approach
  ↓ (test still fails)
ESCALATE to human with detailed diagnostic
```

### Human Conflict Resolution
If agent detects human edits to target files during execution:
1. **Pause immediately**
2. **Save agent's proposed changes to `.mcp/drafts/`**
3. **Notify human**: "Conflict detected, please review"
4. **Wait for human decision**: apply agent changes | discard | merge manually

## Authority Boundaries

### vs pytest-test-writer
- pytest-test-writer: **Creates tests** (owns `tests/`)
- implementation-partner: **Implements code** (owns `src/`)
- No overlap

### vs static-analysis-agent
- implementation-partner: **Generates code**
- static-analysis-agent: **Reviews code** (runs after implementation)
- Gating: static-analysis approval required for merge

### vs langgraph-node-implementer
- implementation-partner: **General Python code**
- langgraph-node-implementer: **LangGraph nodes specifically**
- Decision: If task involves LangGraph → defer to langgraph-node-implementer

## Repo Context Acquisition

### Automatic Detection
```python
def acquire_repo_context(project_root: str) -> dict:
    """Auto-detect repo context"""
    return {
        "language": detect_language(project_root),  # Check pyproject.toml, package.json
        "test_framework": detect_test_framework(project_root),  # pytest.ini, jest.config
        "python_version": parse_pyproject_toml()["python"],
        "dependencies": parse_requirements(),
        "project_structure": analyze_directory_structure()
    }
```

### Required Files for Python Projects
- `pyproject.toml` or `requirements.txt` (dependencies)
- `pytest.ini` or `pyproject.toml[tool.pytest]` (pytest config)
- `src/` or `{project_name}/` (source code)
- `tests/` (test files)

### Rejection Criteria
Agent refuses to proceed if:
- No test framework detected
- Python version < 3.9
- No `tests/` directory
- Git not initialized
```

#### 3. Prototype Sandbox

**파일**: `prototypes/implementation-partner-mvp/`

**구조**:
```
prototypes/implementation-partner-mvp/
├── README.md                          # Prototype documentation
├── toy-project/                       # Throwaway test repo
│   ├── src/
│   │   └── calculator.py              # Empty (to be implemented)
│   ├── tests/
│   │   └── test_calculator.py         # Failing tests
│   ├── pyproject.toml
│   └── pytest.ini
│
├── .mcp/                              # MCP simulation
│   ├── diagnostics/
│   │   └── pytest-test-writer/
│   │       └── task-001.json          # Sample task
│   └── schemas/
│       └── task.schema.json
│
├── agent-prototype.py                 # Minimal agent implementation
├── run-prototype.sh                   # End-to-end test script
└── RESULTS.md                         # Findings from prototype
```

**Sample Task** (`.mcp/diagnostics/pytest-test-writer/task-001.json`):
```json
{
  "task_id": "550e8400-e29b-41d4-a716-446655440000",
  "created_by": "pytest-test-writer",
  "created_at": "2025-11-01T10:00:00Z",
  "schema_version": "1.0",
  "language": "python",
  "test_paths": ["tests/test_calculator.py"],
  "target_module": "src/calculator.py",
  "intent": "Implement a calculator with add and subtract methods",
  "failing_tests": ["test_add", "test_subtract"],
  "repo_context": {
    "project_root": "/path/to/toy-project",
    "test_framework": "pytest",
    "python_version": "3.11",
    "dependencies": []
  },
  "constraints": {
    "max_lines_changed": 50,
    "allowed_dependencies": [],
    "forbidden_patterns": ["eval", "exec"]
  }
}
```

**Sample Test** (`toy-project/tests/test_calculator.py`):
```python
import pytest
from src.calculator import Calculator

def test_add():
    """Calculator should add two numbers"""
    calc = Calculator()
    assert calc.add(2, 3) == 5

def test_subtract():
    """Calculator should subtract two numbers"""
    calc = Calculator()
    assert calc.subtract(5, 3) == 2
```

**Prototype Agent** (`agent-prototype.py`):
```python
#!/usr/bin/env python3
"""
Minimal Implementation Partner Agent Prototype

Tests:
1. Read task from MCP
2. Analyze failing tests
3. Generate minimal code
4. Run pytest
5. Iterate on failures (max 3)
6. Post results to MCP
"""

import json
import subprocess
from pathlib import Path
from typing import Dict, List

class ImplementationPartnerPrototype:
    """Minimal agent for vertical slice validation"""

    def __init__(self, mcp_root: Path):
        self.mcp_root = mcp_root
        self.max_iterations = 3

    def run(self, task_id: str) -> Dict:
        """Execute full agent workflow"""
        # Phase 1: Read task
        task = self.read_task(task_id)
        print(f"Task: {task['intent']}")

        # Phase 2: Analyze tests
        test_file = Path(task['test_paths'][0])
        test_content = test_file.read_text()
        print(f"Test file: {test_file}")

        # Phase 3-5: Implement with iterations
        for iteration in range(1, self.max_iterations + 1):
            print(f"\n=== Iteration {iteration} ===")

            # Generate code (simplified - real version uses LLM)
            code = self.generate_code(task, test_content, iteration)

            # Write to target module
            target_file = Path(task['target_module'])
            target_file.parent.mkdir(parents=True, exist_ok=True)
            target_file.write_text(code)
            print(f"Written to: {target_file}")

            # Run tests
            result = self.run_pytest(task['test_paths'])

            if result['success']:
                print("✅ Tests passed!")
                return self.post_result(task_id, "success", result, iteration)
            else:
                print(f"❌ Tests failed (iteration {iteration})")
                if iteration == self.max_iterations:
                    print("Max iterations reached, escalating to human")
                    return self.post_result(task_id, "failed", result, iteration)

    def read_task(self, task_id: str) -> Dict:
        """Read task from MCP"""
        task_file = self.mcp_root / "diagnostics/pytest-test-writer" / f"{task_id}.json"
        return json.loads(task_file.read_text())

    def generate_code(self, task: Dict, test_content: str, iteration: int) -> str:
        """Generate minimal code (simplified - real version uses LLM)"""
        # For prototype, hardcoded implementation
        return '''
class Calculator:
    """Simple calculator implementation"""

    def add(self, a: int, b: int) -> int:
        """Add two numbers"""
        return a + b

    def subtract(self, a: int, b: int) -> int:
        """Subtract two numbers"""
        return a - b
'''

    def run_pytest(self, test_paths: List[str]) -> Dict:
        """Run pytest on target tests"""
        result = subprocess.run(
            ["pytest", "-v"] + test_paths,
            capture_output=True,
            text=True,
            timeout=60
        )
        return {
            "success": result.returncode == 0,
            "stdout": result.stdout,
            "stderr": result.stderr
        }

    def post_result(self, task_id: str, status: str, test_result: Dict, iterations: int) -> Dict:
        """Post result to MCP"""
        result = {
            "task_id": task_id,
            "status": status,
            "iterations": iterations,
            "test_output": test_result['stdout'],
            "files_modified": ["src/calculator.py"]
        }

        result_file = self.mcp_root / "diagnostics/implementation-partner" / f"{task_id}.json"
        result_file.parent.mkdir(parents=True, exist_ok=True)
        result_file.write_text(json.dumps(result, indent=2))

        print(f"\nResult posted to: {result_file}")
        return result

if __name__ == "__main__":
    agent = ImplementationPartnerPrototype(mcp_root=Path(".mcp"))
    agent.run("550e8400-e29b-41d4-a716-446655440000")
```

**Run Script** (`run-prototype.sh`):
```bash
#!/bin/bash
set -e

echo "=== Implementation Partner Agent Prototype ==="
echo

# Setup
cd toy-project
python -m venv .venv
source .venv/bin/activate
pip install pytest

# Run agent
cd ..
python agent-prototype.py

# Verify
echo
echo "=== Verification ==="
cd toy-project
pytest tests/test_calculator.py -v

echo
echo "✅ Prototype complete! Check RESULTS.md for findings."
```

#### 4. Success Criteria for Prototype

**Must Prove**:
- [ ] Task JSON can be read from MCP
- [ ] Test file parsing works
- [ ] Code generation (even hardcoded) succeeds
- [ ] pytest execution captures results
- [ ] Iteration loop works (max 3)
- [ ] Result JSON posted to MCP
- [ ] End-to-end flow completes in <5 minutes

**Discovery Goals**:
- Gaps in task schema (what's missing?)
- MCP integration issues (file locking, permissions?)
- pytest selection logic (how to target specific tests?)
- Context passing problems (what info does agent need but lack?)

---

## 수정된 Phase 1: MVP Implementation (Week 3-4)

### Preconditions
- ✅ Prototype validated
- ✅ Task contract finalized
- ✅ Guardrails documented
- ✅ MCP schema stable

### Deliverables (adjusted)

1. **Production Agent File** (`.claude/agents/implementation-partner.md`)
   - Based on prototype learnings
   - Full system prompt with guardrails
   - Error handling from failure policy

2. **MCP Integration**
   - File-backed MCP server setup
   - `/diagnostics/{agent}/` directories
   - Schema validation

3. **pytest-test-writer Modification**
   - Add MCP task output
   - Use validated schema

4. **Integration Tests**
   - 5 sample scenarios (happy path + edge cases)
   - Guardrails enforcement tests
   - Failure escalation tests

### Adjusted Timeline
- Week 3: Production agent + MCP setup
- Week 4: pytest-test-writer integration + testing

---

## 수정된 Phase 2: Integration & Testing (Week 5-6)

### Deliverables

1. **Real-world Testing**
   - Test on 3 different Python projects
   - Measure: success rate, iteration count, time

2. **Performance Tuning**
   - Optimize iteration logic
   - Reduce unnecessary pytest runs

3. **Documentation**
   - User guide for implementation-partner
   - Troubleshooting guide

4. **Meta-testing**
   - Use meta-tester agent to validate implementation-partner
   - Publish health scorecard

---

## Risk Mitigation (Codex 지적 사항 대응)

| Risk | Mitigation | Validation |
|------|------------|------------|
| **Brittle hand-off** | Strict JSON schema + validation | Prototype tests 10 scenarios |
| **Unclear authority** | Guardrails doc + allowlist | Code review + meta-testing |
| **Flaky tests** | Retry logic (max 3) + timeout (60s) | Inject flaky test in prototype |
| **Non-deterministic iteration** | Max 3 iterations + escalation | Track iteration count in metrics |
| **MCP state drift** | Atomic writes + schema version | Concurrent access tests |
| **Incorrect schema changes** | Dry-run mode + human approval | Require approval for API changes |

---

## Next Actions (Revised)

### Week 1 (Immediate)
- [ ] Create prototype directory structure
- [ ] Write task contract JSON schema
- [ ] Write guardrails document
- [ ] Implement minimal agent prototype (Python script)
- [ ] Create toy-project with failing tests

### Week 2 (Validation)
- [ ] Run prototype end-to-end
- [ ] Document findings in RESULTS.md
- [ ] Adjust task schema based on gaps
- [ ] Refine guardrails based on edge cases
- [ ] Re-estimate Phase 1 timeline

### Week 3-4 (MVP)
- [ ] Only proceed if prototype successful
- [ ] Implement production agent
- [ ] Integrate with pytest-test-writer
- [ ] Test on real projects

---

## Decision Log

### 2025-11-01: REFINE Decision

**Decision**: Do NOT start Phase 1 immediately. Insert Phase 0 (Prototype & Contract).

**Reasoning** (Codex feedback):
- MVP scope missing critical guardrails
- 2-week timeline unrealistic without validation
- Key risks unaddressed (brittle hand-off, state drift, etc.)
- Prototype can flush out integration issues early

**Trade-off**:
- **Cost**: +2 weeks before MVP
- **Benefit**: Reduce risk of failed MVP, clarify requirements, realistic timeline

**Approval**: Accepted. Quality > Speed.

---

## Conclusion

### What Changed (v1 → v2)

| Aspect | v1.0 (Original) | v2.0 (Refined) |
|--------|-----------------|----------------|
| **Start Date** | Immediate | After 2-week prototype |
| **Timeline** | 2 weeks | 3-4 weeks (after prototype) |
| **Guardrails** | None | Comprehensive spec |
| **Contract** | Informal | JSON schema |
| **Validation** | None | Vertical slice prototype |
| **Risk Mitigation** | Minimal | Detailed per-risk plan |

### Codex's Impact

Codex prevented:
- ❌ Rushing into flawed MVP
- ❌ Discovering integration issues in production
- ❌ Wasting 2 weeks on wrong approach

Codex enabled:
- ✅ Structured contract definition
- ✅ Early validation via prototype
- ✅ Realistic timeline
- ✅ Comprehensive risk mitigation

### Final Recommendation

**START Phase 0 (Prototype & Contract)** - 2 weeks

Then re-evaluate for Phase 1 based on prototype findings.

**Success Metric**: If prototype succeeds with <5 schema adjustments and completes in <5 minutes, proceed to Phase 1.

---

**Document Version**: 2.0 (Refined)
**Status**: Ready for Phase 0
**Next Review**: After prototype completion
