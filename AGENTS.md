# AGENTS.md — Lingo repository guide

This guide applies to the entire repository. User instructions take precedence; a more deeply nested `AGENTS.md` overrides it in that subtree.

## Mission and privacy boundary

Lingo is a native macOS 14+ Swift 6 / SwiftUI menu bar app that switches input sources when the foreground application changes. Keep it local-first: do not add telemetry, analytics, cloud sync, remote configuration, a backend, or credential collection without an explicit product/privacy decision. Never commit usernames, personal absolute paths, signing material, tokens, or private application inventories.

## Start here

Read `README.md`, `docs/ARCHITECTURE.md`, `docs/SPEC_WORKFLOW.md`, the relevant file in `docs/specs/`, and then the affected implementation/tests.

## Mandatory workflow

Every feature or user-visible behavior change follows `docs/SPEC_WORKFLOW.md`: write/update the spec, write and observe a failing test, implement the minimum behavior, run full verification, then update docs and the spec implementation mapping. Domain policy must remain testable without SwiftUI, AppKit, Carbon, or live system state.

## Architecture rules

- `LingoStore` coordinates configuration and side effects; views render state and emit intent.
- `RuleResolver` owns input-method policy; Carbon code only enumerates/selects input sources.
- Observe foreground apps with `NSWorkspace.didActivateApplicationNotification`; do not regress to polling or AppleScript.
- Persist non-sensitive configuration in `UserDefaults` with safe decoding fallback.
- Do not construct shell commands from user input.
- Every visible string must exist in both `en.lproj` and `zh-Hans.lproj`.
- Keep macOS compatibility aligned with `Package.swift` unless an accepted spec changes it.

## Project-local skills

- For compiling, packaging, or installing locally, use `skills/build-install-lingo/SKILL.md`.
- For SwiftUI/menu-bar/settings UI changes, use `skills/lingo-ui-guidelines/SKILL.md`.
- Before completion or commit readiness, use `skills/verify-lingo-change/SKILL.md`.

## Commands and completion

Run `swift test` and `./script/security_check.sh` for every completed change. For UI, lifecycle, resources, login items, notifications, or packaging changes, also run `./script/build_and_run.sh --verify` when GUI launch is available. Preserve unrelated user changes; do not commit or push unless requested.
