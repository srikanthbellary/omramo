import SwiftUI
import Foundation
import OmramoCore

// Shared parts of the Anansi pictures, ported from docs/design/source/src/lib/art-anansi.js:
// kente weave, web mark, the pot, leaves, umbrella trees, fireflies, stars, web, canopy, motes.
// The cloth and pot decoration are plain geometric bands plus the web mark of the design;
// nothing here is meant as a specific adinkra symbol.

extension AnansiArt {
    // MARK: Palette

    static let skin = Art.color(0x7A4A30)
    static let skinDark = Art.color(0x55301F)
    static let skinLight = Art.color(0x9A6040)
    static let skinWarm = Art.color(0x65391F)
    static let hairWhite = Art.color(0xF1F1F4)
    static let kGold = Art.color(0xF7B520)
    static let kGreen = Art.color(0x128A4E)
    static let kRed = Art.color(0xD8342B)
    static let kBlack = Art.color(0x17121F)
    /// Hair, mouth and brow tones: dark, warm tones of the skin, never black.
    static let hairDark = Art.color(0x241624)
    static let mouthTone = Art.color(0x3A1A10)
    static let browTone = Art.color(0x3A2016)
    static let eyeTone = Art.color(0x2A1A12)
    static let moteGold = Art.color(0xFFD25A)
    static let leafRim = Art.color(0x7FE0C0)

    /// Sky colours, top to horizon: night, upper, mid purple, magenta, orange, glow.
    static let duskSky: [Color] = [
        Art.color(0x120D38), Art.color(0x241758), Art.color(0x4A2470),
        Art.color(0x93386F), Art.color(0xE4694F), Art.color(0xFFB45A),
    ]
    /// The same sky a touch lighter: pre-dawn violet.
    static let dawnSky: [Color] = [
        Art.color(0x1D1650), Art.color(0x33206C), Art.color(0x5A2E84),
        Art.color(0xA04A80), Art.color(0xF08A6A), Art.color(0xFFC98A),
    ]
    static let canopyPalette: [Color] = [
        Art.color(0x10283F), Art.color(0x16385A), Art.color(0x2B6A7A), Art.color(0x8FD0B0),
    ]
    static let climbCanopy: [(CGFloat, CGFloat, CGFloat)] = [
        (640, 30, 120), (800, 40, 110), (500, 20, 80), (870, 120, 60),
        (716, 92, 70), (420, 34, 46), (560, 84, 40), (372, 18, 30),
    ]

    // MARK: Small geometry

    static func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        CGPoint(x: x, y: y)
    }

    /// Degrees to radians.
    static func rad(_ degrees: CGFloat) -> CGFloat {
        degrees * CGFloat.pi / 180
    }

    static func shifted(_ path: Path, _ dy: CGFloat) -> Path {
        path.applying(CGAffineTransform(translationX: 0, y: dy))
    }

    static func stretched(_ path: Path, _ k: CGFloat) -> Path {
        path.applying(CGAffineTransform(scaleX: 1, y: k))
    }

    /// An ellipse turned by `angle` radians about its own centre.
    static func tiltedEllipse(_ cx: CGFloat, _ cy: CGFloat, _ rx: CGFloat, _ ry: CGFloat, _ angle: CGFloat) -> Path {
        let transform = CGAffineTransform(translationX: cx, y: cy).rotated(by: angle)
        return Art.ellipse(0, 0, rx, ry).applying(transform)
    }

    static func cubicPoint(_ p0: CGPoint, _ c1: CGPoint, _ c2: CGPoint, _ p1: CGPoint, _ t: CGFloat) -> CGPoint {
        let u: CGFloat = 1 - t
        let uu: CGFloat = u * u
        let tt: CGFloat = t * t
        let a: CGFloat = uu * u
        let b: CGFloat = 3 * uu * t
        let c: CGFloat = 3 * u * tt
        let d: CGFloat = tt * t
        let xStart: CGFloat = a * p0.x + b * c1.x
        let xEnd: CGFloat = c * c2.x + d * p1.x
        let yStart: CGFloat = a * p0.y + b * c1.y
        let yEnd: CGFloat = c * c2.y + d * p1.y
        return CGPoint(x: xStart + xEnd, y: yStart + yEnd)
    }

    /// A round-capped stroke along SVG path data (arms, legs).
    static func limb(_ context: inout GraphicsContext, _ data: String, _ width: CGFloat, _ color: Color) {
        Art.stroke(&context, Art.svg(data), color, width: width)
    }

    // MARK: Kente weave

    static func kenteTile(
        _ ox: CGFloat, _ oy: CGFloat, _ s: CGFloat,
        _ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat
    ) -> CGRect {
        CGRect(x: ox + x * s, y: oy + y * s, width: w * s, height: h * s)
    }

    /// Fills `shape` with the woven strip of the design (pattern unit 48 × 24, times `s`),
    /// laid out from the origin of the current coordinate space.
    static func kente(_ context: inout GraphicsContext, in shape: Path, scale s: CGFloat) {
        Art.fill(&context, shape, kGold)
        let box = shape.boundingRect
        guard s > 0, !box.isNull, !box.isInfinite, box.width > 0, box.height > 0 else { return }
        let tw: CGFloat = 48 * s
        let th: CGFloat = 24 * s
        let i0 = Int((box.minX / tw).rounded(.down))
        let i1 = Int((box.maxX / tw).rounded(.up))
        let j0 = Int((box.minY / th).rounded(.down))
        let j1 = Int((box.maxY / th).rounded(.up))
        guard i1 > i0, j1 > j0, (i1 - i0) * (j1 - j0) < 4000 else { return }

        var greenPath = Path()
        var softGreenPath = Path()
        var goldPath = Path()
        var blackPath = Path()
        var redPath = Path()
        for i in i0..<i1 {
            let ox = CGFloat(i) * tw
            for j in j0..<j1 {
                let oy = CGFloat(j) * th
                greenPath.addRect(kenteTile(ox, oy, s, 0, 0, 12, 24))
                goldPath.addRect(kenteTile(ox, oy, s, 2, 3, 8, 3))
                goldPath.addRect(kenteTile(ox, oy, s, 2, 18, 8, 3))
                redPath.addRect(kenteTile(ox, oy, s, 2, 10.5, 8, 3))
                blackPath.addRect(kenteTile(ox, oy, s, 12, 0, 4, 24))
                redPath.addRect(kenteTile(ox, oy, s, 16, 0, 12, 6))
                redPath.addRect(kenteTile(ox, oy, s, 16, 12, 12, 6))
                blackPath.addRect(kenteTile(ox, oy, s, 16, 6, 6, 6))
                blackPath.addRect(kenteTile(ox, oy, s, 22, 18, 6, 6))
                blackPath.addRect(kenteTile(ox, oy, s, 28, 0, 4, 24))
                softGreenPath.addRect(kenteTile(ox, oy, s, 34, 2, 12, 4))
                softGreenPath.addRect(kenteTile(ox, oy, s, 34, 10, 12, 4))
                softGreenPath.addRect(kenteTile(ox, oy, s, 34, 18, 12, 4))
                redPath.addRect(kenteTile(ox, oy, s, 38, 2, 4, 20))
            }
        }
        let greens = greenPath
        let softGreens = softGreenPath
        let golds = goldPath
        let blacks = blackPath
        let reds = redPath
        Art.clipped(&context, to: shape) { g in
            Art.fill(&g, greens, kGreen)
            Art.fill(&g, softGreens, kGreen.opacity(0.9))
            Art.fill(&g, golds, kGold)
            Art.fill(&g, blacks, kBlack)
            Art.fill(&g, reds, kRed)
        }
    }

    // MARK: Web mark and pot

    /// The web mark of the design: hub, eight spokes and one ring.
    static func webMark(
        _ context: inout GraphicsContext,
        _ x: CGFloat, _ y: CGFloat, _ r: CGFloat,
        _ color: Color,
        weight: CGFloat = 0.11
    ) {
        Art.fill(&context, Art.circle(x, y, r * 0.2), color)
        var spokes = Path()
        for i in 0..<8 {
            let a = CGFloat(i) * CGFloat.pi / 4
            let ca = cos(a)
            let sa = sin(a)
            spokes.move(to: pt(x + ca * r * 0.28, y + sa * r * 0.28))
            spokes.addLine(to: pt(x + ca * r, y + sa * r))
        }
        Art.stroke(&context, spokes, color, width: r * weight)
        Art.stroke(&context, Art.circle(x, y, r * 0.62), color, width: r * weight * 0.9)
    }

    /// The wisdom pot: clay, glowing from inside. Origin is the middle of the belly;
    /// the pot is 42 × 45 units at scale 1. `sealed` adds a clay stopper tied with cord.
    static func pot(
        _ context: inout GraphicsContext,
        _ x: CGFloat, _ y: CGFloat, _ s: CGFloat,
        glow: Bool = true,
        sealed: Bool = false
    ) {
        Art.group(&context, x: x, y: y, scale: s) { g in
            if glow {
                let halo: [(Color, CGFloat)] = [
                    (Art.color(0xFFE27A, 0.85), 0), (Art.color(0xFFB93D, 0.35), 0.4), (Art.color(0xFFB93D, 0), 1),
                ]
                Art.fillRadial(&g, Art.circle(0, 0, 46), halo, center: pt(0, 0), radius: 46)
            }
            let body = Art.svg("M-11,-17 C-13,-21 -12,-24 -9,-24 L9,-24 C12,-24 13,-21 11,-17 C20,-12 22,-2 20,6 C17,17 9,21 0,21 C-9,21 -17,17 -20,6 C-22,-2 -20,-12 -11,-17Z")
            let clay: [(Color, CGFloat)] = [
                (Art.color(0xF08A52), 0), (Art.color(0xC7562E), 0.55), (Art.color(0x7A2E18), 1),
            ]
            Art.fillRadial(&g, body, clay, center: pt(-6.3, -10.5), radius: 39)
            Art.stroke(&g, Art.svg("M-11,-17 C-4,-14 4,-14 11,-17"), Art.color(0x7A2E18), width: 1.6, cap: .butt)
            Art.fill(&g, Art.ellipse(0, -24, 9.6, 2.6), Art.color(0x3A160E))
            Art.fill(&g, Art.ellipse(0, -24, 7.5, 1.8), Art.color(0xFFE27A))
            if sealed {
                let stopper = Art.svg("M-8.6,-24 C-8,-30.5 8,-30.5 8.6,-24 C4,-22.6 -4,-22.6 -8.6,-24Z")
                let stopperClay: [(Color, CGFloat)] = [
                    (Art.color(0xE07A48), 0), (Art.color(0xA9451F), 0.7), (Art.color(0x6A2612), 1),
                ]
                Art.fillRadial(&g, stopper, stopperClay, center: pt(-3, -28), radius: 12)
                Art.fill(&g, Art.ellipse(0, -30, 2.6, 1.7), Art.color(0xB9502A))
                Art.stroke(&g, Art.svg("M-8.4,-23.6 C-4,-22.2 4,-22.2 8.4,-23.6"), Art.color(0xFFE27A, 0.9), width: 0.8)
                Art.stroke(&g, Art.svg("M-11.6,-18.6 C-4,-15.6 4,-15.6 11.6,-18.6"), Art.color(0xE9D9B0), width: 1.5)
                Art.stroke(&g, Art.svg("M5,-16.4 C6,-13 5,-11 3.6,-9.4 M6.4,-16.6 C8.4,-13.6 9,-11.6 9.2,-9.8"), Art.color(0xE9D9B0), width: 1)
                Art.fill(&g, Art.circle(5.8, -16.6, 1.5), Art.color(0xF4E8C8))
            }
            Art.stroke(
                &g,
                Art.svg("M-19,-2 C-8,2 8,2 19,-2 M-20,5 C-8,9 8,9 20,5"),
                Art.color(0xFFD25A, 0.9), width: 1.5, cap: .butt
            )
            Art.stroke(
                &g,
                Art.svg("M-15,1.5 l3,3.5 l3,-3.2 l3,3.4 l3,-3.4 l3,3.4 l3,-3.4 l3,3.2 l3,-3.5"),
                Art.color(0x3A160E, 0.7), width: 1.1, cap: .butt, join: .miter
            )
            webMark(&g, 0, 13, 5.5, Art.color(0xFFD25A), weight: 0.16)
            Art.stroke(&g, Art.svg("M-15,-8 C-17,-2 -17,6 -13,12"), Art.color(0xFFB07A, 0.55), width: 2.4)
        }
    }

    // MARK: Leaves and trees

    static func bigLeaf(
        _ context: inout GraphicsContext,
        _ x: CGFloat, _ y: CGFloat, _ len: CGFloat, _ angle: CGFloat,
        _ c1: Color, _ c2: Color, _ rim: Color
    ) {
        Art.group(&context, x: x, y: y, rotate: rad(angle)) { g in
            let tip = pt(len, 0)
            let upper1 = pt(len * 0.2, -len * 0.3)
            let upper2 = pt(len * 0.7, -len * 0.28)

            var blade = Path()
            blade.move(to: CGPoint.zero)
            blade.addCurve(to: tip, control1: upper1, control2: upper2)
            blade.addCurve(to: CGPoint.zero, control1: pt(len * 0.7, len * 0.2), control2: pt(len * 0.2, len * 0.22))
            blade.closeSubpath()
            Art.fill(&g, blade, c1)

            var top = Path()
            top.move(to: CGPoint.zero)
            top.addCurve(to: tip, control1: upper1, control2: upper2)
            top.addCurve(to: CGPoint.zero, control1: pt(len * 0.6, -len * 0.06), control2: pt(len * 0.3, -len * 0.04))
            top.closeSubpath()
            Art.fill(&g, top, c2)

            var rib = Path()
            rib.move(to: CGPoint.zero)
            rib.addQuadCurve(to: tip, control: pt(len * 0.5, -len * 0.05))
            Art.stroke(&g, rib, rim.opacity(0.7), width: ArtStyle.detailLine)

            var veins = Path()
            let places: [CGFloat] = [0.25, 0.42, 0.58, 0.74]
            for t in places {
                let vx = len * t
                veins.move(to: pt(vx, -len * 0.02))
                veins.addLine(to: pt(vx + len * 0.1, -len * 0.16))
                veins.move(to: pt(vx, 0))
                veins.addLine(to: pt(vx + len * 0.1, len * 0.1))
            }
            Art.stroke(&g, veins, rim.opacity(0.35), width: 0.8, cap: .butt)
        }
    }

    /// A big forest leaf in one of the two tones of the design. `angle` is in degrees.
    static func leaf(
        _ context: inout GraphicsContext,
        _ x: CGFloat, _ y: CGFloat, _ len: CGFloat, _ angle: CGFloat,
        dark: Bool
    ) {
        if dark {
            bigLeaf(&context, x, y, len, angle, Art.color(0x0B2233), Art.color(0x12384A), leafRim)
        } else {
            bigLeaf(&context, x, y, len, angle, Art.color(0x0E2A3C), Art.color(0x17485A), leafRim)
        }
    }

    /// An umbrella-tree silhouette standing on (x, y), `h` tall, crown scaled by `s`.
    static func umbrellaTree(
        _ context: inout GraphicsContext,
        _ x: CGFloat, _ y: CGFloat, _ h: CGFloat, _ s: CGFloat,
        _ color: Color,
        seed: UInt32
    ) {
        var random = ArtRandom(seed)
        var crown = Path()
        for _ in 0..<7 {
            let u1: CGFloat = random.next(in: 0...1) - 0.5
            let u2: CGFloat = random.next(in: 0...1) - 0.5
            let u3: CGFloat = random.next(in: 0...1)
            let u4: CGFloat = random.next(in: 0...1)
            let crownTop: CGFloat = y - h - 6 * s
            let cx: CGFloat = x + u1 * 90 * s
            let cy: CGFloat = crownTop + u2 * 18 * s
            let rx: CGFloat = (26 + u3 * 22) * s
            let ry: CGFloat = (9 + u4 * 8) * s
            crown.addEllipse(in: CGRect(x: cx - rx, y: cy - ry, width: rx * 2, height: ry * 2))
        }

        var trunk = Path()
        trunk.move(to: pt(x - 3 * s, y))
        trunk.addCurve(to: pt(x - 1.5 * s, y - h), control1: pt(x - 2 * s, y - h * 0.5), control2: pt(x - s, y - h * 0.8))
        trunk.addLine(to: pt(x + 1.5 * s, y - h))
        trunk.addCurve(to: pt(x + 4 * s, y), control1: pt(x + s, y - h * 0.8), control2: pt(x + 2 * s, y - h * 0.5))
        trunk.closeSubpath()
        Art.fill(&context, trunk, color)

        var boughs = Path()
        let y1 = y - h * 0.8
        boughs.move(to: pt(x, y1))
        boughs.addQuadCurve(to: pt(x - 30 * s, y1 - h * 0.2), control: pt(x - 16 * s, y1 - 10 * s))
        let y2 = y - h * 0.72
        boughs.move(to: pt(x, y2))
        boughs.addQuadCurve(to: pt(x + 34 * s, y2 - h * 0.26), control: pt(x + 18 * s, y2 - 12 * s))
        Art.stroke(&context, boughs, color, width: 2.2 * s)

        Art.fill(&context, crown, color)
    }

    /// A tall forest trunk from the top edge down to `base`, with a small root flare.
    static func forestTrunk(
        _ context: inout GraphicsContext,
        _ x: CGFloat, _ w: CGFloat, _ base: CGFloat,
        dark: Color, light: Color,
        rim: Double
    ) {
        let a = w / 2
        let yF = base - 110
        var p = Path()
        p.move(to: pt(x - a * 0.86, 0))
        p.addCurve(to: pt(x - a, yF), control1: pt(x - a * 0.8, base * 0.3), control2: pt(x - a * 1.06, base * 0.6))
        p.addCurve(to: pt(x - a * 2.6, base), control1: pt(x - a * 1.1, yF + 60), control2: pt(x - a * 1.7, yF + 96))
        p.addLine(to: pt(x + a * 2.6, base))
        p.addCurve(to: pt(x + a, yF), control1: pt(x + a * 1.7, yF + 96), control2: pt(x + a * 1.1, yF + 60))
        p.addCurve(to: pt(x + a * 0.86, 0), control1: pt(x + a * 1.06, base * 0.6), control2: pt(x + a * 0.8, base * 0.3))
        p.closeSubpath()
        let stops: [(Color, CGFloat)] = [(dark, 0), (dark, 0.45), (light, 1)]
        Art.fillLinear(&context, p, stops, from: pt(x - a, 0), to: pt(x + a, 0))
        if rim > 0 {
            var edge = Path()
            edge.move(to: pt(x + a * 0.84, 6))
            edge.addCurve(to: pt(x + a * 0.98, yF), control1: pt(x + a * 0.78, base * 0.3), control2: pt(x + a * 1.04, base * 0.6))
            Art.stroke(&context, edge, Art.color(0xFFE9D2, rim), width: ArtStyle.detailLine)
        }
    }

    /// A hanging vine with small leaves.
    static func vine(
        _ context: inout GraphicsContext,
        _ x: CGFloat, _ y0: CGFloat, _ len: CGFloat, _ sway: CGFloat,
        _ color: Color,
        leafColor: Color
    ) {
        let p0 = pt(x, y0)
        let c1 = pt(x - sway * 0.6, y0 + len * 0.35)
        let c2 = pt(x + sway * 1.4, y0 + len * 0.7)
        let p1 = pt(x + sway, y0 + len)
        var stem = Path()
        stem.move(to: p0)
        stem.addCurve(to: p1, control1: c1, control2: c2)
        Art.stroke(&context, stem, color, width: ArtStyle.detailLine)

        var leaves = Path()
        let count = max(2, min(40, Int(max(0, len) / 26)))
        for i in 1...count {
            let t = CGFloat(i) / CGFloat(count)
            let p = cubicPoint(p0, c1, c2, p1, t)
            let side: CGFloat = i % 2 == 0 ? 1 : -1
            leaves.addPath(tiltedEllipse(p.x + side * 5, p.y, 6, 2.6, side * 0.6))
        }
        Art.fill(&context, leaves, leafColor)
    }

    // MARK: Lights

    static func fireflies(
        _ context: inout GraphicsContext,
        _ n: Int,
        seed: UInt32,
        in box: CGRect,
        dim: Double = 1
    ) {
        var random = ArtRandom(seed)
        let halo = Art.color(0xFFE27A)
        for _ in 0..<max(0, n) {
            let x = box.minX + random.next(in: 0...1) * box.width
            let y = box.minY + random.next(in: 0...1) * box.height
            let r = 1 + random.next(in: 0...1) * 1.8
            let haloAlpha = 0.1 + random.next() * 0.14
            let coreAlpha = 0.7 + random.next() * 0.3
            Art.fill(&context, Art.circle(x, y, r * 4.5), halo.opacity(haloAlpha * dim))
            Art.fill(&context, Art.circle(x, y, r), Art.color(0xFFF7C8, coreAlpha * dim))
        }
    }

    static func stars(
        _ context: inout GraphicsContext,
        _ n: Int,
        seed: UInt32,
        in box: CGRect,
        alpha: Double = 1
    ) {
        var random = ArtRandom(seed)
        for _ in 0..<max(0, n) {
            let x = box.minX + random.next(in: 0...1) * box.width
            let fall = CGFloat(pow(random.next(), 1.6))
            let y = box.minY + fall * box.height
            let r = 0.5 + random.next(in: 0...1) * 1.1
            let a = 0.25 + random.next() * 0.6
            Art.fill(&context, Art.circle(x, y, r), Art.color(0xFFFFFF, a * alpha))
        }
    }

    /// A fan of spider web from (x, y) between the angles `a0` and `a1` (radians).
    static func spiderWeb(
        _ context: inout GraphicsContext,
        _ x: CGFloat, _ y: CGFloat, _ r: CGFloat, _ a0: CGFloat, _ a1: CGFloat,
        alpha: Double = 1,
        width: CGFloat = 0.7
    ) {
        let n = 7
        let step = (a1 - a0) / CGFloat(n)
        var spokes = Path()
        for i in 0...n {
            let a = a0 + step * CGFloat(i)
            spokes.move(to: pt(x, y))
            spokes.addLine(to: pt(x + cos(a) * r, y + sin(a) * r))
        }
        Art.stroke(&context, spokes, Art.color(0xFFFFFF, 0.5 * alpha), width: width, cap: .butt)

        var rings = Path()
        for k in 1...6 {
            let rr = r * CGFloat(k) / 6.3
            for i in 0...n {
                let a = a0 + step * CGFloat(i)
                let p = pt(x + cos(a) * rr, y + sin(a) * rr)
                if i == 0 {
                    rings.move(to: p)
                } else {
                    let am = a0 + step * (CGFloat(i) - 0.5)
                    let c = pt(x + cos(am) * rr * 0.9, y + sin(am) * rr * 0.9)
                    rings.addQuadCurve(to: p, control: c)
                }
            }
        }
        Art.stroke(&context, rings, Art.color(0xFFFFFF, 0.45 * alpha), width: width, cap: .butt)
    }

    /// The small spider of the design, hanging head up. Origin is the middle of its body.
    static func spider(_ context: inout GraphicsContext, _ x: CGFloat, _ y: CGFloat, _ s: CGFloat) {
        Art.group(&context, x: x, y: y, scale: s) { g in
            // A small, round, friendly spider in the story's deep indigo (not black).
            let tone = ArtStyle.anansi.deepColor
            Art.fill(&g, Art.ellipse(0, 0, 4, 5), tone)
            Art.fill(&g, Art.circle(0, -5, 2.6), tone)
            var legs = Path()
            let sides: [CGFloat] = [-1, 1]
            let shapes: [(CGFloat, CGFloat)] = [(-4, 9), (-1, 10), (3, 9), (6, 6)]
            for side in sides {
                for shape in shapes {
                    legs.move(to: pt(0, shape.0))
                    legs.addQuadCurve(to: pt(side * shape.1, shape.0 + 3), control: pt(side * 6, shape.0 - 3))
                }
            }
            Art.stroke(&g, legs, tone, width: 1)
            Art.fill(&g, Art.circle(-1.2, -1.6, 1.1), ArtStyle.warmLight.opacity(0.35))
        }
    }

    /// The big moon: halo, disc and three craters.
    static func moon(_ context: inout GraphicsContext, _ cx: CGFloat, _ cy: CGFloat, _ r: CGFloat, alpha: Double = 1) {
        let k = r / 52
        let halo: [(Color, CGFloat)] = [
            (Art.color(0xFFF4C8, 0.6 * alpha), 0),
            (ArtStyle.warmLight.opacity(0.2 * alpha), 0.35),
            (ArtStyle.warmLight.opacity(0), 1),
        ]
        Art.fillRadial(&context, Art.circle(cx, cy, 150 * k), halo, center: pt(cx, cy), radius: 150 * k)
        let disc: [(Color, CGFloat)] = [(Art.color(0xFFFBE6, alpha), 0), (Art.color(0xFFE08A, alpha), 1)]
        Art.fillRadial(&context, Art.circle(cx, cy, r), disc, center: pt(cx - r * 0.2, cy - r * 0.3), radius: r * 1.6)
        let crater = Art.color(0xF3D27A)
        Art.fill(&context, Art.circle(cx - 16 * k, cy - 14 * k, 9 * k), crater.opacity(0.5 * alpha))
        Art.fill(&context, Art.circle(cx + 18 * k, cy + 18 * k, 13 * k), crater.opacity(0.4 * alpha))
        Art.fill(&context, Art.circle(cx + 14 * k, cy - 20 * k, 5 * k), crater.opacity(0.4 * alpha))
    }

    // MARK: Canopy and motes

    /// Leafy night canopy: `blobs` are (x, y, radius). Leaves left of `calmX` never use the
    /// brightest tone, so light text can sit over them.
    static func nightCanopy(
        _ context: inout GraphicsContext,
        _ blobs: [(CGFloat, CGFloat, CGFloat)],
        seed: UInt32,
        palette pal: [Color],
        calmBefore calmX: CGFloat = -100_000
    ) {
        guard pal.count >= 4 else { return }
        var random = ArtRandom(seed)
        var base = Path()
        var mid = Path()
        var lit = Path()
        var bright = Path()
        for blob in blobs {
            let bx = blob.0
            let by = blob.1
            let br = blob.2
            guard br > 0 else { continue }
            base.addEllipse(in: CGRect(x: bx - br, y: by - br * 0.62, width: br * 2, height: br * 1.24))
            let n = Int((br * 1.3).rounded())
            for _ in 0..<max(0, n) {
                let an = random.next(in: 0...1) * 6.283
                let spread = CGFloat(pow(random.next(), 0.5))
                let d = spread * br * 1.05
                let x = bx + cos(an) * d
                let y = by + sin(an) * d * 0.62
                let sz = 6 + random.next(in: 0...1) * 8
                let la = random.next(in: 0...1) * 6.283
                let litness: CGFloat = ((x - bx) - (y - by)) / br
                let leafShape = tiltedEllipse(x, y, sz, sz * 0.42, rad(la * 57))
                let roll = random.next(in: 0...1)
                let pick = random.next()
                if litness + roll * 0.8 > 1.0 {
                    if pick > 0.7 && x >= calmX {
                        bright.addPath(leafShape)
                    } else {
                        lit.addPath(leafShape)
                    }
                } else if pick > 0.5 {
                    base.addPath(leafShape)
                } else {
                    mid.addPath(leafShape)
                }
            }
        }
        Art.fill(&context, base, pal[0])
        Art.fill(&context, mid, pal[1])
        Art.fill(&context, lit, pal[2])
        Art.fill(&context, bright, pal[3])
    }

    /// One mote of wisdom. kind 0 = web mark, 1 = four-point spark, anything else = a dot.
    static func mote(
        _ context: inout GraphicsContext,
        _ x: CGFloat, _ y: CGFloat, _ s: CGFloat, _ kind: Int,
        alpha: Double = 1
    ) {
        let pale = Art.color(0xFFF3C2, alpha)
        if kind == 0 {
            Art.fill(&context, Art.circle(x, y, s * 6), moteGold.opacity(0.16 * alpha))
            webMark(&context, x, y, s * 4.2, moteGold.opacity(0.95 * alpha), weight: 0.16)
        } else if kind == 1 {
            Art.fill(&context, Art.circle(x, y, s * 5), moteGold.opacity(0.16 * alpha))
            Art.fill(&context, Art.spark(x, y, s * 4), pale)
        } else {
            Art.fill(&context, Art.circle(x, y, s * 4), moteGold.opacity(0.18 * alpha))
            Art.fill(&context, Art.circle(x, y, s * 1.4), pale)
        }
    }

    static func motes(
        _ context: inout GraphicsContext,
        _ points: [(CGFloat, CGFloat, CGFloat, Int)],
        dx: CGFloat = 0,
        dy: CGFloat = 0
    ) {
        for point in points {
            mote(&context, point.0 + dx, point.1 + dy, point.2, point.3)
        }
    }

    // MARK: Sky and finish

    /// The twilight sky. The warm band is anchored to the bottom edge (the last ~150 units);
    /// everything above stays deep indigo to purple, whatever the height.
    static func sky(_ context: inout GraphicsContext, _ w: CGFloat, _ h: CGFloat, _ colors: [Color]) {
        guard colors.count >= 6, h > 0 else { return }
        let l2 = min(1, max(0.05, (h - 245) / h))
        let l1 = min(0.4, max(0, l2 - 0.05))
        let l3 = min(1, max(l2, (h - 144) / h))
        let l4 = min(1, max(l3, (h - 86) / h))
        let l5 = min(1, max(l4, (h - 50) / h))
        let stops: [(Color, CGFloat)] = [
            (colors[0], 0), (colors[1], l1), (colors[2], l2), (colors[3], l3), (colors[4], l4), (colors[5], l5),
        ]
        Art.fillLinear(&context, Art.rect(0, 0, w, h), stops, from: pt(0, 0), to: pt(0, h))
    }

    /// The last pass of every scene, picture, portrait and cover (not the face chips): the
    /// shared paint tooth, light and indigo, then the shared finish. A dark story takes a
    /// little less warm wash than the default.
    static func finishPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let box = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        ArtStyle.tooth(&context, in: box, seed: 7, alpha: 0.05)
        ArtStyle.tooth(&context, in: box, seed: 19, color: ArtStyle.coolShade, alpha: 0.08)
        ArtStyle.finish(&context, size, wash: 0.07, vignette: 0.10)
    }
}
