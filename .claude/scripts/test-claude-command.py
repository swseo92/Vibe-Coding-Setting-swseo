#!/usr/bin/env python3
"""
Test Claude Code commands in isolated subprocess
"""
import subprocess
import sys
import time
from pathlib import Path

def test_command(command: str, test_dir: Path, timeout: int = 3600):
    """
    Execute Claude command in completely isolated subprocess

    Args:
        command: Claude command to test (e.g., '/init-workspace python')
        test_dir: Directory to run test in
        timeout: Max seconds to wait (default: 3600 = 1 hour)

    Returns:
        dict with results
    """
    print(f"{'='*60}")
    print(f"Testing Claude Command: {command}")
    print(f"Test Directory: {test_dir}")
    print(f"{'='*60}\n")

    # Ensure test directory exists
    test_dir.mkdir(parents=True, exist_ok=True)

    # Output files
    output_file = test_dir / "output.log"
    exit_code_file = test_dir / "exit_code.txt"

    # Prepare command
    # Use claude --print to execute command in isolated session
    import platform
    if platform.system() == "Windows":
        cmd = ["claude.cmd", "--print", command]
    else:
        cmd = ["claude", "--print", command]

    print(f"Starting subprocess...")
    print(f"Command: {' '.join(cmd)}")
    print(f"Working directory: {test_dir}")
    print()

    start_time = time.time()

    try:
        # Run as completely separate process
        result = subprocess.run(
            cmd,
            cwd=str(test_dir),
            capture_output=True,
            text=True,
            timeout=timeout,
            encoding='utf-8',
            errors='replace'  # Handle Windows encoding issues
        )

        elapsed = time.time() - start_time

        # Save output
        output_file.write_text(
            result.stdout + "\n\n=== STDERR ===\n\n" + result.stderr,
            encoding='utf-8'
        )
        exit_code_file.write_text(str(result.returncode))

        print(f"✓ Completed in {elapsed:.1f}s")
        print(f"Exit code: {result.returncode}")
        print()

        return {
            "success": result.returncode == 0,
            "exit_code": result.returncode,
            "duration": elapsed,
            "stdout": result.stdout,
            "stderr": result.stderr,
            "output_file": output_file,
            "test_dir": test_dir
        }

    except subprocess.TimeoutExpired:
        elapsed = time.time() - start_time
        print(f"X Timeout after {elapsed:.1f}s")
        return {
            "success": False,
            "exit_code": -1,
            "duration": elapsed,
            "error": "timeout",
            "test_dir": test_dir
        }
    except Exception as e:
        elapsed = time.time() - start_time
        print(f"X Error: {e}")
        return {
            "success": False,
            "exit_code": -2,
            "duration": elapsed,
            "error": str(e),
            "test_dir": test_dir
        }

def analyze_results(test_dir: Path):
    """Analyze test results"""
    print(f"{'='*60}")
    print("Analyzing Results")
    print(f"{'='*60}\n")

    # Count files created
    files = list(test_dir.glob("**/*"))
    file_count = len([f for f in files if f.is_file() and f.name not in ["output.log", "exit_code.txt"]])

    print(f"Files created: {file_count}")
    print()

    # Check key files
    print("Key files:")
    key_files = [
        "pyproject.toml",
        "pytest.ini",
        ".mcp.json",
        ".specify",
        "src",
        "tests",
        ".github/workflows"
    ]

    for key_file in key_files:
        path = test_dir / key_file
        exists = path.exists()
        symbol = "OK" if exists else "X "
        print(f"  {symbol} {key_file}")

    print()

    # Show output snippet
    output_file = test_dir / "output.log"
    if output_file.exists():
        print("Output (last 20 lines):")
        print("-" * 60)
        lines = output_file.read_text().splitlines()
        for line in lines[-20:]:
            print(line)
        print("-" * 60)

    return file_count

if __name__ == "__main__":
    # Test directory
    import tempfile
    test_dir = Path(tempfile.mkdtemp(prefix="claude-test-"))

    print("\n=== Python Subprocess Test ===\n")

    # Test command (1 hour timeout for long-running agents)
    result = test_command("/init-workspace python", test_dir, timeout=3600)

    # Analyze
    file_count = analyze_results(test_dir)

    # Summary
    print(f"\n{'='*60}")
    print("Test Summary")
    print(f"{'='*60}")
    status = "PASS" if result['success'] and file_count > 10 else "FAIL"
    print(f"Status: {status}")
    print(f"Duration: {result['duration']:.1f}s")
    print(f"Exit code: {result['exit_code']}")
    print(f"Files created: {file_count}")
    print(f"Test artifacts: {test_dir}")
    print(f"{'='*60}\n")

    sys.exit(0 if result['success'] else 1)
