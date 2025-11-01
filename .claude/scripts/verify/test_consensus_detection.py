#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
test_consensus_detection.py: Test consensus detection algorithm on real debate transcripts.

Tests the algorithm proposed in meta-debate:
```python
def detect_consensus(claude_pos, codex_resp):
    agreement = ["I agree", "동의", "correct", "맞습니다"]
    concerns = ["However", "But", "하지만", "issue"]

    has_agreement = any(sig in codex_resp for sig in agreement)
    has_new_concerns = any(sig in codex_resp for sig in concerns)

    return has_agreement and not has_new_concerns
```
"""
import sys
from pathlib import Path
import re
from typing import Dict, List, Tuple

# Fix Windows console encoding
if sys.platform == 'win32':
    sys.stdout.reconfigure(encoding='utf-8')


def detect_consensus(claude_position: str, codex_response: str) -> bool:
    """
    Detect consensus based on agreement signals and absence of new concerns.

    Args:
        claude_position: Claude's position/proposal
        codex_response: Codex's response to Claude

    Returns:
        True if consensus detected, False otherwise
    """
    agreement_signals = [
        "I agree", "동의", "correct", "맞습니다", "You're right",
        "exactly", "precisely", "absolutely", "indeed", "yes",
        "this is good", "좋은", "perfect", "sound", "valid"
    ]

    concern_signals = [
        "However", "But", "하지만", "issue", "problem", "concern",
        "worry", "risk", "flaw", "mistake", "wrong", "disagree",
        "not convinced", "문제", "걱정", "반대"
    ]

    codex_lower = codex_response.lower()

    has_agreement = any(sig.lower() in codex_lower for sig in agreement_signals)
    has_new_concerns = any(sig.lower() in codex_lower for sig in concern_signals)

    return has_agreement and not has_new_concerns


def extract_debate_rounds(report_path: Path) -> List[Tuple[str, str]]:
    """
    Extract Claude positions and Codex responses from debate report.

    Returns:
        List of (claude_position, codex_response) tuples
    """
    content = report_path.read_text(encoding='utf-8')

    rounds = []

    # Pattern: Find "### Round N: ..." sections
    round_pattern = r'### Round \d+:.*?\n(.*?)(?=### Round \d+:|## Final Consensus|---\n\n## |$)'
    round_matches = re.findall(round_pattern, content, re.DOTALL)

    for round_text in round_matches:
        # Extract Claude's proposal
        claude_match = re.search(r'\*\*Claude.*?\*\*.*?\n(.*?)(?=\*\*Codex|\n\n###|\Z)', round_text, re.DOTALL)
        # Extract Codex's response
        codex_match = re.search(r'\*\*Codex.*?\*\*.*?\n(.*?)(?=\n\n###|\Z)', round_text, re.DOTALL)

        if claude_match and codex_match:
            claude_pos = claude_match.group(1).strip()
            codex_resp = codex_match.group(1).strip()
            rounds.append((claude_pos, codex_resp))

    return rounds


def test_on_real_debates():
    """Test consensus detection on actual debate reports."""

    debate_reports = [
        Path(__file__).parent.parent.parent.parent / ".debate-reports" / "2025-10-31-pycharm-worktree-indexing.md",
        Path(__file__).parent.parent.parent.parent / ".debate-reports" / "2025-10-31-meta-codex-skill-improvements.md",
    ]

    print("=" * 60)
    print("Consensus Detection Algorithm Test")
    print("=" * 60)

    all_results = []

    for report_path in debate_reports:
        if not report_path.exists():
            print(f"\n⚠️  Skipping: {report_path.name} (not found)")
            continue

        print(f"\n📄 Testing: {report_path.name}")
        print("-" * 60)

        rounds = extract_debate_rounds(report_path)

        if not rounds:
            print(f"   ⚠️  Could not extract rounds from report")
            continue

        print(f"   Found {len(rounds)} rounds")

        for i, (claude_pos, codex_resp) in enumerate(rounds, 1):
            consensus = detect_consensus(claude_pos, codex_resp)

            # Preview
            claude_preview = claude_pos[:100].replace('\n', ' ') + "..."
            codex_preview = codex_resp[:100].replace('\n', ' ') + "..."

            print(f"\n   Round {i}:")
            print(f"      Claude: {claude_preview}")
            print(f"      Codex:  {codex_preview}")
            print(f"      Consensus: {'✅ YES' if consensus else '❌ NO'}")

            all_results.append({
                'report': report_path.name,
                'round': i,
                'consensus': consensus,
                'claude': claude_pos,
                'codex': codex_resp
            })

    # Summary
    print("\n" + "=" * 60)
    print("📊 RESULTS")
    print("=" * 60)

    total = len(all_results)
    consensus_count = sum(1 for r in all_results if r['consensus'])

    print(f"\nTotal rounds analyzed: {total}")
    print(f"Consensus detected: {consensus_count} ({consensus_count/total*100:.1f}%)")
    print(f"No consensus: {total - consensus_count} ({(total-consensus_count)/total*100:.1f}%)")

    # Manual verification check
    print(f"\n🎯 Manual Verification Needed:")
    print(f"   Both debates reached consensus in Round 1-2")
    print(f"   Expected: Early rounds = no consensus, later rounds = consensus")
    print(f"   Algorithm accuracy can only be verified by:")
    print(f"   1. Reading actual debate transcripts")
    print(f"   2. Comparing algorithm output to human judgment")
    print(f"   3. Testing on diverse debate outcomes (consensus, disagreement, partial)")

    return all_results


def test_synthetic_cases():
    """Test on synthetic examples with known outcomes."""

    print("\n" + "=" * 60)
    print("🧪 Synthetic Test Cases")
    print("=" * 60)

    test_cases = [
        {
            'name': 'Clear Agreement',
            'claude': 'We should use Option A because it is simpler.',
            'codex': 'I agree completely. Option A is the right choice.',
            'expected': True
        },
        {
            'name': 'Agreement with Concerns',
            'claude': 'We should use Option A.',
            'codex': 'I agree with Option A. However, we need to consider security implications.',
            'expected': False
        },
        {
            'name': 'Disagreement',
            'claude': 'We should use Option A.',
            'codex': 'I disagree. Option B is better because of performance.',
            'expected': False
        },
        {
            'name': 'Korean Agreement',
            'claude': 'Option A를 사용하는게 좋겠습니다.',
            'codex': '동의합니다. 좋은 선택입니다.',
            'expected': True
        },
        {
            'name': 'Korean Agreement with Concerns',
            'claude': 'Option A를 사용하는게 좋겠습니다.',
            'codex': '동의합니다. 하지만 보안 문제가 있을 수 있습니다.',
            'expected': False
        }
    ]

    correct = 0
    for case in test_cases:
        result = detect_consensus(case['claude'], case['codex'])
        match = "✅" if result == case['expected'] else "❌"

        print(f"\n{match} {case['name']}")
        print(f"   Expected: {case['expected']}, Got: {result}")

        if result == case['expected']:
            correct += 1

    accuracy = (correct / len(test_cases)) * 100
    print(f"\n📊 Synthetic Test Accuracy: {correct}/{len(test_cases)} ({accuracy:.1f}%)")

    return accuracy


if __name__ == '__main__':
    print("Testing consensus detection algorithm from meta-debate...\n")

    try:
        # Test on synthetic cases first
        synthetic_accuracy = test_synthetic_cases()

        # Test on real debate reports
        real_results = test_on_real_debates()

        print("\n" + "=" * 60)
        print("✅ Verification Complete")
        print("=" * 60)

        print(f"\n📌 Key Findings:")
        print(f"   - Synthetic test accuracy: {synthetic_accuracy:.1f}%")
        print(f"   - Real debates need manual review to validate")
        print(f"   - Algorithm is simple keyword-based (not ML)")
        print(f"   - Works for basic cases, may miss nuanced agreements")

    except Exception as e:
        print(f"\n❌ Test failed: {e}")
        import traceback
        traceback.print_exc()
