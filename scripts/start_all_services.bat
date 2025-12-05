@echo off
setlocal enabledelayedexpansion

REM Get project root directory
pushd "%~dp0.."
set "PROJECT_ROOT=%CD%"
popd

echo ========================================
echo Start All Services - One Click
echo Project Root: %PROJECT_ROOT%
echo ========================================

echo.
echo [0/4] Checking dependencies...

REM Check and install admin frontend dependencies
if not exist "%PROJECT_ROOT%\frontend-admin\node_modules" (
    echo [INFO] Installing admin frontend dependencies...
    cd /d "%PROJECT_ROOT%\frontend-admin"
    call npm install
    if errorlevel 1 (
        echo [ERROR] Failed to install admin dependencies
        pause
        exit /b 1
    )
) else (
    echo [OK] Admin dependencies already installed
)

REM Check and install user frontend dependencies
if not exist "%PROJECT_ROOT%\frontend-user\node_modules" (
    echo [INFO] Installing user frontend dependencies...
    cd /d "%PROJECT_ROOT%\frontend-user"
    call npm install
    if errorlevel 1 (
        echo [ERROR] Failed to install user dependencies
        pause
        exit /b 1
    )
) else (
    echo [OK] User dependencies already installed
)

echo.
echo [1/4] Starting backend service...
start "Backend-8080" cmd /k "cd /d "%PROJECT_ROOT%\backend" && mvn spring-boot:run"

timeout /t 10 /nobreak >nul

echo [2/4] Starting admin frontend...
start "Admin-5173" cmd /k "cd /d "%PROJECT_ROOT%\frontend-admin" && npm run dev"

timeout /t 5 /nobreak >nul

echo [3/4] Starting user frontend...
start "User-5174" cmd /k "cd /d "%PROJECT_ROOT%\frontend-user" && npm run dev"

echo [4/4] All services started!

echo.
echo ========================================
echo All Services Started!
echo ========================================
echo Backend:    http://localhost:8080
echo API Docs:   http://localhost:8080/api/doc.html
echo Admin:      http://localhost:5173
echo User:       http://localhost:5174
echo ========================================
echo Press any key to close this window...
pause >nul
