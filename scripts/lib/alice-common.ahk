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

ConfirmStep(stepKey, promptText) {
    result := MsgBox(promptText, "Alice step debug", "OKCancel Iconi")
    RefocusActiveWindow()

    if (result != "OK") {
        throw FlowCancelledError("Cancelled at step " stepKey)
    }
}

OpenContextMenu(stepDebug := false) {
    global MENUOPENKEYS, CONTEXTMENUOPENDELAYMS

    WriteLog("INFO", "STEPSTART opencontextmenu keys=" MENUOPENKEYS " delayMs=" CONTEXTMENUOPENDELAYMS)
    WriteLog("INFO", "STEPDETAIL opencontextmenu stepDebug=" stepDebug)

    ; 1. Сначала вернуть фокус в браузер / активное окно.
    RefocusActiveWindow()

    ; 2. Только потом реально открыть контекстное меню.
    SendEvent(MENUOPENKEYS)
    WriteLog("INFO", "STEPDETAIL opencontextmenu sentKeys=" MENUOPENKEYS)

    Sleep(CONTEXTMENUOPENDELAYMS)
    WriteLog("INFO", "STEPDONE opencontextmenu")

    ; 3. Если надо задебажить шаг – показываем диалог уже ПОСЛЕ того,
    ;    как контекстное меню появилось, а не вместо него.
    if stepDebug {
        ConfirmStep(
            "opencontextmenu",
            "Step: opencontextmenu`n`n"
            . "Context menu should be open now.`n"
            . "Press OK to continue, Cancel to stop."
        )
    }
}

MoveToMenuItem(stepCount, stepDebug := false) {
    global MENUSTEPDELAYMS

    WriteLog("INFO", "STEPSTART movetomenuitem stepCount" stepCount " stepDelayMs" MENUSTEPDELAYMS)
    WriteLog("INFO", "STEPDETAIL movetomenuitem stepDebug=" stepDebug)

    Loop stepCount {
        currentStep := A_Index
        WriteLog("INFO", "STEPDETAIL movetomenuitem currentStep=" currentStep " of=" stepCount)

        if stepDebug {
            ConfirmStep(
                "movetomenuitem-" currentStep,
                "Step: movetomenuitem`n`n"
                . "About to send Down step " currentStep " of " stepCount ".`n"
                . "Press OK to continue to the next menu item.`n"
                . "Press Cancel to stop."
            )
            ShowNotification("F12 step debug: Down " currentStep " of " stepCount, 1000)
        }

        SendEvent("{Down}")
        WriteLog("INFO", "STEPDETAIL movetomenuitem sentKey=Down currentStep=" currentStep)

        Sleep(MENUSTEPDELAYMS)
    }

    WriteLog("INFO", "STEPDONE movetomenuitem stepCount" stepCount)
}

ChooseCurrentMenuItem(stepDebug := false) {
    global BEFOREENTERDELAYMS

    WriteLog("INFO", "STEPSTART choosecurrentmenuitem beforeEnterDelayMs" BEFOREENTERDELAYMS)
    WriteLog("INFO", "STEPDETAIL choosecurrentmenuitem stepDebug=" stepDebug)

    if stepDebug {
        ConfirmStep(
            "choosecurrentmenuitem",
            "Step: choosecurrentmenuitem`n`nPress OK to confirm the current menu item with Enter.`nPress Cancel to stop."
        )
    }

    Sleep(BEFOREENTERDELAYMS)
    WriteLog("INFO", "STEPDETAIL choosecurrentmenuitem sleptBeforeEnterMs=" BEFOREENTERDELAYMS)

    SendEvent("{Enter}")
    WriteLog("INFO", "STEPDETAIL choosecurrentmenuitem sentKey=Enter")

    WriteLog("INFO", "STEPDONE choosecurrentmenuitem")
}

ReadSelectedTextByIndex(stepCount, modeName, stepDebug := false) {
    global CONTEXTMENUOPENDELAYMS, MENUSTEPDELAYMS, BEFOREENTERDELAYMS

    try {
        WriteLog("INFO", "FLOWSTART mode" modeName " stepCount" stepCount " stepDebug" stepDebug)
        WriteLog(
            "INFO",
            "FLOWDETAIL mode=" modeName
            " stepCount=" stepCount
            " stepDebug=" stepDebug
            " contextMenuOpenDelayMs=" CONTEXTMENUOPENDELAYMS
            " menuStepDelayMs=" MENUSTEPDELAYMS
            " beforeEnterDelayMs=" BEFOREENTERDELAYMS
        )

        ShowNotification("Mode started: " modeName)

        if stepDebug {
            WriteLog("INFO", "FLOWDETAIL stepdebug phase=interactive-run")

            OpenContextMenu(true)
            MoveToMenuItem(stepCount, true)
            ChooseCurrentMenuItem(true)

            WriteLog("INFO", "STEPSTART replayall")
            ConfirmStep("replayall", "Replay all steps without confirmations?")
            WriteLog("INFO", "STEPDONE replayall")

            WriteLog("INFO", "FLOWDETAIL stepdebug phase=replay-without-confirmations")
            OpenContextMenu(false)
            MoveToMenuItem(stepCount, false)
            ChooseCurrentMenuItem(false)
        } else {
            WriteLog("INFO", "FLOWDETAIL phase=normal-run")

            OpenContextMenu(false)
            MoveToMenuItem(stepCount, false)
            ChooseCurrentMenuItem(false)
        }

        WriteLog("INFO", "FLOWDONE mode" modeName)
    } catch FlowCancelledError as cancelErr {
        WriteLog("WARN", "FLOWCANCELLED mode" modeName " reason" cancelErr.Message)
        ShowNotification("Cancelled: " modeName, 2500)
    } catch Error as err {
        WriteLog("ERROR", "FLOWFAIL mode" modeName " error" err.Message)
        ShowNotification("Error: " err.Message, 3500)
    }
}