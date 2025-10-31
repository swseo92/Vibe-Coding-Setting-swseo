#!/usr/bin/env python3
"""Parse YAML blueprint to JSON for reliable processing."""
import sys
import json
import yaml

def main():
    try:
        # Read YAML from stdin
        yaml_content = sys.stdin.read()

        # Parse YAML
        data = yaml.safe_load(yaml_content)

        if data is None:
            print(json.dumps({"error": "Empty YAML"}), file=sys.stderr)
            sys.exit(1)

        # Output JSON to stdout
        print(json.dumps(data, indent=2))
        sys.exit(0)

    except yaml.YAMLError as e:
        print(json.dumps({"error": f"YAML parse error: {str(e)}"}), file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(json.dumps({"error": f"Unexpected error: {str(e)}"}), file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
