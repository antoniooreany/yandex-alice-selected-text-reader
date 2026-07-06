\# AGENTS.md



\## Project overview



This repository contains the Yandex Alice Selected Text Reader project.



Agents working in this repository must prioritize safe, incremental changes and clear documentation. Prefer small, reviewable edits over broad refactors.



\## Primary sources of truth



Before making changes, read and follow:



1\. `README.md`

2\. `CHANGELOG.md`

3\. This `AGENTS.md`



If another tool-specific instruction file exists, treat `AGENTS.md` as the main shared policy unless the tool requires additional local behavior.



\## Repository workflow



\- Work from `develop` for ongoing feature work.

\- Create feature branches from `develop`.

\- Do not start or finish release branches unless the user explicitly says the repository is ready for release work.

\- Do not assume that the next semantic version should be released now.



\## Command safety rules



\- Never present future, optional, or example commands as if they should be run immediately.

\- Always separate commands into two explicit groups when relevant:

&#x20; - `Run now`

&#x20; - `Do not run now / example`

\- If a command is not intended for immediate execution in the repository's current state, mark it clearly as not for current execution.

\- Do not output release, branch-finalization, tagging, push, reset, rebase, or deletion commands as the next step unless the repository state has been checked first.

\- Before suggesting commands such as `git flow release start`, `git flow release finish`, `git push`, `git tag`, `git reset`, `git rebase`, or branch deletion, first confirm:

&#x20; - current branch,

&#x20; - working tree status,

&#x20; - whether the user wants that operation now.

\- Prefer one small executable step at a time.



\## Release rules



\- `0.2.0` is treated as the next real release only when the current documentation feature is complete.

\- Do not suggest starting the `0.2.0` release while the active documentation work is still in progress.

\- Release preparation must happen after the user explicitly confirms readiness.



\## Documentation rules



When updating documentation:



\- Keep instructions concrete and operational.

\- Prefer exact commands over vague prose.

\- Keep examples aligned with the repository's current workflow.

\- Update related docs together when needed, especially `README.md`, `CHANGELOG.md`, and AI instruction files.

\- Avoid documenting commands as the next step unless they are intended to be run now.



\## Git and change discipline



\- Make focused changes.

\- Avoid unrelated edits in the same change set.

\- Preserve existing repository conventions unless the user asks to change them.

\- If repository state is unknown, ask for `git status` and branch context before suggesting risky commands.



\## What to avoid



\- Do not invent release timing.

\- Do not assume a command shown for illustration should be executed now.

\- Do not rewrite large sections of documentation without need.

\- Do not add speculative versioning steps to current action lists.



\## Preferred response style for agents



\- Be explicit about what is safe to run now.

\- Distinguish clearly between current action and future action.

\- Use short, actionable steps.

\- When uncertain, ask for the current repository state instead of guessing.	 

