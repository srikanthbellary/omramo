import SwiftUI
import Foundation
import OmramoCore

// The single pictures of the Anansi story: tap-to-see pictures, character portraits,
// face chips and the cover.

extension AnansiArt {
    // MARK: - See: the precious pot

    /// The great sealed pot, close up. 432 × 404; the lower part tends to the card colour #2A1650.
    static func potPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        let h = size.height
        let card = Art.color(0x2A1650)
        Art.fill(&context, Art.rect(0, 0, w, h), card)
        let room: [(Color, CGFloat)] = [(Art.color(0x5A3396), 0), (Art.color(0x3A2068), 0.5), (card, 1)]
        Art.fillRadial(&context, Art.rect(0, 0, w, h), room, center: pt(w / 2, 180), radius: 300)

        stars(&context, 28, seed: 11, in: CGRect(x: 0, y: 0, width: w, height: 200), alpha: 0.6)
        spiderWeb(&context, w, 0, 230, 1.62, 3.08, alpha: 0.5, width: 0.9)

        // Light from inside the pot, and its shadow on the ground.
        Art.glow(&context, w / 2, 190, 240, Art.color(0xFFC94D), alpha: 0.35)
        Art.group(&context, x: w / 2, y: 298, scaleX: 4.4) { g in
            Art.glow(&g, 0, 0, 24, Art.color(0x120A2A), alpha: 0.7)
        }
        Art.group(&context, x: w / 2, y: 300, scaleX: 5) { g in
            Art.glow(&g, 0, 0, 30, Art.color(0xFFB93D), alpha: 0.22)
        }

        pot(&context, w / 2, 186, 5, glow: true, sealed: true)

        // A little more modelling for the close-up: light through the clay, a dark foot, tooth.
        Art.group(&context, x: w / 2, y: 186, scale: 5) { g in
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
        }

        let sparks: [(CGFloat, CGFloat, CGFloat, Int)] = [
            (92, 98, 1.4, 1), (340, 124, 1.3, 0), (66, 222, 1, 2), (366, 236, 1.1, 1),
            (118, 292, 0.8, 2), (322, 306, 0.8, 2), (252, 44, 0.9, 2), (160, 54, 0.7, 2),
        ]
        motes(&context, sparks)

        let fade: [(Color, CGFloat)] = [(card.opacity(0), 0), (card.opacity(0.9), 1)]
        Art.fillLinear(&context, Art.rect(0, h - 120, w, 120), fade, from: pt(0, h - 120), to: pt(0, h))
        tooth(&context, w, h, count: 180)
    }

    // MARK: - See: the forest

    /// A great trunk with buttress roots, from the top edge down to `base`.
    static func buttressTrunk(
        _ context: inout GraphicsContext,
        _ x: CGFloat, _ w: CGFloat, _ base: CGFloat,
        litLeft: Bool
    ) {
        let a = w / 2
        let yF = base - 170
        var p = Path()
        p.move(to: pt(x - a * 0.9, 0))
        p.addCurve(to: pt(x - a, yF), control1: pt(x - a * 0.86, yF * 0.4), control2: pt(x - a * 1.04, yF * 0.8))
        p.addCurve(to: pt(x - a * 3, base), control1: pt(x - a * 1.1, yF + 70), control2: pt(x - a * 1.9, yF + 130))
        p.addLine(to: pt(x + a * 3, base))
        p.addCurve(to: pt(x + a, yF), control1: pt(x + a * 1.9, yF + 130), control2: pt(x + a * 1.1, yF + 70))
        p.addCurve(to: pt(x + a * 0.9, 0), control1: pt(x + a * 1.04, yF * 0.8), control2: pt(x + a * 0.86, yF * 0.4))
        p.closeSubpath()

        let dark = Art.color(0x081A22)
        let light = Art.color(0x1A4A54)
        var stops: [(Color, CGFloat)] = [(dark, 0), (dark, 0.4), (light, 1)]
        if litLeft {
            stops = [(light, 0), (dark, 0.6), (dark, 1)]
        }
        Art.fillLinear(&context, p, stops, from: pt(x - a, 0), to: pt(x + a, 0))

        // The middle buttress, seen edge on.
        var fin = Path()
        fin.move(to: pt(x - a * 0.15, yF + 10))
        fin.addCurve(to: pt(x - a * 1.4, base), control1: pt(x - a * 0.3, yF + 90), control2: pt(x - a * 0.9, yF + 140))
        fin.addLine(to: pt(x + a * 0.5, base))
        fin.addCurve(to: pt(x + a * 0.1, yF + 10), control1: pt(x + a * 0.2, yF + 130), control2: pt(x + a * 0.12, yF + 70))
        fin.closeSubpath()
        Art.fill(&context, fin, Art.color(0x05121A, 0.55))
        var ridge = Path()
        ridge.move(to: pt(x - a * 0.15, yF + 10))
        ridge.addCurve(to: pt(x - a * 1.4, base), control1: pt(x - a * 0.3, yF + 90), control2: pt(x - a * 0.9, yF + 140))
        Art.stroke(&context, ridge, Art.color(0xFFE9A8, 0.28), width: 1.6)

        var grooves = Path()
        let offsets: [CGFloat] = [-0.45, 0.2, 0.55]
        for offset in offsets {
            grooves.move(to: pt(x + a * offset, 8))
            grooves.addQuadCurve(to: pt(x + a * offset * 1.1, yF), control: pt(x + a * offset + 3, yF * 0.5))
        }
        Art.stroke(&context, grooves, Art.color(0x05121A, 0.45), width: 1.6, cap: .butt)

        // Low light catching one edge.
        let sign: CGFloat = litLeft ? -1 : 1
        var edge = Path()
        edge.move(to: pt(x + sign * a * 0.9, 0))
        edge.addCurve(
            to: pt(x + sign * a, yF),
            control1: pt(x + sign * a * 0.86, yF * 0.4),
            control2: pt(x + sign * a * 1.04, yF * 0.8)
        )
        edge.addCurve(
            to: pt(x + sign * a * 3, base),
            control1: pt(x + sign * a * 1.1, yF + 70),
            control2: pt(x + sign * a * 1.9, yF + 130)
        )
        Art.stroke(&context, edge, Art.color(0xFFE9A8, 0.42), width: 2)
    }

    /// The rain forest: buttressed trunks, vines, big leaves, low golden light, fireflies.
    /// 432 × 404; the lower part tends to the card colour #12303A.
    static func forestPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        let h = size.height
        let card = Art.color(0x12303A)
        let air: [(Color, CGFloat)] = [
            (Art.color(0x0A1F2A), 0), (Art.color(0x14404A), 0.42), (Art.color(0x1E5E5A), 0.68), (card, 1),
        ]
        Art.fillLinear(&context, Art.rect(0, 0, w, h), air, from: pt(0, 0), to: pt(0, h))
        Art.glow(&context, 236, 150, 230, Art.color(0xFFE9A8), alpha: 0.28)

        // Far trunks in the haze.
        let far: [(CGFloat, CGFloat)] = [(150, 26), (196, 10), (232, 16), (292, 30)]
        for trunk in far {
            forestTrunk(&context, trunk.0, trunk.1, h - 56, dark: Art.color(0x1A4A52), light: Art.color(0x2A6A6A), rim: 0)
        }
        let mist: [(Color, CGFloat)] = [(Art.color(0x8FD0B0, 0), 0), (Art.color(0x8FD0B0, 0.14), 1)]
        Art.fillLinear(&context, Art.rect(0, 110, w, 210), mist, from: pt(0, 110), to: pt(0, 320))

        // Shafts of low golden light.
        Art.blurred(&context, radius: 5) { g in
            let beams: [[CGPoint]] = [
                [pt(118, 0), pt(172, 0), pt(332, h), pt(236, h)],
                [pt(214, 0), pt(244, 0), pt(424, h), pt(372, h)],
                [pt(36, 0), pt(68, 0), pt(192, h), pt(128, h)],
            ]
            let light: [(Color, CGFloat)] = [
                (Art.color(0xFFE9A8, 0.3), 0), (Art.color(0xFFD98A, 0.14), 0.6), (Art.color(0xFFD98A, 0), 1),
            ]
            for beam in beams {
                Art.fillLinear(&g, Art.polygon(beam), light, from: pt(150, 0), to: pt(290, h))
            }
        }

        buttressTrunk(&context, 64, 78, h - 6, litLeft: false)
        buttressTrunk(&context, 356, 96, h + 4, litLeft: true)

        // Hanging vines.
        let vineColor = Art.color(0x0A2230)
        let vineLeaf = Art.color(0x2B6A7A)
        vine(&context, 128, 40, 170, 12, vineColor, leafColor: vineLeaf)
        vine(&context, 176, 30, 110, -8, vineColor, leafColor: vineLeaf)
        vine(&context, 262, 44, 200, 10, vineColor, leafColor: vineLeaf)
        vine(&context, 300, 36, 120, -10, vineColor, leafColor: vineLeaf)
        var loop = Path()
        loop.move(to: pt(100, 30))
        loop.addCurve(to: pt(310, 40), control1: pt(150, 150), control2: pt(250, 150))
        Art.stroke(&context, loop, vineColor, width: 2.2)

        // Canopy overhead.
        let blobs: [(CGFloat, CGFloat, CGFloat)] = [(60, 0, 90), (200, -12, 80), (340, 4, 100), (432, 62, 50)]
        let pal: [Color] = [Art.color(0x0A2230), Art.color(0x10364A), Art.color(0x2B6A7A), Art.color(0x8FD0B0)]
        nightCanopy(&context, blobs, seed: 33, palette: pal)

        // Big leaves in the foreground.
        leaf(&context, -14, 400, 170, -38, dark: true)
        leaf(&context, 48, 432, 160, -72, dark: false)
        leaf(&context, 150, 440, 120, -96, dark: true)
        leaf(&context, 446, 396, 180, -142, dark: true)
        leaf(&context, 384, 434, 160, -108, dark: false)
        leaf(&context, 270, 446, 120, -84, dark: true)

        fireflies(&context, 16, seed: 31, in: CGRect(x: 24, y: 120, width: w - 48, height: 220))

        let fade: [(Color, CGFloat)] = [(card.opacity(0), 0), (card.opacity(0.75), 1)]
        Art.fillLinear(&context, Art.rect(0, h - 110, w, 110), fade, from: pt(0, h - 110), to: pt(0, h))
        tooth(&context, w, h, count: 200)
    }

    // MARK: - Portrait: Kweku Tsin

    /// Kweku Tsin, the watchful boy, peeking between two big leaves. 432 × 400.
    static func kwekuPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        let h = size.height
        let back: [(Color, CGFloat)] = [
            (Art.color(0x3A1F6B), 0), (Art.color(0x8A3F78), 0.5), (Art.color(0xF09A4A), 1),
        ]
        Art.fillLinear(&context, Art.rect(0, 0, w, h), back, from: pt(w * 0.5, 0), to: pt(w * 0.5, h))
        stars(&context, 18, seed: 13, in: CGRect(x: 0, y: 0, width: w, height: 120), alpha: 0.6)
        Art.glow(&context, w / 2, 182, 215, Art.color(0xFFD98A), alpha: 0.75)
        Art.fill(&context, Art.circle(w / 2, 186, 128), Art.color(0xFFE9A8, 0.16))

        // Leaves behind him.
        leaf(&context, -34, 330, 270, -48, dark: true)
        leaf(&context, w + 34, 322, 262, -134, dark: true)

        let scale: CGFloat = 3.1
        Art.group(&context, x: w / 2, y: 186, scale: scale) { g in
            kwekuBust(&g, lookX: 2.2, lookY: -2.2, mouthOpen: false, tilt: 6)
        }

        // The two leaves he holds apart, and smaller ones across the bottom.
        leaf(&context, -24, 424, 300, -66, dark: false)
        leaf(&context, w + 24, 428, 300, -114, dark: false)
        leaf(&context, 84, 452, 190, -28, dark: true)
        leaf(&context, w - 84, 454, 190, -152, dark: true)

        Art.group(&context, x: w / 2, y: 186, scale: scale) { g in
            kwekuHands(&g)
        }

        fireflies(&context, 7, seed: 15, in: CGRect(x: 20, y: 40, width: w - 40, height: 200))
        tooth(&context, w, h, count: 180)
    }

    // MARK: - Portrait: Father Anansi

    /// Father Anansi holding the pot, with a fine web and a tiny spider in the corner. 432 × 400.
    static func anansiPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        let h = size.height
        let back: [(Color, CGFloat)] = [
            (Art.color(0x150E3A), 0), (Art.color(0x2A1860), 0.55), (Art.color(0x4A2470), 1),
        ]
        Art.fillLinear(&context, Art.rect(0, 0, w, h), back, from: pt(0, 0), to: pt(0, h))
        stars(&context, 34, seed: 23, in: CGRect(x: 0, y: 0, width: w, height: 240), alpha: 0.8)
        moon(&context, 336, 92, 44)
        Art.glow(&context, w / 2, 170, 200, Art.color(0x7A4AAA), alpha: 0.35)

        // His namesake: a web in the corner and a small spider on its thread.
        spiderWeb(&context, 0, 0, 190, 0.06, 1.5, alpha: 0.85, width: 0.9)
        Art.stroke(&context, Art.line(84, 0, 84, 104), Art.color(0xFFFFFF, 0.6), width: 0.8, cap: .butt)
        spider(&context, 84, 110, 1.5)

        // Shoulders.
        Art.fill(&context, Art.rect(194, 212, 44, 46, radius: 12), skinDark)
        let torso = Art.svg("M92,400 C88,322 108,264 160,248 C190,240 242,240 272,248 C324,264 344,322 340,400Z")
        let torsoTone: [(Color, CGFloat)] = [(skinLight, 0), (skin, 0.5), (skinDark, 1)]
        Art.fillRadial(&context, torso, torsoTone, center: pt(176, 270), radius: 210)

        // Cloth over one shoulder.
        let cloth = Art.svg("M272,246 C326,262 346,322 342,400 L112,400 C140,340 204,286 272,246Z")
        kente(&context, in: cloth, scale: 1.25)
        let shade: [(Color, CGFloat)] = [
            (kBlack.opacity(0.42), 0), (kBlack.opacity(0), 0.6), (Art.color(0xFFE9A8, 0.22), 1),
        ]
        Art.fillLinear(&context, cloth, shade, from: pt(112, 0), to: pt(342, 0))
        Art.fill(
            &context,
            Art.svg("M256,250 C292,252 330,272 341,332 C330,320 312,312 296,312 C292,286 278,264 256,250Z"),
            kBlack.opacity(0.24)
        )
        Art.stroke(
            &context,
            Art.svg("M250,262 C210,300 172,350 152,400 M300,314 C298,344 302,372 308,400"),
            kBlack.opacity(0.25), width: 3
        )
        Art.stroke(&context, Art.svg("M272,246 C204,286 140,340 112,400"), Art.color(0xFFE9A8, 0.4), width: 1.6)

        // The pot in his arms.
        Art.glow(&context, 206, 338, 150, Art.color(0xFFC94D), alpha: 0.35)
        pot(&context, 206, 338, 2.5)

        // Arms and hands round the pot.
        limb(&context, "M112,296 C94,336 104,370 148,376", 36, skin)
        Art.group(&context, x: 158, y: 366, rotate: rad(-20)) { g in
            Art.fill(&g, Art.ellipse(0, 0, 23, 16), skin)
            Art.stroke(&g, Art.svg("M4,-8 q6,2 10,7 M2,-1 q7,1 12,5 M0,6 q6,0 10,3"), skinDark.opacity(0.6), width: 1.4)
        }
        limb(&context, "M304,330 C294,350 280,358 264,356", 30, skin)
        Art.group(&context, x: 256, y: 352, rotate: rad(22)) { g in
            Art.fill(&g, Art.ellipse(0, 0, 22, 16), skin)
            Art.stroke(&g, Art.svg("M-4,-8 q-6,2 -10,7 M-2,-1 q-7,1 -12,5 M0,6 q-6,0 -10,3"), skinDark.opacity(0.6), width: 1.4)
        }

        // Head, lit a little by the pot from below.
        Art.group(&context, x: w / 2, y: 150, scale: 2.9) { g in
            anansiHead(&g, detail: true)
        }
        Art.glow(&context, 212, 262, 60, Art.color(0xFFC94D), alpha: 0.18)

        let sparks: [(CGFloat, CGFloat, CGFloat, Int)] = [
            (70, 250, 1.1, 1), (52, 320, 0.8, 2), (380, 232, 1, 2), (392, 300, 1.2, 0), (96, 196, 0.7, 2),
        ]
        motes(&context, sparks)
        tooth(&context, w, h, count: 180)
    }

    // MARK: - Faces

    /// Anansi's head on #D8342B (design `faceAnansi`, view box -36 -38 72 76).
    static func anansiFace(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        let h = size.height
        Art.fill(&context, Art.rect(0, 0, w, h), kRed)
        Art.glow(&context, w * 0.5, h * 0.4, w * 0.7, Art.color(0xF0584A), alpha: 0.6)
        let s = min(w / 72, h / 76)
        Art.group(&context, x: w / 2, y: h / 2, scale: s) { g in
            anansiHead(&g)
        }
    }

    /// Kweku's head on #F7B520 (design `faceKweku`, view box -36 -38 72 72).
    static func kwekuFace(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        let h = size.height
        Art.fill(&context, Art.rect(0, 0, w, h), kGold)
        Art.glow(&context, w * 0.5, h * 0.4, w * 0.7, Art.color(0xFFD25A), alpha: 0.6)
        let s = min(w / 72, h / 72)
        Art.group(&context, x: w / 2, y: h / 2 + 4 * s, scale: s) { g in
            kwekuHead(&g, lookX: 0, lookY: 0, mouthOpen: false)
        }
    }

    // MARK: - Cover

    /// Anansi on the tree with the glowing pot under the big moon. 300 wide, 150…375 tall:
    /// the figure and the moon sit round the vertical middle; canopy and ground follow the edges.
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
        moon(&context, 240, cy - 30, 44)

        // Far trees and ground along the bottom edge.
        let far: [(CGFloat, CGFloat)] = [(22, 0.5), (62, 0.34), (246, 0.46), (284, 0.36)]
        for (i, tree) in far.enumerated() {
            umbrellaTree(&context, tree.0, h - 8, 60 * tree.1 + 24, tree.1 * 0.8, Art.color(0x3A2466), seed: UInt32(40 + i))
        }
        var ground = Path()
        ground.move(to: pt(0, h - 14))
        ground.addCurve(to: pt(w, h - 12), control1: pt(w * 0.3, h - 22), control2: pt(w * 0.7, h - 8))
        ground.addLine(to: pt(w, h))
        ground.addLine(to: pt(0, h))
        ground.closeSubpath()
        Art.fill(&context, ground, Art.color(0x1A0F33))

        // The trunk.
        var trunk = Path()
        trunk.move(to: pt(148, 0))
        trunk.addCurve(to: pt(146, h - 60), control1: pt(150, h * 0.3), control2: pt(147, h * 0.6))
        trunk.addCurve(to: pt(118, h), control1: pt(145, h - 30), control2: pt(134, h - 12))
        trunk.addLine(to: pt(232, h))
        trunk.addCurve(to: pt(198, h - 60), control1: pt(214, h - 12), control2: pt(200, h - 30))
        trunk.addCurve(to: pt(197, 0), control1: pt(196, h * 0.6), control2: pt(196, h * 0.3))
        trunk.closeSubpath()
        let bark: [(Color, CGFloat)] = [(Art.color(0x150A2C), 0), (Art.color(0x22123F), 0.5), (Art.color(0x4A2C5E), 1)]
        Art.fillLinear(&context, trunk, bark, from: pt(140, 0), to: pt(204, 0))
        var grooves = Path()
        grooves.move(to: pt(162, 0))
        grooves.addQuadCurve(to: pt(160, h - 50), control: pt(165, h * 0.5))
        grooves.move(to: pt(180, 0))
        grooves.addQuadCurve(to: pt(182, h - 44), control: pt(178, h * 0.5))
        Art.stroke(&context, grooves, Art.color(0x1B0F33, 0.45), width: 1.4, cap: .butt)
        var rimLine = Path()
        rimLine.move(to: pt(196, 0))
        rimLine.addCurve(to: pt(197, h - 60), control1: pt(195, h * 0.3), control2: pt(195, h * 0.6))
        rimLine.addCurve(to: pt(230, h), control1: pt(199, h - 30), control2: pt(213, h - 12))
        Art.stroke(&context, rimLine, Art.color(0xFFE9D2, 0.6), width: 1.8, cap: .butt)

        // Web and spider against the moon.
        spiderWeb(&context, 198, cy - 66, 84, -0.42, 0.5)
        Art.stroke(&context, Art.line(250, cy - 84, 250, cy - 14), Art.color(0xFFFFFF, 0.6), width: 0.7, cap: .butt)
        spider(&context, 250, cy - 10, 1)

        // A thin canopy along the top edge.
        let blobs: [(CGFloat, CGFloat, CGFloat)] = [(150, -24, 64), (50, -26, 56), (250, -24, 60), (300, -10, 36), (0, -12, 30)]
        nightCanopy(&context, blobs, seed: 14, palette: canopyPalette)

        // Father Anansi and the pot.
        Art.glow(&context, 138, cy + 22, 78, Art.color(0xFFC94D), alpha: 0.32)
        anansiClimbing(&context, 112, cy + 38, 0.95)
        let sparks: [(CGFloat, CGFloat, CGFloat, Int)] = [
            (98, -74, 1, 1), (74, -44, 0.8, 2), (56, -86, 1.1, 0), (40, -12, 0.7, 2), (84, 34, 0.7, 2),
        ]
        motes(&context, sparks, dx: 0, dy: cy)
        fireflies(&context, 8, seed: 29, in: CGRect(x: 204, y: cy + 20, width: 90, height: max(20, cy - 40)))

        // A woven band along the bottom edge.
        let bandH = max(8, min(16, h * 0.06))
        Art.group(&context, x: 0, y: h - bandH) { g in
            kente(&g, in: Art.rect(0, 0, w, bandH), scale: bandH / 24)
            Art.fill(&g, Art.rect(0, -1.5, w, 1.5), kBlack)
        }
        tooth(&context, w, h, count: 140)
    }
}
