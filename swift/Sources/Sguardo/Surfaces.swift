// Sguardo: surfaces. Glass only on floating chrome; content uses translucent fills plus a hairline.

import AppKit
import SwiftUI

public extension View {
    /// Floating chrome (tab bar, bottom action bar): Liquid Glass on macOS 26,
    /// Glance's material + tint + hairline recipe before that.
    @ViewBuilder
    func sgFloatingChrome<S: InsettableShape>(in shape: S, interactive: Bool = false) -> some View {
        if #available(macOS 26.0, *) {
            self.glassEffect(interactive ? .regular.interactive() : .regular, in: shape)
        } else {
            self
                .background {
                    shape.fill(.regularMaterial)
                    shape.fill(SG.Fill.barTint)
                }
                .overlay(shape.strokeBorder(SG.Fill.barBorder, lineWidth: SG.Stroke.hairline))
        }
    }

    /// Content surface: translucent fill + 1pt hairline, 16pt continuous corners by default.
    func sgRowSurface<S: InsettableShape>(in shape: S) -> some View {
        self
            .background(shape.fill(SG.Fill.row))
            .overlay(shape.strokeBorder(SG.Fill.rowBorder, lineWidth: SG.Stroke.hairline))
            .clipShape(shape)
    }

    func sgRowSurface() -> some View { sgRowSurface(in: .sgRow) }

    /// Standard settings page padding: 16pt sides, room for a floating tab bar at the bottom.
    func sgPagePadding(hasTabBar: Bool = true) -> some View {
        self
            .padding(.horizontal, SG.Space.contentPadding)
            .padding(.bottom, hasTabBar ? SG.Size.pageBottomInset : SG.Space.contentPadding)
    }
}

/// Window background: the sidebar material Glance uses across the whole settings window.
public struct SGWindowBackground: NSViewRepresentable {
    public init() {}
    public func makeNSView(context: Context) -> NSVisualEffectView {
        let v = NSVisualEffectView()
        v.material = .sidebar
        v.blendingMode = .behindWindow
        v.state = .followsWindowActiveState
        return v
    }
    public func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}

/// Header backdrop whose blur fades from strongest at the top edge to none,
/// so scrolled content sharpens as it passes under the header.
public struct SGProgressiveBlur: View {
    var height: CGFloat
    private static let materials: [Material] = [.ultraThinMaterial, .thinMaterial, .regularMaterial]

    public init(height: CGFloat = SG.Size.header + 28) { self.height = height }

    public var body: some View {
        ZStack(alignment: .top) {
            ForEach(Array(Self.materials.enumerated()), id: \.offset) { index, material in
                let fadeEnd = 1 - CGFloat(index) / CGFloat(Self.materials.count)
                Rectangle()
                    .fill(material)
                    .mask(LinearGradient(stops: [.init(color: .black, location: 0),
                                                 .init(color: .clear, location: fadeEnd)],
                                         startPoint: .top, endPoint: .bottom))
            }
        }
        .frame(height: height)
        .allowsHitTesting(false)
    }
}

/// Always-dark transient panel (onboarding steps, scanning, success, failure).
/// Use `cornerRadius` 48 for floating pills, 60 for large notch-attached panels.
public struct SGIsland<Content: View>: View {
    var width: CGFloat
    var cornerRadius: CGFloat
    var content: Content

    public init(width: CGFloat = SG.Size.panelWidth,
                cornerRadius: CGFloat = SG.Radius.island,
                @ViewBuilder content: () -> Content) {
        self.width = width
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    public var body: some View {
        content
            .padding(.horizontal, 30)
            .padding(.top, 32)
            .padding(.bottom, 36)
            .frame(width: width)
            .background(SG.Island.panel, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .environment(\.colorScheme, .dark)
            .shadow(color: .black.opacity(0.25), radius: 24, y: 8)
    }
}
