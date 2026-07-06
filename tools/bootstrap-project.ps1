[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

. "$PSScriptRoot\common.ps1"

try {
    $projectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
    Write-ProjectLog -Level "INFO" -Message "Bootstrap started"

    $requiredDirs = @(
        (Join-Path $projectRoot "logs"),
        (Join-Path $projectRoot "scripts"),
        (Join-Path $projectRoot "docs"),
        (Join-Path $projectRoot "tests"),
        (Join-Path $projectRoot "tools")
    )

    foreach ($dir in $requiredDirs) {
        if (-not (Test-Path -LiteralPath $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            Write-ProjectLog -Level "INFO" -Message "Создана папка: $dir"
        }
    }

    Write-ProjectLog -Level "INFO" -Message "Bootstrap finished"
}
catch {
    Write-ProjectLog -Level "ERROR" -Message $_.Exception.Message
    Write-Error $_
    exit 1
}
