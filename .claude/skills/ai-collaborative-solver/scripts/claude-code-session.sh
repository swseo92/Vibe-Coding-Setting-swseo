#!/usr/bin/env bash
# claude-code-session.sh
# Generalized Claude Code stateful session management
#
# Usage:
#   claude-code-session.sh new "prompt" [options]
#   claude-code-session.sh continue <session-id> "prompt"
#   claude-code-session.sh info <session-id>
#   claude-code-session.sh list

set -euo pipefail

VERSION="1.0.0"
SESSIONS_DIR="${CLAUDE_CODE_SESSIONS_DIR:-.claude-code-sessions}"

# =============================================================
# Configuration
# =============================================================

DEFAULT_OUTPUT_FORMAT="text"
DEFAULT_MODEL=""  # Empty = use Claude Code default

# =============================================================
# Helper Functions
# =============================================================

log_info() {
    [[ "${QUIET:-false}" == "true" ]] || echo "[INFO] $*" >&2
}

log_error() {
    echo "[ERROR] $*" >&2
}

debug() {
    if [[ "${DEBUG:-false}" == "true" ]]; then
        echo "[DEBUG] $*" >&2
    fi
}

generate_session_id() {
    # UUID 생성 (Linux/Mac/Windows Git Bash 호환)
    if command -v uuidgen &>/dev/null; then
        uuidgen | tr '[:upper:]' '[:lower:]'
    elif [[ -f /proc/sys/kernel/random/uuid ]]; then
        cat /proc/sys/kernel/random/uuid
    else
        python3 -c 'import uuid; print(uuid.uuid4())' 2>/dev/null || \
        python -c 'import uuid; print(uuid.uuid4())'
    fi
}

save_session_metadata() {
    local session_id="$1"
    local session_dir="$2"

    cat > "$session_dir/metadata.json" <<EOF
{
  "session_id": "$session_id",
  "created_at": "$(date +%Y-%m-%d\ %H:%M:%S)",
  "round_count": ${ROUND_COUNT:-0},
  "status": "${STATUS:-active}"
}
EOF
}

load_metadata() {
    local session_id="$1"
    local session_dir="$SESSIONS_DIR/$session_id"

    if [[ ! -f "$session_dir/metadata.json" ]]; then
        log_error "Metadata not found for session: $session_id"
        exit 1
    fi

    # Use python for JSON parsing (cross-platform)
    # Try python3 first, fallback to python
    local result=""
    if command -v python3 &>/dev/null; then
        result=$(python3 -c "import json; data=json.load(open('$session_dir/metadata.json')); print(data.get('round_count', 0))" 2>/dev/null || echo "")
    fi

    if [[ -z "$result" ]] && command -v python &>/dev/null; then
        result=$(python -c "import json; data=json.load(open('$session_dir/metadata.json')); print(data.get('round_count', 0))" 2>/dev/null || echo "")
    fi

    if [[ -z "$result" ]]; then
        log_error "Failed to parse metadata (python/python3 required)"
        exit 1
    fi

    echo "$result"
}

# =============================================================
# Core Commands
# =============================================================

cmd_new() {
    local prompt="$1"
    shift

    # Parse options
    local output_dir=""
    local output_format="$DEFAULT_OUTPUT_FORMAT"
    local model="$DEFAULT_MODEL"
    local stdout_only=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --output-dir) output_dir="$2"; shift 2 ;;
            --output-format) output_format="$2"; shift 2 ;;
            --model) model="$2"; shift 2 ;;
            --stdout-only) stdout_only=true; shift ;;
            --quiet) QUIET=true; shift ;;
            --debug) DEBUG=true; shift ;;
            *) log_error "Unknown option: $1"; exit 1 ;;
        esac
    done

    # Fast mode: no file creation, output only
    if [[ "$stdout_only" == "true" ]]; then
        debug "Fast mode: stdout-only (no files)"

        # Build command with optional model
        local cmd=(claude --print "$prompt" --output-format json)
        [[ -n "$model" ]] && cmd+=(--model "$model")

        # Execute and capture JSON output
        local json_output
        if json_output=$("${cmd[@]}" 2>&1); then
            # Extract and output result text only (no JSON, no files)
            local result_text
            if command -v python3 &>/dev/null; then
                result_text=$(python3 -c "import json; data=json.loads('''$json_output'''); print(data.get('result', ''))" 2>/dev/null || echo "")
            fi

            if [[ -z "$result_text" ]] && command -v python &>/dev/null; then
                result_text=$(python -c "import json; data=json.loads('''$json_output'''); print(data.get('result', ''))" 2>/dev/null || echo "")
            fi

            echo "$result_text"
        else
            log_error "Claude Code execution failed"
            return 1
        fi

        return 0
    fi

    # Normal mode: full session management with files
    # Generate session ID first
    local session_id=$(generate_session_id)
    local session_dir="$SESSIONS_DIR/$session_id"

    # Use custom output dir if specified, otherwise use session dir
    if [[ -n "$output_dir" ]]; then
        mkdir -p "$output_dir"
        session_dir="$output_dir/$session_id"
    fi

    mkdir -p "$session_dir"

    log_info "Starting new Claude Code session: $session_id"
    debug "Session directory: $session_dir"

    # Save initial problem
    echo "$prompt" > "$session_dir/problem.txt"

    # Execute Round 1
    local round1_output="$session_dir/round-001.txt"
    local round1_json="$session_dir/round-001.json"

    debug "Executing: claude --print with prompt"

    # Build command with optional model
    local cmd=(claude --print "$prompt" --output-format json)
    [[ -n "$model" ]] && cmd+=(--model "$model")

    # Execute and capture JSON output
    local json_output
    if json_output=$("${cmd[@]}" 2>&1); then
        debug "Claude Code execution successful"

        # Save JSON output
        echo "$json_output" > "$round1_json"

        # Extract session ID from JSON
        local claude_session_id
        if command -v python3 &>/dev/null; then
            claude_session_id=$(python3 -c "import json; data=json.loads('''$json_output'''); print(data.get('session_id', ''))" 2>/dev/null || echo "")
        fi

        if [[ -z "$claude_session_id" ]] && command -v python &>/dev/null; then
            claude_session_id=$(python -c "import json; data=json.loads('''$json_output'''); print(data.get('session_id', ''))" 2>/dev/null || echo "")
        fi

        if [[ -n "$claude_session_id" ]]; then
            echo "$claude_session_id" > "$session_dir/claude_session_id.txt"
            debug "Claude Code session ID: $claude_session_id"
        fi

        # Extract result text
        local result_text
        if command -v python3 &>/dev/null; then
            result_text=$(python3 -c "import json; data=json.loads('''$json_output'''); print(data.get('result', ''))" 2>/dev/null || echo "")
        fi

        if [[ -z "$result_text" ]] && command -v python &>/dev/null; then
            result_text=$(python -c "import json; data=json.loads('''$json_output'''); print(data.get('result', ''))" 2>/dev/null || echo "")
        fi

        # Save result text
        echo "$result_text" > "$round1_output"
    else
        log_error "Claude Code execution failed"
        echo "$json_output" > "$session_dir/error.log"
        exit 1
    fi

    # Save metadata
    ROUND_COUNT=1 STATUS="active" save_session_metadata "$session_id" "$session_dir"

    log_info "Session created: $session_dir"
    log_info "Round 1 completed"

    # Return session ID (stdout for capture)
    echo "$session_id"
}

cmd_continue() {
    local session_id="$1"
    local prompt="$2"
    shift 2

    local session_dir="$SESSIONS_DIR/$session_id"

    # Check if session exists in custom location
    if [[ ! -d "$session_dir" ]]; then
        # Try to find in other locations
        for dir in "$SESSIONS_DIR"/*/"$session_id"; do
            if [[ -d "$dir" ]]; then
                session_dir="$dir"
                break
            fi
        done
    fi

    if [[ ! -d "$session_dir" ]]; then
        log_error "Session not found: $session_id"
        log_error "Searched in: $SESSIONS_DIR"
        exit 1
    fi

    # Load metadata
    local round_count=$(load_metadata "$session_id")
    local next_round=$((round_count + 1))
    local round_label=$(printf "%03d" "$next_round")

    log_info "Continuing session $session_id (Round $next_round)"
    debug "Session directory: $session_dir"

    # Check if we have Claude Code session ID
    local claude_session_id=""
    if [[ -f "$session_dir/claude_session_id.txt" ]]; then
        claude_session_id=$(cat "$session_dir/claude_session_id.txt")
        debug "Using Claude Code session ID: $claude_session_id"
    fi

    # Execute next round
    local round_output="$session_dir/round-${round_label}.txt"
    local round_json="$session_dir/round-${round_label}.json"

    if [[ -n "$claude_session_id" ]]; then
        # Use explicit session ID
        debug "Resuming with explicit session ID: $claude_session_id"

        # Execute
        local json_output
        if json_output=$(claude --resume "$claude_session_id" --print "$prompt" --output-format json 2>&1); then
            debug "Claude Code resume successful"

            # Save JSON
            echo "$json_output" > "$round_json"

            # Extract result text
            local result_text
            if command -v python3 &>/dev/null; then
                result_text=$(python3 -c "import json; data=json.loads('''$json_output'''); print(data.get('result', ''))" 2>/dev/null || echo "")
            fi

            if [[ -z "$result_text" ]] && command -v python &>/dev/null; then
                result_text=$(python -c "import json; data=json.loads('''$json_output'''); print(data.get('result', ''))" 2>/dev/null || echo "")
            fi

            # Save result
            echo "$result_text" > "$round_output"
        else
            log_error "Claude Code resume failed"
            echo "$json_output" > "$session_dir/round-${round_label}-error.log"
            exit 1
        fi
    else
        # Use --continue (fallback)
        debug "Resuming with --continue"

        local json_output
        if json_output=$(claude --continue --print "$prompt" --output-format json 2>&1); then
            debug "Claude Code continue successful"

            # Save JSON
            echo "$json_output" > "$round_json"

            # Extract result text
            local result_text
            if command -v python3 &>/dev/null; then
                result_text=$(python3 -c "import json; data=json.loads('''$json_output'''); print(data.get('result', ''))" 2>/dev/null || echo "")
            fi

            if [[ -z "$result_text" ]] && command -v python &>/dev/null; then
                result_text=$(python -c "import json; data=json.loads('''$json_output'''); print(data.get('result', ''))" 2>/dev/null || echo "")
            fi

            # Save result
            echo "$result_text" > "$round_output"
        else
            log_error "Claude Code continue failed"
            echo "$json_output" > "$session_dir/round-${round_label}-error.log"
            exit 1
        fi
    fi

    # Update metadata
    ROUND_COUNT=$next_round save_session_metadata "$session_id" "$session_dir"

    log_info "Round $next_round completed"
}

cmd_info() {
    local session_id="$1"
    local session_dir="$SESSIONS_DIR/$session_id"

    # Try to find session
    if [[ ! -d "$session_dir" ]]; then
        for dir in "$SESSIONS_DIR"/*/"$session_id"; do
            if [[ -d "$dir" ]]; then
                session_dir="$dir"
                break
            fi
        done
    fi

    if [[ ! -d "$session_dir" ]]; then
        log_error "Session not found: $session_id"
        exit 1
    fi

    echo "==================================================="
    echo "Session: $session_id"
    echo "==================================================="
    echo "Location: $session_dir"
    echo ""
    echo "Metadata:"
    cat "$session_dir/metadata.json" 2>/dev/null || echo "  (no metadata)"
    echo ""
    echo "Rounds:"
    if ls "$session_dir"/round-*.txt &>/dev/null; then
        for round_file in "$session_dir"/round-*.txt; do
            local round_name=$(basename "$round_file")
            local round_size=$(wc -c < "$round_file" 2>/dev/null || echo "0")
            echo "  - $round_name (${round_size} bytes)"
        done
    else
        echo "  (no rounds)"
    fi
    echo ""
    if [[ -f "$session_dir/claude_session_id.txt" ]]; then
        echo "Claude Code Session ID: $(cat "$session_dir/claude_session_id.txt")"
    fi
}

cmd_list() {
    echo "==================================================="
    echo "Claude Code Sessions"
    echo "==================================================="

    local found=0
    for session_dir in "$SESSIONS_DIR"/*; do
        if [[ -d "$session_dir" ]] && [[ -f "$session_dir/metadata.json" ]]; then
            local session_id=$(basename "$session_dir")
            local round_count=$(load_metadata "$session_id")
            local created=$(python3 -c "import json; data=json.load(open('$session_dir/metadata.json')); print(data.get('created_at', 'unknown'))" 2>/dev/null || echo "unknown")
            echo "  $session_id"
            echo "    Rounds: $round_count"
            echo "    Created: $created"
            echo ""
            found=1
        fi
    done

    if [[ $found -eq 0 ]]; then
        echo "  (no sessions found)"
    fi
}

cmd_clean() {
    local session_id="$1"
    local session_dir="$SESSIONS_DIR/$session_id"

    if [[ ! -d "$session_dir" ]]; then
        log_error "Session not found: $session_id"
        exit 1
    fi

    log_info "Removing session: $session_id"
    rm -rf "$session_dir"
    log_info "Session removed"
}

# =============================================================
# Main
# =============================================================

COMMAND="${1:-}"

if [[ -z "$COMMAND" ]]; then
    log_error "No command specified"
    echo "Try: $0 --help"
    exit 1
fi

case "$COMMAND" in
    new)
        shift
        if [[ $# -eq 0 ]]; then
            log_error "Prompt required"
            echo "Usage: $0 new \"prompt\" [options]"
            exit 1
        fi
        cmd_new "$@"
        ;;
    continue)
        shift
        if [[ $# -lt 2 ]]; then
            log_error "Session ID and prompt required"
            echo "Usage: $0 continue <session-id> \"prompt\""
            exit 1
        fi
        cmd_continue "$@"
        ;;
    info)
        shift
        if [[ $# -eq 0 ]]; then
            log_error "Session ID required"
            echo "Usage: $0 info <session-id>"
            exit 1
        fi
        cmd_info "$@"
        ;;
    list)
        cmd_list
        ;;
    clean)
        shift
        if [[ $# -eq 0 ]]; then
            log_error "Session ID required"
            echo "Usage: $0 clean <session-id>"
            exit 1
        fi
        cmd_clean "$@"
        ;;
    --help|-h|help)
        cat << EOF
Claude Code Session Manager v$VERSION

Manage stateful multi-round conversations with Claude Code.

Usage:
  $0 new "prompt" [options]           Start new session
  $0 continue <session-id> "prompt"   Continue session
  $0 info <session-id>                Show session info
  $0 list                             List all sessions
  $0 clean <session-id>               Remove session

Options:
  --output-dir <dir>      Output directory (default: .claude-code-sessions)
  --output-format <fmt>   text|json (default: text)
  --model <model>         Claude Code model (default: auto)
  --quiet                 Suppress progress messages
  --debug                 Enable debug output

Environment Variables:
  CLAUDE_CODE_SESSIONS_DIR      Override default sessions directory

Examples:
  # Start new session
  SESSION_ID=\$(bash $0 new "Explain Python decorators")

  # Continue with multiple rounds
  bash $0 continue "\$SESSION_ID" "Provide examples"
  bash $0 continue "\$SESSION_ID" "What are common pitfalls?"

  # Check results
  bash $0 info "\$SESSION_ID"

  # List all sessions
  bash $0 list

  # Clean up
  bash $0 clean "\$SESSION_ID"

Use Cases:
  - AI debates (multi-round analysis)
  - Code reviews (iterative feedback)
  - Documentation (progressive refinement)
  - Architecture decisions (step-by-step evaluation)

EOF
        exit 0
        ;;
    *)
        log_error "Unknown command: $COMMAND"
        echo "Try: $0 --help"
        exit 1
        ;;
esac
