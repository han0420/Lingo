import AppKit
import XCTest
@testable import Lingo

@MainActor
final class ApplicationIconResolverTests: XCTestCase {
    func testEmptyBundleIdentifierUsesFallbackIcon() {
        let resolver = ApplicationIconResolver(lookup: .live)
        let resolved = resolver.resolve(bundleIdentifier: "  ")
        XCTAssertFalse(resolved.isInstalled)
    }

    func testUnknownBundleIdentifierIsNotInstalled() {
        let lookup = ApplicationLookup(
            urlForBundleID: { _ in nil },
            iconForPath: { _ in NSImage() }
        )
        let resolver = ApplicationIconResolver(lookup: lookup)
        let resolved = resolver.resolve(bundleIdentifier: "dev.unknown.app")
        XCTAssertFalse(resolved.isInstalled)
    }

    func testInstalledApplicationIsResolvedFromLookup() {
        let expectedURL = URL(fileURLWithPath: "/Applications/Safari.app")
        let expectedIcon = NSImage(size: NSSize(width: 32, height: 32))
        final class LookupCounter: @unchecked Sendable {
            var count = 0
        }
        let counter = LookupCounter()
        let lookup = ApplicationLookup(
            urlForBundleID: { bundleID in
                counter.count += 1
                return bundleID == "com.apple.Safari" ? expectedURL : nil
            },
            iconForPath: { path in
                XCTAssertEqual(path, expectedURL.path)
                return expectedIcon
            }
        )
        let resolver = ApplicationIconResolver(lookup: lookup)
        let first = resolver.resolve(bundleIdentifier: "com.apple.Safari")
        let second = resolver.resolve(bundleIdentifier: "com.apple.Safari")
        XCTAssertTrue(first.isInstalled)
        XCTAssertTrue(second.isInstalled)
        XCTAssertEqual(counter.count, 1)
        XCTAssertEqual(first.icon, expectedIcon)
        XCTAssertEqual(second.icon, expectedIcon)
    }
}
