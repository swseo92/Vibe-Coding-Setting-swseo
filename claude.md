# Vibe-Coding-Setting

**이 디렉토리는 개발환경 설정 관리 저장소입니다.**

Claude Code를 활용한 개인 개발환경 설정 및 프로젝트 템플릿을 중앙에서 관리합니다.

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
