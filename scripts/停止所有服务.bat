@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo.
echo ========================================
echo 停止所有服务
echo ========================================
echo.

REM 停止后端服务 (Port 8080)
echo 正在停止后端服务 (Port 8080)...
for /f "tokens=5" %%a in ('netstat -ano ^| find "8080"') do (
    taskkill /F /PID %%a >nul 2>&1
)
if errorlevel 1 (
    echo [信息] 端口 8080 未被占用
) else (
    echo [成功] 已停止端口 8080 的进程
)

timeout /t 1 /nobreak >nul

REM 停止管理端服务 (Port 5173)
echo 正在停止管理端 (Port 5173)...
for /f "tokens=5" %%a in ('netstat -ano ^| find "5173"') do (
    taskkill /F /PID %%a >nul 2>&1
)
if errorlevel 1 (
    echo [信息] 端口 5173 未被占用
) else (
    echo [成功] 已停止端口 5173 的进程
)

timeout /t 1 /nobreak >nul

REM 停止用户端服务 (Port 5174)
echo 正在停止用户端 (Port 5174)...
for /f "tokens=5" %%a in ('netstat -ano ^| find "5174"') do (
    taskkill /F /PID %%a >nul 2>&1
)
if errorlevel 1 (
    echo [信息] 端口 5174 未被占用
) else (
    echo [成功] 已停止端口 5174 的进程
)

echo.
echo ========================================
echo 所有服务已停止！
echo ========================================
echo.
pause
