"""
단위 테스트 설정
- 외부 의존성 모킹 (API, 데이터베이스, 외부 라이브러리 등)
- 빠른 실행을 위한 설정
"""
import pytest
from unittest.mock import Mock, MagicMock


@pytest.fixture
def mock_api_client():
    """외부 API 클라이언트 모킹"""
    mock_client = Mock()
    mock_client.get.return_value = {"status": "success", "data": {}}
    mock_client.post.return_value = {"status": "created", "id": 1}
    return mock_client


@pytest.fixture
def mock_database():
    """데이터베이스 연결 모킹"""
    mock_db = MagicMock()
    mock_db.connect.return_value = True
    mock_db.execute.return_value = []
    mock_db.commit.return_value = None
    return mock_db


@pytest.fixture(autouse=True)
def reset_mocks():
    """각 테스트 후 모든 모킹 초기화"""
    yield
    # 테스트 후 정리 작업
    pass
