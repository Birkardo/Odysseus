# Start Odysseus from PowerShell.
# This replaces start_odysseus.bat with a native PowerShell wrapper.

[CmdletBinding()]
param(
    [int]$Port = 7000,
    [switch]$Minimized
)

# Support legacy or registry-passed `--minimized` argument.
if ($args -contains '--minimized') {
    $Minimized = $true
}

$windowStyle = if ($Minimized) { 'Minimized' } else { 'Normal' }

$ErrorActionPreference = 'Stop'
Set-Location -Path $PSScriptRoot

$launchScript = Join-Path $PSScriptRoot 'launch-windows.ps1'
if (-not (Test-Path $launchScript)) {
    Write-Error "Cannot find launch-windows.ps1 in $PSScriptRoot"
    exit 1
}

Write-Host "Starting Odysseus server in a new PowerShell window..." -ForegroundColor Cyan
$serverProcess = Start-Process -FilePath (Get-Command powershell).Source -ArgumentList @(
    '-NoProfile',
    '-ExecutionPolicy', 'Bypass',
    '-WindowStyle', $windowStyle,
    '-File', $launchScript,
    '-Port', $Port
) -PassThru
Write-Host "Server window started (PID $($serverProcess.Id))." -ForegroundColor Green

$monitorCommand = '$port = ' + $Port + '; $connected = $false; while ($true) { $connection = Get-NetTCPConnection -LocalPort $port -State Established -ErrorAction SilentlyContinue; if ($connection) { if (-not $connected) { $connected = $true; Write-Host "[CONNECTED] A client is now connected to port $port." -ForegroundColor Green; [console]::beep(750,300) } else { Write-Host "[CONNECTED] Port $port still has an active connection." -ForegroundColor DarkGreen } } else { if ($connected) { $connected = $false; Write-Host "[DISCONNECTED] No active connection on port $port." -ForegroundColor Yellow } else { Write-Host "[WAITING] No active connection on port $port." -ForegroundColor DarkGray } }; Start-Sleep -Seconds 300 }'
Write-Host "Starting monitor in a second PowerShell window with 5-minute checks..." -ForegroundColor Cyan
$monitorProcess = Start-Process -FilePath (Get-Command powershell).Source -ArgumentList @(
    '-NoProfile',
    '-ExecutionPolicy', 'Bypass',
    '-WindowStyle', $windowStyle,
    '-Command', $monitorCommand
) -PassThru
Write-Host "Monitor window started (PID $($monitorProcess.Id))." -ForegroundColor Green
Write-Host "Done. Two PowerShell windows are running." -ForegroundColor Cyan
