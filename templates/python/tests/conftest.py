"""
전역 테스트 설정
- .env 파일에서 환경 변수 로드 (python-dotenv)
- VCR 설정 (API 녹음/재생)
- 기본 로깅 설정
- 공통 유틸리티 픽스처
"""
import os
import logging
import pytest
from pathlib import Path
from dotenv import load_dotenv

# .env 파일 로드 (프로젝트 루트에서)
# Priority: .env.local > .env
env_local = Path(__file__).parent.parent / ".env.local"
env_file = Path(__file__).parent.parent / ".env"

if env_local.exists():
    load_dotenv(env_local, override=True)
elif env_file.exists():
    load_dotenv(env_file)

# 테스트 모드 환경 변수 설정 (필요시 override)
os.environ.setdefault("TEST_MODE", "true")


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


# VCR (API 녹음/재생) 설정
@pytest.fixture(scope="module")
def vcr_config():
    """
    VCR 설정: 실제 API 호출을 녹음하고 재생

    첫 실행: 실제 API 호출 → cassette(.yaml)에 저장
    이후 실행: cassette에서 재생 (API 호출 없음)

    주의: 녹음 시 API 키가 cassette에 포함되지 않도록 필터링됨
    """
    return {
        # 민감한 헤더 필터링 (API 키 보호)
        "filter_headers": ["authorization", "x-api-key", "x-openai-key"],

        # 녹음 모드: "once"는 cassette이 없을 때만 실제 API 호출
        "record_mode": "once",

        # Cassette 저장 위치
        "cassette_library_dir": str(Path(__file__).parent / "cassettes"),

        # 요청 필터링 함수 (추가 보안)
        "before_record_request": _filter_request,
        "before_record_response": _filter_response,
    }


def _filter_request(request):
    """
    요청에서 민감한 정보 필터링
    """
    # Authorization 헤더 마스킹
    if "Authorization" in request.headers:
        request.headers["Authorization"] = "[FILTERED]"
    if "X-API-Key" in request.headers:
        request.headers["X-API-Key"] = "[FILTERED]"
    return request


def _filter_response(response):
    """
    응답에서 민감한 정보 필터링 (필요시)
    """
    # 대부분의 경우 응답은 안전하지만, 필요시 필터링 가능
    return response
