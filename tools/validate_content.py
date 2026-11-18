#!/usr/bin/env python3
"""Omramo content check. Python 3, standard library only.

    python3 tools/validate_content.py [CONTENT_DIR] [--release] [--check-art] [--quiet]

CONTENT_DIR defaults to Packages/OmramoCore/Sources/OmramoCore/Resources/Content.

Exit status: 0 when there are no errors (warnings are allowed), 1 when any rule is broken,
2 when the content folder cannot be read at all.

This script mirrors `StoryValidator` in OmramoCore rule for rule (same rule codes). It exists
because the development box has no Swift toolchain. If the two ever disagree, the Swift
validator wins and this script is fixed (docs/ARCHITECTURE.md section 7.3).

Modes
  default      development: pending reviews are warnings.
  --release    pending reviews, an unapproved required cultural review, a missing manuscript
               and (with --check-art) missing image files are errors.
  --check-art  also check that every image file named by an ArtRef exists. Off by default:
               M1 art is placeholder and no image files are bundled.
"""

import json
import os
import re
import sys

SUPPORTED_SCHEMA_VERSION = 1

TIERS = ("low", "medium", "advanced")
TARGET_WORDS = {"low": 55, "medium": 90, "advanced": 190}
WORD_ALLOWANCE = 1.5
MAX_LANDMARKS_PER_STORY = 2

REGION_IDS = (
    "indian", "egyptian", "japanese", "chinese", "nativeAmericanFirstNations",
    "arctic", "russian", "european", "african", "persianArabian",
)
PROVENANCE_KINDS = ("publicDomainRetelling", "original")
TEXT_BASES = ("sourceVerbatim", "omramoRetelling")
REVIEW_STATUSES = ("pending", "approved")
CULTURAL_LEVELS = ("required", "standard")
CULTURAL_STATUSES = ("pending", "inReview", "changesRequested", "approved")
CHROME_STYLES = ("light", "dark")
ACCENTS = ("coral", "amber", "red")
TARGET_KINDS = ("place", "object", "creature", "idea", "landmark")
APPEARANCES = ("natural", "framed")
DEVICE_KINDS = ("thenAndNow", "mapMoment", "worldLink", "presentDayNarrator")
PANES = ("leading", "trailing")
BLOCK_KINDS = ("paragraph", "pathText")
RUN_EFFECTS = ("pop", "stretch")
ERAS = ("ancient", "medieval", "earlyModern", "modern", "contemporary", "natural")
LANDMARK_STATUSES = ("standing", "ruins", "lost", "unproven", "natural")
DEPICTIONS = ("asIs", "reconstruction")
LANDMARK_LISTS = ("ancientSeven", "new7Wonders", "other")

COLOR_RE = re.compile(r"^#(?:[0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})$")


MORAL_MAX_LENGTH = 120


def moral_sentence_count(text):
    """Mirrors MoralRule.sentenceCount in OmramoCore."""
    marks = ".!?"
    closers = "\"\u201d\u2019')"
    count = 0
    index = 0
    ended_at_last = False
    while index < len(text):
        if text[index] in marks:
            end = index + 1
            while end < len(text) and (text[end] in marks or text[end] in closers):
                end += 1
            if end >= len(text):
                count += 1
                ended_at_last = True
            elif text[end].isspace():
                count += 1
            index = end
        else:
            index += 1
    return count if ended_at_last else 0


def moral_problem(moral):
    """Mirrors MoralRule.problem(in:) in OmramoCore. None when the moral is fine."""
    if moral is None:
        return "the story has no moral (one short sentence for the story-finished moment)"
    text = moral.strip()
    if not text:
        return "the moral is empty"
    if len(text) > MORAL_MAX_LENGTH:
        return "the moral is %d characters long; keep it to %d or fewer" % (len(text), MORAL_MAX_LENGTH)
    if moral_sentence_count(text) != 1:
        return ("the moral must be exactly one sentence that ends with a full stop, "
                "a question mark or an exclamation mark")
    return None


class Malformed(Exception):
    """The JSON does not have the shape of the schema (the Swift decoder would refuse it)."""


class Report:
    def __init__(self, release):
        self.release = release
        self.issues = []  # (severity, code, file, location, message)

    @property
    def pending(self):
        return "error" if self.release else "warning"

    def add(self, severity, code, file, location, message):
        self.issues.append((severity, code, file, location, message))

    def errors(self):
        return [i for i in self.issues if i[0] == "error"]

    def warnings(self):
        return [i for i in self.issues if i[0] == "warning"]

    def codes(self, severity=None):
        return {i[1] for i in self.issues if severity is None or i[0] == severity}


# ---------------------------------------------------------------- shape (what decoding enforces)

def _need(obj, key, kind, path, optional=False, choices=None):
    """Return obj[key] after checking its JSON type. Raises Malformed like the Swift decoder."""
    where = (path + "." + key) if path else key
    if not isinstance(obj, dict):
        raise Malformed('wrong type at "%s": expected an object' % path)
    if key not in obj or obj[key] is None:
        if optional:
            return None
        raise Malformed('missing required field "%s"' % where)
    value = obj[key]
    ok = {
        "str": isinstance(value, str),
        "int": isinstance(value, int) and not isinstance(value, bool),
        "num": isinstance(value, (int, float)) and not isinstance(value, bool),
        "bool": isinstance(value, bool),
        "obj": isinstance(value, dict),
        "list": isinstance(value, list),
    }[kind]
    if not ok:
        raise Malformed('wrong type at "%s": expected %s' % (where, kind))
    if choices is not None and value not in choices:
        raise Malformed('invalid value at "%s": "%s" is not one of %s' % (where, value, ", ".join(choices)))
    return value


def check_schema_version(obj, file):
    version = _need(obj, "schemaVersion", "int", "")
    if version < 1 or version > SUPPORTED_SCHEMA_VERSION:
        raise Malformed(
            "%s uses content schema version %d; this validator understands version %d"
            % (file, version, SUPPORTED_SCHEMA_VERSION)
        )


def shape_art(obj, key, path, optional=False):
    art = _need(obj, key, "obj", path, optional=optional)
    if art is None:
        return None
    p = path + "." + key if path else key
    _need(art, "file", "str", p)
    _need(art, "alt", "str", p)
    _need(art, "width", "int", p)
    _need(art, "height", "int", p)
    return art


def shape_chrome(obj, key, path, optional=False):
    chrome = _need(obj, key, "obj", path, optional=optional)
    if chrome is None:
        return
    p = path + "." + key if path else key
    for side in ("leading", "trailing", "folded"):
        _need(chrome, side, "str", p, choices=CHROME_STYLES)


def shape_story(s):
    check_schema_version(s, "story.json")
    _need(s, "id", "str", "")
    _need(s, "contentVersion", "int", "")
    _need(s, "title", "str", "")
    _need(s, "subtitle", "str", "", optional=True)
    _need(s, "tier", "str", "", choices=TIERS)
    _need(s, "language", "str", "")

    region = _need(s, "region", "obj", "")
    _need(region, "id", "str", "region", choices=REGION_IDS)
    for key in ("culture", "place", "label", "pinColor"):
        _need(region, key, "str", "region")
    pin = _need(region, "pin", "obj", "region", optional=True)
    if pin is not None:
        _need(pin, "lat", "num", "region.pin")
        _need(pin, "lon", "num", "region.pin")

    setting = _need(s, "setting", "obj", "")
    _need(setting, "period", "str", "setting")
    _need(setting, "latestYear", "int", "setting", optional=True)

    prov = _need(s, "provenance", "obj", "")
    _need(prov, "kind", "str", "provenance", choices=PROVENANCE_KINDS)
    _need(prov, "rights", "str", "provenance")
    _need(prov, "tradition", "str", "provenance", optional=True)
    _need(prov, "textBasis", "str", "provenance", optional=True, choices=TEXT_BASES)
    _need(prov, "credit", "str", "provenance", optional=True)
    _need(prov, "premise", "str", "provenance", optional=True)
    _need(prov, "authors", "list", "provenance", optional=True)
    for i, src in enumerate(_need(prov, "sources", "list", "provenance", optional=True) or []):
        p = "provenance.sources[%d]" % i
        _need(src, "author", "str", p)
        _need(src, "title", "str", p)
        _need(src, "publisher", "str", p, optional=True)
        _need(src, "year", "int", p)
        _need(src, "gutenbergId", "int", p, optional=True)
        _need(src, "url", "str", p, optional=True)
        _need(src, "verified", "bool", p)

    review = _need(s, "review", "obj", "")
    for key in ("text", "art"):
        record = _need(review, key, "obj", "review")
        _need(record, "status", "str", "review." + key, choices=REVIEW_STATUSES)

    cultural = _need(s, "culturalReview", "obj", "")
    _need(cultural, "level", "str", "culturalReview", choices=CULTURAL_LEVELS)
    _need(cultural, "status", "str", "culturalReview", choices=CULTURAL_STATUSES)
    for key in ("reason", "community", "by", "date", "notes"):
        _need(cultural, key, "str", "culturalReview", optional=True)

    education = _need(s, "education", "obj", "")
    for pillar_name in ("geography", "culture", "moral"):
        pillar = _need(education, pillar_name, "obj", "education")
        _need(pillar, "lesson", "str", "education." + pillar_name)
        _need(pillar, "factCards", "list", "education." + pillar_name, optional=True)
        _need(pillar, "reflectionQuestion", "str", "education." + pillar_name, optional=True)
    _need(s, "moral", "str", "", optional=True)

    sample = _need(s, "sample", "obj", "")
    _need(sample, "freeSpreads", "int", "sample")

    theme = _need(s, "theme", "obj", "")
    _need(theme, "textColor", "str", "theme")
    shape_chrome(theme, "chrome", "theme")
    _need(theme, "accent", "str", "theme", choices=ACCENTS)
    tap = _need(theme, "tap", "obj", "theme")
    for key in ("fill", "fill2", "line", "spark"):
        _need(tap, key, "str", "theme.tap")
    _need(theme, "chipGlass", "str", "theme")

    shape_art(s, "cover", "")

    for i, part in enumerate(_need(s, "parts", "list", "")):
        _need(part, "id", "str", "parts[%d]" % i)
        _need(part, "title", "str", "parts[%d]" % i)

    for i, ch in enumerate(_need(s, "characters", "list", "")):
        p = "characters[%d]" % i
        _need(ch, "id", "str", p)
        _need(ch, "name", "str", p)
        _need(ch, "color", "str", p)
        shape_art(ch, "face", p)
        _need(ch, "chipBackground", "str", p, optional=True)
        card = _need(ch, "card", "obj", p, optional=True)
        if card is not None:
            cp = p + ".card"
            for key in ("label", "title", "body"):
                _need(card, key, "str", cp)
            for j, trait in enumerate(_need(card, "traits", "list", cp)):
                for key in ("text", "fill", "ink"):
                    _need(trait, key, "str", "%s.traits[%d]" % (cp, j))
            shape_art(card, "portrait", cp)
            _need(card, "background", "list", cp)

    for i, t in enumerate(_need(s, "tapTargets", "list", "")):
        p = "tapTargets[%d]" % i
        _need(t, "id", "str", p)
        _need(t, "kind", "str", p, choices=TARGET_KINDS)
        _need(t, "title", "str", p, optional=True)
        _need(t, "subtitle", "str", p, optional=True)
        _need(t, "line", "str", p, optional=True)
        note = _need(t, "cultureNote", "obj", p, optional=True)
        if note is not None:
            _need(note, "label", "str", p + ".cultureNote")
            _need(note, "text", "str", p + ".cultureNote")
        shape_art(t, "picture", p, optional=True)
        _need(t, "background", "str", p)
        ref = _need(t, "landmark", "obj", p, optional=True)
        if ref is not None:
            rp = p + ".landmark"
            _need(ref, "id", "str", rp)
            _need(ref, "appearance", "str", rp, choices=APPEARANCES)
            device = _need(ref, "framingDevice", "obj", rp, optional=True)
            if device is not None:
                _need(device, "kind", "str", rp + ".framingDevice", choices=DEVICE_KINDS)
                _need(device, "label", "str", rp + ".framingDevice")
                _need(device, "line", "str", rp + ".framingDevice")

    for i, spread in enumerate(_need(s, "spreads", "list", "")):
        p = "spreads[%d]" % i
        _need(spread, "id", "str", p)
        _need(spread, "part", "str", p)
        scene = _need(spread, "scene", "obj", p)
        shape_art(scene, "unfolded", p + ".scene")
        shape_art(scene, "folded", p + ".scene")
        _need(scene, "fallbackColors", "list", p + ".scene")
        area = _need(scene, "textArea", "obj", p + ".scene", optional=True)
        if area is not None:
            _need(area, "leadingBottom", "num", p + ".scene.textArea", optional=True)
            _need(area, "trailingBottom", "num", p + ".scene.textArea", optional=True)
        shape_chrome(spread, "chrome", p, optional=True)
        for j, block in enumerate(_need(spread, "blocks", "list", p)):
            bp = "%s.blocks[%d]" % (p, j)
            _need(block, "id", "str", bp)
            _need(block, "pane", "str", bp, choices=PANES)
            _need(block, "kind", "str", bp, choices=BLOCK_KINDS)
            _need(block, "path", "str", bp, optional=True)
            for k, run in enumerate(_need(block, "runs", "list", bp)):
                rp = "%s.runs[%d]" % (bp, k)
                _need(run, "t", "str", rp)
                _need(run, "lead", "bool", rp, optional=True)
                _need(run, "chip", "bool", rp, optional=True)
                for key in ("say", "name", "tap"):
                    _need(run, key, "str", rp, optional=True)
                _need(run, "fx", "str", rp, optional=True, choices=RUN_EFFECTS)
                _need(run, "scale", "num", rp, optional=True)


def shape_landmarks(c):
    check_schema_version(c, "landmarks.json")
    for i, lm in enumerate(_need(c, "landmarks", "list", "")):
        p = "landmarks[%d]" % i
        _need(lm, "id", "str", p)
        _need(lm, "name", "str", p)
        _need(lm, "localName", "str", p, optional=True)
        _need(lm, "era", "str", p, choices=ERAS)
        built = _need(lm, "built", "obj", p, optional=True)
        if built is not None:
            _need(built, "from", "int", p + ".built")
            _need(built, "to", "int", p + ".built", optional=True)
            _need(built, "circa", "bool", p + ".built")
            _need(built, "note", "str", p + ".built", optional=True)
        _need(lm, "status", "str", p, choices=LANDMARK_STATUSES)
        _need(lm, "depiction", "str", p, choices=DEPICTIONS)
        _need(lm, "country", "str", p)
        _need(lm, "place", "str", p, optional=True)
        coords = _need(lm, "coordinates", "obj", p)
        _need(coords, "lat", "num", p + ".coordinates")
        _need(coords, "lon", "num", p + ".coordinates")
        _need(lm, "region", "str", p, optional=True, choices=REGION_IDS)
        for j, name in enumerate(_need(lm, "lists", "list", p)):
            if name not in LANDMARK_LISTS:
                raise Malformed('invalid value at "%s.lists[%d]": "%s"' % (p, j, name))
        cards = _need(lm, "factCards", "obj", p)
        for tier in TIERS:
            card = _need(cards, tier, "obj", p + ".factCards")
            _need(card, "line", "str", "%s.factCards.%s" % (p, tier))
            _need(card, "note", "str", "%s.factCards.%s" % (p, tier), optional=True)
        shape_art(lm, "art", p)
        _need(lm, "background", "str", p)
        _need(lm, "rights", "str", p, optional=True)
        review = _need(lm, "review", "obj", p)
        _need(review, "facts", "str", p + ".review", choices=REVIEW_STATUSES)
        _need(review, "art", "str", p + ".review", choices=REVIEW_STATUSES)


def shape_catalog(c):
    check_schema_version(c, "catalog.json")
    _need(c, "catalogVersion", "int", "")
    for i, sid in enumerate(_need(c, "stories", "list", "")):
        if not isinstance(sid, str):
            raise Malformed('wrong type at "stories[%d]": expected str' % i)


# ---------------------------------------------------------------- text on a path

_PATH_ARITY = {"M": 2, "L": 2, "Q": 4, "C": 6}
_PATH_TOKEN_RE = re.compile(r"[MLQC]|-?(?:[0-9]+\.?[0-9]*|\.[0-9]+)")
TEXT_AREA_RANGE = (200, 720)


def parse_path(text):
    """The curve of a `pathText` block: absolute M, L, Q and C commands only (the subset the app
    draws). Returns a list of (command, [numbers]), or None when the text is not such a path.
    Mirrors `SVGPath` in OmramoCore."""
    if not isinstance(text, str):
        return None
    # Separators are exactly the ones the Swift parser accepts: space, comma, tab, CR, LF.
    if re.sub(r"[ ,\n\t\r]+", "", _PATH_TOKEN_RE.sub("", text)) != "":
        return None
    tokens = _PATH_TOKEN_RE.findall(text)
    segments, i, command = [], 0, None
    while i < len(tokens):
        if tokens[i] in _PATH_ARITY:
            command = tokens[i]
            i += 1
        if command is None:
            return None
        arity = _PATH_ARITY[command]
        numbers = tokens[i:i + arity]
        if len(numbers) != arity or any(n in _PATH_ARITY for n in numbers):
            return None
        segments.append((command, [float(n) for n in numbers]))
        i += arity
        if command == "M":
            command = "L"  # further pairs after a move are lines, as in SVG
    if len(segments) < 2 or segments[0][0] != "M":
        return None
    if any(seg[0] == "M" for seg in segments[1:]):
        return None
    return segments


# ---------------------------------------------------------------- text fidelity

_QUOTE_MAP = {
    "“": '"', "”": '"', "„": '"', "«": '"', "»": '"',
    "‘": "'", "’": "'", "‚": "'",
    "‐": "-", "‑": "-", "‒": "-", "–": "-", "—": "-", "―": "-", "−": "-",
    "…": "...",
}
_SPACES = set("\t\n\r     ")


def normalize(text):
    out = []
    pending_space = False
    last_was_dash = False
    for ch in text:
        piece = _QUOTE_MAP.get(ch, ch)
        if ch in _SPACES:
            pending_space = True
            continue
        if piece == "-":
            if last_was_dash and not pending_space:
                continue
            last_was_dash = True
        else:
            last_was_dash = False
        if pending_space and out:
            out.append(" ")
        pending_space = False
        out.append(piece)
    return "".join(out)


def manuscript_body(manuscript):
    return "\n".join(line for line in manuscript.splitlines() if not line.lstrip(" \t").startswith("#"))


def block_text(block):
    return "".join(run["t"] for run in block["runs"])


def story_text(story):
    return "\n".join(block_text(b) for s in story["spreads"] for b in s["blocks"])


def compare_text(story, manuscript):
    expected = normalize(manuscript_body(manuscript))
    found = normalize(story_text(story))
    i = 0
    while i < len(expected) and i < len(found) and expected[i] == found[i]:
        i += 1
    if i == len(expected) and i == len(found):
        return None
    def excerpt(s):
        return s[max(0, i - 12): i + 28] or "(end of text)"
    return i, excerpt(expected), excerpt(found)


# ---------------------------------------------------------------- rules

def blank(text):
    return text is None or text.strip() == ""


def duplicates(ids):
    seen, repeated = set(), []
    for i in ids:
        if i in seen and i not in repeated:
            repeated.append(i)
        seen.add(i)
    return repeated


def check_art(rep, file, art, path, art_exists):
    if blank(art["alt"]):
        rep.add("error", "missing-alt", file, path + ".alt", "every picture needs alt text")
    if blank(art["file"]) or art["width"] <= 0 or art["height"] <= 0:
        rep.add("error", "bad-art-size", file, path, "a picture needs a file name and a pixel width and height above zero")
    if art_exists is not None and not blank(art["file"]) and not art_exists(art["file"]):
        rep.add(rep.pending, "art-file-missing", file, path + ".file",
                'image file "%s" does not exist (placeholder art)' % art["file"])


def check_color(rep, file, value, path):
    if not isinstance(value, str) or not COLOR_RE.match(value):
        rep.add("error", "bad-color", file, path, '"%s" is not a colour; use #RRGGBB or #RRGGBBAA' % value)


def validate_story(rep, file, story, landmarks, manuscript, art_exists=None):
    """`landmarks` is the decoded landmark catalog (dict). `manuscript` is text or None."""
    E, W = "error", "warning"

    # identity
    for label, ids in (
        ("part", [p["id"] for p in story["parts"]]),
        ("character", [c["id"] for c in story["characters"]]),
        ("tap-target", [t["id"] for t in story["tapTargets"]]),
        ("spread", [s["id"] for s in story["spreads"]]),
        ("block", [b["id"] for s in story["spreads"] for b in s["blocks"]]),
    ):
        for dup in duplicates(ids):
            rep.add(E, "duplicate-id", file, label + "s", '%s id "%s" is used more than once' % (label, dup))
    if blank(story["title"]):
        rep.add(E, "empty-text", file, "title", "the story has no title")
    if not story["spreads"]:
        rep.add(E, "empty-text", file, "spreads", "the story has no spreads")

    # runs
    part_ids = {p["id"] for p in story["parts"]}
    character_ids = {c["id"] for c in story["characters"]}
    target_ids = {t["id"] for t in story["tapTargets"]}
    used_targets = set()
    target_words = TARGET_WORDS[story["tier"]]
    word_limit = int(target_words * WORD_ALLOWANCE + 0.5)  # round half up, as Swift's rounded() does
    for si, spread in enumerate(story["spreads"]):
        sp = "spreads[%d]" % si
        if spread["part"] not in part_ids:
            rep.add(E, "dangling-part", file, sp + ".part", 'part "%s" is not in parts[]' % spread["part"])
        if not spread["blocks"]:
            rep.add(E, "empty-text", file, sp + ".blocks", "the spread has no text blocks")
        words = sum(len(block_text(b).split()) for b in spread["blocks"])
        if words > word_limit:
            rep.add(W, "words-per-spread", file, sp,
                    "%d words; the %s tier aims for about %d a page" % (words, story["tier"], target_words))
        for bi, block in enumerate(spread["blocks"]):
            bp = "%s.blocks[%d]" % (sp, bi)
            if not block["runs"]:
                rep.add(E, "empty-text", file, bp + ".runs", "the block has no runs")
            if block["kind"] == "pathText":
                if parse_path(block.get("path")) is None:
                    rep.add(E, "path-text-incomplete", file, bp + ".path",
                            "a pathText block needs a path of absolute M, L, Q and C commands")
            elif block.get("path") is not None:
                rep.add(E, "path-text-incomplete", file, bp + ".path", "only a pathText block may have a path")
            for ri, run in enumerate(block["runs"]):
                rp = "%s.runs[%d]" % (bp, ri)
                if run["t"] == "":
                    rep.add(E, "empty-text", file, rp + ".t", "a run has empty text")
                tap, name, say = run.get("tap"), run.get("name"), run.get("say")
                if tap is not None and name is not None:
                    rep.add(E, "tap-and-name", file, rp, 'a run may have "tap" or "name", not both')
                if tap is not None:
                    used_targets.add(tap)
                    if tap not in target_ids:
                        rep.add(E, "dangling-tap", file, rp + ".tap", 'tap target "%s" is not in tapTargets[]' % tap)
                if name is not None and name not in character_ids:
                    rep.add(E, "dangling-name", file, rp + ".name", 'character "%s" is not in characters[]' % name)
                if say is not None and say not in character_ids:
                    rep.add(E, "dangling-say", file, rp + ".say", 'character "%s" is not in characters[]' % say)
    for ti, target in enumerate(story["tapTargets"]):
        if target["id"] not in used_targets:
            rep.add(W, "unused-tap-target", file, "tapTargets[%d]" % ti,
                    'tap target "%s" is not marked on any word' % target["id"])

    # art and colours
    check_art(rep, file, story["cover"], "cover", art_exists)
    check_color(rep, file, story["region"]["pinColor"], "region.pinColor")
    theme = story["theme"]
    check_color(rep, file, theme["textColor"], "theme.textColor")
    for key in ("fill", "fill2", "line", "spark"):
        check_color(rep, file, theme["tap"][key], "theme.tap." + key)
    check_color(rep, file, theme["chipGlass"], "theme.chipGlass")
    for ci, ch in enumerate(story["characters"]):
        cp = "characters[%d]" % ci
        if blank(ch["name"]):
            rep.add(E, "empty-text", file, cp + ".name", "a character needs a name")
        check_color(rep, file, ch["color"], cp + ".color")
        if ch.get("chipBackground") is not None:
            check_color(rep, file, ch["chipBackground"], cp + ".chipBackground")
        check_art(rep, file, ch["face"], cp + ".face", art_exists)
        card = ch.get("card")
        if card is not None:
            check_art(rep, file, card["portrait"], cp + ".card.portrait", art_exists)
            for i, color in enumerate(card["background"]):
                check_color(rep, file, color, "%s.card.background[%d]" % (cp, i))
            for i, trait in enumerate(card["traits"]):
                check_color(rep, file, trait["fill"], "%s.card.traits[%d].fill" % (cp, i))
                check_color(rep, file, trait["ink"], "%s.card.traits[%d].ink" % (cp, i))
    for si, spread in enumerate(story["spreads"]):
        sp = "spreads[%d].scene" % si
        check_art(rep, file, spread["scene"]["unfolded"], sp + ".unfolded", art_exists)
        check_art(rep, file, spread["scene"]["folded"], sp + ".folded", art_exists)
        for i, color in enumerate(spread["scene"]["fallbackColors"]):
            check_color(rep, file, color, "%s.fallbackColors[%d]" % (sp, i))
        area = spread["scene"].get("textArea") or {}
        for key in ("leadingBottom", "trailingBottom"):
            value = area.get(key)
            if value is not None and not (TEXT_AREA_RANGE[0] <= value <= TEXT_AREA_RANGE[1]):
                rep.add(E, "text-area-range", file, "%s.textArea.%s" % (sp, key),
                        "the text area must end between %d and %d points down the 720-point reference pane"
                        % TEXT_AREA_RANGE)

    # sample
    free = story["sample"]["freeSpreads"]
    if free < 0 or free > len(story["spreads"]):
        rep.add(E, "free-spreads-range", file, "sample.freeSpreads",
                "freeSpreads is %d; the story has %d spreads" % (free, len(story["spreads"])))

    # region
    region = story["region"]
    if blank(region["culture"]):
        rep.add(E, "region-incomplete", file, "region.culture", "name the specific people or tradition (never a continent)")
    if blank(region["place"]):
        rep.add(E, "region-incomplete", file, "region.place", "name the place")
    if blank(region["label"]):
        rep.add(E, "region-incomplete", file, "region.label", "the origin chip needs a label")
    pin = region.get("pin")
    if pin is not None and not (-90 <= pin["lat"] <= 90 and -180 <= pin["lon"] <= 180):
        rep.add(E, "pin-out-of-range", file, "region.pin", "latitude must be -90...90 and longitude -180...180")
    if blank(story["setting"]["period"]):
        rep.add(E, "region-incomplete", file, "setting.period", "say when the story is set")

    # provenance
    prov = story["provenance"]
    if blank(prov["rights"]):
        rep.add(E, "provenance-incomplete", file, "provenance.rights", "state the rights basis")
    if prov["kind"] == "publicDomainRetelling":
        sources = prov.get("sources") or []
        if not sources:
            rep.add(E, "provenance-no-source", file, "provenance.sources",
                    "a public-domain retelling must cite at least one source")
        for i, src in enumerate(sources):
            if blank(src["author"]) or blank(src["title"]) or src["year"] <= 0:
                rep.add(E, "provenance-source-incomplete", file, "provenance.sources[%d]" % i,
                        "a source needs an author, a title and a year")
        if blank(prov.get("tradition")):
            rep.add(E, "provenance-incomplete", file, "provenance.tradition", "name the tradition the tale comes from")
        if prov.get("textBasis") is None:
            rep.add(E, "provenance-incomplete", file, "provenance.textBasis",
                    "say whether the text is sourceVerbatim or omramoRetelling")
    else:
        if blank(prov.get("credit")):
            rep.add(E, "original-incomplete", file, "provenance.credit", "an original story needs its credit line")
        if blank(prov.get("premise")):
            rep.add(E, "original-incomplete", file, "provenance.premise", "an original story needs its premise")

    # reviews
    for key in ("text", "art"):
        if story["review"][key]["status"] == "pending":
            rep.add(rep.pending, "review-pending", file, "review." + key, "%s review is pending" % key)
    cultural = story["culturalReview"]
    if cultural["level"] == "required":
        if blank(cultural.get("reason")):
            rep.add(E, "cultural-review-no-reason", file, "culturalReview.reason",
                    "a required cultural review must say why it is required")
        if cultural["status"] != "approved":
            rep.add(rep.pending, "cultural-review-not-approved", file, "culturalReview.status",
                    "required cultural review is %s; the story cannot ship until it is approved" % cultural["status"])
    elif cultural["status"] != "approved":
        rep.add(W, "cultural-review-not-approved", file, "culturalReview.status",
                "standard cultural review is %s" % cultural["status"])

    # education
    for name in ("geography", "culture", "moral"):
        pillar = story["education"][name]
        if blank(pillar["lesson"]):
            rep.add(E, "education-incomplete", file, "education.%s.lesson" % name, "the %s lesson is empty" % name)
        for i, tid in enumerate(pillar.get("factCards") or []):
            if tid not in target_ids:
                rep.add(E, "education-fact-card-dangling", file, "education.%s.factCards[%d]" % (name, i),
                        '"%s" is not a tap target of this story' % tid)

    # the one sentence shown to the child when the story is finished (Swift: MoralRule)
    problem = moral_problem(story.get("moral"))
    if problem:
        rep.add(E, "moral-incomplete", file, "moral", problem)

    # tap targets and landmarks
    by_id = {lm["id"]: lm for lm in landmarks["landmarks"]}
    landmark_targets = 0
    for ti, target in enumerate(story["tapTargets"]):
        tp = "tapTargets[%d]" % ti
        check_color(rep, file, target["background"], tp + ".background")
        if target["kind"] != "landmark":
            if target.get("landmark") is not None:
                rep.add(E, "landmark-target-shape", file, tp + ".landmark",
                        'only a target of kind "landmark" may have a landmark reference')
            if blank(target.get("title")) or blank(target.get("line")) or target.get("picture") is None:
                rep.add(E, "tap-target-incomplete", file, tp, "a tap target needs a title, a line to read and a picture")
            if target.get("picture") is not None:
                check_art(rep, file, target["picture"], tp + ".picture", art_exists)
            continue
        landmark_targets += 1
        if any(target.get(k) is not None for k in ("title", "line", "cultureNote", "picture")):
            rep.add(E, "landmark-target-shape", file, tp,
                    "a landmark target takes its title, line, note and picture from the landmark catalog; omit them here")
        ref = target.get("landmark")
        if ref is None:
            rep.add(E, "landmark-target-shape", file, tp + ".landmark", 'a target of kind "landmark" needs a landmark reference')
            continue
        device = ref.get("framingDevice")
        if ref["appearance"] == "framed":
            if device is None:
                rep.add(E, "framed-without-device", file, tp + ".landmark", 'appearance "framed" needs a framingDevice')
            elif blank(device["label"]) or blank(device["line"]):
                rep.add(E, "framed-without-device", file, tp + ".landmark.framingDevice",
                        "a framing device needs a label and a line")
        landmark = by_id.get(ref["id"])
        if landmark is None:
            rep.add(E, "dangling-landmark", file, tp + ".landmark.id",
                    'landmark "%s" is not in the landmark catalog' % ref["id"])
            continue
        latest = story["setting"].get("latestYear")
        built = landmark.get("built")
        if latest is not None and built is not None and built["from"] > latest and ref["appearance"] != "framed":
            rep.add(E, "landmark-anachronism", file, tp + ".landmark.appearance",
                    '%s was built in %d, after this story\'s world (%d); it must be "framed"'
                    % (landmark["name"], built["from"], latest))
        if landmark.get("region") != region["id"]:
            kind = device["kind"] if device is not None else None
            if not (ref["appearance"] == "framed" and kind in ("worldLink", "mapMoment")):
                rep.add(E, "landmark-out-of-region", file, tp + ".landmark",
                        '%s is outside this story\'s region; it must be "framed" with a worldLink or mapMoment device'
                        % landmark["name"])
    if landmark_targets > MAX_LANDMARKS_PER_STORY:
        rep.add(W, "too-many-landmarks", file, "tapTargets",
                "%d landmark targets; the plan allows at most %d a story" % (landmark_targets, MAX_LANDMARKS_PER_STORY))

    # text fidelity
    if manuscript is None:
        rep.add(rep.pending, "manuscript-missing", file, "sources/%s.txt" % story["id"],
                "there is no manuscript to check the story text against")
    else:
        mismatch = compare_text(story, manuscript)
        if mismatch is not None:
            rep.add(E, "text-fidelity", file, "spreads",
                    'story text differs from the manuscript at character %d: manuscript has "%s", story has "%s"' % mismatch)


def validate_landmarks(rep, file, catalog, art_exists=None):
    E = "error"
    for dup in duplicates([lm["id"] for lm in catalog["landmarks"]]):
        rep.add(E, "duplicate-id", file, "landmarks", 'landmark id "%s" is used more than once' % dup)
    for i, lm in enumerate(catalog["landmarks"]):
        p = "landmarks[%d]" % i
        if blank(lm["name"]) or blank(lm["country"]):
            rep.add(E, "landmark-incomplete", file, p, "a landmark needs a name and a country")
        built = lm.get("built")
        if lm["era"] == "natural":
            if lm["status"] != "natural":
                rep.add(E, "landmark-built", file, p + ".status", 'a landmark of era "natural" must have status "natural"')
        else:
            if lm["status"] == "natural":
                rep.add(E, "landmark-built", file, p + ".status", 'status "natural" is only for landmarks of era "natural"')
            if built is None:
                rep.add(E, "landmark-built", file, p + ".built", "a built landmark needs its built year")
            elif built.get("to") is not None and built["to"] < built["from"]:
                rep.add(E, "landmark-built", file, p + ".built", "built.to is earlier than built.from")
        c = lm["coordinates"]
        if not (-90 <= c["lat"] <= 90 and -180 <= c["lon"] <= 180):
            rep.add(E, "landmark-coordinates", file, p + ".coordinates", "latitude must be -90...90 and longitude -180...180")
        if not lm["lists"]:
            rep.add(E, "landmark-no-list", file, p + ".lists", "a landmark belongs to at least one list")
        for tier in TIERS:
            if blank(lm["factCards"][tier]["line"]):
                rep.add(E, "landmark-fact-card", file, "%s.factCards.%s.line" % (p, tier), "the %s fact card has no line" % tier)
        if lm["status"] in ("lost", "unproven") and lm["depiction"] != "reconstruction":
            rep.add(E, "landmark-not-reconstruction", file, p + ".depiction",
                    "a lost or unproven landmark must be shown as a reconstruction")
        check_art(rep, file, lm["art"], p + ".art", art_exists)
        check_color(rep, file, lm["background"], p + ".background")
        if lm["review"]["facts"] == "pending":
            rep.add(rep.pending, "review-pending", file, p + ".review.facts", "fact check is pending")
        if lm["review"]["art"] == "pending":
            rep.add(rep.pending, "review-pending", file, p + ".review.art", "art review is pending")


def validate_catalog(rep, file, catalog, loaded_ids):
    for dup in duplicates(catalog["stories"]):
        rep.add("error", "catalog-duplicate", file, "stories", 'story "%s" is listed more than once' % dup)
    for i, sid in enumerate(catalog["stories"]):
        actual = loaded_ids.get(sid)
        if actual is not None and actual != sid:
            rep.add("error", "catalog-story-mismatch", file, "stories[%d]" % i,
                    'folder "%s" holds a story whose id is "%s"' % (sid, actual))


# ---------------------------------------------------------------- driver

def load_json(path):
    with open(path, "r", encoding="utf-8") as handle:
        return json.load(handle)


def validate_tree(root, release=False, check_art=False):
    """Validate a whole content folder. Returns a Report. Raises Malformed / OSError / ValueError
    when a file is missing or does not have the shape of the schema."""
    rep = Report(release)

    catalog = load_json(os.path.join(root, "catalog.json"))
    shape_catalog(catalog)

    lm_file = "landmarks/landmarks.json"
    landmarks = load_json(os.path.join(root, "landmarks", "landmarks.json"))
    shape_landmarks(landmarks)
    lm_art = (lambda f: os.path.isfile(os.path.join(root, "landmarks", f))) if check_art else None
    validate_landmarks(rep, lm_file, landmarks, lm_art)

    loaded = {}
    for sid in catalog["stories"]:
        if sid in loaded:
            continue
        file = "stories/%s/story.json" % sid
        story = load_json(os.path.join(root, "stories", sid, "story.json"))
        try:
            shape_story(story)
        except Malformed as error:
            raise Malformed("%s: %s" % (file, error))
        loaded[sid] = story["id"]
        manuscript_path = os.path.join(root, "sources", sid + ".txt")
        manuscript = None
        if os.path.isfile(manuscript_path):
            with open(manuscript_path, "r", encoding="utf-8") as handle:
                manuscript = handle.read()
        story_art = (lambda f, sid=sid: os.path.isfile(os.path.join(root, "stories", sid, f))) if check_art else None
        validate_story(rep, file, story, landmarks, manuscript, story_art)

    validate_catalog(rep, "catalog.json", catalog, loaded)
    return rep


def main(argv):
    args = [a for a in argv[1:] if not a.startswith("--")]
    flags = {a for a in argv[1:] if a.startswith("--")}
    unknown = flags - {"--release", "--check-art", "--quiet"}
    if unknown or len(args) > 1:
        print(__doc__)
        return 2
    here = os.path.dirname(os.path.abspath(__file__))
    default_root = os.path.join(here, "..", "Packages", "OmramoCore", "Sources", "OmramoCore", "Resources", "Content")
    root = args[0] if args else os.path.normpath(default_root)

    try:
        rep = validate_tree(root, release="--release" in flags, check_art="--check-art" in flags)
    except Malformed as error:
        print("error [malformed] %s" % error)
        return 1
    except (OSError, ValueError) as error:
        print("error [unreadable] %s" % error)
        return 2

    for severity, code, file, location, message in rep.issues:
        if severity == "warning" and "--quiet" in flags:
            continue
        print("%s [%s] %s: %s: %s" % (severity, code, file, location, message))
    print("%d error(s), %d warning(s) in %s" % (len(rep.errors()), len(rep.warnings()), root))
    return 1 if rep.errors() else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
