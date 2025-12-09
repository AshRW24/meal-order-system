@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM 获取项目根目录
pushd "%~dp0.."
set "PROJECT_ROOT=%CD%"
popd

echo.
echo ========================================
echo 初始化数据库脚本
echo ========================================
echo.
echo 项目根目录: %PROJECT_ROOT%
echo.

REM 检查MySQL是否可用
echo 正在检查 MySQL 连接...
mysql -u root -p123456 -e "SELECT 1;" >nul 2>&1
if errorlevel 1 (
    echo [错误] 无法连接到 MySQL！
    echo.
    echo 请确保：
    echo 1. MySQL 服务已启动
    echo 2. 用户名是 root
    echo 3. 密码是 123456
    echo 4. MySQL 安装在默认目录
    echo.
    pause
    exit /b 1
)

echo [成功] MySQL 连接正常
echo.

REM 创建数据库并导入初始化脚本
echo [1/2] 创建数据库并导入表结构...
mysql -u root -p123456 < "%PROJECT_ROOT%\database\init.sql"
if errorlevel 1 (
    echo [错误] 数据库初始化失败
    pause
    exit /b 1
)
echo [成功] 数据库和表结构创建完成

REM 导入测试数据
echo.
echo [2/2] 导入测试数据...
mysql -u root -p123456 meal_order_system < "%PROJECT_ROOT%\database\test_data.sql"
if errorlevel 1 (
    echo [错误] 测试数据导入失败
    pause
    exit /b 1
)
echo [成功] 测试数据导入完成

echo.
echo ========================================
echo 数据库初始化完成！
echo ========================================
echo.
echo 默认测试账号：
echo   管理端: admin / 123456
echo   用户端: user001 / 123456
echo.
pause
