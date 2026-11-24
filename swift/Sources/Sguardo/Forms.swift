// Sguardo: settings pages. A drop-in replacement for `Form { Section { … } header: footer: }.formStyle(.grouped)`:
// SGPage { SGSection(header) { rows separated by SGDivider() } footer: { SGFootnote(…) } }.

import SwiftUI

/// Scrolling settings page: 16pt sides, 12pt between sections, room above for a transparent title bar
/// and below for a floating tab bar.
public struct SGPage<Content: View>: View {
    var topInset: CGFloat
    var hasTabBar: Bool
    let content: Content

    public init(topInset: CGFloat = SG.Size.header, hasTabBar: Bool = true, @ViewBuilder content: () -> Content) {
        self.topInset = topInset
        self.hasTabBar = hasTabBar
        self.content = content()
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) { content }
                .padding(.top, topInset)
                .sgPagePadding(hasTabBar: hasTabBar)
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollContentBackground(.hidden)
    }
}

/// Section title + one group of rows + optional footnote.
public struct SGSection<Content: View, Footer: View>: View {
    var header: String?
    let content: Content
    let footer: Footer

    public init(_ header: String? = nil, @ViewBuilder content: () -> Content, @ViewBuilder footer: () -> Footer) {
        self.header = header
        self.content = content()
        self.footer = footer()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let header { SGSectionTitle(header).accessibilityAddTraits(.isHeader) }
            SGGroup { content }
            footer
                .padding(.horizontal, SG.Space.sectionTitleInset)
                .padding(.top, 6)
        }
    }
}

public extension SGSection where Footer == EmptyView {
    init(_ header: String? = nil, @ViewBuilder content: () -> Content) {
        self.init(header, content: content, footer: { EmptyView() })
    }
}

/// Explanatory text under a group: 11pt, secondary, wraps.
public struct SGFootnote: View {
    let text: String
    public init(_ text: String) { self.text = text }
    public var body: some View {
        Text(text)
            .font(SG.Font.caption)
            .foregroundStyle(SG.Ink.secondary)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// A row with any leading content (title, `Label`, preview) and any trailing control.
public struct SGLabeledRow<Leading: View, Trailing: View>: View {
    let leading: Leading
    let trailing: Trailing

    public init(@ViewBuilder leading: () -> Leading, @ViewBuilder trailing: () -> Trailing) {
        self.leading = leading()
        self.trailing = trailing()
    }

    public var body: some View {
        HStack(spacing: SG.Space.m) {
            leading
                .font(SG.Font.body)
                .foregroundStyle(SG.Ink.primary)
            Spacer(minLength: SG.Space.s)
            trailing
        }
        .padding(.horizontal, SG.Space.rowInset)
        .padding(.vertical, 6)
        .frame(minHeight: SG.Size.row)
    }
}

/// Free-form row content (segmented pickers, sliders, previews, wrapped text), padded like a row.
public struct SGRowBlock<Content: View>: View {
    let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }
    public var body: some View {
        content
            .font(SG.Font.body)
            .foregroundStyle(SG.Ink.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, SG.Space.rowInset)
            .padding(.vertical, 10)
            .frame(minHeight: SG.Size.row)
    }
}

/// Title (+ subtitle) with a trailing switch.
public struct SGToggleRow: View {
    let title: String
    var subtitle: String?
    @Binding var isOn: Bool

    public init(_ title: String, subtitle: String? = nil, isOn: Binding<Bool>) {
        self.title = title
        self.subtitle = subtitle
        _isOn = isOn
    }

    public var body: some View {
        SGRowContent(title, subtitle: subtitle) { SGToggle(isOn: $isOn).accessibilityLabel(title) }
    }
}

/// Title with a trailing picker pill; the menu shows a checkmark on the current option.
public struct SGMenuRow<Value: Hashable>: View {
    let title: String
    var subtitle: String?
    @Binding var selection: Value
    let options: [(value: Value, title: String)]

    public init(_ title: String, subtitle: String? = nil, selection: Binding<Value>,
                options: [(value: Value, title: String)]) {
        self.title = title
        self.subtitle = subtitle
        _selection = selection
        self.options = options
    }

    public var body: some View {
        SGRowContent(title, subtitle: subtitle) {
            SGPickerPill(options.first { $0.value == selection }?.title ?? "–") {
                Picker(title, selection: $selection) {
                    ForEach(options.indices, id: \.self) { i in
                        Text(options[i].title).tag(options[i].value)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }
            .accessibilityLabel(title)
        }
    }
}

/// Title with a read-only trailing value (tabular digits).
public struct SGValueRow<Value: View>: View {
    let title: String
    let value: Value

    public init(_ title: String, @ViewBuilder value: () -> Value) {
        self.title = title
        self.value = value()
    }

    public var body: some View {
        SGLabeledRow {
            Text(title)
        } trailing: {
            value
                .font(SG.Font.body)
                .foregroundStyle(SG.Ink.secondary)
                .monospacedDigit()
                .multilineTextAlignment(.trailing)
        }
        .accessibilityElement(children: .combine)
    }
}

public extension SGValueRow where Value == Text {
    init(_ title: String, value: String) {
        self.init(title) { Text(value) }
    }
}
