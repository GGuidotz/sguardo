// Snapshot harness: renders an app's SwiftUI screens to PNG, light and dark, without quitting the installed copy.
// Example from What's Going On. Copy it next to (not inside) the app, replace the screens in the loop with the app's own,
// and follow README.md in this folder to build and run it.
import AppKit
import SwiftUI

@main
enum Harness {
    static func main() {
        MainActor.assumeIsolated {
            let app = NSApplication.shared
            app.setActivationPolicy(.accessory)
            let out = CommandLine.arguments[1]
            let model = AppModel.shared
            model.monitor.isPanelOpen = true
            RunLoop.main.run(until: Date().addingTimeInterval(4))
            func shot<V: View>(_ name: String, _ view: V, size: CGSize, dark: Bool) {
                let root = ZStack {
                    Color(nsColor: dark ? NSColor(white: 0.17, alpha: 1) : NSColor(white: 0.93, alpha: 1))
                    view
                }
                .frame(width: size.width, height: size.height)
                .environment(\.colorScheme, dark ? .dark : .light)
                let host = NSHostingView(rootView: root)
                host.appearance = NSAppearance(named: dark ? .darkAqua : .aqua)
                host.frame = NSRect(origin: .zero, size: size)
                let win = NSWindow(contentRect: host.frame, styleMask: [.borderless], backing: .buffered, defer: false)
                win.appearance = host.appearance
                win.contentView = host
                win.orderFrontRegardless()
                host.layoutSubtreeIfNeeded()
                RunLoop.main.run(until: Date().addingTimeInterval(0.6))
                guard let rep = host.bitmapImageRepForCachingDisplay(in: host.bounds) else { return }
                host.cacheDisplay(in: host.bounds, to: rep)
                try? rep.representation(using: .png, properties: [:])?.write(to: URL(fileURLWithPath: "\(out)/\(name)-\(dark ? "dark" : "light").png"))
                win.orderOut(nil)
            }
            for dark in [false, true] {
                for tab in SettingsTab.allCases {
                    model.settingsTab = tab
                    shot("settings-\(tab.rawValue)", SettingsView(model: model), size: SettingsView.size, dark: dark)
                }
                shot("panel", SystemPanel(monitor: model.monitor, advanced: false,
                                          tools: PanelTools(space: {}, memory: {}, cpu: {}),
                                          belowSummary: AnyView(Button { } label: { Label(L("Perché è lento?"), systemImage: "stethoscope") }.buttonStyle(.sgSecondary)))
                        .padding(12).frame(width: 360).sguardoAccent(.whatsGoingOn), size: CGSize(width: 360, height: 720), dark: dark)
                shot("onboarding", OnboardingView(model: model, prefs: model.prefs, monitor: model.monitor, finish: {}), size: OnboardingView.size, dark: dark)
            }
            exit(0)
        }
    }
}
