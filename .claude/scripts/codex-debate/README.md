# Codex Stateful Debate Scripts

Token-efficient stateful conversation scripts for OpenAI Codex CLI.

## Overview

These scripts enable **stateful** multi-round discussions with Codex, eliminating the need to re-send entire conversation history in each round.

**Token Savings: ~67%** (from 6,500 to 2,100 tokens over 5 rounds)

## Scripts

### 1. `debate-start.sh` - Start New Session

Starts a new Codex consultation and saves the thread ID for later rounds.

**Usage:**
```bash
./debate-start.sh "Your question or problem description"
```

**Example:**
```bash
./debate-start.sh "What's the best approach to handle authentication in a REST API?"
```

**Output:**
- Codex's response (displayed in terminal)
- Session saved to `./debate-session/thread_id.txt`
- Output logged to `./debate-session/last-output.jsonl`

### 2. `debate-continue.sh` - Continue Session

Continues an existing session with a new message.

**Usage:**
```bash
./debate-continue.sh "Follow-up question or new perspective"
```

**Example:**
```bash
./debate-continue.sh "What about JWT vs session tokens?"
```

**Features:**
- ✅ Automatically loads previous thread ID
- ✅ No need to re-send conversation history
- ✅ Appends output to session log

### 3. `debate-end.sh` - Cleanup Session

Removes session files when done.

**Usage:**
```bash
./debate-end.sh
```

## Full Workflow Example

```bash
# Round 1: Start discussion
./debate-start.sh "How to optimize Python code for performance?"

# Round 2: Follow up
./debate-continue.sh "What about using Cython?"

# Round 3: Another angle
./debate-continue.sh "Compare Cython vs PyPy"

# Round 4: Specific question
./debate-continue.sh "Show me a Cython example for matrix multiplication"

# Cleanup when done
./debate-end.sh
```

## How It Works

### Traditional (Stateless) Approach
```bash
# Round 1
codex exec "Question 1"  # 500 tokens

# Round 2 - must re-send Round 1 context
codex exec "Context from Round 1... Question 2"  # 900 tokens

# Round 3 - must re-send Rounds 1+2
codex exec "Context from Rounds 1-2... Question 3"  # 1,300 tokens

# Total: ~6,500 tokens
```

### Stateful Approach (These Scripts)
```bash
# Round 1
debate-start.sh "Question 1"  # 500 tokens
# Saves thread_id: 019a2d18-c64a-7ef3-aae3-71e536186462

# Round 2 - Codex remembers Round 1
debate-continue.sh "Question 2"  # 400 tokens (new content only!)

# Round 3 - Codex remembers Rounds 1-2
debate-continue.sh "Question 3"  # 400 tokens

# Total: ~2,100 tokens (67% savings!)
```

## Session Storage

**Location:** `./debate-session/` (relative to where you run the script)

**Files:**
- `thread_id.txt` - The Codex thread/session ID
- `created_at.txt` - Timestamp
- `last-output.jsonl` - Full JSONL output log

**Custom location:**
```bash
export DEBATE_STATE_DIR="$HOME/.codex-debates"
./debate-start.sh "Question"
```

## Requirements

- [OpenAI Codex CLI](https://github.com/openai/codex) v0.50.0+
- Bash (Git Bash on Windows, native on Linux/Mac)
- Basic Unix tools: `grep`, `sed`, `tee`

## Technical Details

### Thread ID Extraction

Codex `--json` output is JSONL format:
```json
{"type":"thread.started","thread_id":"019a2d18..."}
{"type":"turn.started"}
{"type":"item.completed","item":{...}}
```

We extract `thread_id` from the first event and reuse it with:
```bash
codex exec -c "thread_id=\"$THREAD_ID\"" "$MESSAGE"
```

### No Auto-Compaction Flag

Unlike the original Codex proposal, current Codex CLI doesn't support `--auto-compact`. However, Codex handles context window management automatically.

## Troubleshooting

**"No session found"**
- Run `debate-start.sh` first to create a session

**"Error: stdout is not a terminal"**
- Fixed in v3 by using `codex exec` instead of `codex resume`

**Session not persisting**
- Check `./debate-session/thread_id.txt` exists
- Verify `DEBATE_STATE_DIR` if using custom location

## Integration with codex-collaborative-solver Skill

These scripts can be integrated into the `codex-collaborative-solver` Claude Code skill for automated multi-round debates:

```bash
# In skill implementation:
bash .claude/scripts/codex-debate/debate-start.sh "$ROUND_1_PROMPT"
bash .claude/scripts/codex-debate/debate-continue.sh "$ROUND_2_PROMPT"
# ...
bash .claude/scripts/codex-debate/debate-end.sh
```

## Version History

- **v3** (2025-10-29): Working stateful implementation with `codex exec -c thread_id`
- **v2** (2025-10-29): Fixed Python parsing issues
- **v1** (2025-10-29): Initial prototype based on Codex's proposal

## Credits

Created through collaborative problem-solving between:
- **Claude** (Anthropic) - Initial analysis and approach design
- **Codex** (OpenAI) - Implementation details and script structure
- **Human Developer** - Testing, refinement, and practical fixes

---

**License:** MIT
**Maintainer:** swseo
**Last Updated:** 2025-10-29
