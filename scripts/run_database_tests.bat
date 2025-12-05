@echo off
chcp 65001 >nul
setlocal

REM 获取项目根目录
pushd "%~dp0.."
set "PROJECT_ROOT=%CD%"
popd

echo ========================================
echo Meal Order System - Database Test Script
echo Project Root: %PROJECT_ROOT%
echo ========================================

REM Check if MySQL is installed
where mysql >nul 2>&1
if errorlevel 1 (
    echo [ERROR] MySQL not detected, please install MySQL and add it to system PATH
    pause
    exit /b 1
)

echo.
echo [OK] MySQL detected
echo.

REM Check database existence
echo Please enter MySQL root password:
set /p MYSQL_PASSWORD=

echo.
echo ========================================
echo Checking database existence...
echo ========================================

mysql -u root -p%MYSQL_PASSWORD% -e "USE meal_order_system;" >nul 2>&1
if errorlevel 1 (
    echo [WARNING] Database does not exist or password is incorrect
    echo.
    echo Do you want to run the database initialization script first? (Y/N)
    set /p INIT_DB=
    if /i "%INIT_DB%"=="Y" (
        echo.
        echo Running initialization script...
        call "%PROJECT_ROOT%\scripts\initialize_database.bat"
        if errorlevel 1 (
            echo [ERROR] Database initialization failed
            pause
            exit /b 1
        )
    ) else (
        echo [CANCEL] Cannot continue testing
        pause
        exit /b 1
    )
)

echo.
echo ========================================
echo Starting database test queries...
echo ========================================
echo.

REM Execute test query script
mysql -u root -p%MYSQL_PASSWORD% meal_order_system < "%PROJECT_ROOT%\database\test_queries.sql"
if errorlevel 1 (
    echo.
    echo [ERROR] Test queries failed, please check:
    echo   1. MySQL service is running
    echo   2. Password is correct
    echo   3. Database is initialized
    pause
    exit /b 1
)

echo.
echo ========================================
echo Database tests completed!
echo ========================================
echo.
echo Test contents include:
echo   ✓ User data statistics
echo   ✓ Dish data statistics
echo   ✓ Meal data statistics
echo   ✓ Order data statistics
echo   ✓ Order detail statistics
echo   ✓ Address data statistics
echo   ✓ Shopping cart data statistics
echo   ✓ Data integrity checks
echo   ✓ Table structure and index checks
echo.
pause
