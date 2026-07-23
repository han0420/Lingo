import XCTest
@testable import Lingo

final class ConfigurationTests: XCTestCase {
    func testDefaultsIncludeUsefulPresetRules() {
        let configuration = LingoConfiguration.defaults

        XCTAssertTrue(configuration.isAutomaticSwitchingEnabled)
        XCTAssertEqual(configuration.defaultInputMethod, .english)
        XCTAssertEqual(configuration.rules.first(where: { $0.bundleIdentifier == "com.tencent.xinWeChat" })?.inputMethod, .chinese)
        XCTAssertEqual(configuration.rules.first(where: { $0.bundleIdentifier == "com.apple.Safari" })?.inputMethod, .english)
    }

    func testUpsertingRuleReplacesDuplicateBundleIdentifier() {
        var configuration = LingoConfiguration.defaults
        configuration.upsert(AppRule(bundleIdentifier: "com.apple.Safari", appName: "Safari", inputMethod: .chinese))

        XCTAssertEqual(configuration.rules.filter { $0.bundleIdentifier == "com.apple.Safari" }.count, 1)
        XCTAssertEqual(configuration.rules.first { $0.bundleIdentifier == "com.apple.Safari" }?.inputMethod, .chinese)
    }

    func testConfigurationRoundTripsThroughPersistence() throws {
        let suiteName = "LingoTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let repository = ConfigurationRepository(
            defaults: defaults,
            availableSources: { [] }
        )
        var expected = LingoConfiguration.defaults
        expected.showsSwitchNotifications = true

        try repository.save(expected)

        XCTAssertEqual(repository.load(), expected)
    }

    func testCorruptPersistenceFallsBackToDefaults() {
        let suiteName = "LingoTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        defaults.set(Data("not-json".utf8), forKey: ConfigurationRepository.storageKey)

        XCTAssertEqual(
            ConfigurationRepository(defaults: defaults, availableSources: { [] }).load(),
            .defaults
        )
    }
}
