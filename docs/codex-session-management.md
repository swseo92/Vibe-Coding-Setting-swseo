# Codex Stateful Session Management

**Session ID 기반 멀티턴 대화 가이드**

마지막 업데이트: 2025-11-02

---

## 📋 목차

1. [개요](#개요)
2. [세션 생성](#세션-생성)
3. [세션 ID 관리](#세션-id-관리)
4. [세션 재개](#세션-재개)
5. [병렬 세션 관리](#병렬-세션-관리)
6. [실전 워크플로우](#실전-워크플로우)
7. [세션 파일 구조](#세션-파일-구조)
8. [문제 해결](#문제-해결)

---

## 개요

### Stateful 대화란?

Codex는 **세션 ID 기반 멀티턴 대화**를 지원합니다:

- ✅ 모든 대화 내역이 자동으로 저장
- ✅ 고유한 세션 ID로 식별
- ✅ 언제든 세션 ID로 재개 가능
- ✅ 며칠/몇 주 후에도 맥락 유지

### 언제 사용하나?

**세션 ID 기반 대화가 유용한 경우:**
- 장기 학습 (며칠에 걸쳐 주제 학습)
- 코드 리뷰 반복 (수정 → 재검토 → 재수정)
- 프로젝트 의사결정 (기술 스택 토론 → 구현)
- 병렬 프로젝트 작업 (여러 주제 동시 진행)

---

## 세션 생성

### 기본 방법

```bash
# 대화형 모드로 시작
codex "초기 질문"
```

**출력 예시:**
```
session id: 019a44db-0311-74a3-aa02-cda5de88268b

[Codex 답변...]
```

**중요:** 세션 ID를 반드시 기록하세요!

### 세션 ID 저장 전략

#### 전략 1: 메모 파일

```bash
# 세션 시작 후 ID 저장
echo "019a44db-0311-74a3-aa02-cda5de88268b Python 데코레이터 학습" >> ~/.codex-sessions.txt

# 나중에 참조
cat ~/.codex-sessions.txt
```

#### 전략 2: 프로젝트별 파일

```bash
# 프로젝트 디렉토리에 저장
cd my-project
codex "프로젝트 아키텍처 설계"
# session id를 .codex-session 파일에 저장
echo "019a44db-0311-74a3-aa02-cda5de88268b" > .codex-session

# .gitignore에 추가
echo ".codex-session" >> .gitignore
```

#### 전략 3: 태그 기반 검색

```bash
# 초기 프롬프트에 태그 포함
codex "[AUTH-IMPL] JWT 인증 구현 시작"

# 나중에 grep으로 검색
grep -r "AUTH-IMPL" ~/.codex/sessions/ | grep '"text"'
```

---

## 세션 ID 관리

### 세션 파일 위치

```
~/.codex/sessions/
└── YYYY/
    └── MM/
        └── DD/
            └── rollout-YYYY-MM-DDTHH-MM-SS-[SESSION_ID].jsonl
```

**파일명 구조:**
```
rollout-2025-11-02T22-56-35-019a44db-0311-74a3-aa02-cda5de88268b.jsonl
        └─────┬─────┘ └───────┬───────┘ └─────────────┬────────────────┘
           날짜/시간           시간(초)              세션 ID (UUID)
```

### 세션 찾기

#### 방법 1: 날짜로 찾기

```bash
# 오늘 세션
ls -lt ~/.codex/sessions/2025/11/02/*.jsonl

# 특정 날짜
ls -lt ~/.codex/sessions/2025/10/27/*.jsonl
```

#### 방법 2: 키워드 검색

```bash
# "Django" 키워드로 검색
grep -r "Django" ~/.codex/sessions/ --include="*.jsonl" | grep '"text"'

# 태그로 검색
grep -r "\[AUTH-IMPL\]" ~/.codex/sessions/
```

#### 방법 3: 파일명에서 ID 추출

```bash
# 최근 세션의 ID 추출
ls -t ~/.codex/sessions/2025/11/02/*.jsonl | head -1 | grep -oP '019a[0-9a-f-]+'
```

---

## 세션 재개

### 기본 재개

```bash
# 세션 ID로 재개
codex resume 019a44db-0311-74a3-aa02-cda5de88268b
```

**대화형 프롬프트가 나타남:**
```
Resuming session: 019a44db-0311-74a3-aa02-cda5de88268b
Last message: "데코레이터가 뭔지 간단히 설명해줘."

You: _
```

### 재개 + 새 질문

```bash
# 재개하면서 바로 질문
codex resume 019a44db-0311-74a3-aa02-cda5de88268b "클래스 기반 데코레이터는 어떻게 만들어?"
```

### 프로젝트 기반 재개

```bash
# .codex-session 파일 활용
cd my-project
SESSION_ID=$(cat .codex-session)
codex resume $SESSION_ID
```

**자동화 스크립트:**
```bash
#!/bin/bash
# resume-project.sh

if [ -f .codex-session ]; then
    SESSION_ID=$(cat .codex-session)
    echo "Resuming project session: $SESSION_ID"
    codex resume $SESSION_ID
else
    echo "No session found. Start new session:"
    codex
fi
```

---

## 병렬 세션 관리

### 왜 --last는 위험한가?

**문제 상황:**
```bash
# Terminal 1: 프로젝트 A
cd project-a
codex "FastAPI 설계"
# session id: 019a-aaa...

# Terminal 2: 프로젝트 B
cd project-b
codex "Django 마이그레이션"
# session id: 019a-bbb...

# Terminal 1에서 재개 시도
codex resume --last  # ❌ 프로젝트 B 세션이 열림! (가장 최근)
```

**올바른 방법:**
```bash
# Terminal 1: 세션 ID 저장
cd project-a
codex "FastAPI 설계"
echo "019a-aaa..." > .codex-session

# 나중에 정확한 세션 재개
cd project-a
codex resume $(cat .codex-session)  # ✅ 올바른 세션
```

### 프로젝트별 세션 관리

**디렉토리 구조:**
```
workspace/
├── project-auth/
│   ├── .codex-session          # → 019a-aaa... (JWT 인증)
│   └── src/
├── project-api/
│   ├── .codex-session          # → 019a-bbb... (API 설계)
│   └── src/
└── project-db/
    ├── .codex-session          # → 019a-ccc... (DB 최적화)
    └── migrations/
```

**세션 재개 워크플로우:**
```bash
# 프로젝트 A 작업
cd workspace/project-auth
codex resume $(cat .codex-session)
You: JWT 토큰 갱신 로직 추가해줘

# 프로젝트 B로 전환
cd ../project-api
codex resume $(cat .codex-session)
You: API 엔드포인트 테스트 작성해줘

# 프로젝트 A로 복귀
cd ../project-auth
codex resume $(cat .codex-session)
You: 아까 추가한 토큰 갱신 로직 테스트해줘  # ✅ 맥락 유지
```

### 세션 메모 시스템

**~/.codex-sessions.txt 예시:**
```
# Format: SESSION_ID | PROJECT | TOPIC | DATE
019a-aaa... | project-auth | JWT 인증 구현 | 2025-11-02
019a-bbb... | project-api  | API 엔드포인트 설계 | 2025-11-02
019a-ccc... | project-db   | PostgreSQL 최적화 | 2025-11-01
019a-ddd... | learning     | Python async 학습 | 2025-10-30
```

**Helper 스크립트:**
```bash
#!/bin/bash
# codex-sessions.sh

case "$1" in
    list)
        cat ~/.codex-sessions.txt | column -t -s '|'
        ;;
    add)
        echo "$2 | $3 | $4 | $(date +%Y-%m-%d)" >> ~/.codex-sessions.txt
        ;;
    search)
        grep -i "$2" ~/.codex-sessions.txt
        ;;
    resume)
        SESSION_ID=$(grep "$2" ~/.codex-sessions.txt | cut -d'|' -f1 | tr -d ' ')
        codex resume $SESSION_ID
        ;;
esac
```

**사용 예시:**
```bash
# 세션 추가
./codex-sessions.sh add "019a-aaa..." "project-auth" "JWT 인증"

# 세션 목록
./codex-sessions.sh list

# 검색
./codex-sessions.sh search "JWT"

# 재개
./codex-sessions.sh resume "project-auth"
```

---

## 실전 워크플로우

### 워크플로우 1: 단일 주제 장기 학습

```bash
# Day 1: 시작
$ codex "Python async/await 기초부터 배우고 싶어"
session id: 019a-learn-001
$ echo "019a-learn-001" > ~/.sessions/python-async.txt

# Day 2: 재개
$ SESSION_ID=$(cat ~/.sessions/python-async.txt)
$ codex resume $SESSION_ID
You: asyncio.gather vs wait 차이는?

# Day 3: 계속
$ codex resume $SESSION_ID
You: 실전 프로젝트에 적용하고 싶어
```

### 워크플로우 2: 병렬 프로젝트

```bash
# 프로젝트 A: 인증 시스템
$ cd project-auth
$ codex "JWT 인증 설계"
session id: 019a-auth
$ echo "019a-auth" > .codex-session

# 프로젝트 B: API 개발
$ cd ../project-api
$ codex "REST API 설계"
session id: 019a-api
$ echo "019a-api" > .codex-session

# A 작업
$ cd ../project-auth
$ codex resume $(cat .codex-session)
You: JWT 갱신 로직 추가

# B 작업
$ cd ../project-api
$ codex resume $(cat .codex-session)
You: 페이지네이션 구현

# A로 복귀
$ cd ../project-auth
$ codex resume $(cat .codex-session)
You: 아까 추가한 JWT 갱신, 테스트 작성해줘  # ✅ 맥락 유지
```

### 워크플로우 3: 코드 리뷰 반복

```bash
# 초기 리뷰
$ codex "user_service.py 코드 리뷰"
session id: 019a-review
$ echo "019a-review user_service 리뷰" >> ~/.codex-sessions.txt

# 수정 후 재검토
$ codex resume 019a-review
You: SQL injection 고쳤어, 다시 봐줄래?

# 추가 개선
$ codex resume 019a-review
You: type hints도 추가했어, 확인 부탁해

# 최종 확인
$ codex resume 019a-review
You: 모든 수정 완료, 최종 리뷰 부탁해
```

---

## 세션 파일 구조

### JSONL 형식

세션 파일은 **JSON Lines (JSONL)** 형식:

```jsonl
{"type":"session_meta","payload":{"id":"019a44db-...",...}}
{"type":"response_item","payload":{"role":"user","content":[...]}}
{"type":"response_item","payload":{"role":"assistant","content":[...]}}
```

### 주요 레코드 타입

#### 1. session_meta
```json
{
  "type": "session_meta",
  "payload": {
    "id": "019a44db-0311-74a3-aa02-cda5de88268b",
    "timestamp": "2025-11-02T13:56:35.217Z",
    "cwd": "/path/to/project",
    "cli_version": "0.50.0",
    "git": {
      "commit_hash": "2b7c54a...",
      "branch": "main",
      "repository_url": "https://github.com/..."
    }
  }
}
```

#### 2. response_item (user)
```json
{
  "type": "response_item",
  "payload": {
    "role": "user",
    "content": [{
      "type": "input_text",
      "text": "데코레이터가 뭔지 설명해줘"
    }]
  }
}
```

#### 3. response_item (assistant)
```json
{
  "type": "response_item",
  "payload": {
    "role": "assistant",
    "content": [{
      "type": "output_text",
      "text": "데코레이터는..."
    }]
  }
}
```

### 세션 파일 분석

```bash
# 세션 ID 추출
cat session.jsonl | grep '"id"' | head -1

# 사용자 질문 추출
cat session.jsonl | jq -r 'select(.payload.role=="user") | .payload.content[0].text'

# Codex 답변 추출
cat session.jsonl | jq -r 'select(.payload.role=="assistant") | .payload.content[0].text'

# 전체 대화 복원
cat session.jsonl | jq -r 'select(.type=="response_item") | "\(.payload.role): \(.payload.content[0].text)"'
```

---

## 문제 해결

### Q: 세션 ID를 잃어버렸어요

**해결:**

```bash
# 방법 1: 날짜로 찾기
ls -lt ~/.codex/sessions/2025/11/02/*.jsonl

# 방법 2: 키워드 검색
grep -r "내가 했던 질문" ~/.codex/sessions/

# 방법 3: 파일 내용 확인
for file in ~/.codex/sessions/2025/11/02/*.jsonl; do
    echo "=== $file ==="
    cat "$file" | jq -r 'select(.payload.role=="user") | .payload.content[0].text' | head -3
done
```

### Q: 병렬 세션이 섞여요

**해결:**

```bash
# 프로젝트별로 .codex-session 파일 사용
cd project-a && echo "SESSION_ID_A" > .codex-session
cd project-b && echo "SESSION_ID_B" > .codex-session

# 재개 시 해당 프로젝트 디렉토리에서
cd project-a && codex resume $(cat .codex-session)
```

### Q: 세션이 너무 길어요

**해결:**

```bash
# 적절한 주제로 세션 분리
# Bad: 하나의 세션에 모든 주제
codex "Python 배우기"
You: async 설명
You: 데코레이터 설명
You: 제너레이터 설명
# ... 100개 질문

# Good: 주제별 세션
codex "[PYTHON-ASYNC] async/await 학습"
codex "[PYTHON-DECO] 데코레이터 학습"
codex "[PYTHON-GEN] 제너레이터 학습"
```

### Q: 세션 파일이 너무 많아요

**해결:**

```bash
# 30일 이상 된 세션 정리
find ~/.codex/sessions/ -name "*.jsonl" -mtime +30 -delete

# 특정 월 삭제
rm -rf ~/.codex/sessions/2025/09/

# 용량 확인
du -sh ~/.codex/sessions/
```

### Q: 세션을 팀원과 공유하고 싶어요

**해결:**

```bash
# 세션 파일 export (민감 정보 주의!)
SESSION_ID="019a44db-..."
cp ~/.codex/sessions/2025/11/02/*-${SESSION_ID}.jsonl shared/

# 팀원이 import
cp shared/session.jsonl ~/.codex/sessions/2025/11/02/
codex resume $SESSION_ID
```

---

## Best Practices

### ✅ 추천 방법

1. **세션 ID 반드시 기록**
   ```bash
   # 프로젝트별 .codex-session 파일
   echo "SESSION_ID" > .codex-session
   # .gitignore에 추가
   echo ".codex-session" >> .gitignore
   ```

2. **태그로 세션 구분**
   ```bash
   codex "[PROJECT-A-AUTH] JWT 인증 구현"
   codex "[PROJECT-B-API] REST API 설계"
   codex "[LEARN-PYTHON] Python async 학습"
   ```

3. **병렬 작업 시 --last 피하기**
   ```bash
   # ❌ 위험
   codex resume --last

   # ✅ 안전
   codex resume $(cat .codex-session)
   ```

4. **세션 메모 시스템 활용**
   ```bash
   # ~/.codex-sessions.txt에 기록
   echo "SESSION_ID | project | topic | date" >> ~/.codex-sessions.txt
   ```

5. **정기적 정리**
   ```bash
   # 월 1회 오래된 세션 정리
   find ~/.codex/sessions/ -mtime +60 -delete
   ```

### ❌ 피해야 할 방법

1. **--last에 의존**
   - 병렬 작업 시 잘못된 세션 열림
   - 항상 세션 ID 사용

2. **세션 ID 기록 안 함**
   - 나중에 찾기 어려움
   - 반드시 메모

3. **하나의 세션에 모든 주제**
   - 세션이 너무 길어짐
   - 주제별로 분리

4. **민감 정보 입력**
   - 세션 파일에 그대로 저장됨
   - 비밀번호, API 키 입력 금지

---

## Quick Reference

```bash
# 세션 시작
codex "초기 질문"
# → session id 기록!

# 세션 ID 저장
echo "SESSION_ID" > .codex-session

# 세션 재개
codex resume $(cat .codex-session)

# 세션 찾기
ls -lt ~/.codex/sessions/2025/11/02/*.jsonl
grep -r "키워드" ~/.codex/sessions/

# 세션 정리
find ~/.codex/sessions/ -mtime +30 -delete
```

---

## 참고 자료

### 관련 문서
- [OpenAI Codex 통합 가이드](openai-codex-guide.md) - 전체 Codex CLI 가이드
- [AI Collaborative Solver](.claude/skills/ai-collaborative-solver/skill.md) - 토론 시스템

### 공식 문서
- [OpenAI Codex CLI](https://developers.openai.com/codex/cli/)
- [Codex GitHub](https://github.com/openai/codex)

---

**작성**: 2025-11-02
**검증**: 실제 세션 실험 완료 ✅
**상태**: Production Ready
