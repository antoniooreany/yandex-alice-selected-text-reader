#Requires AutoHotkey v2.0
#SingleInstance Force

; SETTINGS
BROWSER_EXE := "ahk_exe browser.exe"
MAIN_MENU_INDEX := 6
ALT_MENU_INDEX := 7

CONTEXT_MENU_OPEN_DELAY_MS := 300
MENU_OPEN_KEYS := "{AppsKey}"
MENU_STEP_DELAY_MS := 80
BEFORE_ENTER_DELAY_MS := 120

DEBUG_CONTEXT_MENU_OPEN_DELAY_MS := 900
DEBUG_MENU_STEP_DELAY_MS := 300
DEBUG_BEFORE_ENTER_DELAY_MS := 500

NOTIFY_HIDE_DELAY_MS := 1800
HELP_HIDE_DELAY_MS := 5000

; ACTIVE RUNTIME STATE
ACTIVETIMINGPROFILENAME := "normal"
RUNTIME_CONTEXT_MENU_OPEN_DELAY_MS := CONTEXT_MENU_OPEN_DELAY_MS
RUNTIME_MENU_STEP_DELAY_MS := MENU_STEP_DELAY_MS
RUNTIME_BEFORE_ENTER_DELAY_MS := BEFORE_ENTER_DELAY_MS
RUNTIME_MENU_OPEN_KEYS := MENU_OPEN_KEYS
RUNTIME_NOTIFY_HIDE_DELAY_MS := NOTIFY_HIDE_DELAY_MS

; PATHS
SCRIPT_DIR := A_ScriptDir
PROJECT_ROOT := DirExist(SCRIPT_DIR "\..") ? SCRIPT_DIR "\.." : SCRIPT_DIR
LOG_DIR := PROJECT_ROOT "\logs"
LOG_FILE := LOG_DIR "\ahk-runtime.log"

HELP_TEXT := "F8 - show help`n"
    . "F9 - test Alice menu item 6`n"
    . "F10 - test Alice menu item 7`n"
    . "Ctrl+F11 - debug primary Alice flow`n"
    . "Ctrl+F12 - step debug primary Alice flow"

#Include %A_ScriptDir%\lib\alice-common.ahk

#HotIf WinActive(BROWSER_EXE)

F8:: {
    WriteLog("INFO", "Hotkey pressed F8")
    ShowNotification(HELP_TEXT, HELP_HIDE_DELAY_MS)
    KeyWait("F8")
}

F9:: {
    WriteLog("INFO", "Hotkey pressed F9")
    ApplyNormalTiming()
    ReadSelectedTextByIndex(MAIN_MENU_INDEX, "F9 AppsKey menu item " MAIN_MENU_INDEX, false)
    KeyWait("F9")
}

F10:: {
    WriteLog("INFO", "Hotkey pressed F10")
    ApplyNormalTiming()
    ReadSelectedTextByIndex(ALT_MENU_INDEX, "F10 AppsKey menu item " ALT_MENU_INDEX, false)
    KeyWait("F10")
}

^F11:: {
    WriteLog("INFO", "Hotkey pressed CtrlF11")
    ApplyDebugTiming()
    ReadSelectedTextByIndex(MAIN_MENU_INDEX, "CtrlF11 debug AppsKey menu item " MAIN_MENU_INDEX, false)
    ApplyNormalTiming()
    KeyWait("F11")
}

^F12:: {
    WriteLog("INFO", "Hotkey pressed CtrlF12")
    ApplyNormalTiming()
    ReadSelectedTextByIndex(MAIN_MENU_INDEX, "CtrlF12 step debug AppsKey menu item " MAIN_MENU_INDEX, true)
    KeyWait("F12")
}

#HotIf

ApplyTimingProfile(profileName, contextMenuOpenDelayMs, menuStepDelayMs, beforeEnterDelayMs) {
    global MENU_OPEN_KEYS
    global NOTIFY_HIDE_DELAY_MS
    global ACTIVETIMINGPROFILENAME
    global RUNTIME_CONTEXT_MENU_OPEN_DELAY_MS
    global RUNTIME_MENU_STEP_DELAY_MS
    global RUNTIME_BEFORE_ENTER_DELAY_MS
    global RUNTIME_MENU_OPEN_KEYS
    global RUNTIME_NOTIFY_HIDE_DELAY_MS

    ACTIVETIMINGPROFILENAME := profileName
    RUNTIME_CONTEXT_MENU_OPEN_DELAY_MS := contextMenuOpenDelayMs
    RUNTIME_MENU_STEP_DELAY_MS := menuStepDelayMs
    RUNTIME_BEFORE_ENTER_DELAY_MS := beforeEnterDelayMs
    RUNTIME_MENU_OPEN_KEYS := MENU_OPEN_KEYS
    RUNTIME_NOTIFY_HIDE_DELAY_MS := NOTIFY_HIDE_DELAY_MS

    WriteLog(
        "INFO",
        "TIMINGPROFILE applied profile=" . ACTIVETIMINGPROFILENAME
        . " contextMenuOpenDelayMs=" . RUNTIME_CONTEXT_MENU_OPEN_DELAY_MS
        . " menuStepDelayMs=" . RUNTIME_MENU_STEP_DELAY_MS
        . " beforeEnterDelayMs=" . RUNTIME_BEFORE_ENTER_DELAY_MS
    )
}

ApplyNormalTiming() {
    global CONTEXT_MENU_OPEN_DELAY_MS
    global MENU_STEP_DELAY_MS
    global BEFORE_ENTER_DELAY_MS

    ApplyTimingProfile("normal", CONTEXT_MENU_OPEN_DELAY_MS, MENU_STEP_DELAY_MS, BEFORE_ENTER_DELAY_MS)
}

ApplyDebugTiming() {
    global DEBUG_CONTEXT_MENU_OPEN_DELAY_MS
    global DEBUG_MENU_STEP_DELAY_MS
    global DEBUG_BEFORE_ENTER_DELAY_MS

    ApplyTimingProfile("debug", DEBUG_CONTEXT_MENU_OPEN_DELAY_MS, DEBUG_MENU_STEP_DELAY_MS, DEBUG_BEFORE_ENTER_DELAY_MS)
}

ApplyNormalTiming()
WriteLog("INFO", "Script loaded")