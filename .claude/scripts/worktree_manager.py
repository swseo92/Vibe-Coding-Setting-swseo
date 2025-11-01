#!/usr/bin/env python3
"""
worktree_manager.py: create/delete isolated git worktrees with per-worktree venvs and PyCharm config.

Usage:
    python worktree_manager.py create feature-auth
    python worktree_manager.py delete feature-auth
"""

import argparse
import platform
import shutil
import subprocess
import sys
from pathlib import Path

# Configuration
REPO_ROOT = Path(__file__).resolve().parent.parent.parent  # Go up to project root
WORKTREE_PARENT = REPO_ROOT.parent / f"{REPO_ROOT.name}-worktrees"
IDEA_TEMPLATE = REPO_ROOT / ".idea-template"

def run(cmd, cwd=None):
    """Execute shell command and print for debugging"""
    print(f"[cmd] {' '.join(cmd)}")
    subprocess.check_call(cmd, cwd=cwd)

def detect_pycharm_launcher():
    """Detect PyCharm launcher command based on OS"""
    system = platform.system()
    if system == "Darwin":
        return ["open", "-a", "PyCharm.app"]
    if system == "Windows":
        # Try common PyCharm paths
        return ["charm64.exe"]  # Assumes PyCharm toolbox CLI in PATH
    return ["pycharm"]  # Linux/Unix

def copy_idea_template(target_dir):
    """Copy .idea-template/ to worktree .idea/ with placeholder replacement"""
    if not IDEA_TEMPLATE.exists():
        print("[warn] .idea-template/ missing; skipping IDE config")
        return

    idea_dir = target_dir / ".idea"
    idea_dir.mkdir(exist_ok=True)

    for src in IDEA_TEMPLATE.rglob("*"):
        if src.is_dir():
            continue

        rel = src.relative_to(IDEA_TEMPLATE)
        dest = idea_dir / rel
        dest.parent.mkdir(parents=True, exist_ok=True)

        # Read template, replace placeholders, write to destination
        text = src.read_text(encoding="utf-8")
        text = text.replace("${WORKTREE_ROOT}", str(target_dir))
        text = text.replace("${WORKTREE_NAME}", target_dir.name)
        dest.write_text(text, encoding="utf-8")

    print(f"[info] Copied .idea config from template")

def create_worktree(name, base_branch):
    """Create a new git worktree with isolated venv and PyCharm config"""
    # Ensure parent directory exists
    WORKTREE_PARENT.mkdir(exist_ok=True)
    target = WORKTREE_PARENT / name

    # Check for conflicts
    if target.exists():
        raise SystemExit(f"❌ Worktree {name} already exists: {target}")

    # Create git worktree
    print(f"\n📁 Creating worktree: {name}")
    run(["git", "worktree", "add", str(target), "-b", name, base_branch], cwd=REPO_ROOT)

    # Create isolated venv
    print(f"\n🐍 Creating virtual environment")
    run(["uv", "venv"], cwd=target)

    # Optional: Install dependencies
    pyproject = target / "pyproject.toml"
    if pyproject.exists():
        print(f"\n📦 Installing dependencies")
        run(["uv", "sync"], cwd=target)

    # Copy IDE config
    copy_idea_template(target)

    # Success message
    launcher = detect_pycharm_launcher()
    print("\n✅ Worktree ready!")
    print(f"   Location: {target}")
    print(f"   Venv: {target / '.venv'}")
    print(f"   IDE: {target / '.idea'}")
    print(f"\n🚀 Open in PyCharm:")
    print(f"   {' '.join(launcher + [str(target)])}")

def delete_worktree(name, keep_venv=False):
    """Remove a git worktree and optionally its venv"""
    target = WORKTREE_PARENT / name

    if not target.exists():
        raise SystemExit(f"❌ Worktree not found: {target}")

    print(f"\n🗑️  Removing worktree: {name}")

    # Remove from git
    try:
        run(["git", "worktree", "remove", str(target)], cwd=REPO_ROOT)
    except subprocess.CalledProcessError:
        print("[warn] Git worktree remove failed; forcing directory removal")

    # Remove venv if requested
    if not keep_venv:
        venv_path = target / ".venv"
        if venv_path.exists():
            print(f"[info] Removing venv: {venv_path}")
            shutil.rmtree(venv_path, ignore_errors=True)

    # Remove entire worktree directory
    if target.exists():
        print(f"[info] Removing directory: {target}")
        shutil.rmtree(target, ignore_errors=True)

    print(f"\n✅ Cleaned worktree {name}")
    print(f"\n💡 To delete the git branch:")
    print(f"   git branch -d {name}")

def main():
    parser = argparse.ArgumentParser(
        description="Manage git worktrees with isolated venvs and PyCharm config"
    )
    sub = parser.add_subparsers(dest="cmd", required=True)

    # Create command
    create = sub.add_parser("create", help="Add a new feature worktree")
    create.add_argument("name", help="Worktree/branch name")
    create.add_argument("--base", default="main", help="Base branch (default: main)")

    # Delete command
    delete = sub.add_parser("delete", help="Remove a feature worktree")
    delete.add_argument("name", help="Worktree name to delete")
    delete.add_argument("--keep-venv", action="store_true", help="Keep virtual environment")

    args = parser.parse_args()

    if args.cmd == "create":
        create_worktree(args.name, args.base)
    elif args.cmd == "delete":
        delete_worktree(args.name, args.keep_venv)

if __name__ == "__main__":
    try:
        main()
    except subprocess.CalledProcessError as exc:
        print(f"\n❌ Command failed with exit code {exc.returncode}", file=sys.stderr)
        sys.exit(exc.returncode)
    except KeyboardInterrupt:
        print("\n\n⚠️  Interrupted by user", file=sys.stderr)
        sys.exit(130)
