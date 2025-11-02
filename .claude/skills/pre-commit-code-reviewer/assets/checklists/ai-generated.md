# AI 생성 코드 검증 체크리스트 (Vibe Coding)

AI(Claude, Codex, Gemini 등)로 생성된 코드를 커밋 전에 검증하는 체크리스트.

---

## 🎯 일반화 & 재사용성 (Critical)

### 하드코딩 제거
- [ ] 매직 넘버/문자열이 상수로 정의됨
- [ ] 파일 경로가 설정/환경변수로 분리됨
- [ ] API 엔드포인트/DB 정보가 하드코딩 안 됨
- [ ] 특정 케이스만 동작하는 조건문 없음

### 파라미터화
- [ ] 반복되는 값이 함수 매개변수로 추출됨
- [ ] 환경별 설정이 분리됨 (dev/staging/prod)
- [ ] 사용자 입력/설정으로 동작 변경 가능

### 예시
```python
# ❌ 특정 케이스만 동작
def process_user():
    user = db.query("SELECT * FROM users WHERE id = 123")  # 하드코딩
    return user

# ✅ 일반화됨
def process_user(user_id: int):
    user = db.query("SELECT * FROM users WHERE id = ?", (user_id,))
    return user
```

---

## 🏗️ 코드 구조화 (Critical)

### 파일 분리
- [ ] 단일 파일이 200줄 이하 (또는 합리적 크기)
- [ ] 관련 기능별로 모듈 분리됨
- [ ] main/entry point와 로직이 분리됨
- [ ] 유틸리티 함수가 별도 파일로 추출됨

### 폴더 구조
- [ ] 논리적 폴더 구조 존재 (src/, tests/, docs/ 등)
- [ ] 설정 파일이 적절한 위치 (config/, .env)
- [ ] 스크립트와 라이브러리 코드 분리

### 예시
```
# ❌ 모놀리식 구조
my-project/
  └── main.py  (1500줄 - 모든 코드가 여기)

# ✅ 구조화됨
my-project/
  ├── src/
  │   ├── api/
  │   ├── models/
  │   └── utils/
  ├── tests/
  ├── config/
  └── main.py  (진입점만)
```

---

## ✂️ 함수 분리 & 모듈화 (Critical)

### 함수 크기
- [ ] 함수가 50줄 이하 (복잡한 경우 100줄 한도)
- [ ] 하나의 함수가 하나의 책임만 (SRP)
- [ ] 중첩 깊이 < 4 레벨

### 재사용 가능성
- [ ] 중복 코드가 함수로 추출됨
- [ ] 공통 로직이 유틸리티로 분리됨
- [ ] 함수가 독립적으로 테스트 가능

### 객체지향 원칙
- [ ] 관련 데이터와 메서드가 클래스로 그룹화됨
- [ ] 클래스 책임이 명확함 (SRP)
- [ ] 불필요한 클래스 생성 안 함 (과도한 추상화 방지)

### 예시
```python
# ❌ 거대한 단일 함수
def process_everything():
    # 100줄의 코드...
    # DB 접속, 데이터 처리, 파일 저장, 이메일 발송 모두 여기서
    pass

# ✅ 함수 분리됨
def fetch_data(user_id: int) -> dict:
    """DB에서 데이터 가져오기"""
    pass

def transform_data(raw_data: dict) -> dict:
    """데이터 변환"""
    pass

def save_result(data: dict, filepath: str) -> None:
    """결과 저장"""
    pass

def process_user(user_id: int, output_path: str) -> None:
    """전체 프로세스 조율"""
    data = fetch_data(user_id)
    transformed = transform_data(data)
    save_result(transformed, output_path)
```

---

## 📝 문서 동기화 (Critical)

### 코드-문서 일치
- [ ] README가 최신 사용법 반영
- [ ] Docstring이 실제 함수 동작과 일치
- [ ] 주석이 현재 코드 설명 (오래된 주석 제거)
- [ ] CHANGELOG 업데이트 (breaking changes)

### 문서 완성도
- [ ] 설치 방법 명시
- [ ] 사용 예시 포함 (코드 스니펫)
- [ ] 의존성 명시 (requirements.txt)
- [ ] 제약사항/알려진 이슈 문서화

### 예시
```python
# ❌ 문서와 코드 불일치
def get_user(id: int) -> dict:
    """사용자 정보 반환

    Returns:
        User: 사용자 객체  # 실제로는 dict 반환
    """
    return {"id": id, "name": "John"}

# ✅ 문서 정확함
def get_user(user_id: int) -> dict:
    """사용자 정보를 dict로 반환

    Args:
        user_id: 사용자 ID

    Returns:
        dict: {"id": int, "name": str} 형태의 사용자 정보

    Raises:
        ValueError: user_id가 0 이하일 때
    """
    if user_id <= 0:
        raise ValueError("Invalid user_id")
    return {"id": user_id, "name": "John"}
```

---

## 🚨 AI가 자주 놓치는 항목 (Critical)

### 에러 핸들링
- [ ] 외부 호출(API, DB, 파일)에 try-except
- [ ] 에러 시 적절한 롤백/정리
- [ ] 의미있는 에러 메시지

### 엣지 케이스
- [ ] None/null 입력 처리
- [ ] 빈 컬렉션 처리 ([], {}, "")
- [ ] 경계값 검증 (0, 음수, 최댓값)

### 리소스 관리
- [ ] 파일 핸들 명시적 close (또는 with 사용)
- [ ] DB 연결 정리
- [ ] 메모리 누수 방지

---

## ⚠️ 유지보수성 (Warning)

### 가독성
- [ ] 변수/함수명이 의미 명확
- [ ] 매직 넘버에 주석 (또는 상수화)
- [ ] 복잡한 로직에 설명 주석

### 확장 가능성
- [ ] 새 기능 추가 시 기존 코드 수정 최소화
- [ ] 설정으로 동작 변경 가능
- [ ] 플러그인/훅 포인트 존재 (필요 시)

### 테스트 용이성
- [ ] 의존성 주입 가능
- [ ] 외부 의존성 mocking 가능
- [ ] 단위 테스트 작성 가능한 구조

---

## 🔍 실제 동작 검증 (Critical)

### 실행 확인
- [ ] **반드시 실제 실행해봄** (AI는 실행 안 해봤을 수 있음)
- [ ] 여러 입력값으로 테스트
- [ ] 로그 확인 (의도한 대로 동작하는지)

### 엣지 케이스 테스트
- [ ] 빈 입력으로 실행
- [ ] 최댓값/최솟값 입력
- [ ] 잘못된 형식 입력

---

## ✅ Scoring Guide

**Pass 기준:**
- 일반화 & 재사용성: 100% 통과
- 코드 구조화: 100% 통과
- 함수 분리: 80% 이상
- 문서 동기화: 100% 통과
- 실제 동작 검증: 필수

**AI 생성 코드 특별 규칙:**
- 특정 케이스만 동작하는 코드 → 자동 Fail
- 1000줄 넘는 단일 파일 → 자동 Fail
- 문서와 코드 불일치 → 자동 Fail
- 실제 실행 안 해봄 → 자동 Fail

---

## 💡 리팩토링 우선순위

AI 생성 코드 개선 시 이 순서로:

1. **일반화** - 하드코딩 제거, 파라미터화
2. **구조화** - 파일/폴더 분리
3. **함수 분리** - 큰 함수 쪼개기
4. **문서 업데이트** - README, docstring 동기화
5. **테스트 추가** - 엣지 케이스, 에러 케이스

---

**Version:** 1.0
**Last Updated:** 2025-11-03
**Based on:** Real-world Vibe Coding experience
