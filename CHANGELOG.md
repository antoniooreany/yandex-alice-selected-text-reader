# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.2.0] - 2026-07-10

### Added
- Step-debug flow for the primary Alice action under `Ctrl+F12`.
- Replay confirmation contract: `Replay all steps without confirmations?`.
- Extended README and `docs/test-cases.md` with debug and step-debug behavior, flow markers, and replay expectations for Alice flows.

### Changed
- Normal and alternate Alice flows now use shared timing helpers and stable logging markers.
- Debug-mode timings switched to slower delays for context menu opening, menu navigation, and Enter confirmation.
- Development notes updated to cover step-debug replay behavior and known edge cases.

### Fixed
- Improved logging robustness when the runtime log file is locked during append.
- Aligned primary flows and documented `Ctrl+F12` replay issue in development notes.

## [0.1.0] - 2026-07-06

### Added
- Initial AutoHotkey v2 script for reading selected text via the Yandex Alice context menu:
  - main script `scripts/yandex-alice-read-selected.ahk`;
  - shared library `scripts/lib/alice-common.ahk`;
  - runtime logging to `logs/ahk-runtime.log`;
  - hotkeys `F8`, `F9`, `F10` for help, primary, and secondary Alice actions.
- PowerShell helpers:
  - `tools/run-ahk.ps1` to start the main AHK script;
  - `tools/run-tests.ps1` to run the project test suite.
- Initial project structure description and manual smoke tests in `README.md` и `docs/test-cases.md`.

### Added
- Added repository-wide AI instruction files: `AGENTS.md`, `GEMINI.md`, `CLAUDE.md`, and `.github/copilot-instructions.md`.

### Changed
- Documented command safety rules for AI assistants, including explicit separation between commands intended to run now and commands shown only as future examples.
- Clarified that release-related commands must not be suggested as immediate next steps until the repository state is checked and the current documentation work is complete.