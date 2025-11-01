# Claude Code Agent 전략: Claude vs Codex 토론

> **일시**: 2025-11-01
> **참여자**: Claude (Anthropic Sonnet 4.5) vs Codex (OpenAI GPT-5-Codex)
> **주제**: Claude Code Agent 기능의 효과적 활용 방안
> **결과**: 5개 신규 agent 제안 + 3개 기존 agent 개선 + 구현 로드맵

---

## 토론 요약

### Claude의 현황 분석

**현재 Agent (3개)**:
1. `pytest-test-writer` (haiku, green) - pytest 테스트 자동 생성
2. `langgraph-node-implementer` (haiku, blue) - TDD 기반 LangGraph 노드 구현
3. `meta-tester` (sonnet, orange) - Claude Code 자체 테스트

**강점**:
- 명확한 단일 책임
- 실용적인 TDD 워크플로우 (VCR cassette)
- 메타 테스팅으로 품질 보증

**약점**:
- 테스트 생성과 구현 사이의 갭
- 프로덕션 코드 품질 관리 부재
- 문서화 자동화 없음

---

## Codex의 분석: Agent Gaps (5가지)

### 1. 프로덕션 코딩 태스크 부재
**문제**:
- 리팩토링 자동화 없음
- 기능 스캐폴딩 없음
- 버그 트리아지 자동화 없음
- 테스트 생성과 구현 사이 수동 작업 필요

**영향**:
- TDD 사이클이 완전히 자동화되지 않음
- 개발자가 여전히 반복 작업 수행

### 2. 아키텍처/표준 큐레이션 부재
**문제**:
- 코딩 표준 강제 없음
- 보안 베이스라인 체크 없음
- 의존성 위생 관리 없음
- 아키텍처 패턴 검증 없음

**영향**:
- 코드 품질이 일관되지 않음
- 보안 취약점 미발견
- 기술 부채 누적

### 3. 문서화/DX 자동화 부재
**문제**:
- README 업데이트 수동
- 릴리즈 노트 작성 수동
- API 문서 생성 수동

**영향**:
- 문서가 코드와 sync 되지 않음
- 새로운 팀원 온보딩 어려움

### 4. 툴체인 오케스트레이션 부재
**문제**:
- 환경 설정 자동화 없음
- 설정 drift 감지 없음
- CI 패리티 체크 없음

**영향**:
- "내 컴퓨터에서는 되는데" 문제
- CI와 로컬 환경 불일치

### 5. 런타임 텔레메트리 피드백 부재
**문제**:
- 프로파일링 결과 활용 안 함
- 회귀 리포트 자동 분석 없음
- 성능 저하 감지 수동

**영향**:
- 프로덕션 이슈 사후 대응
- 성능 문제 늦게 발견

---

## Codex의 제안: 5가지 새로운 Agent

### 1. Implementation Partner Agent ⭐ (최우선)

**목적**: pytest-test-writer가 생성한 실패하는 테스트를 받아서 최소한의 코드 변경으로 통과시킴

**워크플로우**:
```
pytest-test-writer (RED)
  ↓ (구조화된 작업 지시서 → MCP)
implementation-partner
  ↓ (코드 생성 + pytest 실행)
langgraph-node-implementer (GREEN)
  ↓ (결과 피드백 → MCP)
implementation-partner (iterate if failed)
```

**기술 스택**:
- **모델**: Sonnet (계획/번역 품질) + Haiku fallback (tight loop)
- **언어 전략**: 플러그인 방식 (Python 먼저, JS/Go 추후)
- **상태 관리**: LangGraph state store 또는 SQLite (task ID 키)
- **TDD 강제**: 코드 작성 후 항상 `pytest -k <affected>` 실행
- **피드백 루프**: 실패 시 diagnostics → MCP → 재시도

**MCP 작업 지시서 스키마**:
```json
{
  "task_id": "uuid",
  "created_by": "pytest-test-writer",
  "test_paths": ["tests/test_auth.py::test_login"],
  "target_module": "src/auth.py",
  "intent": "Implement login function with password validation",
  "failing_tests": ["test_login", "test_login_invalid_password"],
  "timestamp": "2025-11-01T10:30:00Z",
  "schema_version": "1.0"
}
```

**Agent 설정 (초안)**:
```yaml
---
name: implementation-partner
description: Consumes failing tests from pytest-test-writer and implements minimal code to make them pass. Triggers automatically after test generation or explicitly when user requests TDD implementation.
tools: Read, Write, Edit, Bash
model: sonnet
color: purple
---

You are a TDD implementation specialist. Your mission is to close the RED → GREEN cycle by implementing minimal code that makes failing tests pass.

## Core Responsibilities

1. **Consume Test Work Orders**: Read structured task from MCP (`/diagnostics/pytest-test-writer/<task-id>.json`)
2. **Analyze Failing Tests**: Understand what behavior is expected
3. **Implement Minimal Code**: Write the simplest code that makes tests pass
4. **Run Targeted Tests**: Execute `pytest -k <affected>` after implementation
5. **Iterate on Failures**: If tests still fail, analyze diagnostics and retry
6. **Post Results to MCP**: Update `/diagnostics/implementation-partner/<task-id>.json`

## Workflow

### Phase 1: Read Work Order (1-2 min)
- Pull task from MCP: `/diagnostics/pytest-test-writer/<task-id>.json`
- Extract: test paths, target module, intent, failing tests

### Phase 2: Analyze Tests (2-3 min)
- Read test file to understand expected behavior
- Identify: inputs, outputs, edge cases
- Check existing code in target module (if any)

### Phase 3: Implement Code (5-10 min)
- Write minimal implementation (no over-engineering)
- Follow project patterns (check similar files)
- Add type hints and docstrings
- Handle edge cases from tests

### Phase 4: Run Tests (1 min)
```bash
pytest -k "test_login or test_login_invalid" -v
```

### Phase 5: Iterate or Complete (2-5 min)
- If PASS: Post success to MCP, mark task complete
- If FAIL: Analyze error, update code, retry (max 3 iterations)
- Post diagnostics to MCP for downstream agents

## Quality Criteria

- All targeted tests pass
- No regressions (run full test suite if time permits)
- Code follows project style
- Type hints present
- Docstrings added

## MCP Integration

**Read from**:
- `/diagnostics/pytest-test-writer/<task-id>.json` (work orders)

**Write to**:
- `/diagnostics/implementation-partner/<task-id>.json` (results)
```json
{
  "task_id": "uuid",
  "status": "success | failed | needs_retry",
  "tests_passed": ["test_login"],
  "tests_failed": ["test_login_invalid_password"],
  "iterations": 2,
  "files_modified": ["src/auth.py"],
  "next_action": "langgraph-node-implementer | retry | manual_review"
}
```
```

### 2. Static Analysis & Security Agent

**목적**: 린터/SAST 실행, 시크릿 플래깅, 보안 취약점 탐지

**도구 체인**:
- **Ruff**: Lint + autofix (단계별 도입)
  - Phase 1: `ruff check` (report-only)
  - Phase 2: `ruff check --fix` (allowlist 기반)
  - Phase 3: `ruff check --fix --unsafe-fixes` (신뢰 후)
- **Mypy**: Type coverage (report-only)
- **Bandit**: Security scanning (report-only)
- **Semgrep**: Custom rules (선택적, 룰셋 정의 후)

**GitHub Security Advisory 통합**:
```python
# High severity 발견 시 자동 draft 생성
POST /repos/{owner}/{repo}/security-advisories
{
  "summary": "SQL Injection in user_service.py",
  "severity": "high",
  "description": "...",
  "vulnerabilities": [...]
}
```

**상태**: Manual publish (신뢰 구축 후 자동화)

**MCP 출력**:
```json
{
  "findings": [
    {
      "tool": "bandit",
      "severity": "high",
      "file": "src/user.py",
      "line": 45,
      "rule": "B608",
      "message": "SQL injection vulnerability",
      "fix": "Use parameterized queries"
    }
  ],
  "advisory_draft_url": "https://github.com/.../security-advisories/..."
}
```

### 3. Knowledge Steward Agent

**목적**: 문서, 체인지로그, 다이어그램, MCP 리소스 인덱스 유지

**책임**:
- README.md 업데이트 (기능 추가 시)
- CHANGELOG.md 생성 (커밋 메시지 기반)
- API 문서 생성 (docstring → Markdown)
- 아키텍처 다이어그램 업데이트 (Mermaid)
- MCP 리소스 카탈로그 관리

**트리거**:
- 코드 변경 후 (hook)
- 릴리즈 전 (slash command)
- 명시적 요청

### 4. Observability Agent

**목적**: 로그/트레이스 읽기, 실패를 코드 변경과 연관, 대시보드/알림 표시

**기능**:
- 로그 파일 분석 (에러 패턴 식별)
- 트레이스 상관관계 분석 (어떤 커밋이 문제?)
- 메트릭 추세 분석 (성능 저하 감지)
- Slack/Discord 알림

**통합**:
- Prometheus/Grafana
- Sentry
- CloudWatch/DataDog

### 5. Release Sherpa Agent

**목적**: 릴리즈 체크리스트 준비, 버전 검증, 태깅/아티팩트 퍼블리싱 자동화

**체크리스트**:
- [ ] 모든 테스트 통과
- [ ] CHANGELOG.md 업데이트
- [ ] 버전 번호 일관성 (pyproject.toml, __init__.py, docs)
- [ ] Git 태그 생성
- [ ] GitHub Release 생성
- [ ] PyPI/npm 퍼블리시
- [ ] Docker 이미지 빌드/푸시

---

## 기존 Agent 개선 방안

### pytest-test-writer 업그레이드

**현재**: 테스트 코드 생성

**추가 기능**:
1. **Coverage 텔레메트리**:
   ```bash
   pytest --cov=src --cov-report=json
   # Parse coverage.json → MCP
   ```
   - 현재 커버리지 표시
   - 미커버 영역 하이라이트
   - 목표 커버리지 (예: 80%) 체크

2. **Auto-generate Fixtures**:
   - Factory 라이브러리 (factory_boy, Faker) 활용
   - 공통 픽스처 자동 감지 및 생성

3. **Mock Validation**:
   - Mock 객체가 실제 객체와 일치하는지 검증 (reflection)
   - 인터페이스 변경 시 mock도 업데이트

**구현**:
```yaml
# 시스템 프롬프트 추가
After generating tests:
1. Run `pytest --cov --cov-report=json`
2. Parse coverage.json
3. Report uncovered lines
4. Suggest additional tests for <80% coverage
5. Post coverage data to MCP: `/diagnostics/pytest-test-writer/coverage.json`
```

### langgraph-node-implementer 업그레이드

**현재**: VCR 기반 TDD LangGraph 노드 구현

**추가 기능**:
1. **Architectural Guardrails**:
   - 프로젝트 아키텍처 패턴 준수 체크
   - 의존성 주입 패턴 강제
   - 레이어 분리 검증 (nodes, services, utils)

2. **VCR Fixtures → MCP**:
   ```bash
   # Cassette 자동 공유
   tests/cassettes/*.yaml → /fixtures/vcr/{suite}/{name}.json
   ```
   - 팀 전체가 동일한 API 응답 공유
   - CI에서 cassette-only 모드 강제

3. **Pre-GREEN Linting**:
   ```bash
   # 코드 작성 후, 테스트 전에 린트
   ruff check nodes/{node_name}.py
   mypy nodes/{node_name}.py
   # 통과해야만 GREEN phase 진행
   ```

**구현**:
```yaml
# Phase 3.5: Lint Before Test (추가)
After implementing code, before running tests:
1. Run `ruff check {file}` → must pass
2. Run `mypy {file}` → must pass (or allowlist)
3. If lint fails, fix and retry
4. Only then run pytest
5. Copy cassettes to MCP: `/fixtures/vcr/`
```

### meta-tester 업그레이드

**현재**: subprocess 기반 agent/command/workflow 테스트

**추가 기능**:
1. **Broader Scenario Library**:
   - 병렬 실행 테스트 (여러 agent 동시 호출)
   - Flaky command 재시도 테스트
   - 타임아웃 시나리오 테스트

2. **Chaos/Failure Injection**:
   ```python
   # Subprocess 실패 시뮬레이션
   subprocess.run(..., env={"FAIL_ON_PURPOSE": "1"})
   # Network 실패 시뮬레이션
   # 디스크 full 시뮬레이션
   ```

3. **Agent Health Scorecards**:
   ```json
   {
     "agent": "pytest-test-writer",
     "health_score": 95,
     "success_rate": 0.95,
     "avg_duration": 15.3,
     "failure_modes": ["timeout on large files"],
     "last_updated": "2025-11-01"
   }
   ```
   - 각 agent의 성공률 추적
   - 느린 agent 식별
   - 실패 패턴 분석

**구현**:
```yaml
# 새 테스트 시나리오 추가
Expanded test scenarios:
1. Parallel agent execution (2+ agents)
2. Flaky command retry (random failures)
3. Timeout scenarios (long-running tasks)
4. Chaos injection (network failure, disk full)
5. Publish scorecards to `/diagnostics/meta-tester/health.json`
```

---

## Agent Pipeline Best Practices

### 1. Explicit Hand-off Artifacts

**원칙**: Agent 간 통신은 MCP resources를 통해서만

```
pytest-test-writer
  ↓ writes: /diagnostics/pytest-test-writer/<task-id>.json

implementation-partner
  ↓ reads: above
  ↓ writes: /diagnostics/implementation-partner/<task-id>.json

static-analysis-agent
  ↓ reads: above
  ↓ writes: /diagnostics/static-analysis/<task-id>.json

knowledge-steward
  ↓ reads: all above
  ↓ writes: README.md, CHANGELOG.md
```

**스키마 표준화**:
```json
{
  "task_id": "uuid",
  "created_by": "agent-name",
  "created_at": "ISO-8601",
  "schema_version": "1.0",
  "status": "pending | in_progress | success | failed",
  "payload": { /* agent-specific */ }
}
```

### 2. Gating 메커니즘

**원칙**: 이전 단계가 통과해야 다음 단계 진행

```python
# LangGraph conductor agent
class PipelineState:
    test_status: str  # pending | pass | fail
    impl_status: str
    lint_status: str

def gate_implementation(state):
    if state.test_status != "pass":
        return "halt"  # 테스트 통과 전까지 구현 안 함
    return "proceed"

def gate_merge(state):
    if state.lint_status != "pass":
        return "halt"  # 린트 통과 전까지 merge 안 함
    return "proceed"
```

### 3. Orchestrated Stages with Rollback

**파이프라인**:
```
Stage 1: Generate Tests
  ↓ (gate: tests exist)
Stage 2: Implement Code
  ↓ (gate: tests pass)
Stage 3: Static Analysis
  ↓ (gate: no critical issues)
Stage 4: Update Docs
  ↓ (gate: docs updated)
Stage 5: Release
```

**Rollback 전략**:
```bash
# 각 stage마다 git branch/stash 사용
git stash push -m "before-stage-2"

# Stage 실패 시
git stash pop  # 이전 상태로 복원
# 또는
git checkout -- .  # working tree 변경 drop

# 절대 하지 말 것
git push --force  # 사람 확인 없이 force push 금지
```

### 4. Conversation Snapshots

**원칙**: 각 agent는 현재 stage를 알아야 함 (중복 작업 방지)

```json
// /state/conversation-snapshot.json
{
  "current_stage": "implementation",
  "completed_stages": ["test_generation"],
  "pending_stages": ["static_analysis", "documentation"],
  "context": {
    "feature": "user authentication",
    "target_files": ["src/auth.py", "tests/test_auth.py"]
  }
}
```

**사용**:
```yaml
# implementation-partner agent
Before starting work:
1. Read /state/conversation-snapshot.json
2. Check if "implementation" is current stage
3. If already completed, skip
4. Update snapshot when done
```

---

## MCP & Skills Integration

### 1. MCP Resources 설계

#### File-backed MCP (MVP)

**장점**:
- 인프라 불필요
- Git으로 버전 관리 가능
- 포터블 (다른 머신에서도 동일)

**구조**:
```
project-root/
├── .mcp/
│   ├── diagnostics/           # Agent 실행 결과
│   │   ├── pytest-test-writer/
│   │   │   ├── task-001.json
│   │   │   └── coverage.json
│   │   ├── implementation-partner/
│   │   │   └── task-001.json
│   │   └── static-analysis/
│   │       └── task-001.json
│   │
│   ├── fixtures/              # 공유 테스트 픽스처
│   │   └── vcr/
│   │       ├── researcher/
│   │       │   └── happy_path.json
│   │       └── writer/
│   │           └── edge_case.json
│   │
│   └── state/                 # 파이프라인 상태
│       └── conversation-snapshot.json
│
└── .mcp.json                  # MCP 서버 설정
```

**`.mcp.json` 설정**:
```json
{
  "mcpServers": {
    "file-backend": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", ".mcp"]
    }
  }
}
```

#### 스키마 표준

**메타데이터 블록 (필수)**:
```json
{
  "created_by": "agent-name",
  "created_at": "2025-11-01T10:30:00Z",
  "task_id": "uuid",
  "schema_version": "1.0",
  "
  // ... agent-specific payload
}
```

### 2. FastAPI MCP 서버 (선택적, 향후)

**언제 필요한가**:
- 실시간 쿼리 필요 (예: "모든 실패한 task 찾기")
- Subscription 필요 (예: task 상태 변경 시 알림)
- 복잡한 필터링 (예: "지난 1주일 간 critical issue만")

**구현**:
```python
# mcp-server.py
from fastapi import FastAPI
from mcp import McpServer

app = FastAPI()
mcp = McpServer()

@mcp.resource("diagnostics:list")
def list_diagnostics(agent: str = None, status: str = None):
    """List all diagnostic results with filtering"""
    # Query SQLite or filesystem
    return results

@mcp.tool("diagnostics:create")
def create_diagnostic(agent: str, task_id: str, data: dict):
    """Create new diagnostic entry"""
    # Write to storage
    return {"status": "created"}
```

**Until then**: File-backed가 충분함

### 3. Skills for Repetitive Commands

**원칙**: Agent 프롬프트를 짧게 유지, 반복 명령은 skill로 추출

**예시**:
```yaml
# .claude/skills/pytest-runner.md
---
name: pytest-runner
description: Run pytest with common options
---

Run pytest with coverage and verbosity:

```bash
pytest {args} --cov={module} --cov-report=json --cov-report=term -v
```

Parse coverage.json and report:
- Overall coverage: X%
- Uncovered files: [...]
- Critical gaps: [...]
```

**Agent에서 사용**:
```yaml
# implementation-partner agent
After implementing code:
1. Use pytest-runner skill with args="-k test_login"
2. Read coverage report
3. Iterate if <80% coverage
```

### 4. Commands for External Systems

**원칙**: Agent는 샌드박스, 외부 시스템은 command로 접근

**예시**:
```bash
# .claude/commands/create-github-issue.md
---
description: Create GitHub issue from diagnostic
---

Create GitHub issue:

```bash
gh issue create \
  --title "Security: {title}" \
  --body "$(cat .mcp/diagnostics/static-analysis/{task-id}.json)" \
  --label "security,automated"
```
```

**Agent에서 사용**:
```yaml
# static-analysis-agent
When critical security issue found:
1. Write diagnostic to MCP
2. Suggest: "Run /create-github-issue to file this"
3. Do NOT directly create issue (requires approval)
```

### 5. Skill Catalog per Agent

**문서화**:
```markdown
# .claude/agents/README.md

## Agent Skill Catalog

### implementation-partner
- Skills: pytest-runner, ruff-check, mypy-runner
- Commands: /create-pr
- MCP Resources: Read from pytest-test-writer, Write to diagnostics

### static-analysis-agent
- Skills: ruff-fix, bandit-scan, semgrep-scan
- Commands: /create-github-issue, /create-security-advisory
- MCP Resources: Write to diagnostics/static-analysis

### knowledge-steward
- Skills: generate-changelog, update-readme, mermaid-diagram
- Commands: /publish-docs
- MCP Resources: Read all diagnostics, Write to docs/
```

---

## 구현 로드맵

### Phase 1: Implementation Partner MVP (Week 1-2)

**목표**: TDD 루프 완성

**Deliverables**:
1. MCP 파일 백엔드 구조 생성
   ```bash
   mkdir -p .mcp/{diagnostics,fixtures,state}
   mkdir -p .mcp/diagnostics/{pytest-test-writer,implementation-partner}
   ```

2. Task 스키마 정의
   ```json
   // .mcp/schemas/task.schema.json
   ```

3. `implementation-partner` agent 생성
   - `.claude/agents/implementation-partner.md`
   - 모델: sonnet
   - 도구: Read, Write, Edit, Bash
   - 시스템 프롬프트: TDD implementation specialist

4. `pytest-test-writer` 수정
   - MCP 출력 추가 (작업 지시서 생성)
   - Coverage 텔레메트리 추가

5. 통합 테스트
   - Sample 프로젝트에서 전체 루프 실행
   - pytest-test-writer → implementation-partner → 검증

**성공 기준**:
- [ ] pytest-test-writer가 MCP에 task 작성
- [ ] implementation-partner가 task 읽고 코드 생성
- [ ] 생성된 코드로 테스트 통과
- [ ] 결과가 MCP에 기록

### Phase 2: Static Analysis Agent (Week 3-4)

**목표**: 코드 품질 자동 검증

**Deliverables**:
1. `static-analysis-agent` 생성
   - Ruff, Mypy, Bandit 통합
   - Report-only 모드

2. MCP diagnostics 출력

3. GitHub Security Advisory 통합 (선택)

4. Pipeline gating 구현
   - 테스트 통과 → 구현 → 린트 통과 → merge

**성공 기준**:
- [ ] Ruff/Mypy/Bandit 실행 및 리포트 생성
- [ ] Critical issue 발견 시 파이프라인 중단
- [ ] 결과가 MCP에 기록

### Phase 3: Knowledge Steward (Week 5-6)

**목표**: 문서 자동 생성

**Deliverables**:
1. `knowledge-steward-agent` 생성
   - README.md 업데이트
   - CHANGELOG.md 생성
   - API docs 생성

2. Hook 통합
   - 코드 변경 시 자동 트리거

**성공 기준**:
- [ ] README.md가 코드 변경에 맞춰 업데이트
- [ ] CHANGELOG.md가 커밋 메시지 기반 생성
- [ ] API docs가 docstring 기반 생성

### Phase 4: Full Pipeline Orchestration (Week 7-8)

**목표**: LangGraph conductor agent

**Deliverables**:
1. `conductor-agent` 생성
   - 전체 파이프라인 오케스트레이션
   - Gating 로직
   - Rollback 전략

2. Slash command 통합
   - `/run-pipeline` - 전체 파이프라인 실행
   - `/skip-stage <stage>` - 특정 단계 스킵
   - `/rollback <stage>` - 특정 단계로 롤백

**성공 기준**:
- [ ] 전체 파이프라인 자동 실행
- [ ] Stage 실패 시 자동 중단
- [ ] 사람 승인 후 재개

### Phase 5: Advanced Agents (Week 9+)

**목표**: Observability, Release Sherpa 추가

**Deliverables**:
1. `observability-agent`
2. `release-sherpa-agent`
3. Advanced meta-testing (chaos injection)

---

## 측정 지표

### Agent 성능 지표

```json
{
  "agent_metrics": {
    "pytest-test-writer": {
      "success_rate": 0.95,
      "avg_duration_sec": 12.5,
      "coverage_avg": 0.82,
      "failures": ["timeout on 1000+ line files"]
    },
    "implementation-partner": {
      "success_rate": 0.88,
      "avg_iterations": 1.5,
      "avg_duration_sec": 45.2,
      "tdd_cycle_time_sec": 60.0
    }
  }
}
```

### 파이프라인 지표

```json
{
  "pipeline_metrics": {
    "avg_pipeline_duration_min": 5.2,
    "stage_success_rates": {
      "test_generation": 0.95,
      "implementation": 0.88,
      "static_analysis": 0.92,
      "documentation": 0.99
    },
    "bottlenecks": ["implementation stage (45s)"]
  }
}
```

---

## 예상 효과

### 개발 속도

**Before**:
```
기능 요청 → 수동 테스트 작성 (30분) → 수동 구현 (2시간) → 수동 린트 (10분) → 수동 문서 (30분)
= 총 3시간 10분
```

**After (Full Pipeline)**:
```
기능 요청 → 파이프라인 실행 (5분) → 사람 리뷰 (15분) → Merge
= 총 20분
```

**생산성 향상**: 9.5x

### 코드 품질

- **테스트 커버리지**: 60% → 85%
- **보안 이슈**: 발견 시간 1주 → 즉시
- **문서 동기화**: 50% → 95%
- **기술 부채**: 증가 추세 → 감소 추세

### 팀 경험

- **반복 작업**: 80% 감소
- **컨텍스트 스위칭**: 70% 감소
- **온보딩 시간**: 2주 → 3일

---

## 리스크 & 대응

### 리스크 1: Agent 신뢰성

**문제**: Agent가 잘못된 코드 생성

**대응**:
- Gating으로 테스트 통과 강제
- 사람 리뷰 전까지 merge 금지
- meta-tester로 agent 품질 모니터링

### 리스크 2: 과도한 자동화

**문제**: 개발자가 코드 이해 못 함

**대응**:
- 모든 agent 출력은 설명 포함
- 중요 결정은 사람 승인 필요
- 학습 모드 제공 (왜 이렇게 했는지 설명)

### 리스크 3: MCP 복잡도

**문제**: MCP 리소스 관리 어려움

**대응**:
- 파일 백엔드로 시작 (단순)
- 스키마 표준화
- 자동 정리 (30일 이상 오래된 diagnostics 삭제)

---

## 결론

### Claude의 의견

Codex의 제안은 매우 실용적이고 구현 가능합니다. 특히:

1. **Implementation Partner Agent** - TDD 루프를 완성하는 핵심
2. **MCP 기반 상태 공유** - Agent 간 통신의 표준화
3. **단계적 롤아웃** - MVP부터 시작하여 점진적 확장

현재 3개 agent에서 8개 agent로 확장하면 **완전 자동화된 개발 파이프라인**을 구축할 수 있습니다.

### Codex의 의견

다음 단계는 **Implementation Partner Agent MVP**입니다:
1. Task 스키마 설계
2. MCP 파일 백엔드 구조 생성
3. Agent 시스템 프롬프트 작성
4. 샘플 프로젝트로 검증

이 토론을 실제 구현으로 전환하는 것이 중요합니다.

---

## Next Actions

1. [ ] MCP 디렉토리 구조 생성 (`.mcp/`)
2. [ ] Task 스키마 JSON 정의
3. [ ] `implementation-partner` agent 생성
4. [ ] `pytest-test-writer` MCP 출력 추가
5. [ ] 샘플 프로젝트에서 TDD 루프 테스트
6. [ ] Phase 1 완료 후 Phase 2 시작

**Target**: Phase 1 완료 in 2 weeks

---

**문서 버전**: 1.0
**참여자**: Claude (Anthropic) + Codex (OpenAI)
**다음 리뷰**: Phase 1 완료 후
