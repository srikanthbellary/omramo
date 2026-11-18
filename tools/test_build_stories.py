#!/usr/bin/env python3
"""Tests for tools/build_stories.py and for the round-5 catalog. Standard library only.

    python3 tools/test_build_stories.py
"""

import json
import os
import sys
import unittest

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

import build_stories as bs  # noqa: E402
import validate_content as vc  # noqa: E402

ROOT = bs.CONTENT

# docs/CONTENT_PLAN.md §3: all 32 planned stories in plan order.
PLAN_ORDER = [
    "monkey-and-crocodile", "shipwrecked-sailor", "tongue-cut-sparrow", "old-man-who-moved-mountains",
    "why-possums-tail-is-bare", "the-snow-house", "peasant-and-bear", "bremen-town-musicians",
    "north-wind-and-sun", "why-sun-and-moon-live-in-sky", "lion-and-hare",
    "tiger-brahman-jackal", "khufu-and-the-magician", "bamboo-cutter-and-moon-child",
    "herd-boy-and-weaving-maiden", "iktomi-and-the-muskrat", "long-day-at-fish-camp", "sadko",
    "androcles-and-the-lion", "horse-and-the-olive", "anansi-wisdom", "sindbad-second-voyage",
    "savitri-and-satyavan", "eloquent-peasant", "urashima-taro", "ballad-of-mulan", "the-two-sisters",
    "woman-who-raised-a-bear", "firebird-and-horse-of-power", "daedalus-and-icarus",
    "the-griots-apprentice", "zal-and-the-simurgh",
]
# §7: the twelve stories flagged "needs cultural review before release".
REQUIRED_REVIEW = {
    "monkey-and-crocodile", "savitri-and-satyavan", "lion-and-hare", "why-possums-tail-is-bare",
    "iktomi-and-the-muskrat", "the-two-sisters", "the-snow-house", "long-day-at-fish-camp",
    "woman-who-raised-a-bear", "why-sun-and-moon-live-in-sky", "anansi-wisdom", "the-griots-apprentice",
}
ORIGINALS = {"the-snow-house", "long-day-at-fish-camp", "the-griots-apprentice"}
BATCH_ONE_NEW = PLAN_ORDER[1:11]
# Round 5, batch 2: the ten new Medium stories (the Anansi prototype is the eleventh).
BATCH_TWO_NEW = [sid for sid in PLAN_ORDER[11:22] if sid != "anansi-wisdom"]
HAND_WRITTEN = {"monkey-and-crocodile", "anansi-wisdom", "urashima-taro"}


class ParagraphMarkup(unittest.TestCase):
    def runs(self, text):
        return bs.parse_paragraph(text, "test")[1]

    def test_plain_text_is_one_run(self):
        self.assertEqual(self.runs("All day he ate sweet fruit."), [{"t": "All day he ate sweet fruit."}])

    def test_lead_marks_every_run(self):
        lead, runs = bs.parse_paragraph("^High in a tree on a <tap:river-bank>river bank</tap> lived a Monkey.", "test")
        self.assertTrue(lead)
        self.assertEqual(runs, [
            {"t": "High in a tree on a ", "lead": True},
            {"t": "river bank", "lead": True, "tap": "river-bank"},
            {"t": " lived a Monkey.", "lead": True},
        ])

    def test_speech_with_and_without_a_chip(self):
        runs = self.runs("<say:monkey*>“My heart?”</say> he said. <say:monkey>“What a pity!”</say>")
        self.assertEqual(runs, [
            {"t": "“My heart?”", "say": "monkey", "chip": True},
            {"t": " he said. "},
            {"t": "“What a pity!”", "say": "monkey"},
        ])

    def test_a_tap_word_inside_speech_keeps_the_voice_and_one_chip(self):
        runs = self.runs("<say:croc*>“There is <tap:ripe-fruit>ripe fruit</tap> on the island.”</say>")
        self.assertEqual(runs, [
            {"t": "“There is ", "say": "croc", "chip": True},
            {"t": "ripe fruit", "say": "croc", "tap": "ripe-fruit"},
            {"t": " on the island.”", "say": "croc"},
        ])

    def test_names_and_effects(self):
        runs = self.runs("The <name:monkey>Monkey</name> thought and <stretch>thought</stretch>. <pop:1.42>Whisk!</pop>")
        self.assertEqual(runs[1], {"t": "Monkey", "name": "monkey"})
        self.assertEqual(runs[3], {"t": "thought", "fx": "stretch"})
        self.assertEqual(runs[5], {"t": "Whisk!", "fx": "pop", "scale": 1.42})

    def test_mistakes_are_refused(self):
        for bad in (
            'He said "no".',                 # straight double quote
            "It's late.",                    # straight apostrophe
            "<say:monkey>“Never closed.”",   # unclosed tag
            "Closed twice.</say>",           # closing with nothing open
            "<say>“Who?”</say>",             # no id
            "<shout:monkey>“Hey!”</shout>",  # unknown tag
            "<say:a>“x”</name>",             # wrong closing tag
            "",                              # empty
            "a < b",                         # stray bracket
        ):
            with self.assertRaises(bs.SpecError, msg=bad):
                bs.parse_paragraph(bad, "test")


class Specs(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.specs = {}
        for sid in bs.spec_ids():
            with open(os.path.join(bs.SPECS, sid + ".json"), encoding="utf-8") as handle:
                cls.specs[sid] = json.load(handle)
        cls.catalog = vc.load_json(os.path.join(ROOT, "catalog.json"))["stories"]
        cls.landmarks = vc.load_json(os.path.join(ROOT, "landmarks", "landmarks.json"))
        cls.stories = {sid: vc.load_json(os.path.join(ROOT, "stories", sid, "story.json")) for sid in cls.catalog}

    def test_generated_files_are_up_to_date(self):
        stale = [os.path.relpath(path, bs.REPO) for path, text in bs.outputs(bs.spec_ids()).items()
                 if not os.path.isfile(path) or bs.read(path) != text]
        self.assertEqual(stale, [], "run python3 tools/build_stories.py")

    def test_catalog_is_in_plan_order(self):
        self.assertEqual(self.catalog, [sid for sid in PLAN_ORDER if sid in self.catalog])
        for sid in BATCH_ONE_NEW:
            self.assertIn(sid, self.catalog)
        for sid in HAND_WRITTEN:
            self.assertIn(sid, self.catalog)
        for sid in BATCH_TWO_NEW:
            self.assertIn(sid, self.catalog)
        self.assertEqual(len(BATCH_TWO_NEW), 10)
        self.assertGreaterEqual(len(self.catalog), 23)

    def test_every_catalog_story_has_a_spec_or_is_hand_written(self):
        for sid in self.catalog:
            self.assertTrue(sid in self.specs or sid in HAND_WRITTEN, sid)
        for sid in self.specs:
            self.assertIn(sid, self.catalog, "%s has a spec but is not in the catalog" % sid)

    def test_whole_tree_validates(self):
        rep = vc.validate_tree(ROOT)
        self.assertEqual(rep.errors(), [])
        self.assertNotIn("words-per-spread", rep.codes())
        self.assertNotIn("unused-tap-target", rep.codes())
        self.assertNotIn("too-many-landmarks", rep.codes())
        self.assertNotIn("manuscript-missing", rep.codes())

    def test_every_story_has_a_short_one_sentence_moral(self):
        morals = set()
        for sid, story in self.stories.items():
            moral = story.get("moral")
            self.assertIsNone(vc.moral_problem(moral), sid)
            limit = 14 if story["tier"] == "low" else 18
            self.assertLessEqual(len(moral.split()), limit, "%s: %s" % (sid, moral))
            self.assertNotIn(";", moral, sid)
            self.assertTrue(moral.endswith("."), sid)
            morals.add(moral)
        self.assertEqual(len(morals), len(self.stories))

    def test_section_seven_stories_are_flagged(self):
        for sid, story in self.stories.items():
            review = story["culturalReview"]
            if sid in REQUIRED_REVIEW:
                self.assertEqual(review["level"], "required", sid)
                self.assertEqual(review["status"], "pending", sid)
                self.assertTrue(review.get("reason", "").strip(), sid)
                self.assertTrue(review.get("community", "").strip(), sid)
            else:
                self.assertEqual(review["level"], "standard", sid)

    def test_a_flagged_story_is_an_error_in_release_mode(self):
        rep = vc.validate_tree(ROOT, release=True)
        flagged = {issue[2] for issue in rep.errors() if issue[1] == "cultural-review-not-approved"}
        for sid in self.catalog:
            if sid in REQUIRED_REVIEW:
                self.assertIn("stories/%s/story.json" % sid, flagged)

    def test_a_required_review_must_name_its_reviewer(self):
        story = json.loads(json.dumps(self.stories["why-possums-tail-is-bare"]))
        del story["culturalReview"]["community"]
        rep = vc.Report(False)
        manuscript = bs.read(os.path.join(ROOT, "sources", "why-possums-tail-is-bare.txt"))
        vc.validate_story(rep, "story.json", story, self.landmarks, manuscript)
        self.assertIn("cultural-review-no-community", rep.codes("error"))

    def test_originals_are_labelled(self):
        for sid, story in self.stories.items():
            prov = story["provenance"]
            if sid in ORIGINALS:
                self.assertEqual(prov["kind"], "original", sid)
                self.assertEqual(prov["credit"], "Original story written by us (Omramo)", sid)
            else:
                self.assertEqual(prov["kind"], "publicDomainRetelling", sid)
                self.assertEqual(prov["textBasis"], "omramoRetelling", sid)

    def test_new_low_stories_are_levelled(self):
        for sid in BATCH_ONE_NEW:
            story = self.stories[sid]
            self.assertEqual(story["tier"], "low", sid)
            self.assertTrue(12 <= len(story["spreads"]) <= 14, sid)
            self.assertEqual(len({s["scene"]["unfolded"]["file"] for s in story["spreads"]}), 4, sid)
            ordinary = [t for t in story["tapTargets"] if t["kind"] != "landmark"]
            self.assertGreaterEqual(len(ordinary), 2, sid)
            self.assertTrue(any(c.get("card") for c in story["characters"]), sid)
            for spread in story["spreads"]:
                words = sum(len(vc.block_text(b).split()) for b in spread["blocks"])
                self.assertLessEqual(words, 75, "%s %s" % (sid, spread["id"]))
                taps = [r for b in spread["blocks"] for r in b["runs"] if r.get("tap")]
                self.assertLessEqual(len(taps), 1, "%s %s" % (sid, spread["id"]))

    def test_new_medium_stories_are_levelled(self):
        for sid in BATCH_TWO_NEW:
            story = self.stories[sid]
            self.assertEqual(story["tier"], "medium", sid)
            self.assertTrue(9 <= len(story["spreads"]) <= 10, sid)
            self.assertEqual(len(story["parts"]), 2, sid)
            self.assertEqual(len({s["scene"]["unfolded"]["file"] for s in story["spreads"]}), 4, sid)
            ordinary = [t for t in story["tapTargets"] if t["kind"] != "landmark"]
            self.assertGreaterEqual(len(ordinary), 3, sid)
            self.assertTrue(any(t["kind"] == "place" for t in ordinary), sid)
            self.assertEqual(len([c for c in story["characters"] if c.get("card")]), 2, sid)
            chrome = story["theme"]["chrome"]
            self.assertEqual(len({chrome["leading"], chrome["trailing"], chrome["folded"]}), 1, sid)
            total = 0
            for spread in story["spreads"]:
                words = sum(len(vc.block_text(b).split()) for b in spread["blocks"])
                total += words
                self.assertLessEqual(words, 118, "%s %s" % (sid, spread["id"]))
                self.assertGreaterEqual(words, 55, "%s %s" % (sid, spread["id"]))
                taps = [r for b in spread["blocks"] for r in b["runs"] if r.get("tap")]
                self.assertLessEqual(len(taps), 1, "%s %s" % (sid, spread["id"]))
            self.assertTrue(750 <= total <= 1100, "%s: %d words" % (sid, total))
            # Lead lines open the story and Part II.
            self.assertTrue(all(r.get("lead") for r in story["spreads"][0]["blocks"][0]["runs"]), sid)
            second = next(s for s in story["spreads"] if s["part"] == story["parts"][1]["id"])
            self.assertTrue(all(r.get("lead") for r in second["blocks"][0]["runs"]), sid)
            # Every character with a card is named (tappable) in the text.
            named = {r.get("name") for s in story["spreads"] for b in s["blocks"] for r in b["runs"]}
            for character in story["characters"]:
                if character.get("card"):
                    self.assertIn(character["id"], named, "%s: %s is never named" % (sid, character["id"]))

    def test_the_fish_camp_story_has_no_snow_house_and_no_midnight_sun(self):
        story = self.stories["long-day-at-fish-camp"]
        text = " ".join(vc.block_text(b) for s in story["spreads"] for b in s["blocks"]).lower()
        self.assertNotIn("snow house", text)
        self.assertNotIn("midnight sun", text)
        self.assertNotIn("latestYear", story["setting"])
        self.assertIn("sod-house", [t["id"] for t in story["tapTargets"]])

    def test_a_tap_target_and_a_character_never_share_an_id(self):
        for sid, story in self.stories.items():
            characters = {c["id"] for c in story["characters"]}
            targets = {t["id"] for t in story["tapTargets"]}
            self.assertEqual(characters & targets, set(), sid)

    def test_app_text_never_uses_the_old_word_for_arctic_peoples(self):
        for sid, story in self.stories.items():
            shown = json.dumps([story["title"], story["region"]["label"], story["moral"], story["spreads"],
                                story["tapTargets"], story["characters"]], ensure_ascii=False).lower()
            self.assertNotIn("eskimo", shown, sid)
            self.assertNotIn("igloo", shown, sid)

    def test_landmarks_belong_to_the_plan_and_each_story_points_at_real_ones(self):
        ids = [lm["id"] for lm in self.landmarks["landmarks"]]
        self.assertEqual(len(ids), len(set(ids)))
        for sid, story in self.stories.items():
            for target in story["tapTargets"]:
                if target["kind"] == "landmark":
                    self.assertIn(target["landmark"]["id"], ids, sid)
        for lm in self.landmarks["landmarks"]:
            self.assertEqual(lm["art"]["file"], "art/%s.heic" % lm["id"])


if __name__ == "__main__":
    unittest.main()
