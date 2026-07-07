param(
    [string]$ScriptName = 'yandex-alice-read-selected.ahk',
    [switch]$Wait
)

$ErrorActionPreference = 'Stop'

$scriptPath = Join-Path $PSScriptRoot "..\scripts\$ScriptName"
$resolvedScriptPath = (Resolve-Path $scriptPath).Path

$ahkExe = 'C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe'
if (-not (Test-Path $ahkExe)) {
    $ahkExe = 'C:\Program Files\AutoHotkey\v2\AutoHotkey.exe'
}

if (-not (Test-Path $ahkExe)) {
    Write-Host 'ERROR: AutoHotkey v2 executable not found.' -ForegroundColor Red
    Write-Host 'Expected path example: C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe' -ForegroundColor Yellow
    exit 1
}

Write-Host 'Starting AutoHotkey v2...' -ForegroundColor Cyan
Write-Host "  Interpreter: $ahkExe" -ForegroundColor Cyan
Write-Host "  Script     : $resolvedScriptPath" -ForegroundColor Cyan
Write-Host "  Wait mode  : $Wait" -ForegroundColor Cyan

$startParams = @{
    FilePath     = $ahkExe
    ArgumentList = @($resolvedScriptPath)
}

if ($Wait) {
    $startParams['Wait'] = $true
}

Start-Process @startParams