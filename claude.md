# Vibe-Coding-Setting

**이 디렉토리는 개발환경 설정 관리 저장소입니다.**

Claude Code를 활용한 개인 개발환경 설정 및 프로젝트 템플릿을 중앙에서 관리합니다.

---

## ⚠️ CRITICAL: 필수 규칙

**작업 시작 전 반드시 읽어야 할 규칙:**

### 1. 임시 파일/폴더 생성 규칙 (MANDATORY)

**🚨 모든 임시/테스트/실험용 파일과 폴더는 반드시 `tmp/` 폴더에만 생성합니다.**

- ✅ **DO**: `tmp/test-feature.py`, `tmp/experiment/`, `tmp/report.md`
- ❌ **NEVER**: `test-feature.py`, `experiment/`, `report.md` (루트에 직접 생성 금지)

**이유:** 보안 리스크, Git 오염, 관리 불가 방지 (AI 토론 검증됨, 85% 신뢰도)

**자세한 내용:** [임시 파일/폴더 관리 규칙](#️-important-임시-파일폴더-관리-규칙) 섹션 참조

### 2. 커밋 전 확인사항

**변경사항을 커밋하기 전에 이 문서(`claude.md`)를 검토하고 필요시 업데이트하세요.**

- 새로운 명령어를 추가했다면 → "주요 커맨드" 섹션 업데이트
- 새로운 템플릿을 추가했다면 → "디렉토리 구조" 섹션 업데이트
- 새로운 워크플로우가 추가되었다면 → "사용 시나리오" 섹션 업데이트
- 주요 기능이 변경되었다면 → "저장소 목적" 섹션 검토

**이 문서는 저장소의 "사용 설명서"입니다. 항상 최신 상태를 유지해주세요.**

---

## ⚠️ 프로젝트 루트 폴더 규칙

**이 `CLAUDE.md` 파일이 위치한 폴더가 이 저장소의 루트(root) 디렉토리입니다.**

### 작업 범위 제한
- ✅ 모든 작업은 **이 루트 폴더를 기준**으로 수행됩니다
- ✅ 파일 경로는 **이 루트 폴더 기준 상대 경로** 또는 절대 경로를 사용합니다
- ❌ **상위 폴더(`../`)는 절대 참조하지 않습니다**
- ❌ 이 저장소 외부 파일은 수정하거나 참조하지 않습니다

### Claude Code 작업 가이드라인
```
Vibe-Coding-Setting-swseo/  ← 이 CLAUDE.md가 위치한 폴더 (저장소 루트)
├── CLAUDE.md               ← 현재 파일 (저장소 루트 마커)
├── .claude/                ← ✅ 접근 가능
├── .specify/               ← ✅ 접근 가능
├── templates/              ← ✅ 접근 가능
├── docs/                   ← ✅ 접근 가능
└── ...                     ← ✅ 루트 하위 모든 파일 접근 가능

../                         ← ❌ 상위 폴더 접근 금지
../../                      ← ❌ 상위의 상위 폴더 접근 금지
```

**중요**: Claude Code는 이 규칙을 엄격히 준수해야 합니다. 저장소 범위를 벗어난 작업은 수행하지 않습니다.

---

## 저장소 목적

1. **Claude Code 설정 중앙 관리** - agents, commands, personas, scripts 등
2. **언어별 프로젝트 템플릿 제공** - Python, JavaScript 등
3. **작업환경 빠른 구성** - 새 프로젝트 시작 시 자동 초기화
4. **Speckit 통합** - 스펙 기반 개발 워크플로우

---

## 디렉토리 구조

```
Vibe-Coding-Setting-swseo/
├── .claude/                      # Claude Code 설정 (전역에서 사용)
│   ├── agents/                   # 커스텀 에이전트 (2개)
│   ├── commands/                 # 슬래시 커맨드 (15개)
│   ├── personas/                 # 페르소나 (2개)
│   ├── scripts/                  # 유틸리티 스크립트
│   │   ├── init-workspace.sh     # 프로젝트 초기화 (Unix)
│   │   └── init-workspace.ps1    # 프로젝트 초기화 (Windows)
│   ├── skills/                   # 스킬 (17개)
│   └── settings.local.json       # 전역 설정 템플릿
│
├── .specify/                     # Speckit 템플릿 & 스크립트 (전역)
│   ├── memory/                   # 프로젝트 헌법
│   ├── scripts/bash/             # 자동화 스크립트
│   └── templates/                # 스펙/플랜/태스크 템플릿
│
├── docs/                         # 문서
│   └── python/                   # Python 관련 문서
│       └── testing_guidelines.md
│
├── templates/                    # 언어별 프로젝트 템플릿
│   ├── common/                   # 공통 템플릿 (모든 프로젝트)
│   │   ├── .claude/              # 프로젝트 로컬 설정만
│   │   │   ├── scripts/          # Hook 스크립트 (경로 의존적)
│   │   │   │   ├── notify.py     # 알림 TTS 스크립트
│   │   │   │   ├── run-notify.cmd  # Windows wrapper
│   │   │   │   └── run-notify.sh   # Unix wrapper
│   │   │   └── settings.json     # Hook 설정 (경로 의존적)
│   │   ├── .specify/             # Speckit 기본 구조
│   │   ├── .mcp.json             # MCP 설정
│   │   └── claude.md             # 프로젝트 마커 템플릿 (기본)
│   │
│   └── python/                   # Python 템플릿
│       ├── claude.md             # Python 프로젝트 마커 (환경변수 가이드 포함)
│       ├── pyproject.toml        # uv 설정
│       ├── .env.example          # 환경변수 템플릿
│       ├── .gitignore
│       ├── pytest.ini
│       ├── README.md
│       ├── src/                  # 소스 코드 디렉토리
│       └── tests/                # 테스트 구조
│
├── speckit/                      # Speckit 원본 (GitHub에만 보관)
│   ├── .claude/commands/         # Speckit 커맨드
│   └── .specify/                 # Speckit 템플릿
│
└── claude.md                     # 이 문서
```

### 설정 파일 분리 원칙

**프로젝트 로컬 (.claude/ in project):**
- 경로 의존적 파일만 (상대경로 사용)
- `settings.json` - Hook 설정 (.claude/scripts 참조)
- `scripts/` - Hook 스크립트 (notify.py 등)

**전역 공유 (~/.claude/):**
- 경로 독립적 파일 (모든 프로젝트 공유)
- `commands/` - 슬래시 커맨드
- `agents/` - 에이전트
- `skills/` - 스킬
- `personas/` - 페르소나
- `scripts/` - 유틸리티 스크립트 (init-workspace.sh 등)

---

## 주요 커맨드

### `/apply-settings`
**Vibe-Coding-Setting 저장소에서만 사용** - 로컬 변경사항을 전역으로 적용

```bash
/apply-settings
```

**동작:**
- `.claude/` 전체 → `~/.claude/` (commands, agents, skills, personas, scripts 등)
- `settings.local.json` → `~/.claude/settings.json`
- `.specify/` → `~/.specify/`

**사용 시기:**
- ✅ Vibe-Coding-Setting 저장소에서 직접 명령어/스킬을 수정한 후
- ✅ 전역 설정을 처음 설치할 때
- ✅ `~/.claude/`가 손상되었거나 초기화하고 싶을 때

**특징:**
- 로컬 → 전역 복사만 (GitHub에서 가져오지 않음)
- 프로젝트 파일은 건드리지 않음
- Vibe-Coding-Setting 저장소 전용

### `/init-workspace`
새 프로젝트에 언어별 템플릿을 적용하고 전역 설정을 확인합니다.

```bash
/init-workspace python
/init-workspace javascript
```

**동작:**
1. GitHub에서 이 repo clone (임시 디렉토리)
2. **프로젝트 로컬** 파일 복사:
   - `templates/common/.claude/` (settings.json, scripts/)
   - `templates/common/.specify/`
   - `templates/{언어}/` 파일들
3. **전역 설정 확인**:
   - `~/.claude/commands/`가 없으면 사용자에게 알림
   - `/apply-settings` 수동 실행 안내
4. 의존성 설치 안내

**복사되는 것:**
- ✅ 프로젝트: .claude/settings.json, .claude/scripts/, .specify/, 언어별 템플릿
- ❌ 복사 안 됨: commands, agents, skills, personas (전역에서 공유)

### `/sync-workspace`
**모든 프로젝트에서 사용** - GitHub 최신 버전으로 자동 업데이트

```bash
/sync-workspace              # 프로젝트 + 전역 모두 업데이트 (권장)
/sync-workspace --local-only # 프로젝트만 (전역 설정 유지)
/sync-workspace --global-only # 전역만 (프로젝트 파일 유지)
```

**동작:**
1. **GitHub에서** 최신 Vibe-Coding-Setting repo clone (자동)
2. **프로젝트 로컬** 동기화:
   - `.claude/settings.json` 업데이트 (덮어쓰기)
   - `.claude/scripts/` 업데이트 (덮어쓰기, 삭제 안 함)
   - `.specify/` 업데이트 (덮어쓰기, 삭제 안 함)
3. **전역 설정** 동기화 (자동):
   - `~/.claude/` 전체 업데이트 (commands, agents, skills, personas)
   - `~/.specify/` 업데이트
4. 백업 옵션 제공 (선택사항)

**특징:**
- ✅ GitHub 최신 버전 자동 가져오기
- ✅ 한 번 실행으로 모든 프로젝트에 최신 명령어 적용
- ✅ 프로젝트별 커스터마이징 보존 (기존 파일 삭제 안 함)
- ✅ 변경사항 미리보기 + 백업 옵션
- ✅ 어떤 프로젝트에서든 실행 가능

**차이점:**
- `/apply-settings`: 로컬 → 전역 (수동 수정 후)
- `/sync-workspace`: GitHub → 로컬 + 전역 (자동 업데이트)

### `/merge`
브랜치를 merge하고 conflict를 자동으로 해결합니다.

```bash
/merge <source-branch> --into <target-branch>
/merge <source-branch>  # 현재 브랜치에 merge
```

**동작:**
- Safety checks (working tree, 브랜치 존재 확인)
- 자동 merge 시도
- Conflict 발생 시 자동 해결 (또는 사용자 확인)
- Post-merge 검증 (테스트, 린터 등)

**주요 기능:**
- ✅ 자동 conflict 해결 (단순 패턴)
- ✅ 복잡한 conflict는 사용자 확인
- ✅ 상세한 merge 요약 제공
- ✅ Todo 기반 진행상황 추적

### 기타 커맨드
- `/worktree-*` - Git worktree 관리
- `/speckit.*` - 스펙 기반 개발 워크플로우
- `/persona` - 페르소나 관리
- `/meta-test` - 메타 테스팅

---

## 사용 시나리오

### 1. 처음 설정 (전역 설정 설치)

```bash
# Vibe-Coding-Setting 저장소 clone
git clone https://github.com/swseo92/Vibe-Coding-Setting-swseo.git
cd Vibe-Coding-Setting-swseo

# Claude Code 실행
claude

# 전역 설정 적용 (~/.claude/, ~/.specify/)
/apply-settings

# 이제 모든 프로젝트에서 slash commands 사용 가능!
```

### 2. 새 Python 프로젝트 시작

```bash
# 새 프로젝트 디렉토리 생성
mkdir my-new-api
cd my-new-api

# Claude Code 실행
claude

# 작업환경 초기화 (프로젝트 로컬 파일 + 전역 설정 확인)
/init-workspace python

# 의존성 설치
uv sync

# 개발 시작!
```

### 3. 기존 프로젝트 업데이트

```bash
cd existing-project

# 프로젝트 로컬 + 전역 설정 모두 최신화
/sync-workspace

# 또는 전역 설정만 업데이트 (프로젝트 파일은 유지)
/sync-workspace --global-only
```

### 4. Vibe-Coding-Setting 저장소 업데이트 후

```bash
# Vibe-Coding-Setting 저장소에서
cd ~/Vibe-Coding-Setting-swseo
git pull

# 전역 설정에 반영
/apply-settings

# 또는 다른 프로젝트에서
cd ~/my-api-project
/sync-workspace --global-only  # 전역만 업데이트
```

---

## 템플릿 특징

### Python 템플릿

**포함된 기능:**
- ✅ **환경변수 관리 가이드** - `python-dotenv` 사용법 및 보안 베스트 프랙티스
- ✅ **`.env.example`** - 환경변수 템플릿 (실제 `.env`는 Git 무시)
- ✅ **uv 기반 의존성 관리** - 빠른 패키지 설치 및 가상환경 관리
- ✅ **pytest 설정** - 테스트 프레임워크 및 커버리지 설정
- ✅ **타입 힌팅 권장** - mypy 설정 및 사용 가이드
- ✅ **코드 품질 도구** - black, ruff, mypy 설정

**환경변수 관리 (핵심 기능):**
```python
# 모든 Python 프로젝트에서 권장하는 방법
from dotenv import load_dotenv
import os

load_dotenv()  # .env 파일에서 환경변수 로드
DATABASE_URL = os.getenv("DATABASE_URL")
```

**사용 시나리오:**
- FastAPI/Flask 웹 애플리케이션
- 데이터 분석/ML 프로젝트
- CLI 도구
- 라이브러리 개발

---

## 템플릿 추가 방법

### 새 언어 템플릿 추가

1. `templates/{언어}/` 폴더 생성
2. 기본 파일 구조 작성
   - `claude.md` - 프로젝트 마커 (언어별 가이드 포함)
   - `README.md` - 사용법
   - 설정 파일들 (package.json, Cargo.toml 등)
   - `.gitignore`
   - `.env.example` (환경변수 사용 시)
3. `/init-workspace` 명령어에 언어 추가
4. `claude-md-manager` 스킬의 `template-sections.md`에 언어별 예시 추가

**언어별 환경변수 라이브러리:**
- **Python**: `python-dotenv`
- **JavaScript/Node**: `dotenv`
- **Rust**: `dotenv` crate
- **Go**: `godotenv`

예시:
```
templates/
├── python/       # ✅ 완료 (환경변수 가이드 포함)
├── javascript/   # TODO
├── rust/         # TODO
└── go/           # TODO
```

---

## Hook 설정 (알림 기능)

**모든 템플릿에는 작업 완료 시 TTS 알림을 제공하는 hook이 포함되어 있습니다.**

### 작동 방식

1. **상대경로 기반**: `.claude/scripts/run-notify.cmd` (Windows 기본)
2. **자동 트리거**: Claude Code 세션 종료 또는 알림 이벤트 시 자동 실행
3. **폴더 이름 인식**: 현재 작업 중인 폴더 이름을 음성으로 알려줌

### 설정 파일

**`templates/common/.claude/settings.json`**:
```json
{
  "hooks": {
    "Notification": [{
      "matcher": "",
      "hooks": [{
        "type": "command",
        "command": ".claude/scripts/run-notify.cmd \"작업 완료\""
      }]
    }],
    "Stop": [{
      "hooks": [{
        "type": "command",
        "command": ".claude/scripts/run-notify.cmd \"작업 완료\""
      }]
    }]
  }
}
```

### Hook 스크립트

- **`notify.py`**: 크로스 플랫폼 TTS 알림 (Windows/Mac/Linux)
- **`run-notify.cmd`**: Windows wrapper (기본 설정)
- **`run-notify.sh`**: Unix/Linux/Mac wrapper

**참고:**
- 기본적으로 `.cmd` 스크립트를 사용합니다 (Windows 환경 기준)
- Unix/Mac 환경에서는 `.claude/settings.json`의 command를 `.sh`로 수정하세요

### 플랫폼별 수정 (필요시)

**Unix/Mac 환경:**
프로젝트의 `.claude/settings.json`에서:
```json
"command": ".claude/scripts/run-notify.sh \"작업 완료\""
```

### 커스터마이징

알림 메시지를 변경하려면:
```json
"command": ".claude/scripts/run-notify.cmd \"원하는 메시지\""
```

알림을 비활성화하려면 `.claude/settings.json`에서 `hooks` 섹션을 제거하세요.

---

## Playwright MCP 설정

**MCP Playwright를 사용하여 브라우저 자동화를 수행할 수 있습니다.**

### 자동 적용

`/init-workspace`로 새 프로젝트를 만들면 **자동으로 적용**됩니다!

템플릿에 이미 설정이 포함되어 있어서 별도 작업 불필요.

### 기존 프로젝트에 적용

기존 프로젝트의 `.mcp.json` 파일을 다음과 같이 작성:

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
        "a457b5a4-cd03-4a13-b2ac-cf99c04f6fc4"
      ]
    }
  }
}
```

**중요**:
- Smithery CLI wrapper를 통해 실행
- `@microsoft/playwright-mcp` 패키지 사용
- 설정 변경 후 Claude Code 재시작 필수
- **주의**: `--user-data-dir` 옵션은 Smithery wrapper와 호환되지 않으므로 사용하지 마세요

### 상세 가이드

전체 설정 방법, 문제 해결, 보안 주의사항은 다음 문서 참조:
- [`docs/playwright-persistent-login.md`](docs/playwright-persistent-login.md)

---

## 커스텀 커맨드 추가

1. `.claude/commands/` 폴더에 `.md` 파일 작성
2. `/apply-settings` 실행하여 전역 설정에 반영
3. 모든 프로젝트에서 사용 가능

---

## 설정 업데이트 워크플로우

```bash
# 1. 이 repo에서 설정 수정
cd ~/Vibe-Coding-Setting-swseo
# .claude/commands/my-command.md 수정

# 2. 전역 설정에 적용
/apply-settings

# 3. GitHub에 푸시
git add .
git commit -m "Update command"
git push

# 4. 다른 머신에서 가져오기
git pull
/apply-settings
```

---

## ⚠️ IMPORTANT: 임시 파일/폴더 관리 규칙

**CRITICAL RULE: 모든 임시 파일과 폴더는 MUST be created in `tmp/` directory ONLY.**

### Why This Rule Exists (보안 & 관리)

AI 토론 결과 (신뢰도 85%):
- **보안 위험**: 무분별한 파일 생성 → 정보 유출, 디스크 고갈 DoS 취약점
- **관리 불가**: 200+ 임시 파일 생성 시 중요 파일 구분 불가
- **Git 오염**: 불필요한 파일이 저장소에 추적됨
- **감사 어려움**: 분산된 임시 파일로 인한 유지보수 복잡도 증가

### MANDATORY tmp/ 폴더 규칙

**모든 임시 생성물은 `tmp/` 폴더에만 생성합니다:**

```bash
# ✅ CORRECT: tmp/ 폴더 내부에 생성
mkdir -p tmp/test-python-template
cp -r templates/python/* tmp/test-python-template/
cd tmp/test-python-template
uv sync
pytest

# ✅ CORRECT: 정리
cd ../..
rm -rf tmp/test-python-template
```

```bash
# ❌ WRONG: 루트에 직접 생성 (절대 금지)
mkdir test-project        # ❌ NEVER DO THIS
touch test-script.py      # ❌ NEVER DO THIS
```

### 적용 대상 (All Temporary Artifacts)

**MUST use `tmp/` for ALL of the following:**

| 유형 | 설명 | 올바른 위치 | 잘못된 위치 |
|------|------|-------------|-------------|
| **테스트 스크립트** | `test-*.py`, `*_test.py` | `tmp/test-feature.py` | `test-feature.py` ❌ |
| **실험용 폴더** | E2E 테스트, 세션 폴더 | `tmp/e2e-test-1/` | `e2e-test-1/` ❌ |
| **리포트/분석** | `*-report.md`, `*-analysis.md` | `tmp/feature-report.md` | `feature-report.md` ❌ |
| **세션 데이터** | `debate-session/`, `test-session/` | `tmp/debate-session/` | `debate-session/` ❌ |
| **임시 출력** | `.test-outputs/`, `.debug/` | `tmp/.test-outputs/` | `.test-outputs/` ❌ |
| **백업 파일** | `*.backup`, `*.bak` | `tmp/config.backup` | `config.backup` ❌ |
| **임시 데이터** | JSON, log, CSV 등 실험 데이터 | `tmp/test-data.json` | `test-data.json` ❌ |

### 강제 규칙 (Enforcement Rules)

**BEFORE creating any file/folder, ASK:**

1. **Is this temporary or experimental?** → `tmp/`
2. **Is this for testing a feature?** → `tmp/`
3. **Will this be deleted later?** → `tmp/`
4. **Is this a one-time analysis?** → `tmp/`

**ONLY create in root directory if:**
- ✅ It's a permanent project configuration (`claude.md`, `.gitignore`, `pytest.ini`)
- ✅ It's official documentation (`README.md`, `docs/`)
- ✅ It's a production template (`templates/`)

**When in doubt → USE `tmp/`**

### 올바른 사용 패턴

```bash
# ✅ Pattern 1: 기능 테스트
tmp/
├── feature-auth-test/
│   ├── test_auth.py
│   ├── mock_data.json
│   └── results.log

# ✅ Pattern 2: 실험
tmp/
├── experiment-caching/
│   ├── benchmark.py
│   ├── cache-report.md
│   └── performance.csv

# ✅ Pattern 3: 토론/분석
tmp/
└── debate-session-20251102/
    ├── round1.txt
    ├── round2.txt
    └── summary.md
```

### 정리 가이드 (Cleanup Guide)

**정기적 정리:**

```bash
# 전체 tmp/ 정리 (주의: 모든 내용 삭제)
rm -rf tmp/*

# 특정 패턴만 정리
rm -rf tmp/test-*
rm -rf tmp/*-session/
rm -f tmp/*.md

# 7일 이상 된 파일만 삭제
find tmp/ -mtime +7 -delete
```

**`.gitignore` 확인:**

```bash
# tmp/ 폴더가 이미 .gitignore에 포함되어 있는지 확인
grep "^tmp/" .gitignore

# 없으면 추가
echo "tmp/" >> .gitignore
```

### 위반 시 결과 (Violation Consequences)

**If you create files outside `tmp/`:**

1. **즉시 정리 필요** - 사용자가 수동으로 200+ 파일 검토/삭제
2. **Git 오염** - 불필요한 파일이 untracked files로 나타남
3. **보안 리스크** - 민감 데이터가 의도치 않게 노출될 수 있음
4. **저장소 신뢰도 저하** - 프로젝트 구조 파악 불가

### 예외 처리 (Legitimate Exceptions)

**드문 경우지만, 다음의 경우 루트 생성 허용:**

1. **영구적 설정 파일** - `pyproject.toml`, `pytest.ini` 등
2. **공식 문서** - `README.md`, `CHANGELOG.md`
3. **프로덕션 코드** - `src/`, `tests/` (영구 테스트 코드)

**이런 경우에도 먼저 사용자에게 확인 요청!**

### Quick Reference

```bash
# ✅ DO: Always use tmp/
mkdir -p tmp/my-test
cd tmp/my-test
python test.py

# ❌ DON'T: Never create in root
mkdir my-test          # WRONG
touch test.py          # WRONG
```

**Remember: When in doubt, use `tmp/`**

---

**AI 토론 근거:** Gemini 2.5 Pro 분석 (balanced mode, 4 rounds, 85% confidence)

---

## 주의사항

### speckit/ 폴더
- **GitHub**: 유지 (원본 참조용)
- **로컬 복제 시**: 삭제 (중복 방지)
- `.specify/`에 이미 복사본 존재

### claude.md 위치
- **루트 claude.md**: 이 설정 repo 설명 (현재 문서)
- **templates/{언어}/claude.md**: 각 언어 프로젝트용 마커

### 설정 동기화
- `settings.local.json` 사용 권장 (로컬 환경 설정)
- `settings.json`은 공통 설정용

---

## 참고 자료

- [Claude Code 공식 문서](https://docs.claude.com/claude-code)
- [uv 공식 문서](https://docs.astral.sh/uv/)
- [Speckit GitHub](https://github.com/example/speckit)

---

**마지막 업데이트**: 2025-11-04
**관리자**: swseo
**저장소**: https://github.com/swseo92/Vibe-Coding-Setting-swseo

---

## 변경 이력

### 2025-11-04
- ✅ `claude-md-manager` 스킬 추가 (커밋 전 자동 claude.md 품질 검증)
- ✅ Python 템플릿에 환경변수 관리 가이드 추가 (`python-dotenv` 사용법)
- ✅ `templates/python/claude.md` 생성 (Python 프로젝트 전용 가이드)
- ✅ `claude-md-manager` 템플릿에 환경변수 베스트 프랙티스 추가 (Python, JavaScript)

### 2025-11-02
- 임시 파일 관리 규칙 추가 (AI 토론 기반, 85% 신뢰도)
