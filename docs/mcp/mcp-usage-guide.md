# Claude Code MCP 사용 가이드

> **최종 업데이트:** 2025-01-31
> **원본 문서:** https://docs.claude.com/en/docs/claude-code/mcp

---

## 목차

1. [MCP 개요](#mcp-개요)
2. [설치 방법](#설치-방법)
3. [설정 범위 (Scope)](#설정-범위-scope)
4. [서버 관리](#서버-관리)
5. [설정 파일 형식](#설정-파일-형식)
6. [환경변수 사용](#환경변수-사용)
7. [인증](#인증)
8. [출력 관리](#출력-관리)
9. [리소스 & 프롬프트](#리소스--프롬프트)
10. [엔터프라이즈 설정](#엔터프라이즈-설정)
11. [인기 MCP 서버](#인기-mcp-서버)
12. [문제 해결](#문제-해결)
13. [Windows 전용 설정](#windows-전용-설정)
14. [실전 예제](#실전-예제)

---

## MCP 개요

**Model Context Protocol (MCP)**는 AI와 외부 도구를 연결하는 오픈 표준 프로토콜입니다.

Claude Code는 MCP를 통해 다음 시스템에 접근할 수 있습니다:
- 데이터베이스 (PostgreSQL, Airtable 등)
- API 서비스 (Notion, Linear, GitHub 등)
- 모니터링 시스템 (Sentry 등)
- 클라우드 인프라 (Vercel, Cloudflare 등)
- 결제 시스템 (Stripe, PayPal 등)

---

## 설치 방법

### Transport 타입 3가지

#### 1. HTTP Servers (권장)

클라우드 기반 서비스에 적합:

```bash
claude mcp add --transport http <name> <url>

# 예시
claude mcp add --transport http notion https://mcp.notion.com/mcp
claude mcp add --transport http sentry https://mcp.sentry.dev/mcp
```

#### 2. SSE Servers (Deprecated)

```bash
claude mcp add --transport sse <name> <url>
```

⚠️ **주의:** SSE transport는 deprecated 상태입니다. HTTP를 사용하세요.

#### 3. Local Stdio Servers

로컬에서 실행되는 프로세스:

```bash
claude mcp add --transport stdio <name> -- <command>

# 예시
claude mcp add --transport stdio airtable \
  --env AIRTABLE_API_KEY=YOUR_KEY \
  -- npx -y airtable-mcp-server
```

**중요:** `--` 구분자는 Claude 플래그와 서버 명령어를 분리합니다.

---

## 설정 범위 (Scope)

| Scope | 저장 위치 | 사용 사례 |
|-------|-----------|-----------|
| **Local** (기본) | 사용자 설정, 현재 프로젝트만 | 개인용, 실험용, 민감한 자격증명 |
| **Project** | `.mcp.json` (Git 공유) | 팀 협업, 프로젝트별 공유 서버 |
| **User** | 전역 사용자 설정 | 모든 프로젝트에서 사용하는 도구 |

### Scope 우선순위

```
Local > Project > User
```

동일한 이름의 서버가 여러 scope에 있을 경우, Local이 가장 높은 우선순위를 갖습니다.

### Scope별 등록 예시

```bash
# Local scope (기본)
claude mcp add --transport http myserver https://api.example.com

# Project scope (팀 공유)
claude mcp add --transport http paypal --scope project https://mcp.paypal.com/mcp

# User scope (전역)
claude mcp add --transport http hubspot --scope user https://mcp.hubspot.com/anthropic
```

---

## 서버 관리

### CLI 명령어

```bash
# 모든 서버 목록 보기
claude mcp list

# 특정 서버 상세 정보
claude mcp get <server-name>

# 서버 제거
claude mcp remove <server-name>

# Scope 지정 제거
claude mcp remove <server-name> --scope user
```

### Claude Code 내부 명령어

```bash
# MCP 상태 확인 및 인증
/mcp
```

---

## 설정 파일 형식

### `.mcp.json` 구조

프로젝트 루트의 `.mcp.json` 파일:

```json
{
  "mcpServers": {
    "server-name": {
      "type": "http",
      "url": "https://api.example.com/mcp",
      "headers": {
        "Authorization": "Bearer ${API_TOKEN}"
      }
    },
    "local-server": {
      "command": "npx",
      "args": ["-y", "some-mcp-server"],
      "env": {
        "API_KEY": "${MY_API_KEY}"
      }
    }
  }
}
```

### 필드 설명

- `type`: Transport 타입 (`http`, `sse`, `stdio`)
- `url`: HTTP/SSE 서버 URL
- `command`: stdio 서버 실행 명령어
- `args`: 명령어 인자 배열
- `env`: 환경변수 객체
- `headers`: HTTP 헤더 (인증 등)

---

## 환경변수 사용

### 확장 문법

`.mcp.json`에서 환경변수 참조:

```json
{
  "mcpServers": {
    "myserver": {
      "url": "https://api.example.com",
      "headers": {
        "Authorization": "Bearer ${API_TOKEN}"
      },
      "env": {
        "DATABASE_URL": "${DB_URL:-postgresql://localhost/db}"
      }
    }
  }
}
```

**문법:**
- `${VAR}` - 환경변수 확장
- `${VAR:-default}` - 변수가 없으면 기본값 사용

**지원 위치:**
- `command`
- `args`
- `env`
- `url`
- `headers`

### 환경변수 설정 (Windows)

```powershell
# PowerShell - 영구 설정
[System.Environment]::SetEnvironmentVariable('API_TOKEN', 'your-token', 'User')

# PowerShell - 현재 세션만
$env:API_TOKEN = "your-token"

# CMD - 영구 설정
setx API_TOKEN "your-token"

# CMD - 현재 세션만
set API_TOKEN=your-token
```

---

## 인증

### OAuth 2.0 서버

1. **서버 추가:**
   ```bash
   claude mcp add --transport http sentry https://mcp.sentry.dev/mcp
   ```

2. **Claude Code에서 인증:**
   ```bash
   /mcp
   ```
   이 명령어로 브라우저에서 OAuth 인증을 진행합니다.

3. **자동 토큰 갱신:**
   토큰은 자동으로 갱신되며, 인증 메뉴에서 철회 가능합니다.

---

## 출력 관리

### 토큰 제한

- **경고 임계값:** 10,000 토큰
- **기본 최대값:** 25,000 토큰
- **설정 가능:** `MAX_MCP_OUTPUT_TOKENS` 환경변수

### 제한 변경

```bash
# PowerShell
$env:MAX_MCP_OUTPUT_TOKENS = "50000"
claude

# CMD
set MAX_MCP_OUTPUT_TOKENS=50000
claude

# Bash (WSL/Linux/Mac)
export MAX_MCP_OUTPUT_TOKENS=50000
claude
```

---

## 리소스 & 프롬프트

### MCP 리소스 참조

프롬프트에서 MCP 리소스 참조:

```
@server:protocol://resource/path
```

예시:
```
@notion:notion://database/abc123
```

### MCP 프롬프트 → Slash Command

MCP 서버의 프롬프트는 자동으로 slash command로 변환됩니다:

**형식:** `/mcp__servername__promptname`

예시:
```bash
/mcp__linear__create_issue
```

---

## 엔터프라이즈 설정

### 관리형 설정 파일 위치

관리자가 표준화된 MCP 설정을 배포:

- **macOS:** `/Library/Application Support/ClaudeCode/managed-mcp.json`
- **Windows:** `C:\ProgramData\ClaudeCode\managed-mcp.json`
- **Linux:** `/etc/claude-code/managed-mcp.json`

### 서버 제한

`managed-settings.json`에서 제어:

```json
{
  "allowedMcpServers": ["sentry", "linear", "notion"],
  "deniedMcpServers": ["some-blocked-server"]
}
```

**우선순위:** Denylist가 절대 우선권을 가집니다.

---

## 인기 MCP 서버

### 개발 도구
- **Sentry** - 에러 모니터링
- **Socket** - 보안 분석
- **Hugging Face** - AI 모델
- **Jam** - 버그 리포팅

### 프로젝트 관리
- **Asana** - 태스크 관리
- **Atlassian** - Jira/Confluence
- **Linear** - 이슈 트래킹
- **Notion** - 지식 베이스

### 데이터베이스
- **Airtable** - 협업 데이터베이스
- **PostgreSQL** - stdio 기반

### 결제
- **PayPal**
- **Stripe**
- **Square**

### 인프라
- **Vercel** - 배포
- **Netlify** - 호스팅
- **Cloudflare** - CDN/DNS

**전체 목록:** [MCP Servers GitHub](https://github.com/modelcontextprotocol/servers) (100+ 통합)

---

## 문제 해결

### 1. MCP 상태 확인

```bash
# CLI에서
claude mcp list

# Claude Code 내부
/mcp
```

### 2. 일반적인 설정 실수

#### ❌ Transport 타입 오류

```bash
# 잘못된 예
claude mcp add --transport sse myserver https://api.example.com

# 올바른 예
claude mcp add --transport http myserver https://api.example.com
```

#### ❌ `--` 구분자 누락

```bash
# 잘못된 예
claude mcp add --transport stdio myserver npx server

# 올바른 예
claude mcp add --transport stdio myserver -- npx server
```

#### ❌ Windows에서 npx 직접 실행

```bash
# 잘못된 예 (Connection closed 에러 발생)
claude mcp add --transport stdio myserver -- npx -y @some/package

# 올바른 예
claude mcp add --transport stdio myserver -- cmd /c npx -y @some/package
```

### 3. 인증 문제

OAuth 2.0 서버는 `/mcp` 명령어로 인증:

```bash
# Claude Code 내부에서
/mcp
```

브라우저가 열리면 로그인하고, 토큰은 자동 저장 및 갱신됩니다.

### 4. 환경변수 문제

`.mcp.json`의 환경변수 문법 확인:

```json
{
  "headers": {
    "Authorization": "Bearer ${API_TOKEN}"
  }
}
```

변수가 설정되지 않았으면:

```bash
# 확인
echo $env:API_TOKEN    # PowerShell
echo %API_TOKEN%       # CMD

# 설정
setx API_TOKEN "your-token"
```

### 5. JSON 문법 오류

`.mcp.json` 파일 검증:

```bash
# 온라인 JSON 검증기 사용
# 또는 VS Code에서 파일 열기 (자동 검증)
```

### 6. 출력 토큰 제한 초과

경고 메시지가 나타나면:

```bash
set MAX_MCP_OUTPUT_TOKENS=50000
claude
```

### 7. 검증 단계

1. ✅ `claude mcp list`에 서버가 표시되는지 확인
2. ✅ 서버별 인증 요구사항 확인
3. ✅ `.mcp.json` JSON 문법 검증
4. ✅ 간단한 쿼리로 먼저 테스트
5. ✅ 환경변수가 올바르게 설정되었는지 확인

---

## Windows 전용 설정

### npx 명령어 래퍼 필수

**문제:** Windows에서 `npx`를 직접 실행하면 "Connection closed" 에러 발생

**해결:** `cmd /c` 래퍼 사용

```bash
# ❌ 작동하지 않음
claude mcp add --transport stdio myserver -- npx -y @some/package

# ✅ 올바른 방법
claude mcp add --transport stdio myserver -- cmd /c npx -y @some/package
```

### 경로 구분자

Windows 경로는 백슬래시를 이스케이프:

```json
{
  "mcpServers": {
    "playwright": {
      "command": "cmd",
      "args": [
        "/c",
        "npx",
        "-y",
        "@microsoft/playwright-mcp",
        "--",
        "--user-data-dir",
        "C:\\Users\\EST\\.playwright-persistent"
      ]
    }
  }
}
```

---

## 실전 예제

### 예제 1: Playwright (stdio, Windows)

```bash
claude mcp add --transport stdio microsoft-playwright-mcp --scope user -- cmd /c npx -y @smithery/cli@latest run @microsoft/playwright-mcp --key a457b5a4-cd03-4a13-b2ac-cf99c04f6fc4 -- --user-data-dir "C:\Users\EST\.playwright-persistent"
```

**`.mcp.json` 형식:**

```json
{
  "mcpServers": {
    "microsoft-playwright-mcp": {
      "command": "cmd",
      "args": [
        "/c",
        "npx",
        "-y",
        "@smithery/cli@latest",
        "run",
        "@microsoft/playwright-mcp",
        "--key",
        "a457b5a4-cd03-4a13-b2ac-cf99c04f6fc4",
        "--",
        "--user-data-dir",
        "C:\\Users\\EST\\.playwright-persistent"
      ]
    }
  }
}
```

### 예제 2: Linear (HTTP, OAuth)

```bash
# 1. 서버 추가
claude mcp add --transport http linear --scope user https://mcp.linear.app

# 2. Claude Code에서 인증
/mcp
```

### 예제 3: Notion (HTTP, API Key)

```bash
# 환경변수 설정
setx NOTION_API_KEY "your-notion-api-key"

# 서버 추가
claude mcp add --transport http notion --scope user https://mcp.notion.com/mcp
```

**`.mcp.json` 형식:**

```json
{
  "mcpServers": {
    "notion": {
      "type": "http",
      "url": "https://mcp.notion.com/mcp",
      "headers": {
        "Authorization": "Bearer ${NOTION_API_KEY}"
      }
    }
  }
}
```

### 예제 4: PostgreSQL (stdio, 로컬)

```bash
claude mcp add --transport stdio postgres \
  --env DATABASE_URL="postgresql://user:pass@localhost/db" \
  -- npx -y @modelcontextprotocol/server-postgres
```

### 예제 5: 여러 서버 동시 관리

```json
{
  "mcpServers": {
    "playwright": {
      "command": "cmd",
      "args": ["/c", "npx", "-y", "@microsoft/playwright-mcp"]
    },
    "linear": {
      "type": "http",
      "url": "https://mcp.linear.app"
    },
    "notion": {
      "type": "http",
      "url": "https://mcp.notion.com/mcp",
      "headers": {
        "Authorization": "Bearer ${NOTION_API_KEY}"
      }
    }
  }
}
```

---

## 추가 리소스

- **공식 문서:** https://docs.claude.com/en/docs/claude-code/mcp
- **MCP 서버 목록:** https://github.com/modelcontextprotocol/servers
- **MCP 사양:** https://modelcontextprotocol.io
- **커뮤니티 포럼:** https://community.anthropic.com

---

## 체크리스트

### MCP 서버 추가 전

- [ ] Transport 타입 확인 (http/stdio)
- [ ] 필요한 환경변수 확인
- [ ] API 키/토큰 발급
- [ ] Windows라면 `cmd /c` 래퍼 필요 여부 확인

### 설정 후

- [ ] `claude mcp list`로 등록 확인
- [ ] `/mcp`로 인증 확인
- [ ] 간단한 테스트 쿼리 실행
- [ ] 환경변수 올바르게 설정되었는지 확인

### 문제 발생 시

- [ ] Claude Code 재시작
- [ ] `.mcp.json` JSON 문법 검증
- [ ] 환경변수 확인 (`echo $env:VAR`)
- [ ] 로그 확인 (`/mcp` 출력)
- [ ] 공식 문서 참고

---

**문서 작성자:** Claude Code
**저장소:** Vibe-Coding-Setting-swseo
**관리자:** swseo
