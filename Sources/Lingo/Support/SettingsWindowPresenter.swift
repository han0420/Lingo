import AppKit
import SwiftUI

@MainActor
enum SettingsWindowPresenter {
    static func present(openSettings: OpenSettingsAction) {
        NSApp.activate(ignoringOtherApps: true)
        openSettings()
        focusExistingSettingsWindow()
    }

    private static func focusExistingSettingsWindow() {
        let title = L10n.string("settings.title")
        if let window = NSApp.windows.first(where: { $0.title == title || $0.title.contains(title) }) {
            window.makeKeyAndOrderFront(nil)
        }
    }
}
