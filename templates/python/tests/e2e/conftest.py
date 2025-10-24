"""
E2E (종단간) 테스트 설정
- 전체 워크플로우 테스트 환경
- 실제 애플리케이션 환경 설정
- 브라우저 자동화 설정 (필요시)
"""
import pytest


@pytest.fixture(scope="session")
def app_server():
    """애플리케이션 서버 시작"""
    # 실제 애플리케이션 서버 시작
    # server = start_test_server()
    # yield server
    # server.stop()
    yield None  # 실제 구현 시 교체


@pytest.fixture(scope="session")
def browser():
    """브라우저 인스턴스 (Playwright, Selenium 등)"""
    # 브라우저 자동화가 필요한 경우
    # browser = launch_browser()
    # yield browser
    # browser.close()
    yield None  # 실제 구현 시 교체


@pytest.fixture
def test_user():
    """E2E 테스트용 사용자 계정"""
    user_data = {
        "username": "e2e_test_user",
        "email": "e2e@test.com",
        "password": "test_password_123"
    }
    # 테스트 사용자 생성
    # user = create_test_user(**user_data)
    yield user_data
    # 테스트 사용자 삭제
    # delete_test_user(user.id)


@pytest.fixture(autouse=True)
def reset_application_state():
    """각 E2E 테스트 전후 애플리케이션 상태 초기화"""
    # 테스트 전 준비
    yield
    # 테스트 후 정리
    # - 생성된 데이터 삭제
    # - 파일 시스템 정리
    # - 캐시 초기화 등
    pass


@pytest.fixture
def test_data_factory():
    """E2E 테스트용 데이터 생성 팩토리"""
    created_items = []

    def create_item(item_type, **kwargs):
        # 실제 데이터 생성 로직
        # item = create_real_data(item_type, **kwargs)
        # created_items.append(item)
        # return item
        return None

    yield create_item

    # 테스트 후 생성된 모든 아이템 정리
    # for item in created_items:
    #     delete_item(item)
