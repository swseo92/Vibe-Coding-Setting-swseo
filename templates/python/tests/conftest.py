"""
전역 테스트 설정
- 환경 변수 설정
- 기본 로깅 설정
- 공통 유틸리티 픽스처
"""
import os
import logging
import pytest


# 테스트 모드 환경 변수 설정
os.environ["TEST_MODE"] = "true"


# 로깅 설정
@pytest.fixture(scope="session", autouse=True)
def setup_logging():
    """테스트 실행 시 로깅 설정"""
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
    )
    yield
    # 테스트 종료 후 정리
    logging.shutdown()


# 공통 픽스처 예시
@pytest.fixture
def sample_data():
    """테스트용 샘플 데이터"""
    return {
        "id": 1,
        "name": "Test User",
        "email": "test@example.com"
    }


@pytest.fixture
def temp_directory(tmp_path):
    """임시 디렉토리 픽스처"""
    test_dir = tmp_path / "test_data"
    test_dir.mkdir()
    yield test_dir
    # 자동으로 정리됨 (tmp_path가 처리)
