# PyCharm .idea Manager Skill

Manage PyCharm IDE configurations with ease - analyze, create, and modify Run Configurations and project settings.

## Overview

This skill helps you work with PyCharm's `.idea` folder, focusing on:
- Run Configurations (Python, pytest, Django, Flask)
- Project settings (SDK, modules, VCS)
- Code quality settings (inspections)

## When to Use This Skill

Use this skill when you need to:
- Create new Run Configurations for scripts or tests
- Analyze existing PyCharm configurations
- Modify environment variables or paths in configurations
- Set up standardized configurations for your team
- Troubleshoot Run Configuration issues

## Quick Start

### Example 1: Create Python Script Configuration

User: "Create a Run Configuration for src/main.py"

The skill will:
1. Ask for any additional parameters or environment variables
2. Create the configuration file
3. Guide you to reload PyCharm

### Example 2: Set Up pytest with Coverage

User: "Set up pytest to run all tests with coverage"

The skill will:
1. Create pytest configuration
2. Add coverage options
3. Set up HTML report generation

### Example 3: Analyze Current Configurations

User: "Show me all my Run Configurations"

The skill will:
1. List all existing configurations
2. Display key details (type, script, env vars)
3. Present in easy-to-read format

## Supported Configuration Types

### Python Script
Basic Python script execution with:
- Custom parameters
- Environment variables
- Working directory configuration

### pytest
Test execution with:
- Coverage reporting
- Test discovery options
- Custom pytest arguments

### Django Server
Django development server with:
- Host and port configuration
- Django settings module
- Debug mode

### Flask Server
Flask development server with:
- FLASK_APP and FLASK_ENV
- Debug mode
- Custom host and port

## How It Works

### 1. Analysis Phase
The skill reads existing `.idea/runConfigurations/*.xml` files and presents them in a user-friendly format.

### 2. Creation Phase
Uses XML templates with placeholders:
- `{CONFIG_NAME}` - Display name
- `{SCRIPT_PATH}` - Path to script
- `{WORKING_DIR}` - Working directory
- `{ENV_VARS}` - Environment variables
- And more...

### 3. Modification Phase
Parses existing XML, updates specific fields, and preserves other settings.

### 4. Validation Phase
Checks XML validity, path existence, and configuration completeness.

## File Structure

```
.claude/skills/pycharm-idea-manager/
├── skill.md              # Main skill prompt
├── README.md             # This file
└── templates/            # XML templates
    ├── python-script.xml # Python script template
    ├── pytest.xml        # pytest template
    ├── django.xml        # Django server template
    └── flask.xml         # Flask server template
```

## Template Variables Reference

### Common Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `{CONFIG_NAME}` | Configuration display name | `"Run Tests"` |
| `{MODULE_NAME}` | PyCharm module name | `"my-project"` |
| `{SCRIPT_PATH}` | Absolute script path | `"$PROJECT_DIR$/src/main.py"` |
| `{WORKING_DIR}` | Working directory | `"$PROJECT_DIR$"` |
| `{PARAMETERS}` | Command-line arguments | `"--verbose --debug"` |
| `{ENV_VARS}` | Environment variables block | See below |

### Environment Variables Format

```xml
<env name="DEBUG" value="1" />
<env name="DATABASE_URL" value="postgresql://localhost/mydb" />
```

### pytest Specific

| Variable | Description | Example |
|----------|-------------|---------|
| `{TEST_TARGET}` | Test file/directory path | `"$PROJECT_DIR$/tests"` |
| `{TARGET_TYPE}` | Target type | `"PATH"` or `"PYTHON"` |
| `{PYTEST_OPTIONS}` | pytest command-line options | `"-v --cov=src --cov-report=html"` |

### Django Specific

| Variable | Description | Example |
|----------|-------------|---------|
| `{DJANGO_SETTINGS}` | Django settings module | `"config.settings.dev"` |
| `{HOST}` | Server host | `"127.0.0.1"` |
| `{PORT}` | Server port | `"8000"` |

### Flask Specific

| Variable | Description | Example |
|----------|-------------|---------|
| `{FLASK_APP}` | Flask application | `"app.py"` or `"myapp:create_app()"` |
| `{FLASK_ENV}` | Flask environment | `"development"` or `"production"` |
| `{FLASK_DEBUG}` | Debug mode | `"1"` or `"0"` |
| `{HOST}` | Server host | `"127.0.0.1"` |
| `{PORT}` | Server port | `"5000"` |

## PyCharm Path Variables

Always use these instead of absolute paths:

| Variable | Meaning |
|----------|---------|
| `$PROJECT_DIR$` | Project root directory |
| `$MODULE_DIR$` | Module directory |
| `$USER_HOME$` | User's home directory |

## Usage Examples

### Create Python Script with Environment Variables

User:
```
Create Run Config for src/app.py with DATABASE_URL=postgresql://localhost/mydb
```

Result:
- Configuration name: `app.py`
- Script: `$PROJECT_DIR$/src/app.py`
- Environment: `DATABASE_URL=postgresql://localhost/mydb`

### Create pytest with Coverage

User:
```
Set up pytest to test src/ with coverage reports
```

Result:
- Configuration name: `pytest_with_coverage`
- Target: `$PROJECT_DIR$/tests`
- Options: `-v --cov=src --cov-report=html`

### Modify Existing Configuration

User:
```
Add DEBUG=True to my main.py configuration
```

Result:
- Reads existing `main.py` config
- Adds `<env name="DEBUG" value="True" />`
- Preserves all other settings

## Best Practices

### 1. Use PyCharm Variables
Always use `$PROJECT_DIR$` instead of absolute paths for portability.

### 2. Protect Sensitive Data
Don't commit configurations with secrets. Use `.env` files instead.

### 3. Team Standards
Create shared configurations with clear naming conventions.

### 4. Version Control
Add to `.gitignore` if configurations contain user-specific or sensitive data:
```
.idea/runConfigurations/*.xml
!.idea/runConfigurations/shared-*.xml
```

### 5. Documentation
Document custom configurations in your project README.

## Troubleshooting

### Configuration Not Appearing

Solution:
1. Check XML syntax
2. Verify file is in `.idea/runConfigurations/`
3. Reload project: File > Invalidate Caches / Restart

### Paths Not Working

Solution:
1. Use PyCharm variables (`$PROJECT_DIR$`)
2. Check working directory is correct
3. Verify script paths exist

### Environment Variables Not Loading

Solution:
1. Check XML escaping (use `&amp;` for `&`)
2. Ensure `PARENT_ENVS` is `true`
3. Consider using `python-dotenv`

## Advanced Usage

### Batch Create Configurations

Create configs for all test files:
```python
# Example workflow
for test_file in test_files:
    create_pytest_config(test_file)
```

### Template Customization

Copy and modify templates in `templates/` directory to create custom configuration types.

### Integration with .env Files

Recommend users to use `python-dotenv`:
```python
from dotenv import load_dotenv
load_dotenv()
```

This keeps secrets out of `.idea` files.

## Contributing

To add new templates:
1. Create XML template in `templates/`
2. Use clear placeholder names
3. Document variables in this README
4. Add examples to skill.md

## Related Documentation

- PyCharm Run Configurations: https://www.jetbrains.com/help/pycharm/run-debug-configuration.html
- pytest Documentation: https://docs.pytest.org/
- Django Settings: https://docs.djangoproject.com/en/stable/topics/settings/
- Flask Configuration: https://flask.palletsprojects.com/en/stable/config/

## Skill Trigger

Use this skill when:
- User mentions "PyCharm configuration"
- User asks about "Run Configuration"
- User wants to "create/modify .idea files"
- User needs "IDE setup" or "project configuration"

## Success Metrics

You know this skill succeeded when:
- User can run their script/tests from PyCharm UI
- Configuration appears in Run menu
- All paths resolve correctly
- Environment variables load properly
- No XML parsing errors

## Future Enhancements

Potential additions:
- Docker run configurations
- Remote interpreter configs
- Code style settings management
- Inspection profile customization
- Debugging configuration templates

## Support

If you encounter issues:
1. Check XML validity
2. Verify PyCharm version compatibility
3. Review PyCharm logs
4. Consult official JetBrains documentation

## Version

Current Version: 1.0.0
Last Updated: 2025-11-09
Compatible with: PyCharm 2023.x and later
