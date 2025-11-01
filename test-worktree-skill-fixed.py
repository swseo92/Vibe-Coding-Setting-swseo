"""
Test git-worktree-manager skill after removing legacy /worktree-* commands

This test verifies that with legacy commands removed, the skill now uses
PowerShell scripts instead of the old Python copytree approach.
"""

import subprocess
import tempfile
import time
from pathlib import Path
import platform

def test_worktree_skill_after_legacy_removal():
    """
    Test worktree skill behavior after removing legacy commands

    Expected behavior:
    - Skill should trigger
    - Should use PowerShell scripts (worktree-create.ps1)
    - Should use git worktree add command
    - Should create in C:\ws\ directory (not clone/)
    """

    # Create test directory with git repo
    test_dir = Path(tempfile.mkdtemp(prefix="worktree-skill-test-"))
    test_dir.mkdir(parents=True, exist_ok=True)

    print("=" * 80)
    print("GIT-WORKTREE-MANAGER SKILL TEST (POST LEGACY REMOVAL)")
    print("=" * 80)
    print(f"\nTest directory: {test_dir}")
    print(f"Test time: {time.strftime('%Y-%m-%d %H:%M:%S')}")
    print("\nContext:")
    print("- Removed 5 legacy /worktree-* commands")
    print("- Testing if skill now uses PowerShell scripts")
    print("- Looking for git worktree add vs Python copytree")
    print("\n" + "=" * 80)

    # Initialize git repo
    print("\n[SETUP] Initializing test git repository...")
    subprocess.run(["git", "init"], cwd=test_dir, check=True, capture_output=True)
    subprocess.run(["git", "config", "user.name", "Test User"], cwd=test_dir, check=True, capture_output=True)
    subprocess.run(["git", "config", "user.email", "test@example.com"], cwd=test_dir, check=True, capture_output=True)

    # Create initial commit
    readme = test_dir / "README.md"
    readme.write_text("# Test Repository for Worktree Skill\n", encoding='utf-8')
    subprocess.run(["git", "add", "README.md"], cwd=test_dir, check=True, capture_output=True)
    subprocess.run(["git", "commit", "-m", "Initial commit"], cwd=test_dir, check=True, capture_output=True)

    print("[SETUP] OK: Git repository initialized with initial commit")

    # User query to test
    user_query = "feature-test 브랜치로 worktree 생성해줘"

    print(f"\n[TEST] Running query: '{user_query}'")
    print("[TEST] Timeout: 3600s (1 hour)")

    # Prepare command
    if platform.system() == "Windows":
        cmd = ["claude.cmd", "--print", user_query]
    else:
        cmd = ["claude", "--print", user_query]

    start_time = time.time()

    try:
        # Run in isolated subprocess
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

        # Save full output
        output_file = test_dir / "skill-test-output.log"
        output_file.write_text(
            f"COMMAND: {' '.join(cmd)}\n"
            f"CWD: {test_dir}\n"
            f"DURATION: {elapsed:.1f}s\n"
            f"EXIT CODE: {result.returncode}\n"
            f"\n{'=' * 80}\n"
            f"STDOUT:\n"
            f"{'=' * 80}\n"
            f"{result.stdout}\n"
            f"\n{'=' * 80}\n"
            f"STDERR:\n"
            f"{'=' * 80}\n"
            f"{result.stderr}\n",
            encoding='utf-8'
        )

        print(f"\n[RESULT] OK: Completed in {elapsed:.1f}s")
        print(f"[RESULT] Exit code: {result.returncode}")
        print(f"[RESULT] Output saved to: {output_file}")

        # Analyze output
        print("\n" + "=" * 80)
        print("ANALYSIS")
        print("=" * 80)

        output = result.stdout.lower()

        # 1. Check skill activation
        skill_triggered = "git-worktree-manager" in output or "worktree-manager" in output
        print(f"\n1. SKILL ACTIVATION")
        print(f"   Triggered: {'YES' if skill_triggered else 'NO'}")

        # 2. Check implementation method
        print(f"\n2. IMPLEMENTATION METHOD")

        uses_powershell = "worktree-create.ps1" in output or ".ps1" in output
        uses_git_worktree = "git worktree add" in output
        uses_copytree = "copytree" in output or "shutil" in output
        uses_clone_dir = "clone/" in output or "cloned directory" in output
        uses_ws_dir = "c:\\ws\\" in output or "c:/ws/" in output

        print(f"   PowerShell Script: {'YES' if uses_powershell else 'NO'}")
        print(f"   Git Worktree Command: {'YES' if uses_git_worktree else 'NO'}")
        print(f"   Legacy Copytree: {'FOUND' if uses_copytree else 'NOT FOUND'}")
        print(f"   Uses clone/ dir: {'LEGACY' if uses_clone_dir else 'NO'}")
        print(f"   Uses C:\\ws\\ dir: {'YES' if uses_ws_dir else 'NO'}")

        # 3. Verdict
        print(f"\n3. VERDICT")

        if uses_powershell and uses_git_worktree and not uses_copytree:
            print("   [OK] FIXED: Skill now uses PowerShell scripts!")
            print("   [OK] Uses proper git worktree commands")
            print("   [OK] No legacy copytree approach detected")
        elif uses_copytree or uses_clone_dir:
            print("   [FAIL] STILL BROKEN: Legacy approach still being used")
            print("   [FAIL] Found evidence of old clone/ directory method")
        elif not skill_triggered:
            print("   [WARN] SKILL NOT TRIGGERED")
            print("   [WARN] May need to check skill configuration")
        else:
            print("   [WARN] UNCLEAR: Check transcript for details")

        # 4. Key evidence
        print(f"\n4. KEY EVIDENCE")
        print("   Searching for implementation indicators...")

        lines = result.stdout.split('\n')
        evidence_lines = []

        keywords = ['worktree', 'powershell', '.ps1', 'git worktree', 'copytree', 'clone/', 'c:\\ws\\']

        for i, line in enumerate(lines):
            if any(keyword in line.lower() for keyword in keywords):
                evidence_lines.append(f"   Line {i}: {line.strip()[:100]}")

        if evidence_lines:
            print("\n".join(evidence_lines[:20]))  # Show first 20 matching lines
        else:
            print("   (No direct evidence found in output)")

        print("\n" + "=" * 80)
        print(f"Full transcript available at: {output_file}")
        print("=" * 80)

        return {
            "success": result.returncode == 0,
            "skill_triggered": skill_triggered,
            "uses_powershell": uses_powershell,
            "uses_git_worktree": uses_git_worktree,
            "uses_legacy": uses_copytree or uses_clone_dir,
            "test_dir": test_dir,
            "output_file": output_file,
            "duration": elapsed
        }

    except subprocess.TimeoutExpired:
        elapsed = time.time() - start_time
        print(f"\n[ERROR] ❌ Timeout after {elapsed:.1f}s")
        return {
            "success": False,
            "error": "timeout",
            "test_dir": test_dir,
            "duration": elapsed
        }
    except Exception as e:
        elapsed = time.time() - start_time
        print(f"\n[ERROR] ❌ {e}")
        return {
            "success": False,
            "error": str(e),
            "test_dir": test_dir,
            "duration": elapsed
        }

if __name__ == "__main__":
    result = test_worktree_skill_after_legacy_removal()

    print("\n" + "=" * 80)
    print("TEST SUMMARY")
    print("=" * 80)
    print(f"Success: {result.get('success', False)}")
    print(f"Skill Triggered: {result.get('skill_triggered', 'Unknown')}")
    print(f"Uses PowerShell: {result.get('uses_powershell', 'Unknown')}")
    print(f"Uses Git Worktree: {result.get('uses_git_worktree', 'Unknown')}")
    print(f"Uses Legacy: {result.get('uses_legacy', 'Unknown')}")
    print(f"Duration: {result.get('duration', 0):.1f}s")

    if result.get('output_file'):
        print(f"\n📄 Full transcript: {result['output_file']}")

    print("=" * 80)
