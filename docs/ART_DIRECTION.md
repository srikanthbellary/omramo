# Omramo — art direction (round 3, deepened in round 4)

Status: **direction for the concept art drawn in code** (`App/Sources/Art/`). It is our own
direction for our own drawings; it is not a brief that has been signed off by an illustrator,
and every `review.art` field stays `pending`. The locked screens (`docs/design/03`–`07`, `10`)
stay the reference for the three ported scenes; this page says what the three stories share so
they read as **one app**, and what each keeps as its own.

Audience check for every picture: a six-year-old must find it friendly; a thirteen-year-old
must not find it babyish. Warm, calm, never scary, never edgy. No skeuomorphic paper, no book
edges, no photographs, no third-party art.

Shared constants and helpers live in `App/Sources/Art/ArtStyle.swift`. A painter uses them
instead of inventing its own values.

**Round 4** took the same direction further, toward illustration rather than "shapes drawn by
an engineer": §3a (form and depth), §5a (a picture is composed for the shape it is shown in)
and §10 (the app icon and the splash) are new; the known misses of round 3 were worked on one
by one (`ART_PLACEHOLDERS.md` says what changed and what still falls short). Like round 3,
**none of it has been rendered on the authoring box.**

## 1. One light

Every picture in the app is lit by the **same low, warm light** — a sun (or a lamp, or a
moon warmed by the horizon) that sits low and to the **upper left of the subject**.

| Rule | Value |
|---|---|
| Key light colour | `ArtStyle.warmLight` `#FFD9A0` (never pure white) |
| Shadow tint | `ArtStyle.coolShade` `#2A2466` — the brand's indigo, at low alpha. Never black, never grey |
| Light side | Upper left. Highlights, rim light and eye catchlights sit on the upper left of a form; core shadows and contact shadows fall to the lower right |
| Horizon | Every outdoor scene has a **warm band at the horizon** (`ArtStyle.horizonGlow`), whatever the hour: pale gold in the river morning, ember orange at the Akan dusk, peach behind the Japanese sea |
| Contact shadow | One soft ellipse under anything that stands on something (`ArtStyle.contactShadow`), in the shadow tint |
| Finish | `ArtStyle.finish` last on every scene, picture, portrait and cover: a faint warm wash from the upper left and a soft indigo vignette. The grain overlay is added by the views (`GrainOverlay`), the same on every picture |

## 2. Palette ramps

Each story owns **one five-step ramp** (deep → shade → mid → light → glow) and **one accent**.
The `glow` step of every ramp is a warm colour: that is what ties the three together. Colours
outside the ramp are allowed for small cultural details (kente blocks, lacquer, fruit), not for
large areas.

| Story | Deep | Shade | Mid | Light | Glow (warm) | Accent | Mood |
|---|---|---|---|---|---|---|---|
| The Monkey and the Crocodile (Low, India) | `#0E5A6B` | `#1F8F7A` | `#2FB58A` | `#BFEFE4` | `#FFF3B8` | `#FF9F2E` | Bright river morning; the friendliest and most saturated |
| How Wisdom Became… / Anansi (Medium, Akan) | `#1A1147` | `#35206B` | `#6A2F7A` | `#E2694F` | `#FFC96B` | `#2E9E5B` | Dusk and lamplight; rich, never gloomy — every dark area holds a warm light source |
| Urashima Taro (Advanced, Japan) | `#1F4E96` | `#3F7FC4` | `#9CC9E6` | `#EEF4FB` | `#FFE3D2` | `#F4503F` | Pale washes, patterned sea; quiet and grown-up, still warm (peach sky, red sun) |

In code: `ArtStyle.jataka`, `ArtStyle.anansi`, `ArtStyle.urashima` (`ArtStyle.Ramp`).
Landmark pictures take the ramp of nobody: they use their own subject's colours over the same
light, horizon glow and finish.

Saturation falls with the tier (Low brightest, Advanced quietest); value contrast does not.

## 3. Line and shape

- **No black outlines.** Forms are flat shapes with soft gradients. Where a line is needed
  (a mouth, a fold, a branch, a wave crest) it is a **darker tone of the fill**, with round
  caps and joins.
- Two line weights only, in units of the 432-wide pane: `ArtStyle.detailLine` **1.6** for
  inner detail, `ArtStyle.contourLine` **2.4** for the few contours that carry a shape
  (limbs drawn as strokes are not lines and keep their own widths).
- Shape language: **rounded and leaf-like**. Corners are rounded; silhouettes are simple
  enough to read at face-chip size. Repeated ornament (leaves, seigaiha waves, kente blocks,
  thatch lines) is regular and calm, never noisy.
- Depth by **three planes**: far (hazy, close in value to the sky), middle (the story's
  subject), near (dark framing leaves or waves at the edges, never over the text area).

## 3a. Form and depth (round 4)

A flat shape with a gradient is a diagram; a shape that takes the light is an illustration.
Every main form — a trunk, a roof, a hull, a body, a head, a pot, a dome — now gets, from the
one light:

- a **warm rim** on its upper-left side and an **indigo core shadow** toward its lower right
  (`ArtStyle.form`, straight after the fill; `ArtStyle.rimEdge` for the thin lit contour of a
  large shape; `ArtStyle.rimLight` for round forms);
- a **contact shadow** where it stands (`ArtStyle.contactShadow`), offset a little to the
  lower right.

Depth is **atmospheric**, in three planes, painted back to front:

1. the **far plane**, then a veil of the sky's own colour over it (`ArtStyle.atmosphere`), so
   distance reads paler and closer to the sky's value — hills, a far shore, far trunks, a
   skyline;
2. the **middle plane** — the subject — at full colour and full light;
3. the **near plane** — darker, larger, cropped by the frame (leaves, weed, rocks, a bank) —
   at the edges only, never over the text area and never over a control.

Silhouettes are **built, not stamped**: a crown is several overlapping clumps with a broken
edge, a trunk tapers and flares, cloth has a hem, a roof bows. A lone perfect circle, ellipse
or rectangle is a sign the picture is not finished.

## 4. Characters

- **Proportions.** People stand about **3 heads tall**; animals are built around a head that
  is about a third of their length. The same character keeps the same proportions in a scene,
  a portrait, a cover and a face chip. (Round 4: Urashima and Otohime were redrawn to 3.0
  heads — shorter bodies, not bigger heads — and the Akan villagers to 3.0; the climbing
  Anansi's body is still round 3's.)
- **One face construction** (`ArtStyle.eye`, `ArtStyle.cheek`, `ArtStyle.smile`):
  - Eyes: a round eye with a dark iris and **one catchlight on the upper left**. The Low
    story's eyes are large with a white (the Monkey of screen 07); Medium and Advanced use
    the **same construction smaller** (`showsWhite: false` gives the plain dark eye with a
    catchlight) so older readers do not see a toddler's cartoon.
  - Cheeks: a soft warm blush, the same helper everywhere, quieter on the older tiers.
  - Mouth: a single round-capped curve in a darker tone of the skin or fur.
  - No angry brows, no teeth shown in threat. The crocodiles' teeth are small, rounded and
    comic; nothing bares fangs at the reader.
  - **The crocodiles keep the eye of locked screen 03** (round 4): a yellow ball in a ring of
    the skin's line colour, a dark upright pupil and the one catchlight on the upper left.
    They are the one exception to the white-eye rule for the Low tier, and they carry no
    blush.
- Skin, hair and dress follow the culture notes in `ART_PLACEHOLDERS.md` and go to the
  cultural reviewers with the text (PRD Q24).

## 5. Sky and horizon

- The **horizon is a straight, calm line** in the lower third of a scene's reference height
  (on the designed shapes it is anchored to the bottom edge; on a tall window the scene is
  recomposed and the horizon rises with the height — §5a).
- The sky is a vertical gradient of at most four stops that ends in the ramp's `glow` at the
  horizon. Sun and moon are plain discs with one soft halo; no lens flare, no rays across the
  text area (the portrait sunburst of screen 07 is the one place rays are used).
- The text area of a scene stays calm: no shape with more than a faint contrast under the
  words, and 4.5:1 between the text colour and whatever is behind it.

## 5a. A picture is composed for the shape it is shown in (round 4)

A scene is never stretched and never cropped from another shape. Each painter derives a small
set of numbers from the size it is given (a `Stage`) and places everything from them.

| Shape | Units | What the composition does |
|---|---|---|
| The Duo, an iPad in landscape | 892 × 620–780 | The designed composition (720 is the locked one) |
| **An iPad in portrait** | 892 × 950–1300 | **Recomposed:** the horizon rises to about 64–70% of the height, the subject, the middle plane and the near plane grow with the height (by about 1.3–1.6 ×), trees and waves get taller, and a near band fills the foot of the picture. Not a tall sky over a small picture |
| **An iPhone held sideways** (the simulated unfolded Duo, round 4) | 892 × about 410–500 | The same composition, squat: the trailing ensemble shrinks about its anchor so canopy, subject and ground keep their distances |
| **One pane (a phone, the folded Duo)** | 432 × 240–520 | **Its own composition** for the band at the top of the screen — not a crop of the wide scene: the subject's face in the middle 60% of the width, below the top controls, above the wave cut, with its own far, middle and near planes |

The reader keeps the words out of the picture's part of the pane to match
(`ReaderMetrics.pictureReserve`): on a tall pane no text runs into the lower 37% of the
height, and a scene that names its text area (`scene.textArea`) keeps that share at any shape.

## 6. Texture

- The same film grain on every picture (added by the views), plus `ArtStyle.tooth` — the
  shared stipple — on large flat areas (water, sand, sky near the horizon, big leaves).
- No photographic texture, no paper texture, no drop shadows on characters other than the
  contact shadow.

## 7. Framing

| Picture | Framing |
|---|---|
| Scene (unfolded) | Subject on the trailing pane or low across both; nothing essential under the hinge strip (x 432–460 of 892); the text pane's upper two thirds stay calm |
| Scene (folded band) | The subject's face inside the middle 60% of the width, clear of the top controls (top 110 units) and of the wave edge (bottom 24 units) |
| Tap-to-see picture (432 × 404) | **One subject, centred slightly above the middle, filling about 60% of the width**, on a simple ground in the story's ramp. The bottom quarter is quiet because the card fades it into its own colour. Same horizon glow and finish as the scenes |
| Character portrait (432 × 400) | **Head and shoulders to the waist, centred, head top about 60 units from the top** (clear of the close button, top left), eyes on the upper third line, looking at the reader or slightly toward the text. Behind: `ArtStyle.portraitBackdrop` — a soft halo in the card's own colours (rays only for the Low tier) |
| Face chip (100 × 100) | The face fills 80% of the circle, eyes on the centre line, readable at 18 pt |
| Cover | Subject around the middle of a 300-wide picture that may be 150 to 375 units tall; no title baked in |

## 8. Motion and cost

Pictures are still. Nothing in a picture animates on its own. Each picture is rasterised once
(`.drawingGroup()` on the art views) so page turns, card reveals and the library-to-story
transition move a cached image instead of redrawing a `Canvas` every frame. A painter must be
deterministic (seeded `ArtRandom` only) so the cached image is stable.

## 10. The app icon and the splash (round 4)

**The icon** (`docs/brand/app-icon.svg`, rendered by `tools/make_app_icon.py`; preview
`docs/brand/app-icon-preview.png`): the "O" of OMRAMO as the two panes of the reader, either
side of the fold, and inside it one small place — the low warm sun of every Omramo picture
rising over calm water, running unbroken under the fold ("the page is a place"). On the
brand's midnight indigo with the aurora's violet, rose and teal. A thin seam of warm light in
the fold, above and below the O. Few shapes, so it reads at 29 pt; warm; no face, no mascot,
no book — so it is not babyish and not a hardcover. One 1024 × 1024 PNG, no alpha.

**The splash** (`SplashView`; `docs/DESIGN.md` §5.20): the dark aurora, the wordmark with the
`wordmark.ra` gradient on "RA", the warm glow and seam at the fold, the tagline, ten still
motes. The warm light is at the fold on two panes and behind "RA" on one.

Both are ours; both wait for Srikanth's eye. The icon is a first design, not a decision.

## 11. The illustration kit (round 5)

The catalog grows from three stories to thirty-two. Three bespoke sets of helpers do not scale
to that, and thirty-two sets would not look like one app. So round 5 adds a shared kit,
`enum Kit` in `App/Sources/Art/Kit/` (ten files), on top of `Art` and `ArtStyle`:

- **Frames** — one per picture shape of §5a, so every painter recomposes for a tall window, a
  squat one, the phone's band and both cover crops in the same way: `Kit.stage` /
  `designSpace` / `nearSpace`, `Kit.band` / `hung`, `Kit.cover`, `Kit.portrait`,
  `Kit.faceChip`, `Kit.sink`.
- **Light, sky, land, water** — `Kit.Light` (a story keeps one or two), `sky`, `sun`, `moon`,
  `cloud`, `ranges`, `peaks`, `mountain`, `ground`, `mound`, `water`, `swells`, `ripples`.
- **`Kit.solid`** — any shape filled and modelled by the one light (§3a) in one call.
- **People** — `Kit.Person`: one face construction (§4) for everyone, about three heads tall;
  only skin, hair, headwear and dress change (nine garments: tunic, robe, kimono, kilt, parka,
  wrapper, shirt and trousers, dress, chiton). No caricature: a culture is shown by its true
  dress, tools and setting, never by exaggerated features.
- **Animals** — `Kit.Beast` (a four-legged animal by proportions, ears, tail, muzzle) with
  ready-made looks so every story draws the same bear; `Kit.Bird`; a few small creatures.
- **Plants, ground, buildings, props** — trees of ten regions, crops, snow and sand,
  region-neutral building blocks (walls, eight roof styles, towers, domes, columns), boats of
  five kinds, baskets, pots, carts, wells, tools.

What keeps a kit from making thirty-two recoloured templates:

1. **A story owns its palette and its light** (a five-step ramp with a warm glow, an accent,
   one or two `Kit.Light`s), taken from the author's research in the story's spec.
2. **The hero is the painter's own.** The kit gives the supporting cast and the world; the
   thing a child will remember — the golden serpent, the snow house's spiral, the tower of four
   animals, the North Wind's face, the Water as a person — is drawn for that story alone, in
   the story's `+Cast.swift`.
3. **Region-true composition.** A Japanese farmhouse is `Kit.house` with thatch *and* the
   porch, the bamboo and the hills the painter adds; the kit never decides what a place is.
4. **Tier look.** Low: large eyes with whites, rays behind portraits, bright daylight, comic
   poses. Medium and Advanced: the smaller plain eye, no rays, quieter colour, more air.

Every Low story of round 5 keeps a **pale sky behind the words** in all four scenes, so one
dark ink serves every page; its evenings are pale peach or lilac, never night.

Like everything before it, **the kit and every round-5 picture were written without a
compiler or a renderer.** The kit has the most leverage and so the most risk: a wrong
proportion in `Kit.person` is wrong in twenty stories. It must be looked at on the Mac before
batches 2 and 3 build on it (`docs/agent-runs/r5-batch-notes.md` §6).

## 9. What is still open

- All of this is direction for **concept art written without a renderer on the authoring
  box**. Every picture still needs eyes on a Mac, then a real illustrator (milestone C1).
- Cultural review of every Akan and Japanese drawing (PRD Q24), and the Jataka pictures with
  the Buddhist reader.
- Whether Advanced should go further toward a print-like, limited-colour look is a question
  for Srikanth and the future illustrator, not decided here.
