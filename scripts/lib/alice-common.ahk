EnsureLogDir() {
    global LOGDIR
    if !DirExist(LOGDIR)
        DirCreate(LOGDIR)
}

WriteLog(level, message) {
    global LOGFILE
    EnsureLogDir()
    timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
    FileAppend(level " " timestamp " " message "`n", LOGFILE, "UTF-8")
}

ShowNotification(text, timeoutMs := NOTIFYHIDEDELAYMS) {
    ToolTip(text)
    SetTimer(ToolTip, -timeoutMs)
}

OpenContextMenu() {
    global MENUOPENKEYS, CONTEXTMENUOPENDELAYMS
    WriteLog("INFO", "STEP_START open_context_menu keys=" MENUOPENKEYS " delayMs=" CONTEXTMENUOPENDELAYMS)
    SendEvent(MENUOPENKEYS)
    Sleep(CONTEXTMENUOPENDELAYMS)
    WriteLog("INFO", "STEP_DONE open_context_menu")
}

MoveToMenuItem(stepCount) {
    global MENUSTEPDELAYMS
    WriteLog("INFO", "STEP_START move_to_menu_item stepCount=" stepCount " stepDelayMs=" MENUSTEPDELAYMS)
    Loop stepCount {
        SendEvent("{Down}")
        Sleep(MENUSTEPDELAYMS)
    }
    WriteLog("INFO", "STEP_DONE move_to_menu_item stepCount=" stepCount)
}

ChooseCurrentMenuItem() {
    global BEFOREENTERDELAYMS
    WriteLog("INFO", "STEP_START choose_current_menu_item beforeEnterDelayMs=" BEFOREENTERDELAYMS)
    Sleep(BEFOREENTERDELAYMS)
    SendEvent("{Enter}")
    WriteLog("INFO", "STEP_DONE choose_current_menu_item")
}

ReadSelectedTextByIndex(stepCount, modeName) {
    try {
        WriteLog("INFO", "FLOW_START mode=" modeName " stepCount=" stepCount)
        ShowNotification("Mode started: " modeName)
        OpenContextMenu()
        MoveToMenuItem(stepCount)
        ChooseCurrentMenuItem()
        WriteLog("INFO", "FLOW_DONE mode=" modeName)
    } catch Error as err {
        WriteLog("ERROR", "FLOW_FAIL mode=" modeName " error=" err.Message)
        ShowNotification("Error: " err.Message, 3500)
    }
}