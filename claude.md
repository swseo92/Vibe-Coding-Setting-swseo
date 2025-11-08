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

### 2. 이모지 사용 금지 규칙 (MANDATORY)

**CRITICAL: Claude는 모든 응답에서 이모지를 사용하지 않습니다.**

- ❌ **NEVER**: 이모지를 텍스트에 포함 (✅, ❌, 🚨, 📄 등 모든 이모지)
- ✅ **DO**: 순수 텍스트만 사용 (ASCII 문자, 마크다운 기호는 허용)
- **이유**:
  - Context(토큰) 낭비 - 이모지는 여러 토큰을 소비
  - 가독성 저하 - 텍스트 복사/붙여넣기 시 이모지가 방해
  - 전문성 - 업무용 출력물에서는 이모지 없는 것이 더 professional

**유일한 예외**: 사용자가 명시적으로 "이모지를 사용해줘" 라고 요청한 경우에만

### 3. 커밋 전 확인사항

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

## 📚 문서 구조 및 Context 탐색 가이드

**이 저장소는 계층적 README + 중앙 인덱스 하이브리드 시스템을 사용합니다.**

### 문서 탐색 프로토콜 (Claude Code 에이전트용)

**새로운 작업을 시작할 때 다음 순서로 문서를 읽으세요:**

1. **프로젝트 개요 파악**:
   - 📄 `CLAUDE.md` (이 파일) - 저장소 전체 목적 및 구조
   - 📄 `README.md` - 프로젝트 소개 및 빠른 시작

2. **중앙 인덱스 확인** (있을 경우):
   - 📄 `docs/index.md` - 전체 문서 분류 및 빠른 참조
   - 작업 타입에 해당하는 카테고리 식별 (Architecture, API, Guides 등)

3. **관련 폴더 README 읽기**:
   - 작업할 모듈의 `[폴더]/README.md` 참조
   - 예: `.claude/commands/` 작업 시 → `.claude/commands/README.md` (있을 경우)

4. **세부 문서 탐색**:
   - `docs/` 내부의 관련 가이드, 스펙 문서
   - 예: `docs/readme-config-spec.md`, `docs/recursive-readme-guide.md`

### 작업 유형별 문서 경로 예시

| 작업 유형 | 읽어야 할 문서 | 우선순위 |
|-----------|----------------|----------|
| **새 슬래시 커맨드 추가** | `.claude/commands/` 예시 파일, `CLAUDE.md` > "커스텀 커맨드 추가" | 높음 |
| **새 스킬 작성** | `.claude/skills/skill-creator/` README, `CLAUDE.md` > "주요 커맨드" | 높음 |
| **Python 템플릿 수정** | `templates/python/claude.md`, `docs/python/testing_guidelines.md` | 중간 |
| **문서 시스템 이해** | `docs/index.md`, `docs/readme-config-spec.md` | 중간 |
| **Speckit 워크플로우** | `.specify/README.md`, `CLAUDE.md` > "주요 커맨드" | 낮음 |

### Token 최적화 팁

**❌ 비효율적인 방법**:
- 모든 README를 순차적으로 읽기 (50+ 파일, 100K+ tokens)
- 관련 없는 폴더의 문서까지 탐색

**✅ 효율적인 방법**:
1. `docs/index.md` 먼저 읽기 (전체 개요 파악)
2. "Quick Reference" 섹션에서 작업 타입 검색
3. 명시된 2-3개 문서만 읽기
4. 필요시 추가 탐색

**예시 (인증 기능 추가)**:
```
1. docs/index.md 읽기 (5K tokens)
2. "Quick Reference" → "Authentication" 발견
3. 권장 문서만 읽기:
   - src/auth/README.md (3K tokens)
   - docs/architecture/security.md (4K tokens)
4. 총 12K tokens (기존 100K 대비 88% 절감)
```

### 문서 생성 및 관리

**계층적 README 생성**:
```bash
# 초기 설정
/documentation-manager --init-config

# README 자동 생성 (각 폴더별)
/documentation-manager --recursive-readme

# 중앙 인덱스 생성
/docs-generate-index
```

**문서 검증**:
```bash
# 기존 README 품질 체크
/documentation-manager --check-recursive
```

**자동화 (CI/CD)**:
- README 변경 시 자동으로 `docs/index.md` 업데이트
- 상세: `.claude/commands/docs-generate-index.md` 참조

### Merge Conflict 처리

**`docs/index.md`는 생성물로 취급합니다:**

```bash
# Conflict 발생 시 재생성
git checkout --theirs docs/index.md  # 또는 --ours
/docs-generate-index
git add docs/index.md
```

**권장**: `docs/index.md`를 커밋하여 문서 커버리지 추적

### 관련 문서

- 📖 `.claude/skills/documentation-manager/skill.md` - 문서 자동화 전체 가이드
- 📖 `docs/readme-config-spec.md` - `.readme-config.json` 설정 스펙
- 📖 `docs/recursive-readme-guide.md` - 계층적 README 상세 가이드

---

## 디렉토리 구조

```
Vibe-Coding-Setting-swseo/
├── .claude/                      # Claude Code 설정 (전역에서 사용)
│   ├── agents/                   # 커스텀 에이전트 (4개)
│   ├── commands/                 # 슬래시 커맨드 (15개)
│   ├── personas/                 # 페르소나 (2개)
│   ├── scripts/                  # 유틸리티 스크립트
│   │   ├── init-workspace.sh     # 프로젝트 초기화 (Unix)
│   │   ├── init-workspace.ps1    # 프로젝트 초기화 (Windows)
│   │   ├── install-hooks.sh      # Git hook 설치 (Unix)
│   │   ├── install-hooks.ps1     # Git hook 설치 (Windows)
│   │   └── run-command.py        # Claude 명령어 실행 wrapper
│   ├── skills/                   # 스킬 (20개)
│   ├── state/                    # 상태 파일 저장소 (gitignored, 런타임 데이터)
│   │   ├── .gitignore            # state 폴더 전체 무시
│   │   └── pre-commit-full.json  # /pre-commit-full 검증 상태
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
│   │   │   │   ├── run-notify.sh   # Unix wrapper
│   │   │   │   ├── install-hooks.sh  # Git hook 설치 (Unix)
│   │   │   │   ├── install-hooks.ps1 # Git hook 설치 (Windows)
│   │   │   │   └── run-command.py    # Claude 명령어 실행 wrapper
│   │   │   └── settings.json     # Hook 설정 (경로 의존적)
│   │   ├── .githooks/            # Git hook 템플릿 (Git 추적 가능)
│   │   │   ├── pre-commit        # 커밋 전 검증 (/pre-commit-full)
│   │   │   ├── commit-msg        # 커밋 메시지 검증
│   │   │   └── pre-push          # Push 전 검증
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

## Git Hook 자동화

**Claude 슬래시 커맨드와 스킬을 Git hook/GitHub Actions에서 자동 실행할 수 있습니다.**

### 개요

프로젝트 템플릿에는 Git hook 템플릿과 자동화 스크립트가 포함되어 있습니다:

```
templates/common/
├── .githooks/                  # Git hook 템플릿 (Git 추적 가능)
│   ├── pre-commit             # 커밋 전 검증
│   ├── commit-msg             # 커밋 메시지 검증
│   └── pre-push               # Push 전 검증
└── .claude/scripts/
    ├── run-command.py         # Claude 명령어 실행 wrapper
    ├── install-hooks.sh       # Hook 설치 (Unix/Mac)
    └── install-hooks.ps1      # Hook 설치 (Windows)
```

### 자동 설치

`/init-workspace`로 프로젝트를 초기화하면 **자동으로 Git hook이 설치됩니다**:

```bash
/init-workspace python

# 출력:
# Installing Git hooks...
#   Installed: pre-commit
#   Installed: commit-msg
#   Installed: pre-push
```

**조건**:
- 프로젝트가 Git 저장소여야 함 (`.git/` 폴더 존재)
- `.githooks/` 템플릿이 복사되어 있어야 함

### 수동 설치

기존 프로젝트에 hook을 설치하려면:

**Unix/Mac/Linux:**
```bash
./.claude/scripts/install-hooks.sh
```

**Windows:**
```powershell
.\.claude\scripts\install-hooks.ps1
```

### 기본 Hook 동작

**pre-commit** (커밋 전 자동 실행):
- `/pre-commit-full` 실행
- 코드 품질 + 문서 검증
- 실패 시 커밋 중단

**commit-msg** (커밋 메시지 검증):
- 최소 길이 확인 (10자 이상)
- Conventional Commits 형식 권장 (선택)

**pre-push** (Push 전 검증):
- 선택적 테스트 실행
- Main 브랜치 Push 경고

### Hook 비활성화

**임시로 스킵** (한 번만):
```bash
git commit --no-verify
```

**영구적으로 제거**:
```bash
rm .git/hooks/pre-commit
rm .git/hooks/commit-msg
rm .git/hooks/pre-push
```

### 커스텀 Hook 만들기

`.githooks/`에 새 파일을 추가하고 재설치:

**예시: pre-merge-commit**
```bash
#!/bin/bash
# .githooks/pre-merge-commit

# Merge 커밋 전에 특정 검사 수행
echo "Running pre-merge validation..."
claude --print "/speckit.analyze"
```

**설치:**
```bash
./.claude/scripts/install-hooks.sh
```

### 범용 Command Runner

모든 Claude 커맨드를 자동화할 수 있습니다:

**Python wrapper 사용:**
```bash
python .claude/scripts/run-command.py "/pre-commit-full"
python .claude/scripts/run-command.py "/speckit.specify"
python .claude/scripts/run-command.py --verbose "/your-custom-command"
```

**직접 CLI 사용:**
```bash
claude --print "/pre-commit-full"
```

### GitHub Actions 통합

**`.github/workflows/pre-commit.yml`** (예시):
```yaml
name: Pre-commit Validation
on: [push, pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Claude Code
        run: |
          # Claude Code CLI 설치
          npm install -g @anthropic/claude-code

      - name: Run validation
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          python .claude/scripts/run-command.py "/pre-commit-full"
```

**주의**:
- Claude Code가 CI/CD 환경에서 실행 가능한지 확인 필요
- API 키를 GitHub Secrets에 저장

### Hook 템플릿 수정

프로젝트별로 hook을 수정하려면 `.githooks/` 파일을 편집한 후:

```bash
# 변경사항 적용
./.claude/scripts/install-hooks.sh

# 또는 수동 복사
cp .githooks/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

**팁**: `.githooks/`는 Git에 추적되므로 팀원과 공유 가능!

### 문제 해결

**Claude 명령어가 실행되지 않을 때:**
```bash
# Claude CLI 설치 확인
which claude

# PATH 확인
echo $PATH
```

**Hook이 실행되지 않을 때:**
```bash
# 실행 권한 확인
ls -la .git/hooks/pre-commit

# 실행 권한 부여
chmod +x .git/hooks/pre-commit
```

**Windows에서 Bash script 오류:**
- Git Bash 사용 권장
- PowerShell에서는 `.ps1` 스크립트 사용

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

## Linear API 통합 (완전 버전)

**Linear MCP와 상호보완적으로 사용하는 완전한 API 클라이언트**

MCP는 읽기 중심, API는 쓰기 작업(삭제, 아카이브, 고급 기능)에 특화

### MCP vs API 역할 분담

| 기능 | MCP | API | 비고 |
|------|-----|-----|------|
| **Document** | 읽기 | 전체 | create, update, delete, archive |
| **Issue** | 생성/수정/읽기 | 삭제/아카이브 | 삭제는 API만 |
| **Comment** | 생성/읽기 | 수정/삭제 | 수정/삭제는 API만 |
| **Project** | 생성/수정/읽기 | 삭제/아카이브 | 삭제는 API만 |
| **Cycle** | 읽기만 | 전체 | 생성/수정/삭제 모두 API |
| **Team** | 읽기만 | 생성/수정 | 쓰기는 API만 |
| **Label** | 생성/읽기 | 수정/삭제 | 수정/삭제는 API만 |
| **Attachment** | 없음 | 전체 | MCP 미지원 |
| **Custom View** | 없음 | 전체 | MCP 미지원 |
| **Initiative** | 없음 | 전체 | MCP 미지원 |
| **Roadmap** | 없음 | 전체 | MCP 미지원 |
| **Workflow** | 없음 | 전체 | MCP 미지원 |
| **Webhook** | 없음 | 전체 | MCP 미지원 |

### 빠른 시작

**1. API Key 발급:**
```
Linear > Settings > API > "Create key"
```

**2. 환경변수 설정:**

```bash
cp .env.example .env
# .env 파일에 LINEAR_API_KEY=lin_api_YOUR_KEY 입력
```

**3. 의존성 설치:**

```bash
pip install requests python-dotenv
```

### 주요 사용 예시

**Document 작업:**

```bash
# 생성
python .claude/scripts/linear-api-client.py document create \
  --title "API Guide" --content "# Guide"

# 업데이트
python .claude/scripts/linear-api-client.py document update \
  --id DOC-123 --content "# Updated"

# 삭제
python .claude/scripts/linear-api-client.py document delete --id DOC-123
```

**Issue 삭제/아카이브:**

```bash
# 아카이브 (복구 가능)
python .claude/scripts/linear-api-client.py issue archive --id ISSUE-123

# 삭제 (영구 삭제)
python .claude/scripts/linear-api-client.py issue delete --id ISSUE-123

# 복원
python .claude/scripts/linear-api-client.py issue unarchive --id ISSUE-123
```

**Cycle 관리 (MCP에서 불가능):**

```bash
# Cycle 생성
python .claude/scripts/linear-api-client.py cycle create \
  --team TEAM-123 --name "Sprint 42"

# Cycle 업데이트
python .claude/scripts/linear-api-client.py cycle update \
  --id CYCLE-456 --ends-at "2025-12-31"

# Cycle 아카이브
python .claude/scripts/linear-api-client.py cycle archive --id CYCLE-456
```

**Comment 수정/삭제 (MCP에서 불가능):**

```bash
# Comment 수정
python .claude/scripts/linear-api-client.py comment update \
  --id comment-abc --body "Updated text"

# Comment 삭제
python .claude/scripts/linear-api-client.py comment delete --id comment-abc
```

**고급 기능 (MCP에 없음):**

```bash
# Custom View 생성
python .claude/scripts/linear-api-client.py view create \
  --name "My High Priority" --team TEAM-123

# Initiative 생성
python .claude/scripts/linear-api-client.py initiative create \
  --name "Q4 Goals" --target-date "2025-12-31"

# Webhook 생성
python .claude/scripts/linear-api-client.py webhook create \
  --url "https://api.myapp.com/webhook" --types Issue Comment

# Workflow State 추가
python .claude/scripts/linear-api-client.py workflow create \
  --team TEAM-123 --name "Code Review" --type started

# Attachment 추가
python .claude/scripts/linear-api-client.py attachment create \
  --issue ISSUE-123 --url "https://github.com/org/repo/pull/456"
```

### Python 코드 통합

```python
from linear_api_client import LinearAPIClient
import os

client = LinearAPIClient(os.getenv("LINEAR_API_KEY"))

# Document 관리
doc = client.create_document(
    title="My Doc",
    content="# Hello World"
)

# Issue 아카이브
client.archive_issue("ISSUE-123")

# Comment 수정
client.update_comment(
    comment_id="comment-abc",
    body="Updated comment"
)

# Cycle 생성
cycle = client.create_cycle(
    team_id="TEAM-123",
    name="Sprint 42"
)

# Custom View 생성
view = client.create_custom_view(
    name="High Priority",
    team_id="TEAM-123"
)

# Webhook 설정
webhook = client.create_webhook(
    url="https://api.myapp.com/webhook",
    resource_types=["Issue", "Comment"]
)
```

### 지원하는 모든 기능

**완전 지원 리소스:**
- Document (create, update, delete, archive)
- Cycle (create, update, archive)
- Team (create, update)
- Attachment (create, update, delete)
- Custom View (create, update, delete, archive)
- Initiative (create, update, delete, connect to project)
- Roadmap (create, update, delete)
- Workflow State (create, update, archive)
- Webhook (create, update, delete)

**부분 지원 (삭제/아카이브만):**
- Issue (delete, archive, unarchive)
- Comment (update, delete)
- Project (delete, archive, unarchive)
- Label (update, delete)

### 상세 문서

- [빠른 참조 가이드](docs/linear-api-quick-reference.md) - CLI 사용법 완전 정리
- [MCP vs API 비교](docs/linear-mcp-vs-api-comparison.md) - 기능별 상세 비교
- [통합 가이드](docs/linear-api-integration.md) - MCP와 함께 사용하는 워크플로우

### 보안 주의사항

- API 키를 절대 Git에 커밋하지 마세요
- `.env` 파일은 `.gitignore`에 포함되어야 합니다
- API 키가 노출되면 즉시 재발급하세요
- API 키는 프로젝트 루트의 `.env` 파일에만 저장

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

### 2025-11-09
- Linear API 완전 통합 (MCP 상호보완)
  - `.claude/scripts/linear-api-client.py` - 완전한 Linear API 클라이언트 (1680 lines)
  - 모든 API 작업 지원: Document, Issue, Comment, Project, Cycle, Team, Label, Attachment, Custom View, Initiative, Roadmap, Workflow, Webhook
  - 13개 리소스 타입, 50+ 메소드 구현
  - CLI 인터페이스: resource action 형식 (예: `document create`, `cycle update`)
  - `docs/linear-api-quick-reference.md` - CLI 사용법 완전 정리
  - `docs/linear-mcp-vs-api-comparison.md` - MCP vs API 기능 비교표
  - `docs/linear-api-integration.md` - 통합 가이드 및 워크플로우
  - `.env.example` 추가 (LINEAR_API_KEY 환경변수 템플릿)
  - MCP로 불가능한 작업 완벽 지원: 삭제, 아카이브, Cycle 관리, Comment 수정, Custom View, Initiative, Roadmap, Workflow State, Webhook
- Git Hook 자동화 시스템 추가
  - `templates/common/.githooks/` - Git hook 템플릿 (pre-commit, commit-msg, pre-push)
  - `.claude/scripts/run-command.py` - Claude 명령어 실행 wrapper
  - `.claude/scripts/install-hooks.sh/ps1` - Git hook 설치 스크립트
  - `/init-workspace`에서 자동 hook 설치
  - 모든 Claude 슬래시 커맨드/스킬을 Git hook으로 자동화 가능
- 문서 업데이트: "Git Hook 자동화" 섹션 추가
- 이모지 사용 금지 규칙 추가 (CRITICAL 규칙)

### 2025-11-08
- `/pre-commit-full` Incremental Validation 기능 추가
  - 마지막 검증 이후 커밋만 선택적으로 검증 (시간 절약)
  - `.claude/state/` 폴더 생성 (검증 상태 저장, gitignored)
  - 통계 출력: 검증한 커밋 개수, 소요 시간, 커밋 범위
  - `--force` 옵션으로 전체 검증 가능
- 에이전트 개수 업데이트 (2개 → 4개)
- 스킬 개수 업데이트 (17개 → 20개)

### 2025-11-04
- ✅ `claude-md-manager` 스킬 추가 (커밋 전 자동 claude.md 품질 검증)
- ✅ Python 템플릿에 환경변수 관리 가이드 추가 (`python-dotenv` 사용법)
- ✅ `templates/python/claude.md` 생성 (Python 프로젝트 전용 가이드)
- ✅ `claude-md-manager` 템플릿에 환경변수 베스트 프랙티스 추가 (Python, JavaScript)

### 2025-11-02
- 임시 파일 관리 규칙 추가 (AI 토론 기반, 85% 신뢰도)
