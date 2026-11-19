import SwiftUI
import OmramoCore

// Lions Gate Bridge, Vancouver, on a misty morning: our own drawing (no photograph, nothing
// traced). A green suspension bridge with two tall towers and swooping main cables crosses the
// narrow strait between dark fir-and-cedar shores; behind and above stand two rounded snowy rock
// peaks side by side (the Lions). A small ship passes on the water under the span, and dark firs
// stand at the near left edge. Card background #16343A.

extension LandmarkArt {
    /// lions-gate-bridge: the green suspension bridge over the misty narrows, with the two
    /// rounded snowy peaks behind it and a small ship on the water, in a soft morning light.
    static func paintLionsGate(_ context: inout GraphicsContext) {
        lionsGateSky(&context)
        lionsGateMountains(&context)
        lionsGateWater(&context)
        lionsGateShores(&context)
        lionsGateMist(&context)
        lionsGateCables(&context, front: false)
        lionsGateTower(&context, cx: 128)
        lionsGateTower(&context, cx: 304)
        lionsGateDeck(&context)
        lionsGateCables(&context, front: true)
        // Warm morning light lying on the towers and the cables, from the upper left.
        Art.glow(&context, 150, 130, 160, Art.color(0xFFE6BC), alpha: 0.14)
        lionsGateShip(&context)
        lionsGateNear(&context)
        lionsGateFinish(&context)
    }

    // MARK: Geometry and materials

    /// A point on the quadratic curve from `p0` through control `c` to `p1`, at `t` in 0…1.
    static func lionsGateQuad(_ p0: CGPoint, _ c: CGPoint, _ p1: CGPoint, _ t: CGFloat) -> CGPoint {
        let a: CGFloat = (1 - t) * (1 - t)
        let b: CGFloat = 2 * t * (1 - t)
        let d: CGFloat = t * t
        let x: CGFloat = a * p0.x + b * c.x + d * p1.x
        let y: CGFloat = a * p0.y + b * c.y + d * p1.y
        return CGPoint(x: x, y: y)
    }

    /// The top of the road deck at `x`: a gentle arch, highest in the middle of the span.
    static func lionsGateDeckY(_ x: CGFloat) -> CGFloat {
        let u: CGFloat = (x - 216) / 240
        return 186 + 10 * u * u
    }

    /// The bridge's green steel in the one light: pale green on the left, deep to the right.
    static func lionsGateGreenStops() -> [(Color, CGFloat)] {
        [(Art.color(0x9ACCA8), 0), (Art.color(0x5E9A7A), 0.45), (Art.color(0x2E5E56), 1)]
    }

    /// A row of small pointed firs whose feet follow a quadratic curve.
    static func lionsGateFirs(along p0: CGPoint, _ c: CGPoint, _ p1: CGPoint, count: Int, height: CGFloat, seed: UInt32) -> Path {
        var random = ArtRandom(seed)
        var path = Path()
        let total: Int = max(2, count)
        for index in 0..<total {
            let t: CGFloat = CGFloat(index) / CGFloat(total - 1)
            let foot: CGPoint = lionsGateQuad(p0, c, p1, t)
            let h: CGFloat = height * random.next(in: 0.6...1.2)
            let w: CGFloat = h * 0.3
            let shift: CGFloat = random.next(in: -2...2)
            let x: CGFloat = foot.x + shift
            let corners: [CGPoint] = [pt(x - w, foot.y + 3), pt(x, foot.y - h), pt(x + w, foot.y + 3)]
            path.addPath(Art.polygon(corners))
        }
        return path
    }

    // MARK: Sky and far plane

    static func lionsGateSky(_ context: inout GraphicsContext) {
        let sky: [(Color, CGFloat)] = [
            (Art.color(0x9EBFCC), 0),
            (Art.color(0xC8DCDC), 0.25),
            (Art.color(0xEAE8DC), 0.45),
            (Art.color(0xF6E6CC), 0.58),
            (Art.color(0xF6E6CC), 1),
        ]
        backdrop(&context, sky)
        // The low morning sun behind the mist, up on the left.
        Art.glow(&context, 96, 110, 170, Art.color(0xFFEAC4), alpha: 0.35)
        let cloudA = cloudBand(286, 40, width: 120, height: 10)
        let cloudB = cloudBand(340, 58, width: 80, height: 7)
        Art.fill(&context, cloudA, Art.color(0xFFFFFF, 0.42))
        Art.fill(&context, cloudB, Art.color(0xFFFFFF, 0.3))
    }

    /// The two rounded snowy peaks on their range, then the nearer wooded ridges, all hazed.
    static func lionsGateMountains(_ context: inout GraphicsContext) {
        let range = Art.svg("M-24,172 C20,156 60,146 100,150 C130,152 150,136 172,120 C182,98 192,70 206,64 C218,60 226,70 230,86 C236,78 244,70 256,72 C268,76 274,96 284,118 C302,132 330,130 360,140 C400,152 430,146 456,152 L456,250 L-24,250 Z")
        let rock: [(Color, CGFloat)] = [
            (Art.color(0xA2B0C0), 0),
            (Art.color(0x8496AA), 0.5),
            (Art.color(0x6E8296), 1),
        ]
        fillHorizontal(&context, range, rock, from: 160, to: 300)
        model(&context, range, light: 0.16, shade: 0.12)

        // Snow lying on the domes and in the high hollows, its lower edge ragged.
        let snow = Art.svg("M184,110 C190,88 196,70 206,65 C216,62 224,70 228,84 C222,90 218,86 214,96 C210,92 206,100 200,98 C196,106 190,104 184,110 Z M238,80 C244,74 250,72 256,73 C266,76 272,92 278,108 C272,104 268,110 264,102 C260,108 256,100 252,104 C248,96 244,98 238,94 Z M100,152 C120,150 140,140 160,128 C150,140 140,144 130,148 C120,150 110,156 100,152 Z M300,134 C320,134 340,134 360,142 C340,142 330,146 316,140 C310,142 304,140 300,134 Z")
        let snowStops: [(Color, CGFloat)] = [
            (Art.color(0xFFF8EC), 0),
            (Art.color(0xEEF0F2), 0.5),
            (Art.color(0xC4CCE0), 1),
        ]
        fillHorizontal(&context, snow, snowStops, from: 184, to: 280)
        // The bare granite gullies down the faces of the peaks.
        let gullies = Art.svg("M214,72 C212,84 216,96 212,108 M222,78 C224,90 220,102 224,114 M262,80 C260,92 266,102 262,116 M270,92 C272,100 270,108 274,118")
        Art.stroke(&context, gullies, ArtStyle.coolShade.opacity(0.22), width: 1.4)
        let rims = Art.svg("M186,108 C190,88 196,70 206,65 M240,78 C244,74 250,72 256,73")
        Art.stroke(&context, rims, Art.color(0xFFF2DC, 0.7), width: 1)
        haze(&context, top: 50, bottom: 250, hex: 0xEAE8DC, alpha: 0.42)

        // The nearer wooded ridges of the north shore, bluer and paler the farther they are.
        let ridge = Art.svg("M-24,196 C30,180 80,170 130,178 C170,184 200,168 240,170 C290,172 330,160 380,170 C410,176 440,172 456,176 L456,250 L-24,250 Z")
        Art.fill(&context, ridge, Art.color(0x6A8A8C))
        let ridgeTrees = canopy(from: -24, to: 456, baseY: 186, height: 6, bump: 10, depth: 70, seed: 457)
        Art.clipped(&context, to: ridge) { g in
            Art.fill(&g, ridgeTrees, Art.color(0x5E7E80, 0.6))
        }
        haze(&context, top: 150, bottom: 250, hex: 0xEAE8DC, alpha: 0.32)
        let foothills = Art.svg("M-24,214 C40,206 100,210 160,204 C220,198 280,206 340,200 C390,196 430,204 456,202 L456,250 L-24,250 Z")
        Art.fill(&context, foothills, Art.color(0x4E6E6C))
        let footTrees = lionsGateFirs(along: pt(-24, 214), pt(216, 190), pt(456, 202), count: 60, height: 7, seed: 461)
        Art.fill(&context, footTrees, Art.color(0x4E6E6C))
        haze(&context, top: 190, bottom: 250, hex: 0xEAE8DC, alpha: 0.22)
    }

    // MARK: Water, shores and mist

    static func lionsGateWater(_ context: inout GraphicsContext) {
        let water = Art.rect(-24, 236, unitWidth + 48, unitHeight - 236 + 24)
        let stops: [(Color, CGFloat)] = [
            (Art.color(0xC6D6D2), 0),
            (Art.color(0x8AAAAA), 0.25),
            (Art.color(0x3E6A70), 0.65),
            (Art.color(0x16343A), 1),
        ]
        fillVertical(&context, water, stops, from: 236, to: unitHeight)
        horizon(&context, y: 238, rise: 30, hex: 0xFFE6C0, alpha: 0.3)
        // The towers' long green reflections, broken by the ripples.
        var reflections = Path()
        reflections.addRect(CGRect(x: 116, y: 240, width: 24, height: 56))
        reflections.addRect(CGRect(x: 292, y: 240, width: 24, height: 56))
        let fade: [(Color, CGFloat)] = [
            (Art.color(0x4E8A6E, 0.3), 0),
            (Art.color(0x4E8A6E, 0), 1),
        ]
        fillVertical(&context, reflections, fade, from: 240, to: 296)
        let glints = CGRect(x: 0, y: 244, width: unitWidth, height: 80)
        ripples(&context, in: glints, count: 60, seed: 419, color: Art.color(0xFFFFFF, 0.35), width: 0.8, length: 4...14)
        let darks = CGRect(x: 0, y: 270, width: unitWidth, height: 90)
        ripples(&context, in: darks, count: 30, seed: 433, color: Art.color(0x1E4A52, 0.35), width: 1, length: 8...22)
    }

    /// The dark wooded shores either side of the narrows: the park's headland on the left,
    /// where the bridge begins, and the low north shore across the water on the right.
    static func lionsGateShores(_ context: inout GraphicsContext) {
        var land = Art.svg("M-24,178 C10,172 40,180 70,194 C92,204 108,220 124,240 L-24,240 Z")
        land.addPath(Art.svg("M296,240 C326,226 360,214 400,208 C420,206 440,204 456,204 L456,240 Z"))
        var firs = lionsGateFirs(along: pt(-20, 177), pt(60, 182), pt(120, 238), count: 24, height: 15, seed: 503)
        firs.addPath(lionsGateFirs(along: pt(300, 238), pt(370, 206), pt(456, 204), count: 26, height: 12, seed: 517))
        let forest: [(Color, CGFloat)] = [
            (Art.color(0x4E705E), 0),
            (Art.color(0x2E4A44), 1),
        ]
        fillVertical(&context, firs, forest, from: 160, to: 240)
        fillVertical(&context, land, forest, from: 170, to: 240)
        model(&context, land, light: 0.16, shade: 0.24)
        let lit = Art.svg("M-24,178 C10,172 40,180 70,194 M296,240 C326,226 360,214 400,208")
        Art.stroke(&context, lit, Art.color(0xC8D8A8, 0.25), width: 1.2)

        // The pale rocky edge where the shores meet the water, and their dark reflections.
        let edges = Art.svg("M-24,239.5 L124,239.5 M296,239.5 L456,239.5")
        Art.stroke(&context, edges, Art.color(0xE0DCCC, 0.6), width: 1.2, cap: .butt)
        var shadows = Path()
        shadows.addRect(CGRect(x: -24, y: 241, width: 140, height: 14))
        shadows.addRect(CGRect(x: 304, y: 241, width: 152, height: 12))
        let dim: [(Color, CGFloat)] = [
            (Art.color(0x2E4A44, 0.35), 0),
            (Art.color(0x2E4A44, 0), 1),
        ]
        fillVertical(&context, shadows, dim, from: 241, to: 255)
    }

    /// The morning mist lying low over the water and against the shores.
    static func lionsGateMist(_ context: inout GraphicsContext) {
        let band = Art.rect(-24, 200, unitWidth + 48, 56)
        let stops: [(Color, CGFloat)] = [
            (Art.color(0xF4F0E6, 0), 0),
            (Art.color(0xF4F0E6, 0.5), 0.55),
            (Art.color(0xF4F0E6, 0), 1),
        ]
        fillVertical(&context, band, stops, from: 200, to: 256)
        let driftLeft = cloudBand(-30, 234, width: 150, height: 14)
        let driftRight = cloudBand(330, 238, width: 140, height: 12)
        Art.blurred(&context, radius: 8, opacity: 0.6) { g in
            Art.fill(&g, driftLeft, Art.color(0xFFFFFF, 0.7))
            Art.fill(&g, driftRight, Art.color(0xFFFFFF, 0.6))
        }
    }

    // MARK: The bridge

    /// One tower on its concrete pier: two tapering green legs tied by struts and a cross
    /// brace, with a cap and the two saddles the main cables ride over.
    static func lionsGateTower(_ context: inout GraphicsContext, cx: CGFloat) {
        let top: CGFloat = 114
        let base: CGFloat = 230
        let green: [(Color, CGFloat)] = lionsGateGreenStops()
        let left: CGFloat = cx - 12
        let right: CGFloat = cx + 12

        let pier = Art.rect(cx - 16, 224, 32, 14, radius: 1.5)
        let pierStops: [(Color, CGFloat)] = [
            (Art.color(0xE6E2D6), 0),
            (Art.color(0xA8AAB4), 1),
        ]
        fillHorizontal(&context, pier, pierStops, from: cx - 16, to: cx + 16)
        model(&context, pier, light: 0.14, shade: 0.2)
        Art.fill(&context, Art.rect(cx - 17, 236, 34, 2.4), ArtStyle.coolShade.opacity(0.25))

        var brace = Art.line(cx - 6, 151, cx + 6.6, 184)
        brace.move(to: pt(cx + 6, 151))
        brace.addLine(to: pt(cx - 6.6, 184))
        Art.stroke(&context, brace, Art.color(0x3E7660), width: ArtStyle.detailLine)
        var struts = Path()
        struts.addRect(CGRect(x: cx - 6, y: top + 4, width: 12, height: 3.5))
        struts.addRect(CGRect(x: cx - 6.4, y: 148, width: 12.8, height: 3))
        struts.addRect(CGRect(x: cx - 7.6, y: 206, width: 15.2, height: 3))
        fillHorizontal(&context, struts, green, from: left, to: right)
        Art.fill(&context, struts, ArtStyle.coolShade.opacity(0.12))

        let leftLeg: [CGPoint] = [pt(cx - 10, top), pt(cx - 5, top), pt(cx - 6, base), pt(cx - 12, base)]
        let rightLeg: [CGPoint] = [pt(cx + 5, top), pt(cx + 10, top), pt(cx + 12, base), pt(cx + 6, base)]
        var legs = Art.polygon(leftLeg)
        legs.addPath(Art.polygon(rightLeg))
        fillHorizontal(&context, legs, green, from: left, to: right)
        model(&context, legs, light: 0.22, shade: 0.24, rim: 0.5)
        var edges = Art.line(cx - 9.4, top + 1, cx - 11.4, base)
        edges.move(to: pt(cx + 5.6, top + 1))
        edges.addLine(to: pt(cx + 6.6, base))
        Art.stroke(&context, edges, Art.color(0xEAF6D8, 0.5), width: 0.8, cap: .butt)

        let cap = Art.rect(cx - 11.5, top - 4, 23, 4.5, radius: 1)
        fillHorizontal(&context, cap, green, from: left, to: right)
        var saddles = Path()
        saddles.addEllipse(in: CGRect(x: cx - 10, y: top - 7, width: 5, height: 4))
        saddles.addEllipse(in: CGRect(x: cx + 5, y: top - 7, width: 5, height: 4))
        fillHorizontal(&context, saddles, green, from: left, to: right)
        Art.stroke(&context, Art.line(cx - 11, top - 3.6, cx + 11, top - 3.6), Art.color(0xEAF6D8, 0.6), width: 0.8, cap: .butt)
    }

    /// The road deck across the whole picture: a green girder with a truss below, a railing
    /// and a row of small lamps along its top.
    static func lionsGateDeck(_ context: inout GraphicsContext) {
        var deck = Path()
        var road = Path()
        var started: Bool = false
        var x: CGFloat = -24
        while x <= 456 {
            let y: CGFloat = lionsGateDeckY(x)
            if started {
                deck.addLine(to: pt(x, y))
                road.addLine(to: pt(x, y))
            } else {
                deck.move(to: pt(x, y))
                road.move(to: pt(x, y))
                started = true
            }
            x += 16
        }
        x = 456
        while x >= -24 {
            let y: CGFloat = lionsGateDeckY(x) + 8
            deck.addLine(to: pt(x, y))
            x -= 16
        }
        deck.closeSubpath()

        let girder: [(Color, CGFloat)] = [
            (Art.color(0x8CC4A0), 0),
            (Art.color(0x4E8A6E), 0.4),
            (Art.color(0x2E5A54), 1),
        ]
        fillVertical(&context, deck, girder, from: 184, to: 204)
        let truss = CGRect(x: -24, y: 189, width: unitWidth + 48, height: 16)
        let rising = diagonals(in: truss, spacing: 5, rising: true)
        let falling = diagonals(in: truss, spacing: 5, rising: false)
        Art.clipped(&context, to: deck) { g in
            Art.stroke(&g, rising, Art.color(0x24484A, 0.45), width: 0.7, cap: .butt)
            Art.stroke(&g, falling, Art.color(0x24484A, 0.45), width: 0.7, cap: .butt)
        }
        model(&context, deck, light: 0.12, shade: 0.16)
        Art.stroke(&context, road, Art.color(0xFFF0D0, 0.75), width: 1.1, cap: .butt)

        // The railing and the lamps.
        var rail = Path()
        var lamps = Path()
        var lampX: CGFloat = -12
        while lampX < 452 {
            let deckTop: CGFloat = lionsGateDeckY(lampX)
            rail.move(to: pt(lampX, deckTop))
            rail.addLine(to: pt(lampX, deckTop - 2.6))
            lamps.move(to: pt(lampX + 8, deckTop))
            lamps.addLine(to: pt(lampX + 8, deckTop - 6))
            lampX += 24
        }
        Art.stroke(&context, rail, Art.color(0x5E9A7A, 0.8), width: 0.6, cap: .butt)
        Art.stroke(&context, lamps, Art.color(0x3E7660, 0.9), width: 0.7, cap: .butt)
        Art.group(&context, y: -2.4) { g in
            Art.stroke(&g, road, Art.color(0x5E9A7A, 0.8), width: 0.6, cap: .butt)
        }
    }

    /// The main cables and their hangers. The far cable is drawn first, a little up and to
    /// the right and paler; the near cable after the deck, in full colour.
    static func lionsGateCables(_ context: inout GraphicsContext, front: Bool) {
        let cable = Art.svg("M36,192 Q96,160 128,110 Q216,234 304,110 Q336,160 396,192")
        let spans: [(CGPoint, CGPoint, CGPoint, Int)] = [
            (pt(36, 192), pt(96, 160), pt(128, 110), 12),
            (pt(128, 110), pt(216, 234), pt(304, 110), 30),
            (pt(304, 110), pt(336, 160), pt(396, 192), 12),
        ]
        var hangers = Path()
        for span in spans {
            for index in 1..<span.3 {
                let t: CGFloat = CGFloat(index) / CGFloat(span.3)
                let point: CGPoint = lionsGateQuad(span.0, span.1, span.2, t)
                let deckTop: CGFloat = lionsGateDeckY(point.x)
                if deckTop - point.y > 2 {
                    hangers.move(to: point)
                    hangers.addLine(to: pt(point.x, deckTop))
                }
            }
        }
        if front {
            Art.stroke(&context, hangers, Art.color(0x3E7660, 0.85), width: 0.6, cap: .butt)
            Art.stroke(&context, cable, Art.color(0x3E7660), width: 2.6)
            Art.stroke(&context, cable, Art.color(0xC8E8C4, 0.7), width: 0.9)
        } else {
            Art.group(&context, x: 3, y: -1.5) { g in
                Art.stroke(&g, hangers, Art.color(0x6E9A88, 0.5), width: 0.5, cap: .butt)
                Art.stroke(&g, cable, Art.color(0x6E9A88, 0.8), width: 2)
            }
        }
    }

    // MARK: The ship

    /// A small white coaster heading out under the span, bow to the left, with its wake.
    static func lionsGateShip(_ context: inout GraphicsContext) {
        ArtStyle.contactShadow(&context, 240, 268, 30, 2.4, alpha: 0.3)
        let wake = Art.svg("M262,267 C280,270 300,268 330,272 M262,265 C282,264 304,262 326,262 M258,269 C276,274 296,276 318,280")
        Art.stroke(&context, wake, Art.color(0xFFFFFF, 0.5), width: 0.9)

        let hull = Art.svg("M206,258 L264,258 L262,266 C250,268 226,268 214,266 Z")
        Kit.solid(&context, hull, stops: Kit.stops(0x3E5A7E, 0x24385A), light: 0.16, shade: 0.2)
        Art.stroke(&context, Art.line(212, 265, 262, 265), Art.color(0xC04A3C, 0.8), width: 1.2, cap: .butt)
        Art.stroke(&context, Art.line(207, 258.4, 264, 258.4), Art.color(0xFFF0D8, 0.7), width: 0.8, cap: .butt)

        var cabins = Path()
        cabins.addRect(CGRect(x: 232, y: 250, width: 26, height: 8))
        cabins.addRect(CGRect(x: 238, y: 245, width: 14, height: 5))
        let white: [(Color, CGFloat)] = [
            (Art.color(0xFFFCF4), 0),
            (Art.color(0xC8CCD8), 1),
        ]
        fillHorizontal(&context, cabins, white, from: 232, to: 258)
        var windows = Path()
        var windowX: CGFloat = 234
        while windowX < 256 {
            windows.addRect(CGRect(x: windowX, y: 252.6, width: 1.6, height: 1.4))
            windowX += 3.2
        }
        windows.addRect(CGRect(x: 240, y: 246.4, width: 10, height: 1.4))
        Art.fill(&context, windows, Art.color(0x3E5A7E, 0.8))
        let funnel = Art.polygon([pt(247, 238), pt(252, 238), pt(253, 245), pt(246, 245)])
        Kit.solid(&context, funnel, Art.color(0xD8503C), light: 0.2, shade: 0.2)
        Art.stroke(&context, Art.line(216, 258, 216, 250), Art.color(0x8A92A4), width: 0.7)
        // Its pale reflection on the water.
        Art.fill(&context, Art.rect(214, 268, 46, 5), Art.color(0xFFFCF4, 0.12))
    }

    // MARK: The near plane

    /// A dark fir: tiers of drooping boughs round a trunk, from `top` down past the frame.
    static func lionsGateNearFir(_ cx: CGFloat, top: CGFloat, height: CGFloat, width: CGFloat) -> Path {
        var path = Path()
        let tiers: Int = 6
        for index in 0..<tiers {
            let t: CGFloat = CGFloat(index) / CGFloat(tiers)
            let tierTop: CGFloat = top + height * t * 0.85
            let tierBottom: CGFloat = tierTop + height * 0.26
            let half: CGFloat = width * (0.25 + t * 0.75) / 2
            let droop: CGFloat = tierBottom - height * 0.06
            let lift: CGFloat = tierBottom - height * 0.1
            path.move(to: pt(cx, tierTop))
            path.addQuadCurve(to: pt(cx - half, tierBottom), control: pt(cx - half * 0.4, droop))
            path.addQuadCurve(to: pt(cx + half, tierBottom), control: pt(cx, lift))
            path.addQuadCurve(to: pt(cx, tierTop), control: pt(cx + half * 0.4, droop))
            path.closeSubpath()
        }
        let trunkW: CGFloat = width * 0.08
        path.addRect(CGRect(x: cx - trunkW / 2, y: top + height * 0.5, width: trunkW, height: height))
        return path
    }

    /// Two dark firs cropped at the near left edge and a mossy rock at the near right.
    static func lionsGateNear(_ context: inout GraphicsContext) {
        var firs = lionsGateNearFir(16, top: 236, height: 190, width: 84)
        firs.addPath(lionsGateNearFir(62, top: 292, height: 150, width: 62))
        Kit.solid(&context, firs, stops: Kit.stops(0x2A4A40, 0x14282C), light: 0.08, shade: 0.22)
        let glints = Art.svg("M12,252 L4,268 M10,280 L-2,298 M8,310 L-6,330 M58,306 L50,320 M56,330 L44,348")
        Art.stroke(&context, glints, Art.color(0x8AB48A, 0.35), width: 1.2)

        let rock = Art.svg("M368,412 C372,388 390,370 414,364 C432,360 448,364 456,370 L456,420 Z")
        Kit.solid(&context, rock, stops: Kit.stops(0x3E5450, 0x1A2E34), light: 0.12, shade: 0.24, rim: 2)
        let moss = Art.svg("M376,390 C386,380 398,372 412,368 C424,365 438,365 448,368")
        Art.stroke(&context, moss, Art.color(0x7E9E6A, 0.5), width: 2)
    }

    // MARK: Finish

    static func lionsGateFinish(_ context: inout GraphicsContext) {
        bottomFade(&context, 0x16343A, from: 300, alpha: 0.9)
        tooth(&context, seed: 829, light: 0.05, dark: 0.04)
        finish(&context, wash: 0.10, vignette: 0.10)
    }
}
