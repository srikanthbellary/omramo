import SwiftUI
import OmramoCore

// Kizhi Pogost on Lake Onega by day: our own drawing (no photograph, nothing traced).
// The wooden Church of the Transfiguration: a log tower rising in octagonal tiers, each tier
// crowned with silver-grey shingled onion domes on curved gables, one big dome on top; beside
// it a tent-roofed bell tower and the smaller Church of the Intercession with its crown of
// domes. A low log fence, the grassy island, the lake and a pale northern sky.
// Card background #22394A.

extension LandmarkArt {
    /// kizhi: the many-domed wooden church, its bell tower and the smaller church on the grassy
    /// island, with the lake behind and a pale northern sky.
    static func paintKizhi(_ context: inout GraphicsContext) {
        kizhiSky(&context)
        kizhiLake(&context)
        kizhiIsland(&context)
        kizhiIntercession(&context)
        kizhiBellTower(&context)
        kizhiUpperTiers(&context)
        kizhiLowerTiers(&context)
        // Warm light on the silver domes and the weathered logs, from the upper left.
        Art.glow(&context, 150, 150, 150, Art.color(0xFFE2B4), alpha: 0.16)
        kizhiFence(&context)
        kizhiNear(&context)
        kizhiFinish(&context)
    }

    // MARK: Materials

    /// Weathered log walls: warm grey-brown, lit on the left.
    static func kizhiWood(_ context: inout GraphicsContext, _ shape: Path, from x0: CGFloat, to x1: CGFloat) {
        let wood: [(Color, CGFloat)] = [
            (Art.color(0xCDB08A), 0),
            (Art.color(0xA78868), 0.45),
            (Art.color(0x76624F), 1),
        ]
        fillHorizontal(&context, shape, wood, from: x0, to: x1)
    }

    /// Aspen shingles weathered to silver: pale and warm in the light, blue-grey in shade.
    static func kizhiShingle(_ context: inout GraphicsContext, _ shape: Path, from x0: CGFloat, to x1: CGFloat) {
        let silver: [(Color, CGFloat)] = [
            (Art.color(0xF4F0E6), 0),
            (Art.color(0xCACDD2), 0.45),
            (Art.color(0x8890A2), 1),
        ]
        fillHorizontal(&context, shape, silver, from: x0, to: x1)
    }

    /// The level seams between the logs, clipped to `shape`.
    static func kizhiLogs(_ context: inout GraphicsContext, _ shape: Path, spacing: CGFloat) {
        let box = shape.boundingRect
        var seams = Path()
        var y: CGFloat = box.minY + spacing
        while y < box.maxY {
            seams.move(to: pt(box.minX, y))
            seams.addLine(to: pt(box.maxX, y))
            y += spacing
        }
        Art.clipped(&context, to: shape) { g in
            Art.stroke(&g, seams, Art.color(0x5A4638, 0.36), width: 0.6, cap: .butt)
        }
    }

    /// One octagonal log drum between `x0` and `x1`, seen face on: a lit left face, the front
    /// face and a shaded right face, with a little shingled skirt at its top.
    static func kizhiDrum(_ context: inout GraphicsContext, _ x0: CGFloat, _ x1: CGFloat, top: CGFloat, bottom: CGFloat) {
        let w: CGFloat = x1 - x0
        let h: CGFloat = bottom - top
        let side: CGFloat = w * 0.22
        let body = Art.rect(x0, top, w, h)
        kizhiWood(&context, body, from: x0, to: x1)
        kizhiLogs(&context, body, spacing: 3.6)
        Art.fill(&context, Art.rect(x0, top, side, h), Art.color(0xFFE2BC, 0.18))
        Art.fill(&context, Art.rect(x1 - side, top, side, h), ArtStyle.coolShade.opacity(0.18))
        var corners = Art.line(x0 + side, top, x0 + side, bottom)
        corners.move(to: pt(x1 - side, top))
        corners.addLine(to: pt(x1 - side, bottom))
        Art.stroke(&context, corners, Art.color(0x5A4638, 0.4), width: 0.7, cap: .butt)
        let skirtTop: CGFloat = top - 2.5
        let skirtLow: CGFloat = top + 4
        let skirt = Art.polygon([pt(x0 - 3, skirtLow), pt(x0 + 2, skirtTop), pt(x1 - 2, skirtTop), pt(x1 + 3, skirtLow)])
        kizhiShingle(&context, skirt, from: x0 - 3, to: x1 + 3)
        Art.stroke(&context, Art.line(x0 - 3, skirtLow, x1 + 3, skirtLow), Art.color(0x6E7688, 0.5), width: 0.6, cap: .butt)
    }

    /// One crowned gable: a curved, pointed shingled gable (the "barrel" roof) standing on
    /// `base`, a short neck and a shingled onion dome with a slim spike. `back` darkens the
    /// domes that stand behind the front row.
    static func kizhiCupola(_ context: inout GraphicsContext, _ cx: CGFloat, _ base: CGFloat, scale s: CGFloat, back: Bool) {
        let gableHalf: CGFloat = 9 * s
        let gableTop: CGFloat = base - 13 * s
        let shoulder: CGFloat = base - 8.5 * s
        var gable = Path()
        gable.move(to: pt(cx - gableHalf, base))
        gable.addCurve(to: pt(cx, gableTop), control1: pt(cx - gableHalf, shoulder), control2: pt(cx - 1.6 * s, base - 7 * s))
        gable.addCurve(to: pt(cx + gableHalf, base), control1: pt(cx + 1.6 * s, base - 7 * s), control2: pt(cx + gableHalf, shoulder))
        gable.closeSubpath()
        kizhiShingle(&context, gable, from: cx - gableHalf, to: cx + gableHalf)

        let neck = Art.rect(cx - 2.8 * s, base - 16.5 * s, 5.6 * s, 5 * s)
        kizhiWood(&context, neck, from: cx - 2.8 * s, to: cx + 2.8 * s)

        let domeBase: CGFloat = base - 15 * s
        let domeHeight: CGFloat = 17 * s
        let dome = onionDome(cx, domeBase, halfWidth: 4.6 * s, height: domeHeight)
        let domeHalf: CGFloat = 6.4 * s
        kizhiShingle(&context, dome, from: cx - domeHalf, to: cx + domeHalf)
        if !back {
            model(&context, dome, light: 0.2, shade: 0.18)
        }
        // Rows of shingles, suggested by two curved seams.
        var seams = Path()
        let rowA: CGFloat = domeBase - domeHeight * 0.22
        let rowB: CGFloat = domeBase - domeHeight * 0.5
        seams.move(to: pt(cx - domeHalf, rowA))
        seams.addQuadCurve(to: pt(cx + domeHalf, rowA), control: pt(cx, rowA + 2.2 * s))
        seams.move(to: pt(cx - domeHalf, rowB))
        seams.addQuadCurve(to: pt(cx + domeHalf, rowB), control: pt(cx, rowB + 2 * s))
        Art.clipped(&context, to: dome) { g in
            Art.stroke(&g, seams, Art.color(0x7A8296, 0.45), width: 0.5)
        }
        let tip: CGFloat = domeBase - domeHeight
        Art.stroke(&context, Art.line(cx, tip + 0.5, cx, tip - 3.5 * s), Art.color(0x7A8296), width: 0.8)
        if back {
            var all = gable
            all.addPath(neck)
            all.addPath(dome)
            Art.fill(&context, all, ArtStyle.coolShade.opacity(0.2))
        }
    }

    /// Draws a cupola at each (x, base, scale).
    static func kizhiCupolas(_ context: inout GraphicsContext, _ places: [(CGFloat, CGFloat, CGFloat)], back: Bool) {
        for place in places {
            kizhiCupola(&context, place.0, place.1, scale: place.2, back: back)
        }
    }

    // MARK: Sky, lake and island

    static func kizhiSky(_ context: inout GraphicsContext) {
        let sky: [(Color, CGFloat)] = [
            (Art.color(0x9CC0DC), 0),
            (Art.color(0xCFE0EA), 0.3),
            (Art.color(0xF4E6CE), 0.56),
            (Art.color(0xF8E0BC), 0.62),
            (Art.color(0xF8E0BC), 1),
        ]
        backdrop(&context, sky)
        var clouds = cloudBand(250, 58, width: 120, height: 14)
        clouds.addPath(cloudBand(330, 92, width: 86, height: 9))
        clouds.addPath(cloudBand(96, 132, width: 64, height: 7))
        Art.fill(&context, clouds, Art.color(0xFFFFFF, 0.45))
        let undersides = Art.svg("M254,58 Q310,63 370,58 M334,92 Q372,96 416,92 M98,132 Q128,135 160,132")
        Art.stroke(&context, undersides, Art.color(0xFFD9A8, 0.4), width: 1)
    }

    /// The lake, with the far wooded shore low on the horizon.
    static func kizhiLake(_ context: inout GraphicsContext) {
        let water = Art.rect(-24, 248, unitWidth + 48, 70)
        let lake: [(Color, CGFloat)] = [
            (Art.color(0xC4D4DA), 0),
            (Art.color(0x8EAEC0), 0.4),
            (Art.color(0x5E8098), 1),
        ]
        fillVertical(&context, water, lake, from: 248, to: 318)
        let farShore = canopy(from: -24, to: 456, baseY: 250, height: 9, bump: 14, depth: 2, seed: 19)
        Art.fill(&context, farShore, Art.color(0x6E8A8C))
        let farIsle = canopy(from: 20, to: 120, baseY: 256, height: 6, bump: 10, depth: 2, seed: 23)
        Art.fill(&context, farIsle, Art.color(0x7E9894))
        haze(&context, top: 226, bottom: 258, hex: 0xF4E4CC, alpha: 0.5)
        horizon(&context, y: 250, rise: 34, hex: 0xFFDCAA, alpha: 0.3)
        let calm = CGRect(x: -10, y: 260, width: unitWidth + 20, height: 30)
        ripples(&context, in: calm, count: 50, seed: 29, color: Art.color(0xEAF2F4, 0.45), width: 0.8, length: 5...16)
        let glints = CGRect(x: 10, y: 258, width: 120, height: 28)
        ripples(&context, in: glints, count: 16, seed: 31, color: Art.color(0xFFEACB, 0.6), width: 0.9, length: 3...9)
    }

    /// The grassy island the churches stand on.
    static func kizhiIsland(_ context: inout GraphicsContext) {
        let island = Art.svg("M-24,428 L-24,294 C40,285 100,287 160,290 C220,293 300,288 360,286 C400,285 430,288 456,291 L456,428 Z")
        let grass: [(Color, CGFloat)] = [
            (Art.color(0xB6C27A), 0),
            (Art.color(0x8CA45E), 0.3),
            (Art.color(0x4E6E50), 0.7),
            (Art.color(0x22394A), 1),
        ]
        fillVertical(&context, island, grass, from: 285, to: unitHeight)
        let lip = Art.svg("M-24,294 C40,285 100,287 160,290 C220,293 300,288 360,286 C400,285 430,288 456,291")
        Art.stroke(&context, lip, Art.color(0xE8E0A8, 0.55), width: 1)
        // A worn path toward the churches, and a scatter of small meadow flowers.
        let track = Art.svg("M176,293 C170,310 150,330 120,350 L150,350 C176,330 186,312 184,293 Z")
        Art.fill(&context, track, Art.color(0xD8C894, 0.35))
        var random = ArtRandom(37)
        var flowers = Path()
        for _ in 0..<40 {
            let x: CGFloat = random.next(in: 20...410)
            let y: CGFloat = random.next(in: 300...340)
            flowers.addEllipse(in: CGRect(x: x, y: y, width: 1.4, height: 1.2))
        }
        Art.fill(&context, flowers, Art.color(0xFFF2C0, 0.75))
    }

    // MARK: The smaller church and the bell tower

    /// The Church of the Intercession: a long refectory, a log base and an octagon crowned
    /// with a ring of small domes round a larger one.
    static func kizhiIntercession(_ context: inout GraphicsContext) {
        ArtStyle.contactShadow(&context, 346, 292, 46, 3.5, alpha: 0.24)
        let refectory = Art.rect(304, 262, 38, 30)
        kizhiWood(&context, refectory, from: 304, to: 342)
        kizhiLogs(&context, refectory, spacing: 3.6)
        Art.fill(&context, refectory, Art.color(0x5A4638, 0.08))
        let roof = Art.polygon([pt(300, 264), pt(308, 250), pt(338, 250), pt(345, 264)])
        kizhiShingle(&context, roof, from: 300, to: 345)
        model(&context, roof, light: 0.16, shade: 0.18)

        let backRing: [(CGFloat, CGFloat, CGFloat)] = [(354, 210, 0.6), (372, 210, 0.6)]
        let frontRing: [(CGFloat, CGFloat, CGFloat)] = [(346, 212, 0.68), (363, 212, 0.68), (380, 212, 0.68)]
        kizhiDrum(&context, 347, 379, top: 208, bottom: 242)
        kizhiCupolas(&context, backRing, back: true)
        kizhiDrum(&context, 355, 371, top: 194, bottom: 210)
        kizhiCupola(&context, 363, 196, scale: 1.0, back: false)
        kizhiCupolas(&context, frontRing, back: false)
        kizhiDrum(&context, 342, 384, top: 240, bottom: 292)

        var windows = Path()
        windows.addRect(CGRect(x: 312, y: 272, width: 4, height: 6))
        windows.addRect(CGRect(x: 328, y: 272, width: 4, height: 6))
        windows.addRect(CGRect(x: 352, y: 258, width: 4, height: 6))
        windows.addRect(CGRect(x: 370, y: 258, width: 4, height: 6))
        windows.addRect(CGRect(x: 361, y: 222, width: 3.6, height: 5))
        Art.fill(&context, windows, Art.color(0x4A3A34, 0.8))
        haze(&context, top: 150, bottom: 292, hex: 0xF4E4CC, alpha: 0.06)
    }

    /// The bell tower: a square log base, an octagon, the open belfry and a tall shingled tent
    /// roof with a small dome on its point.
    static func kizhiBellTower(_ context: inout GraphicsContext) {
        ArtStyle.contactShadow(&context, 284, 292, 18, 2.6, alpha: 0.26)
        kizhiDrum(&context, 270, 290, top: 196, bottom: 238)
        kizhiDrum(&context, 266, 294, top: 236, bottom: 292)

        // The open belfry: dark inside, between slim posts.
        let belfry = Art.rect(270, 181, 20, 15)
        Art.fill(&context, belfry, Art.color(0x4A3A34))
        let bell = Art.svg("M277.4,192 C277.4,187 278,185.4 280,185.4 C282,185.4 282.6,187 282.6,192 Z")
        Art.fill(&context, bell, Art.color(0xB88E5A, 0.8))
        var posts = Path()
        let postXs: [CGFloat] = [270.6, 276.4, 283.6, 289.4]
        for x in postXs {
            posts.addRect(CGRect(x: x - 0.8, y: 181, width: 1.6, height: 15))
        }
        kizhiWood(&context, posts, from: 270, to: 290)
        let rail = Art.rect(269, 190.5, 22, 1.6)
        kizhiWood(&context, rail, from: 269, to: 291)

        let tent = Art.polygon([pt(266, 182), pt(280, 126), pt(294, 182)])
        kizhiShingle(&context, tent, from: 266, to: 294)
        model(&context, tent, light: 0.2, shade: 0.2, rim: 0.5)
        let seams = Art.svg("M271,162 L289,162 M268.5,172 L291.5,172 M273.5,152 L286.5,152 M276,142 L284,142")
        Art.clipped(&context, to: tent) { g in
            Art.stroke(&g, seams, Art.color(0x7A8296, 0.45), width: 0.5)
        }
        let neck = Art.rect(278, 122, 4, 6)
        kizhiWood(&context, neck, from: 278, to: 282)
        let dome = onionDome(280, 124, halfWidth: 3.4, height: 12)
        kizhiShingle(&context, dome, from: 275, to: 285)
        model(&context, dome, light: 0.2, shade: 0.18)
        Art.stroke(&context, Art.line(280, 112.5, 280, 108), Art.color(0x7A8296), width: 0.8)

        var windows = Path()
        windows.addRect(CGRect(x: 278, y: 212, width: 4, height: 6))
        windows.addRect(CGRect(x: 278, y: 256, width: 4, height: 6))
        Art.fill(&context, windows, Art.color(0x4A3A34, 0.8))
    }

    // MARK: The Church of the Transfiguration

    /// The upper tiers, drawn from the top down so each lower tier stands in front of the one
    /// above it: the top drum and the great dome, then two tiers of drums and domes.
    static func kizhiUpperTiers(_ context: inout GraphicsContext) {
        kizhiDrum(&context, 164, 188, top: 112, bottom: 152)
        let neck = Art.rect(169, 100, 14, 13)
        kizhiWood(&context, neck, from: 169, to: 183)
        Art.fill(&context, Art.rect(179.5, 100, 3.5, 13), ArtStyle.coolShade.opacity(0.18))
        let dome = onionDome(176, 104, halfWidth: 11, height: 40)
        kizhiShingle(&context, dome, from: 161, to: 191)
        model(&context, dome, light: 0.22, shade: 0.2, rim: 0.6)
        let seams = Art.svg("M160,96 Q176,100 192,96 M161,86 Q176,90 191,86 M164,77 Q176,80 188,77 M168,70 Q176,72 184,70")
        Art.clipped(&context, to: dome) { g in
            Art.stroke(&g, seams, Art.color(0x7A8296, 0.45), width: 0.6)
        }
        Art.stroke(&context, Art.line(176, 64.5, 176, 56), Art.color(0x7A8296), width: 1)
        // The sun's sheen on the great dome's left shoulder.
        let sheen = Art.svg("M165,98 C161,90 163,80 170,72")
        Art.stroke(&context, sheen, Art.color(0xFFF2DC, 0.7), width: 1.4)

        kizhiDrum(&context, 156, 196, top: 150, bottom: 190)
        let rowC: [(CGFloat, CGFloat, CGFloat)] = [(158, 152, 0.85), (194, 152, 0.85)]
        kizhiCupolas(&context, rowC, back: false)

        kizhiDrum(&context, 144, 208, top: 188, bottom: 228)
        let rowBBack: [(CGFloat, CGFloat, CGFloat)] = [(160, 190, 0.8), (192, 190, 0.8)]
        let rowB: [(CGFloat, CGFloat, CGFloat)] = [(142, 192, 0.92), (176, 192, 0.92), (210, 192, 0.92)]
        kizhiCupolas(&context, rowBBack, back: true)
        kizhiCupolas(&context, rowB, back: false)
    }

    /// The lowest tier: the main log body, its two side arms and their domes, and the porch.
    static func kizhiLowerTiers(_ context: inout GraphicsContext) {
        ArtStyle.contactShadow(&context, 182, 292, 82, 4.5, alpha: 0.26)
        kizhiDrum(&context, 128, 224, top: 226, bottom: 292)
        let rowABack: [(CGFloat, CGFloat, CGFloat)] = [(132, 228, 0.9), (220, 228, 0.9)]
        let rowA: [(CGFloat, CGFloat, CGFloat)] = [(146, 230, 1), (176, 230, 1), (206, 230, 1)]
        kizhiCupolas(&context, rowABack, back: true)
        kizhiCupolas(&context, rowA, back: false)

        // The side arms reach toward us, each with its own crowned gable.
        var arms = Path()
        arms.addRect(CGRect(x: 104, y: 258, width: 24, height: 34))
        arms.addRect(CGRect(x: 224, y: 258, width: 24, height: 34))
        kizhiWood(&context, arms, from: 104, to: 248)
        kizhiLogs(&context, arms, spacing: 3.6)
        Art.fill(&context, Art.rect(104, 258, 6, 34), Art.color(0xFFE2BC, 0.2))
        Art.fill(&context, Art.rect(240, 258, 8, 34), ArtStyle.coolShade.opacity(0.2))
        // Where each arm meets the body, the body is in its shade.
        var tucks = Path()
        tucks.addRect(CGRect(x: 128, y: 258, width: 3, height: 34))
        tucks.addRect(CGRect(x: 221, y: 258, width: 3, height: 34))
        Art.fill(&context, tucks, ArtStyle.coolShade.opacity(0.16))
        let armDomes: [(CGFloat, CGFloat, CGFloat)] = [(116, 260, 1), (236, 260, 1)]
        kizhiCupolas(&context, armDomes, back: false)

        // The porch at the front, with its own little shingled gable and the door.
        let porch = Art.rect(162, 272, 28, 20)
        kizhiWood(&context, porch, from: 162, to: 190)
        kizhiLogs(&context, porch, spacing: 3.6)
        let porchRoof = Art.polygon([pt(157, 274), pt(176, 261), pt(195, 274)])
        kizhiShingle(&context, porchRoof, from: 157, to: 195)
        model(&context, porchRoof, light: 0.18, shade: 0.18)
        Art.fill(&context, Art.rect(171, 278, 10, 14), Art.color(0x4A3A34))
        Art.stroke(&context, Art.line(157, 274.4, 176, 261.4), Art.color(0xFFF2DC, 0.6), width: 0.8)

        var windows = Path()
        windows.addRect(CGRect(x: 140, y: 248, width: 4, height: 6))
        windows.addRect(CGRect(x: 208, y: 248, width: 4, height: 6))
        windows.addRect(CGRect(x: 113, y: 272, width: 4, height: 6))
        windows.addRect(CGRect(x: 235, y: 272, width: 4, height: 6))
        windows.addRect(CGRect(x: 174, y: 206, width: 4, height: 6))
        windows.addRect(CGRect(x: 174, y: 166, width: 3.6, height: 5))
        Art.fill(&context, windows, Art.color(0x4A3A34, 0.8))
    }

    // MARK: Fence, near plane and finish

    /// The low fence of long slanting poles between paired posts, across the meadow.
    static func kizhiFence(_ context: inout GraphicsContext) {
        var posts = Path()
        var poles = Path()
        var x: CGFloat = 18
        while x < 420 {
            let sag: CGFloat = (x - 216) * 0.012
            let foot: CGFloat = 316 + sag
            posts.move(to: pt(x, foot))
            posts.addLine(to: pt(x, foot - 15))
            posts.move(to: pt(x + 2.2, foot))
            posts.addLine(to: pt(x + 2.2, foot - 15))
            poles.move(to: pt(x + 1, foot - 3))
            poles.addLine(to: pt(x + 25, foot - 13))
            poles.move(to: pt(x + 1, foot - 8))
            poles.addLine(to: pt(x + 25, foot - 15.5))
            x += 24
        }
        Art.stroke(&context, poles, Art.color(0x7A6452), width: 1.6)
        Art.stroke(&context, poles, Art.color(0xD8BE96, 0.4), width: 0.5)
        Art.stroke(&context, posts, Art.color(0x5E4A3E), width: 1.6)
        ArtStyle.contactShadow(&context, 216, 317, 200, 2.4, alpha: 0.18)
    }

    /// Dark tufts of meadow grass in the two bottom corners.
    static func kizhiNear(_ context: inout GraphicsContext) {
        let left = Art.svg("M-24,428 L-24,332 C10,326 40,336 62,356 C78,372 86,392 90,428 Z")
        let right = Art.svg("M456,428 L456,342 C430,336 404,346 386,364 C374,378 368,400 366,428 Z")
        let dark: [(Color, CGFloat)] = [
            (Art.color(0x3E5A46), 0),
            (Art.color(0x1E3440), 1),
        ]
        fillVertical(&context, left, dark, from: 326, to: unitHeight)
        model(&context, left, light: 0.08, shade: 0.2, rim: 0.5)
        fillVertical(&context, right, dark, from: 336, to: unitHeight)
        model(&context, right, light: 0.06, shade: 0.22)
        let blades = Art.svg("M4,332 L1,318 M10,331 L12,316 M18,331 L22,320 M34,336 L32,324 M40,339 L45,327 M54,348 L58,338 M398,352 L394,340 M406,346 L408,332 M416,342 L420,330 M430,340 L428,326 M442,339 L446,328")
        Art.stroke(&context, blades, Art.color(0x3E5A46), width: 1.4)
        let lit = Art.svg("M10,331 L12,316 M40,339 L45,327 M406,346 L408,332")
        Art.stroke(&context, lit, Art.color(0xE8E0A8, 0.4), width: 0.6)
    }

    static func kizhiFinish(_ context: inout GraphicsContext) {
        bottomFade(&context, 0x22394A, from: 300, alpha: 0.9)
        tooth(&context, seed: 571, light: 0.05, dark: 0.04)
        finish(&context, wash: 0.10, vignette: 0.10)
    }
}
