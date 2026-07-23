import XCTest
@testable import Lingo

final class ConfigurationMigrationTests: XCTestCase {
    func testLegacyConfigurationWithoutInputSourceFieldsPreservesRules() throws {
        let suiteName = "LingoTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let legacyJSON = """
        {
          "isAutomaticSwitchingEnabled": true,
          "defaultInputMethod": "english",
          "launchesAtLogin": false,
          "showsSwitchNotifications": false,
          "rules": [
            {
              "id": "A1B2C3D4-E5F6-7890-ABCD-EF1234567890",
              "bundleIdentifier": "com.apple.Safari",
              "appName": "Safari",
              "inputMethod": "english",
              "isEnabled": true
            }
          ]
        }
        """
        defaults.set(Data(legacyJSON.utf8), forKey: ConfigurationRepository.storageKey)

        let repository = ConfigurationRepository(
            defaults: defaults,
            availableSources: {
                [
                    InputSourceDescriptor(id: "com.sogou.inputmethod.sogou.pinyin", name: "Sogou"),
                    InputSourceDescriptor(id: "com.apple.keylayout.ABC", name: "ABC")
                ]
            }
        )
        let configuration = repository.load()

        XCTAssertEqual(configuration.rules.count, 1)
        XCTAssertEqual(configuration.rules.first?.bundleIdentifier, "com.apple.Safari")
        XCTAssertEqual(configuration.chineseInputSourceID, "com.sogou.inputmethod.sogou.pinyin")
        XCTAssertEqual(configuration.englishInputSourceID, "com.apple.keylayout.ABC")
    }
}
