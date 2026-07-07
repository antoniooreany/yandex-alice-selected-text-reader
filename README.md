# Yandex Alice Selected Text Reader

A browser automation project for sending selected text to Yandex Alice for reading or related voice-assisted workflows with AutoHotkey.

## Status

This project is under active development. Current development happens on `develop`. New work should be added through focused feature branches. Release work should only begin when the current feature set is actually ready.

## Development workflow

This repository follows a Gitflow-style workflow.

- Ongoing feature work starts from `develop`.
- Features should be implemented in dedicated feature branches.
- Release branches should not be started prematurely.
- The next real release should only be prepared after the current documentation and validation work is complete.

### Typical feature workflow

```powershell
git switch develop
git pull
git flow feature start add-some-small-change
# implement and validate the change
git flow feature finish add-some-small-change
git push origin develop
```

### Typical release workflow

```powershell
git switch develop
git pull
git flow release start 0.2.0
# update CHANGELOG.md, README.md, run validation, make final release-only fixes
git flow release finish 0.2.0
git push origin main
git push origin develop
git push origin --tags
```

## Testing and validation

Before committing changes or preparing a release, run the repository checks locally from the project root.

### Run now

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\run-tests.ps1
powershell -ExecutionPolicy Bypass -File .\tools\check-repo-health.ps1
```

These commands verify the current PowerShell tests and repository health checks.

### Manual smoke test

After automated checks pass, run the main AutoHotkey script through the repository launcher and verify the main user flow manually.

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\run-ahk.ps1
```

Direct script start is also available as a manual alternative:

```powershell
Start-Process .\scripts\yandex-alice-read-selected.ahk
```

Suggested smoke-test flow:

1. Open a page with selectable text in the browser.
2. Select a short text fragment.
3. Press `F9`.
4. Verify that the script opens the Alice-related context menu via `AppsKey`.
5. Verify that the script selects the configured menu item and starts the intended Alice-related workflow.
6. Repeat once with no selected text and confirm the script fails safely or does nothing unexpected.

## Debugging Alice flow with FLOW_* logs

Runtime diagnostics are written to `logs/ahk-runtime.log`.[file:344]

When the `F9` hotkey is triggered successfully, the log should contain a full execution flow:[file:344][file:509]

- `Hotkey pressed: F9`[file:344]
- `FLOW_START mode=...`[file:509]
- `STEP_START open_context_menu ...`[file:509]
- `STEP_DONE open_context_menu`[file:509]
- `STEP_START move_to_menu_item ...`[file:509]
- `STEP_DONE move_to_menu_item`[file:509]
- `STEP_START choose_current_menu_item ...`[file:509]
- `STEP_DONE choose_current_menu_item`[file:509]
- `FLOW_DONE mode=...`[file:344][file:509]

This step-by-step logging helps identify where the browser interaction fails.[file:509]

Typical interpretation:

- `FLOW_START` is present, but `STEP_DONE open_context_menu` is missing — the context menu did not open as expected.[file:509]
- `open_context_menu` succeeds, but playback does not start — the fixed menu index may point to the wrong item in the current browser state.[file:344][file:509]
- `FLOW_FAIL` is present — AutoHotkey raised an exception during execution.[file:509]

To inspect the latest runtime activity:

```powershell
Get-Content .\logs\ahk-runtime.log -Tail 40
```

For a clean smoke test:

```powershell
Get-Process AutoHotkey* -ErrorAction SilentlyContinue | Stop-Process -Force
powershell -ExecutionPolicy Bypass -File .\tools\run-ahk.ps1
```

Then select text in the browser, press `F9`, and inspect the log tail again.[file:344]

## Project context report

To collect a snapshot of the current repository state for debugging or discussion, run:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\collect-project-context.ps1
```

By default, the script saves a timestamped report to:

```text
artifacts/project-context/project-context-report_YYYY-MM-DD_HH-mm-ss.txt
```

You can also specify the output path manually:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\collect-project-context.ps1 -OutputPath .\artifacts\project-context\manual-report.txt
```

The generated report may include:

- system information;
- AutoHotkey installation detection;
- project tree;
- git status and recent log;
- diffs and current file contents for key project files;
- selected log files;
- test output.

Reports in `artifacts/project-context/` are generated artifacts for debugging and should not be committed.

## Current script behavior

The current main script is focused on a single primary flow:

- `F8` shows a short help notification.
- `F9` triggers reading of selected text through the Alice-related context menu.
- The script opens the menu with `AppsKey`.
- The target action is currently expected at menu item index `6`.[file:344]

This behavior may evolve as the project adds stronger debugging support, configurable settings, and future execution modes.

## Do not run now example

The following commands are examples for later workflow stages and should not be used as routine pre-commit validation commands.

```powershell
git flow release start 0.2.0
git flow release finish 0.2.0
```

## AI assistant guidance

Repository-specific AI instructions are stored in the following files:

- `AGENTS.md` primary shared instructions for all AI coding assistants.
- `GEMINI.md` Gemini-specific wrapper.
- `CLAUDE.md` Claude-specific wrapper.
- `.github/copilot-instructions.md` GitHub Copilot repository instructions.

The main policy is simple:

- commands intended for immediate execution must be clearly separated from example or future commands;
- release-related commands must not be suggested as the next step unless repository state has been checked and the user explicitly wants release work now.

## Documentation

Important project documentation files:

- `README.md` project overview and workflow notes.
- `CHANGELOG.md` notable project changes.
- `AGENTS.md` repository rules for AI assistants.
- `docs/test-cases.md` manual and smoke-test notes.

When documentation changes affect workflow, debugging, or assistant behavior, related files should be updated together.

## Versioning

This project follows Semantic Versioning. Upcoming work should be tracked in `CHANGELOG.md` under `Unreleased` until an actual release is prepared.

## License

This project is licensed under the MIT License. See `LICENSE` for details.
