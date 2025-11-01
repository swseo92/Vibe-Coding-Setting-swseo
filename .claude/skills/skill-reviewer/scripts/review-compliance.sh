#!/bin/bash
# review-compliance.sh - Review skill compliance with skill-creator guidelines
#
# Usage: ./review-compliance.sh <skill-path>
#
# Example:
#   ./review-compliance.sh ~/.claude/skills/my-skill

set -e
set -o pipefail

if [ -z "$1" ]; then
    echo "Usage: $0 <skill-path>"
    exit 1
fi

SKILL_PATH="$1"
SKILL_NAME=$(basename "$SKILL_PATH")
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ ! -f "$SKILL_PATH/SKILL.md" ]; then
    echo "Error: SKILL.md not found in $SKILL_PATH"
    exit 1
fi

echo "Reviewing skill: $SKILL_NAME"
echo "Skill path: $SKILL_PATH"
echo "Review type: Compliance"
echo ""

# Prepare template variables
REVIEW_DATE=$(date +%Y-%m-%d)
SKILL_MD="$SKILL_PATH/SKILL.md"

# Calculate word count (approximate)
if [ -f "$SKILL_MD" ]; then
    WORD_COUNT=$(wc -w < "$SKILL_MD" 2>/dev/null || echo "unknown")
else
    WORD_COUNT="unknown"
fi

# Extract description from YAML frontmatter
DESCRIPTION=$(sed -n 's/^description:[[:space:]]*//p' "$SKILL_MD" 2>/dev/null || echo "No description found")

# Build prompt with variable substitution
{
    # Output template with substitutions (using awk for safe special character handling)
    awk -v skill="$SKILL_NAME" \
        -v path="$SKILL_PATH" \
        -v date="$REVIEW_DATE" \
        -v words="$WORD_COUNT" \
        -v desc="$DESCRIPTION" \
        '{
            gsub(/{SKILL_NAME}/, skill);
            gsub(/\{SKILL_PATH\}/, path);
            gsub(/{DATE}/, date);
            gsub(/{WORD_COUNT}/, words);
            gsub(/{DESCRIPTION}/, desc);
            print
        }' "$SKILL_DIR/references/compliance-prompt.md"

    echo ""
    echo "# skill-creator SKILL.md Reference"
    echo ""
    cat ~/.claude/skills/skill-creator/SKILL.md

    echo ""
    echo "# $SKILL_NAME SKILL.md Being Reviewed"
    echo ""
    cat "$SKILL_MD"
} | codex exec --skip-git-repo-check

echo ""
echo "Review complete!"
