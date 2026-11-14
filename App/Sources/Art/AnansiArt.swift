import SwiftUI
import Foundation
import OmramoCore

// Concept art, not final art: ported and extended from the locked design source
// docs/design/source/src/lib/art-anansi.js. The kente-style weave and the web mark are
// simplified drawings; final art is to be made and reviewed with Akan cultural advisers.
//
// Scenes are written as functions of the height: ground, village, sunset band and foreground
// leaves hang from the bottom edge, canopy and moon from the top, and trunks stretch between.
// On the leading pane (x 0…432) everything above `h - 200` stays dark and calm for light text.

/// Concept art for "How Wisdom Became the Property of the Human Race", drawn in code.
enum AnansiArt {
    /// Draws the picture called `name`. Returns false for a name this story does not have.
    static func paint(_ name: String, role: ArtRole, in context: inout GraphicsContext, size: CGSize) -> Bool {
        switch (name, role) {
        case ("scene-village", .sceneUnfolded):
            villageScene(&context, size)
        case ("scene-village", .sceneFolded):
            foldedScene(&context, size) { g, s in villageScene(&g, s) }
        case ("scene-forest", .sceneUnfolded):
            forestScene(&context, size)
        case ("scene-forest", .sceneFolded):
            foldedScene(&context, size) { g, s in forestScene(&g, s) }
        case ("scene-climb", .sceneUnfolded):
            climbScene(&context, size)
        case ("scene-climb", .sceneFolded):
            foldedScene(&context, size) { g, s in climbScene(&g, s) }
        case ("scene-wisdom", .sceneUnfolded):
            wisdomScene(&context, size)
        case ("scene-wisdom", .sceneFolded):
            foldedScene(&context, size) { g, s in wisdomScene(&g, s) }
        case ("see-precious-pot", .picture):
            potPicture(&context, size)
        case ("see-forest", .picture):
            forestPicture(&context, size)
        case ("char-kweku", .portrait):
            kwekuPortrait(&context, size)
        case ("char-anansi", .portrait):
            anansiPortrait(&context, size)
        case ("face-anansi", .face):
            anansiFace(&context, size)
        case ("face-kweku", .face):
            kwekuFace(&context, size)
        case ("cover", .cover):
            coverPicture(&context, size)
        default:
            return false
        }
        return true
    }

    // MARK: - Folded band

    /// The folded picture band: the trailing side of the unfolded scene (where the main
    /// moment is), scaled down, with a plain dark strip along the bottom for the wave cut.
    static func foldedScene(
        _ context: inout GraphicsContext,
        _ size: CGSize,
        _ scene: (inout GraphicsContext, CGSize) -> Void
    ) {
        let w = size.width
        let h = size.height
        let floorColor = Art.color(0x140B2A)
        Art.fill(&context, Art.rect(0, 0, w, h), floorColor)
        let band = max(h - 22, 1)
        let s = min(0.7, max(band / 560, w / 892))
        let virtual = CGSize(width: 892, height: band / s)
        let shiftX = w - 892 * s
        Art.clipped(&context, to: Art.rect(0, 0, w, band)) { c in
            Art.group(&c, x: shiftX, y: 0, scale: s) { g in
                scene(&g, virtual)
            }
        }
        let fade: [(Color, CGFloat)] = [(floorColor.opacity(0), 0), (floorColor, 1)]
        Art.fillLinear(&context, Art.rect(0, band - 14, w, 14), fade, from: pt(0, band - 14), to: pt(0, band))
    }

    // MARK: - Shared scene layers (design space: 892 wide, bottom-anchored parts drawn at h - 720)

    /// Where the climbing figure sits (the design has y ≈ 330 of 720).
    static func figureY(_ h: CGFloat) -> CGFloat {
        max(260, min(h * 0.46, h - 330))
    }

    static func starHeight(_ h: CGFloat) -> CGFloat {
        max(140, min(h - 300, 520))
    }

    /// Far umbrella trees, the warm haze and the far ground, with the little far-off village.
    static func lowland(_ context: inout GraphicsContext, _ w: CGFloat, _ h: CGFloat, huts: Bool) {
        Art.group(&context, x: 0, y: h - 720) { g in
            let far: [(CGFloat, CGFloat)] = [
                (30, 0.3), (86, 0.42), (150, 0.3), (226, 0.36), (300, 0.3), (372, 0.4),
                (486, 0.6), (540, 0.5), (760, 0.7), (828, 0.56), (878, 0.66),
            ]
            for (i, item) in far.enumerated() {
                let tone = i % 2 == 1 ? Art.color(0x3A2466) : Art.color(0x472C73)
                umbrellaTree(&g, item.0, 650, 120 * item.1 + 40, item.1 * 0.8, tone, seed: UInt32(40 + i))
            }
            // The shared ember band on the horizon, over the far trees so they stay hazy.
            ArtStyle.horizonGlow(&g, width: w, y: 660, rise: 150, color: ArtStyle.anansi.glowColor, alpha: 0.42)
            Art.fill(
                &g,
                Art.svg("M0,660 C80,640 160,654 260,646 C360,638 420,656 520,648 C640,640 760,656 892,644 L892,720 L0,720Z"),
                Art.color(0x2A1746)
            )
            if huts {
                let places: [(CGFloat, CGFloat)] = [(60, 1), (96, 0.8), (140, 1.1), (182, 0.75)]
                for place in places {
                    hut(&g, place.0, 650, place.1)
                }
                Art.stroke(
                    &g,
                    Art.svg("M100,618 C96,600 108,590 102,572 C98,560 106,552 104,544"),
                    Art.color(0xD9B8E8, 0.3), width: ArtStyle.contourLine
                )
            }
        }
    }

    /// The nearer umbrella trees in dark silhouette. `rightSide` adds the two on the trailing pane.
    static func midTrees(_ context: inout GraphicsContext, _ h: CGFloat, rightSide: Bool) {
        Art.group(&context, x: 0, y: h - 720) { g in
            let trees: [(CGFloat, CGFloat, CGFloat)] = [
                (-6, 0.5, 1.1), (118, 0.42, 1), (236, 0.36, 0.9), (800, 1.2, 1.2), (888, 1.0, 1),
            ]
            for (i, tree) in trees.enumerated() {
                if tree.0 > 440 && !rightSide {
                    continue
                }
                umbrellaTree(&g, tree.0, 690, 250 * tree.1, tree.2 * 1.15, Art.color(0x22133F), seed: UInt32(70 + i))
            }
        }
    }

    static func nearGround(_ context: inout GraphicsContext, _ h: CGFloat) {
        let ground = Art.svg("M0,690 C100,672 200,684 300,676 C420,668 520,686 640,678 C740,672 820,684 892,676 L892,720 L0,720Z")
        Art.fill(&context, shifted(ground, h - 720), Art.color(0x1A0F33))
    }

    /// The great silk-cotton tree of the trailing pane: straight trunk from the top edge,
    /// buttress flare over the last 250 units, two boughs under the canopy.
    static func greatTree(_ context: inout GraphicsContext, _ h: CGFloat) {
        let yF = h - 250
        let k = max(0.1, yF / 470)
        let dy = h - 720

        var trunk = Path()
        trunk.move(to: pt(604, 0))
        trunk.addCurve(to: pt(600, yF), control1: pt(610, yF * 0.34), control2: pt(606, yF * 0.7))
        trunk.addCurve(to: pt(520, h), control1: pt(596, yF + 90), control2: pt(570, yF + 170))
        trunk.addLine(to: pt(770, h))
        trunk.addCurve(to: pt(696, yF), control1: pt(726, yF + 180), control2: pt(700, yF + 90))
        trunk.addCurve(to: pt(694, 0), control1: pt(690, yF * 0.7), control2: pt(690, yF * 0.34))
        trunk.closeSubpath()
        let bark: [(Color, CGFloat)] = [
            (Art.color(0x150A2C), 0), (Art.color(0x22123F), 0.5), (Art.color(0x4A2C5E), 0.82),
            (Art.color(0xB98A9A), 0.96), (Art.color(0xFFE3C8), 1),
        ]
        Art.fillLinear(&context, trunk, bark, from: pt(520, 0), to: pt(770, 0))

        let shadeSide = Art.svg("M600,470 C590,570 556,650 500,720 L560,720 C590,660 612,580 618,500Z")
        Art.fill(&context, shifted(shadeSide, dy), Art.color(0x1B0F33, 0.7))
        let lightSide = Art.svg("M696,470 C702,570 730,650 782,720 L740,720 C712,660 690,590 684,510Z")
        Art.fill(&context, shifted(lightSide, dy), Art.color(0xF3D9C8, 0.25))
        let roots = Art.svg("M640,720 C644,640 640,560 644,500 M664,720 C660,650 664,590 660,520")
        Art.stroke(&context, shifted(roots, dy), Art.color(0x1B0F33, 0.5), width: ArtStyle.contourLine)

        let grooves = Art.svg("M622,20 C626,160 620,320 618,450 M650,10 C654,180 648,300 650,440 M672,0 C676,160 670,320 674,460")
        Art.stroke(&context, stretched(grooves, k), Art.color(0x1B0F33, 0.4), width: ArtStyle.detailLine)
        let rimLine = Art.svg("M692,10 C688,160 688,330 694,470")
        Art.stroke(&context, stretched(rimLine, k), Art.color(0xFFE9D2, 0.65), width: ArtStyle.contourLine)

        Art.fill(
            &context,
            Art.svg("M606,120 C560,110 500,96 440,70 C420,62 400,58 380,50 L384,42 C420,48 470,66 520,78 C560,88 590,90 610,88Z"),
            Art.color(0x22133F)
        )
        Art.fill(
            &context,
            Art.svg("M692,150 C740,130 800,120 892,96 L892,84 C810,104 750,108 692,122Z"),
            Art.color(0x3D2458)
        )
    }

    /// The web strung from the trunk to the moon, with the small spider on its thread.
    static func moonWeb(_ context: inout GraphicsContext) {
        spiderWeb(&context, 694, 140, 110, -0.42, 0.5)
        Art.stroke(&context, Art.line(762, 118, 762, 196), ArtStyle.warmLight.opacity(0.6), width: 0.7, cap: .butt)
        spider(&context, 762, 200, 1)
    }

    static func rightLeaves(_ context: inout GraphicsContext, _ h: CGFloat) {
        Art.group(&context, x: 0, y: h - 720) { g in
            leaf(&g, 900, 735, 190, -118, dark: true)
            leaf(&g, 880, 740, 150, -150, dark: false)
            leaf(&g, 470, 740, 140, -70, dark: true)
        }
    }

    // MARK: - Scene: the village at dusk

    static func villageScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        let h = size.height
        let dy = h - 720

        sky(&context, w, h, duskSky)
        let starH = starHeight(h)
        stars(&context, 34, seed: 5, in: CGRect(x: 460, y: 0, width: 432, height: starH))
        stars(&context, 22, seed: 6, in: CGRect(x: 0, y: 0, width: 432, height: starH), alpha: 0.5)

        // The last warmth of the day behind the houses.
        Art.group(&context, x: 680, y: h - 70, scaleX: 1.6) { g in
            Art.glow(&g, 0, 0, 190, Art.color(0xFFB45A), alpha: 0.3)
        }

        lowland(&context, w, h, huts: false)

        // The village on the leading pane: small houses, steep roofs, warm doorways.
        Art.group(&context, x: 0, y: dy) { g in
            let places: [(CGFloat, CGFloat)] = [
                (52, 1.5), (100, 1.2), (158, 1.65), (214, 1.1), (262, 1.35), (310, 1.0),
            ]
            for place in places {
                hut(&g, place.0, 652, place.1, peak: 34)
            }
            Art.stroke(
                &g,
                Art.svg("M158,596 C154,580 166,570 160,554 C156,544 164,536 162,528"),
                Art.color(0xD9B8E8, 0.3), width: ArtStyle.contourLine
            )
        }

        midTrees(&context, h, rightSide: true)
        nearGround(&context, h)

        // Houses of the trailing pane, and Father Anansi with the people who ask his advice.
        Art.group(&context, x: 0, y: dy) { g in
            house(&g, 532, 684, 1.15, lit: 0.55)
            house(&g, 876, 694, 1.7, lit: 0.8)
            house(&g, 726, 700, 2.25, lit: 1)
            Art.fill(&g, Art.ellipse(676, 706, 130, 9), Art.color(0xFFB84D, 0.2))

            villager(&g, 490, 702, 1.9, seated: false, cloth: ArtStyle.anansi.shadeColor)
            villager(&g, 524, 706, 1.9, seated: true, cloth: ArtStyle.anansi.midColor)
            villager(&g, 556, 708, 1.45, seated: true, cloth: Art.color(0x2E3A6B))

            Art.glow(&g, 612, 640, 90, Art.color(0xFFC46A), alpha: 0.22)
            anansiStanding(&g, 606, 704, 0.98, withPot: false, gesture: true)
        }

        // Leaves overhead, top right.
        let overhead: [(CGFloat, CGFloat, CGFloat)] = [(850, 10, 100), (716, -12, 70), (892, 112, 54)]
        nightCanopy(&context, overhead, seed: 21, palette: canopyPalette)

        Art.group(&context, x: 0, y: dy) { g in
            leaf(&g, 446, 740, 140, -122, dark: false)
            leaf(&g, 380, 770, 120, -78, dark: true)
            leaf(&g, 470, 740, 140, -70, dark: true)
            leaf(&g, 884, 744, 130, -152, dark: false)
        }

        fireflies(&context, 9, seed: 9, in: CGRect(x: 0, y: h - 130, width: 300, height: 90))
        fireflies(&context, 12, seed: 29, in: CGRect(x: 460, y: h - 330, width: 432, height: 250))
        finishPicture(&context, size)
    }

    // MARK: - Scene: the forest path

    static func forestScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        let h = size.height
        let dy = h - 720

        sky(&context, w, h, duskSky)
        let starH = starHeight(h)
        stars(&context, 40, seed: 5, in: CGRect(x: 460, y: 0, width: 432, height: starH))
        stars(&context, 26, seed: 6, in: CGRect(x: 0, y: 0, width: 432, height: starH), alpha: 0.5)
        Art.group(&context, x: 640, y: h * 0.46, scaleX: 0.7) { g in
            Art.glow(&g, 0, 0, h * 0.46, Art.color(0x6A3A9A), alpha: 0.35)
        }
        moon(&context, 618, 176, 40)

        lowland(&context, w, h, huts: true)

        // Far trunks, then a thin mist in front of them.
        let farTrunks: [(CGFloat, CGFloat)] = [(20, 16), (404, 12), (478, 14), (568, 10), (664, 16), (838, 14)]
        for trunk in farTrunks {
            forestTrunk(&context, trunk.0, trunk.1, h - 24, dark: Art.color(0x1E1248), light: Art.color(0x2A1A58), rim: 0)
        }
        let mist: [(Color, CGFloat)] = [(Art.color(0x7A4A9A, 0), 0), (Art.color(0x7A4A9A, 0.14), 1)]
        Art.fillLinear(&context, Art.rect(0, h - 420, w, 280), mist, from: pt(0, h - 420), to: pt(0, h - 140))

        midTrees(&context, h, rightSide: false)
        nearGround(&context, h)

        // The path Father Anansi takes, and the near trunks beside it.
        let path = Art.svg("M540,720 C570,702 592,692 606,686 L636,686 C660,694 690,706 720,720Z")
        Art.fill(&context, shifted(path, dy), Art.color(0x4A2C5E, 0.7))
        forestTrunk(&context, 520, 22, h, dark: Art.color(0x180C30), light: Art.color(0x2C1A4C), rim: 0.2)
        forestTrunk(&context, 792, 26, h, dark: Art.color(0x180C30), light: Art.color(0x2C1A4C), rim: 0.25)
        forestTrunk(&context, 716, 46, h, dark: Art.color(0x150A2C), light: Art.color(0x3A2458), rim: 0.5)
        forestTrunk(&context, 874, 56, h, dark: Art.color(0x150A2C), light: Art.color(0x3A2458), rim: 0.4)

        // Vines and the canopy.
        let vineColor = Art.color(0x10283F)
        let vineLeaf = Art.color(0x2B6A7A)
        vine(&context, 566, 70, 150, 10, vineColor, leafColor: vineLeaf)
        vine(&context, 668, 110, 190, -12, vineColor, leafColor: vineLeaf)
        vine(&context, 760, 96, 130, 8, vineColor, leafColor: vineLeaf)
        vine(&context, 836, 130, 170, -8, vineColor, leafColor: vineLeaf)
        nightCanopy(&context, climbCanopy, seed: 14, palette: canopyPalette, calmBefore: 440)

        // Father Anansi on the path with the pot hung round his neck.
        let feetY = h - 32
        Art.glow(&context, 610, feetY - 62, 110, Art.color(0xFFC94D), alpha: 0.3)
        anansiStanding(&context, 610, feetY, 1.2, withPot: true, gesture: false)
        let sparks: [(CGFloat, CGFloat, CGFloat, Int)] = [
            (566, -150, 1, 1), (652, -176, 0.9, 2), (584, -196, 0.8, 2), (660, -120, 1.1, 0),
        ]
        motes(&context, sparks, dx: 0, dy: feetY)

        // Kweku Tsin following, hidden in the leaves.
        kwekuWatching(&context, h, lookX: 2.6, lookY: -1.6, mouthOpen: false)
        rightLeaves(&context, h)

        fireflies(&context, 12, seed: 9, in: CGRect(x: 0, y: h - 130, width: 300, height: 90))
        let flyTop = min(300, h * 0.42)
        fireflies(&context, 26, seed: 29, in: CGRect(x: 460, y: flyTop, width: 432, height: max(60, h - 20 - flyTop)))
        finishPicture(&context, size)
    }

    // MARK: - Scene: the climb (screen 04)

    static func climbScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        let h = size.height
        let hipY = figureY(h) + 42

        sky(&context, w, h, duskSky)
        let starH = starHeight(h)
        stars(&context, 60, seed: 5, in: CGRect(x: 460, y: 0, width: 432, height: starH))
        stars(&context, 40, seed: 6, in: CGRect(x: 0, y: 0, width: 432, height: starH), alpha: 0.5)
        Art.group(&context, x: 640, y: h * 0.46, scaleX: 0.7) { g in
            Art.glow(&g, 0, 0, h * 0.46, Art.color(0x6A3A9A), alpha: 0.4)
        }
        moon(&context, 776, 170, 52)

        lowland(&context, w, h, huts: true)
        midTrees(&context, h, rightSide: true)
        nearGround(&context, h)
        greatTree(&context, h)
        moonWeb(&context)
        nightCanopy(&context, climbCanopy, seed: 14, palette: canopyPalette, calmBefore: 440)

        // Father Anansi and the pot.
        Art.glow(&context, 598, hipY - 54, 120, Art.color(0xFFC94D), alpha: 0.3)
        anansiClimbing(&context, 558, hipY, 1.42)
        let sparks: [(CGFloat, CGFloat, CGFloat, Int)] = [
            (504, 276, 1.2, 1), (530, 236, 1, 2), (574, 210, 1.5, 0), (540, 176, 0.9, 1),
            (508, 196, 0.8, 2), (486, 150, 1.2, 0), (520, 130, 0.8, 2),
        ]
        motes(&context, sparks, dx: 0, dy: hipY - 372)

        // Kweku Tsin watching from the leaves.
        kwekuWatching(&context, h, lookX: 2.6, lookY: -2.6, mouthOpen: false)
        rightLeaves(&context, h)

        fireflies(&context, 12, seed: 9, in: CGRect(x: 0, y: h - 130, width: 300, height: 90))
        let flyTop = min(300, h * 0.42)
        fireflies(&context, 22, seed: 29, in: CGRect(x: 460, y: flyTop, width: 432, height: max(60, h - 20 - flyTop)))
        finishPicture(&context, size)
    }

    // MARK: - Scene: wisdom spreads over the world

    static func wisdomScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        let h = size.height
        let dy = h - 720
        let hipY = figureY(h) + 42
        var random = ArtRandom(77)

        sky(&context, w, h, dawnSky)
        let starH = starHeight(h)
        stars(&context, 34, seed: 5, in: CGRect(x: 460, y: 0, width: 432, height: starH), alpha: 0.7)
        stars(&context, 22, seed: 6, in: CGRect(x: 0, y: 0, width: 432, height: starH), alpha: 0.35)
        Art.group(&context, x: 640, y: h * 0.46, scaleX: 0.7) { g in
            Art.glow(&g, 0, 0, h * 0.46, Art.color(0x7A4AAA), alpha: 0.35)
        }
        moon(&context, 776, 170, 52, alpha: 0.9)

        lowland(&context, w, h, huts: true)
        midTrees(&context, h, rightSide: true)
        nearGround(&context, h)

        // Wisdom drifting across the whole sky: bigger over the trailing pane, small and
        // faint over the reading area of the leading pane.
        let skySpan = max(80, h - 260)
        for i in 0..<26 {
            let x = random.next(in: 470...880)
            let y = 40 + random.next(in: 0...1) * skySpan
            let big = random.next(in: 0.6...1.3)
            let kind = i % 4 == 0 ? 0 : (i % 2 == 0 ? 1 : 2)
            mote(&context, x, y, big, kind)
        }
        let readSpan = max(60, h - 290)
        for i in 0..<16 {
            let x = random.next(in: 14...420)
            let y = 30 + random.next(in: 0...1) * readSpan
            let kind = i % 5 == 0 ? 1 : 2
            mote(&context, x, y, 0.5, kind, alpha: 0.55)
        }

        greatTree(&context, h)
        moonWeb(&context)
        nightCanopy(&context, climbCanopy, seed: 14, palette: canopyPalette, calmBefore: 440)

        // Father Anansi looking down from the tree, the pot gone.
        anansiClimbing(&context, 558, hipY, 1.42, withPot: false, lookingDown: true)

        // The great rock at the foot of the tree, and the broken pot.
        Art.group(&context, x: 0, y: dy) { g in
            Art.glow(&g, 518, 632, 170, Art.color(0xFFC94D), alpha: 0.45)
            let rock = Art.svg("M452,720 C450,690 466,664 496,656 C524,648 560,654 578,674 C590,690 592,706 590,720Z")
            let stone: [(Color, CGFloat)] = [(Art.color(0x5A4680), 0), (Art.color(0x2E2152), 0.5), (Art.color(0x1C1338), 1)]
            Art.fillLinear(&g, rock, stone, from: pt(0, 652), to: pt(0, 720))
            Art.fill(&g, Art.svg("M470,676 C486,662 520,656 548,662 C530,668 500,672 480,686Z"), Art.color(0xFFD98A, 0.3))
            Art.stroke(
                &g,
                Art.svg("M540,664 C548,680 546,700 552,716 M500,672 C496,690 500,704 496,718"),
                Art.color(0x1C1338, 0.6), width: ArtStyle.detailLine
            )

            // The lower half of the pot, lying open on the rock.
            Art.group(&g, x: 514, y: 638, rotate: rad(-22), scale: 1.5) { p in
                Art.fill(&p, Art.ellipse(0, 0, 19.5, 6), Art.color(0x3A160E))
                Art.fill(&p, Art.ellipse(0, 0.6, 16.5, 4.4), Art.color(0xFFE27A))
                let jag: [CGPoint] = [
                    pt(-30, 1), pt(-15, -6), pt(-9, 3), pt(-1, -5), pt(6, 4), pt(14, -4), pt(30, 3), pt(30, 30), pt(-30, 30),
                ]
                Art.clipped(&p, to: Art.polygon(jag)) { c in
                    pot(&c, 0, 0, 1, glow: false)
                }
            }

            // Shards.
            let shard = Art.svg("M-6,-4 C-2,-7 4,-6 7,-2 L2,6 L-5,3Z")
            let pieces: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
                (472, 664, 20, 1.5), (560, 652, 150, 1.7), (592, 692, 80, 1.3), (486, 640, 250, 1.1),
                (578, 668, 200, 1.2), (604, 708, 310, 1.5), (474, 704, 110, 1.3), (548, 632, 40, 0.9),
            ]
            let clays: [Color] = [Art.color(0xC7562E), Art.color(0xF08A52), Art.color(0x9A3E20)]
            for (i, piece) in pieces.enumerated() {
                let tone = clays[i % 3]
                Art.group(&g, x: piece.0, y: piece.1, rotate: rad(piece.2), scale: piece.3) { c in
                    Art.fill(&c, shard, tone)
                    Art.stroke(&c, Art.line(-4, -3, 5, -1), Art.color(0xFFD25A, 0.85), width: 1, cap: .butt)
                    Art.stroke(&c, Art.line(-5, 3, 2, 6), Art.color(0x3A160E, 0.6), width: 0.8, cap: .butt)
                }
            }
            Art.glow(&g, 516, 630, 46, Art.color(0xFFF3C2), alpha: 0.7)
        }

        // Three streams of wisdom leaving the pot: up into the night, out over the village,
        // and away through the forest.
        let source = pt(518, h - 88)
        let ribbons: [(CGPoint, CGPoint, CGPoint)] = [
            (pt(470, h - 220), pt(500, h * 0.45), pt(470, 60)),
            (pt(430, h - 170), pt(250, h - 110), pt(40, h - 170)),
            (pt(600, h - 240), pt(760, h - 300), pt(880, h * 0.35)),
        ]
        for ribbon in ribbons {
            var stream = Path()
            stream.move(to: source)
            stream.addCurve(to: ribbon.2, control1: ribbon.0, control2: ribbon.1)
            Art.stroke(&context, stream, moteGold.opacity(0.08), width: 7)
            Art.stroke(&context, stream, moteGold.opacity(0.22), width: ArtStyle.detailLine)
            for i in 1...9 {
                let t = CGFloat(i) / 10
                let p = cubicPoint(source, ribbon.0, ribbon.1, ribbon.2, t)
                let x = p.x + random.next(in: -14...14)
                let y = p.y + random.next(in: -14...14)
                let big = random.next(in: 0.7...1.3)
                let overText = x < 440
                let kind = i % 3
                if overText {
                    let calmKind = kind == 0 ? 2 : kind
                    mote(&context, x, y, big * 0.6, calmKind, alpha: 0.6)
                } else {
                    mote(&context, x, y, big, kind)
                }
            }
        }

        // Kweku Tsin below, looking up.
        kwekuWatching(&context, h, lookX: 2.8, lookY: -3.4, mouthOpen: true)
        rightLeaves(&context, h)

        fireflies(&context, 8, seed: 9, in: CGRect(x: 0, y: h - 130, width: 300, height: 90))
        let flyTop = min(300, h * 0.42)
        fireflies(&context, 12, seed: 29, in: CGRect(x: 460, y: flyTop, width: 432, height: max(60, h - 20 - flyTop)))
        finishPicture(&context, size)
    }
}
