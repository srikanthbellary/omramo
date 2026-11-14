# Omramo — art direction (round 3)

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

## 4. Characters

- **Proportions.** People stand about **3 heads tall**; animals are built around a head that
  is about a third of their length. The same character keeps the same proportions in a scene,
  a portrait, a cover and a face chip.
- **One face construction** (`ArtStyle.eye`, `ArtStyle.cheek`, `ArtStyle.smile`):
  - Eyes: a round eye with a dark iris and **one catchlight on the upper left**. The Low
    story's eyes are large with a white (the Monkey of screen 07); Medium and Advanced use
    the **same construction smaller** (`showsWhite: false` gives the plain dark eye with a
    catchlight) so older readers do not see a toddler's cartoon.
  - Cheeks: a soft warm blush, the same helper everywhere, quieter on the older tiers.
  - Mouth: a single round-capped curve in a darker tone of the skin or fur.
  - No angry brows, no teeth shown in threat. The crocodiles' teeth are small, rounded and
    comic; nothing bares fangs at the reader.
- Skin, hair and dress follow the culture notes in `ART_PLACEHOLDERS.md` and go to the
  cultural reviewers with the text (PRD Q24).

## 5. Sky and horizon

- The **horizon is a straight, calm line** in the lower third of a scene's reference height
  (it is anchored to the bottom edge, so on a tall iPad window the sky above it stretches).
- The sky is a vertical gradient of at most four stops that ends in the ramp's `glow` at the
  horizon. Sun and moon are plain discs with one soft halo; no lens flare, no rays across the
  text area (the portrait sunburst of screen 07 is the one place rays are used).
- The text area of a scene stays calm: no shape with more than a faint contrast under the
  words, and 4.5:1 between the text colour and whatever is behind it.

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

## 9. What is still open

- All of this is direction for **concept art written without a renderer on the authoring
  box**. Every picture still needs eyes on a Mac, then a real illustrator (milestone C1).
- Cultural review of every Akan and Japanese drawing (PRD Q24), and the Jataka pictures with
  the Buddhist reader.
- Whether Advanced should go further toward a print-like, limited-colour look is a question
  for Srikanth and the future illustrator, not decided here.
