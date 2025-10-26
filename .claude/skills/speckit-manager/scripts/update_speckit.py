#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Speckit 업데이트 및 한글화 자동화 스크립트

이 스크립트는:
1. GitHub에서 최신 speckit을 clone/pull
2. 영어 파일들을 한글로 번역 (기존 한글 버전 참고)
3. 번역된 파일들을 Vibe-Coding-Setting 저장소에 적용
"""

import argparse
import os
import shutil
import subprocess
import sys
from pathlib import Path
from typing import Optional

# Windows 환경에서 UTF-8 출력 지원
if sys.platform == 'win32':
    import io
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', errors='replace')


class SpeckitManager:
    """Speckit 업데이트 및 한글화 관리 클래스"""

    SPECKIT_REPO = "https://github.com/github/spec-kit.git"
    SPECKIT_COMMANDS = [
        "speckit.analyze.md",
        "speckit.checklist.md",
        "speckit.clarify.md",
        "speckit.constitution.md",
        "speckit.implement.md",
        "speckit.plan.md",
        "speckit.specify.md",
        "speckit.tasks.md",
    ]
    SPECKIT_TEMPLATES = [
        "spec-template.md",
        "plan-template.md",
        "tasks-template.md",
        "checklist-template.md",
    ]

    def __init__(self, workspace_root: Path):
        """
        Args:
            workspace_root: Vibe-Coding-Setting 저장소 루트 디렉토리
        """
        self.workspace_root = workspace_root
        self.temp_dir = workspace_root / "tmp" / "speckit-update"
        self.speckit_clone_dir = self.temp_dir / "spec-kit"

    def ensure_temp_dir(self):
        """임시 디렉토리 생성"""
        self.temp_dir.mkdir(parents=True, exist_ok=True)
        print(f"[OK] 임시 디렉토리 생성: {self.temp_dir}")

    def clone_or_pull_speckit(self):
        """GitHub에서 최신 speckit clone 또는 pull"""
        if self.speckit_clone_dir.exists():
            print(f"[OK] 기존 speckit 발견, pull 진행...")
            result = subprocess.run(
                ["git", "pull"],
                cwd=self.speckit_clone_dir,
                capture_output=True,
                text=True,
            )
            if result.returncode != 0:
                raise RuntimeError(f"Git pull 실패: {result.stderr}")
            print(f"[OK] Speckit 업데이트 완료")
        else:
            print(f"[OK] Speckit clone 시작...")
            result = subprocess.run(
                ["git", "clone", self.SPECKIT_REPO, str(self.speckit_clone_dir)],
                capture_output=True,
                text=True,
            )
            if result.returncode != 0:
                raise RuntimeError(f"Git clone 실패: {result.stderr}")
            print(f"[OK] Speckit clone 완료")

    def get_latest_commit_hash(self) -> str:
        """최신 커밋 해시 가져오기"""
        result = subprocess.run(
            ["git", "rev-parse", "HEAD"],
            cwd=self.speckit_clone_dir,
            capture_output=True,
            text=True,
        )
        if result.returncode != 0:
            raise RuntimeError(f"Git 커밋 해시 가져오기 실패: {result.stderr}")
        return result.stdout.strip()[:8]

    def copy_commands_to_workspace(self):
        """영어 commands를 workspace의 speckit/ 폴더에 복사"""
        source_dir = self.speckit_clone_dir / ".claude" / "commands"
        dest_dir = self.workspace_root / "speckit" / ".claude" / "commands"

        if not source_dir.exists():
            raise RuntimeError(f"Speckit commands 디렉토리를 찾을 수 없습니다: {source_dir}")

        dest_dir.mkdir(parents=True, exist_ok=True)

        copied_count = 0
        for cmd_file in self.SPECKIT_COMMANDS:
            source_file = source_dir / cmd_file
            if source_file.exists():
                shutil.copy2(source_file, dest_dir / cmd_file)
                copied_count += 1
                print(f"  [OK] {cmd_file}")

        print(f"[OK] Commands 복사 완료 ({copied_count}개)")

    def copy_templates_to_workspace(self):
        """영어 templates를 workspace의 speckit/ 폴더에 복사"""
        source_dir = self.speckit_clone_dir / ".specify" / "templates"
        dest_dir = self.workspace_root / "speckit" / ".specify" / "templates"

        if not source_dir.exists():
            raise RuntimeError(f"Speckit templates 디렉토리를 찾을 수 없습니다: {source_dir}")

        dest_dir.mkdir(parents=True, exist_ok=True)

        copied_count = 0
        for template_file in self.SPECKIT_TEMPLATES:
            source_file = source_dir / template_file
            if source_file.exists():
                shutil.copy2(source_file, dest_dir / template_file)
                copied_count += 1
                print(f"  [OK] {template_file}")

        print(f"[OK] Templates 복사 완료 ({copied_count}개)")

    def cleanup(self):
        """임시 디렉토리 정리"""
        if self.temp_dir.exists():
            shutil.rmtree(self.temp_dir)
            print(f"[OK] 임시 디렉토리 정리 완료")

    def run(self, cleanup: bool = True):
        """전체 업데이트 프로세스 실행"""
        print("=" * 60)
        print("Speckit 업데이트 시작")
        print("=" * 60)

        try:
            # 1. 임시 디렉토리 생성
            self.ensure_temp_dir()

            # 2. GitHub에서 최신 버전 가져오기
            self.clone_or_pull_speckit()

            # 3. 커밋 해시 확인
            commit_hash = self.get_latest_commit_hash()
            print(f"[OK] 최신 커밋: {commit_hash}")

            # 4. Commands 복사
            print("\n[INFO] Commands 복사 중...")
            self.copy_commands_to_workspace()

            # 5. Templates 복사
            print("\n[INFO] Templates 복사 중...")
            self.copy_templates_to_workspace()

            print("\n" + "=" * 60)
            print("[SUCCESS] Speckit 업데이트 완료!")
            print("=" * 60)
            print(f"\n다음 단계:")
            print(f"1. speckit/에 복사된 영어 파일들을 확인하세요")
            print(f"2. Claude Code에서 파일들을 한글로 번역하세요")
            print(f"3. 번역된 파일들을 .claude/ 및 .specify/로 이동하세요")
            print(f"4. /apply-settings 명령어로 전역 설정에 적용하세요")

        except Exception as e:
            print(f"\n[ERROR] 오류 발생: {e}", file=sys.stderr)
            raise
        finally:
            if cleanup:
                print("\n[INFO] 정리 작업 중...")
                self.cleanup()


def main():
    parser = argparse.ArgumentParser(
        description="Speckit을 GitHub에서 업데이트하고 workspace에 복사합니다."
    )
    parser.add_argument(
        "--workspace",
        type=Path,
        default=Path.cwd(),
        help="Vibe-Coding-Setting 저장소 루트 경로 (기본: 현재 디렉토리)",
    )
    parser.add_argument(
        "--no-cleanup",
        action="store_true",
        help="임시 디렉토리를 정리하지 않고 유지",
    )

    args = parser.parse_args()

    # workspace_root 검증
    workspace_root = args.workspace.resolve()
    if not (workspace_root / "CLAUDE.md").exists():
        print(
            f"[ERROR] 오류: {workspace_root}는 Vibe-Coding-Setting 저장소가 아닙니다.",
            file=sys.stderr,
        )
        print("CLAUDE.md 파일이 있는 디렉토리에서 실행하세요.", file=sys.stderr)
        sys.exit(1)

    manager = SpeckitManager(workspace_root)
    manager.run(cleanup=not args.no_cleanup)


if __name__ == "__main__":
    main()
