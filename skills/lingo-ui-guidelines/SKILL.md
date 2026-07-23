---
name: lingo-ui-guidelines
description: Apply Lingo SwiftUI conventions when changing settings, app rules, menu bar commands, forms, controls, status feedback, or any other user-visible macOS UI.
---

# Lingo UI guidelines

Read `docs/UI_GUIDELINES.md` before editing views.

- Keep the settings `TabView`: app rules in the rule tab and persistent global options in a grouped `Form`.
- Keep rule rows scannable: icon, app name, Bundle ID, input method, enable toggle, edit action.
- Edit form values locally and persist through `LingoStore` only on a deliberate action or discrete control change.
- Use `.borderedProminent` for the primary add/save action and native List deletion behavior.
- Show success in green and actionable failures in orange; keep explanatory text caption-sized and secondary.
- Route every visible label, placeholder, help, notification, status, and error through both localization files.
- Views must not access Carbon, `UserDefaults`, login services, or foreground-app notifications directly.

After changes, run `swift test`; for UI/resources/lifecycle changes also run `./script/build_and_run.sh --verify` when GUI launch is available.
