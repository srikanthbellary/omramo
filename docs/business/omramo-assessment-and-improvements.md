# Omramo: expert assessment and improvement review

**Date:** 13 Nov 2026 · **For:** Srikanth · **Reviewed against:** the 16-point discussion brief and business case v5

## Verdict

Omramo is buildable. The app is a small, well-understood piece of Swift/SwiftUI work; nothing in the brief needs unproven technology. The hard parts are elsewhere:

1. **Content, not code, is the cost and the schedule.** Every book needs an original retelling, a full set of page illustrations, a set of tap-to-see visuals, and a cultural review. That is the business.
2. **The tier system as written does not hold together.** The three prototype stories already break it: the Medium book is less than half the length of the Low book, and the Advanced book is eleven times the length of the Medium one.
3. **Duo-only is the largest avoidable risk.** The child is rarely the owner of a brand-new foldable phone. The same layout works on iPad and degrades cleanly to an ordinary iPhone; ship all three.
4. **"The child must read" cannot be enforced, only invited.** The app cannot tell whether a child read a page. The rule should become "nothing else in the app is more interesting than the next page", and "pages read" needs an honest definition.
5. **The two claims Omramo must prove (tap-to-see and the fold) are cheap to test before building the product.** Test them first, with pages read as the measure.

## How to read this document

- **[unverified]** marks any fact I could not confirm from the project files or from a page fetched this session. That includes Apple platform facts I know from general experience but whose documentation pages returned no body text when fetched.
- Effort, timeline and page-count figures are **my estimates**, labelled as such. They are not statistics.
- No prices, market sizes or user counts are given except those already in the 7 Nov competitor file, cited to it.

**What I read:** the brief, business case v5, `stories/SOURCES.md`, the three story texts in `stories/text/` (the extracted text of the PDFs), the 7 Nov competitor analysis, product direction (13 Sep), content ingest, the foldable-reader and rights pointer files, and the Duo tracker.

**What I could not read:** the two canonical research documents those pointer files link to (the foldable-reader brief and the full rights research) sit outside this session's permitted folders. My comments on rights and foldable lessons rest on the pointers and `SOURCES.md` only.

**What I measured:** word counts and sentence-ending punctuation counts of the three story bodies with `wc`/`grep`. A proper readability script was not permitted to run in this session, so no Flesch-Kincaid or Lexile figures are given.

| Story (tier) | Words | Approx. words per sentence | Culture as recorded |
|---|---|---|---|
| The Monkey and the Crocodile (Low) | 952 | about 10 | Ancient India, Buddhist Jataka |
| How Wisdom Became the Property of the Human Race (Medium) | 384 | about 14 | Akan (Fante/Asante), present-day Ghana |
| The Story of Urashima Taro (Advanced) | 4,229 | about 19 | Japan |

Sentence length is approximate: it divides words by a count of `.`, `!` and `?`, which over-counts sentences where abbreviations such as "Mr." appear.

---

## 1. Feasibility

### 1.1 Overall

| Area | Feasibility | Main caveat |
|---|---|---|
| Two-pane reader, folded fallback | High | Duo fold APIs and postures not verified here |
| Tap-to-see | High | Accessibility and Dynamic Type need design up front, not afterwards |
| Content packaging | High | Needs an authoring tool, or annotation becomes the bottleneck |
| StoreKit 2 subscription, Family Sharing | High | Purchase must sit behind a parental gate; a three-book catalog is weak "ongoing value" |
| Kids Category, COPPA, GDPR-K | Medium-high | Easy only if the app collects nothing; one age band must be chosen |
| Offline reading | High | Trivial if books are bundled or fully downloaded |
| Content production at catalog scale | **Medium-low** | Cost, consistency and cultural accuracy of art |

### 1.2 Two-pane layout, fold and hinge, folded fallback

**What the files and fetched pages establish**
- The Duo went on pre-order 16 Oct 2026 and shipped 23 Oct 2026 (`duo-app-tracker.md`). So the device is about three weeks old and the install base is, at best, early.
- Apple's developer hub for the device exists and loaded. It points to two sessions, "Strike a pose with adaptive layouts on iPhone Duo" and "Leverage multiple displays and scenes on iPhone Duo", and to an article on updating apps "to dynamically resize and adjust its layouts for iPhone Duo" (https://developer.apple.com/iphone-duo/).
- The HIG page "Designing for iPhone Duo" exists but returned only its title when fetched, so its guidance on the fold is **[unverified]** here.
- A scaffold PR with "fold P0s" already exists in the repo (`duo-app-tracker.md`); I have not seen it.

**What is not established:** screen sizes, aspect ratios, whether the inner display shows a visible crease or seam, which postures exist (for example a half-open "tent" or "laptop" posture), and the API for detecting them. All **[unverified]**. The session titles suggest adaptive resizing and scenes are the official mechanism, which is a reasonable planning assumption and no more.

**Recommended approach (robust to those unknowns)**
- Build the reader around an abstract **layout mode**, not a device check: `spread` (two panes) and `single` (one pane). Derive the mode from the container's size, never from the device model. This is what makes iPad and ordinary iPhones nearly free later.
- Treat the middle of the spread as a **book gutter**: no text, no tap targets and no essential part of an illustration within a margin either side of the centre line. This is correct whether or not the hardware has a visible fold, and it is what a printed book does anyway.
- **Continuity between outer and inner screens** (v5 feature 9, and the P0 from the foldable-reader pointer): store the reading position as a stable content anchor (story, beat, paragraph), not as a page number or scroll offset. Folding and unfolding then becomes a re-layout around the same anchor. Preserve an open tap-to-see card across the transition too.
- **Folded single-screen fallback:** text fills the screen; the page illustration sits above the text or as a full-bleed header that the child scrolls past. Tap-to-see opens as a card from the bottom that covers at most half the screen, and the text scrolls so the tapped line stays visible above it. This is the direct answer to v5's claim that "a single phone screen would have to pop over the story": it would, but partially and without losing the place.
- Which pane holds text should be a setting (left-handed children, right-to-left scripts later).

**Risk:** moderate until someone on the team has run the scaffold on real hardware and read the HIG page. Budget a week for this before committing to layout details.

### 1.3 Tap-to-see implementation

**Data model.** Each paragraph of story text is stored as plain text plus stand-off annotations: `{entityId, start, end}` ranges. Entities live in a separate file: `id`, `type` (place, character, object, creature, idea, word), `title`, `caption` (the one or two lines the child reads), `asset`, `altText`, `cultureNote`, and a `reviewedBy` field for the cultural sign-off. Keeping annotations outside the prose means editors can change either without breaking the other.

**Rendering options, in order of preference**

| Option | How | For | Against |
|---|---|---|---|
| A. Attributed text with link runs | Build an `AttributedString` per paragraph; give each entity range a link with a private scheme (for example `omramo://entity/taj-mahal`); intercept the tap with SwiftUI's URL-opening environment action and open the visual instead of a browser | Least code; real text, so selection, Dynamic Type and VoiceOver come for free; links are announced as links | Does not hand you the on-screen rectangle of the tapped word, so no "visual grows out of the word" animation |
| B. TextKit-backed text view wrapped for SwiftUI | A `UITextView` with custom attributes and hit-testing | Gives glyph rectangles for animation, custom underline styles, precise hit areas | More code; must re-do some accessibility work |
| C. Each word as its own view in a flow layout | Custom layout | Full control | Breaks screen-reader reading order, hyphenation and performance; avoid |

Option A's API behaviour is from general SwiftUI knowledge; the Apple documentation pages for `Text` and `AttributedString` returned only titles when fetched, so treat it as **[unverified]** until confirmed in Xcode, which takes an hour. Start with A for the prototype and move to B only if the word-to-visual animation proves to matter in testing.

**Dynamic Type and pagination.** This is the one real design problem in the reader. A "page" that reflows with text size means the page count of a book changes per child and per device, which breaks "pages read" as a parent metric and breaks a fixed pairing of page and illustration.
- Author each story as a sequence of **beats**: a group of paragraphs tied to one illustration. The beat is the unit of content, of illustration and of saved position.
- Within a beat, text paginates dynamically to whatever fits at the current text size. A beat may be one screen at default size and three at the largest accessibility size; the illustration stays put.
- Report **standard pages**: words read divided by a fixed words-per-page figure for the tier. A child at large type and a child at small type get the same credit for the same book.

**Accessibility**
- Tappable entities must be reachable and announced by VoiceOver ("Taj Mahal, shows a picture"), and by Switch Control and keyboard.
- Entities must not be marked by colour alone; use an underline or a small mark as well.
- Every illustration and tap-to-see visual needs alt text in the package. This is a content cost, so put it in the schema from day one.
- Respect Reduce Motion for the "lightly animated" visuals.
- **A conflict to resolve:** v5 says "no default read-aloud". A child using VoiceOver has the text spoken by the system, and that must not be blocked. State explicitly that system accessibility features are never disabled.

### 1.4 Content packaging

**Story bundle format (proposed)**

```
urashima-taro/
  manifest.json      schemaVersion, storyId, contentVersion, title, tier, sub-level,
                     culture/origin, word count, readability measures, min app version
  rights.json        source editions consulted, adaptation notes, art credits, licences, territories
  text.json          beats → paragraphs → text + entity ranges
  entities.json      tap-to-see cards and characters (see 1.3)
  art/               page illustrations and entity visuals, with alt text in the JSON
  cover/             cover, spine, thumbnail
  sample.json        which beats are free
```

- This follows the existing ingest direction (catalog of packaged titles, JSON and images, bundled for the prototype). EPUB is not worth adopting: tap-to-see and beats are custom, and nothing else needs to open these files.
- **Stable IDs** for stories, beats and entities are what keep reading progress and collections intact when a book is corrected.
- **Illustration assets:** ship one high-resolution master per image in a modern compressed format and let the app downscale. Budget app size from real art; I am not giving a megabyte figure without it. "Lightly animated" should mean layered stills moved in code (parallax, a slow drift), not video files. That keeps size down and stays inside the "not video" rule.

**Delivery**

| Stage | Mechanism | Why |
|---|---|---|
| MVP, three books | Inside the app bundle | No server, no network, works offline at first launch, simplest review |
| v1 catalog | Remote catalog index plus one downloadable package per story | App stays small; books added without an app release |

- For hosting, the two Apple routes are On-Demand Resources and Background Assets. The ODR guide sits in Apple's documentation archive, last updated 2017 (https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/On_Demand_Resources_Guide/); it carries no explicit deprecation notice, but I would not start new work on it. Background Assets is the current framework, with Apple-hosted asset packs as an option **[unverified: the documentation page returned only its title]**.
- Prefer **Apple-hosted** packages if available to you. A self-hosted CDN works, but your server then sees device IP addresses, which becomes a children's-privacy disclosure. Apple hosting keeps Omramo out of that data path.
- **Versioning:** `schemaVersion` (app refuses packages newer than it understands), `contentVersion` (per story), and a catalog version. Integrity-check each package before use.

**The missing piece is an authoring tool.** Someone has to mark every tappable range, write every caption and alt text, and preview the spread. Hand-edited JSON is fine for three books and unworkable for thirty. Plan a simple internal web tool.

### 1.5 StoreKit 2 family subscription and Family Sharing

- StoreKit 2 with auto-renewing subscriptions, no Omramo account, entitlement held by Apple, system manage/restore surfaces: already locked on 14 Sep, and correct.
- **"Family subscription" needs a definition.** The simplest reading is one subscription with Apple's Family Sharing switched on, so the purchaser's family group shares it at no extra charge. That is a setting in App Store Connect plus checking entitlements that arrive as family-shared. Details such as whether the setting can later be switched off, and the size of a family group, are **[unverified]**: the StoreKit Family Sharing page returned only its title.
- **Multiple children on one device** is a separate need. Family Sharing does not give you per-child progress. Add local reader profiles (a name and an avatar, stored on the device, no account). Without them "pages read" for two siblings on one Duo is meaningless.
- **Guideline constraints (fetched, https://developer.apple.com/app-store/review/guidelines/):** subscriptions must run at least seven days, be available across the user's devices, and provide ongoing value (from the fetch summary of 3.1.2). Two consequences: a Duo-only app still has to honour the subscription on whatever else it later runs on; and a three-book library is a thin case for "ongoing value" unless new books arrive on a stated schedule.
- **Offline:** cache the last verified entitlement so a subscribed child can read on a plane.

### 1.6 Kids Category, COPPA and GDPR-K

**Fetched facts**
- Kids Category apps "must not include links out of the app, purchasing opportunities, or other distractions to kids unless reserved for a designated area behind a parental gate" (guideline 1.3, same URL as above).
- They "should not include third-party analytics or third-party advertising"; limited exceptions exist for analytics that collect no identifiable information.
- "For Kids" and "For Children" in app metadata are reserved for the Kids Category (2.3.8).
- A parental gate is "generally not the same as securing parental consent" under privacy law (fetch summary of 5.1.4).
- You must choose an age band: "ages 5 and under, 6-8, or 9-11"; and Kids apps "should not transmit personally identifiable information or device information to third parties — even in sections intended for adults — unless the parent explicitly consents" (https://developer.apple.com/app-store/kids-apps/).
- COPPA applies to services "directed to children under 13" (https://www.ftc.gov/legal-library/browse/rules/childrens-online-privacy-protection-rule-coppa). That page links to amended rule text dated 22 Apr 2025; its compliance dates were not shown and are **[unverified]**.

**What this means for Omramo**
- **The paywall flow in the product direction must change.** "Sample, then subscribe popup" shows a purchasing opportunity to the child. In the Kids Category the child should instead see a friendly "Ask a grown-up to unlock the library" page; prices and the purchase sheet appear only after the parental gate.
- **The age band is a real decision.** Three tiers for "early to middle grades" plausibly span both 6-8 and 9-11. Pick the band that matches the centre of the catalog, or stay out of the Kids Category (losing "for kids" wording in metadata). COPPA applies either way, because the app is directed at children.
- **Collect nothing.** Keep profiles, progress, streaks and the bookshelf on the device. No accounts, no third-party SDKs of any kind (check every dependency), no remote analytics. Then verifiable parental consent mostly does not arise, and the App Store privacy label can honestly say no data is collected **[unverified: confirm label wording against Apple's current definitions]**.
- **Consequence for measurement:** you cannot instrument children remotely. The pages-read evidence in section 4 has to come from consented, moderated family tests with data read off the device, plus Apple's own aggregate App Store analytics.
- **GDPR-K and the UK children's code:** the age of digital consent varies by EU member state, and design-code duties apply in the UK **[unverified: not fetched]**. The collect-nothing design is the right default for both, but get a children's-privacy lawyer to review before a global launch. The competitor file says the same: its privacy notes are "not a compliance clearance".
- **Parental gate:** Apple describes gates as "adult-level tasks". One gate component, reused in front of the paywall, settings, the parent view, and every external link including Privacy and Terms.
- **No notifications aimed at the child.** Streak reminders, if any, go to the parent and are opt-in.

### 1.7 Offline reading

Trivial for the MVP (books are in the bundle). For v1: a downloaded book is fully local; show download state on the cover; let parents manage storage; cache entitlement. The competitor file records that Epic and BOOKR already offer offline downloads, so this is expected, not a differentiator.

### 1.8 Effort, team and timeline (my estimates)

**Assumptions:** Apple developer organisation gate cleared (listed as a hard gate in the tracker); a Duo in hand; original retellings; new art for every page; layout supports Duo, iPhone and iPad from one codebase.

**Illustration load, estimated from the measured word counts.** Page densities are my assumptions, to be replaced by the design mockups.

| Book | Words | Assumed words per page | Approx. pages / illustrated beats | Tap-to-see visuals (assumed) |
|---|---|---|---|---|
| Monkey and the Crocodile | 952 | 50-70 | 14-19 | 6-10 |
| How Wisdom… (Anansi) | 384 | 80-100 | 4-5 | 4-6 |
| Urashima Taro | 4,229 | 150-200 | 21-28 | 15-25 |

So three prototype books need very roughly 40-50 page illustrations and 25-40 tap-to-see visuals, plus covers and character sheets, all in a consistent house style.

**A. Proof prototype (to run the tests in section 4)**
- One iOS engineer, one designer; placeholder or draft art; one book fully built and a second partially.
- **3-5 weeks.**

**B. MVP with three books, to TestFlight and then the App Store**

| Workstream | People | Elapsed |
|---|---|---|
| App: reader, tap-to-see, layout modes, library, profiles, bookshelf, parent view, StoreKit, parental gate, settings, accessibility pass | 1 senior iOS engineer full-time (a second halves the risk, not the time) | 10-14 weeks |
| Design: reader, library, brand, illustration direction | 1 product designer / art director, most of full-time | throughout |
| Text: three original retellings, levelling, captions, alt text | 1 children's editor, part-time; 1 reading specialist, a few days | 4-6 weeks |
| Art: roughly 70-90 finished images | 1-2 illustrators, or an AI-assisted pipeline with a human art director correcting every image | 8-12 weeks, the long pole |
| Cultural review | 1 paid reviewer per culture (three) | 1-2 weeks each, in parallel |
| Privacy/legal review, QA, App Review | part-time | 2-3 weeks |

**About 4 months to a family TestFlight and about 5 months to an App Store release**, with a core team of 4-5 people, several part-time. The engineering alone could be done faster; the art and review cannot.

**C. v1 catalog**
- "Enough unique stories in each tier" (v5 feature 7) is undefined. If it means around ten books per tier, that is thirty books; scale the table above accordingly.
- Team: 1-2 iOS engineers, a content lead/editor, an art director with 2-4 illustrators (or the pipeline equivalent), a part-time reading specialist, a bench of cultural reviewers, part-time privacy counsel, QA.
- Add 3-4 engineer-weeks for the authoring tool and 3-4 for remote catalog and downloads.
- **A further 6-9 months after the MVP**, governed almost entirely by how fast finished, reviewed books can be produced. Measure cost and turnaround per book on the first three before believing any catalog plan, as the competitor file already recommends.

I am not putting a currency figure on per-book cost. It depends on illustrator rates and on how far an AI-assisted pipeline survives cultural review, and neither is in the files. The formula is: (pages + tap-to-see visuals + cover + character sheets) × cost per finished image, plus editor days, plus reviewer fee, plus alt-text and QA time.

---

## 2. Weaknesses and risks in v5 and the brief

### 2.1 Product

- **v5 and the brief are out of step.** Point 16 (stories teach about civilizations and cultures) is not in v5 at all. v5's next steps still say "pick 3 pilot stories from the existing list" and name the Panchatantra pilot, while the prototype uses a Jataka tale. The brief's preamble says "all 15 points" and lists 16. v5 has parents seeing "time spent reading"; the brief says "pages read, not screen time". A v6 should reconcile these.
- **The governing rule cannot be enforced.** "The story moves forward only as the child reads" really means "only as the child turns the page". Nothing detects reading. A rule that pretends otherwise leads to bad design (see 2.8) and to a dishonest parent metric.
- **"Pages read" is easy to inflate** by flipping. Parents will notice when a child "read" 30 pages in two minutes.
- **Tap-to-see can cut both ways.** It may pull a child into the text, or it may turn the page into a hunt for tappable words with the reading skipped. v5 recognises this ("not just whether they tap"), which is right, but the design has no guard yet.
- **"Recurring characters" (v5 feature 4) conflicts with a catalog of unrelated one-off folktales.** In the three prototype stories no character recurs.
- **"Pseudo-video-game feel" (brief point 2) is undefined** and sits awkwardly beside "rewards only from reading" and "no mini-games". Designers will each read it differently.
- **Streaks** are a loss-aversion mechanic. They work for retention and are exactly the kind of pressure many parents are trying to get away from.
- **No support for the child who gets stuck** beyond single-word help. For an additional-language reader, or a child with dyslexia, that is a wall.

### 2.2 Content-production cost per illustrated story

- v5 names this risk but understates it. Section 1.8 puts three small books at 70-90 finished images. Tap-to-see multiplies the art per book beyond what a picture book needs, and every visual of a real place or object has to be factually right.
- An AI illustration pipeline lowers unit cost but has known weak points here: character consistency across twenty pages, and accuracy for culturally specific things (clothing, architecture, a *tamate-bako*, an Akan village). The competitor file's point stands: a pipeline "is a production tool rather than exclusive content ownership". Copyright protection for AI-generated images is also uncertain in some jurisdictions **[unverified: needs counsel]**.
- Alt text, captions, culture notes and reviewer sign-off are per-image costs that the plan does not yet count.

### 2.3 Tier calibration

The three prototype stories show the problem directly.

- **Length does not rise with tier.** Low is 952 words, Medium is 384, Advanced is 4,229. Under v5's own criteria (vocabulary, sentence length, story length, text share), the Medium book is shorter than the Low book by more than half, and the step from Medium to Advanced is an elevenfold jump.
- **The Medium book is four or five pages.** A two-page free sample would give away about half of it.
- **Sentence length does rise** (about 10, 14, 19 words), and the Medium text has clearly harder vocabulary ("inaccessible", "insufficient", "severest penalty"). So the stories were tiered by message, as the brief says, and difficulty came along only partly.
- **v5 fuses two different things into one label:** how hard the text is, and how mature the idea is. They are independent. The competitor file already warns that older children with weaker English "should not receive babyish plots" and strong decoders may still struggle with inference. A nine-year-old who reads at the Low level gets only "basic morals"; a strong six-year-old in Advanced gets Urashima's death on the beach.
- **Three levels are coarse.** There is no recognised scale behind them, ages are "still to be set", and nothing tells a parent what "Medium" means.
- **"Low" is a bad word to print on a child's book cover.** No child wants to be seen reading the Low shelf.
- **One story, one tier triples the catalog needed.** Each book serves a third of the audience. This is a legitimate editorial choice, but it should be made knowing it is the most expensive option.
- **Public-domain text cannot be calibrated.** A 1912 retelling is as hard as its author made it. Since v5 already says stories are "retold in English", the answer is to write to a target level (section 3.3).

### 2.4 Device-market risk

- The Duo has been shipping for about three weeks. Its sales, price and how families use it are unknown to me **[unverified]**.
- **The user is not the owner.** The reader is a child; the device is an adult's new, presumably premium, phone. How often and for how long a parent hands it over is the number that decides whether a Duo-only reading habit can form, and nobody has it yet.
- A subscription needs daily or near-daily use. A device the child borrows occasionally works against that.
- "Best shot at being featured early" is a hope, not a channel. The 13 Sep direction itself notes distribution is a later thesis.
- The competitor file gave this warning on 7 Nov: "Provide a good single-pane phone/tablet experience; don't make this research depend on any unverified device".
- Mitigation is cheap if done from the start (section 1.2): iPad in landscape is the same two-page spread.

### 2.5 Cultural accuracy of colonial-era public-domain retellings

`SOURCES.md` already flags this. Specifics from reading the three texts:

**The Monkey and the Crocodile (Babbitt, 1912)**
- Presented as a plain animal fable; the Jataka frame, in which these are stories of the Buddha's earlier lives, is absent from the text. For a product whose point 16 is teaching about civilizations, the frame is the cultural content.
- Wording to review for young readers: "I want the heart of a Monkey to eat", "I am going to kill you", the repeated "stupid Crocodile", and the dated "How queer!".

**How Wisdom Became the Property of the Human Race (Barker and Sinclair, 1917)**
- The text is set in "Fanti-land" and calls the hero "a man named Father Anansi". The file is named and labelled Akan/Ashanti. Fante and Asante are both Akan peoples, but the label on the cover should match the source, and in the wider tradition Anansi is the spider trickster, which this text never says **[unverified beyond the text itself: confirm with an Akan reviewer]**.
- The register ("severest penalty he could inflict", "unfortunate enough to offend") is an Edwardian English voice laid over an oral tale.
- Names and spellings ("Kweku Tsin") are a colonial-era transcription and should be checked against how the tradition names these characters today.

**Urashima Taro (Ozaki, 1908)**
- Contains a tobacco joke and a sake joke, a footnote reading "only used by lower classes", and the aside "Japanese ghosts have no feet".
- The hero marries, then ages and "fell down dead on the beach".
- It closes with a moral aimed at the reader: "Little children, never be disobedient to those who are wiser than you…". Whether that moral belongs to the legend or to the 1908 retelling is exactly the kind of question a cultural reviewer should answer. It also undercuts SOURCES.md's own reading of the story as being about time and loss.

**Wider points**
- Stories filtered through early-1900s British and American retellers carry those retellers' assumptions. Shipping them as "learn about the world's great cultures" invites justified criticism, and one bad review of this kind is costly for a kids' brand.
- Tap-to-see raises the stakes: every visual is a claim about what a place, garment or object looks like.
- "Major historical civilizations" framing can present living cultures as past ones. Japan, India and the Akan peoples are contemporary.
- "Which cultures count as significant" is a judgement that will be questioned. Have a stated editorial policy.

### 2.6 Rights

- US public-domain status is recorded for all three editions. Outside the US it is confirmed only for Ozaki (died 1932). Death years for Babbitt, Barker and Sinclair are "not verified" in `SOURCES.md`. Omramo is a global app (point 1), so the exact texts are not cleared for a global launch.
- Writing original retellings from several sources solves both this and section 2.5, since traditional plots are not owned, but have counsel confirm the approach **[unverified legal generalisation]**.
- The earlier rights research notes that StoryWeaver story content and its read-along audio/video carry different licences; keep the rights manifest per story as the competitor file proposed.
- I could not read the canonical rights document, so there may be points there I have missed.

### 2.7 Monetization

- **A tiny catalog behind a hard paywall, against large paid libraries and good free ones.** The competitor file lists Epic Family at US$13.99 a month or US$84.99 a year and StoryWeaver and Oxford Owl as free, and says plainly that "a tiny catalog behind a hard paywall faces strong free and paid substitutes".
- **A two-page sample cannot demonstrate the product.** The value claimed is that a child reads more; two pages show a parent nothing about that. For the Medium prototype it is half the book; for Urashima it ends before the tortoise is rescued.
- **Subscription fatigue and ongoing value.** A subscription asks "what is new this month?". With three books, or even thirty, the honest answer has to be a publishing schedule Omramo can keep.
- **Price is unset** and there is no stated view of what a parent compares it to.
- **School licences "later"** would need accounts, rosters and reporting, which collide with the collect-nothing privacy design. It is a different product; do not let it shape v1.
- "A tier is never locked behind payment" (v5 feature 7) reads oddly beside "subscribe to read the full library". I take it to mean one subscription covers all tiers; say that.

### 2.8 Retention, and "force kids to read" versus children's motivation

- **Novelty decay.** Tap-to-see will delight on day one. The question is whether it still matters in week three.
- **Finite content.** Stories are rarely re-read the way games are replayed. A keen reader finishes a tier's shelf quickly and has nowhere to go.
- **Buyer and user differ.** The parent pays for "real reading"; the child stays only if the stories are good. An app designed mainly around the parent's goal will be opened when the parent insists and not otherwise.
- **On forcing.** v5's language is about removing every alternative to reading. The widely held view in reading education is that lasting reading habits come from choice, a sense of competence and shared enjoyment, and that control and external rewards tend to undermine them **[unverified: I did not fetch the research this session]**. Whatever the citations say, the practical point holds: Omramo cannot force anything. A child who is made to use it will flip pages. Its only real lever is that the next page is worth reading.
- **Risks that follow from a "force" framing:**
  - No full-sentence or page audio at all excludes struggling readers, who are the children whose parents most want this.
  - Streaks and locked progression turn reading into a chore to be discharged.
  - A metric that parents use to police ("only 4 pages today?") makes the app the enemy.
- **The morals.** Brief point 9 organises the whole catalog around messages and morals. Children are quick to detect being lectured. Urashima's closing sermon is the clearest example of what to cut.

---

## 3. Concrete improvements

### 3.1 Design

**Must**
- **Rename the tiers.** Replace Low / Medium / Advanced on anything a child sees with neutral names (colours, or book-world names such as Lantern, Compass, Atlas). Keep the plain labels in the parent view.
- **Design the single-screen reader as a first-class layout**, not a fallback. It is the control condition for the fold test and the route to every other device.
- **Respect the gutter** (section 1.2) and make the spread feel like a book: stable page positions, a visible sense of how far through the book you are, a real cover and endpapers.
- **Quiet pages.** At most a small number of tappable entities per page, marked subtly (a soft underline), with no shimmer or bounce competing with the text.

**Should**
- A **world shelf**: the library can be browsed by culture as well as by tier, with the origin shown on the cover as point 16 suggests (a map pin and a one-line culture note).
- A **reading-comfort panel** for the child: text size, line spacing, a dyslexia-friendly typeface option, light/sepia/dark.
- Define "pseudo-video-game feel" narrowly as craft: responsive touch, satisfying page turns, a collection that visibly grows. No points, no currency, no timers.

**Could**
- Subtle ambient sound per scene, off by default.
- A printed-book-style colophon page per story with sources, retelling credit, illustrator and cultural reviewer named.

### 3.2 Interaction

**Must**
- **Define a "page read" honestly.** Count a page when it has been on screen for a plausible minimum time for its word count, and report in standard pages (section 1.3). Tell parents in plain words how it is counted. Do not claim it proves reading.
- **Guard tap-to-see against becoming the game.** A visual shows once per page-visit with a caption that must be read to make sense of it; closing returns to the exact line; visuals never link onward (already in v5). No counter of "3 things left to find on this page".
- **Never block system accessibility,** including spoken text.
- **Help for a stuck reader:** tap a word to hear and define it (already in v5), and add "read me this sentence" on request, with the sentence highlighted. It is requested, per sentence, never continuous. This keeps the reading-first rule and removes the wall.

**Should**
- **Replace streaks with "reading days"** shown as a calendar or a growing shelf, with no penalty for a missed day.
- **One end-of-book conversation prompt** for parent and child ("Why did Kweku Tsin speak up?"), not a quiz. The competitor file proposes the same restraint.
- **Characters and places collected by meeting them in the text**, shown in an atlas organised by culture. This joins v5 feature 5 to point 16.
- A **"read together" mode**: two readers at the open book, each with a page. A foldable is physically suited to this, and it serves the shared-enjoyment side of motivation.

**Could**
- The tapped word's visual animating out of the word itself (needs rendering option B).
- A child's own bookmark with a short note or sticker.

### 3.3 Content strategy, including civilizations and cultures (point 16)

**Must**
- **Commission original Omramo retellings** rather than shipping the 1908-1917 texts. Each is written from several sources, to a target level, in a modern voice. This fixes calibration, global rights and most of the colonial-wording problem at once.
- **A cultural reviewer for every story**, from that culture or a scholar of it, paid and credited, signing off text, illustrations, tap-to-see visuals and the culture note. Record the sign-off in the package.
- **Name cultures precisely and as living.** "An Akan story from Ghana, told by Asante and Fante families" rather than a continental label; "a Jataka tale from the Buddhist tradition of ancient India, still told across South and Southeast Asia". Use civilization and culture names throughout the app, never continents as origins.
- **Write an editorial policy** covering: how stories and cultures are chosen; how death, violence, alcohol, tobacco and marriage are handled per tier; and that appended sermons are removed. Urashima needs these decisions before any art is drawn.
- **Keep `SOURCES.md` discipline** and extend it into the per-story rights manifest.

**Should**
- **Build story cycles, not single tales.** Anansi and Kweku Tsin appear across many tales in the Barker collection's tradition; the Jataka and Panchatantra are cycles; Japanese tale collections share figures and settings. A cycle of four to six books per culture gives recurring characters (v5 feature 4), reusable character sheets and settings (lower art cost), and a reason to come back.
- **Plan the catalog as a grid of culture by tier,** so every tier has stories from every featured culture and no culture is represented only by "simple" or only by "deep" stories.
- **Widen beyond the brief's examples deliberately:** for instance Persian, Arab, Mesopotamian, Egyptian, Greek, Norse, Maya, Inca, Indigenous North American, Polynesian, Korean and Yoruba traditions. Some of these, particularly Indigenous traditions, have community protocols about who may tell which stories; do not treat "old" as "free to use".
- **Let tap-to-see carry the civilization teaching.** The culture is learned through cards for places, objects, foods, clothing and ideas met in the text, each with two lines to read, plus a short culture page at the end of the book. No lecture inside the story.
- **Reuse vocabulary across books** on purpose, as the competitor file suggests, and track it in the package metadata.

**Could**
- Commission living authors and illustrators from each culture for original stories alongside the retellings. This is the strongest answer to "why not just read the free version" and gives Omramo content it owns.
- An optional home-language gloss layer for additional-language readers, as the competitor file floats.

### 3.4 The tier system: calibration, placement, progression

**Must**
- **Separate the two axes.** Give every book (a) a measured **reading level** and (b) an editorial **theme band** (for example "gentle", "bigger ideas", "deep themes"). The child-facing tier can still be a single label and a book can still belong to exactly one tier, honouring point 9, but the catalog plan should include some easy-text books with mature themes and some harder-text books with gentle ones.
- **Calibrate with a recognised measure plus human judgement:**
  - a quantitative measure computed for every text. Lexile is the best known to parents and schools; MetaMetrics offers a Text Analyzer aimed at educators (https://hub.lexile.com/tools-overview/), and the terms for a commercial publisher displaying Lexile measures need checking **[unverified]**. A free formula such as Flesch-Kincaid is a workable internal cross-check;
  - a CEFR band for additional-language families (the A1 to C2 scale **[unverified: the Council of Europe page refused the fetch]**);
  - sign-off by a reading specialist, who also judges what formulas miss: idiom, inference load, background knowledge.
- **Write a tier specification** before writing more stories: per tier, a range for total words, words per page, sentence length, share of uncommon words, and text-to-picture ratio. Then write retellings to the spec. The competitor file gives one reference point: StoryWeaver's Level 3 guidance of 600-1,500 words.
- **Fix the prototype set against that spec.** Either lengthen and enrich the Anansi story or swap it; decide whether Urashima at more than 4,000 words is one book or a book in chapters.
- **Publish what each tier means** to parents in plain terms, and keep the competitor file's caution: do not equate age, grade, Lexile and CEFR.

**Should**
- **Sub-levels inside each tier** (say three), invisible to the child except as shelf order, so there are nine steps and the climb is gradual.
- **Placement without a test:** show the child three short passages, one per tier, and ask which felt "just right"; let the parent confirm. Offer to adjust after the first book if the child used word help very often or hardly at all.
- **Progression as invitation:** after a few finished books, the next tier's shelf lights up with one suggested title. Nothing is ever locked, and going back down is presented as normal (v5 already says this).
- **A parent-facing progress story** based on level reached and standard pages, not on streak length.

**Could**
- A proper placement check built with an educator once there is a catalog to place into.
- Per-book level badges recognisable to teachers, which is the groundwork for any later school offer.

### 3.5 Monetization

**Must**
- **Make at least one whole book free in each tier.** A parent needs to see their child finish a book before paying. Paywall the rest. This contradicts the two-page sample locked on 13 Sep; it is a recommendation for Srikanth to approve, as the competitor file also framed it.
- **Put the paywall behind the parental gate** and give the child an "ask a grown-up" page instead (section 1.6).
- **Do not launch a subscription until there is a publishing cadence to back it.** State the cadence on the paywall ("a new book every…") and keep it.
- **Turn on Family Sharing** and add local reader profiles.

**Should**
- Offer an annual plan alongside monthly, and price with the comparison set from the competitor file in mind: a parent will weigh a small curated shelf against a very large library at the Epic price, and against free.
- Consider selling the launch catalog as a **one-off purchase or story packs** while it is small, moving to subscription when the library and cadence justify it. v5 already lists packs as a later option; I would reverse the order.
- A free trial behind the gate so the first paid month follows real use.

**Could**
- Gift subscriptions from grandparents; a "founding family" price.
- School licences only after consumer retention is proven, as a separate project with its own privacy design.

### 3.6 Technical approach

**Must**
- Layout modes from container size; Duo, iPhone and iPad from day one.
- Beats, stable IDs and stand-off entity annotations in the package format.
- Everything on the device; zero third-party SDKs; a dependency audit in the release checklist.
- Accessibility in the definition of done: VoiceOver through a whole book, largest Dynamic Type, Reduce Motion, contrast.
- Verify the Duo-specific pieces on hardware and against the HIG before detailed design.

**Should**
- The internal authoring and preview tool.
- Apple-hosted downloadable packages for v1; package integrity checks; schema and content versioning.
- Optional progress sync between a family's own devices through the user's iCloud, parent-enabled **[unverified: confirm the privacy-label and Kids Category implications]**.
- Automated checks in the content pipeline: readability measures, missing alt text, entities per page, word count against tier spec.
- A parent-initiated "export reading log" for pilot families, which is how test data leaves the device with consent.

**Could**
- Rendering option B for word-anchored animation.
- Layered parallax illustrations driven by device motion.

---

## 4. Differentiation, and what Omramo must prove

### 4.1 Where Omramo stands

Drawn from the 7 Nov competitor file; "D" there means described by the publisher, not tested hands-on.

| | What they are | Where Omramo differs | Where they are stronger |
|---|---|---|---|
| **Epic** | Very broad children's library with read-to-me, audiobooks, quizzes, dictionary lookup, rewards, parent dashboard, offline | Small curated shelf; reading-only; visuals that open from words; world-cultures spine | Breadth, licensed characters, discovery, price per book |
| **Raz-Kids** | K-5 levelled readers with listen/read/record/quiz and teacher reporting | Reads as a storybook for pleasure, not an assignment; no quizzes | Fine-grained, school-trusted levelling; teacher workflow |
| **Reading Eggspress** | Ages 7-13, placement, Lexile discovery, chapter quizzes | No game lobby, no homework feel | Placement and comprehension scaffolding |
| **BOOKR Class** | Narrated, animated, highlighted stories with games, ages 4-14 | The child reads; nothing is narrated by default | Multimedia polish; additional-language pedagogy |
| **StoryWeaver, Oxford Owl** | Free, levelled, illustrated, culturally wide (StoryWeaver) | Interaction design and device fit | Free; large; StoryWeaver is strong on cultural range |
| **Google Read Along** | Free early-fluency helper | Different audience (already-readers) | Free; speech help |

**Honest reading of this table:** illustration, levels, word help, progress and offline are table stakes, as the competitor file says. Folktales from many cultures are free on StoryWeaver. Omramo's possible edge is narrow and consists of three things:

1. **Tap-to-see from the text** as a curiosity mechanic that increases reading.
2. **The two-page spread** making that mechanic work without losing the place.
3. **A coherent editorial identity:** the world's cultures, read not watched, with no games.

The third is a matter of taste and execution. The first two are empirical claims and can be tested now. Note also that word-tap features exist in competitors (dictionary lookup, word audio); what would be new is a *visual* answer tied to the story. Whether any competitor already does this was not established by the 7 Nov research, which was not hands-on. Check before claiming it.

### 4.2 What must be proved

- **H1, tap-to-see:** children read more pages, and finish more books, with tap-to-see than with the same illustrated book without it.
- **H2, the fold:** tap-to-see on a two-page spread beats tap-to-see on a single screen for pages read and for getting back to the text.
- **H3, habit:** given a free choice on a later day, children come back and open a book.
- **H4, level fit:** children placed in a tier can read it with occasional help and can say what happened.
- **H5, parents:** a parent who watched the sessions would pay, and can say what for.

### 4.3 Prototype tests

**Build:** the proof prototype from section 1.8 with three switches: tap-to-see on/off; spread/single layout; and book. Use the best available art; weak art will confound everything.

**Participants:** the competitor file suggests 8-12 children over several sessions. That is enough to see usability problems and large effects, and not enough to prove efficacy or demand; do not present it as more. Recruit across the three tiers and include both first-language and additional-language English readers, analysed separately. Written parental consent; data stays on the test device.

| Test | Design | What it isolates |
|---|---|---|
| T1 | Same child reads one book with tap-to-see and a matched book without, order alternated between children | H1 |
| T2 | Same child reads with tap-to-see on the open Duo and on a single screen (folded Duo or an ordinary iPhone), order alternated | H2 |
| T3 | Leave the device with the family for one to two weeks with no instruction to read; all three books available | H3 |
| T4 | After each book: an unprompted retelling and one inference question, scored by an educator | H4, and that taps are not replacing comprehension |
| T5 | Parent interview after T3, then a price question with a real paywall mock | H5 |
| T6 (optional) | One session with a comparable book in an existing app the family already uses | Whether Omramo is better at anything a parent notices |

### 4.4 Success metrics, measured in pages read

Use **standard pages** (section 1.3) so tiers and text sizes are comparable.

**Primary**
- **Standard pages read per session**, per condition.
- **Book completion rate:** share of started books finished.
- **Unprompted return:** number of days in the take-home period on which the child opened a book without being asked, and standard pages read on those days.
- **Standard pages per week** in the second week compared with the first (novelty decay).

**Tap-to-see health**
- **Return-to-text rate:** share of tap-to-see openings followed by continued reading of the same page rather than leaving or flipping.
- **Taps per standard page**, watched for the failure pattern of high taps with low dwell on text.
- **Caption dwell:** whether the two-line caption is on screen long enough to be read.

**Guardrails**
- Retelling and inference results do not fall when tap-to-see is on.
- Share of pages turned faster than a plausible reading time (the flipping rate).
- Adult rescues per book.

**Decision rules (proposals; fix them with an educator before testing, as the competitor file advises)**
- **Tap-to-see is proved** if most children read more standard pages and finish more often with it, return-to-text is high, and comprehension holds.
- **The fold is proved** if the spread beats the single screen on pages read or return-to-text by a margin visible child by child, not just on average.
- **If tap-to-see works and the fold adds little,** Omramo is a good reading app that should launch on every iPhone and iPad, with the Duo as its showcase.
- **If neither moves pages read,** the remaining proposition is editorial quality alone, and the business case needs rethinking before more is spent on art.

---

## 5. Top 10 recommendations

1. **Run the tap-to-see and fold tests before building the product**, with standard pages read as the measure.
2. **Support iPad and ordinary iPhones from the first release**; make the Duo the best version, not the only one.
3. **Write original, levelled Omramo retellings** with a paid cultural reviewer per story; do not ship the 1908-1917 texts.
4. **Rebuild the tier system:** separate reading level from theme maturity, calibrate against a recognised measure with a reading specialist, add sub-levels, and rename "Low".
5. **Fix the prototype set:** the Medium story is far too short for its tier and the Advanced one needs chapters and editorial decisions about its ending and moral.
6. **Replace "force" with invitation:** on-request sentence audio, no blocked accessibility, reading days instead of streaks, one conversation prompt instead of quizzes.
7. **Collect no data at all,** keep everything on the device, and put the paywall behind a parental gate with an "ask a grown-up" page for the child.
8. **Give away one whole book per tier** and hold the subscription until a publishing cadence exists; consider packs first.
9. **Build story cycles per culture** (Anansi, Jataka, and so on) so characters recur and art is reused, and plan the catalog as a culture-by-tier grid.
10. **Measure cost and turnaround per finished book on the first three,** build the authoring tool, and only then commit to a catalog size and a date.

## Open questions for Srikanth

1. **Devices:** will you accept iPad and standard iPhone support at launch, or is Duo-only a fixed constraint? If fixed, why?
2. **Ages:** what age range does each tier target, and which Kids Category band (6-8 or 9-11) should the app sit in? Or should it stay out of the Kids Category?
3. **Tiers:** is "one story, one tier, tier set by message" fixed even where a story's reading difficulty and its theme point to different tiers? May the child-facing names change from Low / Medium / Advanced?
4. **Audio:** is on-request sentence read-aloud acceptable, or does "no read-aloud" hold absolutely?
5. **Text:** do you agree to original retellings instead of the public-domain texts as written? Who writes them, and is there budget for a children's editor and cultural reviewers?
6. **Art:** human illustrators, an AI-assisted pipeline, or a mix? What is the budget per finished image, and who is the art director?
7. **Urashima:** keep the death ending for Advanced readers? Remove the closing sermon, the tobacco and sake jokes and the class footnote?
8. **Free sample:** will you move from the locked two-page sample to one free book per tier?
9. **Subscription:** what publishing cadence can you commit to, and is a one-off purchase or packs acceptable while the catalog is small? What does "family subscription" mean: Family Sharing on one plan, or a separate family tier?
10. **Catalog:** how many books per tier counts as "enough" for v1, and which cultures are in the first year? Who decides which cultures are included?
11. **Recurring characters:** story cycles from the traditions, or original Omramo guide characters, or neither?
12. **Testing:** can you recruit 8-12 families with a Duo (or lend devices), and who is the educator who will set the pass thresholds?
13. **Measurement:** are you content with no remote analytics at all, relying on moderated tests and Apple's aggregate figures?
14. **Hardware and gates:** is a Duo available to the team now, has the scaffold PR been run on it, and is the Apple developer organisation gate cleared?
15. **Rights:** has the full rights research been reviewed by a lawyer for territories outside the US, and has the Omramo name been cleared as a trademark?
16. **Schools:** is the school licence a real goal within two years? If so it changes the privacy and account design and should be scoped now, not bolted on.

---

## Sources fetched this session

| URL | Result | Used for |
|---|---|---|
| https://developer.apple.com/app-store/review/guidelines/ | Loaded; 1.3 and 2.3.8 quoted verbatim, 3.1.2 and 5.1.4 from a summary of the page | Kids Category, subscriptions |
| https://developer.apple.com/app-store/kids-apps/ | Loaded | Age bands, parental gates, data practices |
| https://developer.apple.com/iphone-duo/ | Loaded | Existence of the hub, session and article titles |
| https://developer.apple.com/design/human-interface-guidelines/designing-for-iphone-duo | Title only | Nothing; fold guidance unverified |
| https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/On_Demand_Resources_Guide/ | Loaded | ODR definition, archive status, 2017 date |
| https://www.ftc.gov/legal-library/browse/rules/childrens-online-privacy-protection-rule-coppa | Loaded | COPPA scope; existence of 2025 rule text |
| https://hub.lexile.com/tools-overview/ | Loaded (redirect from lexile.com) | Existence and audience of the Lexile Text Analyzer |
| https://developer.apple.com/documentation/storekit/supporting-family-sharing-in-your-app | Title only | Nothing; Family Sharing details unverified |
| https://developer.apple.com/documentation/backgroundassets | Title only | Nothing; Background Assets details unverified |
| https://developer.apple.com/documentation/swiftui/text and https://developer.apple.com/documentation/foundation/attributedstring | Title only | Nothing; link-run behaviour unverified |
| https://www.coe.int/en/web/common-european-framework-reference-languages/level-descriptions | 403 | Nothing; CEFR scale unverified |

Competitor facts and prices are taken from `../2026-11-07-illustrated-english-reader-competitors.md` and were not re-fetched; that file notes its own limits (public pages only, no hands-on audit, prices as listed on 7 Nov 2026).
