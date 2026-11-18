import SwiftUI
import OmramoCore

// The Golden Gate Bridge by day: our own drawing (no photograph, nothing traced).
// Seen at an angle from one shore: the nearer tower large, with its stepped profile and the
// braces between its two legs; the farther tower small, its foot in a bank of fog; the two
// main cables sweeping over the tower tops, thin hanger cables, the road deck, all in
// red-orange and lit warm on the left. Blue strait, a tiny ship, green-gold headland hills
// behind, and a dark rocky shore with grass in the bottom-right corner as the near plane.
// Card background #17405C.
//
// The bridge runs away from the viewer toward a vanishing point at (-40, 262) on the water's
// horizon. The near tower is drawn at full size round x 269; the far tower is the same drawing
// at 0.545 of the size about that point.

extension LandmarkArt {
    /// golden-gate-bridge: the long red-orange bridge with two tall towers and great cables,
    /// crossing blue water with fog round its far foot, by day.
    static func paintGoldenGate(_ context: inout GraphicsContext) {
        goldenGateSky(&context)
        goldenGateHills(&context)
        goldenGateWater(&context)
        goldenGateShip(&context)
        // The far tower, the same drawing made small about the vanishing point.
        Art.group(&context, x: -18.2, y: 119.2, scale: 0.545) { g in
            goldenGateTower(&g)
        }
        haze(&context, top: 140, bottom: 262, hex: 0xFFE9C4, alpha: 0.12)
        goldenGateFog(&context)
        goldenGateTower(&context)
        goldenGateDeck(&context)
        // The viewer's-side leg of each tower stands in front of the deck.
        Art.group(&context, x: -18.2, y: 119.2, scale: 0.545) { g in
            goldenGateFrontLeg(&g)
        }
        goldenGateFrontLeg(&context)
        goldenGateCables(&context)
        goldenGateShore(&context)
        goldenGateFinish(&context)
    }

    // MARK: Measures

    /// How large the bridge is drawn at `x` (1 at the near tower), from the vanishing point.
    static func goldenGateScale(_ x: CGFloat) -> CGFloat {
        (x + 40) / 308
    }

    /// The top of the road deck at `x`.
    static func goldenGateDeckY(_ x: CGFloat) -> CGFloat {
        262 - 44 * goldenGateScale(x)
    }

    /// The bridge's own red-orange in the one light: warm on the left, deeper to the right.
    static func goldenGateSteel(_ context: inout GraphicsContext, _ path: Path, from x0: CGFloat, to x1: CGFloat) {
        let stops: [(Color, CGFloat)] = [
            (Art.color(0xEE6A42), 0),
            (Art.color(0xC0362C), 0.5),
            (Art.color(0x8E2430), 1),
        ]
        fillHorizontal(&context, path, stops, from: x0, to: x1)
    }

    // MARK: Sky and the far plane

    static func goldenGateSky(_ context: inout GraphicsContext) {
        let sky: [(Color, CGFloat)] = [
            (Art.color(0x4A96D2), 0),
            (Art.color(0x8FC6E8), 0.32),
            (Art.color(0xDCEAE6), 0.52),
            (Art.color(0xFFE9C4), 0.64),
            (Art.color(0xFFE9C4), 1),
        ]
        backdrop(&context, sky)
        Art.glow(&context, 20, 150, 220, Art.color(0xFFF2D0), alpha: 0.26)
        horizon(&context, y: 262, rise: 70, hex: 0xFFDCA8, alpha: 0.34)

        var clouds = Path()
        clouds.addPath(cloudBand(318, 104, width: 112, height: 11))
        clouds.addPath(cloudBand(126, 118, width: 84, height: 8))
        clouds.addPath(cloudBand(352, 150, width: 90, height: 7))
        Art.fill(&context, clouds, Art.color(0xFFF8EC, 0.72))
        let lit = Art.svg("M328,100 C348,94 372,92 394,95 M134,115 C150,111 168,110 184,112")
        Art.stroke(&context, lit, Art.color(0xFFFFFF, 0.7), width: 1)
    }

    /// The green-gold headland the bridge runs to, on the left, and a low far shore on the
    /// right, both veiled with the sky's own colour.
    static func goldenGateHills(_ context: inout GraphicsContext) {
        let farShore = Art.svg("M286,264 C320,256 356,252 392,249 C416,247 440,248 456,246 L456,264 Z")
        Art.fill(&context, farShore, Art.color(0x9DB6B4))

        let headland = Art.svg("M-24,266 L-24,214 C6,202 38,196 68,206 C98,214 120,204 150,216 C180,226 204,242 236,255 C250,259 262,262 272,264 L272,266 Z")
        let grass: [(Color, CGFloat)] = [
            (Art.color(0xC4BC6E), 0),
            (Art.color(0x8FA662), 0.5),
            (Art.color(0x5E8670), 1),
        ]
        fillVertical(&context, headland, grass, from: 198, to: 266)
        model(&context, headland, light: 0.2, shade: 0.2)
        // Folds of the hills, and darker scrub lying in them.
        let folds = Art.svg("M40,200 C46,220 38,240 44,262 M100,212 C108,228 100,246 108,262 M150,218 C160,232 156,248 164,262 M196,238 C204,246 204,254 210,262")
        let scrub = Art.svg("M-10,236 C6,230 20,238 34,234 M54,246 C70,240 84,248 96,244 M116,238 C128,234 138,240 146,238 M170,250 C180,246 190,252 200,250")
        let crest = Art.svg("M-24,214 C6,202 38,196 68,206 C98,214 120,204 150,216")
        Art.clipped(&context, to: headland) { g in
            Art.stroke(&g, folds, Art.color(0x4E7460, 0.4), width: 5)
            Art.stroke(&g, scrub, Art.color(0x3E6658, 0.45), width: 3)
            Art.stroke(&g, crest, Art.color(0xFFF0B8, 0.6), width: 1.6)
        }
        haze(&context, top: 190, bottom: 266, hex: 0xFFE9C4, alpha: 0.3)
    }

    // MARK: Water

    static func goldenGateWater(_ context: inout GraphicsContext) {
        let strait = Art.rect(-24, 262, unitWidth + 48, unitHeight - 262 + 24)
        let water: [(Color, CGFloat)] = [
            (Art.color(0xDDE6DC), 0),
            (Art.color(0x8CC4DE), 0.1),
            (Art.color(0x3F8ABC), 0.42),
            (Art.color(0x1F5C88), 0.78),
            (Art.color(0x17405C), 1),
        ]
        fillVertical(&context, strait, water, from: 262, to: unitHeight)

        // The near tower lies red on the water under itself.
        let glow: [(Color, CGFloat)] = [
            (Art.color(0xD04A34, 0.42), 0),
            (Art.color(0xD04A34, 0), 1),
        ]
        var streaks = Path()
        streaks.addRect(CGRect(x: 246, y: 294, width: 12, height: 56))
        streaks.addRect(CGRect(x: 280, y: 294, width: 12, height: 56))
        fillVertical(&context, streaks, glow, from: 294, to: 350)

        let whole = CGRect(x: 0, y: 268, width: unitWidth, height: 116)
        ripples(&context, in: whole, count: 60, seed: 41, color: Art.color(0xFFFFFF, 0.32), width: 0.8, length: 5...24)
        ripples(&context, in: whole, count: 34, seed: 43, color: Art.color(0x17405C, 0.3), width: 0.9, length: 8...30)
        // The light glitters on the left of the strait.
        let glitter = CGRect(x: 10, y: 286, width: 150, height: 40)
        ripples(&context, in: glitter, count: 22, seed: 47, color: Art.color(0xFFEBC4, 0.7), width: 0.9, length: 3...10)
    }

    /// A tiny far ship under the near span, and one small sail: for scale.
    static func goldenGateShip(_ context: inout GraphicsContext) {
        Art.fill(&context, Art.ellipse(351, 276.4, 12, 1.4), Art.color(0x17405C, 0.35))
        let hull = Art.svg("M338,271 L364,271 L361,275.6 L341,275.6 Z")
        Art.fill(&context, hull, Art.color(0x3A3458))
        let band = Art.line(339, 271.6, 363.4, 271.6)
        Art.stroke(&context, band, Art.color(0xD8553C, 0.9), width: 0.9, cap: .butt)
        var house = Path()
        house.addRect(CGRect(x: 354, y: 266, width: 7, height: 5))
        house.addRect(CGRect(x: 343, y: 268.6, width: 9, height: 2.4))
        Art.fill(&context, house, Art.color(0xFFF4E2))
        Art.fill(&context, Art.rect(356, 263, 2.4, 3), Art.color(0xD8553C))
        Art.fill(&context, Art.rect(358.6, 266, 2.4, 5), ArtStyle.coolShade.opacity(0.22))

        // The sail, farther left and nearer.
        Art.fill(&context, Art.ellipse(212, 300.6, 5, 0.9), Art.color(0x17405C, 0.35))
        let sail = Art.polygon([pt(211, 287), pt(211, 298), pt(204.6, 298)])
        let jib = Art.polygon([pt(212.4, 289.6), pt(212.4, 298), pt(217, 298)])
        Art.fill(&context, sail, Art.color(0xFFF6E6))
        Art.fill(&context, jib, Art.color(0xE4E0EC))
        let boat = Art.svg("M203.6,298.6 L218.4,298.6 L216.4,300.6 L205.6,300.6 Z")
        Art.fill(&context, boat, Art.color(0x3A3458))
    }

    /// The bank of fog lying on the water round the far tower's foot.
    static func goldenGateFog(_ context: inout GraphicsContext) {
        Art.blurred(&context, radius: 6) { g in
            var bank = Path()
            bank.addPath(Art.ellipse(128, 273, 74, 12))
            bank.addPath(Art.ellipse(64, 266, 62, 10))
            bank.addPath(Art.ellipse(194, 271, 52, 9))
            bank.addPath(Art.ellipse(108, 259, 50, 8))
            bank.addPath(Art.ellipse(12, 272, 52, 10))
            Art.fill(&g, bank, Art.color(0xFFF8EE, 0.9))
            Art.fill(&g, Art.ellipse(132, 284, 76, 5), ArtStyle.coolShade.opacity(0.12))
        }
        Art.blurred(&context, radius: 2) { g in
            var wisps = Path()
            wisps.addPath(cloudBand(48, 264, width: 136, height: 14))
            wisps.addPath(cloudBand(-16, 258, width: 96, height: 10))
            wisps.addPath(cloudBand(150, 270, width: 96, height: 9))
            Art.fill(&g, wisps, Art.color(0xFFFFFF, 0.6))
        }
    }

    // MARK: Tower (drawn at the near tower's place and size)

    /// The stepped sections of one leg, from the top down: (top y, bottom y, half width).
    static func goldenGateSections() -> [(CGFloat, CGFloat, CGFloat)] {
        let sections: [(CGFloat, CGFloat, CGFloat)] = [
            (46, 98, 4.4), (98, 146, 5.2), (146, 216, 6), (216, 286, 6.8),
        ]
        return sections
    }

    /// One leg centred on `cx`: it narrows upward in steps and ends in two small caps.
    static func goldenGateLegPath(_ cx: CGFloat) -> Path {
        var path = Path()
        for section in goldenGateSections() {
            let height: CGFloat = section.1 - section.0
            path.addRect(CGRect(x: cx - section.2, y: section.0, width: section.2 * 2, height: height))
        }
        path.addRect(CGRect(x: cx - 3.2, y: 41, width: 6.4, height: 5))
        path.addRect(CGRect(x: cx - 2, y: 37.5, width: 4, height: 3.5))
        return path
    }

    /// Paints one leg: lit on its left, shaded on its right, with a ledge at every step.
    static func goldenGatePaintLeg(_ context: inout GraphicsContext, _ cx: CGFloat) {
        let leg = goldenGateLegPath(cx)
        goldenGateSteel(&context, leg, from: cx - 7, to: cx + 7)
        var lights = Path()
        var shades = Path()
        var ledges = Path()
        var ledgeTops = Path()
        for section in goldenGateSections() {
            let half: CGFloat = section.2
            let height: CGFloat = section.1 - section.0
            let lightW: CGFloat = half * 0.5
            let shadeW: CGFloat = half * 0.64
            lights.addRect(CGRect(x: cx - half, y: section.0, width: lightW, height: height))
            shades.addRect(CGRect(x: cx + half - shadeW, y: section.0, width: shadeW, height: height))
            ledges.addRect(CGRect(x: cx - half - 1, y: section.0 - 1.2, width: half * 2 + 2, height: 2.6))
            ledgeTops.move(to: pt(cx - half - 1, section.0 - 1))
            ledgeTops.addLine(to: pt(cx + half + 1, section.0 - 1))
        }
        Art.fill(&context, lights, Art.color(0xFFC494, 0.5))
        Art.fill(&context, shades, ArtStyle.coolShade.opacity(0.2))
        goldenGateSteel(&context, ledges, from: cx - 8, to: cx + 8)
        Art.stroke(&context, ledgeTops, Art.color(0xFFD0A8, 0.85), width: 0.8, cap: .butt)
        // The fluting down the middle of the leg.
        let flute = Art.line(cx + 0.6, 50, cx + 0.6, 282)
        Art.stroke(&context, flute, Art.color(0x7E1E2A, 0.3), width: 0.7, cap: .butt)
    }

    /// The braces between the two legs: three panelled struts above the road, and crossed
    /// braces below it.
    static func goldenGateStruts(_ context: inout GraphicsContext) {
        let levels: [(CGFloat, CGFloat)] = [(47, 12), (97, 11), (145, 12)]
        var struts = Path()
        var tops = Path()
        var ribs = Path()
        var unders = Path()
        for level in levels {
            struts.addRect(CGRect(x: 252, y: level.0, width: 34, height: level.1))
            tops.move(to: pt(252, level.0 + 0.4))
            tops.addLine(to: pt(286, level.0 + 0.4))
            unders.addRect(CGRect(x: 252, y: level.0 + level.1 - 2.4, width: 34, height: 2.4))
            var x: CGFloat = 261
            while x < 280 {
                ribs.move(to: pt(x, level.0 + 2.4))
                ribs.addLine(to: pt(x, level.0 + level.1 - 3))
                x += 4
            }
        }
        let strutStops: [(Color, CGFloat)] = [
            (Art.color(0xD6503A), 0),
            (Art.color(0xA42C2E), 1),
        ]
        fillHorizontal(&context, struts, strutStops, from: 252, to: 286)
        Art.fill(&context, unders, ArtStyle.coolShade.opacity(0.24))
        Art.stroke(&context, ribs, Art.color(0x7E1E2A, 0.4), width: 0.8, cap: .butt)
        Art.stroke(&context, tops, Art.color(0xFFD0A8, 0.8), width: 0.8, cap: .butt)

        let crosses = Art.svg("M252,226 L286,255 M286,226 L252,255 M252,257 L286,285 M286,257 L252,285")
        Art.stroke(&context, crosses, Art.color(0xA42C2E), width: 2.2, cap: .butt)
        let crossLights = Art.svg("M252,225 L286,254 M252,256 L286,284")
        Art.stroke(&context, crossLights, Art.color(0xFFB088, 0.6), width: 0.6, cap: .butt)
        let ties = Art.svg("M252,224 L286,224 M252,256 L286,256")
        Art.stroke(&context, ties, Art.color(0xB8342C), width: 2.4, cap: .butt)
    }

    /// The whole tower: struts, the two legs and the pale pier it stands on in the water.
    static func goldenGateTower(_ context: inout GraphicsContext) {
        goldenGateStruts(&context)
        goldenGatePaintLeg(&context, 286)
        // The farther leg sits a little in the shade of the nearer one.
        Art.fill(&context, goldenGateLegPath(286), ArtStyle.coolShade.opacity(0.1))
        goldenGatePaintLeg(&context, 252)

        ArtStyle.contactShadow(&context, 273, 295, 36, 3, alpha: 0.28)
        let pier = Art.svg("M238,286 L300,286 L302,292 Q270,297 236,292 Z")
        let stone: [(Color, CGFloat)] = [
            (Art.color(0xF2E2CC), 0),
            (Art.color(0xCDBDB4), 0.5),
            (Art.color(0x9A8EA4), 1),
        ]
        fillHorizontal(&context, pier, stone, from: 238, to: 302)
        let pierTop = Art.line(238, 286.4, 300, 286.4)
        Art.stroke(&context, pierTop, Art.color(0xFFF6E4, 0.9), width: 0.9, cap: .butt)
    }

    /// The part of the viewer's-side leg that crosses in front of the road deck.
    static func goldenGateFrontLeg(_ context: inout GraphicsContext) {
        Art.clipped(&context, to: Art.rect(242, 198, 20, 50)) { g in
            goldenGatePaintLeg(&g, 252)
        }
    }

    // MARK: Deck

    /// The road deck from the headland to the right edge: its lit side with the truss, and
    /// a sliver of its dark underside.
    static func goldenGateDeck(_ context: inout GraphicsContext) {
        let x0: CGFloat = 40
        let x1: CGFloat = 456
        let s0: CGFloat = goldenGateScale(x0)
        let s1: CGFloat = goldenGateScale(x1)
        let top0: CGFloat = goldenGateDeckY(x0)
        let top1: CGFloat = goldenGateDeckY(x1)
        let side0: CGFloat = top0 + 9 * s0
        let side1: CGFloat = top1 + 9 * s1
        let under0: CGFloat = side0 + 4 * s0
        let under1: CGFloat = side1 + 4 * s1

        let underside = Art.polygon([pt(x0, side0), pt(x1, side1), pt(x1, under1), pt(x0, under0)])
        Art.fill(&context, underside, Art.color(0x6E1E34))
        let side = Art.polygon([pt(x0, top0), pt(x1, top1), pt(x1, side1), pt(x0, side0)])
        goldenGateSteel(&context, side, from: 40, to: 560)

        // The truss in the side of the deck.
        let box = CGRect(x: 40, y: 186, width: 416, height: 70)
        let rising = diagonals(in: box, spacing: 9, rising: true)
        let falling = diagonals(in: box, spacing: 9, rising: false)
        Art.clipped(&context, to: side) { g in
            Art.stroke(&g, rising, Art.color(0x7E1E2A, 0.3), width: 0.7, cap: .butt)
            Art.stroke(&g, falling, Art.color(0x7E1E2A, 0.3), width: 0.7, cap: .butt)
        }
        let rail = Art.line(x0, top0, x1, top1)
        Art.stroke(&context, rail, Art.color(0xFFC8A0, 0.9), width: 1.1, cap: .butt)
        let chord = Art.line(x0, side0, x1, side1)
        Art.stroke(&context, chord, Art.color(0x7E1E2A, 0.5), width: 0.8, cap: .butt)
    }

    // MARK: Cables

    /// A point on the curve of a cable, at `t` from 0 to 1.
    static func goldenGateCablePoint(_ p0: CGPoint, _ c1: CGPoint, _ c2: CGPoint, _ p3: CGPoint, _ t: CGFloat) -> CGPoint {
        let u: CGFloat = 1 - t
        let a: CGFloat = u * u * u
        let b: CGFloat = 3 * u * u * t
        let c: CGFloat = 3 * u * t * t
        let d: CGFloat = t * t * t
        let xNear: CGFloat = a * p0.x + b * c1.x
        let xFar: CGFloat = c * c2.x + d * p3.x
        let yNear: CGFloat = a * p0.y + b * c1.y
        let yFar: CGFloat = c * c2.y + d * p3.y
        return CGPoint(x: xNear + xFar, y: yNear + yFar)
    }

    /// One span of one main cable, with `hangers` thin cables dropping from it to the deck.
    static func goldenGateSpan(
        _ context: inout GraphicsContext,
        _ p0: CGPoint,
        _ c1: CGPoint,
        _ c2: CGPoint,
        _ p3: CGPoint,
        hangers: Int,
        width: CGFloat
    ) {
        var drops = Path()
        let count: Int = max(2, hangers)
        for index in 1..<count {
            let t: CGFloat = CGFloat(index) / CGFloat(count)
            let point: CGPoint = goldenGateCablePoint(p0, c1, c2, p3, t)
            let deckY: CGFloat = goldenGateDeckY(point.x)
            if point.y < deckY - 1 {
                drops.move(to: point)
                drops.addLine(to: pt(point.x, deckY))
            }
        }
        Art.stroke(&context, drops, Art.color(0xB8342C, 0.85), width: width * 0.3, cap: .butt)

        var cable = Path()
        cable.move(to: p0)
        cable.addCurve(to: p3, control1: c1, control2: c2)
        Art.stroke(&context, cable, Art.color(0xC0362C), width: width)
        Art.stroke(&context, cable, Art.color(0xFFA078, 0.6), width: width * 0.3)
    }

    /// The two main cables: over both tower tops, low over the road in the middle of the
    /// bridge, and down to the shores at either end. The far side's cable is drawn first.
    static func goldenGateCables(_ context: inout GraphicsContext) {
        // The far tower's two tops, from the near tower's (252, 46) and (286, 46).
        let nearA = pt(252, 46)
        let nearB = pt(286, 46)
        let farA = pt(119.1, 144.3)
        let farB = pt(137.7, 144.3)

        // Far side of the road.
        goldenGateSpan(&context, farB, pt(122, 192), pt(96, 230), pt(64, 246.5), hangers: 8, width: 1.3)
        goldenGateSpan(&context, nearB, pt(249, 250), pt(180, 276), farB, hangers: 24, width: 1.8)
        goldenGateSpan(&context, nearB, pt(330, 104), pt(400, 138), pt(470, 152), hangers: 12, width: 2.2)
        // The viewer's side of the road.
        goldenGateSpan(&context, farA, pt(104, 190), pt(80, 228), pt(50, 248.5), hangers: 8, width: 1.4)
        goldenGateSpan(&context, nearA, pt(215, 250), pt(160, 280), farA, hangers: 24, width: 2)
        goldenGateSpan(&context, nearA, pt(300, 112), pt(380, 150), pt(470, 168), hangers: 12, width: 2.4)
    }

    // MARK: The near plane

    /// The dark rocky shore in the bottom-right corner, with grass along its top.
    static func goldenGateShore(_ context: inout GraphicsContext) {
        let shore = Art.svg("M456,428 L236,428 C258,392 286,378 316,362 C346,346 372,338 400,320 C424,306 440,294 456,286 Z")
        let rock: [(Color, CGFloat)] = [
            (Art.color(0x44405C), 0),
            (Art.color(0x2A3048), 0.5),
            (Art.color(0x1C2A40), 1),
        ]
        fillVertical(&context, shore, rock, from: 286, to: unitHeight)
        model(&context, shore, light: 0.12, shade: 0.2)
        let facets = Art.svg("M330,360 L352,372 L344,396 M372,342 L396,352 L390,380 L416,392 M412,318 L432,330 L428,356 M300,378 L318,392")
        let clefts = Art.svg("M352,372 L378,366 M396,352 L420,344 M432,330 L456,326 M318,392 L344,396")
        let edge = Art.svg("M236,428 C258,392 286,378 316,362 C346,346 372,338 400,320 C424,306 440,294 456,286")
        Art.clipped(&context, to: shore) { g in
            Art.stroke(&g, facets, Art.color(0x7A7090, 0.4), width: 1.2)
            Art.stroke(&g, clefts, Art.color(0x141C30, 0.4), width: 1.2)
            Art.stroke(&g, edge, Art.color(0xF0C098, 0.55), width: 2.4)
        }

        // Tufts of grass along the top of the rock, some blades catching the light.
        let anchors: [(CGFloat, CGFloat)] = [
            (294, 374), (316, 362), (338, 351), (359, 342), (379, 332),
            (400, 320), (416, 311), (431, 301), (445, 293),
        ]
        var random = ArtRandom(83)
        var blades = Path()
        var litBlades = Path()
        for anchor in anchors {
            for index in 0..<7 {
                let lean: CGFloat = (CGFloat(index) - 3) * 0.22
                let angle: CGFloat = -1.57 + lean + random.next(in: -0.08...0.08)
                let length: CGFloat = random.next(in: 7...14)
                let bx: CGFloat = anchor.0 + CGFloat(index) * 1.6 - 5
                let tip = pt(bx + cos(angle) * length, anchor.1 + sin(angle) * length)
                if index % 2 == 0 {
                    blades.move(to: pt(bx, anchor.1 + 2))
                    blades.addLine(to: tip)
                } else {
                    litBlades.move(to: pt(bx, anchor.1 + 2))
                    litBlades.addLine(to: tip)
                }
            }
        }
        Art.stroke(&context, blades, Art.color(0x2C4A3C), width: 1.3)
        Art.stroke(&context, litBlades, Art.color(0x9CAA5C, 0.9), width: 0.9)
    }

    // MARK: Finish

    static func goldenGateFinish(_ context: inout GraphicsContext) {
        bottomFade(&context, 0x17405C, from: 300, alpha: 0.9)
        tooth(&context, seed: 829, light: 0.05, dark: 0.04)
        finish(&context, wash: 0.10, vignette: 0.10)
    }
}
