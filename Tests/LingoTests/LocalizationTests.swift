import XCTest
@testable import Lingo

final class LocalizationTests: XCTestCase {
    private let criticalKeys = [
        "app.name",
        "menu.enabled",
        "menu.settings",
        "tab.rules",
        "tab.general",
        "rules.search",
        "rules.add",
        "rules.chooseApp",
        "rules.empty",
        "rules.emptyList",
        "rules.appNotFound",
        "general.enabled",
        "general.default",
        "general.displayLanguage",
        "input.chinese",
        "input.english",
        "notification.title",
        "status.saved"
    ]

    override func tearDown() {
        LanguageSettings.apply(.zhHans)
        super.tearDown()
    }

    func testEnglishCriticalKeysResolveToNonKeyValues() {
        LanguageSettings.apply(.en)
        for key in criticalKeys {
            let value = L10n.string(key)
            XCTAssertFalse(value.isEmpty, "Missing English value for \(key)")
            XCTAssertNotEqual(value, key, "English value for \(key) should not equal the key")
        }
    }

    func testChineseCriticalKeysResolveToNonKeyValues() {
        LanguageSettings.apply(.zhHans)
        for key in criticalKeys {
            let value = L10n.string(key)
            XCTAssertFalse(value.isEmpty, "Missing Chinese value for \(key)")
            XCTAssertNotEqual(value, key, "Chinese value for \(key) should not equal the key")
        }
    }

    func testLocalizationKeySetsAreSymmetric() throws {
        let englishKeys = try localizationKeys(from: "en.lproj/Localizable.strings")
        let chineseKeys = try localizationKeys(from: "zh-Hans.lproj/Localizable.strings")
        XCTAssertEqual(englishKeys, chineseKeys)
    }

    func testFormattedStatusMessageUsesArguments() {
        LanguageSettings.apply(.en)
        let message = L10n.format("status.switched %@ %@", "Safari", "English")
        XCTAssertTrue(message.contains("Safari"))
        XCTAssertTrue(message.contains("English"))
        XCTAssertFalse(message.contains("%@"))
    }

    private func localizationKeys(from relativePath: String) throws -> Set<String> {
        let url = try XCTUnwrap(
            Bundle.module.url(forResource: "Localizable", withExtension: "strings", subdirectory: relativePath)
                ?? Bundle.module.url(forResource: "Localizable", withExtension: "strings", subdirectory: nil)
        )
        let contents = try String(contentsOf: url, encoding: .utf8)
        let pattern = #"^\s*"([^"]+)"\s*="#
        let regex = try NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines])
        let range = NSRange(contents.startIndex..<contents.endIndex, in: contents)
        let matches = regex.matches(in: contents, options: [], range: range)
        let keys = matches.compactMap { match -> String? in
            guard let range = Range(match.range(at: 1), in: contents) else { return nil }
            return String(contents[range])
        }
        return Set(keys)
    }
}
