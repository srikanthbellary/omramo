import SwiftUI
import Foundation
import OmramoCore

// Concept art, not final art: ported and extended from the locked design source
// docs/design/source/src/lib/art-anansi.js. The kente-style weave and the web mark are
// simplified drawings; final art is to be made and reviewed with Akan cultural advisers.
//
// The unfolded scenes are written as functions of the height through `Stage`: at 720 units
// they are the design; on a tall canvas (an iPad in portrait) the horizon rises, the far and
// middle planes and the subject grow, and a near band of ground and big leaves fills the
// bottom; on a short canvas the tree's buttress and the climber shrink so nothing collides.
// The one light is a moon warmed by the dusk, high on the left of the subject (the hinge side
// of the trailing pane): every rim light sits on the upper left, every shade on the lower right.
// On the leading pane (x 0…432) only dark, calm shapes sit under the light text.
// The folded bands are their own compositions: see AnansiArt+Folded.swift.

/// Concept art for "How Wisdom Became the Property of the Human Race", drawn in code.
enum AnansiArt {
    /// Draws the picture called `name`. Returns false for a name this story does not have.
    static func paint(_ name: String, role: ArtRole, in context: inout GraphicsContext, size: CGSize) -> Bool {
        switch (name, role) {
        case ("scene-village", .sceneUnfolded):
            villageScene(&context, size)
        case ("scene-village", .sceneFolded):
            villageBand(&context, size)
        case ("scene-forest", .sceneUnfolded):
            forestScene(&context, size)
        case ("scene-forest", .sceneFolded):
            forestBand(&context, size)
        case ("scene-climb", .sceneUnfolded):
            climbScene(&context, size)
        case ("scene-climb", .sceneFolded):
            climbBand(&context, size)
        case ("scene-wisdom", .sceneUnfolded):
            wisdomScene(&context, size)
        case ("scene-wisdom", .sceneFolded):
            wisdomBand(&context, size)
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

    // MARK: - Stage: how an unfolded scene answers the height

    /// The few numbers every unfolded scene derives from its height, so that 720 stays as
    /// designed, a tall canvas is recomposed (not a stretched sky) and a short one does not
    /// collide.
    struct Stage {
        let w: CGFloat
        let h: CGFloat
        /// 0 at 720 units and below, 1 from about 1150 units (an iPad in portrait).
        let tall: CGFloat
        /// How much the far and middle planes and the subject grow: 1…1.45.
        let grow: CGFloat
        /// How much the near plane (big leaves, Kweku) grows: 1…1.6.
        let near: CGFloat
        /// The height of the extra band of near ground under the grown planes.
        let lift: CGFloat
        /// 0.75…1: how much the climber shrinks on a short canvas.
        let fit: CGFloat
        /// The y of the horizon line: h − 60 at 720, 70% of the height on a tall canvas.
        let horizon: CGFloat
        /// The height of the great tree's buttress flare.
        let flare: CGFloat

        init(_ size: CGSize) {
            let width: CGFloat = size.width
            let height: CGFloat = max(size.height, 1)
            let over: CGFloat = (height - 720) / 430
            let t: CGFloat = max(0, min(1, over))
            let g: CGFloat = 1 + 0.45 * t
            let wanted: CGFloat = 0.30 * height - 60 * g
            let up: CGFloat = t * max(0, wanted)
            let small: CGFloat = max(0.75, min(1, height / 620))
            var buttress: CGFloat = 250 * g
            if height < 720 {
                buttress = max(110, 250 - (720 - height) * 0.42)
            }
            w = width
            h = height
            tall = t
            grow = g
            near = 1 + 0.6 * t
            lift = up
            fit = small
            horizon = height - up - 60 * g
            flare = buttress
        }
    }

    /// Far and middle planes and the subject: the design space (892 × 720, horizon at y 660,
    /// ground line at y 720) grown by `grow` about x = `anchor`, standing on the lifted band.
    static func farStage(
        _ context: inout GraphicsContext,
        _ st: Stage,
        anchor: CGFloat,
        _ body: (inout GraphicsContext) -> Void
    ) {
        let ox: CGFloat = anchor * (1 - st.grow)
        let oy: CGFloat = st.h - st.lift - 720 * st.grow
        Art.group(&context, x: ox, y: oy, scale: st.grow, body)
    }

    /// The near plane: the design space grown by `scale` about x = `anchor`, with design
    /// y 720 on the bottom edge.
    static func nearStage(
        _ context: inout GraphicsContext,
        _ st: Stage,
        anchor: CGFloat,
        scale: CGFloat,
        _ body: (inout GraphicsContext) -> Void
    ) {
        let ox: CGFloat = anchor * (1 - scale)
        let oy: CGFloat = st.h - 720 * scale
        Art.group(&context, x: ox, y: oy, scale: scale, body)
    }

    /// Where the climbing figure's head sits at 720 (the design has y ≈ 330 of 720).
    static func figureY(_ h: CGFloat) -> CGFloat {
        max(260, min(h * 0.46, h - 330))
    }

    static func starHeight(_ st: Stage) -> CGFloat {
        max(140, min(st.horizon - 240, 640))
    }

    /// The one light of the story: a moon warmed by the dusk, high on the hinge side of the
    /// trailing pane — upper left of the subject, clear of the words and of the hinge strip.
    static func moonSpot(_ st: Stage) -> (x: CGFloat, y: CGFloat, r: CGFloat) {
        let r: CGFloat = 44 * st.grow
        return (x: 462 + r, y: 150 * st.grow, r: r)
    }

    /// Hip position and scale of the climbing Father Anansi: his hands on the lit side of
    /// the trunk (x ≈ 609), kept above the buttress flare on a short canvas.
    static func climber(_ st: Stage) -> (x: CGFloat, y: CGFloat, s: CGFloat) {
        let s: CGFloat = 1.42 * st.grow * st.fit
        let flareTop: CGFloat = st.h - st.flare
        let wanted: CGFloat = figureY(st.h) + 42 * st.grow
        let y: CGFloat = min(wanted, flareTop - 40 * s)
        return (x: 609 - 36 * s, y: y, s: s)
    }

    // MARK: - Shared scene layers

    /// The far plane: a ridge of forest hills, far umbrella trees, the ember band and haze,
    /// the far ground, and (with `huts`) the little far-off village.
    static func lowland(_ context: inout GraphicsContext, _ st: Stage, huts: Bool) {
        let bottomY: CGFloat = 726 + st.lift / st.grow
        farStage(&context, st, anchor: 446) { g in
            let ridge = Art.svg("M0,640 C70,612 150,604 230,622 C300,636 360,600 450,596 C540,592 600,624 690,618 C770,612 830,590 892,600 L892,672 L0,672Z")
            Art.fill(&g, ridge, Art.color(0x5E2F7A, 0.5))

            let far: [(CGFloat, CGFloat)] = [
                (30, 0.3), (86, 0.42), (150, 0.3), (226, 0.36), (300, 0.3), (372, 0.4),
                (486, 0.6), (540, 0.5), (760, 0.7), (828, 0.56), (878, 0.66),
            ]
            for (i, item) in far.enumerated() {
                let tone = i % 2 == 1 ? Art.color(0x3A2466) : Art.color(0x472C73)
                umbrellaTree(&g, item.0, 650, 120 * item.1 + 40, item.1 * 0.8, tone, seed: UInt32(40 + i))
            }
            // The shared ember band on the horizon, over the far trees so they stay hazy.
            ArtStyle.horizonGlow(&g, width: 892, y: 660, rise: 150, color: ArtStyle.anansi.glowColor, alpha: 0.42)
            ArtStyle.atmosphere(&g, width: 892, top: 560, bottom: 662, color: Art.color(0xB04A72), alpha: 0.14)

            var ground = Art.svg("M0,660 C80,640 160,654 260,646 C360,638 420,656 520,648 C640,640 760,656 892,644")
            ground.addLine(to: pt(892, bottomY))
            ground.addLine(to: pt(0, bottomY))
            ground.closeSubpath()
            let soil: [(Color, CGFloat)] = [(Art.color(0x3A1F58), 0), (Art.color(0x2A1746), 1)]
            Art.fillLinear(&g, ground, soil, from: pt(0, 640), to: pt(0, 700))

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

    /// On a tall canvas the ember band rises behind the words of the leading pane: a soft
    /// veil of the story's deep indigo keeps that corner calm for the light text.
    static func calmVeil(_ context: inout GraphicsContext, _ st: Stage) {
        guard st.tall > 0.02 else { return }
        let reach: CGFloat = 300 * st.grow
        let strength: Double = 0.62 * Double(st.tall)
        Art.glow(&context, 130, st.horizon - 30, reach, ArtStyle.anansi.deepColor, alpha: strength)
    }

    /// The middle plane: nearer umbrella trees, dark, with the light on their upper left.
    /// `rightSide` adds the two on the trailing pane.
    static func midTrees(_ context: inout GraphicsContext, _ st: Stage, rightSide: Bool) {
        let tone = Art.color(0x22133F)
        farStage(&context, st, anchor: 120) { g in
            umbrellaTree(&g, -6, 690, 125, 1.265, tone, seed: 70, lit: 0.16)
            umbrellaTree(&g, 118, 690, 105, 1.15, tone, seed: 71, lit: 0.16)
            umbrellaTree(&g, 236, 690, 90, 1.035, tone, seed: 72, lit: 0.16)
        }
        if rightSide {
            farStage(&context, st, anchor: 892) { g in
                umbrellaTree(&g, 800, 690, 300, 1.38, tone, seed: 73, lit: 0.2)
                umbrellaTree(&g, 888, 690, 250, 1.15, tone, seed: 74, lit: 0.2)
            }
        }
    }

    /// The near ground: from the lip under the middle plane down to the bottom edge.
    static func nearGround(_ context: inout GraphicsContext, _ st: Stage) {
        let k: CGFloat = st.grow
        let top: CGFloat = st.h - st.lift - 44 * k
        var lip = Path()
        lip.move(to: pt(0, top + 14 * k))
        lip.addCurve(to: pt(300, top), control1: pt(100, top - 4 * k), control2: pt(200, top + 8 * k))
        lip.addCurve(to: pt(640, top + 2 * k), control1: pt(420, top - 8 * k), control2: pt(520, top + 10 * k))
        lip.addCurve(to: pt(892, top), control1: pt(740, top - 4 * k), control2: pt(820, top + 8 * k))
        var ground = lip
        ground.addLine(to: pt(892, st.h))
        ground.addLine(to: pt(0, st.h))
        ground.closeSubpath()
        let soil: [(Color, CGFloat)] = [
            (Art.color(0x26153F), 0), (Art.color(0x1A0F33), 0.3), (Art.color(0x140B2A), 1),
        ]
        Art.fillLinear(&context, ground, soil, from: pt(0, top - 8), to: pt(0, st.h))
        Art.stroke(&context, lip, ArtStyle.warmLight.opacity(0.1), width: 1.2)
    }

    /// Detail on the near ground: tufts of grass, and on a tall canvas a second, nearer fold
    /// of land so the new band reads as ground with depth, not as a flat strip.
    static func nearBand(_ context: inout GraphicsContext, _ st: Stage, seed: UInt32) {
        let k: CGFloat = st.grow
        let top: CGFloat = st.h - st.lift - 44 * k
        if st.lift > 24 {
            let y: CGFloat = top + 44 * k + st.lift * 0.42
            var fold = Path()
            fold.move(to: pt(0, y - 10))
            fold.addCurve(to: pt(460, y + 6), control1: pt(140, y - 34), control2: pt(320, y + 26))
            fold.addCurve(to: pt(892, y - 16), control1: pt(600, y - 14), control2: pt(760, y + 20))
            fold.addLine(to: pt(892, st.h))
            fold.addLine(to: pt(0, st.h))
            fold.closeSubpath()
            let tone: [(Color, CGFloat)] = [(Art.color(0x1C1036), 0), (Art.color(0x120A26), 1)]
            Art.fillLinear(&context, fold, tone, from: pt(0, y - 30), to: pt(0, st.h))
        }
        var random = ArtRandom(seed)
        let extra: CGFloat = (10 * st.tall).rounded()
        let count: Int = 9 + Int(extra)
        let depth: CGFloat = 20 * k + st.lift * 0.8
        for i in 0..<count {
            let x: CGFloat = random.next(in: 6...886)
            let drop: CGFloat = random.next(in: 0...1) * depth
            let y: CGFloat = top + 12 * k + drop
            let tuft: CGFloat = 0.9 + random.next(in: 0...0.7)
            let deeper: CGFloat = 1 + drop / 260
            let size: CGFloat = tuft * k * deeper
            grass(&context, x, y, size, seed: seed &+ UInt32(i) &* 7 &+ 1)
        }
    }

    /// The great silk-cotton tree of the trailing pane: a straight trunk from the top edge,
    /// a buttress flare over the last `flare` units, two boughs under the canopy. Lit from
    /// the upper left: the left side of the trunk and the left buttress carry the warm edge,
    /// the right side falls into shade.
    static func greatTree(_ context: inout GraphicsContext, _ st: Stage) {
        let h: CGFloat = st.h
        let g: CGFloat = st.grow
        let x0: CGFloat = 604
        let x1: CGFloat = x0 + 90 * g
        let gf: CGFloat = st.flare / 250
        let yF: CGFloat = h - st.flare
        let k: CGFloat = max(0.1, yF / 470)

        var trunk = Path()
        trunk.move(to: pt(x0, 0))
        trunk.addCurve(to: pt(x0 - 4, yF), control1: pt(x0 + 6, yF * 0.34), control2: pt(x0 + 2, yF * 0.7))
        trunk.addCurve(to: pt(x0 - 84 * gf, h), control1: pt(x0 - 8, yF + 90 * gf), control2: pt(x0 - 34 * gf, yF + 170 * gf))
        trunk.addLine(to: pt(x1 + 76 * gf, h))
        trunk.addCurve(to: pt(x1 + 2, yF), control1: pt(x1 + 32 * gf, yF + 180 * gf), control2: pt(x1 + 6, yF + 90 * gf))
        trunk.addCurve(to: pt(x1, 0), control1: pt(x1 - 4, yF * 0.7), control2: pt(x1 - 4, yF * 0.34))
        trunk.closeSubpath()
        let bark: [(Color, CGFloat)] = [
            (Art.color(0x8A6282), 0), (Art.color(0x4A2C5E), 0.35), (Art.color(0x22123F), 0.7), (Art.color(0x150A2C), 1),
        ]
        Art.fillLinear(&context, trunk, bark, from: pt(x0 - 70, 0), to: pt(x1 + 8, 0))

        // The buttress faces: the left one catches the light, the right one is in shade.
        let leftFlare = CGAffineTransform(a: gf, b: 0, c: 0, d: gf, tx: x0 - 604 * gf, ty: h - 720 * gf)
        let rightFlare = CGAffineTransform(a: gf, b: 0, c: 0, d: gf, tx: x1 - 694 * gf, ty: h - 720 * gf)
        let midX: CGFloat = (x0 + x1) / 2
        let midFlare = CGAffineTransform(a: gf, b: 0, c: 0, d: gf, tx: midX - 649 * gf, ty: h - 720 * gf)
        let litFace = Art.svg("M600,470 C590,570 556,650 500,720 L560,720 C590,660 612,580 618,500Z")
        Art.fill(&context, litFace.applying(leftFlare), ArtStyle.warmLight.opacity(0.2))
        let darkFace = Art.svg("M696,470 C702,570 730,650 782,720 L740,720 C712,660 690,590 684,510Z")
        Art.fill(&context, darkFace.applying(rightFlare), Art.color(0x120A26, 0.6))
        let roots = Art.svg("M640,720 C644,640 640,560 644,500 M664,720 C660,650 664,590 660,520")
        Art.stroke(&context, roots.applying(midFlare), Art.color(0x1B0F33, 0.5), width: ArtStyle.contourLine)

        let groove = CGAffineTransform(a: g, b: 0, c: 0, d: k, tx: x0 - 604 * g, ty: 0)
        let grooves = Art.svg("M622,20 C626,160 620,320 618,450 M650,10 C654,180 648,300 650,440 M672,0 C676,160 670,320 674,460")
        Art.stroke(&context, grooves.applying(groove), Art.color(0x1B0F33, 0.4), width: ArtStyle.detailLine)

        // The warm edge of the one light down the left of the trunk and along the buttress.
        var rim = Path()
        rim.move(to: pt(x0 + 1, 8))
        rim.addCurve(to: pt(x0 - 3, yF), control1: pt(x0 + 7, yF * 0.34), control2: pt(x0 + 3, yF * 0.7))
        Art.stroke(&context, rim, Art.color(0xFFE9D2, 0.62), width: ArtStyle.contourLine)
        var rimFoot = Path()
        rimFoot.move(to: pt(x0 - 3, yF))
        rimFoot.addCurve(to: pt(x0 - 82 * gf, h - 2), control1: pt(x0 - 7, yF + 90 * gf), control2: pt(x0 - 33 * gf, yF + 170 * gf))
        Art.stroke(&context, rimFoot, Art.color(0xFFE9D2, 0.32), width: ArtStyle.contourLine)

        // Boughs: the left one lit along its top, the right one in shade.
        let leftBough = Art.svg("M606,120 C560,110 500,96 440,70 C420,62 400,58 380,50 L384,42 C420,48 470,66 520,78 C560,88 590,90 610,88Z")
        Art.fill(&context, leftBough, Art.color(0x2E1A4C))
        Art.stroke(
            &context,
            Art.svg("M384,42 C420,48 470,66 520,78 C560,88 590,90 610,88"),
            ArtStyle.warmLight.opacity(0.3), width: ArtStyle.detailLine
        )
        let rightBough = Art.svg("M692,150 C740,130 800,120 892,96 L892,84 C810,104 750,108 692,122Z")
        let shiftRight = CGAffineTransform(translationX: x1 - 694, y: 0)
        Art.fill(&context, rightBough.applying(shiftRight), Art.color(0x1B0F33))
    }

    /// The web strung under the left bough, across the moon, with the small spider on its thread.
    static func moonWeb(_ context: inout GraphicsContext, _ st: Stage) {
        let m = moonSpot(st)
        spiderWeb(&context, 602, 122, 96 * st.grow, 1.75, 2.85)
        let sx: CGFloat = m.x + m.r * 0.41
        let sy: CGFloat = m.y + m.r * 0.59
        Art.stroke(&context, Art.line(sx, 86, sx, sy - 4), ArtStyle.warmLight.opacity(0.6), width: 0.7, cap: .butt)
        spider(&context, sx, sy, st.grow)
    }

    /// The canopy of the great tree, grown with the canvas.
    static func greatCanopy(_ context: inout GraphicsContext, _ st: Stage) {
        let blobs = grown(climbCanopy, by: st.grow, anchor: 700)
        nightCanopy(&context, blobs, seed: 14, palette: canopyPalette, calmBefore: 440)
    }

    static func rightLeaves(_ context: inout GraphicsContext, _ st: Stage) {
        nearStage(&context, st, anchor: 892, scale: st.near) { g in
            leaf(&g, 900, 735, 190, -118, dark: true)
            leaf(&g, 880, 740, 150, -150, dark: false)
        }
        nearStage(&context, st, anchor: 470, scale: st.near) { g in
            leaf(&g, 470, 740, 140, -70, dark: true)
        }
    }

    /// Fireflies low over the leading pane and in the air of the trailing pane.
    static func sceneFireflies(_ context: inout GraphicsContext, _ st: Stage, low: Int, high: Int) {
        let lowTop: CGFloat = st.h - 130 - st.lift * 0.8
        fireflies(&context, low, seed: 9, in: CGRect(x: 0, y: lowTop, width: 300, height: 90 + st.lift * 0.6))
        let flyTop: CGFloat = min(300 * st.grow, st.h * 0.42)
        let flyHeight: CGFloat = max(60, st.h - 20 - flyTop)
        fireflies(&context, high, seed: 29, in: CGRect(x: 460, y: flyTop, width: 432, height: flyHeight))
    }

    // MARK: - Scene: the village at dusk

    static func villageScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Stage(size)
        let w: CGFloat = st.w
        let h: CGFloat = st.h
        let k: CGFloat = st.grow

        sky(&context, w, h, duskSky, horizon: st.horizon, spread: k)
        let starH = starHeight(st)
        stars(&context, 34, seed: 5, in: CGRect(x: 460, y: 0, width: 432, height: starH))
        stars(&context, 22, seed: 6, in: CGRect(x: 0, y: 0, width: 432, height: starH), alpha: 0.5)

        // The one light: an early moon, warmed by the dusk, high on the left of the people.
        let m = moonSpot(st)
        moon(&context, m.x, m.y, m.r * 0.82, alpha: 0.94)

        // The last warmth of the day behind the houses.
        Art.group(&context, x: 680, y: st.horizon - 10, scaleX: 1.6) { c in
            Art.glow(&c, 0, 0, 190 * k, Art.color(0xFFB45A), alpha: 0.3)
        }

        lowland(&context, st, huts: false)
        calmVeil(&context, st)

        // The village on the leading pane: small houses, steep roofs, warm doorways.
        farStage(&context, st, anchor: 160) { c in
            let places: [(CGFloat, CGFloat)] = [
                (52, 1.5), (100, 1.2), (158, 1.65), (214, 1.1), (262, 1.35), (310, 1.0),
            ]
            for place in places {
                hut(&c, place.0, 652, place.1, peak: 34)
            }
            Art.stroke(
                &c,
                Art.svg("M158,596 C154,580 166,570 160,554 C156,544 164,536 162,528"),
                Art.color(0xD9B8E8, 0.3), width: ArtStyle.contourLine
            )
        }

        midTrees(&context, st, rightSide: true)
        nearGround(&context, st)
        nearBand(&context, st, seed: 301)

        // Houses of the trailing pane, and Father Anansi with the people who ask his advice.
        farStage(&context, st, anchor: 500) { c in
            house(&c, 532, 684, 1.15, lit: 0.55)
            house(&c, 876, 694, 1.7, lit: 0.8)
            house(&c, 726, 700, 2.25, lit: 1)
            // Lamplight from the doorway lying across the ground, toward the listeners.
            Art.group(&c, x: 684, y: 707, scale: 0.3, scaleX: 10) { p in
                Art.glow(&p, 0, 0, 46, Art.color(0xFFB84D), alpha: 0.34)
            }

            villager(&c, 488, 702, 2.0, seated: false, cloth: Art.color(0x4B2C86))
            villager(&c, 526, 706, 2.0, seated: true, cloth: ArtStyle.anansi.midColor)
            villager(&c, 560, 709, 1.5, seated: true, cloth: Art.color(0x2E3A6B))

            Art.glow(&c, 612, 640, 90, Art.color(0xFFC46A), alpha: 0.22)
            anansiStanding(&c, 606, 704, 0.98, withPot: false, gesture: true)
        }

        // Leaves overhead, top right.
        let overhead: [(CGFloat, CGFloat, CGFloat)] = [(850, 10, 100), (716, -12, 70), (892, 112, 54)]
        nightCanopy(&context, grown(overhead, by: k, anchor: 892), seed: 21, palette: canopyPalette)

        // The near plane: big leaves at the hinge and in the corner.
        nearStage(&context, st, anchor: 446, scale: st.near) { c in
            leaf(&c, 446, 740, 140, -122, dark: false)
            leaf(&c, 380, 770, 120, -78, dark: true)
            leaf(&c, 470, 740, 140, -70, dark: true)
        }
        nearStage(&context, st, anchor: 892, scale: st.near) { c in
            leaf(&c, 884, 744, 130, -152, dark: false)
        }

        let lowTop: CGFloat = h - 130 - st.lift * 0.8
        fireflies(&context, 9, seed: 9, in: CGRect(x: 0, y: lowTop, width: 300, height: 90 + st.lift * 0.6))
        let airTop: CGFloat = st.horizon - 270 * k
        fireflies(&context, 12, seed: 29, in: CGRect(x: 460, y: airTop, width: 432, height: 250 * k))
        finishPicture(&context, size)
    }

    // MARK: - Scene: the forest path

    static func forestScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Stage(size)
        let w: CGFloat = st.w
        let h: CGFloat = st.h
        let k: CGFloat = st.grow

        sky(&context, w, h, duskSky, horizon: st.horizon, spread: k)
        let starH = starHeight(st)
        stars(&context, 40, seed: 5, in: CGRect(x: 460, y: 0, width: 432, height: starH))
        stars(&context, 26, seed: 6, in: CGRect(x: 0, y: 0, width: 432, height: starH), alpha: 0.5)
        Art.group(&context, x: 640, y: h * 0.46, scaleX: 0.7) { c in
            Art.glow(&c, 0, 0, h * 0.46, Art.color(0x6A3A9A), alpha: 0.35)
        }
        // The one light: the moon through the trees, upper left of Father Anansi.
        let m = moonSpot(st)
        moon(&context, m.x, m.y, m.r * 0.9)

        lowland(&context, st, huts: true)
        calmVeil(&context, st)

        // Far trunks, then a thin mist in front of them.
        let farBase: CGFloat = h - st.lift - 24 * k
        let farTrunks: [(CGFloat, CGFloat)] = [(20, 16), (404, 12), (478, 14), (568, 10), (664, 16), (838, 14)]
        for trunk in farTrunks {
            forestTrunk(&context, trunk.0, trunk.1 * k, farBase, dark: Art.color(0x1E1248), light: Art.color(0x33206A), rim: 0)
        }
        let mistTop: CGFloat = st.horizon - 360 * k
        let mistBottom: CGFloat = mistTop + 280 * k
        let mist: [(Color, CGFloat)] = [(Art.color(0x7A4A9A, 0), 0), (Art.color(0x7A4A9A, 0.16), 1)]
        Art.fillLinear(&context, Art.rect(0, mistTop, w, mistBottom - mistTop), mist, from: pt(0, mistTop), to: pt(0, mistBottom))

        midTrees(&context, st, rightSide: false)
        nearGround(&context, st)
        nearBand(&context, st, seed: 311)

        // The path Father Anansi takes, and the near trunks beside it.
        let feetY: CGFloat = h - 32 * k - st.lift * 0.5
        let pathTop: CGFloat = h - st.lift - 34 * k
        let run: CGFloat = h - pathTop
        let pk: CGFloat = k * (1 + 0.6 * st.tall)
        var trail = Path()
        trail.move(to: pt(621 - 81 * pk, h))
        trail.addCurve(to: pt(621 - 15 * k, pathTop), control1: pt(621 - 51 * pk, h - run * 0.5), control2: pt(621 - 29 * pk, pathTop + run * 0.18))
        trail.addLine(to: pt(621 + 15 * k, pathTop))
        trail.addCurve(to: pt(621 + 99 * pk, h), control1: pt(621 + 39 * pk, pathTop + run * 0.24), control2: pt(621 + 69 * pk, h - run * 0.4))
        trail.closeSubpath()
        let trailTone: [(Color, CGFloat)] = [(Art.color(0x5A3470, 0.75), 0), (Art.color(0x3E2658, 0.7), 1)]
        Art.fillLinear(&context, trail, trailTone, from: pt(0, pathTop), to: pt(0, h))

        forestTrunk(&context, 792, 26 * k, h, dark: Art.color(0x180C30), light: Art.color(0x34205A), rim: 0.25)
        forestTrunk(&context, 716, 46 * k, h, dark: Art.color(0x150A2C), light: Art.color(0x4A2C5E), rim: 0.5)
        forestTrunk(&context, 874, 56 * k, h, dark: Art.color(0x150A2C), light: Art.color(0x4A2C5E), rim: 0.4)

        // Vines and the canopy.
        let vineColor = Art.color(0x14234A)
        let vineLeaf = Art.color(0x2C6A7C)
        vine(&context, 566, 70 * k, 150 * k, 10, vineColor, leafColor: vineLeaf)
        vine(&context, 668, 110 * k, 190 * k, -12, vineColor, leafColor: vineLeaf)
        vine(&context, 760, 96 * k, 130 * k, 8, vineColor, leafColor: vineLeaf)
        vine(&context, 836, 130 * k, 170 * k, -8, vineColor, leafColor: vineLeaf)
        greatCanopy(&context, st)

        // Father Anansi on the path with the pot hung round his neck.
        let s: CGFloat = 1.2 * k
        Art.glow(&context, 610, feetY - 62 * k, 110 * k, Art.color(0xFFC94D), alpha: 0.3)
        anansiStanding(&context, 610, feetY, s, withPot: true, gesture: false)
        let sparks: [(CGFloat, CGFloat, CGFloat, Int)] = [
            (-44, -150, 1, 1), (42, -176, 0.9, 2), (-26, -196, 0.8, 2), (50, -120, 1.1, 0),
        ]
        for spark in sparks {
            mote(&context, 610 + spark.0 * k, feetY + spark.1 * k, spark.2 * k, spark.3)
        }

        // Kweku Tsin following, hidden in the leaves.
        kwekuWatching(&context, st, lookX: 2.6, lookY: -1.6, mouthOpen: false)
        rightLeaves(&context, st)

        sceneFireflies(&context, st, low: 12, high: 26)
        finishPicture(&context, size)
    }

    // MARK: - Scene: the climb (screen 04)

    static func climbScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Stage(size)
        let w: CGFloat = st.w
        let h: CGFloat = st.h
        let k: CGFloat = st.grow

        sky(&context, w, h, duskSky, horizon: st.horizon, spread: k)
        let starH = starHeight(st)
        stars(&context, 60, seed: 5, in: CGRect(x: 460, y: 0, width: 432, height: starH))
        stars(&context, 40, seed: 6, in: CGRect(x: 0, y: 0, width: 432, height: starH), alpha: 0.5)
        Art.group(&context, x: 640, y: h * 0.46, scaleX: 0.7) { c in
            Art.glow(&c, 0, 0, h * 0.46, Art.color(0x6A3A9A), alpha: 0.4)
        }
        // The one light: the big moon, upper left of the climber, on the hinge side of the
        // trailing pane (clear of the words and of the hinge strip).
        let m = moonSpot(st)
        moon(&context, m.x, m.y, m.r)

        lowland(&context, st, huts: true)
        calmVeil(&context, st)
        midTrees(&context, st, rightSide: true)
        nearGround(&context, st)
        nearBand(&context, st, seed: 321)
        greatTree(&context, st)
        moonWeb(&context, st)
        greatCanopy(&context, st)

        // Father Anansi and the pot.
        let who = climber(st)
        Art.glow(&context, who.x + 28 * who.s, who.y - 38 * who.s, 85 * who.s, Art.color(0xFFC94D), alpha: 0.3)
        anansiClimbing(&context, who.x, who.y, who.s)
        let sparks: [(CGFloat, CGFloat, CGFloat, Int)] = [
            (-34, -20, 1, 1), (-52, -48, 1.2, 0), (-46, 10, 0.8, 2), (-58, 30, 1.1, 1),
            (-30, 40, 0.9, 2), (-40, -80, 0.7, 2), (-66, -14, 0.8, 2),
        ]
        for spark in sparks {
            let x: CGFloat = max(466, who.x + spark.0 * who.s)
            mote(&context, x, who.y + spark.1 * who.s, spark.2 * k, spark.3)
        }

        // Kweku Tsin watching from the leaves.
        kwekuWatching(&context, st, lookX: 2.6, lookY: -2.6, mouthOpen: false)
        rightLeaves(&context, st)

        sceneFireflies(&context, st, low: 12, high: 22)
        finishPicture(&context, size)
    }

    // MARK: - Scene: wisdom spreads over the world

    /// The great rock at the foot of the tree and the broken pot lying open on it, with its
    /// shards. Drawn in the design space of the scene: the rock stands on y = 720 round x = 520.
    static func brokenPot(_ g: inout GraphicsContext) {
        Art.glow(&g, 518, 632, 170, Art.color(0xFFC94D), alpha: 0.45)
        ArtStyle.contactShadow(&g, 530, 718, 84, 7, alpha: 0.3)
        let rock = Art.svg("M452,720 C450,690 466,664 496,656 C524,648 560,654 578,674 C590,690 592,706 590,720Z")
        let stone: [(Color, CGFloat)] = [(Art.color(0x5A4680), 0), (Art.color(0x2E2152), 0.5), (Art.color(0x1C1338), 1)]
        Art.fillLinear(&g, rock, stone, from: pt(0, 652), to: pt(0, 720))
        ArtStyle.form(&g, rock, bounds: CGRect(x: 450, y: 652, width: 142, height: 68), light: 0.2, shade: 0.3)
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

    /// One stream of wisdom from `source` along a curve, with motes scattered on it. Motes
    /// left of `calmX` are the small, plain kind, so light text can sit over them.
    static func wisdomStream(
        _ context: inout GraphicsContext,
        from source: CGPoint,
        _ c1: CGPoint, _ c2: CGPoint, _ end: CGPoint,
        random: inout ArtRandom,
        calmX: CGFloat,
        size: CGFloat = 1
    ) {
        var stream = Path()
        stream.move(to: source)
        stream.addCurve(to: end, control1: c1, control2: c2)
        Art.stroke(&context, stream, moteGold.opacity(0.08), width: 7 * size)
        Art.stroke(&context, stream, moteGold.opacity(0.22), width: ArtStyle.detailLine)
        for i in 1...9 {
            let t: CGFloat = CGFloat(i) / 10
            let p = cubicPoint(source, c1, c2, end, t)
            let x: CGFloat = p.x + random.next(in: -14...14) * size
            let y: CGFloat = p.y + random.next(in: -14...14) * size
            let big: CGFloat = random.next(in: 0.7...1.3) * size
            let kind = i % 3
            if x < calmX {
                let calmKind = kind == 0 ? 2 : kind
                mote(&context, x, y, big * 0.6, calmKind, alpha: 0.6)
            } else {
                mote(&context, x, y, big, kind)
            }
        }
    }

    static func wisdomScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Stage(size)
        let w: CGFloat = st.w
        let h: CGFloat = st.h
        let k: CGFloat = st.grow
        var random = ArtRandom(77)

        sky(&context, w, h, dawnSky, horizon: st.horizon, spread: k)
        let starH = starHeight(st)
        stars(&context, 34, seed: 5, in: CGRect(x: 460, y: 0, width: 432, height: starH), alpha: 0.7)
        stars(&context, 22, seed: 6, in: CGRect(x: 0, y: 0, width: 432, height: starH), alpha: 0.35)
        Art.group(&context, x: 640, y: h * 0.46, scaleX: 0.7) { c in
            Art.glow(&c, 0, 0, h * 0.46, Art.color(0x7A4AAA), alpha: 0.35)
        }
        let m = moonSpot(st)
        moon(&context, m.x, m.y, m.r, alpha: 0.9)

        lowland(&context, st, huts: true)
        calmVeil(&context, st)
        midTrees(&context, st, rightSide: true)
        nearGround(&context, st)
        nearBand(&context, st, seed: 331)

        // Wisdom drifting across the whole sky: bigger over the trailing pane, small and
        // faint over the reading area of the leading pane.
        let skySpan: CGFloat = max(80, st.horizon - 200)
        for i in 0..<26 {
            let x: CGFloat = random.next(in: 470...880)
            let y: CGFloat = 40 + random.next(in: 0...1) * skySpan
            let big: CGFloat = random.next(in: 0.6...1.3) * k
            let kind = i % 4 == 0 ? 0 : (i % 2 == 0 ? 1 : 2)
            mote(&context, x, y, big, kind)
        }
        let readSpan: CGFloat = max(60, st.horizon - 230)
        for i in 0..<16 {
            let x: CGFloat = random.next(in: 14...420)
            let y: CGFloat = 30 + random.next(in: 0...1) * readSpan
            let kind = i % 5 == 0 ? 1 : 2
            mote(&context, x, y, 0.5, kind, alpha: 0.55)
        }

        greatTree(&context, st)
        moonWeb(&context, st)
        greatCanopy(&context, st)

        // Father Anansi looking down from the tree, the pot gone.
        let who = climber(st)
        anansiClimbing(&context, who.x, who.y, who.s, withPot: false, lookingDown: true)

        // The great rock at the foot of the tree, and the broken pot.
        nearStage(&context, st, anchor: 452, scale: k) { g in
            brokenPot(&g)
        }

        // Three streams of wisdom leaving the pot: up into the night past the moon, out over
        // the village, and away through the forest.
        let source = pt(452 + 66 * k, h - 88 * k)
        wisdomStream(
            &context, from: source,
            pt(455, h - 230 * k), pt(440, h * 0.42), pt(410, 96),
            random: &random, calmX: 440, size: k
        )
        wisdomStream(
            &context, from: source,
            pt(430, h - 170 * k), pt(250, h - 110 * k), pt(40, h - 170 * k),
            random: &random, calmX: 440, size: k
        )
        wisdomStream(
            &context, from: source,
            pt(600, h - 240 * k), pt(760, h - 300 * k), pt(880, h * 0.35),
            random: &random, calmX: 440, size: k
        )

        // Kweku Tsin below, looking up.
        kwekuWatching(&context, st, lookX: 2.8, lookY: -3.4, mouthOpen: true)
        rightLeaves(&context, st)

        sceneFireflies(&context, st, low: 8, high: 12)
        finishPicture(&context, size)
    }
}
