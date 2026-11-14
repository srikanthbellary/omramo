import SwiftUI
import Foundation
import OmramoCore

// The folded picture bands of the Anansi story (432 units wide, about 240 to 520 high): each
// is its own composition for the tall-ish band, not a crop of the wide scene.
//
// How a band answers its height: the sky, the far plane, the tall trunks and the canopy are
// drawn in real units across the whole width; the subject cluster is drawn in a small design
// space (432 wide, ground content down to y 396) that is scaled by `bandScale` about the
// middle of the bottom edge, so the people keep their relations at every height. The last
// 24 units belong to the wave edge the caller cuts: nothing essential sits there.
// The main face stays inside the middle 60% of the width (x 86…346) and out of the two top
// corners, where the back button and the "Aa" pill sit.

extension AnansiArt {
    // MARK: Band space

    /// The scale of the subject cluster: 1 at a 420-unit band, 0.6 at 250 and below, 1.2 at 504 and above.
    static func bandScale(_ size: CGSize) -> CGFloat {
        max(0.6, min(1.2, size.height / 420))
    }

    /// The real y of the design-space y of the subject cluster.
    static func bandY(_ size: CGSize, _ y: CGFloat) -> CGFloat {
        size.height - 24 - (396 - y) * bandScale(size)
    }

    /// Draws `body` in the design space of the subject cluster.
    static func bandStage(
        _ context: inout GraphicsContext,
        _ size: CGSize,
        _ body: (inout GraphicsContext) -> Void
    ) {
        let u: CGFloat = bandScale(size)
        let ox: CGFloat = 216 * (1 - u)
        let oy: CGFloat = size.height - 24 - 396 * u
        Art.group(&context, x: ox, y: oy, scale: u, body)
    }

    /// Sky, stars, the far ridge, far umbrella trees, the ember band and the ground of a band,
    /// in real units. `horizon` is the design-space y of the horizon line.
    static func bandBackdrop(
        _ context: inout GraphicsContext,
        _ size: CGSize,
        _ colors: [Color],
        horizon: CGFloat,
        seed: UInt32
    ) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let u: CGFloat = bandScale(size)
        let hz: CGFloat = bandY(size, horizon)

        sky(&context, w, h, colors, horizon: hz, spread: 0.8 * u)
        let starH: CGFloat = max(40, hz - 110 * u)
        stars(&context, 30, seed: seed, in: CGRect(x: 0, y: 0, width: w, height: starH))

        // Far plane: a ridge of forest hills, close to the sky's own value, and far trees.
        var ridge = Path()
        ridge.move(to: pt(0, hz - 16 * u))
        ridge.addCurve(to: pt(w * 0.5, hz - 22 * u), control1: pt(w * 0.16, hz - 40 * u), control2: pt(w * 0.34, hz - 6 * u))
        ridge.addCurve(to: pt(w, hz - 20 * u), control1: pt(w * 0.68, hz - 40 * u), control2: pt(w * 0.84, hz - 44 * u))
        ridge.addLine(to: pt(w, hz + 6))
        ridge.addLine(to: pt(0, hz + 6))
        ridge.closeSubpath()
        Art.fill(&context, ridge, Art.color(0x5E2F7A, 0.5))

        let far: [(CGFloat, CGFloat)] = [(14, 0.42), (58, 0.3), (112, 0.36), (330, 0.34), (384, 0.5), (424, 0.38)]
        for (i, item) in far.enumerated() {
            let tone = i % 2 == 1 ? Art.color(0x3A2466) : Art.color(0x472C73)
            let rise: CGFloat = (120 * item.1 + 30) * u
            umbrellaTree(&context, item.0, hz + 4, rise, item.1 * 0.8 * u, tone, seed: UInt32(50 + i))
        }
        ArtStyle.horizonGlow(&context, width: w, y: hz, rise: 110 * u, color: ArtStyle.anansi.glowColor, alpha: 0.42)

        var ground = Path()
        ground.move(to: pt(0, hz))
        ground.addCurve(to: pt(w, hz - 4 * u), control1: pt(w * 0.3, hz - 10 * u), control2: pt(w * 0.7, hz + 8 * u))
        ground.addLine(to: pt(w, h))
        ground.addLine(to: pt(0, h))
        ground.closeSubpath()
        let soil: [(Color, CGFloat)] = [
            (Art.color(0x3A1F58), 0), (Art.color(0x24143F), 0.4), (Art.color(0x160C2C), 1),
        ]
        Art.fillLinear(&context, ground, soil, from: pt(0, hz - 8), to: pt(0, h))
    }

    /// The plain dark strip along the bottom of a band, for the wave edge the caller cuts.
    static func bandFloor(_ context: inout GraphicsContext, _ size: CGSize) {
        let floorColor = Art.color(0x140B2A)
        let top: CGFloat = max(size.height - 22, 1)
        let fade: [(Color, CGFloat)] = [(floorColor.opacity(0), 0), (floorColor, 1)]
        Art.fillLinear(&context, Art.rect(0, top - 10, size.width, 10), fade, from: pt(0, top - 10), to: pt(0, top))
        Art.fill(&context, Art.rect(0, top, size.width, 22), floorColor)
    }

    /// The near ground of the subject cluster, in its design space: wide enough to reach both
    /// edges at every scale.
    static func bandGround(_ g: inout GraphicsContext, top: CGFloat) {
        var lip = Path()
        lip.move(to: pt(-220, top + 8))
        lip.addCurve(to: pt(160, top), control1: pt(-80, top - 4), control2: pt(60, top + 6))
        lip.addCurve(to: pt(440, top + 2), control1: pt(260, top - 6), control2: pt(340, top + 8))
        lip.addCurve(to: pt(652, top), control1: pt(520, top - 3), control2: pt(580, top + 4))
        var ground = lip
        ground.addLine(to: pt(652, 470))
        ground.addLine(to: pt(-220, 470))
        ground.closeSubpath()
        let soil: [(Color, CGFloat)] = [(Art.color(0x26153F), 0), (Art.color(0x180D30), 0.5), (Art.color(0x140B2A), 1)]
        Art.fillLinear(&g, ground, soil, from: pt(0, top - 6), to: pt(0, 420))
        Art.stroke(&g, lip, ArtStyle.warmLight.opacity(0.1), width: 1.2)
    }

    // MARK: - Band: the village at dusk

    /// Father Anansi in the middle, speaking; the listeners on his left; his lit house on his
    /// right; the far forest and the early moon behind.
    static func villageBand(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let u: CGFloat = bandScale(size)
        let hz: CGFloat = bandY(size, 322)

        bandBackdrop(&context, size, duskSky, horizon: 322, seed: 5)
        Art.group(&context, x: w * 0.6, y: hz - 6, scaleX: 1.6) { c in
            Art.glow(&c, 0, 0, 130 * u, Art.color(0xFFB45A), alpha: 0.3)
        }

        bandStage(&context, size) { g in
            // The one light: an early moon, high on the left.
            moon(&g, 118, 112, 24, alpha: 0.94)

            // Middle plane: a tall umbrella tree behind the house, a neighbour's house.
            umbrellaTree(&g, 440, 362, 262, 1.3, Art.color(0x22133F), seed: 73, lit: 0.2)
            house(&g, 18, 342, 1.1, lit: 0.55)
            bandGround(&g, top: 346)

            house(&g, 330, 372, 1.9, lit: 1)
            // Lamplight from the doorway across the ground.
            Art.group(&g, x: 296, y: 379, scale: 0.3, scaleX: 10) { p in
                Art.glow(&p, 0, 0, 42, Art.color(0xFFB84D), alpha: 0.34)
            }
            grass(&g, 196, 392, 1.3, seed: 41)
            grass(&g, 262, 388, 1.1, seed: 43)

            villager(&g, 70, 374, 2.5, seated: false, cloth: Art.color(0x4B2C86))
            villager(&g, 114, 378, 2.5, seated: true, cloth: ArtStyle.anansi.midColor)
            villager(&g, 152, 382, 1.9, seated: true, cloth: Art.color(0x2E3A6B))

            Art.glow(&g, 226, 300, 86, Art.color(0xFFC46A), alpha: 0.22)
            anansiStanding(&g, 222, 376, 1.26, withPot: false, gesture: true)

            // Near plane: leaves in the two bottom corners.
            leaf(&g, -30, 424, 110, -42, dark: true)
            leaf(&g, -4, 432, 84, -76, dark: false)
            leaf(&g, 456, 420, 110, -140, dark: false)
        }

        // Leaves overhead, top right.
        let overhead: [(CGFloat, CGFloat, CGFloat)] = [(410, 0, 70 * u), (330, -14, 42 * u)]
        nightCanopy(&context, overhead, seed: 21, palette: canopyPalette)

        fireflies(&context, 9, seed: 29, in: CGRect(x: 40, y: hz - 150 * u, width: w - 80, height: 130 * u))
        bandFloor(&context, size)
        finishPicture(&context, size)
    }

    // MARK: - Band: the forest path

    /// Father Anansi on the path with the pot round his neck, between tall trunks; Kweku Tsin
    /// in the leaves at the lower left; the moon through the trees.
    static func forestBand(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let u: CGFloat = bandScale(size)
        let hz: CGFloat = bandY(size, 326)

        bandBackdrop(&context, size, duskSky, horizon: 326, seed: 5)
        Art.group(&context, x: w * 0.55, y: h * 0.46, scaleX: 0.8) { c in
            Art.glow(&c, 0, 0, h * 0.5, Art.color(0x6A3A9A), alpha: 0.35)
        }
        bandStage(&context, size) { g in
            moon(&g, 122, 118, 28)
        }

        // Far trunks, then a thin mist in front of them.
        let farBase: CGFloat = bandY(size, 336)
        let farTrunks: [(CGFloat, CGFloat)] = [(150, 11), (196, 8), (296, 13), (346, 9)]
        for trunk in farTrunks {
            forestTrunk(&context, trunk.0, trunk.1 * u, farBase, dark: Art.color(0x1E1248), light: Art.color(0x33206A), rim: 0)
        }
        let mistTop: CGFloat = hz - 200 * u
        let mist: [(Color, CGFloat)] = [(Art.color(0x7A4A9A, 0), 0), (Art.color(0x7A4A9A, 0.16), 1)]
        Art.fillLinear(&context, Art.rect(0, mistTop, w, hz - mistTop), mist, from: pt(0, mistTop), to: pt(0, hz))

        bandStage(&context, size) { g in
            bandGround(&g, top: 350)
            // The path he takes.
            let trail = Art.svg("M150,470 C190,410 216,376 228,354 L252,354 C270,376 300,410 356,470Z")
            let trailTone: [(Color, CGFloat)] = [(Art.color(0x5A3470, 0.75), 0), (Art.color(0x3E2658, 0.7), 1)]
            Art.fillLinear(&g, trail, trailTone, from: pt(0, 354), to: pt(0, 420))
        }

        // Near trunks at the two edges, lit on their left.
        forestTrunk(&context, 16, 40 * u, h, dark: Art.color(0x150A2C), light: Art.color(0x4A2C5E), rim: 0.5)
        forestTrunk(&context, 412, 50 * u, h, dark: Art.color(0x150A2C), light: Art.color(0x4A2C5E), rim: 0.4)
        forestTrunk(&context, 356, 18 * u, bandY(size, 380), dark: Art.color(0x180C30), light: Art.color(0x34205A), rim: 0.25)

        // Vines and the canopy.
        let vineColor = Art.color(0x14234A)
        let vineLeaf = Art.color(0x2C6A7C)
        vine(&context, 86, 40 * u, 120 * u, 10, vineColor, leafColor: vineLeaf)
        vine(&context, 318, 50 * u, 150 * u, -10, vineColor, leafColor: vineLeaf)
        let blobs: [(CGFloat, CGFloat, CGFloat)] = [
            (60, 4, 90 * u), (216, -12, 100 * u), (372, 6, 96 * u), (432, 60 * u, 40 * u), (0, 56 * u, 34 * u),
        ]
        nightCanopy(&context, blobs, seed: 14, palette: canopyPalette)

        bandStage(&context, size) { g in
            // Father Anansi with the pot hung round his neck.
            Art.glow(&g, 240, 298, 104, Art.color(0xFFC94D), alpha: 0.3)
            anansiStanding(&g, 240, 378, 1.3, withPot: true, gesture: false)
            let sparks: [(CGFloat, CGFloat, CGFloat, Int)] = [
                (192, 226, 1, 1), (286, 200, 0.9, 2), (212, 178, 0.8, 2), (294, 258, 1.1, 0),
            ]
            motes(&g, sparks)

            // Kweku Tsin following, hidden in the leaves.
            kwekuInLeaves(&g, 96, 318, 0.9, lookX: 2.6, lookY: -0.8, mouthOpen: false)
            leaf(&g, 448, 424, 150, -118, dark: true)
            leaf(&g, 430, 432, 110, -150, dark: false)
        }

        fireflies(&context, 14, seed: 29, in: CGRect(x: 50, y: h * 0.3, width: w - 100, height: max(40, h * 0.5)))
        bandFloor(&context, size)
        finishPicture(&context, size)
    }

    // MARK: - Bands: the climb, and wisdom spreading

    /// The great tree of the two tree bands, in the design space of the subject cluster: the
    /// trunk (x 240…306) from far above the top edge, its buttress flare, two boughs. Lit
    /// from the upper left.
    static func bandTree(_ g: inout GraphicsContext) {
        var trunk = Path()
        trunk.move(to: pt(240, -220))
        trunk.addCurve(to: pt(237, 290), control1: pt(245, -40), control2: pt(242, 150))
        trunk.addCurve(to: pt(186, 470), control1: pt(234, 352), control2: pt(212, 420))
        trunk.addLine(to: pt(372, 470))
        trunk.addCurve(to: pt(308, 290), control1: pt(338, 420), control2: pt(312, 352))
        trunk.addCurve(to: pt(306, -220), control1: pt(303, 150), control2: pt(303, -40))
        trunk.closeSubpath()
        let bark: [(Color, CGFloat)] = [
            (Art.color(0x8A6282), 0), (Art.color(0x4A2C5E), 0.35), (Art.color(0x22123F), 0.7), (Art.color(0x150A2C), 1),
        ]
        Art.fillLinear(&g, trunk, bark, from: pt(190, 0), to: pt(314, 0))

        Art.fill(
            &g,
            Art.svg("M237,290 C231,352 210,410 176,470 L222,470 C242,414 250,356 252,310Z"),
            ArtStyle.warmLight.opacity(0.2)
        )
        Art.fill(
            &g,
            Art.svg("M308,290 C312,352 338,414 380,470 L346,470 C322,414 304,360 300,318Z"),
            Art.color(0x120A26, 0.6)
        )
        Art.stroke(
            &g,
            Art.svg("M266,470 C268,400 266,340 268,306 M284,470 C282,404 284,356 282,318"),
            Art.color(0x1B0F33, 0.5), width: ArtStyle.contourLine
        )
        Art.stroke(
            &g,
            Art.svg("M254,-200 C258,0 252,160 252,280 M272,-206 C276,0 270,150 272,276 M290,-210 C294,0 288,160 292,286"),
            Art.color(0x1B0F33, 0.4), width: ArtStyle.detailLine
        )
        Art.stroke(&g, Art.svg("M241,-210 C246,-40 243,150 238,290"), Art.color(0xFFE9D2, 0.62), width: ArtStyle.contourLine)
        Art.stroke(&g, Art.svg("M238,290 C235,352 213,420 188,466"), Art.color(0xFFE9D2, 0.32), width: ArtStyle.contourLine)

        let leftBough = Art.svg("M244,92 C200,84 150,66 96,44 C80,38 70,34 56,28 L60,20 C90,28 140,48 180,58 C210,66 230,68 246,66Z")
        Art.fill(&g, leftBough, Art.color(0x2E1A4C))
        Art.stroke(
            &g,
            Art.svg("M60,20 C90,28 140,48 180,58 C210,66 230,68 246,66"),
            ArtStyle.warmLight.opacity(0.3), width: ArtStyle.detailLine
        )
        Art.fill(
            &g,
            Art.svg("M304,110 C340,96 400,88 660,56 L660,44 C400,74 345,76 304,86Z"),
            Art.color(0x1B0F33)
        )
    }

    /// The web under the left bough, across the moon, and the small spider on its thread.
    static func bandWeb(_ g: inout GraphicsContext) {
        spiderWeb(&g, 240, 96, 118, 2.5, 3.25)
        Art.stroke(&g, Art.line(126, 54, 126, 138), ArtStyle.warmLight.opacity(0.6), width: 0.7, cap: .butt)
        spider(&g, 126, 142, 1)
    }

    /// The canopy across the top of a tree band, in real units.
    static func bandCanopy(_ context: inout GraphicsContext, _ size: CGSize) {
        let u: CGFloat = bandScale(size)
        let blobs: [(CGFloat, CGFloat, CGFloat)] = [
            (250, 4, 120 * u), (400, 24, 80 * u), (96, 0, 76 * u), (0, 30 * u, 44 * u), (432, 84 * u, 40 * u),
        ]
        nightCanopy(&context, blobs, seed: 14, palette: canopyPalette)
    }

    /// Father Anansi on the lit side of the great tree with the pot, the big moon on his upper
    /// left, Kweku Tsin watching from the leaves below, the far-off village on the right.
    static func climbBand(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height

        bandBackdrop(&context, size, duskSky, horizon: 326, seed: 5)
        Art.group(&context, x: w * 0.5, y: h * 0.46, scaleX: 0.8) { c in
            Art.glow(&c, 0, 0, h * 0.5, Art.color(0x6A3A9A), alpha: 0.4)
        }

        bandStage(&context, size) { g in
            // The one light: the big moon, upper left of the climber.
            moon(&g, 112, 122, 34)

            // The far-off village.
            hut(&g, 366, 330, 1.2, peak: 32)
            hut(&g, 398, 332, 0.9)
            hut(&g, 426, 331, 1.1, peak: 30)
            bandGround(&g, top: 352)

            bandTree(&g)
            bandWeb(&g)
        }
        bandCanopy(&context, size)

        bandStage(&context, size) { g in
            // Father Anansi and the pot.
            Art.glow(&g, 233, 190, 104, Art.color(0xFFC94D), alpha: 0.3)
            anansiClimbing(&g, 199, 236, 1.22)
            let sparks: [(CGFloat, CGFloat, CGFloat, Int)] = [
                (158, 212, 1, 1), (136, 178, 1.2, 0), (143, 248, 0.8, 2), (128, 272, 1.1, 1),
                (162, 284, 0.9, 2), (118, 220, 0.8, 2),
            ]
            motes(&g, sparks)

            // Kweku Tsin watching from the leaves.
            kwekuInLeaves(&g, 92, 318, 0.9, lookX: 2.6, lookY: -2.6, mouthOpen: false)
            leaf(&g, 448, 424, 150, -118, dark: true)
            leaf(&g, 430, 432, 110, -150, dark: false)
        }

        fireflies(&context, 12, seed: 29, in: CGRect(x: 40, y: h * 0.4, width: w - 80, height: max(40, h * 0.42)))
        bandFloor(&context, size)
        finishPicture(&context, size)
    }

    /// The pot broken on the rock at the foot of the tree, wisdom streaming away in three
    /// directions; Father Anansi looking down from the trunk; Kweku Tsin below, looking up.
    static func wisdomBand(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let hz: CGFloat = bandY(size, 326)
        var random = ArtRandom(77)

        bandBackdrop(&context, size, dawnSky, horizon: 326, seed: 5)
        Art.group(&context, x: w * 0.5, y: h * 0.46, scaleX: 0.8) { c in
            Art.glow(&c, 0, 0, h * 0.5, Art.color(0x7A4AAA), alpha: 0.35)
        }

        // Wisdom drifting across the sky.
        let skySpan: CGFloat = max(30, hz - 70)
        for i in 0..<14 {
            let x: CGFloat = random.next(in: 20...412)
            let y: CGFloat = 30 + random.next(in: 0...1) * skySpan
            let big: CGFloat = random.next(in: 0.5...1.0)
            let kind = i % 4 == 0 ? 0 : (i % 2 == 0 ? 1 : 2)
            mote(&context, x, y, big, kind)
        }

        bandStage(&context, size) { g in
            moon(&g, 112, 122, 34, alpha: 0.9)
            hut(&g, 398, 332, 0.9)
            hut(&g, 426, 331, 1.1, peak: 30)
            bandGround(&g, top: 352)
            bandTree(&g)
            bandWeb(&g)
        }
        bandCanopy(&context, size)

        // The streams are drawn in the design space; their motes use one seeded generator.
        var streamRandom = ArtRandom(91)
        let u: CGFloat = bandScale(size)
        let ox: CGFloat = 216 * (1 - u)
        let oy: CGFloat = h - 24 - 396 * u
        var stage = context
        stage.translateBy(x: ox, y: oy)
        stage.scaleBy(x: u, y: u)

        // Father Anansi looking down from the tree, the pot gone.
        anansiClimbing(&stage, 199, 236, 1.22, withPot: false, lookingDown: true)

        // The great rock at the foot of the tree, and the broken pot.
        Art.group(&stage, x: 150 - 520, y: 392 - 720) { r in
            brokenPot(&r)
        }

        let source = pt(148, 304)
        wisdomStream(
            &stage, from: source,
            pt(130, 230), pt(176, 130), pt(166, 20),
            random: &streamRandom, calmX: -1000, size: 0.8
        )
        wisdomStream(
            &stage, from: source,
            pt(90, 250), pt(20, 300), pt(-60, 250),
            random: &streamRandom, calmX: -1000, size: 0.8
        )
        wisdomStream(
            &stage, from: source,
            pt(190, 330), pt(330, 250), pt(470, 200),
            random: &streamRandom, calmX: -1000, size: 0.8
        )

        // Kweku Tsin below, looking up.
        kwekuInLeaves(&stage, 352, 318, 0.85, lookX: -2.8, lookY: -2.6, mouthOpen: true)
        leaf(&stage, -26, 426, 120, -44, dark: true)

        fireflies(&context, 8, seed: 29, in: CGRect(x: 40, y: h * 0.4, width: w - 80, height: max(40, h * 0.42)))
        bandFloor(&context, size)
        finishPicture(&context, size)
    }
}
