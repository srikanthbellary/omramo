import SwiftUI

// Tokyo Skytree in evening light: our own stylised drawing (no photograph, nothing traced,
// no logos, no lettering, and the tower's signature lighting schemes are not shown).
// The operator licenses commercial use of the tower's name and image: legal review is needed
// before release (CONTENT_PLAN §6.6, PRD Q29). Card background #14254F.

extension LandmarkArt {
    /// The tower's centre line: the middle of the picture.
    private static let skytreeX: CGFloat = 216

    // One light, from the upper left: the moon (warmed by the evening) hangs there, the tower
    // and every roof take a warm edge on their left and indigo shade on their right, and the
    // moon's path lies on the river below it.
    static func paintSkytree(_ context: inout GraphicsContext) {
        skytreeSky(&context)
        skytreeGround(&context)
        // Far plane: hills and a hazy skyline, veiled with the sky's own colour.
        skytreeFarSkyline(&context)
        let farColor = Art.color(0x8072B0, 0.6)
        let midColor = Art.color(0x5A5496)
        skytreeRow(&context, baseY: 299, heights: 5...28, widths: 5...13, color: farColor, rim: Art.color(0xFFD8B8, 0.3), windows: 0, seed: 71, besideRiver: false)
        haze(&context, top: 240, bottom: 302, hex: 0xF4BE9C, alpha: 0.3)
        skytreeRow(&context, baseY: 305, heights: 7...20, widths: 7...15, color: midColor, rim: Art.color(0xFFD0B4, 0.34), windows: 0.07, seed: 73, besideRiver: false)
        skytreeTower(&context)
        skytreeRiver(&context)
        skytreeRow(&context, baseY: 316, heights: 9...19, widths: 8...16, color: Art.color(0x3E4284), rim: Art.color(0xC8A8D8, 0.3), windows: 0.13, seed: 79, besideRiver: true)
        skytreeRow(&context, baseY: 332, heights: 12...24, widths: 10...20, color: Art.color(0x2E3470), rim: Art.color(0xB8A0D8, 0.26), windows: 0.17, seed: 83, besideRiver: true)
        skytreeBridges(&context)
        skytreeRow(&context, baseY: 354, heights: 14...28, widths: 12...24, color: Art.color(0x222A5E), rim: Art.color(0xA898D0, 0.22), windows: 0.19, seed: 89, besideRiver: true)
        skytreeRow(&context, baseY: 380, heights: 16...32, widths: 14...28, color: Art.color(0x19214E), rim: Art.color(0x9890C8, 0.18), windows: 0.19, seed: 97, besideRiver: true)
        skytreeRow(&context, baseY: 410, heights: 18...34, widths: 16...30, color: Art.color(0x141B44), rim: Art.color(0x9088C0, 0.14), windows: 0.15, seed: 101, besideRiver: true)
        skytreeFinish(&context)
    }

    // MARK: Sky

    private static func skytreeSky(_ context: inout GraphicsContext) {
        let sky: [(Color, CGFloat)] = [
            (Art.color(0x1C2260), 0),
            (Art.color(0x383A88), 0.22),
            (Art.color(0x685AA8), 0.42),
            (Art.color(0xA67EB8), 0.58),
            (Art.color(0xE0A0AC), 0.68),
            (Art.color(0xF4BE9C), 0.74),
            (Art.color(0xF4BE9C), 1),
        ]
        backdrop(&context, sky)
        Art.group(&context, opacity: 0.7) { g in
            stars(&g, count: 30, seed: 37, maxY: 150, color: Art.color(0xFFFFFF))
        }

        // The one light: a pale moon in the UPPER LEFT (clear of the close button, which covers
        // the top-left 70 × 70), its halo warmed by the evening.
        let moonX: CGFloat = 106
        let moonY: CGFloat = 98
        Art.glow(&context, moonX, moonY, 120, Art.color(0xFFD9B0), alpha: 0.16)
        Art.glow(&context, moonX, moonY, 60, Art.color(0xFFEBD8), alpha: 0.36)
        let moon = Art.circle(moonX, moonY, 14)
        let moonStops: [(Color, CGFloat)] = [
            (Art.color(0xFFFEF2), 0),
            (Art.color(0xFAF0EA), 0.6),
            (Art.color(0xE6D8E6), 1),
        ]
        Art.fillRadial(&context, moon, moonStops, center: CGPoint(x: moonX - 4, y: moonY - 4), radius: 21)
        let seas = Art.svg("M99,93 C101,90 106,90 107,93 C108,96 101,97 99,93 Z M108,100 C110,98 114,99 114,102 C114,105 109,105 108,100 Z M100,103 C101,101.500 104,102 104,104 C103.500,106 100.500,105.500 100,103 Z")
        Art.fill(&context, seas, Art.color(0x9C98C8, 0.16))

        // Long evening clouds, lit from the moon's side: a rose body, a paler upper lip.
        Art.blurred(&context, radius: 3, opacity: 0.55) { g in
            var clouds = Path()
            clouds.addPath(cloudBand(232, 242, width: 210, height: 12))
            clouds.addPath(cloudBand(-14, 256, width: 170, height: 10))
            clouds.addPath(cloudBand(300, 206, width: 150, height: 9))
            clouds.addPath(cloudBand(18, 190, width: 120, height: 8))
            Art.fill(&g, clouds, Art.color(0xF0B0B8))
            var lips = Path()
            lips.addPath(cloudBand(236, 238, width: 120, height: 7))
            lips.addPath(cloudBand(-10, 252, width: 100, height: 6))
            lips.addPath(cloudBand(22, 187, width: 70, height: 5))
            Art.fill(&g, lips, Art.color(0xFFDCC8, 0.8))
        }
        // The shared horizon band, where the city meets the sky, warmest under the moon.
        horizon(&context, y: 299, rise: 80, hex: 0xFFC9A4, alpha: 0.4)
        Art.glow(&context, 56, 296, 170, Art.color(0xFFC9A4), alpha: 0.26)
    }

    /// The far plane: low hills on the horizon and a few taller, stepped towers of the far
    /// city, all close to the sky's value. Generic blocks: no real building is drawn.
    private static func skytreeFarSkyline(_ context: inout GraphicsContext) {
        let hills = canopy(from: -12, to: 444, baseY: 296, height: 14, bump: 70, depth: 8, seed: 61)
        Art.fill(&context, hills, Art.color(0xA488B8, 0.5))

        let towers: [(CGFloat, CGFloat, CGFloat)] = [
            (34, 8, 34), (78, 6, 26), (140, 9, 40), (168, 6, 24),
            (268, 7, 30), (300, 10, 44), (352, 7, 28), (396, 9, 36),
        ]
        var blocks = Path()
        var lit = Path()
        for tower in towers {
            let x = tower.0
            let w = tower.1
            let h = tower.2
            let top = 299 - h
            blocks.addRect(CGRect(x: x, y: top, width: w, height: h))
            // A stepped crown and a short mast, so the far skyline is not a row of boxes.
            blocks.addRect(CGRect(x: x + w * 0.2, y: top - 4, width: w * 0.6, height: 4))
            blocks.addRect(CGRect(x: x + w * 0.5 - 0.3, y: top - 10, width: 0.6, height: 6))
            lit.move(to: pt(x, 299))
            lit.addLine(to: pt(x, top))
        }
        Art.fill(&context, blocks, Art.color(0x8676B2, 0.55))
        Art.stroke(&context, lit, Art.color(0xFFD8B8, 0.35), width: 0.6, cap: .butt)
    }

    private static func skytreeGround(_ context: inout GraphicsContext) {
        let ground = Art.rect(-24, 296, unitWidth + 48, unitHeight - 296 + 24)
        let stops: [(Color, CGFloat)] = [
            (Art.color(0x6A5E9E), 0),
            (Art.color(0x343A7A), 0.2),
            (Art.color(0x1C2452), 0.6),
            (Art.color(0x14254F), 1),
        ]
        fillVertical(&context, ground, stops, from: 296, to: unitHeight)
    }

    // MARK: City

    /// Where the river's bank lies at height `y` (its left bank, or its right one).
    private static func skytreeRiverX(_ y: CGFloat, right: Bool) -> CGFloat {
        let t = min(1, max(0, (404 - y) / 106))
        let u = 1 - t
        // The river comes in from the lower right and runs away to the upper left, toward the
        // moon, so the moon's path can lie on it.
        let start: CGFloat = right ? 392 : 122
        let bend: CGFloat = right ? 232 : 87
        let end: CGFloat = right ? 134 : 120
        let a = u * u * start
        let b = 2 * u * t * bend
        let c = t * t * end
        return a + b + c
    }

    /// One row of low buildings across the picture, with a few lit windows.
    private static func skytreeRow(
        _ context: inout GraphicsContext,
        baseY: CGFloat,
        heights: ClosedRange<Double>,
        widths: ClosedRange<Double>,
        color: Color,
        rim: Color,
        windows: Double,
        seed: UInt32,
        besideRiver: Bool
    ) {
        var random = ArtRandom(seed)
        var blocks = Path()
        var rims = Path()
        var shades = Path()
        var warm = Path()
        var cool = Path()
        let riverLeft = skytreeRiverX(baseY, right: false) - 3
        let riverRight = skytreeRiverX(baseY, right: true) + 3
        var x: CGFloat = -8
        while x < unitWidth + 8 {
            let w = random.next(in: widths)
            let h = random.next(in: heights)
            let gap = random.next(in: 0...2.5)
            let left = x
            x += max(2, w) + gap
            if besideRiver && left + w > riverLeft && left < riverRight {
                continue
            }
            let top = baseY - h
            blocks.addRect(CGRect(x: left, y: top, width: w, height: h + 3))
            // The light comes from the upper left: an edge of light up the left wall and along
            // the roof, and the right third of each block in shade.
            rims.move(to: pt(left, baseY))
            rims.addLine(to: pt(left, top))
            rims.addLine(to: pt(left + w, top))
            shades.addRect(CGRect(x: left + w * 0.64, y: top, width: w * 0.36, height: h + 3))
            if windows <= 0 {
                continue
            }
            var wy = top + 2.6
            while wy < baseY - 2 {
                var wx = left + 1.6
                while wx < left + w - 2.2 {
                    let roll = random.next()
                    if roll < windows {
                        let pane = CGRect(x: wx, y: wy, width: 1.3, height: 1.7)
                        if roll < windows * 0.72 {
                            warm.addRect(pane)
                        } else {
                            cool.addRect(pane)
                        }
                    }
                    wx += 3.1
                }
                wy += 4.2
            }
        }
        Art.fill(&context, blocks, color)
        Art.fill(&context, shades, ArtStyle.coolShade.opacity(0.16))
        Art.stroke(&context, rims, rim, width: 0.6, cap: .butt, join: .miter)
        Art.fill(&context, warm, Art.color(0xFFD890, 0.95))
        Art.fill(&context, cool, Art.color(0xD4E2FF, 0.8))
    }

    // MARK: River and bridges

    private static func skytreeRiverShape() -> Path {
        var path = Path()
        path.move(to: pt(392, 404))
        path.addQuadCurve(to: pt(134, 298), control: pt(232, 350))
        path.addLine(to: pt(120, 298))
        path.addQuadCurve(to: pt(122, 404), control: pt(87, 345))
        path.addLine(to: pt(122, 430))
        path.addLine(to: pt(392, 430))
        path.closeSubpath()
        return path
    }

    /// The two bank lines of the river, as open curves.
    private static func skytreeBankLines() -> Path {
        var path = Path()
        path.move(to: pt(392, 404))
        path.addQuadCurve(to: pt(134, 298), control: pt(232, 350))
        path.move(to: pt(120, 298))
        path.addQuadCurve(to: pt(122, 404), control: pt(87, 345))
        return path
    }

    private static func skytreeRiver(_ context: inout GraphicsContext) {
        let river = skytreeRiverShape()
        let water: [(Color, CGFloat)] = [
            (Art.color(0xF0BCB4), 0),
            (Art.color(0xB096C8), 0.22),
            (Art.color(0x5C64A8), 0.58),
            (Art.color(0x24346E), 1),
        ]
        fillVertical(&context, river, water, from: 298, to: unitHeight)
        let bankLines = skytreeBankLines()
        Art.clipped(&context, to: river) { g in
            let reach = CGRect(x: 92, y: 302, width: 300, height: 100)
            ripples(&g, in: reach, count: 40, seed: 43, color: Art.color(0xFFFFFF, 0.2), width: 0.6, length: 6...30)
            ripples(&g, in: reach, count: 26, seed: 53, color: Art.color(0x14254F, 0.25), width: 0.7, length: 8...34)
            // The moon on the water, straight below the moon (upper left).
            Art.glow(&g, 122, 318, 44, Art.color(0xFFE6C8), alpha: 0.3)
            let moonPath = CGRect(x: 106, y: 304, width: 30, height: 84)
            ripples(&g, in: moonPath, count: 24, seed: 59, color: Art.color(0xFFF4DC, 0.55), width: 0.9, length: 3...12)
            // The banks' shade along both edges (heavier under the right bank, away from the light).
            Art.stroke(&g, bankLines, Art.color(0x1A2456, 0.45), width: 5)
        }
        // The embankment walls catch a little light.
        Art.stroke(&context, bankLines, Art.color(0xFFDCC8, 0.4), width: 0.8)

        // A small river boat with its lamps lit.
        Art.fill(&context, Art.rect(168, 373, 18, 2.6, radius: 1.2), Art.color(0x161C48))
        Art.fill(&context, Art.rect(172, 370.4, 11, 2.8, radius: 0.8), Art.color(0x232A5C))
        var lamps = Path()
        for index in 0..<4 {
            lamps.addRect(CGRect(x: 173.2 + CGFloat(index) * 2.6, y: 371.1, width: 1.4, height: 1.2))
        }
        Art.fill(&context, lamps, Art.color(0xFFD890))
        let wake = Art.svg("M166,376 C158,377 150,376.500 140,378 M188,376.500 C192,377 196,377 200,378")
        Art.stroke(&context, wake, Art.color(0xFFFFFF, 0.3), width: 0.7)
        let lampGlow = CGRect(x: 170, y: 377, width: 14, height: 9)
        ripples(&context, in: lampGlow, count: 6, seed: 67, color: Art.color(0xFFD890, 0.45), width: 0.8, length: 2...7)
    }

    private static func skytreeBridges(_ context: inout GraphicsContext) {
        // The far bridge: a low truss.
        let farDeck = Art.rect(100, 321.6, 96, 1.8)
        Art.fill(&context, farDeck, Art.color(0x2A3068))
        var farWork = Path()
        let farPiers: [CGFloat] = [122, 148, 174]
        for pier in farPiers {
            farWork.addRect(CGRect(x: pier - 1.3, y: 323, width: 2.6, height: 5.5))
        }
        Art.fill(&context, farWork, Art.color(0x2A3068))
        var truss = Path()
        truss.move(to: pt(122, 321.6))
        var trussX: CGFloat = 122
        var up = true
        while trussX < 174 {
            trussX += 6.5
            truss.addLine(to: pt(min(trussX, 174), up ? 316.4 : 321.6))
            up.toggle()
        }
        truss.move(to: pt(128.5, 316.4))
        truss.addLine(to: pt(167.5, 316.4))
        Art.stroke(&context, truss, Art.color(0x4A4E90, 0.9), width: 0.6)
        Art.stroke(&context, Art.line(100, 321.4, 196, 321.4), Art.color(0xFFDCC8, 0.45), width: 0.5, cap: .butt)

        // The near bridge: three low arches under a level deck.
        let piers: [CGFloat] = [94, 146, 198, 250]
        var stone = Path()
        stone.addRect(CGRect(x: 86, y: 347.4, width: 176, height: 3))
        for pier in piers {
            stone.addRect(CGRect(x: pier - 2.2, y: 350.4, width: 4.4, height: 9))
        }
        Art.fill(&context, stone, Art.color(0x1E2658))
        var spans = Path()
        for index in 0..<3 {
            let x0 = piers[index]
            let x1 = piers[index + 1]
            spans.move(to: pt(x0, 357.5))
            spans.addQuadCurve(to: pt(x1, 357.5), control: pt((x0 + x1) / 2, 343.5))
        }
        Art.stroke(&context, spans, Art.color(0x1E2658), width: 1.5)
        Art.stroke(&context, Art.line(86, 347.2, 262, 347.2), Art.color(0xFFDCC8, 0.5), width: 0.6, cap: .butt)
        var rail = Path()
        var lights = Path()
        var lightX: CGFloat = 92
        while lightX < 260 {
            rail.move(to: pt(lightX, 347.2))
            rail.addLine(to: pt(lightX, 344.4))
            lights.addEllipse(in: CGRect(x: lightX - 0.8, y: 343, width: 1.6, height: 1.6))
            lightX += 13
        }
        Art.stroke(&context, rail, Art.color(0x1E2658), width: 0.5, cap: .butt)
        Art.fill(&context, lights, Art.color(0xFFE2A8))
        let underBridge = CGRect(x: 102, y: 360, width: 140, height: 10)
        ripples(&context, in: underBridge, count: 12, seed: 107, color: Art.color(0xFFE2A8, 0.3), width: 0.7, length: 2...8)
    }

    // MARK: Tower

    /// Half the width of the tower's main shaft at height `y` (300 at the ground, 153 under
    /// the lower deck).
    private static func skytreeHalfWidth(_ y: CGFloat) -> CGFloat {
        if y >= 236 {
            return 9.5 + (y - 236) / 64 * 5.5
        }
        return 6.6 + max(0, y - 153) / 83 * 2.9
    }

    /// Cross-bracing for a shaft that narrows evenly from `bottom` to `top`.
    private static func skytreeBracing(
        cx: CGFloat,
        bottom: CGFloat,
        top: CGFloat,
        halfBottom: CGFloat,
        halfTop: CGFloat,
        step: CGFloat
    ) -> Path {
        var path = Path()
        let span = max(1, bottom - top)
        let stride = max(1, step)
        var y = bottom
        while y > top + 0.5 {
            let next = max(top, y - stride)
            let h0 = halfTop + (halfBottom - halfTop) * (y - top) / span
            let h1 = halfTop + (halfBottom - halfTop) * (next - top) / span
            path.move(to: pt(cx - h0, y))
            path.addLine(to: pt(cx + h1, next))
            path.move(to: pt(cx + h0, y))
            path.addLine(to: pt(cx - h1, next))
            path.move(to: pt(cx - h1, next))
            path.addQuadCurve(to: pt(cx + h1, next), control: pt(cx, next + h1 * 0.5))
            y = next
        }
        return path
    }

    /// An observation deck: it flares outward going up, like a shallow bowl, under a tapered cap.
    private static func skytreeDeck(
        _ context: inout GraphicsContext,
        cx: CGFloat,
        bottom: CGFloat,
        neck: CGFloat,
        reach: CGFloat,
        height: CGFloat,
        cap: CGFloat,
        capHalf: CGFloat
    ) {
        let rim = bottom - height * 0.55
        let top = bottom - height
        let bowl = Art.polygon([
            pt(cx - neck, bottom), pt(cx - reach, rim), pt(cx - reach, top),
            pt(cx + reach, top), pt(cx + reach, rim), pt(cx + neck, bottom),
        ])
        let shell: [(Color, CGFloat)] = [
            (Art.color(0xFBF8FF), 0),
            (Art.color(0xD6D8F2), 0.5),
            (Art.color(0x9A9ED0), 1),
        ]
        fillHorizontal(&context, bowl, shell, from: cx - reach, to: cx + reach)
        let roof = Art.polygon([pt(cx - reach * 0.84, top), pt(cx - capHalf, top - cap), pt(cx + capHalf, top - cap), pt(cx + reach * 0.84, top)])
        fillHorizontal(&context, roof, shell, from: cx - reach, to: cx + reach)

        // Bands of lit windows round the deck.
        var glass = Path()
        let bandOne = top + height * 0.16
        let bandTwo = top + height * 0.36
        glass.move(to: pt(cx - reach + 0.8, bandOne))
        glass.addLine(to: pt(cx + reach - 0.8, bandOne))
        if height > 10 {
            glass.move(to: pt(cx - reach + 0.8, bandTwo))
            glass.addLine(to: pt(cx + reach - 0.8, bandTwo))
        }
        Art.stroke(&context, glass, Art.color(0x3A3E7C, 0.85), width: 1.5, cap: .butt)
        Art.stroke(&context, glass, Art.color(0xFFE9B4, 0.95), width: 0.8, cap: .butt, dash: [1.6, 0.7])
        var underside = Path()
        underside.move(to: pt(cx - reach, rim))
        underside.addLine(to: pt(cx + reach, rim))
        Art.stroke(&context, underside, Art.color(0x6E72B0, 0.6), width: 0.5, cap: .butt)

        // The one light: indigo shade round the right of the deck, a warm edge on its left.
        let shadeStops: [(Color, CGFloat)] = [
            (ArtStyle.coolShade.opacity(0), 0),
            (ArtStyle.coolShade.opacity(0), 0.55),
            (ArtStyle.coolShade.opacity(0.3), 1),
        ]
        fillHorizontal(&context, bowl, shadeStops, from: cx - reach, to: cx + reach)
        fillHorizontal(&context, roof, shadeStops, from: cx - reach, to: cx + reach)
        var lit = Path()
        lit.move(to: pt(cx - neck, bottom))
        lit.addLine(to: pt(cx - reach, rim))
        lit.addLine(to: pt(cx - reach, top))
        lit.addLine(to: pt(cx - reach * 0.84, top))
        lit.addLine(to: pt(cx - capHalf, top - cap))
        Art.stroke(&context, lit, ArtStyle.warmLight.opacity(0.9), width: 0.9)
    }

    private static func skytreeTower(_ context: inout GraphicsContext) {
        let cx = skytreeX
        Art.glow(&context, cx, 150, 100, Art.color(0xCFC8FF), alpha: 0.22)
        // The moonward side of the air round the tower is a little warmer.
        Art.glow(&context, cx - 34, 150, 80, ArtStyle.warmLight, alpha: 0.1)
        // The tower's contact shadow, falling to the right, away from the light.
        ArtStyle.contactShadow(&context, cx + 9, 301, 30, 4, alpha: 0.32)

        let shaftStops: [(Color, CGFloat)] = [
            (Art.color(0xF6F3FF, 0.78), 0),
            (Art.color(0xCDD0F2, 0.62), 0.5),
            (Art.color(0x8E92CC, 0.66), 1),
        ]
        let steel = Art.color(0xFFFFFF, 0.72)
        // The lit (left) edge is the warm key light; the right edge sits back in cool shade.
        let edge = Art.color(0xFFF0D6, 0.96)
        let shadeEdge = Art.color(0xA8A6DC, 0.6)

        // The main shaft: three-sided at the ground, round by the time it reaches the deck.
        let levels: [CGFloat] = [300, 268, 236, 194, 153]
        var leftSide: [CGPoint] = []
        var rightSide: [CGPoint] = []
        for level in levels {
            let half = skytreeHalfWidth(level)
            leftSide.append(pt(cx - half, level))
            rightSide.append(pt(cx + half, level))
        }
        var outline: [CGPoint] = leftSide
        for point in rightSide.reversed() {
            outline.append(point)
        }
        let shaft = Art.polygon(outline)
        fillHorizontal(&context, shaft, shaftStops, from: cx - 15, to: cx + 15)
        model(&context, shaft, light: 0.3, shade: 0.3)
        // The core column, seen through the steel.
        Art.stroke(&context, Art.line(cx, 300, cx, 153), Art.color(0x6E6AA8, 0.5), width: 2.4, cap: .butt)

        var lattice = Path()
        var y: CGFloat = 300
        while y > 156 {
            let h0 = skytreeHalfWidth(y)
            let stride = max(5, h0 * 1.25)
            let next = max(153, y - stride)
            let h1 = skytreeHalfWidth(next)
            lattice.move(to: pt(cx - h0, y))
            lattice.addLine(to: pt(cx + h1, next))
            lattice.move(to: pt(cx + h0, y))
            lattice.addLine(to: pt(cx - h1, next))
            if y > 236 {
                // The three-sided base: the near corner shows as a third leg, with flat rings.
                lattice.move(to: pt(cx, y))
                lattice.addLine(to: pt(cx - h1, next))
                lattice.move(to: pt(cx, y))
                lattice.addLine(to: pt(cx + h1, next))
                lattice.move(to: pt(cx - h1, next))
                lattice.addLine(to: pt(cx + h1, next))
            } else {
                // Higher up the rings curve: the tower has become round.
                lattice.move(to: pt(cx - h1, next))
                lattice.addQuadCurve(to: pt(cx + h1, next), control: pt(cx, next + h1 * 0.5))
            }
            y = next
        }
        Art.stroke(&context, lattice, steel, width: 0.55)
        Art.stroke(&context, Art.polygon(leftSide, closed: false), edge, width: 1.3)
        Art.stroke(&context, Art.polygon(rightSide, closed: false), shadeEdge, width: 0.9)
        Art.stroke(&context, Art.line(cx, 300, cx, 238), Art.color(0xFFFFFF, 0.7), width: 0.8)

        // The lower deck, the shaft between the decks, the upper deck.
        skytreeDeck(&context, cx: cx, bottom: 153, neck: 6.6, reach: 11.5, height: 12, cap: 8, capHalf: 5.4)
        let middle = Art.polygon([pt(cx - 5.4, 133), pt(cx - 4.6, 108), pt(cx + 4.6, 108), pt(cx + 5.4, 133)])
        fillHorizontal(&context, middle, shaftStops, from: cx - 6, to: cx + 6)
        let middleBracing = skytreeBracing(cx: cx, bottom: 133, top: 108, halfBottom: 5.4, halfTop: 4.6, step: 6.2)
        Art.stroke(&context, middleBracing, steel, width: 0.5)
        skytreeDeck(&context, cx: cx, bottom: 108, neck: 4.6, reach: 8.2, height: 8.5, cap: 5.5, capHalf: 3.6)

        // Above the decks: a short shaft, then the broadcasting mast.
        let upper = Art.polygon([pt(cx - 3.6, 94), pt(cx - 3, 82), pt(cx + 3, 82), pt(cx + 3.6, 94)])
        fillHorizontal(&context, upper, shaftStops, from: cx - 4, to: cx + 4)
        let upperBracing = skytreeBracing(cx: cx, bottom: 94, top: 82, halfBottom: 3.6, halfTop: 3, step: 4)
        Art.stroke(&context, upperBracing, steel, width: 0.45)
        // The warm edge carries on up the left of both upper shafts.
        var upperLit = Art.line(cx - 5.4, 133, cx - 4.6, 108)
        upperLit.move(to: pt(cx - 3.6, 94))
        upperLit.addLine(to: pt(cx - 3, 82))
        Art.stroke(&context, upperLit, edge, width: 0.9)
        var upperShade = Art.line(cx + 5.4, 133, cx + 4.6, 108)
        upperShade.move(to: pt(cx + 3.6, 94))
        upperShade.addLine(to: pt(cx + 3, 82))
        Art.stroke(&context, upperShade, shadeEdge, width: 0.7)

        let mastStops: [(Color, CGFloat)] = [
            (Art.color(0xFBF8FF), 0),
            (Art.color(0xB4B8E4), 1),
        ]
        let mast = Art.rect(cx - 2.2, 46, 4.4, 36)
        fillHorizontal(&context, mast, mastStops, from: cx - 2.2, to: cx + 2.2)
        var rings = Path()
        var ringY: CGFloat = 52
        while ringY < 80 {
            rings.move(to: pt(cx - 2.8, ringY))
            rings.addLine(to: pt(cx + 2.8, ringY))
            ringY += 6
        }
        Art.stroke(&context, rings, Art.color(0x7C80BC, 0.8), width: 0.6, cap: .butt)
        Art.stroke(&context, Art.line(cx - 1.8, 80, cx - 1.8, 47), edge, width: 0.8, cap: .butt)
        Art.stroke(&context, Art.line(cx, 46, cx, 27), Art.color(0xF6F3FF, 0.95), width: 1.2)
        Art.glow(&context, cx, 27, 6, Art.color(0xFFFFFF), alpha: 0.8)

        // A soft bloom where the decks are lit.
        Art.glow(&context, cx, 146, 22, Art.color(0xFFE9B4), alpha: 0.28)
        Art.glow(&context, cx, 103, 15, Art.color(0xFFE9B4), alpha: 0.24)
    }

    // MARK: Finish

    private static func skytreeFinish(_ context: inout GraphicsContext) {
        bottomFade(&context, 0x14254F, from: 312, alpha: 0.82)
        tooth(&context, seed: 631, light: 0.05, dark: 0.05)
        // An evening picture: a little less wash.
        finish(&context, wash: 0.06, vignette: 0.08)
    }
}
