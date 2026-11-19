import SwiftUI
import OmramoCore

// "The Eloquent Peasant": palette, light, the people and the donkeys, and the story's own
// parts (salt lake, mud-brick house, fringed cloth, lotus-bud column, lion-legged chair, the
// scribe and his papyrus) shared by the scenes, the pictures and the cover.
// Middle Kingdom Egypt, about 4,000 years ago. Advanced tier: plain eyes, calm postures.

extension EloquentArt {
    // MARK: Palette

    /// Salt white and sand gold, barley green, the slow blue of the Nile, one blue-lotus note.
    static let ramp = ArtStyle.Ramp(deep: 0x1C2433, shade: 0x2E5E7A, mid: 0x7FA35A, light: 0xF8F1E2, glow: 0xE9C46A, accent: 0x5B7FC7)

    static let sandHex: UInt32 = 0xE6D2A6
    static let sandDeepHex: UInt32 = 0xCBAA76
    static let saltHex: UInt32 = 0xF8F2EC
    static let saltPinkHex: UInt32 = 0xEBD8D0
    static let lakeHex: UInt32 = 0x9FB8C2
    static let plasterHex: UInt32 = 0xF1E7D3
    static let plasterShadeHex: UInt32 = 0xE2D3B8
    static let linenHex: UInt32 = 0xF4EFE4
    static let woodHex: UInt32 = 0x8A5A2E
    static let barleyHex: UInt32 = 0x7FA35A
    static let palmHex: UInt32 = 0x4E7F4A
    static let palmTrunkHex: UInt32 = 0x8A6A4A
    static let inkHex: UInt32 = 0x2A2420
    static let redInkHex: UInt32 = 0xB0402A
    static let ropeHex: UInt32 = 0x8C6A42
    static let nileHex: UInt32 = 0x6F9DB0

    // MARK: Light (one warm light from the upper left; every sky pale behind the words)

    /// Early morning at the Salt Field: white-gold.
    static func morning() -> Kit.Light {
        let sky: Kit.Stops = [
            (Art.color(0xE3ECEE), 0), (Art.color(0xF3F2EA), 0.45), (Art.color(0xF8EED6), 0.8), (Art.color(0xF0D9A2), 1),
        ]
        return Kit.Light(sky: sky, sun: 0xFFF8E6, glow: 0xF2D892, haze: 0xF5EBD4, far: 0xE0CFAE, mid: 0xD4BC92, near: 0xBFA078)
    }

    /// Morning on the canal path: pale gold.
    static func goldMorning() -> Kit.Light {
        let sky: Kit.Stops = [
            (Art.color(0xEFEEE2), 0), (Art.color(0xF7F0D8), 0.45), (Art.color(0xF8E7BC), 0.8), (Art.color(0xEFCF86), 1),
        ]
        return Kit.Light(sky: sky, sun: 0xFFF6DA, glow: 0xF0D088, haze: 0xF5EBCF, far: 0xDCD2AC, mid: 0xA9B47C, near: 0x8EA866)
    }

    /// Soft cream daylight in Rensi's courtyard.
    static func courtyard() -> Kit.Light {
        let sky: Kit.Stops = [
            (Art.color(0xEDF0EC), 0), (Art.color(0xF6F2E6), 0.45), (Art.color(0xF7EBD2), 0.8), (Art.color(0xEED9A8), 1),
        ]
        return Kit.Light(sky: sky, sun: 0xFFF8E8, glow: 0xEFD9A0, haze: 0xF5EEDF, far: 0xE6D9C0, mid: 0xDCCBAA, near: 0xCDB892)
    }

    /// Late afternoon at the river landing: pale rose-gold.
    static func afternoon() -> Kit.Light {
        let sky: Kit.Stops = [
            (Art.color(0xEEE7EA), 0), (Art.color(0xF7E9E1), 0.45), (Art.color(0xF8DDCB), 0.8), (Art.color(0xF0C690), 1),
        ]
        return Kit.Light(sky: sky, sun: 0xFFF2DE, glow: 0xF2C994, haze: 0xF6E2D2, far: 0xE3C9BA, mid: 0xA7B07E, near: 0x7E9C5E)
    }

    // MARK: Looks

    /// Khunanup: wiry, sun-browned, short dark hair, a short kilt grey with dust, bare feet.
    static func khunanupLook() -> Kit.Person {
        let skin: UInt32 = 0x9A6038
        return Kit.Person(age: .adult, skin: skin, hair: 0x2A1E16, hairStyle: .short, garment: .kilt, cloth: 0xE4DCCB, trim: Kit.personToneHex(skin, 0.9), legs: skin, showsEyeWhite: false)
    }

    /// Rensi son of Meru: a short black wig, a broad collar of blue beads, a white kilt.
    static func rensiLook() -> Kit.Person {
        Kit.Person(age: .adult, skin: 0xA8693E, hair: 0x1A1614, hairStyle: .bob, garment: .kilt, cloth: 0xF7F3EA, trim: 0x3E7FB8, legs: 0xA8693E, showsEyeWhite: false)
    }

    /// Nemtynakht: neat and well fed, oiled hair, fine linen, a small red-brown bead collar.
    static func nemtyLook() -> Kit.Person {
        Kit.Person(age: .adult, skin: 0xB07448, hair: 0x18120E, hairStyle: .short, garment: .kilt, cloth: 0xFBF8F0, trim: 0xB5523A, legs: 0xB07448, showsEyeWhite: false)
    }

    /// Khunanup's wife: a plain white sheath dress, long dark hair.
    static func wifeLook() -> Kit.Person {
        Kit.Person(age: .adult, skin: 0xA86A40, hair: 0x1E1612, hairStyle: .long, garment: .dress, cloth: 0xF2EDE2, trim: 0xE6DECF, legs: 0xA86A40, showsEyeWhite: false)
    }

    /// The children: a boy in a short kilt, a girl in a simple shift.
    static func childLook(girl: Bool) -> Kit.Person {
        let skin: UInt32 = girl ? 0xA46640 : 0x9C613A
        if girl {
            return Kit.Person(age: .child, skin: skin, hair: 0x1E1612, hairStyle: .bob, garment: .tunic, cloth: 0xF0EADC, trim: 0xE2D8C4, legs: skin, showsEyeWhite: false)
        }
        return Kit.Person(age: .child, skin: skin, hair: 0x221812, hairStyle: .short, garment: .kilt, cloth: 0xF0EADC, trim: Kit.personToneHex(skin, 0.92), legs: skin, showsEyeWhite: false)
    }

    /// The scribe: shaven head, a white kilt.
    static func scribeLook() -> Kit.Person {
        let skin: UInt32 = 0xA56A42
        return Kit.Person(age: .adult, skin: skin, hair: 0x2A1E16, hairStyle: .shaved, garment: .kilt, cloth: 0xF5F0E4, trim: Kit.personToneHex(skin, 0.9), legs: skin, showsEyeWhite: false)
    }

    /// The steward's officials: short wigs, collars of green or red beads.
    static func officialLook(_ variant: Int) -> Kit.Person {
        let skins: [UInt32] = [0xA0643C, 0xB27A4C, 0x96603A]
        let collars: [UInt32] = [0x2E8A6A, 0xC8553D, 0x3E7FB8]
        let index: Int = abs(variant) % 3
        let skin: UInt32 = skins[index]
        return Kit.Person(age: .adult, skin: skin, hair: 0x1A1614, hairStyle: .bob, garment: .kilt, cloth: 0xF6F2E8, trim: collars[index], legs: skin, showsEyeWhite: false)
    }

    /// A small grey pack donkey with long ears and a dark crest; plain eyes.
    static func donkeyLook() -> Kit.Beast {
        var look = Kit.donkeyLook()
        look.body = 0x9C958E
        look.belly = 0xECE6DC
        look.dark = 0x4A423E
        look.mane = true
        look.showsEyeWhite = false
        return look
    }
}

// MARK: - The people (origin at the feet, adult 168 tall, facing LEFT)

extension EloquentArt {
    /// Khunanup. `.wave` is his speaking pose: the near hand raised; the stick is then in the
    /// far hand. Other poses carry the stick in the leading hand.
    static func khunanup(
        _ g: inout GraphicsContext,
        pose: Kit.Pose = .stand,
        mouth: Kit.Mouth = .flat,
        look: CGPoint = .zero,
        mirrored: Bool = false,
        stick: Bool = true
    ) {
        let p = khunanupLook()
        let skin: Color = Art.color(p.skin)
        Kit.shadow(&g, 0, 0, width: 50)
        let farHand = CGPoint(x: 26, y: -62)
        if stick && pose == .wave {
            // Behind the body, in the far hand.
            walkingStick(&g, hand: farHand, far: true)
        }
        Kit.person(&g, p, pose: pose, look: look, mouth: mouth, mirrored: mirrored)
        // The cord belt with its small linen pouch.
        Art.stroke(&g, Art.svg("M-19,-63 Q0,-60 19,-63"), Art.color(ropeHex), width: 1.8)
        let pouch: Path = Art.svg("M9,-62 C6,-57 7,-50 12,-49 C17,-50 18,-57 15,-62Z")
        Kit.solid(&g, pouch, Art.color(0xD8CDB6), light: 0.2, shade: 0.24)
        if stick && pose != .wave {
            let hand: CGPoint = Kit.hand(p, pose: pose)
            walkingStick(&g, hand: hand, far: false)
            Art.fill(&g, Art.circle(hand.x, hand.y, 5.2), skin)
        }
    }

    /// The long walking stick through `hand`, from the ground to a little above the hand.
    static func walkingStick(_ g: inout GraphicsContext, hand: CGPoint, far: Bool) {
        let footX: CGFloat = hand.x - 8
        let topX: CGFloat = hand.x + 3
        let topY: CGFloat = hand.y - 40
        let stick = Art.line(footX, -1, topX, topY)
        let tone: Color = far ? Art.color(0x6E4E30) : Art.color(0x8A6440)
        Art.stroke(&g, stick, tone, width: 3.4)
        if !far {
            Art.stroke(&g, Art.line(footX - 0.8, -4, topX - 0.8, topY + 4), ArtStyle.warmLight.opacity(0.35), width: 1)
        }
    }

    /// The long staff of office, a thin tall rod with a small knob.
    static func staffOfOffice(_ g: inout GraphicsContext, x: CGFloat, top: CGFloat) {
        Art.stroke(&g, Art.line(x, -1, x + 2, top), Art.color(0x6B4426), width: 3)
        Art.stroke(&g, Art.line(x - 0.8, -6, x + 1.2, top + 6), ArtStyle.warmLight.opacity(0.3), width: 1)
        Art.fill(&g, Art.ellipse(x + 2, top, 3.4, 2.6), Art.color(0x8A5A2E))
    }

    /// The see-through over-kilt to the shin that officials wear, standing.
    static func overKilt(_ g: inout GraphicsContext) {
        let cloth: Path = Art.svg("M-17,-70 L17,-70 L21,-15 Q0,-10 -22,-15Z")
        Art.fill(&g, cloth, Art.color(0xFAF7F0, 0.74))
        let folds: Path = Art.svg("M-5,-66 L-9,-15 M5,-66 L7,-14 M12,-64 L16,-15")
        Art.stroke(&g, folds, Art.color(0xD6CCBA, 0.8), width: 1.1)
        Art.stroke(&g, Art.svg("M-22,-15 Q0,-10 21,-15"), Art.color(0xE0D6C4), width: 1.6)
    }

    /// A broad collar laid over the kit's collar: rows of blue, green and red beads.
    static func beadRows(_ g: inout GraphicsContext, hipX: CGFloat, hipY: CGFloat) {
        Art.group(&g, x: hipX, y: hipY) { c in
            let rows: Path = Art.svg("M-16,-50 C-11,-38 9,-38 14,-50 M-14,-46 C-9,-36 7,-36 12,-46")
            Art.stroke(&c, rows, Art.color(0x3FA27A), width: 1.6)
            Art.stroke(&c, Art.svg("M-12,-42 C-7,-35 5,-35 10,-42"), Art.color(0xC8553D), width: 1.6)
            Art.stroke(&c, Art.svg("M-17,-53 C-13,-36 11,-36 15,-53"), Art.color(0xE9C46A, 0.8), width: 1)
        }
    }

    /// Rensi son of Meru, standing (staff in the leading hand) or seated on his lion chair
    /// with both hands folded on the staff.
    static func rensi(
        _ g: inout GraphicsContext,
        seated: Bool,
        mouth: Kit.Mouth = .flat,
        look: CGPoint = .zero,
        mirrored: Bool = false
    ) {
        let p = rensiLook()
        let skin: Color = Art.color(p.skin)
        if seated {
            Kit.shadow(&g, 4, 0, width: 78)
            lionChair(&g)
            Kit.person(&g, p, pose: .sit, look: look, mouth: mouth, mirrored: mirrored)
            let lap: Path = Art.svg("M24,-62 L-34,-55 L-38,-14 L-21,-14 L-20,-40 L24,-38Z")
            Art.fill(&g, lap, Art.color(0xFAF7F0, 0.72))
            Art.stroke(&g, Art.svg("M-34,-50 L-36,-15 M-26,-52 L-27,-15"), Art.color(0xD6CCBA, 0.8), width: 1.1)
            beadRows(&g, hipX: 6, hipY: -46)
            staffOfOffice(&g, x: -31, top: -158)
            Art.fill(&g, Art.circle(-28, -62, 5.6), skin)
            Art.fill(&g, Art.circle(-31, -68, 5.4), Kit.personTone(p.skin, 1.06))
        } else {
            Kit.shadow(&g, 0, 0, width: 56)
            Kit.person(&g, p, pose: .stand, look: look, mouth: mouth, mirrored: mirrored)
            overKilt(&g)
            beadRows(&g, hipX: 0, hipY: -58)
            staffOfOffice(&g, x: -26, top: -176)
            Art.fill(&g, Art.circle(-24, -61, 5.4), skin)
        }
    }

    /// Nemtynakht with his thin green tamarisk switch, smug but not cruel.
    static func nemtynakht(_ g: inout GraphicsContext, mouth: Kit.Mouth = .smile, look: CGPoint = .zero, mirrored: Bool = false) {
        let p = nemtyLook()
        Kit.shadow(&g, 0, 0, width: 56)
        Kit.person(&g, p, pose: .stand, look: look, mouth: mouth, mirrored: mirrored)
        overKiltShort(&g)
        // Oil in his hair: a bright sheen.
        Art.stroke(&g, Art.svg("M-18,-164 C-10,-170 0,-172 8,-170"), Color.white.opacity(0.55), width: 2)
        // The switch hangs from the leading hand toward the ground.
        let hand = CGPoint(x: -24, y: -61)
        let rod: Path = Art.svg("M-24,-61 Q-36,-40 -50,-14")
        Art.stroke(&g, rod, Art.color(0x6E8A3E), width: 2)
        let leaves: Path = Art.svg("M-34,-42 l-5,-2 M-40,-31 l-5,0 M-45,-22 l-4,2 M-30,-48 l-4,-4")
        Art.stroke(&g, leaves, Art.color(0x8EAE58), width: 1.6)
        Art.fill(&g, Art.circle(hand.x, hand.y, 5.4), Art.color(p.skin))
    }

    /// A finer knee-length kilt with a pleated front panel (Nemtynakht's best linen).
    static func overKiltShort(_ g: inout GraphicsContext) {
        let panel: Path = Art.svg("M-6,-66 L6,-66 L4,-32 L-8,-32Z")
        Art.fill(&g, panel, Art.color(0xFFFFFF, 0.7))
        Art.stroke(&g, Art.svg("M-4,-64 L-6,-33 M0,-64 L-1,-33 M4,-64 L3,-33"), Art.color(0xD8D0C2), width: 0.9)
    }

    /// Khunanup's wife, standing at her door.
    static func wife(_ g: inout GraphicsContext, mouth: Kit.Mouth = .smile, look: CGPoint = .zero, mirrored: Bool = false) {
        let p = wifeLook()
        Kit.shadow(&g, 0, 0, width: 48)
        Kit.person(&g, p, pose: .stand, look: look, mouth: mouth, mirrored: mirrored)
        // The two shoulder straps of the sheath dress.
        Art.stroke(&g, Art.svg("M-10,-108 L-7,-92 M8,-108 L6,-92"), Art.color(0xFFFFFF, 0.7), width: 2)
    }

    /// One of the children.
    static func child(_ g: inout GraphicsContext, girl: Bool, mouth: Kit.Mouth = .smile, mirrored: Bool = false) {
        let p = childLook(girl: girl)
        Kit.shadow(&g, 0, 0, width: 36)
        Kit.person(&g, p, pose: .stand, look: CGPoint(x: -0.3, y: 0), mouth: mouth, mirrored: mirrored)
    }

    /// One of the steward's officials, in a long kilt; `variant` 0 also carries a staff.
    static func official(_ g: inout GraphicsContext, variant: Int, mirrored: Bool = false) {
        let p = officialLook(variant)
        Kit.shadow(&g, 0, 0, width: 52)
        Kit.person(&g, p, pose: .stand, look: CGPoint(x: -0.4, y: 0), mouth: .flat, mirrored: mirrored)
        overKilt(&g)
        if variant == 0 {
            staffOfOffice(&g, x: -26, top: -170)
            Art.fill(&g, Art.circle(-24, -61, 5.4), Art.color(p.skin))
        }
    }
}

// MARK: - The donkeys and their loads (origin on the ground under mid-body, facing LEFT)

extension EloquentArt {
    /// A grey pack donkey with the dark stripe over its back and across its shoulders.
    /// `pack`: 0 none, 1 salt in a rope net, 2 reed bundles and a sack, 3 grain sacks.
    static func donkey(
        _ g: inout GraphicsContext,
        pack: Int,
        pose: Kit.BeastPose = .stand,
        mood: Kit.BeastMood = .calm,
        mirrored: Bool = false
    ) {
        let d = donkeyLook()
        Kit.shadow(&g, 0, 0, width: 124)
        Kit.beast(&g, d, pose: pose, mood: mood, look: .zero, mirrored: mirrored)
        let back: CGPoint = Kit.beastBack(d, pose: pose)
        let dark: Color = Art.color(d.dark)
        Art.stroke(&g, Art.line(back.x - 46, back.y + 3, back.x + 42, back.y + 4), dark.opacity(0.3), width: 2.6)
        var cross = Path()
        cross.move(to: CGPoint(x: back.x - 33, y: back.y + 2))
        cross.addQuadCurve(to: CGPoint(x: back.x - 37, y: back.y + 26), control: CGPoint(x: back.x - 31, y: back.y + 14))
        Art.stroke(&g, cross, dark.opacity(0.5), width: 3.6)
        if pack > 0 {
            donkeyPack(&g, x: back.x + 4, y: back.y, kind: pack)
        }
    }

    /// The load on a donkey's back, centred on the top of the back (x, y).
    static func donkeyPack(_ g: inout GraphicsContext, x: CGFloat, y: CGFloat, kind: Int) {
        Art.group(&g, x: x, y: y) { p in
            // A striped saddle cloth.
            let cloth: Path = Art.svg("M-27,-2 L27,-2 L25,17 L-25,17Z")
            Kit.solid(&p, cloth, Art.color(0xB5623A), light: 0.2, shade: 0.2)
            Art.clipped(&p, to: cloth) { c in
                Art.stroke(&c, Art.svg("M-30,5 L30,5 M-30,11 L30,11"), Art.color(0xE9C46A, 0.8), width: 1.6)
            }
            let bag: Path = Art.svg("M-24,-6 C-31,6 -29,30 -15,38 C-4,42 8,42 17,38 C30,30 32,6 25,-6 C10,-12 -10,-12 -24,-6Z")
            let top: Path = Art.svg("M-21,-4 C-22,-19 21,-19 21,-4Z")
            switch kind {
            case 1:
                Kit.solid(&p, top, Art.color(saltPinkHex), light: 0.2, shade: 0.22)
                Kit.solid(&p, bag, Art.color(saltHex), light: 0.18, shade: 0.26, rim: 1.6)
                ropeNet(&p, bag)
            case 2:
                reedBundle(&p)
                Kit.solid(&p, bag, Art.color(0xC9B48C), light: 0.22, shade: 0.26)
                Art.stroke(&p, Art.svg("M-14,4 Q-16,20 -10,34 M10,4 Q14,20 9,34"), Art.color(0xA08A62, 0.6), width: 1.2)
            default:
                Kit.solid(&p, top, Art.color(0xBFA77C), light: 0.2, shade: 0.22)
                Kit.solid(&p, bag, Art.color(0xCDB68A), light: 0.24, shade: 0.28)
                Art.stroke(&p, Art.svg("M-12,6 Q-14,20 -9,32 M8,8 Q12,20 8,32"), Art.color(0xA48C62, 0.6), width: 1.2)
            }
            // The girth rope over the load.
            Art.stroke(&p, Art.svg("M-2,-15 Q-4,14 -3,41"), Art.color(ropeHex), width: 2)
        }
    }

    /// A rope net over a bag: diagonal cords both ways, kept inside the bag.
    static func ropeNet(_ g: inout GraphicsContext, _ bag: Path) {
        var net = Path()
        for index in 0..<9 {
            let x: CGFloat = -40 + CGFloat(index) * 10
            net.move(to: CGPoint(x: x, y: -12))
            net.addLine(to: CGPoint(x: x + 30, y: 44))
            net.move(to: CGPoint(x: x + 30, y: -12))
            net.addLine(to: CGPoint(x: x, y: 44))
        }
        let cords: Path = net
        Art.clipped(&g, to: bag) { c in
            Art.stroke(&c, cords, Art.color(ropeHex, 0.85), width: 1.3)
        }
    }

    /// Bundles of reeds and straight staves lying along the back.
    static func reedBundle(_ g: inout GraphicsContext) {
        let bundle = Art.rect(-36, -17, 70, 13, radius: 6)
        Kit.solid(&g, bundle, Art.color(0xC9A860), light: 0.26, shade: 0.22)
        Art.clipped(&g, to: bundle) { c in
            Art.stroke(&c, Art.svg("M-36,-13 L34,-13 M-36,-9 L34,-9"), Art.color(0x9A7E40, 0.6), width: 1)
        }
        Art.stroke(&g, Art.svg("M-22,-18 L-22,-3 M18,-18 L18,-3"), Art.color(ropeHex), width: 2)
        Art.stroke(&g, Art.line(-40, -20, 38, -18), Art.color(0x8A6440), width: 2.6)
    }
}

// MARK: - Places and things

extension EloquentArt {
    /// A shallow lake with a white, slightly pink crust of salt and natron round its rim.
    /// The crust spans x0…x1 from `top` down `depth`; the water lies inside it.
    static func saltLake(_ g: inout GraphicsContext, x0: CGFloat, x1: CGFloat, top: CGFloat, depth: CGFloat, seed: UInt32) {
        let w: CGFloat = x1 - x0
        guard w > 0, depth > 0 else { return }
        var random = ArtRandom(seed)
        var crust = Path()
        for index in 0..<4 {
            let t: CGFloat = CGFloat(index) / 3
            let lx: CGFloat = x0 + w * (0.02 + 0.06 * Kit.rnd(&random)) + w * 0.1 * t
            let ly: CGFloat = top + depth * (0.08 * Kit.rnd(&random))
            let lw: CGFloat = w * (0.62 + 0.16 * Kit.rnd(&random))
            crust.addPath(Art.rect(lx, ly, lw, depth * (0.88 + 0.1 * t), radius: depth * 0.48))
        }
        let crustStops: Kit.Stops = [(Art.color(saltHex), 0), (Art.color(saltPinkHex), 0.7), (Art.color(0xE2CDBE), 1)]
        Art.fillLinear(&g, crust, crustStops, from: CGPoint(x: 0, y: top), to: CGPoint(x: 0, y: top + depth))
        let inset: CGFloat = depth * 0.62
        let water = Art.rect(x0 + inset * 1.4, top + depth * 0.2, w * 0.74, depth * 0.52, radius: depth * 0.26)
        let waterStops: Kit.Stops = [(Art.color(0xC9DADC), 0), (Art.color(lakeHex), 0.6), (Art.color(0x8FAAB6), 1)]
        Art.fillLinear(&g, water, waterStops, from: CGPoint(x: 0, y: top + depth * 0.2), to: CGPoint(x: 0, y: top + depth * 0.72))
        Art.clipped(&g, to: water) { c in
            Kit.rippleMarks(&c, x0: x0, x1: x1, y0: top + depth * 0.24, y1: top + depth * 0.7, count: 22, seed: seed &+ 3, color: Color.white, alpha: 0.45)
            Art.fill(&c, Art.rect(x0, top + depth * 0.2, w, depth * 0.06), Art.color(0xFFFFFF, 0.35))
        }
        // Cracks in the dry crust nearest us, like the top of a loaf.
        var cracks = Path()
        for _ in 0..<14 {
            let cx: CGFloat = x0 + w * Kit.rnd(&random)
            let cy: CGFloat = top + depth * (0.78 + 0.16 * Kit.rnd(&random))
            let run: CGFloat = 8 + 10 * Kit.rnd(&random)
            cracks.move(to: CGPoint(x: cx, y: cy))
            cracks.addLine(to: CGPoint(x: cx + run * 0.5, y: cy + 1.5))
            cracks.addLine(to: CGPoint(x: cx + run, y: cy - 0.5))
        }
        let crackLines: Path = cracks
        Art.clipped(&g, to: crust) { c in
            Art.stroke(&c, crackLines, Art.color(0xC9B2A4, 0.7), width: 1)
        }
    }

    /// A far date palm in one flat hazy colour: a thin curved trunk and drooping fronds.
    static func farPalm(_ g: inout GraphicsContext, x: CGFloat, baseY: CGFloat, height: CGFloat, color: Color, lean: CGFloat = 0) {
        let h: CGFloat = max(1, height)
        let topX: CGFloat = x + lean
        let topY: CGFloat = baseY - h
        var trunk = Path()
        trunk.move(to: CGPoint(x: x, y: baseY))
        trunk.addQuadCurve(to: CGPoint(x: topX, y: topY), control: CGPoint(x: x + lean * 0.1, y: baseY - h * 0.5))
        Art.stroke(&g, trunk, color, width: max(1, h * 0.045))
        var fronds = Path()
        let angles: [CGFloat] = [-170, -140, -112, -70, -40, -10, 20]
        for angle in angles {
            let a: CGFloat = Kit.deg(angle)
            let reach: CGFloat = h * 0.34
            let tipX: CGFloat = topX + cos(a) * reach
            let tipY: CGFloat = topY + sin(a) * reach * 0.5 + reach * 0.45
            let ctrlX: CGFloat = topX + cos(a) * reach * 0.6
            let ctrlY: CGFloat = topY + sin(a) * reach * 0.8
            fronds.move(to: CGPoint(x: topX, y: topY))
            fronds.addQuadCurve(to: CGPoint(x: tipX, y: tipY), control: CGPoint(x: ctrlX, y: ctrlY))
        }
        Art.stroke(&g, fronds, color, width: max(1, h * 0.05))
    }

    /// The peasant's house: whitewashed mud brick, a flat roof with a light reed shelter on
    /// it, a small high window, a clay store jar by the door.
    static func mudHouse(_ g: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, width: CGFloat, height: CGFloat) {
        let roofH: CGFloat = max(5, height * 0.09)
        let wallH: CGFloat = height - roofH
        Kit.house(&g, cx: cx, baseY: baseY, width: width, wallHeight: wallH, roofHeight: roofH, wall: 0xECE2CE, roof: 0xB89A6E, style: .flat, door: 0x5A3A2A, windows: 1)
        // Where the whitewash has worn off, the bricks show.
        var bricks = Path()
        let places: [(CGFloat, CGFloat)] = [(-0.42, 0.78), (-0.36, 0.86), (0.3, 0.82), (0.38, 0.9), (0.33, 0.74)]
        for place in places {
            let bx: CGFloat = cx + width * place.0
            let by: CGFloat = baseY - wallH * (1 - place.1)
            bricks.addPath(Art.rect(bx, by, width * 0.08, wallH * 0.05, radius: 1))
        }
        Art.fill(&g, bricks, Art.color(0xB98E62, 0.55))
        // The reed shelter on the roof.
        let roofTop: CGFloat = baseY - height
        let x0: CGFloat = cx + width * 0.06
        let x1: CGFloat = cx + width * 0.44
        let rise: CGFloat = height * 0.26
        var poles = Path()
        poles.move(to: CGPoint(x: x0 + 2, y: roofTop))
        poles.addLine(to: CGPoint(x: x0 + 2, y: roofTop - rise * 0.8))
        poles.move(to: CGPoint(x: x1 - 2, y: roofTop))
        poles.addLine(to: CGPoint(x: x1 - 2, y: roofTop - rise))
        Art.stroke(&g, poles, Art.color(0x7A5A3A), width: max(1, width * 0.014))
        let mat = Art.polygon([
            CGPoint(x: x0 - 3, y: roofTop - rise * 0.8), CGPoint(x: x1 + 3, y: roofTop - rise),
            CGPoint(x: x1 + 3, y: roofTop - rise * 0.88), CGPoint(x: x0 - 3, y: roofTop - rise * 0.68),
        ])
        Kit.solid(&g, mat, Art.color(0xC9A860), light: 0.26, shade: 0.2)
    }

    /// Rensi's chair with carved lion legs, in the units of a seated person (origin on the
    /// ground under the seat; the seat 34 high; the sitter faces LEFT).
    static func lionChair(_ g: inout GraphicsContext) {
        let wood: Color = Art.color(woodHex)
        let back = Art.svg("M27,-36 L30,-84 Q31,-88 35,-87 L37,-36Z")
        Kit.solid(&g, back, Kit.personTone(woodHex, 0.86), light: 0.2, shade: 0.26)
        let leg: String = "M0,-32 C-4,-24 -2,-15 -4,-9 C-5,-5 -8,-3 -11,-1 L-11,0 L3,0 C3,-4 4,-10 6,-16 C8,-22 8,-28 6,-32Z"
        let legXs: [CGFloat] = [-2, 28]
        for lx in legXs {
            let shape: Path = Kit.placed(leg, x: lx, y: 0)
            Kit.solid(&g, shape, wood, light: 0.28, shade: 0.24)
            Art.stroke(&g, Kit.placed("M-9,-1 l0,-2 M-6,-1 l0,-2.4", x: lx, y: 0), Kit.personTone(woodHex, 0.6), width: 1)
            let drum = Art.rect(lx - 12, -2, 17, 3, radius: 1.2)
            Art.fill(&g, drum, Kit.personTone(woodHex, 0.7))
        }
        let seat = Art.rect(-8, -38, 46, 6, radius: 2)
        Kit.solid(&g, seat, Kit.personTone(woodHex, 1.1), light: 0.3, shade: 0.2)
        let cushion = Art.rect(-4, -42, 36, 5, radius: 2.5)
        Kit.solid(&g, cushion, Art.color(0xE9DDC4), light: 0.26, shade: 0.2)
    }

    /// A column of bundled stems with a capital of closed lotus buds, painted in soft red,
    /// blue and green bands. `paint` sets how strong the painted bands are (low behind words).
    static func budColumn(_ g: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, width w: CGFloat, height h: CGFloat, color: UInt32, paint: Double) {
        guard w > 0, h > 0 else { return }
        let top: CGFloat = baseY - h
        let capH: CGFloat = w * 1.15
        let tieH: CGFloat = w * 0.42
        let baseH: CGFloat = w * 0.22
        let shaftTop: CGFloat = top + capH + tieH
        let shaftBottom: CGFloat = baseY - baseH
        let span: CGFloat = shaftBottom - shaftTop
        Kit.shadow(&g, cx, baseY, width: w * 2)
        var shaft = Path()
        shaft.move(to: CGPoint(x: cx - w * 0.4, y: shaftBottom))
        shaft.addQuadCurve(to: CGPoint(x: cx - w * 0.47, y: shaftTop), control: CGPoint(x: cx - w * 0.58, y: shaftBottom - span * 0.3))
        shaft.addLine(to: CGPoint(x: cx + w * 0.47, y: shaftTop))
        shaft.addQuadCurve(to: CGPoint(x: cx + w * 0.4, y: shaftBottom), control: CGPoint(x: cx + w * 0.58, y: shaftBottom - span * 0.3))
        shaft.closeSubpath()
        Kit.solid(&g, shaft, Art.color(color), light: 0.26, shade: 0.26)
        var stems = Path()
        let places: [CGFloat] = [-0.17, 0.17]
        for f in places {
            stems.move(to: CGPoint(x: cx + w * f, y: shaftTop))
            stems.addLine(to: CGPoint(x: cx + w * f * 0.9, y: shaftBottom))
        }
        Art.stroke(&g, stems, Kit.personTone(color, 0.8).opacity(0.6), width: 1.2)
        let hues: [UInt32] = [0xC8553D, 0x2F6F9E, 0x3FA27A, 0x2F6F9E, 0xC8553D]
        for index in 0..<5 {
            let y: CGFloat = top + capH + tieH * CGFloat(index) / 5
            let band = Art.rect(cx - w * 0.5, y, w, tieH / 5 - 0.6)
            Art.fill(&g, band, Art.color(hues[index], paint))
        }
        // Three closed buds: the middle one taller.
        let buds: [(CGFloat, CGFloat, CGFloat)] = [(-0.34, 0.5, 0.82), (0.34, 0.5, 0.82), (0, 0.62, 1)]
        for bud in buds {
            let bx: CGFloat = cx + w * bud.0
            let bw: CGFloat = w * bud.1
            let bh: CGFloat = capH * bud.2
            let foot: CGFloat = top + capH
            var shape = Path()
            shape.move(to: CGPoint(x: bx - bw / 2, y: foot))
            shape.addCurve(to: CGPoint(x: bx, y: foot - bh), control1: CGPoint(x: bx - bw * 0.66, y: foot - bh * 0.62), control2: CGPoint(x: bx - bw * 0.18, y: foot - bh))
            shape.addCurve(to: CGPoint(x: bx + bw / 2, y: foot), control1: CGPoint(x: bx + bw * 0.18, y: foot - bh), control2: CGPoint(x: bx + bw * 0.66, y: foot - bh * 0.62))
            shape.closeSubpath()
            Kit.solid(&g, shape, Kit.personTone(color, 1.04), light: 0.28, shade: 0.24)
            let sepal = Art.line(bx, foot - 1, bx, foot - bh * 0.6)
            Art.stroke(&g, sepal, Art.color(0x3FA27A, paint * 0.8), width: 1.3)
        }
        let abacus = Art.rect(cx - w * 0.34, top - capH * 0.1, w * 0.68, capH * 0.12, radius: 1)
        Kit.solid(&g, abacus, Kit.personTone(color, 0.94), light: 0.24, shade: 0.2)
        let plinth = Art.rect(cx - w * 0.62, baseY - baseH, w * 1.24, baseH, radius: baseH * 0.5)
        Kit.solid(&g, plinth, Kit.personTone(color, 0.92), light: 0.24, shade: 0.2)
    }

    /// A reed mat on the floor, `width` wide, centred on (cx, y).
    static func reedMat(_ g: inout GraphicsContext, cx: CGFloat, y: CGFloat, width: CGFloat) {
        let half: CGFloat = width / 2
        let mat = Art.polygon([
            CGPoint(x: cx - half + 6, y: y - 5), CGPoint(x: cx + half - 2, y: y - 5),
            CGPoint(x: cx + half, y: y + 5), CGPoint(x: cx - half, y: y + 5),
        ])
        Kit.solid(&g, mat, Art.color(0xD9B977), light: 0.22, shade: 0.16)
        var weave = Path()
        var x: CGFloat = cx - half + 4
        while x < cx + half - 2 {
            weave.move(to: CGPoint(x: x + 2, y: y - 4))
            weave.addLine(to: CGPoint(x: x, y: y + 4))
            x += 6
        }
        let lines: Path = weave
        Art.clipped(&g, to: mat) { c in
            Art.stroke(&c, lines, Art.color(0xA88A4E, 0.5), width: 1)
        }
    }

    /// The fine linen cloth with fringed ends, lying flat across a path from x0 to x1.
    static func fringedCloth(_ g: inout GraphicsContext, x0: CGFloat, x1: CGFloat, y: CGFloat, depth: CGFloat, skew: CGFloat) {
        let quad = Art.polygon([
            CGPoint(x: x0 + skew, y: y), CGPoint(x: x1 + skew, y: y),
            CGPoint(x: x1, y: y + depth), CGPoint(x: x0, y: y + depth),
        ])
        Kit.solid(&g, quad, Art.color(linenHex), light: 0.3, shade: 0.18)
        let inset: CGFloat = depth * 0.2
        var stripes = Path()
        stripes.move(to: CGPoint(x: x0 + skew * 0.8, y: y + inset))
        stripes.addLine(to: CGPoint(x: x1 + skew * 0.8, y: y + inset))
        stripes.move(to: CGPoint(x: x0 + skew * 0.2, y: y + depth - inset))
        stripes.addLine(to: CGPoint(x: x1 + skew * 0.2, y: y + depth - inset))
        Art.stroke(&g, stripes, Art.color(ramp.accent, 0.55), width: 1.4)
        var folds = Path()
        folds.move(to: CGPoint(x: x0 + (x1 - x0) * 0.35 + skew * 0.5, y: y + 1))
        folds.addQuadCurve(to: CGPoint(x: x0 + (x1 - x0) * 0.4, y: y + depth - 1), control: CGPoint(x: x0 + (x1 - x0) * 0.32, y: y + depth * 0.5))
        Art.stroke(&g, folds, Art.color(0xD8CDB8, 0.8), width: 1.2)
        var fringe = Path()
        for index in 0..<7 {
            let t: CGFloat = (CGFloat(index) + 0.5) / 7
            let ly: CGFloat = y + depth * t
            let lx: CGFloat = x0 + skew * (1 - t)
            let rx: CGFloat = x1 + skew * (1 - t)
            fringe.move(to: CGPoint(x: lx, y: ly))
            fringe.addLine(to: CGPoint(x: lx - 5, y: ly + 0.6))
            fringe.move(to: CGPoint(x: rx, y: ly))
            fringe.addLine(to: CGPoint(x: rx + 5, y: ly + 0.6))
        }
        Art.stroke(&g, fringe, Art.color(0xE2D8C4), width: 1.2)
    }

    /// A long papyrus roll unrolled flat across a floor from x0 to x1: pale sheets joined end
    /// to end, with columns of small dark marks and here and there a red line. No readable signs.
    static func papyrusRun(_ g: inout GraphicsContext, x0: CGFloat, x1: CGFloat, y: CGFloat, depth: CGFloat) {
        guard x1 > x0 else { return }
        ArtStyle.contactShadow(&g, (x0 + x1) / 2, y + depth, (x1 - x0) * 0.52, depth * 0.4, alpha: 0.18)
        let sheet = Art.rect(x0, y, x1 - x0, depth, radius: 1)
        let tone: Kit.Stops = [(Art.color(0xF6EBCB), 0), (Art.color(0xE9D7A8), 1)]
        Art.fillLinear(&g, sheet, tone, from: CGPoint(x: 0, y: y), to: CGPoint(x: 0, y: y + depth))
        var black = Path()
        var red = Path()
        var joins = Path()
        var index: Int = 0
        var x: CGFloat = x0 + 5
        while x < x1 - 4 {
            if index % 7 == 3 {
                red.move(to: CGPoint(x: x, y: y + depth * 0.2))
                red.addLine(to: CGPoint(x: x, y: y + depth * 0.42))
            }
            black.move(to: CGPoint(x: x, y: y + depth * 0.2))
            black.addLine(to: CGPoint(x: x, y: y + depth * 0.82))
            if index % 10 == 9 {
                joins.move(to: CGPoint(x: x + 2.5, y: y))
                joins.addLine(to: CGPoint(x: x + 2.5, y: y + depth))
            }
            x += 4.6
            index += 1
        }
        Art.stroke(&g, joins, Art.color(0xCDB98A, 0.8), width: 0.8)
        Art.stroke(&g, black, Art.color(inkHex, 0.55), width: 1.2, cap: .butt, dash: [1.6, 1.2])
        Art.stroke(&g, red, Art.color(redInkHex, 0.85), width: 1.3, cap: .butt, dash: [1.6, 1.2])
        Art.fill(&g, Art.rect(x0, y, x1 - x0, 1.2), Color.white.opacity(0.4))
    }
}

// MARK: - The scribe, the boat, the landing

extension EloquentArt {
    /// The scribe sitting cross-legged on his mat, the kilt pulled tight over his knees for a
    /// desk, a papyrus roll across it, writing with a reed pen; another pen behind his ear.
    /// Origin on the floor under him; he faces LEFT, head bent to the roll.
    static func scribe(_ g: inout GraphicsContext, mirrored: Bool = false, looksUp: Bool = false) {
        let p = scribeLook()
        let skin: Color = Art.color(p.skin)
        let skinDark: Color = Kit.personTone(p.skin, 0.84)
        reedMat(&g, cx: 4, y: 0, width: 112)
        Kit.shadow(&g, 0, -1, width: 82, alpha: 0.22)
        // Crossed legs, then the kilt stretched over the knees.
        let legs: Path = Art.svg("M-37,-3 C-39,-16 -24,-23 0,-23 C24,-23 39,-16 37,-3 C24,1 -24,1 -37,-3Z")
        Kit.solid(&g, legs, skin, light: 0.22, shade: 0.24)
        var feet = Path()
        feet.addPath(Art.ellipse(-31, -5, 7, 3.6))
        feet.addPath(Art.ellipse(33, -7, 6.5, 3.4))
        Art.fill(&g, feet, skinDark)
        let kilt: Path = Art.svg("M-30,-8 C-30,-21 -18,-27 0,-27 C18,-27 30,-21 30,-8 C18,-4 -18,-4 -30,-8Z")
        Kit.solid(&g, kilt, Art.color(p.cloth), light: 0.24, shade: 0.2)
        // The far arm, holding the roll.
        Art.stroke(&g, Art.svg("M14,-72 Q22,-50 16,-34"), skinDark, width: 9.5)
        // The torso, upright and bare.
        let torso: Path = Art.svg("M-14,-25 L-17,-70 Q-17,-78 -8,-78 L10,-78 Q18,-78 17,-70 L15,-25Z")
        Kit.solid(&g, torso, skin, light: 0.24, shade: 0.22)
        Art.stroke(&g, Art.svg("M-15,-28 Q0,-24 15,-28"), Art.color(p.cloth), width: 4)
        Art.stroke(&g, Art.line(0, -76, -1, -88), Kit.personTone(p.skin, 0.9), width: 12)
        // The roll across the knees.
        let roll = Art.rect(-27, -36, 46, 8, radius: 3)
        Kit.solid(&g, roll, Art.color(0xF3E6C2), light: 0.28, shade: 0.22)
        var marks = Path()
        var mx: CGFloat = -22
        while mx < 12 {
            marks.move(to: CGPoint(x: mx, y: -34.5))
            marks.addLine(to: CGPoint(x: mx, y: -30))
            mx += 3.4
        }
        Art.stroke(&g, marks, Art.color(inkHex, 0.5), width: 1, cap: .butt, dash: [1.2, 0.9])
        Art.fill(&g, Art.ellipse(20, -32, 3.2, 4.6), Art.color(0xE2D0A0))
        Art.fill(&g, Art.circle(16, -33, 5.2), skinDark)
        // The near arm, the pen hand over the roll.
        Art.stroke(&g, Art.svg("M-13,-72 Q-28,-52 -16,-37"), skin, width: 10)
        Art.stroke(&g, Art.line(-16, -38, -24, -49), Art.color(0x9A8450), width: 1.6)
        Art.fill(&g, Art.circle(-16, -37, 5.4), skin)
        let look: CGPoint = looksUp ? CGPoint(x: -0.5, y: -0.2) : CGPoint(x: -0.3, y: 0.8)
        Art.group(&g, x: -2, y: -106, rotate: looksUp ? 0 : Kit.deg(-6)) { h in
            Kit.personHead(&h, p, look: look, mouth: .flat, closedEyes: false, mirrored: mirrored)
            Art.stroke(&h, Art.line(18, -10, 33, 9), Art.color(0x9A8450), width: 1.8)
        }
        // His palette and water pot beside him on the mat.
        let palette = Art.rect(34, -5, 20, 4, radius: 1)
        Kit.solid(&g, palette, Art.color(0xA87A48), light: 0.26, shade: 0.2)
        Art.fill(&g, Art.circle(39, -3, 1.3), Art.color(inkHex))
        Art.fill(&g, Art.circle(43.5, -3, 1.3), Art.color(redInkHex))
        Kit.pot(&g, cx: 56, baseY: -1, width: 11, height: 12, color: 0xB5683A)
    }

    /// Rensi's Nile boat at the landing: the kit's Nile hull and bare mast, with a painted
    /// cabin amidships, a second steering oar and a furled sail on the yard. Bow LEFT.
    static func stewardBoat(_ g: inout GraphicsContext, cx: CGFloat, waterY: CGFloat, length L: CGFloat) {
        let hull: UInt32 = 0x9A6A3E
        Kit.boat(&g, cx: cx, waterY: waterY, length: L, hull: hull, sail: nil, style: .nile)
        // The furled sail along the yard.
        let yardY: CGFloat = waterY - L * 0.61
        let furl = Art.rect(cx - L * 0.3, yardY - L * 0.012, L * 0.6, L * 0.028, radius: L * 0.014)
        Kit.solid(&g, furl, Art.color(0xEFE6D2), light: 0.26, shade: 0.24)
        // The cabin of painted wood and reed matting, a little aft of the mast.
        let cabinX: CGFloat = cx + L * 0.04
        let cabinW: CGFloat = L * 0.24
        let cabinH: CGFloat = L * 0.12
        let deckY: CGFloat = waterY - L * 0.1
        let cabin = Art.rect(cabinX, deckY - cabinH, cabinW, cabinH, radius: 2)
        Kit.solid(&g, cabin, Art.color(0xE9DDC2), light: 0.28, shade: 0.24)
        let bandH: CGFloat = cabinH * 0.14
        let hues: [UInt32] = [0x2F6F9E, 0xC8553D, 0x3FA27A]
        Art.clipped(&g, to: cabin) { c in
            for index in 0..<3 {
                let y: CGFloat = deckY - cabinH + bandH * (0.4 + 1.3 * CGFloat(index))
                Art.fill(&c, Art.rect(cabinX, y, cabinW, bandH * 0.8), Art.color(hues[index], 0.8))
            }
            var mats = Path()
            var x: CGFloat = cabinX + 4
            while x < cabinX + cabinW {
                mats.move(to: CGPoint(x: x, y: deckY - cabinH * 0.5))
                mats.addLine(to: CGPoint(x: x, y: deckY))
                x += 4
            }
            Art.stroke(&c, mats, Art.color(0xB89A62, 0.7), width: 1)
        }
        let roofLine = Art.rect(cabinX - 3, deckY - cabinH - 3, cabinW + 6, 4, radius: 2)
        Kit.solid(&g, roofLine, Art.color(0x7A5230), light: 0.26, shade: 0.2)
        // The second steering oar, beside the kit's.
        let oarTop = CGPoint(x: cx + L * 0.38, y: waterY - L * 0.33)
        let oarFoot = CGPoint(x: cx + L * 0.5, y: waterY + L * 0.02)
        Art.stroke(&g, Art.line(oarTop.x, oarTop.y, oarFoot.x, oarFoot.y), Art.color(0x6A4426), width: max(1.2, L * 0.014))
        Art.stroke(&g, Art.line(oarFoot.x - L * 0.02, oarFoot.y - L * 0.06, oarFoot.x + L * 0.01, oarFoot.y + L * 0.02), Art.color(0x7A5230), width: max(2.4, L * 0.034))
    }

    /// The stone landing: a quay from x0 to the right edge, top at `top`, with three steps
    /// down its left side to the water at `waterY`.
    static func landing(_ g: inout GraphicsContext, x0: CGFloat, x1: CGFloat, top: CGFloat, waterY: CGFloat, bottom: CGFloat) {
        let stone: UInt32 = 0xD9C7A6
        let quay = CGRect(x: x0, y: top, width: x1 - x0, height: bottom - top)
        Kit.wall(&g, rect: quay, color: stone)
        let rise: CGFloat = (waterY - top) / 3
        for index in 0..<3 {
            let i: CGFloat = CGFloat(index)
            let stepX: CGFloat = x0 - 22 * (i + 1)
            let stepY: CGFloat = top + rise * (i + 1)
            let step = CGRect(x: stepX, y: stepY, width: 22, height: max(1, bottom - stepY))
            let k: CGFloat = 0.96 - 0.04 * i
            Kit.wall(&g, rect: step, color: Kit.builtHex(stone, k))
            Art.fill(&g, Art.rect(stepX, stepY, 22, 2), Color.white.opacity(0.35))
        }
        Art.fill(&g, Art.rect(x0, top, x1 - x0, 2.4), Color.white.opacity(0.4))
        // A mooring post at the head of the steps.
        let post = Art.rect(x0 + 8, top - 16, 7, 18, radius: 3)
        Kit.solid(&g, post, Art.color(0x8A6440), light: 0.26, shade: 0.24)
    }
}
