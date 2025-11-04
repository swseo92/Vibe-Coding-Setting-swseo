#!/usr/bin/env bash
# codex-session.sh
# Generalized Codex stateful session management
#
# Usage:
#   codex-session.sh new "prompt" [options]
#   codex-session.sh continue <session-id> "prompt"
#   codex-session.sh info <session-id>
#   codex-session.sh list

set -euo pipefail

VERSION="1.0.0"
SESSIONS_DIR="${CODEX_SESSIONS_DIR:-.codex-sessions}"

# =============================================================
# Configuration
# =============================================================

DEFAULT_OUTPUT_FORMAT="text"
DEFAULT_SANDBOX="workspace-write"
DEFAULT_MODEL=""  # Empty = use Codex's default from config.toml

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
    local session_dir="$SESSIONS_DIR/$session_id"

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
    local sandbox="$DEFAULT_SANDBOX"
    local model="$DEFAULT_MODEL"
    local stdout_only=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --output-dir) output_dir="$2"; shift 2 ;;
            --output-format) output_format="$2"; shift 2 ;;
            --sandbox) sandbox="$2"; shift 2 ;;
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

        # Execute and output to stdout directly
        local cmd=(codex exec "$prompt" --full-auto --sandbox "$sandbox" --skip-git-repo-check)
        [[ -n "$model" ]] && cmd+=(-m "$model")

        # Execute (stdout goes to caller, stderr suppressed unless debug)
        if [[ "${DEBUG:-false}" == "true" ]]; then
            "${cmd[@]}"
        else
            "${cmd[@]}" 2>/dev/null
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

    log_info "Starting new Codex session: $session_id"
    debug "Session directory: $session_dir"

    # Save initial problem
    echo "$prompt" > "$session_dir/problem.txt"

    # Execute Round 1
    local round1_output="$session_dir/round-001.txt"
    local round1_log="$session_dir/round-001.log"

    debug "Executing: codex exec with prompt"

    if [[ "$output_format" == "json" ]]; then
        # Build command with optional model
        local cmd=(codex exec "$prompt" --json --sandbox "$sandbox" --skip-git-repo-check)
        [[ -n "$model" ]] && cmd+=(-m "$model")
        "${cmd[@]}" > "$session_dir/round-001.jsonl" 2>&1

        # Extract Codex session ID from JSONL
        local actual_session_id=$(grep -o '"session_id":"[^"]*"' "$session_dir/round-001.jsonl" | head -1 | cut -d'"' -f4 || echo "")

        if [[ -n "$actual_session_id" ]]; then
            echo "$actual_session_id" > "$session_dir/codex_session_id.txt"
            debug "Codex session ID: $actual_session_id"
        fi
    else
        # Use --full-auto for automatic execution
        local cmd=(codex exec "$prompt" --full-auto --sandbox "$sandbox" --skip-git-repo-check -o "$round1_output")
        [[ -n "$model" ]] && cmd+=(-m "$model")
        "${cmd[@]}" > "$round1_log" 2>&1

        # Try to extract session ID from log
        local actual_session_id=$(grep -i "session id:" "$round1_log" | head -1 | grep -o '[0-9a-f]\{8\}-[0-9a-f]\{4\}-[0-9a-f]\{4\}-[0-9a-f]\{4\}-[0-9a-f]\{12\}' || echo "")
        if [[ -n "$actual_session_id" ]]; then
            echo "$actual_session_id" > "$session_dir/codex_session_id.txt"
            debug "Codex session ID: $actual_session_id"
        fi
    fi

    # Save metadata
    ROUND_COUNT=1 STATUS="active" save_session_metadata "$session_id"

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

    # Check if we have Codex session ID
    local codex_session_id=""
    if [[ -f "$session_dir/codex_session_id.txt" ]]; then
        codex_session_id=$(cat "$session_dir/codex_session_id.txt")
        debug "Using Codex session ID: $codex_session_id"
    fi

    # Execute next round
    local round_output="$session_dir/round-${round_label}.txt"
    local round_log="$session_dir/round-${round_label}.log"

    if [[ -n "$codex_session_id" ]]; then
        # Use explicit session ID
        debug "Resuming with explicit session ID: $codex_session_id"
        codex exec resume "$codex_session_id" "$prompt" --skip-git-repo-check \
            > "$round_output" 2> "$round_log"
    else
        # Use --last (fallback)
        debug "Resuming with --last"
        codex exec resume --last "$prompt" --skip-git-repo-check \
            > "$round_output" 2> "$round_log"
    fi

    # Update metadata
    ROUND_COUNT=$next_round save_session_metadata "$session_id"

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
    if [[ -f "$session_dir/codex_session_id.txt" ]]; then
        echo "Codex Session ID: $(cat "$session_dir/codex_session_id.txt")"
    fi
}

cmd_list() {
    echo "==================================================="
    echo "Codex Sessions"
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
Codex Session Manager v$VERSION

Manage stateful multi-round conversations with Codex CLI.

Usage:
  $0 new "prompt" [options]           Start new session
  $0 continue <session-id> "prompt"   Continue session
  $0 info <session-id>                Show session info
  $0 list                             List all sessions
  $0 clean <session-id>               Remove session

Options:
  --output-dir <dir>      Output directory (default: .codex-sessions)
  --output-format <fmt>   text|json (default: text)
  --sandbox <mode>        Sandbox policy (default: workspace-write)
                          Options: read-only, workspace-write, danger-full-access
  --model <model>         Codex model (default: auto)
  --quiet                 Suppress progress messages
  --debug                 Enable debug output

Environment Variables:
  CODEX_SESSIONS_DIR      Override default sessions directory

Examples:
  # Start new session
  SESSION_ID=\$(bash $0 new "Analyze Django vs FastAPI performance")

  # Continue with multiple rounds
  bash $0 continue "\$SESSION_ID" "Compare scalability"
  bash $0 continue "\$SESSION_ID" "Consider team productivity"

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
