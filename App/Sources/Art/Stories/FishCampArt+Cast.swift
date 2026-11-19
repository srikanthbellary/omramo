import SwiftUI
import OmramoCore

// The cast and the shared parts of "The Long Day at Fish Camp": palette, the two pale evening
// lights, Nick, Grandma, old Lena and Uncle Joe, and the things of a present-day Yup'ik summer
// fish camp (salmon, drying rack, plywood cabins, skiff, uluaq). Summer only: no snow anywhere.

// MARK: - Palette and light

extension FishCampArt {
    static let ramp = ArtStyle.Ramp(deep: 0x1B2E44, shade: 0x5E6F5A, mid: 0x9DB07A, light: 0xFCE9C4, glow: 0xFFD08A, accent: 0xC8442E)

    static let tarpBlue: UInt32 = 0x2F7FC4
    static let salmonRed: UInt32 = 0xC8442E
    static let plywood: UInt32 = 0xCDB68E
    static let greyBoard: UInt32 = 0x9C9A90
    static let aluminium: UInt32 = 0xB9C3C7
    static let peeledPole: UInt32 = 0xDCCBA4
    static let mud: UInt32 = 0x9A9284
    static let grassGreen: UInt32 = 0x7F9A5E
    static let bootBrown: UInt32 = 0x7A5638
    static let bootGreen: UInt32 = 0x4F5F40
    static let capFaded: UInt32 = 0x8C9C8E

    /// The long gold evening at the family's camp and out on the river.
    static func evening() -> Kit.Light {
        let sky: Kit.Stops = [
            (Art.color(0xFDF2D6), 0), (Art.color(0xFCE7C0), 0.5), (Art.color(0xF9D4AA), 0.85), (Art.color(0xFFD08A), 1),
        ]
        return Kit.Light(sky: sky, sun: 0xFFF6DE, glow: 0xFFD08A, haze: 0xF9D9B6, far: 0xB9C5A2, mid: 0x9DB07A, near: 0x74905E)
    }

    /// The peach hour near midnight on the bank path and at Lena's cabin. Still pale.
    static func peach() -> Kit.Light {
        let sky: Kit.Stops = [
            (Art.color(0xFDEBD6), 0), (Art.color(0xFBDCC2), 0.5), (Art.color(0xF8C4A6), 0.85), (Art.color(0xFFC890), 1),
        ]
        return Kit.Light(sky: sky, sun: 0xFFF1DC, glow: 0xFFC890, haze: 0xF8CDB2, far: 0xB4BE9E, mid: 0x93A774, near: 0x6F8A5C)
    }

    /// The wide silty river: silver-brown under the sky, tea-brown toward the viewer.
    static func riverStops() -> Kit.Stops {
        [(Art.color(0xD9C7A4), 0), (Art.color(0xAE9B7C), 0.45), (Art.color(0x8A785E), 1)]
    }

    static func grassStops() -> Kit.Stops {
        [(Art.color(0xA9BA82), 0), (Art.color(0x8DA667), 0.5), (Art.color(0x6F8C54), 1)]
    }

    /// Scrub willow: grey-green.
    static func willowGreens() -> Kit.Greens {
        Kit.greens(0x3F5A40, 0x587A50, 0x7C9A62, 0xA6BD7C, 0xD4E0A0)
    }
}

// MARK: - Looks

extension FishCampArt {
    static func nickLook() -> Kit.Person {
        Kit.Person(
            age: .child, skin: 0xC38C64, hair: 0x1E1A1C, hairStyle: .short, headwear: .none,
            garment: .shirtTrousers, cloth: 0x2F6FA8, trim: 0x24598A, legs: 0x2E3A46, showsEyeWhite: false
        )
    }

    static func grandmaLook() -> Kit.Person {
        Kit.Person(
            age: .adult, skin: 0xBB855E, hair: 0x4A4648, hairStyle: .short, headwear: .kerchief, headwearColor: 0x3F6CA6,
            garment: .tunic, cloth: 0x5F90C6, trim: 0x3F6FA0, legs: 0x3A4048, showsEyeWhite: false
        )
    }

    static func lenaLook() -> Kit.Person {
        Kit.Person(
            age: .elder, skin: 0xBA8A68, hair: 0xF2EFEA, hairStyle: .short, headwear: .kerchief, headwearColor: 0xC9708C,
            garment: .tunic, cloth: 0xB9A6D0, trim: 0x9987B6, legs: 0x4A4650, showsEyeWhite: false
        )
    }

    static func uncleLook() -> Kit.Person {
        Kit.Person(
            age: .adult, skin: 0xB67F58, hair: 0x1E1A1C, hairStyle: .short, headwear: .none,
            garment: .shirtTrousers, cloth: 0xE8862E, trim: 0xC96A1E, legs: 0x3A4048, showsEyeWhite: false
        )
    }
}

// MARK: - Figure tools (a kit person in a pose of this story's own)

extension FishCampArt {
    /// A kit person drawn with a rig of our own: origin at the feet, facing LEFT.
    static func figure(_ g: inout GraphicsContext, _ p: Kit.Person, _ r: Kit.BodyRig, look: CGPoint, mouth: Kit.Mouth, mirrored: Bool) {
        let f = Kit.bodyFrame(p)
        Art.group(&g, scale: f.k) { b in
            Kit.bodyFigure(&b, p, r, mirrored: mirrored)
        }
        let c = Kit.bodyHeadCentre(f, r)
        let tilt: CGFloat = -Kit.deg(r.lean) * 0.45
        Art.group(&g, x: c.x, y: c.y, rotate: tilt, scale: f.headScale) { h in
            Kit.personHead(&h, p, look: look, mouth: mouth, closedEyes: false, mirrored: mirrored)
        }
    }

    /// Draws `body` in head units (skull 52 × 56 round the origin) on the head of a posed person.
    static func onHead(_ g: inout GraphicsContext, _ p: Kit.Person, _ r: Kit.BodyRig, _ body: (inout GraphicsContext) -> Void) {
        let f = Kit.bodyFrame(p)
        let c = Kit.bodyHeadCentre(f, r)
        let tilt: CGFloat = -Kit.deg(r.lean) * 0.45
        let s: CGFloat = p.age == .child ? f.headScale * 0.9 : f.headScale
        Art.group(&g, x: c.x, y: c.y, rotate: tilt, scale: s, body)
    }

    /// Draws `body` in torso units (hips at the origin, shoulders at y −54, 44 wide).
    static func onTorso(_ g: inout GraphicsContext, _ p: Kit.Person, _ r: Kit.BodyRig, _ body: (inout GraphicsContext) -> Void) {
        let f = Kit.bodyFrame(p)
        let x: CGFloat = r.hip.x * f.k
        let y: CGFloat = r.hip.y * f.k
        Art.group(&g, x: x, y: y, rotate: -Kit.deg(r.lean), scale: f.k, body)
    }

    /// The leading hand of a posed person, in the person's own units.
    static func handPoint(_ p: Kit.Person, _ r: Kit.BodyRig) -> CGPoint {
        let f = Kit.bodyFrame(p)
        let s = Kit.bodyShoulder(r, near: true)
        let x: CGFloat = (s.x + r.nearHand.x) * f.k
        let y: CGFloat = (s.y + r.nearHand.y) * f.k
        return CGPoint(x: x, y: y)
    }

    /// Knee-high rubber boots over the kit's legs.
    static func rubberBoots(_ g: inout GraphicsContext, _ p: Kit.Person, _ r: Kit.BodyRig, hex: UInt32) {
        let f = Kit.bodyFrame(p)
        let legs: [(CGPoint, CGPoint, CGFloat)] = [(r.farKnee, r.farFoot, 0.82), (r.nearKnee, r.nearFoot, 1)]
        let back: Bool = r.feetBack
        Art.group(&g, scale: f.k) { b in
            for leg in legs {
                let top = Kit.bodyMix(leg.0, leg.1, 0.22)
                let foot = leg.1
                let shaft = Art.line(top.x, top.y, foot.x, foot.y)
                Art.stroke(&b, shaft, Kit.personTone(hex, leg.2), width: 12.8)
                Art.stroke(&b, Art.line(top.x - 5, top.y, top.x + 5, top.y), Kit.personTone(hex, 1.25 * leg.2), width: 2.2)
                Art.group(&b, x: foot.x, y: foot.y + 3, scaleX: back ? -1 : 1) { s in
                    Art.fill(&s, Art.svg(Kit.bodyShoe), Kit.personTone(hex, 0.8 * leg.2))
                }
            }
        }
    }

    /// The hood of a hoodie or a qaspeq lying behind the neck. Draw it before the figure.
    static func hoodBack(_ g: inout GraphicsContext, _ p: Kit.Person, _ r: Kit.BodyRig) {
        let tone = Kit.personTone(p.cloth, 0.86)
        onTorso(&g, p, r) { t in
            Art.fill(&t, Art.ellipse(12, -55, 14, 8), tone)
            Art.fill(&t, Art.ellipse(-10, -55, 10, 6), tone)
        }
    }

    /// Small flowers printed on the cotton of a qaspeq.
    static func flowerDots(_ g: inout GraphicsContext, _ p: Kit.Person, _ r: Kit.BodyRig, skirt: Bool, petal: UInt32) {
        let upper: [(CGFloat, CGFloat)] = [
            (-14, -46), (-4, -42), (8, -47), (16, -38), (-10, -33), (2, -30), (13, -26), (-16, -22), (-5, -19), (7, -15), (17, -12), (-12, -8),
        ]
        let lower: [(CGFloat, CGFloat)] = [(-15, 6), (-4, 2), (8, 7), (17, 3), (-9, 15), (3, 18), (14, 16), (-17, 22)]
        var dots = Path()
        var hearts = Path()
        for spot in upper {
            dots.addPath(Art.circle(spot.0, spot.1, 1.7))
            hearts.addPath(Art.circle(spot.0, spot.1, 0.6))
        }
        if skirt {
            for spot in lower {
                dots.addPath(Art.circle(spot.0, spot.1, 1.7))
                hearts.addPath(Art.circle(spot.0, spot.1, 0.6))
            }
        }
        let petals = dots
        let middles = hearts
        onTorso(&g, p, r) { t in
            Art.fill(&t, petals, Art.color(petal, 0.9))
            Art.fill(&t, middles, Art.color(0xFFD08A))
        }
    }

    /// A faded baseball cap, in head units: the crown over the hair, the bill over the brow.
    static func capShape(_ h: inout GraphicsContext, hex: UInt32) {
        let crown: Path = Art.svg("M-27.5,-11 C-31,-31 -15,-40 0,-40 C15,-40 31,-31 27.5,-11 C18,-19 -18,-19 -27.5,-11Z")
        Kit.solid(&h, crown, Art.color(hex), light: 0.22, shade: 0.2)
        let seams: Path = Art.svg("M0,-40 L0,-17 M-13,-37 C-17,-30 -18,-23 -17,-16 M13,-37 C17,-30 18,-23 17,-16")
        Art.stroke(&h, seams, Kit.personTone(hex, 0.78), width: 1)
        Art.fill(&h, Art.ellipse(0, -40, 3, 1.8), Kit.personTone(hex, 0.78))
        let bill: Path = Art.svg("M-30,-14 C-20,-22 16,-22.5 27,-15.5 C16,-15.5 -14,-14 -34,-9 C-37,-10 -35,-13 -30,-14Z")
        Kit.solid(&h, bill, Kit.personTone(hex, 0.8), light: 0.2, shade: 0.24)
        let under: Path = Art.svg("M-33,-8.4 C-14,-13 16,-14.6 26,-14.8")
        Art.stroke(&h, under, ArtStyle.coolShade.opacity(0.22), width: 1.6)
    }

    /// Lena's glasses and the white hair at her brow, in head units.
    static func glasses(_ h: inout GraphicsContext) {
        Art.stroke(&h, Art.svg("M-13,-19 C-6,-22 6,-22 13,-19"), Art.color(0xF6F3EE), width: 3)
        var rims = Path()
        rims.addPath(Art.ellipse(-9.5, 2, 7.2, 6.4))
        rims.addPath(Art.ellipse(9.5, 2, 7.2, 6.4))
        Art.fill(&h, rims, Color.white.opacity(0.16))
        Art.stroke(&h, rims, Art.color(0x6A5560), width: 1.3)
        Art.stroke(&h, Art.svg("M-2.4,1 Q0,-1 2.4,1 M-16.6,1 L-23,-1 M16.6,1 L23,-1"), Art.color(0x6A5560), width: 1.2)
    }

    /// Small white flowers on Grandma's blue headscarf, in head units.
    static func scarfDots(_ h: inout GraphicsContext) {
        let spots: [(CGFloat, CGFloat)] = [(-13, -31), (1, -33), (14, -30), (-23, -21), (23, -20), (-6, -25.5), (8, -25), (-27, -8), (27, -7)]
        var dots = Path()
        for spot in spots {
            dots.addPath(Art.circle(spot.0, spot.1, 1.5))
        }
        Art.fill(&h, dots, Color.white.opacity(0.9))
    }
}

// MARK: - Nick

extension FishCampArt {
    enum NickAct { case stand, bucket, haul, hug, walkHug }
    enum GrandmaAct { case stand, cut }

    static func nickRig(_ act: NickAct) -> Kit.BodyRig {
        let p = nickLook()
        switch act {
        case .stand:
            return Kit.bodyRig(p, .stand)
        case .bucket:
            var r = Kit.bodyRig(p, .walk)
            r.nearElbow = Kit.pt(-3, 22)
            r.nearHand = Kit.pt(-7, 43)
            return r
        case .haul:
            // Braced in the skiff, leaning back against the net, both fists forward.
            var r = Kit.bodyRig(p, .stand)
            r.lean = -10
            r.nearKnee = Kit.pt(-14, -30)
            r.nearFoot = Kit.pt(-21, -3)
            r.farKnee = Kit.pt(12, -30)
            r.farFoot = Kit.pt(18, -3)
            r.nearElbow = Kit.pt(-14, 16)
            r.nearHand = Kit.pt(-30, 26)
            r.farElbow = Kit.pt(-26, 14)
            r.farHand = Kit.pt(-62, 22)
            return r
        case .hug:
            var r = Kit.bodyRig(p, .stand)
            nickHugArms(&r)
            return r
        case .walkHug:
            var r = Kit.bodyRig(p, .walk)
            nickHugArms(&r)
            return r
        }
    }

    static func nickHugArms(_ r: inout Kit.BodyRig) {
        r.nearElbow = Kit.pt(-6, 22)
        r.nearHand = Kit.pt(10, 30)
        r.farElbow = Kit.pt(-20, 20)
        r.farHand = Kit.pt(-52, 24)
    }

    /// Where Nick's leading fist is for `act`, in his own units (origin at his feet).
    static func nickHand(_ act: NickAct) -> CGPoint {
        handPoint(nickLook(), nickRig(act))
    }

    /// Nick, nine: blue hoodie, faded cap, dark rain pants, brown rubber boots. Origin at the
    /// feet, 126 tall, facing LEFT. `hug` and `walkHug` put the grass-wrapped salmon in his
    /// arms; `bucket` a bucket of strips in his hand; `vest` a life jacket (in the skiff).
    static func nick(
        _ g: inout GraphicsContext,
        act: NickAct,
        look: CGPoint = .zero,
        mouth: Kit.Mouth = .smile,
        mirrored: Bool = false,
        vest: Bool = false
    ) {
        let p = nickLook()
        let r = nickRig(act)
        let hugging: Bool = act == .hug || act == .walkHug
        hoodBack(&g, p, r)
        figure(&g, p, r, look: look, mouth: mouth, mirrored: mirrored)
        rubberBoots(&g, p, r, hex: bootBrown)
        if vest {
            onTorso(&g, p, r) { t in
                lifeVest(&t)
            }
        } else if !hugging {
            let trim = Art.color(p.trim)
            onTorso(&g, p, r) { t in
                Art.stroke(&t, Art.svg("M-12,-23 L10,-23 L13,-9 L-15,-9Z"), trim, width: 1.4)
                Art.stroke(&t, Art.svg("M-6,-50 L-7,-38 M3,-50 L4,-39"), Art.color(0xE8EEF4), width: 1.3)
            }
        }
        onHead(&g, p, r) { h in
            capShape(&h, hex: capFaded)
        }
        if hugging {
            nickBundle(&g, p)
        }
        if act == .bucket {
            let hand = handPoint(p, r)
            Art.group(&g, x: hand.x, y: hand.y + 25) { b in
                bucket(&b, strips: true)
            }
            Art.fill(&g, Art.circle(hand.x, hand.y, 3.9), Art.color(p.skin))
        }
    }

    /// The grass-wrapped salmon against Nick's chest, with his forearm and both hands over it.
    static func nickBundle(_ g: inout GraphicsContext, _ p: Kit.Person) {
        let f = Kit.bodyFrame(p)
        let sleeve = Art.color(p.cloth)
        let cuff = Kit.personTone(p.cloth, 0.8)
        let skin = Art.color(p.skin)
        let skinFar = Kit.personTone(p.skin, 0.88)
        Art.group(&g, scale: f.k) { b in
            Art.group(&b, x: -10, y: -80, rotate: Kit.deg(-10), scale: 0.8) { s in
                bundle(&s)
            }
            Art.stroke(&b, Art.svg("M-24,-86 Q-21,-70 -8,-73"), sleeve, width: 11)
            Art.stroke(&b, Art.line(-12.5, -76.5, -10.5, -68), cuff, width: 2.4)
            Art.fill(&b, Art.circle(-6, -73, 5.6), skin)
            Art.fill(&b, Art.circle(-38, -79, 5.2), skinFar)
            Art.stroke(&b, Art.line(-34, -84, -32, -75), cuff, width: 2.4)
        }
    }

    /// A life jacket over the torso, in torso units.
    static func lifeVest(_ t: inout GraphicsContext) {
        let vest: Path = Art.svg("M-15,-53 L-6,-53 Q-2,-44 3,-53 L13,-53 Q21,-52 21,-44 L20,-12 Q2,-7 -17,-12 L-17,-44Z")
        Kit.solid(&t, vest, Art.color(0xD9523A), light: 0.24, shade: 0.2)
        Art.stroke(&t, Art.line(2, -47, 2, -10), Art.color(0x9E3324), width: 1.4)
        Art.stroke(&t, Art.svg("M-17,-38 L20.5,-38 M-17,-23 L20,-23"), Art.color(0x26323E), width: 2.6, cap: .butt)
        var buckles = Path()
        buckles.addPath(Art.rect(-1, -40.4, 6, 4.8, radius: 1))
        buckles.addPath(Art.rect(-1, -25.4, 6, 4.8, radius: 1))
        Art.fill(&t, buckles, Art.color(0xE9E4D6))
    }
}

// MARK: - Grandma, Lena, Uncle Joe

extension FishCampArt {
    static func grandmaRig(_ act: GrandmaAct) -> Kit.BodyRig {
        let p = grandmaLook()
        var r = Kit.bodyRig(p, .stand)
        switch act {
        case .stand:
            r.nearElbow = Kit.pt(-8, 20)
            r.nearHand = Kit.pt(-16, 38)
        case .cut:
            r.lean = 6
            r.nearElbow = Kit.pt(-10, 20)
            r.nearHand = Kit.pt(-26, 30)
            r.farElbow = Kit.pt(-16, 22)
            r.farHand = Kit.pt(-46, 44)
        }
        return r
    }

    /// Grandma: flowered blue qaspeq with its hood, an apron, a flowered headscarf, green
    /// rubber boots, the uluaq in her fist. Origin at the feet, 168 tall, facing LEFT. For
    /// `cut` her fist is over a table whose top is 58 units above the ground.
    static func grandma(
        _ g: inout GraphicsContext,
        act: GrandmaAct,
        look: CGPoint = .zero,
        mouth: Kit.Mouth = .smile,
        mirrored: Bool = false
    ) {
        let p = grandmaLook()
        let r = grandmaRig(act)
        hoodBack(&g, p, r)
        figure(&g, p, r, look: look, mouth: mouth, mirrored: mirrored)
        rubberBoots(&g, p, r, hex: bootGreen)
        flowerDots(&g, p, r, skirt: true, petal: 0xFFFFFF)
        let cream = Art.color(0xF3EAD6)
        let creamDark = Art.color(0xD6C8AC)
        onTorso(&g, p, r) { t in
            let apron: Path = Art.svg("M-9,-44 L7,-44 L9,-12 L13,-12 L15,25 L-18,25 L-15,-12 L-11,-12Z")
            Kit.solid(&t, apron, cream, light: 0.16, shade: 0.16)
            Art.stroke(&t, Art.svg("M-9,-44 L-11,-54 M7,-44 L9,-54"), cream, width: 2.4)
            Art.stroke(&t, Art.line(-19, -12, 17, -12), creamDark, width: 2.2)
            Art.stroke(&t, Art.svg("M-4,-4 L-5,22 M6,-4 L7,22"), creamDark, width: 1)
        }
        onHead(&g, p, r) { h in
            scarfDots(&h)
        }
        let hand = handPoint(p, r)
        Art.group(&g, x: hand.x, y: hand.y + 2, scale: 0.55) { u in
            uluaq(&u)
        }
    }

    static func lenaRig() -> Kit.BodyRig {
        var r = Kit.bodyRig(lenaLook(), .sit)
        r.nearElbow = Kit.pt(-4, 22)
        r.nearHand = Kit.pt(-22, 30)
        r.farElbow = Kit.pt(-14, 22)
        r.farHand = Kit.pt(-52, 28)
        return r
    }

    /// Old Lena sitting, the enamel mug in both hands: faded lilac qaspeq, an oatmeal cardigan,
    /// a plain rose headscarf, glasses. Origin on the ground under her seat (the caller draws
    /// the step, 34 high), facing LEFT. Her head centre is at about (0, −123).
    static func lena(_ g: inout GraphicsContext, look: CGPoint = .zero, mouth: Kit.Mouth = .smile) {
        let p = lenaLook()
        let r = lenaRig()
        hoodBack(&g, p, r)
        figure(&g, p, r, look: look, mouth: mouth, mirrored: false)
        rubberBoots(&g, p, r, hex: bootBrown)
        flowerDots(&g, p, r, skirt: false, petal: 0xFFF4F8)
        let wool = Art.color(0xE2D2B0)
        let woolDark = Art.color(0xBFAE8A)
        onTorso(&g, p, r) { t in
            let left: Path = Art.svg("M-22,-46 Q-22,-54 -13,-54 L-7,-54 L-9,-1 Q-15,0 -20,0Z")
            let right: Path = Art.svg("M22,-46 Q22,-54 13,-54 L6,-54 L8,-1 Q15,0 20,0Z")
            Kit.solid(&t, left, wool, light: 0.2, shade: 0.14)
            Kit.solid(&t, right, wool, light: 0.12, shade: 0.2)
            Art.stroke(&t, Art.svg("M-8,-54 L-9.6,-1 M7,-54 L8.6,-1"), woolDark, width: 1.4)
            Art.stroke(&t, Art.rect(-6.5, -24, 12, 10, radius: 2), Art.color(p.trim), width: 1.2)
        }
        onHead(&g, p, r) { h in
            glasses(&h)
        }
        let hand = handPoint(p, r)
        Art.group(&g, x: hand.x - 2, y: hand.y - 3) { m in
            mug(&m, steam: true)
        }
        Art.fill(&g, Art.circle(hand.x - 8, hand.y + 3, 4.6), Kit.personTone(p.skin, 0.88))
        Art.fill(&g, Art.circle(hand.x + 4, hand.y + 2, 5), Art.color(p.skin))
    }

    /// Uncle Joe at the outboard: small, sitting, in an orange rain jacket and a dark cap.
    /// Origin on the floor of the skiff under his seat, facing LEFT.
    static func uncle(_ g: inout GraphicsContext) {
        let p = uncleLook()
        let r = Kit.bodyRig(p, .sit)
        figure(&g, p, r, look: CGPoint(x: -0.6, y: 0), mouth: .smile, mirrored: false)
        onHead(&g, p, r) { h in
            capShape(&h, hex: 0x3A4A5A)
        }
    }
}

// MARK: - The salmon, the bundle, the uluaq

extension FishCampArt {
    /// A king salmon fresh from the river: silver sides, a blue-green back with small dark
    /// spots. Origin at its middle, head to the LEFT, 100 long (x −50…50), about 26 deep.
    static func salmon(_ g: inout GraphicsContext) {
        let fins: Path = Art.svg("M-6,-11.5 L5,-18.5 L11,-10.5Z M24,-7 L29,-10.5 L31,-5.5Z M-2,11.5 L5,17.5 L10,11Z M20,8.5 L27,13.5 L31,6Z M-30,9 L-24,15 L-20,10.5Z")
        Art.fill(&g, fins, Art.color(0x7F9AA0))
        let body: Path = Art.svg("M-50,1 C-44,-9 -28,-13 -8,-12 C12,-11 30,-7 40,-2 L50,-11 C47.5,-3 47.5,5 50,13 L40,3.5 C28,9 10,12 -10,12 C-30,12 -44,8 -50,1Z")
        let silver: Kit.Stops = [
            (Art.color(0x4F7F86), 0), (Art.color(0xA9BEC2), 0.3), (Art.color(0xE6ECEA), 0.62), (Art.color(0xF6F5EE), 1),
        ]
        Kit.solid(&g, body, stops: silver, light: 0.3, shade: 0.14, rim: 1.2)
        let places: [(CGFloat, CGFloat)] = [
            (-30, -8), (-21, -9.4), (-11, -9.8), (-1, -9.4), (9, -8.4), (19, -6.8), (28, -4.8), (-26, -5.4), (-6, -6.2), (14, -4.8),
        ]
        var spots = Path()
        for place in places {
            spots.addPath(Art.circle(place.0, place.1, 0.9))
        }
        Art.fill(&g, spots, Art.color(0x1B2E44, 0.7))
        Art.stroke(&g, Art.svg("M-36,0.5 C-16,-1.5 14,-0.5 39,0.5"), Art.color(0x8FA6AC, 0.7), width: 0.9)
        Art.stroke(&g, Art.svg("M-37.5,-8 C-33.5,-2 -33.5,4 -37.5,9"), Art.color(0x6F8A90), width: 1.2)
        Art.stroke(&g, Art.svg("M42,-2.5 L48,-8 M42.5,0.6 L48,1 M42,3.4 L48,9.5"), Art.color(0x6F8A90, 0.7), width: 0.8)
        Art.stroke(&g, Art.svg("M-50,1.2 L-43.5,3.4"), Art.color(0x1B2E44), width: 1.1)
        ArtStyle.eye(&g, -43.5, -2.4, 2, showsWhite: false)
    }

    /// The first catch wrapped in long wet grass, head and tail showing. Same frame as `salmon`.
    static func bundle(_ g: inout GraphicsContext) {
        salmon(&g)
        let tips: Path = Art.svg("M-29,-10 L-40,-16 M-29,-1 L-42,1 M-29,9 L-39,15 M29,-5 L39,-11 M29,6 L40,10")
        Art.stroke(&g, tips, Art.color(0x7FA85A), width: 1.8)
        let wrap: Path = Art.svg("M-30,-14 C-10,-17.5 14,-15.5 30,-8.5 L30,8.5 C14,15 -10,16 -30,13.5Z")
        let green: Kit.Stops = [(Art.color(0x8DB864), 0), (Art.color(0x6E9A4E), 0.55), (Art.color(0x4F7A3E), 1)]
        Kit.solid(&g, wrap, stops: green, light: 0.24, shade: 0.2)
        let blades: Path = Art.svg("M-30,-9 C-10,-12 12,-10 30,-4 M-30,-3 C-10,-6 12,-4 30,1 M-30,3 C-10,1 12,3 30,5 M-30,9 C-10,9 12,10 30,7.5")
        let lit: Path = Art.svg("M-28,-12 C-10,-15 10,-13 28,-7 M-24,0 C-8,-2 8,-1 24,2")
        Art.clipped(&g, to: wrap) { c in
            Art.stroke(&c, blades, Art.color(0x3F6A34, 0.75), width: 1.1)
            Art.stroke(&c, lit, Art.color(0xC4E08A, 0.8), width: 1.1)
        }
        let ties: Path = Art.svg("M-13,-16.5 C-10,-5 -10,6 -13,15.5 M11,-15 C14,-5 14,5 11,13")
        Art.stroke(&g, ties, Art.color(0xA9CC78), width: 2)
    }

    /// The uluaq, a kitchen knife for fish: a broad crescent of steel with a short handle
    /// fixed across the top. Origin at the middle of the handle; 32 across, blade down.
    static func uluaq(_ g: inout GraphicsContext) {
        Art.fill(&g, Art.rect(-2.4, 2, 4.8, 8), Art.color(0x8E979C))
        let blade: Path = Art.svg("M-16,8 L16,8 C16,20 8,27 0,27 C-8,27 -16,20 -16,8Z")
        let steel: Kit.Stops = [(Art.color(0xDDE4E6), 0), (Art.color(0xB4BFC4), 1)]
        Kit.solid(&g, blade, stops: steel, light: 0.3, shade: 0.18)
        Art.stroke(&g, Art.svg("M-15,13 C-13,21 -7,26 0,26.2 C7,26 13,21 15,13"), Color.white.opacity(0.7), width: 1.2)
        let handle: Path = Art.rect(-10, -4.5, 20, 8, radius: 3.5)
        Kit.solid(&g, handle, Art.color(0x8A5A3A), light: 0.26, shade: 0.22)
    }

    /// One open side of salmon lying on the planks: red-orange flesh. 44 long round the origin.
    static func fillet(_ g: inout GraphicsContext) {
        let side: Path = Art.svg("M-22,0 C-14,-6.5 10,-6.5 22,-1.5 C10,4 -14,5 -22,0Z")
        Kit.solid(&g, side, Art.color(0xDA5A38), light: 0.26, shade: 0.16)
        Art.stroke(&g, Art.svg("M-14,-3 L-12,2.4 M-7,-4 L-5,3 M0,-4.4 L2,3 M7,-4 L9,2.2 M14,-3 L15,1"), Art.color(0xF2A07A, 0.8), width: 0.9)
        Art.stroke(&g, Art.svg("M-21,0 C-12,3.6 10,3.4 21,-1"), Art.color(0x8FA6AC), width: 1.1)
    }
}

// MARK: - The drying rack

extension FishCampArt {
    /// One row of salmon strips hanging from a rail at `y`, from `x0` to `x1`.
    static func strips(_ g: inout GraphicsContext, x0: CGFloat, x1: CGFloat, y: CGFloat, length: CGFloat, seed: UInt32) {
        guard x1 > x0, length > 0 else { return }
        var random = ArtRandom(seed)
        var first = Path()
        var second = Path()
        var third = Path()
        var fourth = Path()
        var x: CGFloat = x0
        var index: Int = 0
        while x < x1 {
            let l: CGFloat = length * (0.78 + Kit.rnd(&random) * 0.22)
            let sway: CGFloat = (Kit.rnd(&random) - 0.5) * 1.6
            var strip = Path()
            strip.move(to: CGPoint(x: x, y: y - 1))
            strip.addLine(to: CGPoint(x: x + 4.2, y: y - 1))
            strip.addLine(to: CGPoint(x: x + 3.6 + sway, y: y + l))
            strip.addLine(to: CGPoint(x: x + 0.8 + sway, y: y + l + 1.5))
            strip.closeSubpath()
            switch index % 4 {
            case 0: first.addPath(strip)
            case 1: second.addPath(strip)
            case 2: third.addPath(strip)
            default: fourth.addPath(strip)
            }
            x += 6.4
            index += 1
        }
        Art.fill(&g, first, Art.color(0xC8442E))
        Art.fill(&g, second, Art.color(0xDA5A38))
        Art.fill(&g, third, Art.color(0xB83A2A))
        Art.fill(&g, fourth, Art.color(0xE27242))
        Art.fill(&g, Art.rect(x0, y, x1 - x0, 3), Art.color(ArtStyle.warmLightHex, 0.28))
    }

    /// The blue plastic tarp tied over a rack whose rails are `h` above the ground.
    static func tarpRoof(_ g: inout GraphicsContext, half: CGFloat, h: CGFloat) {
        var roof = Path()
        roof.move(to: CGPoint(x: -half - 16, y: -h - 6))
        roof.addLine(to: CGPoint(x: -half + 2, y: -h - 34))
        roof.addLine(to: CGPoint(x: half + 22, y: -h - 34))
        roof.addLine(to: CGPoint(x: half + 12, y: -h - 6))
        roof.addQuadCurve(to: CGPoint(x: -half - 16, y: -h - 6), control: CGPoint(x: 0, y: -h - 1))
        roof.closeSubpath()
        let left = CGAffineTransform(translationX: -half - 16, y: -h - 6).scaledBy(x: 1, y: (h + 6) / 28)
        let right = CGAffineTransform(translationX: half + 12, y: -h - 6).scaledBy(x: 1, y: (h + 6) / 28)
        Art.stroke(&g, Art.svg("M0,0 L-14,28").applying(left), Art.color(0xEFE6CE), width: 1)
        Art.stroke(&g, Art.svg("M1,0 L16,28").applying(right), Art.color(0xEFE6CE), width: 1)
        Kit.solid(&g, roof, Art.color(tarpBlue), light: 0.3, shade: 0.2, rim: 1.4)
        var folds = Path()
        for i in 1...5 {
            let x: CGFloat = -half + half * 2 * CGFloat(i) / 6
            folds.move(to: CGPoint(x: x + 8, y: -h - 34))
            folds.addLine(to: CGPoint(x: x - 3, y: -h - 4))
        }
        let creases = folds
        Art.clipped(&g, to: roof) { c in
            Art.stroke(&c, creases, Art.color(0x1F5F9C, 0.6), width: 1.2)
            Art.fill(&c, Art.rect(-half - 20, -h - 11, half * 2 + 44, 12), ArtStyle.coolShade.opacity(0.12))
        }
    }

    /// A drying rack of peeled poles: `rows` rails of red strips, with or without the blue
    /// tarp roof. Origin on the ground under its middle; the top rail is `h` above the ground.
    static func rack(_ g: inout GraphicsContext, width w: CGFloat, height h: CGFloat, rows: Int, tarp: Bool, seed: UInt32 = 3) {
        let half: CGFloat = w / 2
        let pole = Art.color(peeledPole)
        let poleDark = Kit.personTone(peeledPole, 0.7)
        let top: CGFloat = tarp ? -h - 12 : -h - 5
        let count: Int = max(1, rows)
        Kit.shadow(&g, 0, 0, width: w * 1.1, alpha: 0.2)
        var posts = Path()
        posts.addPath(Art.line(-half, 0, -half + 2, top))
        posts.addPath(Art.line(half, 0, half - 2, top))
        if w > 150 {
            posts.addPath(Art.line(0, 0, 0, top))
        }
        Art.stroke(&g, posts, poleDark, width: 6.2)
        Art.stroke(&g, posts, pole, width: 3.8)
        let room: CGFloat = (h - 14) / CGFloat(count)
        let length: CGFloat = min(36, room - 8)
        for row in 0..<count {
            let railY: CGFloat = -h + 4 + CGFloat(row) * room
            strips(&g, x0: -half + 7, x1: half - 9, y: railY, length: length, seed: seed &+ UInt32(row) &* 7)
            let rail = Art.line(-half - 9, railY, half + 9, railY - 1)
            Art.stroke(&g, rail, poleDark, width: 4.8)
            Art.stroke(&g, rail, pole, width: 2.8)
        }
        if tarp {
            tarpRoof(&g, half: half, h: h)
        }
    }
}
