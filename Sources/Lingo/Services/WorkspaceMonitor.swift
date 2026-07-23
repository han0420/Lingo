import AppKit

@MainActor
final class WorkspaceMonitor {
    private var observers: [NSObjectProtocol] = []

    func start(onActivation: @escaping @MainActor (String, String, ForegroundActivationTrigger) -> Void) {
        stop()
        let center = NSWorkspace.shared.notificationCenter

        observers.append(center.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { notification in
            guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
                  let bundleIdentifier = app.bundleIdentifier else { return }
            Task { @MainActor in
                onActivation(bundleIdentifier, app.localizedName ?? bundleIdentifier, .applicationActivated)
            }
        })

        observers.append(center.addObserver(
            forName: NSWorkspace.didWakeNotification,
            object: nil,
            queue: .main
        ) { _ in
            Task { @MainActor in
                guard let foreground = Self.frontmostApplication() else { return }
                onActivation(foreground.bundleIdentifier, foreground.appName, .resync)
            }
        })

        if let foreground = Self.frontmostApplication() {
            onActivation(foreground.bundleIdentifier, foreground.appName, .resync)
        }
    }

    func stop() {
        for observer in observers {
            NSWorkspace.shared.notificationCenter.removeObserver(observer)
        }
        observers = []
    }

    static func frontmostApplication() -> (bundleIdentifier: String, appName: String)? {
        guard let app = NSWorkspace.shared.frontmostApplication,
              let bundleIdentifier = app.bundleIdentifier else { return nil }
        return (bundleIdentifier, app.localizedName ?? bundleIdentifier)
    }
}
