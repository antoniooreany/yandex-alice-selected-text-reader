Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$runTestsPath = Join-Path $PSScriptRoot 'run-tests.ps1'
$checkRepoHealthPath = Join-Path $PSScriptRoot 'check-repo-health.ps1'
$mainScriptPath = Join-Path $projectRoot 'scripts\yandex-alice-read-selected.ahk'

Write-Host "Start-Dev: project root = $projectRoot" -ForegroundColor Cyan

if (-not (Test-Path -LiteralPath $runTestsPath)) {
    throw "Start-Dev failed: run-tests.ps1 not found at $runTestsPath"
}

if (-not (Test-Path -LiteralPath $checkRepoHealthPath)) {
    throw "Start-Dev failed: check-repo-health.ps1 not found at $checkRepoHealthPath"
}

if (-not (Test-Path -LiteralPath $mainScriptPath)) {
    throw "Start-Dev failed: main AHK script not found at $mainScriptPath"
}

Write-Host "Start-Dev: running tests..." -ForegroundColor Cyan
powershell -ExecutionPolicy Bypass -File $runTestsPath
if ($LASTEXITCODE -ne 0) {
    throw "Start-Dev failed: run-tests.ps1 exited with code $LASTEXITCODE"
}

Write-Host "Start-Dev: running repository health check..." -ForegroundColor Cyan
powershell -ExecutionPolicy Bypass -File $checkRepoHealthPath
if ($LASTEXITCODE -ne 0) {
    throw "Start-Dev failed: check-repo-health.ps1 exited with code $LASTEXITCODE"
}

Write-Host "Start-Dev: launching AutoHotkey runtime..." -ForegroundColor Cyan
Start-Process $mainScriptPath

Write-Host ""
Write-Host "Start-Dev: OK" -ForegroundColor Green
Write-Host "Next manual checks:" -ForegroundColor Green
Write-Host "  - Open a browser page with selectable text."
Write-Host "  - Select text and test F9 (primary mode)."
Write-Host "  - Test F10 (fallback mode)."
Write-Host "  - Optionally test F8 (help), if enabled in the script."
Write-Host "  - Review logs in .\logs\ahk-runtime.log and .\logs\project.log"
