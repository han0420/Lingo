import AppKit
import SwiftUI

struct SettingsWindowLifecycle: NSViewRepresentable {
    let onClose: () -> Void

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            guard let window = view.window else { return }
            context.coordinator.observe(window: window)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onClose: onClose)
    }

    @MainActor
    final class Coordinator {
        private let onClose: () -> Void
        private var observer: NSObjectProtocol?

        init(onClose: @escaping () -> Void) {
            self.onClose = onClose
        }

        func observe(window: NSWindow) {
            guard observer == nil else { return }
            observer = NotificationCenter.default.addObserver(
                forName: NSWindow.willCloseNotification,
                object: window,
                queue: .main
            ) { [weak self] _ in
                Task { @MainActor in
                    if let observer = self?.observer {
                        NotificationCenter.default.removeObserver(observer)
                        self?.observer = nil
                    }
                    self?.onClose()
                }
            }
        }
    }
}
