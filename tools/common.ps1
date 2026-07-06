Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-ProjectLog {
    param(
        [Parameter(Mandatory)]
        [string]$Level,

        [Parameter(Mandatory)]
        [string]$Message,

        [string]$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
    )

    $logDir = Join-Path $ProjectRoot "logs"
    if (-not (Test-Path -LiteralPath $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }

    $logFile = Join-Path $logDir "project.log"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $logFile -Value "[$Level] $timestamp $Message" -Encoding UTF8
}
