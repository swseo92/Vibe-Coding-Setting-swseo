#!/usr/bin/env bash

# Auto Model Selector V2 (Registry-Based)
# Uses capability registry for intelligent model selection

set -euo pipefail

PROBLEM="${1:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
REGISTRY="$SKILL_DIR/config/registry.yaml"

if [[ -z "$PROBLEM" ]]; then
    echo "Error: Problem description required" >&2
    exit 1
fi

# Convert to lowercase for matching
PROBLEM_LOWER=$(echo "$PROBLEM" | tr '[:upper:]' '[:lower:]')

# Function to extract selection rules from registry
get_selection_rules() {
    # Extract selection rules from YAML (basic parsing)
    grep -A 5 "pattern:" "$REGISTRY" | grep -v "^--$"
}

# Try to match against registry rules
SELECTED_MODEL=""

# Rule 1: Code analysis
if echo "$PROBLEM_LOWER" | grep -qE "code|코드|리뷰|review|bug|버그|refactor|리팩토링|test|테스트"; then
    SELECTED_MODEL="codex"
    REASON="Code analysis requires deep technical understanding"
fi

# Rule 2: Current information (only if explicitly searching)
# NOTE: Default to codex unless search is explicitly needed
if echo "$PROBLEM_LOWER" | grep -qE "search|검색|find|찾아|research|조사"; then
    if echo "$PROBLEM_LOWER" | grep -qE "2025|2024|latest|최신|trend|트렌드|current|현재"; then
        SELECTED_MODEL="gemini"
        REASON="Explicit search for current information"
    fi
fi

# Rule 3: Architecture (always codex)
if echo "$PROBLEM_LOWER" | grep -qE "architecture|아키텍처|design|설계|system|시스템|structure|구조"; then
    SELECTED_MODEL="codex"
    REASON="Architecture requires deep technical reasoning"
fi

# Rule 4: Comparison (always codex for technical decisions)
if echo "$PROBLEM_LOWER" | grep -qE " vs | or |versus|비교|compare|선택|choose|어느|which"; then
    SELECTED_MODEL="codex"
    REASON="Technical comparison requires code expertise"
fi

# Rule 5: Security (always codex)
if echo "$PROBLEM_LOWER" | grep -qE "security|보안|vulnerability|취약|attack|공격|hack|해킹"; then
    SELECTED_MODEL="codex"
    REASON="Security code analysis requires precise expertise"
fi

# Rule 6: Performance (always codex)
if echo "$PROBLEM_LOWER" | grep -qE "performance|성능|optimize|최적화|speed|속도|fast|빠르|slow|느리"; then
    SELECTED_MODEL="codex"
    REASON="Performance optimization requires code expertise"
fi

# Rule 7: Database/Data (always codex)
if echo "$PROBLEM_LOWER" | grep -qE "database|db|데이터베이스|schema|스키마|query|쿼리|sql|nosql"; then
    SELECTED_MODEL="codex"
    REASON="Database design requires technical precision"
fi

# Rule 8: API (always codex)
if echo "$PROBLEM_LOWER" | grep -qE "api|endpoint|rest|graphql|grpc"; then
    SELECTED_MODEL="codex"
    REASON="API design requires technical expertise"
fi

# Rule 9: Framework/Library (always codex)
if echo "$PROBLEM_LOWER" | grep -qE "framework|프레임워크|library|라이브러리|package|패키지"; then
    SELECTED_MODEL="codex"
    REASON="Framework expertise requires technical depth"
fi

# Rule 10: Best practices/patterns (always codex)
if echo "$PROBLEM_LOWER" | grep -qE "best practice|베스트|pattern|패턴|convention|컨벤션"; then
    SELECTED_MODEL="codex"
    REASON="Established patterns require technical depth"
fi

# Rule 11: Writing/Documentation (use Claude only for pure writing tasks)
# NOTE: Most technical writing should use codex
if echo "$PROBLEM_LOWER" | grep -qE "write.*document|작성.*문서|explain.*concept|설명.*개념"; then
    # Only for non-technical writing
    if ! echo "$PROBLEM_LOWER" | grep -qE "code|코드|api|technical|기술"; then
        if command -v claude &> /dev/null; then
            SELECTED_MODEL="claude"
            REASON="Pure writing task - Claude excels at non-technical writing"
        fi
    fi
fi

# Rule 12: Technical analysis (always codex)
# NOTE: Codex is default for all analysis tasks
if echo "$PROBLEM_LOWER" | grep -qE "reason|추론|analyze|분석|think|생각|logic|논리"; then
    SELECTED_MODEL="codex"
    REASON="Codex good for technical analysis"
fi

# Default: If uncertain, prefer Codex (most comprehensive)
if [[ -z "$SELECTED_MODEL" ]]; then
    SELECTED_MODEL="codex"
    REASON="Default: Codex provides comprehensive technical capability"
fi

# Output selected model
echo "$SELECTED_MODEL"

# Log reason to stderr (optional, for debugging)
# echo "Reason: $REASON" >&2
