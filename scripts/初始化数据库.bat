@echo off
chcp 65001 >nul
setlocal

REM 获取项目根目录
pushd "%~dp0.."
set "PROJECT_ROOT=%CD%"
popd

echo ========================================
echo 初始化数据库
echo 项目根目录: %PROJECT_ROOT%
echo ========================================

echo.
echo [1/2] 创建数据库并导入表结构...
mysql -u root -p < "%PROJECT_ROOT%\database\init.sql"
if errorlevel 1 (
    echo [错误] 数据库初始化失败，请检查MySQL服务是否启动
    pause
    exit /b 1
)

echo.
echo [2/2] 导入测试数据（用户、商品、套餐等）...
mysql -u root -p meal_order_system < "%PROJECT_ROOT%\database\test_data.sql"
if errorlevel 1 (
    echo [错误] 测试数据导入失败
    pause
    exit /b 1
)

echo.
echo ========================================
echo 数据库初始化完成
echo ========================================
pause
