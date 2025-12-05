@echo off
chcp 65001 >nul
setlocal

REM 获取项目根目录
pushd "%~dp0.."
set "PROJECT_ROOT=%CD%"
popd

echo ========================================
echo 餐饮订单系统 - 数据库测试脚本
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

REM 检查数据库是否存在
echo 请输入MySQL root用户密码:
set /p MYSQL_PASSWORD=

echo.
echo ========================================
echo 检查数据库是否存在...
echo ========================================

mysql -u root -p%MYSQL_PASSWORD% -e "USE meal_order_system;" >nul 2>&1
if errorlevel 1 (
    echo [警告] 数据库不存在或密码错误
    echo.
    echo 是否需要先执行初始化数据库脚本？ (Y/N)
    set /p INIT_DB=
    if /i "%INIT_DB%"=="Y" (
        echo.
        echo 正在执行初始化脚本...
        call "%PROJECT_ROOT%\scripts\初始化数据库.bat"
        if errorlevel 1 (
            echo [错误] 数据库初始化失败
            pause
            exit /b 1
        )
    ) else (
        echo [取消] 无法继续测试
        pause
        exit /b 1
    )
)

echo.
echo ========================================
echo 开始执行数据库测试查询...
echo ========================================
echo.

REM 执行测试查询脚本
mysql -u root -p%MYSQL_PASSWORD% meal_order_system < "%PROJECT_ROOT%\database\test_queries.sql"
if errorlevel 1 (
    echo.
    echo [错误] 测试查询执行失败，请检查：
    echo   1. MySQL服务是否正常运行
    echo   2. 密码是否正确
    echo   3. 数据库是否已初始化
    pause
    exit /b 1
)

echo.
echo ========================================
echo 数据库测试完成！
echo ========================================
echo.
echo 测试内容包括：
echo   ✓ 用户数据统计
echo   ✓ 菜品数据统计
echo   ✓ 套餐数据统计
echo   ✓ 订单数据统计
echo   ✓ 订单详情统计
echo   ✓ 地址数据统计
echo   ✓ 购物车数据统计
echo   ✓ 数据完整性检验
echo   ✓ 表结构和索引检验
echo.
pause
