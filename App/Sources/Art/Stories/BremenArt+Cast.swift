import SwiftUI
import OmramoCore

// The cast and the shared parts of "The Bremen Town Musicians": the palette, the three lights
// (afternoon on the road, pale dusk at the forest and the house, fresh morning at home), the
// four friends (each look defined once), the tower of four, the timber house, the straw heap,
// the forest edge and the tiny far town.

extension BremenArt {
    // MARK: Palette and light

    /// Soft northern daylight: cool pale skies, meadow green, warm straw and window gold, one
    /// spot of rooster red.
    static let ramp = ArtStyle.Ramp(deep: 0x2F3E46, shade: 0x5B6E5A, mid: 0x8DB360, light: 0xDCEBF2, glow: 0xFFD98A, accent: 0xC8452C)

    static let timberHex: UInt32 = 0x4A3528
    static let plasterHex: UInt32 = 0xF3E8D2
    static let tileHex: UInt32 = 0xB5553A
    static let thatchHex: UInt32 = 0xC9A45A
    static let strawHex: UInt32 = 0xE9C25A
    static let roadHex: UInt32 = 0xE8D6AE
    static let ropeHex: UInt32 = 0xB98A4E

    /// Late afternoon on the road.
    static func day() -> Kit.Light {
        let sky: Kit.Stops = [(Art.color(0xBFDDEE), 0), (Art.color(0xDCEBF2), 0.55), (Art.color(0xFFF1C4), 1)]
        return Kit.Light(sky: sky, sun: 0xFFF6CF, glow: 0xFFD98A, haze: 0xEAF0DC, far: 0xA9C6C8, mid: 0x9CC08A, near: 0x7FAE5C)
    }

    /// Pale dusk: soft blue-grey above, lilac, cream at the horizon. Never night.
    static func dusk() -> Kit.Light {
        let sky: Kit.Stops = [(Art.color(0xCBD6EA), 0), (Art.color(0xE4DEEC), 0.5), (Art.color(0xFFE6C6), 1)]
        return Kit.Light(sky: sky, sun: 0xFFEBC4, glow: 0xFFD3A0, haze: 0xECE0DE, far: 0xA9B6C4, mid: 0x7F9788, near: 0x4F6E5A)
    }

    /// Fresh morning at home.
    static func morning() -> Kit.Light {
        let sky: Kit.Stops = [(Art.color(0xBDE3F3), 0), (Art.color(0xDDF0F5), 0.55), (Art.color(0xFFF3C9), 1)]
        return Kit.Light(sky: sky, sun: 0xFFF6CF, glow: 0xFFDF95, haze: 0xECF3DC, far: 0xA6CBB4, mid: 0x8FBF7A, near: 0x7FAE5C)
    }

    /// Meadow green going to a deeper green toward the viewer.
    static func meadowStops() -> Kit.Stops {
        [(Art.color(0xB4D27C), 0), (Art.color(0x8DB360), 0.45), (Art.color(0x5F8F4E), 1)]
    }

    /// The forest floor at dusk: moss and brown leaves.
    static func forestFloorStops() -> Kit.Stops {
        [(Art.color(0x9DB07A), 0), (Art.color(0x7A9264), 0.4), (Art.color(0x566E52), 1)]
    }

    static func roadStops() -> Kit.Stops {
        [(Art.color(0xF3E6C4), 0), (Art.color(roadHex), 0.5), (Art.color(0xD4BC8C), 1)]
    }

    /// Beech and oak leaves at dusk: a little greyer than summer.
    static func duskGreens() -> Kit.Greens {
        Kit.greens(0x24463C, 0x356152, 0x4F8062, 0x7FA873, 0xC9D98A)
    }

    // MARK: The four looks (defined once)

    /// A small sturdy grey donkey with a pale muzzle and belly and a dark crest.
    static func donkeyLook() -> Kit.Beast {
        var look = Kit.donkeyLook()
        look.body = 0x9B9CA8
        look.belly = 0xEFE9DD
        look.dark = 0x4A4652
        look.mane = true
        return look
    }

    /// An old hunting hound, rust-brown with a pale grey-white muzzle and chest.
    static func dogLook() -> Kit.Beast {
        var look = Kit.dogLook()
        look.body = 0xB5642E
        look.belly = 0xF1EAE0
        look.dark = 0x4E3524
        return look
    }

    /// An old grey tabby with white whiskers and a white chest.
    static func catLook() -> Kit.Beast {
        var look = Kit.catLook()
        look.body = 0x8F8E9A
        look.belly = 0xF6F2EC
        look.dark = 0x4C4A58
        look.stripes = true
        look.whiskers = true
        return look
    }

    /// A proud farmyard rooster: gold and rust, dark green-black tail, yellow beak and legs.
    static func roosterLook() -> Kit.Bird {
        var look = Kit.roosterLook()
        look.body = 0xC9742A
        look.belly = 0xE8AE4C
        look.wing = 0x1F3B34
        return look
    }

    // MARK: Small shared marks

    /// An open, singing mouth with a pink tongue, centred on `p` (in the animal's own units).
    static func openMouth(_ context: inout GraphicsContext, at p: CGPoint, size: CGFloat) {
        let outer: Path = Art.ellipse(p.x, p.y, size * 0.82, size)
        Art.fill(&context, outer, Art.color(0x5A2A17))
        let tongue: Path = Art.ellipse(p.x, p.y + size * 0.42, size * 0.5, size * 0.42)
        Art.clipped(&context, to: outer) { g in
            Art.fill(&g, tongue, Art.color(0xF2788A))
        }
    }

    // MARK: The Donkey

    /// The Donkey in side view, facing LEFT, origin on the ground under mid-body (Kit.beast
    /// units: about 200 long and 205 tall to the ear tips). Adds his worn rope halter, the dark
    /// cross on his shoulders and, when `singing`, an open hee-haw mouth. No ground shadow.
    static func donkey(
        _ context: inout GraphicsContext,
        pose: Kit.BeastPose = .stand,
        mood: Kit.BeastMood = .happy,
        look: CGPoint = .zero,
        mirrored: Bool = false,
        singing: Bool = false
    ) {
        let spec: Kit.Beast = donkeyLook()
        let asleep: Bool = pose == .sleep
        let face: Kit.BeastMood = singing ? .surprised : mood
        Kit.beast(&context, spec, pose: pose, mood: face, look: look, mirrored: mirrored)
        let dark: Color = Art.color(spec.dark)
        if pose == .stand || pose == .walk || asleep {
            // The cross: a line along the back and a bar down the shoulder.
            let back: CGPoint = Kit.beastBack(spec, pose: pose)
            var cross = Path()
            cross.move(to: CGPoint(x: back.x - 34, y: back.y + 4))
            cross.addQuadCurve(to: CGPoint(x: back.x + 34, y: back.y + 3), control: CGPoint(x: back.x, y: back.y + 1))
            cross.move(to: CGPoint(x: back.x - 22, y: back.y + 3))
            cross.addQuadCurve(to: CGPoint(x: back.x - 19, y: back.y + 26), control: CGPoint(x: back.x - 23, y: back.y + 14))
            Art.stroke(&context, cross, dark.opacity(0.7), width: 4)
        }
        let head: CGPoint = Kit.beastHeadCentre(spec, pose: pose)
        Art.group(&context, x: head.x, y: head.y) { g in
            // The rope halter: a noseband and a cheek strap.
            let rope: Path = Art.svg("M-31,-4 Q-27,9 -30,22 M-29,5 Q-8,13 15,5")
            Art.stroke(&g, rope, Art.color(ropeHex), width: 2.6)
            let lit: Path = Art.svg("M-31,-3 Q-28,7 -30.5,18")
            Art.stroke(&g, lit, Art.color(0xE8C890, 0.7), width: 0.9)
            // A few white hairs round the eye.
            let hairs: Path = Art.svg("M4,-11 l3,-3 M6,-6 l4,-1 M5,-1 l3,2")
            Art.stroke(&g, hairs, Art.color(0xFFFFFF, 0.75), width: 1)
        }
        if singing && !asleep {
            let mouth: CGPoint = Kit.beastMouth(spec, pose: pose)
            openMouth(&context, at: CGPoint(x: mouth.x - 2, y: mouth.y + 2), size: 6.5)
        }
    }

    // MARK: The Dog

    /// The old hound in side view, facing LEFT (Kit.beast units: about 165 long, 122 tall).
    /// Adds his cracked leather collar; `puffing` lets his tongue hang; `singing` opens his
    /// mouth for a "Woof!". No ground shadow.
    static func dog(
        _ context: inout GraphicsContext,
        pose: Kit.BeastPose = .stand,
        mood: Kit.BeastMood = .happy,
        look: CGPoint = .zero,
        mirrored: Bool = false,
        singing: Bool = false,
        puffing: Bool = false
    ) {
        let spec: Kit.Beast = dogLook()
        let asleep: Bool = pose == .sleep
        let face: Kit.BeastMood = singing ? .surprised : mood
        Kit.beast(&context, spec, pose: pose, mood: face, look: look, mirrored: mirrored)
        let head: CGPoint = Kit.beastHeadCentre(spec, pose: pose)
        if !asleep {
            Art.group(&context, x: head.x, y: head.y) { g in
                let collar: Path = Art.svg("M3,27 Q14,31 27,22")
                Art.stroke(&g, collar, Art.color(0x7A4A2A), width: 4.2)
                Art.stroke(&g, Art.svg("M6,26.5 Q14,29.5 24,22.5"), Art.color(0xA8703E, 0.8), width: 1)
                Art.fill(&g, Art.circle(12, 32, 2.6), Art.color(0xE0B84A))
            }
        }
        let mouth: CGPoint = Kit.beastMouth(spec, pose: pose)
        if singing && !asleep {
            openMouth(&context, at: CGPoint(x: mouth.x - 2, y: mouth.y + 2), size: 6)
        } else if puffing && !asleep {
            let tongue: Path = Art.ellipse(mouth.x - 1, mouth.y + 5.5, 3.4, 5.6)
            Art.fill(&context, tongue, Art.color(0xF2788A))
            Art.stroke(&context, Art.line(mouth.x - 1, mouth.y + 2, mouth.x - 1, mouth.y + 7), Art.color(0xC9566A, 0.7), width: 0.9)
        }
    }

    // MARK: The Cat

    /// The old grey tabby in side view, facing LEFT (Kit.beast units: about 120 long; sitting
    /// she is about 125 tall to the ear tips); `singing` opens her
    /// mouth for a "Miaow!". No ground shadow.
    static func cat(
        _ context: inout GraphicsContext,
        pose: Kit.BeastPose = .sit,
        mood: Kit.BeastMood = .calm,
        look: CGPoint = .zero,
        mirrored: Bool = false,
        singing: Bool = false
    ) {
        let spec: Kit.Beast = catLook()
        let asleep: Bool = pose == .sleep
        let face: Kit.BeastMood = singing ? .surprised : mood
        Kit.beast(&context, spec, pose: pose, mood: face, look: look, mirrored: mirrored)
        if singing && !asleep {
            let mouth: CGPoint = Kit.beastMouth(spec, pose: pose)
            openMouth(&context, at: CGPoint(x: mouth.x - 1, y: mouth.y + 2), size: 4.6)
        }
    }

    // MARK: The Rooster

    /// The Rooster in side view, facing LEFT, feet on the origin (about 60 long, 70 tall).
    /// `crowing` lifts his chest and opens his beak.
    static func rooster(_ context: inout GraphicsContext, crowing: Bool = false, look: CGPoint = .zero, mirrored: Bool = false) {
        let pose: Kit.BirdPose = crowing ? .sing : .perch
        Kit.bird(&context, roosterLook(), pose: pose, look: look, mirrored: mirrored)
    }
}

// MARK: - The tower of four

extension BremenArt {
    /// THE picture of the story: the Donkey standing, the Dog on his back, the Cat on the
    /// Dog, the Rooster on the Cat's head. Drawn facing LEFT with the Donkey's feet on the
    /// origin; about 230 wide (x −131…+95) and 275 tall. A little wobbly, mid-song when
    /// `singing`. Mirror with `Art.group(scaleX: -1)` and pass `mirrored: true`. Draws its own
    /// ground shadow.
    static func tower(_ context: inout GraphicsContext, mirrored: Bool, singing: Bool) {
        let donkeySpec: Kit.Beast = donkeyLook()
        let dogSpec: Kit.Beast = dogLook()
        let catSpec: Kit.Beast = catLook()
        let dogK: CGFloat = 0.62
        let catK: CGFloat = 0.5
        let roosterK: CGFloat = 0.6

        Kit.shadow(&context, 6, 0, width: 170)
        let up = CGPoint(x: -0.5, y: -0.2)
        donkey(&context, pose: .stand, mood: .happy, look: up, mirrored: mirrored, singing: singing)

        let donkeyBack: CGPoint = Kit.beastBack(donkeySpec, pose: .stand)
        let dogX: CGFloat = donkeyBack.x + 4
        let dogY: CGFloat = donkeyBack.y + 5
        ArtStyle.contactShadow(&context, dogX + 6, dogY - 1, 34, 4, alpha: 0.2)
        Art.group(&context, x: dogX, y: dogY, rotate: -0.035, scale: dogK) { g in
            dog(&g, pose: .stand, mood: .happy, look: up, mirrored: mirrored, singing: singing)
        }

        let dogBack: CGPoint = Kit.beastBack(dogSpec, pose: .stand)
        let catX: CGFloat = dogX + dogBack.x * dogK + 2
        let catY: CGFloat = dogY + dogBack.y * dogK + 3
        Art.group(&context, x: catX, y: catY, rotate: 0.04, scale: catK) { g in
            cat(&g, pose: .sit, mood: .happy, look: up, mirrored: mirrored, singing: singing)
        }

        let catHead: CGPoint = Kit.beastHeadCentre(catSpec, pose: .sit)
        let roosterX: CGFloat = catX + catHead.x * catK + 3
        let roosterY: CGFloat = catY + (catHead.y - 27) * catK
        Art.group(&context, x: roosterX, y: roosterY, scale: roosterK) { g in
            rooster(&g, crowing: singing, look: up, mirrored: mirrored)
        }
    }
}

// MARK: - The timber house

extension BremenArt {
    /// The wall width, wall height and roof height of the forest house at scale 1.
    static let houseWidth: CGFloat = 250
    static let houseWall: CGFloat = 190
    static let houseRoof: CGFloat = 90

    /// Where the middle of the house's window is, from (cx, baseY), at scale 1.
    static let windowDX: CGFloat = -87
    static let windowDY: CGFloat = -120

    /// The small-paned window (50 × 60) centred on (x, y): frame, nine panes, a sill; `glow`
    /// 1 lights it warm gold with a candle and a loaf on the table inside.
    static func paneWindow(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, glow: Double) {
        let rect = CGRect(x: x - 25, y: y - 30, width: 50, height: 60)
        if glow > 0 {
            Art.glow(&context, x, y, 120, Art.color(0xFFCB6B), alpha: 0.45 * glow)
        }
        Kit.opening(&context, rect: rect, arched: false, color: timberHex, glow: glow)
        if glow > 0 {
            // Seen through the panes: a plank table, a round loaf, one candle.
            let inside: Path = Art.rect(x - 19, y - 24, 38, 48)
            Art.clipped(&context, to: inside) { g in
                Art.fill(&g, Art.rect(x - 19, y + 12, 38, 12), Art.color(0x8A5A2E, 0.75))
                Art.fill(&g, Art.ellipse(x - 7, y + 10, 8, 5), Art.color(0x7A4A22, 0.85))
                Art.fill(&g, Art.rect(x + 7, y - 1, 3, 13), Art.color(0xFFF6DC))
                Kit.lamp(&g, cx: x + 8.5, cy: y - 6, radius: 2.4, color: 0xFFF1B0)
            }
        }
        // The small panes: two more bars each way over the kit's cross.
        var bars = Path()
        bars.move(to: CGPoint(x: x - 8, y: y - 24))
        bars.addLine(to: CGPoint(x: x - 8, y: y + 24))
        bars.move(to: CGPoint(x: x + 8, y: y - 24))
        bars.addLine(to: CGPoint(x: x + 8, y: y + 24))
        bars.move(to: CGPoint(x: x - 19, y: y - 10))
        bars.addLine(to: CGPoint(x: x + 19, y: y - 10))
        bars.move(to: CGPoint(x: x - 19, y: y + 10))
        bars.addLine(to: CGPoint(x: x + 19, y: y + 10))
        Art.stroke(&context, bars, Art.color(timberHex, 0.85), width: 1.6, cap: .butt)
        let sill: Path = Art.rect(x - 31, y + 29, 62, 7, radius: 2)
        Kit.solid(&context, sill, Art.color(timberHex), light: 0.3, shade: 0.2)
    }

    /// The robbers' house — a small half-timbered forest house, front on, standing on baseY
    /// and centred on cx: dark oak beams, pale plaster, a door in the middle, the small-paned
    /// window in the left bay, a chimney. 250 wide (285 with the eaves) and 280 tall to the
    /// ridge at scale 1. `lit` makes the window glow and throws a warm patch on the ground;
    /// `thatch` gives a thatched roof instead of red tiles; `smoke` lets a thin thread rise.
    static func timberHouse(
        _ context: inout GraphicsContext,
        cx: CGFloat,
        baseY: CGFloat,
        lit: Bool,
        thatch: Bool = false,
        smoke: Bool = false
    ) {
        let top: CGFloat = baseY - houseWall
        let ridge: CGFloat = top - houseRoof
        // The chimney first, behind the roof.
        let stackX: CGFloat = cx + 52
        let stack: Path = Art.rect(stackX - 13, ridge - 30, 26, 80, radius: 2)
        Kit.solid(&context, stack, Art.color(0x9A5A44), light: 0.26, shade: 0.24)
        Art.fill(&context, Art.rect(stackX - 16, ridge - 35, 32, 7, radius: 2), Art.color(0x7A4636))
        if smoke {
            let thread: Path = Art.svg("M0,0 C-10,-22 10,-40 0,-62 C-8,-80 8,-96 2,-118")
            let moved: Path = thread.applying(CGAffineTransform(translationX: stackX, y: ridge - 38))
            Art.stroke(&context, moved, Art.color(0xFFFFFF, 0.5), width: 7)
            Art.stroke(&context, moved, Art.color(0xFFFFFF, 0.35), width: 12)
        }
        let style: Kit.RoofStyle = thatch ? .thatch : .tile
        let roofColor: UInt32 = thatch ? thatchHex : tileHex
        Kit.house(
            &context,
            cx: cx,
            baseY: baseY,
            width: houseWidth,
            wallHeight: houseWall,
            roofHeight: houseRoof,
            wall: plasterHex,
            roof: roofColor,
            style: style,
            door: timberHex,
            windows: 0,
            lit: false,
            timber: timberHex
        )
        // Two more slanted braces in the upper bays, so the frame reads as squares and slants.
        let x1: CGFloat = cx + houseWidth / 2 - 8
        let rail: CGFloat = baseY - houseWall * 0.36
        var braces = Path()
        braces.move(to: CGPoint(x: x1, y: top + 10))
        braces.addLine(to: CGPoint(x: x1 - 66, y: rail))
        braces.move(to: CGPoint(x: cx + 46, y: top + 10))
        braces.addLine(to: CGPoint(x: x1, y: rail))
        Art.stroke(&context, braces, Art.color(timberHex), width: 10, cap: .butt)
        let wx: CGFloat = cx + windowDX
        let wy: CGFloat = baseY + windowDY
        if lit {
            // The warm patch the window throws on the ground.
            Art.group(&context, x: wx - 30, y: baseY + 14, scale: 0.34, scaleX: 3.4) { g in
                Art.glow(&g, 0, 0, 90, Art.color(0xFFCB6B), alpha: 0.6)
            }
        }
        paneWindow(&context, x: wx, y: wy, glow: lit ? 1 : 0)
        // A stone step at the door.
        let step: Path = Art.rect(cx - 36, baseY - 5, 72, 9, radius: 3)
        Kit.solid(&context, step, Art.color(0xB9B2A4), light: 0.26, shade: 0.2)
    }
}

// MARK: - Straw, forest edge, far town

extension BremenArt {
    /// A heap of golden straw sitting on baseY, centred on cx, `width` wide and `height` high.
    static func strawHeap(_ context: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, width: CGFloat, height: CGFloat) {
        let half: CGFloat = width / 2
        Kit.shadow(&context, cx, baseY + 2, width: width * 1.05, alpha: 0.2)
        var heap = Path()
        heap.move(to: CGPoint(x: cx - half, y: baseY + 3))
        heap.addQuadCurve(to: CGPoint(x: cx - half * 0.3, y: baseY - height), control: CGPoint(x: cx - half * 0.86, y: baseY - height * 0.9))
        heap.addQuadCurve(to: CGPoint(x: cx + half * 0.42, y: baseY - height * 0.86), control: CGPoint(x: cx + half * 0.06, y: baseY - height * 1.16))
        heap.addQuadCurve(to: CGPoint(x: cx + half, y: baseY + 3), control: CGPoint(x: cx + half * 0.9, y: baseY - height * 0.7))
        heap.addQuadCurve(to: CGPoint(x: cx - half, y: baseY + 3), control: CGPoint(x: cx, y: baseY + 9))
        heap.closeSubpath()
        let fill: Kit.Stops = [(Art.color(0xF6DA7C), 0), (Art.color(strawHex), 0.5), (Art.color(0xC99A3C), 1)]
        Kit.solid(&context, heap, stops: fill, light: 0.24, shade: 0.2, rim: 2)
        let dark: Path = Kit.builtStraw(cx: cx, topY: baseY - height, topHalf: half * 0.5, bottomY: baseY + 4, bottomHalf: half * 0.98, count: 16, seed: 41)
        let pale: Path = Kit.builtStraw(cx: cx + 4, topY: baseY - height, topHalf: half * 0.4, bottomY: baseY + 4, bottomHalf: half * 0.9, count: 9, seed: 53)
        Art.clipped(&context, to: heap) { g in
            Art.stroke(&g, dark, Art.color(0xA87A2A, 0.6), width: ArtStyle.detailLine)
            Art.stroke(&g, pale, Art.color(0xFFF1B0, 0.7), width: 1.2)
        }
        // Loose stalks sticking out of the heap.
        var stalks = Path()
        let ends: [(CGFloat, CGFloat, CGFloat)] = [(-0.96, -8, -0.1), (-0.6, -14, 0.72), (0.2, -12, 1.04), (0.8, -10, 0.5), (1.0, -6, -0.08)]
        for end in ends {
            let sx: CGFloat = cx + half * end.0 * 0.9
            let sy: CGFloat = baseY - height * max(0, end.2)
            stalks.move(to: CGPoint(x: sx, y: sy))
            stalks.addLine(to: CGPoint(x: sx + end.0 * 14, y: sy + end.1))
        }
        Art.stroke(&context, stalks, Art.color(0xD9AE48), width: 1.6)
    }

    /// The edge of the beech and oak forest from x0 to x1, standing on baseY: two hazy rows of
    /// crowns and a few smooth grey trunks between them. `height` is the taller row.
    static func forestEdge(_ context: inout GraphicsContext, x0: CGFloat, x1: CGFloat, baseY: CGFloat, height: CGFloat, seed: UInt32) {
        guard x1 > x0, height > 0 else { return }
        let span: CGFloat = x1 - x0
        let back: Int = max(3, Int(span / (height * 0.34)))
        Kit.farTrees(&context, x0: x0, x1: x1, baseY: baseY, height: height, count: back, color: Art.color(0x8FA6A2), seed: seed)
        // Smooth grey beech trunks.
        var random = ArtRandom(seed &+ 7)
        let trunks: Int = max(2, Int(span / 70))
        for index in 0..<trunks {
            let t: CGFloat = (CGFloat(index) + 0.3 + Kit.rnd(&random) * 0.4) / CGFloat(trunks)
            let tx: CGFloat = x0 + span * t
            let foot: CGFloat = height * (0.022 + Kit.rnd(&random) * 0.012)
            let trunk = Kit.treeTrunk(tx, baseY + 3, tx + 2, baseY - height * 0.55, foot, foot * 0.6)
            Kit.treeBark(&context, trunk.shape, trunk.edge, 0x8E949A)
        }
        let front: Int = max(3, Int(span / (height * 0.3)))
        Kit.farTrees(&context, x0: x0 - 10, x1: x1 + 10, baseY: baseY + 2, height: height * 0.74, count: front, color: Art.color(0x5F8074), seed: seed &+ 3)
        // The dark of the wood at its foot.
        let gloom: Kit.Stops = [(Art.color(0x3F5E54, 0), 0), (Art.color(0x3F5E54, 0.55), 1)]
        let band: CGFloat = height * 0.16
        Art.fillLinear(&context, Art.rect(x0, baseY - band, span, band + 3), gloom, from: CGPoint(x: 0, y: baseY - band), to: CGPoint(x: 0, y: baseY + 3))
    }

    /// Bremen on the horizon, tiny and pale blue with distance: two church spires and low
    /// roofs, standing on baseY round x. About 90 wide and 34 tall at scale 1.
    static func farTown(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, scale s: CGFloat, color: Color) {
        var town = Path()
        let roofs: [(CGFloat, CGFloat, CGFloat)] = [(-40, 12, 7), (-27, 15, 9), (-10, 13, 8), (6, 16, 10), (22, 12, 8), (35, 14, 7)]
        for roof in roofs {
            let rx: CGFloat = x + roof.0 * s
            let rw: CGFloat = roof.1 * s
            let rh: CGFloat = roof.2 * s
            town.move(to: CGPoint(x: rx - rw / 2, y: baseY))
            town.addLine(to: CGPoint(x: rx - rw / 2, y: baseY - rh * 0.55))
            town.addLine(to: CGPoint(x: rx, y: baseY - rh))
            town.addLine(to: CGPoint(x: rx + rw / 2, y: baseY - rh * 0.55))
            town.addLine(to: CGPoint(x: rx + rw / 2, y: baseY))
            town.closeSubpath()
        }
        let spires: [(CGFloat, CGFloat)] = [(-16, 34), (-4, 30)]
        for spire in spires {
            let sx: CGFloat = x + spire.0 * s
            let sh: CGFloat = spire.1 * s
            let half: CGFloat = 3 * s
            town.move(to: CGPoint(x: sx - half, y: baseY))
            town.addLine(to: CGPoint(x: sx - half, y: baseY - sh * 0.5))
            town.addLine(to: CGPoint(x: sx, y: baseY - sh))
            town.addLine(to: CGPoint(x: sx + half, y: baseY - sh * 0.5))
            town.addLine(to: CGPoint(x: sx + half, y: baseY))
            town.closeSubpath()
        }
        Art.fill(&context, town, color)
        // The silver line of the river beside the town.
        let river: Path = Art.rect(x - 70 * s, baseY - 1.2 * s, 150 * s, 2.4 * s, radius: 1.2 * s)
        Art.fill(&context, river, Art.color(0xF4FAFF, 0.9))
    }

    /// A pollarded willow by a ditch: a short thick trunk and a round mop of thin shoots.
    static func willow(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, height: CGFloat, seed: UInt32) {
        let h: CGFloat = max(1, height)
        let foot: CGFloat = h * 0.1
        Kit.shadow(&context, x, baseY, width: h * 0.7, alpha: 0.18)
        let trunk = Kit.treeTrunk(x, baseY, x, baseY - h * 0.5, foot, foot * 0.9)
        Kit.treeBark(&context, trunk.shape, trunk.edge, 0x7A6A58)
        let blobs: [Kit.Blob] = Kit.treeCrown(x, baseY - h * 0.7, h * 0.4, h * 0.3, count: 6, seed: seed)
        let greens: Kit.Greens = Kit.greens(0x4E7A52, 0x6A9A5E, 0x8DB86A, 0xB4D47E, 0xDDEB9E)
        Kit.canopy(&context, blobs, seed: seed &+ 3, palette: greens, density: 1.4)
    }

    /// A poplar: a tall narrow broadleaf tree.
    static func poplar(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, height: CGFloat, seed: UInt32) {
        Kit.tree(&context, x: x, baseY: baseY, height: height, spread: height * 0.3, palette: Kit.summerGreens(), bark: 0x6B5A48, seed: seed)
    }
}
