import SwiftUI
import OmramoCore

// Mount Fuji on a clear morning: our own drawing (no photograph, nothing traced, and no
// print imitated). The broad, even cone with its flattened, notched summit and long concave
// slopes; a cap of snow running down in fingers; blue-violet lower slopes; a band of mist;
// dark wooded low hills; a calm lake in front with a soft reflection and two tiny boats.
// A dark pine bough at the top-right edge is the near plane. Card background #1F3460.

extension LandmarkArt {
    /// mount-fuji: the snow-capped cone above mist, wooded hills and a calm lake, in clear
    /// morning light.
    static func paintMountFuji(_ context: inout GraphicsContext) {
        fujiSky(&context)
        fujiFarRidges(&context)
        fujiCone(&context)
        fujiSnow(&context)
        fujiMist(&context)
        fujiHills(&context)
        fujiLake(&context)
        fujiReflection(&context)
        fujiBoat(&context, x: 118, y: 292, scale: 1)
        fujiBoat(&context, x: 312, y: 281, scale: 0.75)
        fujiPine(&context)
        fujiFinish(&context)
    }

    // MARK: Shapes

    /// The whole mountain: long concave slopes up to a slightly flattened, notched summit.
    static func fujiConePath() -> Path {
        Art.svg("M30,254 C110,214 172,130 203,82 L208,79 L213,81.5 L219,78.5 L224,80.5 L229,82 C260,130 322,214 402,254 L402,270 L30,270 Z")
    }

    /// The snow cap, wider than the cone (clip it to the cone): its lower edge runs down in
    /// rounded fingers of uneven length.
    static func fujiSnowPath() -> Path {
        // (next notch x, notch y, control y): the tongue between two notches hangs to about
        // half-way between the notches and the control.
        let fingers: [(CGFloat, CGFloat, CGFloat)] = [
            (282, 140, 186), (270, 136, 210), (258, 132, 176), (246, 130, 222),
            (234, 128, 170), (222, 126, 214), (210, 128, 180), (198, 130, 226),
            (186, 134, 178), (174, 138, 206), (160, 142, 184), (140, 146, 176),
        ]
        var path = Path()
        path.move(to: pt(140, 60))
        path.addLine(to: pt(296, 60))
        path.addLine(to: pt(296, 138))
        var x: CGFloat = 296
        for finger in fingers {
            let mid: CGFloat = (x + finger.0) / 2
            path.addQuadCurve(to: pt(finger.0, finger.1), control: pt(mid, finger.2))
            x = finger.0
        }
        path.closeSubpath()
        return path
    }

    // MARK: Sky and the far plane

    static func fujiSky(_ context: inout GraphicsContext) {
        let sky: [(Color, CGFloat)] = [
            (Art.color(0x4F86CC), 0),
            (Art.color(0x8DBBE6), 0.3),
            (Art.color(0xD6E2EA), 0.5),
            (Art.color(0xFFE3BC), 0.64),
            (Art.color(0xFFE3BC), 1),
        ]
        backdrop(&context, sky)
        // The morning light, low on the left.
        Art.glow(&context, 30, 210, 230, Art.color(0xFFF0C8), alpha: 0.3)
        horizon(&context, y: 264, rise: 76, hex: 0xFFD9A8, alpha: 0.36)

        // Two thin, high morning clouds, well clear of the summit.
        var clouds = Path()
        clouds.addPath(cloudBand(292, 134, width: 104, height: 8))
        clouds.addPath(cloudBand(44, 168, width: 92, height: 7))
        clouds.addPath(cloudBand(330, 176, width: 80, height: 6))
        Art.fill(&context, clouds, Art.color(0xFFF6E6, 0.7))
        let lit = Art.svg("M300,131 C318,126 340,124 360,126 M52,165 C68,161 86,160 104,162")
        Art.stroke(&context, lit, Art.color(0xFFFFFF, 0.7), width: 1)

        // Three far birds, small strokes only.
        let birds = Art.svg("M108,112 q3,-3 6,0 q3,-3 6,0 M134,124 q2.4,-2.4 4.8,0 q2.4,-2.4 4.8,0 M92,130 q2,-2 4,0 q2,-2 4,0")
        Art.stroke(&context, birds, Art.color(0x4A5C96, 0.6), width: 0.8)
    }

    /// Pale, far ridges on either side of the mountain, veiled with the sky's own colour.
    static func fujiFarRidges(_ context: inout GraphicsContext) {
        let left = Art.svg("M-24,270 L-24,226 C20,214 60,228 100,220 C140,214 170,232 200,240 L200,270 Z")
        let right = Art.svg("M456,270 L456,222 C420,210 390,224 350,218 C310,214 270,236 240,242 L240,270 Z")
        var ridges = Path()
        ridges.addPath(left)
        ridges.addPath(right)
        Art.fill(&context, ridges, Art.color(0x8496C8))
        let crests = Art.svg("M-24,226 C20,214 60,228 100,220 M350,218 C310,214 270,236 240,242")
        Art.stroke(&context, crests, Art.color(0xFFE6CC, 0.5), width: 1)
        haze(&context, top: 150, bottom: 266, hex: 0xFFE3BC, alpha: 0.45)
    }

    // MARK: The mountain

    static func fujiCone(_ context: inout GraphicsContext) {
        let cone = fujiConePath()
        let rock: [(Color, CGFloat)] = [
            (Art.color(0x5563B0), 0),
            (Art.color(0x6A74BC), 0.45),
            (Art.color(0x8E97CE), 0.85),
            (Art.color(0xA9B0DA), 1),
        ]
        fillVertical(&context, cone, rock, from: 80, to: 256)
        // The one light: warm on the left slope, indigo on the right.
        let sides: [(Color, CGFloat)] = [
            (Art.color(0xFFD2B0, 0.3), 0),
            (Art.color(0xFFD2B0, 0), 0.45),
            (ArtStyle.coolShade.opacity(0), 0.55),
            (ArtStyle.coolShade.opacity(0.28), 1),
        ]
        fillHorizontal(&context, cone, sides, from: 110, to: 330)

        // Gullies running down from the summit, and the darker woods at the mountain's foot.
        let darkGullies = Art.svg("M216,92 C214,140 206,190 190,246 M222,90 C232,140 250,190 276,246 M226,92 C250,130 290,186 340,238 M236,120 C262,160 300,204 372,246")
        let lightGullies = Art.svg("M208,94 C196,130 160,184 100,238 M212,96 C204,140 180,196 146,246 M196,104 C170,146 124,200 64,244")
        let foot: [(Color, CGFloat)] = [
            (Art.color(0x35527A, 0), 0),
            (Art.color(0x35527A, 0.45), 1),
        ]
        Art.clipped(&context, to: cone) { g in
            Art.stroke(&g, darkGullies, Art.color(0x3A4590, 0.3), width: 1.4)
            Art.stroke(&g, lightGullies, Art.color(0xFFE0C8, 0.22), width: 1.2)
            fillVertical(&g, Art.rect(20, 206, 392, 64), foot, from: 206, to: 258)
        }
        // A thin edge of warm light along the lit slope.
        let edge = Art.svg("M203,82 C172,130 110,214 30,254")
        Art.stroke(&context, edge, Art.color(0xFFE2C4, 0.55), width: 1.2)
    }

    static func fujiSnow(_ context: inout GraphicsContext) {
        let cone = fujiConePath()
        let snow = fujiSnowPath()
        let white: [(Color, CGFloat)] = [
            (Art.color(0xFFFDF6), 0),
            (Art.color(0xF6F1F2), 0.55),
            (Art.color(0xDCE0F4), 1),
        ]
        let sides: [(Color, CGFloat)] = [
            (Art.color(0xFFE6C0, 0.4), 0),
            (Art.color(0xFFE6C0, 0), 0.42),
            (ArtStyle.coolShade.opacity(0), 0.5),
            (ArtStyle.coolShade.opacity(0.3), 1),
        ]
        // Thin streaks of snow lying in the gullies below the cap, and rock ribs showing
        // through the snow near the top.
        let streaks = Art.svg("M196,168 L184,198 M214,176 L211,206 M232,170 L241,200 M250,164 L266,192 M178,162 L158,188 M268,158 L288,184")
        let ribs = Art.svg("M214,86 L209,120 M221,85 L229,126 M207,88 L189,128 M226,88 L251,132 M203,96 L176,136")
        Art.clipped(&context, to: cone) { g in
            Art.stroke(&g, streaks, Art.color(0xFFFFFF, 0.5), width: 1.3)
            fillVertical(&g, snow, white, from: 78, to: 196)
            fillHorizontal(&g, snow, sides, from: 150, to: 286)
            Art.stroke(&g, ribs, Art.color(0x5563B0, 0.4), width: 1.1)
        }
        // The shaded inside of the notch at the summit, and the lit lip beside it.
        let notch = Art.polygon([pt(208, 79), pt(213, 81.5), pt(219, 78.5), pt(218, 85.5), pt(210, 86)])
        Art.fill(&context, notch, Art.color(0x7C86C6, 0.55))
        let lip = Art.svg("M203,82 L208,79 L213,81.5")
        Art.stroke(&context, lip, Art.color(0xFFFFFF, 0.9), width: 1)
    }

    /// The band of morning mist that lies across the mountain's foot.
    static func fujiMist(_ context: inout GraphicsContext) {
        let band: [(Color, CGFloat)] = [
            (Art.color(0xFFF4E6, 0), 0),
            (Art.color(0xFFF4E6, 0.72), 0.62),
            (Art.color(0xFFF4E6, 0.5), 1),
        ]
        fillVertical(&context, Art.rect(-24, 204, unitWidth + 48, 64), band, from: 204, to: 268)
        Art.blurred(&context, radius: 3) { g in
            var banks = Path()
            banks.addPath(cloudBand(46, 238, width: 160, height: 12))
            banks.addPath(cloudBand(208, 246, width: 176, height: 12))
            banks.addPath(cloudBand(150, 226, width: 116, height: 8))
            banks.addPath(cloudBand(-20, 250, width: 120, height: 9))
            Art.fill(&g, banks, Art.color(0xFFFAF0, 0.78))
        }
        let tops = Art.svg("M70,232 C96,227 120,226 150,229 M236,239 C266,234 300,233 330,236")
        Art.stroke(&context, tops, Art.color(0xFFFFFF, 0.6), width: 1)
    }

    // MARK: Hills

    /// Small pointed trees standing on a ridge: (x, foot y, height) each.
    static func fujiTrees(_ trees: [(CGFloat, CGFloat, CGFloat)]) -> Path {
        var path = Path()
        for tree in trees {
            let half: CGFloat = tree.2 * 0.36
            let top: CGFloat = tree.1 - tree.2
            path.move(to: pt(tree.0 - half, tree.1 + 2))
            path.addLine(to: pt(tree.0, top))
            path.addLine(to: pt(tree.0 + half, tree.1 + 2))
            path.closeSubpath()
        }
        return path
    }

    /// The lit left edge of each of those trees.
    static func fujiTreeLights(_ trees: [(CGFloat, CGFloat, CGFloat)]) -> Path {
        var path = Path()
        for tree in trees {
            let half: CGFloat = tree.2 * 0.36
            let top: CGFloat = tree.1 - tree.2
            path.move(to: pt(tree.0, top))
            path.addLine(to: pt(tree.0 - half, tree.1 + 1))
        }
        return path
    }

    /// The dark wooded low hills between the mist and the lake: a paler back row, then two
    /// darker spurs that leave the middle open.
    static func fujiHills(_ context: inout GraphicsContext) {
        let back = Art.svg("M-24,270 L-24,240 C10,230 40,234 70,242 C100,248 130,242 160,252 C180,257 200,259 216,259 C240,259 262,252 290,246 C320,238 350,242 380,234 C410,228 436,234 456,230 L456,270 Z")
        let backStops: [(Color, CGFloat)] = [
            (Art.color(0x5A84A0), 0),
            (Art.color(0x3E6682), 1),
        ]
        fillVertical(&context, back, backStops, from: 230, to: 270)
        let backTrees: [(CGFloat, CGFloat, CGFloat)] = [
            (120, 245, 6), (134, 245, 5), (148, 249, 5), (300, 244, 6), (316, 240, 6), (332, 239, 5),
            (348, 240, 6), (176, 256, 4), (262, 252, 4), (278, 248, 5),
        ]
        Art.fill(&context, fujiTrees(backTrees), Art.color(0x3E6682))
        haze(&context, top: 228, bottom: 270, hex: 0xFFEEDC, alpha: 0.16)

        let left = Art.svg("M-24,272 L-24,246 C0,238 30,236 56,244 C80,250 104,254 134,259 C150,261 160,265 172,268 L172,272 Z")
        let right = Art.svg("M456,272 L456,240 C430,232 400,236 372,246 C344,254 316,257 290,263 C280,265 272,267 264,269 L264,272 Z")
        let frontStops: [(Color, CGFloat)] = [
            (Art.color(0x2A5560), 0),
            (Art.color(0x1B3C50), 1),
        ]
        fillVertical(&context, left, frontStops, from: 236, to: 272)
        model(&context, left, light: 0.16, shade: 0.16)
        fillVertical(&context, right, frontStops, from: 232, to: 272)
        model(&context, right, light: 0.12, shade: 0.2)

        let leftTrees: [(CGFloat, CGFloat, CGFloat)] = [
            (-10, 243, 9), (4, 240, 10), (18, 238, 9), (32, 238, 10), (46, 241, 9),
            (60, 245, 8), (74, 248, 8), (90, 251, 7), (106, 254, 7), (122, 257, 6), (138, 260, 5),
        ]
        let rightTrees: [(CGFloat, CGFloat, CGFloat)] = [
            (448, 238, 10), (434, 235, 10), (420, 234, 9), (406, 235, 10), (392, 239, 9),
            (378, 243, 8), (362, 248, 8), (346, 252, 7), (330, 255, 7), (314, 258, 6), (298, 261, 5),
        ]
        var trees = fujiTrees(leftTrees)
        trees.addPath(fujiTrees(rightTrees))
        Art.fill(&context, trees, Art.color(0x1F4452))
        var lights = fujiTreeLights(leftTrees)
        lights.addPath(fujiTreeLights(rightTrees))
        Art.stroke(&context, lights, Art.color(0x8FC0A0, 0.5), width: 0.7)
        // A pale line of shore where the hills meet the water.
        let shore = Art.svg("M-24,270.5 L172,270.5 M264,270.5 L456,270.5")
        Art.stroke(&context, shore, Art.color(0xFFF0D8, 0.45), width: 1)
    }

    // MARK: Lake

    static func fujiLake(_ context: inout GraphicsContext) {
        let lake = Art.rect(-24, 268, unitWidth + 48, unitHeight - 268 + 24)
        let water: [(Color, CGFloat)] = [
            (Art.color(0xEBDDCC), 0),
            (Art.color(0xA4C4E2), 0.12),
            (Art.color(0x5F8CC8), 0.45),
            (Art.color(0x2F4F8C), 0.8),
            (Art.color(0x1F3460), 1),
        ]
        fillVertical(&context, lake, water, from: 268, to: unitHeight)
        // The hills lie dark on the water under themselves.
        let under: [(Color, CGFloat)] = [
            (Art.color(0x1B3C50, 0.5), 0),
            (Art.color(0x1B3C50, 0), 1),
        ]
        var shadows = Path()
        shadows.addRect(CGRect(x: -24, y: 271, width: 196, height: 16))
        shadows.addRect(CGRect(x: 264, y: 271, width: 192, height: 18))
        fillVertical(&context, shadows, under, from: 271, to: 289)
    }

    /// The mountain upside down in the lake, squashed and soft, with ripples lying across it.
    static func fujiReflection(_ context: inout GraphicsContext) {
        let cone = Art.svg("M30,272 C110,292 172,334 203,358 L229,358 C260,334 322,292 402,272 Z")
        let snow = Art.svg("M150,327 Q216,319 282,327 L229,358 L203,358 Z")
        Art.blurred(&context, radius: 2.5, opacity: 0.55) { g in
            Art.fill(&g, cone, Art.color(0x5563B0, 0.7))
            Art.clipped(&g, to: cone) { inner in
                Art.fill(&inner, snow, Art.color(0xF6F4FA, 0.8))
            }
        }
        let whole = CGRect(x: 0, y: 276, width: unitWidth, height: 108)
        ripples(&context, in: whole, count: 56, seed: 23, color: Art.color(0xFFFFFF, 0.3), width: 0.8, length: 6...26)
        ripples(&context, in: whole, count: 30, seed: 29, color: Art.color(0x2F4F8C, 0.3), width: 0.9, length: 8...30)
        // The morning light glitters on the left of the lake.
        let glitter = CGRect(x: 14, y: 274, width: 130, height: 36)
        ripples(&context, in: glitter, count: 20, seed: 31, color: Art.color(0xFFE9C0, 0.65), width: 0.9, length: 3...10)
    }

    /// One tiny fishing boat with a person in a straw hat, poling: a dark shape for scale.
    static func fujiBoat(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, scale s: CGFloat) {
        // Its soft dark reflection.
        Art.fill(&context, Art.ellipse(x + 0.5 * s, y + 1.6 * s, 7.5 * s, 1.3 * s), Art.color(0x1F3460, 0.35))
        var hull = Path()
        hull.move(to: pt(x - 7 * s, y - 2 * s))
        hull.addLine(to: pt(x + 8.5 * s, y - 2.6 * s))
        hull.addQuadCurve(to: pt(x - 7 * s, y - 2 * s), control: pt(x + 1 * s, y + 2.6 * s))
        hull.closeSubpath()
        Art.fill(&context, hull, Art.color(0x3C2A44))
        let gunwale = Art.line(x - 7 * s, y - 2 * s, x + 8.5 * s, y - 2.6 * s)
        Art.stroke(&context, gunwale, Art.color(0xFFD9A0, 0.75), width: 0.6 * s)

        let body = Art.polygon([
            pt(x - 1.3 * s, y - 2.2 * s), pt(x + 1.3 * s, y - 2.2 * s),
            pt(x + 0.9 * s, y - 7 * s), pt(x - 0.9 * s, y - 7 * s),
        ])
        Art.fill(&context, body, Art.color(0x34406E))
        Art.fill(&context, Art.circle(x, y - 8 * s, 1.2 * s), Art.color(0x8A5A48))
        let hat = Art.polygon([pt(x - 2.6 * s, y - 8.4 * s), pt(x + 2.6 * s, y - 8.4 * s), pt(x, y - 10.6 * s)])
        Art.fill(&context, hat, Art.color(0xECCB8C))
        let pole = Art.line(x + 0.8 * s, y - 6 * s, x + 9 * s, y + 1.4 * s)
        Art.stroke(&context, pole, Art.color(0x3C2A44, 0.9), width: 0.5 * s)
    }

    // MARK: The near plane

    /// A dark pine bough reaching in from the top-right corner: bent twigs and fans of
    /// needles, each fan with a few needles catching the light.
    static func fujiPine(_ context: inout GraphicsContext) {
        let bough = Art.svg("M456,6 C420,12 392,20 356,22 C340,23 326,28 314,36")
        let twigs = Art.svg("M410,14 C400,28 384,40 366,46 M444,30 C430,40 420,52 414,66")
        Art.stroke(&context, bough, Art.color(0x2E2444), width: 3.2)
        Art.stroke(&context, twigs, Art.color(0x2E2444), width: 2)
        let boughLight = Art.svg("M456,4.6 C420,10.6 392,18.6 356,20.6")
        Art.stroke(&context, boughLight, Art.color(0xB98A6A, 0.6), width: 0.8)

        let anchors: [(CGFloat, CGFloat)] = [
            (446, 4), (430, 10), (408, 15), (386, 20), (362, 22), (340, 25), (322, 31),
            (314, 36), (398, 28), (382, 40), (366, 46), (436, 36), (422, 50), (414, 66),
        ]
        var random = ArtRandom(57)
        var needles = Path()
        var glints = Path()
        for anchor in anchors {
            for index in 0..<9 {
                // The fan opens from straight down, through the left, to up and left.
                let spread: CGFloat = CGFloat(index) * 0.34
                let angle: CGFloat = 1.5 + spread + random.next(in: -0.1...0.1)
                let length: CGFloat = random.next(in: 12...18)
                let ex: CGFloat = anchor.0 + cos(angle) * length
                let ey: CGFloat = anchor.1 + sin(angle) * length
                needles.move(to: pt(anchor.0, anchor.1))
                needles.addLine(to: pt(ex, ey))
                if index % 3 == 1 {
                    glints.move(to: pt(anchor.0 - 0.7, anchor.1 - 0.7))
                    glints.addLine(to: pt(ex - 0.7, ey - 0.7))
                }
            }
        }
        Art.stroke(&context, needles, Art.color(0x173A3C), width: 1.2)
        Art.stroke(&context, glints, Art.color(0x6FA884, 0.8), width: 0.5)
    }

    // MARK: Finish

    static func fujiFinish(_ context: inout GraphicsContext) {
        bottomFade(&context, 0x1F3460, from: 300, alpha: 0.9)
        tooth(&context, seed: 727, light: 0.05, dark: 0.04)
        finish(&context, wash: 0.10, vignette: 0.10)
    }
}
