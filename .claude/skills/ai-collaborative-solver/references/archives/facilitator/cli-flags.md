# CLI Flags for Mid-Debate User Input

**Purpose:** User control over mid-debate behavior through command-line flags.

---

## Available Flags

### `--no-mid-input`

**Purpose:** Disable mid-debate user input for this session.

**Usage:**
```bash
codex와 토론해줘 --no-mid-input

# English
debate with codex --no-mid-input
```

**Behavior:**
- Claude will NOT ask for user input during debate
- Debate runs fully automatically from start to finish
- All decisions made by Claude + Codex without user involvement

**When to use:**
- Quick exploratory debates
- When you trust AI judgment completely
- Batch processing multiple debates
- Demo/presentation mode

**Example:**
```
User: "codex와 토론해서 이 성능 문제 해결해줘 --no-mid-input"

Claude: ✓ Mid-debate user input disabled for this session.
        Debate will run automatically.

[Debate proceeds without interruption]
```

---

### `--interactive`

**Purpose:** Force interactive mode - ask for user input more frequently.

**Usage:**
```bash
codex와 토론해줘 --interactive

# English
debate with codex --interactive
```

**Behavior:**
- Claude asks for input after EVERY round (not just when heuristic triggers)
- User sees debate state and can provide guidance
- Higher engagement, more control

**When to use:**
- High-stakes decisions
- You want to steer the debate direction
- Learning how debate process works
- Complex problems requiring domain knowledge

**Example:**
```
User: "codex와 토론해줘 --interactive"

Claude: ✓ Interactive mode enabled.
        I'll check in with you after each round.

[After Round 1]
Claude: ## Round 1 Complete

**Summary:** We discussed database indexing strategies.

**Current Direction:** Leaning toward B-tree indexes.

**Your Input:**
1. Continue this direction
2. Explore different approach
3. Add context: [your input]
4. Let debate continue automatically

User: 1

[Debate continues...]
```

---

### `--mid-input-frequency=<level>`

**Purpose:** Fine-tune how often Claude asks for input.

**Usage:**
```bash
codex와 토론해줘 --mid-input-frequency=minimal
codex와 토론해줘 --mid-input-frequency=balanced  # default
codex와 토론해줘 --mid-input-frequency=frequent
```

**Levels:**

#### `minimal`
- Only ask when absolutely critical
- High threshold (confidence < 30%)
- Maximum 1 question per debate

#### `balanced` (default)
- Ask when valuable (confidence < 50%)
- Standard heuristics apply
- 0-2 questions per debate

#### `frequent`
- Ask proactively (confidence < 70%)
- Lower threshold for asking
- 2-4 questions per debate

**Example:**
```bash
# For quick decisions
codex와 토론해줘 --mid-input-frequency=minimal "어떤 데이터베이스 쓸까?"

# For important architectural decisions
codex와 토론해줘 --mid-input-frequency=frequent "마이크로서비스 vs 모놀리스"
```

---

### `--min-interval=<seconds>`

**Purpose:** Set minimum time between user input requests.

**Usage:**
```bash
codex와 토론해줘 --min-interval=600  # 10 minutes
```

**Default:** 300 seconds (5 minutes)

**Behavior:**
- If Claude asked user within last N seconds, skip next request
- Prevents rapid-fire questions
- Respects user's attention

**Example:**
```bash
# Never ask more than once per 15 minutes
codex와 토론해줘 --min-interval=900
```

---

## Flag Combinations

### Silent Mode (No Interruptions)
```bash
codex와 토론해줘 --no-mid-input
```

### Maximum Guidance
```bash
codex와 토론해줘 --interactive --mid-input-frequency=frequent
```

### Balanced (Recommended)
```bash
codex와 토론해줘  # Uses defaults
```

### Quick Check-ins
```bash
codex와 토론해줘 --mid-input-frequency=minimal --min-interval=900
```

---

## Global Settings (Persistent)

**File:** `~/.claude/settings.json`

```json
{
  "codex_debate": {
    "mid_debate_input": {
      "enabled": true,
      "default_frequency": "balanced",
      "min_interval": 300,
      "always_show_state_summary": true
    }
  }
}
```

**Settings Explanation:**

- `enabled` (boolean): Global on/off toggle
  - `true`: Mid-debate input enabled (can be overridden per session)
  - `false`: Disabled globally (user must explicitly enable with `--interactive`)

- `default_frequency` (string): Default behavior when no flag specified
  - `"minimal"`: Conservative, fewer questions
  - `"balanced"`: Standard heuristics (recommended)
  - `"frequent"`: Proactive, more questions

- `min_interval` (integer): Minimum seconds between questions
  - Default: `300` (5 minutes)
  - Range: `60` - `3600` (1 min - 1 hour)

- `always_show_state_summary` (boolean): Show debate state even when not asking
  - `true`: User sees progress summaries
  - `false`: Only shown when asking for input

---

## CLI Flag Priority

**Priority Order** (highest to lowest):

1. **Session CLI flags** (`--no-mid-input`, `--interactive`)
2. **Frequency flags** (`--mid-input-frequency`)
3. **Interval flags** (`--min-interval`)
4. **Global settings** (`settings.json`)
5. **Built-in defaults**

**Example:**
```json
// settings.json
{
  "codex_debate": {
    "mid_debate_input": {
      "enabled": false,  // Global default: OFF
      "default_frequency": "minimal"
    }
  }
}
```

```bash
# This OVERRIDES global setting
codex와 토론해줘 --interactive --mid-input-frequency=frequent

# Result: Mid-debate input ENABLED with frequent questions
```

---

## Flag Detection

**Claude should detect these flags in user messages:**

Patterns to recognize:
```
codex와 토론해줘 --no-mid-input [topic]
debate with codex --interactive [topic]
codex 토론 --mid-input-frequency=minimal [topic]
[topic] --no-mid-input codex와 토론
```

**Parsing Rules:**
1. Look for `--` prefix
2. Extract flag name
3. Extract value after `=` if applicable
4. Validate flag and value
5. Apply for this session only

**Validation:**
```python
valid_flags = {
    "no-mid-input": None,  # No value
    "interactive": None,  # No value
    "mid-input-frequency": ["minimal", "balanced", "frequent"],
    "min-interval": int  # Numeric value
}
```

---

## Usage Examples

### Example 1: Quick Decision
```
User: "Redis vs Memcached 뭐가 나아? --no-mid-input"

Claude: ✓ Mid-debate input disabled.

        Starting debate...
        [Automatic debate proceeds]

        Final recommendation: Redis
        Reasoning: [full explanation]
```

### Example 2: Guided Discussion
```
User: "마이크로서비스 아키텍처 설계해줘 --interactive"

Claude: ✓ Interactive mode enabled.

[After Round 1]
Claude: ## 🔄 Round 1 Complete

**Discussed:** Service boundaries, communication patterns

**Direction:** API Gateway + 5-7 microservices

**Your Input?**
1. Continue ✓
2. Fewer services (3-4)
3. More services (8-10)
4. Different approach

User: 2

Claude: Noted. Adjusting to 3-4 services approach...
```

### Example 3: Minimal Interruption
```
User: "Performance optimization --mid-input-frequency=minimal"

Claude: ✓ Minimal frequency mode.
        I'll only ask if absolutely critical.

[Debate proceeds automatically unless critical issue]
```

---

## Implementation Guide

### For Claude (Skill Implementation)

**Step 1: Parse flags from user message**
```python
import re

def parse_cli_flags(user_message: str) -> dict:
    flags = {}

    # Check for --no-mid-input
    if re.search(r'--no-mid-input\b', user_message):
        flags['mid_input_enabled'] = False

    # Check for --interactive
    if re.search(r'--interactive\b', user_message):
        flags['interactive_mode'] = True

    # Check for --mid-input-frequency
    freq_match = re.search(r'--mid-input-frequency=(\w+)', user_message)
    if freq_match:
        flags['frequency'] = freq_match.group(1)

    # Check for --min-interval
    interval_match = re.search(r'--min-interval=(\d+)', user_message)
    if interval_match:
        flags['min_interval'] = int(interval_match.group(1))

    return flags
```

**Step 2: Apply flags to session**
```python
session_config = {
    'mid_input_enabled': flags.get('mid_input_enabled', global_settings.enabled),
    'interactive_mode': flags.get('interactive_mode', False),
    'frequency': flags.get('frequency', global_settings.default_frequency),
    'min_interval': flags.get('min_interval', global_settings.min_interval)
}
```

**Step 3: Use during debate**
```python
def should_ask_user(context, session_config):
    # Check if disabled
    if not session_config['mid_input_enabled']:
        return False

    # Check if interactive mode (always ask)
    if session_config['interactive_mode']:
        return True

    # Apply frequency-based heuristic
    threshold = {
        'minimal': 0.3,
        'balanced': 0.5,
        'frequent': 0.7
    }[session_config['frequency']]

    if context.confidence < threshold:
        return check_interval_and_ask(context, session_config)

    return False
```

---

## Testing

### Test Cases

1. **No flags** → Uses global defaults
2. **`--no-mid-input`** → Never asks
3. **`--interactive`** → Asks after every round
4. **`--mid-input-frequency=minimal`** → Rarely asks
5. **`--mid-input-frequency=frequent`** → Often asks
6. **`--min-interval=600`** → Respects 10-min interval
7. **Conflicting flags** → CLI overrides global

### Validation

```bash
# Should work
codex와 토론해줘 --no-mid-input
codex와 토론해줘 --interactive --mid-input-frequency=frequent

# Should error (invalid value)
codex와 토론해줘 --mid-input-frequency=invalid

# Should warn (conflicting)
codex와 토론해줘 --no-mid-input --interactive
# → Warning: Conflicting flags. --interactive takes precedence.
```

---

**Version:** 1.0
**Last Updated:** 2025-10-31
**Supported Flags:** 4 core flags
