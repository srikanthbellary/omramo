import SwiftUI
import OmramoCore

// The Temple of Artemis at Ephesus: a lost wonder, so this is OUR OWN RECONSTRUCTION, not a
// record. Only its footings and broken pieces remain. The drawing shows a very wide marble
// temple from the front at a slight angle: eight tall, slender columns with scroll capitals,
// more rows glimpsed behind them and down the side (a forest of columns), a low roof front
// with three plain openings, on a high stepped base in a flat, marshy plain. No statue is
// shown. It keeps its construction lines, a height rule and loose ink edges, so that it reads
// as an artist's idea. Our own drawing (no photograph, nothing traced, and not copied from any
// modern reconstruction). Card background #2A3F5C.

extension LandmarkArt {
    /// The side of the temple runs back toward this point, far off to the right at eye level.
    private static let artemisVanishX: CGFloat = 900
    private static let artemisEyeY: CGFloat = 262
    /// How far back the side is drawn (a fraction of the way to the vanishing point).
    private static let artemisDepth: CGFloat = 0.105
    /// The first front column's centre, and the gap from one column to the next.
    private static let artemisFirstX: CGFloat = 92
    private static let artemisGap: CGFloat = 28.571
    /// The columns stand from the top step up to the beam.
    private static let artemisColumnTop: CGFloat = 150
    private static let artemisFloorY: CGFloat = 256

    /// temple-of-artemis-ephesus: our reconstruction of the wide marble temple, by day.
    static func paintTempleOfArtemis(_ context: inout GraphicsContext) {
        artemisSky(&context)
        artemisPlain(&context)
        // The temple is composed about x 223 and moved a little left, to sit in the middle.
        Art.group(&context, x: -8, y: 0) { g in
            artemisGuides(&g)
            artemisPlatform(&g)
            artemisPorch(&g)
            artemisSideColonnade(&g)
            artemisFrontColonnade(&g)
            artemisEntablature(&g)
            artemisPediment(&g)
            artemisInk(&g)
            artemisFigures(&g)
        }
        artemisReeds(&context)
        artemisFinish(&context)
    }

    /// The point a fraction `t` of the way from (`x`, `y`) to the vanishing point.
    private static func artemisBack(_ x: CGFloat, _ y: CGFloat, _ t: CGFloat) -> CGPoint {
        let px: CGFloat = x + (artemisVanishX - x) * t
        let py: CGFloat = y + (artemisEyeY - y) * t
        return pt(px, py)
    }

    /// Pale marble in the one light: warm white on the left, a cool lilac toward the right.
    private static func artemisMarble(_ context: inout GraphicsContext, _ path: Path) {
        let stops: Kit.Stops = [
            (Art.color(0xFFFBF0), 0),
            (Art.color(0xF6EEDF), 0.5),
            (Art.color(0xE0D9DA), 1),
        ]
        fillHorizontal(&context, path, stops, from: 70, to: 314)
    }

    // MARK: Sky and plain

    private static func artemisSky(_ context: inout GraphicsContext) {
        let sky: Kit.Stops = [
            (Art.color(0x9CC4E0), 0),
            (Art.color(0xC6DEEA), 0.3),
            (Art.color(0xE9EDE2), 0.5),
            (Art.color(0xF6EAD0), 0.65),
            (Art.color(0xF6EAD0), 1),
        ]
        backdrop(&context, sky)
        horizon(&context, y: artemisEyeY, rise: 64, hex: 0xFFE2B4, alpha: 0.32)
        Art.glow(&context, 10, 20, 220, Art.color(0xFFF3D2), alpha: 0.3)
        Art.blurred(&context, radius: 3, opacity: 0.7) { g in
            var clouds = Path()
            clouds.addPath(cloudBand(250, 70, width: 160, height: 11))
            clouds.addPath(cloudBand(-10, 196, width: 120, height: 8))
            clouds.addPath(cloudBand(330, 212, width: 110, height: 7))
            Art.fill(&g, clouds, Art.color(0xFFFFFF, 0.8))
        }

        // The far plane: one far hill and a lower ridge, veiled with the sky's own colour.
        let hill = Art.svg("M-24,264 L-24,240 C30,226 80,218 130,222 C170,226 200,238 240,244 C290,250 340,236 380,228 C410,222 440,226 456,230 L456,264 Z")
        Art.fill(&context, hill, Art.color(0xA9B8CC))
        let ridge = Kit.ridge(width: 480, y: 253, amp: 4, seed: 7, bottom: 264, x0: -24)
        Art.fill(&context, ridge, Art.color(0xB4C2A8, 0.85))
        haze(&context, top: 200, bottom: 264, hex: 0xF6EAD0, alpha: 0.36)
    }

    /// The flat, wet plain: grass, shallow pools that hold the sky, and a few grass marks.
    private static func artemisPlain(_ context: inout GraphicsContext) {
        let top: CGFloat = artemisEyeY
        let ground = Art.rect(-24, top, unitWidth + 48, unitHeight - top + 24)
        let grass: Kit.Stops = [
            (Art.color(0xE2E4BC), 0),
            (Art.color(0xB9C99C), 0.2),
            (Art.color(0x6E8E86), 0.55),
            (Art.color(0x2A3F5C), 1),
        ]
        fillVertical(&context, ground, grass, from: top, to: unitHeight)

        let pools: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
            (40, 272, 26, 2), (392, 275, 30, 2.4), (66, 301, 46, 4.6), (352, 311, 60, 5.6), (196, 330, 72, 6.5),
        ]
        var water = Path()
        for pool in pools {
            water.addEllipse(in: CGRect(x: pool.0 - pool.2, y: pool.1 - pool.3, width: pool.2 * 2, height: pool.3 * 2))
        }
        Art.fill(&context, water, Art.color(0xD4E6EC, 0.75))
        Art.clipped(&context, to: water) { g in
            let whole = CGRect(x: 0, y: 268, width: unitWidth, height: 72)
            ripples(&g, in: whole, count: 60, seed: 11, color: Art.color(0xFFFFFF, 0.6), width: 0.6, length: 6...22)
            ripples(&g, in: whole, count: 40, seed: 19, color: Art.color(0x6E8EA6, 0.35), width: 0.6, length: 6...18)
        }
        let nearGrass = CGRect(x: 0, y: 266, width: unitWidth, height: 30)
        ripples(&context, in: nearGrass, count: 46, seed: 23, color: Art.color(0x7E9A78, 0.4), width: 0.6, length: 4...14)
        let farGrass = CGRect(x: 0, y: 292, width: unitWidth, height: 60)
        ripples(&context, in: farGrass, count: 40, seed: 29, color: Art.color(0xDDE6C0, 0.22), width: 0.8, length: 8...26)
    }

    // MARK: The sketch

    /// A draughtsman's lines: each stroke is drawn twice, a little off and a little long.
    private static func artemisSketch(_ segments: [(CGPoint, CGPoint)], seed: UInt32, overshoot: CGFloat, wobble: Double) -> Path {
        var random = ArtRandom(seed)
        var path = Path()
        let shake: Double = max(0.01, wobble)
        for segment in segments {
            let a = segment.0
            let b = segment.1
            let dx: CGFloat = b.x - a.x
            let dy: CGFloat = b.y - a.y
            let squared: CGFloat = dx * dx + dy * dy
            let length: CGFloat = max(1, squared.squareRoot())
            let ux: CGFloat = dx / length
            let uy: CGFloat = dy / length
            for _ in 0..<2 {
                let over: CGFloat = overshoot * random.next(in: 0.3...1)
                let ax: CGFloat = a.x - ux * over + random.next(in: -shake...shake)
                let ay: CGFloat = a.y - uy * over + random.next(in: -shake...shake)
                let bx: CGFloat = b.x + ux * over + random.next(in: -shake...shake)
                let by: CGFloat = b.y + uy * over + random.next(in: -shake...shake)
                path.move(to: pt(ax, ay))
                path.addLine(to: pt(bx, by))
            }
        }
        return path
    }

    /// Faint guide lines behind the temple: its centre line, level lines that run on past the
    /// building, the lines of the side running back, and a height rule on the left.
    private static func artemisGuides(_ context: inout GraphicsContext) {
        let ink = Art.color(0x3A5A8A, 0.3)
        let axis = Art.line(192, 70, 192, 294)
        Art.stroke(&context, axis, ink, width: 0.5, cap: .butt, dash: [7, 3, 1.5, 3])

        var guides: [(CGPoint, CGPoint)] = []
        let levels: [CGFloat] = [286, 256, 150, 126]
        for level in levels {
            guides.append((pt(52, level), pt(332, level)))
        }
        guides.append((pt(304, 126), artemisBack(304, 126, 0.24)))
        guides.append((pt(314, 286), artemisBack(314, 286, 0.24)))
        guides.append((pt(192, 96), artemisBack(192, 96, 0.2)))
        guides.append((pt(80, 126), pt(80, 290)))
        guides.append((pt(304, 126), pt(304, 290)))
        let lines = artemisSketch(guides, seed: 5, overshoot: 7, wobble: 0.35)
        Art.stroke(&context, lines, ink, width: 0.5)

        let ruleX: CGFloat = 56
        var rule = Art.line(ruleX, 286, ruleX, 96)
        for index in 0...10 {
            let y: CGFloat = 286 - CGFloat(index) * 19
            rule.move(to: pt(ruleX - 3, y))
            rule.addLine(to: pt(ruleX + 3, y))
        }
        Art.stroke(&context, rule, ink, width: 0.6, cap: .butt)
    }

    // MARK: Platform

    /// The high stepped base: five steps across the front, each turning the corner and running
    /// back along the shaded side.
    private static func artemisPlatform(_ context: inout GraphicsContext) {
        let depth: CGFloat = artemisDepth
        // The temple's shadow lies on the plain to the right.
        let far = artemisBack(314, 286, depth)
        let cast = Art.polygon([pt(314, 286), far, pt(424, 289), pt(344, 294)])
        Art.fill(&context, cast, ArtStyle.coolShade.opacity(0.16))
        ArtStyle.contactShadow(&context, 200, 287.5, 136, 4, alpha: 0.22)

        var fronts = Path()
        var sides = Path()
        var lit = Path()
        var under = Path()
        for index in 0..<5 {
            let inset: CGFloat = CGFloat(index) * 4
            let top: CGFloat = 280 - CGFloat(index) * 6
            let left: CGFloat = 70 + inset
            let right: CGFloat = 314 - inset
            fronts.addRect(CGRect(x: left, y: top, width: right - left, height: 6))
            under.addRect(CGRect(x: left, y: top + 4.6, width: right - left, height: 1.4))
            let a = pt(right, top)
            let b = artemisBack(right, top, depth)
            let c = artemisBack(right, top + 6, depth)
            let d = pt(right, top + 6)
            sides.addPath(Art.polygon([a, b, c, d]))
            lit.move(to: pt(left, top + 0.4))
            lit.addLine(to: pt(right, top + 0.4))
        }
        let sideStops: Kit.Stops = [(Art.color(0xCFCAD8), 0), (Art.color(0xB9B6CC), 1)]
        fillHorizontal(&context, sides, sideStops, from: 298, to: 376)
        artemisMarble(&context, fronts)
        Art.fill(&context, under, ArtStyle.coolShade.opacity(0.14))
        Art.stroke(&context, lit, Art.color(0xFFFFFF, 0.8), width: 0.7, cap: .butt)
        // The joints of the big blocks, here and there.
        let joints = CGRect(x: 74, y: 258, width: 236, height: 26)
        ripples(&context, in: joints, count: 22, seed: 43, color: Art.color(0x9A94B0, 0.26), width: 0.5, length: 4...10)
    }
}

// MARK: - Columns, beam and roof

extension LandmarkArt {
    /// One slender column with a scroll capital, centred on `x`: lit on its left, shaded on
    /// its right. `shade` cools a column that stands behind others or on the shaded side.
    private static func artemisColumn(
        _ context: inout GraphicsContext,
        x: CGFloat,
        top: CGFloat,
        bottom: CGFloat,
        width: CGFloat,
        shade: Double
    ) {
        let half: CGFloat = width / 2
        let neck: CGFloat = width * 0.43
        let baseW: CGFloat = width * 1.36
        let capW: CGFloat = width * 1.56
        var body = Path()
        body.addPath(Art.polygon([pt(x - neck, top), pt(x + neck, top), pt(x + half, bottom - 3), pt(x - half, bottom - 3)]))
        body.addRect(CGRect(x: x - baseW / 2, y: bottom - 3, width: baseW, height: 3))
        body.addRect(CGRect(x: x - capW / 2, y: top - 2.6, width: capW, height: 2.6))
        let marble: Kit.Stops = [
            (Art.color(0xFFFCF2), 0),
            (Art.color(0xF6EEDF), 0.45),
            (Art.color(0xCBC6D6), 1),
        ]
        fillHorizontal(&context, body, marble, from: x - half, to: x + half)

        // The grooves down the shaft.
        var flutes = Art.line(x - width * 0.14, top + 3, x - width * 0.16, bottom - 4)
        flutes.move(to: pt(x + width * 0.14, top + 3))
        flutes.addLine(to: pt(x + width * 0.16, bottom - 4))
        Art.stroke(&context, flutes, Art.color(0x9A94B0, 0.3), width: 0.4, cap: .butt)

        // The two scrolls of the capital, hanging below its flat top.
        let roll: CGFloat = width * 0.27
        let reach: CGFloat = width * 0.66
        let rollY: CGFloat = top - 1.8
        var scrolls = Path()
        scrolls.addEllipse(in: CGRect(x: x - reach - roll, y: rollY, width: roll * 2, height: roll * 2))
        scrolls.addEllipse(in: CGRect(x: x + reach - roll, y: rollY, width: roll * 2, height: roll * 2))
        Art.fill(&context, scrolls, Art.color(0xFBF5E8))
        let eye: CGFloat = roll * 0.45
        let eyeY: CGFloat = rollY + roll - eye
        var eyes = Path()
        eyes.addEllipse(in: CGRect(x: x - reach - eye, y: eyeY, width: eye * 2, height: eye * 2))
        eyes.addEllipse(in: CGRect(x: x + reach - eye, y: eyeY, width: eye * 2, height: eye * 2))
        Art.stroke(&context, eyes, Art.color(0x8E88A8, 0.6), width: 0.4)

        if shade > 0 {
            Art.fill(&context, body, ArtStyle.coolShade.opacity(shade))
            Art.fill(&context, scrolls, ArtStyle.coolShade.opacity(shade))
        }
    }

    /// The shaded space behind the front columns, and the rows of columns glimpsed in it.
    private static func artemisPorch(_ context: inout GraphicsContext) {
        let top: CGFloat = artemisColumnTop
        let base: CGFloat = artemisFloorY
        let porch = Art.rect(88, top, 208, base - top)
        let dim: Kit.Stops = [
            (Art.color(0x8088AE), 0),
            (Art.color(0x9A9EBE), 0.6),
            (Art.color(0xB0B0C8), 1),
        ]
        fillVertical(&context, porch, dim, from: top, to: base)
        // The shaded side, behind the columns that run back along it.
        let depth: CGFloat = artemisDepth
        let side = Art.polygon([pt(296, top), artemisBack(296, top, depth), artemisBack(296, base, depth), pt(296, base)])
        let sideDim: Kit.Stops = [(Art.color(0x7A82AA), 0), (Art.color(0x9CA0C0), 1)]
        fillVertical(&context, side, sideDim, from: top, to: base)

        // Third row, then second row: each a little farther back, so a little to the right.
        let rows: [(CGFloat, CGFloat, Double)] = [(0.042, 6.6, 0.34), (0.022, 7.6, 0.2)]
        for row in rows {
            for index in 0..<7 {
                let frontX: CGFloat = artemisFirstX + CGFloat(index) * artemisGap
                let head = artemisBack(frontX, top, row.0)
                let foot = artemisBack(frontX, base, row.0)
                artemisColumn(&context, x: head.x, top: head.y, bottom: foot.y, width: row.1, shade: row.2)
            }
        }
        // The beam throws its shade on the tops of the inner columns.
        let soffit: Kit.Stops = [
            (ArtStyle.coolShade.opacity(0.3), 0),
            (ArtStyle.coolShade.opacity(0), 1),
        ]
        fillVertical(&context, Art.rect(88, top, 208, 26), soffit, from: top, to: top + 26)
    }

    /// The columns down the right side, closing up as they go back.
    private static func artemisSideColonnade(_ context: inout GraphicsContext) {
        // Farthest first: (how far back, width).
        let columns: [(CGFloat, CGFloat)] = [
            (0.102, 5.2), (0.090, 5.6), (0.076, 6.1), (0.060, 6.7), (0.042, 7.3), (0.022, 8),
        ]
        let cornerX: CGFloat = artemisFirstX + 7 * artemisGap
        for column in columns {
            let head = artemisBack(cornerX, artemisColumnTop, column.0)
            let foot = artemisBack(cornerX, artemisFloorY, column.0)
            artemisColumn(&context, x: head.x, top: head.y, bottom: foot.y, width: column.1, shade: 0.14)
        }
    }

    /// The eight columns of the front.
    private static func artemisFrontColonnade(_ context: inout GraphicsContext) {
        for index in 0..<8 {
            let x: CGFloat = artemisFirstX + CGFloat(index) * artemisGap
            ArtStyle.contactShadow(&context, x + 5, artemisFloorY, 8, 1.2, alpha: 0.2)
            artemisColumn(&context, x: x, top: artemisColumnTop, bottom: artemisFloorY, width: 9, shade: 0)
        }
        // A sliver of the key light down the left edge of each shaft.
        var slivers = Path()
        for index in 0..<8 {
            let x: CGFloat = artemisFirstX + CGFloat(index) * artemisGap
            slivers.move(to: pt(x - 3.5, artemisColumnTop + 2))
            slivers.addLine(to: pt(x - 4.1, artemisFloorY - 4))
        }
        Art.stroke(&context, slivers, ArtStyle.warmLight.opacity(0.55), width: 0.8, cap: .butt)
    }

    /// The long beam on the columns and the ledge above it, across the front and back along
    /// the side.
    private static func artemisEntablature(_ context: inout GraphicsContext) {
        let depth: CGFloat = artemisDepth
        let sideBeam = Art.polygon([pt(300, 132), artemisBack(300, 132, depth), artemisBack(300, 150, depth), pt(300, 150)])
        Art.fill(&context, sideBeam, Art.color(0xC9C5D8))
        let sideLedge = Art.polygon([pt(304, 126), artemisBack(304, 126, depth), artemisBack(304, 132, depth), pt(304, 132)])
        Art.fill(&context, sideLedge, Art.color(0xDAD5E0))

        let beam = Art.rect(84, 131, 216, 19)
        artemisMarble(&context, beam)
        model(&context, beam, light: 0.14, shade: 0.12)
        let ledge = Art.rect(80, 126, 224, 5.4)
        Art.fill(&context, ledge, Art.color(0xFFFCF4))

        // The row of small blocks under the ledge, and the beam's own level lines.
        var blocks = Path()
        for index in 0..<36 {
            let x: CGFloat = 86 + CGFloat(index) * 6
            blocks.addRect(CGRect(x: x, y: 132.4, width: 3, height: 2.6))
        }
        Art.fill(&context, blocks, ArtStyle.coolShade.opacity(0.16))
        var levels = Art.line(84, 141, 300, 141)
        levels.move(to: pt(84, 145.5))
        levels.addLine(to: pt(300, 145.5))
        Art.stroke(&context, levels, Art.color(0x9A94B0, 0.34), width: 0.5, cap: .butt)
        Art.stroke(&context, Art.line(80, 126.4, 304, 126.4), Art.color(0xFFFFFF, 0.85), width: 0.8, cap: .butt)
        Art.fill(&context, Art.rect(80, 131.4, 224, 1.6), ArtStyle.coolShade.opacity(0.18))
        // The beam's shade on the tops of the front columns.
        Art.fill(&context, Art.rect(86, 150, 212, 3), ArtStyle.coolShade.opacity(0.14))
    }

    /// The low triangular roof front with its three plain openings, and the roof running back.
    private static func artemisPediment(_ context: inout GraphicsContext) {
        let depth: CGFloat = artemisDepth
        // The roof's right slope, seen running back.
        let roof = Art.polygon([pt(192, 96), pt(304, 126), artemisBack(304, 126, depth), artemisBack(192, 96, depth)])
        let tiles: Kit.Stops = [(Art.color(0xE6D2C2), 0), (Art.color(0xC6B8C4), 1)]
        fillHorizontal(&context, roof, tiles, from: 192, to: 368)
        var rows = Path()
        for index in 1..<8 {
            let t: CGFloat = depth * CGFloat(index) / 8
            rows.move(to: artemisBack(192, 96, t))
            rows.addLine(to: artemisBack(304, 126, t))
        }
        Art.stroke(&context, rows, Art.color(0x8E7E96, 0.3), width: 0.5, cap: .butt)

        let front = Art.polygon([pt(80, 126), pt(192, 96), pt(304, 126)])
        artemisMarble(&context, front)
        model(&context, front, light: 0.2, shade: 0.12)
        let field = Art.polygon([pt(100, 124), pt(192, 99.6), pt(284, 124)])
        Art.fill(&context, field, Art.color(0xB9B6CC, 0.3))
        var openings = Path()
        openings.addRect(CGRect(x: 186, y: 106, width: 12, height: 18))
        openings.addRect(CGRect(x: 151, y: 114, width: 8, height: 10))
        openings.addRect(CGRect(x: 225, y: 114, width: 8, height: 10))
        Art.fill(&context, openings, Art.color(0x6A7098, 0.9))
        var frames = Path()
        frames.addRect(CGRect(x: 184.8, y: 104.8, width: 14.4, height: 19.2))
        frames.addRect(CGRect(x: 149.8, y: 112.8, width: 10.4, height: 11.2))
        frames.addRect(CGRect(x: 223.8, y: 112.8, width: 10.4, height: 11.2))
        Art.stroke(&context, frames, Art.color(0xFFFFFF, 0.7), width: 0.6, cap: .butt, join: .miter)

        // The lit rake on the left, the shaded one on the right, and three small ornaments.
        Art.stroke(&context, Art.line(80, 126, 192, 96), Art.color(0xFFFFFF, 0.9), width: 1.1)
        Art.stroke(&context, Art.line(192, 96, 304, 126), Art.color(0x8E88A8, 0.5), width: 0.8)
        var ornaments = Path()
        ornaments.addPath(Art.polygon([pt(188.6, 96.6), pt(192, 87), pt(195.4, 96.6)]))
        ornaments.addPath(Art.polygon([pt(80, 126), pt(81.6, 118.6), pt(86.4, 124.4)]))
        ornaments.addPath(Art.polygon([pt(297.6, 124.4), pt(302.4, 118.6), pt(304, 126)]))
        Art.fill(&context, ornaments, Art.color(0xFBF5E8))
    }
}

// MARK: - Ink, figures, near plane, finish

extension LandmarkArt {
    /// Loose ink edges over the temple, so that the picture stays a drawing.
    private static func artemisInk(_ context: inout GraphicsContext) {
        let depth: CGFloat = artemisDepth
        var edges: [(CGPoint, CGPoint)] = []
        edges.append((pt(80, 126), pt(192, 96)))
        edges.append((pt(192, 96), pt(304, 126)))
        edges.append((pt(80, 126), pt(304, 126)))
        edges.append((pt(84, 150), pt(300, 150)))
        edges.append((pt(86, 256), pt(298, 256)))
        edges.append((pt(70, 286), pt(314, 286)))
        edges.append((pt(70, 280), pt(70, 286)))
        edges.append((pt(314, 286), artemisBack(314, 286, depth)))
        edges.append((pt(298, 256), artemisBack(298, 256, depth)))
        edges.append((pt(304, 126), artemisBack(304, 126, depth)))
        edges.append((pt(192, 96), artemisBack(192, 96, depth)))
        edges.append((artemisBack(192, 96, depth), artemisBack(304, 126, depth)))
        // The outer edges of the two corner columns.
        edges.append((pt(88, 152), pt(87.5, 252)))
        edges.append((pt(296, 152), pt(296.5, 252)))
        let ink = artemisSketch(edges, seed: 31, overshoot: 2.8, wobble: 0.45)
        Art.stroke(&context, ink, Art.color(0x3A4468, 0.4), width: 0.6)
        let chalk = artemisSketch(edges, seed: 47, overshoot: 1.4, wobble: 0.7)
        Art.stroke(&context, chalk, Art.color(0xFFFFFF, 0.3), width: 0.5)
    }

    /// A few tiny people on the steps and the grass, for scale: robes and heads only.
    private static func artemisFigures(_ context: inout GraphicsContext) {
        let people: [(CGFloat, CGFloat, UInt32)] = [
            (118, 286, 0xB0604E), (129, 286, 0xE6DCC6), (150, 274, 0x4E6A8A),
            (232, 262, 0x9A5A6A), (241, 262, 0xD8C49A), (270, 280, 0x5E7A6A), (334, 291, 0x7A5A80),
        ]
        var heads = Path()
        for person in people {
            let x: CGFloat = person.0
            let y: CGFloat = person.1
            ArtStyle.contactShadow(&context, x + 2, y + 0.3, 4, 1, alpha: 0.3)
            let robe = Art.polygon([pt(x - 1.5, y - 6.4), pt(x + 1.5, y - 6.4), pt(x + 2.4, y), pt(x - 2.4, y)])
            Art.fill(&context, robe, Art.color(person.2))
            Art.fill(&context, Art.rect(x + 0.6, y - 6.4, 1.6, 6.4), ArtStyle.coolShade.opacity(0.2))
            heads.addEllipse(in: CGRect(x: x - 1.5, y: y - 9.2, width: 3, height: 3))
        }
        Art.fill(&context, heads, Art.color(0x8A5A4A))
    }

    /// The near plane: dark marsh reeds in the two bottom corners, low in contrast.
    private static func artemisReeds(_ context: inout GraphicsContext) {
        // (foot x, top x, top y)
        let stems: [(CGFloat, CGFloat, CGFloat)] = [
            (372, 364, 338), (384, 380, 322), (396, 400, 330), (408, 404, 312), (420, 428, 326), (430, 424, 342),
            (8, 14, 344), (20, 16, 332), (34, 42, 348),
        ]
        var stalks = Path()
        var blades = Path()
        var heads = Path()
        var glints = Path()
        for stem in stems {
            let footX: CGFloat = stem.0
            let topX: CGFloat = stem.1
            let topY: CGFloat = stem.2
            let midX: CGFloat = (footX + topX) / 2 + 2
            stalks.move(to: pt(footX, 412))
            stalks.addQuadCurve(to: pt(topX, topY), control: pt(midX, 370))
            heads.addEllipse(in: CGRect(x: topX - 1.9, y: topY - 1, width: 3.8, height: 13))
            glints.addEllipse(in: CGRect(x: topX - 1.7, y: topY, width: 1.1, height: 10))
            blades.addPath(leaf(footX, 410, length: 52, width: 3.4, angle: Kit.deg(-104)))
            blades.addPath(leaf(footX, 410, length: 44, width: 3, angle: Kit.deg(-70)))
        }
        Art.fill(&context, blades, Art.color(0x2E5060))
        Art.stroke(&context, stalks, Art.color(0x24425A), width: ArtStyle.detailLine)
        Art.fill(&context, heads, Art.color(0x4A3A50))
        Art.fill(&context, glints, ArtStyle.warmLight.opacity(0.4))
    }

    // MARK: Finish

    private static func artemisFinish(_ context: inout GraphicsContext) {
        bottomFade(&context, 0x2A3F5C, from: 300, alpha: 0.9)
        // Heavier tooth than a standing building: this one is a drawing on paper.
        tooth(&context, seed: 617, light: 0.08, dark: 0.07)
        let paper = CGRect(x: 0, y: 0, width: unitWidth, height: 300)
        Art.stipple(&context, in: paper, count: 180, seed: 641, color: Art.color(0xFFF6E0), alpha: 0.08, size: 0.4...1)
        finish(&context, wash: 0.10, vignette: 0.08)
    }
}
