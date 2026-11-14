# Omramo — Implementation plan (v2)

**Reads with:** `docs/PRD.md`, `docs/ARCHITECTURE.md`, `docs/DESIGN.md`.
**No dates are given.** Order and dependencies are fixed here; the calendar is Srikanth's to set (TBD — open question).

## 0. Ground rules

1. **Phase 1 (this change) is documents only.** No app code.
2. **The development box is Linux with no Swift toolchain and no Xcode.** Code written there cannot be compiled or run. Until a Mac is in the loop:
   - Swift code is **checked by inspection** against the acceptance criteria marked *[inspect]*.
   - Criteria marked *[Mac]* are verified the first time the project is built on a Mac, following `docs/BUILD.md`. A milestone is "code complete" after *[inspect]* and "done" only after *[Mac]*.
   - Content and anything checkable with Python or by reading is verified on the box (*[box]*).
3. **The operator commits.** The build agent does not run state-changing git commands.
4. **No App Store Connect or submission steps are performed.** Where they are needed they are listed as *future owner actions*.
5. **No invented numbers.** Prices and other business values appear only as `TBD` or as test fixtures labelled "Example (not a decision)".
6. Each milestone ends with the 12 design screenshots as the reference: a screen is accepted when it matches its file in `docs/design/` in simulated-Duo mode, apart from deviations listed in the milestone.

## Milestone map

| # | Milestone | Depends on | Screens |
|---|---|---|---|
| M1 | Scaffold, core package, design tokens and fonts, content model, one Low story, Library and Reading (Low) | — | 02 (left pane core), 03 |
| M2 | Complete reader: all tiers, folded mode, position, overflow, text size | M1 + first Mac build | 04, 05, 10 |
| M3 | Tap-to-see and character cards | M2 | 06, 06b, 07 |
| M4 | Reading log, rewards, full library, grown-up gate, parent view | M2 | 02 (complete), 08 |
| M5 | Sample gating, subscription, StoreKit 2 | M4 (gate) | 09, 09b |
| M6 | Splash, motion, accessibility, privacy manifest, release hardening | M3–M5 | 01, all |
| M7 | Duo hardware and SDK hookup | Duo SDK + device (PRD Q4); can start any time after M2 | all |
| Mi | iPad two-pane and size classes | M2; can run in parallel with M3–M7 | — |
| M8 | Pilot build and owner hand-off (TestFlight is an owner action) | M6, M7, Mi | — |
| C1 | **Content production** (parallel workstream, not code): the global launch catalog and landmarks — writing, illustration, cultural review, legal review | PRD Q22–Q31; schema from M1 | — |
| Later | Downloadable packs, authoring tool, profiles | — | — |

M3, M4, M7 and Mi are independent of each other after M2 and can be reordered. C1 runs alongside the code milestones; it is the long pole for a public release.

---

## M1 — Scaffold, core, tokens, one story, Library and Reading (Low)

### Scope

1. **XcodeGen scaffold**
   - `project.yml`: app target `Omramo` (iOS 18.0, iPhone, SwiftUI life cycle, bundle id `com.omramo.app`), unit-test target, local package `Packages/OmramoCore`, `Content/` as a folder reference, `App/Resources/Fonts` as resources, `UIAppFonts` entries, scheme with launch arguments documented.
   - `Configuration/Base.xcconfig`, `Configuration/Brand.xcconfig`; `.gitignore` (generated `Omramo.xcodeproj`, `.build/`, `DerivedData/`, `*.local.xcconfig`).
2. **`OmramoCore` package** (Foundation only; folders per `docs/ARCHITECTURE.md` §4.1, M1 subset):
   - `Brand`, `FoldMark`.
   - `Model`: `Story`, `Tier`, `Region` (the ten-region `RegionID` enum plus `culture`, `place`, `label`, optional pin), `Setting`, `Provenance` (`publicDomainRetelling` with source citations, or `original`), `CulturalReview`, `Education` (geography, culture, moral), `Part`, `Spread`, `TextBlock`, `TextRun`, `TapTarget` (including `kind: landmark`), `LandmarkRef`, `FramingDevice`, `Character`, `ArtRef`, `StoryTheme`, `Catalog`, `Landmark`, `LandmarkCatalog`, typed IDs — as in `docs/ARCHITECTURE.md` §6.3 and §6.5.
   - `Content`: `StoryDecoder` with schema-version check, landmark-catalog decoding, `StoryValidator` (including the region, provenance, education and landmark rules and the anachronism rule), `ContentRepository`, `DirectoryContentRepository`, `ContentError`, `LoadState`.
   - `Layout`: `DisplayPosture`, `PaneLayout`, `PaneLayoutInput`, `PaneLayoutResolver`.
   - `Reading`: `ReadingPosition`, `Pager` (next/previous spread only; continuation screens come in M2).
   - `DesignTokens`: colours, tier colours, gradients as stop lists, radii, spacing, `ReadingTypeScale` (all three tiers, unfolded and the folded Low values), UI type roles — values from `docs/DESIGN.md` §3–4.
3. **Design system in the app**
   - Bundled fonts: `BricolageGrotesque.ttf`, `AtkinsonHyperlegibleNext.ttf`, `AtkinsonHyperlegibleNext-Italic.ttf`, `Inter.ttf`, and the three OFL licence texts, copied from `designs-v2/fonts/`.
   - `OmramoFont` (variable axes via Core Text), `Color` wrappers, glass style, round glass button, capsule control, chip variants, tier glyph, page dashes, page-turn button, primary button, card, cover, aurora backdrop (light), icon set ported from `base.js` as vector assets.
4. **Content**
   - `Content/catalog.json`.
   - `Content/sources/monkey-and-crocodile.txt` (the Babbitt text from `stories/text/`, with its source header).
   - `Content/stories/monkey-and-crocodile/story.json`: the **whole** story (Part I and Part II), Low tier, paginated into spreads of about 55 words, with lead sentences, voices, character names and the tap words shown in the designs ("river bank", "ripe fruit") marked. Text unaltered apart from typographic quotes and dashes (assumption A5). Tap-target and character-card entries may exist in the JSON, but their cards are not shown until M3.
   - The same `story.json` carries the new required metadata: `region` (`indian`; culture "Buddhist Jataka tradition"; place; pin), `setting`, `provenance` (`publicDomainRetelling`, Babbitt 1912, Gutenberg #62514, `textBasis: sourceVerbatim`), `culturalReview` (`required`, `pending`, with its reason) and `education` (geography, culture and moral lessons, with a reflection question). All lesson wording is placeholder copy marked for review.
   - `Content/landmarks/landmarks.json` with at least one landmark, `taj-mahal`, complete with all three tier fact cards (placeholder wording), and a placeholder picture in `Content/landmarks/art/`.
   - **The sample story references that landmark.** The Taj Mahal does not occur naturally in this tale (it was built about 2,000 years later, on another river), so the tap target is `kind: landmark` with `appearance: framed` and a `thenAndNow` framing device. It is attached to an existing word of the unaltered text ("river", on a spread other than page 1 if the editor prefers), so no wording changes. Like the other cards, it is not shown until M3.
   - Placeholder art: the concept river scene and ride scene rendered from the design sources by `tools/render_placeholder_art.py` (headless Chrome, already used by the designs) into the sizes in `docs/ARCHITECTURE.md` §7.2, plus face chips and a cover. Spreads may share a scene. Every image is labelled concept art in its alt-text review status (`review.art: pending`).
   - `tools/validate_content.py`.
5. **Screens**
   - **Library** (screen 02, M1 subset): wordmark, "Stories by level" filter (All / Low / Medium / Advanced, working), story cards from the catalog, "Keep reading" card when a position exists, tab bar drawn with only Library active. The right pane shows the story map card with real pins from the catalog; streak, shelf and friends cards are deferred to M4 (drawn empty-state or omitted — listed as a deviation).
   - **Reading, Low** (screen 03): scene across both panes, text on the leading pane with all word-level styles drawn (lead sentence, voice colour and face chip, name underline, tap-word highlight with underline and spark — visual only, not yet interactive), crumb, tier and origin chips, page chip, page-turn button moving through all spreads, back to the library, position saved and restored.
   - `PaneLayoutReader`, `TwoPane`, `DerivedPaneLayoutProvider`, `SimulatedDuoProvider` (`-OmramoPosture unfolded|folded`). In M1 the folded posture shows a simple single-pane reading layout (art on top, text below) without the full screen-10 polish, which lands in M2.
6. **Tests** (`OmramoCoreTests`): model decoding of the bundled story and of fixtures; rejection of a newer `schemaVersion`; rejection of unknown tier, dangling `tap` / `name` / `say` / `part` references, duplicate IDs, a run with both `tap` and `name`, missing alt text; text-fidelity check passes for the bundled story and fails for a fixture with a changed word; rejection of an unknown region id, an empty `region.culture`, a `publicDomainRetelling` with no source, an `original` with no premise, a missing education pillar, a required cultural review with no reason; landmark catalog decoding; rejection of a dangling landmark id, a landmark missing a tier fact card, a later-built landmark marked `natural`, an out-of-region landmark without a `worldLink` or `mapMoment` device, and a lost landmark not marked as a reconstruction; the fact card chosen for a Low story is the Low wording; `PaneLayoutResolver` cases; `Pager` next/previous and bounds; `FoldMark` derives OM | RA | MO; token checks (Low 23.5 / 37, Medium 19.5 / 32, Advanced 16.5 / 27; tier hex values).
7. **`docs/BUILD.md`**: prerequisites (macOS, Xcode version, `brew install xcodegen`), `xcodegen generate`, `swift test --package-path Packages/OmramoCore`, building and running the app, simulated-Duo launch arguments and which simulator to pick, running the Python content check, how to regenerate placeholder art, a "first compile checklist", and troubleshooting for fonts not loading.

### Not in M1

Tap-to-see interaction, character cards, landmark cards on screen (the data and validation are in M1; the card appears in M3), any story beyond the one sample, Medium and Advanced stories, text-size control, bookmark, streak/shelf/friends data, parent view, gate, StoreKit, splash animation, real Duo SDK.

### Deliverables

`project.yml`, `Configuration/`, `App/`, `Packages/OmramoCore/`, `Content/`, `tools/`, `docs/BUILD.md`, `.gitignore`.

### Acceptance criteria

| # | Criterion | How verified |
|---|---|---|
| 1.1 | `python3 tools/validate_content.py Content` exits 0; it exits non-zero on each invalid fixture | *[box]* |
| 1.2 | `story.json` contains the complete story; the fidelity check confirms the text equals `Content/sources/monkey-and-crocodile.txt` after quote/dash normalisation | *[box]* |
| 1.3 | Every image referenced exists at the declared pixel size; every ArtRef has alt text | *[box]* |
| 1.4 | The four font files and three licence texts are present under `App/Resources/Fonts` and listed in `UIAppFonts` | *[box]* |
| 1.5 | `OmramoCore` imports only Foundation; the app target has no third-party dependency; `project.yml` and `Package.swift` name no remote package | *[inspect]* |
| 1.6 | Token values in `DesignTokens` equal `docs/DESIGN.md` §3–4 (spot-checked line by line for colours, tier colours, reading scale) | *[inspect]* |
| 1.7 | No view reads a device model, a size class or a hardcoded 432/720/28; geometry comes from `PaneLayout` | *[inspect]* |
| 1.8 | Product name appears only via `Brand`; `Brand.xcconfig` agrees with it (a test asserts this) | *[inspect]*, *[Mac]* |
| 1.9 | `docs/BUILD.md` exists and its commands match the files in the repo | *[inspect]* |
| 1.10 | `xcodegen generate` succeeds and the project opens | *[Mac]* |
| 1.11 | `swift test` passes in `Packages/OmramoCore` (all tests in scope item 6) | *[Mac]* (or Linux with a Swift toolchain) |
| 1.12 | The app builds and launches in the simulator with zero warnings treated as errors off, and with no runtime font-fallback: the three families render (checked by the debug font list and by eye) | *[Mac]* |
| 1.13 | With `-OmramoPosture unfolded`, the Reading screen for page 1 matches `docs/design/03-read-low.png` for layout, type sizes and line breaks of the lead sentence; listed deviations only | *[Mac]* |
| 1.14 | The Library lists the story with its tier pill and origin; the level filter hides and shows it correctly; tapping it opens page 1 | *[Mac]* |
| 1.15 | The page-turn button reaches the last page; relaunching the app offers "Keep reading" at the saved page | *[Mac]* |
| 1.16 | On an ordinary iPhone simulator with no launch argument the app shows the single-pane layout and is usable | *[Mac]* |
| 1.17 | The `TextRenderer` approach (`docs/ARCHITECTURE.md` §8.2) is confirmed or the fallback decision is recorded in `docs/BUILD.md` | *[Mac]* |
| 1.18 | `story.json` contains `region`, `setting`, `provenance`, `culturalReview` and `education` exactly as specified in `docs/ARCHITECTURE.md` §6.3, and the validator fails on each of the invalid metadata fixtures | *[box]* |
| 1.19 | `Content/landmarks/landmarks.json` validates; the sample story has one `landmark` tap target that resolves to it, marked `framed` with a `thenAndNow` device; changing it to `natural` makes the validator fail | *[box]* |
| 1.20 | The Swift model types match the JSON field for field (`Region`, `Provenance`, `CulturalReview`, `Education`, `Landmark`, `LandmarkRef`, `FramingDevice`), and the Python and Swift validators list the same rules | *[inspect]* |

Known deviations allowed at M1: placeholder art; right-pane library cards incomplete; word spacing not applied; folded layout basic; no animations.

### Risks specific to M1

- Uncompiled Swift will contain errors. Mitigation: plain code, an explicit first-compile checklist, and core logic concentrated in the tested package.
- Variable-font axis names and ranges must be read from the font files on the Mac; the design uses `wght`, `wdth`, `opsz`.

---

## M2 — Complete reader

### Scope
- First Mac build fixes from M1.
- Medium and Advanced stories authored and validated (*Anansi*, *Urashima Taro*), with placeholder scenes rendered from the design sources; text on both panes for Advanced; `pathText` block.
- Per-story theme: light/dark chrome per pane, text colour, page-turn accent, tap colours.
- Folded reading to the standard of screen 10; posture change keeps the page and paragraph.
- Continuation screens for overflow; `Pager` extended; page indicator counts spreads.
- "Aa" text-size steps (interim panel pending design gap G1); bookmark stub or hidden per PRD decision.
- Sound words (`pop`), stretched words, face chips, final highlight shapes.
- A back-one-page control (pending design answer; interim: a small previous arrow as in the unused `.prev` style).

### Acceptance criteria
| # | Criterion |
|---|---|
| 2.1 | Screens 04 and 05 match their PNGs in simulated-Duo mode, including the amber and red page-turn variants, dark chrome on 04 and the text on a wave path on 05 *[Mac]* |
| 2.2 | Screen 10 matches its PNG in folded simulation (22.5 / 35 pt) *[Mac]* |
| 2.3 | Switching posture mid-story (debug toggle) keeps the same page; the paragraph that was first on screen is still visible *[Mac]* |
| 2.4 | At the largest text step no text is clipped or truncated on any spread of the three stories; extra text appears on a continuation screen with the same page number *[Mac]* |
| 2.5 | All three stories pass the validator, including text fidelity against their sources *[box]* |
| 2.6 | Unit tests cover `Pager` with continuation screens and `ReadingPosition` restore *[Mac]* |
| 2.7 | Every spread of every story can be reached and left using only the on-screen controls *[Mac]* |

---

## M3 — Tap-to-see and character cards

### Scope
- Tap words and names become interactive with ≥ 44 pt targets.
- `CardPlacement`; tap-to-see card and character card on the facing pane; hold state on the text pane (dimming, beam, place marker); close by "Back to my line" or ✕; return state with toast and "seen" style; seen state persisted; "friends met" recorded when a character's first naming run is displayed.
- Folded variant (assumption A2, pending gap G4).
- Card stays open and re-places itself across a posture change.
- Card content for the two designed examples (Rin Gin, the Monkey) plus at least one tap target per story; all concept wording flagged `review: pending`.
- Landmark card: the same tap-to-see card, filled from the landmark catalog in the story's tier wording, with the framing-device label and line in the note box and the reconstruction subtitle for lost wonders (`docs/ARCHITECTURE.md` §6.5). One landmark per prototype story (Example (not a decision): Taj Mahal, Asante Traditional Buildings, Tokyo Skytree, per `docs/CONTENT_PLAN.md` §6).

### Acceptance criteria
| # | Criterion |
|---|---|
| 3.1 | Screens 06, 06b and 07 match their PNGs *[Mac]* |
| 3.2 | The text pane does not move or re-wrap when a card opens or closes (pixel-identical text positions before and after) *[Mac]* |
| 3.3 | A card contains no control other than close and "Back to my line"; nothing on a card opens another card *[inspect]* |
| 3.4 | With text on both panes, the card covers the pane that does not contain the tapped word (unit test on `CardPlacement`) *[Mac]* |
| 3.5 | The page cannot be turned while a card is open *[Mac]* |
| 3.6 | After closing, the tapped word shows the seen style and still opens its card; state survives relaunch *[Mac]* |
| 3.7 | VoiceOver: a marked word can be opened by a custom action; focus moves to the card title and returns to the paragraph *[Mac]* |
| 3.8 | A landmark card uses the tap-to-see layout unchanged, shows the fact line for the story's tier, and shows the framing label when the landmark is framed (unit test on the card model; by eye on screen) *[Mac]* |

---

## M4 — Reading log, rewards, library, gate, parent view

### Scope
- `ReadingLog` (date, story, spread only — no times), `StreakCalculator`, `ShelfState`, `WeekSummary`; file-backed stores.
- Library completed: streak chip and card, shelf card, friends row, map pin states, finished ticks, "Keep reading" progress.
- "My shelf" tab (interim layout from the shelf card, pending gap G5).
- `GateChallenge` and the grown-up gate sheet (screen 09 right, without the plan header behind it).
- Parent view (screen 08) behind the gate: pages chart with adaptive scale, stat trio, level rows, settings rows. Appearance row; Privacy and Terms rows open in-app text or, through the gate helper, the web pages; Manage Subscription and Restore are wired in M5.

### Acceptance criteria
| # | Criterion |
|---|---|
| 4.1 | Screen 08 matches its PNG when the stores are seeded with the sample data shown in the design *[Mac]* |
| 4.2 | Screen 02 matches its PNG with the same seed *[Mac]* |
| 4.3 | Unit tests: a day counts when ≥ 1 page is read; streak across midnight, a missed day, a time-zone change, a week boundary; week summary totals; page counted once per forward turn (rule per PRD Q14) *[Mac]* |
| 4.4 | No stored record and no screen contains a time of day, a duration or a timer (code search for timing APIs in `Progress/` and `Features/GrownUps` finds none) *[inspect]* |
| 4.5 | The Grown-ups tab cannot be entered without passing the gate; digits are random per presentation and change after a wrong answer (unit test on `GateChallenge`) *[Mac]* |
| 4.6 | All numbers on the library and parent view come from the stores; with empty stores every card shows a sensible empty state *[Mac]* |

---

## M5 — Sample gating, subscription, StoreKit 2

### Scope
- `SampleGate` in the reader; end-of-sample card (screen 09 left); crumb shows "· Free sample".
- Subscription screen (screen 09b) reachable only through the gate.
- `EntitlementBackend`, `StoreKitEntitlementBackend`, `SimulatedEntitlementBackend`, `EntitlementStore`, entitlement cache with expiry.
- `Configuration/Omramo.storekit` with placeholder product(s) and **Example (not a decision)** prices, used only for local testing.
- Restore Purchases, Manage Subscription, pending (Ask to Buy) state, family-shared ownership display.
- Single `ExternalLink` helper behind the gate for Terms of Use and Privacy Policy.

### Acceptance criteria
| # | Criterion |
|---|---|
| 5.1 | Not subscribed: pages 1–2 of every story are readable; page 3 is never rendered; the end card shows the correct remaining count *[Mac]* |
| 5.2 | Screens 09 and 09b match their PNGs; with no product configured the plan card shows "TBD — price not set yet" in debug *[Mac]* |
| 5.3 | No code path reaches `purchase()`, restore, manage-subscription or `openURL` without a passed gate in the same presentation (test plus code search) *[inspect]*, *[Mac]* |
| 5.4 | No price or currency string exists in source or content; the displayed price is the StoreKit `displayPrice` *[inspect]* |
| 5.5 | StoreKit tests pass: purchase success, cancel, pending then approval, renewal, expiry, revocation, restore, family-shared transaction *[Mac]* |
| 5.6 | After purchase the reader continues from the page after the sample without losing position *[Mac]* |
| 5.7 | Airplane-mode launch with a valid cached entitlement allows reading; an expired cache past the grace window does not (unit test on `CachedEntitlement`) *[Mac]* |
| 5.8 | While entitlement is `unknown` the paywall never flashes and sample pages are readable *[Mac]* |

**Future owner actions (not performed by this plan):** create the subscription group and product(s) in App Store Connect, set prices, enable Family Sharing on the product(s), supply final product identifiers, publish Terms and Privacy pages.

---

## M6 — Splash, motion, accessibility, hardening

### Scope
- Splash (screen 01) with the wordmark across the hinge; folded variant.
- Motion per `docs/DESIGN.md` §3.7 after Srikanth's review; Reduce Motion variants; haptics.
- Accessibility pass (`docs/ARCHITECTURE.md` §12): VoiceOver through each story, text-size steps, Increase Contrast, Reduce Transparency, Accessibility Inspector audit.
- `PrivacyInfo.xcprivacy`; in-app privacy statement; font licence acknowledgements under "Terms and legal".
- Loading, empty and error states (gap G10); story-finished moment (gap G3); app icon slot (gap G12).
- Release configuration check: simulated store, posture simulation and any test event log compiled out.
- Performance: scene decoding off the main thread, memory under repeated page turns.

### Acceptance criteria
| # | Criterion |
|---|---|
| 6.1 | Screen 01 matches its PNG; the hinge runs between R and A at any simulated hinge width *[Mac]* |
| 6.2 | A whole story can be read, a card opened and closed, and the parent view reached using VoiceOver only *[Mac]* |
| 6.3 | With Reduce Motion on, no transition moves or scales content *[Mac]* |
| 6.4 | Accessibility Inspector audit reports no missing labels and no targets under 44 pt on the 12 screens *[Mac]* |
| 6.5 | Release build contains no debug overrides, no simulated store, no network code (code search for URL loading APIs finds only the gated link helper) *[inspect]* |
| 6.6 | Privacy manifest present; tracking false; no collected data types *[inspect]* |
| 6.7 | All 12 screens match their PNGs side by side in a single review document produced for Srikanth *[Mac]* |

---

## M7 — Duo hardware and SDK hookup

**Blocked on PRD Q4.** Can start as soon as the SDK and a device (or an official simulator) are available.

### Scope
- `DuoSDKPaneLayoutProvider`: real posture and hinge rectangle into `PaneLayoutInput`.
- Replace assumed geometry (432 × 720, 28 pt) with reported values; check every screen at the real sizes; adjust art size guidance in `docs/ARCHITECTURE.md` §7.2 if panes differ.
- Per-pane safe areas, status bar and home-indicator behaviour; window spanning or scenes as the SDK requires.
- Fold/unfold transitions on hardware; touch near the hinge.
- Update `docs/DESIGN.md` §2 and `docs/ARCHITECTURE.md` §5 with verified facts; review Apple's Duo HIG and record any conflicts with the locked design for Srikanth.

### Acceptance criteria
| # | Criterion |
|---|---|
| 7.1 | On a Duo, unfolded reading shows the scene continuous across the hinge and no text or control inside or within 20 pt of it |
| 7.2 | Folding and unfolding mid-page keeps the page and paragraph and keeps an open card open |
| 7.3 | Only one source file references Duo-specific API |
| 7.4 | The app still runs in single-pane mode on an ordinary iPhone, and in two-pane mode on iPad when the window is wide enough (Q1 decided; full iPad acceptance is Mi) |
| 7.5 | Deviations between the device and the locked screenshots are listed and signed off by Srikanth |

---

## M8 — Pilot build and hand-off

### Scope
- Content status review: `review` and `culturalReview` fields; cultural and rights sign-off status per story and per landmark from C1 (owner decision whether a private pilot may use `pending` content; a public release may not).
- Optional test-build event log for the pilot metrics, if PRD Q12/Q14 ask for it.
- Hand-off document: how to archive, what to enter in App Store Connect, the expected privacy-label answers, that the app is not in the Kids Category (Q2), the App Store age rating chosen (4+ or 9+, Q30), known issues.

### Acceptance criteria
| # | Criterion |
|---|---|
| 8.1 | All earlier *[Mac]* criteria pass on the chosen Xcode and device |
| 8.2 | The hand-off document exists and lists every owner action |
| 8.3 | No release-blocking open question remains unanswered (list in §"Blocking questions" below) |

**Future owner actions (not performed by this plan):** Apple developer organisation enrolment, signing and provisioning, App Store Connect app record, TestFlight upload and tester invitations, age rating selection (not Kids Category; Q2 decided; exact 4+ or 9+ waits on Q30), privacy label, App Review submission, legal review, publishing `omramo.com/privacy` and `/terms`.

---

## Mi — iPad two-pane and size classes

**Decided 13 Nov 2026 (PRD Q1).** The app is universal (`TARGETED_DEVICE_FAMILY = 1,2`). Milestone 1 only flips the device family and confirms the existing pane resolver still builds and launches on an iPad simulator. This milestone is the designed iPad experience.

### Scope
- Two-pane spread on a full-size iPad canvas (11-inch and 13-inch), using the same `PaneLayout` resolver as the simulated Duo — not a third layout system.
- Split View and Stage Manager: a window wide enough for two panes plus the virtual gutter uses the two-pane spread; a narrow window falls back to the single-pane (folded) layout without clipped chrome or unusable hit targets.
- Pointer and keyboard: page-turn and back should work with a click and with the expected keys; no hover-only essential control.
- Safe areas, status bar, home indicator / multitasking chrome, and Stage Manager window resize (live, not just on end of gesture).
- Any iPad-specific art or type adjustments stay within the locked v2 tokens; deviations from `docs/design/` are listed for Srikanth.
- Do not require a dedicated iPad design set unless the running layout cannot reach the same grace as the Duo screens.

### Acceptance criteria
| # | Criterion |
|---|---|
| i.1 | Library and Low-tier Reading use two panes on iPad Pro 11-inch and 13-inch in landscape, and remain usable in portrait *[Mac]* |
| i.2 | A Split View / Stage Manager window below the two-pane threshold uses the single-pane layout with no clipped tab bar, page-turn button or unreadable type *[Mac]* |
| i.3 | Resizing across that threshold mid-page keeps the current page, paragraph and any open card *[Mac]* |
| i.4 | Pointer click and hardware keyboard can turn the page and go back; there is no hover-only essential control *[Mac]* |
| i.5 | Visual gaps versus the locked Duo screenshots (type, spacing, art, motion) are listed; nothing is shipped that looks like a stretched iPhone layout *[Mac]* |

---

## C1 — Content production: global launch catalog and landmarks

A parallel workstream run by people (writers, an editor, illustrators, community consultants, a lawyer). It is not engineering work and has no dates here. The catalog, sources and landmark map are in `docs/CONTENT_PLAN.md`. It can start as soon as PRD Q22–Q25 are answered; it needs the M1 schema and validator to deliver into.

### Scope

1. **Tier specification** (PRD Q3): word counts, sentence length and vocabulary guidance per tier, agreed before writing starts.
2. **Writing:** fresh Omramo retellings of the 29 public-domain tales and the 3 originals, each with its manuscript in `Content/sources/`, page breaks, tap words, card copy, character cards, the three education lessons and a reflection question. Each retelling fixes the dated or offensive framing noted for its source.
3. **Landmarks:** fact cards in three tier wordings for each of the 37 landmarks, fact-checked against two reliable sources (dates, sizes, coordinates, status); framing lines for every framed appearance.
4. **Illustration:** covers, scenes (unfolded and folded), tap-to-see pictures, character portraits and face chips per story; one picture per landmark, with lost wonders drawn as our own reconstructions. All to the sizes in `docs/ARCHITECTURE.md` §7.2.
5. **Cultural review:** community consultant sign-off for the 12 flagged stories (text, art and cards), and a standard accuracy read for the rest; results recorded in `culturalReview`.
6. **Legal review:** public-domain status of each cited source for the stores we ship to; trademark check on names; landmark image and name rights; ownership of originals and commissioned art.
7. **Delivery:** `story.json`, art and landmark entries that pass the validator.

### Acceptance criteria

| # | Criterion |
|---|---|
| C1.1 | Every region has at least one story in each tier in `Content/catalog.json` (a validator report prints the region × tier matrix with no empty cell) *[box]* |
| C1.2 | Every story names a specific culture and place, has a provenance record (a cited source, or the "Original story written by us (Omramo)" credit with its premise) and all three education lessons *[box]* |
| C1.3 | No story text matches its cited source's wording (retelling check by the editor; M1's placeholder Babbitt text is replaced or explicitly kept by decision on Q22) |
| C1.4 | Every story with `culturalReview.level: required` is `approved`, with the reviewer and date recorded; a story that is not approved is absent from the release catalog *[box]* |
| C1.5 | No sacred, ceremonial or restricted narrative is in the catalog (confirmed by each consultant for their community) |
| C1.6 | Every landmark has three tier fact cards, a fact-check record, a picture with alt text, and `review.facts` and `review.art` approved *[box]* |
| C1.7 | Every landmark appearance passes the anachronism rule; every lost or unproven wonder is shown as a labelled reconstruction *[box]* |
| C1.8 | Each tier's stories reference both historical (ancient to early-modern) and modern or contemporary landmarks (validator report) *[box]* |
| C1.9 | Legal sign-off recorded per story (`provenance.rights`) and per landmark (`rights`) for the stores chosen; anything unresolved is removed or replaced |
| C1.10 | All content passes `tools/validate_content.py` in release mode, and every image meets the size and contrast rules *[box]* |
| C1.11 | No concept or placeholder art remains in the release catalog |

### Risks

- Consultants may ask for changes or decline a story; each flagged story needs a replacement path (PRD Q24).
- Art volume: 32 stories and 37 landmarks. Launching in waves (PRD Q31) is the main lever.
- App size with all art bundled may force downloadable packs earlier (`docs/ARCHITECTURE.md` §6.7).

---

## Later (not scheduled)

- Downloadable story packs and a remote catalog (`docs/ARCHITECTURE.md` §11).
- Internal authoring and preview tool.
- Local reader profiles (PRD Q11).
- Commissioned art replacing all concept art — a parallel content workstream, the long pole for any public release.

## Blocking questions by milestone

| Milestone | Needs an answer to | If unanswered, the plan proceeds with |
|---|---|---|
| M1 | Q18 (who paginates and marks the Low story) | Engineering paginates at about 55 words a page and marks the words shown in the designs |
| M1 → done | Q16 (a Mac to build on) | First compile recorded 13 Nov 2026 on the Mac Studio, Xcode 26.6. Remaining *[Mac]* visual checks still apply. |
| M2 | Q5 (texts as written?), Q13 (swipe?), Q21 (design gaps G1, G8) | Unaltered public-domain texts; button only; interim Aa panel |
| M3 | Q21 (gap G4) | Bottom card when folded |
| M4 | Q9 (gate mechanic), Q10 (streak), Q14 (page counting), Q11 (profiles) | Three digits as words; streak as designed; every forward turn counts; one child |
| M5 | Q6 (sample), Q7 (plans, identifiers, price), Q20 (bundle id) | Two-page sample; one placeholder product; `com.omramo.app` |
| M6 | Q30 (exact age rating 4+ or 9+), Q15 (font), motion approval | Age rating unset pending Q30; Inter for system rows; proposed motion |
| M7 | Q4 (Duo SDK and device) | Cannot proceed (Q1 is decided: universal) |
| Mi | none blocking; visual sign-off of i.5 | Proceed with the pane resolver and list deviations |
| M8 | Q5 (review and rights), Q12 (testing), Q20 (legal, account) | Cannot proceed to a pilot |
| C1 | Q22 (retellings), Q23 (rights), Q24 (consultants), Q25 (authors of originals), Q3 (tier specification); then Q26–Q31 | Cannot start writing. Engineering is not blocked: M1–M6 use the three prototype stories |

## Assumptions (plan)

1. A Mac with Xcode becomes available after M1 is written; until then verification is by inspection.
2. Headless Chrome on the dev box can render the concept scenes to PNG for placeholders (it produced the designs); HEIC conversion may have to happen on the Mac, so M1 may ship PNG placeholders and switch format later.
3. The three prototype stories use the public-domain texts unaltered during M1–M3, as placeholders. The launch catalog uses fresh retellings (PRD A12, Q22).
4. Milestones are sequential for one engineer; no staffing or duration is assumed.

## Open questions (plan)

1. Calendar and any external deadline: TBD.
2. Who reviews *[Mac]* criteria and reports results back (PRD Q16)?
3. May M2 start before M1 is verified on a Mac? (Recommended: no — fix the first compile first.)
4. Should PRs #1 and #2 be closed when M1 lands (PRD Q17)?
5. Is the art workstream (illustrator, direction, review) being started in parallel, and who owns it (PRD Q5)?
6. Who owns C1 (an editor or content lead), and may it launch in waves (PRD Q31)?
