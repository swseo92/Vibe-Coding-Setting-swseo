#!/bin/bash
# review-functionality.sh - Review skill scripts functionality
#
# Usage: ./review-functionality.sh <skill-path>
#
# Example:
#   ./review-functionality.sh ~/.claude/skills/my-skill

set -e
set -o pipefail

if [ -z "$1" ]; then
    echo "Usage: $0 <skill-path>"
    exit 1
fi

SKILL_PATH="$1"
SKILL_NAME=$(basename "$SKILL_PATH")
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ ! -d "$SKILL_PATH/scripts" ]; then
    echo "No scripts directory found in $SKILL_PATH"
    echo "Skipping functionality review."
    exit 0
fi

echo "Reviewing skill: $SKILL_NAME"
echo "Skill path: $SKILL_PATH"
echo "Review type: Functionality"
echo ""

# Prepare template variables
REVIEW_DATE=$(date +%Y-%m-%d)

# Build script list (including subdirectories)
SCRIPT_LIST=""
if [ -d "$SKILL_PATH/scripts" ]; then
    while IFS= read -r script; do
        if [ -f "$script" ]; then
            relative_path=$(echo "$script" | sed "s|$SKILL_PATH/scripts/||")
            SCRIPT_LIST="${SCRIPT_LIST}- ${relative_path}\n"
        fi
    done < <(find "$SKILL_PATH/scripts" -type f 2>/dev/null)
fi

if [ -z "$SCRIPT_LIST" ]; then
    SCRIPT_LIST="- No scripts found"
fi

# Build prompt: template + all scripts
{
    # Output template with substitutions (using awk for safe special character handling)
    awk -v skill="$SKILL_NAME" \
        -v date="$REVIEW_DATE" \
        -v scripts="$SCRIPT_LIST" \
        '{
            gsub(/{SKILL_NAME}/, skill);
            gsub(/{DATE}/, date);
            gsub(/\{SCRIPT_LIST\}/, scripts);
            print
        }' "$SKILL_DIR/references/functionality-prompt.md"

    echo ""
    echo "# Scripts Being Reviewed"
    echo ""

    # Add each script (including subdirectories)
    if [ -d "$SKILL_PATH/scripts" ]; then
        find "$SKILL_PATH/scripts" -type f 2>/dev/null | while IFS= read -r script; do
            if [ -f "$script" ]; then
                relative_path=$(echo "$script" | sed "s|$SKILL_PATH/scripts/||")
                echo ""
                echo "## Script: $relative_path"
                echo ""
                echo '```bash'
                cat "$script"
                echo '```'
            fi
        done
    fi
} | codex exec --skip-git-repo-check

echo ""
echo "Review complete!"
