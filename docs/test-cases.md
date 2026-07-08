# Test cases

This document contains manual test scenarios for the Yandex Alice selected text reader AutoHotkey script.

The focus is on hotkeys, browser-scoped behavior, runtime logging, debug flow, and step-debug flow.

## Preconditions

Before running the scenarios, make sure that:

- AutoHotkey v2 is installed.
- The script is started successfully.
- The target Chromium-based browser window is active.
- The browser matches the configured `BROWSER_EXE`.
- Yandex Alice is present in the browser context menu.
- Runtime log output is available at `logs/ahk-runtime.log`.

## Useful commands

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\run-ahk.ps1
powershell -ExecutionPolicy Bypass -File .\tools\run-tests.ps1
Get-Content .\logs\ahk-runtime.log -Wait
Get-Content .\logs\ahk-runtime.log -Tail 50
```

## Expected hotkeys

The current hotkey contract is:

- `F8` — show help.
- `F9` — run the primary Alice action.
- `F10` — run the secondary Alice action.
- `Ctrl+F11` — run the primary Alice flow through the debug hotkey.
- `Ctrl+F12` — run the primary Alice flow in step-debug mode.

Plain `F11` must not be used by the script, because browsers typically reserve it for fullscreen mode.

## Logging expectations

The runtime log file is:

```text
logs/ahk-runtime.log
```

The most important markers are:

- `FLOWSTART`
- `FLOWDONE`
- `FLOWCANCELLED`
- `FLOWFAIL`
- `STEPSTART opencontextmenu`
- `STEPSTART movetomenuitem`
- `STEPSTART choosecurrentmenuitem`
- `STEPDONE opencontextmenu`
- `STEPDONE movetomenuitem`
- `STEPDONE choosecurrentmenuitem`

A successful flow should normally end with `FLOWDONE` and should not end with `FLOWFAIL`.

A cancelled step-debug flow should normally end with `FLOWCANCELLED` and should not end with `FLOWFAIL`.

## TC-01: F8 shows help

**Goal**

Verify that the help hotkey works and that the help text reflects the current hotkey contract.

**Steps**

1. Activate the target browser window.
2. Press `F8`.

**Expected result**

- A notification appears with the help text.
- The help text mentions:
  - `F8`
  - `F9`
  - `F10`
  - `Ctrl+F11`
  - `Ctrl+F12`

**Log expectations**

The log should contain a stable hotkey marker similar to:

```text
Hotkey pressed F8
```

## TC-02: F9 runs the normal primary flow

**Goal**

Verify the normal non-interactive primary Alice action.

**Steps**

1. Activate the target browser window.
2. Select text on a web page.
3. Press `F9`.

**Expected result**

- The browser context menu is opened.
- The selection moves to the primary configured Alice menu item.
- The menu item is confirmed with Enter.
- Alice starts reading or handling the selected text according to the browser integration.

**Log expectations**

The log should contain, in order, markers equivalent to:

```text
Hotkey pressed F9
FLOWSTART
STEPSTART opencontextmenu
STEPDONE opencontextmenu
STEPSTART movetomenuitem
STEPDONE movetomenuitem
STEPSTART choosecurrentmenuitem
STEPDONE choosecurrentmenuitem
FLOWDONE
```

**Negative expectation**

- `FLOWFAIL` must not be present for this run.

## TC-03: F10 runs the normal secondary flow

**Goal**

Verify the secondary Alice action.

**Steps**

1. Activate the target browser window.
2. Select text on a web page.
3. Press `F10`.

**Expected result**

- The browser context menu is opened.
- The selection moves to the secondary configured Alice menu item.
- The current menu item is confirmed with Enter.

**Log expectations**

The log should contain markers equivalent to:

```text
Hotkey pressed F10
FLOWSTART
FLOWDONE
```

Step markers may also appear between them.

**Negative expectation**

- `FLOWFAIL` must not be present for this run.

## TC-04: Ctrl+F11 runs the debug primary flow

**Goal**

Verify that the dedicated debug hotkey exists and triggers the primary action through the debug entry point without using replay.

**Steps**

1. Activate the target browser window.
2. Select text on a web page.
3. Press `Ctrl+F11`.

**Expected result**

- The primary Alice action is started through the debug-specific hotkey.
- The script does not rely on plain `F11`.
- The browser fullscreen shortcut conflict is avoided.
- The flow completes without the step-debug replay prompt.

**Log expectations**

The log should contain a stable hotkey marker similar to:

```text
Hotkey pressed CtrlF11
```

The flow should also contain:

```text
FLOWSTART
FLOWDONE
```

Step-level log lines may also be present, depending on implementation details, but replay-specific behavior must not occur for `Ctrl+F11`.

**Negative expectation**

- `FLOWFAIL` must not be present for a successful run.
- The replay confirmation prompt must not appear.

## TC-05: Ctrl+F12 runs the full step-debug flow

**Goal**

Verify that step-debug mode pauses between steps, records step-level diagnostics, and then offers replay.

**Steps**

1. Activate the target browser window.
2. Select text on a web page.
3. Press `Ctrl+F12`.
4. In each step confirmation dialog, press `OK` until the first pass finishes.
5. When prompted with `Replay all steps without confirmations?`, press `OK`.

**Expected result**

- The script asks for confirmation before each major step.
- The first pass runs with per-step confirmations.
- After the first pass, the script asks whether it should replay the same scenario without confirmations.
- After confirming replay, the script runs the same flow once more without step-by-step prompts.
- The flow completes successfully.

**Log expectations**

The log should contain markers equivalent to:

```text
Hotkey pressed CtrlF12
FLOWSTART
STEPSTART opencontextmenu
STEPDONE opencontextmenu
STEPSTART movetomenuitem
STEPDONE movetomenuitem
STEPSTART choosecurrentmenuitem
STEPDONE choosecurrentmenuitem
STEPSTART opencontextmenu
STEPDONE opencontextmenu
STEPSTART movetomenuitem
STEPDONE movetomenuitem
STEPSTART choosecurrentmenuitem
STEPDONE choosecurrentmenuitem
FLOWDONE
```

Depending on implementation details, replay may also omit some progress details in the second pass, but the second pass must still happen before the final `FLOWDONE`.

**Negative expectation**

- `FLOWFAIL` must not be present for this run.

## TC-06: Ctrl+F12 cancellation on the first step

**Goal**

Verify that cancelling step-debug before the first action produces a clean cancellation instead of a failure.

**Steps**

1. Activate the target browser window.
2. Select text on a web page.
3. Press `Ctrl+F12`.
4. In the first confirmation dialog, press `Cancel`.

**Expected result**

- The script stops immediately.
- No Alice action is executed.
- The run is treated as a user cancellation, not as a runtime error.

**Log expectations**

The log should contain:

```text
Hotkey pressed CtrlF12
FLOWSTART
FLOWCANCELLED
```

The cancellation reason should mention the step key for the first cancelled step, for example `opencontextmenu`.

**Negative expectation**

- `FLOWFAIL` must not be present for this run.

## TC-07: Ctrl+F12 cancellation while moving through menu items

**Goal**

Verify cancellation in the middle of the menu traversal stage.

**Steps**

1. Activate the target browser window.
2. Select text on a web page.
3. Press `Ctrl+F12`.
4. Approve the context-menu opening step.
5. Approve at least one menu navigation step.
6. Press `Cancel` on one of the remaining `movetomenuitem` confirmations.

**Expected result**

- The script stops during the traversal stage.
- The run is recorded as a cancellation.

**Log expectations**

The log should contain:

```text
Hotkey pressed CtrlF12
FLOWSTART
STEPSTART movetomenuitem
FLOWCANCELLED
```

The cancellation reason should mention a `movetomenuitem` step key or an equivalent move-to-menu-item cancellation marker.

**Negative expectation**

- `FLOWFAIL` must not be present for this run.

## TC-08: Ctrl+F12 cancellation before Enter

**Goal**

Verify cancellation just before the final Enter confirmation.

**Steps**

1. Activate the target browser window.
2. Select text on a web page.
3. Press `Ctrl+F12`.
4. Approve all earlier step confirmations.
5. In the `choosecurrentmenuitem` confirmation dialog, press `Cancel`.

**Expected result**

- The script stops before sending Enter.
- The run is recorded as a cancellation.

**Log expectations**

The log should contain:

```text
Hotkey pressed CtrlF12
FLOWSTART
STEPSTART choosecurrentmenuitem
FLOWCANCELLED
```

The cancellation reason should mention `choosecurrentmenuitem`.

**Negative expectation**

- `FLOWFAIL` must not be present for this run.

## TC-09: Ctrl+F12 cancellation on replay confirmation

**Goal**

Verify the final replay confirmation in the step-debug flow.

**Steps**

1. Activate the target browser window.
2. Select text on a web page.
3. Press `Ctrl+F12`.
4. Approve all step confirmations in the first pass.
5. When asked `Replay all steps without confirmations?`, press `Cancel`.

**Expected result**

- The first pass completes.
- The replay does not start.
- The overall run is recorded as cancelled at the replay confirmation step.

**Log expectations**

The log should contain:

```text
Hotkey pressed CtrlF12
FLOWSTART
STEPDONE choosecurrentmenuitem
FLOWCANCELLED
```

The cancellation reason should mention the replay confirmation step, for example `replayall`.

**Negative expectation**

- `FLOWFAIL` must not be present for this run.

## TC-10: Browser scope blocks hotkeys outside the target browser

**Goal**

Verify that the script reacts only when the configured browser window is active.

**Steps**

1. Focus an application that is not the configured browser.
2. Press `F8`, `F9`, `F10`, `Ctrl+F11`, and `Ctrl+F12`.

**Expected result**

- The script should not react to these hotkeys outside the target browser window.
- No Alice flow should start.

**Log expectations**

- No new hotkey entries should be added for these key presses while the non-browser window is active.

## TC-11: Plain F11 remains available to the browser

**Goal**

Verify that the script does not capture plain `F11`.

**Steps**

1. Activate the target browser window.
2. Press plain `F11`.

**Expected result**

- The browser handles fullscreen mode as usual.
- The script does not start a debug run.
- No primary Alice flow is executed.

**Log expectations**

- There must be no application log entry that indicates the script handled plain `F11`.
- In particular, there should be no hotkey marker equivalent to `Hotkey pressed F11`.

## TC-12: Runtime error path produces FLOWFAIL

**Goal**

Verify that actual runtime problems are logged as failures.

**Steps**

1. Introduce a reproducible runtime problem, for example:
   - break the configured browser executable filter;
   - use a clearly wrong menu index in a temporary local test;
   - force a script-side error during development.
2. Run one of the flows.

**Expected result**

- The flow does not complete normally.
- The script reports an error notification.
- The run is recorded as a failure.

**Log expectations**

The log should contain:

```text
FLOWSTART
FLOWFAIL
```

**Negative expectation**

- A true runtime error must not be recorded as `FLOWCANCELLED`.

## TC-13: Automated contract remains green

**Goal**

Verify that the repository-level contract checks still pass after hotkey, logging, or debug-flow changes.

**Steps**

1. Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\run-tests.ps1
```

**Expected result**

- The PowerShell test suite passes.
- The tests confirm presence of the expected files, hotkeys, log markers, and step-debug contract.

## Notes for reviewers

When reviewing changes to hotkeys, debug flow, or step-level logging, always verify these five points together:

- the AutoHotkey implementation;
- the runtime log output;
- `README.md`;
- `docs/test-cases.md`;
- `tests/project.tests.ps1`.

These parts should evolve together so the documented behavior stays aligned with the actual script behavior.