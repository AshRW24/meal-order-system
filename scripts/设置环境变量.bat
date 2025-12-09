@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo.
echo ========================================
echo Windows 环境变量配置向导
echo ========================================
echo.

REM 获取当前PATH
for /f "tokens=2*" %%A in ('reg query HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment /v PATH') do set "OLD_PATH=%%B"

set "MYSQL_PATH=C:\Program Files\MySQL\MySQL Server 8.0\bin"

echo 检查 MySQL 路径是否存在...
if not exist "%MYSQL_PATH%" (
    echo [错误] 找不到 MySQL: %MYSQL_PATH%
    echo.
    echo 请手动设置正确的 MySQL 安装路径
    pause
    exit /b 1
)

echo [成功] 找到 MySQL
echo.

echo 正在添加 MySQL 到系统 PATH 环境变量...
echo %OLD_PATH% | find /i "%MYSQL_PATH%" >nul
if errorlevel 1 (
    REM 使用 setx 命令设置系统环境变量
    setx PATH "%MYSQL_PATH%;%OLD_PATH%" /M
    if errorlevel 1 (
        echo [错误] 需要管理员权限！
        echo.
        echo 请以管理员身份运行此脚本：
        echo 1. 右键点击此脚本
        echo 2. 选择 "以管理员身份运行"
        echo.
        pause
        exit /b 1
    )
    echo [成功] PATH 环境变量已更新
    echo.
    echo 现在需要重启电脑才能生效
    echo.
    pause
) else (
    echo [信息] MySQL 已在 PATH 环境变量中
    echo.
    pause
)
