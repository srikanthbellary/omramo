import SwiftUI
import OmramoCore

// The Great Wall of China near Badaling, by day: a wall of grey-tan stone and brick with a
// toothed parapet climbs a green hill to a square watchtower in the middle of the picture,
// drops into a saddle, climbs to a second tower and winds away, small and pale, along the far
// ridges. Our own drawing (no photograph, nothing traced). Card background #2E4A3A.

extension LandmarkArt {
    /// great-wall-of-china: the nearest watchtower and its stretch of wall, the wall winding away.
    static func paintGreatWall(_ context: inout GraphicsContext) {
        greatWallSky(&context)
        greatWallFarRidge(&context)
        greatWallMiddleHills(&context)
        greatWallNearHill(&context)
        greatWallStretch(&context, greatWallNearLeft, merlons: true)
        greatWallStretch(&context, greatWallNearRight, merlons: true)
        ArtStyle.contactShadow(&context, 226, 238, 58, 5, alpha: 0.28)
        greatWallTower(&context, x: 212, baseY: 236, scale: 1.25)
        greatWallNearLeaves(&context)
        bottomFade(&context, 0x2E4A3A, from: 300, alpha: 0.9)
        tooth(&context, seed: 733, light: 0.06, dark: 0.05)
        finish(&context, wash: 0.10, vignette: 0.10)
    }

    // A stretch of wall is a list of (x, top of the wall, height of the wall), x increasing.

    /// The near wall climbing from the left edge to the main tower.
    private static let greatWallNearLeft: [(CGFloat, CGFloat, CGFloat)] = [
        (-24, 258, 42), (40, 250, 40), (96, 226, 38), (140, 212, 37), (176, 198, 36),
    ]
    /// The wall dropping from the main tower into the saddle on the right.
    private static let greatWallNearRight: [(CGFloat, CGFloat, CGFloat)] = [
        (258, 204, 32), (296, 226, 27), (322, 236, 24),
    ]
    /// The wall climbing out of the saddle to the second tower.
    private static let greatWallMiddleUp: [(CGFloat, CGFloat, CGFloat)] = [
        (316, 240, 21), (332, 212, 19), (346, 186, 17),
    ]
    /// The wall going on beyond the second tower.
    private static let greatWallMiddleOn: [(CGFloat, CGFloat, CGFloat)] = [
        (378, 188, 15), (412, 204, 13), (456, 200, 12),
    ]
    /// The far wall along the far ridge.
    private static let greatWallFar: [(CGFloat, CGFloat, CGFloat)] = [
        (-24, 176, 7), (40, 162, 7), (96, 150, 6.5), (150, 168, 6), (176, 176, 6),
        (270, 170, 6), (330, 186, 6), (400, 174, 5.5), (456, 182, 5.5),
    ]

    // MARK: Sky and far plane

    private static func greatWallSky(_ context: inout GraphicsContext) {
        let sky: Kit.Stops = [
            (Art.color(0x62A6DE), 0),
            (Art.color(0x9CCBEC), 0.3),
            (Art.color(0xDDECE4), 0.44),
            (Art.color(0xFFE8BE), 0.52),
            (Art.color(0xFFE8BE), 1),
        ]
        backdrop(&context, sky)
        horizon(&context, y: 196, rise: 70, hex: 0xFFE3B0, alpha: 0.4)
        Kit.cloud(&context, 338, 78, scale: 0.6, color: Art.color(0xFFFFFF, 0.9))
        Kit.cloud(&context, 122, 98, scale: 0.4, color: Art.color(0xFFFFFF, 0.8))
        Kit.birds(&context, 286, 112, scale: 0.5, color: Art.color(0x4A6488, 0.5))

        // The farthest mountains, almost the colour of the sky.
        let farthest = Kit.peaks(width: 480, y: 164, amp: 36, seed: 7, bottom: 260, sharp: 0.4, x0: -24)
        Art.fill(&context, farthest, Art.color(0xA9C4DC, 0.75))
        haze(&context, top: 110, bottom: 190, hex: 0xFFE8BE, alpha: 0.3)
    }

    /// The far ridge with the wall running along it, small and pale, and a tiny tower.
    private static func greatWallFarRidge(_ context: inout GraphicsContext) {
        let crest: [(CGFloat, CGFloat)] = [
            (-24, 181), (40, 167), (96, 154.5), (150, 172), (176, 180),
            (270, 174), (330, 190), (400, 177.5), (456, 185.5),
        ]
        let ridge = greatWallHill(crest, bottom: 330)
        let green: Kit.Stops = [(Art.color(0x8FBF9C), 0), (Art.color(0x7DB08A), 1)]
        fillVertical(&context, ridge, green, from: 150, to: 260)
        model(&context, ridge, light: 0.16, shade: 0.12)
        let bounds = CGRect(x: -24, y: 160, width: 480, height: 90)
        let dark = Art.color(0x5E9A78, 0.35)
        let lit = Art.color(0xE4F2C0, 0.2)
        greatWallBushes(&context, on: ridge, in: bounds, count: 70, seed: 3, size: 0.6, dark: dark, lit: lit)

        let wall = greatWallRibbon(greatWallFar)
        Art.fill(&context, wall, Art.color(0xDCD0B8))
        Art.clipped(&context, to: wall) { g in
            Art.stroke(&g, greatWallLine(greatWallFar, at: 1), ArtStyle.coolShade.opacity(0.22), width: 4, cap: .butt)
        }
        Art.stroke(&context, greatWallLine(greatWallFar, at: 0), Art.color(0xF6EDD8, 0.8), width: 0.8)
        greatWallTower(&context, x: 100, baseY: 158, scale: 0.2)
        greatWallTower(&context, x: 398, baseY: 181, scale: 0.17)
        // The veil of air that sets the far ridge back.
        haze(&context, top: 124, bottom: 236, hex: 0xFFE8BE, alpha: 0.3)
    }

    // MARK: Middle hills

    /// The hills behind the near one: a green shoulder on the left, and on the right the hill
    /// the wall climbs to its second tower.
    private static func greatWallMiddleHills(_ context: inout GraphicsContext) {
        let green: Kit.Stops = [(Art.color(0x79B274), 0), (Art.color(0x4F9060), 1)]
        let dark = Art.color(0x3F8055, 0.4)
        let lit = Art.color(0xE4F2B0, 0.22)

        let leftCrest: [(CGFloat, CGFloat)] = [
            (-24, 222), (20, 216), (60, 214), (100, 219), (140, 229), (200, 244), (260, 262),
        ]
        let left = greatWallHill(leftCrest, bottom: 330)
        Kit.solid(&context, left, stops: green, light: 0.2, shade: 0.16)
        greatWallBushes(&context, on: left, in: CGRect(x: -24, y: 216, width: 280, height: 60), count: 36, seed: 15, size: 0.8, dark: dark, lit: lit)

        let rightCrest: [(CGFloat, CGFloat)] = [
            (236, 300), (290, 266), (316, 258), (332, 228), (346, 200),
            (378, 200), (412, 214), (456, 209),
        ]
        let right = greatWallHill(rightCrest, bottom: 330)
        Kit.solid(&context, right, stops: green, light: 0.2, shade: 0.2)
        greatWallBushes(&context, on: right, in: CGRect(x: 300, y: 204, width: 160, height: 90), count: 40, seed: 27, size: 0.8, dark: dark, lit: lit)

        greatWallStretch(&context, greatWallMiddleUp, merlons: true)
        greatWallStretch(&context, greatWallMiddleOn, merlons: true)
        ArtStyle.contactShadow(&context, 366, 205, 24, 2.4, alpha: 0.24)
        greatWallTower(&context, x: 360, baseY: 204, scale: 0.5)
        haze(&context, top: 150, bottom: 262, hex: 0xFFE8BE, alpha: 0.13)
    }

    // MARK: The near hill

    private static func greatWallNearHill(_ context: inout GraphicsContext) {
        let crest: [(CGFloat, CGFloat)] = [
            (-24, 297), (40, 287), (96, 261), (140, 246), (176, 232), (258, 233),
            (296, 250), (322, 257), (372, 272), (456, 290),
        ]
        let hill = greatWallHill(crest, bottom: 430)
        let green: Kit.Stops = [
            (Art.color(0x6DB060), 0),
            (Art.color(0x3F8550), 0.3),
            (Art.color(0x2F6244), 0.6),
            (Art.color(0x2E4A3A), 1),
        ]
        fillVertical(&context, hill, green, from: 232, to: unitHeight)
        model(&context, hill, light: 0.2, shade: 0.18)
        let dark = Art.color(0x2A6E44, 0.4)
        let lit = Art.color(0xE4F2A8, 0.22)
        greatWallBushes(&context, on: hill, in: CGRect(x: -24, y: 236, width: 480, height: 70), count: 46, seed: 51, size: 1, dark: dark, lit: lit)
    }

    // MARK: Hills and bushes

    /// A hill under a crest of straight runs (the wall hides the corners), filled to `bottom`.
    private static func greatWallHill(_ crest: [(CGFloat, CGFloat)], bottom: CGFloat) -> Path {
        var path = Path()
        guard let first = crest.first, let last = crest.last else { return path }
        path.move(to: pt(first.0, bottom))
        for point in crest {
            path.addLine(to: pt(point.0, point.1))
        }
        path.addLine(to: pt(last.0, bottom))
        path.closeSubpath()
        return path
    }

    /// Round clumps of trees and scrub scattered over a hill, each lit on its upper left.
    private static func greatWallBushes(
        _ context: inout GraphicsContext,
        on hill: Path,
        in rect: CGRect,
        count: Int,
        seed: UInt32,
        size: CGFloat,
        dark: Color,
        lit: Color
    ) {
        var random = ArtRandom(seed)
        var clumps = Path()
        var tops = Path()
        for _ in 0..<max(0, count) {
            let x: CGFloat = rect.minX + rect.width * Kit.rnd(&random)
            let y: CGFloat = rect.minY + rect.height * Kit.rnd(&random)
            let r: CGFloat = (4 + 7 * Kit.rnd(&random)) * size
            clumps.addEllipse(in: CGRect(x: x - r, y: y - r * 0.7, width: r * 2, height: r * 1.4))
            tops.addEllipse(in: CGRect(x: x - r * 0.8, y: y - r * 0.7, width: r, height: r * 0.6))
        }
        Art.clipped(&context, to: hill) { g in
            Art.fill(&g, clumps, dark)
            Art.fill(&g, tops, lit)
        }
    }

    // MARK: The wall

    /// The line through a stretch at `fraction` of the wall's height below its top.
    private static func greatWallLine(_ points: [(CGFloat, CGFloat, CGFloat)], at fraction: CGFloat) -> Path {
        var path = Path()
        guard let first = points.first else { return path }
        path.move(to: pt(first.0, first.1 + first.2 * fraction))
        for point in points.dropFirst() {
            path.addLine(to: pt(point.0, point.1 + point.2 * fraction))
        }
        return path
    }

    /// The face of a stretch of wall, from its top line down to its foot.
    private static func greatWallRibbon(_ points: [(CGFloat, CGFloat, CGFloat)]) -> Path {
        var path = Path()
        guard let first = points.first else { return path }
        path.move(to: pt(first.0, first.1))
        for point in points.dropFirst() {
            path.addLine(to: pt(point.0, point.1))
        }
        for point in points.reversed() {
            path.addLine(to: pt(point.0, point.1 + point.2))
        }
        path.closeSubpath()
        return path
    }

    /// The teeth of the parapet standing along the top of a stretch.
    private static func greatWallMerlons(_ points: [(CGFloat, CGFloat, CGFloat)]) -> Path {
        var path = Path()
        guard points.count > 1 else { return path }
        for index in 1..<points.count {
            let a = points[index - 1]
            let b = points[index]
            let run: CGFloat = b.0 - a.0
            if run <= 0 { continue }
            let slope: CGFloat = (b.1 - a.1) / run
            var x: CGFloat = a.0
            while x < b.0 {
                let t: CGFloat = (x - a.0) / run
                let h: CGFloat = Kit.mix(a.2, b.2, t)
                let w: CGFloat = max(1.2, h * 0.2)
                let rise: CGFloat = max(1.2, h * 0.2)
                let y0: CGFloat = a.1 + slope * (x - a.0)
                let y1: CGFloat = y0 + slope * w
                path.move(to: pt(x, y0 + 0.5))
                path.addLine(to: pt(x, y0 - rise))
                path.addLine(to: pt(x + w, y1 - rise))
                path.addLine(to: pt(x + w, y1 + 0.5))
                path.closeSubpath()
                x += w + max(1, h * 0.15)
            }
        }
        return path
    }

    /// One stretch of wall: stone face, parapet teeth, courses of brick, shade at its foot.
    private static func greatWallStretch(_ context: inout GraphicsContext, _ points: [(CGFloat, CGFloat, CGFloat)], merlons: Bool) {
        let body = greatWallRibbon(points)
        var whole = body
        if merlons {
            whole.addPath(greatWallMerlons(points))
        }
        let stone: Kit.Stops = [(Art.color(0xE0D1B0), 0), (Art.color(0xB9A98C), 1)]
        Kit.solid(&context, whole, stops: stone, light: 0.2, shade: 0.24)

        var courses = Path()
        let fractions: [CGFloat] = [0.42, 0.56, 0.7, 0.84]
        for fraction in fractions {
            courses.addPath(greatWallLine(points, at: fraction))
        }
        Art.clipped(&context, to: body) { g in
            Art.stroke(&g, greatWallLine(points, at: 1), ArtStyle.coolShade.opacity(0.2), width: 9, cap: .butt)
            Art.stroke(&g, courses, Art.color(0x7E6F5A, 0.3), width: 0.6, cap: .butt)
            // The line of the walkway under the parapet, and the light on the top edge.
            Art.stroke(&g, greatWallLine(points, at: 0.27), Art.color(0x6E6052, 0.5), width: 1, cap: .butt)
            Art.stroke(&g, greatWallLine(points, at: 0), Art.color(0xFFF3D6, 0.7), width: 1.6, cap: .butt)
        }
    }

    // MARK: Watchtowers

    /// A round-headed opening standing on `baseY`.
    private static func greatWallArch(_ x: CGFloat, _ baseY: CGFloat, width: CGFloat, height: CGFloat) -> Path {
        let half: CGFloat = width / 2
        let spring: CGFloat = baseY - height + half
        let top: CGFloat = baseY - height
        let k: CGFloat = half * 0.55
        var path = Path()
        path.move(to: pt(x - half, baseY))
        path.addLine(to: pt(x - half, spring))
        path.addCurve(to: pt(x, top), control1: pt(x - half, spring - k), control2: pt(x - k, top))
        path.addCurve(to: pt(x + half, spring), control1: pt(x + k, top), control2: pt(x + half, spring - k))
        path.addLine(to: pt(x + half, baseY))
        path.closeSubpath()
        return path
    }

    /// A square watchtower standing on (`x`, `baseY`). At scale 1 it is about 70 wide and
    /// 97 tall: a lit front, a shaded side to the right, arched windows and a toothed top.
    private static func greatWallTower(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, scale: CGFloat) {
        Art.group(&context, x: x, y: baseY, scale: scale) { g in
            greatWallTowerBody(&g)
            greatWallTowerTop(&g)
        }
    }

    private static func greatWallTowerBody(_ context: inout GraphicsContext) {
        let side = Art.polygon([pt(23, 0), pt(22, -84), pt(38, -80), pt(39, -2)])
        Art.fill(&context, side, Art.color(0xA89A86))
        Art.fill(&context, side, ArtStyle.coolShade.opacity(0.26))
        let front = Art.polygon([pt(-32, 0), pt(-30, -84), pt(22, -84), pt(23, 0)])
        let stone: Kit.Stops = [(Art.color(0xE4D5B4), 0), (Art.color(0xBEAD8E), 1)]
        Kit.solid(&context, front, stops: stone, light: 0.24, shade: 0.2)

        // Courses of brick, the joints staggered row by row.
        var courses = Path()
        var y: CGFloat = -6
        var row: Int = 0
        while y > -84 {
            courses.move(to: pt(-34, y))
            courses.addLine(to: pt(40, y))
            let offset: CGFloat = row % 2 == 0 ? 0 : 6
            var jx: CGFloat = -34 + offset
            while jx < 40 {
                courses.move(to: pt(jx, y))
                courses.addLine(to: pt(jx, y + 6))
                jx += 12
            }
            y -= 6
            row += 1
        }
        Art.clipped(&context, to: front) { g in
            Art.stroke(&g, courses, Art.color(0x7E6F5A, 0.3), width: 0.6, cap: .butt)
            // The big stones of the foot, and the shade under the cornice.
            Art.fill(&g, Art.rect(-34, -10, 60, 10), Art.color(0x8E7F66, 0.25))
            Art.fill(&g, Art.rect(-34, -84, 60, 3.5), ArtStyle.coolShade.opacity(0.2))
        }
        Art.clipped(&context, to: side) { g in
            Art.stroke(&g, courses, Art.color(0x4E4660, 0.28), width: 0.6, cap: .butt)
        }

        // The string course under the windows.
        Art.fill(&context, Art.rect(-31, -62, 53.5, 2.6), Art.color(0xEFE2C4))
        Art.fill(&context, Art.rect(-31, -59.4, 53.5, 1.6), ArtStyle.coolShade.opacity(0.16))

        var windows = Path()
        let places: [CGFloat] = [-19, -4, 11]
        for place in places {
            windows.addPath(greatWallArch(place, -65, width: 7.5, height: 14))
        }
        windows.addPath(greatWallArch(30.5, -63, width: 4.5, height: 12))
        Art.fill(&context, windows, Art.color(0x3F3A5C, 0.88))
        // A sliver of light on the right jamb of each front window.
        var jambs = Path()
        for place in places {
            jambs.move(to: pt(place + 3, -66))
            jambs.addLine(to: pt(place + 3, -73))
        }
        Art.stroke(&context, jambs, Art.color(0xE4D5B4, 0.5), width: 0.9, cap: .butt)

        let edge = Art.line(-31.5, -1, -29.6, -84)
        Art.stroke(&context, edge, ArtStyle.warmLight.opacity(0.7), width: 1, cap: .butt)
    }

    private static func greatWallTowerTop(_ context: inout GraphicsContext) {
        // The side of the cornice and its two teeth, in shade.
        var sideParts = Path()
        sideParts.addPath(Art.polygon([pt(23, -88.5), pt(39, -84.5), pt(39, -80), pt(23, -84)]))
        sideParts.addPath(Art.polygon([pt(25, -88), pt(25, -96.5), pt(30, -95.3), pt(30, -86.8)]))
        sideParts.addPath(Art.polygon([pt(33.5, -85.9), pt(33.5, -94.4), pt(38.5, -93.2), pt(38.5, -84.7)]))
        Art.fill(&context, sideParts, Art.color(0xA89A86))
        Art.fill(&context, sideParts, ArtStyle.coolShade.opacity(0.3))

        // The front of the cornice and its five teeth, in the light.
        var frontParts = Path()
        frontParts.addRect(CGRect(x: -32, y: -88.5, width: 55, height: 4.5))
        for index in 0..<5 {
            let mx: CGFloat = -31 + CGFloat(index) * 11.5
            frontParts.addRect(CGRect(x: mx, y: -97.5, width: 7, height: 9.5))
        }
        Kit.solid(&context, frontParts, Art.color(0xE6D8B8), light: 0.26, shade: 0.2)
        Art.fill(&context, Art.rect(-32, -88.5, 55, 1), Art.color(0xFFF3D6, 0.7))
    }

    // MARK: Near plane

    /// The near plane: dark scrub and leaves in the bottom-right corner.
    private static func greatWallNearLeaves(_ context: inout GraphicsContext) {
        let scrub = canopy(from: 322, to: 470, baseY: 324, height: 28, bump: 30, depth: 110, seed: 77)
        Kit.solid(&context, scrub, Art.color(0x1F4A36), light: 0.14, shade: 0.3)
        var random = ArtRandom(91)
        var glints = Path()
        for _ in 0..<14 {
            let lx: CGFloat = 334 + 110 * Kit.rnd(&random)
            let ly: CGFloat = 312 + 30 * Kit.rnd(&random)
            let angle: CGFloat = Kit.deg(200 + 50 * Kit.rnd(&random))
            glints.addPath(leaf(lx, ly, length: 12, width: 3, angle: angle))
        }
        Art.fill(&context, glints, Art.color(0xCFE8A0, 0.28))
    }
}
