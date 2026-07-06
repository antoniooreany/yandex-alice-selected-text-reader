## Release workflow

This project uses Git Flow for development and release management.

### Branch roles

- `main` — stable production-ready releases. Each completed release is merged here and tagged with a version.
- `develop` — the main integration branch for completed feature work.
- `feature/*` — isolated implementation branches for small, focused changes.
- `release/*` — release preparation branches used to finalize versioned releases.
- `hotfix/*` — urgent fixes for issues that must be patched directly from the current stable release.

### Release rules

- New work is developed in `feature/*` branches and merged into `develop`.
- A release starts from `develop` using `git flow release start <version>`.
- A release branch should contain only release-oriented changes: documentation updates, version notes, small fixes, and final validation.
- A release is completed with `git flow release finish <version>`, which merges it into `main` and `develop` and creates the release tag.
- Stable releases are pushed from `main`, and release tags should also be pushed to GitHub.

### Versioning

This project uses semantic-style versioning:

- `MAJOR` — incompatible or breaking changes.
- `MINOR` — backward-compatible new features or meaningful project improvements.
- `PATCH` — small compatible fixes and corrections.

### Current release state

- Current stable release: `0.1.0`
- Next planned release: `0.2.0`

### Typical workflow

```powershell
git checkout develop
git flow feature start add-some-small-change

# implement and validate the change

git flow feature finish add-some-small-change
git push origin develop
```

### Typical release workflow

```powershell
git checkout develop
git flow release start 0.2.0

# update CHANGELOG.md / README.md, run validation, make final release-only fixes

git flow release finish 0.2.0
git push origin main
git push origin develop
git push origin --tags
```

### Validation before release

Before finishing a release:

- run `powershell -ExecutionPolicy Bypass -File .\tools\run-tests.ps1`
- run `powershell -ExecutionPolicy Bypass -File .\tools\check-repo-health.ps1`
- update `CHANGELOG.md`
- confirm the working tree is clean