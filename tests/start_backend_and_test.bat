@echo off
REM AI ChatBot - Start Backend and Test
REM Starts backend service and opens test script in new windows

chcp 65001 >nul
setlocal enabledelayedexpansion

cls
echo.
echo ========================================================================
echo     AI ChatBot - Backend and Test Startup Script (UTF-8)
echo ========================================================================
echo.

REM Navigate to backend directory
set "BACKEND_DIR=%~dp0..\backend"
set "TESTS_DIR=%~dp0"

if not exist "!BACKEND_DIR!\pom.xml" (
    echo ERROR: Backend directory not found at:
    echo   !BACKEND_DIR!
    echo.
    echo Make sure you are running this script from the tests directory.
    pause
    exit /b 1
)

echo Starting AI ChatBot system...
echo.

REM Start backend in new window
echo [1/2] Starting backend service (in new window)...
echo       Backend will run on port 8080
echo       Waiting 5 seconds for backend to start...
echo.

start "AI ChatBot Backend" cmd /k "cd /d "!BACKEND_DIR!" && call mvn spring-boot:run"

timeout /t 5 /nobreak

REM Check if backend started
echo.
echo [2/2] Starting test tool...
echo       Waiting for backend to be ready...
timeout /t 3 /nobreak

REM Start test tool
cd /d "!TESTS_DIR!"
python chatbot_test.py

echo.
echo Test session completed.
echo To stop the backend, close the backend window.
pause
