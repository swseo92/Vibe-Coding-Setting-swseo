# 테스트 가이드라인

Python 프로젝트의 테스트 코드 작성 및 관리 규칙을 정의합니다.

## 테스트 구조

### 디렉토리 구조
```
tests/
├── unit/                          # 단위 테스트 (빠른 실행)
│   └── test_myproject/
│       ├── test_models/
│       │   ├── test_user.py
│       │   └── test_product.py
│       ├── test_services/
│       │   ├── test_auth_service.py
│       │   └── test_data_service.py
│       └── test_utils/
│           ├── test_validators.py
│           └── test_helpers.py
├── integration/                   # 통합 테스트 (외부 의존성)
│   └── test_myproject/
│       ├── test_api/
│       │   ├── test_auth_endpoints.py
│       │   └── test_user_endpoints.py
│       └── test_database/
│           └── test_repositories.py
├── e2e/                          # 종단간 테스트 (전체 워크플로우)
│   └── test_workflows/
│       ├── test_user_registration_flow.py
│       └── test_order_processing_flow.py
└── conftest.py                   # 전역 설정
```

### 테스트 카테고리

#### Unit Tests (단위 테스트)
- 개별 함수/클래스 테스트
- 외부 의존성 모킹
- 빠른 실행 (< 1초)

#### Integration Tests (통합 테스트)
- 모듈 간 상호작용 테스트
- 외부 서비스 연동 (API, 데이터베이스, 외부 라이브러리 등)
- 중간 실행 시간 (1-10초)

#### E2E Tests (종단간 테스트)
- 전체 워크플로우 테스트
- 실제 사용자 시나리오
- 긴 실행 시간 (10초+)

## 파일 및 함수 명명 규칙

### 파일 명명
- **단순한 모듈**: `test_{module_name}.py`
  ```
  test_supervisor.py          # supervisor.py 테스트
  test_state_manager.py       # state_manager.py 테스트
  ```

- **복잡한 모듈**: `test_{module_name}/` 폴더로 기능별 분리
  ```
  test_slide_generate_agent/
  ├── test_graph.py          # 그래프 로직
  ├── test_state.py          # 상태 관리
  ├── test_nodes.py          # 노드 기능
  └── test_workflows.py      # 워크플로우
  ```

### 함수 명명
기본적으로 **함수 기반** 테스트 사용. 클래스는 공통 setup이 필요할 때만 사용.

```python
# 기본 패턴: test_{action}_{expected_result}_when_{condition}
def test_calculate_total_returns_correct_sum_when_valid_numbers():
def test_validate_email_raises_error_when_invalid_format():

# 간단한 경우: test_{what_it_tests}
def test_user_creation():
def test_password_validation():

# 특정 기능 테스트
def test_api_authentication():
def test_database_connection():
def test_file_processing_workflow():
```

### 클래스 사용 (선택적)
```python
# 공통 setup/teardown이 필요한 경우만
class TestUserService:
    def setup_method(self):
        self.user_service = UserService()
        self.test_user_data = {"email": "test@example.com", "name": "Test User"}

    def test_create_user_with_valid_data(self):
        pass

    def test_update_user_profile(self):
        pass
```

## conftest.py 구조

### 계층별 역할

#### `tests/conftest.py` (전역)
- 환경 변수 설정 (TEST_MODE=true)
- 기본 로깅 설정
- 공통 유틸리티 픽스처

#### `tests/unit/conftest.py` (단위 테스트)
- 외부 의존성 모킹 (API, 데이터베이스, 외부 라이브러리 등)
- 빠른 실행을 위한 설정

#### `tests/integration/conftest.py` (통합 테스트)
- 실제 서비스 연결 설정
- 외부 API 테스트 환경 구성

#### `tests/e2e/conftest.py` (E2E 테스트)
- 전체 워크플로우 테스트 환경
- 실제 애플리케이션 환경 설정

#### `tests/unit/test_myproject/conftest.py` (라이브러리 전용)
- 프로젝트별 특수 픽스처
- 테스트 데이터 및 설정

## 실행 가이드

### 기본 실행
```bash
# 전체 테스트
pytest tests/

# 카테고리별 실행
pytest tests/unit/          # 개발 중 빠른 피드백
pytest tests/integration/   # 배포 전 검증
pytest tests/e2e/          # 릴리즈 전 전체 검증
```

### pytest 설정 (pytest.ini)
```ini
[tool:pytest]
# 테스트 디렉토리 지정
testpaths = tests

# 기본 옵션
addopts =
    --strict-markers
    --strict-config
    --verbose
    --tb=short
    --cov=myproject
    --cov-report=term-missing
    --cov-report=html
    --cov-fail-under=80

# 커스텀 마커 정의
markers =
    slow: 느린 테스트 (10초 이상)
    integration: 통합 테스트
    e2e: 종단간 테스트
    api: API 테스트
    database: 데이터베이스 테스트

# 경고 필터
filterwarnings =
    error
    ignore::UserWarning
    ignore::DeprecationWarning
```

### 마커 활용
```python
# 느린 테스트 마킹
@pytest.mark.slow
def test_large_dataset_processing():
    pass

# 외부 의존성 테스트
@pytest.mark.integration
@pytest.mark.api
def test_external_api_call():
    pass

# 실행 예시
# pytest -m "not slow"           # 느린 테스트 제외
# pytest -m "integration"        # 통합 테스트만
# pytest -m "not (slow or e2e)"  # 빠른 테스트만
```

## 개발 워크플로우

1. **개발 중**: `pytest tests/unit/` (빠른 피드백)
2. **PR 전**: `pytest tests/unit/ tests/integration/`
3. **배포 전**: `pytest tests/` (전체 검증)

## 주의사항

- **외부 의존성**: 단위 테스트에서는 반드시 모킹
- **비동기 코드**: async/await 테스트 시 pytest-asyncio 활용
- **테스트 격리**: 각 테스트는 독립적으로 실행 가능해야 함
- **데이터 정리**: 테스트 후 생성된 파일/상태 정리
- **환경 변수**: 테스트용 환경 변수는 conftest.py에서 설정

## 테스트 작성 모범 사례

### AAA 패턴 (Arrange-Act-Assert)
```python
def test_calculate_discount():
    # Arrange: 테스트 데이터 준비
    original_price = 100
    discount_rate = 0.2

    # Act: 테스트할 기능 실행
    discounted_price = calculate_discount(original_price, discount_rate)

    # Assert: 결과 검증
    assert discounted_price == 80
```

### 픽스처 활용
```python
# conftest.py
@pytest.fixture
def sample_user():
    return {"id": 1, "name": "Test User", "email": "test@example.com"}

@pytest.fixture
def database_session():
    # 테스트 데이터베이스 세션 생성
    session = create_test_session()
    yield session
    session.close()

# 테스트 파일
def test_create_user(sample_user, database_session):
    user = create_user(sample_user, database_session)
    assert user.id == sample_user["id"]
```

### 예외 테스트
```python
def test_divide_by_zero_raises_exception():
    with pytest.raises(ZeroDivisionError):
        divide(10, 0)

def test_invalid_email_raises_validation_error():
    with pytest.raises(ValidationError, match="Invalid email format"):
        validate_email("invalid-email")
```

### 매개변수화 테스트
```python
@pytest.mark.parametrize("input_value,expected", [
    (0, "zero"),
    (1, "positive"),
    (-1, "negative"),
])
def test_number_classification(input_value, expected):
    result = classify_number(input_value)
    assert result == expected
```

## 모킹 가이드라인

### unittest.mock 활용
```python
from unittest.mock import Mock, patch, MagicMock

# 외부 API 호출 모킹
@patch('myproject.services.api_client.requests.get')
def test_fetch_user_data(mock_get):
    mock_get.return_value.json.return_value = {"id": 1, "name": "Test"}

    result = fetch_user_data(1)
    assert result["name"] == "Test"
    mock_get.assert_called_once_with("/api/users/1")

# 클래스 메서드 모킹
def test_email_service(monkeypatch):
    mock_send = Mock(return_value=True)
    monkeypatch.setattr('myproject.services.EmailService.send', mock_send)

    service = EmailService()
    result = service.send_welcome_email("test@example.com")
    assert result is True
```

## 테스트 데이터 관리

### 팩토리 패턴 활용
```python
# tests/factories.py
class UserFactory:
    @staticmethod
    def create(**kwargs):
        defaults = {
            "name": "Test User",
            "email": "test@example.com",
            "age": 25
        }
        defaults.update(kwargs)
        return User(**defaults)

# 테스트에서 사용
def test_user_creation():
    user = UserFactory.create(name="John Doe")
    assert user.name == "John Doe"
    assert user.email == "test@example.com"
```

### 테스트 데이터 파일
```python
# tests/data/sample_data.json
{
    "users": [
        {"id": 1, "name": "Alice", "role": "admin"},
        {"id": 2, "name": "Bob", "role": "user"}
    ]
}

# 테스트에서 로드
import json
from pathlib import Path

def load_test_data(filename):
    data_path = Path(__file__).parent / "data" / filename
    with open(data_path) as f:
        return json.load(f)
```

## 성능 및 커버리지

### 테스트 성능 모니터링
```bash
# 느린 테스트 식별
pytest --durations=10

# 특정 시간 이상 걸리는 테스트만 표시
pytest --durations=0 --durations-min=1.0
```

### 코드 커버리지
```bash
# 커버리지 측정
pip install pytest-cov
pytest --cov=myproject tests/

# HTML 리포트 생성
pytest --cov=myproject --cov-report=html tests/

# 특정 커버리지 임계값 설정
pytest --cov=myproject --cov-fail-under=80 tests/
```

## CI/CD 통합

### GitHub Actions 예시
```yaml
# .github/workflows/test.yml
name: Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: [3.8, 3.9, 3.10, 3.11]

    steps:
    - uses: actions/checkout@v3
    - name: Set up Python
      uses: actions/setup-python@v3
      with:
        python-version: ${{ matrix.python-version }}

    - name: Install dependencies
      run: |
        pip install -r requirements.txt
        pip install pytest pytest-cov

    - name: Run tests
      run: |
        pytest tests/unit/ tests/integration/ --cov=myproject

    - name: Run E2E tests
      run: pytest tests/e2e/
      if: github.event_name == 'push' && github.ref == 'refs/heads/main'
```

## 도구 추천

### 필수 라이브러리
```bash
pip install pytest                    # 테스트 프레임워크
pip install pytest-cov                # 커버리지 측정
pip install pytest-mock               # 모킹 도구
pip install pytest-asyncio            # 비동기 테스트
pip install pytest-xdist              # 병렬 테스트 실행
```

### 선택적 도구
```bash
pip install pytest-benchmark          # 성능 벤치마크
pip install pytest-html               # HTML 테스트 리포트
pip install pytest-sugar              # 더 나은 테스트 출력
pip install factory-boy               # 테스트 데이터 팩토리
```