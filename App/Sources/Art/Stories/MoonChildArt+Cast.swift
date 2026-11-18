import SwiftUI
import OmramoCore

// The cast and the shared parts of "The Bamboo-Cutter and the Moon-Child": palette, the four
// night lights, the people, the bamboo, the thatched house, the Moon people and Mount Fuji.
// A DARK story: every light here is a night, and each picture has one glowing source.

extension MoonChildArt {
    // MARK: Palette and light

    static let ramp = ArtStyle.Ramp(deep: 0x0F1640, shade: 0x17382C, mid: 0x2F4A8A, light: 0xC9D6F2, glow: 0xFFE08A, accent: 0xE8483F)

    static let inkHex: UInt32 = 0x0A1030
    static let caneFarHex: UInt32 = 0x10282C
    static let caneMidHex: UInt32 = 0x17382C
    static let caneNearHex: UInt32 = 0x1F4A36
    static let hairHex: UInt32 = 0x15131F

    /// Night in the grove: indigo, never black.
    static func night() -> Kit.Light {
        let sky: Kit.Stops = [(Art.color(0x0B1136), 0), (Art.color(0x121A4A), 0.5), (Art.color(0x1A2660), 0.86), (Art.color(0x24316C), 1)]
        return Kit.Light(sky: sky, sun: 0xFFF1C4, glow: 0x34448A, haze: 0x1A2660, far: 0x0F2430, mid: 0x0C1F26, near: 0x08171C, isNight: true)
    }

    /// Deep dusk at the house: a last dull violet low down.
    static func dusk() -> Kit.Light {
        let sky: Kit.Stops = [(Art.color(0x12154A), 0), (Art.color(0x1A1E4E), 0.45), (Art.color(0x2A2F78), 0.82), (Art.color(0x4A3A7C), 1)]
        return Kit.Light(sky: sky, sun: 0xFFF1C4, glow: 0x5A4486, haze: 0x2A2F78, far: 0x101C2C, mid: 0x0C1824, near: 0x08121C, isNight: true)
    }

    /// The night of the full moon: a deep, clear blue.
    static func moonNight() -> Kit.Light {
        let sky: Kit.Stops = [(Art.color(0x0C1238), 0), (Art.color(0x0F1640), 0.4), (Art.color(0x1C2A68), 0.84), (Art.color(0x27357A), 1)]
        return Kit.Light(sky: sky, sun: 0xFFF6DC, glow: 0x3A4C96, haze: 0x1C2A68, far: 0x131A3C, mid: 0x0F1634, near: 0x0A102A, isNight: true)
    }

    /// Deep blue just before dawn.
    static func beforeDawn() -> Kit.Light {
        let sky: Kit.Stops = [(Art.color(0x0E173F), 0), (Art.color(0x101A44), 0.4), (Art.color(0x1F3460), 0.84), (Art.color(0x2F4A7C), 1)]
        return Kit.Light(sky: sky, sun: 0xE9EEF8, glow: 0x40608E, haze: 0x1F3460, far: 0x1A2A52, mid: 0x16233F, near: 0x0E1830, isNight: true)
    }

    // MARK: Looks

    static func cutterLook() -> Kit.Person {
        Kit.Person(
            age: .elder, skin: 0xD9A77C, hair: 0xF2F0EA, hairStyle: .topknot, beard: .short,
            garment: .tunic, cloth: 0x5F7388, trim: 0x3D4C5E, legs: 0x4A5A6C, showsEyeWhite: false
        )
    }

    /// Her head only: the robes and the floor-length hair are drawn by `kaguya`.
    static func kaguyaLook() -> Kit.Person {
        Kit.Person(
            age: .adult, skin: 0xF6DEC6, hair: 0x15131F, hairStyle: .short,
            garment: .robe, cloth: 0xF3DFA0, trim: 0x9DB6E6, legs: 0xFBF6EA, showsEyeWhite: false
        )
    }

    static func childLook() -> Kit.Person {
        Kit.Person(
            age: .child, skin: 0xF8E2CC, hair: 0x15131F, hairStyle: .bob,
            garment: .robe, cloth: 0xF7E7A8, trim: 0x9DB6E6, legs: 0xFBF6EA, showsEyeWhite: false
        )
    }

    static func emperorLook() -> Kit.Person {
        Kit.Person(
            age: .adult, skin: 0xEBC9A4, hair: 0x17141F, hairStyle: .short,
            garment: .robe, cloth: 0x5A2E86, trim: 0x8C6AC0, legs: 0xD8D2E4, showsEyeWhite: false
        )
    }

    static func archerLook() -> Kit.Person {
        Kit.Person(
            age: .adult, skin: 0xD8AE86, hair: 0x17141F, hairStyle: .short,
            garment: .tunic, cloth: 0x3A4E7E, trim: 0x7A3A3A, legs: 0x2A3558, showsEyeWhite: false
        )
    }

    // MARK: Spaces

    /// The far plane of an unfolded scene: `body` draws in units where the horizon is `st.H`
    /// and x 892 is the trailing edge; everything is scaled by `st.far` about (892, horizon).
    static func farSpace(_ context: inout GraphicsContext, _ st: Kit.Stage, _ body: (inout GraphicsContext) -> Void) {
        let s: CGFloat = st.far
        Art.group(&context, x: 892 * (1 - s), y: st.H * (1 - s), scale: s, body)
    }

    // MARK: Bamboo

    /// One cane of timber bamboo from `baseY` up to `top`, with its rings. `glow` above 0 adds
    /// a gold lit edge on the side `glowSide` (−1 left, +1 right) for the lowest `reach` units.
    static func cane(
        _ context: inout GraphicsContext,
        x: CGFloat,
        baseY: CGFloat,
        top: CGFloat,
        half: CGFloat,
        tone: UInt32,
        lean: CGFloat = 0,
        glowSide: CGFloat = 0,
        glow: Double = 0,
        reach: CGFloat = 260,
        seed: UInt32 = 1
    ) {
        guard baseY > top, half > 0 else { return }
        var random = ArtRandom(seed)
        let rise: CGFloat = baseY - top
        let topX: CGFloat = x + lean
        let topHalf: CGFloat = half * 0.9
        var body = Path()
        body.move(to: Kit.pt(x - half, baseY))
        body.addLine(to: Kit.pt(topX - topHalf, top))
        body.addLine(to: Kit.pt(topX + topHalf, top))
        body.addLine(to: Kit.pt(x + half, baseY))
        body.closeSubpath()
        Art.fill(&context, body, Art.color(tone))
        var side = Path()
        side.move(to: Kit.pt(x + half * 0.25, baseY))
        side.addLine(to: Kit.pt(topX + topHalf * 0.25, top))
        side.addLine(to: Kit.pt(topX + topHalf, top))
        side.addLine(to: Kit.pt(x + half, baseY))
        side.closeSubpath()
        Art.fill(&context, side, Art.color(inkHex, 0.32))
        // The rings.
        var rings = Path()
        var pale = Path()
        var y: CGFloat = baseY - half * (2 + Kit.rnd(&random) * 2)
        var guardCount: Int = 0
        while y > top && guardCount < 60 {
            let t: CGFloat = (baseY - y) / rise
            let cx: CGFloat = x + lean * t
            let hw: CGFloat = Kit.mix(half, topHalf, t)
            rings.move(to: Kit.pt(cx - hw, y))
            rings.addLine(to: Kit.pt(cx + hw, y))
            pale.move(to: Kit.pt(cx - hw, y + 1.6))
            pale.addLine(to: Kit.pt(cx + hw * 0.2, y + 1.6))
            let span: CGFloat = max(14, half * (5 + Kit.rnd(&random) * 2.5))
            y -= span
            guardCount += 1
        }
        Art.stroke(&context, rings, Art.color(inkHex, 0.6), width: max(1, half * 0.2), cap: .butt)
        Art.stroke(&context, pale, Art.color(0xA8C8B0, 0.16), width: max(0.8, half * 0.14), cap: .butt)
        // The cool night light on the upper-left side.
        let sheen = Art.line(x - half * 0.5, baseY, topX - topHalf * 0.5, top)
        Art.stroke(&context, sheen, Art.color(0xA8C8D8, 0.14), width: max(1, half * 0.3), cap: .butt)
        if glow > 0 {
            let upTo: CGFloat = min(1, reach / rise)
            let gx0: CGFloat = x + glowSide * half * 0.62
            let gx1: CGFloat = x + lean * upTo + glowSide * half * 0.62
            let lit = Art.line(gx0, baseY, gx1, baseY - rise * upTo)
            Art.stroke(&context, lit, ramp.glowColor.opacity(glow), width: max(1.2, half * 0.42), cap: .butt)
        }
    }

    /// A rank of canes between `x0` and `x1`.
    static func caneRank(
        _ context: inout GraphicsContext,
        x0: CGFloat,
        x1: CGFloat,
        baseY: CGFloat,
        top: CGFloat,
        count: Int,
        half: CGFloat,
        tone: UInt32,
        seed: UInt32
    ) {
        guard count > 0, x1 > x0 else { return }
        var random = ArtRandom(seed)
        let gap: CGFloat = (x1 - x0) / CGFloat(count)
        for i in 0..<count {
            let jitter: CGFloat = (Kit.rnd(&random) - 0.5) * gap * 0.7
            let cx: CGFloat = x0 + gap * (CGFloat(i) + 0.5) + jitter
            let width: CGFloat = half * (0.7 + Kit.rnd(&random) * 0.6)
            let lean: CGFloat = (Kit.rnd(&random) - 0.5) * 30
            let drop: CGFloat = Kit.rnd(&random) * 14
            let caneSeed: UInt32 = seed &+ UInt32(i) &* 7 &+ 3
            cane(&context, x: cx, baseY: baseY + drop, top: top, half: width, tone: tone, lean: lean, seed: caneSeed)
        }
    }

    /// One narrow leaf from (ax, ay) to (bx, by), added to `path`.
    static func leaf(_ path: inout Path, _ ax: CGFloat, _ ay: CGFloat, _ bx: CGFloat, _ by: CGFloat, _ wide: CGFloat) {
        let mx: CGFloat = (ax + bx) / 2
        let my: CGFloat = (ay + by) / 2
        let dx: CGFloat = bx - ax
        let dy: CGFloat = by - ay
        let square: CGFloat = dx * dx + dy * dy
        let length: CGFloat = max(0.001, square.squareRoot())
        let nx: CGFloat = -dy / length * wide
        let ny: CGFloat = dx / length * wide
        path.move(to: CGPoint(x: ax, y: ay))
        path.addQuadCurve(to: CGPoint(x: bx, y: by), control: CGPoint(x: mx + nx, y: my + ny))
        path.addQuadCurve(to: CGPoint(x: ax, y: ay), control: CGPoint(x: mx - nx, y: my - ny))
        path.closeSubpath()
    }

    /// A feathery spray of bamboo leaves fanning out from (x, y) and drooping.
    static func leafSpray(
        _ context: inout GraphicsContext,
        x: CGFloat,
        y: CGFloat,
        reach: CGFloat,
        count: Int,
        color: Color,
        seed: UInt32,
        droop: CGFloat = 0.5
    ) {
        var random = ArtRandom(seed)
        var leaves = Path()
        for _ in 0..<max(0, count) {
            let turn: CGFloat = Kit.deg(-200 + Kit.rnd(&random) * 220)
            let start: CGFloat = Kit.rnd(&random) * reach * 0.6
            let length: CGFloat = reach * (0.3 + Kit.rnd(&random) * 0.4)
            let ax: CGFloat = x + cos(turn) * start
            let ay: CGFloat = y + sin(turn) * start * 0.5
            let bx: CGFloat = ax + cos(turn) * length
            let by: CGFloat = ay + sin(turn) * length * 0.4 + length * droop
            leaf(&leaves, ax, ay, bx, by, length * 0.11)
        }
        Art.fill(&context, leaves, color)
    }

    /// Fallen leaves and small tufts over the ground from `top` to the bottom edge, larger
    /// toward the viewer, so a deep foreground is never empty.
    static func floorLitter(_ context: inout GraphicsContext, _ size: CGSize, top: CGFloat, color: Color, seed: UInt32) {
        let depth: CGFloat = size.height - top
        guard depth > 20 else { return }
        var random = ArtRandom(seed)
        let count: Int = min(150, Int(depth * 0.5))
        var leaves = Path()
        var tufts = Path()
        for i in 0..<count {
            let t: CGFloat = Kit.rnd(&random)
            let y: CGFloat = top + 8 + (depth - 12) * t
            let x: CGFloat = size.width * Kit.rnd(&random)
            let s: CGFloat = 5 + 9 * t
            let tilt: CGFloat = (Kit.rnd(&random) - 0.5) * s
            if i % 4 == 0 {
                tufts.move(to: CGPoint(x: x, y: y))
                tufts.addQuadCurve(to: CGPoint(x: x - s * 0.6, y: y - s * 1.3), control: CGPoint(x: x - s * 0.1, y: y - s))
                tufts.move(to: CGPoint(x: x + 2, y: y))
                tufts.addQuadCurve(to: CGPoint(x: x + s * 0.7, y: y - s * 1.1), control: CGPoint(x: x + s * 0.2, y: y - s))
            } else {
                leaf(&leaves, x - s, y + tilt * 0.3, x + s, y - tilt * 0.3, s * 0.22)
            }
        }
        Art.fill(&context, leaves, color.opacity(0.5))
        Art.stroke(&context, tufts, color.opacity(0.7), width: 1.4)
    }
}

// MARK: - The shining stem and the people

extension MoonChildArt {
    /// The one stem that shines, standing on (0, 0) and rising `height`: lit gold from inside
    /// between `from` and `to` units above the ground, like a lamp through paper.
    static func shiningCane(_ context: inout GraphicsContext, half: CGFloat, height: CGFloat, from: CGFloat, to: CGFloat) {
        guard to > from else { return }
        let middle: CGFloat = -(from + to) / 2
        Art.glow(&context, 0, middle, (to - from) * 1.5, ramp.glowColor, alpha: 0.42)
        cane(&context, x: 0, baseY: 0, top: -height, half: half, tone: 0x2A5A3A, seed: 5)
        let lit = Art.rect(-half, -to, half * 2, to - from, radius: half * 0.3)
        let along: Kit.Stops = [
            (Art.color(0x86A856), 0), (Art.color(0xFFE08A), 0.26), (Art.color(0xFFF6C8), 0.5),
            (Art.color(0xFFE08A), 0.74), (Art.color(0x86A856), 1),
        ]
        Art.fillLinear(&context, lit, along, from: CGPoint(x: 0, y: -to), to: CGPoint(x: 0, y: -from))
        let across: Kit.Stops = [
            (Art.color(0x3A6A3A, 0.6), 0), (Art.color(0x3A6A3A, 0), 0.36),
            (Art.color(0x3A6A3A, 0), 0.64), (Art.color(0x3A6A3A, 0.6), 1),
        ]
        Art.fillLinear(&context, lit, across, from: CGPoint(x: -half, y: 0), to: CGPoint(x: half, y: 0))
        var rings = Path()
        rings.move(to: Kit.pt(-half, -to))
        rings.addLine(to: Kit.pt(half, -to))
        rings.move(to: Kit.pt(-half, middle))
        rings.addLine(to: Kit.pt(half, middle))
        rings.move(to: Kit.pt(-half, -from))
        rings.addLine(to: Kit.pt(half, -from))
        Art.stroke(&context, rings, Art.color(0x3E6A30, 0.75), width: max(1.2, half * 0.2), cap: .butt)
        Art.glow(&context, 0, middle, (to - from) * 0.8, Art.color(0xFFF6C8), alpha: 0.3)
    }

    /// The tiny girl, sitting: origin under her, about 100 units tall, looking up to the right.
    static func moonChild(_ context: inout GraphicsContext) {
        Art.glow(&context, 0, -50, 96, Art.color(0xFFF8D8), alpha: 0.5)
        let robe = Art.svg("M-30,0 C-32,-32 -17,-54 0,-54 C17,-54 32,-32 30,0Z")
        let cloth: Kit.Stops = [(Art.color(0xFFF6CE), 0), (Art.color(0xF2DC96), 1)]
        Kit.solid(&context, robe, stops: cloth, light: 0.16, shade: 0.14)
        Art.fill(&context, Art.svg("M-9,-54 L0,-38 L9,-54Z"), Art.color(0xFFFFFF, 0.95))
        Art.stroke(&context, Art.svg("M-10,-54 L0,-37 L10,-54"), Art.color(0x9DB6E6), width: 3)
        Art.stroke(&context, Art.svg("M-12,-26 C-6,-20 6,-20 12,-26"), Art.color(0xD9BF74), width: 1.6)
        Art.fill(&context, Art.ellipse(0, -24, 7, 4.5), Art.color(0xF8E2CC))
        Art.group(&context, x: 0, y: -74) { h in
            Kit.personHead(&h, childLook(), look: CGPoint(x: 0.6, y: -0.7), mouth: .smile)
        }
    }

    /// The stem cut open, standing on (0, 0): 40 wide, the front cut 62 above the ground and
    /// the back wall rising behind the tiny girl who sits in the hollow. About 112 tall.
    static func cutStem(_ context: inout GraphicsContext) {
        Art.glow(&context, 0, -84, 130, ramp.glowColor, alpha: 0.5)
        let back = Art.svg("M-20,-60 L-20,-96 C-14,-108 8,-113 20,-101 L20,-60Z")
        let inner: Kit.Stops = [(Art.color(0xFFF6CC), 0), (Art.color(0xF2CE6A), 1)]
        Art.fillLinear(&context, back, inner, from: CGPoint(x: 0, y: -112), to: CGPoint(x: 0, y: -60))
        Art.stroke(&context, Art.svg("M-20,-96 C-14,-108 8,-113 20,-101"), Art.color(0x4E8A4A), width: 2.6)
        Art.fill(&context, Art.ellipse(0, -61, 20, 6), Art.color(0xFFF8D8))
        Art.group(&context, x: 0, y: -60, scale: 0.4) { c in
            moonChild(&c)
        }
        let front = Art.svg("M-20,0 L-20,-62 C-10,-55 10,-55 20,-62 L20,0Z")
        let wall: Kit.Stops = [(Art.color(0xE4D07A), 0), (Art.color(0x6E9A4E), 0.3), (Art.color(0x2A5A3A), 1)]
        Art.fillLinear(&context, front, wall, from: CGPoint(x: 0, y: -62), to: CGPoint(x: 0, y: 0))
        Art.clipped(&context, to: front) { g in
            Art.fill(&g, Art.rect(6, -64, 16, 66), Art.color(inkHex, 0.3))
            Art.stroke(&g, Art.line(-20, -28, 20, -28), Art.color(inkHex, 0.55), width: 2.2, cap: .butt)
            Art.stroke(&g, Art.line(-20, -25.6, 4, -25.6), Art.color(0xC8E0A8, 0.3), width: 1.2, cap: .butt)
            Art.stroke(&g, Art.line(-15, -60, -15, 0), Art.color(0xE8F0B8, 0.22), width: 4, cap: .butt)
        }
        Art.stroke(&context, Art.svg("M-20,-62 C-10,-55 10,-55 20,-62"), Art.color(0xFFF6C8), width: 2)
    }

    /// The short, broad cutting knife (nata): the grip at the origin, the blade to the left.
    static func nata(_ context: inout GraphicsContext) {
        Art.stroke(&context, Art.line(9, 0, -6, 0), Art.color(0x8A6238), width: 5)
        let blade = Art.svg("M-6,-5 L-32,-6 Q-36,-1 -32,5 L-6,4Z")
        Kit.solid(&context, blade, Art.color(0xAAB6CC), light: 0.3, shade: 0.25)
        Art.stroke(&context, Art.line(-8, 4, -31, 4.6), Art.color(0xF0F4FA, 0.8), width: 1)
    }

    /// The old Bamboo-Cutter, feet at the origin, facing LEFT, his knife in his leading hand.
    static func cutter(
        _ context: inout GraphicsContext,
        pose: Kit.Pose,
        look: CGPoint = .zero,
        mouth: Kit.Mouth = .smile,
        knife: Bool = true
    ) {
        let p = cutterLook()
        Kit.person(&context, p, pose: pose, look: look, mouth: mouth)
        if knife {
            let h = Kit.hand(p, pose: pose)
            Art.group(&context, x: h.x, y: h.y, rotate: Kit.deg(-24)) { k in
                nata(&k)
            }
        }
    }

    /// The two locks that fall beside Kaguya-hime's face, in head units.
    static func kaguyaLocks(_ context: inout GraphicsContext) {
        var locks = Path()
        locks.addPath(Art.svg("M-27,-12 C-31,4 -30,24 -26,40 C-22.5,26 -22.5,6 -23.5,-12Z"))
        locks.addPath(Art.svg("M27,-12 C31,4 30,24 26,40 C22.5,26 22.5,6 23.5,-12Z"))
        Art.fill(&context, locks, Art.color(hairHex))
        Art.stroke(&context, Art.line(0, -34, -0.5, -21.5), Art.color(0x3A3852), width: 1)
    }

    /// Her hair down her back to the floor. `drop` is the height of her shoulders.
    static func kaguyaHair(_ context: inout GraphicsContext, drop: CGFloat, train: CGFloat) {
        var hair = Path()
        hair.move(to: Kit.pt(-6, -drop - 44))
        hair.addCurve(to: Kit.pt(30, -drop * 0.5), control1: Kit.pt(30, -drop - 46), control2: Kit.pt(24, -drop * 0.85))
        hair.addQuadCurve(to: Kit.pt(train + 14, 0), control: Kit.pt(36, -4))
        hair.addLine(to: Kit.pt(train - 26, 0))
        hair.addQuadCurve(to: Kit.pt(6, -drop + 4), control: Kit.pt(16, -drop * 0.4))
        hair.closeSubpath()
        let tone: Kit.Stops = [(Art.color(hairHex), 0), (Art.color(0x24213A), 1)]
        Art.fillLinear(&context, hair, tone, from: CGPoint(x: 0, y: -drop - 40), to: CGPoint(x: train, y: 0))
        var sheen = Path()
        sheen.move(to: Kit.pt(23, -drop - 16))
        sheen.addQuadCurve(to: Kit.pt(29, -drop * 0.5), control: Kit.pt(28, -drop * 0.8))
        sheen.addQuadCurve(to: Kit.pt(train, -3), control: Kit.pt(36, -8))
        Art.stroke(&context, sheen, Art.color(0x6A70A0, 0.5), width: 1.4)
    }

    /// Kaguya-hime in her layered court robes, the ground under her at the origin, facing
    /// LEFT, her hair and train to the right. Standing she is 166 tall, seated about 120.
    static func kaguya(_ context: inout GraphicsContext, seated: Bool = false, look: CGPoint = .zero, mouth: Kit.Mouth = .smile) {
        let drop: CGFloat = seated ? 64 : 110
        let train: CGFloat = seated ? 88 : 66
        let front: CGFloat = seated ? -52 : -36
        var robe = Path()
        robe.move(to: Kit.pt(-19, -drop))
        robe.addQuadCurve(to: Kit.pt(front, 0), control: Kit.pt(front - 4, -drop * 0.5))
        robe.addLine(to: Kit.pt(train, 0))
        robe.addQuadCurve(to: Kit.pt(19, -drop), control: Kit.pt(32, -drop * 0.4))
        robe.closeSubpath()
        let cloth: Kit.Stops = [(Art.color(0xFBEFC2), 0), (Art.color(0xEFD890), 0.6), (Art.color(0xCDB98A), 1)]
        Kit.solid(&context, robe, stops: cloth, light: 0.18, shade: 0.2)
        var fold = Path()
        fold.move(to: Kit.pt(4, -drop * 0.8))
        fold.addQuadCurve(to: Kit.pt(train * 0.45, -15), control: Kit.pt(10, -drop * 0.3))
        fold.move(to: Kit.pt(-8, -drop * 0.42))
        fold.addQuadCurve(to: Kit.pt(front * 0.5, -15), control: Kit.pt(-12, -drop * 0.2))
        let folds = fold
        let outline = robe
        Art.clipped(&context, to: outline) { g in
            Art.stroke(&g, folds, Art.color(0xC2A766, 0.7), width: ArtStyle.detailLine)
            Art.stroke(&g, Art.line(front - 10, -2, train + 10, -2), Art.color(0xFFFFFF, 0.95), width: 4, cap: .butt)
            Art.stroke(&g, Art.line(front - 10, -6.5, train + 10, -6.5), Art.color(0x9DB6E6), width: 4.5, cap: .butt)
            Art.stroke(&g, Art.line(front - 10, -11, train + 10, -11), Art.color(0xE7A9A2), width: 3.5, cap: .butt)
        }
        kaguyaHair(&context, drop: drop, train: train)
        // The wide near sleeve, with the layers showing at its opening.
        let fall: CGFloat = seated ? 58 : 64
        var sleeve = Path()
        sleeve.move(to: Kit.pt(-17, -drop + 4))
        sleeve.addCurve(to: Kit.pt(front - 2, -drop + fall), control1: Kit.pt(-30, -drop + 8), control2: Kit.pt(front - 6, -drop + fall * 0.5))
        sleeve.addLine(to: Kit.pt(-8, -drop + fall + 4))
        sleeve.addQuadCurve(to: Kit.pt(-4, -drop + 8), control: Kit.pt(-2, -drop + fall * 0.5))
        sleeve.closeSubpath()
        Kit.solid(&context, sleeve, Art.color(0xF9EBB6), light: 0.2, shade: 0.16)
        let cuff = sleeve
        let cuffY: CGFloat = -drop + fall
        Art.clipped(&context, to: cuff) { g in
            Art.stroke(&g, Art.line(front - 6, cuffY - 1, -4, cuffY + 3), Art.color(0xFFFFFF, 0.95), width: 3.4, cap: .butt)
            Art.stroke(&g, Art.line(front - 6, cuffY - 5, -4, cuffY - 1), Art.color(0x9DB6E6), width: 3.6, cap: .butt)
            Art.stroke(&g, Art.line(front - 6, cuffY - 9, -4, cuffY - 5), Art.color(0xE7A9A2), width: 3, cap: .butt)
        }
        // Neck and the layered collar.
        Art.fill(&context, Art.rect(-5.5, -drop - 9, 11, 13, radius: 4), Kit.personTone(0xF6DEC6, 0.9))
        let collar: Path = Art.polygon([Kit.pt(-11, -drop - 1), Kit.pt(0, -drop + 18), Kit.pt(11, -drop - 1)])
        Art.fill(&context, collar, Art.color(0xFFFFFF, 0.95))
        let band: Path = Art.polygon([Kit.pt(-12, -drop - 1), Kit.pt(0, -drop + 19), Kit.pt(12, -drop - 1)], closed: false)
        Art.stroke(&context, band, Art.color(0x9DB6E6), width: 3.2)
        let inner: Path = Art.polygon([Kit.pt(-7, -drop - 1), Kit.pt(0, -drop + 10), Kit.pt(7, -drop - 1)], closed: false)
        Art.stroke(&context, inner, Art.color(0xE7A9A2), width: 2)
        Art.group(&context, x: -1, y: -drop - 28) { h in
            Kit.personHead(&h, kaguyaLook(), look: look, mouth: mouth)
            kaguyaLocks(&h)
        }
    }

    /// Kaguya-hime head and shoulders for the portrait: origin at the centre of her head, the
    /// body running down to y +150.
    static func kaguyaBust(_ context: inout GraphicsContext, look: CGPoint = .zero) {
        let back = Art.svg("M-34,-12 C-37,-42 -16,-40 0,-40 C16,-40 37,-42 34,-12 C40,40 48,100 56,150 L-56,150 C-48,100 -40,40 -34,-12Z")
        Art.fill(&context, back, Art.color(hairHex))
        Art.fill(&context, Art.rect(-12, 12, 24, 38, radius: 8), Kit.personTone(0xF6DEC6, 0.9))
        let shoulders = Art.svg("M-74,150 L-66,66 C-62,46 -40,36 -14,34 L14,34 C40,36 62,46 66,66 L74,150Z")
        let cloth: Kit.Stops = [(Art.color(0xFBEFC2), 0), (Art.color(0xEAD48C), 1)]
        Kit.solid(&context, shoulders, stops: cloth, light: 0.2, shade: 0.2)
        Art.clipped(&context, to: shoulders) { g in
            Art.fill(&g, Art.svg("M-23,34 L0,86 L23,34Z"), Art.color(0xFFFFFF, 0.95))
            Art.stroke(&g, Art.svg("M-24,33 L0,88 L24,33"), Art.color(0x9DB6E6), width: 7)
            Art.stroke(&g, Art.svg("M-15,33 L0,68 L15,33"), Art.color(0xE7A9A2), width: 4.5)
            Art.fill(&g, Art.svg("M-9,33 L0,54 L9,33Z"), Art.color(0xF6DEC6))
            Art.stroke(&g, Art.svg("M-44,70 C-48,96 -50,124 -50,150 M44,70 C48,96 50,124 50,150"), Art.color(0xC2A766, 0.7), width: ArtStyle.contourLine)
        }
        var strands = Path()
        strands.addPath(Art.svg("M-29,-6 C-35,30 -39,90 -43,150 L-30,150 C-28,92 -26,40 -24.5,6Z"))
        strands.addPath(Art.svg("M29,-6 C35,30 39,90 43,150 L30,150 C28,92 26,40 24.5,6Z"))
        Art.fill(&context, strands, Art.color(hairHex))
        Art.stroke(&context, Art.svg("M-33,40 C-36,80 -38,116 -40,150 M33,40 C36,80 38,116 40,150"), Art.color(0x6A70A0, 0.45), width: 1.4)
        Kit.personHead(&context, kaguyaLook(), look: look, mouth: .smile)
        kaguyaLocks(&context)
    }

    /// The tall black lacquered court cap, in head units (drawn over a head).
    static func courtCap(_ context: inout GraphicsContext) {
        let tone = Art.color(0x14121C)
        Art.stroke(&context, Art.svg("M10,-46 C24,-58 33,-46 31,-26"), tone, width: 5)
        Art.fill(&context, Art.rect(2, -56, 13, 30, radius: 5), tone)
        Art.fill(&context, Art.svg("M-25,-17 C-26,-33 -12,-37 0,-37 C12,-37 26,-33 25,-17 C14,-23 -14,-23 -25,-17Z"), tone)
        Art.stroke(&context, Art.svg("M-20,-28 C-12,-34 -4,-35.5 4,-35.5"), Art.color(0x7A80B0, 0.6), width: 1.4)
        Art.stroke(&context, Art.line(4.5, -52, 4.5, -32), Art.color(0x7A80B0, 0.5), width: 1.2)
    }

    /// A guard's soft black cap, in head units.
    static func softCap(_ context: inout GraphicsContext) {
        let shape = Art.svg("M-25,-16 C-28,-40 -8,-50 6,-48 C20,-46 28,-32 25,-16 C14,-23 -14,-23 -25,-16Z")
        Art.fill(&context, shape, Art.color(0x1A1826))
        Art.stroke(&context, Art.svg("M-20,-30 C-14,-40 -4,-45 6,-45"), Art.color(0x7A80B0, 0.5), width: 1.4)
    }

    /// A lord of the court waiting at the fence: wide-sleeved robe and the tall black cap.
    static func lord(_ context: inout GraphicsContext, cloth: UInt32) {
        var p = emperorLook()
        p.cloth = cloth
        p.trim = Kit.personToneHex(cloth, 1.4)
        Kit.person(&context, p, pose: .stand, mouth: .flat)
        Art.group(&context, x: 0, y: -140) { h in
            courtCap(&h)
        }
    }

    /// One of the Emperor's archers, astonished, his long bow hanging slack (`slack` radians).
    static func archer(_ context: inout GraphicsContext, slack: CGFloat) {
        let p = archerLook()
        Art.stroke(&context, Art.line(13, -114, 24, -76), Art.color(0x5A3A2A), width: 7)
        Art.stroke(&context, Art.svg("M12,-114 L8,-128 M14,-115 L14,-130 M16,-114 L20,-127"), Art.color(0xD8D2C0, 0.8), width: 1.2)
        Kit.person(&context, p, pose: .stand, look: CGPoint(x: 0.3, y: -0.9), mouth: .oh)
        Art.group(&context, x: 0, y: -140) { h in
            softCap(&h)
        }
        let grip = Kit.hand(p, pose: .stand)
        Art.group(&context, x: grip.x, y: grip.y, rotate: slack) { b in
            Art.stroke(&b, Art.svg("M0,-76 C-14,-50 -12,-10 0,0 C-10,12 -10,38 2,54"), Art.color(0x8A5A34), width: 3)
            Art.stroke(&b, Art.line(0, -76, 2, 54), Art.color(0xE9E4D2, 0.55), width: 0.8)
        }
    }
}

// MARK: - The Moon people, the house, the lane and the mountain

extension MoonChildArt {
    /// One of the Moon people: a tall, calm, robed figure in pale silver-gold, feet at the
    /// origin, about 160 × `tall` high. Little detail, no wings, no halo.
    static func moonPerson(_ context: inout GraphicsContext, tall: CGFloat) {
        Art.group(&context, scale: tall) { g in
            let robe = Art.svg("M-12,-120 C-30,-104 -35,-40 -31,0 L31,0 C35,-40 30,-104 12,-120Z")
            let pale: Kit.Stops = [(Art.color(0xFFFBE8), 0), (Art.color(0xF3E6B8), 0.55), (Art.color(0xC9D6F2), 1)]
            Kit.solid(&g, robe, stops: pale, light: 0.14, shade: 0.16)
            let folds = Art.svg("M-18,-98 C-25,-72 -23,-52 -14,-42 M17,-98 C23,-72 21,-52 12,-42 M-6,-40 C-8,-24 -8,-12 -7,0 M8,-40 C10,-24 10,-12 9,0")
            Art.stroke(&g, folds, Art.color(0xB9A86A, 0.5), width: 1.6)
            Art.fill(&g, Art.ellipse(0, -62, 8, 5), Art.color(0xFFF1DA))
            Art.fill(&g, Art.rect(-4.5, -128, 9, 12, radius: 3), Art.color(0xF2DFC2))
            Art.fill(&g, Art.circle(0, -138, 15), Art.color(0xFFF1DA))
            Art.fill(&g, Art.ellipse(0, -158, 6, 7), Art.color(0x8E9AC8))
            Art.fill(&g, Art.svg("M-15.5,-139 C-16,-156 16,-156 15.5,-139 C8,-148 -8,-148 -15.5,-139Z"), Art.color(0x8E9AC8))
            Art.stroke(&g, Art.svg("M-8,-135 q3,2.2 6,0 M2,-135 q3,2.2 6,0"), Art.color(0x6A5A48, 0.7), width: 1.3)
            ArtStyle.rimLight(&g, 0, -138, 15, alpha: 0.3)
        }
    }

    /// The low bank of shining cloud: the origin is the middle of its top, where the Moon
    /// people stand. `trail` is where its wake leads back to (the Moon), from the origin.
    static func moonCloud(_ context: inout GraphicsContext, width w: CGFloat, trail: CGPoint) {
        var wake = Path()
        wake.move(to: Kit.pt(w * 0.3, 6))
        wake.addQuadCurve(to: trail, control: Kit.pt(trail.x * 0.45, 14))
        Art.stroke(&context, wake, Art.color(0xFFF6D8, 0.16), width: 22)
        Art.stroke(&context, wake, Art.color(0xFFF6D8, 0.2), width: 8)
        Art.glow(&context, 0, 4, w * 0.8, Art.color(0xFFF3C8), alpha: 0.4)
        let puffs: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
            (-0.42, 8, 0.16, 12), (-0.2, 3, 0.2, 16), (0.04, 5, 0.22, 17),
            (0.28, 3, 0.18, 14), (0.44, 9, 0.12, 9), (0, 15, 0.46, 12),
        ]
        var bank = Path()
        for puff in puffs {
            let px: CGFloat = (puff.0 - puff.2) * w
            let py: CGFloat = puff.1 - puff.3
            bank.addEllipse(in: CGRect(x: px, y: py, width: puff.2 * 2 * w, height: puff.3 * 2))
        }
        let tone: Kit.Stops = [(Art.color(0xFFFCEC), 0), (Art.color(0xF2E8C2), 0.5), (Art.color(0xC9D6F2), 1)]
        Art.fillLinear(&context, bank, tone, from: CGPoint(x: 0, y: -14), to: CGPoint(x: 0, y: 28))
        let shape = bank
        Art.clipped(&context, to: shape) { g in
            Art.glow(&g, -w * 0.2, -8, w * 0.36, Color.white, alpha: 0.5)
        }
    }

    /// How high the ridge of `thatchHouse` is above its ground.
    static let houseRidge: CGFloat = 198

    /// The thatched country house: the ground under the middle of its front at the origin, the
    /// wall 280 wide on a narrow raised porch, the roof 356 wide. Its doors stand open and
    /// pale light pours out; `glow` 0…1 is how strong (1 is "as if a moon were inside").
    static func thatchHouse(_ context: inout GraphicsContext, glow: Double) {
        Art.glow(&context, 0, -60, 250, Art.color(0xFFF0C0), alpha: 0.3 * glow)
        // Porch posts and the porch.
        var stilts = Path()
        let stiltX: [CGFloat] = [-136, -68, 0, 68, 136]
        for x in stiltX {
            stilts.addRect(CGRect(x: x - 3, y: -13, width: 6, height: 13))
        }
        Art.fill(&context, stilts, Art.color(0x1A1626))
        Art.fill(&context, Art.rect(-150, -6, 300, 6), Art.color(inkHex, 0.5))
        // The wall of planks, and light in the cracks.
        let wall = Art.rect(-140, -100, 280, 86)
        Kit.solid(&context, wall, Art.color(0x2A2438), light: 0.1, shade: 0.2)
        var planks = Path()
        var px: CGFloat = -120
        while px < 140 {
            planks.move(to: Kit.pt(px, -100))
            planks.addLine(to: Kit.pt(px, -14))
            px += 20
        }
        Art.stroke(&context, planks, Art.color(0x17131F, 0.8), width: 1.4, cap: .butt)
        let cracks = Art.svg("M-120,-84 L-120,-30 M-100,-70 L-100,-20 M100,-88 L100,-40 M120,-64 L120,-18 M-80,-92 L-80,-74")
        Art.stroke(&context, cracks, Art.color(0xFFE9A6, 0.8 * glow), width: 1.2, cap: .butt)
        // The open doorway.
        let door = Art.rect(-52, -96, 104, 82)
        Art.fill(&context, door, Art.color(0x3A2E30))
        let light: Kit.Stops = [(Art.color(0xFFFBE4, glow), 0), (Art.color(0xFFE9A6, glow), 1)]
        Art.fillLinear(&context, door, light, from: CGPoint(x: 0, y: -96), to: CGPoint(x: 0, y: -14))
        // The sliding doors, pushed aside.
        var panels = Path()
        panels.addRect(CGRect(x: -80, y: -96, width: 28, height: 82))
        panels.addRect(CGRect(x: 52, y: -96, width: 28, height: 82))
        Art.fill(&context, panels, Art.color(0x3A3046))
        let lattice = Art.svg("M-80,-68 L-52,-68 M-80,-42 L-52,-42 M-66,-96 L-66,-14 M52,-68 L80,-68 M52,-42 L80,-42 M66,-96 L66,-14")
        Art.stroke(&context, lattice, Art.color(0x1E1A2A), width: 1.6, cap: .butt)
        Art.stroke(&context, Art.svg("M-52,-96 L-52,-14 M52,-96 L52,-14"), Art.color(0xFFF3C8, 0.7 * glow), width: 1.6, cap: .butt)
        // Posts and lintel.
        let frame = Art.svg("M-140,-100 L-140,-14 M140,-100 L140,-14 M-82,-100 L-82,-14 M82,-100 L82,-14 M-140,-98 L140,-98")
        Art.stroke(&context, frame, Art.color(0x1A1626), width: 5, cap: .butt)
        // The porch boards, catching the light.
        let porch = Art.rect(-152, -18, 304, 7, radius: 2)
        Kit.solid(&context, porch, Art.color(0x4A3C3A), light: 0.16, shade: 0.2)
        Art.fill(&context, Art.rect(-58, -18, 116, 7), Art.color(0xFFE9A6, 0.7 * glow))
        houseRoof(&context, glow: glow)
        // The light that falls out over the porch and the ground.
        let fan: Path = Art.polygon([Kit.pt(-52, -12), Kit.pt(52, -12), Kit.pt(110, 76), Kit.pt(-210, 76)])
        let spill: Kit.Stops = [(Art.color(0xFFE9A6, 0.42 * glow), 0), (Art.color(0xFFE9A6, 0), 1)]
        Art.fillLinear(&context, fan, spill, from: CGPoint(x: 0, y: -12), to: CGPoint(x: -40, y: 76))
    }

    /// The thick thatched roof of `thatchHouse`.
    static func houseRoof(_ context: inout GraphicsContext, glow: Double) {
        let roof = Art.svg("M-178,-98 C-150,-112 -110,-160 -88,-196 L88,-196 C110,-160 150,-112 178,-98 L172,-84 L-172,-84Z")
        let thatch: Kit.Stops = [(Art.color(0x4A4458), 0), (Art.color(0x363044), 0.6), (Art.color(0x2A2438), 1)]
        Kit.solid(&context, roof, stops: thatch, light: 0.14, shade: 0.24, rim: 2)
        var straw = Path()
        var random = ArtRandom(23)
        for _ in 0..<46 {
            let t: CGFloat = Kit.rnd(&random)
            let side: CGFloat = Kit.rnd(&random) * 2 - 1
            let y: CGFloat = -190 + 92 * t
            let spread: CGFloat = 86 + 84 * t
            let x: CGFloat = side * spread * Kit.rnd(&random)
            let slant: CGFloat = x / 178 * 9
            straw.move(to: Kit.pt(x, y))
            straw.addLine(to: Kit.pt(x + slant, y + 12))
        }
        let strawLines = straw
        Art.clipped(&context, to: roof) { g in
            Art.stroke(&g, strawLines, Art.color(0x1C1828, 0.7), width: 1.3)
            Art.fill(&g, Art.rect(-180, -92, 360, 10), Art.color(inkHex, 0.4))
            Art.stroke(&g, Art.line(-90, -85, 90, -85), Art.color(0xFFE9A6, 0.6 * glow), width: 3)
        }
        let cap = Art.rect(-96, -204, 192, 13, radius: 6)
        Kit.solid(&context, cap, Art.color(0x2A2438), light: 0.16, shade: 0.2)
        let ties = Art.svg("M-72,-204 L-72,-191 M-36,-204 L-36,-191 M0,-204 L0,-191 M36,-204 L36,-191 M72,-204 L72,-191")
        Art.stroke(&context, ties, Art.color(0x6A6078, 0.8), width: 2.2, cap: .butt)
    }

    /// A simple woven bamboo fence along `y` from `x0` to `x1`.
    static func wovenFence(_ context: inout GraphicsContext, x0: CGFloat, x1: CGFloat, y: CGFloat, height: CGFloat, tone: UInt32) {
        guard x1 > x0, height > 0 else { return }
        var stakes = Path()
        var weave = Path()
        var x: CGFloat = x0
        var index: Int = 0
        while x <= x1 && index < 200 {
            let tip: CGFloat = index % 3 == 0 ? height * 0.14 : 0
            stakes.move(to: Kit.pt(x, y))
            stakes.addLine(to: Kit.pt(x, y - height - tip))
            if x + 9 <= x1 {
                let low: CGFloat = index % 2 == 0 ? 0.24 : 0.8
                weave.move(to: Kit.pt(x, y - height * low))
                weave.addLine(to: Kit.pt(x + 9, y - height * (1.04 - low)))
            }
            x += 9
            index += 1
        }
        var rails = Path()
        rails.move(to: Kit.pt(x0, y - height * 0.24))
        rails.addLine(to: Kit.pt(x1, y - height * 0.24))
        rails.move(to: Kit.pt(x0, y - height * 0.8))
        rails.addLine(to: Kit.pt(x1, y - height * 0.8))
        Art.stroke(&context, weave, Art.color(tone, 0.85), width: 1.5)
        Art.stroke(&context, stakes, Art.color(tone), width: 2.6)
        Art.stroke(&context, rails, Kit.personTone(tone, 1.3), width: 3.2, cap: .butt)
        let shine = Art.line(x0, y - height * 0.8 - 1.2, x1, y - height * 0.8 - 1.2)
        Art.stroke(&context, shine, Art.color(0xA8B8E0, 0.25), width: 1, cap: .butt)
    }

    /// The ox of a lord's carriage: the ground under its middle at the origin, facing LEFT.
    static func ox(_ context: inout GraphicsContext) {
        let hide = Art.color(0x2E2638)
        let legs = Art.svg("M-34,-26 L-36,-2 M-22,-24 L-20,-2 M26,-24 L24,-2 M38,-26 L40,-2")
        Art.stroke(&context, legs, Art.color(0x221C2C), width: 8)
        Art.stroke(&context, Art.svg("M46,-48 C54,-40 54,-28 50,-20"), Art.color(0x221C2C), width: 3)
        let body = Art.svg("M-44,-52 C-30,-66 20,-62 40,-56 C52,-50 52,-28 44,-22 C20,-14 -24,-14 -40,-22 C-50,-30 -50,-44 -44,-52Z")
        Kit.solid(&context, body, hide, light: 0.2, shade: 0.2, rim: 2)
        Art.stroke(&context, Art.svg("M-58,-62 C-64,-74 -74,-74 -78,-67"), Art.color(0xD8CFB8), width: 3)
        Art.fill(&context, Art.ellipse(-49, -60, 6, 3.4), Art.color(0x221C2C))
        let head = Art.svg("M-44,-60 C-56,-68 -72,-60 -76,-46 C-77,-38 -68,-33 -60,-35 C-50,-37 -42,-46 -44,-60Z")
        Kit.solid(&context, head, hide, light: 0.22, shade: 0.18)
        Art.fill(&context, Art.ellipse(-71, -41, 5, 4), Art.color(0x4A4054))
        ArtStyle.eye(&context, -62, -51, 2.2, showsWhite: false)
    }

    /// A lord's ox-carriage: a boxed two-wheeled cart with a curved roof and one ox. The
    /// ground under the wheel is the origin; the ox stands to the LEFT. About 250 × 112.
    static func oxCart(_ context: inout GraphicsContext) {
        Kit.shadow(&context, -40, 2, width: 240, alpha: 0.3)
        Art.stroke(&context, Art.line(-20, -42, -150, -52), Art.color(0x2A2030), width: 4)
        Art.group(&context, x: -150, y: 0) { o in
            ox(&o)
        }
        Art.stroke(&context, Art.line(-150, -58, -196, -62), Art.color(0x2A2030), width: 4)
        let box = Art.rect(-36, -100, 88, 60, radius: 4)
        Kit.solid(&context, box, Art.color(0x33284A), light: 0.16, shade: 0.2)
        let blinds = Art.svg("M-28,-88 L44,-88 M-28,-80 L44,-80 M-28,-72 L44,-72 M-28,-64 L44,-64 M-28,-56 L44,-56")
        Art.stroke(&context, blinds, Art.color(0x5A4E7A, 0.7), width: 1.4, cap: .butt)
        Art.stroke(&context, Art.svg("M-36,-48 L52,-48"), Art.color(0xC9A24A, 0.7), width: 2, cap: .butt)
        let roof = Art.svg("M-46,-98 C-32,-116 48,-116 62,-98 L58,-91 L-42,-91Z")
        Kit.solid(&context, roof, Art.color(0x1E1830), light: 0.2, shade: 0.2, rim: 2)
        // The great wheel.
        Art.stroke(&context, Art.circle(8, -36, 33), Art.color(0x17131F), width: 6)
        var spokes = Path()
        for i in 0..<10 {
            let turn: CGFloat = CGFloat(i) * CGFloat.pi / 5
            spokes.move(to: Kit.pt(8, -36))
            spokes.addLine(to: Kit.pt(8 + cos(turn) * 31, -36 + sin(turn) * 31))
        }
        Art.stroke(&context, spokes, Art.color(0x17131F), width: 2.4)
        Art.fill(&context, Art.circle(8, -36, 6), Art.color(0x3A3046))
        Art.stroke(&context, Art.circle(8, -36, 33).trimmedPath(from: 0.5, to: 0.75), Art.color(0xA8B8E0, 0.35), width: 1.6)
    }

    /// Mount Fuji as the people of the story knew it: an even cone with snow on its head.
    static func fuji(_ context: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, width: CGFloat, height: CGFloat) {
        let half: CGFloat = width / 2
        let topY: CGFloat = baseY - height
        let crown: CGFloat = width * 0.045
        var cone = Path()
        cone.move(to: Kit.pt(cx - half, baseY))
        cone.addCurve(
            to: Kit.pt(cx - crown, topY),
            control1: Kit.pt(cx - half * 0.5, baseY - height * 0.12),
            control2: Kit.pt(cx - crown - half * 0.16, topY + height * 0.42)
        )
        cone.addLine(to: Kit.pt(cx - crown * 0.3, topY + 3))
        cone.addLine(to: Kit.pt(cx + crown * 0.4, topY + 1))
        cone.addLine(to: Kit.pt(cx + crown, topY + 2))
        cone.addCurve(
            to: Kit.pt(cx + half, baseY),
            control1: Kit.pt(cx + crown + half * 0.16, topY + height * 0.42),
            control2: Kit.pt(cx + half * 0.5, baseY - height * 0.12)
        )
        cone.closeSubpath()
        let rock: Kit.Stops = [(Art.color(0x3A4E8C), 0), (Art.color(0x24376E), 0.5), (Art.color(0x1A2A58), 1)]
        Art.fillLinear(&context, cone, rock, from: CGPoint(x: cx, y: topY), to: CGPoint(x: cx, y: baseY))
        var face = Path()
        face.move(to: Kit.pt(cx + crown * 0.2, topY))
        face.addQuadCurve(to: Kit.pt(cx + half * 0.25, baseY), control: Kit.pt(cx + half * 0.3, baseY - height * 0.5))
        face.addLine(to: Kit.pt(cx + half, baseY))
        face.addLine(to: Kit.pt(cx + half, topY))
        face.closeSubpath()
        let capY: CGFloat = topY + height * 0.28
        var snow = Path()
        snow.move(to: Kit.pt(cx - half, topY - 4))
        snow.addLine(to: Kit.pt(cx + half, topY - 4))
        snow.addLine(to: Kit.pt(cx + half, capY))
        let step: CGFloat = half * 1.2 / 12
        for i in 0...12 {
            let x: CGFloat = cx + half * 0.6 - step * CGFloat(i)
            let finger: CGFloat = i % 2 == 0 ? height * 0.13 : -height * 0.03
            snow.addLine(to: Kit.pt(x, capY + finger))
        }
        snow.addLine(to: Kit.pt(cx - half, capY))
        snow.closeSubpath()
        let shaded = face
        let cap = snow
        let glowX: CGFloat = cx - crown * 3
        Art.clipped(&context, to: cone) { g in
            Art.fill(&g, shaded, Art.color(inkHex, 0.3))
            Art.fill(&g, cap, Art.color(0xDCE6F8))
            Art.fill(&g, shaded, Art.color(0x2F4A8A, 0.3))
            Art.glow(&g, glowX, topY + height * 0.1, height * 0.3, Color.white, alpha: 0.35)
        }
    }

    /// The thin thread of smoke from the top of the mountain.
    static func smokeThread(_ context: inout GraphicsContext, from start: CGPoint, to end: CGPoint) {
        let rise: CGFloat = start.y - end.y
        var thread = Path()
        thread.move(to: start)
        thread.addCurve(
            to: end,
            control1: Kit.pt(start.x + 3, start.y - rise * 0.5),
            control2: Kit.pt(start.x - 4, end.y + rise * 0.25)
        )
        Art.stroke(&context, thread, Art.color(0xE9EEF8, 0.2), width: 5)
        Art.stroke(&context, thread, Art.color(0xF4F6FC, 0.75), width: 1.5)
    }

    /// A small flame with its glow, the base at the origin, about 20 high.
    static func flame(_ context: inout GraphicsContext) {
        Art.glow(&context, 0, -8, 44, Art.color(0xFFC65A), alpha: 0.55)
        Art.fill(&context, Art.svg("M0,-20 C8,-9 7,0 0,2 C-7,0 -8,-9 0,-20Z"), Art.color(0xFFB84A))
        Art.fill(&context, Art.svg("M0,-11 C4,-5 3.5,0 0,1 C-3.5,0 -4,-5 0,-11Z"), Art.color(0xFFF3C0))
    }
}
