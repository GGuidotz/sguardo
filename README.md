# Sguardo

Shared design system for our macOS apps and their websites, derived from Glance (github.com/jonnyoo/glance v1.2,
tryglance.app). Each app keeps its own accent, which the person can change in the app's settings; shapes, type, fills
and motion are shared.

| Path | What |
|---|---|
| `DESIGN.md` | The spec: principles, tokens, components, motion, web patterns, do and don't |
| `PLAYBOOK.md` | How to move an app to Sguardo, step by step (what we learned on What's Going On) |
| `tokens/tokens.json` | Source of truth for every value |
| `swift/Sources/Sguardo/` | SwiftUI tokens and components (`SG.*`, `SGPage`, `SGSection`, `SGFloatingTabBar`, `SGIsland`, ...) |
| `web/` | `sguardo.css`, `sguardo.js`, `template.html` landing page |
| `tools/snapshot/` | Harness that renders an app's screens to PNG, light and dark |
| `skill/sguardo-design/` | Claude skill that applies the system when restyling an app |

Visual reference: https://claude.ai/artifact/8UmTuEvoEcacjfkr4cCfhr

## Use in an app

Add it as a submodule, so whoever clones the app gets the exact version it was built with:

```bash
git submodule add https://github.com/GGuidotz/sguardo.git Vendor/Sguardo
```

Our apps build with `swiftc`, so `build.sh` adds the sources (see `PLAYBOOK.md` for the exact lines):

```zsh
SOURCES+=( Vendor/Sguardo/swift/Sources/Sguardo/*.swift )
```

Then set the default accent at each root view; the person can switch to the macOS accent or their own color with
`SGAccentRow` in Settings:

```swift
SettingsView().sguardoAccent(default: .knock)
```

Cloning an app that uses it: `git clone --recursive …`, or `git submodule update --init` after a plain clone.
To update an app to the latest Sguardo: `git -C Vendor/Sguardo pull` and commit the new submodule pointer.
`swift/Package.swift` also exposes it as an SPM library for Xcode projects.

## Install the skill

```bash
mkdir -p ~/.claude/skills && cp -R skill/sguardo-design ~/.claude/skills/
```

## License

MIT. Sguardo's values are derived from Glance by Jonathan Zhou (MIT).
