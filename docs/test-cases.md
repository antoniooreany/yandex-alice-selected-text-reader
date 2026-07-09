# Test cases

Manual smoke cases for the AutoHotkey v2 Alice flow.

## Preconditions

- AutoHotkey v2 is installed
- Supported browser window is active
- Some text is selected on the page
- The script can write to `logs/ahk-runtime.log`

## Case 1 — Help hotkey

**Action**
- Press `F8`

**Expected**
- A help tooltip appears
- The runtime log contains `Hotkey pressed F8`

## Case 2 — Primary Alice flow with compatibility offset

**Action**
- Press `F9`

**Expected**
- The script opens the browser context menu
- The script targets the documented primary Alice action for menu item 6
- The runtime log contains `Hotkey pressed F9`
- The runtime log contains `FLOWSTART mode=F9 AppsKey menu item 6`
- The runtime log contains `STEPSTART opencontextmenu`
- The runtime log contains `STEPDONE opencontextmenu`
- The runtime log contains `STEPSTART movetomenuitem`
- The runtime log contains `STEPDONE movetomenuitem`
- The runtime log contains `STEPSTART choosecurrentmenuitem`
- The runtime log contains `STEPDONE choosecurrentmenuitem`
- The runtime log contains `FLOWDONE mode=F9 AppsKey menu item 6`
- The implementation uses one fewer actual Down step than the documented menu label because of the current browser menu layout

## Case 3 — Alternate Alice flow without offset

**Action**
- Press `F10`

**Expected**
- The script opens the browser context menu
- The script moves to menu item 7
- The script confirms the current menu item with Enter
- The runtime log contains `Hotkey pressed F10`
- The runtime log contains `FLOWSTART mode=F10 AppsKey menu item 7`
- The runtime log contains `FLOWDONE mode=F10 AppsKey menu item 7`

## Case 4 — Ctrl+F11 debug flow with compatibility offset

**Action**
- Press `Ctrl+F11`

**Expected**
- The runtime log contains `Hotkey pressed CtrlF11`
- The runtime log contains `FLOWSTART mode=CtrlF11 debug AppsKey menu item 6`
- The runtime log contains `FLOWDONE mode=CtrlF11 debug AppsKey menu item 6`
- The flow uses slower debug timings
- The flow does not use step-debug confirmations
- The implementation uses one fewer actual Down step than the documented menu label because of the current browser menu layout

## Case 5 — Step-debug happy path without offset

**Action**
1. Press `Ctrl+F12`
2. Press `OK` in all confirmation dialogs
3. Press `OK` in the replay confirmation dialog `Replay all steps without confirmations?`

**Expected**
- The runtime log contains `Hotkey pressed CtrlF12`
- The runtime log contains `FLOWSTART mode=CtrlF12 step debug AppsKey menu item 6`
- The runtime log contains the standard step markers for:
  - `opencontextmenu`
  - `movetomenuitem`
  - `choosecurrentmenuitem`
- After the guided pass, the script replays the same full flow once more without confirmations
- The runtime log ends with `FLOWDONE mode=CtrlF12 step debug AppsKey menu item 6`

## Case 6 — Step-debug cancel on menu movement

**Action**
1. Press `Ctrl+F12`
2. Press `OK` for `opencontextmenu`
3. Press `Cancel` during one of the `movetomenuitem` confirmations

**Expected**
- The flow stops immediately
- The runtime log contains `FLOWCANCELLED mode=CtrlF12 step debug AppsKey menu item 6`
- The cancellation reason contains `Cancelled at step movetomenuitem`

## Case 7 — Step-debug cancel on final confirmation

**Action**
1. Press `Ctrl+F12`
2. Press `OK` through open and navigation steps
3. Press `Cancel` in the `choosecurrentmenuitem` confirmation

**Expected**
- The flow stops before Enter is sent
- The runtime log contains `FLOWCANCELLED mode=CtrlF12 step debug AppsKey menu item 6`
- The cancellation reason contains `Cancelled at step choosecurrentmenuitem`

## Case 8 — Step-debug cancel on replay confirmation

**Action**
1. Press `Ctrl+F12`
2. Press `OK` through the first guided pass
3. Press `Cancel` in the replay confirmation dialog `Replay all steps without confirmations?`

**Expected**
- The first guided pass completes
- The replay pass does not start
- The runtime log contains `FLOWCANCELLED mode=CtrlF12 step debug AppsKey menu item 6`
- The cancellation reason contains `Cancelled at step replayall`

## Case 9 — Plain F11 is not used

**Action**
- Press plain `F11`

**Expected**
- Plain keyboard F11 must not be used by the script
- No script hotkey action should be triggered by plain `F11`

## Case 10 — No unexpected failure marker

**Action**
- Run `F9`
- Run `F10`
- Run `Ctrl+F12` and cancel intentionally

**Expected**
- Successful `F9` and `F10` runs contain `FLOWDONE`
- Cancelled `Ctrl+F12` run contains `FLOWCANCELLED`
- None of these normal scenarios should produce `FLOWFAIL`

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