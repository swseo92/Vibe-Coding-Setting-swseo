# OpenAI Judge MCP Server

MCP (Model Context Protocol) server that uses OpenAI models as LLM judges for code review.

## Features

- **Code Review as LLM Judge**: Get objective code quality scores (0-100)
- **Version Comparison**: Compare code versions and assess improvements
- **Improvement Suggestions**: Get specific code refactoring recommendations
- **Multiple Models**: Support for GPT-4 Turbo, GPT-3.5 Turbo, o1

## Installation

### Prerequisites

- Python 3.10+
- OpenAI API key ([Get one here](https://platform.openai.com/api-keys))
- `uv` package manager (recommended) or `pip`

### Setup

1. **Install dependencies:**

```bash
cd mcp-servers/openai-judge
uv sync
```

2. **Configure API key:**

```bash
cp .env.example .env
# Edit .env and add your OpenAI API key
```

3. **Add to Claude Code MCP configuration:**

Add this to your project's `.mcp.json`:

```json
{
  "mcpServers": {
    "openai-judge": {
      "command": "uv",
      "args": [
        "--directory",
        "C:\\path\\to\\mcp-servers\\openai-judge",
        "run",
        "server.py"
      ]
    }
  }
}
```

**Important:** Replace `C:\\path\\to\\mcp-servers\\openai-judge` with the actual absolute path.

4. **Restart Claude Code** to load the MCP server

## Available Tools

### 1. `review_code`

Review code and get scored assessment.

**Parameters:**
- `code` (required): Code to review (can be diff or full code)
- `context` (optional): Additional context (file path, purpose)
- `model` (optional): OpenAI model (default: `gpt-4-turbo-preview`)
- `review_aspects` (optional): Aspects to review (default: `bugs,security,performance,readability,best-practices`)

**Returns:**
```json
{
  "overall_score": 85,
  "severity_counts": {
    "critical": 0,
    "warning": 2,
    "suggestion": 5
  },
  "issues": [
    {
      "severity": "warning",
      "aspect": "readability",
      "line": 15,
      "description": "Function name is too generic",
      "suggestion": "Use more descriptive name like 'validate_user_input'"
    }
  ],
  "recommendation": "commit",
  "summary": "Code is production-ready with minor improvements suggested"
}
```

### 2. `compare_code_versions`

Compare original and modified code versions.

**Parameters:**
- `original_code` (required): Original code
- `modified_code` (required): Modified code
- `context` (optional): Additional context
- `model` (optional): OpenAI model

**Returns:**
```json
{
  "is_improvement": true,
  "improvement_score": 35,
  "improvements": [
    "Added type hints",
    "Improved error handling"
  ],
  "regressions": [
    "Increased complexity slightly"
  ],
  "summary": "Overall improvement with better type safety"
}
```

### 3. `suggest_improvements`

Get specific code improvement suggestions.

**Parameters:**
- `code` (required): Code to improve
- `issues` (optional): Known issues to address
- `context` (optional): Additional context
- `model` (optional): OpenAI model

**Returns:**
```json
{
  "improved_code": "def validate_input(data: str) -> bool:\n    ...",
  "changes_made": [
    "Added type hints",
    "Extracted validation logic",
    "Added docstring"
  ],
  "explanation": "Improvements enhance type safety and maintainability"
}
```

## Usage Examples

### Example 1: Basic Code Review

```python
# In Claude Code, use the MCP tool:
review_code(
    code='''
def get_user(id):
    return db.query(f"SELECT * FROM users WHERE id = {id}")
''',
    context="File: user_service.py - Get user by ID"
)
```

**Result:**
- Overall Score: 30/100
- Critical Issues: 1 (SQL injection)
- Recommendation: needs_work

### Example 2: Compare Git Diff

```python
# Get git diff
original = open('original.py').read()
modified = open('modified.py').read()

compare_code_versions(
    original_code=original,
    modified_code=modified,
    context="Refactored user authentication"
)
```

### Example 3: Get Improvements

```python
suggest_improvements(
    code='def process(data): return data.upper()',
    issues='Missing type hints, no error handling',
    context='String processing function'
)
```

## Supported Models

| Model | Best For | Cost | Speed |
|-------|----------|------|-------|
| `gpt-4-turbo-preview` | Comprehensive reviews | $$$ | Medium |
| `gpt-3.5-turbo` | Quick reviews | $ | Fast |
| `o1-preview` | Complex analysis | $$$$ | Slow |

## Cost Estimation

Approximate costs per review (as of 2025):

- **GPT-4 Turbo**: ~$0.01-0.05 per review
- **GPT-3.5 Turbo**: ~$0.001-0.005 per review
- **o1**: ~$0.05-0.20 per review

## Integration with Skill

This MCP server is designed to work with the `openai-code-judge` skill for seamless code review workflows.

See: `.claude/skills/openai-code-judge/`

## Troubleshooting

### Error: "OpenAI API key not found"

- Check `.env` file exists with valid `OPENAI_API_KEY`
- Ensure `.env` is in the same directory as `server.py`

### Error: "Invalid model name"

- Use one of: `gpt-4-turbo-preview`, `gpt-3.5-turbo`, `o1-preview`
- Check [OpenAI docs](https://platform.openai.com/docs/models) for latest models

### MCP server not loading

- Verify absolute path in `.mcp.json`
- Restart Claude Code after configuration changes
- Check `uv sync` completed successfully

## Development

### Run server directly:

```bash
uv run server.py
```

### Test with MCP inspector:

```bash
npx @modelcontextprotocol/inspector uv --directory . run server.py
```

## Security Notes

- **Never commit `.env` file** (contains API key)
- API keys are loaded from environment, not hardcoded
- Review OpenAI's [usage policies](https://openai.com/policies/usage-policies)
- Monitor API usage to avoid unexpected costs

## License

MIT

## Related Resources

- [MCP Documentation](https://modelcontextprotocol.io/)
- [FastMCP Guide](https://github.com/jlowin/fastmcp)
- [OpenAI API Reference](https://platform.openai.com/docs/api-reference)
