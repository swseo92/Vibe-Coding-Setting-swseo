import subprocess
import tempfile
from pathlib import Path
import time
import platform

def test_claude_command(command: str, timeout: int = 3600):
    """Test Claude command in isolated subprocess"""
    # Create test directory
    test_dir = Path(tempfile.mkdtemp(prefix="claude-test-"))
    test_dir.mkdir(parents=True, exist_ok=True)

    # Prepare command
    if platform.system() == "Windows":
        cmd = ["claude.cmd", "--print", command]
    else:
        cmd = ["claude", "--print", command]

    print(f"Testing: {command}")
    print(f"Test directory: {test_dir}")
    print(f"Timeout: {timeout}s")

    start_time = time.time()

    try:
        # Run in completely isolated subprocess
        result = subprocess.run(
            cmd,
            cwd=str(test_dir),
            capture_output=True,
            text=True,
            timeout=timeout,
            encoding='utf-8',
            errors='replace'
        )

        elapsed = time.time() - start_time

        # Save output
        output_file = test_dir / "output.log"
        output_file.write_text(
            result.stdout + "\n\n=== STDERR ===\n\n" + result.stderr,
            encoding='utf-8'
        )

        print(f"Completed in {elapsed:.1f}s")
        print(f"Exit code: {result.returncode}")

        # Analyze results
        files = list(test_dir.glob("**/*"))
        file_count = len([f for f in files if f.is_file() and f.name not in ["output.log"]])

        print(f"\nFiles created: {file_count}")

        # Check key files
        key_files = [
            "pyproject.toml",
            "pytest.ini",
            ".mcp.json",
            "src",
            "tests"
        ]

        print("\nKey files:")
        for key_file in key_files:
            path = test_dir / key_file
            exists = path.exists()
            symbol = "OK" if exists else "MISSING"
            print(f"  {symbol} {key_file}")

        return {
            "success": result.returncode == 0 and file_count >= 15,
            "exit_code": result.returncode,
            "duration": elapsed,
            "file_count": file_count,
            "test_dir": test_dir,
            "output": result.stdout[-500:] if result.stdout else "",
            "full_output": result.stdout,
            "stderr": result.stderr
        }

    except subprocess.TimeoutExpired:
        elapsed = time.time() - start_time
        print(f"TIMEOUT after {elapsed:.1f}s")
        return {
            "success": False,
            "error": "timeout",
            "duration": elapsed,
            "test_dir": test_dir
        }
    except Exception as e:
        elapsed = time.time() - start_time
        print(f"ERROR: {e}")
        return {
            "success": False,
            "error": str(e),
            "duration": elapsed,
            "test_dir": test_dir
        }

# Execute test
result = test_claude_command("/init-workspace python", timeout=180)

# Report results
print("\n" + "="*60)
print("TEST RESULTS")
print("="*60)
print(f"Status: {'PASS' if result['success'] else 'FAIL'}")
print(f"Duration: {result.get('duration', 0):.1f}s")
print(f"Exit code: {result.get('exit_code', 'N/A')}")
print(f"Files created: {result.get('file_count', 0)}")
print(f"Test directory: {result.get('test_dir', 'N/A')}")

if 'output' in result:
    print(f"\nLast output:\n{result['output']}")

if 'stderr' in result and result['stderr']:
    print(f"\nStderr:\n{result['stderr']}")

print("="*60)
