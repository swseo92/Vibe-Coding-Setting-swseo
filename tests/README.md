# Tests

이 디렉토리는 Vibe-Coding-Setting 프로젝트의 테스트를 포함합니다.

## 테스트 실행

### 전체 테스트 실행

```bash
pytest tests/
```

### 특정 테스트 파일 실행

```bash
pytest tests/test_update_speckit.py
```

### Verbose 모드

```bash
pytest tests/ -v
```

### Coverage 리포트

```bash
pytest tests/ --cov=.claude --cov-report=html
```

## 테스트 구조

```
tests/
├── __init__.py
├── README.md
└── test_update_speckit.py    # SpeckitManager 테스트
```

## 테스트 대상

### test_update_speckit.py

`SpeckitManager` 클래스의 핵심 기능을 테스트합니다:

- ✅ 초기화 및 설정
- ✅ 임시 디렉토리 생성/정리
- ✅ 커밋 해시 형식 검증
- ✅ 파일 개수 확인
- ✅ Workspace 검증
- ✅ Git clone/pull 동작

## 필수 패키지

```bash
pip install pytest pytest-cov
```

또는:

```bash
uv pip install pytest pytest-cov
```

## 테스트 작성 가이드

1. **파일명**: `test_*.py` 형식 사용
2. **클래스명**: `Test*` 형식 사용
3. **메서드명**: `test_*` 형식 사용
4. **Fixtures**: `@pytest.fixture` 데코레이터 사용
5. **Mock**: `unittest.mock` 또는 `pytest-mock` 사용

## 예시

```python
import pytest
from pathlib import Path

def test_example():
    assert 1 + 1 == 2

@pytest.fixture
def temp_dir(tmp_path):
    """임시 디렉토리 fixture"""
    return tmp_path

def test_with_fixture(temp_dir):
    """Fixture를 사용하는 테스트"""
    test_file = temp_dir / "test.txt"
    test_file.write_text("Hello")
    assert test_file.read_text() == "Hello"
```
