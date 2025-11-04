#!/usr/bin/env python3
"""
Parse Markdown sections and extract H2/H3 headers with metadata.

Usage:
    python parse_markdown_sections.py <markdown-file>

Output:
    JSON with section metadata
"""

import sys
import json
import re
from pathlib import Path

def parse_yaml_frontmatter(content):
    """Extract YAML frontmatter if present."""
    frontmatter_pattern = r'^---\s*\n(.*?)\n---\s*\n'
    match = re.match(frontmatter_pattern, content, re.DOTALL)

    if match:
        yaml_content = match.group(1)
        remaining_content = content[match.end():]
        return yaml_content, remaining_content
    return None, content

def parse_sections(content):
    """Parse Markdown content and extract H2/H3 sections."""
    sections = []
    lines = content.split('\n')

    current_section = None
    current_content = []

    for line_num, line in enumerate(lines, 1):
        # Match H1-H3 headers
        header_match = re.match(r'^(#{1,3})\s+(.+)$', line)

        if header_match:
            # Save previous section
            if current_section:
                current_section['content'] = '\n'.join(current_content).strip()
                current_section['line_end'] = line_num - 1
                sections.append(current_section)

            # Start new section
            level = len(header_match.group(1))
            name = header_match.group(2).strip()

            # Normalize level (if #### without ###, treat as H3)
            if level > 3:
                level = 3

            current_section = {
                'name': name,
                'level': level,
                'line_start': line_num,
                'content': ''
            }
            current_content = []
        else:
            # Accumulate content
            if current_section:
                current_content.append(line)

    # Save last section
    if current_section:
        current_section['content'] = '\n'.join(current_content).strip()
        current_section['line_end'] = len(lines)
        sections.append(current_section)

    return sections

def main():
    # Set UTF-8 output for Windows compatibility
    if sys.platform == 'win32':
        import codecs
        sys.stdout = codecs.getwriter('utf-8')(sys.stdout.buffer, 'strict')
        sys.stderr = codecs.getwriter('utf-8')(sys.stderr.buffer, 'strict')

    if len(sys.argv) < 2:
        print("Usage: python parse_markdown_sections.py <markdown-file>", file=sys.stderr)
        sys.exit(1)

    markdown_file = Path(sys.argv[1])

    if not markdown_file.exists():
        print(f"Error: File not found: {markdown_file}", file=sys.stderr)
        sys.exit(1)

    content = markdown_file.read_text(encoding='utf-8')

    # Parse frontmatter
    frontmatter, body = parse_yaml_frontmatter(content)

    # Parse sections
    sections = parse_sections(body)

    # Build output
    output = {
        'file': str(markdown_file),
        'frontmatter': frontmatter,
        'sections': sections
    }

    # Output JSON
    print(json.dumps(output, indent=2, ensure_ascii=False))

if __name__ == '__main__':
    main()
