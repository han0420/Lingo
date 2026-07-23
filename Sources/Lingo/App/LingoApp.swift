import AppKit
import SwiftUI

@main
struct LingoApp: App {
    @State private var store: LingoStore

    init() {
        let store = LingoStore()
        store.start()
        _store = State(initialValue: store)
    }

    var body: some Scene {
        MenuBarExtra {
            MenuBarContent(store: store)
        } label: {
            MenuBarIconLabel(state: store.menuBarIconState)
        }
        .menuBarExtraStyle(.menu)

        Settings {
            SettingsView(store: store)
        }
        .defaultSize(width: 680, height: 520)
    }
}

private struct MenuBarIconLabel: View {
    let state: MenuBarIconState

    var body: some View {
        Image(nsImage: MenuBarIconProvider.image(for: state))
            .renderingMode(.template)
    }
}

private struct MenuBarContent: View {
    @Bindable var store: LingoStore
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        Toggle(L10n.string("menu.enabled"), isOn: Binding(
            get: { store.configuration.isAutomaticSwitchingEnabled },
            set: { store.setAutomaticSwitching($0) }
        ))
        Divider()
        Button(L10n.string("menu.settings")) {
            SettingsWindowPresenter.present(openSettings: openSettings)
        }
        Button(L10n.string("menu.quit")) { NSApp.terminate(nil) }
    }
}
