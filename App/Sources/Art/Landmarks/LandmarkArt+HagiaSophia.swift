import SwiftUI
import OmramoCore

// Hagia Sophia in Istanbul, seen from its long side by day: the wide, shallow dome on its ring
// of small windows, a half-dome stepping down on either side, buttressed walls of warm
// rose-ochre and the four slender minarets it has today; trees at its foot and the sea beyond.
// Our own drawing (no photograph, nothing traced). Card background #3B2A5C.

extension LandmarkArt {
    static let hagiaWindowHex: UInt32 = 0x5E4468
    static let hagiaCorniceHex: UInt32 = 0xFFE9CE

    /// hagia-sophia: the great dome above its ring of windows, as architecture only.
    static func paintHagiaSophia(_ context: inout GraphicsContext) {
        hagiaSky(&context)
        hagiaFarShore(&context)
        hagiaGarden(&context)
        // The two far minarets stand behind the building.
        hagiaMinaret(&context, x: 112, base: 240, top: 96, width: 7, brick: false)
        hagiaMinaret(&context, x: 320, base: 240, top: 96, width: 7, brick: false)
        hagiaLowerWalls(&context)
        hagiaHalfDomes(&context)
        hagiaCore(&context)
        hagiaDome(&context)
        // The two near minarets; one of the four is of red brick.
        hagiaMinaret(&context, x: 70, base: 263, top: 84, width: 9.5, brick: false)
        hagiaMinaret(&context, x: 362, base: 263, top: 84, width: 9.5, brick: true)
        hagiaTrees(&context)
        // The near plane: a dark bough in the top-right corner.
        cornerSpray(&context, seed: 77, dark: Art.color(0x2E4A52, 0.94), lit: Art.color(0xFFE2B0, 0.35))
        hagiaFinish(&context)
    }

    // MARK: Sky, sea and garden

    private static func hagiaSky(_ context: inout GraphicsContext) {
        let sky: Kit.Stops = [
            (Art.color(0x7DB7E4), 0),
            (Art.color(0xB9DCF0), 0.34),
            (Art.color(0xF6E6CC), 0.58),
            (Art.color(0xFBDDB4), 0.64),
            (Art.color(0xFBDDB4), 1),
        ]
        backdrop(&context, sky)
        horizon(&context, y: 250, rise: 64, hex: 0xFFD9A0, alpha: 0.4)
        Kit.cloud(&context, 290, 60, scale: 0.4, color: Art.color(0xFFFFFF, 0.9))
        Kit.cloud(&context, 30, 152, scale: 0.5, color: Art.color(0xFFFFFF, 0.8))
        Kit.cloud(&context, 404, 168, scale: 0.44, color: Art.color(0xFFFFFF, 0.8))
        Kit.birds(&context, 128, 58, scale: 0.55, color: Art.color(0x5A5F8C, 0.55))
    }

    private static func hagiaFarShore(_ context: inout GraphicsContext) {
        // The far shore across the water, the strip of sea, and a veil of warm air over both.
        let hills = Kit.ridge(width: 480, y: 238, amp: 7, seed: 23, bottom: 254, step: 8, x0: -24)
        Art.fill(&context, hills, Art.color(0x9FAFCB, 0.8))
        let sea = Art.rect(-24, 244, 480, 10)
        let water: Kit.Stops = [(Art.color(0xA9D3E4), 0), (Art.color(0x7FB4D2), 1)]
        fillVertical(&context, sea, water, from: 244, to: 254)
        let band = CGRect(x: -10, y: 246, width: 452, height: 6)
        ripples(&context, in: band, count: 26, seed: 9, color: Art.color(0xFFFFFF, 0.5), width: 0.6, length: 4...14)
        haze(&context, top: 222, bottom: 254, hex: 0xFBDDB4, alpha: 0.3)
    }

    private static func hagiaGarden(_ context: inout GraphicsContext) {
        let ground = Art.rect(-24, 252, 480, 176)
        let stops: Kit.Stops = [
            (Art.color(0xC9C38E), 0),
            (Art.color(0x9BAA7C), 0.2),
            (Art.color(0x6C6E86), 0.6),
            (Art.color(0x3B2A5C), 1),
        ]
        fillVertical(&context, ground, stops, from: 252, to: unitHeight)
        let farTrees = canopy(from: -16, to: 448, baseY: 256, height: 9, bump: 14, depth: 8, seed: 31)
        Art.fill(&context, farTrees, Art.color(0x8FA58C, 0.85))
        // A pale walk leading to the building.
        let walk = Art.polygon([pt(198, 266), pt(234, 266), pt(300, 412), pt(132, 412)])
        Art.fill(&context, walk, Art.color(0xF3E2C4, 0.2))
        // The building's contact shadow, a little to the right, away from the light.
        ArtStyle.contactShadow(&context, 228, 264, 156, 6, alpha: 0.24)
    }

    // MARK: Materials and small parts

    /// Warm rose-ochre masonry: light on the left, shaded on the right.
    private static func hagiaStone(_ context: inout GraphicsContext, _ path: Path, from x0: CGFloat, to x1: CGFloat) {
        let stops: Kit.Stops = [
            (Art.color(0xF6D2AE), 0),
            (Art.color(0xE7AE8C), 0.5),
            (Art.color(0xC98773), 1),
        ]
        fillHorizontal(&context, path, stops, from: x0, to: x1)
    }

    /// The grey lead that covers the domes.
    private static func hagiaLead(_ context: inout GraphicsContext, _ path: Path, from x0: CGFloat, to x1: CGFloat) {
        let stops: Kit.Stops = [
            (Art.color(0xDCE2E8), 0),
            (Art.color(0xAAB6C6), 0.5),
            (Art.color(0x7F8CA8), 1),
        ]
        fillHorizontal(&context, path, stops, from: x0, to: x1)
    }

    /// A round-headed opening standing on `baseY`. `height` must not be less than `width`.
    private static func hagiaRoundArch(_ cx: CGFloat, _ baseY: CGFloat, width: CGFloat, height: CGFloat) -> Path {
        let half: CGFloat = width / 2
        let top: CGFloat = baseY - height
        var path = Path()
        path.addRect(CGRect(x: cx - half, y: top + half, width: width, height: height - half))
        path.addEllipse(in: CGRect(x: cx - half, y: top, width: width, height: width))
        return path
    }

    /// `count` round-headed windows, the first centred on `x0` and the last on `x1`.
    private static func hagiaWindowRow(from x0: CGFloat, to x1: CGFloat, count: Int, baseY: CGFloat, width: CGFloat, height: CGFloat) -> Path {
        var path = Path()
        guard count > 1 else { return path }
        let step: CGFloat = (x1 - x0) / CGFloat(count - 1)
        for index in 0..<count {
            let x: CGFloat = x0 + step * CGFloat(index)
            path.addPath(hagiaRoundArch(x, baseY, width: width, height: height))
        }
        return path
    }

    /// The side view of a half-dome leaning on the building: it starts level at `inner` and
    /// comes down upright at `outer` (both measured from the centre line; `side` is −1 or 1).
    private static func hagiaQuarterDome(side: CGFloat, inner: CGFloat, outer: CGFloat, top: CGFloat, base: CGFloat) -> Path {
        let cx: CGFloat = 216
        let x0: CGFloat = cx + side * inner
        let x1: CGFloat = cx + side * outer
        let bulgeX: CGFloat = x0 + (x1 - x0) * 0.58
        let bulgeY: CGFloat = top + (base - top) * 0.45
        var path = Path()
        path.move(to: pt(x0, top))
        path.addCurve(to: pt(x1, base), control1: pt(bulgeX, top), control2: pt(x1, bulgeY))
        path.addLine(to: pt(x0, base))
        path.closeSubpath()
        return path
    }

    // MARK: Minarets

    private static func hagiaMinaret(_ context: inout GraphicsContext, x: CGFloat, base: CGFloat, top: CGFloat, width: CGFloat, brick: Bool) {
        let half: CGFloat = width / 2
        let slim: CGFloat = width * 0.38
        let shaftTop: CGFloat = top + width * 2.6
        let shaft = Art.polygon([pt(x - half, base), pt(x - slim, shaftTop), pt(x + slim, shaftTop), pt(x + half, base)])
        let pale: Kit.Stops = [(Art.color(0xFFF3E0), 0), (Art.color(0xF0DCC4), 0.45), (Art.color(0xB9A9B8), 1)]
        let rose: Kit.Stops = [(Art.color(0xF2B596), 0), (Art.color(0xDD9478), 0.45), (Art.color(0xA9686A), 1)]
        let stone: Kit.Stops = brick ? rose : pale
        // The square foot the shaft stands on.
        let footHeight: CGFloat = width * 1.5
        let foot = Art.rect(x - half - 1.5, base - footHeight, width + 3, footHeight)
        fillHorizontal(&context, foot, stone, from: x - half - 1.5, to: x + half + 1.5)
        fillHorizontal(&context, shaft, stone, from: x - half, to: x + half)
        model(&context, shaft, light: 0.18, shade: 0.22)
        let litEdge = Art.line(x - half + 0.5, base - footHeight, x - slim + 0.5, shaftTop)
        Art.stroke(&context, litEdge, ArtStyle.warmLight.opacity(0.7), width: 0.9, cap: .butt)

        // One balcony, with its shade beneath.
        let balconyY: CGFloat = shaftTop + (base - shaftTop) * 0.2
        let reach: CGFloat = width * 0.78
        let balcony = Art.rect(x - reach, balconyY - 1.6, reach * 2, 3.2, radius: 1)
        fillHorizontal(&context, balcony, stone, from: x - reach, to: x + reach)
        let under = Art.line(x - reach * 0.7, balconyY + 2.4, x + reach * 0.7, balconyY + 2.4)
        Art.stroke(&context, under, ArtStyle.coolShade.opacity(0.3), width: 0.8, cap: .butt)

        // The slender lead cap and a plain finial.
        let capHalf: CGFloat = slim + 0.9
        let cap = Art.polygon([pt(x - capHalf, shaftTop), pt(x, top), pt(x + capHalf, shaftTop)])
        hagiaLead(&context, cap, from: x - capHalf, to: x + capHalf)
        let finial = Art.line(x, top + 1, x, top - width * 0.6)
        Art.stroke(&context, finial, Art.color(0xE9C983), width: 0.9)
    }

    // MARK: Walls

    private static func hagiaLowerWalls(_ context: inout GraphicsContext) {
        let upper = Art.rect(96, 212, 240, 24)
        hagiaStone(&context, upper, from: 96, to: 336)
        model(&context, upper, light: 0.12, shade: 0.2)
        let lower = Art.rect(78, 234, 276, 29)
        hagiaStone(&context, lower, from: 78, to: 354)
        model(&context, lower, light: 0.14, shade: 0.24)

        // Courses of brick, in a darker tone of the wall.
        var courses = Path()
        let lowerCourses: [CGFloat] = [241, 248, 255]
        for y in lowerCourses {
            courses.move(to: pt(78, y))
            courses.addLine(to: pt(354, y))
        }
        let upperCourses: [CGFloat] = [219, 226]
        for y in upperCourses {
            courses.move(to: pt(96, y))
            courses.addLine(to: pt(336, y))
        }
        Art.stroke(&context, courses, Art.color(0xB7705F, 0.2), width: 0.6, cap: .butt)

        var windows = hagiaWindowRow(from: 104, to: 140, count: 4, baseY: 231, width: 5, height: 11)
        windows.addPath(hagiaWindowRow(from: 292, to: 328, count: 4, baseY: 231, width: 5, height: 11))
        windows.addPath(hagiaWindowRow(from: 172, to: 260, count: 7, baseY: 231, width: 5, height: 11))
        windows.addPath(hagiaWindowRow(from: 90, to: 129, count: 4, baseY: 257, width: 6, height: 14))
        windows.addPath(hagiaWindowRow(from: 303, to: 342, count: 4, baseY: 257, width: 6, height: 14))
        windows.addPath(hagiaWindowRow(from: 171, to: 261, count: 7, baseY: 257, width: 6, height: 14))
        Art.fill(&context, windows, Art.color(hagiaWindowHex, 0.7))

        // Cornices catch the light; a thin shade lies under each.
        var cornices = Path()
        cornices.addRect(CGRect(x: 94, y: 210.4, width: 244, height: 2.4))
        cornices.addRect(CGRect(x: 76, y: 232.8, width: 280, height: 2.6))
        Art.fill(&context, cornices, Art.color(hagiaCorniceHex, 0.95))
        var shades = Path()
        shades.addRect(CGRect(x: 96, y: 212.8, width: 240, height: 1.4))
        shades.addRect(CGRect(x: 78, y: 235.4, width: 276, height: 1.6))
        Art.fill(&context, shades, Art.color(0x8E5560, 0.3))
    }

    private static func hagiaHalfDomes(_ context: inout GraphicsContext) {
        let sides: [CGFloat] = [-1, 1]
        for side in sides {
            let big = hagiaQuarterDome(side: side, inner: 62, outer: 122, top: 160, base: 213)
            hagiaLead(&context, big, from: 94, to: 338)
            let x0: CGFloat = 216 + side * 72
            let x1: CGFloat = 216 + side * 111
            let windows = hagiaWindowRow(from: x0, to: x1, count: 4, baseY: 210, width: 4, height: 8)
            var ribs = Path()
            let ends: [CGFloat] = [78, 94, 108]
            for end in ends {
                let endX: CGFloat = 216 + side * end
                ribs.move(to: pt(216 + side * 62, 162))
                ribs.addQuadCurve(to: pt(endX, 213), control: pt(endX, 176))
            }
            Art.clipped(&context, to: big) { g in
                Art.stroke(&g, ribs, Art.color(0x6F7C9C, 0.3), width: 0.7)
                Art.fill(&g, Art.rect(90, 200, 252, 13), Art.color(0xE7AE8C, 0.55))
                Art.fill(&g, windows, Art.color(hagiaWindowHex, 0.65))
                Art.fill(&g, Art.rect(90, 199.2, 252, 1.2), Art.color(0x6F7C9C, 0.4))
            }
            model(&context, big, light: 0.2, shade: 0.22, rim: 0.5)

            // A smaller half-dome steps down again at each end.
            let small = hagiaQuarterDome(side: side, inner: 120, outer: 137, top: 216, base: 235)
            hagiaLead(&context, small, from: 78, to: 354)
            model(&context, small, light: 0.18, shade: 0.2)
        }
    }

    // MARK: The core under the dome

    private static func hagiaButtress(_ context: inout GraphicsContext, x: CGFloat) {
        let tower = Art.rect(x, 148, 22, 115)
        hagiaStone(&context, tower, from: x - 4, to: x + 26)
        model(&context, tower, light: 0.16, shade: 0.26)
        Art.fill(&context, Art.rect(x, 148, 3, 115), ArtStyle.warmLight.opacity(0.3))
        Art.fill(&context, Art.rect(x + 17, 148, 5, 115), ArtStyle.coolShade.opacity(0.14))
        let cap = Art.polygon([pt(x - 2, 149), pt(x + 11, 140), pt(x + 24, 149)])
        hagiaLead(&context, cap, from: x - 2, to: x + 24)
        var slits = hagiaRoundArch(x + 11, 182, width: 4, height: 10)
        slits.addPath(hagiaRoundArch(x + 11, 222, width: 4, height: 10))
        Art.fill(&context, slits, Art.color(hagiaWindowHex, 0.7))
        var bands = Path()
        bands.addRect(CGRect(x: x - 1, y: 196, width: 24, height: 1.8))
        bands.addRect(CGRect(x: x - 1, y: 236, width: 24, height: 1.8))
        Art.fill(&context, bands, Art.color(hagiaCorniceHex, 0.8))
    }

    private static func hagiaCore(_ context: inout GraphicsContext) {
        let block = Art.rect(150, 154, 132, 60)
        hagiaStone(&context, block, from: 140, to: 292)
        model(&context, block, light: 0.14, shade: 0.2)

        // The great arch under the dome, filled with two rows of windows.
        var arch = Path()
        arch.move(to: pt(166, 214))
        arch.addLine(to: pt(166, 206))
        arch.addCurve(to: pt(216, 156), control1: pt(166, 178.5), control2: pt(188.5, 156))
        arch.addCurve(to: pt(266, 206), control1: pt(243.5, 156), control2: pt(266, 178.5))
        arch.addLine(to: pt(266, 214))
        arch.closeSubpath()
        Art.fill(&context, arch, Art.color(0xF8DFC2, 0.6))
        var windows = hagiaWindowRow(from: 196, to: 236, count: 5, baseY: 187, width: 6, height: 13)
        windows.addPath(hagiaWindowRow(from: 180, to: 252, count: 7, baseY: 210, width: 6, height: 14))
        Art.fill(&context, windows, Art.color(hagiaWindowHex, 0.72))
        Art.stroke(&context, arch, Art.color(0xB7705F, 0.55), width: 1.4)
        let sill = Art.line(170, 191.5, 262, 191.5)
        Art.stroke(&context, sill, Art.color(0xB7705F, 0.3), width: 0.7, cap: .butt)

        // The dome's own shade on the roof line, falling to the right.
        let roofShade: Kit.Stops = [(ArtStyle.coolShade.opacity(0.2), 0), (ArtStyle.coolShade.opacity(0), 1)]
        fillVertical(&context, Art.rect(200, 154, 82, 9), roofShade, from: 154, to: 163)

        hagiaButtress(&context, x: 138)
        hagiaButtress(&context, x: 272)
        // Each buttress shades the wall on its right.
        var cast = Path()
        cast.addRect(CGRect(x: 160, y: 156, width: 6, height: 107))
        cast.addRect(CGRect(x: 294, y: 214, width: 6, height: 49))
        Art.fill(&context, cast, ArtStyle.coolShade.opacity(0.13))
    }

    // MARK: The dome

    private static func hagiaDome(_ context: inout GraphicsContext) {
        let cx: CGFloat = 216

        // The ring of windows the dome seems to float on.
        let drum = Art.rect(152, 136, 128, 19)
        hagiaStone(&context, drum, from: 152, to: 280)
        model(&context, drum, light: 0.12, shade: 0.22)
        let windows = hagiaWindowRow(from: 160, to: 272, count: 13, baseY: 153, width: 5, height: 11)
        Art.fill(&context, windows, Art.color(hagiaWindowHex, 0.78))
        var piers = Path()
        for index in 0..<12 {
            let x: CGFloat = 164.67 + CGFloat(index) * 9.333
            piers.addRect(CGRect(x: x - 1, y: 138, width: 2, height: 17))
        }
        Art.fill(&context, piers, Art.color(hagiaCorniceHex, 0.6))
        Art.fill(&context, Art.rect(148, 153.2, 136, 2.6), Art.color(hagiaCorniceHex, 0.95))

        // The wide, shallow dome.
        var dome = Path()
        dome.move(to: pt(150, 138))
        dome.addCurve(to: pt(cx, 96), control1: pt(154, 112), control2: pt(183, 96))
        dome.addCurve(to: pt(282, 138), control1: pt(249, 96), control2: pt(278, 112))
        dome.closeSubpath()
        hagiaLead(&context, dome, from: 150, to: 282)
        var ribs = Path()
        for index in -4...4 {
            let k: CGFloat = CGFloat(index)
            ribs.move(to: pt(cx, 97))
            ribs.addQuadCurve(to: pt(cx + k * 15.5, 138), control: pt(cx + k * 13.5, 104))
        }
        let domeShade: Kit.Stops = [
            (Art.color(0x6F7C9C, 0), 0),
            (Art.color(0x6F7C9C, 0), 0.45),
            (Art.color(0x5F6C94, 0.5), 1),
        ]
        Art.clipped(&context, to: dome) { g in
            Art.glow(&g, 186, 110, 52, Art.color(0xFFFFFF), alpha: 0.75)
            Art.fillLinear(&g, Art.rect(146, 92, 140, 50), domeShade, from: CGPoint(x: 200, y: 100), to: CGPoint(x: 286, y: 140))
            Art.stroke(&g, ribs, Art.color(0x6F7C9C, 0.32), width: 0.7)
            Art.fill(&g, Art.rect(146, 133.5, 140, 5), Art.color(0x6F7C9C, 0.28))
        }
        model(&context, dome, light: 0.14, shade: 0.22, rim: 0.7)
        Art.fill(&context, Art.rect(148, 136.4, 136, 2.2), Art.color(hagiaCorniceHex, 0.9))

        // A plain finial.
        Art.stroke(&context, Art.line(cx, 98, cx, 82), Art.color(0xE9C983), width: 1.3)
        var beads = Path()
        beads.addEllipse(in: CGRect(x: cx - 2.6, y: 91.4, width: 5.2, height: 5.2))
        beads.addEllipse(in: CGRect(x: cx - 1.6, y: 86, width: 3.2, height: 3.2))
        Art.fill(&context, beads, Art.color(0xF2D592))
    }

    // MARK: Trees

    private static func hagiaCypress(_ x: CGFloat, _ baseY: CGFloat, height: CGFloat, width: CGFloat) -> Path {
        let top: CGFloat = baseY - height
        let mid: CGFloat = baseY - height * 0.5
        var path = Path()
        path.move(to: pt(x, top))
        path.addCurve(to: pt(x, baseY), control1: pt(x + width * 0.95, mid), control2: pt(x + width * 0.8, baseY))
        path.addCurve(to: pt(x, top), control1: pt(x - width * 0.8, baseY), control2: pt(x - width * 0.95, mid))
        path.closeSubpath()
        return path
    }

    private static func hagiaTrees(_ context: inout GraphicsContext) {
        // A row of round garden trees across the building's foot.
        let row = canopy(from: -16, to: 448, baseY: 267, height: 11, bump: 17, depth: 10, seed: 47)
        let green: Kit.Stops = [(Art.color(0x86AA6C), 0), (Art.color(0x4F7A5C), 0.6), (Art.color(0x3A5E5A), 1)]
        fillVertical(&context, row, green, from: 254, to: 278)
        let crownLight: Kit.Stops = [(ArtStyle.warmLight.opacity(0.4), 0), (ArtStyle.warmLight.opacity(0), 1)]
        Art.clipped(&context, to: row) { g in
            fillVertical(&g, Art.rect(-24, 252, 480, 9), crownLight, from: 253, to: 261)
        }

        // Dark cypresses out at the sides, clear of the building.
        let places: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
            (22, 272, 44, 6), (40, 270, 34, 5), (398, 270, 36, 5), (416, 273, 48, 6.5),
        ]
        var dark = Path()
        var lit = Path()
        for place in places {
            let x: CGFloat = place.0
            let width: CGFloat = place.3
            ArtStyle.contactShadow(&context, x + width, place.1, width * 2, 2, alpha: 0.24)
            dark.addPath(hagiaCypress(x, place.1, height: place.2, width: width))
            lit.addPath(hagiaCypress(x - width * 0.22, place.1 - 2, height: place.2 * 0.86, width: width * 0.4))
        }
        let depth: Kit.Stops = [(Art.color(0x4F7A5C), 0), (Art.color(0x2F5350), 0.5), (Art.color(0x24403F), 1)]
        fillVertical(&context, dark, depth, from: 224, to: 274)
        Art.fill(&context, lit, ArtStyle.warmLight.opacity(0.22))
    }

    // MARK: Finish

    private static func hagiaFinish(_ context: inout GraphicsContext) {
        bottomFade(&context, 0x3B2A5C, from: 300, alpha: 0.9)
        tooth(&context, seed: 512, light: 0.06, dark: 0.05)
        finish(&context, wash: 0.10, vignette: 0.10)
    }
}
