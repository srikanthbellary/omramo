import SwiftUI
import OmramoCore

// The cast and the shared parts of "The Peasant and the Bear": the palette, the four seasons of
// light, the Peasant, his wife, the Bear and the horse, and the story's own things — turnips,
// the Bear's heaps, the forest edge, the far village, the stump with the gift.

extension PeasantBearArt {
    // MARK: Palette

    /// Pale northern sky, birch white, dark earth, turnip gold and rye gold; one red shirt.
    static let ramp = ArtStyle.Ramp(deep: 0x1E4A34, shade: 0x5B3A1E, mid: 0x7FAE5A, light: 0xCDEBF2, glow: 0xFFE9A8, accent: 0xC8402A)

    static let turnipHex: UInt32 = 0xFBF1D0
    static let topsHex: UInt32 = 0x4F9A45
    static let ryeHex: UInt32 = 0xE3B23C
    static let cartHex: UInt32 = 0x8E6240
    static let logHex: UInt32 = 0xB07A48
    static let capHex: UInt32 = 0x4E6278

    /// Where the Bear's leading paw is when he is up on his hind legs (`.rear`), in his own units.
    static let rearPawX: CGFloat = -63
    static let rearPawY: CGFloat = -118

    // MARK: Light — four seasons, every sky pale

    /// Spring morning: fresh, cool, a little warm at the horizon.
    static func spring() -> Kit.Light {
        let sky: Kit.Stops = [(Art.color(0xBFE6F2), 0), (Art.color(0xD9F1F4), 0.55), (Art.color(0xFFF4CF), 1)]
        return Kit.Light(sky: sky, sun: 0xFFF6D0, glow: 0xFFE9A8, haze: 0xDDF0EE, far: 0x9CC7C0, mid: 0x8FBF86, near: 0x5E9A5A)
    }

    /// Autumn: low gold light under a pale sky.
    static func autumn() -> Kit.Light {
        let sky: Kit.Stops = [(Art.color(0xCFE8EE), 0), (Art.color(0xE6F1E6), 0.5), (Art.color(0xFFEDBE), 1)]
        return Kit.Light(sky: sky, sun: 0xFFF0C0, glow: 0xFFE3A0, haze: 0xEFEFD9, far: 0xB9C2A0, mid: 0xD9B45A, near: 0xB9862E)
    }

    /// High summer: a high pale blue.
    static func summer() -> Kit.Light {
        let sky: Kit.Stops = [(Art.color(0xA9DCF2), 0), (Art.color(0xCDEBF5), 0.55), (Art.color(0xFFF6D2), 1)]
        return Kit.Light(sky: sky, sun: 0xFFF6D0, glow: 0xFFE9A8, haze: 0xD6EEF2, far: 0x8FBFD0, mid: 0x86B8A6, near: 0x5E9A6A)
    }

    /// Harvest: late-summer afternoon, soft and golden.
    static func harvest() -> Kit.Light {
        let sky: Kit.Stops = [(Art.color(0xC6E6F1), 0), (Art.color(0xDDF0F0), 0.5), (Art.color(0xFFEDC0), 1)]
        return Kit.Light(sky: sky, sun: 0xFFF0C0, glow: 0xFFE7B3, haze: 0xE8F0E2, far: 0xA9C9C2, mid: 0xB9C28A, near: 0xA9903E)
    }

    /// Late-summer birch leaves, just starting to turn.
    static func turningGreens() -> Kit.Greens {
        Kit.greens(0x3F6B2A, 0x6E9A3A, 0x9CBF4A, 0xD6D05A, 0xF6E486)
    }

    // MARK: The Peasant and his wife

    /// A wiry, cheerful man: short brown beard, red belted shirt, a soft cap.
    static func peasantLook(cap: Bool = true) -> Kit.Person {
        let wear: Kit.Person.Headwear = cap ? .cap : .none
        return Kit.Person(
            age: .adult,
            skin: 0xD9A273,
            hair: 0x7A4A28,
            hairStyle: .short,
            beard: .short,
            headwear: wear,
            headwearColor: capHex,
            garment: .shirtTrousers,
            cloth: 0xC8402A,
            trim: 0xF6DFA6,
            legs: 0x6E7FA0,
            showsEyeWhite: true
        )
    }

    /// A sturdy, bright-eyed woman: green dress, white apron, a plain headscarf.
    static func wifeLook() -> Kit.Person {
        Kit.Person(
            age: .adult,
            skin: 0xE2AE82,
            hair: 0x6B4428,
            hairStyle: .short,
            beard: .none,
            headwear: .kerchief,
            headwearColor: 0xF2C14E,
            garment: .dress,
            cloth: 0x2F8F5E,
            trim: 0xFBF3E0,
            legs: 0x7A5638,
            showsEyeWhite: true
        )
    }

    /// The soft peaked cap, held in a hand: centred on (0, 0), about 22 wide.
    static func capShape(_ g: inout GraphicsContext) {
        let crown: Path = Art.svg("M-10,2 C-11,-9 10,-10 10,2 C6,5 -6,5 -10,2Z")
        Kit.solid(&g, crown, Art.color(capHex), light: 0.26, shade: 0.22)
        let peak: Path = Art.svg("M-10,2 C-14,2 -17,4 -18,6 C-13,7 -8,6 -5,4Z")
        Art.fill(&g, peak, Art.color(0x364656))
        Art.stroke(&g, Art.svg("M-9,1 C-4,4 5,4 9,1"), Art.color(0x364656), width: 1.6)
    }

    /// The Peasant, origin at his feet, facing LEFT, 168 tall. `capInHand`: he has taken his
    /// cap off and holds it in his leading hand (use with `.carry`). The caller mirrors with
    /// `Art.group(scaleX: -1)` and passes `mirrored: true`, and draws the contact shadow.
    static func peasant(
        _ context: inout GraphicsContext,
        pose: Kit.Pose = .stand,
        look: CGPoint = .zero,
        mouth: Kit.Mouth = .smile,
        capInHand: Bool = false,
        mirrored: Bool = false
    ) {
        let p = peasantLook(cap: !capInHand)
        Kit.person(&context, p, pose: pose, look: look, mouth: mouth, mirrored: mirrored)
        // The woven belt of his shirt: a knot at the hip and two short ends.
        var upright: Bool = false
        switch pose {
        case .stand, .reach, .carry, .wave, .walk:
            upright = true
        case .sit, .kneel, .bow, .sleep:
            upright = false
        }
        if upright {
            let sash: Color = Art.color(0xF2C14E)
            Art.stroke(&context, Art.svg("M-13,-66 L-15,-50 M-11,-66 L-8,-52"), sash, width: 2.6)
            Art.fill(&context, Art.circle(-12, -66, 3.4), sash)
        }
        if capInHand {
            let hand: CGPoint = Kit.hand(p, pose: pose)
            Art.group(&context, x: hand.x + 2, y: hand.y - 2, rotate: Kit.deg(-12)) { g in
                capShape(&g)
            }
        }
    }

    // MARK: The Bear

    /// The big brown Bear of the Russian tales: round, shaggy, a pale muzzle.
    static func bearSpec() -> Kit.Beast {
        var look = Kit.bearLook()
        look.body = 0x8E5C36
        look.belly = 0xDDB98C
        look.dark = 0x3E2A1E
        return look
    }

    enum BearSprig: Sendable { case none, leaf, rye, root }

    /// A turnip leaf to chew: it hangs from (0, 0), down and to the right.
    static func leafSprig(_ g: inout GraphicsContext) {
        var leaf = Path()
        Kit.groundLeaf(&leaf, base: CGPoint(x: 3, y: 2), angle: Kit.deg(62), length: 30, width: 15)
        Art.stroke(&g, Art.line(-4, -1, 5, 4), Art.color(0x3B7E3A), width: 2.4)
        Kit.solid(&g, leaf, Art.color(topsHex), light: 0.2, shade: 0.16)
        Art.stroke(&g, Art.line(4, 4, 15, 25), Art.color(0xB6DE78, 0.8), width: 1.2)
    }

    /// A rye stalk with its bearded ear: it sticks out from (0, 0), up and to the right.
    static func ryeSprig(_ g: inout GraphicsContext) {
        Art.stroke(&g, Art.svg("M-5,1 Q12,-2 26,-12"), Art.color(0xC9982E), width: 1.8)
        var ear = Path()
        Kit.groundLeaf(&ear, base: CGPoint(x: 24, y: -11), angle: Kit.deg(-30), length: 18, width: 6)
        Art.fill(&g, ear, Art.color(0xF0C552))
        Art.stroke(&g, Art.svg("M30,-15 l8,-9 M34,-17 l9,-6 M38,-19 l9,-2"), Art.color(0xF6DB86), width: 0.9)
    }

    /// A thin dry root, held: it runs up from (0, 0) and trails down, like string.
    static func rootSprig(_ g: inout GraphicsContext) {
        let root: Path = Art.svg("M2,26 C-4,16 6,8 0,0 C-5,-8 4,-16 -1,-26 C-3,-32 2,-36 0,-42")
        Art.stroke(&g, root, Art.color(0xA9865A), width: 2.2)
        Art.stroke(&g, Art.svg("M0,-26 l-7,-5 M-1,-34 l6,-5 M1,10 l7,3 M0,20 l-6,4"), Art.color(0xC9A878), width: 1.1)
    }

    /// The Bear, facing LEFT, origin on the ground under the middle of his body (about 190
    /// tall up on his hind legs, 160 sitting). `brow` lifts his thick eyebrows (0…1);
    /// `sprig` puts something in the corner of his mouth, or (`.root`) in his raised paw.
    /// The caller mirrors with `Art.group(scaleX: -1)` and passes `mirrored: true`.
    static func bear(
        _ context: inout GraphicsContext,
        pose: Kit.BeastPose,
        mood: Kit.BeastMood = .calm,
        look: CGPoint = .zero,
        brow: CGFloat = 0,
        sprig: BearSprig = .none,
        mirrored: Bool = false
    ) {
        let spec = bearSpec()
        Kit.beast(&context, spec, pose: pose, mood: mood, look: look, mirrored: mirrored)
        let head: CGPoint = Kit.beastHeadCentre(spec, pose: pose)
        // His eyebrows: two thick soft arcs that lift when he is puzzled. Never drawn down.
        let lift: CGFloat = -4 * brow
        let by: CGFloat = head.y - 15 + lift
        var brows = Path()
        brows.move(to: CGPoint(x: head.x - 28, y: by + 1))
        brows.addQuadCurve(to: CGPoint(x: head.x - 16, y: by), control: CGPoint(x: head.x - 22, y: by - 5))
        brows.move(to: CGPoint(x: head.x - 10, y: by))
        brows.addQuadCurve(to: CGPoint(x: head.x + 5, y: by + 2), control: CGPoint(x: head.x - 2, y: by - 6))
        Art.stroke(&context, brows, Art.color(0x4A2F1C), width: 3.2)
        let mouth: CGPoint = Kit.beastMouth(spec, pose: pose)
        switch sprig {
        case .none:
            break
        case .leaf:
            Art.group(&context, x: mouth.x + 6, y: mouth.y + 1) { g in
                leafSprig(&g)
            }
        case .rye:
            Art.group(&context, x: mouth.x + 6, y: mouth.y) { g in
                ryeSprig(&g)
            }
        case .root:
            if pose == .rear {
                Art.group(&context, x: rearPawX - 2, y: rearPawY - 4) { g in
                    rootSprig(&g)
                }
            }
        }
    }

    // MARK: The horse

    /// A small, sturdy, shaggy farm horse in a soft bay.
    static func horseSpec() -> Kit.Beast {
        var look = Kit.horseLook()
        look.body = 0xA86A3C
        look.belly = 0xEBD2AC
        look.dark = 0x40281C
        look.bodyLength = 1.8
        look.legLength = 0.95
        look.bulk = 1.1
        look.mane = true
        return look
    }

    /// The horse in harness, standing, facing LEFT; origin on the ground under mid-body
    /// (about 150 tall to the ears). Its collar is at about (−24, −86): hitch the traces there.
    static func horse(_ context: inout GraphicsContext, mood: Kit.BeastMood = .calm, look: CGPoint = .zero, mirrored: Bool = false) {
        let spec = horseSpec()
        Kit.beast(&context, spec, pose: .stand, mood: mood, look: look, mirrored: mirrored)
        // The collar round the base of the neck, and the wooden arch (the duga) above it.
        Art.stroke(&context, Art.svg("M-37,-121 C-28,-108 -22,-92 -21,-74"), Art.color(0x4A2F22), width: 6.5)
        Art.stroke(&context, Art.svg("M-38,-120 C-30,-108 -25,-94 -23,-78"), Art.color(0x8A5A3A, 0.8), width: 1.6)
        let arch: Path = Art.svg("M-44,-112 C-46,-150 -38,-166 -29,-166 C-20,-166 -12,-150 -14,-112")
        Art.stroke(&context, arch, Art.color(0xB8802E), width: 5.5)
        Art.stroke(&context, Art.svg("M-45,-118 C-46,-148 -39,-163 -30,-164"), Art.color(0xF2CC7A, 0.8), width: 1.5)
        Art.fill(&context, Art.circle(-29, -160, 2.6), Art.color(ramp.accent))
    }
}

// MARK: - Turnips and the Bear's heaps

extension PeasantBearArt {
    static let turnipData: String = "M0,-0.78 C0.62,-0.82 1.02,-0.42 1,0 C0.98,0.46 0.5,0.74 0.12,0.8 C0.08,0.95 0.04,1.1 0,1.28 C-0.04,1.1 -0.08,0.95 -0.12,0.8 C-0.5,0.74 -0.98,0.46 -1,0 C-1.02,-0.42 -0.62,-0.82 0,-0.78Z"

    /// The fan of green leaves on a turnip of half-width `r` centred on (0, 0).
    static func turnipTops(_ g: inout GraphicsContext, r: CGFloat) {
        let base = CGPoint(x: 0, y: -r * 0.7)
        let fans: [(CGFloat, CGFloat)] = [(-152, 1.0), (-122, 1.25), (-90, 1.4), (-60, 1.2), (-30, 0.95)]
        var back = Path()
        var front = Path()
        var ribs = Path()
        var index: Int = 0
        for fan in fans {
            let a: CGFloat = Kit.deg(fan.0)
            let length: CGFloat = r * fan.1
            if index % 2 == 0 {
                Kit.groundLeaf(&back, base: base, angle: a, length: length, width: length * 0.42)
            } else {
                Kit.groundLeaf(&front, base: base, angle: a, length: length, width: length * 0.42)
            }
            let reach: CGFloat = length * 0.8
            ribs.move(to: base)
            ribs.addLine(to: CGPoint(x: base.x + cos(a) * reach, y: base.y + sin(a) * reach))
            index += 1
        }
        Art.fill(&g, back, Art.color(0x3B7E3A))
        Art.fill(&g, front, Art.color(topsHex))
        Art.stroke(&g, ribs, Art.color(0xB6DE78, 0.7), width: max(0.7, r * 0.05))
    }

    /// One turnip of the old northern kind: round and a little flat, pale yellow-white with a
    /// soft violet shoulder, a thin root tail; `tops` adds its green leaves. (x, y) is the
    /// middle of the root and `r` its half-width.
    static func turnip(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, r: CGFloat, tops: Bool = true, tilt: CGFloat = 0) {
        Art.group(&context, x: x, y: y, rotate: tilt) { g in
            if tops {
                turnipTops(&g, r: r)
            }
            let root: Path = Kit.placed(turnipData, x: 0, y: 0, scale: r)
            let tone: Kit.Stops = [(Art.color(0xFFFBEA), 0), (Art.color(turnipHex), 0.5), (Art.color(0xE9C877), 1)]
            Kit.solid(&g, root, stops: tone, light: 0.2, shade: 0.2)
            Art.clipped(&g, to: root) { c in
                Art.fill(&c, Art.ellipse(0, -r * 0.8, r * 0.9, r * 0.36), Art.color(0xB88AC4, 0.5))
                Art.fill(&c, Art.ellipse(-r * 0.38, -r * 0.28, r * 0.2, r * 0.12), Color.white.opacity(0.55))
            }
        }
    }

    /// The Bear's share of the turnips: a big heap of cut green tops, `width` wide on baseY.
    static func leafHeap(_ context: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, width: CGFloat, seed: UInt32 = 3) {
        let half: CGFloat = width / 2
        let rise: CGFloat = width * 0.4
        Kit.shadow(&context, cx, baseY, width: width * 1.05)
        var mound = Path()
        mound.move(to: CGPoint(x: cx - half, y: baseY))
        mound.addQuadCurve(to: CGPoint(x: cx + half, y: baseY), control: CGPoint(x: cx, y: baseY - rise * 2))
        mound.closeSubpath()
        Kit.solid(&context, mound, Art.color(0x2F6B36), light: 0.2, shade: 0.24)
        var random = ArtRandom(seed)
        var dark = Path()
        var mid = Path()
        var lit = Path()
        var ribs = Path()
        for index in 0..<48 {
            let t: CGFloat = Kit.rnd(&random) * 2 - 1
            let room: CGFloat = rise * (1 - t * t)
            let lx: CGFloat = cx + t * half * 0.92
            let ly: CGFloat = baseY - Kit.rnd(&random) * room
            let turn: CGFloat = (Kit.rnd(&random) - 0.5) * 70
            let a: CGFloat = Kit.deg(-90 + t * 70 + turn)
            let length: CGFloat = width * (0.16 + Kit.rnd(&random) * 0.1)
            let base = CGPoint(x: lx, y: ly)
            switch index % 3 {
            case 0:
                Kit.groundLeaf(&dark, base: base, angle: a, length: length, width: length * 0.44)
            case 1:
                Kit.groundLeaf(&mid, base: base, angle: a, length: length, width: length * 0.44)
            default:
                Kit.groundLeaf(&lit, base: base, angle: a, length: length * 0.9, width: length * 0.4)
            }
            let reach: CGFloat = length * 0.75
            ribs.move(to: base)
            ribs.addLine(to: CGPoint(x: lx + cos(a) * reach, y: ly + sin(a) * reach))
        }
        Art.fill(&context, dark, Art.color(0x3B7E3A))
        Art.fill(&context, mid, Art.color(topsHex))
        Art.fill(&context, lit, Art.color(0x86C45A))
        Art.stroke(&context, ribs, Art.color(0xC4E88A, 0.55), width: max(0.7, width * 0.008))
    }

    /// The Bear's share of the rye: a heap of thin dry roots and stubble, `width` wide.
    static func rootHeap(_ context: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, width: CGFloat, seed: UInt32 = 5) {
        let half: CGFloat = width / 2
        let rise: CGFloat = width * 0.3
        Kit.shadow(&context, cx, baseY, width: width * 1.05)
        var mound = Path()
        mound.move(to: CGPoint(x: cx - half, y: baseY))
        mound.addQuadCurve(to: CGPoint(x: cx + half, y: baseY), control: CGPoint(x: cx, y: baseY - rise * 2))
        mound.closeSubpath()
        let tone: Kit.Stops = [(Art.color(0xCDB07A), 0), (Art.color(0x9A7A4A), 1)]
        Kit.solid(&context, mound, stops: tone, light: 0.22, shade: 0.24)
        var random = ArtRandom(seed)
        var dark = Path()
        var pale = Path()
        var straw = Path()
        for index in 0..<40 {
            let t: CGFloat = Kit.rnd(&random) * 2 - 1
            let room: CGFloat = rise * (1 - t * t)
            let x: CGFloat = cx + t * half * 0.95
            let y: CGFloat = baseY - Kit.rnd(&random) * room
            let reach: CGFloat = width * (0.1 + Kit.rnd(&random) * 0.12)
            let dir: CGFloat = index % 2 == 0 ? 1 : -1
            let end = CGPoint(x: x + dir * reach, y: y - reach * 0.3)
            let c1 = CGPoint(x: x + dir * reach * 0.3, y: y - reach * 0.7)
            let c2 = CGPoint(x: x + dir * reach * 0.7, y: y + reach * 0.3)
            switch index % 4 {
            case 0, 1:
                dark.move(to: CGPoint(x: x, y: y))
                dark.addCurve(to: end, control1: c1, control2: c2)
            case 2:
                pale.move(to: CGPoint(x: x, y: y))
                pale.addCurve(to: end, control1: c1, control2: c2)
            default:
                straw.move(to: CGPoint(x: x, y: y))
                straw.addLine(to: CGPoint(x: x + dir * reach * 0.5, y: y - reach * 0.9))
            }
        }
        let lineWidth: CGFloat = max(1, width * 0.012)
        Art.stroke(&context, dark, Art.color(0x7A5A34), width: lineWidth)
        Art.stroke(&context, pale, Art.color(0xEAD8AA), width: lineWidth)
        Art.stroke(&context, straw, Art.color(0xE3B23C), width: lineWidth * 1.3)
    }

    /// The gift at the end of the tale: a tree stump with a dark rye loaf and a small basket of
    /// turnips on it. Origin: the middle of the stump's foot; about 88 wide and 64 tall at 1.
    static func stumpGift(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, scale s: CGFloat) {
        Art.group(&context, x: x, y: baseY, scale: s) { g in
            Kit.shadow(&g, 0, 0, width: 90)
            let stump: Path = Art.svg("M-30,-34 L30,-34 C30,-16 34,-6 44,0 L-44,0 C-34,-6 -30,-16 -30,-34Z")
            Kit.solid(&g, stump, Art.color(0x7A5638), light: 0.24, shade: 0.26)
            Art.stroke(&g, Art.svg("M-14,-28 L-16,-4 M4,-28 L6,-3 M20,-28 L24,-5"), Art.color(0x4E3524, 0.6), width: ArtStyle.detailLine)
            Art.fill(&g, Art.ellipse(0, -34, 30, 8), Art.color(0xE2C08A))
            Art.stroke(&g, Art.ellipse(0, -34, 19, 5), Art.color(0xB58A52, 0.8), width: 1.2)
            Art.stroke(&g, Art.ellipse(0, -34, 9, 2.4), Art.color(0xB58A52, 0.8), width: 1.2)
            // The round loaf of black bread, with three cuts on its crust.
            let loaf: Path = Art.svg("M-27,-36 C-27,-53 -3,-55 -3,-36 C-3,-33 -27,-33 -27,-36Z")
            Kit.solid(&g, loaf, Art.color(0x6B4426), light: 0.3, shade: 0.2)
            Art.stroke(&g, Art.svg("M-21,-44 l4,-4 M-15,-45 l4,-4 M-10,-44 l4,-4"), Art.color(0xC9A070, 0.85), width: 1.3)
            // The basket, with two turnips showing over its rim.
            turnip(&g, x: 9, y: -52, r: 6.5)
            turnip(&g, x: 19, y: -53, r: 6)
            Kit.propBasketBody(&g, cx: 14, baseY: -35, width: 25, height: 15, color: 0xC89A54, lid: false, handles: false)
        }
    }
}

// MARK: - The forest edge and the village

extension PeasantBearArt {
    /// The forest edge on the trailing side of an unfolded scene, in design units (horizon
    /// `Hv`): dark pointed spruces behind, white birches in front, bushes at their feet. The
    /// tallest top is about 250 above the horizon. `shift` moves the whole edge right.
    static func forestEdge(_ g: inout GraphicsContext, horizon Hv: CGFloat, leaves: Kit.Greens, bushes: Kit.Greens, shift: CGFloat = 0) {
        let pines: Kit.Greens = Kit.pineGreens()
        let spruces: [(CGFloat, CGFloat, CGFloat)] = [(704, 4, 186), (756, 2, 232), (818, 6, 258), (868, 2, 220), (906, 8, 246)]
        var seed: UInt32 = 3
        for spruce in spruces {
            Kit.conifer(&g, x: spruce.0 + shift, baseY: Hv + spruce.1, height: spruce.2, palette: pines, seed: seed)
            seed = seed &+ 2
        }
        let birches: [(CGFloat, CGFloat, CGFloat)] = [(736, 20, 228), (794, 28, 266), (848, 22, 244), (886, 34, 282)]
        seed = 2
        for birch in birches {
            Kit.birch(&g, x: birch.0 + shift, baseY: Hv + birch.1, height: birch.2, palette: leaves, seed: seed)
            seed = seed &+ 3
        }
        Kit.bush(&g, x: 772 + shift, baseY: Hv + 34, width: 72, palette: bushes, seed: 6)
        Kit.bush(&g, x: 874 + shift, baseY: Hv + 46, width: 92, palette: bushes, seed: 9)
    }

    /// The far village: a log izba with a carved plank gable, a well with its long pole, a
    /// fence and three more roofs, a thread of smoke. Origin: the foot of the izba; about
    /// 400 wide and 110 tall at scale 1 (the smoke rises higher). Draw it small and far.
    static func village(_ g: inout GraphicsContext, light: Kit.Light) {
        let wallFar: Color = Art.color(0xB89A78)
        let roofFar: Color = Art.color(0x8E8068)
        Kit.farHouse(&g, cx: -150, baseY: -2, width: 62, height: 52, wall: wallFar, roof: roofFar)
        Kit.farHouse(&g, cx: -226, baseY: -2, width: 48, height: 40, wall: wallFar, roof: roofFar)
        Kit.farHouse(&g, cx: 176, baseY: -2, width: 56, height: 46, wall: wallFar, roof: roofFar)
        Kit.farTree(&g, x: -92, baseY: 0, height: 84, color: light.mid)
        Kit.farTree(&g, x: 226, baseY: 0, height: 70, color: light.mid)
        Kit.fence(&g, x0: -200, x1: -58, baseY: 2, height: 16, color: 0x9A7A56)
        // A thread of smoke from the stove: the bread is baking.
        let smoke: Path = Art.svg("M22,-96 C14,-110 30,-120 22,-136 C16,-148 30,-158 26,-172")
        Art.stroke(&g, smoke, Art.color(0xFFFFFF, 0.6), width: 5)
        Art.fill(&g, Art.rect(16, -98, 12, 16), Art.color(0x8A6A5A))
        Kit.house(&g, cx: 0, baseY: 0, width: 100, wallHeight: 46, roofHeight: 46, wall: logHex, roof: 0x8A6248, style: .plank, door: 0x5A3A2A, windows: 2, lit: false, timber: 0x8A5A32)
        // The well: a low log box, a post and a long counterweighted pole.
        Kit.solid(&g, Art.rect(86, -12, 20, 12, radius: 2), Art.color(0x9A7450), light: 0.2, shade: 0.2)
        Kit.propShaft(&g, 118, 0, 118, -46, wood: 0x7A5638, width: 3)
        Kit.propShaft(&g, 92, -66, 140, -30, wood: 0x8A6240, width: 2.4)
        Art.stroke(&g, Art.line(92, -66, 95, -14), Art.color(0x5A4636, 0.8), width: 1)
    }
}
