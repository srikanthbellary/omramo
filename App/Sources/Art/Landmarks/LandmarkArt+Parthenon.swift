import SwiftUI
import OmramoCore

// The Parthenon as it stands today, by day: our own drawing (no photograph, nothing traced).
// The marble temple seen from a corner: eight fluted columns across the lit front, the long
// side running back in shade, a band of triglyphs over the columns, the broken triangle of
// the pediment and no roof. It stands on the pale rock of the Acropolis above its retaining
// wall, with a few fallen column drums; a small olive tree and dry grass are the near plane.
// Card background #1D4466.

extension LandmarkArt {
    /// parthenon: the columned marble temple from its corner, front in the sun and side in
    /// shade, on its rocky hilltop under a deep blue sky.
    static func paintParthenon(_ context: inout GraphicsContext) {
        parthenonSky(&context)
        parthenonFarHills(&context)
        parthenonRock(&context)
        parthenonSide(&context)
        parthenonFrontShade(&context)
        parthenonFrontColumns(&context)
        parthenonEntablature(&context)
        parthenonPediment(&context)
        parthenonSteps(&context)
        // Warm light lying on the lit marble, from the upper left.
        Art.glow(&context, 150, 170, 140, Art.color(0xFFE8B8), alpha: 0.16)
        parthenonDrums(&context)
        parthenonVisitors(&context)
        parthenonNearPlane(&context)
        parthenonFinish(&context)
    }

    // MARK: Geometry

    // The temple is drawn from its near corner, which stands at x 250. `t` runs from 0 at the
    // corner to 1 at the far end of a face: the front runs back to the left, the long side to
    // the right. `y` is a height as measured at the corner; it shrinks toward the eye level
    // (y 276) as the face runs back.

    /// How much smaller things are at `t` along a face than at the corner.
    static func parthenonScale(_ side: Bool, _ t: CGFloat) -> CGFloat {
        let shrink: CGFloat = side ? 0.38 : 0.16
        return 1 - shrink * t
    }

    static func parthenonPoint(_ side: Bool, _ t: CGFloat, _ y: CGFloat) -> CGPoint {
        let reach: CGFloat = side ? 118 : -172
        let s: CGFloat = parthenonScale(side, t)
        let px: CGFloat = 250 + reach * t
        let py: CGFloat = 276 + (y - 276) * s
        return pt(px, py)
    }

    /// A four-cornered piece of a face, from `t0` to `t1` and from height `y0` to `y1`.
    static func parthenonQuad(_ side: Bool, _ t0: CGFloat, _ t1: CGFloat, _ y0: CGFloat, _ y1: CGFloat) -> Path {
        let a: CGPoint = parthenonPoint(side, t0, y0)
        let b: CGPoint = parthenonPoint(side, t1, y0)
        let c: CGPoint = parthenonPoint(side, t1, y1)
        let d: CGPoint = parthenonPoint(side, t0, y1)
        return Art.polygon([a, b, c, d])
    }

    /// Where the columns of the long side stand: they crowd together as the side runs back.
    static func parthenonSideStations(count: Int, offset: CGFloat) -> [CGFloat] {
        var stations: [CGFloat] = []
        for index in 0..<max(0, count) {
            let u: CGFloat = (CGFloat(index) + offset) / CGFloat(max(1, count))
            let t: CGFloat = u * (1.35 - 0.35 * u)
            stations.append(t)
        }
        return stations
    }

    /// A row of Doric columns on one face, standing at each `t` of `ts`: tapering fluted
    /// shafts, lit on their left and shaded on their right, each under a plain capital.
    static func parthenonColonnade(_ context: inout GraphicsContext, side: Bool, ts: [CGFloat], width: CGFloat, marble: UInt32, light: Double, shade: Double) {
        var shafts = Path()
        var lights = Path()
        var shades = Path()
        var caps = Path()
        var flutes = Path()
        let offsets: [CGFloat] = [-0.45, 0, 0.45]
        for t in ts {
            let s: CGFloat = parthenonScale(side, t)
            let foot: CGPoint = parthenonPoint(side, t, 270)
            let neck: CGPoint = parthenonPoint(side, t, 167)
            let head: CGPoint = parthenonPoint(side, t, 160)
            let hb: CGFloat = width * s / 2
            let ht: CGFloat = hb * 0.8
            let footL = pt(foot.x - hb, foot.y)
            let footR = pt(foot.x + hb, foot.y)
            let neckL = pt(neck.x - ht, neck.y)
            let neckR = pt(neck.x + ht, neck.y)
            shafts.addPath(Art.polygon([footL, neckL, neckR, footR]))
            let litFoot = pt(foot.x - hb * 0.4, foot.y)
            let litNeck = pt(neck.x - ht * 0.4, neck.y)
            lights.addPath(Art.polygon([footL, neckL, litNeck, litFoot]))
            let dimFoot = pt(foot.x + hb * 0.3, foot.y)
            let dimNeck = pt(neck.x + ht * 0.3, neck.y)
            shades.addPath(Art.polygon([dimFoot, dimNeck, neckR, footR]))

            // The capital: a spreading cushion under a square slab.
            let wide: CGFloat = ht * 1.5
            let lip: CGFloat = (neck.y + head.y) / 2
            let capL = pt(neck.x - wide, lip)
            let capR = pt(neck.x + wide, lip)
            let slabL = pt(neck.x - wide, head.y)
            let slabR = pt(neck.x + wide, head.y)
            caps.addPath(Art.polygon([neckL, capL, slabL, slabR, capR, neckR]))

            for offset in offsets {
                flutes.move(to: pt(foot.x + hb * offset, foot.y))
                flutes.addLine(to: pt(neck.x + ht * offset, neck.y))
            }
        }
        Art.fill(&context, shafts, Art.color(marble))
        Art.fill(&context, lights, Art.color(0xFFF9E8, light))
        Art.fill(&context, shades, ArtStyle.coolShade.opacity(shade))
        Art.stroke(&context, flutes, Art.color(0x9A8068, 0.3), width: 0.6, cap: .butt)
        Art.fill(&context, caps, Art.color(marble))
        Art.fill(&context, caps, Art.color(0xFFF9E8, light * 0.5))
    }

    // MARK: Sky and the far plane

    static func parthenonSky(_ context: inout GraphicsContext) {
        let sky: [(Color, CGFloat)] = [
            (Art.color(0x1E6CBE), 0),
            (Art.color(0x4A98DC), 0.4),
            (Art.color(0xA8D4EE), 0.7),
            (Art.color(0xE4EEDC), 1),
        ]
        backdrop(&context, sky)
        var clouds = Path()
        clouds.addPath(cloudBand(296, 72, width: 74, height: 14))
        clouds.addPath(cloudBand(96, 98, width: 46, height: 9))
        Art.fill(&context, clouds, Art.color(0xFFFFFF, 0.8))
        var bellies = Path()
        bellies.addPath(cloudBand(304, 73, width: 60, height: 5))
        bellies.addPath(cloudBand(102, 98.6, width: 36, height: 3.4))
        Art.fill(&context, bellies, ArtStyle.coolShade.opacity(0.08))
    }

    /// Far hazy hills and the pale specks of the city below the hill, veiled with the sky.
    static func parthenonFarHills(_ context: inout GraphicsContext) {
        let far = Art.svg("M-24,304 L-24,256 C20,240 60,250 100,244 C150,236 190,252 240,246 C300,238 340,226 380,236 C410,242 436,236 456,240 L456,304 Z")
        Art.fill(&context, far, Art.color(0x7FA2CC))
        let nearer = Art.svg("M-24,304 L-24,274 C40,266 90,276 150,270 C230,264 300,276 360,268 C400,264 430,270 456,266 L456,304 Z")
        Art.fill(&context, nearer, Art.color(0x9CB2C4))
        let town = CGRect(x: -24, y: 276, width: unitWidth + 48, height: 22)
        Art.stipple(&context, in: town, count: 70, seed: 29, color: Art.color(0xFFF6E4), alpha: 0.4, size: 0.5...1.1)
        haze(&context, top: 216, bottom: 304, hex: 0xBFDDF0, alpha: 0.45)
        horizon(&context, y: 296, rise: 40, hex: 0xFFE8C0, alpha: 0.28)
    }

    // MARK: The rock

    /// The pale rock of the Acropolis: its flat top, the retaining wall below the lip and
    /// the rough face under it.
    static func parthenonRock(_ context: inout GraphicsContext) {
        let mass = Art.svg("M-24,428 L-24,330 C0,312 20,296 44,288 C60,282 80,281 100,281 L384,280 C404,282 426,300 456,330 L456,428 Z")
        let top: [(Color, CGFloat)] = [
            (Art.color(0xF4E8CC), 0),
            (Art.color(0xDCCAA8), 1),
        ]
        fillVertical(&context, mass, top, from: 280, to: 302)

        let face = Art.svg("M-24,428 L-24,330 C0,314 22,304 48,300 L150,297 L300,298 L396,296 C416,300 436,314 456,330 L456,428 Z")
        let crag: [(Color, CGFloat)] = [
            (Art.color(0xD2BE9E), 0),
            (Art.color(0x9A8E94), 0.45),
            (Art.color(0x1D4466), 1),
        ]
        fillVertical(&context, face, crag, from: 296, to: unitHeight)
        model(&context, face, light: 0.14, shade: 0.18)
        let cracks = Art.svg("M20,316 C26,330 18,344 24,360 M48,302 C52,318 44,330 50,348 M352,300 C356,316 348,328 354,346 M392,300 C398,318 388,334 396,352 M426,312 C430,326 422,340 428,356")
        Art.stroke(&context, cracks, Art.color(0x6E6A80, 0.3), width: 1.6)

        // The retaining wall: long courses of squared blocks, with one buttress.
        let wall = Art.polygon([pt(66, 299), pt(338, 297.4), pt(338, 340), pt(66, 344)])
        let blocks: [(Color, CGFloat)] = [
            (Art.color(0xEAD8B2), 0),
            (Art.color(0xC4AC8E), 1),
        ]
        fillVertical(&context, wall, blocks, from: 297, to: 344)
        model(&context, wall, light: 0.14, shade: 0.16)
        let buttress = Art.polygon([pt(232, 297.8), pt(250, 297.7), pt(254, 342), pt(228, 342)])
        Art.fill(&context, buttress, Art.color(0xF0DEBA))
        Art.fill(&context, Art.polygon([pt(250, 297.7), pt(256, 298), pt(260, 342), pt(254, 342)]), ArtStyle.coolShade.opacity(0.2))
        var courses = Path()
        let rows: [CGFloat] = [306, 315, 324, 333]
        for row in rows {
            courses.move(to: pt(66, row))
            courses.addLine(to: pt(338, row - 1))
        }
        Art.stroke(&context, courses, Art.color(0x9A8468, 0.3), width: 0.7, cap: .butt)
        Art.stroke(&context, Art.line(66, 299, 338, 297.4), Art.color(0xFFF6DE, 0.8), width: 1.2, cap: .butt)

        // The temple's shade on the rock, falling to the right, and where it stands.
        let cast = Art.polygon([pt(250, 284), pt(368, 281), pt(404, 287), pt(292, 293)])
        Art.fill(&context, cast, ArtStyle.coolShade.opacity(0.16))
        ArtStyle.contactShadow(&context, 232, 285, 164, 5, alpha: 0.2)
    }

    // MARK: The long side (right, in shade)

    static func parthenonSide(_ context: inout GraphicsContext) {
        // What is left of the inner wall, seen between the columns: it is broken down in the
        // middle, where the sky shows through.
        var inner = Path()
        inner.addPath(parthenonQuad(true, 0.03, 0.44, 166, 270))
        inner.addPath(parthenonQuad(true, 0.44, 0.58, 214, 270))
        inner.addPath(parthenonQuad(true, 0.58, 0.74, 238, 270))
        inner.addPath(parthenonQuad(true, 0.74, 1, 166, 270))
        let dim: [(Color, CGFloat)] = [
            (Art.color(0xA898A4), 0),
            (Art.color(0x84789A), 1),
        ]
        fillHorizontal(&context, inner, dim, from: 250, to: 368)

        let stations: [CGFloat] = parthenonSideStations(count: 8, offset: 1)
        parthenonColonnade(&context, side: true, ts: stations, width: 11, marble: 0xCFBDA8, light: 0.16, shade: 0.24)

        // The beam, the band of triglyphs and what is left of the cornice.
        let beam: Path = parthenonQuad(true, 0, 1, 148, 160)
        Art.fill(&context, beam, Art.color(0xC8B6A2))
        let frieze: Path = parthenonQuad(true, 0, 1, 137, 148)
        Art.fill(&context, frieze, Art.color(0xBAA89A))
        var cornice = Path()
        cornice.addPath(parthenonQuad(true, 0, 0.36, 132, 137))
        cornice.addPath(parthenonQuad(true, 0.62, 1, 132, 137))
        Art.fill(&context, cornice, Art.color(0xD6C4AE))
        var glyphs = Path()
        let ticks: [CGFloat] = parthenonSideStations(count: 20, offset: 0.5)
        for t in ticks {
            glyphs.move(to: parthenonPoint(true, t, 139))
            glyphs.addLine(to: parthenonPoint(true, t, 147))
        }
        Art.stroke(&context, glyphs, Art.color(0x7A6A84, 0.45), width: 1.2, cap: .butt)
        Art.fill(&context, parthenonQuad(true, 0, 1, 160, 163.5), ArtStyle.coolShade.opacity(0.2))

        // The whole side turns away from the light, deeper as it runs back.
        var whole = Path()
        whole.addPath(parthenonQuad(true, 0, 1, 132, 284))
        let turn: [(Color, CGFloat)] = [
            (ArtStyle.coolShade.opacity(0.04), 0),
            (ArtStyle.coolShade.opacity(0.16), 1),
        ]
        Art.clipped(&context, to: whole) { g in
            var marks = Path()
            marks.addPath(inner)
            marks.addPath(beam)
            marks.addPath(frieze)
            marks.addPath(cornice)
            fillHorizontal(&g, marks, turn, from: 250, to: 368)
        }
    }

    // MARK: The front (left, in the light)

    /// The shade behind the front columns, and the inner row of columns that shows in it.
    static func parthenonFrontShade(_ context: inout GraphicsContext) {
        let porch: Path = parthenonQuad(false, 0, 1, 160, 270)
        let deep: [(Color, CGFloat)] = [
            (Art.color(0x76688E), 0),
            (Art.color(0xA4929A), 0.7),
            (Art.color(0xBCA89C), 1),
        ]
        fillVertical(&context, porch, deep, from: 164, to: 270)
        var innerRow = Path()
        let gaps: [CGFloat] = [0.234, 0.367, 0.5, 0.633, 0.766]
        for t in gaps {
            innerRow.addPath(parthenonQuad(false, t - 0.022, t + 0.022, 174, 270))
        }
        Art.fill(&context, innerRow, Art.color(0xD8C6B0, 0.55))
    }

    static func parthenonFrontColumns(_ context: inout GraphicsContext) {
        var stations: [CGFloat] = []
        for index in 0..<8 {
            let t: CGFloat = 0.035 + CGFloat(index) * 0.1329
            stations.append(t)
        }
        parthenonColonnade(&context, side: false, ts: stations, width: 13, marble: 0xFBEBCB, light: 0.6, shade: 0.16)
        // The beam's shade across the tops of the columns.
        Art.fill(&context, parthenonQuad(false, 0, 1, 160, 163), ArtStyle.coolShade.opacity(0.12))
    }

    /// Over the front columns: the plain beam, the band of triglyphs and the cornice.
    static func parthenonEntablature(_ context: inout GraphicsContext) {
        let honey: [(Color, CGFloat)] = [
            (Art.color(0xFFF4DA), 0),
            (Art.color(0xF4DDB4), 1),
        ]
        let beam: Path = parthenonQuad(false, -0.01, 1.01, 148, 160)
        fillHorizontal(&context, beam, honey, from: 78, to: 250)
        let frieze: Path = parthenonQuad(false, -0.01, 1.01, 137, 148)
        Art.fill(&context, frieze, Art.color(0xEFD8B0))
        var glyphs = Path()
        for index in 0..<15 {
            let t: CGFloat = 0.035 + CGFloat(index) * 0.06645
            glyphs.addPath(parthenonQuad(false, t - 0.013, t + 0.013, 138.6, 147.4))
        }
        Art.fill(&context, glyphs, Art.color(0xB4946E, 0.75))
        let cornice: Path = parthenonQuad(false, -0.02, 1.02, 132, 137)
        fillHorizontal(&context, cornice, honey, from: 78, to: 250)
        Art.fill(&context, parthenonQuad(false, -0.01, 1.01, 137, 138.6), ArtStyle.coolShade.opacity(0.22))
        Art.fill(&context, parthenonQuad(false, -0.01, 1.01, 147.4, 148.6), ArtStyle.coolShade.opacity(0.12))
        var edge = Path()
        edge.move(to: parthenonPoint(false, -0.02, 132.4))
        edge.addLine(to: parthenonPoint(false, 1.02, 132.4))
        Art.stroke(&context, edge, Art.color(0xFFFCF0, 0.9), width: 1, cap: .butt)
    }

    /// A broken piece of the pediment from (t, height) pairs along the front.
    static func parthenonPiece(_ corners: [(CGFloat, CGFloat)]) -> Path {
        var points: [CGPoint] = []
        for corner in corners {
            points.append(parthenonPoint(false, corner.0, corner.1))
        }
        return Art.polygon(points)
    }

    /// The damaged pediment: the two ends of the triangle still stand, the top and part of
    /// the middle are gone, and the sky shows where the roof was.
    static func parthenonPediment(_ context: inout GraphicsContext) {
        let leftCorners: [(CGFloat, CGFloat)] = [
            (1, 132), (0.56, 105.6), (0.54, 112), (0.5, 115), (0.47, 124), (0.45, 132),
        ]
        let rightCorners: [(CGFloat, CGFloat)] = [
            (0, 132), (0.22, 118.8), (0.3, 114), (0.32, 121), (0.36, 124), (0.37, 132),
        ]
        var pieces = Path()
        pieces.addPath(parthenonPiece(leftCorners))
        pieces.addPath(parthenonPiece(rightCorners))
        let honey: [(Color, CGFloat)] = [
            (Art.color(0xFFF2D6), 0),
            (Art.color(0xEED6AC), 1),
        ]
        fillHorizontal(&context, pieces, honey, from: 78, to: 250)
        model(&context, pieces, light: 0.18, shade: 0.12)

        // The sloping cornices: a lit upper edge, and the shade they throw on the wall under them.
        var rakes = Path()
        rakes.move(to: parthenonPoint(false, 1, 132))
        rakes.addLine(to: parthenonPoint(false, 0.56, 105.6))
        rakes.move(to: parthenonPoint(false, 0, 132))
        rakes.addLine(to: parthenonPoint(false, 0.3, 114))
        Art.clipped(&context, to: pieces) { g in
            var lower = g
            lower.translateBy(x: 0, y: 4.4)
            Art.stroke(&lower, rakes, ArtStyle.coolShade.opacity(0.2), width: 2.4, cap: .butt)
            Art.stroke(&g, rakes, Art.color(0xFFFCF0, 0.95), width: 3.2, cap: .butt)
        }
        // A few blocks still lie on the cornice where the middle has fallen.
        var blocks = Path()
        blocks.addPath(parthenonQuad(false, 0.4, 0.425, 127, 132))
        blocks.addPath(parthenonQuad(false, 0.385, 0.4, 129.4, 132))
        Art.fill(&context, blocks, Art.color(0xF2DEB8))
    }

    /// The three steps the temple stands on: lit along the front, in shade along the side.
    static func parthenonSteps(_ context: inout GraphicsContext) {
        let treads: [(CGFloat, CGFloat, CGFloat)] = [(270, 275, 0.01), (275, 279.5, 0.022), (279.5, 284, 0.034)]
        var front = Path()
        var flank = Path()
        var edges = Path()
        var shades = Path()
        for tread in treads {
            let far: CGFloat = 1 + tread.2
            front.addPath(parthenonQuad(false, 0, far, tread.0, tread.1))
            flank.addPath(parthenonQuad(true, 0, far, tread.0, tread.1))
            edges.move(to: parthenonPoint(false, far, tread.0 + 0.4))
            edges.addLine(to: parthenonPoint(false, 0, tread.0 + 0.4))
            edges.addLine(to: parthenonPoint(true, far, tread.0 + 0.4))
            shades.move(to: parthenonPoint(false, far, tread.1 - 0.4))
            shades.addLine(to: parthenonPoint(false, 0, tread.1 - 0.4))
            shades.addLine(to: parthenonPoint(true, far, tread.1 - 0.4))
        }
        Art.fill(&context, front, Art.color(0xF8E6C4))
        Art.fill(&context, flank, Art.color(0xC2B0A2))
        Art.fill(&context, flank, ArtStyle.coolShade.opacity(0.1))
        Art.stroke(&context, shades, ArtStyle.coolShade.opacity(0.2), width: 0.7, cap: .butt)
        Art.stroke(&context, edges, Art.color(0xFFFCF0, 0.85), width: 0.9, cap: .butt)
    }

    // MARK: On the rock

    /// A few fallen column drums lying on the rock in front of the temple.
    static func parthenonDrums(_ context: inout GraphicsContext) {
        let drums: [(CGFloat, CGFloat, CGFloat)] = [(98, 294, 1), (116, 296, 0.8), (334, 292, 0.9), (204, 296, 0.7)]
        for drum in drums {
            let x: CGFloat = drum.0
            let y: CGFloat = drum.1
            let w: CGFloat = 13 * drum.2
            let h: CGFloat = 7.4 * drum.2
            ArtStyle.contactShadow(&context, x + w * 0.2, y + 0.4, w * 0.8, 1.6, alpha: 0.26)
            var body = Art.rect(x - w / 2, y - h, w, h, radius: 1.4)
            body.addEllipse(in: CGRect(x: x + w / 2 - h * 0.3, y: y - h, width: h * 0.6, height: h))
            Art.fill(&context, body, Art.color(0xE6D2AC))
            model(&context, body, light: 0.2, shade: 0.24)
            // The round end that faces the light, and two of the flutes along the drum.
            Art.fill(&context, Art.ellipse(x - w / 2, y - h / 2, h * 0.3, h / 2), Art.color(0xFFF6DE))
            var flutes = Art.line(x - w * 0.42, y - h * 0.68, x + w * 0.46, y - h * 0.68)
            flutes.move(to: pt(x - w * 0.42, y - h * 0.36))
            flutes.addLine(to: pt(x + w * 0.46, y - h * 0.36))
            Art.stroke(&context, flutes, Art.color(0x9A8068, 0.35), width: 0.6, cap: .butt)
        }
    }

    /// Two small visitors on the rock by the front steps, for scale.
    static func parthenonVisitors(_ context: inout GraphicsContext) {
        let folk: [(CGFloat, CGFloat, CGFloat, UInt32)] = [(140, 294, 1.7, 0xB8503C), (151, 295, 1.5, 0x2E5E8A)]
        for person in folk {
            let x: CGFloat = person.0
            let y: CGFloat = person.1
            let s: CGFloat = person.2
            let shoulder: CGFloat = y - 5.6 * s
            ArtStyle.contactShadow(&context, x + 2 * s, y + 0.3, 4 * s, 1.1 * s, alpha: 0.3)
            let body = Art.polygon([pt(x - 1.3 * s, shoulder), pt(x + 1.3 * s, shoulder), pt(x + 1.7 * s, y), pt(x - 1.7 * s, y)])
            Art.fill(&context, body, Art.color(person.3))
            Art.fill(&context, Art.rect(x - 1.3 * s, shoulder, 0.9 * s, 5.6 * s), Art.color(0xFFE6B8, 0.4))
            Art.fill(&context, Art.circle(x, y - 6.9 * s, 1.4 * s), Art.color(0x6A4638))
        }
    }

    // MARK: The near plane

    /// A dark shoulder of rock in the bottom-right corner, with dry grass and a small olive
    /// tree: below and beside the temple, never over it.
    static func parthenonNearPlane(_ context: inout GraphicsContext) {
        let rock = Art.svg("M286,428 C300,396 330,376 366,370 C398,364 430,352 456,340 L456,428 Z")
        let dark: [(Color, CGFloat)] = [
            (Art.color(0x56607A), 0),
            (Art.color(0x1F3E5C), 1),
        ]
        fillVertical(&context, rock, dark, from: 340, to: unitHeight)
        model(&context, rock, light: 0.14, shade: 0.2)

        var random = ArtRandom(53)
        var blades = Path()
        for _ in 0..<30 {
            let f: CGFloat = random.next(in: 0...1)
            let x: CGFloat = 300 + 150 * f
            let y: CGFloat = 392 - 46 * f
            let lean: CGFloat = random.next(in: -4...5)
            let tall: CGFloat = random.next(in: 7...15)
            blades.move(to: pt(x, y))
            blades.addQuadCurve(to: pt(x + lean, y - tall), control: pt(x + lean * 0.2, y - tall * 0.6))
        }
        Art.stroke(&context, blades, Art.color(0xDCC680, 0.85), width: 1)
        parthenonOlive(&context)
    }

    /// The olive tree: a short twisted trunk and a crown of grey-green clumps.
    static func parthenonOlive(_ context: inout GraphicsContext) {
        let trunk = Art.svg("M385,370 C381,356 389,346 385,334")
        Art.stroke(&context, trunk, Art.color(0x4A3C44), width: 6)
        let boughs = Art.svg("M385,336 C382,326 376,322 371,312 M386,338 C391,330 398,326 403,314 M385,334 C386,324 387,318 388,306")
        Art.stroke(&context, boughs, Art.color(0x4A3C44), width: 2.6)
        var lit = context
        lit.translateBy(x: -1.8, y: 0)
        Art.stroke(&lit, trunk, Art.color(0xB09880, 0.6), width: 1.2)

        let clumps: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
            (372, 308, 20, 13), (392, 300, 22, 14), (408, 312, 18, 12),
            (386, 316, 24, 11), (358, 318, 13, 9), (420, 322, 12, 8),
        ]
        var crown = Path()
        for clump in clumps {
            crown.addPath(Art.ellipse(clump.0, clump.1, clump.2, clump.3))
        }
        Art.fill(&context, crown, Art.color(0x5E7658))
        model(&context, crown, light: 0.24, shade: 0.26)
        var sunny = Path()
        sunny.addPath(Art.ellipse(366, 302, 11, 6))
        sunny.addPath(Art.ellipse(386, 293, 13, 6))
        sunny.addPath(Art.ellipse(404, 305, 9, 5))
        Art.fill(&context, sunny, Art.color(0xA8BC98, 0.6))

        // Small narrow leaves, pale above and dark below.
        var random = ArtRandom(67)
        var pale = Path()
        var deep = Path()
        for index in 0..<44 {
            let pick: CGFloat = random.next(in: 0...5.99)
            let clump = clumps[min(5, max(0, Int(pick)))]
            let x: CGFloat = clump.0 + clump.2 * random.next(in: -0.8...0.8)
            let y: CGFloat = clump.1 + clump.3 * random.next(in: -0.8...0.8)
            let angle: CGFloat = random.next(in: 2.2...4.2)
            let blade: Path = leaf(x, y, length: 5.5, width: 1.3, angle: angle)
            if index % 3 == 0 {
                deep.addPath(blade)
            } else {
                pale.addPath(blade)
            }
        }
        Art.fill(&context, deep, Art.color(0x3C5448, 0.7))
        Art.fill(&context, pale, Art.color(0xC6D4B2, 0.6))
    }

    // MARK: Finish

    static func parthenonFinish(_ context: inout GraphicsContext) {
        bottomFade(&context, 0x1D4466, from: 300, alpha: 0.9)
        tooth(&context, seed: 431, light: 0.05, dark: 0.04)
        finish(&context, wash: 0.10, vignette: 0.10)
    }
}
