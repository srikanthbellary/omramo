import SwiftUI
import OmramoCore

// The cast and the shared parts of "The Horse and the Olive": the palette, the two lights, the
// two gods with their helmet, spear, shield and trident, King Cecrops and his townspeople, the
// white horse, the goats and the owl. The story's own places and things (the rock, the huts,
// the young olive tree, the spray) follow in the second half of this file.

extension OliveArt {
    // MARK: Palette

    /// A bright, dry Attic day: blue-white sky, honey limestone, silver-green olive, sea blue.
    static let ramp = ArtStyle.Ramp(deep: 0x12294A, shade: 0x5E7A52, mid: 0x9DB08A, light: 0xE3F0FA, glow: 0xFBE7B0, accent: 0xF5A623)

    static let stoneHex: UInt32 = 0xDDCFAE
    static let stoneShadeHex: UInt32 = 0xBFAE8A
    static let brickHex: UInt32 = 0xC9A27A
    static let thatchHex: UInt32 = 0xC2A45E
    static let clayHex: UInt32 = 0xC47A4A
    static let bronzeHex: UInt32 = 0xC9993F
    static let seaHex: UInt32 = 0x3E7FB4
    static let scrubHex: UInt32 = 0x8A8F5A
    static let strawHex: UInt32 = 0xC9B45A
    static let barkHex: UInt32 = 0x9A9484
    static let woolHex: UInt32 = 0xD9C8A0

    // MARK: Light — both skies pale

    /// High, clear Mediterranean daylight.
    static func day() -> Kit.Light {
        let sky: Kit.Stops = [(Art.color(0xBCDCF2), 0), (Art.color(0xDCEEF8), 0.55), (Art.color(0xFBF1D6), 1)]
        return Kit.Light(sky: sky, sun: 0xFFF7DC, glow: 0xFBE7B0, haze: 0xE4EFF2, far: 0xB4C3CC, mid: 0xCDBF9E, near: 0xB7A47C)
    }

    /// The olive scene: late afternoon, a little warmer, the sky still pale.
    static func gold() -> Kit.Light {
        let sky: Kit.Stops = [(Art.color(0xCDE3EE), 0), (Art.color(0xE6F1F4), 0.5), (Art.color(0xFBEFCB), 1)]
        return Kit.Light(sky: sky, sun: 0xFFF2C8, glow: 0xFBE0A0, haze: 0xF0ECDA, far: 0xC2C6B8, mid: 0xD6C298, near: 0xBFA878)
    }

    /// Olive leaves: dark green above, silver beneath.
    static func oliveLeaves() -> Kit.Greens {
        Kit.greens(0x41583F, 0x5E7A52, 0x7F9A70, 0xA9BE98, 0xD9E6CE)
    }

    // MARK: Looks

    /// Athena: tall and calm, dark hair, a long pale belted robe.
    static func athenaLook() -> Kit.Person {
        Kit.Person(
            age: .adult,
            skin: 0xD9A87C,
            hair: 0x3A2A22,
            hairStyle: .short,
            beard: .none,
            headwear: .none,
            garment: .robe,
            cloth: 0xF1E8D2,
            trim: 0xB98A3A,
            legs: 0xB98A5A,
            showsEyeWhite: false
        )
    }

    /// Poseidon: broad and bare-armed, sea-blue hair and beard, a cloak the colour of deep water.
    static func poseidonLook() -> Kit.Person {
        Kit.Person(
            age: .adult,
            skin: 0xC98E60,
            hair: 0x2E6E8C,
            hairStyle: .long,
            beard: .long,
            headwear: .none,
            garment: .wrapper,
            cloth: 0x1F5F8B,
            trim: 0x8CC7DE,
            legs: 0xC98E60,
            showsEyeWhite: false
        )
    }

    /// King Cecrops: lean and grey-haired, dressed like his own people.
    static func cecropsLook() -> Kit.Person {
        Kit.Person(
            age: .elder,
            skin: 0xC08A5C,
            hair: 0xB8B4AC,
            hairStyle: .short,
            beard: .short,
            headwear: .none,
            garment: .chiton,
            cloth: 0xCDB98E,
            trim: 0x8A5A32,
            legs: 0xC08A5C,
            showsEyeWhite: false
        )
    }

    /// The townspeople, sun-browned and dark-haired, in undyed and earth-coloured wool.
    /// 0 a young man, 1 a woman, 2 the old woman, 3 the small girl, 4 a bearded man,
    /// 5 a second woman, 6 a boy.
    static func folkLook(_ kind: Int) -> Kit.Person {
        switch kind {
        case 0:
            return Kit.Person(age: .adult, skin: 0xC48A5C, hair: 0x2E221C, hairStyle: .curly, garment: .chiton, cloth: 0xD9C8A0, trim: 0x9A5A32, legs: 0xC48A5C, showsEyeWhite: false)
        case 1:
            return Kit.Person(age: .adult, skin: 0xCB9466, hair: 0x33261E, hairStyle: .short, headwear: .kerchief, headwearColor: 0xE6DCC4, garment: .robe, cloth: 0xD4B890, trim: 0xA8683A, legs: 0xB07A50, showsEyeWhite: false)
        case 2:
            return Kit.Person(age: .elder, skin: 0xB97F52, hair: 0xC4C0B8, hairStyle: .short, headwear: .kerchief, headwearColor: 0xCDBFA2, garment: .robe, cloth: 0xB39A78, trim: 0x7A5A3A, legs: 0xA06E46, showsEyeWhite: false)
        case 3:
            return Kit.Person(age: .child, skin: 0xCB9466, hair: 0x2E221C, hairStyle: .bob, garment: .chiton, cloth: 0xEADFC0, trim: 0xC47A4A, legs: 0xCB9466, showsEyeWhite: false)
        case 4:
            return Kit.Person(age: .adult, skin: 0xB97F52, hair: 0x33261E, hairStyle: .short, beard: .short, garment: .chiton, cloth: 0xBFA57A, trim: 0x6E4A2E, legs: 0xB97F52, showsEyeWhite: false)
        case 5:
            return Kit.Person(age: .adult, skin: 0xC48A5C, hair: 0x3A2A22, hairStyle: .bun, garment: .robe, cloth: 0xC9A27A, trim: 0x8A5A32, legs: 0xA87248, showsEyeWhite: false)
        default:
            return Kit.Person(age: .child, skin: 0xC48A5C, hair: 0x33261E, hairStyle: .curly, garment: .chiton, cloth: 0xCDB98E, trim: 0x8A5A32, legs: 0xC48A5C, showsEyeWhite: false)
        }
    }

    // MARK: Joints the kit does not hand out

    /// Draws `body` in the units of a person's head (origin at the head's centre), for the
    /// helmet, a headband or heavy brows laid over the kit's head.
    static func onHead(_ context: inout GraphicsContext, _ p: Kit.Person, pose: Kit.Pose, _ body: (inout GraphicsContext) -> Void) {
        let f = Kit.bodyFrame(p)
        let r = Kit.bodyRig(p, pose)
        let c = Kit.bodyHeadCentre(f, r)
        let tilt: CGFloat = -Kit.deg(r.lean) * 0.45
        Art.group(&context, x: c.x, y: c.y, rotate: tilt, scale: f.headScale, body)
    }

    /// Where the far hand is for `pose`, in the person's own units.
    static func farHand(_ p: Kit.Person, pose: Kit.Pose) -> CGPoint {
        let f = Kit.bodyFrame(p)
        let r = Kit.bodyRig(p, pose)
        let s = Kit.bodyShoulder(r, near: false)
        let x: CGFloat = (s.x + r.farHand.x) * f.k
        let y: CGFloat = (s.y + r.farHand.y) * f.k
        return CGPoint(x: x, y: y)
    }

    // MARK: Athena

    /// The bronze helmet pushed back off the brow, with its horsehair crest, in head units.
    static func helmet(_ g: inout GraphicsContext) {
        let crest: Path = Art.svg("M-12,-45 C-4,-64 26,-62 36,-38 C40,-27 38,-14 31,-6 C32,-22 24,-38 8,-42 C1,-43.5 -6,-43 -12,-45Z")
        Kit.solid(&g, crest, Art.color(0xA8503A), light: 0.24, shade: 0.24)
        let hairs: Path = Art.svg("M-4,-50 C6,-57 22,-53 30,-37 M4,-47 C13,-50 24,-44 32,-25 M-8,-47 C-2,-52 4,-54 10,-54")
        Art.stroke(&g, hairs, Art.color(0x7E3626, 0.8), width: 1.2)
        let dome: Path = Art.svg("M-27.5,-17 C-31,-35 -16,-45 0,-45 C16,-45 31,-35 27.5,-17 C18,-23.5 -18,-23.5 -27.5,-17Z")
        Kit.solid(&g, dome, Art.color(bronzeHex), light: 0.34, shade: 0.24, rim: 1.6)
        // The face guard, tipped up: its two empty eye slots and the nose guard between them.
        let slots: Path = Art.svg("M-15,-29.5 C-12,-33.5 -6,-33.5 -3,-29.5 C-6,-27.5 -12,-27.5 -15,-29.5Z M3,-29.5 C6,-33.5 12,-33.5 15,-29.5 C12,-27.5 6,-27.5 3,-29.5Z")
        Art.fill(&g, slots, Art.color(0x5A3A1E, 0.85))
        let dark: Color = Kit.personTone(bronzeHex, 0.7)
        Art.stroke(&g, Art.line(0, -34, 0, -23.5), dark, width: 1.6)
        Art.stroke(&g, Art.svg("M-27,-18 C-18,-24.5 18,-24.5 27,-18"), dark, width: 2)
        Art.stroke(&g, Art.svg("M-20,-36 C-14,-41 -7,-43.5 0,-43.5"), Art.color(0xFFF2C8, 0.6), width: 1.6)
    }

    /// A long spear standing with its butt on (x, y), `length` long, its head leaning `lean`
    /// radians to the right.
    static func spear(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, length: CGFloat, lean: CGFloat = 0) {
        Art.group(&context, x: x, y: y, rotate: lean) { g in
            Kit.propShaft(&g, 0, 0, 0, -length, wood: 0x8A6A44, width: 4)
            Art.fill(&g, Art.svg("M-2,0 L0,7 L2,0Z"), Art.color(bronzeHex))
            Art.group(&g, x: 0, y: -length) { t in
                let blade: Path = Art.svg("M0,-30 C6,-17 5,-5 2,0 L-2,0 C-5,-5 -6,-17 0,-30Z")
                Kit.solid(&t, blade, Art.color(bronzeHex), light: 0.36, shade: 0.24, rim: 1)
                Art.stroke(&t, Art.line(0, -24, 0, -2), Kit.personTone(bronzeHex, 0.72), width: 1)
                Art.fill(&t, Art.rect(-3, -1, 6, 5, radius: 1.5), Kit.personTone(bronzeHex, 0.8))
            }
        }
    }

    /// The round shield, seen from the front, centred on (cx, cy): a bronze rim, a leather
    /// face and one plain ring. No device on it.
    static func shield(_ context: inout GraphicsContext, cx: CGFloat, cy: CGFloat, r: CGFloat) {
        var disc = Path()
        disc.addEllipse(in: CGRect(x: cx - r * 0.94, y: cy - r, width: r * 1.88, height: r * 2))
        Kit.solid(&context, disc, Art.color(bronzeHex), light: 0.34, shade: 0.26, rim: 2)
        let face: Path = Art.ellipse(cx, cy, r * 0.78, r * 0.83)
        Kit.solid(&context, face, Art.color(0xB8683C), light: 0.26, shade: 0.24)
        Art.stroke(&context, Art.ellipse(cx, cy, r * 0.5, r * 0.53), Art.color(bronzeHex, 0.9), width: max(1.4, r * 0.06))
        let boss: Path = Art.ellipse(cx, cy, r * 0.16, r * 0.17)
        Kit.solid(&context, boss, Art.color(bronzeHex), light: 0.4, shade: 0.2)
        ArtStyle.rimLight(&context, cx, cy, r * 0.9, alpha: 0.22)
    }

    /// A small twig of olive whose cut end is at (x, y), pointing along `angle` (radians).
    static func oliveTwig(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, angle: CGFloat, length: CGFloat) {
        var dark = Path()
        var pale = Path()
        var stem = Path()
        oliveSpray(&dark, &pale, &stem, from: CGPoint(x: x, y: y), angle: angle, length: length, leaf: length * 0.42, pairs: 3)
        Art.stroke(&context, stem, Art.color(0x7A7260), width: max(1.2, length * 0.05))
        Art.fill(&context, dark, Art.color(0x4E6A48))
        Art.fill(&context, pale, Art.color(0xDCE8D2))
        let fx: CGFloat = x + cos(angle) * length * 0.3
        let fy: CGFloat = y + sin(angle) * length * 0.3 + length * 0.12
        olive(&context, x: fx, y: fy, r: max(2, length * 0.09), ripe: true)
    }

    /// Athena, facing LEFT; origin at her feet (the ground under her knees when she kneels).
    /// `armed`: the spear upright in her leading hand and the shield at her side (standing).
    /// `twig`: a small twig of olive in her leading hand.
    static func athena(
        _ context: inout GraphicsContext,
        pose: Kit.Pose = .stand,
        look: CGPoint = .zero,
        mouth: Kit.Mouth = .smile,
        armed: Bool = false,
        twig: Bool = false,
        mirrored: Bool = false
    ) {
        let p = athenaLook()
        let hand: CGPoint = Kit.hand(p, pose: pose)
        if armed {
            shield(&context, cx: 36, cy: -50, r: 42)
        }
        Kit.person(&context, p, pose: pose, look: look, mouth: mouth, mirrored: mirrored)
        onHead(&context, p, pose: pose) { g in
            helmet(&g)
        }
        if armed {
            spear(&context, x: hand.x - 3, y: 2, length: 236, lean: 0.02)
            Art.fill(&context, Art.circle(hand.x, hand.y, 6), Art.color(p.skin))
        }
        if twig {
            oliveTwig(&context, x: hand.x, y: hand.y + 2, angle: Kit.deg(-110), length: 30)
            Art.fill(&context, Art.circle(hand.x, hand.y, 5.5), Art.color(p.skin))
        }
    }

    // MARK: Poseidon

    /// The trident standing with its butt on (x, y), `length` to the foot of the fork, leaning
    /// `lean` radians to the right.
    static func trident(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, length: CGFloat, lean: CGFloat = 0) {
        Art.group(&context, x: x, y: y, rotate: lean) { g in
            Kit.propShaft(&g, 0, 0, 0, -length, wood: 0x7A5A36, width: 5)
            Art.group(&g, x: 0, y: -length) { t in
                let fork: Path = Art.svg("M-3,5 L-3,-8 C-11,-8 -16,-13 -16,-23 L-16,-42 L-12.5,-50 L-9,-42 L-9,-25 C-9,-18 -6,-15 -3,-15 L-3,-46 L0,-56 L3,-46 L3,-15 C6,-15 9,-18 9,-25 L9,-42 L12.5,-50 L16,-42 L16,-23 C16,-13 11,-8 3,-8 L3,5Z")
                Kit.solid(&t, fork, Art.color(bronzeHex), light: 0.36, shade: 0.24, rim: 1.2)
            }
        }
    }

    /// What the kit's head lacks for Poseidon: big eyebrows, weed-wet strands, beard curls.
    static func poseidonHead(_ g: inout GraphicsContext) {
        let p = poseidonLook()
        let brows: Path = Art.svg("M-17.5,-7.5 q6.5,-5.5 12.5,-1.5 M5,-9 q6.5,-4.5 12.5,1.5")
        Art.stroke(&g, brows, Kit.personTone(p.hair, 0.7), width: 3.8)
        let weed: Path = Art.svg("M-30,6 C-37,20 -28,34 -35,52 M30,6 C37,20 28,34 35,54 M-23,30 C-27,40 -21,48 -25,58 M24,30 C28,40 22,48 26,58")
        Art.stroke(&g, weed, Kit.personTone(p.hair, 1.3), width: 2)
        let curls: Path = Art.svg("M-13,29 q3,4.5 6,0 M5,31 q3,4.5 6,0 M-4,39 q3,4.5 6,0 M-16,20 q2.5,4 5,0 M11,21 q2.5,4 5,0")
        Art.stroke(&g, curls, Kit.personTone(p.hair, 1.4), width: 1.4)
    }

    /// A little sea spray blowing in `rect`: white drops and two or three torn wisps.
    static func spray(_ context: inout GraphicsContext, in rect: CGRect, seed: UInt32) {
        Kit.flecks(&context, in: rect, count: 16, seed: seed, color: Art.color(0xFFFFFF, 0.95), radius: 1.0...2.6)
        Kit.flecks(&context, in: rect, count: 10, seed: seed &+ 5, color: Art.color(0xA9CDE6, 0.8), radius: 0.8...1.8)
        var wisps = Path()
        let x: CGFloat = rect.minX
        let y: CGFloat = rect.minY
        let w: CGFloat = rect.width
        let h: CGFloat = rect.height
        wisps.move(to: CGPoint(x: x + w * 0.1, y: y + h * 0.3))
        wisps.addQuadCurve(to: CGPoint(x: x + w * 0.5, y: y + h * 0.22), control: CGPoint(x: x + w * 0.3, y: y + h * 0.1))
        wisps.move(to: CGPoint(x: x + w * 0.45, y: y + h * 0.7))
        wisps.addQuadCurve(to: CGPoint(x: x + w * 0.9, y: y + h * 0.6), control: CGPoint(x: x + w * 0.7, y: y + h * 0.5))
        Art.stroke(&context, wisps, Art.color(0xFFFFFF, 0.8), width: 2)
    }

    /// Poseidon, facing LEFT; origin at his feet. `trident`: the three-pronged spear upright in
    /// his leading hand (standing) or held high (`.reach`).
    static func poseidon(
        _ context: inout GraphicsContext,
        pose: Kit.Pose = .stand,
        look: CGPoint = .zero,
        mouth: Kit.Mouth = .grin,
        trident held: Bool = true,
        mirrored: Bool = false
    ) {
        let p = poseidonLook()
        let hand: CGPoint = Kit.hand(p, pose: pose)
        Kit.person(&context, p, pose: pose, look: look, mouth: mouth, mirrored: mirrored)
        onHead(&context, p, pose: pose) { g in
            poseidonHead(&g)
        }
        if held {
            if pose == .reach {
                // Held high: the shaft slants up through the raised fist.
                trident(&context, x: hand.x + 26, y: hand.y + 150, length: 236, lean: -0.17)
            } else {
                trident(&context, x: hand.x - 3, y: 2, length: 212, lean: -0.02)
            }
            Art.fill(&context, Art.circle(hand.x, hand.y, 6.5), Art.color(p.skin))
        }
        spray(&context, in: CGRect(x: -70, y: -200, width: 140, height: 150), seed: 31)
    }

    // MARK: Cecrops and the townspeople

    /// King Cecrops, facing LEFT; origin at his feet: a cloth band round his head and a wooden
    /// staff in his far hand. `pebble`: he holds a pebble up (use with `.reach`).
    static func cecrops(
        _ context: inout GraphicsContext,
        pose: Kit.Pose = .stand,
        look: CGPoint = .zero,
        mouth: Kit.Mouth = .smile,
        pebble: Bool = false,
        mirrored: Bool = false
    ) {
        let p = cecropsLook()
        Kit.person(&context, p, pose: pose, look: look, mouth: mouth, mirrored: mirrored)
        onHead(&context, p, pose: pose) { g in
            headband(&g)
        }
        let far: CGPoint = farHand(p, pose: pose)
        Kit.propShaft(&context, far.x - 5, 1, far.x + 12, -146, wood: 0x8A6A44, width: 4.5)
        Art.fill(&context, Art.circle(far.x, far.y, 5.2), Kit.personTone(p.skin, 0.86))
        if pebble {
            let hand: CGPoint = Kit.hand(p, pose: pose)
            var stone = Path()
            stone.addEllipse(in: CGRect(x: hand.x - 6, y: hand.y - 11, width: 9, height: 7))
            Kit.solid(&context, stone, Art.color(0xE8E4DA), light: 0.3, shade: 0.3)
        }
    }

    /// The plain band of cloth round the king's head, in head units.
    static func headband(_ g: inout GraphicsContext) {
        let band: Path = Art.svg("M-26,-12 C-13,-18.5 13,-18.5 26,-12")
        Art.stroke(&g, band, Art.color(0x9A8A6A), width: 5.4)
        Art.stroke(&g, band, Art.color(0xEDE2C8), width: 3.8)
        Art.stroke(&g, Art.svg("M25,-11 C30,-6 31,2 29,8"), Art.color(0xEDE2C8), width: 2.6)
    }

    /// One of the townspeople (see `folkLook`), facing LEFT; origin at the feet.
    static func folk(
        _ context: inout GraphicsContext,
        _ kind: Int,
        pose: Kit.Pose = .stand,
        look: CGPoint = .zero,
        mouth: Kit.Mouth = .smile,
        mirrored: Bool = false
    ) {
        Kit.person(&context, folkLook(kind), pose: pose, look: look, mouth: mouth, mirrored: mirrored)
    }
}

// MARK: - Animals

extension OliveArt {
    /// The white horse: sturdy and short-backed like the horses on Greek pots; mane, tail and
    /// hooves in the pale blue-grey of foam in shade. No saddle, no shoes.
    static func horseLook() -> Kit.Beast {
        var look = Kit.horseLook()
        look.body = 0xF7F5EE
        look.belly = 0xFFFFFF
        look.dark = 0xB4C8D6
        look.bodyLength = 1.7
        look.legLength = 1.1
        look.bulk = 1.05
        look.mane = true
        look.showsEyeWhite = false
        return look
    }

    /// A mane like breaking foam, flying back from the head, in head units (the horse faces left).
    static func foamMane(_ g: inout GraphicsContext) {
        let locks: Path = Art.svg("M16,-28 C30,-44 54,-40 60,-22 C52,-29 42,-27 36,-19 C50,-19 64,-9 64,8 C56,-3 44,-5 34,-1 C48,5 58,19 54,36 C48,24 38,17 26,15 C19,5 14,-12 16,-28Z")
        Kit.solid(&g, locks, Art.color(0xFFFFFF), light: 0.1, shade: 0.2)
        let curls: Path = Art.svg("M26,-29 C36,-34 48,-31 54,-24 M38,-11 C48,-11 56,-5 60,3 M34,7 C42,11 48,19 50,28")
        Art.stroke(&g, curls, Art.color(0x9CBAD0), width: 1.6)
        var foam = Path()
        foam.addPath(Art.circle(66, -27, 2.4))
        foam.addPath(Art.circle(71, -3, 2))
        foam.addPath(Art.circle(69, 15, 2.6))
        foam.addPath(Art.circle(61, 34, 2))
        Art.fill(&g, foam, Art.color(0xFFFFFF, 0.95))
    }

    /// The white horse, facing LEFT; origin on the ground under mid-body. Rearing, he is about
    /// 215 units tall at scale 1.
    static func horse(
        _ context: inout GraphicsContext,
        pose: Kit.BeastPose = .stand,
        mood: Kit.BeastMood = .happy,
        look: CGPoint = .zero,
        mirrored: Bool = false
    ) {
        let b = horseLook()
        Kit.beast(&context, b, pose: pose, mood: mood, look: look, mirrored: mirrored)
        let c: CGPoint = Kit.beastHeadCentre(b, pose: pose)
        Art.group(&context, x: c.x, y: c.y) { g in
            foamMane(&g)
        }
    }

    /// A small shaggy goat, dark or brown.
    static func goatLook(dark: Bool) -> Kit.Beast {
        Kit.Beast(
            body: dark ? 0x4A3B30 : 0x8F7458,
            belly: dark ? 0x7A6652 : 0xD6C4A4,
            dark: 0x2A201A,
            ears: .floppy,
            tail: .stub,
            muzzle: .long,
            bodyLength: 1.4,
            legLength: 0.75,
            bulk: 0.85,
            showsEyeWhite: false
        )
    }

    /// A goat with back-curving horns and a little beard, facing LEFT; origin on the ground.
    static func goat(
        _ context: inout GraphicsContext,
        dark: Bool,
        pose: Kit.BeastPose = .stand,
        mood: Kit.BeastMood = .calm,
        mirrored: Bool = false
    ) {
        let b = goatLook(dark: dark)
        let c: CGPoint = Kit.beastHeadCentre(b, pose: pose)
        // The far horn first, behind the head.
        Art.group(&context, x: c.x, y: c.y) { g in
            Art.stroke(&g, Art.svg("M-6,-24 C0,-40 16,-45 25,-37"), Art.color(0x7A6A54), width: 4.2)
        }
        Kit.beast(&context, b, pose: pose, mood: mood, mirrored: mirrored)
        Art.group(&context, x: c.x, y: c.y) { g in
            Art.stroke(&g, Art.svg("M2,-25 C10,-42 28,-42 34,-29"), Art.color(0xA8987C), width: 4.6)
            Art.stroke(&g, Art.svg("M5,-29 C12,-39 24,-39 30,-31"), Art.color(0xE6D9BC, 0.6), width: 1.2)
            let beard: Path = Art.svg("M-34,20 C-36,29 -32,35 -29,38 C-28,31 -27,26 -25,21Z")
            Art.fill(&g, beard, Kit.beastTone(b.belly, 0.9))
        }
        // The shaggy coat hangs under the belly.
        let back: CGPoint = Kit.beastBack(b, pose: pose)
        let fringe: Path = Art.svg("M-22,46 l-3,9 M-12,48 l-2,10 M-2,49 l0,10 M8,48 l2,10 M18,46 l3,9")
        let hang: Path = fringe.applying(CGAffineTransform(translationX: back.x, y: back.y))
        Art.stroke(&context, hang, Kit.beastTone(b.body, 0.8), width: 2.4)
    }

    /// The one small owl the Greeks drew with Athena.
    static func owlLook() -> Kit.Bird {
        Kit.Bird(kind: .owl, body: 0xA89070, belly: 0xE6D6B4, wing: 0x8A7050, beak: 0xD9A441, showsEyeWhite: false)
    }
}

// MARK: - The olive

extension OliveArt {
    /// One olive centred on (x, y), `r` long: green, or ripe purple-black.
    static func olive(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, r: CGFloat, ripe: Bool) {
        let body: Path = Art.ellipse(x, y, r * 0.78, r)
        Kit.solid(&context, body, Art.color(ripe ? 0x3A2A44 : 0x8FA050), light: 0.3, shade: 0.24)
        Art.fill(&context, Art.circle(x - r * 0.26, y - r * 0.36, r * 0.24), Art.color(0xFFFFFF, 0.55))
    }

    /// Adds one spray of olive to three paths: a thin stem from `p` along `angle` (radians),
    /// with narrow leaves in pairs — dark green ones (the upper side) and silver ones (the
    /// underside the wind has turned over).
    static func oliveSpray(
        _ dark: inout Path,
        _ pale: inout Path,
        _ stem: inout Path,
        from p: CGPoint,
        angle a: CGFloat,
        length: CGFloat,
        leaf: CGFloat,
        pairs: Int
    ) {
        let dx: CGFloat = cos(a)
        let dy: CGFloat = sin(a)
        let tip = CGPoint(x: p.x + dx * length, y: p.y + dy * length)
        stem.move(to: p)
        stem.addLine(to: tip)
        let n: Int = max(1, pairs)
        let up: CGFloat = a - 0.75
        let down: CGFloat = a + 0.75
        let wide: CGFloat = leaf * 0.3
        for i in 0..<n {
            let t: CGFloat = (CGFloat(i) + 0.6) / CGFloat(n)
            let base = CGPoint(x: p.x + dx * length * t, y: p.y + dy * length * t)
            if i % 2 == 0 {
                Kit.groundLeaf(&dark, base: base, angle: up, length: leaf, width: wide)
                Kit.groundLeaf(&pale, base: base, angle: down, length: leaf, width: wide)
            } else {
                Kit.groundLeaf(&pale, base: base, angle: up, length: leaf, width: wide)
                Kit.groundLeaf(&dark, base: base, angle: down, length: leaf, width: wide)
            }
        }
        Kit.groundLeaf(&dark, base: tip, angle: a, length: leaf, width: wide)
    }

    /// The crack in the bare rock that the tree grows from, centred on the origin.
    static func rootCrack(_ context: inout GraphicsContext) {
        let gap: Path = Art.svg("M-58,4 L-34,-1 L-16,5 L-4,0 L8,4 L26,-2 L44,4 L62,0")
        Art.stroke(&context, gap, Art.color(0xFFFFFF, 0.35), width: 5)
        Art.stroke(&context, gap, Art.color(0x8A7A5E), width: 2.6)
        Art.stroke(&context, Art.svg("M-16,5 L-24,14 M26,-2 L36,-10 M8,4 L14,13"), Art.color(0x8A7A5E, 0.8), width: 1.6)
    }

    /// Athena's tree: young, no taller than a man (about 180 units), a thin twisting grey trunk
    /// growing straight out of a crack in the rock, narrow leaves dark above and silver
    /// beneath, and — with `fruit` — a scatter of small olives. Origin at the crack.
    static func oliveTree(_ context: inout GraphicsContext, fruit: Bool = true, seed: UInt32 = 5) {
        rootCrack(&context)
        Kit.shadow(&context, 8, 3, width: 120, alpha: 0.2)
        var boughs = Path()
        Kit.treeBough(&boughs, 3, -88, -36, -124, 6, 2.4, bend: -5)
        Kit.treeBough(&boughs, 3, -88, 34, -130, 5.5, 2.2, bend: 5)
        Kit.treeBough(&boughs, 2, -90, 0, -146, 5, 2, bend: 3)
        Kit.treeBough(&boughs, -2, -62, -30, -94, 4, 1.6, bend: -3)
        Art.fill(&context, boughs, Kit.treeTone(barkHex, 0.8))
        let line: [CGPoint] = [
            CGPoint(x: 0, y: 2), CGPoint(x: -5, y: -22), CGPoint(x: 4, y: -46),
            CGPoint(x: -3, y: -70), CGPoint(x: 3, y: -94),
        ]
        let trunk = Kit.treeRibbon(line, 13, 6)
        Kit.treeBark(&context, trunk.shape, trunk.edge, barkHex)
        let groove: Path = Art.svg("M1,-2 C-3,-16 -3,-24 2,-40 C5,-52 -2,-62 -1,-74 C0,-82 2,-88 3,-92")
        Art.stroke(&context, groove, Kit.treeTone(barkHex, 0.6).opacity(0.6), width: 1.3)

        let blobs: [Kit.Blob] = [(-36, -128, 25), (34, -134, 25), (0, -154, 27), (-8, -116, 22), (18, -112, 18), (-32, -98, 14)]
        Kit.canopy(&context, blobs, seed: seed, palette: oliveLeaves(), density: 2.2)

        // The narrow leaves themselves, green above and silver beneath, breaking the edge.
        var dark = Path()
        var pale = Path()
        var stems = Path()
        let sprays: [(CGFloat, CGFloat, CGFloat)] = [
            (-52, -140, 200), (-56, -120, 172), (-20, -172, 250), (10, -176, 285), (44, -156, 322),
            (56, -132, 352), (46, -112, 22), (-44, -98, 152), (0, -142, 240), (20, -130, 300), (-22, -122, 212),
        ]
        for s in sprays {
            oliveSpray(&dark, &pale, &stems, from: CGPoint(x: s.0, y: s.1), angle: Kit.deg(s.2), length: 22, leaf: 11, pairs: 3)
        }
        Art.stroke(&context, stems, Kit.treeTone(barkHex, 0.8), width: 1.2)
        Art.fill(&context, dark, Art.color(0x4E6A48))
        Art.fill(&context, pale, Art.color(0xDCE8D2))
        guard fruit else { return }
        let olives: [(CGFloat, CGFloat)] = [
            (-40, -108), (-24, -103), (-6, -97), (14, -95), (30, -103), (44, -118),
            (-48, -130), (4, -126), (24, -142), (-14, -140), (-30, -152), (40, -140), (6, -164),
        ]
        for i in 0..<olives.count {
            olive(&context, x: olives[i].0, y: olives[i].1, r: 4.4, ripe: i % 3 == 0)
        }
    }
}

// MARK: - The place: the rock, the huts, the spring

extension OliveArt {
    /// The Acropolis as bare nature: a steep-sided, flat-topped outcrop of pale limestone on its
    /// apron of scree. Drawn 400 units wide and about 166 high; origin at the middle of its foot.
    static func acropolis(_ context: inout GraphicsContext) {
        let apron: Path = Art.svg("M-240,2 C-204,-16 -174,-40 -152,-58 L150,-54 C176,-40 208,-16 244,2Z")
        let apronStops: Kit.Stops = [(Art.color(0xD6C6A0), 0), (Art.color(0xC4AE84), 1)]
        Kit.solid(&context, apron, stops: apronStops, light: 0.18, shade: 0.2)
        let cliff: Path = Art.svg("M-178,-40 C-174,-70 -169,-100 -161,-128 C-157,-146 -147,-156 -131,-160 L-60,-166 L20,-163 L96,-166 L138,-158 C152,-154 160,-142 164,-124 C170,-98 177,-68 184,-38 C120,-28 -112,-28 -178,-40Z")
        let cliffStops: Kit.Stops = [(Art.color(0xEFE4C8), 0), (Art.color(stoneHex), 0.45), (Art.color(stoneShadeHex), 1)]
        Kit.solid(&context, cliff, stops: cliffStops, light: 0.3, shade: 0.28, rim: 2.4)
        let face: Path = Art.svg("M84,-170 L190,-170 L190,-26 L104,-26 L92,-90Z")
        let clefts: Path = Art.svg("M-120,-158 L-126,-110 L-118,-60 M-70,-164 L-64,-120 L-72,-84 L-66,-40 M-10,-163 L-16,-126 L-8,-96 M44,-164 L50,-118 L42,-70 L48,-36 M112,-162 L106,-120 L114,-78 M150,-146 L146,-104")
        let ledges: Path = Art.svg("M-164,-112 C-120,-106 -80,-110 -40,-104 M-20,-80 C20,-74 60,-78 110,-72 M-150,-70 C-110,-64 -90,-66 -60,-62 M60,-120 C90,-116 130,-118 160,-112")
        let line: Color = Kit.personTone(stoneShadeHex, 0.78)
        Art.clipped(&context, to: cliff) { g in
            Art.fill(&g, face, ArtStyle.coolShade.opacity(0.12))
            Art.stroke(&g, clefts, line.opacity(0.7), width: ArtStyle.detailLine)
            Art.stroke(&g, ledges, line.opacity(0.45), width: 1.2)
            Art.stroke(&g, ledges.applying(CGAffineTransform(translationX: 0, y: 2)), Art.color(0xFFFFFF, 0.3), width: 1)
        }
        // The flat top catches the light.
        Art.stroke(&context, Art.svg("M-131,-160 L-60,-166 L20,-163 L96,-166 L138,-158"), Art.color(0xFFF6DC, 0.8), width: 2.2)
        // Thorny scrub and fallen stones on the scree.
        var tufts = Path()
        let spots: [(CGFloat, CGFloat, CGFloat)] = [(-196, -6, 9), (-150, -30, 7), (-96, -34, 8), (-30, -30, 6), (40, -32, 8), (120, -30, 7), (176, -18, 9), (210, -4, 7)]
        for spot in spots {
            tufts.addEllipse(in: CGRect(x: spot.0 - spot.2, y: spot.1 - spot.2 * 0.8, width: spot.2 * 2, height: spot.2 * 1.1))
            tufts.addEllipse(in: CGRect(x: spot.0 - spot.2 * 0.2, y: spot.1 - spot.2 * 1.1, width: spot.2 * 1.3, height: spot.2 * 1.1))
        }
        Art.fill(&context, tufts, Art.color(scrubHex, 0.85))
        Kit.pebbles(&context, in: CGRect(x: -200, y: -22, width: 400, height: 20), count: 16, seed: 12, color: 0xCDBE9C)
    }

    /// A one-room hut of sun-dried mud brick on a rough stone footing, thatched. Stands on
    /// baseY, centred on cx; the wall is `width` wide and the whole hut about 0.9 × width tall.
    static func hut(_ context: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, width w: CGFloat) {
        let wallH: CGFloat = w * 0.5
        Kit.house(&context, cx: cx, baseY: baseY, width: w, wallHeight: wallH, roofHeight: w * 0.4, wall: brickHex, roof: thatchHex, style: .thatch, door: 0x6B4A32, windows: 0)
        // Brick courses, faint.
        var courses = Path()
        for row in 1..<5 {
            let y: CGFloat = baseY - wallH * CGFloat(row) / 5
            courses.move(to: CGPoint(x: cx - w * 0.5 + 2, y: y))
            courses.addLine(to: CGPoint(x: cx + w * 0.5 - 2, y: y))
        }
        Art.stroke(&context, courses, Kit.personTone(brickHex, 0.8).opacity(0.4), width: 1)
        // The stone footing on both sides of the door.
        let doorHalf: CGFloat = min(w * 0.2, wallH * 0.42) / 2 + 3
        let foot: CGFloat = max(6, w * 0.09)
        let side: CGFloat = w * 0.5 + 2 - doorHalf
        Kit.builtStoneWall(&context, x0: cx - w * 0.5 - 2, span: side, baseY: baseY, height: foot, color: 0xB5A88E)
        Kit.builtStoneWall(&context, x0: cx + doorHalf, span: side, baseY: baseY, height: foot, color: 0xB5A88E)
    }

    /// A low cushion of thyme or thorny scrub sitting on baseY at x, `width` wide.
    static func scrub(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, width: CGFloat, seed: UInt32) {
        let w: CGFloat = max(8, width)
        var random = ArtRandom(seed)
        var mass = Path()
        for i in 0..<4 {
            let t: CGFloat = CGFloat(i) / 3 - 0.5
            let r: CGFloat = w * (0.2 + Kit.rnd(&random) * 0.08)
            let bx: CGFloat = x + t * w * 0.7
            mass.addEllipse(in: CGRect(x: bx - r, y: baseY - r * 1.5, width: r * 2, height: r * 1.6))
        }
        Kit.shadow(&context, x, baseY, width: w, alpha: 0.18)
        Kit.solid(&context, mass, Art.color(scrubHex), light: 0.26, shade: 0.26)
        let bloom = CGRect(x: x - w * 0.42, y: baseY - w * 0.44, width: w * 0.84, height: w * 0.3)
        Kit.flecks(&context, in: bloom, count: 8, seed: seed &+ 3, color: Art.color(0xB9A0D2, 0.9), radius: 0.8...1.7)
        Kit.flecks(&context, in: bloom, count: 8, seed: seed &+ 8, color: Art.color(0xC9CF9A, 0.9), radius: 0.7...1.4)
    }

    /// A loose block of limestone standing on baseY.
    static func stone(_ context: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, width: CGFloat, seed: UInt32) {
        var random = ArtRandom(seed)
        let lump: Path = Kit.groundLump(cx: cx, baseY: baseY, width: width, height: width * 0.6, random: &random)
        Kit.solid(&context, lump, Art.color(0xD2C4A4), light: 0.3, shade: 0.28, rim: 1.4)
    }

    /// The spring: cold water trickling from a rock into a hollow, centred on (cx, cy).
    static func springPool(_ context: inout GraphicsContext, cx: CGFloat, cy: CGFloat, width w: CGFloat) {
        Kit.rock(&context, cx: cx - w * 0.42, baseY: cy - w * 0.02, width: w * 0.52, height: w * 0.36, color: 0xC4B592, seed: 4)
        let rim: Path = Art.ellipse(cx, cy, w * 0.5, w * 0.16)
        Kit.solid(&context, rim, Art.color(0xA89674), light: 0.2, shade: 0.2)
        let water: Path = Art.ellipse(cx + w * 0.01, cy + w * 0.012, w * 0.43, w * 0.12)
        let blue: Kit.Stops = [(Art.color(0xC6E6F2), 0), (Art.color(0x4E9CC2), 1)]
        Art.fillLinear(&context, water, blue, from: CGPoint(x: cx, y: cy - w * 0.12), to: CGPoint(x: cx, y: cy + w * 0.13))
        var trickle = Path()
        trickle.move(to: CGPoint(x: cx - w * 0.36, y: cy - w * 0.2))
        trickle.addQuadCurve(to: CGPoint(x: cx - w * 0.22, y: cy), control: CGPoint(x: cx - w * 0.25, y: cy - w * 0.2))
        Art.stroke(&context, trickle, Art.color(0xFFFFFF, 0.9), width: max(1.6, w * 0.03))
        Kit.ripples(&context, cx - w * 0.2, cy + w * 0.02, w * 0.3, count: 2, color: Color.white, opacity: 0.6)
    }

    /// A small wooden bucket standing on (x, baseY).
    static func bucket(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, scale: CGFloat) {
        Art.group(&context, x: x, y: baseY, scale: scale) { g in
            Kit.shadow(&g, 0, 0, width: 26, alpha: 0.2)
            let body: Path = Art.svg("M-11,-22 L11,-22 L8.5,0 L-8.5,0Z")
            Kit.solid(&g, body, Art.color(0x9A6E44), light: 0.28, shade: 0.26)
            Art.stroke(&g, Art.svg("M-5,-22 L-4,0 M0,-22 L0,0 M5,-22 L4,0"), Art.color(0x6E4A2E, 0.6), width: 1)
            Art.stroke(&g, Art.svg("M-10.6,-17 L10.6,-17 M-9.2,-5 L9.2,-5"), Art.color(0x5A4030), width: 1.8, cap: .butt)
            Art.stroke(&g, Art.svg("M-10,-22 C-8,-37 8,-37 10,-22"), Art.color(0x7A6A50), width: 1.6)
        }
    }

    /// Cracks in the bare limestone of the hilltop, between `top` and `bottom`: short jagged
    /// lines, longer toward the reader.
    static func rockCracks(_ context: inout GraphicsContext, x0: CGFloat, x1: CGFloat, top: CGFloat, bottom: CGFloat, count: Int, seed: UInt32, scale k: CGFloat) {
        guard x1 > x0, bottom > top else { return }
        var random = ArtRandom(seed)
        var lines = Path()
        for _ in 0..<max(0, count) {
            let t: CGFloat = Kit.rnd(&random)
            let x: CGFloat = x0 + (x1 - x0) * Kit.rnd(&random)
            let y: CGFloat = top + (bottom - top) * (0.1 + 0.85 * t * t)
            let length: CGFloat = (18 + 56 * t) * k
            let jag: CGFloat = (2 + 4 * t) * k
            lines.move(to: CGPoint(x: x, y: y))
            lines.addLine(to: CGPoint(x: x + length * 0.35, y: y + jag))
            lines.addLine(to: CGPoint(x: x + length * 0.62, y: y - jag * 0.6))
            lines.addLine(to: CGPoint(x: x + length, y: y + jag * 0.5))
        }
        let under: Path = lines.applying(CGAffineTransform(translationX: 0, y: 1.6))
        Art.stroke(&context, under, Art.color(0xFFFFFF, 0.3), width: 1.2)
        Art.stroke(&context, lines, Art.color(0x9A8866, 0.6), width: 1.4)
    }
}

// MARK: - The marvels: the cloud throne, the split rock, the burst of spray

extension OliveArt {
    /// Zeus is never drawn: only a pile of white cloud shaped a little like a throne, with
    /// light behind it. (cx, baseY) is the middle of the seat's base; about 300 × 260 at s = 1.
    static func cloudThrone(_ context: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, scale s: CGFloat, light: Kit.Light) {
        Art.glow(&context, cx + 6 * s, baseY - 96 * s, 230 * s, light.glow, alpha: 0.85)
        let white: Color = Art.color(0xFFFFFF, 0.92)
        // The tall back, then the two arms, then the wide seat in front.
        Kit.cloud(&context, cx + 8 * s, baseY - 150 * s, scale: 0.85 * s, color: white)
        Kit.cloud(&context, cx + 6 * s, baseY - 84 * s, scale: 1.25 * s, color: white)
        Kit.cloud(&context, cx - 104 * s, baseY - 34 * s, scale: 0.8 * s, color: white)
        Kit.cloud(&context, cx + 112 * s, baseY - 38 * s, scale: 0.8 * s, color: white)
        Kit.cloud(&context, cx, baseY, scale: 2.1 * s, color: white)
    }

    /// The rock split open: a jagged gap running across, and two slabs heaved up either side
    /// of it. Origin at the middle of the gap, on the ground.
    static func splitRock(_ context: inout GraphicsContext) {
        let left: Path = Art.svg("M-98,8 L-72,-30 L-36,-46 L-14,-8 L-22,10Z")
        let right: Path = Art.svg("M18,10 L12,-14 L40,-54 L80,-34 L102,8Z")
        Kit.solid(&context, left, Art.color(stoneHex), light: 0.32, shade: 0.26, rim: 2)
        Kit.solid(&context, right, Art.color(stoneHex), light: 0.3, shade: 0.3, rim: 2)
        let strata: Path = Art.svg("M-72,-30 L-40,-10 M-58,-16 L-30,-2 M40,-54 L46,-16 M60,-42 L64,-8")
        Art.stroke(&context, strata, Kit.personTone(stoneShadeHex, 0.8).opacity(0.7), width: ArtStyle.detailLine)
        let gap: Path = Art.svg("M-156,10 L-112,4 L-82,13 L-42,3 L-16,11 L0,-2 L16,11 L46,4 L86,13 L122,4 L160,10")
        Art.stroke(&context, gap, Art.color(0x6E5E48), width: 5.5)
        Art.stroke(&context, gap.applying(CGAffineTransform(translationX: 0, y: 3.4)), Art.color(0xFFFFFF, 0.35), width: 1.4)
        Art.stroke(&context, Art.svg("M-82,13 L-94,27 M46,4 L62,23 M122,4 L142,-6 M-112,4 L-128,-6"), Art.color(0x6E5E48, 0.85), width: 2.4)
        Kit.pebbles(&context, in: CGRect(x: -116, y: 12, width: 232, height: 20), count: 12, seed: 6, color: 0xCDBE9C)
    }

    /// A burst of salt spray standing up out of (cx, baseY), about `r` high and 2 × r wide:
    /// white against the pale sky, with a breath of sea blue behind it so that it reads.
    static func sprayBurst(_ context: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, r: CGFloat) {
        Art.glow(&context, cx, baseY - r * 0.45, r * 1.3, Art.color(0x8FBBDD), alpha: 0.42)
        var plumes = Path()
        let angles: [CGFloat] = [-170, -152, -130, -110, -90, -70, -50, -28, -10]
        for i in 0..<angles.count {
            let a: CGFloat = Kit.deg(angles[i])
            let step: CGFloat = CGFloat((i * 7) % 5) / 4
            let reach: CGFloat = r * (0.68 + 0.32 * step)
            let base = CGPoint(x: cx + cos(a) * r * 0.1, y: baseY + sin(a) * r * 0.1)
            Kit.groundLeaf(&plumes, base: base, angle: a, length: reach, width: reach * 0.24)
        }
        Art.fill(&context, plumes, Art.color(0xFFFFFF, 0.9))
        ArtStyle.form(&context, plumes, bounds: plumes.boundingRect, light: 0, shade: 0.14)
        let cloud = CGRect(x: cx - r * 1.15, y: baseY - r * 1.2, width: r * 2.3, height: r * 1.15)
        Kit.flecks(&context, in: cloud, count: 44, seed: 9, color: Art.color(0xFFFFFF, 0.95), radius: 1.2...3.4)
        Kit.flecks(&context, in: cloud, count: 20, seed: 15, color: Art.color(0x9CC4E0, 0.85), radius: 1.0...2.4)
        var arcs = Path()
        arcs.move(to: CGPoint(x: cx - r * 0.5, y: baseY - r * 0.2))
        arcs.addQuadCurve(to: CGPoint(x: cx - r * 0.95, y: baseY - r * 0.75), control: CGPoint(x: cx - r * 0.9, y: baseY - r * 0.3))
        arcs.move(to: CGPoint(x: cx + r * 0.5, y: baseY - r * 0.22))
        arcs.addQuadCurve(to: CGPoint(x: cx + r * 0.98, y: baseY - r * 0.8), control: CGPoint(x: cx + r * 0.92, y: baseY - r * 0.32))
        Art.stroke(&context, arcs, Art.color(0xFFFFFF, 0.85), width: max(1.6, r * 0.02))
    }
}
