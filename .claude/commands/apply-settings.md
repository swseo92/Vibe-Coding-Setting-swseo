Apply the current project's .claude configuration to the global user settings.

This command syncs the following from the project to `~/.claude/`:
- **All `.claude/` directory contents** (commands, agents, scripts, personas, etc.)
- Settings (`.claude/settings.local.json` → `~/.claude/settings.json`)
- Speckit commands (`speckit/.claude/commands/`)
- Speckit templates and scripts (`speckit/.specify/`)

Steps:
1. Verify that `.claude/` directory exists in the current project
2. Remove existing `~/.claude/` directory to ensure clean sync
3. Copy entire `.claude/` directory to `~/.claude/`
4. Handle settings file: copy settings.local.json as settings.json (or settings.json if local doesn't exist)
5. Copy speckit commands to global commands
6. Copy speckit .specify folder to global location
7. Display summary of what was synced

First, create a temporary PowerShell script for Windows, then execute the appropriate commands:

```bash
# Detect OS and execute appropriate commands
case "$OSTYPE" in
  msys*|win32*|cygwin*)
    # Windows - Create and execute PowerShell script
    cat > /tmp/apply-settings.ps1 << 'PSEOF'
# Verify project has .claude directory
if (-not (Test-Path '.claude')) {
  Write-Host 'Error: No .claude directory found in current project' -ForegroundColor Red
  exit 1
}

# Copy entire .claude folder contents to global directory
$globalClaude = Join-Path $env:USERPROFILE '.claude'

# Copy each item from .claude to ~/.claude
Get-ChildItem '.claude' -Force | ForEach-Object {
  $targetPath = Join-Path $globalClaude $_.Name
  if (Test-Path $targetPath) {
    Remove-Item -Recurse -Force $targetPath -ErrorAction SilentlyContinue
  }
  Copy-Item -Recurse -Force $_.FullName $globalClaude
}
Write-Host '✓ All .claude contents synced to ~/.claude/' -ForegroundColor Green

# Sync settings
if (Test-Path '.claude/settings.local.json') {
  Copy-Item -Force '.claude/settings.local.json' (Join-Path $globalClaude 'settings.json')
  Write-Host '✓ Settings synced to ~/.claude/settings.json' -ForegroundColor Green
} elseif (Test-Path '.claude/settings.json') {
  Copy-Item -Force '.claude/settings.json' (Join-Path $globalClaude 'settings.json')
  Write-Host '✓ Settings synced to ~/.claude/settings.json' -ForegroundColor Green
}

# Remove settings.local.json from global directory (should only have settings.json)
$globalSettingsLocal = Join-Path $globalClaude 'settings.local.json'
if (Test-Path $globalSettingsLocal) {
  Remove-Item -Force $globalSettingsLocal
  Write-Host '✓ Removed settings.local.json from global directory' -ForegroundColor Green
}

# Sync speckit commands
if (Test-Path 'speckit/.claude/commands') {
  $commandsPath = Join-Path $globalClaude 'commands'
  New-Item -ItemType Directory -Force -Path $commandsPath | Out-Null
  Get-ChildItem 'speckit/.claude/commands/*.md' | ForEach-Object {
    Copy-Item -Force $_.FullName $commandsPath
  }
  Write-Host '✓ Speckit commands synced to ~/.claude/commands/' -ForegroundColor Green
}

# Sync speckit .specify folder
if (Test-Path 'speckit/.specify') {
  $globalSpecify = Join-Path $env:USERPROFILE '.specify'
  if (Test-Path $globalSpecify) { Remove-Item -Recurse -Force $globalSpecify }
  Copy-Item -Recurse -Force 'speckit/.specify' $globalSpecify
  Write-Host '✓ Speckit templates and scripts synced to ~/.specify/' -ForegroundColor Green
}

Write-Host ''
Write-Host 'Global configuration updated successfully!' -ForegroundColor Cyan
Write-Host 'These settings are now available across all projects.' -ForegroundColor Cyan
PSEOF
    powershell -ExecutionPolicy Bypass -File /tmp/apply-settings.ps1
    rm /tmp/apply-settings.ps1
    ;;
  *)
    # Unix/Linux/Mac bash commands
    # Verify project has .claude directory
    if [ ! -d ".claude" ]; then
      echo "Error: No .claude directory found in current project"
      exit 1
    fi

    # Create global .claude directory and copy contents
    mkdir -p ~/.claude

    # Copy each item from .claude to ~/.claude
    for item in .claude/*; do
      if [ -e "$item" ]; then
        basename_item=$(basename "$item")
        rm -rf ~/.claude/"$basename_item"
        cp -r "$item" ~/.claude/
      fi
    done

    # Also copy hidden files
    for item in .claude/.[!.]*; do
      if [ -e "$item" ]; then
        basename_item=$(basename "$item")
        rm -rf ~/.claude/"$basename_item"
        cp -r "$item" ~/.claude/
      fi
    done

    echo "✓ All .claude contents synced to ~/.claude/"

    # Sync settings
    if [ -f ".claude/settings.local.json" ]; then
      cp .claude/settings.local.json ~/.claude/settings.json
      echo "✓ Settings synced to ~/.claude/settings.json"
    elif [ -f ".claude/settings.json" ]; then
      cp .claude/settings.json ~/.claude/settings.json
      echo "✓ Settings synced to ~/.claude/settings.json"
    fi

    # Remove settings.local.json from global directory (should only have settings.json)
    if [ -f ~/.claude/settings.local.json ]; then
      rm ~/.claude/settings.local.json
      echo "✓ Removed settings.local.json from global directory"
    fi

    # Sync speckit commands
    if [ -d "speckit/.claude/commands" ]; then
      mkdir -p ~/.claude/commands
      cp speckit/.claude/commands/*.md ~/.claude/commands/ 2>/dev/null
      echo "✓ Speckit commands synced to ~/.claude/commands/"
    fi

    # Sync speckit .specify folder
    if [ -d "speckit/.specify" ]; then
      rm -rf ~/.specify
      cp -r speckit/.specify ~/.specify
      echo "✓ Speckit templates and scripts synced to ~/.specify/"
    fi

    echo ""
    echo "Global configuration updated successfully!"
    echo "These settings are now available across all projects."
    ;;
esac

# Step 2: Transform MCP configurations for OS-independence
echo ""
echo "🔧 Transforming MCP configurations for OS-independence..."

# Check if templates/common/.mcp.json exists with transform metadata
if [ -f "templates/common/.mcp.json" ]; then
  echo "   Found MCP template with transform metadata"
  echo "   Claude will now analyze and apply transformations to ~/.claude.json"
  echo ""
fi
```

**IMPORTANT**: After file sync completes, you MUST:

1. **Extract current project's Local MCP settings**:
   - Read `~/.claude.json`
   - Find current project path in `projects` section
   - Extract `mcpServers` from current project (if exists)

2. **Read template MCP configuration**:
   - Read `templates/common/.mcp.json`
   - Extract all `mcpServers` entries

3. **Merge MCP configurations**:
   - Combine current project's Local MCP + template MCP
   - Project MCP takes precedence if same server name exists

4. **Apply to global ~/.claude.json**:
   - Add/update root-level `"mcpServers": {}` section (User scope)
   - Merge all collected MCP servers
   - Convert `type: "stdio"` format to proper structure if needed

5. **Handle transformations** (if metadata exists):
   - Look for `_transform` metadata in mcpServers entries
   - For each server with `_transform: "home-relative-path"`:
     - Extract `_targetPath` (e.g., ".playwright-persistent")
     - Extract `_pathOption` (e.g., "--user-data-dir")
     - Generate `node --eval` code using Codex's recommendation
   - Remove `_transform`, `_targetPath`, `_pathOption` metadata from final config

**Transformation template**:
```javascript
const os=require('os');
const path=require('path');
const {spawn}=require('child_process');
const dir=path.join(os.homedir(),'{{TARGET_PATH}}');
const child=spawn('npx',['-y','{{PACKAGE}}','{{PATH_OPTION}}',dir],{stdio:'inherit'});
child.on('exit',code=>process.exit(code));
```

Provide a summary including:
- Confirmation that entire .claude directory was synced
- List of main folders synced (commands, agents, scripts, personas, etc.)
- Number of files in each main folder
- Whether settings were synced (settings.local.json → settings.json)
- Whether speckit templates and scripts were synced
- Path to global configuration directory (~/.claude/ and ~/.specify/)
- **MCP servers propagated to global scope**:
  - List servers from current project's Local MCP (if any)
  - List servers from templates/common/.mcp.json (if any)
  - Total number of global MCP servers configured
  - Note if any transformations were applied
