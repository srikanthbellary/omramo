import SwiftUI
import OmramoCore

// "The Fire-Bird and the Horse of Power": palette, lights, the cast and the story's own parts.
// A dark story: night forest, candlelit log hall, the grey midnight of a white night and a
// torchlit courtyard. The Fire-Bird's gold is the strongest light wherever it is.

extension FirebirdArt {
    // MARK: Palette

    static let ramp = ArtStyle.Ramp(deep: 0x0B1424, shade: 0x1E3226, mid: 0x3A2216, light: 0xE6E2D6, glow: 0xFFB547, accent: 0xC8452B)

    /// Fire-Bird gold, from the white-hot core out to the ember edge.
    static let fireCore: UInt32 = 0xFFF0B0
    static let fireGold: UInt32 = 0xFFC43D
    static let fireAmber: UInt32 = 0xFFB547
    static let fireEmber: UInt32 = 0xE8562A
    static let fireRed: UInt32 = 0xC8452B

    /// Pine logs by candlelight, and the shadow between them.
    static let logLit: UInt32 = 0x6A3A1E
    static let logMid: UInt32 = 0x4A2A16
    static let logDark: UInt32 = 0x2A170C

    /// The Horse of Power: dark as a wet log.
    static let horseCoat: UInt32 = 0x2C211B
    static let horseDark: UInt32 = 0x16100D
    static let horseMane: UInt32 = 0x120D0B

    /// Night spruce: almost black blue-greens, the lightest only where a glow touches them.
    static func nightSpruce() -> Kit.Greens {
        Kit.greens(0x050E0D, 0x0A1A17, 0x10261F, 0x1A3829, 0x35563A)
    }

    /// Spruce lit gold from below by the feather or the bird.
    static func litSpruce() -> Kit.Greens {
        Kit.greens(0x0A1714, 0x163024, 0x2A4A2E, 0x6A6A34, 0xC89A44)
    }

    /// Birch crowns at night.
    static func nightBirch() -> Kit.Greens {
        Kit.greens(0x0E1E18, 0x18302A, 0x24443A, 0x3A5E48, 0x6A8A60)
    }

    // MARK: Lights

    /// The taiga at night: blue-black sky, a faint cool band on the horizon.
    static func night() -> Kit.Light {
        let sky: Kit.Stops = [
            (Art.color(0x060B16), 0), (Art.color(0x0B1424), 0.45), (Art.color(0x122236), 0.82), (Art.color(0x1E3040), 1),
        ]
        return Kit.Light(sky: sky, sun: 0xFFF1C4, glow: 0x34465A, haze: 0x16263A, far: 0x132232, mid: 0x0E1B1C, near: 0x0A1410, isNight: true)
    }

    /// The tsar's hall: brown shadow under the roof, candle warmth low down.
    static func hall() -> Kit.Light {
        let sky: Kit.Stops = [
            (Art.color(0x100906), 0), (Art.color(0x1A0F0A), 0.45), (Art.color(0x2C1910), 0.82), (Art.color(0x4A2A16), 1),
        ]
        return Kit.Light(sky: sky, sun: 0xFFE2A0, glow: 0x8A4A1E, haze: 0x2A170C, far: 0x2A170C, mid: 0x3A2216, near: 0x1A0F0A, isNight: true)
    }

    /// The white night at the end of the world: soft grey-blue midnight, still dark enough
    /// for the cream words.
    static func whiteNight() -> Kit.Light {
        let sky: Kit.Stops = [
            (Art.color(0x1C2638), 0), (Art.color(0x2A3446), 0.4), (Art.color(0x3A4658), 0.8), (Art.color(0x4E586C), 1),
        ]
        return Kit.Light(sky: sky, sun: 0xE6E2D6, glow: 0x6A7284, haze: 0x4A5468, far: 0x343E50, mid: 0x262E3C, near: 0x1C2430, isNight: true)
    }

    /// The palace courtyard: black sky over torches and the fire under the cauldron.
    static func courtyard() -> Kit.Light {
        let sky: Kit.Stops = [
            (Art.color(0x060509), 0), (Art.color(0x0E0A10), 0.45), (Art.color(0x1E1416), 0.82), (Art.color(0x3A2216), 1),
        ]
        return Kit.Light(sky: sky, sun: 0xFFE2A0, glow: 0x7A3A1A, haze: 0x1E1416, far: 0x1A1214, mid: 0x140E10, near: 0x0C0809, isNight: true)
    }

    // MARK: Looks

    /// The archer: a young huntsman in a long red-brown kaftan with a woven belt, a cap with
    /// a fur rim (added over the kit's cap), soft boots; brown hair cut round.
    static func archerLook() -> Kit.Person {
        Kit.Person(
            age: .adult, skin: 0xE6B08A, hair: 0x6B4128, hairStyle: .short, beard: .none,
            headwear: .cap, headwearColor: 0x8A2A1E, garment: .robe,
            cloth: 0x8E3C22, trim: 0xD4A040, legs: 0x4A2E1E, showsEyeWhite: false
        )
    }

    /// The old tsar: a long grey beard combed to his belt, a heavy robe in red and gold; his
    /// crown (gold filigree on a sable rim) is drawn over the head.
    static func tsarLook() -> Kit.Person {
        Kit.Person(
            age: .elder, skin: 0xE8B8A0, hair: 0xC9C5BC, hairStyle: .short, beard: .long,
            headwear: .none, headwearColor: 0xD4A040, garment: .robe,
            cloth: 0x8A2424, trim: 0xD9A23A, legs: 0x5A1A1A, showsEyeWhite: false
        )
    }

    /// Vasilissa: a dark-gold braid, a tall embroidered headdress (drawn over the head), a
    /// sea-blue sarafan over a white shirt.
    static func vasilissaLook() -> Kit.Person {
        Kit.Person(
            age: .adult, skin: 0xF0C6A6, hair: 0xA8822E, hairStyle: .short, beard: .none,
            headwear: .none, headwearColor: 0xD4A040, garment: .dress,
            cloth: 0x2E6A8E, trim: 0xF2ECE0, legs: 0x2A4A6A, showsEyeWhite: false
        )
    }

    /// A courtier or townsman in the torchlit crowd: dark kaftan, fur cap.
    static func courtierLook(_ cloth: UInt32, _ cap: UInt32) -> Kit.Person {
        Kit.Person(
            age: .adult, skin: 0xC89676, hair: 0x4A3022, hairStyle: .short, beard: .short,
            headwear: .furHat, headwearColor: cap, garment: .robe,
            cloth: cloth, trim: 0x6A4A2A, legs: 0x2A1A14, showsEyeWhite: false
        )
    }

    // MARK: Heads and headgear

    /// Draws `body` in the head's own units (origin at the centre of the skull, as in
    /// `Kit.personHead`) for a figure drawn with `Kit.person(… pose:)` at the same origin.
    static func onHead(_ context: inout GraphicsContext, _ p: Kit.Person, pose: Kit.Pose, _ body: (inout GraphicsContext) -> Void) {
        let f = Kit.bodyFrame(p)
        let r = Kit.bodyRig(p, pose)
        let c: CGPoint = Kit.bodyHeadCentre(f, r)
        let tilt: CGFloat = -Kit.deg(r.lean) * 0.45
        Art.group(&context, x: c.x, y: c.y, rotate: tilt, scale: f.headScale, body)
    }

    /// The brown fur rim of the archer's cap, over the kit cap's band.
    static func archerCapRim(_ h: inout GraphicsContext) {
        Art.stroke(&h, Art.svg("M-28,-12 C-18,-22 18,-22 28,-12"), Art.color(0x4A3020), width: 8)
        let fur: Path = Kit.personScallop(cx: 0, cy: 30, rx: 50, ry: 50, from: 236, to: 304, count: 9, r: 4.6)
        Art.fill(&h, fur, Art.color(0x6A4630))
        let lit: Path = Kit.personScallop(cx: -1, cy: 29, rx: 50, ry: 50, from: 238, to: 262, count: 4, r: 2.6)
        Art.fill(&h, lit, Art.color(0x9A7050))
    }

    /// The tsar's crown: a cap of gold filigree on a rim of dark sable, a few red and green
    /// stones and a gold knop with a pearl. Origin at the middle of the fur rim; 80 wide.
    static func crown(_ g: inout GraphicsContext) {
        let gold: UInt32 = 0xD9A23A
        let cap: Path = Art.svg("M-34,-4 C-36,-26 -22,-44 0,-48 C22,-44 36,-26 34,-4Z")
        Kit.solid(&g, cap, stops: Kit.stops(0xF2C860, gold, 0x9A6A1E), light: 0.3, shade: 0.3, rim: 1.6)
        let lace: Path = Art.svg("M0,-46 L0,-4 M-17,-40 C-22,-28 -24,-16 -24,-4 M17,-40 C22,-28 24,-16 24,-4 M-32,-18 C-20,-24 20,-24 32,-18 M-30,-30 C-20,-12 -10,-12 0,-30 C10,-12 20,-12 30,-30")
        Art.clipped(&g, to: cap) { c in
            Art.stroke(&c, lace, Art.color(0x8A5A16, 0.8), width: 1.4)
        }
        var reds = Path()
        reds.addPath(Art.ellipse(-12, -14, 3.4, 4.2))
        reds.addPath(Art.ellipse(12, -14, 3.4, 4.2))
        reds.addPath(Art.ellipse(0, -36, 2.8, 3.2))
        Art.fill(&g, reds, Art.color(0xB0242A))
        var greens = Path()
        greens.addPath(Art.ellipse(0, -18, 3.2, 3.8))
        greens.addPath(Art.ellipse(-24, -10, 2.4, 3))
        greens.addPath(Art.ellipse(24, -10, 2.4, 3))
        Art.fill(&g, greens, Art.color(0x1E8A5A))
        var sparks = Path()
        sparks.addPath(Art.circle(-13, -15.5, 1))
        sparks.addPath(Art.circle(11, -15.5, 1))
        sparks.addPath(Art.circle(-1, -19.5, 1))
        Art.fill(&g, sparks, Color.white.opacity(0.85))
        Art.fill(&g, Art.rect(-2.4, -58, 4.8, 12, radius: 2), Art.color(gold))
        Art.fill(&g, Art.circle(0, -60, 5), Art.color(0xF2E6D0))
        Art.fill(&g, Art.circle(-1.5, -61.5, 1.6), Color.white.opacity(0.9))
        let rim: Path = Art.rect(-40, -9, 80, 18, radius: 9)
        Kit.solid(&g, rim, Art.color(0x2E211A), light: 0.2, shade: 0.3)
        let tufts: Path = Kit.personScallop(cx: 0, cy: 0, rx: 39, ry: 9, from: 190, to: 350, count: 11, r: 3.4)
        Art.fill(&g, tufts, Art.color(0x3E2E24))
        Art.stipple(&g, in: CGRect(x: -38, y: -8, width: 76, height: 16), count: 40, seed: 17, color: Art.color(0x6A5444), alpha: 0.6, size: 0.5...1.2)
    }

    /// Vasilissa's tall embroidered headdress (a kokoshnik) and her one braid, in head units.
    static func kokoshnik(_ h: inout GraphicsContext) {
        let shield: Path = Art.svg("M-30,-12 C-36,-40 -20,-64 0,-66 C20,-64 36,-40 30,-12 C20,-22 -20,-22 -30,-12Z")
        Kit.solid(&h, shield, stops: Kit.stops(0x3A7AA0, 0x245A80), light: 0.26, shade: 0.24, rim: 1.4)
        let stitch: Path = Art.svg("M-24,-24 C-26,-44 -14,-58 0,-60 C14,-58 26,-44 24,-24 M0,-54 C-8,-46 -8,-36 0,-30 C8,-36 8,-46 0,-54Z M-16,-34 q-4,-6 0,-12 M16,-34 q4,-6 0,-12")
        Art.clipped(&h, to: shield) { c in
            Art.stroke(&c, stitch, Art.color(0xE6C060, 0.85), width: 1.4)
        }
        let pearls: Path = Kit.personScallop(cx: 0, cy: -16, rx: 31, ry: 49, from: 196, to: 344, count: 15, r: 1.7)
        Art.fill(&h, pearls, Art.color(0xF4EEE2))
        Art.stroke(&h, Art.svg("M-29,-13 C-20,-22 20,-22 29,-13"), Art.color(0xD4A040), width: 3)
    }

    /// The one long braid over the near shoulder, in head units (draw it before the head).
    static func braid(_ h: inout GraphicsContext, _ hair: UInt32, length: Int) {
        var plait = Path()
        var creases = Path()
        for index in 0..<max(1, length) {
            let t: CGFloat = CGFloat(index)
            let x: CGFloat = -24 + t * 0.6
            let y: CGFloat = 14 + t * 9
            plait.addEllipse(in: CGRect(x: x - 5.4, y: y - 5.6, width: 10.8, height: 11.2))
            creases.move(to: CGPoint(x: x - 4, y: y + 2.4))
            creases.addLine(to: CGPoint(x: x + 4, y: y + 5))
        }
        Art.fill(&h, plait, Art.color(hair))
        Art.stroke(&h, creases, Kit.personTone(hair, 0.7), width: 1)
    }
}

// MARK: - The people

extension FirebirdArt {
    /// The archer, standing or sitting, origin at his feet (or the ground under the seat),
    /// facing LEFT: bow across his back, quiver at his hip, fur-rimmed cap. `feather` shows
    /// the gold of the feather glowing through his coat.
    static func archer(
        _ g: inout GraphicsContext,
        pose: Kit.Pose,
        look: CGPoint = .zero,
        mouth: Kit.Mouth = .flat,
        mirrored: Bool = false,
        feather: Bool = false
    ) {
        let p = archerLook()
        if pose != .bow {
            let stave: Path = Art.svg("M24,-146 C36,-132 32,-114 26,-104 C20,-92 18,-80 10,-64")
            Art.stroke(&g, Art.line(24, -146, 10, -64), Art.color(0xE6D2A8, 0.7), width: 0.9)
            Art.stroke(&g, stave, Art.color(0x4A2C18), width: 4)
            Art.stroke(&g, stave, Art.color(0x8A5A30), width: 1.6)
        }
        let quiver: Path = Art.svg("M14,-96 L30,-100 L36,-58 L22,-54Z")
        Kit.solid(&g, quiver, Art.color(0x5A3A22), light: 0.2, shade: 0.3)
        Art.stroke(&g, Art.svg("M18,-98 L14,-112 M23,-99 L21,-114 M28,-100 L28,-113"), Art.color(0xC9B48A), width: 1.4)
        Kit.person(&g, p, pose: pose, look: look, mouth: mouth, mirrored: mirrored)
        onHead(&g, p, pose: pose) { h in
            archerCapRim(&h)
        }
        if feather {
            Art.glow(&g, -6, -96, 34, Art.color(fireAmber), alpha: 0.55)
            Art.glow(&g, -6, -96, 12, Art.color(fireCore), alpha: 0.6)
        }
    }

    /// The archer in the saddle, leaning `lean` degrees forward (to the left) from the hips.
    /// Origin is the horse's origin (the ground under its middle): call it right after `horse`.
    static func rider(_ g: inout GraphicsContext, lean: CGFloat, look: CGPoint, mouth: Kit.Mouth = .flat) {
        Art.group(&g, x: -4, y: -164, rotate: -Kit.deg(lean)) { a in
            Art.group(&a, x: -6, y: 46) { p in
                archer(&p, pose: .sit, look: look, mouth: mouth)
            }
        }
    }

    /// The old tsar on his carved chair, origin on the floor under the seat, facing LEFT,
    /// ringed hands reaching.
    static func tsarSeated(_ g: inout GraphicsContext, look: CGPoint = CGPoint(x: -0.6, y: 0.2), mouth: Kit.Mouth = .oh) {
        let wood: UInt32 = 0x6A3A1E
        Kit.shadow(&g, 10, 0, width: 90)
        let back: Path = Art.svg("M22,-34 L24,-150 C24,-168 32,-178 40,-178 C48,-178 56,-168 56,-150 L52,-34Z")
        Kit.solid(&g, back, stops: Kit.stops(0x8A5028, wood, 0x3A2010), light: 0.24, shade: 0.3, rim: 1.4)
        Art.stroke(&g, Art.svg("M30,-140 C36,-130 44,-130 50,-140 M30,-112 C36,-102 44,-102 50,-112 M40,-96 L40,-50"), Art.color(0x3A2010), width: 1.6)
        Art.fill(&g, Art.circle(40, -162, 8), Art.color(0xB07A30))
        Art.stroke(&g, Art.svg("M40,-174 L40,-178 M28,-162 L32,-162 M48,-162 L52,-162 M32,-170 L34,-168 M46,-168 L48,-170"), Art.color(0xB07A30), width: 1.4)
        var legs = Path()
        legs.addPath(Art.rect(-16, -32, 8, 32, radius: 2))
        legs.addPath(Art.rect(42, -32, 8, 32, radius: 2))
        Kit.solid(&g, legs, Art.color(0x4A2814), light: 0.2, shade: 0.3)
        Kit.solid(&g, Art.rect(-20, -40, 76, 9, radius: 3), Art.color(0x7A4422), light: 0.3, shade: 0.2, rim: 1.2)
        let p = tsarLook()
        Kit.person(&g, p, pose: .sit, look: look, mouth: mouth)
        let hand: CGPoint = Kit.hand(p, pose: .sit)
        Art.fill(&g, Art.circle(hand.x - 1, hand.y - 2, 2.2), Art.color(0xF2C860))
        Art.fill(&g, Art.circle(hand.x + 3, hand.y - 1, 1.8), Art.color(0xB0242A))
        onHead(&g, p, pose: .sit) { h in
            Art.group(&h, x: 0, y: -22, scale: 0.72) { c in
                crown(&c)
            }
        }
    }

    /// Vasilissa rowing her little silver boat, the boat centred on (0, 0) at the waterline,
    /// bow to the LEFT; about 100 long at scale 1.
    static func vasilissaBoat(_ g: inout GraphicsContext) {
        let p = vasilissaLook()
        Art.group(&g, x: 6, y: -4, scale: 0.56) { v in
            onHead(&v, p, pose: .sit) { h in
                braid(&h, p.hair, length: 5)
            }
            Kit.person(&v, p, pose: .sit, look: CGPoint(x: -0.4, y: 0), mouth: .smile)
            onHead(&v, p, pose: .sit) { h in
                kokoshnik(&h)
            }
        }
        Art.stroke(&g, Art.line(-8, -24, 30, 10), Art.color(0xA87A20), width: 3)
        Art.stroke(&g, Art.line(-8, -24, 30, 10), Art.color(fireGold), width: 1.6)
        Art.fill(&g, Art.ellipse(32, 11, 6, 2.4), Art.color(fireGold))
        Kit.boat(&g, cx: 0, waterY: 0, length: 100, hull: 0xAEB8C4, style: .rowing)
        Art.glow(&g, 30, 8, 18, Art.color(fireGold), alpha: 0.35)
    }

    /// A townsman of the crowd, a dark shape with a lit rim, origin at the feet.
    static func onlooker(_ g: inout GraphicsContext, cloth: UInt32, cap: UInt32, mirrored: Bool) {
        let p = courtierLook(cloth, cap)
        Kit.shadow(&g, 0, 0, width: 60)
        if mirrored {
            Art.group(&g, scaleX: -1) { m in
                Kit.person(&m, p, pose: .stand, look: CGPoint(x: -0.6, y: 0.2), mouth: .oh, mirrored: true)
            }
        } else {
            Kit.person(&g, p, pose: .stand, look: CGPoint(x: -0.6, y: 0.2), mouth: .oh)
        }
    }
}

// MARK: - The Horse of Power

extension FirebirdArt {
    /// The Horse of Power in profile, facing LEFT, origin on the ground under his middle.
    /// Huge and heavy-boned: withers about 150 high, ears about 260 (an adult is 168). `bend`
    /// (degrees, 0…70) lowers the neck toward the ground in front of him; `liftHoof` sets the
    /// near forefoot forward on the ground (gently, on a wing or a crab's back). `warm` is a
    /// point in his own units where a warm light (the feather, the bird, a fire) touches him.
    static func horse(
        _ g: inout GraphicsContext,
        bend: CGFloat = 0,
        liftHoof: Bool = false,
        saddled: Bool = true,
        warm: CGPoint? = nil,
        warmAlpha: Double = 0.45
    ) {
        let coat: Color = Art.color(horseCoat)
        let farCoat: Color = Kit.personTone(horseCoat, 0.7)
        let hoof: Color = Art.color(0x3A2E26)
        let neckT = CGAffineTransform(translationX: -70, y: -140).rotated(by: -Kit.deg(bend))
        let headT = neckT.translatedBy(x: -40, y: -98).rotated(by: Kit.deg(bend * 0.55))
        Kit.shadow(&g, 0, 0, width: 240, alpha: 0.32)

        // Far legs and the tail, behind the body.
        let farFront: Path = Art.svg("M-74,-96 C-76,-70 -70,-50 -70,-30 L-72,-8 L-56,-8 L-58,-30 C-58,-52 -54,-74 -54,-96Z")
        let farHind: Path = Art.svg("M48,-110 C66,-90 68,-70 62,-52 C60,-40 62,-24 62,-8 L48,-8 C48,-24 46,-40 48,-52 C50,-66 40,-84 32,-100Z")
        Art.fill(&g, farFront, farCoat)
        Art.fill(&g, farHind, farCoat)
        var farHooves = Path()
        farHooves.addPath(Art.rect(-74, -10, 20, 10, radius: 2))
        farHooves.addPath(Art.rect(46, -10, 18, 10, radius: 2))
        Art.fill(&g, farHooves, hoof)
        let tail: Path = Art.svg("M92,-138 C116,-132 124,-100 122,-70 C120,-40 128,-20 136,-4 C118,-6 104,-24 102,-50 C100,-80 100,-110 86,-124Z")
        Kit.solid(&g, tail, Art.color(horseMane), light: 0.18, shade: 0.2)
        Art.stroke(&g, Art.svg("M100,-128 C114,-104 112,-70 114,-44 C116,-28 122,-16 128,-8"), Art.color(0x3A2C24), width: 1.2)

        // The body and the near legs.
        let body: Path = Art.svg("M-92,-120 C-100,-100 -98,-86 -84,-80 C-60,-74 40,-74 70,-80 C88,-84 100,-100 100,-122 C100,-142 86,-152 64,-150 C30,-146 -20,-144 -56,-148 C-76,-150 -90,-138 -92,-120Z")
        let nearFront: Path
        var nearHooves = Path()
        if liftHoof {
            nearFront = Art.svg("M-92,-100 C-98,-80 -104,-60 -116,-40 L-128,-16 L-112,-12 L-102,-36 C-90,-56 -76,-74 -70,-96Z")
            nearHooves.addPath(Art.polygon([Kit.pt(-132, -16), Kit.pt(-110, -12), Kit.pt(-108, -2), Kit.pt(-134, -4)]))
        } else {
            nearFront = Art.svg("M-90,-96 C-92,-70 -86,-50 -86,-30 L-88,-8 L-70,-8 L-72,-30 C-72,-52 -66,-74 -66,-96Z")
            nearHooves.addPath(Art.rect(-90, -10, 22, 10, radius: 2))
        }
        let nearHind: Path = Art.svg("M62,-110 C80,-90 82,-70 76,-52 C74,-40 76,-24 76,-8 L60,-8 C60,-24 58,-40 60,-52 C62,-66 50,-84 42,-100Z")
        nearHooves.addPath(Art.rect(58, -10, 20, 10, radius: 2))
        Kit.solid(&g, body, coat, light: 0.3, shade: 0.3, rim: 2.4)
        Kit.solid(&g, nearFront, coat, light: 0.24, shade: 0.3, rim: 1.6)
        Kit.solid(&g, nearHind, coat, light: 0.24, shade: 0.3, rim: 1.6)
        Art.fill(&g, nearHooves, hoof)
        Art.stroke(&g, Art.svg("M40,-100 C52,-110 66,-112 80,-104 M-70,-90 C-64,-84 -60,-80 -50,-80"), Art.color(horseDark), width: 1.6)

        // The neck, the long mane, the head.
        let neck: Path = Art.svg("M-20,12 C-28,-30 -44,-66 -54,-90 C-50,-102 -36,-108 -26,-102 C-4,-70 18,-34 36,6Z").applying(neckT)
        Kit.solid(&g, neck, coat, light: 0.3, shade: 0.26, rim: 2)
        let head: Path = Art.svg("M8,-6 C-6,-14 -22,-6 -32,8 C-42,22 -54,36 -58,46 C-60,56 -50,62 -40,58 C-30,54 -22,48 -12,40 C0,32 12,24 14,10 C16,2 12,-4 8,-6Z").applying(headT)
        let ears: Path = Art.svg("M4,-4 C2,-14 0,-22 -2,-28 C-6,-20 -8,-12 -6,-4Z").applying(headT)
        let farEar: Path = Art.svg("M10,-4 C9,-14 8,-20 7,-26 C3,-18 2,-12 2,-4Z").applying(headT)
        Art.fill(&g, farEar, farCoat)
        Kit.solid(&g, head, coat, light: 0.32, shade: 0.24, rim: 2)
        Kit.solid(&g, ears, coat, light: 0.3, shade: 0.2)
        let muzzle: Path = Art.ellipse(-46, 48, 13, 10).applying(headT)
        Art.clipped(&g, to: head) { c in
            Art.fill(&c, muzzle, Art.color(0x3E3028, 0.85))
        }
        horseManeLocks(&g, neckT: neckT, headT: headT)
        horseFaceMarks(&g, headT: headT, saddled: saddled)
        if saddled {
            horseSaddle(&g, headT: headT)
        }
        if let warm {
            var whole: Path = body
            whole.addPath(nearFront)
            whole.addPath(nearHind)
            whole.addPath(neck)
            whole.addPath(head)
            Art.clipped(&g, to: whole) { c in
                Art.glow(&c, warm.x, warm.y, 170, Art.color(fireAmber), alpha: warmAlpha)
            }
        }
    }

    /// The very long mane falling from the crest below the neck, and the forelock.
    static func horseManeLocks(_ g: inout GraphicsContext, neckT: CGAffineTransform, headT: CGAffineTransform) {
        let mane: Path = Art.svg("M-30,-106 C-10,-80 20,-40 38,4 C40,30 32,56 20,74 C16,56 8,46 -2,56 C-4,34 -12,26 -20,34 C-20,10 -28,-6 -36,0 C-36,-36 -42,-66 -46,-94Z").applying(neckT)
        Kit.solid(&g, mane, Art.color(horseMane), light: 0.22, shade: 0.2, rim: 1.4)
        let strands: Path = Art.svg("M-34,-90 C-26,-50 -10,-10 6,40 M-24,-96 C-8,-60 10,-20 24,50 M-38,-60 C-30,-30 -18,0 -10,40 M-14,-80 C2,-50 16,-10 30,30").applying(neckT)
        Art.stroke(&g, strands, Art.color(0x3A2C24), width: 1.2)
        let forelock: Path = Art.svg("M4,-8 C-6,-2 -14,6 -22,16 C-12,14 -6,8 2,2Z").applying(headT)
        Art.fill(&g, forelock, Art.color(horseMane))
    }

    /// The calm eye, the nostril, the bridle.
    static func horseFaceMarks(_ g: inout GraphicsContext, headT: CGAffineTransform, saddled: Bool) {
        let eye: CGPoint = CGPoint(x: -16, y: 8).applying(headT)
        Art.fill(&g, Art.circle(eye.x, eye.y, 4.8), Art.color(0x4A3A30))
        ArtStyle.eye(&g, eye.x, eye.y, 3.2, look: CGPoint(x: -0.5, y: 0.2), iris: Art.color(0x0E0806), showsWhite: false)
        Art.stroke(&g, Art.svg("M-22,2 C-18,-1 -13,-1 -10,2").applying(headT), Art.color(0x5A4A40), width: 1.2)
        let nostril: Path = Art.ellipse(-51, 45, 2.8, 1.8).applying(headT)
        Art.fill(&g, nostril, Art.color(0x0E0806))
        Art.stroke(&g, Art.svg("M-50,56 C-46,54 -40,54 -36,56").applying(headT), Art.color(0x0E0806, 0.8), width: 1.2)
        guard saddled else { return }
        let straps: Path = Art.svg("M2,-4 L-36,40 M-50,30 C-42,36 -34,42 -30,48 M8,-6 L-12,-10").applying(headT)
        Art.stroke(&g, straps, Art.color(0x6A4426), width: 2.6)
        let ring: CGPoint = CGPoint(x: -36, y: 42).applying(headT)
        Art.fill(&g, Art.circle(ring.x, ring.y, 2.6), Art.color(0xC9A050))
    }

    /// The plain leather saddle, saddle cloth and girth; the reins to the bit.
    static func horseSaddle(_ g: inout GraphicsContext, headT: CGAffineTransform) {
        let cloth: Path = Art.svg("M-50,-148 L32,-146 L32,-118 C0,-114 -30,-114 -52,-118Z")
        Kit.solid(&g, cloth, Art.color(0x5A1C18), light: 0.2, shade: 0.3)
        Art.stroke(&g, Art.svg("M-50,-122 C-30,-118 0,-118 30,-122"), Art.color(0xC9A050, 0.8), width: 1.6)
        Art.stroke(&g, Art.line(-22, -118, -26, -80), Art.color(0x4A3020), width: 4)
        let seat: Path = Art.svg("M-46,-150 C-44,-164 -34,-162 -24,-154 C-8,-156 10,-158 24,-154 C30,-148 28,-140 22,-138 C0,-142 -26,-142 -44,-138Z")
        Kit.solid(&g, seat, Art.color(0x6A3E22), light: 0.3, shade: 0.24, rim: 1.4)
        let bit: CGPoint = CGPoint(x: -36, y: 42).applying(headT)
        var reins = Path()
        reins.move(to: bit)
        reins.addQuadCurve(to: CGPoint(x: -42, y: -152), control: CGPoint(x: bit.x + 16, y: bit.y + 34))
        Art.stroke(&g, reins, Art.color(0x6A4426), width: 1.8)
    }
}

// MARK: - The Fire-Bird, the feather, the crab

extension FirebirdArt {
    /// The Fire-Bird: a peacock-pheasant shape with a long trailing tail, every feather
    /// glowing gold-orange from within. Feet at the origin, facing LEFT, about 60 tall and
    /// (with the tail) 190 long at scale 1. `glow` 0…1 sets the light it throws.
    static func firebird(_ g: inout GraphicsContext, glow: Double = 1, wingUp: Bool = false) {
        Art.glow(&g, 20, -30, 170, Art.color(fireAmber), alpha: 0.42 * glow)
        Art.glow(&g, 0, -34, 70, Art.color(fireCore), alpha: 0.4 * glow)
        let tips: [(CGFloat, CGFloat, CGFloat)] = [(150, -66, -60), (172, -34, -40), (180, -2, -22), (164, 22, -6), (132, 32, 4)]
        for tip in tips {
            var plume = Path()
            plume.move(to: CGPoint(x: 18, y: -28))
            plume.addQuadCurve(to: CGPoint(x: tip.0, y: tip.1), control: CGPoint(x: 80, y: tip.2))
            Art.stroke(&g, plume, Art.color(fireEmber, 0.55), width: 9)
            Art.stroke(&g, plume, Art.color(fireAmber), width: 4.4)
            Art.stroke(&g, plume, Art.color(fireCore, 0.85), width: 1.4)
            Art.fill(&g, Art.ellipse(tip.0, tip.1, 9, 6), Art.color(fireEmber))
            Art.fill(&g, Art.ellipse(tip.0, tip.1, 5.4, 3.6), Art.color(fireGold))
            Art.fill(&g, Art.ellipse(tip.0 - 0.6, tip.1 - 0.4, 2.2, 1.6), Art.color(fireRed))
        }
        var legs = Path()
        legs.move(to: CGPoint(x: -4, y: -14))
        legs.addLine(to: CGPoint(x: -7, y: 0))
        legs.move(to: CGPoint(x: 6, y: -14))
        legs.addLine(to: CGPoint(x: 6, y: 0))
        Art.stroke(&g, legs, Art.color(0xB0602A), width: 2.2)
        let body: Path = Art.svg("M-24,-34 C-24,-50 -6,-54 10,-48 C26,-42 30,-26 22,-16 C12,-8 -10,-8 -18,-16 C-24,-22 -24,-28 -24,-34Z")
        Kit.solid(&g, body, stops: Kit.stops(fireCore, fireGold, fireEmber), light: 0.3, shade: 0.12)
        let neck: Path = Art.svg("M-20,-40 C-24,-50 -26,-58 -30,-64 L-19,-67 C-16,-56 -12,-48 -8,-42Z")
        Art.fill(&g, neck, Art.color(fireGold))
        let wing: Path
        if wingUp {
            wing = Art.svg("M-4,-40 C0,-70 20,-92 46,-96 C40,-80 34,-62 22,-44 C14,-38 4,-36 -4,-40Z")
        } else {
            wing = Art.svg("M-10,-38 C4,-48 22,-42 32,-28 C20,-22 6,-22 -6,-26Z")
        }
        Kit.solid(&g, wing, stops: Kit.stops(fireGold, fireAmber, fireEmber), light: 0.26, shade: 0.14)
        let quills: Path = wingUp
            ? Art.svg("M2,-44 C10,-64 24,-80 40,-90 M8,-42 C16,-58 26,-70 36,-78 M14,-42 C20,-52 26,-60 30,-66")
            : Art.svg("M-2,-34 C8,-38 18,-36 28,-29 M0,-29 C8,-31 16,-30 24,-26")
        Art.stroke(&g, quills, Art.color(fireRed, 0.7), width: 1.2)
        Art.fill(&g, Art.circle(-27, -69, 8), Art.color(fireGold))
        Art.glow(&g, -29, -72, 6, Art.color(fireCore), alpha: 0.8)
        Art.fill(&g, Art.svg("M-33,-71 L-43,-67 L-33,-64Z"), Art.color(0xD0862A))
        let crest: Path = Art.svg("M-25,-76 C-27,-84 -31,-90 -35,-94 M-23,-77 C-23,-86 -21,-92 -19,-98 M-26,-77 C-28,-86 -27,-94 -27,-100")
        Art.stroke(&g, crest, Art.color(fireGold), width: 1.4)
        var buds = Path()
        buds.addPath(Art.circle(-35, -94, 2.2))
        buds.addPath(Art.circle(-19, -98, 2.2))
        buds.addPath(Art.circle(-27, -100, 2.2))
        Art.fill(&g, buds, Art.color(fireCore))
        ArtStyle.eye(&g, -29, -69, 1.9, look: CGPoint(x: -0.4, y: 0), iris: Art.color(0x3A1206), showsWhite: false)
        var sparks = Path()
        sparks.addPath(Art.spark(-44, -40, 3))
        sparks.addPath(Art.spark(60, -70, 2.4))
        sparks.addPath(Art.spark(110, -12, 2.6))
        Art.fill(&g, sparks, Art.color(fireCore, 0.9))
    }

    /// One fallen feather of the Fire-Bird lying on the ground, centred on (0, 0), about 64
    /// long, glowing like a lamp.
    static func feather(_ g: inout GraphicsContext, glow: Double = 1) {
        Art.glow(&g, 0, -4, 110, Art.color(fireAmber), alpha: 0.5 * glow)
        Art.glow(&g, 0, -2, 34, Art.color(fireCore), alpha: 0.6 * glow)
        let vane: Path = Art.svg("M32,4 C16,-8 -10,-14 -34,-7 C-14,5 10,9 32,4Z")
        Kit.solid(&g, vane, stops: Kit.stops(fireCore, fireGold, fireAmber), light: 0.3, shade: 0.1)
        Art.fill(&g, Art.ellipse(-20, -5, 7, 4.4), Art.color(fireEmber))
        Art.fill(&g, Art.ellipse(-20, -5, 3.6, 2.4), Art.color(fireCore))
        Art.stroke(&g, Art.svg("M34,4 C14,-1 -10,-5 -32,-7"), Art.color(0xFFF6D8), width: 1.2)
        Art.stroke(&g, Art.svg("M18,-1 L24,-6 M8,-3 L13,-9 M-2,-4 L2,-11 M18,1 L22,6 M8,1 L11,7"), Art.color(fireEmber, 0.6), width: 0.9)
    }

    /// A crab of the shore (the great one is drawn at a larger scale): comic and harmless,
    /// claws raised. Origin on the sand under its middle; about 110 wide at scale 1.
    static func crab(_ g: inout GraphicsContext) {
        let shell: UInt32 = 0xA8462A
        Kit.shadow(&g, 0, 0, width: 100)
        var legs = Path()
        let spread: [CGFloat] = [-1, 1]
        for side in spread {
            for index in 0..<3 {
                let k: CGFloat = CGFloat(index)
                let x0: CGFloat = side * (22 + k * 8)
                let x1: CGFloat = side * (40 + k * 10)
                legs.move(to: CGPoint(x: x0, y: -14))
                legs.addQuadCurve(to: CGPoint(x: x1, y: 0), control: CGPoint(x: side * (36 + k * 10), y: -24))
            }
        }
        Art.stroke(&g, legs, Kit.personTone(shell, 0.75), width: 4)
        var arms = Path()
        arms.move(to: CGPoint(x: -26, y: -24))
        arms.addQuadCurve(to: CGPoint(x: -48, y: -56), control: CGPoint(x: -46, y: -30))
        arms.move(to: CGPoint(x: 26, y: -24))
        arms.addQuadCurve(to: CGPoint(x: 48, y: -56), control: CGPoint(x: 46, y: -30))
        Art.stroke(&g, arms, Art.color(shell), width: 6)
        let claws: Path = Art.svg("M-48,-52 C-62,-56 -64,-74 -54,-80 L-50,-68 L-44,-80 C-36,-72 -38,-56 -48,-52Z M48,-52 C62,-56 64,-74 54,-80 L50,-68 L44,-80 C36,-72 38,-56 48,-52Z")
        Kit.solid(&g, claws, Art.color(shell), light: 0.3, shade: 0.24, rim: 1.2)
        let back: Path = Art.svg("M-44,-14 C-44,-34 -20,-42 0,-42 C20,-42 44,-34 44,-14 C30,-6 -30,-6 -44,-14Z")
        Kit.solid(&g, back, stops: Kit.stops(0xC85A34, shell, 0x6A2618), light: 0.3, shade: 0.24, rim: 1.6)
        Art.stroke(&g, Art.line(-8, -40, -10, -52), Art.color(shell), width: 3)
        Art.stroke(&g, Art.line(8, -40, 10, -52), Art.color(shell), width: 3)
        var eyes = Path()
        eyes.addPath(Art.circle(-10, -54, 4))
        eyes.addPath(Art.circle(10, -54, 4))
        Art.fill(&g, eyes, Art.color(0xF2E6D0))
        ArtStyle.eye(&g, -11, -54, 2, look: CGPoint(x: -0.4, y: 0), iris: Art.color(0x1A0E08), showsWhite: false)
        ArtStyle.eye(&g, 9, -54, 2, look: CGPoint(x: -0.4, y: 0), iris: Art.color(0x1A0E08), showsWhite: false)
        ArtStyle.smile(&g, 0, -24, width: 14, curve: 2, color: Art.color(0x5A1A10), lineWidth: 1.6)
    }
}

// MARK: - The story's things: cage, stove, posts, towers, cauldron, tent, torch

extension FirebirdArt {
    /// The golden cage with the Fire-Bird in it; origin under the middle of its base,
    /// about 80 wide and 115 tall.
    static func cage(_ g: inout GraphicsContext) {
        let gold: UInt32 = 0xD9A23A
        Art.glow(&g, 0, -52, 140, Art.color(fireAmber), alpha: 0.5)
        Art.group(&g, x: -8, y: -12, scale: 0.38) { b in
            firebird(&b, glow: 0.7)
        }
        var bars = Path()
        for index in -3...3 {
            let x: CGFloat = CGFloat(index) * 11
            bars.move(to: CGPoint(x: x, y: -10))
            bars.addQuadCurve(to: CGPoint(x: 0, y: -104), control: CGPoint(x: x * 1.12, y: -92))
        }
        Art.stroke(&g, bars, Art.color(0x8A5A16), width: 2.6)
        Art.stroke(&g, bars, Art.color(0xF2C860), width: 1.2)
        Art.stroke(&g, Art.svg("M-36,-58 C-20,-54 20,-54 36,-58"), Art.color(gold), width: 2.4)
        Art.stroke(&g, Art.circle(0, -111, 6), Art.color(gold), width: 2)
        Kit.solid(&g, Art.rect(-42, -12, 84, 12, radius: 4), Art.color(gold), light: 0.32, shade: 0.3, rim: 1.2)
    }

    /// The great stove faced with green glazed tiles; origin under its middle, 132 wide,
    /// 222 tall.
    static func stove(_ g: inout GraphicsContext) {
        Kit.shadow(&g, 0, 0, width: 140)
        let body: Path = Art.rect(-58, -192, 116, 168, radius: 3)
        Art.fill(&g, body, Art.color(0x1E4A36))
        var tiles = Path()
        var shines = Path()
        var dots = Path()
        for row in 0..<8 {
            for col in 0..<6 {
                let x: CGFloat = -58 + CGFloat(col) * 19.33
                let y: CGFloat = -192 + CGFloat(row) * 21
                tiles.addPath(Art.rect(x + 1.4, y + 1.4, 16.5, 18.2, radius: 2.4))
                shines.addPath(Art.ellipse(x + 6, y + 6, 3.4, 2.2))
                dots.addPath(Art.circle(x + 9.7, y + 10.5, 2))
            }
        }
        Art.fill(&g, tiles, Art.color(0x2E7050))
        Art.fill(&g, dots, Art.color(0xC9A050, 0.75))
        Art.fill(&g, shines, Color.white.opacity(0.16))
        Kit.model(&g, body, light: 0.22, shade: 0.4, rim: 1.4)
        Kit.solid(&g, Art.rect(-66, -24, 132, 24, radius: 3), Art.color(0x245A40), light: 0.2, shade: 0.3)
        Kit.solid(&g, Art.rect(-64, -200, 128, 10, radius: 3), Art.color(0x2E7050), light: 0.3, shade: 0.24, rim: 1.2)
        Kit.solid(&g, Art.rect(-50, -222, 100, 22, radius: 4), Art.color(0x245A40), light: 0.26, shade: 0.3)
    }

    /// A carved pine post of the hall; origin under its middle, about 24 wide.
    static func carvedPost(_ g: inout GraphicsContext, height h: CGFloat) {
        let wood: UInt32 = logLit
        let shaft: Path = Art.rect(-10, -h, 20, h, radius: 3)
        Kit.solid(&g, shaft, stops: Kit.stops(0x7A4626, logMid), light: 0.26, shade: 0.34, rim: 1.4)
        var knobs = Path()
        let marks: [CGFloat] = [0.18, 0.5, 0.82]
        for m in marks {
            knobs.addPath(Art.ellipse(0, -h * m, 14, 9))
        }
        Kit.solid(&g, knobs, Art.color(wood), light: 0.3, shade: 0.3, rim: 1.2)
        var cuts = Path()
        for m in marks {
            let y: CGFloat = -h * m
            cuts.move(to: CGPoint(x: -12, y: y))
            cuts.addLine(to: CGPoint(x: 12, y: y))
        }
        Art.stroke(&g, cuts, Art.color(logDark, 0.8), width: 1.2)
        let bracket: Path = Art.svg("M-34,0 C-20,0 -12,6 -10,18 L10,18 C12,6 20,0 34,0 L34,-8 L-34,-8Z").applying(CGAffineTransform(translationX: 0, y: -h))
        Kit.solid(&g, bracket, Art.color(0x5A3018), light: 0.24, shade: 0.3, rim: 1.2)
    }

    /// A wooden tower of the palace: a log body, a tall tent roof of shingles and a small
    /// onion dome; origin under its middle. `lit` puts candlelight in its window.
    static func woodTower(_ g: inout GraphicsContext, width w: CGFloat, height h: CGFloat, roof: UInt32, lit: Bool) {
        let half: CGFloat = w / 2
        let wallH: CGFloat = h * 0.42
        let rect = CGRect(x: -half, y: -wallH, width: w, height: wallH)
        Kit.wall(&g, rect: rect, color: logMid)
        Kit.builtLogs(&g, rect: rect, color: logLit)
        let winW: CGFloat = w * 0.26
        Kit.opening(&g, rect: CGRect(x: -winW / 2, y: -wallH * 0.7, width: winW, height: wallH * 0.32), arched: true, color: 0x1A0F0A, glow: lit ? 0.8 : 0)
        let tentH: CGFloat = h * 0.42
        let eave: CGFloat = -wallH
        var tent = Path()
        tent.move(to: CGPoint(x: -half - w * 0.14, y: eave))
        tent.addLine(to: CGPoint(x: -w * 0.08, y: eave - tentH))
        tent.addLine(to: CGPoint(x: w * 0.08, y: eave - tentH))
        tent.addLine(to: CGPoint(x: half + w * 0.14, y: eave))
        tent.closeSubpath()
        Kit.solid(&g, tent, Art.color(roof), light: 0.22, shade: 0.34, rim: 1.4)
        var shingles = Path()
        for index in 1..<6 {
            let t: CGFloat = CGFloat(index) / 6
            let y: CGFloat = eave - tentH * t
            let reach: CGFloat = (half + w * 0.14) * (1 - t) + w * 0.08 * t
            shingles.move(to: CGPoint(x: -reach, y: y))
            shingles.addLine(to: CGPoint(x: reach, y: y))
        }
        Art.stroke(&g, shingles, Kit.personTone(roof, 0.7), width: 1)
        let domeBase: CGFloat = eave - tentH
        Kit.dome(&g, cx: 0, baseY: domeBase, width: w * 0.3, height: h * 0.16, color: Kit.builtHex(roof, 1.25), onion: true)
    }

    /// The great iron cauldron on its ring of stones over a log fire, a ladder against it;
    /// origin under its middle, about 190 wide and 160 tall. `steam` 0…1.
    static func cauldron(_ g: inout GraphicsContext, steam: Double) {
        Art.glow(&g, 0, -30, 190, Art.color(0xFF8A3A), alpha: 0.5)
        var stones = Path()
        let xs: [CGFloat] = [-84, -58, -30, 0, 30, 58, 84]
        for x in xs {
            stones.addPath(Art.ellipse(x, -10, 15, 11))
        }
        Kit.solid(&g, stones, Art.color(0x4A4040), light: 0.3, shade: 0.3, rim: 1.2)
        Art.stroke(&g, Art.line(-60, -14, 50, -30), Art.color(0x4A2A18), width: 9)
        Art.stroke(&g, Art.line(-50, -30, 60, -14), Art.color(0x5A3420), width: 9)
        let flames: [(CGFloat, CGFloat, CGFloat)] = [(-44, 22, -3), (-16, 30, 2), (14, 34, -2), (42, 24, 3)]
        for f in flames {
            Art.fill(&g, Kit.propFlame(f.0, -14, f.1, f.1 * 1.6, f.2), Art.color(fireEmber))
            Art.fill(&g, Kit.propFlame(f.0, -14, f.1 * 0.6, f.1 * 1.1, f.2), Art.color(fireGold))
        }
        let pot: Path = Art.svg("M-86,-150 C-92,-110 -80,-62 -40,-46 C-14,-38 14,-38 40,-46 C80,-62 92,-110 86,-150Z")
        Kit.solid(&g, pot, stops: Kit.stops(0x4A4446, 0x2E2A2C, 0x1A1618), light: 0.22, shade: 0.3, rim: 2)
        Art.clipped(&g, to: pot) { c in
            Art.glow(&c, 0, -40, 90, Art.color(0xFF8A3A), alpha: 0.5)
        }
        Kit.solid(&g, Art.rect(-96, -160, 192, 14, radius: 7), Art.color(0x3A3436), light: 0.3, shade: 0.24, rim: 1.4)
        Art.fill(&g, Art.ellipse(0, -156, 84, 4), Art.color(0x1A2228))
        Art.stroke(&g, Art.circle(-96, -128, 10), Art.color(0x2A2628), width: 4)
        Art.stroke(&g, Art.circle(96, -128, 10), Art.color(0x2A2628), width: 4)
        var rails = Path()
        rails.move(to: CGPoint(x: 112, y: 0))
        rails.addLine(to: CGPoint(x: 82, y: -172))
        rails.move(to: CGPoint(x: 130, y: 0))
        rails.addLine(to: CGPoint(x: 100, y: -172))
        for index in 1..<8 {
            let t: CGFloat = CGFloat(index) / 8
            let y: CGFloat = -172 * t
            rails.move(to: CGPoint(x: 112 - 30 * t, y: y))
            rails.addLine(to: CGPoint(x: 130 - 30 * t, y: y))
        }
        Art.stroke(&g, rails, Art.color(0x6A4426), width: 3.4)
        guard steam > 0 else { return }
        Art.blurred(&g, radius: 12, opacity: steam) { s in
            let puffs: [(CGFloat, CGFloat, CGFloat)] = [(0, -180, 60), (-10, -230, 70), (8, -290, 80), (-6, -350, 90)]
            for puff in puffs {
                Art.fill(&s, Art.ellipse(puff.0, puff.1, puff.2, puff.2 * 0.55), Color.white.opacity(0.22))
            }
        }
    }

    /// The round golden-roofed tent on the sand; origin under its middle, 160 wide, 170 tall.
    static func tent(_ g: inout GraphicsContext) {
        Kit.shadow(&g, 0, 0, width: 170)
        let walls: Path = Art.svg("M-70,0 L-66,-80 L66,-80 L70,0Z")
        Kit.solid(&g, walls, stops: Kit.stops(0xE6E2D6, 0xB8B4AC), light: 0.2, shade: 0.34)
        Art.stroke(&g, Art.svg("M-44,0 L-42,-80 M-18,0 L-17,-80 M18,0 L17,-80 M44,0 L42,-80"), Art.color(0x8A8680, 0.6), width: 1.2)
        Art.fill(&g, Art.svg("M-14,0 L-9,-58 L9,-58 L14,0Z"), Art.color(0xFFC96B))
        Art.glow(&g, 0, -20, 50, Art.color(0xFFC96B), alpha: 0.45)
        let roof: Path = Art.svg("M-80,-76 C-50,-98 -20,-128 0,-150 C20,-128 50,-98 80,-76 C40,-70 -40,-70 -80,-76Z")
        Kit.solid(&g, roof, stops: Kit.stops(0xF2C860, 0xD9A23A, 0x8A5A16), light: 0.3, shade: 0.28, rim: 1.6)
        let valance: Path = Kit.personScallop(cx: 0, cy: -150, rx: 80, ry: 76, from: 64, to: 116, count: 9, r: 6)
        Art.fill(&g, valance, Art.color(0xB07A20))
        Art.stroke(&g, Art.line(0, -150, 0, -166), Art.color(0xD9A23A), width: 2.4)
        Art.fill(&g, Art.circle(0, -168, 4.4), Art.color(0xF2C860))
    }

    /// A torch on a pole; origin at the foot of the pole.
    static func torch(_ g: inout GraphicsContext, height h: CGFloat) {
        Art.glow(&g, 0, -h - 12, 110, Art.color(0xFF9A3C), alpha: 0.4)
        Art.stroke(&g, Art.line(0, 0, 0, -h), Art.color(0x3A2416), width: 4)
        Art.fill(&g, Art.rect(-5, -h - 4, 10, 10, radius: 2), Art.color(0x2A1A10))
        Art.fill(&g, Kit.propFlame(0, -h - 3, 14, 30, -3), Art.color(fireEmber))
        Art.fill(&g, Kit.propFlame(0, -h - 3, 8, 18, -2), Art.color(fireGold))
    }
}
