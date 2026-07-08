#Requires AutoHotkey v2.0
#SingleInstance Force

; SETTINGS
BROWSER_EXE := "chrome.exe"
MAIN_MENU_INDEX := 6
ALT_MENU_INDEX := 7
CONTEXT_MENU_KEY := "{AppsKey}"
CONTEXT_MENU_OPEN_DELAY_MS := 300
MENU_STEP_DELAY_MS := 80
BEFORE_ENTER_DELAY_MS := 120
LOG_DIR := A_ScriptDir "\..\logs"
LOG_FILE := LOG_DIR "\ahk-runtime.log"

HELP_TEXT :=
(
"F8 - show help`n"
. "F9 - test Alice menu item 6`n"
. "F10 - test Alice menu item 7`n"
. "Ctrl+F11 - debug primary Alice flow`n"
. "Ctrl+F12 - step debug primary Alice flow"
)

#Include "lib\alice-common.ahk"

#HotIf WinActive("ahk_exe " BROWSER_EXE)

F8:: {
    WriteLog("INFO", "Hotkey pressed F8")
    ShowNotification(HELP_TEXT, 4000)
    KeyWait("F8")
}

F9:: {
    WriteLog("INFO", "Hotkey pressed F9")
    ReadSelectedTextByIndex(MAIN_MENU_INDEX, "F9 AppsKey menu item " MAIN_MENU_INDEX)
    KeyWait("F9")
}

F10:: {
    WriteLog("INFO", "Hotkey pressed F10")
    ReadSelectedTextByIndex(ALT_MENU_INDEX, "F10 AppsKey menu item " ALT_MENU_INDEX)
    KeyWait("F10")
}

^F11:: {
    WriteLog("INFO", "Hotkey pressed CtrlF11")
    ; debug entry point: primary flow, no step-debug confirmations
    ReadSelectedTextByIndex(MAIN_MENU_INDEX, "CtrlF11 debug AppsKey menu item " MAIN_MENU_INDEX, false)
    KeyWait("F11")
}

^F12:: {
    WriteLog("INFO", "Hotkey pressed CtrlF12")
    ; step-debug entry point: primary flow with step-level confirmations and replay
    ReadSelectedTextByIndex(MAIN_MENU_INDEX, "CtrlF12 step debug AppsKey menu item " MAIN_MENU_INDEX, true)
    KeyWait("F12")
}

#HotIf