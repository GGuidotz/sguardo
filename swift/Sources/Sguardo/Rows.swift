// Sguardo: settings content. Rows and groups on translucent fills, 16pt continuous corners, 1pt hairline.

import SwiftUI

/// Section heading above a group: 13 medium, secondary, inset 10pt.
public struct SGSectionTitle: View {
    let title: String
    public init(_ title: String) { self.title = title }
    public var body: some View {
        Text(title)
            .font(SG.Font.bodyEmphasis)
            .foregroundStyle(SG.Ink.secondary)
            .padding(.horizontal, SG.Space.sectionTitleInset)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Title + optional subtitle + trailing control, without its own surface (use inside `SGGroup`).
public struct SGRowContent<Trailing: View>: View {
    let title: String
    var subtitle: String?
    var trailing: Trailing

    public init(_ title: String, subtitle: String? = nil, @ViewBuilder trailing: () -> Trailing) {
        self.title = title
        self.subtitle = subtitle
        self.trailing = trailing()
    }

    public var body: some View {
        HStack(spacing: SG.Space.m) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(SG.Font.body).foregroundStyle(SG.Ink.primary)
                if let subtitle {
                    Text(subtitle)
                        .font(SG.Font.caption)
                        .foregroundStyle(SG.Ink.secondary)
                        .frame(maxWidth: SG.Size.subtitleMaxWidth, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer(minLength: SG.Space.s)
            trailing
        }
        .padding(.horizontal, SG.Space.rowInset)
        .padding(.vertical, subtitle == nil ? 0 : 10)
        .frame(minHeight: SG.Size.row)
    }
}

public extension SGRowContent where Trailing == EmptyView {
    init(_ title: String, subtitle: String? = nil) {
        self.init(title, subtitle: subtitle) { EmptyView() }
    }
}

/// A standalone row with its own surface.
public struct SGRow<Trailing: View>: View {
    let content: SGRowContent<Trailing>
    public init(_ title: String, subtitle: String? = nil, @ViewBuilder trailing: () -> Trailing) {
        content = SGRowContent(title, subtitle: subtitle, trailing: trailing)
    }
    public var body: some View { content.sgRowSurface() }
}

/// Several rows on one surface, separated by inset hairlines.
public struct SGGroup<Content: View>: View {
    let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }
    public var body: some View {
        VStack(spacing: 0) { content }.sgRowSurface()
    }
}

public struct SGDivider: View {
    public init() {}
    public var body: some View {
        Rectangle()
            .fill(SG.Fill.rowBorder)
            .frame(height: SG.Stroke.hairline)
            .padding(.leading, SG.Space.rowInset)
    }
}

/// Small native switch, accent-tinted.
public struct SGToggle: View {
    @Binding var isOn: Bool
    @Environment(\.sgAccent) private var accent
    public init(isOn: Binding<Bool>) { _isOn = isOn }
    public var body: some View {
        Toggle("", isOn: $isOn)
            .labelsHidden()
            .toggleStyle(.switch)
            .controlSize(.small)
            .tint(accent.base)
    }
}

/// Trailing menu picker in a row: capsule, faint fill, hairline, up-down chevron.
public struct SGPickerPill<MenuContent: View>: View {
    let label: String
    let menu: MenuContent

    public init(_ label: String, @ViewBuilder menu: () -> MenuContent) {
        self.label = label
        self.menu = menu()
    }

    public var body: some View {
        Menu { menu } label: {
            HStack(spacing: 6) {
                Text(label).lineLimit(1)
                Image(systemName: "chevron.up.chevron.down").font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(SG.Ink.secondary)
            }
            .font(SG.Font.body)
            .foregroundStyle(SG.Ink.primary)
            .padding(.horizontal, 12)
            .frame(height: 26)
            .background(Capsule().fill(SG.Fill.pickerPill))
            .overlay(Capsule().strokeBorder(SG.Fill.rowBorder, lineWidth: SG.Stroke.hairline))
            .contentShape(Capsule())
        }
        // `.button` + `.plain` draws the label as ordinary SwiftUI content, so the capsule chrome is honored
        // (`.borderlessButton` drops it). The tint override keeps the window accent off the label.
        .menuStyle(.button)
        .buttonStyle(.plain)
        .menuIndicator(.hidden)
        .fixedSize()
        .tint(SG.Ink.primary)
    }
}

/// Selectable preview tile. Selected = accent ring 3.5pt, 2.5pt outside the edge, plus a 12% wash.
public struct SGOptionTile<Preview: View>: View {
    let title: String
    let isSelected: Bool
    var size: CGSize
    let preview: Preview
    let action: () -> Void

    @Environment(\.sgAccent) private var accent

    public init(_ title: String, isSelected: Bool, size: CGSize = CGSize(width: 112, height: 76),
                action: @escaping () -> Void, @ViewBuilder preview: () -> Preview) {
        self.title = title
        self.isSelected = isSelected
        self.size = size
        self.action = action
        self.preview = preview()
    }

    public var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                preview
                    .frame(width: size.width, height: size.height)
                    .background(SG.Fill.tile)
                    .overlay(isSelected ? accent.selectedWash : .clear)
                    .clipShape(.sgTile)
                    .overlay(RoundedRectangle.sgTile.strokeBorder(SG.Fill.rowBorder, lineWidth: SG.Stroke.hairline))
                    .shadow(color: .black.opacity(0.15), radius: 4)
                    .overlay {
                        let out = SG.Stroke.selectionOutset + SG.Stroke.selectionRing / 2
                        RoundedRectangle(cornerRadius: SG.Radius.tile + out, style: .continuous)
                            .stroke(accent.base, lineWidth: SG.Stroke.selectionRing)
                            .padding(-out)
                            .opacity(isSelected ? 1 : 0)
                            .scaleEffect(isSelected ? 1 : 0.96)
                    }
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(isSelected ? SG.Ink.primary : SG.Ink.secondary)
            }
            .animation(SG.Motion.snappy, value: isSelected)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

/// Centered icon + message + one primary action.
public struct SGEmptyState: View {
    let systemImage: String
    let message: String
    var buttonTitle: String?
    var action: (() -> Void)?

    public init(systemImage: String, message: String, buttonTitle: String? = nil, action: (() -> Void)? = nil) {
        self.systemImage = systemImage
        self.message = message
        self.buttonTitle = buttonTitle
        self.action = action
    }

    public var body: some View {
        VStack(spacing: SG.Space.m) {
            Image(systemName: systemImage)
                .font(.system(size: SG.Size.emptyStateIcon))
                .foregroundStyle(SG.Ink.secondary)
            Text(message)
                .font(SG.Font.body)
                .foregroundStyle(SG.Ink.secondary)
                .multilineTextAlignment(.center)
            if let buttonTitle, let action {
                SGSmallButton(buttonTitle, action: action)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 340)
    }
}
