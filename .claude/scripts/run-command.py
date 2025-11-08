#!/usr/bin/env python3
"""
Claude Code Command Runner
Universal wrapper for executing Claude slash commands or skills from automation scripts.

Usage:
    python run-command.py "/pre-commit-full"
    python run-command.py "/speckit.analyze"
    python run-command.py --skill "pre-commit-code-reviewer"
"""

import sys
import subprocess
import argparse
from pathlib import Path


def run_claude_command(command: str, verbose: bool = False) -> int:
    """
    Execute a Claude Code slash command using claude --print.

    Args:
        command: Slash command to execute (e.g., "/pre-commit-full")
        verbose: Print detailed output

    Returns:
        Exit code (0 for success, non-zero for failure)
    """
    if verbose:
        print(f"Executing Claude command: {command}")

    try:
        result = subprocess.run(
            ["claude", "--print", command],
            capture_output=not verbose,
            text=True,
            check=False
        )

        if verbose or result.returncode != 0:
            if result.stdout:
                print(result.stdout)
            if result.stderr:
                print(result.stderr, file=sys.stderr)

        return result.returncode

    except FileNotFoundError:
        print("Error: 'claude' command not found", file=sys.stderr)
        print("Please ensure Claude Code CLI is installed", file=sys.stderr)
        return 127
    except Exception as e:
        print(f"Error executing command: {e}", file=sys.stderr)
        return 1


def main():
    parser = argparse.ArgumentParser(
        description="Run Claude Code commands from automation scripts"
    )
    parser.add_argument(
        "command",
        help="Claude slash command to execute (e.g., '/pre-commit-full')"
    )
    parser.add_argument(
        "-v", "--verbose",
        action="store_true",
        help="Print detailed output"
    )
    parser.add_argument(
        "--skill",
        action="store_true",
        help="Execute as a skill (not implemented yet)"
    )

    args = parser.parse_args()

    if args.skill:
        print("Error: Direct skill execution not yet supported", file=sys.stderr)
        print("Please use a slash command that invokes the skill", file=sys.stderr)
        return 1

    # Ensure command starts with /
    command = args.command
    if not command.startswith("/"):
        command = f"/{command}"

    return run_claude_command(command, args.verbose)


if __name__ == "__main__":
    sys.exit(main())
