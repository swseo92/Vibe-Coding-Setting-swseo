Apply the current project's .claude configuration to the global user settings.

This command syncs the following from the project to `~/.claude/`:
- Commands (`.claude/commands/`)
- Agents (`.claude/agents/`)
- Scripts (`.claude/scripts/`)
- Settings (`.claude/settings.local.json` → `~/.claude/settings.json`)
- Speckit commands (`speckit/.claude/commands/`)
- Speckit templates and scripts (`speckit/.specify/`)

Steps:
1. Verify that `.claude/` directory exists in the current project
2. Create `~/.claude/` directory if it doesn't exist
3. Copy commands, agents, and scripts directories recursively
4. Copy settings.local.json to global settings.json
5. Copy speckit commands to global commands
6. Copy speckit .specify folder to global location
7. Display summary of what was synced

Execute the following commands:
```bash
# Verify project has .claude directory
if [ ! -d ".claude" ]; then
  echo "Error: No .claude directory found in current project"
  exit 1
fi

# Create global .claude directory if needed
mkdir -p ~/.claude

# Sync commands
if [ -d ".claude/commands" ]; then
  cp -r .claude/commands ~/.claude/
  echo "✓ Commands synced to ~/.claude/commands/"
fi

# Sync agents
if [ -d ".claude/agents" ]; then
  cp -r .claude/agents ~/.claude/
  echo "✓ Agents synced to ~/.claude/agents/"
fi

# Sync scripts
if [ -d ".claude/scripts" ]; then
  cp -r .claude/scripts ~/.claude/
  echo "✓ Scripts synced to ~/.claude/scripts/"
fi

# Sync settings
if [ -f ".claude/settings.local.json" ]; then
  cp .claude/settings.local.json ~/.claude/settings.json
  echo "✓ Settings synced to ~/.claude/settings.json"
elif [ -f ".claude/settings.json" ]; then
  cp .claude/settings.json ~/.claude/settings.json
  echo "✓ Settings synced to ~/.claude/settings.json"
fi

# Sync speckit commands
if [ -d "speckit/.claude/commands" ]; then
  mkdir -p ~/.claude/commands
  cp speckit/.claude/commands/*.md ~/.claude/commands/ 2>/dev/null
  echo "✓ Speckit commands synced to ~/.claude/commands/"
fi

# Sync speckit .specify folder
if [ -d "speckit/.specify" ]; then
  cp -r speckit/.specify ~/.specify
  echo "✓ Speckit templates and scripts synced to ~/.specify/"
fi

echo ""
echo "Global configuration updated successfully!"
echo "These settings are now available across all projects."
```

Provide a summary including:
- Number of commands synced (including speckit commands)
- Number of agents synced
- Whether scripts were synced
- Whether settings were synced
- Whether speckit templates and scripts were synced
- Path to global configuration directory (~/.claude/ and ~/.specify/)
