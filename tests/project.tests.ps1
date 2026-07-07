BeforeAll {
    $ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
    $MainAhkPath = Join-Path $ProjectRoot "scripts\yandex-alice-read-selected.ahk"
    $RunTestsPath = Join-Path $ProjectRoot "tools\run-tests.ps1"
    $ReadmePath = Join-Path $ProjectRoot "README.md"
    $DocsPath = Join-Path $ProjectRoot "docs\test-cases.md"
    $LogsPath = Join-Path $ProjectRoot "logs"

    $AhkContent = Get-Content $MainAhkPath -Raw
    $ReadmeContent = Get-Content $ReadmePath -Raw
}

Describe "Project structure" {
    It "has README.md" {
        Test-Path $ReadmePath | Should -BeTrue
    }

    It "has main AHK script" {
        Test-Path $MainAhkPath | Should -BeTrue
    }

    It "has tools\run-tests.ps1" {
        Test-Path $RunTestsPath | Should -BeTrue
    }

    It "has docs\test-cases.md" {
        Test-Path $DocsPath | Should -BeTrue
    }

    It "has logs directory" {
        Test-Path $LogsPath | Should -BeTrue
    }
}

Describe "Project content" {
    It "README mentions AutoHotkey" {
        $ReadmeContent | Should -Match "AutoHotkey"
    }

    It "AHK script contains MENU_ITEM_INDEX" {
        $AhkContent | Should -Match "MENU_ITEM_INDEX"
    }

    It "AHK script contains MENU_OPEN_KEYS" {
        $AhkContent | Should -Match "MENU_OPEN_KEYS"
    }

    It "AHK script uses AppsKey" {
        $AhkContent | Should -Match "AppsKey"
    }

    It "AHK script contains WriteLog" {
        $AhkContent | Should -Match "WriteLog"
    }

    It "AHK script binds F8" {
        $AhkContent | Should -Match "F8::"
    }

    It "AHK script binds F9" {
        $AhkContent | Should -Match "F9::"
    }

    It "AHK script does not require F10" {
        $AhkContent | Should -Not -Match "F10::"
    }
}