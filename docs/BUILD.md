# Omramo — Build and run (Milestones 1, 2, 3, Mi and rounds 3 and 4)

**Round 4 (14 Nov 2026) — polish: code complete, NOT compiled, NOT seen.** Written on the
Linux box (no Swift toolchain) on branch `feat/r4-polish`, checked by inspection, by scripts
(brace balance, duplicate declarations, the argument labels of all 3,407 calls into the art
kit) and by "be the compiler" reviewer passes. Rounds 1–3 build and pass on the Mac (247 core
tests, 52 app tests, 7 `WordTapTests`, the `ShotTests`). §6 "Implemented in round 4" says what
is in it; **§7c is the first-compile checklist** and §8c lists where compile errors are most
likely.

**Round 3 (14 Nov 2026) — polish (since compiled, run and merged as PR #4).** Written on the
Linux box (no Swift toolchain), checked by inspection and reviewer passes only. §6 "Implemented
in round 3" says what is in it; **§7b is the first-compile checklist** and §8b lists where
compile errors are most likely. The round-3 brief states that M1, M2, M3 and Mi build and run
on the Mac (Xcode 26.6, iOS 26 simulators, iOS 18 deployment target); the older status
paragraphs below were written before that and are kept for their checklists.

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
| Launch argument `-OmramoPosture unfolded` (Debug builds only) | **Two panes over the whole window** (round 4): the scene runs edge to edge, a thin 12 pt gutter stands for the hinge, the panes start inside the side safe areas and the real top and bottom safe areas apply. **On an iPhone the app turns itself to landscape** (an unfolded Duo is wider than tall). The panes are then shorter than the design's (about 410 × 440 pt on an iPhone 17 Pro Max), so the design is held at about 0.85 × and each screen shows less of a page (`PaneLayout.isSquat`); a page simply takes more screens. On an iPad it fills the window at the pane's own scale |
| Launch argument `-OmramoPosture reference` (Debug builds only) | The **reference Duo canvas**, letterboxed as before round 4: two 432 × 720 pt panes and a black 28 pt hinge band, scaled to fit the window. This is what to compare with `docs/design/02-library-home.png` and `03-read-low.png` |
| Launch argument `-OmramoPosture folded` (Debug only) on an iPhone, or on any window that is one pane anyway | **The real screen, edge to edge**, with its real safe areas — the folded Duo is an ordinary phone screen, so it is not drawn as a small picture of a device (round 3). The scene bleeds under the status bar and Dynamic Island; controls keep clear of them and of the home indicator |
| Launch argument `-OmramoPosture folded` on a window wide enough for two panes (an iPad in landscape) | One 432 × 720 pt reference pane, scaled to fit (compare with `10-folded.png`) |
| A window at least 748 pt wide, at least 600 pt tall and wider than tall, no argument (iPad Pro 11-inch and 13-inch in landscape; a large Stage Manager window) | Two panes with a 28 pt virtual gutter (rule 4 of the resolver). An ordinary iPhone in landscape is too short and stays single-pane |
| A window taller than wide and at least 980 pt wide (iPad Pro 13-inch in portrait; a two-thirds Split View on a 13-inch iPad in landscape, which the tests take as 981 × 1024 pt — only just over the threshold, to check on the simulator) | Two panes as well: each is wider than the design's pane |
| Any other window: iPad Pro 11-inch in portrait, a half or narrow Split View, Slide Over, a small Stage Manager window | One well-padded pane (the folded composition) |

On every layout derived from a window's size the design is scaled by at most **1.3 ×** (the
real Duo and the simulated canvas are not capped). A larger pane keeps the design's own
proportions and gains room: the text column and cards sit in a centred band, the scene fills
the whole window, and glass chrome stays at the pane's edges. The thresholds (748, 600, 980,
1.3) are assumptions in `PaneLayoutResolver`, to tune by eye on the Mac (milestone Mi).

To set the argument: **Product ▸ Scheme ▸ Edit Scheme… ▸ Run ▸ Arguments**. The arguments are
already listed there (unticked); tick one. For `unfolded` on an iPhone the app asks for
landscape itself (`-OmramoOrientation portrait` overrides that; two narrow panes result). For
`reference`, **rotate the simulator to landscape** (⌘→) and pick the largest iPhone you have
(956 × 440 pt, so the canvas is drawn at about 0.61 scale): everything scales with the pane, so
proportions match the locked screenshots even though the picture is small.

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
xcrun simctl launch booted com.omramo.app -- -OmramoOpenStory monkey-and-crocodile -OmramoOpenCard river-bank
```

Arguments that start with `-` must come after `--`, or `simctl` swallows them. Debug-only flags:
`-OmramoOpenCard <tap-or-character-id>` opens that card on the opened story; `-OmramoOrientation
landscape|portrait` asks the window scene to rotate. Two more since round 3, both without a
value: `-OmramoResetState` starts with empty in-memory stores (every story opens on page 1 and
nothing is read from or written to the simulator — the UI tests use it); `-OmramoDemoState`
starts with a small made-up reading history in memory (a three-day streak, one story finished,
one in progress on page 5, friends met) so the library can be photographed with its cards
filled.

Three more since round 4: `-OmramoOpenFinished <story-id>` opens that story on its
story-finished moment (nothing is written to the reading log); `-OmramoOpenPage <n>` (with
`-OmramoOpenStory`) starts on page n, clamped to the story's pages; `-OmramoShowSplash` keeps
the splash on screen until the app is closed. The splash is skipped whenever a launch argument
opens a story.

```sh
xcrun simctl launch booted com.omramo.app -- -OmramoOpenFinished monkey-and-crocodile
xcrun simctl launch booted com.omramo.app -- -OmramoOpenStory monkey-and-crocodile -OmramoOpenPage 14
xcrun simctl launch booted com.omramo.app -- -OmramoShowSplash
xcrun simctl launch booted com.omramo.app -- -OmramoShowSplash -OmramoPosture unfolded
```

### Screenshots and UI tests (the `OmramoShots` scheme)

The `OmramoUITests` target holds three XCUITest classes. They are not part of ⌘U on the
`Omramo` scheme.

```sh
# Round-4 screenshots → $OMRAMO_SHOT_DIR (default /tmp/omramo-shots), named r4-ipad-*.png
# or r4-iphone-*.png after the simulator they ran on.
xcodebuild test -project Omramo.xcodeproj -scheme OmramoShots \
  -destination 'platform=iOS Simulator,id=<ipad-udid>' -only-testing:OmramoUITests/ShotTests
xcodebuild test -project Omramo.xcodeproj -scheme OmramoShots \
  -destination 'platform=iOS Simulator,id=<iphone-udid>' -only-testing:OmramoUITests/ShotTests

# Tapping marked words (goal 6): run on an iPhone and on an iPad simulator.
xcodebuild test -project Omramo.xcodeproj -scheme OmramoShots \
  -destination 'platform=iOS Simulator,id=<udid>' -only-testing:OmramoUITests/WordTapTests
```

`ShotTests` on an iPad writes, in landscape **and** portrait: `library`, `library-reading`
(with `-OmramoDemoState`), `reader-monkey`, `reader-anansi`, `reader-urashima`, `tap-to-see`
(the river-bank card) and, new in round 4, `finished` (the story-finished moment) and
`splash`. On an iPhone it writes the portrait set, the folded-posture set
(`reader-monkey-folded`, `library-folded`, `tap-to-see-folded` — the partial card with the
tapped line above it) and the unfolded-posture set, taken in landscape (`library-unfolded`,
`reader-monkey-unfolded`, `reader-anansi-unfolded`, `reader-urashima-unfolded`,
`tap-to-see-unfolded`, `splash-unfolded`). Each shot waits for a known accessibility
identifier (`reader.next`, `library.streak`, `card.river-bank`, `finished.moment`, `splash`)
and then 2.2 s for the splash, the rotation and the transition to come to rest. To change the
folder, edit `OMRAMO_SHOT_DIR` in the scheme (`project.yml`) and run `xcodegen generate`.

`MotionDemoTests` (round 4) are slow walks for screen recordings — they assert only that the
controls they need exist:

```sh
xcrun simctl io <udid> recordVideo --codec h264 demo-page-turn.mov &
xcodebuild test -project Omramo.xcodeproj -scheme OmramoShots \
  -destination 'platform=iOS Simulator,id=<udid>' \
  -only-testing:OmramoUITests/MotionDemoTests/testDemoPageTurn
kill -INT %1
```

| Test | What it shows |
|---|---|
| `testDemoLibraryToStory` | Splash, the library (1.5 s), the Monkey cover opens into the reader (2 s), "Library" closes it back into the cover (1.5 s) |
| `testDemoPageTurn` | The Monkey story: three presses of the round button, 1.5 s apart, then one press of the previous-page arrow |
| `testDemoTapToSee` | `word.river-bank` opens its card (2 s), "Back to my line" closes it (1.5 s) |
| `testDemoFinished` | The last page (`-OmramoOpenPage 14`), the round button until the story-finished moment arrives, 3 s on it |

They run on an iPhone (portrait, the real full screen) and on an iPad (portrait); every step
waits for its control by identifier (`library.story.<id>`, `reader.next`, `reader.previous`,
`reader.library`, `word.<id>`, `card.<id>`, `finished.moment`) before using it.

`WordTapTests` opens each story on page 1, taps a marked word by identifier
(`word.river-bank`, `word.village-houses`, `word.urashima`), expects its card
(`card.<id>`), closes it with "Back to my line" and expects it gone; taps one word
(`word.anansi`) by screen coordinate at the middle of its frame; checks every marked word on
each first page is at least 44 pt each way; checks that tapping an unmarked paragraph opens
nothing; and turns one page with the round button (`reader.next`, then `reader.previous`
appears).

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
  Advanced story sets `trailingBottom: 420` (the picture keeps the lower part of the trailing
  pane) and, since round 4, `leadingBottom: 470` (the words on the leading pane stop at the
  sea's horizon). Rule `text-area-range`. Since round 4 an authored text area is a share of
  the pane's height at any shape (`ReaderMetrics.pictureReserve`).
- Round 4: `story.moral` — one child-facing sentence for the story-finished moment. Optional
  in the file, required by the validators: present, not blank, at most 120 characters, exactly
  one sentence. Rule `moral-incomplete` (`MoralRule` in the core).
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

### Implemented in round 3 — polish (code complete, **not yet compiled or seen**)

**1. Tall windows (13-inch iPad in portrait): no empty band under short text**

| Item | Where | Notes |
|---|---|---|
| Extra height, measure and fit rules as pure arithmetic | `PageFit` (core, `Layout/PageFit.swift`) | Still the single `PaneLayoutResolver`; `PageFit` only reads the numbers a `PaneLayout` already gives. On the reference pane every function returns the designed value |
| Type grows on a tall two-pane window, within the tier's measure | `PageFit.typeBoost`, `ReaderMetrics.typeBoost` | Never past the layout's 1.3 × cap, never under the tier's shortest line (Low 24, Medium 32, Advanced 45 characters). 13-inch portrait: Low and Medium about 1.11 ×, Advanced 1.00 × (it keeps its 45-character line). Not on the Duo, not on one pane |
| A short page is set lower, toward the scene | `PageFit.balancedOffset`, `ReaderPageLayout.balancedOffset`, `ReaderColumn` | 42% of the column's free space above the text, never more than half the extra height; both columns move together; computed from the measured paragraphs, so it cannot push text under chrome |
| The folded picture takes 40% of a tall screen's extra height | `PageFit.foldedPictureHeight`, `ReaderMetrics` | An iPhone 17 Pro Max: about 435 pt of picture instead of 346, and more room for words as well (page 1 of the Low story fits on one screen) |

**2. Folded iPhone uses the whole screen**

| Item | Where | Notes |
|---|---|---|
| `-OmramoPosture folded` on a phone is the real window | `SimulatedDuoProvider` | The resolver is unchanged (its tests still describe the letterboxed reference pane, which a wide window still gets) |
| Real phone, no argument | unchanged | Already edge to edge; now with the taller picture band above |

**3. Motion** (all values in `Motion.swift`; described in `docs/DESIGN.md` §3.7)

| Item | Where | Notes |
|---|---|---|
| Page turn: words slide and fade, the picture drifts less, forward and back mirror | `AnyTransition.pageText` / `.pageScene`, `ReaderPage.turn`, `ReaderModel.pageToken` / `turnDirection` | The text column's identity is a token that changes once per turn. A reversal sets the direction first and turns 20 ms later, so the leaving words use the mirrored transition |
| No re-trigger during a turn | `ReaderModel.beginTurn`, `isTurning` | Set by the controls only; the model's own page functions stay immediate |
| Press response and light haptic | `PressScaleButtonStyle`, `.sensoryFeedback` on `pageToken` | Reduce Motion: a dim instead of a shrink |
| Card grows out of its word and folds back into it | `AnyTransition.cardReveal`, `WordBloomModifier`, `ReaderPage.cardAnchor`, `CardOrigin` | The word's rectangle is captured in window coordinates when it is tapped |
| Library cover → reader, and back | `HeroModifier`, `AnyTransition.hero`, `AppRouter.heroRect`, `HeroSourceModifier`, `RootScreens` | The library stays laid out under the reader (not hit-testable, hidden from assistive technology) |
| Reduce Motion | `Motion.page/card/hero(reduceMotion:)` | Cross-fades only |
| Pictures cached while they move | `cachedArt()` (`drawingGroup`) in `StoryArt.swift` | |

**4. One art direction** — `docs/ART_DIRECTION.md`, `ArtStyle.swift`, all painters re-worked;
`ART_PLACEHOLDERS.md` lists what changed and what is known to fall short.

**5. Library side column (the M4 subset)**

| Item | Where | Notes |
|---|---|---|
| Reading log: day, story, page — never a time | `ReadingDay`, `PageRead`, `ReadingLogFile` (core, `Progress/ReadingLog.swift`), `ReadingLogStore` (`reading-log.json`) | One entry per forward turn that leaves a page, and one for the last page when a story is finished. Days are stored as year / month / day numbers |
| Streak | `StreakCalculator`, `StreakSummary` | A day counts when at least one page is read. Before today's first page the run that ended yesterday still stands. No words for a missed day |
| Shelf | `ShelfState`, `ShelfCard` | "Keep reading" row (cover, title, page x of y) — one large button that opens the story at the saved place; finished covers with ticks; a summary line |
| Friends you have met | `FriendMet`, `FriendsSection`, `FriendChip` | From the existing friends-met memory; face chips with short names |
| Streak chip and card, finished ticks on covers | `StreakChip`, `StreakCard`, `FinishedTick`, `StoryCardView` | |
| One pane (phone, folded) | `LibraryScreen` | "Keep reading" on top as before; the streak card and friends follow the map |
| Empty states | each card | "Your reading days", "Stories you start will wait here, with your place kept.", three empty circles and "Friends you meet in stories will wait here." |

**6. Tapping words** — every marked word is a real button of at least 44 × 44 pt with the
identifier `word.<cardID>` (`MarkButtons`, `HitTargets` in the core); cards are
`card.<cardID>`; if the text layout is ever not reported, the paragraph opens its first marked
word instead of being dead. `WordTapTests` (above).

**7. Round-3 screenshots** — `ShotTests` (above).

**Tests added in round 3**

- Core (`swift test`): `Round3Tests.swift` — `PageFitTests` (11), `HitTargetTests` (12),
  `ReadingDayTests` (6), `ReadingLogTests` (14), `ShelfAndFriendsTests` (7): 50 test methods
  on top of the 197. Criterion 4.3 is covered by `testADayCountsWhenAtLeastOnePageIsRead`,
  `testStreakAcrossMidnight`, `testAMissedDayStartsAgainQuietly`,
  `testATimeZoneChangeNeverBreaksOrInventsADay`, `testAStreakRunsAcrossAWeekBoundary` and
  `testAPageIsCountedOncePerForwardTurn`. None has been run.
- App (⌘U): `App/Tests/Round3Tests.swift` — `PageFitAppTests`, `FoldedSimulationTests`,
  `ReadingLogAppTests`, `RouterAndLaunchTests` (24 test methods). None has been run.
- UI (`OmramoShots` scheme): `WordTapTests` (7), `ShotTests` (14).
- Python: unchanged, 62 tests, run on the box and passing.

### Implemented in round 4 — polish (code complete, **not yet compiled or seen**)

**1. Illustration pass** — every painter under `App/Sources/Art/` re-worked toward
illustration (`docs/ART_DIRECTION.md` §3a, §5a; new helpers `ArtStyle.form`, `rimEdge`,
`atmosphere`): Urashima and Otohime redrawn at 3 heads; the Anansi climb scene and the Skytree
relit from the upper left; `see-river-bank` and `see-forest` given one centred subject (and
three more tap-to-see pictures and two landmarks re-framed); the crocodiles' eyes back to
locked screen 03; **thirteen folded scenes composed for the phone's band** instead of cropped;
every unfolded scene **recomposed for a tall window** (horizon up to 64–70% of the height,
subject and planes grown) and for a squat one; the Urashima sea brought under both panes to
fill the empty lower-left. What changed per picture and what still falls short:
`Content/ART_PLACEHOLDERS.md`. The reader keeps the words out of the picture's part of the
pane to match (`ReaderMetrics.pictureReserve`; Urashima's pages now carry
`textArea.leadingBottom` 470). **None of it has been rendered.**

**2. Unfolded iPhone** — `-OmramoPosture unfolded` fills the window (§4): the one
`PaneLayoutResolver` gained a filled variant of the simulation (`PaneLayoutInput
.simulationFillsWindow`, side safe-area insets, a 12 pt gutter) and `PaneLayout` a
`minimumReferenceScale` (the design is not shrunk below what a 520 pt-tall pane would give) and
`isSquat`. The letterboxed reference canvas is unchanged and still reachable
(`-OmramoPosture reference`); the core tests that pin it are untouched.

**3. The folded card no longer covers the tapped line** — `CardSheet` is a partial sheet
(60% of the pane; `PageFit.foldedCardHeight`) with no scrim; the page slides up, as one
transform, until the tapped line is 14 pt above the card (`PageFit.foldedLineShift`, from the
word's own rectangle, or from the paragraph's measured place when the card was not opened by
a tap); the paragraph keeps its beam and marker, the others dim. `docs/DESIGN.md` §5.9a.

**4. Story-finished moment** — `StoryFinishedView` over the last page: cover with a tick, a
soft glow and seven sparks (once), "The end", the title, the story's **moral** (new optional
`Story.moral`, required by both validators as rule `moral-incomplete`: one sentence of at most
120 characters; all three stories have one), "Next story" (primary, 56 pt; chosen by
`NextStory` in the core), "Read again", "Library". The story is recorded finished, with its
last page, when the button is pressed. `docs/DESIGN.md` §6 "Story finished".

**5. Splash and app icon** — `SplashView` (screen 01's wordmark across the hinge on two panes,
one line on one pane; 0.65 s + a 0.3 s cross-fade; launch-screen colour `LaunchBackground`).
App icon: `docs/brand/app-icon.svg` → `tools/make_app_icon.py` (headless Chrome + Pillow) →
`App/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png` (1024 × 1024, RGB, no
alpha; one universal size) and `docs/brand/app-icon-1024.png`;
`ASSETCATALOG_COMPILER_APPICON_NAME: AppIcon` in `project.yml`.

**6. "Aa" panel and back controls** — the finished panel (live preview line, five sizes in one
track with 52 pt buttons, the sound switch, the bookmark row); a "Library" capsule with a
house in place of the bare back chevron; a 46 pt round previous-page arrow beside the page
chip. `docs/DESIGN.md` §5.1a, §5.1b, §5.2a.

**7. Optional sound** — two short sounds synthesised by `tools/make_sounds.py`
(`App/Resources/Sounds/page-turn.wav`, `card-open.wav`; no samples from anywhere),
`ReaderSound` (AVAudioPlayer; audio session `.ambient`, so the silent switch applies and other
audio is not interrupted; no session is opened unless sounds are on), **off by default**, a
switch in the "Aa" panel, remembered in `reader-memory.json` (`soundOn`, optional).

**8. Motion demos** and **9. round-4 screenshots** — `MotionDemoTests`, `ShotTests` (§4).

**Tests added in round 4 (none run)**

- Core (`swift test`): `Round4Tests.swift` — `FilledSimulationTests` (10), `FoldedCardFitTests`
  (6), `MoralTests` (7), `NextStoryTests` (7), `SoundSettingTests` (2): 32 test methods on top
  of the 247.
- App (⌘U): `App/Tests/Round4Tests.swift` — `UnfoldedSimulationAppTests` (5),
  `StoryFinishedTests` (5), `Round4LaunchTests` (5), `Round4ControlTests` (2), `SoundTests`
  (4): 21 test methods on top of the 52.
- UI (`OmramoShots` scheme): `MotionDemoTests` (4); `ShotTests` now 25 tests (was 14),
  writing `r4-*.png`.
- Python: still 62 tests, passing on the box. One assertion was **updated, not weakened**:
  `test_urashima_is_advanced_with_text_on_both_panes_and_a_wave` now expects
  `{"leadingBottom": 470, "trailingBottom": 420}` on every Urashima page (it pinned
  `{"trailingBottom": 420}`); the change of content is intended (goal 1, the sea under both
  panes). The new rule `moral-incomplete` is covered by the Swift tests and by the
  same-rule-codes test; no Python test was added, to keep the count the brief names.
- No existing Swift test was edited. `FoldedSimulationTests.testUnfoldedSimulationIsUnchanged`
  (round 3) still holds as written — the provider still asks for the unfolded simulation and
  the posture is still unfolded — although the layout behind it now fills the window.

### Implemented in round 5, batch 1 — the stories round (code complete, **not yet compiled or seen**)

Batch 1 of three (18 Nov 2026, branch `feat/r5-stories`, cut from `main` after round 4 was
compiled and merged as PR #5). Conventions for batches 2 and 3: `docs/agent-runs/r5-batch-notes.md`.

- **Tagline.** "Turn the page. See the world." (`Brand.tagline`; the splash halves are cut
  after the first sentence: "Turn the page." | "See the world."; README line 1).
- **Morals.** One short sentence a story (at most 14 words for Low, 18 for Medium and
  Advanced, no semicolon). Monkey unchanged; Anansi and Urashima reworded.
- **Ten new Low stories** in plan order after the Monkey story — `shipwrecked-sailor`,
  `tongue-cut-sparrow`, `old-man-who-moved-mountains`, `why-possums-tail-is-bare`,
  `the-snow-house` (an Omramo original), `peasant-and-bear`, `bremen-town-musicians`,
  `north-wind-and-sun`, `why-sun-and-moon-live-in-sky`, `lion-and-hare` — each 12–14 pages in
  two parts, four scenes, three tap-to-see words, the plan's landmark moments, two character
  cards, a one-sentence moral, the `education` block and a manuscript. The catalog now holds
  13 stories (`catalogVersion` 3).
- **Authoring.** Each new story is built from a spec, `docs/content/story-specs/<id>.json`,
  by `tools/build_stories.py` (writes `story.json`, the manuscript, and merges new landmarks);
  `--check` fails when a generated file is stale. `tools/test_build_stories.py` (19 tests).
- **Ten landmarks** added to the shared catalog (14 now), each with fact cards for the three
  tiers and its own picture: `sydney-opera-house`, `himeji-castle`, `great-wall-of-china`,
  `machu-picchu`, `hagia-sophia`, `saint-basils-cathedral`, `bremen-town-hall-roland`,
  `colossus-of-rhodes` (lost: a reconstruction), `statue-of-liberty`, `petra`.
- **Cultural-review flag.** `CulturalReview.needsReviewBeforeRelease` / `releaseFlagLine`
  ("Needs cultural review before release — <reviewer>: <reason>"); new rule
  `cultural-review-no-community` in both validators (a required review must name its
  reviewer). Flagged in the catalog: Monkey, Possum, Snow House, Sun and Moon, Lion and Hare,
  Anansi (six of the plan's twelve; the other six arrive in batches 2 and 3).
- **Illustration kit.** `App/Sources/Art/Kit/` (`enum Kit`, ten files, about 8,200 lines):
  frames for every picture shape, light / sky / land / water, `Kit.solid`, people, animals,
  birds, trees, ground cover, buildings, props (`docs/ART_DIRECTION.md` §11). The ten story
  painters are under `App/Sources/Art/Stories/` (one enum a story, four files each) and the
  ten landmark pictures under `App/Sources/Art/Landmarks/`.
- **Art registry.** `ArtLibrary.storyPainter(for:)` in `StoryArt.swift`: one line a story; a
  story without a painter, or an unknown picture name, gets the calm stand-in.
- **Library for a big catalog.** "All" shows one shelf a level (a header with the level and
  its count, covers scrolling sideways, loaded lazily); a chosen level shows all of its covers
  in a grid, three to a row at the design width (`Library.shelves(matching:)`, `LibraryShelf`
  in the core). Every card has one height. The story map names only the story being read once
  there are more than six pins, draws it last, and leaves out a "more cultures later" ring
  where a story has arrived (`StoryMapRules`).
- **Next story.** `NextStory` is unchanged: with eleven Low stories a reader is led through
  their own level in catalog order before the next level (tests on the whole catalog).
- **Screenshots.** `ShotTests` gains `testR5…` methods writing `r5-*.png` (§7d); the round-4
  methods still write `r4-*.png`.

**Tests added (none run):** core `Round5Tests.swift` — `CatalogPlanTests` (12),
`LandmarkPlanTests` (4), `CulturalReviewFlagTests` (5), `LibraryShelfTests` (3),
`StoryMapRulesTests` (3), `NextStoryCatalogTests` (3); app `App/Tests/Round5Tests.swift` —
`StoryArtRegistryTests` (6), `BiggerLibraryTests` (6); UI `ShotTests` `testR5…` (17); Python
`tools/test_build_stories.py` (19, run on the box: pass).

**Existing tests updated because the catalog grew (intended changes; nothing weakened):**
`DecodingTests.testLibraryLoadsAndListsTheSample` (counts follow the catalog; eleven Low
entries); core `Round4Tests` — `testEveryBundledStoryHasAMoralOfOneSentence` (every story, all
morals different) and the `NextStoryTests` helper (its catalog is the three prototypes, one a
level, as when it was written); `ReaderCardTests` — `PrototypeContent.allStories()` now means
the three prototypes (not every planned story has a landmark, by design); app `Round4Tests`
— `testTheTaglineSplitsAtTheHinge` (new wording) and
`testTheNextStoryComesFromTheCatalogAndTheLog` (the three-prototype catalog); Python
`test_catalog_lists_one_story_per_tier` (the prototypes within the bigger catalog). Any
further edits made by the review pass are listed in the round-5 entry of
`docs/AGENT_HANDOFF.md`.

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
| A2 / G4 | Round 4: the folded card is a 60% sheet and the page slides so the tapped line stays visible above it (our design, unseen; DESIGN §5.9a). A paragraph taller than the gap above the card shows only its first lines |
| G1 | Round 4: a finished "Aa" panel (our design, unseen; DESIGN §5.2a) |
| G3 | Round 4: a "Library" capsule, a previous-page arrow and a story-finished moment (our designs, unseen; DESIGN §5.1a, §5.1b, §6). They change the look of locked screens 03–07 and 10 slightly — to confirm |
| i.1–i.5 | Thresholds and the 1.3 × cap are assumptions, untested on a simulator |
| Art | All pictures are concept art drawn in code, unseen; see `ART_PLACEHOLDERS.md` |

### Visual gaps versus `docs/design/` still open (criterion i.5 and the award bar)

1. **Nothing in this round has been rendered.** The first job on the Mac is a side-by-side of
   screens 03–07 and 10 in simulated-Duo mode, then the iPad sizes.
2. **Art:** the three "ported" scenes (`scene-river`, `scene-climb`, `scene-sea`) and the Rin
   Gin and Monkey cards should be close to the PNGs; every *new* composition (ten scenes, six
   tap-to-see pictures, five portraits, four landmarks, three covers) is unseen and will need
   art direction. Since round 4 all thirteen folded scenes are compositions of their own
   (`*Art+Folded.swift`) and every wide scene recomposes for tall and squat windows — all
   unseen. The design's SVG grain is approximated by a tiled noise overlay and light stipple.
3. **Type:** line breaks, hanging punctuation, "pretty" wrapping and word spacing are not
   matched; exact line height relies on `lineSpacing` arithmetic; the text-on-a-path letters
   are set one by one without kerning pairs.
4. **Glass:** material + tint is an estimate of the design's blur and saturation.
5. **Motion:** implemented in rounds 3 and 4 (`docs/DESIGN.md` §3.7). The round-4 additions
   (the story-finished moment, the splash, the folded page sliding under a card) are unseen;
   all values are our proposals.
6. **Hold state:** no inlet glow; the beam is the paragraph's height plus 8 pt above and
   below (the design source draws a fixed 66 pt band on screen 06 — matched approximately).
7. **iPad:** round 3 sets short pages lower and lets Low and Medium type grow on a 13-inch
   portrait screen (`PageFit`), and fills the library's trailing pane. Round 4 recomposes
   every scene for a tall window (the horizon rises, the picture grows) and keeps the words
   above the picture's part of the pane — by arithmetic only: whether a portrait page now
   reads as designed needs eyes, and a real portrait composition is an illustrator's job.
7a. **Unfolded on an iPhone (round 4):** the panes are squat (about 410 × 440 pt), so a Low
   page takes two or three screens and the scene is drawn at about 410–500 units of height, which no
   locked screen shows. It is a simulation aid, not a designed layout.
8. **Library:** covers are new code drawings; the Anansi and Urashima covers follow the brief
   (Anansi on the tree; Urashima in his boat), not the exact covers of screen 02.
9. **Page chip:** a page with continuation screens fills its coral dash step by step; this is
   an invention, not in the designs.

### Stubbed — marked `TODO(Mx)` in the code

| What | Where | Lands in |
|---|---|---|
| Sample gate, end-of-sample card, paywall, StoreKit: **every page of all three stories is readable** | `ReaderModel.turnPage` | M5 |
| "My shelf" and "Grown-ups" tabs are drawn but inert; no grown-up gate, no parent view, no week summary | `LibraryTabBar` | M4 (the reading log, streak, shelf card, finished ticks and friends row landed in round 3) |
| Map legend says "Read", but a finished story's pin does not yet look different | `StoryMapCard.swift` | M4 |
| Loading and error designs | `RootView`, `ContentFailureView` | M6 (page-turn, card and library motion landed in round 3; the splash, the story-finished moment, the app icon and optional sounds in round 4) |
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

## 7b. First-compile checklist for round 3

Nothing in round 3 has been compiled or seen. Work in this order.

1. `swift test --package-path Packages/OmramoCore` — 197 tests from before plus 50 in
   `Round3Tests.swift`. Fix the core first.
2. `python3 tools/validate_content.py` and `python3 tools/test_validate_content.py`
   (0 errors; 62 tests). No content changed this round.
3. `xcodegen generate` (new source files), then build the app. §8b says where errors are most
   likely. If an art file fights back, the quickest unblock is still to make that painter's
   `paint` return `false` for the picture and come back to it.
4. Run the app tests (⌘U): `App/Tests/Round3Tests.swift` and the existing suites
   (`ArtCoverageTests` draws every picture once).
5. iPhone simulator, no arguments: library and reader fill the screen. Then
   `-OmramoPosture folded`: the same — no black bars (goal 2).
6. iPad Pro 13-inch, portrait, each story: the text block should sit lower than in
   `r2-ipad-reader-monkey-portrait.png`, with Low and Medium type a little larger; nothing
   under any control (goal 1). Then 11-inch portrait and both landscapes.
7. Turn pages forward and back, quickly and slowly; open and close a card from a word on each
   pane and folded; open a story from "Keep reading", from a cover and from the shelf row and
   go back (goal 3). Repeat with **Reduce Motion** on (Settings ▸ Accessibility ▸ Motion):
   cross-fades only. Watch for a flash or a jump at the start of a reversed page turn and at
   the start of closing a story — both use a 20 ms two-step (§8b items 2 and 3).
8. Library: read a few pages, go back: streak chip and card, shelf row, friends, and — after
   finishing a story — the tick on its cover (goal 5). `-OmramoDemoState` shows them filled.
9. `WordTapTests`, then `ShotTests` on an iPad and an iPhone simulator (§4). Compare the
   `r3-*.png` set with `r2-*.png`.
10. Go through every picture against `docs/ART_DIRECTION.md` and the "to check" table in
    `ART_PLACEHOLDERS.md`: faces and portraits first.

## 7c. First-compile checklist for round 4

Nothing in round 4 has been compiled or seen. Work in this order.

1. `swift test --package-path Packages/OmramoCore` — the 247 from before plus 32 in
   `Round4Tests.swift`. Fix the core first (`PaneLayout.swift`, `PageFit.swift`,
   `MoralRule.swift`, `NextStory.swift`).
2. `python3 tools/validate_content.py` and `python3 tools/test_validate_content.py`
   (0 errors; 62 tests).
3. `xcodegen generate` — **required**: new source files, the `Sounds` folder, the app icon set,
   the `LaunchBackground` colour and the `ASSETCATALOG_COMPILER_APPICON_NAME` setting. Then
   build. §8c says where errors are most likely; the art files are by far the largest risk
   (about 11,800 lines, most of them rewritten). If a painter fights back, make its `paint`
   return `false` for that picture (a calm gradient stand-in is drawn) and come back to it.
4. ⌘U: `App/Tests/Round4Tests.swift` and the existing suites (`ArtCoverageTests` draws every
   picture once — a crash there is an inverted range or a bad index in a painter).
5. Launch on an iPhone: the splash (dark, the wordmark, under a second), then the library; the
   new icon on the home screen. `-OmramoShowSplash` holds it; add `-OmramoPosture unfolded` to
   see the wordmark across the hinge.
6. iPhone, a story, page 1: the "Library" capsule top left; tap "Aa" — the panel (preview
   line, five sizes, Sounds off); switch sounds on, turn a page, open a card; flip the silent
   switch (hardware) — silence. Turn a page: the previous-page arrow appears beside the page
   chip.
7. iPhone, tap `river bank`: the card rises to about 60% and the lead sentence slides to just
   above it, with its beam; "Back to my line" slides it back. Try a word low on the page and a
   word in a long paragraph; then with Reduce Motion.
8. `-OmramoOpenStory monkey-and-crocodile -OmramoOpenPage 14`, press the round button (twice
   if the page has two screens): the story-finished moment. "Read again", then finish again
   and "Next story", then "Library" (the cover carries its tick). `-OmramoOpenFinished
   <id>` for each story; on an iPad in both orientations.
9. `-OmramoPosture unfolded` on an iPhone: it turns to landscape and fills the screen — two
   panes, a thin black gutter, nothing under the Dynamic Island. Library, each story (a page
   takes two or three screens), a card. `-OmramoPosture reference` still gives the letterboxed
   canvas.
10. Art, in this order: the redrawn Urashima and Otohime; the Anansi climb scene's light; each
    story on an iPad in portrait (is the picture recomposed, do the words stay clear of it?);
    each story on an iPhone in portrait (the folded band); the tap-to-see cards; the
    crocodile's eye against `03-read-low.png`; the Urashima sea on an iPad in landscape.
    `ART_PLACEHOLDERS.md` lists what to look for.
11. `WordTapTests`, `MotionDemoTests`, then `ShotTests` on an iPad and an iPhone simulator
    (§4). Compare the `r4-*.png` set with `r3-*.png`.

## 7d. First-compile checklist for round 5, batch 1

Nothing of this batch has been compiled, run or seen. In order:

1. `python3 tools/build_stories.py --check && python3 tools/validate_content.py` (0 errors),
   `python3 tools/test_validate_content.py` (62), `python3 tools/test_build_stories.py` (19).
2. `swift test --package-path Packages/OmramoCore` — the round-4 suite plus `Round5Tests`.
   A failing content assertion names the story and the page.
3. `xcodegen generate` (**required**: about 60 new source files under `App/Sources/Art/Kit`,
   `Stories` and `Landmarks`), then build. Expect the first errors in the kit
   (`App/Sources/Art/Kit/*.swift`), then in the story painters. §8d lists the likely kinds.
   If one painter will not compile and time is short, comment its line out of
   `ArtLibrary.storyPainter(for:)` — that story then shows the stand-in — and go on.
4. ⌘U (the app tests, with `App/Tests/Round5Tests.swift`).
5. `WordTapTests`, then `ShotTests` with the `OmramoShots` scheme on an iPad and an iPhone
   simulator: `-only-testing:OmramoUITests/ShotTests` writes the `r4-*.png` set again and the
   new `r5-*.png` set: the library (all levels; with a reading history; the Low level's grid;
   folded and unfolded postures on the iPhone), page 1 of each of the ten stories (iPad
   landscape and portrait, iPhone portrait, folded and unfolded postures), pages 5, 9 and 12
   of each (the later scenes), six cards, one finished moment, the splash with the new
   tagline. About 150 files on an iPad and 110 on an iPhone; allow for the time.
6. **Look at the kit first**: `r5-*-reader-*` shots show `Kit.person` (Sailor, Sparrow,
   Mountains, Snow House, Peasant, Wind and Sun, Sun and Moon), `Kit.beast` (Possum, Peasant
   and Bear, Bremen, Lion and Hare), `Kit.bird` (Sparrow, Bremen), trees, houses and props. A
   fault there repeats in every story; fix the kit before judging a story, and before batch 2.
7. Check per story: is the sky behind the words pale on every page (dark ink is used
   throughout)? Is the subject on the trailing pane, on the ground, clear of the controls? Does
   the tall iPad portrait have a filled foot? Does the folded band hold the subject's face?
8. Check the library: three shelves on "All", the grid on "Low", the map with thirteen pins
   and only the story being read named; the hero transition into and out of a cover on a
   shelf that has been scrolled.

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

### 8b. Unverified in round 3

Nothing in round 3 was compiled. Most likely to need a fix, first:

| # | Item | File | If it fails |
|---|---|---|---|
| 1 | **The art painters after the art-direction pass** (every file under `App/Sources/Art/` was edited by hand): scope, `CGFloat` / `Double`, call signatures of the new `ArtStyle` helpers | `App/Sources/Art/` | Fix the reported line; or stub that picture |
| 2 | **Page-turn transition**: `.id(model.pageToken)` + `.transition(…)` on the text column inside a `ZStack`; whether the leaving words use the transition they were last drawn with (hence the 20 ms two-step on a reversal, `ReaderPage.turn`) | `ReaderScreen.swift` | If words leave the wrong way after a reversal, lengthen the delay; if nothing animates, check the `withAnimation` wraps the model change |
| 3 | **Hero transition**: `HeroModifier` (scale + offset + mask, `Animatable`), the library kept under the reader, `AppRouter.showLibrary` two-step | `Motion.swift`, `OmramoApp.swift`, `AppEnvironment.swift` | `AnyTransition.hero` → `.opacity` is a one-line fallback |
| 4 | `ViewModifier, Animatable` structs under complete concurrency checking (`animatableData` on a main-actor type) | `Motion.swift` | A warning in Swift 5 mode; mark `animatableData` `nonisolated` if the compiler asks |
| 5 | **Word buttons**: accessibility identifier and label on buttons inside `overlayPreferenceValue(Text.LayoutKey.self)`, with the paragraph itself an `.ignore` element underneath; whether XCUITest sees `word.<id>` | `StoryText.swift` | Query by label ("Show picture: …") instead; or move the identifier |
| 6 | `card.<id>` on a `GeometryReader` with `.accessibilityElement(children: .contain)`; `app.buttons["Back to my line"]` | `StoryCards.swift`, `WordTapTests.swift` | Put the identifier on the card's title instead |
| 7 | `.sensoryFeedback(.impact(weight: .light, intensity: 0.7), trigger:)`; `ViewThatFits`; `onGeometryChange` reporting cover frames in `.global` space | `ReaderScreen.swift`, `LibrarySideCards.swift` | Fix from the documentation |
| 8 | `drawingGroup()` over a `Canvas` with a soft-light grain overlay (does the blend survive flattening? is a full-screen iPad scene within the texture limit?) | `StoryArt.swift` (`cachedArt`) | Remove `cachedArt()` from the scene only |
| 9 | Word bloom rectangle and card anchor use window (`.global`) coordinates; correct only because `PaneLayoutReader` ignores the safe area and fills the window | `ReaderScreen.swift`, `StoryText.swift` | Use a named coordinate space on `TwoPane` |
| 10 | `PageFit` numbers (42% optical share, half the extra height, 40% of a folded screen's extra to the picture, the measures per tier, 0.5 em average character) are estimates | `PageFit.swift` | Tune by eye; the tests state the rules, not the taste |
| 11 | The `@Observable` composition root assigns its stores in `#if DEBUG` branches | `AppEnvironment.swift` | Assign defaults first, then override |

### 8c. Unverified in round 4

Nothing in round 4 was compiled. Most likely to need a fix, first:

| # | Item | File | If it fails |
|---|---|---|---|
| 1 | **The art painters** — most of `App/Sources/Art/` was rewritten by authors with no compiler and no renderer: type-checker time on long arithmetic, `CGFloat` / `Double` slips, locals shadowing helpers, nested `inout GraphicsContext` closures, `Stage` structs. Scripts confirmed balanced braces, no duplicate declarations and correct argument labels on every `Art.*` / `ArtStyle.*` call; types were checked by reading only | `JatakaArt*`, `AnansiArt*`, `UrashimaArt*`, `LandmarkArt*` | Split the reported expression into typed `let`s; or return `false` from `paint` for that picture |
| 2 | `GraphicsContext.clipToLayer` used as a mask (`ArtStyle.rimEdge`; `UrashimaArt.leadingMist`) | `ArtStyle.swift`, `UrashimaArt.swift` | Replace the body of `rimEdge` with a plain clipped stroke; drop the mask in `leadingMist` |
| 3 | **Folded card**: `.offset(y:)` on the picture-and-words group while the card's overlay rises; whether the word rectangle (window coordinates, captured at the tap) puts the line where the arithmetic says; whether the clear layer above the card really swallows touches | `ReaderScreen.swift` (`ReaderFoldedPane`, `ReaderPage.foldedShift`), `StoryCards.swift` (`CardSheet`) | Fall back to the paragraph's measured place (`blockSpan`) by ignoring `wordRect` in `heldLine` |
| 4 | **Story-finished overlay**: an `.overlay` with a transition on the reader's `TwoPane`, a second `TwoPane` inside it, `.allowsHitTesting(false)` on the page beneath, `.sensoryFeedback(.success, …)`, `AccessibilityNotification.ScreenChanged` | `ReaderScreen.swift`, `StoryFinishedView.swift` | Remove the transition first; then the feedback |
| 5 | **Splash**: `@State` initialised from `SplashView.plan()`, a `.task` that sleeps and then animates the removal, text filled with a `LinearGradient` (`foregroundStyle`), the 158 pt variable-font wordmark scaled per pane | `OmramoApp.swift`, `SplashView.swift` | Shorten to a plain fade of a solid colour; fix sizes by eye |
| 6 | `UILaunchScreen` → `UIColorName` `LaunchBackground`; the single-size `AppIcon.appiconset` (`"idiom": "universal", "platform": "ios", "size": "1024x1024"`) with XcodeGen and Xcode 26 | `Info.plist`, `Assets.xcassets`, `project.yml` | Xcode will say what the icon set lacks; add the sizes it names |
| 7 | **Sound**: `AVAudioSession.setCategory(.ambient, mode: .default, options: [.mixWithOthers])`, `AVAudioPlayer` kept in a `@MainActor` singleton; WAV files found by `Bundle.main.url(forResource:withExtension:)` (XcodeGen must copy `App/Resources/Sounds/*.wav` flat into the bundle) | `Sound.swift`, `project.yml` | `SoundTests.testBothSoundsAreBundledAndSilentWhenOff` says if the files are missing; sounds are off by default, so nothing else depends on them |
| 8 | Filled unfolded simulation on a real iPhone: `requestGeometryUpdate(.iOS(interfaceOrientations: .landscape))` at launch, safe-area insets read in landscape, panes starting at x = 62 | `OmramoApp.swift`, `PaneLayoutReader.swift` | Pass `-OmramoOrientation landscape` and rotate the simulator by hand |
| 9 | `ReaderMetrics.pictureReserve`: a nested function inside `init` before every stored property is set (it captures only locals); the 37% tall-pane share and the proportional text area are estimates | `ReaderLayout.swift` | Inline the function; tune `tallSceneShare` by eye |
| 10 | `.accessibilityAddTraits(.isToggle)` (iOS 17+); `SpeakerShape`; the panel's 260-reference-point rows (about 288 with its padding; never under 5 × 48 pt) on the smallest phone, and its height on a squat pane once the bookmark row shows | `ReaderChrome.swift` | Drop the trait; scale the panel |
| 11 | XCUITest: `finished.moment` and `splash` identifiers on containers (`.accessibilityElement(children: .contain / .ignore)`); `XCUIDevice.shared.orientation = .landscapeLeft` on an iPhone together with the app's own request for landscape | `MotionDemoTests.swift`, `ShotTests.swift` | Put the identifier on the title text instead |
| 12 | `NextStory.suggestion` compares `(Int, Int, Int)` tuples with `<` (standard library, up to six elements) | `NextStory.swift` | Write the comparison out |

Not verifiable at all without hardware: everything about the real Duo (pane sizes, hinge,
posture API, per-pane safe areas). The app does not reference any Duo API.

### 8d. Unverified in round 5, batch 1

- **The whole kit** (`App/Sources/Art/Kit/`, about 8,200 lines) and **every story painter and
  landmark picture** of the batch: written blind, checked by script (brackets, duplicate
  declarations, the argument labels of every call into the art types) and by "be the compiler"
  reading passes. Likely compile errors, most likely first: a `CGFloat` / `Double` mix; an
  expression too long for the type-checker ("unable to type-check this expression in
  reasonable time": split it into typed `let`s); a wrong enum case or property name on a kit
  type; an unqualified call shadowed by a parameter of the same name (`Kit+Buildings.swift`
  calls `Kit.wall` / `Kit.roof` from functions with parameters named `wall` and `roof`); a
  closure drawing on the outer `context`; `Path.strokedPath` / `trimmedPath` uses in
  `Kit+Beasts.swift`, `Kit+PeopleBody.swift` and two landmark files.
- `ArtLibrary.storyPainter(for:)` returns function references such as
  `SailorArt.paint(_:role:in:size:)` as `ArtPainter` values (a function type with an `inout`
  parameter). If the compiler objects, write each case as a closure:
  `return { name, role, context, size in SailorArt.paint(name, role: role, in: &context, size: size) }`.
- **Proportions and faces of `Kit.person`, `Kit.beast`, `Kit.bird`** — never rendered.
- **Cost.** Thirteen covers are rasterised on the library (lazily per shelf); each new scene
  is one `Canvas` of several hundred to about 1,500 calls, rasterised once. Watch the first
  open of a story and the first scroll of the Low shelf on a real device.
- **Library.** `LazyHStack` inside a horizontal `ScrollView` inside the vertical one; the hero
  frame of a cover that has scrolled off its shelf (the router keeps the last reported frame);
  the `LazyVGrid` column count on a narrow window; XCUITest tapping "Level: Low".
- **Story text on real pages.** The new Low pages are 35–64 words; the Monkey story's are
  similar, but nobody has seen these pages at the five text sizes or on a squat pane.
- **Facts.** Ten new landmark entries and thirty tap-to-see notes: `review.facts` pending.
  The source check (18 Nov, on a Gutenberg mirror) is recorded in each manuscript header.

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
  `Omramo/reading-progress.json` (reading position per story: page and paragraph),
  `Omramo/reader-memory.json` (text-size step, one bookmark per story, which tap-to-see and
  character cards have been seen, which characters have been met) and, since round 3,
  `Omramo/reading-log.json` (which page of which story was read on which calendar day —
  three numbers for the day, never a time — and which stories were finished; entries older
  than 400 days are dropped and only counted).
- The streak never pressures: there is no countdown, no reminder, no notification and no
  wording for a missed day (a unit test checks the card's words).
