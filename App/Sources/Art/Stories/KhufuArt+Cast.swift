import SwiftUI
import OmramoCore

// The cast and the shared parts of "King Khufu and the Magician": palette, the two lights,
// King Khufu, Dedi, Prince Hordedef, the court, the goose, the king's chair, the river boat,
// the half-built pyramid and the small things of an Old Kingdom hall and river bank.

// MARK: - Palette and light

extension KhufuArt {
    /// Sand gold and limestone white, with small notes of lotus blue-green.
    static let ramp = ArtStyle.Ramp(deep: 0x33210F, shade: 0x9A6B34, mid: 0xD9B36A, light: 0xF8EED6, glow: 0xFFE2A0, accent: 0x2F8F8A)

    static let skinHex: UInt32 = 0xA9603A
    static let oldSkinHex: UInt32 = 0x9E5834
    static let linenHex: UInt32 = 0xF7F1E1
    static let wigHex: UInt32 = 0x241B1B
    static let goldHex: UInt32 = 0xE0A92E
    static let redHex: UInt32 = 0xB8492E
    static let woodHex: UInt32 = 0x8A5A34
    static let darkWoodHex: UInt32 = 0x6E4A2A
    static let plasterHex: UInt32 = 0xF5ECD6
    static let mudHex: UInt32 = 0xD8BC8C
    static let nileHex: UInt32 = 0x7DBDB0
    static let papyrusHex: UInt32 = 0xE4CF9A
    static let fieldHex: UInt32 = 0x8DB06A

    /// High pale daylight: the hall and the river.
    static func day() -> Kit.Light {
        let sky: Kit.Stops = [(Art.color(0xE4F0EE), 0), (Art.color(0xF2F1DF), 0.6), (Art.color(0xFFEBBE), 1)]
        return Kit.Light(sky: sky, sun: 0xFFF6DC, glow: 0xFFE2A0, haze: 0xF6EDD2, far: 0xEAD9B0, mid: 0xDCC592, near: 0x9DB07E)
    }

    /// The late, pale-gold afternoon of the terrace. Never red, never dark.
    static func afternoon() -> Kit.Light {
        let sky: Kit.Stops = [(Art.color(0xFBF1D6), 0), (Art.color(0xFBE7B8), 0.6), (Art.color(0xFFE2A0), 1)]
        return Kit.Light(sky: sky, sun: 0xFFF3CF, glow: 0xFFD98A, haze: 0xFBE6BC, far: 0xEBD3A0, mid: 0xD9BC80, near: 0xA8A866)
    }

    /// The pale floor of the hall: limestone plaster, a little warmer toward the viewer.
    static func floorStops() -> Kit.Stops {
        [(Art.color(0xF1E5C6), 0), (Art.color(0xE3CFA0), 0.6), (Art.color(0xCFB57E), 1)]
    }

    static func waterStops() -> Kit.Stops {
        [(Art.color(0xA9D6C8), 0), (Art.color(nileHex), 0.5), (Art.color(0x4F9C96), 1)]
    }
}

// MARK: - Looks

extension KhufuArt {
    static func khufuLook() -> Kit.Person {
        Kit.Person(
            age: .adult, skin: skinHex, hair: wigHex, hairStyle: .short, beard: .none,
            headwear: .headcloth, headwearColor: 0xF3E7C6, garment: .kilt,
            cloth: linenHex, trim: 0x2F8F8A, legs: skinHex, showsEyeWhite: false
        )
    }

    /// Dedi wears no jewels: the collar of the kit's kilt is given his own skin colour.
    static func dediLook() -> Kit.Person {
        Kit.Person(
            age: .elder, skin: oldSkinHex, hair: 0xF6F2EA, hairStyle: .short, beard: .none,
            headwear: .none, headwearColor: 0xFFFFFF, garment: .kilt,
            cloth: linenHex, trim: oldSkinHex, legs: oldSkinHex, showsEyeWhite: false
        )
    }

    static func princeLook() -> Kit.Person {
        Kit.Person(
            age: .adult, skin: 0xB0663E, hair: wigHex, hairStyle: .bob, beard: .none,
            headwear: .none, headwearColor: 0xFFFFFF, garment: .kilt,
            cloth: linenHex, trim: 0x3D7FA6, legs: 0xB0663E, showsEyeWhite: false
        )
    }

    /// The court. 0: a servant (no collar, cropped hair); 1 and 2: the king's other sons.
    static func courtLook(_ kind: Int) -> Kit.Person {
        let skins: [UInt32] = [0xA05A36, 0xAD643C, 0xA45C38]
        let trims: [UInt32] = [0xA05A36, redHex, 0xD9A63A]
        let index: Int = max(0, min(2, kind))
        let style: Kit.Person.Hair = index == 0 ? .shaved : .bob
        return Kit.Person(
            age: .adult, skin: skins[index], hair: wigHex, hairStyle: style, beard: .none,
            headwear: .none, headwearColor: 0xFFFFFF, garment: .kilt,
            cloth: linenHex, trim: trims[index], legs: skins[index], showsEyeWhite: false
        )
    }
}

// MARK: - A kit person in a rig of our own

extension KhufuArt {
    /// Draws a kit person in a pose of our own (the kit's poses have no chin on a fist and no
    /// raised staff): the body by `Kit.bodyFigure`, then the head as `Kit.person` sets it, then
    /// `head` in the head's own space (brows, a gold band, wrinkles). `beads` adds two rows of
    /// beads to the collar. Origin and facing as `Kit.person`.
    static func figure(
        _ context: inout GraphicsContext,
        _ p: Kit.Person,
        rig r: Kit.BodyRig,
        look: CGPoint = .zero,
        mouth: Kit.Mouth = .smile,
        mirrored: Bool = false,
        beads: UInt32? = nil,
        head: (inout GraphicsContext) -> Void
    ) {
        let f = Kit.bodyFrame(p)
        let turn: CGFloat = -Kit.deg(r.lean)
        Art.group(&context, scale: f.k) { g in
            Kit.bodyFigure(&g, p, r, mirrored: mirrored)
            if let beads {
                Art.group(&g, x: r.hip.x, y: r.hip.y, rotate: turn) { t in
                    Art.stroke(&t, Art.svg("M-15,-51 C-10,-36 9,-36 13,-51"), Art.color(beads), width: 1.8)
                    Art.stroke(&t, Art.svg("M-11,-52 C-7,-43 5,-43 9,-52"), Art.color(redHex), width: 1.5)
                }
            }
        }
        let c = Kit.bodyHeadCentre(f, r)
        let tilt: CGFloat = turn * 0.45
        Art.group(&context, x: c.x, y: c.y, rotate: tilt, scale: f.headScale) { g in
            Kit.personHead(&g, p, look: look, mouth: mouth, closedEyes: false, mirrored: mirrored)
            head(&g)
        }
    }

    /// Where the leading hand of a rig is, in the person's own units.
    static func rigHand(_ p: Kit.Person, _ r: Kit.BodyRig) -> CGPoint {
        let f = Kit.bodyFrame(p)
        let s = Kit.bodyShoulder(r, near: true)
        let x: CGFloat = (s.x + r.nearHand.x) * f.k
        let y: CGFloat = (s.y + r.nearHand.y) * f.k
        return CGPoint(x: x, y: y)
    }
}

// MARK: - King Khufu

extension KhufuArt {
    enum KingPose { case chin, amazed, stand, point }

    /// What the king's head wears over the kit's striped headcloth: a thin gold band on the
    /// brow and his heavy dark eyebrows. `left` / `right` lift each brow (units, up).
    static func kingHead(_ g: inout GraphicsContext, left: CGFloat, right: CGFloat) {
        let band: Path = Art.svg("M-27.6,-7.5 C-21,-17 -11,-20.5 0,-20.5 C11,-20.5 21,-17 27.6,-7.5")
        Art.stroke(&g, band, Art.color(goldHex), width: 2.4)
        Art.stroke(&g, band.applying(CGAffineTransform(translationX: 0, y: -1)), Art.color(0xFFE9A8, 0.6), width: 0.8)
        let browL: Path = Art.svg("M-16,-7.4 q5.6,-3 11.4,-0.6").applying(CGAffineTransform(translationX: 0, y: -left))
        let browR: Path = Art.svg("M4.6,-8 q5.4,-2.6 11,0.8").applying(CGAffineTransform(translationX: 0, y: -right))
        Art.stroke(&g, browL, Art.color(wigHex), width: 3.2)
        Art.stroke(&g, browR, Art.color(wigHex), width: 3.2)
    }

    /// King Khufu, facing LEFT. Seated poses (`chin`, `amazed`): the origin is the top of the
    /// platform under his chair (draw `throne` first, at the same origin). Standing poses: the
    /// ground between his feet. The caller draws the shadow.
    static func king(_ context: inout GraphicsContext, pose: KingPose, mirrored: Bool = false) {
        let p = khufuLook()
        switch pose {
        case .chin:
            var r = Kit.bodySitRig(p)
            r.lean = 14
            r.nearElbow = Kit.pt(-8, 15)
            r.nearHand = Kit.pt(-16, 30)
            r.farElbow = Kit.pt(-12, 22)
            r.farHand = Kit.pt(-26, 42)
            figure(&context, p, rig: r, look: CGPoint(x: -0.5, y: 0), mouth: .flat, mirrored: mirrored, beads: goldHex) { h in
                kingHead(&h, left: 0, right: 2.6)
            }
            // The forearm from the knee up to the chin, and the fist the chin rests on.
            let skin: Color = Art.color(skinHex)
            Art.stroke(&context, Art.line(-34, -58, -29, -95), skin, width: 10)
            Art.fill(&context, Art.circle(-28, -100, 6.8), skin)
            Art.stroke(&context, Art.svg("M-32,-101 q4,-3 8,0"), Kit.personTone(skinHex, 0.72), width: 1.2)
        case .amazed:
            var r = Kit.bodySitRig(p)
            r.lean = 6
            r.nearElbow = Kit.pt(-16, 4)
            r.nearHand = Kit.pt(-28, -18)
            r.openHand = true
            r.farElbow = Kit.pt(-18, 6)
            r.farHand = Kit.pt(-36, -14)
            figure(&context, p, rig: r, look: CGPoint(x: -0.7, y: 0.4), mouth: .oh, mirrored: mirrored, beads: goldHex) { h in
                kingHead(&h, left: 3, right: 3)
            }
        case .stand:
            let r = Kit.bodyStandRig(p)
            figure(&context, p, rig: r, look: CGPoint(x: -0.6, y: 0), mouth: .smile, mirrored: mirrored, beads: goldHex) { h in
                kingHead(&h, left: 0, right: 0)
            }
        case .point:
            var r = Kit.bodyStandRig(p)
            r.nearElbow = Kit.pt(-18, 2)
            r.nearHand = Kit.pt(-38, -8)
            figure(&context, p, rig: r, look: CGPoint(x: -0.7, y: 0), mouth: .smile, mirrored: mirrored, beads: goldHex) { h in
                kingHead(&h, left: 1.5, right: 1.5)
            }
        }
    }

    /// The king's chair: a low-backed wooden throne with lion-paw legs and a linen cushion, on
    /// a low platform. Faces LEFT. Origin: the top of the platform under the seat (the seated
    /// king's origin); the platform is 12 high, so the floor is at y 12. Draws its own shadow.
    static func throne(_ context: inout GraphicsContext) {
        Kit.shadow(&context, 4, 13, width: 150)
        let slab: Path = Art.rect(-64, 0, 128, 12, radius: 2)
        Kit.solid(&context, slab, Art.color(0xEADCB8), light: 0.3, shade: 0.2)
        Art.stroke(&context, Art.line(-62, 4, 62, 4), Art.color(ramp.accent, 0.7), width: 1.6, cap: .butt)
        Art.stroke(&context, Art.line(-62, 7.5, 62, 7.5), Art.color(redHex, 0.6), width: 1.2, cap: .butt)
        let wood: Color = Art.color(woodHex)
        let back: Path = Art.svg("M29,-32 L30,-72 Q34.5,-79 40,-72 L41,-32Z")
        Kit.solid(&context, back, wood, light: 0.3, shade: 0.24)
        Art.stroke(&context, Art.line(31, -64, 39, -64), Art.color(goldHex), width: 1.6, cap: .butt)
        let paw: String = "M-3.5,-28 C-1.5,-18 -4.5,-11 -2.5,-5 L-7,-0.5 Q-7,0 -6,0 L5,0 L3.5,-5 C2.5,-12 4.5,-19 3.5,-28Z"
        var legs = Path()
        legs.addPath(Kit.placed(paw, x: -9, y: 0))
        legs.addPath(Kit.placed(paw, x: 33, y: 0))
        Kit.solid(&context, legs, wood, light: 0.26, shade: 0.24)
        var toes = Path()
        let feet: [CGFloat] = [-9, 33]
        for x in feet {
            toes.move(to: CGPoint(x: x - 4, y: -1))
            toes.addLine(to: CGPoint(x: x - 4, y: -3.4))
            toes.move(to: CGPoint(x: x - 1, y: -1))
            toes.addLine(to: CGPoint(x: x - 1, y: -3.4))
        }
        Art.stroke(&context, toes, Kit.propTone(woodHex, 0.62), width: 0.9)
        let seat: Path = Art.rect(-16, -34, 58, 7, radius: 2)
        Kit.solid(&context, seat, wood, light: 0.3, shade: 0.22)
        Art.fill(&context, Art.rect(-12, -38.5, 48, 5.5, radius: 2.7), Art.color(linenHex))
        Art.stroke(&context, Art.line(-14, -28.4, 40, -28.4), Art.color(goldHex, 0.8), width: 1.2, cap: .butt)
    }
}

// MARK: - Dedi

extension KhufuArt {
    enum SagePose { case staff, cast, sit }

    /// Dedi is as small as a boy: the kit's elder, drawn at this scale.
    static let dediScale: CGFloat = 0.72

    /// A hundred and ten years of lines, over the kit's elder face.
    static func dediHead(_ g: inout GraphicsContext) {
        let line: Color = Kit.personTone(oldSkinHex, 0.68).opacity(0.75)
        let brow: Path = Art.svg("M-11,-15 q6,-2.2 12,0 M-8,-19.6 q5,-1.6 10,0")
        Art.stroke(&g, brow, line, width: 1)
        let feet: Path = Art.svg("M-20.5,1 l-4,-2.4 M-20.8,3.4 l-4.2,0.6 M20.5,1 l4,-2.4 M20.8,3.4 l4.2,0.6")
        Art.stroke(&g, feet, line, width: 1)
        let cheeks: Path = Art.svg("M-11.5,12 q-2.4,4 -0.6,8 M10.5,12 q2.4,4 0.6,8")
        Art.stroke(&g, cheeks, line, width: 1)
    }

    /// Dedi, tiny, facing LEFT, origin on the ground between his feet (`sit`: the ground under
    /// his seat, which is 24 high and drawn by the caller). `staff`: his plain staff, taller
    /// than he is, planted before him. `cast`: the staff lifted over what stands before him.
    /// `sit`: both hands held out to be pulled up. About 116 tall standing.
    static func dedi(_ context: inout GraphicsContext, pose: SagePose, mouth: Kit.Mouth = .smile, mirrored: Bool = false) {
        let p = dediLook()
        var r: Kit.BodyRig
        switch pose {
        case .staff:
            r = Kit.bodyStandRig(p)
            r.nearElbow = Kit.pt(-10, 14)
            r.nearHand = Kit.pt(-20, 20)
        case .cast:
            r = Kit.bodyStandRig(p)
            r.nearElbow = Kit.pt(-16, -8)
            r.nearHand = Kit.pt(-30, -30)
            r.farElbow = Kit.pt(-8, 14)
            r.farHand = Kit.pt(-22, 8)
        case .sit:
            r = Kit.bodySitRig(p)
            r.nearElbow = Kit.pt(-16, 10)
            r.nearHand = Kit.pt(-34, 2)
            r.openHand = true
            r.farElbow = Kit.pt(-18, 8)
            r.farHand = Kit.pt(-40, -2)
        }
        let rig: Kit.BodyRig = r
        let hand: CGPoint = rigHand(p, rig)
        Art.group(&context, scale: dediScale) { g in
            switch pose {
            case .staff:
                Kit.propShaft(&g, hand.x, 0, hand.x - 2, -186, wood: darkWoodHex, width: 4.6)
            case .cast:
                Kit.propShaft(&g, hand.x + 12, hand.y + 44, hand.x - 30, hand.y - 112, wood: darkWoodHex, width: 4.6)
            case .sit:
                break
            }
            figure(&g, p, rig: rig, look: CGPoint(x: -0.4, y: 0), mouth: mouth, mirrored: mirrored, beads: nil) { h in
                dediHead(&h)
            }
        }
    }
}

// MARK: - The prince and the court

extension KhufuArt {
    /// A papyrus roll lying along x, centred on the origin: pale tan, tied with a cord.
    static func papyrusRoll(_ context: inout GraphicsContext, length: CGFloat, thick: CGFloat) {
        let half: CGFloat = length / 2
        let body: Path = Art.rect(-half, -thick / 2, length, thick, radius: thick / 2)
        Kit.solid(&context, body, Art.color(papyrusHex), light: 0.3, shade: 0.22)
        Art.fill(&context, Art.ellipse(half - thick * 0.3, 0, thick * 0.26, thick * 0.4), Kit.propTone(papyrusHex, 0.78))
        let cordX: CGFloat = -half * 0.1
        Art.stroke(&context, Art.line(cordX, -thick / 2, cordX, thick / 2), Art.color(redHex), width: max(1, thick * 0.16), cap: .butt)
    }

    /// Prince Hordedef, the quiet son, facing LEFT, origin at his feet. Standing, he has a
    /// papyrus roll tucked at his side.
    static func prince(_ context: inout GraphicsContext, pose: Kit.Pose = .stand, mouth: Kit.Mouth = .smile, mirrored: Bool = false) {
        let p = princeLook()
        Kit.person(&context, p, pose: pose, look: CGPoint(x: -0.4, y: 0), mouth: mouth, mirrored: mirrored)
        if pose == .stand {
            Art.group(&context, x: 14, y: -82, rotate: Kit.deg(-26)) { g in
                papyrusRoll(&g, length: 36, thick: 8)
            }
        }
    }

    /// One of the court (see `courtLook`), facing LEFT, origin at the feet.
    static func courtier(_ context: inout GraphicsContext, kind: Int, pose: Kit.Pose = .stand, mouth: Kit.Mouth = .smile, mirrored: Bool = false) {
        Kit.person(&context, courtLook(kind), pose: pose, look: CGPoint(x: -0.4, y: 0), mouth: mouth, mirrored: mirrored)
    }

    /// One of the court with a hand before the mouth: the gasp when the goose gets up.
    static func gasper(_ context: inout GraphicsContext, kind: Int, mirrored: Bool = false) {
        let p = courtLook(kind)
        var r = Kit.bodyStandRig(p)
        r.nearElbow = Kit.pt(-10, 12)
        r.nearHand = Kit.pt(12, -16)
        let skin: Color = Art.color(p.skin)
        let knuckle: Color = Kit.personTone(p.skin, 0.72)
        figure(&context, p, rig: r, look: CGPoint(x: -0.6, y: 0.2), mouth: .oh, mirrored: mirrored, beads: nil) { h in
            Art.fill(&h, Art.circle(-3, 17, 6.2), skin)
            Art.stroke(&h, Art.svg("M-7,15 q4,-2.6 8,0"), knuckle, width: 1)
        }
    }

    /// The head of a long-handled fan of palm leaf, its foot on the origin, standing up.
    static func fanHead(_ context: inout GraphicsContext) {
        let leaf: Path = Art.svg("M-34,2 C-36,-42 36,-42 34,2 Q0,10 -34,2Z")
        Kit.solid(&context, leaf, Art.color(0xCDBE78), light: 0.3, shade: 0.22)
        var ribs = Path()
        for index in 0..<7 {
            let a: CGFloat = Kit.deg(-162 + 24 * CGFloat(index))
            ribs.move(to: CGPoint(x: 0, y: 3))
            ribs.addLine(to: CGPoint(x: cos(a) * 32, y: 2 + sin(a) * 30))
        }
        let spokes: Path = ribs
        Art.clipped(&context, to: leaf) { g in
            Art.stroke(&g, spokes, Art.color(0x9C8E52, 0.8), width: 1.1)
        }
        Art.stroke(&context, Art.svg("M-34,2 C-36,-42 36,-42 34,2"), Art.color(ramp.accent, 0.85), width: 2)
        Art.fill(&context, Art.circle(0, 4, 4.4), Art.color(goldHex))
    }

    /// A fan-bearer: a servant holding a long-handled fan that stands about 250 above the
    /// ground. Faces LEFT, origin at his feet.
    static func fanBearer(_ context: inout GraphicsContext, mirrored: Bool = false) {
        let p = courtLook(0)
        var r = Kit.bodyStandRig(p)
        r.nearElbow = Kit.pt(-10, 10)
        r.nearHand = Kit.pt(-16, 0)
        let hand: CGPoint = rigHand(p, r)
        let topX: CGFloat = hand.x - 22
        Kit.propShaft(&context, hand.x + 5, -44, topX, -224, wood: darkWoodHex, width: 3.4)
        Art.group(&context, x: topX, y: -226, rotate: Kit.deg(-8)) { g in
            fanHead(&g)
        }
        figure(&context, p, rig: r, look: CGPoint(x: -0.4, y: 0), mouth: .flat, mirrored: mirrored, beads: nil) { _ in
        }
    }
}

// MARK: - The goose

extension KhufuArt {
    /// The goose: a white-fronted goose as in the Old Kingdom painting of the geese of Meidum:
    /// grey-brown, barred flanks, a white patch above an orange-pink bill, orange legs. Always
    /// whole and always cross. Side view facing LEFT, feet on the origin, about 86 long and 75
    /// tall. `cackling` opens the bill.
    static func goose(_ context: inout GraphicsContext, cackling: Bool, mirrored: Bool = false) {
        let bodyHex: UInt32 = 0x8C7862
        let billHex: UInt32 = 0xF0906A
        let legs: Path = Art.svg("M-3,-15 L-5,-1 M8,-15 L7,-1 M-5,-1 l-8,0.6 M7,-1 l-8,0.6")
        Art.stroke(&context, legs, Art.color(0xE88A3A), width: 3)
        let body: Path = Art.svg("M-22,-30 C-20,-44 4,-48 22,-40 C30,-37 38,-37 45,-41 C43,-30 34,-22 24,-17 C10,-10 -12,-11 -20,-20 C-23,-24 -23,-27 -22,-30Z")
        Kit.birdSolid(&context, body, Art.color(bodyHex), mirrored: mirrored)
        let bars: Path = Art.svg("M-4,-17 q3,-6 0,-12 M4,-15 q3,-7 0,-14 M12,-15 q3,-7 0,-14 M20,-17 q3,-6 0,-12")
        Art.clipped(&context, to: body) { g in
            Art.fill(&g, Art.ellipse(-14, -26, 11, 11), Art.color(0xA89A84))
            Art.fill(&g, Art.ellipse(35, -24, 13, 7), Art.color(0xF4EFE4))
            Art.stroke(&g, bars, Art.color(0x5E4E40, 0.8), width: 1.6)
        }
        let wing: Path = Art.svg("M-6,-40 C8,-46 26,-43 38,-37 C26,-30 8,-27 -4,-31 C-8,-34 -8,-37 -6,-40Z")
        Kit.birdSolid(&context, wing, Kit.propTone(bodyHex, 0.82), mirrored: mirrored)
        let feathers: Path = Art.svg("M2,-33 C12,-31 24,-33 34,-37 M6,-37 C14,-36 22,-37 30,-39")
        Art.stroke(&context, feathers, Art.color(0xD8CDB8, 0.7), width: 1)
        // The neck, straight up and indignant, and the head.
        Art.stroke(&context, Art.svg("M-15,-30 C-22,-42 -20,-54 -18,-62"), Art.color(bodyHex), width: 10.5)
        Art.fill(&context, Art.circle(-19, -66, 8.6), Kit.propTone(bodyHex, 0.9))
        Art.fill(&context, Art.ellipse(-25.6, -65.5, 3.2, 5), Art.color(0xF8F4EA))
        if cackling {
            Art.fill(&context, Art.svg("M-27,-65.4 L-37,-69 L-36,-60.5Z"), Art.color(0x9A3A30))
            Art.fill(&context, Art.svg("M-26,-70 L-41,-71.5 L-27,-65.4Z"), Art.color(billHex))
            Art.fill(&context, Art.svg("M-26,-62 L-39,-57.5 L-27,-65.4Z"), Kit.propTone(billHex, 0.86))
        } else {
            Art.fill(&context, Art.svg("M-26,-70 L-41,-65.5 L-26,-61.5Z"), Art.color(billHex))
            Art.stroke(&context, Art.line(-27, -65.6, -39, -65.6), Kit.propTone(billHex, 0.7), width: 0.9)
        }
        Kit.personEye(&context, -20, -68.4, 2.3, look: CGPoint(x: -0.6, y: 0), white: false, mirrored: mirrored)
        // One short level brow: cross, and comic.
        Art.stroke(&context, Art.line(-24.5, -72.8, -17.5, -72.2), Art.color(0x4A3C30), width: 1.5)
    }

    /// The folded linen cloth the trick was done behind, lying on the floor at the origin.
    static func linenCloth(_ context: inout GraphicsContext) {
        Kit.shadow(&context, 0, 2, width: 52, alpha: 0.2)
        let cloth: Path = Art.svg("M-25,0 C-21,-8 -8,-10 4,-9 C15,-9 23,-6 25,0 C16,4 -15,4 -25,0Z")
        Kit.solid(&context, cloth, Art.color(linenHex), light: 0.2, shade: 0.24)
        let folds: Path = Art.svg("M-14,-6 C-8,-3 6,-3 16,-6 M-18,-2 C-8,1 8,1 19,-2")
        Art.stroke(&context, folds, Art.color(0xCFC4A8), width: 1.1)
    }
}

// MARK: - The hall

extension KhufuArt {
    /// A slim painted wooden column with a bud top, standing on baseY.
    static func hallColumn(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, width: CGFloat, height: CGFloat) {
        Kit.column(&context, cx: x, baseY: baseY, width: width, height: height, color: 0xEFE3C8, lotus: true)
    }

    /// The floor of the hall from `top` down to the foot of the picture: pale plaster with
    /// joints that open toward the viewer.
    static func hallFloor(_ context: inout GraphicsContext, _ size: CGSize, top: CGFloat) {
        Kit.ground(&context, width: size.width, top: top, bottom: size.height, stops: floorStops(), seed: 41)
        let depth: CGFloat = max(1, size.height - top)
        var joints = Path()
        var t: CGFloat = 0.14
        while t < 1 {
            let y: CGFloat = top + depth * t * t
            joints.move(to: CGPoint(x: 0, y: y))
            joints.addLine(to: CGPoint(x: size.width, y: y))
            t += 0.17
        }
        Art.stroke(&context, joints, Art.color(ramp.shade, 0.13), width: 1.2, cap: .butt)
    }

    /// A reed mat lying on the floor: its far edge at `y`, `width` wide at the near edge.
    static func reedMat(_ context: inout GraphicsContext, cx: CGFloat, y: CGFloat, width w: CGFloat, depth: CGFloat) {
        let shape: Path = Art.polygon([
            CGPoint(x: cx - w * 0.44, y: y), CGPoint(x: cx + w * 0.44, y: y),
            CGPoint(x: cx + w * 0.5, y: y + depth), CGPoint(x: cx - w * 0.5, y: y + depth),
        ])
        Art.fill(&context, shape, Art.color(0xD6BF7C))
        var weave = Path()
        for index in 1..<6 {
            let t: CGFloat = CGFloat(index) / 6
            let wy: CGFloat = y + depth * t
            weave.move(to: CGPoint(x: cx - w * 0.5, y: wy))
            weave.addLine(to: CGPoint(x: cx + w * 0.5, y: wy))
        }
        let rows: Path = weave
        Art.clipped(&context, to: shape) { g in
            Art.stroke(&g, rows, Art.color(0xB09A58, 0.7), width: 1.1, cap: .butt)
            Art.fill(&g, Art.rect(cx - w * 0.5, y, w, depth * 0.14), Art.color(ramp.accent, 0.45))
            Art.fill(&g, Art.rect(cx - w * 0.5, y + depth * 0.86, w, depth * 0.14), Art.color(redHex, 0.45))
        }
        Kit.model(&context, shape, light: 0.16, shade: 0.14)
    }

    /// The painted band along the foot of a plastered wall: `y` is its top edge.
    static func dado(_ context: inout GraphicsContext, x0: CGFloat, x1: CGFloat, y: CGFloat, height: CGFloat) {
        let span: CGFloat = x1 - x0
        Art.fill(&context, Art.rect(x0, y, span, height), Art.color(0xE7D6AE))
        Art.fill(&context, Art.rect(x0, y, span, height * 0.2), Art.color(ramp.accent, 0.55))
        Art.fill(&context, Art.rect(x0, y + height * 0.3, span, height * 0.1), Art.color(redHex, 0.5))
    }

    /// Dedi's daily bread: tall red beer jars with mud stoppers, conical and round loaves and a
    /// bunch of green onions, standing on the origin; about 120 wide and 70 tall.
    static func rations(_ context: inout GraphicsContext) {
        let jars: [(CGFloat, CGFloat)] = [(-44, 66), (-20, 58)]
        for jar in jars {
            Kit.pot(&context, cx: jar.0, baseY: 0, width: jar.1 * 0.46, height: jar.1, color: 0xB5603A)
            let top: CGFloat = -jar.1
            let stopper: Path = Art.svg("M-6,2 C-6,-6 -3,-11 0,-12 C3,-11 6,-6 6,2Z").applying(CGAffineTransform(translationX: jar.0, y: top))
            Kit.solid(&context, stopper, Art.color(0x8E7C62), light: 0.24, shade: 0.2)
        }
        Kit.shadow(&context, 24, 1, width: 70, alpha: 0.2)
        let cone: Path = Art.svg("M2,0 C4,-14 9,-28 13,-34 C17,-28 22,-14 24,0Z")
        Kit.solid(&context, cone, Art.color(0xD9A75E), light: 0.3, shade: 0.24)
        let round: Path = Art.svg("M26,0 C24,-12 34,-18 42,-18 C50,-18 60,-12 58,0Z")
        Kit.solid(&context, round, Art.color(0xCF9A52), light: 0.3, shade: 0.24)
        Art.stroke(&context, Art.svg("M34,-13 l5,5 M42,-15 l5,5"), Art.color(0xA87838), width: 1.2)
        // The onions, lying in front.
        let stalks: Path = Art.svg("M-8,-3 C2,-9 14,-11 26,-9 M-8,-1 C4,-6 16,-7 28,-5 M-8,1 C4,-3 16,-3 27,-1")
        Art.stroke(&context, stalks, Art.color(0x6FA05A), width: 2.2)
        var bulbs = Path()
        bulbs.addPath(Art.ellipse(-10, -3, 3.6, 3))
        bulbs.addPath(Art.ellipse(-11, 0.5, 3.6, 3))
        Art.fill(&context, bulbs, Art.color(0xF6F0E2))
    }
}

// MARK: - The river and its banks

extension KhufuArt {
    /// A low line of flat-topped desert cliffs standing on baseY, about `height` tall.
    static func cliffs(_ context: inout GraphicsContext, width w: CGFloat, baseY: CGFloat, height: CGFloat, color: Color, seed: UInt32) {
        var random = ArtRandom(seed)
        var path = Path()
        path.move(to: CGPoint(x: -10, y: baseY))
        var x: CGFloat = -10
        var top: CGFloat = baseY - height * (0.5 + Kit.rnd(&random) * 0.4)
        path.addLine(to: CGPoint(x: x, y: top))
        while x < w {
            let run: CGFloat = height * (1.4 + Kit.rnd(&random) * 2.6) + 6
            path.addLine(to: CGPoint(x: x + run, y: top + height * 0.04))
            let next: CGFloat = baseY - height * (0.45 + Kit.rnd(&random) * 0.55)
            let slope: CGFloat = abs(next - top) * 0.8 + 4
            let midY: CGFloat = (top + next) / 2
            path.addQuadCurve(to: CGPoint(x: x + run + slope, y: next), control: CGPoint(x: x + run + slope * 0.3, y: midY))
            x += run + slope
            top = next
        }
        path.addLine(to: CGPoint(x: x, y: baseY))
        path.closeSubpath()
        Art.fill(&context, path, color)
        let strataY: CGFloat = baseY - height * 0.32
        Art.clipped(&context, to: path) { g in
            Art.stroke(&g, Art.line(0, strataY, w, strataY), ArtStyle.coolShade.opacity(0.07), width: 1, cap: .butt)
        }
    }

    /// Small far date palms in one flat colour between x0 and x1, standing on baseY.
    static func farPalms(_ context: inout GraphicsContext, x0: CGFloat, x1: CGFloat, baseY: CGFloat, height: CGFloat, count: Int, color: Color, seed: UInt32) {
        var random = ArtRandom(seed)
        var stems = Path()
        var fronds = Path()
        let n: Int = max(1, count)
        let gap: CGFloat = (x1 - x0) / CGFloat(n)
        let dirs: [CGFloat] = [-1, -0.55, 0.1, 0.6, 1]
        for index in 0..<n {
            let px: CGFloat = x0 + gap * (CGFloat(index) + Kit.rnd(&random))
            let ph: CGFloat = height * (0.6 + Kit.rnd(&random) * 0.4)
            let lean: CGFloat = (Kit.rnd(&random) - 0.5) * ph * 0.3
            let tx: CGFloat = px + lean
            let ty: CGFloat = baseY - ph
            stems.move(to: CGPoint(x: px, y: baseY))
            stems.addQuadCurve(to: CGPoint(x: tx, y: ty), control: CGPoint(x: px, y: baseY - ph * 0.6))
            let reach: CGFloat = ph * 0.42
            for d in dirs {
                let ex: CGFloat = tx + d * reach
                let ey: CGFloat = ty + abs(d) * reach * 0.55 - reach * 0.1
                fronds.move(to: CGPoint(x: tx, y: ty))
                fronds.addQuadCurve(to: CGPoint(x: ex, y: ey), control: CGPoint(x: tx + d * reach * 0.6, y: ty - reach * 0.5))
            }
        }
        Art.stroke(&context, stems, color, width: max(0.8, height * 0.07))
        Art.stroke(&context, fronds, color, width: max(0.8, height * 0.09))
    }

    /// The far bank of the Nile along `y`: pale desert cliffs, a thin green strip of fields,
    /// small palms and flat-roofed houses, already hazy. `s` scales it (the stage's `far`).
    static func farBank(_ context: inout GraphicsContext, width w: CGFloat, y: CGFloat, scale s: CGFloat, light: Kit.Light, seed: UInt32) {
        cliffs(&context, width: w, baseY: y, height: 30 * s, color: light.far.opacity(0.6), seed: seed &+ 7)
        cliffs(&context, width: w, baseY: y, height: 17 * s, color: light.far, seed: seed)
        ArtStyle.atmosphere(&context, width: w, top: y - 40 * s, bottom: y, color: light.haze, alpha: 0.3)
        Art.fill(&context, Art.rect(0, y - 5 * s, w, 5 * s + 1), light.near)
        let wall: Color = Art.color(0xE8D5AA)
        let roof: Color = Art.color(0xD6C090)
        let places: [CGFloat] = [0.2, 0.57, 0.86]
        for place in places {
            Kit.farHouse(&context, cx: w * place, baseY: y - 3 * s, width: 20 * s, height: 10 * s, wall: wall, roof: roof, flat: true)
        }
        farPalms(&context, x0: 0, x1: w, baseY: y - 3 * s, height: 17 * s, count: max(3, Int(w / 64)), color: Art.color(0x7C9968), seed: seed &+ 3)
    }

    /// The prince's river boat, as the Old Kingdom built them: a long wooden hull with ends
    /// that curve up, a two-legged mast with one tall narrow sail, a small cabin of matting,
    /// oarsmen resting and steering oars at the stern. Side view, bow to the LEFT, drawn 200
    /// long with the waterline on y 0; the sail stands 150 above the water.
    static func riverBoat(_ context: inout GraphicsContext, rowers: Int) {
        let hullHex: UInt32 = 0x9A6A3C
        Art.fill(&context, Art.ellipse(4, 9, 92, 6), Kit.propTone(hullHex, 0.55).opacity(0.28))
        Kit.propShaft(&context, -16, -12, -3, -150, wood: darkWoodHex, width: 3.2)
        Kit.propShaft(&context, 10, -12, -3, -150, wood: darkWoodHex, width: 3.2)
        var stays = Path()
        stays.move(to: CGPoint(x: -3, y: -150))
        stays.addLine(to: CGPoint(x: 86, y: -32))
        stays.move(to: CGPoint(x: -3, y: -150))
        stays.addLine(to: CGPoint(x: -84, y: -28))
        Art.stroke(&context, stays, Art.color(darkWoodHex, 0.5), width: 1)
        var cloth = Path()
        cloth.move(to: CGPoint(x: -34, y: -142))
        cloth.addLine(to: CGPoint(x: 26, y: -142))
        cloth.addQuadCurve(to: CGPoint(x: 24, y: -44), control: CGPoint(x: 33, y: -92))
        cloth.addQuadCurve(to: CGPoint(x: -32, y: -44), control: CGPoint(x: -4, y: -38))
        cloth.addQuadCurve(to: CGPoint(x: -34, y: -142), control: CGPoint(x: -41, y: -92))
        cloth.closeSubpath()
        let seams: Path = Art.svg("M-14,-142 L-14,-40 M6,-142 L6,-40")
        Kit.propCloth(&context, cloth, seams: seams, sail: 0xF4EAD0, lineWidth: 1)
        Kit.propShaft(&context, -40, -142, 32, -142, wood: darkWoodHex, width: 2.6)
        Kit.propShaft(&context, -37, -44, 29, -44, wood: darkWoodHex, width: 2.2)
        boatCrew(&context, rowers: rowers)
        let hull: Path = Art.svg("M-100,-40 C-78,-18 -45,-10 0,-10 C45,-10 78,-18 100,-44 C94,-14 60,8 0,8 C-60,8 -94,-12 -100,-40Z")
        Kit.solid(&context, hull, Art.color(hullHex), light: 0.24, shade: 0.28, rim: 1.5)
        let planks: Path = Art.svg("M-92,-24 C-62,-3 -30,-1 0,-1 C40,-1 70,-7 93,-27")
        Art.stroke(&context, planks, Kit.propTone(hullHex, 0.68).opacity(0.75), width: 1.2)
        let bindings: Path = Art.svg("M-84,-30 L-80,-12 M-76,-25 L-72,-8 M84,-33 L80,-13 M76,-27 L72,-9")
        Art.stroke(&context, bindings, Kit.propTone(hullHex, 1.5).opacity(0.7), width: 1.3)
        var oars = Path()
        for index in 0..<max(0, rowers) {
            let ox: CGFloat = -62 + 14 * CGFloat(index)
            oars.move(to: CGPoint(x: ox, y: -11))
            oars.addLine(to: CGPoint(x: ox + 10, y: 7))
        }
        Art.stroke(&context, oars, Art.color(darkWoodHex), width: 1.5)
        Kit.propShaft(&context, 72, -42, 97, 9, wood: darkWoodHex, width: 2.6)
        Art.stroke(&context, Art.line(91, -3, 98, 12), Kit.propTone(hullHex, 0.8), width: 5)
        Kit.ripples(&context, 0, 9, 196, count: 2, color: Color.white, opacity: 0.5)
    }

    /// The cabin of matting, the resting oarsmen and the steersman, behind the gunwale.
    static func boatCrew(_ context: inout GraphicsContext, rowers: Int) {
        let cabin: Path = Art.svg("M32,-10 L32,-27 Q49,-35 66,-27 L66,-10Z")
        Kit.solid(&context, cabin, Art.color(0xD9BE7E), light: 0.3, shade: 0.24)
        Art.stroke(&context, Art.svg("M32,-21 L66,-21 M32,-15 L66,-15 M43,-30 L43,-10 M55,-30 L55,-10"), Art.color(0xAE9452, 0.8), width: 0.9)
        let skin: Color = Art.color(skinHex)
        var bodies = Path()
        var hair = Path()
        for index in 0..<max(0, rowers) {
            let x: CGFloat = -62 + 14 * CGFloat(index)
            bodies.addPath(Art.rect(x - 3.4, -25, 6.8, 16, radius: 3))
            bodies.addPath(Art.circle(x - 0.6, -29, 4))
            hair.addPath(Art.ellipse(x, -31.2, 4, 2.6))
        }
        // The steersman stands at the stern.
        bodies.addPath(Art.rect(76, -48, 7, 17, radius: 3))
        bodies.addPath(Art.circle(79, -52.5, 4.2))
        hair.addPath(Art.ellipse(79.6, -54.8, 4.2, 2.7))
        Art.fill(&context, bodies, skin)
        Art.fill(&context, hair, Art.color(wigHex))
        Art.fill(&context, Art.rect(75.6, -34, 8, 10, radius: 2), Art.color(linenHex))
    }

    /// A small flat-roofed mud-brick house standing on baseY, with a dark doorway.
    static func mudHouse(_ context: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, width: CGFloat, height: CGFloat) {
        Kit.house(
            &context, cx: cx, baseY: baseY, width: width, wallHeight: height * 0.9, roofHeight: height * 0.1,
            wall: mudHex, roof: 0xC2A070, style: .flat, door: 0x5A3A2A, windows: 1, lit: false, timber: nil
        )
    }

    /// Dedi's couch of palm sticks: a low bed frame 24 high standing on the origin (its
    /// middle), `length` long, with a headrest end to the right.
    static func couch(_ context: inout GraphicsContext, length: CGFloat) {
        let half: CGFloat = length / 2
        Kit.shadow(&context, 0, 1, width: length * 1.05)
        var legs = Path()
        let places: [CGFloat] = [-half + 5, -half * 0.3, half * 0.3, half - 5]
        for x in places {
            legs.addPath(Art.rect(x - 2.2, -22, 4.4, 22, radius: 1.5))
        }
        Kit.solid(&context, legs, Art.color(0xB08A4E), light: 0.24, shade: 0.24)
        let frame: Path = Art.rect(-half, -25, length, 6, radius: 2.5)
        Kit.solid(&context, frame, Art.color(0xC9A460), light: 0.3, shade: 0.22)
        var sticks = Path()
        var sx: CGFloat = -half + 4
        while sx < half - 2 {
            sticks.move(to: CGPoint(x: sx, y: -24.4))
            sticks.addLine(to: CGPoint(x: sx, y: -19.6))
            sx += 5
        }
        Art.stroke(&context, sticks, Art.color(0x8E6C38, 0.7), width: 0.9, cap: .butt)
        let rest: Path = Art.svg("M0,-25 C2,-38 10,-42 14,-36 L14,-25Z").applying(CGAffineTransform(translationX: half - 14, y: 0))
        Kit.solid(&context, rest, Art.color(0xC9A460), light: 0.3, shade: 0.22)
    }
}

// MARK: - The half-built pyramid

extension KhufuArt {
    /// The great tomb, half done: the lower courses cased in smooth white limestone, rough
    /// steps above, no top; one long straight ramp of rubble and mud brick on its right, and a
    /// paid crew hauling one block up it on a sledge. Origin: the middle of its base; the base
    /// is 200 wide and the work stands 77 high. Nothing else stands near it.
    static func pyramidSite(_ context: inout GraphicsContext) {
        let ramp0: Path = Art.polygon([CGPoint(x: 38, y: -77), CGPoint(x: 280, y: 0), CGPoint(x: 60, y: 0)])
        Art.fill(&context, ramp0, Art.color(0xD2B487))
        Art.stroke(&context, Art.line(40, -76, 279, 0), Art.color(0xF1DFB6, 0.9), width: 1.4)
        // The crew, the rope, the sledge and its block, on the ramp's slope.
        let slope: CGFloat = 77.0 / 242.0
        var crew = Path()
        var kilts = Path()
        for index in 0..<7 {
            let wx: CGFloat = 132 + 7 * CGFloat(index)
            let wy: CGFloat = -(280 - wx) * slope
            crew.addPath(Art.rect(wx - 1, wy - 6.4, 2, 6.4, radius: 0.8))
            kilts.addPath(Art.rect(wx - 1.2, wy - 3.4, 2.4, 2))
        }
        let blockX: CGFloat = 192
        let blockY: CGFloat = -(280 - blockX) * slope
        Art.stroke(&context, Art.line(176, -(280 - 176) * slope - 4, blockX, blockY - 3), Art.color(0x8A6A44, 0.8), width: 0.8)
        Art.fill(&context, crew, Art.color(0x8E5230))
        Art.fill(&context, kilts, Art.color(0xFBF6EA))
        Art.fill(&context, Art.rect(blockX - 1, blockY - 6.5, 9, 5.5), Art.color(0xF6EEDA))
        Art.stroke(&context, Art.line(blockX - 3, blockY - 0.8, blockX + 10, blockY + 3.2), Art.color(0x7A5230), width: 1.2)
        // The cased lower courses.
        let cased: Path = Art.polygon([
            CGPoint(x: -100, y: 0), CGPoint(x: -68.75, y: -40), CGPoint(x: 68.75, y: -40), CGPoint(x: 100, y: 0),
        ])
        Art.fill(&context, cased, Art.color(0xFAF3E0))
        // The rough steps above, to the working level.
        var steps = Path()
        for index in 0..<5 {
            let yb: CGFloat = -40 - 7.4 * CGFloat(index)
            let hw: CGFloat = 100 * (1 + yb / 128) - 3
            steps.addPath(Art.rect(-hw, yb - 7.4, hw * 2, 7.9))
        }
        Art.fill(&context, steps, Art.color(0xE6CD9C))
        var whole = Path()
        whole.addPath(cased)
        whole.addPath(steps)
        let shadeFace: Path = Art.polygon([
            CGPoint(x: 14, y: -80), CGPoint(x: 100, y: -80), CGPoint(x: 100, y: 0), CGPoint(x: 34, y: 0),
        ])
        Art.clipped(&context, to: whole) { g in
            Art.fill(&g, shadeFace, ArtStyle.coolShade.opacity(0.13))
            Art.stroke(&g, Art.svg("M-90,-13 L96,-13 M-80,-27 L88,-27"), Art.color(0xD9CCAE, 0.6), width: 0.7, cap: .butt)
        }
        // A few of the crew on the working level, and one more block waiting.
        var tops = Path()
        let places: [CGFloat] = [-22, -10, 6, 24]
        for x in places {
            tops.addPath(Art.rect(x - 1, -83.4, 2, 6.4, radius: 0.8))
        }
        Art.fill(&context, tops, Art.color(0x8E5230))
        Art.fill(&context, Art.rect(-4, -82, 7, 5), Art.color(0xF6EEDA))
    }
}
