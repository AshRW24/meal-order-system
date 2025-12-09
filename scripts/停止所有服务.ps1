# PowerShell 停止所有服务脚本

# 设置UTF-8编码
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "停止所有服务" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 停止后端服务 (Port 8080)
Write-Host "正在停止后端服务 (Port 8080)..." -ForegroundColor Yellow
$port8080 = Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue | Where-Object {$_.State -eq 'Listen'}
if ($port8080) {
    $process = Get-Process -Id $port8080.OwningProcess -ErrorAction SilentlyContinue
    if ($process) {
        Stop-Process -Id $port8080.OwningProcess -Force -ErrorAction SilentlyContinue
        Write-Host "[成功] 已停止端口 8080 的进程" -ForegroundColor Green
    }
} else {
    Write-Host "[信息] 端口 8080 未被占用" -ForegroundColor Gray
}

Start-Sleep -Seconds 1

# 停止管理端服务 (Port 5173)
Write-Host "正在停止管理端 (Port 5173)..." -ForegroundColor Yellow
$port5173 = Get-NetTCPConnection -LocalPort 5173 -ErrorAction SilentlyContinue | Where-Object {$_.State -eq 'Listen'}
if ($port5173) {
    $process = Get-Process -Id $port5173.OwningProcess -ErrorAction SilentlyContinue
    if ($process) {
        Stop-Process -Id $port5173.OwningProcess -Force -ErrorAction SilentlyContinue
        Write-Host "[成功] 已停止端口 5173 的进程" -ForegroundColor Green
    }
} else {
    Write-Host "[信息] 端口 5173 未被占用" -ForegroundColor Gray
}

Start-Sleep -Seconds 1

# 停止用户端服务 (Port 5174)
Write-Host "正在停止用户端 (Port 5174)..." -ForegroundColor Yellow
$port5174 = Get-NetTCPConnection -LocalPort 5174 -ErrorAction SilentlyContinue | Where-Object {$_.State -eq 'Listen'}
if ($port5174) {
    $process = Get-Process -Id $port5174.OwningProcess -ErrorAction SilentlyContinue
    if ($process) {
        Stop-Process -Id $port5174.OwningProcess -Force -ErrorAction SilentlyContinue
        Write-Host "[成功] 已停止端口 5174 的进程" -ForegroundColor Green
    }
} else {
    Write-Host "[信息] 端口 5174 未被占用" -ForegroundColor Gray
}

# 也尝试关闭PowerShell和cmd窗口（由启动脚本创建的）
Write-Host ""
Write-Host "正在关闭后台进程窗口..." -ForegroundColor Yellow
Get-Process powershell -ErrorAction SilentlyContinue | Where-Object {$_.MainWindowTitle -like "*后端*" -or $_.MainWindowTitle -like "*管理端*" -or $_.MainWindowTitle -like "*用户端*"} | Stop-Process -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "所有服务已停止！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Read-Host "按 Enter 键继续"
