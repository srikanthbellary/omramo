# Omramo — agent handoff

Last updated: 18 Nov 2026 — coding round 5 (the stories round), batch 1 of 3: code and content complete, uncompiled and unseen (see §9, last entry). Round 4 was compiled, run and merged (PR #5, `17e5581`). Read this first, then `docs/PRD.md`.
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
| `docs/ART_DIRECTION.md` | The art direction for the pictures drawn in code (round 3, deepened in round 4), the app icon and the splash |
| `docs/content/story-specs/` | Round 5: the authoring spec of each new story (text, cards, header, landmark entries, art brief); `tools/build_stories.py` builds `story.json` and the manuscript from it |
| `docs/agent-runs/r5-batch-notes.md` | Round 5: the kit, the per-story file layout and the conventions batches 2 and 3 must follow |
| `docs/brand/` | App icon: `app-icon.svg` (source), `app-icon-1024.png`, `app-icon-preview.png` (round 4) |
| `tools/` | `validate_content.py` + its tests; `make_app_icon.py` (SVG → the icon PNGs); `make_sounds.py` (the two optional reader sounds) |

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
- Debug launch arguments: `-OmramoPosture unfolded|folded`, `-OmramoOpenStory <story-id>` (e.g. `monkey-and-crocodile`), `-OmramoOpenCard <id>`, `-OmramoOrientation landscape|portrait`, and since round 3 `-OmramoResetState` (empty in-memory stores; UI tests) and `-OmramoDemoState` (a made-up reading history in memory; screenshots). Since round 4: `-OmramoOpenFinished <story-id>` (the story-finished moment), `-OmramoOpenPage <n>` (start page), `-OmramoShowSplash` (hold the splash), and `-OmramoPosture reference` (the letterboxed reference canvas; `unfolded` now fills the window and turns an iPhone to landscape).
- Details in `docs/BUILD.md`.

## 8. Next milestones

**Immediate next step (as of the last §9 entry, round 5 batch 1): compile batch 1 on the Mac — `docs/BUILD.md` §7d is the checklist and §8d the list of likely compile errors — run `ShotTests` for the `r5-*.png` set, and look at the kit's people and animals before batches 2 and 3 (`docs/agent-runs/r5-batch-notes.md`) build twenty more stories on them.** The paragraphs below are the earlier next steps, kept for their lists.

See `docs/IMPLEMENTATION_PLAN.md`. **Immediate next step (as of the last §9 entry): compile round 4 on the Mac — `docs/BUILD.md` §7c is the checklist and §8c the list of likely compile errors — then run `ShotTests` for the `r4-*.png` set and `MotionDemoTests` for the recordings, and look at them.** The paragraph below is the earlier next step, kept for its list. Earlier: **compile the M2 / M3 / Mi round on the Mac** — `docs/BUILD.md` §7a is the checklist and §8a the list of likely compile errors. Then:
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

### 14 Nov 2026 — coding round 4: polish (Fable 5.2, Linux box, branch `feat/r4-polish`)

Round 3 was compiled, run and merged on the Mac as PR #4 (`7194575`): 247 core tests, 52 app tests, 7 `WordTapTests` and the `ShotTests` pass there (Xcode 26.6, iOS 26.5 simulators). Round 4 was cut from that `main`. Srikanth's bar is unchanged: award level, but smooth, seamless and simple for children of 6–12; calm motion that respects Reduce Motion; a real app, never a hardcover book; Advanced not babyish; primary controls at least 56 pt, every target at least 44 pt.

- **State: code complete, NOT compiled, NOT seen.** No Swift toolchain on the box. Checked by inspection, by three scripts (brace balance over all 93 Swift files; no duplicate declarations in the art; the argument labels of all 3,407 calls into `Art.*` / `ArtStyle.*`) and by five "be the compiler" reviewer passes (core + app, and one per art family). The Python validator suite was run: 62 tests pass; three stories, 0 errors. Treat every statement below as unverified until `docs/BUILD.md` §7c has been worked through.
- **1. Illustration pass.** Every painter re-worked toward illustration (`docs/ART_DIRECTION.md` §3a, §5a; new `ArtStyle.form`, `rimEdge`, `atmosphere`). The named misses: Urashima and Otohime redrawn at 3 heads; the Anansi climb scene and the Skytree relit from the upper left (the moon moved); `see-river-bank` and `see-forest` given one centred subject; the crocodiles' eyes back to locked screen 03; thirteen folded scenes composed for the phone's band instead of cropped; every unfolded scene recomposed for a tall window (horizon up to 64–70% of the height, the picture grown) and for a squat one; the Urashima sea brought under both panes. The reader keeps the words out of the picture's part of the pane to match (`ReaderMetrics.pictureReserve`; Urashima pages carry `textArea.leadingBottom` 470). The four painters had **no shell at all** in their sessions, so they could not prototype or render: every round-4 picture is arithmetic. Per-picture changes and shortfalls: `Content/ART_PLACEHOLDERS.md`.
- **2. Unfolded iPhone.** `-OmramoPosture unfolded` now lays the two panes over the whole window (scene full-bleed, a 12 pt gutter for the hinge, panes inside the side safe areas, real top and bottom safe areas) and turns an iPhone to landscape. Still the one `PaneLayoutResolver` (`simulationFillsWindow`); `PaneLayout` gained `minimumReferenceScale` (a squat pane keeps the design at about 0.85 × and shows less of a page per screen) and `isSquat`. The letterboxed reference canvas is unchanged (`-OmramoPosture reference`) and no existing layout test was edited.
- **3. Folded card.** A 60% partial sheet with no scrim; the page slides up as one transform so the tapped line sits 14 pt above the card with its beam; close and "Back to my line" only (`PageFit.foldedCardHeight` / `foldedLineShift`, DESIGN §5.9a). Closes gap G4 with our design.
- **4. Story finished.** `StoryFinishedView`: cover with a tick, a soft glow and seven sparks (once), "The end", the title, the story's moral, "Next story" (primary), "Read again", "Library". New content field `Story.moral` (one sentence; rule `moral-incomplete` in both validators; all three stories have one — **draft wording, unreviewed**). Next story chosen by `NextStory` in the core (unread first, the same level first, then up). The story is logged finished when the button is pressed. `-OmramoOpenFinished <id>`.
- **5. Splash and icon.** `SplashView` (wordmark across the hinge on two panes; one line on one pane; 0.65 s + 0.3 s cross-fade; `-OmramoShowSplash`). App icon: `docs/brand/app-icon.svg` → `tools/make_app_icon.py` → `AppIcon.appiconset/AppIcon-1024.png` + `docs/brand/app-icon-1024.png` (and a preview sheet). The icon was rendered and looked at on the box: the "O" as two panes either side of the fold, a low warm sun over water inside it.
- **6. "Aa" panel and back controls.** A finished panel (live preview line, five sizes, the sound switch, the bookmark row); a "Library" capsule with a house instead of the bare chevron; a 46 pt round previous-page arrow beside the page chip (DESIGN §5.1a, §5.1b, §5.2a). Closes G1 and G3 with our designs — they change the look of locked screens 03–07 and 10 slightly.
- **7. Sound (done, optional).** Two short synthesised sounds (`tools/make_sounds.py`; no samples from anywhere), `.ambient` audio session, **off by default**, a switch in the "Aa" panel. Never heard: the levels and the character of both sounds are guesses.
- **8–9. UI tests.** `App/UITests/MotionDemoTests.swift` (four slow demos for `simctl io recordVideo`); `ShotTests` writes `r4-*.png` (round 3's matrix plus finished, splash, the folded card and the unfolded-posture iPhone set in landscape).
- **Tests added (none run):** core `Round4Tests.swift` (32 methods on top of 247); app `App/Tests/Round4Tests.swift` (21 on top of 52); UI `MotionDemoTests` (4), `ShotTests` (25). **One existing assertion was updated, not weakened:** the Python test that pinned Urashima's `textArea` now expects `leadingBottom` 470 as well. No Swift test was edited or removed.
- **How to run:** `docs/BUILD.md` §7c. In short: `swift test --package-path Packages/OmramoCore`; `xcodegen generate` (required: new files, sounds, icon, launch colour); build; ⌘U; then `WordTapTests`, `MotionDemoTests` and `ShotTests` with the `OmramoShots` scheme on an iPad and an iPhone simulator.
- **Untouched, as instructed:** no App Store Connect, signing or submission step; `DEVELOPMENT_TEAM` empty; no prices; no ads, tracking, analytics, accounts, network calls or sign-in; no third-party package (AVFoundation is Apple's); the Q2 decision stands; no `omramo-web` repo was touched. Every earlier debug flag still works. XcodeGen settings stay explicit (the only `project.yml` changes: the app-icon name, four scheme arguments, comments).
- **Riskiest compile and run-time items:** the art (about 11,800 lines, most rewritten blind); the folded page's offset under the card; the story-finished overlay and its second `TwoPane`; the splash task; the single-size app icon set and the launch-screen colour with XcodeGen; the landscape request for the unfolded iPhone. Full list: `docs/BUILD.md` §8c.
- **Honest gaps against an award-level bar** (the round's own list):
  - Nothing has been seen. The art most of all: figure proportions, the relit scenes, every folded composition and every tall recomposition are numbers on a page. Expect a round of fixes on the Mac before any of it is judged, and an illustrator (C1) remains the real answer.
  - The tall-window recomposition scales and re-places the 720 composition; it does not invent a portrait picture. The words now keep clear of it by a rule (37% of the pane), not by a designed page.
  - The unfolded iPhone is a simulation aid: squat panes, two or three screens to a Low page, scenes at a height no locked screen shows.
  - The story-finished moment, the "Aa" panel, the "Library" capsule, the previous-page arrow, the 60% card, the one-pane splash and the icon are **our designs for open gaps**, not Srikanth's; each needs his eye. The splash leaves out the cover discs and origin chips of screen 01.
  - The morals are our draft sentences; showing a moral at all touches PRD Q27.
  - Sounds were made without being heard.
  - Still not built: designed loading and error states, the "My shelf" tab, the map's "Read" pin, the parent view, the grown-up gate, the paywall; type refinements (line breaks, hanging punctuation, word spacing); folded Medium and Advanced type (G8).
  - VoiceOver on the new screens (the modal finished moment, the panel's switch, focus after "Read again") needs a device.
- **Needs Srikanth (nothing here was assumed as decided):** the icon; the splash as built; the story-finished moment and whether a moral is shown (Q27) and its three wordings (with Q22 / Q24); the "Library" capsule and previous-page arrow versus the locked screens; the "Aa" panel; the folded card at 60%; sounds — keep, change or remove; the moon moved in the Anansi story (a visible change from locked screen 04); the crocodile eye restored to screen 03 (round 3's friendlier white eye is gone); plus everything still open from earlier rounds (motion values, Mi numbers, Q14, Q10, Q22, Q24, Q29, Q21).

### 18 Nov 2026 — coding round 5, the stories round: batch 1 of 3 (Fable 5.2, Linux box, branch `feat/r5-stories`)

Round 4 was compiled, run and merged on the Mac as PR #5 (`17e5581`). Round 5 adds the 29 remaining stories of `docs/CONTENT_PLAN.md` in three batches; this is batch 1: the tagline, the morals, the shared illustration kit and the ten new **Low** stories. Srikanth's bar is unchanged (award level, smooth and simple for 6–12, no slop, a real app, Advanced not babyish).

**Decisions Srikanth made for the round (applied, not reopened):**
1. **Tagline: "Turn the page. See the world."** It replaces "A magical book that you read." in `Brand.tagline`, on the splash (left pane "Turn the page.", right pane "See the world."), in README line 1 and in the test that pinned the old wording. It sits under the website's "Read your way around the world". Historical documents and the locked design PNGs keep the old line.
2. **Morals: one clear, kid-friendly sentence each** (short concrete words, no semicolon, at most about 14 words for Low and 18 for Medium / Advanced), keeping the idea of each draft. The three older stories now read: Monkey — "When you are in trouble, stay calm and think." (unchanged); Anansi — "Nobody has all the wisdom, so even a child can teach a grown-up."; Urashima — "Be kind and keep your promises, for lost time never comes back."
3. The finished screen, the icon and the splash stay as designed in round 4 (only the tagline text changed).

- **State: code and content complete, NOT compiled, NOT seen.** No Swift toolchain on the box. Checked by the Python tools (validator 0 errors; 62 + 19 tests pass), by scripts over all 155 Swift files (bracket balance; duplicate declarations; the argument labels of about 19,000 calls into the art types; private or undeclared kit members) and by 24 "be the compiler" reading passes (the kit, the landmarks, each story painter, core + app + tests). The box rebooted mid-batch; the working tree survived, the sub-agents and scratch files did not, and the art half of the batch was re-run from the saved state.
- **Ten new Low stories** (all drafts, `review.text` and `review.art` pending), in plan order after the Monkey story. ⚑ = flagged "needs cultural review before release".

  | Story | People, place | Moral |
  |---|---|---|
  | `shipwrecked-sailor` — The Shipwrecked Sailor | Ancient Egypt | When things go wrong, stay brave and thank those who help you. |
  | `tongue-cut-sparrow` — The Tongue-Cut Sparrow | Japan | Kindness comes back to you, but greed brings only trouble. |
  | `old-man-who-moved-mountains` — The Old Man Who Moved the Mountains | Ancient China | Big things get done a little at a time by people who keep going. |
  | `why-possums-tail-is-bare` — Why the Possum's Tail Is Bare ⚑ | Cherokee, southern Appalachians | Boasting makes you easy to trick, so be proud quietly. |
  | `the-snow-house` — The Snow House (an Omramo original) ⚑ | Inuit, Nunavut, Canada | Careful, patient work holds together, because every block leans on the others. |
  | `peasant-and-bear` — The Peasant and the Bear | Russia | Think and ask before you agree to a bargain. |
  | `bremen-town-musicians` — The Bremen Town Musicians | Germany | You are never too old to be useful to your friends. |
  | `north-wind-and-sun` — The North Wind and the Sun | Ancient Greece | A gentle way often works better than force. |
  | `why-sun-and-moon-live-in-sky` — Why the Sun and the Moon Live in the Sky ⚑ | Efik, Nigeria | Think ahead before you make a big promise. |
  | `lion-and-hare` — The Lion and the Hare ⚑ | Persia | Quick thinking can keep the small safe from a bully. |

  Each: 12–14 pages in two parts, four scenes, three tap-to-see words with culture notes, the plan's landmark moments, two character cards (three in Sun and Moon), the `education` block, a manuscript whose header records the source, every softening and what a reviewer must check. Built from `docs/content/story-specs/<id>.json` by `tools/build_stories.py`.
- **Cultural-review flag.** All twelve §7 stories will carry `culturalReview { level: required, status: pending, reason, community }`; the six in the catalog now do (the four above plus Monkey and Anansi, which already did). In code: `CulturalReview.needsReviewBeforeRelease`, `releaseFlagLine`; a new rule `cultural-review-no-community` in both validators; release mode refuses a flagged story.
- **Ten landmarks** added (14 in the catalog), each with three fact cards and a picture: Sydney Opera House, Himeji Castle, Great Wall, Machu Picchu, Hagia Sophia, Saint Basil's, Bremen Town Hall and Roland, Colossus of Rhodes (a reconstruction), Statue of Liberty, Petra.
- **Illustration kit** (`App/Sources/Art/Kit/`, about 8,200 lines) and **ten story painters** (`App/Sources/Art/Stories/`, about 15,000 lines) and **ten landmark pictures** (`App/Sources/Art/Landmarks/`, about 3,850 lines). `docs/ART_DIRECTION.md` §11; per-story lists and the painters' own shortfalls in `Content/ART_PLACEHOLDERS.md`.
- **Library for a big catalog:** shelves by level on "All", a grid for a chosen level, a quieter map (`docs/BUILD.md` §6, round 5). `NextStory` unchanged and tested on the whole catalog.
- **Tests added (none of the Swift ones run):** core `Round5Tests.swift` (30 methods), app `App/Tests/Round5Tests.swift` (12), UI `ShotTests` `testR5…` (17), Python `tools/test_build_stories.py` (19, run: pass).
- **Existing tests updated — intended changes because the catalog grew or the tagline changed; none weakened:** core `DecodingTests` (`testCatalogDecodes`: the three prototypes within the bigger catalog; `testLibraryLoadsAndListsTheSample`: counts follow the catalog), core `Round4Tests` (every story has a moral, all different; the `NextStoryTests` helper's catalog is the three prototypes), `ReaderCardTests` (`PrototypeContent.allStories()` is the three prototypes), app `Round4Tests` (the tagline halves; the next-story test's catalog), Python `test_catalog_lists_one_story_per_tier`.
- **How to run:** `docs/BUILD.md` §7d.
- **Untouched, as instructed:** no App Store Connect, signing or submission step; `DEVELOPMENT_TEAM` empty; no prices; no ads, tracking, analytics, accounts, network calls or sign-in; no third-party package; no photos or third-party art; the `omramo-web` repo was not touched; every debug flag still works; XcodeGen settings unchanged (new files sit under existing target folders).
- **Honest gaps (the batch's own list):**
  - **Nothing has been compiled or seen**: about 27,000 new lines of Swift, of which the kit is the riskiest (a fault in `Kit.person` or `Kit.beast` shows in most stories). Expect a round of compile fixes and then of visual fixes on the Mac before any picture is judged.
  - **The pictures are thinner than the Monkey story's.** The painters used 1,250–1,650 lines a story against the Monkey's 2,660; scenes lean on kit calls, near-plane framing is often generic, kit figures have a fixed set of side-view poses. Each story has heroes of its own, but "distinct and specific, not a recoloured template" is a claim only eyes can check. An illustrator (C1) remains the real answer.
  - **The texts are drafts by an AI author with an AI editor.** They were read in full by the lead and checked once against their sources, but no child, teacher, editor or cultural reader has seen them.
  - **Sources.** gutenberg.org was unreachable; six sources were read on a mirror afterwards. Three findings stand as open questions in the manuscript headers: Carrick's *Peasant and the Bear* is a different variant from the commonly told one we follow (no second source cited); details of the Sailor follow later translations than Petrie (none cited); Dayrell does not name the Efik for the Sun-and-Moon tale (the attribution follows the plan).
  - **Facts.** Ten landmark entries and thirty culture notes carry details beyond CONTENT_PLAN §5.1 from general knowledge; all `review.facts` pending.
  - **Cultural review has not started** (PRD Q24). The Snow House uses an Inuit girl's name (Elisapie) and three Inuktitut words chosen by us; the Possum story's cards make statements about the Cherokee; none of it has been read by the people concerned.
  - **Library.** Three shelves and a grid are our design for a catalog the locked screen 02 never showed; the map with many pins is quieter but still crowded where regions cluster.
  - Not built: a region filter (CQ11 leaves it open), landmark pins on the map, "Wonders you have seen".
- **Needs Srikanth (nothing here was assumed as decided):** the ten texts and their softenings (each manuscript header lists them); the four new morals where we departed from the suggested wording (Bremen, Peasant and Bear); the name Elisapie and the Inuktitut words until a consultant is found (Q24, Q25); the Efik attribution; whether "loose" landmark links stay (Sydney Opera House, Statue of Liberty — Q28); landmark image rights (Q29: Sydney Opera House most of all); the library shelves; plus everything still open from earlier rounds.
