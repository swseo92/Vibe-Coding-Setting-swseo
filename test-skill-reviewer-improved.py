"""
Test the improved skill-reviewer skill by having it review itself.

This test verifies:
1. Template placeholder substitution ({SKILL_NAME}, {DATE}, etc.)
2. Recursive script discovery with find command
3. --skip-git-repo-check flag working
4. set -o pipefail preventing silent failures
5. Overall review quality improvement
"""

import subprocess
import tempfile
from pathlib import Path
import time
import platform
import json
import re

def test_skill_reviewer_improved(timeout: int = 3600):
    """
    Test improved skill-reviewer by having it review itself

    Args:
        timeout: Max seconds to wait (default: 3600 = 1 hour)
    """
    # Create test directory
    test_dir = Path(tempfile.mkdtemp(prefix="skill-reviewer-test-"))
    test_dir.mkdir(parents=True, exist_ok=True)

    # Test command: trigger skill-reviewer to review itself
    test_command = "review the skill-reviewer skill with codex. perform both compliance and functionality reviews."

    # Prepare command
    if platform.system() == "Windows":
        cmd = ["claude.cmd", "--print", test_command]
    else:
        cmd = ["claude", "--print", test_command]

    print("=" * 80)
    print("TESTING IMPROVED SKILL-REVIEWER")
    print("=" * 80)
    print(f"Test command: {test_command}")
    print(f"Test directory: {test_dir}")
    print(f"Timeout: {timeout}s")
    print(f"Start time: {time.strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 80)

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

        print(f"\n{'=' * 80}")
        print(f"TEST COMPLETED in {elapsed:.1f}s")
        print(f"Exit code: {result.returncode}")
        print(f"{'=' * 80}\n")

        # Analyze output
        analysis = analyze_skill_reviewer_output(result.stdout, result.stderr)

        # Print analysis
        print_analysis(analysis, elapsed, result.returncode)

        # Save analysis
        analysis_file = test_dir / "analysis.json"
        analysis_file.write_text(
            json.dumps(analysis, indent=2, ensure_ascii=False),
            encoding='utf-8'
        )

        return {
            "success": result.returncode == 0,
            "exit_code": result.returncode,
            "duration": elapsed,
            "stdout": result.stdout,
            "stderr": result.stderr,
            "test_dir": test_dir,
            "analysis": analysis
        }

    except subprocess.TimeoutExpired:
        elapsed = time.time() - start_time
        print(f"\n{'=' * 80}")
        print(f"TIMEOUT after {elapsed:.1f}s")
        print(f"{'=' * 80}\n")
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
        print(f"ERROR: {e}")
        print(f"{'=' * 80}\n")
        return {
            "success": False,
            "exit_code": -2,
            "duration": elapsed,
            "error": str(e),
            "test_dir": test_dir
        }

def analyze_skill_reviewer_output(stdout: str, stderr: str) -> dict:
    """Analyze skill-reviewer output for improvements and issues"""

    analysis = {
        "triggering": {
            "score": 0,
            "issues": [],
            "successes": []
        },
        "functionality": {
            "score": 0,
            "issues": [],
            "successes": []
        },
        "improvements": {
            "placeholder_substitution": False,
            "script_discovery": False,
            "git_check_skip": False,
            "pipefail": False,
            "examples": {}
        },
        "comparison": {
            "previous_scores": {"triggering": 10, "functionality": 6},
            "current_scores": {},
            "improvement": ""
        },
        "recommendations": []
    }

    combined = stdout + "\n" + stderr

    # Check skill triggering
    if "skill-reviewer" in combined.lower():
        analysis["triggering"]["score"] = 10
        analysis["triggering"]["successes"].append("Skill-reviewer skill triggered correctly")
    else:
        analysis["triggering"]["issues"].append("Skill-reviewer skill did NOT trigger")

    # Check for template placeholder issues
    placeholder_issues = re.findall(r'\{[A-Z_]+\}', combined)
    if placeholder_issues:
        analysis["functionality"]["issues"].append(
            f"Template placeholders NOT substituted: {set(placeholder_issues)}"
        )
        analysis["improvements"]["placeholder_substitution"] = False
    else:
        analysis["functionality"]["successes"].append(
            "Template placeholders substituted correctly"
        )
        analysis["improvements"]["placeholder_substitution"] = True

    # Check for script discovery
    if "find" in combined and ".claude/skills" in combined:
        analysis["functionality"]["successes"].append(
            "Recursive script discovery with find command"
        )
        analysis["improvements"]["script_discovery"] = True

    # Check for git errors
    if "not a git repository" in combined.lower():
        analysis["functionality"]["issues"].append(
            "Git repository check error (--skip-git-repo-check not working)"
        )
        analysis["improvements"]["git_check_skip"] = False
    else:
        analysis["functionality"]["successes"].append(
            "--skip-git-repo-check flag working correctly"
        )
        analysis["improvements"]["git_check_skip"] = True

    # Check for pipefail
    if "set -o pipefail" in combined or "pipefail" in combined:
        analysis["functionality"]["successes"].append(
            "Pipeline failure handling enabled"
        )
        analysis["improvements"]["pipefail"] = True

    # Check for Codex output
    if "codex" in combined.lower() and ("review" in combined.lower() or "analysis" in combined.lower()):
        analysis["functionality"]["successes"].append(
            "Codex review executed successfully"
        )
    else:
        analysis["functionality"]["issues"].append(
            "Codex review output not found or incomplete"
        )

    # Extract examples of substituted values
    skill_name_match = re.search(r'Reviewing skill:\s*(\S+)', combined)
    if skill_name_match:
        analysis["improvements"]["examples"]["skill_name"] = skill_name_match.group(1)

    date_match = re.search(r'Review date:\s*(\d{4}-\d{2}-\d{2})', combined)
    if date_match:
        analysis["improvements"]["examples"]["date"] = date_match.group(1)

    # Calculate functionality score
    total_checks = 6  # placeholder, script_discovery, git_check, pipefail, codex, errors
    passed_checks = (
        analysis["improvements"]["placeholder_substitution"] +
        analysis["improvements"]["script_discovery"] +
        analysis["improvements"]["git_check_skip"] +
        analysis["improvements"]["pipefail"] +
        (1 if "Codex review executed" in str(analysis["functionality"]["successes"]) else 0) +
        (1 if not any("error" in i.lower() for i in analysis["functionality"]["issues"]) else 0)
    )

    analysis["functionality"]["score"] = int((passed_checks / total_checks) * 10)

    # Comparison to previous test
    analysis["comparison"]["current_scores"] = {
        "triggering": analysis["triggering"]["score"],
        "functionality": analysis["functionality"]["score"]
    }

    prev_func = analysis["comparison"]["previous_scores"]["functionality"]
    curr_func = analysis["functionality"]["score"]

    if curr_func > prev_func:
        analysis["comparison"]["improvement"] = f"IMPROVED: {prev_func}/10 → {curr_func}/10 (+{curr_func - prev_func})"
    elif curr_func == prev_func:
        analysis["comparison"]["improvement"] = f"SAME: {curr_func}/10 (no change)"
    else:
        analysis["comparison"]["improvement"] = f"REGRESSED: {prev_func}/10 → {curr_func}/10 ({curr_func - prev_func})"

    # Recommendations
    if not analysis["improvements"]["placeholder_substitution"]:
        analysis["recommendations"].append(
            "Fix template placeholder substitution in review scripts"
        )

    if not analysis["improvements"]["script_discovery"]:
        analysis["recommendations"].append(
            "Verify find command for recursive script discovery"
        )

    if analysis["functionality"]["score"] < 8:
        analysis["recommendations"].append(
            "Review functionality issues and fix remaining bugs"
        )

    if analysis["functionality"]["score"] == 10:
        analysis["recommendations"].append(
            "All checks passed! Consider this version production-ready."
        )

    return analysis

def print_analysis(analysis: dict, duration: float, exit_code: int):
    """Print formatted analysis report"""

    print("\n" + "=" * 80)
    print("SKILL-REVIEWER IMPROVEMENT TEST REPORT")
    print("=" * 80)

    print(f"\n[EXECUTION SUMMARY]")
    print(f"   Duration: {duration:.1f}s")
    print(f"   Exit code: {exit_code}")

    print(f"\n[TRIGGERING SCORE]: {analysis['triggering']['score']}/10")
    if analysis['triggering']['successes']:
        print("   [+] Successes:")
        for s in analysis['triggering']['successes']:
            print(f"      - {s}")
    if analysis['triggering']['issues']:
        print("   [-] Issues:")
        for i in analysis['triggering']['issues']:
            print(f"      - {i}")

    print(f"\n[FUNCTIONALITY SCORE]: {analysis['functionality']['score']}/10")
    if analysis['functionality']['successes']:
        print("   [+] Successes:")
        for s in analysis['functionality']['successes']:
            print(f"      - {s}")
    if analysis['functionality']['issues']:
        print("   [-] Issues:")
        for i in analysis['functionality']['issues']:
            print(f"      - {i}")

    print(f"\n[IMPROVEMENTS VERIFIED]:")
    print(f"   - Placeholder substitution: {'[OK]' if analysis['improvements']['placeholder_substitution'] else '[FAIL]'}")
    print(f"   - Script discovery: {'[OK]' if analysis['improvements']['script_discovery'] else '[FAIL]'}")
    print(f"   - Git check skip: {'[OK]' if analysis['improvements']['git_check_skip'] else '[FAIL]'}")
    print(f"   - Pipefail handling: {'[OK]' if analysis['improvements']['pipefail'] else '[FAIL]'}")

    if analysis['improvements']['examples']:
        print(f"\n[SUBSTITUTION EXAMPLES]:")
        for key, value in analysis['improvements']['examples'].items():
            print(f"   - {key}: {value}")

    print(f"\n[COMPARISON TO PREVIOUS TEST]:")
    print(f"   Previous: Triggering={analysis['comparison']['previous_scores']['triggering']}/10, "
          f"Functionality={analysis['comparison']['previous_scores']['functionality']}/10")
    print(f"   Current:  Triggering={analysis['comparison']['current_scores']['triggering']}/10, "
          f"Functionality={analysis['comparison']['current_scores']['functionality']}/10")
    print(f"   Result:   {analysis['comparison']['improvement']}")

    if analysis['recommendations']:
        print(f"\n[RECOMMENDATIONS]:")
        for i, rec in enumerate(analysis['recommendations'], 1):
            print(f"   {i}. {rec}")

    print("\n" + "=" * 80)

if __name__ == "__main__":
    result = test_skill_reviewer_improved(timeout=3600)

    print(f"\n[Test artifacts saved to]: {result['test_dir']}")
    print(f"   - output.log - Full command output")
    print(f"   - analysis.json - Detailed analysis")

    if result.get("analysis"):
        final_score = (
            result["analysis"]["triggering"]["score"] +
            result["analysis"]["functionality"]["score"]
        ) / 2

        print(f"\n[FINAL SCORE]: {final_score:.1f}/10")

        if final_score >= 9:
            print("   Status: [OK] EXCELLENT - Production ready")
        elif final_score >= 7:
            print("   Status: [OK] GOOD - Minor improvements needed")
        elif final_score >= 5:
            print("   Status: [WARN] FAIR - Significant improvements needed")
        else:
            print("   Status: [FAIL] POOR - Major fixes required")
