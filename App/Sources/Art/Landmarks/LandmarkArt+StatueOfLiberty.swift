import SwiftUI
import OmramoCore

// The Statue of Liberty by day: our own drawing (no photograph, nothing traced, no lettering).
// The green copper figure, torch raised in her right hand (the picture's left), tablet in her
// other arm, a crown of seven rays, on her stone pedestal and star-shaped base on a small
// island in a harbour. Her face is only just indicated. Card background #0F3F4F.

extension LandmarkArt {
    /// The statue's centre line: the middle of the picture.
    private static let libertyX: CGFloat = 216

    /// statue-of-liberty: the green statue on its pedestal on a small island in a harbour.
    static func paintStatueOfLiberty(_ context: inout GraphicsContext) {
        libertySky(&context)
        libertyHarbour(&context)
        libertyIsland(&context)
        libertyFort(&context)
        libertyPedestal(&context)
        libertyRaisedArm(&context)
        libertyFigure(&context)
        libertyHead(&context)
        libertyBoat(&context, x: 52, y: 292, scale: 1)
        libertyBoat(&context, x: 396, y: 276, scale: 0.55)
        libertyNearPlane(&context)
        libertyFinish(&context)
    }

    // MARK: Colours

    /// Copper gone green in the sea air: pale on the side of the light, deep away from it.
    private static func libertyCopper(_ context: inout GraphicsContext, _ path: Path, from x0: CGFloat, to x1: CGFloat) {
        let stops: [(Color, CGFloat)] = [
            (Art.color(0xA4E0C6), 0),
            (Art.color(0x62B79C), 0.5),
            (Art.color(0x2F857C), 1),
        ]
        fillHorizontal(&context, path, stops, from: x0, to: x1)
    }

    /// The pale stone of the pedestal and the base.
    private static func libertyStone(_ context: inout GraphicsContext, _ path: Path, from x0: CGFloat, to x1: CGFloat) {
        let stops: [(Color, CGFloat)] = [
            (Art.color(0xF4E6CA), 0),
            (Art.color(0xDCC9AC), 0.5),
            (Art.color(0xA7989E), 1),
        ]
        fillHorizontal(&context, path, stops, from: x0, to: x1)
    }

    // MARK: Shapes used twice (the picture and its reflection)

    private static func libertyBody() -> Path {
        Art.svg("M204,98 C202,112 201,132 198,155 L234,155 C232,134 231,114 229,98 C224,93 209,93 204,98 Z")
    }

    private static func libertyShaft() -> Path {
        Art.polygon([pt(191, 160), pt(241, 160), pt(244, 214), pt(188, 214)])
    }

    private static func libertyPlinth() -> Path {
        Art.polygon([pt(180, 214), pt(252, 214), pt(256, 236), pt(176, 236)])
    }

    private static func libertyFortWall() -> Path {
        Art.polygon([pt(136, 254), pt(142, 236), pt(290, 236), pt(296, 254)])
    }

    // MARK: Sky and far shore

    private static func libertySky(_ context: inout GraphicsContext) {
        let sky: [(Color, CGFloat)] = [
            (Art.color(0x3A8AD8), 0),
            (Art.color(0x6FB0E6), 0.32),
            (Art.color(0xB6DAF0), 0.54),
            (Art.color(0xFFE8C2), 0.65),
            (Art.color(0xFFE8C2), 1),
        ]
        backdrop(&context, sky)
        Art.glow(&context, -10, 30, 210, Art.color(0xFFF4D6), alpha: 0.3)
        horizon(&context, y: 262, rise: 72, hex: 0xFFE2B0, alpha: 0.35)

        // A bank of fair-weather cloud behind the figure, so the green stands clear of the blue.
        Kit.cloud(&context, 232, 152, scale: 1.5, color: Art.color(0xFFFFFF, 0.94))
        Kit.cloud(&context, 146, 186, scale: 0.9, color: Art.color(0xFFFFFF, 0.85))
        Kit.cloud(&context, 344, 120, scale: 0.5, color: Art.color(0xFFFFFF, 0.85))
        Kit.birds(&context, 318, 64, scale: 0.6, color: Art.color(0x2E4F7E, 0.55))

        // The far plane: the low far shore of the harbour, veiled with the sky's own colour.
        let farShore = Kit.ridge(width: 480, y: 254, amp: 6, seed: 21, bottom: 266, step: 8, x0: -24)
        Art.fill(&context, farShore, Art.color(0x6E9DBE, 0.85))
        let nearShore = Kit.ridge(width: 480, y: 259, amp: 3, seed: 27, bottom: 266, step: 8, x0: -24)
        Art.fill(&context, nearShore, Art.color(0x5A8CAE, 0.8))
        haze(&context, top: 236, bottom: 266, hex: 0xFFE8C2, alpha: 0.32)
    }

    // MARK: Harbour

    private static func libertyHarbour(_ context: inout GraphicsContext) {
        let sea = Art.rect(-24, 262, unitWidth + 48, unitHeight - 262 + 24)
        let water: [(Color, CGFloat)] = [
            (Art.color(0xA8D6E4), 0),
            (Art.color(0x3F97B8), 0.2),
            (Art.color(0x1C6480), 0.6),
            (Art.color(0x0F3F4F), 1),
        ]
        fillVertical(&context, sea, water, from: 262, to: unitHeight)

        // The statue and its pedestal lie on the water, upside down, short and soft.
        let mirror = CGAffineTransform(a: 1, b: 0, c: 0, d: -0.3, tx: 0, ty: 348.4)
        let stoneParts: [Path] = [libertyShaft(), libertyPlinth(), libertyFortWall()]
        let figure = libertyBody().applying(mirror)
        Art.clipped(&context, to: sea) { g in
            Art.blurred(&g, radius: 2, opacity: 0.36) { layer in
                for part in stoneParts {
                    Art.fill(&layer, part.applying(mirror), Art.color(0xE6D6BC))
                }
                Art.fill(&layer, figure, Art.color(0x8FD2BA))
            }
        }

        let farBand = CGRect(x: 0, y: 265, width: unitWidth, height: 22)
        let nearBand = CGRect(x: 0, y: 286, width: unitWidth, height: 104)
        ripples(&context, in: farBand, count: 44, seed: 5, color: Art.color(0xFFFFFF, 0.4), width: 0.6, length: 6...24)
        ripples(&context, in: nearBand, count: 42, seed: 11, color: Art.color(0xCFEAF2, 0.2), width: 0.9, length: 10...38)
        ripples(&context, in: nearBand, count: 20, seed: 29, color: Art.color(0x0F3F4F, 0.22), width: 0.9, length: 12...40)
        let sunPath = CGRect(x: 6, y: 266, width: 90, height: 36)
        ripples(&context, in: sunPath, count: 16, seed: 17, color: Art.color(0xFFF1CF, 0.5), width: 0.9, length: 5...20)
    }

    // MARK: Island and base

    private static func libertyIsland(_ context: inout GraphicsContext) {
        ArtStyle.contactShadow(&context, 224, 269, 150, 5, alpha: 0.3)
        let island = Art.svg("M78,266 C96,256 128,252 150,252 L282,252 C306,252 338,256 356,266 C320,272 110,272 78,266 Z")
        let lawn: [(Color, CGFloat)] = [
            (Art.color(0x8CC97A), 0),
            (Art.color(0x4F9A62), 0.6),
            (Art.color(0x2F6F5A), 1),
        ]
        fillVertical(&context, island, lawn, from: 252, to: 270)
        model(&context, island, light: 0.18, shade: 0.22)
        // The sea wall round the island, and a thread of surf against it.
        let wall = Art.svg("M78,266 C110,272 320,272 356,266")
        Art.stroke(&context, wall, Art.color(0xE2D6BE), width: 2.2)
        let surf = Art.svg("M84,269.5 C120,274 310,274 350,269.5")
        Art.stroke(&context, surf, Art.color(0xFFFFFF, 0.5), width: 0.8)

        // Trees either side of the base, with the light on their left shoulders.
        var trees = Path()
        trees.addPath(canopy(from: 94, to: 136, baseY: 256, height: 11, bump: 9, depth: 3, seed: 41))
        trees.addPath(canopy(from: 298, to: 338, baseY: 256, height: 10, bump: 9, depth: 3, seed: 43))
        Art.fill(&context, trees, Art.color(0x2F7A56))
        model(&context, trees, light: 0.22, shade: 0.24)
    }

    /// The star-shaped base: from the side its points show as walls that turn to the light
    /// and away from it by turns.
    private static func libertyFort(_ context: inout GraphicsContext) {
        ArtStyle.contactShadow(&context, 226, 255, 88, 4, alpha: 0.28)
        let wall = libertyFortWall()
        libertyStone(&context, wall, from: 136, to: 296)
        model(&context, wall, light: 0.14, shade: 0.2)

        var away = Path()
        var corners = Path()
        for index in 0..<7 {
            let x: CGFloat = 140 + CGFloat(index) * 22
            if index % 2 == 1 {
                away.addPath(Art.polygon([pt(x, 236), pt(x + 22, 236), pt(x + 23, 254), pt(x - 1, 254)]))
            }
            if index > 0 {
                corners.move(to: pt(x, 237))
                corners.addLine(to: pt(x - 0.6, 254))
            }
        }
        Art.clipped(&context, to: wall) { g in
            Art.fill(&g, away, ArtStyle.coolShade.opacity(0.14))
            Art.stroke(&g, corners, Art.color(0xFFF6E2, 0.55), width: 0.7, cap: .butt)
            Art.stroke(&g, Art.line(138, 245, 294, 245), Art.color(0x7C6C8E, 0.3), width: 0.5, cap: .butt)
        }
        // The terrace on top of the base, with its low parapet.
        let terrace = Art.rect(140, 232.5, 152, 4)
        libertyStone(&context, terrace, from: 140, to: 292)
        Art.fill(&context, Art.rect(140, 232, 152, 1.3), Art.color(0xFFFFFF, 0.8))
        Art.fill(&context, Art.rect(141, 236.5, 150, 1.2), Art.color(0x5A4E72, 0.3))
    }

    // MARK: Pedestal

    private static func libertyPedestal(_ context: inout GraphicsContext) {
        ArtStyle.contactShadow(&context, 222, 233, 46, 3, alpha: 0.28)

        let plinth = libertyPlinth()
        libertyStone(&context, plinth, from: 176, to: 256)
        model(&context, plinth, light: 0.14, shade: 0.22)
        Art.fill(&context, Art.rect(179, 213.4, 74, 1.5), Art.color(0xFFFFFF, 0.8))
        Art.fill(&context, pointedArch(216, 236, width: 8, height: 14), Art.color(0x4A4266, 0.8))

        let shaft = libertyShaft()
        libertyStone(&context, shaft, from: 188, to: 244)
        model(&context, shaft, light: 0.16, shade: 0.22, rim: 0.5)

        // Courses of stone low on the shaft, two string courses above.
        var courses = Path()
        var y: CGFloat = 195
        while y < 213 {
            courses.move(to: pt(189, y))
            courses.addLine(to: pt(243, y))
            y += 6
        }
        courses.move(to: pt(191, 166.5))
        courses.addLine(to: pt(241, 166.5))
        courses.move(to: pt(190, 189.5))
        courses.addLine(to: pt(242, 189.5))
        Art.stroke(&context, courses, Art.color(0x7C6C8E, 0.32), width: 0.6, cap: .butt)

        // The open gallery: a shaded recess behind four slim piers.
        Art.fill(&context, Art.rect(198, 170, 36, 16), Art.color(0x5E5884, 0.72))
        var piers = Path()
        let pierOffsets: [CGFloat] = [-18, -9, 0, 9, 18]
        for offset in pierOffsets {
            piers.addRect(CGRect(x: libertyX + offset - 1.3, y: 170, width: 2.6, height: 16))
        }
        libertyStone(&context, piers, from: 196, to: 236)
        Art.fill(&context, Art.rect(198, 170, 36, 2), ArtStyle.coolShade.opacity(0.2))

        // The cornice the statue stands on, and its shade on the shaft below.
        let cornice = Art.polygon([pt(186, 155), pt(246, 155), pt(243, 160), pt(189, 160)])
        libertyStone(&context, cornice, from: 186, to: 246)
        Art.fill(&context, Art.rect(186, 154.4, 60, 1.4), Art.color(0xFFFFFF, 0.85))
        Art.fill(&context, Art.rect(191, 160, 50, 2.4), ArtStyle.coolShade.opacity(0.18))
    }

    // MARK: The statue

    /// Her right arm (the picture's left), raised straight up, and the torch in its hand.
    private static func libertyRaisedArm(_ context: inout GraphicsContext) {
        let arm = Art.svg("M203,101 C198,93 193,85 191,78 L190,56 L195,56 L198,76 C201,84 206,90 211,96 Z")
        libertyCopper(&context, arm, from: 188, to: 212)
        model(&context, arm, light: 0.2, shade: 0.2, rim: 0.6)
        let sleeve = Art.svg("M197,84 C200,86 202,90 203,94")
        Art.stroke(&context, sleeve, Art.color(0x2F7F78, 0.5), width: 0.7)

        // The torch: a handle, a little gallery, and a gilded flame.
        let handle = Art.rect(191.2, 45, 2.6, 13, radius: 1)
        libertyCopper(&context, handle, from: 190, to: 195)
        let hand = Art.circle(192.5, 55, 3.1)
        libertyCopper(&context, hand, from: 188, to: 197)
        let gallery = Art.polygon([pt(187.5, 43.6), pt(197.5, 43.6), pt(195.6, 47.6), pt(189.4, 47.6)])
        libertyCopper(&context, gallery, from: 186, to: 199)
        Art.fill(&context, Art.rect(187.5, 43, 10, 1), Art.color(0xD6F4E6, 0.9))

        Art.glow(&context, 192.5, 38, 16, Art.color(0xFFE9A8), alpha: 0.6)
        let flame = Art.svg("M0,0 C-4.5,-2 -4,-7 -1,-9 C-1,-6.5 1,-7.5 0.5,-12 C4,-8.500 4.6,-3 0,0 Z")
            .applying(CGAffineTransform(translationX: 192.5, y: 43.4))
        let gold: [(Color, CGFloat)] = [
            (Art.color(0xFFF2B8), 0),
            (Art.color(0xFFC94A), 0.6),
            (Art.color(0xE89A2E), 1),
        ]
        fillHorizontal(&context, flame, gold, from: 188, to: 197)
    }

    /// The long robe, the arm that holds the tablet, and the tablet.
    private static func libertyFigure(_ context: inout GraphicsContext) {
        let body = libertyBody()
        libertyCopper(&context, body, from: 198, to: 236)
        model(&context, body, light: 0.2, shade: 0.24, rim: 0.6)

        // The folds of the robe: long falls, and the cloak drawn across the body.
        let falls = Art.svg("M207,101 C210,118 208,138 203,154 M214,105 C216,124 214,142 211,154 M222,105 C224,124 224,142 223,154 M228,114 C229,130 230,144 230,154")
        let cloak = Art.svg("M205,104 C212,112 221,118 229,120 M203,122 C210,128 219,133 230,134")
        Art.clipped(&context, to: body) { g in
            Art.stroke(&g, falls, Art.color(0x2F7F78, 0.5), width: 0.8)
            Art.stroke(&g, cloak, Art.color(0x2F7F78, 0.42), width: 0.8)
            Art.stroke(&g, Art.svg("M206,101 C209,118 207,138 202,154"), Art.color(0xD6F4E6, 0.45), width: 0.7)
            Art.fill(&g, Art.rect(196, 151.6, 40, 3.4), Art.color(0x2F7F78, 0.3))
        }

        // Her left arm, bent to hold the tablet against her side.
        let arm = Art.svg("M226,98 C232,101 236,108 237,116 L231,120 C230,113 228,108 223,104 Z")
        libertyCopper(&context, arm, from: 216, to: 240)
        Art.fill(&context, arm, ArtStyle.coolShade.opacity(0.08))
        let tablet = Art.polygon([pt(229, 106), pt(238, 103.6), pt(240.6, 120), pt(231.6, 122.6)])
        Art.fill(&context, tablet, Art.color(0x9BDCC4))
        model(&context, tablet, light: 0.2, shade: 0.22)
        let tabletEdge = Art.polygon([pt(238, 103.6), pt(239.6, 104.4), pt(242.2, 120.6), pt(240.6, 120)])
        Art.fill(&context, tabletEdge, Art.color(0x2F7F78, 0.8))
        Art.fill(&context, Art.circle(233.4, 121.6, 2.3), Art.color(0x6FBFA6))
    }

    /// The head: seven rays, hair, a calm face that is barely there, and the band of the crown.
    private static func libertyHead(_ context: inout GraphicsContext) {
        let hx: CGFloat = libertyX
        let hy: CGFloat = 81

        var rays = Path()
        for index in 0..<7 {
            let angle: CGFloat = Kit.deg(-150 + CGFloat(index) * 20)
            let a0: CGFloat = angle - 0.14
            let a1: CGFloat = angle + 0.14
            rays.move(to: pt(hx + cos(a0) * 6.5, hy + sin(a0) * 6.5))
            rays.addLine(to: pt(hx + cos(angle) * 17, hy + sin(angle) * 17))
            rays.addLine(to: pt(hx + cos(a1) * 6.5, hy + sin(a1) * 6.5))
            rays.closeSubpath()
        }
        libertyCopper(&context, rays, from: 199, to: 233)

        let neck = Art.rect(213, 89, 6, 9)
        Art.fill(&context, neck, Art.color(0x4FA08E))
        let hair = Art.ellipse(hx, 83.5, 7.4, 8.2)
        Art.fill(&context, hair, Art.color(0x4FA08E))
        model(&context, hair, light: 0.16, shade: 0.24)
        let face = Art.ellipse(hx, 85, 5.5, 6.8)
        Art.fill(&context, face, Art.color(0x8FD2BA))
        model(&context, face, light: 0.24, shade: 0.2)

        // Tiny, calm features in a darker tone of the copper.
        let feature = Art.color(0x2F6F6A, 0.75)
        var eyes = Path()
        eyes.addEllipse(in: CGRect(x: hx - 2.9, y: 84.6, width: 1.2, height: 1.2))
        eyes.addEllipse(in: CGRect(x: hx + 1.7, y: 84.6, width: 1.2, height: 1.2))
        Art.fill(&context, eyes, feature)
        Art.stroke(&context, Art.line(hx, 85.6, hx - 0.3, 87.4), Art.color(0x2F6F6A, 0.4), width: 0.5)
        ArtStyle.smile(&context, hx, 89, width: 2.6, curve: 0.3, color: feature, lineWidth: 0.6)

        // The band of the crown across her brow.
        let band = Art.svg("M209.4,81.6 Q216,76.8 222.6,81.6 L222.3,79 Q216,74.2 209.7,79 Z")
        libertyCopper(&context, band, from: 205, to: 227)
        Art.stroke(&context, Art.svg("M209.7,79 Q216,74.2 222.3,79"), Art.color(0xD6F4E6, 0.8), width: 0.6)
    }

    // MARK: Boats and near plane

    /// A small sailing boat for scale, far enough off to have nobody to see in it.
    private static func libertyBoat(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, scale: CGFloat) {
        Art.group(&context, x: x, y: y, scale: scale) { g in
            ArtStyle.contactShadow(&g, 2, 4, 16, 2.2, alpha: 0.3)
            Art.stroke(&g, Art.line(0, -2, 0, -25), Art.color(0x6A4A3A), width: 1)
            var sails = Path()
            sails.addPath(Art.svg("M1.5,-24 C8,-16 11,-9 12,-4 L1.5,-4 Z"))
            sails.addPath(Art.svg("M-1.5,-20 C-5,-13 -8,-8 -10,-4 L-1.5,-4 Z"))
            Art.fill(&g, sails, Art.color(0xFFF8EA))
            model(&g, sails, light: 0.1, shade: 0.22)
            let hull = Art.svg("M-12,-3 L14,-3 C12,2 8,4 2,4 L-6,4 C-9,4 -11,1 -12,-3 Z")
            Art.fill(&g, hull, Art.color(0x2F5F9A))
            model(&g, hull, light: 0.16, shade: 0.24)
            Art.stroke(&g, Art.line(-11, -2.4, 13, -2.4), Art.color(0xFFE2C4, 0.8), width: 0.8)
        }
    }

    /// The near plane: dark harbour rocks and two old mooring posts in the bottom-right
    /// corner, well clear of the statue.
    private static func libertyNearPlane(_ context: inout GraphicsContext) {
        var posts = Path()
        posts.addPath(Art.rect(392, 318, 7, 60, radius: 2))
        posts.addPath(Art.rect(374, 334, 6, 50, radius: 2))
        let wood: [(Color, CGFloat)] = [
            (Art.color(0x4A5A62), 0),
            (Art.color(0x1E3A44), 1),
        ]
        fillVertical(&context, posts, wood, from: 318, to: 384)
        model(&context, posts, light: 0.22, shade: 0.2)

        let rocks = Art.svg("M456,326 C438,322 424,330 412,344 C400,342 388,352 380,366 C370,378 362,394 356,412 L456,412 Z")
        let rockStops: [(Color, CGFloat)] = [
            (Art.color(0x2A5E6C), 0),
            (Art.color(0x134452), 0.5),
            (Art.color(0x0B303C), 1),
        ]
        fillVertical(&context, rocks, rockStops, from: 324, to: unitHeight)
        model(&context, rocks, light: 0.2, shade: 0.2, rim: 0.5)
        let facets = Art.svg("M412,344 L420,370 M380,366 L394,388 M432,330 L438,356 M402,376 L406,400")
        Art.clipped(&context, to: rocks) { g in
            Art.stroke(&g, facets, Art.color(0x06222C, 0.35), width: 0.9)
        }
    }

    // MARK: Finish

    private static func libertyFinish(_ context: inout GraphicsContext) {
        bottomFade(&context, 0x0F3F4F, from: 300, alpha: 0.9)
        tooth(&context, seed: 541, light: 0.06, dark: 0.05)
        finish(&context, wash: 0.10, vignette: 0.10)
    }
}
