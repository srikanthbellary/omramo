# Omramo

Turn the page. See the world. Omramo is a global English, illustration-driven story reader for children who can already read, built natively in Swift (SwiftUI) for the two-pane **iPhone Duo**, with a folded single-screen mode.

Sunrise Gen AI LLC · private · `omramo.com`

## What it is

- **Reading is the product.** No video, no narration, no autoplay. A page turns only when the child presses the button.
- **Three tiers:** Low, Medium, Advanced. Each story belongs to exactly one.
- **Tap-to-see:** tap a marked word and a visual opens on the facing pane; one button returns to the same line. Character cards work the same way.
- **32 stories from the world's cultures**, each with its place on the map: one story in every one of ten regions at every tier (Indian, Egyptian, Japanese, Chinese, Native American / First Nations, Arctic, Russian, European, African, Persian / Arabian), plus two more European (Greek) stories — 11 Low, 11 Medium, 10 Advanced. 29 are our own retellings of public-domain tales and 3 are Omramo originals; 37 world landmarks are woven in as tap-to-see moments ([`docs/CONTENT_PLAN.md`](docs/CONTENT_PLAN.md)). Twelve stories carry the flag "needs cultural review before release".
- **For parents:** pages read, never screen time. No ads, no tracking, no data collected.
- **Free sample, then a family subscription** (StoreKit 2), with purchases behind a grown-up gate. Price: TBD.

## Status

v2 design is approved and locked (13 Nov 2026). **Milestone 1** compiled and launched on a Mac (Xcode 26.6) on 13 Nov 2026. **Milestones 2, 3 and Mi** (complete reader, tap-to-see / character / landmark cards, iPad layout) and **polish round 3** (page fit, motion, art direction, the library's side column) build, run and pass their tests on the Mac. **Polish round 4** (illustration pass, the unfolded iPhone, the folded card, the story-finished moment, splash, app icon, the "Aa" panel, optional sounds) is **code complete but not yet compiled or seen**: it was written on a Linux box with no Swift toolchain. Round 4 was then compiled, run and merged on the Mac. **Round 5, the stories round** (18 Nov 2026, three batches on branch `feat/r5-stories`) completes the catalog — 29 new stories, 33 new landmarks, a shared illustration kit and the library for a 32-story catalog — and is **code complete but not yet compiled or seen**, written on the same Linux box. Compiling it on the Mac is the next step (see [`docs/BUILD.md`](docs/BUILD.md) §7d–§7f).

The repo contains the XcodeGen project, the pure-Swift core package (content model, validator, paging, layout), the full launch catalog of 32 draft stories (our own retellings and originals; texts, art, facts and cultural review all pending) with concept art drawn in code, the design system, the Library and the reader. The parent view, the grown-up gate, the sample gate and the subscription are later milestones.

## Documents

| Document | Contents |
|---|---|
| [`docs/PRD.md`](docs/PRD.md) | Product requirements, features and priorities, metrics, risks, open questions |
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | Modules, Duo pane abstraction, story format, StoreKit, privacy, accessibility, testing |
| [`docs/DESIGN.md`](docs/DESIGN.md) | Design tokens, type scale, components, specs for all 12 screens |
| [`docs/IMPLEMENTATION_PLAN.md`](docs/IMPLEMENTATION_PLAN.md) | Milestones M1–M8 with acceptance criteria |
| [`docs/CONTENT_PLAN.md`](docs/CONTENT_PLAN.md) | Launch story catalog and landmarks (proposal) |
| [`docs/BUILD.md`](docs/BUILD.md) | How to build and run, what is stubbed, and what is unverified |
| [`docs/design/`](docs/design/) | The 12 locked screenshots |
| [`docs/PRODUCT.md`](docs/PRODUCT.md) | The earlier Telugu-first v1 lock. Superseded; kept for history |

## Build

Needs a Mac with Xcode 16 or later. The Xcode project is generated from `project.yml` and is not committed.

```sh
swift test --package-path Packages/OmramoCore   # core tests (also runs on Linux with Swift 5.9+)
python3 tools/validate_content.py               # content check (Python 3, no dependencies)
brew install xcodegen                           # once
xcodegen generate                               # writes Omramo.xcodeproj
open Omramo.xcodeproj                           # scheme Omramo, any iPhone simulator on iOS 18+
```

To see the two-pane Duo layout on an ordinary simulator, run a Debug build with the launch argument `-OmramoPosture unfolded` (two panes over the whole screen; an iPhone turns itself to landscape), or `-OmramoPosture reference` in landscape for the letterboxed 892 × 720 canvas of the locked screens. Details, the first-compile checklist and the list of unverified items are in [`docs/BUILD.md`](docs/BUILD.md).

| Path | Contents |
|---|---|
| `project.yml`, `Configuration/` | XcodeGen project definition and build settings |
| `App/` | The SwiftUI app target (sources, fonts, assets, tests) |
| `Packages/OmramoCore/` | Pure-Swift core: content model, validator, layout maths, design tokens, bundled sample content, tests |
| `tools/` | Content validator and its tests (Python) |

## Screens

![Reading, Low tier](docs/design/03-read-low.png)
