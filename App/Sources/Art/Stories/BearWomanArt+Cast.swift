import SwiftUI
import OmramoCore

// The cast, the light and the shared parts of "The Woman Who Raised a Bear": the old woman,
// the polar bear (drawn by hand: the kit's bear is too round for a real nanoq), a ringed
// seal, icebergs, the stone-and-turf house, the kayak on its stand, the drying rack, the
// resting dogs and the half-moon soapstone lamp.

extension BearWomanArt {
    // MARK: Palette and light

    static let ramp = ArtStyle.Ramp(deep: 0x12233A, shade: 0x3E5A73, mid: 0x8FB4CC, light: 0xEEF4F7, glow: 0xF2C063, accent: 0x7A5235)

    static let coatHex: UInt32 = 0xF3ECD8
    static let coatFarHex: UInt32 = 0xD8D1C2
    static let cubHex: UInt32 = 0xEEF0EE
    static let noseHex: UInt32 = 0x23232C
    static let sinewHex: UInt32 = 0xD8C79C
    static let sinewDarkHex: UInt32 = 0xA48E5A
    static let sootHex: UInt32 = 0x34343E
    static let iceHex: UInt32 = 0xF4F8FA
    static let iceShadeHex: UInt32 = 0xBCD3E2
    static let rockHex: UInt32 = 0x6E7A82
    static let turfHex: UInt32 = 0x9A8A66
    static let woodHex: UInt32 = 0x8A6E50
    static let skinBoatHex: UInt32 = 0xC2A47A
    static let flameHex: UInt32 = 0xF6C25A

    /// The long clear light of late winter: pale blue overhead, warm on the horizon.
    static func day() -> Kit.Light {
        let sky: Kit.Stops = [(Art.color(0xD3E4EF), 0), (Art.color(0xE8F1F6), 0.55), (Art.color(0xF8EEDB), 1)]
        return Kit.Light(sky: sky, sun: 0xFFF6E2, glow: 0xF2C063, haze: 0xE6EFF4, far: 0xC3D4E0, mid: 0x8C9CA8, near: 0x5E6F7A)
    }

    /// The cloudless still morning of the farewell: paler, a little warmer low down.
    static func morning() -> Kit.Light {
        let sky: Kit.Stops = [(Art.color(0xDDEAF3), 0), (Art.color(0xEFF4F8), 0.6), (Art.color(0xFBEAD3), 1)]
        return Kit.Light(sky: sky, sun: 0xFFF8EA, glow: 0xF5CC86, haze: 0xEEF2F5, far: 0xC9D9E4, mid: 0x93A3AE, near: 0x5E6F7A)
    }

    /// Snow and sea ice from the horizon toward the viewer.
    static func iceStops() -> Kit.Stops {
        [(Art.color(0xDCE8F0), 0), (Art.color(0xEEF4F8), 0.35), (Art.color(0xF7FAFC), 1)]
    }

    // MARK: People

    /// The old woman: small, a little bent, grey top-knot, plain sealskin anorak and kamiks.
    static func womanLook() -> Kit.Person {
        Kit.Person(
            age: .elder,
            skin: 0xB07A58,
            hair: 0xC9C3BA,
            hairStyle: .topknot,
            beard: .none,
            headwear: .none,
            headwearColor: 0xFFFFFF,
            garment: .parka,
            cloth: 0x7A5235,
            trim: 0xD9C4A0,
            legs: 0x5A3C28,
            showsEyeWhite: false
        )
    }

    /// A hunter in a hooded sealskin anorak.
    static func hunterLook(_ n: Int) -> Kit.Person {
        let cloth: UInt32 = n % 2 == 0 ? 0x6A4C34 : 0x5E4636
        return Kit.Person(
            age: .adult,
            skin: 0xA8724E,
            hair: 0x2A2220,
            hairStyle: .short,
            beard: .none,
            headwear: .hood,
            headwearColor: cloth,
            garment: .parka,
            cloth: cloth,
            trim: 0xCDB894,
            legs: 0x4A3424,
            showsEyeWhite: false
        )
    }

    /// A child of the settlement, in the same sealskin dress, smaller.
    static func childLook(_ n: Int) -> Kit.Person {
        let girl: Bool = n % 2 == 1
        return Kit.Person(
            age: .child,
            skin: 0xB27C56,
            hair: 0x241C1A,
            hairStyle: girl ? .topknot : .short,
            beard: .none,
            headwear: .none,
            headwearColor: 0xFFFFFF,
            garment: .parka,
            cloth: girl ? 0x8A5E3E : 0x6E5038,
            trim: 0xE0CCA6,
            legs: 0x5A3C28,
            showsEyeWhite: false
        )
    }

    /// The old woman at the origin (feet, or the ground under the seat for `.sit`), with her
    /// contact shadow. `sooty` blackens the fingertips of her leading hand (page 12).
    static func woman(
        _ context: inout GraphicsContext,
        pose: Kit.Pose,
        mouth: Kit.Mouth = .flat,
        mirrored: Bool = false,
        sooty: Bool = false
    ) {
        let look = womanLook()
        if pose != .sit {
            Kit.shadow(&context, 0, 0, width: 54)
        }
        let flip: CGFloat = mirrored ? -1 : 1
        Art.group(&context, scaleX: flip) { g in
            Kit.person(&g, look, pose: pose, look: CGPoint(x: -0.3, y: 0), mouth: mouth, mirrored: mirrored)
            if sooty {
                let hand: CGPoint = Kit.hand(look, pose: pose)
                Art.fill(&g, Art.circle(hand.x - 1, hand.y + 2, 3.6), Art.color(sootHex, 0.85))
            }
        }
    }

    /// A hunter standing with a harpoon upright in his leading hand.
    static func hunter(_ context: inout GraphicsContext, _ n: Int, pose: Kit.Pose = .stand, mirrored: Bool = false) {
        let look = hunterLook(n)
        Kit.shadow(&context, 0, 0, width: 56)
        let flip: CGFloat = mirrored ? -1 : 1
        Art.group(&context, scaleX: flip) { g in
            let hand: CGPoint = Kit.hand(look, pose: pose)
            let top: CGFloat = hand.y - 70
            Art.stroke(&g, Art.line(hand.x, top, hand.x, -2), Art.color(woodHex), width: 3)
            Art.fill(&g, Art.svg("M\(hand.x - 2.4),\(top) L\(hand.x),\(top - 9) L\(hand.x + 2.4),\(top) Z"), Art.color(0xEDE4D0))
            Kit.person(&g, look, pose: pose, look: .zero, mouth: .flat, mirrored: mirrored)
        }
    }

    /// A child at play (`.wave` or `.walk`), with its shadow.
    static func child(_ context: inout GraphicsContext, _ n: Int, pose: Kit.Pose, mirrored: Bool = false) {
        let look = childLook(n)
        Kit.shadow(&context, 0, 0, width: 40)
        let flip: CGFloat = mirrored ? -1 : 1
        Art.group(&context, scaleX: flip) { g in
            Kit.person(&g, look, pose: pose, look: .zero, mouth: .grin, mirrored: mirrored)
        }
    }

    // MARK: Modelling helper

    /// Fills and models a shape with the one light, correct when the caller has mirrored x.
    static func lit(_ context: inout GraphicsContext, _ shape: Path, _ hex: UInt32, mirrored: Bool, rim: Bool = true) {
        let box: CGRect = shape.boundingRect
        guard box.width > 0, box.height > 0 else { return }
        Kit.personLit(&context, shape, Art.color(hex), bounds: box, mirrored: mirrored, light: 0.22, shade: 0.26)
        if rim && !mirrored {
            ArtStyle.rimEdge(&context, shape, bounds: box, width: 2.4, alpha: 0.4)
        }
    }
}

// MARK: - The bear

extension BearWomanArt {
    /// The bear's head in profile, facing LEFT, centred on (0, 0): about 50 long and 26 high,
    /// a long straight nose, small round ears, black nose and lips, the plain eye.
    static func bearHead(_ context: inout GraphicsContext, coat: UInt32 = coatHex, mirrored: Bool = false) {
        let skull: Path = Art.svg("M18,-12 C8,-18 -6,-16 -14,-6 C-20,-2 -26,2 -27,6 C-27,10 -22,12 -16,12 C-6,14 8,14 16,10 C22,6 24,-6 18,-12 Z")
        let ear: Path = Art.svg("M9,-14 C8,-21 15,-23 18,-17 C19.5,-14 17,-11 13,-11.5 Z")
        lit(&context, ear, coat, mirrored: mirrored, rim: false)
        Art.fill(&context, Art.circle(13.6, -15.4, 2.2), Art.color(0xB9A894, 0.8))
        lit(&context, skull, coat, mirrored: mirrored)
        let jaw: Path = Art.svg("M-22,11 C-12,14 4,15 14,10")
        Art.stroke(&context, jaw, Art.color(0xC9C1B0, 0.7), width: ArtStyle.detailLine)
        Art.fill(&context, Art.ellipse(-25, 5, 3.6, 2.9), Art.color(noseHex))
        Art.fill(&context, Art.circle(-26, 3.9, 1), Color.white.opacity(0.5))
        let lips: Path = Art.svg("M-24.5,9.6 C-19,11.6 -13,11.2 -8,9.2")
        Art.stroke(&context, lips, Art.color(noseHex, 0.75), width: ArtStyle.detailLine)
        let brow: Path = Art.svg("M-11,-7 C-8,-9 -4,-9.4 -1,-8")
        Art.stroke(&context, brow, Art.color(0xCFC7B6, 0.8), width: ArtStyle.detailLine)
        Art.group(&context, x: -6.5, y: -3, scaleX: mirrored ? -1 : 1) { e in
            ArtStyle.eye(&e, 0, 0, 2.3, showsWhite: false)
        }
    }

    /// The braided sinew collar along `data` (a short curve round the neck).
    static func collar(_ context: inout GraphicsContext, _ data: String) {
        let band: Path = Art.svg(data)
        Art.stroke(&context, band, Art.color(sinewDarkHex), width: 10)
        Art.stroke(&context, band, Art.color(sinewHex), width: 8)
        Art.stroke(&context, band, Art.color(sinewDarkHex, 0.9), width: 7, dash: [2.2, 3.2])
        Art.stroke(&context, band, Color.white.opacity(0.35), width: 2, dash: [3, 2.4])
    }

    /// The full-grown bear walking, facing LEFT; origin on the ground under mid-body; about
    /// 220 long (nose x −131, rump x 92) and 104 high. `head`: 0 carried level, 1 low (hauling),
    /// 2 turned back over the shoulder.
    static func bear(
        _ context: inout GraphicsContext,
        head: Int = 0,
        collar wearsCollar: Bool = true,
        soot: Bool = false,
        mirrored: Bool = false
    ) {
        Kit.shadow(&context, -4, 0, width: 210, alpha: 0.2)
        let flip: CGFloat = mirrored ? -1 : 1
        Art.group(&context, scaleX: flip) { g in
            let farFront: Path = Art.svg("M-30,-50 C-30,-30 -32,-14 -34,-5 C-35,0 -26,1 -16,0 C-16,-8 -16,-26 -12,-48 Z")
            let farHind: Path = Art.svg("M56,-56 C58,-36 60,-18 58,-5 C58,0 68,1 76,0 C76,-14 76,-34 80,-58 Z")
            lit(&g, farFront, coatFarHex, mirrored: mirrored, rim: false)
            lit(&g, farHind, coatFarHex, mirrored: mirrored, rim: false)
            Art.fill(&g, Art.circle(90, -80, 5.5), Art.color(coatHex))
            let torso: Path = Art.svg("M-50,-44 C-62,-60 -56,-84 -36,-90 C-10,-98 30,-104 58,-98 C82,-92 94,-70 86,-48 C80,-32 66,-28 52,-32 C22,-30 -10,-30 -32,-32 C-42,-34 -47,-38 -50,-44 Z")
            bearNeck(&g, head: head, mirrored: mirrored)
            lit(&g, torso, coatHex, mirrored: mirrored)
            let belly: Path = Art.svg("M-40,-36 C-10,-33 24,-33 52,-35")
            Art.stroke(&g, belly, Art.color(0xCFC6B4, 0.6), width: ArtStyle.contourLine)
            let haunch: Path = Art.svg("M48,-90 C64,-80 70,-62 62,-44")
            Art.stroke(&g, haunch, Art.color(0xD6CDBA, 0.7), width: ArtStyle.contourLine)
            let nearFront: Path = Art.svg("M-48,-52 C-52,-30 -56,-14 -60,-5 C-62,0 -52,2 -38,0 C-36,-8 -34,-24 -28,-46 Z")
            let nearHind: Path = Art.svg("M40,-58 C46,-38 48,-18 44,-5 C44,0 56,2 66,0 C66,-14 68,-34 74,-60 Z")
            lit(&g, nearFront, coatHex, mirrored: mirrored)
            lit(&g, nearHind, coatHex, mirrored: mirrored)
            let toes: Path = Art.svg("M-56,-1 L-55,-5 M-50,0 L-49,-4 M-44,0 L-43,-4 M50,0 L50,-4 M56,1 L56,-3 M62,0 L62,-4")
            Art.stroke(&g, toes, Art.color(0xBDB4A2, 0.8), width: 1.3)
            if soot {
                let streak: Path = Art.svg("M8,-97 C13,-78 17,-60 22,-40")
                Art.stroke(&g, streak, Art.color(sootHex, 0.5), width: 8)
                Art.stroke(&g, streak, Art.color(sootHex, 0.6), width: 3.5)
            }
            bearHeadPlaced(&g, head: head, collar: wearsCollar, mirrored: mirrored)
        }
    }

    /// The neck of the walking bear for each head carriage.
    static func bearNeck(_ context: inout GraphicsContext, head: Int, mirrored: Bool) {
        let data: String
        switch head {
        case 1: data = "M-34,-90 C-60,-90 -84,-74 -98,-58 L-100,-36 C-84,-36 -62,-40 -46,-42 Z"
        case 2: data = "M-50,-80 C-58,-94 -54,-110 -44,-118 L-24,-108 C-26,-98 -28,-92 -26,-84 Z"
        default: data = "M-34,-90 C-58,-92 -80,-86 -96,-78 L-98,-58 C-82,-56 -62,-52 -46,-42 Z"
        }
        lit(&context, Art.svg(data), coatHex, mirrored: mirrored, rim: false)
    }

    /// The head and the collar of the walking bear for each head carriage.
    static func bearHeadPlaced(_ context: inout GraphicsContext, head: Int, collar wearsCollar: Bool, mirrored: Bool) {
        switch head {
        case 1:
            Art.group(&context, x: -106, y: -46, rotate: -0.35) { h in
                bearHead(&h, mirrored: mirrored)
            }
            if wearsCollar {
                collar(&context, "M-60,-84 C-68,-70 -72,-56 -70,-42")
            }
        case 2:
            if wearsCollar {
                collar(&context, "M-52,-92 C-44,-98 -36,-98 -28,-94")
            }
            Art.group(&context, x: -30, y: -116, rotate: -0.12, scaleX: -1) { h in
                bearHead(&h, mirrored: !mirrored)
            }
        default:
            Art.group(&context, x: -104, y: -68) { h in
                bearHead(&h, mirrored: mirrored)
            }
            if wearsCollar {
                collar(&context, "M-58,-90 C-64,-76 -66,-62 -62,-48")
            }
        }
    }

    /// The bear lying on his belly, facing LEFT, head raised by `lift` (0…1); origin on the
    /// ground under mid-body; about 190 long and 50 high at the back. `cub` makes him a small
    /// frosted cub (the caller scales him down) with a bigger head.
    static func bearLying(
        _ context: inout GraphicsContext,
        lift: CGFloat = 0.5,
        collar wearsCollar: Bool = false,
        cub: Bool = false,
        mirrored: Bool = false
    ) {
        let coat: UInt32 = cub ? cubHex : coatHex
        Kit.shadow(&context, 4, 0, width: 180, alpha: 0.2)
        let flip: CGFloat = mirrored ? -1 : 1
        Art.group(&context, scaleX: flip) { g in
            Art.fill(&g, Art.ellipse(-70, -5, 15, 6), Art.color(coatFarHex))
            let torso: Path = Art.svg("M-46,-8 C-58,-24 -50,-46 -28,-52 C4,-58 46,-60 70,-50 C90,-42 94,-18 84,-6 C72,2 -36,2 -46,-8 Z")
            let headX: CGFloat = -84
            let headY: CGFloat = -30 - 24 * lift
            var neck = Path()
            neck.move(to: CGPoint(x: -26, y: -52))
            neck.addQuadCurve(to: CGPoint(x: headX + 12, y: headY - 11), control: CGPoint(x: -50, y: headY - 14))
            neck.addLine(to: CGPoint(x: headX + 14, y: headY + 10))
            neck.addQuadCurve(to: CGPoint(x: -30, y: -12), control: CGPoint(x: -52, y: headY + 16))
            neck.closeSubpath()
            lit(&g, neck, coat, mirrored: mirrored, rim: false)
            lit(&g, torso, coat, mirrored: mirrored)
            let haunch: Path = Art.svg("M50,-46 C64,-38 68,-20 60,-4")
            Art.stroke(&g, haunch, Art.color(0xD6CDBA, 0.7), width: ArtStyle.contourLine)
            let leg: Path = Art.svg("M-38,-24 C-56,-20 -72,-15 -84,-10 C-91,-6 -88,0 -80,0 L-34,0 Z")
            lit(&g, leg, coat, mirrored: mirrored)
            let toes: Path = Art.svg("M-84,-2 L-82,-6 M-78,-1 L-76,-5 M-72,-1 L-71,-5")
            Art.stroke(&g, toes, Art.color(0xBDB4A2, 0.8), width: 1.3)
            if cub {
                Kit.flecks(&g, in: CGRect(x: -40, y: -52, width: 110, height: 40), count: 26, seed: 61, color: Color.white, radius: 0.8...1.8)
            }
            if wearsCollar {
                collar(&g, "M-40,-54 C-48,-42 -50,-26 -44,-12")
            }
            let headScale: CGFloat = cub ? 1.45 : 1
            Art.group(&g, x: headX, y: headY, rotate: 0.32 * lift, scale: headScale) { h in
                bearHead(&h, coat: coat, mirrored: mirrored)
            }
        }
    }
}

// MARK: - The seal, the ice, the sea

extension BearWomanArt {
    /// A ringed seal lying whole and still, facing LEFT; origin on the ground under its middle;
    /// about 116 long and 24 high. Grey with pale rings.
    static func seal(_ context: inout GraphicsContext) {
        Kit.shadow(&context, 0, 1, width: 100, alpha: 0.18)
        let flippers: Path = Art.svg("M52,-10 C62,-18 70,-15 66,-8 C71,-4 66,3 57,-1 Z")
        Kit.solid(&context, flippers, Art.color(0x6E7780), light: 0.2, shade: 0.2)
        let body: Path = Art.svg("M-50,-6 C-50,-16 -40,-21 -26,-22 C-2,-24 24,-20 38,-12 C44,-9 50,-8 56,-12 C60,-10 60,-4 56,-1 C44,2 20,3 -40,2 C-48,1 -51,-2 -50,-6 Z")
        Kit.solid(&context, body, Art.color(0x838C95), light: 0.26, shade: 0.24, rim: 2)
        let belly: Path = Art.svg("M-44,0 C-20,2 20,2 50,-2")
        Art.stroke(&context, belly, Art.color(0xB8C0C6, 0.7), width: 2)
        let rings: [(CGFloat, CGFloat, CGFloat)] = [(-20, -16, 2.6), (-6, -18, 3), (8, -16, 2.4), (20, -13, 2.8), (-12, -9, 2.2), (2, -9, 2.6), (30, -9, 2.2), (14, -6, 2)]
        var marks = Path()
        for ring in rings {
            marks.addEllipse(in: CGRect(x: ring.0 - ring.2, y: ring.1 - ring.2 * 0.7, width: ring.2 * 2, height: ring.2 * 1.4))
        }
        Art.stroke(&context, marks, Art.color(0xC4CCD2, 0.8), width: 1.1)
        let fore: Path = Art.svg("M-30,-3 C-28,3 -20,5 -16,1 Z")
        Art.fill(&context, fore, Art.color(0x6E7780))
        Art.stroke(&context, Art.svg("M-43,-13 q2,1.4 4,0"), Art.color(0x2E3238), width: 1.3)
        Art.fill(&context, Art.circle(-49.5, -8, 1.4), Art.color(0x2E3238))
        Art.stroke(&context, Art.svg("M-47,-6 L-52,-5 M-47,-4 L-52,-2"), Art.color(0xDDE2E6, 0.7), width: 0.8)
    }

    /// An iceberg standing on the water at `baseY`: a lit white face on the left, a blue
    /// shaded face on the right, clefts, and its foot in the water. `sharp` gives a tall
    /// pinnacled berg, otherwise a low rounded one.
    static func iceberg(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, width w: CGFloat, height h: CGFloat, sharp: Bool, seed: UInt32 = 1) {
        var random = ArtRandom(seed)
        let j: CGFloat = (Kit.rnd(&random) - 0.5) * 0.12
        let shape: Path
        let ridgeX: CGFloat
        if sharp {
            let pts: [CGPoint] = [
                Kit.pt(x - w * 0.5, baseY), Kit.pt(x - w * 0.38, baseY - h * 0.5), Kit.pt(x - w * 0.24, baseY - h * 0.58),
                Kit.pt(x - w * (0.1 + j), baseY - h), Kit.pt(x + w * 0.04, baseY - h * 0.84), Kit.pt(x + w * 0.16, baseY - h * 0.9),
                Kit.pt(x + w * 0.3, baseY - h * 0.48), Kit.pt(x + w * 0.42, baseY - h * 0.36), Kit.pt(x + w * 0.5, baseY)
            ]
            shape = Art.polygon(pts)
            ridgeX = x - w * (0.1 + j)
        } else {
            var p = Path()
            p.move(to: Kit.pt(x - w * 0.5, baseY))
            p.addQuadCurve(to: Kit.pt(x - w * 0.2, baseY - h), control: Kit.pt(x - w * 0.46, baseY - h * 0.9))
            p.addQuadCurve(to: Kit.pt(x + w * 0.22, baseY - h * 0.86), control: Kit.pt(x, baseY - h * 1.1))
            p.addQuadCurve(to: Kit.pt(x + w * 0.5, baseY), control: Kit.pt(x + w * 0.48, baseY - h * 0.7))
            p.closeSubpath()
            shape = p
            ridgeX = x - w * 0.05
        }
        Art.fill(&context, shape, Art.color(iceShadeHex))
        Art.clipped(&context, to: shape) { g in
            var face = Path()
            face.move(to: Kit.pt(x - w * 0.6, baseY - h * 1.2))
            face.addLine(to: Kit.pt(ridgeX, baseY - h * 1.2))
            face.addQuadCurve(to: Kit.pt(ridgeX + w * 0.08, baseY), control: Kit.pt(ridgeX - w * 0.06, baseY - h * 0.4))
            face.addLine(to: Kit.pt(x - w * 0.6, baseY))
            face.closeSubpath()
            Art.fill(&g, face, Art.color(0xFBFDFE))
            Art.glow(&g, x - w * 0.3, baseY - h * 0.8, w * 0.5, Art.color(0xFFF4DE), alpha: 0.5)
            let cleftA: Path = Art.line(ridgeX + w * 0.14, baseY - h * 0.7, ridgeX + w * 0.18, baseY - h * 0.15)
            let cleftB: Path = Art.line(x - w * 0.3, baseY - h * 0.35, x - w * 0.26, baseY - h * 0.05)
            Art.stroke(&g, cleftA, Art.color(0x7FA6C2, 0.7), width: max(1, w * 0.02))
            Art.stroke(&g, cleftB, Art.color(0xA9C6DA, 0.6), width: max(0.8, w * 0.012))
            Art.fill(&g, Art.rect(x - w, baseY - h * 0.08, w * 2, h * 0.08), Art.color(0x8FB4CC, 0.35))
        }
        ArtStyle.rimEdge(&context, shape, bounds: shape.boundingRect, width: 2, alpha: 0.5)
        let foot: Path = Art.ellipse(x, baseY + 1.5, w * 0.52, max(1.5, h * 0.05))
        Art.fill(&context, foot, Art.color(0x6F95B0, 0.35))
    }

    /// Small ovals of paw prints along a line from `a` to `b`, smaller toward `b`.
    static func pawPrints(_ context: inout GraphicsContext, from a: CGPoint, to b: CGPoint, count: Int, size: CGFloat) {
        var marks = Path()
        let n: Int = max(2, count)
        for i in 0..<n {
            let t: CGFloat = CGFloat(i) / CGFloat(n - 1)
            let x: CGFloat = a.x + (b.x - a.x) * t
            let side: CGFloat = i % 2 == 0 ? -1 : 1
            let y: CGFloat = a.y + (b.y - a.y) * t + side * size * 0.6
            let r: CGFloat = size * (1 - 0.6 * t)
            marks.addEllipse(in: CGRect(x: x - r, y: y - r * 0.45, width: r * 2, height: r * 0.9))
        }
        Art.fill(&context, marks, Art.color(0x9DB9CC, 0.45))
    }
}

// MARK: - The settlement

extension BearWomanArt {
    /// A winter house of stone and turf, half sunk into the slope, origin at the foot of its
    /// front wall: the turf roof (x −66…84, 46 high), the stone front with its gut-skin window,
    /// and the low entrance passage reaching out to the left (to x −106).
    static func turfHouse(_ context: inout GraphicsContext, window: Bool = true, seed: UInt32 = 3) {
        Kit.shadow(&context, -10, 1, width: 190, alpha: 0.18)
        let roof: Path = Art.svg("M-66,0 C-64,-26 -50,-44 -20,-46 L40,-46 C66,-44 80,-24 84,0 Z")
        Kit.solid(&context, roof, Art.color(turfHex), light: 0.26, shade: 0.24, rim: 2)
        Kit.grass(&context, in: CGRect(x: -52, y: -46, width: 120, height: 10), count: 14, seed: seed, color: Art.color(0x7C8452), height: 6)
        let snow: Path = Art.svg("M-30,-45 C-20,-49 8,-49 22,-46 C14,-42 -10,-41 -30,-45 Z M44,-40 C56,-40 70,-30 74,-20 C64,-26 54,-32 44,-40 Z")
        Art.fill(&context, snow, Art.color(0xF6F9FB))
        let wall: Path = Art.svg("M-52,0 L-50,-28 C-30,-31 30,-31 50,-28 L52,0 Z")
        Kit.solid(&context, wall, Art.color(0x8E8A80), light: 0.24, shade: 0.22)
        var stones = Path()
        let rows: [(CGFloat, CGFloat)] = [(-26, 0), (-17, 6), (-8, 0)]
        for row in rows {
            var sx: CGFloat = -48 + row.1
            while sx < 44 {
                stones.addRoundedRect(in: CGRect(x: sx, y: row.0, width: 13, height: 8), cornerSize: CGSize(width: 3, height: 3))
                sx += 15
            }
        }
        Art.stroke(&context, stones, Art.color(0x6A675F, 0.55), width: 1.1)
        if window {
            let pane: Path = Art.rect(-12, -25, 26, 15, radius: 3)
            Art.glow(&context, 1, -18, 30, Art.color(flameHex), alpha: 0.25)
            Art.fill(&context, pane, Art.color(0xF3E2B8))
            Art.stroke(&context, pane, Art.color(woodHex), width: 2)
            Art.stroke(&context, Art.line(1, -25, 1, -10), Art.color(0xD9C28E, 0.7), width: 1)
        }
        let passage: Path = Art.svg("M-46,0 C-48,-14 -60,-21 -78,-21 C-96,-21 -104,-12 -106,0 Z")
        Kit.solid(&context, passage, Art.color(0x958564), light: 0.26, shade: 0.24, rim: 2)
        Art.fill(&context, Art.svg("M-84,-20 C-76,-23 -62,-21 -54,-16 C-64,-17 -74,-18 -84,-20 Z"), Art.color(0xF6F9FB))
        let door: Path = Art.svg("M-101,0 C-101,-8 -95,-12.5 -89,-12.5 C-83,-12.5 -78,-8 -78,0 Z")
        Art.fill(&context, door, Art.color(0x3A2E2A, 0.85))
        Art.fill(&context, Art.rect(-112, -3, 200, 5, radius: 2.5), Art.color(0xF6F9FB, 0.9))
    }

    /// A slim sealskin kayak resting on a stand of two driftwood posts, harpoon and coiled line
    /// on its deck; origin on the ground under the middle; 124 long, deck at y −47.
    static func kayakOnStand(_ context: inout GraphicsContext) {
        Kit.shadow(&context, 0, 0, width: 110, alpha: 0.16)
        let posts: Path = Art.svg("M-38,0 L-37,-38 M38,0 L37,-38 M-44,-36 L-30,-36 M30,-36 L44,-36")
        Art.stroke(&context, posts, Art.color(woodHex), width: 4)
        kayak(&context, y: -40)
    }

    /// The kayak alone (bow to the LEFT, keel at `y`).
    static func kayak(_ context: inout GraphicsContext, y: CGFloat) {
        Art.group(&context, y: y) { g in
            let hull: Path = Art.svg("M-62,0 C-50,5 -20,7 0,7 C20,7 50,5 62,-2 C50,-6 20,-7 0,-7 C-20,-7 -50,-6 -62,0 Z")
            Kit.solid(&g, hull, Art.color(skinBoatHex), light: 0.28, shade: 0.24, rim: 1.6)
            Art.stroke(&g, Art.svg("M-60,-0.5 C-30,-5 30,-5.5 60,-2.5"), Art.color(0x9A7A52, 0.8), width: 1.2)
            Art.stroke(&g, Art.svg("M-30,4 C-10,5.5 20,5.5 40,3.5"), Art.color(0x9A7A52, 0.4), width: 1)
            Art.fill(&g, Art.ellipse(4, -6.4, 8, 2.2), Art.color(0x6A4C34))
            Art.stroke(&g, Art.line(-52, -7.5, 50, -9), Art.color(woodHex), width: 1.8)
            Art.fill(&g, Art.svg("M-52,-9 L-60,-7.6 L-52,-6 Z"), Art.color(0xEDE4D0))
            var coil = Path()
            coil.addEllipse(in: CGRect(x: 18, y: -11.5, width: 12, height: 4))
            coil.addEllipse(in: CGRect(x: 19.5, y: -11, width: 9, height: 3))
            Art.stroke(&g, coil, Art.color(0xC9B48A), width: 1.1)
        }
    }

    /// A drying rack of two posts and a bar hung with split fish; origin on the ground, 64 wide.
    static func dryingRack(_ context: inout GraphicsContext) {
        Kit.shadow(&context, 0, 0, width: 70, alpha: 0.14)
        let frame: Path = Art.svg("M-30,0 L-29,-52 M30,0 L29,-52 M-36,-48 L36,-48")
        Art.stroke(&context, frame, Art.color(woodHex), width: 3.2)
        for i in 0..<6 {
            let fx: CGFloat = -22 + CGFloat(i) * 9
            let fish: Path = Art.svg("M\(fx - 3),-48 L\(fx + 3),-48 L\(fx + 1.6),-30 L\(fx),-27 L\(fx - 1.6),-30 Z")
            let hex: UInt32 = i % 2 == 0 ? 0xB07048 : 0x9A5E3E
            Kit.solid(&context, fish, Art.color(hex), light: 0.25, shade: 0.2)
        }
    }

    /// A Greenland dog curled up resting, facing LEFT; origin on the ground; about 34 wide.
    static func restingDog(_ context: inout GraphicsContext, coat: UInt32, mirrored: Bool = false) {
        Kit.shadow(&context, 0, 0, width: 36, alpha: 0.18)
        let flip: CGFloat = mirrored ? -1 : 1
        Art.group(&context, scaleX: flip) { g in
            let body: Path = Art.svg("M-14,0 C-17,-10 -8,-16 2,-16 C12,-16 18,-9 16,0 Z")
            lit(&g, body, coat, mirrored: mirrored, rim: false)
            let tail: Path = Art.svg("M12,-10 C18,-18 8,-22 4,-15")
            Art.stroke(&g, tail, Kit.personTone(coat, 0.9), width: 4)
            let head: Path = Art.svg("M-20,-2 C-22,-8 -18,-13 -12,-13 C-7,-13 -5,-8 -6,-3 C-8,0 -18,1 -20,-2 Z")
            lit(&g, head, coat, mirrored: mirrored, rim: false)
            let ears: Path = Art.svg("M-17,-12 L-16,-17 L-13,-12.5 Z M-11,-12.5 L-9,-17 L-7.5,-11.5 Z")
            Art.fill(&g, ears, Kit.personTone(coat, 0.8))
            Art.fill(&g, Art.circle(-20, -4.5, 1.3), Art.color(noseHex))
        }
    }
}

// MARK: - Inside the house

extension BearWomanArt {
    /// The half-moon soapstone lamp, `w` wide; origin at the middle of its straight front edge
    /// (the flame line). A long low row of small flames, and its warm light.
    static func stoneLamp(_ context: inout GraphicsContext, width w: CGFloat, glow: Bool = true) {
        let half: CGFloat = w / 2
        if glow {
            Art.glow(&context, 0, -6, w * 2.2, Art.color(0xFFD98A), alpha: 0.42)
        }
        var bowl = Path()
        bowl.move(to: Kit.pt(-half, 0))
        bowl.addCurve(to: Kit.pt(half, 0), control1: Kit.pt(-half, w * 0.26), control2: Kit.pt(half, w * 0.26))
        bowl.closeSubpath()
        Kit.solid(&context, bowl, Art.color(0x8E8C84), light: 0.3, shade: 0.3, rim: 1.6)
        let rimShape: Path = Art.ellipse(0, -w * 0.06, half, w * 0.09)
        Art.fill(&context, rimShape, Art.color(0x9C9A92))
        Art.fill(&context, Art.ellipse(0, -w * 0.05, half * 0.86, w * 0.06), Art.color(0x6E5A36))
        Art.fill(&context, Art.ellipse(-half * 0.2, -w * 0.07, half * 0.4, w * 0.02), Art.color(0xE8C680, 0.5))
        let n: Int = max(5, Int(w / 9))
        var outer = Path()
        var inner = Path()
        for i in 0..<n {
            let t: CGFloat = (CGFloat(i) + 0.5) / CGFloat(n)
            let fx: CGFloat = -half * 0.82 + half * 1.64 * t
            let fh: CGFloat = w * (0.1 + 0.03 * sin(CGFloat(i) * 1.7))
            outer.addPath(Kit.propFlame(fx, -w * 0.02, w * 0.07, fh, -0.15))
            inner.addPath(Kit.propFlame(fx, -w * 0.02, w * 0.035, fh * 0.55, -0.1))
        }
        Art.fill(&context, outer, Art.color(flameHex))
        Art.fill(&context, inner, Art.color(0xFFF2C6))
    }

    /// A spread of sealskins over a platform top from `x0` to `x1` at `y`, `depth` deep.
    static func skins(_ context: inout GraphicsContext, x0: CGFloat, x1: CGFloat, y: CGFloat, depth: CGFloat, seed: UInt32 = 9) {
        var random = ArtRandom(seed)
        var x: CGFloat = x0
        var i: Int = 0
        while x < x1 {
            let span: CGFloat = 70 + Kit.rnd(&random) * 40
            let lift: CGFloat = 3 + Kit.rnd(&random) * 4
            var hide = Path()
            hide.move(to: Kit.pt(x - 6, y + depth))
            hide.addQuadCurve(to: Kit.pt(x + span * 0.5, y - lift), control: Kit.pt(x, y - lift))
            hide.addQuadCurve(to: Kit.pt(x + span + 6, y + depth), control: Kit.pt(x + span, y - lift))
            hide.closeSubpath()
            let hex: UInt32 = i % 2 == 0 ? 0x9E866A : 0xB49C7C
            Kit.solid(&context, hide, Art.color(hex), light: 0.24, shade: 0.2, rim: 1.4)
            x += span * 0.82
            i += 1
        }
        Art.stipple(&context, in: CGRect(x: x0, y: y - 4, width: x1 - x0, height: depth), count: 120, seed: seed &+ 3, color: Art.color(0x5E4A36), alpha: 0.12)
    }

    /// The drying rack of wooden rods over the lamp, `w` wide, hung with a pair of kamiks and
    /// a mitten; origin at the middle of the rack.
    static func lampRack(_ context: inout GraphicsContext, width w: CGFloat) {
        let half: CGFloat = w / 2
        var rods = Path()
        rods.move(to: Kit.pt(-half, 0))
        rods.addLine(to: Kit.pt(half, -2))
        rods.move(to: Kit.pt(-half + 6, 6))
        rods.addLine(to: Kit.pt(half - 6, 4))
        Art.stroke(&context, rods, Art.color(woodHex), width: 3)
        let cords: Path = Art.svg("M\(-half + 4),0 L\(-half + 10),-60 M\(half - 4),-2 L\(half - 10),-60")
        Art.stroke(&context, cords, Art.color(0xB8A57E, 0.5), width: 1.2)
        let kamik: Path = Art.svg("M-4,0 L4,0 L4,26 C4,32 0,34 -6,34 L-14,34 C-16,30 -12,27 -4,26 Z")
        Art.group(&context, x: -half * 0.45, y: 2) { g in
            Kit.solid(&g, kamik, Art.color(0x7A5A3E), light: 0.24, shade: 0.22)
        }
        Art.group(&context, x: -half * 0.45 + 13, y: 2) { g in
            Kit.solid(&g, kamik, Art.color(0x84624A), light: 0.24, shade: 0.22)
        }
        let mitten: Path = Art.svg("M-6,0 L6,0 L7,14 C7,20 3,22 -1,22 C-5,22 -7,18 -7,14 Z M-7,9 C-11,9 -12,14 -8,16 Z")
        Art.group(&context, x: half * 0.4, y: 3) { g in
            Kit.solid(&g, mitten, Art.color(0x9E866A), light: 0.24, shade: 0.22)
        }
    }

    /// A bundle of meat with its layer of blubber, tied with a cord; origin on the ground, 40 wide.
    static func meatBundle(_ context: inout GraphicsContext, seed: UInt32) {
        var random = ArtRandom(seed)
        let lean: CGFloat = (Kit.rnd(&random) - 0.5) * 4
        Kit.shadow(&context, 0, 0, width: 42, alpha: 0.24)
        let blubber: Path = Art.svg("M-20,0 C-21,-8 -16,-12 -8,-12 L10,-12 C17,-12 21,-8 20,0 Z")
        Kit.solid(&context, blubber, Art.color(0xF0E2C4), light: 0.3, shade: 0.2, rim: 1.4)
        var meat = Path()
        meat.move(to: Kit.pt(-17, -9))
        meat.addCurve(to: Kit.pt(17, -9), control1: Kit.pt(-16, -26 + lean), control2: Kit.pt(16, -26 - lean))
        meat.closeSubpath()
        Kit.solid(&context, meat, Art.color(0x8A3E2E), light: 0.26, shade: 0.24, rim: 1.4)
        let cord: Path = Art.svg("M-2,-21 C-3,-14 -3,-6 -2,0 M-17,-6 C-6,-8 6,-8 18,-6")
        Art.stroke(&context, cord, Art.color(0xD8C79C), width: 1.8)
    }
}
