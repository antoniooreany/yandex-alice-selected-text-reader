class FlowCancelledError extends Error {
}

EnsureLogDir() {
    global LOG_DIR, LOGDIR

    targetDir := ""
    if IsSet(LOG_DIR) && (LOG_DIR != "") {
        targetDir := LOG_DIR
    } else if IsSet(LOGDIR) && (LOGDIR != "") {
        targetDir := LOGDIR
    }

    if (targetDir = "") {
        return
    }

    if !DirExist(targetDir) {
        DirCreate(targetDir)
    }
}

WriteLog(level, message) {
    global LOG_FILE, LOGFILE

    EnsureLogDir()

    targetFile := ""
    if IsSet(LOG_FILE) && (LOG_FILE != "") {
        targetFile := LOG_FILE
    } else if IsSet(LOGFILE) && (LOGFILE != "") {
        targetFile := LOGFILE
    }

    if (targetFile = "") {
        return false
    }

    timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
    line := level " " timestamp " " message "`n"

    Loop 5 {
        try {
            FileAppend(line, targetFile, "UTF-8")
            return true
        } catch Error {
            if (A_Index = 5) {
                return false
            }
            Sleep(40)
        }
    }

    return false
}

ShowNotification(text, timeoutMs := 1800) {
    ToolTip(text)
    SetTimer(() => ToolTip(), -timeoutMs)
}

RefocusActiveWindow() {
    try {
        WinActivate("A")
    }
}

GetActiveTimingProfileName() {
    global ACTIVETIMINGPROFILENAME

    if IsSet(ACTIVETIMINGPROFILENAME) && (ACTIVETIMINGPROFILENAME != "") {
        return ACTIVETIMINGPROFILENAME
    }

    return "unknown"
}

GetTimingProfileName() {
    return GetActiveTimingProfileName()
}

NewFlowAttemptId() {
    static counter := 0
    counter += 1
    return FormatTime(, "yyyyMMdd-HHmmss") "-" Format("{:03}", counter)
}

GetActiveWindowTitleSafe() {
    try {
        return WinGetTitle("A")
    } catch Error {
        return ""
    }
}

GetActiveWindowClassSafe() {
    try {
        return WinGetClass("A")
    } catch Error {
        return ""
    }
}

GetActiveWindowProcessSafe() {
    try {
        return WinGetProcessName("A")
    } catch Error {
        return ""
    }
}

QuoteValueForLog(value) {
    text := value . ""
    text := StrReplace(text, '"', "'")
    return '"' . text . '"'
}

BuildFlowContextMap(stepCount, modeName, stepDebug, flowAttemptId) {
    global RUNTIME_CONTEXT_MENU_OPEN_DELAY_MS
    global RUNTIME_MENU_STEP_DELAY_MS
    global RUNTIME_BEFORE_ENTER_DELAY_MS

    context := Map()
    context["mode"] := modeName
    context["stepCount"] := stepCount
    context["stepDebug"] := stepDebug ? 1 : 0
    context["timingProfile"] := GetActiveTimingProfileName()
    context["contextMenuOpenDelayMs"] := RUNTIME_CONTEXT_MENU_OPEN_DELAY_MS
    context["menuStepDelayMs"] := RUNTIME_MENU_STEP_DELAY_MS
    context["beforeEnterDelayMs"] := RUNTIME_BEFORE_ENTER_DELAY_MS
    context["flowAttemptId"] := flowAttemptId
    context["activeWindowTitle"] := GetActiveWindowTitleSafe()
    context["activeWindowClass"] := GetActiveWindowClassSafe()
    context["activeWindowProcess"] := GetActiveWindowProcessSafe()
    return context
}

GetFlowContext(stepCount, modeName, stepDebug, flowAttemptId) {
    return BuildFlowContextMap(stepCount, modeName, stepDebug, flowAttemptId)
}

FormatFlowContext(context) {
    return "mode=" . context["mode"]
        . " stepCount=" . context["stepCount"]
        . " stepDebug=" . context["stepDebug"]
        . " timingProfile=" . context["timingProfile"]
        . " contextMenuOpenDelayMs=" . context["contextMenuOpenDelayMs"]
        . " menuStepDelayMs=" . context["menuStepDelayMs"]
        . " beforeEnterDelayMs=" . context["beforeEnterDelayMs"]
        . " flowAttemptId=" . context["flowAttemptId"]
        . " activeWindowTitle=" . QuoteValueForLog(context["activeWindowTitle"])
        . " activeWindowClass=" . QuoteValueForLog(context["activeWindowClass"])
        . " activeWindowProcess=" . QuoteValueForLog(context["activeWindowProcess"])
}

ConfirmStep(stepKey, promptText, flowAttemptId := "") {
    WriteLog("INFO", "STEPPROMPT stepKey=" . stepKey . " flowAttemptId=" . flowAttemptId)
    WriteLog("INFO", "STEPDETAIL confirmstep prompt stepKey=" . stepKey . " flowAttemptId=" . flowAttemptId)

    result := MsgBox(promptText, "Alice step debug", "OKCancel Iconi")
    RefocusActiveWindow()

    if (result = "OK") {
        WriteLog("INFO", "STEPCONFIRMED stepKey=" . stepKey . " flowAttemptId=" . flowAttemptId)
        WriteLog("INFO", "STEPDETAIL confirmstep accepted stepKey=" . stepKey . " flowAttemptId=" . flowAttemptId)
        return
    }

    WriteLog("WARN", "STEPCANCELLED stepKey=" . stepKey . " flowAttemptId=" . flowAttemptId)
    WriteLog("WARN", "STEPDETAIL confirmstep cancelled stepKey=" . stepKey . " flowAttemptId=" . flowAttemptId)
    throw FlowCancelledError("Cancelled at step " . stepKey)
}

OpenContextMenu(stepDebug := false, flowAttemptId := "") {
    global RUNTIME_MENU_OPEN_KEYS, RUNTIME_CONTEXT_MENU_OPEN_DELAY_MS

    WriteLog("INFO", "STEPSTART opencontextmenu keys=" . RUNTIME_MENU_OPEN_KEYS . " delayMs=" . RUNTIME_CONTEXT_MENU_OPEN_DELAY_MS . " flowAttemptId=" . flowAttemptId)
    WriteLog("INFO", "STEPDETAIL opencontextmenu stepDebug=" . (stepDebug ? 1 : 0) . " flowAttemptId=" . flowAttemptId)

    RefocusActiveWindow()
    SendEvent(RUNTIME_MENU_OPEN_KEYS)
    WriteLog("INFO", "STEPDETAIL opencontextmenu sentKeys=" . RUNTIME_MENU_OPEN_KEYS . " flowAttemptId=" . flowAttemptId)

    Sleep(RUNTIME_CONTEXT_MENU_OPEN_DELAY_MS)
    WriteLog("INFO", "STEPDONE opencontextmenu flowAttemptId=" . flowAttemptId)

    if stepDebug {
        ConfirmStep(
            "opencontextmenu",
            "Step: opencontextmenu`n`nContext menu should be open now.`nPress OK to continue, Cancel to stop.",
            flowAttemptId
        )
    }
}

MoveToMenuItem(stepCount, stepDebug := false, flowAttemptId := "") {
    global RUNTIME_MENU_STEP_DELAY_MS

    WriteLog("INFO", "STEPSTART movetomenuitem stepCount=" . stepCount . " stepDelayMs=" . RUNTIME_MENU_STEP_DELAY_MS . " flowAttemptId=" . flowAttemptId)
    WriteLog("INFO", "STEPDETAIL movetomenuitem stepDebug=" . (stepDebug ? 1 : 0) . " flowAttemptId=" . flowAttemptId)

    Loop stepCount {
        currentStep := A_Index
        WriteLog("INFO", "STEPDETAIL movetomenuitem currentStep=" . currentStep . " of=" . stepCount . " flowAttemptId=" . flowAttemptId)

        if stepDebug {
            ConfirmStep(
                "movetomenuitem-" . currentStep,
                "Step: movetomenuitem`n`nAbout to send Down step " . currentStep . " of " . stepCount . ".`nPress OK to continue to the next menu item.`nPress Cancel to stop.",
                flowAttemptId
            )
            ShowNotification("F12 step debug: Down " . currentStep . " of " . stepCount, 1000)
        }

        SendEvent("{Down}")
        WriteLog("INFO", "STEPDETAIL movetomenuitem sentKey=Down currentStep=" . currentStep . " flowAttemptId=" . flowAttemptId)
        Sleep(RUNTIME_MENU_STEP_DELAY_MS)
    }

    WriteLog("INFO", "STEPDONE movetomenuitem stepCount=" . stepCount . " flowAttemptId=" . flowAttemptId)
}

ChooseCurrentMenuItem(stepDebug := false, flowAttemptId := "") {
    global RUNTIME_BEFORE_ENTER_DELAY_MS

    WriteLog("INFO", "STEPSTART choosecurrentmenuitem beforeEnterDelayMs=" . RUNTIME_BEFORE_ENTER_DELAY_MS . " flowAttemptId=" . flowAttemptId)
    WriteLog("INFO", "STEPDETAIL choosecurrentmenuitem stepDebug=" . (stepDebug ? 1 : 0) . " flowAttemptId=" . flowAttemptId)

    if stepDebug {
        ConfirmStep(
            "choosecurrentmenuitem",
            "Step: choosecurrentmenuitem`n`nPress OK to confirm the current menu item with Enter.`nPress Cancel to stop.",
            flowAttemptId
        )
    }

    Sleep(RUNTIME_BEFORE_ENTER_DELAY_MS)
    WriteLog("INFO", "STEPDETAIL choosecurrentmenuitem sleptBeforeEnterMs=" . RUNTIME_BEFORE_ENTER_DELAY_MS . " flowAttemptId=" . flowAttemptId)

    SendEvent("{Enter}")
    WriteLog("INFO", "STEPDETAIL choosecurrentmenuitem sentKey=Enter flowAttemptId=" . flowAttemptId)
    WriteLog("INFO", "STEPDONE choosecurrentmenuitem flowAttemptId=" . flowAttemptId)
}

ReadSelectedTextByIndex(stepCount, modeName, stepDebug := false) {
    flowAttemptId := NewFlowAttemptId()

    try {
        context := GetFlowContext(stepCount, modeName, stepDebug, flowAttemptId)

        WriteLog("INFO", "FLOWSTART mode=" . modeName . " stepCount=" . stepCount . " stepDebug=" . (stepDebug ? 1 : 0) . " flowAttemptId=" . flowAttemptId)
        WriteLog("INFO", "FLOWDETAIL " . FormatFlowContext(context))
        ShowNotification("Mode started: " . modeName)

        if stepDebug {
            WriteLog("INFO", "FLOWDETAIL stepdebug phase=interactive-run flowAttemptId=" . flowAttemptId)

            OpenContextMenu(true, flowAttemptId)
            MoveToMenuItem(stepCount, true, flowAttemptId)
            ChooseCurrentMenuItem(true, flowAttemptId)

            WriteLog("INFO", "STEPSTART replayall flowAttemptId=" . flowAttemptId)
            ConfirmStep("replayall", "Replay all steps without confirmations?", flowAttemptId)
            WriteLog("INFO", "STEPDONE replayall flowAttemptId=" . flowAttemptId)

            WriteLog("INFO", "FLOWDETAIL stepdebug phase=replay-without-confirmations flowAttemptId=" . flowAttemptId)

            OpenContextMenu(false)
            MoveToMenuItem(stepCount, false)
            ChooseCurrentMenuItem(false)
        } else {
            WriteLog("INFO", "FLOWDETAIL phase=normal-run flowAttemptId=" . flowAttemptId)

            OpenContextMenu(false, flowAttemptId)
            MoveToMenuItem(stepCount, false, flowAttemptId)
            ChooseCurrentMenuItem(false, flowAttemptId)
        }

        WriteLog("INFO", "FLOWDONE mode=" . modeName . " flowAttemptId=" . flowAttemptId)
    } catch FlowCancelledError as cancelErr {
        WriteLog("WARN", "FLOWCANCELLED mode=" . modeName . " reason=" . cancelErr.Message . " flowAttemptId=" . flowAttemptId)
        ShowNotification("Cancelled: " . modeName, 2500)
    } catch Error as err {
        WriteLog("ERROR", "FLOWFAIL mode=" . modeName . " error=" . err.Message . " flowAttemptId=" . flowAttemptId)
        ShowNotification("Error: " . err.Message, 3500)
    }
}