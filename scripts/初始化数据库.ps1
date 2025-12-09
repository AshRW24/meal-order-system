# PowerShell 初始化数据库脚本
# 需要以管理员身份运行

param(
    [string]$MySqlPath = "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"
)

# 设置UTF-8编码
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# 获取项目根目录
$ProjectRoot = Split-Path -Parent $PSScriptRoot

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "初始化数据库脚本" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "项目根目录: $ProjectRoot"
Write-Host ""

# 检查是否管理员运行
$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object System.Security.Principal.WindowsPrincipal($currentUser)
if (-not $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[信息] 建议以管理员身份运行此脚本" -ForegroundColor Yellow
}

# 首先尝试用PATH中的mysql命令
try {
    $mysqlTest = & mysql -u root -p123456 -e "SELECT 1;" 2>$null
    if ($?) {
        Write-Host "[成功] 在系统 PATH 中找到 MySQL" -ForegroundColor Green
        $mysql = "mysql"
    } else {
        throw "PATH中的MySQL不可用"
    }
} catch {
    # 如果PATH中没有，尝试完整路径
    if (-not (Test-Path $MySqlPath)) {
        Write-Host "[错误] 找不到 MySQL！" -ForegroundColor Red
        Write-Host ""
        Write-Host "尝试的位置："
        Write-Host "  - 系统 PATH 环境变量"
        Write-Host "  - $MySqlPath"
        Write-Host ""
        Write-Host "解决方案："
        Write-Host "1. 以管理员身份运行 '设置环境变量.ps1' 配置 MySQL 路径"
        Write-Host "2. 或修改此脚本中的 `$MySqlPath 变量"
        Write-Host "3. 重启电脑使环境变量生效"
        Write-Host ""
        pause
        exit 1
    }

    Write-Host "[成功] 在完整路径中找到 MySQL" -ForegroundColor Green
    $mysql = $MySqlPath
}

# 验证MySQL连接
Write-Host "正在检查 MySQL 连接..."
try {
    & $mysql -u root -p123456 -e "SELECT 1;" >$null 2>&1
    if ($?) {
        Write-Host "[成功] MySQL 连接正常" -ForegroundColor Green
    } else {
        throw "连接失败"
    }
} catch {
    Write-Host "[错误] 无法连接到 MySQL！" -ForegroundColor Red
    Write-Host ""
    Write-Host "请检查："
    Write-Host "1. MySQL 服务是否已启动"
    Write-Host "2. 用户名是否为 root"
    Write-Host "3. 密码是否为 123456"
    Write-Host ""
    Read-Host "按 Enter 键继续"
    exit 1
}

Write-Host ""

# 创建数据库并导入初始化脚本
Write-Host "[1/2] 创建数据库并导入表结构..." -ForegroundColor Cyan
$initFile = Join-Path $ProjectRoot "database\init.sql"
if (-not (Test-Path $initFile)) {
    Write-Host "[错误] 找不到 init.sql 文件" -ForegroundColor Red
    exit 1
}

& $mysql -u root -p123456 < $initFile
if ($LASTEXITCODE -ne 0) {
    Write-Host "[错误] 数据库初始化失败" -ForegroundColor Red
    exit 1
}
Write-Host "[成功] 数据库和表结构创建完成" -ForegroundColor Green

# 导入测试数据
Write-Host ""
Write-Host "[2/2] 导入测试数据..." -ForegroundColor Cyan
$testDataFile = Join-Path $ProjectRoot "database\test_data.sql"
if (-not (Test-Path $testDataFile)) {
    Write-Host "[错误] 找不到 test_data.sql 文件" -ForegroundColor Red
    exit 1
}

& $mysql -u root -p123456 meal_order_system < $testDataFile
if ($LASTEXITCODE -ne 0) {
    Write-Host "[错误] 测试数据导入失败" -ForegroundColor Red
    exit 1
}
Write-Host "[成功] 测试数据导入完成" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "数据库初始化完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "默认测试账号："
Write-Host "  管理端: admin / 123456" -ForegroundColor Yellow
Write-Host "  用户端: user001 / 123456" -ForegroundColor Yellow
Write-Host ""
Read-Host "按 Enter 键继续"
