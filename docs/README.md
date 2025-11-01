# Vibe-Coding-Setting 문서

> **저장소**: Claude Code 설정 및 개발환경 관리
> **최종 업데이트**: 2025-11-01

---

## 📚 문서 구조

### 🤖 Claude Code 기능

#### 1. [Agents](./agents/) - 전문화된 AI 어시스턴트
- **[Agents 종합 가이드](./agents/overview.md)** - Agent 개념, 구조, 생성, 활용법
- **[Agent 전략 토론](./agents/codex-debate-agent-strategy.md)** - Claude + Codex 협업 분석
- **[Implementation Partner MVP](./agents/implementation-partner-mvp-refined.md)** - 수정된 구현 계획

**현재 Agents (3개)**:
- `pytest-test-writer` - pytest 테스트 자동 생성
- `langgraph-node-implementer` - VCR 기반 TDD LangGraph 노드 구현
- `meta-tester` - Claude Code 자체 테스트 (메타 테스팅)

#### 2. [Skills](./skills/) - 지식과 워크플로우 제공
- **[Skills 종합 가이드](./skills/overview.md)** - Skill 개념, 구조, 생성, 활용법
- **Agent vs Skills 비교** - 언제 무엇을 사용할까

**현재 Skills (25개)**, 카테고리별:
- **메타/관리** (3): skill-creator, agent-creator, template-skill
- **워크플로우** (6): langgraph-tdd-workflow, blueprint-orchestrator, git-worktree-manager 등
- **도구/통합** (7): web-automation, mcp-builder, codex-integration 등
- **디자인** (5): artifacts-builder, canvas-design, algorithmic-art 등
- **문서** (2): internal-comms, brand-guidelines
- **도메인** (2): prompt-engineer 등

### 🛠️ 기술 문서

#### Python
- **[testing_guidelines.md](./python/testing_guidelines.md)** - Python 테스트 가이드라인

#### MCP (Model Context Protocol)
- **[Playwright 지속 로그인](./playwright-persistent-login.md)** - Playwright MCP 설정 가이드

### 📖 프로젝트 문서

#### LangGraph
- **[TDD 분석](./langgraph-tdd-analysis-summary.md)** - LangGraph TDD 방법론
- **[VCR 마이그레이션](./langgraph-vcr-migration-guide.md)** - VCR cassette 기반 테스팅
- **[비주얼 가이드](./langgraph-tdd-visual-guide.md)** - 시각적 설명
- **[비교 예시](./langgraph-tdd-comparison-example.md)** - Mock vs VCR
- **[실전 vs Mock API](./langgraph-tdd-analysis-real-vs-mock-api.md)** - 상세 분석
- **[Quick Reference](./langgraph-vcr-quick-reference.md)** - 빠른 참조

#### Git Worktree
- **[분석 및 개선](./worktree-analysis-and-improvements.md)** - Worktree 활용 분석
- **[의사결정 프레임워크](./worktree-decision-framework.md)** - 언제 사용할까
- **[구현 예시](./worktree-implementation-examples.md)** - 실전 예시
- **[Quick Reference](./worktree-quick-reference.md)** - 빠른 참조

#### OpenAI Codex
- **[Codex 가이드](./openai-codex-guide.md)** - OpenAI Codex CLI 사용법

#### 기타
- **[지식 베이스 설계](./knowledge-base-design.md)** - KB 아키텍처
- **[변경 사항 요약](./CHANGES_SUMMARY.md)** - 주요 변경사항
- **[마이그레이션](./MIGRATION.md)** - 마이그레이션 가이드
- **[리뷰](./REVIEW.md)** - 코드 리뷰 노트

---

## 🔍 빠른 탐색

### Agents vs Skills, 언제 무엇을?

| 상황 | 사용 | 문서 |
|------|------|------|
| **자동화된 작업 실행** | Agent | [Agents 가이드](./agents/overview.md#agent-사용-방법) |
| **절차적 지식 제공** | Skill | [Skills 가이드](./skills/overview.md#skills란-무엇인가) |
| **복잡한 추론 필요** | Agent | [Agent 예시](./agents/overview.md#현재-저장소의-agent-분석) |
| **도구/API 통합 가이드** | Skill | [Skill 예시](./skills/overview.md#현재-저장소의-skills-분석) |
| **독립 컨텍스트 필요** | Agent | [Agent vs Skills](./agents/overview.md#agent란-무엇인가) |
| **스크립트/템플릿 번들링** | Skill | [Skill 구조](./skills/overview.md#skill-파일-구조) |

### 실용적 시나리오

#### 1. LangGraph 워크플로우 개발

```
langgraph-tdd-workflow skill (Skill)
  ↓ Phase 1-2: 설계 및 Mock
langgraph-node-implementer agent (Agent)
  ↓ Phase 3: 병렬 노드 구현
```

**문서**:
- [langgraph-tdd-workflow](./skills/overview.md#1-langgraph-tdd-workflow)
- [langgraph-node-implementer](./agents/overview.md#2-langgraph-node-implementer)

#### 2. Web Automation (API 키 생성)

```
web-automation skill (Skill)
  ↓ Playwright 워크플로우
  ↓ Google OAuth 자동 로그인
  ↓ GCP/Linear/Notion 자동화
```

**문서**:
- [web-automation](./skills/overview.md#2-web-automation)
- [Playwright 설정](./playwright-persistent-login.md)

#### 3. MCP 서버 개발

```
mcp-builder skill (Skill)
  ↓ 4단계 개발 프로세스
  ↓ Agent-Centric 디자인
  ↓ 언어별 가이드 (Python/TypeScript)
```

**문서**:
- [mcp-builder](./skills/overview.md#3-mcp-builder)

#### 4. 테스트 자동 생성 + 구현

```
pytest-test-writer agent (Agent)
  ↓ pytest 테스트 생성
  ↓ MCP에 task 작성
implementation-partner agent (Agent, 예정)
  ↓ 테스트 통과하는 코드 구현
```

**문서**:
- [pytest-test-writer](./agents/overview.md#1-pytest-test-writer)
- [Implementation Partner 계획](./agents/implementation-partner-mvp-refined.md)

---

## 📈 프로젝트 상태

### Current Phase: Agent/Skill 문서화 완료

**완료**:
- ✅ Agents 종합 가이드
- ✅ Skills 종합 가이드
- ✅ Agent vs Skills 비교
- ✅ Claude + Codex 전략 토론
- ✅ Implementation Partner MVP 계획 (Codex 피드백 반영)

**다음 단계**:
- [ ] Implementation Partner Agent 프로토타입 구현
- [ ] Task contract JSON schema 정의
- [ ] Guardrails specification 작성
- [ ] End-to-end validation

---

## 🎯 추천 학습 경로

### 초보자

1. **[Skills 가이드](./skills/overview.md)** 읽기
   - Skills가 무엇인지 이해
   - 현재 25개 skills 탐색
   - "What skills are available?" 물어보기

2. **[Agents 가이드](./agents/overview.md)** 읽기
   - Agents가 무엇인지 이해
   - 현재 3개 agents 분석
   - Agent vs Skills 차이점 파악

3. **실습**
   - 기존 Skill 사용해보기 (자동 활성화)
   - 기존 Agent 호출해보기 (Task tool)

### 중급자

1. **[Agent 전략 토론](./agents/codex-debate-agent-strategy.md)** 읽기
   - Claude + Codex 협업 분석
   - 5개 신규 agent 제안
   - 3개 기존 agent 개선안

2. **[Implementation Partner MVP](./agents/implementation-partner-mvp-refined.md)** 읽기
   - TDD 루프 자동화 계획
   - Guardrails 설계
   - 프로토타입 가이드

3. **실습**
   - skill-creator로 새 Skill 만들기
   - 기존 agent 커스터마이즈

### 고급자

1. **Agent/Skill 개발**
   - 새로운 Agent 설계 및 구현
   - 복잡한 Skill (scripts, references, assets)
   - Agent + Skill 파이프라인 구축

2. **기여**
   - Implementation Partner Agent 프로토타입
   - Static Analysis Agent
   - Knowledge Steward Agent

---

## 🔗 관련 리소스

### 외부 문서
- [Claude Code 공식 문서](https://docs.claude.com/claude-code)
- [MCP 프로토콜](https://modelcontextprotocol.io/)
- [LangGraph](https://langchain-ai.github.io/langgraph/)

### GitHub
- [Vibe-Coding-Setting](https://github.com/swseo92/Vibe-Coding-Setting-swseo)
- [Speckit](https://github.com/spec-kit/spec-kit)

---

## 📝 문서 작성 원칙

1. **명확성**: 기술 용어 설명 포함
2. **예시**: 구체적인 사용 예시 제공
3. **구조화**: 목차, 표, 다이어그램 활용
4. **최신성**: 변경사항 즉시 반영
5. **접근성**: 초보자부터 고급자까지

---

## 💡 기여 가이드

### 새 문서 추가

1. 적절한 폴더에 `.md` 파일 생성
2. 이 README에 링크 추가
3. 관련 문서에 상호 참조 추가
4. 커밋 및 푸시

### 기존 문서 수정

1. 문서 수정
2. "마지막 업데이트" 날짜 갱신
3. 변경사항이 크면 히스토리 추가
4. 커밋 및 푸시

---

**마지막 업데이트**: 2025-11-01
**관리자**: swseo
**문서 수**: 30+ (Agents 4, Skills 2, 기타 24+)
