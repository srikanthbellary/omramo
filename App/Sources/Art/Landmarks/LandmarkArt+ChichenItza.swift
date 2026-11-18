import SwiftUI
import OmramoCore

// Chichen Itza by day: our own drawing (no photograph, nothing traced).
// The step pyramid known as El Castillo, seen from near a corner: nine terraces of grey-cream
// limestone, a broad stairway up the sunlit face and a second stair seen edge-on on the shaded
// side, and the square temple with its doorway on top. It stands on a short green lawn with
// the low dark forest of Yucatan behind it and big clouds above; a few tiny visitors give the
// scale. Card background #1F4A3A.

extension LandmarkArt {
    /// chichen-itza: the grey stone step pyramid with nine terraces, its stairways and the
    /// square temple on top, on a green lawn with forest behind and big clouds, by day.
    static func paintChichenItza(_ context: inout GraphicsContext) {
        chichenSky(&context)
        chichenForest(&context)
        chichenLawn(&context)
        chichenTerraces(&context)
        chichenMasonry(&context)
        chichenStair(&context, from: 1, to: 2, lit: false)
        chichenStair(&context, from: 0, to: 1, lit: true)
        chichenTemple(&context)
        chichenTempleDetail(&context)
        // Warm light lying on the sunlit face, from the upper left.
        Art.glow(&context, 150, 190, 120, Art.color(0xFFF0C8), alpha: 0.14)
        chichenVisitors(&context)
        chichenNearPlane(&context)
        chichenFinish(&context)
    }

    // MARK: Geometry

    /// A corner of the pyramid at height `t` (0 on the lawn, 1 at the top platform):
    /// 0 is the far left corner, 1 the corner that points at the viewer, 2 the far right one.
    static func chichenCorner(_ which: Int, _ t: CGFloat) -> CGPoint {
        switch which {
        case 0:
            return chichenLerp(CGPoint(x: 70, y: 282), CGPoint(x: 166, y: 144), t)
        case 1:
            return chichenLerp(CGPoint(x: 268, y: 290), CGPoint(x: 254, y: 140), t)
        default:
            return chichenLerp(CGPoint(x: 360, y: 280), CGPoint(x: 296, y: 143.5), t)
        }
    }

    /// The point `t` of the way from `a` to `b`.
    static func chichenLerp(_ a: CGPoint, _ b: CGPoint, _ t: CGFloat) -> CGPoint {
        let x: CGFloat = a.x + (b.x - a.x) * t
        let y: CGFloat = a.y + (b.y - a.y) * t
        return CGPoint(x: x, y: y)
    }

    /// A corner of the temple: 0, 1, 2 are the feet of its left, near and right corners;
    /// 3, 4, 5 are the tops of the same three corners.
    static func chichenTemplePoint(_ which: Int) -> CGPoint {
        switch which {
        case 0: return CGPoint(x: 184, y: 143.2)
        case 1: return CGPoint(x: 244, y: 140.5)
        case 2: return CGPoint(x: 280, y: 142.2)
        case 3: return CGPoint(x: 184, y: 116.5)
        case 4: return CGPoint(x: 244, y: 110.5)
        default: return CGPoint(x: 280, y: 114.5)
        }
    }

    // MARK: Sky

    static func chichenSky(_ context: inout GraphicsContext) {
        let sky: [(Color, CGFloat)] = [
            (Art.color(0x4C9CDA), 0),
            (Art.color(0x8CC6EA), 0.32),
            (Art.color(0xD6EEF0), 0.56),
            (Art.color(0xFFF0CC), 0.68),
            (Art.color(0xFFF0CC), 1),
        ]
        backdrop(&context, sky)
        // Big fair-weather clouds; the far ones are smaller, lower and paler.
        chichenCloud(&context, 372, 196, scale: 0.6, alpha: 0.75)
        chichenCloud(&context, 40, 190, scale: 0.7, alpha: 0.8)
        chichenCloud(&context, 150, 66, scale: 0.5, alpha: 0.85)
        chichenCloud(&context, 318, 70, scale: 1, alpha: 1)
        chichenCloud(&context, 20, 124, scale: 0.9, alpha: 0.95)
    }

    /// One heaped cloud with a flat underside, its left tip near (`x`, `y`): white in the
    /// sun on its upper left, soft indigo underneath.
    static func chichenCloud(_ context: inout GraphicsContext, _ x: CGFloat, _ y: CGFloat, scale s: CGFloat, alpha: Double) {
        let puffs: [(CGFloat, CGFloat, CGFloat)] = [
            (0, 0, 20), (24, -12, 24), (52, -6, 21), (76, 4, 15),
            (-20, 6, 13), (36, 4, 22), (10, 6, 17), (62, 8, 15),
        ]
        var shape = Path()
        for puff in puffs {
            let r: CGFloat = puff.2 * s
            let cx: CGFloat = x + puff.0 * s
            let cy: CGFloat = y + puff.1 * s
            shape.addEllipse(in: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2))
        }
        let baseY: CGFloat = y + 13 * s
        let top: CGFloat = y - 40 * s
        let above = Art.rect(x - 40 * s, top, 140 * s, baseY - top, radius: 5 * s)
        let white: [(Color, CGFloat)] = [
            (Art.color(0xFFFFFF), 0),
            (Art.color(0xF4F4F6), 0.6),
            (Art.color(0xD6DCEC), 1),
        ]
        let under: [(Color, CGFloat)] = [
            (ArtStyle.coolShade.opacity(0), 0),
            (ArtStyle.coolShade.opacity(0.16), 1),
        ]
        let shadeTop: CGFloat = y - 2 * s
        let glowX: CGFloat = x + 8 * s
        let glowY: CGFloat = y - 22 * s
        let glowR: CGFloat = 46 * s
        Art.group(&context, opacity: alpha) { g in
            Art.clipped(&g, to: above) { c in
                fillVertical(&c, shape, white, from: top, to: baseY)
                Art.clipped(&c, to: shape) { inner in
                    fillVertical(&inner, above, under, from: shadeTop, to: baseY)
                    Art.glow(&inner, glowX, glowY, glowR, Art.color(0xFFF2CC), alpha: 0.5)
                }
            }
        }
    }

    // MARK: The far plane

    /// The low forest all along the skyline, veiled with the sky's own colour, and the nearer
    /// trees that close the lawn on both sides.
    static func chichenForest(_ context: inout GraphicsContext) {
        let farBand = canopy(from: -24, to: 456, baseY: 262, height: 14, bump: 22, depth: 16, seed: 301)
        Art.fill(&context, farBand, Art.color(0x6C9E78))
        let band = canopy(from: -24, to: 456, baseY: 271, height: 18, bump: 17, depth: 10, seed: 313)
        let green: [(Color, CGFloat)] = [
            (Art.color(0x427F54), 0),
            (Art.color(0x265C42), 1),
        ]
        fillVertical(&context, band, green, from: 250, to: 280)
        haze(&context, top: 226, bottom: 280, hex: 0xE6F2E4, alpha: 0.34)

        // Nearer trees at the two sides, darker and taller, with a little sun on their crowns.
        let deep: [(Color, CGFloat)] = [
            (Art.color(0x34784A), 0),
            (Art.color(0x1C4A36), 1),
        ]
        let trunks = Art.svg("M8,262 L9,278 M30,258 L30,278 M52,264 L51,278 M388,262 L389,278 M412,258 L411,278 M436,264 L436,278")
        Art.stroke(&context, trunks, Art.color(0x4E4034, 0.8), width: 1.4)
        let leftTrees = canopy(from: -24, to: 92, baseY: 268, height: 32, bump: 20, depth: 6, seed: 331)
        fillVertical(&context, leftTrees, deep, from: 234, to: 276)
        model(&context, leftTrees, light: 0.16, shade: 0.14)
        let rightTrees = canopy(from: 356, to: 456, baseY: 268, height: 30, bump: 19, depth: 6, seed: 337)
        fillVertical(&context, rightTrees, deep, from: 236, to: 276)
        model(&context, rightTrees, light: 0.12, shade: 0.2)
        Art.clipped(&context, to: leftTrees) { g in
            Art.stipple(&g, in: CGRect(x: -24, y: 234, width: 116, height: 30), count: 50, seed: 341, color: Art.color(0xB4DC84), alpha: 0.3, size: 0.8...2.2)
        }
        Art.clipped(&context, to: rightTrees) { g in
            Art.stipple(&g, in: CGRect(x: 356, y: 236, width: 100, height: 28), count: 40, seed: 343, color: Art.color(0xB4DC84), alpha: 0.26, size: 0.8...2.2)
        }
    }

    // MARK: Lawn

    static func chichenLawn(_ context: inout GraphicsContext) {
        let lawn = Art.rect(-24, 272, unitWidth + 48, unitHeight - 272 + 24)
        let grass: [(Color, CGFloat)] = [
            (Art.color(0xB8DA7A), 0),
            (Art.color(0x86BC5C), 0.3),
            (Art.color(0x3F7A48), 0.75),
            (Art.color(0x1F4A3A), 1),
        ]
        fillVertical(&context, lawn, grass, from: 272, to: unitHeight)
        horizon(&context, y: 272, rise: 30, hex: 0xFFF0C4, alpha: 0.24)

        // The worn pale ground round the foot of the pyramid, and the path to the stairway.
        let apron = Art.polygon([pt(54, 285), pt(268, 295), pt(376, 282), pt(360, 277), pt(70, 278)])
        Art.fill(&context, apron, Art.color(0xECE4C6, 0.5))
        let path = Art.svg("M150,290 L190,292 C186,312 168,330 140,352 C120,368 100,390 92,428 L10,428 C30,384 70,356 100,334 C124,318 142,304 150,290 Z")
        let worn: [(Color, CGFloat)] = [
            (Art.color(0xECE4C6, 0.5), 0),
            (Art.color(0xECE4C6, 0.16), 1),
        ]
        fillVertical(&context, path, worn, from: 290, to: 400)

        // The shadow the pyramid throws on the grass, away from the light.
        let shadow = Art.polygon([pt(268, 290), pt(360, 280), pt(456, 284), pt(456, 300), pt(336, 304)])
        let dusk: [(Color, CGFloat)] = [
            (ArtStyle.coolShade.opacity(0.32), 0),
            (ArtStyle.coolShade.opacity(0.14), 1),
        ]
        fillHorizontal(&context, shadow, dusk, from: 270, to: 456)

        let blades = CGRect(x: 0, y: 296, width: unitWidth, height: 76)
        ripples(&context, in: blades, count: 60, seed: 359, color: Art.color(0xDCF2A0, 0.34), width: 0.7, length: 3...9)
        ripples(&context, in: blades, count: 44, seed: 367, color: Art.color(0x2F6B3A, 0.3), width: 0.7, length: 3...10)
        let mown = Art.svg("M-24,312 C90,306 220,316 456,308 M-24,340 C120,332 280,344 456,334")
        Art.stroke(&context, mown, Art.color(0xDCF2A0, 0.16), width: 5)
    }

    // MARK: The nine terraces

    /// The nine sloping terraces, each set back from the one below: grey-cream in the sun on
    /// the left face, soft indigo shade on the right face.
    static func chichenTerraces(_ context: inout GraphicsContext) {
        var litRisers = Path()
        var shadeRisers = Path()
        var litLows = Path()
        var litEdges = Path()
        var shadeEdges = Path()
        for k in 0..<9 {
            let t0: CGFloat = CGFloat(k) / 9
            let t1: CGFloat = CGFloat(k + 1) / 9
            let l0: CGPoint = chichenCorner(0, t0)
            let f0: CGPoint = chichenCorner(1, t0)
            let r0: CGPoint = chichenCorner(2, t0)
            let l1: CGPoint = chichenCorner(0, t1)
            let f1: CGPoint = chichenCorner(1, t1)
            let r1: CGPoint = chichenCorner(2, t1)
            let lTop = pt((l0.x + l1.x) / 2, l1.y)
            let fTop = pt((f0.x + f1.x) / 2, f1.y)
            let rTop = pt((r0.x + r1.x) / 2, r1.y)
            litRisers.addPath(Art.polygon([l0, f0, fTop, lTop]))
            shadeRisers.addPath(Art.polygon([f0, r0, rTop, fTop]))
            let lLow: CGPoint = chichenLerp(l0, lTop, 0.35)
            let fLow: CGPoint = chichenLerp(f0, fTop, 0.35)
            litLows.addPath(Art.polygon([l0, f0, fLow, lLow]))
            litEdges.move(to: lTop)
            litEdges.addLine(to: fTop)
            shadeEdges.move(to: fTop)
            shadeEdges.addLine(to: rTop)
        }
        ArtStyle.contactShadow(&context, 230, 290, 150, 5, alpha: 0.2)

        let lit: [(Color, CGFloat)] = [
            (Art.color(0xF8F2DE), 0),
            (Art.color(0xE8E0C8), 0.5),
            (Art.color(0xD4CAB0), 1),
        ]
        fillVertical(&context, litRisers, lit, from: 140, to: 290)
        Art.fill(&context, litLows, Art.color(0xA89C80, 0.22))
        model(&context, litRisers, light: 0.16, shade: 0.05)

        let shade: [(Color, CGFloat)] = [
            (Art.color(0xA8A2B8), 0),
            (Art.color(0x9690AC), 0.5),
            (Art.color(0x8882A2), 1),
        ]
        fillVertical(&context, shadeRisers, shade, from: 140, to: 290)
        // Green light thrown back up from the lawn onto the foot of the shaded face.
        let bounce: [(Color, CGFloat)] = [
            (Art.color(0xB8D48A, 0), 0),
            (Art.color(0xB8D48A, 0.26), 1),
        ]
        Art.clipped(&context, to: shadeRisers) { g in
            fillVertical(&g, Art.rect(250, 236, 120, 56), bounce, from: 236, to: 290)
        }

        // The top edge of every terrace catches the light; the corner between the faces too.
        Art.stroke(&context, litEdges, Art.color(0xFFFDF0, 0.9), width: 1, cap: .butt)
        Art.stroke(&context, shadeEdges, Art.color(0xC8C2D6, 0.7), width: 0.8, cap: .butt)
    }

    /// The stonework of the terraces: one course line and a few upright joints on each.
    static func chichenMasonry(_ context: inout GraphicsContext) {
        var litLines = Path()
        var shadeLines = Path()
        for k in 0..<9 {
            let t0: CGFloat = CGFloat(k) / 9
            let t1: CGFloat = CGFloat(k + 1) / 9
            let l0: CGPoint = chichenCorner(0, t0)
            let f0: CGPoint = chichenCorner(1, t0)
            let r0: CGPoint = chichenCorner(2, t0)
            let l1: CGPoint = chichenCorner(0, t1)
            let f1: CGPoint = chichenCorner(1, t1)
            let r1: CGPoint = chichenCorner(2, t1)
            let lTop = pt((l0.x + l1.x) / 2, l1.y)
            let fTop = pt((f0.x + f1.x) / 2, f1.y)
            let rTop = pt((r0.x + r1.x) / 2, r1.y)
            litLines.move(to: chichenLerp(l0, lTop, 0.55))
            litLines.addLine(to: chichenLerp(f0, fTop, 0.55))
            shadeLines.move(to: chichenLerp(f0, fTop, 0.55))
            shadeLines.addLine(to: chichenLerp(r0, rTop, 0.55))
            let panels: Int = 15 - k
            for j in 1..<panels {
                let s: CGFloat = CGFloat(j) / CGFloat(panels)
                litLines.move(to: chichenLerp(l0, f0, s))
                litLines.addLine(to: chichenLerp(lTop, fTop, s))
            }
            let sidePanels: Int = 7 - k / 2
            for j in 1..<sidePanels {
                let s: CGFloat = CGFloat(j) / CGFloat(sidePanels)
                shadeLines.move(to: chichenLerp(f0, r0, s))
                shadeLines.addLine(to: chichenLerp(fTop, rTop, s))
            }
        }
        Art.stroke(&context, litLines, Art.color(0xA0947A, 0.3), width: 0.5, cap: .butt)
        Art.stroke(&context, shadeLines, Art.color(0x58528A, 0.3), width: 0.5, cap: .butt)
        // Weather stains on the old stone.
        let stains = Art.svg("M96,270 C110,262 130,266 134,276 C120,282 102,280 96,270 Z M214,236 C226,230 242,234 244,244 C232,250 218,246 214,236 Z M150,206 C160,200 172,204 174,212 C164,218 152,214 150,206 Z M226,180 C234,176 244,178 246,186 C238,190 228,188 226,180 Z")
        Art.fill(&context, stains, Art.color(0x8A8068, 0.12))
    }

    // MARK: Stairways

    /// The stairway up the middle of the face between corners `a` and `b`. The stair is less
    /// steep than the terraces, so it stands out from them at the foot. `lit` is the broad
    /// stair on the sunlit face; the other one is seen nearly edge-on, in shade.
    static func chichenStair(_ context: inout GraphicsContext, from a: Int, to b: Int, lit: Bool) {
        let footA: CGPoint = chichenLerp(chichenCorner(a, 0), chichenCorner(b, 0), 0.42)
        let footB: CGPoint = chichenLerp(chichenCorner(a, 0), chichenCorner(b, 0), 0.58)
        let drop: CGFloat = lit ? 3.5 : 2.5
        let bl = pt(footA.x, footA.y + drop)
        let br = pt(footB.x, footB.y + drop)
        let tl: CGPoint = chichenLerp(chichenCorner(a, 1), chichenCorner(b, 1), 0.32)
        let tr: CGPoint = chichenLerp(chichenCorner(a, 1), chichenCorner(b, 1), 0.68)

        if lit {
            // The shade the stair throws on the terraces to its right, and its shaded flank.
            let cast = Art.polygon([br, tr, pt(tr.x + 4, tr.y), pt(br.x + 11, footB.y)])
            Art.fill(&context, cast, ArtStyle.coolShade.opacity(0.16))
            let flank = Art.polygon([br, tr, pt(br.x + 4.5, footB.y)])
            Art.fill(&context, flank, Art.color(0xA6A0B6))
        } else {
            // The flank that faces the viewer's left is in the sun.
            let flank = Art.polygon([bl, tl, pt(bl.x - 4, footA.y)])
            Art.fill(&context, flank, Art.color(0xE4DCC4))
        }

        let stair = Art.polygon([bl, br, tr, tl])
        let stops: [(Color, CGFloat)] = [
            (Art.color(lit ? 0xFDF8E8 : 0xA29CB6), 0),
            (Art.color(lit ? 0xEAE2CA : 0x847EA0), 1),
        ]
        fillVertical(&context, stair, stops, from: tl.y, to: bl.y)

        var treads = Path()
        let count: Int = lit ? 32 : 22
        for index in 1..<count {
            let t: CGFloat = CGFloat(index) / CGFloat(count)
            treads.move(to: chichenLerp(bl, tl, t))
            treads.addLine(to: chichenLerp(br, tr, t))
        }
        let treadColor: Color = lit ? Art.color(0x9C9076, 0.55) : Art.color(0x565086, 0.5)
        Art.stroke(&context, treads, treadColor, width: 0.6, cap: .butt)

        // The two low walls that run up the sides of the stair.
        let railWidth: CGFloat = lit ? 2.6 : 1.6
        let nearRail: Color = lit ? Art.color(0xFFFCEE) : Art.color(0xB4AEC6)
        let farRail: Color = lit ? Art.color(0xD6CCB2) : Art.color(0x7C7698)
        Art.stroke(&context, Art.line(br.x, br.y, tr.x, tr.y), farRail, width: railWidth, cap: .butt)
        Art.stroke(&context, Art.line(bl.x, bl.y, tl.x, tl.y), nearRail, width: railWidth, cap: .butt)

        // Two simple carved shapes at the foot of the stair, one at the end of each low wall.
        let headW: CGFloat = lit ? 7 : 4.4
        let headH: CGFloat = lit ? 5 : 3.4
        var heads = Path()
        heads.addPath(Art.rect(bl.x - headW * 0.6, bl.y - headH * 0.5, headW, headH, radius: 2))
        heads.addPath(Art.rect(br.x - headW * 0.4, br.y - headH * 0.5, headW, headH, radius: 2))
        ArtStyle.contactShadow(&context, (bl.x + br.x) / 2 + 3, bl.y + headH * 0.5, headW * 3, 1.6, alpha: 0.24)
        Art.fill(&context, heads, lit ? Art.color(0xF6F0DC) : Art.color(0xA8A2BA))
        if lit {
            model(&context, heads, light: 0.2, shade: 0.24)
        }
    }

    // MARK: The temple

    /// The square temple on the top platform: its two walls and the flat roof.
    static func chichenTemple(_ context: inout GraphicsContext) {
        let a = chichenTemplePoint(0)
        let b = chichenTemplePoint(1)
        let c = chichenTemplePoint(2)
        let a2 = chichenTemplePoint(3)
        let b2 = chichenTemplePoint(4)
        let c2 = chichenTemplePoint(5)
        // The edge of the top platform, in the light.
        let rim = Art.polygon([chichenCorner(0, 1), chichenCorner(1, 1), chichenCorner(2, 1)], closed: false)
        Art.stroke(&context, rim, Art.color(0xFFFDF0, 0.9), width: 1.2, cap: .butt)

        let leftWall = Art.polygon([a, b, b2, a2])
        let rightWall = Art.polygon([b, c, c2, b2])
        let lit: [(Color, CGFloat)] = [
            (Art.color(0xF6F0DC), 0),
            (Art.color(0xDED4BA), 1),
        ]
        let shade: [(Color, CGFloat)] = [
            (Art.color(0xA49EB6), 0),
            (Art.color(0x8C86A4), 1),
        ]
        fillVertical(&context, leftWall, lit, from: 110, to: 144)
        model(&context, leftWall, light: 0.18, shade: 0.06)
        fillVertical(&context, rightWall, shade, from: 110, to: 144)

        // The shade under the roof, and the roof slab that stands out a little over the walls.
        let eaves = Art.polygon([a2, b2, c2, pt(c2.x, c2.y + 2.4), pt(b2.x, b2.y + 2.6), pt(a2.x, a2.y + 2.4)])
        Art.fill(&context, eaves, ArtStyle.coolShade.opacity(0.2))
        let leftSlab = Art.polygon([pt(182, 116.8), pt(244.6, 110.4), pt(244.6, 107.4), pt(182, 114)])
        let rightSlab = Art.polygon([pt(244.6, 110.4), pt(282, 114.8), pt(282, 112), pt(244.6, 107.4)])
        Art.fill(&context, leftSlab, Art.color(0xFFFBEA))
        Art.fill(&context, rightSlab, Art.color(0xB2ACC4))
        let roofLine = Art.polygon([pt(182, 114), pt(244.6, 107.4), pt(282, 112)], closed: false)
        Art.stroke(&context, roofLine, Art.color(0xFFFFFF, 0.8), width: 0.8, cap: .butt)
        Art.stroke(&context, Art.line(b.x, b.y, b2.x, b2.y), Art.color(0xFFFDF0, 0.7), width: 0.8, cap: .butt)
    }

    /// The moulding that runs round the temple, the plain band above it, and the doorways.
    static func chichenTempleDetail(_ context: inout GraphicsContext) {
        let a = chichenTemplePoint(0)
        let b = chichenTemplePoint(1)
        let c = chichenTemplePoint(2)
        let a2 = chichenTemplePoint(3)
        let b2 = chichenTemplePoint(4)
        let c2 = chichenTemplePoint(5)

        // The upper band of the walls, a little darker than the wall below the moulding.
        let aHigh: CGPoint = chichenLerp(a, a2, 0.64)
        let bHigh: CGPoint = chichenLerp(b, b2, 0.64)
        let cHigh: CGPoint = chichenLerp(c, c2, 0.64)
        let aLow: CGPoint = chichenLerp(a, a2, 0.56)
        let bLow: CGPoint = chichenLerp(b, b2, 0.56)
        let cLow: CGPoint = chichenLerp(c, c2, 0.56)
        let frieze = Art.polygon([aHigh, bHigh, cHigh, c2, b2, a2])
        Art.fill(&context, frieze, Art.color(0x8A8068, 0.14))
        let leftBand = Art.polygon([aLow, bLow, bHigh, aHigh])
        let rightBand = Art.polygon([bLow, cLow, cHigh, bHigh])
        Art.fill(&context, leftBand, Art.color(0xFFFCEE))
        Art.fill(&context, rightBand, Art.color(0xB8B2C8))
        let underBand = Art.polygon([aLow, bLow, cLow], closed: false)
        Art.group(&context, y: 0.8) { g in
            Art.stroke(&g, underBand, ArtStyle.coolShade.opacity(0.22), width: 0.9, cap: .butt)
        }

        // The doorway on the sunlit side, at the head of the stair: dark inside, with the sun
        // on its right-hand jamb.
        let d0: CGPoint = chichenLerp(a, b, 0.41)
        let d1: CGPoint = chichenLerp(a, b, 0.59)
        let u0: CGPoint = chichenLerp(d0, chichenLerp(a2, b2, 0.41), 0.5)
        let u1: CGPoint = chichenLerp(d1, chichenLerp(a2, b2, 0.59), 0.5)
        let door = Art.polygon([d0, d1, u1, u0])
        Art.fill(&context, door, Art.color(0x3E3A5C))
        let jamb = Art.polygon([pt(d1.x - 2.2, d1.y), d1, u1, pt(u1.x - 2.2, u1.y)])
        Art.fill(&context, jamb, Art.color(0x7A7494))
        let lintel = Art.polygon([pt(u0.x - 1.4, u0.y), pt(u1.x + 1.4, u1.y), pt(u1.x + 1.4, u1.y - 1.8), pt(u0.x - 1.4, u0.y - 1.8)])
        Art.fill(&context, lintel, Art.color(0xFFFCEE))

        // The doorway on the shaded side.
        let e0: CGPoint = chichenLerp(b, c, 0.36)
        let e1: CGPoint = chichenLerp(b, c, 0.64)
        let v0: CGPoint = chichenLerp(e0, chichenLerp(b2, c2, 0.36), 0.5)
        let v1: CGPoint = chichenLerp(e1, chichenLerp(b2, c2, 0.64), 0.5)
        let sideDoor = Art.polygon([e0, e1, v1, v0])
        Art.fill(&context, sideDoor, Art.color(0x35304F))
    }

    // MARK: Visitors

    /// One tiny visitor: a shadow, two legs, a shirt lit on the left, a head, sometimes a hat.
    static func chichenVisitor(_ context: inout GraphicsContext, _ x: CGFloat, _ y: CGFloat, height h: CGFloat, shirt: UInt32, hat: Bool) {
        ArtStyle.contactShadow(&context, x + h * 0.25, y + 0.3, h * 0.42, h * 0.08, alpha: 0.3)
        var legs = Path()
        legs.move(to: pt(x - h * 0.1, y))
        legs.addLine(to: pt(x - h * 0.06, y - h * 0.44))
        legs.move(to: pt(x + h * 0.1, y))
        legs.addLine(to: pt(x + h * 0.06, y - h * 0.44))
        Art.stroke(&context, legs, Art.color(0x3A3A5E), width: h * 0.12)
        let torso = Art.rect(x - h * 0.16, y - h * 0.8, h * 0.32, h * 0.42, radius: h * 0.1)
        Art.fill(&context, torso, Art.color(shirt))
        let side = Art.rect(x, y - h * 0.78, h * 0.16, h * 0.38, radius: h * 0.06)
        Art.fill(&context, side, ArtStyle.coolShade.opacity(0.22))
        Art.fill(&context, Art.circle(x, y - h * 0.9, h * 0.11), Art.color(0x8A5A3A))
        if hat {
            var straw = Path()
            straw.addEllipse(in: CGRect(x: x - h * 0.2, y: y - h * 1.0, width: h * 0.4, height: h * 0.09))
            straw.addEllipse(in: CGRect(x: x - h * 0.1, y: y - h * 1.07, width: h * 0.2, height: h * 0.14))
            Art.fill(&context, straw, Art.color(0xF2DE9C))
        }
    }

    /// A few tiny visitors on the lawn, for scale.
    static func chichenVisitors(_ context: inout GraphicsContext) {
        let people: [(CGFloat, CGFloat, CGFloat, UInt32, Bool)] = [
            (118, 300, 10, 0xE8503A, false),
            (126, 301, 9.4, 0xFFF6E0, true),
            (224, 305, 10.4, 0x2E7EB8, true),
            (233, 306, 7, 0xFFC84A, false),
            (322, 301, 9.6, 0xFFF6E0, false),
            (84, 326, 13, 0x2E8A86, true),
            (298, 322, 12.4, 0xD8527A, false),
        ]
        for person in people {
            chichenVisitor(&context, person.0, person.1, height: person.2, shirt: person.3, hat: person.4)
        }
    }

    // MARK: The near plane

    /// Dark leaves hanging in at the top right, and dark bushes at the two bottom corners.
    static func chichenNearPlane(_ context: inout GraphicsContext) {
        cornerSpray(&context, seed: 347, dark: Art.color(0x163A2E), lit: Art.color(0x8CC66A, 0.7))
        let dark: [(Color, CGFloat)] = [
            (Art.color(0x2C5E3E), 0),
            (Art.color(0x143226), 1),
        ]
        let leftBush = canopy(from: -24, to: 84, baseY: 372, height: 28, bump: 22, depth: 60, seed: 353)
        fillVertical(&context, leftBush, dark, from: 344, to: unitHeight)
        model(&context, leftBush, light: 0.14, shade: 0.2)
        let rightBush = canopy(from: 370, to: 456, baseY: 378, height: 26, bump: 20, depth: 56, seed: 373)
        fillVertical(&context, rightBush, dark, from: 352, to: unitHeight)
        model(&context, rightBush, light: 0.1, shade: 0.24)

        // A few big leaves standing up out of the bushes, each with a sliver of light.
        let stems: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
            (10, 366, 26, -1.9), (34, 362, 22, -1.3), (58, 370, 20, -0.9),
            (396, 372, 22, -2.2), (420, 366, 26, -1.7), (444, 372, 20, -1.3),
        ]
        var leaves = Path()
        var glints = Path()
        for stem in stems {
            leaves.addPath(leaf(stem.0, stem.1, length: stem.2, width: stem.2 * 0.3, angle: stem.3))
            glints.addPath(leaf(stem.0 - 1, stem.1 - 0.6, length: stem.2 * 0.8, width: stem.2 * 0.08, angle: stem.3 - 0.1))
        }
        Art.fill(&context, leaves, Art.color(0x1C4630))
        Art.fill(&context, glints, Art.color(0x8CC66A, 0.6))
    }

    // MARK: Finish

    static func chichenFinish(_ context: inout GraphicsContext) {
        bottomFade(&context, 0x1F4A3A, from: 300, alpha: 0.9)
        tooth(&context, seed: 619, light: 0.06, dark: 0.05)
        finish(&context, wash: 0.10, vignette: 0.10)
    }
}
