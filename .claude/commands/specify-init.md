---
description: Initialize .specify from template repository
argument-hint: [repo-url]
allowed-tools: Bash(git:*), Bash(mkdir:*), Bash(rm:*), Bash(python:*)
---

Initialize .specify directory from template repository to current project:

1. Create temporary directory for cloning
2. Clone template repository with sparse checkout (only speckit/.specify)
3. Copy speckit/.specify to current project root as .specify
4. Clean up temporary directory

Repository URL: $1 (defaults to https://github.com/swseo92/Vibe-Coding-Setting-swseo.git)

Execute the following commands:
!mkdir -p .tmp-specify-clone
!git clone --depth 1 --filter=blob:none --sparse "${1:-https://github.com/swseo92/Vibe-Coding-Setting-swseo.git}" .tmp-specify-clone
!cd .tmp-specify-clone && git sparse-checkout set speckit/.specify
!python -c "import shutil; import os; src = os.path.join('.tmp-specify-clone', 'speckit', '.specify'); dst = '.specify'; shutil.copytree(src, dst, dirs_exist_ok=True) if os.path.exists(src) else print(f'Error: {src} not found')"
!rm -rf .tmp-specify-clone

Provide a summary of what was copied:
- Source: Template repository's speckit/.specify
- Destination: Current project's .specify
- Contents: All directories (memory/, scripts/, templates/) and files
- Status: Check if .specify directory was successfully created
