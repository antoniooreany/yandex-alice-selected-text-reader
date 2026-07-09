# yandex-alice-selected-text-reader

AutoHotkey v2 script for reading selected text in a Chromium-based browser through the Yandex Alice context menu.

The script works only when the target browser window is active. It opens the browser context menu, moves to the configured Alice item, confirms the choice with Enter, and writes runtime diagnostics to the log file.

## Features

- AutoHotkey v2 implementation.
- Browser-scoped hotkeys via `#HotIf WinActive(...)`.
- Configurable menu item indexes for Alice actions.
- Runtime logging to `logs/ahk-runtime.log`.
- Normal flow, debug flow, and step-debug flow for troubleshooting.
- PowerShell helpers for running the script and tests.

## Project structure

```text
.
├── README.md
├── docs/
│   ├── notes.md
│   └── test-cases.md
├── logs/
│   ├── .gitkeep
│   ├── ahk-runtime.log
│   └── project.log
├── scripts/
│   ├── yandex-alice-read-selected.ahk
│   └── lib/
│       └── alice-common.ahk
├── tests/
│   └── project.tests.ps1
└── tools/
    ├── collect-project-context.ps1
    ├── run-ahk.ps1
    ├── run-tests.ps1
    └── ...
```

## Requirements

- Windows.
- AutoHotkey v2 installed.
- A Chromium-based browser window matching the configured executable filter.
- Yandex Alice available in the browser context menu.

## Hotkeys

The main script defines these hotkeys for the active browser window.

- `F8` — show help.
- `F9` — run the primary Alice action using `MAIN_MENU_INDEX`.
- `F10` — run the secondary Alice action using `ALT_MENU_INDEX`.
- `Ctrl+F11` — debug primary Alice flow.
- `Ctrl+F12` — experimental step-debug primary Alice flow for troubleshooting.

`F11` is intentionally not used by the script. In browsers, plain `F11` is typically reserved for fullscreen mode, so the project uses `Ctrl+F11` for the debug entry point instead.

`Ctrl+F12` should be treated as an experimental troubleshooting path. The main supported user-facing flows are `F9`, `F10`, and `Ctrl+F11`.

## Current behavior

### Normal flow

`F9` and `F10` run the normal non-interactive flow.

1. Open the browser context menu.
2. Move down by the configured number of menu steps.
3. Confirm the current menu item with Enter.
4. Write `FLOWSTART` and `FLOWDONE` markers to the runtime log.

### Debug flow

`Ctrl+F11` runs the primary Alice flow through the debug hotkey, but without step confirmations and without replay.

Use this mode when you want a dedicated debug entry point for the primary action without taking over the browser fullscreen shortcut.

### Step-debug flow

`Ctrl+F12` runs the primary Alice flow in experimental step-debug mode.

This mode is intended for troubleshooting and manual verification of the menu automation. The shared library contains step-level instrumentation and confirmation helpers such as:

- `ConfirmStep`
- `STEPSTART opencontextmenu`
- `STEPSTART movetomenuitem`
- `STEPSTART choosecurrentmenuitem`
- `FLOWSTART`
- `FLOWDONE`
- `FLOWCANCELLED`
- `FLOWFAIL`

In step-debug mode, the script first runs the flow with per-step confirmations. After the first pass, it asks:

```text
Replay all steps without confirmations?
```

If confirmed, the script attempts one replay of the same scenario without step-by-step prompts and then finishes with `FLOWDONE`. If cancelled at that point, the run is recorded as `FLOWCANCELLED`.

The replay phase is best-effort and should be treated as a troubleshooting aid rather than a guaranteed end-user workflow. It is useful for diagnostics and repeated input emission, but it is not currently documented as a strict guarantee of identical browser or menu behavior in every state.

## Logging

Runtime diagnostics are written to:

```text
logs/ahk-runtime.log
```

The logging helpers live in:

```text
scripts/lib/alice-common.ahk
```

Important log markers:

- `FLOWSTART` — the selected Alice flow started.
- `FLOWDONE` — the flow finished successfully.
- `FLOWCANCELLED` — the flow was cancelled intentionally.
- `FLOWFAIL` — the flow failed with an error.
- `STEPSTART ...` / `STEPDONE ...` — step-level diagnostics for the menu automation.
- `FLOWDETAIL ...` / `STEPDETAIL ...` — additional runtime details for mode, timing, and step execution.

Typical examples:

```text
INFO 2026-07-08 13:38:42 Hotkey pressed F9
INFO 2026-07-08 13:38:42 FLOWSTART mode=F9 AppsKey menu item 6 stepCount=6 stepDebug=0
INFO 2026-07-08 13:38:42 STEPSTART opencontextmenu keys=AppsKey delayMs=300
INFO 2026-07-08 13:38:42 STEPDONE opencontextmenu
INFO 2026-07-08 13:38:43 FLOWDONE mode=F9 AppsKey menu item 6
```

A successful `Ctrl+F12` run should contain the first pass step markers, then the replay prompt, then a replay attempt without confirmations, and finally `FLOWDONE`. The replay markers are useful for diagnostics, but they should not be interpreted as a strict UX guarantee for every browser or menu state.

## Running the script

Start the AutoHotkey script with the provided helper:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\run-ahk.ps1
```

If needed, the helper can also run in wait mode:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\run-ahk.ps1 -Wait
```

The script launcher resolves the main AHK file from `scripts\yandex-alice-read-selected.ahk` and tries standard AutoHotkey v2 installation paths.

## Running tests

Run the project test suite with:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\run-tests.ps1
```

The PowerShell tests check the repository contract, including:

- presence of key project files;
- presence of the main AHK script;
- presence of the shared AHK library;
- presence of docs and logs directory;
- stable logging markers such as `FLOWSTART`, `FLOWDONE`, `FLOWFAIL`, and `FLOWCANCELLED`;
- hotkey-related expectations in the main script;
- help text expectations;
- presence of the `Ctrl+F11` and `Ctrl+F12` bindings;
- absence of plain `F11::` in the application hotkey definitions;
- presence of the replay confirmation contract for step-debug mode.

The main test file is:

```text
tests/project.tests.ps1
```

## Test cases and notes

Additional manual test coverage and project notes are stored here:

- `docs/test-cases.md`
- `docs/notes.md`

Use `docs/test-cases.md` for manual verification scenarios around hotkeys, debug behavior, replay behavior, and expected runtime logging.

## Troubleshooting

### AutoHotkey executable not found

If `tools/run-ahk.ps1` cannot find AutoHotkey v2, install AutoHotkey v2 and verify one of the standard executable paths exists.

### Hotkeys do not trigger

Check that:

- the target browser window is active;
- the browser executable matches the configured `BROWSER_EXE`;
- AutoHotkey v2 is running the script successfully.

### The script runs but Alice action does not open

Check:

- `MAIN_MENU_INDEX` and `ALT_MENU_INDEX`;
- browser context menu order;
- timing values inside `alice-common.ahk`, especially the delays used for:
  - opening the context menu;
  - moving through menu items;
  - pressing Enter.

### Step-debug replay expectations

`Ctrl+F12` is primarily a troubleshooting mode. The guided first pass, confirmation prompts, and runtime log markers are the main supported contract for this flow.

If the replay phase behaves inconsistently, check:

- that the script reaches `ConfirmStep("replayall", ...)`;
- that replay calls `OpenContextMenu(false)`, `MoveToMenuItem(stepCount, false)`, and `ChooseCurrentMenuItem(false)`;
- that the runtime log contains `STEPSTART replayall`, `STEPDONE replayall`, and `FLOWDETAIL stepdebug phase=replay-without-confirmations`;
- that `Ctrl+F11` does not call `ReadSelectedTextByIndex(..., true)` by mistake.

At the moment, replay is treated as best-effort diagnostic behavior rather than a guaranteed production workflow. If this mode becomes important in regular use, it can be refined in a dedicated follow-up change.

### Debugging with logs

Watch the runtime log live:

```powershell
Get-Content .\logs\ahk-runtime.log -Wait
```

Show the last 50 lines:

```powershell
Get-Content .\logs\ahk-runtime.log -Tail 50
```

If the flow starts but does not complete, compare the latest log entries for:

- the hotkey pressed line;
- `FLOWSTART`;
- step-level markers;
- `FLOWDONE`, `FLOWCANCELLED`, or `FLOWFAIL`.

## Development notes

The repository also includes helper scripts for diagnostics and project health checks, including project context collection. These helpers are useful when preparing bug reports, validating the current branch state, or reviewing runtime behavior during hotkey and flow changes.

When changing hotkeys, debug flow, or runtime logging, update these files together:

- `scripts/yandex-alice-read-selected.ahk`
- `scripts/lib/alice-common.ahk`
- `README.md`
- `docs/test-cases.md`
- `tests/project.tests.ps1`

## License

Internal project repository. Add a formal license section here if the project is later opened publicly.