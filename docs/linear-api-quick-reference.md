# Linear API Quick Reference

완전한 Linear API 클라이언트 사용 가이드 - MCP와 상호보완적으로 사용

---

## 설치 및 설정

```bash
# 의존성 설치
pip install requests python-dotenv

# .env 파일 생성
cp .env.example .env

# API 키 설정 (.env 파일 편집)
LINEAR_API_KEY=lin_api_YOUR_KEY_HERE
```

---

## CLI 사용법

### 기본 형식

```bash
python .claude/scripts/linear-api-client.py <resource> <action> [options]
```

### 리소스 타입

- `document` (또는 `doc`) - Document 관리
- `issue` - Issue 삭제/아카이브
- `comment` - Comment 수정/삭제
- `project` - Project 삭제/아카이브
- `cycle` - Cycle 전체 관리
- `team` - Team 생성/수정
- `label` - Label 수정/삭제
- `attachment` (또는 `att`) - Attachment 관리
- `view` - Custom View 관리
- `initiative` (또는 `init`) - Initiative 관리
- `roadmap` - Roadmap 관리
- `workflow` (또는 `wf`) - Workflow State 관리
- `webhook` - Webhook 관리

---

## Document 작업

### 생성

```bash
python .claude/scripts/linear-api-client.py document create \
  --title "API Integration Guide" \
  --content "# Linear API\n\nComplete guide to using the API" \
  --project-id "PROJECT-123"
```

### 업데이트

```bash
python .claude/scripts/linear-api-client.py document update \
  --id "DOC-456" \
  --content "# Updated Content"
```

### 삭제

```bash
python .claude/scripts/linear-api-client.py document delete --id "DOC-456"
```

### 아카이브

```bash
python .claude/scripts/linear-api-client.py document archive --id "DOC-456"
```

---

## Issue 작업 (삭제/아카이브만)

Issue 생성/수정은 MCP 사용 권장

### 삭제

```bash
python .claude/scripts/linear-api-client.py issue delete --id "ISSUE-123"
```

### 아카이브

```bash
python .claude/scripts/linear-api-client.py issue archive --id "ISSUE-123"
```

### 복원 (아카이브 해제)

```bash
python .claude/scripts/linear-api-client.py issue unarchive --id "ISSUE-123"
```

---

## Comment 작업

### 업데이트

```bash
python .claude/scripts/linear-api-client.py comment update \
  --id "comment-abc-123" \
  --body "Updated comment text"
```

### 삭제

```bash
python .claude/scripts/linear-api-client.py comment delete --id "comment-abc-123"
```

---

## Project 작업 (삭제/아카이브만)

Project 생성/수정은 MCP 사용 권장

### 삭제

```bash
python .claude/scripts/linear-api-client.py project delete --id "PROJECT-123"
```

### 아카이브

```bash
python .claude/scripts/linear-api-client.py project archive --id "PROJECT-123"
```

### 복원

```bash
python .claude/scripts/linear-api-client.py project unarchive --id "PROJECT-123"
```

---

## Cycle 작업 (완전 지원)

MCP에서는 읽기만 가능, 모든 쓰기 작업은 API 사용 필요

### 생성

```bash
python .claude/scripts/linear-api-client.py cycle create \
  --team "TEAM-123" \
  --name "Sprint 42" \
  --starts-at "2025-11-09T00:00:00Z" \
  --ends-at "2025-11-23T00:00:00Z"
```

### 업데이트

```bash
python .claude/scripts/linear-api-client.py cycle update \
  --id "CYCLE-456" \
  --name "Sprint 42 Extended" \
  --ends-at "2025-11-30T00:00:00Z"
```

### 아카이브

```bash
python .claude/scripts/linear-api-client.py cycle archive --id "CYCLE-456"
```

---

## Team 작업

### 생성

```bash
python .claude/scripts/linear-api-client.py team create \
  --name "Backend Team" \
  --key "BACK" \
  --description "Backend development team"
```

### 업데이트

```bash
python .claude/scripts/linear-api-client.py team update \
  --id "TEAM-123" \
  --description "Updated description" \
  --color "#0000FF"
```

---

## Label 작업

### 업데이트

```bash
python .claude/scripts/linear-api-client.py label update \
  --id "LABEL-123" \
  --name "critical" \
  --color "#FF0000"
```

### 삭제

```bash
python .claude/scripts/linear-api-client.py label delete --id "LABEL-123"
```

---

## Attachment 작업

### 생성 (GitHub PR 링크)

```bash
python .claude/scripts/linear-api-client.py attachment create \
  --issue "ISSUE-123" \
  --url "https://github.com/org/repo/pull/456" \
  --title "Fix authentication bug"
```

### 업데이트

```bash
python .claude/scripts/linear-api-client.py attachment update \
  --id "ATT-789" \
  --title "Updated title"
```

### 삭제

```bash
python .claude/scripts/linear-api-client.py attachment delete --id "ATT-789"
```

---

## Custom View 작업

### 생성

```bash
python .claude/scripts/linear-api-client.py view create \
  --name "My High Priority Issues" \
  --team "TEAM-123" \
  --description "Issues assigned to me with high priority"
```

### 업데이트

```bash
python .claude/scripts/linear-api-client.py view update \
  --id "VIEW-456" \
  --description "Updated description"
```

### 삭제

```bash
python .claude/scripts/linear-api-client.py view delete --id "VIEW-456"
```

### 아카이브

```bash
python .claude/scripts/linear-api-client.py view archive --id "VIEW-456"
```

---

## Initiative 작업

### 생성

```bash
python .claude/scripts/linear-api-client.py initiative create \
  --name "Q4 2025 Goals" \
  --description "Major features for Q4" \
  --target-date "2025-12-31"
```

### 업데이트

```bash
python .claude/scripts/linear-api-client.py initiative update \
  --id "INIT-123" \
  --target-date "2026-01-15"
```

### 삭제

```bash
python .claude/scripts/linear-api-client.py initiative delete --id "INIT-123"
```

### Project 연결

```bash
python .claude/scripts/linear-api-client.py initiative connect \
  --id "INIT-123" \
  --project "PROJECT-456"
```

---

## Roadmap 작업

### 생성

```bash
python .claude/scripts/linear-api-client.py roadmap create \
  --name "2025 Product Roadmap" \
  --description "Our product vision for 2025"
```

### 업데이트

```bash
python .claude/scripts/linear-api-client.py roadmap update \
  --id "ROADMAP-123" \
  --description "Updated vision"
```

### 삭제

```bash
python .claude/scripts/linear-api-client.py roadmap delete --id "ROADMAP-123"
```

---

## Workflow State 작업

### 생성 (커스텀 상태 추가)

```bash
python .claude/scripts/linear-api-client.py workflow create \
  --team "TEAM-123" \
  --name "Code Review" \
  --type "started" \
  --color "#FFA500"
```

**State Types:**
- `backlog` - Backlog
- `unstarted` - Not started
- `started` - In progress
- `completed` - Done
- `canceled` - Canceled

### 업데이트

```bash
python .claude/scripts/linear-api-client.py workflow update \
  --id "STATE-456" \
  --color "#00FF00"
```

### 아카이브

```bash
python .claude/scripts/linear-api-client.py workflow archive --id "STATE-456"
```

---

## Webhook 작업

### 생성

```bash
python .claude/scripts/linear-api-client.py webhook create \
  --url "https://api.myapp.com/linear-webhook" \
  --types Issue Comment \
  --label "My App Webhook"
```

### 업데이트

```bash
python .claude/scripts/linear-api-client.py webhook update \
  --id "WEBHOOK-123" \
  --enabled true
```

### 삭제

```bash
python .claude/scripts/linear-api-client.py webhook delete --id "WEBHOOK-123"
```

---

## Python 코드에서 사용

### Import 및 초기화

```python
import os
import sys
from dotenv import load_dotenv

# .claude/scripts 경로 추가
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '.claude', 'scripts'))

from linear_api_client import LinearAPIClient

# 환경변수 로드
load_dotenv()
api_key = os.getenv("LINEAR_API_KEY")

# 클라이언트 생성
client = LinearAPIClient(api_key)
```

### 사용 예시

```python
# Document 생성
result = client.create_document(
    title="My Document",
    content="# Hello World\n\nContent here",
    project_id="PROJECT-123"
)
print(f"Created: {result['document']['url']}")

# Issue 아카이브
client.archive_issue("ISSUE-456")

# Comment 업데이트
client.update_comment(
    comment_id="comment-789",
    body="Updated comment text"
)

# Cycle 생성
cycle = client.create_cycle(
    team_id="TEAM-123",
    name="Sprint 42",
    starts_at="2025-11-09",
    ends_at="2025-11-23"
)
print(f"Cycle ID: {cycle['cycle']['id']}")

# Custom View 생성
view = client.create_custom_view(
    name="My High Priority",
    team_id="TEAM-123"
)

# Webhook 생성
webhook = client.create_webhook(
    url="https://api.myapp.com/webhook",
    resource_types=["Issue", "Comment"]
)
```

---

## MCP vs API 사용 가이드

### MCP 사용 권장

- Issue 생성/조회/수정 (삭제/아카이브 제외)
- Project 생성/조회/수정 (삭제/아카이브 제외)
- Comment 생성/조회
- Team 조회
- Cycle 조회
- Label 생성/조회
- Document 조회

### API 사용 필수

- 모든 삭제 작업
- 모든 아카이브 작업
- Comment 수정/삭제
- Cycle 생성/수정
- Team 생성/수정
- Label 수정/삭제
- Attachment 모든 작업
- Custom View 모든 작업
- Initiative 모든 작업
- Roadmap 모든 작업
- Workflow State 모든 작업
- Webhook 모든 작업

### 하이브리드 워크플로우

**패턴 1: 조회 후 삭제**

```python
# 1. MCP로 완료된 Issue 조회
issues = mcp__linear_server__list_issues(state="Done", limit=100)

# 2. API로 일괄 아카이브
for issue in issues['nodes']:
    client.archive_issue(issue['id'])
    print(f"Archived: {issue['identifier']}")
```

**패턴 2: 생성 후 연결**

```python
# 1. API로 Initiative 생성
initiative = client.create_initiative(
    name="Q4 Goals",
    target_date="2025-12-31"
)

# 2. MCP로 Project 조회
project = mcp__linear_server__get_project(query="My Project")

# 3. API로 연결
client.connect_initiative_to_project(
    initiative_id=initiative['initiative']['id'],
    project_id=project['id']
)
```

**패턴 3: Custom View + Webhook**

```python
# 1. API로 Custom View 생성 (High Priority Bugs)
view = client.create_custom_view(
    name="Critical Bugs",
    team_id="TEAM-123"
)

# 2. API로 Webhook 생성 (이 View에 Issue 추가되면 알림)
webhook = client.create_webhook(
    url="https://api.myapp.com/critical-alert",
    resource_types=["Issue"],
    label="Critical Bugs Alert"
)
```

---

## 일반적인 사용 시나리오

### 시나리오 1: Sprint 완료 후 정리

```bash
# 1. 완료된 Issue 아카이브
python .claude/scripts/linear-api-client.py issue archive --id ISSUE-123

# 2. 완료된 Cycle 아카이브
python .claude/scripts/linear-api-client.py cycle archive --id CYCLE-456

# 3. 완료된 Project 아카이브
python .claude/scripts/linear-api-client.py project archive --id PROJECT-789
```

### 시나리오 2: 새 팀 설정

```bash
# 1. Team 생성
python .claude/scripts/linear-api-client.py team create \
  --name "Frontend" --key "FE"

# 2. Workflow State 추가 (Code Review)
python .claude/scripts/linear-api-client.py workflow create \
  --team TEAM-123 --name "Code Review" --type started

# 3. Custom View 생성
python .claude/scripts/linear-api-client.py view create \
  --name "Team Backlog" --team TEAM-123
```

### 시나리오 3: 릴리스 노트 자동화

```python
# 1. MCP로 완료된 Issue 가져오기
issues = mcp__linear_server__list_issues(
    state="Done",
    cycle="CYCLE-current"
)

# 2. Roadmap에 추가할 Document 생성
content = "# Release v1.2.0\n\n"
for issue in issues['nodes']:
    content += f"- {issue['title']} ([{issue['identifier']}]({issue['url']}))\n"

doc = client.create_document(
    title="Release Notes v1.2.0",
    content=content
)

# 3. Webhook으로 외부 시스템에 알림
webhook = client.create_webhook(
    url="https://api.slack.com/webhooks/...",
    resource_types=["Document"]
)
```

### 시나리오 4: Label 정리

```python
# 1. MCP로 모든 Label 조회
labels = mcp__linear_server__list_issue_labels()

# 2. 중복 Label 찾기 및 업데이트/삭제
for label in labels['nodes']:
    if "deprecated" in label['name'].lower():
        # 삭제
        client.delete_label(label['id'])
    elif label['color'] == "#000000":
        # 색상 업데이트
        client.update_label(
            label_id=label['id'],
            color="#808080"
        )
```

---

## 오류 처리

### API 키 오류

```
ERROR: LINEAR_API_KEY not found in environment variables
```

**해결:**
- `.env` 파일 확인
- `LINEAR_API_KEY=lin_api_...` 설정 확인

### GraphQL 오류

```
GraphQL errors: Variable "$input" of required type was not provided
```

**해결:**
- 필수 필드 확인 (예: update는 최소 1개 필드 필요)
- `--help` 옵션으로 필요한 인자 확인

### 권한 오류

```
API request failed: 403
```

**해결:**
- API 키 권한 확인 (Linear Settings > API)
- 삭제 권한이 있는지 확인

---

## 도움말 보기

### 전체 명령어 보기

```bash
python .claude/scripts/linear-api-client.py --help
```

### 특정 리소스 명령어 보기

```bash
python .claude/scripts/linear-api-client.py document --help
python .claude/scripts/linear-api-client.py cycle --help
```

### 특정 액션 옵션 보기

```bash
python .claude/scripts/linear-api-client.py cycle create --help
```

---

## 추가 리소스

- [Linear API 공식 문서](https://developers.linear.app/docs/graphql)
- [MCP vs API 비교](docs/linear-mcp-vs-api-comparison.md)
- [통합 가이드](docs/linear-api-integration.md)

---

마지막 업데이트: 2025-11-09
