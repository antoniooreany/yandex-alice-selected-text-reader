$scriptPath = Join-Path $PSScriptRoot '..\scripts\yandex-alice-read-selected.ahk'
$resolvedScriptPath = (Resolve-Path $scriptPath).Path
Start-Process $resolvedScriptPath
