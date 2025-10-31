# Codex Debate Scripts

Stateful multi-round Codex consultation scripts with automatic session management and token-efficient auto-compaction.

## Scripts

### 1. debate-start.sh
Bootstrap a new Codex debate session.

**Usage:**
```bash
# Start with inline message
./debate-start.sh -m "What's the best approach for X?"

# Start with message from file
./debate-start.sh -f prompt.txt

# Start with STDIN
echo "Your question" | ./debate-start.sh

# Disable auto-compaction
./debate-start.sh --no-auto-compact -m "Your question"
```

**Options:**
- `-m, --message TEXT` - Prompt to send
- `-f, --message-file FILE` - Read prompt from file
- `-s, --session-file FILE` - Override metadata file path
- `-d, --state-dir DIR` - Override state directory
- `--auto-compact-flag F` - Override auto-compaction flag (default: `--auto-compact`)
- `--no-auto-compact` - Disable auto-compaction entirely
- `-h, --help` - Show help

### 2. debate-continue.sh
Continue an existing session or restart if invalid.

**Usage:**
```bash
# Continue with new question
./debate-continue.sh -m "Follow up: What about Y?"

# Force restart (ignore saved session)
./debate-continue.sh --restart -m "Start fresh"

# Fail instead of auto-restart on invalid session
./debate-continue.sh --skip-restart -m "Your question"
```

**Options:**
- Same as debate-start.sh, plus:
- `--restart` - Ignore existing metadata and start fresh
- `--skip-restart` - Fail if session is invalid (don't auto-restart)

**Auto-restart behavior:**
- If saved session is missing or rejected by Codex, automatically starts a new session
- Use `--skip-restart` to disable this and fail instead

### 3. debate-end.sh
Close session and clean up.

**Usage:**
```bash
# Close session and clean up
./debate-end.sh

# Skip remote termination (only delete local files)
./debate-end.sh --skip-remote
```

**Options:**
- `-s, --session-file FILE` - Override metadata file path
- `-d, --state-dir DIR` - Override state directory
- `--skip-remote` - Skip remote session termination
- `-h, --help` - Show help

## Session State

Sessions are stored in platform-specific directories:

- **Linux/Unix:** `~/.local/state/codex-debates/session.json`
- **macOS:** `~/Library/Application Support/codex-debates/session.json`
- **Windows (Git Bash/MSYS):** `%LOCALAPPDATA%/codex-debates/session.json`

**Override with:**
- Environment variable: `DEBATE_STATE_DIR=/custom/path`
- Command flag: `-d /custom/path`

## Metadata Format

```json
{
  "session_path": "/path/to/codex/session",
  "session_id": "019a2d02-...",
  "created_at": "2025-10-29T00:00:00Z",
  "updated_at": "2025-10-29T01:00:00Z",
  "auto_compact_flag": "--auto-compact",
  "last_prompt": "Your last question",
  "raw": { ... }
}
```

## Example Workflow

**Korean mode (default):**
```bash
# Round 1: Start debate
./debate-start.sh -m "Blueprint orchestrator를 어떻게 설계해야 할까요?"

# Round 2: Follow up
./debate-continue.sh -m "상태 관리(state management)는 어떻게 하죠?"

# Round 3: More questions
./debate-continue.sh -m "에러 처리는 어떻게 해야 할까요?"

# Clean up
./debate-end.sh
```

**English mode:**
```bash
# Switch to English
export CODEX_LANG=en

# Round 1: Start debate
./debate-start.sh -m "How should I design a blueprint orchestrator?"

# Round 2: Follow up
./debate-continue.sh -m "What about state management?"

# Round 3: More questions
./debate-continue.sh -m "How to handle errors?"

# Clean up
./debate-end.sh
```

## Cross-Platform Support

All scripts work on:
- Linux
- macOS
- Windows Git Bash
- Windows MSYS/Cygwin

**Requirements:**
- Bash 4.0+
- Python 3.x (for JSON parsing)
- `codex` CLI on PATH

## Language Settings

**Default: Korean (한글) with English technical terms**

Both `debate-start.sh` and `debate-continue.sh` default to requesting Korean responses from Codex.

**Response format:**
- Korean explanations: "캐싱(caching) 전략을 고려할 때..."
- English code/function names
- Technical terms: "지연 시간(latency)", "영속성(persistence)"

**Switch to English mode:**
```bash
# English mode for a single debate
CODEX_LANG=en ./debate-start.sh -m "Your question"
CODEX_LANG=en ./debate-continue.sh -m "Follow up"

# Set globally for your session
export CODEX_LANG=en
./debate-start.sh -m "Your question"
./debate-continue.sh -m "Follow up"
```

**Switch back to Korean:**
```bash
unset CODEX_LANG
# or
CODEX_LANG=ko ./debate-start.sh -m "질문"
```

**How it works:**
- Scripts automatically prepend language instruction to your message
- No manual language request needed
- Session state preserves language preference
- Works seamlessly with V3.0 facilitator's agent-driven judgment

## Environment Variables

- `DEBATE_STATE_DIR` - Override state directory
- `PYTHON_BIN` - Override Python interpreter (default: auto-detect)
- `CODEX_AUTO_COMPACT_FLAG` - Default auto-compaction flag
- `CODEX_LANG` - Response language (`ko` = Korean [default], `en` = English)

## Error Handling

All scripts include:
- Rigorous argument validation
- Clear error messages to stderr
- Automatic temp file cleanup
- Exit codes: 0 = success, 1 = error

## Token Efficiency

The `--auto-compact` flag (enabled by default) tells Codex to automatically compact conversation history when approaching token limits, saving ~67% tokens in long debates.

**To disable:**
```bash
./debate-start.sh --no-auto-compact -m "Your question"
```

## Integration with Claude Code

These scripts complement the `codex-collaborative-solver` skill:

**Manual debates (these scripts):**
```bash
./debate-start.sh -m "Question for Codex"
./debate-continue.sh -m "Follow up"
```

**Skill-based debates (Claude Code):**
```
User: "Discuss X with Codex"
Claude: *Uses codex-collaborative-solver skill*
```

Use manual scripts when you want:
- Direct control over rounds
- Session persistence across days
- Custom state management
- Scriptable automation

Use the skill when you want:
- Claude to manage the conversation
- Automatic round planning
- Integrated documentation
- Analysis and insights

---

**Created:** 2025-10-29
**Provider:** OpenAI Codex (GPT-5-Codex)
**Session:** 019a2d06-6bd5-7cf2-add5-f89dc6b41b16
