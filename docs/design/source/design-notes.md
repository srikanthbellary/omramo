# Omramo designs v2 — design notes (13 Nov 2026)

Second design pass after Srikanth rejected v1 (`designs/`, untouched). His brief: real app screenshots, not mocks; nothing that looks like a hardcover book; top-notch fonts, line spacing and art insertions. Open `index.html` to browse.

## What is in this folder

| Path | Contents |
|---|---|
| `png/` | 12 raw screenshots at device resolution, no frame, no captions |
| `png-framed/` | The same 12 in an illustrative Duo shell on a clean backdrop |
| `src/` | Sources: `lib/*.js` (shell, type system, art), `screens.js`, `screens-ui.js`, `screen.html` (loader), `frame.html`, `render.py`, `screens/*.html` (static snapshot of each screen) |
| `fonts/` | The three font files and their OFL licence texts |
| `index.html` | Gallery |

To re-render: `python3 src/render.py` (all), or `python3 src/render.py 03,05` (by name). It uses headless Chrome only.

## Canvas (my assumption, not an Apple spec)

- Each Duo pane is **432 × 720 pt**, rendered **@3x = 1296 × 2160 px**.
- Unfolded, the two panes sit either side of a **28 pt hinge gap**, so the raw unfolded screenshot is 892 × 720 pt = **2676 × 2160 px**. The gap is captured as a black band, the way dual-screen devices capture a spanned app.
- Folded is one pane, 1296 × 2160 px, with a Dynamic Island on the outer screen.
- Status bar: time on the left pane, signal/Wi-Fi/battery on the right pane. One home indicator per pane.
- The device shell in `png-framed/` is a drawn illustration, not an Apple asset.

## Direction: "the page is a place"

v1 put cream pages, a serif and a spine on screen. v2 removes all of it.

- **No paper, no spine, no serif.** Every reading spread is one continuous scene running under both panes and the hinge. The text sits in the calm part of that scene (sky, twilight, sea haze).
- **Each story has its own light.** Jataka: bright river morning. Anansi: twilight forest with light text. Urashima: pale sea haze. The app chrome (glass buttons, chips, the round page-turn button) stays the same across all three.
- **Brand palette moved off paper/ink:** midnight indigo `#130F36`, cloud `#F3F1FF`, coral `#FF6A4D`, sun `#FFC43D`. Tier colours: Low green `#12B58F`, Medium amber `#FF9F1A`, Advanced violet `#6E56FF`.
- **OM | RA | MO is kept.** On the splash, `OM` sits on the left pane, `MO` on the right, and the `R` and `A` press against the fold from either side in the accent gradient, so the hinge runs through the middle of `RA`. A raw screenshot cannot draw on the hinge itself; this is the closest honest version.

## Fonts (all embedded from `fonts/`, no fallbacks used)

| Role | Family | Licence | Source |
|---|---|---|---|
| Display: titles, lead sentences, sound words, UI labels | **Bricolage Grotesque** (variable: opsz, wdth, wght) | SIL OFL 1.1 | `github.com/google/fonts/tree/main/ofl/bricolagegrotesque` |
| Reading: all story text | **Atkinson Hyperlegible Next** (variable wght, roman + italic) | SIL OFL 1.1 | `github.com/google/fonts/tree/main/ofl/atkinsonhyperlegiblenext` |
| System chrome: status bar, settings rows, keypad | **Inter** (variable) | SIL OFL 1.1 | `github.com/google/fonts/tree/main/ofl/inter` |

Why this pair: Atkinson Hyperlegible was designed so similar letters (I/l/1, O/0, b/d) cannot be confused, which suits new readers; Bricolage Grotesque is a characterful grotesque that reads as "app", not "novel". Inter stands in for San Francisco, which cannot be embedded; the shipped Swift app would use the system font there.

Font rendering was checked in every PNG: display, reading and system faces all render; nothing falls back.

## Type scale per tier

| | Low | Medium | Advanced |
|---|---|---|---|
| Reading size / line height | 23.5 / 37 pt (1.57) | 19.5 / 32 pt (1.64) | 16.5 / 27 pt (1.64) |
| Weight | 460 | 430 | 420 |
| Paragraph gap | 17 pt | 16 pt | 12 pt |
| Measure (374 pt column) | about 30 characters | about 40 | about 46 |
| Lead sentence (display face) | 32 / 38 pt, weight 720 | 27 / 33 pt, weight 700 | 21 / 27 pt, weight 680 |
| Text share of the spread | one pane, about 55 words | one pane, about 90 words | both panes, about 190 words |
| Folded | 22.5 / 35 pt | not drawn | not drawn |

Word-level styling (wording is never changed, only typographic quotes and dashes):

- **Lead sentence** of a page is set in the display face instead of a drop cap.
- **Voices:** each character's speech has its own colour and a heavier weight, with a small face chip where the voice starts (crocodile green, monkey amber, tortoise green, Urashima blue).
- **Tap-to-see words** carry a soft highlight, an underline and a small spark.
- **Character names** have a dotted underline in the character's colour.
- **Sound and motion words** are set in the display face ("whisk!", "Off we go!"), stretched ("thought and *t h o u g h t*") or run along a path ("Urashima, Urashima!" floats on a wave line in 05).

## Art approach

All illustration is **code-drawn concept art** (layered SVG built by the scripts in `src/lib/`: gradients, procedural foliage, ripples and wave bands, a grain overlay). It is there to show the art direction and how art and text interlock. **It is not final commissioned illustration**, and it should be replaced by work from illustrators.

- **Jataka, ancient India:** banyan with aerial roots, lotus, fruit island, the Monkey and the two Crocodiles.
- **Anansi, Akan people of Ghana:** silk-cotton tree at twilight, kente-inspired cloth, a web mark inspired by the Adinkra symbol Ananse Ntontan, a spider on its thread as a nod to Anansi the spider. Barker's 1917 text calls Father Anansi a man, so he is drawn as one. The kente and Adinkra drawings are simplified by me and need review by Akan cultural advisers before anything ships.
- **Urashima Taro, Japan:** ukiyo-e-style wave bands with foam fingers, seigaiha pattern, a hazy red sun, the tortoise with a seaweed tail, the palace under the sea, the tied lacquer box on the cover. Needs review by Japanese illustrators or advisers.
- The culture note in 06 (Ryūjin, Ryūgū-jō, red and white coral) is from general knowledge of the legend, not from the Ozaki text; fact-check it before use.

How art and text integrate:

- The scene crosses the hinge: the banyan branch and leaves reach into the Low text pane; the swell rises from under the Advanced text into the picture.
- Characters look into the text: the little crocodile watches from the water under the Low text; Kweku Tsin peers out of the leaves below the Medium text.
- Text becomes art in one place per page at most (the call on the wave line).

## Interaction rules shown

- **Reading is the product.** No video, no autoplay, no read-aloud control anywhere. A page turns only when the child presses the round button.
- **Tap-to-see** opens only from a marked word. The visual takes the **facing pane**; the text pane does not move. The tapped paragraph stays at full strength with an orange place marker, the rest dims. The card has one line to read, one culture note with a pin, and one button: "Back to my line". It does not link to another visual.
- **Return** (06b): the card is gone, the marker and a brief toast show the same line, the word is marked as seen.
- **Character card** (07) works the same way from a name.
- **Rule for which pane:** the card opens on the pane opposite the tapped word. On Advanced spreads with text on both panes, it covers the far pane's text, never the line being read.
- **Rewards** come only from reading: finished stories on the shelf, a streak that counts a day when a page is read, friends met.
- **Parents** see pages read, stories finished and level progress. No time metric of any kind.
- **Purchase** sits behind a grown-up gate. Price reads "TBD".

## Concept versus decided

| Concept, to be replaced or confirmed | Taken from the brief / business case |
|---|---|
| All illustrations and the device shell | Three tiers, one story per tier, tier locked per story |
| Pane size, hinge gap, status bar split | Tap-to-see on the facing pane, return to the same line |
| Page counts (14, 6, 19), sample numbers in the parent view, streak length | Two-page free sample, family subscription, parental gate |
| Culture-note wording, character-card wording | Pages read, not screen time; no ads or tracking |
| The parental-gate mechanic (type three numbers) | Story text: unaltered from `stories/text/` |
| "More cultures later" markers on the map (no titles promised) | OM / RA / MO mark |

## Self-review per screen

I opened every PNG after rendering. First renders had real faults; these were fixed and re-rendered: stretched icons and a broken level filter in the library, text running into the island on Low, a tree that vanished into the sky and a hidden Kweku Tsin on Medium, gulls flying through the Advanced text, page indicators unreadable over art, status icons lost on foliage, numbers that disagreed between library and parent view.

| Screen | Real screenshot? | Book-like? | Fonts | Verdict |
|---|---|---|---|---|
| 01 splash | Yes | No | OK | Pass. Plainest screen of the set; the mark reads clearly across the fold. |
| 02 library home | Yes | No | OK | Pass. Medium title truncates at three lines. |
| 03 read Low | Yes | No | OK | Pass. Strongest of the three spreads. |
| 04 read Medium | Yes | No | OK | Pass with a weakness: Father Anansi's figure is the least convincing drawing. |
| 05 read Advanced | Yes | No | OK | Pass. "fishing boats" forces an early line break. |
| 06 tap-to-see open | Yes | No | OK | Pass. Palace side wings are slightly misaligned. |
| 06b return | Yes | No | OK | Pass. Right pane is sparse above the boat. |
| 07 character card | Yes | No | OK | Pass. |
| 08 parent view | Yes | No | OK | Pass. No screen-time metric. |
| 09 sample → gate | Yes | No | OK | Pass. |
| 09b subscription | Yes | No | OK | Pass. Lower third of both panes is empty. |
| 10 folded | Yes | No | OK | Pass. |

Honest limits: the human figures (Anansi, Urashima) are simpler than the animals; vector art drawn in code will not match a commissioned illustrator; nothing here has been tested with children.

## Brief compliance (points 1–16)

| # | Point | Where it shows |
|---|---|---|
| 1 | Global, English | All screens in English; three cultures on the map |
| 2 | Illustration-driven, game-like feel, for children who can read | Full-bleed scenes, round haptic-style controls, face chips (03–07, 10) |
| 3 | Stories are the core | Library leads with "Keep reading" and the stories (02) |
| 4 | Tap a word to see a visual; characters as visuals | 06, 06b, 07; marked words in 03–05, 10 |
| 5 | Oriented around reading | Text is the largest element on every reading screen |
| 6 | A magical book, not video | No play, audio or autoplay controls anywhere |
| 7 | Art pulls into the text, never replaces it | Art shows the moment just read; cards return to the line (06b) |
| 8 | Low / Medium / Advanced | Level filter (02), tier chip on every reading screen, three type scales |
| 9 | One story, one tier | Each story carries one tier chip; parent view says so (08) |
| 10 | Duo two-pane, visual opens beside text | 06, 07; all unfolded screens are two panes plus hinge. Swift build is not part of this pass |
| 11 | Family subscription, free sample, no ads or tracking, parental gate | 09, 09b; privacy row in 08 |
| 12 | Parents see pages read, not screen time | 08 |
| 13 | Rewards only from reading | Shelf, streak, friends met (02) |
| 14 | Three prototype books, one per tier | 02, and 03 / 04 / 05 |
| 15 | Tap-to-see and the fold are what must be proven | 06 → 06b sequence; scenes that cross the hinge; 10 for folded |
| 16 | Civilizations, map pin or culture note | Story map (02), pin chip on every reading screen, culture note (06), splash pins (01) |
