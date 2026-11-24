---
name: sguardo-design
description: Apply the Sguardo design system (Glance-style capsules, translucent rows, springs, dark island) when building or restyling Giulio's macOS menu-bar apps (typewithme, knock, tivu, magictouch, nod, smartmemo, whats-going-on) or their websites. Use for "restyle", "update the graphics", "apply the design system", new settings windows, onboarding, landing or download pages.
---

# Sguardo: restyling an app or site

The system lives in `~/Developer/design-system` (GitHub: GGuidotz/sguardo; in each app as the submodule `Vendor/Sguardo`). Read `DESIGN.md` first, then follow `PLAYBOOK.md` step by step when moving an app: it holds every lesson from the first migration (What's Going On 0.7.5). `tokens/tokens.json` is the source of truth. Never invent values: take them from the tokens or the Swift/CSS kit.

## Swift apps (SwiftUI, built with swiftc)

1. **Wire it in.** `git submodule add https://github.com/GGuidotz/sguardo.git Vendor/Sguardo`, then add `Vendor/Sguardo/swift/Sources/Sguardo/*.swift` to `SOURCES` in `build.sh` (exact lines in PLAYBOOK.md). Never copy the files. No `import` is needed since swiftc compiles one module. Liquid Glass is behind `#available(macOS 26.0, *)` inside the kit. SwiftUI macros need the plugin server: compile outside the Claude Code sandbox.
2. **Set the accent** at each window/panel root with `.sguardoAccent(default: .<app>)` and add `SGAccentRow` to General settings, so the person can keep the app color, follow the system accent or pick one. Use the app's brand color; if it has none, the icon's dominant color.
3. **Reconcile Style.swift.** Each app has a `Style.swift` with `Palette`, `glassSurface`, `glassButton`, `contentCard`. Keep `Palette` brand colors (they feed the accent). Replace `contentCard` uses with `SGGroup`/`sgRowSurface()`, `glassProminentButton` primaries with `SGPillButton`/`SGSmallButton`, and keep `glassSurface` only on floating chrome (or swap for `sgFloatingChrome(in:)`). Delete helpers only once nothing references them.
4. **Map screens to components.**
   - Settings window: `SGWindowBackground` + 500x620 window, `SGFloatingTabBar` at the bottom, pages as `ScrollView { VStack(spacing: 12) { SGSectionTitle; SGGroup { SGRowContent …; SGDivider() } } .sgPagePadding() }`, header overlaid with `SGProgressiveBlur`.
   - Toggles: `SGToggle`. Menus: `SGPickerPill`. Visual choices: `SGOptionTile`. Destructive: `SGHoldToConfirmButton`. Empty/locked: `SGEmptyState`.
   - Onboarding, permissions, transient status near the notch or menu bar: `SGIsland` with `SGIslandTitle`, `SGStatusRow`, `SGIslandField`, `SGPillButton`, `SGCheckmark`.
   - Menu-bar popovers: system popover glass is the floating chrome; content inside uses `SGGroup` rows.
5. **Motion.** Use `SG.Motion.snappy` for selection, `.standard` for step and size changes (animate size and content together), `.expand`/`.collapse` for islands, wrapped in `SG.Motion.respecting(_:)`.
6. **Check.** Build, run, compare light and dark, Reduce Transparency, Increase Contrast and Reduce Motion. One accent button per view. No shadows on rows. Sentence case, no emoji.

## Websites

Copy `web/sguardo.css`, `web/sguardo.js` and start from `web/template.html`. Set `:root { --accent: … }` to the app accent. Keep: two-tone headlines (`.m` for muted words), black Download capsule + `#EEEEEF` secondary, bento cards with 52px corners, one dark section for privacy/security, the floating bottom nav, blur-in reveals.

## Rules that matter most

- Everything pressable is a capsule; containers use continuous corners (13 tile, 16 row, 48/60 island).
- Translucent fills + 1px hairline, never solid grey; light-mode rows are whiter than the window.
- One accent, used for the primary action, selection and switches only.
- System font, 13pt body, 12pt semibold labels, 11pt captions, one 26pt bold title per panel.
- Glass only on floating chrome; never on content, never glass on glass.

Ask the user before changing an app's brand color, removing features, or restructuring navigation; restyling alone does not need approval.
