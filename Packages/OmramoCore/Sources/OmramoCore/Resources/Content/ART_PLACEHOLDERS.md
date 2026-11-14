# Art status: concept art drawn in code (round 3: one art direction across the three stories)

**No image file listed here exists yet.** The story and landmark JSON name each picture by a
file path, an alt text and a pixel size; the files are delivered later by the art workstream
(milestone C1). Until a file exists, the app draws the picture **in code**: SwiftUI `Canvas`
painters, chosen by the picture's *asset name* — the file name without folder or extension
(`art/scene-river.unfolded.heic` → `scene-river`).

- Painters: `App/Sources/Art/JatakaArt*.swift`, `AnansiArt*.swift`, `UrashimaArt*.swift`,
  `LandmarkArt*.swift`; shared kit `ArtKit.swift`; lookup and views `StoryArt.swift`.
- They are **our own drawings**, ported and extended from the locked design sources
  (`docs/design/source/src/lib/art-*.js`). No photographs, no third-party artwork, nothing traced.
- They are **concept art, not final illustration.** Every `review.art` field stays `pending`.
- **Round 2** pictures were seen on the Mac (simulator shots `r2-*.png`). **Round 3** then
  re-worked every painter to one shared art direction (`docs/ART_DIRECTION.md`; shared
  constants and helpers in `App/Sources/Art/ArtStyle.swift`) — again on a box with no Swift
  toolchain and no renderer. **The round-3 look has not been seen on a screen**: every picture
  needs a visual check on the Mac (`docs/BUILD.md` §7b), and the list at the end of this file
  says where it is most likely to look wrong.
- Each picture is rasterised once (`cachedArt()` in `StoryArt.swift`), so page turns, card
  reveals and the library-to-story transition move a cached image, not a redrawn `Canvas`.
- When a real file is added at the path below, the app shows it and stops drawing the code
  picture; no code change is needed. Run `python3 tools/validate_content.py --check-art` to
  list the files still missing.
- A picture no painter knows (a story added before its art) gets a calm gradient stand-in in
  the content's own `fallbackColors`, never a blank rectangle.

Sizes follow `docs/ARCHITECTURE.md` §7.2 (@3x of the 432 × 720 pt reference pane).
HEIC for opaque art, PNG where transparency is needed.

## How the code pictures adapt (what a delivered image must also allow for)

| Role | Drawn in | Notes for the illustrator |
|---|---|---|
| Scene, unfolded | 892 units wide, any height (720 on the Duo; about 520–1300 on iPad windows) | Ground, water and figures are anchored to the bottom, canopy and sky to the top; the sky stretches. A delivered image is aspect-filled instead, so iPad crops need checking (visual gap, `docs/BUILD.md` §6). |
| Scene, folded | 432 units wide, about 240–440 high | The picture band at the top of one pane; the app cuts a wave along its bottom edge. |
| Tap-to-see / landmark picture | 432 × 404 | The lower quarter fades into the card colour. |
| Character portrait | 432 × 400 | The card's sheet overlaps the bottom 28 pt. |
| Face chip | 100 × 100, clipped to a circle | Shown from about 18 pt (inline) upward. |
| Cover | 300 wide, 150–375 high | The same cover is shown tall (story card) and wide ("Keep reading"). |

Text-area rule for scenes (dark or light, per story): the part of the scene under the text
must stay calm and keep 4.5:1 contrast with the story's text colour. The strip under the hinge
(x 432–460 of 892) is not visible on hardware: no faces or essentials there. A framed landmark
(the Taj Mahal, Tokyo Skytree) never appears in scene art; it appears only on its card.

## `stories/monkey-and-crocodile/` — Low, bright river morning (text `#10283A`, on the leading pane)

| File | Pixels | What it shows | Used on | Drawn by |
|---|---|---|---|---|
| `art/cover.heic` | 720 × 900 | The Monkey riding on the Crocodile's back across the river. No title baked in. | Library card, "Keep reading" card | `JatakaArt` `cover` |
| `art/scene-river.unfolded.heic` / `.folded.heic` | 2676 × 2160 / 1296 × 2160 | Morning. The great banyan on the bank (trailing side), the Monkey on a branch, the little Crocodile in the water looking toward the text. Screen 03. | Pages 1–3, 8 | `scene-river` (a port of the design's `riverScene`) |
| `art/scene-ride.unfolded.heic` / `.folded.heic` | same | Mid-river: the Monkey on the Crocodile's back; the fruit island far ahead. Screen 10 when folded. | Pages 4–7 | `scene-ride` (new composition unfolded; the folded picture is drawn separately, after screen 10) |
| `art/scene-island.unfolded.heic` / `.folded.heic` | same | The new tree, the stepping-stone rock, the island of fruit trees. | Pages 9–10 | `scene-island` (new composition) |
| `art/scene-dusk.unfolded.heic` / `.folded.heic` | same | Dusk, pale sky. The Crocodile lying flat on the rock; the Monkey at the water's edge. | Pages 11–14 | `scene-dusk` (new composition) |
| `art/face-monkey.png` | 144 × 144 | The Monkey's face. | Voice chip | `face-monkey` |
| `art/face-crocodile.png` | 144 × 144 | The little Crocodile's face. | Voice chip | `face-crocodile` |
| `art/face-mother-crocodile.png` | 144 × 144 | The Mother Crocodile's face (older, heavier brow). | Voice chip | `face-mother-crocodile` |
| `art/char-monkey.card.heic` | 1296 × 1200 | The Monkey waving from a branch on a sunburst. Screen 07. | Character card | `char-monkey` |
| `art/see-river-bank.heic` | 1296 × 1212 | A grassy bank beside a wide river, a tall tree leaning over the water. Fades into `#0A6585`. | Tap-to-see card | `see-river-bank` |
| `art/see-ripe-fruit.heic` | 1296 × 1212 | A branch heavy with golden fruit. Fades into `#1F6B50`. | Tap-to-see card | `see-ripe-fruit` |

## `stories/anansi-wisdom/` — Medium, twilight forest (light text `#FBF2E2`, dark chrome)

Every kente, pot and house drawing goes to the Akan reviewer with the text (`culturalReview:
required`). Cloth and pot decoration is limited to woven blocks, plain bands, a zig-zag and
the design's web mark; no named adinkra symbol is drawn.

| File | Pixels | What it shows | Used on | Drawn by |
|---|---|---|---|---|
| `art/cover.heic` | 720 × 900 | Father Anansi on the great tree with the glowing pot, under the moon. | Library | `AnansiArt` `cover` |
| `art/scene-village.unfolded.heic` / `.folded.heic` | 2676 × 2160 / 1296 × 2160 | Dusk in the village; Father Anansi, whom everyone asks for advice. | Pages 1–2 | `scene-village` (new composition) |
| `art/scene-forest.unfolded.heic` / `.folded.heic` | same | The forest path at twilight; Anansi with the pot; Kweku Tsin following. | Pages 3–4 | `scene-forest` (new composition) |
| `art/scene-climb.unfolded.heic` / `.folded.heic` | same | Anansi clinging to the great tree, the pot in front of him; the big moon. Screen 04. | Pages 5–7 | `scene-climb` (a port of the design's `forestScene`) |
| `art/scene-wisdom.unfolded.heic` / `.folded.heic` | same | The pot broken on the rock; wisdom drifting out over the world as golden motes. | Page 8 | `scene-wisdom` (new composition) |
| `art/face-anansi.png`, `art/face-kweku.png` | 144 × 144 | Father Anansi; Kweku Tsin. | Voice chips | `face-anansi`, `face-kweku` |
| `art/char-anansi.card.heic`, `art/char-kweku.card.heic` | 1296 × 1200 | Father Anansi with the pot; Kweku Tsin peeking between leaves. | Character cards | `char-anansi`, `char-kweku` |
| `art/see-precious-pot.heic` | 1296 × 1212 | The great sealed clay pot, glowing. Fades into `#2A1650`. | Tap-to-see card | `see-precious-pot` |
| `art/see-forest.heic` | 1296 × 1212 | The rain forest of southern Ghana. Fades into `#12303A`. | Tap-to-see card | `see-forest` |

## `stories/urashima-taro/` — Advanced, pale sea haze (text `#13264A` on both panes)

Grown-up, restrained, woodblock-influenced: this tier (10–12+) must not look babyish to a
13- or 14-year-old. The picture keeps the lower 300 pt of the trailing pane (`scene.textArea`).

| File | Pixels | What it shows | Used on | Drawn by |
|---|---|---|---|---|
| `art/cover.heic` | 720 × 900 | Urashima in his boat on layered waves with the red sun. | Library | `UrashimaArt` `cover` |
| `art/scene-shore.unfolded.heic` / `.folded.heic` | 2676 × 2160 / 1296 × 2160 | The beach at evening; Urashima letting the tortoise go. | Pages 1–3 | `scene-shore` (new composition) |
| `art/scene-sea.unfolded.heic` / `.folded.heic` | same | Pale haze, the boat, the tortoise in the waves, the red sun. Screen 05. | Pages 4–5 | `scene-sea` (a port of the design's `seaScene`) |
| `art/scene-deep.unfolded.heic` / `.folded.heic` | same | Riding the tortoise down through pale aqua water. | Pages 6–7 | `scene-deep` (new composition) |
| `art/scene-palace.unfolded.heic` / `.folded.heic` | same | Rin Gin's halls and garden; Princess Otohime; the four seasons at once. | Pages 8–12 | `scene-palace` (new composition) |
| `art/scene-return.unfolded.heic` / `.folded.heic` | same | The changed shore, years later; Urashima alone with the box. | Pages 13–16 | `scene-return` (new composition) |
| `art/face-urashima.png`, `art/face-tortoise.png`, `art/face-otohime.png` | 144 × 144 | Urashima; the tortoise; Princess Otohime. | Voice chips | `face-…` |
| `art/char-urashima.card.heic`, `art/char-tortoise.card.heic`, `art/char-otohime.card.heic` | 1296 × 1200 | The three characters. | Character cards | `char-…` |
| `art/see-fishing-boats.heic` | 1296 × 1212 | Small wooden fishing boats on a morning sea. Fades into `#1B4C93`. | Tap-to-see card | `see-fishing-boats` |
| `art/see-rin-gin.heic` | 1296 × 1212 | The Dragon Palace under the sea. Screen 06. Fades into `#06204A`. | Tap-to-see card | `see-rin-gin` (a port of the design's `palaceScene`) |
| `art/see-tamatebako.heic` | 1296 × 1212 | The black lacquer box with its red cord. Fades into `#2B1E4A`. | Tap-to-see card | `see-tamatebako` |

## `landmarks/`

Our own illustrations, never photographs. Lost wonders are drawn as our own reconstructions
and their card says so.

| File | Pixels | What it shows | Used by | Drawn by |
|---|---|---|---|---|
| `art/taj-mahal.heic` | 1296 × 1212 | The white domed mausoleum with four minarets, mirrored in the long pool, at dawn. | The Monkey and the Crocodile (framed, "then and now") | `LandmarkArt` `taj-mahal` |
| `art/lighthouse-of-alexandria.heic` | 1296 × 1212 | A reconstruction, drawn to look like an artist's idea: three-level tower on a small island. | No story yet (exercises the reconstruction rule) | `lighthouse-of-alexandria` |
| `art/asante-traditional-buildings.heic` | 1296 × 1212 | A low earth-walled house with a steep thatched roof and curling wall patterns. Generic patterns only; for the Akan reviewer. | How Wisdom Became the Property of the Human Race (natural) | `asante-traditional-buildings` |
| `art/tokyo-skytree.heic` | 1296 × 1212 | A slim pale lattice tower above a low city and a river, evening. Our own stylised drawing; `docs/CONTENT_PLAN.md` §6.6 notes that the operator licenses the name and image (legal review before release, PRD Q29). | The Story of Urashima Taro (framed, "then and now") | `tokyo-skytree` |

## What round 3 changed in the pictures (to check on the Mac)

One light, one face construction, one finish, three palettes (`docs/ART_DIRECTION.md`).

| Shared rule | Where it was applied |
|---|---|
| Warm horizon band (`ArtStyle.horizonGlow`) | Every scene with a horizon, the covers, the outdoor tap-to-see pictures and all four landmarks. In the Anansi scenes it replaces the old orange haze; in the Skytree picture it replaces a blurred haze ellipse |
| Finish pass (`ArtStyle.finish`: warm wash from the upper left, soft indigo vignette) | Every scene (unfolded and folded), picture, portrait, cover and landmark. Not on face chips. Weaker wash on the dark Anansi story, weaker vignette on the pale Urashima story |
| Contact shadows in the shared indigo (`ArtStyle.contactShadow`) | Under the Monkey (branch, rock, the Crocodile's back), standing Anansi and the villagers, Urashima, Otohime, the beached boat, the lacquer box, the pot, and the landmark buildings — replacing black or grey ellipses |
| One face construction (`ArtStyle.eye` / `cheek` / `smile`) | The Monkey and both crocodiles (large eye with a white: Low tier); Father Anansi, Kweku Tsin and the villagers (plain dark eye in scenes, a modest white eye on portraits and chips); Urashima and Otohime (plain dark eye), the tortoise (small white eye, as on screen 05). Catchlights are upper left everywhere |
| Two line weights, no black lines | Detail and contour strokes in all three stories are a darker tone of their fill at 1.6 or 2.4 units. Hairline detail in the landmarks, rigging, nets and leaf veins keep their own finer widths |
| Shared stipple (`ArtStyle.tooth`) | Large flat areas in all three stories and the landmarks |
| Portrait framing | Anansi, Kweku Tsin and Otohime use `ArtStyle.portraitBackdrop` in their card's own colours (Kweku Tsin's portrait is now on the card's gold, not dusk purple); the Monkey keeps the sunburst of screen 07; Urashima and the tortoise keep their sea backdrops |
| Friendlier, calmer faces | Anansi's stern brow and down-turned mouth became a raised brow and a small smile; crocodile teeth are small rounded bumps; Otohime's near-black lash strokes are gone |
| Proportions | Standing Anansi about 3.2 heads tall (head scale 0.56 → 0.78); Urashima about 3.5 (head × 1.18); Otohime about 4.4 (head × 1.3) |

Known shortfalls against the direction, from the three painters' own notes:

- **Light direction is not fully one light.** The Anansi climb scene keeps its moon on the
  right (locked screen 04), so the tree's rim light and the cloth highlights still come from
  the right; the Skytree's moon is upper right.
- **Proportions:** Urashima (3.5 heads) and Otohime (4.4) are not at 3; the villagers are
  nearer 3.7. Reaching 3 means redrawing bodies, not scaling heads.
- **Crocodile eyes** are now a white eye in a yellow rim instead of the yellow reptile eye of
  screen 03 — friendlier, but a visible change from the locked design; the peach cheek on
  green skin may look muddy.
- **Tap-to-see framing:** `see-river-bank` is still a small landscape, not one centred
  subject, and its bank reaches into the bottom quarter; `see-forest` has no single subject;
  the Lighthouse and Skytree sit off-centre.
- **Palette:** the Anansi canopy and forest picture stay teal (as on screen 04), off the
  purple-to-ember ramp; the Urashima "years later" sea is still grey-lavender.
- **Folded bands** are still crops of the unfolded scenes (except `scene-ride`); the "face
  inside the middle 60%" rule is unchecked.
- **Unverified arithmetic:** the re-framed portraits (leaf and hand alignment on Kweku Tsin,
  head positions on all five), the larger heads against shoulders, and the horizon band's
  edge in open sky under the text on the Urashima sea, shore and return scenes.

## Status

Every `review.art` field is `pending`. All card copy, lesson wording and fact-card wording in
the JSON is draft, unreviewed text. After round 3 **every** picture needs a look on the Mac
(nothing drawn this round has been rendered); first the faces and portraits, which changed
most, then every scene's horizon and finish, then the folded crops. New cultural-review
material from this round: the villagers' faces and hair and Father Anansi's new expression
(Akan reviewer), Urashima's and Otohime's faces (Japanese reader).
