import SwiftUI
import OmramoCore

// The Novgorod Kremlin and Saint Sophia Cathedral by day, as they stand today: our own drawing
// (no photograph, nothing traced). Seen from across the River Volkhov: the tall, plain white
// cathedral with its five helmet-shaped domes (the middle one gold, the four round it
// grey-silver) behind the long red-brick fortress wall and two towers with tent-shaped wooden
// roofs; a green bank, the wide calm river with a reflection and a small boat; birches at the
// right edge as the near plane. Card background #1E3554.

extension LandmarkArt {
    /// novgorod-kremlin: the white five-domed cathedral behind the red-brick wall and towers,
    /// across the wide river, under a cool northern sky, by day.
    static func paintNovgorod(_ context: inout GraphicsContext) {
        novgorodSky(&context)
        novgorodFarTrees(&context)
        novgorodRiver(&context)
        novgorodCathedral(&context)
        novgorodWall(&context)
        novgorodRoundTower(&context)
        novgorodSquareTower(&context)
        novgorodBank(&context)
        novgorodReflection(&context)
        novgorodBoat(&context)
        novgorodBirches(&context)
        novgorodFinish(&context)
    }

    // MARK: Small tools

    /// Three gradient stops at 0, `middle` and 1.
    static func novgorodStops(_ a: UInt32, _ b: UInt32, _ c: UInt32, middle: CGFloat = 0.5) -> [(Color, CGFloat)] {
        let stops: [(Color, CGFloat)] = [
            (Art.color(a), 0),
            (Art.color(b), middle),
            (Art.color(c), 1),
        ]
        return stops
    }

    /// A helmet-shaped dome sitting on `baseY`: it bulges only a little past its base and
    /// draws up to a point, like an old warrior's helmet.
    static func novgorodHelmet(_ cx: CGFloat, _ baseY: CGFloat, halfWidth: CGFloat, height: CGFloat) -> Path {
        let bulge: CGFloat = halfWidth * 1.14
        let neck: CGFloat = halfWidth * 0.2
        let low: CGFloat = baseY - height * 0.55
        let high: CGFloat = baseY - height * 0.74
        let top: CGFloat = baseY - height
        var path = Path()
        path.move(to: pt(cx - halfWidth, baseY))
        path.addCurve(to: pt(cx, top), control1: pt(cx - bulge, low), control2: pt(cx - neck, high))
        path.addCurve(to: pt(cx + halfWidth, baseY), control1: pt(cx + neck, high), control2: pt(cx + bulge, low))
        path.closeSubpath()
        return path
    }

    /// Red brick in the one light, across a span from `x0` to `x1`.
    static func novgorodBrick(_ context: inout GraphicsContext, _ path: Path, from x0: CGFloat, to x1: CGFloat) {
        let stops: [(Color, CGFloat)] = novgorodStops(0xE08A66, 0xC2604A, 0x93423E, middle: 0.45)
        fillHorizontal(&context, path, stops, from: x0, to: x1)
    }

    // MARK: Sky and the far plane

    static func novgorodSky(_ context: inout GraphicsContext) {
        let sky: [(Color, CGFloat)] = [
            (Art.color(0x6C9FCC), 0),
            (Art.color(0xA9CDE4), 0.26),
            (Art.color(0xF1E8D4), 0.5),
            (Art.color(0xF1E8D4), 1),
        ]
        backdrop(&context, sky)

        // Soft northern clouds: pale tops, cool undersides. None in the top-left corner.
        let clouds: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
            (262, 74, 132, 24), (318, 112, 124, 18), (-10, 128, 118, 20), (60, 164, 96, 13), (286, 160, 110, 12),
        ]
        var tops = Path()
        var unders = Path()
        for cloud in clouds {
            tops.addPath(cloudBand(cloud.0, cloud.1, width: cloud.2, height: cloud.3))
            let underY: CGFloat = cloud.1 + cloud.3 * 0.12
            let underX: CGFloat = cloud.0 + cloud.2 * 0.08
            unders.addPath(cloudBand(underX, underY, width: cloud.2 * 0.84, height: cloud.3 * 0.5))
        }
        Art.fill(&context, unders, Art.color(0x8FA6CC, 0.3))
        Art.fill(&context, tops, Art.color(0xFFFBF0, 0.82))
        horizon(&context, y: 204, rise: 56, hex: 0xFFE4BC, alpha: 0.34)
    }

    /// The far plane: the tops of far trees behind the wall, veiled with the sky's own colour.
    static func novgorodFarTrees(_ context: inout GraphicsContext) {
        let back = canopy(from: -24, to: 456, baseY: 196, height: 20, bump: 26, depth: 20, seed: 41)
        Art.fill(&context, back, Art.color(0x7FA58E))
        let front = canopy(from: -24, to: 456, baseY: 200, height: 12, bump: 18, depth: 16, seed: 77)
        Art.fill(&context, front, Art.color(0x5F8E78))
        haze(&context, top: 150, bottom: 214, hex: 0xF1E8D4, alpha: 0.42)
    }

    // MARK: The river

    static func novgorodRiver(_ context: inout GraphicsContext) {
        let water = Art.rect(-24, 262, unitWidth + 48, unitHeight - 262 + 24)
        let stops: [(Color, CGFloat)] = [
            (Art.color(0xCFE3EA), 0),
            (Art.color(0x8FBAD6), 0.22),
            (Art.color(0x4C7BA8), 0.6),
            (Art.color(0x1E3554), 1),
        ]
        fillVertical(&context, water, stops, from: 262, to: unitHeight)
    }

    // MARK: The cathedral

    /// One drum with narrow windows and its helmet dome. `gold` is the middle dome.
    static func novgorodDrum(
        _ context: inout GraphicsContext,
        cx: CGFloat,
        top: CGFloat,
        bottom: CGFloat,
        width: CGFloat,
        domeHeight: CGFloat,
        gold: Bool
    ) {
        let half: CGFloat = width / 2
        let drum = Art.rect(cx - half, top, width, bottom - top)
        let white: [(Color, CGFloat)] = novgorodStops(0xFFF9EC, 0xEFEAE4, 0xBFC3DA, middle: 0.4)
        fillHorizontal(&context, drum, white, from: cx - half, to: cx + half)

        // Narrow windows round the drum, and the plain band under the dome.
        var slits = Path()
        let offsets: [CGFloat] = [-0.58, 0, 0.58]
        let slitW: CGFloat = width * 0.1
        let slitH: CGFloat = (bottom - top) * 0.42
        let slitY: CGFloat = top + (bottom - top) * 0.2
        for offset in offsets {
            let sx: CGFloat = cx + offset * half - slitW / 2
            slits.addPath(Art.rect(sx, slitY, slitW, slitH, radius: slitW / 2))
        }
        Art.fill(&context, slits, Art.color(0x4A5578, 0.78))
        let band = Art.rect(cx - half - 1, top - 1, width + 2, 3)
        fillHorizontal(&context, band, white, from: cx - half, to: cx + half)
        Art.fill(&context, Art.rect(cx - half, top + 2, width, 2), ArtStyle.coolShade.opacity(0.16))

        let domeHalf: CGFloat = half + 2.5
        let dome = novgorodHelmet(cx, top - 1, halfWidth: domeHalf, height: domeHeight)
        let metal: [(Color, CGFloat)] = gold
            ? novgorodStops(0xFFE9A0, 0xEBB542, 0xA9701E, middle: 0.4)
            : novgorodStops(0xE4EAF0, 0xA6B1C0, 0x687290, middle: 0.4)
        fillHorizontal(&context, dome, metal, from: cx - domeHalf, to: cx + domeHalf)
        model(&context, dome, light: 0.3, shade: 0.2, rim: gold ? 0.7 : 0)
        // The catchlight on the upper left of the metal.
        let glintX: CGFloat = cx - domeHalf * 0.42
        let glintY: CGFloat = top - 1 - domeHeight * 0.46
        let glint = Art.ellipse(glintX, glintY, domeHalf * 0.14, domeHeight * 0.16)
        Art.fill(&context, glint, Art.color(0xFFFDF2, gold ? 0.7 : 0.5))

        // A tiny plain finial on the point of the dome.
        let tip: CGFloat = top - 1 - domeHeight
        let rise: CGFloat = gold ? 11 : 7
        var finial = Art.line(cx, tip + 1, cx, tip - rise)
        let bar: CGFloat = gold ? 2.4 : 1.6
        finial.move(to: pt(cx - bar, tip - rise * 0.62))
        finial.addLine(to: pt(cx + bar, tip - rise * 0.62))
        let finialHex: UInt32 = gold ? 0xC98F2A : 0x7A8598
        Art.stroke(&context, finial, Art.color(finialHex), width: gold ? 1.1 : 0.9)
        Art.fill(&context, Art.circle(cx, tip, gold ? 1.7 : 1.3), Art.color(finialHex))
    }

    static func novgorodCathedral(_ context: inout GraphicsContext) {
        // The two farther drums first, then the nearer pair, then the tall middle one.
        novgorodDrum(&context, cx: 191, top: 94, bottom: 134, width: 19, domeHeight: 22, gold: false)
        novgorodDrum(&context, cx: 249, top: 94, bottom: 134, width: 19, domeHeight: 22, gold: false)
        novgorodDrum(&context, cx: 220, top: 82, bottom: 134, width: 32, domeHeight: 37, gold: true)
        novgorodDrum(&context, cx: 163, top: 101, bottom: 134, width: 22, domeHeight: 25, gold: false)
        novgorodDrum(&context, cx: 277, top: 101, bottom: 134, width: 22, domeHeight: 25, gold: false)

        // The low porch on the left and the stair block on the right.
        var wings = Path()
        wings.addPath(Art.polygon([pt(122, 208), pt(122, 160), pt(142, 150), pt(142, 208)]))
        wings.addPath(Art.polygon([pt(298, 208), pt(298, 146), pt(308, 140), pt(320, 148), pt(320, 208)]))
        let wingStops: [(Color, CGFloat)] = novgorodStops(0xFBF4E6, 0xE6E2DE, 0xB9BDD6)
        fillHorizontal(&context, wings, wingStops, from: 122, to: 320)
        let wingRoofs = Art.svg("M121,160.5 L142,150 M297,146.5 L308,140 L321,148.5")
        Art.stroke(&context, wingRoofs, Art.color(0x8693A6), width: 2)

        // The tall plain body: five bays, each under its own rounded gable.
        let roofline = "M140,130 Q156,106 172,130 Q188,106 204,130 Q220,104 236,130 Q252,106 268,130 Q284,106 300,130"
        let body = Art.svg(roofline + " L300,208 L140,208 Z")
        let white: [(Color, CGFloat)] = novgorodStops(0xFFFAEE, 0xF3EEE6, 0xC6C9DE, middle: 0.42)
        fillHorizontal(&context, body, white, from: 140, to: 300)
        model(&context, body, light: 0.16, shade: 0.14)
        novgorodFacade(&context)
        Art.stroke(&context, Art.svg(roofline), Art.color(0x8693A6), width: 2.2)
        Art.stroke(&context, Art.svg("M140,128.6 Q156,104.6 172,128.6 Q188,104.6 204,128.6"), Art.color(0xE4EAF0, 0.8), width: 0.8)
    }

    /// The flat strips that divide the white front into bays, and its narrow windows.
    static func novgorodFacade(_ context: inout GraphicsContext) {
        var litStrips = Path()
        var shadeStrips = Path()
        let edges: [CGFloat] = [140, 172, 204, 236, 268]
        for edge in edges {
            litStrips.addRect(CGRect(x: edge, y: 130, width: 2.2, height: 78))
            shadeStrips.addRect(CGRect(x: edge + 2.2, y: 130, width: 1.6, height: 78))
        }
        shadeStrips.addRect(CGRect(x: 297, y: 130, width: 3, height: 78))
        Art.fill(&context, litStrips, Art.color(0xFFFDF4, 0.85))
        Art.fill(&context, shadeStrips, ArtStyle.coolShade.opacity(0.14))

        var slits = Path()
        let centres: [CGFloat] = [157, 189, 221, 253, 285]
        for centre in centres {
            slits.addPath(Art.rect(centre - 1.6, 136, 3.2, 13, radius: 1.6))
            slits.addPath(Art.rect(centre - 1.6, 164, 3.2, 15, radius: 1.6))
        }
        slits.addPath(Art.rect(130, 172, 3, 11, radius: 1.5))
        slits.addPath(Art.rect(307.5, 158, 3, 11, radius: 1.5))
        Art.fill(&context, slits, Art.color(0x4A5578, 0.8))
        // The gables throw a little shade onto the wall under them.
        let underGable = Art.svg("M142,132 Q156,112 170,132 M174,132 Q188,112 202,132 M206,132 Q220,110 234,132 M238,132 Q252,112 266,132 M270,132 Q284,112 298,132")
        Art.stroke(&context, underGable, ArtStyle.coolShade.opacity(0.12), width: 2.4)
    }

    // MARK: The fortress wall

    static func novgorodWall(_ context: inout GraphicsContext) {
        var wall = Path()
        wall.addRect(CGRect(x: -24, y: 204, width: unitWidth + 48, height: 48))
        // Plain battlements along the top of the wall.
        var x: CGFloat = -22
        while x < unitWidth + 24 {
            wall.addRect(CGRect(x: x, y: 197.5, width: 5.4, height: 7))
            x += 9.6
        }
        novgorodBrick(&context, wall, from: -24, to: 456)
        let fall: [(Color, CGFloat)] = [
            (Art.color(0xFFD9A0, 0.22), 0),
            (Art.color(0xFFD9A0, 0), 0.4),
            (ArtStyle.coolShade.opacity(0.2), 1),
        ]
        fillVertical(&context, wall, fall, from: 197, to: 252)

        // Courses of brick, a pale string course, and the loopholes under the battlements.
        var courses = Path()
        let rows: [CGFloat] = [214, 220, 226, 232, 238, 244]
        for row in rows {
            courses.move(to: pt(-24, row))
            courses.addLine(to: pt(456, row))
        }
        Art.stroke(&context, courses, Art.color(0x7E3438, 0.2), width: 0.6, cap: .butt, dash: [7, 2.4])
        Art.stroke(&context, Art.line(-24, 204.4, 456, 204.4), Art.color(0xFFD2A8, 0.6), width: 0.9, cap: .butt)
        Art.stroke(&context, Art.line(-24, 209, 456, 209), Art.color(0x7E3438, 0.3), width: 0.8, cap: .butt)
        var loops = Path()
        var lx: CGFloat = 8
        while lx < unitWidth {
            loops.addRect(CGRect(x: lx, y: 211.5, width: 1.6, height: 5))
            lx += 28.8
        }
        Art.fill(&context, loops, Art.color(0x4A2038, 0.6))
    }

    // MARK: The towers

    /// The round tower on the left, with its overhanging gallery and conical wooden roof.
    static func novgorodRoundTower(_ context: inout GraphicsContext) {
        ArtStyle.contactShadow(&context, 98, 251, 26, 3, alpha: 0.2)
        let shaft = Art.rect(74, 176, 36, 76)
        novgorodBrick(&context, shaft, from: 74, to: 110)
        let gallery = Art.rect(71, 166, 42, 12, radius: 1)
        novgorodBrick(&context, gallery, from: 71, to: 113)
        // The round of the tower: a soft band of light left of the middle, shade at the right.
        let sheen: [(Color, CGFloat)] = [
            (Art.color(0xFFD9A0, 0), 0),
            (Art.color(0xFFD9A0, 0.3), 0.26),
            (Art.color(0xFFD9A0, 0), 0.55),
            (ArtStyle.coolShade.opacity(0.26), 1),
        ]
        fillHorizontal(&context, Art.rect(71, 166, 42, 86), sheen, from: 71, to: 113)
        Art.fill(&context, Art.rect(74, 178, 36, 3), ArtStyle.coolShade.opacity(0.22))

        var courses = Path()
        let rows: [CGFloat] = [190, 198, 206, 214, 222, 230, 238, 246]
        for row in rows {
            courses.move(to: pt(74, row))
            courses.addLine(to: pt(110, row))
        }
        Art.stroke(&context, courses, Art.color(0x7E3438, 0.2), width: 0.6, cap: .butt, dash: [6, 2])
        var loops = Path()
        loops.addRect(CGRect(x: 81, y: 169, width: 2, height: 5.5))
        loops.addRect(CGRect(x: 91, y: 169, width: 2, height: 5.5))
        loops.addRect(CGRect(x: 101, y: 169, width: 2, height: 5.5))
        loops.addPath(Art.rect(86, 196, 3, 9, radius: 1.5))
        loops.addPath(Art.rect(96, 220, 3, 9, radius: 1.5))
        Art.fill(&context, loops, Art.color(0x4A2038, 0.7))

        let roof = Art.svg("M66,167 Q78,150 92,112 Q106,150 118,167 Q92,171 66,167 Z")
        let wood: [(Color, CGFloat)] = novgorodStops(0xB08C6C, 0x86654E, 0x55423E, middle: 0.4)
        fillHorizontal(&context, roof, wood, from: 66, to: 118)
        model(&context, roof, light: 0.22, shade: 0.2, rim: 0.5)
        let boards = Art.svg("M92,114 L80,167 M92,114 L92,169 M92,114 L104,167")
        Art.stroke(&context, boards, Art.color(0x4A3838, 0.3), width: 0.7)
        Art.stroke(&context, Art.line(92, 113, 92, 104), Art.color(0x6A5650), width: 1)
        Art.fill(&context, Art.circle(92, 104, 1.5), Art.color(0x6A5650))
    }

    /// The square gate tower on the right, seen a little from the left: a lit front, a shaded
    /// side, and a tall tent-shaped wooden roof.
    static func novgorodSquareTower(_ context: inout GraphicsContext) {
        ArtStyle.contactShadow(&context, 354, 251, 26, 3, alpha: 0.2)
        let front = Art.rect(330, 170, 27, 82)
        let side = Art.rect(357, 170, 10, 82)
        novgorodBrick(&context, front, from: 318, to: 400)
        Art.fill(&context, side, Art.color(0x93423E))
        Art.fill(&context, side, ArtStyle.coolShade.opacity(0.22))
        // The wider head of the tower, with its row of loopholes.
        let headFront = Art.rect(327, 158, 31, 13)
        let headSide = Art.rect(358, 158, 12, 13)
        novgorodBrick(&context, headFront, from: 315, to: 400)
        Art.fill(&context, headSide, Art.color(0x8A3C3C))
        Art.fill(&context, headSide, ArtStyle.coolShade.opacity(0.22))
        Art.fill(&context, Art.rect(330, 171, 37, 3), ArtStyle.coolShade.opacity(0.22))
        Art.stroke(&context, Art.line(327, 158.5, 358, 158.5), Art.color(0xFFD2A8, 0.6), width: 0.9, cap: .butt)

        var courses = Path()
        let rows: [CGFloat] = [184, 192, 200, 208, 216, 224, 232, 240]
        for row in rows {
            courses.move(to: pt(330, row))
            courses.addLine(to: pt(357, row))
        }
        Art.stroke(&context, courses, Art.color(0x7E3438, 0.2), width: 0.6, cap: .butt, dash: [6, 2])
        var loops = Path()
        loops.addRect(CGRect(x: 333, y: 161.5, width: 2, height: 5.5))
        loops.addRect(CGRect(x: 341.5, y: 161.5, width: 2, height: 5.5))
        loops.addRect(CGRect(x: 350, y: 161.5, width: 2, height: 5.5))
        loops.addPath(Art.rect(342, 188, 3.2, 10, radius: 1.6))
        // The gateway at the foot of the tower.
        loops.addPath(pointedArch(343.5, 252, width: 12, height: 20))
        Art.fill(&context, loops, Art.color(0x4A2038, 0.75))

        let litFace = Art.polygon([pt(323, 158), pt(346, 100), pt(360, 158)])
        let shadeFace = Art.polygon([pt(360, 158), pt(346, 100), pt(373, 158)])
        let wood: [(Color, CGFloat)] = novgorodStops(0xB69070, 0x94705A, 0x7A5C4E)
        fillVertical(&context, litFace, wood, from: 100, to: 158)
        Art.fill(&context, shadeFace, Art.color(0x5A4744))
        model(&context, litFace, light: 0.22, shade: 0.1)
        let boards = Art.svg("M346,102 L333,158 M346,102 L343,158 M346,102 L352,158 M346,102 L367,158")
        Art.stroke(&context, boards, Art.color(0x4A3838, 0.28), width: 0.7)
        Art.stroke(&context, Art.line(323, 158, 346, 100), Art.color(0xFFE2BC, 0.7), width: 0.9)
        Art.stroke(&context, Art.line(346, 100, 346, 90), Art.color(0x6A5650), width: 1)
        Art.fill(&context, Art.circle(346, 90, 1.6), Art.color(0x6A5650))
    }

    // MARK: The bank and the water

    static func novgorodBank(_ context: inout GraphicsContext) {
        let bank = Art.svg("M-24,247 L456,247 L456,277 C380,272 300,280 220,276 C140,272 60,279 -24,275 Z")
        let grass: [(Color, CGFloat)] = novgorodStops(0xA8CC78, 0x6FA65C, 0x437A52, middle: 0.5)
        fillVertical(&context, bank, grass, from: 247, to: 279)
        let lightFall: [(Color, CGFloat)] = [
            (Art.color(0xFFE9A8, 0.3), 0),
            (Art.color(0xFFE9A8, 0), 0.6),
            (ArtStyle.coolShade.opacity(0.14), 1),
        ]
        fillHorizontal(&context, bank, lightFall, from: 0, to: 432)
        // The shade of the wall on the grass, and the pale edge of sand at the water.
        let wallShade: [(Color, CGFloat)] = [
            (ArtStyle.coolShade.opacity(0.24), 0),
            (ArtStyle.coolShade.opacity(0), 1),
        ]
        fillVertical(&context, Art.rect(-24, 247, 480, 8), wallShade, from: 247, to: 255)
        let sand = Art.svg("M-24,275 C60,279 140,272 220,276 C300,280 380,272 456,277")
        Art.stroke(&context, sand, Art.color(0xF3E3BC, 0.8), width: 1.6)

        // Bushes at the foot of the wall and one round tree, each with its lit side.
        let bushes = canopy(from: 120, to: 318, baseY: 252, height: 8, bump: 13, depth: 4, seed: 23)
        Art.fill(&context, bushes, Art.color(0x3F7A4C))
        let bushTops = canopy(from: 120, to: 318, baseY: 251, height: 5, bump: 9, depth: 1, seed: 29)
        Art.fill(&context, bushTops, Art.color(0x9CC870, 0.45))

        ArtStyle.contactShadow(&context, 40, 258, 15, 2.6, alpha: 0.24)
        Art.stroke(&context, Art.line(36, 258, 36, 240), Art.color(0x5A4638), width: 2.2)
        var crown = Path()
        crown.addPath(Art.circle(36, 228, 12))
        crown.addPath(Art.circle(26, 236, 8.5))
        crown.addPath(Art.circle(46, 236, 9.5))
        crown.addPath(Art.circle(40, 220, 7.5))
        Art.fill(&context, crown, Art.color(0x3E7C4E))
        model(&context, crown, light: 0.34, shade: 0.26)
        var crownLights = Path()
        crownLights.addPath(Art.circle(31, 224, 6))
        crownLights.addPath(Art.circle(24, 234, 4))
        Art.fill(&context, crownLights, Art.color(0xA6D078, 0.4))
    }

    /// The still reflection of the wall, the towers and the cathedral, broken by ripples.
    static func novgorodReflection(_ context: inout GraphicsContext) {
        let red: [(Color, CGFloat)] = [(Art.color(0xB85A48, 0.4), 0), (Art.color(0xB85A48, 0), 1)]
        fillVertical(&context, Art.rect(-24, 280, 480, 28), red, from: 280, to: 308)
        var towers = Path()
        towers.addRect(CGRect(x: 75, y: 280, width: 34, height: 58))
        towers.addRect(CGRect(x: 331, y: 280, width: 35, height: 64))
        let towerStops: [(Color, CGFloat)] = [(Art.color(0xA85244, 0.4), 0), (Art.color(0x6A4A5A, 0), 1)]
        fillVertical(&context, towers, towerStops, from: 280, to: 344)
        let white: [(Color, CGFloat)] = [
            (Art.color(0xFFF8EA, 0), 0),
            (Art.color(0xFFF8EA, 0.5), 0.3),
            (Art.color(0xFFF8EA, 0), 1),
        ]
        fillVertical(&context, Art.rect(144, 290, 152, 70), white, from: 290, to: 360)
        let gold: [(Color, CGFloat)] = [
            (Art.color(0xF2C050, 0), 0),
            (Art.color(0xF2C050, 0.6), 0.4),
            (Art.color(0xF2C050, 0), 1),
        ]
        fillVertical(&context, Art.rect(208, 332, 24, 52), gold, from: 332, to: 384)

        let near = CGRect(x: 0, y: 284, width: 432, height: 100)
        ripples(&context, in: near, count: 44, seed: 19, color: Art.color(0xEAF4FA, 0.42), width: 0.9, length: 8...28)
        ripples(&context, in: near, count: 30, seed: 53, color: Art.color(0x2E4E7A, 0.3), width: 1, length: 10...34)
        let far = CGRect(x: 0, y: 279, width: 432, height: 10)
        ripples(&context, in: far, count: 14, seed: 67, color: Art.color(0xFFFFFF, 0.5), width: 0.6, length: 6...18)
    }

    /// A small rowing boat on the river, with one tiny rower: dark shapes and a lit rim.
    static func novgorodBoat(_ context: inout GraphicsContext) {
        Art.group(&context, x: 116, y: 322) { g in
            Art.fill(&g, Art.ellipse(2, 6.5, 20, 2.6), Art.color(0x24365A, 0.34))
            let hull = Art.svg("M-18,-3 L19,-3 Q15,5 2,5 L-6,5 Q-15,4 -18,-3 Z")
            Art.fill(&g, hull, Art.color(0x6A4436))
            LandmarkArt.model(&g, hull, light: 0.2, shade: 0.24)
            Art.stroke(&g, Art.line(-18, -3, 19, -3), Art.color(0xF2D2A4), width: 1)
            // The rower, sitting, and the two oars.
            let coat = Art.polygon([pt(-3.4, -3), pt(-2.4, -10), pt(2.6, -10), pt(3.6, -3)])
            Art.fill(&g, coat, Art.color(0x2F5E8A))
            Art.fill(&g, Art.circle(0.2, -12.4, 2.5), Art.color(0xE8B890))
            Art.fill(&g, Art.svg("M-2.4,-13 Q0.2,-16.6 2.8,-13 Z"), Art.color(0xC2523E))
            let oars = Art.svg("M1,-7 L13,3 M-1,-7 L-12,3.4")
            Art.stroke(&g, oars, Art.color(0x8A6A4E), width: 0.9)
            let wake = Art.svg("M-24,8 L-40,8 M22,7 L34,7 M-30,11 L-12,11")
            Art.stroke(&g, wake, Art.color(0xF2FAFF, 0.6), width: 0.8)
        }
    }

    // MARK: The near plane

    /// Two birch trunks at the right edge, with hanging twigs of dark leaves from the top
    /// right corner: the near plane, clear of the towers and the domes.
    static func novgorodBirches(_ context: inout GraphicsContext) {
        let tuft = canopy(from: 384, to: 460, baseY: 366, height: 16, bump: 12, depth: 70, seed: 91)
        Art.fill(&context, tuft, Art.color(0x23463E))

        let trunkA = Art.svg("M416,428 C418,330 411,230 417,130 C419,80 423,30 426,-24 L436,-24 C434,40 430,90 428,134 C424,240 431,330 431,428 Z")
        let trunkB = Art.svg("M436,428 C434,320 440,200 438,90 C438,50 440,10 442,-24 L456,-24 L456,428 Z")
        var trunks = Path()
        trunks.addPath(trunkB)
        trunks.addPath(trunkA)
        let bark: [(Color, CGFloat)] = novgorodStops(0xE6E4EC, 0xB6B6CE, 0x7C7CA4, middle: 0.4)
        fillHorizontal(&context, trunks, bark, from: 410, to: 450)
        let marks = Art.svg("M417,60 L424,61 M423,98 L429,97 M415,150 L421,152 M420,196 L427,195 M414,246 L420,247 M421,292 L428,291 M417,338 L423,340 M440,74 L448,75 M439,170 L446,169 M441,262 L449,263")
        Art.stroke(&context, marks, Art.color(0x3A3558, 0.75), width: 1.8)
        Art.stroke(&context, Art.svg("M417,130 C411,230 418,330 416,404"), Art.color(0xFFF6E4, 0.6), width: 1)

        // Hanging twigs: short near the tower, longer toward the corner.
        var random = ArtRandom(733)
        var twigs = Path()
        var leaves = Path()
        var glints = Path()
        for strand in 0..<9 {
            let x0: CGFloat = 368 + CGFloat(strand) * 9
            let reach: CGFloat = 30 + CGFloat(strand) * 9 + random.next(in: 0...10)
            let sway: CGFloat = random.next(in: -9...3)
            twigs.move(to: pt(x0, -8))
            twigs.addQuadCurve(to: pt(x0 + sway, reach), control: pt(x0 + sway * 0.2, reach * 0.5))
            let count: Int = max(2, Int(reach / 8))
            for index in 1...count {
                let t: CGFloat = CGFloat(index) / CGFloat(count)
                let px: CGFloat = x0 + sway * t * t
                let py: CGFloat = -8 + (reach + 8) * t
                let side: CGFloat = index % 2 == 0 ? 0.75 : -0.75
                let angle: CGFloat = CGFloat.pi / 2 + side + random.next(in: -0.2...0.2)
                leaves.addPath(leaf(px, py, length: 9.5, width: 3.2, angle: angle))
                if index % 3 == 0 {
                    glints.addPath(leaf(px - 0.6, py, length: 7, width: 1, angle: angle))
                }
            }
        }
        Art.stroke(&context, twigs, Art.color(0x2A3A3A), width: 0.9)
        Art.fill(&context, leaves, Art.color(0x25503C))
        Art.fill(&context, glints, Art.color(0xA9CF74, 0.7))
    }

    // MARK: Finish

    static func novgorodFinish(_ context: inout GraphicsContext) {
        bottomFade(&context, 0x1E3554, from: 300, alpha: 0.9)
        tooth(&context, seed: 947, light: 0.05, dark: 0.04)
        finish(&context, wash: 0.10, vignette: 0.10)
    }
}
