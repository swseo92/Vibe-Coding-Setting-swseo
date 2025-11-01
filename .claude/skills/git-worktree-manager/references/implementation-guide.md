# Git Worktree Manager Skill - 구현 가이드

**작성일**: 2025-11-01
**상태**: 설계 완료, 구현 대기 중
**예상 완료 시간**: 4-6시간 (전체) / 1-2시간 (최소 동작 버전)

---

## 프로젝트 개요

### 무엇을 만드는가?

Git worktree를 이용한 병렬 개발 워크플로우를 관리하는 Claude Code skill.

**핵심 기능**:
- 독립적인 개발 환경(worktree) 자동 생성
- Rebase-first merge 전략으로 안전한 통합
- PyCharm + Windows 환경 최적화
- 충돌 해결 가이드 제공 (AI suggestion 선택적)

**대상 사용자**: Python 프로젝트를 다루는 솔로 개발자 (Windows + PyCharm)

### 왜 필요한가?

1. **병렬 작업**: 여러 기능을 동시에 개발 (main 브랜치 방해 없이)
2. **실험 안전성**: 실험적 코드를 격리된 환경에서 테스트
3. **긴급 핫픽스**: 기능 개발 중 긴급 배포 가능
4. **독립 환경**: 각 worktree마다 독립적인 venv, DB, env 설정

### 설계 철학 (Codex와의 4라운드 토론 결과)

1. **Safety First** - 항상 롤백 가능, 드라이런 지원
2. **Pragmatic ROI** - 실용적인 자동화만 (AI 자동 해결 제외)
3. **Windows-Optimized** - 경로 길이, symlink 문제 해결
4. **Test-Driven** - 모든 merge 후 테스트 검증

---

## 현재 상태 (체크리스트)

### ✅ 완료된 작업

- [x] **Round 1-2: 아키텍처 설계** (Multi-Project 방식 확정)
  - 독립적 .venv, .env.local, DB 구조
  - Windows 최적화 (짧은 경로, venv 사용)
  - Minimal symlink 전략
- [x] **Round 3: Merge 전략** (Rebase-first workflow 확정)
  - 5개 전략 → 3개 시나리오로 단순화
  - merge-simple.ps1, hotfix-merge.ps1 설계
- [x] **Round 4: AI 충돌 해결** (보수적 접근 확정)
  - AI 자동 해결 거부 (ROI 부족)
  - git rerere + PyCharm merge tool 권장
  - AI suggestion은 선택적 (수동 적용만)
- [x] **Skill 설계** (skill-creator 프로세스 완료)
  - 사용 시나리오 5개 정의
  - Reusable contents 계획 (6 scripts + 5 references)
  - skill.md 작성 완료

**완료 파일**:
- `.claude/skills/git-worktree-manager/skill.md` (348줄)
- `.debate-reports/2025-11-01-FINAL-git-worktree-complete-guide.md` (종합 가이드)
- 토론 기록 9개 파일

### ❌ 남은 작업

- [ ] **Phase 1: PowerShell Scripts 추출** (예상 1-2시간)
  - [ ] worktree-create.ps1
  - [ ] cleanup-worktree.ps1
  - [ ] merge-simple.ps1
  - [ ] hotfix-merge.ps1
  - [ ] update-all-worktrees.ps1
  - [ ] conflict-helper.ps1

- [ ] **Phase 2: Reference Docs 작성** (예상 2-3시간)
  - [ ] architecture-decision.md
  - [ ] merge-strategy.md
  - [ ] conflict-resolution.md
  - [ ] pycharm-integration.md
  - [ ] best-practices.md

- [ ] **Phase 3: 검증 및 패키징** (예상 30분)
  - [ ] YAML frontmatter 검증
  - [ ] 파일 구조 확인
  - [ ] (선택) 압축 패키징

- [ ] **Phase 4: 실전 테스트** (예상 1시간)
  - [ ] Skill 활성화 테스트
  - [ ] 트리거 문구 테스트
  - [ ] 전체 워크플로우 실행

---

## 구현 방법 (단계별 가이드)

### Phase 1: PowerShell Scripts 추출

#### 1.1 디렉토리 생성

```bash
mkdir -p .claude/skills/git-worktree-manager/scripts
```

#### 1.2 스크립트 추출 위치

각 스크립트는 다음 토론 파일에서 추출:

| 스크립트 | 소스 파일 | 검색 키워드 |
|---------|----------|-----------|
| `worktree-create.ps1` | `.debate-reports/2025-11-01-git-worktree-pycharm-vibe-coding.md` | `# worktree-create.ps1` |
| `cleanup-worktree.ps1` | 동일 | `# cleanup-worktree.ps1` |
| `merge-simple.ps1` | `.debate-reports/2025-11-01-FINAL-git-worktree-complete-guide.md` | `# merge-simple.ps1` |
| `hotfix-merge.ps1` | 동일 | `# hotfix-merge.ps1` |
| `update-all-worktrees.ps1` | 동일 | `# update-all-worktrees.ps1` |
| `conflict-helper.ps1` | 동일 | `# conflict-helper.ps1` |

#### 1.3 추출 절차

각 스크립트마다:

1. **소스 파일 열기**
   ```bash
   # Read를 사용하여 파일 내용 확인
   ```

2. **스크립트 블록 찾기**
   - Grep으로 `# worktree-create.ps1` 등 검색
   - 코드 블록 시작(```)부터 끝(```)까지 복사

3. **파일 생성**
   ```bash
   # Write tool로 scripts/ 폴더에 저장
   ```

4. **검증**
   - PowerShell 문법 오류 확인
   - Set-StrictMode, try-catch-finally 구조 확인

#### 1.4 빠른 실행 명령어

```bash
# 1. 소스 파일 읽기
Read: .debate-reports/2025-11-01-git-worktree-pycharm-vibe-coding.md

# 2. worktree-create.ps1 검색 및 추출
Grep: pattern="# worktree-create.ps1" -A 200

# 3. 파일 생성
Write: .claude/skills/git-worktree-manager/scripts/worktree-create.ps1

# 반복...
```

### Phase 2: Reference Docs 작성

#### 2.1 디렉토리 생성

```bash
mkdir -p .claude/skills/git-worktree-manager/references
```

#### 2.2 문서별 작성 가이드

**architecture-decision.md** (Rounds 1-2 요약)
- 소스: `.debate-reports/codex-round1-response.md`, `codex-round2-response.md`
- 포함 내용:
  - 3가지 접근법 비교 (Multi-Project, Attached, Hybrid)
  - Windows 최적화 결정 (venv, 짧은 경로, minimal symlink)
  - Codex의 critique 핵심 포인트
  - 디렉토리 구조 예시

**merge-strategy.md** (Round 3 요약)
- 소스: `.debate-reports/codex-round3-merge-response.md`
- 포함 내용:
  - 3가지 시나리오 (feature, hotfix, experiment)
  - Rebase-first workflow 설명
  - Squash vs FF 비교
  - Pre-merge validation 체크리스트

**conflict-resolution.md** (Round 4 요약)
- 소스: `.debate-reports/codex-round4-ai-conflict-response.md`
- 포함 내용:
  - Tier 1: git rerere (권장)
  - Tier 2: PyCharm merge tool
  - Tier 3: AI suggestion (선택적)
  - ROI 분석 (3-6년 breakeven)
  - 왜 AI 자동 해결을 하지 않는가

**pycharm-integration.md**
- 소스: `.debate-reports/2025-11-01-FINAL-git-worktree-complete-guide.md` 섹션 추출
- 포함 내용:
  - 프로젝트 열기 방법 (File > Open)
  - Python interpreter 설정 (.venv/Scripts/python.exe)
  - EnvFile 플러그인 설치
  - VCS root 설정
  - 일반적인 PyCharm 이슈 해결

**best-practices.md**
- 소스: skill.md의 "Best Practices" 섹션 확장
- 포함 내용:
  - Do's ✅ (상세 설명)
  - Don'ts ❌ (이유와 대안)
  - Performance tips
  - Security considerations

#### 2.3 작성 템플릿

각 reference 문서는 다음 구조 사용:

```markdown
# [문서 제목]

**작성 기준**: Codex vs Claude 토론 Round X
**마지막 업데이트**: 2025-11-01

## 개요

[간단한 요약 - 2-3 문장]

## [주요 섹션 1]

### [세부 주제]

[내용]

**예시:**
```
코드 또는 명령어 예시
```

## 참고 자료

- 토론 파일: `.debate-reports/...`
- 관련 스크립트: `scripts/...`
```

### Phase 3: 검증 및 패키징

#### 3.1 YAML Frontmatter 검증

skill.md 상단 확인:
```yaml
---
name: git-worktree-manager
description: [한 줄 설명]
---
```

검증 항목:
- [ ] `name`이 kebab-case인가?
- [ ] `description`이 150자 이하인가?
- [ ] YAML 문법 오류 없는가?

#### 3.2 파일 구조 확인

```
.claude/skills/git-worktree-manager/
├── skill.md              ✅ 존재
├── IMPLEMENTATION-GUIDE.md  ✅ 이 문서
├── scripts/
│   ├── worktree-create.ps1
│   ├── cleanup-worktree.ps1
│   ├── merge-simple.ps1
│   ├── hotfix-merge.ps1
│   ├── update-all-worktrees.ps1
│   └── conflict-helper.ps1
└── references/
    ├── architecture-decision.md
    ├── merge-strategy.md
    ├── conflict-resolution.md
    ├── pycharm-integration.md
    └── best-practices.md
```

#### 3.3 (선택) 압축 패키징

```bash
cd .claude/skills
zip -r git-worktree-manager.zip git-worktree-manager/
```

### Phase 4: 실전 테스트

#### 4.1 Skill 활성화 테스트

1. Claude Code 재시작
2. 새 세션에서 입력: "worktree 만들어줘"
3. Skill이 자동으로 로드되는지 확인

#### 4.2 트리거 문구 테스트

다음 문구들이 skill을 활성화하는지 테스트:

- "새 기능 개발 시작해야 하는데 worktree 만들어줘"
- "feature-auth 작업 끝났어. main으로 merge해줘"
- "hotfix 긴급하게 배포해야 해"
- "conflict 발생했어. 어떻게 해결하지?"
- "worktree들 정리하고 싶어"

#### 4.3 전체 워크플로우 실행

실제 프로젝트에서:

1. **Create**: `worktree-create.ps1 -BranchName test-feature`
2. **Develop**: PyCharm에서 코드 작성
3. **Merge**: `merge-simple.ps1 -FeatureBranch test-feature -DryRun`
4. **Merge**: `merge-simple.ps1 -FeatureBranch test-feature`
5. **Cleanup**: `cleanup-worktree.ps1 -BranchName test-feature`

각 단계에서:
- 오류 없이 실행되는가?
- 예상대로 동작하는가?
- 롤백이 필요한 경우 정상 작동하는가?

---

## 우선순위 전략

### Option A: 완전 구현 (추천: 주말 프로젝트)

**시간**: 4-6시간
**순서**: Phase 1 → 2 → 3 → 4
**결과**: Production-ready skill

**장점**:
- 완전한 문서화
- 즉시 사용 가능
- 유지보수 용이

**단점**:
- 시간 투자 큼

### Option B: 빠른 검증 (추천: 즉시 사용)

**시간**: 1-2시간
**순서**: Phase 1 → 4 (스크립트만 추출, 바로 테스트)
**결과**: 기본 동작 가능, 문서는 나중에

**장점**:
- 빠른 피드백
- 실사용하며 개선

**단점**:
- 문서 부족

**나중에 추가**:
- Phase 2는 필요할 때마다 점진적으로 작성
- Phase 3는 모든 완료 후

### Option C: 점진적 구현 (추천: 여유 있을 때)

**Day 1 (1-2시간)**: Phase 1
- 스크립트 6개 추출
- 기본 사용 가능

**Day 2-3 (2-3시간)**: Phase 2
- 중요한 reference 2-3개 작성
- architecture-decision.md (필수)
- merge-strategy.md (필수)
- conflict-resolution.md (선택)

**Day 4 (1시간)**: Phase 3 + 4
- 검증 및 실전 테스트
- 피드백 반영

---

## 참고 파일 링크

### 핵심 파일

**Skill 정의**:
- `.claude/skills/git-worktree-manager/skill.md` (348줄) ← 현재 파일

**종합 가이드**:
- `.debate-reports/2025-11-01-FINAL-git-worktree-complete-guide.md` (모든 라운드 통합)

### 토론 기록 (라운드별)

**Round 1: 아키텍처**
- `.debate-reports/worktree-context.md` (사용자 요구사항)
- `.debate-reports/codex-prompt-round1.md` (Claude의 제안)
- `.debate-reports/codex-round1-response.md` (Codex의 critique)

**Round 2: 아키텍처 강화**
- `.debate-reports/codex-prompt-round2-stress-test.md`
- `.debate-reports/codex-round2-response.md` (Conditional Pass)

**Round 3: Merge 전략**
- `.debate-reports/merge-context.md`
- `.debate-reports/codex-prompt-round3-merge.md`
- `.debate-reports/codex-round3-merge-response.md` (Simplify Significantly)

**Round 4: AI 충돌 해결**
- `.debate-reports/ai-conflict-resolution-context.md`
- `.debate-reports/codex-prompt-round4-ai-conflict.md`
- `.debate-reports/codex-round4-ai-conflict-response.md` (보수적 접근)

### Skill Creator 참고

- `.claude/skills/skill-creator/skill.md` (skill 작성 프로세스)
- `.claude/skills/codex-collaborative-solver/skill.md` (토론 프레임워크)

---

## 빠른 시작 (최소 동작 버전)

메모리가 없어도 이어서 작업하려면:

### 1단계: 이 문서 열기

```bash
claude
# 세션 시작 후
Read: .claude/skills/git-worktree-manager/IMPLEMENTATION-GUIDE.md
```

### 2단계: Phase 1 실행

```bash
# 스크립트 추출 시작
Read: .debate-reports/2025-11-01-FINAL-git-worktree-complete-guide.md

# merge-simple.ps1 찾기
Grep: pattern="# merge-simple.ps1" -A 150

# 파일 생성
Write: .claude/skills/git-worktree-manager/scripts/merge-simple.ps1
# (Grep 결과에서 코드 블록만 복사)

# 나머지 5개 스크립트 반복...
```

### 3단계: 검증

```bash
# 파일 구조 확인
ls .claude/skills/git-worktree-manager/scripts/
# 6개 파일 있어야 함

# skill.md 확인
Read: .claude/skills/git-worktree-manager/skill.md
# YAML frontmatter 정상인지 확인
```

### 4단계: 테스트

```bash
# Claude Code 재시작
# 새 세션에서:
"worktree 만들어줘"
# → skill이 자동 로드되면 성공
```

---

## 트러블슈팅

### 문제: Skill이 트리거되지 않음

**원인**:
- skill.md의 description이 너무 짧음
- YAML frontmatter 오류

**해결**:
```yaml
# skill.md 상단 확인
---
name: git-worktree-manager
description: Manage parallel development workflows using git worktree for Python projects in PyCharm on Windows. Use this skill when users need to create independent development environments for multiple features, handle merge conflicts, or manage worktree lifecycle (create/merge/cleanup). Optimized for solo developers working on Python projects with pytest test suites.
---
```

### 문제: 스크립트 추출 시 코드 블록이 깨짐

**원인**:
- 마크다운 코드 블록(```)을 포함해서 복사

**해결**:
- 코드 블록 시작(```)과 끝(```) 제외하고 복사
- PowerShell 주석(`#`)으로 시작하는 첫 줄부터 복사

### 문제: Phase 1 완료 후 어디서부터 시작할지 모름

**해결**:
1. 이 문서의 "남은 작업" 섹션 확인
2. 체크박스에서 다음 [ ] 항목 찾기
3. "구현 방법" 섹션에서 해당 Phase 가이드 읽기

---

## 마일스톤

### Milestone 1: 기본 동작 (최소 기능)
- [ ] Phase 1 완료 (스크립트 6개)
- [ ] Skill 트리거 테스트 성공
- [ ] 1개 worktree 생성/삭제 성공

**완료 시**: 실사용 가능, 문서는 부족

### Milestone 2: 문서화 완료 (권장)
- [ ] Phase 2 완료 (references 5개)
- [ ] 모든 워크플로우 가이드 완성

**완료 시**: 타인과 공유 가능

### Milestone 3: 프로덕션 준비 (완전)
- [ ] Phase 3 완료 (검증)
- [ ] Phase 4 완료 (실전 테스트)
- [ ] 최소 3개 프로젝트에서 사용 검증

**완료 시**: 안정적 사용, 저장소 공개 가능

---

## 다음 작업

**지금 바로 시작한다면**:

1. **Phase 1 시작** - 스크립트 추출 (1-2시간)
   ```bash
   # 첫 번째 스크립트부터
   Read: .debate-reports/2025-11-01-FINAL-git-worktree-complete-guide.md
   # merge-simple.ps1 검색 및 추출
   ```

**나중에 이어서 작업한다면**:

1. **이 문서 열기**
   ```bash
   Read: .claude/skills/git-worktree-manager/IMPLEMENTATION-GUIDE.md
   ```

2. **"남은 작업" 섹션에서 체크박스 확인**

3. **해당 Phase의 "구현 방법" 따라가기**

---

**작성자**: Claude Code
**기반**: Codex vs Claude 4라운드 토론 (2025-11-01)
**신뢰도**: High (85-90%)
**마지막 업데이트**: 2025-11-01
