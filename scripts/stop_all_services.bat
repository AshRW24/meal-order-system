@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM 获取项目根目录
pushd "%~dp0.."
set "PROJECT_ROOT=%CD%"
popd

echo ========================================
echo Stop All Services
echo Project Root: %PROJECT_ROOT%
echo ========================================

echo.
echo Stopping backend service (Port 8080)...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :8080 ^| findstr LISTENING 2^>nul') do (
    echo Killing process PID: %%a
    taskkill /F /PID %%a 2>nul
)

echo.
echo Stopping admin frontend (Port 5173)...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :5173 ^| findstr LISTENING 2^>nul') do (
    echo Killing process PID: %%a
    taskkill /F /PID %%a 2>nul
)

echo.
echo Stopping user frontend (Port 5174)...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :5174 ^| findstr LISTENING 2^>nul') do (
    echo Killing process PID: %%a
    taskkill /F /PID %%a 2>nul
)

echo.
echo ========================================
echo All Services Stopped!
echo ========================================
pause
