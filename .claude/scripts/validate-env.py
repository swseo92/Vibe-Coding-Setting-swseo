#!/usr/bin/env python3
"""
Environment Variable Validation Script

환경변수 누락 또는 형식 오류를 검증하는 스크립트입니다.
프로젝트 초기화 시 또는 pre-commit hook에서 실행하여
필수 환경변수가 올바르게 설정되었는지 확인합니다.

Usage:
    python .claude/scripts/validate-env.py
    python .claude/scripts/validate-env.py --strict  # 선택적 환경변수도 검증

Exit codes:
    0: 모든 검증 통과
    1: 필수 환경변수 누락 또는 형식 오류
    2: 선택적 환경변수 누락 (--strict 모드만)
"""

import os
import sys
from pathlib import Path
from typing import Dict, List, Tuple, Optional
import argparse


class ValidationResult:
    """검증 결과를 담는 클래스"""

    def __init__(self):
        self.errors: List[str] = []
        self.warnings: List[str] = []
        self.info: List[str] = []

    def add_error(self, message: str):
        self.errors.append(f"ERROR: {message}")

    def add_warning(self, message: str):
        self.warnings.append(f"WARNING: {message}")

    def add_info(self, message: str):
        self.info.append(f"INFO: {message}")

    def has_errors(self) -> bool:
        return len(self.errors) > 0

    def has_warnings(self) -> bool:
        return len(self.warnings) > 0

    def print_results(self):
        """검증 결과 출력"""
        if self.errors:
            print("\n=== ERRORS ===")
            for error in self.errors:
                print(f"  {error}")

        if self.warnings:
            print("\n=== WARNINGS ===")
            for warning in self.warnings:
                print(f"  {warning}")

        if self.info:
            print("\n=== INFO ===")
            for info in self.info:
                print(f"  {info}")

        if not self.errors and not self.warnings:
            print("\n[OK] All environment variables are valid!")


class EnvValidator:
    """환경변수 검증기"""

    # 환경변수 정의
    # Format: (변수명, 필수여부, 검증함수, 설명)
    REQUIRED_VARS: List[Tuple[str, bool, Optional[callable], str]] = [
        # 필수 환경변수
        # ("DATABASE_URL", True, None, "Database connection string"),

        # 선택적 환경변수
        ("LINEAR_API_KEY", False, lambda v: v.startswith("lin_api_"),
         "Linear API key (should start with 'lin_api_')"),
        ("OPENAI_API_KEY", False, lambda v: v.startswith("sk-"),
         "OpenAI API key (should start with 'sk-')"),
        ("ANTHROPIC_API_KEY", False, lambda v: v.startswith("sk-ant-"),
         "Anthropic API key (should start with 'sk-ant-')"),
    ]

    def __init__(self, env_path: Optional[Path] = None, strict: bool = False):
        """
        Args:
            env_path: .env 파일 경로 (None이면 현재 디렉토리에서 검색)
            strict: True면 선택적 환경변수도 검증
        """
        self.env_path = env_path or self._find_env_file()
        self.strict = strict
        self.result = ValidationResult()

    def _find_env_file(self) -> Optional[Path]:
        """프로젝트 루트의 .env 파일 찾기"""
        current = Path.cwd()

        # 현재 디렉토리부터 상위로 탐색
        for _ in range(5):  # 최대 5단계 상위까지
            env_file = current / ".env"
            if env_file.exists():
                return env_file

            # claude.md나 pyproject.toml이 있으면 프로젝트 루트로 간주
            if (current / "claude.md").exists() or (current / "pyproject.toml").exists():
                return current / ".env"

            parent = current.parent
            if parent == current:  # 루트 도달
                break
            current = parent

        return Path(".env")  # 기본값

    def validate(self) -> ValidationResult:
        """환경변수 검증 실행"""
        # 1. .env 파일 존재 여부 확인
        if not self.env_path.exists():
            self.result.add_error(f".env file not found at {self.env_path.absolute()}")
            self.result.add_info("Copy .env.example to .env and configure your environment variables")
            return self.result

        # 2. .env 파일 로드 (python-dotenv 없이 수동 파싱)
        env_vars = self._load_env_file()

        # 3. 각 환경변수 검증
        for var_name, is_required, validator, description in self.REQUIRED_VARS:
            self._validate_variable(var_name, is_required, validator, description, env_vars)

        return self.result

    def _load_env_file(self) -> Dict[str, str]:
        """
        .env 파일 수동 파싱 (python-dotenv 의존성 제거)

        Returns:
            Dict[변수명, 값]
        """
        env_vars = {}

        try:
            with open(self.env_path, 'r', encoding='utf-8') as f:
                for line_num, line in enumerate(f, 1):
                    line = line.strip()

                    # 주석 또는 빈 줄 무시
                    if not line or line.startswith('#'):
                        continue

                    # KEY=VALUE 형식 파싱
                    if '=' in line:
                        # 첫 번째 = 기준으로 split (값에 =가 있을 수 있음)
                        key, value = line.split('=', 1)
                        key = key.strip()
                        value = value.strip()

                        # 따옴표 제거 (optional)
                        if value.startswith('"') and value.endswith('"'):
                            value = value[1:-1]
                        elif value.startswith("'") and value.endswith("'"):
                            value = value[1:-1]

                        env_vars[key] = value

        except Exception as e:
            self.result.add_error(f"Failed to read .env file: {e}")

        return env_vars

    def _validate_variable(
        self,
        var_name: str,
        is_required: bool,
        validator: Optional[callable],
        description: str,
        env_vars: Dict[str, str]
    ):
        """개별 환경변수 검증"""
        value = env_vars.get(var_name) or os.getenv(var_name)

        # 1. 존재 여부 확인
        if not value:
            if is_required:
                self.result.add_error(f"{var_name} is required but not set")
                self.result.add_info(f"  {description}")
            elif self.strict:
                self.result.add_warning(f"{var_name} is not set (optional)")
                self.result.add_info(f"  {description}")
            return

        # 2. 빈 문자열 체크
        if value.strip() == "":
            if is_required:
                self.result.add_error(f"{var_name} is empty")
            elif self.strict:
                self.result.add_warning(f"{var_name} is empty (optional)")
            return

        # 3. 커스텀 검증 함수 실행
        if validator:
            try:
                if not validator(value):
                    self.result.add_error(
                        f"{var_name} has invalid format: {description}"
                    )
            except Exception as e:
                self.result.add_error(
                    f"{var_name} validation failed: {e}"
                )


def main():
    parser = argparse.ArgumentParser(
        description="Validate environment variables for the project"
    )
    parser.add_argument(
        "--strict",
        action="store_true",
        help="Also validate optional environment variables"
    )
    parser.add_argument(
        "--env-file",
        type=Path,
        help="Path to .env file (default: auto-detect)"
    )

    args = parser.parse_args()

    # 검증 실행
    validator = EnvValidator(env_path=args.env_file, strict=args.strict)
    result = validator.validate()

    # 결과 출력
    result.print_results()

    # Exit code 설정
    if result.has_errors():
        sys.exit(1)
    elif args.strict and result.has_warnings():
        sys.exit(2)
    else:
        sys.exit(0)


if __name__ == "__main__":
    main()
