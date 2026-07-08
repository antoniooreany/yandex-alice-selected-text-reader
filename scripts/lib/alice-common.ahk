class FlowCancelledError extends Error {
}

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

ConfirmStep(stepKey, promptText) {
    result := MsgBox(promptText, "Alice step debug", "OKCancel Iconi")
    if (result != "OK") {
        throw FlowCancelledError("Cancelled at step: " stepKey)
    }
}

OpenContextMenu(stepDebug := false) {
    global MENUOPENKEYS, CONTEXTMENUOPENDELAYMS
    WriteLog("INFO", "STEP_START open_context_menu keys=" MENUOPENKEYS " delayMs=" CONTEXTMENUOPENDELAYMS)

    if stepDebug {
        ConfirmStep(
            "open_context_menu",
            "Step: open_context_menu`n`nPress OK to open the browser context menu with " MENUOPENKEYS ".`nPress Cancel to stop."
        )
    }

    SendEvent(MENUOPENKEYS)
    Sleep(CONTEXTMENUOPENDELAYMS)
    WriteLog("INFO", "STEP_DONE open_context_menu")
}

MoveToMenuItem(stepCount, stepDebug := false) {
    global MENUSTEPDELAYMS
    WriteLog("INFO", "STEP_START move_to_menu_item stepCount=" stepCount " stepDelayMs=" MENUSTEPDELAYMS)

    Loop stepCount {
        currentStep := A_Index

        if stepDebug {
            ConfirmStep(
                "move_to_menu_item_" currentStep,
                "Step: move_to_menu_item`n`n"
                . "About to send {Down} step " currentStep " of " stepCount ".`n"
                . "Press OK to continue to the next menu item.`n"
                . "Press Cancel to stop."
            )
            ShowNotification("F12 step debug: Down " currentStep " of " stepCount, 1000)
        }

        SendEvent("{Down}")
        Sleep(MENUSTEPDELAYMS)
    }

    WriteLog("INFO", "STEP_DONE move_to_menu_item stepCount=" stepCount)
}

ChooseCurrentMenuItem(stepDebug := false) {
    global BEFOREENTERDELAYMS
    WriteLog("INFO", "STEP_START choose_current_menu_item beforeEnterDelayMs=" BEFOREENTERDELAYMS)

    if stepDebug {
        ConfirmStep(
            "choose_current_menu_item",
            "Step: choose_current_menu_item`n`nPress OK to confirm the current menu item with Enter.`nPress Cancel to stop."
        )
    }

    Sleep(BEFOREENTERDELAYMS)
    SendEvent("{Enter}")
    WriteLog("INFO", "STEP_DONE choose_current_menu_item")
}

ReadSelectedTextByIndex(stepCount, modeName, stepDebug := false) {
    try {
        WriteLog("INFO", "FLOW_START mode=" modeName " stepCount=" stepCount " stepDebug=" stepDebug)
        ShowNotification("Mode started: " modeName)
        OpenContextMenu(stepDebug)
        MoveToMenuItem(stepCount, stepDebug)
        ChooseCurrentMenuItem(stepDebug)
        WriteLog("INFO", "FLOW_DONE mode=" modeName)
    } catch FlowCancelledError as cancelErr {
        WriteLog("WARN", "FLOW_CANCELLED mode=" modeName " reason=" cancelErr.Message)
        ShowNotification("Cancelled: " modeName, 2500)
    } catch Error as err {
        WriteLog("ERROR", "FLOW_FAIL mode=" modeName " error=" err.Message)
        ShowNotification("Error: " err.Message, 3500)
    }
}