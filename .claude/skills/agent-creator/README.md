# Agent Creator Skill

A comprehensive skill for creating, validating, and managing Claude Code subagents.

## Overview

The `agent-creator` skill helps you design and implement effective Claude Code subagents with specialized expertise, custom workflows, and appropriate tool access. It provides interactive guidance, templates, and validation tools to ensure your agents follow best practices.

## Features

- **Interactive Agent Creation**: Step-by-step guidance for designing agents
- **Template Library**: Pre-built templates for common agent types
- **Validation Tools**: Automated checking of agent structure and best practices
- **Initialization Scripts**: Quick generation of agent boilerplate

## Structure

```
.claude/skills/agent-creator/
├── SKILL.md                          # Main skill definition
├── README.md                         # This file
├── scripts/
│   ├── init_agent.py                # Agent initialization script
│   └── validate_agent.py            # Agent validation script
└── templates/
    ├── basic-agent-template.md      # Basic agent template
    ├── code-generator-template.md   # Template for code generation agents
    └── analyzer-template.md         # Template for analysis/review agents
```

## Usage

### Creating an Agent with the Skill

Simply ask Claude Code:

```
"I need an agent that reviews API documentation for consistency."
```

Claude will automatically use the agent-creator skill to:
1. Ask clarifying questions about your needs
2. Suggest an agent design
3. Generate the agent file
4. Validate the structure
5. Provide usage examples

### Using the Scripts Directly

#### Initialize a New Agent

```bash
python .claude/skills/agent-creator/scripts/init_agent.py \
    "my-agent-name" \
    "Description of when to use this agent" \
    --tools "Read, Write, Edit" \
    --model sonnet \
    --output ".claude/agents/my-agent-name.md"
```

**Options:**
- `-o, --output`: Output path (default: `.claude/agents/NAME.md`)
- `-t, --tools`: Comma-separated tool list
- `-m, --model`: Model to use (`haiku` or `sonnet`)
- `-c, --color`: Agent color (e.g., `blue`, `green`, `purple`)
- `-i, --interactive`: Interactive mode with detailed prompts

#### Validate an Existing Agent

```bash
python .claude/skills/agent-creator/scripts/validate_agent.py \
    ".claude/agents/my-agent.md"
```

The validator checks:
- YAML frontmatter syntax
- Required fields (name, description)
- Name format (lowercase, hyphens only)
- Filename matches agent name
- Tool list appropriateness
- System prompt structure
- Best practice adherence

## Agent Templates

### Basic Agent Template

Use for simple, general-purpose agents.

**Best for:**
- Documentation agents
- Simple automation tasks
- Lightweight helpers

### Code Generator Template

Use for agents that create new code.

**Best for:**
- Component generators
- Boilerplate creators
- API endpoint scaffolding
- Test file generation

**Characteristics:**
- Model: sonnet (complex reasoning)
- Tools: Read, Write, Edit, Glob, Grep
- Focus: Code structure, best practices, testing

### Analyzer Template

Use for agents that review or analyze existing code.

**Best for:**
- Code reviewers
- Security auditors
- Performance analyzers
- Documentation reviewers

**Characteristics:**
- Model: sonnet (deep analysis)
- Tools: Read, Glob, Grep (no Write/Edit)
- Focus: Patterns, issues, recommendations

## Best Practices

### Agent Design

1. **Single Responsibility**: Each agent should do one thing well
2. **Clear Triggers**: Description should clearly indicate when to use
3. **Minimal Tool Access**: Only include necessary tools
4. **Detailed Prompts**: Provide comprehensive instructions
5. **Include Examples**: Show expected usage patterns

### Naming Conventions

- ✅ `api-doc-reviewer` (lowercase, hyphens)
- ✅ `test-generator` (descriptive)
- ✅ `security-auditor` (clear purpose)
- ❌ `MyAgent` (no capitals)
- ❌ `agent_1` (not descriptive)
- ❌ `do stuff` (no spaces)

### Model Selection

- **haiku**: Fast, cheap, good for straightforward tasks
  - Documentation formatting
  - Simple code generation
  - Automated workflows

- **sonnet**: Powerful, better for complex reasoning
  - Code architecture decisions
  - Deep code analysis
  - Complex test generation

### Tool Selection

- **Read only**: For analysis/review agents
- **Read + Write**: For creation agents
- **Read + Edit**: For modification agents
- **Bash**: Only if shell commands needed
- **Omit tools field**: To inherit all tools (use sparingly)

## Examples

### Example 1: API Documentation Generator

```bash
python scripts/init_agent.py \
    "api-doc-generator" \
    "Use this agent when you need to generate OpenAPI/Swagger documentation from code" \
    --tools "Read, Write, Grep, Glob" \
    --model sonnet
```

### Example 2: Test Coverage Analyzer

```bash
python scripts/init_agent.py \
    "test-coverage-analyzer" \
    "Use this agent to analyze test coverage and suggest missing tests" \
    --tools "Read, Grep, Glob" \
    --model sonnet
```

### Example 3: Documentation Formatter

```bash
python scripts/init_agent.py \
    "doc-formatter" \
    "Use this agent to format and standardize documentation files" \
    --tools "Read, Edit" \
    --model haiku
```

## Validation Checklist

Before finalizing an agent, verify:

- [ ] YAML frontmatter is valid
- [ ] Name is lowercase with hyphens only
- [ ] Name matches filename (without .md extension)
- [ ] Description includes clear triggers and examples
- [ ] System prompt has all key sections
- [ ] Tool list is minimal and appropriate
- [ ] Model choice matches task complexity
- [ ] Examples show realistic usage patterns

## Troubleshooting

### "Invalid agent name" error

Agent names must:
- Be lowercase
- Use hyphens (not underscores or spaces)
- Contain only letters, numbers, and hyphens

### "YAML frontmatter has formatting issues"

This is a warning that the YAML couldn't be parsed perfectly but basic fields were extracted. You may want to:
- Check for unquoted colons in description
- Ensure proper YAML syntax
- Consider using multiline string syntax (`|` or `>`)

### Agent doesn't trigger automatically

Make sure the description:
- Uses phrases like "Use this agent when..."
- Includes 2-3 concrete examples
- Clearly describes the trigger conditions

## Resources

- [Claude Code Subagents Documentation](https://docs.claude.com/en/docs/claude-code/subagents)
- [YAML Syntax Guide](https://yaml.org/spec/1.2.2/)
- [Agent Best Practices](https://docs.claude.com/en/docs/claude-code/best-practices)

## Contributing

To improve this skill:

1. Test with various agent types
2. Identify common patterns
3. Update templates based on learnings
4. Add new templates for new agent categories
5. Enhance validation rules

---

**Created**: 2025-10-26
**Version**: 1.0.0
**Maintainer**: Claude Code Users
