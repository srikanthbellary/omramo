# Omramo: business use case v5, one story, one tier (13 Nov 2026)

**Supersedes:** v4 (`2026-11-13-omramo-business-use-case-v4-leveled.md`), v3, v2 and the Telugu-first v1. All are kept for history.
**v5 change (Srikanth, 13 Nov 2026):** Tiers are locked at the story level. Every story is unique and belongs to exactly one tier, decided by its message and complexity. No story appears in more than one tier.
**v4 change (Srikanth, 13 Nov 2026):** Stories are leveled by reading complexity into Low, Medium and Advanced tiers. Readers choose by age or reading level, and moving up through the tiers is part of the value.
**Direction set by:** Srikanth, 13 Nov 2026: Omramo must read like a real book, a magical book, not video storytelling. Children read the text; pictures serve the reading.
**Product:** Omramo (`omramo.com`), the first app in Sunrise Gen AI's iPhone Duo line. Native Swift/SwiftUI in Xcode, private repo `srikanthbellary/omramo`, site repo `srikanthbellary/omramo-web`.

## The rule that governs everything
**The child reading words on the page is the product.** Illustrations and tap-to-see visuals exist only to pull a child into the text and keep them reading. They never tell the story for them. Omramo has no narrated video, no autoplay and no scene that advances unless the child reads. If a feature could let a child skip reading, it doesn't ship.

## 1. Problem
- **Children are reading less, and that is the problem Omramo exists to fix.** Kids who can read are choosing not to. Games and short video are the competition: they're instant, moving and endless, and a page of text loses to them.
- Most "story" apps answer this by turning books into video or narrated cartoons. That holds attention but replaces reading: the child watches and listens instead of reading.
- Plain ebooks keep the reading but give a child nothing to pull them in. When a story mentions something they've never seen, such as the Taj Mahal, the moment passes and their attention drifts.

## 2. Target users
- **Primary:** Children worldwide who can already read English, roughly early to middle grades, who enjoy games and visuals but should be building a reading habit.
- **Served by three reading tiers:** Low for newer independent readers, Medium for confident readers, and Advanced for strong readers ready for longer, richer text. A child starts at the tier that matches their age or reading level, not a single one-size catalog. Exact ages per tier are still to be set.
- **Buyers:** Parents (and later teachers) who want screen time that is real reading, not another game.
- **Device:** Owners of Apple's foldable iPhone Duo first, a family device that opens into a book-sized screen. Other iPhones and iPads can come later.

## 3. Value proposition
Omramo is a magical book. It looks and behaves like a real book: pages of text the child reads, set beside rich illustrations. The magic is that the book answers their curiosity. Tap a word like "Taj Mahal" and it appears on the facing page. Characters are vivid enough that kids want to find out what happens to them. Every bit of that magic is earned by reading and sends the child straight back to the words. Because the library is leveled, every child finds books they can actually read today, and a clear next step up. Watching a child climb from Low to Advanced is part of what parents are paying for. It's book reading strong enough to compete with games and video, without becoming them.

**What Omramo is not:** video storytelling, a narrated cartoon, a read-to-me app, or a game with some text in it.

## 4. Key features
1. **Real pages of text, read by the child:** Each spread is a book page. The story moves forward only as the child reads and turns the page. There's no autoplay, no video scenes and no default read-aloud. Optional help is limited to tapping a single word to hear or define it.
2. **Heavy illustration in service of the text:** Every spread is richly illustrated on the facing pane, like a picture book for confident readers. The art shows the moment the child just read; it doesn't tell the next part of the story.
3. **Tap-to-see, from the text:** Visuals open only from words in the text, so curiosity starts in the reading. Tap "Taj Mahal" and a still or lightly animated visualization appears on the facing page, with a line or two of text to read. It closes back to the exact spot on the page. Visuals are short and never chain into each other.
4. **Characters as visuals:** Recurring illustrated characters the child comes to know. Tapping a name shows the character with a short description to read, which keeps them tied to the story.
5. **Rewards for reading, not playing:** Any game-like touch is earned by reading. Examples are a collection of places and characters met by finishing chapters, a book shelf that fills up, and reading streaks. There are no mini-games, timers or rewards that skip pages.
6. **Leveled library, Low, Medium and Advanced:** The catalog is organized into three complexity tiers. Every story is unique and is assigned to exactly one tier, based on its message (what the story is about and how mature its ideas are) and its complexity. The tier is locked when the story is written and never changes. There are no simplified or expanded versions of a story in other tiers. Complexity is judged by vocabulary, sentence length, story length and the share of the page that is text versus illustration, so Advanced books carry more text and less picture. Each book shows its tier on the cover, and browsing can be filtered by tier. Parents or kids pick a starting tier by age or reading level. A short placement check can come later.
7. **Progression across tiers:** Moving up a tier means meeting new stories with bigger ideas and harder text, not rereading the same story in a harder version. Finishing books in a tier unlocks a nudge toward the next one, and the bookshelf and collection show how far a child has climbed. Kids can always go back down a tier for comfort reads, and a tier is never locked behind payment. Each tier needs enough unique stories of its own to keep a child reading before they move up.
8. **Story library:** Builds on the existing story list (for example the public-domain Panchatantra pilot and openly licensed tales from the 7 Nov rights research), retold in English, with new stories added over time.
9. **Two-pane Duo book:** Text on one pane and illustration or tapped visual on the other, opening like a real book. Reading carries over between the outer and inner screens.
10. **Free browse and sample, then subscribe:** Browse covers for free in every tier, read a two-page sample, then subscribe to read the full library across all tiers.
11. **For parents:** Time spent reading, pages read, the current tier and progress toward the next one, not screen time. Settings has Appearance, Restore Purchases, Manage Subscription and legal links. No child account is needed in v1.

**Content pipeline (ops side, not in the app):** Each story is packaged with its single locked tier (Low, Medium or Advanced), its text, page art, character sheet and a set of tappable visual moments, each tied to a word in the text. The catalog downloads into the app. The prototype has three sample books: three different stories, one written for each tier (one Low, one Medium, one Advanced), each picked for a message that fits its tier.

## 5. Monetization
- An auto-renewing family subscription through StoreKit 2 and Apple ID, unlocking the whole library. Prices aren't set yet; use App Store per-country pricing for a global launch.
- The free browse and two-page sample act as the funnel into the paywall.
- Later options, not committed: classroom or school licences, and premium story packs or new worlds.
- **Kids-app rules apply:** App Store Kids Category, COPPA in the US and GDPR-K in the EU. That means no third-party ads or tracking, and a parental gate in front of purchases and outside links.

## 6. Why the foldable iPhone Duo matters
- **The device's shape is a book.** The open Duo is a two-page spread, so story and picture sit side by side as in a printed picture book.
- **Tap-to-see needs a second page.** The visual opens on the facing pane without covering the text, so the child never loses their place. A single phone screen would have to pop over the story.
- **The brand comes from the fold.** OM | RA | MO, read across left pane, spine and right pane: closed it's Omramo, open it's the book.
- **It's a new platform with few native readers.** Building natively in Swift and following Apple's iPhone Duo design guidelines gives the best shot at being featured early.

## 7. Competition (from the 7 Nov research)
- **The field:** Epic, Raz-Kids, Reading Eggspress, Oxford Reading Club and BOOKR already mix illustrated reading with audio, levels and quizzes. StoryWeaver, Oxford Owl and Google Read Along set a strong free baseline.
- **Omramo's angle:** Not "illustrated stories plus narration" alone. Many rivals lean on narration, video and games. Omramo's difference is a reading-first magical book: tap-to-see visuals that start from the text, recurring characters, rewards earned only by reading, and a reader built for the fold. These are claims to test with kids, not established advantages.

## 8. Risks and next steps
- **Risks:**
  - Making visuals for every tappable moment is costly and needs a repeatable art pipeline.
  - The Duo install base is small at first.
  - Children's-privacy compliance.
  - A crowded market.
- **Next steps:**
  - Pick 3 pilot stories from the existing list and mark their tappable moments and characters.
  - Prototype tap-to-see on the two-pane layout in Xcode.
  - Test with a few families, measuring whether kids read more pages per session, not just whether they tap.
  - Set the price.
  - TestFlight under the Sunrise Apple developer account.
