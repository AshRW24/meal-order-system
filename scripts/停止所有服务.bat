@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM 获取项目根目录
pushd "%~dp0.."
set "PROJECT_ROOT=%CD%"
popd

echo ========================================
echo 停止所有服务
echo 项目根目录: %PROJECT_ROOT%
echo ========================================

echo.
echo 正在停止后端服务 (端口 8080)...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :8080 ^| findstr LISTENING 2^>nul') do (
    echo 终止进程 PID: %%a
    taskkill /F /PID %%a 2>nul
)

echo.
echo 正在停止管理端 (端口 5173)...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :5173 ^| findstr LISTENING 2^>nul') do (
    echo 终止进程 PID: %%a
    taskkill /F /PID %%a 2>nul
)

echo.
echo 正在停止用户端 (端口 5174)...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :5174 ^| findstr LISTENING 2^>nul') do (
    echo 终止进程 PID: %%a
    taskkill /F /PID %%a 2>nul
)

echo.
echo ========================================
echo 所有服务已停止！
echo ========================================
pause
