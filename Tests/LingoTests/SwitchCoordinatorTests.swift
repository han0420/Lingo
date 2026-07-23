import XCTest
@testable import Lingo

final class SwitchCoordinatorTests: XCTestCase {
    func testSkipWhenAutomaticSwitchingDisabled() {
        XCTAssertEqual(
            SwitchCoordinator.skipReason(
                bundleIdentifier: "com.apple.Safari",
                lastBundleIdentifier: nil,
                isAutomaticSwitchingEnabled: false,
                ownBundleIdentifier: "com.lingo.input-switcher"
            ),
            .automaticSwitchingDisabled
        )
    }

    func testSkipWhenSameForegroundApplication() {
        XCTAssertEqual(
            SwitchCoordinator.skipReason(
                bundleIdentifier: "com.apple.Safari",
                lastBundleIdentifier: "com.apple.Safari",
                isAutomaticSwitchingEnabled: true,
                ownBundleIdentifier: "com.lingo.input-switcher"
            ),
            .sameForegroundApplication
        )
    }

    func testSkipWhenOwnApplicationIsForeground() {
        XCTAssertEqual(
            SwitchCoordinator.skipReason(
                bundleIdentifier: "com.lingo.input-switcher",
                lastBundleIdentifier: nil,
                isAutomaticSwitchingEnabled: true,
                ownBundleIdentifier: "com.lingo.input-switcher"
            ),
            .ownApplication
        )
    }

    func testEvaluateUsesMatchedRule() {
        let rules = [AppRule(bundleIdentifier: "com.tencent.xinWeChat", appName: "WeChat", inputMethod: .chinese)]

        let evaluation = SwitchCoordinator.evaluate(
            bundleIdentifier: "com.tencent.xinWeChat",
            rules: rules,
            defaultInputMethod: .english
        )

        XCTAssertEqual(evaluation.method, .chinese)
        XCTAssertEqual(evaluation.reason, .matchedRule)
    }

    func testEvaluateFallsBackToGlobalDefault() {
        let evaluation = SwitchCoordinator.evaluate(
            bundleIdentifier: "dev.unknown",
            rules: [],
            defaultInputMethod: .english
        )

        XCTAssertEqual(evaluation.method, .english)
        XCTAssertEqual(evaluation.reason, .globalDefault)
    }
}
