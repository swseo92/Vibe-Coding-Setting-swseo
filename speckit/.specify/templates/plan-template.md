# 구현 계획: [기능명]

**브랜치**: `[###-feature-name]` | **날짜**: [날짜] | **명세서**: [링크]
**입력**: `/specs/[###-feature-name]/spec.md`의 기능 명세서

**참고**: 이 템플릿은 `/speckit.plan` 명령어로 작성됩니다. 실행 워크플로우는 `.specify/templates/commands/plan.md`를 참조하세요.

## 요약

[기능 명세서에서 추출: 주요 요구사항 + 연구를 통한 기술적 접근법]

## 기술 컨텍스트

<!--
  조치 필요: 이 섹션의 내용을 프로젝트의 기술 세부사항으로 교체하세요.
  여기의 구조는 반복 프로세스를 안내하기 위한 권고사항입니다.
-->

**언어/버전**: [예: Python 3.11, Swift 5.9, Rust 1.75 또는 명확화 필요]
**주요 의존성**: [예: FastAPI, UIKit, LLVM 또는 명확화 필요]
**저장소**: [해당되는 경우, 예: PostgreSQL, CoreData, 파일 또는 해당없음]
**테스트**: [예: pytest, XCTest, cargo test 또는 명확화 필요]
**대상 플랫폼**: [예: Linux 서버, iOS 15+, WASM 또는 명확화 필요]
**프로젝트 유형**: [단일/웹/모바일 - 소스 구조 결정]
**성능 목표**: [도메인별, 예: 1000 req/s, 10k lines/sec, 60 fps 또는 명확화 필요]
**제약사항**: [도메인별, 예: <200ms p95, <100MB 메모리, 오프라인 지원 또는 명확화 필요]
**규모/범위**: [도메인별, 예: 10k 사용자, 1M LOC, 50개 화면 또는 명확화 필요]

## 헌법 검사

*게이트: Phase 0 연구 전에 통과해야 함. Phase 1 설계 후 재검사.*

[헌법 파일을 기반으로 게이트 결정]

## 프로젝트 구조

### 문서화 (이 기능)

```
specs/[###-feature]/
├── plan.md              # 이 파일 (/speckit.plan 명령어 출력)
├── research.md          # Phase 0 출력 (/speckit.plan 명령어)
├── data-model.md        # Phase 1 출력 (/speckit.plan 명령어)
├── quickstart.md        # Phase 1 출력 (/speckit.plan 명령어)
├── contracts/           # Phase 1 출력 (/speckit.plan 명령어)
└── tasks.md             # Phase 2 출력 (/speckit.tasks 명령어 - /speckit.plan으로 생성 안됨)
```

### 소스 코드 (저장소 루트)
<!--
  조치 필요: 아래의 플레이스홀더 트리를 이 기능의 구체적인 레이아웃으로 교체하세요.
  사용하지 않는 옵션은 삭제하고 선택한 구조를 실제 경로로 확장하세요
  (예: apps/admin, packages/something). 최종 계획에는 옵션 레이블을 포함하면 안됩니다.
-->

```
# [사용하지 않으면 제거] 옵션 1: 단일 프로젝트 (기본)
src/
├── models/
├── services/
├── cli/
└── lib/

tests/
├── contract/
├── integration/
└── unit/

# [사용하지 않으면 제거] 옵션 2: 웹 애플리케이션 ("frontend" + "backend" 감지 시)
backend/
├── src/
│   ├── models/
│   ├── services/
│   └── api/
└── tests/

frontend/
├── src/
│   ├── components/
│   ├── pages/
│   └── services/
└── tests/

# [사용하지 않으면 제거] 옵션 3: 모바일 + API ("iOS/Android" 감지 시)
api/
└── [위의 backend와 동일]

ios/ or android/
└── [플랫폼별 구조: 기능 모듈, UI 플로우, 플랫폼 테스트]
```

**구조 결정**: [선택한 구조를 문서화하고 위에서 캡처한 실제 디렉토리 참조]

## 복잡도 추적

*헌법 검사에서 정당화가 필요한 위반이 있는 경우에만 작성*

| 위반 사항 | 필요한 이유 | 더 간단한 대안을 거부한 이유 |
|-----------|------------|-------------------------------------|
| [예: 4번째 프로젝트] | [현재 필요사항] | [3개 프로젝트로 부족한 이유] |
| [예: 레포지토리 패턴] | [특정 문제] | [직접 DB 접근이 불충분한 이유] |
