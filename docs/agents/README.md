# Claude Code Agents: 문서 인덱스

> **최종 업데이트**: 2025-11-01
> **프로젝트 상태**: Phase 0 (Prototype & Contract Definition)

---

## 문서 목록

### 1. [overview.md](./overview.md) - 종합 가이드
Claude Code Agent 기능의 완전한 이해

**내용**:
- Agent란 무엇인가 (독립 컨텍스트, 전문화, 도구 제어)
- Agent 파일 구조 (YAML frontmatter, 저장 위치)
- Agent 생성/사용 방법
- Best Practices (8가지 핵심 원칙)
- 현재 저장소의 Agent 심층 분석:
  - `pytest-test-writer` - AAA 패턴, parametrized tests
  - `langgraph-node-implementer` - VCR 기반 TDD
  - `meta-tester` - Python subprocess 메타 테스팅
- 고급 활용법 (파이프라인, 병렬 실행, Hook 통합)

**대상 독자**: 초보자 ~ 고급 사용자

---

### 2. [codex-debate-agent-strategy.md](./codex-debate-agent-strategy.md) - 전략 토론
Claude (Anthropic) vs Codex (OpenAI GPT-5) 토론 결과

**내용**:
- **Agent Gaps 분석** (5가지 누락 영역)
  1. 프로덕션 코딩 태스크 부재
  2. 아키텍처/표준 큐레이션 부재
  3. 문서화/DX 자동화 부재
  4. 툴체인 오케스트레이션 부재
  5. 런타임 텔레메트리 피드백 부재

- **신규 Agent 제안** (5개)
  1. ⭐ **Implementation Partner Agent** (최우선)
  2. **Static Analysis & Security Agent**
  3. **Knowledge Steward Agent**
  4. **Observability Agent**
  5. **Release Sherpa Agent**

- **기존 Agent 개선안** (3개)
  - pytest-test-writer: Coverage 텔레메트리, auto-fixture
  - langgraph-node-implementer: Architectural guardrails, VCR → MCP
  - meta-tester: Chaos injection, health scorecards

- **Agent Pipeline Best Practices**
  - Explicit hand-off artifacts (MCP)
  - Gating 메커니즘
  - Orchestrated stages with rollback
  - Conversation snapshots

- **MCP & Skills Integration**
  - File-backed MCP (MVP)
  - FastAPI MCP server (선택적)
  - Skills for repetitive commands
  - Agent skill catalog

- **구현 로드맵** (8주)
  - Phase 1: Implementation Partner MVP (Week 1-2)
  - Phase 2: Static Analysis Agent (Week 3-4)
  - Phase 3: Knowledge Steward (Week 5-6)
  - Phase 4: Full Pipeline Orchestration (Week 7-8)

**대상 독자**: 아키텍트, 기술 리더

---

### 3. [implementation-partner-mvp-refined.md](./implementation-partner-mvp-refined.md) - 수정된 MVP 계획
Codex 피드백 반영하여 REFINE된 Implementation Partner Agent MVP

**내용**:
- **Codex의 핵심 피드백**
  - MVP 스코프에 누락된 Guardrails
  - 타임라인 재평가 (2주 → 3-4주)
  - 주요 리스크 6가지
  - 프로토타입 필수 (Vertical Slice)
  - 최종 추천: REFINE (즉시 시작 말고 다듬기)

- **Phase 0: Prototype & Contract** (NEW! Week 1-2)
  1. **Task Contract Specification**
     - JSON Schema 정의
     - Guardrails 추가 (language, constraints, repo_context)

  2. **Guardrails Specification**
     - Allowed/Forbidden operations
     - Code change constraints
     - Error handling policy
     - Authority boundaries
     - Repo context acquisition

  3. **Prototype Sandbox**
     - Toy project (calculator)
     - Minimal agent implementation (Python script)
     - End-to-end test script
     - RESULTS.md (findings)

  4. **Success Criteria**
     - 7가지 검증 항목
     - Discovery goals (gaps, issues)

- **Phase 1: MVP Implementation** (Week 3-4, adjusted)
  - Preconditions (prototype validated)
  - Production agent file
  - MCP integration
  - pytest-test-writer modification
  - Integration tests

- **Risk Mitigation**
  - Brittle hand-off → Strict JSON schema
  - Unclear authority → Guardrails doc
  - Flaky tests → Retry logic
  - Non-deterministic iteration → Max 3 iterations
  - MCP state drift → Atomic writes
  - Incorrect schema changes → Dry-run + approval

- **Decision Log**
  - 2025-11-01: REFINE Decision
  - Trade-off: +2 weeks for validation, but reduced risk

**대상 독자**: 구현자, 프로젝트 매니저

---

## 프로젝트 상태

### Current Phase: Phase 0 (Prototype & Contract)

**기간**: Week 1-2 (2025-11-01 ~)

**목표**:
- Task contract JSON schema 작성 ✅ (문서화 완료)
- Guardrails specification 작성 ✅ (문서화 완료)
- Prototype sandbox 구현 ⏳ (다음 단계)
- End-to-end validation ⏳ (다음 단계)

**다음 액션**:
1. [ ] `prototypes/implementation-partner-mvp/` 디렉토리 생성
2. [ ] Toy project 구조 생성 (calculator 예시)
3. [ ] Minimal agent prototype 구현 (agent-prototype.py)
4. [ ] End-to-end test 실행 (run-prototype.sh)
5. [ ] Findings 문서화 (RESULTS.md)
6. [ ] Task schema 조정 (발견된 gaps 기반)
7. [ ] Phase 1 진입 여부 결정

---

## 핵심 Insights (Claude + Codex)

### Claude의 강점
- ✅ 포괄적인 리서치 및 문서화
- ✅ 사용자 친화적 설명
- ✅ Best practices 큐레이션
- ✅ 실용적인 예시 제공

### Codex의 강점
- ✅ 아키텍처 리스크 식별
- ✅ 엔지니어링 현실성 검증
- ✅ 구체적인 기술 스펙 제안
- ✅ 프로토타입 우선 접근

### 협업의 가치
단독으로는 불가능했을 결과:
- **Claude 혼자**: 이론적으로 완벽하지만 구현 시 문제 발생 가능
- **Codex 혼자**: 기술적으로 정확하지만 사용자 관점 부족
- **Together**: 이론 + 실무, 품질 + 속도, 야심 + 현실성

---

## 참고 자료

### 내부 문서
- `.claude/agents/pytest-test-writer.md`
- `.claude/agents/langgraph-node-implementer.md`
- `.claude/agents/meta-tester.md`
- `docs/python/testing_guidelines.md`

### 외부 문서
- [Claude Code Sub-agents 공식 문서](https://docs.claude.com/en/docs/claude-code/sub-agents.md)
- [OpenAI Codex CLI](https://developers.openai.com/codex/cli/)

### 관련 스킬
- `codex-integration` - OpenAI Codex CLI 통합

---

## 문서 히스토리

| 날짜 | 문서 | 버전 | 변경 사항 |
|------|------|------|----------|
| 2025-11-01 | overview.md | 1.0 | 초기 리서치 완료 |
| 2025-11-01 | codex-debate-agent-strategy.md | 1.0 | Claude-Codex 토론 결과 |
| 2025-11-01 | implementation-partner-mvp-refined.md | 2.0 | Codex 피드백 반영 (v1 → v2) |
| 2025-11-01 | README.md | 1.0 | 문서 인덱스 생성 |

---

## Quick Links

**시작하기**:
- [Agent 개요](./overview.md#agent란-무엇인가)
- [첫 Agent 만들기](./overview.md#agent-생성-방법)

**전략 이해하기**:
- [Agent Gaps 분석](./codex-debate-agent-strategy.md#codex의-분석-agent-gaps-5가지)
- [신규 Agent 제안](./codex-debate-agent-strategy.md#codex의-제안-5가지-새로운-agent)

**구현 시작하기**:
- [Phase 0 가이드](./implementation-partner-mvp-refined.md#수정된-phase-0-prototype--contract-week-1-2)
- [Prototype Sandbox](./implementation-partner-mvp-refined.md#3-prototype-sandbox)

---

**마지막 업데이트**: 2025-11-01
**관리자**: swseo
**리뷰어**: Claude (Anthropic) + Codex (OpenAI)
