#!/usr/bin/env python3
"""Render template by substituting ${{ variable }} tokens with values from state."""
import sys
import json
import re
import argparse

def get_nested_value(data, path):
    """Get value from nested dict using dot notation (e.g., 'steps.test.outputs.coverage')."""
    keys = path.split('.')
    value = data

    for key in keys:
        if isinstance(value, dict) and key in value:
            value = value[key]
        else:
            return None

    return value

def render_template(template, state):
    """Replace ${{ variable }} patterns with values from state."""
    # Pattern to match ${{ ... }}
    pattern = r'\$\{\{\s*([^}]+)\s*\}\}'

    def replacer(match):
        var_path = match.group(1).strip()
        value = get_nested_value(state, var_path)

        if value is None:
            # Keep original if not found
            return match.group(0)

        # Convert to string
        if isinstance(value, (dict, list)):
            return json.dumps(value)
        elif isinstance(value, bool):
            return str(value).lower()
        else:
            return str(value)

    return re.sub(pattern, replacer, template)

def main():
    parser = argparse.ArgumentParser(description='Render template with variable substitution')
    parser.add_argument('--template', required=True, help='Template string with ${{ ... }} tokens')
    parser.add_argument('--state', required=True, help='Path to state JSON file')

    args = parser.parse_args()

    try:
        # Load state
        with open(args.state, 'r', encoding='utf-8') as f:
            state = json.load(f)

        # Render template
        result = render_template(args.template, state)

        # Output result
        print(result)
        sys.exit(0)

    except FileNotFoundError:
        print(f"Error: State file not found: {args.state}", file=sys.stderr)
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON in state file: {str(e)}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error: {str(e)}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
