# 프로젝트 로컬/전역 설정 분리 마이그레이션 가이드

**날짜**: 2025-10-27
**변경 사항**: `.claude` 설정을 프로젝트 로컬과 전역으로 분리

---

## 변경 사항 요약

### 이전 (Before)

모든 `.claude` 설정이 프로젝트마다 복사됨:

```
my-project/.claude/
├── commands/      ← 13개 명령어 (중복!)
├── agents/        ← 2개 에이전트 (중복!)
├── skills/        ← 13개 스킬 (중복, ~5MB!)
├── personas/      ← 2개 페르소나 (중복!)
├── scripts/       ← Hook 스크립트
└── settings.json  ← Hook 설정
```

**문제점:**
- 프로젝트 10개 = 같은 파일 10번 복사
- 명령어 업데이트 시 모든 프로젝트 수동 업데이트 필요
- 디스크 공간 낭비 (~50MB × 프로젝트 수)

### 이후 (After)

경로 의존성에 따라 분리:

**프로젝트 로컬** (경로 의존적):
```
my-project/.claude/
├── settings.json  ← Hook 설정 (.claude/scripts 참조)
└── scripts/       ← Hook 스크립트 (상대경로)
```

**전역 공유** (경로 독립적):
```
~/.claude/
├── commands/      ← 모든 프로젝트 공유
├── agents/        ← 모든 프로젝트 공유
├── skills/        ← 모든 프로젝트 공유
├── personas/      ← 모든 프로젝트 공유
└── scripts/       ← 유틸리티 스크립트
```

**장점:**
- ✅ 중복 제거 (디스크 공간 90% 절약)
- ✅ 한 곳에서 업데이트하면 모든 프로젝트 반영
- ✅ 일관성 유지 (모든 프로젝트가 같은 버전 사용)

---

## 마이그레이션 방법

### 방법 1: 자동 마이그레이션 (`/sync-workspace` 사용)

**가장 간단하고 권장하는 방법입니다.**

```bash
cd my-existing-project
claude

# 프로젝트 로컬 + 전역 설정 모두 자동 업데이트
/sync-workspace
```

**동작:**
1. 최신 Vibe-Coding-Setting 자동 clone
2. 프로젝트 로컬에서 불필요한 파일 제거 (commands, agents, skills, personas)
3. 필요한 파일만 유지 (.claude/settings.json, .claude/scripts/)
4. 전역 설정 자동 업데이트 (~/.claude/, ~/.specify/)

**결과 확인:**
```bash
# 프로젝트 로컬 - 최소 파일만 남음
ls -la .claude/
# → settings.json, scripts/

# 전역 설정 - commands 등이 있어야 함
ls -la ~/.claude/
# → commands/, agents/, skills/, personas/
```

---

### 방법 2: 수동 마이그레이션

전역 설정이 없거나 특정 파일만 수정하고 싶은 경우:

#### Step 1: 전역 설정 설치

```bash
# Vibe-Coding-Setting 저장소로 이동 (또는 clone)
cd ~/Vibe-Coding-Setting-swseo
claude

# 전역 설정 적용
/apply-settings

# 확인
ls ~/.claude/commands/
# → init-workspace.md, sync-workspace.md 등이 보여야 함
```

#### Step 2: 프로젝트 로컬 정리

```bash
cd my-existing-project

# 중복 파일 제거 (경로 독립적 파일들)
rm -rf .claude/commands/
rm -rf .claude/agents/
rm -rf .claude/skills/
rm -rf .claude/personas/

# 필요한 파일만 유지
ls .claude/
# → settings.json, scripts/ 만 남아야 함
```

#### Step 3: 동작 확인

```bash
# 프로젝트에서 Claude Code 실행
claude

# slash command 테스트 (전역에서 로드되어야 함)
/help

# Hook 테스트 (로컬 settings.json 사용)
# 세션 종료 시 TTS 알림이 작동해야 함
```

---

## 기존 프로젝트별 가이드

### 케이스 1: 이미 `/init-workspace`로 생성한 프로젝트

```bash
cd my-python-project

# /sync-workspace로 자동 정리
/sync-workspace
```

---

### 케이스 2: 수동으로 `.claude` 폴더를 복사한 프로젝트

```bash
cd manually-setup-project

# 수동 정리
rm -rf .claude/commands/ .claude/agents/ .claude/skills/ .claude/personas/

# 전역 설정이 없다면
cd ~/Vibe-Coding-Setting-swseo
/apply-settings
```

---

### 케이스 3: `.claude` 폴더가 아예 없는 프로젝트

```bash
cd project-without-claude

# 처음부터 새로 적용
/init-workspace python  # 또는 javascript 등
```

---

## 확인 체크리스트

마이그레이션 후 다음 항목을 확인하세요:

### ✅ 프로젝트 로컬 확인

```bash
cd my-project

# 1. .claude 폴더 구조 확인
ls -la .claude/
# → settings.json, scripts/ 만 있어야 함

# 2. settings.json 내용 확인
cat .claude/settings.json
# → hook 설정이 있어야 함

# 3. scripts 폴더 확인
ls .claude/scripts/
# → notify.py, run-notify.cmd, run-notify.sh가 있어야 함
```

### ✅ 전역 설정 확인

```bash
# 1. commands 확인
ls ~/.claude/commands/
# → init-workspace.md, sync-workspace.md 등

# 2. agents 확인
ls ~/.claude/agents/
# → pytest-test-writer/ 등

# 3. skills 확인
ls ~/.claude/skills/
# → agent-creator/, algorithmic-art/ 등 13개

# 4. personas 확인
ls ~/.claude/personas/
# → briefer.md, default.md
```

### ✅ 기능 동작 확인

```bash
cd my-project
claude

# 1. Slash commands (전역)
/help
/init-workspace
/speckit.specify

# 2. Hook (로컬)
# Claude 세션 종료 → TTS 알림 작동 확인

# 3. Skills (전역)
# 임의의 skill 사용 테스트
```

---

## 롤백 방법

마이그레이션 전 상태로 되돌리고 싶다면:

### 방법 1: Git으로 롤백

```bash
cd my-project

# 변경 전으로 되돌리기
git restore .claude/
```

### 방법 2: 수동 복사

```bash
# Vibe-Coding-Setting에서 모든 파일 복사 (옛날 방식)
cd ~/Vibe-Coding-Setting-swseo
cp -r .claude/ ~/my-project/.claude/
```

---

## FAQ

### Q1: 전역 설정을 업데이트하려면?

```bash
# 방법 1: Vibe-Coding-Setting 저장소에서
cd ~/Vibe-Coding-Setting-swseo
git pull
/apply-settings

# 방법 2: 아무 프로젝트에서
cd ~/any-project
/sync-workspace --global-only
```

### Q2: 프로젝트마다 다른 명령어를 쓰고 싶다면?

프로젝트 로컬 `.claude/commands/`를 만들어서 추가하면 됩니다:

```bash
cd my-special-project
mkdir -p .claude/commands/

# 프로젝트 전용 명령어 추가
cat > .claude/commands/special-command.md << 'EOF'
---
name: special-command
description: Project-specific command
---
# Special Command
...
EOF

# 전역 + 로컬 명령어 모두 사용 가능!
```

### Q3: `/sync-workspace`를 실행하면 프로젝트 코드가 손상되나요?

**절대 아닙니다!** `/sync-workspace`는 다음만 건드립니다:
- `.claude/settings.json`
- `.claude/scripts/`
- `.specify/`
- `~/.claude/` (전역)
- `~/.specify/` (전역)

프로젝트 코드 (`src/`, `tests/` 등)는 절대 건드리지 않습니다.

### Q4: 기존 커스터마이징한 `.claude` 설정은?

`/sync-workspace`는 덮어씁니다. 커스터마이징을 유지하려면:

1. **전역 커스터마이징**: Vibe-Coding-Setting 저장소에 추가
2. **프로젝트별 커스터마이징**: 프로젝트 로컬에 추가 (전역과 병합됨)

---

## 트러블슈팅

### 문제: Slash commands가 작동하지 않음

**원인**: 전역 설정이 없거나 손상됨

**해결**:
```bash
cd ~/Vibe-Coding-Setting-swseo
/apply-settings

# 또는
cd ~/any-project
/sync-workspace --global-only
```

### 문제: Hook (TTS 알림)이 작동하지 않음

**원인**: 프로젝트 로컬 `.claude/settings.json` 또는 `.claude/scripts/`가 없음

**해결**:
```bash
cd my-project
/sync-workspace --local-only
```

### 문제: `/sync-workspace` 실행 시 에러

**원인**: 네트워크 문제 또는 git 미설치

**해결**:
```bash
# git 설치 확인
git --version

# 수동으로 clone
git clone https://github.com/swseo92/Vibe-Coding-Setting-swseo.git /tmp/vibe-coding

# 수동 복사
cp /tmp/vibe-coding/templates/common/.claude/settings.json .claude/
cp -r /tmp/vibe-coding/templates/common/.claude/scripts/ .claude/
cp -r /tmp/vibe-coding/.claude/ ~/.claude/
```

---

## 요약

**새 프로젝트:**
```bash
/init-workspace python  # 자동으로 올바른 구조 생성
```

**기존 프로젝트:**
```bash
/sync-workspace  # 자동 마이그레이션 + 업데이트
```

**전역 설정 업데이트:**
```bash
/apply-settings  # Vibe-Coding-Setting 저장소에서
# 또는
/sync-workspace --global-only  # 아무 프로젝트에서
```

**확인:**
```bash
ls .claude/        # → settings.json, scripts/
ls ~/.claude/      # → commands/, agents/, skills/, personas/
```

**문제 시:**
- GitHub Issues: https://github.com/swseo92/Vibe-Coding-Setting-swseo/issues
- 또는 Vibe-Coding-Setting 저장소 CLAUDE.md 참고

---

**마지막 업데이트**: 2025-10-27
**버전**: 2.0.0 (프로젝트 로컬/전역 분리)
