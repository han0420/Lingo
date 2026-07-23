import Foundation

enum InputMethod: String, Codable, CaseIterable, Identifiable, Sendable {
    case chinese
    case english

    var id: String { rawValue }

    var localizedName: String {
        switch self {
        case .chinese: L10n.string("input.chinese")
        case .english: L10n.string("input.english")
        }
    }

    var localizedDisplayName: String { localizedName }
}

struct AppRule: Codable, Equatable, Identifiable, Sendable {
    var id: UUID
    var bundleIdentifier: String
    var appName: String
    var inputMethod: InputMethod
    var isEnabled: Bool

    init(
        id: UUID = UUID(),
        bundleIdentifier: String,
        appName: String,
        inputMethod: InputMethod,
        isEnabled: Bool = true
    ) {
        self.id = id
        self.bundleIdentifier = bundleIdentifier
        self.appName = appName
        self.inputMethod = inputMethod
        self.isEnabled = isEnabled
    }
}

struct LingoConfiguration: Codable, Equatable, Sendable {
    var isAutomaticSwitchingEnabled: Bool
    var defaultInputMethod: InputMethod
    var chineseInputSourceID: String?
    var englishInputSourceID: String?
    var preferredLanguage: AppLanguage
    var launchesAtLogin: Bool
    var showsSwitchNotifications: Bool
    var rules: [AppRule]

    enum CodingKeys: String, CodingKey {
        case isAutomaticSwitchingEnabled
        case defaultInputMethod
        case chineseInputSourceID
        case englishInputSourceID
        case preferredLanguage
        case launchesAtLogin
        case showsSwitchNotifications
        case rules
    }

    init(
        isAutomaticSwitchingEnabled: Bool,
        defaultInputMethod: InputMethod,
        chineseInputSourceID: String?,
        englishInputSourceID: String?,
        preferredLanguage: AppLanguage,
        launchesAtLogin: Bool,
        showsSwitchNotifications: Bool,
        rules: [AppRule]
    ) {
        self.isAutomaticSwitchingEnabled = isAutomaticSwitchingEnabled
        self.defaultInputMethod = defaultInputMethod
        self.chineseInputSourceID = chineseInputSourceID
        self.englishInputSourceID = englishInputSourceID
        self.preferredLanguage = preferredLanguage
        self.launchesAtLogin = launchesAtLogin
        self.showsSwitchNotifications = showsSwitchNotifications
        self.rules = rules
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isAutomaticSwitchingEnabled = try container.decode(Bool.self, forKey: .isAutomaticSwitchingEnabled)
        defaultInputMethod = try container.decode(InputMethod.self, forKey: .defaultInputMethod)
        chineseInputSourceID = try container.decodeIfPresent(String.self, forKey: .chineseInputSourceID)
        englishInputSourceID = try container.decodeIfPresent(String.self, forKey: .englishInputSourceID)
        preferredLanguage = try container.decodeIfPresent(AppLanguage.self, forKey: .preferredLanguage) ?? .zhHans
        launchesAtLogin = try container.decode(Bool.self, forKey: .launchesAtLogin)
        showsSwitchNotifications = try container.decode(Bool.self, forKey: .showsSwitchNotifications)
        rules = try container.decode([AppRule].self, forKey: .rules)
    }

    static let defaults = LingoConfiguration(
        isAutomaticSwitchingEnabled: true,
        defaultInputMethod: .english,
        chineseInputSourceID: nil,
        englishInputSourceID: nil,
        preferredLanguage: .zhHans,
        launchesAtLogin: false,
        showsSwitchNotifications: false,
        rules: [
            AppRule(bundleIdentifier: "com.tencent.xinWeChat", appName: "微信", inputMethod: .chinese),
            AppRule(bundleIdentifier: "com.apple.Safari", appName: "Safari", inputMethod: .english),
            AppRule(bundleIdentifier: "com.google.Chrome", appName: "Google Chrome", inputMethod: .english),
            AppRule(bundleIdentifier: "com.microsoft.VSCode", appName: "Visual Studio Code", inputMethod: .english),
            AppRule(bundleIdentifier: "com.todesktop.230313mzl4w4u92", appName: "Cursor", inputMethod: .english)
        ]
    )

    mutating func upsert(_ rule: AppRule) {
        let bundleIdentifier = rule.bundleIdentifier.trimmingCharacters(in: .whitespacesAndNewlines)
        let appName = rule.appName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !bundleIdentifier.isEmpty, !appName.isEmpty else { return }
        var normalized = rule
        normalized.bundleIdentifier = bundleIdentifier
        normalized.appName = appName
        rules.removeAll { $0.bundleIdentifier.caseInsensitiveCompare(bundleIdentifier) == .orderedSame }
        rules.append(normalized)
        rules.sort { $0.appName.localizedCaseInsensitiveCompare($1.appName) == .orderedAscending }
    }
}

enum RuleResolver {
    static func resolve(
        bundleIdentifier: String,
        rules: [AppRule],
        defaultInputMethod: InputMethod
    ) -> InputMethod {
        rules.first {
            $0.isEnabled && $0.bundleIdentifier.caseInsensitiveCompare(bundleIdentifier) == .orderedSame
        }?.inputMethod ?? defaultInputMethod
    }
}
