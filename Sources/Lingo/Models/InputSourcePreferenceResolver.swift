import Foundation

struct InputSourceDescriptor: Equatable, Identifiable, Sendable, Codable {
    let id: String
    let name: String
}

enum InputSourcePreferenceResolver {
    static let legacyChineseCandidates = [
        "com.sogou.inputmethod.sogou.pinyin",
        "com.apple.inputmethod.SCIM.ITABC"
    ]

    static let legacyEnglishCandidates = [
        "com.apple.keylayout.ABC",
        "com.apple.keylayout.US"
    ]

    static func sourceID(
        for method: InputMethod,
        chineseSourceID: String?,
        englishSourceID: String?,
        availableSources: [InputSourceDescriptor]
    ) -> String? {
        let availableIDs = Set(availableSources.map(\.id))
        let configuredID = method == .chinese ? chineseSourceID : englishSourceID
        if let configuredID, availableIDs.contains(configuredID) {
            return configuredID
        }
        let legacyCandidates = method == .chinese ? legacyChineseCandidates : legacyEnglishCandidates
        return legacyCandidates.first { availableIDs.contains($0) }
    }

    static func migrate(
        _ configuration: LingoConfiguration,
        availableSources: [InputSourceDescriptor]
    ) -> LingoConfiguration {
        var migrated = configuration
        if migrated.chineseInputSourceID == nil {
            migrated.chineseInputSourceID = sourceID(
                for: .chinese,
                chineseSourceID: nil,
                englishSourceID: nil,
                availableSources: availableSources
            )
        }
        if migrated.englishInputSourceID == nil {
            migrated.englishInputSourceID = sourceID(
                for: .english,
                chineseSourceID: nil,
                englishSourceID: nil,
                availableSources: availableSources
            )
        }
        return migrated
    }

    static func displayName(for sourceID: String, in availableSources: [InputSourceDescriptor]) -> String {
        availableSources.first { $0.id == sourceID }?.name ?? sourceID
    }
}
