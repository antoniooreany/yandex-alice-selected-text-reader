\# Changelog



\## \[Unreleased]

\- Add pre-commit hook to run `tools\\check-repo-health.ps1` before commits.

\- Specify and implement global `Assert-NotInsideForeignGitRepo` guardrail for automation scripts.



\## \[0.2.0] - (planned)

\- Added `tools\\check-repo-health.ps1` to verify repository health:

&#x20; - Ensures `codeminder` is absent from the Alice project root.

&#x20; - Fails on unexpected nested `.git` directories.

&#x20; - Runs `tools\\run-tests.ps1` and fails if tests do not pass.



\## \[0.1.0] - 2026-07-06

\- Initial infrastructure release for Alice project.

\- Set up Git Flow workflow (`main`, `develop`, `feature/\*`, `release/\*`).\[web:1857]\[web:1877]

\- Fixed Pester test runner (`tools\\run-tests.ps1`) to use Pester 5.8.0 with detailed output.

\- Verified baseline project structure and green tests (8 tests passing).

