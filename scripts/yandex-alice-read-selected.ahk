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

ApplyNormalTiming() {
    global CONTEXT_MENU_OPEN_DELAY_MS
    global MENU_STEP_DELAY_MS
    global BEFORE_ENTER_DELAY_MS
    global CONTEXTMENUOPENDELAYMS
    global MENUSTEPDELAYMS
    global BEFOREENTERDELAYMS
    global MENUOPENKEYS
    global NOTIFYHIDEDELAYMS

    CONTEXTMENUOPENDELAYMS := CONTEXT_MENU_OPEN_DELAY_MS
    MENUSTEPDELAYMS := MENU_STEP_DELAY_MS
    BEFOREENTERDELAYMS := BEFORE_ENTER_DELAY_MS
    MENUOPENKEYS := MENU_OPEN_KEYS
    NOTIFYHIDEDELAYMS := NOTIFY_HIDE_DELAY_MS
}

ApplyDebugTiming() {
    global DEBUG_CONTEXT_MENU_OPEN_DELAY_MS
    global DEBUG_MENU_STEP_DELAY_MS
    global DEBUG_BEFORE_ENTER_DELAY_MS
    global CONTEXTMENUOPENDELAYMS
    global MENUSTEPDELAYMS
    global BEFOREENTERDELAYMS
    global MENUOPENKEYS
    global NOTIFYHIDEDELAYMS

    CONTEXTMENUOPENDELAYMS := DEBUG_CONTEXT_MENU_OPEN_DELAY_MS
    MENUSTEPDELAYMS := DEBUG_MENU_STEP_DELAY_MS
    BEFOREENTERDELAYMS := DEBUG_BEFORE_ENTER_DELAY_MS
    MENUOPENKEYS := MENU_OPEN_KEYS
    NOTIFYHIDEDELAYMS := NOTIFY_HIDE_DELAY_MS
}