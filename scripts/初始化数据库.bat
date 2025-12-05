@echo off
chcp 65001 >nul
setlocal

REM 获取项目根目录
pushd "%~dp0.."
set "PROJECT_ROOT=%CD%"
popd

echo ========================================
echo 餐饮订单系统 - 数据库初始化脚本
echo 项目根目录: %PROJECT_ROOT%
echo ========================================

REM 检查MySQL是否安装
where mysql >nul 2>&1
if errorlevel 1 (
    echo [错误] 未检测到MySQL，请先安装MySQL并将其加入系统环境变量
    pause
    exit /b 1
)

echo.
echo [✓] 检测到MySQL已安装
echo.

REM 获取MySQL密码
echo 请输入MySQL root用户密码:
set /p MYSQL_PASSWORD=

echo.
echo ========================================
echo 开始初始化数据库...
echo ========================================

echo.
echo [1/2] 创建数据库并导入表结构...
mysql -u root -p%MYSQL_PASSWORD% < "%PROJECT_ROOT%\database\init.sql"
if errorlevel 1 (
    echo [错误] 数据库初始化失败，请检查：
    echo   1. MySQL服务是否启动
    echo   2. root密码是否正确
    echo   3. init.sql文件是否存在
    pause
    exit /b 1
)

echo.
echo [2/2] 导入测试数据（用户、商品、套餐等）...
mysql -u root -p%MYSQL_PASSWORD% meal_order_system < "%PROJECT_ROOT%\database\test_data.sql"
if errorlevel 1 (
    echo [错误] 测试数据导入失败，请检查test_data.sql文件
    pause
    exit /b 1
)

echo.
echo ========================================
echo 数据库初始化完成！
echo ========================================
echo.
echo 默认账户信息：
echo.
echo 【管理员账户】
echo   用户名: admin
echo   密码: 123456
echo   管理地址: http://localhost:5173
echo.
echo 【普通用户账户】
echo   用户名: user001 / user002 / user003 / user004
echo   密码: 123456
echo   访问地址: http://localhost:5174
echo.
echo 数据库配置信息：
echo   主机: localhost:3306
echo   数据库: meal_order_system
echo   用户名: root
echo   密码: %MYSQL_PASSWORD%
echo.
echo ========================================
pause
