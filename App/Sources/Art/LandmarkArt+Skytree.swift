import SwiftUI

// Tokyo Skytree in evening light: our own stylised drawing (no photograph, nothing traced,
// no logos, no lettering, and the tower's signature lighting schemes are not shown).
// The operator licenses commercial use of the tower's name and image: legal review is needed
// before release (CONTENT_PLAN §6.6, PRD Q29). Card background #14254F.

extension LandmarkArt {
    /// The tower's centre line.
    private static let skytreeX: CGFloat = 176

    static func paintSkytree(_ context: inout GraphicsContext) {
        skytreeSky(&context)
        skytreeGround(&context)
        let farColor = Art.color(0x8072B0, 0.6)
        let midColor = Art.color(0x5A5496)
        skytreeRow(&context, baseY: 299, heights: 5...28, widths: 5...13, color: farColor, rim: Art.color(0xF4C8C0, 0.25), windows: 0, seed: 71, besideRiver: false)
        skytreeRow(&context, baseY: 305, heights: 7...20, widths: 7...15, color: midColor, rim: Art.color(0xE8B8C8, 0.3), windows: 0.07, seed: 73, besideRiver: false)
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

        // A pale moon, its halo warmed a little by the evening.
        Art.glow(&context, 322, 76, 64, Art.color(0xFFEBD8), alpha: 0.32)
        let moon = Art.circle(322, 76, 13)
        let moonStops: [(Color, CGFloat)] = [
            (Art.color(0xFFFEF6), 0),
            (Art.color(0xF2EEF8), 0.6),
            (Art.color(0xDCD6EE), 1),
        ]
        Art.fillRadial(&context, moon, moonStops, center: CGPoint(x: 318, y: 72), radius: 20)
        var seas = Path()
        seas.addEllipse(in: CGRect(x: 315, y: 69, width: 7, height: 5))
        seas.addEllipse(in: CGRect(x: 324, y: 77, width: 6, height: 6))
        seas.addEllipse(in: CGRect(x: 317, y: 80, width: 4, height: 3))
        Art.fill(&context, seas, Art.color(0x9C98C8, 0.16))

        Art.blurred(&context, radius: 4, opacity: 0.5) { g in
            var clouds = Path()
            clouds.addEllipse(in: CGRect(x: 210, y: 231, width: 180, height: 10))
            clouds.addEllipse(in: CGRect(x: 0, y: 246, width: 150, height: 8))
            clouds.addEllipse(in: CGRect(x: 320, y: 196, width: 120, height: 7))
            clouds.addEllipse(in: CGRect(x: 60, y: 210, width: 90, height: 6))
            Art.fill(&g, clouds, Art.color(0xF0B0B8))
        }
        // The shared horizon band, where the city meets the sky (it replaces the old blurred
        // haze of the finish, so the picture has one blur layer fewer).
        horizon(&context, y: 299, rise: 80, hex: 0xFFC9A4, alpha: 0.4)
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
        let start: CGFloat = right ? 310 : 40
        let bend: CGFloat = right ? 345 : 200
        let end: CGFloat = right ? 312 : 298
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
            rims.move(to: pt(left, top))
            rims.addLine(to: pt(left + w, top))
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
        Art.stroke(&context, rims, rim, width: 0.6, cap: .butt)
        Art.fill(&context, warm, Art.color(0xFFD890, 0.95))
        Art.fill(&context, cool, Art.color(0xD4E2FF, 0.8))
    }

    // MARK: River and bridges

    private static func skytreeRiverShape() -> Path {
        var path = Path()
        path.move(to: pt(40, 404))
        path.addQuadCurve(to: pt(298, 298), control: pt(200, 350))
        path.addLine(to: pt(312, 298))
        path.addQuadCurve(to: pt(310, 404), control: pt(345, 345))
        path.addLine(to: pt(310, 430))
        path.addLine(to: pt(40, 430))
        path.closeSubpath()
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
        Art.clipped(&context, to: river) { g in
            let reach = CGRect(x: 40, y: 302, width: 300, height: 100)
            ripples(&g, in: reach, count: 40, seed: 43, color: Art.color(0xFFFFFF, 0.2), width: 0.6, length: 6...30)
            ripples(&g, in: reach, count: 26, seed: 53, color: Art.color(0x14254F, 0.25), width: 0.7, length: 8...34)
            // The moon on the water.
            let moonPath = CGRect(x: 304, y: 312, width: 26, height: 80)
            ripples(&g, in: moonPath, count: 20, seed: 59, color: Art.color(0xFFFBEA, 0.5), width: 0.9, length: 3...12)
            // The banks' shade along both edges.
            var banks = Path()
            banks.move(to: pt(40, 404))
            banks.addQuadCurve(to: pt(298, 298), control: pt(200, 350))
            banks.move(to: pt(312, 298))
            banks.addQuadCurve(to: pt(310, 404), control: pt(345, 345))
            Art.stroke(&g, banks, Art.color(0x1A2456, 0.45), width: 5)
        }
        // The embankment walls catch a little light.
        var walls = Path()
        walls.move(to: pt(40, 404))
        walls.addQuadCurve(to: pt(298, 298), control: pt(200, 350))
        walls.move(to: pt(312, 298))
        walls.addQuadCurve(to: pt(310, 404), control: pt(345, 345))
        Art.stroke(&context, walls, Art.color(0xE8D0E8, 0.4), width: 0.8)

        // A small river boat with its lamps lit.
        Art.fill(&context, Art.rect(246, 373, 18, 2.6, radius: 1.2), Art.color(0x161C48))
        Art.fill(&context, Art.rect(249, 370.4, 11, 2.8, radius: 0.8), Art.color(0x232A5C))
        var lamps = Path()
        for index in 0..<4 {
            lamps.addRect(CGRect(x: 250.2 + CGFloat(index) * 2.6, y: 371.1, width: 1.4, height: 1.2))
        }
        Art.fill(&context, lamps, Art.color(0xFFD890))
        let wake = Art.svg("M266,376 C274,377 282,376.500 292,378 M244,376.500 C240,377 236,377 232,378")
        Art.stroke(&context, wake, Art.color(0xFFFFFF, 0.3), width: 0.7)
        let lampGlow = CGRect(x: 248, y: 377, width: 14, height: 9)
        ripples(&context, in: lampGlow, count: 6, seed: 67, color: Art.color(0xFFD890, 0.45), width: 0.8, length: 2...7)
    }

    private static func skytreeBridges(_ context: inout GraphicsContext) {
        // The far bridge: a low truss.
        let farDeck = Art.rect(236, 321.6, 96, 1.8)
        Art.fill(&context, farDeck, Art.color(0x2A3068))
        var farWork = Path()
        let farPiers: [CGFloat] = [258, 284, 310]
        for pier in farPiers {
            farWork.addRect(CGRect(x: pier - 1.3, y: 323, width: 2.6, height: 5.5))
        }
        Art.fill(&context, farWork, Art.color(0x2A3068))
        var truss = Path()
        truss.move(to: pt(258, 321.6))
        var trussX: CGFloat = 258
        var up = true
        while trussX < 310 {
            trussX += 6.5
            truss.addLine(to: pt(min(trussX, 310), up ? 316.4 : 321.6))
            up.toggle()
        }
        truss.move(to: pt(264.5, 316.4))
        truss.addLine(to: pt(303.5, 316.4))
        Art.stroke(&context, truss, Art.color(0x4A4E90, 0.9), width: 0.6)
        Art.stroke(&context, Art.line(236, 321.4, 332, 321.4), Art.color(0xE8D0E8, 0.45), width: 0.5, cap: .butt)

        // The near bridge: three low arches under a level deck.
        let piers: [CGFloat] = [182, 234, 286, 338]
        var stone = Path()
        stone.addRect(CGRect(x: 170, y: 347.4, width: 176, height: 3))
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
        Art.stroke(&context, Art.line(170, 347.2, 346, 347.2), Art.color(0xE8D0E8, 0.5), width: 0.6, cap: .butt)
        var rail = Path()
        var lights = Path()
        var lightX: CGFloat = 176
        while lightX < 344 {
            rail.move(to: pt(lightX, 347.2))
            rail.addLine(to: pt(lightX, 344.4))
            lights.addEllipse(in: CGRect(x: lightX - 0.8, y: 343, width: 1.6, height: 1.6))
            lightX += 13
        }
        Art.stroke(&context, rail, Art.color(0x1E2658), width: 0.5, cap: .butt)
        Art.fill(&context, lights, Art.color(0xFFE2A8))
        let underBridge = CGRect(x: 190, y: 360, width: 140, height: 10)
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
    }

    private static func skytreeTower(_ context: inout GraphicsContext) {
        let cx = skytreeX
        Art.glow(&context, cx, 150, 100, Art.color(0xCFC8FF), alpha: 0.22)
        // The tower's contact shadow, falling a little to the right.
        ArtStyle.contactShadow(&context, cx + 5, 301, 28, 4, alpha: 0.3)

        let shaftStops: [(Color, CGFloat)] = [
            (Art.color(0xF6F3FF, 0.78), 0),
            (Art.color(0xCDD0F2, 0.62), 0.5),
            (Art.color(0x8E92CC, 0.66), 1),
        ]
        let steel = Art.color(0xFFFFFF, 0.72)
        let edge = Art.color(0xFFFFFF, 0.9)

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
        Art.stroke(&context, Art.polygon(leftSide, closed: false), edge, width: 1)
        Art.stroke(&context, Art.polygon(rightSide, closed: false), edge, width: 1)
        Art.stroke(&context, Art.line(cx, 300, cx, 238), edge, width: 0.9)

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
