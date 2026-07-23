import AppKit

@MainActor
final class WorkspaceMonitor {
    private var observer: NSObjectProtocol?

    func start(onActivation: @escaping @MainActor (String, String) -> Void) {
        stop()
        observer = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { notification in
            guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
                  let bundleIdentifier = app.bundleIdentifier else { return }
            Task { @MainActor in onActivation(bundleIdentifier, app.localizedName ?? bundleIdentifier) }
        }
    }

    func stop() {
        if let observer { NSWorkspace.shared.notificationCenter.removeObserver(observer) }
        observer = nil
    }
}
