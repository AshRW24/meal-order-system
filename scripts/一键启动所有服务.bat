@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM 获取项目根目录
pushd "%~dp0.."
set "PROJECT_ROOT=%CD%"
popd

echo ========================================
echo 一键启动所有服务
echo 项目根目录: %PROJECT_ROOT%
echo ========================================

echo.
echo [0/4] 正在检查依赖...

REM 检查并安装管理端依赖
if not exist "%PROJECT_ROOT%\frontend-admin\node_modules" (
    echo [信息] 正在安装管理端依赖...
    cd /d "%PROJECT_ROOT%\frontend-admin"
    call npm install
)

REM 检查并安装用户端依赖
if not exist "%PROJECT_ROOT%\frontend-user\node_modules" (
    echo [信息] 正在安装用户端依赖...
    cd /d "%PROJECT_ROOT%\frontend-user"
    call npm install
)

echo.
echo [1/4] 正在启动后端服务...
start "后端服务-8080" cmd /k "cd /d "%PROJECT_ROOT%\backend" && mvn spring-boot:run"

timeout /t 5 /nobreak >nul

echo [2/4] 正在启动管理端...
start "管理端-5173" cmd /k "cd /d "%PROJECT_ROOT%\frontend-admin" && npm run dev"

timeout /t 3 /nobreak >nul

echo [3/4] 正在启动用户端...
start "用户端-5174" cmd /k "cd /d "%PROJECT_ROOT%\frontend-user" && npm run dev"

echo.
echo ========================================
echo 所有服务已启动！
echo ========================================
echo 后端服务: http://localhost:8080
echo API 文档: http://localhost:8080/api/doc.html
echo 管理端:   http://localhost:5173
echo 用户端:   http://localhost:5174
echo ========================================
pause
