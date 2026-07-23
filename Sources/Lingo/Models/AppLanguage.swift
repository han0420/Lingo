import Foundation

enum AppLanguage: String, Codable, CaseIterable, Identifiable, Sendable {
    case zhHans = "zh-Hans"
    case en

    var id: String { rawValue }

    var locale: Locale { Locale(identifier: rawValue) }

    var segmentTitle: String {
        switch self {
        case .zhHans: "简体中文"
        case .en: "English"
        }
    }
}

enum LanguageSettings {
    nonisolated(unsafe) private(set) static var currentLanguage: AppLanguage = .zhHans
    nonisolated(unsafe) private(set) static var currentLocale: Locale = AppLanguage.zhHans.locale

    static func apply(_ language: AppLanguage) {
        currentLanguage = language
        currentLocale = language.locale
    }
}
