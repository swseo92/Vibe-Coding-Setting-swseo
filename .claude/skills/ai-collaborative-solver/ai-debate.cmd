@echo off
REM AI Collaborative Debate - Simple Interactive Wrapper
REM Usage: ai-debate.cmd "Your topic here"

if "%~1"=="" (
    echo Usage: ai-debate.cmd "topic"
    echo Example: ai-debate.cmd "Redis vs Memcached"
    exit /b 1
)

set TOPIC=%~1
set SCRIPT_DIR=%~dp0

REM Generate session directory with timestamp
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set DATE=%%c-%%a-%%b)
for /f "tokens=1-2 delims=/:" %%a in ("%TIME%") do (set TIME=%%a%%b)
set SESSION_DIR=%SCRIPT_DIR%sessions\%DATE%-%TIME%

echo.
echo ==================================================
echo AI Collaborative Debate - Interactive Mode
echo ==================================================
echo Topic: %TOPIC%
echo Session: %SESSION_DIR%
echo.
echo Press Ctrl+C to cancel, or any key to start...
pause > nul

REM Run facilitator in interactive mode (no piping)
cd "%SCRIPT_DIR%"
bash scripts/facilitator.sh "%TOPIC%" claude simple "%SESSION_DIR%"

echo.
echo ==================================================
echo Debate Complete
echo ==================================================
echo Results saved to: %SESSION_DIR%
echo.
