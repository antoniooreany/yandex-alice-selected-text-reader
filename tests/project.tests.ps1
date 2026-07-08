BeforeAll {
    $ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
}

Describe "Project structure" {
    It "has README.md" {
        Test-Path (Join-Path $ProjectRoot 'README.md') | Should -BeTrue
    }

    It "has main AHK script" {
        Test-Path (Join-Path $ProjectRoot 'scripts\yandex-alice-read-selected.ahk') | Should -BeTrue
    }

    It "has tools\run-tests.ps1" {
        Test-Path (Join-Path $ProjectRoot 'tools\run-tests.ps1') | Should -BeTrue
    }

    It "has docs\test-cases.md" {
        Test-Path (Join-Path $ProjectRoot 'docs\test-cases.md') | Should -BeTrue
    }

    It "has logs directory" {
        Test-Path (Join-Path $ProjectRoot 'logs') | Should -BeTrue
    }
}

Describe "Project content" {
    It "README mentions AutoHotkey" {
        $content = Get-Content (Join-Path $ProjectRoot 'README.md') -Raw
        $content | Should -Match 'AutoHotkey'
    }

    It "AHK script contains MAINMENUINDEX" {
        $content = Get-Content (Join-Path $ProjectRoot 'scripts\yandex-alice-read-selected.ahk') -Raw
        $content | Should -Match 'MAINMENUINDEX'
    }

    It "AHK script contains WriteLog" {
        $content = Get-Content (Join-Path $ProjectRoot 'scripts\yandex-alice-read-selected.ahk') -Raw
        $content | Should -Match 'WriteLog'
    }

    It "AHK shared library contains FLOW_START logging marker" {
        $content = Get-Content (Join-Path $ProjectRoot 'scripts\lib\alice-common.ahk') -Raw
        $content | Should -Match 'FLOW_START'
    }

    It "AHK shared library contains FLOW_DONE logging marker" {
        $content = Get-Content (Join-Path $ProjectRoot 'scripts\lib\alice-common.ahk') -Raw
        $content | Should -Match 'FLOW_DONE'
    }

    It "AHK shared library contains FLOW_FAIL logging marker" {
        $content = Get-Content (Join-Path $ProjectRoot 'scripts\lib\alice-common.ahk') -Raw
        $content | Should -Match 'FLOW_FAIL'
    }

    It "AHK shared library contains FLOW_CANCELLED logging marker" {
        $content = Get-Content (Join-Path $ProjectRoot 'scripts\lib\alice-common.ahk') -Raw
        $content | Should -Match 'FLOW_CANCELLED'
    }

    It "AHK shared library contains ConfirmStep helper" {
        $content = Get-Content (Join-Path $ProjectRoot 'scripts\lib\alice-common.ahk') -Raw
        $content | Should -Match 'ConfirmStep'
    }

    It "AHK shared library uses MsgBox for step debug confirmation" {
        $content = Get-Content (Join-Path $ProjectRoot 'scripts\lib\alice-common.ahk') -Raw
        $content | Should -Match 'MsgBox'
    }

    It "AHK shared library supports stepDebug parameter in flow" {
        $content = Get-Content (Join-Path $ProjectRoot 'scripts\lib\alice-common.ahk') -Raw
        $content | Should -Match 'stepDebug := false'
    }

    It "AHK shared library contains open_context_menu step logging" {
        $content = Get-Content (Join-Path $ProjectRoot 'scripts\lib\alice-common.ahk') -Raw
        $content | Should -Match 'STEP_START open_context_menu'
    }

    It "AHK shared library contains move_to_menu_item step logging" {
        $content = Get-Content (Join-Path $ProjectRoot 'scripts\lib\alice-common.ahk') -Raw
        $content | Should -Match 'STEP_START move_to_menu_item'
    }

    It "AHK shared library contains choose_current_menu_item step logging" {
        $content = Get-Content (Join-Path $ProjectRoot 'scripts\lib\alice-common.ahk') -Raw
        $content | Should -Match 'STEP_START choose_current_menu_item'
    }

    It "AHK script logs F8 hotkey in stable format" {
        $content = Get-Content (Join-Path $ProjectRoot 'scripts\yandex-alice-read-selected.ahk') -Raw
        $content | Should -Match 'Hotkey pressed: F8'
    }

    It "AHK script logs F9 hotkey in stable format" {
        $content = Get-Content (Join-Path $ProjectRoot 'scripts\yandex-alice-read-selected.ahk') -Raw
        $content | Should -Match 'Hotkey pressed: F9'
    }

    It "AHK script logs Ctrl+F12 hotkey in stable format" {
        $content = Get-Content (Join-Path $ProjectRoot 'scripts\yandex-alice-read-selected.ahk') -Raw
        $content | Should -Match 'Hotkey pressed: Ctrl\+F12'
    }

    It "AHK script help mentions Ctrl+F12 step debug mode" {
        $content = Get-Content (Join-Path $ProjectRoot 'scripts\yandex-alice-read-selected.ahk') -Raw
        $content | Should -Match 'Ctrl\+F12 - step debug primary Alice flow'
    }

    It "AHK script binds Ctrl+F12 to step debug primary flow" {
        $content = Get-Content (Join-Path $ProjectRoot 'scripts\yandex-alice-read-selected.ahk') -Raw
        $content | Should -Match '\^F12::'
        $content | Should -Match 'ReadSelectedTextByIndex\(MAINMENUINDEX, "Ctrl\+F12 / step debug AppsKey menu item 6", true\)'
    }
}