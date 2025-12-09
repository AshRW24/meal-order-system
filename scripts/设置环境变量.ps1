# PowerShell MySQL 环境变量配置脚本
# 需要以管理员身份运行

# 设置UTF-8编码
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Windows 环境变量配置向导" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 检查是否管理员运行
$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object System.Security.Principal.WindowsPrincipal($currentUser)
if (-not $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[错误] 此脚本需要管理员权限！" -ForegroundColor Red
    Write-Host ""
    Write-Host "请以管理员身份运行："
    Write-Host "1. 右键点击此脚本"
    Write-Host "2. 选择 'Run with PowerShell' 中的 '以管理员身份运行'"
    Write-Host ""
    Read-Host "按 Enter 键继续"
    exit 1
}

$MySqlPath = "C:\Program Files\MySQL\MySQL Server 8.0\bin"

Write-Host "检查 MySQL 路径是否存在..."
if (-not (Test-Path $MySqlPath)) {
    Write-Host "[错误] 找不到 MySQL: $MySqlPath" -ForegroundColor Red
    Write-Host ""
    Write-Host "请手动设置正确的 MySQL 安装路径" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "按 Enter 键继续"
    exit 1
}

Write-Host "[成功] 找到 MySQL" -ForegroundColor Green
Write-Host ""

# 获取当前PATH
$currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")

# 检查MySQL路径是否已在PATH中
if ($currentPath -contains $MySqlPath) {
    Write-Host "[信息] MySQL 已在 PATH 环境变量中" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "按 Enter 键继续"
    exit 0
}

Write-Host "正在添加 MySQL 到系统 PATH 环境变量..." -ForegroundColor Yellow

# 添加MySQL路径到PATH
$newPath = "$MySqlPath;$currentPath"
[Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")

Write-Host "[成功] PATH 环境变量已更新" -ForegroundColor Green
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "配置完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "重要: 您需要重启电脑才能使环境变量生效" -ForegroundColor Yellow
Write-Host ""
Write-Host "配置的路径: $MySqlPath" -ForegroundColor Cyan
Write-Host ""

$choice = Read-Host "是否现在重启电脑？(Y/N)"
if ($choice -eq "Y" -or $choice -eq "y") {
    Write-Host "准备重启电脑..." -ForegroundColor Yellow
    Start-Sleep -Seconds 3
    Restart-Computer -Force
} else {
    Write-Host "请手动重启电脑以使设置生效" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "按 Enter 键继续"
}
