#!/usr/bin/env python3
"""Tests for tools/validate_content.py. Python 3, standard library only.

    python3 tools/test_validate_content.py

Each test takes the bundled sample content, breaks one thing in memory and checks that the
validator reports the matching rule code. These are the "invalid fixtures" of
docs/IMPLEMENTATION_PLAN.md criteria 1.1, 1.18 and 1.19; the Swift tests in
Packages/OmramoCore/Tests cover the same cases against StoryValidator.
"""

import copy
import os
import sys
import unittest

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import validate_content as vc  # noqa: E402

ROOT = os.path.normpath(os.path.join(HERE, "..", "Packages", "OmramoCore", "Sources", "OmramoCore", "Resources", "Content"))
STORY_ID = "monkey-and-crocodile"


class Base(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.story0 = vc.load_json(os.path.join(ROOT, "stories", STORY_ID, "story.json"))
        cls.landmarks0 = vc.load_json(os.path.join(ROOT, "landmarks", "landmarks.json"))
        with open(os.path.join(ROOT, "sources", STORY_ID + ".txt"), encoding="utf-8") as handle:
            cls.manuscript = handle.read()

    def setUp(self):
        self.story = copy.deepcopy(self.story0)
        self.landmarks = copy.deepcopy(self.landmarks0)

    def run_story(self, release=False, manuscript="use-default"):
        rep = vc.Report(release)
        vc.shape_story(self.story)
        vc.shape_landmarks(self.landmarks)
        text = self.manuscript if manuscript == "use-default" else manuscript
        vc.validate_story(rep, "story.json", self.story, self.landmarks, text)
        return rep

    def run_landmarks(self, release=False):
        rep = vc.Report(release)
        vc.shape_landmarks(self.landmarks)
        vc.validate_landmarks(rep, "landmarks.json", self.landmarks)
        return rep

    def assertError(self, rep, code):
        self.assertIn(code, rep.codes("error"), "expected error %s, got %s" % (code, sorted(rep.codes())))

    def landmark_target(self):
        return next(t for t in self.story["tapTargets"] if t["kind"] == "landmark")


class BundledContent(Base):
    def test_whole_tree_is_valid(self):
        rep = vc.validate_tree(ROOT)
        self.assertEqual(rep.errors(), [])

    def test_release_mode_blocks_pending_reviews(self):
        rep = vc.validate_tree(ROOT, release=True)
        self.assertIn("cultural-review-not-approved", rep.codes("error"))
        self.assertIn("review-pending", rep.codes("error"))

    def test_sample_story_is_complete(self):
        s = self.story
        self.assertEqual(s["tier"], "low")
        self.assertEqual(s["region"]["id"], "indian")
        self.assertEqual(s["provenance"]["kind"], "publicDomainRetelling")
        self.assertEqual(s["provenance"]["textBasis"], "omramoRetelling")
        self.assertEqual(s["provenance"]["sources"][0]["gutenbergId"], 62514)
        self.assertEqual(s["culturalReview"]["level"], "required")
        for pillar in ("geography", "culture", "moral"):
            self.assertTrue(s["education"][pillar]["lesson"])
        self.assertEqual(len(s["spreads"]), 14)
        parts = {sp["part"] for sp in s["spreads"]}
        self.assertEqual(parts, {"part-1", "part-2"})

    def test_sample_landmark_is_framed_then_and_now(self):
        ref = self.landmark_target()["landmark"]
        self.assertEqual(ref["id"], "taj-mahal")
        self.assertEqual(ref["appearance"], "framed")
        self.assertEqual(ref["framingDevice"]["kind"], "thenAndNow")
        self.assertIn("taj-mahal", [lm["id"] for lm in self.landmarks["landmarks"]])

    def test_fonts_and_licences_are_bundled(self):
        fonts = os.path.normpath(os.path.join(HERE, "..", "App", "Resources", "Fonts"))
        if not os.path.isdir(fonts):
            self.skipTest("App/Resources/Fonts not present")
        names = set(os.listdir(fonts))
        for name in ("BricolageGrotesque.ttf", "AtkinsonHyperlegibleNext.ttf", "AtkinsonHyperlegibleNext-Italic.ttf",
                     "Inter.ttf", "OFL-bricolagegrotesque.txt", "OFL-atkinsonhyperlegiblenext.txt", "OFL-inter.txt"):
            self.assertIn(name, names)
        with open(os.path.join(fonts, "..", "Info.plist"), encoding="utf-8") as handle:
            plist = handle.read()
        for name in ("BricolageGrotesque.ttf", "AtkinsonHyperlegibleNext.ttf", "AtkinsonHyperlegibleNext-Italic.ttf", "Inter.ttf"):
            self.assertIn("<string>%s</string>" % name, plist)


class Shape(Base):
    def assertMalformed(self, fn):
        with self.assertRaises(vc.Malformed):
            fn()

    def test_newer_schema_version(self):
        self.story["schemaVersion"] = 2
        self.assertMalformed(lambda: vc.shape_story(self.story))

    def test_unknown_tier(self):
        self.story["tier"] = "huge"
        self.assertMalformed(lambda: vc.shape_story(self.story))

    def test_unknown_region_id(self):
        self.story["region"]["id"] = "atlantean"
        self.assertMalformed(lambda: vc.shape_story(self.story))

    def test_missing_education_pillar(self):
        del self.story["education"]["moral"]
        self.assertMalformed(lambda: vc.shape_story(self.story))

    def test_missing_provenance(self):
        del self.story["provenance"]
        self.assertMalformed(lambda: vc.shape_story(self.story))

    def test_landmark_missing_tier_fact_card(self):
        del self.landmarks["landmarks"][0]["factCards"]["advanced"]
        self.assertMalformed(lambda: vc.shape_landmarks(self.landmarks))

    def test_art_without_alt_key(self):
        del self.story["cover"]["alt"]
        self.assertMalformed(lambda: vc.shape_story(self.story))


class StoryRules(Base):
    def first_run_with(self, key):
        for spread in self.story["spreads"]:
            for block in spread["blocks"]:
                for run in block["runs"]:
                    if key in run:
                        return run
        self.fail("no run with " + key)

    def test_valid_as_bundled(self):
        self.assertEqual(self.run_story().errors(), [])

    def test_duplicate_spread_id(self):
        self.story["spreads"][1]["id"] = self.story["spreads"][0]["id"]
        self.assertError(self.run_story(), "duplicate-id")

    def test_duplicate_block_id(self):
        self.story["spreads"][1]["blocks"][0]["id"] = self.story["spreads"][0]["blocks"][0]["id"]
        self.assertError(self.run_story(), "duplicate-id")

    def test_dangling_part(self):
        self.story["spreads"][0]["part"] = "part-9"
        self.assertError(self.run_story(), "dangling-part")

    def test_dangling_tap(self):
        self.first_run_with("tap")["tap"] = "nowhere"
        self.assertError(self.run_story(), "dangling-tap")

    def test_dangling_name(self):
        self.first_run_with("name")["name"] = "nobody"
        self.assertError(self.run_story(), "dangling-name")

    def test_dangling_say(self):
        self.first_run_with("say")["say"] = "nobody"
        self.assertError(self.run_story(), "dangling-say")

    def test_tap_and_name_on_one_run(self):
        self.first_run_with("tap")["name"] = "monkey"
        self.assertError(self.run_story(), "tap-and-name")

    def test_missing_alt_text(self):
        self.story["spreads"][0]["scene"]["unfolded"]["alt"] = "  "
        self.assertError(self.run_story(), "missing-alt")

    def test_bad_colour(self):
        self.story["theme"]["textColor"] = "navy"
        self.assertError(self.run_story(), "bad-color")

    def test_free_spreads_out_of_range(self):
        self.story["sample"]["freeSpreads"] = 99
        self.assertError(self.run_story(), "free-spreads-range")

    def test_changed_word_fails_fidelity(self):
        run = self.story["spreads"][0]["blocks"][1]["runs"][0]
        self.assertIn("sweet", run["t"])
        run["t"] = run["t"].replace("sweet", "sour")
        self.assertError(self.run_story(), "text-fidelity")

    def test_quotes_and_dashes_do_not_break_fidelity(self):
        text = self.manuscript.replace("“", '"').replace("”", '"').replace("’", "'")
        self.assertEqual(self.run_story(manuscript=text).errors(), [])

    def test_missing_manuscript_is_release_error(self):
        self.assertIn("manuscript-missing", self.run_story(manuscript=None).codes("warning"))
        self.assertError(self.run_story(release=True, manuscript=None), "manuscript-missing")

    def test_empty_region_culture(self):
        self.story["region"]["culture"] = ""
        self.assertError(self.run_story(), "region-incomplete")

    def test_retelling_with_no_source(self):
        self.story["provenance"]["sources"] = []
        self.assertError(self.run_story(), "provenance-no-source")

    def test_source_without_author(self):
        self.story["provenance"]["sources"][0]["author"] = ""
        self.assertError(self.run_story(), "provenance-source-incomplete")

    def test_original_with_no_premise(self):
        self.story["provenance"] = {"kind": "original", "credit": "Original story written by us (Omramo)", "rights": "Ours."}
        self.assertError(self.run_story(), "original-incomplete")

    def test_original_complete_is_valid(self):
        self.story["provenance"] = {"kind": "original", "credit": "Original story written by us (Omramo)",
                                    "premise": "A monkey outwits a crocodile.", "rights": "Ours."}
        self.assertEqual(self.run_story().errors(), [])

    def test_required_cultural_review_with_no_reason(self):
        del self.story["culturalReview"]["reason"]
        self.assertError(self.run_story(), "cultural-review-no-reason")

    def test_empty_education_lesson(self):
        self.story["education"]["culture"]["lesson"] = ""
        self.assertError(self.run_story(), "education-incomplete")

    def test_education_fact_card_dangling(self):
        self.story["education"]["geography"]["factCards"] = ["no-such-card"]
        self.assertError(self.run_story(), "education-fact-card-dangling")


class LandmarkRules(Base):
    def test_dangling_landmark_id(self):
        self.landmark_target()["landmark"]["id"] = "atlantis"
        self.assertError(self.run_story(), "dangling-landmark")

    def test_later_built_landmark_marked_natural(self):
        ref = self.landmark_target()["landmark"]
        ref["appearance"] = "natural"
        del ref["framingDevice"]
        self.assertError(self.run_story(), "landmark-anachronism")

    def test_framed_without_device(self):
        del self.landmark_target()["landmark"]["framingDevice"]
        self.assertError(self.run_story(), "framed-without-device")

    def test_out_of_region_needs_world_link_or_map_moment(self):
        ref = self.landmark_target()["landmark"]
        ref["id"] = "lighthouse-of-alexandria"      # Egyptian landmark in an Indian story
        self.assertError(self.run_story(), "landmark-out-of-region")   # thenAndNow is not enough
        ref["framingDevice"]["kind"] = "worldLink"
        self.assertNotIn("landmark-out-of-region", self.run_story().codes())

    def test_landmark_target_must_not_carry_card_copy(self):
        self.landmark_target()["title"] = "Taj Mahal"
        self.assertError(self.run_story(), "landmark-target-shape")

    def test_lost_landmark_must_be_reconstruction(self):
        lighthouse = next(lm for lm in self.landmarks["landmarks"] if lm["status"] == "lost")
        lighthouse["depiction"] = "asIs"
        self.assertError(self.run_landmarks(), "landmark-not-reconstruction")

    def test_empty_fact_card_line(self):
        self.landmarks["landmarks"][0]["factCards"]["low"]["line"] = ""
        self.assertError(self.run_landmarks(), "landmark-fact-card")

    def test_coordinates_out_of_range(self):
        self.landmarks["landmarks"][0]["coordinates"]["lat"] = 123
        self.assertError(self.run_landmarks(), "landmark-coordinates")

    def test_no_list(self):
        self.landmarks["landmarks"][0]["lists"] = []
        self.assertError(self.run_landmarks(), "landmark-no-list")

    def test_built_missing(self):
        del self.landmarks["landmarks"][0]["built"]
        self.assertError(self.run_landmarks(), "landmark-built")

    def test_low_story_gets_low_wording(self):
        taj = next(lm for lm in self.landmarks["landmarks"] if lm["id"] == "taj-mahal")
        self.assertEqual(self.story["tier"], "low")
        self.assertNotEqual(taj["factCards"]["low"]["line"], taj["factCards"]["medium"]["line"])


class PathTextAndTextArea(Base):
    """Milestone 2 rules: text on a path, and where a scene's calm text area ends."""

    WAVE = "M14,66 C70,22 120,84 190,52 C250,26 300,70 388,30"

    def first_block(self):
        return self.story["spreads"][0]["blocks"][0]

    def test_parse_path_accepts_the_supported_commands(self):
        self.assertEqual(len(vc.parse_path(self.WAVE)), 3)
        lines = vc.parse_path("M0 0 10 0 L 20,5 Q30,-5 40.5,0")
        self.assertEqual([seg[0] for seg in lines], ["M", "L", "L", "Q"])
        self.assertEqual(lines[3][1], [30.0, -5.0, 40.5, 0.0])
        self.assertEqual(vc.parse_path("M.5,0 L1.5.25")[1], ("L", [1.5, 0.25]))

    def test_parse_path_rejects_what_the_app_cannot_draw(self):
        for bad in ("", "M10,10", "L10,10 20,20", "M0,0 c10,10 20,20 30,0", "M0,0 A5,5 0 0 1 10,10",
                    "M0,0 C10,10 20,20", "M0,0 L10,10 M20,20 L30,30", "M0,0 L10,ten", None, 12):
            self.assertIsNone(vc.parse_path(bad), repr(bad))

    def test_paragraph_must_not_carry_a_path(self):
        self.first_block()["path"] = self.WAVE
        self.assertError(self.run_story(), "path-text-incomplete")

    def test_path_text_needs_a_path(self):
        self.first_block()["kind"] = "pathText"
        self.assertError(self.run_story(), "path-text-incomplete")
        self.first_block()["path"] = "M0,0 a5,5 0 0 1 10,10"
        self.assertError(self.run_story(), "path-text-incomplete")

    def test_path_text_with_a_path_is_valid_and_keeps_fidelity(self):
        block = self.first_block()
        block["kind"] = "pathText"
        block["path"] = self.WAVE
        rep = self.run_story()
        self.assertNotIn("path-text-incomplete", rep.codes())
        self.assertNotIn("text-fidelity", rep.codes())

    def test_text_area_range(self):
        scene = self.story["spreads"][0]["scene"]
        scene["textArea"] = {"trailingBottom": 420}
        self.assertNotIn("text-area-range", self.run_story().codes())
        scene["textArea"] = {"leadingBottom": 90}
        self.assertError(self.run_story(), "text-area-range")
        scene["textArea"] = {"trailingBottom": 900}
        self.assertError(self.run_story(), "text-area-range")

    def test_text_area_shape(self):
        self.story["spreads"][0]["scene"]["textArea"] = {"trailingBottom": "low"}
        with self.assertRaises(vc.Malformed):
            self.run_story()


class PrototypeStories(unittest.TestCase):
    """The Medium and Advanced prototype stories added in Milestone 2 (criterion 2.5)."""

    @classmethod
    def setUpClass(cls):
        cls.landmarks = vc.load_json(os.path.join(ROOT, "landmarks", "landmarks.json"))
        cls.stories = {}
        cls.manuscripts = {}
        for sid in ("monkey-and-crocodile", "anansi-wisdom", "urashima-taro"):
            cls.stories[sid] = vc.load_json(os.path.join(ROOT, "stories", sid, "story.json"))
            with open(os.path.join(ROOT, "sources", sid + ".txt"), encoding="utf-8") as handle:
                cls.manuscripts[sid] = handle.read()

    def validate(self, sid, story=None, manuscript=None):
        story = copy.deepcopy(self.stories[sid]) if story is None else story
        vc.shape_story(story)
        rep = vc.Report(False)
        vc.validate_story(rep, "story.json", story, self.landmarks,
                          self.manuscripts[sid] if manuscript is None else manuscript)
        return rep

    def test_catalog_lists_one_story_per_tier(self):
        catalog = vc.load_json(os.path.join(ROOT, "catalog.json"))
        # Round 5: the catalog grows toward the plan's 32 stories; the three prototypes stay
        # in it, in this order, one a tier.
        prototypes = [s for s in catalog["stories"] if s in self.stories]
        self.assertEqual(prototypes, ["monkey-and-crocodile", "anansi-wisdom", "urashima-taro"])
        self.assertEqual(catalog["stories"][0], "monkey-and-crocodile")
        self.assertEqual([self.stories[s]["tier"] for s in prototypes], ["low", "medium", "advanced"])
        self.assertEqual([self.stories[s]["region"]["id"] for s in prototypes],
                         ["indian", "african", "japanese"])

    def test_all_three_validate_with_text_fidelity(self):
        for sid in self.stories:
            rep = self.validate(sid)
            self.assertEqual(rep.errors(), [], sid)
            self.assertNotIn("words-per-spread", rep.codes(), sid)
            self.assertNotIn("unused-tap-target", rep.codes(), sid)
            self.assertIsNone(vc.compare_text(self.stories[sid], self.manuscripts[sid]), sid)

    def test_fidelity_check_is_honest_for_the_new_stories(self):
        # One changed word in the story, or in the manuscript, is caught.
        for sid in ("anansi-wisdom", "urashima-taro"):
            story = copy.deepcopy(self.stories[sid])
            run = story["spreads"][1]["blocks"][0]["runs"][0]
            run["t"] = run["t"].replace(" ", "  very ", 1)
            self.assertIn("text-fidelity", self.validate(sid, story=story).codes("error"), sid)
            lines = self.manuscripts[sid].splitlines()
            index = next(i for i, line in enumerate(lines) if not line.startswith("#") and " the " in line)
            lines[index] = lines[index].replace(" the ", " teh ", 1)
            changed = "\n".join(lines)
            self.assertIn("text-fidelity", self.validate(sid, manuscript=changed).codes("error"), sid)

    def test_stories_are_our_own_retellings(self):
        for sid, story in self.stories.items():
            self.assertEqual(story["provenance"]["textBasis"], "omramoRetelling", sid)
            self.assertEqual(story["review"]["text"]["status"], "pending", sid)

    def test_anansi_is_medium_with_text_on_one_pane(self):
        story = self.stories["anansi-wisdom"]
        self.assertEqual(story["theme"]["accent"], "amber")
        self.assertEqual(story["theme"]["chrome"], {"leading": "dark", "trailing": "dark", "folded": "dark"})
        self.assertEqual(story["culturalReview"]["level"], "required")
        panes = {b["pane"] for s in story["spreads"] for b in s["blocks"]}
        self.assertEqual(panes, {"leading"})
        target = next(t for t in story["tapTargets"] if t["kind"] == "landmark")
        self.assertEqual(target["landmark"], {"id": "asante-traditional-buildings", "appearance": "natural"})

    def test_urashima_is_advanced_with_text_on_both_panes_and_a_wave(self):
        story = self.stories["urashima-taro"]
        self.assertEqual(story["theme"]["accent"], "red")
        for spread in story["spreads"]:
            panes = {b["pane"] for b in spread["blocks"]}
            self.assertEqual(panes, {"leading", "trailing"}, spread["id"])
            # Round 4: the words on the leading pane stop at the horizon of the recomposed
            # sea scenes (470), as well as above the picture on the trailing pane (420).
            self.assertEqual(spread["scene"]["textArea"], {"leadingBottom": 470, "trailingBottom": 420}, spread["id"])
        paths = [b for s in story["spreads"] for b in s["blocks"] if b["kind"] == "pathText"]
        self.assertEqual(len(paths), 1)
        self.assertEqual(paths[0]["pane"], "trailing")
        self.assertIsNotNone(vc.parse_path(paths[0]["path"]))
        self.assertEqual(vc.normalize(vc.block_text(paths[0])), '"Urashima, Urashima!"')

    def test_skytree_must_stay_framed_in_old_japan(self):
        story = copy.deepcopy(self.stories["urashima-taro"])
        target = next(t for t in story["tapTargets"] if t["kind"] == "landmark")
        self.assertEqual(target["landmark"]["appearance"], "framed")
        self.assertEqual(target["landmark"]["framingDevice"]["kind"], "thenAndNow")
        target["landmark"] = {"id": "tokyo-skytree", "appearance": "natural"}
        self.assertIn("landmark-anachronism", self.validate("urashima-taro", story=story).codes("error"))

    def test_every_story_marks_a_landmark_a_tap_word_and_a_character_with_a_card(self):
        for sid, story in self.stories.items():
            runs = [r for s in story["spreads"] for b in s["blocks"] for r in b["runs"]]
            tapped = {r["tap"] for r in runs if "tap" in r}
            named = {r["name"] for r in runs if "name" in r}
            kinds = {t["kind"] for t in story["tapTargets"] if t["id"] in tapped}
            self.assertIn("landmark", kinds, sid)
            self.assertTrue(kinds - {"landmark"}, sid)
            with_cards = {c["id"] for c in story["characters"] if c.get("card")}
            self.assertTrue(named & with_cards, sid)

    def test_new_landmarks_have_three_tier_wordings(self):
        by_id = {lm["id"]: lm for lm in self.landmarks["landmarks"]}
        for lid in ("asante-traditional-buildings", "tokyo-skytree"):
            cards = by_id[lid]["factCards"]
            lines = {cards[t]["line"] for t in vc.TIERS}
            self.assertEqual(len(lines), 3, lid)


class RuleCodesMatchSwift(unittest.TestCase):
    """Criterion 1.20: the Python and Swift validators list the same rules."""

    def test_same_codes(self):
        import re
        swift = os.path.normpath(os.path.join(
            HERE, "..", "Packages", "OmramoCore", "Sources", "OmramoCore", "Content", "ValidationIssue.swift"))
        with open(swift, encoding="utf-8") as handle:
            swift_codes = set(re.findall(r'case \w+ = "([a-z-]+)"', handle.read()))
        with open(os.path.join(HERE, "validate_content.py"), encoding="utf-8") as handle:
            source = handle.read()
        python_codes = set(re.findall(r'rep\.add\(\s*[\w.]+,\s*"([a-z-]+)"', source))
        python_codes |= set(re.findall(r'rep\.add\("(?:error|warning)",\s*"([a-z-]+)"', source))
        self.assertEqual(swift_codes, python_codes)


if __name__ == "__main__":
    unittest.main()
