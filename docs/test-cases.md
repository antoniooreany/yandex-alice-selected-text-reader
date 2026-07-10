# Manual test cases

This document contains manual verification scenarios for `yandex-alice-selected-text-reader`. Use it when validating hotkeys, runtime logging, debug behavior, step-debug behavior, replay behavior, timing profile changes, and local PowerShell workflow helpers.

## Preconditions

Before running the scenarios below, make sure all of the following are true:

- Windows is running normally.
- AutoHotkey v2 is installed.
- The target Chromium-based browser is open.
- The active browser window matches the configured `BROWSEREXE`.
- Yandex Alice is present in the browser context menu.
- The repository is opened from its root directory.
- The runtime log path is available at `logs/ahk-runtime.log`.

## Recommended preparation

Open one terminal for commands and, when needed, another terminal for log inspection.

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

## Case 1. Repository smoke test

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

## Case 2. Start AHK through the repository helper

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

## Case 3. F8 help hotkey

Goal: confirm that the help hotkey still works.

Steps:

1. Make the target browser window active.
2. Press `F8`.

Expected result:

- A help notification appears.
- The notification includes `F8`, `F9`, `F10`, `Ctrl+F11`, and `Ctrl+F12`.
- The runtime log contains `Hotkey pressed F8`.

## Case 4. F9 primary flow

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
  - `TIMINGPROFILE applied profile...normal`
  - `FLOWSTART`
  - `FLOWDETAIL`
  - `STEPSTART opencontextmenu`
  - `STEPSTART movetomenuitem`
  - `STEPSTART choosecurrentmenuitem`
  - `FLOWDONE`
- The same `flowAttemptId` is present across the flow lines of the attempt.

## Case 5. F10 secondary flow

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
  - `TIMINGPROFILE applied profile...normal`
  - `FLOWSTART`
  - `FLOWDETAIL`
  - `FLOWDONE`
- The flow records the expected menu item index for the secondary action.

## Case 6. Ctrl+F11 debug flow

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
  - `TIMINGPROFILE applied profile...debug`
  - `FLOWSTART`
  - `FLOWDETAIL`
  - `STEPSTART opencontextmenu`
  - `STEPSTART movetomenuitem`
  - `STEPSTART choosecurrentmenuitem`
  - `FLOWDONE`
- After the debug run, normal timing can be restored by the script.

## Case 7. Ctrl+F12 step-debug flow, accepted path

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
  - `TIMINGPROFILE applied profile...normal`
  - `FLOWSTART`
  - `FLOWDETAIL stepdebug phase=interactive-run`
  - `STEPPROMPT`
  - `STEPCONFIRMED`
  - `STEPSTART replayall`
  - `STEPDONE replayall`
  - `FLOWDETAIL stepdebug phase=replay-without-confirmations`
  - `FLOWDONE`
- The flow ends without `FLOWFAIL`.
- The same `flowAttemptId` ties together the whole attempt.

## Case 8. Ctrl+F12 step-debug flow, cancelled path

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
  - `FLOWCANCELLED`
- The run does not end with `FLOWDONE`.
- Cancellation is not reported as `FLOWFAIL` unless there is an unrelated runtime error.

## Case 9. Replay contract in step-debug flow

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
  - `FLOWDETAIL stepdebug phase=replay-without-confirmations`
- The replay path attempts:
  - `OpenContextMenu(false)`
  - `MoveToMenuItem(stepCount, false)`
  - `ChooseCurrentMenuItem(false)`
- Replay is treated as troubleshooting behavior, not as a strict UX guarantee for every browser state.

## Case 10. Timing profile verification

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

## Case 11. flowAttemptId correlation

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

## Case 12. Log tail command

Goal: confirm that the runtime log can be inspected quickly during diagnosis.

Steps:

1. In PowerShell, run:

```powershell
Get-Content .\logs\ahk-runtime.log -Tail 50
```

Expected result:

- The latest log lines are shown without waiting for new output.
- Recent hotkey and flow markers are visible.

## Case 13. Live log watch command

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

## Case 14. Local PowerShell helper: ahk-start

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

## Case 15. Local PowerShell helper: ahk-stop

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

## Case 16. Local PowerShell helper: ahk-tail

Goal: confirm that the helper shows the latest log lines quickly.

Steps:

1. Ensure `logs/ahk-runtime.log` exists.
2. Run:

```powershell
ahk-tail
```

Expected result:

- The last 50 log lines are shown.
- The command exits after printing the latest lines.
- If the file does not exist, a readable message is shown instead of an unhandled error.

## Case 17. Local PowerShell helper: ahk-log

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

## Case 18. Local PowerShell helper: ahk-restart

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

## Case 19. Negative case: missing runtime log for helper commands

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

## Case 20. Alice action does not open

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

## Notes for reviewers

When validating changes related to hotkeys, debug behavior, timing profiles, local developer workflow, or runtime logging, review these files together:

- `scripts/yandex-alice-read-selected.ahk`
- `scripts/lib/alice-common.ahk`
- `README.md`
- `docs/test-cases.md`
- `tests/project.tests.ps1`