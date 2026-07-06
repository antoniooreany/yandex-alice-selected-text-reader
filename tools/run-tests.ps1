Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$TestPath = Join-Path $ProjectRoot 'tests\project.tests.ps1'

if (-not (Test-Path $TestPath)) {
    throw "Test file not found: $TestPath"
}

$loadedPester = $null

try {
    Import-Module Pester -MinimumVersion 5.0.0 -Force -ErrorAction Stop
    $loadedPester = Get-Module Pester | Sort-Object Version -Descending | Select-Object -First 1
}
catch {
    $pesterCandidate = Get-Module -ListAvailable Pester |
        Where-Object { $_.Version -ge [version]'5.0.0' } |
        Sort-Object Version -Descending |
        Select-Object -First 1

    if ($null -ne $pesterCandidate) {
        Import-Module $pesterCandidate.Path -Force -ErrorAction Stop
        $loadedPester = Get-Module Pester | Sort-Object Version -Descending | Select-Object -First 1
    }
}

if ($null -eq $loadedPester) {
    $userScopedPesterManifest = Join-Path $HOME 'OneDrive\Documents\PowerShell\Modules\Pester\5.8.0\Pester.psd1'

    if (Test-Path $userScopedPesterManifest) {
        Import-Module $userScopedPesterManifest -Force -ErrorAction Stop
        $loadedPester = Get-Module Pester | Sort-Object Version -Descending | Select-Object -First 1
    }
}

if ($null -eq $loadedPester) {
    throw "Pester 5+ could not be loaded. Checked module auto-discovery and explicit user module path."
}

if (-not (Get-Command Invoke-Pester -ErrorAction SilentlyContinue)) {
    throw "Invoke-Pester is not available after loading Pester."
}

if (-not (Get-Command New-PesterConfiguration -ErrorAction SilentlyContinue)) {
    throw "New-PesterConfiguration is not available after loading Pester. Ensure Pester 5+ is loaded."
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