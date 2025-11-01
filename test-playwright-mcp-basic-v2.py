"""
Test Playwright MCP configuration without user-data-dir in isolated subprocess
"""
import subprocess
import tempfile
import json
from pathlib import Path
import time
import platform

def test_playwright_mcp_basic():
    """
    Test Playwright MCP configuration without --user-data-dir

    Configuration to test:
    {
      "mcpServers": {
        "playwright-mcp": {
          "command": "npx",
          "args": ["-y", "@playwright/mcp"]
        }
      }
    }
    """
    # Create test directory
    test_dir = Path(tempfile.mkdtemp(prefix="claude-test-playwright-basic-v2-"))
    test_dir.mkdir(parents=True, exist_ok=True)

    # Create .mcp.json configuration
    mcp_config = {
        "mcpServers": {
            "playwright-mcp": {
                "command": "npx",
                "args": ["-y", "@playwright/mcp"]
            }
        }
    }

    mcp_file = test_dir / ".mcp.json"
    mcp_file.write_text(json.dumps(mcp_config, indent=2), encoding='utf-8')

    print("=" * 80)
    print("TEST: Playwright MCP (no user-data-dir)")
    print("=" * 80)
    print(f"\nTest directory: {test_dir}")
    print(f"\nConfiguration:")
    print(json.dumps(mcp_config, indent=2))
    print("\n" + "=" * 80)

    # Test command: Ask Claude Code to list MCP tools
    test_prompt = "List all available MCP tools. Show me the playwright MCP tools if connected."

    # Prepare command
    if platform.system() == "Windows":
        cmd = ["claude.cmd", "--print", test_prompt]
    else:
        cmd = ["claude", "--print", test_prompt]

    print(f"\nExecuting: {' '.join(cmd[:2])} '{test_prompt}'")
    print(f"Working directory: {test_dir}")
    print(f"Timeout: 3600 seconds (1 hour)")
    print("\n" + "=" * 80)

    start_time = time.time()

    try:
        # Run in completely isolated subprocess with 1 hour timeout
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
        output_file.write_text(
            f"=== STDOUT ===\n\n{result.stdout}\n\n=== STDERR ===\n\n{result.stderr}",
            encoding='utf-8'
        )

        print(f"\n{'=' * 80}")
        print(f"TEST COMPLETED in {elapsed:.1f}s")
        print(f"{'=' * 80}")
        print(f"Exit code: {result.returncode}")
        print(f"\n{'=' * 80}")
        print("STDOUT:")
        print(f"{'=' * 80}")
        print(result.stdout)
        print(f"\n{'=' * 80}")
        print("STDERR:")
        print(f"{'=' * 80}")
        print(result.stderr)
        print(f"\n{'=' * 80}")

        # Determine success
        success = result.returncode == 0

        # Look for success indicators
        success_indicators = []
        error_indicators = []

        # Check for Playwright MCP connection
        if "playwright" in result.stdout.lower():
            success_indicators.append("Playwright MCP mentioned in output")

        if "mcp" in result.stdout.lower():
            success_indicators.append("MCP tools mentioned in output")

        # Look for error indicators
        if "error" in result.stdout.lower() or "error" in result.stderr.lower():
            error_indicators.append("'error' found in output")
        if "failed" in result.stdout.lower() or "failed" in result.stderr.lower():
            error_indicators.append("'failed' found in output")
        if "connection" in result.stderr.lower() and "error" in result.stderr.lower():
            error_indicators.append("Connection error detected")
        if result.returncode != 0:
            error_indicators.append(f"Non-zero exit code: {result.returncode}")

        # Final status
        final_status = "SUCCESS" if success and success_indicators and not error_indicators else "FAILURE"

        print("\nTEST RESULT:")
        print(f"{'=' * 80}")
        print(f"Configuration: Playwright MCP (no user-data-dir)")
        print(f"Status: {final_status}")
        print(f"Duration: {elapsed:.1f}s")
        if success_indicators:
            print(f"Success indicators: {', '.join(success_indicators)}")
        if error_indicators:
            print(f"Error indicators: {', '.join(error_indicators)}")
        print(f"Output saved to: {output_file}")
        print(f"{'=' * 80}")

        return {
            "success": final_status == "SUCCESS",
            "exit_code": result.returncode,
            "duration": elapsed,
            "stdout": result.stdout,
            "stderr": result.stderr,
            "test_dir": test_dir,
            "success_indicators": success_indicators,
            "error_indicators": error_indicators
        }

    except subprocess.TimeoutExpired:
        elapsed = time.time() - start_time
        print(f"\n{'=' * 80}")
        print(f"TEST TIMEOUT after {elapsed:.1f}s")
        print(f"{'=' * 80}")
        return {
            "success": False,
            "exit_code": -1,
            "duration": elapsed,
            "error": "timeout",
            "test_dir": test_dir
        }
    except Exception as e:
        elapsed = time.time() - start_time
        print(f"\n{'=' * 80}")
        print(f"TEST ERROR: {e}")
        print(f"{'=' * 80}")
        return {
            "success": False,
            "exit_code": -2,
            "duration": elapsed,
            "error": str(e),
            "test_dir": test_dir
        }

if __name__ == "__main__":
    result = test_playwright_mcp_basic()

    print("\n" + "=" * 80)
    print("FINAL SUMMARY")
    print("=" * 80)
    print(f"Configuration: Playwright MCP (no user-data-dir)")
    print(f"Status: {'SUCCESS' if result['success'] else 'FAILURE'}")
    print(f"Duration: {result['duration']:.1f}s")
    print(f"Test directory: {result['test_dir']}")
    if 'error' in result:
        print(f"Error: {result['error']}")
    if 'success_indicators' in result and result['success_indicators']:
        print(f"Success indicators: {', '.join(result['success_indicators'])}")
    if 'error_indicators' in result and result['error_indicators']:
        print(f"Error indicators: {', '.join(result['error_indicators'])}")
    print("=" * 80)
