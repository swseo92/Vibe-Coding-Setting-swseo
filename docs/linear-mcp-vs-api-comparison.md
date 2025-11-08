# Linear MCP vs API 기능 비교

Linear MCP와 API의 기능 차이를 정리한 문서

---

## 전체 비교표

| 기능 | MCP 지원 | API 지원 | 비고 |
|------|----------|----------|------|
| **Document** | 읽기만 | 모든 작업 | MCP: get, list / API: create, update, delete |
| **Issue** | 읽기/쓰기 | 모든 작업 | MCP: 삭제 없음 / API: archive, delete 추가 |
| **Comment** | 생성만 | 모든 작업 | MCP: update/delete 없음 |
| **Project** | 읽기/쓰기 | 모든 작업 | MCP: 삭제 없음 / API: archive, delete 추가 |
| **Label** | 생성만 | 모든 작업 | MCP: update/delete 없음 |
| **Cycle** | 읽기만 | 모든 작업 | MCP: 쓰기 없음 |
| **Team** | 읽기만 | 모든 작업 | MCP: 쓰기 없음 |
| **User** | 읽기만 | 읽기만 | 둘 다 제한적 |
| **Custom View** | 없음 | 모든 작업 | MCP: 완전 없음 |
| **Attachment** | 없음 | 모든 작업 | MCP: 완전 없음 |
| **Initiative** | 없음 | 모든 작업 | MCP: 완전 없음 |
| **Roadmap** | 없음 | 모든 작업 | MCP: 완전 없음 |
| **Template** | 없음 | 모든 작업 | MCP: 완전 없음 |
| **Workflow** | 없음 | 모든 작업 | MCP: 완전 없음 |
| **Custom Field** | 없음 | 모든 작업 | MCP: 완전 없음 |
| **Webhook** | 없음 | 모든 작업 | MCP: 완전 없음 |
| **Integration** | 없음 | 모든 작업 | MCP: 완전 없음 |

---

## API로만 가능한 작업 (카테고리별)

### 1. 삭제 작업 (Delete)

**MCP에서 지원하지 않는 삭제:**
- Issue 삭제 (`issueDelete`)
- Comment 삭제 (`commentDelete`)
- Project 삭제 (`projectDelete`)
- Document 삭제 (`documentDelete`)
- Cycle 삭제 (`cycleDelete`)
- Custom View 삭제 (`customViewDelete`)
- Label 삭제 (`issueLabelDelete`)
- Attachment 삭제 (`attachmentDelete`)

**사용 예시:**
```python
# Issue 삭제
client.delete_issue(issue_id="ISSUE-123")

# Comment 삭제
client.delete_comment(comment_id="abc-123")
```

---

### 2. 아카이브 작업 (Archive)

**MCP에서 지원하지 않는 아카이브:**
- Issue 아카이브 (`issueArchive`)
- Project 아카이브 (`projectArchive`)
- Cycle 아카이브 (`cycleArchive`)
- Custom View 아카이브 (`customViewArchive`)
- Document 아카이브 (`documentArchive`)

**아카이브 vs 삭제:**
- 아카이브: 숨김 처리 (복구 가능)
- 삭제: 영구 삭제 (30일 유예 기간 후 복구 불가)

---

### 3. Comment 관리

**MCP 제한사항:**
- 생성만 가능 (`create_comment`)
- 업데이트/삭제 불가

**API로 가능:**
- Comment 업데이트 (`commentUpdate`)
  - 내용 수정
  - Thread 해결 상태 변경
  - 구독 관리
- Comment 삭제 (`commentDelete`)

**사용 예시:**
```python
# Comment 업데이트
client.update_comment(
    comment_id="abc-123",
    body="Updated comment content",
    resolveThread=True
)
```

---

### 4. Cycle 관리

**MCP 제한사항:**
- 조회만 가능 (`list_cycles`)
- 생성/수정/삭제 불가

**API로 가능:**
- Cycle 생성 (`cycleCreate`)
- Cycle 업데이트 (`cycleUpdate`)
- Cycle 삭제 (`cycleDelete`)
- Cycle 아카이브 (`cycleArchive`)

**사용 예시:**
```python
# Cycle 생성
client.create_cycle(
    team_id="TEAM-123",
    name="Sprint 42",
    startsAt="2025-11-09",
    endsAt="2025-11-23"
)
```

---

### 5. Team 관리

**MCP 제한사항:**
- 조회만 가능 (`list_teams`, `get_team`)
- 생성/수정 불가

**API로 가능:**
- Team 생성 (`teamCreate`)
- Team 업데이트 (`teamUpdate`)
- Team 멤버십 관리 (`teamMembershipCreate`, `teamMembershipUpdate`)

**사용 예시:**
```python
# Team 생성
client.create_team(
    name="Backend Team",
    key="BACKEND",
    description="Backend development team"
)
```

---

### 6. Custom View (MCP에 완전 없음)

**MCP:** 지원 없음

**API로 가능:**
- Custom View 생성 (`customViewCreate`)
- Custom View 업데이트 (`customViewUpdate`)
- Custom View 삭제 (`customViewDelete`)
- Custom View 아카이브 (`customViewArchive`)

**Custom View란?**
- 필터링된 Issue 목록을 저장한 뷰
- 팀원과 공유 가능
- 대시보드처럼 사용

**사용 예시:**
```python
# Custom View 생성 (예: 내가 할당받은 High Priority Issues)
client.create_custom_view(
    name="My High Priority",
    filters={
        "assignee": {"eq": "me"},
        "priority": {"gte": 2}
    }
)
```

---

### 7. Attachment (MCP에 완전 없음)

**MCP:** 지원 없음

**API로 가능:**
- Attachment 생성 (`attachmentCreate`)
- Attachment 업데이트 (`attachmentUpdate`)
- Attachment 삭제 (`attachmentDelete`)

**Attachment 유형:**
- GitHub PR 링크
- Figma 디자인 링크
- 외부 티켓 링크
- 파일 첨부

**사용 예시:**
```python
# GitHub PR을 Issue에 첨부
client.create_attachment(
    issue_id="ISSUE-123",
    url="https://github.com/org/repo/pull/456",
    title="Fix authentication bug",
    metadata={"prNumber": 456}
)
```

---

### 8. Initiative (MCP에 완전 없음)

**MCP:** 지원 없음

**API로 가능:**
- Initiative 생성 (`initiativeCreate`)
- Initiative 업데이트 (`initiativeUpdate`)
- Initiative-Project 연결 (`initiativeToProjectCreate`)

**Initiative란?**
- 여러 Project를 묶는 상위 개념
- 분기별/연도별 목표 관리
- Roadmap과 연동

**사용 예시:**
```python
# 2025 Q4 Initiative 생성
client.create_initiative(
    name="Q4 2025 Goals",
    description="Major features for Q4",
    targetDate="2025-12-31"
)
```

---

### 9. Roadmap (MCP에 완전 없음)

**MCP:** 지원 없음

**API로 가능:**
- Roadmap 생성 (`roadmapCreate`)
- Roadmap 업데이트 (`roadmapUpdate`)
- Roadmap-Project 연결

**Roadmap이란?**
- 시각적 타임라인 뷰
- Project와 Initiative를 시간순 배치
- 장기 계획 공유용

---

### 10. Template (MCP에 완전 없음)

**MCP:** 지원 없음

**API로 가능:**
- Template 생성 (`templateCreate`)
- Template 업데이트 (`templateUpdate`)

**Template 유형:**
- Issue Template (버그 리포트, Feature 요청 등)
- Project Template (제품 출시, 마케팅 캠페인 등)
- Document Template

**사용 예시:**
```python
# Bug Report Template 생성
client.create_template(
    type="issue",
    name="Bug Report",
    templateData={
        "title": "[BUG] ",
        "description": "## Steps to Reproduce\n\n## Expected Behavior\n\n## Actual Behavior"
    }
)
```

---

### 11. Workflow (MCP에 완전 없음)

**MCP:** 지원 없음

**API로 가능:**
- Workflow State 생성 (`workflowStateCreate`)
- Workflow State 업데이트 (`workflowStateUpdate`)
- Workflow State 아카이브 (`workflowStateArchive`)

**Workflow란?**
- Issue 상태 흐름 정의 (Backlog → In Progress → Done)
- 팀별 커스텀 워크플로우

**사용 예시:**
```python
# "Code Review" 상태 추가
client.create_workflow_state(
    team_id="TEAM-123",
    name="Code Review",
    type="started",
    color="#FFA500"
)
```

---

### 12. Custom Field (MCP에 완전 없음)

**MCP:** 지원 없음

**API로 가능:**
- Custom Field 생성 (`customFieldCreate`)
- Custom Field 업데이트 (`customFieldUpdate`)

**Custom Field 유형:**
- Text
- Number
- Select (단일 선택)
- Multi-Select (다중 선택)
- Date

**사용 예시:**
```python
# "Customer Impact" 필드 추가
client.create_custom_field(
    name="Customer Impact",
    type="select",
    options=["High", "Medium", "Low", "None"]
)
```

---

### 13. Webhook (MCP에 완전 없음)

**MCP:** 지원 없음

**API로 가능:**
- Webhook 생성 (`webhookCreate`)
- Webhook 업데이트 (`webhookUpdate`)
- Webhook 삭제 (`webhookDelete`)

**Webhook 이벤트:**
- Issue 생성/업데이트/삭제
- Comment 추가
- Project 변경
- Cycle 시작/종료

**사용 예시:**
```python
# Issue 생성 시 Slack 알림
client.create_webhook(
    url="https://hooks.slack.com/services/...",
    resourceTypes=["Issue"],
    events=["create"]
)
```

---

### 14. Label 업데이트/삭제

**MCP 제한사항:**
- 생성만 가능 (`create_issue_label`)
- 업데이트/삭제 불가

**API로 가능:**
- Label 업데이트 (`issueLabelUpdate`)
  - 이름, 색상, 설명 변경
- Label 삭제 (`issueLabelDelete`)

**사용 예시:**
```python
# Label 색상 변경
client.update_label(
    label_id="LABEL-123",
    color="#FF0000"
)
```

---

### 15. Agent & Integration (MCP에 완전 없음)

**MCP:** 지원 없음

**API로 가능:**
- Agent Session 생성 (`agentSessionCreate`)
- Agent Activity 로깅 (`agentActivityCreate`)
- Slack 통합 관리

**Agent Session이란?**
- AI 에이전트가 Issue/Comment에서 작업할 때 사용
- 외부 URL 추적
- 작업 계획 저장

---

## 권장 사용 패턴

### Pattern 1: MCP for Read, API for Write/Delete

```python
# 1. MCP로 Issue 조회
issues = mcp__linear_server__list_issues(state="Done", limit=50)

# 2. API로 완료된 Issue 아카이브
for issue in issues:
    client.archive_issue(issue_id=issue['id'])
```

### Pattern 2: API for Advanced Features

```python
# 1. API로 Custom View 생성
view = client.create_custom_view(
    name="Urgent Bugs",
    filters={"priority": {"eq": 1}, "labels": {"contains": "bug"}}
)

# 2. API로 Webhook 설정
client.create_webhook(
    url="https://api.myapp.com/linear-webhook",
    resourceTypes=["Issue"],
    events=["create", "update"]
)
```

### Pattern 3: Hybrid Workflow

```python
# 1. MCP로 Project 정보 가져오기
project = mcp__linear_server__get_project(query="My Project")

# 2. API로 Cycle 생성 및 연결
cycle = client.create_cycle(
    team_id=project['team']['id'],
    name="Sprint 1",
    startsAt="2025-11-09"
)

# 3. MCP로 Issue 생성 (간단한 작업)
mcp__linear_server__create_issue(
    title="Setup project",
    team=project['team']['id'],
    cycle=cycle['id']
)
```

---

## 우선순위별 API 추가 권장사항

### High Priority (즉시 추가 권장)

1. **삭제 작업**
   - `delete_issue()`, `delete_comment()`, `delete_project()`
   - 데이터 정리 필수

2. **아카이브 작업**
   - `archive_issue()`, `archive_project()`, `archive_cycle()`
   - 완료된 작업 정리

3. **Comment 관리**
   - `update_comment()`, `delete_comment()`
   - 오타 수정, 민감정보 삭제

### Medium Priority (필요시 추가)

4. **Cycle 관리**
   - `create_cycle()`, `update_cycle()`, `delete_cycle()`
   - 스프린트 자동화

5. **Attachment 관리**
   - `create_attachment()`, `update_attachment()`
   - PR/디자인 링크 자동 연결

6. **Label 업데이트**
   - `update_label()`, `delete_label()`
   - Label 정리 작업

### Low Priority (선택적)

7. **Custom View**
   - 자주 사용하는 필터를 뷰로 저장

8. **Webhook**
   - 외부 시스템 연동 시

9. **Template**
   - 반복 작업 자동화 시

10. **Custom Field**
    - 고급 메타데이터 추적 시

---

## 결론

**MCP로 충분한 경우:**
- Issue/Project 기본 CRUD (삭제 제외)
- 간단한 조회 작업
- Comment 생성

**API가 필수인 경우:**
- 삭제/아카이브 작업
- Comment 수정/삭제
- Cycle, Team, Workflow 관리
- Custom View, Template, Webhook
- 고급 기능 (Initiative, Roadmap, Custom Field)

**권장:**
- 기본 작업은 MCP 사용 (간편함)
- 고급 작업은 API 사용 (완전한 제어)
- 둘을 조합하여 최적의 워크플로우 구성

---

마지막 업데이트: 2025-11-09
