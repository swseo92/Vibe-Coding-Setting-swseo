# Week 1 회고 및 프로세스 개선 추가사항

## 핵심 아이디어

**"자동화 전에 수동으로 먼저 해보기"**
- 무엇이 귀찮은지 체감
- Baseline 측정 (자동화 효과 비교)
- 빠른 학습 루프

---

## Labels Setup (Day 1)

**목적**:
- 일관된 Issue 분류 체계 확립
- 프로젝트/작업 종류별 필터링 가능
- 진화 가능한 최소한의 라벨로 시작

**초기 라벨 (5개)**:

| 라벨 이름 | 설명 | 색상 제안 | 사용 예시 |
|----------|------|-----------|-----------|
| type:feature | 새로운 기능 추가 | #0E8A16 (녹색) | "Add user authentication" |
| type:bug | 버그 수정 | #D73A4A (빨강) | "Fix login error" |
| type:refactor | 코드 리팩토링 | #FBCA04 (노랑) | "Refactor API client" |
| type:docs | 문서 작업 | #0075CA (파랑) | "Update README" |
| type:learning | 학습/연구 | #7057FF (보라) | "Learn GraphQL basics" |

**생성 방법**:
```bash
# MCP로 라벨 생성 (팀 라벨로 생성)
claude
> "Linear에 다음 라벨들 만들어줘:
  - type:feature (녹색, 새로운 기능 추가)
  - type:bug (빨강, 버그 수정)
  - type:refactor (노랑, 코드 리팩토링)
  - type:docs (파랑, 문서 작업)
  - type:learning (보라, 학습/연구)"
```

**사용 가이드**:
- 하나의 Issue에 여러 type 라벨 가능 (예: feature + docs)
- Week 1-2에는 이 5개로 충분
- Week 3 이후 필요시 추가 라벨 생성 가능 (priority:*, status:* 등)
- 진화적 접근: 실제 필요가 생길 때 추가

**완료 기준**:
- [ ] 5개 라벨이 Linear에 생성됨
- [ ] 각 라벨이 올바른 색상으로 설정됨
- [ ] 첫 Issue 생성 시 적절한 type 라벨 부여

---

## Week 1-2에 추가: Manual Retrospective & Baseline

### Day 1-5: Daily Reflection (매일 저녁 5분)

**목적**:
- 하루를 되돌아보는 습관 형성
- 불편한 점을 즉시 기록
- 자동화 우선순위 파악

**방법**:
```bash
# tmp/daily-notes.md에 추가 (append)
echo "## $(date +%Y-%m-%d)" >> tmp/daily-notes.md
echo "" >> tmp/daily-notes.md

# Claude와 대화로 작성
claude
> "오늘 회고 도와줘. 오늘 작업: ALPHA-123 완료, BETA-45 진행 중"
> "어려웠던 점: Linear에서 Issue 찾기 번거로움"
> "내일 목표: BETA-45 완료"
```

**템플릿**:
```markdown
## 2025-11-09

Today's work:
- 완료: ALPHA-123 (사용자 인증 API)
- 진행 중: BETA-45 (대시보드 UI 개선)
- Commits: 8 (Alpha: 5, Beta: 3)

What went well:
- 오전 (9-11 AM) 집중 시간 생산성 높음
- Linear MCP 명령어 익숙해짐
- Issue 우선순위 명확히 함

What was difficult:
- Linear에서 Issue ID 찾기 번거로움 (검색 5-6회)
- Commit과 Issue 수동 연결 귀찮음 (10회)
- 어제 뭐 했는지 기억 안 남 (5분 소요)

Learnings:
- Labels로 프로젝트 구분이 효과적
- "오늘 할 일" 명령어를 자주 씀
- Web UI보다 MCP가 3배 빠름

Tomorrow:
- BETA-45 완료 목표
- 새 Issue: GAMMA-78 (데이터 파이프라인)
```

**효과**:
- 5일 후 명확한 Pain points 파악
- 자동화 우선순위 자연스럽게 도출
- "Commit <-> Issue 연결"이 가장 귀찮다는 것 체감

---

### Day 5 (금요일): Week 1 Mini Retro (30분)

**목적**:
- 첫 주 경험 정리
- 다음 주 개선 방향 설정
- Baseline 측정 (자동화 전 상태)

**방법**:
```bash
# tmp/retro-week1.md 작성
claude
> "이번 주 회고 도와줘"
> "Daily notes 5개 읽어서 패턴 찾아줘"
> "가장 시간 많이 쓴 작업이 뭐야?"
```

**템플릿**:
```markdown
# Week 1 Retrospective (2025-11-04 ~ 11-08)

## Numbers (수동 측정)

### Git Activity
```bash
# 모든 repo의 commits 합계
for repo in ~/projects/*; do
  cd $repo
  echo "$(basename $repo): $(git log --since="1 week ago" --oneline | wc -l) commits"
done
# Total: 45 commits
```

### Linear Activity
```bash
# MCP로 조회
> "지난주 완료한 Issues 개수"
> "지난주 생성한 Issues 개수"
# Closed: 8 issues
# Created: 12 issues
```

### Time Tracking (추정)
- Average work hours/day: ~7h
- Linear 사용 시간: ~30분/일
- Manual Issue updates: ~15분/일
- "어제 뭐 했지?" 시간: ~10분/일
- **Total overhead: ~55분/일**

## What Went Well

1. **Linear MCP 빠르게 익힘**
   - Day 1: 어색함
   - Day 5: 자연스러움
   - Web UI 사용: 주 2-3회로 감소

2. **CLI 워크플로우가 효율적**
   - Web UI 대비 3배 빠름
   - "오늘 할 일" 명령어로 하루 시작

3. **Labels 체계 효과적**
   - project:* 로 프로젝트 구분 명확
   - type:* 로 작업 종류 파악 쉬움

4. **[구체적 사례]**
   - 예: Tuesday 오전 집중 시간 (9-11 AM)에 4 issues 완료

## What Needs Improvement

1. **Issue와 Commit 수동 연결 번거로움** (가장 큰 pain!)
   - 하루 10-15회 반복
   - 매번 5분 소요 = 50-75분/일
   - **Week 3에 자동화 최우선**

2. **어떤 Issue에 집중할지 판단 어려움**
   - Priority가 명확하지 않음
   - Labels 정리 필요

3. **진행 상황 파악 번거로움**
   - "어제 뭐 했지?" 매일 10분 소요
   - Daily summary 자동화 필요

4. **[구체적 사례]**
   - 예: Wednesday는 생산성 낮음 (context switching 많음)

## Patterns Discovered

### Productivity
- Best time: 9-11 AM (commits per hour 평균 4개)
- Worst time: 2-3 PM (점심 후 슬럼프)
- Friday velocity: -20% (주말 전 집중력 저하)

### Tool Usage
- Most used MCP command: "오늘 할 일" (하루 3-4회)
- Least used: Web UI (주 2-3회만)
- Commit frequency: 평균 9 commits/day

### Context Switching
- 프로젝트 간 전환: 5회/일 (너무 많음)
- 이상적: 2-3회/일

## Learnings

1. **Linear MCP > Web UI**
   - 속도: 3배 차이
   - 키보드만으로 작업 가능
   - 학습 곡선: 2-3일

2. **Labels가 핵심**
   - 프로젝트 구분: project:*
   - 작업 분류: type:*
   - 필터링 강력함

3. **Daily reflection 효과적**
   - 5분 투자로 명확한 개선점 발견
   - "Commit 연결"이 가장 귀찮다는 것 체감

## Next Week Goals

1. **Labels 체계 정리**
   - Priority labels 추가
   - 사용하지 않는 labels 제거

2. **Daily reflection 습관화**
   - 매일 저녁 5분 투자
   - tmp/daily-notes.md 계속 작성

3. **Week 3 자동화 준비**
   - Pain points 우선순위 확정
   - Git hook 설계 시작

4. **Context switching 줄이기**
   - 프로젝트별 집중 시간 블록 (2시간)
   - 목표: 5회 -> 3회/일

## Baseline Metrics (자동화 전)

**이 지표는 Week 5-6 자동화 후 비교 기준이 됨**

### Time Overhead (Manual Tasks)
- Linear UI/MCP 사용: 30분/일
- Commit <-> Issue 연결: 15분/일
- Progress tracking: 10분/일
- **Total: 55분/일 (주당 4.6시간!)**

### Friction Points (우선순위순)
1. **Commit -> Issue 자동 연결** (하루 10-15회, 각 5분)
2. **Daily progress summary** (하루 1회, 10분)
3. **Weekly retro 데이터 수집** (주 1회, 30분)

### Current Workflow Pain
"Commit 후 Linear 열어서 Issue 찾고 (2분) -> Comment 추가 (1분) -> 상태 변경 (1분) -> Changelog 업데이트 (1분) = 5분/commit. 하루 10 commits면 50분!"

### Target (자동화 후)
- Time overhead: 55분 -> 10분 (80% 감소)
- Manual updates: 10-15회 -> 0-1회
- Progress tracking: 수동 -> 자동
```

**효과**:
- Week 5 자동화 도입 시 Before/After 비교 가능
- ROI 명확히 측정 ("50분 절약!")
- 우선순위 확정 (Commit 연결 1순위)

---

### 완료 기준 (Updated)

**기존**:
- [ ] Linear Team + 3개 Projects 생성
- [ ] 5개 기본 Labels 생성 (type:*)
- [ ] MCP로 Issue CRUD 가능
- [ ] 첫 Cycle 생성 및 Issue 할당

**추가 (NEW!)**:
- [ ] Day 1-5: Daily reflection 5일 연속 작성
- [ ] Day 5: Week 1 mini-retro 작성 완료
- [ ] Day 5: Baseline metrics 측정 완료
- [ ] 자동화 우선순위 Top 3 확정

---

## 자동화 전/후 비교 (예상)

### Week 1 (Manual Baseline)
```
Time spent on overhead: 55분/일
- Issue finding: 10분
- Commit linking: 15분
- Manual updates: 20분
- Progress tracking: 10분

Feeling: "매번 반복 작업 귀찮음..."
```

### Week 6 (After Automation)
```
Time spent on overhead: 10분/일 (-80%)
- Issue finding: 자동 (MCP 명령어)
- Commit linking: 자동 (post-commit hook)
- Manual updates: 자동 (큐 시스템)
- Progress tracking: 자동 (daily metrics)

Feeling: "거의 신경 안 써도 됨!"
```

**절약 시간**: 45분/일 = 3.75시간/주 = 15시간/월

---

## Week 1 Daily Schedule (Updated)

### Day 1 (Monday)
- **오전**: Linear Team/Projects 생성
- **오후 전반**: Labels 5개 생성 (10분)
- **오후 후반**: MCP 워크플로우 익히기
- **저녁 (NEW!)**: 첫 Daily reflection 작성 (5분)

### Day 2-4 (Tue-Thu)
- **오전/오후**: 실제 프로젝트 작업
- **저녁 (NEW!)**: Daily reflection (5분)
  - 오늘 완료/진행 작업
  - 어려웠던 점
  - 내일 목표

### Day 5 (Friday)
- **오전/오후**: 실제 작업
- **오후 4-5시 (NEW!)**: Week 1 mini-retro (30분)
  - Daily notes 5개 읽기
  - 패턴 발견
  - Baseline metrics 측정
  - 다음 주 목표 설정
- **저녁**: 주말 시작!

---

## 실전 예시

### Day 1 Evening (첫 Daily Reflection)

```bash
claude
> "오늘 회고 도와줘"

User: "오늘 Linear 처음 써봤어. Team 만들고 Projects 3개 생성했어."

Claude: "좋은 시작이네요! 어떤 점이 어려웠나요?"

User: "MCP 명령어 익히는 게 좀 헷갈렸어. 그리고 Issue 만들 때 뭘 넣어야 할지..."

Claude: "Daily reflection 형식으로 정리해드릴게요."

# tmp/daily-notes.md에 작성됨:
## 2025-11-04 (Day 1)

Today's work:
- Linear 계정 설정
- Team: Personal Projects 생성
- Projects: Alpha, Beta, Gamma 생성
- Labels: project:*, type:* 설정

What went well:
- Linear 계정 빠르게 설정
- MCP 연결 성공
- 첫 Issue 생성 (ALPHA-1)

What was difficult:
- MCP 명령어 익히기 (30분 소요)
- Issue에 뭘 넣을지 모호함
- Web UI와 MCP 중 뭐 쓸지 헷갈림

Learnings:
- Linear MCP는 자연어로 작동
- "오늘 할 일" 같은 명령어가 편함
- Labels가 중요하다는 것 깨달음

Tomorrow:
- 실제 프로젝트 Issue 5개 생성
- MCP 명령어 더 익히기
- 첫 Cycle 만들기
```

### Day 5 Afternoon (Week 1 Mini Retro)

```bash
claude
> "이번 주 회고 도와줘. tmp/daily-notes.md 읽어서 패턴 찾아줘"

Claude: (5개 daily notes 분석 후)
"패턴을 발견했습니다:
1. Day 1-2: MCP 익히기 (learning phase)
2. Day 3-5: 실제 작업 (productive phase)
3. 매일 'Commit과 Issue 수동 연결'이 불편함으로 언급됨
4. 오전 (9-11 AM)에 집중력 높음
5. Friday 오후는 velocity 낮음"

> "가장 많이 시간 쓴 manual task가 뭐야?"

Claude: "Commit과 Issue 연결입니다.
- Day 2: 5회 (25분)
- Day 3: 10회 (50분)
- Day 4: 12회 (60분)
- Day 5: 8회 (40분)
평균: 하루 43분 소요. 이게 최우선 자동화 대상입니다."

> "Week 1 retro 작성해줘"

# tmp/retro-week1.md 생성됨 (위 템플릿 참고)
```

---

## 기대 효과

### 즉시 (Week 1)
- 불편한 점 명확히 인식
- 자동화 우선순위 확정
- 학습 루프 빠름 (Linear 사용법)

### 중기 (Week 3-4)
- Baseline과 비교하여 자동화 설계
- "50분 절약"이라는 명확한 목표
- 사용자 경험 기반 구현

### 장기 (Week 5-6)
- 자동화 효과 측정 (Before 55분 -> After 10분)
- ROI 증명 (45분/일 절약)
- 추가 개선 포인트 발견

---

## 다음 단계

1. **지금 바로 시작**:
```bash
# tmp/daily-notes.md 파일 생성
touch tmp/daily-notes.md
echo "# Daily Reflections - Week 1" > tmp/daily-notes.md
```

2. **매일 저녁 5분**:
```bash
claude > "오늘 회고 도와줘"
```

3. **금요일 30분**:
```bash
claude > "이번 주 회고 도와줘"
```

**간단하지만 강력합니다!**
