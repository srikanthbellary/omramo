# Omramo — Product Requirements (v2, global English)

**Status:** v2 design approved and locked by Srikanth, 13 Nov 2026. This document supersedes `docs/PRODUCT.md` (the Telugu-first v1 lock, kept for history).
**Companions:** `docs/ARCHITECTURE.md`, `docs/DESIGN.md`, `docs/IMPLEMENTATION_PLAN.md`.
**Sources:** business case v5 (13 Nov 2026), the 16-point discussion brief, the locked designs-v2 (12 screens in `docs/design/`), the expert assessment of 13 Nov 2026, and `stories/SOURCES.md`.

Conventions used in all four documents:

- **Decided** means it comes from Srikanth's brief, business case v5 or the locked design.
- **Assumption** means I chose it to keep work moving; it can be overturned.
- **TBD — open question** means a number or decision only Srikanth can give. No prices, dates, conversion rates, revenue or user counts are invented anywhere.

---

## 1. Problem

Children who can read are choosing not to. Games and short video are instant and endless, and a page of text loses to them. Most "story" apps respond by turning books into narrated video, which holds attention but replaces reading. Plain ebooks keep the reading but give a child nothing to pull them in: when a story mentions something they have never seen, the moment passes.

Omramo's answer is a **magical book that the child reads**. Illustration and tap-to-see visuals exist only to pull the child into the text and send them back to it.

**Governing rule (decided):** the child reading words on the page is the product. No narrated video, no autoplay, no read-aloud control, and a page turns only when the child presses the page-turn button. If a feature lets a child skip reading, it does not ship.

## 2. Audience

| | Who | What they want |
|---|---|---|
| **Reader** | A child anywhere in the world who can already read English, roughly early to middle grades. Exact ages per tier: TBD — open question (Q2). | Stories worth reading, pictures, things to tap, a shelf that fills up. |
| **Buyer** | The parent (teachers and schools later, not in this scope). | Screen time that is real reading; proof of it in pages read, not minutes; no ads, no tracking. |
| **Device** | Apple's foldable iPhone Duo: two panes either side of a hinge, plus the folded outer screen. | — |

Assumption A1: the app also runs, in single-pane mode, on an ordinary iPhone, because the folded layout is the same layout. Whether that is *shipped* to non-Duo devices is an open question (Q1).

## 3. Goals and non-goals

### Goals

1. A child can open a story at their tier and read it from first page to last on the open Duo and on the folded screen, with reading position carried between the two.
2. Tapping a marked word opens a visual on the facing pane, and one button returns the child to the exact line.
3. Tapping a character name opens a character card the same way.
4. A parent can see what was read (pages, stories, level progress), with no time metric.
5. Anyone can browse every cover and read a two-page sample of any story; a grown-up, behind a gate, can subscribe the family to unlock everything.
6. The app looks and behaves like a modern app, exactly as the 12 locked screens show. It never looks like a hardcover book: no paper, no spine, no serif.
7. The app collects no personal data and contains no third-party code.

### Non-goals (for the MVP)

- Narration, read-aloud, video, autoplay, mini-games, points, currency, timers.
- Accounts, sign-in, a server, remote analytics, push notifications.
- Any language other than English. (The v1 Telugu/Hindi editions are dropped.)
- Simplified or expanded versions of a story in another tier.
- School licences, classroom rosters, teacher reporting.
- A content authoring tool inside the app; the art pipeline itself (ops side).
- App Store submission or App Store Connect set-up. These are future owner actions and are only described, never performed, by this plan.
- Final illustration. The code-drawn art in the designs is concept art and must be replaced by commissioned work (see risks).

## 4. Tiers

**Decided:** three tiers, Low, Medium and Advanced. Every story is unique and belongs to exactly one tier, set by its message and complexity when it is written. A tier is never locked behind its own payment: one subscription covers all tiers. A child may read at any tier at any time.

| Tier | Meaning (business case v5) | Reading type (locked design) | Prototype story |
|---|---|---|---|
| **Low** | Newer independent readers; basic morals | 23.5 / 37 pt, about 55 words a page, text on one pane | *The Monkey and the Crocodile* — Jataka, ancient India |
| **Medium** | Confident readers; a bigger idea | 19.5 / 32 pt, about 90 words a page, text on one pane | *How Wisdom Became the Property of the Human Race* — Anansi, Akan people of Ghana |
| **Advanced** | Strong readers; deeper meaning, longer text | 16.5 / 27 pt, about 190 words a page, text on both panes | *The Story of Urashima Taro* — Japan |

Each story also carries its **origin** (civilization or culture, shown as a map pin and label) because the catalog is meant to teach children about the world's cultures by reading (brief point 16).

Known tension, recorded and not resolved here: the assessment measured the three prototype texts at 952, 384 and 4,229 words, so length does not rise with tier, and it recommends renaming "Low" on child-facing surfaces. The locked design uses the names Low / Medium / Advanced on child-facing screens. This PRD follows the locked design; see Q3.

## 5. Core loop

```
Open app → Splash (OM | RA | MO across the fold)
        → Library: "Keep reading" or pick a story by level
        → Read a page → (tap a marked word → visual on the facing pane → "Back to my line")
        → press the round button → next page … → story finished
        → shelf fills, friends met, streak day counted, map pin turns "read"
Not subscribed: pages 1–2 of any story are free → "The free sample ends here"
        → "Ask a grown-up to unlock" → grown-up gate → Family subscription
Parent: Grown-ups tab → gate → pages read, level progress, settings
```

Everything a child earns comes from reading: a page counts when it is turned after reading; a day counts toward the streak when at least one page is read that day; a story joins the shelf when its last page is turned; a character becomes a "friend you have met" when the child first meets them in the text.

## 6. Features and priority

**P0** = required for the MVP (first family TestFlight). **P1** = required before a public release. **P2** = later.

### Reading

| # | Feature | Priority | Notes |
|---|---|---|---|
| R1 | Two-pane reading spread: one continuous scene under both panes and the hinge; text in the calm part of the scene | P0 | Screens 03, 04, 05 |
| R2 | Three tier type systems (size, line height, weight, lead sentence) | P0 | `docs/DESIGN.md` §3 |
| R3 | Word-level styling: lead sentence, voice colour with face chip, character names, sound and motion words | P0 | Wording is never changed; only typographic quotes and dashes |
| R4 | Page turn only by the round button (and a back control); no swipe-through autoplay | P0 | Whether a swipe gesture also turns the page: Q13 |
| R5 | Folded single-screen reading with art above the text | P0 | Screen 10 |
| R6 | Reading position kept across fold/unfold and across launches, anchored to story + page + paragraph | P0 | |
| R7 | Page indicator ("1 / 14") and tier and origin chips | P0 | |
| R8 | Text-size control ("Aa") | P1 | Shown in design as a button; the panel itself is not designed — design gap G1 |
| R9 | Bookmark | P1 | Button shown; behaviour not designed — design gap G2 |
| R10 | "Story finished" moment | P1 | Not designed — design gap G3 |

### Tap-to-see and characters

| # | Feature | Priority | Notes |
|---|---|---|---|
| T1 | Marked words (soft highlight, underline, spark) open a visual on the **facing pane**; the text pane does not move | P0 | Screen 06 |
| T2 | While open: the tapped paragraph stays at full strength with an orange place marker; other paragraphs dim | P0 | |
| T3 | Card content: one picture, a title, one line to read, one culture note with a pin, one button "Back to my line". No onward links | P0 | |
| T4 | Return: card closes, marker and a brief toast show the same line, the word is marked as seen | P0 | Screen 06b |
| T5 | Character card from a dotted-underlined name, same mechanics | P0 | Screen 07 |
| T6 | On Advanced spreads (text on both panes) the card covers the far pane, never the line being read | P0 | |
| T7 | Folded tap-to-see | P0 | Not designed — design gap G4. Assumption A2: a card rises from the bottom over at most the art area and the tapped line stays visible |

### Library and rewards

| # | Feature | Priority | Notes |
|---|---|---|---|
| L1 | Library home: "Keep reading" card, stories filtered by level, story cards with tier pill and origin | P0 | Screen 02 left |
| L2 | Story map ("Where the stories come from") with read / reading-now / later pins | P1 | Screen 02 right |
| L3 | Streak: a day counts when a page is read; week row | P1 | Assessment recommends "reading days" with no penalty; locked design shows a streak. See Q10 |
| L4 | My shelf: finished and in-progress stories | P1 | Card is designed; the full "My shelf" tab is not — design gap G5 |
| L5 | Friends you have met | P1 | |
| L6 | Tab bar: Library, My shelf, Grown-ups | P0 | |
| L7 | Folded library | P0 | Not designed — design gap G6. Assumption A3: the two panes stack into one scroll |
| L8 | Splash with the OM \| RA \| MO mark across the hinge | P1 | Screen 01. M1 may use a plain launch screen |

### Parents, sample and subscription

| # | Feature | Priority | Notes |
|---|---|---|---|
| S1 | Grown-up gate (adult-level task) in front of the parent view, purchase, and every external link | P0 | Mechanic in the design (type three numbers given as words) is a concept — Q9 |
| S2 | Parent view: pages read in the last 7 days, stories finished, cultures visited, days in a row, level progress. **No time metric of any kind** | P0 | Screen 08 |
| S3 | Settings rows: Appearance, Manage Subscription, Restore Purchases, Privacy, Terms and legal | P0 | Dark appearance is not designed — design gap G7 |
| S4 | Free sample: browse all covers; read the first two pages of any story | P0 | Screen 09 left. Assessment recommends a whole free book per tier — Q6 |
| S5 | End-of-sample card: "Ask a grown-up to unlock". The child never sees a price or a buy button | P0 | |
| S6 | Family subscription screen behind the gate: plan card with StoreKit price, Subscribe, Restore Purchases, renewal terms, Terms of Use, Privacy Policy | P0 | Screen 09b |
| S7 | Family Sharing on the subscription | P0 | Enabled in App Store Connect by the owner (future action) |
| S8 | Entitlement cached for offline reading | P0 | |
| S9 | Local reader profiles for siblings on one device | P2 | Not in the design — Q11 |

### Content and platform

| # | Feature | Priority | Notes |
|---|---|---|---|
| C1 | Versioned JSON story format with tiers, spreads, text runs, tap targets, character cards, art references | P0 | `docs/ARCHITECTURE.md` §6 |
| C2 | Three prototype stories bundled in the app; fully offline | P0 | One per tier |
| C3 | Content validator (text matches source, every tap target has a card and alt text) | P0 | |
| C4 | Downloadable story packs | P2 | |
| C5 | VoiceOver through a whole story, Reduce Motion, contrast checks, text scaling | P1 | System accessibility is never disabled, including spoken text |
| C6 | Real Duo SDK hookup (posture and hinge geometry) | P0 for Duo release, blocked on Q4 | Until then the app uses its own pane abstraction and a simulated Duo layout |

## 7. Screens

All 12 locked screens. Detailed specs are in `docs/DESIGN.md` §6.

| # | Screen | File | Purpose |
|---|---|---|---|
| 01 | Splash | `docs/design/01-splash.png` | OM \| RA \| MO mark split by the hinge; "A magical book / that you read." |
| 02 | Library home | `docs/design/02-library-home.png` | Keep reading, stories by level, story map, streak, shelf, friends |
| 03 | Reading, Low | `docs/design/03-read-low.png` | Text left, scene across both panes |
| 04 | Reading, Medium | `docs/design/04-read-medium.png` | Twilight scene, light text |
| 05 | Reading, Advanced | `docs/design/05-read-advanced.png` | Text on both panes; text on a path |
| 06 | Tap-to-see open | `docs/design/06-tap-to-see-open.png` | Visual on the facing pane, line held |
| 06b | Tap-to-see return | `docs/design/06b-tap-to-see-return.png` | Back at the same line, word marked seen |
| 07 | Character card | `docs/design/07-character-card.png` | Card for a named character |
| 08 | Parent view | `docs/design/08-parent-view.png` | Pages read, level progress, settings |
| 09 | End of sample → gate | `docs/design/09-sample-paywall.png` | "Ask a grown-up", grown-up gate |
| 09b | Family subscription | `docs/design/09b-family-subscription.png` | Plan card (price TBD), subscribe, restore |
| 10 | Folded reading | `docs/design/10-folded.png` | Single-screen reading, Low tier |

### Design gaps (screens or states the locked set does not cover)

These need either a design pass or Srikanth's agreement that engineering derives them from the existing components.

| ID | Gap |
|---|---|
| G1 | The "Aa" text-size panel |
| G2 | Bookmark behaviour and where bookmarks are listed |
| G3 | Story-finished screen, and the last page's button state |
| G4 | Folded tap-to-see and folded character card |
| G5 | The full "My shelf" tab |
| G6 | Folded library, folded parent view, folded gate and subscription |
| G7 | Dark appearance for the library and parent view ("Appearance: Automatic" row exists) |
| G8 | Folded type for Medium and Advanced (only Low, 22.5 / 35 pt, is drawn) |
| G9 | Story opening: whether tapping a cover goes straight to page 1 or to a cover/detail page |
| G10 | Loading, empty and error states; "purchase pending" (Ask to Buy) state |
| G11 | Motion: no animation is specified by static screenshots |
| G12 | App icon |

## 8. Monetisation shape

- **Decided:** one auto-renewing **family subscription** through StoreKit 2 and the Apple Account, unlocking the whole library across all tiers. Family Sharing on. Free: browse every cover, read the first two pages of any story. No ads. Purchases only behind the grown-up gate.
- **Price:** TBD — open question (Q7). The app never hardcodes a price; it shows the localized price StoreKit returns. The design shows "TBD".
- **Plan structure:** TBD — open question (Q7): one plan or monthly + yearly; free trial or not. The locked screen shows a single plan card.
- **Publishing cadence** that justifies a subscription ("new stories added"): TBD — open question (Q8).
- **Later, not committed:** school licences, story packs.

## 9. Success metrics (definitions only; no targets set)

The app sends no analytics (see `docs/ARCHITECTURE.md` §10). These are measured in consented, moderated family tests by reading the on-device log, and from Apple's own aggregate App Store reports. Targets: TBD — open question (Q12).

| Metric | Definition |
|---|---|
| **Pages read per session** | Count of pages turned forward after being displayed, per app session, per child. A "page" is one authored spread (the unit the page indicator counts), so it is the same folded and unfolded and at any text size. |
| **Story completion rate** | Stories whose last page was turned ÷ stories whose first page was turned, per child. |
| **Unprompted return days** | Days in a take-home period on which at least one page was read. |
| **Novelty decay** | Pages read in week 2 ÷ pages read in week 1 of a take-home test. |
| **Return-to-text rate** | Tap-to-see openings that are followed by a forward page turn on the same page ÷ all tap-to-see openings. |
| **Taps per page** | Tap-to-see and character-card openings ÷ pages read. Watched for "tapping instead of reading". |
| **Fast-flip share** | Pages turned sooner than a plausible minimum reading time for their word count ÷ pages turned. The minimum is a parameter to set with an educator: TBD. Used only in tests, never shown as a time to parents. |
| **Sample-to-gate rate** | Sessions that reach the end-of-sample card and tap "Ask a grown-up" ÷ sessions that reach the card. Local test metric only. |
| **Paid conversion** | Read from App Store Connect aggregates by the owner. No in-app measurement. |
| **Comprehension guardrail** | In tests: unprompted retelling scored by an educator, with and without tap-to-see. |

## 10. Risks

| Risk | Effect | Mitigation in this plan |
|---|---|---|
| **Duo developer API is unknown to this team.** Pane sizes (432 × 720 pt), the 28 pt hinge gap and the status-bar split in the designs are assumptions, not Apple specifications. | Layout could be wrong on hardware. | A `PaneLayout` abstraction with a fallback and a simulated Duo mode; all geometry read from one place; hardware check is its own milestone. |
| **Art is concept only.** Every illustration in the designs is code-drawn SVG. | The app cannot ship with it; commissioned art is the long pole and the main cost. | Asset pipeline and sizes specified now; placeholder art in M1; art production tracked outside the code plan. |
| **Cultural accuracy.** Kente and Adinkra drawings, the Urashima palace, and the culture note in screen 06 are unreviewed. The source texts are 1908–1917 retellings with period wording. | Reputational harm to a children's brand. | `review` fields in the content format; release checklist blocks unreviewed content. Reviewer budget: Q5. |
| **Rights outside the US.** US public-domain status is recorded for all three texts; outside the US only Ozaki (d. 1932) is confirmed. | A global launch of the exact texts is not cleared. | Per-story `source` and `rights` record; Q5. |
| **Tier calibration.** The three prototype texts do not rise in length with tier; the Medium story is 384 words, so a two-page sample is a large share of it. | Tiers may not mean what parents expect; sample gives away too much of short stories. | Sample length is a per-story field; Q3 and Q6. |
| **"Pages read" can be inflated by flipping.** | Parents lose trust in the one metric shown. | Honest wording in the parent view; fast-flip share measured in tests; a minimum-dwell rule is an open question (Q14). |
| **Kids Category and children's privacy (COPPA, GDPR-K).** | Rejection or legal exposure. | Collect nothing, no third-party SDKs, gate before purchase and links; legal review is an owner action. |
| **Small Duo install base; the child is not the device owner.** | Habit cannot form on a borrowed phone. | Single-pane mode works on any iPhone if Srikanth chooses to ship there (Q1). |
| **No Swift toolchain on the development box.** | M1 code is checked by reading, not compiling. | Pure-Swift core with tests that run the moment a Mac is available; `docs/BUILD.md`; small, conventional code. |
| **Thin catalog behind a subscription.** | "Ongoing value" is weak with three books. | Q8. |
| **Fixed tier type sizes versus accessibility text sizes.** | Larger text may not fit a designed page. | Pages are authored units; overflow continues on a continuation screen of the same page (see `docs/ARCHITECTURE.md` §12). |

## 11. Assumptions (consolidated)

| ID | Assumption |
|---|---|
| A1 | The app runs in single-pane mode on an ordinary iPhone and in the simulator; whether it is distributed to non-Duo devices is Q1. |
| A2 | Folded tap-to-see is a bottom card that keeps the tapped line visible. |
| A3 | Folded library stacks the two panes into one scroll. |
| A4 | A "page" in all counts and in the page indicator is one authored spread. |
| A5 | The prototype stories use the public-domain texts unaltered (typographic quotes and dashes only), as in the locked design, until Q5 is answered. |
| A6 | Page counts in the designs (14, 6, 19) and all numbers in the library and parent view are sample data; real counts come from the authored content. |
| A7 | Minimum iOS is 18.0 until the Duo SDK says otherwise (see `docs/ARCHITECTURE.md` §2). |
| A8 | Bundle identifier stays `com.omramo.app` as in the earlier scaffold; product identifiers are placeholders until Q7. |
| A9 | One child per device for the MVP (no profiles). |
| A10 | Streak follows the locked design ("5 days in a row") rather than the assessment's "reading days". |
| A11 | Inter in the designs stands in for the system font; the shipped app uses San Francisco for system chrome, as the design notes say. See Q15. |

## 12. Open questions for Srikanth (consolidated)

**Device and platform**

- **Q1. Devices.** Is the release Duo-only, or may the single-pane mode ship on ordinary iPhones (and a two-pane mode on iPad)? This sets the device family and the minimum iOS version.
- **Q4. Duo hardware and SDK.** Is a Duo available to the team? Which Xcode and iOS SDK version carries the Duo APIs, and what are the real pane sizes, hinge width and posture API? The earlier scaffold refers to `ArrangementView` and `GeometryProxy.reservedRegions(kind: .division)` in an "iOS 27.1 SDK"; I could not verify these. Has the earlier scaffold ever been run on a device?
- **Q16. Mac build machine.** Which Mac and Xcode version will build and test M1, and who runs it?
- **Q17. Earlier PRs.** May PRs #1 and #2 (the Telugu-first scaffold) be closed once the v2 scaffold lands? Nothing is merged from them; ideas reused are listed in `docs/ARCHITECTURE.md` §16.

**Audience and tiers**

- **Q2. Ages.** What age range does each tier target, and which Kids Category age band (5 and under, 6–8, 9–11) does the app sit in? Or does it stay out of the Kids Category?
- **Q3. Tier names and calibration.** The locked design prints "Low" on child-facing screens; the assessment advises a neutral name. Keep Low / Medium / Advanced? Is a written tier specification (word counts, sentence length) wanted before more stories are written?

**Content**

- **Q5. Text, art and review.** Ship the public-domain texts as written, or commission original retellings? Who illustrates (human, AI-assisted, mixed), who directs art, and is there budget for a cultural reviewer per story and a rights check outside the US? For Urashima: keep the death ending, the closing moral, and the tobacco and sake passages?
- **Q8. Catalog and cadence.** How many stories per tier at launch, and what publishing cadence can the subscription promise?
- **Q18. Page breaks.** May engineering paginate the three prototype texts (about 55 / 90 / 190 words a page), or will an editor supply the page breaks, tap words and card texts? M1 needs this for the Low story only.

**Monetisation**

- **Q6. Sample.** Keep the two-page sample for every story (locked), or move to one free whole story per tier as the assessment recommends? Should very short stories have a shorter sample?
- **Q7. Price and plans.** Price: TBD. One plan or monthly + yearly? Free trial? Final product identifiers and subscription group name? Does "family subscription" mean one plan with Apple Family Sharing on (my reading), or a separate family tier?

**Behaviour**

- **Q9. Grown-up gate.** Is "type three numbers written as words" the final mechanic? It must count as an adult-level task for App Review.
- **Q10. Streaks.** Keep "days in a row" as designed, or switch to non-punishing "reading days"?
- **Q11. Siblings.** Are local reader profiles needed for the MVP, or is one child per device acceptable?
- **Q13. Page turn.** Button only (as designed), or also a swipe?
- **Q14. Counting a page.** Count every forward turn (as the parent view says: "A page counts when your child turns it after reading"), or require a minimum time on the page? A minimum must never surface as a clock.
- **Q19. Read-aloud.** Does "no read-aloud" hold absolutely, or is on-request single-word or single-sentence audio acceptable later? (System VoiceOver is never blocked either way.)

**Measurement and legal**

- **Q12. Targets and testing.** Who sets the success thresholds, and can 8–12 families be recruited for moderated tests? Is "no remote analytics at all" accepted?
- **Q15. System font.** Confirm San Francisco (system) for settings rows and the keypad in the shipped app, with Inter bundled only if you want pixel parity with the screenshots.
- **Q20. Legal and identity.** Who writes the Privacy Policy and Terms (the app links to `omramo.com/privacy` and `/terms`)? Has a children's-privacy lawyer been engaged? Is the Apple developer organisation account in place, and is `com.omramo.app` the bundle identifier to keep?
- **Q21. Design gaps G1–G12** (§7): another design pass, or derive from existing components and review in the build?
