// Sguardo: the accent the person chose. Each app ships a default accent (its brand color); the person can keep it,
// follow the macOS accent color, or pick their own. Stored in the app's UserDefaults, so it survives updates.
//
// Root views: `.sguardoAccent(default: .knock)` instead of `.sguardoAccent(.knock)`.
// Settings:   `SGAccentRow(title:, options: (app:, system:, custom:), customTitle:)` with the app's localized words.

import AppKit
import SwiftUI

public enum SGAccentChoice: String, CaseIterable, Identifiable, Sendable {
    /// The app's own color (default).
    case app
    /// System Settings › Appearance › Accent color.
    case system
    /// A color the person picked.
    case custom

    public var id: String { rawValue }
}

public enum SGAccentStore {
    public static let choiceKey = "sguardo.accent.choice"
    public static let customKey = "sguardo.accent.custom"

    /// Resolves the accent for a choice. `system` follows the macOS accent live.
    public static func accent(choice: SGAccentChoice, customHex: Int, appDefault: SG.Accent) -> SG.Accent {
        switch choice {
        case .app: return appDefault
        case .system: return SG.Accent(NSColor.controlAccentColor)
        case .custom: return customHex >= 0 ? SG.Accent(hex: UInt32(customHex)) : appDefault
        }
    }
}

private struct SGAccentFromSettings: ViewModifier {
    let appDefault: SG.Accent
    @AppStorage(SGAccentStore.choiceKey) private var choice: SGAccentChoice = .app
    @AppStorage(SGAccentStore.customKey) private var customHex: Int = -1
    /// Bumped when the person changes the macOS accent, so `.system` redraws.
    @State private var systemTick = 0

    func body(content: Content) -> some View {
        let _ = systemTick
        content
            .sguardoAccent(SGAccentStore.accent(choice: choice, customHex: customHex, appDefault: appDefault))
            .onReceive(NotificationCenter.default.publisher(for: NSColor.systemColorsDidChangeNotification)) { _ in
                systemTick &+= 1
            }
    }
}

public extension View {
    /// The person's accent (see `SGAccentRow`), falling back to the app's own color.
    func sguardoAccent(default appDefault: SG.Accent) -> some View {
        modifier(SGAccentFromSettings(appDefault: appDefault))
    }
}

/// Settings row: "Accent color" with a picker pill (app / system / custom) and, for custom, a color well.
/// Every visible word comes from the app, already localized.
public struct SGAccentRow: View {
    let title: String
    let options: (app: String, system: String, custom: String)
    let appDefault: SG.Accent

    @AppStorage(SGAccentStore.choiceKey) private var choice: SGAccentChoice = .app
    @AppStorage(SGAccentStore.customKey) private var customHex: Int = -1

    public init(_ title: String, options: (app: String, system: String, custom: String), appDefault: SG.Accent) {
        self.title = title
        self.options = options
        self.appDefault = appDefault
    }

    public var body: some View {
        SGLabeledRow {
            Text(title)
        } trailing: {
            HStack(spacing: 10) {
                if choice == .custom {
                    ColorPicker(options.custom, selection: customBinding, supportsOpacity: false)
                        .labelsHidden()
                }
                SGPickerPill(label(for: choice)) {
                    Picker(title, selection: $choice) {
                        ForEach(SGAccentChoice.allCases) { Text(label(for: $0)).tag($0) }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
                .accessibilityLabel(title)
            }
        }
    }

    private func label(for choice: SGAccentChoice) -> String {
        switch choice {
        case .app: options.app
        case .system: options.system
        case .custom: options.custom
        }
    }

    private var customBinding: Binding<Color> {
        Binding(
            get: { customHex >= 0 ? Color(nsColor: NSColor(sgHex: UInt32(customHex))) : appDefault.base },
            set: { color in
                guard let c = NSColor(color).usingColorSpace(.sRGB) else { return }
                let r = Int((c.redComponent * 255).rounded()), g = Int((c.greenComponent * 255).rounded())
                let b = Int((c.blueComponent * 255).rounded())
                customHex = (r << 16) | (g << 8) | b
            }
        )
    }
}
