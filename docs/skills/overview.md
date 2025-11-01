# Claude Code Skills: 종합 가이드

> **최종 업데이트**: 2025-11-01
> **작성자**: AI Research
> **목적**: Claude Code의 Skills 기능에 대한 완전한 이해

---

## 목차

1. [개요](#개요)
2. [Skills란 무엇인가](#skills란-무엇인가)
3. [Agent vs Skills: 언제 무엇을 사용할까](#agent-vs-skills-언제-무엇을-사용할까)
4. [Skill 파일 구조](#skill-파일-구조)
5. [Progressive Disclosure 디자인](#progressive-disclosure-디자인)
6. [Skill 생성 방법](#skill-생성-방법)
7. [Best Practices](#best-practices)
8. [현재 저장소의 Skills 분석](#현재-저장소의-skills-분석)
9. [고급 활용법](#고급-활용법)
10. [참고 자료](#참고-자료)

---

## 개요

Claude Code의 **Skills**는 Claude의 기능을 확장하는 모듈형 패키지입니다. Agent가 "전문화된 AI 어시스턴트"라면, Skills는 "특정 도메인의 지식과 워크플로우를 제공하는 온보딩 가이드"입니다.

### Skills의 필요성

1. **전문 지식 제공**: 모델이 가질 수 없는 절차적 지식 (회사 정책, API 스펙 등)
2. **워크플로우 자동화**: 반복적인 다단계 프로세스 표준화
3. **도구 통합**: 특정 파일 형식/API와 작업하는 방법 제공
4. **리소스 번들링**: 스크립트, 템플릿, 참조 문서 등 함께 제공
5. **컨텍스트 효율성**: 필요할 때만 로드 (Progressive disclosure)

---

## Skills란 무엇인가

### 핵심 특징

#### 1. Model-Invoked (모델 호출)

**Agent와의 가장 큰 차이점**: Skills는 **Claude가 자동으로 결정**합니다.

```
사용자: "PDF를 회전시켜줘"

Claude: (내부 판단)
→ "pdf-editor skill이 있네"
→ "description을 보니 PDF 회전 기능이 있어"
→ "이 skill을 사용해야겠다"
→ skill-creator skill 자동 활성화

vs. Slash Command (명시적 호출):
사용자: "/rotate-pdf file.pdf"
```

**장점**:
- 사용자가 명령어를 외울 필요 없음
- 자연어로 요청하면 자동으로 적절한 skill 선택
- 여러 skills를 조합하여 복잡한 작업 수행

#### 2. Modular & Self-Contained

각 Skill은 독립적인 패키지:

```
skill-name/
├── SKILL.md          # 메타데이터 + 지시사항 (필수)
├── scripts/          # 실행 가능한 코드 (선택)
├── references/       # 참조 문서 (선택)
└── assets/           # 템플릿, 아이콘 등 (선택)
```

**Agent와 비교**:
- **Agent**: `.claude/agents/{name}.md` (단일 파일)
- **Skill**: `.claude/skills/{name}/` (폴더 구조)

#### 3. Progressive Disclosure

컨텍스트 윈도우를 효율적으로 사용:

```
Level 1: Metadata (항상 로드, ~100 words)
  ├── name: skill-name
  └── description: When to use this...

Level 2: SKILL.md body (skill 활성화 시, <5k words)
  └── 상세 지시사항, 워크플로우

Level 3: Bundled resources (필요 시, unlimited)
  ├── scripts/ (실행 시 컨텍스트 로드 안 함)
  ├── references/ (Claude가 판단하여 로드)
  └── assets/ (출력에 사용, 로드 안 함)
```

**효과**:
- 25개 skills가 있어도 부담 없음 (metadata만 항상 로드)
- 필요한 것만 점진적으로 로드 → 컨텍스트 절약

---

## Agent vs Skills: 언제 무엇을 사용할까

### 비교 표

| 특징 | Agent | Skill |
|------|-------|-------|
| **호출 방식** | Task tool (명시적) | 자동 (Claude 판단) |
| **컨텍스트** | 독립 (별도 윈도우) | 공유 (main conversation) |
| **파일 구조** | 단일 .md 파일 | 폴더 (SKILL.md + 리소스) |
| **목적** | 특화된 AI 어시스턴트 | 지식/워크플로우 제공 |
| **도구 제한** | tools: 필드 | allowed-tools: 필드 |
| **스크립트** | 포함 안 함 | scripts/ 폴더 가능 |
| **템플릿/에셋** | 포함 안 함 | assets/ 폴더 가능 |
| **참조 문서** | 시스템 프롬프트에 포함 | references/ 폴더 (lazy load) |

### 사용 가이드라인

#### Agent를 사용할 때

✅ **자동화된 작업 실행**:
```yaml
# pytest-test-writer agent
- 테스트 코드 생성
- 독립적인 컨텍스트에서 실행
- 실행 후 결과 반환
```

✅ **복잡한 다단계 추론**:
```yaml
# meta-tester agent
- Claude Code 자체 테스트
- subprocess 생성 및 관리
- 종합적 분석 및 보고서
```

✅ **특정 작업에 최적화된 프롬프트**:
```yaml
# langgraph-node-implementer agent
- VCR 기반 TDD 워크플로우
- 특화된 시스템 프롬프트
- 제한된 도구 (Read, Write, Edit, Bash)
```

#### Skills를 사용할 때

✅ **절차적 지식 제공**:
```yaml
# langgraph-tdd-workflow skill
- LangGraph TDD 방법론 설명
- 단계별 워크플로우 가이드
- 참조 문서 및 템플릿 제공
```

✅ **도구/API 통합**:
```yaml
# web-automation skill
- Playwright MCP 사용법
- 브라우저 자동화 워크플로우
- Google OAuth 자동 로그인 패턴
```

✅ **스크립트/템플릿 번들링**:
```yaml
# mcp-builder skill
- MCP 서버 개발 가이드
- 평가 스크립트
- 언어별 참조 문서 (Python, TypeScript)
```

✅ **회사/프로젝트 특화 지식**:
```yaml
# internal-comms skill
- 회사 커뮤니케이션 포맷
- 템플릿 및 예시
- 스타일 가이드
```

### 조합 사용

**Skill + Agent를 함께 사용**:

```
langgraph-tdd-workflow skill (지식 제공)
  ↓ Phase 1-2: 설계 및 Mock 구현
  ↓ Phase 3: 실제 구현 필요
langgraph-node-implementer agent (실행)
  ↓ 노드별 TDD 구현
  ↓ VCR 기반 테스트
```

**실제 시나리오**:
```
User: "LangGraph 워크플로우를 TDD로 만들고 싶어"

Claude:
1. langgraph-tdd-workflow skill 활성화
   - Phase 1-2 가이드 제공
   - State schema 설계 지원
   - Mock nodes 구현 안내

2. Phase 3에서 langgraph-node-implementer agent 호출
   - 각 노드 병렬 구현
   - 테스트 자동 생성
   - VCR cassette 녹화
```

---

## Skill 파일 구조

### SKILL.md (필수)

모든 Skill은 **SKILL.md** 파일을 포함해야 합니다:

```markdown
---
name: skill-identifier
description: What this does and when to use it. Include specific trigger keywords.
allowed-tools: Read, Write, Edit (optional)
license: Complete terms in LICENSE.txt (optional)
---

# Skill Name

Brief overview of what this skill does.

## When to Use This Skill

List specific scenarios and trigger keywords:
- "keyword1" or "phrase1"
- "keyword2" or "phrase2"

## Core Workflow

### Step 1: First Phase
Instructions...

### Step 2: Second Phase
More instructions...

## Examples

Concrete usage examples...

## Best Practices

Guidelines for effective use...

## References

Load these as needed:
- [references/detailed-guide.md](references/detailed-guide.md)
```

### 필수 필드

#### `name` (필수)

Skill의 고유 식별자:

```yaml
name: langgraph-tdd-workflow
name: web-automation
name: mcp-builder
```

**규칙**:
- 소문자, 숫자, 하이픈만 사용
- 최대 64자
- 설명적이어야 함 (축약어 피하기)

#### `description` (필수)

**가장 중요한 필드!** Claude가 언제 이 Skill을 사용할지 결정:

```yaml
# ❌ 나쁜 예 (모호함)
description: Helps with documents

# ✅ 좋은 예 (구체적)
description: Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDFs.

# ✅ 더 좋은 예 (트리거 키워드 포함)
description: Build testable LangGraph workflows using Test-Driven Development. This skill provides a systematic workflow for designing State schemas, implementing mock nodes, testing topology, and progressively implementing real nodes with comprehensive test coverage. Use when creating new LangGraph workflows or improving testability of existing ones.
```

**Best Practices**:
- **기능** 설명 (무엇을 하는가)
- **사용 시기** 명시 (언제 사용하는가)
- **트리거 키워드** 포함 (어떤 단어를 들으면 활성화되는가)
- 최대 1024자
- 3인칭 사용 ("This skill should be used when...")

### 선택 필드

#### `allowed-tools` (선택)

Skill 사용 중 Claude가 쓸 수 있는 도구 제한:

```yaml
# 읽기 전용 skill
allowed-tools: Read, Grep, Glob

# 분석 및 리포트 작성
allowed-tools: Read, Grep, Glob, Write

# 브라우저 자동화 (MCP만)
allowed-tools: mcp__microsoft-playwright-mcp__*
```

**목적**:
- 보안 (읽기 전용 skill이 파일 수정 방지)
- 범위 제한 (skill이 의도된 작업만 수행)
- 권한 요청 줄이기

#### `license` (선택)

라이선스 정보:

```yaml
license: Complete terms in LICENSE.txt
license: MIT
```

---

## Progressive Disclosure 디자인

### 3단계 로딩 시스템

Skills의 가장 혁신적인 디자인:

```
┌─────────────────────────────────────────┐
│ Level 1: Metadata (~100 words)          │
│ ✅ 항상 컨텍스트에 로드                    │
│ - name                                   │
│ - description                            │
│ - allowed-tools                          │
└─────────────────────────────────────────┘
           ↓ Skill 활성화 시
┌─────────────────────────────────────────┐
│ Level 2: SKILL.md Body (<5k words)      │
│ ✅ Skill 트리거 시 로드                   │
│ - 워크플로우 지시사항                      │
│ - 단계별 가이드                           │
│ - 예시                                   │
└─────────────────────────────────────────┘
           ↓ 필요 시 (Claude 판단)
┌─────────────────────────────────────────┐
│ Level 3: Bundled Resources (unlimited)  │
│ ✅ 필요할 때만 로드                       │
│ - scripts/ (실행, 컨텍스트 로드 X)         │
│ - references/ (Claude가 선택적 로드)      │
│ - assets/ (출력에 사용, 로드 X)           │
└─────────────────────────────────────────┘
```

### 예시: mcp-builder Skill

```
활성화 전:
Context: name=mcp-builder, description=Guide for creating...
Token usage: ~50 tokens

활성화 후:
Context: + SKILL.md body (MCP 개발 가이드, 4단계 프로세스)
Token usage: ~2,000 tokens

참조 문서 로드 (필요 시):
Context: + references/python_mcp_server.md
Token usage: +1,500 tokens

스크립트 실행:
실행만 함, 컨텍스트 로드 안 함
Token usage: 0 tokens (효율적!)
```

### 설계 원칙

1. **SKILL.md는 간결하게** (<5k words)
   - 핵심 워크플로우만
   - 상세 내용은 references/로

2. **References는 구체적으로**
   - 언어별 가이드 분리
   - 주제별 문서 분리
   - Claude가 필요할 때만 로드

3. **Scripts는 결정론적으로**
   - 반복적으로 재작성되는 코드
   - 토큰 효율적 (실행만, 로드 안 함)
   - 예: PDF 회전, 이미지 리사이즈

4. **Assets는 출력용**
   - 템플릿, 아이콘, 폰트 등
   - 컨텍스트 로드 안 함
   - 복사/수정하여 사용

---

## Skill 생성 방법

### 방법 1: skill-creator Skill 사용 (권장)

```
User: "MCP 서버 개발 가이드를 만드는 skill을 만들고 싶어"

Claude: (skill-creator skill 자동 활성화)
  ↓
Step 1: 구체적 사용 예시 수집
  - "어떤 기능을 지원해야 하나요?"
  - "어떤 상황에서 사용되나요?"
  - "사용자가 어떻게 요청할까요?"

Step 2: 재사용 가능한 컨텐츠 계획
  - Scripts: 필요한 자동화 코드?
  - References: 참조할 문서?
  - Assets: 템플릿이나 예시?

Step 3: Skill 초기화
  - 디렉토리 구조 생성
  - SKILL.md 템플릿 작성
  - 예시 파일 생성

Step 4: Skill 편집
  - SKILL.md 작성 (명령형 문체)
  - Scripts 구현
  - References 작성
  - Assets 추가

Step 5: 패키징 (선택)
  - 검증 및 zip 생성

Step 6: 반복
  - 실제 사용 → 피드백 → 개선
```

### 방법 2: 직접 생성

```bash
# 1. Skill 폴더 생성
mkdir -p .claude/skills/my-skill/{scripts,references,assets}

# 2. SKILL.md 작성
cat > .claude/skills/my-skill/SKILL.md << 'EOF'
---
name: my-skill
description: This skill helps with X. Use when users request Y or Z.
---

# My Skill

## When to Use

Trigger when:
- User says "X"
- User needs "Y"

## Workflow

### Step 1: Analyze Request
...

### Step 2: Execute
...
EOF

# 3. 리소스 추가 (필요시)
# scripts/helper.py
# references/guide.md
# assets/template.txt

# 4. Claude Code 재시작
claude  # skill 로드
```

### 방법 3: 기존 Skill 복제

```bash
# 템플릿으로 사용
cp -r .claude/skills/template-skill .claude/skills/my-new-skill

# 편집
vim .claude/skills/my-new-skill/SKILL.md

# 불필요한 예시 파일 삭제
rm -rf .claude/skills/my-new-skill/scripts/example_*
rm -rf .claude/skills/my-new-skill/references/example_*
```

---

## Best Practices

### 1. 집중된 Skills (Single Responsibility)

각 Skill은 하나의 명확한 목적:

✅ **좋은 예**:
```
langgraph-tdd-workflow: LangGraph TDD 방법론만
web-automation: 브라우저 자동화만
mcp-builder: MCP 서버 개발만
```

❌ **나쁜 예**:
```
developer-helper: 테스트도 쓰고, 브라우저도 자동화하고, MCP도 만들고...
→ 너무 광범위, 언제 활성화할지 모호
```

### 2. 구체적인 Description

Claude가 언제 사용할지 명확히:

✅ **좋은 예**:
```yaml
description: Automate web browser tasks using Playwright MCP to navigate websites, fill forms, extract data, and generate API keys. Use this skill when users request browser automation like "get me an API key from GCP", "fill out this form", or "extract data from this website".
```

**포함 요소**:
- 기능 설명 (what)
- 사용 시기 (when)
- 구체적 트리거 (예시 문장)

❌ **나쁜 예**:
```yaml
description: Helps with web stuff
```

### 3. 명령형 문체 (Imperative/Infinitive)

SKILL.md는 객관적, 지시적 톤:

✅ **좋은 예**:
```markdown
To accomplish X, do Y.
For best results, follow these steps:
1. Analyze the request
2. Plan the workflow
3. Execute systematically
```

❌ **나쁜 예**:
```markdown
You should do X.
If you need to do X, you can try Y.
```

**이유**: AI consumption을 위한 일관성

### 4. Progressive Disclosure 활용

SKILL.md는 간결하게, 상세 내용은 references/로:

**SKILL.md** (핵심 워크플로우):
```markdown
## Core Workflow

### Phase 1: Design
- Create State schema (Pydantic)
- Design graph topology
- Implement mock nodes

For detailed State schema patterns, see:
[references/state-schema-pattern.md](references/state-schema-pattern.md)
```

**references/state-schema-pattern.md** (상세 가이드):
```markdown
# State Schema Patterns

## Pydantic Model Design

### Pattern 1: Basic State
(20 examples...)

### Pattern 2: Complex State
(detailed explanation...)
```

**효과**:
- SKILL.md: 2k tokens
- references/: 5k tokens (필요할 때만)
- 총 컨텍스트 절약: ~70%

### 5. Script vs Reference 구분

#### Scripts/ (scripts/)

**언제**: 반복적으로 재작성되는 코드

✅ **적합**:
```python
# scripts/rotate_pdf.py
# PDF 회전은 항상 같은 코드

# scripts/resize_image.py
# 이미지 리사이즈는 정형화

# scripts/init_skill.py
# Skill 초기화는 표준화
```

**장점**:
- 실행만, 컨텍스트 로드 안 함
- 결정론적 (항상 동일한 결과)
- 토큰 효율적

#### References/ (references/)

**언제**: Claude가 참조할 문서

✅ **적합**:
```
references/api_docs.md
  - API 스펙 (Claude가 참조하며 코드 작성)

references/company_policies.md
  - 회사 정책 (Claude가 참조하며 판단)

references/database_schema.md
  - DB 스키마 (Claude가 참조하며 쿼리 작성)
```

**장점**:
- 필요할 때만 로드
- Claude가 지식을 얻음
- SKILL.md 간결 유지

#### Assets/ (assets/)

**언제**: 출력에 사용할 파일

✅ **적합**:
```
assets/logo.png
  - 브랜드 로고 (문서에 삽입)

assets/template.html
  - HTML 템플릿 (복사 후 수정)

assets/frontend-boilerplate/
  - React 보일러플레이트 (복사 후 커스터마이즈)
```

**장점**:
- 컨텍스트 로드 안 함
- 바로 사용 가능
- 일관된 결과물

### 6. YAML Frontmatter 검증

Invalid YAML은 Skill 로드 실패:

✅ **올바른 형식**:
```yaml
---
name: my-skill
description: This skill helps with X. Use when Y.
allowed-tools: Read, Write
---
```

❌ **잘못된 형식**:
```yaml
name: my-skill  # ← --- 없음
description: ...
---
```

```yaml
---
name: my-skill
description: "This has "quotes" inside"  # ← 이스케이프 안 됨
---
```

**검증 방법**:
```bash
# Python
python -c "import yaml; yaml.safe_load(open('.claude/skills/my-skill/SKILL.md').read().split('---')[1])"

# 또는 skill-creator의 package_skill.py 사용
```

### 7. 팀과 테스트

**반복 사이클**:
```
1. Skill 생성
2. 팀원에게 테스트 요청
   - "X를 해줘" 라고 말했을 때 skill이 활성화되나?
   - 지시사항이 명확한가?
   - 트리거 키워드가 자연스러운가?
3. 피드백 수집
4. Description 및 SKILL.md 개선
5. 반복
```

---

## 현재 저장소의 Skills 분석

### 전체 현황 (25개)

현재 `.claude/skills/`에 25개의 skills가 있습니다:

**카테고리별 분류**:

#### 1. 메타/관리 Skills (3개)
- `skill-creator` - Skill 생성 가이드
- `agent-creator` - Agent 생성 가이드
- `template-skill` - Skill 템플릿

#### 2. 워크플로우 Skills (6개)
- `langgraph-tdd-workflow` - LangGraph TDD 방법론
- `blueprint-orchestrator` - YAML 기반 멀티 skill 파이프라인
- `n8n-automation-builder` - n8n 워크플로우 구축
- `ai-collaborative-solver` - AI 토론 기반 문제 해결
- `codex-collaborative-solver` - Codex 통합 협업 솔버
- `git-worktree-manager` - Git worktree 관리

#### 3. 도구/통합 Skills (7개)
- `web-automation` - Playwright 브라우저 자동화
- `webapp-testing` - Playwright 웹앱 테스팅
- `mcp-builder` - MCP 서버 개발 가이드
- `codex-integration` - OpenAI Codex CLI 통합
- `pre-commit-code-reviewer` - Codex 기반 코드 리뷰
- `linear-project-manager` - Linear MCP 통합
- `speckit-manager` - Speckit 라이브러리 관리

#### 4. 디자인/아티팩트 Skills (5개)
- `artifacts-builder` - claude.ai HTML 아티팩트 (React)
- `canvas-design` - PNG/PDF 시각 디자인
- `algorithmic-art` - p5.js 알고리즘 아트
- `slack-gif-creator` - Slack용 애니메이션 GIF
- `theme-factory` - 아티팩트 테마 스타일링

#### 5. 문서/커뮤니케이션 Skills (2개)
- `internal-comms` - 사내 커뮤니케이션 포맷
- `brand-guidelines` - Anthropic 브랜드 가이드라인

#### 6. 도메인 특화 Skills (2개)
- `prompt-engineer` - 프롬프트 엔지니어링 가이드
- (backup 폴더 제외)

### 주목할 만한 Skills 심층 분석

#### 1. langgraph-tdd-workflow

**파일**: `.claude/skills/langgraph-tdd-workflow/SKILL.md`

**목적**: LangGraph를 TDD 방식으로 구축하는 체계적 워크플로우

**핵심 특징**:

1. **4단계 프로세스**:
   ```
   Phase 1: Design & Documentation (Top-Down)
   Phase 2: Mock Implementation
   Phase 3: Progressive Implementation
   Phase 4: Integration Testing
   ```

2. **Agent 통합**:
   ```markdown
   ### Option B: Parallel (Agent Orchestration) ⚡
   Uses langgraph-node-implementer agent for parallel node implementation
   ```

3. **Progressive Disclosure**:
   - SKILL.md: 핵심 워크플로우 (~300줄)
   - References: 상세 가이드
     - `state-schema-pattern.md`
     - `topology-testing.md`
     - `split-merge-testing.md`
     - `best-practices.md`

4. **Templates**:
   ```
   assets/templates/
   ├── node_spec_template.md
   ├── complete_example.py
   ├── state_schema.py
   ├── mock_node.py
   └── test_topology.py
   ```

**활성화 트리거**:
- "LangGraph TDD"
- "testable workflow"
- "how to test LangGraph"
- "LangGraph workflows"

**Skill + Agent 조합**:
```
langgraph-tdd-workflow skill
  → Phase 1-2: 설계 및 Mock (Skill 가이드)
  → Phase 3: 실제 구현 (Agent 호출)
    └── langgraph-node-implementer agent (병렬 실행)
```

#### 2. web-automation

**파일**: `.claude/skills/web-automation/SKILL.md`

**목적**: Playwright MCP를 사용한 브라우저 자동화

**핵심 특징**:

1. **자동 Google OAuth**:
   ```markdown
   ### Step 4.5: Handle Google OAuth Login (Automated)
   - Detect "Continue with Google" button
   - Automatically select Google account
   - Persistent browser sessions
   ```

2. **사용자 개입 패턴**:
   ```markdown
   ### Step 5: Handle User Intervention Points
   - Login/authentication (non-Google)
   - 2FA, CAPTCHA
   - Clear communication template
   ```

3. **6단계 워크플로우**:
   ```
   Step 1: Understand Goal
   Step 2: Plan Automation Sequence
   Step 3: Initialize Browser
   Step 4: Execute Automated Steps
   Step 4.5: Handle Google OAuth (Automated)
   Step 5: Handle User Intervention
   Step 6: Extract and Report Results
   ```

4. **시나리오 라이브러리**:
   - Cloud Service API Key Generation
   - Form Submission
   - Data Extraction
   - Account Settings Update
   - Service with Google OAuth

**활성화 트리거**:
- "web automation"
- "browser"
- "navigate to"
- "API key"
- "fill form"
- "extract from website"

**실용성**: GCP, Linear, Notion 등 Google OAuth 서비스에서 API 키 자동 생성

#### 3. mcp-builder

**파일**: `.claude/skills/mcp-builder/SKILL.md`

**목적**: 고품질 MCP 서버 개발 가이드

**핵심 특징**:

1. **4단계 프로세스**:
   ```markdown
   Phase 1: Deep Research and Planning
   Phase 2: Implementation
   Phase 3: Review and Refine
   Phase 4: Create Evaluations
   ```

2. **Agent-Centric Design 원칙**:
   ```markdown
   - Build for Workflows, Not Just API Endpoints
   - Optimize for Limited Context
   - Design Actionable Error Messages
   - Follow Natural Task Subdivisions
   - Use Evaluation-Driven Development
   ```

3. **언어별 가이드**:
   ```
   references/
   ├── mcp_best_practices.md
   ├── python_mcp_server.md
   ├── node_mcp_server.md
   └── evaluation.md
   ```

4. **외부 문서 통합**:
   ```markdown
   Use WebFetch to load:
   - https://modelcontextprotocol.io/llms-full.txt
   - https://raw.githubusercontent.com/.../python-sdk/main/README.md
   - https://raw.githubusercontent.com/.../typescript-sdk/main/README.md
   ```

**활성화 트리거**:
- "MCP server"
- "Model Context Protocol"
- "integrate external API"
- "FastMCP", "MCP SDK"

**혁신**: WebFetch로 최신 문서 자동 로드 → 항상 최신 정보

#### 4. skill-creator

**파일**: `.claude/skills/skill-creator/SKILL.md`

**목적**: Skill 생성 방법론

**핵심 특징**:

1. **6단계 생성 프로세스**:
   ```markdown
   Step 1: Understanding the Skill with Concrete Examples
   Step 2: Planning the Reusable Skill Contents
   Step 3: Initializing the Skill (scripts/init_skill.py)
   Step 4: Edit the Skill
   Step 5: Packaging a Skill (scripts/package_skill.py)
   Step 6: Iterate
   ```

2. **Progressive Disclosure 설명**:
   ```markdown
   ## Progressive Disclosure Design Principle
   3-level loading system:
   1. Metadata (~100 words)
   2. SKILL.md body (<5k words)
   3. Bundled resources (Unlimited*)
   ```

3. **Scripts 포함**:
   ```
   scripts/
   ├── init_skill.py      # Skill 초기화
   └── package_skill.py   # 검증 및 패키징
   ```

4. **Skill Anatomy 교육**:
   ```markdown
   - scripts/ - 실행 가능 코드 (결정론적)
   - references/ - 문서 (Claude 참조)
   - assets/ - 출력 파일 (템플릿, 아이콘)
   ```

**메타적 특성**: 이 Skill 자체가 Skill의 모범 사례

### Skills 통계

| 카테고리 | 개수 | 비율 |
|----------|------|------|
| 메타/관리 | 3 | 12% |
| 워크플로우 | 6 | 24% |
| 도구/통합 | 7 | 28% |
| 디자인/아티팩트 | 5 | 20% |
| 문서/커뮤니케이션 | 2 | 8% |
| 도메인 특화 | 2 | 8% |
| **총계** | **25** | **100%** |

**평균 복잡도**:
- Simple (SKILL.md만): 40%
- Medium (+ references/): 36%
- Complex (+ scripts/, references/, assets/): 24%

---

## 고급 활용법

### 1. Skill Composition (조합)

여러 Skills를 조합하여 복잡한 작업:

```
User: "Linear에서 이슈를 가져와서 GCP Vertex AI로 분석하고 결과를 Notion에 저장해줘"

Claude:
1. linear-project-manager skill
   → Linear 이슈 조회

2. web-automation skill
   → GCP Vertex AI 콘솔 접근
   → API 호출 (Google OAuth 자동)

3. web-automation skill (Notion)
   → Notion 페이지 생성
   → 분석 결과 저장
```

### 2. Skill + Agent Pipeline

Skill이 지식 제공, Agent가 실행:

```
blueprint-orchestrator skill
  ↓ (YAML 파이프라인 정의)
  ↓
langgraph-tdd-workflow skill
  ↓ (Phase 1-2 가이드)
  ↓
langgraph-node-implementer agent
  ↓ (병렬 노드 구현)
  ↓
pre-commit-code-reviewer skill + codex-integration
  ↓ (Codex 기반 리뷰)
  ↓
Complete!
```

### 3. Dynamic Skill Loading

References를 조건부 로드:

```markdown
# SKILL.md

## Phase 1: Python Implementation

For Python projects, load:
[references/python_guide.md](references/python_guide.md)

## Phase 2: TypeScript Implementation

For TypeScript projects, load:
[references/typescript_guide.md](references/typescript_guide.md)
```

**효과**:
- Python 프로젝트: TypeScript 가이드 로드 안 함
- 컨텍스트 절약: ~50%

### 4. External Documentation Integration

WebFetch로 최신 문서 자동 로드:

```markdown
# mcp-builder/SKILL.md

### Step 1.3: Study MCP Protocol Documentation

Use WebFetch to load:
`https://modelcontextprotocol.io/llms-full.txt`

This ensures you always have the latest MCP specification.
```

**장점**:
- 항상 최신 정보
- Skill 파일 크기 작게 유지
- 외부 변경사항 자동 반영

### 5. Skill Versioning

References를 버전별로 관리:

```
references/
├── v1/
│   ├── api_spec.md
│   └── examples.md
├── v2/
│   ├── api_spec.md
│   └── examples.md
└── latest -> v2/
```

**SKILL.md**:
```markdown
For API v2 (recommended):
[references/latest/api_spec.md](references/latest/api_spec.md)

For legacy API v1:
[references/v1/api_spec.md](references/v1/api_spec.md)
```

### 6. Templated Workflows

Assets를 복사하여 프로젝트 스캐폴딩:

```markdown
# langgraph-tdd-workflow/SKILL.md

To start a new LangGraph project:

1. Copy template structure:
   ```bash
   cp -r assets/templates/complete_example.py .
   ```

2. Customize State schema:
   - Edit WorkflowState class
   - Add project-specific fields

3. Implement nodes:
   - Replace mock implementations
   - Follow TDD process
```

### 7. Multi-Language Support

동일 Skill, 다른 언어:

```
mcp-builder/
├── SKILL.md (메인)
└── references/
    ├── python_mcp_server.md
    ├── node_mcp_server.md
    └── go_mcp_server.md (미래)
```

**SKILL.md**:
```markdown
## Language Selection

Based on your preference:
- Python → Load [references/python_mcp_server.md]
- TypeScript → Load [references/node_mcp_server.md]
- Go → Load [references/go_mcp_server.md]
```

### 8. Conditional Workflows

사용자 컨텍스트에 따라 다른 경로:

```markdown
# web-automation/SKILL.md

## Workflow Selection

### If Google OAuth available:
1. Detect "Sign in with Google"
2. **Automated flow** (no user intervention)
3. Proceed to main task

### If other authentication:
1. Navigate to login page
2. **User intervention** (manual login)
3. Wait for confirmation
4. Proceed to main task
```

---

## 참고 자료

### 공식 문서
- [Claude Code Skills 공식 문서](https://docs.claude.com/en/docs/claude-code/skills.md)
- [Slash Commands 문서](https://docs.claude.com/en/docs/claude-code/slash-commands.md)
- [Sub-agents 문서](https://docs.claude.com/en/docs/claude-code/sub-agents.md)

### 내부 문서
- `.claude/skills/skill-creator/SKILL.md` - Skill 생성 가이드
- `.claude/skills/langgraph-tdd-workflow/` - 워크플로우 예시
- `.claude/skills/mcp-builder/` - 복잡한 Skill 예시
- `docs/agents/overview.md` - Agent와의 비교

### 관련 개념
- **Progressive Disclosure**: 점진적 정보 공개
- **Model-Invoked**: Claude가 자동 판단
- **Bundled Resources**: 스크립트, 참조, 에셋 번들링
- **Agent vs Skills**: 언제 무엇을 사용할까

---

## 요약

### Skills의 핵심

Claude Code Skills는:

1. **자동으로 활성화** (description 기반 매칭)
2. **지식과 워크플로우 제공** (절차적 지식)
3. **리소스 번들링** (scripts, references, assets)
4. **Progressive Disclosure** (필요할 때만 로드)
5. **팀과 공유** (git으로 관리)

### Agent vs Skills

| 언제 | 사용 |
|------|------|
| 자동화된 작업 실행 | Agent |
| 절차적 지식 제공 | Skill |
| 복잡한 추론 필요 | Agent |
| 도구/API 통합 가이드 | Skill |
| 독립 컨텍스트 필요 | Agent |
| 스크립트/템플릿 번들링 | Skill |

### Best Practices 요약

1. **집중된 Skills** - 하나의 명확한 목적
2. **구체적인 Description** - 트리거 키워드 포함
3. **명령형 문체** - 객관적, 지시적
4. **Progressive Disclosure** - SKILL.md 간결, 상세는 references/
5. **Script vs Reference 구분** - 용도에 맞게
6. **YAML 검증** - 로드 실패 방지
7. **팀과 테스트** - 반복적 개선

### 현재 저장소

- **25개 Skills** (6개 카테고리)
- **다양한 복잡도** (simple → complex)
- **실용적 예시** (langgraph-tdd, web-automation, mcp-builder)
- **메타 Skills** (skill-creator, agent-creator)

---

**다음 단계**:
1. 기존 Skills 탐색 ("What skills are available?")
2. 새 Skill 만들기 (skill-creator 사용)
3. Skill + Agent 조합 활용
4. 팀과 공유 및 개선

Happy Skill Building! 🚀
