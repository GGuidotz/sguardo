// Sguardo: floating tab bar. A capsule pinned above the window bottom; the selected item
// sits on a sliding pill and unfurls its title from the icon (opacity + blur + slide).

import SwiftUI

public struct SGTab<ID: Hashable>: Identifiable {
    public let id: ID
    public let title: String
    public let systemImage: String
    public init(_ id: ID, title: String, systemImage: String) {
        self.id = id
        self.title = title
        self.systemImage = systemImage
    }
}

public struct SGFloatingTabBar<ID: Hashable>: View {
    let tabs: [SGTab<ID>]
    @Binding var selection: ID
    var commandShortcuts: Bool
    @Namespace private var pill

    /// `commandShortcuts`: ⌘1…⌘9 select the tabs in order.
    public init(_ tabs: [SGTab<ID>], selection: Binding<ID>, commandShortcuts: Bool = false) {
        self.tabs = tabs
        _selection = selection
        self.commandShortcuts = commandShortcuts
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(tabs.enumerated()), id: \.element.id) { index, tab in item(tab, index: index) }
        }
        .padding(.horizontal, 6)
        .frame(height: SG.Size.tabBar)
        .sgFloatingChrome(in: Capsule())
    }

    private func item(_ tab: SGTab<ID>, index: Int) -> some View {
        let selected = tab.id == selection
        return Button {
            withAnimation(SG.Motion.respecting(SG.Motion.snappy)) { selection = tab.id }
        } label: {
            HStack(spacing: 7) {
                Image(systemName: tab.systemImage)
                    .font(.system(size: SG.Size.glyph, weight: .medium))
                    .frame(width: SG.Size.glyph + 4, height: SG.Size.glyph + 4)
                if selected {
                    Text(tab.title)
                        .font(SG.Font.bodyEmphasis)
                        .lineLimit(1)
                        .fixedSize()
                        .transition(.sgLabelReveal)
                }
            }
            .foregroundStyle(SG.Ink.primary)
            .padding(.horizontal, selected ? 14 : 11)
            .frame(height: SG.Size.tabItem)
            .background {
                if selected {
                    Capsule()
                        .fill(SG.Fill.selectedPill)
                        .overlay(Capsule().strokeBorder(SG.Fill.selectedPillBorder, lineWidth: 1))
                        .matchedGeometryEffect(id: "pill", in: pill)
                }
            }
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .keyboardShortcut(commandShortcuts && index < 9 ? KeyboardShortcut(KeyEquivalent(Character("\(index + 1)")), modifiers: .command) : nil)
        .help(tab.title)
        .accessibilityLabel(tab.title)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

private struct LabelReveal: ViewModifier {
    var progress: CGFloat
    func body(content: Content) -> some View {
        content
            .opacity(progress)
            .blur(radius: (1 - progress) * SG.Motion.labelRevealBlur)
            .offset(x: (1 - progress) * -SG.Motion.labelRevealOffset)
    }
}

public extension AnyTransition {
    /// A label unfurling from, and collapsing back into, the icon beside it.
    static var sgLabelReveal: AnyTransition {
        .modifier(active: LabelReveal(progress: 0), identity: LabelReveal(progress: 1))
    }

    /// Content entering with blur, used for step changes inside a panel.
    static var sgBlurReplace: AnyTransition {
        .modifier(active: BlurFade(radius: 8), identity: BlurFade(radius: 0))
    }
}

private struct BlurFade: ViewModifier {
    var radius: CGFloat
    func body(content: Content) -> some View {
        content.blur(radius: radius).opacity(radius == 0 ? 1 : 0)
    }
}
