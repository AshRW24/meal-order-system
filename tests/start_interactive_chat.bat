@echo off
REM AI ChatBot Interactive Chat - UTF-8 Encoded
REM Quick startup script for interactive chat mode

chcp 65001 >nul
setlocal enabledelayedexpansion

cls
echo.
echo ========================================================================
echo               AI ChatBot - Interactive Chat Mode
echo ========================================================================
echo.

REM Check Python
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python not found. Please install Python 3.6+
    pause
    exit /b 1
)

REM Check requests
python -c "import requests" >nul 2>&1
if errorlevel 1 (
    echo Installing Python requests library...
    python -m pip install requests >nul 2>&1
)

REM Run interactive chat
echo Starting interactive chat...
echo Type 'exit' to quit, 'help' for commands
echo.
python "%~dp0chatbot_test.py"

echo.
echo Chat session ended.
pause
