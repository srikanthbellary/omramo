# Omramo

A magical book that you read. Omramo is a global English, illustration-driven story reader for children who can already read, built natively in Swift (SwiftUI) for the two-pane **iPhone Duo**, with a folded single-screen mode.

Sunrise Gen AI LLC · private · `omramo.com`

## What it is

- **Reading is the product.** No video, no narration, no autoplay. A page turns only when the child presses the button.
- **Three tiers:** Low, Medium, Advanced. Each story belongs to exactly one.
- **Tap-to-see:** tap a marked word and a visual opens on the facing pane; one button returns to the same line. Character cards work the same way.
- **Stories from the world's cultures**, each with its place on the map. Prototype set: a Jataka tale (ancient India), an Anansi story (Akan, Ghana), Urashima Taro (Japan).
- **For parents:** pages read, never screen time. No ads, no tracking, no data collected.
- **Free sample, then a family subscription** (StoreKit 2), with purchases behind a grown-up gate. Price: TBD.

## Status

v2 design is approved and locked (13 Nov 2026). Milestone 1 of the implementation plan is **code complete but unverified**: it was written on a Linux box with no Swift toolchain, so no Swift file has been compiled yet. The first build on a Mac is the next step (see [`docs/BUILD.md`](docs/BUILD.md)).

M1 contains the XcodeGen project, the pure-Swift core package with the content model and validator, one sample story (*The Monkey and the Crocodile*, Low tier, our own draft retelling with placeholder art), the design system, and the Library and Reading (Low) screens. Tap-to-see, character cards, the parent view and the subscription are later milestones.

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

To see the two-pane Duo layout on an ordinary simulator, run a Debug build in landscape with the launch argument `-OmramoPosture unfolded`. Details, the first-compile checklist and the list of unverified items are in [`docs/BUILD.md`](docs/BUILD.md).

| Path | Contents |
|---|---|
| `project.yml`, `Configuration/` | XcodeGen project definition and build settings |
| `App/` | The SwiftUI app target (sources, fonts, assets, tests) |
| `Packages/OmramoCore/` | Pure-Swift core: content model, validator, layout maths, design tokens, bundled sample content, tests |
| `tools/` | Content validator and its tests (Python) |

## Screens

![Reading, Low tier](docs/design/03-read-low.png)
