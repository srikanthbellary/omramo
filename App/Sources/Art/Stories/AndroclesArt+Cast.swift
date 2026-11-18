import SwiftUI
import OmramoCore

// The cast and the shared parts of "Androcles and the Lion": the palette and the lights of
// Roman North Africa and Rome, Androcles in his rough tunic, the Barbary lion with his heavy
// dark mane, the Emperor, and the small things several pictures use (the thorn, thorn scrub,
// the cave wall, petals, the far crowd, a round loaf).

extension AndroclesArt {
    // MARK: Palette

    static let ramp = ArtStyle.Ramp(deep: 0x2A2033, shade: 0x8A4F2C, mid: 0xD9A45F, light: 0xFBEBCB, glow: 0xFFD98A, accent: 0xC8472E)
    static let rockHex: UInt32 = 0xD9A45F
    static let rockPaleHex: UInt32 = 0xEBC88E
    static let sandHex: UInt32 = 0xF2E0B6
    static let woolHex: UInt32 = 0xE3D3AC
    static let cleanHex: UInt32 = 0xF6EEDA
    static let skinHex: UInt32 = 0xB67A50
    static let tawnyHex: UInt32 = 0xD9A248
    static let bellyHex: UInt32 = 0xF0D9A6
    static let maneHex: UInt32 = 0x33231F
    static let purpleHex: UInt32 = 0x6B2A7A
    static let tileHex: UInt32 = 0xC0683C
    static let stuccoHex: UInt32 = 0xE4B870
    static let creamHex: UInt32 = 0xF3E4C2
    static let redWallHex: UInt32 = 0xB5553C

    // MARK: Lights

    /// The hills of North Africa at noon: pale blue warming to gold at the horizon.
    static func day() -> Kit.Light {
        let sky: Kit.Stops = [(Art.color(0xCFE6F2), 0), (Art.color(0xE4EEE2), 0.55), (Art.color(0xFBE7BE), 1)]
        return Kit.Light(sky: sky, sun: 0xFFF3CF, glow: 0xFFD98A, haze: 0xF6E8C8, far: 0xE6CFA6, mid: 0xDDB680, near: 0xCF9C5E)
    }

    /// The cave in full sun: a pale gold sky.
    static func goldDay() -> Kit.Light {
        let sky: Kit.Stops = [(Art.color(0xE9ECDD), 0), (Art.color(0xF3E6C8), 0.5), (Art.color(0xFBE2B0), 1)]
        return Kit.Light(sky: sky, sun: 0xFFF3CF, glow: 0xFFD98A, haze: 0xF7E6C2, far: 0xE9CD9C, mid: 0xE0B77C, near: 0xCB9658)
    }

    /// Rome in the morning: a pale bright sky over stone and stucco.
    static func morning() -> Kit.Light {
        let sky: Kit.Stops = [(Art.color(0xD6E8F4), 0), (Art.color(0xE9EEE6), 0.6), (Art.color(0xFCEBCB), 1)]
        return Kit.Light(sky: sky, sun: 0xFFF5D6, glow: 0xFFD98A, haze: 0xF8ECD2, far: 0xE8D4B6, mid: 0xDDC09A, near: 0xC9A47C)
    }

    static func ochreGround() -> Kit.Stops {
        [(Art.color(0xE9C58A), 0), (Art.color(rockHex), 0.5), (Art.color(0xBE8647), 1)]
    }

    static func sandGround() -> Kit.Stops {
        [(Art.color(0xF8ECCC), 0), (Art.color(sandHex), 0.5), (Art.color(0xE3C692), 1)]
    }

    static func pavingGround() -> Kit.Stops {
        [(Art.color(0xEAD9B8), 0), (Art.color(0xD9C29C), 0.5), (Art.color(0xC2A67E), 1)]
    }

    /// The dusty grey-greens of thorn scrub.
    static func scrubGreens() -> Kit.Greens {
        Kit.greens(0x4A5236, 0x6B7446, 0x8E9660, 0xB3B880, 0xD9D8A6)
    }

    // MARK: Androcles

    /// Androcles: a wiry man of Roman North Africa in a short undyed wool tunic, bare-armed
    /// and bare-legged; a clean pale tunic in Rome.
    static func androclesLook(clean: Bool = false) -> Kit.Person {
        let cloth: UInt32 = clean ? cleanHex : woolHex
        let cord: UInt32 = clean ? 0xA9743F : 0x8A6A44
        return Kit.Person(skin: skinHex, hair: 0x2B1D19, hairStyle: .curly, beard: .short, garment: .chiton, cloth: cloth, trim: cord, legs: skinHex, showsEyeWhite: false)
    }

    /// The whole man, feet at the origin, facing LEFT (as `Kit.person`). In Part I (`clean`
    /// false) he carries his goatskin water bag on a strap and his hem is ragged.
    static func androcles(
        _ context: inout GraphicsContext,
        pose: Kit.Pose = .stand,
        look: CGPoint = .zero,
        mouth: Kit.Mouth = .smile,
        clean: Bool = false,
        bag: Bool = true,
        mirrored: Bool = false
    ) {
        let p = androclesLook(clean: clean)
        Kit.person(&context, p, pose: pose, look: look, mouth: mouth, mirrored: mirrored)
        if clean { return }
        switch pose {
        case .stand, .walk, .reach, .carry, .wave:
            if bag {
                waterSkin(&context, shoulder: CGPoint(x: -15, y: -110), hip: CGPoint(x: 15, y: -60))
            }
            let threads = Art.svg("M-13,-29 l-1,6 M-4,-27 l1,7 M7,-28 l-1,5 M14,-30 l1,6")
            Art.stroke(&context, threads, Kit.personTone(woolHex, 0.8), width: 1.3)
        case .kneel:
            if bag {
                waterSkin(&context, shoulder: CGPoint(x: -22, y: -84), hip: CGPoint(x: 12, y: -42))
            }
        case .sit, .bow, .sleep:
            break
        }
    }

    /// The goatskin water bag on its strap, from a shoulder to the far hip.
    static func waterSkin(_ context: inout GraphicsContext, shoulder: CGPoint, hip: CGPoint) {
        Art.stroke(&context, Art.line(shoulder.x, shoulder.y, hip.x, hip.y), Art.color(0x6B4A30), width: 2.6)
        let bx: CGFloat = hip.x + 2
        let by: CGFloat = hip.y + 4
        let bag = Kit.placed("M-9,-8 C-12,2 -10,14 0,17 C10,14 12,2 8,-8 C5,-12 -5,-12 -9,-8Z", x: bx, y: by)
        Kit.solid(&context, bag, Art.color(0x9A6B44), light: 0.26, shade: 0.24)
        Art.fill(&context, Kit.placed("M-4,-10 L-3,-16 L3,-16 L4,-10Z", x: bx, y: by), Art.color(0x7A5234))
        Art.stroke(&context, Kit.placed("M-5,-9 L5,-9", x: bx, y: by), Art.color(0x4E3524), width: 1.6)
    }

    /// One long pale thorn: its thick end at (x, y), pointing along `angle` (radians).
    static func thorn(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, length: CGFloat, angle: CGFloat) {
        Art.group(&context, x: x, y: y, rotate: angle) { g in
            let w: CGFloat = max(1.2, length * 0.09)
            let shape = Art.polygon([CGPoint(x: 0, y: -w), CGPoint(x: length, y: 0), CGPoint(x: 0, y: w)])
            Art.fill(&g, shape, Art.color(0xF4EACB))
            Art.stroke(&g, Art.line(0, w, length, 0), Art.color(0xA98A5A), width: 0.8)
        }
    }

    // MARK: The Emperor

    /// The Emperor: clean-shaven, short dark hair, a white toga with a broad purple border.
    /// No likeness of any real emperor.
    static func emperorLook() -> Kit.Person {
        Kit.Person(skin: 0xD9A47C, hair: 0x3A2A22, hairStyle: .short, garment: .robe, cloth: 0xF5F0E4, trim: purpleHex, legs: 0xD9A47C, showsEyeWhite: false)
    }

    /// The thin gold wreath, in head units (drawn over `Kit.personHead` at the same place).
    static func wreath(_ context: inout GraphicsContext) {
        let band = Art.svg("M-25,-12 C-13,-19 13,-19 25,-12")
        Art.stroke(&context, band, Art.color(0xB98A2E), width: 2)
        var leaves = Path()
        for i in 0..<8 {
            let t: CGFloat = (CGFloat(i) + 0.5) / 8
            let d: CGFloat = 2 * t - 1
            let arch: CGFloat = 1 - d * d
            let x: CGFloat = -24 + 48 * t
            let y: CGFloat = -14 - 5.5 * arch
            let tilt: CGFloat = t < 0.5 ? -0.6 : 0.6
            let move = CGAffineTransform(translationX: x, y: y).rotated(by: tilt)
            leaves.addPath(Art.ellipse(0, 0, 4.2, 1.9).applying(move))
        }
        Art.fill(&context, leaves, Art.color(0xE3BC52))
        Art.stroke(&context, Art.svg("M-22,-16 C-14,-21 -6,-22 0,-22"), Art.color(0xFFF0B8, 0.7), width: 1)
    }

    /// The whole Emperor, feet at the origin, facing LEFT, one finger lifted.
    static func emperor(_ context: inout GraphicsContext, pose: Kit.Pose = .reach) {
        let p = emperorLook()
        Kit.person(&context, p, pose: pose, mouth: .smile)
        // The fold of the toga across the chest, with its purple border.
        Art.stroke(&context, Art.svg("M-16,-110 C-4,-94 8,-80 17,-62"), Art.color(purpleHex), width: 4)
        if pose == .reach || pose == .stand {
            Art.group(&context, x: 0, y: -140) { g in
                wreath(&g)
            }
        }
    }

    // MARK: The Lion

    /// The body of the Barbary lion (the mane is added by `lion`): big, tawny, brown paws.
    static func lionBodyLook(thin: Bool = false) -> Kit.Beast {
        var look = Kit.lionLook()
        look.body = tawnyHex
        look.belly = bellyHex
        look.dark = 0x5E3E26
        look.mane = false
        look.bodyLength = 2.15
        look.bulk = thin ? 0.82 : 1.0
        look.showsEyeWhite = false
        return look
    }

    /// The head of the Barbary lion with his near-black ruff (also the front views).
    static func lionHeadLook() -> Kit.Beast {
        var look = Kit.lionLook()
        look.body = tawnyHex
        look.belly = bellyHex
        look.dark = maneHex
        look.showsEyeWhite = false
        return look
    }

    /// The mane that runs down the chest, hung under the head centre `hc`.
    static func lionChestMane(_ context: inout GraphicsContext, _ hc: CGPoint, long: Bool = false) {
        var mass = Path()
        var blobs: [(CGFloat, CGFloat, CGFloat)] = [(12, 30, 27), (20, 52, 20), (4, 46, 16), (26, 34, 20)]
        if long {
            blobs.append((16, 70, 15))
        }
        for blob in blobs {
            let r: CGFloat = blob.2
            mass.addEllipse(in: CGRect(x: hc.x + blob.0 - r, y: hc.y + blob.1 - r, width: r * 2, height: r * 2))
        }
        Art.fill(&context, mass, Art.color(maneHex))
        let move = CGAffineTransform(translationX: hc.x, y: hc.y)
        let strands = Art.svg("M-6,36 q-4,10 0,20 M8,44 q-2,10 2,18 M22,40 q0,12 4,20").applying(move)
        Art.stroke(&context, strands, Kit.beastTone(maneHex, 1.8), width: 1.4)
    }

    /// Rose petals caught in the mane, in head units.
    static func manePetals(_ context: inout GraphicsContext) {
        let places: [(CGFloat, CGFloat, CGFloat)] = [(-8, -30, 0.4), (22, -30, -0.5), (40, -6, 1.1), (32, 26, 0.2), (-12, 32, -0.8), (6, -38, 0.9), (42, 14, -0.3)]
        var pink = Path()
        var red = Path()
        var index: Int = 0
        for place in places {
            let move = CGAffineTransform(translationX: place.0, y: place.1).rotated(by: place.2)
            let leaf = Art.ellipse(0, 0, 4.4, 2.6).applying(move)
            if index % 3 == 0 {
                red.addPath(leaf)
            } else {
                pink.addPath(leaf)
            }
            index += 1
        }
        Art.fill(&context, pink, Art.color(0xF6B4C2))
        Art.fill(&context, red, Art.color(0xDB5A6E))
    }

    /// The Lion on his feet (stand, walk, run), facing LEFT, origin on the ground under the
    /// middle of his body: the kit's beast with the Barbary mane down his chest and along his
    /// belly. `thin` is the hungry lion of the arena; `petals` the lion of the last street.
    static func lion(
        _ context: inout GraphicsContext,
        pose: Kit.BeastPose = .stand,
        mood: Kit.BeastMood = .calm,
        look: CGPoint = .zero,
        thin: Bool = false,
        petals: Bool = false,
        mirrored: Bool = false
    ) {
        let body = lionBodyLook(thin: thin)
        Kit.beast(&context, body, pose: pose, mood: mood, look: look, mirrored: mirrored)
        let hc: CGPoint = Kit.beastHeadCentre(body, pose: pose)
        if pose == .stand || pose == .walk {
            let legs: CGFloat = body.legLength * 60
            var fringe = Path()
            for i in 0..<7 {
                let x: CGFloat = -20 + CGFloat(i) * 9
                let r: CGFloat = i % 2 == 0 ? 6.5 : 5
                fringe.addEllipse(in: CGRect(x: x - r, y: -legs - r * 0.5, width: r * 2, height: r * 1.7))
            }
            Art.fill(&context, fringe, Art.color(maneHex))
        }
        lionChestMane(&context, hc)
        let head = lionHeadLook()
        Art.group(&context, x: hc.x, y: hc.y) { g in
            Kit.beastHead(&g, head, mood: mood, look: look, mirrored: mirrored)
            if petals {
                manePetals(&g)
            }
        }
    }
}

// MARK: - The sitting Lion (the story's own pose: one paw held out)

extension AndroclesArt {
    /// The raised paw's centre and the tip of the thorn in it, in the sitting lion's units.
    static let lionPawX: CGFloat = -90
    static let lionPawY: CGFloat = -52
    static let thornTipX: CGFloat = -108
    static let thornTipY: CGFloat = -26

    /// One foreleg as a modelled limb through `bend`.
    static func lionForeleg(_ context: inout GraphicsContext, from: CGPoint, bend: CGPoint, to: CGPoint, far: Bool) {
        var line = Path()
        line.move(to: from)
        line.addQuadCurve(to: to, control: bend)
        let shape: Path = line.strokedPath(StrokeStyle(lineWidth: 17, lineCap: .round, lineJoin: .round))
        let tone: Color = far ? Kit.beastTone(tawnyHex, 0.8) : Art.color(tawnyHex)
        let lit: Double = far ? 0.06 : 0.18
        Kit.solid(&context, shape, tone, light: lit, shade: 0.2)
    }

    /// A planted paw centred on (x, y).
    static func lionPaw(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, r: CGFloat, far: Bool) {
        let shape = Art.ellipse(x, y, r * 1.15, r * 0.62)
        let k: CGFloat = far ? 0.8 : 1.04
        Kit.solid(&context, shape, Kit.beastTone(tawnyHex, k), light: 0.16, shade: 0.18)
        let toes = Kit.placed("M-6,-2 q-2,3 -1,6 M0,-3 q-2,4 -1,7", x: x - r * 0.3, y: y)
        Art.stroke(&context, toes, Art.color(0x5E3E26, 0.55), width: 1.2)
    }

    /// The paw held out: swollen with the long thorn in its pad, or bound in a strip of the
    /// same undyed cloth as the tunic. No blood.
    static func lionRaisedPaw(_ context: inout GraphicsContext, bandaged: Bool) {
        let x: CGFloat = lionPawX
        let y: CGFloat = lionPawY
        let r: CGFloat = bandaged ? 13 : 15
        var shape = Art.circle(x, y, r)
        shape.addEllipse(in: CGRect(x: x - r * 1.3, y: y - r * 0.25, width: r * 1.1, height: r * 1.1))
        Kit.solid(&context, shape, Kit.beastTone(tawnyHex, 1.05), light: 0.24, shade: 0.2)
        let toes = Kit.placed("M-13,1 q-3,4 -1,9 M-7,5 q-2,4 0,8", x: x, y: y)
        Art.stroke(&context, toes, Art.color(0x5E3E26, 0.55), width: 1.3)
        if bandaged {
            let band = Art.line(x - 3, y - r + 1, x + 2, y + r - 1)
            Art.stroke(&context, band, Art.color(woolHex), width: 12, cap: .butt)
            let edges = Art.svg("M-9,-11 L-4,12 M3,-12 L8,11 M-5,-2 L5,-4").applying(CGAffineTransform(translationX: x, y: y))
            Art.stroke(&context, edges, Kit.personTone(woolHex, 0.74), width: 1.1)
            let tails = Art.svg("M5,-10 q8,-6 12,-1 M5,-10 q9,0 10,7").applying(CGAffineTransform(translationX: x, y: y))
            Art.stroke(&context, tails, Art.color(woolHex), width: 3)
        } else {
            ArtStyle.cheek(&context, x - 3, y + 4, 10, alpha: 0.32)
            thorn(&context, x: x - 6, y: y + 8, length: 22, angle: Kit.deg(124))
        }
    }

    /// The Lion sitting, facing LEFT, origin on the ground under his haunch; about 172 tall.
    /// `paw`: 0 both forepaws planted, 1 one paw held out with the thorn in it, 2 held out and
    /// bandaged. `nod` (degrees, negative) bends his head down to watch.
    static func lionSitting(
        _ context: inout GraphicsContext,
        mood: Kit.BeastMood = .calm,
        look: CGPoint = .zero,
        paw: Int = 0,
        nod: CGFloat = 0
    ) {
        let coat = Art.color(tawnyHex)
        Art.stroke(&context, Art.svg("M56,-12 C84,-2 104,-6 112,-22"), Kit.beastTone(tawnyHex, 0.9), width: 6)
        Art.fill(&context, Art.svg("M112,-18 C120,-24 122,-38 114,-44 C106,-38 106,-24 112,-18Z"), Art.color(maneHex))
        lionForeleg(&context, from: CGPoint(x: -28, y: -78), bend: CGPoint(x: -32, y: -40), to: CGPoint(x: -33, y: -12), far: true)
        lionPaw(&context, x: -37, y: -6, r: 11, far: true)
        let torso = Art.svg("M-30,-100 C-20,-116 6,-116 20,-100 C40,-78 62,-52 66,-24 C68,-10 60,0 46,0 L4,0 C-10,-4 -22,-24 -30,-48 C-36,-66 -36,-86 -30,-100Z")
        Kit.solid(&context, torso, coat, light: 0.24, shade: 0.24)
        Art.clipped(&context, to: torso) { g in
            Art.fill(&g, Art.ellipse(-16, -34, 16, 34), Art.color(bellyHex))
        }
        let haunch = Art.svg("M12,-6 C8,-30 26,-50 46,-48 C64,-46 72,-26 68,-10 C66,-2 58,0 48,0 L18,0 C14,0 12,-2 12,-6Z")
        Kit.solid(&context, haunch, coat, light: 0.2, shade: 0.2)
        Art.stroke(&context, Art.svg("M16,-10 C14,-28 28,-44 44,-44"), Kit.beastTone(tawnyHex, 0.78).opacity(0.6), width: 1.6)
        lionPaw(&context, x: 8, y: -5, r: 12, far: false)
        if paw == 0 {
            lionForeleg(&context, from: CGPoint(x: -16, y: -80), bend: CGPoint(x: -18, y: -40), to: CGPoint(x: -19, y: -12), far: false)
            lionPaw(&context, x: -23, y: -6, r: 12, far: false)
        } else {
            lionForeleg(&context, from: CGPoint(x: -18, y: -82), bend: CGPoint(x: -50, y: -54), to: CGPoint(x: -80, y: -54), far: false)
            lionRaisedPaw(&context, bandaged: paw == 2)
        }
        let hc = CGPoint(x: -40, y: -128)
        lionChestMane(&context, hc, long: true)
        let head = lionHeadLook()
        Art.group(&context, x: hc.x, y: hc.y, rotate: Kit.deg(nod)) { g in
            Kit.beastHead(&g, head, mood: mood, look: look)
        }
    }
}

// MARK: - Shared parts of the land and the city

extension AndroclesArt {
    /// Dry thorn scrub: bare thorny twigs with a low dusty crown, `width` wide, on baseY.
    static func thornBush(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, width: CGFloat, seed: UInt32 = 1) {
        var random = ArtRandom(seed)
        var twigs = Path()
        for i in 0..<7 {
            let t: CGFloat = CGFloat(i) / 6 - 0.5
            let reach: CGFloat = width * (0.44 + Kit.rnd(&random) * 0.2)
            let droop: CGFloat = 1 - abs(t) * 0.6
            let tipX: CGFloat = x + t * width * 1.1
            let tipY: CGFloat = baseY - reach * droop
            let footX: CGFloat = x + t * width * 0.2
            twigs.move(to: CGPoint(x: footX, y: baseY))
            twigs.addQuadCurve(to: CGPoint(x: tipX, y: tipY), control: CGPoint(x: x + t * width * 0.4, y: baseY - reach * 0.7))
            let spurX: CGFloat = (footX + tipX) / 2
            let spurY: CGFloat = baseY - reach * droop * 0.62
            twigs.move(to: CGPoint(x: spurX, y: spurY))
            twigs.addLine(to: CGPoint(x: spurX + width * 0.05, y: spurY - width * 0.07))
        }
        Art.stroke(&context, twigs, Art.color(0x7A5A40), width: max(1.2, width * 0.025))
        Kit.bush(&context, x: x, baseY: baseY, width: width * 0.9, palette: scrubGreens(), seed: seed)
    }

    /// The wall of warm rock with the soft dark mouth of the cave, in the unfolded scene's
    /// design units (it fills the trailing side from about x 500 to the edge).
    static func caveRock(_ context: inout GraphicsContext, _ Hv: CGFloat) {
        var wall = Path()
        wall.move(to: CGPoint(x: 496, y: Hv + 66))
        wall.addCurve(to: CGPoint(x: 592, y: Hv - 120), control1: CGPoint(x: 536, y: Hv + 10), control2: CGPoint(x: 562, y: Hv - 60))
        wall.addCurve(to: CGPoint(x: 696, y: Hv - 262), control1: CGPoint(x: 616, y: Hv - 170), control2: CGPoint(x: 640, y: Hv - 236))
        wall.addCurve(to: CGPoint(x: 900, y: Hv - 296), control1: CGPoint(x: 756, y: Hv - 288), control2: CGPoint(x: 836, y: Hv - 300))
        wall.addLine(to: CGPoint(x: 900, y: Hv + 70))
        wall.closeSubpath()
        let stops: Kit.Stops = [(Art.color(rockPaleHex), 0), (Art.color(rockHex), 0.55), (Art.color(0xB9773F), 1)]
        Kit.solid(&context, wall, stops: stops, light: 0.3, shade: 0.2, rim: 2.4)
        var strata = Path()
        strata.move(to: CGPoint(x: 560, y: Hv - 40))
        strata.addQuadCurve(to: CGPoint(x: 760, y: Hv - 150), control: CGPoint(x: 650, y: Hv - 120))
        strata.move(to: CGPoint(x: 640, y: Hv - 190))
        strata.addQuadCurve(to: CGPoint(x: 900, y: Hv - 236), control: CGPoint(x: 760, y: Hv - 240))
        strata.move(to: CGPoint(x: 530, y: Hv + 24))
        strata.addQuadCurve(to: CGPoint(x: 700, y: Hv - 30), control: CGPoint(x: 610, y: Hv - 14))
        strata.move(to: CGPoint(x: 612, y: Hv - 100))
        strata.addLine(to: CGPoint(x: 626, y: Hv - 62))
        strata.move(to: CGPoint(x: 720, y: Hv - 224))
        strata.addLine(to: CGPoint(x: 712, y: Hv - 176))
        var mouth = Path()
        mouth.move(to: CGPoint(x: 752, y: Hv + 66))
        mouth.addCurve(to: CGPoint(x: 828, y: Hv - 110), control1: CGPoint(x: 744, y: Hv - 22), control2: CGPoint(x: 776, y: Hv - 106))
        mouth.addCurve(to: CGPoint(x: 900, y: Hv - 44), control1: CGPoint(x: 872, y: Hv - 112), control2: CGPoint(x: 896, y: Hv - 70))
        mouth.addLine(to: CGPoint(x: 900, y: Hv + 68))
        mouth.closeSubpath()
        let dark: Kit.Stops = [(Art.color(0x6B4A44), 0), (Art.color(0x3A2A3C), 0.6), (Art.color(0x5A4040), 1)]
        Art.clipped(&context, to: wall) { g in
            Art.stroke(&g, strata, Art.color(0x9A6238, 0.45), width: ArtStyle.detailLine)
            ArtStyle.tooth(&g, in: CGRect(x: 496, y: Hv - 300, width: 404, height: 370), seed: 19, color: Art.color(0xFFF0D0), alpha: 0.08)
            Art.fillLinear(&g, mouth, dark, from: CGPoint(x: 0, y: Hv - 112), to: CGPoint(x: 0, y: Hv + 68))
            Art.stroke(&g, mouth, Art.color(0xF6D9A8, 0.55), width: ArtStyle.contourLine)
            // Sunlight reaching a little way in over the sandy floor.
            Art.fill(&g, Art.ellipse(800, Hv + 66, 70, 16), Art.color(sandHex, 0.3))
        }
    }

    /// Rose petals scattered over `rect` (falling, or lying on the stones).
    static func petals(_ context: inout GraphicsContext, in rect: CGRect, count: Int, seed: UInt32) {
        var random = ArtRandom(seed)
        var pink = Path()
        var red = Path()
        for i in 0..<max(0, count) {
            let x: CGFloat = rect.minX + rect.width * Kit.rnd(&random)
            let y: CGFloat = rect.minY + rect.height * Kit.rnd(&random)
            let r: CGFloat = 2.2 + Kit.rnd(&random) * 2
            let turn: CGFloat = Kit.rnd(&random) * CGFloat.pi
            let move = CGAffineTransform(translationX: x, y: y).rotated(by: turn)
            let leaf = Art.ellipse(0, 0, r, r * 0.6).applying(move)
            if i % 3 == 0 {
                red.addPath(leaf)
            } else {
                pink.addPath(leaf)
            }
        }
        Art.fill(&context, pink, Art.color(0xF6B4C2))
        Art.fill(&context, red, Art.color(0xDB5A6E))
    }

    /// Tiers of tiny far spectators over `rect`: dots of white, ochre, red and dull blue.
    static func spectators(_ context: inout GraphicsContext, in rect: CGRect, rows: Int, seed: UInt32) {
        guard rows > 0, rect.width > 0, rect.height > 0 else { return }
        var random = ArtRandom(seed)
        var white = Path()
        var ochre = Path()
        var red = Path()
        var blue = Path()
        let rowH: CGFloat = rect.height / CGFloat(rows)
        let r: CGFloat = max(1.2, min(3.2, rowH * 0.36))
        for row in 0..<rows {
            let y: CGFloat = rect.minY + rowH * (CGFloat(row) + 0.55)
            var x: CGFloat = rect.minX + Kit.rnd(&random) * r * 2
            while x < rect.maxX {
                let pick: CGFloat = Kit.rnd(&random)
                let dot = CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2.2)
                if pick < 0.42 {
                    white.addEllipse(in: dot)
                } else if pick < 0.7 {
                    ochre.addEllipse(in: dot)
                } else if pick < 0.86 {
                    red.addEllipse(in: dot)
                } else {
                    blue.addEllipse(in: dot)
                }
                x += r * (2.3 + Kit.rnd(&random) * 1.2)
            }
        }
        Art.fill(&context, white, Art.color(0xFBF4E4))
        Art.fill(&context, ochre, Art.color(0xD9A45F))
        Art.fill(&context, red, Art.color(0xC8472E, 0.85))
        Art.fill(&context, blue, Art.color(0x7F93AD))
    }

    /// A round loaf scored into wedges, seen a little from above, centred on (x, y).
    static func loaf(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, r: CGFloat) {
        let shape = Art.ellipse(x, y, r, r * 0.62)
        Kit.solid(&context, shape, Art.color(0xD9A058), light: 0.3, shade: 0.24)
        var scores = Path()
        scores.move(to: CGPoint(x: x - r * 0.8, y: y))
        scores.addLine(to: CGPoint(x: x + r * 0.8, y: y))
        scores.move(to: CGPoint(x: x, y: y - r * 0.5))
        scores.addLine(to: CGPoint(x: x, y: y + r * 0.5))
        scores.move(to: CGPoint(x: x - r * 0.55, y: y - r * 0.36))
        scores.addLine(to: CGPoint(x: x + r * 0.55, y: y + r * 0.36))
        scores.move(to: CGPoint(x: x - r * 0.55, y: y + r * 0.36))
        scores.addLine(to: CGPoint(x: x + r * 0.55, y: y - r * 0.36))
        Art.stroke(&context, scores, Art.color(0x9A6430, 0.7), width: max(0.8, r * 0.07))
    }
}
