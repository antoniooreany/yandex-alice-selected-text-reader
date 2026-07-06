EnsureLogDir() {
    global LOG_DIR
    if !DirExist(LOG_DIR) {
        DirCreate(LOG_DIR)
    }
}

WriteLog(level, message) {
    global LOG_FILE
    EnsureLogDir()
    timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
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
