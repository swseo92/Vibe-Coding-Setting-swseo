#!/bin/bash
# Install Git hooks from .githooks/ to .git/hooks/
# This script should be run from project root

set -e

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "Installing Git hooks..."

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo -e "${RED}Error: Not a git repository${NC}"
    echo "Please run this script from project root"
    exit 1
fi

# Check if .githooks directory exists
if [ ! -d ".githooks" ]; then
    echo -e "${RED}Error: .githooks directory not found${NC}"
    echo "Expected location: ./.githooks/"
    exit 1
fi

# Create .git/hooks if it doesn't exist
mkdir -p .git/hooks

# Install each hook
INSTALLED=0
SKIPPED=0

for hook in .githooks/*; do
    if [ -f "$hook" ]; then
        HOOK_NAME=$(basename "$hook")

        # Skip README or other documentation files
        if [[ "$HOOK_NAME" == README* ]] || [[ "$HOOK_NAME" == *.md ]]; then
            continue
        fi

        TARGET=".git/hooks/$HOOK_NAME"

        # Check if hook already exists
        if [ -f "$TARGET" ]; then
            echo -e "${YELLOW}Warning: $HOOK_NAME already exists${NC}"
            read -p "Overwrite? (y/n) " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                echo "Skipped $HOOK_NAME"
                SKIPPED=$((SKIPPED + 1))
                continue
            fi
        fi

        # Copy and make executable
        cp "$hook" "$TARGET"
        chmod +x "$TARGET"
        echo -e "${GREEN}Installed: $HOOK_NAME${NC}"
        INSTALLED=$((INSTALLED + 1))
    fi
done

echo ""
echo "Summary:"
echo "- Installed: $INSTALLED hooks"
echo "- Skipped: $SKIPPED hooks"
echo ""
echo -e "${GREEN}Git hooks installation complete${NC}"
echo ""
echo "Installed hooks will run automatically during git operations."
echo "To bypass a hook temporarily, use: git commit --no-verify"
