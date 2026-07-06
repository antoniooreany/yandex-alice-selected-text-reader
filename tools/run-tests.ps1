[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

. "$PSScriptRoot\common.ps1"

try {
    Write-ProjectLog -Level "INFO" -Message "Запуск run-tests.ps1"

    if (-not (Get-Module -ListAvailable -Name Pester)) {
        throw "Pester не установлен. Установи модуль: Install-Module Pester -Scope CurrentUser"
    }

    $projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
    $testsPath = Join-Path $projectRoot "tests"

    Invoke-Pester -Path $testsPath
    Write-ProjectLog -Level "INFO" -Message "Тесты завершены успешно"
}
catch {
    Write-ProjectLog -Level "ERROR" -Message $_.Exception.Message
    Write-Error $_
    exit 1
}