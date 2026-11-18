# Art status: concept art drawn in code (round 5, batch 1: ten more stories and ten landmarks, from a shared kit)

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
  toolchain and no renderer. The round-3 look was then seen on the Mac (simulator shots
  `r3-*.png`).
- **Round 4** went over every painter again (deeper form and depth, the known misses of
  round 3, a composition of its own for every folded scene, a recomposition for tall and for
  squat windows — `docs/ART_DIRECTION.md` §3a and §5a). It was written by four painters who
  could neither compile nor render (the authoring box has no Swift toolchain and their
  sessions had no shell at all): **every number in a round-4 picture is arithmetic, not
  something anyone has looked at.** "What round 4 changed" and "Known shortfalls after
  round 4" below are the list to check on the Mac.
- **Round 5, batch 1** added the pictures of ten new Low stories and ten landmarks. They
  are composed from a shared illustration kit (`App/Sources/Art/Kit/`, `enum Kit`;
  `docs/ART_DIRECTION.md` §11), with each story's heroes and region-true details drawn in its
  own painter (`App/Sources/Art/Stories/<Name>Art*.swift`); the landmark pictures are in
  `App/Sources/Art/Landmarks/`. The registry is `ArtLibrary.storyPainter(for:)` in
  `StoryArt.swift` and the `switch` in `LandmarkArt.paint`. The kit, the ten painters and the
  ten landmark pictures were written by agents with **no compiler, no renderer and no shell**:
  like round 4, every number is arithmetic nobody has looked at. See "Round 5, batch 1" below.
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
| Scene, unfolded | 892 units wide, any height from about 400 to 1300 (720 on the Duo; 669 on an iPad in landscape; about 1190 on a 13-inch iPad in portrait; about 410–500 on an iPhone held sideways as the simulated Duo) | **Recomposed for the shape (round 4):** each painter derives a `Stage` from the height — on a tall window the horizon rises to about 64–70% and the subject and planes grow; on a squat one the ensemble shrinks. A delivered image is aspect-filled instead, so it needs a wide, a tall and a squat crop — or three files. |
| Scene, folded | 432 units wide, about 240–520 high | The picture band at the top of one pane; the app cuts a wave along its bottom edge. **Its own composition since round 4**, not a crop of the wide scene. |
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
| `art/scene-ride.unfolded.heic` / `.folded.heic` | same | Mid-river: the Monkey on the Crocodile's back; the fruit island far ahead. Screen 10 when folded. | Pages 4–7 | `scene-ride` (new composition unfolded; the folded picture follows screen 10) |
| `art/scene-island.unfolded.heic` / `.folded.heic` | same | The new tree, the stepping-stone rock, the island of fruit trees. | Pages 9–10 | `scene-island` (new composition) |
| `art/scene-dusk.unfolded.heic` / `.folded.heic` | same | Dusk, pale sky. The Crocodile lying flat on the rock; the Monkey at the water's edge. | Pages 11–14 | `scene-dusk` (new composition) |
| `art/face-monkey.png` | 144 × 144 | The Monkey's face. | Voice chip | `face-monkey` |
| `art/face-crocodile.png` | 144 × 144 | The little Crocodile's face. | Voice chip | `face-crocodile` |
| `art/face-mother-crocodile.png` | 144 × 144 | The Mother Crocodile's face (older, heavier brow). | Voice chip | `face-mother-crocodile` |
| `art/char-monkey.card.heic` | 1296 × 1200 | The Monkey waving from a branch on a sunburst. Screen 07. | Character card | `char-monkey` |
| `art/see-river-bank.heic` | 1296 × 1212 | One rounded grassy bank, centred, meeting the water, with its leaning tree, earth lip, reeds and reflection (round 4: one subject, not a landscape). Fades into `#0A6585`. | Tap-to-see card | `see-river-bank` |
| `art/see-ripe-fruit.heic` | 1296 × 1212 | One cluster of three golden mangoes on its branch, centred (round 4). Fades into `#1F6B50`. | Tap-to-see card | `see-ripe-fruit` |

## `stories/anansi-wisdom/` — Medium, twilight forest (light text `#FBF2E2`, dark chrome)

Every kente, pot and house drawing goes to the Akan reviewer with the text (`culturalReview:
required`). Cloth and pot decoration is limited to woven blocks, plain bands, a zig-zag and
the design's web mark; no named adinkra symbol is drawn.

| File | Pixels | What it shows | Used on | Drawn by |
|---|---|---|---|---|
| `art/cover.heic` | 720 × 900 | Father Anansi on the great tree with the glowing pot, under the moon. | Library | `AnansiArt` `cover` |
| `art/scene-village.unfolded.heic` / `.folded.heic` | 2676 × 2160 / 1296 × 2160 | Dusk in the village; Father Anansi, whom everyone asks for advice. | Pages 1–2 | `scene-village` (new composition) |
| `art/scene-forest.unfolded.heic` / `.folded.heic` | same | The forest path at twilight; Anansi with the pot; Kweku Tsin following. | Pages 3–4 | `scene-forest` (new composition) |
| `art/scene-climb.unfolded.heic` / `.folded.heic` | same | Anansi clinging to the great tree, the pot in front of him; the moon. Screen 04, **relit in round 4**: the moon is on the hinge side of the trailing pane, upper left of Anansi, and the tree, cloth and web are lit from the left. | Pages 5–7 | `scene-climb` (a port of the design's `forestScene`, with the light moved) |
| `art/scene-wisdom.unfolded.heic` / `.folded.heic` | same | The pot broken on the rock; wisdom drifting out over the world as golden motes. | Page 8 | `scene-wisdom` (new composition) |
| `art/face-anansi.png`, `art/face-kweku.png` | 144 × 144 | Father Anansi; Kweku Tsin. | Voice chips | `face-anansi`, `face-kweku` |
| `art/char-anansi.card.heic`, `art/char-kweku.card.heic` | 1296 × 1200 | Father Anansi with the pot; Kweku Tsin peeking between leaves. | Character cards | `char-anansi`, `char-kweku` |
| `art/see-precious-pot.heic` | 1296 × 1212 | The great sealed clay pot, glowing. Fades into `#2A1650`. | Tap-to-see card | `see-precious-pot` |
| `art/see-forest.heic` | 1296 × 1212 | One great buttressed forest tree, centred, with lianas, far trunks in haze behind it and a warm shaft of light from the upper left (round 4: one subject). Fades into `#12303A`. | Tap-to-see card | `see-forest` |

## `stories/urashima-taro/` — Advanced, pale sea haze (text `#13264A` on both panes)

Grown-up, restrained, woodblock-influenced: this tier (10–12+) must not look babyish to a
13- or 14-year-old. The picture keeps the lower 300 pt of the trailing pane and, since round 4,
the lower 250 pt of the leading pane — from the sea's horizon down (`scene.textArea`
`trailingBottom` 420, `leadingBottom` 470; a share of the pane's height at any shape).

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
| `art/see-fishing-boats.heic` | 1296 × 1212 | One small wooden fishing boat, centred, on a morning sea, a low pale headland behind (round 4: one boat, not several). Fades into `#1B4C93`. | Tap-to-see card | `see-fishing-boats` |
| `art/see-rin-gin.heic` | 1296 × 1212 | The Dragon Palace under the sea. Screen 06. Fades into `#06204A`. | Tap-to-see card | `see-rin-gin` (a port of the design's `palaceScene`) |
| `art/see-tamatebako.heic` | 1296 × 1212 | The black lacquer box with its red cord. Fades into `#2B1E4A`. | Tap-to-see card | `see-tamatebako` |

## `landmarks/`

Our own illustrations, never photographs. Lost wonders are drawn as our own reconstructions
and their card says so.

| File | Pixels | What it shows | Used by | Drawn by |
|---|---|---|---|---|
| `art/taj-mahal.heic` | 1296 × 1212 | The white domed mausoleum with four minarets, mirrored in the long pool, at dawn. | The Monkey and the Crocodile (framed, "then and now") | `LandmarkArt` `taj-mahal` |
| `art/lighthouse-of-alexandria.heic` | 1296 × 1212 | A reconstruction, drawn to look like an artist's idea: three-level tower on a small island, centred (round 4). | The Shipwrecked Sailor (framed, "then and now", on "harbour") | `lighthouse-of-alexandria` |
| `art/asante-traditional-buildings.heic` | 1296 × 1212 | A low earth-walled house with a steep thatched roof and curling wall patterns. Generic patterns only; for the Akan reviewer. | How Wisdom Became the Property of the Human Race (natural) | `asante-traditional-buildings` |
| `art/tokyo-skytree.heic` | 1296 × 1212 | A slim pale lattice tower, centred, above a low city and a river, evening; the moon upper left (round 4). Our own stylised drawing; `docs/CONTENT_PLAN.md` §6.6 notes that the operator licenses the name and image (legal review before release, PRD Q29). | The Story of Urashima Taro (framed, "then and now") | `tokyo-skytree` |

| `art/sydney-opera-house.heic` | 1296 × 1212 | Nine pale sail-like roof shells in three groups on a stepped podium at the water, a blue harbour, two small sailing boats. No logo. Name and image are the Trust's trademarks (PRD Q29). | The Shipwrecked Sailor (framed, world link, on "sail") | `LandmarkArt+SydneyOperaHouse.swift` |
| `art/himeji-castle.heic` | 1296 × 1212 | The white main keep, five tiers of plaster walls and grey tiled roofs with upturned eaves on a curved stone base, a small tower joined to it, pines and a little blossom. | The Tongue-Cut Sparrow (framed, "then and now", on "white heron") | `LandmarkArt+HimejiCastle.swift` |
| `art/great-wall-of-china.heic` | 1296 × 1212 | A crenellated wall climbing green hills to a square watchtower, then on over a saddle to a second tower and away along a hazy ridge. | The Old Man Who Moved the Mountains (framed, map moment, on "basket by basket") | `LandmarkArt+GreatWall.swift` |
| `art/machu-picchu.heic` | 1296 × 1212 | Roofless grey stone houses and green terraces on a mountain saddle, the sugar-loaf peak behind, far Andes and a wisp of cloud. | The Old Man Who Moved the Mountains (framed, world link, on "mountain") | `LandmarkArt+MachuPicchu.swift` |
| `art/hagia-sophia.heic` | 1296 × 1212 | The building from its long side: the wide shallow dome on its ring of windows, half-domes stepping down, rose-ochre walls, four minarets, garden trees. Architecture only. | The Snow House (framed, world link, on "dome") | `LandmarkArt+HagiaSophia.swift` |
| `art/saint-basils-cathedral.heic` | 1296 × 1212 | Six red-brick towers, each with a different patterned onion dome, round a taller tent-roofed spire; paving in front. Architecture only; finials plain. | The Peasant and the Bear (framed, "then and now", on "onions") | `LandmarkArt+SaintBasils.swift` |
| `art/bremen-town-hall-roland.heic` | 1296 × 1212 | The stone knight Roland under his Gothic canopy on the market square, the town hall's arcade and green copper roof behind. The modern bronze of the four animals is deliberately not drawn (it may be in copyright). | The Bremen Town Musicians (natural, on "Bremen") | `LandmarkArt+BremenRoland.swift` |
| `art/colossus-of-rhodes.heic` | 1296 × 1212 | **A reconstruction**, pale and sketched: a bronze sun god, feet together on a tall white pedestal beside (not astride) the harbour, a crown of rays, small square-sailed ships for scale, a height rule in the margin. | The North Wind and the Sun (framed, "then and now", on "Sun") | `LandmarkArt+Colossus.swift` |
| `art/statue-of-liberty.heic` | 1296 × 1212 | The green copper statue on its stone pedestal and star-shaped base on a small island, torch raised, by day. | The North Wind and the Sun (framed, world link, on "harbour") | `LandmarkArt+StatueOfLiberty.swift` |
| `art/petra.heic` | 1296 × 1212 | The rose-red rock-cut front known as the Treasury, seen from inside the dark canyon; three tiny camels for scale. | The Lion and the Hare (framed, map moment, on "caravans") | `LandmarkArt+Petra.swift` |

## Round 5, batch 1 — the ten new Low stories

Every story names the same set of files (pixel sizes as the Monkey story's): `art/cover.heic`
720 × 900; for each of its four scenes `art/scene-<name>.unfolded.heic` 2676 × 2160 and
`art/scene-<name>.folded.heic` 1296 × 2160; for each ordinary tap target
`art/see-<id>.heic` 1296 × 1212; for each character `art/face-<id>.png` 144 × 144 and, where
the character has a card, `art/char-<id>.card.heic` 1296 × 1200. The asset name the painter
is asked for is the file name without folder and extensions. All ten keep a pale sky behind
the words in every scene (one dark ink a story).

| Story (painter) | Scenes | Tap pictures | Portraits · faces | Heroes drawn for this story alone |
|---|---|---|---|---|
| `shipwrecked-sailor` (`SailorArt`) — ancient Egypt | `scene-ship`, `scene-island`, `scene-serpent`, `scene-home` | `see-red-sea`, `see-incense`, `see-papyrus` | sailor, serpent · sailor, serpent, captain | The great golden Serpent (scaled coils, lapis brows, a king's beard); the ship's crew along the rail; the Nile harbour |
| `tongue-cut-sparrow` (`SparrowArt`) — Japan | `scene-cottage`, `scene-bamboo`, `scene-sparrow-house`, `scene-road` | `see-bamboo-grove`, `see-rice`, `see-guest` | old-man, sparrow · old-man, sparrow, old-woman | The thatched farmhouse with its porch; the sparrows' house and gate; the two wicker boxes; the heron in the stream |
| `old-man-who-moved-mountains` (`MountainsArt`) — ancient China | `scene-mountains`, `scene-digging`, `scene-river-bend`, `scene-open-road` | `see-north-china-mountains`, `see-big-family`, `see-carrying-pole` | yu-gong, zhi-sou · yu-gong, wife, boy, zhi-sou | Taihang and Wangwu with cliff bands; the family at work with poles and baskets; the willow at the river bend; the open road |
| `why-possums-tail-is-bare` (`PossumArt`) — Cherokee ⚑ | `scene-woods`, `scene-combing`, `scene-dance`, `scene-grin` | `see-smoky-mountains`, `see-cricket-barber`, `see-opossum` | possum, rabbit · possum, rabbit, cricket | Possum's tail in three states (silver plume, wrapped in red string, bare and curled); Cricket; Turtle; the layered blue ridges. Animals and forest only — no people, drums, fire, masks, feathers, patterns or lettering |
| `the-snow-house` (`SnowHouseArt`) — Inuit, Nunavut ⚑ | `scene-trail`, `scene-cutting`, `scene-spiral`, `scene-night` | `see-nunavut`, `see-snow-knife`, `see-qulliq` | elisapie, grandfather · elisapie, grandfather | The snow house as a rising spiral of slabs (half-built, and glowing gold at dusk); the snowmobile and the qamutiik; the snow knife; the qulliq. Plain modern parkas, no patterns |
| `peasant-and-bear` (`PeasantBearArt`) — Russia | `scene-field`, `scene-turnips`, `scene-rye`, `scene-harvest` | `see-forest`, `see-turnip`, `see-rye` | peasant, bear · peasant, bear, wife | Four seasons of one field; the horse with collar and duga; turnips, tops and roots; the birch-and-spruce forest edge; the far izba |
| `bremen-town-musicians` (`BremenArt`) — Germany | `scene-road`, `scene-forest`, `scene-window`, `scene-home` | `see-mill`, `see-town-musician`, `see-timber-house` | donkey, rooster · donkey, dog, cat, rooster | The tower of four at the glowing window; the half-timbered house by night and by morning. No robbers in any picture |
| `north-wind-and-sun` (`WindSunArt`) — ancient Greece | `scene-sky`, `scene-wind`, `scene-sun`, `scene-rest` | `see-fable`, `see-aegean-sea`, `see-cloak` | north-wind, sun · north-wind, sun, traveller | The North Wind (a cloud with a face and moods) and the Sun (a disc with a calm face) — the one story where the sun is a character and sits on the trailing pane; the rust-red cloak in three states; the sheared olive in the gale |
| `why-sun-and-moon-live-in-sky` (`SunMoonArt`) — Efik, Nigeria ⚑ | `scene-visit`, `scene-building`, `scene-flood`, `scene-sky` | `see-cross-river`, `see-compound`, `see-tide` | sun, moon, water · sun, moon, water | The Water as a person made of water; the Sun and the Moon as people with a gold and a silver glow; the compound going up and under water. Plain cloth only — no signs, masks or regalia |
| `lion-and-hare` (`LionHareArt`) — Persia ⚑ | `scene-valley`, `scene-council`, `scene-hills`, `scene-well` | `see-persia`, `see-wild-hare`, `see-well` | hare, lion · hare, lion, gazelle, tortoise | The old stone well with the two faces in the water; the Tortoise; the Gazelle's horns; gold hills and a green valley. Animals only |

⚑ = the story is flagged "needs cultural review before release"; its pictures go to the same
reviewer as its text.

### Known shortfalls after round 5, batch 1 (from the painters' own notes — to check on the Mac)

Across the batch:
- **Nothing has been rendered.** The kit's people, animals and birds have never been seen; a
  fault in `Kit.person`, `Kit.beast` or `Kit.bird` shows in most stories at once.
- Kit figures are **side or three-quarter views** with a fixed set of poses. Painters built a
  few poses the kit lacks from its internal rig (`Kit.bodyRig`, `Kit.bodyFigure`…), which ties
  those stories to the rig's field names.
- Most painters came in under the line budget (about 1,250–1,650 lines a story against the
  Monkey story's 2,660): the scenes lean on kit calls. Near-plane framing is often
  `Kit.cornerLeaves` rather than something drawn for the place.
- Tall iPad windows and the squattest phone windows were checked by arithmetic for the
  subject only. Several painters note a prop near the hinge strip or a face close to a control
  at an extreme size (listed below).
- Some painters did not finish the full "be the compiler" re-read; a reviewer pass followed.

Per story:
- **Sailor.** The Serpent's coil pile is stacked capsules (a cushion, not a true spiral) and
  its scale pattern is a flat grid. In both home scenes the ship is the kit boat mirrored, so
  the hull's light is on the wrong side. `scene-ship` is side-on, not three-quarter. On a tall
  window the coil pile is cropped by the right edge; on a squat one the bow crosses the hinge.
- **Sparrow.** The old man is a side-view figure on a front-view porch and his head overlaps
  the slatted window; the Sparrow is small in the wide cottage scene; her "bow" is the kit's
  peck tilt; the wicker boxes are the kit's flared basket, not rectangular boxes; both elders
  wear a long kimono where the author's brief asked for a short jacket and leggings.
- **Mountains.** Cliff bands are placed by an estimate of the kit mountain's outline; the
  elders' robes are ankle-length (the brief asks knee-length work robes); the wife has no
  folded-arms pose; the open-road folded scene cannot show the back view the brief asked for.
- **Possum.** The upside-down heads in `scene-grin` are rotated kit heads (catchlights not
  upper-left); the grin shows a small rounded row of teeth, as the story needs; Rabbit's bent
  ear is not drawn; the silver plume may read soft against the blue ridges; the hollow tree is
  left out of the folded combing scene.
- **Snow House.** Near-plane framing is only pale snow banks; on the tallest windows the sled
  is cropped and the snowmobile's ski crosses the hinge; portrait arms are drawn over the kit
  bust and may not join the shoulders; Elisapie stands (the kit's kneel puts hands on the
  ground); the scene-cutting layout is mirrored from the author's brief. **For the Inuit
  consultant:** the spiral, the knife, the qulliq, the parkas, the sled and the snowmobile.
- **Peasant and Bear.** The Bear "sits" as a rearing bear half-hidden by his heap; the cart is
  two-wheeled (a telega has four); the izba roof is low-pitched; on tall windows the horse and
  the Bear's side drift toward the hinge; the wife appears only as a face chip.
- **Bremen.** The Donkey stands beside the wall rather than with hooves on the sill; the
  Rooster's wings stay folded; the Cat's green eyes and white paws are not drawn; the door is
  small beside the Donkey; birch tops in `scene-window` rise into the leading pane's sky.
  Kit trap: `Kit.beastFace` draws a lion's ruff for any `mane: true`, so the Donkey's front
  views use a mane-less copy with a drawn forelock.
- **Wind and Sun.** The traveller is bare-headed in the gale with the hat in the air; harbour
  houses are stone and mud-brick colours (the author's brief warns against whitewashed
  cubes); on the tall cover the two sky characters are small; on the widest cover crop the
  Sun's face is near the tier pill; the bent olive uses a sheared context.
- **Sun and Moon.** The two sit shoulder to shoulder in the sky (not hand in hand), in a pale
  cloud; the Moon's wrapper is the kit's one-shoulder wrap (**for the Efik reader's dress
  check**); the Sun in the canoe is a sitting figure clipped at the gunwale; on a squat phone
  the Moon's face is close to the "Aa" capsule in `scene-sky`.
- **Lion and Hare.** At the well the Lion is a front-view bust behind the rim (he does not
  hold the Hare); `see-wild-hare` shows the story's Hare rather than a natural-history hare;
  the Hare's ears do not change with mood; the Tortoise always faces left; the kit lion's mane
  is the standard ruff.
- **Landmarks.** Petra's top-left corner is dark canyon, not sky, and its carved front is
  narrower than 60% of the width; the Sydney shells are a simplified side view about 77% of
  the width; the Statue of Liberty's figure is a little over half the total height and its
  face is tiny; Hagia Sophia is a flattened, symmetric side elevation; Saint Basil's shows six
  of the side chapels and its swirls may read as slanted stripes; Roland and the Colossus are
  narrow subjects carried by what stands behind them; Himeji shows one small tower of three.

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

Known shortfalls of round 3 (kept as the record; round 4 worked on each — see below):
the Anansi climb scene and the Skytree lit from the right; Urashima at 3.5 heads, Otohime at
4.4, the villagers at 3.7; white crocodile eyes instead of screen 03's; `see-river-bank` a
small landscape, `see-forest` without a subject, the Lighthouse and Skytree off-centre; a teal
Anansi canopy and a grey-lavender "years later" sea; folded bands cropped from the wide
scenes; unverified portrait arithmetic.

## What round 4 changed in the pictures (to check on the Mac — none of it has been rendered)

| Known miss of round 3 | What round 4 did |
|---|---|
| Urashima and Otohime proportions | Both **redrawn at 3.0 heads** (about 104 units to the crown with a 35-unit head): shorter coat, straw skirt and legs, larger hands and feet; Otohime's bodice and robe shortened, sleeves ending in cuffs. One set of figure functions (`UrashimaArt+Figures.swift`) feeds scenes, portraits, the cover, the boat's crew and the rider |
| Light in the Anansi climb scene | **The moon moved** from the right to the hinge side of the trailing pane (upper left of Anansi); bark, buttresses, boughs, cloth, web and canopy highlights flipped to lit-left, shaded-right. The cover, the portrait and the other three scenes take the same moon, so the story has one light |
| Light in the Skytree picture | **Moon upper left** (clear of the close button), warm edge up the tower's left side and a cool right edge, buildings lit on the left wall, the river, bridges and boat mirrored so the moon's reflection lies under the moon |
| `see-river-bank`, `see-forest` | **One centred subject each** (the bank with its tree; one great buttressed tree). `see-ripe-fruit`, `see-precious-pot` and `see-fishing-boats` were re-framed to the same rule; the Lighthouse and the Skytree were centred; the Asante house was drawn a little smaller so its roof no longer touches the edges |
| Crocodile eyes | **Restored to locked screen 03**: yellow ball, a ring in the skin's line colour, a dark upright pupil, one catchlight (kept upper left when the animal is mirrored). The peach blush on the crocodiles is gone |
| Folded scenes were crops | **Thirteen folded compositions of their own** (`JatakaArt+Folded.swift`, `AnansiArt+Folded.swift`, `UrashimaArt+Folded.swift`) for a 432 × 240–520 band: subject in the middle of the width, under the top controls, above the wave cut |
| iPad portrait: a stretched sky | **Every unfolded scene recomposes with the height** (a `Stage` per story): the horizon rises to about 64% (Urashima) or 70% (Monkey, Anansi) of a tall window, the subject, the far and near planes and the trees grow by about 1.3–1.6 ×, and a near band fills the foot of the picture. The reader keeps the words above the picture's part (`ReaderMetrics.pictureReserve`) |
| Urashima on an iPad in landscape: an empty lower-left | **The sea now runs under both panes**: a level horizon at about 64% of the height, a long pale far shore with a line of pines and distant sails, the patterned wave bands across the leading pane, sea rocks with a leaning pine in the bottom third; a mist veil keeps everything above the horizon close to the sky's value for the words. The words on the leading pane now stop at the horizon (`textArea.leadingBottom` 470 on every Urashima page) |
| Squat windows (new: the simulated Duo on an iPhone held sideways) | Each unfolded scene shrinks its ensemble below about 520–560 units so canopy, subject and ground keep their distances |
| Illustration depth | Far planes veiled with the sky's colour, rim light and core shadow on the main forms (banyan trunk, crocodile back, the Monkey's head and chest, huts and houses, the great tree, hull and sail, the landmarks' towers, dome and roof), contact shadows, broken-edge foliage, tapered trunks (`docs/ART_DIRECTION.md` §3a) |
| Palette | The Anansi canopy's dark tones pulled toward indigo; the "years later" sea of `scene-return` is a cooler, quieter blue of the story's own ramp, with the warm horizon kept |

## Known shortfalls after round 4 (from the four painters' own notes)

- **Nothing was rendered.** Figure proportions are right by arithmetic and may look stubby
  (Urashima shows only about 13 units of leg under the skirt); the mirrored Skytree river and
  every folded composition are hand-calculated.
- **Text contrast near the picture:** on the Urashima sea scenes the nearest wave bands on the
  leading pane are dark blue (the words now stop at the horizon above them, but check a long
  page at the largest text size); on a tall iPad the Monkey's far hills and island tree tops
  reach about 62–67% of the height and the Anansi village sunset behind the words is muted by
  an indigo veil — whether each reads as designed and keeps 4.5:1 needs eyes.
- **Tall windows grow, they do not gain a new middle plane.** The recomposition scales and
  re-places what the 720 composition has (plus extra lily pads, a sandbar, a band of near
  ground); a true portrait composition is an illustrator's job.
- **Very short folded bands (under about 300 units):** subjects shrink hard to stay below the
  top controls (the boat in the folded sea scene to about 0.36 ×); in the Monkey's folded river
  and ride bands at 240 the Monkey's head sits between the two top controls rather than below
  them. Folded river, island and dusk still share the tree and bank painters of the wide scene.
- **Hinge and chrome:** at tall heights the Mother Crocodile's body crosses the hinge strip
  (her face is clear of it); at mid-tall heights the little Crocodile's tail sits just above
  the tier chips. In the folded wisdom band Kweku Tsin's face is just outside the middle 60%.
- **Light:** the suns of the Taj Mahal, Lighthouse and Asante pictures are low on the left,
  not truly upper left (rim and shade follow upper left regardless); the Lighthouse's fire is
  a second light by nature. Canopy highlights in the Anansi story now sit upper left — a
  visible difference from locked screen 04, like the moved moon.
- **Proportions:** the climbing Anansi's body is unchanged; only the villagers were redrawn.
  `scene-return` shows Urashima as the same young figure holding the box, not aged.
- **Still shapes:** the Monkey's limbs are plain strokes, faces are built from ellipses, kente
  stays flat blocks, kelp and coral are plain strokes, the tortoise is nearly unchanged, the
  cypresses and some far crowns are still symmetric.
- **Framing:** the Skytree and the Lighthouse are slim subjects, well under 60% of the width
  (centred, not enlarged); the Asante house is about 79%. The Skytree's boat, the
  Lighthouse's swells and the largest cypresses sit in the bottom quarter and rely on the
  card's fade. The top-right leaf spray on the Taj Mahal and Asante pictures is the least
  certain addition (one line each to remove).
- **Portraits:** a 3-heads figure cannot show head-to-waist with the head top at 60 units;
  Urashima is framed to the sash and Otohime to the cuffs.

## Status

**Round 5, batch 1:** every picture of the ten new stories and the ten new landmarks, and
the whole kit, is unrendered and `review.art: pending`; start with the kit's people and
animals (`docs/BUILD.md` §7d, step 6). New cultural-review material: every picture of the
four flagged stories of the batch (Cherokee consultant; Inuit consultant, Nunavut; Efik
reader; reviewer familiar with Rumi and Sufi tradition), and the religious buildings among
the landmarks (Hagia Sophia, Saint Basil's) as architecture only.

Every `review.art` field is `pending`. All card copy, lesson wording and fact-card wording in
the JSON is draft, unreviewed text. After round 4 **every** picture needs a look on the Mac
(nothing drawn in rounds 3 or 4 has been rendered by its authors; the round-3 look was seen
in the `r3-*.png` shots, the round-4 look by nobody): first the redrawn figures and the
relit climb scene, then each scene on an iPad in portrait and in the phone's folded band,
then the tap-to-see pictures. New cultural-review material from round 4: the redrawn
villagers (Akan reviewer), the redrawn Urashima and Otohime (Japanese reader) — on top of
round 3's: the villagers' faces and hair and Father Anansi's expression, Urashima's and
Otohime's faces.
