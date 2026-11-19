#!/usr/bin/env python3
"""Builds story.json files and manuscripts from compact story specs. Python 3, stdlib only.

    python3 tools/build_stories.py            # build every spec
    python3 tools/build_stories.py --check    # exit 1 if a generated file is out of date
    python3 tools/build_stories.py ID [ID…]   # build only these stories

A spec (docs/content/story-specs/<id>.json) is the authoring form of a story: the header
fields of story.json as they are, plus short forms for the repetitive parts (scenes, pages
written as marked-up paragraphs, characters, tap targets) and the catalog entries of any
landmark the story introduces. From each spec this tool writes

    <Content>/stories/<id>/story.json     the shipped story (schema version 1)
    <Content>/sources/<id>.txt            the manuscript for the text-fidelity check

and merges the spec's landmarks into <Content>/landmarks/landmarks.json (by id).

The three prototype stories (monkey-and-crocodile, anansi-wisdom, urashima-taro) have no
spec; their story.json files are edited by hand. Run tools/validate_content.py afterwards.

Paragraph mark-up (see docs/agent-runs/r5-batch-notes.md):
    ^ at the start        the paragraph is a lead (the large first line of a part)
    <say:ID>…</say>       spoken by character ID;  <say:ID*> also shows the face chip
    <name:ID>…</name>     a character's name that opens the character card
    <tap:ID>…</tap>       a tap-to-see word or phrase
    <pop:1.3>…</pop>      a word that pops at that scale;  <stretch>…</stretch> a stretched word
Tags nest (a tap word inside speech). Prose uses typographic quotes (“ ” ‘ ’); a straight
quote in a paragraph is an error.

Panes (round 5, batch 3 — Advanced stories put text on both panes, like urashima-taro):
    "> …"                 a paragraph on the trailing pane (the marker comes before any ^)
    {"path": "M… C…", "text": "…"}
                          a pathText block drawn along the curve (trailing pane unless
                          "pane": "leading"); absolute M, L, Q and C commands only
Leading paragraphs come first on a page, then trailing ones.
"""

import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.normpath(os.path.join(HERE, ".."))
SPECS = os.path.join(REPO, "docs", "content", "story-specs")
CONTENT = os.path.join(REPO, "Packages", "OmramoCore", "Sources", "OmramoCore", "Resources", "Content")

TAG_RE = re.compile(r"<(/?)([a-z]*)(?::([^>*]+))?(\*?)>")
TAGS = ("say", "name", "tap", "pop", "stretch")


class SpecError(Exception):
    pass


def parse_paragraph(text, where):
    """Marked-up paragraph → (is_lead, [run dicts])."""
    lead = text.startswith("^")
    if lead:
        text = text[1:]
    if '"' in text or "'" in text:
        raise SpecError("%s: straight quote in prose; use “ ” ‘ ’" % where)
    runs = []
    stack = []  # (tag, value, chip_pending)
    chip_given = set()
    pos = 0

    def emit(piece):
        if piece == "":
            return
        run = {"t": piece}
        if lead:
            run["lead"] = True
        for index, (tag, value, chip) in enumerate(stack):
            if tag == "say":
                run["say"] = value
                if chip and index not in chip_given:
                    run["chip"] = True
                    chip_given.add(index)
            elif tag == "name":
                run["name"] = value
            elif tag == "tap":
                run["tap"] = value
            elif tag == "pop":
                run["fx"] = "pop"
                run["scale"] = float(value) if value else 1.25
            elif tag == "stretch":
                run["fx"] = "stretch"
        # Keep the key order of the hand-written stories: t, lead, say, chip, name, tap, fx, scale.
        ordered = {}
        for key in ("t", "lead", "say", "chip", "name", "tap", "fx", "scale"):
            if key in run:
                ordered[key] = run[key]
        runs.append(ordered)

    for match in TAG_RE.finditer(text):
        emit(text[pos:match.start()])
        pos = match.end()
        closing, tag, value, star = match.group(1), match.group(2), match.group(3), match.group(4)
        if closing:
            if not stack:
                raise SpecError("%s: closing tag with nothing open" % where)
            if tag and stack[-1][0] != tag:
                raise SpecError("%s: </%s> closes <%s>" % (where, tag, stack[-1][0]))
            closed = stack.pop()
            chip_given.discard(len(stack))
            if closed[0] == "say" and closed[2] and len(stack) not in chip_given:
                pass
        else:
            if tag not in TAGS:
                raise SpecError("%s: unknown tag <%s>" % (where, tag))
            if tag in ("say", "name", "tap") and not value:
                raise SpecError("%s: <%s> needs an id" % (where, tag))
            stack.append((tag, value, bool(star)))
    emit(text[pos:])
    if stack:
        raise SpecError("%s: <%s> is never closed" % (where, stack[-1][0]))
    if "<" in "".join(r["t"] for r in runs) or ">" in "".join(r["t"] for r in runs):
        raise SpecError("%s: stray < or > (a mistyped tag?)" % where)
    if not runs:
        raise SpecError("%s: empty paragraph" % where)
    return lead, runs


def art(file, alt, width, height):
    return {"file": file, "alt": alt, "width": width, "height": height}


def build_story(spec):
    sid = spec["id"]
    story = {
        "schemaVersion": 1,
        "id": sid,
        "contentVersion": spec.get("contentVersion", 1),
        "title": spec["title"],
    }
    if spec.get("subtitle"):
        story["subtitle"] = spec["subtitle"]
    story["tier"] = spec["tier"]
    story["language"] = "en"
    story["region"] = spec["region"]
    story["setting"] = spec["setting"]
    story["provenance"] = spec["provenance"]
    story["review"] = {"text": {"status": "pending"}, "art": {"status": "pending"}}
    story["culturalReview"] = spec["culturalReview"]
    story["education"] = spec["education"]
    story["moral"] = spec["moral"]
    story["sample"] = {"freeSpreads": spec.get("freeSpreads", 2)}
    story["theme"] = spec["theme"]
    story["cover"] = art("art/cover.heic", spec["cover"]["alt"], 720, 900)
    story["parts"] = spec["parts"]

    characters = []
    for ch in spec["characters"]:
        out = {
            "id": ch["id"],
            "name": ch["name"],
            "color": ch["color"],
            "face": art("art/face-%s.png" % ch["id"], ch["faceAlt"], 144, 144),
        }
        if ch.get("chipBackground"):
            out["chipBackground"] = ch["chipBackground"]
        card = ch.get("card")
        if card:
            out["card"] = {
                "label": card["label"],
                "title": card["title"],
                "traits": card["traits"],
                "body": card["body"],
                "portrait": art("art/char-%s.card.heic" % ch["id"], card["portraitAlt"], 1296, 1200),
                "background": card["background"],
            }
        characters.append(out)
    story["characters"] = characters

    targets = []
    for t in spec["tapTargets"]:
        if t["kind"] == "landmark":
            targets.append({"id": t["id"], "kind": "landmark", "landmark": t["landmark"], "background": t["background"]})
            continue
        out = {"id": t["id"], "kind": t["kind"], "title": t["title"]}
        if t.get("subtitle"):
            out["subtitle"] = t["subtitle"]
        out["line"] = t["line"]
        if t.get("cultureNote"):
            out["cultureNote"] = t["cultureNote"]
        out["picture"] = art("art/see-%s.heic" % t["id"], t["pictureAlt"], 1296, 1212)
        out["background"] = t["background"]
        targets.append(out)
    story["tapTargets"] = targets

    scenes = spec["scenes"]
    part_ids = [p["id"] for p in spec["parts"]]
    spreads = []
    for index, page in enumerate(spec["pages"], start=1):
        scene = scenes.get(page["scene"])
        if scene is None:
            raise SpecError("%s page %d: scene %r is not in scenes" % (sid, index, page["scene"]))
        if page["part"] not in part_ids:
            raise SpecError("%s page %d: part %r is not in parts" % (sid, index, page["part"]))
        name = page["scene"]
        scene_out = {
            "unfolded": art("art/%s.unfolded.heic" % name, scene["unfoldedAlt"], 2676, 2160),
            "folded": art("art/%s.folded.heic" % name, scene["foldedAlt"], 1296, 2160),
            "fallbackColors": scene["fallbackColors"],
        }
        if scene.get("textArea"):
            scene_out["textArea"] = scene["textArea"]
        spread_id = "s%02d" % index
        blocks = []
        seen_trailing = False
        for b, para in enumerate(page["paras"], start=1):
            where = "%s page %d paragraph %d" % (sid, index, b)
            block_id = "%s-b%d" % (spread_id, b)
            if isinstance(para, dict):
                # {"path": "M… C…", "text": "…"} → a pathText block (trailing pane by default).
                pane = para.get("pane", "trailing")
                if pane not in ("leading", "trailing"):
                    raise SpecError("%s: pane must be leading or trailing" % where)
                if not para.get("path"):
                    raise SpecError("%s: a pathText paragraph needs a path" % where)
                _, runs = parse_paragraph(para["text"], where)
                if pane == "leading" and seen_trailing:
                    raise SpecError("%s: a leading paragraph after a trailing one" % where)
                seen_trailing = seen_trailing or pane == "trailing"
                blocks.append({"id": block_id, "pane": pane, "kind": "pathText", "path": para["path"], "runs": runs})
                continue
            pane = "leading"
            if para.startswith(">"):
                # "> …" puts the paragraph on the trailing pane (Advanced stories, like Urashima).
                pane = "trailing"
                para = para[1:].lstrip(" ")
            if pane == "leading" and seen_trailing:
                raise SpecError("%s: a leading paragraph after a trailing one" % where)
            seen_trailing = seen_trailing or pane == "trailing"
            _, runs = parse_paragraph(para, where)
            blocks.append({"id": block_id, "pane": pane, "kind": "paragraph", "runs": runs})
        spread = {"id": spread_id, "part": page["part"], "scene": scene_out}
        if scene.get("chrome"):
            spread["chrome"] = scene["chrome"]
        spread["blocks"] = blocks
        spreads.append(spread)
    story["spreads"] = spreads
    return story


def build_manuscript(spec, story):
    lines = ["# " + spec["title"]]
    lines.append("# Omramo %s, %s tier. Manuscript for the text-fidelity check."
                 % ("original story" if spec["provenance"]["kind"] == "original" else "retelling",
                    spec["tier"].capitalize()))
    lines.append("#")
    for note in spec.get("sourceNotes", []):
        lines.append(("# " + note) if note else "#")
    lines.append("#")
    lines.append("# Generated by tools/build_stories.py from docs/content/story-specs/%s.json; edit the spec," % spec["id"])
    lines.append("# not this file.")
    lines.append("#")
    lines.append('# Format: lines starting with "#" are notes and are not story text. One paragraph per line.')
    lines.append('# A blank line separates paragraphs; a "# --- page" note marks a page (spread) break.')
    titles = {p["id"]: p["title"] for p in spec["parts"]}
    last_part = None
    for index, spread in enumerate(story["spreads"], start=1):
        if spread["part"] != last_part:
            last_part = spread["part"]
            lines.append("")
            lines.append("# " + titles[last_part])
        lines.append("")
        lines.append("# --- page %d" % index)
        for b, block in enumerate(spread["blocks"]):
            if b:
                lines.append("")
            lines.append("".join(run["t"] for run in block["runs"]))
    return "\n".join(lines) + "\n"


def dump(obj):
    return json.dumps(obj, indent=2, ensure_ascii=False) + "\n"


def read(path):
    with open(path, "r", encoding="utf-8") as handle:
        return handle.read()


def spec_ids():
    if not os.path.isdir(SPECS):
        return []
    return sorted(name[:-5] for name in os.listdir(SPECS) if name.endswith(".json"))


def catalog_order(ids):
    order = json.loads(read(os.path.join(CONTENT, "catalog.json")))["stories"]
    known = [sid for sid in order if sid in ids]
    return known + [sid for sid in ids if sid not in known]


def outputs(ids):
    """{path: text} for the stories in `ids`, plus the merged landmark catalog."""
    result = {}
    lm_path = os.path.join(CONTENT, "landmarks", "landmarks.json")
    catalog = json.loads(read(lm_path))
    by_id = {lm["id"]: i for i, lm in enumerate(catalog["landmarks"])}
    for sid in catalog_order(spec_ids()):
        spec = json.loads(read(os.path.join(SPECS, sid + ".json")))
        if spec["id"] != sid:
            raise SpecError("%s.json holds a story whose id is %r" % (sid, spec["id"]))
        for lm in spec.get("landmarks", []):
            if lm["id"] in by_id:
                catalog["landmarks"][by_id[lm["id"]]] = lm
            else:
                by_id[lm["id"]] = len(catalog["landmarks"])
                catalog["landmarks"].append(lm)
        if sid not in ids:
            continue
        story = build_story(spec)
        result[os.path.join(CONTENT, "stories", sid, "story.json")] = dump(story)
        result[os.path.join(CONTENT, "sources", sid + ".txt")] = build_manuscript(spec, story)
    result[lm_path] = dump(catalog)
    return result


def main(argv):
    check = "--check" in argv
    wanted = [a for a in argv[1:] if not a.startswith("--")]
    ids = wanted or spec_ids()
    missing = [sid for sid in ids if sid not in spec_ids()]
    if missing:
        print("no spec for: " + ", ".join(missing))
        return 2
    try:
        files = outputs(ids)
    except (SpecError, KeyError, ValueError) as error:
        print("error: %s" % (error,))
        return 1
    stale = []
    for path, text in sorted(files.items()):
        current = read(path) if os.path.isfile(path) else None
        if current == text:
            continue
        stale.append(os.path.relpath(path, REPO))
        if not check:
            os.makedirs(os.path.dirname(path), exist_ok=True)
            with open(path, "w", encoding="utf-8") as handle:
                handle.write(text)
    if check:
        for path in stale:
            print("out of date: " + path)
        return 1 if stale else 0
    print("%d file(s) written, %d unchanged" % (len(stale), len(files) - len(stale)))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
