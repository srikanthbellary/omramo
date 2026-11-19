import SwiftUI
import OmramoCore

// Zal and the Simurgh: palette, the four lights, the people, the horses, the Simurgh, her
// chicks and her feather. Every picture of the story draws its characters from here, so each
// looks the same everywhere.

extension ZalArt {
    // MARK: Palette

    /// Mountain blue and snow, lapis shadow, turquoise tile and feather, saffron and rose.
    static let ramp = ArtStyle.Ramp(deep: 0x14204A, shade: 0x2E4A86, mid: 0x3FA7B0, light: 0xF4F1EA, glow: 0xF2B544, accent: 0xD9707A)
    static let lapis: UInt32 = 0x2E4A86
    static let turquoise: UInt32 = 0x3FA7B0
    static let paleTurquoise: UInt32 = 0xBFE6DF
    static let saffron: UInt32 = 0xF2B544
    static let rose: UInt32 = 0xD9707A
    static let snow: UInt32 = 0xF4F1EA
    static let gold: UInt32 = 0xD9A13A

    /// Garden greens for roses and the beds.
    static func roseGreens() -> Kit.Greens {
        Kit.greens(0x234A38, 0x2F5E44, 0x46784F, 0x7FA866, 0xC6D98A)
    }

    // MARK: Lights (all pale: dark lapis words read on every sky)

    /// Pale rose-gold dawn over Sam's garden.
    static func dawn() -> Kit.Light {
        let sky: Kit.Stops = [(Art.color(0xEFE4EC), 0), (Art.color(0xF6E3DB), 0.5), (Art.color(0xF9DCC6), 0.82), (Art.color(0xF6CF96), 1)]
        return Kit.Light(sky: sky, sun: 0xFFF4DE, glow: 0xF4C27A, haze: 0xF5DED2, far: 0xD7C3C9, mid: 0xA9B08E, near: 0x5E7A5A)
    }

    /// Pale blue high day over the Alborz.
    static func highDay() -> Kit.Light {
        let sky: Kit.Stops = [(Art.color(0xD3E4F3), 0), (Art.color(0xE3EEF7), 0.55), (Art.color(0xF0F2EE), 0.86), (Art.color(0xF6E2B4), 1)]
        return Kit.Light(sky: sky, sun: 0xFFF8E6, glow: 0xF4D79A, haze: 0xE6EEF5, far: 0xBCD0E4, mid: 0x93A9C3, near: 0x6F7E92)
    }

    /// Pale turquoise above the floor of cloud at the nest.
    static func cloudDay() -> Kit.Light {
        let sky: Kit.Stops = [(Art.color(0xC9EBE6), 0), (Art.color(0xDDF3EF), 0.55), (Art.color(0xEEF6F0), 0.86), (Art.color(0xF8E6BC), 1)]
        return Kit.Light(sky: sky, sun: 0xFFF8E6, glow: 0xF6D9A0, haze: 0xE3F4F2, far: 0xC3DCE8, mid: 0x9FC0D2, near: 0x7E98AE)
    }

    /// Clear pale morning at the foot of the mountain.
    static func morning() -> Kit.Light {
        let sky: Kit.Stops = [(Art.color(0xDCE8F2), 0), (Art.color(0xEAF0F3), 0.55), (Art.color(0xF4F2EA), 0.86), (Art.color(0xF7E2B6), 1)]
        return Kit.Light(sky: sky, sun: 0xFFF8E8, glow: 0xF4D69A, haze: 0xEEF2F3, far: 0xC9D7E3, mid: 0xA7B7C2, near: 0x8E9A7E)
    }

    // MARK: People

    /// Sam: a big warrior in a lapis robe; his long beard black in Part I, white later.
    static func samLook(white: Bool) -> Kit.Person {
        let hair: UInt32 = white ? 0xF1EEE8 : 0x231C1E
        return Kit.Person(age: .adult, skin: 0xD9A57E, hair: hair, hairStyle: .short, beard: .long, headwear: .none, garment: .robe, cloth: lapis, trim: 0xC9A24A, legs: 0x5A3A2A, showsEyeWhite: false)
    }

    /// Zal: snow-white long hair and a plain saffron robe, barefoot.
    static func zalLook(child: Bool) -> Kit.Person {
        let age: Kit.Person.Age = child ? .child : .adult
        return Kit.Person(age: age, skin: 0xE6B994, hair: 0xF7F5EF, hairStyle: .long, beard: .none, headwear: .none, garment: .robe, cloth: 0xE9A23B, trim: 0xC8742A, legs: 0xE6B994, showsEyeWhite: false)
    }

    /// The old nurse, in plain dark blue with a scarf.
    static func nurseLook() -> Kit.Person {
        Kit.Person(age: .elder, skin: 0xD8A27C, hair: 0xC9C2B8, hairStyle: .bun, beard: .none, headwear: .kerchief, headwearColor: 0x2B3B6B, garment: .robe, cloth: 0x2A3A6A, trim: 0x6F80B0, legs: 0x2A3A6A, showsEyeWhite: false)
    }

    /// Zal's mother, in a rose robe with a pale veil.
    static func motherLook() -> Kit.Person {
        Kit.Person(age: .adult, skin: 0xE4B48E, hair: 0x2A1C18, hairStyle: .long, beard: .none, headwear: .kerchief, headwearColor: 0xF4ECE2, garment: .robe, cloth: 0xC4566A, trim: saffron, legs: 0xC4566A, showsEyeWhite: false)
    }

    /// One of Sam's riders: a robe in lapis or saffron, a short beard.
    static func riderLook(_ cloth: UInt32, skin: UInt32) -> Kit.Person {
        Kit.Person(age: .adult, skin: skin, hair: 0x2A2022, hairStyle: .short, beard: .short, headwear: .none, garment: .robe, cloth: cloth, trim: 0xC9A24A, legs: 0x4A3428, showsEyeWhite: false)
    }

    /// Sam, origin at his feet, facing left. `white` gives him the white beard of Part II;
    /// `helmet` the pointed steel helmet with its small plume.
    static func sam(
        _ g: inout GraphicsContext,
        pose: Kit.Pose,
        white: Bool,
        helmet: Bool,
        look: CGPoint = .zero,
        mouth: Kit.Mouth = .flat,
        mirrored: Bool = false
    ) {
        let p = samLook(white: white)
        Kit.person(&g, p, pose: pose, look: look, mouth: mouth, mirrored: mirrored)
        let rig = Kit.bodyRig(p, pose)
        let lean: CGFloat = Kit.deg(rig.lean)
        // The skirt of the mail coat over the long robe, and a gold belt.
        Art.group(&g, x: rig.hip.x, y: rig.hip.y, rotate: -lean) { m in
            mailSkirt(&m, mirrored: mirrored)
        }
        if helmet {
            let head = Kit.bodyHeadCentre(Kit.bodyFrame(p), rig)
            Art.group(&g, x: head.x, y: head.y) { h in
                samHelmet(&h, mirrored: mirrored)
            }
        }
    }

    /// The mail skirt, in the hip's own units (hip at the origin).
    static func mailSkirt(_ g: inout GraphicsContext, mirrored: Bool) {
        let skirt: Path = Art.svg("M-21,-8 L21,-8 C23,4 24,14 25,22 C14,25 -14,25 -25,22 C-24,14 -23,4 -21,-8Z")
        let bounds = CGRect(x: -25, y: -8, width: 50, height: 33)
        Kit.personLit(&g, skirt, Art.color(0xA9B3BF), bounds: bounds, mirrored: mirrored, light: 0.3, shade: 0.3)
        Art.clipped(&g, to: skirt) { c in
            var rings = Path()
            for row in 0..<4 {
                let y: CGFloat = -4 + CGFloat(row) * 7
                let shift: CGFloat = row % 2 == 0 ? 0 : 3
                for col in 0..<9 {
                    let x: CGFloat = -26 + CGFloat(col) * 6 + shift
                    rings.move(to: CGPoint(x: x - 3, y: y))
                    rings.addQuadCurve(to: CGPoint(x: x + 3, y: y), control: CGPoint(x: x, y: y + 4))
                }
            }
            Art.stroke(&c, rings, Art.color(0x6E7A8A, 0.7), width: 1)
        }
        Art.stroke(&g, Art.svg("M-25,22 C-14,25 14,25 25,22"), Art.color(0x7E8A9A), width: 1.6)
        Art.fill(&g, Art.rect(-22, -10, 44, 5, radius: 2), Art.color(0xC9A24A))
        Art.fill(&g, Art.rect(-4, -11, 8, 7, radius: 1.5), Art.color(0xE8C36A))
    }

    /// The pointed steel helmet with a small rose plume, in head units (head centre at 0, 0).
    static func samHelmet(_ g: inout GraphicsContext, mirrored: Bool) {
        let steel: UInt32 = 0xA7B1BE
        let aventail: Path = Art.svg("M21,-10 C31,-1 32,15 27,25 L20,20 C24,10 24,1 18,-7Z")
        Art.fill(&g, aventail, Kit.personTone(steel, 0.82))
        let dome: Path = Art.svg("M-29,-8 C-31,-26 -16,-38 0,-54 C16,-38 31,-26 29,-8 C18,-15 -18,-15 -29,-8Z")
        Kit.personLit(&g, dome, Art.color(steel), bounds: CGRect(x: -31, y: -54, width: 62, height: 46), mirrored: mirrored, light: 0.36, shade: 0.3)
        let ridge: Path = Art.svg("M0,-53 C-2,-40 -3,-26 -3,-14")
        Art.stroke(&g, ridge, Kit.personTone(steel, 0.7), width: 1.2)
        Art.stroke(&g, Art.svg("M-29,-9 C-18,-16 18,-16 29,-9"), Art.color(0xC9A24A), width: 3.2)
        let plume: Path = Art.svg("M0,-52 C5,-64 15,-69 25,-65 C17,-62 9,-57 3,-49Z")
        Art.fill(&g, plume, Art.color(rose))
        Art.fill(&g, Art.circle(0, -53, 2.4), Art.color(0xC9A24A))
    }

    /// Zal, origin at his feet, facing left: a boy (`child`) or the young man. `feather` adds
    /// the Simurgh's striped feather tucked at his chest.
    static func zal(
        _ g: inout GraphicsContext,
        child: Bool,
        pose: Kit.Pose,
        feather: Bool,
        look: CGPoint = .zero,
        mouth: Kit.Mouth = .smile,
        mirrored: Bool = false
    ) {
        let p = zalLook(child: child)
        Kit.person(&g, p, pose: pose, look: look, mouth: mouth, mirrored: mirrored)
        guard feather else { return }
        let frame = Kit.bodyFrame(p)
        let rig = Kit.bodyRig(p, pose)
        let neck = Kit.bodyNeck(rig)
        let k: CGFloat = frame.k
        let x: CGFloat = neck.x * k + 4 * k
        let y: CGFloat = neck.y * k + 16 * k
        Art.group(&g, x: x, y: y, rotate: -1.15, scale: 0.26 * k) { f in
            simurghFeather(&f, length: 110)
        }
    }

    /// The old nurse holding out the white-haired baby, origin at her feet, facing left.
    static func nurse(_ g: inout GraphicsContext) {
        let p = nurseLook()
        Kit.person(&g, p, pose: .carry, look: CGPoint(x: -0.6, y: 0.2), mouth: .flat)
        let hand = Kit.hand(p, pose: .carry)
        Art.group(&g, x: hand.x - 10, y: hand.y - 5, scale: 1.1) { b in
            baby(&b)
        }
    }

    /// Zal's mother, origin at her feet, facing left; her veil falls behind her.
    static func mother(_ g: inout GraphicsContext, pose: Kit.Pose) {
        let p = motherLook()
        let rig = Kit.bodyRig(p, pose)
        let head = Kit.bodyHeadCentre(Kit.bodyFrame(p), rig)
        Art.group(&g, x: head.x, y: head.y) { h in
            let veil: Path = Art.svg("M10,-34 C34,-26 40,6 36,50 L20,52 C24,20 22,-8 4,-28Z")
            Kit.solid(&h, veil, Art.color(0xEFE4D8), light: 0.2, shade: 0.24)
        }
        Kit.person(&g, p, pose: pose, look: CGPoint(x: -0.9, y: -0.3), mouth: .sad)
    }

    /// The baby in his embroidered cloak, about 46 long, head on the left; origin mid-bundle.
    static func baby(_ g: inout GraphicsContext) {
        let bundle: Path = Art.svg("M-12,-9 C0,-13 16,-11 22,-4 C26,2 22,9 12,10 C2,11 -10,10 -14,6 C-18,2 -18,-6 -12,-9Z")
        Kit.solid(&g, bundle, Art.color(0xE9A53C), light: 0.3, shade: 0.26)
        Art.stroke(&g, Art.svg("M-12,-8 C0,-12 16,-10 21,-4"), Art.color(rose), width: 2.4)
        Art.stroke(&g, Art.svg("M-13,5 C-4,9 8,9 18,6"), Art.color(rose), width: 1.6)
        var dots = Path()
        let places: [(CGFloat, CGFloat)] = [(-2, -2), (6, -1), (13, 0), (2, 4), (10, 4)]
        for place in places {
            dots.addPath(Art.circle(place.0, place.1, 1.3))
        }
        Art.fill(&g, dots, Art.color(0xFBE7A8))
        Art.fill(&g, Art.circle(6, 1.5, 2.2), Art.color(lapis, 0.8))
        // The head: pink-cheeked, with a full cap of snow-white hair.
        let face: Path = Art.circle(-16, -3, 8.5)
        Kit.solid(&g, face, Art.color(0xF2C4A6), light: 0.3, shade: 0.2)
        let cap: Path = Art.svg("M-25,-4 C-26,-12 -20,-15.5 -15,-15 C-9,-15 -6,-10 -7,-5 C-10,-9 -13,-9.6 -15.5,-8 C-18.5,-10 -22.5,-9 -25,-4Z")
        Art.fill(&g, cap, Art.color(0xFCFBF7))
        Art.stroke(&g, cap, Art.color(0xC9D3E0, 0.8), width: 0.8)
        ArtStyle.eye(&g, -19, -2.6, 1.3, iris: Art.color(0x2A1A12), showsWhite: false)
        ArtStyle.eye(&g, -13.6, -2.6, 1.3, iris: Art.color(0x2A1A12), showsWhite: false)
        ArtStyle.cheek(&g, -20.5, 0.8, 3, alpha: 0.5)
        ArtStyle.cheek(&g, -11.8, 0.8, 3, alpha: 0.5)
        ArtStyle.smile(&g, -16.2, 1.6, width: 3.4, curve: 0.8, color: Art.color(0xB8735A), lineWidth: 1)
    }

    // MARK: Horses and riders

    /// A horse of Sam's company, with a mane and the plain eye of the older tiers.
    static func steedLook(_ coat: UInt32) -> Kit.Beast {
        var look = Kit.horseLook()
        look.body = coat
        look.mane = true
        look.showsEyeWhite = false
        return look
    }

    /// A rider on a waiting horse with an upright lance and a small pennant; origin on the
    /// ground under the horse, facing left. Nobody is armed against the bird: the lance points
    /// at the sky.
    static func horseman(
        _ g: inout GraphicsContext,
        coat: UInt32,
        cloth: UInt32,
        skin: UInt32,
        pennant: UInt32,
        mirrored: Bool = false
    ) {
        let horse = steedLook(coat)
        Kit.shadow(&g, 0, 0, width: 150)
        Kit.beast(&g, horse, pose: .stand, mood: .calm, mirrored: mirrored)
        let head = Kit.beastHeadCentre(horse, pose: .stand)
        var tassels = Path()
        let tx: CGFloat = head.x + 6
        let ty: CGFloat = head.y + 20
        tassels.move(to: CGPoint(x: tx, y: ty))
        tassels.addLine(to: CGPoint(x: tx - 2, y: ty + 12))
        tassels.move(to: CGPoint(x: tx + 6, y: ty - 2))
        tassels.addLine(to: CGPoint(x: tx + 5, y: ty + 10))
        Art.stroke(&g, tassels, Art.color(0xC23A3A), width: 2.4)
        let back = Kit.beastBack(horse, pose: .stand)
        let rider = riderLook(cloth, skin: skin)
        let seat: CGFloat = Kit.seatHeight(rider)
        Art.group(&g, x: back.x + 4, y: back.y + seat) { r in
            Kit.person(&r, rider, pose: .sit, mouth: .flat, mirrored: mirrored)
            let rig = Kit.bodyRig(rider, .sit)
            let hc = Kit.bodyHeadCentre(Kit.bodyFrame(rider), rig)
            Art.group(&r, x: hc.x, y: hc.y) { h in
                samHelmet(&h, mirrored: mirrored)
            }
            let hand = Kit.hand(rider, pose: .sit)
            let topY: CGFloat = hc.y - 62
            let topX: CGFloat = hand.x + 8
            Art.stroke(&r, Art.line(hand.x - 2, hand.y + 18, topX, topY), Art.color(0x8A6A4A), width: 2.2)
            Art.fill(&r, Art.polygon([Kit.pt(topX, topY - 4), Kit.pt(topX + 3, topY + 4), Kit.pt(topX - 3, topY + 4)]), Art.color(0xC8D0DA))
            let flag: Path = Art.polygon([Kit.pt(topX, topY + 6), Kit.pt(topX + 26, topY + 12), Kit.pt(topX, topY + 20)])
            Kit.solid(&r, flag, Art.color(pennant), light: 0.2, shade: 0.2)
        }
    }

    /// A far camel of the caravan with its bells and striped bags, about 40 long; origin on the
    /// ground under it, facing left.
    static func camel(_ g: inout GraphicsContext, color: Color, bags: Color) {
        let body: Path = Art.svg("M-16,-14 C-14,-24 -6,-28 0,-22 C4,-28 12,-26 14,-16 C18,-16 20,-12 18,-8 L16,0 L14,0 L14,-7 L6,-7 L6,0 L4,0 L3,-8 L-8,-8 L-9,0 L-11,0 L-12,-8 C-16,-10 -18,-12 -19,-16 C-21,-20 -24,-26 -26,-30 C-28,-33 -32,-33 -33,-30 L-31,-28 C-29,-28 -28,-26 -26,-20 C-24,-16 -20,-13 -16,-14Z")
        Art.fill(&g, body, color)
        Art.fill(&g, Art.rect(-6, -18, 10, 8, radius: 1.5), bags)
        Art.fill(&g, Art.circle(-22, -18, 1.4), Art.color(0xE8C36A))
    }

    // MARK: The Simurgh

    enum SimurghPose { case glide, perch }

    /// A long flame-shaped feather pointing along +x from the origin, its tip curling a little.
    static func flamePath(_ L: CGFloat, _ w: CGFloat) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: 0, y: -w * 0.3))
        p.addCurve(to: CGPoint(x: L, y: -w * 0.28), control1: CGPoint(x: L * 0.3, y: -w * 0.72), control2: CGPoint(x: L * 0.8, y: -w * 0.74))
        p.addCurve(to: CGPoint(x: 0, y: w * 0.3), control1: CGPoint(x: L * 0.74, y: w * 0.56), control2: CGPoint(x: L * 0.3, y: w * 0.7))
        p.closeSubpath()
        return p
    }

    /// One trailing tail plume, `L` long, falling `d` by its tip, `w` wide.
    static func plumePath(_ L: CGFloat, _ d: CGFloat, _ w: CGFloat) -> Path {
        var p = Path()
        let upper: CGFloat = d * 0.8 - w
        let lower: CGFloat = d * 0.86 + w * 0.8
        p.move(to: CGPoint(x: 0, y: -w * 0.3))
        p.addCurve(to: CGPoint(x: L, y: d), control1: CGPoint(x: L * 0.4, y: -w * 0.6), control2: CGPoint(x: L * 0.78, y: upper))
        p.addCurve(to: CGPoint(x: 0, y: w * 0.3), control1: CGPoint(x: L * 0.8, y: lower), control2: CGPoint(x: L * 0.4, y: w * 0.6))
        p.closeSubpath()
        return p
    }

    /// A wing: rows of flame-shaped feathers fanned from `pivot` between the angles `a0` and
    /// `a1` (degrees; 180 points left, 270 up). The near wing is turquoise and lapis with
    /// saffron edges; the far wing is a deeper tone of the same.
    static func simurghWing(
        _ g: inout GraphicsContext,
        pivot: CGPoint,
        from a0: CGFloat,
        to a1: CGFloat,
        count: Int,
        length: CGFloat,
        near: Bool
    ) {
        let outer: UInt32 = near ? lapis : 0x24407A
        let inner: UInt32 = near ? turquoise : 0x2F8E9A
        let covert: UInt32 = near ? turquoise : 0x2F7F8E
        let n: Int = max(2, count)
        let w: CGFloat = length * 0.17
        for i in 0..<n {
            let t: CGFloat = CGFloat(i) / CGFloat(n - 1)
            let a: CGFloat = Kit.deg(Kit.mix(a0, a1, t))
            let reach: CGFloat = length * (0.74 + 0.26 * sin(t * CGFloat.pi))
            let base: CGFloat = length * 0.16
            let place: CGAffineTransform = CGAffineTransform(translationX: pivot.x, y: pivot.y).rotated(by: a).translatedBy(x: base, y: 0)
            let quill: Path = flamePath(reach, w).applying(place)
            Kit.solid(&g, quill, Art.color(outer), light: 0.2, shade: 0.2)
            Art.fill(&g, flamePath(reach * 0.7, w * 0.45).applying(place), Art.color(inner))
            Art.stroke(&g, quill, Art.color(saffron, near ? 0.6 : 0.25), width: 1)
        }
        for i in 0..<n {
            let t: CGFloat = CGFloat(i) / CGFloat(n - 1)
            let a: CGFloat = Kit.deg(Kit.mix(a0, a1, t))
            let base: CGFloat = length * 0.06
            let place: CGAffineTransform = CGAffineTransform(translationX: pivot.x, y: pivot.y).rotated(by: a).translatedBy(x: base, y: 0)
            let quill: Path = flamePath(length * 0.5, w * 0.9).applying(place)
            Kit.solid(&g, quill, Art.color(covert), light: 0.24, shade: 0.18)
            Art.fill(&g, flamePath(length * 0.16, w * 0.4).applying(place.translatedBy(x: length * 0.3, y: 0)), Art.color(saffron, near ? 0.9 : 0.4))
        }
        for i in 0..<(n - 1) {
            let t: CGFloat = (CGFloat(i) + 0.5) / CGFloat(n - 1)
            let a: CGFloat = Kit.deg(Kit.mix(a0, a1, t))
            let place = CGAffineTransform(translationX: pivot.x, y: pivot.y).rotated(by: a)
            let quill: Path = flamePath(length * 0.3, w * 0.8).applying(place)
            Art.fill(&g, quill, Art.color(near ? paleTurquoise : 0x8FBDBA))
            Art.fill(&g, flamePath(length * 0.08, w * 0.4).applying(place.translatedBy(x: length * 0.22, y: 0)), Art.color(rose, near ? 0.85 : 0.4))
        }
        let shoulder: Path = Art.ellipse(pivot.x, pivot.y, length * 0.13, length * 0.11)
        Kit.solid(&g, shoulder, Art.color(near ? turquoise : 0x2F7F8E), light: 0.3, shade: 0.2)
    }

    /// The long sweeping tail: six plumes in turquoise, saffron, rose and lapis, each with an
    /// eye at its tip; origin at the root, the plumes streaming to the right.
    static func simurghTail(_ g: inout GraphicsContext, length: CGFloat, drop: CGFloat) {
        let plumes: [(CGFloat, CGFloat, CGFloat, UInt32, UInt32)] = [
            (0.86, 1.0, 12, saffron, rose), (1.0, 0.8, 14, rose, saffron), (0.94, 0.6, 13, 0x7FC6C0, lapis),
            (1.08, 0.4, 15, turquoise, saffron), (0.98, 0.2, 14, saffron, turquoise), (0.9, 0.02, 13, lapis, 0x7FC6C0),
        ]
        let k: CGFloat = length / 200
        for plume in plumes {
            let L: CGFloat = length * plume.0
            let d: CGFloat = drop * plume.1
            let w: CGFloat = plume.2 * k
            Kit.solid(&g, plumePath(L, d, w), Art.color(plume.3), light: 0.22, shade: 0.22)
            Art.fill(&g, plumePath(L * 0.9, d * 0.9, w * 0.36), Kit.personTone(plume.3, 1.16))
            var rachis = Path()
            rachis.move(to: CGPoint(x: 0, y: 0))
            rachis.addCurve(to: CGPoint(x: L * 0.96, y: d * 0.96), control1: CGPoint(x: L * 0.4, y: 0), control2: CGPoint(x: L * 0.78, y: d * 0.82))
            Art.stroke(&g, rachis, Kit.personTone(plume.3, 0.72), width: 1)
            let ex: CGFloat = L * 0.84
            let ey: CGFloat = d * 0.76
            Art.fill(&g, Art.ellipse(ex, ey, w * 0.62, w * 0.42), Art.color(plume.4))
            Art.fill(&g, Art.ellipse(ex, ey, w * 0.26, w * 0.18), Art.color(snow))
        }
    }

    /// The Simurgh's head, facing left, centre at the origin (about 44 across, the crest
    /// reaching some 50 above): a crest of long feathers white at the tips, a curved gold beak,
    /// and a calm gold-rimmed eye under a quiet lid.
    static func simurghHead(_ g: inout GraphicsContext, look: CGPoint = .zero, mirrored: Bool = false) {
        let crest: [(CGFloat, CGFloat, UInt32)] = [(345, 34, saffron), (328, 44, rose), (311, 50, turquoise), (295, 46, rose), (280, 36, saffron)]
        for feather in crest {
            let a: CGFloat = Kit.deg(feather.0)
            let place = CGAffineTransform(translationX: 4, y: -17).rotated(by: a)
            Kit.solid(&g, flamePath(feather.1, 9).applying(place), Art.color(feather.2), light: 0.24, shade: 0.2)
            let tip: Path = flamePath(feather.1 * 0.34, 6).applying(place.translatedBy(x: feather.1 * 0.66, y: 0))
            Art.fill(&g, tip, Art.color(0xFAF7F0))
        }
        let head: Path = Art.svg("M-20,-4 C-21,-17 -10,-24 2,-23 C14,-22 23,-12 22,1 C21,13 13,21 3,22 C-9,22 -19,12 -20,-4Z")
        Kit.solid(&g, head, stops: Kit.stops(0x56BCC2, turquoise, 0x2F8E9A), light: 0.3, shade: 0.24, rim: 2)
        let scales: Path = Kit.personScallop(cx: 10, cy: 4, rx: 12, ry: 14, from: 300, to: 420, count: 6, r: 3)
        Art.fill(&g, scales, Art.color(0x2F8E9A, 0.6))
        Art.fill(&g, Art.ellipse(-7, -2, 11, 10), Art.color(paleTurquoise, 0.85))
        let stripe = CGAffineTransform(translationX: -4, y: 6).rotated(by: 0.3)
        Art.fill(&g, flamePath(15, 5).applying(stripe), Art.color(rose, 0.7))
        let wattle = CGAffineTransform(translationX: -12, y: 9).rotated(by: Kit.deg(100))
        Kit.solid(&g, flamePath(18, 6).applying(wattle), Art.color(rose), light: 0.2, shade: 0.2)
        let upper: Path = Art.svg("M-17,-9 C-27,-11 -35,-5 -36,5 C-33.5,2.5 -30,1 -26,1.4 C-23,1.8 -20,2.6 -16,4Z")
        Kit.solid(&g, upper, Art.color(0xE3A33A), light: 0.34, shade: 0.24)
        let lower: Path = Art.svg("M-16,4 C-21,4 -25,5 -27.5,7.5 C-23,9.6 -18,9.4 -14.5,7Z")
        Art.fill(&g, lower, Art.color(0xC98A2E))
        Art.fill(&g, Art.circle(-22, -4, 1), Art.color(0x8A5A1E))
        Art.fill(&g, Art.circle(-8, -4, 5.2), Art.color(saffron))
        Art.stroke(&g, Art.circle(-8, -4, 5.2), Art.color(0xB07A1E), width: 0.8)
        let iris: Color = Art.color(0x1C1630)
        if mirrored {
            let turned = CGPoint(x: -look.x, y: look.y)
            Art.group(&g, x: -8, y: -4, scaleX: -1) { e in
                ArtStyle.eye(&e, 0, 0, 3.2, look: turned, iris: iris, showsWhite: false)
            }
        } else {
            ArtStyle.eye(&g, -8, -4, 3.2, look: look, iris: iris, showsWhite: false)
        }
        Art.stroke(&g, Art.svg("M-13.6,-7.6 C-10,-10.6 -5.6,-10.4 -2.6,-7.4"), Art.color(0x14204A), width: 1.5)
        ArtStyle.cheek(&g, -3, 7, 6, color: Art.color(rose), alpha: 0.3)
    }

    /// Her neck and body in flight, facing left, centre of the body at the origin.
    static func simurghBody(_ g: inout GraphicsContext) {
        let neck: Path = Art.svg("M-40,-24 C-52,-30 -66,-40 -76,-56 C-86,-70 -104,-62 -102,-46 C-98,-30 -80,-12 -62,-2Z")
        Kit.solid(&g, neck, Art.color(turquoise), light: 0.28, shade: 0.22)
        let body: Path = Art.svg("M-58,-20 C-44,-34 -6,-31 24,-21 C46,-13 62,-3 64,6 C50,14 24,24 -4,24 C-30,24 -52,12 -62,-2 C-64,-10 -62,-16 -58,-20Z")
        let coat: Kit.Stops = Kit.stops(lapis, 0x357FA8, turquoise)
        Kit.solid(&g, body, stops: coat, light: 0.26, shade: 0.24, rim: 2)
        let breast: Path = Art.svg("M-62,-4 C-56,-14 -40,-14 -24,-6 C-10,2 -4,14 -6,23 C-28,23 -50,12 -62,-4Z")
        Art.fill(&g, breast, Art.color(paleTurquoise))
        var scales = Path()
        for row in 0..<3 {
            for col in 0..<4 {
                let x: CGFloat = -50 + CGFloat(col) * 9 + CGFloat(row) * 5
                let y: CGFloat = -6 + CGFloat(row) * 8
                scales.move(to: CGPoint(x: x - 4, y: y))
                scales.addQuadCurve(to: CGPoint(x: x + 4, y: y), control: CGPoint(x: x, y: y + 5))
            }
        }
        Art.stroke(&g, scales, Art.color(0x7FC6C0), width: 1.1)
        let lines: Path = Art.svg("M-30,-24 C-10,-22 10,-18 30,-10 M-20,-14 C0,-12 20,-6 40,2")
        Art.stroke(&g, lines, Art.color(0x22396E, 0.5), width: 1.2)
        let claws: Path = Art.svg("M-8,22 C-6,29 -10,32 -14,30 M0,22 C2,29 -2,32 -6,30")
        Art.stroke(&g, claws, Art.color(0xC98A2E), width: 2.4)
    }

    /// The Simurgh, facing left. `.glide`: origin at the centre of the body, wings spread; with
    /// `rider` the grown Zal sits on her back and her near wing sweeps down. `.perch`: origin
    /// at her feet, body upright, the near wing spread forward (`wing` long) like a roof.
    static func simurgh(
        _ g: inout GraphicsContext,
        pose: SimurghPose,
        wing: CGFloat = 170,
        rider: Bool = false,
        look: CGPoint = .zero,
        mirrored: Bool = false
    ) {
        switch pose {
        case .glide:
            simurghGlide(&g, wing: wing, rider: rider, look: look, mirrored: mirrored)
        case .perch:
            simurghPerch(&g, wing: wing, look: look, mirrored: mirrored)
        }
    }

    static func simurghGlide(_ g: inout GraphicsContext, wing: CGFloat, rider: Bool, look: CGPoint, mirrored: Bool) {
        simurghWing(&g, pivot: CGPoint(x: 4, y: -22), from: 232, to: 302, count: 7, length: wing * 0.9, near: false)
        Art.group(&g, x: 50, y: 2, rotate: 0.06) { t in
            simurghTail(&t, length: 210, drop: 46)
        }
        simurghBody(&g)
        Art.group(&g, x: -88, y: -50) { h in
            simurghHead(&h, look: look, mirrored: mirrored)
        }
        if rider {
            let p = zalLook(child: false)
            let lift: CGFloat = Kit.seatHeight(p) * 0.62
            Art.group(&g, x: 12, y: -26 + lift, scale: 0.62) { z in
                zal(&z, child: false, pose: .sit, feather: true, look: CGPoint(x: -0.7, y: 0.6), mouth: .smile, mirrored: mirrored)
            }
            simurghWing(&g, pivot: CGPoint(x: -14, y: -14), from: 100, to: 165, count: 8, length: wing, near: true)
        } else {
            simurghWing(&g, pivot: CGPoint(x: -14, y: -16), from: 206, to: 288, count: 8, length: wing, near: true)
        }
    }

    static func simurghPerch(_ g: inout GraphicsContext, wing: CGFloat, look: CGPoint, mirrored: Bool) {
        simurghPerchBack(&g)
        simurghPerchFront(&g, wing: wing, look: look, mirrored: mirrored)
    }

    /// The perched Simurgh's far wing, tail, legs and body (draw what she shelters next, then
    /// `simurghPerchFront`).
    static func simurghPerchBack(_ g: inout GraphicsContext) {
        simurghWing(&g, pivot: CGPoint(x: 15, y: -89), from: 290, to: 330, count: 5, length: 120, near: false)
        Art.group(&g, x: 42, y: -44, rotate: 0.55) { t in
            simurghTail(&t, length: 190, drop: 120)
        }
        let legTone: Color = Art.color(0xC98A2E)
        Art.stroke(&g, Art.svg("M-10,-46 L-12,-6 M6,-46 L8,-6"), legTone, width: 5)
        Art.stroke(&g, Art.svg("M-12,-5 C-18,-5 -22,-2 -24,1 M-12,-5 C-14,-2 -14,1 -12,2 M8,-5 C2,-5 -2,-2 -4,1"), legTone, width: 2.6)
        Art.group(&g, x: 0, y: -72, rotate: 0.55) { b in
            simurghBody(&b)
        }
    }

    /// The perched Simurgh's near wing, spread forward, and her head.
    static func simurghPerchFront(_ g: inout GraphicsContext, wing: CGFloat, look: CGPoint, mirrored: Bool) {
        simurghWing(&g, pivot: CGPoint(x: -4, y: -93), from: 185, to: 212, count: 8, length: wing, near: true)
        Art.group(&g, x: -49, y: -161) { h in
            simurghHead(&h, look: look, mirrored: mirrored)
        }
    }

    /// One of her chicks, already the size of a goat: a ball of soft grey-turquoise down with
    /// a rose tuft; origin on the ground under it, facing left, about 60 tall.
    static func chick(_ g: inout GraphicsContext, look: CGPoint = .zero) {
        var fluff: Path = Kit.personScallop(cx: 0, cy: -17, rx: 15, ry: 15, from: 0, to: 345, count: 16, r: 4.2)
        fluff.addPath(Art.circle(0, -17, 15))
        Kit.solid(&g, fluff, Art.color(0xA9CFCB), light: 0.3, shade: 0.26)
        Art.fill(&g, Art.ellipse(-3, -13, 9, 9), Art.color(0xD8ECE8, 0.8))
        Art.fill(&g, Art.svg("M6,-24 C14,-22 16,-12 12,-6 C8,-10 6,-16 6,-24Z"), Art.color(0x86B6B4))
        var head: Path = Kit.personScallop(cx: -4, cy: -38, rx: 10, ry: 10, from: 0, to: 345, count: 12, r: 3)
        head.addPath(Art.circle(-4, -38, 10))
        Kit.solid(&g, head, Art.color(0xB6D9D5), light: 0.32, shade: 0.22)
        Art.stroke(&g, Art.svg("M-2,-48 C0,-56 6,-58 8,-56 M-5,-48 C-6,-55 -3,-59 0,-60"), Art.color(rose), width: 2)
        Art.fill(&g, Art.svg("M-13,-40 L-20,-37 L-13,-34Z"), Art.color(0xE3A33A))
        ArtStyle.eye(&g, -9, -40, 2, look: look, iris: Art.color(0x1C1630), showsWhite: false)
        ArtStyle.cheek(&g, -7, -35, 3.4, color: Art.color(rose), alpha: 0.35)
    }

    /// The Simurgh's feather, striped turquoise, saffron and rose, from its quill at the
    /// origin to its tip at (`length`, 0).
    static func simurghFeather(_ g: inout GraphicsContext, length L: CGFloat) {
        let w: CGFloat = L * 0.2
        var vane = Path()
        vane.move(to: CGPoint(x: L * 0.12, y: 0))
        vane.addCurve(to: CGPoint(x: L, y: -w * 0.1), control1: CGPoint(x: L * 0.3, y: -w * 0.9), control2: CGPoint(x: L * 0.85, y: -w * 0.8))
        vane.addCurve(to: CGPoint(x: L * 0.12, y: 0), control1: CGPoint(x: L * 0.86, y: w * 0.7), control2: CGPoint(x: L * 0.3, y: w * 0.8))
        vane.closeSubpath()
        Art.fill(&g, vane, Art.color(turquoise))
        let bands: [UInt32] = [turquoise, saffron, rose, turquoise, saffron, rose, turquoise, saffron]
        let step: CGFloat = L * 0.11
        Art.clipped(&g, to: vane) { c in
            for (i, hex) in bands.enumerated() {
                let x: CGFloat = L * 0.1 + CGFloat(i) * step
                let slant: CGFloat = w * 0.5
                let band: Path = Art.polygon([Kit.pt(x, -w), Kit.pt(x + step, -w), Kit.pt(x + step + slant, w), Kit.pt(x + slant, w)])
                Art.fill(&c, band, Art.color(hex))
            }
            var barbs = Path()
            for i in 0..<14 {
                let x: CGFloat = L * 0.16 + CGFloat(i) * L * 0.058
                barbs.move(to: CGPoint(x: x, y: 0))
                barbs.addLine(to: CGPoint(x: x + w * 0.5, y: -w))
                barbs.move(to: CGPoint(x: x, y: 0))
                barbs.addLine(to: CGPoint(x: x + w * 0.5, y: w))
            }
            Art.stroke(&c, barbs, Color.white.opacity(0.22), width: 0.8)
        }
        Kit.model(&g, vane, light: 0.3, shade: 0.24)
        Art.fill(&g, Art.ellipse(L * 0.85, -w * 0.05, L * 0.07, w * 0.4), Art.color(lapis))
        Art.fill(&g, Art.ellipse(L * 0.85, -w * 0.05, L * 0.03, w * 0.18), Art.color(snow))
        Art.stroke(&g, Art.line(0, 0, L * 0.97, -w * 0.06), Art.color(0xF4EBD8), width: max(1, L * 0.018))
        let wisps: Path = Art.svg("M0,0 q-4,-6 -10,-6 M0,0 q-4,6 -10,7 M2,0 q-2,-9 -7,-12")
        Art.stroke(&g, wisps.applying(CGAffineTransform(translationX: L * 0.14, y: 0)), Color.white.opacity(0.6), width: 1)
    }
}
