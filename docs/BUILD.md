# Omramo — Build and run (Milestone 1)

**Status: code complete, unverified.** Everything in this milestone was written on a Linux box
with no Swift toolchain and no Xcode. **No Swift file here has ever been compiled or run.**
The JSON content and the Python tools *were* run and pass. The first build on a Mac will
surface compile errors; §8 lists where to expect them and §7 is the checklist to work through.

Reads with: `docs/IMPLEMENTATION_PLAN.md` (M1 scope and acceptance criteria),
`docs/ARCHITECTURE.md`, `docs/DESIGN.md`.

---

## 1. What you need

| Tool | Version | Notes |
|---|---|---|
| macOS | Whatever your Xcode needs | |
| Xcode | **16.0 or later** (iOS 18 SDK, Swift 6 toolchain) | The app's minimum iOS is 18.0 (`TextRenderer`). Which Xcode is on the build Mac is PRD Q16 — **record the version here once known: TBD** |
| XcodeGen | 2.38.0 or later | `brew install xcodegen`. **Record the version you used here: TBD** |
| Python 3 | 3.8 or later, standard library only | For the content check. Already on macOS with the Xcode command-line tools |

There are no third-party dependencies and nothing to resolve. No Apple developer account is
needed to run in the simulator.

## 2. Quick start

```sh
git clone <this repo> && cd <repo>

# 1. Core package tests (pure Swift, no simulator needed)
swift test --package-path Packages/OmramoCore

# 2. Content check (same rules as the Swift validator)
python3 tools/validate_content.py
python3 tools/test_validate_content.py

# 3. Generate the Xcode project and open it
brew install xcodegen          # once
xcodegen generate              # writes Omramo.xcodeproj (git-ignored; never commit it)
open Omramo.xcodeproj
```

In Xcode: choose the **Omramo** scheme and an **iPhone simulator running iOS 18 or later**,
then Run (⌘R). Run the tests with ⌘U (app tests plus the core package tests).

Command line, if you prefer:

```sh
xcodebuild -project Omramo.xcodeproj -scheme Omramo \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max' build
xcodebuild -project Omramo.xcodeproj -scheme Omramo \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max' test
```

(Use any simulator name that `xcrun simctl list devices` shows on your Mac.)

`Omramo.xcodeproj` is generated. If you change `project.yml`, add or remove a file, or pull,
run `xcodegen generate` again. Never edit the project in Xcode's project editor: the change
would be lost.

## 3. Running the core tests

```sh
swift test --package-path Packages/OmramoCore
```

`OmramoCore` imports Foundation only, so this also works on Linux with a Swift 5.9+ toolchain
(for example `docker run --rm -v "$PWD":/src -w /src swift:6.0 swift test --package-path Packages/OmramoCore`).
The tests read the bundled sample content from the package's own resource bundle, and
`Configuration/Brand.xcconfig` from the repository (skipped if the package is checked out
alone).

The package's tools version is 5.9 with strict-concurrency checking on. To build it in Swift 6
language mode (the target in `docs/ARCHITECTURE.md` §2), change the first line of
`Packages/OmramoCore/Package.swift` to `// swift-tools-version: 6.0` and remove the two
`swiftSettings` entries. Do this after the first green test run, not before.

## 4. Which simulator, and simulated Duo

The real Duo SDK is unknown (PRD Q4), so the app lays itself out from its own `PaneLayout`
abstraction (`docs/ARCHITECTURE.md` §5):

| How you run | What you get |
|---|---|
| Any iPhone simulator, portrait, no launch argument | **Folded** layout: one pane. This is the normal-iPhone fallback |
| Launch argument `-OmramoPosture unfolded` (Debug builds only) | The **reference Duo canvas**: two 432 × 720 pt panes and a black 28 pt hinge band, scaled to fit the window. This is what to compare with `docs/design/02-library-home.png` and `03-read-low.png` |
| Launch argument `-OmramoPosture folded` (Debug only) | One 432 × 720 pt reference pane, scaled to fit (compare with `10-folded.png`; M1's folded layout is basic) |
| A window at least 748 pt wide, at least 600 pt tall and wider than tall, no argument | Two panes with a 28 pt virtual gutter (rule 4 of the resolver, plus a minimum height added in M1). No current iPhone qualifies; an ordinary iPhone in landscape stays single-pane, which is allowed only so the simulated canvas can be viewed — it is not a designed layout |

To set the argument: **Product ▸ Scheme ▸ Edit Scheme… ▸ Run ▸ Arguments**. Both arguments are
already listed there (unticked); tick one. For `unfolded`, **rotate the simulator to
landscape** (⌘→) and pick the largest iPhone you have (iPhone 16 Pro Max: 956 × 440 pt, so the
canvas is drawn at about 0.61 scale). Everything scales with the pane, so proportions match the
screenshots even though the picture is small.

The app target is iPhone-only (`TARGETED_DEVICE_FAMILY = 1`, assumption A7). An iPad simulator
would show the canvas larger; that needs the device family changed to `1,2`, which is an open
question (PRD Q1), so it is not done here.

From the command line:

```sh
xcrun simctl launch booted com.omramo.app -OmramoPosture unfolded
```

## 5. Content

| Path | What |
|---|---|
| `Packages/OmramoCore/Sources/OmramoCore/Resources/Content/catalog.json` | Ordered story ids |
| `…/Content/stories/monkey-and-crocodile/story.json` | The sample story: Low tier, 14 pages in two parts, with `region`, `setting`, `provenance`, `culturalReview`, `education` |
| `…/Content/sources/monkey-and-crocodile.txt` | The manuscript the story text is checked against |
| `…/Content/landmarks/landmarks.json` | Landmark catalog: `taj-mahal` (referenced by the story) and `lighthouse-of-alexandria` (a lost wonder, to exercise the reconstruction rule) |
| `…/Content/ART_PLACEHOLDERS.md` | Every image the JSON names, its size and what it should show. **None of the image files exist yet** |

Check it:

```sh
python3 tools/validate_content.py                 # development: exit 0, pending reviews are warnings
python3 tools/validate_content.py --release       # exits 1 today: reviews are pending (expected)
python3 tools/validate_content.py --check-art     # also lists the image files not delivered yet
python3 tools/test_validate_content.py            # 46 tests: every invalid fixture is rejected
```

`tools/validate_content.py` mirrors `StoryValidator` in the core rule for rule, with the same
rule codes (a test compares the two lists). If they ever disagree, the Swift validator wins.

**The story text is our own retelling**, written for this milestone, of the traditional Jataka
tale. It is draft copy: text review and the required cultural review (a Buddhist reader) are
both `pending`, and all card, lesson and fact-card wording is unreviewed. The cited edition
(Babbitt 1912, Gutenberg #62514) is the documented source of the tale, not the app's wording.

### Placeholder art

No illustrations ship in M1. `App/Sources/Art/PlaceholderArt.swift` draws simple shapes and
gradients, chosen by each art reference's asset name. To use a real picture, add the file at
the path the JSON names (see `ART_PLACEHOLDERS.md`); the app loads it instead of the
placeholder, with no code change. Search the code for `TODO(art)`.

## 6. What is implemented, and what is stubbed

### Implemented in M1

- **Project:** `project.yml` (XcodeGen), `Configuration/*.xcconfig`, `Info.plist` with
  `UIAppFonts`, an empty-collection privacy manifest, no remote packages, no signing team.
- **`OmramoCore`** (Foundation only): the content model (schema version 1) with tiers, spreads,
  text runs, tap-to-see targets, character cards, art references, `region`, `provenance`,
  `culturalReview`, `education`, and the `Landmark` catalog with per-tier fact cards and
  `framingDevice`; decoder with schema-version check and readable errors; validator (identity,
  references, art, colours, region, provenance, reviews, education, landmark and anachronism
  rules, text fidelity); `ContentRepository`; library model and level filter; `PaneLayout` and
  its resolver; `Pager`, `ReadingPosition`, page-dash rule; design tokens and the tier type
  scale as data; `Brand` and `FoldMark`; `LandmarkCardContent` (data for the M3 card).
- **App:** design-system wrappers (colours, variable-axis fonts, glass, chips, tier glyph, page
  dashes, round glass button, round page-turn button, primary button, card, aurora backdrop,
  SVG icons ported from the design source); font registration; `PaneLayoutReader` / `TwoPane`
  with the derived (normal iPhone) and simulated-Duo providers; **Library** (wordmark, Keep
  reading, level filter, story cards, tab bar, story map with real pins); **Reading, Low**
  (continuous scene across both panes and the hinge, lead sentence, voices with face chips,
  name underline, tap-word highlight with underline and spark, sound word, stretched word,
  crumb, tier and origin chips, page chip, page-turn button through all 14 pages, back to the
  library, position saved and restored).
- **Tools:** `tools/validate_content.py`, `tools/test_validate_content.py`.

### Stubbed — marked `TODO(Mx)` in the code

| What | Where | Lands in |
|---|---|---|
| Tap-to-see words and character names are drawn but **not tappable**; no cards | `Text/StoryText.swift` | M3 |
| Landmark card (data and validation are done; nothing on screen) | `LandmarkCardContent` in the core | M3 |
| "Aa" + bookmark capsule is drawn but does nothing | `ReaderScreen.swift` | M2 |
| No way to go back one page (none is designed) | — | M2 |
| Overflow: no continuation screens. Unfolded pages are authored short enough to fit; **folded text scrolls** as an interim | `ReaderFoldedPane` | M2 |
| Folded reading is the basic "picture on top, text below" layout, not screen 10 | `ReaderFoldedPane` | M2 |
| Last page: the button shows a tick and returns to the library (no finished moment) | `NextPageButton` | M6 (gap G3) |
| Sample gate, end-of-sample card, paywall, StoreKit: **all 14 pages are readable** | `ReaderModel.turnPage` | M5 |
| Library: streak chip and card, shelf card, friends row, finished ticks | `LibraryScreen.swift` | M4 |
| "My shelf" and "Grown-ups" tabs are drawn but inert; no grown-up gate, no parent view | `LibraryTabBar` | M4 |
| Map legend says "Read", but read state does not exist yet | `StoryMapCard.swift` | M4 |
| Splash, motion, haptics, Reduce Motion, aurora grain, loading and error designs, app icon | several | M6 |
| Duo SDK adapter | `Layout/PaneLayoutProvider.swift` | M7 |
| Real illustrations | `Art/PlaceholderArt.swift` | C1 |

### Deviations from `docs/IMPLEMENTATION_PLAN.md` M1 (deliberate)

1. **The story text is a fresh Omramo retelling, not the unaltered 1912 Babbitt text.** The M1
   brief asked for our own child-friendly retelling; this follows `docs/CONTENT_PLAN.md` §1.2
   and PRD A12. So `provenance.textBasis` is `omramoRetelling`, the manuscript in `sources/` is
   our text, and page 1 does **not** read word for word like `03-read-low.png` (criterion 1.13
   can be met for layout and type, not for the lead sentence's exact line breaks). Decision
   needed: PRD Q22.
2. **Content is a resource of the `OmramoCore` package**, not a top-level `Content/` folder
   reference in the app target. One copy serves `swift test` on Linux and the app; the app gets
   it through the package's resource bundle (`BundledContent`).
3. **No placeholder image files and no `tools/render_placeholder_art.py`.** Placeholders are
   drawn in SwiftUI instead, so the validator cannot check pixel sizes yet; a missing image
   file is reported only with `--check-art`.
4. **Invalid fixtures are made in memory** by breaking one thing in the valid sample (in both
   the Swift tests and the Python tests) rather than kept as fixture files.
5. **Folded text scrolls** (interim; see the table above).
6. Type names: `ContentDecoder` (the plan's `StoryDecoder`, since it also decodes the catalog
   and landmarks) and `StoryCharacter` (the plan's `Character`, which would shadow
   `Swift.Character`).
7. Plan deviations already allowed at M1: placeholder art; right-pane library cards incomplete;
   word spacing not applied; no animations.

## 7. First-compile checklist

Work through these in order; each depends on the one before.

1. `swift test --package-path Packages/OmramoCore` — fix compile errors in the core first.
   Everything else depends on it, and it is the fastest loop. Expect all tests to pass.
2. `xcodegen generate` — if it rejects the scheme's `package: OmramoCore/OmramoCoreTests` test
   entry, delete that line from `project.yml` (the core tests still run with `swift test`).
3. Open the project. Check that `Info.plist` is **not** in *Copy Bundle Resources*, and that
   the four `.ttf` files, three `OFL-*.txt` files, `PrivacyInfo.xcprivacy` and
   `Assets.xcassets` **are**.
4. Build the app. Fix compile errors (§8 says where they are most likely).
5. Run on an iPhone simulator with no arguments. You should see the Library, folded.
6. Fonts: run the app tests (⌘U). `testEveryFamilyResolvesToItsOwnFont` fails if a font fell
   back to the system font; see §9.
7. Run with `-OmramoPosture unfolded` in landscape and compare with
   `docs/design/02-library-home.png` and `03-read-low.png`.
8. Open the story; turn all 14 pages; relaunch and check "Keep reading" offers the saved page.
9. **Decide the `TextRenderer` question** (criterion 1.17): do the tap-word highlight, spark
   and dotted name underline draw correctly? If the approach does not work, set
   `StoryTextStyle.usesTextRenderer = false` in `App/Sources/Text/StoryText.swift` (plain
   underlines) and record the decision here: **TBD**.
10. Record the Xcode and XcodeGen versions in §1, and list any fixes you had to make.

## 8. Known unverified items

Nothing was compiled. These are the places where I am least sure, most likely first.

| # | Item | File | If it fails |
|---|---|---|---|
| 1 | **`TextRenderer` usage**: iterating `Text.Layout` lines and runs, `run[Attribute.self]`, `run.typographicBounds.rect` / `.origin`, `context.draw(run)`, `displayPadding`, and whether a custom attribute survives on a `Text` joined with `+` | `App/Sources/Text/StoryText.swift` | Fix the API names from the iOS 18 documentation; or switch `usesTextRenderer` off |
| 2 | **Inline face chips**: `Text(Image(uiImage:))` joined into a paragraph, with `baselineOffset`; whether a `TextRenderer` draws image runs via `context.draw(run)` | same | Draw the chip in the renderer over a reserved space instead |
| 3 | **Variable-font axes**: a `UIFontDescriptor` with `.name` plus `kCTFontVariationAttribute` (axis tag as a number → value), wrapped as `Font(uiFont as CTFont)`. The PostScript names were read from the font files (`BricolageGrotesque-96ptExtraBold`, `AtkinsonHyperlegibleNext-Regular`, `-Italic`, `Inter-Regular`) and are re-read from the bundle at launch | `App/Sources/DesignSystem/ColorAndFont.swift` | See §9 |
| 4 | `Text + Text` may be flagged deprecated by newer SDKs (a warning, not an error) | `StoryText.swift` | Replace with `Text("\(a)\(b)")` interpolation |
| 5 | Exact line height: `lineSpacing = designed line height − UIFont.lineHeight`. Line breaks will not match the browser render exactly; word spacing is not applied (allowed deviation) | `ColorAndFont.swift` | Tune by eye |
| 6 | `GeometryProxy.safeAreaInsets` read inside a `GeometryReader` that ignores the safe area (used so top and bottom chrome clear the status bar and home indicator on a real iPhone) | `App/Sources/Layout/PaneLayoutReader.swift` | Read the insets from an outer `GeometryReader` instead |
| 7 | Swift concurrency under `SWIFT_STRICT_CONCURRENCY = complete`: action closures are typed `@MainActor () -> Void`; `static let` environment defaults; `@Observable` `@MainActor` classes created in a `@State` initialiser | app-wide | Mostly warnings in Swift 5 mode; fix as reported |
| 8 | XcodeGen details: local package + scheme test entry for the package's tests; `Info.plist` kept out of resources; `#include?` optional include in the xcconfig | `project.yml`, `Configuration/Base.xcconfig` | See checklist steps 2–3 |
| 9 | SVG icons in the asset catalog as template images (strokes, round caps). The pin's white dot is drawn in SwiftUI on top | `App/Resources/Assets.xcassets/Icons` | Convert the SVGs to PDF, or check "Preserve Vector Data" |
| 10 | `Bundle.module` lookup of the `Content` folder copied with `.copy(…)`, inside an app and on Linux | `Content/ContentRepository.swift` (`BundledContent`) | The app shows "The stories could not be opened" with the path it tried |
| 11 | `Codable` for the typed ids relies on the standard library's `RawRepresentable` defaults (ids must encode as plain strings) | `Model/Identifiers.swift` | A decoding test fails immediately; add explicit `init(from:)` / `encode(to:)` |
| 12 | Glass look (material + tint + shadows), page-turn button shading, aurora without grain: estimates to match by eye | `DesignSystem/Components.swift` | Tune against the screenshots |
| 13 | Dates and facts in the content (Taj Mahal dates, coordinates, the "crocodiles shut their eyes" line taken from the tale) are unreviewed | content JSON | Content review (C1) |

Not verifiable at all without hardware: everything about the real Duo (pane sizes, hinge,
posture API, per-pane safe areas). The app does not reference any Duo API.

## 9. Troubleshooting: fonts not loading

Symptoms: text in the system font; `testEveryFamilyResolvesToItsOwnFont` fails; the Debug
console prints `[Omramo] font problem: …` at launch.

1. **File not in the bundle.** In Xcode, select `App/Resources/Fonts/*.ttf` and check *Target
   Membership: Omramo*. Re-run `xcodegen generate` if the files were added after generating.
2. **Not listed in `UIAppFonts`.** `App/Resources/Info.plist` must list the four file names
   exactly (they are copied to the bundle root, so no folder prefix).
3. **Wrong PostScript name.** The app reads the real names from the files at launch
   (`FontRegistrar`). To see them, pause in the debugger and run
   `po FontRegistrar.registeredPostScriptNames`, or `po UIFont.familyNames`. If a name differs
   from the token in `Packages/OmramoCore/Sources/OmramoCore/DesignTokens/TypeTokens.swift`
   (`postScriptName`), update the token.
4. **Axes ignored** (the font loads but every weight looks the same). Check the variation
   dictionary in `OmramoFont.uiFont`: keys are the axis tags as 32-bit numbers (`wght`,
   `opsz`, `wdth`). Axis ranges read from the files: Bricolage `wght` 200–800, `wdth` 75–100,
   `opsz` 12–96; Atkinson `wght` 200–800; Inter `wght` 100–900, `opsz` 14–32.

The three families are SIL OFL 1.1; the licence texts are bundled next to the fonts
(`OFL-*.txt`). Showing them in the app ("Terms and legal") is M6.

## 10. Signing, bundle identifier, App Store

- `DEVELOPMENT_TEAM` is empty on purpose. Simulator builds need no team. For a device build,
  create `Configuration/Signing.local.xcconfig` (git-ignored) containing
  `DEVELOPMENT_TEAM = <your team id>`.
- The bundle identifier `com.omramo.app` is a **placeholder, TBD** (PRD Q20). It has not been
  registered anywhere.
- No App Store Connect action has been taken and none is needed for M1.

## 11. Kids-appropriate settings in this build

- No network code, no analytics, no third-party SDK; `project.yml` and `Package.swift` name no
  remote package.
- No permission is requested: `Info.plist` has no usage-description keys.
- `PrivacyInfo.xcprivacy`: tracking false, no tracking domains, no collected data, no
  required-reason APIs (the app uses neither `UserDefaults` nor file timestamps in M1). To be
  re-checked in M6.
- Nothing a child can tap leads outside the app or to a purchase. There is no purchase code.
- Stored on the device: reading position per story only (Application Support,
  `Omramo/reading-progress.json`). No times, no durations.
