---
name: build-install-lingo
description: Build, sign, verify, run, or install the current Lingo native macOS app. Use for local compile/package/install/refresh requests involving Lingo.app.
---

# Build and install Lingo

Work from the repository root.

1. Inspect `git status --short` and preserve unrelated changes.
2. Run `swift test`.
3. Assemble a debug app with `./script/assemble_app.sh debug "$PWD/dist/Lingo.app"`. Use release only when explicitly requested.
4. Verify with `codesign --verify --deep --strict --verbose=2 "$PWD/dist/Lingo.app"`.
5. For local run/launch verification, use `./script/build_and_run.sh --verify`.
6. Only when the user explicitly asks to install, replace `/Applications/Lingo.app` with the verified bundle. Resolve both paths first; do not delete any other application.
7. Report output/install path, bundle identifier, version, build, configuration, signature type, tests, and launch verification.

Never bundle user configuration, application inventory, credentials, or signing secrets. Stop on build/signature failure instead of installing a partial bundle. Ad-hoc signing is for local use only.
