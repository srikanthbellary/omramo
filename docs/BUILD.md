# Omramo — Build and run (Milestones 1, 2, 3 and Mi)

**Status: Milestone 1 first-compiled on the Mac Studio, 13 Nov 2026.** The Swift package
tests and an iPhone 17 Pro Max (iOS 26.5) simulator build both succeeded. The app launches.
See §7 item 10 for the compile fixes.

**Milestones 2, 3 and Mi are code complete and NOT yet compiled** (written 13 Nov 2026 on
the Linux box, which has no Swift toolchain; checked by inspection and by reviewer passes
only). Expect compile errors on the first Mac build of this round: §7a is the checklist and
§8 lists where they are most likely. Nothing in this round has been seen on a screen.

Reads with: `docs/IMPLEMENTATION_PLAN.md` (M1 scope and acceptance criteria),
`docs/ARCHITECTURE.md`, `docs/DESIGN.md`.

---

## 1. What you need

| Tool | Version | Notes |
|---|---|---|
| macOS | macOS 26.7.1 (Mac Studio, Apple M4 Max) | Recorded 13 Nov 2026 |
| Xcode | **16.0 or later** (iOS 18 SDK, Swift 6 toolchain) | First verified build: **Xcode 26.6** (17F113), Swift 6.3.3, iOS 26.5 Simulator. PRD Q16. |
| XcodeGen | 2.38.0 or later | First verified build: **2.46.0**, installed at `~/development/bin/xcodegen` (Homebrew was not writable). |
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
| Launch argument `-OmramoPosture folded` (Debug only) | One 432 × 720 pt reference pane, scaled to fit (compare with `10-folded.png`) |
| A window at least 748 pt wide, at least 600 pt tall and wider than tall, no argument (iPad Pro 11-inch and 13-inch in landscape; a large Stage Manager window) | Two panes with a 28 pt virtual gutter (rule 4 of the resolver). An ordinary iPhone in landscape is too short and stays single-pane |
| A window taller than wide and at least 980 pt wide (iPad Pro 13-inch in portrait; a two-thirds Split View on a 13-inch iPad in landscape, which the tests take as 981 × 1024 pt — only just over the threshold, to check on the simulator) | Two panes as well: each is wider than the design's pane |
| Any other window: iPad Pro 11-inch in portrait, a half or narrow Split View, Slide Over, a small Stage Manager window | One well-padded pane (the folded composition) |

On every layout derived from a window's size the design is scaled by at most **1.3 ×** (the
real Duo and the simulated canvas are not capped). A larger pane keeps the design's own
proportions and gains room: the text column and cards sit in a centred band, the scene fills
the whole window, and glass chrome stays at the pane's edges. The thresholds (748, 600, 980,
1.3) are assumptions in `PaneLayoutResolver`, to tune by eye on the Mac (milestone Mi).

To set the argument: **Product ▸ Scheme ▸ Edit Scheme… ▸ Run ▸ Arguments**. Both arguments are
already listed there (unticked); tick one. For `unfolded`, **rotate the simulator to
landscape** (⌘→) and pick the largest iPhone you have (iPhone 16 Pro Max: 956 × 440 pt, so the
canvas is drawn at about 0.61 scale). Everything scales with the pane, so proportions match the
screenshots even though the picture is small.

The app is **universal** (`TARGETED_DEVICE_FAMILY = 1,2`; PRD Q1 decided 13 Nov 2026). Ordinary
iPhones use the single-pane layout; iPads use the table above, through the same resolver —
there is no separate iPad layout. Check milestone Mi on the **iPad Pro 11-inch and 13-inch
simulators, portrait and landscape**, then in Split View and Stage Manager (drag the divider
across the threshold while a page — and then a card — is open).

From the command line:

```sh
xcrun simctl launch booted com.omramo.app -OmramoPosture unfolded
# Open the sample story (Debug only), alone or combined with a posture:
xcrun simctl launch booted com.omramo.app -OmramoOpenStory monkey-and-crocodile
xcrun simctl launch booted com.omramo.app -OmramoPosture unfolded -OmramoOpenStory monkey-and-crocodile
# The Medium and Advanced stories (screens 04 and 05):
xcrun simctl launch booted com.omramo.app -OmramoPosture unfolded -OmramoOpenStory anansi-wisdom
xcrun simctl launch booted com.omramo.app -OmramoPosture unfolded -OmramoOpenStory urashima-taro
```

Hardware keyboard (simulator: *I/O ▸ Keyboard ▸ Connect Hardware Keyboard*): **→** or
**space** turns the page, **←** goes back a page; with a card open, **Return** is "Back to my
line" and **Esc** closes it.

Command-line builds must keep `ONLY_ACTIVE_ARCH=YES` (already set for Debug in `project.yml`).
Without it, `xcodebuild` tries to compile the app for x86_64 while the local `OmramoCore`
package emits only arm64, and the build fails with `unable to resolve module dependency: 'OmramoCore'`.
An explicit destination on Apple Silicon is enough once that setting is present:

```sh
xcodebuild -project Omramo.xcodeproj -scheme Omramo   -destination 'platform=iOS Simulator,id=<booted-simulator-udid>'   -derivedDataPath build/dd build
```

## 5. Content

| Path | What |
|---|---|
| `Packages/OmramoCore/Sources/OmramoCore/Resources/Content/catalog.json` | Ordered story ids |
| `…/Content/stories/monkey-and-crocodile/story.json` | Low tier, Buddhist Jataka tradition, India: 14 pages in two parts, text on the leading pane |
| `…/Content/stories/anansi-wisdom/story.json` | Medium tier, Akan (Asante and Fante), Ghana: *How Wisdom Became the Property of the Human Race*, 8 pages, light text on a twilight scene, cultural review **required** |
| `…/Content/stories/urashima-taro/story.json` | Advanced tier, Japan: *The Story of Urashima Taro*, 16 pages in three parts, text on both panes, one `pathText` block (the call across the water, page 4) |
| `…/Content/sources/<story-id>.txt` | The manuscript each story's text is checked against (one per story) |
| `…/Content/landmarks/landmarks.json` | Landmark catalog: `taj-mahal` (Low story, framed), `asante-traditional-buildings` (Medium story, natural), `tokyo-skytree` (Advanced story, framed "then and now") and `lighthouse-of-alexandria` (a lost wonder, to exercise the reconstruction rule) |
| `…/Content/ART_PLACEHOLDERS.md` | Every image the JSON names, its size and what it should show. **None of the image files exist yet**; the app draws concept art in code |

Check it:

```sh
python3 tools/validate_content.py                 # development: exit 0, pending reviews are warnings
python3 tools/validate_content.py --release       # exits 1 today: reviews are pending (expected)
python3 tools/validate_content.py --check-art     # also lists the image files not delivered yet
python3 tools/test_validate_content.py            # 62 tests: every invalid fixture is rejected
```

Schema additions in this round (still `schemaVersion` 1; both are optional or only checked):

- `spread.scene.textArea { leadingBottom?, trailingBottom? }` — where the calm part of the
  scene ends on each pane, as a y position on the 720-point reference pane (200…720). The
  Advanced story sets `trailingBottom: 420`: the picture keeps the lower part of the trailing
  pane. Rule `text-area-range`.
- A `pathText` block must carry a `path` of absolute `M`, `L`, `Q`, `C` commands (the subset
  the app draws), and a paragraph must not carry one. Rule `path-text-incomplete`.

`tools/validate_content.py` mirrors `StoryValidator` in the core rule for rule, with the same
rule codes (a test compares the two lists). If they ever disagree, the Swift validator wins.

**All three story texts are our own retellings** of traditional tales (`textBasis:
omramoRetelling`). They are draft copy: every text review is `pending`; the cultural reviews
(required: a Buddhist reader for the Jataka, an Akan reader for Anansi; standard: a Japanese
reader for Urashima) are `pending`; all card, lesson and fact-card wording is unreviewed. The
cited editions (Babbitt 1912, Barker and Sinclair 1917, Ozaki 1908) are the documented sources
of the tales, not the app's wording. Editorial choices that need Srikanth's decision are
listed in `docs/AGENT_HANDOFF.md` (PRD Q5, Q22; the Urashima ones also in its manuscript's header): the Urashima
retelling ends with him grown old on the shore (no death, no tobacco or sake, no wedding); the
Anansi retelling softens why he takes the wisdom back.

### Concept art drawn in code

No image files ship. `App/Sources/Art/` draws every scene, cover, tap-to-see picture,
character portrait, face chip and landmark picture in SwiftUI `Canvas` code, chosen by each
art reference's asset name (`JatakaArt`, `AnansiArt`, `UrashimaArt`, `LandmarkArt`; shared kit
`ArtKit.swift`; lookup `StoryArt.swift`). The drawings are our own, ported and extended from
the locked design sources (`docs/design/source/src/lib/art-*.js`); no photographs and no
third-party art. They are concept art (`review.art: pending`), written without a compiler and
not yet seen on a screen. To use a real picture, add the file at the path the JSON names (see
`ART_PLACEHOLDERS.md`); the app loads it instead of the drawing, with no code change. Search
the code for `TODO(art)`.

## 6. What is implemented, and what is stubbed

### Implemented in M1 (compiled and launched on the Mac, 13 Nov 2026)

- **Project:** `project.yml` (XcodeGen), `Configuration/*.xcconfig`, `Info.plist` with
  `UIAppFonts`, an empty-collection privacy manifest, no remote packages, no signing team.
- **`OmramoCore`** (Foundation only): the content model (schema version 1) with tiers, spreads,
  text runs, tap-to-see targets, character cards, art references, `region`, `provenance`,
  `culturalReview`, `education`, and the `Landmark` catalog with per-tier fact cards and
  `framingDevice`; decoder with schema-version check and readable errors; validator (identity,
  references, art, colours, region, provenance, reviews, education, landmark and anachronism
  rules, text fidelity); `ContentRepository`; library model and level filter; `PaneLayout` and
  its resolver; `Pager`, `ReadingPosition`, page-dash rule; design tokens and the tier type
  scale as data; `Brand` and `FoldMark`; `LandmarkCardContent`.
- **App:** design-system wrappers (colours, variable-axis fonts, glass, chips, tier glyph, page
  dashes, round glass button, round page-turn button, primary button, card, aurora backdrop,
  SVG icons ported from the design source); font registration; `PaneLayoutReader` / `TwoPane`
  with the derived and simulated-Duo providers; **Library** (wordmark, Keep reading, level
  filter, story cards, tab bar, story map with real pins); **Reading, Low**.
- **Tools:** `tools/validate_content.py`, `tools/test_validate_content.py`.

### Implemented in the M2 / M3 / Mi round (code complete, **not yet compiled or seen**)

**Mi fixes from the first simulator pass**

- *Reader text clipped under the controls on iPad.* The reader is rewritten so that text no
  longer scrolls behind chrome (to confirm on the simulator). Each pane has a text area with a top (below the back button / "Aa"
  capsule and the status bar) and a bottom (above the footer chips, the page chip, the round
  button and the home indicator); text that does not fit that area goes to a continuation
  screen (`ReaderMetrics`, `ReaderPageLayout`). `ReaderGeometryTests` (not yet run) checks the arithmetic on
  iPad Pro 11-inch and 13-inch (both orientations), Split View, Slide Over, Stage Manager and
  iPhone sizes, for all three stories at all five text sizes.
- *Library tab bar covered the map legend.* The tab bar now has its own strip under the
  scrolling column; the column ends (with a soft fade) above it, so the legend and every card
  are either fully visible or scrolled away, never underneath the bar.
- *Stretched-iPhone look.* A derived layout scales the design by at most 1.3 ×; wider panes
  centre the text column and cards and let the scene fill the window (§4). Scenes are drawn
  for the window's real shape (anchored top and bottom), not stretched from the Duo's.

**M2 — complete reader**

| Item | Where | Notes |
|---|---|---|
| "Aa" text size, five steps (0.9, 1.0, 1.15, 1.3, 1.5), remembered | `TextSizeStep` (core), `TextSizePanel`, `ReaderMemoryStore` | Interim panel (design gap G1). The first launch starts from the system text size |
| Continuation screens: no clipping or truncation at any size | `ScreenPlanner`, `ScreenPlan` (core); `ReaderPageLayout`, `ReaderMeasurer` | Same page number, same scene, next paragraphs. A paragraph taller than a whole column continues sentence by sentence (`TextBlock.sentenceFragments()`); a single sentence taller than a column makes that one column scroll instead of clipping |
| Bookmark: one per story, saved and restored | `ReaderMemoryFile` (core), `TextControlsCapsule`, `TextSizePanel` | The capsule's bookmark fills when this page is bookmarked; pressing it there removes it; "Go to my bookmark · page N" is in the "Aa" panel |
| Back one page | `Pager.backward` (core), `PreviousPageButton` | Small glass button with the design's unused `prev` arrow, beside the page chip; hidden on the first screen. Goes to the *last* screen of the page before. No swipe (PRD Q13 open) |
| Position: page **and** paragraph, across relaunch and posture / window changes | `ScreenAnchor`, `ReadingPosition.anchor` (core), `ReaderModel` | The model stores the paragraph first on screen, never a screen index |
| Folded reading to screen 10 | `ReaderFoldedPane`, `FoldedPictureBand`, `FoldedGround`, `WaveEdge` | Picture band with a wave edge over a ground in the story's own light; Low 22.5 / 35; seven dashes; tier chip, page chip, 54 pt button. Medium and Advanced folded type uses the unfolded values (gap G8) |
| Medium and Advanced stories | `Content/stories/anansi-wisdom`, `urashima-taro` | §5. Text on both panes for Advanced; `pathText` on the designed wave |
| Text on a path | `SVGPath`, `PathSampler` (core), `PathTextView` | Letters set one by one along the curve, with the dotted echo line |
| Per-story theme | `StoryTheme` → `StoryChips`, `PageChip`, `PageTurnButton`, `StoryTextRenderer` | Light / dark chrome per pane, text colour, amber and red page-turn buttons, tap colours |
| Sound words, stretched words, face chips, highlight shapes | `StoryTextBuilder`, `StoryTextRenderer`, `FaceChipRenderer` | Face chips are drawn from the character's own face art |

**M3 — tap-to-see, landmark and character cards**

| Item | Where | Notes |
|---|---|---|
| Marked words and names are tappable, ≥ 44 pt | `MarkButtons` in `StoryText.swift` | Invisible buttons laid over the word's rectangles, read back through `Text.LayoutKey` |
| Card on the facing pane; with text on both panes it covers the pane without the word | `CardPlacement` (core), `ReaderLeadingPane` / `ReaderTrailingPane` | Placement follows the pane the word is *shown* on now |
| Hold state: dimming, beam, place marker; "Back to my line" or ✕; toast; seen style; seen state persisted | `ParagraphHold`, `HoldBand`, `ReaderToastView`, `MarkState`, `ReaderMemoryStore` | The marker and wash stay until the child turns the page (open question, DESIGN §5.8) |
| The text does not move or re-wrap when a card opens or closes | `StoryTextBuilder` / `StoryTextRenderer` | Only colours and what the renderer paints change; no font, size or width |
| The page cannot be turned while a card is open | `ReaderModel.turnPage`, `goBack`, `setTextSize`, `toggleBookmark` | Guarded in the model, and the controls are covered or disabled |
| Folded: bottom card (assumption A2, gap G4) | `CardSheet` | The same card, rising from the bottom over a dimmed pane |
| Card survives and re-places itself across a posture / size change | `ReaderModel.openCard`, `ReaderPage.placement` | State is in the model; placement is recomputed every layout |
| Nothing on a card opens another card | `StoryCards.swift` | Cards are given only a close action |
| Landmark card: same layout, tier wording, framing label, reconstruction subtitle | `TapCardContent` (core), `TapToSeeCard` | One landmark per prototype story |
| Character cards | `CharacterCardContent` (core), `CharacterCard` | The Monkey; Father Anansi, Kweku Tsin; Urashima, the tortoise, Princess Otohime |
| Friends met | `ReaderMemoryFile.recordMet` (core), `ReaderModel.didShow` | Recorded when a screen showing the character's naming run is laid out. Not shown anywhere yet (M4) |
| VoiceOver | `StoryParagraph`, cards | Each paragraph offers its marked words as custom actions; focus moves to the card title and back to the paragraph; cards are modal; the toast is announced |

**Mi — iPad, Split View, Stage Manager, pointer and keyboard**

| Item | Where | Notes |
|---|---|---|
| Two panes on full-size iPads in landscape, and on a 13-inch iPad in portrait; one padded pane otherwise | `PaneLayoutResolver` (core) | The same resolver as the Duo — no third layout system |
| Resizing across the threshold keeps page, paragraph and open card | `ReaderModel` (anchor and card are content ids) | Live with the window: the layout is a pure function of its size |
| Pointer and keyboard | `NextPageButton`, `PreviousPageButton`, `ReaderKeyCommands`, cards | Every control is a real button (so a pointer click should work); → / space, ←, Return, Esc; hover lift on round buttons; no hover-only control |
| Safe areas | `ReaderMetrics`, `PaneContext` | Top controls clear the status bar; bottom chrome clears the home indicator |

**Tests added**

- Core (`swift test`): `ReaderFlowTests.swift` and `ReaderCardTests.swift` — continuation
  paging, screen planning, anchors across layout changes, reading-position restore, text-size
  steps, sentence splitting (including every paragraph of all three stories), SVG path and
  sampler, `CardPlacement`, reader memory (seen, friends, bookmark, no times stored), card
  content for ordinary, landmark and character cards, the three stories, iPad layout rules.
  About 80 new test methods on top of the 116 from M1 (counted on the box, 13 Nov 2026:
  116 + 81 = 197 `func test`; the number may still move in review, and none of the new ones
  has been run). **Two M1 assertions were updated**, in
  `DecodingTests.swift`, because they asserted a one-story catalog
  (`testCatalogDecodes`, `testLibraryLoadsAndListsTheSample`).
- App (⌘U): `App/Tests/ReaderTests.swift` — the reader model, the reader's geometry on eleven
  window sizes, and a smoke test that draws every picture the content names. About 20 test
  methods, beside the 8 in `OmramoAppTests.swift`; not yet run.
- Python: 62 tests (46 from M1 + 16). These were run on the box and pass.

### Short of the acceptance criteria (precise leftovers)

Everything marked *[Mac]* in `docs/IMPLEMENTATION_PLAN.md` for M2, M3 and Mi is **unverified**
until this round compiles and is looked at. Beyond that, known gaps:

| Criterion | Gap |
|---|---|
| 2.1, 2.2, 3.1 (match the PNGs) | Never rendered. Line breaks will differ from the browser render; word spacing is still not applied; the designed pages use the 1917 / 1908 wording and ours are retellings, so text never matches word for word |
| 2.2, gap G8 | Folded Medium and Advanced type is not designed; the unfolded sizes are used |
| 2.4 | Intended by construction and covered as arithmetic by tests that have not been run; not yet checked by eye. The last-resort scrolling column (a single sentence taller than a column) is a deviation from "reading text never scrolls" (ARCHITECTURE §8.3); it is expected only at the largest sizes in the smallest windows, which is unmeasured |
| 3.1 | The **inlet glow** on the card's hinge edge at the height of the held paragraph (DESIGN §5.8) is not drawn |
| 3.2 | "Pixel-identical" needs a screenshot diff on the Mac |
| 3.7 | Focus moves are expressed with `AccessibilityFocusState`; whether VoiceOver honours them at the right moment needs a device |
| A2 / G4 | Folded: the bottom card covers the pane from just below the top controls down, so the tapped line is usually *not* visible behind it (A2 asks that it stay visible). The marker, wash and toast show on return. Needs a design answer |
| G1 | The "Aa" panel is an interim design |
| G3 | The back control's place and look are interim; the last page's button still shows a tick and returns to the library |
| i.1–i.5 | Thresholds and the 1.3 × cap are assumptions, untested on a simulator |
| Art | All pictures are concept art drawn in code, unseen; see `ART_PLACEHOLDERS.md` |

### Visual gaps versus `docs/design/` still open (criterion i.5 and the award bar)

1. **Nothing in this round has been rendered.** The first job on the Mac is a side-by-side of
   screens 03–07 and 10 in simulated-Duo mode, then the iPad sizes.
2. **Art:** the three "ported" scenes (`scene-river`, `scene-climb`, `scene-sea`) and the Rin
   Gin and Monkey cards should be close to the PNGs; every *new* composition (ten scenes, six
   tap-to-see pictures, five portraits, four landmarks, three covers) is unseen and will need
   art direction. Folded scenes are crops of the unfolded scene, not compositions of their
   own (one exception: the folded `scene-ride` is drawn separately, after screen 10). The design's SVG grain is approximated by a tiled noise overlay and light stipple.
3. **Type:** line breaks, hanging punctuation, "pretty" wrapping and word spacing are not
   matched; exact line height relies on `lineSpacing` arithmetic; the text-on-a-path letters
   are set one by one without kerning pairs.
4. **Glass:** material + tint is an estimate of the design's blur and saturation.
5. **Motion:** cross-fades (scene, text, card, toast); the card's fade is on a spring, and
   the folded bottom card also slides up. No page-turn drift, no haptics (M6). Reduce Motion
   gets opacity-only transitions.
6. **Hold state:** no inlet glow; the beam is the paragraph's height plus 8 pt above and
   below (the design source draws a fixed 66 pt band on screen 06 — matched approximately).
7. **iPad:** two tall panes on a 13-inch portrait screen leave a lot of scene below the text
   on Low and Medium pages; whether that reads as graceful or empty needs eyes. The library's
   trailing pane is still mostly empty (streak, shelf and friends cards are M4).
8. **Library:** covers are new code drawings; the Anansi and Urashima covers follow the brief
   (Anansi on the tree; Urashima in his boat), not the exact covers of screen 02.
9. **Page chip:** a page with continuation screens fills its coral dash step by step; this is
   an invention, not in the designs.

### Stubbed — marked `TODO(Mx)` in the code

| What | Where | Lands in |
|---|---|---|
| Last page: the button shows a tick and returns to the library (no finished moment) | `NextPageButton` | M6 (gap G3) |
| Sample gate, end-of-sample card, paywall, StoreKit: **every page of all three stories is readable** | `ReaderModel.turnPage` | M5 |
| Reading log, streak, shelf, finished ticks; friends row (friends met are recorded, not shown) | `LibraryScreen.swift`, `ReaderModel.turnPage` | M4 |
| "My shelf" and "Grown-ups" tabs are drawn but inert; no grown-up gate, no parent view | `LibraryTabBar` | M4 |
| Map legend says "Read", but read state does not exist yet | `StoryMapCard.swift` | M4 |
| Splash, page-turn motion, haptics, loading and error designs, app icon | several | M6 |
| Duo SDK adapter | `Layout/PaneLayoutProvider.swift` | M7 |
| Real illustrations | `App/Sources/Art/` (`TODO(art)`) | C1 |

There is no `TODO(M2)` or `TODO(M3)` left in the code.

### Deviations from `docs/IMPLEMENTATION_PLAN.md` (deliberate)

1. **Story texts are fresh Omramo retellings**, not the unaltered public-domain texts the plan
   still describes for M1–M3 (assumption 3 there). This follows the M1 and M2 briefs,
   `docs/CONTENT_PLAN.md` §1.2 and PRD A12. So `provenance.textBasis` is `omramoRetelling`,
   the manuscripts in `sources/` are our texts, and no page reads word for word like its PNG.
   Decision needed: PRD Q22.
2. **Content is a resource of the `OmramoCore` package**, not a top-level `Content/` folder.
3. **No image files and no `tools/render_placeholder_art.py`.** Art is drawn in SwiftUI code,
   so the validator cannot check pixel sizes; a missing image file is reported only with
   `--check-art`.
4. **Invalid fixtures are made in memory** by breaking one thing in valid content.
5. **The text-size setting is stored in a file** (`reader-memory.json`), not in `UserDefaults`
   as `docs/ARCHITECTURE.md` §10.3 says, so the privacy manifest needs no required-reason
   entry for it.
6. **Schema additions** within version 1: `scene.textArea` and the `pathText` path rule (§5).
7. Type names: `ContentDecoder` (the plan's `StoryDecoder`) and `StoryCharacter` (the plan's
   `Character`).
8. A page that fits flows text only where it was authored; when it overflows on an Advanced
   page, text continues leading pane → trailing pane → next screen, in reading order.

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
    **Done, 13 Nov 2026, Mac Studio (M4 Max):**
    - Xcode 26.6 (17F113), XcodeGen 2.46.0, iPhone 17 Pro Max simulator (iOS 26.5, UDID
      `416D3327-A123-4748-8ABF-9E8D27B48610`).
    - `swift test --package-path Packages/OmramoCore`: **116 tests, 0 failures**.
    - First `xcodebuild` without `ONLY_ACTIVE_ARCH=YES` failed: the app compiled for x86_64
      against an arm64 `OmramoCore.swiftmodule` (`unable to resolve module dependency:
      'OmramoCore'` / "built for incompatible target"). Fixed by setting `ONLY_ACTIVE_ARCH=YES`
      on the Debug configuration and `ALWAYS_SEARCH_USER_PATHS=NO` (silences the traditional
      headermap warning). No Swift source changes were required for the first green build.
    - Added Debug launch argument `-OmramoOpenStory <story-id>` so the reader can be opened
      from `simctl` without UI automation.
    - `TextRenderer` decision (item 9) is still **TBD** pending a visual check of the
      Low-tier reading screen.

## 7a. First-compile checklist for the M2 / M3 / Mi round

Nothing in this round has been compiled. Work in this order; each step depends on the one
before.

1. `swift test --package-path Packages/OmramoCore` — the core first. Expect the 116 M1 tests
   plus the new ones in `ReaderFlowTests.swift` and `ReaderCardTests.swift` (about 80; see
   §6). Fix compile errors here before touching the app.
2. `python3 tools/validate_content.py` and `python3 tools/test_validate_content.py`
   (0 errors; 62 tests).
3. `xcodegen generate` (new source files were added), then build the app. §8a says where
   errors are most likely. The art painters are about 7,800 lines of drawing code written
   without a compiler: if one file fights back, the quickest unblock is to make its `paint`
   return `false` (the app then draws a calm gradient stand-in) and come back to it.
4. Run the app tests (⌘U): `ReaderTests.swift` checks the reader model, the geometry on
   eleven window sizes, and draws every picture once (`ArtCoverageTests` — it also catches a
   picture name with no painter).
5. Simulated Duo, landscape: `-OmramoPosture unfolded -OmramoOpenStory <id>` for each of the
   three stories; compare with `docs/design/03`, `04`, `05`. Then tap a marked word and a
   name (06, 06b, 07). Then `-OmramoPosture folded` (10).
6. **Decide the two text switches** in `App/Sources/Text/StoryText.swift`:
   `usesTextRenderer` (highlights, spark, dotted underline — criterion 1.17, still open from
   M1) and `usesLayoutKey` (per-word tap targets). If marked words draw but do not respond to
   taps, set `usesLayoutKey = false`: a tap on a paragraph then opens its first marked word.
   Per-word targets need both switches on: with `usesTextRenderer = false` taps are also
   paragraph-level. Record the decision here: **TBD**.
7. Text size: open "Aa", go to the largest step on every page of each story, folded and
   unfolded, on the smallest iPhone you have. Nothing may be clipped; pages continue on
   further screens with the same page number (criterion 2.4).
8. Posture and size: toggle the simulated posture, rotate an iPad, and drag a Split View
   divider across the two-pane threshold — mid-page, and with a card open. The page, the
   paragraph and the card must survive (criteria 2.3, i.3).
9. iPad Pro 11-inch and 13-inch, portrait and landscape: no text under any control, tab bar
   clear of the map legend, nothing that looks like a stretched phone (criteria i.1, i.2, i.5).
10. VoiceOver: a paragraph's actions rotor offers "Show picture: …" / "About: …"; focus goes
    to the card's title and comes back to the paragraph (criterion 3.7).
11. Go through every picture against `ART_PLACEHOLDERS.md` and list what needs art direction.

## 8. Known unverified items

Milestone 1 compiled and ran (13 Nov 2026). The table below is the M1 list, kept for the
items still waiting for a visual check; §8a lists what is unverified in the M2 / M3 / Mi round.

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

### 8a. Unverified in the M2 / M3 / Mi round

Nothing in this round was compiled. Most likely to need a fix, first:

| # | Item | File | If it fails |
|---|---|---|---|
| 1 | **`Text.LayoutKey`** — reading laid-out text back to place the tap targets: `overlayPreferenceValue(Text.LayoutKey.self)`, `AnchoredLayout.origin` / `.layout`, `proxy[anchor]`, and whether run rectangles are relative to that origin | `App/Sources/Text/StoryText.swift` (`MarkRegions`, `MarkButtons`) | Fix the names from the iOS 18 documentation; or set `StoryTextStyle.usesLayoutKey = false` (paragraph-level tap) |
| 2 | **The art painters** (`JatakaArt*`, `AnansiArt*`, `UrashimaArt*`, `LandmarkArt*`, about 7,800 lines): type-checker time on long arithmetic, `CGFloat` / `Double` slips, closure inference. Reviewed by inspection only | `App/Sources/Art/` | Split the reported expression; or stub that painter (`return false`) for now |
| 3 | **Measuring loop**: hidden paragraphs report heights with `onGeometryChange`; the model stores them; the page is planned from them. If text never appears, the heights are not arriving | `ReaderMeasurer`, `ReaderModel.report`, `ReaderPageLayout` | Check that `onGeometryChange` fires for hidden views; replace `.hidden()` with `.opacity(0)` |
| 4 | Text on a path in a `Canvas`: `context.resolve(Text)`, `measure(in:)`, `firstBaseline(in:)`, `draw(_:at:anchor:)` with a rotated context | `PathTextView` | Fix from the documentation; fall back to drawing the block as a lead sentence |
| 5 | `ImageRenderer` drawing a `Canvas` off screen (face chips; the art smoke test) | `FaceChipRenderer`, `ArtCoverageTests` | Face chips fall back to a plain head; the test skips itself |
| 6 | `AccessibilityFocusState<ReaderFocus?>.Binding` passed down through views and an optional-binding modifier; `accessibilityActions { ForEach … }` | `StoryText.swift`, `StoryCards.swift`, `ReaderScreen.swift` | Keep the focus state in each view instead |
| 7 | Keyboard: `keyboardShortcut(.rightArrow / .leftArrow / .space, modifiers: [])` on custom buttons; `.cancelAction` / `.defaultAction` on card buttons | `ReaderChrome.swift`, `StoryCards.swift`, `ReaderKeyCommands` | Use `onKeyPress` on a focusable container |
| 8 | Explicit `return` inside a `body` to switch the view builder off (`HoldBand`, `FoldedGround`) | `StoryText.swift`, `ReaderScreen.swift` | Move the `let`s into a helper function |
| 9 | Custom `Layout` for the trait pills | `WrappingRow` in `StoryCards.swift` | Replace with an `HStack` that truncates |
| 10 | `@MainActor` closures stored in a plain struct and called from view code (`StoryTextInteraction`), under complete concurrency checking | `StoryText.swift`, `ReaderScreen.swift` | Mostly warnings in Swift 5 mode; mark the struct `@MainActor` |
| 11 | Animations keyed on the model (`.animation(_, value: model.openCard)`): whether the text fade and the card spring feel right, and whether the hidden-then-shown text flickers on a page turn | `ReaderContent`, `ReaderColumn` | Tune or remove |
| 12 | `Double(".5")`-style numbers in ported SVG path strings (normalised in `Art.svg`, untested at run time) | `ArtKit.swift` | A shape draws truncated; fix the string |
| 13 | Folded picture height, the 1.3 × cap, the 980 pt portrait threshold, the two-thirds Split View case: all estimates | `ReaderMetrics`, `PaneLayoutResolver` | Tune by eye |
| 14 | Facts in the new content (Skytree height and date, Asante building dates, the Rin Gin and tamate-bako notes, the Anansi card's "spider in Twi" line) are unreviewed | content JSON | Content review (C1) |

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
  required-reason APIs (the app still uses neither `UserDefaults` nor file timestamps: the
  text-size setting is kept in a file, not in `UserDefaults`). To be re-checked in M6.
- Nothing a child can tap leads outside the app or to a purchase. There is no purchase code.
  A card has only a close button and "Back to my line"; nothing on a card opens anything.
- No ads, no tracking, no account, no sign-in screen.
- Stored on the device, in Application Support, never sent anywhere, no times, no durations:
  `Omramo/reading-progress.json` (reading position per story: page and paragraph) and
  `Omramo/reader-memory.json` (text-size step, one bookmark per story, which tap-to-see and
  character cards have been seen, which characters have been met).
