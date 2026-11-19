import SwiftUI
import OmramoCore

// The cast and the shared parts of "The Snow House": the palette and the two lights (a low gold
// spring evening, and the pale blue dusk of the spring night), Elisapie and Grandfather, the
// snow knife and the saw, the far land of sea ice and bare rock, the snow house itself (a dome
// of slabs laid in ONE rising spiral), the qamutiik and the snowmobile.
//
// Cultural care (CONTENT_PLAN §1.3, §1.4): present-day Nunavut; plain modern parkas with no
// invented trim patterns; no face markings; no dogs, bears or costume clichés. Concept art,
// cultural review pending.

// MARK: - Palette and light

extension SnowHouseArt {
    static let ramp = ArtStyle.Ramp(deep: 0x1B4F7A, shade: 0x6FA3CC, mid: 0xBCD9EE, light: 0xF3F8FC, glow: 0xFFC766, accent: 0xC8402F)

    /// Snow in shade (blue-lilac), the line of a seam, snow in the sun (warm cream).
    static let snowShade: UInt32 = 0xB9CCEA
    static let snowLine: UInt32 = 0x8FA8D0
    static let snowCream: UInt32 = 0xFFF6E2
    static let shadowBlue: UInt32 = 0x5E7FC2
    static let rockHex: UInt32 = 0x9A8C86
    static let woodHex: UInt32 = 0xB98652
    static let steelHex: UInt32 = 0xC9D3DE
    static let parkaRed: UInt32 = 0xC8402F
    static let parkaBlue: UInt32 = 0x1D4F86
    static let furPale: UInt32 = 0xF1E6D4
    static let furDark: UInt32 = 0x5A4638

    static func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        CGPoint(x: x, y: y)
    }

    /// The spring evening: a pale blue sky going to cream and gold at the horizon.
    static func day() -> Kit.Light {
        let sky: Kit.Stops = [
            (Art.color(0xBFE1F6), 0), (Art.color(0xDDEFFA), 0.5), (Art.color(0xFFF1D6), 0.86), (Art.color(0xFFDDA2), 1),
        ]
        return Kit.Light(sky: sky, sun: 0xFFE7A0, glow: 0xFFC766, haze: 0xF6EBDD, far: 0xB4BFD6, mid: 0xC8D4E6, near: 0x9FB2D2)
    }

    /// The spring night: it stays light. Pale blue-lilac above, peach along the horizon.
    static func dusk() -> Kit.Light {
        let sky: Kit.Stops = [
            (Art.color(0xC3D5F1), 0), (Art.color(0xD7DEF4), 0.52), (Art.color(0xF3DEE2), 0.86), (Art.color(0xFAD9B4), 1),
        ]
        return Kit.Light(sky: sky, sun: 0xFFE3B0, glow: 0xFFC9A0, haze: 0xE8DEEC, far: 0xAEB8D8, mid: 0xC2CAE4, near: 0x97A6D0)
    }

    /// The snow underfoot, from the horizon to the viewer: warm where the low sun touches it,
    /// blue-lilac toward the near plane.
    static func snowStops(dusk: Bool) -> Kit.Stops {
        if dusk {
            return [(Art.color(0xEDE6F2), 0), (Art.color(0xD6DEF3), 0.4), (Art.color(0xBDCBEA), 1)]
        }
        return [(Art.color(0xFFF4DE), 0), (Art.color(0xEAF2FB), 0.38), (Art.color(0xC9DBF1), 1)]
    }

    /// A soft flat oval of colour: light lying on snow, or a long shadow.
    static func flatGlow(_ context: inout GraphicsContext, _ x: CGFloat, _ y: CGFloat, rx: CGFloat, ry: CGFloat, color: Color, alpha: Double) {
        guard rx > 0, ry > 0 else { return }
        let k: CGFloat = ry / rx
        let wide: CGFloat = 1 / k
        Art.group(&context, x: x, y: y, scale: k, scaleX: wide) { g in
            Art.glow(&g, 0, 0, rx, color, alpha: alpha)
        }
    }

    /// The long soft blue shadow the low sun throws to the lower right of something standing
    /// at (x, y) that is about `length` across.
    static func castShadow(_ context: inout GraphicsContext, _ x: CGFloat, _ y: CGFloat, length: CGFloat, alpha: Double = 0.34) {
        let sx: CGFloat = x + length * 0.42
        let sy: CGFloat = y + length * 0.05
        let deep: CGFloat = max(3, length * 0.1)
        Kit.shadow(&context, x, y, width: length * 0.6, alpha: 0.2)
        flatGlow(&context, sx, sy, rx: length * 0.62, ry: deep, color: Art.color(shadowBlue), alpha: alpha)
    }
}

// MARK: - Elisapie and Grandfather

extension SnowHouseArt {
    /// Elisapie: about eight, a bright red parka, two black braids. Her hood is always off
    /// (it is drawn fallen back behind her head by `hoodBack`), so the look has no headwear.
    static func elisapieLook() -> Kit.Person {
        Kit.Person(
            age: .child, skin: 0xB8784E, hair: 0x1F1A1D, hairStyle: .braids, beard: .none,
            headwear: .none, headwearColor: parkaRed, garment: .parka,
            cloth: parkaRed, trim: furPale, legs: 0x24406E, showsEyeWhite: true
        )
    }

    /// Grandfather: about seventy, a deep blue parka with a dark ruff, a small grey moustache.
    static func grandfatherLook() -> Kit.Person {
        Kit.Person(
            age: .elder, skin: 0xAA7049, hair: 0xA3A6AE, hairStyle: .short, beard: .moustache,
            headwear: .hood, headwearColor: parkaBlue, garment: .parka,
            cloth: parkaBlue, trim: furDark, legs: 0x262A33, showsEyeWhite: true
        )
    }

    /// Elisapie's hood, fallen back behind her head, in head units (origin: the head's centre).
    static func hoodBack(_ g: inout GraphicsContext) {
        let hood: Path = Art.svg("M-8,-12 C12,-30 43,-19 43,8 C43,28 28,39 8,39 C-10,39 -22,31 -24,18Z")
        Kit.solid(&g, hood, Art.color(parkaRed), light: 0.16, shade: 0.26)
        let fur: Path = Kit.personScallop(cx: 10, cy: 10, rx: 32, ry: 28, from: 292, to: 420, count: 9, r: 5)
        Art.fill(&g, fur, Kit.personTone(furPale, 0.86))
        let tufts: Path = Kit.personScallop(cx: 11, cy: 9, rx: 32, ry: 28, from: 298, to: 414, count: 8, r: 3.6)
        Art.fill(&g, tufts, Art.color(furPale))
    }

    /// Grandfather's sunglasses, pushed up on his hood, in head units.
    static func sunglasses(_ g: inout GraphicsContext) {
        var lenses = Path()
        lenses.addPath(Art.rect(-15.5, -30, 13, 8.4, radius: 4))
        lenses.addPath(Art.rect(1.5, -30, 13, 8.4, radius: 4))
        Art.fill(&g, lenses, Art.color(0x2B2F3A))
        Art.stroke(&g, Art.line(-2.5, -26.5, 1.5, -26.5), Art.color(0x2B2F3A), width: 1.8)
        var glints = Path()
        glints.addPath(Art.rect(-13.5, -28.6, 5, 2, radius: 1))
        glints.addPath(Art.rect(3.5, -28.6, 5, 2, radius: 1))
        Art.fill(&g, glints, Color.white.opacity(0.55))
    }

    /// Elisapie, feet at the origin, facing LEFT. `tongue` shows the tip of her tongue (she is
    /// working hard); use it with an upright pose and `mouth: .smile`.
    static func elisapie(
        _ context: inout GraphicsContext,
        pose: Kit.Pose = .stand,
        look: CGPoint = .zero,
        mouth: Kit.Mouth = .smile,
        mirrored: Bool = false,
        tongue: Bool = false
    ) {
        let p = elisapieLook()
        let f = Kit.bodyFrame(p)
        let r = Kit.bodyRig(p, pose)
        let c = Kit.bodyHeadCentre(f, r)
        Art.group(&context, x: c.x, y: c.y, scale: f.headScale) { g in
            hoodBack(&g)
        }
        Kit.person(&context, p, pose: pose, look: look, mouth: mouth, mirrored: mirrored)
        if tongue {
            let tx: CGFloat = c.x - 0.5
            let ty: CGFloat = c.y + 13.4
            Art.fill(&context, Art.ellipse(tx, ty, 2.6, 2.3), Art.color(0xE8776A))
        }
    }

    /// Grandfather, feet at the origin, facing LEFT, his sunglasses pushed up on his hood.
    static func grandfather(
        _ context: inout GraphicsContext,
        pose: Kit.Pose = .stand,
        look: CGPoint = .zero,
        mouth: Kit.Mouth = .smile,
        mirrored: Bool = false
    ) {
        let p = grandfatherLook()
        Kit.person(&context, p, pose: pose, look: look, mouth: mouth, mirrored: mirrored)
        let f = Kit.bodyFrame(p)
        let r = Kit.bodyRig(p, pose)
        let c = Kit.bodyHeadCentre(f, r)
        Art.group(&context, x: c.x, y: c.y, scale: f.headScale) { g in
            sunglasses(&g)
        }
    }

    /// Where a character's leading hand is, for a tool or a block.
    static func elisapieHand(_ pose: Kit.Pose) -> CGPoint {
        Kit.hand(elisapieLook(), pose: pose)
    }

    static func grandfatherHand(_ pose: Kit.Pose) -> CGPoint {
        Kit.hand(grandfatherLook(), pose: pose)
    }
}

// MARK: - Tools

extension SnowHouseArt {
    /// The snow knife: a long, straight, flat blade with a plain wooden handle. The origin is
    /// the middle of the grip and the blade points UP (−y); `length` is the blade's length.
    static func snowKnife(_ context: inout GraphicsContext, length: CGFloat) {
        let tip: CGFloat = -9 - length
        let outline: [CGPoint] = [pt(-3.4, -9), pt(-4.4, tip + 7), pt(-1.2, tip), pt(3.8, tip + 4), pt(3.4, -9)]
        let blade: Path = Art.polygon(outline)
        Kit.solid(&context, blade, Art.color(steelHex), light: 0.3, shade: 0.2)
        Art.stroke(&context, Art.line(-1.8, -13, -2.6, tip + 9), Color.white.opacity(0.85), width: 1.2)
        Art.stroke(&context, blade, Art.color(0x8C9AAE, 0.7), width: 0.9)
        Kit.propShaft(&context, 0, 9, 0, -8, wood: woodHex, width: 6.6)
        var rivets = Path()
        rivets.addPath(Art.circle(0, -4, 1))
        rivets.addPath(Art.circle(0, 4, 1))
        Art.fill(&context, rivets, Kit.propTone(woodHex, 0.6))
    }

    /// An ordinary wood saw. The origin is the handle and the blade points UP (−y).
    static func woodSaw(_ context: inout GraphicsContext, length: CGFloat) {
        let tip: CGFloat = -8 - length
        let outline: [CGPoint] = [pt(-6, -6), pt(-2.4, tip), pt(2.4, tip), pt(8, -6)]
        let blade: Path = Art.polygon(outline)
        Kit.solid(&context, blade, Art.color(steelHex), light: 0.28, shade: 0.2)
        let teeth: Path = Art.line(8.4, -8, 2.8, tip + 2)
        Art.stroke(&context, teeth, Art.color(0x7C8AA0), width: 2.2, cap: .butt, dash: [2.2, 2.2])
        let grip: Path = Art.rect(-9, -7, 20, 17, radius: 6)
        Kit.solid(&context, grip, Art.color(woodHex), light: 0.26, shade: 0.24)
        Art.fill(&context, Art.rect(-3.6, -1.5, 9, 6.5, radius: 3), Kit.propTone(woodHex, 0.55))
    }

    /// A block that has cracked in two: the halves lean apart on (x, baseY); x is its left.
    static func brokenBlock(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, width w: CGFloat, height h: CGFloat) {
        Kit.shadow(&context, x + w * 0.5, baseY, width: w * 1.1, alpha: 0.2)
        let left: [CGPoint] = [pt(0, 0), pt(w * 0.03, -h), pt(w * 0.46, -h), pt(w * 0.39, -h * 0.62), pt(w * 0.49, -h * 0.34), pt(w * 0.42, 0)]
        let right: [CGPoint] = [pt(0, 0), pt(w * 0.07, -h * 0.34), pt(-w * 0.03, -h * 0.62), pt(w * 0.04, -h), pt(w * 0.42, -h), pt(w * 0.45, 0)]
        let leftHalf: Path = Art.polygon(left)
        let rightHalf: Path = Art.polygon(right)
        let edge: Color = Art.color(0xA9BEDD, 0.7)
        Art.group(&context, x: x, y: baseY, rotate: -0.13) { g in
            Kit.solid(&g, leftHalf, Art.color(0xFAFCFF), light: 0.14, shade: 0.12)
            Art.stroke(&g, leftHalf, edge, width: 1.2)
        }
        Art.group(&context, x: x + w * 0.6, y: baseY, rotate: 0.15) { g in
            Kit.solid(&g, rightHalf, Art.color(0xEEF3FB), light: 0.1, shade: 0.2)
            Art.stroke(&g, rightHalf, edge, width: 1.2)
        }
        // The crack: three short marks springing from the gap.
        let cx: CGFloat = x + w * 0.5
        let top: CGFloat = baseY - h
        var marks = Path()
        marks.move(to: pt(cx, top - h * 0.16))
        marks.addLine(to: pt(cx, top - h * 0.42))
        marks.move(to: pt(cx - w * 0.1, top - h * 0.1))
        marks.addLine(to: pt(cx - w * 0.2, top - h * 0.3))
        marks.move(to: pt(cx + w * 0.1, top - h * 0.1))
        marks.addLine(to: pt(cx + w * 0.2, top - h * 0.3))
        Art.stroke(&context, marks, Art.color(ramp.shade, 0.9), width: 2)
    }

    /// A heap of crumbled soft snow on (cx, baseY).
    static func crumbHeap(_ context: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, width w: CGFloat, seed: UInt32 = 3) {
        Kit.shadow(&context, cx, baseY, width: w, alpha: 0.2)
        let half: CGFloat = w / 2
        let high: CGFloat = w * 0.34
        var heap = Path()
        heap.move(to: pt(cx - half, baseY))
        heap.addQuadCurve(to: pt(cx - half * 0.1, baseY - high), control: pt(cx - half * 0.6, baseY - high * 0.95))
        heap.addQuadCurve(to: pt(cx + half, baseY), control: pt(cx + half * 0.55, baseY - high * 0.9))
        heap.closeSubpath()
        heap.addEllipse(in: CGRect(x: cx - half * 0.7, y: baseY - high * 0.75, width: half * 0.6, height: high * 0.6))
        heap.addEllipse(in: CGRect(x: cx + half * 0.1, y: baseY - high * 0.9, width: half * 0.55, height: high * 0.6))
        let shape: Path = heap
        Kit.solid(&context, shape, Art.color(0xF8FAFE), light: 0.16, shade: 0.2)
        let lumps = CGRect(x: cx - half * 1.15, y: baseY - high * 0.5, width: w * 1.15, height: high * 0.62)
        Kit.flecks(&context, in: lumps, count: 14, seed: seed, color: Color.white, radius: 1.6...3.6)
        Kit.flecks(&context, in: lumps, count: 8, seed: seed &+ 5, color: Art.color(snowShade), radius: 1.2...2.6)
    }
}

// MARK: - The land: sea ice, bare rock, snow

extension SnowHouseArt {
    /// A low hill of bare brown-grey rock showing through the snow, standing on `y`.
    static func rockHill(_ context: inout GraphicsContext, x0: CGFloat, x1: CGFloat, y: CGFloat, height: CGFloat) {
        let span: CGFloat = x1 - x0
        guard span > 0, height > 0 else { return }
        let crown = pt(x0 + span * 0.42, y - height)
        var hill = Path()
        hill.move(to: pt(x0, y))
        hill.addCurve(to: crown, control1: pt(x0 + span * 0.14, y - height * 0.2), control2: pt(x0 + span * 0.26, y - height))
        hill.addCurve(to: pt(x1, y), control1: pt(x0 + span * 0.62, y - height), control2: pt(x0 + span * 0.8, y - height * 0.3))
        hill.closeSubpath()
        let shape: Path = hill
        Art.fill(&context, shape, Art.color(rockHex))
        // Snow lies in the hollows and over the crown; the rock shows in bands between.
        var snow = Path()
        snow.addEllipse(in: CGRect(x: x0 + span * 0.02, y: y - height * 0.4, width: span * 0.5, height: height * 0.62))
        snow.addEllipse(in: CGRect(x: x0 + span * 0.2, y: y - height * 1.12, width: span * 0.34, height: height * 0.5))
        snow.addEllipse(in: CGRect(x: x0 + span * 0.52, y: y - height * 0.34, width: span * 0.5, height: height * 0.5))
        snow.addEllipse(in: CGRect(x: x0 + span * 0.5, y: y - height * 0.84, width: span * 0.16, height: height * 0.2))
        let drifts: Path = snow
        let shadeFrom = pt(crown.x, y)
        let shadeTo = pt(x1, y)
        let shadeStops: Kit.Stops = [(Art.color(shadowBlue, 0), 0), (Art.color(shadowBlue, 0.3), 1)]
        Art.clipped(&context, to: shape) { g in
            Art.fill(&g, drifts, Art.color(0xF6F8FC, 0.94))
            Art.fillLinear(&g, Art.rect(x0, y - height, span, height), shadeStops, from: shadeFrom, to: shadeTo)
        }
        var lit = Path()
        lit.move(to: pt(x0 + span * 0.12, y - height * 0.36))
        lit.addQuadCurve(to: crown, control: pt(x0 + span * 0.24, y - height * 0.98))
        Art.stroke(&context, lit, Art.color(snowCream, 0.8), width: 1.6)
    }

    /// The far plane of every outdoor picture: the flat line of the sea ice, low bare-rock
    /// hills with snow lying on them, and the veil of air. `hills` are (x0, x1, height) with x
    /// as parts of the width and the height in far units; `s` is the far scale.
    static func farLand(
        _ context: inout GraphicsContext,
        width w: CGFloat,
        horizon H: CGFloat,
        scale s: CGFloat,
        light: Kit.Light,
        hills: [(CGFloat, CGFloat, CGFloat)],
        seed: UInt32
    ) {
        let farthest: Path = Kit.ridge(width: w, y: H - 9 * s, amp: 8 * s, seed: seed &+ 19, bottom: H + 6, step: 10)
        Art.fill(&context, farthest, light.far.opacity(0.5))
        for hill in hills {
            rockHill(&context, x0: w * hill.0, x1: w * hill.1, y: H + 2, height: hill.2 * s)
        }
        ArtStyle.atmosphere(&context, width: w, top: H - 70 * s, bottom: H + 6, color: light.haze, alpha: 0.42)
    }

    /// The frozen lake (or the sea ice): a paler, flatter band lying on the snow.
    static func iceBand(_ context: inout GraphicsContext, x0: CGFloat, x1: CGFloat, y: CGFloat, depth: CGFloat, dusk: Bool = false) {
        let span: CGFloat = x1 - x0
        guard span > 0, depth > 0 else { return }
        let mid: CGFloat = (x0 + x1) / 2
        var band = Path()
        band.move(to: pt(x0, y))
        band.addQuadCurve(to: pt(x1, y), control: pt(mid, y - depth * 0.5))
        band.addQuadCurve(to: pt(x0, y), control: pt(mid + span * 0.08, y + depth * 1.5))
        band.closeSubpath()
        let shape: Path = band
        let stops: Kit.Stops = dusk ? Kit.stops(0xF4F0F8, 0xDCE4F6) : Kit.stops(0xFDFEFF, 0xE2EEFA)
        Art.fillLinear(&context, shape, stops, from: pt(0, y - depth * 0.3), to: pt(0, y + depth * 0.8))
        var shore = Path()
        shore.move(to: pt(x0 + span * 0.04, y + depth * 0.14))
        shore.addQuadCurve(to: pt(x1 - span * 0.04, y + depth * 0.14), control: pt(mid + span * 0.08, y + depth * 1.36))
        Art.stroke(&context, shore, Art.color(snowLine, 0.45), width: 1.4)
        var streaks = Path()
        let marks: [(CGFloat, CGFloat, CGFloat)] = [(0.2, 0.1, 0.16), (0.44, 0.3, 0.2), (0.62, 0.02, 0.14), (0.34, 0.5, 0.12)]
        for mark in marks {
            let sx: CGFloat = x0 + span * mark.0
            let sy: CGFloat = y + depth * mark.1
            streaks.move(to: pt(sx, sy))
            streaks.addLine(to: pt(sx + span * mark.2, sy))
        }
        Art.stroke(&context, streaks, Art.color(ramp.mid, 0.7), width: 1.2)
    }

    /// A low drift in the middle ground: a soft mound that melts into the snow at its foot,
    /// warm on its crest, blue on its right side.
    static func softDrift(_ context: inout GraphicsContext, x0: CGFloat, x1: CGFloat, baseY: CGFloat, height: CGFloat) {
        let span: CGFloat = x1 - x0
        guard span > 0, height > 0 else { return }
        let peak = pt(x0 + span * 0.42, baseY - height)
        let run: CGFloat = x1 - peak.x
        var mound = Path()
        mound.move(to: pt(x0, baseY))
        mound.addQuadCurve(to: peak, control: pt(x0 + span * 0.2, baseY - height))
        mound.addQuadCurve(to: pt(x1, baseY), control: pt(peak.x + run * 0.5, baseY - height))
        mound.closeSubpath()
        let shape: Path = mound
        let body: Kit.Stops = [(Art.color(0xFFFBF1), 0), (Art.color(0xEDF3FB, 0.8), 0.55), (Art.color(0xDCE7F6, 0), 1)]
        Art.fillLinear(&context, shape, body, from: pt(0, baseY - height), to: pt(0, baseY))
        let side: Kit.Stops = [(Art.color(shadowBlue, 0), 0), (Art.color(shadowBlue, 0.22), 0.7), (Art.color(shadowBlue, 0), 1)]
        Art.fillLinear(&context, shape, side, from: pt(peak.x, 0), to: pt(x1, 0))
        var crest = Path()
        crest.move(to: pt(x0 + span * 0.1, baseY - height * 0.5))
        crest.addQuadCurve(to: peak, control: pt(x0 + span * 0.22, baseY - height))
        Art.stroke(&context, crest, Art.color(snowCream, 0.9), width: 1.8)
        castShadow(&context, peak.x + run * 0.5, baseY + 2, length: span * 0.5, alpha: 0.22)
    }

    /// A near bank of snow in shade, for a bottom corner: its foot is meant to lie off the
    /// frame (`baseY` at or below the bottom edge).
    static func nearBank(_ context: inout GraphicsContext, x0: CGFloat, x1: CGFloat, baseY: CGFloat, height: CGFloat) {
        let span: CGFloat = x1 - x0
        guard span > 0, height > 0 else { return }
        let peak = pt(x0 + span * 0.55, baseY - height)
        var bank = Path()
        bank.move(to: pt(x0, baseY))
        bank.addQuadCurve(to: peak, control: pt(x0 + span * 0.25, baseY - height))
        bank.addQuadCurve(to: pt(x1, baseY), control: pt(x0 + span * 0.8, baseY - height))
        bank.closeSubpath()
        let shape: Path = bank
        Art.fillLinear(&context, shape, Kit.stops(0xCBD8F0, 0xA6B9DE), from: pt(0, baseY - height), to: pt(0, baseY))
        var crest = Path()
        crest.move(to: pt(x0 + span * 0.14, baseY - height * 0.62))
        crest.addQuadCurve(to: peak, control: pt(x0 + span * 0.3, baseY - height * 1.02))
        Art.stroke(&context, crest, Art.color(snowCream, 0.85), width: 2.2)
    }

    /// Wind-ripples on the snow: short soft strokes, finer far away.
    static func windRipples(_ context: inout GraphicsContext, x0: CGFloat, x1: CGFloat, y0: CGFloat, y1: CGFloat, count: Int, seed: UInt32) {
        Kit.rippleMarks(&context, x0: x0, x1: x1, y0: y0, y1: y1, count: count, seed: seed, color: Art.color(snowLine), alpha: 0.4)
        Kit.rippleMarks(&context, x0: x0, x1: x1, y0: y0 + 3, y1: y1 + 3, count: count / 2, seed: seed &+ 7, color: Color.white, alpha: 0.7)
    }

    /// The two tracks of the sled's runners, from `a` (near) round `c` back to `b` (far),
    /// thinner with distance. `gap` is the distance between the runners.
    static func tracks(_ context: inout GraphicsContext, from a: CGPoint, round c: CGPoint, to b: CGPoint, gap: CGFloat) {
        let offsets: [CGFloat] = [0, 1]
        for offset in offsets {
            let start = pt(a.x + gap * offset, a.y - gap * 0.4 * offset)
            let control = pt(c.x + gap * offset, c.y)
            var track = Path()
            track.move(to: start)
            track.addQuadCurve(to: b, control: control)
            let line: Path = track
            let color: Color = Art.color(snowLine, 0.7)
            Art.stroke(&context, line.trimmedPath(from: 0, to: 0.42), color, width: 3.2)
            Art.stroke(&context, line.trimmedPath(from: 0.4, to: 0.76), color, width: 2.1)
            Art.stroke(&context, line.trimmedPath(from: 0.74, to: 1), color, width: 1.1)
            let lit: Path = line.applying(CGAffineTransform(translationX: 0, y: 2.2))
            Art.stroke(&context, lit.trimmedPath(from: 0, to: 0.6), Color.white.opacity(0.7), width: 1.2)
        }
    }

    /// What fills the deeper snow of a tall window (inside `designSpace`): drifts, ripples and
    /// a rock showing through, between the subject and the foot of the picture.
    static func tallFill(_ context: inout GraphicsContext, _ st: Kit.Stage, seed: UInt32) {
        guard st.extra > 40 else { return }
        let e: CGFloat = st.extra
        let top: CGFloat = st.Hv + 190
        windRipples(&context, x0: 0, x1: 892, y0: top, y1: st.hv - 12, count: 46, seed: seed)
        softDrift(&context, x0: 40, x1: 430, baseY: top + 30 + e * 0.18, height: 24)
        softDrift(&context, x0: 470, x1: 860, baseY: top + 50 + e * 0.42, height: 30)
        softDrift(&context, x0: 150, x1: 600, baseY: top + 70 + e * 0.7, height: 34)
        let rockY: CGFloat = top + 44 + e * 0.5
        Kit.rock(&context, cx: 250, baseY: rockY, width: 96, height: 46, color: rockHex, seed: seed &+ 2)
        Art.fill(&context, Art.ellipse(238, rockY - 44, 30, 9), Art.color(0xF8FAFE))
        Kit.pebbles(&context, in: CGRect(x: 290, y: rockY - 6, width: 120, height: 18), count: 7, seed: seed &+ 4, color: rockHex)
        let sparkle = CGRect(x: 0, y: top, width: 892, height: max(1, st.hv - top))
        Kit.flecks(&context, in: sparkle, count: 40, seed: seed &+ 9, color: Color.white, radius: 0.7...1.6)
    }
}

// MARK: - The snow house

// The house is a dome of large slabs laid in ONE rising spiral, never in level rows. A point on
// the dome is given by how far round the front it is (`t`: 0 at the left edge, 1 at the right)
// and how far up the dome's arc it is (`psi`, radians: 0 on the snow, π/2 at the very top).
// The seam between two turns of the spiral is the line psi = pitch × (k − phase + t / 2): it
// climbs steadily from left to right, goes on round the back, and comes back one course higher.

extension SnowHouseArt {
    struct Dome: Sendable {
        var cx: CGFloat
        var baseY: CGFloat
        var radius: CGFloat
        var rise: CGFloat
        /// How far up the arc the wall climbs in one turn (radians).
        var pitch: CGFloat = 0.26
        /// Where the spiral begins, as a part of a turn: 0.15 puts its step 30% across the front.
        var phase: CGFloat = 0.15
        /// How much the rings bow toward the viewer (the house is seen from a little above).
        var sag: CGFloat = 0.14
    }

    /// The highest seam: above it sits the last block, laid flat like a lid.
    static let domeCap: CGFloat = 1.36

    static func domeFront(_ d: Dome, _ t: CGFloat, _ psi: CGFloat) -> CGPoint {
        let w: CGFloat = d.radius * cos(psi)
        let z: CGFloat = d.rise * sin(psi)
        let a: CGFloat = CGFloat.pi * t
        let x: CGFloat = d.cx - w * cos(a)
        let y: CGFloat = d.baseY - z + d.sag * w * sin(a)
        return CGPoint(x: x, y: y)
    }

    /// A point on the far side of the ring: `s` is 0 at the right edge and 1 at the left.
    static func domeBack(_ d: Dome, _ s: CGFloat, _ psi: CGFloat) -> CGPoint {
        let w: CGFloat = d.radius * cos(psi)
        let z: CGFloat = d.rise * sin(psi)
        let a: CGFloat = CGFloat.pi * s
        let x: CGFloat = d.cx + w * cos(a)
        let y: CGFloat = d.baseY - z - d.sag * w * sin(a)
        return CGPoint(x: x, y: y)
    }

    /// Seam `k` of the spiral at `t` across the front (may be below 0 or above the cap).
    static func domeSeam(_ d: Dome, _ k: Int, _ t: CGFloat) -> CGFloat {
        d.pitch * (CGFloat(k) - d.phase + 0.5 * t)
    }

    /// The top of a wall of `courses` turns at `t`: left of the step the newest turn is one
    /// course higher.
    static func domeTop(_ d: Dome, _ courses: Int, _ t: CGFloat) -> CGFloat {
        let k: Int = t < 2 * d.phase ? courses + 1 : courses
        return Kit.clamp(domeSeam(d, k, t), 0, domeCap)
    }

    /// The top edge of the front of a half-built wall, left to right, with the step in it.
    static func domeTopEdge(_ d: Dome, courses: Int) -> [CGPoint] {
        let step: CGFloat = 2 * d.phase
        var points: [CGPoint] = []
        for i in 0...6 {
            let t: CGFloat = step * CGFloat(i) / 6
            let psi: CGFloat = Kit.clamp(domeSeam(d, courses + 1, t), 0, domeCap)
            points.append(domeFront(d, t, psi))
        }
        for i in 0...14 {
            let t: CGFloat = step + (1 - step) * CGFloat(i) / 14
            let psi: CGFloat = Kit.clamp(domeSeam(d, courses, t), 0, domeCap)
            points.append(domeFront(d, t, psi))
        }
        return points
    }

    /// The top edge of the far side of a half-built wall, right to left.
    static func domeBackEdge(_ d: Dome, courses: Int) -> [CGPoint] {
        var points: [CGPoint] = []
        for i in 0...16 {
            let s: CGFloat = CGFloat(i) / 16
            let turn: CGFloat = CGFloat(courses) - d.phase + 0.5 + 0.5 * s
            let psi: CGFloat = Kit.clamp(d.pitch * turn, 0, domeCap)
            points.append(domeBack(d, s, psi))
        }
        return points
    }

    /// The front of a half-built wall as one shape: up the left side, along the stepped top,
    /// down the right side and back along the foot.
    static func domeWallPath(_ d: Dome, courses: Int) -> Path {
        var points: [CGPoint] = []
        let leftTop: CGFloat = domeTop(d, courses, 0)
        for i in 0...5 {
            points.append(domeFront(d, 0, leftTop * CGFloat(i) / 6))
        }
        points.append(contentsOf: domeTopEdge(d, courses: courses))
        let rightTop: CGFloat = domeTop(d, courses, 1)
        for i in 1...6 {
            points.append(domeFront(d, 1, rightTop * (1 - CGFloat(i) / 6)))
        }
        for i in 1...11 {
            points.append(domeFront(d, 1 - CGFloat(i) / 12, 0))
        }
        return Art.polygon(points)
    }

    /// The whole finished dome as one shape.
    static func domeFullPath(_ d: Dome) -> Path {
        var points: [CGPoint] = []
        for i in 0...28 {
            let a: CGFloat = CGFloat.pi * CGFloat(i) / 28
            points.append(pt(d.cx - d.radius * cos(a), d.baseY - d.rise * sin(a)))
        }
        for i in 1...11 {
            points.append(domeFront(d, 1 - CGFloat(i) / 12, 0))
        }
        return Art.polygon(points)
    }

    /// The spiral: seams 0…`courses`, each a slanted line climbing across the front.
    static func domeSeams(_ d: Dome, upTo courses: Int) -> Path {
        var path = Path()
        let last: Int = max(0, courses)
        for k in 0...last {
            var started: Bool = false
            for i in 0...20 {
                let t: CGFloat = CGFloat(i) / 20
                let psi: CGFloat = domeSeam(d, k, t)
                if psi < -0.001 || psi > domeCap {
                    started = false
                    continue
                }
                let point = domeFront(d, t, max(0, psi))
                if started {
                    path.addLine(to: point)
                } else {
                    path.move(to: point)
                    started = true
                }
            }
        }
        return path
    }

    /// The joints between the blocks of each turn: short lines from one seam to the next,
    /// leaning the way the spiral climbs, staggered from turn to turn.
    static func domeJoints(_ d: Dome, upTo courses: Int, blockLength: CGFloat) -> Path {
        var path = Path()
        let last: Int = max(0, courses) + 1
        for c in 0...last {
            let middle: CGFloat = max(0, d.pitch * (CGFloat(c) - 0.5))
            if middle > domeCap { continue }
            let w: CGFloat = d.radius * cos(middle)
            let wanted: CGFloat = (CGFloat.pi * w / max(1, blockLength)).rounded()
            let n: Int = max(3, Int(wanted))
            let shift: CGFloat = c % 2 == 0 ? 0.3 : 0.8
            for j in 0..<n {
                let t: CGFloat = (CGFloat(j) + shift) / CGFloat(n)
                let lean: CGFloat = min(1, t + 0.03)
                let low: CGFloat = max(0, domeSeam(d, c - 1, t))
                let high: CGFloat = min(domeCap, domeSeam(d, c, lean))
                if high <= low + 0.03 { continue }
                path.move(to: domeFront(d, t, low))
                path.addLine(to: domeFront(d, lean, high))
            }
        }
        return path
    }

    /// The ring where the last block sits, at the top of a finished dome.
    static func domeLid(_ d: Dome) -> Path {
        var points: [CGPoint] = []
        for i in 0...10 {
            points.append(domeFront(d, CGFloat(i) / 10, domeCap))
        }
        return Art.polygon(points, closed: false)
    }
}

// MARK: - Painting the snow house

extension SnowHouseArt {
    /// The inside of the far wall of a half-built house. Draw it first, then whoever stands
    /// inside, then `snowWall` over them.
    static func snowWallBack(_ context: inout GraphicsContext, _ d: Dome, courses: Int) {
        let edge: [CGPoint] = domeBackEdge(d, courses: courses)
        var points: [CGPoint] = edge
        points.append(pt(d.cx - d.radius, d.baseY))
        points.append(pt(d.cx + d.radius, d.baseY))
        let shape: Path = Art.polygon(points)
        let top: CGFloat = d.baseY - d.rise
        Art.fillLinear(&context, shape, Kit.stops(0xD6E1F3, 0xA9BEE0), from: pt(0, top), to: pt(0, d.baseY))
        var seams = Path()
        for m in 1...2 {
            var started: Bool = false
            for i in 0...16 {
                let s: CGFloat = CGFloat(i) / 16
                let turn: CGFloat = CGFloat(courses - m) - d.phase + 0.5 + 0.5 * s
                let psi: CGFloat = d.pitch * turn
                if psi < 0 {
                    started = false
                    continue
                }
                let point = domeBack(d, s, psi)
                if started {
                    seams.addLine(to: point)
                } else {
                    seams.move(to: point)
                    started = true
                }
            }
        }
        let lines: Path = seams
        Art.clipped(&context, to: shape) { g in
            Art.stroke(&g, lines, Art.color(snowLine, 0.55), width: 1.4)
        }
        let rim: CGFloat = max(2.4, d.radius * 0.03)
        Art.stroke(&context, Art.polygon(edge, closed: false), Art.color(0xF6F9FE), width: rim)
    }

    /// The front of a half-built house: `courses` turns of the spiral, its top a slope with
    /// one step where the newest block ends. `blockLength` is the length of a slab.
    static func snowWall(_ context: inout GraphicsContext, _ d: Dome, courses: Int, blockLength: CGFloat) {
        let wall: Path = domeWallPath(d, courses: courses)
        let left: CGFloat = d.cx - d.radius
        let right: CGFloat = d.cx + d.radius
        let fill: Kit.Stops = [(Art.color(snowCream), 0), (Art.color(0xF2F6FC), 0.42), (Art.color(0xC2D3EE), 1)]
        Art.fillLinear(&context, wall, fill, from: pt(left, 0), to: pt(right, 0))
        let seams: Path = domeSeams(d, upTo: courses)
        let joints: Path = domeJoints(d, upTo: courses, blockLength: blockLength)
        let lit: Path = seams.applying(CGAffineTransform(translationX: 0, y: 2))
        let wide: CGFloat = max(1.2, d.radius * 0.011)
        let bounds: CGRect = wall.boundingRect
        Art.clipped(&context, to: wall) { g in
            Art.stroke(&g, joints, Art.color(snowLine, 0.7), width: wide)
            Art.stroke(&g, lit, Color.white.opacity(0.8), width: wide)
            Art.stroke(&g, seams, Art.color(snowLine, 0.9), width: wide * 1.25)
            ArtStyle.tooth(&g, in: bounds, seed: 21, color: Color.white, alpha: 0.06)
        }
        ArtStyle.rimEdge(&context, wall, bounds: bounds, width: 2.4, alpha: 0.45)
        // The lit top faces of the slabs, and the shaded end of the newest block (the step).
        let edge: [CGPoint] = domeTopEdge(d, courses: courses)
        let thick: CGFloat = max(3, d.radius * 0.04)
        Art.stroke(&context, Art.polygon(edge, closed: false), Art.color(0xFFFEF8), width: thick)
        if edge.count > 7 {
            let a = edge[6]
            let b = edge[7]
            Art.stroke(&context, Art.line(a.x, a.y, b.x, b.y), Art.color(snowShade), width: thick)
        }
    }

    /// The finished house: a low dome, its spiral of slabs clear to see, a small door cut low
    /// in the wall. With `glow` the lamp is lit inside: the snow shines warm gold, the seams
    /// are fine bright lines and the door is a gold shape that spills light on the snow.
    static func snowDome(_ context: inout GraphicsContext, _ d: Dome, glow: Bool, blockLength: CGFloat) {
        let full: Path = domeFullPath(d)
        let left: CGFloat = d.cx - d.radius
        let right: CGFloat = d.cx + d.radius
        let heart = pt(d.cx - d.radius * 0.1, d.baseY - d.rise * 0.34)
        if glow {
            Art.glow(&context, d.cx, d.baseY - d.rise * 0.4, d.radius * 1.6, Art.color(0xFFD98A), alpha: 0.3)
        }
        let dayFill: Kit.Stops = [(Art.color(snowCream), 0), (Art.color(0xF2F6FC), 0.42), (Art.color(0xC2D3EE), 1)]
        let duskFill: Kit.Stops = [(Art.color(0xF4EFF6), 0), (Art.color(0xDFE4F4), 0.45), (Art.color(0xB7C5E6), 1)]
        Art.fillLinear(&context, full, glow ? duskFill : dayFill, from: pt(left, 0), to: pt(right, 0))
        var lines: Path = domeSeams(d, upTo: 8)
        lines.addPath(domeJoints(d, upTo: 8, blockLength: blockLength))
        lines.addPath(domeLid(d))
        let marks: Path = lines
        let wide: CGFloat = max(1.1, d.radius * 0.01)
        let bounds: CGRect = full.boundingRect
        let warm: Kit.Stops = [(Art.color(0xFFE594, 0.96), 0), (Art.color(0xFFC766, 0.72), 0.5), (Art.color(0xFFC766, 0), 1)]
        let reach: CGFloat = d.radius * 1.2
        Art.clipped(&context, to: full) { g in
            if glow {
                Art.fillRadial(&g, Art.rect(bounds.minX, bounds.minY, bounds.width, bounds.height), warm, center: heart, radius: reach)
                Art.stroke(&g, marks, Art.color(0xFFAE42, 0.5), width: wide * 3)
                Art.stroke(&g, marks, Art.color(0xFFF4C4, 0.95), width: wide * 1.1)
            } else {
                let lit: Path = marks.applying(CGAffineTransform(translationX: 0, y: 2))
                Art.stroke(&g, lit, Color.white.opacity(0.8), width: wide)
                Art.stroke(&g, marks, Art.color(snowLine, 0.85), width: wide * 1.25)
            }
            ArtStyle.tooth(&g, in: bounds, seed: 23, color: Color.white, alpha: 0.06)
        }
        ArtStyle.rimEdge(&context, full, bounds: bounds, width: 2.6, alpha: glow ? 0.3 : 0.5)
        snowDoor(&context, d, glow: glow)
    }

    /// The small door, cut low in the wall a little left of the middle.
    static func snowDoor(_ context: inout GraphicsContext, _ d: Dome, glow: Bool) {
        let base = domeFront(d, 0.36, 0)
        let half: CGFloat = d.radius * 0.15
        let high: CGFloat = d.rise * 0.36
        let shoulder: CGFloat = base.y - high * 0.5
        let crown: CGFloat = base.y - high * 1.16
        var door = Path()
        door.move(to: pt(base.x - half, base.y + 1))
        door.addLine(to: pt(base.x - half, shoulder))
        door.addCurve(to: pt(base.x + half, shoulder), control1: pt(base.x - half, crown), control2: pt(base.x + half, crown))
        door.addLine(to: pt(base.x + half, base.y + 1))
        door.closeSubpath()
        let shape: Path = door
        if glow {
            Art.glow(&context, base.x, base.y - high * 0.4, high * 1.5, Art.color(0xFFE6A0), alpha: 0.5)
            flatGlow(&context, base.x - half, base.y + high * 0.42, rx: d.radius * 0.95, ry: d.radius * 0.2, color: Art.color(0xFFC766), alpha: 0.6)
        }
        Art.stroke(&context, shape, Art.color(glow ? 0xF3E9EE : 0xE2EAF6), width: d.radius * 0.05)
        let lamp: Kit.Stops = Kit.stops(0xFFF8D6, 0xFFC766)
        let dark: Kit.Stops = Kit.stops(0x7C97C6, 0x55739F)
        Art.fillLinear(&context, shape, glow ? lamp : dark, from: pt(0, base.y - high), to: pt(0, base.y))
    }
}

