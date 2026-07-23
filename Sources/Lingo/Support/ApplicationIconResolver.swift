import AppKit

struct ResolvedApplication: Equatable {
    let isInstalled: Bool
    let icon: NSImage
}

struct ApplicationLookup {
    var urlForBundleID: (String) -> URL?
    var iconForPath: (String) -> NSImage

    @MainActor static let live = ApplicationLookup(
        urlForBundleID: { NSWorkspace.shared.urlForApplication(withBundleIdentifier: $0) },
        iconForPath: { NSWorkspace.shared.icon(forFile: $0) }
    )
}

@MainActor
final class ApplicationIconResolver {
    static let shared = ApplicationIconResolver()

    private let lookup: ApplicationLookup
    private var cache: [String: ResolvedApplication] = [:]

    init(lookup: ApplicationLookup = .live) {
        self.lookup = lookup
    }

    func resolve(bundleIdentifier: String) -> ResolvedApplication {
        let trimmed = bundleIdentifier.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return ResolvedApplication(isInstalled: false, icon: Self.fallbackIcon)
        }
        if let cached = cache[trimmed] {
            return cached
        }
        let resolved: ResolvedApplication
        if let url = lookup.urlForBundleID(trimmed) {
            resolved = ResolvedApplication(isInstalled: true, icon: lookup.iconForPath(url.path))
        } else {
            resolved = ResolvedApplication(isInstalled: false, icon: Self.fallbackIcon)
        }
        cache[trimmed] = resolved
        return resolved
    }

    private static var fallbackIcon: NSImage {
        if let image = NSImage(systemSymbolName: "app.dashed", accessibilityDescription: nil) {
            return image
        }
        return NSImage(size: NSSize(width: 32, height: 32))
    }
}
