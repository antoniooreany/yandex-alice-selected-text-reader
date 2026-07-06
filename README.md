# Yandex Alice Selected Text Reader

A browser extension project for sending selected text to Yandex Alice for reading or voice-related workflows.

## Status

This project is under active development.

Current development happens on `develop`. New work should be added through focused feature branches. Release work should only begin when the current feature set is actually ready.

## Development workflow

This repository follows a Gitflow-style workflow.

- Ongoing feature work starts from `develop`.
- Features should be implemented in dedicated feature branches.
- Release branches should not be started prematurely.
- The next real release should only be prepared after the current documentation work is complete.

## AI assistant guidance

Repository-specific AI instructions are stored in the following files:

- `AGENTS.md` — primary shared instructions for all AI coding assistants.
- `GEMINI.md` — Gemini-specific wrapper.
- `CLAUDE.md` — Claude-specific wrapper.
- `.github/copilot-instructions.md` — GitHub Copilot repository instructions.

The main policy is simple:

- commands intended for immediate execution must be clearly separated from example or future commands;
- release-related commands must not be suggested as the next step unless repository state has been checked and the user explicitly wants release work now.

## Documentation

Important project documentation files:

- `README.md` — project overview and workflow notes.
- `CHANGELOG.md` — notable project changes.
- `AGENTS.md` — repository rules for AI assistants.

When documentation changes affect workflow or assistant behavior, related files should be updated together.

## Versioning

This project follows Semantic Versioning.

Upcoming work should be tracked in `CHANGELOG.md` under `Unreleased` until an actual release is prepared.

## License

This project is licensed under the MIT License. See `LICENSE` for details.