#!/usr/bin/env python3
"""
Agent validation script for Claude Code.

Validates agent markdown files for proper structure, YAML frontmatter, and best practices.
"""

import argparse
import re
import sys
from pathlib import Path
from typing import List, Tuple, Optional
import yaml


class AgentValidator:
    """Validates Claude Code agent files."""

    def __init__(self, file_path: Path):
        self.file_path = file_path
        self.content = ""
        self.frontmatter = {}
        self.errors: List[str] = []
        self.warnings: List[str] = []

    def validate(self) -> bool:
        """Run all validation checks."""
        print(f"Validating agent: {self.file_path}\n")

        # Read file
        if not self._read_file():
            return False

        # Parse frontmatter
        if not self._parse_frontmatter():
            return False

        # Run checks
        self._check_required_fields()
        self._check_name_format()
        self._check_description()
        self._check_tools()
        self._check_model()
        self._check_filename_match()
        self._check_system_prompt()
        self._check_best_practices()

        # Report results
        self._report_results()

        return len(self.errors) == 0

    def _read_file(self) -> bool:
        """Read agent file content."""
        try:
            self.content = self.file_path.read_text(encoding='utf-8')
            return True
        except Exception as e:
            self.errors.append(f"Failed to read file: {e}")
            return False

    def _parse_frontmatter(self) -> bool:
        """Parse YAML frontmatter."""
        # Extract frontmatter between --- markers
        match = re.match(r'^---\s*\n(.*?)\n---\s*\n', self.content, re.DOTALL)
        if not match:
            self.errors.append("No valid YAML frontmatter found (must start with ---)")
            return False

        yaml_content = match.group(1)

        try:
            # Try to parse as YAML first
            self.frontmatter = yaml.safe_load(yaml_content) or {}
            return True
        except yaml.YAMLError:
            # If YAML parsing fails, try simple key-value extraction
            # This handles cases where description has complex multiline content
            try:
                self.frontmatter = {}
                for line in yaml_content.split('\n'):
                    if ':' in line:
                        key, _, value = line.partition(':')
                        key = key.strip()
                        value = value.strip()
                        if key and value:
                            # Handle multiline values by concatenating
                            if key in self.frontmatter:
                                self.frontmatter[key] += ' ' + value
                            else:
                                self.frontmatter[key] = value

                # At minimum we need name and description
                if 'name' in self.frontmatter or 'description' in self.frontmatter:
                    self.warnings.append("YAML frontmatter has formatting issues but basic parsing succeeded")
                    return True
                else:
                    self.errors.append("Could not extract required fields from frontmatter")
                    return False
            except Exception as e:
                self.errors.append(f"Failed to parse frontmatter: {e}")
                return False

    def _check_required_fields(self):
        """Check for required frontmatter fields."""
        if 'name' not in self.frontmatter:
            self.errors.append("Missing required field: 'name'")

        if 'description' not in self.frontmatter:
            self.errors.append("Missing required field: 'description'")

    def _check_name_format(self):
        """Validate agent name format."""
        if 'name' not in self.frontmatter:
            return

        name = self.frontmatter['name']

        # Must be string
        if not isinstance(name, str):
            self.errors.append(f"Name must be a string, got: {type(name)}")
            return

        # Must be lowercase
        if name != name.lower():
            self.errors.append(f"Name must be lowercase: '{name}'")

        # No spaces allowed
        if ' ' in name:
            self.errors.append(f"Name cannot contain spaces (use hyphens): '{name}'")

        # Only alphanumeric and hyphens
        if not re.match(r'^[a-z0-9-]+$', name):
            self.errors.append(f"Name can only contain lowercase letters, numbers, and hyphens: '{name}'")

        # Should use hyphens for multi-word names
        if '_' in name:
            self.warnings.append(f"Name uses underscores; hyphens are preferred: '{name}'")

    def _check_description(self):
        """Validate description field."""
        if 'description' not in self.frontmatter:
            return

        description = self.frontmatter['description']

        # Must be string
        if not isinstance(description, str):
            self.errors.append(f"Description must be a string, got: {type(description)}")
            return

        # Should have reasonable length
        if len(description) < 20:
            self.warnings.append(f"Description is very short ({len(description)} chars); consider adding more detail")

        # Should contain usage guidance
        if 'use this agent' not in description.lower() and 'use when' not in description.lower():
            self.warnings.append("Description should explain when to use this agent")

        # Should contain examples
        if '<example>' not in description:
            self.warnings.append("Description should include usage examples")

    def _check_tools(self):
        """Validate tools field if present."""
        if 'tools' not in self.frontmatter:
            self.warnings.append("No tools specified; agent will inherit all tools (consider restricting)")
            return

        tools = self.frontmatter['tools']

        # Can be string (comma-separated) or list
        if isinstance(tools, str):
            tool_list = [t.strip() for t in tools.split(',')]
        elif isinstance(tools, list):
            tool_list = tools
        else:
            self.errors.append(f"Tools must be string or list, got: {type(tools)}")
            return

        # Known tools
        known_tools = {
            'Read', 'Write', 'Edit', 'Bash', 'Grep', 'Glob',
            'WebFetch', 'WebSearch', 'Task', 'TodoWrite',
            'NotebookEdit', 'AskUserQuestion'
        }

        # Check for unknown tools
        for tool in tool_list:
            if tool not in known_tools:
                self.warnings.append(f"Unknown tool: '{tool}' (may be valid but not recognized)")

        # Warn if too many tools
        if len(tool_list) > 6:
            self.warnings.append(f"Agent has {len(tool_list)} tools; consider restricting to only necessary ones")

    def _check_model(self):
        """Validate model field if present."""
        if 'model' not in self.frontmatter:
            return

        model = self.frontmatter['model']

        # Known models
        known_models = {'haiku', 'sonnet', 'opus', 'inherit'}

        if model not in known_models:
            self.warnings.append(f"Unknown model: '{model}' (expected: haiku, sonnet, opus, or inherit)")

    def _check_filename_match(self):
        """Check if filename matches agent name."""
        if 'name' not in self.frontmatter:
            return

        name = self.frontmatter['name']
        expected_filename = f"{name}.md"

        if self.file_path.name != expected_filename:
            self.errors.append(
                f"Filename '{self.file_path.name}' doesn't match agent name '{name}' "
                f"(expected: '{expected_filename}')"
            )

    def _check_system_prompt(self):
        """Validate system prompt content."""
        # Extract content after frontmatter
        match = re.match(r'^---\s*\n.*?\n---\s*\n(.+)', self.content, re.DOTALL)
        if not match:
            self.errors.append("No system prompt content found after frontmatter")
            return

        system_prompt = match.group(1)

        # Should have reasonable length
        if len(system_prompt) < 100:
            self.warnings.append(f"System prompt is very short ({len(system_prompt)} chars)")

        # Should have structure
        if '##' not in system_prompt:
            self.warnings.append("System prompt lacks section headers (consider using ## for structure)")

        # Common sections
        recommended_sections = [
            'Core Responsibilities',
            'Methodology',
            'Quality Criteria',
            'Output Format'
        ]

        missing_sections = []
        for section in recommended_sections:
            if section not in system_prompt:
                missing_sections.append(section)

        if missing_sections:
            self.warnings.append(
                f"System prompt missing recommended sections: {', '.join(missing_sections)}"
            )

    def _check_best_practices(self):
        """Check adherence to best practices."""
        # Single responsibility check
        if 'name' in self.frontmatter:
            name = self.frontmatter['name']
            if len(name.split('-')) > 4:
                self.warnings.append(
                    f"Agent name has many parts ({len(name.split('-'))}); "
                    "consider if agent is trying to do too much"
                )

        # Description examples check
        if 'description' in self.frontmatter:
            description = self.frontmatter['description']
            example_count = description.count('<example>')

            if example_count == 0:
                self.warnings.append("No usage examples in description")
            elif example_count < 2:
                self.warnings.append("Consider adding 2-3 usage examples to description")

    def _report_results(self):
        """Print validation results."""
        if self.errors:
            print("ERRORS:")
            for error in self.errors:
                print(f"   - {error}")
            print()

        if self.warnings:
            print("WARNINGS:")
            for warning in self.warnings:
                print(f"   - {warning}")
            print()

        if not self.errors and not self.warnings:
            print("Agent validation passed! No issues found.\n")
        elif not self.errors:
            print("Agent validation passed with warnings.\n")
        else:
            print("Agent validation failed.\n")


def main():
    parser = argparse.ArgumentParser(description="Validate Claude Code agent files")
    parser.add_argument("file", help="Path to agent markdown file")
    parser.add_argument("-v", "--verbose", action="store_true", help="Verbose output")

    args = parser.parse_args()

    file_path = Path(args.file)

    if not file_path.exists():
        print(f"ERROR: File not found: {file_path}")
        sys.exit(1)

    if not file_path.suffix == '.md':
        print(f"WARNING: File doesn't have .md extension: {file_path}")

    validator = AgentValidator(file_path)
    success = validator.validate()

    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
