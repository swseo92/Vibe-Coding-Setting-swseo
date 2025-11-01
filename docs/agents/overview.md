# Claude Code Agents: 종합 가이드

> **최종 업데이트**: 2025-11-01
> **작성자**: AI Research
> **목적**: Claude Code의 Agent(Subagent) 기능에 대한 완전한 이해

---

## 목차

1. [개요](#개요)
2. [Agent란 무엇인가](#agent란-무엇인가)
3. [Agent 파일 구조](#agent-파일-구조)
4. [Agent 생성 방법](#agent-생성-방법)
5. [Agent 사용 방법](#agent-사용-방법)
6. [Best Practices](#best-practices)
7. [현재 저장소의 Agent 분석](#현재-저장소의-agent-분석)
8. [고급 활용법](#고급-활용법)
9. [참고 자료](#참고-자료)

---

## 개요

Claude Code의 **Agent(Subagent)**는 특정 작업에 특화된 AI 어시스턴트입니다. 메인 대화와 독립적인 컨텍스트를 가지며, 전문화된 시스템 프롬프트와 제한된 도구 접근 권한으로 특정 작업을 효율적으로 수행합니다.

### Agent의 필요성

1. **컨텍스트 분리**: 메인 대화가 길어져도 agent는 깨끗한 컨텍스트에서 시작
2. **전문화**: 특정 도메인에 최적화된 시스템 프롬프트로 높은 성공률
3. **재사용성**: 한 번 만들면 모든 프로젝트에서 사용 가능
4. **보안**: 도구 접근 권한을 세밀하게 제어
5. **팀 협업**: 프로젝트 전체에서 일관된 작업 방식 공유

---

## Agent란 무엇인가

### 핵심 특징

#### 1. 독립된 컨텍스트 윈도우
각 agent는 자체 컨텍스트를 사용하여 메인 대화를 오염시키지 않습니다:

```
Main Conversation (Claude Code)
├── Context: 사용자와의 전체 대화 히스토리
└── Delegates to Agent
    └── Agent Context: 깨끗한 상태에서 시작
        ├── System Prompt (전문화)
        ├── Task Parameters
        └── Allowed Tools Only
```

#### 2. 전문화된 역할
각 agent는 명확한 단일 책임을 가집니다:
- 테스트 작성 전문가 (pytest-test-writer)
- LangGraph 노드 구현 전문가 (langgraph-node-implementer)
- 메타 테스팅 전문가 (meta-tester)

#### 3. 도구 접근 제어
Agent마다 사용할 수 있는 도구를 제한할 수 있습니다:

```yaml
# 예시: 읽기 전용 agent
tools: Read, Grep, Glob

# 예시: 구현 agent
tools: Read, Write, Edit, Bash, Grep, Glob
```

#### 4. 모델 선택
작업 복잡도에 따라 적절한 모델을 선택:

| 모델 | 용도 | 예시 |
|------|------|------|
| `haiku` | 빠른 작업, 간단한 태스크 | 테스트 작성, 코드 생성 |
| `sonnet` | 일반적인 작업, 복잡한 분석 | 메타 테스팅, 코드 리뷰 |
| `opus` | 매우 복잡한 추론 | 아키텍처 설계, 복잡한 리팩토링 |

---

## Agent 파일 구조

### 파일 형식

Agent는 **YAML frontmatter**를 가진 **Markdown 파일**로 저장됩니다:

```markdown
---
name: agent-identifier
description: When this agent should be invoked (with examples)
tools: tool1, tool2, tool3 (optional)
model: sonnet|opus|haiku (optional)
color: green|blue|orange|purple (optional)
---

# System Prompt

You are an expert in [domain]. Your mission is to [purpose].

## Core Responsibilities

1. **Responsibility 1**: Description
2. **Responsibility 2**: Description

## Methodology

Step-by-step approach...

## Quality Criteria

Standards to meet...
```

### 필수 필드

#### `name` (필수)
Agent의 고유 식별자 (kebab-case 권장):
```yaml
name: pytest-test-writer
name: langgraph-node-implementer
name: meta-tester
```

#### `description` (필수)
Agent가 언제 호출되어야 하는지 설명 (예시 포함 권장):
```yaml
description: Use this agent when you need to create pytest-based test code following the guidelines from testing_guidelines.md. Examples:\n\n<example>\nuser: "Create tests for my login function"\nassistant: "I'll use the pytest-test-writer agent to create comprehensive tests."\n</example>
```

### 선택적 필드

#### `tools` (선택)
Agent가 사용할 수 있는 도구 목록 (생략 시 모든 도구 접근 가능):
```yaml
tools: Read, Write, Edit, Bash, Grep, Glob
```

**사용 가능한 도구**:
- `Read` - 파일 읽기
- `Write` - 파일 생성
- `Edit` - 파일 편집
- `Bash` - 쉘 명령어 실행
- `Grep` - 코드 검색
- `Glob` - 파일 패턴 매칭
- `Task` - 하위 agent 호출
- `WebFetch` - 웹 페이지 가져오기
- `WebSearch` - 웹 검색
- 기타 MCP 도구들...

#### `model` (선택)
사용할 AI 모델 (생략 시 상위에서 상속):
```yaml
model: haiku  # 빠르고 저렴
model: sonnet # 기본값, 균형잡힌 성능
model: opus   # 복잡한 추론
```

#### `color` (선택)
터미널에서 agent 표시 색상:
```yaml
color: green  # 테스트 관련
color: blue   # 구현 관련
color: orange # 메타/관리 관련
```

### 저장 위치

#### 프로젝트 Agent (`.claude/agents/`)
현재 프로젝트에서만 사용 가능:
```
project-root/
└── .claude/
    └── agents/
        ├── my-project-agent.md
        └── custom-validator.md
```

**용도**:
- 프로젝트 특화 작업 (예: 특정 API 클라이언트 생성)
- 팀 전체 공유 (git으로 관리)
- 프로젝트별 설정 (testing_guidelines.md 참조 등)

#### 전역 Agent (`~/.claude/agents/`)
모든 프로젝트에서 사용 가능:
```
~/.claude/
└── agents/
    ├── pytest-test-writer.md
    ├── code-reviewer.md
    └── documentation-writer.md
```

**용도**:
- 범용적인 작업 (예: pytest 테스트 작성)
- 개인 워크플로우 자동화
- 언어/프레임워크 독립적 작업

---

## Agent 생성 방법

### 방법 1: `/agents` 명령어 사용 (권장)

Claude Code에서 대화형으로 agent 생성:

```bash
# Claude Code에서 실행
/agents
```

**단계**:
1. "Create New Agent" 선택
2. **Scope 선택**:
   - "Project" - `.claude/agents/`에 저장
   - "User" - `~/.claude/agents/`에 저장
3. **정보 입력**:
   - Name: agent-identifier
   - Description: When to invoke (with examples)
   - Tools: (선택) Read, Write, Edit, ...
   - Model: (선택) haiku, sonnet, opus
4. **System Prompt 작성**: Agent의 역할과 책임 정의
5. 저장 → 즉시 사용 가능

**장점**:
- ✅ 대화형 인터페이스로 쉽게 생성
- ✅ Claude가 시스템 프롬프트 초안 생성 가능
- ✅ 문법 오류 방지
- ✅ 즉시 테스트 가능

### 방법 2: 직접 파일 작성

텍스트 에디터로 직접 작성:

```bash
# 프로젝트 agent
touch .claude/agents/my-agent.md

# 전역 agent
touch ~/.claude/agents/my-agent.md
```

**템플릿**:
```markdown
---
name: my-custom-agent
description: Use this agent when [specific scenario]. Examples:\n\n<example>\nuser: "[user request]"\nassistant: "I'll use the my-custom-agent to [action]."\n</example>
tools: Read, Write, Edit
model: haiku
color: green
---

You are an expert in [domain]. Your mission is to [specific goal].

## Core Responsibilities

1. **[Responsibility 1]**: [Description]
2. **[Responsibility 2]**: [Description]

## Methodology

### Step 1: [Phase Name]
- [Action 1]
- [Action 2]

### Step 2: [Phase Name]
- [Action 1]
- [Action 2]

## Quality Criteria

Before completing, verify:
- [ ] Criterion 1
- [ ] Criterion 2

## Output Format

Provide results in this structure:
1. **Summary**: Brief overview
2. **Details**: Specific findings
3. **Recommendations**: Next steps
```

**장점**:
- ✅ 버전 관리 용이
- ✅ 팀과 공유 쉬움
- ✅ 세밀한 제어 가능

### 방법 3: 기존 Agent 복제 및 수정

기존 agent를 기반으로 새 agent 생성:

```bash
# 프로젝트 agent 복제
cp .claude/agents/pytest-test-writer.md .claude/agents/my-test-writer.md

# 편집
vim .claude/agents/my-test-writer.md
```

**장점**:
- ✅ 검증된 구조 재사용
- ✅ 빠른 프로토타이핑
- ✅ 일관된 포맷 유지

---

## Agent 사용 방법

### 1. 자동 호출 (Automatic Delegation)

Agent의 `description`과 사용자 요청이 매칭되면 자동 호출:

```
User: "Create comprehensive tests for my authentication module"

Claude Code: [Automatically delegates to pytest-test-writer agent]
```

**자동 호출 조건**:
- `description` 필드에 명확한 트리거 키워드 포함
- 사용자 요청이 agent의 전문 분야와 일치
- Claude가 자동으로 매칭 판단

**예시 (pytest-test-writer)**:
```yaml
description: Use this agent when you need to create pytest-based test code...
```

```
User: "I need tests for my API endpoints"
→ pytest-test-writer 자동 호출 ✅

User: "Write unit tests with pytest"
→ pytest-test-writer 자동 호출 ✅

User: "Review my code"
→ pytest-test-writer 호출 안 됨 ❌
```

### 2. 명시적 호출 (Explicit Invocation)

사용자가 agent 이름을 직접 지정:

```
User: "Use the pytest-test-writer agent to create tests for this code"

Claude Code: [Explicitly invokes pytest-test-writer]
```

**장점**:
- 원하는 agent를 정확히 선택 가능
- 자동 매칭이 잘못될 때 유용
- 여러 agent가 있을 때 명확한 지시

### 3. Task 도구로 호출 (Programmatic)

다른 agent나 스크립트에서 프로그래밍 방식으로 호출:

```python
# Claude Code 내부에서 (다른 agent가 사용)
Task(
    subagent_type="pytest-test-writer",
    prompt="Create comprehensive tests for the login function in auth.py",
    description="Generate pytest tests",
    model="haiku"  # 선택적으로 모델 지정
)
```

**장점**:
- Agent 체이닝 가능
- 복잡한 워크플로우 구축
- 병렬 실행 가능

### 4. Agent 체이닝 (Advanced)

여러 agent를 순차적으로 호출:

```
User: "First analyze my code structure, then generate tests, then create documentation"

Claude Code:
1. [Invokes code-analyzer agent]
   → 결과: 코드 구조 분석 보고서

2. [Invokes pytest-test-writer agent]
   → 입력: 분석 보고서
   → 결과: 테스트 코드

3. [Invokes documentation-writer agent]
   → 입력: 코드 + 테스트
   → 결과: README.md
```

**예시 스크립트**:
```markdown
# .claude/commands/full-analysis.md
---
description: Full code analysis workflow
---

Perform comprehensive code analysis:

1. Use code-analyzer agent to analyze structure
2. Use pytest-test-writer agent to generate tests
3. Use documentation-writer agent to create docs
4. Summarize all results
```

---

## Best Practices

### 1. 단일 책임 원칙 (Single Responsibility)

각 agent는 **하나의 명확한 목적**만 가져야 합니다:

✅ **좋은 예시**:
```yaml
name: pytest-test-writer
# 목적: pytest 테스트 코드 생성만

name: api-client-generator
# 목적: REST API 클라이언트 코드 생성만
```

❌ **나쁜 예시**:
```yaml
name: code-helper
# 목적: 테스트도 쓰고, 문서도 쓰고, 리팩토링도 하고...
# → 너무 많은 책임 = 전문성 저하
```

**이유**:
- 전문화된 시스템 프롬프트가 더 효과적
- 디버깅과 유지보수 용이
- 재사용성 향상

### 2. 상세한 시스템 프롬프트

Agent의 역할과 책임을 **구체적으로** 정의:

✅ **좋은 예시**:
```markdown
You are an expert Python test engineer specializing in pytest-based test development.

## Core Responsibilities

1. **Analyze the Code Under Test**:
   - Function/class/module's purpose
   - Input parameters, types, valid ranges
   - Expected outputs and return types
   - Edge cases and error conditions

2. **Create Comprehensive Test Suites**:
   - Happy path tests (valid inputs)
   - Edge case tests (boundary conditions)
   - Error handling tests (exceptions)
   - Use @pytest.mark.parametrize for multiple cases

3. **Follow pytest Best Practices**:
   - Descriptive test function names
   - Arrange-Act-Assert (AAA) pattern
   - Reusable fixtures
   - Clear docstrings
```

❌ **나쁜 예시**:
```markdown
You write tests.
```

**포함해야 할 요소**:
- 구체적인 역할 정의
- 단계별 방법론
- 품질 기준
- 출력 형식
- 예외 처리 방법

### 3. 최소 권한 원칙 (Least Privilege)

Agent에게 **필요한 도구만** 허용:

✅ **좋은 예시**:
```yaml
# 읽기 전용 분석 agent
name: code-analyzer
tools: Read, Grep, Glob

# 테스트 작성 agent
name: pytest-test-writer
tools: Read, Write  # Bash 불필요

# 구현 agent
name: langgraph-node-implementer
tools: Read, Write, Edit, Bash, Grep, Glob
```

❌ **나쁜 예시**:
```yaml
# 분석만 하는데 모든 도구 허용
name: code-analyzer
# tools: (생략) → 모든 도구 접근 가능
```

**이점**:
- 보안 향상 (실수로 파일 삭제 방지)
- Agent 집중도 향상
- 의도하지 않은 부작용 방지

### 4. 예시 포함 (Examples in Description)

`description` 필드에 **구체적인 사용 예시** 포함:

✅ **좋은 예시**:
```yaml
description: |
  Use this agent when you need to create pytest-based test code.

  Examples:

  <example>
  Context: User has written a login function
  user: "Create tests for my login function"
  assistant: "I'll use the pytest-test-writer agent to create comprehensive tests."
  <commentary>
  Clear test generation request → pytest-test-writer
  </commentary>
  </example>

  <example>
  user: "I need unit tests for auth.py"
  assistant: "I'll use the pytest-test-writer agent."
  </example>
```

❌ **나쁜 예시**:
```yaml
description: Creates tests
```

**이점**:
- Claude가 언제 호출할지 명확히 이해
- 자동 호출 정확도 향상
- 팀원들이 사용법 쉽게 파악

### 5. 적절한 모델 선택

작업 복잡도에 맞는 모델 선택:

| 작업 유형 | 모델 | 이유 |
|----------|------|------|
| 단순 코드 생성 | `haiku` | 빠르고 저렴, 패턴 기반 작업 |
| 테스트 작성 | `haiku` | 정형화된 구조, 빠른 실행 |
| 코드 분석 | `sonnet` | 복잡한 패턴 이해 필요 |
| 메타 테스팅 | `sonnet` | 종합적 판단 필요 |
| 아키텍처 설계 | `opus` | 깊은 추론 필요 |

**예시**:
```yaml
# 빠른 테스트 생성
name: pytest-test-writer
model: haiku

# 복잡한 분석
name: meta-tester
model: sonnet
```

### 6. 버전 관리

프로젝트 agent는 **git으로 관리**:

```bash
# .gitignore에서 제외 (커밋해야 함)
# .claude/agents/ ← 커밋!

git add .claude/agents/
git commit -m "Add custom pytest agent for API testing"
git push
```

**이점**:
- 팀 전체가 동일한 agent 사용
- 변경 히스토리 추적
- 코드 리뷰 가능

### 7. 문서화

Agent의 **사용법과 목적**을 명확히 문서화:

**방법 1: Agent 파일 내부에 주석**
```markdown
---
name: api-test-generator
description: ...
---

<!--
이 agent는 REST API 엔드포인트 테스트를 자동 생성합니다.

사용 시나리오:
- FastAPI/Flask 프로젝트
- OpenAPI 스펙이 있는 경우

필요 파일:
- openapi.yaml 또는 swagger.json
- 프로젝트 루트에 tests/ 폴더

출력:
- tests/api/test_{endpoint}.py
-->

You are an expert in API testing...
```

**방법 2: 별도 README**
```bash
# .claude/agents/README.md
cat > .claude/agents/README.md << 'EOF'
# Project Agents

## api-test-generator
Generates pytest tests for REST API endpoints.

**Usage**: "Create tests for my API endpoints"

**Requirements**:
- openapi.yaml in project root
- tests/ directory exists

**Output**: tests/api/test_{endpoint}.py
EOF
```

### 8. 테스트 및 반복

Agent를 만든 후 **실제로 테스트**:

```bash
# 1. Agent 생성
vim .claude/agents/my-agent.md

# 2. Claude Code 재시작 (agent 로드)
claude

# 3. 테스트
User: "Use my-agent to do X"

# 4. 결과 확인 및 개선
# - 기대한 대로 작동하는가?
# - 시스템 프롬프트 개선 필요?
# - 도구 추가/제거 필요?

# 5. 반복
vim .claude/agents/my-agent.md  # 수정
```

**테스팅 체크리스트**:
- [ ] 자동 호출이 잘 작동하는가?
- [ ] 출력 품질이 기대에 부합하는가?
- [ ] 엣지 케이스 처리가 적절한가?
- [ ] 다른 agent와 충돌하지 않는가?
- [ ] 성능이 허용 범위인가?

---

## 현재 저장소의 Agent 분석

### 1. pytest-test-writer

**파일**: `.claude/agents/pytest-test-writer.md`
**모델**: `haiku` (빠른 테스트 생성)
**색상**: `green` (테스트 관련)
**도구**: 모두 (명시 안 됨)

#### 목적
Python pytest 기반 테스트 코드 자동 생성

#### 핵심 기능

1. **testing_guidelines.md 준수**
   - 프로젝트별 테스트 가이드라인 참조
   - 일관된 테스트 스타일 유지

2. **종합적인 테스트 커버리지**
   ```python
   # Happy path
   def test_login_success():
       assert login(valid_user, valid_pass) == True

   # Edge cases
   def test_login_empty_password():
       assert login(valid_user, "") == False

   # Error handling
   def test_login_invalid_credentials():
       with pytest.raises(AuthError):
           login(invalid_user, invalid_pass)
   ```

3. **AAA 패턴 (Arrange-Act-Assert)**
   ```python
   def test_user_creation():
       # Arrange
       user_data = {"name": "John", "email": "john@example.com"}

       # Act
       user = create_user(user_data)

       # Assert
       assert user.name == "John"
       assert user.email == "john@example.com"
   ```

4. **Parametrized Tests**
   ```python
   @pytest.mark.parametrize("input,expected", [
       ("valid@email.com", True),
       ("invalid-email", False),
       ("", False),
   ])
   def test_email_validation(input, expected):
       assert validate_email(input) == expected
   ```

5. **Mock/Fixture 지원**
   ```python
   @pytest.fixture
   def mock_database():
       db = MockDB()
       yield db
       db.cleanup()

   def test_with_mock(mock_database):
       result = query_user(mock_database, user_id=1)
       assert result is not None
   ```

#### 출력 형식

1. **Summary**: 테스트 스위트 개요
2. **Test File**: 완전한 실행 가능한 pytest 파일
3. **Coverage Analysis**: 커버된 영역과 미커버 영역
4. **Usage Instructions**: 실행 방법 및 의존성

#### 사용 예시

```
User: "I wrote a function to validate email addresses. Can you create tests?"

pytest-test-writer:
1. 코드 분석 (입력, 출력, 엣지 케이스)
2. 테스트 케이스 설계
3. pytest 코드 생성
4. 커버리지 분석 제공
```

#### 강점
- ✅ 프로젝트 가이드라인 준수
- ✅ 종합적인 커버리지 (happy path + edge cases + errors)
- ✅ 실행 가능한 코드 생성
- ✅ 명확한 문서화

#### 개선 가능 영역
- 도구 제한 없음 (Read, Write만으로도 충분할 수 있음)
- 성능 테스트나 통합 테스트는 다루지 않음 (의도적일 수 있음)

---

### 2. langgraph-node-implementer

**파일**: `.claude/agents/langgraph-node-implementer.md`
**모델**: `haiku` (효율적인 구현)
**색상**: `blue` (구현 관련)
**도구**: `Read, Write, Edit, Bash, Grep, Glob`

#### 목적
LangGraph 노드를 TDD(Test-Driven Development) 방식으로 구현

#### 핵심 워크플로우: VCR 기반 TDD

```
Phase 1: 스펙 읽기 (2-3분)
├── 노드 스펙 파일 읽기 (nodes/{node_name}_spec.md)
├── State schema 확인
└── testing_guidelines.md 참조

Phase 2: 테스트 작성 (5-7분)
├── pytest-vcr 설정
├── .env 파일 생성 (API keys)
├── tests/test_{node_name}.py 작성
│   ├── @pytest.mark.vcr() 데코레이터
│   ├── Happy path test
│   ├── Edge case tests
│   └── Error handling tests
└── 테스트 실행 → FAIL (RED phase)

Phase 3: 실제 구현 (10-15분)
├── nodes/{node_name}.py 생성
├── 실제 API 호출 코드 작성
├── LangChain OpenAI 사용
└── 테스트 실행 → PASS + Cassette 녹화 (GREEN phase)

Phase 4: 검증 (2-3분)
├── Cassette로 재실행 (instant)
├── Coverage 확인
└── 문서화
```

#### VCR (Video Cassette Recorder) 패턴

**문제**: LLM API 호출은 비용이 들고 느리며 결과가 비결정적

**해결**: 첫 실행 시 실제 API 호출 → 응답 녹화 → 이후 재생

```python
# 첫 실행: 실제 API 호출
@pytest.mark.vcr()  # cassette 자동 녹화
def test_researcher_happy_path():
    state = WorkflowState(query="AI safety")
    result = researcher_node(state)  # ← 실제 OpenAI API 호출

    assert len(result.research_results) > 0
    # ✅ Cassette 저장: tests/cassettes/test_researcher_happy_path.yaml

# 이후 실행: Cassette 재생 (instant, 무료)
@pytest.mark.vcr()
def test_researcher_happy_path():
    state = WorkflowState(query="AI safety")
    result = researcher_node(state)  # ← Cassette 재생 (실제 API 호출 없음)

    assert len(result.research_results) > 0
    # ✅ 0.1초 만에 완료, 비용 $0
```

#### .env 기반 API Key 관리

```bash
# .env (git-ignored, 로컬만)
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...

# .env.example (커밋, 템플릿)
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...

# tests/conftest.py
from dotenv import load_dotenv
load_dotenv()  # .env 자동 로드

@pytest.fixture(scope="module")
def vcr_config():
    return {
        "filter_headers": ["authorization", "x-api-key"],  # API key 필터링
        "record_mode": "once",
        "cassette_library_dir": "tests/cassettes",
    }
```

#### 실제 구현 예시

```python
# nodes/researcher.py
from langchain_openai import ChatOpenAI
from langchain_core.messages import HumanMessage, SystemMessage
from state_schema import WorkflowState

def researcher_node(state: WorkflowState) -> WorkflowState:
    """Research a topic using LLM"""
    try:
        # Step 1: LLM 초기화
        llm = ChatOpenAI(model="gpt-4", temperature=0.7)

        # Step 2: 실제 API 호출
        response = llm.invoke([
            SystemMessage(content="You are a research expert."),
            HumanMessage(content=f"Research: {state.query}")
        ])

        # Step 3: State 업데이트 (Pydantic model_copy)
        return state.model_copy(update={
            "research_results": [response.content],
            "completed_branches": state.completed_branches | {"researcher"}
        })

    except Exception as e:
        # Step 4: 에러 처리 (graceful degradation)
        return state.model_copy(update={
            "errors": state.errors + [{"node": "researcher", "error": str(e)}],
            "completed_branches": state.completed_branches | {"researcher"}
        })
```

#### 품질 기준

1. **Test Coverage**: 모든 테스트 케이스 구현
2. **Tests Pass**: 100% 통과 (GREEN phase)
3. **Type Safety**: Pydantic State schema 준수
4. **Error Handling**: graceful degradation
5. **Provenance**: `completed_branches` 업데이트
6. **Real API Validation**: VCR cassette 생성
7. **CI/CD Ready**: `--vcr-record=none`로 실행 가능

#### 출력 형식

```markdown
## Node Implementation Complete: researcher

### Files Created
- nodes/researcher.py (실제 구현)
- tests/test_researcher.py (VCR 테스트)
- tests/cassettes/test_researcher*.yaml (API 응답)

### Test Results

**First run (real API):**
$ pytest tests/test_researcher.py -v
================================ 3 passed in 5.2s ================================
✅ Cassettes created

**Subsequent runs (cassette replay):**
$ pytest tests/test_researcher.py -v --vcr-record=none
================================ 3 passed in 0.3s ================================
✅ Using recorded responses

### Implementation Notes
- TDD: RED → GREEN phases completed
- Real API: Validated against OpenAI GPT-4
- LLM: langchain_openai.ChatOpenAI
- VCR: Cassettes committed to git
```

#### 강점
- ✅ **진정한 TDD**: RED → GREEN → REFACTOR
- ✅ **실제 API 검증**: Mock이 아닌 실제 LLM 응답
- ✅ **CI/CD 친화적**: Cassette로 API key 불필요
- ✅ **비용 효율적**: 첫 실행 후 무료
- ✅ **결정적**: 항상 동일한 응답
- ✅ **빠름**: Cassette 재생은 instant

#### 혁신적인 점
- Mock 대신 VCR 사용 (Real API validation)
- .env 기반 API key 관리 (보안)
- Cassette git 커밋 (팀 공유)

---

### 3. meta-tester

**파일**: `.claude/agents/meta-tester.md`
**모델**: `sonnet` (복잡한 분석)
**색상**: `orange` (메타/관리)
**도구**: 모두

#### 목적
Claude Code 자체 기능을 테스트 (재귀적 자기 테스트)

#### 핵심 개념: 메타 테스팅

```
Main Claude Session
└── Spawns Independent Claude Session (subprocess)
    ├── Completely Isolated Context
    ├── Tests: Agent / Command / Workflow
    └── Returns: Test Results

Main Session analyzes results and provides feedback
```

#### Python Subprocess 기반 테스트

```python
import subprocess
import tempfile
from pathlib import Path

def test_claude_command(command: str, timeout: int = 3600):
    """
    독립적인 Claude Code 세션에서 명령어 테스트

    Args:
        command: 테스트할 명령어 (예: '/init-workspace python')
        timeout: 타임아웃 (기본 1시간)
    """
    test_dir = Path(tempfile.mkdtemp(prefix="claude-test-"))

    cmd = ["claude", "--print", command]

    result = subprocess.run(
        cmd,
        cwd=str(test_dir),
        capture_output=True,
        text=True,
        timeout=timeout,
        encoding='utf-8',
        errors='replace'
    )

    return {
        "success": result.returncode == 0,
        "stdout": result.stdout,
        "stderr": result.stderr,
        "test_dir": test_dir
    }

# 사용 예시
result = test_claude_command("/init-workspace python", timeout=3600)
```

#### 중요: 타임아웃 설정

**반드시 3600초 (1시간) 사용**:
```python
# ✅ 올바른 타임아웃
result = test_claude_command(cmd, timeout=3600)

# ❌ 잘못된 타임아웃 (너무 짧음)
result = test_claude_command(cmd, timeout=180)  # Agent 실행 중 중단됨!
result = test_claude_command(cmd, timeout=60)   # 거의 항상 실패
```

**이유**:
- Agent 실행은 시간이 오래 걸림 (특히 LLM 호출 시)
- 복잡한 워크플로우는 여러 단계를 거침
- 파일 I/O, 네트워크 요청 등 대기 시간 발생

#### 테스팅 방법론

```
Phase 1: 테스트 계획
├── 테스트할 기능 식별
├── 성공 기준 정의
├── 테스트 입력 설계
└── 의존성 확인

Phase 2: 테스트 실행
├── Python subprocess 생성
├── 독립적인 Claude 세션 실행
├── 결과 캡처 (stdout, stderr, exit code)
└── 테스트 디렉토리 보존

Phase 3: 결과 분석
├── 예상 동작 vs 실제 출력
├── 에러 식별
├── 성능 평가
└── 완전성 검증

Phase 4: 피드백 생성
├── 합격/불합격 판정
├── 구체적인 예시
├── 개선 제안
└── 추가 테스트 권장
```

#### 사용 시나리오

**1. Agent 테스트**
```
User: "방금 code-review 에이전트를 만들었는데 제대로 작동하는지 테스트해줘"

meta-tester:
1. 테스트 스크립트 작성
2. Subprocess로 독립 세션 실행
3. code-review agent 호출
4. 결과 분석 (정확성, 완전성)
5. 피드백 제공
```

**2. 명령어 테스트**
```
User: "/init-workspace python 명령어가 올바르게 작동하는지 확인해줘"

meta-tester:
1. 임시 디렉토리 생성
2. claude --print '/init-workspace python' 실행
3. 생성된 파일 확인
4. 의존성 설치 스크립트 검증
5. 보고서 생성
```

**3. 워크플로우 테스트**
```
User: "speckit.specify → speckit.plan → speckit.implement 워크플로우 테스트"

meta-tester:
1. 각 단계별 subprocess 실행
2. 중간 출력물 검증
3. 다음 단계로 전달
4. 전체 파이프라인 성공 여부 확인
```

#### 출력 형식

```markdown
# Meta Test Report: /init-workspace python

## Test Purpose
Verify /init-workspace python command correctly initializes a new Python project

## Test Scenarios
1. Fresh directory initialization
2. Template file copying
3. Dependency installation instructions
4. Global settings check

## Execution Details
```bash
Command: claude --print '/init-workspace python'
Timeout: 3600s
Test Dir: /tmp/claude-test-abc123/
Exit Code: 0
Duration: 15.3s
```

## Results Summary
✅ PASSED - All criteria met

## Detailed Findings

### Scenario 1: Fresh Directory ✅
- Created .claude/settings.json
- Created .claude/scripts/notify.py
- Created .specify/ structure
- Created pyproject.toml

### Scenario 2: Template Files ✅
- All files from templates/python/ copied
- All files from templates/common/ copied
- No extra files created

### Scenario 3: Instructions ✅
- Printed "Run: uv sync"
- Warned about global settings if missing

## Recommendations
- Add verification for .claude/scripts/ permissions
- Consider auto-running uv sync with user confirmation

## Conclusion
The /init-workspace python command works as expected.
Ready for production use.
```

#### 강점
- ✅ **완전한 격리**: Subprocess로 상태 오염 없음
- ✅ **실제 환경 시뮬레이션**: 사용자가 실행하는 것과 동일
- ✅ **포괄적 테스팅**: Agent, Command, Workflow 모두 가능
- ✅ **자동화**: 반복적 테스트 용이

#### 혁신적인 점
- Claude Code가 Claude Code를 테스트 (메타 순환)
- 품질 보증의 자동화

---

## 고급 활용법

### 1. Agent 파이프라인

여러 agent를 순차적으로 연결:

```markdown
# .claude/commands/full-pipeline.md
---
description: Run full development pipeline
---

Execute complete development workflow:

1. Use code-analyzer agent to analyze structure
   - Identify components
   - Find dependencies
   - Detect potential issues

2. Use langgraph-node-implementer for each component
   - Write tests first (TDD)
   - Implement with VCR
   - Verify with cassettes

3. Use pytest-test-writer for integration tests
   - Test component interactions
   - Verify end-to-end flow

4. Use documentation-writer agent
   - Generate API docs
   - Create README
   - Add usage examples

5. Summary report
```

### 2. Agent 병렬 실행

여러 agent를 동시에 실행:

```python
# Claude Code에서
Task.parallel([
    Task(
        subagent_type="pytest-test-writer",
        prompt="Create tests for auth module"
    ),
    Task(
        subagent_type="pytest-test-writer",
        prompt="Create tests for API module"
    ),
    Task(
        subagent_type="documentation-writer",
        prompt="Write README for the project"
    )
])
```

### 3. 조건부 Agent 호출

조건에 따라 다른 agent 호출:

```markdown
# .claude/commands/smart-test.md
---
description: Smart test generation based on code type
---

Analyze the code and choose appropriate testing agent:

1. If code contains FastAPI/Flask routes:
   → Use api-test-generator agent

2. If code contains LangChain/LangGraph nodes:
   → Use langgraph-node-implementer agent

3. Otherwise:
   → Use pytest-test-writer agent

Generate comprehensive tests.
```

### 4. Agent State 공유

Agent 간 결과 공유:

```
code-analyzer agent
├── 출력: analysis_report.json
└── 전달 →

pytest-test-writer agent
├── 입력: analysis_report.json
├── 출력: tests/
└── 전달 →

documentation-writer agent
├── 입력: analysis_report.json + tests/
└── 출력: README.md
```

### 5. Custom Hook과 Agent 통합

특정 이벤트 발생 시 agent 자동 호출:

```json
// .claude/settings.json
{
  "hooks": {
    "AfterEdit": [{
      "matcher": "*.py",
      "hooks": [{
        "type": "agent",
        "agent": "code-formatter",
        "prompt": "Format the edited Python file"
      }]
    }],
    "BeforeCommit": [{
      "hooks": [{
        "type": "agent",
        "agent": "pytest-test-writer",
        "prompt": "Ensure all changed files have tests"
      }]
    }]
  }
}
```

### 6. Agent 디버깅

Agent 동작 디버깅:

```markdown
# .claude/agents/debug-agent.md
---
name: debug-agent
description: Debug other agents
model: sonnet
---

You are an agent debugging specialist.

When invoked, you:
1. Read the target agent's file
2. Analyze system prompt clarity
3. Check tool permissions
4. Review example quality
5. Test with sample inputs
6. Provide improvement suggestions

Format:
- **Issues Found**: List of problems
- **Recommendations**: Specific fixes
- **Test Results**: Before/after comparison
```

### 7. Agent 성능 모니터링

Agent 성능 추적:

```python
# .claude/scripts/agent-monitor.py
import time
from datetime import datetime

def monitor_agent(agent_name: str, task: str):
    """Agent 실행 시간 및 성공률 모니터링"""
    start = time.time()

    result = Task(
        subagent_type=agent_name,
        prompt=task
    )

    duration = time.time() - start

    # 로그 저장
    with open(".claude/logs/agent_metrics.log", "a") as f:
        f.write(f"{datetime.now()},{agent_name},{duration},{result.success}\n")

    return result
```

---

## 참고 자료

### 공식 문서
- [Sub-agents 공식 문서](https://docs.claude.com/en/docs/claude-code/sub-agents.md)
- [Skills 문서](https://docs.claude.com/en/docs/claude-code/skills.md)
- [Plugins 문서](https://docs.claude.com/en/docs/claude-code/plugins.md)
- [Slash Commands 문서](https://docs.claude.com/en/docs/claude-code/slash-commands.md)
- [Hooks 문서](https://docs.claude.com/en/docs/claude-code/hooks-guide.md)

### 내부 문서
- `.claude/agents/pytest-test-writer.md` - 테스트 작성 agent
- `.claude/agents/langgraph-node-implementer.md` - LangGraph 구현 agent
- `.claude/agents/meta-tester.md` - 메타 테스팅 agent
- `docs/python/testing_guidelines.md` - Python 테스트 가이드라인

### 관련 개념
- **Task Tool**: Agent를 프로그래밍 방식으로 호출
- **Skills**: Agent보다 경량화된 기능 확장
- **Slash Commands**: 사용자 정의 명령어
- **Hooks**: 이벤트 기반 자동화
- **MCP**: 외부 도구 통합

---

## 요약

Claude Code의 Agent는 **전문화된 AI 어시스턴트**로:

1. **독립된 컨텍스트**에서 실행
2. **특정 작업에 최적화**된 시스템 프롬프트
3. **도구 접근 제어**로 보안 강화
4. **재사용 가능**하고 팀과 공유 가능

**Best Practices**:
- 단일 책임 원칙
- 상세한 시스템 프롬프트
- 최소 권한 원칙
- 예시 포함
- 적절한 모델 선택
- 버전 관리
- 테스트 및 반복

**현재 저장소의 Agent**:
1. `pytest-test-writer` - 테스트 자동 생성
2. `langgraph-node-implementer` - TDD 기반 LangGraph 노드 구현
3. `meta-tester` - Claude Code 자체 테스트

Agent를 효과적으로 활용하면 **반복적인 작업 자동화**, **일관된 품질 유지**, **팀 생산성 향상**을 달성할 수 있습니다.

---

**다음 단계**:
1. `/agents` 명령어로 첫 agent 만들어보기
2. 기존 agent를 실제 작업에 활용해보기
3. 팀과 agent 공유 및 개선
4. Agent 파이프라인 구축

Happy Agent Building! 🚀
