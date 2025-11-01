#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
test_worktree_disk.py: Measure actual disk usage of git worktrees vs full clones.

Tests the claim from debate: "Git worktrees save ~90% disk space via hard links"
"""
import subprocess
import sys
import tempfile
from pathlib import Path

# Fix Windows console encoding
if sys.platform == 'win32':
    sys.stdout.reconfigure(encoding='utf-8')


def get_dir_size(path: Path) -> int:
    """Get total size of directory in bytes."""
    if not path.exists():
        return 0

    # On Windows, use powershell for accurate size
    try:
        result = subprocess.run(
            ['powershell', '-Command',
             f'(Get-ChildItem -Path "{path}" -Recurse | Measure-Object -Property Length -Sum).Sum'],
            capture_output=True,
            text=True,
            check=True
        )
        return int(result.stdout.strip())
    except:
        # Fallback to simple sum
        total = 0
        for f in path.rglob('*'):
            if f.is_file():
                try:
                    total += f.stat().st_size
                except:
                    pass
        return total


def test_worktree_vs_clone():
    """Compare disk usage: worktree vs full clone."""

    with tempfile.TemporaryDirectory() as tmpdir:
        tmpdir = Path(tmpdir)

        # 1. Create a test repo with some content
        main_repo = tmpdir / "main-repo"
        main_repo.mkdir()

        print("📦 Creating test repository...")
        subprocess.run(['git', 'init'], cwd=main_repo, check=True, capture_output=True)
        subprocess.run(['git', 'config', 'user.email', 'test@test.com'], cwd=main_repo, check=True, capture_output=True)
        subprocess.run(['git', 'config', 'user.name', 'Test'], cwd=main_repo, check=True, capture_output=True)

        # Create some files to simulate a real project
        (main_repo / "README.md").write_text("# Test Project\n" * 100)
        (main_repo / "src").mkdir()
        for i in range(10):
            (main_repo / "src" / f"file{i}.py").write_text(f"# File {i}\n" + "x = 1\n" * 100)

        subprocess.run(['git', 'add', '.'], cwd=main_repo, check=True, capture_output=True)
        subprocess.run(['git', 'commit', '-m', 'Initial'], cwd=main_repo, check=True, capture_output=True)

        main_size = get_dir_size(main_repo)
        print(f"✅ Main repo size: {main_size:,} bytes ({main_size / 1024:.1f} KB)")

        # 2. Create worktree
        worktree_dir = tmpdir / "worktree"
        print("\n🌿 Creating worktree...")
        subprocess.run(['git', 'worktree', 'add', str(worktree_dir), '-b', 'feature'],
                      cwd=main_repo, check=True, capture_output=True)

        worktree_size = get_dir_size(worktree_dir)
        print(f"✅ Worktree size: {worktree_size:,} bytes ({worktree_size / 1024:.1f} KB)")

        # 3. Create full clone
        clone_dir = tmpdir / "clone"
        print("\n📋 Creating full clone...")
        subprocess.run(['git', 'clone', str(main_repo), str(clone_dir)],
                      check=True, capture_output=True)

        clone_size = get_dir_size(clone_dir)
        print(f"✅ Clone size: {clone_size:,} bytes ({clone_size / 1024:.1f} KB)")

        # 4. Calculate savings
        print("\n" + "="*60)
        print("📊 RESULTS")
        print("="*60)

        savings = ((clone_size - worktree_size) / clone_size) * 100
        print(f"\n💾 Worktree vs Clone:")
        print(f"   Clone:    {clone_size:,} bytes ({clone_size / 1024:.1f} KB)")
        print(f"   Worktree: {worktree_size:,} bytes ({worktree_size / 1024:.1f} KB)")
        print(f"   Savings:  {clone_size - worktree_size:,} bytes ({savings:.1f}%)")

        # 5. Verify claim
        claimed_savings = 90.0
        print(f"\n🎯 Claim Verification:")
        print(f"   Claimed:  ~{claimed_savings}% savings")
        print(f"   Measured: {savings:.1f}% savings")

        if abs(savings - claimed_savings) < 20:
            print(f"   ✅ VERIFIED (within reasonable margin)")
        else:
            print(f"   ⚠️  CLAIM NEEDS REVISION")
            print(f"   Difference: {abs(savings - claimed_savings):.1f}%")

        return {
            'main_size': main_size,
            'worktree_size': worktree_size,
            'clone_size': clone_size,
            'savings_percent': savings
        }


if __name__ == '__main__':
    print("="*60)
    print("Git Worktree Disk Usage Verification")
    print("="*60)
    print("\nTesting claim: 'Git worktrees save ~90% disk space'\n")

    try:
        results = test_worktree_vs_clone()
        print("\n" + "="*60)
        print("✅ Verification complete!")
        print("="*60)
    except Exception as e:
        print(f"\n❌ Verification failed: {e}")
        import traceback
        traceback.print_exc()
