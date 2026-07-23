import Carbon
import Foundation

enum InputSourceError: LocalizedError {
    case noAvailableSource(InputMethod)
    case selectionFailed(String)

    var errorDescription: String? {
        switch self {
        case .noAvailableSource(let method):
            L10n.format("error.noInputSource %@", method.localizedDisplayName)
        case .selectionFailed(let sourceID):
            L10n.format("error.selectionFailed %@", sourceID)
        }
    }
}

protocol InputSourceSelecting {
    func availableSources() -> [InputSourceDescriptor]
    func select(sourceID: String) throws -> String
}

struct InputSourceService: InputSourceSelecting {
    func availableSources() -> [InputSourceDescriptor] {
        let properties = [kTISPropertyInputSourceCategory: kTISCategoryKeyboardInputSource] as CFDictionary
        guard let sources = TISCreateInputSourceList(properties, false)?.takeRetainedValue() as? [TISInputSource] else {
            return []
        }

        return sources.compactMap { source in
            guard isSelectable(source), let id = sourceID(for: source) else { return nil }
            return InputSourceDescriptor(id: id, name: localizedName(for: source) ?? id)
        }
        .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    func select(sourceID requestedSourceID: String) throws -> String {
        let properties = [kTISPropertyInputSourceCategory: kTISCategoryKeyboardInputSource] as CFDictionary
        guard let sources = TISCreateInputSourceList(properties, false)?.takeRetainedValue() as? [TISInputSource],
              let source = sources.first(where: { sourceID(for: $0) == requestedSourceID }) else {
            throw InputSourceError.selectionFailed(requestedSourceID)
        }
        guard TISSelectInputSource(source) == noErr else {
            throw InputSourceError.selectionFailed(requestedSourceID)
        }
        return requestedSourceID
    }

    private func isSelectable(_ source: TISInputSource) -> Bool {
        guard let pointer = TISGetInputSourceProperty(source, kTISPropertyInputSourceIsSelectCapable) else {
            return false
        }
        return CFBooleanGetValue(Unmanaged<CFBoolean>.fromOpaque(pointer).takeUnretainedValue())
    }

    private func localizedName(for source: TISInputSource) -> String? {
        guard let pointer = TISGetInputSourceProperty(source, kTISPropertyLocalizedName) else { return nil }
        return Unmanaged<CFString>.fromOpaque(pointer).takeUnretainedValue() as String
    }

    private func sourceID(for source: TISInputSource) -> String? {
        guard let pointer = TISGetInputSourceProperty(source, kTISPropertyInputSourceID) else { return nil }
        return Unmanaged<CFString>.fromOpaque(pointer).takeUnretainedValue() as String
    }
}
