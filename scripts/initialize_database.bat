@echo off
setlocal

REM 获取项目根目录
pushd "%~dp0.."
set "PROJECT_ROOT=%CD%"
popd

echo ========================================
echo Meal Order System - Database Initialization Script
echo Project Root: %PROJECT_ROOT%
echo ========================================

REM 检查MySQL是否安装
where mysql >nul 2>&1
if errorlevel 1 (
    echo [ERROR] MySQL not detected, please install MySQL and add it to system PATH
    pause
    exit /b 1
)

echo.
echo [OK] MySQL detected
echo.

REM 获取MySQL密码
echo Please enter MySQL root password:
set /p MYSQL_PASSWORD=

echo.
echo ========================================
echo Starting database initialization...
echo ========================================

echo.
echo [1/2] Creating database and importing table structure...
mysql -u root -p%MYSQL_PASSWORD% -e "CREATE DATABASE IF NOT EXISTS meal_order_system CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -u root -p%MYSQL_PASSWORD% meal_order_system < "%PROJECT_ROOT%\database\init.sql"
if errorlevel 1 (
    echo [ERROR] Database initialization failed, please check:
    echo   1. MySQL service is started
    echo   2. root password is correct
    echo   3. init.sql file exists at %PROJECT_ROOT%\database\init.sql
    pause
    exit /b 1
)

echo.
echo [2/2] Importing test data (users, dishes, meals, etc.)...
mysql -u root -p%MYSQL_PASSWORD% meal_order_system < "%PROJECT_ROOT%\database\test_data.sql"
if errorlevel 1 (
    echo [ERROR] Test data import failed, please check test_data.sql file
    pause
    exit /b 1
)

echo.
echo ========================================
echo Database initialization completed!
echo ========================================
echo.
echo Default account information:
echo.
echo [Admin Account]
echo   Username: admin
echo   Password: 123456
echo   Admin URL: http://localhost:5173
echo.
echo [User Accounts]
echo   Username: user001 / user002 / user003 / user004
echo   Password: 123456
echo   User URL: http://localhost:5174
echo.
echo Database configuration:
echo   Host: localhost:3306
echo   Database: meal_order_system
echo   Username: root
echo   Password: %MYSQL_PASSWORD%
echo.
echo ========================================
pause
