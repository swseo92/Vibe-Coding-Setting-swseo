# Common MCP Servers

## Popular MCP Servers and Installation Commands

### Project Management & Issue Tracking

#### Linear
**Purpose:** Issue tracking, project management

**Local Scope:**
```bash
claude mcp add --transport http linear-server https://mcp.linear.app/mcp
```

**Project Scope:**
```bash
claude mcp add --transport http --scope project linear-server https://mcp.linear.app/mcp
```

**Authentication:** OAuth or API key via `/mcp` command

**Capabilities:**
- Create, read, update issues
- Query projects and teams
- Manage issue status and assignments

---

### Browser Automation

#### Microsoft Playwright
**Purpose:** Browser automation, web scraping, testing

**Local Scope:**
```bash
claude mcp add --transport stdio playwright -- npx -y @playwright/mcp
```

**Project Scope:**
```bash
claude mcp add --transport stdio --scope project playwright -- npx -y @playwright/mcp
```

**Authentication:** None required

**Capabilities:**
- Navigate web pages
- Fill forms and click elements
- Take screenshots
- Execute JavaScript
- Extract data from websites

---

### File & Data Management

#### Filesystem
**Purpose:** Advanced file operations

**Local Scope:**
```bash
claude mcp add --transport stdio filesystem -- npx -y @modelcontextprotocol/server-filesystem /path/to/allowed/directory
```

**Note:** Requires specifying allowed directories for security

**Capabilities:**
- Read/write files outside working directory
- Directory traversal
- Batch file operations

---

### Development Tools

#### GitHub
**Purpose:** GitHub repository management

**Local Scope:**
```bash
claude mcp add --transport stdio github -- npx -y @modelcontextprotocol/server-github
```

**Project Scope:**
```bash
claude mcp add --transport stdio --scope project github -- npx -y @modelcontextprotocol/server-github
```

**Authentication:** GitHub token via environment variable

**Capabilities:**
- Create issues and PRs
- Search repositories
- Read file contents
- Manage branches

---

### Database Tools

#### PostgreSQL
**Purpose:** Database queries and management

**Local Scope:**
```bash
claude mcp add --transport stdio postgres -- npx -y @modelcontextprotocol/server-postgres postgresql://connection-string
```

**Authentication:** Connection string with credentials

**Capabilities:**
- Execute SQL queries
- Schema inspection
- Data analysis

---

### Cloud Platforms

#### AWS KB Retrieval
**Purpose:** Retrieve information from AWS Knowledge Bases

**Local Scope:**
```bash
claude mcp add --transport stdio aws-kb -- npx -y @modelcontextprotocol/server-aws-kb-retrieval
```

**Authentication:** AWS credentials

**Capabilities:**
- Query knowledge bases
- Retrieve documents
- Semantic search

---

## Installation Best Practices

### For stdio Servers

Always use `-y` flag with npx to avoid prompts:
```bash
-- npx -y package-name
```

### For Project Scope

Remember two-step process:
1. Add server with `--scope project`
2. Enable in `.claude/settings.json`

```json
{
  "enabledMcpjsonServers": ["server-name"]
}
```

### With Environment Variables

```bash
claude mcp add --transport stdio --env API_KEY=value server -- command
```

### With Custom Headers (HTTP)

```bash
claude mcp add --transport http --header "Authorization: Bearer token" server url
```

## Verification

After installing ANY MCP server, always verify:

```bash
# Check if server appears
claude mcp list

# Check server details
claude mcp get server-name
```

## Finding More MCP Servers

**Official Registry:**
- https://github.com/modelcontextprotocol/servers

**Community Servers:**
- Search GitHub for "mcp-server"
- NPM packages: `@modelcontextprotocol/server-*`

**Creating Custom Servers:**
- See MCP documentation: https://modelcontextprotocol.io
- Use TypeScript or Python SDK
