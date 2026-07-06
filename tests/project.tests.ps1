BeforeAll {
    $ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
}

Describe "Project structure" {
    It "has README.md" {
        Test-Path (Join-Path $ProjectRoot "README.md") | Should -BeTrue
    }

    It "has main AHK script" {
        Test-Path (Join-Path $ProjectRoot "scripts\yandex-alice-read-selected.ahk") | Should -BeTrue
    }

    It "has tools\run-tests.ps1" {
        Test-Path (Join-Path $ProjectRoot "tools\run-tests.ps1") | Should -BeTrue
    }

    It "has docs\test-cases.md" {
        Test-Path (Join-Path $ProjectRoot "docs\test-cases.md") | Should -BeTrue
    }

    It "has logs directory" {
        Test-Path (Join-Path $ProjectRoot "logs") | Should -BeTrue
    }
}

Describe "Project content" {
    It "README mentions AutoHotkey" {
        $content = Get-Content (Join-Path $ProjectRoot "README.md") -Raw
        $content | Should -Match "AutoHotkey"
    }

    It "AHK script contains MAIN_MENU_INDEX" {
        $content = Get-Content (Join-Path $ProjectRoot "scripts\yandex-alice-read-selected.ahk") -Raw
        $content | Should -Match "MAIN_MENU_INDEX"
    }

    It "AHK script contains WriteLog" {
        $content = Get-Content (Join-Path $ProjectRoot "scripts\yandex-alice-read-selected.ahk") -Raw
        $content | Should -Match "WriteLog"
    }
}