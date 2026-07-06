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
PROJECT_ROOT := SCRIPT_DIR "\.."
LOG_DIR := PROJECT_ROOT "\logs"
LOG_FILE := LOG_DIR "\ahk-runtime.log"

HELP_TEXT :=
(
F8  - show help
F9  - read selected text (primary mode)
F10 - read selected text (alternate mode)
)

EnsureLogDir() {
    global LOG_DIR
    if !DirExist(LOG_DIR) {
        DirCreate LOG_DIR
    }
}

WriteLog(level, message) {
    global LOG_FILE
    EnsureLogDir()
    timestamp := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
    FileAppend("[" level "] " timestamp " " message "`n", LOG_FILE, "UTF-8")
}

ShowNotification(text, timeoutMs := NOTIFY_HIDE_DELAY_MS) {
    ToolTip text
    SetTimer () => ToolTip(), -timeoutMs
}

OpenContextMenu() {
    global MENU_OPEN_KEYS, CONTEXT_MENU_OPEN_DELAY_MS
    SendEvent MENU_OPEN_KEYS
    Sleep CONTEXT_MENU_OPEN_DELAY_MS
}

MoveToMenuItem(stepCount) {
    global MENU_STEP_DELAY_MS
    Loop stepCount {
        SendEvent "{Down}"
        Sleep MENU_STEP_DELAY_MS
    }
}

ChooseCurrentMenuItem() {
    global BEFORE_ENTER_DELAY_MS
    Sleep BEFORE_ENTER_DELAY_MS
    SendEvent "{Enter}"
}

ReadSelectedTextByIndex(stepCount, modeName) {
    try {
        WriteLog("INFO", "Starting mode: " modeName ", down steps: " stepCount)
        ShowNotification("Mode started: " modeName)
        OpenContextMenu()
        MoveToMenuItem(stepCount)
        ChooseCurrentMenuItem()
        WriteLog("INFO", "Mode completed successfully: " modeName)
    } catch Error as err {
        WriteLog("ERROR", "Mode failed: " modeName ": " err.Message)
        ShowNotification("Error: " err.Message, 3500)
    }
}

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