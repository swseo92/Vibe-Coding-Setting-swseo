# Linear Multi-repo 통합 관리 로드맵

**작성일**: 2025-11-09
**최종 결정**: Hybrid approach (단순 시작 + 확장 경로)
**신뢰도**: 80% (High)

---

## 빠른 참조

- **전체 로드맵**: 8주 (Week 1-8)
- **핵심 자동화**: Week 3-4 (Git hook + 큐 시스템)
- **ROI 측정**: Week 5-6 (Before 55분/일 -> After 10분/일)
- **확장 시점**: Phase 2 (프로젝트 5개+), Phase 3 (프로젝트 10개+)

---

## 최종 결정 사항

### Linear 구조
```
Personal Workspace
└── Projects Team (단일 Team)
    ├── Alpha Project
    ├── Beta Project
    ├── Gamma Project
    └── Shared Infrastructure
```

### Labels 체계
```
프로젝트: project:alpha, project:beta, project:gamma
타입: type:feature, type:bug, type:refactor, type:docs
우선순위: priority:urgent, priority:high, priority:normal, priority:low
```

### 자동화 파이프라인
```
Commit
  -> Post-commit hook (< 10ms)
  -> Queue (~/.claude/commit-queue/)
  -> Background worker (항상 실행)
  -> Claude Agent (/auto-commit-process)
  -> Linear Issue 업데이트 (MCP + API)
```

---

## Week 1-2: 기본 워크플로우 + Manual Retro

### 목표
- Linear MCP 익히기
- CLI 중심 워크플로우 확립
- **Daily reflection 습관 형성**
- **Baseline metrics 측정**

### Day 1-5
**오전/오후**: Linear 설정 + 실제 작업
**저녁 (5분)**: Daily reflection
```bash
claude > "오늘 회고 도와줘"
# tmp/daily-notes.md에 기록
```

### Day 5 (금요일)
**오후 (30분)**: Week 1 mini-retro
```bash
claude > "이번 주 회고 도와줘"
# tmp/retro-week1.md 생성
# Baseline metrics 측정: "수동 작업 55분/일"
```

### 완료 기준
- [ ] Linear Team + 3개 Projects 생성
- [ ] MCP로 Issue CRUD 가능
- [ ] Daily reflection 5일 연속
- [ ] Baseline metrics 측정 완료
- [ ] 자동화 우선순위 Top 3 확정

### 예상 Baseline (자동화 전)
- Time overhead: 55분/일
- Commit <-> Issue 수동 연결: 15분/일 (최우선 자동화!)
- Progress tracking: 10분/일
- Linear UI 사용: 30분/일

**상세**: `tmp/week1-retro-addition.md` 참조

---

## Week 3-4: Commit 자동화 (핵심!)

### 목표
- Git commit -> Linear 자동 업데이트
- 비차단 큐 시스템 구축
- Conservative AI matching

### Step 1: 비차단 큐 시스템
```bash
# Background worker 설정
mkdir -p ~/.claude/commit-queue

# Systemd service (Linux)
systemctl --user enable commit-queue-worker.service
systemctl --user start commit-queue-worker.service

# Windows: Task Scheduler로 자동 시작
```

### Step 2: Post-commit hook 설치
```bash
# 각 프로젝트 repo에서
cd ~/projects/alpha
.claude/scripts/install-hooks.sh

# .git/hooks/post-commit 생성됨
# Commit info를 큐에 추가 (< 10ms)
```

### Step 3: /auto-commit-process 커맨드 개발
```
로직:
1. Commit message에서 Issue ID 추출 ([ALPHA-123])
2. ID 없으면 AI matching (confidence > 0.85)
3. Linear Issue 업데이트:
   - Commit link 추가
   - 상태 자동 변경 (fix|close -> Done)
   - Changelog Document append
4. 로그 기록 (tmp/commit-log.jsonl)
```

### Step 4: 테스트
```bash
cd ~/projects/alpha
git commit -m "[ALPHA-123] feat: Add JWT auth"
# 커밋 즉시 완료 (< 10ms)
# 5-10초 후 Linear 확인 -> 자동 업데이트됨!
```

### 완료 기준
- [ ] 모든 repo에 post-commit hook 설치
- [ ] Background worker 실행 중
- [ ] /auto-commit-process 작동 확인
- [ ] 테스트 commit이 Linear에 자동 반영

### 예상 효과
- Commit 연결 시간: 15분/일 -> 0분/일 (100% 감소!)

---

## Week 5-6: Metrics + Retrospective 자동화

### 목표
- Daily metrics 자동 수집
- Weekly retrospective 자동 생성
- **ROI 측정 (Before vs After)**

### Daily metrics (Cron: 매일 9 AM)
```bash
# .claude/scripts/daily-metrics.sh
# Git stats + Linear data -> tmp/metrics-YYYY-MM-DD.md

# 사용자 확인:
claude > "/metrics"
```

### Weekly retro (Cron: 금요일 5 PM)
```bash
# .claude/scripts/weekly-retro.sh
# Claude Agent 실행 -> tmp/retro-YYYY-MM-DD.md

# 자동으로 action items를 Linear Issues로 생성
```

### /retrospective 커맨드
```
자동 분석:
1. Issues completed this week (Linear MCP)
2. Git metrics (commits, LOC, active hours)
3. Patterns (best time, context switching)
4. Action items (3-5개 자동 생성)
```

### 완료 기준
- [ ] Daily metrics 자동 수집
- [ ] /metrics 커맨드로 대시보드 확인
- [ ] Weekly retro 자동 실행
- [ ] Action items 자동 생성 확인

### ROI 측정
```
Week 1 (Baseline):
- Time overhead: 55분/일
- Manual tasks: 매일 반복

Week 6 (Automated):
- Time overhead: 10분/일 (-80%)
- Manual tasks: 거의 없음

절약: 45분/일 = 3.75시간/주 = 15시간/월
```

---

## Week 7-8: Refinement

### 목표
- AI matching 정확도 튜닝
- Metrics rotation 자동화
- Phase 2 도입 여부 결정

### AI matching 튜닝
```bash
# /review-unmatched-commits 커맨드 개발
# 매칭 실패한 commits 검토
# Threshold 조정 (0.85 -> 0.80 or 0.90)
```

### Metrics rotation
```bash
# daily-metrics.sh 수정
# - 날짜별 파일 생성 (metrics-YYYY-MM-DD.md)
# - 최근 7일만 유지
# - 주간 summary를 Linear Document에 푸시
```

### 완료 기준
- [ ] AI matching 정확도 80% 이상
- [ ] Unmatched commits 주당 10개 미만
- [ ] Metrics rotation 자동 작동
- [ ] Phase 2 도입 여부 결정

---

## 구현 우선순위

```
High Impact, Low Effort (즉시):
1. Linear MCP 워크플로우 (Week 1-2)
2. Git hook + 큐 시스템 (Week 3-4)

High Impact, Medium Effort (우선):
3. /auto-commit-process 커맨드 (Week 3-4)
4. Daily metrics 수집 (Week 5)

Medium Impact (중요):
5. /retrospective 자동화 (Week 6)
6. AI matching 튜닝 (Week 7)

Low Priority (나중에):
7. JSONL 구조화 (Phase 2)
8. DuckDB 도입 (Phase 2-3)
9. Orchestrator (Phase 3)
```

---

## UI-Free Daily Workflow (목표 상태)

### 아침 (9 AM)
```bash
# Cron이 자동으로 metrics 업데이트
# TTS 알림: "Metrics 업데이트 완료"

claude
> "/metrics"
# 출력: 어제 4 issues 완료, 오늘 5 issues 계획

> "오늘 할 일 보여줘"
# 출력: In Progress 3개 + 우선순위
```

### 작업 중
```bash
git commit -m "[ALPHA-123] feat: Add password hashing"
# Post-commit hook 자동 실행 (< 10ms)
# 5초 후: Linear Issue 자동 업데이트
```

### 저녁
```bash
> "오늘 뭐 했지?"
# 출력: 12 commits, 4 issues closed

# Week 1-2만: Daily reflection (수동)
> "오늘 회고 도와줘"
```

### 금요일
```bash
# Cron이 자동으로 회고 실행
# TTS 알림: "주간 회고 완료!"

> "이번 주 회고 보여줘"
# 출력: 18 issues 완료, action items 3개 생성
```

---

## Phase 2 도입 시점 (프로젝트 5-10개)

### 트리거
- 프로젝트 수 5개 초과
- Metrics 쿼리 느려짐
- Cross-repo 분석 필요

### 변경사항
1. **JSONL 로그 추가** (구조화된 데이터)
2. **Lightweight supervisor** (중앙 감시)
3. **DuckDB 고려** (복잡한 쿼리 필요 시)

---

## Phase 3 도입 시점 (프로젝트 10개+, 팀 협업)

### 트리거
- 프로젝트 수 10개 초과
- 팀 협업 시작
- Portfolio-level reporting 필요

### 변경사항
1. **Hub-and-spoke 구조** (Portfolio team + repo teams)
2. **Orchestrator agent** (중앙 집중식)
3. **Team workflows** (권한 관리, 협업 회고)

---

## 핵심 커맨드

### /auto-commit-process
- Commit info 받아서 Linear Issue 자동 업데이트
- Conservative AI matching (confidence > 0.85)
- Changelog Document append

### /metrics
- 최신 대시보드 표시
- Git + Linear 데이터 통합
- 어제와 비교 (delta)

### /retrospective
- 자동 회고 생성
- Data collection (Linear + Git)
- Action items 자동 생성

### /collect-linear-metrics
- Linear MCP로 데이터 수집
- Issues closed, in progress
- Cycle progress, average cycle time

### /create-retro-issues
- 회고 action items -> Linear Issues
- Label: retro-action
- 자동 할당

---

## 문제 해결 가이드

### Q: Commit hook이 실행 안 됨
```bash
# Hook 파일 권한 확인
chmod +x .git/hooks/post-commit

# Worker 상태 확인
systemctl --user status commit-queue-worker.service
```

### Q: Claude API rate limit
```bash
# Worker 속도 줄이기
# commit-queue-worker.sh에서 sleep 1 -> sleep 5
```

### Q: AI matching 정확도 낮음
```python
# Threshold 상향
CONFIDENCE_THRESHOLD = 0.85 -> 0.90
```

### Q: Background worker 멈춤
```bash
# Restart
systemctl --user restart commit-queue-worker.service
```

---

## 성공 지표 (KPIs)

### Week 4 (Phase 1-2 완료)
- [ ] Commit 자동 업데이트: 80% 이상
- [ ] Manual updates: 주당 5회 이하
- [ ] UI 사용: 주당 10분 이하

### Month 2 (Phase 3 완료)
- [ ] Background worker uptime: 99%+
- [ ] 주간 회고 실행률: 100%
- [ ] Action items 완료율: 70%+
- [ ] Context switching: 2회/일 이하

---

## 다음 단계

### 지금 바로 시작
```bash
# 1. Daily notes 파일 생성
mkdir -p tmp
echo "# Daily Reflections - Week 1" > tmp/daily-notes.md

# 2. Linear Team 생성
claude
> "Linear에 'Personal Projects' Team 만들어줘"
> "Alpha, Beta, Gamma 프로젝트 생성해줘"

# 3. 오늘 회고 (첫 번째!)
> "오늘 회고 도와줘"
```

### 제가 도울 수 있는 것
1. Linear Team/Projects 생성 (MCP)
2. 커스텀 커맨드 파일 작성
3. Git hook 스크립트 생성
4. Background worker 설정

---

## 관련 문서

- **Week 1 회고 상세**: `tmp/week1-retro-addition.md`
- **AI 토론 전체**: (AI Collaborative Solver 결과)
- **프로젝트 가이드**: `CLAUDE.md`
- **Linear API 가이드**: `docs/linear-api-integration.md`

---

**작성자**: AI Collaborative Solver (Main Claude + Codex)
**검토일**: 2025-11-09
**다음 검토**: 2025-12-09 (Phase 2 도입 여부)
