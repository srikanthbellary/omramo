import SwiftUI

// An Asante traditional building near Kumasi at warm twilight: our own drawing (no photograph).
//
// FOR THE AKAN REVIEWER (CONTENT_PLAN §7): the wall decoration here is deliberately generic.
// It uses only running scrolls, a plaited band and diagonal lattice, in the manner of these
// walls. It does NOT try to reproduce any named adinkra symbol and it is not copied from any
// one wall or building. No emblem stands alone. Please tell us what should change.
// Card background #3A1F4D.

extension LandmarkArt {
    static func paintAsante(_ context: inout GraphicsContext) {
        asanteSky(&context)
        asanteForest(&context)
        asanteGround(&context)
        asanteOpenSide(&context)
        asanteWall(&context)
        asanteWallLight(&context)
        asanteRoof(&context)
        asanteFinish(&context)
    }

    // MARK: Sky, forest, ground

    private static func asanteSky(_ context: inout GraphicsContext) {
        let sky: [(Color, CGFloat)] = [
            (Art.color(0x261A4A), 0),
            (Art.color(0x482B66), 0.2),
            (Art.color(0x8C4670), 0.36),
            (Art.color(0xD8706A), 0.47),
            (Art.color(0xF6AA64), 0.54),
            (Art.color(0xFFD08A), 0.6),
            (Art.color(0xFFD08A), 1),
        ]
        backdrop(&context, sky)
        stars(&context, count: 34, seed: 23, maxY: 120, color: Art.color(0xFFF3DC))
        Art.glow(&context, 92, 232, 180, Art.color(0xFFC878), alpha: 0.65)

        Art.blurred(&context, radius: 4, opacity: 0.5) { g in
            var clouds = Path()
            clouds.addEllipse(in: CGRect(x: 180, y: 150, width: 170, height: 8))
            clouds.addEllipse(in: CGRect(x: 300, y: 176, width: 140, height: 7))
            clouds.addEllipse(in: CGRect(x: 96, y: 128, width: 110, height: 6))
            Art.fill(&g, clouds, Art.color(0xE88C7A))
        }
    }

    /// A tall forest tree that stands above the rest: straight trunk, flat spreading crown.
    private static func asanteTallTree(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, top: CGFloat, spread: CGFloat, color: Color) {
        let fork = top + spread * 0.5
        let trunk = Art.polygon([pt(x - 2.4, baseY), pt(x - 1, fork), pt(x + 1, fork), pt(x + 2.4, baseY)])
        Art.fill(&context, trunk, color)
        var limbs = Path()
        limbs.move(to: pt(x, fork + spread * 0.2))
        limbs.addQuadCurve(to: pt(x - spread * 0.7, top + spread * 0.26), control: pt(x - spread * 0.2, top + spread * 0.5))
        limbs.move(to: pt(x, fork + spread * 0.1))
        limbs.addQuadCurve(to: pt(x + spread * 0.72, top + spread * 0.3), control: pt(x + spread * 0.2, top + spread * 0.52))
        Art.stroke(&context, limbs, color, width: 1.5)
        var crown = Path()
        crown.addEllipse(in: CGRect(x: x - spread, y: top + spread * 0.06, width: spread * 1.1, height: spread * 0.42))
        crown.addEllipse(in: CGRect(x: x - spread * 0.4, y: top, width: spread * 1.1, height: spread * 0.4))
        crown.addEllipse(in: CGRect(x: x, y: top + spread * 0.12, width: spread, height: spread * 0.4))
        Art.fill(&context, crown, color)
    }

    private static func asanteForest(_ context: inout GraphicsContext) {
        let haze = Art.color(0x7E4068, 0.78)
        asanteTallTree(&context, x: 118, baseY: 230, top: 124, spread: 34, color: haze)
        asanteTallTree(&context, x: 368, baseY: 230, top: 136, spread: 30, color: haze)
        asanteTallTree(&context, x: 252, baseY: 230, top: 150, spread: 24, color: haze)
        let far = canopy(from: -12, to: 444, baseY: 224, height: 48, bump: 34, depth: 80, seed: 3)
        Art.fill(&context, far, haze)

        let near = canopy(from: -12, to: 444, baseY: 244, height: 42, bump: 26, depth: 70, seed: 9)
        let nearStops: [(Color, CGFloat)] = [
            (Art.color(0x55305A), 0),
            (Art.color(0x331E44), 0.6),
            (Art.color(0x2A1838), 1),
        ]
        fillVertical(&context, near, nearStops, from: 200, to: 300)
        // Sunset caught in the crowns on the left.
        Art.clipped(&context, to: near) { g in
            Art.glow(&g, 70, 214, 120, Art.color(0xFFB06A), alpha: 0.32)
        }
        asanteTallTree(&context, x: 30, baseY: 250, top: 138, spread: 36, color: Art.color(0x3A2048))
    }

    private static func asanteGround(_ context: inout GraphicsContext) {
        let ground = Art.rect(-24, 288, unitWidth + 48, unitHeight - 288 + 24)
        let stops: [(Color, CGFloat)] = [
            (Art.color(0xCB7046), 0),
            (Art.color(0x8E4446), 0.3),
            (Art.color(0x4C2750), 0.72),
            (Art.color(0x3A1F4D), 1),
        ]
        fillVertical(&context, ground, stops, from: 288, to: unitHeight)
        // Warm light lying across the swept courtyard.
        Art.glow(&context, 110, 300, 150, Art.color(0xFFC27A), alpha: 0.22)
        let earth = CGRect(x: 0, y: 304, width: unitWidth, height: 70)
        ripples(&context, in: earth, count: 36, seed: 19, color: Art.color(0xFFD6A0, 0.12), width: 0.7, length: 10...46)
        ripples(&context, in: earth, count: 24, seed: 27, color: Art.color(0x2A1438, 0.16), width: 0.7, length: 10...40)

        // The building's own shadow, falling away from the light.
        let shadow = Art.polygon([pt(40, 300), pt(398, 300), pt(436, 322), pt(96, 322)])
        let shadowStops: [(Color, CGFloat)] = [
            (Art.color(0x2A1438, 0.42), 0),
            (Art.color(0x2A1438, 0), 1),
        ]
        fillVertical(&context, shadow, shadowStops, from: 300, to: 322)
    }

    // MARK: Relief

    /// Low relief: a raised ridge with light on its upper edge and shadow under it.
    private static func asanteRelief(
        _ context: inout GraphicsContext,
        _ path: Path,
        shadow: Color,
        body: Color,
        light: Color,
        width: CGFloat
    ) {
        let under = path.applying(CGAffineTransform(translationX: 0.7, y: 0.9))
        let over = path.applying(CGAffineTransform(translationX: -0.4, y: -0.5))
        Art.stroke(&context, under, shadow, width: width)
        Art.stroke(&context, path, body, width: width)
        Art.stroke(&context, over, light, width: width * 0.4)
    }

    /// A running scroll: curls that rise from one base line, all turning the same way.
    private static func asanteScroll(from x0: CGFloat, to x1: CGFloat, baseline: CGFloat, radius: CGFloat, count: Int, clockwise: Bool) -> Path {
        var path = Art.line(x0, baseline, x1, baseline)
        let n = max(1, count)
        let spacing = (x1 - x0) / CGFloat(n)
        let start = CGFloat.pi / 2
        for index in 0..<n {
            let cx = x0 + spacing * (CGFloat(index) + 0.5)
            path.addPath(spiral(cx, baseline - radius, radius, turns: 1.75, start: start, clockwise: clockwise))
        }
        return path
    }

    /// A plaited band: two strands that cross over and under along a line.
    private static func asanteBraid(from x0: CGFloat, to x1: CGFloat, centre: CGFloat, amplitude: CGFloat, period: CGFloat) -> Path {
        var path = Path()
        let signs: [CGFloat] = [1, -1]
        let wave = max(1, period)
        for sign in signs {
            var x = x0
            var first = true
            while x <= x1 + 0.01 {
                let phase = (x - x0) / wave * 2 * CGFloat.pi
                let y = centre + sign * amplitude * sin(phase)
                if first {
                    path.move(to: pt(x, y))
                    first = false
                } else {
                    path.addLine(to: pt(x, y))
                }
                x += 1.5
            }
        }
        return path
    }

    /// A lattice of crossing diagonals inside `rect`, in relief.
    private static func asanteLattice(
        _ context: inout GraphicsContext,
        in rect: CGRect,
        spacing: CGFloat,
        shadow: Color,
        body: Color,
        light: Color,
        width: CGFloat
    ) {
        var lines = diagonals(in: rect, spacing: spacing, rising: true)
        lines.addPath(diagonals(in: rect, spacing: spacing, rising: false))
        let lattice = lines
        Art.clipped(&context, to: Path(rect)) { g in
            asanteRelief(&g, lattice, shadow: shadow, body: body, light: light, width: width)
        }
        asanteRelief(&context, Path(rect), shadow: shadow, body: body, light: light, width: width)
    }

    // MARK: The open side

    /// The right-hand part of the building stands open to the courtyard: a raised floor of
    /// polished earth, stout pillars, and the shaded room behind.
    private static func asanteOpenSide(_ context: inout GraphicsContext) {
        let room = Art.rect(268, 214, 126, 74)
        let roomStops: [(Color, CGFloat)] = [
            (Art.color(0x24122A), 0),
            (Art.color(0x3E1E30), 0.6),
            (Art.color(0x5A2A30), 1),
        ]
        fillVertical(&context, room, roomStops, from: 214, to: 288)

        // The back wall of the room, dim: white above, red below, a lattice just visible.
        Art.fill(&context, Art.rect(268, 232, 126, 30), Art.color(0xE8D2C4, 0.1))
        Art.fill(&context, Art.rect(268, 262, 126, 22), Art.color(0xB8401E, 0.28))
        let backLattice = CGRect(x: 284, y: 236, width: 38, height: 20)
        let dimShadow = Art.color(0x140A1C, 0.3)
        let dimBody = Art.color(0xE8D2C4, 0.1)
        let dimLight = Art.color(0xFFE6CC, 0.16)
        asanteLattice(&context, in: backLattice, spacing: 6, shadow: dimShadow, body: dimBody, light: dimLight, width: 1)
        let backLatticeTwo = CGRect(x: 342, y: 236, width: 34, height: 20)
        asanteLattice(&context, in: backLatticeTwo, spacing: 6, shadow: dimShadow, body: dimBody, light: dimLight, width: 1)

        // The raised floor.
        let floorFront = Art.rect(264, 284, 134, 16, radius: 2)
        let redStops: [(Color, CGFloat)] = [
            (Art.color(0xDA5A2C), 0),
            (Art.color(0xB03A1E), 0.6),
            (Art.color(0x8A2A1C), 1),
        ]
        fillVertical(&context, floorFront, redStops, from: 284, to: 300)
        Art.fill(&context, Art.rect(264, 282.5, 134, 3, radius: 1.5), Art.color(0xF08A56))
        let step = Art.rect(312, 295, 50, 7, radius: 2)
        fillVertical(&context, step, redStops, from: 293, to: 303)
        Art.fill(&context, Art.rect(312, 294.4, 50, 1.6, radius: 0.8), Art.color(0xF08A56, 0.9))

        // Two pillars: white above, polished red below.
        let pillars: [CGFloat] = [330, 388]
        let whiteStops: [(Color, CGFloat)] = [
            (Art.color(0xFFF0DA), 0),
            (Art.color(0xE4CFCC), 1),
        ]
        for x in pillars {
            let upper = Art.rect(x - 8, 214, 16, 44)
            fillHorizontal(&context, upper, whiteStops, from: x - 8, to: x + 8)
            let lower = Art.rect(x - 9.5, 256, 19, 28, radius: 2)
            fillVertical(&context, lower, redStops, from: 256, to: 284)
            Art.fill(&context, Art.rect(x - 9.5, 255.2, 19, 2.2, radius: 1.1), Art.color(0xF08A56))
            // A small plaited band on each pillar, and a moulding round the red base.
            let band = asanteBraid(from: x - 5.5, to: x + 5.5, centre: 240, amplitude: 4, period: 11)
            asanteRelief(&context, band, shadow: Art.color(0x9A7474, 0.85), body: Art.color(0xF8E8D6), light: Art.color(0xFFFFFF), width: 1.3)
            var moulding = Art.line(x - 7, 263, x + 7, 263)
            moulding.move(to: pt(x - 7, 276))
            moulding.addLine(to: pt(x + 7, 276))
            asanteRelief(&context, moulding, shadow: Art.color(0x6A1C14), body: Art.color(0xC8482A), light: Art.color(0xF08A56), width: 1.4)
        }
    }

    // MARK: The decorated wall

    private static func asanteWall(_ context: inout GraphicsContext) {
        // Upper wall: white clay.
        let upper = Art.rect(44, 214, 224, 50)
        let whiteStops: [(Color, CGFloat)] = [
            (Art.color(0xFFF2DC), 0),
            (Art.color(0xF4E4D6), 0.5),
            (Art.color(0xE6D2D0), 1),
        ]
        fillHorizontal(&context, upper, whiteStops, from: 44, to: 268)

        // Lower wall: red-orange earth, polished, standing a little proud of the white.
        let lower = Art.rect(40, 262, 232, 38, radius: 3)
        let redStops: [(Color, CGFloat)] = [
            (Art.color(0xDE5E2E), 0),
            (Art.color(0xB63E1E), 0.55),
            (Art.color(0x8C2C1C), 1),
        ]
        fillVertical(&context, lower, redStops, from: 262, to: 300)
        // The polish: a soft shine along the shoulder of the red wall.
        Art.fill(&context, Art.rect(42, 261.2, 228, 2.6, radius: 1.3), Art.color(0xF5925C))
        let sheen: [(Color, CGFloat)] = [
            (Art.color(0xFFD2A8, 0), 0),
            (Art.color(0xFFD2A8, 0.3), 0.3),
            (Art.color(0xFFD2A8, 0), 0.7),
            (Art.color(0xFFD2A8, 0), 1),
        ]
        fillHorizontal(&context, Art.rect(44, 265, 224, 7), sheen, from: 44, to: 268)

        let whiteShadow = Art.color(0x9A7474, 0.85)
        let whiteBody = Art.color(0xF8E8D6)
        let whiteLight = Art.color(0xFFFFFF)

        // Four panels on the white wall, each framed, each with a running pattern.
        for index in 0..<4 {
            let px = 48 + CGFloat(index) * 55
            let frame = Path(CGRect(x: px, y: 230, width: 49, height: 29))
            asanteRelief(&context, frame, shadow: whiteShadow, body: whiteBody, light: whiteLight, width: 1.6)
            if index == 0 || index == 3 {
                let scroll = asanteScroll(from: px + 5, to: px + 44, baseline: 254, radius: 6.5, count: 3, clockwise: index == 0)
                asanteRelief(&context, scroll, shadow: whiteShadow, body: whiteBody, light: whiteLight, width: 1.5)
                let top = Art.line(px + 5, 235, px + 44, 235)
                asanteRelief(&context, top, shadow: whiteShadow, body: whiteBody, light: whiteLight, width: 1.2)
            } else if index == 1 {
                let inner = CGRect(x: px + 5, y: 235, width: 39, height: 19)
                asanteLattice(&context, in: inner, spacing: 6.5, shadow: whiteShadow, body: whiteBody, light: whiteLight, width: 1.2)
            } else {
                let braidOne = asanteBraid(from: px + 5, to: px + 44, centre: 239.5, amplitude: 3.6, period: 13)
                let braidTwo = asanteBraid(from: px + 5, to: px + 44, centre: 249.5, amplitude: 3.6, period: 13)
                asanteRelief(&context, braidOne, shadow: whiteShadow, body: whiteBody, light: whiteLight, width: 1.3)
                asanteRelief(&context, braidTwo, shadow: whiteShadow, body: whiteBody, light: whiteLight, width: 1.3)
            }
        }

        // Bolder relief on the red wall: a moulding, then one long run of large curls.
        let redShadow = Art.color(0x6A1C14)
        let redBody = Art.color(0xC8482A)
        let redLight = Art.color(0xF4925C)
        var moulding = Art.line(46, 268, 266, 268)
        moulding.move(to: pt(46, 296))
        moulding.addLine(to: pt(266, 296))
        asanteRelief(&context, moulding, shadow: redShadow, body: redBody, light: redLight, width: 1.6)
        let curls = asanteScroll(from: 50, to: 262, baseline: 293, radius: 9.5, count: 8, clockwise: true)
        asanteRelief(&context, curls, shadow: redShadow, body: redBody, light: redLight, width: 2.2)

        // The end of the wall, where the open side begins.
        let jamb = Art.rect(262, 214, 9, 48)
        fillHorizontal(&context, jamb, whiteStops, from: 240, to: 276)
        Art.fill(&context, Art.rect(270.5, 214, 1.4, 48), Art.color(0x9A7474, 0.6))
    }

    /// The evening light across the whole front: warm at the left, dusk at the right,
    /// and the deep shadow under the eaves.
    private static func asanteWallLight(_ context: inout GraphicsContext) {
        let front = Art.rect(40, 214, 358, 88)
        let wash: [(Color, CGFloat)] = [
            (Art.color(0xFFB868, 0.3), 0),
            (Art.color(0xFFB868, 0), 0.42),
            (Art.color(0x3A1F4D, 0), 0.55),
            (Art.color(0x3A1F4D, 0.36), 1),
        ]
        fillHorizontal(&context, front, wash, from: 40, to: 398)
        let eaveShadow: [(Color, CGFloat)] = [
            (Art.color(0x22102A, 0.6), 0),
            (Art.color(0x22102A, 0.22), 0.5),
            (Art.color(0x22102A, 0), 1),
        ]
        fillVertical(&context, Art.rect(40, 214, 358, 18), eaveShadow, from: 214, to: 232)
    }

    // MARK: The thatched roof

    private static func asanteRoofShape() -> Path {
        var random = ArtRandom(57)
        var path = Path()
        path.move(to: pt(24, 216))
        path.addQuadCurve(to: pt(112, 88), control: pt(82, 146))
        path.addQuadCurve(to: pt(324, 88), control: pt(218, 93))
        path.addQuadCurve(to: pt(412, 216), control: pt(354, 146))
        // The trimmed, slightly ragged edge of the thatch.
        var x: CGFloat = 412
        while x > 28 {
            x -= 4
            let drop = random.next(in: 0.4...3.4)
            path.addLine(to: pt(x, 216 + drop))
        }
        path.closeSubpath()
        return path
    }

    private static func asanteRoof(_ context: inout GraphicsContext) {
        let roof = asanteRoofShape()
        let thatch: [(Color, CGFloat)] = [
            (Art.color(0xDCA860), 0),
            (Art.color(0xB47E42), 0.45),
            (Art.color(0x7C4C30), 0.85),
            (Art.color(0x502E28), 1),
        ]
        fillVertical(&context, roof, thatch, from: 88, to: 220)

        // Strands of thatch, combed down the slope, and the courses it is laid in.
        var random = ArtRandom(41)
        var darkStrands = Path()
        var lightStrands = Path()
        for index in 0..<280 {
            let x = random.next(in: 24...412)
            let y = random.next(in: 88...212)
            let length = random.next(in: 5...13)
            let lean = (x - 218) / 194 * 0.5 * length
            if index % 3 == 0 {
                lightStrands.move(to: pt(x, y))
                lightStrands.addLine(to: pt(x + lean, y + length))
            } else {
                darkStrands.move(to: pt(x, y))
                darkStrands.addLine(to: pt(x + lean, y + length))
            }
        }
        var courses = Path()
        let courseLevels: [CGFloat] = [112, 136, 160, 184, 204]
        for level in courseLevels {
            courses.move(to: pt(20, level))
            courses.addQuadCurve(to: pt(416, level), control: pt(218, level + 4))
        }
        let coursesLight = courses.applying(CGAffineTransform(translationX: 0, y: 1.3))
        let dark = darkStrands
        let light = lightStrands
        let allCourses = courses
        let evening: [(Color, CGFloat)] = [
            (Art.color(0xFFD08A, 0.3), 0),
            (Art.color(0xFFD08A, 0), 0.45),
            (Art.color(0x2A1438, 0), 0.55),
            (Art.color(0x2A1438, 0.4), 1),
        ]
        Art.clipped(&context, to: roof) { g in
            Art.stroke(&g, dark, Art.color(0x4E2C22, 0.32), width: 0.7)
            Art.stroke(&g, light, Art.color(0xF8D69A, 0.3), width: 0.7)
            Art.stroke(&g, allCourses, Art.color(0x4E2C22, 0.3), width: 1.1)
            Art.stroke(&g, coursesLight, Art.color(0xF8D69A, 0.16), width: 0.7)
            fillHorizontal(&g, Art.rect(20, 80, 400, 150), evening, from: 24, to: 412)
            Art.fill(&g, Art.rect(20, 209, 400, 14), Art.color(0x2A1420, 0.3))
        }

        // The ridge: a thick roll of thatch, bound at intervals.
        var ridge = Path()
        ridge.move(to: pt(110, 90))
        ridge.addQuadCurve(to: pt(326, 90), control: pt(218, 95))
        Art.stroke(&context, ridge, Art.color(0x8C5C36), width: 6.5)
        let ridgeLight = ridge.applying(CGAffineTransform(translationX: 0, y: -1.8))
        Art.stroke(&context, ridgeLight, Art.color(0xF2C680, 0.6), width: 1.4)
        var ties = Path()
        for index in 0..<12 {
            let x = 122 + CGFloat(index) * 17.4
            let offset = (x - 218) / 108
            let sag = 2.5 * (1 - offset * offset)
            ties.move(to: pt(x, 87 + sag))
            ties.addLine(to: pt(x, 93.4 + sag))
        }
        Art.stroke(&context, ties, Art.color(0x4E2C22, 0.6), width: 0.9, cap: .butt)

        // The line of shade tucked under the eaves.
        Art.stroke(&context, Art.line(42, 218.5, 396, 218.5), Art.color(0x22102A, 0.4), width: 1.6, cap: .butt)
    }

    // MARK: Finish

    private static func asanteFinish(_ context: inout GraphicsContext) {
        bottomFade(&context, 0x3A1F4D, from: 304, alpha: 0.85)
        tooth(&context, seed: 521, light: 0.06, dark: 0.06)
    }
}
