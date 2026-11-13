# Omramo design pass v2 — Srikanth's feedback (Fable 5.2)

Srikanth reviewed the v1 Omramo designs in `designs/` (look at `designs/png/*.png` to see what he rejected) and said, verbatim:

> "i did not like the omramo designs. do the real thing. real mockups. should feel real app screenshots. i dont care what tech it will use. also the overall fonts and desings should not looks like a typical hardcover book. the lines spacings. the fonts, the art insertions all has to be top notch, innovative and pleasing and sepctacular to read."

Do not modify anything in `designs/` (v1). Write everything for this pass into `designs-v2/`.

## What he means (follow all of it)
1. **Real app screenshots, not mocks.** Every screen must look like a genuine, high-fidelity screenshot of a shipped iPhone Duo app: real iOS status bar (time, signal, battery), safe areas, real system UI chrome (sheets, buttons, tab/toolbar, haptic-feel controls), finished art direction. No wireframes, no "HTML-looking" mocks, no captions/annotations on the screens, no "PLACEHOLDER" labels, no grey boxes. Put any notes in `designs-v2/design-notes.md`, not on the images.
2. **Any tech is fine.** HTML/CSS + SVG + canvas, generated illustration via code, whatever gives the most real-looking result. Render final PNGs at device resolution (@3x of your stated point size). The two panes of the unfolded Duo are separate screens with a hinge/fold between them — present them as a device screenshot, optionally with a subtle real device frame on a clean backdrop for a presentation version, plus a frameless raw screenshot version.
3. **Real illustrations, not placeholders.** Draw rich, finished illustrations (detailed layered SVG/canvas art: gradients, lighting, texture, depth, characters with personality), culturally grounded for each story's civilization (ancient India / Jataka; Akan people of Ghana / Anansi — consider Kente and Adinkra visual language respectfully; Japan / Urashima Taro — sea, Ryūgū-jō dragon palace, the lacquer box). Make the art look like a premium children's app, not clip-art. Be honest in design-notes.md that art is code-drawn concept art, not final commissioned illustration.
4. **Not a hardcover book.** Drop the paper-and-ink / serif-novel / cream page / book-spine look entirely. Invent a fresh, modern, innovative reading typography system: a distinctive display + reading font pairing, license-safe (Google Fonts / OFL), **downloaded and embedded** (base64 @font-face or local files in `designs-v2/fonts/`) so renders never fall back. Craft line spacing, measure, type scale per tier, rhythm, and word-level styling. Kids' reading text must be very legible and pleasing.
5. **Inventive art + text integration.** Art flowing around and between lines, inline tap-to-see word reveals, layered/parallax-feeling compositions, characters peeking into the text column, full-bleed scenes with text on calm reading zones, etc. It should feel spectacular to read — while **reading the text remains the core product**: no video, no autoplay, no default read-aloud; tap-to-see opens from a word and shows the visual on the facing pane, then returns to the same line.
6. The product rules still apply: read `2026-11-13-omramo-business-use-case-v5-story-tiers.md` (business case v5) and `omramo-discussion-brief.md` (16 points: civilization theme with map pin/culture note, Low/Medium/Advanced tiers locked per story, rewards only from reading, parents see pages read not screen time, family subscription + free sample + parental gate, no ads/tracking, Duo two-pane). You may evolve the brand palette away from paper/ink, but keep the OM | RA | MO mark idea (OM left pane, RA on the fold, MO right pane) — see `../../omramo-mark.md`.
7. Use the same three stories with their **real text on screen** from `stories/text/` (and `stories/SOURCES.md`): Low = The Monkey and the Crocodile (Jataka, ancient India); Medium = How Wisdom Became the Property of the Human Race (Anansi, Akan/Ghana); Advanced = The Story of Urashima Taro (Japan).

## Screens (minimum)
- `01-splash` (OM|RA|MO across panes + fold)
- `02-library-home` (tiers, civilization pins, bookshelf/streak from reading)
- `03-read-low`, `04-read-medium`, `05-read-advanced` (one reading spread per tier, each with its own typography scale)
- `06-tap-to-see-open` (word tapped, visual + one readable line + culture note on facing pane; text stays put)
- `07-character-card` (recurring character)
- `08-parent-view` (pages read, tier progress; no screen-time metric)
- `09-sample-paywall` (end of free sample → parental gate → family subscription; price "TBD", no invented prices)
- `10-folded` (folded single-screen reading state)
Optional extras welcome (e.g. tap-to-see return state, tier picker).

Output: `designs-v2/src/` (sources), `designs-v2/png/` (raw device-resolution screenshots), `designs-v2/png-framed/` (presentation versions), `designs-v2/index.html`, `designs-v2/design-notes.md` (direction, fonts with licences and sources, type scale per tier, art approach, interaction rules, what's concept vs final, brief 1–16 compliance table).

Render with headless Chrome, e.g. `google-chrome --headless=new --no-sandbox --disable-gpu --hide-scrollbars --force-device-scale-factor=3 --window-size=W,H --screenshot=OUT.png file://...` (set W,H to your point size). Wait for fonts to load (use `--virtual-time-budget=5000`).

## Self-review (mandatory)
After rendering, open (Read) every PNG and judge it against Srikanth's feedback: does it look like a real shipped app screenshot? Does it look like a hardcover book or a mock? Are fonts rendering (not fallback)? Is the line spacing and art integration spectacular? Redo any screen that fails, then re-render. Record the review outcome per screen in design-notes.md.

Constraints: work only inside this project folder (you may download fonts from fonts.google.com / github.com/google/fonts). No git, no push, no deploy, no contacting anyone, no paid services. Finish with a short summary.
