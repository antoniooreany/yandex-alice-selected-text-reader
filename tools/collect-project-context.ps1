param(
    [string]$OutputPath
)

$ErrorActionPreference = 'Continue'

$ToolsDir = $PSScriptRoot
$RepoRoot = (Resolve-Path (Join-Path $ToolsDir '..')).Path
$ArtifactsDir = Join-Path $RepoRoot 'artifacts'
$ProjectContextDir = Join-Path $ArtifactsDir 'project-context'

if (-not $OutputPath) {
    $timestampForFile = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'
    $fileName = "project-context-report_$timestampForFile.txt"
    $OutputPath = Join-Path $ProjectContextDir $fileName
}

$OutputPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputPath)

function Add-Section {
    param(
        [string]$Title,
        [scriptblock]$Body
    )

    Add-Content -Path $OutputPath -Value "`r`n============================================================"
    Add-Content -Path $OutputPath -Value $Title
    Add-Content -Path $OutputPath -Value "============================================================`r`n"

    try {
        $result = & $Body 2>&1 | Out-String
        if ([string]::IsNullOrWhiteSpace($result)) {
            Add-Content -Path $OutputPath -Value "<no output>`r`n"
        }
        else {
            Add-Content -Path $OutputPath -Value $result
        }
    }
    catch {
        Add-Content -Path $OutputPath -Value ("ERROR: " + $_.Exception.Message + "`r`n")
    }
}

function Get-LogTailSafe {
    param(
        [string]$Path,
        [int]$Tail = 200
    )

    if (Test-Path $Path) {
        Get-Content $Path -Tail $Tail
    }
    else {
        Write-Output ("{0} not found" -f $Path)
    }
}

function Select-LogLines {
    param(
        [string]$Path,
        [string[]]$Patterns,
        [int]$Tail = 4000
    )

    if (-not (Test-Path $Path)) {
        Write-Output ("{0} not found" -f $Path)
        return
    }

    $lines = Get-Content $Path -Tail $Tail
    if (-not $Patterns -or $Patterns.Count -eq 0) {
        $lines
        return
    }

    $matched = foreach ($line in $lines) {
        foreach ($pattern in $Patterns) {
            if ($line -match $pattern) {
                $line
                break
            }
        }
    }

    if ($matched) {
        $matched
    }
    else {
        Write-Output "<no matching log lines>"
    }
}

function Get-FileMetadata {
    param(
        [string]$Path
    )

    if (-not (Test-Path $Path)) {
        Write-Output ("{0} not found" -f $Path)
        return
    }

    $item = Get-Item $Path
    $lineCount = (Get-Content $Path | Measure-Object -Line).Lines
    $charCount = (Get-Content $Path -Raw).Length

    [pscustomobject]@{
        Path          = $item.FullName
        SizeBytes     = $item.Length
        LastWriteTime = $item.LastWriteTime
        LineCount     = $lineCount
        CharCount     = $charCount
    } | Format-List | Out-String
}

function Get-FileContentWithLineNumbers {
    param(
        [string]$Path
    )

    if (-not (Test-Path $Path)) {
        Write-Output ("{0} not found" -f $Path)
        return
    }

    $lineNumber = 0
    Get-Content $Path | ForEach-Object {
        $lineNumber++
        "{0:D4}: {1}" -f $lineNumber, $_
    }
}

New-Item -ItemType Directory -Force -Path $ProjectContextDir | Out-Null

if (Test-Path $OutputPath) {
    Remove-Item $OutputPath -Force
}

$timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss K'

$ReadmePath = Join-Path $RepoRoot 'README.md'
$MainAhkPath = Join-Path $RepoRoot 'scripts\yandex-alice-read-selected.ahk'
$AliceCommonPath = Join-Path $RepoRoot 'scripts\lib\alice-common.ahk'
$RunAhkPath = Join-Path $RepoRoot 'tools\run-ahk.ps1'
$RunTestsPath = Join-Path $RepoRoot 'tools\run-tests.ps1'
$RepoHealthPath = Join-Path $RepoRoot 'tools\check-repo-health.ps1'
$ProjectTestsPath = Join-Path $RepoRoot 'tests\project.tests.ps1'
$TestCasesPath = Join-Path $RepoRoot 'docs\test-cases.md'
$NotesPath = Join-Path $RepoRoot 'docs\notes.md'
$AhkRuntimeLogPath = Join-Path $RepoRoot 'logs\ahk-runtime.log'
$ProjectLogPath = Join-Path $RepoRoot 'logs\project.log'
$CollectProjectContextPath = Join-Path $RepoRoot 'tools\collect-project-context.ps1'

Add-Content -Path $OutputPath -Value "Project context report"
Add-Content -Path $OutputPath -Value "Generated: $timestamp"
Add-Content -Path $OutputPath -Value "Script dir: $ToolsDir"
Add-Content -Path $OutputPath -Value "Repo root: $RepoRoot"
Add-Content -Path $OutputPath -Value "Output path: $OutputPath`r`n"

Push-Location $RepoRoot
try {
    Add-Section 'SYSTEM INFO' {
        Write-Output "PowerShell: $($PSVersionTable.PSVersion)"
        Write-Output "OS: $([System.Environment]::OSVersion.VersionString)"
        Write-Output "User: $env:USERNAME"
        Write-Output "Computer: $env:COMPUTERNAME"
        Write-Output "Current directory: $(Get-Location)"
        Write-Output "Script dir: $ToolsDir"
        Write-Output "Repo root: $RepoRoot"
    }

    Add-Section 'AUTOHOTKEY INFO' {
        $candidates = @(
            'C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe',
            'C:\Program Files\AutoHotkey\v2\AutoHotkey.exe',
            'C:\Program Files\AutoHotkey\AutoHotkey64.exe',
            'C:\Program Files\AutoHotkey\AutoHotkey.exe',
            "$env:LOCALAPPDATA\Programs\AutoHotkey\v2\AutoHotkey64.exe",
            "$env:LOCALAPPDATA\Programs\AutoHotkey\v2\AutoHotkey.exe",
            "$env:LOCALAPPDATA\Microsoft\WindowsApps\AutoHotkeyv2.exe"
        )

        foreach ($candidate in $candidates | Select-Object -Unique) {
            Write-Output ("{0} => {1}" -f $candidate, (Test-Path $candidate))
        }

        $cmd1 = Get-Command AutoHotkey64.exe -ErrorAction SilentlyContinue
        if ($cmd1) { Write-Output "PATH AutoHotkey64.exe: $($cmd1.Source)" }

        $cmd2 = Get-Command AutoHotkey.exe -ErrorAction SilentlyContinue
        if ($cmd2) { Write-Output "PATH AutoHotkey.exe: $($cmd2.Source)" }
    }

    Add-Section 'PROJECT TREE' {
        cmd /c tree /F
    }

    Add-Section 'GIT STATUS' {
        git status
    }

    Add-Section 'GIT LOG' {
        git log --oneline -n 10
    }

    Add-Section 'GIT DIFF -- README.md' {
        git diff -- $ReadmePath
    }

    Add-Section 'GIT DIFF -- scripts/yandex-alice-read-selected.ahk' {
        git diff -- $MainAhkPath
    }

    Add-Section 'GIT DIFF -- scripts/lib/alice-common.ahk' {
        git diff -- $AliceCommonPath
    }

    Add-Section 'GIT DIFF -- tools/run-ahk.ps1' {
        git diff -- $RunAhkPath
    }

    Add-Section 'GIT DIFF -- tools/collect-project-context.ps1' {
        git diff -- $CollectProjectContextPath
    }

    Add-Section 'GIT DIFF -- tests/project.tests.ps1' {
        git diff -- $ProjectTestsPath
    }

    Add-Section 'GIT DIFF -- docs/test-cases.md' {
        git diff -- $TestCasesPath
    }

    Add-Section 'GIT DIFF -- docs/notes.md' {
        git diff -- $NotesPath
    }

    Add-Section 'FILE METADATA -- README.md' {
        Get-FileMetadata -Path $ReadmePath
    }

    Add-Section 'FILE METADATA -- scripts/yandex-alice-read-selected.ahk' {
        Get-FileMetadata -Path $MainAhkPath
    }

    Add-Section 'FILE METADATA -- scripts/lib/alice-common.ahk' {
        Get-FileMetadata -Path $AliceCommonPath
    }

    Add-Section 'FILE METADATA -- tools/run-ahk.ps1' {
        Get-FileMetadata -Path $RunAhkPath
    }

    Add-Section 'FILE METADATA -- tools/collect-project-context.ps1' {
        Get-FileMetadata -Path $CollectProjectContextPath
    }

    Add-Section 'FILE METADATA -- tests/project.tests.ps1' {
        Get-FileMetadata -Path $ProjectTestsPath
    }

    Add-Section 'FILE METADATA -- docs/test-cases.md' {
        Get-FileMetadata -Path $TestCasesPath
    }

    Add-Section 'FILE METADATA -- docs/notes.md' {
        Get-FileMetadata -Path $NotesPath
    }

    Add-Section 'FILE CONTENT -- README.md' {
        Get-Content $ReadmePath -Raw
    }

    Add-Section 'FILE CONTENT -- scripts/yandex-alice-read-selected.ahk' {
        Get-Content $MainAhkPath -Raw
    }

    Add-Section 'FILE CONTENT -- scripts/lib/alice-common.ahk' {
        Get-Content $AliceCommonPath -Raw
    }

    Add-Section 'FILE CONTENT -- tools/run-ahk.ps1' {
        Get-Content $RunAhkPath -Raw
    }

    Add-Section 'FILE CONTENT -- tools/collect-project-context.ps1' {
        Get-Content $CollectProjectContextPath -Raw
    }

    Add-Section 'FILE CONTENT -- tests/project.tests.ps1' {
        Get-Content $ProjectTestsPath -Raw
    }

    Add-Section 'FILE CONTENT -- docs/test-cases.md' {
        Get-Content $TestCasesPath -Raw
    }

    Add-Section 'FILE CONTENT -- docs/notes.md' {
        Get-Content $NotesPath -Raw
    }

    Add-Section 'FILE CONTENT WITH LINE NUMBERS -- docs/test-cases.md' {
        Get-FileContentWithLineNumbers -Path $TestCasesPath
    }

    Add-Section 'LOG FILE -- logs/ahk-runtime.log (tail 200)' {
        Get-LogTailSafe -Path $AhkRuntimeLogPath -Tail 200
    }

    Add-Section 'LOG FILE -- logs/project.log (tail 200)' {
        Get-LogTailSafe -Path $ProjectLogPath -Tail 200
    }

    Add-Section 'LOG FILTER -- F9/F11/F12 hotkeys and flow markers' {
        Select-LogLines -Path $AhkRuntimeLogPath -Tail 4000 -Patterns @(
            'Hotkey pressed F9',
            'Hotkey pressed CtrlF11',
            'Hotkey pressed CtrlF12',
            'FLOWSTART',
            'FLOWDONE',
            'FLOWCANCELLED',
            'FLOWFAIL'
        )
    }

    Add-Section 'LOG FILTER -- debug contract markers' {
        Select-LogLines -Path $AhkRuntimeLogPath -Tail 4000 -Patterns @(
            'TIMINGPROFILE',
            'contextMenuOpenDelayMs',
            'menuStepDelayMs',
            'beforeEnterDelayMs',
            'stepDebug='
        )
    }

    Add-Section 'LOG FILTER -- F12 step-debug markers' {
        Select-LogLines -Path $AhkRuntimeLogPath -Tail 4000 -Patterns @(
            'Hotkey pressed CtrlF12',
            'CtrlF12 step debug AppsKey menu item',
            'FLOWSTART',
            'STEPSTART',
            'STEPPROMPT',
            'STEPCONFIRMED',
            'STEPDONE',
            'FLOWDONE',
            'FLOWCANCELLED',
            'FLOWFAIL',
            'replayall',
            'replay-without-confirmations'
        )
    }

    Add-Section 'LOG FILTER -- choosecurrentmenuitem and Enter markers' {
        Select-LogLines -Path $AhkRuntimeLogPath -Tail 4000 -Patterns @(
            'STEPSTART choosecurrentmenuitem',
            'STEPDETAIL choosecurrentmenuitem',
            'sentKey=Enter',
            'STEPDONE choosecurrentmenuitem'
        )
    }

    Add-Section 'LOG FILTER -- cancellation markers' {
        Select-LogLines -Path $AhkRuntimeLogPath -Tail 4000 -Patterns @(
            'Cancel',
            'FLOWCANCELLED',
            'FLOWFAIL'
        )
    }

    Add-Section 'TEST OUTPUT -- run-tests.ps1' {
        powershell -ExecutionPolicy Bypass -File $RunTestsPath
    }

    Add-Section 'TEST OUTPUT -- check-repo-health.ps1' {
        if (Test-Path $RepoHealthPath) {
            powershell -ExecutionPolicy Bypass -File $RepoHealthPath
        }
        else {
            Write-Output 'tools/check-repo-health.ps1 not found'
        }
    }

    Add-Section 'SMOKE TEST COMMANDS' {
        Write-Output 'Run tests:'
        Write-Output 'powershell -ExecutionPolicy Bypass -File .\tools\run-tests.ps1'
        Write-Output ''
        Write-Output 'Run AHK:'
        Write-Output 'powershell -ExecutionPolicy Bypass -File .\tools\run-ahk.ps1'
        Write-Output ''
        Write-Output 'Collect context report:'
        Write-Output 'powershell -ExecutionPolicy Bypass -File .\tools\collect-project-context.ps1'
        Write-Output ''
        Write-Output 'Watch runtime log:'
        Write-Output 'Get-Content .\logs\ahk-runtime.log -Wait'
        Write-Output ''
        Write-Output 'Tail runtime log:'
        Write-Output 'Get-Content .\logs\ahk-runtime.log -Tail 50'
        Write-Output ''
        Write-Output 'Expected F12 normal path: FLOWDONE without FLOWFAIL'
        Write-Output 'Expected F12 cancel path: FLOWCANCELLED without FLOWFAIL'
    }
}
finally {
    Pop-Location
}

Write-Host "Saved report to: $OutputPath"