import SwiftUI
import OmramoCore

// "The Tiger, the Brahman and the Jackal": the palette, the three lights of one long day on
// the Punjab plain, the cast (the Brahman, the Jackal, the Tiger, the old buffalo) and the
// story's own parts (the flat far plain, the fields, the road, the bamboo trap, the pipal,
// the Persian wheel) that several pictures share.
//
// The plain is completely flat: no picture of this story draws a hill.

// MARK: - Palette and light

extension TigerArt {
    static let ramp = ArtStyle.Ramp(deep: 0x2B2038, shade: 0x8A5A2B, mid: 0xD9B36A, light: 0xF8EED2, glow: 0xFFD98A, accent: 0xE0661F)

    static let wheatHex: UInt32 = 0x8FB45C
    static let mustardHex: UInt32 = 0xE8C440
    static let earthHex: UInt32 = 0xD9BC82
    static let bambooHex: UInt32 = 0xD2B46A
    static let woodHex: UInt32 = 0x7A5234
    static let clayHex: UInt32 = 0xB5532F
    static let brickHex: UInt32 = 0xB97A52
    static let buffaloHex: UInt32 = 0x5C616E
    static let pipalBarkHex: UInt32 = 0xA39C8E

    /// Pale morning: hazy cream with a breath of green high up (scene-pipal, scene-well).
    static func morning() -> Kit.Light {
        let sky: Kit.Stops = [
            (Art.color(0xE6EFE2), 0), (Art.color(0xF3F1DA), 0.5), (Art.color(0xFBEBBE), 0.86), (Art.color(0xFFD98A), 1),
        ]
        return Kit.Light(sky: sky, sun: 0xFFF6D6, glow: 0xFFE3A6, haze: 0xF8EBC6, far: 0xB9BE84, mid: 0xA3B56A, near: 0x86A058)
    }

    /// The dry cream-gold of the middle of the day (scene-cage, the cover).
    static func midday() -> Kit.Light {
        let sky: Kit.Stops = [
            (Art.color(0xEFEEDD), 0), (Art.color(0xF6EDD0), 0.55), (Art.color(0xFAE6B4), 0.88), (Art.color(0xFFD98A), 1),
        ]
        return Kit.Light(sky: sky, sun: 0xFFF4D0, glow: 0xFFE0A0, haze: 0xF7E8C2, far: 0xC2BC84, mid: 0xB4AC68, near: 0x9A9450)
    }

    /// Late afternoon: soft gold warming to peach at the horizon, still pale (scene-road).
    static func afternoon() -> Kit.Light {
        let sky: Kit.Stops = [
            (Art.color(0xFBF2DC), 0), (Art.color(0xFCE8BE), 0.5), (Art.color(0xFBD8A8), 0.85), (Art.color(0xFFD49A), 1),
        ]
        return Kit.Light(sky: sky, sun: 0xFFF0C8, glow: 0xFFCF94, haze: 0xFBE2BC, far: 0xC9B886, mid: 0xB8A862, near: 0xA0904E)
    }

    /// The dusty feathery green of the kikar (thorny acacia).
    static func kikarGreens() -> Kit.Greens {
        Kit.greens(0x3E5A34, 0x5C7A3E, 0x7F9A4C, 0xA7BC62, 0xD6DE8E)
    }

    /// The fresh, glossy green of the pipal.
    static func pipalGreens() -> Kit.Greens {
        Kit.greens(0x2F5E36, 0x437C3E, 0x62A04A, 0x93C25C, 0xD2E58C)
    }
}

// MARK: - The plain

extension TigerArt {
    /// The far plane of every scene: the dead-flat edge of the plain. A low hazy line of far
    /// trees, a thread of mustard yellow and a thread of wheat green on the horizon `H`, then
    /// the veil of dusty air. Nothing rises more than about 20 × `s` above the horizon.
    static func farPlain(_ context: inout GraphicsContext, width w: CGFloat, horizon H: CGFloat, scale s: CGFloat, light: Kit.Light, seed: UInt32) {
        Kit.farTrees(&context, x0: -10, x1: w * 0.46, baseY: H, height: 12 * s, count: 6, color: light.far, seed: seed)
        Kit.farTrees(&context, x0: w * 0.5, x1: w + 10, baseY: H, height: 15 * s, count: 7, color: light.far, seed: seed &+ 3)
        let lineY: CGFloat = H - 5 * s
        Art.fill(&context, Art.rect(0, lineY, w, 3 * s), Art.color(mustardHex, 0.75))
        Art.fill(&context, Art.rect(0, H - 2.4 * s, w, 3.4 * s), light.mid)
        ArtStyle.atmosphere(&context, width: w, top: H - 34 * s, bottom: H + 4, color: light.haze, alpha: 0.34)
    }

    /// Flat strips of young wheat and mustard between `top` and `bottom`, thin far away and
    /// broad near the viewer, each with a low earth bank along its far edge.
    static func fields(_ context: inout GraphicsContext, x0: CGFloat, x1: CGFloat, top: CGFloat, bottom: CGFloat, mustardFirst: Bool, seed: UInt32) {
        guard x1 > x0, bottom > top else { return }
        let cuts: [CGFloat] = [0, 0.1, 0.24, 0.44, 0.7, 1]
        let depth: CGFloat = bottom - top
        let span: CGFloat = x1 - x0
        for index in 0..<5 {
            let y0: CGFloat = top + depth * cuts[index]
            let y1: CGFloat = top + depth * cuts[index + 1]
            let thick: CGFloat = y1 - y0
            let isMustard: Bool = (index % 2 == 0) == mustardFirst
            let base: UInt32 = isMustard ? mustardHex : wheatHex
            let tone: CGFloat = 1.1 - CGFloat(index) * 0.045
            let strip = Art.rect(x0, y0, span, thick + 1)
            let stops: Kit.Stops = [(Kit.groundTone(base, tone * 1.05), 0), (Kit.groundTone(base, tone * 0.93), 1)]
            Art.fillLinear(&context, strip, stops, from: CGPoint(x: 0, y: y0), to: CGPoint(x: 0, y: y1))
            let bank: CGFloat = max(1, min(4, thick * 0.1))
            Art.fill(&context, Art.rect(x0, y0, span, bank), Art.color(0xC7A566, 0.85))
            Art.fill(&context, Art.rect(x0, y0 + bank, span, bank * 0.6), ArtStyle.coolShade.opacity(0.1))
            guard thick > 9 else { continue }
            let area: CGFloat = span * thick
            let wanted: Int = min(150, max(10, Int(area / 420)))
            let inner = CGRect(x: x0, y: y0 + bank + 3, width: span, height: thick - bank - 3)
            let rowSeed: UInt32 = seed &+ UInt32(index) &* 7
            if isMustard {
                let dots: Int = min(260, wanted * 3)
                Art.stipple(&context, in: inner, count: dots, seed: rowSeed, color: Art.color(0xFFF08A), alpha: 0.75, size: 0.7...1.9)
                Art.stipple(&context, in: inner, count: wanted, seed: rowSeed &+ 1, color: Art.color(0x7E9A3E), alpha: 0.5, size: 0.6...1.4)
            } else {
                let blade: CGFloat = min(11, 4 + thick * 0.09)
                Kit.grass(&context, in: inner, count: wanted, seed: rowSeed, color: Kit.groundTone(wheatHex, 0.78), height: blade)
                Kit.grass(&context, in: inner, count: wanted / 2, seed: rowSeed &+ 2, color: Kit.groundTone(wheatHex, 1.22), height: blade * 0.8)
            }
        }
    }

    /// The unpaved road: a pale dusty ribbon running away from the viewer, with two cart ruts.
    static func road(_ context: inout GraphicsContext, nearX: CGFloat, nearY: CGFloat, nearWidth: CGFloat, farX: CGFloat, farY: CGFloat, farWidth: CGFloat) {
        let stops: Kit.Stops = [(Art.color(0xF3E4BC), 0), (Art.color(0xEBD6A4), 0.5), (Art.color(0xDDBF84), 1)]
        Kit.ribbon(&context, nearX: nearX, nearY: nearY, nearWidth: nearWidth, farX: farX, farY: farY, farWidth: farWidth, stops: stops)
        // The ruts follow the ribbon's own bend (the same control points as `Kit.ribbon`).
        let rise: CGFloat = farY - nearY
        let bend: CGFloat = nearWidth * 0.7
        let c1 = CGPoint(x: nearX + bend, y: nearY + rise * 0.35)
        let c2 = CGPoint(x: farX - bend * 0.6, y: nearY + rise * 0.72)
        let w1: CGFloat = Kit.mix(nearWidth, farWidth, 0.5) / 2
        let w2: CGFloat = Kit.mix(nearWidth, farWidth, 0.85) / 2
        var ruts = Path()
        let sides: [CGFloat] = [-0.3, 0.3]
        for side in sides {
            let start = CGPoint(x: nearX + nearWidth * 0.5 * side, y: nearY)
            let end = CGPoint(x: farX + farWidth * 0.5 * side, y: farY)
            ruts.move(to: start)
            ruts.addCurve(to: end, control1: CGPoint(x: c1.x + w1 * side, y: c1.y), control2: CGPoint(x: c2.x + w2 * side, y: c2.y))
        }
        Art.stroke(&context, ruts, Art.color(0xB08A52, 0.45), width: 2.4)
    }

    /// Dust, grain husks and small stones lying on a stretch of bare earth.
    static func dust(_ context: inout GraphicsContext, in rect: CGRect, seed: UInt32) {
        guard rect.width > 0, rect.height > 0 else { return }
        let wanted: Int = min(160, max(12, Int(rect.width * rect.height / 900)))
        Art.stipple(&context, in: rect, count: wanted, seed: seed, color: Art.color(0xFFF4CF), alpha: 0.7, size: 0.8...2.2)
        Art.stipple(&context, in: rect, count: wanted / 2, seed: seed &+ 5, color: Art.color(0xA9824A), alpha: 0.45, size: 0.7...1.8)
        Kit.pebbles(&context, in: rect, count: max(3, wanted / 12), seed: seed &+ 9, color: 0xB7A27C)
    }

    /// The far village: a handful of low flat-roofed mud-brick houses the colour of the earth,
    /// a few trees and one thread of cooking smoke. About 170 × `s` wide, standing on `baseY`.
    static func farVillage(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, scale s: CGFloat, light: Kit.Light) {
        Kit.farTrees(&context, x0: x - 84 * s, x1: x + 96 * s, baseY: baseY, height: 21 * s, count: 4, color: light.mid, seed: 6)
        let wall = Art.color(0xCFB07E)
        let roof = Art.color(0xAE8D5C)
        let houses: [(CGFloat, CGFloat, CGFloat)] = [(-52, 26, 11), (-22, 34, 15), (12, 28, 12), (40, 36, 14), (70, 24, 10)]
        for house in houses {
            Kit.farHouse(&context, cx: x + house.0 * s, baseY: baseY, width: house.1 * s, height: house.2 * s, wall: wall, roof: roof, flat: true)
        }
        let smoke = Kit.placed("M0,0 C-4,-10 6,-16 0,-28 C-5,-38 4,-44 2,-54", x: x + 14 * s, y: baseY - 15 * s, scale: s)
        Art.stroke(&context, smoke, Color.white.opacity(0.55), width: max(1, 1.8 * s))
    }

    /// One small paper kite far off in the sky, with its tail and a faint string.
    static func kite(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, scale s: CGFloat) {
        let string = Kit.placed("M0,6 C-8,40 -30,70 -64,96", x: x, y: y, scale: s)
        Art.stroke(&context, string, Art.color(0x8A5A2B, 0.3), width: 0.8)
        let tail = Kit.placed("M0,8 C5,14 -4,19 1,26 C5,31 -1,35 2,40", x: x, y: y, scale: s)
        Art.stroke(&context, tail, Art.color(0xE0661F, 0.7), width: max(0.8, 1.2 * s))
        let sail = Kit.placed("M0,-9 L7,0 L0,9 L-7,0Z", x: x, y: y, scale: s)
        Art.fill(&context, sail, Art.color(0xE0661F, 0.85))
        let lit = Kit.placed("M0,-9 L0,9 L-7,0Z", x: x, y: y, scale: s)
        Art.fill(&context, lit, Art.color(0xFFD98A, 0.55))
    }

    /// A rose-ringed parakeet perched, facing left: a small green leaf of a bird with a long
    /// tail and a red beak. About 30 long at scale 1; (x, y) is under its feet.
    static func parakeet(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, scale s: CGFloat) {
        Art.group(&context, x: x, y: y, scale: s) { g in
            Art.fill(&g, Art.svg("M4,-6 C12,-2 20,8 24,20 C16,14 8,8 2,0Z"), Art.color(0x3F8A3C))
            let body = Art.svg("M-7,-13 C-2,-17 6,-14 8,-7 C9,-1 4,2 -1,1 C-7,0 -10,-7 -7,-13Z")
            Kit.solid(&g, body, Art.color(0x6CB84E), light: 0.25, shade: 0.2)
            Art.fill(&g, Art.svg("M-9,-12 C-12,-12 -13,-9 -11,-7 L-8,-9Z"), Art.color(0xD8402C))
            ArtStyle.eye(&g, -5.6, -11.4, 1.3, showsWhite: false)
            Art.stroke(&g, Art.svg("M-1,-4 C3,-5 6,-3 7,0"), Art.color(0x3F8A3C), width: 1)
        }
    }
}

// MARK: - The Brahman

extension TigerArt {
    /// A thin, kindly old man: shaved head, plain white cotton dhoti with the shawl over one
    /// shoulder (the kit's wrapper), bare feet.
    static func brahmanLook() -> Kit.Person {
        Kit.Person(
            age: .elder,
            skin: 0xA8703F,
            hair: 0xD9D5CC,
            hairStyle: .shaved,
            garment: .wrapper,
            cloth: 0xF8F4EA,
            trim: 0xE3D9C2,
            legs: 0xA8703F,
            showsEyeWhite: false
        )
    }

    /// The small bundle tied in faded blue cloth, about 32 wide, centred on (0, 0).
    static func bundle(_ context: inout GraphicsContext, mirrored: Bool) {
        let knot = Art.svg("M-1,-14 C-6,-17 -9,-22 -8,-26 C-4,-24 -1,-20 1,-15 C3,-21 7,-24 11,-25 C11,-20 7,-16 2,-14Z")
        Art.fill(&context, knot, Art.color(0x6C88A6))
        let sack = Art.svg("M-14,5 C-19,-7 -9,-16 2,-15 C12,-16 19,-7 15,5 C10,11 -9,11 -14,5Z")
        Kit.personLit(&context, sack, Art.color(0x86A0BC), bounds: CGRect(x: -18, y: -16, width: 36, height: 27), mirrored: mirrored)
        Art.stroke(&context, Art.svg("M-6,-13 C-9,-6 -9,1 -6,7 M4,-14 C7,-7 7,0 5,8"), Art.color(0x5E7896, 0.7), width: 1.2)
    }

    /// The Brahman, whole, with his staff, his bundle, his sacred thread and the small tuft
    /// of grey hair at the back of his head. As `Kit.person`: origin at the feet, 160 tall,
    /// facing LEFT; mirror with `Art.group(scaleX: -1)` and pass `mirrored: true`. The staff
    /// stands in his leading hand (in the far hand when that arm is raised).
    static func brahman(
        _ context: inout GraphicsContext,
        pose: Kit.Pose = .stand,
        look: CGPoint = .zero,
        mouth: Kit.Mouth = .smile,
        mirrored: Bool = false
    ) {
        let p = brahmanLook()
        let frame = Kit.bodyFrame(p)
        let rig = Kit.bodyRig(p, pose)
        let raised: Bool = pose == .reach || pose == .wave
        let grip: CGPoint = raised ? CGPoint(x: 20, y: -58) : Kit.hand(p, pose: pose)
        Kit.propShaft(&context, grip.x + 1, grip.y - 76, grip.x - 4, -1, wood: 0x8A6238, width: 5)
        Kit.person(&context, p, pose: pose, look: look, mouth: mouth, mirrored: mirrored)
        // The sacred thread: one pale line on the bare chest, beside the edge of the shawl.
        let hipX: CGFloat = rig.hip.x * frame.k
        let hipY: CGFloat = rig.hip.y * frame.k
        Art.group(&context, x: hipX, y: hipY, rotate: -Kit.deg(rig.lean), scale: frame.k) { g in
            Art.stroke(&g, Art.line(0.5, -53, -20, -30), Art.color(0xFFFBF0), width: 1.5)
        }
        let head = Kit.bodyHeadCentre(frame, rig)
        let tuft = Kit.placed("M0,0 C3,-7 11,-6 10,2 C8,7 2,6 0,0Z", x: head.x + 21, y: head.y - 13)
        Art.fill(&context, tuft, Art.color(p.hair))
        let neck = Kit.bodyNeck(rig)
        let bx: CGFloat = neck.x * frame.k + 19
        let by: CGFloat = neck.y * frame.k + 1
        Art.group(&context, x: bx, y: by, scale: 0.9) { g in
            bundle(&g, mirrored: mirrored)
        }
        if !raised {
            Art.fill(&context, Art.circle(grip.x, grip.y, 5.6), Art.color(p.skin))
        }
    }

    /// The Brahman's head for the face chip and the close pictures, centred on (0, 0).
    static func brahmanHead(_ context: inout GraphicsContext, look: CGPoint = .zero, mouth: Kit.Mouth = .smile) {
        let p = brahmanLook()
        Kit.personHead(&context, p, look: look, mouth: mouth)
        Art.fill(&context, Art.svg("M21,-14 C24,-22 33,-20 31,-11 C29,-6 23,-8 21,-14Z"), Art.color(p.hair))
    }
}

// MARK: - The Jackal and the Tiger

extension TigerArt {
    /// The golden jackal of the plains: sandy-gold, slim-legged, big pointed ears, a narrow
    /// muzzle. His short dark-tipped brush is drawn by `jackal` (the kit's fox brush has a
    /// pale tip), so the spec has no tail.
    static func jackalLook() -> Kit.Beast {
        var look = Kit.foxLook()
        look.body = 0xD8A858
        look.belly = 0xF7E8C6
        look.dark = 0x4E3826
        look.tail = .none
        look.bodyLength = 1.45
        look.legLength = 0.75
        look.bulk = 0.7
        look.showsEyeWhite = false
        return look
    }

    /// The Jackal in side view, facing LEFT; origin on the ground under mid-body. About 150
    /// long and 130 tall to the ear tips. With the darker back and the short brush tipped
    /// dark. Use `.stand` or `.walk`.
    static func jackal(
        _ context: inout GraphicsContext,
        pose: Kit.BeastPose = .walk,
        mood: Kit.BeastMood = .happy,
        look: CGPoint = .zero,
        mirrored: Bool = false
    ) {
        let spec = jackalLook()
        let brush = Kit.placed("M-4,-6 C12,-13 30,-5 40,13 C46,27 41,40 32,38 C22,28 10,13 -4,6Z", x: 50, y: -74)
        Art.fill(&context, brush, Kit.beastTone(spec.body, 0.9))
        let dark = Art.color(spec.dark)
        let sheen = Kit.beastTone(spec.body, 1.15)
        Art.clipped(&context, to: brush) { g in
            Art.fill(&g, Art.circle(88, -38, 14), dark)
            Art.stroke(&g, Art.svg("M54,-80 C68,-82 82,-74 90,-58"), sheen, width: 2)
        }
        Kit.beast(&context, spec, pose: pose, mood: mood, look: look, mirrored: mirrored)
        // The darker back of the golden jackal.
        Art.stroke(&context, Art.svg("M-12,-86 C6,-90 30,-88 46,-82"), Art.color(0x9A7038, 0.5), width: 5)
    }

    /// The Bengal tiger: rich orange, dark stripes, white cheeks, chest and belly, and the
    /// fine white whiskers he is vain about.
    static func tigerLook() -> Kit.Beast {
        var look = Kit.tigerLook()
        look.body = 0xEC8A2C
        look.belly = 0xFFF5E2
        look.dark = 0x33241F
        look.showsEyeWhite = false
        return look
    }
}

// MARK: - The trap

extension TigerArt {
    /// The back of the bamboo trap: its shadow, its floor and the far poles, seen through.
    /// The cage is `w` wide and `h` high; the origin is the middle of its foot.
    static func cageBack(_ context: inout GraphicsContext, w: CGFloat, h: CGFloat) {
        let half: CGFloat = w / 2
        ArtStyle.contactShadow(&context, w * 0.14, 3, w * 0.66, 10, alpha: 0.3)
        Art.fill(&context, Art.rect(-half + 3, -h + 6, w - 6, h - 8), ArtStyle.coolShade.opacity(0.1))
        var poles = Path()
        var x: CGFloat = -half + 22
        while x < half - 8 {
            poles.move(to: CGPoint(x: x, y: -h + 8))
            poles.addLine(to: CGPoint(x: x, y: -8))
            x += 27
        }
        Art.stroke(&context, poles, Kit.propTone(bambooHex, 0.66).opacity(0.6), width: 4, cap: .butt)
        Art.fill(&context, Art.rect(-half, -9, w, 9), Kit.propTone(woodHex, 0.7))
    }

    /// The front of the trap: thick bamboo poles with their joints, the wooden beams, the
    /// rope lashings, and the wooden latch on the outside of the door (the left end).
    /// `latched` false lifts the latch.
    static func cageFront(_ context: inout GraphicsContext, w: CGFloat, h: CGFloat, latched: Bool) {
        let half: CGFloat = w / 2
        let count: Int = max(3, Int(w / 28))
        let step: CGFloat = w / CGFloat(count)
        var joints = Path()
        for index in 1..<count {
            let x: CGFloat = -half + step * CGFloat(index)
            Kit.propShaft(&context, x, -h + 8, x, -8, wood: bambooHex, width: 6)
            var y: CGFloat = -h + 30 + CGFloat(index % 2) * 14
            while y < -14 {
                joints.move(to: CGPoint(x: x - 3.2, y: y))
                joints.addLine(to: CGPoint(x: x + 3.2, y: y))
                y += 36
            }
        }
        Art.stroke(&context, joints, Kit.propTone(bambooHex, 0.62), width: 1.4, cap: .butt)
        let railY: CGFloat = -h * 0.36
        Kit.propShaft(&context, -half, railY, half, railY, wood: Kit.propToneHex(bambooHex, 0.9), width: 5)
        let wood = Art.color(woodHex)
        Kit.solid(&context, Art.rect(-half - 7, -h - 5, w + 14, 14, radius: 4), wood, light: 0.3, shade: 0.2)
        Kit.solid(&context, Art.rect(-half - 7, -11, w + 14, 13, radius: 4), wood, light: 0.22, shade: 0.24)
        Kit.propShaft(&context, -half, -h + 2, -half, -2, wood: Kit.propToneHex(bambooHex, 0.86), width: 9)
        Kit.propShaft(&context, half, -h + 2, half, -2, wood: Kit.propToneHex(bambooHex, 0.8), width: 9)
        // Rope lashings where the poles meet the beams and the rail.
        var rope = Path()
        let knots: [(CGFloat, CGFloat)] = [(-half, -h + 2), (half, -h + 2), (-half, -5), (half, -5), (-half, railY), (half, railY)]
        for knot in knots {
            rope.move(to: CGPoint(x: knot.0 - 6, y: knot.1 - 5))
            rope.addLine(to: CGPoint(x: knot.0 + 6, y: knot.1 + 5))
            rope.move(to: CGPoint(x: knot.0 - 6, y: knot.1 + 5))
            rope.addLine(to: CGPoint(x: knot.0 + 6, y: knot.1 - 5))
        }
        Art.stroke(&context, rope, Art.color(0xEEDFB0), width: 2.2)
        // The latch: a wooden bar on a peg.
        let turn: CGFloat = latched ? 0 : -Kit.deg(62)
        Art.group(&context, x: -half - 2, y: -h * 0.56, rotate: turn) { g in
            Kit.solid(&g, Art.rect(-8, -5, 34, 10, radius: 3), Art.color(0x5E3C26), light: 0.3, shade: 0.2)
            Art.fill(&g, Art.circle(0, 0, 2.6), Art.color(0xEEDFB0))
        }
    }

    /// The Tiger sitting up in the trap, looking out to the left between the bars. The cage
    /// is 176 wide and 168 high; the origin is the middle of its foot; his face is at about
    /// (−30, −117).
    static func cagedTiger(_ context: inout GraphicsContext, mood: Kit.BeastMood, look: CGPoint, latched: Bool = true) {
        let w: CGFloat = 176
        let h: CGFloat = 168
        cageBack(&context, w: w, h: h)
        let spec = tigerLook()
        Art.group(&context, x: 6, y: -9, scale: 0.84) { g in
            Kit.beast(&g, spec, pose: .sit, mood: mood, look: look)
        }
        cageFront(&context, w: w, h: h, latched: latched)
    }
}

// MARK: - The pipal

extension TigerArt {
    /// Adds one pipal leaf to `path`: a heart `size` wide hanging from its stalk at (x, y),
    /// with the long thin drip tip of the pipal (the whole leaf is 1.38 × `size` long).
    /// `angle` (radians) swings it; 0 hangs straight down.
    static func pipalLeaf(_ path: inout Path, x: CGFloat, y: CGFloat, size: CGFloat, angle: CGFloat) {
        let heart = Art.svg("M0,0 C-10,-6 -52,-4 -50,34 C-48,62 -16,76 -4,96 C-2,108 -1,122 0,138 C1,122 2,108 4,96 C16,76 48,62 50,34 C52,-4 10,-6 0,0Z")
        let k: CGFloat = size / 100
        let move = CGAffineTransform(translationX: x, y: y).rotated(by: angle).scaledBy(x: k, y: k)
        path.addPath(heart.applying(move))
    }

    /// A few hanging pipal leaves, each (x, y, size, angle in degrees): a shaded leaf, a
    /// lit leaf laid on it a little to the upper left, and the pale midrib.
    static func pipalLeaves(_ context: inout GraphicsContext, _ leaves: [(CGFloat, CGFloat, CGFloat, CGFloat)], dark: UInt32 = 0x437C3E, light: UInt32 = 0x7FB052) {
        var back = Path()
        var front = Path()
        var ribs = Path()
        for leaf in leaves {
            let a: CGFloat = Kit.deg(leaf.3)
            pipalLeaf(&back, x: leaf.0, y: leaf.1, size: leaf.2, angle: a)
            pipalLeaf(&front, x: leaf.0 - leaf.2 * 0.03, y: leaf.1, size: leaf.2 * 0.84, angle: a)
            let reach: CGFloat = leaf.2 * 1.3
            ribs.move(to: CGPoint(x: leaf.0, y: leaf.1))
            ribs.addLine(to: CGPoint(x: leaf.0 - sin(a) * reach, y: leaf.1 + cos(a) * reach))
        }
        Art.fill(&context, back, Art.color(dark))
        Art.fill(&context, front, Art.color(light))
        Art.stroke(&context, ribs, Art.color(0xE4F0B4, 0.7), width: 0.9)
    }

    /// The clumps of the pipal's great crown: rows of blobs from the top edge of the picture
    /// down to `bottom`, between `x0` and `x1`; lower rows start `slant` further right, so
    /// the crown is cut away over the words.
    static func pipalCrown(x0: CGFloat, x1: CGFloat, bottom: CGFloat, slant: CGFloat) -> [Kit.Blob] {
        var blobs: [Kit.Blob] = []
        var random = ArtRandom(41)
        let rows: Int = min(7, max(2, Int(bottom / 62) + 1))
        for row in 0..<rows {
            let t: CGFloat = CGFloat(row) / CGFloat(rows - 1)
            let y: CGFloat = Kit.mix(-8, bottom - 48, t)
            let left: CGFloat = x0 + slant * t
            let count: Int = max(2, Int((x1 - left) / 76) + 1)
            for index in 0..<count {
                let u: CGFloat = CGFloat(index) / CGFloat(count - 1)
                let jitterX: CGFloat = (Kit.rnd(&random) - 0.5) * 26
                let jitterY: CGFloat = (Kit.rnd(&random) - 0.5) * 22
                let r: CGFloat = 46 + Kit.rnd(&random) * 18
                let blob: Kit.Blob = (Kit.mix(left, x1, u) + jitterX, y + jitterY, r)
                blobs.append(blob)
            }
        }
        return blobs
    }

    /// The pipal's pale grey ribbed trunk from its foot at (x, baseY) up to `topY`, with two
    /// great boughs spreading into the crown. `girth` is the half-width of the trunk's foot.
    static func pipalTrunk(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, topY: CGFloat, girth: CGFloat) {
        let height: CGFloat = max(40, baseY - topY)
        var boughs = Path()
        Kit.treeBough(&boughs, x - girth * 0.2, topY + 30, x - girth * 3.4, topY - height * 0.3 - 40, girth * 0.62, girth * 0.2, bend: -girth * 0.5)
        Kit.treeBough(&boughs, x + girth * 0.2, topY + 36, x + girth * 2.6, topY - height * 0.25 - 50, girth * 0.56, girth * 0.2, bend: girth * 0.4)
        Kit.treeBough(&boughs, x, topY + 20, x - girth * 0.6, topY - 120, girth * 0.6, girth * 0.22, bend: 0)
        Art.fill(&context, boughs, Kit.treeTone(pipalBarkHex, 0.84))
        let trunk = Kit.treeTrunk(x, baseY, x, topY, girth, girth * 0.52)
        Kit.treeBark(&context, trunk.shape, trunk.edge, pipalBarkHex)
        // The ribs of an old fig: long shallow flutes, dark beside light.
        var dark = Path()
        var pale = Path()
        let flutes: [CGFloat] = [-0.42, -0.08, 0.26, 0.5]
        for flute in flutes {
            let fx: CGFloat = x + girth * flute
            let tx: CGFloat = x + girth * flute * 0.56
            dark.move(to: CGPoint(x: fx, y: baseY - 4))
            dark.addQuadCurve(to: CGPoint(x: tx, y: topY + 10), control: CGPoint(x: tx - 3, y: baseY - height * 0.4))
            pale.move(to: CGPoint(x: fx - 3.5, y: baseY - 6))
            pale.addQuadCurve(to: CGPoint(x: tx - 3, y: topY + 14), control: CGPoint(x: tx - 6.5, y: baseY - height * 0.4))
        }
        Art.clipped(&context, to: trunk.shape) { g in
            Art.stroke(&g, dark, Art.color(0x5E584E, 0.5), width: 2)
            Art.stroke(&g, pale, Art.color(0xE6DFCC, 0.5), width: 1.6)
            // The crown throws its shade on the top of the trunk.
            let shade: Kit.Stops = [(ArtStyle.coolShade.opacity(0.3), 0), (ArtStyle.coolShade.opacity(0), 1)]
            Art.fillLinear(&g, Art.rect(x - girth * 2, topY, girth * 4, height * 0.5), shade, from: CGPoint(x: 0, y: topY), to: CGPoint(x: 0, y: topY + height * 0.5))
        }
    }

    /// The low earth platform round the pipal's foot, `width` wide, its top at `topY`.
    static func pipalPlatform(_ context: inout GraphicsContext, x: CGFloat, topY: CGFloat, width: CGFloat, height: CGFloat) {
        let half: CGFloat = width / 2
        ArtStyle.contactShadow(&context, x + width * 0.06, topY + height + 2, half * 1.12, 9, alpha: 0.26)
        let side = Art.rect(x - half, topY, width, height, radius: 8)
        let earth: Kit.Stops = [(Art.color(0xDDBE86), 0), (Art.color(0xBF9A62), 1)]
        Kit.solid(&context, side, stops: earth, light: 0.2, shade: 0.22)
        let top = Art.ellipse(x, topY + 1, half, max(4, height * 0.3))
        Art.fill(&context, top, Art.color(0xE9D3A0))
        Art.stroke(&context, Kit.builtCourses(CGRect(x: x - half + 8, y: topY + 7, width: width - 16, height: height - 10), seed: 14), Art.color(0x9A7848, 0.4), width: 1.1)
    }
}

// MARK: - The old buffalo

extension TigerArt {
    /// The old water buffalo in side view, facing LEFT, mid-step on her worn circle: dark
    /// slate grey, heavy, thin-hipped, with swept-back curved horns. Bespoke (the kit has no
    /// ox). Origin: the ground under the middle of her body; she is about 260 long (nose at
    /// x −160) and 150 tall; her eye is at (−124, −98); the yoke lies on her neck at
    /// (−76, −118).
    static func buffalo(_ context: inout GraphicsContext, look: CGPoint = .zero) {
        let coat = Art.color(buffaloHex)
        let far = Kit.beastTone(buffaloHex, 0.76)
        let line = Kit.beastTone(buffaloHex, 0.66)
        let hoof = Art.color(0x2E2A30)
        let horn = Art.color(0x47434C)
        Art.fill(&context, Art.svg("M-120,-112 C-116,-140 -82,-150 -58,-132 C-80,-138 -102,-132 -108,-112Z"), Kit.beastTone(0x47434C, 0.8))
        Art.stroke(&context, Art.svg("M96,-104 C108,-92 107,-66 102,-48"), far, width: 5)
        Art.fill(&context, Art.svg("M102,-50 C108,-44 108,-30 102,-24 C97,-30 97,-44 102,-50Z"), hoof)
        Art.stroke(&context, Art.svg("M-46,-62 C-44,-40 -38,-24 -34,-9"), far, width: 16)
        Art.stroke(&context, Art.svg("M58,-62 C52,-44 50,-24 46,-9"), far, width: 16)
        var farHooves = Art.ellipse(-35, -5, 10, 5)
        farHooves.addPath(Art.ellipse(45, -5, 10, 5))
        Art.fill(&context, farHooves, hoof.opacity(0.85))
        let body = Art.svg("M-78,-112 C-66,-124 -40,-122 -10,-118 C20,-116 44,-123 66,-121 C88,-118 102,-102 100,-78 C98,-58 84,-44 58,-42 C20,-36 -30,-34 -62,-42 C-84,-48 -94,-66 -92,-88 C-91,-100 -86,-108 -78,-112Z")
        Kit.solid(&context, body, coat, light: 0.22, shade: 0.26, rim: 2)
        // Old bones: the hip and three ribs, lightly.
        let bones = Art.svg("M62,-113 C72,-105 76,-92 74,-80 M20,-100 C24,-86 22,-70 16,-58 M34,-102 C38,-88 36,-72 30,-60 M6,-100 C10,-86 8,-70 2,-58")
        Art.stroke(&context, bones, line.opacity(0.55), width: 1.6)
        Art.stroke(&context, Art.svg("M-66,-60 C-70,-40 -78,-24 -84,-9"), coat, width: 17)
        Art.stroke(&context, Art.svg("M78,-60 C90,-44 84,-24 80,-9"), coat, width: 18)
        Art.stroke(&context, Art.svg("M-72,-56 C-76,-40 -83,-26 -88,-14"), ArtStyle.warmLight.opacity(0.16), width: 3)
        var hooves = Art.ellipse(-86, -5, 11, 5.5)
        hooves.addPath(Art.ellipse(79, -5, 11, 5.5))
        Art.fill(&context, hooves, hoof)
        // The neck, the long head held low and level, the ear, the near horn.
        Art.stroke(&context, Art.svg("M-70,-94 C-86,-98 -100,-96 -112,-93"), coat, width: 42)
        let muzzle = Art.svg("M-122,-108 C-140,-104 -159,-92 -161,-81 C-162,-70 -151,-65 -138,-67 C-124,-69 -110,-75 -104,-84Z")
        Kit.solid(&context, muzzle, coat, light: 0.2, shade: 0.22)
        Kit.solid(&context, Art.ellipse(-113, -96, 25, 22), coat, light: 0.24, shade: 0.2)
        Art.fill(&context, Art.ellipse(-152, -79, 9.5, 8.5), Kit.beastTone(buffaloHex, 0.62))
        Art.fill(&context, Art.ellipse(-155.5, -81, 2.2, 1.6), hoof)
        Art.fill(&context, Art.ellipse(-152, -84.5, 3, 1.4), Color.white.opacity(0.25))
        Art.stroke(&context, Art.svg("M-157,-72 C-150,-68 -140,-70 -132,-74"), hoof.opacity(0.7), width: ArtStyle.detailLine)
        ArtStyle.eye(&context, -124, -98, 3.7, look: look, showsWhite: false)
        Art.stroke(&context, Art.svg("M-129.5,-102 C-126,-105 -121,-104.5 -118,-101"), line, width: 1.5)
        ArtStyle.cheek(&context, -112, -86, 7, alpha: 0.18)
        let ear = Art.svg("M-102,-110 C-90,-116 -76,-110 -70,-100 C-82,-97 -95,-101 -102,-110Z")
        Kit.solid(&context, ear, Kit.beastTone(buffaloHex, 0.88), light: 0.2, shade: 0.2)
        Art.stroke(&context, Art.svg("M-96,-108 C-88,-108 -80,-105 -75,-101"), Art.color(0xC9A6A0, 0.5), width: 1.6)
        let nearHorn = Art.svg("M-114,-114 C-110,-144 -72,-154 -46,-132 C-70,-141 -95,-134 -101,-112Z")
        Kit.solid(&context, nearHorn, horn, light: 0.34, shade: 0.2, rim: 1.5)
        Art.stroke(&context, Art.svg("M-108,-122 l7,2 M-104,-130 l7,3 M-97,-137 l6,4 M-88,-142 l4,5"), Color.white.opacity(0.2), width: 1.1)
    }

    /// The wooden yoke on the buffalo's neck and the draw beam that runs from it back to the
    /// gear shaft of the wheel at (`toX`, `toY`), in the buffalo's own units.
    static func yoke(_ context: inout GraphicsContext, toX: CGFloat, toY: CGFloat) {
        Kit.propShaft(&context, -70, -116, toX, toY, wood: 0x8A6238, width: 6)
        let bow = Art.svg("M-92,-104 C-90,-122 -64,-126 -58,-108 C-64,-114 -86,-112 -92,-104Z")
        Kit.solid(&context, bow, Art.color(woodHex), light: 0.3, shade: 0.2)
        Art.stroke(&context, Art.svg("M-88,-104 C-90,-90 -88,-78 -84,-70"), Art.color(0xEEDFB0, 0.9), width: 2)
    }
}

// MARK: - The well-wheel

extension TigerArt {
    /// One small red clay pot, mouth up, about 18 wide and 20 tall, centred on (x, y) and
    /// turned by `turn` radians (clockwise).
    static func clayPot(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, turn: CGFloat, scale: CGFloat = 1) {
        Art.group(&context, x: x, y: y, rotate: turn, scale: scale) { g in
            let belly = Art.svg("M-5,-7 C-9,-3 -9,5 -4,8 C-1,10 2,10 5,8 C9,5 9,-3 5,-7Z")
            Art.fill(&g, belly, Art.color(clayHex))
            Art.fill(&g, Art.rect(-5.5, -10, 11, 3.8, radius: 1.6), Kit.propTone(clayHex, 0.78))
        }
        // The light stays on the upper left whichever way the pot is turned.
        Art.fill(&context, Art.ellipse(x - 2.4 * scale, y - 2 * scale, 2.4 * scale, 3 * scale), Art.color(0xE9966A, 0.7))
    }

    /// The Persian wheel: a round brick well, a large upright wooden wheel over it carrying a
    /// loop of small red clay pots on ropes, the top pots tipping bright water into a wooden
    /// trough, and the wooden gear on its shaft that an animal turns. No animal.
    /// Origin: the ground under the middle of the well. About 280 wide (x −140…134) and 172
    /// tall; the hub is at (0, −100); the top of the gear shaft, where the draw beam is
    /// fixed, is at (−112, −134).
    static func wellWheel(_ context: inout GraphicsContext) {
        let hubY: CGFloat = -100
        let R: CGFloat = 52
        let water = Art.color(0xDDF3F7)
        ArtStyle.contactShadow(&context, 14, 4, 118, 12, alpha: 0.24)
        // The two posts that carry the axle, behind everything.
        Kit.propShaft(&context, -70, -2, -70, hubY - 12, wood: woodHex, width: 9)
        Kit.propShaft(&context, 70, -2, 70, hubY - 12, wood: Kit.propToneHex(woodHex, 0.86), width: 9)
        Kit.well(&context, cx: 0, baseY: 0, width: 108, height: 44, stone: brickHex, roofed: false)
        wellTrough(&context, water: water)
        // The loop of pots: up out of the well on the left, down into it on the right.
        let ropes = Art.svg("M-51,-92 C-48,-72 -38,-56 -30,-45 M51,-92 C48,-72 38,-56 30,-45")
        Art.stroke(&context, ropes, Art.color(0xE4D3A0), width: 2)
        clayPot(&context, x: -46, y: -73, turn: -Kit.deg(12))
        clayPot(&context, x: -36, y: -54, turn: -Kit.deg(24))
        clayPot(&context, x: 45, y: -70, turn: Kit.deg(192))
        Kit.propShaft(&context, -98, hubY, 76, hubY, wood: Kit.propToneHex(woodHex, 0.8), width: 7)
        Kit.propWheel(&context, x: 0, y: hubY, r: R, color: woodHex)
        for index in 0..<6 {
            let a: CGFloat = 180 + CGFloat(index) * 36
            let px: CGFloat = cos(Kit.deg(a)) * (R + 8)
            let py: CGFloat = hubY + sin(Kit.deg(a)) * (R + 8)
            clayPot(&context, x: px, y: py, turn: Kit.deg(a - 180))
        }
        // The top pots tip their water into the trough.
        let falls = Art.svg("M24,-151 C44,-147 60,-110 64,-51 M55,-131 C67,-123 75,-90 79,-47")
        Art.stroke(&context, falls, water.opacity(0.9), width: 3.4)
        Art.stroke(&context, falls, Color.white.opacity(0.8), width: 1.1)
        var drops = Path()
        let places: [(CGFloat, CGFloat, CGFloat)] = [(38, -128, 1.8), (58, -96, 1.6), (70, -74, 2), (84, -62, 1.5), (52, -58, 1.4)]
        for place in places {
            drops.addEllipse(in: CGRect(x: place.0 - place.2, y: place.1 - place.2, width: place.2 * 2, height: place.2 * 2.6))
        }
        Art.fill(&context, drops, Color.white.opacity(0.85))
        wellGear(&context, hubY: hubY)
    }

    /// The wooden trough that carries the water from the wheel to the ditch.
    static func wellTrough(_ context: inout GraphicsContext, water: Color) {
        Kit.propShaft(&context, 112, -2, 112, -30, wood: Kit.propToneHex(woodHex, 0.8), width: 6)
        let trough = Art.svg("M34,-54 L130,-37 L128,-26 L32,-43Z")
        Kit.solid(&context, trough, Art.color(woodHex), light: 0.3, shade: 0.2)
        Art.stroke(&context, Art.line(38, -51, 127, -35), water, width: 3)
        Art.stroke(&context, Art.svg("M129,-34 C136,-28 137,-16 136,-5"), water.opacity(0.9), width: 3)
        Art.fill(&context, Art.ellipse(136, -1, 13, 3.6), water.opacity(0.8))
        Art.stroke(&context, Art.svg("M124,-1 q12,5 24,0"), Color.white.opacity(0.7), width: 1.2)
    }

    /// The gears: a pegged cog on the wheel's axle and the flat pegged wheel on the upright
    /// shaft that the draw beam turns.
    static func wellGear(_ context: inout GraphicsContext, hubY: CGFloat) {
        let dark = Kit.propTone(woodHex, 0.74)
        Kit.solid(&context, Art.ellipse(-89, hubY, 7.5, 25), dark, light: 0.26, shade: 0.2)
        var pegs = Path()
        for index in 0..<5 {
            let y: CGFloat = hubY - 20 + CGFloat(index) * 10
            pegs.move(to: CGPoint(x: -97, y: y))
            pegs.addLine(to: CGPoint(x: -81, y: y))
        }
        Art.stroke(&context, pegs, Kit.propTone(woodHex, 1.3), width: 2.4)
        Art.fill(&context, Art.ellipse(-112, 0, 15, 4.5), Art.color(0x9A8A72))
        Kit.propShaft(&context, -112, -1, -112, -134, wood: woodHex, width: 9)
        var teeth = Path()
        for index in 0..<6 {
            let x: CGFloat = -134 + CGFloat(index) * 8.8
            teeth.move(to: CGPoint(x: x, y: hubY - 25))
            teeth.addLine(to: CGPoint(x: x, y: hubY - 15))
        }
        Art.stroke(&context, teeth, Kit.propTone(woodHex, 1.3), width: 2.6)
        Kit.solid(&context, Art.ellipse(-112, hubY - 27, 27, 7), Art.color(woodHex), light: 0.3, shade: 0.22)
        Art.fill(&context, Art.circle(-112, -134, 5.5), dark)
    }
}
