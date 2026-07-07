#Requires AutoHotkey v2.0
#SingleInstance Force

; =========================================================
; SETTINGS
; =========================================================
BROWSER_EXE := "ahk_exe browser.exe"
MENU_ITEM_INDEX := 6

CONTEXT_MENU_OPEN_DELAY_MS := 300
MENU_OPEN_KEYS := "{AppsKey}"
MENU_STEP_DELAY_MS := 80
BEFORE_ENTER_DELAY_MS := 120
NOTIFY_HIDE_DELAY_MS := 1800
HELP_HIDE_DELAY_MS := 4500

; =========================================================
; PATHS
; =========================================================
SCRIPT_DIR := A_ScriptDir
PROJECT_ROOT := DirExist(SCRIPT_DIR "\..") ? SCRIPT_DIR "\.." : SCRIPT_DIR
LOG_DIR := PROJECT_ROOT "\logs"
LOG_FILE := LOG_DIR "\ahk-runtime.log"

HELP_TEXT := "F8  - show help`n"
    . "F9  - read selected text via Alice menu (item 6)"

#Include .\lib\alice-common.ahk

#HotIf WinActive(BROWSER_EXE)

F8::
{
    WriteLog("INFO", "Hotkey pressed: F8")
    ShowNotification(HELP_TEXT, HELP_HIDE_DELAY_MS)
    KeyWait "F8"
}

F9::
{
    WriteLog("INFO", "Hotkey pressed: F9")
    ReadSelectedTextByIndex(MENU_ITEM_INDEX, "F9 / AppsKey item 6")
    KeyWait "F9"
}

#HotIf