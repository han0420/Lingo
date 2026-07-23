import XCTest
@testable import Lingo

final class RuleResolverTests: XCTestCase {
    func testEnabledRuleOverridesGlobalDefault() {
        let rules = [AppRule(bundleIdentifier: "com.tencent.xinWeChat", appName: "微信", inputMethod: .chinese)]

        let result = RuleResolver.resolve(bundleIdentifier: "com.tencent.xinWeChat", rules: rules, defaultInputMethod: .english)

        XCTAssertEqual(result, .chinese)
    }

    func testDisabledRuleFallsBackToGlobalDefault() {
        let rules = [AppRule(bundleIdentifier: "com.apple.Safari", appName: "Safari", inputMethod: .chinese, isEnabled: false)]

        let result = RuleResolver.resolve(bundleIdentifier: "com.apple.Safari", rules: rules, defaultInputMethod: .english)

        XCTAssertEqual(result, .english)
    }

    func testUnknownApplicationUsesGlobalDefault() {
        XCTAssertEqual(
            RuleResolver.resolve(bundleIdentifier: "dev.unknown", rules: [], defaultInputMethod: .chinese),
            .chinese
        )
    }
}
