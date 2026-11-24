// Sguardo: design tokens. Mirrors tokens/tokens.json; change values there first.
// Derived from Glance (github.com/jonnyoo/glance): GlanceTheme, SettingsMetrics, OnboardingMetrics, NotchGeometry.

import AppKit
import SwiftUI

public enum SG {}

// MARK: - Accent (per app)

public extension SG {
    /// The accent ramp for one app. Set once at the root with `.sguardoAccent(...)`.
    struct Accent: Sendable {
        public let base: Color
        public let pale: Color
        public let bright: Color
        public let deep: Color

        public init(_ nsColor: NSColor) {
            let c = nsColor.usingColorSpace(.sRGB) ?? nsColor
            base = Color(nsColor: c)
            pale = Color(nsColor: c.blended(withFraction: 0.75, of: .white) ?? c)
            bright = Color(nsColor: c.blended(withFraction: 0.40, of: .white) ?? c)
            deep = Color(nsColor: c.blended(withFraction: 0.30, of: .black) ?? c)
        }

        public init(hex: UInt32) { self.init(NSColor(sgHex: hex)) }

        /// Glance blue, the default when an app has no brand color.
        public static let glance = Accent(hex: 0x3499FF)
        public static let typewithme = Accent(hex: 0x2E7DF5)
        public static let knock = Accent(hex: 0x33C773)

        /// Wash over a selected tile.
        public var selectedWash: Color { base.opacity(0.12) }
    }
}

private struct SGAccentKey: EnvironmentKey {
    static let defaultValue = SG.Accent.glance
}

public extension EnvironmentValues {
    var sgAccent: SG.Accent {
        get { self[SGAccentKey.self] }
        set { self[SGAccentKey.self] = newValue }
    }
}

public extension View {
    /// Sets the app accent for every Sguardo component below, and the SwiftUI tint.
    func sguardoAccent(_ accent: SG.Accent) -> some View {
        environment(\.sgAccent, accent).tint(accent.base)
    }
}

// MARK: - Color

public extension SG {
    enum Ink {
        public static let primary = adaptive(dark: NSColor(sgHex: 0xEEEEEE), light: NSColor(white: 0, alpha: 0.85))
        public static let secondary = adaptive(dark: NSColor(sgHex: 0xBFBFBF), light: NSColor(white: 0, alpha: 0.50))
        public static let tertiary = adaptive(dark: NSColor(sgHex: 0x999999), light: NSColor(white: 0, alpha: 0.40))
        public static let onAccent = Color.white
    }

    enum Fill {
        public static let row = adaptive(dark: NSColor(white: 1, alpha: 0.08), light: NSColor(white: 1, alpha: 0.75))
        public static let rowBorder = adaptive(dark: NSColor(white: 0.8, alpha: 0.12), light: NSColor(white: 0, alpha: 0.15))
        public static let neutralButton = adaptive(dark: NSColor(white: 1, alpha: 0.14), light: NSColor(white: 0, alpha: 0.10))
        public static let pickerPill = adaptive(dark: NSColor(white: 1, alpha: 0.05), light: NSColor(white: 0, alpha: 0.10))
        public static let tile = adaptive(dark: NSColor(white: 1, alpha: 0.05), light: NSColor(white: 0, alpha: 0.05))
        public static let tileOuterStroke = adaptive(dark: NSColor(white: 0.1, alpha: 0.35), light: NSColor(white: 0, alpha: 0))
        public static let barTint = adaptive(dark: NSColor(white: 1, alpha: 0.15), light: NSColor(white: 1, alpha: 0.5))
        public static let barBorder = adaptive(dark: NSColor(white: 1, alpha: 0.16), light: NSColor(white: 0, alpha: 0.08))
        public static let selectedPill = adaptive(dark: NSColor(white: 1, alpha: 0.10), light: NSColor(white: 1, alpha: 0.70))
        public static let selectedPillBorder = adaptive(dark: NSColor(white: 1, alpha: 0.12), light: NSColor(white: 0, alpha: 0.06))
    }

    /// Always-dark transient panels (notch, floating pill, onboarding). Not adaptive by design.
    enum Island {
        public static let panel = Color.black
        public static let surface = Color(nsColor: NSColor(sgHex: 0x1E1E1E))
        public static let surfaceRaised = Color(nsColor: NSColor(sgHex: 0x323232))
        public static let textPrimary = Color.white
        public static let textDetail = Color(nsColor: NSColor(sgHex: 0xBDBDBD))
        public static let textSecondary = Color(nsColor: NSColor(sgHex: 0x949494))
        public static let placeholder = Color(nsColor: NSColor(sgHex: 0x2F2F2F))
    }

    enum Status {
        public static let success = Color(nsColor: NSColor(sgHex: 0x30D158))
        public static let danger = Color(nsColor: NSColor(sgHex: 0xFF453A))
        public static let destructive = Color(nsColor: NSColor(sgHex: 0xE03B2F))
        public static let warning = Color(nsColor: NSColor(sgHex: 0xFFBE54))
        public static let qualityPoor = Color(nsColor: NSColor(sgHex: 0xFF5454))
        public static let qualityFair = Color(nsColor: NSColor(sgHex: 0xFFBE54))
        public static let qualityGood = Color(nsColor: NSColor(sgHex: 0x85FF77))
    }

    /// Resolves live against the current appearance.
    static func adaptive(dark: NSColor, light: NSColor) -> Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua ? dark : light
        })
    }
}

public extension NSColor {
    convenience init(sgHex hex: UInt32, alpha: CGFloat = 1) {
        self.init(srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
                  green: CGFloat((hex >> 8) & 0xFF) / 255,
                  blue: CGFloat(hex & 0xFF) / 255,
                  alpha: alpha)
    }
}

// MARK: - Type

public extension SG {
    enum Font {
        public static let title = SwiftUI.Font.system(size: 26, weight: .bold)
        public static let instruction = SwiftUI.Font.system(size: 15, weight: .medium)
        public static let body = SwiftUI.Font.system(size: 13, weight: .regular)
        public static let bodyEmphasis = SwiftUI.Font.system(size: 13, weight: .medium)
        public static let button = SwiftUI.Font.system(size: 13, weight: .medium)
        public static let label = SwiftUI.Font.system(size: 12, weight: .semibold)
        public static let field = SwiftUI.Font.system(size: 12, weight: .regular)
        public static let caption = SwiftUI.Font.system(size: 11, weight: .regular)
        public static let value = SwiftUI.Font.system(size: 13, design: .monospaced)
    }
}

// MARK: - Space, size, radius

public extension SG {
    enum Space {
        public static let xxs: CGFloat = 4
        public static let xs: CGFloat = 6
        public static let s: CGFloat = 8
        public static let sm: CGFloat = 10
        public static let m: CGFloat = 12
        public static let ml: CGFloat = 14
        public static let l: CGFloat = 16
        public static let xl: CGFloat = 24
        public static let xxl: CGFloat = 28
        public static let xxxl: CGFloat = 32
        public static let huge: CGFloat = 40

        public static let contentPadding: CGFloat = 16
        public static let rowInset: CGFloat = 14
        public static let rowSpacing: CGFloat = 12
        public static let sectionTitleInset: CGFloat = 10
    }

    enum Size {
        public static let row: CGFloat = 44
        public static let buttonLarge: CGFloat = 38
        public static let buttonHeader: CGFloat = 30
        public static let buttonSmall: CGFloat = 26
        public static let field: CGFloat = 40
        public static let tabBar: CGFloat = 54
        public static let tabItem: CGFloat = 42
        public static let tabBarBottomInset: CGFloat = 14
        public static let statusDot: CGFloat = 16
        public static let glyph: CGFloat = 15
        public static let header: CGFloat = 52
        public static let panelWidth: CGFloat = 380
        public static let primaryButtonWidth: CGFloat = 160
        public static let subtitleMaxWidth: CGFloat = 260
        public static let emptyStateIcon: CGFloat = 34
        /// Bottom room so the last row clears a floating tab bar.
        public static var pageBottomInset: CGFloat { tabBar + tabBarBottomInset + 16 }
    }

    enum Radius {
        public static let tile: CGFloat = 13
        public static let row: CGFloat = 16
        public static let islandSmall: CGFloat = 22
        public static let island: CGFloat = 48
        public static let islandLarge: CGFloat = 60
    }

    enum Stroke {
        public static let hairline: CGFloat = 1
        public static let selectionRing: CGFloat = 3.5
        public static let selectionOutset: CGFloat = 2.5
    }
}

public extension Shape where Self == RoundedRectangle {
    static var sgRow: RoundedRectangle { RoundedRectangle(cornerRadius: SG.Radius.row, style: .continuous) }
    static var sgTile: RoundedRectangle { RoundedRectangle(cornerRadius: SG.Radius.tile, style: .continuous) }
    static var sgIsland: RoundedRectangle { RoundedRectangle(cornerRadius: SG.Radius.island, style: .continuous) }
}

// MARK: - Motion

public extension SG {
    enum Motion {
        /// Selection, tabs, toggles.
        public static let snappy = Animation.spring(response: 0.35, dampingFraction: 0.82)
        /// Step changes, panel resize. Animate size and content with this together.
        public static let standard = Animation.spring(response: 0.42, dampingFraction: 0.8)
        /// Island opening, small overshoot.
        public static let expand = Animation.spring(response: 0.45, dampingFraction: 0.7)
        /// Island closing, no overshoot.
        public static let collapse = Animation.spring(response: 0.45, dampingFraction: 1.0)
        public static let hover = Animation.easeOut(duration: 0.18)
        public static let fast = Animation.easeInOut(duration: 0.2)
        public static let state = Animation.easeInOut(duration: 0.28)
        public static let fade = Animation.easeInOut(duration: 0.35)

        public static let disabledOpacity: Double = 0.4
        public static let labelRevealOffset: CGFloat = 10
        public static let labelRevealBlur: CGFloat = 4
        public static let holdToConfirm: TimeInterval = 3

        /// Replaces springs with a short fade when Reduce Motion is on.
        public static func respecting(_ animation: Animation) -> Animation {
            NSWorkspace.shared.accessibilityDisplayShouldReduceMotion ? .easeInOut(duration: 0.2) : animation
        }
    }
}
