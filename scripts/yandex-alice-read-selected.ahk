#Requires AutoHotkey v2.0

; =========================================================
; SETTINGS
; =========================================================
BROWSER_EXE := "ahk_exe browser.exe"
MAIN_MENU_INDEX := 6
ALT_MENU_INDEX := 7
MENU_OPEN_KEYS := "+{F10}"

CONTEXT_MENU_OPEN_DELAY_MS := 300
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

HELP_TEXT :=
(
F8  - show help
F9  - read selected text (primary mode)
F10 - read selected text (alternate mode)
)

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
    ReadSelectedTextByIndex(MAIN_MENU_INDEX, "F9 / primary")
    KeyWait "F9"
}

F10::
{
    ReadSelectedTextByIndex(ALT_MENU_INDEX, "F10 / alternate")
    KeyWait "F10"
}

#HotIf