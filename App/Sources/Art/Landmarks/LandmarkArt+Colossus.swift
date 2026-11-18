import SwiftUI
import OmramoCore

// The Colossus of Rhodes: a lost wonder, so this is OUR OWN RECONSTRUCTION, not a record.
// Nobody knows exactly how or where it stood. The drawing shows a bronze sun god with a crown
// of rays, feet together on a tall white stone pedestal BESIDE the harbour (never astride the
// harbour mouth), one hand shading his eyes and a cloak over the other arm. It keeps its
// construction lines, a height rule and loose ink edges, so that it reads as an artist's idea.
// Not traced from any modern reconstruction. Card background #123A5C.

extension LandmarkArt {
    /// The statue's centre line: the middle of the picture.
    private static let colossusX: CGFloat = 216
    /// The sea's horizon.
    private static let colossusSeaY: CGFloat = 264
    /// The figure is drawn with its feet at y 214 and moved down by this much.
    private static let colossusDrop: CGFloat = 10

    /// colossus-of-rhodes: our reconstruction of the bronze sun god beside the harbour, by day.
    static func paintColossus(_ context: inout GraphicsContext) {
        colossusSky(&context)
        colossusCoast(&context)
        colossusSea(&context)
        colossusTownWall(&context)
        colossusMole(&context)
        colossusGuides(&context)
        colossusPedestal(&context)
        Art.group(&context, x: 0, y: colossusDrop) { g in
            colossusCloakAndLegs(&g)
            colossusTorso(&g)
            colossusHead(&g)
        }
        colossusInk(&context)
        colossusShip(&context, x: 84, y: 300, scale: 0.8, flipped: false)
        colossusShip(&context, x: 352, y: 293, scale: 0.5, flipped: true)
        colossusShip(&context, x: 108, y: 270, scale: 0.3, flipped: false)
        colossusRocks(&context)
        colossusFinish(&context)
    }

    // MARK: Sky, coast, sea

    private static func colossusSky(_ context: inout GraphicsContext) {
        let sky: Kit.Stops = [
            (Art.color(0x7DB6DE), 0),
            (Art.color(0xA9D2EA), 0.3),
            (Art.color(0xDDECE8), 0.5),
            (Art.color(0xFBE8C6), 0.64),
            (Art.color(0xFBE8C6), 1),
        ]
        backdrop(&context, sky)
        horizon(&context, y: colossusSeaY, rise: 70, hex: 0xFFDDA8, alpha: 0.35)
        Art.glow(&context, 6, 24, 230, Art.color(0xFFF3D2), alpha: 0.34)
        Art.blurred(&context, radius: 3, opacity: 0.7) { g in
            var clouds = Path()
            clouds.addPath(cloudBand(262, 128, width: 150, height: 11))
            clouds.addPath(cloudBand(-6, 178, width: 140, height: 10))
            clouds.addPath(cloudBand(306, 204, width: 120, height: 8))
            Art.fill(&g, clouds, Art.color(0xFFFFFF, 0.85))
        }
        Kit.birds(&context, 96, 132, scale: 0.5, color: Art.color(0x4A6A9A, 0.5))
    }

    /// The top of the town wall at `x`: it climbs gently to the right.
    private static func colossusWallTop(_ x: CGFloat) -> CGFloat {
        252 - (x - 262) * 0.0928
    }

    /// The far plane: a far coast, the island's own hill and the flat-roofed town, all veiled.
    private static func colossusCoast(_ context: inout GraphicsContext) {
        let far = Kit.ridge(width: 480, y: 254, amp: 9, seed: 9, bottom: 268, x0: -24)
        Art.fill(&context, far, Art.color(0x9DB4D2, 0.8))
        let hill = Art.svg("M236,266 C270,248 320,240 372,234 C408,230 436,226 456,222 L456,266 Z")
        Kit.solid(&context, hill, stops: Kit.stops(0xD9CFA6, 0xC2B48E), light: 0.14, shade: 0.12)
        let groves = canopy(from: 296, to: 456, baseY: 240, height: 6, bump: 11, depth: 5, seed: 3)
        Art.clipped(&context, to: hill) { g in
            Art.fill(&g, groves, Art.color(0x9DB48C, 0.55))
        }
        // Flat-roofed houses standing behind the wall.
        let houses: [(CGFloat, CGFloat, CGFloat)] = [
            (318, 12, 9), (333, 10, 12), (349, 14, 8), (372, 12, 11), (391, 14, 9), (413, 12, 12), (431, 14, 9),
        ]
        var walls = Path()
        var sides = Path()
        var doors = Path()
        for house in houses {
            let x: CGFloat = house.0
            let w: CGFloat = house.1
            let bottom: CGFloat = colossusWallTop(x) + 3
            let top: CGFloat = bottom - house.2 - 4
            walls.addRect(CGRect(x: x, y: top, width: w, height: bottom - top))
            sides.addRect(CGRect(x: x + w * 0.66, y: top, width: w * 0.34, height: bottom - top))
            doors.addRect(CGRect(x: x + w * 0.25, y: top + 3, width: 1.8, height: 3))
        }
        Art.fill(&context, walls, Art.color(0xF6EEDF))
        Art.fill(&context, sides, ArtStyle.coolShade.opacity(0.14))
        Art.fill(&context, doors, Art.color(0x6A6488, 0.5))
        haze(&context, top: 205, bottom: 266, hex: 0xFBE8C6, alpha: 0.3)
    }

    private static func colossusSea(_ context: inout GraphicsContext) {
        let top: CGFloat = colossusSeaY
        let sea = Art.rect(-24, top, unitWidth + 48, unitHeight - top + 24)
        let stops: Kit.Stops = [
            (Art.color(0xCFE6E4), 0),
            (Art.color(0x7FBAD4), 0.15),
            (Art.color(0x3C83AE), 0.5),
            (Art.color(0x123A5C), 1),
        ]
        fillVertical(&context, sea, stops, from: top, to: unitHeight)
        let far = CGRect(x: 0, y: 266, width: unitWidth, height: 20)
        let near = CGRect(x: 0, y: 286, width: unitWidth, height: 96)
        ripples(&context, in: far, count: 40, seed: 3, color: Art.color(0xFFFFFF, 0.4), width: 0.5, length: 6...24)
        ripples(&context, in: near, count: 40, seed: 9, color: Art.color(0xDFF1F6, 0.2), width: 0.8, length: 10...38)
        // Sunlight on the water to the left, and the statue's own warm reflection.
        let sunPath = CGRect(x: 14, y: 268, width: 90, height: 44)
        ripples(&context, in: sunPath, count: 20, seed: 13, color: Art.color(0xFFE9B8, 0.45), width: 0.9, length: 5...20)
        let stone = CGRect(x: 190, y: 286, width: 52, height: 14)
        ripples(&context, in: stone, count: 12, seed: 17, color: Art.color(0xFFFFFF, 0.4), width: 1, length: 5...16)
        let bronze = CGRect(x: 198, y: 298, width: 36, height: 44)
        ripples(&context, in: bronze, count: 20, seed: 21, color: Art.color(0xF3C680, 0.38), width: 1, length: 4...16)
    }

    /// The low town wall with its towers, pale: it is a long way behind the statue.
    private static func colossusTownWall(_ context: inout GraphicsContext) {
        let stone = Art.color(0xEADFCB)
        let wall = Art.polygon([pt(262, 252), pt(456, 234), pt(456, 246), pt(262, 264)])
        var crenels = Path()
        for index in 0..<32 {
            let x: CGFloat = 264 + CGFloat(index) * 6
            crenels.addRect(CGRect(x: x, y: colossusWallTop(x) - 2.4, width: 3, height: 3))
        }
        Art.fill(&context, crenels, stone)
        Kit.solid(&context, wall, stone, light: 0.16, shade: 0.18)
        let towerPlaces: [CGFloat] = [290, 356, 424]
        var towers = Path()
        var teeth = Path()
        var slits = Path()
        for x in towerPlaces {
            let top: CGFloat = colossusWallTop(x) - 10
            let foot: CGFloat = colossusWallTop(x) + 13
            towers.addRect(CGRect(x: x - 6, y: top, width: 12, height: foot - top))
            teeth.addRect(CGRect(x: x - 6, y: top - 2.6, width: 3, height: 2.8))
            teeth.addRect(CGRect(x: x - 1.5, y: top - 2.6, width: 3, height: 2.8))
            teeth.addRect(CGRect(x: x + 3, y: top - 2.6, width: 3, height: 2.8))
            slits.addRect(CGRect(x: x - 0.7, y: top + 5, width: 1.4, height: 4.4))
        }
        Art.fill(&context, teeth, stone)
        Kit.solid(&context, towers, Art.color(0xF0E6D4), light: 0.18, shade: 0.2)
        Art.fill(&context, slits, Art.color(0x6A6488, 0.55))
        let courses = Art.svg("M262,258 L456,240")
        Art.stroke(&context, courses, Art.color(0x9A94A8, 0.3), width: 0.5, cap: .butt)
    }

    /// The harbour mole the pedestal stands on: the statue is beside the water, not over it.
    private static func colossusMole(_ context: inout GraphicsContext) {
        ArtStyle.contactShadow(&context, 300, 285, 176, 4, alpha: 0.3)
        let face = Art.rect(140, 274, 330, 10)
        Kit.solid(&context, face, stops: Kit.stops(0xDCD0BC, 0xB6ACB6), light: 0.14, shade: 0.2)
        let deck = Art.polygon([pt(147, 268), pt(470, 268), pt(470, 274), pt(140, 274)])
        Art.fill(&context, deck, Art.color(0xF4EBD8))
        let joints = CGRect(x: 144, y: 276, width: 300, height: 6)
        ripples(&context, in: joints, count: 26, seed: 41, color: Art.color(0x8A8098, 0.32), width: 0.5, length: 6...14)
        Art.stroke(&context, Art.line(147, 268, 456, 268), Art.color(0xFFFFFF, 0.7), width: 0.7, cap: .butt)
        let surf = Art.svg("M136,284 C150,286 164,283.5 180,285 M250,285 C270,286.500 292,284 312,285.500 M352,285 C370,286 388,284 404,285")
        Art.stroke(&context, surf, Art.color(0xFFFFFF, 0.55), width: 0.9)
    }

    // MARK: The sketch

    /// A draughtsman's lines: each stroke is drawn twice, a little off and a little long.
    private static func colossusSketch(_ segments: [(CGPoint, CGPoint)], seed: UInt32, overshoot: CGFloat, wobble: Double) -> Path {
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

    /// Faint guide lines behind the statue: a centre line, level lines and a height rule with
    /// ten divisions (the statue was about as tall as a ten-floor building).
    private static func colossusGuides(_ context: inout GraphicsContext) {
        let cx: CGFloat = colossusX
        let ink = Art.color(0x3A5A8A, 0.3)
        let axis = Art.line(cx, 44, cx, 262)
        Art.stroke(&context, axis, ink, width: 0.5, cap: .butt, dash: [7, 3, 1.5, 3])

        var guides: [(CGPoint, CGPoint)] = []
        let levels: [CGFloat] = [224, 162, 106, 74]
        for level in levels {
            guides.append((pt(cx - 58, level), pt(cx + 66, level)))
        }
        guides.append((pt(cx - 26, 266), pt(cx - 22, 74)))
        guides.append((pt(cx + 26, 266), pt(cx + 22, 74)))
        let lines = colossusSketch(guides, seed: 5, overshoot: 7, wobble: 0.35)
        Art.stroke(&context, lines, ink, width: 0.5)

        let ruleX: CGFloat = cx + 58
        var rule = Art.line(ruleX, 224, ruleX, 74)
        for index in 0...10 {
            let y: CGFloat = 224 - CGFloat(index) * 15
            rule.move(to: pt(ruleX - 3, y))
            rule.addLine(to: pt(ruleX + 3, y))
        }
        Art.stroke(&context, rule, ink, width: 0.6, cap: .butt)
    }

    /// Loose ink edges over the pedestal and the mole, so that the picture stays a drawing.
    private static func colossusInk(_ context: inout GraphicsContext) {
        let cx: CGFloat = colossusX
        var edges: [(CGPoint, CGPoint)] = []
        edges.append((pt(cx - 26, 266), pt(cx - 24, 230)))
        edges.append((pt(cx + 26, 266), pt(cx + 24, 230)))
        edges.append((pt(cx - 29, 224), pt(cx + 29, 224)))
        edges.append((pt(cx - 29, 230), pt(cx + 29, 230)))
        edges.append((pt(cx - 33, 265), pt(cx + 33, 265)))
        edges.append((pt(cx - 33, 272), pt(cx + 33, 272)))
        edges.append((pt(140, 274), pt(190, 274)))
        edges.append((pt(244, 274), pt(330, 274)))
        edges.append((pt(140, 274), pt(140, 284)))
        // A few strokes on the figure: the line of the legs and of the shoulders.
        edges.append((pt(cx - 14, 162), pt(cx - 10, 216)))
        edges.append((pt(cx + 14, 162), pt(cx + 10, 216)))
        edges.append((pt(cx - 19, 107), pt(cx - 13, 138)))
        let ink = colossusSketch(edges, seed: 31, overshoot: 2.6, wobble: 0.45)
        Art.stroke(&context, ink, Art.color(0x3A4468, 0.42), width: 0.6)
        let chalk = colossusSketch(edges, seed: 47, overshoot: 1.4, wobble: 0.7)
        Art.stroke(&context, chalk, Art.color(0xFFFFFF, 0.3), width: 0.5)
    }

    // MARK: Pedestal

    private static func colossusPedestal(_ context: inout GraphicsContext) {
        let cx: CGFloat = colossusX
        // The pedestal's shadow lies along the mole to the right.
        let cast = Art.polygon([pt(cx + 30, 269), pt(cx + 96, 269), pt(cx + 104, 273.5), pt(cx + 32, 273.5)])
        Art.fill(&context, cast, ArtStyle.coolShade.opacity(0.18))
        let base = Art.rect(cx - 33, 265, 66, 7)
        let shaft = Art.polygon([pt(cx - 26, 266), pt(cx - 24, 230), pt(cx + 24, 230), pt(cx + 26, 266)])
        let cornice = Art.rect(cx - 29, 224, 58, 6)
        Kit.solid(&context, shaft, Art.color(0xF6F1E6), light: 0.2, shade: 0.24)
        Kit.solid(&context, base, Art.color(0xEFE8DA), light: 0.2, shade: 0.24)
        Kit.solid(&context, cornice, Art.color(0xFBF7EE), light: 0.2, shade: 0.2)
        var courses = Path()
        let rows: [CGFloat] = [239, 248, 257]
        for row in rows {
            courses.move(to: pt(cx - 25, row))
            courses.addLine(to: pt(cx + 25, row))
        }
        courses.move(to: pt(cx - 8, 230))
        courses.addLine(to: pt(cx - 8, 239))
        courses.move(to: pt(cx + 10, 239))
        courses.addLine(to: pt(cx + 10, 248))
        courses.move(to: pt(cx - 4, 248))
        courses.addLine(to: pt(cx - 4, 257))
        Art.stroke(&context, courses, Art.color(0x9A94A8, 0.36), width: 0.5, cap: .butt)
        Art.fill(&context, Art.rect(cx - 24, 230, 48, 2.4), ArtStyle.coolShade.opacity(0.16))
        Art.stroke(&context, Art.line(cx - 25.4, 265, cx - 23.5, 231), ArtStyle.warmLight.opacity(0.8), width: 1, cap: .butt)
        // The statue's own small shadow on the top of the pedestal.
        ArtStyle.contactShadow(&context, cx + 4, 224.5, 22, 2, alpha: 0.3)
    }

    // MARK: The statue (drawn with its feet at y 214)

    /// Sun-warm bronze, a little chalky: lit on the left, plum shade on the right.
    private static func colossusBronze(_ context: inout GraphicsContext, _ path: Path, light: Double, shade: Double) {
        let stops: Kit.Stops = [
            (Art.color(0xF5CB88), 0),
            (Art.color(0xDBA462), 0.5),
            (Art.color(0xAC7A66), 1),
        ]
        fillHorizontal(&context, path, stops, from: 192, to: 242)
        model(&context, path, light: light, shade: shade)
    }

    private static func colossusDrape(_ context: inout GraphicsContext, _ path: Path) {
        Kit.solid(&context, path, stops: Kit.stops(0xD29A68, 0xA07468), light: 0.18, shade: 0.22)
    }

    private static func colossusLimb(_ data: String, width: CGFloat) -> Path {
        Art.svg(data).strokedPath(StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round))
    }

    private static func colossusCloakAndLegs(_ context: inout GraphicsContext) {
        // The cloak falls from the far shoulder, over the arm, to the knee.
        let cloak = Art.svg("M229,95 C238,96 244,106 245,120 C247,140 250,164 253,190 C248,186 245,191 241,186 C240,168 237,150 233,136 C231,122 230,108 229,95 Z")
        colossusDrape(&context, cloak)
        let cloakFolds = Art.svg("M238,104 C241,130 244,160 247,186 M234,114 C237,136 239,160 243,184")
        Art.stroke(&context, cloakFolds, Art.color(0x7A5048, 0.42), width: 0.8)

        // Feet together.
        let leftLeg = Art.svg("M202,150 C201,170 204,186 206,208 L215,208 L215.5,150 Z")
        let rightLeg = Art.svg("M216.5,150 L217,208 L226,208 C228,186 231,170 230,150 Z")
        colossusBronze(&context, leftLeg, light: 0.22, shade: 0.14)
        colossusBronze(&context, rightLeg, light: 0.12, shade: 0.24)
        let leftFoot = Art.svg("M203,208 L215,208 L215,214 L200,214 C200,211 201,209 203,208 Z")
        let rightFoot = Art.svg("M217,208 L229,208 C231,209 232,211 232,214 L217,214 Z")
        colossusBronze(&context, leftFoot, light: 0.1, shade: 0.1)
        colossusBronze(&context, rightFoot, light: 0.06, shade: 0.2)
        let marks = Art.svg("M205,180 C207,183 211,183 213,180 M219,180 C221,183 225,183 227,180 M216,152 L216,207")
        Art.stroke(&context, marks, Art.color(0x8A5A4A, 0.36), width: 0.7)
    }

    private static func colossusTorso(_ context: inout GraphicsContext) {
        let torso = Art.svg("M196,98 C198,93 206,91 216,91 C226,91 234,93 236,98 C236,110 231,120 229,130 C229,138 231,144 231,152 L201,152 C201,144 203,138 203,130 C201,120 196,110 196,98 Z")
        colossusBronze(&context, torso, light: 0.26, shade: 0.22)
        ArtStyle.rimEdge(&context, torso, bounds: torso.boundingRect, width: 1.2, alpha: 0.6)
        let chest = Art.svg("M204,108 C210,112 222,112 228,108 M216,112 L216,130 M208,122 C211,124 213,124 215,123 M217,123 C219,124 221,124 224,122")
        Art.stroke(&context, chest, Art.color(0x8A5A4A, 0.34), width: 0.7)

        // The cloak wraps the hips.
        let wrap = Art.svg("M201,137 C210,143 222,143 231,135 L233,157 C222,164 210,165 200,159 Z")
        colossusDrape(&context, wrap)
        let wrapFolds = Art.svg("M204,143 C212,150 222,150 231,142 M203,151 C212,157 222,157 232,150")
        Art.stroke(&context, wrapFolds, Art.color(0x7A5048, 0.42), width: 0.8)

        // The lowered arm carries the cloak.
        let lowArm = colossusLimb("M234,100 C239,110 241,120 240,130 L234,139", width: 7.5)
        colossusBronze(&context, lowArm, light: 0.12, shade: 0.22)
        let overArm = Art.svg("M233,131 C239,127 245,129 246,137 C242,141 237,142 232,140 Z")
        colossusDrape(&context, overArm)
        Art.fill(&context, Art.circle(233, 140, 3), Art.color(0xC8946A))
    }

    /// The head with its crown of sun rays, and the raised hand shading the eyes.
    private static func colossusHead(_ context: inout GraphicsContext) {
        let cx: CGFloat = colossusX
        Art.glow(&context, cx, 70, 44, Art.color(0xFFF1C0), alpha: 0.5)
        var rays = Path()
        let angles: [CGFloat] = [-150, -130, -110, -90, -70, -50, -30]
        for degrees in angles {
            let a: CGFloat = Kit.deg(degrees)
            let ux: CGFloat = cos(a)
            let uy: CGFloat = sin(a)
            let reach: CGFloat = degrees == -90 ? 25 : 22
            let bx: CGFloat = cx + ux * 10
            let by: CGFloat = 72 + uy * 10
            rays.move(to: pt(bx - uy * 1.8, by + ux * 1.8))
            rays.addLine(to: pt(cx + ux * reach, 72 + uy * reach))
            rays.addLine(to: pt(bx + uy * 1.8, by - ux * 1.8))
            rays.closeSubpath()
        }
        let gold: Kit.Stops = [(Art.color(0xFFE9A0), 0), (Art.color(0xE8B04E), 1)]
        fillHorizontal(&context, rays, gold, from: 192, to: 240)

        let neck = Art.rect(211.5, 82, 9, 11)
        colossusBronze(&context, neck, light: 0.08, shade: 0.2)
        let head = Art.ellipse(cx, 74, 9, 10.5)
        colossusBronze(&context, head, light: 0.26, shade: 0.2)
        let hair = Art.svg("M206,75 C205,64 211,61 216,61 C221,61 227,64 226,75 C223,69.500 220,67.500 216,67.500 C212,67.500 209,69.500 206,75 Z")
        Art.fill(&context, hair, Art.color(0xB98058))
        Art.fill(&context, Art.rect(210, 84.6, 12, 2), ArtStyle.coolShade.opacity(0.18))
        // The face is barely there: two faint marks under the shading hand.
        var face = Path()
        face.addEllipse(in: CGRect(x: 212.4, y: 76, width: 1.4, height: 1.4))
        face.addEllipse(in: CGRect(x: 218.4, y: 76, width: 1.4, height: 1.4))
        Art.fill(&context, face, Art.color(0x7A4E44, 0.45))

        // The raised arm: out from the shoulder, back to the brow.
        let arm = colossusLimb("M199,99 C192,95 186,90 183,84 C190,80 198,76 205,73", width: 7)
        colossusBronze(&context, arm, light: 0.26, shade: 0.12)
        let hand = Art.ellipse(206.5, 72.4, 4, 2.5)
        colossusBronze(&context, hand, light: 0.2, shade: 0.1)
        Art.fill(&context, Art.rect(208, 74.6, 14, 1.6, radius: 0.8), ArtStyle.coolShade.opacity(0.2))
    }

    // MARK: Ships and the near rocks

    /// A small ship of the ancient kind: curved hull, one mast, one square sail, a steering oar.
    private static func colossusShip(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, scale: CGFloat, flipped: Bool) {
        let mirror: CGFloat = flipped ? -1 : 1
        let sailStops: Kit.Stops = [(Art.color(0xFFF7E4), 0), (Art.color(0xE9CBA2), 1)]
        let spar = Art.color(0x4A3840)
        Art.group(&context, x: x, y: y, scale: scale, scaleX: mirror) { g in
            ArtStyle.contactShadow(&g, 2, 3.4, 26, 2.6, alpha: 0.34)
            let wake = CGRect(x: -16, y: 5, width: 32, height: 10)
            ripples(&g, in: wake, count: 7, seed: 61, color: Art.color(0xFFFFFF, 0.4), width: 0.8, length: 4...12)
            Art.stroke(&g, Art.line(-18, -4, -26, 4.5), spar, width: 1)
            Art.stroke(&g, Art.line(0, -3, 0, -32), spar, width: 1.1)
            let sail = Art.svg("M-13,-28 L13,-28 C15.500,-21 15.500,-14 12,-8 L-12,-8 C-14.500,-14 -15,-21 -13,-28 Z")
            fillVertical(&g, sail, sailStops, from: -28, to: -8)
            model(&g, sail, light: 0.16, shade: 0.16)
            let stripe = Art.svg("M-14.300,-19 L14.700,-19")
            Art.stroke(&g, stripe, Art.color(0xC2573F, 0.6), width: 2.2, cap: .butt)
            Art.stroke(&g, Art.line(-15, -28, 15, -28), spar, width: 1.1)
            let hull = Art.svg("M-22,0 C-14,6 12,6 21,-1 L25,-9 C20,-5 16,-3 11,-3 L-13,-3 C-18,-3 -21,-7 -22,-12 C-26,-7 -26,-3 -22,0 Z")
            Art.fill(&g, hull, Art.color(0x6A4A4A))
            let wale = Art.svg("M-21.500,-1.500 C-13,3 11,3 21,-3")
            Art.stroke(&g, wale, Art.color(0xF0C888, 0.8), width: 0.8)
        }
    }

    /// The near plane: dark harbour rocks in the bottom-right corner, low in contrast.
    private static func colossusRocks(_ context: inout GraphicsContext) {
        let rocks = Art.svg("M456,330 L456,412 L330,412 C338,392 352,384 368,380 C376,362 396,352 414,350 C426,338 442,332 456,330 Z")
        Kit.solid(&context, rocks, stops: Kit.stops(0x4A6A8A, 0x1E3E60), light: 0.2, shade: 0.2, rim: 2)
        let facets = Art.svg("M368,380 L382,404 M414,350 L420,384 M396,360 L404,398 M440,336 L444,372")
        Art.stroke(&context, facets, Art.color(0x10284A, 0.4), width: 0.8)
    }

    // MARK: Finish

    private static func colossusFinish(_ context: inout GraphicsContext) {
        bottomFade(&context, 0x123A5C, from: 300, alpha: 0.88)
        // Heavier tooth than a standing building: this one is a drawing on paper.
        tooth(&context, seed: 611, light: 0.08, dark: 0.07)
        let paper = CGRect(x: 0, y: 0, width: unitWidth, height: 300)
        Art.stipple(&context, in: paper, count: 180, seed: 633, color: Art.color(0xFFF6E0), alpha: 0.08, size: 0.4...1)
        finish(&context, wash: 0.10, vignette: 0.08)
    }
}
