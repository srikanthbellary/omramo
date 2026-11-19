import SwiftUI
import OmramoCore

// Petra by day: our own drawing (no photograph, nothing traced).
// The rock-cut front known as the Treasury, carved into a rose-red sandstone cliff and seen
// from the mouth of the narrow canyon: six columns under a low pediment below; above, a round
// pavilion with a conical top between two half-pediments. A tiny far caravan gives the scale.
// Card background #5A2430.

extension LandmarkArt {
    /// petra: the rose-red rock-cut front in its cliff, framed by the dark canyon walls, with
    /// warm light on the stone, sandy ground and a tiny far camel caravan, by day.
    static func paintPetra(_ context: inout GraphicsContext) {
        petraSky(&context)
        petraCliff(&context)
        petraGround(&context)
        petraNiche(&context)
        petraUpperStorey(&context)
        petraLowerStorey(&context)
        // Warm light lying on the carved stone, from the upper left.
        Art.glow(&context, 186, 140, 150, Art.color(0xFFE0B0), alpha: 0.2)
        petraCaravan(&context)
        petraCanyon(&context)
        petraFinish(&context)
    }

    // MARK: Stone

    /// Rose-red sandstone in the one light: warm on the left, deeper rose to the right.
    static func petraStone(_ context: inout GraphicsContext, _ path: Path) {
        let stops: [(Color, CGFloat)] = [
            (Art.color(0xF8B890), 0),
            (Art.color(0xEC977A), 0.45),
            (Art.color(0xC96C66), 1),
        ]
        fillHorizontal(&context, path, stops, from: 138, to: 294)
    }

    /// A row of columns from `top` to `bottom`, centred on each of `xs`: shafts lit on the
    /// left and shaded on the right, each with a capital and a base.
    static func petraColumnRow(_ context: inout GraphicsContext, xs: [CGFloat], top: CGFloat, bottom: CGFloat, width: CGFloat) {
        var shafts = Path()
        var lights = Path()
        var shades = Path()
        var caps = Path()
        let half: CGFloat = width / 2
        let height: CGFloat = bottom - top
        let lightW: CGFloat = width * 0.28
        let shadeW: CGFloat = width * 0.36
        for x in xs {
            shafts.addRect(CGRect(x: x - half, y: top, width: width, height: height))
            lights.addRect(CGRect(x: x - half, y: top, width: lightW, height: height))
            shades.addRect(CGRect(x: x + half - shadeW, y: top, width: shadeW, height: height))
            caps.addRect(CGRect(x: x - half - 1.5, y: top - 4, width: width + 3, height: 4))
            caps.addRect(CGRect(x: x - half - 1, y: bottom - 2.5, width: width + 2, height: 2.5))
        }
        petraStone(&context, shafts)
        Art.fill(&context, lights, Art.color(0xFFE2BC, 0.5))
        Art.fill(&context, shades, ArtStyle.coolShade.opacity(0.2))
        petraStone(&context, caps)
        Art.fill(&context, caps, Art.color(0xFFE2BC, 0.25))
    }

    // MARK: Sky and cliff

    static func petraSky(_ context: inout GraphicsContext) {
        let sky: [(Color, CGFloat)] = [
            (Art.color(0x5FA8DC), 0),
            (Art.color(0xBFE0EC), 0.1),
            (Art.color(0xFFE3B8), 0.2),
            (Art.color(0xFFE3B8), 1),
        ]
        backdrop(&context, sky)
        // The far plane: the pale top of a farther cliff, veiled with the sky's own colour.
        let farCrest = Art.svg("M-24,70 L-24,30 C40,12 100,24 160,14 C220,6 300,20 360,10 C400,6 430,16 456,12 L456,70 Z")
        Art.fill(&context, farCrest, Art.color(0xDDA890))
        haze(&context, top: 0, bottom: 64, hex: 0xFFE3B8, alpha: 0.4)
    }

    static func petraCliff(_ context: inout GraphicsContext) {
        let cliff = Art.svg("M20,428 L20,62 C60,46 90,52 120,38 C160,26 200,36 240,30 C290,22 330,42 370,36 C390,34 404,46 412,62 L412,428 Z")
        let rock: [(Color, CGFloat)] = [
            (Art.color(0xEFA27E), 0),
            (Art.color(0xD98068), 0.5),
            (Art.color(0xB86060), 1),
        ]
        fillVertical(&context, cliff, rock, from: 26, to: 290)
        model(&context, cliff, light: 0.2, shade: 0.2)

        // The bands of the sandstone, and a few weathered clefts running down the face.
        let darkBands = Art.svg("M20,84 C80,76 130,92 200,82 C270,74 340,90 412,80 M20,138 C90,130 120,146 150,138 M290,150 C330,142 370,156 412,146 M20,214 C70,206 110,220 140,212 M296,226 C340,218 380,230 412,222")
        let lightBands = Art.svg("M20,62 C80,58 150,48 240,44 C300,42 360,50 412,66 M20,112 C70,104 110,118 140,110 M294,116 C330,108 380,122 412,112 M20,180 C60,172 100,186 136,178 M296,188 C340,180 372,194 412,184 M20,252 C60,246 100,258 134,252 M298,258 C340,250 380,262 412,256")
        let clefts = Art.svg("M96,58 C100,110 92,170 100,270 M124,44 C120,90 128,130 122,190 M318,44 C322,100 314,160 322,280 M352,46 C348,100 356,150 350,230")
        Art.clipped(&context, to: cliff) { g in
            Art.stroke(&g, darkBands, Art.color(0xA9505A, 0.3), width: 3)
            Art.stroke(&g, lightBands, Art.color(0xFFD4AC, 0.28), width: 2)
            Art.stroke(&g, clefts, Art.color(0x8E3E50, 0.28), width: 1.6)
        }
    }

    // MARK: Ground

    static func petraGround(_ context: inout GraphicsContext) {
        let ground = Art.rect(-24, 284, unitWidth + 48, unitHeight - 284 + 24)
        let sand: [(Color, CGFloat)] = [
            (Art.color(0xF4CFA0), 0),
            (Art.color(0xE3A682), 0.3),
            (Art.color(0x9A4E4C), 0.75),
            (Art.color(0x5A2430), 1),
        ]
        fillVertical(&context, ground, sand, from: 284, to: unitHeight)
        horizon(&context, y: 284, rise: 44, hex: 0xFFDCAA, alpha: 0.3)

        // The patch of sun on the sand in front of the carved front.
        let patch = Art.polygon([pt(128, 285), pt(304, 285), pt(336, 332), pt(92, 332)])
        let sun: [(Color, CGFloat)] = [
            (Art.color(0xFFEBC6, 0.4), 0),
            (Art.color(0xFFEBC6, 0), 1),
        ]
        fillVertical(&context, patch, sun, from: 285, to: 332)
        Kit.rippleMarks(&context, x0: 70, x1: 350, y0: 290, y1: 340, count: 16, seed: 37, color: Art.color(0xB86A5A), alpha: 0.3)
        ArtStyle.contactShadow(&context, 224, 285.5, 88, 4, alpha: 0.24)
    }

    // MARK: The carved front

    /// The deep recess cut back into the cliff, in which the front stands.
    static func petraNiche(_ context: inout GraphicsContext) {
        let niche = Art.rect(133, 54, 166, 230)
        let deep: [(Color, CGFloat)] = [
            (Art.color(0x8A3E4E), 0),
            (Art.color(0xAE5A58), 0.4),
            (Art.color(0xB8605A), 1),
        ]
        fillVertical(&context, niche, deep, from: 54, to: 284)
        // The roof of the recess and its left side are in shade; its right side faces the light.
        let soffit: [(Color, CGFloat)] = [
            (ArtStyle.coolShade.opacity(0.34), 0),
            (ArtStyle.coolShade.opacity(0), 1),
        ]
        fillVertical(&context, Art.rect(133, 54, 166, 22), soffit, from: 54, to: 76)
        Art.fill(&context, Art.rect(133, 54, 7, 230), ArtStyle.coolShade.opacity(0.24))
        Art.fill(&context, Art.rect(292, 54, 7, 230), Art.color(0xF8B890, 0.55))
        Art.stroke(&context, Art.line(133, 54, 299, 54), Art.color(0xFFD4AC, 0.6), width: 1)
    }

    static func petraUpperStorey(_ context: inout GraphicsContext) {
        // The dark gaps between the round pavilion and the two side pavilions.
        var gaps = Path()
        gaps.addRect(CGRect(x: 183, y: 86, width: 13, height: 70))
        gaps.addRect(CGRect(x: 236, y: 86, width: 13, height: 70))
        let dark: [(Color, CGFloat)] = [
            (Art.color(0x6E2F45), 0),
            (Art.color(0x8A3E4E), 1),
        ]
        fillVertical(&context, gaps, dark, from: 86, to: 156)

        // The side pavilions: a wall, two columns, a cornice and half a pediment each, the
        // halves rising toward the middle.
        var sideWalls = Path()
        sideWalls.addRect(CGRect(x: 145, y: 108, width: 38, height: 48))
        sideWalls.addRect(CGRect(x: 249, y: 108, width: 38, height: 48))
        petraStone(&context, sideWalls)
        Art.fill(&context, sideWalls, Art.color(0x8E3E50, 0.2))
        var panels = Path()
        panels.addRect(CGRect(x: 158, y: 118, width: 12, height: 32))
        panels.addRect(CGRect(x: 262, y: 118, width: 12, height: 32))
        Art.stroke(&context, panels, Art.color(0x8E3E50, 0.4), width: 0.7, cap: .butt, join: .miter)
        petraColumnRow(&context, xs: [149.5, 178.5, 253.5, 282.5], top: 112, bottom: 156, width: 7)

        var cornices = Path()
        cornices.addRect(CGRect(x: 141, y: 100, width: 44, height: 8))
        cornices.addRect(CGRect(x: 247, y: 100, width: 44, height: 8))
        cornices.addPath(Art.polygon([pt(141, 100), pt(185, 100), pt(185, 84)]))
        cornices.addPath(Art.polygon([pt(247, 100), pt(291, 100), pt(247, 84)]))
        petraStone(&context, cornices)
        model(&context, cornices, light: 0.2, shade: 0.18)
        let rakes = Art.svg("M141,100 L185,84 M291,100 L247,84")
        Art.stroke(&context, rakes, Art.color(0xFFE2BC, 0.8), width: 1)
        let friezes = Art.svg("M141,104 L185,104 M247,104 L291,104")
        Art.stroke(&context, friezes, Art.color(0x8E3E50, 0.4), width: 0.7, cap: .butt)

        petraTholos(&context)
    }

    /// The round pavilion in the middle of the upper storey: a drum with columns, a cornice,
    /// a conical top and the urn that stands on it.
    static func petraTholos(_ context: inout GraphicsContext) {
        let round: [(Color, CGFloat)] = [
            (Art.color(0xFAC09A), 0),
            (Art.color(0xEC977A), 0.4),
            (Art.color(0xB85C60), 1),
        ]
        let drum = Art.rect(198, 108, 36, 48)
        fillHorizontal(&context, drum, round, from: 198, to: 234)
        petraColumnRow(&context, xs: [201, 216, 231], top: 112, bottom: 156, width: 5)
        var bays = Path()
        bays.addRect(CGRect(x: 205.5, y: 118, width: 6, height: 30))
        bays.addRect(CGRect(x: 220.5, y: 118, width: 6, height: 30))
        Art.fill(&context, bays, Art.color(0x8E3E50, 0.28))

        let cornice = Art.svg("M194,100 L238,100 L238,106 Q216,110 194,106 Z")
        fillHorizontal(&context, cornice, round, from: 194, to: 238)
        Art.stroke(&context, Art.line(194, 100.4, 238, 100.4), Art.color(0xFFE2BC, 0.8), width: 0.9, cap: .butt)

        let cone = Art.svg("M193,100 Q209,95 216,77 Q223,95 239,100 Z")
        fillHorizontal(&context, cone, round, from: 196, to: 236)
        model(&context, cone, light: 0.2, shade: 0.2, rim: 0.6)

        var urn = Path()
        urn.addRect(CGRect(x: 214, y: 74, width: 4, height: 4))
        urn.addEllipse(in: CGRect(x: 211.5, y: 64, width: 9, height: 10.5))
        urn.addRect(CGRect(x: 214.6, y: 61, width: 2.8, height: 3.6))
        fillHorizontal(&context, urn, round, from: 211, to: 221)
        Art.fill(&context, Art.ellipse(214.2, 67.6, 1.3, 2.2), Art.color(0xFFE9C8, 0.6))
    }

    static func petraLowerStorey(_ context: inout GraphicsContext) {
        // The attic above the porch, and the wall behind the columns.
        let attic = Art.rect(141, 156, 150, 30)
        petraStone(&context, attic)
        Art.fill(&context, attic, Art.color(0x8E3E50, 0.14))
        let wall = Art.rect(141, 196, 150, 80)
        petraStone(&context, wall)
        Art.fill(&context, wall, Art.color(0x8E3E50, 0.22))

        // The shaded porch behind the four middle columns, and the tall doorway in it.
        let porch = Art.rect(177, 197, 78, 79)
        let shadeStops: [(Color, CGFloat)] = [
            (Art.color(0x5E2740), 0),
            (Art.color(0x7E3648), 0.6),
            (Art.color(0x96484E), 1),
        ]
        fillVertical(&context, porch, shadeStops, from: 197, to: 276)
        let door = Art.rect(205, 224, 22, 52)
        Art.fill(&context, door, Art.color(0x3E1630))
        Art.stroke(&context, Art.rect(203.5, 222.5, 25, 53.5), Art.color(0xD98068, 0.6), width: 1, cap: .butt, join: .miter)
        var sidePanels = Path()
        sidePanels.addRect(CGRect(x: 153, y: 214, width: 12, height: 44))
        sidePanels.addRect(CGRect(x: 267, y: 214, width: 12, height: 44))
        Art.stroke(&context, sidePanels, Art.color(0x8E3E50, 0.4), width: 0.7, cap: .butt, join: .miter)

        petraColumnRow(&context, xs: [147, 172, 199, 233, 260, 285], top: 200, bottom: 276, width: 9)

        // The beam over the columns, the low pediment over the middle four, the attic's cornice.
        var beams = Path()
        beams.addRect(CGRect(x: 138, y: 186, width: 156, height: 10))
        beams.addRect(CGRect(x: 138, y: 152, width: 156, height: 5))
        petraStone(&context, beams)
        let pediment = Art.polygon([pt(164, 186), pt(216, 165), pt(268, 186)])
        petraStone(&context, pediment)
        model(&context, pediment, light: 0.22, shade: 0.16)
        let tympanum = Art.polygon([pt(177, 184), pt(216, 169), pt(255, 184)])
        Art.fill(&context, tympanum, Art.color(0x8E3E50, 0.3))
        var lit = Art.line(164, 186, 216, 165)
        lit.move(to: pt(138, 186.4))
        lit.addLine(to: pt(294, 186.4))
        lit.move(to: pt(138, 152.4))
        lit.addLine(to: pt(294, 152.4))
        Art.stroke(&context, lit, Art.color(0xFFE2BC, 0.8), width: 0.9, cap: .butt)
        var lines = Art.line(138, 191.5, 294, 191.5)
        lines.move(to: pt(216, 165))
        lines.addLine(to: pt(268, 186))
        Art.stroke(&context, lines, Art.color(0x8E3E50, 0.4), width: 0.7, cap: .butt)
        // The beams throw a little shade onto what stands under them.
        var under = Path()
        under.addRect(CGRect(x: 141, y: 196, width: 150, height: 3.4))
        under.addRect(CGRect(x: 141, y: 157, width: 150, height: 2.6))
        Art.fill(&context, under, ArtStyle.coolShade.opacity(0.2))

        // The podium and the steps up to the door.
        let podium = Art.rect(137, 276, 158, 8)
        petraStone(&context, podium)
        model(&context, podium, light: 0.16, shade: 0.2)
        var steps = Art.line(137, 276.4, 295, 276.4)
        steps.move(to: pt(200, 279))
        steps.addLine(to: pt(232, 279))
        steps.move(to: pt(197, 281.6))
        steps.addLine(to: pt(235, 281.6))
        Art.stroke(&context, steps, Art.color(0xFFE2BC, 0.75), width: 0.8, cap: .butt)
    }

    // MARK: Caravan

    /// Three tiny camels and the person who leads them, far off on the sand: dark shapes only.
    static func petraCaravan(_ context: inout GraphicsContext) {
        let camel = "M-6,-7 C-5,-11 -2,-9 -1,-11 C0,-12.5 2,-11 3,-8 C4.5,-8 5.5,-10 6.5,-12.5 L8.5,-13 L9,-11.8 L7.6,-11.6 C7,-9 6,-6 4,-5.5 L4,0 L3,0 L2.6,-5 L-3.4,-5 L-3.8,0 L-4.8,0 L-5,-5.4 C-5.8,-5.8 -6.2,-6.4 -6,-7 Z M1.2,-5 L1.6,0 L0.8,0 L0.2,-5 Z M-2,-5 L-1.6,0 L-2.6,0 L-3,-5 Z"
        let places: [(CGFloat, CGFloat, CGFloat)] = [(112, 300, 1), (138, 298.5, 0.95), (163, 297, 0.9)]
        var shapes = Path()
        var packs = Path()
        for place in places {
            ArtStyle.contactShadow(&context, place.0 + 2, place.1 + 0.4, 9, 1.5, alpha: 0.3)
            shapes.addPath(Kit.placed(camel, x: place.0, y: place.1, scale: place.2))
            let packY: CGFloat = place.1 - 11.5 * place.2
            packs.addRect(CGRect(x: place.0 - 3.4, y: packY, width: 5, height: 3))
        }
        // The leader walks ahead, in a long robe.
        ArtStyle.contactShadow(&context, 182, 296.4, 3.4, 1, alpha: 0.3)
        shapes.addPath(Art.polygon([pt(180, 289.6), pt(182.4, 289.6), pt(183.2, 296), pt(179.2, 296)]))
        shapes.addEllipse(in: CGRect(x: 180, y: 287, width: 2.5, height: 2.6))
        Art.fill(&context, shapes, Art.color(0x4A1F33))
        Art.fill(&context, packs, Art.color(0x2E6E78, 0.9))
        let rope = Art.svg("M182.6,292 Q176,293.6 171.4,286")
        Art.stroke(&context, rope, Art.color(0x4A1F33, 0.7), width: 0.4)
    }

    // MARK: The near plane

    /// The two dark walls of the narrow canyon the viewer looks out of.
    static func petraCanyon(_ context: inout GraphicsContext) {
        let left = Art.svg("M-24,-24 L62,-24 C54,40 72,90 60,150 C50,210 76,260 64,320 C58,360 72,392 62,428 L-24,428 Z")
        Kit.solid(&context, left, stops: Kit.stops(0x6A2C40, 0x3A1830), light: 0.06, shade: 0.2)
        let right = Art.svg("M456,-24 L382,-24 C390,30 370,80 378,140 C386,200 362,250 374,310 C380,350 366,392 374,428 L456,428 Z")
        Kit.solid(&context, right, stops: Kit.stops(0x74324A, 0x3A1830), light: 0.1, shade: 0.22, rim: 2.5)

        let leftBands = Art.svg("M-24,96 C0,90 30,100 64,94 M-24,176 C0,170 30,182 58,176 M-24,250 C10,244 40,256 72,250")
        let rightBands = Art.svg("M374,70 C400,64 430,76 456,70 M380,160 C404,154 432,166 456,160 M366,236 C396,230 428,242 456,236")
        Art.clipped(&context, to: left) { g in
            Art.stroke(&g, leftBands, Art.color(0x9A4A5A, 0.3), width: 2)
        }
        Art.clipped(&context, to: right) { g in
            Art.stroke(&g, rightBands, Art.color(0xB05E62, 0.35), width: 2)
        }
    }

    // MARK: Finish

    static func petraFinish(_ context: inout GraphicsContext) {
        bottomFade(&context, 0x5A2430, from: 300, alpha: 0.9)
        tooth(&context, seed: 613, light: 0.06, dark: 0.05)
        finish(&context, wash: 0.10, vignette: 0.10)
    }
}
