"""
Test codex-collaborative-solver V3.0 in isolated subprocess

This script tests the V3.0 skill from the current directory,
which should load the local version instead of the global one.
"""

import subprocess
import tempfile
from pathlib import Path
import time
import platform
import os

def test_codex_v3(timeout: int = 3600):
    """
    Test Codex V3.0 with a simple debate topic

    Args:
        timeout: Max seconds to wait (default: 3600 = 1 hour)
    """
    # Use current directory (contains V3.0 locally)
    current_dir = Path(r"C:\Users\EST\PycharmProjects\my agents\Vibe-Coding-Setting-swseo")
    test_dir = current_dir / "tmp" / f"codex-v3-test-{int(time.time())}"
    test_dir.mkdir(parents=True, exist_ok=True)

    # Simple debate topic for testing
    debate_topic = "Django API rate limiting: Redis vs Memcached for 10k req/sec?"

    # Prepare command
    # V3.0 should be loaded from .claude/skills/codex-collaborative-solver-v3/
    if platform.system() == "Windows":
        cmd = ["claude.cmd", "--print", f"Use codex-collaborative-solver skill to debate: {debate_topic}. Keep it brief (1-2 rounds only)."]
    else:
        cmd = ["claude", "--print", f"Use codex-collaborative-solver skill to debate: {debate_topic}. Keep it brief (1-2 rounds only)."]

    print("=" * 80)
    print("Testing: codex-collaborative-solver V3.0")
    print("=" * 80)
    print(f"Current directory: {current_dir}")
    print(f"Test directory: {test_dir}")
    print(f"Debate topic: {debate_topic}")
    print(f"Timeout: {timeout}s")
    print(f"Expected V3.0 location: .claude/skills/codex-collaborative-solver-v3/")
    print("=" * 80)

    start_time = time.time()

    try:
        # Run from CURRENT directory (not test_dir) to load local V3.0
        result = subprocess.run(
            cmd,
            cwd=str(current_dir),  # Use current dir to load local .claude/skills/
            capture_output=True,
            text=True,
            timeout=timeout,
            encoding='utf-8',
            errors='replace',
            env={**os.environ}  # Pass all environment variables
        )

        elapsed = time.time() - start_time

        # Save output
        output_file = test_dir / "debate-output.log"
        output_file.write_text(
            f"=== COMMAND ===\n{' '.join(cmd)}\n\n"
            f"=== STDOUT ===\n{result.stdout}\n\n"
            f"=== STDERR ===\n{result.stderr}",
            encoding='utf-8'
        )

        print(f"\n{'=' * 80}")
        print(f"Completed in {elapsed:.1f}s")
        print(f"Exit code: {result.returncode}")
        print(f"Output saved to: {output_file}")
        print(f"{'=' * 80}\n")

        # Display stdout preview
        if result.stdout:
            print("=== OUTPUT PREVIEW (first 2000 chars) ===")
            print(result.stdout[:2000])
            if len(result.stdout) > 2000:
                print("\n... (truncated, see log file for full output)")

        # Check for V3.0 indicators
        print(f"\n{'=' * 80}")
        print("V3.0 FEATURE DETECTION:")
        print(f"{'=' * 80}")

        v3_indicators = {
            "Quality Gate": "quality gate" in result.stdout.lower(),
            "Coverage Monitor": "coverage" in result.stdout.lower() or "dimension" in result.stdout.lower(),
            "Facilitator": "facilitator" in result.stdout.lower(),
            "Playbook": "playbook" in result.stdout.lower(),
            "Confidence Level": "confidence" in result.stdout.lower(),
            "Evidence Tier": "tier" in result.stdout.lower() or "evidence" in result.stdout.lower(),
            "Stress Pass": "stress" in result.stdout.lower() or "failure mode" in result.stdout.lower(),
        }

        for feature, detected in v3_indicators.items():
            status = "✅" if detected else "❌"
            print(f"{status} {feature}: {detected}")

        detected_count = sum(v3_indicators.values())
        print(f"\nDetected {detected_count}/{len(v3_indicators)} V3.0 features")

        return {
            "success": result.returncode == 0,
            "exit_code": result.returncode,
            "duration": elapsed,
            "stdout": result.stdout,
            "stderr": result.stderr,
            "test_dir": test_dir,
            "output_file": output_file,
            "v3_detected": detected_count >= 3,  # At least 3 features should be present
            "v3_indicators": v3_indicators
        }

    except subprocess.TimeoutExpired:
        elapsed = time.time() - start_time
        print(f"\n❌ TIMEOUT after {elapsed:.1f}s")
        return {
            "success": False,
            "exit_code": -1,
            "duration": elapsed,
            "error": "timeout",
            "test_dir": test_dir
        }
    except Exception as e:
        elapsed = time.time() - start_time
        print(f"\n❌ ERROR: {e}")
        return {
            "success": False,
            "exit_code": -2,
            "duration": elapsed,
            "error": str(e),
            "test_dir": test_dir
        }

if __name__ == "__main__":
    print("\n" + "=" * 80)
    print("CODEX-COLLABORATIVE-SOLVER V3.0 META-TEST")
    print("=" * 80 + "\n")

    result = test_codex_v3(timeout=3600)

    print("\n" + "=" * 80)
    print("TEST SUMMARY")
    print("=" * 80)
    print(f"Success: {result.get('success', False)}")
    print(f"Duration: {result.get('duration', 0):.1f}s")
    print(f"V3.0 Detected: {result.get('v3_detected', False)}")

    if result.get('v3_indicators'):
        print("\nV3.0 Features:")
        for feature, detected in result['v3_indicators'].items():
            print(f"  - {feature}: {detected}")

    print(f"\nOutput: {result.get('output_file', 'N/A')}")
    print("=" * 80 + "\n")
