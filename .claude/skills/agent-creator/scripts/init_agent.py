#!/usr/bin/env python3
"""
Agent initialization script for Claude Code.

Creates a new agent file with boilerplate structure based on user input.
"""

import argparse
import sys
from pathlib import Path
from typing import Optional


AGENT_TEMPLATE = '''---
name: {name}
description: {description}
{tools_line}{model_line}{color_line}---

You are {role_description}.

## Core Responsibilities

1. **{responsibility_1}**: {detail_1}

2. **{responsibility_2}**: {detail_2}

3. **{responsibility_3}**: {detail_3}

## Methodology

### Step 1: {step_1_name}
{step_1_detail}

### Step 2: {step_2_name}
{step_2_detail}

### Step 3: {step_3_name}
{step_3_detail}

## Quality Criteria

- **{criterion_1}**: {criterion_1_detail}
- **{criterion_2}**: {criterion_2_detail}
- **{criterion_3}**: {criterion_3_detail}

## Output Format

Provide your results in the following structure:

1. **{output_section_1}**: {output_description_1}
2. **{output_section_2}**: {output_description_2}
3. **{output_section_3}**: {output_description_3}

## Special Considerations

- {consideration_1}
- {consideration_2}
- {consideration_3}

Your goal is to {goal_statement}.
'''


def validate_agent_name(name: str) -> bool:
    """Validate agent name follows conventions."""
    if not name:
        return False
    if name != name.lower():
        return False
    if ' ' in name:
        return False
    if not all(c.isalnum() or c == '-' for c in name):
        return False
    return True


def create_agent_file(
    name: str,
    description: str,
    output_path: Path,
    tools: Optional[str] = None,
    model: Optional[str] = None,
    color: Optional[str] = None,
    interactive: bool = False
) -> bool:
    """Create agent markdown file with boilerplate."""

    # Validate name
    if not validate_agent_name(name):
        print(f"ERROR: Invalid agent name: '{name}'")
        print("   Agent names must be lowercase with hyphens only (e.g., 'my-agent')")
        return False

    # Prepare YAML frontmatter
    tools_line = f"tools: {tools}\n" if tools else ""
    model_line = f"model: {model}\n" if model else ""
    color_line = f"color: {color}\n" if color else ""

    # Interactive mode: gather details
    if interactive:
        print(f"\nCreating agent: {name}\n")

        # Get role description
        role_description = input("What is this agent's role? (e.g., 'an expert Python test engineer')\n> ").strip()
        if not role_description:
            role_description = "a specialized assistant"

        # Get responsibilities
        print("\nDefine 3 core responsibilities:")
        responsibility_1 = input("1. ").strip() or "Primary task"
        detail_1 = input("   Detail: ").strip() or "Describe the task"

        responsibility_2 = input("2. ").strip() or "Secondary task"
        detail_2 = input("   Detail: ").strip() or "Describe the task"

        responsibility_3 = input("3. ").strip() or "Tertiary task"
        detail_3 = input("   Detail: ").strip() or "Describe the task"

        # Get methodology steps
        print("\nDefine 3 methodology steps:")
        step_1_name = input("Step 1 name: ").strip() or "Preparation"
        step_1_detail = input("Step 1 detail: ").strip() or "Prepare for the task"

        step_2_name = input("Step 2 name: ").strip() or "Execution"
        step_2_detail = input("Step 2 detail: ").strip() or "Execute the task"

        step_3_name = input("Step 3 name: ").strip() or "Validation"
        step_3_detail = input("Step 3 detail: ").strip() or "Validate the results"

        # Get quality criteria
        print("\nDefine 3 quality criteria:")
        criterion_1 = input("1. ").strip() or "Correctness"
        criterion_1_detail = input("   Detail: ").strip() or "Output must be correct"

        criterion_2 = input("2. ").strip() or "Completeness"
        criterion_2_detail = input("   Detail: ").strip() or "Output must be complete"

        criterion_3 = input("3. ").strip() or "Clarity"
        criterion_3_detail = input("   Detail: ").strip() or "Output must be clear"

        # Get output format
        print("\nDefine 3 output sections:")
        output_section_1 = input("1. ").strip() or "Summary"
        output_description_1 = input("   Description: ").strip() or "Brief overview"

        output_section_2 = input("2. ").strip() or "Details"
        output_description_2 = input("   Description: ").strip() or "Detailed information"

        output_section_3 = input("3. ").strip() or "Recommendations"
        output_description_3 = input("   Description: ").strip() or "Suggestions"

        # Get special considerations
        print("\nDefine 3 special considerations:")
        consideration_1 = input("1. ").strip() or "Consider edge cases"
        consideration_2 = input("2. ").strip() or "Handle errors gracefully"
        consideration_3 = input("3. ").strip() or "Document assumptions"

        # Get goal statement
        goal_statement = input("\nWhat is the agent's goal?\n> ").strip()
        if not goal_statement:
            goal_statement = "accomplish the task effectively and efficiently"

    else:
        # Default placeholders
        role_description = "a specialized assistant"
        responsibility_1 = "Analyze Input"
        detail_1 = "Understand what needs to be done"
        responsibility_2 = "Execute Task"
        detail_2 = "Perform the primary function"
        responsibility_3 = "Validate Output"
        detail_3 = "Ensure quality and correctness"

        step_1_name = "Preparation"
        step_1_detail = "Gather necessary information and context"
        step_2_name = "Execution"
        step_2_detail = "Perform the core task"
        step_3_name = "Validation"
        step_3_detail = "Verify results meet quality standards"

        criterion_1 = "Correctness"
        criterion_1_detail = "Output must be accurate and error-free"
        criterion_2 = "Completeness"
        criterion_2_detail = "All requirements must be addressed"
        criterion_3 = "Clarity"
        criterion_3_detail = "Results must be clear and understandable"

        output_section_1 = "Summary"
        output_description_1 = "Brief overview of results"
        output_section_2 = "Details"
        output_description_2 = "Comprehensive breakdown"
        output_section_3 = "Recommendations"
        output_description_3 = "Suggestions for next steps"

        consideration_1 = "Handle edge cases appropriately"
        consideration_2 = "Provide clear error messages when issues arise"
        consideration_3 = "Document any assumptions or limitations"

        goal_statement = "accomplish the task effectively while maintaining high quality standards"

    # Generate content
    content = AGENT_TEMPLATE.format(
        name=name,
        description=description,
        tools_line=tools_line,
        model_line=model_line,
        color_line=color_line,
        role_description=role_description,
        responsibility_1=responsibility_1,
        detail_1=detail_1,
        responsibility_2=responsibility_2,
        detail_2=detail_2,
        responsibility_3=responsibility_3,
        detail_3=detail_3,
        step_1_name=step_1_name,
        step_1_detail=step_1_detail,
        step_2_name=step_2_name,
        step_2_detail=step_2_detail,
        step_3_name=step_3_name,
        step_3_detail=step_3_detail,
        criterion_1=criterion_1,
        criterion_1_detail=criterion_1_detail,
        criterion_2=criterion_2,
        criterion_2_detail=criterion_2_detail,
        criterion_3=criterion_3,
        criterion_3_detail=criterion_3_detail,
        output_section_1=output_section_1,
        output_description_1=output_description_1,
        output_section_2=output_section_2,
        output_description_2=output_description_2,
        output_section_3=output_section_3,
        output_description_3=output_description_3,
        consideration_1=consideration_1,
        consideration_2=consideration_2,
        consideration_3=consideration_3,
        goal_statement=goal_statement
    )

    # Write file
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(content, encoding='utf-8')

    print(f"\nAgent created: {output_path}")
    print(f"\nNext steps:")
    print(f"   1. Edit {output_path} to customize the agent")
    print(f"   2. Validate with: python scripts/validate_agent.py {output_path}")
    print(f"   3. Test by using the agent in a Claude Code session")

    return True


def main():
    parser = argparse.ArgumentParser(description="Initialize a new Claude Code agent")
    parser.add_argument("name", help="Agent name (lowercase with hyphens)")
    parser.add_argument("description", help="Agent description (when to use it)")
    parser.add_argument("-o", "--output", help="Output path (default: .claude/agents/NAME.md)")
    parser.add_argument("-t", "--tools", help="Comma-separated tool list (e.g., 'Read, Write, Edit')")
    parser.add_argument("-m", "--model", choices=["haiku", "sonnet"], help="Model to use")
    parser.add_argument("-c", "--color", help="Agent color (e.g., 'blue', 'green', 'purple')")
    parser.add_argument("-i", "--interactive", action="store_true", help="Interactive mode")

    args = parser.parse_args()

    # Determine output path
    if args.output:
        output_path = Path(args.output)
    else:
        output_path = Path(f".claude/agents/{args.name}.md")

    # Create agent
    success = create_agent_file(
        name=args.name,
        description=args.description,
        output_path=output_path,
        tools=args.tools,
        model=args.model,
        color=args.color,
        interactive=args.interactive
    )

    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
