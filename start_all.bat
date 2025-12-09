@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM ==========================================
REM  Meal Order System - Windows Startup Script
REM ==========================================

cls
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║     Meal Order System - All Services Startup                   ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

REM Get the project root directory
for %%I in ("%~dp0.") do set "PROJECT_ROOT=%%~fI"

REM ==========================================
REM Check if MySQL is installed
REM ==========================================
echo Checking MySQL installation...
where mysql >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERROR] MySQL not found!
    echo Please install MySQL and add it to PATH
    echo.
    pause
    exit /b 1
)
echo [OK] MySQL found

REM ==========================================
REM Check if Maven is installed
REM ==========================================
echo Checking Maven installation...
where mvn >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERROR] Maven not found!
    echo Please install Maven and add it to PATH
    echo.
    pause
    exit /b 1
)
echo [OK] Maven found

REM ==========================================
REM Check if Node.js is installed
REM ==========================================
echo Checking Node.js installation...
where node >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERROR] Node.js not found!
    echo Please install Node.js and add it to PATH
    echo.
    pause
    exit /b 1
)
echo [OK] Node.js found
echo.

REM ==========================================
REM Initialize Database
REM ==========================================
echo Initializing database...
cd "%PROJECT_ROOT%\database" >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Database directory not found!
    pause
    exit /b 1
)

mysql -u root -p123456 < init.sql >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [WARNING] Database initialization failed or already exists
) else (
    echo [OK] Database initialized
)
echo.

REM ==========================================
REM Start Backend
REM ==========================================
echo Starting Backend Service (Port 8080)...
cd "%PROJECT_ROOT%\backend"
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Backend directory not found!
    pause
    exit /b 1
)

start "Backend - Spring Boot" cmd /k "mvn clean spring-boot:run"
echo [OK] Backend started in new window
echo Waiting for backend to start (about 30 seconds)...

REM Wait for backend to be ready
setlocal enabledelayedexpansion
for /L %%i in (1,1,30) do (
    timeout /t 1 /nobreak >nul
    curl -s http://localhost:8080/api/doc.html >nul 2>&1
    if !ERRORLEVEL! EQU 0 (
        echo [OK] Backend is ready
        goto backend_ready
    )
)
echo [WARNING] Backend may not be fully ready, continuing...

:backend_ready
echo.

REM ==========================================
REM Start Admin Frontend
REM ==========================================
echo Starting Admin Frontend (Port 5173)...
cd "%PROJECT_ROOT%\frontend-admin"
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Admin frontend directory not found!
    pause
    exit /b 1
)

start "Admin Frontend - Vue" cmd /k "npm install && npm run dev"
echo [OK] Admin frontend started in new window
timeout /t 5 /nobreak >nul
echo.

REM ==========================================
REM Start User Frontend
REM ==========================================
echo Starting User Frontend (Port 5174)...
cd "%PROJECT_ROOT%\frontend-user"
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] User frontend directory not found!
    pause
    exit /b 1
)

start "User Frontend - Vue" cmd /k "npm install && npm run dev"
echo [OK] User frontend started in new window
timeout /t 5 /nobreak >nul
echo.

REM ==========================================
REM Display Access Information
REM ==========================================
cls
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║     All Services Started Successfully!                         ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo [Access Addresses]
echo.
echo   API Documentation:  http://localhost:8080/api/doc.html
echo   Admin Dashboard:    http://localhost:5173
echo   User Application:   http://localhost:5174
echo.
echo [Test Credentials]
echo.
echo   Admin:      admin / 123456
echo   User:       user001 / 123456
echo.
echo [Database Credentials]
echo.
echo   Host:       localhost
echo   User:       root
echo   Password:   123456
echo   Database:   meal_order_system
echo.
echo [Windows Terminal Windows]
echo.
echo   Three new terminal windows have been opened:
echo   1. Backend (Spring Boot) - Port 8080
echo   2. Admin Frontend (Vue) - Port 5173
echo   3. User Frontend (Vue) - Port 5174
echo.
echo [Note]
echo   Close any window to stop the respective service
echo   All services will continue running until manually stopped
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo.

REM Keep the main window open
pause

endlocal
