# Linear Label 사용 가이드

**목적**: Issue를 효과적으로 분류하고 필터링하기 위한 라벨 사용법

---

## 현재 라벨 체계 (Week 1-2)

### type:feature

**언제 사용하나요?**
- 새로운 기능을 추가할 때
- 기존에 없던 동작을 구현할 때
- 사용자에게 새로운 가치를 제공할 때

**사용 예시:**
- "Add user authentication system"
- "Implement video upload pipeline"
- "Create daily metrics dashboard"
- "Add TTS notification for task completion"

**베스트 프랙티스:**
- 명확한 동사 사용 (Add, Implement, Create)
- 사용자 관점에서 가치 설명
- Feature가 크면 여러 하위 Issue로 분리

**안티패턴:**
- "Update authentication" (이건 refactor)
- "Fix missing feature" (이건 bug)

---

### type:bug

**언제 사용하나요?**
- 예상대로 작동하지 않는 기능이 있을 때
- 에러나 크래시가 발생할 때
- 사용자 경험을 방해하는 문제가 있을 때

**사용 예시:**
- "Fix login error on Safari"
- "Resolve memory leak in video processor"
- "Fix broken links in documentation"
- "Resolve API timeout issue"

**베스트 프랙티스:**
- "Fix" 또는 "Resolve" 동사 사용
- 재현 방법을 Issue description에 작성
- 예상 동작 vs 실제 동작 명확히 구분

**안티패턴:**
- "Improve performance" (이건 refactor)
- "Add missing validation" (이건 feature)

---

### type:refactor

**언제 사용하나요?**
- 동작은 그대로지만 코드를 개선할 때
- 성능 최적화할 때
- 코드 구조를 재정리할 때
- 기술 부채를 해결할 때

**사용 예시:**
- "Refactor API client to use async/await"
- "Optimize database query performance"
- "Restructure project folder layout"
- "Extract common logic into utility functions"

**베스트 프랙티스:**
- "Refactor", "Optimize", "Restructure" 동사 사용
- 리팩토링 이유를 Issue description에 명시
- 기능 변경이 없음을 강조

**안티패턴:**
- "Refactor and add new feature" (feature와 분리)
- "Fix bug by refactoring" (bug가 우선)

---

### type:docs

**언제 사용하나요?**
- README, 가이드, API 문서 작성/수정할 때
- 코드 주석(docstring)을 추가/개선할 때
- 사용법 예시를 추가할 때
- CHANGELOG 업데이트할 때

**사용 예시:**
- "Update README with installation guide"
- "Add docstrings to API endpoints"
- "Create troubleshooting guide"
- "Document environment variable usage"

**베스트 프랙티스:**
- "Update", "Add", "Document" 동사 사용
- 어떤 문서를 수정하는지 명시
- 코드 변경 없이 문서만 수정

**안티패턴:**
- "Add feature and update docs" (feature와 분리)
- "Fix typo in code comment" (너무 trivial하면 별도 Issue 불필요)

---

### type:learning

**언제 사용하나요?**
- 새로운 기술/라이브러리를 학습할 때
- 실험적 프로토타입을 만들 때
- 연구/조사 작업을 수행할 때
- 튜토리얼을 따라할 때

**사용 예시:**
- "Learn GraphQL basics"
- "Research LangGraph workflow patterns"
- "Experiment with Playwright automation"
- "Study pytest best practices"

**베스트 프랙티스:**
- "Learn", "Research", "Study", "Experiment" 동사 사용
- 학습 목표를 Issue description에 작성
- 학습 결과를 comment로 기록
- Personal Development 프로젝트에 주로 사용

**안티패턴:**
- "Learn React by building feature" (feature가 우선)
- 학습 Issue를 무한정 열어두기 (완료 기준 명확히)

---

## 라벨 조합 가이드

### 여러 라벨을 함께 사용할 수 있나요?

**가능합니다!** 하지만 신중하게:

**좋은 조합:**
- `type:feature` + `type:docs` - "새 기능 추가 + 문서화"
- `type:refactor` + `type:docs` - "리팩토링 + 주석 개선"
- `type:learning` + `type:docs` - "학습 + 학습 노트 작성"

**피해야 할 조합:**
- `type:feature` + `type:bug` - 하나로 정하세요 (어느 게 주목적?)
- 3개 이상 라벨 - Issue가 너무 큽니다, 분리하세요

---

## 필터링 활용법

**MCP 명령어로 필터링:**

```bash
# type:feature 라벨이 있는 Issue만
"type:feature 라벨이 있는 Issue 보여줘"

# type:bug이면서 In Progress 상태인 것만
"진행 중인 버그 Issue 보여줘"

# Personal Development 프로젝트의 type:learning
"Personal Development 프로젝트에서 학습 관련 Issue 보여줘"
```

**웹 UI 필터:**
- Filters > Labels > `type:feature` 선택
- 여러 라벨을 AND/OR 조건으로 조합 가능

---

## 라벨 진화 전략

**Week 1-2 (현재)**: 5개 type 라벨만
**Week 3 이후**: 필요에 따라 추가

**추가 가능한 라벨 (나중에):**

### Priority 라벨 (필요시)
- `priority:urgent` - 즉시 처리 필요
- `priority:high` - 중요하지만 급하지 않음
- `priority:normal` - 일반적인 우선순위
- `priority:low` - 시간 날 때 처리

**언제 추가하나요?**
- Week 1-2에서 "어떤 Issue를 먼저 해야 할지 모르겠다"는 pain point 발견 시
- Issue가 20개 이상 쌓였을 때

### Status 라벨 (필요시)
- `status:blocked` - 다른 작업 대기 중
- `status:needs-review` - 리뷰 필요

**언제 추가하나요?**
- 협업 시작 시
- Workflow state만으로 부족할 때

### Project 라벨 (비추천)
- `project:alpha`, `project:beta` 형태
- **대신 Linear Project 기능 사용 권장**
- 프로젝트가 5개 이상일 때만 고려

---

## 베스트 프랙티스 요약

1. **하나의 주된 type 선택** - Feature인가, Bug인가, Refactor인가?
2. **명확한 동사 사용** - Add, Fix, Refactor, Update, Learn
3. **조합은 신중히** - 2개까지, 목적이 명확할 때만
4. **진화적 접근** - 필요할 때 라벨 추가, 미리 만들지 말기
5. **일관성 유지** - 팀원과 동일한 기준 사용

---

## 안티패턴 요약

- 너무 많은 라벨 생성 (처음부터 20개 만들기)
- 라벨 없이 Issue 생성 (최소 1개는 부여)
- 모호한 라벨 조합 (feature + bug 동시 사용)
- 사용하지 않는 라벨 방치 (6개월간 0회 사용)
- Linear Project 대신 project:* 라벨 남용

---

## 주간 라벨 리뷰 (Week 1 금요일)

**Mini-retro에서 체크할 것:**

1. 각 라벨이 몇 번 사용되었나?
2. 어떤 라벨이 가장 유용했나?
3. 추가하고 싶은 라벨이 있나?
4. 사용하지 않는 라벨이 있나?

**예시 분석:**
```
Week 1 라벨 사용 통계:
- type:feature: 8회 (가장 많이 사용)
- type:bug: 3회
- type:refactor: 2회
- type:docs: 5회
- type:learning: 4회

인사이트:
- Feature 개발 중심의 한 주였음
- Docs 작업도 활발 (문서화 습관 좋음)
- Learning이 4회 (Personal Development 프로젝트 활용 중)
```

---

**마지막 업데이트**: 2025-11-09 (Week 1-2)
**다음 리뷰**: Week 3 시작 시 (라벨 진화 결정)
