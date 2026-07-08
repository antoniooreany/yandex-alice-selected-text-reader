BeforeAll {
    $ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
    $ReadmePath = Join-Path $ProjectRoot "README.md"
    $MainAhkPath = Join-Path $ProjectRoot "scripts\yandex-alice-read-selected.ahk"
    $CommonAhkPath = Join-Path $ProjectRoot "scripts\lib\alice-common.ahk"
    $TestCasesPath = Join-Path $ProjectRoot "docs\test-cases.md"

    $Readme = Get-Content $ReadmePath -Raw
    $MainAhk = Get-Content $MainAhkPath -Raw
    $CommonAhk = Get-Content $CommonAhkPath -Raw
    $TestCases = Get-Content $TestCasesPath -Raw
}

Describe "Project structure" {
    It "has README.md" {
        Test-Path (Join-Path $ProjectRoot "README.md") | Should -BeTrue
    }

    It "has main AHK script" {
        Test-Path (Join-Path $ProjectRoot "scripts\yandex-alice-read-selected.ahk") | Should -BeTrue
    }

    It "has shared AHK library" {
        Test-Path (Join-Path $ProjectRoot "scripts\lib\alice-common.ahk") | Should -BeTrue
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

Describe "README contract" {
    It "README mentions AutoHotkey" {
        $Readme | Should -Match "AutoHotkey"
    }

    It "README mentions F8 help hotkey" {
        $Readme | Should -Match "F8"
    }

    It "README mentions F9 primary action hotkey" {
        $Readme | Should -Match "F9"
    }

    It "README mentions F10 secondary action hotkey" {
        $Readme | Should -Match "F10"
    }

    It "README mentions CtrlF11 debug flow" {
        $Readme | Should -Match "Ctrl\+?F11"
    }

    It "README mentions CtrlF12 step-debug flow" {
        $Readme | Should -Match "Ctrl\+?F12"
    }

    It "README mentions runtime log path" {
        $Readme | Should -Match "logs[\\/]+ahk-runtime\.log"
    }

    It "README mentions FLOWSTART marker" {
        $Readme | Should -Match "FLOWSTART"
    }

    It "README mentions FLOWDONE marker" {
        $Readme | Should -Match "FLOWDONE"
    }

    It "README mentions FLOWCANCELLED marker" {
        $Readme | Should -Match "FLOWCANCELLED"
    }

    It "README mentions FLOWFAIL marker" {
        $Readme | Should -Match "FLOWFAIL"
    }

    It "README mentions replay confirmation contract" {
        $Readme | Should -Match "Replay all steps without confirmations\?"
    }
}

Describe "Main AHK script contract" {
    It "AHK script contains MAIN_MENU_INDEX" {
        $MainAhk | Should -Match "MAIN_MENU_INDEX"
    }

    It "AHK script contains ALT_MENU_INDEX" {
        $MainAhk | Should -Match "ALT_MENU_INDEX"
    }

    It "AHK script contains WriteLog usage" {
        $MainAhk | Should -Match "WriteLog"
    }

    It "AHK script logs F8 hotkey in stable format" {
        $MainAhk | Should -Match "Hotkey pressed F8"
    }

    It "AHK script logs F9 hotkey in stable format" {
        $MainAhk | Should -Match "Hotkey pressed F9"
    }

    It "AHK script logs F10 hotkey in stable format" {
        $MainAhk | Should -Match "Hotkey pressed F10"
    }

    It "AHK script logs CtrlF11 hotkey in stable format" {
        $MainAhk | Should -Match "Hotkey pressed CtrlF11"
    }

    It "AHK script logs CtrlF12 hotkey in stable format" {
        $MainAhk | Should -Match "Hotkey pressed CtrlF12"
    }

    It "AHK script help mentions CtrlF11 debug mode" {
        $MainAhk | Should -Match "Ctrl\+F11 - debug primary Alice flow"
    }

    It "AHK script help mentions CtrlF12 step-debug mode" {
        $MainAhk | Should -Match "Ctrl\+F12 - step debug primary Alice flow"
    }

    It "AHK script binds CtrlF11 to primary debug flow without step-debug flag" {
        $MainAhk | Should -Match "\^F11::"
        $MainAhk | Should -Match "ReadSelectedTextByIndex\(MAIN_MENU_INDEX,\s*""CtrlF11 debug AppsKey menu item """
        $MainAhk | Should -Match "CtrlF11 debug AppsKey menu item "" MAIN_MENU_INDEX,\s*false\)"
    }

    It "AHK script binds CtrlF12 to step-debug primary flow" {
        $MainAhk | Should -Match "\^F12::"
        $MainAhk | Should -Match "ReadSelectedTextByIndex\(MAIN_MENU_INDEX,\s*""CtrlF12 step debug AppsKey menu item """
        $MainAhk | Should -Match "CtrlF12 step debug AppsKey menu item "" MAIN_MENU_INDEX,\s*true\)"
    }

    It "AHK script does not bind plain F11" {
        $MainAhk | Should -Not -Match "(?m)^F11::"
    }
}

Describe "Shared AHK library contract" {
    It "AHK shared library contains FLOWSTART logging marker" {
        $CommonAhk | Should -Match "FLOWSTART"
    }

    It "AHK shared library contains FLOWDONE logging marker" {
        $CommonAhk | Should -Match "FLOWDONE"
    }

    It "AHK shared library contains FLOWFAIL logging marker" {
        $CommonAhk | Should -Match "FLOWFAIL"
    }

    It "AHK shared library contains FLOWCANCELLED logging marker" {
        $CommonAhk | Should -Match "FLOWCANCELLED"
    }

    It "AHK shared library contains ConfirmStep helper" {
        $CommonAhk | Should -Match "ConfirmStep"
    }

    It "AHK shared library uses MsgBox for step-debug confirmation" {
        $CommonAhk | Should -Match "MsgBox"
    }

    It "AHK shared library supports stepDebug parameter in flow helpers" {
        $CommonAhk | Should -Match "stepDebug\s*:=\s*false"
    }

    It "AHK shared library contains opencontextmenu step logging" {
        $CommonAhk | Should -Match "STEPSTART opencontextmenu"
    }

    It "AHK shared library contains movetomenuitem step logging" {
        $CommonAhk | Should -Match "STEPSTART movetomenuitem"
    }

    It "AHK shared library contains choosecurrentmenuitem step logging" {
        $CommonAhk | Should -Match "STEPSTART choosecurrentmenuitem"
    }

    It "AHK shared library contains replay confirmation step for step-debug flow" {
        $CommonAhk | Should -Match "replayall"
        $CommonAhk | Should -Match "Replay all steps without confirmations\?"
    }

    It "AHK shared library replays step-debug flow without confirmations after replay confirmation" {
        $CommonAhk | Should -Match "OpenContextMenu\(false\)"
        $CommonAhk | Should -Match "MoveToMenuItem\(stepCount,\s*false\)"
        $CommonAhk | Should -Match "ChooseCurrentMenuItem\(false\)"
    }
}

Describe "Manual test cases document contract" {
    It "test cases mention CtrlF11" {
        $TestCases | Should -Match "Ctrl\+?F11"
    }

    It "test cases mention CtrlF12" {
        $TestCases | Should -Match "Ctrl\+?F12"
    }

    It "test cases mention FLOWDONE" {
        $TestCases | Should -Match "FLOWDONE"
    }

    It "test cases mention FLOWCANCELLED" {
        $TestCases | Should -Match "FLOWCANCELLED"
    }

    It "test cases mention FLOWFAIL" {
        $TestCases | Should -Match "FLOWFAIL"
    }

    It "test cases mention replay confirmation" {
        $TestCases | Should -Match "Replay all steps without confirmations\?"
    }

    It "test cases mention plain F11 must not be captured" {
        $TestCases | Should -Match 'Plain .*F11.* must not be used by the script'
    }
}