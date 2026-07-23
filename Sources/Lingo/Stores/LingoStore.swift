import Foundation
import Observation

@MainActor
@Observable
final class LingoStore {
    var configuration: LingoConfiguration
    var lastStatus: String?
    var lastError: String?
    var lastSuccessfulSwitch: SwitchRecord?
    var isSwitching = false

    private let repository: ConfigurationRepository
    private let inputSourceService: InputSourceSelecting
    private let monitor: WorkspaceMonitor
    private let loginItemService: LoginItemService
    private let notificationService: SwitchNotificationService
    private var lastBundleIdentifier: String?
    private var activationSequence: UInt64 = 0

    var availableInputSources: [InputSourceDescriptor] {
        inputSourceService.availableSources()
    }

    var menuBarIconState: MenuBarIconState {
        if !configuration.isAutomaticSwitchingEnabled { return .disabled }
        if isSwitching { return .switching }
        guard let lastSuccessfulSwitch else { return .english }
        switch lastSuccessfulSwitch.reason {
        case .matchedRule:
            return .ruleActive(lastSuccessfulSwitch.method)
        case .globalDefault:
            return lastSuccessfulSwitch.method == .chinese ? .chinese : .english
        }
    }

    init(
        repository: ConfigurationRepository = ConfigurationRepository(),
        inputSourceService: InputSourceSelecting = InputSourceService(),
        monitor: WorkspaceMonitor = WorkspaceMonitor(),
        loginItemService: LoginItemService = LoginItemService(),
        notificationService: SwitchNotificationService = SwitchNotificationService()
    ) {
        self.repository = repository
        self.inputSourceService = inputSourceService
        self.monitor = monitor
        self.loginItemService = loginItemService
        self.notificationService = notificationService
        self.configuration = repository.load()
        LanguageSettings.apply(configuration.preferredLanguage)
    }

    func start() {
        monitor.start { [weak self] bundleIdentifier, appName, trigger in
            self?.applicationDidActivate(
                bundleIdentifier: bundleIdentifier,
                appName: appName,
                trigger: trigger
            )
        }
    }

    func resyncForegroundApplication() {
        guard let app = WorkspaceMonitor.frontmostApplication() else { return }
        applicationDidActivate(
            bundleIdentifier: app.bundleIdentifier,
            appName: app.appName,
            trigger: .resync
        )
    }

    func save() {
        do {
            try repository.save(configuration)
            lastStatus = L10n.string("status.saved")
            lastError = nil
        } catch {
            lastError = error.localizedDescription
        }
    }

    func setAutomaticSwitching(_ enabled: Bool) {
        configuration.isAutomaticSwitchingEnabled = enabled
        save()
    }

    func setPreferredLanguage(_ language: AppLanguage) {
        configuration.preferredLanguage = language
        LanguageSettings.apply(language)
        save()
    }

    func setLaunchAtLogin(_ enabled: Bool) {
        do {
            try loginItemService.setEnabled(enabled)
            configuration.launchesAtLogin = enabled
            save()
        } catch {
            lastError = error.localizedDescription
        }
    }

    func setNotifications(_ enabled: Bool) {
        configuration.showsSwitchNotifications = enabled
        if enabled { notificationService.requestAuthorization() }
        save()
    }

    func setChineseInputSource(_ sourceID: String?) {
        configuration.chineseInputSourceID = sourceID
        save()
    }

    func setEnglishInputSource(_ sourceID: String?) {
        configuration.englishInputSourceID = sourceID
        save()
    }

    func upsert(_ rule: AppRule) {
        configuration.upsert(rule)
        save()
    }

    func delete(_ rule: AppRule) {
        configuration.rules.removeAll { $0.id == rule.id }
        save()
    }

    func deleteRules(at offsets: IndexSet, in filteredRules: [AppRule]) {
        let ids = Set(offsets.map { filteredRules[$0].id })
        configuration.rules.removeAll { ids.contains($0.id) }
        save()
    }

    func applicationDidActivate(
        bundleIdentifier: String,
        appName: String,
        trigger: ForegroundActivationTrigger = .applicationActivated
    ) {
        if let skipReason = SwitchCoordinator.skipReason(
            bundleIdentifier: bundleIdentifier,
            lastBundleIdentifier: lastBundleIdentifier,
            isAutomaticSwitchingEnabled: configuration.isAutomaticSwitchingEnabled,
            ownBundleIdentifier: Bundle.main.bundleIdentifier,
            ignoreSameForegroundApplication: trigger == .resync
        ) {
            if skipReason == .sameForegroundApplication || skipReason == .ownApplication {
                return
            }
            return
        }

        activationSequence += 1
        let sequence = activationSequence
        lastBundleIdentifier = bundleIdentifier

        let evaluation = SwitchCoordinator.evaluate(
            bundleIdentifier: bundleIdentifier,
            rules: configuration.rules,
            defaultInputMethod: configuration.defaultInputMethod
        )
        let availableSources = inputSourceService.availableSources()
        guard let sourceID = InputSourcePreferenceResolver.sourceID(
            for: evaluation.method,
            chineseSourceID: configuration.chineseInputSourceID,
            englishSourceID: configuration.englishInputSourceID,
            availableSources: availableSources
        ) else {
            lastError = statusMessage(for: .inputSourceUnavailable(evaluation.method))
            return
        }

        isSwitching = true
        defer { isSwitching = false }

        do {
            _ = try inputSourceService.select(sourceID: sourceID)
            guard sequence == activationSequence else { return }

            let sourceName = InputSourcePreferenceResolver.displayName(for: sourceID, in: availableSources)
            let timestamp = Date()
            lastSuccessfulSwitch = SwitchRecord(
                bundleIdentifier: bundleIdentifier,
                appName: appName,
                sourceID: sourceID,
                sourceName: sourceName,
                method: evaluation.method,
                reason: evaluation.reason,
                timestamp: timestamp
            )
            lastStatus = statusMessage(
                for: evaluation.reason,
                appName: appName,
                sourceName: sourceName
            )
            lastError = nil
            if configuration.showsSwitchNotifications {
                notificationService.show(appName: appName, sourceName: sourceName)
            }
        } catch {
            guard sequence == activationSequence else { return }
            lastError = statusMessage(for: .systemFailure(error.localizedDescription))
        }
    }

    private func statusMessage(for failure: SwitchFailureReason) -> String {
        switch failure {
        case .inputSourceUnavailable(let method):
            InputSourceError.noAvailableSource(method).localizedDescription
        case .systemFailure(let message):
            message
        }
    }

    private func statusMessage(for reason: SwitchReason, appName: String, sourceName: String) -> String {
        switch reason {
        case .matchedRule:
            L10n.format("status.matchedRule %@ %@", appName, sourceName)
        case .globalDefault:
            L10n.format("status.globalDefault %@ %@", appName, sourceName)
        }
    }
}
