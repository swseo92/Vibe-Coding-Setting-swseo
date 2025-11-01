# Claude Code Skills: 문서 인덱스

> **최종 업데이트**: 2025-11-01
> **관련 문서**: [Agents 문서](../agents/)

---

## 문서 목록

### 1. [overview.md](./overview.md) - Skills 종합 가이드
Claude Code Skills 기능의 완전한 이해

**내용**:
- Skills란 무엇인가 (Model-invoked, Progressive Disclosure)
- **Agent vs Skills 비교** (언제 무엇을 사용할까)
- Skill 파일 구조 (SKILL.md + 리소스)
- Progressive Disclosure 디자인 (3단계 로딩)
- Skill 생성 방법 (3가지)
- Best Practices (7가지 핵심 원칙)
- 현재 저장소의 Skills 분석 (25개!)
  - 카테고리별 분류
  - 주요 Skills 심층 분석:
    - `langgraph-tdd-workflow` - TDD 워크플로우
    - `web-automation` - Playwright 자동화 + Google OAuth
    - `mcp-builder` - MCP 서버 개발
    - `skill-creator` - Skill 생성 방법론
- 고급 활용법 (8가지 패턴)

**대상 독자**: 초보자 ~ 고급 사용자

---

## 핵심 개념

### Skills vs Agents

| 특징 | Agent | Skill |
|------|-------|-------|
| **호출** | 명시적 (Task tool) | 자동 (Claude 판단) |
| **컨텍스트** | 독립 | 공유 (main conversation) |
| **구조** | 단일 .md | 폴더 (SKILL.md + 리소스) |
| **목적** | 작업 실행 | 지식/워크플로우 제공 |

**사용 가이드**:
- **Agent**: 자동화된 작업 실행 (pytest-test-writer, meta-tester)
- **Skill**: 절차적 지식 제공 (langgraph-tdd-workflow, mcp-builder)
- **조합**: Skill (가이드) → Agent (실행)

### Progressive Disclosure

Skills의 혁신적 디자인:

```
Level 1: Metadata (~100 words) ✅ 항상 로드
  ↓ Skill 활성화 시
Level 2: SKILL.md Body (<5k words) ✅ 필요 시 로드
  ↓ Claude 판단으로
Level 3: Bundled Resources (unlimited) ✅ 선택적 로드
```

**효과**: 25개 skills가 있어도 컨텍스트 부담 없음

---

## 현재 저장소 Skills (25개)

### 카테고리별

1. **메타/관리** (3개)
   - skill-creator, agent-creator, template-skill

2. **워크플로우** (6개)
   - langgraph-tdd-workflow ⭐
   - blueprint-orchestrator
   - n8n-automation-builder
   - ai-collaborative-solver
   - codex-collaborative-solver
   - git-worktree-manager

3. **도구/통합** (7개)
   - web-automation ⭐ (Google OAuth 자동)
   - webapp-testing
   - mcp-builder ⭐ (MCP 서버 개발)
   - codex-integration
   - pre-commit-code-reviewer
   - linear-project-manager
   - speckit-manager

4. **디자인/아티팩트** (5개)
   - artifacts-builder, canvas-design
   - algorithmic-art, slack-gif-creator
   - theme-factory

5. **문서/커뮤니케이션** (2개)
   - internal-comms, brand-guidelines

6. **도메인 특화** (2개)
   - prompt-engineer

### 복잡도 분포

- **Simple** (SKILL.md만): 40%
- **Medium** (+ references/): 36%
- **Complex** (+ scripts/, references/, assets/): 24%

---

## Quick Start

### Skills 확인하기

```
User: "What skills are available?"

Claude: (25개 skills 목록 + 설명)
```

### Skill 사용하기 (자동)

```
User: "LangGraph를 TDD로 만들고 싶어"

Claude: (langgraph-tdd-workflow skill 자동 활성화)
  → Phase 1-4 가이드 제공
```

### 새 Skill 만들기

```
User: "API 문서 생성 skill을 만들고 싶어"

Claude: (skill-creator skill 자동 활성화)
  → 6단계 생성 프로세스 안내
```

---

## Best Practices

### 1. 집중된 Skills
각 Skill은 하나의 명확한 목적만

### 2. 구체적인 Description
트리거 키워드 포함으로 자동 활성화 정확도 향상

### 3. Progressive Disclosure
SKILL.md 간결, 상세는 references/

### 4. Script vs Reference 구분
- **scripts/**: 반복 코드 (실행만, 컨텍스트 로드 X)
- **references/**: 참조 문서 (Claude가 읽음)
- **assets/**: 출력 파일 (템플릿, 로고 등)

### 5. 명령형 문체
"To accomplish X, do Y" (객관적, 지시적)

### 6. YAML 검증
Invalid YAML → Skill 로드 실패

### 7. 팀과 테스트
반복적 피드백으로 개선

---

## 고급 패턴

### 1. Skill Composition
여러 Skills 조합으로 복잡한 작업

### 2. Skill + Agent Pipeline
Skill이 가이드, Agent가 실행

### 3. Dynamic Skill Loading
조건에 따라 references 선택적 로드

### 4. External Documentation
WebFetch로 최신 문서 자동 통합

### 5. Multi-Language Support
동일 Skill, 언어별 references

---

## 주요 Skills 가이드

### langgraph-tdd-workflow

**목적**: LangGraph TDD 방법론

**특징**:
- 4단계 프로세스
- Agent 통합 (langgraph-node-implementer)
- Templates, References 완비

**활성화**: "LangGraph TDD", "testable workflow"

### web-automation

**목적**: Playwright 브라우저 자동화

**특징**:
- Google OAuth 자동 로그인
- 사용자 개입 패턴
- 6단계 워크플로우

**활성화**: "browser automation", "API key", "fill form"

**실용**: GCP, Linear, Notion 등 자동화

### mcp-builder

**목적**: MCP 서버 개발 가이드

**특징**:
- 4단계 개발 프로세스
- Agent-Centric 디자인 원칙
- 언어별 가이드 (Python, TypeScript)

**활성화**: "MCP server", "integrate API"

**혁신**: WebFetch로 최신 SDK 문서 자동 로드

### skill-creator

**목적**: Skill 생성 방법론

**특징**:
- 6단계 생성 프로세스
- Scripts (init_skill.py, package_skill.py)
- Progressive Disclosure 교육

**활성화**: "create a skill", "update skill"

**메타적**: Skill의 모범 사례

---

## 참고 자료

### 공식 문서
- [Claude Code Skills](https://docs.claude.com/en/docs/claude-code/skills.md)
- [Slash Commands](https://docs.claude.com/en/docs/claude-code/slash-commands.md)
- [Sub-agents](https://docs.claude.com/en/docs/claude-code/sub-agents.md)

### 내부 문서
- [Agents 문서](../agents/) - Agent와의 비교
- `.claude/skills/skill-creator/` - Skill 생성 가이드
- `.claude/skills/langgraph-tdd-workflow/` - 워크플로우 예시
- `.claude/skills/mcp-builder/` - 복잡한 Skill 예시

### Skill 파일 위치
- **프로젝트**: `.claude/skills/{name}/`
- **전역**: `~/.claude/skills/{name}/`

---

## 다음 단계

1. [ ] [overview.md](./overview.md) 읽기 (완전한 이해)
2. [ ] "What skills are available?" 물어보기 (현재 skills 확인)
3. [ ] 기존 Skill 사용해보기 (자동 활성화 체험)
4. [ ] skill-creator로 새 Skill 만들기
5. [ ] Skill + Agent 조합 활용

---

## 문서 히스토리

| 날짜 | 문서 | 버전 | 변경 사항 |
|------|------|------|----------|
| 2025-11-01 | overview.md | 1.0 | Skills 종합 가이드 작성 |
| 2025-11-01 | README.md | 1.0 | 문서 인덱스 생성 |

---

**마지막 업데이트**: 2025-11-01
**관리자**: swseo
**관련 문서**: [Agents 문서](../agents/)
