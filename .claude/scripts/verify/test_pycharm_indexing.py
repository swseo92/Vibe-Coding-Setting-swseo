#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
test_pycharm_indexing.py: Simulate PyCharm indexing behavior with/without worktrees.

Tests the claim: "83% faster indexing when worktrees are outside project"

Note: This is a SIMULATION. Real verification requires:
1. Actual PyCharm installation
2. Measuring real indexing time via PyCharm logs
3. Multiple worktrees (5-10) for realistic scenario

This script simulates filesystem watch overhead as a proxy.
"""
import sys
import time
import tempfile
import subprocess
from pathlib import Path
from typing import List

# Fix Windows console encoding
if sys.platform == 'win32':
    sys.stdout.reconfigure(encoding='utf-8')


def create_test_project(base_dir: Path, name: str, file_count: int = 100):
    """Create a test Python project with given number of files."""
    project_dir = base_dir / name
    project_dir.mkdir(parents=True, exist_ok=True)

    subprocess.run(['git', 'init'], cwd=project_dir, check=True, capture_output=True)
    subprocess.run(['git', 'config', 'user.email', 'test@test.com'], cwd=project_dir, check=True, capture_output=True)
    subprocess.run(['git', 'config', 'user.name', 'Test'], cwd=project_dir, check=True, capture_output=True)

    # Create Python files
    src_dir = project_dir / "src"
    src_dir.mkdir(exist_ok=True)

    for i in range(file_count):
        (src_dir / f"module{i}.py").write_text(
            f"# Module {i}\n"
            "def function():\n"
            "    pass\n" * 10
        )

    subprocess.run(['git', 'add', '.'], cwd=project_dir, check=True, capture_output=True)
    subprocess.run(['git', 'commit', '-m', 'Initial'], cwd=project_dir, check=True, capture_output=True)

    return project_dir


def count_files_recursive(directory: Path) -> int:
    """Count total files in directory tree."""
    return sum(1 for _ in directory.rglob('*') if _.is_file())


def simulate_indexing_scan(directory: Path) -> float:
    """Simulate IDE indexing by recursively scanning all files."""
    start = time.time()
    file_count = 0

    for file_path in directory.rglob('*.py'):
        if file_path.is_file():
            try:
                # Simulate reading file (like IDE would)
                _ = file_path.read_text()
                file_count += 1
            except:
                pass

    elapsed = time.time() - start
    return elapsed, file_count


def test_worktrees_inside_vs_outside():
    """Compare indexing overhead: worktrees inside vs outside project."""

    with tempfile.TemporaryDirectory() as tmpdir:
        tmpdir = Path(tmpdir)

        print("📦 Setting up test scenario...")
        print("=" * 60)

        # Scenario A: Worktrees INSIDE project (current problem)
        print("\n🔴 Scenario A: Worktrees INSIDE project/clone/")
        main_inside = create_test_project(tmpdir / "scenario_a", "main", file_count=50)
        clone_dir = main_inside / "clone"
        clone_dir.mkdir()

        # Create 5 worktrees inside
        worktrees_inside = []
        for i in range(5):
            wt = clone_dir / f"feature-{i}"
            subprocess.run(['git', 'worktree', 'add', str(wt), '-b', f'feat{i}'],
                          cwd=main_inside, check=True, capture_output=True)
            worktrees_inside.append(wt)

        total_files_a = count_files_recursive(main_inside)
        print(f"   Created: main + 5 worktrees in clone/")
        print(f"   Total files visible to IDE: {total_files_a}")

        time_a, scanned_a = simulate_indexing_scan(main_inside)
        print(f"   Simulated scan time: {time_a:.3f}s")
        print(f"   Python files scanned: {scanned_a}")

        # Scenario B: Worktrees OUTSIDE project (solution)
        print("\n🟢 Scenario B: Worktrees OUTSIDE project")
        main_outside = create_test_project(tmpdir / "scenario_b", "main", file_count=50)
        worktree_parent = tmpdir / "scenario_b" / "worktrees"
        worktree_parent.mkdir()

        worktrees_outside = []
        for i in range(5):
            wt = worktree_parent / f"feature-{i}"
            subprocess.run(['git', 'worktree', 'add', str(wt), '-b', f'feat{i}'],
                          cwd=main_outside, check=True, capture_output=True)
            worktrees_outside.append(wt)

        # When opening main_outside in IDE (NOT worktrees)
        total_files_b = count_files_recursive(main_outside)
        print(f"   Created: main (worktrees elsewhere)")
        print(f"   Total files visible to IDE: {total_files_b}")

        time_b, scanned_b = simulate_indexing_scan(main_outside)
        print(f"   Simulated scan time: {time_b:.3f}s")
        print(f"   Python files scanned: {scanned_b}")

        # Results
        print("\n" + "=" * 60)
        print("📊 RESULTS")
        print("=" * 60)

        speedup = ((time_a - time_b) / time_a) * 100
        file_reduction = ((total_files_a - total_files_b) / total_files_a) * 100

        print(f"\n⏱️  Indexing Time:")
        print(f"   Inside:  {time_a:.3f}s ({scanned_a} files)")
        print(f"   Outside: {time_b:.3f}s ({scanned_b} files)")
        print(f"   Speedup: {speedup:.1f}%")

        print(f"\n📁 File Count Visible to IDE:")
        print(f"   Inside:  {total_files_a} files")
        print(f"   Outside: {total_files_b} files")
        print(f"   Reduction: {file_reduction:.1f}%")

        # Verify claim
        print(f"\n🎯 Claim Verification:")
        claimed_speedup = 83.0
        print(f"   Claimed:  ~{claimed_speedup}% faster indexing")
        print(f"   Simulated: {speedup:.1f}% faster")

        if speedup > 50:
            print(f"   ✅ DIRECTIONALLY CORRECT (major improvement)")
        else:
            print(f"   ⚠️  NEEDS REAL MEASUREMENT")

        print(f"\n⚠️  IMPORTANT:")
        print(f"   This is a SIMULATION using file scan time.")
        print(f"   Real verification requires:")
        print(f"   - Actual PyCharm installation")
        print(f"   - Measuring indexing via IDE logs")
        print(f"   - Larger project (10K+ files)")
        print(f"   - Real VFS + filesystem watches overhead")

        return {
            'time_inside': time_a,
            'time_outside': time_b,
            'speedup_percent': speedup,
            'files_inside': total_files_a,
            'files_outside': total_files_b
        }


if __name__ == '__main__':
    print("=" * 60)
    print("PyCharm Indexing Performance Verification (SIMULATION)")
    print("=" * 60)
    print("\nTesting claim: '83% faster indexing with worktrees outside'\n")

    try:
        results = test_worktrees_inside_vs_outside()
        print("\n" + "=" * 60)
        print("✅ Simulation complete!")
        print("=" * 60)
    except Exception as e:
        print(f"\n❌ Simulation failed: {e}")
        import traceback
        traceback.print_exc()
