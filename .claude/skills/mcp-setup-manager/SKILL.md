---
name: mcp-setup-manager
description: Configure MCP (Model Context Protocol) servers in Claude Code with proper scope selection (local vs project), validation, and troubleshooting. Use this skill when users request adding MCP servers, when MCP servers aren't showing in lists, or when setting up team-shared MCP configurations.
---

# MCP Setup Manager

## Overview

This skill provides a systematic workflow for configuring MCP servers in Claude Code, ensuring proper setup through validation and troubleshooting. MCP servers extend Claude Code's capabilities by connecting to external tools and services.

The skill addresses common pitfalls:
- Choosing between local (personal) and project (team-shared) scope
- Ensuring MCP servers appear in `claude mcp list`
- Configuring project-scoped servers to be git-committable
- Validating setup with proper verification steps

## Workflow Decision Tree

Start by determining the appropriate scope:

**Use Local Scope when:**
- Personal tool preferences (e.g., individual developer's Playwright setup)
- Not shared with team members
- Configuration stored in `~/.claude.json`

**Use Project Scope when:**
- Team collaboration required
- Configuration should be version-controlled
- Same MCP tools needed across team
- Configuration stored in `.mcp.json` at project root

## Adding MCP Servers

### Local Scope Setup

**Step 1: Add the MCP server**

For HTTP/SSE servers:
```bash
claude mcp add --transport http <server-name> <url>
```

For stdio servers:
```bash
claude mcp add --transport stdio <server-name> -- <command> [args]
```

**Examples:**
```bash
# HTTP server
claude mcp add --transport http linear-server https://mcp.linear.app/mcp

# stdio server
claude mcp add --transport stdio playwright -- npx -y @playwright/mcp
```

**Step 2: Validate (REQUIRED)**
```bash
claude mcp list
```

Verify the server appears in the list. If not, see Troubleshooting section.

**Result:**
- Configuration saved to `~/.claude.json`
- Server available immediately in current project
- Not shared with team or version control

### Project Scope Setup

**Step 1: Add the MCP server with --scope project**

```bash
claude mcp add --transport http --scope project <server-name> <url>
```

**Example:**
```bash
claude mcp add --transport http --scope project linear-server https://mcp.linear.app/mcp
```

**Step 2: Enable in project settings**

Create or update `.claude/settings.json`:
```json
{
  "enabledMcpjsonServers": ["<server-name>"]
}
```

**Example:**
```json
{
  "enabledMcpjsonServers": ["linear-server"]
}
```

**Step 3: Validate (REQUIRED)**
```bash
claude mcp list
```

Verify the server appears in the list. If not, see Troubleshooting section.

**Step 4: Commit to version control**
```bash
git add .mcp.json .claude/settings.json
git commit -m "Add <server-name> MCP configuration"
```

**Result:**
- `.mcp.json` created at project root
- `.claude/settings.json` enables the server
- Configuration shared via git
- Team members get same MCP setup after clone

## Validation

**ALWAYS validate MCP setup immediately after configuration.**

### Primary Validation
```bash
claude mcp list
```

Expected output shows server name, transport type, and status:
```
linear-server: https://mcp.linear.app/mcp (HTTP) - ⚠ Needs authentication
playwright: npx -y @playwright/mcp - ✓ Connected
```

### Detailed Validation
```bash
claude mcp get <server-name>
```

Shows detailed information including scope, status, and configuration.

**Example:**
```bash
claude mcp get linear-server
```

Output:
```
linear-server:
  Scope: Project config (shared via .mcp.json)
  Status: ⚠ Needs authentication
  Type: http
  URL: https://mcp.linear.app/mcp
```

## Troubleshooting

### Server Not Appearing in `claude mcp list`

**For Project Scope:**

1. Verify `.mcp.json` exists at project root:
   ```bash
   cat .mcp.json
   ```

2. Check `.claude/settings.json` includes server in `enabledMcpjsonServers`:
   ```bash
   cat .claude/settings.json
   ```

3. Ensure server name matches exactly between `.mcp.json` and `enabledMcpjsonServers`

4. Use `claude mcp get <server-name>` to verify configuration exists

**For Local Scope:**

1. Verify command syntax included all required flags
2. Check `~/.claude.json` for the project path entry
3. Re-run add command if needed

### Common Issues

**Issue: `claude mcp list` shows "No MCP servers configured"**
- **Project scope**: Missing `.claude/settings.json` or `enabledMcpjsonServers` not configured
- **Local scope**: Server not added to current project path in `~/.claude.json`

**Issue: Server exists in multiple scopes**
```bash
# Remove from specific scope
claude mcp remove <server-name> -s local
claude mcp remove <server-name> -s project
```

**Issue: Authentication needed**
- Run `/mcp` command in Claude Code session
- Follow authentication prompts
- Re-validate with `claude mcp list`

## Advanced Configuration

### Environment Variables

Add environment variables to MCP server configuration:

```bash
claude mcp add --transport stdio --env API_KEY=value server-name -- command
```

### Custom Headers (HTTP servers)

Add authentication headers:

```bash
claude mcp add --transport http --header "Authorization: Bearer token" server-name url
```

### Alternative: Using .env Files

For project scope with sensitive credentials, reference environment variables in `.mcp.json`:

```json
{
  "mcpServers": {
    "server-name": {
      "type": "http",
      "url": "https://example.com",
      "env": {
        "API_KEY": "${MY_API_KEY}"
      }
    }
  }
}
```

Then create `.env` (git-ignored) with actual values:
```
MY_API_KEY=actual_secret_value
```

## Resources

### references/

**scope-comparison.md** - Detailed comparison of local vs project scope with decision matrix

**common-mcp-servers.md** - List of popular MCP servers with installation commands
