#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Test git-worktree-manager skill with Korean trigger patterns
"""
import subprocess
import tempfile
from pathlib import Path
import time
import platform
import sys
import io

# Fix Windows console encoding
if platform.system() == "Windows":
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8')

def test_worktree_korean_trigger():
    """
    Test if git-worktree-manager skill triggers with Korean query
    """
    # Create test directory
    test_dir = Path(tempfile.mkdtemp(prefix="worktree-korean-test-"))
    test_dir.mkdir(parents=True, exist_ok=True)

    # Initialize a git repository for realistic context
    init_result = subprocess.run(
        ["git", "init"],
        cwd=str(test_dir),
        capture_output=True,
        text=True
    )

    if init_result.returncode != 0:
        print(f"Warning: Could not initialize git repo: {init_result.stderr}")

    # Test query (exact same as user provided)
    test_query = "feature-auth 브랜치로 worktree 생성해줘"

    # Prepare command
    if platform.system() == "Windows":
        cmd = ["claude.cmd", "--print", test_query]
    else:
        cmd = ["claude", "--print", test_query]

    print("=" * 80)
    print("Testing git-worktree-manager skill with Korean trigger")
    print("=" * 80)
    print(f"Test directory: {test_dir}")
    print(f"Test query: {test_query}")
    print(f"Timeout: 3600 seconds (1 hour)")
    print("=" * 80)

    start_time = time.time()

    try:
        # Run in completely isolated subprocess
        result = subprocess.run(
            cmd,
            cwd=str(test_dir),
            capture_output=True,
            text=True,
            timeout=3600,  # 1 hour timeout
            encoding='utf-8',
            errors='replace'
        )

        elapsed = time.time() - start_time

        # Save output
        output_file = test_dir / "output.log"
        full_output = result.stdout + "\n\n=== STDERR ===\n\n" + result.stderr
        output_file.write_text(full_output, encoding='utf-8')

        print(f"\n[OK] Test completed in {elapsed:.1f} seconds")
        print(f"Exit code: {result.returncode}")
        print(f"Output saved to: {output_file}")

        # Analyze output
        print("\n" + "=" * 80)
        print("ANALYSIS")
        print("=" * 80)

        skill_triggered = False
        skill_activation_evidence = []

        # Check for skill activation indicators
        activation_patterns = [
            "git-worktree-manager skill",
            "git-worktree-manager is loading",
            "<command-message>",
            "skill is running",
            # Korean skill activation messages
            "스킬이 로드",
            "스킬 실행"
        ]

        output_lower = result.stdout.lower()

        for pattern in activation_patterns:
            if pattern.lower() in output_lower:
                skill_triggered = True
                # Find context around the pattern
                for line in result.stdout.split('\n'):
                    if pattern.lower() in line.lower():
                        skill_activation_evidence.append(line.strip())

        print(f"\n1. SKILL TRIGGERED: {'YES [OK]' if skill_triggered else 'NO [X]'}")

        if skill_activation_evidence:
            print("\n   Evidence of skill activation:")
            for evidence in skill_activation_evidence[:5]:  # Show first 5
                print(f"   - {evidence}")

        # Check for worktree-related guidance
        worktree_guidance = False
        guidance_indicators = [
            "/worktree-create",
            "worktree",
            "git worktree add",
            "clone",
            "작업 트리"  # Korean for worktree
        ]

        for indicator in guidance_indicators:
            if indicator.lower() in output_lower:
                worktree_guidance = True
                break

        print(f"\n2. WORKTREE GUIDANCE PROVIDED: {'YES [OK]' if worktree_guidance else 'NO [X]'}")

        # Quality assessment
        print("\n3. RESPONSE QUALITY:")

        if skill_triggered:
            print("   [OK] Skill successfully triggered by Korean query")
            print("   [OK] Specialized guidance expected")
        else:
            print("   [X] Skill did NOT trigger")
            print("   - Response likely generic")

        if worktree_guidance:
            print("   [OK] Worktree-related content present")
        else:
            print("   [X] No clear worktree guidance")

        # Show key response snippet
        print("\n4. RESPONSE SNIPPET (first 500 chars):")
        print("-" * 80)
        print(result.stdout[:500])
        print("-" * 80)

        # Comparison with previous test
        print("\n5. COMPARISON WITH PREVIOUS TEST:")
        print("   Previous (before fix):")
        print("   - Skill triggered: NO")
        print("   - Response: Generic")
        print("   ")
        print("   Current (after adding Korean patterns):")
        print(f"   - Skill triggered: {'YES [OK]' if skill_triggered else 'NO [X]'}")
        print(f"   - Improvement: {'FIXED [OK]' if skill_triggered else 'STILL BROKEN [X]'}")

        # Final verdict
        print("\n" + "=" * 80)
        print("VERDICT")
        print("=" * 80)

        if skill_triggered and worktree_guidance:
            verdict = "FIXED [OK][OK][OK]"
            print(f"   {verdict}")
            print("   - Korean trigger patterns working")
            print("   - Skill activates correctly")
            print("   - Specialized guidance provided")
        elif skill_triggered:
            verdict = "PARTIALLY FIXED [WARNING]"
            print(f"   {verdict}")
            print("   - Skill activates, but guidance unclear")
        else:
            verdict = "NOT FIXED [X][X][X]"
            print(f"   {verdict}")
            print("   - Skill still doesn't trigger with Korean query")
            print("   - Further debugging needed")

        print("\n" + "=" * 80)

        return {
            "success": result.returncode == 0,
            "skill_triggered": skill_triggered,
            "worktree_guidance": worktree_guidance,
            "verdict": verdict,
            "exit_code": result.returncode,
            "duration": elapsed,
            "test_dir": test_dir,
            "output_file": output_file
        }

    except subprocess.TimeoutExpired:
        elapsed = time.time() - start_time
        print(f"\n[X] Timeout after {elapsed:.1f} seconds")
        return {
            "success": False,
            "skill_triggered": False,
            "error": "timeout",
            "duration": elapsed,
            "test_dir": test_dir
        }
    except Exception as e:
        elapsed = time.time() - start_time
        print(f"\n[X] Error: {e}")
        return {
            "success": False,
            "skill_triggered": False,
            "error": str(e),
            "duration": elapsed,
            "test_dir": test_dir
        }

if __name__ == "__main__":
    result = test_worktree_korean_trigger()

    print("\n" + "=" * 80)
    print("TEST SUMMARY")
    print("=" * 80)
    print(f"Skill Triggered: {result.get('skill_triggered', False)}")
    print(f"Verdict: {result.get('verdict', 'ERROR')}")
    print(f"Duration: {result.get('duration', 0):.1f}s")
    print(f"Test Directory: {result.get('test_dir', 'N/A')}")
    if 'output_file' in result:
        print(f"Full Output: {result['output_file']}")
    print("=" * 80)
