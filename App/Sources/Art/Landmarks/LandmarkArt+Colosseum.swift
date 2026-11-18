import SwiftUI
import OmramoCore

// The Colosseum as it stands today, by day: our own drawing (no photograph, nothing traced).
// The curved outer wall of pale travertine seen from outside: three storeys of arches and a
// plain fourth storey on the taller left part; on the right the outer wall is broken away, so
// the lower inner ring of arches shows, in indigo shade. Paving, a few tiny people, and
// flat-topped umbrella pines at the right edge. Card background #5A2E22.

extension LandmarkArt {
    /// colosseum: the great oval arena from outside, the tall outer wall lit on the left and
    /// the lower inner ring in shade on the right, under a warm pale sky.
    static func paintColosseum(_ context: inout GraphicsContext) {
        colosseumSky(&context)
        colosseumFarCity(&context)
        colosseumGround(&context)
        colosseumInnerRing(&context)
        colosseumCutEnd(&context)
        colosseumOuterWall(&context)
        colosseumOuterArcades(&context)
        colosseumOuterDetail(&context)
        // Warm light lying on the lit stone, from the upper left.
        Art.glow(&context, 136, 150, 150, Art.color(0xFFE6B8), alpha: 0.16)
        colosseumPeople(&context)
        colosseumPines(&context)
        colosseumFinish(&context)
    }

    // MARK: Geometry

    /// A point on the curved wall: `x` across the picture, `h` units above the ground.
    /// The wall is `half` wide either side of x 216. Level lines near the ground sag a little
    /// at the middle and the high ones bow upward, as a round wall does seen from below.
    static func colosseumPoint(_ x: CGFloat, _ h: CGFloat, half: CGFloat) -> CGPoint {
        let u: CGFloat = (x - 216) / half
        let bow: CGFloat = h * 0.1 - 4
        let y: CGFloat = 288 - h + bow * u * u
        return pt(x, y)
    }

    /// Adds the level line at height `h` from `x0` to `x1` to `path`.
    static func colosseumAddArc(_ path: inout Path, from x0: CGFloat, to x1: CGFloat, h: CGFloat, half: CGFloat, move: Bool) {
        let steps: Int = 12
        for index in 0...steps {
            let f: CGFloat = CGFloat(index) / CGFloat(steps)
            let x: CGFloat = x0 + (x1 - x0) * f
            let point: CGPoint = colosseumPoint(x, h, half: half)
            if index == 0 && move {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
    }

    /// The level line at height `h`, as its own path (for cornices and courses).
    static func colosseumArc(from x0: CGFloat, to x1: CGFloat, h: CGFloat, half: CGFloat) -> Path {
        var path = Path()
        colosseumAddArc(&path, from: x0, to: x1, h: h, half: half, move: true)
        return path
    }

    /// The broken right end of the outer wall, from its top down to the ground: (x, height).
    static func colosseumBreak() -> [(CGFloat, CGFloat)] {
        let steps: [(CGFloat, CGFloat)] = [
            (234, 184), (238, 160), (246, 156), (250, 132), (258, 126),
            (262, 96), (272, 90), (277, 44), (288, 38), (292, 0),
        ]
        return steps
    }

    /// The standing part of the outer wall: four storeys high, broken off on the right.
    static func colosseumOuterShape() -> Path {
        var path = Path()
        path.move(to: colosseumPoint(61, 0, half: 155))
        colosseumAddArc(&path, from: 61, to: 234, h: 184, half: 155, move: false)
        for step in colosseumBreak() {
            path.addLine(to: colosseumPoint(step.0, step.1, half: 155))
        }
        colosseumAddArc(&path, from: 292, to: 61, h: 0, half: 155, move: false)
        path.closeSubpath()
        return path
    }

    /// One row of round-headed openings standing at height `base`. They narrow toward the
    /// sides of the oval. Only openings wholly between `minX` and `maxX` are kept.
    static func colosseumArches(half: CGFloat, base: CGFloat, height: CGFloat, width: CGFloat, minX: CGFloat, maxX: CGFloat) -> Path {
        var path = Path()
        for index in 0..<15 {
            let theta: CGFloat = (CGFloat(index) - 7) * 0.192
            let cx: CGFloat = 216 + half * sin(theta)
            let halfW: CGFloat = width * cos(theta) / 2
            if cx - halfW < minX || cx + halfW > maxX {
                continue
            }
            let foot: CGPoint = colosseumPoint(cx, base, half: half)
            let spring: CGFloat = foot.y - height + halfW
            let lift: CGFloat = spring - halfW * 1.32
            path.move(to: pt(cx - halfW, foot.y))
            path.addLine(to: pt(cx - halfW, spring))
            path.addCurve(to: pt(cx + halfW, spring), control1: pt(cx - halfW, lift), control2: pt(cx + halfW, lift))
            path.addLine(to: pt(cx + halfW, foot.y))
            path.closeSubpath()
        }
        return path
    }

    /// The half-columns that stand between the openings of one storey, from `base` to `top`.
    static func colosseumPiers(half: CGFloat, base: CGFloat, top: CGFloat, width: CGFloat, minX: CGFloat, maxX: CGFloat) -> Path {
        var path = Path()
        for index in 0..<16 {
            let theta: CGFloat = (CGFloat(index) - 7.5) * 0.192
            let cx: CGFloat = 216 + half * sin(theta)
            let halfW: CGFloat = (width * cos(theta) + 0.6) / 2
            if cx - halfW < minX || cx + halfW > maxX {
                continue
            }
            let foot: CGPoint = colosseumPoint(cx, base, half: half)
            let head: CGPoint = colosseumPoint(cx, top, half: half)
            path.addRect(CGRect(x: cx - halfW, y: head.y, width: halfW * 2, height: foot.y - head.y))
        }
        return path
    }

    /// Fills openings with the dark of the inside: a warm indigo, never black.
    static func colosseumHollow(_ context: inout GraphicsContext, _ path: Path, deep: UInt32, low: UInt32) {
        let bounds: CGRect = path.boundingRect
        let stops: [(Color, CGFloat)] = [
            (Art.color(deep), 0),
            (Art.color(low), 1),
        ]
        fillVertical(&context, path, stops, from: bounds.minY, to: bounds.maxY)
    }

    // MARK: Sky and the far plane

    static func colosseumSky(_ context: inout GraphicsContext) {
        let sky: [(Color, CGFloat)] = [
            (Art.color(0xA9D2E4), 0),
            (Art.color(0xDCE9DC), 0.3),
            (Art.color(0xFBE9C6), 0.55),
            (Art.color(0xFFE0B0), 1),
        ]
        backdrop(&context, sky)
        Art.glow(&context, 40, 150, 200, Art.color(0xFFF0CC), alpha: 0.3)
        var clouds = Path()
        clouds.addPath(cloudBand(150, 64, width: 96, height: 15))
        clouds.addPath(cloudBand(292, 44, width: 72, height: 11))
        clouds.addPath(cloudBand(352, 100, width: 60, height: 9))
        Art.fill(&context, clouds, Art.color(0xFFF7E6, 0.7))
    }

    /// Far hills and the low roofs of the city either side of the arena, veiled with the sky.
    static func colosseumFarCity(_ context: inout GraphicsContext) {
        let hills = Art.svg("M-24,290 L-24,270 C30,256 90,268 136,262 L136,290 Z M296,290 L296,266 C350,254 400,262 456,252 L456,290 Z")
        Art.fill(&context, hills, Art.color(0xC4BCB4))
        let roofs = Art.svg("M-24,290 L-24,262 L-6,262 L-6,254 L10,254 L10,266 L30,266 L30,258 L44,258 L44,270 L64,270 L64,290 Z M364,290 L364,268 L380,268 L380,256 L396,256 L396,264 L414,264 L414,250 Q422,239 430,250 L430,262 L456,262 L456,290 Z")
        Art.fill(&context, roofs, Art.color(0xDDB49A))
        let tiles = Art.svg("M-24,262 L-6,262 M-6,254 L10,254 M10,266 L30,266 M30,258 L44,258 M364,268 L380,268 M380,256 L396,256 M396,264 L414,264")
        Art.stroke(&context, tiles, Art.color(0xC8785A, 0.7), width: 1.6, cap: .butt)
        haze(&context, top: 232, bottom: 290, hex: 0xFFE6C0, alpha: 0.45)
    }

    // MARK: Ground

    static func colosseumGround(_ context: inout GraphicsContext) {
        let ground = Art.rect(-24, 282, unitWidth + 48, unitHeight - 282 + 24)
        let paving: [(Color, CGFloat)] = [
            (Art.color(0xF6E4C4), 0),
            (Art.color(0xDDB48C), 0.3),
            (Art.color(0x8C5238), 0.75),
            (Art.color(0x5A2E22), 1),
        ]
        fillVertical(&context, ground, paving, from: 282, to: unitHeight)
        horizon(&context, y: 282, rise: 46, hex: 0xFFE2B0, alpha: 0.3)

        // The joints of the paving: lines that run toward the arena, and a few across.
        var joints = Path()
        for index in 0..<11 {
            let k: CGFloat = CGFloat(index) - 5
            joints.move(to: pt(216 + k * 38, 292))
            joints.addLine(to: pt(216 + k * 66, 410))
        }
        let across = Art.svg("M-24,304 Q216,312 456,304 M-24,322 Q216,334 456,322 M-24,348 Q216,364 456,348")
        joints.addPath(across)
        Art.stroke(&context, joints, Art.color(0xA87A58, 0.22), width: 1)

        // The arena's own shade on the paving, falling to the lower right.
        let cast = Art.polygon([pt(250, 289), pt(366, 286), pt(424, 298), pt(300, 304)])
        Art.fill(&context, cast, ArtStyle.coolShade.opacity(0.14))
        ArtStyle.contactShadow(&context, 222, 289, 170, 7, alpha: 0.26)
    }

    // MARK: The inner ring (right, in shade)

    /// The lower inner wall that shows where the outer wall is gone: two storeys of arches
    /// and a broken third, turned away from the light.
    static func colosseumInnerRing(_ context: inout GraphicsContext) {
        var wall = Path()
        wall.move(to: colosseumPoint(250, 0, half: 143))
        colosseumAddArc(&wall, from: 250, to: 300, h: 118, half: 143, move: false)
        colosseumAddArc(&wall, from: 304, to: 338, h: 106, half: 143, move: false)
        colosseumAddArc(&wall, from: 342, to: 359, h: 92, half: 143, move: false)
        colosseumAddArc(&wall, from: 359, to: 250, h: 0, half: 143, move: false)
        wall.closeSubpath()
        let stone: [(Color, CGFloat)] = [
            (Art.color(0xE6C8A2), 0),
            (Art.color(0xCDAA92), 0.5),
            (Art.color(0xAE8E92), 1),
        ]
        fillHorizontal(&context, wall, stone, from: 250, to: 359)
        let turn: [(Color, CGFloat)] = [
            (ArtStyle.coolShade.opacity(0.08), 0),
            (ArtStyle.coolShade.opacity(0.3), 1),
        ]
        fillHorizontal(&context, wall, turn, from: 262, to: 359)

        var openings = Path()
        openings.addPath(colosseumArches(half: 143, base: 3, height: 30, width: 15, minX: 250, maxX: 360))
        openings.addPath(colosseumArches(half: 143, base: 48, height: 30, width: 15, minX: 250, maxX: 360))
        openings.addPath(colosseumArches(half: 143, base: 93, height: 20, width: 13, minX: 250, maxX: 302))
        colosseumHollow(&context, openings, deep: 0x54406A, low: 0x86666E)

        var ledges = Path()
        colosseumAddArc(&ledges, from: 250, to: 359, h: 44, half: 143, move: true)
        colosseumAddArc(&ledges, from: 250, to: 359, h: 89, half: 143, move: true)
        Art.stroke(&context, ledges, Art.color(0xF4DCB8, 0.6), width: 1.6, cap: .butt)
        var under = Path()
        colosseumAddArc(&under, from: 250, to: 359, h: 41.6, half: 143, move: true)
        colosseumAddArc(&under, from: 250, to: 359, h: 86.6, half: 143, move: true)
        Art.stroke(&context, under, ArtStyle.coolShade.opacity(0.22), width: 1.2, cap: .butt)

        // The tall outer wall throws its shade onto the ring beside it.
        let thrown: [(Color, CGFloat)] = [
            (ArtStyle.coolShade.opacity(0.3), 0),
            (ArtStyle.coolShade.opacity(0), 1),
        ]
        Art.clipped(&context, to: wall) { g in
            fillHorizontal(&g, Art.rect(250, 150, 60, 150), thrown, from: 266, to: 310)
        }
    }

    /// The cut end of the outer wall where it breaks off: brick, stepping down to the ground.
    static func colosseumCutEnd(_ context: inout GraphicsContext) {
        let steps: [(CGFloat, CGFloat)] = colosseumBreak()
        var path = Path()
        path.move(to: colosseumPoint(232, 184, half: 155))
        for step in steps {
            path.addLine(to: colosseumPoint(step.0, step.1, half: 155))
        }
        for step in steps.reversed() {
            path.addLine(to: colosseumPoint(step.0 + 9, step.1, half: 155))
        }
        path.closeSubpath()
        let brick: [(Color, CGFloat)] = [
            (Art.color(0xDDA47C), 0),
            (Art.color(0xB67C6A), 1),
        ]
        fillVertical(&context, path, brick, from: 104, to: 288)
        Art.fill(&context, path, ArtStyle.coolShade.opacity(0.12))
    }

    // MARK: The outer wall (left, in the light)

    static func colosseumOuterWall(_ context: inout GraphicsContext) {
        let wall: Path = colosseumOuterShape()
        let stone: [(Color, CGFloat)] = [
            (Art.color(0xFFF4D8), 0),
            (Art.color(0xF8E2BA), 0.5),
            (Art.color(0xE4C49E), 1),
        ]
        fillHorizontal(&context, wall, stone, from: 61, to: 292)
        model(&context, wall, light: 0.2, shade: 0.14)

        // Courses of stone, weather stains and the small holes left in the travertine.
        var courses = Path()
        let heights: [CGFloat] = [22, 66, 110, 148, 164]
        for h in heights {
            colosseumAddArc(&courses, from: 61, to: 292, h: h, half: 155, move: true)
        }
        let stains = Art.svg("M92,128 C94,150 90,170 93,196 M134,112 C132,130 137,150 134,168 M176,106 C178,122 174,140 177,152 M214,106 C212,120 216,134 213,150 M118,206 C120,220 116,232 119,246")
        let pocked = CGRect(x: 61, y: 104, width: 232, height: 184)
        Art.clipped(&context, to: wall) { g in
            Art.stroke(&g, courses, Art.color(0xB89070, 0.2), width: 0.8, cap: .butt)
            Art.stroke(&g, stains, Art.color(0xA8846A, 0.16), width: 3)
            Art.stipple(&g, in: pocked, count: 150, seed: 71, color: Art.color(0x9A7458), alpha: 0.3, size: 0.4...0.9)
        }
    }

    /// The three rows of arches of the outer wall, and the half-columns between them.
    static func colosseumOuterArcades(_ context: inout GraphicsContext) {
        let limits: [CGFloat] = [272, 270, 248]
        var openings = Path()
        var columns = Path()
        var base: CGFloat = 0
        for limit in limits {
            openings.addPath(colosseumArches(half: 155, base: base + 4, height: 31, width: 15, minX: 61, maxX: limit))
            columns.addPath(colosseumPiers(half: 155, base: base + 2, top: base + 41, width: 3.2, minX: 61, maxX: limit))
            base += 44
        }
        columns.addPath(colosseumPiers(half: 155, base: 134, top: 176, width: 3.2, minX: 61, maxX: 233))
        Art.fill(&context, columns, Art.color(0xFFFAEA, 0.55))
        // Each half-column shades the wall on its right.
        var shadows = context
        shadows.translateBy(x: 1.6, y: 0)
        Art.fill(&shadows, columns, ArtStyle.coolShade.opacity(0.1))
        Art.fill(&context, columns, Art.color(0xFFFAEA, 0.35))

        colosseumHollow(&context, openings, deep: 0x3E2A4E, low: 0x74505C)
        // The right-hand jamb of each arch faces the sun: the rest of the opening is deeper.
        var jambs = context
        jambs.clip(to: openings)
        jambs.translateBy(x: -2.2, y: 0)
        Art.fill(&jambs, openings, Art.color(0x3E2A4E, 0.45))
    }

    /// The cornices between the storeys, and the plain top storey: small square windows,
    /// a row of brackets under the rim.
    static func colosseumOuterDetail(_ context: inout GraphicsContext) {
        let bands: [(CGFloat, CGFloat)] = [(44, 277), (88, 272), (132, 250)]
        var lit = Path()
        var under = Path()
        for band in bands {
            colosseumAddArc(&lit, from: 61, to: band.1, h: band.0, half: 155, move: true)
            colosseumAddArc(&under, from: 61, to: band.1, h: band.0 - 2.6, half: 155, move: true)
        }
        Art.stroke(&context, under, ArtStyle.coolShade.opacity(0.24), width: 1.4, cap: .butt)
        Art.stroke(&context, lit, Art.color(0xFFFBEC, 0.9), width: 2.4, cap: .butt)
        let rim: Path = colosseumArc(from: 61.6, to: 233, h: 183, half: 155)
        Art.stroke(&context, rim, Art.color(0xFFFBEC, 0.9), width: 1.8, cap: .butt)
        let brackets: Path = colosseumArc(from: 63, to: 232, h: 177, half: 155)
        Art.stroke(&context, brackets, Art.color(0xA8846A, 0.55), width: 2.4, cap: .butt, dash: [1.2, 3.4])

        var windows = Path()
        for index in 0..<15 where index % 2 == 0 {
            let theta: CGFloat = (CGFloat(index) - 7) * 0.192
            let cx: CGFloat = 216 + 155 * sin(theta)
            let w: CGFloat = 5.5 * cos(theta)
            if cx + w > 232 {
                continue
            }
            let foot: CGPoint = colosseumPoint(cx, 152, half: 155)
            windows.addRect(CGRect(x: cx - w / 2, y: foot.y - 7, width: w, height: 7))
        }
        Art.fill(&context, windows, Art.color(0x5A4466, 0.85))

        // The round wall turns away from the light toward the break.
        let wall: Path = colosseumOuterShape()
        let turn: [(Color, CGFloat)] = [
            (ArtStyle.coolShade.opacity(0), 0),
            (ArtStyle.coolShade.opacity(0.16), 1),
        ]
        fillHorizontal(&context, wall, turn, from: 190, to: 292)
    }

    // MARK: People and pines

    /// A few tiny visitors on the paving, for scale.
    static func colosseumPeople(_ context: inout GraphicsContext) {
        let folk: [(CGFloat, CGFloat, CGFloat, UInt32)] = [
            (96, 298, 1, 0xB8503C), (104, 299, 0.9, 0x3E6E8A), (172, 305, 1.1, 0x4E7A5A),
            (240, 300, 1, 0xC98A3A), (248, 301, 0.8, 0x8A4A6A), (324, 307, 1.1, 0x3E5E8A),
        ]
        for person in folk {
            let x: CGFloat = person.0
            let y: CGFloat = person.1
            let s: CGFloat = person.2
            let shoulder: CGFloat = y - 5.6 * s
            ArtStyle.contactShadow(&context, x + 2 * s, y + 0.3, 4 * s, 1.1 * s, alpha: 0.3)
            let body = Art.polygon([pt(x - 1.3 * s, shoulder), pt(x + 1.3 * s, shoulder), pt(x + 1.7 * s, y), pt(x - 1.7 * s, y)])
            Art.fill(&context, body, Art.color(person.3))
            Art.fill(&context, Art.rect(x - 1.3 * s, shoulder, 0.9 * s, 5.6 * s), Art.color(0xFFE6B8, 0.4))
            Art.fill(&context, Art.circle(x, y - 6.9 * s, 1.4 * s), Art.color(0x6A4638))
        }
    }

    /// One umbrella pine: a bare leaning trunk, two boughs, and a flat-topped crown built
    /// from overlapping clumps, lit on its upper left.
    static func colosseumPine(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, height: CGFloat, spread: CGFloat, bark: UInt32, needles: UInt32, lit: UInt32) {
        let top: CGFloat = baseY - height
        let girth: CGFloat = spread * 0.1
        let cx: CGFloat = x + spread * 0.12
        let midY: CGFloat = baseY - height * 0.5
        var trunk = Path()
        trunk.move(to: pt(x - girth, baseY))
        trunk.addQuadCurve(to: pt(cx - girth * 0.5, top), control: pt(x - girth * 0.4, midY))
        trunk.addLine(to: pt(cx + girth * 0.5, top))
        trunk.addQuadCurve(to: pt(x + girth, baseY), control: pt(x + girth * 1.3, midY))
        trunk.closeSubpath()
        Art.fill(&context, trunk, Art.color(bark))
        model(&context, trunk, light: 0.2, shade: 0.2)

        var boughs = Path()
        boughs.move(to: pt(cx, top + spread * 0.5))
        boughs.addQuadCurve(to: pt(cx - spread * 0.55, top), control: pt(cx - spread * 0.2, top + spread * 0.14))
        boughs.move(to: pt(cx, top + spread * 0.36))
        boughs.addQuadCurve(to: pt(cx + spread * 0.55, top), control: pt(cx + spread * 0.24, top + spread * 0.1))
        Art.stroke(&context, boughs, Art.color(bark), width: girth * 0.8)

        var crown: Path = cloudBand(cx - spread, top + spread * 0.08, width: spread * 2, height: spread * 0.46)
        crown.addPath(cloudBand(cx - spread * 0.66, top - spread * 0.14, width: spread * 1.2, height: spread * 0.34))
        crown.addPath(cloudBand(cx - spread * 0.1, top - spread * 0.08, width: spread * 0.9, height: spread * 0.3))
        Art.fill(&context, crown, Art.color(needles))
        model(&context, crown, light: 0.22, shade: 0.24)
        var clumps: Path = cloudBand(cx - spread * 0.84, top - spread * 0.02, width: spread * 0.8, height: spread * 0.2)
        clumps.addPath(cloudBand(cx - spread * 0.46, top - spread * 0.2, width: spread * 0.7, height: spread * 0.18))
        clumps.addPath(cloudBand(cx + spread * 0.1, top - spread * 0.1, width: spread * 0.56, height: spread * 0.14))
        Art.fill(&context, clumps, Art.color(lit, 0.75))
    }

    /// A small pine in the middle distance on the left; two tall dark ones at the right edge
    /// as the near plane, beside the arena and never over it.
    static func colosseumPines(_ context: inout GraphicsContext) {
        ArtStyle.contactShadow(&context, 34, 292, 14, 2.4, alpha: 0.24)
        colosseumPine(&context, x: 30, baseY: 292, height: 58, spread: 20, bark: 0x8A5A48, needles: 0x587A52, lit: 0x9AB070)
        colosseumPine(&context, x: 440, baseY: 372, height: 150, spread: 36, bark: 0x4E2E34, needles: 0x2F4E40, lit: 0x6A8A52)
        colosseumPine(&context, x: 410, baseY: 392, height: 252, spread: 44, bark: 0x4A2A32, needles: 0x2A463C, lit: 0x74924E)
    }

    // MARK: Finish

    static func colosseumFinish(_ context: inout GraphicsContext) {
        bottomFade(&context, 0x5A2E22, from: 300, alpha: 0.9)
        tooth(&context, seed: 727, light: 0.05, dark: 0.04)
        finish(&context, wash: 0.10, vignette: 0.10)
    }
}
