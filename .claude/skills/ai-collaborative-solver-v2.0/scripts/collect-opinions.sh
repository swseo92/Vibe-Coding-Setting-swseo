#!/usr/bin/env bash
# collect-opinions.sh
# Parallel opinion collection from Codex, Claude Code, and Gemini
#
# Usage:
#   bash collect-opinions.sh "Your prompt here"
#
# Returns:
#   - Session IDs on stdout (one per line)
#   - Exit 0 if all succeeded, 1 if any failed

set -euo pipefail

VERSION="1.0.0"

# =============================================================
# Configuration
# =============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${AI_DEBATE_OUTPUT_DIR:-.ai-debate-output}"

# =============================================================
# Helper Functions
# =============================================================

log_info() {
    echo "[INFO] $*" >&2
}

log_error() {
    echo "[ERROR] $*" >&2
}

cleanup() {
    # Optional cleanup on exit
    :
}

trap cleanup EXIT

# =============================================================
# Main
# =============================================================

main() {
    local prompt="$1"

    if [[ -z "$prompt" ]]; then
        log_error "Prompt required"
        echo "Usage: $0 \"Your prompt here\""
        exit 1
    fi

    # Create output directory
    mkdir -p "$OUTPUT_DIR"
    local timestamp=$(date +%Y%m%d-%H%M%S)
    local session_output="$OUTPUT_DIR/session-$timestamp"
    mkdir -p "$session_output"

    log_info "Starting parallel opinion collection..."
    log_info "Output: $session_output"

    # Save prompt
    echo "$prompt" > "$session_output/prompt.txt"

    # Launch all 3 agents in parallel
    log_info "Launching Codex..."
    bash "$SCRIPT_DIR/codex-session.sh" new "$prompt" > "$session_output/codex.log" 2>&1 &
    local codex_pid=$!

    log_info "Launching Claude Code..."
    bash "$SCRIPT_DIR/claude-code-session.sh" new "$prompt" > "$session_output/claude.log" 2>&1 &
    local claude_pid=$!

    log_info "Launching Gemini..."
    bash "$SCRIPT_DIR/gemini-cli-session.sh" new "$prompt" > "$session_output/gemini.log" 2>&1 &
    local gemini_pid=$!

    log_info "Launched: Codex($codex_pid), Claude($claude_pid), Gemini($gemini_pid)"
    log_info "Waiting for all agents to complete..."

    # Wait for all processes
    local codex_status=0
    local claude_status=0
    local gemini_status=0

    wait $codex_pid || codex_status=$?
    wait $claude_pid || claude_status=$?
    wait $gemini_pid || gemini_status=$?

    log_info "All agents completed."

    # Extract session IDs from logs (filter out log lines starting with [)
    local codex_session=$(grep -v '^\[' "$session_output/codex.log" 2>/dev/null | tail -1 | tr -d '\n' || echo "")
    local claude_session=$(grep -v '^\[' "$session_output/claude.log" 2>/dev/null | tail -1 | tr -d '\n' || echo "")
    local gemini_session=$(grep -v '^\[' "$session_output/gemini.log" 2>/dev/null | tail -1 | tr -d '\n' || echo "")

    # Save session IDs
    echo "$codex_session" > "$session_output/codex-session-id.txt"
    echo "$claude_session" > "$session_output/claude-session-id.txt"
    echo "$gemini_session" > "$session_output/gemini-session-id.txt"

    # Collect opinions from session directories
    local success_count=0

    # Codex
    if [[ $codex_status -eq 0 ]] && [[ -n "$codex_session" ]]; then
        local codex_dir=".codex-sessions/$codex_session"
        if [[ -f "$codex_dir/round-001.txt" ]]; then
            cp "$codex_dir/round-001.txt" "$session_output/codex-opinion.txt"
            log_info "✓ Codex opinion collected"
            ((++success_count))
        else
            log_error "✗ Codex session created but no output found"
        fi
    else
        log_error "✗ Codex failed (exit code: $codex_status)"
    fi

    # Claude Code
    if [[ $claude_status -eq 0 ]] && [[ -n "$claude_session" ]]; then
        local claude_dir=".claude-code-sessions/$claude_session"
        if [[ -f "$claude_dir/round-001.txt" ]]; then
            cp "$claude_dir/round-001.txt" "$session_output/claude-opinion.txt"
            log_info "✓ Claude opinion collected"
            ((++success_count))
        else
            log_error "✗ Claude session created but no output found"
        fi
    else
        log_error "✗ Claude failed (exit code: $claude_status)"
    fi

    # Gemini
    if [[ $gemini_status -eq 0 ]] && [[ -n "$gemini_session" ]]; then
        local gemini_dir=".gemini-cli-sessions/$gemini_session"
        if [[ -f "$gemini_dir/round-001.txt" ]]; then
            cp "$gemini_dir/round-001.txt" "$session_output/gemini-opinion.txt"
            log_info "✓ Gemini opinion collected"
            ((++success_count))
        else
            log_error "✗ Gemini session created but no output found"
        fi
    else
        log_error "✗ Gemini failed (exit code: $gemini_status)"
    fi

    # Summary
    log_info "========================================"
    log_info "Collection complete: $success_count/3 succeeded"
    log_info "Output directory: $session_output"
    log_info "========================================"

    # Output session IDs to stdout (for Claude to capture)
    echo "SESSION_OUTPUT=$session_output"
    echo "CODEX_SESSION=$codex_session"
    echo "CLAUDE_SESSION=$claude_session"
    echo "GEMINI_SESSION=$gemini_session"
    echo "SUCCESS_COUNT=$success_count"

    # Exit with error if not all succeeded
    if [[ $success_count -lt 3 ]]; then
        exit 1
    fi

    exit 0
}

# =============================================================
# Entry Point
# =============================================================

if [[ $# -eq 0 ]]; then
    log_error "No prompt provided"
    echo "Usage: $0 \"Your prompt here\""
    exit 1
fi

main "$@"
