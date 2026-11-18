import SwiftUI
import OmramoCore

// The Hanging Gardens of Babylon: an unproven wonder (no trace of it has ever been found), so
// this is OUR OWN RECONSTRUCTION, not a record: our own drawing (no photograph, nothing traced,
// and not copied from any modern artist's reconstruction). Five stepped terraces of sun-baked
// brick with one band of blue glazed brick, planted on every level, with arched openings, thin
// streams of water falling from level to level and a stair up the left side, beside the broad
// river. It keeps its construction lines, a height rule and loose ink edges, and its washes are
// pale, so that it reads as an artist's idea. Card background #1E4A38.

extension LandmarkArt {
    /// The line where the bank meets the river.
    private static let gardensRiverY: CGFloat = 288

    /// The five terraces, bottom to top: (left, right, top, bottom) of each wall face.
    private static func gardensLevels() -> [(CGFloat, CGFloat, CGFloat, CGFloat)] {
        let levels: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
            (76, 356, 244, 282),
            (104, 336, 204, 244),
            (134, 314, 166, 204),
            (164, 290, 130, 166),
            (192, 264, 100, 130),
        ]
        return levels
    }

    /// hanging-gardens-babylon: our reconstruction of the planted terraces beside the river, by day.
    static func paintHangingGardens(_ context: inout GraphicsContext) {
        gardensSky(&context)
        gardensFarCity(&context)
        gardensRiver(&context)
        gardensBank(&context)
        gardensGuides(&context)
        gardensWalls(&context)
        gardensStairs(&context)
        gardensArches(&context)
        gardensBlueBand(&context)
        gardensWater(&context)
        gardensPlanting(&context)
        gardensTrailing(&context)
        gardensInk(&context)
        gardensPeople(&context)
        gardensBoat(&context, x: 112, y: 322)
        gardensReeds(&context)
        gardensFinish(&context)
    }

    // MARK: Sky and the far plane

    private static func gardensSky(_ context: inout GraphicsContext) {
        let sky: Kit.Stops = [
            (Art.color(0xC4DAD8), 0),
            (Art.color(0xE4E6CE), 0.3),
            (Art.color(0xF8E9C4), 0.55),
            (Art.color(0xFBE6BE), 1),
        ]
        backdrop(&context, sky)
        horizon(&context, y: 280, rise: 80, hex: 0xFFDDA8, alpha: 0.32)
        Art.glow(&context, 6, 24, 240, Art.color(0xFFF3D2), alpha: 0.36)
        Art.blurred(&context, radius: 3, opacity: 0.6) { g in
            var clouds = Path()
            clouds.addPath(cloudBand(292, 62, width: 130, height: 8))
            clouds.addPath(cloudBand(-10, 150, width: 96, height: 7))
            Art.fill(&g, clouds, Art.color(0xFFFFFF, 0.8))
        }
    }

    /// The far plane: low hills, palm groves, the long city wall with its towers and a far
    /// stepped temple tower, all veiled with the sky's own colour.
    private static func gardensFarCity(_ context: inout GraphicsContext) {
        let hills = Kit.ridge(width: 480, y: 254, amp: 5, seed: 7, bottom: 282, x0: -24)
        Art.fill(&context, hills, Art.color(0xDCCBA6, 0.75))
        let leftGrove = canopy(from: -12, to: 72, baseY: 263, height: 6, bump: 9, depth: 3, seed: 5)
        let rightGrove = canopy(from: 352, to: 440, baseY: 263, height: 5, bump: 8, depth: 3, seed: 15)
        Art.fill(&context, leftGrove, Art.color(0xA9BE94, 0.6))
        Art.fill(&context, rightGrove, Art.color(0xA9BE94, 0.6))

        // A far temple tower of three steps, to the right.
        var temple = Path()
        temple.addRect(CGRect(x: 384, y: 250, width: 30, height: 13))
        temple.addRect(CGRect(x: 390, y: 242, width: 18, height: 8))
        temple.addRect(CGRect(x: 395, y: 236, width: 8, height: 6))
        Kit.solid(&context, temple, Art.color(0xE2CFA8), light: 0.14, shade: 0.16)

        let stone = Art.color(0xE8D7B0)
        let wall = Art.rect(-24, 262, unitWidth + 48, 18)
        var crenels = Path()
        for index in 0..<78 {
            let x: CGFloat = -22 + CGFloat(index) * 6
            crenels.addRect(CGRect(x: x, y: 259.8, width: 3, height: 2.6))
        }
        Art.fill(&context, crenels, stone)
        Kit.solid(&context, wall, stone, light: 0.12, shade: 0.14)
        let towerPlaces: [CGFloat] = [14, 56, 376, 422]
        var towers = Path()
        var teeth = Path()
        var slits = Path()
        for x in towerPlaces {
            towers.addRect(CGRect(x: x - 6, y: 253, width: 12, height: 27))
            teeth.addRect(CGRect(x: x - 6, y: 250.4, width: 3, height: 2.8))
            teeth.addRect(CGRect(x: x - 1.5, y: 250.4, width: 3, height: 2.8))
            teeth.addRect(CGRect(x: x + 3, y: 250.4, width: 3, height: 2.8))
            slits.addRect(CGRect(x: x - 0.7, y: 258, width: 1.4, height: 4.4))
        }
        Art.fill(&context, teeth, stone)
        Kit.solid(&context, towers, Art.color(0xEEDFBC), light: 0.16, shade: 0.18)
        Art.fill(&context, slits, Art.color(0x8A7488, 0.5))
        let courses = Art.svg("M-24,268 L456,268 M-24,274 L456,274")
        Art.stroke(&context, courses, Art.color(0xA8948A, 0.28), width: 0.5, cap: .butt)
        haze(&context, top: 226, bottom: 282, hex: 0xF8E9C4, alpha: 0.34)
    }

    // MARK: River and bank

    private static func gardensRiver(_ context: inout GraphicsContext) {
        let top: CGFloat = gardensRiverY
        let river = Art.rect(-24, top, unitWidth + 48, unitHeight - top + 24)
        let stops: Kit.Stops = [
            (Art.color(0xDCE8D0), 0),
            (Art.color(0x9CC4B4), 0.18),
            (Art.color(0x4E8A74), 0.55),
            (Art.color(0x1E4A38), 1),
        ]
        fillVertical(&context, river, stops, from: top, to: unitHeight)
        let far = CGRect(x: 0, y: 291, width: unitWidth, height: 18)
        let near = CGRect(x: 0, y: 309, width: unitWidth, height: 80)
        ripples(&context, in: far, count: 40, seed: 3, color: Art.color(0xFFFFFF, 0.42), width: 0.5, length: 6...24)
        ripples(&context, in: near, count: 36, seed: 9, color: Art.color(0xE4F2E6, 0.2), width: 0.8, length: 10...38)
        // The terraces' own warm reflection, and the sun on the water to the left.
        let brick = CGRect(x: 84, y: 292, width: 264, height: 40)
        ripples(&context, in: brick, count: 34, seed: 17, color: Art.color(0xF2D69C, 0.4), width: 1, length: 6...22)
        let green = CGRect(x: 120, y: 298, width: 190, height: 30)
        ripples(&context, in: green, count: 16, seed: 23, color: Art.color(0x8FB888, 0.34), width: 1, length: 5...16)
        let sunPath = CGRect(x: 8, y: 292, width: 76, height: 36)
        ripples(&context, in: sunPath, count: 16, seed: 13, color: Art.color(0xFFE9B8, 0.45), width: 0.9, length: 5...20)
    }

    /// The sandy bank and the brick quay the lowest terrace stands on.
    private static func gardensBank(_ context: inout GraphicsContext) {
        let bank = Art.svg("M-24,278 C60,275 140,277 216,276 C300,275 380,278 456,276 L456,289 C380,291 300,288 216,290 C140,291 60,288 -24,290 Z")
        Kit.solid(&context, bank, stops: Kit.stops(0xEEDCAE, 0xCDB68E), light: 0.12, shade: 0.14)
        ArtStyle.contactShadow(&context, 214, 291, 170, 4, alpha: 0.26)
        let quay = Art.rect(40, 281, 328, 9)
        Kit.solid(&context, quay, stops: Kit.stops(0xE8CE9C, 0xBE9C84), light: 0.14, shade: 0.18)
        let joints = CGRect(x: 44, y: 283, width: 320, height: 6)
        ripples(&context, in: joints, count: 30, seed: 41, color: Art.color(0x9A7868, 0.32), width: 0.5, length: 6...14)
        Art.stroke(&context, Art.line(40, 281, 368, 281), Art.color(0xFFF6DC, 0.8), width: 0.8, cap: .butt)
        let surf = Art.svg("M34,290.500 C56,292 80,289.500 104,291 M168,291 C196,292.500 226,290 254,291.500 M300,291 C326,292 352,290 376,291")
        Art.stroke(&context, surf, Art.color(0xFFFFFF, 0.55), width: 0.9)
    }

    // MARK: The sketch

    /// A draughtsman's lines: each stroke is drawn twice, a little off and a little long.
    private static func gardensSketch(_ segments: [(CGPoint, CGPoint)], seed: UInt32, overshoot: CGFloat, wobble: Double) -> Path {
        var random = ArtRandom(seed)
        var path = Path()
        let shake: Double = max(0.01, wobble)
        for segment in segments {
            let a: CGPoint = segment.0
            let b: CGPoint = segment.1
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

    /// Faint guide lines behind the terraces: a centre line, the level of every terrace carried
    /// out past the walls, the two slopes the steps are fitted to, and a height rule.
    private static func gardensGuides(_ context: inout GraphicsContext) {
        let ink = Art.color(0x6A5068, 0.3)
        let axis = Art.line(228, 58, 228, 284)
        Art.stroke(&context, axis, ink, width: 0.5, cap: .butt, dash: [7, 3, 1.5, 3])

        var guides: [(CGPoint, CGPoint)] = []
        var rule = Art.line(378, 282, 378, 100)
        for level in gardensLevels() {
            let top: CGFloat = level.2
            guides.append((pt(level.0 - 16, top), pt(level.1 + 18, top)))
            rule.move(to: pt(375, top))
            rule.addLine(to: pt(381, top))
        }
        rule.move(to: pt(375, 282))
        rule.addLine(to: pt(381, 282))
        // The slopes: up the stair on the left, and up the corners of the terraces on the right.
        guides.append((pt(48, 282), pt(206, 82)))
        guides.append((pt(366, 282), pt(254, 82)))
        let lines = gardensSketch(guides, seed: 5, overshoot: 7, wobble: 0.35)
        Art.stroke(&context, lines, ink, width: 0.5)
        Art.stroke(&context, rule, ink, width: 0.6, cap: .butt)
    }

    /// Loose ink edges over the terraces, so that the picture stays a drawing.
    private static func gardensInk(_ context: inout GraphicsContext) {
        var edges: [(CGPoint, CGPoint)] = []
        for level in gardensLevels() {
            let left: CGFloat = level.0
            let right: CGFloat = level.1
            let top: CGFloat = level.2
            let bottom: CGFloat = level.3
            edges.append((pt(left, top), pt(right, top)))
            edges.append((pt(left, top), pt(left, bottom)))
            edges.append((pt(right, top), pt(right, bottom)))
        }
        edges.append((pt(40, 281), pt(368, 281)))
        edges.append((pt(40, 290), pt(150, 290)))
        edges.append((pt(48, 282), pt(76, 244)))
        let ink = gardensSketch(edges, seed: 31, overshoot: 2.6, wobble: 0.45)
        Art.stroke(&context, ink, Art.color(0x5A4460, 0.4), width: 0.6)
        let chalk = gardensSketch(edges, seed: 47, overshoot: 1.4, wobble: 0.7)
        Art.stroke(&context, chalk, Art.color(0xFFFFFF, 0.32), width: 0.5)
    }

    // MARK: The terraces

    /// The brick faces of the five terraces: sun-baked ochre, warm on the left, rosier and
    /// shaded to the right, with thin courses and a pale coping along every top.
    private static func gardensWalls(_ context: inout GraphicsContext) {
        let brick: Kit.Stops = [
            (Art.color(0xF6E2B2), 0),
            (Art.color(0xE6C48E), 0.5),
            (Art.color(0xCDA084), 1),
        ]
        var faces = Path()
        var copings = Path()
        var corners = Path()
        var eaves = Path()
        var courses = Path()
        for level in gardensLevels() {
            let left: CGFloat = level.0
            let top: CGFloat = level.2
            let width: CGFloat = level.1 - left
            let height: CGFloat = level.3 - top
            faces.addRect(CGRect(x: left, y: top, width: width, height: height))
            copings.addRect(CGRect(x: left - 2, y: top - 2.5, width: width + 4, height: 3))
            corners.addRect(CGRect(x: level.1 - width * 0.1, y: top, width: width * 0.1, height: height))
            eaves.addRect(CGRect(x: left, y: top + 0.5, width: width, height: 3))
            var y: CGFloat = top + 6
            while y < level.3 - 1 {
                courses.move(to: pt(left, y))
                courses.addLine(to: pt(level.1, y))
                y += 5
            }
        }
        fillHorizontal(&context, faces, brick, from: 76, to: 356)
        model(&context, faces, light: 0.14, shade: 0.14)
        Art.fill(&context, corners, ArtStyle.coolShade.opacity(0.1))
        Art.stroke(&context, courses, Art.color(0xA9785E, 0.22), width: 0.4, cap: .butt)
        Art.fill(&context, eaves, ArtStyle.coolShade.opacity(0.12))
        Art.fill(&context, copings, Art.color(0xFBF0D2))
    }

    /// The stair up the left side: one flight against the left end of every terrace.
    private static func gardensStairs(_ context: inout GraphicsContext) {
        let levels = gardensLevels()
        var flights = Path()
        var treads = Path()
        for index in 0..<levels.count {
            let level = levels[index]
            let start: CGFloat = index == 0 ? 48 : levels[index - 1].0 + 2
            let run: CGFloat = (level.0 - start) / 6
            let rise: CGFloat = (level.3 - level.2) / 6
            flights.move(to: pt(start, level.3))
            for step in 0..<6 {
                let x: CGFloat = start + CGFloat(step) * run
                let y: CGFloat = level.3 - CGFloat(step + 1) * rise
                flights.addLine(to: pt(x, y))
                flights.addLine(to: pt(x + run, y))
                treads.move(to: pt(x, y))
                treads.addLine(to: pt(x + run, y))
            }
            flights.addLine(to: pt(level.0, level.3))
            flights.closeSubpath()
        }
        Kit.solid(&context, flights, stops: Kit.stops(0xF8EACB, 0xDDBE96), light: 0.12, shade: 0.14)
        Art.stroke(&context, treads, Art.color(0xFFFAE6, 0.85), width: 0.7, cap: .butt)
    }

    /// A round-headed opening standing on `baseY`.
    private static func gardensArch(_ cx: CGFloat, _ baseY: CGFloat, width: CGFloat, height: CGFloat) -> Path {
        let half: CGFloat = width / 2
        let spring: CGFloat = baseY - height + half
        let lift: CGFloat = spring - half * 1.33
        var path = Path()
        path.move(to: pt(cx - half, baseY))
        path.addLine(to: pt(cx - half, spring))
        path.addCurve(to: pt(cx + half, spring), control1: pt(cx - half, lift), control2: pt(cx + half, lift))
        path.addLine(to: pt(cx + half, baseY))
        path.closeSubpath()
        return path
    }

    /// The arched openings in every terrace wall: shaded inside, the right jamb catching the light.
    private static func gardensArches(_ context: inout GraphicsContext) {
        // One row for each terrace, bottom to top: (first centre, spacing, width, height).
        let rows: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
            (100, 32, 16, 24), (124, 32, 14, 18), (152, 28, 12, 18), (180, 24, 10, 16), (208, 20, 9, 14),
        ]
        let counts: [Int] = [8, 7, 6, 5, 3]
        let levels = gardensLevels()
        var openings = Path()
        var jambs = Path()
        var sills = Path()
        let rowCount: Int = min(rows.count, min(counts.count, levels.count))
        for index in 0..<rowCount {
            let row = rows[index]
            let baseY: CGFloat = levels[index].3
            for step in 0..<counts[index] {
                let cx: CGFloat = row.0 + CGFloat(step) * row.1
                let half: CGFloat = row.2 / 2
                openings.addPath(gardensArch(cx, baseY, width: row.2, height: row.3))
                let jambTop: CGFloat = baseY - row.3 + half
                jambs.addRect(CGRect(x: cx + half - 1.6, y: jambTop, width: 1.6, height: row.3 - half))
                sills.move(to: pt(cx - half - 1, baseY - 0.4))
                sills.addLine(to: pt(cx + half + 1, baseY - 0.4))
            }
        }
        let dark: Kit.Stops = [
            (Art.color(0x7E5E70, 0.8), 0),
            (Art.color(0xA98274, 0.7), 1),
        ]
        fillVertical(&context, openings, dark, from: 100, to: 282)
        Art.fill(&context, jambs, Art.color(0xF8E4B4, 0.55))
        Art.stroke(&context, openings, Art.color(0xFFF2D0, 0.5), width: 0.6)
        Art.stroke(&context, sills, Art.color(0xFFF6DC, 0.6), width: 0.6, cap: .butt)
    }

    /// The one band of blue glazed brick, along the second terrace, with small gold rosettes.
    private static func gardensBlueBand(_ context: inout GraphicsContext) {
        let band = Art.rect(104, 209, 232, 7)
        let glaze: Kit.Stops = [
            (Art.color(0x8FBEDE), 0),
            (Art.color(0x5E8FC4), 0.6),
            (Art.color(0x4A72AA), 1),
        ]
        fillHorizontal(&context, band, glaze, from: 104, to: 336)
        var rosettes = Path()
        for index in 0..<23 {
            let x: CGFloat = 109 + CGFloat(index) * 10
            rosettes.addEllipse(in: CGRect(x: x - 1.3, y: 211.2, width: 2.6, height: 2.6))
        }
        Art.fill(&context, rosettes, Art.color(0xF6D684))
        let trims = Art.svg("M104,209 L336,209 M104,216 L336,216")
        Art.stroke(&context, trims, Art.color(0xFFF6DC, 0.8), width: 0.7, cap: .butt)
        Art.stroke(&context, Art.line(104, 216.8, 336, 216.8), ArtStyle.coolShade.opacity(0.16), width: 0.8, cap: .butt)
    }

    /// Thin streams of water falling from a spout in each wall to the terrace below, and at
    /// last into the river.
    private static func gardensWater(_ context: inout GraphicsContext) {
        // (x, the spout's height, the foot of the fall)
        let streams: [(CGFloat, CGFloat, CGFloat)] = [
            (218, 106, 130), (192, 136, 166), (240, 136, 166), (194, 172, 204), (250, 172, 204),
            (172, 221, 244), (268, 221, 244), (148, 250, 290), (308, 250, 290),
        ]
        var spouts = Path()
        var falls = Path()
        var edges = Path()
        var splashes = Path()
        for stream in streams {
            let x: CGFloat = stream.0
            spouts.addRect(CGRect(x: x - 1.8, y: stream.1 - 2, width: 3.6, height: 2.4))
            falls.move(to: pt(x, stream.1))
            falls.addLine(to: pt(x, stream.2))
            edges.move(to: pt(x + 0.8, stream.1 + 1))
            edges.addLine(to: pt(x + 0.8, stream.2))
            splashes.addEllipse(in: CGRect(x: x - 3.5, y: stream.2 - 1.2, width: 7, height: 2.4))
        }
        Art.fill(&context, spouts, Art.color(0x7E5E70, 0.8))
        Art.stroke(&context, falls, Art.color(0xEAF7FA, 0.95), width: 1.6, cap: .butt)
        Art.stroke(&context, edges, Art.color(0x7FBAD4, 0.7), width: 0.5, cap: .butt)
        Art.fill(&context, splashes, Art.color(0xFFFFFF, 0.75))
        // Where the two lowest streams meet the river.
        let leftFoam = CGRect(x: 138, y: 290, width: 20, height: 8)
        let rightFoam = CGRect(x: 298, y: 290, width: 20, height: 8)
        ripples(&context, in: leftFoam, count: 6, seed: 61, color: Art.color(0xFFFFFF, 0.7), width: 0.8, length: 3...9)
        ripples(&context, in: rightFoam, count: 6, seed: 67, color: Art.color(0xFFFFFF, 0.7), width: 0.8, length: 3...9)
    }

    // MARK: The planting

    /// The trees of one terrace, standing on `baseY`. Each place is (x, kind, height); kind 0 is
    /// a date palm, 1 a cypress-like tree, anything else a round-crowned tree.
    private static func gardensTrees(_ context: inout GraphicsContext, baseY: CGFloat, _ places: [(CGFloat, Int, CGFloat)]) {
        var trunks = Path()
        var fronds = Path()
        var dates = Path()
        var spires = Path()
        var crowns = Path()
        var lights = Path()
        let up: CGFloat = -CGFloat.pi / 2
        for place in places {
            let x: CGFloat = place.0
            let h: CGFloat = place.2
            let top: CGFloat = baseY - h
            switch place.1 {
            case 0:
                let headX: CGFloat = x + 1.5
                let headY: CGFloat = top + 3
                trunks.move(to: pt(x, baseY))
                trunks.addQuadCurve(to: pt(headX, headY), control: pt(x - 1, baseY - h * 0.5))
                let r: CGFloat = h * 0.42
                for k in 0..<7 {
                    let a: CGFloat = CGFloat.pi * (CGFloat(k) / 6 - 1)
                    let ux: CGFloat = cos(a)
                    let uy: CGFloat = sin(a)
                    let tipX: CGFloat = headX + ux * r
                    let tipY: CGFloat = headY + uy * r * 0.5 + r * 0.45
                    let midX: CGFloat = headX + ux * r * 0.6
                    let midY: CGFloat = headY + uy * r * 0.9 - r * 0.25
                    fronds.move(to: pt(headX, headY))
                    fronds.addQuadCurve(to: pt(tipX, tipY), control: pt(midX, midY))
                }
                dates.addEllipse(in: CGRect(x: headX - 1.2, y: headY + 0.6, width: 2.4, height: 2.6))
            case 1:
                spires.addPath(leaf(x, baseY, length: h, width: h * 0.2, angle: up))
                lights.addPath(leaf(x - 0.7, baseY - 1, length: h * 0.8, width: h * 0.05, angle: up))
            default:
                let r: CGFloat = h * 0.34
                let cy: CGFloat = top + r
                trunks.move(to: pt(x, baseY))
                trunks.addLine(to: pt(x, cy))
                crowns.addEllipse(in: CGRect(x: x - r, y: cy - r, width: r * 2, height: r * 2))
                let sideR: CGFloat = r * 0.8
                let sideY: CGFloat = cy + r * 0.5
                crowns.addEllipse(in: CGRect(x: x - r * 0.75 - sideR, y: sideY - sideR, width: sideR * 2, height: sideR * 2))
                crowns.addEllipse(in: CGRect(x: x + r * 0.75 - sideR, y: sideY - sideR, width: sideR * 2, height: sideR * 2))
                let litR: CGFloat = r * 0.45
                lights.addEllipse(in: CGRect(x: x - r * 0.4 - litR, y: cy - r * 0.3 - litR, width: litR * 2, height: litR * 2))
            }
        }
        Art.stroke(&context, trunks, Art.color(0x9A7A5E), width: 1.3)
        Art.fill(&context, spires, Art.color(0x5E8A70, 0.92))
        Art.fill(&context, crowns, Art.color(0x86B07E, 0.94))
        Art.stroke(&context, fronds, Art.color(0x6E9E72), width: 1.5)
        Art.fill(&context, dates, Art.color(0xD98A4A, 0.85))
        Art.fill(&context, lights, Art.color(0xDCE8AA, 0.55))
    }

    /// Date palms, cypress-like trees and round-crowned trees on every terrace.
    private static func gardensPlanting(_ context: inout GraphicsContext) {
        let first: [(CGFloat, Int, CGFloat)] = [
            (112, 2, 15), (128, 0, 26), (146, 1, 22), (166, 2, 15), (184, 0, 24), (204, 1, 20), (222, 2, 15), (242, 0, 26),
            (262, 2, 14), (280, 1, 22), (300, 0, 24), (318, 2, 15), (334, 1, 20), (346, 0, 26), (352, 2, 13),
        ]
        let second: [(CGFloat, Int, CGFloat)] = [
            (142, 1, 22), (158, 2, 15), (176, 0, 26), (198, 2, 14), (214, 1, 20), (236, 0, 24),
            (258, 2, 15), (276, 1, 22), (294, 0, 24), (310, 2, 14), (322, 0, 26), (330, 1, 20),
        ]
        let third: [(CGFloat, Int, CGFloat)] = [
            (172, 2, 14), (190, 0, 24), (206, 1, 20), (224, 2, 14), (246, 0, 22),
            (264, 2, 14), (280, 1, 20), (296, 0, 26), (307, 2, 13),
        ]
        let fourth: [(CGFloat, Int, CGFloat)] = [
            (198, 1, 18), (218, 2, 13), (238, 0, 22), (258, 2, 13), (272, 1, 20), (283, 0, 24),
        ]
        let fifth: [(CGFloat, Int, CGFloat)] = [
            (204, 2, 16), (216, 0, 26), (230, 1, 22), (242, 2, 15), (254, 0, 20),
        ]
        gardensTrees(&context, baseY: 100, fifth)
        gardensTrees(&context, baseY: 130, fourth)
        gardensTrees(&context, baseY: 166, third)
        gardensTrees(&context, baseY: 204, second)
        gardensTrees(&context, baseY: 244, first)
    }

    /// Low shrubs along the edge of every terrace, and the plants that trail down over its wall.
    private static func gardensTrailing(_ context: inout GraphicsContext) {
        var random = ArtRandom(83)
        var vines = Path()
        var clumps = Path()
        var blossoms = Path()
        var seed: UInt32 = 41
        var counter: Int = 0
        for level in gardensLevels() {
            let left: CGFloat = level.0
            let top: CGFloat = level.2
            let width: CGFloat = level.1 - left
            seed += 1
            let shrubs = canopy(from: left + 2, to: level.1 - 10, baseY: top - 2, height: 4, bump: 9, depth: 3, seed: seed)
            Art.fill(&context, shrubs, Art.color(0x7FA878, 0.94))
            let count: Int = Int(width / 7)
            for _ in 0..<count {
                let x: CGFloat = left + 2 + (width - 4) * random.next(in: 0...1)
                let length: CGFloat = random.next(in: 4...13)
                let sway: CGFloat = random.next(in: -2.5...2.5)
                let endX: CGFloat = x + sway
                let endY: CGFloat = top + length
                vines.move(to: pt(x, top - 1))
                vines.addQuadCurve(to: pt(endX, endY), control: pt(x - sway, top + length * 0.5))
                let dot = CGRect(x: endX - 1.3, y: endY - 1.3, width: 2.6, height: 2.6)
                counter += 1
                if counter % 4 == 0 {
                    blossoms.addEllipse(in: dot)
                } else {
                    clumps.addEllipse(in: dot)
                }
            }
        }
        Art.stroke(&context, vines, Art.color(0x5E9270, 0.9), width: 1.1)
        Art.fill(&context, clumps, Art.color(0x9CC488))
        Art.fill(&context, blossoms, Art.color(0xF8C8C2))
    }

    // MARK: People, the boat and the near reeds

    /// Three tiny people on the quay and at the foot of the stair, for the scale.
    private static func gardensPeople(_ context: inout GraphicsContext) {
        let places: [(CGFloat, CGFloat)] = [(330, 281), (339, 281.4), (62, 281.2)]
        var robes = Path()
        var heads = Path()
        for place in places {
            let x: CGFloat = place.0
            let y: CGFloat = place.1
            robes.addPath(Art.polygon([pt(x - 1.2, y - 6.4), pt(x + 1.2, y - 6.4), pt(x + 2, y), pt(x - 2, y)]))
            heads.addEllipse(in: CGRect(x: x - 1.3, y: y - 9, width: 2.6, height: 2.7))
            ArtStyle.contactShadow(&context, x + 1.4, y + 0.3, 3.4, 1, alpha: 0.3)
        }
        Art.fill(&context, robes, Art.color(0xB0604E))
        Art.fill(&context, heads, Art.color(0x7A5648))
    }

    /// A small round reed boat of the river, with one person and a pole.
    private static func gardensBoat(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat) {
        Art.group(&context, x: x, y: y) { g in
            ArtStyle.contactShadow(&g, 2, 11.5, 19, 3, alpha: 0.32)
            let wake = CGRect(x: -22, y: 10, width: 44, height: 9)
            ripples(&g, in: wake, count: 8, seed: 71, color: Art.color(0xFFFFFF, 0.42), width: 0.8, length: 4...12)
            // The person stands in the boat, behind its near rim.
            Art.stroke(&g, Art.line(7, -17, 12, 9), Art.color(0x6A4A3C), width: 0.9)
            let robe = Art.polygon([pt(-3.6, -11), pt(0.4, -11), pt(1.8, 1), pt(-5, 1)])
            Art.fill(&g, robe, Art.color(0xF2E6CC))
            Art.fill(&g, Art.rect(-0.8, -11, 2.2, 12), ArtStyle.coolShade.opacity(0.14))
            Art.stroke(&g, Art.line(-0.4, -8.6, 7.6, -6.4), Art.color(0x9A6A54), width: 1.2)
            Art.fill(&g, Art.circle(-1.6, -13.4, 2.5), Art.color(0x9A6A54))
            let bowl = Art.svg("M-14,0 C-14,8 -8,11.500 0,11.500 C8,11.500 14,8 14,0 Z")
            Kit.solid(&g, bowl, stops: Kit.stops(0xD9B478, 0x9A7450), light: 0.2, shade: 0.24)
            let weave = Art.svg("M-13,3 C-6,6 6,6 13,3 M-10.500,6.500 C-4,9 4,9 10.500,6.500 M-7,1 L-5,10 M0,2 L0,11 M7,1 L5,10")
            Art.stroke(&g, weave, Art.color(0x7A5438, 0.4), width: 0.6)
            let rim = Art.ellipse(0, 0, 14, 3.2)
            Art.fill(&g, rim, Art.color(0x8A6448))
            Art.stroke(&g, rim, Art.color(0xF2D8A0), width: 1)
        }
    }

    /// Reeds on the far bank, and the near plane: darker reeds in the two bottom corners.
    private static func gardensReeds(_ context: inout GraphicsContext) {
        Kit.reeds(&context, x: 24, baseY: 292, count: 5, height: 24, seed: 3, color: 0x7FA070)
        Kit.reeds(&context, x: 398, baseY: 292, count: 6, height: 26, seed: 19, color: 0x7FA070)
        Kit.reeds(&context, x: 406, baseY: 410, count: 9, height: 84, seed: 7, color: 0x2C6A4C)
        Kit.reeds(&context, x: 22, baseY: 412, count: 6, height: 58, seed: 11, color: 0x2C6A4C)
    }

    // MARK: Finish

    private static func gardensFinish(_ context: inout GraphicsContext) {
        bottomFade(&context, 0x1E4A38, from: 300, alpha: 0.88)
        // Heavier tooth than a standing building: this one is a drawing on paper.
        tooth(&context, seed: 619, light: 0.08, dark: 0.07)
        let paper = CGRect(x: 0, y: 0, width: unitWidth, height: 300)
        Art.stipple(&context, in: paper, count: 180, seed: 641, color: Art.color(0xFFF6E0), alpha: 0.08, size: 0.4...1)
        finish(&context, wash: 0.10, vignette: 0.08)
    }
}
