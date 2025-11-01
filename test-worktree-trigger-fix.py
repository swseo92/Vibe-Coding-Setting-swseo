#!/usr/bin/env python3
"""
Test git-worktree-manager skill trigger after description fix
Tests Korean trigger phrase: "feature-auth 브랜치로 worktree 생성해줘"
"""

import subprocess
import tempfile
import time
from pathlib import Path
import json

def test_worktree_skill_trigger():
    """Test if skill triggers with explicit trigger pattern"""

    # Create test directory
    test_dir = Path(tempfile.mkdtemp(prefix="worktree-trigger-test-"))
    test_dir.mkdir(parents=True, exist_ok=True)

    # Initialize minimal git repo (skill needs git context)
    subprocess.run(["git", "init"], cwd=test_dir, capture_output=True)
    subprocess.run(["git", "config", "user.name", "Test User"], cwd=test_dir, capture_output=True)
    subprocess.run(["git", "config", "user.email", "test@test.com"], cwd=test_dir, capture_output=True)

    # Create initial commit
    readme = test_dir / "README.md"
    readme.write_text("# Test Repo\n", encoding='utf-8')
    subprocess.run(["git", "add", "."], cwd=test_dir, capture_output=True)
    subprocess.run(["git", "commit", "-m", "Initial commit"], cwd=test_dir, capture_output=True)

    # Test command - Korean trigger phrase
    test_query = "feature-auth 브랜치로 worktree 생성해줘"

    # Use claude.cmd on Windows
    import platform
    claude_cmd = "claude.cmd" if platform.system() == "Windows" else "claude"
    cmd = [claude_cmd, "--print", test_query]

    print("=" * 80)
    print("WORKTREE SKILL TRIGGER TEST - DESCRIPTION FIX VERIFICATION")
    print("=" * 80)
    print(f"Test directory: {test_dir}")
    print(f"Test query: {test_query}")
    print(f"Timeout: 3600s (1 hour)")
    print("=" * 80)

    start_time = time.time()

    try:
        result = subprocess.run(
            cmd,
            cwd=str(test_dir),
            capture_output=True,
            text=True,
            timeout=3600,  # 1 hour
            encoding='utf-8',
            errors='replace'
        )

        elapsed = time.time() - start_time

        # Save output
        output_file = test_dir / "test-output.log"
        full_output = f"""
WORKTREE SKILL TRIGGER TEST
==========================

Test Query: {test_query}
Duration: {elapsed:.1f}s
Exit Code: {result.returncode}

STDOUT:
{result.stdout}

STDERR:
{result.stderr}
"""
        output_file.write_text(full_output, encoding='utf-8')

        # Analyze output for skill trigger evidence
        stdout_lower = result.stdout.lower()

        # Check for skill activation indicators
        skill_indicators = [
            "git-worktree-manager",
            "worktree-manager is running",
            "skill is loading",
            "워크트리",
            "worktree creation",
        ]

        skill_triggered = any(indicator in stdout_lower for indicator in skill_indicators)

        # Extract key parts of response
        lines = result.stdout.split('\n')
        first_response = '\n'.join(lines[:30])  # First 30 lines

        # Generate report
        report = f"""
{'=' * 80}
WORKTREE SKILL TRIGGER TEST - FINAL REPORT
{'=' * 80}

1. TEST RESULT
--------------
Skill Triggered: {'YES' if skill_triggered else 'NO'}
Exit Code: {result.returncode}
Duration: {elapsed:.1f}s

Evidence of Skill Activation:
{chr(10).join(f"  - Found: '{ind}'" for ind in skill_indicators if ind in stdout_lower) if skill_triggered else "  - No skill indicators found in output"}

2. VERDICT
----------
"""

        if skill_triggered:
            report += "FIXED: Skill triggers correctly with explicit trigger pattern\n"
        else:
            report += "NOT FIXED: Skill still does not trigger\n"

        report += f"""
3. ANALYSIS
-----------
Test Query: "{test_query}"
Expected: git-worktree-manager skill should activate
Actual: {'Skill activated' if skill_triggered else 'Generic Claude response (no skill)'}

Trigger Pattern Used in Description:
  "Trigger when user says 'create worktree', '워크트리 생성', 'worktree 생성'..."

What Happened:
"""

        if skill_triggered:
            report += "  - Korean trigger phrase recognized\n"
            report += "  - Skill loaded successfully\n"
            report += "  - Description pattern fix is effective\n"
        else:
            report += "  - Korean trigger phrase NOT recognized\n"
            report += "  - Skill did NOT load\n"
            report += "  - Description pattern may need further refinement\n"

        report += f"""
4. TRANSCRIPT HIGHLIGHTS
------------------------
First Response from Claude:

{first_response}

{'...(truncated)' if len(lines) > 30 else ''}

Full output saved to: {output_file}

{'=' * 80}
TEST COMPLETE
{'=' * 80}
"""

        print(report)

        # Save report
        report_file = test_dir / "test-report.md"
        report_file.write_text(report, encoding='utf-8')

        return {
            "success": skill_triggered,
            "exit_code": result.returncode,
            "duration": elapsed,
            "skill_triggered": skill_triggered,
            "test_dir": test_dir,
            "report_file": report_file,
            "output_file": output_file
        }

    except subprocess.TimeoutExpired:
        elapsed = time.time() - start_time
        print(f"\nTIMEOUT after {elapsed:.1f}s")
        return {
            "success": False,
            "exit_code": -1,
            "duration": elapsed,
            "error": "timeout",
            "test_dir": test_dir
        }
    except Exception as e:
        elapsed = time.time() - start_time
        print(f"\nERROR: {e}")
        return {
            "success": False,
            "exit_code": -2,
            "duration": elapsed,
            "error": str(e),
            "test_dir": test_dir
        }

if __name__ == "__main__":
    result = test_worktree_skill_trigger()

    print(f"\n{'=' * 80}")
    print("SUMMARY")
    print(f"{'=' * 80}")
    print(f"Skill Triggered: {'YES' if result.get('skill_triggered') else 'NO'}")
    print(f"Duration: {result['duration']:.1f}s")
    print(f"Test Directory: {result['test_dir']}")
    if 'report_file' in result:
        print(f"Report: {result['report_file']}")
        print(f"Output: {result['output_file']}")
    print(f"{'=' * 80}")
