; Shared library for Yandex Alice selected text reader
; Contains logging helpers, core flow, and step-debug / replay logic.

class FlowCancelledError extends Error {
}

EnsureLogDir() {
    if !DirExist(LOG_DIR) {
        DirCreate(LOG_DIR)
    }
}

WriteLog(level, message) {
    EnsureLogDir()
    timestamp := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
    line := level " " timestamp " " message "`n"
    FileAppend(line, LOG_FILE, "UTF-8")
}

ShowNotification(text, durationMs := 3000) {
    TrayTip("Yandex Alice selected text reader", text, durationMs, 1)
}

ConfirmStep(stepKey, promptText) {
    result := MsgBox(
        promptText,
        "Step debug confirmation (" stepKey ")",
        "OKCancel IconQuestion"
    )
    if (result = "Cancel") {
        throw FlowCancelledError("Cancelled at step " stepKey)
    }
}

OpenContextMenu(stepDebug := false) {
    WriteLog(
        "INFO",
        "STEPSTART opencontextmenu keys=" CONTEXT_MENU_KEY " delayMs=" CONTEXT_MENU_OPEN_DELAY_MS
    )
    if stepDebug {
        ConfirmStep("opencontextmenu", "Open browser context menu?")
    }

    Send(CONTEXT_MENU_KEY)
    Sleep(CONTEXT_MENU_OPEN_DELAY_MS)

    WriteLog("INFO", "STEPDONE opencontextmenu")
}

MoveToMenuItem(stepCount, stepDebug := false) {
    WriteLog(
        "INFO",
        "STEPSTART movetomenuitem stepCount=" stepCount " stepDelayMs=" MENU_STEP_DELAY_MS
    )

    if stepDebug {
        ConfirmStep(
            "movetomenuitem",
            "Move down " stepCount " times to the target menu item?"
        )
    }

    Loop stepCount {
        Send("{Down}")
        Sleep(MENU_STEP_DELAY_MS)
    }

    WriteLog("INFO", "STEPDONE movetomenuitem stepCount=" stepCount)
}

ChooseCurrentMenuItem(stepDebug := false) {
    WriteLog(
        "INFO",
        "STEPSTART choosecurrentmenuitem beforeEnterDelayMs=" BEFORE_ENTER_DELAY_MS
    )

    if stepDebug {
        ConfirmStep(
            "choosecurrentmenuitem",
            "Confirm current menu item with Enter?"
        )
    }

    Sleep(BEFORE_ENTER_DELAY_MS)
    Send("{Enter}")

    WriteLog("INFO", "STEPDONE choosecurrentmenuitem")
}

ReadSelectedTextByIndex(stepCount, modeName, stepDebug := false) {
    try {
        WriteLog(
            "INFO",
            "FLOWSTART mode=" modeName
            " stepCount=" stepCount
            " stepDebug=" stepDebug
        )
        ShowNotification("Mode started: " modeName)

        if stepDebug {
            ; текущий пошаговый поток с подтверждениями
            OpenContextMenu(true)
            MoveToMenuItem(stepCount, true)
            ChooseCurrentMenuItem(true)

            ; финальный шаг: предложение повторить без подтверждений
            ConfirmStep(
                "replayall",
                "Replay all steps without confirmations?"
            )

            ; если ConfirmStep не бросил исключение → повторяем сценарий без stepDebug
            OpenContextMenu(false)
            MoveToMenuItem(stepCount, false)
            ChooseCurrentMenuItem(false)
        } else {
            ; обычный поток
            OpenContextMenu(false)
            MoveToMenuItem(stepCount, false)
            ChooseCurrentMenuItem(false)
        }

        WriteLog("INFO", "FLOWDONE mode=" modeName)
    } catch FlowCancelledError as cancelErr {
        WriteLog(
            "WARN",
            "FLOWCANCELLED mode=" modeName
            " reason=" cancelErr.Message
        )
        ShowNotification("Cancelled: " modeName, 2500)
    } catch Error as err {
        WriteLog(
            "ERROR",
            "FLOWFAIL mode=" modeName
            " error=" err.Message
        )
        ShowNotification("Error: " err.Message, 3500)
    }
}