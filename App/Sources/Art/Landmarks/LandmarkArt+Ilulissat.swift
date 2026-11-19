import SwiftUI
import OmramoCore

// Ilulissat Icefjord by day: our own drawing (no photograph, nothing traced).
// A Greenland fjord packed with icebergs of many shapes, tabular and pinnacled, white on their
// sunlit left faces and pale blue in shade, between dark rocky shores with a little low
// green-brown tundra. One small red wooden house on the right-hand rocks gives the scale. A pale
// Arctic sky with a low sun to the left. Card background #173A52.

extension LandmarkArt {
    /// ilulissat: icebergs packed into the fjord between dark tundra shores, a small red house
    /// on the rocks, pale Arctic sky and a low sun from the left.
    static func paintIlulissat(_ context: inout GraphicsContext) {
        ilulissatSky(&context)
        ilulissatFar(&context)
        ilulissatWater(&context)
        ilulissatFarBergs(&context)
        ilulissatMidBergs(&context)
        ilulissatHeroBergs(&context)
        ilulissatFrontBergs(&context)
        ilulissatBrash(&context)
        ilulissatLeftShore(&context)
        ilulissatRightShore(&context)
        ilulissatHouse(&context)
        // The low sun lying across the ice from the left.
        Art.glow(&context, 150, 180, 150, Art.color(0xFFE2B4), alpha: 0.16)
        ilulissatNearRock(&context)
        ilulissatFinish(&context)
    }

    // MARK: Ice

    /// The outline of one iceberg standing on the water line `base`, starting at `x`.
    /// `kind` 0 is tabular (flat-topped), 1 is pinnacled, anything else is a rounded wedge.
    /// A negative `height` gives the berg's reflection below the water line.
    static func ilulissatBergPath(_ x: CGFloat, _ base: CGFloat, width: CGFloat, height: CGFloat, kind: Int) -> Path {
        let outline: [(CGFloat, CGFloat)]
        switch kind {
        case 0:
            outline = [
                (0, 0), (0.03, 0.62), (0.08, 0.9), (0.2, 0.97), (0.42, 1), (0.64, 0.97),
                (0.82, 0.94), (0.93, 0.78), (0.97, 0.4), (1, 0),
            ]
        case 1:
            outline = [
                (0, 0), (0.1, 0.3), (0.22, 0.46), (0.3, 0.7), (0.38, 1), (0.46, 0.74),
                (0.56, 0.86), (0.66, 0.56), (0.78, 0.42), (0.9, 0.24), (1, 0),
            ]
        default:
            outline = [
                (0, 0), (0.08, 0.4), (0.24, 0.78), (0.42, 0.97), (0.56, 1), (0.72, 0.8),
                (0.88, 0.46), (1, 0),
            ]
        }
        var points: [CGPoint] = []
        for corner in outline {
            let px: CGFloat = x + corner.0 * width
            let py: CGFloat = base - corner.1 * height
            points.append(pt(px, py))
        }
        return Art.polygon(points)
    }

    /// Where the sunlit face of a berg turns into its shaded face, as a share of its width.
    static func ilulissatRidge(_ kind: Int) -> CGFloat {
        switch kind {
        case 0:
            return 0.7
        case 1:
            return 0.4
        default:
            return 0.56
        }
    }

    /// One iceberg: the turquoise glow of its underwater foot, a faint reflection, the ice lit
    /// from the left and shaded to the right, and (when `detail`) its crevasses and rim.
    /// `berg` is (x, water line, width, height, kind).
    static func ilulissatBerg(_ context: inout GraphicsContext, _ berg: (CGFloat, CGFloat, CGFloat, CGFloat, Int), detail: Bool) {
        let x: CGFloat = berg.0
        let base: CGFloat = berg.1
        let w: CGFloat = berg.2
        let h: CGFloat = berg.3
        let kind: Int = berg.4
        let midX: CGFloat = x + w * 0.5
        let footRy: CGFloat = max(1.6, h * 0.08)
        Art.fill(&context, Art.ellipse(midX, base + 1.2, w * 0.56, footRy), Art.color(0x6FC2D2, 0.34))
        let reflection = ilulissatBergPath(x, base, width: w, height: -h * 0.3, kind: kind)
        Art.fill(&context, reflection, Art.color(0xDDEFF5, 0.16))

        let shape = ilulissatBergPath(x, base, width: w, height: h, kind: kind)
        let ice: [(Color, CGFloat)] = [
            (Art.color(0xFFFCF2), 0),
            (Art.color(0xEEF6F8), 0.4),
            (Art.color(0xB8D6E4), 0.72),
            (Art.color(0x8DB4CE), 1),
        ]
        fillHorizontal(&context, shape, ice, from: x, to: x + w)
        if detail {
            model(&context, shape, light: 0.16, shade: 0.18, rim: 0.5)
        }

        let ridgeX: CGFloat = x + w * ilulissatRidge(kind)
        let lean: CGFloat = w * 0.08
        let top: CGFloat = base - h * 1.1
        let right: CGFloat = x + w + 2
        let face = Art.polygon([pt(ridgeX, top), pt(right, top), pt(right, base + 1), pt(ridgeX - lean, base + 1)])
        var cracks = Path()
        if detail {
            let shares: [CGFloat] = [0.16, 0.3, 0.5, 0.78, 0.9]
            for share in shares {
                let cx: CGFloat = x + w * share
                cracks.move(to: pt(cx, base - h))
                cracks.addLine(to: pt(cx + 1.5, base - h * 0.35))
            }
            if kind == 0 {
                let band: CGFloat = base - h * 0.55
                cracks.move(to: pt(x, band))
                cracks.addLine(to: pt(x + w, band + 2))
            }
        }
        let waterline: CGFloat = max(1.5, h * 0.06)
        Art.clipped(&context, to: shape) { g in
            Art.fill(&g, face, ArtStyle.coolShade.opacity(0.16))
            Art.stroke(&g, cracks, Art.color(0x8FB6D0, 0.5), width: 0.8)
            Art.fill(&g, Art.rect(x - 2, base - waterline, w + 4, waterline), Art.color(0x7FB8CE, 0.5))
        }
    }

    /// Draws every berg in `bergs` in order.
    static func ilulissatBergs(_ context: inout GraphicsContext, _ bergs: [(CGFloat, CGFloat, CGFloat, CGFloat, Int)], detail: Bool) {
        for berg in bergs {
            ilulissatBerg(&context, berg, detail: detail)
        }
    }

    // MARK: Sky, far shore and water

    static func ilulissatSky(_ context: inout GraphicsContext) {
        let sky: [(Color, CGFloat)] = [
            (Art.color(0x8DB8D6), 0),
            (Art.color(0xC4DCE8), 0.18),
            (Art.color(0xF1E4D0), 0.33),
            (Art.color(0xFADDB6), 0.4),
            (Art.color(0xFADDB6), 1),
        ]
        backdrop(&context, sky)
        // The low sun, just above the horizon on the left.
        Art.glow(&context, 40, 140, 130, Art.color(0xFFE4B4), alpha: 0.55)
        Art.glow(&context, 40, 142, 22, Art.color(0xFFF4DC), alpha: 0.9)
        // Thin, high Arctic clouds, warm on their undersides.
        var clouds = cloudBand(236, 74, width: 128, height: 10)
        clouds.addPath(cloudBand(318, 104, width: 92, height: 7))
        clouds.addPath(cloudBand(150, 112, width: 70, height: 5))
        Art.fill(&context, clouds, Art.color(0xFFFFFF, 0.4))
        let undersides = Art.svg("M240,74 Q300,78 364,74 M322,104 Q364,107 410,104 M152,112 Q186,114 220,112")
        Art.stroke(&context, undersides, Art.color(0xFFD9A8, 0.4), width: 1)
    }

    /// The far plane: low hills and the edge of the ice sheet where the fjord begins.
    static func ilulissatFar(_ context: inout GraphicsContext) {
        let hills = Art.svg("M-24,160 L-24,146 C20,140 60,146 100,139 C150,131 190,142 236,140 C282,138 330,129 378,135 C410,139 436,136 456,139 L456,160 Z")
        Art.fill(&context, hills, Art.color(0x9EB2C4))
        let sheet = Art.svg("M150,160 L150,148 C180,145 220,147 260,145 C300,143 330,146 360,144 L360,160 Z")
        Art.fill(&context, sheet, Art.color(0xE4EEF2))
        let snow = Art.svg("M-24,148 C20,143 60,149 100,142 M236,143 C282,141 330,132 378,138 C410,142 436,139 456,142")
        Art.stroke(&context, snow, Art.color(0xF2F6F6, 0.7), width: 1.4)
        haze(&context, top: 120, bottom: 162, hex: 0xF4E2C8, alpha: 0.45)
        horizon(&context, y: 160, rise: 30, hex: 0xFFDCAA, alpha: 0.3)
    }

    static func ilulissatWater(_ context: inout GraphicsContext) {
        let water = Art.rect(-24, 158, unitWidth + 48, unitHeight - 158 + 24)
        let deep: [(Color, CGFloat)] = [
            (Art.color(0x9CBCCC), 0),
            (Art.color(0x5E90AA), 0.22),
            (Art.color(0x2F6684), 0.6),
            (Art.color(0x1C4762), 1),
        ]
        fillVertical(&context, water, deep, from: 158, to: unitHeight)
        // The sun's path on the water, warm and broken, from the left.
        let sunPath = Art.polygon([pt(20, 160), pt(70, 160), pt(150, 300), pt(40, 300)])
        let warm: [(Color, CGFloat)] = [
            (Art.color(0xFFE2B4, 0.32), 0),
            (Art.color(0xFFE2B4, 0), 1),
        ]
        fillVertical(&context, sunPath, warm, from: 160, to: 300)
        let calm = CGRect(x: 0, y: 166, width: unitWidth, height: 140)
        ripples(&context, in: calm, count: 70, seed: 52, color: Art.color(0xD8EAF0, 0.35), width: 0.8, length: 4...14)
        let glints = CGRect(x: 30, y: 168, width: 110, height: 110)
        ripples(&context, in: glints, count: 26, seed: 53, color: Art.color(0xFFEACB, 0.55), width: 0.9, length: 3...9)
    }

    // MARK: The icebergs

    /// The far bergs, crowded toward the mouth of the fjord, small and veiled.
    static func ilulissatFarBergs(_ context: inout GraphicsContext) {
        var random = ArtRandom(41)
        var bergs: [(CGFloat, CGFloat, CGFloat, CGFloat, Int)] = []
        for index in 0..<30 {
            let fall: CGFloat = random.next(in: 0...1)
            let base: CGFloat = 161 + fall * 24
            let x: CGFloat = random.next(in: 40...380)
            let size: CGFloat = 0.5 + fall
            let w: CGFloat = random.next(in: 8...20) * size
            let h: CGFloat = w * random.next(in: 0.25...0.6)
            bergs.append((x, base, w, h, index % 3))
        }
        // Nearer bergs (lower on the page) are drawn over farther ones.
        let ordered: [(CGFloat, CGFloat, CGFloat, CGFloat, Int)] = bergs.sorted { $0.1 < $1.1 }
        ilulissatBergs(&context, ordered, detail: false)
        haze(&context, top: 150, bottom: 190, hex: 0xE8EEF0, alpha: 0.35)
    }

    static func ilulissatMidBergs(_ context: inout GraphicsContext) {
        let bergs: [(CGFloat, CGFloat, CGFloat, CGFloat, Int)] = [
            (250, 192, 30, 14, 2),
            (176, 196, 44, 22, 2),
            (112, 198, 38, 16, 0),
            (346, 198, 34, 15, 0),
            (300, 204, 54, 36, 1),
            (70, 206, 46, 20, 2),
        ]
        ilulissatBergs(&context, bergs, detail: true)
        haze(&context, top: 170, bottom: 210, hex: 0xE8EEF0, alpha: 0.12)
    }

    /// The two great bergs at the heart of the picture: a pinnacled one behind and a broad
    /// tabular one in front of it, with a wedge beside them.
    static func ilulissatHeroBergs(_ context: inout GraphicsContext) {
        let bergs: [(CGFloat, CGFloat, CGFloat, CGFloat, Int)] = [
            (214, 230, 100, 94, 1),
            (104, 240, 124, 54, 0),
            (300, 246, 60, 32, 2),
        ]
        ilulissatBergs(&context, bergs, detail: true)
        // The sun catches the flat top of the tabular berg and the left face of the spire.
        let litTop = Art.svg("M107,207 L114,191 L129,188 L156,186 L183,188 L205,189")
        Art.stroke(&context, litTop, Art.color(0xFFEBC8, 0.85), width: 1.2)
        let litSpire = Art.svg("M224,202 L236,187 L244,164 L252,136")
        Art.stroke(&context, litSpire, Art.color(0xFFEBC8, 0.75), width: 1.1)
        // The darker blue of old ice in the shaded clefts.
        let clefts = Art.svg("M262,160 L266,206 M276,178 L278,214 M196,196 L198,232")
        Art.stroke(&context, clefts, Art.color(0x5E94B8, 0.4), width: 1.2)
    }

    static func ilulissatFrontBergs(_ context: inout GraphicsContext) {
        let bergs: [(CGFloat, CGFloat, CGFloat, CGFloat, Int)] = [
            (176, 266, 72, 20, 0),
            (56, 272, 58, 22, 2),
            (262, 282, 66, 28, 1),
            (130, 296, 42, 12, 2),
            (214, 304, 50, 14, 0),
        ]
        ilulissatBergs(&context, bergs, detail: true)
    }

    /// Broken floes and bits of ice scattered between the bergs.
    static func ilulissatBrash(_ context: inout GraphicsContext) {
        var random = ArtRandom(77)
        var floes = Path()
        var feet = Path()
        for _ in 0..<60 {
            let x: CGFloat = random.next(in: 60...350)
            let fall: CGFloat = random.next(in: 0...1)
            let y: CGFloat = 200 + fall * 120
            let size: CGFloat = 0.6 + fall * 1.4
            let w: CGFloat = random.next(in: 3...8) * size
            let h: CGFloat = w * random.next(in: 0.2...0.45)
            let a: CGPoint = pt(x + w * 0.3, y - h)
            let b: CGPoint = pt(x + w * 0.8, y - h * 0.85)
            floes.addPath(Art.polygon([pt(x, y), a, b, pt(x + w, y)]))
            feet.move(to: pt(x - 0.5, y + 0.6))
            feet.addLine(to: pt(x + w + 0.5, y + 0.6))
        }
        Art.stroke(&context, feet, Art.color(0x6FC2D2, 0.4), width: 1)
        Art.fill(&context, floes, Art.color(0xEEF6F8, 0.92))
    }

    // MARK: The shores

    static func ilulissatRock(_ context: inout GraphicsContext, _ shape: Path, from y0: CGFloat, to y1: CGFloat) {
        let rock: [(Color, CGFloat)] = [
            (Art.color(0x76706A), 0),
            (Art.color(0x4A4C58), 0.45),
            (Art.color(0x2C3646), 1),
        ]
        fillVertical(&context, shape, rock, from: y0, to: y1)
        model(&context, shape, light: 0.18, shade: 0.22, rim: 0.6)
    }

    static func ilulissatLeftShore(_ context: inout GraphicsContext) {
        let shore = Art.svg("M-24,404 L-24,170 C4,168 26,176 44,188 C60,198 72,214 84,232 C94,246 102,258 100,268 C96,280 80,290 60,298 L-24,322 Z")
        ArtStyle.contactShadow(&context, 70, 290, 40, 4, alpha: 0.24)
        ilulissatRock(&context, shore, from: 168, to: 330)
        let tundra = Art.svg("M-24,170 C4,168 26,176 44,188 C60,198 72,214 84,232 L76,238 C64,222 50,208 36,200 C20,190 0,184 -24,186 Z")
        let strata = Art.svg("M-24,214 C10,210 40,224 70,244 M-24,250 C14,246 50,262 86,270 M-24,284 C10,282 36,290 62,296")
        let dabs = Art.svg("M6,180 L14,182 M26,186 L32,190 M48,198 L54,204 M64,214 L68,220")
        Art.clipped(&context, to: shore) { g in
            Art.fill(&g, tundra, Art.color(0x8C8650, 0.85))
            Art.stroke(&g, dabs, Art.color(0x9A6A44, 0.6), width: 2)
            Art.stroke(&g, strata, Art.color(0x2A2E40, 0.3), width: 1.4)
        }
        let lip = Art.svg("M-24,170 C4,168 26,176 44,188 C60,198 72,214 84,232")
        Art.stroke(&context, lip, Art.color(0xE8D8A0, 0.5), width: 1)
    }

    static func ilulissatRightShore(_ context: inout GraphicsContext) {
        let shore = Art.svg("M456,404 L456,168 C436,170 414,178 398,190 C380,202 364,216 350,234 C338,250 330,262 326,274 C336,288 362,298 400,304 L456,310 Z")
        ArtStyle.contactShadow(&context, 360, 300, 46, 5, alpha: 0.26)
        ilulissatRock(&context, shore, from: 168, to: 320)
        let tundra = Art.svg("M456,168 C436,170 414,178 398,190 C380,202 364,216 350,234 L358,238 C370,222 386,208 402,199 C420,190 438,184 456,183 Z")
        let strata = Art.svg("M346,250 C376,240 410,236 456,230 M332,272 C364,266 410,262 456,258 M360,292 C392,286 420,286 456,284")
        let dabs = Art.svg("M420,180 L428,178 M372,210 L378,206 M440,176 L448,174")
        Art.clipped(&context, to: shore) { g in
            Art.fill(&g, tundra, Art.color(0x8C8650, 0.85))
            Art.stroke(&g, dabs, Art.color(0x9A6A44, 0.6), width: 2)
            Art.stroke(&g, strata, Art.color(0x2A2E40, 0.32), width: 1.4)
            // The shore's right side turns away from the sun.
            Art.fill(&g, Art.rect(420, 160, 40, 160), ArtStyle.coolShade.opacity(0.14))
        }
        let lip = Art.svg("M456,168 C436,170 414,178 398,190 C380,202 364,216 350,234")
        Art.stroke(&context, lip, Art.color(0xE8D8A0, 0.55), width: 1)
    }

    /// The small red wooden house on the right-hand rocks: gable end to the sun.
    static func ilulissatHouse(_ context: inout GraphicsContext) {
        ArtStyle.contactShadow(&context, 398, 196.5, 13, 1.8, alpha: 0.3)
        let gable = Art.polygon([pt(384, 196), pt(384, 186), pt(390, 180), pt(396, 186), pt(396, 196)])
        Art.fill(&context, gable, Art.color(0xD24C3C))
        Art.fill(&context, Art.rect(384, 186, 3, 10), Art.color(0xF0806A, 0.5))
        let side = Art.rect(396, 186, 10, 10)
        Art.fill(&context, side, Art.color(0xA23634))
        Art.fill(&context, side, ArtStyle.coolShade.opacity(0.12))
        let roof = Art.polygon([pt(390, 179.4), pt(404, 179.4), pt(407.4, 186.4), pt(396, 186.4)])
        Art.fill(&context, roof, Art.color(0x4C5068))
        Art.fill(&context, Art.rect(402, 176.4, 2.2, 4), Art.color(0x4C5068))
        // White trim along the gable and the corners, and two small windows.
        var trim = Path()
        trim.move(to: pt(383.6, 186.4))
        trim.addLine(to: pt(390, 179.8))
        trim.addLine(to: pt(396.4, 186.4))
        trim.move(to: pt(396, 186.4))
        trim.addLine(to: pt(396, 196))
        trim.move(to: pt(406, 186.6))
        trim.addLine(to: pt(406, 196))
        Art.stroke(&context, trim, Art.color(0xFFF6E6, 0.9), width: 0.7)
        var windows = Path()
        windows.addRect(CGRect(x: 387.6, y: 189, width: 4.4, height: 4))
        windows.addRect(CGRect(x: 399.4, y: 189, width: 3.6, height: 3.6))
        Art.fill(&context, windows, Art.color(0xFFF0D0, 0.9))
        var bars = Art.line(389.8, 189, 389.8, 193)
        bars.move(to: pt(387.6, 191))
        bars.addLine(to: pt(392, 191))
        Art.stroke(&context, bars, Art.color(0xA23634, 0.8), width: 0.5, cap: .butt)
    }

    // MARK: The near plane and finish

    /// A dark rock with a few tufts of tundra in the bottom-left corner.
    static func ilulissatNearRock(_ context: inout GraphicsContext) {
        let rock = Art.svg("M-24,428 L-24,318 C6,314 34,324 56,342 C74,356 88,378 96,404 L100,428 Z")
        let dark: [(Color, CGFloat)] = [
            (Art.color(0x34404E), 0),
            (Art.color(0x1C2C3C), 1),
        ]
        fillVertical(&context, rock, dark, from: 316, to: unitHeight)
        model(&context, rock, light: 0.08, shade: 0.2, rim: 0.5)
        let tufts = Art.svg("M4,318 L2,310 M8,318 L10,309 M12,319 L15,312 M30,324 L28,316 M34,325 L37,317 M50,336 L52,329 M54,339 L58,333")
        Art.stroke(&context, tufts, Art.color(0x6E6E44, 0.9), width: 1.2)
        let lit = Art.svg("M-24,318 C6,314 34,324 56,342 C66,350 74,360 80,370")
        Art.stroke(&context, lit, Art.color(0xFFD9A0, 0.3), width: 1)
    }

    static func ilulissatFinish(_ context: inout GraphicsContext) {
        bottomFade(&context, 0x173A52, from: 300, alpha: 0.9)
        tooth(&context, seed: 557, light: 0.05, dark: 0.04)
        finish(&context, wash: 0.10, vignette: 0.10)
    }
}
