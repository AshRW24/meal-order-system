@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM 获取项目根目录
pushd "%~dp0.."
set "PROJECT_ROOT=%CD%"
popd

echo.
echo ========================================
echo 一键启动所有服务
echo ========================================
echo.
echo 项目根目录: %PROJECT_ROOT%
echo.

REM 检查前端依赖
echo [1/4] 检查依赖...

if not exist "%PROJECT_ROOT%\frontend-admin\node_modules" (
    echo [正在安装] 管理端依赖...
    cd /d "%PROJECT_ROOT%\frontend-admin"
    call npm install >nul 2>&1
    if errorlevel 1 (
        echo [错误] 管理端依赖安装失败
        pause
        exit /b 1
    )
)
echo [成功] 管理端依赖检查完成

if not exist "%PROJECT_ROOT%\frontend-user\node_modules" (
    echo [正在安装] 用户端依赖...
    cd /d "%PROJECT_ROOT%\frontend-user"
    call npm install >nul 2>&1
    if errorlevel 1 (
        echo [错误] 用户端依赖安装失败
        pause
        exit /b 1
    )
)
echo [成功] 用户端依赖检查完成

echo.
echo [2/4] 启动后端服务 (Port 8080)...
start "后端服务-8080" cmd /k "cd /d "%PROJECT_ROOT%\backend" && mvn spring-boot:run"
timeout /t 8 /nobreak >nul

echo [3/4] 启动管理端 (Port 5173)...
start "管理端-5173" cmd /k "cd /d "%PROJECT_ROOT%\frontend-admin" && npm run dev"
timeout /t 3 /nobreak >nul

echo [4/4] 启动用户端 (Port 5174)...
start "用户端-5174" cmd /k "cd /d "%PROJECT_ROOT%\frontend-user" && npm run dev"

echo.
echo ========================================
echo 所有服务已启动！
echo ========================================
echo.
echo 访问地址：
echo   后端API:  http://localhost:8080/api
echo   API文档:  http://localhost:8080/api/doc.html
echo   管理端:   http://localhost:5173
echo   用户端:   http://localhost:5174
echo.
echo 默认账号：
echo   管理端: admin / 123456
echo   用户端: user001 / 123456
echo.
echo 提示：首次启动后端需要 30-60 秒编译
echo.
pause
