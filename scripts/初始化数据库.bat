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

REM 首先尝试用 PATH 中的 mysql 命令
mysql -u root -p123456 -e "SELECT 1;" >nul 2>&1
if not errorlevel 1 (
    echo [成功] 在系统 PATH 中找到 MySQL
    goto RUN_INIT
)

REM 如果 PATH 中没有，尝试完整路径
set "MYSQL_PATH=C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"

if not exist "%MYSQL_PATH%" (
    echo [错误] 找不到 MySQL！
    echo.
    echo 尝试的位置：
    echo   - 系统 PATH 环境变量
    echo   - %MYSQL_PATH%
    echo.
    echo 解决方案：
    echo 1. 双击运行 "设置环境变量.bat" 配置 MySQL 路径
    echo 2. 或编辑此脚本中的 MYSQL_PATH 变量
    echo 3. 重启电脑使环境变量生效
    echo.
    pause
    exit /b 1
)

echo [成功] 在完整路径中找到 MySQL
set "mysql=%MYSQL_PATH%"
goto RUN_INIT

:RUN_INIT
echo 正在检查 MySQL 连接...
%mysql% -u root -p123456 -e "SELECT 1;" >nul 2>&1
if errorlevel 1 (
    echo [错误] 无法连接到 MySQL！
    echo.
    echo 请检查：
    echo 1. MySQL 服务是否已启动
    echo 2. 用户名是否为 root
    echo 3. 密码是否为 123456
    echo.
    pause
    exit /b 1
)

echo [成功] MySQL 连接正常
echo.

REM 创建数据库并导入初始化脚本
echo [1/2] 创建数据库并导入表结构...
%mysql% -u root -p123456 < "%PROJECT_ROOT%\database\init.sql"
if errorlevel 1 (
    echo [错误] 数据库初始化失败
    echo.
    pause
    exit /b 1
)
echo [成功] 数据库和表结构创建完成

REM 导入测试数据
echo.
echo [2/2] 导入测试数据...
%mysql% -u root -p123456 meal_order_system < "%PROJECT_ROOT%\database\test_data.sql"
if errorlevel 1 (
    echo [错误] 测试数据导入失败
    echo.
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
