#!/usr/bin/env bash

# Coverage Monitoring Script
# Checks debate responses against 8 key dimensions
# Usage: check-coverage.sh <response_text> <output_file>

set -euo pipefail

RESPONSE_TEXT="${1:-}"
OUTPUT_FILE="${2:-}"

if [[ -z "$RESPONSE_TEXT" ]]; then
    echo "Usage: $0 <response_text> [output_file]" >&2
    exit 1
fi

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$SKILL_DIR/config/coverage-dimensions.yaml"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: Coverage config not found: $CONFIG_FILE" >&2
    exit 1
fi

# Check if yq is available (for proper YAML parsing)
HAS_YQ=false
if command -v yq &> /dev/null; then
    HAS_YQ=true
fi

# Extract dimension names and keywords
declare -A DIMENSIONS
declare -A DIMENSION_KEYWORDS

if [[ "$HAS_YQ" == "true" ]]; then
    # Use yq for robust YAML parsing
    DIM_COUNT=$(yq '.dimensions | length' "$CONFIG_FILE")

    for ((i=0; i<DIM_COUNT; i++)); do
        name=$(yq ".dimensions[$i].name" "$CONFIG_FILE")
        keywords=$(yq ".dimensions[$i].keywords[]" "$CONFIG_FILE" | tr '\n' '|' | sed 's/|$//')

        DIMENSIONS["$name"]="$keywords"
        DIMENSION_KEYWORDS["$name"]="$keywords"
    done
else
    # Fallback to manual parsing (simple grep-based)
    echo "Warning: yq not found, using fallback parsing" >&2

    # Define dimensions manually
    DIMENSIONS["performance"]="performance|latency|throughput|scalability|speed|optimization|bottleneck"
    DIMENSIONS["security"]="security|authentication|authorization|encryption|vulnerability|attack|threat"
    DIMENSIONS["cost"]="cost|price|budget|expense|pricing|TCO|ROI|license"
    DIMENSIONS["operations"]="ops|operations|deployment|monitoring|maintenance|DevOps|observability"
    DIMENSIONS["team_capability"]="team|skill|expertise|learning curve|training|experience"
    DIMENSIONS["migration"]="migration|transition|upgrade|compatibility|legacy|integration"
    DIMENSIONS["edge_cases"]="edge case|corner case|failure mode|error handling|exception|fallback"
    DIMENSIONS["long_term"]="long term|sustainability|maintainability|extensibility|technical debt"
fi

# Check coverage
COVERED_COUNT=0
MISSING_COUNT=0
COVERAGE_REPORT=""

for dim in "${!DIMENSIONS[@]}"; do
    keywords="${DIMENSIONS[$dim]}"

    # Check if any keyword appears in response (case-insensitive)
    if echo "$RESPONSE_TEXT" | grep -qiE "$keywords"; then
        COVERED_COUNT=$((COVERED_COUNT + 1))
        COVERAGE_REPORT+="✅ $dim: COVERED
"
    else
        MISSING_COUNT=$((MISSING_COUNT + 1))
        COVERAGE_REPORT+="❌ $dim: MISSING
"
    fi
done

# Calculate coverage percentage
TOTAL_DIMS=${#DIMENSIONS[@]}
COVERAGE_PCT=$((COVERED_COUNT * 100 / TOTAL_DIMS))

# Generate summary
SUMMARY="Coverage Summary:
- Total Dimensions: $TOTAL_DIMS
- Covered: $COVERED_COUNT (${COVERAGE_PCT}%)
- Missing: $MISSING_COUNT

Detailed Coverage:
$COVERAGE_REPORT"

# Output
echo "$SUMMARY"

# Save to file if specified
if [[ -n "$OUTPUT_FILE" ]]; then
    echo "$SUMMARY" > "$OUTPUT_FILE"
    echo ""
    echo "Coverage report saved to: $OUTPUT_FILE"
fi

# Return missing dimensions list (for facilitator to use)
echo ""
echo "Missing Dimensions:"
echo "$COVERAGE_REPORT" | grep "❌" | cut -d: -f1 | sed 's/❌ //'

# Exit with status based on minimum threshold (5/8 dimensions)
if [[ $COVERED_COUNT -ge 5 ]]; then
    exit 0  # Adequate coverage
else
    exit 1  # Insufficient coverage
fi
