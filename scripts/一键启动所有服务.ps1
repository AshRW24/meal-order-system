# PowerShell 一键启动所有服务脚本
# 需要以管理员身份运行

# 获取项目根目录
$ProjectRoot = Split-Path -Parent $PSScriptRoot

# 设置UTF-8编码
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "一键启动所有服务" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "项目根目录: $ProjectRoot"
Write-Host ""

# 检查是否管理员运行
$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object System.Security.Principal.WindowsPrincipal($currentUser)
if (-not $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[警告] 建议以管理员身份运行此脚本" -ForegroundColor Yellow
    Write-Host ""
}

# 检查和安装前端依赖
Write-Host "[1/4] 检查依赖..." -ForegroundColor Cyan

$adminNodeModules = Join-Path $ProjectRoot "frontend-admin\node_modules"
if (-not (Test-Path $adminNodeModules)) {
    Write-Host "[正在安装] 管理端依赖..." -ForegroundColor Yellow
    $adminPath = Join-Path $ProjectRoot "frontend-admin"
    Push-Location $adminPath
    & npm install
    Pop-Location
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[错误] 管理端依赖安装失败" -ForegroundColor Red
        exit 1
    }
}
Write-Host "[成功] 管理端依赖检查完成" -ForegroundColor Green

$userNodeModules = Join-Path $ProjectRoot "frontend-user\node_modules"
if (-not (Test-Path $userNodeModules)) {
    Write-Host "[正在安装] 用户端依赖..." -ForegroundColor Yellow
    $userPath = Join-Path $ProjectRoot "frontend-user"
    Push-Location $userPath
    & npm install
    Pop-Location
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[错误] 用户端依赖安装失败" -ForegroundColor Red
        exit 1
    }
}
Write-Host "[成功] 用户端依赖检查完成" -ForegroundColor Green

Write-Host ""

# 启动后端
Write-Host "[2/4] 启动后端服务 (Port 8080)..." -ForegroundColor Cyan
$backendPath = Join-Path $ProjectRoot "backend"
Start-Process -WorkingDirectory $backendPath -FileName "powershell.exe" -ArgumentList "-Command cd '$backendPath'; mvn spring-boot:run" -WindowStyle Normal

Start-Sleep -Seconds 8

# 启动管理端
Write-Host "[3/4] 启动管理端 (Port 5173)..." -ForegroundColor Cyan
$adminPath = Join-Path $ProjectRoot "frontend-admin"
Start-Process -WorkingDirectory $adminPath -FileName "powershell.exe" -ArgumentList "-Command cd '$adminPath'; npm run dev" -WindowStyle Normal

Start-Sleep -Seconds 3

# 启动用户端
Write-Host "[4/4] 启动用户端 (Port 5174)..." -ForegroundColor Cyan
$userPath = Join-Path $ProjectRoot "frontend-user"
Start-Process -WorkingDirectory $userPath -FileName "powershell.exe" -ArgumentList "-Command cd '$userPath'; npm run dev" -WindowStyle Normal

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "所有服务已启动！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "访问地址："
Write-Host "  后端API:  http://localhost:8080/api" -ForegroundColor Yellow
Write-Host "  API文档:  http://localhost:8080/api/doc.html" -ForegroundColor Yellow
Write-Host "  管理端:   http://localhost:5173" -ForegroundColor Yellow
Write-Host "  用户端:   http://localhost:5174" -ForegroundColor Yellow
Write-Host ""
Write-Host "默认账号："
Write-Host "  管理端: admin / 123456" -ForegroundColor Yellow
Write-Host "  用户端: user001 / 123456" -ForegroundColor Yellow
Write-Host ""
Write-Host "提示：首次启动后端需要 30-60 秒编译" -ForegroundColor Yellow
Write-Host ""
Read-Host "按 Enter 键继续"
