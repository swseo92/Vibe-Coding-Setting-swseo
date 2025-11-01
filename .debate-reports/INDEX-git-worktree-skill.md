# Git Worktree Skill 프로젝트 - 마스터 인덱스

**프로젝트 기간**: 2025-11-01
**참여자**: Claude Code + OpenAI Codex (GPT-5-Codex)
**방법론**: Codex Collaborative Solver V3.0 (4라운드 토론)
**최종 결과물**: `.claude/skills/git-worktree-manager/`

---

## 프로젝트 요약

### 목표
Git worktree를 이용한 병렬 개발 워크플로우를 관리하는 Claude Code skill 개발

### 핵심 결정사항

| 주제 | 결정 | 근거 |
|------|------|------|
| **아키텍처** | Multi-Project 방식 | Windows symlink 문제, PyCharm VCS 충돌 방지 |
| **환경관리** | venv (uv 아님) | Windows 안정성 우선 |
| **데이터베이스** | 독립 복사본 기본 | SQLite locking 방지 |
| **경로 전략** | 짧은 경로 (C:\ws\) | Windows 260자 제한 대응 |
| **Merge 전략** | Rebase-first + FF | 선형 히스토리 유지 |
| **충돌 해결** | git rerere + PyCharm | AI 자동 해결 거부 (ROI 부족) |

### 주요 지표

- **토론 라운드**: 4회
- **토론 문서**: 9개
- **최종 가이드**: 1개 (70,000+ 토큰)
- **PowerShell 스크립트**: 6개 설계 완료
- **Reference 문서**: 5개 계획
- **총 작업 시간**: 약 8시간 (토론 + 설계)

---

## 프로젝트 구조

### 최종 결과물

```
.claude/skills/git-worktree-manager/
├── skill.md                    ✅ 완료 (348줄)
├── IMPLEMENTATION-GUIDE.md     ✅ 완료 (이 프로젝트 실행 가이드)
├── scripts/                    ⏳ 대기 (Phase 1)
│   ├── worktree-create.ps1
│   ├── cleanup-worktree.ps1
│   ├── merge-simple.ps1
│   ├── hotfix-merge.ps1
│   ├── update-all-worktrees.ps1
│   └── conflict-helper.ps1
└── references/                 ⏳ 대기 (Phase 2)
    ├── architecture-decision.md
    ├── merge-strategy.md
    ├── conflict-resolution.md
    ├── pycharm-integration.md
    └── best-practices.md
```

### 토론 기록 (`.debate-reports/`)

```
.debate-reports/
├── INDEX-git-worktree-skill.md              ← 이 문서
│
├── 2025-11-01-FINAL-git-worktree-complete-guide.md  ✅ 종합 가이드
│
├── Round 1: 아키텍처 설계
│   ├── worktree-context.md                  (사용자 요구사항)
│   ├── codex-prompt-round1.md               (Claude의 3가지 제안)
│   └── codex-round1-response.md             (Codex의 critique)
│
├── Round 2: 아키텍처 강화
│   ├── codex-prompt-round2-stress-test.md   (Stress test 시나리오)
│   └── codex-round2-response.md             (Conditional Pass)
│
├── Round 3: Merge 전략
│   ├── merge-context.md                     (4가지 시나리오)
│   ├── codex-prompt-round3-merge.md         (5가지 전략 제안)
│   └── codex-round3-merge-response.md       (Simplify Significantly)
│
└── Round 4: AI 충돌 해결
    ├── ai-conflict-resolution-context.md    (4가지 conflict 유형)
    ├── codex-prompt-round4-ai-conflict.md   (AI 자동 해결 제안)
    └── codex-round4-ai-conflict-response.md (보수적 접근 권고)
```

---

## 빠른 네비게이션

### 🎯 지금 바로 작업 시작하기

```bash
# 1. 구현 가이드 읽기
Read: .claude/skills/git-worktree-manager/IMPLEMENTATION-GUIDE.md

# 2. 현재 진행 상황 확인
# → "남은 작업" 섹션 체크박스 확인

# 3. Phase 1 시작 (스크립트 추출)
Read: .debate-reports/2025-11-01-FINAL-git-worktree-complete-guide.md
```

### 📚 토론 내용 복습하기

**Round 1-2: 아키텍처가 궁금하다면**
```bash
Read: .debate-reports/codex-round1-response.md
# Codex가 왜 Multi-Project를 추천했는지 확인
```

**Round 3: Merge 전략이 궁금하다면**
```bash
Read: .debate-reports/codex-round3-merge-response.md
# 왜 Rebase-first를 선택했는지 확인
```

**Round 4: AI 충돌 해결을 왜 안 하는지 궁금하다면**
```bash
Read: .debate-reports/codex-round4-ai-conflict-response.md
# ROI 분석 (3-6년 breakeven) 확인
```

### 🔧 스크립트 코드 찾기

모든 스크립트는 다음 파일에 있음:

```bash
Read: .debate-reports/2025-11-01-FINAL-git-worktree-complete-guide.md

# 특정 스크립트 검색
Grep: pattern="# merge-simple.ps1" -A 150
Grep: pattern="# worktree-create.ps1" -A 200
```

### 📖 Skill 사용법 보기

```bash
Read: .claude/skills/git-worktree-manager/skill.md
# "When to Use This Skill" 섹션 참고
```

---

## 토론 라운드별 상세 내용

### Round 1: Worktree 아키텍처 설계

**날짜**: 2025-11-01
**주제**: 독립적인 worktree 환경 구성 방법

**Claude의 제안**:
1. **Approach A: Multi-Project** - 각 worktree = 독립 PyCharm 프로젝트
2. **Approach B: Attached Directory** - 1개 PyCharm 프로젝트, 여러 worktree
3. **Approach C: Hybrid Symlink** - Symlink로 설정 공유

**Codex의 판정**:
- **Accept with Modifications** (Approach A)
- **Top Issues**:
  - Approach C의 Windows symlink 위험성
  - uv의 Windows 성숙도 문제
  - .idea 자동 생성의 취약성

**핵심 결정**:
- ✅ Multi-Project 방식 채택
- ✅ venv 사용 (uv 대신)
- ✅ 독립 DB 복사본 기본
- ✅ 짧은 경로 전략 (C:\ws\)

**파일**:
- Context: `worktree-context.md`
- Prompt: `codex-prompt-round1.md`
- Response: `codex-round1-response.md`

---

### Round 2: 아키텍처 Stress Test

**날짜**: 2025-11-01
**주제**: Round 1 결정사항의 실전 검증

**Stress Test 시나리오**:
1. PowerShell 스크립트 중간에 실패하면?
2. DB 동시 접근 시 locking 발생하면?
3. PyCharm interpreter 꼬이면?
4. Windows 경로 길이 초과하면?
5. Git hooks 충돌하면?

**Codex의 판정**:
- **Conditional Pass**
- **Critical Failures** 식별됨

**개선 사항**:
- ✅ Set-StrictMode, try-catch-finally 추가
- ✅ DB file lock 감지 및 retry
- ✅ 트랜잭션 rollback 메커니즘
- ✅ Long path 활성화 검증
- ✅ core.hooksPath 사용 (symlink 대신)

**파일**:
- Prompt: `codex-prompt-round2-stress-test.md`
- Response: `codex-round2-response.md`

---

### Round 3: Commit Merge 전략

**날짜**: 2025-11-01
**주제**: Feature worktree를 main으로 통합하는 merge 전략

**Claude의 제안** (5가지):
1. Squash-by-default
2. Rebase + Squash
3. Fast-Forward Only
4. No-Merge (Tag만)
5. Periodic Rebase

**Codex의 판정**:
- **Simplify Significantly**
- 5개 전략 → 3개 시나리오로 단순화

**최종 전략**:
1. **Feature Merge**: Rebase onto main → FF merge (기본값)
2. **Hotfix**: Rebase → FF 시도 → 실패 시 merge commit
3. **Experiment**: Worktree에 격리, tag로 snapshot

**핵심 원칙**:
- ✅ Squash 하지 않음 (히스토리 보존)
- ✅ Rebase-first (충돌 조기 발견)
- ✅ FF-only (선형 히스토리)
- ✅ Dry-run 지원

**스크립트**:
- `merge-simple.ps1` (feature merge)
- `hotfix-merge.ps1` (emergency)
- `update-all-worktrees.ps1` (sync)

**파일**:
- Context: `merge-context.md`
- Prompt: `codex-prompt-round3-merge.md`
- Response: `codex-round3-merge-response.md`

---

### Round 4: AI-Assisted Conflict Resolution

**날짜**: 2025-11-01
**주제**: Merge 충돌을 AI가 자동으로 해결할 수 있는가?

**사용자 요청**:
> "merge시에 conflict 같은걸 agent가 판단하고 수정해서 merge하는건 어때?"

**Claude의 제안**:
- 4가지 분류 (Trivial, Low-Risk, Medium-Risk, High-Risk)
- Confidence threshold로 자동/수동 결정
- AI suggestion + Test validation
- ~200줄 PowerShell 스크립트 (`merge-ai.ps1`)

**Codex의 판정**:
- **Simplify Significantly**
- AI 자동 해결 **거부**

**거부 이유 (ROI 분석)**:
```
수동 해결 시간: 2-5분/conflict
연간 예상: 50-100 conflicts × 3분 = 2.5-5시간
스크립트 개발: 17-34시간 (첫 해)
유지보수: 2-4시간/년
→ Breakeven: 340-680 conflicts = 3-6년
```

**최종 권고**:
1. **Tier 1: git rerere** (자동, 100% 안전)
2. **Tier 2: PyCharm Merge Tool** (GUI, 2-5분)
3. **Tier 3: AI Suggestion** (선택적, 수동 적용만)

**핵심 통찰**:
- ❌ AI confidence score 신뢰 불가
- ❌ Test 통과 ≠ 올바른 해결
- ❌ 사용자 피로 (프롬프트 과다)
- ✅ 단순한 해결이 더 실용적

**파일**:
- Context: `ai-conflict-resolution-context.md`
- Prompt: `codex-prompt-round4-ai-conflict.md`
- Response: `codex-round4-ai-conflict-response.md`

---

## 주요 인사이트

### 설계 원칙

1. **Safety First**
   - 모든 작업에 rollback 메커니즘
   - Dry-run 모드 지원
   - Test-driven validation

2. **Pragmatic ROI**
   - 실용적인 자동화만 채택
   - 복잡도 vs 이득 엄격히 평가
   - AI 자동화는 ROI 분석 후 결정

3. **Windows-Optimized**
   - Symlink 최소화 (Developer Mode 회피)
   - 경로 길이 문제 사전 해결
   - venv 사용 (uv보다 안정적)

4. **Test-Driven**
   - 모든 merge 후 pytest 실행
   - Smoke test (worktree 생성 시)
   - Pre-merge validation

### Codex의 핵심 피드백

**Round 1**:
> "Approach A (Multi-Project) is the only path that doesn't rely on fragile assumptions about symlinks, VCS root detection, or homogeneous .idea configs."

**Round 2**:
> "Script failures, DB locking, and interpreter mix-ups are the top failure modes. Add Set-StrictMode, try-catch-finally, and file-lock detection."

**Round 3**:
> "Five strategies is overkill. Three scenarios (feature, hotfix, experiment) cover everything. Default to rebase + FF-only."

**Round 4**:
> "Solo developer sees few substantial conflicts; manual resolution remains cheaper than maintaining the script. Building, testing, and debugging the AI tooling likely eclipses time saved over many months."

---

## 다음 단계

### 즉시 실행 가능

✅ **설계 완료**
- skill.md 작성됨
- 구현 가이드 작성됨
- 모든 스크립트 설계 완료

⏳ **구현 대기 중**
- Phase 1: PowerShell 스크립트 추출 (1-2시간)
- Phase 2: Reference 문서 작성 (2-3시간)
- Phase 3: 검증 (30분)
- Phase 4: 실전 테스트 (1시간)

### 시작 방법

```bash
# 1. 구현 가이드 읽기
Read: .claude/skills/git-worktree-manager/IMPLEMENTATION-GUIDE.md

# 2. Phase 1 시작
# → "Phase 1: PowerShell Scripts 추출" 섹션 따라가기
```

---

## 통계

### 토론 통계

- **총 라운드**: 4회
- **토론 시간**: 약 6시간
- **설계 시간**: 약 2시간
- **총 문서**: 10개 (토론 9개 + 종합 가이드 1개)
- **총 토큰**: 약 100,000+ 토큰

### 코드 통계 (설계 완료)

- **PowerShell 스크립트**: 6개
  - worktree-create.ps1: ~200줄
  - cleanup-worktree.ps1: ~100줄
  - merge-simple.ps1: ~150줄
  - hotfix-merge.ps1: ~100줄
  - update-all-worktrees.ps1: ~80줄
  - conflict-helper.ps1: ~50줄
- **총 코드**: 약 680줄

### 문서 통계

- **skill.md**: 348줄
- **IMPLEMENTATION-GUIDE.md**: 800+줄
- **종합 가이드**: 70,000+ 토큰
- **Reference 문서** (계획): 5개 × 200줄 = 1,000줄

---

## 참고 자료

### 외부 링크

- [Git Worktree 공식 문서](https://git-scm.com/docs/git-worktree)
- [Git Rerere 가이드](https://git-scm.com/docs/git-rerere)
- [PyCharm 프로젝트 관리](https://www.jetbrains.com/help/pycharm/managing-projects.html)

### 내부 문서

- **Skill Creator**: `.claude/skills/skill-creator/skill.md`
- **Codex Solver**: `.claude/skills/codex-collaborative-solver/skill.md`
- **CLAUDE.md**: 프로젝트 루트의 전체 가이드

---

## 변경 이력

### 2025-11-01

- ✅ Round 1-4 토론 완료
- ✅ 종합 가이드 작성 (`2025-11-01-FINAL-git-worktree-complete-guide.md`)
- ✅ Skill 설계 완료 (`skill.md`)
- ✅ 구현 가이드 작성 (`IMPLEMENTATION-GUIDE.md`)
- ✅ 마스터 인덱스 작성 (이 문서)

---

**프로젝트 상태**: 설계 완료, 구현 대기 중
**예상 완료일**: TBD (사용자 결정)
**신뢰도**: High (85-90%)
**마지막 업데이트**: 2025-11-01
