import SwiftUI
import OmramoCore

// Christ the Redeemer above Rio de Janeiro by day: our own drawing (no photograph, nothing
// traced). Seen from a little below: the steep forested granite peak of Corcovado rising in the
// middle and, on its top, the pale soapstone statue on its pedestal with its arms held level,
// drawn small and plain as a landmark and a feat of building. Beyond and below lie the blue
// bay, the rounded Sugarloaf rock and other humped hills, a pale city edge and beaches. Dark
// tropical leaves hang in at the top right as the near plane. Card background #134A4A.

extension LandmarkArt {
    /// christ-the-redeemer: the pale statue with level arms on its steep green peak, above the
    /// bay with its rounded hills, by day.
    static func paintChristRedeemer(_ context: inout GraphicsContext) {
        redeemerSky(&context)
        redeemerBay(&context)
        redeemerBayHills(&context)
        redeemerBayDetails(&context)
        redeemerCity(&context)
        redeemerLowHills(&context)
        redeemerPeak(&context)
        redeemerForest(&context)
        redeemerPlatform(&context)
        redeemerStatue(&context)
        redeemerLeaves(&context)
        redeemerFinish(&context)
    }

    // MARK: Small tools

    /// Three gradient stops at 0, `middle` and 1.
    static func redeemerStops(_ a: UInt32, _ b: UInt32, _ c: UInt32, middle: CGFloat = 0.5) -> [(Color, CGFloat)] {
        let stops: [(Color, CGFloat)] = [
            (Art.color(a), 0),
            (Art.color(b), middle),
            (Art.color(c), 1),
        ]
        return stops
    }

    /// The outline of the peak: steep on both sides, with a small level top for the statue.
    static func redeemerPeakPath() -> Path {
        Art.svg("M30,428 C84,372 124,318 152,262 C170,226 186,180 203,153 C212,149 224,149 232,153 C244,178 254,214 268,262 C286,318 336,380 404,428 Z")
    }

    // MARK: Sky

    static func redeemerSky(_ context: inout GraphicsContext) {
        let sky: [(Color, CGFloat)] = [
            (Art.color(0x4C9CD6), 0),
            (Art.color(0x9CD2EA), 0.3),
            (Art.color(0xFFE9C4), 0.58),
            (Art.color(0xFFE9C4), 1),
        ]
        backdrop(&context, sky)

        // Warm clouds: peach undersides, pale gold tops. None in the top-left corner.
        let clouds: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
            (26, 122, 124, 24), (270, 134, 136, 26), (96, 196, 104, 14), (262, 204, 128, 13), (-20, 176, 86, 12),
        ]
        var tops = Path()
        var unders = Path()
        for cloud in clouds {
            tops.addPath(cloudBand(cloud.0, cloud.1, width: cloud.2, height: cloud.3))
            let underX: CGFloat = cloud.0 + cloud.2 * 0.08
            let underY: CGFloat = cloud.1 + cloud.3 * 0.14
            unders.addPath(cloudBand(underX, underY, width: cloud.2 * 0.84, height: cloud.3 * 0.5))
        }
        Art.fill(&context, unders, Art.color(0xF0A886, 0.38))
        Art.fill(&context, tops, Art.color(0xFFF6E2, 0.86))
        horizon(&context, y: 240, rise: 64, hex: 0xFFDDB0, alpha: 0.36)
    }

    // MARK: The bay (the far plane)

    static func redeemerBay(_ context: inout GraphicsContext) {
        // The far shore across the bay: a long low line of hills, close in value to the sky.
        let farShore = Art.svg("M-24,242 L-24,227 C10,219 40,229 70,223 C110,215 140,227 180,225 C230,219 260,229 300,223 C340,215 380,227 420,221 L456,225 L456,242 Z")
        Art.fill(&context, farShore, Art.color(0x8FA9C8))

        let water = Art.rect(-24, 240, unitWidth + 48, 120)
        let blue: [(Color, CGFloat)] = [
            (Art.color(0xC6E6EA), 0),
            (Art.color(0x62B6D4), 0.28),
            (Art.color(0x2E8CBA), 0.7),
            (Art.color(0x1F6E9A), 1),
        ]
        fillVertical(&context, water, blue, from: 240, to: 360)
    }

    /// The rounded Sugarloaf rock with its lower neighbour on the right, and two humped hills
    /// on the left, all standing in the bay and veiled with the sky's own colour.
    static func redeemerBayHills(_ context: inout GraphicsContext) {
        let rock: [(Color, CGFloat)] = redeemerStops(0xC9B4A6, 0x8C9296, 0x4E8672, middle: 0.5)

        let urca = Art.svg("M272,270 C280,252 296,242 310,248 C318,252 322,262 326,270 Z")
        fillVertical(&context, urca, rock, from: 236, to: 270)
        model(&context, urca, light: 0.26, shade: 0.24)
        let sugarloaf = Art.svg("M308,270 C312,244 322,206 340,199 C358,196 368,230 378,270 Z")
        fillVertical(&context, sugarloaf, rock, from: 199, to: 270)
        model(&context, sugarloaf, light: 0.34, shade: 0.3, rim: 0.5)
        let streaks = Art.svg("M334,206 C330,226 328,246 326,264 M346,204 C350,226 354,246 358,262")
        Art.stroke(&context, streaks, Art.color(0x5E6480, 0.28), width: 1)

        let leftHills = Art.svg("M-24,270 C-6,240 26,228 50,246 C66,224 98,228 118,270 Z")
        fillVertical(&context, leftHills, rock, from: 224, to: 270)
        model(&context, leftHills, light: 0.28, shade: 0.26)
        let island = Art.svg("M402,270 C410,256 428,252 440,260 C448,264 452,268 456,270 Z")
        fillVertical(&context, island, rock, from: 250, to: 270)

        haze(&context, top: 190, bottom: 272, hex: 0xFFE9C4, alpha: 0.3)
        // The bright line where the rocks meet the water.
        let waterline = Art.svg("M-24,270.5 L118,270.5 M272,270.5 L378,270.5 M402,270.5 L456,270.5")
        Art.stroke(&context, waterline, Art.color(0xF4FBFF, 0.7), width: 0.9)
    }

    /// Glints on the bay and a few tiny far sails, for the scale.
    static func redeemerBayDetails(_ context: inout GraphicsContext) {
        let far = CGRect(x: 0, y: 244, width: 432, height: 22)
        ripples(&context, in: far, count: 22, seed: 31, color: Art.color(0xFFFFFF, 0.5), width: 0.6, length: 6...20)
        let near = CGRect(x: 0, y: 270, width: 432, height: 34)
        ripples(&context, in: near, count: 26, seed: 47, color: Art.color(0xDFF4FA, 0.4), width: 0.9, length: 8...26)
        ripples(&context, in: near, count: 14, seed: 59, color: Art.color(0x1C5E8C, 0.3), width: 0.9, length: 10...28)

        let sails: [(CGFloat, CGFloat, CGFloat)] = [(136, 262, 1), (296, 280, 1.3), (398, 284, 1.1), (84, 282, 1.2)]
        var cloth = Path()
        var hulls = Path()
        for sail in sails {
            let s: CGFloat = sail.2
            let mastTop: CGFloat = sail.1 - 6 * s
            let foot: CGFloat = sail.1 - 0.8 * s
            let clew: CGFloat = sail.0 + 3.2 * s
            cloth.move(to: pt(sail.0, mastTop))
            cloth.addLine(to: pt(clew, foot))
            cloth.addLine(to: pt(sail.0, foot))
            cloth.closeSubpath()
            let hullX: CGFloat = sail.0 - 2.4 * s
            let hullY: CGFloat = sail.1 - 0.6 * s
            hulls.addRect(CGRect(x: hullX, y: hullY, width: 6 * s, height: 1.2 * s))
        }
        Art.fill(&context, cloth, Art.color(0xFFFDF4))
        Art.fill(&context, hulls, Art.color(0x2A4A70, 0.8))
    }

    // MARK: The city edge and the low hills

    static func redeemerCity(_ context: inout GraphicsContext) {
        var land = Path()
        land.addPath(Art.svg("M-24,428 L-24,294 C20,286 60,298 96,290 C130,284 160,298 196,302 L196,428 Z"))
        land.addPath(Art.svg("M456,428 L456,288 C420,282 390,296 350,292 C310,288 280,300 244,304 L244,428 Z"))
        let pale: [(Color, CGFloat)] = redeemerStops(0xF6E8D2, 0xD8C8B6, 0x7FA08C, middle: 0.35)
        fillVertical(&context, land, pale, from: 286, to: 380)

        // The beaches: a few light strokes of sand, each with a thin white line of surf.
        let beaches = Art.svg("M-24,294 C20,286 60,298 96,290 C130,284 160,298 196,302 M456,288 C420,282 390,296 350,292 C310,288 280,300 244,304")
        Art.stroke(&context, beaches, Art.color(0xFFF2CC), width: 2.6)
        let surf = Art.svg("M-24,291.6 C20,283.6 60,295.6 96,287.6 C130,281.6 160,295.6 196,299.6 M456,285.6 C420,279.6 390,293.6 350,289.6 C310,285.6 280,297.6 244,301.6")
        Art.stroke(&context, surf, Art.color(0xFFFFFF, 0.8), width: 0.8)

        // The pale city: small blocks, each lit on the left and shaded on the right.
        var random = ArtRandom(389)
        var lit = Path()
        var shaded = Path()
        for index in 0..<54 {
            let leftSide: Bool = index % 2 == 0
            let spanStart: CGFloat = leftSide ? -10 : 272
            let x: CGFloat = spanStart + random.next(in: 0...160)
            let y: CGFloat = 302 + random.next(in: 0...34)
            let w: CGFloat = random.next(in: 3...6.5)
            let h: CGFloat = random.next(in: 3...9)
            lit.addRect(CGRect(x: x, y: y - h, width: w, height: h))
            shaded.addRect(CGRect(x: x + w * 0.6, y: y - h, width: w * 0.4, height: h))
        }
        Art.fill(&context, lit, Art.color(0xFFF9EC, 0.9))
        Art.fill(&context, shaded, Art.color(0x8C8AB0, 0.55))
    }

    /// The green humps that rise out of the city on either side, leading down to the card.
    static func redeemerLowHills(_ context: inout GraphicsContext) {
        let green: [(Color, CGFloat)] = redeemerStops(0x5EA862, 0x2C7450, 0x134A4A, middle: 0.4)
        let left = Art.svg("M-24,428 L-24,346 C-4,322 30,314 58,334 C78,318 108,324 130,352 C146,372 160,400 170,428 Z")
        fillVertical(&context, left, green, from: 316, to: 404)
        model(&context, left, light: 0.26, shade: 0.24)
        let right = Art.svg("M456,428 L456,338 C436,318 404,316 382,336 C360,322 330,330 312,356 C298,378 286,404 280,428 Z")
        fillVertical(&context, right, green, from: 316, to: 404)
        model(&context, right, light: 0.2, shade: 0.28)
        let crowns = canopy(from: -24, to: 456, baseY: 352, height: 12, bump: 16, depth: 4, seed: 83)
        var both = Path()
        both.addPath(left)
        both.addPath(right)
        Art.clipped(&context, to: both) { g in
            Art.fill(&g, crowns, Art.color(0x9AD070, 0.24))
        }
    }

    // MARK: The peak

    static func redeemerPeak(_ context: inout GraphicsContext) {
        let peak = redeemerPeakPath()
        let green: [(Color, CGFloat)] = [
            (Art.color(0x6CB466), 0),
            (Art.color(0x3A8656), 0.3),
            (Art.color(0x1F5E4C), 0.7),
            (Art.color(0x134A4A), 1),
        ]
        fillVertical(&context, peak, green, from: 150, to: unitHeight)

        // The bare granite under the top, and the sheer face that runs down the right side.
        let cap = Art.svg("M150,146 L290,146 L290,236 C270,252 256,232 244,220 C234,208 224,228 214,216 C202,204 192,224 178,234 L150,244 Z")
        let face = Art.svg("M238,160 L300,160 L300,340 C282,312 266,286 256,254 C250,232 244,200 238,160 Z")
        let granite: [(Color, CGFloat)] = redeemerStops(0xE2CCAE, 0xB09C90, 0x7A7290, middle: 0.45)
        let clefts = Art.svg("M208,160 C204,178 200,196 192,218 M218,156 C218,176 214,196 216,212 M228,160 C232,180 236,200 242,218 M250,206 C256,236 264,262 276,290 M258,236 C262,256 270,276 282,300")
        let ledges = Art.svg("M196,186 C206,182 216,188 228,184 M188,206 C200,202 210,208 222,204 M240,196 C246,194 250,198 254,196")
        Art.clipped(&context, to: peak) { g in
            LandmarkArt.fillHorizontal(&g, cap, granite, from: 176, to: 262)
            Art.fill(&g, face, Art.color(0x8A8298, 0.85))
            Art.stroke(&g, clefts, Art.color(0x5E5878, 0.4), width: 1)
            Art.stroke(&g, ledges, Art.color(0xFFF0D2, 0.5), width: 0.9)
        }
        model(&context, peak, light: 0.26, shade: 0.28, rim: 0.4)
    }

    /// The forest on the peak: rows of crowns, lit above and shaded beneath, kept inside the
    /// outline of the peak.
    static func redeemerForest(_ context: inout GraphicsContext) {
        let peak = redeemerPeakPath()
        let rows: [(CGFloat, UInt32)] = [(248, 11), (276, 13), (304, 17), (332, 19), (360, 23)]
        Art.clipped(&context, to: peak) { g in
            for row in rows {
                let shade = LandmarkArt.canopy(from: 20, to: 420, baseY: row.0 + 9, height: 13, bump: 20, depth: 6, seed: row.1 &+ 100)
                Art.fill(&g, shade, Art.color(0x0F3E44, 0.26))
                let lit = LandmarkArt.canopy(from: 20, to: 420, baseY: row.0, height: 13, bump: 20, depth: 3, seed: row.1)
                Art.fill(&g, lit, Art.color(0x9AD070, 0.22))
            }
            // Forest climbing the left of the granite, and a few trees on its ledges.
            let climb = LandmarkArt.canopy(from: 150, to: 216, baseY: 232, height: 16, bump: 12, depth: 30, seed: 29)
            Art.fill(&g, climb, Art.color(0x3E8A56))
            let climbLit = LandmarkArt.canopy(from: 150, to: 216, baseY: 230, height: 10, bump: 9, depth: 1, seed: 37)
            Art.fill(&g, climbLit, Art.color(0xA6D878, 0.35))
            // The sun on the left flank, and the deep shade of the right one.
            let warm: [(Color, CGFloat)] = [
                (Art.color(0xFFE6A0, 0.24), 0),
                (Art.color(0xFFE6A0, 0), 0.5),
                (ArtStyle.coolShade.opacity(0.24), 1),
            ]
            LandmarkArt.fillHorizontal(&g, Art.rect(20, 240, 400, 190), warm, from: 90, to: 350)
        }
    }

    // MARK: The top of the peak

    /// The viewing platform on the top, its rail, and a few tiny visitors for the scale.
    static func redeemerPlatform(_ context: inout GraphicsContext) {
        let slab = Art.rect(198, 148, 40, 5.5, radius: 1.2)
        let stone: [(Color, CGFloat)] = redeemerStops(0xF2E8D4, 0xD2C8BA, 0x9C98AE, middle: 0.45)
        fillHorizontal(&context, slab, stone, from: 198, to: 238)
        Art.fill(&context, Art.rect(199, 151.6, 38, 1.9), ArtStyle.coolShade.opacity(0.2))

        var rail = Path()
        rail.move(to: pt(198.5, 144.6))
        rail.addLine(to: pt(209, 144.6))
        rail.move(to: pt(227, 144.6))
        rail.addLine(to: pt(237.5, 144.6))
        let posts: [CGFloat] = [198.5, 202, 205.5, 209, 227, 230.5, 234, 237.5]
        for post in posts {
            rail.move(to: pt(post, 144.6))
            rail.addLine(to: pt(post, 148))
        }
        Art.stroke(&context, rail, Art.color(0xEDE4D2, 0.9), width: 0.5, cap: .butt)

        // Visitors: a coat and a head each, no more.
        let people: [(CGFloat, UInt32)] = [(200.6, 0xC8503E), (204.2, 0x2F5E8A), (229.4, 0xE2A63C), (232.6, 0x7A4E8A), (235.8, 0x2F7A5E)]
        var heads = Path()
        for person in people {
            let coat = Art.rect(person.0 - 0.8, 144.2, 1.6, 3.8, radius: 0.6)
            Art.fill(&context, coat, Art.color(person.1))
            heads.addEllipse(in: CGRect(x: person.0 - 0.8, y: 142.5, width: 1.6, height: 1.7))
        }
        Art.fill(&context, heads, Art.color(0x8A5A44))
    }

    /// The statue: a plain robed figure with its arms stretched level, on a tall pedestal, in
    /// pale soapstone. No face is drawn, and nothing shines behind it.
    static func redeemerStatue(_ context: inout GraphicsContext) {
        let soapstone: [(Color, CGFloat)] = redeemerStops(0xF6F2E4, 0xDAD9D0, 0xA4A8BC, middle: 0.5)

        // The pedestal, a little wider at its foot, with a plain cap.
        let pedestal = Art.polygon([pt(209.6, 148), pt(211, 134), pt(225.4, 134), pt(226.8, 148)])
        let base: [(Color, CGFloat)] = redeemerStops(0xE6DECE, 0xC4BEB4, 0x8E8CA6, middle: 0.45)
        fillHorizontal(&context, pedestal, base, from: 209, to: 227)
        let cap = Art.rect(210, 132.8, 16.4, 2.2, radius: 0.6)
        fillHorizontal(&context, cap, soapstone, from: 210, to: 226.4)
        Art.fill(&context, Art.rect(211, 135, 14.4, 1.6), ArtStyle.coolShade.opacity(0.2))
        Art.fill(&context, Art.rect(215.4, 138, 5.4, 10, radius: 2.4), Art.color(0x5E5A7A, 0.5))

        // The figure: the long robe, the two level arms with their hanging sleeves, the head.
        var figure = Path()
        figure.addPath(Art.svg("M213,133 C213.6,118 213.4,104 213,92 C213,88 215,86.4 218.2,86.4 C221.4,86.4 223.4,88 223.4,92 C223,104 222.8,118 223.6,133 Z"))
        figure.addPath(Art.svg("M215,87 L196,88 L189.6,88.6 Q188,89.6 189.6,90.6 L196,91.4 C202,92.4 207,96 213.4,101 L214,92 Z"))
        figure.addPath(Art.svg("M221.4,87 L240.4,88 L246.8,88.6 Q248.4,89.6 246.8,90.6 L240.4,91.4 C234.4,92.4 229.4,96 223,101 L222.4,92 Z"))
        figure.addRect(CGRect(x: 216.8, y: 83, width: 2.8, height: 4.4))
        figure.addEllipse(in: CGRect(x: 214.9, y: 75.6, width: 6.6, height: 8.6))
        fillHorizontal(&context, figure, soapstone, from: 190, to: 248)
        model(&context, figure, light: 0.2, shade: 0.16)

        // The shade under the arms and down the right of the robe; the light along the top.
        let underArms = Art.svg("M196,91.4 C202,92.4 207,96 213.4,101 M240.4,91.4 C234.4,92.4 229.4,96 223,101")
        Art.stroke(&context, underArms, Art.color(0x8088A4, 0.6), width: 0.8)
        let robeShade = Art.svg("M221.2,92 C221,104 220.8,118 221.6,133 L223.6,133 C222.8,118 223,104 223.4,92 Z")
        Art.fill(&context, robeShade, ArtStyle.coolShade.opacity(0.18))
        let folds = Art.svg("M215.6,97 C215.4,110 215.2,122 214.8,132 M218,100 C218.2,112 218.2,124 218.6,132 M220.2,99 C220.2,110 220.4,122 220.8,131")
        Art.stroke(&context, folds, Art.color(0x8A90AA, 0.5), width: 0.5)
        let topLight = Art.svg("M190,88.5 L196,87.9 L215,86.9 M221.6,86.9 L240.4,87.9 L246.6,88.5")
        Art.stroke(&context, topLight, Art.color(0xFFFBEE, 0.9), width: 0.7)
        Art.fill(&context, Art.ellipse(217, 78.6, 1.3, 1.9), Art.color(0xFFFBEE, 0.6))
    }

    // MARK: The near plane

    /// Dark tropical leaves hanging in at the top right: the shared spray and three long
    /// blades, each with a lit midrib.
    static func redeemerLeaves(_ context: inout GraphicsContext) {
        let blades: [(CGFloat, CGFloat, CGFloat, CGFloat, CGFloat)] = [
            (452, 26, 84, 13, 2.96), (448, 66, 66, 12, 2.74), (444, 98, 52, 10, 2.42),
        ]
        var dark = Path()
        var ribs = Path()
        for blade in blades {
            dark.addPath(leaf(blade.0, blade.1, length: blade.2, width: blade.3, angle: blade.4))
            let dx: CGFloat = cos(blade.4) * blade.2 * 0.86
            let dy: CGFloat = sin(blade.4) * blade.2 * 0.86
            ribs.move(to: pt(blade.0, blade.1))
            ribs.addLine(to: pt(blade.0 + dx, blade.1 + dy))
        }
        Art.fill(&context, dark, Art.color(0x0E3B36))
        model(&context, dark, light: 0.16, shade: 0.2)
        Art.stroke(&context, ribs, Art.color(0x8FCB6A, 0.6), width: 0.9)
        cornerSpray(&context, seed: 211, dark: Art.color(0x0B332F), lit: Art.color(0x8FCB6A, 0.7))
    }

    // MARK: Finish

    static func redeemerFinish(_ context: inout GraphicsContext) {
        bottomFade(&context, 0x134A4A, from: 300, alpha: 0.9)
        tooth(&context, seed: 859, light: 0.05, dark: 0.04)
        finish(&context, wash: 0.10, vignette: 0.10)
    }
}
