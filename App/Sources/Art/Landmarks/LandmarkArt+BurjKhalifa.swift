import SwiftUI
import OmramoCore

// The Burj Khalifa in the late afternoon: our own drawing (no photograph, nothing traced).
// A very tall, thin tower of bundled tubes that step back one after another, in a spiral, so
// that the outline narrows in uneven steps to a fine spire. Silver-blue glass, a warm strip of
// light down the left side and cool shade on the right. Round its foot stand ordinary
// skyscrapers that reach only about a quarter of its height; behind them a strip of the blue
// Gulf and a hazy desert horizon; thin clouds drift below the tip. No logos, no text.
// Card background #1B3558.

extension LandmarkArt {
    /// The tower's centre line: the middle of the picture.
    private static let burjX: CGFloat = 216
    /// Where the tower meets the ground.
    private static let burjBase: CGFloat = 332

    /// The bundled tubes, left to right, then the two parts of the core: (left, right, top).
    /// The tops fall away unevenly on the two sides, as the real setbacks wind round the tower.
    private static func burjTubes() -> [(CGFloat, CGFloat, CGFloat)] {
        let tubes: [(CGFloat, CGFloat, CGFloat)] = [
            (189, 194, 262), (194, 199, 214), (199, 204, 168), (204, 208, 126), (208, 211, 96), (211, 216, 74),
            (216, 221.5, 84), (221.5, 225, 110), (225, 229, 146), (229, 234, 190), (234, 238.5, 238), (238.5, 243, 284),
            (212.5, 219.5, 60), (214, 218, 44),
        ]
        return tubes
    }

    /// burj-khalifa: the stepped silver tower far above the towers of the city by the sea, by day.
    static func paintBurjKhalifa(_ context: inout GraphicsContext) {
        burjSky(&context)
        burjGround(&context)
        burjFarPlane(&context)
        burjCloudsBehind(&context)
        burjTower(&context)
        burjTowerDetail(&context)
        burjPodium(&context)
        burjCity(&context)
        burjLake(&context)
        burjCloudInFront(&context)
        burjPalms(&context)
        burjFinish(&context)
    }

    // MARK: Sky and the far plane

    private static func burjSky(_ context: inout GraphicsContext) {
        let sky: Kit.Stops = [
            (Art.color(0x3F80C4), 0),
            (Art.color(0x7FB2DC), 0.34),
            (Art.color(0xCDE0E6), 0.58),
            (Art.color(0xFFE2B4), 0.72),
            (Art.color(0xFFE2B4), 1),
        ]
        backdrop(&context, sky)
        horizon(&context, y: 288, rise: 80, hex: 0xFFD9A0, alpha: 0.4)
        Art.glow(&context, 6, 30, 250, Art.color(0xFFF0CC), alpha: 0.3)
    }

    /// The far plane: the Gulf, the desert rising behind it on the right, and the far towers of
    /// the city, all veiled with the sky's own colour.
    private static func burjFarPlane(_ context: inout GraphicsContext) {
        let gulf = Art.rect(-24, 288, unitWidth + 48, 18)
        let water: Kit.Stops = [
            (Art.color(0xA9D4E8), 0),
            (Art.color(0x5E9ED0), 0.4),
            (Art.color(0x3E7EBE), 1),
        ]
        fillVertical(&context, gulf, water, from: 288, to: 306)
        let glints = CGRect(x: 0, y: 290, width: 190, height: 12)
        ripples(&context, in: glints, count: 22, seed: 5, color: Art.color(0xFFFFFF, 0.45), width: 0.5, length: 5...18)
        // Two tiny white boats, far out.
        var boats = Path()
        boats.addRect(CGRect(x: 64, y: 293.4, width: 5, height: 1.2))
        boats.addRect(CGRect(x: 138, y: 296.2, width: 4, height: 1.1))
        Art.fill(&context, boats, Art.color(0xFFFFFF, 0.9))

        let desert = Kit.ridge(width: 230, y: 284, amp: 3, seed: 21, bottom: 306, x0: 232)
        Kit.solid(&context, desert, stops: Kit.stops(0xF2DCB4, 0xDCC0A0), light: 0.1, shade: 0.1)

        // The far towers: small and pale.
        var random = ArtRandom(57)
        var far = Path()
        var lit = Path()
        var x: CGFloat = -12
        while x < 444 {
            let w: CGFloat = random.next(in: 6...12)
            let top: CGFloat = random.next(in: 292...314)
            far.addRect(CGRect(x: x, y: top, width: w, height: 326 - top))
            lit.addRect(CGRect(x: x, y: top, width: w * 0.4, height: 326 - top))
            x += w + random.next(in: 1...7)
        }
        Art.fill(&context, far, Art.color(0x9FB4D0))
        Art.fill(&context, lit, Art.color(0xFFEBD0, 0.4))
        haze(&context, top: 270, bottom: 328, hex: 0xFFE2B4, alpha: 0.34)
    }

    /// The city's ground: pale sand under the towers, leading down to the card's colour.
    private static func burjGround(_ context: inout GraphicsContext) {
        let ground = Art.rect(-24, 304, unitWidth + 48, unitHeight - 304 + 24)
        let stops: Kit.Stops = [
            (Art.color(0xF2E0BC), 0),
            (Art.color(0xDCCDB4), 0.2),
            (Art.color(0xA9AAB8), 0.36),
            (Art.color(0x4E668E), 0.68),
            (Art.color(0x1B3558), 1),
        ]
        fillVertical(&context, ground, stops, from: 304, to: unitHeight)
        // Roads running in toward the tower's foot.
        let roads = Art.svg("M-24,372 C60,362 140,352 204,340 M456,366 C380,358 300,350 232,340 M-24,350 C60,346 130,343 190,338")
        Art.stroke(&context, roads, Art.color(0xF6E8CC, 0.3), width: 1.4)
    }

    // MARK: Clouds

    /// Thin clouds well below the tip, behind the tower.
    private static func burjCloudsBehind(_ context: inout GraphicsContext) {
        Art.blurred(&context, radius: 2.5, opacity: 0.85) { g in
            var clouds = Path()
            clouds.addPath(cloudBand(226, 92, width: 128, height: 8))
            clouds.addPath(cloudBand(84, 168, width: 118, height: 9))
            clouds.addPath(cloudBand(300, 206, width: 110, height: 7))
            Art.fill(&g, clouds, Art.color(0xFFFFFF, 0.85))
            var undersides = Path()
            undersides.addPath(cloudBand(240, 93.5, width: 100, height: 3))
            undersides.addPath(cloudBand(100, 169.5, width: 90, height: 3))
            Art.fill(&g, undersides, Art.color(0xFFD9A0, 0.5))
        }
    }

    /// One thin cloud that drifts across in front of the tower, far below its tip.
    private static func burjCloudInFront(_ context: inout GraphicsContext) {
        Art.blurred(&context, radius: 2, opacity: 0.72) { g in
            let cloud = cloudBand(168, 134, width: 104, height: 7)
            Art.fill(&g, cloud, Art.color(0xFFFFFF, 0.9))
        }
    }

    // MARK: The tower

    /// The whole outline of the tower: every tube, the core and the spire.
    private static func burjOutline() -> Path {
        var tower = Path()
        for tube in burjTubes() {
            let width: CGFloat = tube.1 - tube.0
            let height: CGFloat = burjBase - tube.2
            tower.addPath(Art.rect(tube.0, tube.2, width, height, radius: 0.8))
        }
        let cx: CGFloat = burjX
        tower.addPath(Art.polygon([pt(cx - 1.3, 44), pt(cx - 0.25, 24), pt(cx + 0.25, 24), pt(cx + 1.3, 44)]))
        return tower
    }

    /// Silver-blue glass in the one light: warm on the left edge, cool shade to the right.
    private static func burjTower(_ context: inout GraphicsContext) {
        Art.glow(&context, 196, 190, 70, Art.color(0xFFF0CC), alpha: 0.14)
        let tower = burjOutline()
        let glass: Kit.Stops = [
            (Art.color(0xFFEBC4), 0),
            (Art.color(0xE4ECF2), 0.2),
            (Art.color(0xB4CCE4), 0.48),
            (Art.color(0x7C9CC6), 0.75),
            (Art.color(0x566FA2), 1),
        ]
        fillHorizontal(&context, tower, glass, from: 189, to: 243)
        model(&context, tower, light: 0.1, shade: 0.12)
        // The foot of the tower stands in the warm haze of the city.
        let veil: Kit.Stops = [
            (Art.color(0xFFE2B4, 0), 0),
            (Art.color(0xFFE2B4, 0.28), 1),
        ]
        fillVertical(&context, tower, veil, from: 240, to: burjBase)
    }

    /// Fine floor lines, the darker service floors, and the lit and shaded edge of every tube.
    private static func burjTowerDetail(_ context: inout GraphicsContext) {
        let tower = burjOutline()
        var floors = Path()
        var y: CGFloat = 48
        while y < burjBase {
            floors.move(to: pt(186, y))
            floors.addLine(to: pt(246, y))
            y += 3
        }
        var service = Path()
        let serviceFloors: [CGFloat] = [300, 252, 204, 158, 118, 90]
        for level in serviceFloors {
            service.move(to: pt(186, level))
            service.addLine(to: pt(246, level))
        }
        Art.clipped(&context, to: tower) { g in
            Art.stroke(&g, floors, Art.color(0x34507E, 0.2), width: 0.35, cap: .butt)
            Art.stroke(&g, service, Art.color(0x2E4674, 0.3), width: 1.6, cap: .butt)
        }

        let tubes = burjTubes()
        var warmStrips = Path()
        var coolStrips = Path()
        var seams = Path()
        var caps = Path()
        for index in 0..<tubes.count {
            let tube = tubes[index]
            let top: CGFloat = tube.2
            let height: CGFloat = burjBase - top
            caps.addRect(CGRect(x: tube.0 + 0.4, y: top + 0.3, width: tube.1 - tube.0 - 0.8, height: 1.1))
            if index < 6 {
                // The left tubes face the light: a bright warm strip down each outer edge.
                warmStrips.addRect(CGRect(x: tube.0, y: top + 0.8, width: 1.8, height: height))
            } else if index < 12 {
                coolStrips.addRect(CGRect(x: tube.1 - 1.7, y: top + 0.8, width: 1.7, height: height))
                seams.move(to: pt(tube.0, top + 1))
                seams.addLine(to: pt(tube.0, burjBase))
            }
        }
        Art.fill(&context, warmStrips, Art.color(0xFFF3D2, 0.8))
        Art.fill(&context, coolStrips, ArtStyle.coolShade.opacity(0.22))
        Art.stroke(&context, seams, Art.color(0xE4ECF2, 0.4), width: 0.5, cap: .butt)
        Art.fill(&context, caps, Art.color(0xFFF6E0, 0.7))
        // The spire catches the light on its left.
        let cx: CGFloat = burjX
        Art.stroke(&context, Art.line(cx - 0.6, 27, cx - 1.4, 59), Art.color(0xFFF3D2, 0.9), width: 0.6)
        Art.stroke(&context, Art.line(cx - 3, 61, cx - 3, 74), Art.color(0xFFF3D2, 0.8), width: 0.8, cap: .butt)
    }

    /// The low building the tower rises from.
    private static func burjPodium(_ context: inout GraphicsContext) {
        ArtStyle.contactShadow(&context, 222, 335, 46, 4, alpha: 0.28)
        var podium = Path()
        podium.addPath(Art.polygon([pt(178, 335), pt(185, 324), pt(247, 324), pt(254, 335)]))
        podium.addPath(Art.polygon([pt(196, 324), pt(200, 318), pt(232, 318), pt(236, 324)]))
        Kit.solid(&context, podium, stops: Kit.stops(0xEAF0F4, 0xA9BCD4), light: 0.18, shade: 0.2)
        let lines = Art.svg("M185,324 L247,324 M200,318 L232,318 M181,329.500 L251,329.500")
        Art.stroke(&context, lines, Art.color(0xFFF6E0, 0.75), width: 0.7, cap: .butt)
    }

    // MARK: The city round its foot

    /// The ordinary skyscrapers: glass and stone towers, each with a lit face and a shaded
    /// face, the tallest only about a quarter of the great tower's height.
    private static func burjCity(_ context: inout GraphicsContext) {
        // (x, width, top, crown): crown 1 is a slanted top, 2 a mast, 3 a stepped top.
        let places: [(CGFloat, CGFloat, CGFloat, Int)] = [
            (38, 20, 294, 0), (60, 16, 272, 2), (78, 22, 286, 1), (102, 18, 266, 3), (122, 16, 292, 0),
            (140, 20, 276, 1), (162, 14, 298, 0), (176, 11, 308, 0),
            (247, 11, 308, 0), (259, 16, 294, 1), (277, 20, 270, 2), (299, 16, 288, 0), (317, 22, 262, 3),
            (341, 18, 282, 1), (361, 20, 296, 0), (383, 16, 274, 2), (401, 22, 292, 0),
        ]
        let base: CGFloat = 336
        var glass = Path()
        var stone = Path()
        var sides = Path()
        var edges = Path()
        var masts = Path()
        var floors = Path()
        for index in 0..<places.count {
            let place = places[index]
            let x: CGFloat = place.0
            let w: CGFloat = place.1
            let top: CGFloat = place.2
            var body = Path()
            body.addRect(CGRect(x: x, y: top, width: w, height: base - top))
            switch place.3 {
            case 1:
                body.addPath(Art.polygon([pt(x, top), pt(x, top - 2), pt(x + w, top - 7), pt(x + w, top)]))
            case 2:
                body.addRect(CGRect(x: x + w * 0.3, y: top - 4, width: w * 0.4, height: 4))
                masts.move(to: pt(x + w * 0.5, top - 4))
                masts.addLine(to: pt(x + w * 0.5, top - 15))
            case 3:
                body.addRect(CGRect(x: x + w * 0.2, y: top - 5, width: w * 0.6, height: 5))
                body.addRect(CGRect(x: x + w * 0.38, y: top - 9, width: w * 0.24, height: 4))
            default:
                break
            }
            if index % 2 == 0 {
                glass.addPath(body)
            } else {
                stone.addPath(body)
            }
            sides.addRect(CGRect(x: x + w * 0.62, y: top, width: w * 0.38, height: base - top))
            edges.move(to: pt(x + 0.5, top + 1))
            edges.addLine(to: pt(x + 0.5, base))
            var y: CGFloat = top + 4
            while y < base - 2 {
                floors.move(to: pt(x + 1, y))
                floors.addLine(to: pt(x + w - 1, y))
                y += 4
            }
        }
        let shadows = Art.rect(30, 334, 400, 5, radius: 2.5)
        Art.fill(&context, shadows, ArtStyle.coolShade.opacity(0.16))
        let glassStops: Kit.Stops = [(Art.color(0xBCD2E8), 0), (Art.color(0x7E9CC4), 1)]
        let stoneStops: Kit.Stops = [(Art.color(0xF2E2C6), 0), (Art.color(0xC4AE9E), 1)]
        fillVertical(&context, glass, glassStops, from: 252, to: base)
        fillVertical(&context, stone, stoneStops, from: 252, to: base)
        Art.fill(&context, sides, ArtStyle.coolShade.opacity(0.2))
        Art.stroke(&context, floors, Art.color(0xFFFFFF, 0.16), width: 0.4, cap: .butt)
        Art.stroke(&context, edges, Art.color(0xFFF3D2, 0.75), width: 1, cap: .butt)
        Art.stroke(&context, masts, Art.color(0x8FA6C4), width: 0.8)
        // Rows of street trees in front of the towers.
        let leftTrees = canopy(from: 24, to: 160, baseY: 340, height: 3, bump: 6, depth: 2, seed: 9)
        let rightTrees = canopy(from: 282, to: 410, baseY: 341, height: 3, bump: 6, depth: 2, seed: 29)
        Art.fill(&context, leftTrees, Art.color(0x4E8A78, 0.75))
        Art.fill(&context, rightTrees, Art.color(0x4E8A78, 0.75))
    }

    /// The small lake at the tower's foot, with the tower's pale reflection in it.
    private static func burjLake(_ context: inout GraphicsContext) {
        let lake = Art.svg("M168,344 C182,339 202,340 218,341.500 C240,339 262,340 276,345 C264,352 240,354 218,352 C196,355 176,352 168,344 Z")
        let water: Kit.Stops = [(Art.color(0x9FD8DE), 0), (Art.color(0x4E9CBE), 1)]
        fillVertical(&context, lake, water, from: 339, to: 355)
        Art.clipped(&context, to: lake) { g in
            Art.fill(&g, Art.rect(207, 338, 18, 18), Art.color(0xEAF2F6, 0.5))
            Art.fill(&g, Art.rect(207, 338, 5, 18), Art.color(0xFFF3D2, 0.5))
            let glints = CGRect(x: 170, y: 342, width: 104, height: 10)
            ripples(&g, in: glints, count: 12, seed: 45, color: Art.color(0xFFFFFF, 0.5), width: 0.6, length: 4...12)
        }
        Art.stroke(&context, lake, Art.color(0xF6E8CC, 0.6), width: 0.8)
    }

    // MARK: The near plane

    /// Adds one palm frond to `leaves`: leaflets on both sides of a curved rib from `a` to `b`.
    private static func burjFrond(_ leaves: inout Path, _ glints: inout Path, from a: CGPoint, control c: CGPoint, to b: CGPoint, size: CGFloat) {
        for step in 1...10 {
            let t: CGFloat = CGFloat(step) / 10
            let u: CGFloat = 1 - t
            let wa: CGFloat = u * u
            let wc: CGFloat = 2 * u * t
            let wb: CGFloat = t * t
            let x: CGFloat = wa * a.x + wc * c.x + wb * b.x
            let y: CGFloat = wa * a.y + wc * c.y + wb * b.y
            let dx: CGFloat = u * (c.x - a.x) + t * (b.x - c.x)
            let dy: CGFloat = u * (c.y - a.y) + t * (b.y - c.y)
            let along: CGFloat = atan2(dy, dx)
            let length: CGFloat = size * (1.1 - t * 0.6)
            leaves.addPath(leaf(x, y, length: length, width: length * 0.16, angle: along + 0.9))
            leaves.addPath(leaf(x, y, length: length, width: length * 0.16, angle: along - 0.9))
            glints.addPath(leaf(x, y, length: length * 0.8, width: length * 0.035, angle: along - 0.9))
        }
    }

    /// The near plane: dark palm fronds reaching in from the bottom-right corner, each with a
    /// sliver of the key light.
    private static func burjPalms(_ context: inout GraphicsContext) {
        let root = pt(442, 404)
        // (control x, control y, tip x, tip y, leaflet size)
        let fronds: [(CGFloat, CGFloat, CGFloat, CGFloat, CGFloat)] = [
            (398, 336, 346, 346, 20), (420, 318, 384, 300, 20), (380, 376, 330, 388, 18), (446, 326, 426, 290, 17),
        ]
        var ribs = Path()
        var leaves = Path()
        var glints = Path()
        for frond in fronds {
            let control = pt(frond.0, frond.1)
            let tip = pt(frond.2, frond.3)
            ribs.move(to: root)
            ribs.addQuadCurve(to: tip, control: control)
            burjFrond(&leaves, &glints, from: root, control: control, to: tip, size: frond.4)
        }
        Art.fill(&context, leaves, Art.color(0x14304C))
        Art.stroke(&context, ribs, Art.color(0x10283E), width: ArtStyle.detailLine)
        Art.fill(&context, glints, Art.color(0xFFD9A0, 0.32))
    }

    // MARK: Finish

    private static func burjFinish(_ context: inout GraphicsContext) {
        bottomFade(&context, 0x1B3558, from: 304, alpha: 0.9)
        tooth(&context, seed: 617, light: 0.06, dark: 0.05)
        finish(&context, wash: 0.10, vignette: 0.10)
    }
}
