import SwiftUI
import Foundation
import OmramoCore

// The riverbank world of "The Monkey and the Crocodile": leaves, water, hills, palms, fruit
// trees, lotus pads and reeds. Ported from docs/design/source/src/lib/art-jataka.js.

extension JatakaArt {
    /// A leaf cluster: centre x, centre y, radius.
    typealias Blob = (CGFloat, CGFloat, CGFloat)

    /// The light of a scene.
    struct Mood {
        var sky: [(Color, CGFloat)]
        var sun: Color
        var glowCore: Color
        var glowEdge: Color
        var hillFar: Color
        var hillMid: Color
        var hillNear: Color
        var palmTrunk: Color
        var water: [(Color, CGFloat)]
        var waterEdge: Color
        var glint: Color
        var waterTint: Color
        var isDusk: Bool
    }

    static func morningMood() -> Mood {
        let sky: [(Color, CGFloat)] = [
            (Art.color(0xBDEFE9), 0), (Art.color(0xDDF8EC), 0.52), (Art.color(0xF6FBD9), 0.89), (Art.color(0xFFF2B5), 1),
        ]
        let water: [(Color, CGFloat)] = [
            (Art.color(0xA9E9D4), 0), (Art.color(0x4CC4B4), 0.16), (Art.color(0x1596A0), 0.6), (Art.color(0x0A6585), 1),
        ]
        return Mood(
            sky: sky,
            sun: Art.color(0xFFF9D6),
            glowCore: Art.color(0xFFF7C2),
            glowEdge: Art.color(0xFFEE9E),
            hillFar: Art.color(0xA8DDCF),
            hillMid: Art.color(0x7CCAB2),
            hillNear: Art.color(0x3FA088),
            palmTrunk: Art.color(0x5A4638),
            water: water,
            waterEdge: Art.color(0x2B8C7E),
            glint: Art.color(0xFFF6C8),
            waterTint: Art.color(0x1596A0),
            isDusk: false
        )
    }

    /// Evening. The sky stays pale so dark story text keeps its contrast.
    static func duskMood() -> Mood {
        let sky: [(Color, CGFloat)] = [
            (Art.color(0xEEE6F5), 0), (Art.color(0xFCE9D2), 0.45), (Art.color(0xF9D6B8), 0.82), (Art.color(0xF2B8A0), 1),
        ]
        let water: [(Color, CGFloat)] = [
            (Art.color(0xF6C7A6), 0), (Art.color(0xD99A98), 0.18), (Art.color(0x86709F), 0.6), (Art.color(0x473F78), 1),
        ]
        return Mood(
            sky: sky,
            sun: Art.color(0xFFE9C4),
            glowCore: Art.color(0xFFE2B0),
            glowEdge: Art.color(0xFFBE92),
            hillFar: Art.color(0xDDB9C2),
            hillMid: Art.color(0xB894B0),
            hillNear: Art.color(0x7F6C9A),
            palmTrunk: Art.color(0x4A3A52),
            water: water,
            waterEdge: Art.color(0x8A5F86),
            glint: Art.color(0xFFEBC8),
            waterTint: Art.color(0x86709F),
            isDusk: true
        )
    }

    static let leafGreens: [Color] = [
        Art.color(0x0E4A45), Art.color(0x16695A), Art.color(0x22966A), Art.color(0x52BF72), Art.color(0xB4E86B),
    ]

    /// A lighter, yellower set for the tree downriver.
    static let figGreens: [Color] = [
        Art.color(0x14573F), Art.color(0x1E7F58), Art.color(0x36A86A), Art.color(0x7AD278), Art.color(0xD6F08C),
    ]

    /// The same tree in evening light.
    static let duskGreens: [Color] = [
        Art.color(0x1C4350), Art.color(0x2A6260), Art.color(0x418A6C), Art.color(0x9CBF74), Art.color(0xF1D488),
    ]

    // MARK: Small tools

    /// The next random value as a `CGFloat` in 0..<1.
    static func rnd(_ random: inout ArtRandom) -> CGFloat {
        CGFloat(random.next())
    }

    static func power(_ value: CGFloat, _ exponent: Double) -> CGFloat {
        CGFloat(pow(Double(value), exponent))
    }

    /// Degrees to radians.
    static func deg(_ degrees: CGFloat) -> CGFloat {
        degrees * CGFloat.pi / 180
    }

    static func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        CGPoint(x: x, y: y)
    }

    /// SVG path data drawn around the origin, then scaled and moved to (x, y).
    static func placed(_ data: String, x: CGFloat, y: CGFloat, scale: CGFloat = 1) -> Path {
        let transform = CGAffineTransform(translationX: x, y: y).scaledBy(x: scale, y: scale)
        return Art.svg(data).applying(transform)
    }

    // MARK: Leaves

    /// Adds one pointed leaf that starts at (x, y) and points along angle `a`.
    static func addLeaf(_ path: inout Path, _ x: CGFloat, _ y: CGFloat, _ r: CGFloat, _ a: CGFloat) {
        let c = cos(a)
        let s = sin(a)
        func p(_ u: CGFloat, _ v: CGFloat) -> CGPoint {
            CGPoint(x: x + u * c - v * s, y: y + u * s + v * c)
        }
        let start = p(0, 0)
        path.move(to: start)
        path.addCurve(to: p(r * 1.25, 0), control1: p(r * 0.45, -r * 0.42), control2: p(r * 0.95, -r * 0.26))
        path.addCurve(to: start, control1: p(r * 0.95, r * 0.26), control2: p(r * 0.45, r * 0.42))
        path.closeSubpath()
    }

    /// A mass of leaves built from blobs: dark leaves at the back, sunlit leaves on the
    /// upper-left of every blob.
    static func canopy(
        _ context: inout GraphicsContext,
        _ blobs: [Blob],
        seed: UInt32,
        palette: [Color] = JatakaArt.leafGreens,
        density: CGFloat = 1
    ) {
        guard palette.count >= 5 else { return }
        var random = ArtRandom(seed)
        var back0 = Path()
        var back1 = Path()
        var mid1 = Path()
        var mid2 = Path()
        var light3 = Path()
        var light4 = Path()
        for blob in blobs {
            let bx = blob.0
            let by = blob.1
            let br = blob.2
            guard br > 0 else { continue }
            let core = br * 0.72
            back0.addEllipse(in: CGRect(x: bx - core, y: by - core, width: core * 2, height: core * 2))
            let wanted = (br * br / 26 * density).rounded()
            let count = max(0, Int(wanted))
            let backLimit = CGFloat(count) * 0.38
            for i in 0..<count {
                let a = rnd(&random) * 6.283
                let d = power(rnd(&random), 0.42) * br * 1.06
                let x = bx + cos(a) * d
                let y = by + sin(a) * d * 0.92
                let turn: CGFloat = x < bx ? 2.6 : 0.5
                let la = (rnd(&random) - 0.5) * 2.4 + turn
                let sz = 7 + rnd(&random) * 8
                let lit = ((bx - x) + (by - y) * 1.3) / br
                let k = rnd(&random)
                if CGFloat(i) < backLimit {
                    if k < 0.5 {
                        addLeaf(&back0, x, y, sz * 1.1, la)
                    } else {
                        addLeaf(&back1, x, y, sz * 1.1, la)
                    }
                } else if lit + k * 0.9 > 0.95 {
                    if k > 0.82 {
                        addLeaf(&light4, x, y, sz, la)
                    } else {
                        addLeaf(&light3, x, y, sz, la)
                    }
                } else if k < 0.55 {
                    addLeaf(&mid1, x, y, sz, la)
                } else {
                    addLeaf(&mid2, x, y, sz, la)
                }
            }
        }
        Art.fill(&context, back0, palette[0])
        Art.fill(&context, back1, palette[1])
        Art.fill(&context, mid1, palette[1])
        Art.fill(&context, mid2, palette[2])
        Art.fill(&context, light3, palette[3])
        Art.fill(&context, light4, palette[4])
    }

    /// For tall windows: hangs lower tiers of the trailing-side blobs so the tree keeps
    /// filling the pane. Blobs left of `minX` are never copied (the reading side stays clear).
    static func stretched(_ blobs: [Blob], height h: CGFloat, minX: CGFloat) -> [Blob] {
        let extra = min(280, (h - 720) * 0.48)
        guard extra > 40 else { return blobs }
        var result: [Blob] = blobs
        for blob in blobs where blob.0 >= minX && blob.1 > 90 {
            let half: Blob = (blob.0 + 14, blob.1 + extra * 0.5, blob.2 * 0.92)
            let full: Blob = (blob.0 + 26, blob.1 + extra, blob.2 * 0.84)
            result.append(half)
            result.append(full)
        }
        return result
    }

    /// Blobs scaled by `k` about the point (`ax`, `ay`): a canopy that grows or shrinks with
    /// the window while it stays hung on its corner.
    static func scaled(_ blobs: [Blob], by k: CGFloat, aboutX ax: CGFloat, aboutY ay: CGFloat = 0) -> [Blob] {
        var result: [Blob] = []
        for blob in blobs {
            let moved: Blob = (ax + (blob.0 - ax) * k, ay + (blob.1 - ay) * k, blob.2 * k)
            result.append(moved)
        }
        return result
    }

    /// Blobs with their heights multiplied by `ky` (a crown lifted for a short window).
    static func lifted(_ blobs: [Blob], by ky: CGFloat) -> [Blob] {
        var result: [Blob] = []
        for blob in blobs {
            let moved: Blob = (blob.0, blob.1 * ky, blob.2)
            result.append(moved)
        }
        return result
    }

    /// One big leaf with a midrib, for close-up pictures.
    static func bigLeaf(
        _ context: inout GraphicsContext,
        _ x: CGFloat,
        _ y: CGFloat,
        length: CGFloat,
        angle: CGFloat,
        fill: Color,
        rib: Color
    ) {
        let r = length / 1.25
        var leaf = Path()
        addLeaf(&leaf, x, y, r, angle)
        Art.fill(&context, leaf, fill)
        let tipX = x + cos(angle) * length * 0.92
        let tipY = y + sin(angle) * length * 0.92
        Art.stroke(&context, Art.line(x, y, tipX, tipY), rib.opacity(0.7), width: max(1, length * 0.022))
        // Side veins.
        var veins = Path()
        let nx = -sin(angle)
        let ny = cos(angle)
        let steps: [CGFloat] = [0.28, 0.46, 0.64]
        for t in steps {
            let px = x + cos(angle) * length * t
            let py = y + sin(angle) * length * t
            let reach = length * 0.16 * (1 - (t - 0.3))
            let fx = cos(angle) * length * 0.1
            let fy = sin(angle) * length * 0.1
            veins.move(to: CGPoint(x: px, y: py))
            veins.addLine(to: CGPoint(x: px + nx * reach + fx, y: py + ny * reach + fy))
            veins.move(to: CGPoint(x: px, y: py))
            veins.addLine(to: CGPoint(x: px - nx * reach + fx, y: py - ny * reach + fy))
        }
        Art.stroke(&context, veins, rib.opacity(0.4), width: max(0.8, length * 0.012))
    }

    // MARK: Water

    /// Ripple rings around something sitting in the water.
    static func ripples(
        _ context: inout GraphicsContext,
        _ x: CGFloat,
        _ y: CGFloat,
        _ w: CGFloat,
        count: Int = 3,
        color: Color = .white,
        opacity: Double = 0.55
    ) {
        for i in 0..<max(0, count) {
            let step = CGFloat(i)
            let ww = w * (1 + step * 0.22)
            let yy = y + step * 5
            let bump = 3 + step
            var ring = Path()
            ring.move(to: CGPoint(x: x - ww / 2, y: yy))
            ring.addQuadCurve(to: CGPoint(x: x, y: yy), control: CGPoint(x: x - ww / 4, y: yy + bump))
            ring.addQuadCurve(to: CGPoint(x: x + ww / 2, y: yy), control: CGPoint(x: x + ww / 4, y: yy - bump))
            let alpha = max(0.05, opacity - Double(i) * 0.15)
            Art.stroke(&context, ring, color.opacity(alpha), width: max(0.6, 2.2 - step * 0.5))
        }
    }

    /// Short white wavelets scattered over water, longer and stronger toward the viewer.
    static func waterRipples(
        _ context: inout GraphicsContext,
        x0: CGFloat,
        x1: CGFloat,
        y0: CGFloat,
        y1: CGFloat,
        count: Int,
        seed: UInt32,
        color: Color = .white
    ) {
        var random = ArtRandom(seed)
        for _ in 0..<max(0, count) {
            let t = power(rnd(&random), 0.8)
            let y = y0 + t * (y1 - y0)
            let w = 14 + t * 60 * (0.4 + rnd(&random))
            let x = x0 + rnd(&random) * (x1 - x0)
            let alpha = 0.12 + random.next() * 0.3
            let bump = -1.5 - t * 2
            var wave = Path()
            wave.move(to: CGPoint(x: x, y: y))
            wave.addQuadCurve(to: CGPoint(x: x + w / 2, y: y), control: CGPoint(x: x + w / 4, y: y + bump))
            wave.addQuadCurve(to: CGPoint(x: x + w, y: y), control: CGPoint(x: x + w * 0.75, y: y - bump))
            Art.stroke(&context, wave, color.opacity(alpha), width: 0.9 + t * 1.6)
        }
    }

    /// A lily pad lying on the water, with an optional pink lotus.
    static func lotusPad(
        _ context: inout GraphicsContext,
        _ x: CGFloat,
        _ y: CGFloat,
        _ rx: CGFloat,
        flower: Bool = false,
        pad: Color = Art.color(0x2FA36B),
        vein: Color = Art.color(0x7FD68A)
    ) {
        let ry = rx * 0.32
        // An ellipse with a wedge cut out of its right side.
        var points: [CGPoint] = []
        let from: CGFloat = 0.34
        let to: CGFloat = 2 * CGFloat.pi - 0.52
        let steps = 30
        for i in 0...steps {
            let t = from + (to - from) * CGFloat(i) / CGFloat(steps)
            points.append(CGPoint(x: x + cos(t) * rx, y: y + sin(t) * ry))
        }
        points.append(CGPoint(x: x, y: y))
        Art.fill(&context, Art.polygon(points), pad)
        var shine = Path()
        shine.move(to: CGPoint(x: x - rx * 0.8, y: y - ry * 0.2))
        shine.addQuadCurve(to: CGPoint(x: x + rx * 0.4, y: y - ry * 0.8), control: CGPoint(x: x - rx * 0.45, y: y - ry * 1.0))
        Art.stroke(&context, shine, vein.opacity(0.8), width: ArtStyle.detailLine)
        guard flower else { return }
        let fx = x - rx * 0.2
        let fy = y - ry * 0.6
        let petals: [(CGFloat, CGFloat, UInt32)] = [
            (-62, 15, 0xF06C9B), (62, 15, 0xF06C9B), (-36, 18, 0xFF8FB4), (36, 18, 0xFF8FB4),
            (-14, 20, 0xFFB3CC), (14, 20, 0xFFB3CC), (0, 17, 0xFFD3E0),
        ]
        for petal in petals {
            let l = petal.1
            var shape = Path()
            shape.move(to: CGPoint(x: 0, y: 0))
            shape.addCurve(
                to: CGPoint(x: 0, y: -l),
                control1: CGPoint(x: -l * 0.32, y: -l * 0.5),
                control2: CGPoint(x: -l * 0.2, y: -l * 0.9)
            )
            shape.addCurve(
                to: CGPoint(x: 0, y: 0),
                control1: CGPoint(x: l * 0.2, y: -l * 0.9),
                control2: CGPoint(x: l * 0.32, y: -l * 0.5)
            )
            shape.closeSubpath()
            let turn = CGAffineTransform(translationX: fx, y: fy).rotated(by: deg(petal.0))
            Art.fill(&context, shape.applying(turn), Art.color(petal.2))
        }
        Art.fill(&context, Art.circle(fx, fy - 3, 2.6), Art.color(0xFFD23F))
    }

    /// A clump of reeds and bulrushes growing up from (x, y).
    static func reeds(
        _ context: inout GraphicsContext,
        _ x: CGFloat,
        _ y: CGFloat,
        count: Int,
        seed: UInt32,
        height: CGFloat = 70,
        dark: Color = Art.color(0x2C8A5C),
        light: Color = Art.color(0x3FA36A),
        head: Color = Art.color(0x7A4A2A)
    ) {
        var random = ArtRandom(seed)
        for _ in 0..<max(0, count) {
            let dx = (rnd(&random) - 0.5) * 46
            let hh = height * (0.55 + rnd(&random) * 0.6)
            let lean = (rnd(&random) - 0.5) * 26
            let useDark = rnd(&random) > 0.5
            let width = 1.8 + rnd(&random) * 1.6
            let bx = x + dx
            var stem = Path()
            stem.move(to: CGPoint(x: bx, y: y))
            stem.addQuadCurve(to: CGPoint(x: bx + lean, y: y - hh), control: CGPoint(x: bx + lean * 0.3, y: y - hh * 0.6))
            Art.stroke(&context, stem, useDark ? dark : light, width: width)
            if rnd(&random) > 0.6 {
                let turn = CGAffineTransform(translationX: bx + lean, y: y - hh).rotated(by: deg(lean * 0.6))
                let bulrush = Art.rect(-2.2, -9, 4.4, 14, radius: 2.2).applying(turn)
                Art.fill(&context, bulrush, head)
            }
        }
    }

    /// A dragonfly hovering at (x, y).
    static func dragonfly(_ context: inout GraphicsContext, _ x: CGFloat, _ y: CGFloat, scale: CGFloat) {
        Art.group(&context, x: x, y: y, rotate: deg(-18), scale: scale) { g in
            Art.stroke(&g, Art.line(0, 0, 16, 0), Art.color(0xE0457B), width: 2)
            let upper = CGAffineTransform(translationX: 4, y: -4).rotated(by: deg(-20))
            let lower = CGAffineTransform(translationX: 4, y: 4).rotated(by: deg(20))
            Art.fill(&g, Art.ellipse(0, 0, 7, 2.4).applying(upper), Art.color(0xFFFFFF, 0.8))
            Art.fill(&g, Art.ellipse(0, 0, 7, 2.4).applying(lower), Art.color(0xFFFFFF, 0.7))
        }
    }

    // MARK: Land and sky

    /// A soft rolling skyline from x0 to x0 + w around height `y`, filled down to `bottom`.
    static func hills(
        width w: CGFloat,
        y: CGFloat,
        amp: CGFloat,
        seed: UInt32,
        bottom: CGFloat,
        step: CGFloat = 8,
        x0: CGFloat = 0
    ) -> Path {
        var random = ArtRandom(seed)
        let p1 = rnd(&random) * 6
        let p2 = rnd(&random) * 6
        let p3 = rnd(&random) * 6
        var path = Path()
        path.move(to: CGPoint(x: x0, y: bottom))
        path.addLine(to: CGPoint(x: x0, y: y))
        let advance = max(1, step)
        var x = x0
        var lastY = y
        while x <= x0 + w {
            let a = 0.5 * sin(x / 97 + p1)
            let b = 0.32 * sin(x / 41 + p2)
            let c = 0.18 * sin(x / 17 + p3)
            lastY = y - amp * (a + b + c)
            path.addLine(to: CGPoint(x: x, y: lastY))
            x += advance
        }
        path.addLine(to: CGPoint(x: x0 + w, y: lastY))
        path.addLine(to: CGPoint(x: x0 + w, y: bottom))
        path.closeSubpath()
        return path
    }

    /// A small far palm.
    static func palm(
        _ context: inout GraphicsContext,
        _ x: CGFloat,
        _ y: CGFloat,
        _ s: CGFloat,
        lean: CGFloat = 0,
        color: Color,
        trunk: Color = Art.color(0x5A4638)
    ) {
        var stem = Path()
        stem.move(to: CGPoint(x: x, y: y))
        stem.addQuadCurve(to: CGPoint(x: x + lean, y: y - 46 * s), control: CGPoint(x: x + lean * 0.2, y: y - 24 * s))
        Art.stroke(&context, stem, trunk, width: 2.6 * s)
        var frond = Path()
        frond.move(to: CGPoint(x: 0, y: 0))
        frond.addQuadCurve(to: CGPoint(x: 34 * s, y: 4 * s), control: CGPoint(x: 18 * s, y: -10 * s))
        frond.addQuadCurve(to: CGPoint(x: 0, y: 0), control: CGPoint(x: 16 * s, y: 1 * s))
        frond.closeSubpath()
        let angles: [CGFloat] = [-150, -120, -95, -70, -40, -15, 10]
        var crown = Path()
        for angle in angles {
            let turn = CGAffineTransform(translationX: x + lean, y: y - 46 * s).rotated(by: deg(angle))
            crown.addPath(frond.applying(turn))
        }
        Art.fill(&context, crown, color)
    }

    /// A round little tree heavy with orange fruit.
    static func mangoTree(
        _ context: inout GraphicsContext,
        _ x: CGFloat,
        _ y: CGFloat,
        _ s: CGFloat,
        seed: UInt32,
        crown: Color = Art.color(0x1E8A63),
        crownLight: Color = Art.color(0x3DB877),
        trunk: Color = Art.color(0x6B4A3A)
    ) {
        var random = ArtRandom(seed)
        var gold = Path()
        var orange = Path()
        for _ in 0..<7 {
            let a = rnd(&random) * 6.28
            let d = rnd(&random) * 17 * s
            let cx = x + cos(a) * d
            let rise: CGFloat = sin(a) * d * 0.7
            let cy: CGFloat = y - 34 * s + rise + 3
            let fruit = CGRect(x: cx - 2.6 * s, y: cy - 3.3 * s, width: 5.2 * s, height: 6.6 * s)
            if rnd(&random) > 0.4 {
                gold.addEllipse(in: fruit)
            } else {
                orange.addEllipse(in: fruit)
            }
        }
        ArtStyle.contactShadow(&context, x + 3 * s, y, 13 * s, 2.6 * s, alpha: 0.2)
        Art.fill(&context, placed("M-2,0 q1,-12 -1,-22 l5,0 q-1,10 2,22Z", x: x, y: y, scale: s), trunk)
        // The crown: three overlapping clumps instead of one ellipse, lit from the upper left.
        var crownShape = Path()
        crownShape.addEllipse(in: CGRect(x: x - 22 * s, y: y - 49 * s, width: 34 * s, height: 30 * s))
        crownShape.addEllipse(in: CGRect(x: x - 6 * s, y: y - 51 * s, width: 28 * s, height: 26 * s))
        crownShape.addEllipse(in: CGRect(x: x - 17 * s, y: y - 37 * s, width: 38 * s, height: 20 * s))
        Art.fill(&context, crownShape, crown)
        Art.clipped(&context, to: crownShape) { lit in
            Art.fill(&lit, Art.ellipse(x + 10 * s, y - 24 * s, 17 * s, 11 * s), ArtStyle.coolShade.opacity(0.22))
            Art.fill(&lit, Art.ellipse(x - 7 * s, y - 40 * s, 13 * s, 9 * s), crownLight.opacity(0.9))
            Art.fill(&lit, Art.ellipse(x + 8 * s, y - 43 * s, 8 * s, 5 * s), crownLight.opacity(0.5))
        }
        var rim = Path()
        rim.move(to: CGPoint(x: x - 21 * s, y: y - 33 * s))
        rim.addQuadCurve(to: CGPoint(x: x - 4 * s, y: y - 49 * s), control: CGPoint(x: x - 20 * s, y: y - 48 * s))
        Art.stroke(&context, rim, ArtStyle.warmLight.opacity(0.55), width: max(0.8, 1.5 * s))
        Art.fill(&context, gold, Art.color(0xFFB62E))
        Art.fill(&context, orange, Art.color(0xFF8A3D))
    }

    /// The island with the ripe fruit. (x, y) is its left end on the horizon line.
    /// `rich` adds a front row of trees for the scene where the island is near.
    static func island(
        _ context: inout GraphicsContext,
        x: CGFloat,
        y: CGFloat,
        scale: CGFloat,
        withPalm: Bool = true,
        rich: Bool = false,
        dusk: Bool = false,
        haze: Double = 0
    ) {
        let sand = dusk ? Art.color(0xE9BE9A) : Art.color(0xE9D58A)
        let sandLight = dusk ? Art.color(0xFFE0C0) : Art.color(0xFFF3C0)
        let grass = dusk ? Art.color(0x5F9A78) : Art.color(0x5DBB63)
        let grassLight = dusk ? Art.color(0xA9C88A) : Art.color(0x9BDD72)
        let crown = dusk ? Art.color(0x2A6E66) : Art.color(0x1E8A63)
        let crownLight = dusk ? Art.color(0x6FAE7C) : Art.color(0x3DB877)
        let shade = dusk ? Art.color(0x4A3F78, 0.35) : Art.color(0x0E7C86, 0.35)
        let palmColor = dusk ? Art.color(0x2A5F66) : Art.color(0x1C7A5E)
        // Drawn as one layer, so a far island can sink a little into the air (`haze`).
        let clear = min(1, max(0.3, 1 - haze))
        Art.layer(&context, opacity: clear) { layer in
            Art.group(&layer, x: x, y: y, scale: scale) { g in
                Art.fill(&g, Art.ellipse(118, 34, 112, 9), shade)
                // Its reflection, broken by the water.
                Art.fill(&g, Art.svg("M22,36 C70,48 168,48 214,36 C168,41 70,41 22,36Z"), crown.opacity(0.3))
                let sandShape = Art.svg("M10,30 C40,8 90,2 130,4 C176,6 210,16 226,30Z")
                Art.fill(&g, sandShape, sand)
                let grassShape = Art.svg("M26,24 C56,6 100,1 134,4 C170,6 196,14 210,24Z")
                Art.fill(&g, grassShape, grass)
                ArtStyle.form(&g, grassShape, bounds: CGRect(x: 26, y: 1, width: 184, height: 23), light: 0.3, shade: 0.24)
                Art.stroke(&g, Art.svg("M34,21 C60,7 100,3 132,5.5"), grassLight.opacity(0.7), width: ArtStyle.detailLine)
                Art.stroke(&g, Art.svg("M13,29.4 C20,24 26,20 32,17"), sandLight.opacity(0.8), width: ArtStyle.detailLine)
                mangoTree(&g, 70, 12, 0.95, seed: 2, crown: crown, crownLight: crownLight)
                mangoTree(&g, 118, 8, 1.2, seed: 5, crown: crown, crownLight: crownLight)
                mangoTree(&g, 166, 13, 0.9, seed: 7, crown: crown, crownLight: crownLight)
                if withPalm {
                    palm(&g, 196, 16, 0.7, lean: 8, color: palmColor)
                }
                if rich {
                    mangoTree(&g, 44, 20, 0.66, seed: 11, crown: crown, crownLight: crownLight)
                    mangoTree(&g, 94, 19, 0.78, seed: 13, crown: crown, crownLight: crownLight)
                    mangoTree(&g, 142, 20, 0.82, seed: 17, crown: crown, crownLight: crownLight)
                    mangoTree(&g, 188, 22, 0.62, seed: 19, crown: crown, crownLight: crownLight)
                }
            }
        }
    }

    /// A puffy cloud whose left foot is at (x, y).
    static func cloud(_ context: inout GraphicsContext, _ x: CGFloat, _ y: CGFloat, scale: CGFloat, color: Color) {
        let shape = placed("M0,0 q14,-18 34,-8 q14,-16 36,-2 q22,-4 26,10Z", x: x, y: y, scale: scale)
        Art.fill(&context, shape, color)
    }

    /// Far birds: a small flock of "m" strokes around (x, y).
    static func birds(_ context: inout GraphicsContext, _ x: CGFloat, _ y: CGFloat, color: Color) {
        let flock: [(CGFloat, CGFloat, CGFloat)] = [(0, 0, 1), (26, -12, 0.7), (-22, -16, 0.6)]
        for bird in flock {
            let s = bird.2
            let bx = x + bird.0
            let by = y + bird.1
            var wings = Path()
            wings.move(to: CGPoint(x: bx - 7 * s, y: by))
            wings.addQuadCurve(to: CGPoint(x: bx, y: by), control: CGPoint(x: bx - 3.5 * s, y: by - 5 * s))
            wings.addQuadCurve(to: CGPoint(x: bx + 7 * s, y: by), control: CGPoint(x: bx + 3.5 * s, y: by - 5 * s))
            Art.stroke(&context, wings, color.opacity(0.7), width: 1.5 * s)
        }
    }

    /// Sky, sun, far hills, palms and the river, for any canvas. Everything hangs on the
    /// horizon line `H`; the sky above it stretches.
    static func backdrop(
        _ context: inout GraphicsContext,
        size: CGSize,
        horizon H: CGFloat,
        mood: Mood,
        sunX: CGFloat,
        sunRadius: CGFloat,
        hillScale: CGFloat,
        palms: [CGFloat],
        ripples rippleCount: Int,
        palmScale: CGFloat = 1
    ) {
        let w = size.width
        let h = size.height
        let hs = hillScale
        Art.fillLinear(&context, Art.rect(0, 0, w, h), mood.sky, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: H))

        let glowRadius = sunRadius * 4.5
        let glowStops: [(Color, CGFloat)] = [
            (mood.glowCore.opacity(0.95), 0), (mood.glowEdge.opacity(0.5), 0.45), (mood.glowEdge.opacity(0), 1),
        ]
        Art.fillRadial(
            &context,
            Art.circle(sunX, H - 26, glowRadius),
            glowStops,
            center: CGPoint(x: sunX, y: H - 26),
            radius: glowRadius
        )
        // The shared warm band on the horizon (pale gold in the morning, peach at dusk),
        // behind the sun's disc and the far hills.
        let bandColor = mood.isDusk ? mood.glowEdge : ArtStyle.jataka.glowColor
        let bandRise = min(150, max(40, H * 0.3))
        ArtStyle.horizonGlow(&context, width: w, y: H, rise: bandRise, color: bandColor, alpha: 0.5)
        Art.fill(&context, Art.circle(sunX, H - 30, sunRadius), mood.sun)

        let skyTop = max(0, H - 170)
        ArtStyle.tooth(&context, in: CGRect(x: 0, y: skyTop, width: w, height: H - skyTop), seed: 78, alpha: 0.05)

        // The far plane: a pale farthest range, the far hills, then a veil of the sky's own
        // colour so distance reads paler than the middle ground.
        let farthest = hills(width: w, y: H - 38 * hs, amp: 30 * hs, seed: 23, bottom: H + 8, step: 10)
        Art.fill(&context, farthest, mood.hillFar.opacity(0.5))
        let far = hills(width: w, y: H - 22 * hs, amp: 26 * hs, seed: 4, bottom: H + 8)
        Art.fill(&context, far, mood.hillFar)
        let veil = mood.isDusk ? Art.color(0xFBDCC2) : Art.color(0xF6FBD9)
        ArtStyle.atmosphere(&context, width: w, top: H - 84 * hs, bottom: H + 8, color: veil, alpha: 0.3)
        let middle = hills(width: w, y: H - 8 * hs, amp: 16 * hs, seed: 9, bottom: H + 8)
        Art.fill(&context, middle, mood.hillMid)
        // Morning light catching the tops of the middle hills.
        let crest: [(Color, CGFloat)] = [(mood.glowCore.opacity(0.28), 0), (mood.glowCore.opacity(0), 1)]
        Art.clipped(&context, to: middle) { lit in
            Art.fillLinear(
                &lit,
                Art.rect(0, H - 26 * hs, w, 22 * hs),
                crest,
                from: CGPoint(x: 0, y: H - 26 * hs),
                to: CGPoint(x: 0, y: H - 4 * hs)
            )
        }
        for (i, x) in palms.enumerated() {
            let s = (0.5 + CGFloat(i % 3) * 0.12) * palmScale
            let lean: CGFloat = i % 2 == 1 ? 5 : -4
            palm(&context, x, H - 2, s, lean: lean, color: mood.hillNear, trunk: mood.palmTrunk)
        }
        let near = hills(width: w, y: H + 2, amp: 7 * hs, seed: 15, bottom: H + 8, step: 5)
        Art.fill(&context, near, mood.hillNear)

        let depth = max(1, h - H)
        Art.fillLinear(&context, Art.rect(0, H, w, depth), mood.water, from: CGPoint(x: 0, y: H), to: CGPoint(x: 0, y: h))
        Art.fill(&context, Art.rect(0, H, w, 9), mood.waterEdge.opacity(0.35))
        // The far shore mirrored in the first stretch of water.
        let mirrorDepth = min(depth, 30 * hs)
        let mirror: [(Color, CGFloat)] = [(mood.hillNear.opacity(0.26), 0), (mood.hillNear.opacity(0), 1)]
        Art.fillLinear(
            &context,
            Art.rect(0, H + 9, w, mirrorDepth),
            mirror,
            from: CGPoint(x: 0, y: H + 9),
            to: CGPoint(x: 0, y: H + 9 + mirrorDepth)
        )
        // The same warm light, lying on the first stretch of water under the horizon.
        let reflection: [(Color, CGFloat)] = [(bandColor.opacity(0.22), 0), (bandColor.opacity(0), 1)]
        let reflectionDepth = min(depth, 34)
        Art.fillLinear(
            &context,
            Art.rect(0, H + 9, w, reflectionDepth),
            reflection,
            from: CGPoint(x: 0, y: H + 9),
            to: CGPoint(x: 0, y: H + 9 + reflectionDepth)
        )

        // The sun's path on the water.
        var random = ArtRandom(8)
        for _ in 0..<46 {
            let dy = 6 + power(rnd(&random), 1.3) * depth * 0.95
            let spread = 16 + dy * 0.5
            let x = sunX + (rnd(&random) - 0.5) * spread * 2
            let ww = 6 + rnd(&random) * 22 * (0.5 + dy / 150)
            let alpha = 0.35 + random.next() * 0.5
            let bar = Art.rect(x - ww / 2, H + dy, ww, 1.4 + dy / 90, radius: 1)
            Art.fill(&context, bar, mood.glint.opacity(alpha))
        }
        waterRipples(&context, x0: 0, x1: w, y0: H + 8, y1: h, count: rippleCount, seed: 31)
        ArtStyle.tooth(&context, in: CGRect(x: 0, y: H + 10, width: w, height: depth), seed: 77)
    }

    // MARK: Bank, rock, trees

    /// The near grassy bank at the trailing side (x 628…892), as in the design. It hangs on
    /// the horizon: its top is at H − 114 and its muddy foot at H + 84.
    static func nearBank(_ context: inout GraphicsContext, horizon H: CGFloat, dusk: Bool) {
        let shift = CGAffineTransform(translationX: 0, y: H - 584)
        let turf = Art.svg(
            "M892,470 C850,476 800,500 760,528 C720,556 690,560 650,606 C640,616 660,628 700,634 C760,644 800,640 892,650Z"
        ).applying(shift)
        let morningStops: [(Color, CGFloat)] = [
            (Art.color(0x7CCB5C), 0), (Art.color(0x3F9E58), 0.3), (Art.color(0x1F6B50), 1),
        ]
        let duskStops: [(Color, CGFloat)] = [
            (Art.color(0xA9BF74), 0), (Art.color(0x4F8C68), 0.3), (Art.color(0x245660), 1),
        ]
        // The bank's own shade on the water at its foot.
        ArtStyle.contactShadow(&context, 770, H + 74, 170, 16, alpha: 0.3)
        Art.fillLinear(
            &context,
            turf,
            dusk ? duskStops : morningStops,
            from: CGPoint(x: 0, y: H - 114),
            to: CGPoint(x: 0, y: H + 66)
        )
        let turfBounds = CGRect(x: 628, y: H - 114, width: 264, height: 180)
        ArtStyle.form(&context, turf, bounds: turfBounds, light: 0.26, shade: 0.22)
        ArtStyle.rimEdge(&context, turf, bounds: turfBounds, width: 2.4, alpha: 0.4)
        Art.clipped(&context, to: turf) { g in
            ArtStyle.tooth(&g, in: turfBounds, seed: 43, color: Art.color(0xD6F08C), alpha: 0.12)
        }
        let earth = Art.svg(
            "M650,606 C640,616 660,628 700,634 C760,644 800,640 892,650 L892,668 C800,660 750,660 694,646 C650,638 628,622 650,606Z"
        ).applying(shift)
        Art.fill(&context, earth, dusk ? Art.color(0x6A4A48) : Art.color(0x7A5638))
        // Grass tufts along the top of the slope.
        var random = ArtRandom(41)
        var tufts = Path()
        for _ in 0..<26 {
            let t = rnd(&random)
            let x = 668 + t * 220
            let slope = H + 8 - t * 108
            let y = slope + 6 + rnd(&random) * 26
            let lean = (rnd(&random) - 0.5) * 6
            tufts.move(to: CGPoint(x: x, y: y))
            tufts.addLine(to: CGPoint(x: x + lean, y: y - 7))
            tufts.move(to: CGPoint(x: x + 3, y: y))
            tufts.addLine(to: CGPoint(x: x + 4 + lean, y: y - 5))
        }
        Art.stroke(&context, tufts, Art.color(dusk ? 0xD9D48A : 0xB4E86B, 0.55), width: 1.3)
    }

    /// A smooth river rock. `cx` is its middle, `waterY` the waterline it sits on.
    /// `flat` gives it a broad table top (for something to lie on).
    static func rock(
        _ context: inout GraphicsContext,
        cx: CGFloat,
        waterY: CGFloat,
        width: CGFloat,
        height: CGFloat,
        flat: Bool,
        dusk: Bool
    ) {
        let roundData = "M-1,0 C-1.02,-0.46 -0.74,-0.9 -0.32,-0.98 C0.04,-1.05 0.5,-0.92 0.78,-0.62 C0.96,-0.42 1.03,-0.18 1,0 C0.6,0.16 -0.6,0.16 -1,0Z"
        let tableData = "M-1,0 C-1.05,-0.52 -0.82,-0.86 -0.46,-0.95 C-0.1,-1.02 0.42,-1 0.7,-0.86 C0.95,-0.72 1.05,-0.3 1,0 C0.6,0.16 -0.6,0.16 -1,0Z"
        let fit = CGAffineTransform(translationX: cx, y: waterY).scaledBy(x: width / 2, y: height)
        let shape = Art.svg(flat ? tableData : roundData).applying(fit)

        let shadow = ArtStyle.coolShade.opacity(dusk ? 0.32 : 0.26)
        Art.fill(&context, Art.ellipse(cx + width * 0.04, waterY + height * 0.16, width * 0.58, height * 0.2 + 3), shadow)

        let morningStops: [(Color, CGFloat)] = [
            (Art.color(0xE4DCC6), 0), (Art.color(0xB3AA96), 0.42), (Art.color(0x6E7474), 1),
        ]
        let duskStops: [(Color, CGFloat)] = [
            (Art.color(0xF0C3A6), 0), (Art.color(0xB18892), 0.45), (Art.color(0x5C5380), 1),
        ]
        Art.fillLinear(
            &context,
            shape,
            dusk ? duskStops : morningStops,
            from: CGPoint(x: cx - width * 0.2, y: waterY - height),
            to: CGPoint(x: cx + width * 0.15, y: waterY + height * 0.12)
        )
        let moss = dusk ? Art.color(0x5F8F6C, 0.55) : Art.color(0x52BF72, 0.6)
        let sheen = dusk ? Art.color(0xFFE6CC, 0.4) : Art.color(0xFFFFFF, 0.4)
        let crack = dusk ? Art.color(0x4A3F66, 0.4) : Art.color(0x4E5558, 0.4)
        Art.clipped(&context, to: shape) { g in
            // Light from the upper left, shade on the right flank.
            Art.fill(&g, Art.ellipse(cx - width * 0.2, waterY - height * 0.86, width * 0.3, height * 0.2), sheen)
            Art.fill(&g, Art.ellipse(cx + width * 0.42, waterY - height * 0.2, width * 0.22, height * 0.6), crack.opacity(0.22))
            Art.fill(&g, Art.ellipse(cx + width * 0.18, waterY - height * 1.0, width * 0.2, height * 0.16), moss)
            Art.fill(&g, Art.ellipse(cx - width * 0.36, waterY - height * 0.1, width * 0.2, height * 0.16), moss.opacity(0.4))
            var lines = Path()
            lines.move(to: CGPoint(x: cx - width * 0.1, y: waterY - height * 0.7))
            lines.addQuadCurve(
                to: CGPoint(x: cx + width * 0.02, y: waterY - height * 0.2),
                control: CGPoint(x: cx - width * 0.02, y: waterY - height * 0.5)
            )
            lines.move(to: CGPoint(x: cx + width * 0.24, y: waterY - height * 0.62))
            lines.addQuadCurve(
                to: CGPoint(x: cx + width * 0.3, y: waterY - height * 0.3),
                control: CGPoint(x: cx + width * 0.3, y: waterY - height * 0.48)
            )
            Art.stroke(&g, lines, crack, width: ArtStyle.detailLine)
            ArtStyle.tooth(
                &g,
                in: CGRect(x: cx - width / 2, y: waterY - height, width: width, height: height),
                seed: 23,
                color: crack,
                alpha: 0.25
            )
        }
        ripples(&context, cx, waterY + 3, width * 1.02, count: 3, color: .white, opacity: 0.6)
    }

    /// The tree downriver: a pale, smooth trunk leaning toward the water with a rounder,
    /// lighter crown than the banyan. The crown hangs from the top edge and the trunk
    /// stretches down to the bank at `baseY`.
    static func shoreTree(
        _ context: inout GraphicsContext,
        height h: CGFloat,
        baseY: CGFloat,
        palette: [Color],
        fruit: Bool,
        dusk: Bool,
        girth: CGFloat = 1,
        crownLift: CGFloat = 1
    ) {
        // `crownLift` below 1 raises the crown toward the top edge, for a short picture.
        let top: CGFloat = 150 * crownLift
        let span = max(40, baseY - top)
        // `girth` thickens the trunk about the trailing edge, for tall windows.
        func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: 892 - (892 - x) * girth, y: y)
        }
        var trunk = Path()
        trunk.move(to: pt(784, baseY))
        trunk.addCurve(to: pt(790, top), control1: pt(812, baseY - span * 0.35), control2: pt(768, top + span * 0.35))
        trunk.addLine(to: pt(838, top))
        trunk.addCurve(to: pt(874, baseY + 6), control1: pt(818, top + span * 0.35), control2: pt(854, baseY - span * 0.35))
        trunk.addCurve(to: pt(784, baseY), control1: pt(846, baseY + 3), control2: pt(812, baseY + 5))
        trunk.closeSubpath()
        let trunkLeft: CGFloat = 892 - 124 * girth
        let trunkBounds = CGRect(x: trunkLeft, y: top, width: 892 - trunkLeft, height: span + 8)
        let morningStops: [(Color, CGFloat)] = [
            (Art.color(0xCFA57C), 0), (Art.color(0x9A6E52), 0.42), (Art.color(0x5E4038), 1),
        ]
        let duskStops: [(Color, CGFloat)] = [
            (Art.color(0xD9A383), 0), (Art.color(0x8E5F5C), 0.42), (Art.color(0x4A3350), 1),
        ]
        let stops = dusk ? duskStops : morningStops

        let designed: [Blob] = [
            (850, 50, 90), (735, 44, 72), (640, 66, 54), (880, 165, 62), (775, 140, 58),
            (690, 150, 38), (585, 48, 34), (835, 238, 34), (600, 110, 24),
        ]
        let base = lifted(designed, by: crownLift)
        if !dusk {
            // A hazy back layer under the crown's lower edge: the far side of the tree.
            var backBlobs: [Blob] = []
            for blob in base where blob.1 > 90 * crownLift {
                let back: Blob = (blob.0 - 14, blob.1 + 14, blob.2 * 0.9)
                backBlobs.append(back)
            }
            canopy(&context, backBlobs, seed: 16, palette: hazyGreens, density: 0.4)
        }

        // Two limbs that reach up into the crown.
        let forkY = min(top + span * 0.34, 330)
        var limbs = Path()
        limbs.move(to: pt(800, forkY))
        limbs.addCurve(
            to: CGPoint(x: 660, y: 110 * crownLift),
            control1: pt(770, forkY - 50),
            control2: CGPoint(x: 700, y: 170 * crownLift)
        )
        limbs.move(to: pt(806, forkY + 30))
        limbs.addCurve(
            to: CGPoint(x: 880, y: 150 * crownLift),
            control1: pt(840, forkY - 10),
            control2: CGPoint(x: 872, y: 200 * crownLift)
        )
        Art.stroke(&context, limbs, dusk ? Art.color(0x7A5258) : Art.color(0x8A6048), width: 13)

        ArtStyle.contactShadow(&context, 892 - 62 * girth, baseY + 6, 78 * girth, 9, alpha: 0.3)
        Art.fillLinear(&context, trunk, stops, from: CGPoint(x: trunkLeft + 8, y: 0), to: CGPoint(x: 892 - 16 * girth, y: 0))
        // The one light: a warm edge down the left of the trunk, shade on its right.
        ArtStyle.form(&context, trunk, bounds: trunkBounds, light: 0.2, shade: 0.24)
        ArtStyle.rimEdge(&context, trunk, bounds: trunkBounds, width: 3, alpha: 0.5)
        Art.clipped(&context, to: trunk) { g in
            ArtStyle.tooth(&g, in: trunkBounds, seed: 57, color: Art.color(0xFFE2BD), alpha: 0.1)
        }
        // Smooth bark: a soft light edge and a few rings.
        var edge = Path()
        edge.move(to: pt(792, baseY - span * 0.06))
        edge.addCurve(
            to: pt(797, top + span * 0.1),
            control1: pt(816, baseY - span * 0.36),
            control2: pt(778, top + span * 0.4)
        )
        Art.stroke(&context, edge, Art.color(0xFFE2BD, 0.45), width: ArtStyle.contourLine)
        var rings = Path()
        let marks: [CGFloat] = [0.22, 0.4, 0.58, 0.76]
        for t in marks {
            let y = top + span * t
            let lean = sin(t * 3.1) * 10
            rings.move(to: pt(806 + lean, y))
            rings.addQuadCurve(to: pt(836 + lean, y + 2), control: pt(820 + lean, y + 6))
        }
        let ringColor = dusk ? Art.color(0x4A3350, 0.4) : Art.color(0x5E4038, 0.4)
        Art.stroke(&context, rings, ringColor, width: ArtStyle.detailLine)
        var feet = Path()
        feet.move(to: pt(790, baseY - 6))
        feet.addQuadCurve(to: pt(752, baseY + 12), control: pt(776, baseY + 6))
        feet.move(to: pt(862, baseY))
        feet.addQuadCurve(to: pt(886, baseY + 16), control: pt(876, baseY + 6))
        Art.stroke(&context, feet, dusk ? Art.color(0x6A4650) : Art.color(0x7A5442), width: 7)

        let blobs = stretched(base, height: h, minX: 680)
        canopy(&context, blobs, seed: 14, palette: palette)

        guard fruit else { return }
        var random = ArtRandom(52)
        for _ in 0..<22 {
            let pick = Int(rnd(&random) * CGFloat(base.count))
            let blob = base[min(max(0, pick), base.count - 1)]
            let a = rnd(&random) * 6.283
            let d = rnd(&random) * blob.2 * 0.8
            let x = blob.0 + cos(a) * d
            let y = blob.1 + abs(sin(a)) * d * 0.8
            let ripe = rnd(&random) > 0.4
            Art.fill(&context, Art.ellipse(x, y, 4.4, 5.4), ripe ? Art.color(0xFFB62E) : Art.color(0xFF8A3D))
            Art.fill(&context, Art.circle(x - 1.3, y - 1.8, 1.2), Art.color(0xFFF3C0, 0.8))
        }
    }

    /// The near plane: dark, soft, out-of-focus leaves fanning up from the two bottom corners
    /// (the design's foreground). `scale` grows them on a tall window. They stay in the
    /// corners, under the chrome, and never reach the words.
    static func cornerLeaves(
        _ context: inout GraphicsContext,
        width w: CGFloat,
        height h: CGFloat,
        color: Color,
        scale: CGFloat = 1
    ) {
        Art.blurred(&context, radius: 2.2, opacity: 0.95) { g in
            var leaves = Path()
            addLeaf(&leaves, -16, h + 18, 92 * scale, deg(-80))
            addLeaf(&leaves, -12, h + 22, 80 * scale, deg(-50))
            addLeaf(&leaves, -8, h + 24, 58 * scale, deg(-22))
            addLeaf(&leaves, w + 14, h + 18, 98 * scale, deg(-102))
            addLeaf(&leaves, w + 12, h + 22, 76 * scale, deg(-134))
            addLeaf(&leaves, w + 8, h + 24, 52 * scale, deg(-160))
            Art.fill(&g, leaves, color)
            // A breath of the key light on the upper-left edge of each leaf group.
            var edges = Path()
            addLeaf(&edges, -16, h + 18, 78 * scale, deg(-84))
            addLeaf(&edges, w + 14, h + 18, 82 * scale, deg(-106))
            Art.fill(&g, edges, ArtStyle.warmLight.opacity(0.1))
        }
    }

    /// The flat rock of scene-dusk with the Crocodile lying on it, pretending to be part of
    /// it. `cx` is the middle of the rock and `waterY` its waterline; the rock is 200 units
    /// wide at scale 1.
    static func sleepingRock(_ context: inout GraphicsContext, cx: CGFloat, waterY: CGFloat, scale: CGFloat) {
        let skin = youngCrocSkin()
        Art.group(&context, x: cx - 560 * scale, y: waterY - 76 * scale, scale: scale) { g in
            rock(&g, cx: 560, waterY: 76, width: 200, height: 40, flat: true, dusk: true)
            let lyingFlat = Art.rect(440, -30, 240, 72)
            Art.clipped(&g, to: lyingFlat) { c in
                Art.group(&c, x: 650, y: 31, scale: 0.5, scaleX: -1) { body in
                    croc(&body, skin: skin, lid: .shut, waterline: 200, waterOpacity: 0, mirrored: true)
                }
            }
            Art.stroke(&g, Art.line(482, 42.5, 644, 42.5), ArtStyle.coolShade.opacity(0.3), width: ArtStyle.contourLine)
            ArtStyle.contactShadow(&g, 566, 42, 84, 4, alpha: 0.3)
        }
    }
}
