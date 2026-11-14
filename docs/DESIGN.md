# Omramo — Design system and screen specs (v2, locked)

**Status:** locked by Srikanth, 13 Nov 2026. This document codifies the approved designs-v2 so the Swift code can reproduce them.
**Authority order when two sources disagree:** (1) the design source code `designs-v2/src/lib/base.js`, `src/screens.js`, `src/screens-ui.js`; (2) the 12 screenshots in `docs/design/`; (3) `designs-v2/design-notes.md`. Every value below marked **(source)** is copied from the source code. Values marked **(estimate)** are mine.

**Checked against the source:** the tier reading sizes in the brief and in the design notes (Low 23.5 / 37, Medium 19.5 / 32, Advanced 16.5 / 27 pt) match `base.js` exactly. No conflict.

**Units:** points. The designs were rendered at @3x.

---

## 1. Principles

1. **The page is a place.** Every reading spread is one continuous scene under both panes and the hinge. Text sits in the calm part of the scene (sky, twilight, sea haze).
2. **Never a hardcover book.** No paper texture, no cream page, no spine or gutter shadow, no serif type, no page-curl.
3. **Each story has its own light; the chrome is constant.** Jataka: bright river morning. Anansi: twilight forest, light text. Urashima: pale sea haze. Glass buttons, chips and the round page-turn button are the same everywhere and only switch between a light and a dark variant.
4. **Reading is the largest thing on a reading screen.** No play, audio or autoplay control anywhere.
5. **One picture answer at a time.** A tap-to-see card has one line, one culture note, one button, and no onward link.
6. **Text becomes art in at most one place per page** (for example the call on the wave line in screen 05).
7. **Advanced should not feel babyish.** The app is marketed as ages 6 to 14 and up and is not listed in the Kids Category (PRD Q2). Advanced typography, scenes and chrome should feel grown-up enough for a 13- or 14-year-old still building reading skills; do not invent a more "kiddie" look for the older tier.

## 2. Canvas (assumption, not an Apple specification)

| Item | Value | Source |
|---|---|---|
| Pane | 432 × 720 pt (1296 × 2160 px @3x) | `PANE_W`, `PANE_H` |
| Hinge gap | 28 pt, captured black | `HINGE` |
| Unfolded canvas | 892 × 720 pt (2676 × 2160 px) | `DUO_W` |
| Folded canvas | one pane, 432 × 720 pt, Dynamic Island 116 × 33 pt at top 11 pt | `.island` |
| Status bar | 44 pt high; time on the left pane, signal/Wi-Fi/battery on the right pane | `.sb` |
| Home indicator | 134 × 5 pt, 8 pt from the bottom, one per pane | `.homebar` |

The app must not hardcode these. It reads pane rectangles from `PaneLayout` (`docs/ARCHITECTURE.md` §5) and uses 432 × 720 only as the **reference pane** against which the positions below are expressed. Status bar, island and home indicator are drawn by the system, never by the app.

## 3. Tokens

### 3.1 Brand colours (source: `:root` in `base.js`)

| Token | Hex | Use |
|---|---|---|
| `night` | `#130F36` | Midnight indigo; brand dark |
| `night2` | `#1F1856` | Secondary dark |
| `cloud` | `#F3F1FF` | Brand light |
| `ink` | `#16123D` | Default text and chrome on light |
| `coral` | `#FF6A4D` | Primary accent |
| `sun` | `#FFC43D` | Secondary accent, tap highlight |
| `mint` | `#19C7A2` | Map pin (India), "read" state |
| `sky` | `#3FB4FF` | Avatar ring (Urashima) |
| `violet` | `#7257FF` | Aurora blob |
| `rose` | `#FF5C8A` | Accent |

Additional UI colours used in the screens (source):

| Token | Hex | Use |
|---|---|---|
| `surfaceLight` | `#F4F2FF` | Light UI background base; subscription right pane |
| `surfaceDark` | `#110C33` | Dark aurora base (splash, subscription left) |
| `sheet` | `#F4F2FB` | Gate sheet |
| `keypadTray` | `#D8D5E6` | Gate keypad background |
| `wordmarkAccent` | `#FF5B3D` | "RA" in the small wordmark |
| `placeMarker` | `#FF7A3D` | The orange "keeper" line marker, toast icon, today ring |
| `mapPinGhana` | `#FFB020` | |
| `mapPinJapan` | `#FF6A8A` | |
| `violetStrong` | `#5A3FE0` | Links, selected tab, "Reading now", Subscribe gradient end |
| `violetLight` | `#8E7BFF` | Subscribe gradient start, gate lock disc |
| `chartBar` | `#B9ADFF` | Parent-view bars (today: `#5A3FE0`) |

Text opacities on light UI (source): primary `ink` 100%; secondary `rgba(22,18,61,.62)`; label `rgba(22,18,61,.5)`; hairline `rgba(22,18,61,.12)`.

### 3.2 Tier colours

| Tier | Base (source `--low/--med/--adv`) | Pill text | Pill background | Chip text on glass (reading) | Glyph |
|---|---|---|---|---|---|
| Low | `#12B58F` | `#0B8A6C` | `#D6F7EC` | `#0B7A62` | 1 of 3 bars |
| Medium | `#FF9F1A` | `#B36200` | `#FFEFC9` | `#FFC43D` (on dark glass) | 2 of 3 bars |
| Advanced | `#6E56FF` | `#5A3FE0` | `#E6E0FF` | `#5A3FE0` | 3 of 3 bars |

Note: the Low text colour differs slightly between the library pill (`#0B8A6C`) and the reading chip (`#0B7A62`). Both are in the source; keep both.

### 3.3 Gradients

| Token | Definition (source) |
|---|---|
| `pageTurn.coral` | radial at 32% 26%: `#FF9A66` → `#FF5B3D` 62% → `#E8432B` |
| `pageTurn.amber` (Medium) | `#FFD76B` → `#FFB020` → `#F08A12`; arrow colour `#3A1B08` |
| `pageTurn.red` (Advanced) | `#FF8A70` → `#F4503F` → `#D8342B` |
| `button.primary` | linear top→bottom `#FF8A66` → `#FF5B3D` |
| `button.sun` ("Back to my line" on dark) | `#FFD25A` → `#FFB020`, text `#3A1B08` |
| `button.violet` (Subscribe) | `#8E7BFF` → `#5A3FE0` |
| `wordmark.ra` (splash) | linear top→bottom `#FFD25A` 10% → `#FF7A4D` 60% → `#FF4D7A` |
| `streakDay` | `#FFB84D` → `#FF7A3D` |
| `mapCard` | linear 160° `#2A1F7A` → `#17114A` 70% |
| `planHeader` | linear 160° `#3A2BB0` → `#1B1466` 70% |
| `characterCard.monkey` | linear top→bottom `#FFD35A` 0% → `#FFAE45` 46% → `#FF8A4D` 70% |
| `seam` (splash hinge edge) | vertical transparent → `#FFC46B` 30% → `#FF7A4D` 70% → transparent, 2 pt wide |

**Aurora backdrop** (library, parent view, splash, subscription): a base fill with five heavily blurred circles (Gaussian blur 70 pt) and a grain overlay.

| Variant | Base | Blobs: centre (x, y on the 892 × 720 canvas), radius, colour, opacity |
|---|---|---|
| Light | `#F4F2FF` | (80, 60) r300 `#C9BEFF` .70 · (820, 120) r300 `#BFEFE6` .75 · (760, 700) r320 `#FFD9C2` .70 · (120, 700) r280 `#FFE9A8` .55 · (446, 380) r260 `#E3DCFF` .60 |
| Dark | `#110C33` | (140, 120) r300 `#5B3BFF` .50 · (760, 600) r320 `#FF5C7A` .32 · (820, 80) r240 `#19C7A2` .28 · (80, 680) r260 `#FF9F1A` .22 · (446, 360) r240 `#7257FF` .30 |

Grain: fractal noise, soft-light blend, opacity .35 (light) / .55 (dark). In SwiftUI: a small tiled noise image with `.blendMode(.softLight)` (estimate of the technique; the look must match the screenshots).

### 3.4 Radii (source)

| Element | Radius |
|---|---|
| Round glass button (40 pt) | 20 |
| Capsule glass control (40 pt high) | 20 |
| Chip (28 pt high) | 14 |
| Page-turn button (60 pt) | 30 |
| Primary button (52 pt high) | 26 |
| Card | 26 |
| "Keep reading" cover | 28 |
| Story cover | 20; shelf cover 12; subscription cover 16 |
| Settings list card | 20 |
| Tab bar (62 pt high) | 31; tab item 26 |
| Segmented filter (38 pt high) | 19; segment 16 |
| End-of-sample card | 30 |
| Gate sheet top corners | 36 |
| Character-card sheet top corners | 34 |
| Culture note | 22 |
| Tap-word highlight | 0.34 em |
| Gate digit box (54 × 62) | 16; keypad key 12 |

### 3.5 Spacing (source positions on the 432 × 720 reference pane)

| Token | Value | Where |
|---|---|---|
| `inset.text` | 30 | Left edge of story text, labels, cards |
| `inset.control` | 20 | Top glass buttons from the pane edge |
| `inset.foot` | 28 | Footer chips from the pane edge |
| `top.control` | 50 | Top of the back button and the Aa capsule (56 folded) |
| `top.crumb` | 53, left 70 | Story title and part beside the back button |
| `top.text` | 106 (Low), 108 (Medium, Advanced) | First line of story text |
| `column.text` | 374 (372 on Medium and on the Advanced right pane) | Story text width |
| `foot.bottom` | 26, height 34 | Footer chip row |
| `pageTurn` | right 24, bottom 24 (54 pt button at 22/22 folded) | |
| `card.width` | 372 | Cards span 30 → 402 |
| `chip.gap` | 10 | Between footer chips |
| `card.gap` | 14 (estimate from positions: 298 → 312, 416 → 430) | Between stacked cards |

General spacing scale for new layouts (estimate, chosen to fit the values above): 4, 8, 12, 16, 20, 24, 30.

**Gutter rule:** nothing interactive and no text within the hinge. In the designs the nearest text is 28–30 pt from the hinge-side pane edge.

### 3.6 Glass and shadows (source)

**Glass (light):** fill `rgba(255,255,255,.62)`, backdrop blur 18 pt with saturation 180%, inner 0.5 pt edge `rgba(255,255,255,.9)`, inner top highlight 1 pt `rgba(255,255,255,.85)`, shadow `0 6 18 rgba(20,40,80,.14)` plus `0 1 2 rgba(0,0,0,.08)`.

**Glass (dark):** fill `rgba(40,28,84,.46)`, edge `rgba(255,255,255,.16)`, highlight `rgba(255,255,255,.2)`, shadow `0 6 18 rgba(0,0,0,.35)`; content colour white.

Per-screen glass fills (source): footer chips on Low `rgba(255,255,255,.84)`; on Medium `rgba(30,18,70,.55)`; on Advanced `rgba(255,255,255,.8)`; folded `rgba(255,255,255,.9)`; tab bar `rgba(255,255,255,.72)`; end-of-sample card `rgba(255,255,255,.8)`; close button on the Rin Gin card `rgba(10,40,90,.5)`; on the Monkey card `rgba(255,255,255,.55)`.

SwiftUI mapping (estimate): a tinted fill over `.ultraThinMaterial`, an inner stroke and the two shadows. Match by eye against the screenshots.

| Shadow token | Value |
|---|---|
| `card` | `0 14 34 rgba(60,40,140,.10)` + `0 2 6 rgba(60,40,140,.06)` + inner 0.5 pt white .9 edge; fill `rgba(255,255,255,.78)` (.86 in the parent view) |
| `cover` | `0 12 26 rgba(40,24,110,.22)` + `0 2 5 rgba(40,24,110,.16)` + inner top highlight |
| `pageTurn` | inner top 1.5 pt white .55, inner bottom `0 -3 6 rgba(120,20,0,.25)`, drop `0 10 22 rgba(232,67,43,.42)` + `0 2 4 rgba(0,0,0,.18)`; outer ring 2 pt `rgba(255,255,255,.55)` at 6 pt outside the button |
| `buttonPrimary` | inner top 1.5 pt white .5, inner bottom `0 -3 6 rgba(120,20,0,.2)`, drop `0 10 22 rgba(232,67,43,.34)` + `0 2 4 rgba(0,0,0,.14)` |
| `tapOn` | ring 3 pt `rgba(255,196,61,.35)` + `0 6 16 rgba(255,150,30,.35)` |
| `sheet` | `0 -12 40 rgba(0,0,0,.3)` |

### 3.7 Motion (estimates — the locked designs are static screenshots and specify no animation; design gap G11)

Proposed defaults, to be tuned on device:

| Token | Proposal |
|---|---|
| `motion.quick` | 0.18 s ease-out — button press, chip state |
| `motion.standard` | 0.30 s spring (response 0.35, damping 0.85) — card open/close, paragraph dim |
| `motion.page` | 0.35 s cross-fade of text with a short horizontal drift of the scene (no page-curl, no paper flip) |
| `motion.toast` | appears 0.2 s, stays 1.6 s, fades 0.3 s |
| Press feedback | scale to 0.96 plus a light haptic on the page-turn button |
| Reduce Motion | all of the above become opacity-only cross-fades; no drift, no scale |

Nothing moves unless the child acts. No idle shimmer on tap words.

## 4. Typography

### 4.1 Families

| Role | Family | File | Axes | Licence |
|---|---|---|---|---|
| Display: titles, lead sentences, sound words, UI labels, chips, buttons | **Bricolage Grotesque** | `BricolageGrotesque.ttf` | `wght` 200–800, `wdth` 75–100, `opsz` | SIL OFL 1.1 |
| Reading: all story text, card body text, captions | **Atkinson Hyperlegible Next** | `AtkinsonHyperlegibleNext.ttf`, `-Italic.ttf` | `wght` 200–800 | SIL OFL 1.1 |
| System chrome: settings rows, keypad, chart axis | **Inter** in the designs; **San Francisco (system font)** in the shipped app | `Inter.ttf` | `wght` 100–900 | SIL OFL 1.1 |

The design notes state that Inter stands in for San Francisco and the Swift app should use the system font there (PRD Q15). The status bar is drawn by iOS.

All weights below are variable-font `wght` values and must be set through font variation axes, not by picking the nearest named weight. `opsz` and `wdth` are Bricolage axis values.

### 4.2 Reading scale (source: `.t-low`, `.t-med`, `.t-adv`)

| | Low | Medium | Advanced |
|---|---|---|---|
| Body family | Atkinson Hyperlegible Next | same | same |
| Size / line height | 23.5 / 37 | 19.5 / 32 | 16.5 / 27 |
| Weight | 460 | 430 | 420 |
| Tracking | +0.1 | +0.1 | +0.05 |
| Word spacing | +0.4 | +0.6 | +0.3 |
| Paragraph gap | 17 | 16 | 12 |
| Column | 374 | 372 | 374 / 372 |
| Lead sentence (Bricolage) | 32 / 38, wght 720, tracking −0.6, opsz 48, wdth 92, balanced wrap | 27 / 33, wght 700, tracking −0.5, opsz 36, wdth 90 | 21 / 27, wght 680, tracking −0.3, opsz 24, wdth 88 |
| Text on | one pane (left), about 55 words | one pane (left), about 90 words | both panes, about 190 words |
| Folded | 22.5 / 35, paragraph gap 12 | not drawn (gap G8) | not drawn (gap G8) |

Reading text colour per story (source): Jataka `#10283A`; Anansi `#FBF2E2`; Urashima `#13264A`. Default `#12203A`. Features: kerning and ligatures on, hanging punctuation at line start, "pretty" wrapping (avoid short last lines).

### 4.3 Word-level styles (source)

| Style | Spec |
|---|---|
| **Voice** (`say`) | wght 640 in the character's voice colour. A face chip sits where a voice starts. |
| **Face chip** (`who`) | circle 1.12 em, baseline offset −0.22 em, margins 0.04 em left / 0.22 em right, ring 1.5 pt in the voice colour, shadow `0 2 5 rgba(0,0,0,.18)`, white (or given) background |
| **Tap-to-see word** (`tap`) | wght 640, no line break inside, horizontal padding 0.18 em, radius 0.34 em; highlight band from 8% to 92% of the line box: `rgba(255,196,61,.5)` → `rgba(255,170,61,.38)`; 2 pt underline `rgba(240,140,20,.9)`; a four-point spark 0.5 em, raised 0.5 em, 0.16 em after the word, colour `#F08A12` |
| Tap word, **open** (`tap.on`) | solid `#FFC43D`, text `#16123D`, shadow `tapOn` |
| Tap word, **seen** (`tap.seen`) | highlight `rgba(255,196,61,.28)`, underline and spark `#FFB020` |
| **Character name** (`name`) | wght 640, dotted underline 2 pt, offset 0.2 em, in the character colour, no line break inside |
| Name, **open** (`name.on`) | no underline; solid `#FFC43D`, radius 0.34 em, padding 0.2 em, shadow `tapOn`, text `#16123D` |
| **Sound / motion word** (`pop`) | Bricolage wght 760, opsz 30, wdth 86, tracking −0.2, colour coral or given; size 1.25 em ("whisk!") or 1.42 em ("Off we go!") |
| **Stretched word** (`think`) | italic, wght 560, letter spacing 0.14 em ("*t h o u g h t*") |
| **Text on a path** | Bricolage 33 pt, wght 720, opsz 40, wdth 92, tracking +0.5, gradient `#1B4C93` → `#2F8FCB`, on a wave curve with a dotted echo line `#7FB9DB` beneath |

Tap-highlight colours per story (source): Jataka default (sun); Anansi `rgba(255,196,61,.3)` / `rgba(255,160,61,.22)`, line `#FFC43D`, spark `#FFD25A`; Urashima `rgba(255,150,120,.34)` / `rgba(255,120,100,.26)`, line and spark `#F4503F`.

Voice colours (source): Crocodile `#17694A`; mother Crocodile `#0E5A55` (chip background `#FFE2A8`); Monkey `#A8501C`; Father Anansi `#FFB86B`; Kweku Tsin `#FFD25A`; Urashima `#1B4C93`; Tortoise `#2F6B45`.

Rule: marked words are never signalled by colour alone — the tap word always has its underline and spark, the name always has its dotted underline.

### 4.4 UI type scale

| Role | Family | Size / line | wght | Tracking | Axes | Colour |
|---|---|---|---|---|---|---|
| Splash wordmark | Bricolage | 158 / 158 | 800 | −3 | opsz 96, wdth 100 | white; R and A in `wordmark.ra` |
| Splash tagline | Atkinson | 19 | 480 | +0.2 | — | white 82% |
| Screen title (`h1`, "For grown-ups") | Bricolage | 30 / 31.5 | 760 | −0.9 | opsz 48, wdth 90 | ink |
| Hero title (subscription left) | Bricolage | 36 / 37 | 780 | −1.2 | opsz 60, wdth 90 | white |
| Card hero title (Rin Gin) | Bricolage | 40 / 40 | 780 | −1.2 | opsz 60, wdth 90 | white |
| Character name title | Bricolage | 38 / 38 | 800 | −1.2 | opsz 60, wdth 90 | `#2A1408` |
| Big number (parent "25") | Bricolage | 56 / 56 | 800 | −2.5 | opsz 96, wdth 90 | ink |
| Price ("TBD") | Bricolage | 46 / 46 | 800 | −1.5 | opsz 96, wdth 90 | ink |
| Stat number | Bricolage | 26 | 800 | −0.8 | — | ink |
| "Keep reading" title | Bricolage | 25 / 26 | 760 | −0.7 | opsz 36, wdth 88 | `#13264A` |
| Gate title | Bricolage | 25 | 780 | −0.7 | opsz 36, wdth 90 | ink |
| Card heading (`h2`) | Bricolage | 17 (15.5 and 19 variants) | 700 | −0.3 | opsz 20, wdth 92 | ink |
| Wordmark in nav | Bricolage | 22 | 800 | −0.3 | opsz 30, wdth 96 | ink, "RA" `#FF5B3D` |
| Button label | Bricolage | 17 (15–18) | 700 | −0.2 | — | white |
| Section label (`lab`) | Bricolage | 11, uppercase | 650 | +0.9 | — | ink 50% |
| Chip | Bricolage | 12 | 650 | +0.1 | — | per chip |
| Crumb title | Bricolage | 14 / 16 | 650 | −0.1 | opsz 14, wdth 95 | ink 90%, one line, truncates |
| Crumb subtitle | Bricolage | 11.5 | 500 | +0.1 | — | 66% of the title colour |
| Footer / page count | Bricolage | 12 | 600 | — | — | ink 86% or white |
| Story card title | Bricolage | 13 / 15.5 | 680 | −0.15 | — | ink, max 3 lines |
| Story card place | Bricolage | 11 | 600 | — | — | ink 60% |
| Tab label | Bricolage | 10.5 | 650 | — | — | ink 55%; selected `#5A3FE0` |
| Segment label | Bricolage | 13 | 650 | — | — | ink 70%; tier colours |
| Body small (`sub`) | Atkinson | 13 / 18 (12 and 12.5 variants) | 450 | — | — | ink 62% |
| Card line (tap-to-see, character) | Atkinson | 19 / 29 | 480 (470 on the character card) | — | — | `#F2F8FF` / `#2A1408` |
| Culture note body | Atkinson | 13.5 / 19.5 | 440 | — | — | `#DDEBFF` |
| Culture note label | Bricolage | 12, uppercase | 700 | +0.7 | — | `#FFB3A8` |
| Card subtitle (romanised name) | Bricolage | 13 | 600 | +0.2 | opsz 14 | `#8FE3E8` |
| Trait pill | Bricolage | 12.5 | 680 | — | — | per pill |
| Toast | Bricolage | 13.5 | 650 | — | — | `#13264A` |
| Aa control | Atkinson | 16 with 12 small cap | 700 | −0.3 | — | chrome |
| Settings row | System (Inter in design) | 15.5; value 14.5 | 400 | −0.2 | — | ink; value ink 50% |
| Gate words ("seven · three · nine") | Atkinson | 21 | 700 | +0.2 | — | `#5A3FE0` |
| Gate digit | Bricolage | 30 | 760 | — | — | ink |
| Keypad key | System | 23; letters 8.5 wght 700 tracking +1.6 | 400 | — | — | ink |
| Chart axis | System | 10; grid label 9.5 | 400 (today 600) | — | — | ink 50% |

## 5. Components

### 5.1 Round glass button
40 × 40, radius 20, glass (light or dark by pane), icon centred. Icons: back chevron (12 × 20, stroke 2.6), close ✕ (13 × 13, stroke 2.3). Hit area at least 44 × 44. Position: left 20, top 50 on the reference pane (left 18, top 56 folded).

### 5.2 Capsule glass control ("Aa" + bookmark)
Height 40, radius 20, horizontal padding 15, gap 14 between items. Position: right 20, top 50 (right 18, top 56 folded). Two separate hit targets, each at least 44 pt wide.

### 5.3 Chip
Height 28, radius 14, padding 9 left / 11 right, icon gap 6, Bricolage 12 wght 650. Variants:
- **Tier chip (glass)** in the reader footer: tier glyph + name, text in the tier's chip colour.
- **Tier pill (solid)** on covers: pill background and text from §3.2; height 22 on small covers (10.5 pt text), 24 on the "Keep reading" card.
- **Origin chip**: pin icon (10 pt) in the story's pin colour + label ("Ancient India", "Akan · Ghana", "Japan").
- **Page chip**: page dashes + "1 / 14", padding 12, gap 9.
- **Streak chip**: height 32, radius 16, white, flame in `#E8552B`, text "5 days".

### 5.4 Tier glyph
Three bars 3.5 wide, heights 5 / 8 / 11, gap 2, radius 1.5, current colour; bars above the tier at 28% opacity.

### 5.5 Page dashes
Dashes 10 × 4, radius 2, gap 3, current colour at 22%; read pages at 60%; current page 20 × 4 in coral (the story accent). The design draws 7, 6 or 9 dashes for 14, 6 or 19 pages; rule (estimate): show `min(pageCount, 9)` dashes and map the current page proportionally.

### 5.6 Round page-turn button
60 × 60 (54 × 54 folded), radius 30, gradient per story (§3.3), shadow `pageTurn`, white arrow 26 × 22 stroke 3.2 (dark `#3A1B08` on the amber variant), outer ring. Position: right 24, bottom 24. It is the only forward control. Accessibility label "Next page".
A "previous page" control exists in the source CSS (`.prev`, left 24, bottom 34) but is not placed on any screen; going back a page is a design gap (covered by G3).

### 5.7 Story crumb
Title (one line, truncating) and subtitle (part or series, plus "· Free sample" when sampling) to the right of the back button: left 70, top 53, right 22.

### 5.8 Tap-to-see hotspot — states
1. **Idle:** highlight band, underline, spark (§4.3).
2. **Open:** word becomes solid sun with a glow. On the text pane: a **beam** (band the height of the tapped paragraph, gradient sun 0% → 20% at 60% → 50% at the hinge edge) and a **place marker** ("keeper": 5 pt wide, radius 3, `#FF7A3D`, halo 4 pt at 18%, at x 12, spanning the paragraph). Other paragraphs drop to 42% opacity (45% on Low). The facing pane shows the card with an **inlet** glow on its hinge edge at the same height (14 pt wide, sun 75% → 0).
3. **Returned:** card gone; beam fades to a faint left-weighted wash (sun 22% → 6% → 0); marker stays; toast "You are back at your line" on the facing pane (height 38, radius 19, glass, orange 22 pt disc with a return arrow), top 104, centred; word switches to **seen**.
4. **Seen:** quieter highlight (§4.3). Still tappable.

When the marker and wash clear after a return is not specified (estimate: on the next page turn or after the toast fades; confirm in build review).

### 5.9 Tap-to-see card (facing pane)
Full pane, background from the card's own palette (Rin Gin: `#06204A`). Picture fills the top 404 pt and fades into the background over 300–406 pt. Close button (round glass) top-left. Title (40 pt) at top 372 with an optional subtitle; one line to read (19 / 29) at top 446; culture note box at top 520 (inset 20, radius 22, fill white 10%, edge white 22%, label with pin "FROM JAPAN"); primary button "Back to my line" (52 high, inset 20, bottom 26) with the return-arrow icon. No other controls.

### 5.10 Character card (facing pane)
Full pane. Top: character portrait on a warm gradient with a sunburst, 400 pt high. Bottom sheet from top 372: fill `#FFFBF4`, top radius 34, shadow `0 -10 30 rgba(160,60,0,.18)`. Inside (inset 28, top 26): label "CHARACTER · IN PART I AND PART II" (`#C2571C`), name (38 pt), up to three trait pills (height 30, radius 15; e.g. `#FFE9B8`/`#8A4A00`, `#D9F5E4`/`#0B6B4A`, `#FFE0D6`/`#B33A1C`), a short description (19 / 29). Primary coral button "Back to my line" (inset 20, bottom 26). Text-pane behaviour is the same as tap-to-see: marker, dimming, the name shown in its open state.

### 5.11 Primary, ghost and quiet buttons
Height 52 (42–56 by context), radius = half height, Bricolage 17 wght 700, icon gap 9. Primary: `button.primary` gradient and shadow. Violet (Subscribe): `button.violet`, shadow `0 12 24 rgba(90,63,224,.36)`. Sun: `button.sun`. Quiet (Restore Purchases): fill `rgba(22,18,61,.06)`, ink text, no shadow. Ghost: fill white 14%, 1 pt inner edge white 28%, white text.

### 5.12 Card
Radius 26, fill white 78% (86% in the parent view), shadow `card`, padding 14–18. Used for streak, shelf, parent stats, level list.

### 5.13 Cover
Full-bleed art, no title baked in. Radius by size (§3.4), shadow `cover`, tier pill at top-left 7, finished tick (24 pt white disc, `#0B8A6C` check) at bottom-right 7. Library card: 116 × 134 with title (max 3 lines) and origin below.

### 5.14 Segmented level filter
372 × 38, radius 19, track `rgba(22,18,61,.07)`, padding 3; segments All / Low / Medium / Advanced with tier glyphs and tier pill-text colours; selected segment white with shadow `0 2 8 rgba(40,24,110,.14)`.

### 5.15 Tab bar
Floating glass capsule, height 62, radius 31, padding 5, centred, bottom 22, on the left pane. Three items 92 wide: Library (home icon), My shelf (shelf icon), Grown-ups (lock icon). Selected: fill `rgba(110,86,255,.13)`, colour `#5A3FE0`.

### 5.16 Parent view rows
- **Level row:** 40 × 40 tile (radius 14, tier pill background, tier glyph scaled 1.45), tier name (15.5 pt heading), state on the right ("Finished 1 story" in ink 55%, "Reading now" in `#5A3FE0`), progress bar 6 pt (track ink 8%, fill tier pill-text colour), detail line 12 pt. Rows separated by 0.5 pt hairlines.
- **Settings row:** height 46, padding 16, label left, value right in ink 50%, chevron in ink 30%, 0.5 pt separators, in a card with radius 20. Rows: Appearance, Manage Subscription, Restore Purchases, Privacy ("No ads · No tracking"), Terms and legal.
- **Stat trio:** three equal columns with 0.5 × 44 pt dividers: number (26 pt) over caption (12 pt).
- **Pages chart:** seven bars 26 wide, top radius 4, `#B9ADFF`, today `#5A3FE0`; zero days are a 2 pt line; grid lines at 3 and 6 pages; value label above today and the maximum. The y-scale must adapt to the data (the fixed maximum of 6 is sample data).

### 5.17 End-of-sample card
Glass card pinned to the bottom of the text pane (inset 16, bottom 24, radius 30, padding 18): small cover 50 × 62, heading "The free sample ends here" (19 pt), line "12 more pages are waiting in this story." (count computed), primary button with lock icon "Ask a grown-up to unlock" (height 50). No price, no plan name.

### 5.18 Grown-up gate
Sheet over a dimmed (`rgba(12,8,40,.46)`) facing pane, from top 92, top radius 36, fill `#F4F2FB`, grab handle 36 × 5, close button 30 pt top-right. Content centred: lock disc 52 pt (`#8E7BFF` → `#5A3FE0`), "Grown-ups only", "To continue, type these numbers:", three number words in violet, three digit boxes 54 × 62 (current box: 2.5 pt `#6E56FF` edge with a 4 pt halo and a caret), "Omramo never asks a child to buy anything." A numeric keypad fills the bottom 256 pt. The digits must be random per presentation. The mechanic is a concept (PRD Q9).

### 5.19 Family plan card and subscription screen
Left pane (dark aurora): close button, label "OMRAMO FAMILY", headline "Every story. / Every level. / One family.", three fanned covers (92 × 116, rotated −7°, 0°, +7°), four benefits (34 pt icon tile radius 12, white 12% fill, icon `#FFD25A`; title 15.5 pt wght 700; detail Atkinson 13 / 18 white 70%).
Right pane (`#F4F2FF`): label "CHOOSE A PLAN"; **plan card** 372 × 176, white, 2.5 pt `#6E56FF` inner edge, shadow `0 16 34 rgba(90,63,224,.2)`, plan name, 26 pt violet check disc, price (46 pt) with period beside it, and the auto-renew sentence; info card "The free sample stays free"; Subscribe button (violet, height 56); Restore Purchases (quiet, height 50); renewal terms paragraph; links "Terms of Use", "Privacy Policy" in `#5A3FE0`.
The price string always comes from StoreKit. Until a product exists the card shows "TBD — price not set yet", exactly as designed.

### 5.20 Splash wordmark across the hinge
`OM` + `R` right-aligned 9 pt from the hinge edge of the left pane; `A` + `MO` left-aligned 9 pt from the hinge edge of the right pane; top 214; so the hinge runs through the middle of "RA". R and A carry the `wordmark.ra` gradient. Each pane has a 60 pt warm edge glow (`rgba(255,150,90,.22)`) and a 2 pt seam line on its hinge edge from top 150 to bottom 150. Tagline at top 404: "A magical book" right-aligned on the left pane, "that you read." left-aligned on the right. Bottom-left: three overlapping 40 pt cover discs. Bottom-right: three origin chips (white 9% fill). Small four-point "motes" in `#FFD25A`.
Folded splash is not drawn (estimate: the full word "OMRAMO" on one line scaled to the pane width with the same gradient on "RA").

### 5.21 Story map card
372 × 214, `mapCard` gradient. Dotted world map (dots white 30%, radius 1.5, every 5°). Pins: read (solid dot with white edge and a white label pill), reading now (same with a pulsing-looking halo: 13 pt 22% disc and 8 pt ring), later (3.6 pt dashed white ring, no label, no title promised). Legend row at the bottom.

### 5.22 Streak card, shelf card, friends row
- Streak: heading "5 days in a row", note "A day counts when you read a page", seven day discs (30 pt; done = `streakDay` gradient with a white check; today = extra white and `#FF7A3D` rings; future = ink 6%).
- Shelf: heading, "2 stories finished · 25 pages read", covers 58 × 72 slightly rotated; in-progress cover at 45% with a "5 / 19" pill; empty slots dashed.
- Friends: avatars 48 pt with a white ring and a coloured ring, name below (10.5 pt); not-yet-met friends greyscale at 40%.

### 5.23 Icons
The design icons are hand-drawn SVGs in `base.js` (`I.back`, `fwd`, `bookmark`, `pin`, `x`, `lock`, `flame`, `check`, `spark`, `book`, `person2`, `gear`, `chevR`, `ret`, `globe`, `home`, `shelf`). They are not Apple assets. Port them as vector assets (SVG/PDF in the asset catalog) rather than substituting SF Symbols, to keep the look.

## 6. Screen-by-screen spec

Positions are on the 432 × 720 reference pane unless stated. "L" and "R" are the left and right panes.

### 01 Splash — `docs/design/01-splash.png`
Dark aurora across both panes. Wordmark, seam, tagline, cover discs and origin chips as in §5.20. Light status bar and home indicators. No buttons; the app moves to the library when content is ready. The minimum display time is not specified (estimate: about 1.2 s, skipped under Reduce Motion to a plain fade).

### 02 Library home — `docs/design/02-library-home.png`
Light aurora.
**L:** wordmark (left 30, top 56); streak chip (right 28, top 52); label "KEEP READING" (top 110); keep-reading card 372 × 186 at top 132: story art, tier pill, title (width 190), Continue button (height 42, book icon), "Page 5 of 19", origin, progress bar 5 pt; label "STORIES BY LEVEL" (top 334); level filter (top 356); story cards row (top 408, gap 12); tab bar.
**R:** label "WHERE THE STORIES COME FROM" (top 60); map card (top 84); streak card 372 × 104 (top 312); shelf card 372 × 132 (top 430); label "FRIENDS YOU HAVE MET" (top 580); avatars (top 604, gap 11).
Notes: the long Medium title truncates at three lines. With more than three stories the cards row scrolls horizontally (estimate; the design shows exactly three). All counts are sample data.

### 03 Reading, Low — `docs/design/03-read-low.png`
Scene: river morning (banyan, island, crocodile) across both panes; the branch and leaves reach into L.
**L (light chrome):** back button; crumb "The Monkey and the Crocodile / Part I"; text column left 30, top 106, width 374, Low scale: lead sentence with tap word "river bank"; body paragraphs; character name "Crocodile" with dotted underline; crocodile voice in `#17694A` with a face chip. Footer: Low tier chip, origin chip "Ancient India".
**R (dark chrome):** Aa + bookmark capsule; page chip "1 / 14" (ends 100 pt from the right edge); coral page-turn button.
The little crocodile in the water looks toward the text. Home indicator light on both panes.

### 04 Reading, Medium — `docs/design/04-read-medium.png`
Scene: twilight forest; both panes use dark chrome; text colour `#FBF2E2`.
**L:** crumb "How Wisdom Became the Property of the Human Race / An Anansi story" (title truncates); text left 30, top 108, width 372, Medium scale; lead sentence with two character names (Father Anansi `#FFB86B`, Kweku Tsin `#FFD25A`); tap word "precious pot" with the Anansi highlight colours. Footer: Medium chip (text `#FFC43D`), "Akan · Ghana"; footer chips use glass `rgba(30,18,70,.55)`.
**R:** Aa capsule, page chip "3 / 6", amber page-turn button with a dark arrow.
Kweku Tsin peers out of the leaves below the text.

### 05 Reading, Advanced — `docs/design/05-read-advanced.png`
Scene: pale sea haze with wave bands rising from under the L text into the R picture; light chrome on both panes; text colour `#13264A`.
**L:** crumb "The Story of Urashima Taro / The Fisher Lad"; text left 30, top 108, width 374, Advanced scale; tap word "fishing boats" (Urashima highlight colours); name "tortoise" (`#2F6B45`).
**R:** Aa capsule; text on a path "“Urashima, Urashima!”" in a 400 × 96 box at left 18, top 86; text continues at left 30, top 186, width 372; picture (boat, Urashima, tortoise, sun) in the lower half; page chip "5 / 19"; red page-turn button.
Known flaw accepted in the lock: "fishing boats" forces an early line break.

### 06 Tap-to-see open — `docs/design/06-tap-to-see-open.png`
**L:** same reading layout, Advanced. Tapped paragraph (the tortoise's question) at full strength with beam and place marker; "Rin Gin" in the open state; other paragraphs at 42%. Chrome stays.
**R:** tap-to-see card (§5.9): palace picture; close button; "Rin Gin" / "Ryūgū-jō · the Dragon Palace"; line "A palace at the bottom of the sea, where the Dragon King lives."; culture note "FROM JAPAN"; sun button "Back to my line". The Aa capsule, page chip and page-turn button are covered by the card: the child cannot turn the page while a card is open.
The culture-note wording is unverified concept text and must be fact-checked.

### 06b Tap-to-see return — `docs/design/06b-tap-to-see-return.png`
**L:** all paragraphs back to full strength; faint wash and place marker on the same paragraph; "Rin Gin" in the seen state.
**R:** scene visible again (the tortoise now in the boat); toast "You are back at your line"; Aa capsule; page chip; page-turn button.
Note: the page chip reads "7 / 19" here while the dashes show the fourth; this is sample data, not a rule.

### 07 Character card — `docs/design/07-character-card.png`
**L:** Low reading layout. First paragraph held with a short place marker (x 12, top 110, height 30); "Monkey" in the open name state; monkey voice `#A8501C`; sound word "whisk!" at 1.25 em in `#E8552B`; other paragraphs at 45%. Footer: Low chip, origin chip, and a "7 / 14" chip (the page chip moves to L because R is covered).
**R:** character card (§5.10): the Monkey waving on a sunburst; label, name, three trait pills, description, coral "Back to my line". Home indicator dark.
Card wording is concept text.

### 08 Parent view — `docs/design/08-parent-view.png`
Light aurora. Reached only through the grown-up gate.
**L:** back button; title "For grown-ups" (left 30, top 104); subtitle "What your child has read this week." (top 142); pages card 372 × 282 (top 178): label "PAGES READ · LAST 7 DAYS", big number + "pages", chip "Read on 6 of 7 days", chart, note "A page counts when your child turns it after reading."; stat trio card 372 × 86 (top 474): stories finished, cultures visited, days in a row; footnote with a book icon (top 580): "Omramo reports reading, not screen time. There is no timer and no usage clock anywhere in the app."
**R:** label "READING LEVEL" (top 62); level card 372 × 262 (top 86) with three level rows; note (top 358): "Each story belongs to one level, chosen for its message. Your child can read at any level at any time."; label "SETTINGS" (top 412); settings card (top 436).
There is no time metric of any kind on this screen, and none may be added.

### 09 End of sample → grown-up gate — `docs/design/09-sample-paywall.png`
**L:** Low reading layout; crumb subtitle "Part I · Free sample"; page text; the stretched word "thought."; end-of-sample card (§5.17) over the lower scene. No footer chips and no page-turn button: the sample ends here.
**R:** after "Ask a grown-up to unlock": the subscription header dimmed behind the gate sheet (§5.18).
The screenshot shows both moments at once. Sequence: (1) last sample page shows the end card, with R still showing the scene; (2) tapping the button raises the gate on R; (3) a correct answer opens 09b; a wrong answer shakes and issues new numbers (estimate).

### 09b Family subscription — `docs/design/09b-family-subscription.png`
As §5.19. L dark aurora, R `#F4F2FF`. Close returns to the story at the sample end. After a successful purchase the story continues from the next page (estimate; not drawn). Accepted flaw: the lower third of both panes is empty.

### 10 Folded reading — `docs/design/10-folded.png`
One pane with Dynamic Island. Scene fills the pane; the picture occupies the top (to about y 340) and ends in a wave edge over a pale text area. Back button (left 18, top 56); Aa capsule (right 18, top 56). Text left 30, top 366, width 376, Low at 22.5 / 35 with 12 pt paragraph gaps: name "Monkey", tap word "ripe fruit", "“Off we go!”" as a 1.42 em sound word in the crocodile's colour, voices with face chips. Footer: Low chip left, page chip "5 / 14" right (ends 92 pt from the right edge); page-turn button 54 pt at right 22, bottom 22. The origin chip and the crumb are omitted when folded.
The folded page number is the same page as unfolded (5 of 14), so position carries across the fold.

## 7. Accessibility requirements that are part of the design

- Minimum hit target 44 × 44 pt, including tap words (expand the hit area beyond the glyphs).
- Contrast: body text on scene backgrounds must reach 4.5:1; scenes must keep the text area calm. This is a rule for art direction as well as code; each spread's text colour is set per story (§4.2).
- Marked words carry a non-colour cue (underline, spark, dotted underline).
- Every scene, card picture and face chip has alt text in the content file.
- Reduce Motion variant for every animation (§3.7).
- Text size: the "Aa" control scales the tier's type from its designed size; see `docs/ARCHITECTURE.md` §12.

## 8. Concept versus decided (from the design notes)

| Concept — to be replaced or confirmed | Decided |
|---|---|
| All illustrations; the device shell | Three tiers, one story per tier, tier locked per story |
| Pane size, hinge gap, status-bar split | Tap-to-see on the facing pane, return to the same line |
| Page counts (14, 6, 19), parent-view numbers, streak length | Two-page free sample, family subscription, grown-up gate |
| Culture-note and character-card wording | Pages read, not screen time; no ads or tracking; marketed as ages 6 to 14 and up; Advanced must not look like a little-kid book |
| The gate mechanic (type three numbers) | Story text unaltered from the source texts |
| "More cultures later" markers (no titles promised) | The OM / RA / MO mark |

## 9. Open questions (design)

1. Design gaps G1–G12 listed in `docs/PRD.md` §7: who designs them (PRD Q21)?
2. Motion values in §3.7 are proposals. Approve or supply.
3. System font versus bundled Inter for settings and keypad (PRD Q15).
4. When does the place marker clear after returning from a card (§5.8)?
5. How does a child go back one page? No control is placed in the locked screens (§5.6).
6. Page-dash rule for long stories (§5.5).
7. Folded splash layout (§5.20).
8. Are tier names "Low / Medium / Advanced" final on child-facing chips (PRD Q3)?
