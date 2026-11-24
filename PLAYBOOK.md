# Restyling an app with Sguardo

What we learned moving What's Going On to Sguardo (0.7.5), as a checklist for the next app. Read `DESIGN.md` first; this
file is the how, that one is the what. What's Going On (github.com/GGuidotz/whats-going-on, commit 0b84cac and the
accent commit after it) is the reference implementation: when unsure, look at how it did it.

## 0. Before touching anything

- Read the app's `CLAUDE.md`, `README.md`, `build.sh` and its `Style.swift` (or `Theme.swift`). They hold rules that win
  over this file: language of the UI and comments, `L("…")` localization with a strings checker, CHANGELOG format,
  `Sources/Core` free of SwiftUI, what may be shared with Cocaine.
- `git status`: uncommitted changes belong to the person. Never stage, stash, revert or reformat them. Stage only files
  you changed (`git add <paths>`), never `git add -A`. If a file you must change already has uncommitted changes, stop
  and report instead of mixing your edits into theirs.
- Work on a new branch `design/sguardo` from the current branch. Never touch `main` directly, never push.
- Inventory the UI: every window, popover, panel and settings page; every use of `glassButton`, `glassProminentButton`,
  `glassSurface`, `contentCard`, `Form`, `.formStyle`, `accentColor`, `.tint(`. That list is the work.

## 1. Wire Sguardo in (submodule)

```bash
git submodule add https://github.com/GGuidotz/sguardo.git Vendor/Sguardo
```

In `build.sh`, right after `SOURCES=(…)`:

```zsh
# Sguardo, il sistema di design comune: submodule in Vendor/Sguardo, compilato con l'app (un modulo, niente import).
# Per provare modifiche al kit senza aggiornare il submodule: SGUARDO_DIR=~/Developer/design-system ./build.sh
SGUARDO="${SGUARDO_DIR:-Vendor/Sguardo}/swift/Sources/Sguardo"
[ -d "$SGUARDO" ] || { echo "Manca Sguardo: git submodule update --init" >&2; exit 1; }
SOURCES+=("$SGUARDO"/*.swift)
```

Add to the README's build section: clone with `git clone --recursive`, or run `git submodule update --init`.
If the app is built by Xcode or SPM instead, add `Vendor/Sguardo/swift` as a local package and `import Sguardo`.

## 2. Accent

- Define the app's default in its `Style.swift`: `extension SG.Accent { static let <app> = SG.Accent(hex: 0x…) }`.
  Use the app's existing brand color (`Palette`, `Theme`). If it has none, take the dominant color of the app icon
  (read `Resources/Icon` or the `.icns`), and say in the report which color and why.
- Apply it at every root view (panel, popover, settings, onboarding, what's new, tools, any extra window) with
  `.sguardoAccent(default: .<app>)`, so the person's choice wins.
- Add `SGAccentRow` to the General settings page, with localized words: title "Colore d'accento", options
  "Colore dell'app" / "Colore di sistema" / "Personalizzato" (and their English entries in Localizable.strings).
- White text on a light accent can fall below 4.5:1 (green is about 2.3:1). Mention it in the report; do not change the
  brand color on your own.

## 3. Style.swift

- Keep `Palette` (brand and semantic colors). Add a header comment that shapes, fills and motion come from Sguardo.
- `contentCard(...)`: keep the signature so call sites do not change; implement it with `sgRowSurface(in:)`, default
  radius `SG.Radius.row`, plus a solid border when Increase Contrast is on.
- `glassSurface(in:)`: forward to `sgFloatingChrome(in:)` (needs an `InsettableShape`).
- Rename the glass button helpers to `floatingGlassButton()` / `floatingGlassProminentButton()` and use them only on
  floating chrome (bottom bars of popovers). Everywhere else, content buttons become `.buttonStyle(.sgSecondary)`,
  primaries `.buttonStyle(.sgPrimary)`, destructive ones (uninstall, delete, move to Trash) `.buttonStyle(.sgDestructive)`.
  A scripted replace across the app works; check each primary and destructive by hand.

## 4. Settings windows

- Replace `Form { Section { … } header: footer: }.formStyle(.grouped)` with
  `SGPage { SGSection(header) { rows separated by SGDivider() } footer: { SGFootnote(…) } }`.
- Rows: `SGToggleRow`, `SGMenuRow(title, selection:, options: [(value:, title:)])` (build options with labeled tuples:
  `.map { (value: $0, title: $0.title) }`), `SGValueRow`, `SGLabeledRow { leading } trailing: { control }` for anything
  custom, `SGRowBlock { … }` for segmented pickers, previews, wrapped text and button rows. Buttons in rows use
  `.buttonStyle(.sgSecondary)`.
- Tab bar: `SGFloatingTabBar(tabs, selection:, commandShortcuts: true)` floating at the bottom in a
  `ZStack(alignment: .bottom)` with `.padding(.bottom, SG.Size.tabBarBottomInset)`; `SGPage` leaves room for it.
  Keep the existing ⌘1… shortcuts (that is what `commandShortcuts` does).
- Window with a transparent title bar and full-size content: put `.ignoresSafeArea()` on the root after `.frame`,
  otherwise the title-bar safe area pushes everything down and the bottom tab bar sits on (or past) the bottom edge.
  `SGPage` already leaves `SG.Size.header` (52pt) at the top for the traffic lights; add `SGProgressiveBlur()` as a
  top overlay so content fades under them.
- Keep every string, binding and side effect exactly as it was. The rewrite is layout only.

## 5. Panels, onboarding, what's new, tools

- Popovers: system glass is the floating chrome; cards use `contentCard`; the bottom bar keeps floating glass buttons.
- Onboarding and what's new: titles `SG.Font.title` (26 bold, no rounded design), lead text `SG.Font.instruction` in
  `SG.Ink.secondary`, footer buttons `SGCapsuleButtonStyle(.primary / .secondary, size: .large)` keeping their
  `.keyboardShortcut(.defaultAction / .cancelAction)`. Step changes on `SG.Motion.standard` with `.sgBlurReplace`
  (plain fade under Reduce Motion).
- Other tab bars (tools windows): `SGFloatingTabBar` too.
- Disclosure and selection animations: `SG.Motion.snappy`.
- Do not move onboarding into a notch island or otherwise restructure navigation without asking.

## 6. Words

- No new user-visible string without its English entry; run the app's strings checker (for example
  `python3 -I tools/check-strings.py`) until it reports 0 problems.
- Sguardo itself never hardcodes visible words: pass localized titles, hints and options from the app.

## 7. Build and check

- Compile outside the Claude Code sandbox (SwiftUI macros need the plugin server): `./build.sh`. Zero errors, no new
  warnings.
- Render the main screens with the snapshot harness (`tools/snapshot/README.md`), light and dark, and look at every PNG:
  clipped or wrapping values (give monospaced values `.lineLimit(1).fixedSize()`), menus that lost their capsule, rows
  that touch edges, tab bars that overlap content.
- Do not run `./build.sh --install` and do not quit the person's running copy: they try it themselves.

## 8. Version and commit

- Bump the patch version (`VERSION`) and add `## <version> · <date>` on top of `CHANGELOG.md` and `CHANGELOG.en.md` in
  the app's own format, with a short summary line and `### Miglioramenti` / `### Improvements` bullets that describe
  what the person sees (not the code).
- Update the app's `CLAUDE.md` design rule to say the UI uses Sguardo (submodule, accent name, components, glass only
  on floating chrome).
- One commit on `design/sguardo` with the app's commit style, ending with the co-author line. No merge, no push.

## 9. Report

What changed by screen, the accent and why, anything left unconverted and why, the snapshot paths, warnings
(contrast, shared code with Cocaine, uncommitted files you left alone), and the commit hash.
