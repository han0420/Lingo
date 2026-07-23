import XCTest
@testable import Lingo

@MainActor
final class LanguageSettingsTests: XCTestCase {
    override func tearDown() {
        LanguageSettings.apply(.zhHans)
        super.tearDown()
    }

    func testEnglishLocaleResolvesLocalizedTabTitle() {
        LanguageSettings.apply(.en)

        let value = L10n.string("tab.rules")

        XCTAssertEqual(value, "App Rules")
        XCTAssertNotEqual(value, "tab.rules")
    }

    func testChineseLocaleResolvesLocalizedTabTitle() {
        LanguageSettings.apply(.zhHans)

        let value = L10n.string("tab.rules")

        XCTAssertEqual(value, "应用规则")
    }

    func testPreferredLanguageRoundTripsThroughConfiguration() throws {
        let suiteName = "LingoTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let repository = ConfigurationRepository(defaults: defaults, availableSources: { [] })
        var expected = LingoConfiguration.defaults
        expected.preferredLanguage = .en

        try repository.save(expected)

        XCTAssertEqual(repository.load().preferredLanguage, .en)
    }
}
