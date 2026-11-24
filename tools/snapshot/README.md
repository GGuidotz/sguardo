# Snapshot harness

Renders an app's screens to PNG (light and dark) so a restyle can be checked without quitting the copy the person has
open. It is a check of layout, type, fills and spacing. Two known limits: switches look grey and unselected (an
offscreen window is never key, so AppKit draws controls inactive) and materials render flat. Judge those in the real app.

1. Copy `Harness.example.swift` to a scratch folder (never inside the app repo) and replace the screens with the app's
   root views. Do not call launch hooks that write the person's real data (history files, prefs, notifications).
2. Compile the app's sources except its `@main` file, plus Sguardo and the harness:

   ```bash
   SRC=($(ls Sources/**/*.swift | grep -v "App/Main.swift"))
   swiftc -swift-version 5 -parse-as-library -target arm64-apple-macos14.0 "${SRC[@]}" \
     Vendor/Sguardo/swift/Sources/Sguardo/*.swift "$H/Harness.swift" -o "$H/H.app/Contents/MacOS/harness"
   ```

   SwiftUI macros need the Swift plugin server, which the Claude Code sandbox blocks: compile outside it.
3. Wrap it in a bundle with its own identifier (`local.sguardo.harness`) and an `Info.plist` with `LSUIElement`;
   frameworks such as UserNotifications crash without a bundle. `codesign -s - --force H.app`.
4. Run it with `HOME` pointed at a scratch folder, inside the sandbox, so it cannot touch the person's files:
   `HOME="$H/home" ./H.app/Contents/MacOS/harness "$H/out"`.
5. Read the PNGs. Views that size themselves from scroll preferences or safe-area bars (a popover with a floating
   bottom bar) can come out blank: render their inner content view instead.
