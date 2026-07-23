import AppKit
import XCTest
@testable import Lingo

final class MenuBarIconProviderTests: XCTestCase {
    func testMenuBarStatesUseNativeSymbolsThatRemainLegibleAtSmallSizes() {
        XCTAssertEqual(MenuBarIconProvider.symbolName(for: .chinese), "keyboard.badge.ellipsis")
        XCTAssertEqual(MenuBarIconProvider.symbolName(for: .english), "keyboard.badge.ellipsis")
        XCTAssertEqual(MenuBarIconProvider.symbolName(for: .switching), "arrow.triangle.2.circlepath")
        XCTAssertEqual(MenuBarIconProvider.symbolName(for: .ruleActive(.chinese)), "keyboard.badge.ellipsis")
        XCTAssertEqual(MenuBarIconProvider.symbolName(for: .ruleActive(.english)), "keyboard.badge.ellipsis")
        XCTAssertEqual(MenuBarIconProvider.symbolName(for: .disabled), "character.cursor.ibeam.slash")
    }

    func testAppIconHasTransparentOuterCanvas() throws {
        let url = try XCTUnwrap(Bundle.module.url(forResource: "app-icon-source", withExtension: "png"))
        let image = try XCTUnwrap(NSImage(contentsOf: url))
        let bitmap = try XCTUnwrap(NSBitmapImageRep(data: try XCTUnwrap(image.tiffRepresentation)))

        let alpha = try XCTUnwrap(bitmap.colorAt(x: 0, y: 0)?.alphaComponent)
        XCTAssertEqual(Double(alpha), 0, accuracy: 0.001)
    }

    func testEveryRuntimeStateUsesAn18PointTemplateImage() {
        let states: [MenuBarIconState] = [
            .disabled,
            .chinese,
            .english,
            .switching,
            .ruleActive(.chinese),
            .ruleActive(.english)
        ]

        for state in states {
            let image = MenuBarIconProvider.image(for: state)
            XCTAssertEqual(image.size, NSSize(width: 18, height: 18), "Unexpected size for \(state)")
            XCTAssertTrue(image.isTemplate, "Expected template rendering for \(state)")
        }
    }
}
