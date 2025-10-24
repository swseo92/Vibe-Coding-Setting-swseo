#!/bin/bash
set -e

# init-workspace.sh - Initialize workspace from language template
# Usage: init-workspace.sh <language> [additional-requirements]

LANGUAGE="$1"
ADDITIONAL_REQUIREMENTS="${@:2}"

if [ -z "$LANGUAGE" ]; then
    echo "Error: Language not specified"
    echo "Usage: init-workspace.sh <language> [additional-requirements]"
    echo ""
    echo "Available languages:"
    echo "  - python"
    echo "  - javascript (coming soon)"
    exit 1
fi

echo "Initializing workspace for language: $LANGUAGE"

# Create temporary directory
TEMP_DIR=$(mktemp -d)
echo "Created temporary directory: $TEMP_DIR"

# Clone the settings repository
echo "Cloning Vibe-Coding-Setting-swseo repository..."
git clone https://github.com/swseo92/Vibe-Coding-Setting-swseo.git "$TEMP_DIR" 2>&1 | grep -v "Cloning into"

# Check if language template exists
TEMPLATE_PATH="$TEMP_DIR/templates/$LANGUAGE"
if [ ! -d "$TEMPLATE_PATH" ]; then
    echo "Error: Template for '$LANGUAGE' not found"
    echo ""
    echo "Available templates:"
    ls -1 "$TEMP_DIR/templates" | grep -v "^common$"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Copy common files first (hidden files included)
COMMON_PATH="$TEMP_DIR/templates/common"
if [ -d "$COMMON_PATH" ]; then
    echo "Copying common files..."
    cp -r "$COMMON_PATH/." .
    echo "✓ Common files copied (.specify/, .mcp.json)"
fi

# Copy language-specific template files (hidden files included)
echo "Copying $LANGUAGE template files..."
cp -r "$TEMPLATE_PATH/." .
echo "✓ Template files copied successfully"

# Clean up temporary directory
rm -rf "$TEMP_DIR"
echo "✓ Cleanup completed"

# Get project name from current directory
PROJECT_NAME=$(basename "$(pwd)")
echo ""
echo "Project name detected: $PROJECT_NAME"

# Language-specific post-processing
case "$LANGUAGE" in
    python)
        # Update project name in Python files
        if [ -d "src/myproject" ]; then
            mv "src/myproject" "src/$PROJECT_NAME"
            echo "✓ Renamed src/myproject → src/$PROJECT_NAME"
        fi

        # Update pyproject.toml
        if [ -f "pyproject.toml" ]; then
            sed -i.bak "s/name = \"myproject\"/name = \"$PROJECT_NAME\"/" pyproject.toml
            sed -i.bak "s/packages = \\[{include = \"myproject\"/packages = [{include = \"$PROJECT_NAME\"/" pyproject.toml
            rm -f pyproject.toml.bak
            echo "✓ Updated pyproject.toml with project name"
        fi
        ;;
    javascript)
        # Future: Update package.json
        echo "✓ JavaScript template applied"
        ;;
esac

# Display success message
echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║          ✅ Workspace Initialized Successfully             ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "Language:      $LANGUAGE"
echo "Project Name:  $PROJECT_NAME"
echo ""
echo "Files Created:"

# List key files
if [ -d ".specify" ]; then
    echo "  ✓ .specify/          (Speckit templates & scripts)"
fi
if [ -f ".mcp.json" ]; then
    echo "  ✓ .mcp.json          (MCP server configuration)"
fi

case "$LANGUAGE" in
    python)
        echo "  ✓ pyproject.toml     (uv package configuration)"
        echo "  ✓ pytest.ini         (pytest configuration)"
        echo "  ✓ src/$PROJECT_NAME/ (main package)"
        echo "  ✓ tests/             (unit/integration/e2e)"
        echo "  ✓ docs/              (documentation)"
        echo "  ✓ .github/workflows/ (CI/CD)"
        echo "  ✓ .pre-commit-config.yaml"
        ;;
esac

echo ""
echo "Next Steps:"
echo ""

case "$LANGUAGE" in
    python)
        echo "1. Install dependencies:"
        echo "   $ uv sync"
        echo ""
        echo "2. Install pre-commit hooks:"
        echo "   $ uv run pre-commit install"
        echo ""
        echo "3. Run tests:"
        echo "   $ uv run pytest"
        echo ""
        ;;
esac

echo "4. Initialize git (if needed):"
echo "   $ git init"
echo "   $ git add ."
echo "   $ git commit -m \"Initial commit from template\""
echo ""
echo "5. Review and customize:"
echo "   - Update README.md with project details"
echo "   - Configure .env (see .env.example)"
echo "   - Review docs/testing_guidelines.md"
echo ""

if [ -n "$ADDITIONAL_REQUIREMENTS" ]; then
    echo "Additional requirements noted: $ADDITIONAL_REQUIREMENTS"
    echo "Please handle these manually or ask Claude Code for help."
    echo ""
fi

echo "Happy coding! 🚀"
