import SwiftUI
import OmramoCore

// The palette, the lights, the cast and the shared parts of "The Lion and the Hare".
//
// Persia (the Iranian plateau): bare folded gold hills, one cool green valley, a pale
// turquoise sky. Animals only: no people, no buildings but the old stone well.

// MARK: - Palette and light

extension LionHareArt {
    static let ramp = ArtStyle.Ramp(deep: 0x1E5C4E, shade: 0x8A6A3A, mid: 0xD9A85C, light: 0xD4ECEF, glow: 0xFFE6AE, accent: 0x12A8B8)

    /// Grey field stone (the well, the outcrops).
    static let stoneHex: UInt32 = 0xA89F90
    /// Dusty rose rock (the Lion's rock).
    static let rockHex: UInt32 = 0xC79A82
    static let dryGrassHex: UInt32 = 0xC9A24E
    static let tulipHex: UInt32 = 0xE8503A
    static let tortoiseSkinHex: UInt32 = 0xB5A866
    static let tortoiseShellHex: UInt32 = 0x7C8A3E

    /// Clear daylight over the valley: pale turquoise falling to warm gold.
    static func day() -> Kit.Light {
        let sky: Kit.Stops = [(Art.color(0xBFE6E4), 0), (Art.color(0xD4ECEF), 0.45), (Art.color(0xF3F1D6), 0.8), (Art.color(0xFFE6AE), 1)]
        return Kit.Light(sky: sky, sun: 0xFFF6D8, glow: 0xFFE6AE, haze: 0xF3EDD0, far: 0xE9CF9C, mid: 0xDDB56E, near: 0xC9954E)
    }

    /// Bright noon on the dry hills: a pale hot sky.
    static func noon() -> Kit.Light {
        let sky: Kit.Stops = [(Art.color(0xCFE9EE), 0), (Art.color(0xE4F1EA), 0.45), (Art.color(0xFBF1D2), 0.8), (Art.color(0xFFE6AE), 1)]
        return Kit.Light(sky: sky, sun: 0xFFFBE8, glow: 0xFFE9B8, haze: 0xF8EFD4, far: 0xEBD3A2, mid: 0xE0B872, near: 0xCE9B52)
    }

    /// Soft evening gold (still a pale sky: the words sit on it).
    static func evening() -> Kit.Light {
        let sky: Kit.Stops = [(Art.color(0xD9EEDD), 0), (Art.color(0xF1EFCD), 0.45), (Art.color(0xFFE8B4), 0.8), (Art.color(0xFFD996), 1)]
        return Kit.Light(sky: sky, sun: 0xFFEFC0, glow: 0xFFDCA0, haze: 0xF8E6BE, far: 0xE6C690, mid: 0xD9A862, near: 0xC48C4A)
    }

    static func dryGround() -> Kit.Stops {
        [(Art.color(0xE9C785), 0), (Art.color(0xD9A85C), 0.5), (Art.color(0xC48E48), 1)]
    }

    static func greenGround() -> Kit.Stops {
        [(Art.color(0xACD17E), 0), (Art.color(0x6FA85A), 0.5), (Art.color(0x4A8A4C), 1)]
    }

    static func eveningGround() -> Kit.Stops {
        [(Art.color(0xB9CC72), 0), (Art.color(0x7FA650), 0.5), (Art.color(0x55843F), 1)]
    }

    static func streamStops() -> Kit.Stops {
        [(Art.color(0xC4ECF0), 0), (Art.color(0x4FB6C8), 0.5), (Art.color(0x1E8AA6), 1)]
    }

    static func pathStops() -> Kit.Stops {
        [(Art.color(0xF6E4BC), 0), (Art.color(0xEFD3A0), 0.5), (Art.color(0xE2BC80), 1)]
    }

    static func poplarGreens() -> Kit.Greens {
        Kit.greens(0x3F7A3E, 0x5C9A48, 0x7DB85A, 0xA9D46E, 0xDDF09A)
    }

    /// The plane tree's sunlit mid-greens (kept light: its crown hangs over the trailing pane).
    static func planeGreens() -> Kit.Greens {
        Kit.greens(0x3E7F4A, 0x5AA052, 0x7DBB5E, 0xA8D872, 0xE0F2A0)
    }

    static func valleyGrass() -> Color { Art.color(0x3F7F45) }
    static func dryGrass() -> Color { Art.color(dryGrassHex) }
}

// MARK: - The land

extension LionHareArt {
    /// The far plane of every scene: a pale back range, the kit's rolling gold ranges and a
    /// few fold lines on the nearest one (bare, folded hills; no dunes).
    static func farLand(_ context: inout GraphicsContext, width w: CGFloat, horizon H: CGFloat, scale s: CGFloat, light: Kit.Light, seed: UInt32) {
        let back: Path = Kit.peaks(width: w, y: H - 24 * s, amp: 78 * s, seed: seed &+ 3, bottom: H + 8, sharp: 0.25)
        Art.fill(&context, back, light.far.opacity(0.42))
        Kit.ranges(&context, width: w, horizon: H, scale: s, light: light, mountains: false, seed: seed)
        var folds = Path()
        var random = ArtRandom(seed &+ 31)
        var x: CGFloat = 20
        while x < w {
            let top: CGFloat = H - (10 + Kit.rnd(&random) * 10) * s
            folds.move(to: CGPoint(x: x, y: top))
            folds.addQuadCurve(to: CGPoint(x: x + 14 * s, y: H + 2), control: CGPoint(x: x + 2 * s, y: H - 4 * s))
            x += (46 + Kit.rnd(&random) * 60) * s
        }
        Art.stroke(&context, folds, light.near.opacity(0.35), width: 1.4)
    }

    /// A white-trunked poplar: a slim column of leaves.
    static func poplar(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, height h: CGFloat, seed: UInt32) {
        let foot: CGFloat = max(1.5, h * 0.03)
        Kit.shadow(&context, x, baseY, width: h * 0.3, alpha: 0.2)
        let trunk = Kit.treeTrunk(x, baseY, x, baseY - h * 0.55, foot, foot * 0.6)
        Kit.treeBark(&context, trunk.shape, trunk.edge, 0xE4DECB)
        let b0: Kit.Blob = (x, baseY - h * 0.36, h * 0.13)
        let b1: Kit.Blob = (x + h * 0.01, baseY - h * 0.54, h * 0.14)
        let b2: Kit.Blob = (x - h * 0.01, baseY - h * 0.71, h * 0.12)
        let b3: Kit.Blob = (x, baseY - h * 0.86, h * 0.085)
        let blobs: [Kit.Blob] = [b0, b1, b2, b3]
        Kit.canopy(&context, blobs, seed: seed, palette: poplarGreens(), density: 1.5)
    }

    /// A small puff of dust kicked up from the path; (x, y) is the middle of its base.
    static func dustPuff(_ context: inout GraphicsContext, _ x: CGFloat, _ y: CGFloat, scale: CGFloat) {
        Kit.cloud(&context, x, y, scale: scale, color: Art.color(0xF6E6C2, 0.8))
    }

    /// Wild red tulips and a few white flowers over `rect`.
    static func wildFlowers(_ context: inout GraphicsContext, in rect: CGRect, count: Int, seed: UInt32) {
        Kit.flowers(&context, in: rect, count: count, seed: seed, petal: tulipHex, heart: 0x4A2A22)
        Kit.flowers(&context, in: rect, count: max(1, count / 2), seed: seed &+ 7, petal: 0xFFF6E0)
    }
}

// MARK: - The Lion

extension LionHareArt {
    /// An Asiatic lion: sandy gold, a dark-brown mane, a round well-fed tummy.
    static func lionLook() -> Kit.Beast {
        var spec = Kit.lionLook()
        spec.body = 0xE2B25E
        spec.belly = 0xF6E3B4
        spec.dark = 0x7A4A28
        spec.bulk = 1.1
        return spec
    }

    /// The Lion from the side, facing LEFT; origin on the ground under mid-body (about 220
    /// long and 150 tall at scale 1). `roar` opens a round comic mouth (never teeth).
    static func lion(
        _ context: inout GraphicsContext,
        pose: Kit.BeastPose,
        mood: Kit.BeastMood = .proud,
        roar: Bool = false,
        look: CGPoint = .zero,
        mirrored: Bool = false
    ) {
        let spec = lionLook()
        let shown: Kit.BeastMood = roar ? .surprised : mood
        Kit.shadow(&context, 8, 0, width: 180)
        Kit.beast(&context, spec, pose: pose, mood: shown, look: look, mirrored: mirrored)
        if roar {
            let m: CGPoint = Kit.beastMouth(spec, pose: pose)
            lionRoarMouth(&context, x: m.x - 1, y: m.y + 4, r: 7.5)
            let puffs = Kit.placed("M-14,-10 q-7,8 -2,18 M-24,-15 q-10,13 -3,28 M-35,-20 q-13,18 -4,38", x: m.x, y: m.y)
            Art.stroke(&context, puffs, Art.color(0xFFF8E4, 0.8), width: ArtStyle.contourLine)
        }
    }

    /// The round roaring mouth: a dropped jaw, a dark-red mouth and a pink tongue.
    static func lionRoarMouth(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, r: CGFloat) {
        Art.fill(&context, Art.ellipse(x + r * 0.1, y + r * 0.5, r * 1.3, r * 1.1), Art.color(0xF6E3B4))
        let mouth: Path = Art.ellipse(x, y, r, r * 1.1)
        Art.fill(&context, mouth, Art.color(0x7A2E22))
        let tongue: Path = Art.ellipse(x + r * 0.1, y + r * 0.8, r * 0.75, r * 0.55)
        Art.clipped(&context, to: mouth) { g in
            Art.fill(&g, tongue, Art.color(0xF2788A))
        }
    }

    /// The Lion from the FRONT, roaring: head, chest and paws (origin = head centre, as
    /// `Kit.beastBust`), with the mane blown back.
    static func lionRoarBust(_ context: inout GraphicsContext) {
        let spec = lionLook()
        let tufts = Art.svg("M44,-34 C62,-48 80,-44 90,-32 C74,-34 62,-28 52,-18Z M54,-4 C74,-12 92,-4 98,10 C82,4 68,6 58,12Z M48,26 C66,24 82,34 84,48 C72,38 60,36 50,38Z")
        Art.fill(&context, tufts, Art.color(spec.dark))
        Kit.beastBust(&context, spec, mood: .proud)
        lionRoarMouth(&context, x: 0, y: 28, r: 12.5)
    }
}

// MARK: - The Hare

extension LionHareArt {
    /// A sandy-brown hare with black-tipped ears.
    static func hareLook() -> Kit.Beast {
        var spec = Kit.hareLook()
        spec.body = 0xC9A574
        spec.belly = 0xF6EAD2
        spec.dark = 0x3A2C28
        return spec
    }

    /// The Hare from the side, facing LEFT; origin on the ground under mid-body. `.rear` sits
    /// him up (about 190 tall with the ears at scale 1). One ear is bent at the tip.
    static func hare(
        _ context: inout GraphicsContext,
        pose: Kit.BeastPose,
        mood: Kit.BeastMood = .happy,
        look: CGPoint = .zero,
        mirrored: Bool = false
    ) {
        let spec = hareLook()
        Kit.shadow(&context, 6, 0, width: 90)
        Kit.beast(&context, spec, pose: pose, mood: mood, look: look, mirrored: mirrored)
        let head: CGPoint = Kit.beastHeadCentre(spec, pose: pose)
        let bend = Kit.placed("M-6,-2 C-1,-8 8,-5 12,6 C6,2 0,2 -6,-2Z", x: head.x + 31, y: head.y - 71)
        Art.fill(&context, bend, Art.color(spec.dark))
    }

    /// The bent ear tip on a front view (`Kit.beastFace` / `Kit.beastBust` units).
    static func hareBendFront(_ context: inout GraphicsContext) {
        let spec = hareLook()
        let flap = Art.svg("M23,-68 C27,-76 35,-74 39,-61 C34,-65 28,-65 23,-68Z")
        Art.fill(&context, flap, Kit.faceTone(spec.body, 0.8))
        let tip = Art.svg("M31,-70 C35,-70 38,-66 39,-61 C36,-64 33,-66 31,-70Z")
        Art.fill(&context, tip, Art.color(spec.dark))
        hareTipsFront(&context)
    }

    /// The dark tips of both long ears on a front view.
    static func hareTipsFront(_ context: inout GraphicsContext) {
        let spec = hareLook()
        let left = Art.svg("M-19,-64 C-17,-69 -15,-73 -14,-75 C-11,-71 -9,-67 -8.5,-63 C-12,-66 -16,-66 -19,-64Z")
        Art.fill(&context, left, Art.color(spec.dark))
    }
}

// MARK: - The Gazelle, the deer, the fox

extension LionHareArt {
    static func gazelleLook() -> Kit.Beast {
        var spec = Kit.gazelleLook()
        spec.dark = 0x4A3428
        return spec
    }

    /// A Persian fallow deer: warmer, a little stockier, spotted (the spots are added).
    static func deerLook() -> Kit.Beast {
        var spec = Kit.gazelleLook()
        spec.body = 0xC98A52
        spec.belly = 0xF8E8CE
        spec.bulk = 0.85
        spec.legLength = 1.05
        return spec
    }

    /// Two slim ringed horns; (x, y) is the middle of their bases.
    static func gazelleHorns(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, dark: UInt32) {
        var horns = Path()
        Kit.treeBough(&horns, x - 5, y, x - 12, y - 40, 5, 1.4, bend: -4)
        Kit.treeBough(&horns, x + 4, y - 1, x + 6, y - 42, 5, 1.4, bend: 4)
        Art.fill(&context, horns, Art.color(dark))
        var rings = Path()
        for index in 0..<4 {
            let t: CGFloat = 0.15 + CGFloat(index) * 0.18
            let lx: CGFloat = x - 5 - 7 * t
            let ly: CGFloat = y - 40 * t
            let rx: CGFloat = x + 4 + 2 * t
            let ry: CGFloat = y - 1 - 41 * t
            rings.addPath(Art.line(lx - 2.4, ly, lx + 2.4, ly - 1))
            rings.addPath(Art.line(rx - 2.4, ry, rx + 2.4, ry - 1))
        }
        Art.stroke(&context, rings, Kit.beastTone(dark, 1.9).opacity(0.7), width: 1)
    }

    /// The Gazelle from the side, facing LEFT (about 200 tall with the horns at scale 1).
    static func gazelle(
        _ context: inout GraphicsContext,
        pose: Kit.BeastPose = .stand,
        mood: Kit.BeastMood = .calm,
        look: CGPoint = .zero,
        mirrored: Bool = false
    ) {
        let spec = gazelleLook()
        Kit.shadow(&context, 8, 0, width: 110)
        Kit.beast(&context, spec, pose: pose, mood: mood, look: look, mirrored: mirrored)
        if pose == .stand || pose == .walk {
            let back: CGPoint = Kit.beastBack(spec, pose: pose)
            var stripe = Path()
            stripe.move(to: CGPoint(x: back.x - 34, y: back.y + 26))
            stripe.addQuadCurve(to: CGPoint(x: back.x + 36, y: back.y + 24), control: CGPoint(x: back.x, y: back.y + 30))
            Art.stroke(&context, stripe, Art.color(spec.dark, 0.55), width: 3.5)
        }
        let head: CGPoint = Kit.beastHeadCentre(spec, pose: pose)
        gazelleHorns(&context, x: head.x + 4, y: head.y - 26, dark: spec.dark)
    }

    /// A spotted deer from the side, facing LEFT.
    static func deer(_ context: inout GraphicsContext, pose: Kit.BeastPose = .stand, mood: Kit.BeastMood = .calm, mirrored: Bool = false) {
        let spec = deerLook()
        Kit.shadow(&context, 8, 0, width: 110)
        Kit.beast(&context, spec, pose: pose, mood: mood, mirrored: mirrored)
        guard pose == .stand || pose == .walk else { return }
        let back: CGPoint = Kit.beastBack(spec, pose: pose)
        let places: [(CGFloat, CGFloat)] = [(-22, 8), (-8, 6), (6, 7), (20, 8), (-14, 16), (2, 15), (16, 17)]
        var spots = Path()
        for place in places {
            spots.addPath(Art.circle(back.x + place.0, back.y + place.1, 2.6))
        }
        Art.fill(&context, spots, Art.color(0xFBEBD2, 0.85))
    }

    /// The red fox from the side, facing LEFT.
    static func fox(_ context: inout GraphicsContext, pose: Kit.BeastPose = .sit, mood: Kit.BeastMood = .calm, look: CGPoint = .zero, mirrored: Bool = false) {
        Kit.shadow(&context, 6, 0, width: 100)
        Kit.beast(&context, Kit.foxLook(), pose: pose, mood: mood, look: look, mirrored: mirrored)
    }
}

// MARK: - The Tortoise (bespoke)

extension LionHareArt {
    /// The old Tortoise from the side, facing LEFT; origin on the ground under the shell
    /// (about 120 long and 60 tall at scale 1). Always chewing.
    static func tortoise(_ context: inout GraphicsContext, chewing: Bool = true) {
        let skin: Color = Art.color(tortoiseSkinHex)
        let farSkin: Color = Kit.beastTone(tortoiseSkinHex, 0.76)
        Kit.shadow(&context, 4, 0, width: 104)
        Art.fill(&context, Art.rect(-24, -16, 13, 16, radius: 5), farSkin)
        Art.fill(&context, Art.rect(22, -16, 13, 16, radius: 5), farSkin)
        Art.fill(&context, Art.svg("M36,-14 C44,-14 50,-10 52,-5 C46,-6 40,-7 36,-9Z"), skin)
        // The wrinkly neck and the kind head.
        Kit.limb(&context, "M-28,-18 C-38,-20 -44,-26 -50,-32", 13, skin)
        let wrinkles = Art.svg("M-39,-15 q-3,-5 -7,-7 M-33,-13 q-3,-5 -7,-8")
        Art.stroke(&context, wrinkles, Kit.beastTone(tortoiseSkinHex, 0.68), width: 1.2)
        var head: Path = Art.ellipse(-56, -36, 15, 12.5)
        head.addEllipse(in: CGRect(x: -75, y: -41, width: 24, height: 18))
        Kit.solid(&context, head, skin, light: 0.24, shade: 0.18)
        tortoiseShell(&context)
        Kit.solid(&context, Art.rect(-30, -13, 14, 13, radius: 5), skin, light: 0.2, shade: 0.2)
        Kit.solid(&context, Art.rect(18, -13, 14, 13, radius: 5), skin, light: 0.2, shade: 0.2)
        let toes = Art.svg("M-27,-2 v-3 M-23,-2 v-3 M21,-2 v-3 M25,-2 v-3")
        Art.stroke(&context, toes, Kit.beastTone(tortoiseSkinHex, 0.6), width: 1.2)
        // The face: a big eye under a heavy sleepy lid, a blush, a small smile.
        ArtStyle.eye(&context, -60, -39, 4.8, look: CGPoint(x: -0.3, y: 0.3), showsWhite: true)
        let lidColor: Color = Kit.beastTone(tortoiseSkinHex, 0.86)
        Art.clipped(&context, to: Art.circle(-60, -39, 5.2)) { g in
            Art.fill(&g, Art.rect(-66, -45, 12, 4.6), lidColor)
        }
        Art.stroke(&context, Art.line(-65, -40.4, -55, -40.4), Kit.beastTone(tortoiseSkinHex, 0.55), width: 1.2)
        ArtStyle.cheek(&context, -53, -31, 5, alpha: 0.4)
        ArtStyle.smile(&context, -67, -29, width: 12, curve: 1.8, color: Kit.beastTone(tortoiseSkinHex, 0.5))
        if chewing {
            let leaf = Art.svg("M-73,-28 C-80,-33 -87,-30 -89,-24 C-83,-22 -77,-24 -73,-28Z")
            Art.fill(&context, leaf, Art.color(0x6FA85A))
        }
    }

    /// The domed shell: olive with gold patches and scute lines, a pale rim underneath.
    static func tortoiseShell(_ context: inout GraphicsContext) {
        let shell = Art.svg("M-36,-12 C-36,-40 -16,-58 4,-58 C26,-58 42,-40 42,-12 C30,-8 -24,-8 -36,-12Z")
        Kit.solid(&context, shell, Art.color(tortoiseShellHex), light: 0.3, shade: 0.26, rim: 2)
        var patches = Path()
        let places: [(CGFloat, CGFloat, CGFloat)] = [(-14, -37, 9), (6, -43, 10), (25, -34, 8), (-25, -20, 6), (4, -19, 7), (29, -18, 5)]
        for place in places {
            patches.addEllipse(in: CGRect(x: place.0 - place.2, y: place.1 - place.2 * 0.85, width: place.2 * 2, height: place.2 * 1.7))
        }
        let lines = Art.svg("M-36,-25 C-20,-29 26,-29 42,-25 M-5,-57 L-4,-28 M16,-56 L15,-28 M-23,-49 L-19,-28 M31,-47 L29,-27")
        Art.clipped(&context, to: shell) { g in
            Art.fill(&g, patches, Art.color(0xD9B84A, 0.85))
            Art.stroke(&g, lines, Art.color(0x4E5A26, 0.6), width: 1.4)
        }
        Art.fill(&context, Art.svg("M-37,-13 C-24,-8 30,-8 43,-13 C40,-5 -32,-5 -37,-13Z"), Art.color(0xD8C88A))
    }

    /// The Tortoise from the FRONT, for the face chip: origin at the head centre, the head
    /// about 50 across with the shell's dome behind it.
    static func tortoiseFace(_ context: inout GraphicsContext) {
        let shell = Art.svg("M-37,28 C-42,-8 -24,-35 0,-35 C24,-35 42,-8 37,28Z")
        Kit.solid(&context, shell, Art.color(tortoiseShellHex), light: 0.3, shade: 0.24, rim: 2)
        var patches: Path = Art.ellipse(-21, -10, 8, 8)
        patches.addPath(Art.ellipse(0, -24, 9, 7))
        patches.addPath(Art.ellipse(21, -10, 8, 8))
        Art.fill(&context, patches, Art.color(0xD9B84A, 0.85))
        let head = Art.svg("M0,-20 C-16,-20 -25,-8 -25,6 C-25,20 -14,29 0,29 C14,29 25,20 25,6 C25,-8 16,-20 0,-20Z")
        Kit.solid(&context, head, Art.color(tortoiseSkinHex), light: 0.26, shade: 0.18, rim: 1.6)
        ArtStyle.eye(&context, -10, 1, 6.6, look: CGPoint(x: 0, y: 0.3), showsWhite: true)
        ArtStyle.eye(&context, 10, 1, 6.6, look: CGPoint(x: 0, y: 0.3), showsWhite: true)
        var sockets: Path = Art.circle(-10, 1, 7)
        sockets.addPath(Art.circle(10, 1, 7))
        let lidColor: Color = Kit.beastTone(tortoiseSkinHex, 0.86)
        Art.clipped(&context, to: sockets) { g in
            Art.fill(&g, Art.rect(-18, -7, 36, 6.4), lidColor)
        }
        let lids = Art.svg("M-17,-0.6 h14 M3,-0.6 h14")
        Art.stroke(&context, lids, Kit.beastTone(tortoiseSkinHex, 0.55), width: 1.3)
        ArtStyle.cheek(&context, -17, 11, 6, alpha: 0.4)
        ArtStyle.cheek(&context, 17, 11, 6, alpha: 0.4)
        var nostrils: Path = Art.circle(-2.6, 11, 1.1)
        nostrils.addPath(Art.circle(2.6, 11, 1.1))
        Art.fill(&context, nostrils, Kit.beastTone(tortoiseSkinHex, 0.5))
        ArtStyle.smile(&context, 0, 17, width: 20, curve: 2.4, color: Kit.beastTone(tortoiseSkinHex, 0.45), lineWidth: ArtStyle.contourLine)
        let folds = Art.svg("M-13,24 q13,5 26,0")
        Art.stroke(&context, folds, Kit.beastTone(tortoiseSkinHex, 0.68), width: 1.2)
    }
}

// MARK: - The old stone well

extension LionHareArt {
    /// One rough field stone of the rim, centred on (cx, cy).
    static func wellStone(cx: CGFloat, cy: CGFloat, half: CGFloat, tall: CGFloat, random: inout ArtRandom) -> Path {
        let h: CGFloat = tall / 2
        let j1: CGFloat = (Kit.rnd(&random) - 0.5) * h * 0.5
        let j2: CGFloat = (Kit.rnd(&random) - 0.5) * h * 0.4
        var points: [CGPoint] = []
        points.append(Kit.pt(cx - half, cy + h * 0.5))
        points.append(Kit.pt(cx - half * 0.8, cy - h * 0.7 + j1))
        points.append(Kit.pt(cx - half * 0.1, cy - h + j2))
        points.append(Kit.pt(cx + half * 0.75, cy - h * 0.75 - j1))
        points.append(Kit.pt(cx + half, cy + h * 0.4))
        points.append(Kit.pt(cx + half * 0.5, cy + h))
        points.append(Kit.pt(cx - half * 0.5, cy + h))
        return Kit.groundSmooth(points)
    }

    /// The low outer wall of the well under the front of the rim, with its rough courses.
    static func wellWall(_ context: inout GraphicsContext, ry: CGFloat, wall: CGFloat) {
        let rx: CGFloat = 150
        ArtStyle.contactShadow(&context, 14, wall + ry * 0.6, rx * 1.25, ry * 0.8 + 6, alpha: 0.28)
        var body = Path()
        body.move(to: CGPoint(x: -rx, y: 0))
        body.addLine(to: CGPoint(x: -rx + 4, y: wall))
        body.addQuadCurve(to: CGPoint(x: rx - 4, y: wall), control: CGPoint(x: 0, y: wall + ry * 2))
        body.addLine(to: CGPoint(x: rx, y: 0))
        body.closeSubpath()
        Kit.solid(&context, body, Art.color(stoneHex), light: 0.24, shade: 0.3)
        var random = ArtRandom(41)
        var pale = Path()
        var dark = Path()
        let rows: Int = 3
        for row in 0..<rows {
            let t: CGFloat = 0.22 + CGFloat(row) * 0.3
            for column in 0..<9 {
                let shift: CGFloat = row % 2 == 0 ? 0 : 0.5
                let u: CGFloat = (CGFloat(column) + shift + 0.25) / 9 * 2 - 1
                let bow: CGFloat = 1 - u * u
                let top: CGFloat = ry * bow.squareRoot()
                let bottom: CGFloat = wall + ry * bow
                let sx: CGFloat = u * rx * 0.97
                let sy: CGFloat = Kit.mix(top, bottom, t)
                let widen: CGFloat = 0.4 + 0.6 * bow
                let jitter: CGFloat = Kit.rnd(&random) * 3
                let half: CGFloat = rx * 0.1 * widen + jitter
                let tall: CGFloat = max(5, wall * 0.26)
                let stone = CGRect(x: sx - half, y: sy - tall / 2, width: half * 2, height: tall)
                if (row + column) % 2 == 0 {
                    pale.addRoundedRect(in: stone, cornerSize: CGSize(width: 4, height: 4))
                } else {
                    dark.addRoundedRect(in: stone, cornerSize: CGSize(width: 4, height: 4))
                }
            }
        }
        Art.clipped(&context, to: body) { g in
            Art.fill(&g, pale, Kit.groundTone(stoneHex, 1.14).opacity(0.6))
            Art.fill(&g, dark, Kit.groundTone(stoneHex, 0.8).opacity(0.5))
        }
    }

    /// The old well, seen from a little above: a low ring of rough field stones round a dark
    /// mouth with round water far down. Drawn in its own units: the ring is 300 wide (rx 150),
    /// `ry` is how open the ring looks (40 = seen from the side, 100 = from above), `wall` is
    /// the height of the outer wall; the origin is the middle of the mouth. With `reflect`
    /// a lion's face and a small hare's look up from the water.
    static func well(_ context: inout GraphicsContext, ry: CGFloat, wall: CGFloat, reflect: Bool) {
        let rx: CGFloat = 150
        wellWall(&context, ry: ry, wall: wall)
        Art.fill(&context, Art.ellipse(0, 0, rx, ry), Kit.groundTone(stoneHex, 0.9))
        let mouth: Path = Art.ellipse(0, 0, rx * 0.74, ry * 0.74)
        let inside: Kit.Stops = [(Kit.groundTone(stoneHex, 0.66), 0), (Kit.groundTone(stoneHex, 0.3), 1)]
        Art.fillLinear(&context, mouth, inside, from: CGPoint(x: 0, y: -ry * 0.74), to: CGPoint(x: 0, y: ry * 0.5))
        Art.fill(&context, mouth, ArtStyle.coolShade.opacity(0.28))
        var courses = Path()
        for index in 0..<7 {
            let sx: CGFloat = (CGFloat(index) - 3) * rx * 0.19
            let sy: CGFloat = -ry * 0.5 + CGFloat(index % 2) * ry * 0.13
            courses.addEllipse(in: CGRect(x: sx - rx * 0.08, y: sy - ry * 0.08, width: rx * 0.16, height: ry * 0.16))
        }
        let water: Path = Art.ellipse(0, ry * 0.2, rx * 0.6, ry * 0.5)
        let deep: Kit.Stops = [(Art.color(0x2E7284), 0), (Art.color(0x123E52), 1)]
        let lionSpec = lionLook()
        let hareSpec = hareLook()
        Art.clipped(&context, to: mouth) { g in
            Art.fill(&g, courses, Kit.groundTone(stoneHex, 0.82).opacity(0.4))
            Art.fillLinear(&g, water, deep, from: CGPoint(x: 0, y: -ry * 0.3), to: CGPoint(x: 0, y: ry * 0.7))
            if reflect {
                Art.clipped(&g, to: water) { w in
                    Art.layer(&w, opacity: 0.66) { l in
                        Art.group(&l, x: 14, y: ry * 0.24, scale: ry * 0.0082, scaleX: 1.5) { f in
                            Kit.beastFace(&f, lionSpec, mood: .surprised)
                        }
                        Art.group(&l, x: -54, y: ry * 0.34, scale: ry * 0.0052, scaleX: 1.5) { f in
                            Kit.beastFace(&f, hareSpec, mood: .happy)
                        }
                    }
                    Art.fill(&w, water, Art.color(0x1E5C6E, 0.36))
                }
            }
            Art.fill(&g, Art.ellipse(-rx * 0.2, ry * 0.02, rx * 0.2, ry * 0.1), Art.color(0xD4ECEF, 0.16))
            Art.stroke(&g, Art.ellipse(0, ry * 0.2, rx * 0.44, ry * 0.36), Art.color(0xFFFFFF, 0.22), width: 1.4)
            Art.stroke(&g, Art.ellipse(0, ry * 0.2, rx * 0.24, ry * 0.19), Art.color(0xFFFFFF, 0.3), width: 1.2)
        }
        wellRim(&context, ry: ry)
        Kit.grass(&context, in: CGRect(x: -rx, y: wall + ry * 0.55, width: rx * 2, height: ry * 0.4 + 6), count: 9, seed: 3, color: dryGrass(), height: 11)
        Kit.rock(&context, cx: -rx - 34, baseY: wall + ry * 0.5, width: 46, height: 24, color: stoneHex, seed: 5)
        Kit.rock(&context, cx: rx + 22, baseY: wall + ry * 0.75, width: 34, height: 18, color: stoneHex, seed: 8)
    }

    /// The ring of rim stones: the far half first, then the near half over it.
    static func wellRim(_ context: inout GraphicsContext, ry: CGFloat) {
        let rx: CGFloat = 150
        var random = ArtRandom(52)
        let count: Int = 18
        for pass in 0..<2 {
            for index in 0..<count {
                let a: CGFloat = (CGFloat(index) + 0.5) / CGFloat(count) * 2 * CGFloat.pi
                let s: CGFloat = sin(a)
                let front: Bool = s > 0
                if front != (pass == 1) { continue }
                let c: CGFloat = cos(a)
                let jitter: CGFloat = Kit.rnd(&random)
                let across: CGFloat = 0.55 + 0.45 * abs(s)
                let half: CGFloat = rx * (0.15 + jitter * 0.04) * across
                let tall: CGFloat = ry * 0.2 + 8 + jitter * 4
                let stone: Path = wellStone(cx: c * rx * 0.87, cy: s * ry * 0.87, half: half, tall: tall, random: &random)
                let tone: CGFloat = 0.95 + jitter * 0.22
                Kit.solid(&context, stone, Kit.groundTone(stoneHex, tone), light: 0.3, shade: 0.26, rim: 1.6)
            }
        }
    }

    /// The story's key picture, in the well's units (see `well`): the Lion leaning over the
    /// far rim with his paws on the stones, the little Hare at the rim beside his paw, and
    /// the two of them looking back up from the water. `lionScale` 1.7 is the full-size Lion.
    static func wellEnsemble(
        _ context: inout GraphicsContext,
        ry: CGFloat,
        wall: CGFloat,
        lionScale ls: CGFloat,
        hareScale hs: CGFloat,
        lionMood: Kit.BeastMood = .surprised,
        hareMood: Kit.BeastMood = .happy,
        hareGaze: CGPoint = CGPoint(x: 0.3, y: 0.8)
    ) {
        let lionSpec = lionLook()
        let hareSpec = hareLook()
        let lionY: CGFloat = -ry - 62 * ls
        Art.group(&context, x: 10, y: lionY, scale: ls) { g in
            Kit.beastBust(&g, lionSpec, mood: lionMood, look: CGPoint(x: -0.2, y: 0.9))
        }
        let hareRim: CGFloat = -ry * 0.745 - 12
        let hareY: CGFloat = hareRim - 27 * hs
        Art.group(&context, x: -100, y: hareY, scale: hs) { g in
            Kit.beastBust(&g, hareSpec, mood: hareMood, look: hareGaze)
            hareBendFront(&g)
        }
        well(&context, ry: ry, wall: wall, reflect: true)
        let pawY: CGFloat = -ry * 0.9 - 6
        let lionPaws: [CGFloat] = [10 - 30 * ls, 10 + 30 * ls]
        for px in lionPaws {
            Art.group(&context, x: px, y: pawY, scale: ls * 0.95) { g in
                Kit.facePaw(&g, lionSpec, x: 0, y: 0)
            }
        }
        let harePaws: [CGFloat] = [-100 - 13 * hs, -100 + 13 * hs]
        for px in harePaws {
            Art.group(&context, x: px, y: hareRim + 6, scale: hs * 0.8) { g in
                Kit.facePaw(&g, hareSpec, x: 0, y: 0)
            }
        }
    }
}
