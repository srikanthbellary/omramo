# Omramo — agent handoff

Last updated: 13 Nov 2026, 8:46 PM ET (America/New_York). Read this first, then `docs/PRD.md`.
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
- Debug launch arguments: `-OmramoPosture unfolded|folded`, `-OmramoOpenStory <story-id>` (e.g. `monkey-and-crocodile`).
- Details in `docs/BUILD.md`.

## 8. Next milestones

See `docs/IMPLEMENTATION_PLAN.md`. Immediate next steps after the first green Mac build:
1. Visual check of Library and Low-tier Reading against `docs/design/` (including `TextRenderer`, item 1.17 / BUILD §7.9). List every gap versus Apple Design Award / locked v2 quality.
2. Srikanth still needs to answer remaining blocking questions (PRD §12; especially Q4 Duo SDK, Q7 pricing/plans, Q18 page breaks, Q22 retellings, Q23–Q24 rights and cultural reviewers, Q30 sensitive content / exact age rating). Q1 and Q2 are decided.
3. M2 complete reader, M3 tap-to-see + character cards, Mi iPad layout (parallel after M2), …; content milestone C1 in parallel.

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
