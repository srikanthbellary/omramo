# Omramo — Content plan: launch story catalog and landmarks (v2)

**Status:** the plan is Srikanth's proposal-as-adopted for the build (round 5 writes it out). **Written and drawn so far: 13 of 32 stories** — the three prototypes and, in round 5 batch 1 (18 Nov 2026), the ten other Low stories; see §2a. Every text is a draft (`review.text: pending`), every picture is concept art drawn in code (`review.art: pending`), and nothing has been through cultural review, fact-check or legal clearance.
**Reads with:** `docs/PRD.md` (§4a, §12), `docs/ARCHITECTURE.md` (§6), `docs/DESIGN.md`, `docs/IMPLEMENTATION_PLAN.md` (milestone C1).

**Owner requirements this plan answers (13 Nov 2026):**

1. First stories are copyright-free and ready to use; go across the globe; where no copyright-free source exists, create one; every tier spans all regions, with grounded geography, culture and moral education.
2. Weave landmarks into the stories — the Seven Wonders, on to 21 or more — from historical to modern and contemporary.

**Wording used in all Omramo documents.** The owner's "native red indians" is written as **Native American / First Nations**, and each story names the specific nation (Cherokee, Dakota, Sḵwx̱wú7mesh). "Alaska igloos" is written as **Arctic (Inuit / Yupik / Iñupiat)**. The word "Eskimo" appears below only inside the titles of old source books; it is never used in the app (many Inuit, especially in Canada and Greenland, find it offensive).

Conventions: **Decided / Assumption / TBD — open question** as in the PRD. No business numbers are invented. Examples are labelled **Example (not a decision)**.

---

## 1. Rules for the catalog

### 1.1 Coverage

- **10 regions × 3 tiers, at least one story in every cell** (30 minimum). This plan has **32 stories**: one per cell, plus two extra European stories (Greek) that give the Ancient Wonders a natural home.
- A "region" is a shelf label, not a culture. Every story names a **specific people and place** (for example "Akan (Asante/Fante), Ghana", never just "African").

### 1.2 Rights basis

- **Public-domain first.** Each retelling cites a specific edition published before 1931, which is in the US public domain in 2026. Where I could, I confirmed that the Project Gutenberg ebook exists and contains the story (checked 13 Nov 2026 by fetching the ebook text; marked **verified**). Anything not checked is marked **unverified**.
- **The app text is our own fresh retelling** of the traditional tale, written for the tier. This is the safest basis: the old tales themselves are not owned by anyone, we copy no translator's wording, and we can fix dated language. The cited edition is our documented source, not our text.
- **US public domain is not worldwide public domain.** Some cited translators died recently enough that their *wording* is still protected in life + 70 countries (flagged per story — for example Arthur Ransome, d. 1967; Lionel Giles, d. 1958). A fresh retelling reduces this risk but a lawyer must confirm it for non-US stores. Open question CQ2.
- **Originals.** Where no clean public-domain source exists, the story is marked **"Original story written by us (Omramo)"**, with its premise. Originals are grounded in real geography and daily life and take no sacred material.
- **This changes an earlier assumption.** PRD assumption A5 and DESIGN §8 say the prototype stories use the source texts unaltered. The new catalog rule is fresh retellings. M1 still uses the 1912 Babbitt text as a placeholder manuscript. Open question CQ1.

### 1.3 Cultural care

- **No sacred, ceremonial or restricted narratives:** nothing clan-owned, nothing told only in a certain season or by certain people, no creation or ceremony stories from living Indigenous traditions.
- **Cultural review** has two levels:
  - **Required (launch-blocking):** every Native American / First Nations story, every Arctic story, every story from another living oral tradition (the three African stories), and every story derived from religious scripture or a religious teaching text. A consultant from the community reads the text, the art and every card before release.
  - **Standard:** every other story gets an accuracy and sensitivity read by someone with knowledge of the culture.
- Old source books carry colonial-era framing. Each entry notes what our retelling must fix.
- Peoples are shown as **living today**, not only in the past. Cards say "the Cherokee tell", not "the Cherokee told".

### 1.4 Arctic accuracy (must be taught correctly)

- **Iglu** is the Inuktitut word for a house of any kind. The domed **snow house** (igluvijaq) is mainly a tradition of **Inuit in the central Canadian Arctic** (and parts of Greenland), used as a winter home or a hunting shelter.
- **Alaska is different.** Yup'ik and Iñupiat families traditionally lived in **semi-underground sod houses** framed with driftwood or whalebone; a snow shelter was an emergency measure on the trail. The app must not show "Alaskan igloos".
- Today Arctic families live in modern houses; snow-house building is still taught as a skill.
- So the plan has a Canadian Inuit snow-house story, an Alaskan Yup'ik story with no snow house, and a Greenlandic story.

---

## 2. Summary matrix (region × tier)

| Region | Low | Medium | Advanced |
|---|---|---|---|
| **Indian** | The Monkey and the Crocodile *(prepared)* | The Tiger, the Brahman and the Jackal | Savitri and Satyavan |
| **Egyptian** | The Shipwrecked Sailor | King Khufu and the Magician | The Eloquent Peasant |
| **Japanese** | The Tongue-Cut Sparrow | The Bamboo-Cutter and the Moon-Child | The Story of Urashima Taro *(prepared)* |
| **Chinese** | The Old Man Who Moved the Mountains | The Herd Boy and the Weaving Maiden | The Ballad of Mulan |
| **Native American / First Nations** | Why the Possum's Tail Is Bare (Cherokee) | Iktomi and the Muskrat (Dakota) | The Two Sisters (Sḵwx̱wú7mesh / Squamish) |
| **Arctic** | The Snow House (Inuit, Nunavut) — *original* | The Long Day at Fish Camp (Yup'ik, Alaska) — *original* | The Woman Who Raised a Bear (Kalaallit, Greenland) |
| **Russian** | The Peasant and the Bear | Sadko | The Fire-Bird and the Horse of Power |
| **European** | The Bremen Town Musicians (German) · The North Wind and the Sun (Greek) | Androcles and the Lion (Roman) · The Horse and the Olive (Greek) | Daedalus and Icarus (Greek) |
| **African** | Why the Sun and the Moon Live in the Sky (Efik, Nigeria) | How Wisdom Became the Property of the Human Race (Akan, Ghana) *(prepared)* | The Griot's Apprentice (Mande, Mali) — *original* |
| **Persian / Arabian** | The Lion and the Hare (Persian) | Sindbad's Second Voyage (Arabic) | Zal and the Simurgh (Persian) |

**Counts:** 32 stories — Low 11, Medium 11, Advanced 10. **29 public-domain retellings, 3 originals.** **12 flagged for required cultural review** (§7).

### 2a. Status of each story (round 5)

"Draft" = text written as our own retelling (or original), built from `docs/content/story-specs/<id>.json`, validated, with concept art drawn in code; text, art, facts and cultural review all still **pending**. ⚑ = carries the flag **needs cultural review before release** (§7).

| # | Story | Tier | Status |
|---|---|---|---|
| L1 | `monkey-and-crocodile` | Low | Draft (rounds 1–4; moral polished in round 5) ⚑ Buddhist reader |
| L2 | `shipwrecked-sailor` | Low | Draft — round 5 batch 1 |
| L3 | `tongue-cut-sparrow` | Low | Draft — round 5 batch 1 |
| L4 | `old-man-who-moved-mountains` | Low | Draft — round 5 batch 1 |
| L5 | `why-possums-tail-is-bare` | Low | Draft — round 5 batch 1 ⚑ Cherokee consultant |
| L6 | `the-snow-house` | Low | Draft (original) — round 5 batch 1 ⚑ Inuit consultant (Nunavut) |
| L7 | `peasant-and-bear` | Low | Draft — round 5 batch 1 |
| L8 | `bremen-town-musicians` | Low | Draft — round 5 batch 1 |
| L9 | `north-wind-and-sun` | Low | Draft — round 5 batch 1 |
| L10 | `why-sun-and-moon-live-in-sky` | Low | Draft — round 5 batch 1 ⚑ Efik reader |
| L11 | `lion-and-hare` | Low | Draft — round 5 batch 1 ⚑ reviewer familiar with Rumi and Sufi tradition (light) |
| M1–M9, M11 | the ten other Medium stories | Medium | Planned — round 5 batch 2 |
| M10 | `anansi-wisdom` | Medium | Draft (rounds 2–4; moral polished in round 5) ⚑ Akan reader |
| A1, A2, A4–A10 | the nine other Advanced stories | Advanced | Planned — round 5 batch 3 |
| A3 | `urashima-taro` | Advanced | Draft (rounds 2–4; moral polished in round 5) |

Things the drafts of batch 1 did that this plan left open (each is listed in the story's manuscript header, `Content/sources/<id>.txt`, for the reviewers):

- **Sources.** gutenberg.org was unreachable from the authoring box on 18 Nov 2026; where a mirror could be read the tale was read there, otherwise the retelling was written from knowledge of the traditional tale. No source wording is used. Each manuscript header says which.
- **Softenings (examples).** Sparrow: the scissors "nip the tip" of the tongue, the big basket holds bees, a toad and mud, the old woman says sorry. Sailor: the crew is not lost; the serpent's family "now there is only me". Lion and Hare: the animals bring the lion his dinner (no victim) and the lion climbs out of the well and leaves. Bremen: "too old to be useful", no talk of killing. Peasant and Bear: a warm ending (a loaf and turnips left on a stump).
- **Names and words.** The Snow House: the girl is Elisapie; three Inuktitut words (iglu, qamutiik, qulliq) — all for the Inuit consultant. Possum: no Cherokee words; the dance is the animals' own. Sun and Moon: no Efik names. Old Man: Yu Gong and Zhi Sou with the meanings of their names.
- **Landmarks added to the shared catalog (10):** `sydney-opera-house`, `himeji-castle`, `great-wall-of-china`, `machu-picchu`, `hagia-sophia`, `saint-basils-cathedral`, `bremen-town-hall-roland`, `colossus-of-rhodes`, `statue-of-liberty`, `petra`, each with fact cards for the three tiers (facts pending review; several dates and details beyond §5.1 come from general knowledge and are marked in the review notes).
- **Morals** are one short sentence each (round 5 rule: at most about 14 words for Low, 18 for Medium and Advanced, no semicolon).

---

## 3. Story catalog

Each entry gives: id · region (people, place) · tier · source and rights basis · geography, culture and moral lessons · cultural review · landmarks (detail in §6) · notes.

### 3.1 Low tier (11)

**L1 `monkey-and-crocodile` — The Monkey and the Crocodile** *(prepared)*
- **Region:** Indian — Buddhist Jataka tradition, ancient northern India.
- **Source:** Ellen C. Babbitt, *Jataka Tales*, The Century Co., 1912. Gutenberg #62514, https://www.gutenberg.org/ebooks/62514 (verified earlier, `stories/SOURCES.md`). US public domain; Babbitt's death year not verified.
- **Geography:** the great rivers of northern India; monkeys and mugger crocodiles share them.
- **Culture:** the Jatakas are very old teaching stories told by Buddhists about wise animals; they travelled across Asia.
- **Moral:** when you are in trouble, think. A calm, clever answer beats a bigger foe.
- **Cultural review:** **Required** — derived from Buddhist scripture (the Jataka collection).
- **Landmark:** Taj Mahal (framed, "then and now").
- **Notes:** the mother crocodile wants the monkey's heart to eat; keep it light. M1 sample story.

**L2 `shipwrecked-sailor` — The Shipwrecked Sailor**
- **Region:** Egyptian — ancient Egypt, Middle Kingdom (about 4,000 years ago).
- **Source:** W. M. Flinders Petrie, *Egyptian Tales, Translated from the Papyri, First Series*, 1895. Gutenberg #7386, https://www.gutenberg.org/ebooks/7386 (verified). Petrie died 1942, so his text is also out of copyright in life + 70 countries.
- **Geography:** the Nile, the Red Sea, and the voyage south toward the land Egyptians called Punt (its exact place is still debated — say so).
- **Culture:** Egyptians wrote stories on papyrus; this is one of the oldest adventure stories known. Fun link: the papyrus is kept in a museum in Russia.
- **Moral:** stay brave and calm when things go wrong; be thankful to those who help you.
- **Cultural review:** Standard (Egyptologist accuracy read).
- **Landmarks:** Lighthouse of Alexandria (framed, lost wonder); Sydney Opera House (framed, world link).
- **Notes:** the giant serpent is kind, not a monster. The serpent's lost family is told gently.

**L3 `tongue-cut-sparrow` — The Tongue-Cut Sparrow**
- **Region:** Japanese — Japan (folk tale, *Shita-kiri Suzume*).
- **Source:** Yei Theodora Ozaki, *Japanese Fairy Tales*, 1908 ed. Gutenberg #4018, https://www.gutenberg.org/ebooks/4018 (verified). Ozaki died 1932.
- **Geography:** Japan's wooded hills and bamboo groves; an island country.
- **Culture:** hospitality to a guest; rice as daily food; choosing the smaller gift as good manners.
- **Moral:** kindness is returned; greed chooses the big basket and regrets it.
- **Cultural review:** Standard.
- **Landmark:** Himeji Castle (framed, "then and now").
- **Notes:** soften the tongue-cutting (Example (not a decision): the wife "snipped and chased the sparrow away"); avoid making the wife a one-note villain.

**L4 `old-man-who-moved-mountains` — The Old Man Who Moved the Mountains**
- **Region:** Chinese — ancient China (the Taihang and Wangwu mountains, north China); from the classic *Liezi*.
- **Source:** the *Liezi* ("Tang wen" chapter), an ancient text, public domain everywhere. English reference: Lionel Giles, *Taoist Teachings from the Book of Lieh Tzŭ*, 1912 — **unverified** (not found on Gutenberg; inclusion of this story to be checked). Giles died 1958: his wording is protected in life + 70 countries until 2029, so we work from the classical text.
- **Geography:** north China's mountains and the Yellow River plain; how mountains shape roads and journeys.
- **Culture:** families of several generations working together; respect for elders; a four-character saying every Chinese schoolchild knows (*Yu Gong yi shan*).
- **Moral:** big things are done a little at a time, by people who keep going.
- **Cultural review:** Standard. Note: the fable was used in 20th-century political speeches; we tell the classical version only.
- **Landmarks:** Great Wall of China (framed, map moment); Machu Picchu (framed, world link).

**L5 `why-possums-tail-is-bare` — Why the Possum's Tail Is Bare**
- **Region:** Native American / First Nations — **Cherokee** (southern Appalachian homelands; today the Eastern Band of Cherokee Indians in North Carolina, and the Cherokee Nation and United Keetoowah Band in Oklahoma).
- **Source:** James Mooney, *Myths of the Cherokee*, Bureau of American Ethnology 19th Annual Report, 1900 (story 18). Gutenberg #45634, https://www.gutenberg.org/ebooks/45634 (verified). US government publication; Mooney died 1921.
- **Geography:** the Great Smoky Mountains; real animals of the eastern woodlands (opossum, rabbit, cricket).
- **Culture:** animal stories told for fun and for teaching; the Cherokee have their own written language (the syllabary made by Sequoyah); Cherokee people live and tell these stories today.
- **Moral:** boasting makes you easy to trick; be proud quietly.
- **Cultural review:** **Required** — Indigenous story. A widely published animal tale that Cherokee tellers share publicly, but a Cherokee consultant must confirm it is right for us to retell and how.
- **Landmark:** none, by design (§6.4).
- **Notes:** Mooney was an outside ethnographer; credit the Cherokee storytellers he recorded (Ayûñinĭ "Swimmer" and others). No feathers-and-tipis imagery: Cherokee towns had wooden houses and gardens.

**L6 `the-snow-house` — The Snow House** *(working title)*
- **Region:** Arctic — **Inuit**, Nunavut, Canada (Example (not a decision): near Igloolik).
- **Source:** **Original story written by us (Omramo).** No sacred or traditional narrative is used.
- **Premise:** on a spring trip to the fishing lakes, a girl helps her grandfather build a snow house for the night. She wants to go fast; her blocks crack. He shows her how to find the right snow, cut each block, lean it on the last one, and set the final block at the top. She sleeps warm inside what she helped build.
- **Geography:** the Canadian Arctic; sea ice and tundra; long light in spring; where Nunavut is.
- **Culture:** the snow house as Inuit engineering (a spiral of blocks that holds itself up); the snow knife; the stone lamp (qulliq); learning by watching elders. Card: families in Nunavut live in modern houses today, and still teach this skill.
- **Moral:** careful work, done patiently, holds together; every block leans on the others.
- **Cultural review:** **Required** — Indigenous setting. Names, words in Inuktitut, clothing and tools all need an Inuit consultant; ideally co-written with an Inuit author (CQ4).
- **Landmark:** Hagia Sophia (framed, world link — "a dome of snow, a dome of stone").

**L7 `peasant-and-bear` — The Peasant and the Bear**
- **Region:** Russian — Russian village folk tale.
- **Source:** Valery Carrick, *More Russian Picture Tales*, trans. Nevill Forbes, 1914. Gutenberg #23462, https://www.gutenberg.org/ebooks/23462 (book verified; the tale is in the text, its printed title not confirmed). Carrick died 1943, Forbes 1929.
- **Geography:** Russia's forests and farm fields; short summers; root crops such as turnips, and grain.
- **Culture:** the bear as the best-known animal of Russian tales; village farming.
- **Moral:** think before you agree to a bargain. (Tops or roots? It depends on the crop.)
- **Cultural review:** Standard.
- **Landmark:** Saint Basil's Cathedral (framed, "then and now" — its onion domes).
- **Notes:** keep it playful rather than a lesson in cheating; the bear is hasty, the peasant careful.

**L8 `bremen-town-musicians` — The Bremen Town Musicians**
- **Region:** European — **German** (Brothers Grimm; Lower Saxony and Bremen).
- **Source:** *Household Tales by Brothers Grimm*, trans. Margaret Hunt, 1884 (tale 27). Gutenberg #5314, https://www.gutenberg.org/ebooks/5314 (verified). Public domain worldwide (Hunt died 1912).
- **Geography:** northern Germany; the old trading city of Bremen on the River Weser.
- **Culture:** the Grimm brothers collected tales people told at home; town musicians were a real job.
- **Moral:** nobody is too old to be useful; friends are stronger together.
- **Cultural review:** Standard.
- **Landmark:** Bremen Town Hall and Roland statue (natural — the city the animals are walking to).
- **Notes:** the animals never reach Bremen; a nice fact for the card.

**L9 `north-wind-and-sun` — The North Wind and the Sun**
- **Region:** European — **ancient Greek** (Aesop's fables).
- **Source:** *Aesop's Fables*, trans. V. S. Vernon Jones, 1912. Gutenberg #11339, https://www.gutenberg.org/ebooks/11339 (verified). Also in Joseph Jacobs, *The Fables of Aesop*, 1894, Gutenberg #28 (verified).
- **Geography:** Greece and its islands; the Aegean Sea; windy winters, hot sun.
- **Culture:** fables — very short stories with a point — told in Greece about 2,500 years ago and still told everywhere.
- **Moral:** gentleness wins where force fails.
- **Cultural review:** Standard.
- **Landmarks:** Colossus of Rhodes (framed, lost wonder — a statue of the sun god); Statue of Liberty (framed, world link).

**L10 `why-sun-and-moon-live-in-sky` — Why the Sun and the Moon Live in the Sky**
- **Region:** African — **Efik** people, Calabar and the Cross River, south-eastern Nigeria.
- **Source:** Elphinstone Dayrell, *Folk Stories from Southern Nigeria, West Africa*, 1910 (story XVI). Gutenberg #34655, https://www.gutenberg.org/ebooks/34655 (verified). Dayrell's death year not verified.
- **Geography:** the Niger Delta and Cross River country, where land, river and sea meet; tides and floods.
- **Culture:** visiting and hospitality; building a compound; "why" stories that explain the world.
- **Moral:** think ahead before you make a big promise — and a good host makes room.
- **Cultural review:** **Required** — living oral tradition; an Efik reader should confirm tone and details.
- **Landmark:** none at launch (§6.4).
- **Notes:** Dayrell was a colonial district officer; his book speaks of "natives". Our retelling drops that voice entirely.

**L11 `lion-and-hare` — The Lion and the Hare**
- **Region:** Persian / Arabian — **Persian** (told by the poet Rumi in the *Masnavi*, 13th century; the tale is older, from *Kalila and Dimna*, and before that from India).
- **Source:** *The Mesnevi* of Jalal al-Din Rumi, Book I, trans. James W. Redhouse, 1881. Gutenberg #61724, https://www.gutenberg.org/ebooks/61724 (verified; the hare-and-lion tale is in the text). Redhouse died 1892.
- **Geography:** the lands the story crossed — India, Persia (Iran), Arabia; caravan roads.
- **Culture:** stories travel: this one was told in Sanskrit, then Persian, then Arabic, and reached Europe. Poets taught with animal stories.
- **Moral:** wit can protect the small from a bully.
- **Cultural review:** **Required (light)** — our direct source is a Sufi religious poem. We retell only the animal tale, without Rumi's spiritual commentary; a reviewer should confirm that is respectful.
- **Landmark:** Petra (framed, map moment — a caravan city).
- **Notes:** the lion's end (he leaps into the well) is told without cruelty.

### 3.2 Medium tier (11)

**M1 `tiger-brahman-jackal` — The Tiger, the Brahman and the Jackal**
- **Region:** Indian — **Punjab**, north-west India and Pakistan.
- **Source:** Joseph Jacobs, *Indian Fairy Tales*, 1892 (story IX; from Flora Annie Steel's Punjab collection). Gutenberg #7128, https://www.gutenberg.org/ebooks/7128 (verified). Jacobs died 1916.
- **Geography:** the Punjab, "land of five rivers"; the pipal tree, the buffalo, the road.
- **Culture:** asking others to judge a quarrel; who a Brahman is; tigers in India today.
- **Moral:** be kind, but keep your eyes open; a cool head settles what an argument cannot.
- **Cultural review:** Standard. Explain "Brahman" neutrally; no caste judgement.
- **Landmark:** none at launch (§6.4).

**M2 `khufu-and-the-magician` — King Khufu and the Magician**
- **Region:** Egyptian — ancient Egypt, Old Kingdom (the age of the pyramid builders).
- **Source:** Petrie, *Egyptian Tales, First Series*, 1895 ("Tales of the Magicians", from the Westcar Papyrus). Gutenberg #7386 (verified; Khufu and "Dedi" are in the text).
- **Geography:** Giza and Memphis on the Nile; travelling by river boat.
- **Culture:** King Khufu built the Great Pyramid; kings were told stories at court; scribes and papyrus.
- **Moral:** power does not make a thing right. The old magician refuses to try his magic on a prisoner — "not on a person" — and the king accepts it.
- **Cultural review:** Standard (Egyptologist accuracy read).
- **Landmarks:** Great Pyramid of Giza (natural); Chichén Itzá (framed, world link — another people's pyramid).
- **Notes:** leave out the prophecy about the next dynasty's birth.

**M3 `bamboo-cutter-and-moon-child` — The Bamboo-Cutter and the Moon-Child**
- **Region:** Japanese — Japan (*Taketori Monogatari*, about 1,100 years old, the oldest Japanese story in prose).
- **Source:** Ozaki, *Japanese Fairy Tales*, 1908 ed. Gutenberg #4018 (verified; the ending names Mount Fuji).
- **Geography:** bamboo forests; the old capital; Mount Fuji, Japan's highest mountain.
- **Culture:** court life and poetry; the moon in Japanese stories; moon-viewing in autumn.
- **Moral:** you cannot own someone you love; tricks and false gifts are found out.
- **Cultural review:** Standard.
- **Landmark:** Mount Fuji (natural — the story ends on its summit).

**M4 `herd-boy-and-weaving-maiden` — The Herd Boy and the Weaving Maiden**
- **Region:** Chinese — China (the Qixi festival story).
- **Source:** Richard Wilhelm (ed.), *The Chinese Fairy Book*, trans. Frederick H. Martens, 1921 (story XVI). Gutenberg #29939, https://www.gutenberg.org/ebooks/29939 (verified). Wilhelm died 1930, Martens 1932.
- **Geography:** the night sky as geography: the Milky Way ("Silver River") and the stars Vega and Altair, visible worldwide.
- **Culture:** the Qixi festival on the seventh day of the seventh lunar month; silk weaving; the same story is celebrated in Japan (Tanabata) and Korea (Chilseok).
- **Moral:** love needs patience; do your work as well as follow your heart.
- **Cultural review:** Standard.
- **Landmark:** Golden Gate Bridge (framed, world link — a bridge of birds, a bridge of steel).

**M5 `iktomi-and-the-muskrat` — Iktomi and the Muskrat**
- **Region:** Native American / First Nations — **Dakota** (Yankton), northern Great Plains.
- **Source:** Zitkala-Ša (Gertrude Simmons Bonnin, Yankton Dakota), *Old Indian Legends*, 1901. Gutenberg #338, https://www.gutenberg.org/ebooks/338 (verified). The author died 1938; public domain in life + 70 countries too.
- **Geography:** the Great Plains: lakes, grassland, the Missouri River country.
- **Culture:** Iktomi the trickster teaches by doing things wrong; sharing food with a guest is the Dakota way. The book was written by a Dakota woman to share her people's stories with all children.
- **Moral:** share what you have; greed loses the whole pot.
- **Cultural review:** **Required** — Indigenous story. Some Dakota and Lakota families tell Iktomi stories only in winter; a Dakota consultant must advise whether and how we publish it (Example (not a decision): a card saying when these stories are traditionally told).
- **Landmark:** none, by design (§6.4). Mount Rushmore is excluded: it is carved into the Black Hills, which are sacred to the Lakota and Dakota.
- **Notes:** the 1901 title word "Indian" stays only in the source citation.

**M6 `long-day-at-fish-camp` — The Long Day at Fish Camp** *(working title)*
- **Region:** Arctic — **Yup'ik**, Kuskokwim River, south-west Alaska, present day.
- **Source:** **Original story written by us (Omramo).**
- **Premise:** in the summer of the midnight sun a boy catches his first salmon at his family's fish camp and wants to keep it. His grandmother tells him where a first catch goes. He carries it to an elder down the river, and comes home with something better than a fish.
- **Geography:** Alaska's river deltas; the midnight sun; salmon swimming upriver; summer on the tundra (no snow — on purpose).
- **Culture:** fish camp; drying salmon on racks; giving away your first catch; wasting nothing. Card: Yup'ik families did not live in snow houses — their winter homes were built of sod and driftwood.
- **Moral:** the best part of having is giving; take only what you will use.
- **Cultural review:** **Required** — Indigenous setting; Yup'ik consultant for names, Yugtun words and customs; ideally co-written (CQ4).
- **Landmark:** none, by design (§6.4).

**M7 `sadko` — Sadko**
- **Region:** Russian — **Novgorod**, north-west Russia (a medieval *bylina*, a sung story).
- **Source:** Arthur Ransome, *Old Peter's Russian Tales*, 1916. Gutenberg #16981, https://www.gutenberg.org/ebooks/16981 (verified). **Ransome died 1967: his wording is protected in life + 70 countries until 2038.** We retell from the traditional bylina; legal check needed (CQ2).
- **Geography:** Novgorod, Lake Ilmen and the River Volkhov; river and sea trade routes of old Russia.
- **Culture:** the gusli (a harp-like instrument); merchant life in a medieval trading city.
- **Moral:** your gift is worth more than gold, and no palace is better than home.
- **Cultural review:** Standard.
- **Landmarks:** Novgorod Kremlin and Saint Sophia Cathedral (natural); Christ the Redeemer (framed, world link — a loose link, see §6.3).

**M8 `androcles-and-the-lion` — Androcles and the Lion**
- **Region:** European — **Roman** (Rome, Italy; the tale is set in the Roman Empire).
- **Source:** Joseph Jacobs, *The Fables of Aesop*, 1894. Gutenberg #28, https://www.gutenberg.org/ebooks/28 (verified). Also Jacobs, *Europa's Fairy Book*, 1916, Gutenberg #26019 (verified).
- **Geography:** the Roman Empire around the Mediterranean; North Africa to Rome.
- **Culture:** Rome's arenas; slavery in the ancient world, said plainly and briefly; an old story first written down by the Roman writer Aulus Gellius.
- **Moral:** a kindness is remembered — by people and by animals.
- **Cultural review:** Standard.
- **Landmarks:** Colosseum (framed — the oldest version sets the scene in Rome's Circus Maximus, about 40 years before the Colosseum opened); Temple of Artemis at Ephesus (framed, map moment, lost wonder).

**M9 `horse-and-the-olive` — The Horse and the Olive**
- **Region:** European — **ancient Greek** (Athens).
- **Source:** James Baldwin, *Old Greek Stories*, 1895. Gutenberg #11582, https://www.gutenberg.org/ebooks/11582 (verified). Baldwin died 1925.
- **Geography:** Athens and the rocky hill of the Acropolis; why olive trees suit dry Greek hills.
- **Culture:** how Athens got its name; the olive in Greek life (food, oil, light); Greek gods as ancient stories, told as "the Greeks said".
- **Moral:** the most useful gift beats the most impressive one; peace feeds more people than war.
- **Cultural review:** Standard.
- **Landmarks:** Parthenon (natural, with a short "built later" note — the contest is carved on the temple); Statue of Zeus at Olympia (framed, lost wonder — same sculptor).

**M10 `anansi-wisdom` — How Wisdom Became the Property of the Human Race** *(prepared)*
- **Region:** African — **Akan (Asante and Fante)**, Ghana.
- **Source:** W. H. Barker and Cecilia Sinclair, *West African Folk-Tales*, 1917. Gutenberg #66923, https://www.gutenberg.org/ebooks/66923 (verified earlier). Authors' death years not verified.
- **Geography:** the forests of southern Ghana; West Africa on the map.
- **Culture:** Anansi the spider and *Anansesem* (spider stories); adinkra symbols and kente cloth; Anansi stories crossed the Atlantic to the Caribbean and the Americas (said gently: carried by people who were taken there).
- **Moral:** no one can keep all the wisdom; even a child can teach a wise grown-up.
- **Cultural review:** **Required** — living oral tradition; Akan reader for the story and for every kente/adinkra drawing (already listed as a risk in the PRD).
- **Landmark:** Asante Traditional Buildings near Kumasi (natural).
- **Notes:** Barker's book has colonial-era commentary outside the tale; none of it is used.

**M11 `sindbad-second-voyage` — Sindbad's Second Voyage**
- **Region:** Persian / Arabian — **Arabic** (*The Thousand and One Nights*; Baghdad and Basra, Iraq, and the Indian Ocean).
- **Source:** Andrew Lang, *The Arabian Nights Entertainments*, 1898. Gutenberg #128, https://www.gutenberg.org/ebooks/128 (verified). Lang died 1912.
- **Geography:** Baghdad on the Tigris, the port of Basra, the Gulf and the Indian Ocean; monsoon winds that carried sailing ships (dhows).
- **Culture:** the golden age of Baghdad; merchants and sailors; the *Nights* as a collection gathered over centuries from Arabic, Persian and Indian tales.
- **Moral:** keep your wits when you are alone and afraid; and notice that Sindbad is always glad to get home.
- **Cultural review:** Standard. Lang's text has dated words for the people Sindbad meets; ours does not.
- **Landmarks:** Hanging Gardens of Babylon (framed, map moment, unproven wonder); Burj Khalifa (framed, "then and now").

### 3.3 Advanced tier (10)

**A1 `savitri-and-satyavan` — Savitri and Satyavan**
- **Region:** Indian — ancient India (a story inside the *Mahabharata*).
- **Source:** Donald A. Mackenzie, *Indian Myth and Legend*, 1913. Gutenberg #47228, https://www.gutenberg.org/ebooks/47228 (verified). Mackenzie died 1936.
- **Geography:** the forests and kingdoms of ancient India; how India's epics spread across South-East Asia.
- **Culture:** the *Mahabharata*, one of the longest poems in the world; forest hermitages; Savitri is still honoured by many Hindus today.
- **Moral:** courage, faithfulness, and the power of wise words: Savitri wins not by force but by what she says.
- **Cultural review:** **Required** — from a sacred Hindu epic, with the god Yama as a character. A Hindu reviewer decides wording and how Yama is drawn.
- **Landmark:** Angkor Wat (framed, world link — scenes from this epic are carved on its walls).
- **Notes:** old retellings praise Savitri as an "ideal wife"; ours shows her choice, courage and wit. Death is central to the story, handled calmly.

**A2 `eloquent-peasant` — The Eloquent Peasant**
- **Region:** Egyptian — ancient Egypt (set about 4,000 years ago; from the Wadi Natrun oasis to the city of Herakleopolis).
- **Source:** Petrie, *Egyptian Tales, First Series*, 1895 ("The Peasant and the Workman"). Gutenberg #7386 (verified).
- **Geography:** oasis and desert edge versus the green Nile valley; donkey caravans carrying salt and goods.
- **Culture:** *ma'at* — the Egyptian idea of truth and fairness; scribes writing speeches on papyrus; judges and officials.
- **Moral:** speak up when you are wronged — clearly, and more than once; those with power must be fair.
- **Cultural review:** Standard (Egyptologist accuracy read).
- **Landmark:** Bibliotheca Alexandrina (framed, "then and now" — from papyrus rolls to a modern library).
- **Notes:** nine speeches become three in our retelling.

**A3 `urashima-taro` — The Story of Urashima Taro, the Fisher Lad** *(prepared)*
- **Region:** Japanese — Japan (Tango coast, Kyoto Prefecture; told for over 1,200 years).
- **Source:** Ozaki, *Japanese Fairy Tales*, 1908 ed. Gutenberg #4018 (verified earlier).
- **Geography:** the Sea of Japan coast; fishing villages; Japan as islands.
- **Culture:** the Dragon Palace under the sea (Ryūgū-jō); the four seasons seen at once; a tale known to every Japanese child.
- **Moral:** kindness is rewarded; a promise matters; time cannot be taken back.
- **Cultural review:** Standard.
- **Landmark:** Tokyo Skytree (framed, "then and now" — what Urashima would find if he came home today).
- **Notes:** the death ending and the tobacco and sake passages are already open (PRD Q5).

**A4 `ballad-of-mulan` — The Ballad of Mulan**
- **Region:** Chinese — northern China (Northern Wei period, about 1,500 years ago; the Yellow River and the northern frontier).
- **Source:** the anonymous *Ballad of Mulan* (5th–6th century, kept in the 12th-century anthology *Yuefu Shiji*) — an ancient work, public domain everywhere. We retell from the ballad itself. No specific pre-1931 English translation is cited yet (**unverified**; not found on Gutenberg in English).
- **Geography:** the Yellow River, the northern grasslands and mountains, the frontier.
- **Culture:** weaving at home; duty to parents; a poem that people have sung for 1,500 years.
- **Moral:** courage and love of family; what you can do does not depend on being a boy or a girl.
- **Cultural review:** Standard.
- **Landmarks:** Great Wall of China (framed lightly — frontier walls existed in Mulan's time, but the stone wall visitors see today was built about 1,000 years later); Forbidden City (framed, "then and now").
- **Notes:** nothing is taken from any film version; the name and title need a trademark check (CQ2). War is present but not graphic.

**A5 `the-two-sisters` — The Two Sisters**
- **Region:** Native American / First Nations — **Sḵwx̱wú7mesh (Squamish) Nation**, Burrard Inlet and the North Shore mountains, Vancouver, British Columbia, Canada.
- **Source:** E. Pauline Johnson (Tekahionwake, Mohawk), *Legends of Vancouver*, 1911, as told to her by Chief Joe Capilano (Sahp-luk). Gutenberg #3478, https://www.gutenberg.org/ebooks/3478 (verified). Johnson died 1913.
- **Geography:** the Pacific coast of Canada; mountains that rise straight from the sea; salmon rivers.
- **Culture:** the two peaks above Vancouver are, to the Squamish, the Twin Sisters (Ch'ich'iyúy Elx̱wíkn) who brought peace between warring peoples; a great feast as the way to make peace. Settlers later named the peaks "The Lions".
- **Moral:** peace takes more courage than war, and the young can ask for it.
- **Cultural review:** **Required** — a First Nations story about a named, living landscape, and it touches a coming-of-age custom. The Squamish Nation should be asked directly whether and how it may be retold. If the answer is no, we replace it with an original (CQ3).
- **Landmark:** Lions Gate Bridge (framed, present-day narrator).
- **Notes:** Johnson's 1911 prose is romantic and uses trade-jargon terms ("Sagalie Tyee"); our retelling follows the Nation's guidance on names.

**A6 `woman-who-raised-a-bear` — The Woman Who Raised a Bear**
- **Region:** Arctic — **Kalaallit (Greenlandic Inuit)**, Greenland.
- **Source:** Knud Rasmussen, *Eskimo Folk-Tales*, ed. and trans. W. Worster, 1921 ("The Woman Who Had a Bear as a Foster-Son"). Gutenberg #28932, https://www.gutenberg.org/ebooks/28932 (verified). Rasmussen died 1933; Worster's death year not verified.
- **Geography:** Greenland, the world's largest island; sea ice, icebergs and polar bears.
- **Culture:** life in a small hunting settlement where everyone shares; Rasmussen was himself part Greenlandic and wrote the stories down from Greenlandic tellers.
- **Moral:** loving someone can mean letting them go.
- **Cultural review:** **Required** — Indigenous story; Greenlandic reviewer for the telling and the art.
- **Landmark:** Ilulissat Icefjord (natural landmark; framed lightly as a map moment).
- **Notes:** the source title's word is not used in the app. Hunting is part of daily life in the story; shown plainly, without gore.

**A7 `firebird-and-horse-of-power` — The Fire-Bird and the Horse of Power**
- **Region:** Russian — Russian wonder tale (from the Afanasyev collection).
- **Source:** Ransome, *Old Peter's Russian Tales*, 1916 ("The Fire-Bird, the Horse of Power, and the Princess Vasilissa"). Gutenberg #16981 (verified). Same rights flag as M7 (Ransome d. 1967); the underlying tale was collected by Alexander Afanasyev (d. 1871).
- **Geography:** the great northern forest (taiga) and the edge of the sea; the size of Russia.
- **Culture:** the Fire-Bird in Russian art and music; the tsar; horses as wise helpers in Russian tales.
- **Moral:** listen to a good friend's warning; every choice has a cost, and courage sees it through.
- **Cultural review:** Standard.
- **Landmark:** Kizhi Pogost (framed, map moment — wooden churches built without nails).

**A8 `daedalus-and-icarus` — Daedalus and Icarus**
- **Region:** European — **ancient Greek** (Athens and Crete).
- **Source:** Baldwin, *Old Greek Stories*, 1895 ("The Wonderful Artisan"). Gutenberg #11582 (verified).
- **Geography:** Crete and the Aegean islands; the Icarian Sea is named in the story.
- **Culture:** Greek myths of invention; the Labyrinth; real Bronze Age palaces found on Crete.
- **Moral:** great skill needs good judgement; listen when someone who loves you warns you.
- **Cultural review:** Standard.
- **Landmarks:** Palace of Knossos (natural, with a note that the myth and the ruin were linked later); Eiffel Tower (framed, "then and now" — people kept reaching for the sky).
- **Notes:** the death of Daedalus's nephew in the source is cut down to a line or left out (editor's call).

**A9 `the-griots-apprentice` — The Griot's Apprentice** *(working title)*
- **Region:** African — **Mande (Mandinka/Malinke)**, the Mali Empire on the River Niger, about 700 years ago.
- **Source:** **Original story written by us (Omramo).** The Sunjata epic was considered and not used: it is a living tradition owned by its griots, and I found no clean public-domain English edition (the well-known 1960 version is in copyright).
- **Premise:** a girl learning to be a jeli (griot) must sing the history of a rich merchant's family at a feast in Djenné. He pays her master to leave out a shameful part. She has to decide what a keeper of memory owes to the truth.
- **Geography:** the Niger's great bend; Djenné and Timbuktu; the Sahara trade in salt and gold.
- **Culture:** griots as keepers of history in song; the kora and balafon; mud-brick building; the libraries of Timbuktu.
- **Moral:** tell the truth even when a powerful person would rather you did not.
- **Cultural review:** **Required** — living tradition; a Mande cultural consultant, ideally a griot family member, and ideally a co-author (CQ4).
- **Landmark:** Great Mosque of Djenné (framed, "then and now" — the building seen today dates from 1907).

**A10 `zal-and-the-simurgh` — Zal and the Simurgh**
- **Region:** Persian / Arabian — **Persian** (Iran; from Ferdowsi's *Shahnameh*, finished about 1010).
- **Source:** Elizabeth D. Renninger, *The Story of Rustem, and Other Persian Hero Tales from Firdusi*, 1909 ("Zal of the White Hair"). Gutenberg #57827, https://www.gutenberg.org/ebooks/57827 (verified). Renninger's death year not verified; the *Shahnameh* itself is public domain everywhere.
- **Geography:** the Alborz mountains and Mount Damavand, Iran's highest peak.
- **Culture:** the *Shahnameh*, Iran's national epic; the Simurgh, a wise giant bird; Nowruz and Persian storytelling.
- **Moral:** being different is not a fault; a parent can be wrong, say sorry, and be forgiven.
- **Cultural review:** Standard.
- **Landmarks:** Persepolis (framed, map moment); Mausoleum at Halicarnassus (framed, map moment, lost wonder).
- **Notes:** the baby is left on the mountain because of his white hair; told with care, and with the father's regret made clear.

### 3.4 Considered and not used

| Story | Why not |
|---|---|
| *The Magic Paintbrush* (Ma Liang) | Written in the 1950s by Hong Xuntao; in copyright. |
| *Sunjata* epic (Mali) | Living griot tradition; no clean public-domain English source found. |
| Sedna, Raven creation stories, other origin and ceremony narratives | Sacred or restricted; outside our rule. |
| *Aladdin*, *Ali Baba* | Not in the oldest Arabic manuscripts; *Ali Baba* is violent; strong film associations. Possible later. |
| *The Stonecutter* ("Japanese") | Its Japanese origin is doubtful. |
| *The Monkey, the Shark and the Washerman's Donkey* (Swahili; Bateman, *Zanzibar Tales*, 1901, Gutenberg #37472, verified) | Same plot as L1. Kept as a reserve East African story. |

---

## 4. How geography, culture and moral education appear in the app

All of this uses components in the locked v2 design: the origin chip and map pin, tap-to-see cards (one picture, one line, one note, "Back to my line"), character cards, and the parent view. **No new screen is invented.** Additions are listed in §4.4 as proposals.

| Pillar | Where it appears (existing design) |
|---|---|
| **Geography** | Origin chip in the reader ("Akan · Ghana"); the pin on the story map; tap-to-see cards of kind *place*; landmark cards (§6), whose note box acts as the "where in the world" card. |
| **Culture** | The culture note on a tap-to-see card ("FROM JAPAN"); character-card traits and description; objects and customs as tap words. |
| **Moral** | Carried by the story itself, in what characters do and what follows. It is never printed as "Moral:" and never quizzed. The moral lesson and a reflection question are stored with the story (ARCHITECTURE §6.3) for the proposals in §4.4. |

Rules for every card: tap-to-see, never a lecture; one line the child reads, one note; no onward links; the child always returns to their line. No points, quizzes or scores for education content (PRD governing rule).

### 4.1 Low tier

- **Geography:** one *place* tap word per story, usually on the first page ("river bank"). Card line of about 10–14 words. The note names the country and one thing to picture ("India is a land of great rivers").
- **Culture:** one object or custom per story (Example (not a decision): "snow knife", "rice cake"). One short sentence.
- **Moral:** shown through a clear cause and effect. The last page ends on the outcome, not a sermon.
- **Landmark:** at most one or two per story; the Low fact card is one concrete, visual fact ("It is made of white stone").

### 4.2 Medium tier

- **Geography:** a place card plus one "how people live there" card (river trade, seasons, a festival's time of year). The note may compare with somewhere else.
- **Culture:** two or three culture notes across the story; character cards carry a cultural detail in a trait pill (Example (not a decision): "Plays the gusli").
- **Moral:** a bigger idea with two sides; the story leaves a little for the child to work out.
- **Landmark:** the Medium fact card adds when and who ("built about 4,500 years ago for King Khufu").

### 4.3 Advanced tier

- **Geography:** routes and scale (trade roads, empires, how far a story travelled). Notes may carry dates and distances.
- **Culture:** ideas, not only objects (*ma'at*, the griot's duty, a festival's meaning); notes may say honestly what is uncertain or disputed.
- **Moral:** real dilemmas and costs; endings can be bittersweet.
- **Landmark:** the Advanced fact card adds how we know, or what is unknown ("No one has found the Hanging Gardens. They may never have stood in Babylon").

### 4.4 Proposed additions (not in the locked design — open question CQ6)

| Idea | Priority | Needs |
|---|---|---|
| A **reflection question** on the story-finished moment ("What would you have done with the fish?") — one line, no answer box, no score | P1 | Design gap G3 is undesigned; child-facing wording review |
| **"Talk about it"** in the parent view: for each finished story, its origin, moral in one line, and the reflection question for a parent to ask | P1 | A new card on screen 08; must not add any time metric |
| **Landmark pins** on the story map, lit when the child has seen the card | P1 | Extension of map card L2 |
| **"Wonders you have seen"** row on My shelf, like "Friends you have met" | P2 | My shelf tab is design gap G5 |
| A story-opening "where in the world" moment | P2 | Design gap G9 |

---

## 5. Landmarks: principles

- **Tap-to-see moments, not lectures.** A landmark is a tap word in the story text that opens the standard tap-to-see card on the facing pane. The landmark's facts come from a **shared landmark catalog**, written once in three wordings (Low / Medium / Advanced), so the same landmark reads correctly in any tier.
- **Honest history.** Six of the seven Ancient Wonders no longer stand. They are drawn as **reconstructions** and labelled so ("An artist's idea — this wonder is gone"). The Hanging Gardens may never have existed in Babylon; we say that.
- **Lists.** *Ancient Seven* = the classical Greek list. *New7Wonders* = the winners of a 2007 public poll run by a private foundation (not UNESCO); the Great Pyramid holds honorary status. *Other* = our choice.
- **Eras** (assumption): ancient = before 500 CE; medieval = 500–1500; early-modern = 1500–1800; modern = 1800–1945; contemporary = after 1945. Natural landmarks are marked *natural*.
- **Anachronism rule.** A story may show a landmark that does not belong to its time or place only through a named **framing device**:

| Device | Meaning | Card label, Example (not a decision) |
|---|---|---|
| `thenAndNow` | Same land, a later time | "LONG AFTER THIS STORY" |
| `mapMoment` | A child-reader map moment: step out of the story to the map; a different place in the same region | "FIND IT ON THE MAP" |
| `worldLink` | The same idea somewhere else in the world, outside the story's region | "FAR AWAY, THE SAME IDEA" |
| `presentDayNarrator` | Our retelling has a narrator standing in the present day | (in the story text) |

- A framed landmark never appears in the story's scene art as if the characters could see it; it appears only on its card.
- **Limits** (assumption): at most two landmarks per story; a story may have none.
- **Religious buildings** (Hagia Sophia, Saint Basil's, Saint Sophia of Novgorod, Kizhi, Angkor Wat, the Great Mosque of Djenné, Christ the Redeemer) are presented as architecture and history, with respect and without religious teaching (CQ9).

### 5.1 Landmark table (37)

Coordinates are rounded (latitude, longitude; negative = south or west) and, like every date here, must be fact-checked in content production.

**Seven Wonders of the Ancient World**

| id | Name | Era | Built | Country | Coordinates | One-line fact | List |
|---|---|---|---|---|---|---|---|
| `great-pyramid-giza` | Great Pyramid of Giza | ancient | c. 2600–2560 BCE | Egypt | 29.979, 31.134 | The only Ancient Wonder still standing; built for King Khufu. | Ancient Seven (New7Wonders honorary) |
| `hanging-gardens-babylon` | Hanging Gardens of Babylon | ancient | said c. 600 BCE | Iraq (traditional site) | 32.54, 44.42 | No trace has been found; they may be a legend, or may have been in another city. **Reconstruction.** | Ancient Seven |
| `statue-of-zeus-olympia` | Statue of Zeus at Olympia | ancient | c. 435 BCE | Greece | 37.638, 21.630 | A seated gold-and-ivory statue about 12 m tall, by Phidias; lost over 1,500 years ago. **Reconstruction.** | Ancient Seven |
| `temple-of-artemis-ephesus` | Temple of Artemis at Ephesus | ancient | c. 550 BCE; rebuilt from c. 323 BCE | Türkiye | 37.950, 27.364 | Once ringed by more than 100 columns; one rebuilt column stands today. **Reconstruction.** | Ancient Seven |
| `mausoleum-halicarnassus` | Mausoleum at Halicarnassus | ancient | c. 353–350 BCE | Türkiye (Bodrum) | 37.038, 27.424 | The tomb of Mausolus gave us the word "mausoleum"; earthquakes brought it down. **Reconstruction.** | Ancient Seven |
| `colossus-of-rhodes` | Colossus of Rhodes | ancient | c. 292–280 BCE | Greece | 36.451, 28.226 | A bronze sun god about 33 m tall; an earthquake felled it after only about 54 years. **Reconstruction.** | Ancient Seven |
| `lighthouse-of-alexandria` | Lighthouse (Pharos) of Alexandria | ancient | c. 280 BCE | Egypt | 31.214, 29.885 | Guided ships for about 1,500 years before earthquakes ruined it. **Reconstruction.** | Ancient Seven |

**New7Wonders (2007 poll)**

| id | Name | Era | Built | Country | Coordinates | One-line fact | List |
|---|---|---|---|---|---|---|---|
| `great-wall-of-china` | Great Wall of China | ancient to early-modern | 7th c. BCE – 17th c. CE; most of today's wall 1368–1644 | China | 40.36, 116.02 (Badaling) | Many walls built over 2,000 years; it cannot be seen from the Moon with the naked eye. | New7Wonders |
| `petra` | Petra | ancient | c. 4th c. BCE – 1st c. CE | Jordan | 30.329, 35.444 | A caravan city carved into rose-red rock by the Nabataeans. | New7Wonders |
| `christ-the-redeemer` | Christ the Redeemer | modern | 1922–1931 | Brazil | −22.952, −43.211 | A 30 m statue on a mountain above Rio de Janeiro. | New7Wonders |
| `machu-picchu` | Machu Picchu | medieval | c. 1450 | Peru | −13.163, −72.545 | An Inca town built on a mountain ridge, stones fitted without mortar. | New7Wonders |
| `chichen-itza` | Chichén Itzá | medieval | c. 600–1200 CE | Mexico | 20.683, −88.569 | A Maya city; its step pyramid, El Castillo, works like a calendar in stone. | New7Wonders |
| `colosseum` | Colosseum | ancient | 70–80 CE | Italy | 41.890, 12.492 | Rome's great arena held about 50,000 people. | New7Wonders |
| `taj-mahal` | Taj Mahal | early-modern | 1632 – c. 1653 | India | 27.175, 78.042 | A white marble tomb built by the emperor Shah Jahan for his wife Mumtaz Mahal. | New7Wonders |

**Other landmarks (our choice)**

| id | Name | Era | Built | Country | Coordinates | One-line fact | List |
|---|---|---|---|---|---|---|---|
| `palace-of-knossos` | Palace of Knossos | ancient | c. 1900–1400 BCE | Greece (Crete) | 35.298, 25.163 | A Bronze Age palace with so many rooms it may have inspired the Labyrinth story. | Other |
| `persepolis` | Persepolis | ancient | begun c. 518 BCE | Iran | 29.935, 52.891 | The ceremonial city of the Persian kings; Iranians call it Takht-e Jamshid. | Other |
| `parthenon` | Parthenon | ancient | 447–432 BCE | Greece | 37.972, 23.727 | Athena's temple on the Acropolis of Athens. | Other |
| `hagia-sophia` | Hagia Sophia | medieval | 532–537 CE | Türkiye | 41.009, 28.980 | Its great dome was the wonder of its age; it has been a church, a mosque and a museum. | Other |
| `novgorod-kremlin` | Novgorod Kremlin and Saint Sophia Cathedral | medieval | cathedral 1045–1050 | Russia | 58.522, 31.276 | One of Russia's oldest stone buildings, in a city grown rich on trade. | Other |
| `angkor-wat` | Angkor Wat | medieval | early–mid 12th c. | Cambodia | 13.412, 103.867 | The largest religious monument in the world; Indian epics are carved along its walls. | Other |
| `bremen-town-hall-roland` | Bremen Town Hall and Roland | medieval | 1404–1410 | Germany | 53.076, 8.807 | A stone knight has guarded Bremen's market square for over 600 years. | Other |
| `forbidden-city` | Forbidden City | medieval | 1406–1420 | China | 39.916, 116.397 | The emperors' palace in Beijing, with hundreds of buildings. | Other |
| `saint-basils-cathedral` | Saint Basil's Cathedral | early-modern | 1555–1561 | Russia | 55.752, 37.623 | Its bright onion domes stand on Red Square in Moscow. | Other |
| `himeji-castle` | Himeji Castle | early-modern | 1601–1609 | Japan | 34.839, 134.694 | Called the White Heron Castle for its white walls and wing-like roofs. | Other |
| `kizhi-pogost` | Kizhi Pogost | early-modern | 1714 (main church) | Russia | 62.068, 35.224 | Wooden churches with 22 domes, on an island in Lake Onega. | Other |
| `asante-traditional-buildings` | Asante Traditional Buildings | early-modern to modern | surviving buildings 19th c. (to verify) | Ghana | about 6.7, −1.6 (near Kumasi; to verify) | Earth-walled buildings decorated with adinkra-style symbols. | Other |
| `statue-of-liberty` | Statue of Liberty | modern | dedicated 1886 | USA | 40.689, −74.045 | A gift from the people of France; a poem calls her "The New Colossus". | Other |
| `eiffel-tower` | Eiffel Tower | modern | 1887–1889 | France | 48.858, 2.294 | About 330 m of iron; the tallest structure in the world when it opened. | Other |
| `great-mosque-of-djenne` | Great Mosque of Djenné | modern (on a medieval site) | present building 1907 | Mali | 13.905, −4.555 | The largest mud-brick building in the world; the town re-plasters it every year. | Other |
| `golden-gate-bridge` | Golden Gate Bridge | modern | 1933–1937 | USA | 37.820, −122.478 | Painted "international orange" so ships can see it in fog. | Other |
| `lions-gate-bridge` | Lions Gate Bridge | modern | 1937–1938 | Canada | 49.315, −123.139 | Named for two mountain peaks the Squamish call the Twin Sisters. | Other |
| `sydney-opera-house` | Sydney Opera House | contemporary | 1959–1973 | Australia | −33.857, 151.215 | Its roof looks like sails on the harbour. | Other |
| `bibliotheca-alexandrina` | Bibliotheca Alexandrina | contemporary | opened 2002 | Egypt | 31.209, 29.909 | A modern library built near where the great ancient library once stood. | Other |
| `burj-khalifa` | Burj Khalifa | contemporary | 2004–2010 | United Arab Emirates | 25.197, 55.274 | At 828 m, the tallest building in the world. | Other |
| `tokyo-skytree` | Tokyo Skytree | contemporary | 2008–2012 | Japan | 35.710, 139.811 | A 634 m tower, built to stay standing in earthquakes. | Other |
| `mount-fuji` | Mount Fuji | natural | — (last eruption 1707) | Japan | 35.361, 138.727 | Japan's highest mountain, 3,776 m, and a sleeping volcano. | Other (natural) |
| `ilulissat-icefjord` | Ilulissat Icefjord | natural | — | Greenland | about 69.1, −49.5 | A fjord packed with icebergs breaking off one of the world's fastest glaciers. | Other (natural) |

By era: ancient 13 · medieval 7 · early-modern 5 · modern 6 · contemporary 4 · natural 2. (The Great Wall is counted as ancient; the Great Mosque of Djenné as modern.)

**Considered and left out:** Mount Rushmore (carved into land sacred to the Lakota and Dakota); Mesa Verde, Cahokia and other Indigenous sites (must not be attached to another nation's story; revisit with consultants); Stonehenge and Great Zimbabwe (no story yet — reserve list).

### 5.2 Example of per-tier fact cards — Example (not a decision), unreviewed

| Tier | Taj Mahal |
|---|---|
| Low | "A white stone palace for remembering someone loved." |
| Medium | "An emperor built it about 400 years ago for his wife, Mumtaz Mahal. It took about 20 years." |
| Advanced | "Shah Jahan's tomb for Mumtaz Mahal, finished about 1653. Some 20,000 workers built it. The marble seems to change colour through the day." |

---

## 6. Story → landmark map

**Fit:** *Natural* = belongs to the story's place and time (no device needed). *Framed* = needs the named device. *Loose* = framed, and the link is thin — recommended for editorial review and possibly dropping (CQ7).

### 6.1 Low tier

| Story | Landmark | Fit / device | How it is woven in |
|---|---|---|---|
| Monkey and the Crocodile | Taj Mahal | **Framed — `thenAndNow`** ⚠ anachronism: about 2,000 years later, on a different river | Tap word "river". Card: "Rivers like this one cross northern India. Long after this story, beside one of them, people built the Taj Mahal." |
| Shipwrecked Sailor | Lighthouse of Alexandria | **Framed — `thenAndNow`** ⚠ about 1,700 years later; lost wonder | Tap on "harbour" when the sailor comes home: later Egyptian sailors had a great light to guide them. |
| Shipwrecked Sailor | Sydney Opera House | **Framed — `worldLink`** ⚠ about 4,000 years later; outside the 10 regions (Australia) | Tap on "sail": far away and long after, a building was shaped like sails. *Loose.* |
| Tongue-Cut Sparrow | Himeji Castle | **Framed — `thenAndNow`** ⚠ folk-tale time versus 1609 | Tap on a bird word: a castle named for a white heron. |
| Old Man Who Moved the Mountains | Great Wall of China | **Framed — `mapMoment`** | Tap on "basket by basket": another great work built a little at a time, by many generations. |
| Old Man Who Moved the Mountains | Machu Picchu | **Framed — `worldLink`** ⚠ outside the 10 regions (Peru) | Tap on "mountain": across the world, people shaped a mountain top into a town. |
| Why the Possum's Tail Is Bare | — | none, by design | See §6.4. |
| The Snow House | Hagia Sophia | **Framed — `worldLink`** ⚠ outside the 10 regions (Türkiye) | Tap on "dome": a dome of snow and a dome of stone both stand because each block leans on the next. Celebrates Inuit engineering. |
| Peasant and the Bear | Saint Basil's Cathedral | **Framed — `thenAndNow`** ⚠ folk-tale time versus 1561 | Tap on "turnip" or "onion": roofs shaped like onions. |
| Bremen Town Musicians | Bremen Town Hall and Roland | **Natural** | Tap on "Bremen": the city they are walking to (and never reach). |
| North Wind and the Sun | Colossus of Rhodes | **Framed — `thenAndNow`**; lost wonder | Tap on "Sun": Greeks on the island of Rhodes built a giant statue of the sun god. |
| North Wind and the Sun | Statue of Liberty | **Framed — `worldLink`** ⚠ about 2,400 years later; USA | Same card family: a later giant statue at a harbour, called "The New Colossus". *Loose.* |
| Why the Sun and the Moon Live in the Sky | — | none at launch | See §6.4. |
| Lion and the Hare | Petra | **Framed — `mapMoment`** | Tap on "caravan" in a short opening line about how the story travelled: caravans rested in cities like Petra. |

Low spread: ancient (Lighthouse, Colossus, Petra, Great Wall), medieval (Hagia Sophia, Machu Picchu, Bremen), early-modern (Taj Mahal, Himeji, Saint Basil's), modern (Statue of Liberty), contemporary (Sydney Opera House).

### 6.2 Medium tier

| Story | Landmark | Fit / device | How it is woven in |
|---|---|---|---|
| Tiger, the Brahman and the Jackal | — | none at launch | See §6.4. |
| King Khufu and the Magician | Great Pyramid of Giza | **Natural** | Khufu is its builder; in the tale he wants secret plans for his own tomb. |
| King Khufu and the Magician | Chichén Itzá | **Framed — `worldLink`** ⚠ about 3,500 years later; outside the 10 regions (Mexico) | Tap on "pyramid": the Maya, a different people far away, also built pyramids. The card says the two are not connected. |
| Bamboo-Cutter and the Moon-Child | Mount Fuji | **Natural** | The story ends with smoke rising from the summit. |
| Herd Boy and the Weaving Maiden | Golden Gate Bridge | **Framed — `worldLink`** ⚠ modern; USA | Tap on "bridge": a bridge of birds across the sky, a bridge of steel across the sea. *Loose.* |
| Iktomi and the Muskrat | — | none, by design | See §6.4. |
| Long Day at Fish Camp | — | none, by design | See §6.4. |
| Sadko | Novgorod Kremlin and Saint Sophia | **Natural** | Sadko's own city. |
| Sadko | Christ the Redeemer | **Framed — `worldLink`** ⚠ 1931; outside the 10 regions (Brazil) | Tap on "harbour": famous harbours have famous landmarks. *Loose — weakest link in the plan.* |
| Androcles and the Lion | Colosseum | **Framed — `thenAndNow`** ⚠ mild: the tale is set about 40 years before it opened | Tap on "arena": soon after this story, Rome built its greatest arena. |
| Androcles and the Lion | Temple of Artemis at Ephesus | **Framed — `mapMoment`**; lost wonder; in Türkiye (inside the Roman Empire of the story) | Tap on "empire": a wonder that stood in another Roman city. |
| Horse and the Olive | Parthenon | **Natural**, with a "built later" note | Athena's temple on the hill where the contest is set; the contest is carved on it. |
| Horse and the Olive | Statue of Zeus at Olympia | **Framed — `thenAndNow`**; lost wonder | Tap on "Zeus" (or "Jupiter" in the old source): the sculptor of Athena's statue also made this one. |
| How Wisdom Became the Property of the Human Race | Asante Traditional Buildings | **Natural** (same people and place; folk-tale time) | Tap on "village" or "house": walls decorated with symbols that carry sayings. |
| Sindbad's Second Voyage | Hanging Gardens of Babylon | **Framed — `mapMoment`** ⚠ about 1,400 years earlier, and unproven | Tap on "Baghdad": near here, people said, a king once built gardens in the sky. |
| Sindbad's Second Voyage | Burj Khalifa | **Framed — `thenAndNow`** ⚠ about 1,200 years later | Tap on "the Gulf": Sindbad's sea today. |

Medium spread: ancient (Great Pyramid, Hanging Gardens, Temple of Artemis, Statue of Zeus, Colosseum, Parthenon), medieval (Chichén Itzá, Novgorod), early-modern to modern (Asante buildings), modern (Golden Gate Bridge, Christ the Redeemer), contemporary (Burj Khalifa), natural (Mount Fuji).

### 6.3 Advanced tier

| Story | Landmark | Fit / device | How it is woven in |
|---|---|---|---|
| Savitri and Satyavan | Angkor Wat | **Framed — `worldLink`** ⚠ 12th century; outside the 10 regions (Cambodia) | Tap on "the great poem": the epic this story comes from is carved along the walls of a temple far to the east. |
| Eloquent Peasant | Bibliotheca Alexandrina | **Framed — `thenAndNow`** ⚠ about 4,000 years later | Tap on "papyrus": Egypt still keeps words safe; the card also mentions the lost ancient library. |
| Urashima Taro | Tokyo Skytree | **Framed — `thenAndNow`** ⚠ contemporary; different part of Japan | At the moment Urashima returns to a changed world: "If he came home today…" The story's own theme is the framing device. |
| Ballad of Mulan | Great Wall of China | **Framed — `thenAndNow`** ⚠ partial: frontier walls existed; the famous stone wall is about 1,000 years later | Tap on "frontier": the card shows an earth wall of her time and the later stone wall. |
| Ballad of Mulan | Forbidden City | **Framed — `thenAndNow`** ⚠ about 900 years later | Tap on "the emperor's hall": where later emperors held court. |
| The Two Sisters | Lions Gate Bridge | **Framed — `presentDayNarrator`** ⚠ 1938 | Our retelling opens today, on the bridge, looking up at the two peaks; then the old story is told. The card gives both names for the peaks. |
| Woman Who Raised a Bear | Ilulissat Icefjord | **Framed — `mapMoment`** (natural landmark; the tale is not set at this exact place) | Tap on "icebergs". |
| Fire-Bird and the Horse of Power | Kizhi Pogost | **Framed — `mapMoment`** ⚠ folk-tale time versus 1714 | Tap on "wooden": northern builders raised whole churches of wood. |
| Daedalus and Icarus | Palace of Knossos | **Natural**, with a note | The Labyrinth's island; the card says the ruin and the myth were linked later. |
| Daedalus and Icarus | Eiffel Tower | **Framed — `thenAndNow`** ⚠ 1889; France | Tap on "the sky": people kept reaching upward; Eiffel used his tower for experiments on air and flight. |
| The Griot's Apprentice | Great Mosque of Djenné | **Framed — `thenAndNow`** ⚠ mild: a great mosque stood in Djenné in the story's time; today's building is from 1907 | Tap on "the great mosque". |
| Zal and the Simurgh | Persepolis | **Framed — `mapMoment`** | Tap on "the kings of Persia": their stone city, which Iranians name after a king of this same epic. |
| Zal and the Simurgh | Mausoleum at Halicarnassus | **Framed — `mapMoment`**; lost wonder; in Türkiye | Tap on "empire": at its western edge a Persian governor built a tomb so grand it became a Wonder. |

Advanced spread: ancient (Knossos, Persepolis, Mausoleum, Great Wall), medieval (Angkor Wat, Forbidden City), early-modern (Kizhi), modern (Eiffel Tower, Lions Gate Bridge, Great Mosque of Djenné), contemporary (Bibliotheca Alexandrina, Tokyo Skytree), natural (Ilulissat Icefjord).

### 6.4 Stories with no landmark, and why

- **The Cherokee, Dakota and Yup'ik stories have no landmark**, and the Inuit story has none from its own land. (The Squamish story has the Lions Gate Bridge, which stands in Squamish territory.) Monument-building is not how these cultures mark the world; the land itself is the landmark. Attaching another nation's site (Mesa Verde to a Cherokee story) would be exactly the lumping this plan avoids. Their geography is taught through place cards (the Great Smoky Mountains, the Great Plains, the Kuskokwim River).
- *Why the Sun and the Moon Live in the Sky* and *The Tiger, the Brahman and the Jackal* have no honest link at launch. Forcing one would be a lecture.

### 6.5 Landmarks outside the 10 story regions

| Landmark | Country | How it gets in |
|---|---|---|
| Machu Picchu | Peru | `worldLink` in *The Old Man Who Moved the Mountains* |
| Chichén Itzá | Mexico | `worldLink` in *King Khufu and the Magician* |
| Christ the Redeemer | Brazil | `worldLink` in *Sadko* (loose) |
| Sydney Opera House | Australia | `worldLink` in *The Shipwrecked Sailor* (loose) |
| Angkor Wat | Cambodia | `worldLink` in *Savitri and Satyavan* (a real historical link) |
| Hagia Sophia, Temple of Artemis, Mausoleum | Türkiye | `worldLink` / `mapMoment` in the Inuit, Roman and Persian stories |
| Statue of Liberty, Golden Gate Bridge | USA | `worldLink`; the USA is inside the Native American region geographically, but these are not Native landmarks and are never presented as such |

A framing device is a workaround. The better answer for the Latin American and Oceanian landmarks is **stories from those places**. I have not added regions silently; adding **Latin America (Maya, Inca and others)**, **South-East Asia** and **Oceania** is open question CQ5.

### 6.6 Image rights for landmark art

We draw our own illustrations; no photographs are used. Even so, these need a legal check before art is commissioned (CQ8):

| Landmark | Concern to check |
|---|---|
| Eiffel Tower | The tower is public domain; its **night lighting** is claimed as a protected work. Draw it by day. |
| Sydney Opera House | Name and image are trademarks of the Sydney Opera House Trust, with rules for commercial use. |
| Burj Khalifa | The owner asserts rights over the name and image in commercial use. |
| Christ the Redeemer | Rights in the statue's image are claimed by the Archdiocese of Rio; the sculptor died in 1961, so copyright may still run in some countries. |
| Tokyo Skytree | The operator licenses commercial use of the name and image. |
| Golden Gate Bridge, Lions Gate Bridge, Statue of Liberty | Believed clear (public works; the statue is long out of copyright) — confirm names are not restricted marks. |
| Bibliotheca Alexandrina | Recent building; architectural copyright and the rules on depicting buildings differ by country. |
| General | The right to depict public buildings ("freedom of panorama") varies by country and matters for non-US stores. |
| Indigenous designs | Kente and adinkra patterns, Inuit clothing designs and Northwest Coast formline art may be community heritage or individual artists' work; never copied from a living artist; reviewed by consultants. |
| Reconstructions | Our drawings of lost wonders must be our own, not traced from a modern artist's reconstruction. |

---

## 7. Stories flagged for required cultural review (12)

| Story | Community / reviewer needed | Why |
|---|---|---|
| The Monkey and the Crocodile | Buddhist reader | From the Jataka scripture collection |
| Savitri and Satyavan | Hindu reviewer | From the *Mahabharata*; a god is a character |
| The Lion and the Hare | Reviewer familiar with Rumi and Sufi tradition | Direct source is a religious teaching poem (light review) |
| Why the Possum's Tail Is Bare | Cherokee consultant | Indigenous story |
| Iktomi and the Muskrat | Dakota consultant | Indigenous story; possible seasonal telling custom |
| The Two Sisters | Squamish Nation | Indigenous story of a named landscape; coming-of-age custom; permission |
| The Snow House | Inuit consultant (Nunavut) | Indigenous setting; original must be accurate, ideally co-written |
| The Long Day at Fish Camp | Yup'ik consultant | Same |
| The Woman Who Raised a Bear | Greenlandic (Kalaallit) reviewer | Indigenous story |
| Why the Sun and the Moon Live in the Sky | Efik reader | Living oral tradition; colonial-era source |
| How Wisdom Became the Property of the Human Race | Akan reader | Living oral tradition; kente and adinkra art |
| The Griot's Apprentice | Mande consultant, ideally from a griot family | Living tradition; original must be accurate |

All other stories get the standard read. Landmark cards for the Lions Gate Bridge, Asante buildings, the Great Mosque of Djenné and every religious building go through the same reviewers.

---

## 8. Assumptions

1. Fresh Omramo retellings replace verbatim source texts for the launch catalog (changes PRD A5; CQ1). M1 keeps the Babbitt text as a placeholder.
2. Tier assignments follow the existing rule (message and complexity); word counts per tier wait on PRD Q3.
3. Required cultural review blocks release of that story, not of the whole app.
4. At most two landmarks per story; a story may have none.
5. Era boundaries as in §5.
6. "Verified" means the Gutenberg ebook and the story's presence in it were confirmed on 13 Nov 2026. Authors' death dates and all dates, heights and coordinates in §5.1 are from general knowledge and must be fact-checked.
7. Story and landmark ids are working slugs; they become permanent when the first content file ships.

## 9. Open questions (content) — mirrored in PRD §12 as Q22–Q31

- **CQ1 (Q22). Retellings.** Confirm that launch stories are fresh Omramo retellings, replacing "story text unaltered" (PRD A5, DESIGN §8). Who writes and who edits?
- **CQ2 (Q23). Legal.** Rights check for stores outside the US: cited translators still in copyright in life + 70 countries (Ransome, Giles; several death dates unverified); trademark check on titles and names (Mulan, Sindbad); ownership of our originals and commissioned text.
- **CQ3 (Q24). Cultural consultants.** Who finds and pays community reviewers for the 12 flagged stories? Is their sign-off launch-blocking for the story (assumed yes)? If a community declines (for example the Squamish Nation), do we replace the story with an original?
- **CQ4 (Q25). Authors of originals.** May the three originals be co-written with, or commissioned from, Inuit, Yup'ik and Mande writers?
- **CQ5 (Q26). More regions.** Add Latin America, South-East Asia and Oceania so Machu Picchu, Chichén Itzá, Christ the Redeemer, Angkor Wat and the Sydney Opera House have their own stories — or keep the `worldLink` device? Aboriginal Australian and Māori stories would need the same Indigenous care.
- **CQ6 (Q27). Education surfacing.** Approve, reject or redesign the proposals in §4.4 (reflection question, "Talk about it" for parents, landmark pins, "Wonders you have seen").
- **CQ7 (Q28). Landmark scope.** Is 37 the right launch set? Keep or drop the *loose* links (Sydney Opera House, Statue of Liberty, Golden Gate Bridge, Christ the Redeemer)? Confirm the limit of two per story and that some stories have none.
- **CQ8 (Q29). Landmark image rights.** Legal review of §6.6 before art is commissioned.
- **CQ9 (Q30). Sensitive content policy.** Religious buildings shown as architecture; gods in Greek, Egyptian and Hindu stories told as "the Greeks said…"; slavery (Androcles), war (Mulan), death (Savitri, Urashima), abandonment (Zal), hunting (Arctic stories): confirm age-appropriate handling per tier, tied to the ages in PRD Q2 (decided: Low 6–8, Medium 8–10, Advanced 10–12+; marketed 6 to 14 and up). The exact App Store age rating (4+ or 9+) still depends on this policy.
- **CQ10 (Q31). Launch size and order.** Must all 32 stories ship on day one, or may the catalog launch in waves (Example (not a decision): the 3 prepared stories, then one full tier at a time)? This answers part of PRD Q8.
- **CQ11.** Child-facing origin labels: confirm the form "Cherokee · Appalachian Mountains", "Inuit · Nunavut, Canada", and that region names are shelf filters only (if a region filter is ever added — not in the locked design).
