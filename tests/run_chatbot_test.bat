@echo off
REM AI ChatBot Test Script - UTF-8 Encoded
REM This script starts the backend and runs the chatbot test

chcp 65001 >nul
setlocal enabledelayedexpansion

REM Colors (for Windows 10+)
set "BLUE=[94m"
set "GREEN=[92m"
set "YELLOW=[93m"
set "RED=[91m"
set "RESET=[0m"

cls
echo.
echo ========================================================================
echo                    AI ChatBot Test - Startup Script
echo ========================================================================
echo.

REM Check if Python is installed
echo [1/3] Checking Python installation...
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python 3.6+ and add it to PATH
    pause
    exit /b 1
)
echo       OK - Python found
echo.

REM Check if requests library is installed
echo [2/3] Checking Python requests library...
python -c "import requests" >nul 2>&1
if errorlevel 1 (
    echo WARNING: requests library not found
    echo Installing requests...
    python -m pip install requests >nul 2>&1
    if errorlevel 1 (
        echo ERROR: Failed to install requests
        echo Run: pip install requests
        pause
        exit /b 1
    )
)
echo       OK - requests library found
echo.

REM Check if backend is running
echo [3/3] Checking backend service...
timeout /t 1 /nobreak >nul
for /f %%i in ('PowerShell -Command "[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12; try { $response = Invoke-WebRequest -Uri 'http://localhost:8080/api/chatbot/status' -TimeoutSec 2 -ErrorAction SilentlyContinue; if ($response.StatusCode -eq 200) { Write-Output 'OK' } } catch { Write-Output 'FAIL' }"') do set backend_status=%%i

if "!backend_status!"=="OK" (
    echo       OK - Backend is running on port 8080
) else (
    echo WARNING: Could not connect to backend on port 8080
    echo Make sure backend is running:
    echo   cd backend
    echo   mvn spring-boot:run
    echo.
    echo Continuing anyway - the test will try to connect...
)
echo.

REM Show menu
:menu
cls
echo.
echo ========================================================================
echo                  AI ChatBot Interactive Test Tool
echo ========================================================================
echo.
echo Choose test mode:
echo.
echo   1) Interactive chat (recommended)
echo   2) Automated test (5 predefined messages)
echo   3) Single message test
echo   4) Check backend status
echo   5) Exit
echo.
set /p choice="Enter your choice (1-5): "

if "!choice!"=="1" goto interactive
if "!choice!"=="2" goto automated
if "!choice!"=="3" goto single
if "!choice!"=="4" goto status
if "!choice!"=="5" goto exit
echo.
echo Invalid choice. Please try again.
timeout /t 2 /nobreak >nul
goto menu

REM Interactive mode
:interactive
echo.
echo ========================================================================
echo Starting interactive chat mode (type 'exit' to quit)...
echo ========================================================================
echo.
python "%~dp0chatbot_test.py"
goto menu

REM Automated test mode
:automated
echo.
echo ========================================================================
echo Running automated tests (5 predefined messages)...
echo ========================================================================
echo.
python "%~dp0chatbot_test.py" --test
pause
goto menu

REM Single message test
:single
echo.
set /p message="Enter your message: "
if "!message!"=="" (
    echo Message cannot be empty.
    timeout /t 2 /nobreak >nul
    goto menu
)
echo.
python "%~dp0chatbot_test.py" --message "!message!"
pause
goto menu

REM Check status
:status
echo.
python "%~dp0chatbot_test.py" --backend-url http://localhost:8080/api
timeout /t 2 /nobreak >nul
goto menu

REM Exit
:exit
echo.
echo Thank you for using AI ChatBot Test Tool!
echo.
pause
exit /b 0
