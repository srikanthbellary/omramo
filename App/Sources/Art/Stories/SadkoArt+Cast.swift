import SwiftUI
import OmramoCore

// The cast and the shared parts of "Sadko": palette, lights, Sadko and his gusli, the Sea
// Tsar, Chernava and her sisters, the white stone, the gold-finned fish, the red-sailed ship,
// the log houses and the white cathedral of Novgorod, and the palace under the sea.
//
// A DARK story: every picture is deep dusk, night or deep water.

extension SadkoArt {
    // MARK: Palette and light

    static let ramp = ArtStyle.Ramp(deep: 0x0C1730, shade: 0x17365A, mid: 0x1F6B66, light: 0xE9EEF2, glow: 0xFFC65A, accent: 0xC8352B)

    static let skinHex: UInt32 = 0xE9BE98
    static let tsarSkinHex: UInt32 = 0xD79E78
    static let beardHex: UInt32 = 0x3FA57C
    static let robeHex: UInt32 = 0x2E8F9A
    static let sailHex: UInt32 = 0xC8352B
    static let woodHex: UInt32 = 0x6E4A30
    static let stoneHex: UInt32 = 0xE9EEF2

    /// Night over the lake and the sea: starlight, no warm band.
    static func night() -> Kit.Light {
        let sky: Kit.Stops = [
            (Art.color(0x070E22), 0), (Art.color(0x0C1730), 0.45), (Art.color(0x14294A), 0.85), (Art.color(0x1D3F62), 1),
        ]
        return Kit.Light(sky: sky, sun: 0xF3ECD2, glow: 0x3F6F8E, haze: 0x1D3F62, far: 0x0A1226, mid: 0x0C1A30, near: 0x08101F, isNight: true)
    }

    /// Deep dusk over Novgorod: almost night, a last dull ember low on the horizon.
    static func dusk() -> Kit.Light {
        let sky: Kit.Stops = [
            (Art.color(0x0B1530), 0), (Art.color(0x14233F), 0.5), (Art.color(0x2B4468), 0.86), (Art.color(0x5E4A50), 1),
        ]
        return Kit.Light(sky: sky, sun: 0xF3ECD2, glow: 0xB9785A, haze: 0x2B4468, far: 0x101C36, mid: 0x14233F, near: 0x0B1428, isNight: true)
    }

    // MARK: People

    /// Sadko in Part I: undyed linen tunic with a red embroidered collar, hair cut round.
    static func sadkoLook() -> Kit.Person {
        Kit.Person(
            age: .adult, skin: skinHex, hair: 0x6B4428, hairStyle: .bob,
            garment: .tunic, cloth: 0xE4DAC2, trim: 0xC8352B, legs: 0x4E4038, showsEyeWhite: false
        )
    }

    /// Sadko the merchant: a long dark-blue coat edged with brown fur; a round cap if `cap`.
    static func merchantLook(cap: Bool) -> Kit.Person {
        Kit.Person(
            age: .adult, skin: skinHex, hair: 0x6B4428, hairStyle: .bob,
            headwear: cap ? Kit.Person.Headwear.cap : Kit.Person.Headwear.none, headwearColor: 0x8A5E3A,
            garment: .robe, cloth: 0x27467A, trim: 0x8A5E3A, legs: 0x3A2C28, showsEyeWhite: false
        )
    }

    /// Chernava: long straight dark hair, a plain grey gown, no jewels.
    static func chernavaLook() -> Kit.Person {
        Kit.Person(
            age: .adult, skin: 0xE6C8AE, hair: 0x2A2230, hairStyle: .long,
            garment: .dress, cloth: 0x8E97A8, trim: 0x8E97A8, legs: 0x8E97A8, showsEyeWhite: false
        )
    }

    /// One of Chernava's sisters, in the colours of river water with a little gold.
    static func maidenLook(_ index: Int) -> Kit.Person {
        let cloths: [UInt32] = [0x3E9AA0, 0x5E8FC0, 0x4FAE8E]
        let hairs: [UInt32] = [0x8A5A2E, 0x3A2A22, 0xB98A4A]
        let i: Int = abs(index) % 3
        return Kit.Person(
            age: .adult, skin: 0xE6C8AE, hair: hairs[i], hairStyle: .long,
            headwear: .circlet, headwearColor: 0xE8C060,
            garment: .dress, cloth: cloths[i], trim: 0xE8C060, legs: cloths[i], showsEyeWhite: false
        )
    }

    /// A sailor of Novgorod: brown tunic, short beard.
    static func sailorLook() -> Kit.Person {
        Kit.Person(
            age: .adult, skin: 0xDDAE88, hair: 0x4A3424, hairStyle: .short, beard: .short,
            garment: .tunic, cloth: 0x8A6A4A, trim: 0x5A3A2A, legs: 0x3A3030, showsEyeWhite: false
        )
    }

    /// The old singer of the bylina: white hair and beard, a linen tunic with a red band.
    static func singerLook() -> Kit.Person {
        Kit.Person(
            age: .elder, skin: 0xE2B48E, hair: 0xF2EEE6, hairStyle: .short, beard: .long,
            garment: .tunic, cloth: 0xD9CDB2, trim: 0xA8322A, legs: 0x4A3A32, showsEyeWhite: false
        )
    }

    /// A kit person in a rig of our own (the kit's `person`, with the joints given).
    static func figure(
        _ context: inout GraphicsContext,
        _ p: Kit.Person,
        _ r: Kit.BodyRig,
        look: CGPoint = .zero,
        mouth: Kit.Mouth = .smile
    ) {
        let f = Kit.bodyFrame(p)
        Art.group(&context, scale: f.k) { g in
            Kit.bodyFigure(&g, p, r, mirrored: false)
        }
        let c = Kit.bodyHeadCentre(f, r)
        let tilt: CGFloat = -Kit.deg(r.lean) * 0.45
        Art.group(&context, x: c.x, y: c.y, rotate: tilt, scale: f.headScale) { g in
            Kit.personHead(&g, p, look: look, mouth: mouth, closedEyes: false, mirrored: false)
        }
    }

    // MARK: The gusli

    /// The small wing-shaped maple gusli, lying flat: about 60 long, the wide end to the left,
    /// seven strings fanning from the narrow end. Origin at its middle.
    static func gusli(_ context: inout GraphicsContext, broken: Bool = false) {
        let body: Path = Art.svg("M-28,-10 C-10,-13 14,-9 29,-3 L29,4 C12,9 -12,12 -28,10 C-32,4 -32,-4 -28,-10Z")
        let maple: Kit.Stops = [(Art.color(0xE8BC7C), 0), (Art.color(0xB87A40), 1)]
        Kit.solid(&context, body, stops: maple, light: 0.3, shade: 0.24, rim: 1.2)
        Art.stroke(&context, body, Art.color(0x6E4322, 0.7), width: 0.9)
        Art.fill(&context, Art.ellipse(-19, 0, 5.4, 5), Art.color(0x4A2A16))
        Art.fill(&context, Art.rect(22.5, -3.6, 2.6, 8, radius: 1), Art.color(0x6E4322))
        var strings = Path()
        var pegs = Path()
        for i in 0..<7 {
            let t: CGFloat = CGFloat(i) / 6
            let y0: CGFloat = -2.6 + 5.8 * t
            let y1: CGFloat = -7.4 + 15 * t
            pegs.addEllipse(in: CGRect(x: -28.4, y: y1 - 0.9, width: 1.8, height: 1.8))
            strings.move(to: CGPoint(x: 23.5, y: y0))
            if broken {
                let curl: CGFloat = (i % 2 == 0) ? -5 : 5
                strings.addQuadCurve(to: CGPoint(x: 8 - 3 * t, y: y0 + curl), control: CGPoint(x: 14, y: y0 - curl))
            } else {
                strings.addLine(to: CGPoint(x: -27, y: y1))
            }
        }
        Art.stroke(&context, strings, Art.color(0xFFF1C4, 0.92), width: 0.7)
        Art.fill(&context, pegs, Art.color(0x4A2A16))
    }

    // MARK: Sadko

    /// Sadko sitting and playing, the gusli across his knees. Origin: the ground under the
    /// seat (the caller draws a seat 34 high under x 12). About 168 tall, facing LEFT.
    static func sadkoPlaying(
        _ context: inout GraphicsContext,
        merchant: Bool = false,
        look: CGPoint = .zero,
        mouth: Kit.Mouth = .smile,
        broken: Bool = false
    ) {
        let p: Kit.Person = merchant ? merchantLook(cap: false) : sadkoLook()
        var r = Kit.bodySitRig(p)
        r.nearElbow = Kit.pt(-2, 20)
        r.nearHand = Kit.pt(-20, 31)
        r.farElbow = Kit.pt(-10, 22)
        r.farHand = Kit.pt(-28, 30)
        figure(&context, p, r, look: look, mouth: mouth)
        Art.group(&context, x: -18, y: -57, rotate: Kit.deg(-4)) { g in
            gusli(&g, broken: broken)
        }
        var fingers = Path()
        fingers.addPath(Art.circle(-32, -61, 4.6))
        fingers.addPath(Art.circle(-6, -62, 4.6))
        Art.fill(&context, fingers, Art.color(skinHex))
    }

    /// Sadko the merchant standing with the gusli under his arm. Origin at the feet.
    static func sadkoStanding(_ context: inout GraphicsContext, look: CGPoint = .zero, mouth: Kit.Mouth = .flat) {
        let p: Kit.Person = merchantLook(cap: true)
        Kit.person(&context, p, pose: .stand, look: look, mouth: mouth)
        Art.group(&context, x: -22, y: -80, rotate: Kit.deg(78), scale: 0.95) { g in
            gusli(&g)
        }
        Art.fill(&context, Art.circle(-25, -62, 5.2), Art.color(skinHex))
    }

    /// The smooth white boulder at the lake's edge: Sadko's seat. Its top is 34 above the
    /// origin, which is the ground under its middle (x 8).
    static func whiteStone(_ context: inout GraphicsContext) {
        let stone: Path = Art.svg("M-44,2 C-52,-16 -36,-33 -8,-36 C18,-38 46,-32 54,-14 C58,-4 54,2 48,3Z")
        let tone: Kit.Stops = [(Art.color(0xF4F7FA), 0), (Art.color(0xC3CEDB), 0.55), (Art.color(0x8496B0), 1)]
        ArtStyle.contactShadow(&context, 10, 3, 60, 7, alpha: 0.4)
        Kit.solid(&context, stone, stops: tone, light: 0.3, shade: 0.3, rim: 2)
        let marks: Path = Art.svg("M-20,-22 q10,-5 22,-2 M14,-12 q10,2 16,8")
        Art.stroke(&context, marks, Art.color(0x8496B0, 0.5), width: 1.1)
    }

    // MARK: Fish

    /// A plain silver lake fish, 48 long, facing LEFT; with fins of red gold when `gold`.
    static func fish(_ context: inout GraphicsContext, gold: Bool = true) {
        let fin: Color = gold ? Art.color(0xF2A03D) : Art.color(0x7FA6AE)
        let tail: Path = Art.svg("M13,0 L27,-10 C23,-3 23,3 27,10Z")
        let fins: Path = Art.svg("M-6,-8 C0,-18 9,-15 10,-6Z M-5,8 C0,16 6,13 6,7Z")
        Art.fill(&context, tail, fin)
        Art.fill(&context, fins, fin)
        if gold {
            Art.stroke(&context, Art.svg("M17,-2 L24,-7 M17,2 L24,7 M-2,-10 L3,-14"), Art.color(0xFFD98A, 0.9), width: 0.8)
        }
        let body: Path = Art.svg("M-22,0 C-14,-10 6,-11 16,-2 L16,2 C6,11 -14,10 -22,0Z")
        let silver: Kit.Stops = [(Art.color(0xE4ECF0), 0), (Art.color(0x8FA6B4), 1)]
        Kit.solid(&context, body, stops: silver, light: 0.3, shade: 0.2)
        Art.stroke(&context, Art.svg("M-12,-5 q3,5 0,10"), Art.color(0x6E8494, 0.7), width: 0.8)
        ArtStyle.eye(&context, -16, -2, 1.9, showsWhite: false)
    }
}

// MARK: - The Sea Tsar

extension SadkoArt {
    /// A scallop shell standing on (x, y): 26 wide and 18 high at scale 1.
    static func shell(_ context: inout GraphicsContext, _ x: CGFloat, _ y: CGFloat, scale: CGFloat, hex: UInt32 = 0xF2E6CE) {
        let fan: Path = Kit.placed("M0,2 C-13,0 -14,-14 0,-16 C14,-14 13,0 0,2Z", x: x, y: y, scale: scale)
        Kit.solid(&context, fan, Art.color(hex), light: 0.3, shade: 0.24)
        let ribs: Path = Kit.placed("M0,1 L-8,-10 M0,1 L-3.5,-14 M0,1 L3.5,-14 M0,1 L8,-10", x: x, y: y, scale: scale)
        Art.stroke(&context, ribs, Kit.personTone(hex, 0.7).opacity(0.8), width: max(0.7, 0.9 * scale))
    }

    /// The Sea Tsar's head, facing the reader: a broad weathered face (54 across each way from
    /// the origin), bushy lifted brows, a green beard spreading like a net down to y 190 and
    /// out to x ±124, and a crown of red coral and shells reaching y −98.
    static func tsarHead(_ context: inout GraphicsContext, laughing: Bool = false) {
        let weeds: Path = Art.svg("M-50,-40 C-66,-20 -60,10 -72,40 M50,-40 C66,-18 58,8 70,36 M-44,-46 C-74,-36 -78,-6 -94,10")
        Art.stroke(&context, weeds, Art.color(0x2F7F58), width: 4)
        tsarBeard(&context)
        let face: Path = Art.ellipse(0, 0, 54, 52)
        let skin: Kit.Stops = [(Art.color(0xE6B088), 0), (Art.color(tsarSkinHex), 0.5), (Art.color(0xB67C5C), 1)]
        Kit.solid(&context, face, stops: skin, light: 0.26, shade: 0.22, rim: 1.6)
        ArtStyle.cheek(&context, -31, 14, 17, alpha: 0.45)
        ArtStyle.cheek(&context, 31, 14, 16, alpha: 0.45)
        if laughing {
            let lids: Path = Art.svg("M-29,-10 q8,-8 16,0 M13,-10 q8,-8 16,0")
            Art.stroke(&context, lids, Art.color(0x2A1A12), width: 3)
        } else {
            ArtStyle.eye(&context, -21, -12, 5.6, showsWhite: false)
            ArtStyle.eye(&context, 21, -12, 5.6, showsWhite: false)
        }
        // Bushy brows, lifted: never drawn down toward the nose.
        let brows: Path = Art.svg("M-36,-25 q13,-11 25,-4 M11,-29 q12,-7 25,4")
        Art.stroke(&context, brows, Art.color(0x2A7A60), width: 6.5)
        Art.stroke(&context, brows, Art.color(0x6FCF9F, 0.6), width: 1.6)
        let nose: Path = Art.ellipse(0, 8, 13, 11)
        Kit.solid(&context, nose, Art.color(0xC98862), light: 0.34, shade: 0.2)
        // The mouth, under the moustache.
        if laughing {
            let mouth: Path = Art.svg("M-17,32 C-6,36 6,36 17,32 C15,49 7,56 0,56 C-7,56 -15,49 -17,32Z")
            Art.fill(&context, mouth, Art.color(0x7A2E24))
            Art.clipped(&context, to: mouth) { g in
                Art.fill(&g, Art.ellipse(0, 55, 9, 6), Art.color(0xE8776A))
            }
        } else {
            ArtStyle.smile(&context, 0, 38, width: 24, curve: 4, color: Art.color(0x7A3A2A), lineWidth: 2.4)
        }
        let moustache: Path = Art.svg("M0,21 C-12,14 -36,18 -54,38 C-36,36 -14,37 0,27 C14,37 36,36 54,38 C36,18 12,14 0,21Z")
        Kit.solid(&context, moustache, Art.color(0x58BE90), light: 0.26, shade: 0.2)
        tsarCrown(&context)
    }

    /// The green beard: a wide net with a ragged lower edge, strands and faint net lines.
    static func tsarBeard(_ context: inout GraphicsContext) {
        let beard: Path = Art.svg("M-54,-8 C-92,18 -130,70 -122,140 C-98,128 -86,150 -72,172 C-58,150 -40,168 -24,190 C-12,168 10,170 22,190 C36,166 56,152 70,172 C84,148 98,130 122,140 C130,70 92,18 54,-8 C30,34 -30,34 -54,-8Z")
        let tone: Kit.Stops = [(Art.color(0x58BE90), 0), (Art.color(beardHex), 0.45), (Art.color(0x1C6A58), 1)]
        Kit.solid(&context, beard, stops: tone, light: 0.22, shade: 0.26, rim: 1.6)
        let strands: Path = Art.svg("M-32,36 C-52,70 -82,110 -102,138 M-15,44 C-25,90 -45,140 -68,168 M0,48 L0,184 M15,44 C25,90 45,140 68,168 M32,36 C52,70 82,110 102,138 M-48,14 C-76,40 -100,80 -112,120 M48,14 C76,40 100,80 112,120")
        let net: Path = Art.svg("M-98,52 C-50,74 50,74 98,52 M-112,92 C-60,114 60,114 112,92 M-112,130 C-60,152 60,152 112,130")
        Art.clipped(&context, to: beard) { g in
            Art.stroke(&g, strands, Art.color(0x17584A, 0.75), width: 1.8)
            Art.stroke(&g, net, Art.color(0x8FE3C8, 0.3), width: 1.4)
            Art.glow(&g, -50, 40, 80, ArtStyle.warmLight, alpha: 0.14)
        }
    }

    /// The crown: a band of pale shell, three scallops, pearls, and branches of red coral.
    static func tsarCrown(_ context: inout GraphicsContext) {
        let coral: Path = Art.svg("M-30,-54 C-32,-66 -36,-76 -34,-90 M-33,-70 L-46,-80 M-34,-78 L-24,-88 M0,-58 C0,-72 2,-84 0,-98 M1,-76 L-12,-88 M1,-82 L14,-92 M0,-68 L10,-74 M30,-54 C32,-66 36,-74 36,-88 M33,-68 L46,-78 M35,-78 L26,-88")
        Art.stroke(&context, coral, Art.color(0xB02A26), width: 6)
        Art.stroke(&context, coral, Art.color(0xD8483A), width: 4)
        let lit: Path = coral.applying(CGAffineTransform(translationX: -1.2, y: -0.8))
        Art.stroke(&context, lit, Art.color(0xF59A80, 0.7), width: 1.2)
        let band: Path = Art.svg("M-51,-30 C-30,-45 30,-45 51,-30 L47,-50 C28,-63 -28,-63 -47,-50Z")
        let pale: Kit.Stops = [(Art.color(0xF6EDD8), 0), (Art.color(0xC9B48E), 1)]
        Kit.solid(&context, band, stops: pale, light: 0.3, shade: 0.24, rim: 1.4)
        shell(&context, -27, -40, scale: 0.95)
        shell(&context, 0, -43, scale: 1.15, hex: 0xF7D9C4)
        shell(&context, 27, -40, scale: 0.95)
        var pearls = Path()
        let spots: [(CGFloat, CGFloat)] = [(-41, -36), (-14, -41), (14, -41), (41, -36)]
        for spot in spots {
            pearls.addPath(Art.circle(spot.0, spot.1, 2.4))
        }
        Art.fill(&context, pearls, Art.color(0xFFFDF4))
    }

    /// The Sea Tsar risen from the water to the chest. Origin at the centre of his head; the
    /// water stands `waterline` units below it. Draws the foam and rings on the water too.
    static func tsarRising(_ context: inout GraphicsContext, waterline: CGFloat, laughing: Bool = false) {
        let clip: Path = Art.rect(-280, -280, 560, 280 + waterline)
        Art.clipped(&context, to: clip) { g in
            let robe: Path = Art.svg("M-152,260 C-152,96 -92,44 0,44 C92,44 152,96 152,260Z")
            let cloth: Kit.Stops = [(Art.color(0x3BA3A8), 0), (Art.color(robeHex), 0.4), (Art.color(0x174E66), 1)]
            Kit.solid(&g, robe, stops: cloth, light: 0.24, shade: 0.26, rim: 2)
            tsarHead(&g, laughing: laughing)
            // Water pouring from the crown, the beard and the shoulders.
            let pour: Path = Art.svg("M-118,138 L-118,250 M-70,172 L-70,250 M-24,190 L-24,250 M22,190 L22,250 M70,172 L70,250 M118,138 L118,250 M-140,110 L-142,250 M140,110 L142,250")
            Art.stroke(&g, pour, Art.color(0xE9EEF2, 0.4), width: 2.2)
        }
        Art.fill(&context, Art.ellipse(0, waterline, 172, 8), Art.color(0xE9EEF2, 0.3))
        var foam = Path()
        for i in 0..<11 {
            let x: CGFloat = -150 + CGFloat(i) * 30
            let r: CGFloat = 5 + CGFloat((i * 7) % 4)
            foam.addPath(Art.circle(x, waterline - 1, r))
        }
        Art.fill(&context, foam, Art.color(0xE9EEF2, 0.55))
        Kit.ripples(&context, 0, waterline + 5, 360, count: 3, color: Art.color(0xE9EEF2), opacity: 0.6)
    }

    /// The Sea Tsar dancing: one big bare foot planted at the origin, the other up, robe
    /// swirling, arms flung wide. About 360 tall (the coral reaches y −352), 270 wide.
    static func tsarDancing(_ context: inout GraphicsContext, laughing: Bool = true) {
        let skin: Color = Art.color(tsarSkinHex)
        let skinDark: Color = Art.color(0xB67C5C)
        // The lifted leg and the planted leg.
        Kit.limb(&context, "M34,-76 Q70,-70 80,-34", 24, skinDark)
        tsarFoot(&context, 92, -28, rotate: -18, color: skinDark)
        Kit.limb(&context, "M-22,-76 L-24,-14", 26, skin)
        tsarFoot(&context, -34, -7, rotate: 0, color: skin)
        // Arms behind the robe's shoulders.
        Kit.limb(&context, "M52,-214 Q112,-204 134,-244", 26, Art.color(0x1F6F80))
        Art.fill(&context, Art.circle(136, -250, 13), skinDark)
        Kit.limb(&context, "M-52,-214 Q-110,-222 -128,-270", 26, Art.color(robeHex))
        Art.fill(&context, Art.circle(-130, -276, 13), skin)
        // The robe: a great bell with a swirling hem of foam.
        let robe: Path = Art.svg("M-58,-234 C-98,-180 -114,-110 -122,-62 C-92,-44 -62,-70 -32,-52 C-2,-36 30,-66 60,-50 C86,-38 108,-58 126,-78 C114,-132 94,-190 58,-234Z")
        let cloth: Kit.Stops = [(Art.color(0x3BA3A8), 0), (Art.color(robeHex), 0.4), (Art.color(0x174E66), 1)]
        Kit.solid(&context, robe, stops: cloth, light: 0.26, shade: 0.28, rim: 2.4)
        let waves: Path = Art.svg("M-108,-124 C-60,-100 40,-144 108,-114 M-116,-92 C-60,-70 50,-112 120,-88 M-92,-160 C-50,-142 40,-176 92,-152")
        Art.clipped(&context, to: robe) { g in
            Art.stroke(&g, waves, Art.color(0x8FE3C8, 0.4), width: 3)
            Art.glow(&g, -30, -130, 70, Art.color(0x8FE3C8), alpha: 0.2)
        }
        let hem: [(CGFloat, CGFloat)] = [
            (-116, -62), (-98, -54), (-78, -58), (-58, -62), (-38, -55), (-18, -47), (4, -50),
            (24, -57), (44, -56), (64, -49), (84, -47), (102, -56), (118, -70),
        ]
        var foam = Path()
        for spot in hem {
            foam.addPath(Art.circle(spot.0, spot.1, 7))
        }
        Art.fill(&context, foam, Art.color(0xE9EEF2, 0.85))
        Art.group(&context, x: 0, y: -262, rotate: Kit.deg(-5), scale: 0.72) { g in
            tsarHead(&g, laughing: laughing)
        }
    }

    /// One big bare foot, toes to the left, centred on (x, y).
    static func tsarFoot(_ context: inout GraphicsContext, _ x: CGFloat, _ y: CGFloat, rotate: CGFloat, color: Color) {
        Art.group(&context, x: x, y: y, rotate: Kit.deg(rotate)) { g in
            var foot = Path()
            foot.addPath(Art.ellipse(0, 0, 25, 10))
            foot.addPath(Art.circle(-25, -3, 6.5))
            foot.addPath(Art.circle(-21, -9, 4.6))
            foot.addPath(Art.circle(-14, -12, 4))
            Art.fill(&g, foot, color)
            Art.stroke(&g, Art.svg("M-12,-6 q10,-5 24,-2"), ArtStyle.warmLight.opacity(0.4), width: 1.6)
        }
    }
}

// MARK: - Ships

extension SadkoArt {
    /// The mast, the yard and the one square red sail of a Novgorod ship (bellied full, or
    /// rolled on the yard when `furled`). Origin: the waterline under the middle of the hull.
    static func shipSail(_ context: inout GraphicsContext, furled: Bool = false) {
        let rope: Color = Art.color(0xC9B79A, 0.45)
        Art.stroke(&context, Art.svg("M-4,-198 L-116,-92 M-4,-198 L124,-68"), rope, width: 1)
        Art.stroke(&context, Art.line(-4, -22, -4, -200), Art.color(0x4A3424), width: 5.5)
        Art.stroke(&context, Art.line(-5.4, -24, -5.4, -198), ArtStyle.warmLight.opacity(0.3), width: 1.2)
        if furled {
            Art.stroke(&context, Art.line(-72, -150, 64, -150), Art.color(0x4A3424), width: 4)
            Art.stroke(&context, Art.line(-66, -144, 58, -144), Art.color(0x8A2A28), width: 11)
            Art.stroke(&context, Art.line(-64, -147, 54, -147), Art.color(0xC8352B, 0.6), width: 2.4)
            let ties: Path = Art.svg("M-44,-150 L-44,-138 M-18,-150 L-18,-138 M10,-150 L10,-138 M36,-150 L36,-138")
            Art.stroke(&context, ties, rope.opacity(0.9), width: 1.2)
            return
        }
        let sail: Path = Art.svg("M-72,-178 C-84,-140 -84,-100 -66,-60 C-34,-50 26,-50 58,-60 C76,-100 76,-140 64,-178Z")
        let red: Kit.Stops = [(Art.color(0xD4483A), 0), (Art.color(sailHex), 0.4), (Art.color(0x7E1F26), 1)]
        Kit.solid(&context, sail, stops: red, light: 0.3, shade: 0.32, rim: 2)
        let seams: Path = Art.svg("M-38,-178 C-46,-140 -46,-100 -36,-54 M-4,-178 C-6,-140 -6,-100 -4,-52 M30,-178 C36,-140 36,-100 28,-54")
        Art.clipped(&context, to: sail) { g in
            Art.stroke(&g, seams, Art.color(0x6A1A22, 0.6), width: 1.2)
            Art.glow(&g, -40, -140, 60, ArtStyle.warmLight, alpha: 0.16)
        }
        Art.stroke(&context, Art.line(-76, -180, 68, -180), Art.color(0x4A3424), width: 4)
        Art.stroke(&context, Art.svg("M-66,-60 L-92,-34 M58,-60 L92,-34"), rope, width: 1)
    }

    /// The clinker-built hull: a high carved prow to the LEFT, a stern post, a steering oar on
    /// the stern side, oar ports. 250 long; the gunwale is about 28 above the waterline (y 0).
    static func shipHull(_ context: inout GraphicsContext) {
        Art.fill(&context, Art.ellipse(4, 8, 126, 7), Art.color(0x050A18, 0.4))
        Art.stroke(&context, Art.line(104, -30, 117, 16), Art.color(0x4A3424), width: 3)
        Art.fill(&context, Art.ellipse(118, 14, 5, 11), Art.color(0x4A3424))
        let hull: Path = Art.svg("M-104,-30 C-70,-20 70,-20 100,-32 C112,-36 120,-50 122,-68 L130,-66 C130,-36 114,-2 84,6 L-80,6 C-104,2 -118,-16 -124,-38 C-128,-56 -126,-78 -118,-94 L-110,-90 C-116,-72 -114,-48 -104,-30Z")
        let wood: Kit.Stops = [(Art.color(0x8A6040), 0), (Art.color(woodHex), 0.4), (Art.color(0x36241E), 1)]
        Kit.solid(&context, hull, stops: wood, light: 0.26, shade: 0.28, rim: 1.6)
        let planks: Path = Art.svg("M-124,-34 C-70,-9 70,-9 128,-40 M-118,-18 C-70,3 70,3 120,-22")
        var ports = Path()
        for i in 0..<8 {
            let x: CGFloat = -70 + CGFloat(i) * 20
            ports.addPath(Art.circle(x, -15, 2.2))
        }
        Art.clipped(&context, to: hull) { g in
            Art.stroke(&g, planks, Art.color(0x2A1A16, 0.7), width: 1.3)
            Art.fill(&g, ports, Art.color(0x1E1412))
        }
        Art.stroke(&context, Art.svg("M-104,-30 C-70,-20 70,-20 100,-32"), ArtStyle.warmLight.opacity(0.5), width: 1.8)
        // The carved prow: a round bird's head with a short beak.
        var head = Path()
        head.addPath(Art.circle(-113, -99, 8.5))
        head.addPath(Art.svg("M-119,-105 L-133,-99 L-119,-95Z"))
        Kit.solid(&context, head, Art.color(0x8A6040), light: 0.3, shade: 0.24)
        Art.fill(&context, Art.circle(-115, -101, 1.5), Art.color(0x1E1412))
    }

    /// A whole ship with nobody aboard (for far ships and boats at the quay).
    static func ship(_ context: inout GraphicsContext, furled: Bool = false) {
        shipSail(&context, furled: furled)
        shipHull(&context)
    }

    /// A barrel standing on the origin, 22 wide and 26 high.
    static func barrel(_ context: inout GraphicsContext) {
        let body: Path = Art.svg("M-9,0 C-13,-8 -13,-18 -9,-26 L9,-26 C13,-18 13,-8 9,0Z")
        Kit.solid(&context, body, Art.color(0x9A6E44), light: 0.3, shade: 0.28)
        Art.stroke(&context, Art.svg("M-11.4,-7 L11.4,-7 M-11.4,-19 L11.4,-19"), Art.color(0x4A3424), width: 2, cap: .butt)
    }

    /// A tied bundle of furs lying on the origin, 30 wide and 18 high.
    static func furBundle(_ context: inout GraphicsContext, hex: UInt32 = 0x7A5232) {
        var fur: Path = Kit.personScallop(cx: 0, cy: -9, rx: 13, ry: 7, from: 0, to: 330, count: 10, r: 4.2)
        fur.addPath(Art.ellipse(0, -9, 13, 8))
        Kit.solid(&context, fur, Art.color(hex), light: 0.26, shade: 0.26)
        Art.stroke(&context, Art.svg("M-4,-19 L-4,1 M5,-19 L5,1"), Art.color(0xE4DAC2, 0.8), width: 1.3)
    }
}

// MARK: - Novgorod

extension SadkoArt {
    /// A house of round horizontal logs with notched corners and a steep plank roof, seen
    /// gable-on. Origin: the ground under its middle. `w` is the wall; the ridge stands about
    /// `wall + 0.8 w` high. One small window, glowing with lamplight when `lit`.
    static func logHouse(_ context: inout GraphicsContext, w: CGFloat, wall: CGFloat, lit: Bool) {
        let half: CGFloat = w / 2
        let ridge: CGFloat = -wall - w * 0.8
        let walls: Path = Art.rect(-half, -wall, w, wall)
        let gable: Path = Art.polygon([CGPoint(x: -half, y: -wall), CGPoint(x: 0, y: ridge + 6), CGPoint(x: half, y: -wall)])
        var front = Path()
        front.addPath(walls)
        front.addPath(gable)
        let logs: Kit.Stops = [(Art.color(0x5E4634), 0), (Art.color(0x3A2A24), 1)]
        Kit.solid(&context, front, stops: logs, light: 0.2, shade: 0.3)
        var seams = Path()
        var ends = Path()
        var y: CGFloat = -4
        while y > ridge {
            seams.move(to: CGPoint(x: -half - 4, y: y))
            seams.addLine(to: CGPoint(x: half + 4, y: y))
            if y > -wall {
                ends.addPath(Art.circle(-half - 2, y + 3.5, 3.2))
                ends.addPath(Art.circle(half + 2, y + 3.5, 3.2))
            }
            y -= 7
        }
        Art.fill(&context, ends, Art.color(0x6E543C))
        Art.clipped(&context, to: front) { g in
            Art.stroke(&g, seams, Art.color(0x241A18, 0.7), width: 1.2)
        }
        // The steep roof: two plank slopes seen edge-on, the left one catching the light.
        let over: CGFloat = half + 9
        let left: Path = Art.polygon([CGPoint(x: -over, y: -wall + 5), CGPoint(x: 0, y: ridge), CGPoint(x: 0, y: ridge + 9), CGPoint(x: -over + 6, y: -wall + 9)])
        let right: Path = Art.polygon([CGPoint(x: over, y: -wall + 5), CGPoint(x: 0, y: ridge), CGPoint(x: 0, y: ridge + 9), CGPoint(x: over - 6, y: -wall + 9)])
        Art.fill(&context, right, Art.color(0x2A2230))
        Art.fill(&context, left, Art.color(0x4A4458))
        Art.stroke(&context, Art.line(-over, -wall + 5, 0, ridge), ArtStyle.warmLight.opacity(0.35), width: 1.2)
        // The window.
        let wy: CGFloat = -wall * 0.62
        if lit {
            Art.glow(&context, 0, wy, w * 0.5, Art.color(0xFFC65A), alpha: 0.3)
        }
        let pane: Path = Art.rect(-5, wy - 6, 10, 12, radius: 1.5)
        Art.fill(&context, pane, lit ? Art.color(0xFFC65A) : Art.color(0x1A1620))
        Art.stroke(&context, pane, Art.color(0x241A18), width: 1.6)
    }

    /// A smooth helmet-shaped dome (pointed like a warrior's helmet, never bulging past its
    /// drum), `r` half its width, standing on (cx, baseY), with a plain short finial.
    static func helmetDome(_ context: inout GraphicsContext, _ cx: CGFloat, _ baseY: CGFloat, r: CGFloat, gold: Bool) {
        let dome: Path = Kit.placed("M-1.06,0 C-1.08,-0.8 -0.46,-1.25 0,-1.95 C0.46,-1.25 1.08,-0.8 1.06,0Z", x: cx, y: baseY, scale: r)
        let gilt: Kit.Stops = [(Art.color(0xF2CC6A), 0), (Art.color(0xA87A28), 1)]
        let lead: Kit.Stops = [(Art.color(0x9AA6B6), 0), (Art.color(0x4E5A6E), 1)]
        if gold {
            Art.glow(&context, cx, baseY - r, r * 2.6, Art.color(0xFFC65A), alpha: 0.22)
        }
        Kit.solid(&context, dome, stops: gold ? gilt : lead, light: 0.32, shade: 0.3, rim: max(0.8, r * 0.08))
        let top: CGFloat = baseY - r * 1.95
        Art.stroke(&context, Art.line(cx, top, cx, top - r * 0.5), gold ? Art.color(0xF2CC6A) : Art.color(0x9AA6B6), width: 1.3)
    }

    /// The white cathedral: tall plain walls, narrow windows, a tight cluster of five helmet
    /// domes, the middle one gilded and the others lead-grey. Origin: the ground under its
    /// middle; 136 wide, about 215 high.
    static func cathedral(_ context: inout GraphicsContext) {
        let white: Kit.Stops = [(Art.color(0xE6EBF0), 0), (Art.color(0xB4C0D0), 0.6), (Art.color(0x8292AC), 1)]
        var body = Path()
        body.addPath(Art.rect(-66, -112, 132, 112))
        body.addPath(Art.ellipse(-44, -112, 22, 17))
        body.addPath(Art.ellipse(0, -112, 22, 19))
        body.addPath(Art.ellipse(44, -112, 22, 17))
        // The drums, the outer pair first.
        let drums: [(CGFloat, CGFloat, CGFloat)] = [(-52, -148, 10), (52, -148, 10), (-28, -160, 12), (28, -160, 12), (0, -176, 16)]
        var towers = Path()
        for drum in drums {
            towers.addPath(Art.rect(drum.0 - drum.2, drum.1, drum.2 * 2, -drum.1 - 110))
        }
        Kit.solid(&context, towers, stops: white, light: 0.24, shade: 0.3)
        Kit.solid(&context, body, stops: white, light: 0.26, shade: 0.3, rim: 1.6)
        var slits = Path()
        let windows: [(CGFloat, CGFloat)] = [(-44, -86), (0, -90), (44, -86), (-44, -44), (0, -46), (44, -44)]
        for window in windows {
            slits.addPath(Art.rect(window.0 - 2.4, window.1, 4.8, 20, radius: 2.4))
        }
        for drum in drums {
            slits.addPath(Art.rect(drum.0 - 1.4, drum.1 + 6, 2.8, 12, radius: 1.4))
        }
        Art.fill(&context, slits, Art.color(0x24304E))
        Art.stroke(&context, Art.svg("M-22,-108 L-22,0 M22,-108 L22,0"), Art.color(0x7686A4, 0.6), width: 1.4)
        Art.fill(&context, Art.rect(-5, -22, 10, 22, radius: 5), Art.color(0x24304E))
        for drum in drums {
            helmetDome(&context, drum.0, drum.1, r: drum.2 + 1.5, gold: drum.2 > 14)
        }
    }

    /// A stretch of the old rampart from `x0` to `x1`, standing on `y`: a pale bank of earth
    /// and white stone with a timber palisade along its top.
    static func rampart(_ context: inout GraphicsContext, x0: CGFloat, x1: CGFloat, y: CGFloat) {
        guard x1 > x0 else { return }
        let bank: Path = Art.rect(x0, y - 24, x1 - x0, 24)
        let pale: Kit.Stops = [(Art.color(0xC4CAD0), 0), (Art.color(0x76829A), 1)]
        Kit.solid(&context, bank, stops: pale, light: 0.2, shade: 0.24)
        var stakes = Path()
        var x: CGFloat = x0 + 2
        while x < x1 {
            stakes.move(to: CGPoint(x: x, y: y - 22))
            stakes.addLine(to: CGPoint(x: x, y: y - 33))
            x += 5
        }
        Art.stroke(&context, stakes, Art.color(0x4A3A34), width: 3.2, cap: .butt)
        Art.stroke(&context, Art.line(x0, y - 12, x1, y - 12), Art.color(0x5E6A84, 0.5), width: 1)
    }

    /// A wooden tower of the rampart with a pointed plank roof. Origin: the ground under it.
    static func woodTower(_ context: inout GraphicsContext) {
        let shaft: Path = Art.rect(-11, -58, 22, 58)
        Kit.solid(&context, shaft, stops: Kit.stops(0x5E4634, 0x34262A), light: 0.2, shade: 0.3)
        Art.stroke(&context, Art.svg("M-11,-14 L11,-14 M-11,-28 L11,-28 M-11,-42 L11,-42"), Art.color(0x241A18, 0.6), width: 1)
        Art.fill(&context, Art.rect(-14, -64, 28, 8), Art.color(0x4A3A34))
        let roof: Path = Art.polygon([CGPoint(x: -16, y: -64), CGPoint(x: 0, y: -98), CGPoint(x: 16, y: -64)])
        Kit.solid(&context, roof, Art.color(0x3A3446), light: 0.28, shade: 0.3)
        Art.fill(&context, Art.rect(-2.5, -52, 5, 9, radius: 1), Art.color(0x1A1620))
    }

    /// A stretch of wooden quay on posts from `x0` to `x1`, its deck at `y`.
    static func quay(_ context: inout GraphicsContext, x0: CGFloat, x1: CGFloat, y: CGFloat) {
        guard x1 > x0 else { return }
        var posts = Path()
        var x: CGFloat = x0 + 6
        while x < x1 {
            posts.move(to: CGPoint(x: x, y: y - 6))
            posts.addLine(to: CGPoint(x: x, y: y + 13))
            x += 22
        }
        Art.stroke(&context, posts, Art.color(0x2A1E1C), width: 4, cap: .butt)
        Art.fill(&context, Art.rect(x0, y - 3, x1 - x0, 6, radius: 1.5), Art.color(0x6E543C))
        Art.fill(&context, Art.rect(x0, y - 3, x1 - x0, 1.6), ArtStyle.warmLight.opacity(0.35))
    }

    /// A torch on a post standing on the origin (flame at about y −62), with its glow.
    static func torch(_ context: inout GraphicsContext) {
        Art.glow(&context, 0, -64, 90, Art.color(0xFFC65A), alpha: 0.32)
        Art.stroke(&context, Art.line(0, 0, 0, -54), Art.color(0x3A2A24), width: 4)
        let flame: Path = Art.svg("M0,-76 C6,-68 8,-62 5,-56 C3,-52 -3,-52 -5,-56 C-8,-62 -4,-66 0,-76Z")
        Art.fill(&context, flame, Art.color(0xFF9A3A))
        Art.fill(&context, Art.ellipse(0, -59, 2.6, 5), Art.color(0xFFE9A8))
    }
}

// MARK: - Water things: reeds, weed, bubbles, the palace under the sea

extension SadkoArt {
    /// A clump of reeds growing up from (x, y), dark against the night water.
    static func reedClump(_ context: inout GraphicsContext, _ x: CGFloat, _ y: CGFloat, count: Int, height: CGFloat, seed: UInt32, color: Color) {
        var random = ArtRandom(seed)
        var stems = Path()
        var heads = Path()
        for i in 0..<max(0, count) {
            let bx: CGFloat = x + (CGFloat(i) - CGFloat(count) / 2) * 6 + Kit.rnd(&random) * 4
            let tall: CGFloat = height * (0.6 + Kit.rnd(&random) * 0.4)
            let lean: CGFloat = (Kit.rnd(&random) - 0.5) * height * 0.3
            stems.move(to: CGPoint(x: bx, y: y))
            stems.addQuadCurve(to: CGPoint(x: bx + lean, y: y - tall), control: CGPoint(x: bx, y: y - tall * 0.6))
            if i % 2 == 0 {
                heads.addPath(Art.ellipse(bx + lean, y - tall, 1.8, 6))
            }
        }
        Art.stroke(&context, stems, color, width: 1.8)
        Art.fill(&context, heads, color)
    }

    /// Ribbons of waterweed swaying up from (x, y).
    static func weed(_ context: inout GraphicsContext, _ x: CGFloat, _ y: CGFloat, count: Int, height: CGFloat, seed: UInt32, color: Color) {
        var random = ArtRandom(seed)
        var ribbons = Path()
        for i in 0..<max(0, count) {
            let bx: CGFloat = x + (CGFloat(i) - CGFloat(count) / 2) * 9
            let tall: CGFloat = height * (0.55 + Kit.rnd(&random) * 0.45)
            let sway: CGFloat = 8 + Kit.rnd(&random) * 10
            let mid: CGFloat = y - tall * 0.5
            ribbons.move(to: CGPoint(x: bx, y: y))
            ribbons.addQuadCurve(to: CGPoint(x: bx + sway * 0.3, y: mid), control: CGPoint(x: bx + sway, y: y - tall * 0.25))
            ribbons.addQuadCurve(to: CGPoint(x: bx + sway * 0.6, y: y - tall), control: CGPoint(x: bx - sway * 0.6, y: y - tall * 0.75))
        }
        Art.stroke(&context, ribbons, color, width: 4.5)
    }

    /// A few rising bubbles between `y0` (top) and `y1`, round about the column at `x`.
    static func bubbles(_ context: inout GraphicsContext, x: CGFloat, y0: CGFloat, y1: CGFloat, count: Int, seed: UInt32) {
        guard y1 > y0 else { return }
        var random = ArtRandom(seed)
        var rings = Path()
        var shines = Path()
        for _ in 0..<max(0, count) {
            let bx: CGFloat = x + (Kit.rnd(&random) - 0.5) * 36
            let by: CGFloat = y0 + (y1 - y0) * Kit.rnd(&random)
            let r: CGFloat = 2 + Kit.rnd(&random) * 3.5
            rings.addEllipse(in: CGRect(x: bx - r, y: by - r, width: r * 2, height: r * 2))
            shines.addEllipse(in: CGRect(x: bx - r * 0.6, y: by - r * 0.6, width: r * 0.5, height: r * 0.5))
        }
        Art.stroke(&context, rings, Art.color(0xBFE6D0, 0.4), width: 1)
        Art.fill(&context, shines, Art.color(0xFFFFFF, 0.5))
    }

    /// Soft shafts of green-gold light falling from the top of the water between `x0` and
    /// `x1` down to `bottom`.
    static func lightShafts(_ context: inout GraphicsContext, x0: CGFloat, x1: CGFloat, bottom: CGFloat) {
        guard x1 > x0, bottom > 0 else { return }
        let span: CGFloat = x1 - x0
        let fade: Kit.Stops = [(Art.color(0xE6D98A, 0.2), 0), (Art.color(0xBFE6A0, 0.07), 0.6), (Art.color(0xBFE6A0, 0), 1)]
        for i in 0..<4 {
            let t: CGFloat = CGFloat(i) / 4
            let top: CGFloat = x0 + span * (t + 0.06)
            let width: CGFloat = span * 0.11
            let slip: CGFloat = bottom * 0.16
            let shaft: Path = Art.polygon([
                CGPoint(x: top, y: 0), CGPoint(x: top + width, y: 0),
                CGPoint(x: top + width * 1.9 - slip, y: bottom), CGPoint(x: top - width * 0.6 - slip, y: bottom),
            ])
            Art.fillLinear(&context, shaft, fade, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: bottom))
        }
    }

    /// A round-headed arch `w` wide and `h` high standing on (cx, 0).
    static func archPath(_ cx: CGFloat, w: CGFloat, h: CGFloat) -> Path {
        let half: CGFloat = w / 2
        let spring: CGFloat = -(h - half)
        var path = Path()
        path.move(to: CGPoint(x: cx - half, y: 0))
        path.addLine(to: CGPoint(x: cx - half, y: spring))
        path.addCurve(
            to: CGPoint(x: cx + half, y: spring),
            control1: CGPoint(x: cx - half, y: spring - half * 1.33),
            control2: CGPoint(x: cx + half, y: spring - half * 1.33)
        )
        path.addLine(to: CGPoint(x: cx + half, y: 0))
        path.closeSubpath()
        return path
    }

    /// The Sea Tsar's palace: white stone with three round arches, pillars wound with
    /// waterweed, and giant shells for a roof. Origin: the sea floor under its middle;
    /// 320 wide, about 285 high.
    static func palace(_ context: inout GraphicsContext) {
        shell(&context, -104, -176, scale: 4.2, hex: 0xCFE0D4)
        shell(&context, 104, -176, scale: 4.2, hex: 0xCFE0D4)
        shell(&context, 0, -180, scale: 6.6, hex: 0xE2EEE2)
        let stone: Kit.Stops = [(Art.color(0xE2EEE6), 0), (Art.color(0xA9CDBE), 0.5), (Art.color(0x5E9488), 1)]
        let wall: Path = Art.rect(-150, -172, 300, 172)
        Kit.solid(&context, wall, stops: stone, light: 0.26, shade: 0.3, rim: 2)
        var openings = Path()
        openings.addPath(archPath(-96, w: 58, h: 128))
        openings.addPath(archPath(0, w: 70, h: 144))
        openings.addPath(archPath(96, w: 58, h: 128))
        let dark: Kit.Stops = [(Art.color(0x1A5A52), 0), (Art.color(0x0A2A33), 1)]
        Art.fillLinear(&context, openings, dark, from: CGPoint(x: 0, y: -144), to: CGPoint(x: 0, y: 0))
        Art.stroke(&context, openings, Art.color(0xF2F8F0, 0.7), width: 3)
        let blocks: Path = Art.svg("M-150,-150 L150,-150 M-150,-40 L-125,-40 M-67,-40 L-35,-40 M35,-40 L67,-40 M125,-40 L150,-40 M-150,-96 L-125,-96 M125,-96 L150,-96")
        Art.stroke(&context, blocks, Art.color(0x4E8478, 0.5), width: 1.2)
        // The pillars between the arches, wound with weed.
        let pillars: [CGFloat] = [-48, 48, -144, 144]
        for px in pillars {
            let pillar: Path = Art.rect(px - 8, -172, 16, 172, radius: 3)
            Kit.solid(&context, pillar, stops: stone, light: 0.3, shade: 0.3)
            var wind = Path()
            var y: CGFloat = -12
            while y > -160 {
                wind.move(to: CGPoint(x: px - 8, y: y))
                wind.addQuadCurve(to: CGPoint(x: px + 8, y: y - 16), control: CGPoint(x: px, y: y - 2))
                y -= 30
            }
            Art.stroke(&context, wind, Art.color(0x2F8F5E, 0.9), width: 3.4)
        }
        let cornice: Path = Art.rect(-160, -184, 320, 14, radius: 3)
        Kit.solid(&context, cornice, stops: stone, light: 0.3, shade: 0.26)
    }

    /// The coral throne: a pale shell seat among branches of red coral. Origin under its
    /// middle; 110 wide, 130 high.
    static func coralThrone(_ context: inout GraphicsContext) {
        let branches: Path = Art.svg("M-34,0 C-38,-40 -46,-70 -40,-112 M-38,-60 L-54,-78 M-40,-88 L-26,-104 M34,0 C38,-40 46,-66 42,-108 M39,-56 L54,-72 M42,-84 L28,-100 M0,-40 C0,-70 4,-100 0,-128 M1,-96 L-12,-112 M1,-104 L14,-118")
        Art.stroke(&context, branches, Art.color(0x8E2422), width: 9)
        Art.stroke(&context, branches, Art.color(0xC8352B), width: 6)
        let lit: Path = branches.applying(CGAffineTransform(translationX: -1.6, y: -1))
        Art.stroke(&context, lit, Art.color(0xF59A80, 0.6), width: 1.6)
        shell(&context, 0, -30, scale: 3.6, hex: 0xF2E6CE)
        let seat: Path = Art.rect(-32, -34, 64, 34, radius: 8)
        Kit.solid(&context, seat, stops: Kit.stops(0xE9EEF2, 0x7FA89A), light: 0.28, shade: 0.3)
    }
}
