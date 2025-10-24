#!/bin/bash
# test-init-workspace.sh - Simulate real user testing /init-workspace

set -e

echo "=========================================="
echo "Real User Simulation Test"
echo "Testing: /init-workspace python"
echo "=========================================="
echo ""

# 1. Create test directory (like a real user would)
TEST_DIR="/tmp/user-test-$(date +%s)"
mkdir -p "$TEST_DIR"
echo "✓ Created test directory: $TEST_DIR"

# 2. Navigate to test directory
cd "$TEST_DIR"
echo "✓ Changed to test directory"
echo ""

# 3. Create a test script that Claude will execute
# This simulates typing the command in an interactive session
cat > "$TEST_DIR/test-commands.txt" << 'EOF'
/init-workspace python
EOF

echo "✓ Created test command file"
echo ""

# 4. Execute Claude in a completely separate process
# Using script to capture full session output
echo "Starting Claude Code in independent process..."
echo "This simulates a real user opening a terminal and running Claude"
echo ""

# Start time
START_TIME=$(date +%s)

# Run claude --print in a completely independent shell
# with proper error handling and timeout
(
    cd "$TEST_DIR"
    timeout 60s claude --print "$(cat test-commands.txt)" > output.log 2>&1
    echo $? > exit_code.txt
) &

CLAUDE_PID=$!
echo "Claude process started (PID: $CLAUDE_PID)"

# Monitor progress
echo ""
echo "Waiting for completion (max 60 seconds)..."
ELAPSED=0
while kill -0 $CLAUDE_PID 2>/dev/null; do
    sleep 2
    ELAPSED=$((ELAPSED + 2))
    if [ $ELAPSED -le 60 ]; then
        echo "  ... ${ELAPSED}s elapsed"
    fi
done

wait $CLAUDE_PID
EXIT_CODE=$(cat "$TEST_DIR/exit_code.txt" 2>/dev/null || echo "unknown")

# End time
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo ""
echo "=========================================="
echo "Test Completed"
echo "=========================================="
echo "Duration: ${DURATION}s"
echo "Exit code: $EXIT_CODE"
echo ""

# 5. Analyze results
echo "Analyzing results..."
echo ""

# Count files created
if [ -d "$TEST_DIR" ]; then
    FILE_COUNT=$(find "$TEST_DIR" -type f ! -name "test-commands.txt" ! -name "output.log" ! -name "exit_code.txt" 2>/dev/null | wc -l)
    echo "Files created: $FILE_COUNT"

    # Check for key files
    echo ""
    echo "Key files verification:"
    [ -f "pyproject.toml" ] && echo "  ✓ pyproject.toml" || echo "  ✗ pyproject.toml"
    [ -f "pytest.ini" ] && echo "  ✓ pytest.ini" || echo "  ✗ pytest.ini"
    [ -f ".mcp.json" ] && echo "  ✓ .mcp.json" || echo "  ✗ .mcp.json"
    [ -d ".specify" ] && echo "  ✓ .specify/" || echo "  ✗ .specify/"
    [ -d "src" ] && echo "  ✓ src/" || echo "  ✗ src/"
    [ -d "tests" ] && echo "  ✓ tests/" || echo "  ✗ tests/"
    [ -d ".github/workflows" ] && echo "  ✓ .github/workflows/" || echo "  ✗ .github/workflows/"
fi

echo ""
echo "Command output (last 50 lines):"
echo "----------------------------------------"
tail -50 "$TEST_DIR/output.log" 2>/dev/null || echo "No output captured"
echo "----------------------------------------"

echo ""
echo "Test directory preserved at: $TEST_DIR"
echo ""

# 6. Generate report
REPORT_FILE="/tmp/init-workspace-real-test-report.txt"
cat > "$REPORT_FILE" << REPORT_EOF
# /init-workspace Real User Simulation Test Report

**Test Date:** $(date)
**Test Directory:** $TEST_DIR
**Execution Time:** ${DURATION}s
**Exit Code:** $EXIT_CODE

## Test Scenario

Simulated a real user:
1. Opening a new terminal
2. Creating a new directory
3. Running: claude
4. Executing: /init-workspace python

## Results

**Files Created:** $FILE_COUNT

**Key Components:**
$(cd "$TEST_DIR" && {
    [ -f "pyproject.toml" ] && echo "✓" || echo "✗"
} 2>/dev/null) pyproject.toml
$(cd "$TEST_DIR" && {
    [ -f "pytest.ini" ] && echo "✓" || echo "✗"
} 2>/dev/null) pytest.ini
$(cd "$TEST_DIR" && {
    [ -f ".mcp.json" ] && echo "✓" || echo "✗"
} 2>/dev/null) .mcp.json
$(cd "$TEST_DIR" && {
    [ -d ".specify" ] && echo "✓" || echo "✗"
} 2>/dev/null) .specify/
$(cd "$TEST_DIR" && {
    [ -d "src" ] && echo "✓" || echo "✗"
} 2>/dev/null) src/
$(cd "$TEST_DIR" && {
    [ -d "tests" ] && echo "✓" || echo "✗"
} 2>/dev/null) tests/
$(cd "$TEST_DIR" && {
    [ -d ".github/workflows" ] && echo "✓" || echo "✗"
} 2>/dev/null) .github/workflows/

## Performance

- Expected: ~3 seconds
- Actual: ${DURATION}s
- Status: $([ $DURATION -lt 10 ] && echo "✓ GOOD" || echo "⚠ SLOW")

## Output Log

See: $TEST_DIR/output.log

## Test Status

$([ $FILE_COUNT -ge 15 ] && [ $EXIT_CODE = "0" ] && echo "✅ PASS" || echo "❌ FAIL")

---
Generated: $(date)
REPORT_EOF

echo "Report saved: $REPORT_FILE"
cat "$REPORT_FILE"

echo ""
echo "=========================================="
echo "Test artifacts:"
echo "  - Test directory: $TEST_DIR"
echo "  - Output log: $TEST_DIR/output.log"
echo "  - Report: $REPORT_FILE"
echo "=========================================="
