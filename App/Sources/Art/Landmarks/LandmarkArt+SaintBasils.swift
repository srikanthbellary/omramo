import SwiftUI
import OmramoCore

// Saint Basil's Cathedral on Red Square, by day: a cluster of red-brick towers with white trim,
// each under its own bright onion dome (no two alike), around one taller tent-roofed tower with
// a small gold dome; the paving of the square in front and a dark stretch of wall at the right.
// Our own drawing (no photograph, nothing traced). Card background #1B3160.

extension LandmarkArt {
    static let basilTrimHex: UInt32 = 0xFBF3E4
    static let basilDarkHex: UInt32 = 0x4A2440
    static let basilGoldHex: UInt32 = 0xF4C64E

    /// saint-basils-cathedral: the onion domes, each with its own pattern, as architecture only.
    static func paintSaintBasils(_ context: inout GraphicsContext) {
        basilSky(&context)
        basilSkyline(&context)
        basilSquare(&context)
        // The cathedral is drawn with its foot at y 268 and set down 8 units onto the square.
        Art.group(&context, x: 0, y: 8) { g in
            // The outer towers, then the two tall ones, the centre, and the two in front.
            basilTower(&g, cx: 112, domeBase: 190, neck: 10, width: 24)
            basilDome(&g, cx: 112, baseY: 190, halfWidth: 10, height: 33, pattern: 0, base: 0x2F9E63, mark: 0xFFD54A)
            basilTower(&g, cx: 320, domeBase: 190, neck: 10, width: 24)
            basilDome(&g, cx: 320, baseY: 190, halfWidth: 10, height: 33, pattern: 2, base: 0xF2C230, mark: 0x2F8F5A)
            basilTower(&g, cx: 162, domeBase: 156, neck: 12.5, width: 30)
            basilDome(&g, cx: 162, baseY: 156, halfWidth: 12.5, height: 40, pattern: 1, base: 0xD9412F, mark: 0xFBF3E4)
            basilTower(&g, cx: 270, domeBase: 156, neck: 12.5, width: 30)
            basilDome(&g, cx: 270, baseY: 156, halfWidth: 12.5, height: 40, pattern: 3, base: 0x2F6FD0, mark: 0xFBF3E4)
            basilSpire(&g)
            basilTower(&g, cx: 190, domeBase: 206, neck: 7.5, width: 18)
            basilDome(&g, cx: 190, baseY: 206, halfWidth: 7.5, height: 25, pattern: 4, base: 0xFBF3E4, mark: 0x2F6FD0)
            basilTower(&g, cx: 242, domeBase: 206, neck: 7.5, width: 18)
            basilDome(&g, cx: 242, baseY: 206, halfWidth: 7.5, height: 25, pattern: 5, base: 0xE8742C, mark: 0x2F8F5A)
            basilGallery(&g)
        }
        basilNearWall(&context)
        basilFinish(&context)
    }

    // MARK: Sky, skyline and square

    private static func basilSky(_ context: inout GraphicsContext) {
        let sky: Kit.Stops = [
            (Art.color(0x6FB1E6), 0),
            (Art.color(0xB4D9F0), 0.38),
            (Art.color(0xF8E8CC), 0.62),
            (Art.color(0xFFE2B8), 0.69),
            (Art.color(0xFFE2B8), 1),
        ]
        backdrop(&context, sky)
        horizon(&context, y: 276, rise: 70, hex: 0xFFDDB0, alpha: 0.4)
        Kit.cloud(&context, 346, 96, scale: 0.6, color: Art.color(0xFFFFFF, 0.92))
        Kit.cloud(&context, 56, 172, scale: 0.45, color: Art.color(0xFFFFFF, 0.85))
        Kit.cloud(&context, 398, 196, scale: 0.36, color: Art.color(0xFFFFFF, 0.8))
        Kit.birds(&context, 112, 98, scale: 0.55, color: Art.color(0x4C5C8E, 0.55))
    }

    private static func basilSkyline(_ context: inout GraphicsContext) {
        // The far plane: low, pale roofs of the city, veiled by the warm air.
        let blocks: [(CGFloat, CGFloat, CGFloat)] = [
            (-24, 44, 20), (16, 30, 30), (44, 34, 16), (76, 22, 24),
            (340, 30, 18), (366, 36, 28), (400, 26, 16), (424, 34, 24),
        ]
        var far = Path()
        for block in blocks {
            far.addRect(CGRect(x: block.0, y: 276 - block.2, width: block.1, height: block.2 + 2))
        }
        far.addPath(Art.polygon([pt(22, 247), pt(31, 228), pt(40, 247)]))
        far.addPath(Art.polygon([pt(368, 249), pt(384, 240), pt(400, 249)]))
        Art.fill(&context, far, Art.color(0x9FB0D2, 0.75))
        haze(&context, top: 226, bottom: 278, hex: 0xFFE6C2, alpha: 0.36)
    }

    private static func basilSquare(_ context: inout GraphicsContext) {
        let ground = Art.rect(-24, 275, 480, 153)
        let stops: Kit.Stops = [
            (Art.color(0xE0CDBC), 0),
            (Art.color(0xB7A9B4), 0.24),
            (Art.color(0x5E6492), 0.62),
            (Art.color(0x1B3160), 1),
        ]
        fillVertical(&context, ground, stops, from: 275, to: unitHeight)
        Art.fill(&context, Art.rect(-24, 275, 480, 1.6), ArtStyle.coolShade.opacity(0.14))
        // Courses of paving stones, finer far away.
        let nearBand = CGRect(x: -10, y: 280, width: 452, height: 22)
        ripples(&context, in: nearBand, count: 54, seed: 41, color: ArtStyle.coolShade.opacity(0.13), width: 0.7, length: 5...13)
        ripples(&context, in: nearBand, count: 30, seed: 43, color: Art.color(0xFFFFFF, 0.2), width: 0.6, length: 4...10)
        // The cathedral's contact shadow, a little to the right, away from the light.
        ArtStyle.contactShadow(&context, 230, 277, 150, 6, alpha: 0.26)
    }

    // MARK: Materials and small parts

    /// Red brick: warm on the left, plum in the shade on the right.
    private static func basilBrick(_ context: inout GraphicsContext, _ path: Path, from x0: CGFloat, to x1: CGFloat) {
        let stops: Kit.Stops = [
            (Art.color(0xEE8A66), 0),
            (Art.color(0xCF5B41), 0.45),
            (Art.color(0x8F3B4C), 1),
        ]
        fillHorizontal(&context, path, stops, from: x0, to: x1)
    }

    private static func basilGreen(_ context: inout GraphicsContext, _ path: Path, from x0: CGFloat, to x1: CGFloat) {
        let stops: Kit.Stops = [
            (Art.color(0x7CC797), 0),
            (Art.color(0x3E9670), 0.5),
            (Art.color(0x2A6660), 1),
        ]
        fillHorizontal(&context, path, stops, from: x0, to: x1)
    }

    /// A round-headed opening standing on `baseY`. `height` must not be less than `width`.
    private static func basilArch(_ cx: CGFloat, _ baseY: CGFloat, width: CGFloat, height: CGFloat) -> Path {
        let half: CGFloat = width / 2
        let top: CGFloat = baseY - height
        var path = Path()
        path.addRect(CGRect(x: cx - half, y: top + half, width: width, height: height - half))
        path.addEllipse(in: CGRect(x: cx - half, y: top, width: width, height: width))
        return path
    }

    /// A row of round white gables (kokoshniks) standing on the line `y`.
    private static func basilKokoshniks(_ context: inout GraphicsContext, cx: CGFloat, y: CGFloat, span: CGFloat, count: Int) {
        guard count > 0 else { return }
        let r: CGFloat = span / CGFloat(count) / 2
        let left: CGFloat = cx - span / 2
        var outer = Path()
        var inner = Path()
        for index in 0..<count {
            let x: CGFloat = left + r + CGFloat(index) * r * 2
            outer.addPath(Art.circle(x, y, r))
            inner.addPath(Art.circle(x, y, r * 0.52))
        }
        let upper = Art.rect(left - 1, y - r - 1, span + 2, r + 1)
        Art.clipped(&context, to: upper) { g in
            Art.fill(&g, outer, Art.color(basilTrimHex))
            Art.fill(&g, inner, Art.color(0xB84A3C))
        }
    }

    /// A plain gold stalk and bead on top of a dome whose tip is at (`cx`, `top`).
    private static func basilFinial(_ context: inout GraphicsContext, cx: CGFloat, top: CGFloat, rise: CGFloat, bead: CGFloat) {
        Art.stroke(&context, Art.line(cx, top + 2, cx, top - rise), Art.color(0xE2B040), width: 1)
        Art.fill(&context, Art.circle(cx, top - 0.5, bead), Art.color(basilGoldHex))
        Art.fill(&context, Art.circle(cx - bead * 0.3, top - 0.5 - bead * 0.3, bead * 0.35), Art.color(0xFFF3C8, 0.9))
    }

    // MARK: A tower and its dome

    private static func basilTower(_ context: inout GraphicsContext, cx: CGFloat, domeBase: CGFloat, neck: CGFloat, width w: CGFloat) {
        let half: CGFloat = w / 2
        let shaftTop: CGFloat = domeBase + 8 + w / 6
        let foot: CGFloat = 246
        let shaft = Art.polygon([pt(cx - half, foot), pt(cx - half + 1, shaftTop), pt(cx + half - 1, shaftTop), pt(cx + half, foot)])
        basilBrick(&context, shaft, from: cx - half, to: cx + half)
        model(&context, shaft, light: 0.12, shade: 0.2)

        // White trim: a band under the gables, a band lower down and the two corners.
        let bandY: CGFloat = shaftTop + (foot - shaftTop) * 0.58
        var trim = Path()
        trim.addRect(CGRect(x: cx - half + 1, y: shaftTop, width: w - 2, height: 1.8))
        trim.addRect(CGRect(x: cx - half + 0.5, y: bandY, width: w - 1, height: 1.6))
        Art.fill(&context, trim, Art.color(basilTrimHex, 0.92))
        var edges = Path()
        edges.move(to: pt(cx - half + 1.6, shaftTop))
        edges.addLine(to: pt(cx - half + 0.8, foot))
        edges.move(to: pt(cx + half - 1.6, shaftTop))
        edges.addLine(to: pt(cx + half - 0.8, foot))
        Art.stroke(&context, edges, Art.color(basilTrimHex, 0.7), width: 1, cap: .butt)

        let window = basilArch(cx, bandY - 3, width: w * 0.2, height: w * 0.56)
        Art.fill(&context, window, Art.color(basilDarkHex, 0.85))
        Art.stroke(&context, window, Art.color(basilTrimHex, 0.9), width: 0.9)
        basilKokoshniks(&context, cx: cx, y: shaftTop, span: w - 2, count: 3)

        // The white drum the dome sits on, with three slit windows.
        let drum = Art.rect(cx - neck, domeBase - 1, neck * 2, 9.5)
        let pale: Kit.Stops = [(Art.color(0xFFFBF0), 0), (Art.color(0xF3E6D6), 0.5), (Art.color(0xB9AEC6), 1)]
        fillHorizontal(&context, drum, pale, from: cx - neck, to: cx + neck)
        var slits = Path()
        let offsets: [CGFloat] = [-0.55, 0, 0.55]
        for offset in offsets {
            slits.addPath(basilArch(cx + offset * neck, domeBase + 7.5, width: neck * 0.22, height: 6))
        }
        Art.fill(&context, slits, Art.color(basilDarkHex, 0.7))
    }

    /// One onion dome in `base` with its own pattern in `mark`, clipped to the dome's shape.
    private static func basilDome(_ context: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, halfWidth: CGFloat, height: CGFloat, pattern: Int, base: UInt32, mark: UInt32) {
        let shape = onionDome(cx, baseY, halfWidth: halfWidth, height: height)
        Art.fill(&context, shape, Art.color(base))
        let reach: CGFloat = halfWidth * 1.5
        let box = CGRect(x: cx - reach, y: baseY - height, width: reach * 2, height: height)
        let ink = Art.color(mark)
        Art.clipped(&context, to: shape) { g in
            switch pattern {
            case 0:
                let bands = basilSwirl(in: box, spacing: halfWidth * 0.7, clockwise: true)
                Art.stroke(&g, bands, ink, width: halfWidth * 0.3, cap: .butt)
            case 1:
                let rows = basilZigzag(in: box, rowHeight: height * 0.2, pitch: halfWidth * 0.36)
                Art.stroke(&g, rows, ink, width: height * 0.07, cap: .butt, join: .miter)
            case 2:
                var lattice = diagonals(in: box, spacing: halfWidth * 0.62, rising: true)
                lattice.addPath(diagonals(in: box, spacing: halfWidth * 0.62, rising: false))
                Art.stroke(&g, lattice, ink, width: halfWidth * 0.13, cap: .butt)
            case 3:
                let ribs = basilRibs(cx: cx, baseY: baseY, halfWidth: halfWidth, height: height)
                Art.stroke(&g, ribs, ink, width: halfWidth * 0.22, cap: .butt)
            case 4:
                let bands = basilSwirl(in: box, spacing: halfWidth * 0.8, clockwise: false)
                Art.stroke(&g, bands, ink, width: halfWidth * 0.36, cap: .butt)
            default:
                Art.fill(&g, basilStuds(in: box, spacing: halfWidth * 0.6), ink)
            }
        }
        // The dome turns in the one light: warm upper left, indigo lower right, a lit rim.
        model(&context, shape, light: 0.34, shade: 0.34, rim: 0.6)
        let collar = Art.rect(cx - halfWidth - 1, baseY - 1.2, halfWidth * 2 + 2, 2.4, radius: 1)
        Art.fill(&context, collar, Art.color(basilGoldHex))
        basilFinial(&context, cx: cx, top: baseY - height, rise: height * 0.22, bead: max(1.2, halfWidth * 0.16))
    }

    // MARK: Dome patterns

    /// Curved bands that wind up and round the dome.
    private static func basilSwirl(in box: CGRect, spacing: CGFloat, clockwise: Bool) -> Path {
        var path = Path()
        let step: CGFloat = max(1, spacing)
        let lean: CGFloat = clockwise ? box.width * 0.9 : -box.width * 0.9
        let controlY: CGFloat = box.maxY - box.height * 0.3
        var x: CGFloat = box.minX - box.width
        while x < box.maxX + box.width {
            path.move(to: pt(x, box.maxY))
            path.addQuadCurve(to: pt(x + lean, box.minY), control: pt(x + lean * 0.85, controlY))
            x += step
        }
        return path
    }

    /// Rows of zigzag.
    private static func basilZigzag(in box: CGRect, rowHeight: CGFloat, pitch: CGFloat) -> Path {
        var path = Path()
        let rise: CGFloat = max(1, rowHeight)
        let run: CGFloat = max(1, pitch)
        var y: CGFloat = box.minY + rise * 0.5
        while y < box.maxY + rise {
            var x: CGFloat = box.minX
            var up = true
            path.move(to: pt(x, y))
            while x < box.maxX {
                x += run
                let peak: CGFloat = up ? y - rise * 0.5 : y
                path.addLine(to: pt(x, peak))
                up.toggle()
            }
            y += rise
        }
        return path
    }

    /// Stripes that run from the dome's base up to its point, like the ribs of a melon.
    private static func basilRibs(cx: CGFloat, baseY: CGFloat, halfWidth: CGFloat, height: CGFloat) -> Path {
        var path = Path()
        let controlY: CGFloat = baseY - height * 0.4
        for index in -3...3 {
            let k: CGFloat = CGFloat(index)
            let footX: CGFloat = cx + k * halfWidth * 0.36
            let controlX: CGFloat = cx + k * halfWidth * 0.95
            path.move(to: pt(footX, baseY))
            path.addQuadCurve(to: pt(cx, baseY - height), control: pt(controlX, controlY))
        }
        return path
    }

    /// Small diamond studs in staggered rows.
    private static func basilStuds(in box: CGRect, spacing: CGFloat) -> Path {
        var path = Path()
        let step: CGFloat = max(2, spacing)
        let r: CGFloat = step * 0.3
        var row = 0
        var y: CGFloat = box.minY + step * 0.5
        while y < box.maxY {
            let shift: CGFloat = row % 2 == 0 ? 0 : step * 0.5
            var x: CGFloat = box.minX + shift
            while x < box.maxX {
                path.addPath(Art.polygon([pt(x, y - r), pt(x + r, y), pt(x, y + r), pt(x - r, y)]))
                x += step
            }
            y += step * 0.8
            row += 1
        }
        return path
    }

    // MARK: The central tower

    private static func basilSpire(_ context: inout GraphicsContext) {
        let cx: CGFloat = 216
        let shaft = Art.polygon([pt(196, 246), pt(198, 156), pt(234, 156), pt(236, 246)])
        basilBrick(&context, shaft, from: 196, to: 236)
        model(&context, shaft, light: 0.14, shade: 0.22)
        var trim = Path()
        trim.addRect(CGRect(x: 198, y: 156, width: 36, height: 2))
        trim.addRect(CGRect(x: 197.4, y: 198, width: 37.2, height: 1.8))
        Art.fill(&context, trim, Art.color(basilTrimHex, 0.92))
        let edges = Art.svg("M199.6,156 L197.8,246 M232.4,156 L234.2,246")
        Art.stroke(&context, edges, Art.color(basilTrimHex, 0.7), width: 1, cap: .butt)
        var windows = basilArch(207, 192, width: 5, height: 20)
        windows.addPath(basilArch(225, 192, width: 5, height: 20))
        windows.addPath(basilArch(216, 236, width: 7, height: 22))
        Art.fill(&context, windows, Art.color(basilDarkHex, 0.85))
        Art.stroke(&context, windows, Art.color(basilTrimHex, 0.9), width: 0.9)

        // Two tiers of round gables step in toward the tent roof.
        let tier = Art.rect(201, 142, 30, 14)
        basilBrick(&context, tier, from: 196, to: 236)
        basilKokoshniks(&context, cx: cx, y: 156, span: 38, count: 4)
        basilKokoshniks(&context, cx: cx, y: 147.5, span: 30, count: 3)

        // The tall tent roof: brick, with pale ribs and green bands.
        let tent = Art.polygon([pt(200, 143), pt(cx, 76), pt(232, 143)])
        basilBrick(&context, tent, from: 200, to: 232)
        var ribs = Path()
        let feet: [CGFloat] = [205, 210.5, 216, 221.5, 227]
        for footX in feet {
            ribs.move(to: pt(cx, 78))
            ribs.addLine(to: pt(footX, 143))
        }
        var bands = Path()
        let levels: [CGFloat] = [100, 116, 132]
        for level in levels {
            bands.move(to: pt(196, level))
            bands.addLine(to: pt(236, level))
        }
        Art.clipped(&context, to: tent) { g in
            Art.stroke(&g, bands, Art.color(0x3E9670, 0.9), width: 2.6, cap: .butt)
            Art.stroke(&g, ribs, Art.color(basilTrimHex, 0.65), width: 0.9, cap: .butt)
        }
        model(&context, tent, light: 0.2, shade: 0.28, rim: 0.6)

        // The lantern, the small gold dome and a plain finial.
        let lantern = Art.rect(cx - 4.5, 68, 9, 11)
        let pale: Kit.Stops = [(Art.color(0xFFFBF0), 0), (Art.color(0xF3E6D6), 0.5), (Art.color(0xB9AEC6), 1)]
        fillHorizontal(&context, lantern, pale, from: cx - 4.5, to: cx + 4.5)
        let gold = onionDome(cx, 69, halfWidth: 4.6, height: 16)
        Art.fill(&context, gold, Art.color(basilGoldHex))
        model(&context, gold, light: 0.4, shade: 0.3, rim: 0.7)
        basilFinial(&context, cx: cx, top: 53, rise: 8, bead: 1.5)
    }

    // MARK: The gallery at the foot

    private static func basilGallery(_ context: inout GraphicsContext) {
        let wall = Art.rect(88, 240, 256, 28)
        basilBrick(&context, wall, from: 88, to: 344)
        model(&context, wall, light: 0.14, shade: 0.24)
        let roof = Art.polygon([pt(84, 241), pt(92, 233), pt(340, 233), pt(348, 241)])
        basilGreen(&context, roof, from: 84, to: 348)
        Art.fill(&context, Art.rect(84, 240.4, 264, 1.6), Art.color(basilTrimHex, 0.95))

        var arches = Path()
        for index in 0..<11 {
            let x: CGFloat = 100 + CGFloat(index) * 23.2
            arches.addPath(basilArch(x, 264.5, width: 11, height: 19))
        }
        Art.fill(&context, arches, Art.color(basilDarkHex, 0.8))
        Art.stroke(&context, arches, Art.color(basilTrimHex, 0.9), width: 1.1)
        Art.fill(&context, Art.rect(86, 264.5, 260, 3.5), Art.color(0xE9DCCB))
        Art.fill(&context, Art.rect(86, 267.2, 260, 1.2), Art.color(0x6E3A52, 0.4))

        // A small green tent roof over the porch at each end.
        let porches: [CGFloat] = [97, 335]
        for x in porches {
            let porch = Art.polygon([pt(x - 10, 233.5), pt(x, 213), pt(x + 10, 233.5)])
            basilGreen(&context, porch, from: x - 10, to: x + 10)
            model(&context, porch, light: 0.2, shade: 0.24)
            basilFinial(&context, cx: x, top: 213, rise: 4, bead: 1.2)
        }
    }

    // MARK: Near plane and finish

    /// The near plane: a dark stretch of old brick wall with notched battlements, cropped by
    /// the right edge and clear of the cathedral.
    private static func basilNearWall(_ context: inout GraphicsContext) {
        ArtStyle.contactShadow(&context, 424, 297, 52, 4, alpha: 0.26)
        var wall = Path()
        wall.addRect(CGRect(x: 386, y: 238, width: 70, height: 58))
        var x: CGFloat = 388
        while x < 452 {
            wall.addPath(Art.polygon([pt(x, 239), pt(x, 227), pt(x + 5, 231), pt(x + 10, 227), pt(x + 10, 239)]))
            x += 15
        }
        let stops: Kit.Stops = [(Art.color(0x8A3A4C), 0), (Art.color(0x5E2A4A), 0.6), (Art.color(0x3C2350), 1)]
        fillVertical(&context, wall, stops, from: 227, to: 296)
        let lit = Art.line(386.5, 240, 386.5, 296)
        Art.stroke(&context, lit, ArtStyle.warmLight.opacity(0.45), width: 1, cap: .butt)
        let courses = Art.svg("M386,252 H456 M386,266 H456 M386,280 H456")
        Art.stroke(&context, courses, ArtStyle.coolShade.opacity(0.22), width: 0.7, cap: .butt)
        Art.fill(&context, Art.rect(386, 238, 70, 1.4), ArtStyle.warmLight.opacity(0.3))
    }

    private static func basilFinish(_ context: inout GraphicsContext) {
        bottomFade(&context, 0x1B3160, from: 300, alpha: 0.9)
        tooth(&context, seed: 618, light: 0.06, dark: 0.05)
        finish(&context, wash: 0.10, vignette: 0.10)
    }
}
