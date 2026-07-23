import AppKit

enum InstalledApplicationPicker {
    @MainActor
    static func pickRule() -> AppRule? {
        let panel = NSOpenPanel()
        panel.title = L10n.string("picker.title")
        panel.directoryURL = URL(fileURLWithPath: "/Applications")
        panel.allowedContentTypes = [.application]
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        guard panel.runModal() == .OK, let url = panel.url, let bundle = Bundle(url: url),
              let identifier = bundle.bundleIdentifier else { return nil }
        let name = bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? bundle.object(forInfoDictionaryKey: "CFBundleName") as? String
            ?? url.deletingPathExtension().lastPathComponent
        return AppRule(bundleIdentifier: identifier, appName: name, inputMethod: .english)
    }
}
