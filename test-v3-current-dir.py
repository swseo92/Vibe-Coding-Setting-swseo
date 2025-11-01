#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Test codex-collaborative-solver-v3 in current directory
This script verifies V3.0 features are accessible and functional
"""

import subprocess
import time
from pathlib import Path
import sys
import io

# Fix Windows console encoding
if sys.platform == 'win32':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', errors='replace')

def test_v3_skill():
    """Test V3 skill in current working directory"""

    # Verify we're in the correct directory
    cwd = Path.cwd()
    print(f"Working directory: {cwd}")

    # Check V3 skill exists
    v3_skill = cwd / ".claude" / "skills" / "codex-collaborative-solver-v3"
    if not v3_skill.exists():
        print(f"[FAIL] V3 skill not found at {v3_skill}")
        return False
    print(f"[OK] V3 skill found at {v3_skill}")

    # Check Codex CLI
    codex_paths = [
        "codex",
        "C:\\Users\\EST\\AppData\\Roaming\\npm\\codex.cmd",
        "C:\\Users\\EST\\AppData\\Roaming\\npm\\codex",
    ]

    codex_cmd = None
    for path in codex_paths:
        try:
            result = subprocess.run(
                [path, "--version"],
                capture_output=True,
                text=True,
                timeout=10,
                shell=True
            )
            if result.returncode == 0:
                codex_cmd = path
                print(f"[OK] Codex CLI available at {path}: {result.stdout.strip()}")
                break
        except:
            continue

    if not codex_cmd:
        print(f"[FAIL] Codex CLI not available in any known location")
        return False

    # Prepare test command
    test_problem = (
        "Redis vs Memcached for session caching. "
        "We have 5K daily active users and expect 3x growth in 6 months. "
        "codex와 토론해서 결정해줘."
    )

    print("\n" + "="*80)
    print("TEST PROBLEM:")
    print(test_problem)
    print("="*80 + "\n")

    # Run Claude with the test problem
    # Using claude --print to capture output
    cmd = ["claude", "--print", test_problem]

    print(f"Running command: {' '.join(cmd)}")
    print(f"Timeout: 3600s (1 hour)")
    print("\n" + "="*80)
    print("STARTING TEST...")
    print("="*80 + "\n")

    start_time = time.time()

    try:
        result = subprocess.run(
            cmd,
            cwd=str(cwd),
            capture_output=True,
            text=True,
            timeout=3600,  # 1 hour timeout
            encoding='utf-8',
            errors='replace'
        )

        elapsed = time.time() - start_time

        # Save output
        output_file = cwd / "v3-test-output.log"
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write("="*80 + "\n")
            f.write(f"Test completed in {elapsed:.1f}s\n")
            f.write(f"Exit code: {result.returncode}\n")
            f.write("="*80 + "\n\n")
            f.write("STDOUT:\n")
            f.write(result.stdout)
            f.write("\n\n" + "="*80 + "\n")
            f.write("STDERR:\n")
            f.write(result.stderr)

        print(f"\n[OK] Test completed in {elapsed:.1f}s")
        print(f"Exit code: {result.returncode}")
        print(f"Output saved to: {output_file}")

        # Print first 2000 chars of output
        print("\n" + "="*80)
        print("OUTPUT PREVIEW (first 2000 chars):")
        print("="*80)
        print(result.stdout[:2000])

        if len(result.stdout) > 2000:
            print(f"\n... ({len(result.stdout) - 2000} more characters)")

        return result.returncode == 0

    except subprocess.TimeoutExpired:
        elapsed = time.time() - start_time
        print(f"\n[FAIL] Test timed out after {elapsed:.1f}s")
        return False

    except Exception as e:
        elapsed = time.time() - start_time
        print(f"\n[FAIL] Test failed: {e}")
        return False

if __name__ == "__main__":
    print("="*80)
    print("V3.0 SKILL TEST - CURRENT DIRECTORY")
    print("="*80 + "\n")

    success = test_v3_skill()

    print("\n" + "="*80)
    if success:
        print("[PASS] TEST PASSED")
    else:
        print("[FAIL] TEST FAILED")
    print("="*80)

    sys.exit(0 if success else 1)
