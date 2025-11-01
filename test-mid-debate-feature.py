#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Test Script: Mid-debate User Input Feature
Tests the AI Collaborative Solver's mid-debate heuristic detection
"""

import subprocess
import time
from pathlib import Path
import re
import json
from typing import Dict, List
import sys
import io

# Force UTF-8 output on Windows
if sys.platform == 'win32':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8')

def test_mid_debate_feature():
    """
    Test the mid-debate user input feature comprehensively
    """
    print("=" * 80)
    print("TEST: Mid-debate User Input Feature")
    print("=" * 80)
    print()

    # Test configuration
    test_dir = Path(r"C:\Users\EST\PycharmProjects\my agents\Vibe-Coding-Setting-swseo\.claude\skills\ai-collaborative-solver")
    test_topic = "우리 팀에 어떤 데이터베이스를 사용해야 할지 모르겠어요"
    timeout = 3600  # 1 hour - MUST use long timeout for agent execution

    print(f"Test Directory: {test_dir}")
    print(f"Test Topic: {test_topic}")
    print(f"Timeout: {timeout}s (1 hour)")
    print()

    # Change to test directory
    original_dir = Path.cwd()

    try:
        # Execute the debate script
        print("=" * 80)
        print("STEP 1: Execute AI Debate")
        print("=" * 80)
        print()

        start_time = time.time()

        # Generate session directory with timestamp
        timestamp = time.strftime("%Y%m%d-%H%M%S")
        session_dir = test_dir / "sessions" / timestamp

        # On Windows, use Git Bash directly with full path
        if sys.platform == 'win32':
            bash_path = r"C:\Program Files\Git\bin\bash.exe"
            cmd = [
                bash_path,
                str(test_dir / "scripts" / "facilitator.sh"),
                test_topic,
                "claude",
                "simple",
                str(session_dir)
            ]
        else:
            cmd = ["bash", "ai-debate.sh", test_topic]

        print(f"Command: {' '.join(cmd)}")
        print(f"Working Directory: {test_dir}")
        print()
        print("Executing... (this may take several minutes)")
        print()

        result = subprocess.run(
            cmd,
            cwd=str(test_dir),
            capture_output=True,
            text=True,
            timeout=timeout,
            encoding='utf-8',
            errors='replace',
            input="\n"  # Auto-confirm start prompt
        )

        elapsed = time.time() - start_time

        print(f"Execution completed in {elapsed:.1f}s")
        print(f"Exit Code: {result.returncode}")
        print()

        # Save raw output
        output_file = test_dir / "test-mid-debate-output.log"
        output_file.write_text(
            f"STDOUT:\n{result.stdout}\n\nSTDERR:\n{result.stderr}",
            encoding='utf-8'
        )
        print(f"Raw output saved to: {output_file}")
        print()

        # ============================================================
        # STEP 2: Find the latest session directory
        # ============================================================
        print("=" * 80)
        print("STEP 2: Locate Session Results")
        print("=" * 80)
        print()

        sessions_dir = test_dir / "sessions"
        if not sessions_dir.exists():
            print("❌ ERROR: sessions/ directory not found!")
            return generate_report(False, "sessions/ directory not found", result, elapsed)

        # Find latest session
        session_dirs = sorted([d for d in sessions_dir.iterdir() if d.is_dir()], reverse=True)

        if not session_dirs:
            print("❌ ERROR: No session directories found!")
            return generate_report(False, "No session directories found", result, elapsed)

        latest_session = session_dirs[0]
        print(f"✅ Latest Session: {latest_session.name}")
        print(f"   Full Path: {latest_session}")
        print()

        # ============================================================
        # STEP 3: Verify Output Files
        # ============================================================
        print("=" * 80)
        print("STEP 3: Verify Output Files")
        print("=" * 80)
        print()

        expected_files = [
            "debate_summary.md",
            "session_info.txt"
        ]

        files_found = {}
        for filename in expected_files:
            filepath = latest_session / filename
            exists = filepath.exists()
            files_found[filename] = exists
            status = "✅" if exists else "❌"
            print(f"{status} {filename}: {'Found' if exists else 'NOT FOUND'}")

        print()

        # Check rounds directory
        rounds_dir = latest_session / "rounds"
        if rounds_dir.exists():
            round_files = list(rounds_dir.glob("*.txt"))
            print(f"✅ rounds/ directory: {len(round_files)} files")
            for rf in sorted(round_files):
                print(f"   - {rf.name}")
        else:
            print("❌ rounds/ directory: NOT FOUND")
            files_found['rounds'] = False

        print()

        # ============================================================
        # STEP 4: Analyze Round 2 for Heuristic Triggers
        # ============================================================
        print("=" * 80)
        print("STEP 4: Analyze Round 2 for Heuristic Triggers")
        print("=" * 80)
        print()

        # Heuristic keywords from facilitator.sh
        low_confidence_keywords = [
            "unclear", "uncertain", "depends on",
            "need.*information", "assume"
        ]
        deadlock_keywords = [
            "however", "disagree", "alternatively"
        ]

        all_keywords = low_confidence_keywords + deadlock_keywords

        round2_file = rounds_dir / "round2_response.txt" if rounds_dir.exists() else None

        if round2_file and round2_file.exists():
            round2_content = round2_file.read_text(encoding='utf-8', errors='replace')
            print(f"Round 2 Response Length: {len(round2_content)} characters")
            print()

            # Check for keywords
            matches = {}
            for keyword in all_keywords:
                pattern = re.compile(keyword, re.IGNORECASE)
                found = pattern.search(round2_content)
                matches[keyword] = found is not None

            print("Heuristic Keyword Analysis:")
            print()
            print("Low Confidence Markers:")
            low_conf_found = False
            for kw in low_confidence_keywords:
                status = "✅ FOUND" if matches[kw] else "❌ Not found"
                print(f"  {status}: '{kw}'")
                if matches[kw]:
                    low_conf_found = True

            print()
            print("Deadlock Markers:")
            deadlock_found = False
            for kw in deadlock_keywords:
                status = "✅ FOUND" if matches[kw] else "❌ Not found"
                print(f"  {status}: '{kw}'")
                if matches[kw]:
                    deadlock_found = True

            print()

            heuristic_triggered = low_conf_found or deadlock_found

            if heuristic_triggered:
                print("🎯 RESULT: Heuristic WOULD trigger (keywords found)")
            else:
                print("⚠️  RESULT: Heuristic would NOT trigger (no keywords found)")

            print()

            # Show excerpt with matches
            if heuristic_triggered:
                print("Sample excerpts with trigger keywords:")
                print()
                for kw, found in matches.items():
                    if found:
                        pattern = re.compile(f".{{0,50}}{kw}.{{0,50}}", re.IGNORECASE | re.DOTALL)
                        match = pattern.search(round2_content)
                        if match:
                            excerpt = match.group(0).replace('\n', ' ')
                            print(f"  '{kw}': ...{excerpt}...")
                print()
        else:
            print("❌ ERROR: round2_response.txt not found!")
            heuristic_triggered = None

        # ============================================================
        # STEP 5: Check for User Input Evidence
        # ============================================================
        print("=" * 80)
        print("STEP 5: Check for User Input Evidence")
        print("=" * 80)
        print()

        user_input_files = list(rounds_dir.glob("*user_input.txt")) if rounds_dir.exists() else []

        if user_input_files:
            print(f"✅ User input files found: {len(user_input_files)}")
            for uif in sorted(user_input_files):
                content = uif.read_text(encoding='utf-8', errors='replace')
                print(f"   - {uif.name}: {len(content)} characters")
                print(f"     Preview: {content[:100]}...")
        else:
            print("ℹ️  No user input files (expected - auto-skip in non-interactive meta-test)")

        print()

        # ============================================================
        # STEP 6: Verify Debate Completion
        # ============================================================
        print("=" * 80)
        print("STEP 6: Verify Debate Completion")
        print("=" * 80)
        print()

        summary_file = latest_session / "debate_summary.md"
        if summary_file.exists():
            summary_content = summary_file.read_text(encoding='utf-8', errors='replace')

            # Check for synthesis section
            has_synthesis = "## Final Synthesis" in summary_content or "synthesis" in summary_content.lower()

            status = "✅" if has_synthesis else "⚠️"
            print(f"{status} Final Synthesis: {'Present' if has_synthesis else 'Missing'}")

            # Count rounds
            round_count = len([line for line in summary_content.split('\n') if line.startswith("### Round")])
            print(f"ℹ️  Rounds completed: {round_count}")

            print()
            print("Summary file excerpt (first 500 chars):")
            print("-" * 60)
            print(summary_content[:500])
            print("-" * 60)
            print()
        else:
            has_synthesis = False
            print("❌ debate_summary.md not found!")

        # ============================================================
        # STEP 7: Final Assessment
        # ============================================================
        print("=" * 80)
        print("STEP 7: Final Assessment")
        print("=" * 80)
        print()

        success_criteria = {
            "Exit code 0": result.returncode == 0,
            "Session directory created": bool(session_dirs),
            "Output files present": all(files_found.values()),
            "Round 2 analyzed": round2_file is not None and round2_file.exists(),
            "Heuristic keywords found": heuristic_triggered is True,
            "Debate completed": has_synthesis,
        }

        print("Success Criteria Checklist:")
        print()

        all_passed = True
        for criterion, passed in success_criteria.items():
            status = "✅ PASS" if passed else "❌ FAIL"
            print(f"  {status}: {criterion}")
            if not passed:
                all_passed = False

        print()

        if all_passed:
            print("🎉 TEST RESULT: PASS")
            print()
            print("All success criteria met!")
        else:
            print("⚠️  TEST RESULT: PARTIAL PASS")
            print()
            print("Some criteria not met - see details above")

        print()
        print("=" * 80)
        print("TEST COMPLETE")
        print("=" * 80)
        print()
        print(f"Duration: {elapsed:.1f}s")
        print(f"Session: {latest_session}")
        print(f"Raw Log: {output_file}")
        print()

        return {
            "success": all_passed,
            "exit_code": result.returncode,
            "duration": elapsed,
            "session_dir": str(latest_session),
            "criteria": success_criteria,
            "heuristic_triggered": heuristic_triggered
        }

    except subprocess.TimeoutExpired:
        elapsed = time.time() - start_time
        print(f"❌ TEST FAILED: Timeout after {elapsed:.1f}s")
        return {
            "success": False,
            "error": "timeout",
            "duration": elapsed
        }
    except Exception as e:
        print(f"❌ TEST FAILED: {e}")
        import traceback
        traceback.print_exc()
        return {
            "success": False,
            "error": str(e)
        }


def generate_report(success: bool, reason: str, result, elapsed: float) -> Dict:
    """Generate test report for early termination"""
    return {
        "success": success,
        "reason": reason,
        "exit_code": result.returncode if result else -1,
        "duration": elapsed
    }


if __name__ == "__main__":
    result = test_mid_debate_feature()

    # Save result as JSON
    import json
    output_path = Path(r"C:\Users\EST\PycharmProjects\my agents\Vibe-Coding-Setting-swseo\test-mid-debate-result.json")
    output_path.write_text(json.dumps(result, indent=2), encoding='utf-8')
    print(f"Test result saved to: {output_path}")
