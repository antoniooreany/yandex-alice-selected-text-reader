# Changelog

All notable changes to this project will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project aims to follow Semantic Versioning where applicable.

## Unreleased

### Devtools

- Refactor `tools/collect-project-context.ps1` to include:
  - file metadata for key project files (`README.md`, main AHK script, shared library, tests, docs);
  - full content snapshots for `README.md` and manual test cases;
  - focused log filters for Alice flows, including `Ctrl+F11`/`Ctrl+F12`, timing profiles, `choosecurrentmenuitem` and `Enter` markers;
  - smoke-test commands for tests, AHK runner, and context report collection.

## 2026-07-10

### Added

- Introduced step-debug flow for the primary Alice action under `Ctrl+F12`.
- Added replay confirmation contract: `Replay all steps without confirmations?` for guided step-debug runs.
- Documented step-debug behavior, flow markers, and replay expectations in `README.md` and `docs/test-cases.md`.

### Changed

- Updated primary and alternate Alice flows to use shared timing helpers and stable logging markers.
- Clarified that plain `F11` is intentionally not bound to avoid conflicts with browser fullscreen mode.
- Adjusted debug-mode timings to use slower delays for context menu opening, menu movement, and Enter confirmation.

### Fixed

- Improved logging robustness to tolerate locked runtime log file when appending.
- Aligned primary flows and documented known `Ctrl+F12` replay issue in development notes.

## 2026-07-09

### Added

- Added debug-mode foundation for the AutoHotkey v2 Alice flow:
  - slower timing profile for debug runs;
  - dedicated debug hotkey `Ctrl+F11` for the primary action;
  - runtime logging for debug timing profile and mode selection.

### Changed

- Updated `README.md` to describe normal, debug, and step-debug flows, including hotkeys and expected log markers.
- Extended manual test cases in `docs/test-cases.md` to cover debug and step-debug scenarios.

## 2026-07-08

### Added

- Introduced FLOW-level runtime diagnostics (`FLOWSTART`, `FLOWDONE`, `FLOWCANCELLED`, `FLOWFAIL`) in the shared AHK library.
- Added step-level instrumentation for context menu automation:
  - `STEPSTART opencontextmenu` / `STEPDONE opencontextmenu`;
  - `STEPSTART movetomenuitem` / `STEPDONE movetomenuitem`;
  - `STEPSTART choosecurrentmenuitem` / `STEPDONE choosecurrentmenuitem`.

### Changed

- Updated `README.md` to explain FLOW and STEP markers with concrete log examples.
- Added manual test cases for verifying presence and stability of FLOW and STEP markers in `docs/test-cases.md`.

## 2026-07-07

### Added

- Initial project context collection script `tools/collect-project-context.ps1` for gathering:
  - system information;
  - AutoHotkey installation paths;
  - project tree;
  - git status and recent log;
  - diffs for main scripts and tests;
  - runtime log tails.

### Changed

- Extended `tests/project.tests.ps1` to assert presence of key project files and directories.
- Added basic development notes in `docs/notes.md` for manual observations across sites and menu index compatibility.

## 2026-07-06

### Added

- Initial AutoHotkey v2 script for reading selected text via Yandex Alice context menu:
  - main script `scripts/yandex-alice-read-selected.ahk`;
  - shared library `scripts/lib/alice-common.ahk`;
  - runtime logging to `logs/ahk-runtime.log`;
  - hotkeys `F8`, `F9`, `F10` for help, primary, and secondary actions.
- Added PowerShell helpers:
  - `tools/run-ahk.ps1` for running the main AHK script;
  - `tools/run-tests.ps1` for project test suite.

### Changed

- Documented project structure, requirements, and basic usage in `README.md`.
- Added initial manual smoke test cases to `docs/test-cases.md`.
