import Foundation

enum ForegroundActivationTrigger: Equatable, Sendable {
    case applicationActivated
    case resync
}

enum SwitchReason: Equatable, Sendable {
    case matchedRule
    case globalDefault
}

enum SwitchSkipReason: Equatable, Sendable {
    case automaticSwitchingDisabled
    case sameForegroundApplication
    case ownApplication
}

enum SwitchFailureReason: Equatable, Sendable {
    case inputSourceUnavailable(InputMethod)
    case systemFailure(String)
}

struct SwitchRecord: Equatable, Sendable {
    let bundleIdentifier: String
    let appName: String
    let sourceID: String
    let sourceName: String
    let method: InputMethod
    let reason: SwitchReason
    let timestamp: Date
}

struct SwitchEvaluation: Equatable, Sendable {
    let method: InputMethod
    let reason: SwitchReason
}

enum SwitchCoordinator {
    static func skipReason(
        bundleIdentifier: String,
        lastBundleIdentifier: String?,
        isAutomaticSwitchingEnabled: Bool,
        ownBundleIdentifier: String?,
        ignoreSameForegroundApplication: Bool = false
    ) -> SwitchSkipReason? {
        guard isAutomaticSwitchingEnabled else { return .automaticSwitchingDisabled }
        if let ownBundleIdentifier, bundleIdentifier == ownBundleIdentifier { return .ownApplication }
        if !ignoreSameForegroundApplication, bundleIdentifier == lastBundleIdentifier {
            return .sameForegroundApplication
        }
        return nil
    }

    static func evaluate(
        bundleIdentifier: String,
        rules: [AppRule],
        defaultInputMethod: InputMethod
    ) -> SwitchEvaluation {
        let matched = rules.first {
            $0.isEnabled && $0.bundleIdentifier.caseInsensitiveCompare(bundleIdentifier) == .orderedSame
        }
        if let matched {
            return SwitchEvaluation(method: matched.inputMethod, reason: .matchedRule)
        }
        return SwitchEvaluation(method: defaultInputMethod, reason: .globalDefault)
    }
}
