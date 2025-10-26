#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Speckit Manager 테스트

update_speckit.py의 핵심 기능을 테스트합니다.
"""

import pytest
import tempfile
from pathlib import Path
from unittest.mock import Mock, patch
import sys
import os

# 상위 디렉토리를 import path에 추가
sys.path.insert(0, str(Path(__file__).parent.parent / ".claude" / "skills" / "speckit-manager" / "scripts"))

from update_speckit import SpeckitManager


class TestSpeckitManager:
    """SpeckitManager 클래스 테스트"""

    @pytest.fixture
    def temp_workspace(self):
        """임시 workspace 생성"""
        with tempfile.TemporaryDirectory() as tmpdir:
            workspace = Path(tmpdir)
            # CLAUDE.md 마커 파일 생성
            (workspace / "CLAUDE.md").write_text("# Test Workspace")
            yield workspace

    @pytest.fixture
    def manager(self, temp_workspace):
        """SpeckitManager 인스턴스"""
        return SpeckitManager(temp_workspace)

    def test_init(self, manager, temp_workspace):
        """초기화 테스트"""
        assert manager.workspace_root == temp_workspace
        assert manager.temp_dir == temp_workspace / "tmp" / "speckit-update"
        assert manager.speckit_clone_dir == manager.temp_dir / "spec-kit"

    def test_ensure_temp_dir(self, manager):
        """임시 디렉토리 생성 테스트"""
        assert not manager.temp_dir.exists()

        manager.ensure_temp_dir()

        assert manager.temp_dir.exists()
        assert manager.temp_dir.is_dir()

    def test_cleanup(self, manager):
        """정리 기능 테스트"""
        # 임시 디렉토리 생성
        manager.ensure_temp_dir()
        assert manager.temp_dir.exists()

        # 정리 실행
        manager.cleanup()

        assert not manager.temp_dir.exists()

    def test_get_latest_commit_hash_format(self, manager):
        """커밋 해시 형식 테스트"""
        # Mock subprocess result
        mock_result = Mock()
        mock_result.returncode = 0
        mock_result.stdout = "abc123def456789\n"

        with patch('subprocess.run', return_value=mock_result):
            # Git repo가 있다고 가정
            manager.speckit_clone_dir.mkdir(parents=True, exist_ok=True)
            (manager.speckit_clone_dir / ".git").mkdir(exist_ok=True)

            commit_hash = manager.get_latest_commit_hash()

            assert len(commit_hash) == 8
            assert commit_hash == "abc123de"

    def test_copy_commands_file_count(self, manager):
        """Commands 파일 개수 확인"""
        expected_commands = [
            "speckit.analyze.md",
            "speckit.checklist.md",
            "speckit.clarify.md",
            "speckit.constitution.md",
            "speckit.implement.md",
            "speckit.plan.md",
            "speckit.specify.md",
            "speckit.tasks.md",
        ]

        assert manager.SPECKIT_COMMANDS == expected_commands
        assert len(manager.SPECKIT_COMMANDS) == 8

    def test_copy_templates_file_count(self, manager):
        """Templates 파일 개수 확인"""
        expected_templates = [
            "spec-template.md",
            "plan-template.md",
            "tasks-template.md",
            "checklist-template.md",
        ]

        assert manager.SPECKIT_TEMPLATES == expected_templates
        assert len(manager.SPECKIT_TEMPLATES) == 4

    def test_workspace_validation(self, temp_workspace):
        """Workspace 검증 테스트"""
        # CLAUDE.md가 있으면 성공
        manager = SpeckitManager(temp_workspace)
        assert (temp_workspace / "CLAUDE.md").exists()

        # CLAUDE.md가 없으면 실패 (main() 함수에서 체크)
        invalid_workspace = temp_workspace / "invalid"
        invalid_workspace.mkdir()
        assert not (invalid_workspace / "CLAUDE.md").exists()

    def test_speckit_repo_url(self, manager):
        """Speckit 저장소 URL 확인"""
        assert manager.SPECKIT_REPO == "https://github.com/github/spec-kit.git"

    @patch('subprocess.run')
    def test_clone_or_pull_new_clone(self, mock_run, manager):
        """새로운 clone 테스트"""
        # Git clone 성공 시뮬레이션
        mock_run.return_value = Mock(returncode=0, stdout="", stderr="")

        manager.ensure_temp_dir()
        manager.clone_or_pull_speckit()

        # git clone 명령어가 호출되었는지 확인
        assert mock_run.called
        call_args = mock_run.call_args[0][0]
        assert "git" in call_args
        assert "clone" in call_args

    @patch('subprocess.run')
    def test_clone_or_pull_existing_pull(self, mock_run, manager):
        """기존 repo pull 테스트"""
        # Git pull 성공 시뮬레이션
        mock_run.return_value = Mock(returncode=0, stdout="", stderr="")

        # 기존 repo가 있는 것처럼 설정
        manager.ensure_temp_dir()
        manager.speckit_clone_dir.mkdir(parents=True, exist_ok=True)

        manager.clone_or_pull_speckit()

        # git pull 명령어가 호출되었는지 확인
        assert mock_run.called
        call_args = mock_run.call_args[0][0]
        assert "git" in call_args
        assert "pull" in call_args


def test_main_missing_claude_md(capsys):
    """main() 함수 - CLAUDE.md 없을 때 테스트"""
    with tempfile.TemporaryDirectory() as tmpdir:
        workspace = Path(tmpdir)

        # CLAUDE.md 없이 실행
        with patch('sys.argv', ['update_speckit.py', '--workspace', str(workspace)]):
            with pytest.raises(SystemExit) as exc_info:
                from update_speckit import main
                main()

            assert exc_info.value.code == 1


if __name__ == "__main__":
    # pytest를 사용하여 테스트 실행
    pytest.main([__file__, "-v"])
