# Manual test cases

This document contains manual verification scenarios for `yandex-alice-selected-text-reader`. Use it when validating hotkeys, runtime logging, debug behavior, step-debug behavior, replay behavior, timing profile changes, and local PowerShell workflow helpers.

## 1. Scope and goals

This document describes manual smoke and exploratory test cases for the AutoHotkey script that reads selected text via the Yandex Alice browser context menu flow.

The primary goal of these tests is not only to confirm that the happy-path works, but also to provide a repeatable way to observe and diagnose unstable behaviour using runtime logs.

Runtime evidence must be collected from `logs/ahk-runtime.log`. All conclusions about stability must be backed by log markers, not only by subjective perception.

Plain keyboard `F11` must not be used by the script in any scenario. Plain `F11` must not be used by the script.

## 2. Preconditions

Before running the scenarios below, make sure all of the following are true:

- Windows is running normally.
- AutoHotkey v2 is installed.
- The target Chromium-based browser is open.
- The active browser window matches the configured `BROWSEREXE`.
- Yandex Alice is present in the browser context menu.
- The repository is opened from its root directory.
- The runtime log path is available at `logs/ahk-runtime.log`.

## 3. Common preparation

Open one terminal for commands and, when needed, another terminal for log inspection.

Before running any test case:

1. Start the AutoHotkey script, for example via `tools\run-ahk.ps1`.
2. Open the target browser window matched by `ahk_exe browser.exe`.
3. Navigate to a page where Yandex Alice can read selected text.
4. Select some text on the page.
5. Open `logs\ahk-runtime.log` in a tail view, for example with `Get-Content .\logs\ahk-runtime.log -Wait`.

Useful commands:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\run-tests.ps1
powershell -ExecutionPolicy Bypass -File .\tools\run-ahk.ps1
Get-Content .\logs\ahk-runtime.log -Wait
Get-Content .\logs\ahk-runtime.log -Tail 50
```

If you use local PowerShell profile helpers, these commands are also expected to be available:

```powershell
ahk-start
ahk-stop
ahk-tail
ahk-log
ahk-restart
```

Optional local PowerShell helper aliases or functions may be used during manual runs:

- `ahk-start` -> starts the script through `tools\run-ahk.ps1`.
- `ahk-stop` -> stops the current AutoHotkey process.
- `ahk-tail` -> runs `Get-Content .\logs\ahk-runtime.log -Wait`.
- `ahk-restart` -> stops and starts the script again.

If these helpers are configured in the local shell, the preparation flow may also be:

1. Run `ahk-start`.
2. Open the target browser window and prepare selected text.
3. Run `ahk-tail` to watch runtime diagnostics.
4. Use `ahk-stop` after the session ends or `ahk-restart` after script changes.

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

## 4. Expected runtime markers per attempt

For every invocation of the primary flow (`F9`, `F10`, `Ctrl+F11`, `Ctrl+F12`) the following pattern is expected:

1. Hotkey log:
   - `Hotkey pressed F9`, or
   - `Hotkey pressed F10`, or
   - `Hotkey pressed CtrlF11`, or
   - `Hotkey pressed CtrlF12`.
2. A `TIMINGPROFILE applied` line that reflects the active timing profile for this attempt.
3. A `FLOWSTART` line including:
   - mode name, for example `modeF9 AppsKey menu item 6`;
   - `stepCount`;
   - `stepDebug` flag;
   - `flowAttemptId`.
4. A sequence of `STEPSTART` / `STEPDONE` markers:
   - `STEPSTART opencontextmenu` / `STEPDONE opencontextmenu`;
   - `STEPSTART movetomenuitem` / `STEPDONE movetomenuitem`;
   - `STEPSTART choosecurrentmenuitem` / `STEPDONE choosecurrentmenuitem`.
5. A terminal marker for that `flowAttemptId`:
   - `FLOWDONE` for successful runs;
   - `FLOWCANCELLED` for user cancellations;
   - `FLOWFAIL` for runtime errors.

If there is a `FLOWSTART` with a given `flowAttemptId`, but no terminal marker for the same `flowAttemptId`, this is considered a stuck or incomplete attempt and must be investigated.

## 5. Case 1. Repository smoke test

Goal: confirm that the repository contract is still valid before manual UI checks.

Steps:

1. Open PowerShell in the repository root.
2. Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\run-tests.ps1
```

Expected result:

- The test suite completes successfully.
- No repository contract failures are reported.
- README, scripts, docs, tests, and logs paths are present.

## 6. Case 2. Start AHK through the repository helper

Goal: confirm that the standard repository launcher starts the script successfully.

Steps:

1. Open PowerShell in the repository root.
2. Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\run-ahk.ps1
```

Expected result:

- PowerShell reports that AutoHotkey v2 is starting.
- The configured script path is resolved correctly.
- The AHK process starts successfully.
- The script becomes resident and listens for hotkeys.

## 7. Case 3. F8 help hotkey

Goal: confirm that the help hotkey still works.

Steps:

1. Make the target browser window active.
2. Press `F8`.

Expected result:

- A help notification appears.
- The notification includes `F8`, `F9`, `F10`, `Ctrl+F11`, and `Ctrl+F12`.
- The runtime log contains `Hotkey pressed F8`.
- No `FLOWSTART` / `FLOWDONE` markers are produced for `F8`.
- No `FLOWFAIL` is produced.

## 8. Case 4. F9 primary flow

Goal: confirm that the primary non-debug Alice flow still works.

Steps:

1. Make the target browser window active.
2. Select text in the browser.
3. Press `F9`.
4. Inspect the latest runtime log lines.

Expected result:

- The browser context menu opens.
- The script moves down by `MAINMENUINDEX`.
- The script confirms with `Enter`.
- The runtime log contains:
  - `Hotkey pressed F9`
  - `TIMINGPROFILE applied profile=normal`
  - `FLOWSTART`
  - `FLOWDETAIL`
  - `STEPSTART opencontextmenu`
  - `STEPSTART movetomenuitem`
  - `STEPSTART choosecurrentmenuitem`
  - `FLOWDONE`.
- The same `flowAttemptId` is present across the flow lines of the attempt.
- No `FLOWFAIL` lines should be present for this `flowAttemptId`.

Assessment of stability:

- Run `F9` at least 5 to 10 times in a row.
- Confirm Alice starts reading the selected text on each attempt.
- If Alice does not start reading, but `FLOWDONE` is present, treat this as a UI-level failure and record the full block of log lines for that `flowAttemptId`.

## 9. Case 5. F10 secondary flow

Goal: confirm that the secondary non-debug Alice flow still works.

Steps:

1. Make the target browser window active.
2. Select text in the browser.
3. Press `F10`.
4. Inspect the latest runtime log lines.

Expected result:

- The browser context menu opens.
- The script moves down by `ALTMENUINDEX`.
- The script confirms with `Enter`.
- The runtime log contains:
  - `Hotkey pressed F10`
  - `TIMINGPROFILE applied profile=normal`
  - `FLOWSTART`
  - `FLOWDETAIL`
  - `FLOWDONE`.
- The flow records the expected menu item index for the secondary action.

## 10. Case 6. Ctrl+F11 debug flow

Goal: confirm that the dedicated debug hotkey applies the debug timing profile and runs without step confirmations.

Steps:

1. Make the target browser window active.
2. Select text in the browser.
3. Press `Ctrl+F11`.
4. Inspect the latest runtime log lines.

Expected result:

- The flow runs without per-step confirmation dialogs.
- The timing profile is slower than the normal flow.
- The runtime log contains:
  - `Hotkey pressed CtrlF11`
  - `TIMINGPROFILE applied profile=debug`
  - `FLOWSTART`
  - `FLOWDETAIL`
  - `STEPSTART opencontextmenu`
  - `STEPSTART movetomenuitem`
  - `STEPSTART choosecurrentmenuitem`
  - `FLOWDONE`.
- After the debug run, normal timing can be restored by the script.

Investigation guidance:

- Compare unstable `F9` attempts with stable `Ctrl+F11` attempts.
- Pay attention to `activeWindowTitle`, `activeWindowClass`, and `activeWindowProcess` in `FLOWDETAIL` / `STEPDETAIL` output.

## 11. Case 7. Ctrl+F12 step-debug flow, accepted path

Goal: confirm that the interactive troubleshooting flow works and records step-level markers.

Steps:

1. Make the target browser window active.
2. Select text in the browser.
3. Press `Ctrl+F12`.
4. Accept every confirmation dialog during the first pass.
5. When asked `Replay all steps without confirmations?`, press `OK`.
6. Inspect the runtime log.

Expected result:

- The first pass shows confirmation dialogs after opening the menu and before each important step.
- The runtime log contains:
  - `Hotkey pressed CtrlF12`
  - `TIMINGPROFILE applied profile=normal`
  - `FLOWSTART`
  - `FLOWDETAIL stepdebug phase=interactive-run`
  - `STEPPROMPT`
  - `STEPCONFIRMED`
  - `STEPSTART replayall`
  - `STEPDONE replayall`
  - `FLOWDETAIL stepdebug phase=replay-without-confirmations`
  - `FLOWDONE`.
- The flow ends without `FLOWFAIL`.
- The same `flowAttemptId` ties together the whole attempt.

## 12. Case 8. Ctrl+F12 step-debug flow, cancelled path

Goal: confirm that cancellation is recorded intentionally rather than as a generic error.

Steps:

1. Make the target browser window active.
2. Select text in the browser.
3. Press `Ctrl+F12`.
4. Press `Cancel` at one of the step confirmation dialogs.
5. Inspect the runtime log.

Expected result:

- The flow stops immediately after the cancelled step.
- The runtime log contains:
  - `Hotkey pressed CtrlF12`
  - `FLOWSTART`
  - `STEPPROMPT`
  - `STEPCANCELLED`
  - `FLOWCANCELLED`.
- The run does not end with `FLOWDONE`.
- Cancellation is not reported as `FLOWFAIL` unless there is an unrelated runtime error.

## 13. Case 9. Replay contract in step-debug flow

Goal: confirm that replay remains a best-effort diagnostic path and is visible in the logs.

Steps:

1. Run `Ctrl+F12`.
2. Accept all interactive confirmations.
3. Accept `Replay all steps without confirmations?`.
4. Inspect the runtime log carefully around the replay phase.

Expected result:

- Replay markers appear after the first pass.
- The runtime log contains:
  - `STEPSTART replayall`
  - `STEPDONE replayall`
  - `FLOWDETAIL stepdebug phase=replay-without-confirmations`.
- The replay path attempts:
  - `OpenContextMenu(false)`
  - `MoveToMenuItem(stepCount, false)`
  - `ChooseCurrentMenuItem(false)`.
- Replay is treated as troubleshooting behavior, not as a strict UX guarantee for every browser state.

## 14. Case 10. Timing profile verification

Goal: confirm that normal and debug flows use different timing values.

Steps:

1. Run `F9`.
2. Inspect the log for the latest `TIMINGPROFILE` and `FLOWDETAIL`.
3. Run `Ctrl+F11`.
4. Inspect the log again.

Expected result:

- The normal flow uses the normal timing profile.
- The debug flow uses the debug timing profile.
- `contextMenuOpenDelayMs`, `menuStepDelayMs`, and `beforeEnterDelayMs` differ between normal and debug runs.
- The timing values in `FLOWDETAIL` match the selected mode.

## 15. Case 11. flowAttemptId correlation

Goal: confirm that each run can be isolated in the logs.

Steps:

1. Run `F9`.
2. Run `F10`.
3. Run `Ctrl+F11`.
4. Run `Ctrl+F12`.
5. Inspect the log.

Expected result:

- Each run has its own unique `flowAttemptId`.
- All step-level markers for a single run use the same `flowAttemptId`.
- It is possible to isolate one attempt from `FLOWSTART` to `FLOWDONE`, `FLOWCANCELLED`, or `FLOWFAIL`.

## 16. Case 12. Log tail command

Goal: confirm that the runtime log can be inspected quickly during diagnosis.

Steps:

1. In PowerShell, run:

```powershell
Get-Content .\logs\ahk-runtime.log -Tail 50
```

Expected result:

- The latest log lines are shown without waiting for new output.
- Recent hotkey and flow markers are visible.

## 17. Case 13. Live log watch command

Goal: confirm that the runtime log can be followed in real time.

Steps:

1. In PowerShell, run:

```powershell
Get-Content .\logs\ahk-runtime.log -Wait
```

2. Trigger any hotkey in the browser, for example `F9`.

Expected result:

- New runtime log entries appear live in the terminal.
- Hotkey and flow markers become visible without reopening the file.

## 18. Case 14. Local PowerShell helper: ahk-start

Goal: confirm that the local developer helper starts AHK without blocking the console.

Steps:

1. Make sure the helper functions are loaded from `$PROFILE`.
2. Open PowerShell in the repository root.
3. Run:

```powershell
ahk-start
```

4. Observe whether the prompt returns immediately.
5. Run:

```powershell
Get-Process AutoHotkey -ErrorAction SilentlyContinue
```

Expected result:

- The console is not blocked by the AHK process.
- The PowerShell prompt returns immediately after launch.
- `AutoHotkey.exe` appears in the process list.
- The script remains resident and can react to hotkeys.

## 19. Case 15. Local PowerShell helper: ahk-stop

Goal: confirm that the local developer helper stops the resident AHK process cleanly.

Steps:

1. Start the script with `ahk-start`.
2. Run:

```powershell
ahk-stop
```

3. Then run:

```powershell
Get-Process AutoHotkey -ErrorAction SilentlyContinue
```

Expected result:

- The running AutoHotkey process is stopped.
- No stale AHK process remains in the process list.

## 20. Case 16. Local PowerShell helper: ahk-tail

Goal: confirm that the helper shows the latest log lines quickly.

Steps:

1. Ensure `logs/ahk-runtime.log` exists.
2. Run:

```powershell
ahk-tail
```

Expected result:

- The runtime log is shown in a live tail mode using `Get-Content .\logs\ahk-runtime.log -Wait`.
- New log lines appear as the script writes them.

## 21. Case 17. Local PowerShell helper: ahk-log

Goal: confirm that the helper follows the runtime log in real time.

Steps:

1. Ensure `logs/ahk-runtime.log` exists.
2. Run:

```powershell
ahk-log
```

3. In another terminal or after reopening the shell, trigger any hotkey such as `F9`.

Expected result:

- The terminal stays attached to the log stream.
- New runtime lines appear live as the script writes them.
- If the file does not exist, a readable message is shown instead of an unhandled error.

## 22. Case 18. Local PowerShell helper: ahk-restart

Goal: confirm that the helper replaces the running process with a fresh AHK instance.

Steps:

1. Start the script with `ahk-start`.
2. Run:

```powershell
ahk-restart
```

3. Then run:

```powershell
Get-Process AutoHotkey -ErrorAction SilentlyContinue
```

Expected result:

- The existing AHK process is stopped.
- A fresh AHK process is started.
- The console remains usable after restart.
- Hotkeys remain available after the restart.

## 23. Case 19. Negative case: missing runtime log for helper commands

Goal: confirm that helper commands fail gracefully when the log file does not exist yet.

Steps:

1. Temporarily remove or rename `logs/ahk-runtime.log`.
2. Run:

```powershell
ahk-tail
```

3. Then run:

```powershell
ahk-log
```

Expected result:

- The commands do not crash with an unhandled exception.
- A readable message explains that the log file does not exist yet.

## 24. Case 20. Alice action does not open

Goal: use the existing diagnostics to narrow down where the scenario breaks.

Steps:

1. Start AHK.
2. Open live log view with `Get-Content .\logs\ahk-runtime.log -Wait` or `ahk-log`.
3. Trigger `F9` or `Ctrl+F12`.
4. Compare the latest entries.

Expected result:

- It is possible to distinguish between:
  - hotkey not triggered;
  - context menu not opened;
  - menu navigation not completed;
  - `Enter` sent but Alice not started.
- The key markers for diagnosis are:
  - `Hotkey pressed ...`
  - `TIMINGPROFILE`
  - `FLOWSTART`
  - `STEPSTART opencontextmenu`
  - `STEPSTART movetomenuitem`
  - `STEPSTART choosecurrentmenuitem`
  - `FLOWDONE`, `FLOWCANCELLED`, or `FLOWFAIL`.

## 25. Case 21. Window diagnostics and active context

Goal: confirm that window-related diagnostics are present and useful during troubleshooting.

Steps:

1. Run one `F9` attempt and one `Ctrl+F11` attempt.
2. Inspect `FLOWDETAIL` and `STEPDETAIL opencontextmenu` lines in the runtime log.

Expected result:

- The diagnostics include `activeWindowTitle=`, `activeWindowClass=`, and `activeWindowProcess=` fields.
- These values help determine whether the browser window was active when the flow started.

## 26. Case 22. Unstable behaviour reproduction and analysis

Goal: use `flowAttemptId` and step markers to isolate unstable attempts.

Steps:

1. Identify the nearest `FLOWSTART` line for the unstable attempt.
2. Extract the corresponding `flowAttemptId`.
3. Collect all log lines containing this `flowAttemptId`.
4. Locate the last `STEPDONE` marker for this attempt.
5. Compare the unstable attempt with a stable one, for example `F9` versus `Ctrl+F11` or the replay phase of `Ctrl+F12`.

Expected result:

- If the last marker is `STEPDONE opencontextmenu`, the failure likely occurs during menu navigation.
- If the last marker is `STEPDONE movetomenuitem`, the failure likely occurs at the confirmation step or in Alice itself.
- If the last marker is `STEPDONE choosecurrentmenuitem`, but Alice does not start reading, the failure is likely on the Alice side.
- The collected evidence is sufficient for timing-profile or focus-handling investigation.

## 27. Constraints and non-goals

- These test cases do not attempt to exhaustively validate Yandex Alice itself; they focus on the automation script and its interaction with the browser UI.
- The document assumes that `logs\ahk-runtime.log` is writable and not locked by other tools; if the log cannot be written, the debug-mode foundation is considered not functional.
- Plain `F11` must remain unbound by the script to avoid conflict with browser or OS behaviour; any binding of `F11` is treated as a regression.

## Notes for reviewers

When validating changes related to hotkeys, debug behavior, timing profiles, local developer workflow, or runtime logging, review these files together:

- `scripts/yandex-alice-read-selected.ahk`
- `scripts/lib/alice-common.ahk`
- `README.md`
- `docs/test-cases.md`
- `tests/project.tests.ps1`