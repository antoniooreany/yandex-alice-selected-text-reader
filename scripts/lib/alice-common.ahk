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

BoolText(value) {
    return value ? "true" : "false"
}

GetRunProfile(isDebug := false) {
    global CONTEXTMENUOPENDELAYMS
    global MENUSTEPDELAYMS
    global BEFOREENTERDELAYMS
    global DEBUGCONTEXTMENUOPENDELAYMS
    global DEBUGMENUSTEPDELAYMS
    global DEBUGBEFOREENTERDELAYMS

    if isDebug {
        return Map(
            "debug", true,
            "contextMenuOpenDelayMs", DEBUGCONTEXTMENUOPENDELAYMS,
            "menuStepDelayMs", DEBUGMENUSTEPDELAYMS,
            "beforeEnterDelayMs", DEBUGBEFOREENTERDELAYMS
        )
    }

    return Map(
        "debug", false,
        "contextMenuOpenDelayMs", CONTEXTMENUOPENDELAYMS,
        "menuStepDelayMs", MENUSTEPDELAYMS,
        "beforeEnterDelayMs", BEFOREENTERDELAYMS
    )
}

OpenContextMenu(profile) {
    global MENUOPENKEYS
    delayMs := profile["contextMenuOpenDelayMs"]
    WriteLog("INFO", "STEP_START open_context_menu keys=" MENUOPENKEYS " delayMs=" delayMs)
    SendEvent(MENUOPENKEYS)
    Sleep(delayMs)
    WriteLog("INFO", "STEP_DONE open_context_menu")
}

MoveToMenuItem(stepCount, profile) {
    delayMs := profile["menuStepDelayMs"]
    WriteLog("INFO", "STEP_START move_to_menu_item stepCount=" stepCount " stepDelayMs=" delayMs)
    Loop stepCount {
        SendEvent("{Down}")
        Sleep(delayMs)
    }
    WriteLog("INFO", "STEP_DONE move_to_menu_item stepCount=" stepCount)
}

ChooseCurrentMenuItem(profile) {
    delayMs := profile["beforeEnterDelayMs"]
    WriteLog("INFO", "STEP_START choose_current_menu_item beforeEnterDelayMs=" delayMs)
    Sleep(delayMs)
    SendEvent("{Enter}")
    WriteLog("INFO", "STEP_DONE choose_current_menu_item")
}

ReadSelectedTextByIndex(stepCount, modeName, profile := unset) {
    if !IsSet(profile)
        profile := GetRunProfile(false)

    debugText := BoolText(profile["debug"])
    contextMenuOpenDelayMs := profile["contextMenuOpenDelayMs"]
    menuStepDelayMs := profile["menuStepDelayMs"]
    beforeEnterDelayMs := profile["beforeEnterDelayMs"]

    try {
        WriteLog(
            "INFO",
            "FLOW_START mode=" modeName
            " stepCount=" stepCount
            " debug=" debugText
            " contextMenuOpenDelayMs=" contextMenuOpenDelayMs
            " menuStepDelayMs=" menuStepDelayMs
            " beforeEnterDelayMs=" beforeEnterDelayMs
        )

        if profile["debug"]
            ShowNotification("Debug mode started: " modeName, 2500)
        else
            ShowNotification("Mode started: " modeName)

        OpenContextMenu(profile)
        MoveToMenuItem(stepCount, profile)
        ChooseCurrentMenuItem(profile)

        WriteLog("INFO", "FLOW_DONE mode=" modeName " debug=" debugText)
    } catch Error as err {
        WriteLog("ERROR", "FLOW_FAIL mode=" modeName " debug=" debugText " error=" err.Message)
        ShowNotification("Error: " err.Message, 3500)
    }
}