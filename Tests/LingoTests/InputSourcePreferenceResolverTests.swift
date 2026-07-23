import XCTest
@testable import Lingo

final class InputSourcePreferenceResolverTests: XCTestCase {
    private let sources = [
        InputSourceDescriptor(id: "com.sogou.inputmethod.sogou.pinyin", name: "Sogou Pinyin"),
        InputSourceDescriptor(id: "com.apple.keylayout.ABC", name: "ABC"),
        InputSourceDescriptor(id: "com.example.custom.chinese", name: "Custom Chinese")
    ]

    func testConfiguredChineseSourceIsUsedWhenAvailable() {
        let sourceID = InputSourcePreferenceResolver.sourceID(
            for: .chinese,
            chineseSourceID: "com.example.custom.chinese",
            englishSourceID: nil,
            availableSources: sources
        )

        XCTAssertEqual(sourceID, "com.example.custom.chinese")
    }

    func testMissingConfiguredSourceFallsBackToLegacyCandidate() {
        let sourceID = InputSourcePreferenceResolver.sourceID(
            for: .chinese,
            chineseSourceID: "com.missing.source",
            englishSourceID: nil,
            availableSources: sources
        )

        XCTAssertEqual(sourceID, "com.sogou.inputmethod.sogou.pinyin")
    }

    func testEnglishSourceUsesConfiguredValue() {
        let sourceID = InputSourcePreferenceResolver.sourceID(
            for: .english,
            chineseSourceID: nil,
            englishSourceID: "com.apple.keylayout.ABC",
            availableSources: sources
        )

        XCTAssertEqual(sourceID, "com.apple.keylayout.ABC")
    }

    func testReturnsNilWhenNoSourcesAreAvailable() {
        let sourceID = InputSourcePreferenceResolver.sourceID(
            for: .english,
            chineseSourceID: "com.apple.keylayout.ABC",
            englishSourceID: "com.apple.keylayout.ABC",
            availableSources: []
        )

        XCTAssertNil(sourceID)
    }

    func testMigrationFillsMissingInputSourcePreferences() {
        var configuration = LingoConfiguration.defaults
        configuration.chineseInputSourceID = nil
        configuration.englishInputSourceID = nil

        let migrated = InputSourcePreferenceResolver.migrate(configuration, availableSources: sources)

        XCTAssertEqual(migrated.chineseInputSourceID, "com.sogou.inputmethod.sogou.pinyin")
        XCTAssertEqual(migrated.englishInputSourceID, "com.apple.keylayout.ABC")
    }
}
