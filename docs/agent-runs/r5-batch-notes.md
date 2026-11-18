# Round 5 (the stories round) — batch notes

Written in batch 1 (18 Nov 2026) for the agents who run batches 2 and 3. Follow these
conventions exactly; they are what makes 32 stories one app.

Round 5 adds the 29 remaining stories of `docs/CONTENT_PLAN.md` in three batches:

| Batch | Stories | State |
|---|---|---|
| 1 | The ten new **Low** stories (L2–L11), the shared illustration kit, the build tool, the library for a big catalog, ten landmarks | written, **uncompiled, unseen** |
| 2 | The ten new **Medium** stories (M1–M9, M11) | to do |
| 3 | The nine new **Advanced** stories (A1, A2, A4–A10) | to do |

## 0. Standing decisions for the round (from Srikanth; do not reopen)

1. Tagline: **"Turn the page. See the world."** (`Brand.tagline`; splash halves "Turn the page." / "See the world.").
2. Morals: the idea of the plan's draft moral, polished into **one clear, kid-friendly sentence**:
   short concrete words, no semicolon, no dash, no "but … and …" chain, at most 14 words for
   Low and 18 for Medium / Advanced, ending with a full stop. Tests enforce the limits
   (`Round5Tests`, `tools/test_build_stories.py`).
3. The finished screen, the icon and the splash stay as designed in round 4.

## 1. Per-story file layout

For a story with id `<id>` (the plan's id, exactly):

| What | Where | Made by |
|---|---|---|
| Authoring spec (text, cards, header, new landmark entries, art brief) | `docs/content/story-specs/<id>.json` | a writer |
| Shipped story | `Packages/OmramoCore/Sources/OmramoCore/Resources/Content/stories/<id>/story.json` | `tools/build_stories.py` — **never edit by hand** |
| Manuscript for the text-fidelity check, with the source notes as its header | `…/Content/sources/<id>.txt` | `tools/build_stories.py` |
| New landmark catalog entries | merged into `…/Content/landmarks/landmarks.json` | `tools/build_stories.py` (from the spec's `landmarks`) |
| Catalog order | `…/Content/catalog.json` — **plan order** (L1…L11, M1…M11, A1…A10) | by hand |
| Story painter | `App/Sources/Art/Stories/<Enum>.swift`, `<Enum>+Folded.swift`, `<Enum>+Cast.swift`, `<Enum>+Pictures.swift` | a painter |
| Landmark picture | `App/Sources/Art/Landmarks/LandmarkArt+<Name>.swift` (`extension LandmarkArt`, `static func paint<Name>(_ context: inout GraphicsContext)`) | a landmark painter |
| Registry lines | `ArtLibrary.storyPainter(for:)` in `App/Sources/Art/StoryArt.swift`; the `switch` in `LandmarkArt.paint` (`App/Sources/Art/LandmarkArt.swift`) | the lead |
| Test data | `ContentPlan.landmarks` (story → landmark ids) and, per batch, a `batchTwo` / `batchThree` list in `Packages/OmramoCore/Tests/OmramoCoreTests/Round5Tests.swift`; `PLAN_ORDER`-driven checks in `tools/test_build_stories.py`; `ShotTests.newStories` | the lead |
| Docs | `docs/CONTENT_PLAN.md` §2a status row; `…/Content/ART_PLACEHOLDERS.md` section; `docs/BUILD.md` §6; `docs/AGENT_HANDOFF.md` §9 | the lead |

The three prototypes (`monkey-and-crocodile`, `anansi-wisdom`, `urashima-taro`) have **no
spec**: their `story.json` files are still edited by hand, and their painters
(`JatakaArt`, `AnansiArt`, `UrashimaArt`) stay where they are in `App/Sources/Art/`.

Batch-1 painter enums: `SailorArt`, `SparrowArt`, `MountainsArt`, `PossumArt`, `SnowHouseArt`,
`PeasantBearArt`, `BremenArt`, `WindSunArt`, `SunMoonArt`, `LionHareArt`.

## 2. The spec and the build tool

```
python3 tools/build_stories.py            # build every spec
python3 tools/build_stories.py --check    # exit 1 if a generated file is out of date
python3 tools/validate_content.py         # must print 0 error(s)
python3 tools/test_validate_content.py    # 62 tests
python3 tools/test_build_stories.py       # mark-up, catalog, morals, flags, levelling
```

A spec holds the header fields of `story.json` as they are (`id`, `title`, `subtitle?`, `tier`,
`region`, `setting`, `provenance`, `culturalReview`, `education`, `moral`, `theme`, `parts`)
plus short forms:

- `cover`: `{ "alt" }` → `art/cover.heic`, 720 × 900.
- `characters[]`: `id`, `name`, `color`, `chipBackground`, `faceAlt` (→ `art/face-<id>.png`),
  optional `card` { `label`, `title`, `traits` ×3, `body`, `portraitAlt` (→
  `art/char-<id>.card.heic`), `background` ×3 }.
- `tapTargets[]`: ordinary — `id`, `kind`, `title`, `line`, `cultureNote`, `pictureAlt` (→
  `art/see-<id>.heic`), `background`; landmark — `id` (`<x>-moment`), `kind: "landmark"`,
  `landmark` { `id`, `appearance`, `framingDevice?` }, `background`.
- `scenes`: `{ "scene-<name>": { "unfoldedAlt", "foldedAlt", "fallbackColors": [3], "textArea"?, "chrome"? } }`
  → `art/scene-<name>.unfolded.heic` / `.folded.heic`.
- `pages[]`: `{ "scene", "part", "paras": [marked-up paragraphs] }` → spreads `s01…`, blocks
  `s01-b1…`, all on the **leading** pane (the tool does not yet write trailing-pane blocks or
  `pathText`: **batch 3 must extend it** for Advanced stories, which put text on both panes
  like Urashima — add a per-paragraph pane marker and keep the generated JSON identical in
  shape to `urashima-taro/story.json`).
- `landmarks[]`: full catalog entries for landmarks this story introduces.
- `sourceNotes[]`: lines for the manuscript header (what the text is, the source, what was
  softened or left out, what a reviewer must check, the status line).
- `artBrief`: the writer's research for the painter (palette, light, world facts, per-picture
  notes, cultural cautions). Not shipped.

Paragraph mark-up: `^` lead paragraph · `<say:ID>…</say>` speech (`<say:ID*>` shows the face
chip) · `<name:ID>…</name>` a name that opens the character card · `<tap:ID>…</tap>` a
tap-to-see word · `<pop:1.3>…</pop>` · `<stretch>…</stretch>`. Tags nest. Prose uses
typographic quotes only; a straight `"` or `'` in a paragraph is an error.

Asset names are derived, and the painters and tests rely on them: `cover`, `scene-<name>`,
`see-<tap id>`, `char-<character id>`, `face-<character id>`, and a landmark's art is
`<landmark id>`.

## 3. Writing rules that worked (Low; adjust numbers for the tier)

| | Low (batch 1) | Medium (like `anansi-wisdom`) | Advanced (like `urashima-taro`) |
|---|---|---|---|
| Pages | 12–14, two parts | about 8–10 | about 14–16, text on both panes |
| Words a page | 35–60, never over 75 (validator warns above 82) | about 90 (warns above 135) | about 190 (warns above 285) |
| Scenes | exactly 4 | 3–4 | 4–5 |
| Ordinary tap targets | exactly 3 (one `place`) | 3–4 (a place + "how people live there") | 4–5 (routes, ideas, what is uncertain) |
| Character cards | hero + one other | 2 | 2–3 |
| Landmarks | exactly as CONTENT_PLAN §6 | same | same |

- The writer gets the lead's **editorial plan** for the story in the prompt: the shape of the
  telling beat by beat, every softening the plan asks for, the four scene names, the
  characters and ids, the tap targets, the landmark and the word it is tapped on, the header
  values (region label ≤ about 22 characters, pin, `latestYear`), the review block and a
  suggested moral. Writers improve the telling, not the structure. Scene names fixed before
  writing mean the art can start from the spec without waiting for text edits.
- One tap word a page at most; each tap target marked exactly once; a name tagged at first
  mention; a lead line on page 1 and on the first page of Part II.
- Every scene of a Low story keeps a **pale sky behind the words** so one dark ink
  (`theme.textColor`) works on every page: "night" scenes are pale dusk.
- A character `name` is what the friends row shows; `FriendMet.shortName` must give something
  sensible of at most 16 characters ("the Sun" → "Sun"; use "Wife", not "Yu Gong's wife").
- **Sources.** gutenberg.org answered 503 from the box all day; the mirror worked:
  `https://gutenberg.pglaf.org/<d1>/<d2>/…/<id>/<id>.txt` (digits of the id except the last;
  try `<id>-0.txt` too). After the drafts, one "source check" agent compared every retelling
  with its source and its findings went into the specs' `sourceNotes` and into fixes (a phrase
  that echoed a translator, a wrong attribution, a variant that differs from the cited book).
  Do this for every batch.
- Cultural review: the twelve §7 stories carry `culturalReview { level: required, status:
  pending, reason, community, notes: "Needs cultural review before release." }`; every other
  story `level: standard` with a `community` naming the reader. `CulturalReview.needsReviewBeforeRelease`
  is the flag in code; the release-mode validators refuse a flagged story. Rule
  `cultural-review-no-community` (both validators) makes the reviewer's name mandatory.

## 4. The illustration kit (`App/Sources/Art/Kit/`, `enum Kit`)

Ten files, about 8,200 lines, written once in batch 1. A story painter composes from it and
draws its own heroes and region-true details. `docs/ART_DIRECTION.md` §11 is the summary;
the doc comments in the files are the reference.

| File | What it gives |
|---|---|
| `Kit.swift` | Small tools (`rnd`, `deg`, `pt`, `clamp`, `mix`, `placed`, `stops`); the frames — `Stage` + `stage(_:ground:)`, `designSpace`, `nearSpace` (unfolded scenes: designed, tall, squat), `Band` + `band(_:share:least:most:)`, `hung` (folded), `CoverFrame` + `cover`, `faceChip`, `portrait`, `sink` (tap pictures); `Light`, `sky`, `sun`, `moon`, `stars`, `cloud`, `birds`; `ridge`, `peaks`, `ranges`, `mountain`, `ground`, `mound`; `water`, `glints`, `rippleMarks`, `ripples`, `swells`; `solid` / `model` (any shape, lit by the one light), `shadow`, `limb` |
| `Kit+People.swift` | `Person` (age, skin, hair + style, beard, headwear, garment, cloth, trim, legs), `Mouth`, `personHead` |
| `Kit+PeopleBody.swift` | `Pose`, `person` (3 heads tall, nine garments × nine poses), `bust`, `hand`, `seatHeight` |
| `Kit+Beasts.swift` | `Beast` (ears, tail, muzzle, proportions, mane, stripes), `BeastPose`, `BeastMood`, `beast` (side view), `beastHead`, anchors |
| `Kit+BeastFaces.swift` | `beastFace`, `beastBust` (front views) and the looks: `bearLook`, `lionLook`, `hareLook`, `rabbitLook`, `possumLook`, `donkeyLook`, `dogLook`, `catLook`, `foxLook`, `horseLook`, `tigerLook`, `gazelleLook` |
| `Kit+Birds.swift` | `Bird`, `BirdPose`, `bird`, `birdFace`, `birdBust`, `sparrowLook`, `roosterLook`, `heronLook`, `crowLook`; `critterFish`, `critterCrab`, `critterFrog`, `critterButterfly`, `critterBee`, `critterLizard` |
| `Kit+Trees.swift` | `Greens` palettes, `canopy`, `tree`, `conifer`, `birch`, `palm`, `bamboo`, `cloudPine`, `acacia`, `cypress`, `olive`, `greatTree`, `mangrove`, `bareTree`, `farTree(s)`, `bush` |
| `Kit+Ground.swift` | `grass`, `grassTuft`, `reeds` (papyrus), `flowers`, `crop`, `grainField`, `furrows`, `rock`, `pebbles`, `drift` (snow / sand), `snowBlock`, `cornerLeaves`, `flecks`, `lilyPad`, `ribbon` (road / stream) |
| `Kit+Buildings.swift` | `RoofStyle`, `house`, `wall`, `roof`, `opening`, `tower`, `dome`, `column`, `fence`, `gateway`, `longWall`, `farHouse`, `windmill`, `bridge` |
| `Kit+Props.swift` | `BoatStyle` + `boat`, `basket`, `pot`, `sack`, `bowl`, `campfire`, `lamp`, `cart`, `well`, `signpost`, `carryingPole`, `Tool` + `tool`, `sheaf`, `heap`, `table`, `treasure` |

Rules for adding to the kit (batches 2–3 will need more: a camel, a ship of the Nights, a
gusli, armour, a firebird…): put region-neutral, reusable things in the kit under the file's
prefix (`person…`, `body…`, `beast…`, `face…`, `bird…`, `critter…`, `tree…`, `ground…`,
`built…`, `prop…`), story-specific heroes in the story's `+Cast.swift`. Never change an
existing public signature: thirteen painters call them.

### Painter conventions

- One `enum <Name>Art` with `static func paint(_ name: String, role: ArtRole, in context: inout GraphicsContext, size: CGSize) -> Bool`:
  a `switch (name, role)` over every asset of the story; `default: return false` (the app then
  draws the calm stand-in — an unknown name never crashes).
- **Unfolded scene** (892 × 410…1300): `Kit.stage(size, ground:)`; far plane in picture units
  with `st.H`, scaled by `st.far`; middle and near planes inside `Kit.designSpace` /
  `Kit.nearSpace`, placed relative to `st.Hv`; extra ground fill when `st.tall > 0.25`; the
  leading pane (x 0…432) calm and pale above the horizon band; the subject on the trailing
  pane (x 480…880), clear of the chrome corners; `ArtStyle.finish` last.
- **Folded scene** (432 × 240…520): its own composition with `Kit.band`; the subject's face in
  x 86…346, below the top controls, above `band.floor`.
- **Tap picture** (432 × 404): one centred subject; `Kit.sink(… card:)` last.
- **Portrait** (432 × 400): `Kit.portrait(… rays:)` — rays for Low only. **Face chip**
  (100 × 100): `Kit.faceChip`. **Cover** (300 × 150…375): `Kit.cover { g, frame in … }` in
  240-wide units around `frame.H`, scaled by `frame.k`.
- A character is built once in `+Cast.swift` (a `…Look()` function returning the kit spec, or
  a bespoke drawing) and reused in every picture. `Kit.person` / `Kit.beast` draw no ground
  shadow: add `Kit.shadow`.
- Lights are functions (`static func day() -> Kit.Light`): `Kit.Light` is not `Sendable`.
- **Tier look.** Low: `showsEyeWhite: true`, rays on portraits, saturated daylight. Medium and
  Advanced: `showsEyeWhite: false` (the smaller plain eye), no rays, quieter saturation, and
  Advanced must not look babyish (ART_DIRECTION §4) — fewer comic poses, more atmosphere.
  Medium and Advanced stories may be dark (light text) like Anansi: then every scene of the
  story is dark and `theme.chrome` is `dark`.

## 5. How the batch was run (what to repeat, what to avoid)

Sub-agents in this environment have **no shell**; only the lead runs scripts. The order that
worked:

1. Lead: kit core and contracts first; the build tool; the brief files (see below).
2. **Writers** (one a story, in parallel): spec JSON only. Lead builds, validates, reads every
   story, applies editorial fixes. Then one **source-check** agent.
3. **Landmark painters** (two landmarks an agent) — they need only `LandmarkArt.swift` and
   `Kit.swift`, so they can run while the kit is finished.
4. **Painters** (one a story, in parallel), against the finished kit and the spec's `artBrief`.
5. **"Be the compiler" reviewers**: one per two or three kit files, one per five landmark
   files, one per story painter, one for core + app + tests (who also evaluates every new test
   assertion against the content).
6. Lead: the mechanical checks, the docs, the registry and test data.

Hard-won notes:

- **Tell every writing agent to write early and in parts** (a first Write within a dozen tool
  calls, then Edit-appends of at most about 250 lines). Three agents asked for one 700–1,000
  line file each sat for 90 minutes and produced nothing; the same work split into nine files
  with "write early, append in parts" finished in 4–11 minutes each.
- Keep the briefs and the check scripts **inside the workspace** (this batch:
  `/workspace/srikanth/duo/Omramo/r5-scratch/`, outside the repo): `/tmp` did not survive a
  reboot mid-batch and was not listable afterwards.
- The mechanical checks (recreate them; about 300 lines of Python): bracket balance over every
  Swift file with strings and comments stripped; duplicate `static func` signatures, nested
  types and `static let`s within one type across its files; stored `static var`s in art
  files; and an argument-label check of every call into `Art`, `ArtStyle`, `Kit`,
  `LandmarkArt`, the story enums and of unqualified calls to a type's own static functions
  (about 11,000 calls before the story painters). It cannot see types, enum cases or struct
  properties — that is what the reviewers are for.
- Existing tests that pinned "three stories" were updated as intended changes (listed in
  `docs/BUILD.md` §6, round 5). When a batch adds stories of a level, look for tests that
  assume one Medium or one Advanced story (`books.medium`, `stories.first { $0.tier == … }`
  are fine; exact lists are not).

## 6. What batch 2 must do first

1. Compile batch 1 on the Mac if it has not been (BUILD §7d) — the kit has never been
   compiled or rendered; fix it before thirteen more painters lean on it.
2. Add to `catalog.json` in plan order: M1–M9 before `anansi-wisdom`, M11 after it.
3. Extend `ContentPlan.landmarks`, `ShotTests.newStories`, `CONTENT_PLAN` §2a,
   `ART_PLACEHOLDERS.md`, the registry.
4. New landmarks for Medium: `great-pyramid-giza`, `chichen-itza`, `mount-fuji` (natural: no
   `built`), `golden-gate-bridge`, `novgorod-kremlin`, `christ-the-redeemer`, `colosseum`,
   `temple-of-artemis-ephesus`, `parthenon`, `statue-of-zeus-olympia`,
   `hanging-gardens-babylon` (status `unproven`), `burj-khalifa`.
