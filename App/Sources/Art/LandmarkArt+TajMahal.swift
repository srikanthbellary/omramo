import SwiftUI

// The Taj Mahal at blue dawn: our own drawing (no photograph, nothing traced).
// Card background #12305A.

extension LandmarkArt {
    static func paintTajMahal(_ context: inout GraphicsContext) {
        tajSky(&context)
        tajGarden(&context)
        tajPool(&context)
        tajPlinth(&context)
        Art.group(&context, opacity: 0.88) { g in
            tajMinaret(&g, x: 111, base: 233, top: 124, width: 8.5)
            tajMinaret(&g, x: 321, base: 233, top: 124, width: 8.5)
        }
        tajTomb(&context)
        tajMinaret(&context, x: 85, base: 234, top: 106, width: 11)
        tajMinaret(&context, x: 347, base: 234, top: 106, width: 11)
        tajCypresses(&context)
        tajFinish(&context)
    }

    // MARK: Sky

    private static func tajSky(_ context: inout GraphicsContext) {
        let sky: [(Color, CGFloat)] = [
            (Art.color(0x2B4888), 0),
            (Art.color(0x5673B4), 0.22),
            (Art.color(0xA4A6D4), 0.42),
            (Art.color(0xE9BFC6), 0.55),
            (Art.color(0xF9DCBE), 0.62),
            (Art.color(0xF9DCBE), 1),
        ]
        backdrop(&context, sky)

        Art.group(&context, opacity: 0.5) { g in
            stars(&g, count: 26, seed: 11, maxY: 110, color: Art.color(0xFFFFFF))
        }

        // The shared horizon band, then the low sun, just clear of the far trees.
        horizon(&context, y: 249, rise: 70, hex: 0xFFD9B0, alpha: 0.35)
        Art.glow(&context, 44, 242, 190, Art.color(0xFFD3A0), alpha: 0.6)
        Art.glow(&context, 44, 241, 46, Art.color(0xFFF1D2), alpha: 0.9)
        Art.fill(&context, Art.circle(44, 240, 8), Art.color(0xFFF8E2))

        Art.blurred(&context, radius: 5, opacity: 0.55) { g in
            var clouds = Path()
            clouds.addEllipse(in: CGRect(x: 20, y: 191, width: 140, height: 10))
            clouds.addEllipse(in: CGRect(x: 214, y: 206, width: 180, height: 8))
            clouds.addEllipse(in: CGRect(x: 160, y: 147, width: 120, height: 7))
            clouds.addEllipse(in: CGRect(x: 312, y: 117, width: 100, height: 6))
            Art.fill(&g, clouds, Art.color(0xFFD6CC))
        }

        // A few birds, far off.
        var birds = Path()
        let flock: [(CGFloat, CGFloat)] = [(302, 92), (314, 85), (329, 96), (344, 80)]
        for bird in flock {
            let x = bird.0
            let y = bird.1
            birds.move(to: pt(x - 3.2, y - 1.4))
            birds.addQuadCurve(to: pt(x, y), control: pt(x - 1.4, y - 2.2))
            birds.addQuadCurve(to: pt(x + 3.2, y - 1.4), control: pt(x + 1.4, y - 2.2))
        }
        Art.stroke(&context, birds, Art.color(0x2E3F6E, 0.55), width: 0.7)

        // The far bank of trees, hazy.
        let far = canopy(from: -12, to: 444, baseY: 249, height: 12, bump: 16, depth: 10, seed: 5)
        Art.fill(&context, far, Art.color(0x7483AE, 0.75))
    }

    // MARK: Garden and pool

    private static func tajGarden(_ context: inout GraphicsContext) {
        let ground = Art.rect(-24, 248, unitWidth + 48, unitHeight - 248 + 24)
        let stops: [(Color, CGFloat)] = [
            (Art.color(0x5A7392), 0),
            (Art.color(0x2E5672), 0.22),
            (Art.color(0x183C60), 0.6),
            (Art.color(0x12305A), 1),
        ]
        fillVertical(&context, ground, stops, from: 248, to: unitHeight)

        // Morning mist lying on the lawns.
        Art.blurred(&context, radius: 6, opacity: 0.4) { g in
            Art.fill(&g, Art.ellipse(216, 252, 230, 7), Art.color(0xF6D2C8))
        }

        // The stone walks either side of the water.
        var walks = Path()
        walks.move(to: pt(192, 250))
        walks.addLine(to: pt(104, 410))
        walks.move(to: pt(240, 250))
        walks.addLine(to: pt(328, 410))
        Art.stroke(&context, walks, Art.color(0xD7DCF0, 0.2), width: 1.2)
    }

    private static func tajPoolShape() -> Path {
        Art.polygon([pt(203, 250), pt(229, 250), pt(294, 412), pt(138, 412)])
    }

    /// The parts of the tomb that show in the water, as separate shapes.
    private static func tajSilhouette() -> [Path] {
        let parts: [Path] = [
            onionDome(216, 138, halfWidth: 27, height: 70),
            Art.rect(190, 136, 52, 26),
            Art.rect(141, 160, 150, 72),
            Art.rect(189, 150, 54, 82),
            Art.rect(76, 232, 280, 18),
            Art.rect(215.2, 46, 1.6, 26),
        ]
        return parts
    }

    private static func tajPool(_ context: inout GraphicsContext) {
        let border = Art.polygon([pt(198, 250), pt(234, 250), pt(306, 412), pt(126, 412)])
        Art.fill(&context, border, Art.color(0xCDD2E8, 0.42))

        let pool = tajPoolShape()
        let water: [(Color, CGFloat)] = [
            (Art.color(0xF3D0C8), 0),
            (Art.color(0xA7AFDA), 0.25),
            (Art.color(0x4865A0), 0.6),
            (Art.color(0x1A3A6A), 1),
        ]
        fillVertical(&context, pool, water, from: 250, to: unitHeight)

        // The mirrored tomb: flipped about the water's far edge and a little squashed.
        let mirror = CGAffineTransform(a: 1, b: 0, c: 0, d: -0.8, tx: 0, ty: 450)
        let parts = tajSilhouette()
        let deep: [(Color, CGFloat)] = [
            (Art.color(0x1A3A6A, 0), 0),
            (Art.color(0x1A3A6A, 0.35), 0.5),
            (Art.color(0x1A3A6A, 0.9), 1),
        ]
        Art.clipped(&context, to: pool) { g in
            Art.blurred(&g, radius: 1.6, opacity: 0.62) { layer in
                for part in parts {
                    Art.fill(&layer, part.applying(mirror), Art.color(0xF2F2FB))
                }
            }
            let veil = Art.rect(120, 250, 200, 170)
            fillVertical(&g, veil, deep, from: 262, to: unitHeight)
            let band = CGRect(x: 140, y: 258, width: 152, height: 140)
            ripples(&g, in: band, count: 30, seed: 17, color: Art.color(0xFFFFFF, 0.26), width: 0.6, length: 6...24)
            ripples(&g, in: band, count: 16, seed: 29, color: Art.color(0x12305A, 0.3), width: 0.7, length: 8...30)
        }

        var edges = Path()
        edges.move(to: pt(203, 250))
        edges.addLine(to: pt(138, 412))
        edges.move(to: pt(229, 250))
        edges.addLine(to: pt(294, 412))
        Art.stroke(&context, edges, Art.color(0xFFFFFF, 0.35), width: 0.8)
    }

    // MARK: Marble

    /// White marble in dawn light: rose-white on the sun's side, blue in the shade.
    private static func tajMarble(_ context: inout GraphicsContext, _ path: Path, from x0: CGFloat, to x1: CGFloat) {
        let stops: [(Color, CGFloat)] = [
            (Art.color(0xFFEFE2), 0),
            (Art.color(0xF7F6FC), 0.42),
            (Art.color(0xC0CAE6), 1),
        ]
        fillHorizontal(&context, path, stops, from: x0, to: x1)
    }

    private static func tajRecess(_ context: inout GraphicsContext, _ path: Path, from y0: CGFloat, to y1: CGFloat) {
        let stops: [(Color, CGFloat)] = [
            (Art.color(0x8799C8), 0),
            (Art.color(0x566AA0), 0.55),
            (Art.color(0x3B4E84), 1),
        ]
        fillVertical(&context, path, stops, from: y0, to: y1)
    }

    private static func tajPlinth(_ context: inout GraphicsContext) {
        // The tomb's contact shadow, falling a little to the right, away from the sun.
        ArtStyle.contactShadow(&context, 224, 251, 152, 5, alpha: 0.26)
        let plinth = Art.rect(76, 232, 280, 18)
        tajMarble(&context, plinth, from: 76, to: 356)
        Art.fill(&context, Art.rect(74, 231, 284, 2.2), Art.color(0xFFFFFF, 0.9))

        // A blind arcade along the plinth, and the steps in the middle.
        var arcade = Path()
        for index in 0..<22 {
            let x = 86 + CGFloat(index) * 12.4
            arcade.addPath(pointedArch(x, 248.5, width: 7, height: 11))
        }
        Art.fill(&context, arcade, Art.color(0x5F74A8, 0.3))
        Art.fill(&context, Art.rect(205, 240, 22, 10), Art.color(0x7C8DBA, 0.75))
        Art.fill(&context, Art.rect(205, 240, 22, 1), Art.color(0xFFFFFF, 0.7))
        Art.fill(&context, Art.rect(76, 249, 280, 1.4), Art.color(0x3C4F80, 0.45))
    }

    // MARK: Minarets

    private static func tajMinaret(_ context: inout GraphicsContext, x: CGFloat, base: CGFloat, top: CGFloat, width: CGFloat) {
        let half = width / 2
        let slim = width * 0.36
        let shaftTop = top + width * 2.2
        let shaft = Art.polygon([pt(x - half, base), pt(x - slim, shaftTop), pt(x + slim, shaftTop), pt(x + half, base)])
        tajMarble(&context, shaft, from: x - half, to: x + half)

        // Three balconies.
        var rings = Path()
        var shadows = Path()
        let fractions: [CGFloat] = [0.34, 0.67, 1]
        for fraction in fractions {
            let y = base + (shaftTop - base) * fraction
            let reach = width * 0.64 - width * 0.1 * fraction
            rings.addRect(CGRect(x: x - reach, y: y - 1.2, width: reach * 2, height: 2.4))
            shadows.move(to: pt(x - reach * 0.8, y + 1.9))
            shadows.addLine(to: pt(x + reach * 0.8, y + 1.9))
        }
        tajMarble(&context, rings, from: x - half, to: x + half)
        Art.stroke(&context, shadows, Art.color(0x5F74A8, 0.5), width: 0.7, cap: .butt)

        // The open kiosk and its little dome.
        let kioskHeight = width * 0.8
        let kioskTop = shaftTop - 1.2 - kioskHeight
        let kiosk = Art.rect(x - slim, kioskTop, slim * 2, kioskHeight)
        Art.fill(&context, kiosk, Art.color(0x4A5E94, 0.7))
        var posts = Path()
        let offsets: [CGFloat] = [-1, 0, 1]
        for offset in offsets {
            let px = x + offset * slim * 0.86
            posts.move(to: pt(px, kioskTop))
            posts.addLine(to: pt(px, kioskTop + kioskHeight))
        }
        Art.stroke(&context, posts, Art.color(0xF7F6FC), width: max(0.6, width * 0.09), cap: .butt)
        let eave = Art.rect(x - half, kioskTop - 1.4, width, 1.4)
        tajMarble(&context, eave, from: x - half, to: x + half)
        let domeHeight = width * 0.75
        let dome = onionDome(x, kioskTop - 1.4, halfWidth: slim, height: domeHeight)
        tajMarble(&context, dome, from: x - half, to: x + half)
        let finial = Art.line(x, kioskTop - 1.4 - domeHeight + 0.5, x, top)
        Art.stroke(&context, finial, Art.color(0xE9C983), width: 0.8)
    }

    // MARK: The tomb

    private static func tajKiosk(_ context: inout GraphicsContext, x: CGFloat, base: CGFloat, scale s: CGFloat) {
        let body = Art.rect(x - 8 * s, base - 12 * s, 16 * s, 12 * s)
        tajMarble(&context, body, from: x - 10 * s, to: x + 10 * s)
        var openings = Path()
        let offsets: [CGFloat] = [-4.4, 0, 4.4]
        for offset in offsets {
            openings.addPath(pointedArch(x + offset * s, base - 1 * s, width: 3.2 * s, height: 9 * s))
        }
        tajRecess(&context, openings, from: base - 11 * s, to: base)
        let eave = Art.rect(x - 10.5 * s, base - 14 * s, 21 * s, 2.2 * s)
        tajMarble(&context, eave, from: x - 10.5 * s, to: x + 10.5 * s)
        Art.fill(&context, Art.rect(x - 9 * s, base - 11.8 * s, 18 * s, 0.9 * s), Art.color(0x5F74A8, 0.4))
        let dome = onionDome(x, base - 14 * s, halfWidth: 7 * s, height: 13 * s)
        tajMarble(&context, dome, from: x - 10 * s, to: x + 10 * s)
        let finial = Art.line(x, base - 26.5 * s, x, base - 32 * s)
        Art.stroke(&context, finial, Art.color(0xE9C983), width: 0.9)
    }

    private static func tajTomb(_ context: inout GraphicsContext) {
        let cx: CGFloat = 216

        // The two kiosks behind the dome, then the drum and the great dome.
        tajKiosk(&context, x: cx - 34, base: 159, scale: 0.78)
        tajKiosk(&context, x: cx + 34, base: 159, scale: 0.78)

        let drum = Art.rect(190, 136, 52, 26)
        tajMarble(&context, drum, from: 186, to: 246)
        var drumLines = Path()
        drumLines.move(to: pt(190, 141))
        drumLines.addLine(to: pt(242, 141))
        drumLines.move(to: pt(190, 155))
        drumLines.addLine(to: pt(242, 155))
        Art.stroke(&context, drumLines, Art.color(0x7F90BC, 0.55), width: 0.6, cap: .butt)

        let dome = onionDome(cx, 138, halfWidth: 27, height: 70)
        tajMarble(&context, dome, from: 178, to: 254)
        let domeShade: [(Color, CGFloat)] = [
            (Art.color(0x8FA0CE, 0), 0),
            (Art.color(0x8FA0CE, 0), 0.5),
            (Art.color(0x7F92C4, 0.5), 1),
        ]
        Art.clipped(&context, to: dome) { g in
            Art.glow(&g, 201, 100, 42, Art.color(0xFFFFFF), alpha: 0.85)
            Art.fillLinear(&g, Art.rect(170, 60, 92, 84), domeShade, from: CGPoint(x: 196, y: 84), to: CGPoint(x: 258, y: 140))
            Art.fill(&g, Art.rect(170, 133, 92, 6), Art.color(0x7F90BC, 0.3))
        }
        // The lotus cap and the finial.
        Art.fill(&context, Art.ellipse(cx, 71.5, 5.2, 2.2), Art.color(0xF4F2FA))
        Art.stroke(&context, Art.line(cx, 70, cx, 46), Art.color(0xE9C983), width: 1.3)
        var beads = Path()
        beads.addEllipse(in: CGRect(x: cx - 2.4, y: 61.6, width: 4.8, height: 4.8))
        beads.addEllipse(in: CGRect(x: cx - 1.7, y: 55.3, width: 3.4, height: 3.4))
        beads.addEllipse(in: CGRect(x: cx - 1.1, y: 50.4, width: 2.2, height: 2.2))
        Art.fill(&context, beads, Art.color(0xF2D592))

        // The two kiosks in front of the dome.
        tajKiosk(&context, x: cx - 54, base: 160, scale: 1)
        tajKiosk(&context, x: cx + 54, base: 160, scale: 1)

        // The body, with its cut corners turning away from the light.
        let body = Art.rect(141, 160, 150, 72)
        tajMarble(&context, body, from: 141, to: 291)
        Art.fill(&context, Art.rect(141, 160, 19, 72), Art.color(0xE2B9B4, 0.22))
        Art.fill(&context, Art.rect(272, 160, 19, 72), Art.color(0x6F84B8, 0.3))
        Art.fill(&context, Art.rect(139, 158, 154, 3), Art.color(0xFFFFFF, 0.95))
        Art.fill(&context, Art.rect(141, 161, 150, 1.2), Art.color(0x7F90BC, 0.35))

        // Stacked arches either side of the great portal.
        var arches = Path()
        var frames = Path()
        let bays: [(CGFloat, CGFloat)] = [(150.5, 11), (174.5, 15), (257.5, 15), (281.5, 11)]
        for bay in bays {
            let x = bay.0
            let w = bay.1
            arches.addPath(pointedArch(x, 191, width: w, height: 22))
            arches.addPath(pointedArch(x, 229, width: w, height: 25))
            frames.addRect(CGRect(x: x - w / 2 - 2.2, y: 166, width: w + 4.4, height: 27))
            frames.addRect(CGRect(x: x - w / 2 - 2.2, y: 201, width: w + 4.4, height: 30))
        }
        tajRecess(&context, arches, from: 168, to: 230)
        Art.stroke(&context, arches, Art.color(0xFFFFFF, 0.75), width: 0.6)
        Art.stroke(&context, frames, Art.color(0x8E9CC6, 0.5), width: 0.5, cap: .butt, join: .miter)

        // The great portal: a tall frame that rises above the roof line.
        let frame = Art.rect(189, 150, 54, 82)
        tajMarble(&context, frame, from: 176, to: 262)
        Art.fill(&context, Art.rect(188, 148.5, 56, 2.4), Art.color(0xFFFFFF))
        let inlay = Art.rect(192.5, 154, 47, 78)
        Art.stroke(&context, inlay, Art.color(0x8E9CC6, 0.6), width: 0.6, cap: .butt, join: .miter)

        let portal = pointedArch(cx, 232, width: 36, height: 66)
        tajRecess(&context, portal, from: 166, to: 232)
        Art.clipped(&context, to: portal) { g in
            // Light falling into the left of the recess.
            Art.fill(&g, Art.polygon([pt(198, 160), pt(207, 160), pt(203, 232), pt(198, 232)]), Art.color(0xDCE3F6, 0.3))
            Art.fill(&g, pointedArch(216, 232, width: 13, height: 25), Art.color(0x22315E))
            Art.fill(&g, pointedArch(216, 198, width: 12, height: 15), Art.color(0x2E3F70, 0.8))
            Art.stroke(&g, Art.line(205, 204, 227, 204), Art.color(0xC9D2EC, 0.5), width: 0.6)
        }
        Art.stroke(&context, portal, Art.color(0xFFFFFF, 0.85), width: 0.9)

        // Slim pinnacles at the corners of the portal frame and of the body.
        var pinnacles = Path()
        let posts: [(CGFloat, CGFloat, CGFloat)] = [(189, 150, 139), (243, 150, 139), (141, 160, 151), (291, 160, 151)]
        for post in posts {
            pinnacles.move(to: pt(post.0, post.1))
            pinnacles.addLine(to: pt(post.0, post.2))
        }
        Art.stroke(&context, pinnacles, Art.color(0xF7F6FC), width: 1.3)
        var tips = Path()
        for post in posts {
            tips.addEllipse(in: CGRect(x: post.0 - 1.1, y: post.2 - 2.2, width: 2.2, height: 2.2))
        }
        Art.fill(&context, tips, Art.color(0xF2D592))

        // The string course between the two storeys.
        var course = Path()
        course.move(to: pt(141, 197))
        course.addLine(to: pt(189, 197))
        course.move(to: pt(243, 197))
        course.addLine(to: pt(291, 197))
        Art.stroke(&context, course, Art.color(0x8E9CC6, 0.55), width: 0.6, cap: .butt)
    }

    // MARK: Cypresses

    private static func tajCypress(_ x: CGFloat, _ baseY: CGFloat, height: CGFloat, width: CGFloat) -> Path {
        let top = baseY - height
        let mid = baseY - height * 0.5
        var path = Path()
        path.move(to: pt(x, top))
        path.addCurve(to: pt(x, baseY), control1: pt(x + width * 0.95, mid), control2: pt(x + width * 0.8, baseY))
        path.addCurve(to: pt(x, top), control1: pt(x - width * 0.8, baseY), control2: pt(x - width * 0.95, mid))
        path.closeSubpath()
        return path
    }

    private static func tajCypresses(_ context: inout GraphicsContext) {
        var dark = Path()
        var lit = Path()
        let sides: [CGFloat] = [-1, 1]
        for index in 0..<6 {
            let t = CGFloat(index) / 5
            let eased = t * t
            let baseY = 256 + eased * 110
            let offset = 30 + eased * 150
            let height = 14 + eased * 70
            let width = 3 + eased * 9
            for side in sides {
                let x = 216 + side * offset
                dark.addPath(tajCypress(x, baseY, height: height, width: width))
                lit.addPath(tajCypress(x - width * 0.2, baseY - height * 0.05, height: height * 0.88, width: width * 0.42))
            }
        }
        let depth: [(Color, CGFloat)] = [
            (Art.color(0x4A6686), 0),
            (Art.color(0x1C3A58), 0.4),
            (Art.color(0x0D2440), 1),
        ]
        fillVertical(&context, dark, depth, from: 242, to: 370)
        Art.fill(&context, lit, Art.color(0xF2C8B8, 0.13))
    }

    // MARK: Finish

    private static func tajFinish(_ context: inout GraphicsContext) {
        bottomFade(&context, 0x12305A, from: 300, alpha: 0.85)
        tooth(&context, seed: 301, light: 0.06, dark: 0.05)
        finish(&context, wash: 0.08, vignette: 0.07)
    }
}
