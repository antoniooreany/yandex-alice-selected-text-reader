Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module Pester -MinimumVersion 5.0.0 -Force

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$TestPath = Join-Path $ProjectRoot 'tests\project.tests.ps1'

if (-not (Test-Path $TestPath)) {
    throw "Test file not found: $TestPath"
}

if (-not (Get-Command Invoke-Pester -ErrorAction SilentlyContinue)) {
    throw "Invoke-Pester is not available. Install Pester first."
}

if (-not (Get-Command New-PesterConfiguration -ErrorAction SilentlyContinue)) {
    throw "New-PesterConfiguration is not available. Ensure Pester 5+ is installed and imported."
}

$configuration = New-PesterConfiguration
$configuration.Run.Path = $TestPath
$configuration.Run.PassThru = $true
$configuration.Output.Verbosity = 'Detailed'

$result = Invoke-Pester -Configuration $configuration

if ($null -eq $result) {
    throw "Pester did not return a result object."
}

if ($result.FailedCount -gt 0) {
    exit 1
}

exit 0