# Yandex Alice Selected Text Reader

A browser automation project for sending selected text to Yandex Alice for reading or related voice-assisted workflows with AutoHotkey.

## Status

This project is under active development. Current development happens on `develop`. New work should be added through focused feature branches. Release work should only begin when the current feature set is actually ready.

## Development workflow

This repository follows a Gitflow-style workflow.

- Ongoing feature work starts from `develop`.
- Features should be implemented in dedicated feature branches.
- Release branches should not be started prematurely.
- The next real release should only be prepared after the current documentation work is complete.

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

## Testing and Validation

Before committing changes or preparing a release, run the repository checks locally from the project root.

### Run now

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\run-tests.ps1
powershell -ExecutionPolicy Bypass -File .\tools\check-repo-health.ps1
```

These commands verify the current PowerShell tests and repository health checks.

### Manual smoke test

After automated checks pass, run the main AutoHotkey script through the repository launcher and verify the primary user flow manually.

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
3. Trigger the configured AutoHotkey action.
4. Verify that the selected text is captured and passed into the intended Alice-related workflow.
5. Repeat once with no selected text and confirm the script fails safely or does nothing unexpected.

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

When documentation changes affect workflow or assistant behavior, related files should be updated together.

## Versioning

This project follows Semantic Versioning. Upcoming work should be tracked in `CHANGELOG.md` under `Unreleased` until an actual release is prepared.

## License

This project is licensed under the MIT License. See `LICENSE` for details.