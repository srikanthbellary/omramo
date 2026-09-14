# Omramo design (v1 scaffold)

The whole app is one idea: a Telugu book that opens across two panes. Every
screen either leads to that moment or lives inside it.

## Mark: OM | RA | MO

Three tiles. `OM` is the left pane, `RA` is the spine, `MO` is the right pane.

- **Closed**: the tiles sit flush and read Omramo. Indigo, spine brown, saffron.
- **Open**: `OM` and `MO` rotate outward like the covers of a book (28 degrees
  on the y axis, anchored at the spine), `RA` narrows to a spine and its
  letters turn vertical.

`FoldMarkView(isOpen:scale:)` draws both states and animates between them with
a single spring. The tile letters are `Brand.mark`, derived from
`Brand.displayName` by splitting the name into three near equal upper case
tiles with the spine narrowest. The splash plays closed to open once (about
1.5 seconds), then fades to the catalog. The paywall header shows the open
mark at half scale. Do not invent a second mark or wordmark.

### Brand is one constant

Nothing in the UI spells the product name. All copy reads `Brand.displayName`
(and `Brand.allAccessName`, `Brand.tagline`, `Brand.domain`) from
`OmramoCore/Brand/Brand.swift`; the home screen label reads
`BRAND_DISPLAY_NAME` from `Configuration/Brand.xcconfig`. Change those two
values to rebrand; a core test fails if they disagree. See the README section
"Renaming the product".

## Palette

| Role | Value | Use |
| --- | --- | --- |
| Paper | `#F7F1E3` | Page and catalog surface |
| Paper shade | `#EDE6D4` | Page gradient foot, plan cards |
| Ink | `#1C1C21` | Body text |
| Ink soft | `#5C5754` | Captions, secondary copy |
| Saffron | `#E07A1F` | The one action colour: buttons, selected plan, all access badge |
| Indigo | `#2B3A67` | Left mark tile, ready edition chips |
| Spine | `#3E2723` | Spine tile, fold gap |
| Shelf | `#211A17` | Backdrop behind open books |

Content colours come from each `Artwork` descriptor and never from code, so
posters and illustrations carry their own story.

## Type

System fonts only. Telugu, Devanagari and Latin fall back to their platform
faces and Dynamic Type works everywhere.

- Display title: serif, semibold, `.title`. Telugu titles over posters.
- Card title: serif, semibold, `.headline`. English title under the poster.
- Page body: serif, `.title3`, line spacing 8. Telugu needs more leading than
  Latin at the same size; the same style is used for English so synced panes
  align.
- Page caption: serif italic, `.footnote`.
- Page number: serif, `.caption`.

## Screens

### Splash

Paper background. Mark closed, then open. Wordmark and the line
"తెలుగు కథలు, తెరిచిన పుస్తకంలా" fade in with the opening. Nothing tappable.

### Catalog (free)

- Adaptive grid, cards 170 to 240pt wide. One pane on the outer display; two
  panes on the inner display with titles alternating left and right and the
  fold left empty.
- Card: 2:3 poster with the Telugu title set into the lower left, English title,
  author, three lines of Telugu description, edition chips (`TE EN HI`; solid
  when bundled, outlined when planned), page count.
- Top trailing badge shows "Browsing free" or "All access".
- States: spinner "Opening the library"; empty "No titles yet"; failure with the
  reader facing message and a Try again button when retryable.
- Tapping a card always goes to the sample, never the full book.

### Sample spread (the wow)

- Shelf gradient backdrop. The book sits on it with a deep shadow.
- **Regular width (inner display, iPad, wide Split View)**: two pages around a
  28pt spine. Left is page 1 in Telugu. Right is page 2 in Telugu, or page 1
  in English when the segmented control is set to `తెలుగు | English`.
- **Compact width (outer display, phones)**: one page with the paging tab view
  and page dots; swipe between the two sample pages. The same segmented
  control is present; `తెలుగు | English` stacks the English page under the
  Telugu one.
- Footer: "You have read the free sample of <title>", one line about the
  subscription, and a saffron button reading "Subscribe to continue reading",
  "Continue reading" once subscribed, or a spinner while the store is still
  answering. With two panes the message sits under the left page and the
  control plus button under the right.
- Pages are `PageView`: paper gradient, optional 120pt illustration band, text,
  italic caption, and a foot row with the edition name and page number.

### Paywall (hard)

- Full screen cover, swipe to dismiss disabled, "Not now" in the top leading
  slot returns to where the reader was.
- Header: open mark, "Read every book in Omramo", one supporting line.
- Four benefits with saffron symbols.
- Plan cards: Yearly (default) and Monthly. Name, price and period come from the
  store. Selected card has a saffron border and filled radio.
- Primary button "Subscribe and keep reading" (spinner while purchasing),
  secondary "Restore purchases", inline error copy in red.
- Legal footnote about auto renewal in `.caption2`.
- Debug only "Developer" disclosure to simulate a subscription.
- Two panes on regular width: the pitch (mark, headline, benefits) on the left,
  the decision (plans, actions, legal) on the right, each column capped at
  480pt inside its pane. One scrolling column on compact width.

### Reader

- Same shelf and book treatment as the sample.
- Toolbar menu "Spread" switches `Pages`, `తెలుగు | English`, `Art`.
  Modes appear only when the editions exist for that title.
- Under the book: previous chevron, "Pages 3 and 4 of 10", next chevron.
  44pt targets. With two panes, back and the position sit under the left page
  and next under the right so nothing crosses the fold. Horizontal swipe on
  the book also turns pages.
- Position and mode are saved per title and restored on reopen; folding or
  unfolding mid read keeps the same page.
- Facing pages keep even indices on the left so a page stays on its side while
  turning; an odd last page shows a blank right leaf with a closed book glyph.
- Every pane passes through the entitlement gate. A locked pane is
  `LockedPageView`: lock glyph, "Page n is part of the full book", one line,
  saffron "Subscribe to keep reading".

## Foldable reader P0 locks

Source: RNDB foldable reader brief, research library topic "Foldable reader
apps Android -> Duo". The bar is set by Google Play Books and the Surface Duo
reader samples, which are fold native (two panes by default, position kept
across postures, fold as separator). Kindle on foldables is compatible but not
fold native: it stretches a phone column across the inner display and only
shows two pages after a rotate to landscape. Omramo takes the stronger bar.

| # | Lock | Where it is enforced |
| --- | --- | --- |
| 1 | Default inner layout is two related panes, for the sample and the reader. Never a single stretched phone column. | `SpreadLayoutPolicy`: regular width always yields `.dual`. Catalog, sample, paywall and reader all lay out through `OpenBookSpread`. |
| 2 | Reading position and pane mode persist across size changes (outer to inner, compact to regular). | `ReadingPosition` is a value independent of arrangement; `SpreadPager` re-derives the spread. `ReaderModel` saves it per title through `ReadingProgressStore`. Sample mode is view state that survives the change. |
| 3 | Never letterbox or stretch a phone layout to fill a wide canvas. | Wide compact canvases (>= 700pt, landscape phones) also get two panes. The paywall form is two panes on regular width, not a centred column. |
| 4 | Compact and outer is a real compact reader, not an afterthought. | Single pane keeps every mode: synced stacks the second edition under the first (`CompanionPage`), illustrated keeps the art band inline, the mode picker is present, paging dots in the sample and 44pt chevrons in the reader. |
| 5 | The hinge and fold region is a separator. No critical text or chrome through the middle. | `BookSpine` gap of 28pt holds nothing. Reader controls split under their pages (back and position left, next right). Sample footer splits message left, controls right. Paywall and catalog leave the gap empty. The only element on the fold by design is the spine tile of the mark on the splash. |
| 6 | Never require a landscape rotate to get two pages. | `.dual` depends on regular width only, not on orientation or aspect ratio. Portrait on the inner display is a spread. |

## Duo behaviour, in one table

| Situation | Size class | What the reader sees |
| --- | --- | --- |
| Closed, outer display | compact width | One page, paging dots in the sample, chevrons in the reader, synced mode stacked |
| Open, inner display, portrait | regular width | Two pages around the spine; controls split under each page |
| Open, inner display, landscape | regular width | Two pages; system moves bars to the outer edge, book content stays put |
| Phone in landscape | compact width, >= 700pt | Two pages (wide compact rule) |
| Split View, narrow | compact width | One page |
| Split View, regular | regular width | Two pages |

Rules followed from Apple's Duo guidance:

- Two layout foundations (compact, regular), no pose breakpoints and no hinge
  angle reads.
- Interactive controls sit below or beside the book, never on the spine gap.
- Scrolling page text may pass under the fold region; buttons do not.
- Everything is freely resizable: no fixed screen metrics, no `UIScreen.main`.

## Copy rules

- English copy is written for readers, not pasted from a model. Short
  sentences, no em dashes, no exclamation marks.
- Telugu leads wherever both appear (poster titles, splash line, page feet).
- The app never says "buy this book". It says subscribe, all access, every
  title.
