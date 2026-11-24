# Sguardo design system

A shared visual language for our macOS apps and their websites, derived from Glance (source v1.2 at github.com/jonnyoo/glance, website tryglance.app). Values live in `tokens/tokens.json`; `swift/` and `web/` mirror them.

## 1. What makes the Glance look

Seven traits, in order of impact. Restyling an app means applying these, not copying screens.

1. **Everything you can press is a capsule.** Buttons, fields, pickers, permission rows, tab bar, nav bar. Containers are rounded rects (16pt rows, 13pt tiles, 48 to 60pt islands), always the continuous corner style.
2. **Translucent fills with a 1pt hairline, never solid grey.** Rows sit on `white 8%` (dark) or `white 75%` (light) over the window material, outlined with a 12 to 15% hairline. Light mode goes whiter than the page, not darker.
3. **One accent, used sparingly.** The accent fills the single primary button of a view, the selection ring and its 12% wash, and nothing else. Secondary actions are neutral fills.
4. **Small, quiet type.** System font only. 13pt is body, 12pt semibold labels the controls, 11pt is the caption. One bold 26pt title per panel. No all-caps, no letter-spaced labels.
5. **Springs, not curves.** Selection snaps (0.35 / 0.82), steps and resizes glide (0.42 / 0.80), islands open with a small overshoot (0.45 / 0.70) and close without one (0.45 / 1.0).
6. **Blur as a transition.** Labels unfurl from their icon (opacity + 4pt blur + 10pt slide); headers fade content through a progressive blur; on the web, sections blur in on scroll.
7. **The dark island.** Transient states (onboarding, scanning, success, failure) appear in an always-black panel attached to the notch or floating as a pill, independent of appearance.

## 2. Combining with Liquid Glass

Our apps already follow the HIG rule "glass only on floating controls". Sguardo keeps that rule and fills in everything else.

| Layer | macOS 26+ | macOS 14 to 15 |
|---|---|---|
| Floating chrome (tab bar, bottom action bar, nav pill) | `glassEffect` in a capsule | `.regularMaterial` + `barTint` + `barBorder` hairline (Glance's own recipe) |
| Window background | system (sidebar material) | `.sidebar` NSVisualEffectView |
| Content (rows, groups, tiles) | Sguardo fills + hairline | same |
| Primary button | accent capsule (`glassProminent` tinted with the app accent is acceptable) | accent capsule |
| Transient island | always-black panel, no glass | same |

Never put glass on content, and never stack glass on glass.

## 3. Color

**Accent (per app).** Each app sets one `accent` color; tokens derive the rest:

| Step | Rule | Glance blue |
|---|---|---|
| base | the app's brand color | #3499FF |
| pale | mix 75% white | #CFE7FF |
| bright | mix 40% white | #7FC2FF |
| deep | mix 30% black | #1F6BD1 |
| selected wash | base at 12% | |

Current app accents: What's Going On and knock #33C773, typewithme #2E7DF5, nod #1C9EDB. Each app's accent is only a default: `SGAccentRow` in General settings lets the person keep it, follow the macOS accent color, or pick their own (`.sguardoAccent(default:)` at every root reads that choice).

**Neutrals (adaptive).** Text primary `#EEEEEE` / `black 85%`, secondary `#BFBFBF` / `black 50%`, tertiary `#999999` / `black 40%`. The light values match AppKit's own label colors, so text has native contrast.

**Fills (adaptive).** row, rowBorder, neutralButton, pickerPill, tile, barTint, barBorder, selectedPill. See tokens. Alpha only, so they adapt to whatever is behind them.

**Island (fixed dark).** panel #000, surface #1E1E1E, raised #323232, text white / #BDBDBD / #949494, placeholder #2F2F2F.

**Status.** success #30D158, danger #FF453A, destructive fill #E03B2F, warning #FFBE54. Quality scale poor #FF5454, fair #FFBE54, good #85FF77.

## 4. Typography

App (SF Pro, points):

| Token | Size / weight | Use |
|---|---|---|
| title | 26 bold | one per panel or onboarding step |
| instruction | 15 medium | live guidance under a camera, progress |
| bodyEmphasis | 13 medium | row titles in islands, tab titles, section titles |
| body | 13 regular | settings row titles, menus |
| button | 13 medium | large capsule buttons |
| label | 12 semibold | small buttons, grant pills |
| field | 12 regular | text fields, captions |
| caption | 11 regular | row subtitles, detail lines (max 260pt wide) |
| value | 13 monospaced | slider values, counters |

Web: display `clamp(46px, 5.3vw, 80px)` bold, line-height 1.025, tracking -0.02em. Headlines are **two-tone**: muted words in `mutedInk`, key words in `foreground` ("With the **convenience** and **design** of your **iPhone**").

## 5. Shape, space, size

Radii: control capsule, tile 13, row/group 16, island small 22, island 48, island large 60. Web: buttons 999px, cards `clamp(28px, 4.33vw, 52px)`.

Spacing scale (pt): 4, 6, 8, 10, 12, 14, 16, 24, 28, 32, 40, 60. Content inset 16, row inset 14, row gap 12.

Heights: row 44, large button 38, header button 30, small button 26, field 40, tab bar 54 (item 42), status dot 16.

## 6. Components

| Component | Spec |
|---|---|
| **PillButton** | Capsule, 38pt high, 13 medium white text. Primary = accent; secondary = island surface (in islands) or neutralButton fill (in windows). Disabled at 40% opacity. Return triggers the default one. |
| **SmallButton** | Capsule, 12 semibold, padding 14 x 6. Accent or neutral. |
| **HoldToConfirmButton** | Replaces confirmation dialogs for destructive actions. Neutral capsule that fills left to right with #E03B2F over 3s while held; releases in 0.18s. |
| **Row / Group** | 44pt, 16pt continuous corners, row fill + 1pt hairline. Title 13 regular, subtitle 11 secondary. Groups stack rows with inset dividers. Trailing control: toggle (small switch), picker pill, or small button. |
| **PickerPill** | Capsule with pickerPill fill + hairline, 13 regular text, `chevron.up.chevron.down` 10 semibold. |
| **SectionTitle** | 13 medium, secondary, 10pt leading inset, 8pt vertical padding. |
| **OptionTile** | 13pt rounded preview, tile fill, 4pt soft shadow. Selected: accent ring 3.5pt wide, 2.5pt outside the edge, plus 12% accent wash. Label 12 medium under it. |
| **FloatingTabBar** | Capsule 54pt, glass (26+) or material + tint + border, 14pt above the window bottom. Selected item sits on its own sliding pill and shows its title; others show the glyph only. Label reveal = opacity + 4pt blur + 10pt slide, spring snappy. |
| **Header** | 52pt strip, traffic lights leading, one 30pt capsule action trailing. Content scrolls under a progressive blur (3 stacked materials, 80pt tall). |
| **Island** | Black panel, 380pt wide, 48 to 60pt corners (notch style: inverted top corners flush with the screen). Content insets 28 to 32, title top inset 32 (pill) or 50 (under the notch). Rows inside are surface-filled capsules. |
| **StatusRow** | Island capsule row: 16pt status dot (success/danger), title 13 medium, detail 11, trailing 60x26 grant pill. |
| **EmptyState** | Centered SF Symbol 34pt, 13pt message, primary small button; 12pt gaps. |
| **Checkmark** | Drawn stroke, 0.28s, after 0.2s delay. |

## 7. Motion

| Token | Value | Use |
|---|---|---|
| snappy | spring 0.35 / 0.82 | selection, tabs, toggles |
| standard | spring 0.42 / 0.80 | steps, panel resize, scroll + blur transitions together |
| expand | spring 0.45 / 0.70 | island opens |
| collapse | spring 0.45 / 1.00 | island closes |
| hover | easeOut 0.18 | hover states |
| state | easeInOut 0.28 | crossfade between locked/unlocked or empty/filled |
| fade | 0.35 | overlays in and out |
| web ease | cubic-bezier(.16, 1, .3, 1), 0.9s | scroll reveals, nav |

Rules: animate size and content with the same spring so they move as one; stagger lists by 4 to 8 ms per item (web 50 ms); respect Reduce Motion by replacing springs with 0.2s fades.

## 8. Web patterns (tryglance.app)

- Light page `#FBFDFF`, ink `#071727`; one full-bleed dark section (`#09090A`, cards `#1B1C1D`) for trust, security or privacy.
- **Bottom floating nav**: wordmark pill + a pill group of capsule links (icon + label) + one black "Download" capsule, translucent `#EAEAEABF`, blur 16px.
- Hero: two-tone display headline, short lead in muted ink, black primary capsule + `#EEEEEF` secondary capsule, a micro caption under the CTA ("macOS 15 Sequoia+").
- Feature bento: large `panelMuted` cards with 52px corners, a mix of product shots and short bold statements ("Haptic feedback", "instant unlocks").
- An accent block card (accent fill, white bold text) for the one message that must not be missed.
- Every section reveals with opacity 0 → 1, blur 12px → 0, translateY 20px → 0.

## 9. Do and don't

- Do keep one primary (accent) action per view. Don't color secondary buttons.
- Do use hairlines plus translucency to separate layers. Don't use drop shadows on rows (only tiles get a soft 4pt shadow).
- Do keep copy short and plain, sentence case. Don't use all-caps labels.
- Do use the island for transient, system-level moments. Don't build ordinary settings inside it.
- Do respect Reduce Transparency and Increase Contrast (the system handles glass; our fills should rise to opaque).
