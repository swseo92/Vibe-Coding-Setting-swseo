# Git Worktree + PyCharm 병렬 작업 환경 토론

## User Context

**문제:** Git worktree를 이용한 Python 프로젝트 병렬 작업 환경 구성

**핵심 요구사항:**
- 여러 기능 동시 개발 (feature-a, feature-b)
- 실험적 변경과 안정 버전 병렬 유지
- 코드 리뷰 중 다른 작업 계속

**기술 스택:**
- Language: Python
- Dependency Management: 각 worktree마다 독립 `.venv`
- IDE: PyCharm (Windows)
- Database: 공유 DB (기본) / 독립 DB (스키마 변경 시)
- Environment Variables: 독립적 (원본에서 복사)

**사용자 상황:**
- Git worktree 초보
- 1인 개발자
- 기존 Vibe-Coding-Setting의 `/worktree-*` 명령어 활용 가능

**토론 목표:**
PyCharm IDE와 git worktree를 어떻게 통합하여 최적의 병렬 개발 환경을 구성할 것인가?

## Claude's Round 1 Proposal

### 접근법 A: Multi-Project Window (별도 PyCharm 인스턴스)

**구조:**
- 각 worktree = 독립 PyCharm 프로젝트
- 각자 `.venv`, `.env`, `.idea/` 보유
- 별도 창으로 열기

**장점:**
- 완전한 독립성
- 인덱싱 충돌 없음
- 독립 Run Configuration

**단점:**
- 메모리 부담 (여러 PyCharm 인스턴스)
- 창 전환 번거로움

### 접근법 B: Attached Directory (하나의 PyCharm 프로젝트)

**구조:**
- main 프로젝트에 worktrees를 Attached Directory로 추가
- 하나의 PyCharm 창에서 모든 worktree 관리
- 각 worktree별 Python Interpreter + Run Config

**장점:**
- 단일 PyCharm 창
- 코드 비교 용이
- 리소스 효율적

**단점:**
- 인덱싱 혼란 가능성
- 환경변수 전환 복잡

### 접근법 C: Hybrid - Smart Symlink (Claude 권장)

**구조:**
```
workspace/
├── main/
│   ├── .git/
│   ├── .venv/
│   └── src/
├── feature-a/
│   ├── .git -> main/.git/
│   ├── .venv/
│   ├── .env
│   ├── .shared/
│   │   └── db.sqlite3 -> ../../main/db.sqlite3
│   └── src/
└── experiment-b/
    ├── .venv/
    ├── .shared/
    │   └── db-copy.sqlite3
    └── src/
```

**자동화:**
- `/worktree-create feature-a` 명령어
- 자동 venv 생성 (`uv venv && uv sync`)
- `.env` 복사 + 커스터마이징
- DB 공유 or 복사 (플래그로 선택)
- PyCharm 설정 자동 생성

**PyCharm 통합:**
- 일반 작업: 별도 창 (접근법 A)
- 코드 비교: PyCharm 내장 기능
- 빠른 전환: Recent Projects

**장점:**
- 유연성 (DB 전략 전환 가능)
- 자동화 가능
- 기존 `/worktree-*` 명령어 활용
- PyCharm과 자연스러운 통합

**단점:**
- 초기 스크립트 작성 필요
- Windows 심볼릭 링크 권한 문제 가능성

## Questions for Codex

1. **PyCharm Indexing:**
   - Multi-project vs Single-project: 실제 성능 차이는?
   - Worktree 구조에서 인덱싱 최적화 방법?

2. **Windows Symlink:**
   - Developer Mode 없이 심볼릭 링크 사용 가능한가?
   - Junction vs Symlink: Windows에서 권장 방법?

3. **Automation Script:**
   - 접근법 C의 자동화 스크립트에서 놓친 엣지 케이스?
   - `uv` vs `venv` vs `poetry`: worktree 환경에서 최적은?

4. **DB Strategy:**
   - SQLite 파일 공유 시 locking 문제?
   - 스키마 변경 감지 후 자동 DB 복사 가능한가?

5. **Testing:**
   - 각 worktree에서 테스트 실행 시 격리 전략?
   - Shared fixtures vs Independent fixtures?

6. **Missing Dimensions:**
   - 환경변수에 민감정보 있을 때 복사 전략?
   - Git hooks (pre-commit 등)은 각 worktree에서 어떻게 작동?
   - PyCharm 플러그인 설정 공유 vs 독립?

## Expected from Codex

- Reality check on Claude's proposals
- Windows-specific considerations
- PyCharm best practices for worktree workflow
- Edge cases and failure modes
- Concrete implementation suggestions
