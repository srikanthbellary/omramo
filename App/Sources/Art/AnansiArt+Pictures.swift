import SwiftUI
import Foundation
import OmramoCore

// The single pictures of the Anansi story: tap-to-see pictures, character portraits,
// face chips and the cover. Every one is lit by the same warm light from the upper left.

extension AnansiArt {
    // MARK: - See: the precious pot

    /// The great sealed pot, close up: one subject, centred a little above the middle, on a
    /// simple ground. 432 × 404; the lower part tends to the card colour #2A1650.
    static func potPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        let h = size.height
        let card = Art.color(0x2A1650)
        Art.fill(&context, Art.rect(0, 0, w, h), card)
        let room: [(Color, CGFloat)] = [(Art.color(0x5A3396), 0), (Art.color(0x3A2068), 0.5), (card, 1)]
        Art.fillRadial(&context, Art.rect(0, 0, w, h), room, center: pt(w / 2, 180), radius: 300)

        stars(&context, 28, seed: 11, in: CGRect(x: 0, y: 0, width: w, height: 200), alpha: 0.6)
        spiderWeb(&context, w, 0, 230, 1.62, 3.08, alpha: 0.5, width: 0.9)

        // A simple ground in the story's ramp: the earth floor of the house, a round woven
        // mat under the pot, both fading into the card below.
        var floorPath = Path()
        floorPath.move(to: pt(0, 262))
        floorPath.addCurve(to: pt(w, 258), control1: pt(w * 0.3, 254), control2: pt(w * 0.7, 266))
        floorPath.addLine(to: pt(w, h))
        floorPath.addLine(to: pt(0, h))
        floorPath.closeSubpath()
        let earth: [(Color, CGFloat)] = [(Art.color(0x4A2A66), 0), (Art.color(0x35206B, 0.6), 0.4), (card.opacity(0), 1)]
        Art.fillLinear(&context, floorPath, earth, from: pt(0, 256), to: pt(0, 340))
        Art.fill(&context, Art.ellipse(w / 2, 296, 136, 17), Art.color(0x6A2F7A, 0.55))
        Art.stroke(&context, Art.ellipse(w / 2, 296, 136, 17), ArtStyle.anansi.glowColor.opacity(0.3), width: ArtStyle.detailLine)
        Art.stroke(&context, Art.ellipse(w / 2, 296, 112, 13), ArtStyle.anansi.deepColor.opacity(0.35), width: ArtStyle.detailLine)

        // Light from inside the pot, its glow on the ground, and the shared contact shadow
        // (falling to the lower right, away from the one light).
        Art.glow(&context, w / 2, 190, 250, Art.color(0xFFC94D), alpha: 0.35)
        Art.group(&context, x: w / 2, y: 298, scaleX: 5) { g in
            Art.glow(&g, 0, 0, 30, Art.color(0xFFB93D), alpha: 0.22)
        }
        ArtStyle.contactShadow(&context, w / 2 + 12, 297, 120, 14, alpha: 0.42)

        pot(&context, w / 2, 184, 5.5, glow: true, sealed: true)

        // A little more modelling for the close-up: light through the clay, a dark foot, tooth.
        Art.group(&context, x: w / 2, y: 184, scale: 5.5) { g in
            let body = Art.svg("M-11,-17 C-13,-21 -12,-24 -9,-24 L9,-24 C12,-24 13,-21 11,-17 C20,-12 22,-2 20,6 C17,17 9,21 0,21 C-9,21 -17,17 -20,6 C-22,-2 -20,-12 -11,-17Z")
            Art.clipped(&g, to: body) { c in
                Art.glow(&c, 1, 3, 20, Art.color(0xFFE27A), alpha: 0.26)
                Art.fill(&c, Art.ellipse(0, 25, 26, 9), Art.color(0x3A160E, 0.5))
                Art.stipple(
                    &c,
                    in: CGRect(x: -22, y: -25, width: 44, height: 47),
                    count: 170, seed: 5, color: Art.color(0x3A160E), alpha: 0.2, size: 0.1...0.36
                )
                Art.stipple(
                    &c,
                    in: CGRect(x: -22, y: -25, width: 30, height: 30),
                    count: 60, seed: 8, color: Art.color(0xFFE0B0), alpha: 0.22, size: 0.1...0.3
                )
            }
            // The one light on the clay: warm on the upper left, indigo toward the lower right.
            ArtStyle.form(&g, body, bounds: CGRect(x: -22, y: -25, width: 44, height: 47), light: 0.14, shade: 0.24)
        }

        let sparks: [(CGFloat, CGFloat, CGFloat, Int)] = [
            (66, 98, 1.4, 1), (368, 124, 1.3, 0), (52, 208, 1, 2), (384, 220, 1.1, 1),
            (74, 262, 0.8, 2), (362, 270, 0.8, 2), (316, 50, 0.9, 2), (112, 58, 0.7, 2),
        ]
        motes(&context, sparks)

        // The bottom quarter stays quiet: the card fades it into its own colour.
        let fade: [(Color, CGFloat)] = [(card.opacity(0), 0), (card.opacity(0.9), 1)]
        Art.fillLinear(&context, Art.rect(0, h - 120, w, 120), fade, from: pt(0, h - 120), to: pt(0, h))
        finishPicture(&context, size)
    }

    // MARK: - See: the forest

    /// The one great tree of the forest picture: a buttressed rain-forest trunk standing on
    /// (cx, base), rising out of the top edge, its roots spreading to about 60% of the
    /// picture's width. Lit from the upper left.
    static func forestGiant(_ context: inout GraphicsContext, _ cx: CGFloat, _ base: CGFloat) {
        Art.group(&context, x: cx, y: base) { g in
            var outline = Path()
            outline.move(to: pt(-38, -330))
            outline.addCurve(to: pt(-42, -114), control1: pt(-34, -240), control2: pt(-40, -170))
            outline.addCurve(to: pt(-130, 0), control1: pt(-46, -54), control2: pt(-84, -18))
            outline.addQuadCurve(to: pt(-60, -4), control: pt(-96, -12))
            outline.addQuadCurve(to: pt(0, 2), control: pt(-30, 8))
            outline.addQuadCurve(to: pt(64, -4), control: pt(34, 8))
            outline.addQuadCurve(to: pt(126, 0), control: pt(98, -14))
            outline.addCurve(to: pt(42, -114), control1: pt(82, -18), control2: pt(46, -54))
            outline.addCurve(to: pt(38, -330), control1: pt(40, -170), control2: pt(34, -240))
            outline.closeSubpath()
            let trunk = outline
            let bark: [(Color, CGFloat)] = [
                (Art.color(0x8A6282), 0), (Art.color(0x4A2C5E), 0.3), (Art.color(0x2A1848), 0.65), (Art.color(0x180E32), 1),
            ]
            Art.fillLinear(&g, trunk, bark, from: pt(-70, 0), to: pt(50, 0))

            // The buttress roots: a lit face on the left, the middle fin, a shaded face on the right.
            Art.fill(
                &g,
                Art.svg("M-26,-106 C-32,-56 -56,-22 -96,-2 L-52,0 C-30,-24 -16,-54 -12,-96Z"),
                ArtStyle.warmLight.opacity(0.2)
            )
            Art.fill(
                &g,
                Art.svg("M-2,-100 C-6,-50 -16,-16 -32,2 L16,4 C10,-24 8,-54 10,-96Z"),
                Art.color(0x180E32, 0.5)
            )
            Art.fill(
                &g,
                Art.svg("M30,-106 C36,-56 60,-22 102,-2 L66,0 C42,-24 28,-54 22,-94Z"),
                Art.color(0x120A26, 0.6)
            )
            Art.stroke(&g, Art.svg("M-2,-100 C-6,-50 -16,-16 -32,2"), ArtStyle.warmLight.opacity(0.34), width: ArtStyle.detailLine)
            Art.stroke(&g, Art.svg("M-26,-106 C-32,-56 -56,-22 -96,-2"), ArtStyle.warmLight.opacity(0.4), width: ArtStyle.detailLine)

            // Bark lines in a darker tone, and tooth.
            Art.stroke(
                &g,
                Art.svg("M-18,-320 C-14,-240 -20,-170 -18,-118 M4,-324 C8,-240 2,-180 4,-112 M22,-322 C26,-250 20,-170 24,-120"),
                ArtStyle.coolShade.opacity(0.4), width: ArtStyle.detailLine
            )
            Art.clipped(&g, to: trunk) { c in
                Art.stipple(
                    &c,
                    in: CGRect(x: -130, y: -322, width: 260, height: 326),
                    count: 160, seed: 12, color: ArtStyle.coolShade, alpha: 0.12, size: 0.5...1.4
                )
            }

            // The warm edge of the one light down the left of the trunk and along the root.
            Art.stroke(&g, Art.svg("M-37,-326 C-33,-240 -39,-170 -41,-114"), Art.color(0xFFE9D2, 0.65), width: ArtStyle.contourLine)
            Art.stroke(&g, Art.svg("M-41,-114 C-45,-54 -83,-18 -128,-1"), Art.color(0xFFE9D2, 0.4), width: ArtStyle.contourLine)
        }
    }

    /// The rain forest as one clear subject: a single great buttressed tree in the middle,
    /// lianas hanging from its crown, smaller trees receding behind it in the haze, and a
    /// shaft of warm light from the upper left. 432 × 404; the bottom quarter is quiet and
    /// tends to the card colour #12303A.
    static func forestPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        let h = size.height
        let card = Art.color(0x12303A)

        // The forest air: the story's indigo above, the card's deep green below.
        let air: [(Color, CGFloat)] = [
            (Art.color(0x15143C), 0), (Art.color(0x1B3550), 0.4), (Art.color(0x1F5A5A), 0.68), (card, 1),
        ]
        Art.fillLinear(&context, Art.rect(0, 0, w, h), air, from: pt(0, 0), to: pt(0, h))
        // The one light, low and warm, from the upper left.
        Art.glow(&context, 96, 96, 260, ArtStyle.warmLight, alpha: 0.26)

        // Far plane: thin trunks deep in the haze, close to the air's own value.
        let far: [(CGFloat, CGFloat, CGFloat)] = [
            (22, 12, 250), (128, 10, 246), (168, 7, 242), (268, 8, 244), (318, 12, 248), (410, 11, 252),
        ]
        for item in far {
            forestTrunk(&context, item.0, item.1, item.2, dark: Art.color(0x24506A), light: Art.color(0x3A7480), rim: 0)
        }
        ArtStyle.atmosphere(&context, width: w, top: 60, bottom: 262, color: Art.color(0x4A8A84), alpha: 0.3)

        // Middle plane: two nearer trunks, one on each side, darker.
        forestTrunk(&context, 66, 30, 276, dark: Art.color(0x152A48), light: Art.color(0x2A5670), rim: 0.2)
        forestTrunk(&context, 376, 26, 274, dark: Art.color(0x152A48), light: Art.color(0x2A5670), rim: 0.18)
        let mist: [(Color, CGFloat)] = [(Art.color(0x8FD0B0, 0), 0), (Art.color(0x8FD0B0, 0.12), 1)]
        Art.fillLinear(&context, Art.rect(0, 150, w, 130), mist, from: pt(0, 150), to: pt(0, 280))

        // The forest floor: simple, in the card's own green, with a pool of warm light at
        // the foot of the tree.
        var floorPath = Path()
        floorPath.move(to: pt(0, 268))
        floorPath.addCurve(to: pt(w, 264), control1: pt(w * 0.3, 258), control2: pt(w * 0.7, 272))
        floorPath.addLine(to: pt(w, h))
        floorPath.addLine(to: pt(0, h))
        floorPath.closeSubpath()
        let floorTone: [(Color, CGFloat)] = [(Art.color(0x1A4A4E), 0), (Art.color(0x163C44), 0.4), (card, 1)]
        Art.fillLinear(&context, floorPath, floorTone, from: pt(0, 262), to: pt(0, 340))
        Art.group(&context, x: 168, y: 298, scale: 0.3, scaleX: 9) { g in
            Art.glow(&g, 0, 0, 50, ArtStyle.warmLight, alpha: 0.3)
        }

        // A shaft of the warm light from the upper left, falling on the tree.
        Art.blurred(&context, radius: 6) { g in
            let light: [(Color, CGFloat)] = [
                (Art.color(0xFFE9A8, 0.34), 0), (Art.color(0xFFD98A, 0.16), 0.6), (Art.color(0xFFD98A, 0), 1),
            ]
            let beam: [CGPoint] = [pt(-20, 0), pt(84, 0), pt(250, 310), pt(96, 310)]
            Art.fillLinear(&g, Art.polygon(beam), light, from: pt(30, 0), to: pt(180, 310))
            let thin: [CGPoint] = [pt(120, 0), pt(150, 0), pt(300, 300), pt(250, 300)]
            Art.fillLinear(&g, Art.polygon(thin), light, from: pt(130, 0), to: pt(280, 300))
        }

        // The great tree, with its shadow falling to the lower right.
        ArtStyle.contactShadow(&context, w / 2 + 14, 306, 140, 12, alpha: 0.4)
        forestGiant(&context, w / 2, 304)

        // Lianas from the crown: two with leaves beside the trunk, a loop behind them and
        // one bare liana hanging across the bark.
        let vineColor = Art.color(0x14234A)
        let vineLeaf = Art.color(0x2C6A7C)
        var loop = Path()
        loop.move(to: pt(150, 52))
        loop.addCurve(to: pt(292, 60), control1: pt(170, 150), control2: pt(280, 150))
        Art.stroke(&context, loop, vineColor, width: ArtStyle.contourLine)
        vine(&context, 150, 50, 150, 12, vineColor, leafColor: vineLeaf)
        vine(&context, 292, 44, 120, -10, vineColor, leafColor: vineLeaf)
        var liana = Path()
        liana.move(to: pt(236, 40))
        liana.addCurve(to: pt(232, 198), control1: pt(214, 90), control2: pt(254, 140))
        Art.stroke(&context, liana, vineColor, width: ArtStyle.contourLine)
        Art.stroke(&context, liana, ArtStyle.warmLight.opacity(0.18), width: 0.8)

        // The tree's own crown across the top.
        let blobs: [(CGFloat, CGFloat, CGFloat)] = [(216, -8, 124), (96, 6, 72), (338, 2, 78), (20, -6, 48), (420, -4, 50)]
        nightCanopy(&context, blobs, seed: 33, palette: canopyPalette)

        // Near plane, kept low and small: leaves and grass at the foot of the tree.
        leaf(&context, 96, 314, 62, -152, dark: true)
        leaf(&context, 100, 314, 56, -112, dark: false)
        leaf(&context, 340, 314, 60, -30, dark: true)
        leaf(&context, 336, 314, 54, -72, dark: false)
        grass(&context, 186, 312, 1.4, seed: 5)
        grass(&context, 262, 314, 1.2, seed: 6)

        // Fireflies in the lit air, above the quiet bottom quarter.
        fireflies(&context, 14, seed: 31, in: CGRect(x: 70, y: 110, width: w - 140, height: 170))

        let fade: [(Color, CGFloat)] = [(card.opacity(0), 0), (card.opacity(0.8), 1)]
        Art.fillLinear(&context, Art.rect(0, h - 110, w, 110), fade, from: pt(0, h - 110), to: pt(0, h))
        finishPicture(&context, size)
    }

    // MARK: - Portrait: Kweku Tsin

    /// Kweku Tsin, the watchful boy, peeking between two big leaves. 432 × 400.
    static func kwekuPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        // The card's own colours (story.json: #FFD35A → #FFAE45) and a pale warm halo.
        ArtStyle.portraitBackdrop(
            &context,
            size,
            top: Art.color(0xFFD35A),
            bottom: Art.color(0xFFAE45),
            halo: Art.color(0xFFF3C2),
            rays: false
        )

        // Leaves behind him: the far ones paler, as if in warm haze.
        leaf(&context, -34, 330, 270, -48, dark: true)
        leaf(&context, w + 34, 322, 262, -134, dark: true)
        ArtStyle.atmosphere(&context, width: w, top: 60, bottom: 400, color: Art.color(0xFFC860), alpha: 0.22)

        // Head and shoulders to the waist: the top of his hair about 60 units down, his
        // eyes near the upper third, looking a little toward the reader's left.
        let scale: CGFloat = 2.7
        let faceY: CGFloat = 152
        Art.group(&context, x: w / 2, y: faceY, scale: scale) { g in
            kwekuBust(&g, lookX: 1.2, lookY: -0.6, mouthOpen: false, tilt: 5, showsWhite: true)
        }

        // The two leaves he holds apart, and smaller ones across the bottom.
        leaf(&context, 6, 402, 290, -66, dark: false)
        leaf(&context, w - 6, 404, 290, -114, dark: false)
        leaf(&context, 84, 452, 190, -28, dark: true)
        leaf(&context, w - 84, 454, 190, -152, dark: true)

        Art.group(&context, x: w / 2, y: faceY, scale: scale) { g in
            kwekuHands(&g)
        }

        fireflies(&context, 6, seed: 15, in: CGRect(x: 24, y: 210, width: w - 48, height: 120), dim: 0.8)
        finishPicture(&context, size)
    }

    // MARK: - Portrait: Father Anansi

    /// Father Anansi holding the pot, the moon on his upper left, a fine web and a tiny
    /// spider in the other corner. 432 × 400.
    static func anansiPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        // The card's own colours (story.json: #6B3A7E → #3A1F6B) and a lamplight halo.
        ArtStyle.portraitBackdrop(
            &context,
            size,
            top: Art.color(0x6B3A7E),
            bottom: Art.color(0x3A1F6B),
            halo: ArtStyle.anansi.glowColor,
            rays: false
        )
        stars(&context, 22, seed: 23, in: CGRect(x: 0, y: 0, width: w, height: 130), alpha: 0.6)
        // The one light: the moon on the upper left, just clear of the close button.
        moon(&context, 104, 92, 32)

        // His namesake: a web in the top right corner and a small spider on its thread.
        spiderWeb(&context, w, 0, 190, 1.64, 3.08, alpha: 0.7, width: 0.9)
        Art.stroke(&context, Art.line(w - 104, 0, w - 104, 118), ArtStyle.warmLight.opacity(0.6), width: 0.8, cap: .butt)
        spider(&context, w - 104, 124, 1.5)

        // Shoulders.
        Art.fill(&context, Art.rect(194, 212, 44, 46, radius: 12), skinDark)
        let torso = Art.svg("M92,400 C88,322 108,264 160,248 C190,240 242,240 272,248 C324,264 344,322 340,400Z")
        let torsoTone: [(Color, CGFloat)] = [(skinLight, 0), (skin, 0.5), (skinDark, 1)]
        Art.fillRadial(&context, torso, torsoTone, center: pt(176, 270), radius: 210)
        // The warm edge of the light along his bare left shoulder.
        Art.stroke(
            &context,
            Art.svg("M96,372 C96,318 114,270 160,250"),
            ArtStyle.warmLight.opacity(0.45), width: ArtStyle.contourLine
        )

        // Cloth over one shoulder: lit on the side toward the light, in shade on the far side.
        let cloth = Art.svg("M272,246 C326,262 346,322 342,400 L112,400 C140,340 204,286 272,246Z")
        kente(&context, in: cloth, scale: 1.25)
        let shade: [(Color, CGFloat)] = [
            (Art.color(0xFFE9A8, 0.22), 0), (ArtStyle.coolShade.opacity(0), 0.4), (ArtStyle.coolShade.opacity(0.36), 1),
        ]
        Art.fillLinear(&context, cloth, shade, from: pt(112, 0), to: pt(342, 0))
        Art.fill(
            &context,
            Art.svg("M256,250 C292,252 330,272 341,332 C330,320 312,312 296,312 C292,286 278,264 256,250Z"),
            ArtStyle.coolShade.opacity(0.24)
        )
        Art.stroke(
            &context,
            Art.svg("M250,262 C210,300 172,350 152,400 M300,314 C298,344 302,372 308,400"),
            ArtStyle.coolShade.opacity(0.26), width: ArtStyle.contourLine
        )
        Art.stroke(
            &context,
            Art.svg("M272,246 C204,286 140,340 112,400"),
            Art.color(0xFFE9A8, 0.4), width: ArtStyle.detailLine
        )

        // The pot in his arms.
        Art.glow(&context, 206, 338, 150, Art.color(0xFFC94D), alpha: 0.35)
        pot(&context, 206, 338, 2.5)

        // Arms and hands round the pot.
        limb(&context, "M112,296 C94,336 104,370 148,376", 36, skin)
        Art.group(&context, x: 158, y: 366, rotate: rad(-20)) { g in
            Art.fill(&g, Art.ellipse(0, 0, 23, 16), skin)
            Art.stroke(&g, Art.svg("M4,-8 q6,2 10,7 M2,-1 q7,1 12,5 M0,6 q6,0 10,3"), skinDark.opacity(0.6), width: ArtStyle.detailLine)
        }
        limb(&context, "M304,330 C294,350 280,358 264,356", 30, skinWarm)
        Art.group(&context, x: 256, y: 352, rotate: rad(22)) { g in
            Art.fill(&g, Art.ellipse(0, 0, 22, 16), skinWarm)
            Art.stroke(&g, Art.svg("M-4,-8 q-6,2 -10,7 M-2,-1 q-7,1 -12,5 M0,6 q-6,0 -10,3"), skinDark.opacity(0.6), width: ArtStyle.detailLine)
        }

        // Head, lit a little by the pot from below. The top of his hair sits about 60 units
        // down (clear of the close button) and his eyes near the upper third.
        Art.group(&context, x: w / 2, y: 146, scale: 2.6) { g in
            anansiHead(&g, detail: true, showsWhite: true)
        }
        ArtStyle.rimLight(&context, w / 2, 146, 62, alpha: 0.2)
        Art.glow(&context, 212, 262, 60, Art.color(0xFFC94D), alpha: 0.18)

        let sparks: [(CGFloat, CGFloat, CGFloat, Int)] = [
            (70, 250, 1.1, 1), (52, 320, 0.8, 2), (380, 232, 1, 2), (392, 300, 1.2, 0), (96, 196, 0.7, 2),
        ]
        motes(&context, sparks)
        finishPicture(&context, size)
    }

    // MARK: - Faces

    /// Anansi's head on #D8342B (design `faceAnansi`, view box -36 -38 72 76).
    static func anansiFace(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        let h = size.height
        Art.fill(&context, Art.rect(0, 0, w, h), kRed)
        Art.glow(&context, w * 0.5, h * 0.4, w * 0.7, Art.color(0xF0584A), alpha: 0.6)
        // The face fills about 80% of the circle, eyes on the centre line.
        let s = min(w, h) / 70
        Art.group(&context, x: w / 2, y: h / 2 + s, scale: s) { g in
            anansiHead(&g, showsWhite: true)
        }
    }

    /// Kweku's head on #F7B520 (design `faceKweku`, view box -36 -38 72 72).
    static func kwekuFace(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        let h = size.height
        Art.fill(&context, Art.rect(0, 0, w, h), kGold)
        Art.glow(&context, w * 0.5, h * 0.4, w * 0.7, Art.color(0xFFD25A), alpha: 0.6)
        // The face fills about 80% of the circle, eyes on the centre line.
        let s = min(w, h) / 70
        Art.group(&context, x: w / 2, y: h / 2 + s, scale: s) { g in
            kwekuHead(&g, lookX: 0, lookY: 0, mouthOpen: false, showsWhite: true)
        }
    }

    // MARK: - Cover

    /// Anansi on the tree with the glowing pot, the big moon on his upper left. 300 wide,
    /// 150…375 tall: the figure and the moon sit round the vertical middle; canopy and ground
    /// follow the edges.
    static func coverPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        let h = size.height
        let cy = h / 2

        let night: [(Color, CGFloat)] = [
            (Art.color(0x120D38), 0), (Art.color(0x2A1A60), 0.35), (Art.color(0x5A2A78), 0.62),
            (Art.color(0xA8406E), 0.84), (Art.color(0xF0804E), 0.96), (Art.color(0xFFB45A), 1),
        ]
        Art.fillLinear(&context, Art.rect(0, 0, w, h), night, from: pt(0, 0), to: pt(0, h))
        stars(&context, 40, seed: 17, in: CGRect(x: 0, y: 0, width: w, height: h * 0.7))
        // The one light: the moon, upper left of the climber.
        let moonY: CGFloat = max(38, cy - 56)
        moon(&context, 56, moonY, 32)

        // Far plane: a ridge, far trees, the ember band; then the ground along the bottom edge.
        var ridge = Path()
        ridge.move(to: pt(0, h - 26))
        ridge.addCurve(to: pt(w, h - 30), control1: pt(w * 0.3, h - 44), control2: pt(w * 0.7, h - 18))
        ridge.addLine(to: pt(w, h))
        ridge.addLine(to: pt(0, h))
        ridge.closeSubpath()
        Art.fill(&context, ridge, Art.color(0x5E2F7A, 0.5))
        let far: [(CGFloat, CGFloat)] = [(22, 0.5), (62, 0.34), (246, 0.46), (284, 0.36)]
        for (i, tree) in far.enumerated() {
            umbrellaTree(&context, tree.0, h - 8, 60 * tree.1 + 24, tree.1 * 0.8, Art.color(0x3A2466), seed: UInt32(40 + i))
        }
        // The shared ember band on the horizon, over the far trees so they stay hazy.
        let glowRise: CGFloat = min(70, h * 0.3)
        ArtStyle.horizonGlow(&context, width: w, y: h - 14, rise: glowRise, color: ArtStyle.anansi.glowColor, alpha: 0.4)
        var ground = Path()
        ground.move(to: pt(0, h - 14))
        ground.addCurve(to: pt(w, h - 12), control1: pt(w * 0.3, h - 22), control2: pt(w * 0.7, h - 8))
        ground.addLine(to: pt(w, h))
        ground.addLine(to: pt(0, h))
        ground.closeSubpath()
        Art.fill(&context, ground, Art.color(0x1A0F33))

        // The trunk: lit on its left, in shade on its right.
        var trunk = Path()
        trunk.move(to: pt(148, 0))
        trunk.addCurve(to: pt(146, h - 60), control1: pt(150, h * 0.3), control2: pt(147, h * 0.6))
        trunk.addCurve(to: pt(118, h), control1: pt(145, h - 30), control2: pt(134, h - 12))
        trunk.addLine(to: pt(232, h))
        trunk.addCurve(to: pt(198, h - 60), control1: pt(214, h - 12), control2: pt(200, h - 30))
        trunk.addCurve(to: pt(197, 0), control1: pt(196, h * 0.6), control2: pt(196, h * 0.3))
        trunk.closeSubpath()
        let bark: [(Color, CGFloat)] = [
            (Art.color(0x8A6282), 0), (Art.color(0x4A2C5E), 0.3), (Art.color(0x22123F), 0.7), (Art.color(0x150A2C), 1),
        ]
        Art.fillLinear(&context, trunk, bark, from: pt(126, 0), to: pt(204, 0))
        var grooves = Path()
        grooves.move(to: pt(162, 0))
        grooves.addQuadCurve(to: pt(160, h - 50), control: pt(165, h * 0.5))
        grooves.move(to: pt(180, 0))
        grooves.addQuadCurve(to: pt(182, h - 44), control: pt(178, h * 0.5))
        Art.stroke(&context, grooves, Art.color(0x1B0F33, 0.45), width: ArtStyle.detailLine)
        var rimLine = Path()
        rimLine.move(to: pt(149, 0))
        rimLine.addCurve(to: pt(147, h - 60), control1: pt(151, h * 0.3), control2: pt(148, h * 0.6))
        rimLine.addCurve(to: pt(120, h), control1: pt(146, h - 30), control2: pt(135, h - 12))
        Art.stroke(&context, rimLine, Art.color(0xFFE9D2, 0.6), width: ArtStyle.detailLine)

        // Web and spider against the moon.
        spiderWeb(&context, 148, moonY - 26, 84, 2.5, 3.3)
        Art.stroke(&context, Art.line(70, moonY - 40, 70, moonY + 8), ArtStyle.warmLight.opacity(0.6), width: 0.7, cap: .butt)
        spider(&context, 70, moonY + 12, 1)

        // A thin canopy along the top edge.
        let blobs: [(CGFloat, CGFloat, CGFloat)] = [(150, -24, 64), (50, -26, 56), (250, -24, 60), (300, -10, 36), (0, -12, 30)]
        nightCanopy(&context, blobs, seed: 14, palette: canopyPalette)

        // Father Anansi and the pot.
        Art.glow(&context, 138, cy + 22, 78, Art.color(0xFFC94D), alpha: 0.32)
        anansiClimbing(&context, 112, cy + 38, 0.95)
        let sparks: [(CGFloat, CGFloat, CGFloat, Int)] = [
            (84, 22, 1, 1), (62, 48, 0.8, 2), (44, 14, 0.7, 2), (92, 62, 0.7, 2), (236, -44, 1.1, 0), (262, 4, 0.7, 2),
        ]
        motes(&context, sparks, dx: 0, dy: cy)
        fireflies(&context, 8, seed: 29, in: CGRect(x: 204, y: cy + 20, width: 90, height: max(20, cy - 40)))

        // A woven band along the bottom edge.
        let bandH = max(8, min(16, h * 0.06))
        Art.group(&context, x: 0, y: h - bandH) { g in
            kente(&g, in: Art.rect(0, 0, w, bandH), scale: bandH / 24)
            Art.fill(&g, Art.rect(0, -1.5, w, 1.5), ArtStyle.anansi.deepColor)
        }
        finishPicture(&context, size)
    }
}
