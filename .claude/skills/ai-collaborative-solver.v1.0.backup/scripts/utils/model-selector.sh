#!/usr/bin/env bash

# Auto Model Selector
# Analyzes problem description and selects best AI model

set -euo pipefail

PROBLEM="${1:-}"

if [[ -z "$PROBLEM" ]]; then
    echo "Error: Problem description required" >&2
    exit 1
fi

# Convert to lowercase for matching
PROBLEM_LOWER=$(echo "$PROBLEM" | tr '[:upper:]' '[:lower:]')

# Rule-based selection (order matters - first match wins)

# Pattern: Code review, bugs, code analysis
if echo "$PROBLEM_LOWER" | grep -qE "코드|code|리뷰|review|버그|bug|리팩토링|refactor|테스트|test"; then
    echo "codex"
    exit 0
fi

# Pattern: Latest trends, current year, 2025
if echo "$PROBLEM_LOWER" | grep -qE "2025|2024|최신|latest|트렌드|trend|현재|current|newest|recent"; then
    echo "gemini"
    exit 0
fi

# Pattern: Search, research, find
if echo "$PROBLEM_LOWER" | grep -qE "검색|search|조사|research|찾기|find|알아보|investigate"; then
    echo "gemini"
    exit 0
fi

# Pattern: vs, compare, choose
if echo "$PROBLEM_LOWER" | grep -qE " vs | or |비교|compare|선택|choose|어느|which"; then
    # If involves code/architecture -> prefer codex
    if echo "$PROBLEM_LOWER" | grep -qE "아키텍처|architecture|설계|design|구현|implement"; then
        echo "codex"
    else
        # General comparison -> gemini (can use search)
        echo "gemini"
    fi
    exit 0
fi

# Pattern: Architecture, design (deep analysis)
if echo "$PROBLEM_LOWER" | grep -qE "아키텍처|architecture|설계|design|시스템|system|구조|structure"; then
    echo "codex"
    exit 0
fi

# Pattern: Security, vulnerability
if echo "$PROBLEM_LOWER" | grep -qE "보안|security|취약|vulnerab|공격|attack|해킹|hack"; then
    # Security research -> gemini
    if echo "$PROBLEM_LOWER" | grep -qE "조사|research|트렌드|trend|최신|latest"; then
        echo "gemini"
    else
        # Security code review -> codex
        echo "codex"
    fi
    exit 0
fi

# Pattern: Performance, optimization
if echo "$PROBLEM_LOWER" | grep -qE "성능|performance|최적화|optimiz|속도|speed|빠르|fast"; then
    echo "codex"
    exit 0
fi

# Pattern: Database, data model
if echo "$PROBLEM_LOWER" | grep -qE "데이터베이스|database|db|스키마|schema|쿼리|query|sql"; then
    echo "codex"
    exit 0
fi

# Pattern: API, endpoint
if echo "$PROBLEM_LOWER" | grep -qE "api|endpoint|rest|graphql|grpc"; then
    echo "codex"
    exit 0
fi

# Pattern: Framework, library (if recent year mentioned -> gemini, else codex)
if echo "$PROBLEM_LOWER" | grep -qE "프레임워크|framework|라이브러리|library|패키지|package"; then
    if echo "$PROBLEM_LOWER" | grep -qE "2025|2024|최신|latest"; then
        echo "gemini"
    else
        echo "codex"
    fi
    exit 0
fi

# Pattern: Best practice, pattern
if echo "$PROBLEM_LOWER" | grep -qE "best practice|베스트|패턴|pattern"; then
    # Recent best practices -> gemini (with search)
    if echo "$PROBLEM_LOWER" | grep -qE "2025|2024|최신|latest|현재|current"; then
        echo "gemini"
    else
        # General patterns -> codex
        echo "codex"
    fi
    exit 0
fi

# Default: If uncertain, prefer codex (more comprehensive)
echo "codex"
