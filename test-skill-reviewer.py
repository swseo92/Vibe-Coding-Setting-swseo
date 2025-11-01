"""
Test skill-reviewer skill in isolated Claude Code session

This script tests whether skill-reviewer can analyze ai-collaborative-solver
according to skill-creator guidelines.
"""

import subprocess
import tempfile
import time
from pathlib import Path
import json

def test_skill_reviewer():
    """
    Test skill-reviewer skill in isolated subprocess

    Expected behavior:
    1. skill-reviewer activates automatically
    2. Analyzes .claude/skills/ai-collaborative-solver/SKILL.md
    3. Evaluates against skill-creator guidelines
    4. Provides score and detailed review
    """

    # Use the actual workspace directory
    test_dir = Path(r"C:\Users\EST\PycharmProjects\my agents\Vibe-Coding-Setting-swseo")

    # Verify ai-collaborative-solver exists
    skill_path = test_dir / ".claude" / "skills" / "ai-collaborative-solver" / "SKILL.md"
    if not skill_path.exists():
        print(f"[FAIL] Skill not found at: {skill_path}")
        return {
            "success": False,
            "error": "ai-collaborative-solver skill not found"
        }

    print(f"[OK] Found ai-collaborative-solver at: {skill_path}")

    # Natural language test command
    test_command = "ai-collaborative-solver 스킬을 skill-creator 가이드라인에 따라 리뷰해줘"

    # Prepare command (use claude.cmd on Windows)
    cmd = ["claude.cmd", "--print", test_command]

    print(f"\n{'='*80}")
    print(f"Testing: skill-reviewer skill")
    print(f"Command: {test_command}")
    print(f"Working directory: {test_dir}")
    print(f"Timeout: 3600s (1 hour)")
    print(f"{'='*80}\n")

    start_time = time.time()

    try:
        # Run in isolated subprocess with 1 hour timeout
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
        output_dir = test_dir / ".test-outputs"
        output_dir.mkdir(exist_ok=True)

        output_file = output_dir / "skill-reviewer-test-output.log"
        output_file.write_text(
            f"=== STDOUT ===\n\n{result.stdout}\n\n=== STDERR ===\n\n{result.stderr}",
            encoding='utf-8'
        )

        print(f"\n{'='*80}")
        print(f"[OK] Test completed in {elapsed:.1f}s")
        print(f"Exit code: {result.returncode}")
        print(f"Output saved to: {output_file}")
        print(f"{'='*80}\n")

        # Analyze output
        analysis = analyze_output(result.stdout, result.stderr)

        return {
            "success": result.returncode == 0,
            "exit_code": result.returncode,
            "duration": elapsed,
            "stdout": result.stdout,
            "stderr": result.stderr,
            "output_file": str(output_file),
            "analysis": analysis
        }

    except subprocess.TimeoutExpired:
        elapsed = time.time() - start_time
        print(f"\n[TIMEOUT] Timeout after {elapsed:.1f}s")
        return {
            "success": False,
            "exit_code": -1,
            "duration": elapsed,
            "error": "timeout"
        }
    except Exception as e:
        elapsed = time.time() - start_time
        print(f"\n[ERROR] Error: {e}")
        return {
            "success": False,
            "exit_code": -2,
            "duration": elapsed,
            "error": str(e)
        }

def analyze_output(stdout: str, stderr: str) -> dict:
    """Analyze the output to extract review results"""

    analysis = {
        "skill_reviewer_activated": False,
        "review_completed": False,
        "score": None,
        "major_issues": [],
        "recommendations": [],
        "full_review": ""
    }

    # Check if skill-reviewer activated
    if "skill-reviewer" in stdout.lower() or "reviewing" in stdout.lower():
        analysis["skill_reviewer_activated"] = True

    # Check if review completed
    if "review" in stdout.lower() and ("score" in stdout.lower() or "compliance" in stdout.lower()):
        analysis["review_completed"] = True

    # Try to extract score (look for patterns like "85/100", "Score: 85")
    import re
    score_patterns = [
        r'(\d+)/100',
        r'score[:\s]+(\d+)',
        r'compliance[:\s]+(\d+)'
    ]
    for pattern in score_patterns:
        match = re.search(pattern, stdout, re.IGNORECASE)
        if match:
            analysis["score"] = int(match.group(1))
            break

    # Extract issues (look for bullet points or numbered lists after "issues", "problems", etc.)
    if "issue" in stdout.lower() or "problem" in stdout.lower():
        lines = stdout.split('\n')
        in_issues_section = False
        for line in lines:
            if any(keyword in line.lower() for keyword in ["issue", "problem", "concern"]):
                in_issues_section = True
            elif in_issues_section and (line.strip().startswith('-') or line.strip().startswith('•')):
                analysis["major_issues"].append(line.strip())

    # Extract recommendations
    if "recommend" in stdout.lower() or "suggestion" in stdout.lower():
        lines = stdout.split('\n')
        in_rec_section = False
        for line in lines:
            if any(keyword in line.lower() for keyword in ["recommend", "suggestion", "should"]):
                in_rec_section = True
            elif in_rec_section and (line.strip().startswith('-') or line.strip().startswith('•')):
                analysis["recommendations"].append(line.strip())

    # Store full review
    analysis["full_review"] = stdout

    return analysis

def print_report(result: dict):
    """Print a formatted test report"""

    print("\n" + "="*80)
    print("SKILL-REVIEWER TEST REPORT")
    print("="*80)

    if not result["success"]:
        print(f"\n[FAIL] Test FAILED")
        print(f"Exit code: {result.get('exit_code', 'unknown')}")
        print(f"Error: {result.get('error', 'unknown error')}")
        return

    print(f"\n[OK] Test PASSED")
    print(f"Duration: {result['duration']:.1f}s")

    analysis = result.get("analysis", {})

    print("\n" + "-"*80)
    print("REVIEW RESULTS")
    print("-"*80)

    print(f"\n1. skill-reviewer activated: {'[YES]' if analysis.get('skill_reviewer_activated') else '[NO]'}")
    print(f"2. Review completed: {'[YES]' if analysis.get('review_completed') else '[NO]'}")

    score = analysis.get('score')
    if score is not None:
        print(f"3. Compliance Score: {score}/100")
    else:
        print(f"3. Compliance Score: [WARN] Not found in output")

    issues = analysis.get('major_issues', [])
    if issues:
        print(f"\n4. Major Issues Found ({len(issues)}):")
        for issue in issues[:5]:  # Show first 5
            print(f"   {issue}")
    else:
        print(f"\n4. Major Issues: None extracted (check full output)")

    recs = analysis.get('recommendations', [])
    if recs:
        print(f"\n5. Recommendations ({len(recs)}):")
        for rec in recs[:5]:  # Show first 5
            print(f"   {rec}")
    else:
        print(f"\n5. Recommendations: None extracted (check full output)")

    print(f"\n6. Full output saved to: {result.get('output_file', 'unknown')}")

    print("\n" + "="*80)

if __name__ == "__main__":
    print("Starting skill-reviewer test...")
    result = test_skill_reviewer()
    print_report(result)

    # Save result as JSON
    result_file = Path(r"C:\Users\EST\PycharmProjects\my agents\Vibe-Coding-Setting-swseo\.test-outputs\skill-reviewer-test-result.json")
    result_file.parent.mkdir(exist_ok=True)

    # Make result JSON serializable
    json_result = {
        "success": result.get("success"),
        "exit_code": result.get("exit_code"),
        "duration": result.get("duration"),
        "output_file": result.get("output_file"),
        "analysis": result.get("analysis", {})
    }

    result_file.write_text(json.dumps(json_result, indent=2, ensure_ascii=False), encoding='utf-8')
    print(f"\nResult saved to: {result_file}")
