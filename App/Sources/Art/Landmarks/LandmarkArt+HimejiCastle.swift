import SwiftUI
import OmramoCore

// Himeji Castle, the White Heron Castle, by day: the tall main keep of five white storeys under
// grey tiled roofs with upturned eaves and gables, on a high sloping stone base, a smaller
// tower beside it, pines and a little cherry blossom at the foot of the hill.
// Our own drawing (no photograph, nothing traced). Card background #1B3A5C.

extension LandmarkArt {
    /// himeji-castle: the white keep and its small tower on their stone bases, on a green hill.
    static func paintHimejiCastle(_ context: inout GraphicsContext) {
        himejiSky(&context)
        himejiHill(&context)
        himejiOuterWalls(&context)
        himejiSmallTower(&context, cx: 116)
        himejiLink(&context)
        himejiKeep(&context, cx: 246)
        himejiFootTrees(&context)
        himejiNearPine(&context)
        bottomFade(&context, 0x1B3A5C, from: 300, alpha: 0.9)
        tooth(&context, seed: 611, light: 0.06, dark: 0.05)
        finish(&context, wash: 0.10, vignette: 0.10)
    }

    /// One storey: wall half-width, wall bottom, wall top (the eave line of the roof above it),
    /// eave half-width, roof top, roof top half-width.
    private static let himejiKeepTiers: [(CGFloat, CGFloat, CGFloat, CGFloat, CGFloat, CGFloat)] = [
        (76, 232, 214, 88, 202, 64),
        (64, 202, 186, 76, 174, 52),
        (52, 174, 158, 63, 147, 42),
        (42, 147, 132, 52, 122, 33),
        (33, 122, 106, 46, 86, 19),
    ]

    private static let himejiSmallTiers: [(CGFloat, CGFloat, CGFloat, CGFloat, CGFloat, CGFloat)] = [
        (27, 240, 224, 36, 214, 20),
        (20, 214, 200, 29, 185, 9),
    ]

    // MARK: Sky and hill

    private static func himejiSky(_ context: inout GraphicsContext) {
        let sky: Kit.Stops = [
            (Art.color(0x4C97DB), 0),
            (Art.color(0x7FB9EA), 0.36),
            (Art.color(0xBFDDF2), 0.58),
            (Art.color(0xFFE9C6), 0.70),
            (Art.color(0xFFE9C6), 1),
        ]
        backdrop(&context, sky)
        horizon(&context, y: 270, rise: 64, hex: 0xFFE0AE, alpha: 0.4)
        Kit.cloud(&context, 356, 96, scale: 0.62, color: Art.color(0xFFFFFF, 0.9))
        Kit.cloud(&context, 40, 196, scale: 0.42, color: Art.color(0xFFFFFF, 0.8))
        Kit.birds(&context, 322, 146, scale: 0.5, color: Art.color(0x3D5C8C, 0.55))

        // The far plane: two ranges of hills, veiled with the warm air of the horizon.
        let farthest = Kit.ridge(width: 480, y: 250, amp: 16, seed: 23, bottom: 300, step: 8, x0: -24)
        Art.fill(&context, farthest, Art.color(0x9FBAD6, 0.7))
        let far = Kit.ridge(width: 480, y: 262, amp: 10, seed: 41, bottom: 300, step: 8, x0: -24)
        Art.fill(&context, far, Art.color(0x7FA6B4))
        haze(&context, top: 226, bottom: 278, hex: 0xFFE9C6, alpha: 0.4)
    }

    private static func himejiHill(_ context: inout GraphicsContext) {
        var hill = Path()
        hill.move(to: pt(-24, 430))
        hill.addLine(to: pt(-24, 292))
        hill.addQuadCurve(to: pt(216, 268), control: pt(90, 266))
        hill.addQuadCurve(to: pt(456, 296), control: pt(350, 270))
        hill.addLine(to: pt(456, 430))
        hill.closeSubpath()
        let grass: Kit.Stops = [
            (Art.color(0x86BE6E), 0),
            (Art.color(0x4C8F5C), 0.3),
            (Art.color(0x2A5C5A), 0.7),
            (Art.color(0x1B3A5C), 1),
        ]
        fillVertical(&context, hill, grass, from: 266, to: unitHeight)
        model(&context, hill, light: 0.2, shade: 0.16)
        // The castle's shadow lies on the hill, a little to the right.
        ArtStyle.contactShadow(&context, 236, 290, 160, 7, alpha: 0.26)
    }

    /// The low white walls with tiled copings that run along the hill either side.
    private static func himejiOuterWalls(_ context: inout GraphicsContext) {
        var walls = Path()
        walls.addPath(Art.polygon([pt(-24, 283), pt(22, 274), pt(72, 267), pt(72, 277), pt(22, 284), pt(-24, 293)]))
        walls.addPath(Art.polygon([pt(356, 269), pt(412, 278), pt(456, 287), pt(456, 297), pt(412, 288), pt(356, 279)]))
        himejiPlaster(&context, walls, from: -24, to: 456)
        var copings = Path()
        copings.move(to: pt(-24, 282))
        copings.addLine(to: pt(22, 273))
        copings.addLine(to: pt(73, 266))
        copings.move(to: pt(355, 268))
        copings.addLine(to: pt(412, 277))
        copings.addLine(to: pt(456, 286))
        Art.stroke(&context, copings, Art.color(0x7F8A9C), width: 3, cap: .butt)
        var edges = Path()
        edges.move(to: pt(-24, 280.8))
        edges.addLine(to: pt(22, 271.8))
        edges.addLine(to: pt(73, 264.8))
        edges.move(to: pt(355, 266.8))
        edges.addLine(to: pt(412, 275.8))
        edges.addLine(to: pt(456, 284.8))
        Art.stroke(&context, edges, Art.color(0xF1EEE8, 0.6), width: 0.7, cap: .butt)
    }

    // MARK: Materials

    /// White plaster in day light: warm on the sun's side, lilac in the shade.
    private static func himejiPlaster(_ context: inout GraphicsContext, _ path: Path, from x0: CGFloat, to x1: CGFloat) {
        let stops: Kit.Stops = [
            (Art.color(0xFFF2D8), 0),
            (Art.color(0xFDFBF5), 0.4),
            (Art.color(0xC9C2E6), 1),
        ]
        fillHorizontal(&context, path, stops, from: x0, to: x1)
    }

    /// A stone base with the inward-curving slope of a Japanese castle wall.
    private static func himejiStoneBase(
        _ context: inout GraphicsContext,
        cx: CGFloat,
        topY: CGFloat,
        topHalf: CGFloat,
        bottomY: CGFloat,
        bottomHalf: CGFloat
    ) {
        let bend: CGFloat = topHalf + (bottomHalf - topHalf) * 0.22
        let bendY: CGFloat = topY + (bottomY - topY) * 0.6
        var base = Path()
        base.move(to: pt(cx - topHalf, topY))
        base.addLine(to: pt(cx + topHalf, topY))
        base.addQuadCurve(to: pt(cx + bottomHalf, bottomY), control: pt(cx + bend, bendY))
        base.addLine(to: pt(cx - bottomHalf, bottomY))
        base.addQuadCurve(to: pt(cx - topHalf, topY), control: pt(cx - bend, bendY))
        base.closeSubpath()
        let stone: Kit.Stops = [(Art.color(0xCDBFA6), 0), (Art.color(0xA39782), 1)]
        fillVertical(&context, base, stone, from: topY, to: bottomY)

        // Courses of fitted stone, the joints staggered row by row.
        var courses = Path()
        var y: CGFloat = topY + 6
        var row: Int = 0
        while y < bottomY + 6 {
            courses.move(to: pt(cx - bottomHalf, y))
            courses.addLine(to: pt(cx + bottomHalf, y))
            let offset: CGFloat = row % 2 == 0 ? 0 : 7
            var x: CGFloat = cx - bottomHalf + offset
            while x < cx + bottomHalf {
                courses.move(to: pt(x, y - 6))
                courses.addLine(to: pt(x, y))
                x += 14
            }
            y += 6
            row += 1
        }
        Art.clipped(&context, to: base) { g in
            Art.stroke(&g, courses, Art.color(0x766B58, 0.38), width: 0.7, cap: .butt)
        }
        model(&context, base, light: 0.24, shade: 0.3, rim: 0.5)
    }

    // MARK: Roofs

    /// A skirt of roof: narrow at the top, sweeping out to eaves whose corners turn up.
    private static func himejiRoofShape(_ cx: CGFloat, eaveY: CGFloat, eaveHalf: CGFloat, topY: CGFloat, topHalf: CGFloat) -> Path {
        let tip: CGFloat = eaveHalf + 4
        let lift: CGFloat = eaveY - 3.5
        let swing: CGFloat = topHalf + (eaveHalf - topHalf) * 0.5
        let under: CGFloat = eaveY + 2.5
        let belly: CGFloat = eaveHalf * 0.55
        var path = Path()
        path.move(to: pt(cx - topHalf, topY))
        path.addLine(to: pt(cx + topHalf, topY))
        path.addQuadCurve(to: pt(cx + tip, lift), control: pt(cx + swing, eaveY - 0.5))
        path.addQuadCurve(to: pt(cx, under), control: pt(cx + belly, under + 0.5))
        path.addQuadCurve(to: pt(cx - tip, lift), control: pt(cx - belly, under + 0.5))
        path.addQuadCurve(to: pt(cx - topHalf, topY), control: pt(cx - swing, eaveY - 0.5))
        path.closeSubpath()
        return path
    }

    private static func himejiRoof(_ context: inout GraphicsContext, _ cx: CGFloat, eaveY: CGFloat, eaveHalf: CGFloat, topY: CGFloat, topHalf: CGFloat) {
        let roof = himejiRoofShape(cx, eaveY: eaveY, eaveHalf: eaveHalf, topY: topY, topHalf: topHalf)
        let tiles: Kit.Stops = [
            (Art.color(0x76829A), 0),
            (Art.color(0x929EB2), 0.7),
            (Art.color(0xAEB8C8), 1),
        ]
        fillVertical(&context, roof, tiles, from: topY, to: eaveY + 3)

        // Rows of tiles, fanning out from the top of the roof to the eaves.
        var rows = Path()
        let count: Int = max(6, Int(eaveHalf / 3.2))
        let swing: CGFloat = topHalf + (eaveHalf - topHalf) * 0.5
        for index in 0...count {
            let t: CGFloat = CGFloat(index) / CGFloat(count)
            let side: CGFloat = t * 2 - 1
            let foot = pt(cx + side * (eaveHalf + 2), eaveY + 2)
            rows.move(to: pt(cx + side * topHalf, topY))
            rows.addQuadCurve(to: foot, control: pt(cx + side * swing, eaveY - 1))
        }
        Art.clipped(&context, to: roof) { g in
            Art.stroke(&g, rows, Art.color(0x4F5A72, 0.42), width: 0.7, cap: .butt)
        }
        model(&context, roof, light: 0.24, shade: 0.28)

        // The pale plastered edge of the eaves.
        let tip: CGFloat = eaveHalf + 4
        let belly: CGFloat = eaveHalf * 0.55
        var edge = Path()
        edge.move(to: pt(cx + tip, eaveY - 3.5))
        edge.addQuadCurve(to: pt(cx, eaveY + 2.5), control: pt(cx + belly, eaveY + 3))
        edge.addQuadCurve(to: pt(cx - tip, eaveY - 3.5), control: pt(cx - belly, eaveY + 3))
        Art.stroke(&context, edge, Art.color(0xF4F1EA, 0.85), width: 1.1)
    }

    /// A gable standing on a roof: a triangular one with swept sides, or a curved bell-shaped one.
    private static func himejiGableShape(_ cx: CGFloat, baseY: CGFloat, half: CGFloat, height: CGFloat, curved: Bool) -> Path {
        let top: CGFloat = baseY - height
        var path = Path()
        if curved {
            let low: CGFloat = baseY - height * 0.05
            path.move(to: pt(cx - half, baseY + 1))
            path.addCurve(to: pt(cx, top), control1: pt(cx - half * 0.7, low), control2: pt(cx - half * 0.55, top))
            path.addCurve(to: pt(cx + half, baseY + 1), control1: pt(cx + half * 0.55, top), control2: pt(cx + half * 0.7, low))
        } else {
            let sweep: CGFloat = baseY - height * 0.3
            path.move(to: pt(cx - half - 2, baseY + 1))
            path.addQuadCurve(to: pt(cx, top), control: pt(cx - half * 0.42, sweep))
            path.addQuadCurve(to: pt(cx + half + 2, baseY + 1), control: pt(cx + half * 0.42, sweep))
        }
        path.closeSubpath()
        return path
    }

    private static func himejiGable(_ context: inout GraphicsContext, _ cx: CGFloat, baseY: CGFloat, half: CGFloat, height: CGFloat, curved: Bool) {
        let shape = himejiGableShape(cx, baseY: baseY, half: half, height: height, curved: curved)
        Kit.solid(&context, shape, Art.color(0x8793A8), light: 0.26, shade: 0.24)
        Art.stroke(&context, shape, Art.color(0xF4F1EA, 0.6), width: 0.8)
        // The white plastered face inside the gable, and its small window.
        let face = himejiGableShape(cx, baseY: baseY, half: half * 0.62, height: height * 0.62, curved: curved)
        himejiPlaster(&context, face, from: cx - half, to: cx + half)
        let windowHeight: CGFloat = height * 0.2
        let window = Art.rect(cx - 1.4, baseY - height * 0.34, 2.8, windowHeight)
        Art.fill(&context, window, Art.color(0x5A5F8A, 0.7))
    }

    // MARK: Towers

    /// The storeys of a tower from the bottom up: each white wall, the shade of the eaves on
    /// it, the roof above it, and a row of small windows.
    private static func himejiStoreys(_ context: inout GraphicsContext, cx: CGFloat, tiers: [(CGFloat, CGFloat, CGFloat, CGFloat, CGFloat, CGFloat)]) {
        var windows = Path()
        let eaveShade: Kit.Stops = [
            (ArtStyle.coolShade.opacity(0.32), 0),
            (ArtStyle.coolShade.opacity(0), 1),
        ]
        for tier in tiers {
            let half: CGFloat = tier.0
            let bottom: CGFloat = tier.1
            let top: CGFloat = tier.2
            let wall = Art.rect(cx - half, top, half * 2, bottom - top)
            himejiPlaster(&context, wall, from: cx - half, to: cx + half)
            model(&context, wall, light: 0.10, shade: 0.16)
            fillVertical(&context, Art.rect(cx - half, top + 2, half * 2, 8), eaveShade, from: top + 2, to: top + 10)
            himejiRoof(&context, cx, eaveY: top, eaveHalf: tier.3, topY: tier.4, topHalf: tier.5)

            let count: Int = max(2, Int(half / 6))
            let gap: CGFloat = half * 2 / CGFloat(count + 1)
            let height: CGFloat = (bottom - top) * 0.36
            for index in 1...count {
                let x: CGFloat = cx - half + gap * CGFloat(index)
                windows.addRect(CGRect(x: x - 1.6, y: top + 8.5, width: 3.2, height: height))
            }
        }
        Art.fill(&context, windows, Art.color(0x5A5F8A, 0.7))
    }

    /// The ridge of a top roof, with the two fish-shaped tiles that curl up at its ends.
    private static func himejiRidge(_ context: inout GraphicsContext, cx: CGFloat, y: CGFloat, half: CGFloat) {
        let tile = Art.color(0x657088)
        Art.fill(&context, Art.rect(cx - half, y - 2.5, half * 2, 4, radius: 1.5), tile)
        Art.fill(&context, Art.rect(cx - half, y - 2.5, half * 2, 1), Art.color(0xF4F1EA, 0.6))
        let curl: CGFloat = max(3, half * 0.34)
        var fish = Path()
        fish.move(to: pt(cx - half + 1, y - 1))
        fish.addQuadCurve(to: pt(cx - half + curl, y - 2 - curl), control: pt(cx - half - 1, y - curl))
        fish.move(to: pt(cx + half - 1, y - 1))
        fish.addQuadCurve(to: pt(cx + half - curl, y - 2 - curl), control: pt(cx + half + 1, y - curl))
        Art.stroke(&context, fish, tile, width: max(1.2, half * 0.1))
    }

    private static func himejiKeep(_ context: inout GraphicsContext, cx: CGFloat) {
        himejiStoneBase(&context, cx: cx, topY: 232, topHalf: 78, bottomY: 288, bottomHalf: 102)
        himejiStoreys(&context, cx: cx, tiers: himejiKeepTiers)
        himejiGable(&context, cx - 42, baseY: 213, half: 13, height: 14, curved: false)
        himejiGable(&context, cx + 42, baseY: 213, half: 13, height: 14, curved: false)
        himejiGable(&context, cx, baseY: 185, half: 24, height: 23, curved: false)
        himejiGable(&context, cx - 22, baseY: 157, half: 11, height: 13, curved: false)
        himejiGable(&context, cx + 22, baseY: 157, half: 11, height: 13, curved: false)
        himejiGable(&context, cx, baseY: 131, half: 14, height: 11, curved: true)
        himejiRidge(&context, cx: cx, y: 86, half: 21)
    }

    private static func himejiSmallTower(_ context: inout GraphicsContext, cx: CGFloat) {
        himejiStoneBase(&context, cx: cx, topY: 240, topHalf: 28, bottomY: 288, bottomHalf: 38)
        himejiStoreys(&context, cx: cx, tiers: himejiSmallTiers)
        himejiGable(&context, cx, baseY: 223, half: 9, height: 10, curved: false)
        himejiRidge(&context, cx: cx, y: 185, half: 10)
    }

    /// The roofed passage that joins the small tower to the keep.
    private static func himejiLink(_ context: inout GraphicsContext) {
        let stone = Art.rect(140, 246, 36, 42)
        Art.fill(&context, stone, Art.color(0xB0A48E))
        Art.fill(&context, stone, ArtStyle.coolShade.opacity(0.14))
        let wall = Art.rect(140, 231, 36, 15)
        himejiPlaster(&context, wall, from: 100, to: 200)
        Art.fill(&context, Art.rect(140, 232, 36, 4), ArtStyle.coolShade.opacity(0.2))
        let roof = Art.polygon([pt(136, 233), pt(142, 224), pt(176, 224), pt(178, 233)])
        Art.fill(&context, roof, Art.color(0x8793A8))
        Art.fill(&context, Art.rect(136, 232, 42, 1.1), Art.color(0xF4F1EA, 0.8))
        var windows = Path()
        windows.addRect(CGRect(x: 149, y: 238, width: 3, height: 5))
        windows.addRect(CGRect(x: 160, y: 238, width: 3, height: 5))
        Art.fill(&context, windows, Art.color(0x5A5F8A, 0.7))
    }

    // MARK: Trees

    /// A pine: a leaning trunk and flat pads of needles, each with a sliver of the light.
    private static func himejiPine(
        _ context: inout GraphicsContext,
        x: CGFloat,
        baseY: CGFloat,
        scale s: CGFloat,
        dark: Color,
        lit: Color,
        trunk: Color
    ) {
        let stem = Kit.placed("M0,0 C-3,-14 4,-26 -2,-40 C-5,-48 2,-54 0,-60", x: x, y: baseY, scale: s)
        Art.stroke(&context, stem, trunk, width: 2.6 * s)
        let pads: [(CGFloat, CGFloat, CGFloat)] = [(-2, -60, 15), (-14, -46, 12), (11, -42, 13), (-9, -30, 10), (10, -27, 9)]
        var needles = Path()
        var glints = Path()
        for pad in pads {
            let px: CGFloat = x + pad.0 * s
            let py: CGFloat = baseY + pad.1 * s
            let r: CGFloat = pad.2 * s
            needles.addEllipse(in: CGRect(x: px - r, y: py - r * 0.42, width: r * 2, height: r * 0.84))
            glints.addEllipse(in: CGRect(x: px - r * 0.8, y: py - r * 0.42, width: r * 1.1, height: r * 0.3))
        }
        Art.fill(&context, needles, dark)
        Art.fill(&context, glints, lit)
    }

    /// The trees at the foot of the castle: a green bank, cherry trees in flower, two pines.
    private static func himejiFootTrees(_ context: inout GraphicsContext) {
        let bank = canopy(from: 62, to: 372, baseY: 294, height: 15, bump: 20, depth: 14, seed: 9)
        Kit.solid(&context, bank, Art.color(0x3E8259), light: 0.24, shade: 0.24)

        let blossoms: [(CGFloat, CGFloat, CGFloat)] = [
            (166, 289, 9), (178, 286, 10), (189, 291, 8),
            (228, 292, 7), (239, 290, 8),
            (292, 290, 9), (304, 287, 10), (315, 291, 8),
        ]
        var pink = Path()
        var pale = Path()
        for blossom in blossoms {
            let r: CGFloat = blossom.2
            pink.addEllipse(in: CGRect(x: blossom.0 - r, y: blossom.1 - r * 0.8, width: r * 2, height: r * 1.6))
            pale.addEllipse(in: CGRect(x: blossom.0 - r * 0.8, y: blossom.1 - r * 0.75, width: r, height: r * 0.7))
        }
        Art.fill(&context, pink, Art.color(0xF2B3C4))
        Art.fill(&context, pale, Art.color(0xFFE6EC, 0.85))
        model(&context, pink, light: 0.1, shade: 0.16)

        let dark = Art.color(0x2C6A52)
        let lit = Art.color(0xCDE8A8, 0.4)
        let trunk = Art.color(0x5A4A4E)
        himejiPine(&context, x: 22, baseY: 300, scale: 0.6, dark: dark, lit: lit, trunk: trunk)
        himejiPine(&context, x: 52, baseY: 303, scale: 0.78, dark: dark, lit: lit, trunk: trunk)
    }

    /// The near plane: a dark pine cropped by the right edge and the bottom corner.
    private static func himejiNearPine(_ context: inout GraphicsContext) {
        let dark = Art.color(0x163A44, 0.96)
        let lit = Art.color(0xFFD9A0, 0.22)
        himejiPine(&context, x: 438, baseY: 424, scale: 2.4, dark: dark, lit: lit, trunk: Art.color(0x2A2F4A))
    }
}
