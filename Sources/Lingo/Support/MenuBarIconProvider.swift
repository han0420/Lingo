import AppKit

enum MenuBarIconState: Equatable {
    case disabled
    case chinese
    case english
    case switching
    case ruleActive(InputMethod)
}

enum MenuBarIconProvider {
    static func image(for state: MenuBarIconState) -> NSImage {
        let image = NSImage(
            systemSymbolName: symbolName(for: state),
            accessibilityDescription: nil
        ) ?? NSImage(systemSymbolName: "keyboard", accessibilityDescription: nil) ?? NSImage()
        image.size = NSSize(width: 18, height: 18)
        image.isTemplate = true
        return image
    }

    static func symbolName(for state: MenuBarIconState) -> String {
        switch state {
        case .disabled: "character.cursor.ibeam.slash"
        case .chinese, .english: "keyboard.badge.ellipsis"
        case .switching: "arrow.triangle.2.circlepath"
        case .ruleActive: "keyboard.badge.ellipsis"
        }
    }
}
