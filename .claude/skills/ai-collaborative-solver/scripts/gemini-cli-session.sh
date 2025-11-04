#!/usr/bin/env bash
# gemini-cli-session.sh
# Generalized Gemini CLI stateful session management
#
# Usage:
#   gemini-cli-session.sh new "prompt" [options]
#   gemini-cli-session.sh continue <session-id> "prompt"
#   gemini-cli-session.sh info <session-id>
#   gemini-cli-session.sh list

set -euo pipefail

VERSION="1.0.0"
SESSIONS_DIR="${GEMINI_CLI_SESSIONS_DIR:-.gemini-cli-sessions}"

# =============================================================
# Configuration
# =============================================================

DEFAULT_OUTPUT_FORMAT="text"
DEFAULT_MODEL=""  # Empty = use Gemini CLI default

# Get API key from settings.json (workaround for Gemini CLI bug)
# Try multiple possible locations
GEMINI_SETTINGS=""
GEMINI_SETTINGS_PYTHON=""  # Python-compatible path
for settings_path in "${HOME}/.gemini/settings.json" "C:/Users/EST/.gemini/settings.json" "/c/Users/EST/.gemini/settings.json"; do
    if [[ -f "$settings_path" ]]; then
        GEMINI_SETTINGS="$settings_path"
        # Convert /c/ paths to C:/ for Python compatibility
        GEMINI_SETTINGS_PYTHON="${settings_path/#\/c\//C:/}"
        break
    fi
done

if [[ -n "$GEMINI_SETTINGS_PYTHON" ]]; then
    # Use heredoc for Python script to avoid quoting issues
    GEMINI_API_KEY_FROM_FILE=$(python << EOF 2>/dev/null || echo ""
import json
try:
    with open('$GEMINI_SETTINGS_PYTHON') as f:
        data = json.load(f)
        print(data.get('auth', {}).get('apiKey', ''))
except:
    pass
EOF
)
    export GEMINI_API_KEY="${GEMINI_API_KEY:-$GEMINI_API_KEY_FROM_FILE}"
fi

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

build_context_prompt() {
    local session_dir="$1"
    local new_prompt="$2"

    # Build conversation history from previous rounds
    local context=""

    # Add previous rounds (up to last 3 for context window management)
    # Use grep to exclude -prompt.txt files
    local round_files=($(ls -1 "$session_dir"/round-*.txt 2>/dev/null | grep -v -- '-prompt\.txt$' | tail -3 || echo ""))

    if [[ ${#round_files[@]} -gt 0 ]] && [[ -n "${round_files[0]}" ]]; then
        context="Previous conversation:\n\n"
        for round_file in "${round_files[@]}"; do
            local round_num=$(basename "$round_file" | sed 's/round-\([0-9]*\).txt/\1/')
            local round_prompt=$(cat "$session_dir/round-${round_num}-prompt.txt" 2>/dev/null || echo "")
            local round_response=$(cat "$round_file" 2>/dev/null || echo "")

            if [[ -n "$round_prompt" ]]; then
                context="${context}User: $round_prompt\n\n"
            fi
            if [[ -n "$round_response" ]]; then
                context="${context}Assistant: $round_response\n\n"
            fi
        done
        context="${context}Current user message: $new_prompt"
    else
        context="$new_prompt"
    fi

    echo -e "$context"
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

    # Check API key
    if [[ -z "${GEMINI_API_KEY:-}" ]]; then
        log_error "GEMINI_API_KEY not set. Please configure it in ~/.gemini/settings.json or export GEMINI_API_KEY"
        exit 1
    fi

    # Fast mode: no file creation, output only
    if [[ "$stdout_only" == "true" ]]; then
        debug "Fast mode: stdout-only (no files)"

        # Build command with optional model
        local cmd=(gemini "$prompt" -o json)
        [[ -n "$model" ]] && cmd+=(-m "$model")

        # Execute and capture JSON output
        local json_output
        if json_output=$("${cmd[@]}" 2>&1); then
            # Extract and output response text only (no JSON, no files)
            local result_text=$(python << EOF 2>/dev/null || echo ""
import json
try:
    data = json.loads('''$json_output''')
    print(data.get('response', '').strip())
except:
    pass
EOF
)

            echo "$result_text"
        else
            log_error "Gemini CLI execution failed"
            return 1
        fi

        return 0
    fi

    # Normal mode: full session management with files
    # Generate session ID first
    local session_id=$(generate_session_id)
    local session_dir="$SESSIONS_DIR/$session_id"

    # Use custom output dir if specified
    if [[ -n "$output_dir" ]]; then
        mkdir -p "$output_dir"
        session_dir="$output_dir/$session_id"
    fi

    mkdir -p "$session_dir"

    log_info "Starting new Gemini CLI session: $session_id"
    debug "Session directory: $session_dir"

    # Save initial problem
    echo "$prompt" > "$session_dir/problem.txt"
    echo "$prompt" > "$session_dir/round-001-prompt.txt"

    # Execute Round 1
    local round1_output="$session_dir/round-001.txt"
    local round1_json="$session_dir/round-001.json"

    debug "Executing: gemini with prompt"

    # Build command with optional model
    local cmd=(gemini "$prompt" -o json)
    [[ -n "$model" ]] && cmd+=(-m "$model")

    # Execute and capture JSON output
    local json_output
    if json_output=$("${cmd[@]}" 2>&1); then
        debug "Gemini CLI execution successful"

        # Save JSON output
        echo "$json_output" > "$round1_json"

        # Extract response text from JSON
        local result_text=$(python << EOF 2>/dev/null || echo ""
import json
try:
    with open('$round1_json') as f:
        data = json.load(f)
        print(data.get('response', '').strip())
except:
    pass
EOF
)

        if [[ -z "$result_text" ]]; then
            log_error "Failed to extract response from JSON"
            exit 1
        fi

        # Save result text
        echo "$result_text" > "$round1_output"
    else
        log_error "Gemini CLI execution failed"
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

    # Check if session exists
    if [[ ! -d "$session_dir" ]]; then
        log_error "Session not found: $session_id"
        log_error "Searched in: $SESSIONS_DIR"
        exit 1
    fi

    # Check API key
    if [[ -z "${GEMINI_API_KEY:-}" ]]; then
        log_error "GEMINI_API_KEY not set. Please configure it in ~/.gemini/settings.json or export GEMINI_API_KEY"
        exit 1
    fi

    # Load metadata
    local round_count=$(load_metadata "$session_id")
    local next_round=$((round_count + 1))
    local round_label=$(printf "%03d" "$next_round")

    log_info "Continuing session $session_id (Round $next_round)"
    debug "Session directory: $session_dir"

    # Save the new prompt
    echo "$prompt" > "$session_dir/round-${round_label}-prompt.txt"

    # Build context-aware prompt
    local context_prompt=$(build_context_prompt "$session_dir" "$prompt")
    debug "Context prompt built with ${#context_prompt} characters"

    # Execute next round
    local round_output="$session_dir/round-${round_label}.txt"
    local round_json="$session_dir/round-${round_label}.json"

    # Execute
    local json_output
    if json_output=$(gemini "$context_prompt" -o json 2>&1); then
        debug "Gemini CLI execution successful"

        # Save JSON
        echo "$json_output" > "$round_json"

        # Extract result text
        local result_text=$(python << EOF 2>/dev/null || echo ""
import json
try:
    with open('$round_json') as f:
        data = json.load(f)
        print(data.get('response', '').strip())
except:
    pass
EOF
)

        # Save result
        echo "$result_text" > "$round_output"
    else
        log_error "Gemini CLI execution failed"
        echo "$json_output" > "$session_dir/round-${round_label}-error.log"
        exit 1
    fi

    # Update metadata
    ROUND_COUNT=$next_round save_session_metadata "$session_id" "$session_dir"

    log_info "Round $next_round completed"
}

cmd_info() {
    local session_id="$1"
    local session_dir="$SESSIONS_DIR/$session_id"

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
}

cmd_list() {
    echo "==================================================="
    echo "Gemini CLI Sessions"
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
Gemini CLI Session Manager v$VERSION

Manage stateful multi-round conversations with Gemini CLI.

Usage:
  $0 new "prompt" [options]           Start new session
  $0 continue <session-id> "prompt"   Continue session
  $0 info <session-id>                Show session info
  $0 list                             List all sessions
  $0 clean <session-id>               Remove session

Options:
  --output-dir <dir>      Output directory (default: .gemini-cli-sessions)
  --output-format <fmt>   text|json (default: text)
  --model <model>         Gemini model (default: gemini-2.0-flash-exp)
  --quiet                 Suppress progress messages
  --debug                 Enable debug output

Environment Variables:
  GEMINI_CLI_SESSIONS_DIR       Override default sessions directory
  GEMINI_API_KEY                API key (auto-loaded from ~/.gemini/settings.json)

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

Note: Gemini CLI doesn't have native session management, so this script
      manages context by passing conversation history in each round.

EOF
        exit 0
        ;;
    *)
        log_error "Unknown command: $COMMAND"
        echo "Try: $0 --help"
        exit 1
        ;;
esac
