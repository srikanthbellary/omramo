# Omramo — agent handoff

Last updated: 14 Nov 2026 — coding round 3 (polish), code complete and uncompiled (see §9, last entry). Read this first, then `docs/PRD.md`.
This file is the durable memory for any agent (human or AI) picking up Omramo. It contains no secrets; credentials live outside the repo.

## 1. What Omramo is

A **global English, illustration-driven, game-like story reader for children who can already read**, marketed as **ages 6 to 14 and up**. Stories come in three tiers (Low / Medium / Advanced; ability bands 6–8, 8–10, 10–12+), with tap-to-see visuals, character cards, a parent view, a sample + paywall and a family subscription. It is a **native Swift (SwiftUI) universal app** for iPhone, the two-pane iPhone Duo and iPad, with a folded single-screen mode. It is **not** listed in the App Store Kids Category, but keeps the same kid-safety rules.

Owner: Srikanth Bellary (GitHub `srikanthbellary`), Sunrise Gen AI LLC.

## 2. Product direction history

| When | Direction | Where it lives |
|---|---|---|
| Sept 2026 | **Telugu-first** illustrated serial reader for iPhone Duo (open-book spread, Telugu + English editions). Scaffolded by Cursor cloud agents. | `docs/PRODUCT.md` (superseded, kept for history); unmerged PRs #1 and #2 |
| 7 Nov 2026 | Competitor research on illustrated English readers | `docs/business/2026-11-07-illustrated-english-reader-competitors.md` |
| 13 Nov 2026 | **Pivot to global English**, business cases v2 → v5; v5 (story tiers) is current | `docs/business/2026-11-13-omramo-business-use-case-v5-story-tiers.md` |
| 13 Nov 2026 | Design v1 (Fable 5.2) **rejected**; design v2 **locked** | `docs/design/`, `docs/DESIGN.md` |
| 13 Nov 2026 | Planning docs, global content plan with landmarks, M1 scaffold | this branch, `docs/*.md` |

### Why design v1 was rejected (Srikanth, verbatim)
"i did not like the omramo designs. tell it do the real thing. real mockups. should feel real app screenshots. i dont care what tech it will use. also the overall fonts and desings should not looks like a typical hardcover book. the lines spacings. the fonts, the art insertions all has to be top notch, innovative and pleasing and sepctacular to read."

v1 used cream paper, a serif and a book spine. v2 ("the page is a place") removed all of that: every reading spread is one continuous illustrated scene running under both panes and the hinge, with text sitting in the calm part of the scene; each story has its own light; app chrome is glass buttons, chips and a round page-turn button.

### Locked v2 design (13 Nov 2026: "Yes! Lock this design and get to work!")
- Screens: `docs/design/*.png` (12 raw screenshots). Source, render script, notes and fonts: `docs/design/source/` (`python3 src/render.py` re-renders with headless Chrome). Spec: `docs/DESIGN.md`.
- Fonts (SIL OFL 1.1): **Bricolage Grotesque** (display/headings), **Atkinson Hyperlegible Next** (all story text), **Inter** (UI chrome).
- Story text size / line height: **Low 23.5 / 37 pt, Medium 19.5 / 32 pt, Advanced 16.5 / 27 pt**.
- Palette: midnight indigo `#130F36`, cloud `#F3F1FF`, coral `#FF6A4D`, sun `#FFC43D`; tiers Low green `#12B58F`, Medium amber `#FF9F1A`, Advanced violet `#6E56FF`.
- Wordmark OM | RA | MO split across the hinge on the splash.

## 3. Srikanth's standing preferences (keep these)

1. Designs must feel like **real app screenshots**, never mockup-y and never like a hardcover book.
2. Typography, line spacing and art insertion must be **top-notch, innovative and spectacular to read**.
3. Coding/design work for Omramo is done with **Claude Code on Fable 5.2**: `claude -p --model claude-fable-5-2` (no fallback model), on Srikanth's Max subscription login (no API key). The CLI prints `[claude-code:unrecognized_model]`; the server still runs Fable 5.2. Always verify via `modelUsage` in the `--output-format json` result (Claude Code may also use a small Haiku model internally for WebFetch summaries). The alias `fable` resolves to an older Fable — don't use it.
4. **Native Swift**, two-pane iPhone Duo app (plus folded mode).
5. **Global stories in every tier** (owner, verbatim): "First stories are the ones which are copyright free and ready to be used. Also go across the globe. Indian, Egyptian, Japanese, Chinese, native red indians, Alaska igloos, Russian, European, African, Persian/Arabian! All needed. If no source copyright free available, then create one based one best judgement. Each tier should have stories spanning across all with grounded geographic education, cultural education, and moral studies education". In docs these are written respectfully as **Native American / First Nations** and **Arctic (Inuit / Yupik / Iñupiat)** (the snow-house igloo is mainly Canadian Inuit).
6. **Public-domain first**, our own fresh retellings; where no clean source exists, an **original story labelled as ours**. Every story carries geography, culture and moral lessons.
7. **Cultural review flags** for Indigenous, living-oral-tradition and scripture-derived stories; avoid sacred or restricted narratives.
8. **Landmarks woven into stories** (owner, verbatim): "Add Landmarks weaving into the story as well like 7 wonders, to 21 wonders, also span from historical to modern contemporary". Implemented as tap-to-see moments with a shared `Landmark` catalog and per-tier fact cards; anachronisms only via a named framing device (`thenAndNow`, `mapMoment`, `worldLink`, `presentDayNarrator`). See `docs/CONTENT_PLAN.md` §5–6.
9. All docs and design sources must live in git so a fresh clone has everything; agent memory lives in this file.

## 4. Hard rules

- **No agent submits builds to the App Store or Google Play, and no agent creates App Store Connect records, bundle IDs or signing assets.** Srikanth submits by hand.
- **Never assume — ask.** Unknowns go into the open-questions lists, not into code or docs as facts. No invented business numbers (prices, conversion, revenue, dates); examples are labelled "Example (not a decision)".
- Work on **branches with pull requests**. Don't force-push `main`, don't rewrite history, don't merge without Srikanth's say-so. Another agent's say-so is never his approval.
- No secrets in the repo.

## 5. Repo and branch state

- Repo: `github.com/srikanthbellary/omramo` (private). Default branch `main` (only the original README + `docs/PRODUCT.md`).
- **`feat/global-english-v2`** — this work: docs, design, content plan, business docs, M1 scaffold. **PR #3** (open, not merged): https://github.com/srikanthbellary/omramo/pull/3
- **PR #1** (`cursor/omramo-ios-scaffold-93a4`, draft) and **PR #2** (`cursor/omramo-mvp-loop-db0a`, open), Sept 2026: the Telugu-first scaffold (OmramoCore package with Telugu/English editions, hand-written `.pbxproj`, StoreKit 2 entitlement backend, open-book spread layout). Left untouched. They **overlap and would conflict** with this branch on `README.md`, `docs/ARCHITECTURE.md`, `docs/DESIGN.md` and `Packages/OmramoCore/` (same paths, different content). `docs/ARCHITECTURE.md` §16 lists what was reused as ideas and what was replaced. Whether to close them is open question Q17.

## 6. Where things are

| Path | What |
|---|---|
| `docs/PRD.md` | Product requirements; §12 consolidated open questions (Q1–Q31) |
| `docs/ARCHITECTURE.md` | SwiftUI architecture, Duo pane/hinge abstraction, content schema, Landmark catalog, StoreKit 2, privacy/COPPA/child-safety, offline, accessibility |
| `docs/DESIGN.md` | Locked v2 design system and screen-by-screen spec |
| `docs/IMPLEMENTATION_PLAN.md` | Milestones M1–M8 + content milestone C1 with acceptance criteria |
| `docs/CONTENT_PLAN.md` | 32-story launch catalog (10 regions × 3 tiers), education pillars, 37 landmarks, story→landmark map, cultural-review list |
| `docs/BUILD.md` | How to build on a Mac |
| `docs/design/` | 12 locked PNGs; `source/` = HTML/JS sources, render script, design notes, OFL fonts |
| `docs/business/` | Business case v5, competitor research, Fable assessment and discussion brief |
| `docs/content/source-texts/` | Public-domain source texts (Gutenberg) for the first three stories, `SOURCES.md` |
| `docs/agent-runs/` | Fable 5.2 run log and the exact prompts used |

## 6a. Decisions recorded 13 Nov 2026 (evening)

Srikanth: "go with whatever the best approach is for this kind of app. Follow best practices and Apple guidelines." And earlier: Apple ID for purchases, no sign-in screen.

1. **Universal app (PRD Q1 decided).** iPhone (single-pane), Duo (two-pane), iPad (two-pane spread on the larger canvas, including Split View and Stage Manager, via the same `PaneLayout` resolver). `TARGETED_DEVICE_FAMILY = 1,2`. Full iPad layout polish is **milestone Mi** (acceptance criteria in `docs/IMPLEMENTATION_PLAN.md`); do not treat a first iPad simulator launch as that milestone.
2. **No accounts or sign-in.** Purchases go through the **Apple ID** with a StoreKit 2 family subscription, Family Sharing on, and Restore Purchases. No Omramo account, no sign-in screen, no server. Reading progress stays on the device.
3. **Child-safety rules, without the Kids Category listing.** Follow App Store Review Guidelines **1.3** and **5.1.4** anyway: no third-party analytics or ads, a parental gate before purchases, external links and settings, and a privacy manifest. No accounts.
4. **Ages (PRD Q2 decided, 13 Nov 2026, 8:46 PM ET).** Do **not** list Omramo in the App Store Kids Category. Use a normal App Store age rating and market it as **ages 6 to 14 and up**, so a 13- or 14-year-old still building reading skills does not see it as a little-kid app. Tiers from `docs/research/AGE_RANGE.md` stand (Low 6–8, Medium 8–10, Advanced 10–12+). Advanced should look grown-up enough not to feel babyish. The exact rating (4+ or 9+) stays open under Q30.

## 7. Build setup

- Dev box (Linux) has **no Swift toolchain or Xcode** for compiling the iOS app; the first compile was done on the Mac Studio.
- **Mac Studio** (user `sholu`): macOS 26.7.1, **Xcode 26.6** (17F113), Swift 6.3.3, XcodeGen **2.46.0** at `~/development/bin/xcodegen` (Homebrew was not writable). Claude Code 2.1.325 is installed; Srikanth has not yet signed it in (`claude auth login --claudeai`, Max account). Repo path on the Mac: `~/development/omramo` (synced by git bundle; do not log `gh` in or copy credentials there).
- First simulator used: iPhone 17 Pro Max, iOS 26.5, UDID `416D3327-A123-4748-8ABF-9E8D27B48610`.
- Command-line `xcodebuild` must use Debug `ONLY_ACTIVE_ARCH=YES` (set in `project.yml`); otherwise the app compiles for x86_64 against an arm64 `OmramoCore` module and fails with `unable to resolve module dependency: 'OmramoCore'`.
- Debug launch arguments: `-OmramoPosture unfolded|folded`, `-OmramoOpenStory <story-id>` (e.g. `monkey-and-crocodile`), `-OmramoOpenCard <id>`, `-OmramoOrientation landscape|portrait`, and since round 3 `-OmramoResetState` (empty in-memory stores; UI tests) and `-OmramoDemoState` (a made-up reading history in memory; screenshots).
- Details in `docs/BUILD.md`.

## 8. Next milestones

See `docs/IMPLEMENTATION_PLAN.md`. **Immediate next step (as of the last §9 entry): compile round 3 on the Mac — `docs/BUILD.md` §7b is the checklist and §8b the list of likely compile errors — then take the `r3-*.png` shots and look at them.** The paragraph below is the earlier next step, kept for its list. Earlier: **compile the M2 / M3 / Mi round on the Mac** — `docs/BUILD.md` §7a is the checklist and §8a the list of likely compile errors. Then:
1. Visual check of Library and Low-tier Reading against `docs/design/` (including `TextRenderer`, item 1.17 / BUILD §7.9). List every gap versus Apple Design Award / locked v2 quality. Now also screens 04–07 and 10, and the iPad sizes.
2. Srikanth still needs to answer remaining blocking questions (PRD §12; especially Q4 Duo SDK, Q7 pricing/plans, Q18 page breaks, Q22 retellings, Q23–Q24 rights and cultural reviewers, Q30 sensitive content / exact age rating). Q1 and Q2 are decided.
3. M2 complete reader, M3 tap-to-see + character cards and Mi iPad layout are written but unverified: check each *[Mac]* criterion before calling any of them done. Later milestones follow the plan; content milestone C1 in parallel.

## 9. Status log

### 13 Nov 2026 — planning + M1 scaffold (branch `feat/global-english-v2`)
- Fable 5.2 runs on the Linux box (all verified `modelUsage` = `claude-fable-5-2` only): planning docs 4:08–4:22 PM ET; content plan + landmarks 4:22–5:20 PM ET; M1 code 5:20–6:25 PM ET. Prompts and run log in `docs/agent-runs/`.
- **M1 implemented (uncompiled):** XcodeGen `project.yml` (iOS 18.0, bundle id `com.omramo.app` = placeholder/TBD, empty `DEVELOPMENT_TEAM`); `Packages/OmramoCore` (Foundation-only: schema v1 story model with tiers/spreads/text runs/tap targets/character cards/art refs + `region`, `provenance`, `culturalReview`, `education`; `Landmark` catalog with per-tier fact cards and `framingDevice`; decoder, validator incl. anachronism rules, pager, pane-layout resolver, design tokens; XCTest suites); sample *The Monkey and the Crocodile* (Low, 14 pages, our draft retelling, Taj Mahal via `thenAndNow`); SwiftUI app with design system, bundled OFL fonts, `PaneLayoutReader` with normal-iPhone fallback and Debug-only simulated Duo (`-OmramoPosture unfolded|folded`), Library and Low-tier Reading screens; `tools/validate_content.py` (46 tests pass on the box).
- **Stubbed (`TODO(Mx)`):** tap-to-see / character / landmark cards (M3); Aa/bookmark, back-a-page, continuation screens, proper folded reading (M2); sample gate, paywall, StoreKit 2 (M5); streak, shelf, parent view, grown-up gate (M4); splash, motion, app icon (M6); all art is SwiftUI placeholder shapes (`ART_PLACEHOLDERS.md`).
- **Riskiest compile items:** `TextRenderer` use in `StoryText.swift` (switch `usesTextRenderer = false` to fall back), inline face chips, variable-font axes via `UIFontDescriptor`, XcodeGen scheme/Info.plist details, SVG template icons, `Bundle.module` content lookup. See `docs/BUILD.md` §7–8.
- **Next action (updated same evening):** first Mac build is in progress / landing on this branch. `swift test --package-path Packages/OmramoCore` passed **116 tests, 0 failures**. An iPhone 17 Pro Max simulator build succeeded after `ONLY_ACTIVE_ARCH=YES`. Remaining: confirm launch screenshots, iPad family flag, and the visual-gap list.

### 13 Nov 2026 — first Mac Studio compile and product decisions
- First `xcodebuild` of M1 on the Mac Studio (Xcode 26.6, iPhone 17 Pro Max / iOS 26.5). Package tests: 116 passed. The first failing command-line build was an arch mismatch (app x86_64 vs `OmramoCore` arm64), not a missing package reference; fixed in `project.yml` / `Base.xcconfig`. Debug argument `-OmramoOpenStory` added so the reader can be opened from `simctl`.
- **Q1 decided (universal app).** **No accounts / no sign-in; Apple ID + StoreKit 2 for purchases.** Child-safety guidelines 1.3 and 5.1.4 adopted (at that time framed as Kids Category). Recorded in `docs/PRD.md`, `docs/ARCHITECTURE.md`, `docs/IMPLEMENTATION_PLAN.md` (new milestone Mi) and here.

### 13 Nov 2026, 8:46 PM ET — Q2 ages and store listing
- Srikanth: list as 6–12 and suggest younger and older can also read, including 13/14 who are still building reading skills, otherwise they will think it is a younger-kids app and not open it. Chose: skip the Kids Category, use a normal age rating, market as ages 6 to 14 and up, keep the kid-safety rules.
- **Q2 decided.** Not in the Kids Category. Marketed as ages 6 to 14 and up. Tiers stand (Low 6–8, Medium 8–10, Advanced 10–12+). Advanced must not feel babyish to a 13–14-year-old. Exact App Store age rating (4+ or 9+) remains open under Q30. Recorded in `docs/PRD.md`, `docs/ARCHITECTURE.md`, `docs/DESIGN.md`, `docs/IMPLEMENTATION_PLAN.md`, `docs/CONTENT_PLAN.md`, `docs/research/AGE_RANGE.md` and here.

### 13 Nov 2026 (after 8:46 PM ET) — M2, M3 and Mi code round (Fable 5.2, Linux box)
- **State: code complete, NOT compiled, NOT seen.** The box has no Swift toolchain. Everything was checked by inspection and by reviewer passes; the Python validator suite was run (62 tests pass; all three stories validate, 0 errors). Do not call any *[Mac]* criterion of M2, M3 or Mi met until `docs/BUILD.md` §7a has been worked through on the Mac.
- **Mi bug fixes from the first simulator pass (written, not yet seen):** reader text is laid out so it should no longer sit under chrome (each pane has a bounded text area; overflow goes to a continuation screen); the library tab bar has its own strip, so the map legend should not be under it; derived layouts cap the design at 1.3 × and centre the content band, so an iPad should not look like a stretched phone.
- **M2:** "Aa" text size (5 steps, persisted, interim panel — gap G1); bookmark (one per story, persisted); back-one-page control (interim, beside the page chip — gap G3; no swipe, Q13 still open); continuation screens (`ScreenPlanner` in the core); position = page + paragraph, kept across relaunch, posture and window changes; folded reading after screen 10; per-story theme; text on a path.
- **M3:** marked words and names tappable (≥ 44 pt); tap-to-see, landmark and character cards on the facing pane (`CardPlacement`), bottom card when folded (A2 / G4); hold state, toast, seen state and friends met persisted (`reader-memory.json`); page turn blocked while a card is open; VoiceOver custom actions and focus moves.
- **Mi:** same `PaneLayoutResolver`; two panes on full-size iPads in landscape and on a 13-inch iPad in portrait (≥ 980 pt wide), one padded pane otherwise; pointer and hardware keyboard (→ / space, ←, Return, Esc).
- **Content:** two new prototype stories, both **our own retellings**, `review: pending`: *How Wisdom Became the Property of the Human Race* (Medium, Akan, 8 pages, cultural review required) and *The Story of Urashima Taro* (Advanced, Japan, 16 pages, text on both panes, the call on the wave path). Two new landmarks: `asante-traditional-buildings` (natural in the Anansi story) and `tokyo-skytree` (framed, "then and now", in Urashima). Schema additions inside version 1: `scene.textArea`, and a path rule for `pathText` (both validators).
- **Art:** every scene, cover, tap-to-see picture, portrait, face chip and landmark picture for the three stories is now drawn in SwiftUI `Canvas` code (`App/Sources/Art/`), ported and extended from our own locked design sources. Concept art, `review.art: pending`, never rendered. See `Content/ART_PLACEHOLDERS.md`.
- **Tests:** core suite grew from 116 by about 80 test methods (two M1 assertions in `DecodingTests.swift` were updated because they asserted a one-story catalog); about 20 new app tests in `App/Tests/ReaderTests.swift`. None of the new Swift tests has been run. Counts and the list are in `docs/BUILD.md` §6.
- **Untouched, as instructed:** M4–M8 stay stubbed (no sample gate: every page of all three stories is readable; no StoreKit, gate, parent view, splash or Duo SDK). No App Store Connect, signing or submission step. `DEVELOPMENT_TEAM` empty. No prices. The Q2 decision (not in the Kids Category; ages 6 to 14 and up) is unchanged. The `omramo-web` repo was not touched.
- **Needs Srikanth (nothing here was assumed as decided):**
  - Q22 / Q5 — the three texts are retellings; the plan's M1–M3 assumption still says "public-domain texts unaltered". Editorial choices made in the drafts, to confirm or reverse: Urashima ends with him grown old on the shore (no death, no tobacco or sake, no wedding, no closing sermon); Anansi takes the wisdom back over a small slight and walks home hand in hand with his son.
  - Q24 — Akan reader for the Anansi text **and** drawings (kente, pot, village houses, the landmark card); Japanese reader for Urashima. Facts in the culture notes and fact cards are unverified.
  - Q29 — Tokyo Skytree name and image rights before any release.
  - Q21 — design answers for G1 ("Aa" panel), G3 (back control; last page), G4 (folded card: ours covers the tapped line), G8 (folded Medium / Advanced type); DESIGN §9 item 4 (when the place marker clears: ours clears on the next page turn).
  - Mi — sign-off of the iPad rules after seeing them: two panes in portrait only from 980 pt, the 1.3 × cap.
- **Riskiest compile items this round:** `Text.LayoutKey` hit-testing (switch `StoryTextStyle.usesLayoutKey = false` to fall back), the art painters' volume, the measure-then-plan loop, text on a path in `Canvas`. Full list: `docs/BUILD.md` §8a.

### 14 Nov 2026 — coding round 3: polish toward an award-level bar (Fable 5.2, Linux box, branch `feat/r3-polish`)

Srikanth's direction for the round, as given in the brief: "Make sure it is award level but not compromising on a smooth and seamless interface and UI and UX. Award level means still grounded for real usage by kids from 6–12. Don't make it too complicated and too edgy for a young audience." Read as: big obvious controls (44 pt at least, 56 pt for the primary one), calm purposeful motion that respects Reduce Motion, a real app and never a book, Advanced not babyish, Low friendly.

- **State: code complete, NOT compiled, NOT seen.** The box has no Swift toolchain. Checked by inspection and by "be the compiler" reviewer passes; the Python validator suite was run (62 tests pass; three stories, 0 errors). No content, schema or validator rule changed. Treat every *[Mac]* statement below as unverified until `docs/BUILD.md` §7b has been worked through.
- **1. 13-inch iPad portrait.** New pure arithmetic in the core, `PageFit` (still the one `PaneLayoutResolver`; no third layout system): on a pane taller than the design's proportions, Low and Medium type grows a little within the tier's measure (about 1.11 × on a 13-inch portrait; Advanced keeps its 45-character line), and a page shorter than its column is set lower — 42% of the free space above it, at most half the extra height — instead of at the top over an empty band. Text still cannot go under chrome: the offset only uses space the measured text leaves free (tests on eleven windows). The scene itself still stretches its sky on a tall window.
- **2. Folded iPhone.** `-OmramoPosture folded` on a phone (or any one-pane window) now lays out the real window edge to edge with real safe areas instead of a letterboxed device picture; a wide window still gets the reference pane for comparison with screen 10. On every phone the picture band takes 40% of the screen's extra height, the words the rest.
- **3. Motion.** One file of tokens, `App/Sources/DesignSystem/Motion.swift`, documented in `docs/DESIGN.md` §3.7: page turn (words slide 30 pt and fade, the picture drifts 12 pt, forward and back mirror, controls locked for the 0.42 s turn, press response and a light haptic, no swipe); card open / close (a sun glow travels from the tapped word into the card while the card grows from 0.94 anchored on the word; reverses on close; the text never moves); library → story (the reader grows out of the tapped cover and closes back into it; the library stays laid out underneath). Critically damped springs, 0.38–0.45 s. Reduce Motion: cross-fades only. Pictures are rasterised once (`cachedArt()`).
- **4. Art direction.** New `docs/ART_DIRECTION.md` (one warm light from the upper left, an indigo shadow tint, a warm horizon band, two line weights, one face construction, one finish, a five-step ramp and accent per story, framing rules for scenes, pictures, portraits, chips, covers) and `App/Sources/Art/ArtStyle.swift`; every painter for the three stories and the four landmarks was re-worked to it. What changed per rule, and where it is known to fall short, is in `Content/ART_PLACEHOLDERS.md`. **Nothing drawn this round has been rendered.**
- **5. Library side column (M4 subset).** Core: `ReadingDay` (year / month / day numbers — never a time), `PageRead`, `ReadingLogFile`, `StreakCalculator`, `StreakSummary`, `ShelfState`, `FriendMet`. App: `ReadingLogStore` (`reading-log.json`), streak chip and card, shelf card with a large "Keep reading" row (cover, page x of y) and finished covers, "Friends you have met", finished ticks on covers, empty states; compact on one pane. A page is logged once per forward turn that leaves it, plus the last page on finishing (PRD Q14 default: every forward turn counts). The streak wording has no pressure and no word for a missed day. **Not built, as instructed:** grown-up gate, parent view, "My shelf" tab, week summary, paywall.
- **6. Tapping words.** Every marked word is a button of at least 44 × 44 pt with identifier `word.<cardID>`; cards are `card.<cardID>`; neighbouring words share the room between them (`HitTargets`, core); unmarked words have no gesture. XCUITests in `App/UITests/WordTapTests.swift`.
- **7. Screenshots.** `App/UITests/ShotTests.swift` writes `r3-ipad-*.png` / `r3-iphone-*.png` to `OMRAMO_SHOT_DIR`.
- **How to run** (details in `docs/BUILD.md` §4 and §7b): `swift test --package-path Packages/OmramoCore`; `xcodegen generate`; build; ⌘U; then
  `xcodebuild test -project Omramo.xcodeproj -scheme OmramoShots -destination 'platform=iOS Simulator,id=<udid>' -only-testing:OmramoUITests/WordTapTests` and the same with `ShotTests`, on an iPad and an iPhone simulator.
- **Tests added (none run):** core `Round3Tests.swift` (on top of the 197: page fit, hit targets, reading days, log and streak per criterion 4.3, shelf, friends); app `App/Tests/Round3Tests.swift`; UI `WordTapTests`, `ShotTests`. Counts in `docs/BUILD.md` §6.
- **Untouched, as instructed:** no App Store Connect, signing or submission step; `DEVELOPMENT_TEAM` empty; no prices; no ads, tracking, analytics, accounts, network calls or sign-in; no third-party package; the Q2 decision stands; the `omramo-web` repo and `/workspace/srikanth/duo/Omramo/web` were not touched. The existing debug launch flags still work.
- **Riskiest compile and run-time items:** the art files after the direction pass; the page-turn and hero transitions (each relies on a 20 ms two-step so the leaving view is drawn with the right transition); XCUITest seeing the word buttons through the text's accessibility element; `drawingGroup()` over the grain overlay. Full list: `docs/BUILD.md` §8b.
- **Honest gaps against an award-level bar** (the round's own list):
  - Nothing has been seen. Motion values, the 42% / 40% fit shares and every picture are estimates until someone looks.
  - The art is still code-drawn concept art by engineers, not illustration; proportions, light direction and tap-to-see framing only partly meet `ART_DIRECTION.md` (listed in `ART_PLACEHOLDERS.md`). An illustrator is the real fix (C1).
  - A tall iPad portrait page is balanced, not recomposed: the scene is not redrawn for portrait.
  - No story-finished moment, no splash, no sound, no app icon, no designed loading or error state (M6). The last page still ends with a tick and a return to the library.
  - The "Aa" panel (G1) and the back control (G3) are still interim designs; folded Medium and Advanced type (G8) and the folded card that covers the tapped line (G4) are unresolved.
  - Type: line breaks, hanging punctuation and word spacing are still not matched to the designs.
  - The map's "Read" pin state, the "My shelf" tab and the parent view are not built; the streak has no gentle celebration.
  - VoiceOver focus moves and the new word buttons need a device; Dynamic Type beyond the five "Aa" steps is untested.
- **Needs Srikanth (nothing here was assumed as decided):** approval of the motion values (DESIGN §9 item 2); the fit numbers and the type growth on a 13-inch portrait (Mi sign-off); the art direction itself, and whether Advanced should go further toward a limited-colour print look; the crocodiles' new friendlier eyes versus the locked screen 03; Q14 (does re-reading a page count again?); Q10 (streak as designed); plus everything still open from the round before (Q22, Q24, Q29, Q21).
