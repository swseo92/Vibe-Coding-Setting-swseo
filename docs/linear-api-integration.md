# Linear API Integration Guide

MCP와 상호보완적으로 Linear API를 사용하여 Document를 관리하는 방법

---

## 개요

**Linear MCP와 Linear API의 역할 분담:**

| 작업 유형 | 도구 | 사용 가능 작업 |
|-----------|------|----------------|
| **읽기 (Read)** | Linear MCP | Document 조회, 목록, Issue/Project 조회 |
| **쓰기 (Write)** | Linear API | Document 생성/업데이트/삭제 |

**왜 이렇게 나눴나요?**
- Linear MCP는 현재 Document 쓰기 작업을 지원하지 않습니다
- API를 통해 이 제한을 우회하여 완전한 Document 관리가 가능합니다

---

## 설정 방법

### 1. Linear API Key 발급

1. Linear에 로그인
2. Settings > API > Personal API keys
3. "Create key" 클릭
4. 생성된 키를 복사 (예: `lin_api_abc123...`)

**주의:** API 키는 절대 Git에 커밋하지 마세요!

### 2. 환경변수 설정

**프로젝트 루트에 `.env` 파일 생성:**

```bash
cp .env.example .env
```

**`.env` 파일 편집:**

```bash
LINEAR_API_KEY=lin_api_YOUR_ACTUAL_KEY_HERE
```

**`.gitignore` 확인:**

`.env` 파일이 Git에 추적되지 않는지 확인:

```bash
grep "^.env$" .gitignore
# 없으면 추가
echo ".env" >> .gitignore
```

### 3. 의존성 설치

```bash
pip install requests python-dotenv
```

또는 `requirements.txt`에 추가:

```txt
requests>=2.31.0
python-dotenv>=1.0.0
```

---

## 사용 방법

### CLI 사용

**Document 생성:**

```bash
python .claude/scripts/linear-api-client.py create \
  --title "API Integration Guide" \
  --content "# Linear API\n\nComplete guide to using Linear API"
```

**Document 업데이트:**

```bash
python .claude/scripts/linear-api-client.py update \
  --id DOC-123 \
  --content "# Updated Content\n\nNew information added"
```

**Document 조회:**

```bash
python .claude/scripts/linear-api-client.py get --id DOC-123
```

**Document 목록:**

```bash
python .claude/scripts/linear-api-client.py list --limit 20
```

**Document 삭제:**

```bash
python .claude/scripts/linear-api-client.py delete --id DOC-123
```

### Python 코드에서 사용

```python
from dotenv import load_dotenv
import os
import sys

# .claude/scripts 경로 추가
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '.claude', 'scripts'))

from linear_api_client import LinearAPIClient

# 환경변수 로드
load_dotenv()
api_key = os.getenv("LINEAR_API_KEY")

# 클라이언트 생성
client = LinearAPIClient(api_key)

# Document 생성
result = client.create_document(
    title="My Document",
    content="# Hello\n\nThis is a document created via API",
    project_id="PROJECT-123"  # Optional
)

print(f"Created document: {result['document']['id']}")
print(f"URL: {result['document']['url']}")

# Document 업데이트
result = client.update_document(
    document_id="DOC-456",
    content="# Updated\n\nNew content here"
)

print(f"Updated at: {result['document']['updatedAt']}")
```

---

## MCP와 함께 사용하기

### 워크플로우 예시: Document 읽고 수정하기

**Step 1: MCP로 Document 조회**

```python
# Claude Code에서 MCP 도구 사용
# mcp__linear-server__get_document(id="DOC-123")
```

**Step 2: 내용 분석 및 수정**

```python
# Claude가 내용을 읽고 수정사항 결정
# 예: "Introduction 섹션에 새로운 예시 추가"
```

**Step 3: API로 Document 업데이트**

```bash
python .claude/scripts/linear-api-client.py update \
  --id DOC-123 \
  --content "$(cat updated-content.md)"
```

### 실제 사용 시나리오

**시나리오 1: Project 문서 자동 생성**

```python
# 1. MCP로 Project 정보 가져오기
# mcp__linear-server__get_project(query="My Project")

# 2. Project 정보를 바탕으로 Document 생성
client = LinearAPIClient(os.getenv("LINEAR_API_KEY"))
result = client.create_document(
    title="Project Overview - My Project",
    content=f"# {project_name}\n\n{project_description}",
    project_id=project_id
)
```

**시나리오 2: Issue 링크가 포함된 Release Notes 생성**

```python
# 1. MCP로 Issue 목록 가져오기
# mcp__linear-server__list_issues(state="Done", limit=50)

# 2. Release Notes 작성
content = "# Release Notes v1.2.0\n\n"
for issue in issues:
    content += f"- {issue['title']} ([{issue['id']}]({issue['url']}))\n"

# 3. Document 생성
client.create_document(
    title="Release Notes v1.2.0",
    content=content
)
```

**시나리오 3: Document 템플릿 적용**

```python
# 템플릿 읽기
with open("templates/project-charter.md", "r") as f:
    template = f.read()

# 변수 치환
content = template.format(
    project_name="New Feature",
    start_date="2025-11-09",
    owner="@username"
)

# Document 생성
client.create_document(
    title="Project Charter - New Feature",
    content=content,
    project_id="PROJECT-789"
)
```

---

## API 제한사항

**Rate Limits:**
- Personal API Key: 1,500 requests/hour per user
- OAuth App: 500 requests/hour per user/app

**권장사항:**
- 대량 작업 시 rate limit 확인
- 429 에러 발생 시 exponential backoff 구현
- 가능한 경우 batch 작업 사용

**보안 주의사항:**
- API 키를 절대 코드에 하드코딩하지 마세요
- `.env` 파일을 Git에 커밋하지 마세요
- 팀 공유 시 `.env.example`만 공유하세요
- API 키가 노출되면 즉시 재발급하세요

---

## 문제 해결

### API 키 오류

```
ERROR: LINEAR_API_KEY not found in environment variables
```

**해결:**
1. `.env` 파일이 존재하는지 확인
2. `.env` 파일에 `LINEAR_API_KEY=...` 설정 확인
3. 환경변수 로드 확인: `python -c "from dotenv import load_dotenv; import os; load_dotenv(); print(os.getenv('LINEAR_API_KEY'))"`

### API 요청 실패

```
API request failed: 401 - Unauthorized
```

**해결:**
1. API 키가 유효한지 확인 (Linear Settings > API에서 확인)
2. API 키 형식 확인: `lin_api_`로 시작해야 함
3. API 키가 만료되지 않았는지 확인

### GraphQL 에러

```
GraphQL errors: Variable "$input" of required type "DocumentUpdateInput!" was not provided
```

**해결:**
- Update 시 최소 1개 필드는 제공해야 함 (title, content, icon 중 하나)
- 예: `--content "New content"` 또는 `--title "New title"`

---

## 추가 리소스

- Linear API 공식 문서: https://developers.linear.app/docs/graphql
- GraphQL Playground: https://studio.apollographql.com/public/Linear-API
- Linear API Schema: https://github.com/linear/linear/blob/master/packages/sdk/src/schema.graphql

---

마지막 업데이트: 2025-11-09
