import SwiftUI
import OmramoCore

// The cast and the story's own parts for "Sindbad's Second Voyage": palette, lights, Sindbad,
// the merchants and porters, the dhow, the egg, the Roc (always a part, never whole), the
// eagle, the rough diamonds, the meat and the nest.

// MARK: - Palette and light

extension SindbadArt {
    static let ramp = ArtStyle.Ramp(deep: 0x0F2F3D, shade: 0x1C6F80, mid: 0x5DBFC4, light: 0xDDF3F1, glow: 0xFBE3A6, accent: 0xE0822A)

    static let clothWhite: UInt32 = 0xFBF6EA
    static let sailWhite: UInt32 = 0xFBF6E8
    static let hullWood: UInt32 = 0x8A5B38
    static let sparWood: UInt32 = 0x6A4630
    static let mudBrick: UInt32 = 0xD8B886
    static let mudRoof: UInt32 = 0xB48F62
    static let rocGold: UInt32 = 0xE2A93B
    static let sandstone: UInt32 = 0xEBCFA4
    static let palmGreen: UInt32 = 0x3E8A62

    /// Hot clear sea-and-sand day: pale turquoise sky going to warm sand at the horizon.
    static func day() -> Kit.Light {
        let sky: Kit.Stops = [
            (Art.color(0xBFE6EA), 0), (Art.color(0xD6F0EE), 0.5), (Art.color(0xEEF4E0), 0.82), (Art.color(0xFBE9BE), 1),
        ]
        return Kit.Light(sky: sky, sun: 0xFFF6D8, glow: 0xFBE3A6, haze: 0xE4F1E6, far: 0xA7CDBF, mid: 0x86B79E, near: 0x5E9A84)
    }

    /// The wide pale morning over the cliff top.
    static func morning() -> Kit.Light {
        let sky: Kit.Stops = [
            (Art.color(0xC6E6F0), 0), (Art.color(0xDDEFF0), 0.5), (Art.color(0xF6F0DA), 0.85), (Art.color(0xFDEBC0), 1),
        ]
        return Kit.Light(sky: sky, sun: 0xFFF3CF, glow: 0xFDE7B4, haze: 0xEAF0E4, far: 0xC3CED2, mid: 0xC2BFA6, near: 0xB29E78)
    }

    /// Island greens: evergreen fruit trees in clear light.
    static func islandGreens() -> Kit.Greens {
        Kit.greens(0x1F5A48, 0x2E7A55, 0x4A9E62, 0x86C46E, 0xD2EC8E)
    }

    /// The same trees seen through the air.
    static func hazyGreens() -> Kit.Greens {
        Kit.greens(0x6FA694, 0x80B79E, 0x97C8A8, 0xB4D9B4, 0xD8EDC4)
    }
}

// MARK: - People

extension SindbadArt {
    /// Sindbad: warm brown skin, a short dark beard, a cream robe with a sea-green sash and
    /// the big white turban. Without the turban (it is a rope just then) he has a small cap.
    static func sindbadLook(turban: Bool = true) -> Kit.Person {
        var p = Kit.Person(
            age: .adult, skin: 0xB8784E, hair: 0x2B1C17, hairStyle: .short, beard: .short,
            headwear: .turban, headwearColor: 0xFBF6EA, garment: .robe,
            cloth: 0xF0E2C2, trim: 0x2F9C8C, legs: 0xB98F5E, showsEyeWhite: false
        )
        if !turban {
            p.headwear = .cap
            p.headwearColor = 0xA6452F
        }
        return p
    }

    /// The diamond merchant: stout, grey-flecked beard, plum robe, pale turban.
    static func merchantLook() -> Kit.Person {
        Kit.Person(
            age: .adult, skin: 0xC08A5E, hair: 0x6E6660, hairStyle: .short, beard: .short,
            headwear: .turban, headwearColor: 0xEFE3CF, garment: .robe,
            cloth: 0x7A3E6B, trim: 0xD9A64A, legs: 0x5A4038, showsEyeWhite: false
        )
    }

    /// Another merchant of the party, in a robe of `cloth`.
    static func fellowLook(cloth: UInt32, sash: UInt32, turban: UInt32) -> Kit.Person {
        Kit.Person(
            age: .adult, skin: 0xA96E48, hair: 0x2F211B, hairStyle: .short, beard: .short,
            headwear: .turban, headwearColor: turban, garment: .robe,
            cloth: cloth, trim: sash, legs: 0x5A4038, showsEyeWhite: false
        )
    }

    /// A porter of the quay: short tunic, bare legs, a small head cloth.
    static func porterLook(tunic: UInt32) -> Kit.Person {
        Kit.Person(
            age: .adult, skin: 0xA66A44, hair: 0x2B1C17, hairStyle: .short, beard: .none,
            headwear: .cap, headwearColor: 0xE9DCC0, garment: .tunic,
            cloth: tunic, trim: 0x8A4A32, legs: 0xA66A44, showsEyeWhite: false
        )
    }

    /// A person in a rig of the story's own (the kit's `person` with a custom pose). Origin at
    /// the feet, facing LEFT. `tilt` tips the head back (radians, positive = looking up).
    static func rigged(
        _ context: inout GraphicsContext,
        _ p: Kit.Person,
        _ r: Kit.BodyRig,
        look: CGPoint = .zero,
        mouth: Kit.Mouth = .smile,
        tilt: CGFloat = 0,
        mirrored: Bool = false
    ) {
        let f = Kit.bodyFrame(p)
        Art.group(&context, scale: f.k) { g in
            Kit.bodyFigure(&g, p, r, mirrored: mirrored)
        }
        let c = Kit.bodyHeadCentre(f, r)
        let lean: CGFloat = -Kit.deg(r.lean) * 0.45
        let turn: CGFloat = lean + tilt
        Art.group(&context, x: c.x, y: c.y, rotate: turn, scale: f.headScale) { g in
            Kit.personHead(&g, p, look: look, mouth: mouth, closedEyes: false, mirrored: mirrored)
        }
    }

    /// Where the leading hand of a rig is, in the person's own units.
    static func handOf(_ p: Kit.Person, _ r: Kit.BodyRig) -> CGPoint {
        let f = Kit.bodyFrame(p)
        let s = Kit.bodyShoulder(r, near: true)
        let x: CGFloat = (s.x + r.nearHand.x) * f.k
        let y: CGFloat = (s.y + r.nearHand.y) * f.k
        return CGPoint(x: x, y: y)
    }

    /// Walking with a bale on the far shoulder, the far hand up to steady it.
    static func baleRig(_ p: Kit.Person) -> Kit.BodyRig {
        var r = Kit.bodyWalkRig(p)
        r.farElbow = Kit.pt(16, 2)
        r.farHand = Kit.pt(10, -22)
        r.nearElbow = Kit.pt(-8, 20)
        r.nearHand = Kit.pt(-14, 38)
        return r
    }

    /// Standing and staring up, the hands a little open.
    static func gazeRig(_ p: Kit.Person) -> Kit.BodyRig {
        var r = Kit.bodyStandRig(p)
        r.nearElbow = Kit.pt(-14, 16)
        r.nearHand = Kit.pt(-24, 30)
        r.farElbow = Kit.pt(12, 18)
        r.farHand = Kit.pt(22, 32)
        r.openHand = true
        return r
    }

    /// Standing with both hands forward at the waist (holding the unwound turban cloth).
    static func holdRig(_ p: Kit.Person) -> Kit.BodyRig {
        var r = Kit.bodyStandRig(p)
        r.nearElbow = Kit.pt(4, 18)
        r.nearHand = Kit.pt(-4, 26)
        r.farElbow = Kit.pt(-30, 22)
        r.farHand = Kit.pt(-70, 24)
        return r
    }

    /// Kneeling, one hand lifted to hold a stone up to the light.
    static func gemRig(_ p: Kit.Person) -> Kit.BodyRig {
        var r = Kit.bodyKneelRig(p)
        r.lean = 4
        r.nearElbow = Kit.pt(-16, 0)
        r.nearHand = Kit.pt(-28, -28)
        r.farElbow = Kit.pt(-8, 22)
        r.farHand = Kit.pt(-22, 38)
        return r
    }

    /// Sitting up with both hands held out.
    static func offerRig(_ p: Kit.Person) -> Kit.BodyRig {
        var r = Kit.bodySitRig(p)
        r.nearElbow = Kit.pt(-10, 18)
        r.nearHand = Kit.pt(-32, 10)
        r.farElbow = Kit.pt(-24, 20)
        r.farHand = Kit.pt(-58, 12)
        return r
    }

    /// A stick in the leading hand and the other arm thrown up in surprise.
    static func stickRig(_ p: Kit.Person, running: Bool) -> Kit.BodyRig {
        var r = running ? Kit.bodyWalkRig(p) : Kit.bodyStandRig(p)
        r.nearElbow = Kit.pt(-14, 14)
        r.nearHand = Kit.pt(-26, 4)
        r.farElbow = Kit.pt(14, -4)
        r.farHand = Kit.pt(22, -30)
        return r
    }

    /// A merchant with his long plain bird-scaring stick. Origin at the feet, facing LEFT.
    static func stickMan(
        _ context: inout GraphicsContext,
        _ p: Kit.Person,
        running: Bool,
        mouth: Kit.Mouth = .oh,
        look: CGPoint = .zero,
        mirrored: Bool = false
    ) {
        let r = stickRig(p, running: running)
        let h = handOf(p, r)
        rigged(&context, p, r, look: look, mouth: mouth, tilt: 0, mirrored: mirrored)
        Kit.propShaft(&context, h.x + 8, h.y + 46, h.x - 12, h.y - 78, wood: 0x9A7650, width: 3.6)
        Art.fill(&context, Art.circle(h.x, h.y, 5.5), Kit.personTone(p.skin, 1))
    }

    /// The long white turban cloth as a band along SVG path data.
    static func clothBand(_ context: inout GraphicsContext, _ data: String, width: CGFloat) {
        let path = Art.svg(data)
        Art.stroke(&context, path, Art.color(0xCFC3A8), width: width + 1.8)
        Art.stroke(&context, path, Art.color(clothWhite), width: width)
        Art.stroke(&context, path, Art.color(0xE2D8C0, 0.9), width: max(0.8, width * 0.14))
    }
}

// MARK: - Cargo and the quay

extension SindbadArt {
    /// A bale of cloth wrapped in matting and tied with two ropes, centred on (cx, cy).
    static func bale(_ context: inout GraphicsContext, cx: CGFloat, cy: CGFloat, width w: CGFloat, height h: CGFloat, color: UInt32 = 0xC9A66B) {
        let left: CGFloat = cx - w / 2
        let top: CGFloat = cy - h / 2
        let body = Art.rect(left, top, w, h, radius: h * 0.3)
        Kit.solid(&context, body, Art.color(color), light: 0.26, shade: 0.24)
        var weave = Path()
        for i in 1...3 {
            let y: CGFloat = top + h * CGFloat(i) / 4
            weave.move(to: CGPoint(x: left, y: y))
            weave.addLine(to: CGPoint(x: left + w, y: y))
        }
        var ropes = Path()
        let offsets: [CGFloat] = [-0.24, 0.24]
        for offset in offsets {
            let x: CGFloat = cx + w * offset
            ropes.move(to: CGPoint(x: x, y: top))
            ropes.addQuadCurve(to: CGPoint(x: x, y: top + h), control: CGPoint(x: x + w * 0.04, y: cy))
        }
        let weaveLines: Path = weave
        let ropeLines: Path = ropes
        let weaveColor: Color = Kit.propTone(color, 0.74).opacity(0.7)
        Art.clipped(&context, to: body) { g in
            Art.stroke(&g, weaveLines, weaveColor, width: 1, cap: .butt, dash: [4, 3])
            Art.stroke(&g, ropeLines, Art.color(0x7A5A3A), width: max(1.4, h * 0.08))
        }
    }

    /// A tall pottery jar sealed with a lump of clay, standing on baseY.
    static func sealedJar(_ context: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, height h: CGFloat, color: UInt32 = 0xB5683A) {
        let w: CGFloat = h * 0.56
        Kit.pot(&context, cx: cx, baseY: baseY, width: w, height: h, color: color, band: 0x8A4A2A)
        var seal = Path()
        seal.addPath(Art.ellipse(cx, baseY - h, w * 0.25, h * 0.06))
        seal.addPath(Art.ellipse(cx - w * 0.04, baseY - h * 1.04, w * 0.16, h * 0.05))
        Kit.solid(&context, seal, Art.color(0xDCC9A4), light: 0.3, shade: 0.2)
    }

    /// A stack of bales and two jars: the cargo waiting on the quay. About 150 wide; (x, baseY)
    /// is the foot of its middle.
    static func cargo(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat) {
        Kit.shadow(&context, x, baseY, width: 150, alpha: 0.24)
        bale(&context, cx: x - 38, cy: baseY - 15, width: 60, height: 30)
        bale(&context, cx: x + 24, cy: baseY - 15, width: 58, height: 30, color: 0xBF9A5E)
        bale(&context, cx: x - 8, cy: baseY - 44, width: 56, height: 28, color: 0xD4B27A)
        sealedJar(&context, cx: x + 72, baseY: baseY + 2, height: 52)
        sealedJar(&context, cx: x - 84, baseY: baseY + 4, height: 44, color: 0xA85E36)
    }

    /// A line of far date palms in one flat hazy colour.
    static func farPalms(
        _ context: inout GraphicsContext,
        x0: CGFloat,
        x1: CGFloat,
        baseY: CGFloat,
        height: CGFloat,
        count: Int,
        color: Color,
        seed: UInt32
    ) {
        guard count > 0, x1 > x0 else { return }
        var random = ArtRandom(seed)
        var trunks = Path()
        var crowns = Path()
        for i in 0..<count {
            let t: CGFloat = (CGFloat(i) + Kit.rnd(&random)) / CGFloat(count)
            let x: CGFloat = x0 + (x1 - x0) * t
            let h: CGFloat = height * (0.7 + Kit.rnd(&random) * 0.45)
            let lean: CGFloat = (Kit.rnd(&random) - 0.5) * h * 0.2
            let top = CGPoint(x: x + lean, y: baseY - h)
            trunks.move(to: CGPoint(x: x, y: baseY))
            trunks.addQuadCurve(to: top, control: CGPoint(x: x, y: baseY - h * 0.5))
            let reach: CGFloat = h * 0.4
            for j in 0..<7 {
                let a: CGFloat = Kit.deg(196 + CGFloat(j) * 24.6)
                let tipX: CGFloat = top.x + cos(a) * reach
                let tipY: CGFloat = top.y + sin(a) * reach * 0.6 + reach * 0.34
                let midX: CGFloat = top.x + cos(a) * reach * 0.55
                let midY: CGFloat = top.y + sin(a) * reach * 0.8 - reach * 0.16
                crowns.move(to: top)
                crowns.addQuadCurve(to: CGPoint(x: tipX, y: tipY), control: CGPoint(x: midX, y: midY))
            }
        }
        Art.stroke(&context, trunks, color, width: max(1.2, height * 0.05))
        Art.stroke(&context, crowns, color, width: max(1.4, height * 0.075))
    }
}

// MARK: - The dhow

extension SindbadArt {
    /// A dhow seen from the side, bow to the LEFT, in its own units: the waterline is y = 0,
    /// the hull runs from x −114 (the raked stem) to x 100 (the stern), the mast top is near
    /// y −154 and the peak of the long slanting yard near (66, −200). The planks are SEWN:
    /// the seams show their stitches. `full`: the white lateen sail is set and filled;
    /// otherwise it is furled along the yard.
    static func dhow(_ context: inout GraphicsContext, full: Bool) {
        let rope = Art.color(0x5A4636, 0.55)
        Art.stroke(&context, Art.svg("M-20,-152 L-108,-40 M-20,-152 L94,-50"), rope, width: 1)
        Kit.propShaft(&context, -8, -22, -20, -154, wood: sparWood, width: 6)
        if full {
            let cloth = Art.svg("M-100,-66 L62,-196 C80,-150 82,-96 74,-46 C24,-38 -52,-48 -100,-66Z")
            Kit.solid(&context, cloth, stops: Kit.stops(0xFFFDF4, 0xEDE3CC), light: 0.2, shade: 0.2, rim: 2)
            let seams = Art.svg("M-66,-93 C-44,-78 -32,-64 -26,-52 M-30,-122 C-2,-100 12,-72 16,-46 M8,-152 C36,-124 48,-84 48,-44 M40,-178 C62,-150 70,-100 66,-46")
            Art.clipped(&context, to: cloth) { g in
                Art.stroke(&g, seams, Art.color(0xCDBFA0, 0.8), width: 1.2)
            }
            Art.stroke(&context, Art.svg("M74,-46 L92,-48"), rope, width: 1.2)
        }
        Kit.propShaft(&context, -104, -62, 66, -200, wood: sparWood, width: 4.6)
        if !full {
            let a = CGPoint(x: -87, y: -69)
            let b = CGPoint(x: 59, y: -188)
            Art.stroke(&context, Art.line(a.x, a.y, b.x, b.y), Art.color(0xD3C7AC), width: 12)
            Art.stroke(&context, Art.line(a.x - 1, a.y - 1.6, b.x - 1, b.y - 1.6), Art.color(sailWhite), width: 8.6)
            var ties = Path()
            for i in 1..<8 {
                let t: CGFloat = CGFloat(i) / 8
                let x: CGFloat = Kit.mix(a.x, b.x, t)
                let y: CGFloat = Kit.mix(a.y, b.y, t)
                ties.move(to: CGPoint(x: x - 4.4, y: y - 5.4))
                ties.addLine(to: CGPoint(x: x + 4.4, y: y + 5.4))
            }
            Art.stroke(&context, ties, Art.color(0x8A6A48), width: 1.6)
        }
        dhowHull(&context)
    }

    /// The hull of the dhow in the same units: body, sewn seams, gunwale, steering oar.
    static func dhowHull(_ context: inout GraphicsContext) {
        let hull = Art.svg("M-114,-40 C-92,-18 -74,-4 -58,6 L78,6 C88,-8 96,-28 100,-50 L88,-50 C60,-31 10,-24 -30,-24 C-62,-24 -92,-30 -114,-40Z")
        let seams = Art.svg("M-100,-30 C-70,-16 -20,-13 20,-14 C56,-15 82,-24 98,-38 M-84,-20 C-60,-8 -20,-3 20,-4 C52,-5 78,-12 94,-24")
        let stitches: Path = seams.applying(CGAffineTransform(translationX: 0, y: 1.8))
        let dark: Color = Kit.propTone(hullWood, 0.62)
        Kit.propShaft(&context, 90, -46, 106, -2, wood: sparWood, width: 3.2)
        Art.clipped(&context, to: Art.rect(-130, -90, 260, 90)) { g in
            Kit.solid(&g, hull, stops: Kit.stops(0xA06C44, 0x74492C), light: 0.24, shade: 0.26)
            Art.clipped(&g, to: hull) { c in
                Art.stroke(&c, seams, dark, width: 1.4)
                Art.stroke(&c, stitches, Art.color(0xE6D2A8, 0.9), width: 1.4, cap: .butt, dash: [1.6, 3.2])
                Art.fill(&c, Art.rect(-130, -5, 260, 6), ArtStyle.coolShade.opacity(0.22))
            }
        }
        let sheer = Art.svg("M88,-50 C60,-31 10,-24 -30,-24 C-62,-24 -92,-30 -114,-40")
        Art.stroke(&context, sheer, Kit.propTone(hullWood, 0.7), width: 4.4)
        Art.stroke(&context, sheer.applying(CGAffineTransform(translationX: 0, y: -1)), Kit.propTone(hullWood, 1.5), width: 1.6)
        let rail = Art.svg("M58,-36 L60,-56 L96,-66 L98,-50")
        Art.stroke(&context, rail, Kit.propTone(hullWood, 0.8), width: 2.4)
    }

    /// A far dhow under sail: a speck or a small boat, in one hazy tone and a white sail.
    static func farDhow(_ context: inout GraphicsContext, x: CGFloat, waterY: CGFloat, scale: CGFloat) {
        Art.group(&context, x: x, y: waterY, scale: scale) { g in
            let hull = Art.svg("M-22,-6 C-14,-1 -8,1 -4,1 L14,1 C18,-2 20,-6 21,-10 C10,-5 -8,-4 -22,-6Z")
            Art.fill(&g, hull, Art.color(0x7A6650))
            Art.stroke(&g, Art.line(-2, -4, -4, -30), Art.color(0x7A6650), width: 1.4)
            let sail = Art.svg("M-20,-12 L12,-40 C16,-30 16,-18 14,-8 C4,-7 -10,-9 -20,-12Z")
            Art.fill(&g, sail, Art.color(sailWhite))
            Art.fill(&g, Art.svg("M12,-40 C16,-30 16,-18 14,-8 L8,-9 C10,-20 10,-30 12,-40Z"), ArtStyle.coolShade.opacity(0.12))
            Art.fill(&g, Art.rect(-20, 1.5, 40, 1.6, radius: 0.8), Color.white.opacity(0.5))
        }
    }
}

// MARK: - The egg and the Roc

extension SindbadArt {
    /// The outline of the egg standing on baseY: smooth, a little pointed, widest low down.
    static func eggPath(cx: CGFloat, baseY: CGFloat, width w: CGFloat, height h: CGFloat) -> Path {
        var p = Path()
        let top = CGPoint(x: cx, y: baseY - h)
        p.move(to: CGPoint(x: cx - w * 0.42, y: baseY))
        p.addCurve(to: top, control1: CGPoint(x: cx - w * 0.62, y: baseY - h * 0.55), control2: CGPoint(x: cx - w * 0.3, y: baseY - h))
        p.addCurve(to: CGPoint(x: cx + w * 0.42, y: baseY), control1: CGPoint(x: cx + w * 0.3, y: baseY - h), control2: CGPoint(x: cx + w * 0.62, y: baseY - h * 0.55))
        p.closeSubpath()
        return p
    }

    /// The Roc's egg: a huge smooth white dome with no door, window or seam. `shade` is the
    /// shadow of the wing lying across it (in the caller's units), if any.
    static func egg(_ context: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, width w: CGFloat, height h: CGFloat, shade: Path? = nil) {
        let shape = eggPath(cx: cx, baseY: baseY, width: w, height: h)
        let tone: Kit.Stops = [(Art.color(0xFFFEF8), 0), (Art.color(0xFBF5E6), 0.55), (Art.color(0xE8DFCA), 1)]
        Kit.solid(&context, shape, stops: tone, light: 0.16, shade: 0.16, rim: 3)
        let flank: Kit.Stops = [(ArtStyle.coolShade.opacity(0), 0), (ArtStyle.coolShade.opacity(0.14), 1)]
        let bounce: Kit.Stops = [(Art.color(0x9CCB8A, 0), 0), (Art.color(0x9CCB8A, 0.3), 1)]
        let box = CGRect(x: cx - w / 2, y: baseY - h, width: w, height: h)
        Art.clipped(&context, to: shape) { g in
            Art.fillLinear(&g, Path(box), flank, from: CGPoint(x: cx + w * 0.05, y: 0), to: CGPoint(x: cx + w * 0.5, y: 0))
            Art.fillLinear(&g, Path(box), bounce, from: CGPoint(x: 0, y: baseY - h * 0.2), to: CGPoint(x: 0, y: baseY))
            if let shade {
                Art.fill(&g, shade, ArtStyle.coolShade.opacity(0.15))
            }
            ArtStyle.tooth(&g, in: box, seed: 91, color: Art.color(0xD9CDB0), alpha: 0.08)
        }
    }

    /// Adds one long feather: root at (x, y), pointing along `a` (radians), a lens `length`
    /// long and about `width` across.
    static func feather(_ path: inout Path, _ x: CGFloat, _ y: CGFloat, _ a: CGFloat, length: CGFloat, width: CGFloat) {
        let c: CGFloat = cos(a)
        let s: CGFloat = sin(a)
        let tip = CGPoint(x: x + c * length, y: y + s * length)
        let mx: CGFloat = x + c * length * 0.5
        let my: CGFloat = y + s * length * 0.5
        path.move(to: CGPoint(x: x, y: y))
        path.addQuadCurve(to: tip, control: CGPoint(x: mx - s * width, y: my + c * width))
        path.addQuadCurve(to: CGPoint(x: x, y: y), control: CGPoint(x: mx + s * width, y: my - c * width))
        path.closeSubpath()
    }

    /// Part of the Roc's wing: a fan of long white feathers edged with gold, from `root`,
    /// sweeping from angle `a0` to `a1` (degrees; 90 points down, 180 left).
    static func rocWing(_ context: inout GraphicsContext, root: CGPoint, from a0: CGFloat, to a1: CGFloat, length: CGFloat, count: Int) {
        let n: Int = max(2, count)
        var long = Path()
        var middle = Path()
        var short = Path()
        for i in 0..<n {
            let t: CGFloat = CGFloat(i) / CGFloat(n - 1)
            let a: CGFloat = Kit.deg(Kit.mix(a0, a1, t))
            let reach: CGFloat = length * (0.82 + 0.18 * sin(t * CGFloat.pi))
            feather(&long, root.x, root.y, a, length: reach, width: reach * 0.16)
            feather(&middle, root.x, root.y, a + 0.04, length: reach * 0.62, width: reach * 0.15)
            feather(&short, root.x, root.y, a - 0.03, length: reach * 0.36, width: reach * 0.14)
        }
        Art.fill(&context, long, Art.color(0xFFFBF0))
        Kit.model(&context, long, light: 0.1, shade: 0.14)
        Art.stroke(&context, long, Art.color(rocGold, 0.85), width: max(1.2, length * 0.012))
        Art.fill(&context, middle, Art.color(0xFBEFD0))
        Art.stroke(&context, middle, Art.color(0xD9A548, 0.7), width: max(1, length * 0.009))
        Art.fill(&context, short, Art.color(0xF3D58E))
        Art.stroke(&context, short, Art.color(0xC98A2B, 0.6), width: max(1, length * 0.008))
    }

    /// The soft shadow of a vast wing: the same fan as one flat shape, for the ground and the egg.
    static func wingShadow(root: CGPoint, from a0: CGFloat, to a1: CGFloat, length: CGFloat, count: Int, squash: CGFloat) -> Path {
        let n: Int = max(2, count)
        var fan = Path()
        for i in 0..<n {
            let t: CGFloat = CGFloat(i) / CGFloat(n - 1)
            let a: CGFloat = Kit.deg(Kit.mix(a0, a1, t))
            let reach: CGFloat = length * (0.8 + 0.2 * sin(t * CGFloat.pi))
            feather(&fan, 0, 0, a, length: reach, width: reach * 0.2)
        }
        let flat = CGAffineTransform(translationX: root.x, y: root.y).scaledBy(x: 1, y: squash)
        return fan.applying(flat)
    }

    /// The Roc's head and neck, facing LEFT, in its own units: the head is about 64 across,
    /// centred near (5, 0); the neck runs down to y 124. Calm: it looks past the reader.
    static func rocHead(_ context: inout GraphicsContext) {
        let neck = Art.svg("M-18,18 C-34,44 -40,80 -36,124 L84,124 C80,70 62,14 30,-20Z")
        Kit.solid(&context, neck, stops: Kit.stops(0xFFFBF0, 0xF3E3BC), light: 0.2, shade: 0.2)
        var rows = Path()
        let lines: [(CGFloat, CGFloat, Int)] = [(-26, 46, 5), (-32, 68, 6), (-34, 92, 7), (-34, 114, 7)]
        for line in lines {
            var x: CGFloat = line.0
            let y: CGFloat = line.1
            for _ in 0..<line.2 {
                rows.move(to: CGPoint(x: x, y: y))
                rows.addQuadCurve(to: CGPoint(x: x + 16, y: y), control: CGPoint(x: x + 8, y: y + 11))
                x += 16
            }
        }
        let featherRows: Path = rows
        Art.clipped(&context, to: neck) { g in
            Art.stroke(&g, featherRows, Art.color(rocGold, 0.75), width: 1.8)
        }
        var crest = Path()
        feather(&crest, 22, -22, Kit.deg(-28), length: 34, width: 9)
        feather(&crest, 28, -12, Kit.deg(-12), length: 36, width: 9)
        feather(&crest, 30, 0, Kit.deg(6), length: 32, width: 9)
        Art.fill(&context, crest, Art.color(0xFFFBF0))
        Art.stroke(&context, crest, Art.color(rocGold, 0.85), width: 1.4)
        let skull = Art.svg("M-26,-2 C-27,-20 -12,-32 6,-32 C24,-32 37,-19 37,-1 C37,17 25,30 8,30 C-8,30 -22,22 -26,-2Z")
        Kit.solid(&context, skull, Art.color(0xFFFCF4), light: 0.16, shade: 0.2, rim: 2)
        let upper = Art.svg("M-20,-12 C-34,-15 -50,-8 -56,6 C-58,14 -55,21 -50,23 C-49,15 -44,10 -36,9 C-29,8 -23,7 -19,4Z")
        Kit.solid(&context, upper, stops: Kit.stops(0xF6C552, 0xD9912A), light: 0.3, shade: 0.2)
        Art.fill(&context, Art.svg("M-20,5 C-28,9 -36,10 -44,11 C-41,17 -30,19 -19,13Z"), Art.color(0xC98628))
        Art.stroke(&context, Art.svg("M-19,4 C-27,8 -36,9 -45,10"), Art.color(0x8A5A1E, 0.8), width: 1.3)
        Art.fill(&context, Art.ellipse(-31, -4, 2.4, 1.4), Art.color(0x8A5A1E, 0.7))
        Art.fill(&context, Art.circle(-4, -8, 7), Art.color(rocGold))
        ArtStyle.eye(&context, -4, -8, 4.8, look: CGPoint(x: -0.4, y: 0), iris: Art.color(0x2A1A12), showsWhite: false)
        Art.stroke(&context, Art.svg("M-13,-17 C-7,-20 1,-20 7,-17"), Art.color(0xD9B872), width: 1.8)
        ArtStyle.cheek(&context, -6, 9, 8, color: Art.color(0xF6C98A), alpha: 0.3)
    }

    /// One golden leg and foot of the Roc in its own units: the ankle at the origin, the
    /// scaled leg rising up and to the right out of sight (to about (68, −264)), three toes
    /// closing below the ankle (down to y 56).
    static func rocFoot(_ context: inout GraphicsContext) {
        let leg = Art.svg("M-20,4 C-16,-70 6,-170 44,-270 L92,-258 C58,-160 34,-70 26,6Z")
        Kit.solid(&context, leg, stops: Kit.stops(0xF2C050, 0xD08E2C), light: 0.28, shade: 0.26, rim: 3)
        var scales = Path()
        for i in 0..<12 {
            let t: CGFloat = CGFloat(i) / 12
            let y: CGFloat = -8 - t * 250
            let x: CGFloat = 2 + t * 44 + t * t * 20
            scales.move(to: CGPoint(x: x - 28, y: y + 4))
            scales.addQuadCurve(to: CGPoint(x: x + 28, y: y - 4), control: CGPoint(x: x, y: y + 12))
        }
        let scaleLines: Path = scales
        Art.clipped(&context, to: leg) { g in
            Art.stroke(&g, scaleLines, Art.color(0xA86E20, 0.6), width: 1.8)
        }
        let toes = Art.svg("M-18,-2 C-44,2 -62,16 -66,36 C-58,30 -46,22 -30,20Z M-6,4 C-16,22 -16,40 -6,54 C-2,42 2,32 10,22Z M24,0 C44,6 58,20 60,40 C52,32 40,26 26,22Z")
        Kit.solid(&context, toes, stops: Kit.stops(0xEDB848, 0xC98628), light: 0.26, shade: 0.24)
        var tips = Path()
        tips.addPath(Art.ellipse(-65, 35, 4, 6))
        tips.addPath(Art.ellipse(-6, 53, 4, 6))
        tips.addPath(Art.ellipse(60, 39, 4, 6))
        Art.fill(&context, tips, Art.color(0x8A6A3A))
        Kit.solid(&context, Art.ellipse(3, 4, 26, 14), Art.color(0xE6AE40), light: 0.26, shade: 0.2)
    }
}

// MARK: - The valley and the nest

extension SindbadArt {
    /// One rough crystal: an uneven five-sided lump (never a cut jewel).
    static func crystalPath(_ x: CGFloat, _ y: CGFloat, _ r: CGFloat, _ random: inout ArtRandom) -> Path {
        var points: [CGPoint] = []
        for k in 0..<5 {
            let a: CGFloat = Kit.deg(CGFloat(k) * 72 + Kit.rnd(&random) * 40)
            let d: CGFloat = r * (0.7 + Kit.rnd(&random) * 0.5)
            points.append(CGPoint(x: x + cos(a) * d, y: y + sin(a) * d * 0.8))
        }
        return Art.polygon(points)
    }

    /// Rough clear and pale-yellow stones strewn over `rect`, larger toward its foot, with a
    /// few small hard glints. `size` is the radius of a middling stone.
    static func stones(_ context: inout GraphicsContext, in rect: CGRect, count: Int, seed: UInt32, size: CGFloat = 4) {
        guard rect.width > 0, rect.height > 0 else { return }
        var random = ArtRandom(seed)
        var shades = Path()
        var clear = Path()
        var yellow = Path()
        var glints = Path()
        for i in 0..<max(0, count) {
            let x: CGFloat = rect.minX + rect.width * Kit.rnd(&random)
            let t: CGFloat = Kit.rnd(&random)
            let y: CGFloat = rect.minY + rect.height * t
            let grain: CGFloat = 0.6 + Kit.rnd(&random) * 0.8
            let r: CGFloat = size * grain * (0.7 + 0.5 * t)
            let lump = crystalPath(x, y, r, &random)
            shades.addEllipse(in: CGRect(x: x - r + 1.5, y: y - r * 0.1, width: r * 2.2, height: r * 0.8))
            if i % 3 == 0 {
                yellow.addPath(lump)
            } else {
                clear.addPath(lump)
            }
            if i % 4 == 0 {
                glints.addPath(Art.spark(x - r * 0.3, y - r * 0.6, r * 0.8))
            }
        }
        Art.fill(&context, shades, ArtStyle.coolShade.opacity(0.18))
        Art.fill(&context, clear, Art.color(0xF4FBFA))
        Art.stroke(&context, clear, Art.color(0x8FC3C8, 0.9), width: 0.9)
        Art.fill(&context, yellow, Art.color(0xFBEFB8))
        Art.stroke(&context, yellow, Art.color(0xD3B158, 0.9), width: 0.9)
        Art.fill(&context, glints, Color.white)
    }

    /// One large rough diamond, as big as a fist, catching the light.
    static func crystal(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, r: CGFloat) {
        Art.glow(&context, x, y, r * 2.6, Color.white, alpha: 0.5)
        let points: [CGPoint] = [
            CGPoint(x: x - r * 0.9, y: y + r * 0.2), CGPoint(x: x - r * 0.5, y: y - r * 0.7),
            CGPoint(x: x + r * 0.2, y: y - r), CGPoint(x: x + r * 0.9, y: y - r * 0.3),
            CGPoint(x: x + r * 0.7, y: y + r * 0.6), CGPoint(x: x - r * 0.2, y: y + r * 0.9),
        ]
        let shape = Art.polygon(points)
        Kit.solid(&context, shape, stops: Kit.stops(0xFFFFFF, 0xCFEFF0), light: 0.2, shade: 0.12)
        Art.stroke(&context, shape, Art.color(0x8FC6CC), width: max(0.8, r * 0.1))
        let plane = Art.line(x - r * 0.5, y - r * 0.7, x + r * 0.1, y + r * 0.15)
        Art.stroke(&context, plane, Art.color(0xA9D9DC, 0.8), width: max(0.7, r * 0.07))
        Art.fill(&context, Art.spark(x - r * 0.45, y - r * 0.95, r * 0.9), Color.white)
    }

    /// The slab of meat, like a side of mutton, about 76 × 40, centred on the origin. No blood.
    static func meat(_ context: inout GraphicsContext) {
        let slab = Art.svg("M-34,-6 C-30,-20 -8,-22 10,-18 C28,-16 36,-6 34,6 C30,18 6,20 -12,18 C-28,16 -38,8 -34,-6Z")
        Kit.solid(&context, slab, stops: Kit.stops(0xC9654E, 0xA8483A), light: 0.24, shade: 0.22, rim: 2)
        Art.clipped(&context, to: slab) { g in
            Art.stroke(&g, Art.svg("M-30,2 C-14,-8 8,-8 30,0"), Art.color(0xF2DCC4, 0.85), width: 4)
            Art.stroke(&g, Art.svg("M-22,12 C-8,6 10,6 24,12"), Art.color(0xE9BFA6, 0.6), width: 2)
        }
        var bone = Path()
        bone.addPath(Art.ellipse(36, 2, 5, 6))
        bone.addPath(Art.ellipse(40, -2, 3.4, 3.4))
        bone.addPath(Art.ellipse(40, 6, 3.4, 3.4))
        Kit.solid(&context, bone, Art.color(0xF6EEDC), light: 0.2, shade: 0.16)
    }

    /// The eagle's nest: a wide untidy platform of sticks, `w` wide, its foot on baseY and
    /// its rim about `w` × 0.2 above it.
    static func nest(_ context: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, width w: CGFloat, seed: UInt32 = 5) {
        let h: CGFloat = w * 0.26
        var bowl = Path()
        bowl.move(to: CGPoint(x: cx - w / 2, y: baseY - h * 0.6))
        bowl.addQuadCurve(to: CGPoint(x: cx + w / 2, y: baseY - h * 0.6), control: CGPoint(x: cx, y: baseY - h * 1.05))
        bowl.addQuadCurve(to: CGPoint(x: cx - w / 2, y: baseY - h * 0.6), control: CGPoint(x: cx, y: baseY + h * 0.8))
        bowl.closeSubpath()
        Kit.shadow(&context, cx, baseY, width: w * 0.9, alpha: 0.28)
        Kit.solid(&context, bowl, Art.color(0x6B4A30), light: 0.2, shade: 0.26)
        var random = ArtRandom(seed)
        var tones: [Path] = [Path(), Path(), Path()]
        let n: Int = max(12, Int(w / 2.4))
        for i in 0..<n {
            let u: CGFloat = Kit.rnd(&random) - 0.5
            let v: CGFloat = Kit.rnd(&random)
            let room: CGFloat = max(0.2, 1 - abs(u) * 1.5)
            let x: CGFloat = cx + u * w * 0.94
            let y: CGFloat = baseY - h * (0.12 + v * 0.74 * room)
            let a: CGFloat = (Kit.rnd(&random) - 0.5) * 0.9
            let half: CGFloat = w * (0.07 + Kit.rnd(&random) * 0.09)
            let dx: CGFloat = cos(a) * half
            let dy: CGFloat = sin(a) * half
            tones[i % 3].move(to: CGPoint(x: x - dx, y: y - dy))
            tones[i % 3].addLine(to: CGPoint(x: x + dx, y: y + dy))
        }
        Art.stroke(&context, tones[0], Art.color(0x5A3D28), width: 3)
        Art.stroke(&context, tones[1], Art.color(0x8A6240), width: 2.6)
        Art.stroke(&context, tones[2], Art.color(0xB98F5E), width: 2.2)
    }

    /// The ordinary large brown eagle of the nest, flapping away to the RIGHT, in its own
    /// units: the body about 60 long round the origin, the wings raised to about y −76.
    static func eagle(_ context: inout GraphicsContext) {
        var farWing = Path()
        for i in 0..<7 {
            let a: CGFloat = Kit.deg(-150 + CGFloat(i) * 11)
            feather(&farWing, -2, -6, a, length: 60 - CGFloat(i) * 3, width: 11)
        }
        Art.fill(&context, farWing, Art.color(0x6B4A30))
        var tail = Path()
        for i in 0..<4 {
            let a: CGFloat = Kit.deg(158 + CGFloat(i) * 10)
            feather(&tail, -16, 4, a, length: 34, width: 9)
        }
        Art.fill(&context, tail, Art.color(0x5A3D28))
        Art.stroke(&context, tail, Art.color(0x8A6240, 0.7), width: 1)
        let body = Art.svg("M-24,2 C-16,-12 14,-14 30,-6 C36,-2 34,6 26,8 C10,14 -12,12 -24,2Z")
        Kit.solid(&context, body, Art.color(0x7A5536), light: 0.22, shade: 0.22)
        let head = Art.svg("M24,-8 C26,-16 38,-18 43,-11 C46,-6 42,1 35,2 C29,3 24,-1 24,-8Z")
        Kit.solid(&context, head, Art.color(0xE4D2A6), light: 0.2, shade: 0.16)
        Art.fill(&context, Art.svg("M42,-10 C49,-10 52,-6 50,0 C48,-3 45,-4 41,-4Z"), Art.color(0xE0A83A))
        ArtStyle.eye(&context, 37, -9, 1.9, look: .zero, iris: Art.color(0x2A1A12), showsWhite: false)
        var nearWing = Path()
        for i in 0..<8 {
            let a: CGFloat = Kit.deg(-132 + CGFloat(i) * 11)
            let fall: CGFloat = abs(CGFloat(i) - 3.5) * 3
            feather(&nearWing, 4, -4, a, length: 72 - fall, width: 13)
        }
        Art.fill(&context, nearWing, Art.color(0x8A6240))
        Kit.model(&context, nearWing, light: 0.2, shade: 0.2)
        Art.stroke(&context, nearWing, Art.color(0x5A3D28, 0.6), width: 1)
    }
}

// MARK: - Sindbad in his poses

extension SindbadArt {
    /// Sindbad walking with a bale on his shoulder. Origin at the feet, facing LEFT.
    static func sindbadWithBale(_ context: inout GraphicsContext, mouth: Kit.Mouth = .smile, look: CGPoint = .zero) {
        let p = sindbadLook()
        bale(&context, cx: 34, cy: -133, width: 52, height: 28)
        rigged(&context, p, baleRig(p), look: look, mouth: mouth)
    }

    /// A porter walking with a bale on his shoulder. Origin at the feet, facing LEFT.
    static func porterWithBale(_ context: inout GraphicsContext, tunic: UInt32, mirrored: Bool = false) {
        let p = porterLook(tunic: tunic)
        bale(&context, cx: 34, cy: -133, width: 50, height: 26, color: 0xBF9A5E)
        rigged(&context, p, baleRig(p), look: .zero, mouth: .flat, tilt: 0, mirrored: mirrored)
    }

    /// Sindbad standing with his head tipped back, staring up. Origin at the feet, facing LEFT.
    static func sindbadGazing(_ context: inout GraphicsContext, mouth: Kit.Mouth = .oh, mirrored: Bool = false) {
        let p = sindbadLook()
        rigged(&context, p, gazeRig(p), look: CGPoint(x: -0.4, y: -1), mouth: mouth, tilt: 0.3, mirrored: mirrored)
    }

    /// Sindbad with the turban unwound: the long white cloth in both hands and trailing on
    /// the ground. Origin at the feet, facing LEFT.
    static func sindbadWithCloth(_ context: inout GraphicsContext, mouth: Kit.Mouth = .oh) {
        let p = sindbadLook(turban: false)
        clothBand(&context, "M-22,-79 C-10,-40 10,-14 36,-4 C52,2 66,-6 78,-2", width: 7)
        rigged(&context, p, holdRig(p), look: CGPoint(x: -0.4, y: -1), mouth: mouth, tilt: 0.3)
        clothBand(&context, "M-54,-81 C-44,-90 -32,-90 -22,-79", width: 7)
        clothBand(&context, "M-54,-81 C-62,-56 -58,-30 -66,-6", width: 7)
    }

    /// Sindbad kneeling with a diamond as big as his fist held up to the light. Origin on
    /// the ground under him, facing LEFT.
    static func sindbadWithGem(_ context: inout GraphicsContext, mouth: Kit.Mouth = .grin) {
        let p = sindbadLook()
        let r = gemRig(p)
        let h = handOf(p, r)
        rigged(&context, p, r, look: CGPoint(x: -0.8, y: -0.5), mouth: mouth, tilt: 0.12)
        crystal(&context, x: h.x - 4, y: h.y - 8, r: 9)
    }

    /// Sindbad sitting up with the slab of meat tied to his back by the white turban cloth,
    /// both hands held out full of stones. Origin on the ground under the seat (the caller
    /// draws what he sits on, 34 high), facing LEFT.
    static func sindbadWithMeat(_ context: inout GraphicsContext, mouth: Kit.Mouth = .smile, look: CGPoint = .zero) {
        let p = sindbadLook(turban: false)
        Art.group(&context, x: 36, y: -80, rotate: Kit.deg(78)) { g in
            meat(&g)
        }
        rigged(&context, p, offerRig(p), look: look, mouth: mouth)
        clothBand(&context, "M-14,-94 C-2,-82 14,-74 29,-68", width: 5)
        clothBand(&context, "M-13,-66 C0,-74 16,-84 28,-94", width: 5)
        clothBand(&context, "M30,-66 C44,-58 52,-44 48,-26", width: 5)
        stones(&context, in: CGRect(x: -54, y: -90, width: 20, height: 5), count: 7, seed: 44, size: 3.2)
        Art.fill(&context, Art.spark(-46, -96, 5), Color.white)
    }
}
