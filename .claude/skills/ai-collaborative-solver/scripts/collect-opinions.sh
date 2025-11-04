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

    # Create output directory (only 3 files will be created)
    mkdir -p "$OUTPUT_DIR"
    local timestamp=$(date +%Y%m%d-%H%M%S)
    local session_output="$OUTPUT_DIR/session-$timestamp"
    mkdir -p "$session_output"

    log_info "Starting parallel opinion collection (fast mode: 2 agents)..."
    log_info "Output: $session_output"

    # Save prompt (required)
    echo "$prompt" > "$session_output/prompt.txt"

    # Launch 2 agents in parallel with --stdout-only --quiet
    # Capture output directly to final files (no intermediate files)
    log_info "Launching Codex..."
    bash "$SCRIPT_DIR/codex-session.sh" new "$prompt" --stdout-only --quiet > "$session_output/codex-opinion.txt" 2>&1 &
    local codex_pid=$!

    log_info "Launching Claude Code..."
    bash "$SCRIPT_DIR/claude-code-session.sh" new "$prompt" --stdout-only --quiet > "$session_output/claude-opinion.txt" 2>&1 &
    local claude_pid=$!

    log_info "Launched: Codex($codex_pid), Claude($claude_pid)"
    log_info "Waiting for all agents to complete..."

    # Wait for all processes
    local codex_status=0
    local claude_status=0

    wait $codex_pid || codex_status=$?
    wait $claude_pid || claude_status=$?

    log_info "All agents completed."

    # Check results (opinions already written directly to final files)
    local success_count=0

    # Codex
    if [[ $codex_status -eq 0 ]] && [[ -s "$session_output/codex-opinion.txt" ]]; then
        log_info "✓ Codex opinion collected"
        ((++success_count))
    else
        log_error "✗ Codex failed (exit code: $codex_status)"
        echo "Error: Codex execution failed" > "$session_output/codex-opinion.txt"
    fi

    # Claude Code
    if [[ $claude_status -eq 0 ]] && [[ -s "$session_output/claude-opinion.txt" ]]; then
        log_info "✓ Claude opinion collected"
        ((++success_count))
    else
        log_error "✗ Claude failed (exit code: $claude_status)"
        echo "Error: Claude Code execution failed" > "$session_output/claude-opinion.txt"
    fi

    # Summary
    log_info "========================================"
    log_info "Collection complete: $success_count/2 succeeded"
    log_info "Output directory: $session_output"
    log_info "Files created: 3 (prompt.txt + 2 opinions)"
    log_info "========================================"

    # Output session info to stdout (for Claude to capture)
    echo "SESSION_OUTPUT=$session_output"
    echo "SUCCESS_COUNT=$success_count"

    # Exit with error if not all succeeded
    if [[ $success_count -lt 2 ]]; then
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
