import Foundation
import SwiftUI

enum L10n {
    static let bundle = Bundle.module

    static var locale: Locale { LanguageSettings.currentLocale }

    static func string(_ key: String) -> String {
        localizedBundle(for: LanguageSettings.currentLanguage)
            .localizedString(forKey: key, value: nil, table: nil)
    }

    static func format(_ key: String, _ arguments: CVarArg...) -> String {
        String(format: string(key), locale: locale, arguments: arguments)
    }

    private static func localizedBundle(for language: AppLanguage) -> Bundle {
        let candidates = [language.rawValue, language.rawValue.lowercased()]
        for candidate in candidates {
            if let path = bundle.path(forResource: candidate, ofType: "lproj"),
               let localizedBundle = Bundle(path: path) {
                return localizedBundle
            }
        }
        return bundle
    }
}

extension Text {
    init(l10n key: String) {
        self.init(L10n.string(key))
    }
}

extension Label where Title == Text, Icon == Image {
    init(l10n titleKey: String, systemImage: String) {
        self.init(L10n.string(titleKey), systemImage: systemImage)
    }
}
