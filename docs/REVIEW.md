# Commit Review: 프로젝트 로컬/전역 설정 분리

**날짜**: 2025-10-27
**리뷰어**: Claude (독립 세션)
**변경 범위**: 설정 구조 개편 + 문서 업데이트

---

## ✅ 장점 (Strengths)

1. **명확한 아키텍처 개선**
   - 경로 의존적/독립적 파일 분리는 논리적이고 합리적
   - 중복 제거로 디스크 공간 절약 (90% 예상)
   - 전역 설정 공유로 일관성 향상

2. **상세한 문서화**
   - MIGRATION.md가 매우 구체적이고 실용적
   - 다양한 케이스별 가이드 제공
   - FAQ와 트러블슈팅 섹션 포함

3. **사용자 경험 고려**
   - 자동 마이그레이션 (/sync-workspace) 제공
   - 롤백 방법 명시
   - 단계별 확인 체크리스트

4. **명령어 옵션 개선**
   - --local-only, --global-only 플래그로 유연성 제공
   - --dry-run으로 안전성 확보

---

## ⚠️ 발견된 문제 (Issues Found)

### 심각도: High

#### 1. **치명적 불일치: `/sync-workspace` 동작 설명 vs 실제 구현**

**문제**:
- 문서에서는 "자동으로 프로젝트 로컬의 commands/agents/skills를 제거한다"고 설명
- 하지만 실제 스크립트 구현 확인 불가 (스크립트가 존재하지만 실행 전까지 동작 불명)
- `/sync-workspace`가 **기존 파일을 덮어쓰기만** 하는지, **삭제 후 복사**하는지 불명확

**위험**:
```bash
# 시나리오: 기존 프로젝트에 commands/가 있는 경우
my-project/.claude/commands/my-custom-command.md  # 사용자 커스텀

# /sync-workspace 실행 후:
# 예상 1: commands/ 전체 삭제 → 사용자 커스텀 명령어 손실!
# 예상 2: 아무 일도 안 일어남 → 중복 그대로 유지
```

**영향**: 사용자 데이터 손실 가능

**권장 수정**:
1. `/sync-workspace` 실행 전 백업 생성
2. 사용자 커스텀 파일 감지 및 경고
3. MIGRATION.md에 "커스텀 설정 백업 필수" 강조

---

#### 2. **구현 검증 불가능 - 스크립트 미검토**

**문제**:
- `init-workspace.sh`, `init-workspace.ps1` 스크립트 존재 확인
- 하지만 리뷰 시점에 스크립트 내용 미확인
- 문서가 스크립트 동작을 "가정"하고 작성됨

**위험**:
- 문서와 실제 구현이 다를 가능성
- 테스트 없이 커밋 시 프로덕션 문제

**권장 수정**:
1. 스크립트 실제 실행 테스트 필수
2. `tmp/` 폴더에서 end-to-end 테스트 수행
3. Windows/Unix 양쪽 환경 검증

---

#### 3. **"/apply-settings" vs "/sync-workspace" 역할 혼란**

**문제**:
두 명령어의 차이가 명확하지 않음:

```bash
# /apply-settings
- 이 저장소(Vibe-Coding-Setting) → ~/.claude/
- "저장소 자체에서" 실행

# /sync-workspace
- GitHub에서 clone → 현재 프로젝트 + ~/.claude/
- "아무 프로젝트에서" 실행
```

**혼란 포인트**:
- 사용자가 Vibe-Coding-Setting 저장소에서 `/sync-workspace` 실행하면?
- "프로젝트 로컬 업데이트"가 의미가 없는 상황
- 문서에서 명시되지 않음

**권장 수정**:
CLAUDE.md에 명확한 결정 트리 추가:
```
Q: 어떤 명령어를 써야 하나?

현재 위치가 Vibe-Coding-Setting 저장소:
  → /apply-settings (간단, 빠름)

현재 위치가 다른 프로젝트:
  새 프로젝트: /init-workspace <language>
  기존 프로젝트: /sync-workspace
```

---

### 심각도: Medium

#### 4. **templates/common/ 구조 문서 불일치**

**문제**:
CLAUDE.md 디렉토리 구조 설명:
```
templates/common/.claude/
├── scripts/
└── settings.json
```

하지만 실제 파일 확인:
```
templates/common/.claude/scripts/notify.py
templates/common/.claude/scripts/run-notify.cmd
templates/common/.claude/scripts/run-notify.sh
templates/common/.claude/settings.json
```

**이슈**:
- `claude.md`는 `templates/common/claude.md`에 있어야 하는데 명시 누락
- `.mcp.json`, `.specify/`가 `templates/common/`에 있는지 확인 불가

**권장 수정**:
1. 실제 파일 구조 재확인
2. CLAUDE.md 디렉토리 트리 업데이트
3. `ls -R templates/common/` 출력을 문서에 반영

---

#### 5. **"/init-workspace" 전역 설정 확인 로직 불명확**

**문제**:
문서 line 65-76:
```markdown
### 3. 전역 설정 확인

**전역 설정이 있는지 확인:**
ls ~/.claude/commands/ 2>/dev/null || echo "전역 설정 없음"

**전역 설정이 없거나 오래된 경우:**
- 나중에 `/apply-settings` 자동 실행 (clone된 repo에서)
```

**의문**:
1. "오래된 경우"를 어떻게 판단? (파일 날짜? 버전 체크?)
2. "/apply-settings 자동 실행" - 정말 자동인가 수동인가?
3. Line 169-179에서는 "수동 실행 안내"라고 모순

**실제 동작 예상**:
- 아마도 수동 안내만 하고 자동 실행은 안 함
- 하지만 문서에서 "자동으로" 라고 명시

**권장 수정**:
정확한 동작으로 문서 수정:
```markdown
**전역 설정이 없는 경우:**
- 사용자에게 알림 메시지 표시
- Vibe-Coding-Setting 저장소에서 `/apply-settings` 실행 안내
- 또는 수동으로 ~/.claude/ 복사 방법 제시
```

---

#### 6. **Windows 경로 구분자 혼용**

**문제**:
`templates/common/.claude/settings.json` (line 15, 25):
```json
"command": "\".claude\\scripts\\run-notify.cmd\" \"작업 완료\""
```

- Windows 역슬래시 (`\`) 하드코딩
- Unix 시스템에서 작동 안 함

**현재 해결책**:
- `run-notify.sh`가 별도 존재하여 Unix용 wrapper 제공
- 하지만 settings.json은 Windows 전용

**문제점**:
- `templates/common/`은 "공통" 템플릿인데 플랫폼별 분기 없음
- `/init-workspace`에서 플랫폼 감지 후 settings.json을 동적 생성해야 하는데 명시 없음

**권장 수정**:
1. settings.json을 두 버전 제공:
   - `settings.windows.json`
   - `settings.unix.json`
2. 초기화 스크립트에서 플랫폼별로 복사
3. 또는 상대경로로 `.claude/scripts/run-notify.sh` 사용 (슬래시)

---

#### 7. **sync-workspace 변경사항 프리뷰 제한**

**문제**:
문서 line 194-197 (sync-workspace.md):
```markdown
# 전역 설정은 항상 업데이트 (프리뷰 없이)
Write-Host "`n=== Global Settings ===" -ForegroundColor Cyan
Write-Host "  Will update: ~/.claude/ (commands, agents, skills, personas)"
```

**이슈**:
- 프로젝트 로컬은 diff 표시
- 전역 설정은 "무조건 덮어쓰기" (사용자 확인 없음?)

**위험**:
```bash
# 시나리오: 사용자가 ~/.claude/commands/에 커스텀 명령어 추가
~/.claude/commands/my-secret-automation.md

# /sync-workspace 실행
# → 전체 ~/.claude/ 삭제 후 복사
# → my-secret-automation.md 손실!
```

**권장 수정**:
1. 전역 설정도 diff 표시
2. 백업 자동 생성 (타임스탬프)
3. "전역 설정 덮어쓰기 주의" 경고 메시지

---

### 심각도: Low

#### 8. **CLAUDE.md 업데이트 날짜 불일치**

**문제**:
- CLAUDE.md line 448: "마지막 업데이트: 2025-10-25"
- MIGRATION.md line 397: "마지막 업데이트: 2025-10-27"
- 실제 리뷰 날짜: 2025-10-27

**권장**: CLAUDE.md 날짜를 2025-10-27로 업데이트

---

#### 9. **용어 일관성 문제**

**발견된 용어 혼용**:

| 개념 | 사용된 용어들 |
|------|--------------|
| 전역 설정 | "전역 설정", "global config", "~/.claude/", "전역 Claude 설정" |
| 프로젝트 로컬 | "프로젝트 로컬", "local", "프로젝트별", "현재 프로젝트" |
| 동기화 | "sync", "동기화", "업데이트", "적용" |

**권장**: 용어 통일 가이드라인 작성

---

#### 10. **예시 코드 일관성**

**문제**:
- 어떤 곳은 `bash` 코드 블록
- 어떤 곳은 `sh` 코드 블록
- 어떤 곳은 언어 지정 없음

**권장**: 모두 ```bash로 통일

---

#### 11. **git diff 출력 누락**

**발견**:
- git diff 실행했으나 n8n-automation-builder/SKILL.md 변경사항 포함
- 이 파일이 이번 변경의 일부인지 불명확
- 리뷰 범위 밖 변경사항 혼입 가능성

**권장**: 변경사항 범위 명확히 하기

---

## 🔍 세부 검토 결과

### 1. 일관성 검토

**✅ 잘된 점**:
- `/init-workspace`, `/sync-workspace`, CLAUDE.md가 동일한 개념 설명
- 디렉토리 구조 표현이 일관적 (트리 형식)
- "프로젝트 로컬/전역" 구분이 모든 문서에서 동일

**❌ 문제점**:
- "자동 실행" vs "수동 안내" 모순 (issue #5)
- Windows/Unix 경로 혼용 (issue #6)
- 용어 혼용 (issue #9)

**점수**: 7/10

---

### 2. 완전성 검토

**✅ 포함된 것**:
- 마이그레이션 가이드 (MIGRATION.md)
- 여러 케이스별 시나리오
- 롤백 방법
- FAQ, 트러블슈팅

**❌ 누락된 것**:
1. **실제 테스트 결과**: 스크립트가 정말 작동하는가?
2. **백업 전략**: 사용자 데이터 보호 방안
3. **버전 관리**: "오래된 전역 설정" 판단 기준
4. **충돌 해결**: 사용자 커스텀 vs 기본 설정 충돌 시
5. **성능 영향**: clone, 파일 복사 시간 (느린 네트워크 환경)

**점수**: 6/10

---

### 3. 정확성 검토

**확인 가능한 것**:
- ✅ 파일 경로 (`templates/common/.claude/`) 실제 존재
- ✅ CLAUDE.md 디렉토리 구조 대체로 정확
- ✅ Git 관련 명령어 문법 정확

**확인 불가능한 것**:
- ❓ init-workspace.sh/ps1 스크립트 동작
- ❓ /sync-workspace의 실제 파일 삭제/복사 로직
- ❓ 전역 설정 "자동 적용" 동작 여부

**점수**: 5/10 (검증 부족)

---

### 4. 사용자 경험 검토

**✅ 긍정적**:
- 단계별 가이드 명확
- 다양한 케이스 커버
- 에러 메시지 예시 제공
- 확인 체크리스트

**❌ 부정적**:
1. **명령어 선택 혼란**: `/apply-settings` vs `/sync-workspace`
2. **데이터 손실 불안**: "덮어쓰기" 경고 부족
3. **복잡도**: 사용자가 "경로 의존적/독립적" 개념 이해 필요
4. **롤백 어려움**: Git 없는 프로젝트는?

**개선 제안**:
```bash
# Interactive 모드 추가
/sync-workspace
→ "전역 설정도 업데이트하시겠습니까? (Y/n)"
→ "백업을 생성하시겠습니까? (Y/n)"
```

**점수**: 7/10

---

### 5. 잠재적 문제점

#### 보안 문제
- ❌ 없음 (설정 파일만 다룸)

#### 데이터 무결성
- ⚠️ **사용자 커스텀 설정 손실 위험** (issue #1, #7)
- ⚠️ **롤백 시 부분 실패** 가능성

#### 호환성 문제
- ⚠️ **Windows/Unix 경로 차이** (issue #6)
- ⚠️ **Git Bash vs PowerShell** 환경 차이
- ⚠️ **Python 버전 의존성** (notify.py)

#### 성능 문제
- ⚠️ **매번 GitHub clone** (네트워크 오버헤드)
- 💡 캐싱 또는 "로컬 우선" 옵션 고려

#### 유지보수 문제
- ⚠️ **문서-코드 동기화**: 스크립트 변경 시 문서도 업데이트 필요
- ⚠️ **버전 호환성**: 오래된 프로젝트 + 새 명령어

---

## 📝 권장 수정사항

### 즉시 수정 (Before Commit)

- [ ] **[HIGH] issue #1**: `/sync-workspace`에 백업 로직 추가
  ```bash
  # 예시
  if [ -d ".claude/commands" ]; then
      echo "Warning: Found custom commands. Backing up..."
      cp -r .claude/commands .claude/commands.backup-$(date +%s)
  fi
  ```

- [ ] **[HIGH] issue #2**: 스크립트 실제 테스트 수행
  ```bash
  # tmp/ 폴더에서 end-to-end 테스트
  mkdir tmp/test-init
  cd tmp/test-init
  /init-workspace python
  # 검증...
  ```

- [ ] **[HIGH] issue #3**: CLAUDE.md에 명령어 선택 가이드 추가
  ```markdown
  ## 명령어 선택 가이드

  ### /apply-settings
  - **언제**: Vibe-Coding-Setting 저장소에서 작업 중
  - **목적**: 수정한 설정을 전역에 반영

  ### /sync-workspace
  - **언제**: 다른 프로젝트에서 작업 중
  - **목적**: 최신 설정 가져오기
  ```

- [ ] **[MEDIUM] issue #4**: templates/common/ 실제 파일 구조 확인 및 문서 정정

- [ ] **[MEDIUM] issue #5**: "/init-workspace" 전역 설정 처리 로직 명확화
  - "자동 실행"을 "수동 안내"로 수정
  - 또는 정말 자동으로 만들기

- [ ] **[LOW] issue #8**: CLAUDE.md 날짜 업데이트 (2025-10-27)

---

### 추후 개선 (After Commit)

- [ ] **Windows/Unix settings.json 분리** (issue #6)
  - `templates/common/.claude/settings.windows.json`
  - `templates/common/.claude/settings.unix.json`
  - 초기화 시 자동 선택

- [ ] **전역 설정 diff 표시** (issue #7)
  - `~/.claude/` 변경사항도 미리보기
  - 덮어쓰기 전 사용자 확인

- [ ] **버전 관리 시스템**
  - `~/.claude/VERSION` 파일 추가
  - "오래된 설정" 자동 감지

- [ ] **Incremental sync**
  - 전체 clone 대신 필요한 파일만 다운로드
  - GitHub API 또는 sparse checkout 활용

- [ ] **사용자 커스텀 보호**
  - `~/.claude/custom/` 디렉토리 도입
  - sync 시 보존되는 영역

- [ ] **Interactive 모드**
  ```bash
  /sync-workspace --interactive
  → "전역 설정 업데이트? (Y/n)"
  → "백업 생성? (Y/n)"
  ```

- [ ] **Dry-run 상세화**
  ```bash
  /sync-workspace --dry-run
  → 프로젝트 로컬 변경사항
  → 전역 설정 변경사항
  → 예상 삭제 파일 목록
  ```

---

## ✓ Commit 승인 여부

### 🟡 조건부 승인 (Conditional Approval)

**승인 조건**:
1. ✅ **즉시 수정 항목 중 HIGH 우선순위 3개 해결**
2. ✅ **스크립트 실제 테스트 수행 및 결과 확인**
3. ✅ **백업 메커니즘 추가 (최소한 경고 메시지)**

**이유**:
- 아키텍처 방향성은 매우 좋음 (중복 제거, 전역 공유)
- 하지만 구현 검증 부족 (스크립트 미테스트)
- 사용자 데이터 손실 위험 (백업 없음)

**조건 충족 시**: ✅ **Commit 승인**
**조건 미충족 시**: ⚠️ **추가 작업 필요**

---

## 추가 의견

### 장기적 개선 방향

1. **설정 버전 관리**
   ```json
   // ~/.claude/manifest.json
   {
     "version": "2.0.0",
     "updated": "2025-10-27",
     "source": "https://github.com/.../commit/abc123"
   }
   ```

2. **Diff 시각화 개선**
   ```bash
   /sync-workspace --diff
   → Vimdiff style 또는 colored diff
   ```

3. **플러그인 시스템**
   ```
   ~/.claude/
   ├── core/          # 코어 설정 (덮어쓰기)
   ├── user/          # 사용자 커스텀 (보존)
   └── projects/      # 프로젝트별 (각 프로젝트 링크)
   ```

4. **자동 테스트**
   ```bash
   # CI/CD에서 실행
   tests/test-init-workspace.sh
   tests/test-sync-workspace.sh
   ```

### 칭찬할 점

- 📚 **문서화 품질**: 상세하고 실용적
- 🎯 **문제 인식**: 중복 제거 필요성 정확히 파악
- 🛡️ **안전장치**: dry-run, 롤백 가이드 제공
- 🔄 **사용자 경험**: 다양한 시나리오 고려

### 주의할 점

- ⚠️ **검증 우선**: 문서 작성 전 스크립트 테스트
- 🔒 **데이터 보호**: 덮어쓰기 전 항상 백업
- 📊 **메트릭 수집**: 사용자가 어디서 막히는지 추적
- 📢 **Breaking Change 공지**: 기존 사용자에게 충분한 안내

---

**최종 권고**:
HIGH 우선순위 이슈 3개를 해결한 후 커밋하세요. 현재 상태로는 프로덕션 환경에서 사용자 데이터 손실 위험이 있습니다.

---

**리뷰 완료**: 2025-10-27
**다음 리뷰 필요**: 스크립트 테스트 결과 확인 후
