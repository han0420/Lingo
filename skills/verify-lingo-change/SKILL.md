---
name: verify-lingo-change
description: Verify a Lingo feature, fix, refactor, documentation update, or commit-ready change. Checks specs, tests, localization, security, packaging, and git hygiene without editing or publishing.
---

# Verify a Lingo change

Validate and report only; do not edit, install, commit, or push during this skill.

1. Inspect `git status --short`, `git diff --stat`, and `git diff --check` when this is a git worktree.
2. Confirm the relevant `docs/specs/*.md` matches requirements, acceptance scenarios, status, implementation mapping, and manual checks.
3. Confirm user-visible changes are in `README.md`, ownership/data-flow changes are in `docs/ARCHITECTURE.md`, and privacy changes are documented.
4. Compare user-visible keys in both `Sources/Lingo/Resources/en.lproj/Localizable.strings` and `zh-Hans.lproj/Localizable.strings`.
5. Run `swift test` and `./script/security_check.sh`.
6. For UI, lifecycle, resources, login items, notifications, Carbon, or packaging changes, run `./script/build_and_run.sh --verify` when GUI launch is available.
7. If skills changed, run the system `skill-creator` `quick_validate.py` against each changed skill directory.
8. Report changed scope, passes, failures, and unperformed manual checks. Declare ready only if all required automated checks pass and specs/docs/localizations are current.
