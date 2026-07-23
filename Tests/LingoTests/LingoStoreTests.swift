import XCTest
@testable import Lingo

@MainActor
final class LingoStoreTests: XCTestCase {
    func testAutomaticSwitchingToggleUpdatesSharedConfiguration() {
        let store = makeStore()

        store.setAutomaticSwitching(false)

        XCTAssertFalse(store.configuration.isAutomaticSwitchingEnabled)
    }

    func testDisabledAutomaticSwitchingDoesNotCallInputSourceService() {
        let inputSourceService = MockInputSourceService()
        let store = makeStore(inputSourceService: inputSourceService)
        store.configuration.isAutomaticSwitchingEnabled = false

        store.applicationDidActivate(bundleIdentifier: "com.apple.Safari", appName: "Safari")

        XCTAssertEqual(inputSourceService.selectCallCount, 0)
    }

    func testRepeatedForegroundApplicationDoesNotCallInputSourceServiceTwice() {
        let inputSourceService = MockInputSourceService()
        let store = makeStore(inputSourceService: inputSourceService)

        store.applicationDidActivate(bundleIdentifier: "com.apple.Safari", appName: "Safari")
        store.applicationDidActivate(bundleIdentifier: "com.apple.Safari", appName: "Safari")

        XCTAssertEqual(inputSourceService.selectCallCount, 1)
    }

    func testResyncAllowsRepeatedForegroundApplicationSwitch() {
        let inputSourceService = MockInputSourceService()
        let store = makeStore(inputSourceService: inputSourceService)

        store.applicationDidActivate(bundleIdentifier: "com.apple.Safari", appName: "Safari")
        store.applicationDidActivate(
            bundleIdentifier: "com.apple.Safari",
            appName: "Safari",
            trigger: .resync
        )

        XCTAssertEqual(inputSourceService.selectCallCount, 2)
    }

    func testSuccessfulSwitchRecordsInMemoryOnly() {
        let inputSourceService = MockInputSourceService()
        let store = makeStore(inputSourceService: inputSourceService)

        store.applicationDidActivate(bundleIdentifier: "dev.unknown.app", appName: "Unknown")

        XCTAssertEqual(store.lastSuccessfulSwitch?.bundleIdentifier, "dev.unknown.app")
        XCTAssertEqual(store.lastSuccessfulSwitch?.sourceID, "com.apple.keylayout.ABC")
        XCTAssertEqual(store.lastSuccessfulSwitch?.reason, .globalDefault)
        XCTAssertEqual(store.menuBarIconState, .english)
    }

    func testMatchedRuleUsesRuleActiveMenuBarState() {
        let inputSourceService = MockInputSourceService(sources: [
            InputSourceDescriptor(id: "com.sogou.inputmethod.sogou.pinyin", name: "Sogou")
        ])
        let store = makeStore(inputSourceService: inputSourceService)
        store.configuration.rules = [
            AppRule(bundleIdentifier: "com.tencent.xinWeChat", appName: "WeChat", inputMethod: .chinese)
        ]
        store.configuration.chineseInputSourceID = "com.sogou.inputmethod.sogou.pinyin"

        store.applicationDidActivate(bundleIdentifier: "com.tencent.xinWeChat", appName: "WeChat")

        XCTAssertEqual(store.lastSuccessfulSwitch?.reason, .matchedRule)
        XCTAssertEqual(store.menuBarIconState, .ruleActive(.chinese))
    }

    func testPresetBundleIDsMatchKnownReleaseIdentifiers() {
        let expected = [
            "com.tencent.xinWeChat",
            "com.apple.Safari",
            "com.google.Chrome",
            "com.microsoft.VSCode",
            "com.todesktop.230313mzl4w4u92"
        ]
        let configured = Set(LingoConfiguration.defaults.rules.map(\.bundleIdentifier))
        for bundleID in expected {
            XCTAssertTrue(configured.contains(bundleID), "Missing preset rule for \(bundleID)")
        }
    }

    func testDeletingRuleRemovesOnlyTheRequestedRule() {
        let store = makeStore()
        let ruleToDelete = store.configuration.rules[0]
        let remainingRule = store.configuration.rules[1]

        store.delete(ruleToDelete)

        XCTAssertFalse(store.configuration.rules.contains(where: { $0.id == ruleToDelete.id }))
        XCTAssertTrue(store.configuration.rules.contains(where: { $0.id == remainingRule.id }))
    }

    private func makeStore(inputSourceService: MockInputSourceService = MockInputSourceService()) -> LingoStore {
        LingoStore(
            repository: ConfigurationRepository(
                defaults: isolatedDefaults(),
                availableSources: { inputSourceService.availableSources() }
            ),
            inputSourceService: inputSourceService,
            monitor: WorkspaceMonitor(),
            loginItemService: LoginItemService(),
            notificationService: SwitchNotificationService()
        )
    }

    private func isolatedDefaults() -> UserDefaults {
        let suiteName = "LingoTests.\(UUID().uuidString)"
        return UserDefaults(suiteName: suiteName)!
    }
}

private final class MockInputSourceService: InputSourceSelecting {
    private(set) var selectCallCount = 0
    private let sources: [InputSourceDescriptor]

    init(
        sources: [InputSourceDescriptor] = [
            InputSourceDescriptor(id: "com.apple.keylayout.ABC", name: "ABC")
        ]
    ) {
        self.sources = sources
    }

    func availableSources() -> [InputSourceDescriptor] { sources }

    func select(sourceID: String) throws -> String {
        selectCallCount += 1
        return sourceID
    }
}
