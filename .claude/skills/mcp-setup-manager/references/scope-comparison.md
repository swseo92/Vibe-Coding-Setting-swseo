# MCP Scope Comparison

## Overview

Claude Code supports three scopes for MCP server configuration. Understanding the differences is crucial for proper setup.

## Scope Comparison Table

| Feature | Local Scope | Project Scope | User Scope |
|---------|-------------|---------------|------------|
| **Storage Location** | `~/.claude.json` (per-project section) | `.mcp.json` (project root) | `~/.claude.json` (global section) |
| **Git Tracked** | ❌ No | ✅ Yes | ❌ No |
| **Team Sharing** | ❌ Individual only | ✅ All team members | ❌ Individual only |
| **Requires Approval** | ❌ No | ✅ Yes (enabledMcpjsonServers) | ❌ No |
| **Use Case** | Personal project preferences | Team collaboration | Cross-project personal tools |
| **CLI Flag** | (default) or `-s local` | `-s project` or `--scope project` | `-s user` or `--scope user` |

## Decision Matrix

### Choose Local Scope When:
- ✅ Personal tool that other team members may not need
- ✅ Experimenting with MCP servers
- ✅ Project-specific but not shared
- ✅ Quick setup without git commits
- ❌ NOT for team collaboration

**Examples:**
- Personal Playwright instance for testing
- Development-only debugging tools
- Individual preferences that differ from team

### Choose Project Scope When:
- ✅ Entire team needs same MCP tools
- ✅ Configuration should be version controlled
- ✅ New team members should get auto-configured
- ✅ Standardized development environment
- ❌ NOT for personal tools or experiments

**Examples:**
- Linear integration for issue tracking (team-wide)
- Shared database query tools
- Team-standard linting/formatting MCP servers

### Choose User Scope When:
- ✅ Same tool needed across multiple projects
- ✅ Personal productivity tools
- ✅ Cross-project standardization (personal)
- ❌ NOT for team sharing

**Examples:**
- Personal file management MCP
- Cross-project note-taking tools
- Individual workflow automation

## Configuration File Details

### Local Scope: `~/.claude.json`
```json
{
  "projects": {
    "/path/to/project": {
      "mcpServers": {
        "server-name": {
          "type": "http",
          "url": "https://example.com"
        }
      }
    }
  }
}
```

### Project Scope: `.mcp.json`
```json
{
  "mcpServers": {
    "server-name": {
      "type": "http",
      "url": "https://example.com"
    }
  }
}
```

**IMPORTANT:** Project scope also requires `.claude/settings.json`:
```json
{
  "enabledMcpjsonServers": ["server-name"]
}
```

### User Scope: `~/.claude.json`
```json
{
  "mcpServers": {
    "server-name": {
      "type": "http",
      "url": "https://example.com"
    }
  }
}
```

## Common Mistakes

### Mistake 1: Project Scope Without enabledMcpjsonServers
**Problem:** Added MCP server with `--scope project` but didn't create `.claude/settings.json`

**Symptom:** `claude mcp get server-name` shows config exists, but `claude mcp list` shows nothing

**Solution:** Create `.claude/settings.json` with `enabledMcpjsonServers` array

### Mistake 2: Expecting Local Scope to Share
**Problem:** Added MCP server locally, expecting team to have it after git pull

**Symptom:** Team members don't have MCP server configuration

**Solution:** Remove from local scope, re-add with `--scope project`

### Mistake 3: Committing Secrets in Project Scope
**Problem:** Added API keys directly in `.mcp.json` and committed to git

**Symptom:** Secrets exposed in version control

**Solution:** Use environment variable references in `.mcp.json`, store actual values in git-ignored `.env`

## Switching Between Scopes

To move a server from one scope to another:

```bash
# Remove from current scope
claude mcp remove server-name -s local

# Add to new scope
claude mcp add --transport http --scope project server-name https://example.com
```

**Note:** Server names can exist in multiple scopes simultaneously. Use `-s` flag to specify which to remove.
