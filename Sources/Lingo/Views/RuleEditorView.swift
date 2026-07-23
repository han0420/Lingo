import SwiftUI

struct RuleEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var rule: AppRule
    let onSave: (AppRule) -> Void

    init(rule: AppRule?, onSave: @escaping (AppRule) -> Void) {
        _rule = State(initialValue: rule ?? AppRule(bundleIdentifier: "", appName: "", inputMethod: .english))
        self.onSave = onSave
    }

    private var canSave: Bool {
        !rule.appName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !rule.bundleIdentifier.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        Form {
            TextField(L10n.string("editor.appName"), text: $rule.appName)
            TextField(L10n.string("editor.bundleID"), text: $rule.bundleIdentifier)
            Picker(L10n.string("editor.inputMethod"), selection: $rule.inputMethod) {
                ForEach(InputMethod.allCases) { method in
                    Text(method.localizedName).tag(method)
                }
            }
            .pickerStyle(.menu)
            Toggle(L10n.string("editor.enabled"), isOn: $rule.isEnabled)
            HStack {
                Spacer()
                Button(L10n.string("common.cancel")) { dismiss() }
                Button(L10n.string("common.save")) { onSave(rule); dismiss() }
                    .buttonStyle(.borderedProminent)
                    .disabled(!canSave)
            }
        }
        .formStyle(.grouped)
        .padding()
        .frame(width: 460)
    }
}
