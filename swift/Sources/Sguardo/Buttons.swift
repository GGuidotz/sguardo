// Sguardo: buttons. Every pressable thing is a capsule. One accent button per view.

import SwiftUI

public enum SGButtonRole: Sendable { case primary, secondary, destructive }

/// Capsule style for any `Button` label (text, `Label` with a symbol, custom content).
/// `.small` = 12 semibold, padding 14 x 6 (row and header actions); `.large` = 13 medium, 38pt tall.
public struct SGCapsuleButtonStyle: ButtonStyle {
    public enum Size: Sendable { case small, large }
    var role: SGButtonRole
    var size: Size

    public init(_ role: SGButtonRole = .secondary, size: Size = .small) {
        self.role = role
        self.size = size
    }

    public func makeBody(configuration: Configuration) -> some View {
        StyledLabel(configuration: configuration, role: role, size: size)
    }

    private struct StyledLabel: View {
        let configuration: Configuration
        let role: SGButtonRole
        let size: Size
        @Environment(\.sgAccent) private var accent
        @Environment(\.isEnabled) private var isEnabled

        var body: some View {
            configuration.label
                .font(size == .small ? SG.Font.label : SG.Font.button)
                .labelStyle(SGCapsuleLabelStyle())
                .foregroundStyle(role == .secondary ? SG.Ink.primary : SG.Ink.onAccent)
                .padding(.horizontal, size == .small ? 14 : 22)
                .padding(.vertical, size == .small ? 6 : 0)
                .frame(height: size == .large ? SG.Size.buttonLarge : nil)
                .background(fill, in: Capsule())
                .contentShape(Capsule())
                .scaleEffect(configuration.isPressed ? 0.97 : 1)
                .brightness(configuration.isPressed ? -0.04 : 0)
                .opacity(isEnabled ? 1 : SG.Motion.disabledOpacity)
                .animation(SG.Motion.snappy, value: configuration.isPressed)
        }

        private var fill: Color {
            switch role {
            case .primary: accent.base
            case .destructive: SG.Status.destructive
            case .secondary: SG.Fill.neutralButton
            }
        }
    }
}

/// Icon + title tight together, as Sguardo capsules want them.
public struct SGCapsuleLabelStyle: LabelStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 6) {
            configuration.icon
            configuration.title
        }
    }
}

public extension ButtonStyle where Self == SGCapsuleButtonStyle {
    static var sgSecondary: SGCapsuleButtonStyle { SGCapsuleButtonStyle(.secondary) }
    static var sgPrimary: SGCapsuleButtonStyle { SGCapsuleButtonStyle(.primary) }
    static var sgDestructive: SGCapsuleButtonStyle { SGCapsuleButtonStyle(.destructive) }
}

/// Large 38pt capsule (onboarding, islands, empty states).
public struct SGPillButton: View {
    let title: String
    var role: SGButtonRole
    var width: CGFloat?
    var isEnabled: Bool
    var isDefault: Bool
    let action: () -> Void

    @Environment(\.sgAccent) private var accent
    @Environment(\.colorScheme) private var scheme

    public init(_ title: String, role: SGButtonRole = .primary, width: CGFloat? = SG.Size.primaryButtonWidth,
                isEnabled: Bool = true, isDefault: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.role = role
        self.width = width
        self.isEnabled = isEnabled
        self.isDefault = isDefault
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(SG.Font.button)
                .foregroundStyle(role == .secondary ? SG.Ink.primary : SG.Ink.onAccent)
                .padding(.horizontal, width == nil ? 22 : 0)
                .frame(width: width, height: SG.Size.buttonLarge)
                .background(fill, in: Capsule())
                .contentShape(Capsule())
        }
        .buttonStyle(SGPressStyle())
        .opacity(isEnabled ? 1 : SG.Motion.disabledOpacity)
        .disabled(!isEnabled)
        .keyboardShortcut(isDefault ? .defaultAction : nil)
    }

    private var fill: Color {
        switch role {
        case .primary: accent.base
        case .destructive: SG.Status.destructive
        case .secondary: SG.Fill.neutralButton
        }
    }
}

/// Compact capsule (12 semibold) for row trailing actions and header actions.
public struct SGSmallButton: View {
    let title: String
    var role: SGButtonRole
    var isEnabled: Bool
    let action: () -> Void

    @Environment(\.sgAccent) private var accent

    public init(_ title: String, role: SGButtonRole = .primary, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.role = role
        self.isEnabled = isEnabled
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(SG.Font.label)
                .foregroundStyle(role == .secondary ? SG.Ink.primary : SG.Ink.onAccent)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(fill, in: Capsule())
                .contentShape(Capsule())
        }
        .buttonStyle(SGPressStyle())
        .opacity(isEnabled ? 1 : SG.Motion.disabledOpacity)
        .disabled(!isEnabled)
    }

    private var fill: Color {
        switch role {
        case .primary: accent.base
        case .destructive: SG.Status.destructive.opacity(0.9)
        case .secondary: SG.Fill.neutralButton
        }
    }
}

/// Destructive action that fires only after a continuous hold, filling red left to right.
/// Use instead of a confirmation dialog.
public struct SGHoldToConfirmButton: View {
    let title: String
    var holdDuration: TimeInterval
    var hint: String?
    let action: () -> Void
    @State private var progress: CGFloat = 0

    /// `hint` is the VoiceOver hint in the app's language (for example "Tieni premuto per confermare").
    public init(_ title: String, holdDuration: TimeInterval = SG.Motion.holdToConfirm, hint: String? = nil,
                action: @escaping () -> Void) {
        self.title = title
        self.holdDuration = holdDuration
        self.hint = hint
        self.action = action
    }

    public var body: some View {
        Text(title)
            .font(SG.Font.label)
            .foregroundStyle(SG.Ink.primary)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background {
                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        SG.Fill.neutralButton
                        Rectangle().fill(SG.Status.destructive).frame(width: proxy.size.width * progress)
                    }
                }
            }
            .clipShape(Capsule())
            .contentShape(Capsule())
            .onLongPressGesture(minimumDuration: holdDuration) {
                action()
            } onPressingChanged: { pressing in
                withAnimation(.linear(duration: pressing ? holdDuration : 0.18)) { progress = pressing ? 1 : 0 }
            }
            .accessibilityAddTraits(.isButton)
            .accessibilityHint(hint ?? "")
    }
}

/// Subtle press feedback shared by all Sguardo buttons.
public struct SGPressStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .brightness(configuration.isPressed ? -0.04 : 0)
            .animation(SG.Motion.snappy, value: configuration.isPressed)
    }
}
