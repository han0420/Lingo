import AppKit
import SwiftUI

struct SettingsView: View {
    @Bindable var store: LingoStore
    @State private var searchText = ""
    @State private var editedRule: AppRule?
    @State private var rulePendingDeletion: AppRule?
    @State private var showsEditor = false

    private var filteredRules: [AppRule] {
        guard !searchText.isEmpty else { return store.configuration.rules }
        return store.configuration.rules.filter {
            $0.appName.localizedCaseInsensitiveContains(searchText)
                || $0.bundleIdentifier.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var emptyStateKey: String {
        if store.configuration.rules.isEmpty {
            return "rules.emptyList"
        }
        return "rules.empty"
    }

    var body: some View {
        TabView {
            rulesView
                .tabItem { Label(l10n: "tab.rules", systemImage: "list.bullet.rectangle") }
            globalSettingsView
                .tabItem { Label(l10n: "tab.general", systemImage: "gearshape") }
        }
        .padding(16)
        .frame(minWidth: 600, minHeight: 460)
        .navigationTitle(L10n.string("settings.title"))
        .background(SettingsWindowLifecycle(onClose: store.resyncForegroundApplication))
        .sheet(isPresented: $showsEditor) {
            RuleEditorView(rule: editedRule) { store.upsert($0) }
        }
    }

    private var rulesView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                TextField(L10n.string("rules.search"), text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .frame(minWidth: 160, maxWidth: 280)
                    .layoutPriority(1)
                Spacer(minLength: 8)
                Button {
                    editedRule = nil
                    showsEditor = true
                } label: {
                    Label(l10n: "rules.add", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
                Button {
                    if let rule = InstalledApplicationPicker.pickRule() {
                        editedRule = rule
                        showsEditor = true
                    }
                } label: {
                    Label(l10n: "rules.chooseApp", systemImage: "app.badge")
                }
            }

            rulesHeader

            List {
                ForEach(filteredRules) { rule in
                    RuleRow(rule: rule) { updated in
                        store.upsert(updated)
                    } onEdit: {
                        editedRule = rule
                        showsEditor = true
                    } onDelete: {
                        rulePendingDeletion = rule
                    }
                }
                .onDelete { store.deleteRules(at: $0, in: filteredRules) }
            }
            .listStyle(.inset)
            .overlay {
                if filteredRules.isEmpty {
                    ContentUnavailableView(L10n.string(emptyStateKey), systemImage: "text.magnifyingglass")
                }
            }
            .alert(
                L10n.string("rules.deleteConfirmationTitle"),
                isPresented: Binding(
                    get: { rulePendingDeletion != nil },
                    set: { if !$0 { rulePendingDeletion = nil } }
                ),
                presenting: rulePendingDeletion
            ) { rule in
                Button(L10n.string("rules.delete"), role: .destructive) {
                    store.delete(rule)
                    rulePendingDeletion = nil
                }
                Button(L10n.string("common.cancel"), role: .cancel) {
                    rulePendingDeletion = nil
                }
            } message: { rule in
                Text(L10n.format("rules.deleteConfirmation %@", rule.appName))
            }
        }
    }

    private var rulesHeader: some View {
        HStack(spacing: 12) {
            Color.clear.frame(width: 32, height: 1)
            Text(L10n.string("editor.appName"))
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(minWidth: 140, maxWidth: .infinity, alignment: .leading)
            Text(L10n.string("editor.inputMethod"))
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 120, alignment: .leading)
            Text(L10n.string("rules.enable"))
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 44, alignment: .center)
            Color.clear.frame(width: 64, height: 1)
        }
        .padding(.horizontal, 8)
    }

    private var globalSettingsView: some View {
        Form {
            Section(L10n.string("general.title")) {
                HStack {
                    Text(L10n.string("general.displayLanguage"))
                    Spacer(minLength: 12)
                    Picker("", selection: Binding(
                        get: { store.configuration.preferredLanguage },
                        set: { store.setPreferredLanguage($0) }
                    )) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(language.segmentTitle).tag(language)
                        }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                    .frame(width: 220)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Toggle(L10n.string("general.launchAtLogin"), isOn: Binding(
                        get: { store.configuration.launchesAtLogin },
                        set: { store.setLaunchAtLogin($0) }
                    ))
                    Text(L10n.string("general.launchAtLoginHint"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Section(L10n.string("general.switching")) {
                Toggle(L10n.string("general.enabled"), isOn: Binding(
                    get: { store.configuration.isAutomaticSwitchingEnabled },
                    set: { store.setAutomaticSwitching($0) }
                ))
                Picker(L10n.string("general.default"), selection: $store.configuration.defaultInputMethod) {
                    ForEach(InputMethod.allCases) { method in
                        Text(method.localizedName).tag(method)
                    }
                }
                .onChange(of: store.configuration.defaultInputMethod) { _, _ in store.save() }
                if !store.availableInputSources.isEmpty {
                    Picker(L10n.string("general.chineseInputSource"), selection: chineseInputSourceBinding) {
                        ForEach(store.availableInputSources) { source in
                            Text(inputSourceLabel(for: source)).tag(source.id)
                        }
                    }
                    if let message = unavailableInputSourceMessage(for: store.configuration.chineseInputSourceID) {
                        Text(message).font(.caption).foregroundStyle(.orange)
                    }
                    Picker(L10n.string("general.englishInputSource"), selection: englishInputSourceBinding) {
                        ForEach(store.availableInputSources) { source in
                            Text(inputSourceLabel(for: source)).tag(source.id)
                        }
                    }
                    if let message = unavailableInputSourceMessage(for: store.configuration.englishInputSourceID) {
                        Text(message).font(.caption).foregroundStyle(.orange)
                    }
                }
                Toggle(L10n.string("general.notifications"), isOn: Binding(
                    get: { store.configuration.showsSwitchNotifications },
                    set: { store.setNotifications($0) }
                ))
            }
            Section(L10n.string("general.systemStatus")) {
                HStack {
                    Text(L10n.string("general.automaticSwitching"))
                    Spacer()
                    Text(store.configuration.isAutomaticSwitchingEnabled
                        ? L10n.string("general.statusEnabled")
                        : L10n.string("general.statusDisabled"))
                        .foregroundStyle(.secondary)
                }
                if let status = store.lastStatus {
                    Label(status, systemImage: "checkmark.circle.fill").foregroundStyle(.green)
                }
                if let error = store.lastError {
                    Label(error, systemImage: "exclamationmark.triangle.fill").foregroundStyle(.orange)
                }
                Text(l10n: "general.permissionHint").font(.caption).foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
    }

    private var chineseInputSourceBinding: Binding<String> {
        Binding(
            get: { resolvedInputSourceID(for: .chinese) },
            set: { store.setChineseInputSource($0) }
        )
    }

    private var englishInputSourceBinding: Binding<String> {
        Binding(
            get: { resolvedInputSourceID(for: .english) },
            set: { store.setEnglishInputSource($0) }
        )
    }

    private func resolvedInputSourceID(for method: InputMethod) -> String {
        let configured = method == .chinese
            ? store.configuration.chineseInputSourceID
            : store.configuration.englishInputSourceID
        if let configured { return configured }
        return InputSourcePreferenceResolver.sourceID(
            for: method,
            chineseSourceID: store.configuration.chineseInputSourceID,
            englishSourceID: store.configuration.englishInputSourceID,
            availableSources: store.availableInputSources
        ) ?? store.availableInputSources.first?.id ?? ""
    }

    private func inputSourceLabel(for source: InputSourceDescriptor) -> String {
        "\(source.name) · \(source.id)"
    }

    private func unavailableInputSourceMessage(for sourceID: String?) -> String? {
        guard let sourceID,
              !store.availableInputSources.contains(where: { $0.id == sourceID }) else { return nil }
        return L10n.format("error.inputSourceUnavailable %@", sourceID)
    }
}

private struct RuleRow: View {
    let rule: AppRule
    let onUpdate: (AppRule) -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    private var application: ResolvedApplication {
        ApplicationIconResolver.shared.resolve(bundleIdentifier: rule.bundleIdentifier)
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(nsImage: application.icon)
                .resizable()
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(rule.appName)
                    .font(.headline)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Text(rule.bundleIdentifier)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                if !application.isInstalled {
                    Text(l10n: "rules.appNotFound")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
            }
            .frame(minWidth: 140, maxWidth: .infinity, alignment: .leading)

            Picker("", selection: Binding(
                get: { rule.inputMethod },
                set: { var copy = rule; copy.inputMethod = $0; onUpdate(copy) }
            )) {
                ForEach(InputMethod.allCases) { method in
                    Text(method.localizedName).tag(method)
                }
            }
            .labelsHidden()
            .pickerStyle(.menu)
            .frame(width: 120, alignment: .leading)

            Toggle("", isOn: Binding(
                get: { rule.isEnabled },
                set: { var copy = rule; copy.isEnabled = $0; onUpdate(copy) }
            ))
            .labelsHidden()
            .frame(width: 44, alignment: .center)
            .accessibilityLabel(L10n.string("rules.enable"))

            Button(action: onEdit) {
                Image(systemName: "pencil")
            }
            .buttonStyle(.borderless)
            .frame(width: 28)
            .help(L10n.string("rules.edit"))
            .accessibilityLabel(L10n.string("rules.edit"))

            Button(action: onDelete) {
                Image(systemName: "trash")
            }
            .buttonStyle(.borderless)
            .frame(width: 28)
            .help(L10n.string("rules.delete"))
            .accessibilityLabel(L10n.string("rules.delete"))
        }
        .padding(.vertical, 4)
    }
}
