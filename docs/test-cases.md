# Manual test cases

## 1. Scope and goals

This document describes manual smoke and exploratory test cases for the AutoHotkey script that reads selected text via the Yandex Alice browser context menu flow.

The primary goal of these tests is not only to confirm that the happy-path works, but also to provide a **repeatable way to observe and diagnose unstable behaviour** using runtime logs.

Runtime evidence must be collected from `logs/ahk-runtime.log`. All conclusions about stability must be backed by log markers, not only by subjective perception.

Plain keyboard `F11` must not be used by the script in any scenario. Plain F11 must not be used by the script.

---

## 2. Common preparation

Before running any test case:

1. Start the AutoHotkey script (for example via `tools\run-ahk.ps1`).
2. Open the target browser window matched by `ahk_exe browser.exe`.
3. Navigate to a page where Yandex Alice can read selected text.
4. Select some text on the page.
5. Open `logs\ahk-runtime.log` in a tail view (e.g. `Get-Content .\logs\ahk-runtime.log -Wait`).

Expected base markers in the log:

- `TIMINGPROFILE`
- `FLOWSTART`
- `FLOWDONE`
- `FLOWCANCELLED`
- `FLOWFAIL`
- `STEPSTART`
- `STEPDONE`
- `flowAttemptId`

If any of these markers are completely absent, the script is not following the expected debug contract.

---

## 3. Expected runtime markers per attempt

For every invocation of the primary flow (`F9`, `F10`, `Ctrl+F11`, `Ctrl+F12`) the following pattern is expected:

1. Hotkey log:
   - `Hotkey pressed F9`, or
   - `Hotkey pressed F10`, or
   - `Hotkey pressed CtrlF11`, or
   - `Hotkey pressed CtrlF12`.
2. A `TIMINGPROFILE applied` line that reflects the active timing profile for this attempt.
3. A `FLOWSTART` line including:
   - mode name (e.g. `modeF9 AppsKey menu item 6`),
   - `stepCount`,
   - `stepDebug` flag,
   - `flowAttemptId`.
4. A sequence of `STEPSTART` / `STEPDONE` markers:
   - `STEPSTART opencontextmenu` / `STEPDONE opencontextmenu`,
   - `STEPSTART movetomenuitem` / `STEPDONE movetomenuitem`,
   - `STEPSTART choosecurrentmenuitem` / `STEPDONE choosecurrentmenuitem`.
5. A terminal marker for that `flowAttemptId`:
   - `FLOWDONE` for successful runs,
   - `FLOWCANCELLED` for user cancellations,
   - `FLOWFAIL` for runtime errors.

If there is a `FLOWSTART` with a given `flowAttemptId`, but no terminal marker for the same `flowAttemptId`, this is considered a **stuck or incomplete attempt** and must be investigated.

---

## 4. F8 help

**Steps**

1. Press `F8`.
2. Observe the help tooltip appearing in the browser context.
3. Verify that the log contains `Hotkey pressed F8`.

**Expected result**

- Tooltip text matches the documented shortcuts (`F8`, `F9`, `F10`, `Ctrl+F11`, `Ctrl+F12`).
- No `FLOWSTART` / `FLOWDONE` markers are produced for `F8`.
- No `FLOWFAIL` is produced.

Any runtime error during `F8` help is considered a defect, as `F8` must be a safe, non-invasive help action.

---

## 5. F9 normal primary flow (stable mode)

**Purpose**

This test case verifies that the regular primary Alice flow (without debug or step-debug) runs to completion, and that its behaviour is observable through step markers and `flowAttemptId`. It also serves as a baseline for comparing debug modes.

**Steps**

1. Press `F9`.
2. Confirm that Yandex Alice starts reading the selected text.
3. Observe the context menu behaviour:
   - Context menu opens.
   - Selection moves to the expected menu item index (`MAIN_MENU_INDEX`).
   - Enter confirms the current item.
4. Inspect `logs\ahk-runtime.log` for the latest `F9` attempt.

**Expected log markers**

- `Hotkey pressed F9`.
- `TIMINGPROFILE applied profile=normal`.
- `FLOWSTART` for `modeF9 AppsKey menu item 6 stepCount6 stepDebug0`.
- `FLOWDETAIL` line containing `timingProfile=normal`, `contextMenuOpenDelayMs=300`, `menuStepDelayMs=80`, `beforeEnterDelayMs=120`.
- `STEPSTART opencontextmenu` / `STEPDONE opencontextmenu`.
- `STEPSTART movetomenuitem` / `STEPDONE movetomenuitem`.
- `STEPSTART choosecurrentmenuitem` / `STEPDONE choosecurrentmenuitem`.
- `FLOWDONE modeF9 AppsKey menu item 6`.
- The same block of lines shares a single `flowAttemptId=...`.

**No** `FLOWFAIL` lines should be present for this `flowAttemptId`.

**Assessment of stability**

Run `F9` at least 5–10 times in a row. For each attempt:

- Confirm Alice starts reading the selected text.
- Confirm `FLOWDONE` is present and `FLOWFAIL` is absent for the corresponding `flowAttemptId`.
- If Alice does not start reading, but `FLOWDONE` is present, treat this as a **UI-level failure** and mark the attempt as unstable; record the full block of log lines for that `flowAttemptId` for further analysis.

---

## 6. F10 alternate flow (secondary menu index)

**Purpose**

This test case verifies that the alternate menu item index (`ALT_MENU_INDEX`) produces a consistent flow, and that the difference from `F9` is visible in logs via `stepCount` and mode name.

**Steps**

1. Press `F10`.
2. Confirm that Yandex Alice starts reading the selected text using the alternate menu item index.
3. Inspect `logs\ahk-runtime.log` for the latest `F10` attempt.

**Expected log markers**

- `Hotkey pressed F10`.
- `TIMINGPROFILE applied profile=normal`.
- `FLOWSTART modeF10 AppsKey menu item 7 stepCount7 stepDebug0`.
- `FLOWDETAIL` with `stepCount=7`, `timingProfile=normal`.
- Full chain of `STEPSTART` / `STEPDONE` markers analogous to `F9`, but with `stepCount7`.
- `FLOWDONE modeF10 AppsKey menu item 7`.

**No** `FLOWFAIL` lines should be present for this `flowAttemptId`.

---

## 7. Ctrl+F11 debug timing flow (slow, non-step)

**Purpose**

This test case verifies that enabling debug timing (slow delays, no step confirmations) gives a more forgiving timing window while preserving the same sequence of logical steps. It is used for investigating timing-related instabilities.

**Steps**

1. Press `Ctrl+F11`.
2. Confirm that Alice starts reading the selected text.
3. Observe that the flow runs more slowly than `F9` (longer delays between actions).
4. Inspect `logs\ahk-runtime.log` for the latest `Ctrl+F11` attempt.

**Expected log markers**

- `Hotkey pressed CtrlF11`.
- `TIMINGPROFILE applied profile=debug`.
- `FLOWSTART modeCtrlF11 debug AppsKey menu item 6 stepCount6 stepDebug0`.
- `FLOWDETAIL` with:
  - `timingProfile=debug`,
  - `contextMenuOpenDelayMs=900`,
  - `menuStepDelayMs=300`,
  - `beforeEnterDelayMs=500`.
- Full chain of `STEPSTART` / `STEPDONE` markers.
- `FLOWDONE modeCtrlF11 debug AppsKey menu item 6`.

**No** `FLOWFAIL` lines should be present for this `flowAttemptId`.

**Investigation guidance**

If the normal `F9` flow is unstable but `Ctrl+F11` produces more successful attempts:

- Compare `FLOWDETAIL` for unstable `F9` attempts with `FLOWDETAIL` for stable `Ctrl+F11` attempts.
- Pay attention to `activeWindowTitle`, `activeWindowClass`, `activeWindowProcess`, and `activeWindowId` to see whether focus is lost in unstable cases.
- Use the difference in timing profiles to decide whether instability is purely timing-driven or window-focus related.

---

## 8. Ctrl+F12 step-debug flow (interactive + replay)

**Purpose**

This test case verifies that the step-debug mode provides interactive confirmations for each step, followed by an automated replay without confirmations. It is the primary tool for investigating **where exactly the flow diverges from expectations**.

**Steps: interactive phase**

1. Press `Ctrl+F12`.
2. Confirm that the first `MsgBox` confirmation appears for `opencontextmenu`.
3. For each step:
   - Read the dialog text.
   - Press `OK` to continue, or `Cancel` to stop.
4. Ensure the replay confirmation prompt appears with text exactly: `Replay all steps without confirmations?`.
5. Press `OK` to trigger the replay phase.

**Steps: replay phase**

6. Observe the automated replay of the steps without further `MsgBox` dialogs.
7. Confirm that Alice starts reading the selected text in at least one of the two runs (interactive or replay).

**Expected log markers**

For the interactive phase:

- `Hotkey pressed CtrlF12`.
- `TIMINGPROFILE applied profile=normal`.
- `FLOWSTART modeCtrlF12 step debug AppsKey menu item 6 stepCount6 stepDebug1`.
- `FLOWDETAIL stepdebug phase=interactive-run`.
- `STEPSTART opencontextmenu` / `STEPDONE opencontextmenu` with `stepDebug=1`.
- `STEPSTART movetomenuitem` / `STEPDONE movetomenuitem` with `stepDebug=1`.
- `STEPSTART choosecurrentmenuitem` / `STEPDONE choosecurrentmenuitem` with `stepDebug=1`.
- `STEPPROMPT` / `STEPCONFIRMED` for each interactive step.
- `STEPSTART replayall`.
- `STEPDONE replayall`.

For the replay phase:

- `FLOWDETAIL stepdebug phase=replay-without-confirmations`.
- `STEPSTART opencontextmenu` / `STEPDONE opencontextmenu` with `stepDebug=0`.
- `STEPSTART movetomenuitem` / `STEPDONE movetomenuitem` with `stepDebug=0`.
- `STEPSTART choosecurrentmenuitem` / `STEPDONE choosecurrentmenuitem` with `stepDebug=0`.
- `FLOWDONE modeCtrlF12 step debug AppsKey menu item 6`.

**Cancellation sub-case**

If the user presses `Cancel` on any step confirmation:

- The log must contain `STEPCANCELLED stepKey=...`.
- The flow must end with `FLOWCANCELLED modeCtrlF12 step debug AppsKey menu item 6`.
- There must be **no** `FLOWDONE` for the same `flowAttemptId`.
- There must be **no** `FLOWFAIL` unless an additional runtime error occurs.

---

## 9. Window diagnostics (focus and context)

For at least one `F9` attempt and one `Ctrl+F11` attempt, verify that:

- `FLOWDETAIL` and/or `STEPDETAIL opencontextmenu` lines include:
  - `activeWindowTitle=`,
  - `activeWindowClass=`,
  - `activeWindowProcess=`,
  - `activeWindowId=`.
- `STEPDETAIL opencontextmenu refocusedWindowTitle=` and related fields correctly reflect the browser window after `RefocusActiveWindow()`.

These fields are essential for investigating cases where the context menu opens in the wrong window or not at all.

---

## 10. Unstable behaviour reproduction and analysis

When you observe unstable behaviour, for example Alice does not start reading or reads the wrong item:

1. Identify the nearest `FLOWSTART` line for the attempt.
2. Extract the corresponding `flowAttemptId`.
3. Collect all log lines containing this `flowAttemptId`.
4. Locate the last `STEPDONE` marker for this attempt:
   - If the last marker is `STEPDONE opencontextmenu`, the failure likely occurs during menu navigation.
   - If the last marker is `STEPDONE movetomenuitem`, the failure likely occurs at the confirmation step or in Alice itself.
   - If the last marker is `STEPDONE choosecurrentmenuitem`, but Alice does not start reading, the failure is likely on the Alice side.
5. Compare timing and window diagnostics for unstable attempts with stable ones (`F9` vs `Ctrl+F11` vs `Ctrl+F12` replay).

Document the observed differences and use them as input for further tuning of timing profiles or window-focus handling.

---

## 11. Constraints and non-goals

- These test cases do **not** attempt to exhaustively validate Yandex Alice itself; they focus on the automation script and its interaction with the browser UI.
- The document assumes that `logs\ahk-runtime.log` is writable and not locked by other tools; if the log cannot be written, the debug-mode foundation is considered not functional.
- Plain `F11` must remain unbound by the script to avoid conflict with browser or OS behaviour; any binding of `F11` is treated as a regression.