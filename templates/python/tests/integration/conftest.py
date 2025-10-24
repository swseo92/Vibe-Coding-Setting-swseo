"""
통합 테스트 설정
- 실제 서비스 연결 설정
- 외부 API 테스트 환경 구성
- 테스트 데이터베이스 설정
"""
import pytest


@pytest.fixture(scope="session")
def test_database_url():
    """테스트용 데이터베이스 URL"""
    # 환경 변수나 설정 파일에서 가져오기
    return "sqlite:///test.db"


@pytest.fixture(scope="session")
def database_connection(test_database_url):
    """실제 데이터베이스 연결 (세션 범위)"""
    # 실제 데이터베이스 연결 생성
    # connection = create_engine(test_database_url)
    # yield connection
    # connection.dispose()
    yield None  # 실제 구현 시 교체


@pytest.fixture
def database_session(database_connection):
    """각 테스트마다 새로운 데이터베이스 세션"""
    # session = Session(database_connection)
    # yield session
    # session.rollback()  # 테스트 후 롤백
    # session.close()
    yield None  # 실제 구현 시 교체


@pytest.fixture
def api_test_client():
    """API 테스트 클라이언트"""
    # 실제 API 서버 또는 테스트 서버에 연결
    # client = TestClient(app)
    # yield client
    yield None  # 실제 구현 시 교체


@pytest.fixture(autouse=True)
def cleanup_test_data(database_session):
    """각 테스트 후 생성된 테스트 데이터 정리"""
    yield
    # 테스트 데이터 정리 로직
    pass
