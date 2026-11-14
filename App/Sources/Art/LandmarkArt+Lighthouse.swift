import SwiftUI

// The Lighthouse of Alexandria: a lost wonder, so this is OUR OWN RECONSTRUCTION, not a record.
// Nobody knows exactly how it looked. The drawing follows only what the old descriptions agree
// on (a square level, an eight-sided level, a round level, a fire and a statue on top) and it
// keeps its construction lines and loose ink edges so that it reads as an artist's idea.
// Not traced from any modern reconstruction. Card background #0B2A4A.

extension LandmarkArt {
    /// The tower's centre line: the middle of the picture.
    private static let pharosX: CGFloat = 216
    /// The island was first drawn round x 262; it moves with the tower.
    private static let pharosShift: CGFloat = 216 - 262
    /// The height of the fire.
    private static let pharosFireY: CGFloat = 57

    static func paintLighthouse(_ context: inout GraphicsContext) {
        pharosSky(&context)
        pharosBeams(&context)
        pharosSea(&context)
        pharosConstructionLines(&context)
        pharosIsland(&context)
        pharosTower(&context)
        pharosInk(&context)
        // Two ships balance the centred tower: a nearer one on the lit side, a far one beyond.
        pharosShip(&context, x: 70, y: 298, scale: 0.94, flipped: false)
        pharosShip(&context, x: 368, y: 284, scale: 0.58, flipped: true)
        pharosFinish(&context)
    }

    // MARK: Sky and sea

    private static func pharosSky(_ context: inout GraphicsContext) {
        let sky: [(Color, CGFloat)] = [
            (Art.color(0x14234E), 0),
            (Art.color(0x2C376E), 0.25),
            (Art.color(0x6B5286), 0.45),
            (Art.color(0xC6717A), 0.58),
            (Art.color(0xF4AA69), 0.66),
            (Art.color(0xF4AA69), 1),
        ]
        backdrop(&context, sky)
        stars(&context, count: 40, seed: 7, maxY: 150, color: Art.color(0xFFF3DC))

        // The shared horizon band, then the last of the sunset, low on the left.
        horizon(&context, y: 267, rise: 70, hex: 0xFFC482, alpha: 0.35)
        Art.glow(&context, 52, 268, 170, Art.color(0xFFB56C), alpha: 0.5)

        Art.blurred(&context, radius: 3, opacity: 0.5) { g in
            var clouds = Path()
            clouds.addPath(cloudBand(-14, 224, width: 160, height: 10))
            clouds.addPath(cloudBand(250, 240, width: 120, height: 7))
            clouds.addPath(cloudBand(322, 214, width: 130, height: 9))
            Art.fill(&g, clouds, Art.color(0x8E5A86))
            // The undersides nearest the sunset catch its colour.
            var lit = Path()
            lit.addPath(cloudBand(-10, 225, width: 110, height: 4))
            lit.addPath(cloudBand(254, 241, width: 70, height: 3))
            Art.fill(&g, lit, Art.color(0xFFB98A, 0.7))
        }

        // The far plane: the far shore and the city on the left, a low headland on the right,
        // both very faint and veiled with the sky's own colour.
        let shore = Art.svg("M-12,268 L-12,258 L18,256 L30,251 L38,256 L66,257 L82,253 L92,257 L120,259 L150,262 L182,267 Z")
        Art.fill(&context, shore, Art.color(0x5E4C80, 0.75))
        let headland = Art.svg("M444,268 L444,257 C430,255 420,257 408,254 C396,251 386,257 372,259 C356,261 342,264 326,267 Z")
        Art.fill(&context, headland, Art.color(0x5E4C80, 0.6))
        haze(&context, top: 240, bottom: 268, hex: 0xF4AA69, alpha: 0.3)
    }

    private static func pharosBeams(_ context: inout GraphicsContext) {
        let cx = pharosX
        let fy = pharosFireY
        let left = Art.polygon([pt(cx - 3, fy), pt(-24, 108), pt(-24, 176)])
        let right = Art.polygon([pt(cx + 3, fy), pt(456, 6), pt(456, 58)])
        let leftStops: [(Color, CGFloat)] = [
            (Art.color(0xFFE2A0, 0.6), 0),
            (Art.color(0xFFE2A0, 0.2), 0.55),
            (Art.color(0xFFE2A0, 0), 1),
        ]
        let rightStops: [(Color, CGFloat)] = [
            (Art.color(0xFFE2A0, 0.5), 0),
            (Art.color(0xFFE2A0, 0.14), 0.6),
            (Art.color(0xFFE2A0, 0), 1),
        ]
        let origin = CGPoint(x: cx, y: fy)
        Art.blurred(&context, radius: 3) { g in
            Art.fillLinear(&g, left, leftStops, from: origin, to: CGPoint(x: 0, y: 140))
            Art.fillLinear(&g, right, rightStops, from: origin, to: CGPoint(x: 440, y: 32))
        }
        // The turning of the light, drawn as a dashed ring: half light, half draughtsman's mark.
        let sweep = Art.ellipse(cx, fy, 170, 22)
        Art.stroke(&context, sweep, Art.color(0xFFE2A0, 0.2), width: 0.7, cap: .butt, dash: [2, 5])
    }

    private static func pharosSea(_ context: inout GraphicsContext) {
        let sea = Art.rect(-24, 266, unitWidth + 48, unitHeight - 266 + 24)
        let stops: [(Color, CGFloat)] = [
            (Art.color(0xA9788C), 0),
            (Art.color(0x3D5484), 0.16),
            (Art.color(0x143C64), 0.55),
            (Art.color(0x0B2A4A), 1),
        ]
        fillVertical(&context, sea, stops, from: 266, to: unitHeight)

        let far = CGRect(x: 0, y: 268, width: unitWidth, height: 22)
        let near = CGRect(x: 0, y: 288, width: unitWidth, height: 100)
        ripples(&context, in: far, count: 44, seed: 3, color: Art.color(0xFFD9B0, 0.3), width: 0.5, length: 6...26)
        ripples(&context, in: near, count: 46, seed: 9, color: Art.color(0xBFD3F2, 0.14), width: 0.8, length: 10...40)
        // The sunset on the water, and the fire's own path of light.
        let sunPath = CGRect(x: 18, y: 269, width: 80, height: 54)
        ripples(&context, in: sunPath, count: 22, seed: 13, color: Art.color(0xFFC482, 0.4), width: 0.9, length: 5...22)
        let firePath = CGRect(x: pharosX - 15, y: 284, width: 30, height: 96)
        ripples(&context, in: firePath, count: 30, seed: 21, color: Art.color(0xFFD796, 0.42), width: 1, length: 4...18)

        // The causeway to the island: a low stone mole on little arches.
        let mole = Art.polygon([pt(-12, 267), pt(160, 259), pt(160, 265), pt(-12, 274)])
        let moleStops: [(Color, CGFloat)] = [
            (Art.color(0x8E7A96), 0),
            (Art.color(0xD9BC9E), 1),
        ]
        fillHorizontal(&context, mole, moleStops, from: 0, to: 160)
        var openings = Path()
        for index in 0..<9 {
            let x = 14 + CGFloat(index) * 16
            let y = 271.4 - x * 0.049
            openings.addEllipse(in: CGRect(x: x - 2.4, y: y - 1.6, width: 4.8, height: 4.4))
        }
        Art.fill(&context, openings, Art.color(0x2A3560, 0.6))
        let moleTop = Art.line(-12, 267, 160, 259)
        Art.stroke(&context, moleTop, Art.color(0xFFE9C8, 0.6), width: 0.6)

        // The near plane: two long, quiet swells, a little darker than the sea, their crests
        // just catching the evening. Low contrast: the card fades this part into its colour.
        let swells = Art.svg(
            "M-24,318 C40,310 96,324 160,316 C230,308 290,324 456,314 L456,330 "
                + "C300,338 220,324 150,331 C90,337 40,326 -24,333 Z"
        )
        Art.fill(&context, swells, Art.color(0x0B2A4A, 0.3))
        let crests = Art.svg("M-24,318 C40,310 96,324 160,316 C230,308 290,324 456,314 M-24,350 C60,343 130,356 216,348 C300,341 370,354 456,346")
        Art.stroke(&context, crests, Art.color(0xBFD3F2, 0.14), width: 0.9)
    }

    // MARK: The sketch

    /// A draughtsman's lines: each stroke is drawn twice, a little off and a little long.
    private static func pharosSketch(_ segments: [(CGPoint, CGPoint)], seed: UInt32, overshoot: CGFloat, wobble: Double) -> Path {
        var random = ArtRandom(seed)
        var path = Path()
        let shake = max(0.01, wobble)
        for segment in segments {
            let a = segment.0
            let b = segment.1
            let dx = b.x - a.x
            let dy = b.y - a.y
            let squared = dx * dx + dy * dy
            let length = max(1, squared.squareRoot())
            let ux = dx / length
            let uy = dy / length
            for _ in 0..<2 {
                let over = overshoot * random.next(in: 0.3...1)
                let ax = a.x - ux * over + random.next(in: -shake...shake)
                let ay = a.y - uy * over + random.next(in: -shake...shake)
                let bx = b.x + ux * over + random.next(in: -shake...shake)
                let by = b.y + uy * over + random.next(in: -shake...shake)
                path.move(to: pt(ax, ay))
                path.addLine(to: pt(bx, by))
            }
        }
        return path
    }

    /// Faint guide lines behind the tower: centre line, level lines, the taper, a height rule.
    private static func pharosConstructionLines(_ context: inout GraphicsContext) {
        let cx = pharosX
        let chalk = Art.color(0xF6E8D2, 0.24)

        let axis = Art.line(cx, 16, cx, 262)
        Art.stroke(&context, axis, chalk, width: 0.5, cap: .butt, dash: [7, 3, 1.5, 3])

        var guides: [(CGPoint, CGPoint)] = []
        let levels: [CGFloat] = [238, 142, 89, 66, 42]
        for level in levels {
            guides.append((pt(cx - 64, level), pt(cx + 78, level)))
        }
        // The taper of the lowest level, carried on up to where its sides would meet.
        guides.append((pt(cx - 30, 238), pt(cx - 17.6, 40)))
        guides.append((pt(cx + 30, 238), pt(cx + 17.6, 40)))
        // Diagonals that find the middle of the square level.
        guides.append((pt(cx - 30, 238), pt(cx + 24, 142)))
        guides.append((pt(cx + 30, 238), pt(cx - 24, 142)))
        let lines = pharosSketch(guides, seed: 5, overshoot: 7, wobble: 0.35)
        Art.stroke(&context, lines, chalk, width: 0.5)

        // A height rule to the right, with a tick at every level.
        let ruleX = cx + 70
        var rule = Art.line(ruleX, 238, ruleX, 28)
        var y: CGFloat = 238
        while y >= 28 {
            rule.move(to: pt(ruleX - 2, y))
            rule.addLine(to: pt(ruleX + 2, y))
            y -= 16
        }
        for level in levels {
            rule.move(to: pt(ruleX - 4.5, level))
            rule.addLine(to: pt(ruleX + 4.5, level))
        }
        Art.stroke(&context, rule, chalk, width: 0.5, cap: .butt)
    }

    // MARK: Island

    private static func pharosIsland(_ context: inout GraphicsContext) {
        let cx = pharosX
        let shift = CGAffineTransform(translationX: pharosShift, y: 0)
        // The island's reflection: a soft dark shape lying under it on the water.
        ArtStyle.contactShadow(&context, cx + 10, 281, 104, 7, alpha: 0.34)
        let rocks = Art.svg(
            "M170,273 C180,263 190,263 197,256 L205,250 L213,252 L221,246 L304,246 L311,251 L320,249 L328,257 "
                + "C338,260 348,266 356,275 C322,281 206,281 170,273 Z"
        )
            .applying(shift)
        let rockStops: [(Color, CGFloat)] = [
            (Art.color(0x9A7E8C), 0),
            (Art.color(0x5A4E72), 0.5),
            (Art.color(0x2C3256), 1),
        ]
        fillVertical(&context, rocks, rockStops, from: 246, to: 279)
        let facets = Art.svg("M197,256 L204,272 M213,252 L220,270 M311,251 L306,268 M328,257 L322,274 M236,262 L246,276 M288,260 L282,277")
            .applying(shift)
        Art.clipped(&context, to: rocks) { g in
            Art.fill(&g, Art.rect(cx - 102, 244, 70, 40), Art.color(0xFFC68E, 0.2))
            Art.stroke(&g, facets, Art.color(0x241E40, 0.4), width: 0.7)
        }
        // The one light on the rock: warm on its left shoulder, indigo to the lower right.
        model(&context, rocks, light: 0.22, shade: 0.3, rim: 0.5)
        // Surf at the foot of the rocks.
        let surf = Art.svg("M168,274 C176,277 184,275 192,277 M202,279 C214,281 226,279 238,281 M300,280 C314,281 330,279 344,277 M350,275 L360,276")
            .applying(shift)
        Art.stroke(&context, surf, Art.color(0xFFFFFF, 0.5), width: 0.9)

        // The walled court the tower stands in, with its contact shadow on the rock.
        ArtStyle.contactShadow(&context, cx + 6, 249, 54, 4, alpha: 0.3)
        let court = Art.polygon([pt(cx - 46, 248), pt(cx - 42, 235), pt(cx + 42, 235), pt(cx + 46, 248)])
        let courtStops: [(Color, CGFloat)] = [
            (Art.color(0xF0D2AC), 0),
            (Art.color(0xC9A892), 0.55),
            (Art.color(0x7C6C8E), 1),
        ]
        fillHorizontal(&context, court, courtStops, from: cx - 46, to: cx + 46)
        model(&context, court, light: 0.18, shade: 0.24)
        var merlons = Path()
        for index in 0..<14 {
            let x = cx - 41 + CGFloat(index) * 6.2
            merlons.addRect(CGRect(x: x, y: 232.6, width: 3, height: 2.6))
        }
        fillHorizontal(&context, merlons, courtStops, from: cx - 46, to: cx + 46)
        Art.fill(&context, Art.rect(cx - 30, 238, 9, 10), Art.color(0x3A3058, 0.8))
    }

    // MARK: Tower

    private static func pharosTower(_ context: inout GraphicsContext) {
        let cx = pharosX
        let fy = pharosFireY
        let litStops: [(Color, CGFloat)] = [
            (Art.color(0xF8DFB8), 0),
            (Art.color(0xDDB896), 1),
        ]
        let shadeStops: [(Color, CGFloat)] = [
            (Art.color(0xA08AA4), 0),
            (Art.color(0x675C86), 1),
        ]

        // Level one: square. Two faces show, the left one in the last light.
        let litFace = Art.polygon([pt(cx - 30, 238), pt(cx - 24, 142), pt(cx + 5, 142), pt(cx + 6, 238)])
        let shadeFace = Art.polygon([pt(cx + 6, 238), pt(cx + 5, 142), pt(cx + 24, 142), pt(cx + 30, 238)])
        fillVertical(&context, litFace, litStops, from: 142, to: 238)
        fillVertical(&context, shadeFace, shadeStops, from: 142, to: 238)
        let hatchOne = diagonals(in: CGRect(x: cx + 4, y: 140, width: 28, height: 100), spacing: 3.4, rising: true)
        Art.clipped(&context, to: shadeFace) { g in
            Art.stroke(&g, hatchOne, Art.color(0x2B2444, 0.22), width: 0.5, cap: .butt)
        }

        // Stone courses, lightly.
        var courses = Path()
        var courseY: CGFloat = 154
        while courseY < 236 {
            let reach = 24 + (courseY - 142) / 96 * 6
            courses.move(to: pt(cx - reach, courseY))
            courses.addLine(to: pt(cx + reach, courseY))
            courseY += 12
        }
        Art.stroke(&context, courses, Art.color(0x6A5470, 0.22), width: 0.5, cap: .butt)

        // Slit windows and the door.
        var slits = Path()
        let slitColumns: [CGFloat] = [-19, -9, 0, 13, 21]
        let slitRows: [CGFloat] = [158, 180, 202]
        for row in slitRows {
            for column in slitColumns {
                slits.addRect(CGRect(x: cx + column - 0.8, y: row, width: 1.6, height: 4.4))
            }
        }
        Art.fill(&context, slits, Art.color(0x3A3058, 0.7))
        Art.fill(&context, Art.rect(cx - 15, 223, 7, 15), Art.color(0x2E2648, 0.85))

        // The first terrace.
        let terraceOne = Art.rect(cx - 27, 138, 54, 5)
        let terraceStops: [(Color, CGFloat)] = [
            (Art.color(0xFFEBCB), 0),
            (Art.color(0xE3C29E), 0.55),
            (Art.color(0x8B7A98), 1),
        ]
        fillHorizontal(&context, terraceOne, terraceStops, from: cx - 27, to: cx + 27)
        Art.fill(&context, Art.rect(cx - 25, 143, 50, 1.6), Art.color(0x3A3058, 0.3))
        var cornerPosts = Path()
        let corners: [CGFloat] = [-25.5, 5, 25.5]
        for corner in corners {
            cornerPosts.move(to: pt(cx + corner, 138))
            cornerPosts.addLine(to: pt(cx + corner, 132.5))
        }
        Art.stroke(&context, cornerPosts, Art.color(0xE3C29E), width: 1.6, cap: .butt)

        // Level two: eight-sided. Three faces show.
        let faceLeft = Art.polygon([pt(cx - 15, 138), pt(cx - 12.5, 92), pt(cx - 5.6, 92), pt(cx - 6.8, 138)])
        let faceMiddle = Art.polygon([pt(cx - 6.8, 138), pt(cx - 5.6, 92), pt(cx + 5.6, 92), pt(cx + 6.8, 138)])
        let faceRight = Art.polygon([pt(cx + 6.8, 138), pt(cx + 5.6, 92), pt(cx + 12.5, 92), pt(cx + 15, 138)])
        Art.fill(&context, faceLeft, Art.color(0xFAE4C0))
        Art.fill(&context, faceMiddle, Art.color(0xD8B79C))
        Art.fill(&context, faceRight, Art.color(0x8C7A98))
        let hatchTwo = diagonals(in: CGRect(x: cx + 4, y: 90, width: 14, height: 50), spacing: 3, rising: true)
        Art.clipped(&context, to: faceRight) { g in
            Art.stroke(&g, hatchTwo, Art.color(0x2B2444, 0.22), width: 0.5, cap: .butt)
        }
        var slitsTwo = Path()
        slitsTwo.addRect(CGRect(x: cx - 0.7, y: 104, width: 1.4, height: 4))
        slitsTwo.addRect(CGRect(x: cx - 0.7, y: 120, width: 1.4, height: 4))
        slitsTwo.addRect(CGRect(x: cx - 10.4, y: 112, width: 1.2, height: 4))
        Art.fill(&context, slitsTwo, Art.color(0x3A3058, 0.65))

        // The second terrace.
        let terraceTwo = Art.rect(cx - 14.5, 89, 29, 4)
        fillHorizontal(&context, terraceTwo, terraceStops, from: cx - 14.5, to: cx + 14.5)

        // Level three: round.
        var drum = Path()
        drum.move(to: pt(cx - 8, 89))
        drum.addLine(to: pt(cx - 7, 66))
        drum.addLine(to: pt(cx + 7, 66))
        drum.addLine(to: pt(cx + 8, 89))
        drum.closeSubpath()
        let roundStops: [(Color, CGFloat)] = [
            (Art.color(0xFBE6C4), 0),
            (Art.color(0xE6C8A4), 0.3),
            (Art.color(0xB79A94), 0.65),
            (Art.color(0x77688E), 1),
        ]
        fillHorizontal(&context, drum, roundStops, from: cx - 8, to: cx + 8)
        var bands = Path()
        let bandLevels: [CGFloat] = [72, 80]
        for level in bandLevels {
            bands.move(to: pt(cx - 7.5, level))
            bands.addQuadCurve(to: pt(cx + 7.5, level), control: pt(cx, level + 3))
        }
        Art.stroke(&context, bands, Art.color(0x4A3E60, 0.35), width: 0.6)

        // The lantern: a ring of columns round the fire, under a small cone.
        let lanternFloor = Art.rect(cx - 9.5, 63.4, 19, 3)
        fillHorizontal(&context, lanternFloor, terraceStops, from: cx - 9.5, to: cx + 9.5)
        Art.glow(&context, cx, fy, 96, Art.color(0xFFC062), alpha: 0.5)
        Art.glow(&context, cx, fy, 28, Art.color(0xFFE9B0), alpha: 0.95)
        let flame = Art.svg("M0,6 C-4,4 -3.4,-1 -1.2,-3 C-1,-0.6 0.4,-1.4 0.2,-6 C3,-3 4,2 0,6 Z")
            .applying(CGAffineTransform(translationX: cx, y: fy))
        Art.fill(&context, flame, Art.color(0xFFF6D8))
        var columns = Path()
        let columnOffsets: [CGFloat] = [-7, -2.4, 2.4, 7]
        for offset in columnOffsets {
            columns.move(to: pt(cx + offset, 63.4))
            columns.addLine(to: pt(cx + offset, 51.5))
        }
        Art.stroke(&context, columns, Art.color(0x5A4A66), width: 1.1, cap: .butt)
        let cone = Art.polygon([pt(cx - 9.5, 52), pt(cx, 41.5), pt(cx + 9.5, 52)])
        let coneStops: [(Color, CGFloat)] = [
            (Art.color(0xE6C6A0), 0),
            (Art.color(0x8E7A90), 0.5),
            (Art.color(0x54496E), 1),
        ]
        fillHorizontal(&context, cone, coneStops, from: cx - 9.5, to: cx + 9.5)
        Art.fill(&context, Art.rect(cx - 9.5, 51.2, 19, 1.4), Art.color(0xFFD796, 0.8))

        // The one light, from the upper left: a warm edge up the left of every level, and the
        // indigo core shadow gathering low on the shaded faces.
        var rim = Art.line(cx - 29.2, 237, cx - 23.3, 143.5)
        rim.move(to: pt(cx - 14.3, 137))
        rim.addLine(to: pt(cx - 11.9, 93))
        rim.move(to: pt(cx - 7.4, 88))
        rim.addLine(to: pt(cx - 6.4, 67))
        Art.stroke(&context, rim, ArtStyle.warmLight.opacity(0.85), width: 1.3)
        let core: [(Color, CGFloat)] = [
            (ArtStyle.coolShade.opacity(0), 0),
            (ArtStyle.coolShade.opacity(0.1), 0.5),
            (ArtStyle.coolShade.opacity(0.3), 1),
        ]
        fillVertical(&context, shadeFace, core, from: 142, to: 238)
        fillVertical(&context, faceRight, core, from: 92, to: 138)
        // The terraces throw a little shade onto the lit wall below them.
        var underTerrace = Path()
        underTerrace.addRect(CGRect(x: cx - 24, y: 143, width: 29, height: 3.2))
        underTerrace.addRect(CGRect(x: cx - 12.5, y: 93, width: 18, height: 2.4))
        Art.fill(&context, underTerrace, ArtStyle.coolShade.opacity(0.16))

        // Only a hint of the statue: a standing figure with a staff. Nobody knows whose it was.
        let figure = Art.polygon([pt(cx - 1.7, 42), pt(cx - 1.1, 34), pt(cx + 1.1, 34), pt(cx + 1.7, 42)])
        Art.fill(&context, figure, Art.color(0x4A3E5E))
        Art.fill(&context, Art.circle(cx, 32.4, 1.5), Art.color(0x4A3E5E))
        var staff = Art.line(cx - 2.8, 42, cx - 2.8, 28.5)
        staff.move(to: pt(cx + 1, 35.4))
        staff.addLine(to: pt(cx + 3.6, 31))
        Art.stroke(&context, staff, Art.color(0x4A3E5E), width: 0.7)
        Art.stroke(&context, Art.line(cx - 1.5, 41, cx - 1, 34.4), Art.color(0xFFD796, 0.7), width: 0.5)
    }

    /// Loose ink edges over the tower, so that it stays a drawing.
    private static func pharosInk(_ context: inout GraphicsContext) {
        let cx = pharosX
        var edges: [(CGPoint, CGPoint)] = []
        // Level one.
        edges.append((pt(cx - 30, 238), pt(cx - 24, 142)))
        edges.append((pt(cx + 30, 238), pt(cx + 24, 142)))
        edges.append((pt(cx + 6, 238), pt(cx + 5, 142)))
        edges.append((pt(cx - 27, 138), pt(cx + 27, 138)))
        edges.append((pt(cx - 27, 143), pt(cx + 27, 143)))
        // Level two.
        edges.append((pt(cx - 15, 138), pt(cx - 12.5, 92)))
        edges.append((pt(cx + 15, 138), pt(cx + 12.5, 92)))
        edges.append((pt(cx - 6.8, 138), pt(cx - 5.6, 92)))
        edges.append((pt(cx + 6.8, 138), pt(cx + 5.6, 92)))
        edges.append((pt(cx - 14.5, 89), pt(cx + 14.5, 89)))
        // Level three and the lantern.
        edges.append((pt(cx - 8, 89), pt(cx - 7, 66)))
        edges.append((pt(cx + 8, 89), pt(cx + 7, 66)))
        edges.append((pt(cx - 9.5, 63.4), pt(cx + 9.5, 63.4)))
        edges.append((pt(cx - 9.5, 52), pt(cx, 41.5)))
        edges.append((pt(cx + 9.5, 52), pt(cx, 41.5)))
        // The court wall.
        edges.append((pt(cx - 46, 248), pt(cx - 42, 235)))
        edges.append((pt(cx + 46, 248), pt(cx + 42, 235)))
        edges.append((pt(cx - 42, 235), pt(cx - 30, 235)))
        edges.append((pt(cx + 30, 235), pt(cx + 42, 235)))

        let ink = pharosSketch(edges, seed: 31, overshoot: 2.6, wobble: 0.45)
        Art.stroke(&context, ink, Art.color(0x2B2444, 0.5), width: 0.6)
        let chalk = pharosSketch(edges, seed: 47, overshoot: 1.4, wobble: 0.7)
        Art.stroke(&context, chalk, Art.color(0xFFF1DA, 0.22), width: 0.5)
    }

    // MARK: Ships

    /// A small ship of the ancient kind: curved hull, one mast, one square sail, a steering oar.
    private static func pharosShip(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, scale: CGFloat, flipped: Bool) {
        let mirror: CGFloat = flipped ? -1 : 1
        let sailStops: [(Color, CGFloat)] = [
            (Art.color(0xFCE8C6), 0),
            (Art.color(0xDCAA82), 1),
        ]
        Art.group(&context, x: x, y: y, scale: scale, scaleX: mirror) { g in
            ArtStyle.contactShadow(&g, 2, 3.4, 26, 2.6, alpha: 0.4)
            ripples(&g, in: CGRect(x: -16, y: 5, width: 32, height: 12), count: 7, seed: 61, color: Art.color(0xFCE8C6, 0.3), width: 0.8, length: 4...12)

            Art.stroke(&g, Art.line(-18, -4, -26, 4.5), Art.color(0x2A1E30), width: 1)
            Art.stroke(&g, Art.line(0, -3, 0, -32), Art.color(0x2A1E30), width: 1.1)
            var rigging = Art.line(0, -32, -21, -10)
            rigging.move(to: pt(0, -32))
            rigging.addLine(to: pt(23, -7))
            Art.stroke(&g, rigging, Art.color(0x2A1E30, 0.5), width: 0.4)

            let sail = Art.svg("M-13,-28 L13,-28 C15.5,-21 15.5,-14 12,-8 L-12,-8 C-14.5,-14 -15,-21 -13,-28 Z")
            fillVertical(&g, sail, sailStops, from: -28, to: -8)
            let seams = Art.svg("M-5,-28 C-6,-21 -6,-14 -4.6,-8 M4,-28 C5.4,-21 5.4,-14 4,-8")
            Art.stroke(&g, seams, Art.color(0xB8563F, 0.55), width: 1)
            Art.stroke(&g, Art.line(-15, -28, 15, -28), Art.color(0x2A1E30), width: 1.1)

            let hull = Art.svg("M-22,0 C-14,6 12,6 21,-1 L25,-9 C20,-5 16,-3 11,-3 L-13,-3 C-18,-3 -21,-7 -22,-12 C-26,-7 -26,-3 -22,0 Z")
            Art.fill(&g, hull, Art.color(0x3A2A40))
            let wale = Art.svg("M-21.500,-1.500 C-13,3 11,3 21,-3")
            Art.stroke(&g, wale, Art.color(0xE0AE72, 0.75), width: 0.8)
        }
    }

    // MARK: Finish

    private static func pharosFinish(_ context: inout GraphicsContext) {
        bottomFade(&context, 0x0B2A4A, from: 300, alpha: 0.85)
        // Heavier tooth than the other cards: this one is a drawing on paper.
        tooth(&context, seed: 411, light: 0.08, dark: 0.08)
        let paper = CGRect(x: 0, y: 0, width: unitWidth, height: 300)
        Art.stipple(&context, in: paper, count: 180, seed: 433, color: Art.color(0xFFE9C8), alpha: 0.07, size: 0.4...1)
        // A dusk picture: a little less wash.
        finish(&context, wash: 0.06, vignette: 0.08)
    }
}
