Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ProjectRoot = Split-Path -Parent $PSScriptRoot

Write-Host "Check-Repo-Health: starting for Alice at '$ProjectRoot'" -ForegroundColor Cyan

$codeminderPath = Join-Path $ProjectRoot 'codeminder'

if (Test-Path $codeminderPath) {
    Write-Error "Healthcheck failed: unexpected 'codeminder' folder present at '$codeminderPath'."
    exit 1
}

$gitRoots = Get-ChildItem -Path $ProjectRoot -Directory -Recurse -Filter '.git' -ErrorAction SilentlyContinue

$unexpectedNestedGit = @()

foreach ($gitDir in $gitRoots) {
    if ($gitDir.FullName -eq (Join-Path $ProjectRoot '.git')) {
        continue
    }
    $unexpectedNestedGit += $gitDir.FullName
}

if ($unexpectedNestedGit.Count -gt 0) {
    Write-Error "Healthcheck failed: unexpected nested .git directories detected:`n$($unexpectedNestedGit -join [Environment]::NewLine)"
    exit 1
}

$runTestsPath = Join-Path $ProjectRoot 'tools\run-tests.ps1'

if (-not (Test-Path $runTestsPath)) {
    Write-Error "Healthcheck failed: tools\run-tests.ps1 is missing at '$runTestsPath'."
    exit 1
}

Write-Host "Check-Repo-Health: running tools\run-tests.ps1..." -ForegroundColor Cyan

$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = 'powershell.exe'
$psi.Arguments = "-ExecutionPolicy Bypass -File `"$runTestsPath`""
$psi.WorkingDirectory = $ProjectRoot
$psi.UseShellExecute = $false
$psi.RedirectStandardOutput = $true
$psi.RedirectStandardError = $true

$process = New-Object System.Diagnostics.Process
$process.StartInfo = $psi
[void]$process.Start()

$stdout = $process.StandardOutput.ReadToEnd()
$stderr = $process.StandardError.ReadToEnd()

$process.WaitForExit()
$exitCode = $process.ExitCode

Write-Host $stdout

if ($stderr) {
    Write-Host $stderr -ForegroundColor Yellow
}

if ($exitCode -ne 0) {
    Write-Error "Healthcheck failed: run-tests.ps1 exited with code $exitCode."
    exit $exitCode
}

Write-Host "Check-Repo-Health: OK (tests passed, no unexpected nested .git, 'codeminder' absent)." -ForegroundColor Green
exit 0