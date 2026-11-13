# Art placeholders (M1)

**No image file listed here exists yet.** The story and landmark JSON name each picture by a
file path, an alt text and a pixel size; the files are delivered later by the art workstream
(milestone C1). Until a file exists, the app draws a simple shape-and-gradient placeholder in
SwiftUI, chosen by the *asset name* — the file name without folder or extension
(`art/scene-river.unfolded.heic` → `scene-river`). See `App/Sources/Art/PlaceholderArt.swift`.

When a real file is added at the path below, the app shows it and stops drawing the
placeholder; no code change is needed. Run `python3 tools/validate_content.py --check-art`
to list the files still missing.

Sizes follow `docs/ARCHITECTURE.md` §7.2 (@3x of the 432 × 720 pt reference pane).
HEIC for opaque art, PNG where transparency is needed.

## `stories/monkey-and-crocodile/`

| File | Pixels | What it shows | Used on | Placeholder drawn |
|---|---|---|---|---|
| `art/cover.heic` | 720 × 900 | The Monkey riding on the Crocodile's back across the river. No title baked in. | Library card, "Keep reading" card | The ride scene, cropped |
| `art/scene-river.unfolded.heic` | 2676 × 2160 | Morning. The great tree on the bank (trailing side), the Monkey on a branch, the little Crocodile in the water. Calm sky on the leading side for the text. | Pages 1–3, 8 | `scene-river` |
| `art/scene-river.folded.heic` | 1296 × 2160 | The same moment for one pane: picture in the top ~47%, calm pale area below. | Pages 1–3, 8 (folded) | Crop of `scene-river` |
| `art/scene-ride.unfolded.heic` | 2676 × 2160 | Mid-river. The Monkey on the Crocodile's back; the fruit island far ahead. | Pages 4–7 | `scene-ride` |
| `art/scene-ride.folded.heic` | 1296 × 2160 | The same, one pane. | Pages 4–7 (folded) | Crop of `scene-ride` |
| `art/scene-island.unfolded.heic` | 2676 × 2160 | The new tree, the stepping-stone rock halfway across, the island of fruit trees. | Pages 9–10 | `scene-island` |
| `art/scene-island.folded.heic` | 1296 × 2160 | The same, one pane. | Pages 9–10 (folded) | Crop of `scene-island` |
| `art/scene-dusk.unfolded.heic` | 2676 × 2160 | Dusk. The Crocodile lying flat on the rock; the Monkey at the water's edge. | Pages 11–14 | `scene-dusk` |
| `art/scene-dusk.folded.heic` | 1296 × 2160 | The same, one pane. | Pages 11–14 (folded) | Crop of `scene-dusk` |
| `art/face-monkey.png` | 144 × 144 | The Monkey's face (voice chip, avatar). | Inline in the text | Generic face in the voice colour |
| `art/face-crocodile.png` | 144 × 144 | The little Crocodile's face. | Inline in the text | Generic face in the voice colour |
| `art/face-mother-crocodile.png` | 144 × 144 | The Mother Crocodile's face. | Inline in the text | Generic face in the voice colour |
| `art/char-monkey.card.heic` | 1296 × 1200 | The Monkey waving from a branch (character card portrait). | Character card (M3) | Not drawn in M1 |
| `art/see-river-bank.heic` | 1296 × 1212 | A grassy bank beside a wide river. Bottom ~320 px fades into `#0A6585`. | Tap-to-see card (M3) | Not drawn in M1 |
| `art/see-ripe-fruit.heic` | 1296 × 1212 | A branch heavy with golden fruit. Fades into `#1F6B50`. | Tap-to-see card (M3) | Not drawn in M1 |

Rules for scenes: the strip under the hinge (84 px wide, in the middle of the unfolded image)
is not visible on hardware — keep faces and essentials out of it and out of the text area.
A framed landmark (the Taj Mahal here) never appears in scene art; it appears only on its card.

## `landmarks/`

| File | Pixels | What it shows | Placeholder drawn |
|---|---|---|---|
| `art/taj-mahal.heic` | 1296 × 1212 | Our own illustration (never a photograph): a white domed building with four slim towers, mirrored in a long pool. | Not drawn in M1 (landmark card is M3) |
| `art/lighthouse-of-alexandria.heic` | 1296 × 1212 | Our own reconstruction drawing of a lost wonder, labelled as such on its card. | Not drawn in M1 |

## Status

Every `review.art` field is `pending`. All card copy, lesson wording and fact-card wording in
the JSON is draft, unreviewed text.
