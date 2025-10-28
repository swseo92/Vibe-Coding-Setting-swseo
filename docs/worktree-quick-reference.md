# Worktree Commands: Quick Reference

## 명령어 치트시트

### 기본 명령어 (현재 구현)

```bash
# 새 클론 생성
/worktree-create <branch-name>

# 클론 상태 확인
/worktree-status <branch-name>

# GitHub에서 최신 변경사항 가져오기
/worktree-sync <branch-name>

# PR 생성
/worktree-pr <branch-name>

# 클론 삭제
/worktree-delete <branch-name>
```

---

## 일반적인 워크플로우

### 1. 새 기능 개발 시작
```bash
/worktree-create feature-login
# → clone/feature-login/ 디렉토리 생성
# → 자동으로 .venv 생성 및 의존성 설치
```

### 2. 작업 중 상태 확인
```bash
/worktree-status feature-login
# → Git 상태, 커밋 히스토리, 변경 파일 등 확인
```

### 3. 메인 브랜치 최신화
```bash
/worktree-sync feature-login
# → origin/main의 최신 변경사항을 클론에 병합
```

### 4. PR 생성
```bash
# 먼저 커밋
cd clone/feature-login
git add .
git commit -m "feat: Add login feature"
cd ../..

# PR 생성
/worktree-pr feature-login
# → 자동으로 push + gh pr create
```

### 5. 작업 완료 후 정리
```bash
/worktree-delete feature-login
# → 클론 디렉토리 삭제 (⚠️ 주의: 되돌릴 수 없음!)
```

---

## 예정된 새 명령어 (개선 버전)

### 모든 클론 관리
```bash
# 모든 클론 목록 보기
/worktree-list

# 오래된 클론 정리 (30일 이상)
/worktree-cleanup --age=30

# 병합된 브랜치만 정리
/worktree-cleanup --merged-only

# 삭제 전 미리보기 (실제 삭제 안 함)
/worktree-cleanup --dry-run
```

### 클론 복구
```bash
# 손상된 클론 복구
/worktree-repair <branch-name>
```

### 클론 비교
```bash
# 클론과 메인 브랜치 비교
/worktree-diff feature-login main

# 두 클론 간 비교
/worktree-diff feature-a feature-b
```

### 빠른 전환
```bash
# VS Code에서 클론 열기
/worktree-switch feature-login
```

---

## 사용 팁

### ✅ 권장 사항

1. **작업 시작 전에 클론 생성**
   ```bash
   /worktree-create feature-name
   ```

2. **주기적으로 메인과 동기화**
   ```bash
   /worktree-sync feature-name
   ```

3. **상태 확인 습관**
   ```bash
   /worktree-status feature-name
   ```

4. **PR 병합 후 즉시 정리**
   ```bash
   /worktree-delete feature-name
   ```

5. **주기적으로 오래된 클론 정리 (예정)**
   ```bash
   /worktree-list  # 먼저 확인
   /worktree-cleanup --age=30
   ```

---

### ⚠️ 주의사항

1. **삭제는 영구적**
   - `/worktree-delete`는 되돌릴 수 없음
   - 커밋 안 한 변경사항은 모두 손실
   - 푸시 안 한 커밋도 손실

2. **디스크 공간 사용**
   - 각 클론은 전체 프로젝트 복사본
   - 대용량 프로젝트는 GB 단위 공간 사용
   - 주기적으로 정리 필요

3. **가상환경 독립성**
   - 각 클론은 독립적인 .venv 보유
   - 의존성 변경 시 각 클론에서 `uv sync` 필요

4. **Git origin 방향**
   - Clone의 origin = GitHub (remote)
   - `/worktree-sync`는 GitHub에서 가져옴
   - Local main → clone 동기화가 아님!

---

## 문제 해결

### Q: 클론 생성 실패
```bash
# 안전성 체크 실패 시:
# 1. Remote 확인
git remote -v

# 2. 현재 브랜치 확인 (main/master여야 함)
git branch --show-current

# 3. 커밋 존재 확인
git log --oneline -1
```

### Q: Sync 시 충돌 발생
```bash
# 수동 해결:
cd clone/<branch-name>
git status  # 충돌 파일 확인
# 충돌 해결 후:
git add <resolved-files>
git merge --continue
```

### Q: 삭제된 클론 복구
```bash
# 삭제 전 백업 안 했다면 복구 불가능
# 다시 생성:
/worktree-create <branch-name>
# GitHub에서 복구:
cd clone/<branch-name>
git pull origin <branch-name>
```

### Q: 디스크 공간 부족
```bash
# 오래된 클론 정리 (예정):
/worktree-list  # 클론 목록 확인
/worktree-cleanup --age=30  # 30일 이상 된 클론 삭제

# 또는 수동으로:
/worktree-delete <old-branch-1>
/worktree-delete <old-branch-2>
```

### Q: 가상환경 손상
```bash
# 수동 복구 (현재):
cd clone/<branch-name>
rm -rf .venv
uv venv
uv sync

# 자동 복구 (예정):
/worktree-repair <branch-name>
```

---

## 성능 고려사항

### 클론 생성 시간
- **소규모 프로젝트** (~50MB): 5-10초
- **중규모 프로젝트** (~200MB): 20-30초
- **대규모 프로젝트** (~500MB+): 60초 이상

### 최적화 팁
1. `.gitignore`에 불필요한 파일 추가
2. 빌드 아티팩트는 제외 (dist/, build/)
3. node_modules, .venv는 자동 제외됨
4. 대용량 바이너리 파일은 Git LFS 사용 고려

---

## 비교: Git Worktree vs Copy-based (현재 구현)

| 특징 | Git Worktree | Copy-based (현재) |
|------|-------------|------------------|
| 디스크 공간 | ✅ 효율적 (.git 공유) | ❌ 각 클론이 독립적 |
| 설정 자동화 | ❌ 수동 (venv, sync) | ✅ 자동 (venv, sync) |
| Python 최적화 | ❌ 범용 Git 기능 | ✅ Python 특화 |
| 생성 속도 | ✅ 빠름 | ❌ 느림 (복사) |
| 격리 수준 | ⚠️ .git 공유 | ✅ 완전 격리 |
| 관리 도구 | ✅ git worktree list | ❌ 커스텀 필요 |
| 학습 곡선 | ⚠️ Git 이해 필요 | ✅ 단순 명확 |

**결론**: Python 프로젝트에서는 Copy-based가 더 적합 (자동화 + 격리)

---

## 디렉토리 구조 이해

```
project-root/
├── .git/                    # 원본 Git repository
├── src/
├── tests/
├── pyproject.toml
├── README.md
└── clone/                   # 모든 클론이 여기에 생성됨
    ├── feature-a/           # Clone 1
    │   ├── .git/            # 독립적인 Git repository
    │   ├── .venv/           # 독립적인 가상환경
    │   ├── src/
    │   ├── tests/
    │   └── pyproject.toml
    │
    └── feature-b/           # Clone 2
        ├── .git/
        ├── .venv/
        └── ...
```

**중요**:
- 각 클론은 완전히 독립적
- 원본 프로젝트와 클론은 git origin을 통해 연결됨
- 클론에서 작업 → commit → push → PR

---

## 다음 단계

### 즉시 사용 가능
- ✅ /worktree-create
- ✅ /worktree-status
- ✅ /worktree-sync
- ✅ /worktree-pr
- ✅ /worktree-delete

### 개선 예정 (Phase 1-2)
- 🔄 안전성 체크 강화
- 🔄 진행 상황 표시
- 🔄 백업 옵션
- 🔄 Health check

### 신규 명령어 예정 (Phase 3-4)
- 📅 /worktree-list
- 📅 /worktree-cleanup
- 📅 /worktree-repair
- 📅 /worktree-diff
- 📅 /worktree-switch

---

## 추가 자료

- 상세 분석 문서: `docs/worktree-analysis-and-improvements.md`
- 구현 로드맵: (상세 분석 문서 내 포함)
- GitHub Issues: (향후 추가 예정)
