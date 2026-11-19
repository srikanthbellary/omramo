import SwiftUI
import OmramoCore

// The Griot's Apprentice: palette, lights, the people and the story's own parts (banco walls
// and houses, the baobab, the balafon, the salt boat), shared by every picture.

extension GriotArt {
    // MARK: Palette and light

    /// Mud-brick ochre, warm earth, white cotton and indigo, a little gold.
    static let ramp = ArtStyle.Ramp(deep: 0x2A1A10, shade: 0x5A3218, mid: 0xA8683A, light: 0xF4E8D2, glow: 0xE8B04A, accent: 0x2F3F86)

    static let banco: UInt32 = 0xC48E5A
    static let bancoLit: UInt32 = 0xD8A570
    static let bancoDeep: UInt32 = 0x9A6638
    static let cotton: UInt32 = 0xF3EEE4
    static let indigo: UInt32 = 0x2F3F86
    static let indigoDeep: UInt32 = 0x1F2A5E
    static let honey: UInt32 = 0xD9A94E
    static let gold: UInt32 = 0xE8B04A
    static let saltGrey: UInt32 = 0xD9D5CC
    static let boatWood: UInt32 = 0x6A4428
    static let skinSira: UInt32 = 0x5A3420
    static let skinOld: UInt32 = 0x4A2C1C
    static let skinWarm: UInt32 = 0x603A24
    static let riverPale: UInt32 = 0xB9A98C

    /// Early morning in the compound: a milky pale sky.
    static func morning() -> Kit.Light {
        let sky: Kit.Stops = [(Art.color(0xE8E7E1), 0), (Art.color(0xF2EEE3), 0.55), (Art.color(0xF5E3C2), 1)]
        return Kit.Light(sky: sky, sun: 0xFFF6E2, glow: 0xF0C878, haze: 0xF2EADB, far: 0xD9CFC0, mid: 0xC9B394, near: 0xB08A62)
    }

    /// Late afternoon on the flood: hazy gold-white.
    static func afternoon() -> Kit.Light {
        let sky: Kit.Stops = [(Art.color(0xEEE9DA), 0), (Art.color(0xF5EBD3), 0.5), (Art.color(0xF4DDB0), 1)]
        return Kit.Light(sky: sky, sun: 0xFFF3D2, glow: 0xEBC070, haze: 0xF0E4CA, far: 0xCFC8B4, mid: 0xB7B29A, near: 0x8E9A7E)
    }

    /// Evening in the merchant's courtyard: pale gold, never night.
    static func evening() -> Kit.Light {
        let sky: Kit.Stops = [(Art.color(0xF4E8CC), 0), (Art.color(0xF6DFB0), 0.6), (Art.color(0xF1CC8E), 1)]
        return Kit.Light(sky: sky, sun: 0xFFE8B6, glow: 0xE8B04A, haze: 0xF3DDB4, far: 0xD8B98E, mid: 0xC49A6A, near: 0xA8683A)
    }

    /// Dawn on the riverbank: pale rose.
    static func dawn() -> Kit.Light {
        let sky: Kit.Stops = [(Art.color(0xEFE3E2), 0), (Art.color(0xF7DDD4), 0.55), (Art.color(0xF6CFB6), 1)]
        return Kit.Light(sky: sky, sun: 0xFFEEDC, glow: 0xF0B890, haze: 0xF4DCD2, far: 0xD6C0BC, mid: 0xBBA49C, near: 0x8A7A70)
    }

    /// The muted dry-season greens of the delta (baobab, palms, rice).
    static func deltaGreens() -> Kit.Greens {
        Kit.greens(0x34421E, 0x526430, 0x7A8A3E, 0xA7AE5E, 0xD8CE8A)
    }

    // MARK: The people

    /// Sira, about twelve: braids under an indigo head-wrap, a white cotton wrap.
    static func siraLook() -> Kit.Person {
        Kit.Person(
            age: .child, skin: skinSira, hair: 0x1E120C, hairStyle: .braids, beard: .none,
            headwear: .headwrap, headwearColor: indigo, garment: .wrapper,
            cloth: cotton, trim: indigo, legs: skinSira, showsEyeWhite: false
        )
    }

    /// Jeli Madi: an old man, short white beard, white robe and cap.
    static func madiLook() -> Kit.Person {
        Kit.Person(
            age: .elder, skin: skinOld, hair: 0xEDE8E0, hairStyle: .short, beard: .short,
            headwear: .cap, headwearColor: 0xF6F2EA, garment: .robe,
            cloth: 0xF2EEE4, trim: 0xD8CFC0, legs: 0xE6DED0, showsEyeWhite: false
        )
    }

    /// Bakary the merchant: broad, close grey beard, the honey-gold robe (the tall cap is drawn
    /// by `bakary`).
    static func bakaryLook() -> Kit.Person {
        Kit.Person(
            age: .adult, skin: skinWarm, hair: 0x8E8A84, hairStyle: .short, beard: .short,
            headwear: .none, headwearColor: 0x5A2A6E, garment: .robe,
            cloth: honey, trim: 0xA8742A, legs: 0xE8DCC0, showsEyeWhite: false
        )
    }

    /// Lamine, fourteen, the balafon player: a cotton tunic and an indigo cap.
    static func lamineLook() -> Kit.Person {
        Kit.Person(
            age: .child, skin: 0x4E2E1C, hair: 0x1A100A, hairStyle: .short, beard: .none,
            headwear: .cap, headwearColor: indigo, garment: .tunic,
            cloth: 0xE9E2D2, trim: indigo, legs: 0xD8CEBC, showsEyeWhite: false
        )
    }

    /// A guest or a townsman: white or indigo robe and cap.
    static func manLook(_ cloth: UInt32, cap: UInt32, beard: Kit.Person.Beard) -> Kit.Person {
        Kit.Person(
            age: .adult, skin: skinWarm, hair: 0x1E140E, hairStyle: .short, beard: beard,
            headwear: .cap, headwearColor: cap, garment: .robe,
            cloth: cloth, trim: Kit.builtHex(cloth, 0.8), legs: 0xE0D6C4, showsEyeWhite: false
        )
    }

    /// A guest woman: a wrap and a head-wrap.
    static func womanLook(_ cloth: UInt32, wrap: UInt32) -> Kit.Person {
        Kit.Person(
            age: .adult, skin: skinSira, hair: 0x1E120C, hairStyle: .braids, beard: .none,
            headwear: .headwrap, headwearColor: wrap, garment: .dress,
            cloth: cloth, trim: wrap, legs: skinSira, showsEyeWhite: false
        )
    }

    /// Fodé, Yaya's grandson: an old porter, thin, in a worn robe.
    static func fodeLook() -> Kit.Person {
        Kit.Person(
            age: .elder, skin: skinOld, hair: 0xBDB6AC, hairStyle: .short, beard: .short,
            headwear: .none, headwearColor: 0xFFFFFF, garment: .tunic,
            cloth: 0xC9BBA2, trim: 0xA89878, legs: 0xB8AA92, showsEyeWhite: false
        )
    }

    /// Fodé's granddaughter, with her water gourd.
    static func gourdGirlLook() -> Kit.Person {
        Kit.Person(
            age: .child, skin: skinSira, hair: 0x1E120C, hairStyle: .braids, beard: .none,
            headwear: .kerchief, headwearColor: 0xB88A5A, garment: .wrapper,
            cloth: 0xDCCDB2, trim: 0x8A6A44, legs: skinSira, showsEyeWhite: false
        )
    }

    /// A boatman: bare-headed, a short tunic.
    static func boatmanLook(_ shade: UInt32) -> Kit.Person {
        Kit.Person(
            age: .adult, skin: 0x4A2A18, hair: 0x1A100A, hairStyle: .short, beard: .none,
            headwear: .cap, headwearColor: 0xE6DCC8, garment: .tunic,
            cloth: shade, trim: Kit.builtHex(shade, 0.8), legs: 0x4A2A18, showsEyeWhite: false
        )
    }

    /// Sira standing, origin at her feet, facing left; her indigo upper cloth over the wrap.
    /// Hands flat at her sides in `.stand` (her signature); `.wave` lifts one hand to sing.
    static func sira(
        _ context: inout GraphicsContext,
        pose: Kit.Pose = .stand,
        mouth: Kit.Mouth = .open,
        look: CGPoint = CGPoint(x: -0.2, y: -0.3),
        mirrored: Bool = false
    ) {
        let p = siraLook()
        Kit.shadow(&context, 0, 0, width: 46)
        Kit.person(&context, p, pose: pose, look: look, mouth: mouth, mirrored: mirrored)
        let top: Path = Art.svg("M-13,-74 C-6,-78.5 6,-78.5 12.5,-73.5 L11.5,-55 C4,-52 -5,-52 -12.5,-55Z")
        Kit.solid(&context, top, Art.color(indigo), light: 0.2, shade: 0.2)
        let folds: Path = Art.svg("M-9,-70 C-3,-64 3,-60 9,-58 M-11,-62 C-5,-58 2,-56 8,-55")
        Art.stroke(&context, folds, Art.color(indigoDeep), width: 1.1)
        let hem: Path = Art.svg("M-15,-14 C-5,-12 5,-12 15,-14")
        Art.stroke(&context, hem, Art.color(indigo, 0.8), width: 2.2)
    }

    /// Anyone sitting cross-legged on the ground or a mat, origin on the ground under the seat:
    /// the kit's sitting figure lowered to the ground, its shins hidden under a lap of cloth.
    static func crossLegged(
        _ context: inout GraphicsContext,
        _ p: Kit.Person,
        look: CGPoint = .zero,
        mouth: Kit.Mouth = .smile,
        mirrored: Bool = false
    ) {
        let drop: CGFloat = Kit.seatHeight(p)
        let k: CGFloat = p.age == .child ? 0.72 : 1
        Kit.shadow(&context, 0, 0, width: 62 * k)
        Art.clipped(&context, to: Art.rect(-120, -300, 240, 298)) { g in
            Art.group(&g, x: 0, y: drop) { s in
                Kit.person(&s, p, pose: .sit, look: look, mouth: mouth, mirrored: mirrored)
            }
        }
        let lap: Path = Art.svg("M-38,-2 C-40,-12 -26,-20 -6,-20 C14,-21 30,-16 32,-6 C30,-1 -30,1 -38,-2Z")
        Art.group(&context, scale: k) { g in
            Kit.solid(&g, lap, Art.color(p.cloth), light: 0.22, shade: 0.24)
            Art.stroke(&g, Art.svg("M-30,-6 C-18,-12 -2,-13 14,-10"), Kit.personTone(p.cloth, 0.8), width: 1.2)
        }
    }

    /// Jeli Madi sitting cross-legged on the ground, origin under the seat, facing left.
    static func madi(_ context: inout GraphicsContext, mouth: Kit.Mouth = .flat, look: CGPoint = .zero, mirrored: Bool = false) {
        crossLegged(&context, madiLook(), look: look, mouth: mouth, mirrored: mirrored)
    }

    /// The small bundle of white cotton tied with string, centred on (x, y).
    static func cottonBundle(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, scale: CGFloat = 1) {
        Art.group(&context, x: x, y: y, scale: scale) { g in
            let body: Path = Art.svg("M-9,4 C-11,-2 -7,-7 -2,-6 L-3,-9 C-1,-11 2,-11 3,-9 L2,-6 C7,-7 11,-2 9,4 C4,7 -4,7 -9,4Z")
            Kit.solid(&g, body, Art.color(0xF8F4EC), light: 0.3, shade: 0.28)
            Art.stroke(&g, Art.svg("M-2,-6 C0,-5 1,-5 2,-6 M-8,0 C-3,2 3,2 8,0"), Art.color(0xA8742A), width: 1)
        }
    }
}

// MARK: - Bakary, Lamine and the gate

extension GriotArt {
    /// Bakary on his raised seat of mud brick (spread with a rug and cushions), origin on the
    /// ground under the seat, facing left: the huge honey-gold robe, the tall cap, the thumb
    /// ring on the hand that grips his knee.
    static func bakary(_ context: inout GraphicsContext, mouth: Kit.Mouth = .smile, look: CGPoint = .zero) {
        let p = bakaryLook()
        let seat: Path = Art.svg("M-20,0 L-18,-34 C-10,-37 34,-37 42,-34 L44,0Z")
        Kit.shadow(&context, 10, 0, width: 90)
        Kit.solid(&context, seat, Art.color(banco), light: 0.22, shade: 0.26)
        let rug: Path = Art.svg("M-22,-33 C-8,-38 34,-38 46,-33 L44,-18 C30,-15 -6,-15 -20,-18Z")
        Kit.solid(&context, rug, Art.color(0x8A2E22), light: 0.18, shade: 0.2)
        Art.stroke(&context, Art.svg("M-20,-22 C-6,-19 30,-19 44,-22 M-21,-27 C-6,-24 30,-24 45,-27"), Art.color(0xE8B04A, 0.7), width: 1.4)
        Kit.solid(&context, Art.ellipse(36, -42, 13, 9), Art.color(0x6A2E5A), light: 0.24, shade: 0.24)
        // The robe "that moves like a sail": wide drapery behind the body.
        let sail: Path = Art.svg("M-14,-100 C-50,-84 -64,-40 -60,-30 C-40,-24 30,-24 44,-32 C48,-60 38,-88 24,-100Z")
        Kit.solid(&context, sail, Art.color(honey), light: 0.26, shade: 0.26)
        Kit.person(&context, p, pose: .sit, look: look, mouth: mouth)
        // The embroidered chest panel and the scrolls of honey thread.
        let panel: Path = Art.svg("M-5,-99 L17,-99 L21,-80 C15,-66 -3,-66 -9,-80Z")
        Art.fill(&context, panel, Art.color(0xF0CC7A, 0.9))
        let scrolls: Path = Art.svg("M-2,-94 C2,-90 10,-90 14,-94 M0,-86 C4,-80 8,-80 12,-86 M6,-78 L6,-70 M-40,-60 C-34,-56 -28,-58 -26,-64 M-48,-44 C-42,-40 -36,-42 -34,-48 M28,-58 C32,-54 36,-56 36,-62")
        Art.stroke(&context, scrolls, Art.color(0xA8742A), width: 1.2)
        // The tall cloth cap.
        let cap: Path = Art.svg("M-16,-150 C-18,-168 -12,-180 6,-182 C24,-180 30,-168 28,-150 C18,-155 -6,-155 -16,-150Z")
        Kit.solid(&context, cap, Art.color(0x5A2A6E), light: 0.26, shade: 0.24)
        Art.stroke(&context, Art.svg("M-15,-153 C-5,-157 18,-157 27,-153"), Art.color(0xE8B04A, 0.8), width: 1.6)
        let hand: CGPoint = Kit.hand(p, pose: .sit)
        Art.stroke(&context, Art.circle(hand.x + 1, hand.y - 1, 2.6), Art.color(gold), width: 1.8)
        Art.fill(&context, Art.circle(hand.x, hand.y - 2.4, 0.8), Color.white.opacity(0.8))
    }

    /// Lamine kneeling at the balafon, origin on the ground under his knees, facing left; the
    /// instrument stands in front of him and the two padded beaters are in his hands.
    static func lamine(_ context: inout GraphicsContext, lifted: Bool = false, mirrored: Bool = false) {
        let p = lamineLook()
        Kit.shadow(&context, 0, 0, width: 52)
        Kit.person(&context, p, pose: .kneel, look: CGPoint(x: -0.4, y: 0.4), mouth: .flat, mirrored: mirrored)
        let h: CGPoint = Kit.hand(p, pose: .kneel)
        let keysY: CGFloat = lifted ? -54 : -30
        balafon(&context, x: h.x - 34, baseY: 4, scale: 0.72)
        let beater: Path = Art.line(h.x, h.y, h.x - 16, keysY)
        Art.stroke(&context, beater, Art.color(0x6A4428), width: 2)
        Art.fill(&context, Art.circle(h.x - 16, keysY, 3), Art.color(0x3A2A1E))
        let second: Path = Art.line(h.x + 4, h.y + 2, h.x - 6, keysY + 3)
        Art.stroke(&context, second, Art.color(0x6A4428), width: 2)
        Art.fill(&context, Art.circle(h.x - 6, keysY + 3, 3), Art.color(0x3A2A1E))
    }

    /// A guest sitting on a mat, facing left (or right when mirrored).
    static func guest(_ context: inout GraphicsContext, _ p: Kit.Person, mirrored: Bool = false, bowl: Bool = false) {
        if bowl {
            Kit.bowl(&context, cx: mirrored ? 34 : -34, baseY: 0, width: 16, color: 0x7A4A2A, filling: 0xF2E8D2)
        }
        if mirrored {
            Art.group(&context, scaleX: -1) { g in
                crossLegged(&g, p, look: CGPoint(x: -0.3, y: -0.2), mouth: .smile, mirrored: true)
            }
        } else {
            crossLegged(&context, p, look: CGPoint(x: -0.3, y: -0.2), mouth: .smile)
        }
    }

    /// Fodé standing bent at the gate and his granddaughter with the water gourd beside him,
    /// origin on the ground between them, both facing left (toward the courtyard).
    static func gateWatchers(_ context: inout GraphicsContext) {
        Art.group(&context, x: 16, y: 0) { g in
            Kit.shadow(&g, 0, 0, width: 44)
            Kit.person(&g, fodeLook(), pose: .bow, look: CGPoint(x: -0.6, y: -0.6), mouth: .flat)
        }
        Art.group(&context, x: -22, y: 0) { g in
            Kit.shadow(&g, 0, 0, width: 36)
            let girl = gourdGirlLook()
            Kit.person(&g, girl, pose: .carry, look: CGPoint(x: -0.6, y: -0.2), mouth: .flat)
            let h: CGPoint = Kit.hand(girl, pose: .carry)
            gourd(&g, x: h.x + 2, y: h.y + 2, scale: 0.9)
        }
    }

    /// A round water gourd (calabash), centred on (x, y).
    static func gourd(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, scale: CGFloat = 1) {
        Art.group(&context, x: x, y: y, scale: scale) { g in
            let body: Path = Art.svg("M-2,-9 C-2,-12 2,-12 2,-9 C7,-8 10,-3 10,2 C10,8 5,11 0,11 C-5,11 -10,8 -10,2 C-10,-3 -7,-8 -2,-9Z")
            Kit.solid(&g, body, Art.color(0xC89A54), light: 0.3, shade: 0.28)
            Art.stroke(&g, Art.svg("M-8,1 C-3,3 3,3 8,1"), Art.color(0x8A5A2A), width: 1)
        }
    }

    /// A boatman standing with his long pole (feet at the origin, facing left); the pole runs
    /// back and down to `poleDown` below his feet, into the water.
    static func boatman(_ context: inout GraphicsContext, _ p: Kit.Person, poleDown: CGFloat = 60) {
        Kit.person(&context, p, pose: .reach, look: CGPoint(x: -0.5, y: 0.3), mouth: .flat)
        let h: CGPoint = Kit.hand(p, pose: .reach)
        Kit.propShaft(&context, h.x - 8, h.y - 40, h.x + 30, poleDown, wood: 0x8A6A44, width: 2.6)
    }
}

// MARK: - The balafon and the baobab

extension GriotArt {
    /// The balafon seen from the front and a little above, origin on the ground under its
    /// middle, about 112 wide and 36 tall at scale 1: seventeen pale keys on a bowed frame of
    /// sticks, a gourd of graded size under each key. `wrapped` draws it bundled in cloth.
    static func balafon(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, scale: CGFloat, wrapped: Bool = false) {
        Art.group(&context, x: x, y: baseY, scale: scale) { g in
            Kit.shadow(&g, 0, 0, width: 118)
            if wrapped {
                let bundle: Path = Art.svg("M-56,0 C-60,-16 -50,-30 -30,-32 C-10,-36 20,-36 42,-32 C58,-28 62,-12 56,0Z")
                Kit.solid(&g, bundle, Art.color(indigo), light: 0.22, shade: 0.26)
                Art.stroke(&g, Art.svg("M-40,-28 C-30,-14 -30,-6 -34,0 M20,-34 C26,-20 26,-8 22,0"), Art.color(indigoDeep), width: 1.4)
                Art.stroke(&g, Art.svg("M-52,-18 C-20,-12 20,-12 56,-18"), Art.color(0xE6DCC8), width: 1.8)
                return
            }
            let wood: Color = Art.color(0x7A5230)
            let legs: Path = Art.svg("M-52,-26 L-57,0 M52,-24 L57,0 M-30,-22 L-32,-2 M30,-22 L32,-2")
            Art.stroke(&g, legs, wood, width: 2.6)
            for i in 0..<17 {
                let t: CGFloat = CGFloat(i) / 16
                let gx: CGFloat = -50 + 100 * t
                let r: CGFloat = 6.4 - 3.4 * t
                let bow: CGFloat = 1 - 4 * (t - 0.5) * (t - 0.5)
                let gy: CGFloat = -21 + 3 * bow + r
                Kit.solid(&g, Art.circle(gx, gy, r), Art.color(0xC8984E), light: 0.34, shade: 0.3)
                Art.fill(&g, Art.circle(gx + r * 0.2, gy + r * 0.2, max(0.8, r * 0.22)), Art.color(0x5A3218, 0.7))
            }
            let rail: Path = Art.svg("M-58,-27 C-20,-19 20,-19 58,-25")
            Art.stroke(&g, rail, wood, width: 3.4)
            Art.stroke(&g, Art.svg("M-58,-28 C-20,-20 20,-20 58,-26"), ArtStyle.warmLight.opacity(0.4), width: 1)
            for i in 0..<17 {
                let t: CGFloat = CGFloat(i) / 16
                let kx: CGFloat = -52 + 104 * t
                let length: CGFloat = 13 - 5 * t
                let bow: CGFloat = 1 - 4 * (t - 0.5) * (t - 0.5)
                let bottom: CGFloat = -23 + 3 * bow
                let tone: UInt32 = i % 2 == 0 ? 0xE6CA94 : 0xDCBC84
                let key: Path = Art.rect(kx - 2.6, bottom - length, 5.2, length, radius: 1.4)
                Kit.solid(&g, key, Art.color(tone), light: 0.3, shade: 0.2)
                Art.fill(&g, Art.circle(kx, bottom - length + 2, 0.7), Art.color(0x5A3218, 0.6))
            }
        }
    }

    /// The great baobab, origin at the foot of its trunk, about 300 tall and 210 wide at scale
    /// 1: a swollen grey trunk, stubby crooked boughs, small clumps of late-rains leaves.
    static func baobab(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, scale: CGFloat) {
        Art.group(&context, x: x, y: baseY, scale: scale) { g in
            Kit.shadow(&g, 6, 0, width: 150, alpha: 0.22)
            let bark: Color = Art.color(0x8E7E6C)
            let boughs: Path = Art.svg("M-30,-184 C-46,-206 -70,-216 -96,-214 M-24,-186 C-30,-214 -28,-236 -36,-258 M0,-168 C2,-196 8,-222 4,-252 M28,-190 C40,-210 64,-218 92,-212 M32,-188 C36,-212 50,-236 46,-262")
            Art.stroke(&g, boughs, bark, width: 11)
            let twigs: Path = Art.svg("M-70,-214 C-78,-228 -76,-238 -82,-246 M-36,-258 C-46,-266 -50,-274 -58,-276 M4,-252 C14,-262 18,-270 26,-272 M70,-216 C78,-232 80,-240 86,-248")
            Art.stroke(&g, twigs, bark, width: 5)
            let trunk: Path = Art.svg("M-46,0 C-44,-44 -38,-96 -32,-150 C-31,-166 -34,-178 -38,-190 L-20,-188 C-16,-178 -10,-170 0,-168 C10,-172 16,-182 22,-194 L38,-190 C33,-178 31,-162 31,-148 C34,-92 40,-42 48,0 C20,6 -20,6 -46,0Z")
            let tone: Kit.Stops = [(Art.color(0xA89684), 0), (Art.color(0x8E7E6C), 0.6), (Art.color(0x7A6A5A), 1)]
            Kit.solid(&g, trunk, stops: tone, light: 0.3, shade: 0.3, rim: 2.4)
            let lines: Path = Art.svg("M-30,-20 C-28,-70 -24,-110 -20,-150 M-8,-10 C-8,-60 -6,-110 -6,-160 M14,-14 C14,-60 16,-110 18,-160 M32,-12 C28,-50 24,-90 22,-140")
            Art.stroke(&g, lines, Art.color(0x6A5A4A, 0.5), width: 1.4)
            let blobs: [Kit.Blob] = [
                (-96, -222, 26), (-62, -240, 30), (-34, -268, 28), (4, -262, 32), (44, -272, 28),
                (86, -226, 28), (20, -234, 24), (-20, -232, 24), (62, -248, 24),
            ]
            Kit.canopy(&g, blobs, seed: 41, palette: deltaGreens(), density: 2)
        }
    }
}

// MARK: - Banco: walls, houses, granaries

extension GriotArt {
    /// A compound wall of smooth mud brick from x0 to x1 standing on baseY, `height` tall:
    /// a soft rounded crest, rounded buttresses every 70 units, a darker splash band.
    static func mudWall(_ context: inout GraphicsContext, x0: CGFloat, x1: CGFloat, baseY: CGFloat, height: CGFloat, color: UInt32 = GriotArt.banco) {
        guard x1 > x0, height > 0 else { return }
        let top: CGFloat = baseY - height
        var shape = Path()
        shape.move(to: CGPoint(x: x0, y: baseY))
        shape.addLine(to: CGPoint(x: x0, y: top + 4))
        var x: CGFloat = x0
        var up: Bool = true
        while x < x1 {
            let next: CGFloat = min(x1, x + 34)
            let dip: CGFloat = up ? -3 : 2
            shape.addQuadCurve(to: CGPoint(x: next, y: top + 3), control: CGPoint(x: (x + next) / 2, y: top + dip))
            x = next
            up.toggle()
        }
        shape.addLine(to: CGPoint(x: x1, y: baseY))
        shape.closeSubpath()
        Kit.solid(&context, shape, Art.color(color), light: 0.2, shade: 0.18)
        var buttresses = Path()
        let pier: Path = Art.svg("M-7,0 C-8,-20 -6,-40 -3,-52 C-1,-54 1,-54 3,-52 C6,-40 8,-20 7,0Z")
        let stretch: CGFloat = height / 60
        var bx: CGFloat = x0 + 30
        while bx < x1 - 16 {
            let place = CGAffineTransform(translationX: bx, y: baseY).scaledBy(x: 1, y: stretch)
            buttresses.addPath(pier.applying(place))
            bx += 70
        }
        Kit.solid(&context, buttresses, Kit.builtTone(color, 1.06), light: 0.3, shade: 0.3)
        Art.fill(&context, Art.rect(x0, baseY - height * 0.14, x1 - x0, height * 0.14), Kit.builtTone(color, 0.82).opacity(0.5))
        ArtStyle.tooth(&context, in: CGRect(x: x0, y: top, width: x1 - x0, height: height), seed: 13, color: Color.white, alpha: 0.08)
    }

    /// A flat-roofed banco house, origin on the ground under its middle: tapered walls with
    /// rounded corners, a parapet with small corner pinnacles, palm-wood beam ends (toron)
    /// jutting in a row, one pottery water spout and a small dark doorway.
    static func bancoHouse(_ context: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, width: CGFloat, height: CGFloat, color: UInt32 = GriotArt.banco, door: Bool = true) {
        let half: CGFloat = width / 2
        let top: CGFloat = baseY - height
        let lean: CGFloat = width * 0.04
        var body = Path()
        body.move(to: CGPoint(x: cx - half, y: baseY))
        body.addLine(to: CGPoint(x: cx - half + lean, y: top + 6))
        body.addQuadCurve(to: CGPoint(x: cx - half + lean + 6, y: top), control: CGPoint(x: cx - half + lean, y: top))
        body.addLine(to: CGPoint(x: cx + half - lean - 6, y: top))
        body.addQuadCurve(to: CGPoint(x: cx + half - lean, y: top + 6), control: CGPoint(x: cx + half - lean, y: top))
        body.addLine(to: CGPoint(x: cx + half, y: baseY))
        body.closeSubpath()
        Kit.solid(&context, body, Art.color(color), light: 0.26, shade: 0.28, rim: 1.6)
        let pinL: Path = Art.svg("M-4,0 C-4,-6 -2,-11 0,-13 C2,-11 4,-6 4,0Z").applying(CGAffineTransform(translationX: cx - half + lean + 4, y: top + 1))
        let pinR: Path = Art.svg("M-4,0 C-4,-6 -2,-11 0,-13 C2,-11 4,-6 4,0Z").applying(CGAffineTransform(translationX: cx + half - lean - 4, y: top + 1))
        Kit.solid(&context, pinL, Kit.builtTone(color, 1.08), light: 0.3, shade: 0.2)
        Kit.solid(&context, pinR, Kit.builtTone(color, 0.96), light: 0.2, shade: 0.3)
        var beams = Path()
        let count: Int = max(2, Int(width / 16))
        for i in 0..<count {
            let t: CGFloat = (CGFloat(i) + 0.5) / CGFloat(count)
            let bx: CGFloat = cx - half + lean + (width - lean * 2) * t
            beams.addPath(Art.rect(bx - 1.3, top + 8, 2.6, 4.4, radius: 1))
        }
        Art.fill(&context, beams, Art.color(0x5A3A22))
        let spout: Path = Art.rect(cx + half * 0.5, top + 3, 9, 3, radius: 1.4)
        Kit.solid(&context, spout, Art.color(0xB0683A), light: 0.3, shade: 0.2)
        if door {
            let dw: CGFloat = max(8, width * 0.18)
            let dh: CGFloat = max(12, height * 0.46)
            let doorway: Path = Art.rect(cx - half * 0.3 - dw / 2, baseY - dh, dw, dh, radius: dw * 0.3)
            Art.fill(&context, doorway, Art.color(0x3A2416))
            Art.fill(&context, Art.rect(cx - half * 0.3 - dw / 2, baseY - dh, 2, dh), ArtStyle.warmLight.opacity(0.25))
        }
        ArtStyle.tooth(&context, in: CGRect(x: cx - half, y: top, width: width, height: height), seed: 29, color: Color.white, alpha: 0.08)
    }

    /// A round mud granary with a conical thatched cap, origin on the ground under it.
    static func granary(_ context: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, width: CGFloat, height: CGFloat) {
        let half: CGFloat = width / 2
        let eave: CGFloat = baseY - height * 0.62
        let stand: Path = Art.rect(cx - half * 0.7, baseY - 6, half * 1.4, 6, radius: 2)
        Kit.solid(&context, stand, Art.color(bancoDeep), light: 0.2, shade: 0.2)
        var drum = Path()
        drum.move(to: CGPoint(x: cx - half * 0.8, y: baseY - 5))
        drum.addCurve(to: CGPoint(x: cx - half * 0.86, y: eave), control1: CGPoint(x: cx - half * 1.04, y: baseY - height * 0.24), control2: CGPoint(x: cx - half * 1.02, y: eave + height * 0.1))
        drum.addLine(to: CGPoint(x: cx + half * 0.86, y: eave))
        drum.addCurve(to: CGPoint(x: cx + half * 0.8, y: baseY - 5), control1: CGPoint(x: cx + half * 1.02, y: eave + height * 0.1), control2: CGPoint(x: cx + half * 1.04, y: baseY - height * 0.24))
        drum.closeSubpath()
        Kit.solid(&context, drum, Art.color(banco), light: 0.3, shade: 0.32, rim: 1.6)
        Kit.builtConeRoof(&context, cx: cx, eaveY: eave + 3, width: width * 1.16, height: height * 0.46, color: 0xC8A868)
    }

    /// A woven palm-leaf mat lying on the ground, centred on cx.
    static func mat(_ context: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, width: CGFloat, color: UInt32 = 0xD8BC84) {
        let half: CGFloat = width / 2
        let depth: CGFloat = width * 0.14
        let shape: Path = Art.polygon([
            CGPoint(x: cx - half + depth * 0.6, y: baseY - depth), CGPoint(x: cx + half - depth * 0.2, y: baseY - depth),
            CGPoint(x: cx + half, y: baseY), CGPoint(x: cx - half, y: baseY),
        ])
        Kit.solid(&context, shape, Art.color(color), light: 0.2, shade: 0.16)
        var weave = Path()
        let rows: Int = 4
        for i in 1..<rows {
            let y: CGFloat = baseY - depth * CGFloat(i) / CGFloat(rows)
            weave.move(to: CGPoint(x: cx - half + 3, y: y))
            weave.addLine(to: CGPoint(x: cx + half - 3, y: y))
        }
        Art.stroke(&context, weave, Kit.builtTone(color, 0.78).opacity(0.7), width: 0.9)
        Art.stroke(&context, Art.line(cx - half, baseY, cx + half, baseY), Kit.builtTone(color, 0.7), width: 1.2)
    }
}

// MARK: - The river: pirogues, salt, the town on its island, the reeds

extension GriotArt {
    /// A long, narrow plank pirogue, bow to the LEFT, floating with its waterline at waterY:
    /// raised tapering ends, two plank seams, a lit gunwale. `salt` stacks grey slabs in its
    /// belly; `awning` adds a low arched awning of striped matting near the stern.
    static func pirogue(_ context: inout GraphicsContext, cx: CGFloat, waterY: CGFloat, length L: CGFloat, salt: Bool = false, awning: Bool = false) {
        let half: CGFloat = L / 2
        let hgt: CGFloat = L * 0.05
        Art.fill(&context, Art.ellipse(cx + L * 0.02, waterY + hgt * 0.9, half * 0.92, hgt * 0.7), Art.color(0x3A2A1E, 0.22))
        if salt {
            saltLoad(&context, cx: cx, waterY: waterY, length: L)
        }
        if awning {
            let arch: Path = Art.svg("M0,0 C2,-22 40,-24 44,0Z").applying(CGAffineTransform(translationX: cx + half * 0.32, y: waterY - hgt).scaledBy(x: L / 300, y: L / 300))
            Kit.solid(&context, arch, Art.color(0xD8BC84), light: 0.24, shade: 0.24)
            let stripes: Path = Art.svg("M10,-14 L10,0 M22,-17 L22,0 M34,-14 L34,0").applying(CGAffineTransform(translationX: cx + half * 0.32, y: waterY - hgt).scaledBy(x: L / 300, y: L / 300))
            Art.stroke(&context, stripes, Art.color(0x8A2E22, 0.7), width: 1.6)
        }
        var hull = Path()
        hull.move(to: CGPoint(x: cx - half, y: waterY - hgt * 1.7))
        hull.addQuadCurve(to: CGPoint(x: cx - half * 0.7, y: waterY + hgt * 0.4), control: CGPoint(x: cx - half * 0.96, y: waterY + hgt * 0.2))
        hull.addLine(to: CGPoint(x: cx + half * 0.7, y: waterY + hgt * 0.4))
        hull.addQuadCurve(to: CGPoint(x: cx + half, y: waterY - hgt * 1.7), control: CGPoint(x: cx + half * 0.96, y: waterY + hgt * 0.2))
        hull.addQuadCurve(to: CGPoint(x: cx + half * 0.7, y: waterY - hgt), control: CGPoint(x: cx + half * 0.86, y: waterY - hgt))
        hull.addLine(to: CGPoint(x: cx - half * 0.7, y: waterY - hgt))
        hull.addQuadCurve(to: CGPoint(x: cx - half, y: waterY - hgt * 1.7), control: CGPoint(x: cx - half * 0.86, y: waterY - hgt))
        hull.closeSubpath()
        Kit.solid(&context, hull, Art.color(boatWood), light: 0.26, shade: 0.3, rim: 1.6)
        let seamY: CGFloat = waterY - hgt * 0.3
        Art.stroke(&context, Art.line(cx - half * 0.78, seamY, cx + half * 0.78, seamY), Kit.builtTone(boatWood, 0.7), width: 1)
        let rim: Path = Art.line(cx - half * 0.72, waterY - hgt, cx + half * 0.72, waterY - hgt)
        Art.stroke(&context, rim, Kit.builtTone(boatWood, 1.4), width: 1.6)
        Kit.ripples(&context, cx, waterY + hgt * 0.5, L * 0.8, count: 2, color: Color.white, opacity: 0.4)
    }

    /// Grey-white slabs of rock salt stacked in two layers in a boat's belly, tied with rope.
    static func saltLoad(_ context: inout GraphicsContext, cx: CGFloat, waterY: CGFloat, length L: CGFloat) {
        let half: CGFloat = L / 2
        let hgt: CGFloat = L * 0.05
        let w: CGFloat = L * 0.06
        let h: CGFloat = hgt * 1.2
        var slabs = Path()
        for row in 0..<2 {
            let y: CGFloat = waterY - hgt - h * CGFloat(row + 1) + 1
            let count: Int = row == 0 ? 7 : 5
            let x0: CGFloat = cx - half * 0.55 + w * 0.5 * CGFloat(row)
            for i in 0..<count {
                let sx: CGFloat = x0 + w * CGFloat(i)
                slabs.addPath(Art.rect(sx, y, w - 1.2, h - 0.8, radius: 1.2))
            }
        }
        Kit.solid(&context, slabs, Art.color(saltGrey), light: 0.3, shade: 0.26)
        let rope: Path = Art.line(cx - half * 0.5, waterY - hgt - h * 1.4, cx + half * 0.3, waterY - hgt - h * 1.5)
        Art.stroke(&context, rope, Art.color(0x8A6A44), width: 1.1)
    }

    /// One slab of rock salt standing on end, origin at its foot.
    static func saltSlab(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, width: CGFloat, height: CGFloat, tilt: CGFloat = 0) {
        Art.group(&context, x: x, y: baseY, rotate: tilt) { g in
            Kit.shadow(&g, 0, 0, width: width * 1.3)
            let slab: Path = Art.svg("M-0.5,0 L-0.48,-0.96 C-0.46,-1 0.44,-1.01 0.48,-0.97 L0.5,0Z").applying(CGAffineTransform(scaleX: width, y: height))
            let tone: Kit.Stops = [(Art.color(0xECE8E0), 0), (Art.color(saltGrey), 0.5), (Art.color(0xB8B2A8), 1)]
            Kit.solid(&g, slab, stops: tone, light: 0.34, shade: 0.3, rim: 2)
            var strata = Path()
            for i in 1..<5 {
                let y: CGFloat = -height * CGFloat(i) / 5
                strata.move(to: CGPoint(x: -width * 0.46, y: y))
                strata.addQuadCurve(to: CGPoint(x: width * 0.46, y: y + 2), control: CGPoint(x: 0, y: y - 3))
            }
            Art.stroke(&g, strata, Art.color(0x9A948A, 0.5), width: 1.2)
        }
    }

    /// A far town of earth houses on a low island (Djenné in the flood): no mosque, only
    /// flat roofs, from x0 to x1 on baseY, its houses about `height` tall.
    static func islandTown(_ context: inout GraphicsContext, x0: CGFloat, x1: CGFloat, baseY: CGFloat, height: CGFloat, light: Kit.Light) {
        guard x1 > x0 else { return }
        let span: CGFloat = x1 - x0
        let island: Path = Art.svg("M0,0 C0.08,-0.5 0.3,-0.9 0.5,-0.9 C0.7,-0.9 0.92,-0.5 1,0Z").applying(CGAffineTransform(translationX: x0, y: baseY).scaledBy(x: span, y: height * 0.5))
        Art.fill(&context, island, Kit.builtTone(0xB8946A, 1))
        var random = ArtRandom(23)
        let count: Int = max(4, Int(span / (height * 0.8)))
        let wall: Color = Art.color(0xC9A27A)
        let roofLine: Color = Art.color(0xA8805A)
        for i in 0..<count {
            let t: CGFloat = (CGFloat(i) + 0.5) / CGFloat(count)
            let hx: CGFloat = x0 + span * (0.1 + 0.8 * t)
            let rise: CGFloat = 1 - 2 * abs(t - 0.5)
            let hh: CGFloat = height * (0.55 + 0.35 * rise + 0.2 * Kit.rnd(&random))
            let hw: CGFloat = height * (0.7 + 0.5 * Kit.rnd(&random))
            let hy: CGFloat = baseY - height * 0.32 * rise
            Kit.farHouse(&context, cx: hx, baseY: hy, width: hw, height: hh, wall: wall, roof: roofLine, flat: true)
        }
        ArtStyle.atmosphere(&context, width: x1 + 20, top: baseY - height * 1.6, bottom: baseY + 2, color: light.haze, alpha: 0.32)
    }

    /// Reeds at the water's edge with two hanging weaverbird nests, origin at their foot.
    static func weaverReeds(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, height: CGFloat, seed: UInt32) {
        Kit.reeds(&context, x: x, baseY: baseY, count: 9, height: height, seed: seed, color: 0x5E7A3A)
        let nests: [(CGFloat, CGFloat)] = [(-12, -0.74), (10, -0.62)]
        for nest in nests {
            let nx: CGFloat = x + nest.0
            let ny: CGFloat = baseY + height * nest.1
            Art.stroke(&context, Art.line(nx, ny - 9, nx, ny - 4), Art.color(0x8A7A4A), width: 1)
            let ball: Path = Art.svg("M0,-5 C5,-5 7,0 6,5 C5,9 2,11 0,11 C-2,11 -5,9 -6,5 C-7,0 -5,-5 0,-5Z").applying(CGAffineTransform(translationX: nx, y: ny))
            Kit.solid(&context, ball, Art.color(0xB8A060), light: 0.3, shade: 0.3)
            Art.fill(&context, Art.circle(nx + 1, ny + 8, 1.8), Art.color(0x4A3A1E))
        }
    }

    /// A clay lamp burning in a wall niche, centred on (cx, cy).
    static func lampNiche(_ context: inout GraphicsContext, cx: CGFloat, cy: CGFloat, scale: CGFloat = 1) {
        Art.group(&context, x: cx, y: cy, scale: scale) { g in
            let niche: Path = Art.svg("M-8,8 L-8,-4 C-8,-10 8,-10 8,-4 L8,8Z")
            Art.fill(&g, niche, Art.color(0x7A4A2A))
            Art.fill(&g, Art.ellipse(0, 6, 5, 2), Art.color(0xA8683A))
            Kit.lamp(&g, cx: 0, cy: 2, radius: 2.4, color: 0xFFC96B)
        }
    }
}
