// Sguardo: controls for the always-dark island (onboarding, permissions, transient status).

import SwiftUI

/// Island title: 26 bold white, optional detail line under it.
public struct SGIslandTitle: View {
    let title: String
    var detail: String?
    public init(_ title: String, detail: String? = nil) {
        self.title = title
        self.detail = detail
    }
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(SG.Font.title).foregroundStyle(SG.Island.textPrimary)
            if let detail {
                Text(detail).font(SG.Font.bodyEmphasis).foregroundStyle(SG.Island.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Capsule row: status dot, title/detail, trailing grant pill.
public struct SGStatusRow: View {
    let title: String
    let detail: String
    let isOK: Bool
    var actionTitle: (pending: String, done: String)
    let action: () -> Void

    public init(_ title: String, detail: String, isOK: Bool,
                actionTitle: (pending: String, done: String) = ("Grant", "Granted"),
                action: @escaping () -> Void) {
        self.title = title
        self.detail = detail
        self.isOK = isOK
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(isOK ? SG.Status.success : SG.Status.danger)
                .frame(width: SG.Size.statusDot, height: SG.Size.statusDot)
            VStack(alignment: .leading, spacing: 1) {
                Text(title).font(SG.Font.bodyEmphasis).foregroundStyle(SG.Island.textPrimary)
                Text(detail).font(SG.Font.caption).foregroundStyle(SG.Island.textDetail)
                    .lineLimit(1).minimumScaleFactor(0.85)
            }
            Spacer(minLength: 4)
            Button(action: action) {
                Text(isOK ? actionTitle.done : actionTitle.pending)
                    .font(SG.Font.label)
                    .foregroundStyle(SG.Island.textPrimary)
                    .frame(width: 60, height: SG.Size.buttonSmall)
                    .background(SG.Island.surfaceRaised, in: Capsule())
            }
            .buttonStyle(SGPressStyle())
            .disabled(isOK)
            .opacity(isOK ? 0.6 : 1)
        }
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity)
        .frame(height: SG.Size.row)
        .background(SG.Island.surface, in: Capsule())
    }
}

/// Capsule text field for islands. Set `secure` for passwords.
public struct SGIslandField: View {
    let placeholder: String
    @Binding var text: String
    var secure: Bool
    var onSubmit: () -> Void

    public init(_ placeholder: String, text: Binding<String>, secure: Bool = false, onSubmit: @escaping () -> Void = {}) {
        self.placeholder = placeholder
        _text = text
        self.secure = secure
        self.onSubmit = onSubmit
    }

    public var body: some View {
        Group {
            let prompt = Text(placeholder).foregroundStyle(SG.Island.textSecondary.opacity(0.6))
            if secure {
                SecureField("", text: $text, prompt: prompt)
            } else {
                TextField("", text: $text, prompt: prompt)
            }
        }
        .textFieldStyle(.plain)
        .font(SG.Font.field)
        .foregroundStyle(SG.Island.textPrimary)
        .onSubmit(onSubmit)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .frame(height: SG.Size.field)
        .background(SG.Island.surface, in: Capsule())
    }
}

/// Animated stroke checkmark for completion moments.
public struct SGCheckmark: View {
    var size: CGFloat
    @State private var progress: CGFloat = 0
    @Environment(\.sgAccent) private var accent

    public init(size: CGFloat = 44) { self.size = size }

    public var body: some View {
        Path { p in
            p.move(to: CGPoint(x: size * 0.22, y: size * 0.52))
            p.addLine(to: CGPoint(x: size * 0.42, y: size * 0.72))
            p.addLine(to: CGPoint(x: size * 0.78, y: size * 0.30))
        }
        .trim(from: 0, to: progress)
        .stroke(accent.base, style: StrokeStyle(lineWidth: size * 0.1, lineCap: .round, lineJoin: .round))
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeOut(duration: 0.28).delay(0.2)) { progress = 1 }
        }
    }
}
