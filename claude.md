# Vibe-Coding-Setting

**이 디렉토리는 개발환경 설정 관리 저장소입니다.**

Claude Code를 활용한 개인 개발환경 설정 및 프로젝트 템플릿을 중앙에서 관리합니다.

---

## ⚠️ 중요: 커밋 전 확인사항

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
├── .claude/                      # Claude Code 설정
│   ├── agents/                   # 커스텀 에이전트
│   ├── commands/                 # 슬래시 커맨드
│   ├── personas/                 # 페르소나
│   ├── scripts/                  # 스크립트
│   └── settings.local.json       # 로컬 설정
│
├── .specify/                     # Speckit 템플릿 & 스크립트
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
│   │   ├── .claude/              # Claude Code 기본 설정
│   │   │   ├── scripts/          # Hook 스크립트
│   │   │   │   ├── notify.py     # 알림 TTS 스크립트
│   │   │   │   ├── run-notify.cmd  # Windows wrapper
│   │   │   │   └── run-notify.sh   # Unix wrapper
│   │   │   └── settings.json     # 상대경로 hook 설정
│   │   ├── .specify/             # Speckit 기본 구조
│   │   ├── .mcp.json             # MCP 설정
│   │   └── claude.md             # 프로젝트 마커 템플릿
│   │
│   └── python/                   # Python 템플릿
│       ├── claude.md             # 프로젝트용 마커
│       ├── pyproject.toml        # uv 설정
│       ├── .gitignore
│       ├── pytest.ini
│       ├── README.md
│       └── tests/                # 테스트 구조
│
├── speckit/                      # Speckit 원본 (GitHub에만 보관)
│   ├── .claude/commands/         # Speckit 커맨드
│   └── .specify/                 # Speckit 템플릿
│
└── claude.md                     # 이 문서
```

---

## 주요 커맨드

### `/apply-settings`
현재 프로젝트의 `.claude` 설정을 전역 설정(`~/.claude/`)으로 동기화합니다.

```bash
/apply-settings
```

**동작:**
- `.claude/` 전체 → `~/.claude/`
- `settings.local.json` → `~/.claude/settings.json`
- `speckit/` 템플릿 → `~/.specify/`

### `/init-workspace` (예정)
새 프로젝트에 언어별 템플릿을 적용합니다.

```bash
/init-workspace python
/init-workspace javascript
```

**동작:**
- 이 repo clone
- templates/{언어}/ 파일들을 현재 디렉토리에 복사
- 불필요한 파일 정리 (speckit/, .git/ 등)
- 의존성 설치 안내

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

### 1. 전역 Claude Code 설정 적용

```bash
# 이 repo로 이동
cd ~/Vibe-Coding-Setting-swseo

# Claude Code 실행
claude

# 설정 적용
/apply-settings
```

### 2. 새 Python 프로젝트 시작 (예정)

```bash
# 새 프로젝트 디렉토리 생성
mkdir my-new-project
cd my-new-project

# Claude Code 실행
claude

# 작업환경 초기화
/init-workspace python

# 의존성 설치
uv sync
```

### 3. 기존 프로젝트에 설정 추가

```bash
cd existing-project

# 수동으로 필요한 파일만 복사
# 또는 /init-workspace --minimal (향후 구현)
```

---

## 템플릿 추가 방법

### 새 언어 템플릿 추가

1. `templates/{언어}/` 폴더 생성
2. 기본 파일 구조 작성
   - `claude.md` - 프로젝트 마커
   - `README.md` - 사용법
   - 설정 파일들 (package.json, Cargo.toml 등)
   - `.gitignore`
3. `/init-workspace` 명령어에 언어 추가

예시:
```
templates/
├── python/       # 완료
├── javascript/   # TODO
├── rust/         # TODO
└── go/           # TODO
```

---

## Hook 설정 (알림 기능)

**모든 템플릿에는 작업 완료 시 TTS 알림을 제공하는 hook이 포함되어 있습니다.**

### 작동 방식

1. **상대경로 기반**: `.claude/scripts/run-notify.cmd` (Windows) 또는 `.claude/scripts/run-notify.sh` (Unix)
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
        "command": "\".claude\\scripts\\run-notify.cmd\" \"작업 완료\""
      }]
    }],
    "Stop": [{
      "hooks": [{
        "type": "command",
        "command": "\".claude\\scripts\\run-notify.cmd\" \"작업 완료\""
      }]
    }]
  }
}
```

### Hook 스크립트

- **`notify.py`**: 크로스 플랫폼 TTS 알림 (Windows/Mac/Linux)
- **`run-notify.cmd`**: Windows wrapper (Python 실행)
- **`run-notify.sh`**: Unix/Linux wrapper

### 커스터마이징

알림 메시지를 변경하려면:
```json
"command": "\".claude\\scripts\\run-notify.cmd\" \"원하는 메시지\""
```

알림을 비활성화하려면 `settings.json`에서 `hooks` 섹션을 제거하세요.

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

## 테스트 환경 관리

### tmp/ 폴더 사용

**새로운 기능이나 설정을 테스트할 때는 반드시 `tmp/` 폴더를 사용하세요.**

```bash
# 템플릿 테스트
mkdir -p tmp/test-python-template
cp -r templates/python/* tmp/test-python-template/
cd tmp/test-python-template
uv sync
# 테스트 진행...

# 완료 후 정리
cd ../..
rm -rf tmp/test-python-template
```

**규칙**:
- ✅ **모든 테스트는 `tmp/` 폴더 내부에서 수행**
- ✅ `tmp/` 폴더는 `.gitignore`에 포함되어 git에 추적되지 않음
- ✅ 테스트 완료 후 정리 권장 (선택사항)
- ❌ 저장소 루트에 직접 테스트 파일/폴더 생성 금지

**예시**:
- ✅ `tmp/python-test/`
- ✅ `tmp/init-workspace-test/`
- ✅ `tmp/jupyter-test/`
- ❌ `test-project/` (루트에 직접 생성 금지)
- ❌ `example-project/` (루트에 직접 생성 금지)

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

**마지막 업데이트**: 2025-10-25
**관리자**: swseo
**저장소**: https://github.com/swseo92/Vibe-Coding-Setting-swseo
