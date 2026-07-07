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

New-Item -ItemType Directory -Force -Path $ProjectContextDir | Out-Null

if (Test-Path $OutputPath) {
    Remove-Item $OutputPath -Force
}

$timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss K'

$MainAhkPath = Join-Path $RepoRoot 'scripts\yandex-alice-read-selected.ahk'
$AliceCommonPath = Join-Path $RepoRoot 'scripts\lib\alice-common.ahk'
$RunAhkPath = Join-Path $RepoRoot 'tools\run-ahk.ps1'
$RunTestsPath = Join-Path $RepoRoot 'tools\run-tests.ps1'
$RepoHealthPath = Join-Path $RepoRoot 'tools\check-repo-health.ps1'
$ProjectTestsPath = Join-Path $RepoRoot 'tests\project.tests.ps1'
$AhkRuntimeLogPath = Join-Path $RepoRoot 'logs\ahk-runtime.log'
$ProjectLogPath = Join-Path $RepoRoot 'logs\project.log'

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

    Add-Section 'GIT DIFF -- scripts/yandex-alice-read-selected.ahk' {
        git diff -- $MainAhkPath
    }

    Add-Section 'GIT DIFF -- scripts/lib/alice-common.ahk' {
        git diff -- $AliceCommonPath
    }

    Add-Section 'GIT DIFF -- tools/run-ahk.ps1' {
        git diff -- $RunAhkPath
    }

    Add-Section 'GIT DIFF -- tests/project.tests.ps1' {
        git diff -- $ProjectTestsPath
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

    Add-Section 'FILE CONTENT -- tests/project.tests.ps1' {
        Get-Content $ProjectTestsPath -Raw
    }

    Add-Section 'LOG FILE -- logs/ahk-runtime.log' {
        if (Test-Path $AhkRuntimeLogPath) {
            Get-Content $AhkRuntimeLogPath -Raw
        }
        else {
            Write-Output 'logs/ahk-runtime.log not found'
        }
    }

    Add-Section 'LOG FILE -- logs/project.log' {
        if (Test-Path $ProjectLogPath) {
            Get-Content $ProjectLogPath -Raw
        }
        else {
            Write-Output 'logs/project.log not found'
        }
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
}
finally {
    Pop-Location
}

Write-Host "Saved report to: $OutputPath"