import SwiftUI
import OmramoCore

// The cast and the shared parts of "Iktomi and the Muskrat": palette, the two lights, Iktomi,
// the muskrat, the pot, the horn spoon, the blanket and the stone, and the prairie lake's own
// plants. Cultural care (the spec's artBrief): Iktomi is a man in plain deerskin with two
// braids; no face paint, no feathers, no sacred object, no spider; beadwork is a plain band of
// two colours and copies no real design. No tipi is drawn.

// MARK: - Palette and light

extension IktomiArt {
    static let ramp = ArtStyle.Ramp(deep: 0x23404F, shade: 0x4F7F94, mid: 0xA9B865, light: 0xE3F0F3, glow: 0xF8E3A6, accent: 0xD94F3D)

    static let deerskin: UInt32 = 0xC49A6C
    static let blanketTan: UInt32 = 0xCBA672
    static let stoneGrey: UInt32 = 0x9C9C96
    static let potIron: UInt32 = 0x3A3338
    static let hornDark: UInt32 = 0x3B2A22
    static let muskratFur: UInt32 = 0x5A3D2B
    static let muskratBelly: UInt32 = 0xB48E66
    static let willowBark: UInt32 = 0x8A8478
    static let reedGreen: UInt32 = 0x6E9A52
    static let grassGold: UInt32 = 0x9DB15C

    /// Clear summer daylight: a wide pale blue sky that warms at the horizon.
    static func day() -> Kit.Light {
        let sky: Kit.Stops = [
            (Art.color(0xBFDDEE), 0), (Art.color(0xD8EBF6), 0.45), (Art.color(0xEAF3EE), 0.8), (Art.color(0xF8E3A6), 1),
        ]
        return Kit.Light(sky: sky, sun: 0xFFF6D8, glow: 0xF8E3A6, haze: 0xE6F0EA, far: 0xC9D3A0, mid: 0xB7BF78, near: 0x8FA35A)
    }

    /// Late afternoon: a pale gold sky, never dark.
    static func evening() -> Kit.Light {
        let sky: Kit.Stops = [
            (Art.color(0xE2F0F2), 0), (Art.color(0xF1ECD2), 0.5), (Art.color(0xF7E3B0), 0.85), (Art.color(0xF8DC98), 1),
        ]
        return Kit.Light(sky: sky, sun: 0xFFF1C2, glow: 0xF9DC9A, haze: 0xF3E8C8, far: 0xCDCB96, mid: 0xB5B574, near: 0x8C9A58)
    }

    static func dayWater() -> Kit.Stops {
        [(Art.color(0xD2E6EC), 0), (Art.color(0x9CC6D8), 0.5), (Art.color(0x6FA3B8), 1)]
    }

    static func eveningWater() -> Kit.Stops {
        [(Art.color(0xF0E6C2), 0), (Art.color(0xBFD3C4), 0.45), (Art.color(0x7FA98C), 1)]
    }

    static func willowGreens() -> Kit.Greens {
        Kit.greens(0x3C5A3C, 0x587C46, 0x7C9E52, 0xA6C068, 0xDCE8A0)
    }
}

// MARK: - Iktomi

extension IktomiArt {
    /// Iktomi: warm brown skin, two black braids tied in red, plain fringed deerskin.
    static func iktomiLook() -> Kit.Person {
        Kit.Person(
            age: .adult,
            skin: 0xA8704A,
            hair: 0x241C1E,
            hairStyle: .braids,
            garment: .tunic,
            cloth: deerskin,
            trim: 0xD94F3D,
            legs: 0xA9814F,
            showsEyeWhite: false
        )
    }

    /// The joints of a kit pose for Iktomi, with his own lean (degrees, forward) if given.
    static func iktomiRig(_ pose: Kit.Pose, lean: CGFloat? = nil) -> Kit.BodyRig {
        var r = Kit.bodyRig(iktomiLook(), pose)
        if let lean {
            r.lean = lean
        }
        return r
    }

    /// Bent double and running, one hand on the knot of the sling at his chest.
    static func iktomiRunRig() -> Kit.BodyRig {
        var r = iktomiRig(.walk, lean: 28)
        r.nearElbow = Kit.pt(8, 10)
        r.nearHand = Kit.pt(-2, 13)
        return r
    }

    /// Where the head's centre is for a rig, in Iktomi's own units (origin at his feet).
    static func iktomiHeadCentre(_ r: Kit.BodyRig) -> CGPoint {
        Kit.bodyHeadCentre(Kit.bodyFrame(iktomiLook()), r)
    }

    /// Iktomi in any rig. Origin at the ground between his feet, facing LEFT, 168 tall when he
    /// stands. `load` puts the stone in its blanket on his back, the sling knotted on his chest.
    /// `headTurn` turns the head further (radians; positive tips it back when he faces left).
    static func iktomi(
        _ context: inout GraphicsContext,
        rig r: Kit.BodyRig,
        look: CGPoint = .zero,
        mouth: Kit.Mouth = .smile,
        headTurn: CGFloat = 0,
        load: Bool = false,
        mirrored: Bool = false
    ) {
        let p = iktomiLook()
        if load {
            Art.group(&context, x: 21, y: -104) { g in
                stoneBundle(&g)
            }
        }
        Kit.bodyFigure(&context, p, r, mirrored: mirrored)
        iktomiDress(&context, r)
        if load {
            let knot = CGPoint(x: -30, y: -84)
            let sling: Path = Art.svg("M-2,-126 Q-22,-112 -30,-84 M6,-80 Q-12,-76 -30,-84")
            Art.stroke(&context, sling, Art.color(blanketTan), width: 7)
            Art.stroke(&context, sling, Kit.personTone(blanketTan, 0.74), width: 1.2)
            Art.fill(&context, Art.ellipse(knot.x, knot.y, 6.5, 5.5), Kit.personTone(blanketTan, 0.9))
            Art.stroke(&context, Art.svg("M-33,-80 L-38,-70 M-28,-79 L-27,-69"), Art.color(blanketTan), width: 3.4)
            Kit.bodyHand(&context, CGPoint(x: knot.x - 2, y: knot.y + 2), 5.5, Art.color(p.skin), open: false)
        }
        let c = iktomiHeadCentre(r)
        let tilt: CGFloat = -Kit.deg(r.lean) * 0.45 + headTurn
        Art.group(&context, x: c.x, y: c.y, rotate: tilt) { g in
            Kit.personHead(&g, p, look: look, mouth: mouth, closedEyes: false, mirrored: mirrored)
        }
    }

    /// What the kit's tunic lacks: a plain two-colour bead band on the belt, soft fringes at
    /// the hem and down the leggings, a plain bead band on each moccasin.
    static func iktomiDress(_ context: inout GraphicsContext, _ r: Kit.BodyRig) {
        let fringe: Color = Kit.personTone(deerskin, 0.76)
        let beadPale: Color = Art.color(0xF4EBDC)
        let beadBlue: Color = Art.color(0x4F7F94)
        Art.group(&context, x: r.hip.x, y: r.hip.y, rotate: -Kit.deg(r.lean)) { g in
            let band: Path = Art.line(-5, -10, 19.5, -10)
            Art.stroke(&g, band, beadPale, width: 4.6, cap: .butt)
            Art.stroke(&g, band, beadBlue, width: 4.6, cap: .butt, dash: [3.5, 3.5])
        }
        let edges = Kit.bodySkirtEdges(r, length: 1.0, flare: 1.15)
        if let a = edges.0.last, let b = edges.1.last {
            var strands = Path()
            for i in 0...8 {
                let t: CGFloat = CGFloat(i) / 8
                let sx: CGFloat = Kit.mix(a.x, b.x, t)
                let sy: CGFloat = Kit.mix(a.y, b.y, t)
                strands.move(to: CGPoint(x: sx, y: sy))
                strands.addLine(to: CGPoint(x: sx + 1.2, y: sy + 7.5))
            }
            Art.stroke(&context, strands, fringe, width: 1.4)
        }
        var legFringe = Path()
        for i in 1...5 {
            let t: CGFloat = CGFloat(i) / 6
            let q = Kit.bodyMix(r.nearKnee, r.nearFoot, t)
            legFringe.move(to: CGPoint(x: q.x + 4, y: q.y))
            legFringe.addLine(to: CGPoint(x: q.x + 11, y: q.y + 3))
        }
        Art.stroke(&context, legFringe, fringe, width: 1.3)
        if !r.feetBack {
            var beads = Path()
            beads.move(to: CGPoint(x: r.nearFoot.x - 8, y: r.nearFoot.y - 2.5))
            beads.addLine(to: CGPoint(x: r.nearFoot.x - 1, y: r.nearFoot.y - 4.5))
            beads.move(to: CGPoint(x: r.farFoot.x - 8, y: r.farFoot.y - 2.5))
            beads.addLine(to: CGPoint(x: r.farFoot.x - 1, y: r.farFoot.y - 4.5))
            Art.stroke(&context, beads, beadPale, width: 2.4, cap: .butt)
            Art.stroke(&context, beads, beadBlue, width: 2.4, cap: .butt, dash: [1.6, 1.6])
        }
    }

    /// The big grey stone tied in the blanket: origin at its centre, about 64 across.
    static func stoneBundle(_ g: inout GraphicsContext) {
        let stone: Path = Art.svg("M-22,-18 C-14,-30 10,-32 22,-20 C31,-10 31,10 22,22 C12,31 -12,31 -22,22 C-31,10 -30,-8 -22,-18Z")
        Kit.solid(&g, stone, Art.color(stoneGrey), light: 0.3, shade: 0.28, rim: 2)
        Art.stroke(&g, Art.svg("M-6,-26 L-2,-18 L-8,-12 M10,-27 L13,-20"), Kit.personTone(stoneGrey, 0.7).opacity(0.7), width: 1.3)
        let wrap: Path = Art.svg("M-30,-6 C-22,-2 -8,-14 4,-12 C14,-10 24,-16 31,-8 C34,8 28,26 14,32 C2,36 -14,35 -24,28 C-32,20 -34,6 -30,-6Z")
        Kit.solid(&g, wrap, Art.color(blanketTan), light: 0.26, shade: 0.26, rim: 1.6)
        let stripes: Path = Art.svg("M-34,15 C-14,26 12,26 33,13")
        let thin: Path = Art.svg("M-33,22 C-14,32 12,32 31,20")
        let folds: Path = Art.svg("M-18,-2 C-14,8 -14,18 -18,28 M2,-10 C6,2 6,16 2,30 M20,-10 C22,0 22,12 18,24")
        Art.clipped(&g, to: wrap) { c in
            Art.stroke(&c, folds, Kit.personTone(blanketTan, 0.78), width: 1.4)
            Art.stroke(&c, stripes, Art.color(0xD94F3D), width: 4, cap: .butt)
            Art.stroke(&c, thin, Art.color(0xD94F3D), width: 1.6, cap: .butt)
        }
    }

    /// The stone where it fell, with the blanket in a heap beside it. Origin on the ground.
    static func droppedStone(_ g: inout GraphicsContext) {
        Kit.rock(&g, cx: 0, baseY: 0, width: 58, height: 40, color: stoneGrey, seed: 5)
        Kit.shadow(&g, 44, 2, width: 60, alpha: 0.2)
        let heap: Path = Art.svg("M20,2 C22,-8 30,-16 40,-12 C46,-20 58,-16 60,-8 C68,-8 74,-2 74,2Z")
        Kit.solid(&g, heap, Art.color(blanketTan), light: 0.26, shade: 0.24, rim: 1.4)
        Art.clipped(&g, to: heap) { c in
            Art.stroke(&c, Art.svg("M32,-10 C36,-4 36,0 34,3 M50,-13 C52,-6 52,-2 50,3"), Kit.personTone(blanketTan, 0.78), width: 1.3)
            Art.stroke(&c, Art.svg("M56,-14 C64,-10 70,-4 74,0"), Art.color(0xD94F3D), width: 3.4, cap: .butt)
        }
    }
}

// MARK: - The pot, the spoon, the fire

extension IktomiArt {
    /// The plain dark cooking pot with its wire handle: origin on the ground under its middle,
    /// about 52 wide and 34 tall (the handle rises to about 50). `fish` shows the boiled fish.
    static func pot(_ g: inout GraphicsContext, fish: Bool = true, handle: Bool = true) {
        if handle {
            Art.stroke(&g, Art.svg("M-18,-28 C-16,-52 16,-52 18,-28"), Art.color(0x5A545E), width: 1.8)
        }
        let body: Path = Art.svg("M-17,-28 C-28,-22 -28,-4 -16,0 L16,0 C28,-4 28,-22 17,-28Z")
        Kit.solid(&g, body, Art.color(potIron), light: 0.32, shade: 0.24, rim: 1.6)
        Art.fill(&g, Art.ellipse(0, -28, 18, 5), Art.color(0x262026))
        if fish {
            Art.fill(&g, Art.ellipse(0, -27.5, 15, 3.6), Art.color(0xCDBB8E))
            let one: Path = Art.svg("M-13,-28 C-11,-37 1,-39 7,-32 L12,-37 L11,-27 C5,-26 -7,-26 -13,-28Z")
            let two: Path = Art.svg("M-2,-28 C0,-34 9,-35 13,-30 C10,-27 3,-26 -2,-28Z")
            Art.fill(&g, two, Art.color(0xB9C0B4))
            Kit.solid(&g, one, Art.color(0xD9DDD2), light: 0.2, shade: 0.18)
            Art.fill(&g, Art.circle(-8, -31.5, 1.1), Art.color(0x2E2A2C))
            Art.stroke(&g, Art.svg("M-3,-35 L-2,-29 M1,-36 L2,-29"), Art.color(0x9AA39A, 0.7), width: 0.8)
        }
        Art.stroke(&g, Art.svg("M-18,-28 C-12,-22.5 12,-22.5 18,-28"), Kit.personTone(potIron, 1.7), width: 1.6)
    }

    /// Two soft threads of steam rising from (x, y).
    static func steam(_ g: inout GraphicsContext, x: CGFloat, y: CGFloat, height h: CGFloat) {
        var wisps = Path()
        wisps.move(to: CGPoint(x: x - 5, y: y))
        wisps.addCurve(to: CGPoint(x: x - 7, y: y - h), control1: CGPoint(x: x - 12, y: y - h * 0.35), control2: CGPoint(x: x + 2, y: y - h * 0.65))
        wisps.move(to: CGPoint(x: x + 5, y: y - 2))
        wisps.addCurve(to: CGPoint(x: x + 8, y: y - h * 0.8), control1: CGPoint(x: x + 12, y: y - h * 0.3), control2: CGPoint(x: x, y: y - h * 0.55))
        Art.stroke(&g, wisps, Color.white.opacity(0.6), width: 2.2)
    }

    /// The dark horn spoon with its curved handle: origin at the grip, the bowl up and to the left.
    static func spoon(_ g: inout GraphicsContext) {
        Art.stroke(&g, Art.svg("M1,5 C3,-8 -1,-18 -7,-24"), Art.color(hornDark), width: 3.2)
        Art.fill(&g, Art.ellipse(-9.5, -29, 5.6, 7.2), Art.color(hornDark))
        Art.fill(&g, Art.ellipse(-11, -31, 2, 3), Art.color(0x8A6A52, 0.75))
    }

    /// The fire burnt out: a low heap of grey ash and three charred sticks. Origin on the ground.
    static func ashes(_ g: inout GraphicsContext) {
        Kit.shadow(&g, 0, 1, width: 56, alpha: 0.16)
        Art.stroke(&g, Art.svg("M-26,-3 L20,-9 M-18,-10 L24,-2 M-4,-12 L6,0"), Art.color(0x3E3230), width: 4.4)
        let heap: Path = Art.svg("M-20,1 C-16,-9 -6,-12 2,-10 C12,-12 18,-6 20,1Z")
        Kit.solid(&g, heap, Art.color(0xA9A59D), light: 0.24, shade: 0.2)
        Art.stipple(&g, in: CGRect(x: -16, y: -9, width: 32, height: 9), count: 22, seed: 4, color: Color.white, alpha: 0.5, size: 0.5...1.1)
    }

    /// One small fish bone: origin at its middle, about 16 long.
    static func fishBone(_ g: inout GraphicsContext) {
        let bone: Path = Art.svg("M-8,0 L8,0 M-5,-3 L-3,3 M-1,-3.4 L1,3.4 M3,-3 L5,3 M8,0 L11,-3 M8,0 L11,3")
        Art.stroke(&g, bone, Art.color(0xF6F1E4), width: 1.5)
    }
}

// MARK: - The muskrat

extension IktomiArt {
    /// Water drops on fur and whiskers: the muskrat's signature.
    static func muskratDrops(_ g: inout GraphicsContext, _ places: [(CGFloat, CGFloat)]) {
        var drops = Path()
        var glints = Path()
        for place in places {
            drops.addEllipse(in: CGRect(x: place.0 - 1.5, y: place.1 - 1.9, width: 3, height: 3.8))
            glints.addEllipse(in: CGRect(x: place.0 - 1, y: place.1 - 1.4, width: 1, height: 1))
        }
        Art.fill(&g, drops, Art.color(0xBFE3F0, 0.95))
        Art.fill(&g, glints, Color.white)
    }

    /// The muskrat's face from the front: origin at the head's centre, the head 60 across.
    static func muskratFace(_ g: inout GraphicsContext, laugh: Bool = false, look: CGPoint = .zero, mirrored: Bool = false) {
        var ears = Path()
        ears.addPath(Art.circle(-21, -21, 7))
        ears.addPath(Art.circle(21, -21, 7))
        Art.fill(&g, ears, Kit.personTone(muskratFur, 0.8))
        var inner = Path()
        inner.addPath(Art.circle(-21, -20, 3.6))
        inner.addPath(Art.circle(21, -20, 3.6))
        Art.fill(&g, inner, Art.color(0x9A6F5A))
        let head: Path = Art.svg("M0,-28 C18,-28 30,-15 30,1 C30,17 18,27 0,27 C-18,27 -30,17 -30,1 C-30,-15 -18,-28 0,-28Z")
        let box = CGRect(x: -30, y: -28, width: 60, height: 55)
        Kit.personLit(&g, head, Art.color(muskratFur), bounds: box, mirrored: mirrored, light: 0.3, shade: 0.24)
        Art.clipped(&g, to: head) { c in
            Art.fill(&c, Art.ellipse(0, 14, 17, 13), Art.color(muskratBelly, 0.85))
        }
        Kit.personEye(&g, -12.5, -4, 3.6, look: look, white: false, mirrored: mirrored)
        Kit.personEye(&g, 12.5, -4, 3.6, look: look, white: false, mirrored: mirrored)
        Art.fill(&g, Art.ellipse(0, 5.5, 5.2, 3.8), Art.color(0x2E1F1E))
        Art.fill(&g, Art.ellipse(-1.4, 4.4, 1.6, 1), Color.white.opacity(0.55))
        ArtStyle.cheek(&g, -19, 9, 6, alpha: 0.26)
        ArtStyle.cheek(&g, 19, 9, 6, alpha: 0.26)
        if laugh {
            let open: Path = Art.svg("M-7,12 C-3,14 3,14 7,12 C6,20 3,23 0,23 C-3,23 -6,20 -7,12Z")
            Art.fill(&g, open, Art.color(0x7A2E24))
            Art.fill(&g, Art.ellipse(0, 21, 3, 1.8), Art.color(0xE8776A))
        } else {
            let lips: Path = Art.svg("M0,9.5 L0,12.5 M-6,12 Q-3,15.5 0,12.5 Q3,15.5 6,12")
            Art.stroke(&g, lips, Art.color(0x3A2620), width: 1.5)
        }
        let whiskers: Path = Art.svg("M-13,9 L-40,3 M-13,12 L-41,13 M-12,15 L-38,23 M13,9 L40,3 M13,12 L41,13 M12,15 L38,23")
        Art.stroke(&g, whiskers, Art.color(0x4A342A, 0.7), width: 1)
        let wet: [(CGFloat, CGFloat)] = [(-40, 5), (41, 15), (-38, 25), (-13, -21), (9, -23)]
        muskratDrops(&g, wet)
    }

    /// The muskrat's head turned three-quarters LEFT: origin at its centre, about 48 across.
    static func muskratHead(_ g: inout GraphicsContext, laugh: Bool, look: CGPoint, mirrored: Bool) {
        var ears = Path()
        ears.addPath(Art.circle(-7, -17, 5))
        ears.addPath(Art.circle(14, -15, 5.5))
        Art.fill(&g, ears, Kit.personTone(muskratFur, 0.8))
        Art.fill(&g, Art.circle(14, -14.5, 2.8), Art.color(0x9A6F5A))
        let head: Path = Art.svg("M3,-20 C15,-20 22,-11 22,0 C22,12 13,19 1,19 C-8,19 -16,17 -22,12 C-27,9 -27,3 -22,0 C-19,-11 -10,-20 3,-20Z")
        let box = CGRect(x: -27, y: -20, width: 49, height: 39)
        Kit.personLit(&g, head, Art.color(muskratFur), bounds: box, mirrored: mirrored, light: 0.3, shade: 0.24)
        Art.clipped(&g, to: head) { c in
            Art.fill(&c, Art.ellipse(-15, 10, 11, 7.5), Art.color(muskratBelly, 0.85))
        }
        Kit.personEye(&g, -9, -3, 2.7, look: look, white: false, mirrored: mirrored)
        Kit.personEye(&g, 6, -4.5, 3, look: look, white: false, mirrored: mirrored)
        Art.fill(&g, Art.ellipse(-24.5, 5, 3.2, 2.8), Art.color(0x2E1F1E))
        ArtStyle.cheek(&g, -3, 8, 5, alpha: 0.24)
        if laugh {
            let open: Path = Art.svg("M-21,10 C-17,12 -12,12 -8,10 C-9,16 -12,18.5 -15,18.5 C-18,18.5 -20.5,15 -21,10Z")
            Art.fill(&g, open, Art.color(0x7A2E24))
        } else {
            Art.stroke(&g, Art.svg("M-21,11 Q-15,15.5 -9,11"), Art.color(0x3A2620), width: 1.4)
        }
        let whiskers: Path = Art.svg("M-17,8 L-40,2 M-17,10.5 L-41,11 M-16,13 L-38,20 M-9,10 L8,17 M-9,8 L10,11")
        Art.stroke(&g, whiskers, Art.color(0x4A342A, 0.7), width: 0.9)
        let wet: [(CGFloat, CGFloat)] = [(-40, 4), (-38, 22), (8, 19), (-2, -15)]
        muskratDrops(&g, wet)
    }

    /// The muskrat sitting up like a polite visitor: origin on the ground under him, about 80
    /// tall, turned three-quarters LEFT (or facing the reader with `front`). No clothes.
    static func muskrat(
        _ g: inout GraphicsContext,
        front: Bool = false,
        laugh: Bool = false,
        look: CGPoint = .zero,
        paws: Bool = true,
        mirrored: Bool = false
    ) {
        Art.stroke(&g, Art.svg("M18,-5 C34,2 50,-1 64,-8"), Art.color(0x4A3A36), width: 3.6)
        var feet = Path()
        feet.addPath(Art.ellipse(-13, 0, 8, 3.6))
        feet.addPath(Art.ellipse(9, 0.5, 8, 3.6))
        Art.fill(&g, feet, Art.color(0x3C2A24))
        let body: Path = Art.svg("M-2,-52 C14,-52 27,-34 27,-15 C27,-3 16,1 0,1 C-16,1 -27,-3 -27,-15 C-27,-34 -18,-52 -2,-52Z")
        let box = CGRect(x: -27, y: -52, width: 54, height: 53)
        Kit.personLit(&g, body, Art.color(muskratFur), bounds: box, mirrored: mirrored, light: 0.28, shade: 0.26)
        let bellyX: CGFloat = front ? 0 : -7
        Art.clipped(&g, to: body) { c in
            Art.fill(&c, Art.ellipse(bellyX, -17, 14, 21), Art.color(muskratBelly, 0.9))
        }
        if paws {
            let px: CGFloat = front ? 0 : -12
            var arms = Path()
            arms.move(to: CGPoint(x: px - 12, y: -38))
            arms.addQuadCurve(to: CGPoint(x: px - 2.5, y: -27), control: CGPoint(x: px - 12, y: -28))
            arms.move(to: CGPoint(x: px + 12, y: -38))
            arms.addQuadCurve(to: CGPoint(x: px + 2.5, y: -27), control: CGPoint(x: px + 12, y: -28))
            Art.stroke(&g, arms, Kit.personTone(muskratFur, 0.82), width: 5.5)
            var hands = Path()
            hands.addPath(Art.circle(px - 2.6, -27, 3.2))
            hands.addPath(Art.circle(px + 2.6, -27, 3.2))
            Art.fill(&g, hands, Art.color(0x8E6652))
        }
        let wet: [(CGFloat, CGFloat)] = [(16, -30), (-20, -12), (20, -10)]
        muskratDrops(&g, wet)
        if front {
            Art.group(&g, x: 0, y: -62, scale: 0.7) { h in
                muskratFace(&h, laugh: laugh, look: look, mirrored: mirrored)
            }
        } else {
            Art.group(&g, x: -5, y: -60) { h in
                muskratHead(&h, laugh: laugh, look: look, mirrored: mirrored)
            }
        }
    }

    /// The muskrat swimming to the LEFT, seen from the side: only nose, eyes, whiskers and the
    /// line of his back above the water. Origin on the waterline under his head; 106 long.
    static func muskratSwim(_ g: inout GraphicsContext, mirrored: Bool = false) {
        let fur: Color = Art.color(muskratFur)
        let above: Path = Art.rect(-80, -60, 220, 60)
        Art.clipped(&g, to: above) { c in
            let back: Path = Art.svg("M18,4 C30,-9 58,-10 78,4Z")
            Kit.personLit(&c, back, fur, bounds: CGRect(x: 18, y: -8, width: 60, height: 12), mirrored: mirrored, light: 0.3, shade: 0.2)
            Art.fill(&c, Art.circle(9, -15, 4.2), Kit.personTone(muskratFur, 0.8))
            let head: Path = Art.svg("M-28,2 C-28,-4 -22,-8 -14,-11 C-6,-17 8,-18 15,-10 C19,-5 20,0 19,6 L-26,6Z")
            Kit.personLit(&c, head, fur, bounds: CGRect(x: -28, y: -18, width: 48, height: 24), mirrored: mirrored, light: 0.3, shade: 0.2)
            Art.clipped(&c, to: head) { m in
                Art.fill(&m, Art.ellipse(-19, 1, 9, 4.5), Art.color(muskratBelly, 0.75))
            }
            Kit.personEye(&c, -6, -8.5, 2.6, look: .zero, white: false, mirrored: mirrored)
            Art.fill(&c, Art.ellipse(-27.5, -2.5, 2.8, 2.4), Art.color(0x2E1F1E))
            Art.stroke(&c, Art.svg("M-21,-2 L-40,-9 M-21,-1 L-42,-3"), Art.color(0x4A342A, 0.7), width: 0.9)
        }
        Art.stroke(&g, Art.line(-34, 1, 22, 1), Color.white.opacity(0.75), width: 1.4)
        Art.stroke(&g, Art.line(16, 1.6, 82, 1.6), Color.white.opacity(0.5), width: 1.2)
    }

    /// The long clean V of ripples behind a swimmer at (x, y) heading LEFT: `length` back,
    /// opening by `spread` toward the viewer.
    static func wake(_ g: inout GraphicsContext, x: CGFloat, y: CGFloat, length: CGFloat, spread: CGFloat) {
        var outer = Path()
        outer.move(to: CGPoint(x: x, y: y))
        outer.addQuadCurve(to: CGPoint(x: x + length, y: y - spread * 0.3), control: CGPoint(x: x + length * 0.5, y: y - spread * 0.06))
        outer.move(to: CGPoint(x: x, y: y))
        outer.addQuadCurve(to: CGPoint(x: x + length * 0.92, y: y + spread), control: CGPoint(x: x + length * 0.45, y: y + spread * 0.3))
        Art.stroke(&g, outer, Color.white.opacity(0.8), width: 2)
        var inner = Path()
        inner.move(to: CGPoint(x: x + length * 0.2, y: y + spread * 0.04))
        inner.addQuadCurve(to: CGPoint(x: x + length * 0.9, y: y + spread * 0.05), control: CGPoint(x: x + length * 0.55, y: y + spread * 0.1))
        inner.move(to: CGPoint(x: x + length * 0.3, y: y + spread * 0.2))
        inner.addQuadCurve(to: CGPoint(x: x + length * 0.86, y: y + spread * 0.55), control: CGPoint(x: x + length * 0.6, y: y + spread * 0.32))
        Art.stroke(&g, inner, Color.white.opacity(0.4), width: 1.4)
        Art.stroke(&g, outer, ramp.shadeColor.opacity(0.18), width: 0.8)
    }
}

// MARK: - The prairie and the lake

extension IktomiArt {
    /// The far plane: a level horizon of open grass, three thin bands paling into the air.
    static func farPrairie(_ context: inout GraphicsContext, width w: CGFloat, horizon H: CGFloat, scale s: CGFloat, light: Kit.Light, seed: UInt32) {
        let farthest: Path = Kit.ridge(width: w, y: H - 13 * s, amp: 4 * s, seed: seed &+ 19, bottom: H + 6, step: 12)
        Art.fill(&context, farthest, light.far.opacity(0.7))
        let far: Path = Kit.ridge(width: w, y: H - 7 * s, amp: 3 * s, seed: seed, bottom: H + 6, step: 10)
        Art.fill(&context, far, light.far)
        ArtStyle.atmosphere(&context, width: w, top: H - 30 * s, bottom: H + 6, color: light.haze, alpha: 0.3)
        let near: Path = Kit.ridge(width: w, y: H - 3 * s, amp: 1.6 * s, seed: seed &+ 5, bottom: H + 6, step: 10)
        Art.fill(&context, near, light.mid)
    }

    /// A tall white summer cloud: three of the kit's clouds heaped up; (x, y) is its base.
    static func cumulus(_ context: inout GraphicsContext, _ x: CGFloat, _ y: CGFloat, scale s: CGFloat) {
        let white: Color = Art.color(0xFFFFFF, 0.92)
        Kit.cloud(&context, x - 34 * s, y - 20 * s, scale: s * 0.8, color: white)
        Kit.cloud(&context, x + 30 * s, y - 26 * s, scale: s * 0.9, color: white)
        Kit.cloud(&context, x, y, scale: s * 1.5, color: white)
    }

    /// The thin thread of smoke from the far fire, rising `height` from (x, baseY).
    static func smoke(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, height h: CGFloat) {
        var thread = Path()
        thread.move(to: CGPoint(x: x, y: baseY))
        thread.addCurve(
            to: CGPoint(x: x + h * 0.16, y: baseY - h),
            control1: CGPoint(x: x - h * 0.1, y: baseY - h * 0.4),
            control2: CGPoint(x: x + h * 0.14, y: baseY - h * 0.6)
        )
        Art.stroke(&context, thread, Art.color(0xAEB9BC, 0.55), width: max(1.4, h * 0.05))
        Art.stroke(&context, thread, Color.white.opacity(0.6), width: max(0.8, h * 0.022))
    }

    /// Wild rice: thin stems with feathery straw-coloured seed heads, standing at (x, baseY).
    static func wildRice(_ g: inout GraphicsContext, x: CGFloat, baseY: CGFloat, count: Int, height: CGFloat, seed: UInt32) {
        var random = ArtRandom(seed)
        var stems = Path()
        var leaves = Path()
        var heads = Path()
        let n: Int = max(0, count)
        for index in 0..<n {
            let offset: CGFloat = CGFloat(index) - CGFloat(n - 1) / 2
            let jitter: CGFloat = (Kit.rnd(&random) - 0.5) * height * 0.05
            let sx: CGFloat = x + offset * height * 0.09 + jitter
            let rise: CGFloat = height * (0.7 + Kit.rnd(&random) * 0.3)
            let lean: CGFloat = (Kit.rnd(&random) - 0.5) * height * 0.2
            let top = CGPoint(x: sx + lean, y: baseY - rise)
            stems.move(to: CGPoint(x: sx, y: baseY))
            stems.addQuadCurve(to: top, control: CGPoint(x: sx, y: baseY - rise * 0.6))
            let blade: CGFloat = max(1.6, height * 0.03)
            Kit.groundBlade(&leaves, x: sx, baseY: baseY, width: blade, length: rise * 0.55, lean: -lean - height * 0.08)
            for k in 0..<5 {
                let t: CGFloat = CGFloat(k) / 5
                let hy: CGFloat = top.y + rise * 0.24 * t
                let hx: CGFloat = top.x - lean * 0.24 * t
                let side: CGFloat = k % 2 == 0 ? 1 : -1
                let reach: CGFloat = height * 0.05 * (0.5 + t)
                heads.move(to: CGPoint(x: hx, y: hy))
                heads.addLine(to: CGPoint(x: hx + side * reach, y: hy - reach * 0.9))
            }
        }
        Art.fill(&g, leaves, Kit.groundTone(reedGreen, 0.85))
        Art.stroke(&g, stems, Kit.groundTone(reedGreen, 1.05), width: max(1, height * 0.012))
        Art.stroke(&g, heads, Art.color(0xC4A85E), width: max(1, height * 0.016))
    }

    /// The near bank on the trailing side, drawn inside `nearSpace`: grass sloping down to a
    /// muddy edge at the water. Its top is at `Hv + 30` on the trailing edge and `Hv + 78` at
    /// its leading end (x 470 + `shift`).
    static func bank(_ g: inout GraphicsContext, Hv: CGFloat, shift: CGFloat = 0, evening: Bool = false) {
        let top: CGFloat = Hv + 30
        var shape = Path()
        shape.move(to: CGPoint(x: 900, y: top))
        shape.addCurve(
            to: CGPoint(x: 470 + shift, y: Hv + 78),
            control1: CGPoint(x: 760, y: top - 4),
            control2: CGPoint(x: 560 + shift, y: Hv + 44)
        )
        shape.addCurve(
            to: CGPoint(x: 300 + shift, y: Hv + 420),
            control1: CGPoint(x: 410 + shift, y: Hv + 120),
            control2: CGPoint(x: 350 + shift, y: Hv + 240)
        )
        shape.addLine(to: CGPoint(x: 900, y: Hv + 420))
        shape.closeSubpath()
        let mud: Path = shape.applying(CGAffineTransform(translationX: -13, y: 3))
        Art.fill(&g, mud.applying(CGAffineTransform(translationX: -8, y: 3)), Color.white.opacity(0.35))
        Art.fill(&g, mud, Art.color(0x9A8660))
        let grass: Kit.Stops = [(Art.color(0xBAC670), 0), (Art.color(0x9DB15C), 0.45), (Art.color(0x7C9650), 1)]
        Art.fillLinear(&g, shape, grass, from: CGPoint(x: 0, y: top), to: CGPoint(x: 0, y: top + 260))
        let box = CGRect(x: 300 + shift, y: top - 4, width: 600 - shift, height: 300)
        ArtStyle.form(&g, shape, bounds: box, light: 0.16, shade: 0.14)
        if evening {
            Art.fill(&g, shape, Art.color(0xF9DC9A, 0.14))
        }
        Art.clipped(&g, to: shape) { c in
            ArtStyle.tooth(&c, in: CGRect(x: 420, y: top, width: 480, height: 260), seed: 61, alpha: 0.07)
            Kit.grass(&c, in: CGRect(x: 470, y: Hv + 52, width: 430, height: 100), count: 80, seed: 3, color: Art.color(0x6E8C48), height: 9)
            Kit.grass(&c, in: CGRect(x: 470, y: Hv + 56, width: 430, height: 100), count: 50, seed: 9, color: Art.color(0xD6DC8C), height: 7)
            Kit.grass(&c, in: CGRect(x: 400, y: Hv + 150, width: 500, height: 130), count: 70, seed: 13, color: Art.color(0x5F7E44), height: 13)
            Kit.grass(&c, in: CGRect(x: 400, y: Hv + 150, width: 500, height: 130), count: 40, seed: 17, color: Art.color(0xCBD384), height: 10)
        }
    }

    /// What fills the deep bank of a tall window: flowers, stones and tufts lower down.
    static func bankFill(_ g: inout GraphicsContext, Hv: CGFloat) {
        Kit.flowers(&g, in: CGRect(x: 520, y: Hv + 160, width: 300, height: 80), count: 9, seed: 5, petal: 0xF4E9B8)
        Kit.flowers(&g, in: CGRect(x: 480, y: Hv + 176, width: 360, height: 70), count: 6, seed: 8, petal: 0xC9A0D0)
        Kit.pebbles(&g, in: CGRect(x: 470, y: Hv + 170, width: 330, height: 70), count: 7, seed: 12)
        Kit.grassTuft(&g, x: 560, baseY: Hv + 214, height: 44, color: 0x7E9A50, seed: 4)
        Kit.grassTuft(&g, x: 742, baseY: Hv + 236, height: 52, color: 0x6F8E4A, seed: 6)
        Kit.grassTuft(&g, x: 468, baseY: Hv + 250, height: 40, color: 0x86A256, seed: 9)
    }

    /// The muskrat's lodge: a round dome of heaped cattails, reeds and mud standing in the
    /// water at (cx, waterY), `width` across. No door shows.
    static func lodge(_ g: inout GraphicsContext, cx: CGFloat, waterY: CGFloat, width w: CGFloat, seed: UInt32 = 3) {
        let half: CGFloat = w / 2
        let rise: CGFloat = w * 0.5
        Art.fill(&g, Art.ellipse(cx + w * 0.03, waterY + rise * 0.16, half * 1.02, rise * 0.2), ramp.deepColor.opacity(0.22))
        var dome = Path()
        dome.move(to: CGPoint(x: cx - half, y: waterY))
        dome.addCurve(
            to: CGPoint(x: cx, y: waterY - rise),
            control1: CGPoint(x: cx - half * 0.92, y: waterY - rise * 0.62),
            control2: CGPoint(x: cx - half * 0.5, y: waterY - rise)
        )
        dome.addCurve(
            to: CGPoint(x: cx + half, y: waterY),
            control1: CGPoint(x: cx + half * 0.55, y: waterY - rise),
            control2: CGPoint(x: cx + half * 0.94, y: waterY - rise * 0.55)
        )
        dome.addQuadCurve(to: CGPoint(x: cx - half, y: waterY), control: CGPoint(x: cx, y: waterY + rise * 0.08))
        dome.closeSubpath()
        var random = ArtRandom(seed)
        var loose = Path()
        for _ in 0..<9 {
            let a: CGFloat = CGFloat.pi * (1.08 + Kit.rnd(&random) * 0.84)
            let bx: CGFloat = cx + cos(a) * half * 0.9
            let by: CGFloat = waterY + sin(a) * rise * 0.9
            let length: CGFloat = w * (0.07 + Kit.rnd(&random) * 0.06)
            loose.move(to: CGPoint(x: bx, y: by))
            loose.addLine(to: CGPoint(x: bx + cos(a) * length + length * 0.3, y: by + sin(a) * length))
        }
        Art.stroke(&g, loose, Art.color(0x7A5E3C), width: max(1.2, w * 0.014))
        let shape: Path = dome
        Kit.solid(&g, shape, Art.color(0x8E6F47), light: 0.3, shade: 0.28, rim: 2)
        var dark = Path()
        var pale = Path()
        for index in 0..<46 {
            let px: CGFloat = cx + (Kit.rnd(&random) - 0.5) * w
            let py: CGFloat = waterY - Kit.rnd(&random) * rise
            let length: CGFloat = w * (0.06 + Kit.rnd(&random) * 0.1)
            let tilt: CGFloat = (Kit.rnd(&random) - 0.5) * length * 0.6
            if index % 2 == 0 {
                dark.move(to: CGPoint(x: px, y: py))
                dark.addLine(to: CGPoint(x: px + length, y: py + tilt))
            } else {
                pale.move(to: CGPoint(x: px, y: py))
                pale.addLine(to: CGPoint(x: px + length, y: py + tilt))
            }
        }
        let darkLines: Path = dark
        let paleLines: Path = pale
        Art.clipped(&g, to: shape) { c in
            Art.stroke(&c, darkLines, Art.color(0x5E4428, 0.8), width: max(1.2, w * 0.014))
            Art.stroke(&c, paleLines, Art.color(0xC9A970, 0.8), width: max(1, w * 0.011))
            Art.fill(&c, Art.rect(cx - half, waterY - rise * 0.12, w, rise * 0.2), Art.color(0x4A3A2C, 0.35))
        }
        Kit.ripples(&g, cx, waterY + 3, w * 1.1, count: 2, color: Color.white, opacity: 0.5)
    }
}

// MARK: - The old willow and the small prairie life

extension IktomiArt {
    /// Where somebody sits on the willow's long low limb (the top of the limb).
    static func willowPerch(x: CGFloat, baseY: CGFloat, height h: CGFloat) -> CGPoint {
        CGPoint(x: x - h * 0.80, y: baseY - h * 0.60)
    }

    /// The old willow: a thick grey trunk standing at (x, baseY) and leaning LEFT over the
    /// water, one long low limb reaching to about x − h, a crown `h` high and long hanging
    /// strands of narrow leaves.
    static func willow(_ g: inout GraphicsContext, x: CGFloat, baseY: CGFloat, height h: CGFloat, seed: UInt32) {
        let forkX: CGFloat = x - h * 0.26
        let forkY: CGFloat = baseY - h * 0.52
        Kit.shadow(&g, x - h * 0.1, baseY, width: h * 0.7, alpha: 0.2)
        var boughs = Path()
        Kit.treeBough(&boughs, forkX, forkY, x - h * 0.98, baseY - h * 0.57, h * 0.085, h * 0.03, bend: h * 0.03)
        Kit.treeBough(&boughs, forkX, forkY, x - h * 0.34, baseY - h * 0.98, h * 0.07, h * 0.02, bend: -h * 0.03)
        Kit.treeBough(&boughs, forkX + h * 0.02, forkY, x + h * 0.2, baseY - h * 0.9, h * 0.07, h * 0.02, bend: h * 0.04)
        let limbs: Path = boughs
        Kit.solid(&g, limbs, Art.color(willowBark), light: 0.22, shade: 0.3)
        let trunk = Kit.treeTrunk(x, baseY, forkX, forkY - h * 0.02, h * 0.1, h * 0.05)
        Kit.treeBark(&g, trunk.shape, trunk.edge, willowBark)
        var furrows = Path()
        for i in 0..<4 {
            let t: CGFloat = CGFloat(i) * 0.22
            let fx: CGFloat = x - h * 0.05 + t * h * 0.1
            furrows.move(to: CGPoint(x: fx, y: baseY - h * 0.03))
            furrows.addQuadCurve(to: CGPoint(x: fx - h * 0.2, y: baseY - h * 0.44), control: CGPoint(x: fx - h * 0.04, y: baseY - h * 0.26))
        }
        let barkLines: Path = furrows
        Art.clipped(&g, to: trunk.shape) { c in
            Art.stroke(&c, barkLines, Kit.treeTone(willowBark, 0.66).opacity(0.6), width: max(1, h * 0.006))
        }
        let places: [(CGFloat, CGFloat, CGFloat)] = [
            (-0.34, -1.0, 0.2), (-0.6, -0.96, 0.15), (-0.06, -1.02, 0.2), (0.2, -0.92, 0.18), (-1.0, -0.62, 0.09),
        ]
        var blobs: [Kit.Blob] = []
        for place in places {
            let blob: Kit.Blob = (x + place.0 * h, baseY + place.1 * h, place.2 * h)
            blobs.append(blob)
        }
        let palette: Kit.Greens = willowGreens()
        Kit.canopy(&g, blobs, seed: seed, palette: palette, density: 2)
        willowStrands(&g, x: x, baseY: baseY, height: h, seed: seed &+ 7)
    }

    /// The willow's hanging strands: thin stems with narrow leaves on both sides, in three tones.
    static func willowStrands(_ g: inout GraphicsContext, x: CGFloat, baseY: CGFloat, height h: CGFloat, seed: UInt32) {
        var random = ArtRandom(seed)
        var dark = Path()
        var mid = Path()
        var lit = Path()
        var stems = Path()
        let roots: [(CGFloat, CGFloat, CGFloat)] = [
            (-0.48, -0.88, 0.5), (-0.36, -0.84, 0.42), (-0.2, -0.86, 0.5), (-0.06, -0.86, 0.46), (0.1, -0.84, 0.5),
            (0.24, -0.8, 0.44), (-1.03, -0.6, 0.3), (-0.95, -0.58, 0.26), (-0.6, -0.84, 0.2),
        ]
        let size: CGFloat = h * 0.036
        for (index, root) in roots.enumerated() {
            let sx: CGFloat = x + root.0 * h
            let sy: CGFloat = baseY + root.1 * h
            let length: CGFloat = root.2 * h
            let sway: CGFloat = -h * 0.04 - Kit.rnd(&random) * h * 0.03
            stems.move(to: CGPoint(x: sx, y: sy))
            stems.addQuadCurve(to: CGPoint(x: sx + sway, y: sy + length), control: CGPoint(x: sx, y: sy + length * 0.6))
            let count: Int = max(4, Int(length / 9))
            for i in 0..<count {
                let t: CGFloat = (CGFloat(i) + 0.5) / CGFloat(count)
                let px: CGFloat = sx + sway * t * t
                let py: CGFloat = sy + length * t
                let side: CGFloat = i % 2 == 0 ? 1 : -1
                let a: CGFloat = CGFloat.pi / 2 + side * 0.5
                switch (i + index) % 3 {
                case 0: Kit.treeLeaf(&dark, px, py, size, a, slim: 0.55)
                case 1: Kit.treeLeaf(&mid, px, py, size, a, slim: 0.55)
                default: Kit.treeLeaf(&lit, px, py, size, a, slim: 0.55)
                }
            }
        }
        let palette: Kit.Greens = willowGreens()
        Art.stroke(&g, stems, palette[1], width: max(1, h * 0.004))
        Art.fill(&g, dark, palette[1])
        Art.fill(&g, mid, palette[2])
        Art.fill(&g, lit, palette[3])
    }

    /// A tiny far willow on the far bank, about `height` tall, standing at (x, baseY).
    static func farWillow(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, height h: CGFloat, color: Color) {
        var crown = Path()
        crown.addEllipse(in: CGRect(x: x - h * 0.7, y: baseY - h, width: h * 1.1, height: h * 0.7))
        crown.addEllipse(in: CGRect(x: x - h * 0.3, y: baseY - h * 0.9, width: h * 0.9, height: h * 0.66))
        crown.addEllipse(in: CGRect(x: x - h * 0.9, y: baseY - h * 0.7, width: h * 0.5, height: h * 0.5))
        Art.fill(&context, crown, color)
        Art.stroke(&context, Art.line(x + h * 0.1, baseY, x - h * 0.05, baseY - h * 0.5), color, width: max(1, h * 0.12))
    }

    /// A western meadowlark: brown back, yellow breast with a black V. Origin at its feet,
    /// facing LEFT, about 30 long.
    static func meadowlark(_ g: inout GraphicsContext) {
        Art.stroke(&g, Art.line(8, -8, 19, -3), Art.color(0x7A6240), width: 3.4)
        Art.stroke(&g, Art.svg("M-2,-3 L-3,1 M3,-3 L3,1"), Art.color(0x6A5A4A), width: 1.1)
        let body: Path = Art.svg("M-12,-10 C-12,-18 0,-20 8,-14 C12,-10 10,-3 2,-2 C-6,-1 -12,-4 -12,-10Z")
        Kit.solid(&g, body, Art.color(0x9A7B4E), light: 0.26, shade: 0.2)
        Art.clipped(&g, to: body) { c in
            Art.fill(&c, Art.ellipse(-6, -7, 7.5, 6.5), Art.color(0xF2CE3E))
        }
        let head: Path = Art.circle(-10, -19, 5.6)
        Kit.solid(&g, head, Art.color(0x9A7B4E), light: 0.26, shade: 0.16)
        Art.fill(&g, Art.ellipse(-11.5, -16.5, 3.6, 2.6), Art.color(0xF2CE3E))
        Art.fill(&g, Art.svg("M-15,-20 L-22,-18.6 L-15,-17.4Z"), Art.color(0x6A6A70))
        Art.stroke(&g, Art.svg("M-11,-12.5 L-7,-8 L-3,-12.5"), Art.color(0x2A2426), width: 2)
        ArtStyle.eye(&g, -11, -20.5, 1.3, showsWhite: false)
        Art.stroke(&g, Art.svg("M-2,-15 L6,-11 M0,-12 L7,-8"), Art.color(0x6E5636, 0.8), width: 0.9)
    }

    /// A dragonfly on the wing: origin at its middle, about 22 long.
    static func dragonfly(_ g: inout GraphicsContext) {
        var wings = Path()
        wings.addEllipse(in: CGRect(x: -9, y: -7, width: 13, height: 4.4))
        wings.addEllipse(in: CGRect(x: -3, y: -8, width: 13, height: 4.4))
        Art.fill(&g, wings, Color.white.opacity(0.7))
        Art.stroke(&g, Art.line(-10, 0, 10, -1), Art.color(0x2F7F8A), width: 2)
        Art.fill(&g, Art.circle(-10.5, 0, 1.9), Art.color(0x23404F))
    }

    /// A duck far out on the lake: a small soft silhouette at (x, y) on the water.
    static func farDuck(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, scale s: CGFloat) {
        var duck = Path()
        duck.addEllipse(in: CGRect(x: x - 7 * s, y: y - 5 * s, width: 14 * s, height: 6 * s))
        duck.addEllipse(in: CGRect(x: x - 9 * s, y: y - 9 * s, width: 5 * s, height: 5 * s))
        Art.fill(&context, duck, ramp.deepColor.opacity(0.5))
        Art.stroke(&context, Art.line(x - 10 * s, y + 1.5 * s, x + 12 * s, y + 1.5 * s), Color.white.opacity(0.6), width: 1.1)
    }
}
