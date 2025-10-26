---
name: speckit-manager
description: Fetch the latest speckit library from GitHub (github/spec-kit repository) and translate to Korean. Use ONLY when user explicitly mentions fetching/pulling speckit FROM GITHUB or updating the speckit LIBRARY itself, not workspace settings. Triggers include "GitHub에서 speckit 가져와줘", "fetch speckit from GitHub", "pull latest spec-kit", "update speckit library from source". Do NOT use for general workspace sync (that is /sync-workspace).
---

# Speckit Manager

## Overview

Manage speckit library updates and Korean translations automatically. This skill helps maintain a Korean-localized version of GitHub's spec-kit by fetching the latest updates and preserving Korean translations across versions.

## When to Use

Use this skill when:

- Updating speckit to the latest version from GitHub
- Syncing Korean-translated speckit files with the workspace
- The user mentions "speckit 업데이트" or "update speckit"
- After significant speckit releases on GitHub

## Workflow

### Phase 1: Update from GitHub

To update speckit from GitHub:

1. Run the update script:
   ```bash
   python .claude/skills/speckit-manager/scripts/update_speckit.py
   ```

2. The script will:
   - Clone or pull the latest spec-kit from `github/spec-kit`
   - Copy English command files to `speckit/.claude/commands/`
   - Copy English template files to `speckit/.specify/templates/`
   - Display the latest commit hash

3. Review the copied files:
   ```bash
   ls -la speckit/.claude/commands/
   ls -la speckit/.specify/templates/
   ```

**Important**: The script only fetches English originals. Translation is a separate step.

### Phase 2: Translate to Korean

After fetching the latest English files, translate them to Korean:

1. **Compare with existing Korean versions**:
   - Existing Korean commands: `.claude/commands/` (will be copied to `~/.claude/commands/` via `/apply-settings`)
   - Existing Korean templates: `.specify/templates/`
   - New English originals: `speckit/.claude/commands/`, `speckit/.specify/templates/`

2. **Identify what changed**:
   ```bash
   # Compare a specific command file
   diff speckit/.claude/commands/speckit.specify.md .claude/commands/speckit.specify.md || echo "Files differ"
   ```

3. **Translate updated files**:
   For each file that changed or is new:
   - Read the English version from `speckit/`
   - Compare with the existing Korean version (if exists)
   - Translate the new or changed content to Korean
   - Maintain the same structure and formatting
   - Preserve all technical terms, code blocks, and file paths exactly

4. **Save Korean translations**:
   - Commands → No Korean commands in `.claude/commands/` yet (they're in global `~/.claude/commands/`)
   - Templates → `.specify/templates/` (already Korean in this workspace)

**Translation Guidelines**:
- Keep technical terms in English: "spec", "plan", "tasks", "constitution"
- Translate instructions and descriptions to Korean
- Preserve all YAML frontmatter, code blocks, and file paths
- Maintain markdown formatting exactly
- Keep `$ARGUMENTS` and other variables unchanged

### Phase 3: Apply to Global Settings

After translation:

1. **Copy Korean commands to workspace** (if not already there):
   ```bash
   # Speckit commands are typically managed globally
   # They will be applied via /apply-settings
   ```

2. **Apply to global settings**:
   ```
   /apply-settings
   ```

   This copies:
   - `.claude/commands/speckit.*.md` → `~/.claude/commands/`
   - `.specify/templates/*.md` → `~/.specify/templates/`

3. **Verify the update**:
   ```bash
   ls -la ~/.claude/commands/speckit.*
   ls -la ~/.specify/templates/
   ```

### Phase 4: Cleanup

1. **Remove temporary English files** (optional):
   ```bash
   rm -rf speckit/
   ```

   Or keep them for reference and future comparisons.

2. **Commit changes**:
   ```bash
   git add .specify/templates/
   git commit -m "Update speckit templates to latest version (Korean)"
   git push
   ```

## Advanced Usage

### Update Specific Files Only

To update only commands:
```bash
python .claude/skills/speckit-manager/scripts/update_speckit.py
# Then manually translate only the command files
```

### Keep Temp Directory for Reference

To keep the temporary directory:
```bash
python .claude/skills/speckit-manager/scripts/update_speckit.py --no-cleanup
# Temp files remain in tmp/speckit-update/
```

### Check Speckit Version

To see the current speckit version:
```bash
cd tmp/speckit-update/spec-kit
git log -1 --oneline
```

## Translation Workflow Tips

When translating speckit files:

1. **Use Claude Code for translation**:
   - Open the English file
   - Open the existing Korean file (if exists)
   - Ask: "Translate this speckit file to Korean, maintaining the structure"

2. **Batch translation**:
   - Translate similar files together
   - Templates: spec-template, plan-template, tasks-template
   - Commands: speckit.specify, speckit.plan, speckit.tasks, etc.

3. **Quality checks**:
   - Verify all sections are translated
   - Ensure code blocks are unchanged
   - Check that file paths are preserved
   - Confirm YAML frontmatter is intact

## File Locations Reference

| File Type | English Original | Korean Translation | Global Location |
|-----------|------------------|-------------------|-----------------|
| Commands | `speckit/.claude/commands/speckit.*.md` | `~/.claude/commands/speckit.*.md` (via /apply-settings) | `~/.claude/commands/` |
| Templates | `speckit/.specify/templates/*.md` | `.specify/templates/*.md` | `~/.specify/templates/` (via /apply-settings) |
| Scripts | `speckit/.specify/scripts/` | `.specify/scripts/` | `~/.specify/scripts/` (via /apply-settings) |

## Troubleshooting

**Error: "CLAUDE.md not found"**
- Run the script from the Vibe-Coding-Setting workspace root

**Error: "Git command failed"**
- Check internet connection
- Verify git is installed and configured

**Files not translating correctly**
- Ensure you're comparing the right files
- Check that Korean versions exist in `.specify/templates/`
- Verify global commands were applied via `/apply-settings`

**Global settings not updating**
- Run `/apply-settings` after translation
- Check `~/.claude/` permissions
- Verify files are in the correct locations

## Resources

### scripts/update_speckit.py

Python script that automates the speckit update process:
- Clones or pulls the latest spec-kit from GitHub
- Copies English command files to `speckit/.claude/commands/`
- Copies English template files to `speckit/.specify/templates/`
- Displays the latest commit hash for reference

Usage:
```bash
python .claude/skills/speckit-manager/scripts/update_speckit.py [OPTIONS]

Options:
  --workspace PATH    Workspace root path (default: current directory)
  --no-cleanup        Keep temporary directory after update
```

The script validates that it's running in a Vibe-Coding-Setting workspace by checking for `CLAUDE.md`.
