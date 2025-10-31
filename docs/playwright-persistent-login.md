# Playwright Persistent Login 설정 가이드

MCP Playwright에서 브라우저 로그인 상태를 영구적으로 유지하는 방법입니다.

## ✨ 효과

- ✅ **한 번 로그인하면 계속 유지**
- ✅ **Claude Code 재시작 후에도 로그인 상태 유지**
- ✅ **모든 프로젝트에서 같은 브라우저 세션 공유**
- ✅ **GitHub, Google 등 모든 사이트 로그인 자동 유지**

---

## 📋 적용 방법

### 방법 1: 새 프로젝트 (가장 쉬움)

`/init-workspace`를 사용하면 **자동으로 적용**됩니다!

```bash
# 새 프로젝트 디렉토리 생성
mkdir my-new-project
cd my-new-project

# Claude Code 실행
claude

# 작업환경 초기화 (persistent login 자동 적용)
/init-workspace python
```

완료! 이제 브라우저 로그인이 자동으로 유지됩니다.

---

### 방법 2: 기존 프로젝트에 적용

기존 프로젝트의 `.mcp.json` 파일을 수정합니다.

#### 2-1. 파일 위치 확인

```bash
# 프로젝트 루트에 .mcp.json 파일이 있는지 확인
ls -la .mcp.json

# 없으면 생성
```

#### 2-2. .mcp.json 수정

파일을 열어서 다음과 같이 수정:

**올바른 설정:**
```json
{
  "mcpServers": {
    "playwright-mcp": {
      "command": "npx",
      "args": [
        "-y",
        "@playwright/mcp",
        "--user-data-dir",
        "C:\\Users\\EST\\.playwright-persistent"
      ]
    }
  }
}
```

**주요 포인트:**
- ✅ `npx`로 직접 실행 (Smithery wrapper 불필요)
- ✅ `@playwright/mcp` 패키지 사용 (올바른 패키지명)
- ✅ `--user-data-dir` 옵션으로 persistent login 활성화
- ✅ 간단하고 깔끔한 설정

#### 2-3. Claude Code 재시작

```bash
# Claude Code 종료
exit

# 다시 시작
claude
```

완료! 이제 브라우저 로그인이 유지됩니다.

---

### 방법 3: 다른 사용자 또는 다른 컴퓨터

**경로 수정 필요:**

```json
"--user-data-dir",
"C:\\Users\\EST\\.playwright-persistent"
```

이 부분을 사용자 환경에 맞게 변경:

**Windows:**
```json
"--user-data-dir",
"C:\\Users\\[사용자이름]\\.playwright-persistent"
```

**macOS/Linux:**
```json
"--user-data-dir",
"/home/[사용자이름]/.playwright-persistent"
```

또는 환경변수 사용:

**Windows:**
```json
"--user-data-dir",
"%USERPROFILE%\\.playwright-persistent"
```

**macOS/Linux:**
```json
"--user-data-dir",
"$HOME/.playwright-persistent"
```

---

## 🧪 작동 확인

### 1. 브라우저 열기

Claude Code에서:

```
브라우저로 https://github.com 접속해줘
```

### 2. 로그인

브라우저 창에서 수동으로 로그인합니다.

### 3. 브라우저 닫기

```
브라우저 닫아줘
```

### 4. 다시 열기

```
브라우저로 https://github.com 접속해줘
```

### 5. 확인

**성공**: 로그인 상태로 Dashboard 표시됨
**실패**: 로그인 페이지로 이동됨

---

## 🔧 문제 해결

### 문제 1: 로그인 상태가 유지되지 않음

**원인**: 설정이 적용되지 않았거나 Claude Code를 재시작하지 않음

**해결:**
1. `.mcp.json` 파일 확인 (위 형식과 동일한지)
2. Claude Code 완전히 종료 후 재시작
3. 다시 테스트

### 문제 2: "user-data-dir" 폴더를 찾을 수 없음

**원인**: 경로가 잘못되었거나 폴더가 없음

**해결:**
1. 경로 확인 (Windows: `C:\Users\사용자이름\`, macOS/Linux: `/home/사용자이름/`)
2. 폴더는 자동으로 생성되므로 미리 만들 필요 없음
3. 경로에 한글이나 공백이 있으면 문제가 될 수 있음

### 문제 3: 여러 프로젝트에서 다른 계정 사용하고 싶음

**현재 설정**: 모든 프로젝트가 같은 브라우저 프로필 공유

**해결 방법**:

**프로젝트별로 다른 프로필 사용:**
```json
"--user-data-dir",
"C:\\Users\\EST\\.playwright-persistent-project1"
```

각 프로젝트의 `.mcp.json`에 다른 경로 지정:
- Project A: `.playwright-persistent-accountA`
- Project B: `.playwright-persistent-accountB`

---

## 📁 브라우저 데이터 위치

### 저장되는 내용

`C:\Users\EST\.playwright-persistent\` 폴더에 저장됨:
- 쿠키 (로그인 세션)
- localStorage
- sessionStorage
- 브라우저 히스토리
- 캐시
- 다운로드 히스토리
- 확장 프로그램 (있는 경우)

### 데이터 삭제 (로그인 상태 초기화)

```bash
# Windows
rmdir /s C:\Users\EST\.playwright-persistent

# macOS/Linux
rm -rf ~/.playwright-persistent
```

다음 브라우저 실행 시 깨끗한 상태로 시작됩니다.

---

## 🔒 보안 주의사항

### ⚠️ 민감한 정보

`.playwright-persistent` 폴더에는 로그인 세션 정보가 저장됩니다.

**주의:**
- ❌ Git에 커밋하지 마세요
- ❌ 다른 사람과 공유하지 마세요
- ❌ 공용 컴퓨터에서 사용 시 주의
- ✅ 개인 컴퓨터에서만 사용 권장

### .gitignore 설정

프로젝트 루트의 `.gitignore`에 추가:

```
# Playwright persistent data
.playwright-persistent/
```

---

## ✅ 장점 vs 단점

### 장점

- ✅ 매번 로그인할 필요 없음
- ✅ 자연스러운 브라우저 경험
- ✅ 모든 사이트 지원
- ✅ 설정 한 번이면 끝

### 단점

- ❌ 민감한 정보가 로컬에 저장됨
- ❌ 모든 프로젝트가 같은 계정 공유 (기본 설정)
- ❌ 세션 만료되면 수동 재로그인 필요

---

## 📚 관련 자료

- [Playwright Persistent Context 문서](https://playwright.dev/docs/api/class-browsertype#browser-type-launch-persistent-context)
- [MCP Playwright GitHub](https://github.com/microsoft/playwright-mcp)

---

**마지막 업데이트**: 2025-10-27
**작성자**: Claude Code Assistant
