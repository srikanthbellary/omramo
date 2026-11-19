import SwiftUI
import OmramoCore

// The Mausoleum at Halicarnassus: a lost wonder, so this is OUR OWN RECONSTRUCTION, an idea and
// not a record. Nobody knows its exact form. The drawing shows a tall white stone podium, a ring
// of Ionic columns above it, a stepped pyramid roof and a four-horse chariot group on the top,
// standing in the town above the harbour of Bodrum with the blue sea behind. In the foreground a
// faint chalk outline of the few stones that remain today. It keeps construction lines, a height
// rule and loose ink edges, so that it reads as an artist's idea. Our own drawing (no photograph,
// nothing traced). Card background #2A3A4A.

extension LandmarkArt {
    /// mausoleum-halicarnassus: our reconstruction of the tomb above the harbour, by day.
    static func paintMausoleum(_ context: inout GraphicsContext) {
        mausoleumSky(&context)
        mausoleumSea(&context)
        mausoleumHills(&context)
        mausoleumGround(&context)
        mausoleumTown(&context)
        mausoleumBoat(&context, x: 58, y: 240, scale: 0.5, flipped: false)
        mausoleumBoat(&context, x: 392, y: 233, scale: 0.34, flipped: true)
        mausoleumBoat(&context, x: 110, y: 236, scale: 0.28, flipped: true)
        mausoleumGuides(&context)
        mausoleumBase(&context)
        mausoleumPodium(&context)
        mausoleumColonnade(&context)
        mausoleumEntablature(&context)
        mausoleumRoof(&context)
        mausoleumQuadriga(&context)
        mausoleumInk(&context)
        mausoleumFigures(&context)
        mausoleumNear(&context)
        mausoleumFinish(&context)
    }

    // MARK: Sky, sea, hills, ground, town

    static func mausoleumSky(_ context: inout GraphicsContext) {
        let sky: Kit.Stops = [
            (Art.color(0x86BCE0), 0),
            (Art.color(0xB2D6EA), 0.28),
            (Art.color(0xE2EEE8), 0.46),
            (Art.color(0xFBEACB), 0.54),
            (Art.color(0xFBEACB), 1),
        ]
        backdrop(&context, sky)
        horizon(&context, y: 214, rise: 64, hex: 0xFFDDA8, alpha: 0.32)
        Art.glow(&context, 10, 20, 220, Art.color(0xFFF3D2), alpha: 0.3)
        Art.blurred(&context, radius: 3, opacity: 0.7) { g in
            var clouds = Path()
            clouds.addPath(cloudBand(276, 100, width: 150, height: 10))
            clouds.addPath(cloudBand(-10, 152, width: 128, height: 9))
            clouds.addPath(cloudBand(322, 172, width: 110, height: 7))
            Art.fill(&g, clouds, Art.color(0xFFFFFF, 0.85))
        }
        Kit.birds(&context, 298, 66, scale: 0.45, color: Art.color(0x4A6A9A, 0.5))
    }

    /// The harbour and the open sea: seen past both sides of the tomb.
    static func mausoleumSea(_ context: inout GraphicsContext) {
        let far = Kit.ridge(width: 480, y: 207, amp: 5, seed: 23, bottom: 216, x0: -24)
        Art.fill(&context, far, Art.color(0xA6BCD8, 0.7))
        let top: CGFloat = 214
        let sea = Art.rect(-24, top, unitWidth + 48, 44)
        let stops: Kit.Stops = [
            (Art.color(0xD4E8E4), 0),
            (Art.color(0x8CC2D8), 0.3),
            (Art.color(0x4E92BA), 1),
        ]
        fillVertical(&context, sea, stops, from: top, to: 258)
        let openWater = CGRect(x: 0, y: 216, width: unitWidth, height: 34)
        ripples(&context, in: openWater, count: 44, seed: 7, color: Art.color(0xFFFFFF, 0.42), width: 0.5, length: 5...20)
        let glints = CGRect(x: 14, y: 217, width: 96, height: 22)
        ripples(&context, in: glints, count: 18, seed: 11, color: Art.color(0xFFE9B8, 0.5), width: 0.8, length: 4...16)
    }

    /// The far plane: two headlands of the peninsula closing the bay, veiled by distance.
    static func mausoleumHills(_ context: inout GraphicsContext) {
        let left = Art.svg("M-24,232 L-24,186 C4,180 30,178 56,186 C80,193 100,208 122,230 Z")
        Kit.solid(&context, left, stops: Kit.stops(0xCAC8A8, 0xADB096), light: 0.14, shade: 0.12)
        let right = Art.svg("M326,232 C340,214 358,200 380,192 C404,184 430,180 456,178 L456,232 Z")
        Kit.solid(&context, right, stops: Kit.stops(0xD0CAA6, 0xB0AE94), light: 0.12, shade: 0.16)
        let leftGroves = canopy(from: -24, to: 124, baseY: 192, height: 5, bump: 9, depth: 70, seed: 5)
        Art.clipped(&context, to: left) { g in
            Art.fill(&g, leftGroves, Art.color(0x9AAE88, 0.4))
        }
        let rightGroves = canopy(from: 318, to: 456, baseY: 192, height: 5, bump: 9, depth: 70, seed: 15)
        Art.clipped(&context, to: right) { g in
            Art.fill(&g, rightGroves, Art.color(0x9AAE88, 0.4))
        }
        // The harbour mole on the right with its small tower at the end.
        let mole = Art.svg("M336,247 C362,241 392,237 424,235 L426,238.500 C394,240 364,244 338,250 Z")
        Kit.solid(&context, mole, Art.color(0xE8DECA), light: 0.16, shade: 0.18)
        let tower = Art.rect(419, 226, 7, 10)
        Kit.solid(&context, tower, Art.color(0xF2EADA), light: 0.18, shade: 0.24)
        Art.stroke(&context, Art.line(338, 251, 424, 239.5), Art.color(0xFFFFFF, 0.5), width: 0.7)
        haze(&context, top: 168, bottom: 254, hex: 0xFBEACB, alpha: 0.3)
    }

    /// The town's ground and the paved precinct in front of the tomb.
    static func mausoleumGround(_ context: inout GraphicsContext) {
        let ground = Art.rect(-24, 252, unitWidth + 48, unitHeight - 228)
        let stops: Kit.Stops = [
            (Art.color(0xEADCC0), 0),
            (Art.color(0xD2C2A4), 0.3),
            (Art.color(0x7A7C80), 0.75),
            (Art.color(0x2A3A4A), 1),
        ]
        fillVertical(&context, ground, stops, from: 252, to: unitHeight)
        Art.stroke(&context, Art.line(-24, 252.5, 456, 252.5), Art.color(0xFFFFFF, 0.55), width: 0.8, cap: .butt)
        let precinct = Art.polygon([pt(104, 284), pt(328, 284), pt(374, 332), pt(58, 332)])
        Art.fill(&context, precinct, Art.color(0xF2E8D4, 0.55))
        var joints = Path()
        let rows: [CGFloat] = [292, 302, 314, 328]
        for row in rows {
            let t: CGFloat = (row - 284) / 48
            let spread: CGFloat = 46 * t
            joints.move(to: pt(104 - spread, row))
            joints.addLine(to: pt(328 + spread, row))
        }
        let rays: [CGFloat] = [140, 180, 216, 252, 292]
        for x in rays {
            let foot: CGFloat = 216 + (x - 216) * 1.42
            joints.move(to: pt(x, 284))
            joints.addLine(to: pt(foot, 332))
        }
        Art.stroke(&context, joints, Art.color(0x9A90A0, 0.28), width: 0.5, cap: .butt)
    }

    static func mausoleumCypress(_ x: CGFloat, _ base: CGFloat, _ h: CGFloat) -> Path {
        let mid: CGFloat = base - h * 0.45
        var path = Path()
        path.move(to: pt(x - 2.4, base))
        path.addQuadCurve(to: pt(x, base - h), control: pt(x - 3.4, mid))
        path.addQuadCurve(to: pt(x + 2.4, base), control: pt(x + 3.4, mid))
        path.closeSubpath()
        return path
    }

    /// White flat-roofed houses and dark cypresses along the near shore, on both sides.
    static func mausoleumTown(_ context: inout GraphicsContext) {
        let houses: [(CGFloat, CGFloat, CGFloat)] = [
            (2, 12, 10), (16, 10, 13), (28, 14, 9), (44, 11, 12), (57, 13, 8), (72, 10, 11),
            (84, 14, 9), (100, 12, 7), (318, 12, 8), (332, 14, 11), (348, 10, 9), (360, 13, 12),
            (375, 11, 8), (388, 14, 10), (404, 12, 13), (418, 14, 9),
        ]
        var trees = Path()
        let spires: [(CGFloat, CGFloat)] = [(40, 22), (96, 18), (344, 20), (400, 24)]
        for spire in spires {
            trees.addPath(mausoleumCypress(spire.0, 258, spire.1))
        }
        Art.fill(&context, trees, Art.color(0x5E7A62))
        var walls = Path()
        var sides = Path()
        var doors = Path()
        for house in houses {
            let x: CGFloat = house.0
            let w: CGFloat = house.1
            let top: CGFloat = 258 - house.2
            walls.addRect(CGRect(x: x, y: top, width: w, height: house.2))
            sides.addRect(CGRect(x: x + w * 0.66, y: top, width: w * 0.34, height: house.2))
            doors.addRect(CGRect(x: x + w * 0.22, y: top + 3, width: 1.8, height: 3))
        }
        Art.fill(&context, walls, Art.color(0xF6EEDF))
        Art.fill(&context, sides, ArtStyle.coolShade.opacity(0.14))
        Art.fill(&context, doors, Art.color(0x6A6488, 0.5))
        haze(&context, top: 200, bottom: 262, hex: 0xFBEACB, alpha: 0.22)
    }

    /// A small ancient ship: curved hull, one mast and one square sail.
    static func mausoleumBoat(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, scale: CGFloat, flipped: Bool) {
        let mirror: CGFloat = flipped ? -1 : 1
        let sailStops: Kit.Stops = [(Art.color(0xFFF7E4), 0), (Art.color(0xE6CCA6), 1)]
        let spar = Art.color(0x4A3E4C)
        Art.group(&context, x: x, y: y, scale: scale, scaleX: mirror) { g in
            ArtStyle.contactShadow(&g, 2, 3, 24, 2.4, alpha: 0.3)
            let wake = CGRect(x: -14, y: 4, width: 28, height: 8)
            ripples(&g, in: wake, count: 6, seed: 61, color: Art.color(0xFFFFFF, 0.4), width: 0.8, length: 4...10)
            Art.stroke(&g, Art.line(0, -3, 0, -30), spar, width: 1.1)
            let sail = Art.svg("M-12,-27 L12,-27 C14,-20 14,-14 11,-8 L-11,-8 C-14,-14 -14,-20 -12,-27 Z")
            fillVertical(&g, sail, sailStops, from: -27, to: -8)
            model(&g, sail, light: 0.16, shade: 0.16)
            Art.stroke(&g, Art.line(-13, -27, 13, -27), spar, width: 1)
            let hull = Art.svg("M-20,0 C-12,5 10,5 19,-1 L23,-8 C18,-4 14,-3 10,-3 L-12,-3 C-17,-3 -19,-6 -20,-10 C-24,-6 -24,-3 -20,0 Z")
            Art.fill(&g, hull, Art.color(0x6A4C50))
            let wale = Art.svg("M-19.500,-1.500 C-12,2.500 10,2.500 19,-3")
            Art.stroke(&g, wale, Art.color(0xF0C888, 0.8), width: 0.8)
        }
    }

    // MARK: The sketch

    /// A draughtsman's lines: each stroke is drawn twice, a little off and a little long.
    static func mausoleumSketch(_ segments: [(CGPoint, CGPoint)], seed: UInt32, overshoot: CGFloat, wobble: Double) -> Path {
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

    /// Faint guide lines behind the tomb: a centre line, level lines, the roof's slopes run on
    /// to where a full pyramid would close, and a height rule with ten divisions.
    static func mausoleumGuides(_ context: inout GraphicsContext) {
        let cx: CGFloat = 216
        let ink = Art.color(0x3A5A8A, 0.3)
        let axis = Art.line(cx, 16, cx, 292)
        Art.stroke(&context, axis, ink, width: 0.5, cap: .butt, dash: [7, 3, 1.5, 3])

        var guides: [(CGPoint, CGPoint)] = []
        let levels: [CGFloat] = [286, 168, 116, 99, 57]
        for level in levels {
            guides.append((pt(cx - 116, level), pt(cx + 118, level)))
        }
        guides.append((pt(146, 99), pt(cx, 49)))
        guides.append((pt(286, 99), pt(cx, 49)))
        guides.append((pt(140, 270), pt(140, 102)))
        guides.append((pt(292, 270), pt(292, 102)))
        let lines = mausoleumSketch(guides, seed: 5, overshoot: 8, wobble: 0.35)
        Art.stroke(&context, lines, ink, width: 0.5)

        let ruleX: CGFloat = 342
        var rule = Art.line(ruleX, 286, ruleX, 26)
        for index in 0...10 {
            let y: CGFloat = 286 - CGFloat(index) * 26
            rule.move(to: pt(ruleX - 3, y))
            rule.addLine(to: pt(ruleX + 3, y))
        }
        Art.stroke(&context, rule, ink, width: 0.6, cap: .butt)
    }

    // MARK: The tomb

    /// The shaded right-hand side of a block: its front's right edge pushed back and up.
    static func mausoleumSide(_ x: CGFloat, top: CGFloat, bottom: CGFloat, depth: CGFloat) -> Path {
        let rise: CGFloat = depth * 0.4
        return Art.polygon([pt(x, bottom), pt(x + depth, bottom - rise), pt(x + depth, top - rise), pt(x, top)])
    }

    /// The lit top of a block: its front's top edge pushed back and up.
    static func mausoleumTop(_ x0: CGFloat, _ x1: CGFloat, y: CGFloat, depth: CGFloat) -> Path {
        let rise: CGFloat = depth * 0.4
        return Art.polygon([pt(x0, y), pt(x0 + depth, y - rise), pt(x1 + depth, y - rise), pt(x1, y)])
    }

    static func mausoleumShadeSide(_ context: inout GraphicsContext, _ side: Path, alpha: Double) {
        Art.fill(&context, side, Art.color(0xE4DED8))
        Art.fill(&context, side, ArtStyle.coolShade.opacity(alpha))
    }

    /// The three broad steps the tomb stands on, and its shadow on the ground.
    static func mausoleumBase(_ context: inout GraphicsContext) {
        let cast = Art.polygon([pt(312, 272), pt(370, 262), pt(398, 278), pt(316, 286)])
        Art.fill(&context, cast, ArtStyle.coolShade.opacity(0.16))
        ArtStyle.contactShadow(&context, 222, 286, 112, 5, alpha: 0.3)
        let steps: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
            (118, 280, 196, 6), (124, 275, 184, 5), (130, 270, 172, 5),
        ]
        for step in steps {
            let x: CGFloat = step.0
            let y: CGFloat = step.1
            let w: CGFloat = step.2
            let h: CGFloat = step.3
            let tread = mausoleumTop(x, x + w, y: y, depth: 10)
            Art.fill(&context, tread, Art.color(0xFBF8F2))
            mausoleumShadeSide(&context, mausoleumSide(x + w, top: y, bottom: y + h, depth: 10), alpha: 0.26)
            let face = Art.rect(x, y, w, h)
            Kit.solid(&context, face, Art.color(0xF2ECE0), light: 0.18, shade: 0.22)
            Art.stroke(&context, Art.line(x, y + 0.4, x + w, y + 0.4), Art.color(0xFFFFFF, 0.7), width: 0.7, cap: .butt)
        }
    }

    /// The tall white podium: a plinth, courses of stone, a carved band and a cornice.
    static func mausoleumPodium(_ context: inout GraphicsContext) {
        mausoleumShadeSide(&context, mausoleumSide(292, top: 168, bottom: 270, depth: 10), alpha: 0.24)
        let wall = Art.rect(140, 168, 152, 102)
        Kit.solid(&context, wall, stops: Kit.stops(0xFAF6EE, 0xECE5D8), light: 0.22, shade: 0.2)
        var courses = Path()
        let rows: [CGFloat] = [194, 206, 218, 230, 242, 254]
        for (index, row) in rows.enumerated() {
            courses.move(to: pt(141, row))
            courses.addLine(to: pt(291, row))
            let shift: CGFloat = index % 2 == 0 ? 0 : 12
            var x: CGFloat = 150 + shift
            while x < 290 {
                courses.move(to: pt(x, row))
                courses.addLine(to: pt(x, row - 12))
                x += 24
            }
        }
        Art.stroke(&context, courses, Art.color(0x9A94A8, 0.3), width: 0.5, cap: .butt)

        // The carved band: a row of small fighting figures in low relief.
        let band = Art.rect(140, 170, 152, 12)
        Art.fill(&context, band, Art.color(0xEFE6D6))
        var figures = Path()
        var shields = Path()
        for index in 0..<18 {
            let x: CGFloat = 146 + CGFloat(index) * 8.2
            let lean: CGFloat = index % 2 == 0 ? 1.4 : -1.4
            figures.move(to: pt(x - 2, 181))
            figures.addLine(to: pt(x, 176.5))
            figures.addLine(to: pt(x + 2, 181))
            figures.move(to: pt(x, 176.5))
            figures.addLine(to: pt(x + lean * 0.4, 173.6))
            figures.move(to: pt(x, 175))
            figures.addLine(to: pt(x + lean * 2, 173))
            figures.addEllipse(in: CGRect(x: x - 1 + lean * 0.4, y: 171.4, width: 2, height: 2))
            if index % 3 == 1 {
                shields.addEllipse(in: CGRect(x: x - lean - 1.6, y: 174.2, width: 3.2, height: 3.2))
            }
        }
        Art.stroke(&context, figures, Art.color(0xA89C98, 0.7), width: 0.7)
        Art.fill(&context, shields, Art.color(0xB8AAA2, 0.6))
        Art.stroke(&context, Art.line(140, 182.5, 292, 182.5), Art.color(0xA89C98, 0.4), width: 0.6, cap: .butt)

        // The plinth at its foot stands a little proud.
        mausoleumShadeSide(&context, mausoleumSide(295, top: 258, bottom: 270, depth: 10), alpha: 0.28)
        let plinth = Art.rect(137, 258, 158, 12)
        Kit.solid(&context, plinth, Art.color(0xF0EADE), light: 0.2, shade: 0.22)
        Art.fill(&context, Art.rect(140, 168, 152, 2.4), ArtStyle.coolShade.opacity(0.14))

        // The cornice that carries the colonnade.
        Art.fill(&context, mausoleumTop(136, 296, y: 162, depth: 10), Art.color(0xFFFCF6))
        mausoleumShadeSide(&context, mausoleumSide(296, top: 162, bottom: 168, depth: 10), alpha: 0.26)
        let cornice = Art.rect(136, 162, 160, 6)
        Kit.solid(&context, cornice, Art.color(0xFBF7EE), light: 0.2, shade: 0.2)
        Art.stroke(&context, Art.line(140.6, 269, 140.6, 169), ArtStyle.warmLight.opacity(0.8), width: 1, cap: .butt)
    }

    /// The ring of Ionic columns round a shaded inner wall, on its own low step.
    static func mausoleumColonnade(_ context: inout GraphicsContext) {
        Art.fill(&context, mausoleumTop(144, 288, y: 152, depth: 10), Art.color(0xFFFCF6))
        mausoleumShadeSide(&context, mausoleumSide(288, top: 152, bottom: 158, depth: 10), alpha: 0.26)
        let stylobate = Art.rect(144, 152, 144, 6)
        Kit.solid(&context, stylobate, Art.color(0xF6F0E4), light: 0.2, shade: 0.2)

        // The inner wall: in the shade of the roof, darkest at the top.
        mausoleumShadeSide(&context, mausoleumSide(288, top: 116, bottom: 152, depth: 10), alpha: 0.36)
        let cella = Art.rect(148, 116, 140, 36)
        Art.fill(&context, cella, Art.color(0xDCD6DA))
        let soffit: Kit.Stops = [
            (ArtStyle.coolShade.opacity(0.34), 0),
            (ArtStyle.coolShade.opacity(0.08), 1),
        ]
        fillVertical(&context, cella, soffit, from: 116, to: 152)

        // Two columns of the side row, in shade.
        let sideSpots: [CGFloat] = [0.4, 0.85]
        var sideShafts = Path()
        for t in sideSpots {
            let x: CGFloat = 288 + 10 * t
            let lift: CGFloat = 4 * t
            sideShafts.addRect(CGRect(x: x - 2.6, y: 120 - lift, width: 5.2, height: 32))
        }
        Art.fill(&context, sideShafts, Art.color(0xD2CAD2))

        let shaftStops: Kit.Stops = [
            (Art.color(0xFFFCF4), 0),
            (Art.color(0xF2ECE2), 0.45),
            (Art.color(0xCCC4CE), 1),
        ]
        var flutes = Path()
        var bases = Path()
        var capitals = Path()
        var eyes = Path()
        for index in 0..<9 {
            let c: CGFloat = 152 + CGFloat(index) * 16
            let shaft = Art.polygon([pt(c - 3.6, 150), pt(c - 3.1, 121), pt(c + 3.1, 121), pt(c + 3.6, 150)])
            fillHorizontal(&context, shaft, shaftStops, from: c - 3.6, to: c + 3.6)
            flutes.move(to: pt(c - 1.3, 122))
            flutes.addLine(to: pt(c - 1.5, 149))
            flutes.move(to: pt(c + 1.3, 122))
            flutes.addLine(to: pt(c + 1.5, 149))
            bases.addRect(CGRect(x: c - 4.6, y: 149.4, width: 9.2, height: 2.6))
            capitals.addRect(CGRect(x: c - 5.4, y: 116, width: 10.8, height: 1.8))
            capitals.addRect(CGRect(x: c - 4, y: 117.8, width: 8, height: 2.2))
            capitals.addEllipse(in: CGRect(x: c - 5.9, y: 117.7, width: 3.4, height: 3.4))
            capitals.addEllipse(in: CGRect(x: c + 2.5, y: 117.7, width: 3.4, height: 3.4))
            eyes.addEllipse(in: CGRect(x: c - 4.8, y: 118.8, width: 1.2, height: 1.2))
            eyes.addEllipse(in: CGRect(x: c + 3.6, y: 118.8, width: 1.2, height: 1.2))
        }
        Art.stroke(&context, flutes, Art.color(0xA8A0B0, 0.4), width: 0.4, cap: .butt)
        Art.fill(&context, bases, Art.color(0xF4EEE4))
        Art.fill(&context, capitals, Art.color(0xFBF6EC))
        Art.fill(&context, eyes, Art.color(0xA8A0B0, 0.6))
        Art.fill(&context, Art.rect(144, 150, 144, 2), ArtStyle.coolShade.opacity(0.12))
    }

    /// The beam over the columns: a plain band, a row of small blocks and a cornice.
    static func mausoleumEntablature(_ context: inout GraphicsContext) {
        mausoleumShadeSide(&context, mausoleumSide(290, top: 105, bottom: 116, depth: 10), alpha: 0.28)
        let architrave = Art.rect(142, 109, 148, 7)
        Kit.solid(&context, architrave, Art.color(0xF4EEE2), light: 0.2, shade: 0.22)
        Art.stroke(&context, Art.line(143, 112.4, 289, 112.4), Art.color(0x9A94A8, 0.32), width: 0.5, cap: .butt)
        let frieze = Art.rect(142, 105, 148, 4)
        Art.fill(&context, frieze, Art.color(0xF8F2E8))
        var dentils = Path()
        var x: CGFloat = 143
        while x < 289 {
            dentils.addRect(CGRect(x: x, y: 105, width: 2.2, height: 2.4))
            x += 4
        }
        Art.fill(&context, dentils, Art.color(0xB0A8B4, 0.35))

        Art.fill(&context, mausoleumTop(137, 295, y: 101, depth: 10), Art.color(0xFFFDF8))
        mausoleumShadeSide(&context, mausoleumSide(295, top: 101, bottom: 105, depth: 10), alpha: 0.26)
        let cornice = Art.rect(137, 101, 158, 4)
        Kit.solid(&context, cornice, Art.color(0xFCF8F0), light: 0.2, shade: 0.2)
        Art.fill(&context, Art.rect(142, 105, 148, 1.2), ArtStyle.coolShade.opacity(0.18))
        Art.fill(&context, Art.rect(148, 116, 140, 2.4), ArtStyle.coolShade.opacity(0.2))
    }

    /// The stepped pyramid roof, twelve broad steps up to the chariot's base.
    static func mausoleumRoof(_ context: inout GraphicsContext) {
        var risers = Path()
        var treads = Path()
        var sides = Path()
        for index in 0..<12 {
            let step: CGFloat = CGFloat(index)
            let half: CGFloat = 70 - step * 4.9
            let bottom: CGFloat = 99 - step * 3.5
            let top: CGFloat = bottom - 3.5
            let left: CGFloat = 216 - half
            let right: CGFloat = 216 + half
            let depth: CGFloat = 4 + 6 * half / 70
            risers.addRect(CGRect(x: left, y: top, width: half * 2, height: 3.5))
            treads.addRect(CGRect(x: left, y: top, width: half * 2, height: 0.8))
            sides.addPath(mausoleumSide(right, top: top, bottom: bottom, depth: depth))
        }
        Art.fill(&context, sides, Art.color(0xDDD6D8))
        Art.fill(&context, sides, ArtStyle.coolShade.opacity(0.22))
        let stone: Kit.Stops = [
            (Art.color(0xFFF8EA), 0),
            (Art.color(0xF0E8DA), 0.5),
            (Art.color(0xD2CAD0), 1),
        ]
        fillHorizontal(&context, risers, stone, from: 146, to: 290)
        Art.fill(&context, treads, Art.color(0xFFFFFF, 0.7))
        var joints = Path()
        for index in 0..<12 {
            let step: CGFloat = CGFloat(index)
            let bottom: CGFloat = 99 - step * 3.5
            joints.move(to: pt(216 - 70 + step * 4.9, bottom))
            joints.addLine(to: pt(216 + 70 - step * 4.9, bottom))
        }
        Art.stroke(&context, joints, ArtStyle.coolShade.opacity(0.16), width: 0.5, cap: .butt)
        // A warm edge where the light runs down the roof's left side.
        Art.stroke(&context, Art.line(146.4, 99, 199.6, 57.5), ArtStyle.warmLight.opacity(0.5), width: 0.8)

        // The base of the chariot group.
        Art.fill(&context, mausoleumTop(200, 232, y: 51, depth: 5), Art.color(0xFFFDF8))
        mausoleumShadeSide(&context, mausoleumSide(232, top: 51, bottom: 57, depth: 5), alpha: 0.28)
        let block = Art.rect(200, 51, 32, 6)
        Kit.solid(&context, block, Art.color(0xF6F0E4), light: 0.2, shade: 0.22)
    }

    // MARK: The chariot group on the top

    /// One horse in profile, facing left (toward the light), hooves on y 0.
    static func mausoleumHorse() -> Path {
        Art.svg("M-6,-13 C-8,-16 -10,-18 -12,-19 L-16,-17 C-17,-18 -17,-20 -15,-21 L-11,-24 L-10,-26 L-9,-23 C-5,-20 -2,-16 2,-15 C6,-15 10,-15 12,-13 C14,-12 15,-9 14,-7 C16,-6 17,-3 16,-1 L14,-6 L12,0 L10,0 L10,-6 C6,-6 0,-6 -4,-7 L-5,0 L-7,0 L-7,-8 C-8,-9 -8,-11 -6,-13 Z")
    }

    /// Four horses abreast, a chariot and its driver, in sun-warm bronze.
    static func mausoleumQuadriga(_ context: inout GraphicsContext) {
        Art.glow(&context, 214, 38, 40, Art.color(0xFFF1C0), alpha: 0.42)
        ArtStyle.contactShadow(&context, 216, 51.4, 22, 1.6, alpha: 0.3)
        let bronze: Kit.Stops = [
            (Art.color(0xF4D296), 0),
            (Art.color(0xD8A462), 0.55),
            (Art.color(0xA87A6A), 1),
        ]
        let edge = Art.color(0x8A5A4A, 0.4)
        // The far horses stand a little higher and to the right, and a little in shade.
        let teams: [(CGFloat, CGFloat, Double)] = [
            (216, 49.6, 0.24), (213, 50.1, 0.16), (210, 50.6, 0.08), (207, 51, 0),
        ]
        let horse = mausoleumHorse()
        for team in teams {
            let dim: Double = team.2
            Art.group(&context, x: team.0, y: team.1) { g in
                fillHorizontal(&g, horse, bronze, from: -17, to: 17)
                model(&g, horse, light: 0.22, shade: 0.18)
                if dim > 0 {
                    Art.fill(&g, horse, ArtStyle.coolShade.opacity(dim))
                }
                Art.stroke(&g, horse, edge, width: 0.5)
                let mane = Art.svg("M-10,-24 C-6,-21 -3,-17 1,-15.500")
                Art.stroke(&g, mane, Art.color(0x8A5A4A, 0.5), width: 0.9)
            }
        }
        // The nearest horse lifts a foreleg.
        let foreleg = Art.svg("M201,42 C198,43 196,44 195,46 L196,48")
        Art.stroke(&context, foreleg, Art.color(0xE2B06C), width: 1.6)

        // The driver, standing in the chariot, the reins in his hands.
        let driver = Art.svg("M224,44 L225,34 C225,32 227,31 228,31 C230,31 231,32 231,34 L232,44 Z")
        fillHorizontal(&context, driver, bronze, from: 223, to: 233)
        model(&context, driver, light: 0.2, shade: 0.2)
        let head = Art.ellipse(228, 28.6, 2.2, 2.4)
        fillHorizontal(&context, head, bronze, from: 225, to: 231)
        Art.stroke(&context, Art.line(226, 35, 221, 37.5), Art.color(0xE2B06C), width: 1.4)
        Art.stroke(&context, Art.line(221, 37.5, 197, 29), Art.color(0x8A5A4A, 0.6), width: 0.4)

        // The chariot box, its wheel and the pole running forward to the team.
        Art.stroke(&context, Art.line(222, 46, 206, 42.5), Art.color(0x9A6A52), width: 0.9)
        let box = Art.svg("M222,41 L232,41 C234,43 234,46 233,49 L223,49 C222,46 221.500,43 222,41 Z")
        fillHorizontal(&context, box, bronze, from: 221, to: 234)
        model(&context, box, light: 0.24, shade: 0.2)
        Art.stroke(&context, Art.line(222.4, 42.6, 232.4, 42.6), Art.color(0xFFE6B0, 0.7), width: 0.6)
        var wheel = Art.circle(228, 47.4, 3.8)
        wheel.move(to: pt(228, 43.6))
        wheel.addLine(to: pt(228, 51.2))
        wheel.move(to: pt(224.2, 47.4))
        wheel.addLine(to: pt(231.8, 47.4))
        Art.stroke(&context, wheel, Art.color(0x7A4E44, 0.8), width: 0.8)
        Art.fill(&context, Art.circle(228, 47.4, 0.9), Art.color(0xF4D296))
    }

    // MARK: Ink, figures, near plane

    /// Loose ink edges and two faint diagonals over the podium, so the tomb stays a drawing.
    static func mausoleumInk(_ context: inout GraphicsContext) {
        var edges: [(CGPoint, CGPoint)] = []
        edges.append((pt(140, 270), pt(140, 168)))
        edges.append((pt(292, 270), pt(292, 168)))
        edges.append((pt(302, 266), pt(302, 164)))
        edges.append((pt(136, 162), pt(296, 162)))
        edges.append((pt(137, 101), pt(295, 101)))
        edges.append((pt(142, 116), pt(290, 116)))
        edges.append((pt(118, 286), pt(314, 286)))
        edges.append((pt(146, 99), pt(201, 57)))
        edges.append((pt(286, 99), pt(231, 57)))
        edges.append((pt(144, 152), pt(288, 152)))
        let ink = mausoleumSketch(edges, seed: 31, overshoot: 2.8, wobble: 0.45)
        Art.stroke(&context, ink, Art.color(0x3A4468, 0.4), width: 0.6)
        let chalk = mausoleumSketch(edges, seed: 47, overshoot: 1.4, wobble: 0.7)
        Art.stroke(&context, chalk, Art.color(0xFFFFFF, 0.3), width: 0.5)
        var cross: [(CGPoint, CGPoint)] = []
        cross.append((pt(140, 184), pt(292, 256)))
        cross.append((pt(292, 184), pt(140, 256)))
        let diagonals = mausoleumSketch(cross, seed: 53, overshoot: 0, wobble: 0.3)
        Art.stroke(&context, diagonals, Art.color(0x3A5A8A, 0.12), width: 0.5)
    }

    /// A tiny townsperson about three heads tall, for scale.
    static func mausoleumPerson(_ context: inout GraphicsContext, _ x: CGFloat, _ y: CGFloat, tunic: UInt32) {
        ArtStyle.contactShadow(&context, x + 1, y, 3.2, 0.9, alpha: 0.3)
        var legs = Path()
        legs.move(to: pt(x - 0.8, y - 2.4))
        legs.addLine(to: pt(x - 1, y))
        legs.move(to: pt(x + 0.8, y - 2.4))
        legs.addLine(to: pt(x + 1, y))
        Art.stroke(&context, legs, Art.color(0x8A5A4A), width: 0.9)
        let body = Art.polygon([pt(x - 1.4, y - 7), pt(x + 1.4, y - 7), pt(x + 2.2, y - 2.2), pt(x - 2.2, y - 2.2)])
        Kit.solid(&context, body, Art.color(tunic), light: 0.24, shade: 0.24)
        let face = Art.circle(x, y - 8.4, 1.5)
        Art.fill(&context, face, Art.color(0xC88E6A))
        Art.fill(&context, Art.circle(x - 0.4, y - 8.8, 0.6), Art.color(0xF2C49A, 0.7))
    }

    static func mausoleumFigures(_ context: inout GraphicsContext) {
        mausoleumPerson(&context, 100, 300, tunic: 0xC2573F)
        mausoleumPerson(&context, 107, 302, tunic: 0x4E7AA0)
        mausoleumPerson(&context, 334, 296, tunic: 0xE0B050)
        mausoleumPerson(&context, 156, 270, tunic: 0xF4F0E6)
    }

    /// The near plane: a dark rock and an olive bush in the bottom-right corner.
    static func mausoleumNear(_ context: inout GraphicsContext) {
        let rock = Art.svg("M456,334 L456,412 L338,412 C344,394 356,384 372,380 C382,362 400,352 418,350 C430,340 444,334 456,334 Z")
        Kit.solid(&context, rock, stops: Kit.stops(0x48606A, 0x22323E), light: 0.18, shade: 0.2, rim: 1.6)
        let facets = Art.svg("M372,380 L384,404 M418,350 L422,384 M398,360 L404,398")
        Art.stroke(&context, facets, Art.color(0x1A2A36, 0.4), width: 0.8)
        var random = ArtRandom(71)
        let anchors: [(CGFloat, CGFloat)] = [
            (400, 344), (414, 336), (428, 330), (442, 326), (452, 334), (390, 354), (436, 342),
        ]
        var leaves = Path()
        var glints = Path()
        for anchor in anchors {
            for side in 0..<3 {
                let base: CGFloat = -2.2 + CGFloat(side) * 0.7
                let angle: CGFloat = base + random.next(in: -0.3...0.3)
                let length: CGFloat = random.next(in: 11...17)
                leaves.addPath(leaf(anchor.0, anchor.1, length: length, width: length * 0.22, angle: angle))
                if side == 0 {
                    glints.addPath(leaf(anchor.0 - 0.6, anchor.1 - 0.6, length: length * 0.8, width: length * 0.07, angle: angle))
                }
            }
        }
        Art.fill(&context, leaves, Art.color(0x34503E))
        Art.fill(&context, glints, Art.color(0x8AA67A, 0.7))
    }

    // MARK: Today's stones and the finish

    /// A faint chalk outline of what is left today: a foundation, a few drums and blocks.
    static func mausoleumRuins(_ context: inout GraphicsContext) {
        var lines = Path()
        lines.addPath(Art.polygon([pt(58, 346), pt(82, 324), pt(198, 324), pt(178, 346)]))
        let drums: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [(70, 338, 4.6, 15), (148, 333, 4, 12)]
        for drum in drums {
            let x: CGFloat = drum.0
            let y: CGFloat = drum.1
            let r: CGFloat = drum.2
            let far: CGFloat = x + drum.3
            lines.addEllipse(in: CGRect(x: x - r * 0.5, y: y - r, width: r, height: r * 2))
            lines.move(to: pt(x, y - r))
            lines.addLine(to: pt(far, y - r))
            lines.addQuadCurve(to: pt(far, y + r), control: pt(far + r * 0.7, y))
            lines.addLine(to: pt(x, y + r))
        }
        let blocks: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [(96, 334, 12, 7), (166, 336, 10, 6), (118, 340, 9, 5)]
        var fills = Path()
        for block in blocks {
            let rect = CGRect(x: block.0, y: block.1, width: block.2, height: block.3)
            lines.addRect(rect)
            fills.addRect(rect)
        }
        let stub = Art.svg("M124,334 L124,318 L126,316 L128,318.500 L130,315.500 L131,318 L131,334 Z")
        lines.addPath(stub)
        fills.addPath(stub)
        Art.fill(&context, fills, Art.color(0xF4ECDC, 0.1))
        Art.stroke(&context, lines, Art.color(0xF4ECDC, 0.34), width: 0.7)
    }

    static func mausoleumFinish(_ context: inout GraphicsContext) {
        bottomFade(&context, 0x2A3A4A, from: 300, alpha: 0.9)
        mausoleumRuins(&context)
        tooth(&context, seed: 617, light: 0.06, dark: 0.05)
        // A little extra paper grain over the sky and the tomb: this one is a drawing.
        let paper = CGRect(x: 0, y: 0, width: unitWidth, height: 300)
        Art.stipple(&context, in: paper, count: 160, seed: 637, color: Art.color(0xFFF6E0), alpha: 0.07, size: 0.4...1)
        finish(&context, wash: 0.10, vignette: 0.10)
    }
}
