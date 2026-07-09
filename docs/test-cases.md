# Test cases

Manual smoke cases for the AutoHotkey v2 Alice flow. These checks focus on hotkeys, runtime log markers, and the interactive troubleshooting paths.

## Preconditions

- AutoHotkey v2 is installed.
- Supported browser window is active.
- Some text is selected on the page.
- The script can write to `logs/ahk-runtime.log`.

## Case 1 — Help hotkey

**Action**
- Press `F8`.

**Expected**
- A help tooltip appears.
- The runtime log contains `Hotkey pressed F8`.

## Case 2 — Primary Alice flow

**Action**
- Press `F9`.

**Expected**
- The script opens the browser context menu.
- The script moves to the configured primary Alice action for menu item 6.
- The script confirms the current menu item with Enter.
- The runtime log contains `Hotkey pressed F9`.
- The runtime log contains `FLOWSTART mode=F9 AppsKey menu item 6`.
- The runtime log contains `STEPSTART opencontextmenu`.
- The runtime log contains `STEPDONE opencontextmenu`.
- The runtime log contains `STEPSTART movetomenuitem`.
- The runtime log contains `STEPDONE movetomenuitem`.
- The runtime log contains `STEPSTART choosecurrentmenuitem`.
- The runtime log contains `STEPDONE choosecurrentmenuitem`.
- The runtime log contains `FLOWDONE mode=F9 AppsKey menu item 6`.
- The runtime log does not contain `FLOWFAIL` for this run.

## Case 3 — Alternate Alice flow

**Action**
- Press `F10`.

**Expected**
- The script opens the browser context menu.
- The script moves to menu item 7.
- The script confirms the current menu item with Enter.
- The runtime log contains `Hotkey pressed F10`.
- The runtime log contains `FLOWSTART mode=F10 AppsKey menu item 7`.
- The runtime log contains `FLOWDONE mode=F10 AppsKey menu item 7`.
- The runtime log does not contain `FLOWFAIL` for this run.

## Case 4 — Ctrl+F11 debug flow

**Action**
- Press `Ctrl+F11`.

**Expected**
- The runtime log contains `Hotkey pressed CtrlF11`.
- The runtime log contains `FLOWSTART mode=CtrlF11 debug AppsKey menu item 6`.
- The runtime log contains `FLOWDONE mode=CtrlF11 debug AppsKey menu item 6`.
- The flow uses slower debug timings.
- The flow does not use step-debug confirmations.
- The runtime log does not contain `FLOWFAIL` for this run.

## Case 5 — Step-debug happy path

**Action**
1. Press `Ctrl+F12`.
2. Press `OK` in all confirmation dialogs.
3. Press `OK` in the replay confirmation dialog `Replay all steps without confirmations?`.

**Expected**
- The runtime log contains `Hotkey pressed CtrlF12`.
- The runtime log contains `FLOWSTART mode=CtrlF12 step debug AppsKey menu item 6`.
- The runtime log contains `FLOWDETAIL stepdebug phase=interactive-run`.
- The runtime log contains the standard step markers for:
  - `opencontextmenu`
  - `movetomenuitem`
  - `choosecurrentmenuitem`
- The runtime log contains `STEPSTART replayall` and `STEPDONE replayall`.
- The runtime log contains `FLOWDETAIL stepdebug phase=replay-without-confirmations`.
- The runtime log ends with `FLOWDONE mode=CtrlF12 step debug AppsKey menu item 6`.
- The runtime log does not contain `FLOWCANCELLED` or `FLOWFAIL` for this run.

**Notes**
- `Ctrl+F12` is intended as an experimental troubleshooting flow.
- The replay phase is best-effort: it is useful for diagnostics and repeated input emission, but it is not a strict guarantee of identical end-user behavior in every browser or menu state.

## Case 6 — Step-debug cancel on menu movement

**Action**
1. Press `Ctrl+F12`.
2. Press `OK` for `opencontextmenu`.
3. Press `Cancel` during one of the `movetomenuitem` confirmations.

**Expected**
- The flow stops immediately.
- The runtime log contains `FLOWCANCELLED mode=CtrlF12 step debug AppsKey menu item 6`.
- The cancellation reason contains `Cancelled at step movetomenuitem`.
- The runtime log does not contain `FLOWFAIL` unless there was a separate real error.

## Case 7 — Step-debug cancel on final confirmation

**Action**
1. Press `Ctrl+F12`.
2. Press `OK` through open and navigation steps.
3. Press `Cancel` in the `choosecurrentmenuitem` confirmation.

**Expected**
- The flow stops before Enter is sent.
- The runtime log contains `FLOWCANCELLED mode=CtrlF12 step debug AppsKey menu item 6`.
- The cancellation reason contains `Cancelled at step choosecurrentmenuitem`.
- The runtime log does not contain `FLOWFAIL` unless there was a separate real error.

## Case 8 — Step-debug cancel on replay confirmation

**Action**
1. Press `Ctrl+F12`.
2. Press `OK` through the first guided pass.
3. Press `Cancel` in the replay confirmation dialog `Replay all steps without confirmations?`.

**Expected**
- The first guided pass completes.
- The replay pass does not start.
- The runtime log contains `STEPSTART replayall`.
- The runtime log contains `FLOWCANCELLED mode=CtrlF12 step debug AppsKey menu item 6`.
- The cancellation reason contains `Cancelled at step replayall`.
- The runtime log does not contain `STEPDONE replayall` for that cancelled run.

## Case 9 — Plain F11 is not used

**Action**
- Press plain `F11`.

**Expected**
- Plain keyboard `F11` must not be used by the script.
- No script hotkey action should be triggered by plain `F11`.

## Case 10 — No unexpected failure marker

**Action**
- Run `F9`.
- Run `F10`.
- Run `Ctrl+F12` and cancel intentionally.

**Expected**
- Successful `F9` and `F10` runs contain `FLOWDONE`.
- Cancelled `Ctrl+F12` run contains `FLOWCANCELLED`.
- None of these normal scenarios should produce `FLOWFAIL`.

## Useful commands

Run tests:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\run-tests.ps1
```

Watch logs live:

```powershell
Get-Content .\logs\ahk-runtime.log -Wait
```

Show recent lines:

```powershell
Get-Content .\logs\ahk-runtime.log -Tail 80
```