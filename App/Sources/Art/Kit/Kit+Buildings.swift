import SwiftUI
import OmramoCore

// The shared illustration kit: buildings (round 5).
//
// Region-neutral building blocks. A story composes them into region-true architecture: a
// Japanese thatched farmhouse (`house` with `.thatch`), a Russian log izba (`.plank` with
// `timber`), a German half-timbered house (`.tile` with `timber`), an Egyptian mud-brick house
// (`.flat`), an Efik compound (`.cone` / `.thatch`, `longWall`, `gateway`), a Chinese farmhouse
// (`.sweep`). Everything stands on a `baseY` and is centred on a `cx`, in the units of the
// picture being drawn; the one light comes from the upper left. Helpers start with `built`.

// MARK: - Tones, walls, openings

extension Kit {
    enum RoofStyle: Sendable { case thatch, tile, shingle, flat, sweep, snow, cone, plank }

    /// A hex colour with each RGB component scaled by `k` (clamped to 0…255).
    static func builtHex(_ hex: UInt32, _ k: CGFloat) -> UInt32 {
        let scale: CGFloat = max(0, k)
        let r: CGFloat = min(255, CGFloat((hex >> 16) & 0xFF) * scale)
        let g: CGFloat = min(255, CGFloat((hex >> 8) & 0xFF) * scale)
        let b: CGFloat = min(255, CGFloat(hex & 0xFF) * scale)
        let r8: UInt32 = UInt32(r.rounded())
        let g8: UInt32 = UInt32(g.rounded())
        let b8: UInt32 = UInt32(b.rounded())
        return (r8 << 16) | (g8 << 8) | b8
    }

    /// Lighter (k > 1) or darker (k < 1) tone of a hex colour.
    static func builtTone(_ hex: UInt32, _ k: CGFloat) -> Color {
        Art.color(builtHex(hex, k))
    }

    /// Short seeded course marks (stones, bricks) scattered over `rect`, as one path.
    static func builtCourses(_ rect: CGRect, seed: UInt32) -> Path {
        var random = ArtRandom(seed)
        var marks = Path()
        let wanted: Int = Int(rect.width * rect.height / 700)
        let count: Int = min(28, max(6, wanted))
        for _ in 0..<count {
            let x: CGFloat = rect.minX + rect.width * rnd(&random)
            let y: CGFloat = rect.minY + rect.height * rnd(&random)
            let length: CGFloat = 6 + rnd(&random) * 9
            marks.move(to: CGPoint(x: x, y: y))
            marks.addLine(to: CGPoint(x: x + length, y: y))
            marks.addLine(to: CGPoint(x: x + length, y: y + 3))
        }
        return marks
    }

    /// Just a wall block with the light, a base course and tooth.
    static func wall(_ context: inout GraphicsContext, rect: CGRect, color: UInt32, radius: CGFloat = 0) {
        guard rect.width > 0, rect.height > 0 else { return }
        let shape = Art.rect(rect.minX, rect.minY, rect.width, rect.height, radius: radius)
        Kit.solid(&context, shape, Art.color(color), light: 0.22, shade: 0.16)
        let course: CGFloat = min(rect.height * 0.14, 14)
        let side: Kit.Stops = [(ArtStyle.coolShade.opacity(0), 0), (ArtStyle.coolShade.opacity(0.16), 1)]
        Art.clipped(&context, to: shape) { g in
            Art.fill(&g, Art.rect(rect.minX, rect.maxY - course, rect.width, course), builtTone(color, 0.78))
            let from = CGPoint(x: rect.minX + rect.width * 0.55, y: rect.midY)
            Art.fillLinear(&g, shape, side, from: from, to: CGPoint(x: rect.maxX, y: rect.midY))
            ArtStyle.tooth(&g, in: rect, seed: 61, alpha: 0.06)
        }
    }

    /// The outline of an opening: a slightly rounded rectangle, or one with a round-arched top.
    static func builtOpeningShape(_ rect: CGRect, arched: Bool) -> Path {
        if !arched {
            let soft: CGFloat = min(rect.width, rect.height) * 0.08
            return Art.rect(rect.minX, rect.minY, rect.width, rect.height, radius: soft)
        }
        let r: CGFloat = min(rect.width / 2, rect.height)
        let spring: CGFloat = rect.minY + r
        let lift: CGFloat = r * 4 / 3
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: spring))
        path.addCurve(
            to: CGPoint(x: rect.maxX, y: spring),
            control1: CGPoint(x: rect.minX, y: spring - lift),
            control2: CGPoint(x: rect.maxX, y: spring - lift)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }

    /// A door or window opening: a dark recess with a frame in `color`; `arched` rounds its
    /// top; `glow` > 0 fills it with warm lamp light and adds a soft halo. An opening that is
    /// about as wide as it is high is read as a window and gets glazing bars.
    static func opening(_ context: inout GraphicsContext, rect: CGRect, arched: Bool, color: UInt32, glow: Double = 0) {
        guard rect.width > 0, rect.height > 0 else { return }
        let least: CGFloat = min(rect.width, rect.height)
        // Never inset a tiny opening away to nothing (an empty rect has no finite origin).
        let t: CGFloat = min(least * 0.3, max(1.5, least * 0.12))
        let inner: CGRect = rect.insetBy(dx: t, dy: t)
        let frame = builtOpeningShape(rect, arched: arched)
        let hole = builtOpeningShape(inner, arched: arched)
        if glow > 0 {
            let reach: CGFloat = max(rect.width, rect.height) * 1.3
            Art.glow(&context, rect.midX, rect.midY, reach, Art.color(0xFFC96B), alpha: 0.4 * glow)
        }
        Kit.solid(&context, frame, Art.color(color), light: 0.24, shade: 0.18)
        Art.fill(&context, hole, Art.color(0x2A2140, 0.92))
        if glow > 0 {
            let lamp: Kit.Stops = [(Art.color(0xFFC96B, glow), 0), (Art.color(0xFF9E4D, glow), 1)]
            let from = CGPoint(x: inner.midX, y: inner.minY)
            Art.fillLinear(&context, hole, lamp, from: from, to: CGPoint(x: inner.midX, y: inner.maxY))
        }
        Art.clipped(&context, to: hole) { g in
            // The recess: the lintel and the left jamb throw a little shade into it.
            Art.fill(&g, Art.rect(inner.minX, inner.minY, inner.width, t * 0.9), ArtStyle.coolShade.opacity(0.25))
            Art.fill(&g, Art.rect(inner.minX, inner.minY, t * 0.7, inner.height), ArtStyle.coolShade.opacity(0.18))
        }
        if rect.height <= rect.width * 1.4 {
            var bars = Path()
            bars.move(to: CGPoint(x: inner.midX, y: inner.minY))
            bars.addLine(to: CGPoint(x: inner.midX, y: inner.maxY))
            bars.move(to: CGPoint(x: inner.minX, y: inner.midY))
            bars.addLine(to: CGPoint(x: inner.maxX, y: inner.midY))
            Art.stroke(&context, bars, Art.color(color), width: max(1.2, t * 0.6), cap: .butt)
        }
    }
}

// MARK: - Roofs

extension Kit {
    /// Just a roof whose eaves line is at eaveY, `width` wide (overhang included), `height` tall.
    static func roof(_ context: inout GraphicsContext, cx: CGFloat, eaveY: CGFloat, width: CGFloat, height: CGFloat, color: UInt32, style: RoofStyle) {
        guard width > 0, height > 0 else { return }
        switch style {
        case .thatch:
            builtThatchRoof(&context, cx: cx, eaveY: eaveY, width: width, height: height, color: color)
        case .tile:
            builtRowRoof(&context, cx: cx, eaveY: eaveY, width: width, height: height, color: color, shingle: false)
        case .shingle:
            builtRowRoof(&context, cx: cx, eaveY: eaveY, width: width, height: height, color: color, shingle: true)
        case .flat:
            builtFlatRoof(&context, cx: cx, eaveY: eaveY, width: width, height: height, wall: color, line: builtHex(color, 0.7))
        case .sweep:
            builtSweepRoof(&context, cx: cx, eaveY: eaveY, width: width, height: height, color: color)
        case .snow:
            builtSnowRoof(&context, cx: cx, eaveY: eaveY, width: width, height: height, color: color)
        case .cone:
            builtConeRoof(&context, cx: cx, eaveY: eaveY, width: width, height: height, color: color)
        case .plank:
            builtPlankRoof(&context, cx: cx, eaveY: eaveY, width: width, height: height, color: color)
        }
    }

    /// A roof slope seen from the front: eaves `width` wide at eaveY, a ridge `ridge` (0…1) of
    /// that width at the top, sides bowing out (`bow` > 0) or in (`bow` < 0), and a rounded
    /// eave `lip` units thick hanging under the eaves line.
    static func builtRoofShape(cx: CGFloat, eaveY: CGFloat, width: CGFloat, height: CGFloat, ridge: CGFloat, bow: CGFloat, lip: CGFloat) -> Path {
        let half: CGFloat = width / 2
        let top: CGFloat = eaveY - height
        let ridgeHalf: CGFloat = half * ridge
        let midX: CGFloat = (half + ridgeHalf) / 2 + bow * width
        let midY: CGFloat = eaveY - height / 2 - bow * height
        var path = Path()
        path.move(to: CGPoint(x: cx - half, y: eaveY))
        path.addQuadCurve(to: CGPoint(x: cx - ridgeHalf, y: top), control: CGPoint(x: cx - midX, y: midY))
        path.addLine(to: CGPoint(x: cx + ridgeHalf, y: top))
        path.addQuadCurve(to: CGPoint(x: cx + half, y: eaveY), control: CGPoint(x: cx + midX, y: midY))
        if lip > 0 {
            path.addQuadCurve(to: CGPoint(x: cx + half - lip, y: eaveY + lip), control: CGPoint(x: cx + half, y: eaveY + lip))
            path.addLine(to: CGPoint(x: cx - half + lip, y: eaveY + lip))
            path.addQuadCurve(to: CGPoint(x: cx - half, y: eaveY), control: CGPoint(x: cx - half, y: eaveY + lip))
        }
        path.closeSubpath()
        return path
    }

    /// Straw strokes fanning from a top span down to a bottom span, as one path.
    static func builtStraw(cx: CGFloat, topY: CGFloat, topHalf: CGFloat, bottomY: CGFloat, bottomHalf: CGFloat, count: Int, seed: UInt32) -> Path {
        var random = ArtRandom(seed)
        var path = Path()
        let n: Int = max(2, count)
        for index in 0..<n {
            let t: CGFloat = (CGFloat(index) + 0.5) / CGFloat(n)
            let f: CGFloat = t * 2 - 1
            let a: CGFloat = 0.12 + rnd(&random) * 0.2
            let b: CGFloat = 0.7 + rnd(&random) * 0.26
            let xTop: CGFloat = cx + f * topHalf
            let xBottom: CGFloat = cx + f * bottomHalf
            path.move(to: CGPoint(x: Kit.mix(xTop, xBottom, a), y: Kit.mix(topY, bottomY, a)))
            path.addLine(to: CGPoint(x: Kit.mix(xTop, xBottom, b), y: Kit.mix(topY, bottomY, b)))
        }
        return path
    }

    static func builtThatchRoof(_ context: inout GraphicsContext, cx: CGFloat, eaveY: CGFloat, width: CGFloat, height: CGFloat, color: UInt32) {
        let half: CGFloat = width / 2
        let top: CGFloat = eaveY - height
        let lip: CGFloat = min(height * 0.16, 10)
        let shape = builtRoofShape(cx: cx, eaveY: eaveY, width: width, height: height, ridge: 0.4, bow: 0.06, lip: lip)
        Kit.solid(&context, shape, Art.color(color), light: 0.3, shade: 0.24, rim: 2)
        let dark = builtStraw(cx: cx, topY: top, topHalf: half * 0.4, bottomY: eaveY + lip, bottomHalf: half * 0.96, count: 12, seed: 17)
        let pale = builtStraw(cx: cx, topY: top, topHalf: half * 0.36, bottomY: eaveY + lip, bottomHalf: half * 0.9, count: 6, seed: 29)
        Art.clipped(&context, to: shape) { g in
            // The trimmed eave: a darker band where the straw is cut.
            Art.fill(&g, Art.rect(cx - half, eaveY, width, lip + 1), builtTone(color, 0.74))
            Art.stroke(&g, dark, builtTone(color, 0.7).opacity(0.7), width: ArtStyle.detailLine)
            Art.stroke(&g, pale, builtTone(color, 1.25).opacity(0.55), width: 1.2)
        }
        let capW: CGFloat = width * 0.46
        let capH: CGFloat = max(3, height * 0.16)
        let cap = Art.rect(cx - capW / 2, top - capH * 0.35, capW, capH, radius: capH / 2)
        Kit.solid(&context, cap, builtTone(color, 0.84), light: 0.3, shade: 0.2)
    }

    /// Tiles (rows of scallops) or wooden shingles (rows of staggered boards).
    static func builtRowRoof(_ context: inout GraphicsContext, cx: CGFloat, eaveY: CGFloat, width: CGFloat, height: CGFloat, color: UInt32, shingle: Bool) {
        let half: CGFloat = width / 2
        let top: CGFloat = eaveY - height
        let shape = builtRoofShape(cx: cx, eaveY: eaveY, width: width, height: height, ridge: 0.5, bow: 0, lip: 0)
        Kit.solid(&context, shape, Art.color(color), light: 0.28, shade: 0.24, rim: 2)
        let rows: Int = min(8, max(3, Int(height / 9)))
        let rowH: CGFloat = height / CGFloat(rows)
        let tile: CGFloat = max(5, rowH * (shingle ? 1.5 : 1.1))
        var marks = Path()
        for row in 0..<rows {
            let y: CGFloat = top + rowH * CGFloat(row + 1)
            let offset: CGFloat = row % 2 == 0 ? 0 : tile / 2
            var x: CGFloat = cx - half - offset
            if shingle {
                marks.move(to: CGPoint(x: cx - half, y: y))
                marks.addLine(to: CGPoint(x: cx + half, y: y))
            }
            while x < cx + half {
                if shingle {
                    marks.move(to: CGPoint(x: x, y: y - rowH))
                    marks.addLine(to: CGPoint(x: x, y: y))
                } else {
                    marks.move(to: CGPoint(x: x, y: y - rowH * 0.45))
                    marks.addQuadCurve(to: CGPoint(x: x + tile, y: y - rowH * 0.45), control: CGPoint(x: x + tile / 2, y: y + rowH * 0.45))
                }
                x += tile
            }
        }
        Art.clipped(&context, to: shape) { g in
            Art.stroke(&g, marks, builtTone(color, 0.7).opacity(0.75), width: 1.3)
            Art.fill(&g, Art.rect(cx - half, eaveY - 3, width, 3), builtTone(color, 0.7))
        }
        let ridge = Art.rect(cx - half * 0.54, top - 2.5, half * 1.08, 5, radius: 2.5)
        Kit.solid(&context, ridge, builtTone(color, 0.8), light: 0.3, shade: 0.2)
    }

    /// A flat roof: a low parapet in the wall's colour, a coping line in `line`, and the round
    /// ends of the roof beams showing under it.
    static func builtFlatRoof(_ context: inout GraphicsContext, cx: CGFloat, eaveY: CGFloat, width: CGFloat, height: CGFloat, wall: UInt32, line: UInt32) {
        let half: CGFloat = width / 2
        let block = Art.rect(cx - half, eaveY - height, width, height + 1, radius: 2)
        Kit.solid(&context, block, builtTone(wall, 1.04), light: 0.24, shade: 0.2)
        let lineH: CGFloat = max(2.5, height * 0.22)
        let coping = Art.rect(cx - half - 2, eaveY - height - lineH * 0.5, width + 4, lineH, radius: lineH / 2)
        Kit.solid(&context, coping, Art.color(line), light: 0.3, shade: 0.2)
        var beams = Path()
        let count: Int = min(12, max(3, Int(width / 22)))
        let r: CGFloat = max(1.4, min(3, height * 0.14))
        for index in 0..<count {
            let t: CGFloat = (CGFloat(index) + 0.5) / CGFloat(count)
            let bx: CGFloat = cx - half + width * t
            beams.addEllipse(in: CGRect(x: bx - r, y: eaveY + r * 0.6, width: r * 2, height: r * 2))
        }
        Art.fill(&context, beams, builtTone(wall, 0.6))
        Art.fill(&context, Art.rect(cx - half, eaveY - 1, width, 2), builtTone(wall, 0.8))
    }
}

// MARK: - Roofs with a shape of their own

extension Kit {
    /// An East Asian roof: concave slopes, eaves curving up to a tip at both ends, tile ribs
    /// running down the slope and a ridge beam with raised ends.
    static func builtSweepRoof(_ context: inout GraphicsContext, cx: CGFloat, eaveY: CGFloat, width: CGFloat, height: CGFloat, color: UInt32) {
        let half: CGFloat = width / 2
        let top: CGFloat = eaveY - height
        let tipY: CGFloat = eaveY - height * 0.24
        let ridgeHalf: CGFloat = half * 0.5
        let pullY: CGFloat = eaveY - height * 0.34
        var edge = Path()
        edge.move(to: CGPoint(x: cx + half, y: tipY))
        edge.addQuadCurve(to: CGPoint(x: cx + half * 0.72, y: eaveY), control: CGPoint(x: cx + half * 0.86, y: eaveY))
        edge.addLine(to: CGPoint(x: cx - half * 0.72, y: eaveY))
        edge.addQuadCurve(to: CGPoint(x: cx - half, y: tipY), control: CGPoint(x: cx - half * 0.86, y: eaveY))
        var shape = Path()
        shape.move(to: CGPoint(x: cx - half, y: tipY))
        shape.addQuadCurve(to: CGPoint(x: cx - ridgeHalf, y: top), control: CGPoint(x: cx - half * 0.62, y: pullY))
        shape.addLine(to: CGPoint(x: cx + ridgeHalf, y: top))
        shape.addQuadCurve(to: CGPoint(x: cx + half, y: tipY), control: CGPoint(x: cx + half * 0.62, y: pullY))
        shape.addQuadCurve(to: CGPoint(x: cx + half * 0.72, y: eaveY), control: CGPoint(x: cx + half * 0.86, y: eaveY))
        shape.addLine(to: CGPoint(x: cx - half * 0.72, y: eaveY))
        shape.addQuadCurve(to: CGPoint(x: cx - half, y: tipY), control: CGPoint(x: cx - half * 0.86, y: eaveY))
        shape.closeSubpath()
        Kit.solid(&context, shape, Art.color(color), light: 0.28, shade: 0.24, rim: 2)
        var ribs = Path()
        let n: Int = min(16, max(6, Int(width / 14)))
        for index in 0..<n {
            let t: CGFloat = (CGFloat(index) + 0.5) / CGFloat(n)
            let f: CGFloat = t * 2 - 1
            ribs.move(to: CGPoint(x: cx + f * ridgeHalf, y: top))
            ribs.addQuadCurve(to: CGPoint(x: cx + f * half * 0.94, y: eaveY), control: CGPoint(x: cx + f * half * 0.64, y: pullY))
        }
        Art.clipped(&context, to: shape) { g in
            Art.stroke(&g, ribs, builtTone(color, 0.72).opacity(0.7), width: 1.3)
            Art.stroke(&g, edge, builtTone(color, 0.62), width: 5)
        }
        let thick: CGFloat = max(4, height * 0.14)
        var beam = Art.rect(cx - ridgeHalf * 1.1, top - thick * 0.6, ridgeHalf * 2.2, thick, radius: thick / 2)
        let knob: CGFloat = thick * 1.1
        beam.addEllipse(in: CGRect(x: cx - ridgeHalf * 1.1 - knob * 0.4, y: top - thick * 1.2, width: knob, height: knob))
        beam.addEllipse(in: CGRect(x: cx + ridgeHalf * 1.1 - knob * 0.6, y: top - thick * 1.2, width: knob, height: knob))
        Kit.solid(&context, beam, builtTone(color, 0.74), light: 0.3, shade: 0.2)
    }

    /// A gable roof under a thick rounded cap of snow; the roof's own colour shows at the eaves.
    static func builtSnowRoof(_ context: inout GraphicsContext, cx: CGFloat, eaveY: CGFloat, width: CGFloat, height: CGFloat, color: UInt32) {
        let half: CGFloat = width / 2
        let top: CGFloat = eaveY - height
        let shape = builtRoofShape(cx: cx, eaveY: eaveY, width: width, height: height, ridge: 0.36, bow: 0.02, lip: 0)
        Kit.solid(&context, shape, Art.color(color), light: 0.24, shade: 0.24)
        Art.fill(&context, Art.rect(cx - half, eaveY - 2.5, width, 2.5), builtTone(color, 0.7))
        let puff: CGFloat = height * 0.2
        let edgeY: CGFloat = eaveY - height * 0.2
        let shoulderY: CGFloat = top - puff * 0.6
        var cap = Path()
        cap.move(to: CGPoint(x: cx - half - 3, y: edgeY))
        cap.addQuadCurve(to: CGPoint(x: cx - half * 0.36, y: shoulderY), control: CGPoint(x: cx - half * 0.78, y: top + height * 0.1))
        cap.addQuadCurve(to: CGPoint(x: cx + half * 0.36, y: shoulderY), control: CGPoint(x: cx, y: top - puff * 1.5))
        cap.addQuadCurve(to: CGPoint(x: cx + half + 3, y: edgeY), control: CGPoint(x: cx + half * 0.78, y: top + height * 0.1))
        // The lower edge: soft lobes of snow hanging toward the eaves.
        let lobes: Int = 5
        let run: CGFloat = (width + 6) / CGFloat(lobes)
        for index in 0..<lobes {
            let x: CGFloat = cx + half + 3 - run * CGFloat(index)
            let drop: CGFloat = index % 2 == 0 ? height * 0.16 : height * 0.08
            cap.addQuadCurve(to: CGPoint(x: x - run, y: edgeY), control: CGPoint(x: x - run / 2, y: edgeY + drop * 2))
        }
        cap.closeSubpath()
        Kit.solid(&context, cap, Art.color(0xFAF9FF), light: 0.12, shade: 0.16)
        let lilac: Kit.Stops = [(Art.color(0xB9A8E0, 0), 0), (Art.color(0xB9A8E0, 0.4), 1)]
        Art.clipped(&context, to: cap) { g in
            let from = CGPoint(x: cx, y: eaveY - height * 0.5)
            Art.fillLinear(&g, cap, lilac, from: from, to: CGPoint(x: cx + half * 0.3, y: eaveY))
        }
    }

    /// A round conical thatch with a sagging eave and a top knot.
    static func builtConeRoof(_ context: inout GraphicsContext, cx: CGFloat, eaveY: CGFloat, width: CGFloat, height: CGFloat, color: UInt32) {
        let half: CGFloat = width / 2
        let top: CGFloat = eaveY - height
        let sag: CGFloat = min(height * 0.16, 10)
        let sideY: CGFloat = eaveY - height * 0.58
        var eave = Path()
        eave.move(to: CGPoint(x: cx + half, y: eaveY))
        eave.addQuadCurve(to: CGPoint(x: cx - half, y: eaveY), control: CGPoint(x: cx, y: eaveY + sag * 2))
        var shape = Path()
        shape.move(to: CGPoint(x: cx, y: top))
        shape.addQuadCurve(to: CGPoint(x: cx + half, y: eaveY), control: CGPoint(x: cx + half * 0.5, y: sideY))
        shape.addQuadCurve(to: CGPoint(x: cx - half, y: eaveY), control: CGPoint(x: cx, y: eaveY + sag * 2))
        shape.addQuadCurve(to: CGPoint(x: cx, y: top), control: CGPoint(x: cx - half * 0.5, y: sideY))
        shape.closeSubpath()
        Kit.solid(&context, shape, Art.color(color), light: 0.3, shade: 0.26, rim: 2)
        let dark = builtStraw(cx: cx, topY: top, topHalf: half * 0.03, bottomY: eaveY + sag * 0.6, bottomHalf: half * 0.92, count: 11, seed: 23)
        let pale = builtStraw(cx: cx, topY: top, topHalf: half * 0.02, bottomY: eaveY + sag * 0.5, bottomHalf: half * 0.8, count: 5, seed: 37)
        Art.clipped(&context, to: shape) { g in
            Art.stroke(&g, eave, builtTone(color, 0.7), width: 6)
            Art.stroke(&g, dark, builtTone(color, 0.7).opacity(0.7), width: ArtStyle.detailLine)
            Art.stroke(&g, pale, builtTone(color, 1.25).opacity(0.55), width: 1.2)
        }
        let knotR: CGFloat = max(2.5, width * 0.035)
        var knot = Art.ellipse(cx, top + knotR * 0.8, knotR * 1.5, knotR)
        knot.addPath(Art.rect(cx - knotR * 0.5, top - knotR * 1.6, knotR, knotR * 2.2, radius: knotR * 0.5))
        Kit.solid(&context, knot, builtTone(color, 0.78), light: 0.3, shade: 0.2)
    }

    /// A low-pitched plank roof seen from the gable end (a Russian izba): a boarded gable with
    /// a small round window, carved barge boards with a scalloped edge, and a ridge pendant.
    static func builtPlankRoof(_ context: inout GraphicsContext, cx: CGFloat, eaveY: CGFloat, width: CGFloat, height: CGFloat, color: UInt32) {
        let half: CGFloat = width / 2
        let top: CGFloat = eaveY - height
        let board: CGFloat = max(4, min(height * 0.3, 9))
        let inset: CGFloat = min(half * 0.5, board * half / height)
        let gable = Art.polygon([CGPoint(x: cx - half * 0.9, y: eaveY), CGPoint(x: cx, y: top + board * 0.6), CGPoint(x: cx + half * 0.9, y: eaveY)])
        Kit.solid(&context, gable, builtTone(color, 1.18), light: 0.2, shade: 0.2)
        var boards = Path()
        var x: CGFloat = cx - half * 0.9 + 4
        while x < cx + half * 0.9 {
            boards.move(to: CGPoint(x: x, y: top))
            boards.addLine(to: CGPoint(x: x, y: eaveY))
            x += 8
        }
        Art.clipped(&context, to: gable) { g in
            Art.stroke(&g, boards, builtTone(color, 0.8).opacity(0.6), width: 1.2)
        }
        let eyeR: CGFloat = max(2, height * 0.11)
        Art.fill(&context, Art.circle(cx, eaveY - height * 0.34, eyeR * 1.45), Art.color(color))
        Art.fill(&context, Art.circle(cx, eaveY - height * 0.34, eyeR), Art.color(0x2A2140, 0.9))
        // The barge boards, with carved drops along their lower edge and a ridge pendant.
        let trim = Art.polygon([
            CGPoint(x: cx - half, y: eaveY), CGPoint(x: cx, y: top), CGPoint(x: cx + half, y: eaveY),
            CGPoint(x: cx + half - inset, y: eaveY), CGPoint(x: cx, y: top + board), CGPoint(x: cx - half + inset, y: eaveY),
        ])
        var carving = Art.rect(cx - board * 0.4, top + board * 0.5, board * 0.8, board * 1.5, radius: board * 0.4)
        let drops: Int = min(9, max(3, Int(half / 12)))
        let r: CGFloat = board * 0.34
        for index in 0..<drops {
            let t: CGFloat = (CGFloat(index) + 0.5) / CGFloat(drops)
            let dx: CGFloat = (half - inset) * t
            let dy: CGFloat = Kit.mix(top + board, eaveY, t)
            carving.addEllipse(in: CGRect(x: cx - dx - r, y: dy - r * 0.6, width: r * 2, height: r * 2))
            carving.addEllipse(in: CGRect(x: cx + dx - r, y: dy - r * 0.6, width: r * 2, height: r * 2))
        }
        Art.fill(&context, carving, builtTone(color, 0.92))
        Kit.solid(&context, trim, Art.color(color), light: 0.28, shade: 0.22)
        Art.fill(&context, Art.spark(cx, top - board * 0.2, board * 0.7), builtTone(color, 0.92))
    }
}

// MARK: - Houses

extension Kit {
    /// How much wider than the wall each roof is (the eaves' overhang on both sides).
    static func builtOverhang(_ style: RoofStyle) -> CGFloat {
        switch style {
        case .thatch: return 1.24
        case .tile, .shingle: return 1.14
        case .flat: return 1.04
        case .sweep: return 1.4
        case .snow: return 1.2
        case .cone: return 1.3
        case .plank: return 1.2
        }
    }

    /// A house front seen straight on, standing on baseY and centred on cx: the wall, the roof
    /// by style with overhanging eaves, one door and `windows` windows (0…3); `lit` makes door
    /// and windows glow warm with a spill of light on the ground; `timber` non-nil draws beams
    /// in that colour over the wall (a half-timber frame, or logs when the style is `.plank`).
    /// The whole house is `wallHeight + roofHeight` tall and `width` × the overhang wide.
    static func house(_ context: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, width: CGFloat, wallHeight: CGFloat, roofHeight: CGFloat, wall: UInt32, roof: UInt32, style: RoofStyle, door: UInt32 = 0x5A3A2A, windows: Int = 1, lit: Bool = false, timber: UInt32? = nil) {
        guard width > 0, wallHeight > 0 else { return }
        let top: CGFloat = baseY - wallHeight
        Kit.shadow(&context, cx, baseY, width: width * 1.08)
        let body = CGRect(x: cx - width / 2, y: top, width: width, height: wallHeight)
        let isRound: Bool = style == .cone
        Kit.wall(&context, rect: body, color: wall, radius: isRound ? 3 : 0)
        if let timber {
            let isLog: Bool = style == .plank
            builtTimber(&context, rect: body, color: timber, logs: isLog)
        }
        let isArched: Bool = style == .tile || style == .cone
        builtOpenings(&context, rect: body, door: door, windows: windows, lit: lit, arched: isArched)
        // The eaves throw a band of shade on the top of the wall.
        let eave: CGFloat = min(9, wallHeight * 0.12)
        Art.fill(&context, Art.rect(body.minX, top, width, eave), ArtStyle.coolShade.opacity(0.16))
        guard roofHeight > 0 else { return }
        let roofWidth: CGFloat = width * builtOverhang(style)
        if style == .flat {
            builtFlatRoof(&context, cx: cx, eaveY: top, width: roofWidth, height: roofHeight, wall: wall, line: roof)
        } else {
            Kit.roof(&context, cx: cx, eaveY: top, width: roofWidth, height: roofHeight, color: roof, style: style)
        }
    }

    /// The door and the windows of a house front, placed by how many windows there are.
    static func builtOpenings(_ context: inout GraphicsContext, rect: CGRect, door: UInt32, windows: Int, lit: Bool, arched: Bool) {
        let w: CGFloat = rect.width
        let h: CGFloat = rect.height
        let cx: CGFloat = rect.midX
        let baseY: CGFloat = rect.maxY
        let count: Int = min(3, max(0, windows))
        let doorW: CGFloat = min(w * 0.2, h * 0.42)
        let doorH: CGFloat = min(h * 0.7, doorW * 2.1)
        let side: CGFloat = min(w * 0.15, h * 0.3)
        var doorX: CGFloat = cx
        var spots: [CGFloat] = []
        switch count {
        case 1:
            doorX = cx - w * 0.16
            spots = [0.2]
        case 2:
            spots = [-0.3, 0.3]
        case 3:
            doorX = cx - w * 0.3
            spots = [-0.02, 0.17, 0.36]
        default:
            break
        }
        let lamp: Double = lit ? 1 : 0
        if lit {
            // The light of the open door lying on the ground.
            Art.group(&context, x: doorX, y: baseY + 2, scale: 0.4, scaleX: 4.5) { g in
                Art.glow(&g, 0, 0, doorW * 1.2, Art.color(0xFFC96B), alpha: 0.55)
            }
        }
        let doorRect = CGRect(x: doorX - doorW / 2, y: baseY - doorH, width: doorW, height: doorH)
        Kit.opening(&context, rect: doorRect, arched: arched, color: door, glow: lamp)
        let windowY: CGFloat = baseY - h * 0.56 - side / 2
        for spot in spots {
            let windowRect = CGRect(x: cx + w * spot - side / 2, y: windowY, width: side, height: side)
            Kit.opening(&context, rect: windowRect, arched: false, color: door, glow: lamp)
        }
    }

    /// Beams over a wall: a half-timber frame (posts, rails and two diagonal braces), or
    /// horizontal log lines with round log ends at both corners when `logs`.
    static func builtTimber(_ context: inout GraphicsContext, rect: CGRect, color: UInt32, logs: Bool) {
        if logs {
            builtLogs(&context, rect: rect, color: color)
            return
        }
        let beam: CGFloat = max(2.5, min(rect.width, rect.height) * 0.07)
        let x0: CGFloat = rect.minX + beam / 2
        let x1: CGFloat = rect.maxX - beam / 2
        let yTop: CGFloat = rect.minY + beam / 2
        let yBase: CGFloat = rect.maxY - beam / 2
        let yRail: CGFloat = rect.maxY - rect.height * 0.36
        let third: CGFloat = rect.width * 0.3
        var frame = Path()
        let posts: [CGFloat] = [x0, x0 + third, x1 - third, x1]
        for post in posts {
            frame.move(to: CGPoint(x: post, y: yTop))
            frame.addLine(to: CGPoint(x: post, y: yBase))
        }
        let rails: [CGFloat] = [yTop, yRail, yBase]
        for rail in rails {
            frame.move(to: CGPoint(x: x0, y: rail))
            frame.addLine(to: CGPoint(x: x1, y: rail))
        }
        frame.move(to: CGPoint(x: x0, y: yBase))
        frame.addLine(to: CGPoint(x: x0 + third, y: yRail))
        frame.move(to: CGPoint(x: x1, y: yBase))
        frame.addLine(to: CGPoint(x: x1 - third, y: yRail))
        Art.stroke(&context, frame, Art.color(color), width: beam, cap: .butt, join: .miter)
        Art.group(&context, x: -beam * 0.3, y: -beam * 0.3) { g in
            Art.stroke(&g, frame, builtTone(color, 1.35).opacity(0.45), width: 1, cap: .butt)
        }
    }

    /// A log wall: a line between every two logs and the round ends of the cross logs at both
    /// corners, each with its heart.
    static func builtLogs(_ context: inout GraphicsContext, rect: CGRect, color: UInt32) {
        let n: Int = min(12, max(4, Int(rect.height / 10)))
        let step: CGFloat = rect.height / CGFloat(n)
        let r: CGFloat = step * 0.5
        var lines = Path()
        var ends = Path()
        var hearts = Path()
        for index in 0..<n {
            let y: CGFloat = rect.minY + step * CGFloat(index)
            if index > 0 {
                lines.move(to: CGPoint(x: rect.minX, y: y))
                lines.addLine(to: CGPoint(x: rect.maxX, y: y))
            }
            let cy: CGFloat = y + r
            let sides: [CGFloat] = [rect.minX - r * 0.4, rect.maxX + r * 0.4]
            for ex in sides {
                ends.addEllipse(in: CGRect(x: ex - r, y: cy - r, width: r * 2, height: r * 2))
                hearts.addEllipse(in: CGRect(x: ex - r * 0.3, y: cy - r * 0.3, width: r * 0.6, height: r * 0.6))
            }
        }
        Art.stroke(&context, lines, builtTone(color, 0.8).opacity(0.8), width: 1.4, cap: .butt)
        Art.group(&context, x: 0, y: 1.4) { g in
            Art.stroke(&g, lines, builtTone(color, 1.35).opacity(0.3), width: 1, cap: .butt)
        }
        Kit.solid(&context, ends, builtTone(color, 1.12), light: 0.25, shade: 0.2)
        Art.fill(&context, hearts, builtTone(color, 0.7))
    }
}

// MARK: - Towers, domes, columns

extension Kit {
    /// A row of merlons on a low band from x0 to x1, the band's foot at topY: one modelled
    /// path. The crenellation is about `size` × 1.4 tall.
    static func builtMerlons(_ context: inout GraphicsContext, x0: CGFloat, x1: CGFloat, topY: CGFloat, size: CGFloat, color: UInt32) {
        let span: CGFloat = x1 - x0
        guard span > 0, size > 0 else { return }
        let wanted: Int = Int((span / size + 1) / 2)
        let n: Int = min(40, max(2, wanted))
        let unit: CGFloat = span / CGFloat(2 * n - 1)
        let band: CGFloat = size * 0.4
        var teeth = Path()
        teeth.addRect(CGRect(x: x0, y: topY - band, width: span, height: band + 1))
        for index in 0..<n {
            let x: CGFloat = x0 + unit * CGFloat(2 * index)
            teeth.addRect(CGRect(x: x, y: topY - band - size, width: unit, height: size + 1))
        }
        Kit.solid(&context, teeth, builtTone(color, 1.04), light: 0.24, shade: 0.2)
        Art.fill(&context, Art.rect(x0, topY, span, 2.5), ArtStyle.coolShade.opacity(0.18))
    }

    /// A pointed roof with slightly hollow sides, a shaded right face and a small gold ball.
    static func builtSpire(_ context: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, width: CGFloat, height: CGFloat, color: UInt32) {
        let half: CGFloat = width / 2
        let top: CGFloat = baseY - height
        let pullY: CGFloat = baseY - height * 0.42
        let sagY: CGFloat = baseY + width * 0.08
        var shape = Path()
        shape.move(to: CGPoint(x: cx - half, y: baseY))
        shape.addQuadCurve(to: CGPoint(x: cx, y: top), control: CGPoint(x: cx - half * 0.4, y: pullY))
        shape.addQuadCurve(to: CGPoint(x: cx + half, y: baseY), control: CGPoint(x: cx + half * 0.4, y: pullY))
        shape.addQuadCurve(to: CGPoint(x: cx - half, y: baseY), control: CGPoint(x: cx, y: sagY))
        shape.closeSubpath()
        Kit.solid(&context, shape, Art.color(color), light: 0.3, shade: 0.2, rim: 2)
        let face = Art.polygon([CGPoint(x: cx, y: top), CGPoint(x: cx + half, y: sagY), CGPoint(x: cx + half * 0.12, y: sagY)])
        Art.clipped(&context, to: shape) { g in
            Art.fill(&g, face, ArtStyle.coolShade.opacity(0.16))
        }
        Art.stroke(&context, Art.line(cx, top + 2, cx, top - 7), builtTone(color, 0.6), width: ArtStyle.detailLine)
        Art.fill(&context, Art.circle(cx, top - 8, 2.4), Art.color(0xE8C36A))
    }

    /// A tower or a stretch of wall standing on baseY, with crenellations along the top when
    /// `crenellated`, an optional pointed roof in `roof`, and two or three small windows.
    /// `height` is the masonry; merlons and the roof rise above it.
    static func tower(_ context: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, width: CGFloat, height: CGFloat, color: UInt32, crenellated: Bool = true, roof: UInt32? = nil) {
        guard width > 0, height > 0 else { return }
        let half: CGFloat = width / 2
        let top: CGFloat = baseY - height
        let flare: CGFloat = width * 0.06
        Kit.shadow(&context, cx, baseY, width: width * 1.1)
        let body = Art.polygon([
            CGPoint(x: cx - half - flare, y: baseY), CGPoint(x: cx - half, y: top),
            CGPoint(x: cx + half, y: top), CGPoint(x: cx + half + flare, y: baseY),
        ])
        Kit.solid(&context, body, Art.color(color), light: 0.24, shade: 0.26, rim: 2)
        let bounds = CGRect(x: cx - half - flare, y: top, width: width + flare * 2, height: height)
        let course: CGFloat = min(height * 0.08, 12)
        let marks = builtCourses(bounds, seed: 43)
        Art.clipped(&context, to: body) { g in
            Art.fill(&g, Art.rect(bounds.minX, baseY - course, bounds.width, course), builtTone(color, 0.78))
            Art.stroke(&g, marks, builtTone(color, 0.76).opacity(0.5), width: 1.2)
            ArtStyle.tooth(&g, in: bounds, seed: 62, alpha: 0.06)
        }
        let slitW: CGFloat = max(3, width * 0.16)
        let slitH: CGFloat = min(slitW * 2.2, height * 0.2)
        let slits: Int = height > width * 2.4 ? 3 : 2
        let frame: UInt32 = builtHex(color, 0.8)
        for index in 0..<slits {
            let turn: CGFloat = index % 2 == 0 ? -1 : 1
            let sx: CGFloat = cx + turn * width * 0.14
            let sy: CGFloat = top + height * (0.2 + 0.24 * CGFloat(index))
            let slit = CGRect(x: sx - slitW / 2, y: sy, width: slitW, height: slitH)
            Kit.opening(&context, rect: slit, arched: true, color: frame)
        }
        if let roof {
            // Behind the merlons when there are any; otherwise its eaves overhang the wall.
            let spireW: CGFloat = crenellated ? width * 0.9 : width * 1.2
            let spireH: CGFloat = min(height * 0.5, width * 1.2)
            builtSpire(&context, cx: cx, baseY: top, width: spireW, height: spireH, color: roof)
        }
        if crenellated {
            let merlon: CGFloat = max(4, width * 0.16)
            builtMerlons(&context, x0: cx - half - 2, x1: cx + half + 2, topY: top, size: merlon, color: color)
        }
    }

    /// The short round drum a dome sits on, with a row of small dark lights.
    static func builtDrum(_ context: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, width: CGFloat, height: CGFloat, color: UInt32) {
        let body = Art.rect(cx - width / 2, baseY - height, width, height)
        Kit.solid(&context, body, builtTone(color, 0.9), light: 0.24, shade: 0.24)
        var lights = Path()
        let count: Int = min(7, max(3, Int(width / 16)))
        let w: CGFloat = max(1.6, height * 0.22)
        for index in 0..<count {
            let t: CGFloat = (CGFloat(index) + 0.5) / CGFloat(count)
            let x: CGFloat = cx - width / 2 + width * t
            lights.addPath(Art.rect(x - w / 2, baseY - height * 0.78, w, height * 0.5, radius: w / 2))
        }
        Art.fill(&context, lights, Art.color(0x2A2140, 0.7))
    }

    /// A dome sitting on baseY: `onion` true = an onion dome (swelling past its base to a
    /// point) with optional stripes; false = a round dome on a short drum (stripes become
    /// ribs). A small gold finial rises about `height` × 0.14 above the top.
    static func dome(_ context: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, width: CGFloat, height: CGFloat, color: UInt32, onion: Bool, stripes: UInt32? = nil) {
        guard width > 0, height > 0 else { return }
        let half: CGFloat = width / 2
        let top: CGFloat = baseY - height
        let drum: CGFloat = onion ? 0 : height * 0.24
        let spring: CGFloat = baseY - drum
        let rise: CGFloat = height - drum
        let foot: CGFloat = onion ? width * 0.3 : half
        var shape = Path()
        if onion {
            let swellY: CGFloat = baseY - height * 0.38
            let neckY: CGFloat = baseY - height * 0.62
            shape.move(to: CGPoint(x: cx - foot, y: baseY))
            shape.addCurve(to: CGPoint(x: cx, y: top), control1: CGPoint(x: cx - width * 0.75, y: swellY), control2: CGPoint(x: cx - width * 0.08, y: neckY))
            shape.addCurve(to: CGPoint(x: cx + foot, y: baseY), control1: CGPoint(x: cx + width * 0.08, y: neckY), control2: CGPoint(x: cx + width * 0.75, y: swellY))
        } else {
            builtDrum(&context, cx: cx, baseY: baseY, width: width * 0.86, height: drum + 1, color: color)
            let lift: CGFloat = rise * 4 / 3
            shape.move(to: CGPoint(x: cx - half, y: spring))
            shape.addCurve(to: CGPoint(x: cx + half, y: spring), control1: CGPoint(x: cx - half, y: spring - lift), control2: CGPoint(x: cx + half, y: spring - lift))
        }
        shape.closeSubpath()
        Kit.solid(&context, shape, Art.color(color), light: 0.34, shade: 0.28, rim: 2)
        if let stripes {
            var bands = Path()
            let factors: [CGFloat] = [-0.62, 0, 0.62]
            let swell: CGFloat = onion ? width * 0.56 : half * 1.1
            for f in factors {
                bands.move(to: CGPoint(x: cx + f * foot, y: spring))
                bands.addQuadCurve(to: CGPoint(x: cx, y: top), control: CGPoint(x: cx + f * swell, y: spring - rise * 0.5))
            }
            Art.clipped(&context, to: shape) { g in
                Art.stroke(&g, bands, Art.color(stripes), width: max(2, width * 0.08))
            }
        }
        let band = Art.rect(cx - foot * 1.12, spring - 2.5, foot * 2.24, 5, radius: 2.5)
        Kit.solid(&context, band, builtTone(color, 0.72), light: 0.3, shade: 0.2)
        let pin: CGFloat = max(5, height * 0.14)
        Art.stroke(&context, Art.line(cx, top + 2, cx, top - pin), Art.color(0xC9A24E), width: ArtStyle.detailLine)
        Art.fill(&context, Art.circle(cx, top - pin * 0.45, max(1.8, pin * 0.22)), Art.color(0xE8C36A))
    }

    /// A column standing on baseY with base and capital: fluted Greek by default; `lotus`
    /// true = an Egyptian column with a flaring lotus/papyrus capital and coloured bands.
    /// `width` is the shaft at its foot; base and capital are wider (up to × 1.8 for lotus).
    static func column(_ context: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, width: CGFloat, height: CGFloat, color: UInt32, lotus: Bool = false) {
        guard width > 0, height > 0 else { return }
        let half: CGFloat = width / 2
        let top: CGFloat = baseY - height
        let baseH: CGFloat = max(3, min(height * 0.07, width * 0.5))
        let capH: CGFloat = lotus ? min(height * 0.2, width * 1.3) : min(height * 0.1, width * 0.7)
        let shaftTop: CGFloat = top + capH
        let shaftBottom: CGFloat = baseY - baseH
        let midY: CGFloat = (shaftTop + shaftBottom) / 2
        Kit.shadow(&context, cx, baseY, width: width * 1.5)
        var shaft = Path()
        shaft.move(to: CGPoint(x: cx - half, y: shaftBottom))
        shaft.addQuadCurve(to: CGPoint(x: cx - half * 0.82, y: shaftTop), control: CGPoint(x: cx - half * 1.02, y: midY))
        shaft.addLine(to: CGPoint(x: cx + half * 0.82, y: shaftTop))
        shaft.addQuadCurve(to: CGPoint(x: cx + half, y: shaftBottom), control: CGPoint(x: cx + half * 1.02, y: midY))
        shaft.closeSubpath()
        Kit.solid(&context, shaft, Art.color(color), light: 0.3, shade: 0.26)
        if lotus {
            builtLotusParts(&context, shaft: shaft, cx: cx, top: top, shaftTop: shaftTop, baseY: baseY, half: half, baseH: baseH, color: color)
        } else {
            builtGreekParts(&context, cx: cx, top: top, shaftTop: shaftTop, baseY: baseY, half: half, baseH: baseH, color: color)
        }
    }

    /// Flutes, a stepped base, and a Doric capital (echinus and abacus).
    static func builtGreekParts(_ context: inout GraphicsContext, cx: CGFloat, top: CGFloat, shaftTop: CGFloat, baseY: CGFloat, half: CGFloat, baseH: CGFloat, color: UInt32) {
        let shaftBottom: CGFloat = baseY - baseH
        let capH: CGFloat = shaftTop - top
        var flutes = Path()
        let places: [CGFloat] = [-0.55, -0.2, 0.15, 0.5]
        for f in places {
            flutes.move(to: CGPoint(x: cx + f * half, y: shaftBottom))
            flutes.addLine(to: CGPoint(x: cx + f * half * 0.82, y: shaftTop))
        }
        Art.stroke(&context, flutes, builtTone(color, 0.78).opacity(0.55), width: 1.2, cap: .butt)
        var foot = Art.rect(cx - half * 1.36, baseY - baseH * 0.5, half * 2.72, baseH * 0.5)
        foot.addPath(Art.rect(cx - half * 1.18, baseY - baseH, half * 2.36, baseH * 0.6, radius: baseH * 0.3))
        Kit.solid(&context, foot, builtTone(color, 0.94), light: 0.28, shade: 0.22)
        let neckY: CGFloat = top + capH * 0.45
        let echinus = Art.polygon([
            CGPoint(x: cx - half * 0.82, y: shaftTop), CGPoint(x: cx - half * 1.3, y: neckY),
            CGPoint(x: cx + half * 1.3, y: neckY), CGPoint(x: cx + half * 0.82, y: shaftTop),
        ])
        Kit.solid(&context, echinus, builtTone(color, 0.92), light: 0.28, shade: 0.22)
        let abacus = Art.rect(cx - half * 1.42, top, half * 2.84, capH * 0.48, radius: 1)
        Kit.solid(&context, abacus, builtTone(color, 1.03), light: 0.28, shade: 0.22)
    }

    /// Painted bands on the shaft, a flaring bell capital with petal lines, a thin abacus and
    /// a round foot.
    static func builtLotusParts(_ context: inout GraphicsContext, shaft: Path, cx: CGFloat, top: CGFloat, shaftTop: CGFloat, baseY: CGFloat, half: CGFloat, baseH: CGFloat, color: UInt32) {
        let capH: CGFloat = shaftTop - top
        let bandH: CGFloat = max(2, capH * 0.12)
        let hues: [UInt32] = [0xC8553D, 0x2F6F9E, 0xE2B84A]
        Art.clipped(&context, to: shaft) { g in
            for index in 0..<3 {
                let y: CGFloat = shaftTop + bandH * (0.6 + 1.5 * CGFloat(index))
                Art.fill(&g, Art.rect(cx - half * 1.1, y, half * 2.2, bandH), Art.color(hues[index], 0.9))
            }
            let lowY: CGFloat = baseY - baseH - bandH * 2.2
            Art.fill(&g, Art.rect(cx - half * 1.1, lowY, half * 2.2, bandH), Art.color(0x2F6F9E, 0.9))
        }
        let lipY: CGFloat = top + capH * 0.14
        let flareY: CGFloat = top + capH * 0.34
        var bell = Path()
        bell.move(to: CGPoint(x: cx - half * 0.82, y: shaftTop))
        bell.addQuadCurve(to: CGPoint(x: cx - half * 1.8, y: lipY), control: CGPoint(x: cx - half * 0.86, y: flareY))
        bell.addLine(to: CGPoint(x: cx + half * 1.8, y: lipY))
        bell.addQuadCurve(to: CGPoint(x: cx + half * 0.82, y: shaftTop), control: CGPoint(x: cx + half * 0.86, y: flareY))
        bell.closeSubpath()
        Kit.solid(&context, bell, builtTone(color, 1.05), light: 0.3, shade: 0.24, rim: 1.5)
        var petals = Path()
        let places: [CGFloat] = [-0.6, -0.2, 0.2, 0.6]
        for f in places {
            petals.move(to: CGPoint(x: cx + f * half * 0.7, y: shaftTop - 1))
            petals.addQuadCurve(to: CGPoint(x: cx + f * half * 1.7, y: lipY + 1), control: CGPoint(x: cx + f * half * 0.8, y: flareY))
        }
        Art.clipped(&context, to: bell) { g in
            Art.fill(&g, Art.rect(cx - half * 1.8, lipY, half * 3.6, capH * 0.1), Art.color(0xC8553D, 0.8))
            Art.stroke(&g, petals, Art.color(0x2F6F9E, 0.7), width: 1.4)
        }
        let abacus = Art.rect(cx - half, top, half * 2, capH * 0.16, radius: 1)
        Kit.solid(&context, abacus, builtTone(color, 0.94), light: 0.28, shade: 0.22)
        let foot = Art.rect(cx - half * 1.3, baseY - baseH, half * 2.6, baseH, radius: baseH / 2)
        Kit.solid(&context, foot, builtTone(color, 0.94), light: 0.28, shade: 0.22)
    }
}

// MARK: - Fences, gates, long walls

extension Kit {
    /// A fence from x0 to x1 on baseY: wooden pickets with two rails, or (`stone` true) a low
    /// dry-stone wall of rounded stones.
    static func fence(_ context: inout GraphicsContext, x0: CGFloat, x1: CGFloat, baseY: CGFloat, height: CGFloat, color: UInt32, stone: Bool = false) {
        let span: CGFloat = x1 - x0
        guard span > 0, height > 0 else { return }
        let ry: CGFloat = min(6, max(2, height * 0.14))
        ArtStyle.contactShadow(&context, x0 + span * 0.52, baseY, span * 0.52, ry, alpha: 0.2)
        if stone {
            builtStoneWall(&context, x0: x0, span: span, baseY: baseY, height: height, color: color)
            return
        }
        let top: CGFloat = baseY - height
        let gap: CGFloat = max(6, height * 0.34)
        let count: Int = min(80, max(2, Int(span / gap) + 1))
        let step: CGFloat = span / CGFloat(count - 1)
        let pw: CGFloat = max(2.5, min(step * 0.5, height * 0.16))
        let railH: CGFloat = max(2, height * 0.09)
        var rails = Path()
        rails.addRect(CGRect(x: x0, y: baseY - height * 0.72, width: span, height: railH))
        rails.addRect(CGRect(x: x0, y: baseY - height * 0.3, width: span, height: railH))
        Art.fill(&context, rails, builtTone(color, 0.74))
        var pickets = Path()
        var edges = Path()
        for index in 0..<count {
            let x: CGFloat = x0 + step * CGFloat(index)
            let left: CGFloat = x - pw / 2
            let right: CGFloat = x + pw / 2
            let shoulder: CGFloat = top + pw * 0.6
            pickets.move(to: CGPoint(x: left, y: baseY))
            pickets.addLine(to: CGPoint(x: left, y: shoulder))
            pickets.addLine(to: CGPoint(x: x, y: top))
            pickets.addLine(to: CGPoint(x: right, y: shoulder))
            pickets.addLine(to: CGPoint(x: right, y: baseY))
            pickets.closeSubpath()
            edges.move(to: CGPoint(x: right - 0.6, y: shoulder))
            edges.addLine(to: CGPoint(x: right - 0.6, y: baseY))
        }
        Kit.solid(&context, pickets, Art.color(color), light: 0.22, shade: 0.12)
        Art.stroke(&context, edges, builtTone(color, 0.7).opacity(0.6), width: 1.1, cap: .butt)
    }

    /// A dry-stone wall: rows of rounded stones in two tones on a dark bed, the top row uneven.
    static func builtStoneWall(_ context: inout GraphicsContext, x0: CGFloat, span: CGFloat, baseY: CGFloat, height: CGFloat, color: UInt32) {
        var random = ArtRandom(91)
        let rows: Int = min(4, max(2, Int(height / 9)))
        let rowH: CGFloat = height / CGFloat(rows)
        let bed = Art.rect(x0, baseY - height * 0.92, span, height * 0.92, radius: rowH * 0.4)
        Art.fill(&context, bed, builtTone(color, 0.6))
        var pale = Path()
        var dark = Path()
        for row in 0..<rows {
            let y: CGFloat = baseY - rowH * CGFloat(row + 1)
            let shift: CGFloat = row % 2 == 0 ? 0 : rowH * 0.7
            var x: CGFloat = x0 - shift
            var index: Int = row
            while x < x0 + span {
                let w: CGFloat = rowH * (1.1 + rnd(&random) * 0.9)
                let bump: CGFloat = rnd(&random) * rowH * 0.3
                let lift: CGFloat = row == rows - 1 ? bump : 0
                let left: CGFloat = max(x0, x)
                let right: CGFloat = min(x0 + span, x + w)
                if right - left > 2 {
                    let block = Art.rect(left + 0.6, y - lift + 0.6, right - left - 1.2, rowH + lift - 1.2, radius: rowH * 0.42)
                    if index % 2 == 0 {
                        pale.addPath(block)
                    } else {
                        dark.addPath(block)
                    }
                }
                x += w
                index += 1
            }
        }
        Kit.solid(&context, pale, Art.color(color), light: 0.26, shade: 0.16)
        Kit.solid(&context, dark, builtTone(color, 0.86), light: 0.22, shade: 0.16)
    }

    /// A gate / gateway in a compound wall: two posts and a lintel (or an arch when `arched`),
    /// open, its two leaves swung back against the posts. `width` × `height` overall.
    static func gateway(_ context: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, width: CGFloat, height: CGFloat, color: UInt32, arched: Bool = false) {
        guard width > 0, height > 0 else { return }
        let half: CGFloat = width / 2
        let top: CGFloat = baseY - height
        let post: CGFloat = max(4, min(width * 0.16, height * 0.22))
        let inner: CGFloat = half - post
        Kit.shadow(&context, cx, baseY, width: width)
        let leafW: CGFloat = post * 0.5
        let leafTop: CGFloat = top + height * 0.26
        var leaves = Path()
        leaves.addRect(CGRect(x: cx - inner, y: leafTop, width: leafW, height: baseY - leafTop))
        leaves.addRect(CGRect(x: cx + inner - leafW, y: leafTop, width: leafW, height: baseY - leafTop))
        Art.fill(&context, leaves, builtTone(color, 0.55))
        var frame = Path()
        if arched {
            let r: CGFloat = max(1, min(inner, height - post - 2))
            let spring: CGFloat = top + post + r
            let lift: CGFloat = r * 4 / 3
            let corner: CGFloat = post * 0.6
            frame.move(to: CGPoint(x: cx - half, y: baseY))
            frame.addLine(to: CGPoint(x: cx - half, y: top + corner))
            frame.addQuadCurve(to: CGPoint(x: cx - half + corner, y: top), control: CGPoint(x: cx - half, y: top))
            frame.addLine(to: CGPoint(x: cx + half - corner, y: top))
            frame.addQuadCurve(to: CGPoint(x: cx + half, y: top + corner), control: CGPoint(x: cx + half, y: top))
            frame.addLine(to: CGPoint(x: cx + half, y: baseY))
            frame.addLine(to: CGPoint(x: cx + inner, y: baseY))
            frame.addLine(to: CGPoint(x: cx + inner, y: spring))
            frame.addCurve(to: CGPoint(x: cx - inner, y: spring), control1: CGPoint(x: cx + inner, y: spring - lift), control2: CGPoint(x: cx - inner, y: spring - lift))
            frame.addLine(to: CGPoint(x: cx - inner, y: baseY))
            frame.closeSubpath()
        } else {
            let lintel: CGFloat = post * 0.9
            frame.addRect(CGRect(x: cx - half, y: top + lintel * 0.5, width: post, height: height - lintel * 0.5))
            frame.addRect(CGRect(x: cx + inner, y: top + lintel * 0.5, width: post, height: height - lintel * 0.5))
            frame.addRect(CGRect(x: cx - half - post * 0.5, y: top, width: width + post, height: lintel))
        }
        Kit.solid(&context, frame, Art.color(color), light: 0.26, shade: 0.22, rim: 1.5)
        let course: CGFloat = min(8, height * 0.08)
        let bounds = CGRect(x: cx - half - post * 0.5, y: top, width: width + post, height: height)
        Art.clipped(&context, to: frame) { g in
            Art.fill(&g, Art.rect(bounds.minX, baseY - course, bounds.width, course), builtTone(color, 0.78))
            ArtStyle.tooth(&g, in: bounds, seed: 64, alpha: 0.06)
        }
    }

    /// A long compound / garden / city wall from x0 to x1 standing on baseY, `height` tall,
    /// with a coping in a darker tone (and crenellations above it when `crenellated`).
    static func longWall(_ context: inout GraphicsContext, x0: CGFloat, x1: CGFloat, baseY: CGFloat, height: CGFloat, color: UInt32, crenellated: Bool = false) {
        let span: CGFloat = x1 - x0
        guard span > 0, height > 0 else { return }
        let top: CGFloat = baseY - height
        let ry: CGFloat = min(7, max(2, height * 0.1))
        ArtStyle.contactShadow(&context, x0 + span * 0.52, baseY, span * 0.52, ry, alpha: 0.2)
        let rect = CGRect(x: x0, y: top, width: span, height: height)
        Kit.wall(&context, rect: rect, color: color)
        let marks = builtCourses(rect.insetBy(dx: 0, dy: height * 0.14), seed: 47)
        Art.clipped(&context, to: Path(rect)) { g in
            Art.stroke(&g, marks, builtTone(color, 0.76).opacity(0.45), width: 1.2)
        }
        if crenellated {
            let merlon: CGFloat = max(4, min(height * 0.16, 12))
            builtMerlons(&context, x0: x0, x1: x1, topY: top, size: merlon, color: color)
        }
        let cope: CGFloat = max(3, min(height * 0.12, 8))
        let coping = Art.rect(x0 - 2, top - cope * 0.5, span + 4, cope, radius: cope * 0.4)
        Kit.solid(&context, coping, builtTone(color, 0.72), light: 0.3, shade: 0.2)
    }
}

// MARK: - Far houses, a windmill, a bridge

extension Kit {
    /// A small far house for the far plane in flat hazy colours: wall + roof, no detail.
    /// `flat` gives a flat-roofed block with a smaller upper room. `width` × `height` overall.
    static func farHouse(_ context: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, width: CGFloat, height: CGFloat, wall: Color, roof: Color, flat: Bool = false) {
        guard width > 0, height > 0 else { return }
        let half: CGFloat = width / 2
        let top: CGFloat = baseY - height
        if flat {
            let bodyTop: CGFloat = top + height * 0.3
            let line: CGFloat = max(1.4, height * 0.07)
            Art.fill(&context, Art.rect(cx - half, bodyTop, width, height * 0.7), wall)
            Art.fill(&context, Art.rect(cx + half * 0.1, top, half * 0.8, height * 0.34), wall)
            Art.fill(&context, Art.rect(cx - half - 1, bodyTop - line * 0.5, width + 2, line), roof)
            Art.fill(&context, Art.rect(cx + half * 0.1 - 1, top - line * 0.5, half * 0.8 + 2, line), roof)
        } else {
            let eaveY: CGFloat = top + height * 0.48
            Art.fill(&context, Art.rect(cx - half * 0.86, eaveY, half * 1.72, height * 0.52), wall)
            let slope = Art.polygon([
                CGPoint(x: cx - half, y: eaveY + 1), CGPoint(x: cx - half * 0.4, y: top),
                CGPoint(x: cx + half * 0.4, y: top), CGPoint(x: cx + half, y: eaveY + 1),
            ])
            Art.fill(&context, slope, roof)
        }
        let shade = Art.rect(cx + half * 0.2, top + height * 0.52, half * 0.66, height * 0.48)
        Art.fill(&context, shade, ArtStyle.coolShade.opacity(0.1))
    }

    /// One windmill sail in its own space: the arm runs along +x from the hub at the origin.
    static func builtSail(_ context: inout GraphicsContext, length: CGFloat, cloth: UInt32, wood: UInt32) {
        let w: CGFloat = length * 0.22
        let start: CGFloat = length * 0.24
        let run: CGFloat = length - start
        let frame = CGRect(x: start, y: 0, width: run, height: w)
        Art.fill(&context, Path(frame), Art.color(cloth, 0.88))
        var lattice = Path()
        lattice.addRect(frame)
        let bars: Int = 5
        for index in 1..<bars {
            let x: CGFloat = start + run * CGFloat(index) / CGFloat(bars)
            lattice.move(to: CGPoint(x: x, y: 0))
            lattice.addLine(to: CGPoint(x: x, y: w))
        }
        lattice.move(to: CGPoint(x: start, y: w / 2))
        lattice.addLine(to: CGPoint(x: length, y: w / 2))
        Art.stroke(&context, lattice, Art.color(wood, 0.7), width: 1, cap: .butt)
        Art.stroke(&context, Art.line(0, 0, length, 0), Art.color(wood), width: max(1.6, length * 0.035))
    }

    /// A windmill (a smock mill with four lattice sails) standing on baseY, about `height`
    /// tall to the tip of the highest sail; the sails sweep about `height` × 0.38 round the hub.
    static func windmill(_ context: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, height: CGFloat, body: UInt32 = 0x8A6A52, sails: UInt32 = 0xF2E8D8) {
        guard height > 0 else { return }
        let footHalf: CGFloat = height * 0.16
        let neckHalf: CGFloat = height * 0.095
        let neckY: CGFloat = baseY - height * 0.6
        Kit.shadow(&context, cx, baseY, width: footHalf * 2.3)
        let smock = Art.polygon([
            CGPoint(x: cx - footHalf, y: baseY), CGPoint(x: cx - neckHalf, y: neckY),
            CGPoint(x: cx + neckHalf, y: neckY), CGPoint(x: cx + footHalf, y: baseY),
        ])
        Kit.solid(&context, smock, Art.color(body), light: 0.26, shade: 0.26, rim: 2)
        var boards = Path()
        for index in 1..<6 {
            let y: CGFloat = Kit.mix(neckY, baseY, CGFloat(index) / 6)
            boards.move(to: CGPoint(x: cx - footHalf, y: y))
            boards.addLine(to: CGPoint(x: cx + footHalf, y: y))
        }
        Art.clipped(&context, to: smock) { g in
            Art.stroke(&g, boards, builtTone(body, 0.76).opacity(0.5), width: 1.2, cap: .butt)
            Art.fill(&g, Art.rect(cx - footHalf, baseY - height * 0.04, footHalf * 2, height * 0.04), builtTone(body, 0.72))
        }
        let capHalf: CGFloat = neckHalf * 1.25
        let capLift: CGFloat = height * 0.1 * 4 / 3
        var cap = Path()
        cap.move(to: CGPoint(x: cx - capHalf, y: neckY + 1))
        cap.addCurve(to: CGPoint(x: cx + capHalf, y: neckY + 1), control1: CGPoint(x: cx - capHalf, y: neckY - capLift), control2: CGPoint(x: cx + capHalf, y: neckY - capLift))
        cap.closeSubpath()
        Kit.solid(&context, cap, builtTone(body, 0.7), light: 0.3, shade: 0.22, rim: 1.5)
        let frame: UInt32 = builtHex(body, 0.6)
        let doorRect = CGRect(x: cx - height * 0.035, y: baseY - height * 0.13, width: height * 0.07, height: height * 0.13)
        Kit.opening(&context, rect: doorRect, arched: true, color: frame)
        let windowRect = CGRect(x: cx - height * 0.025, y: baseY - height * 0.42, width: height * 0.05, height: height * 0.05)
        Kit.opening(&context, rect: windowRect, arched: false, color: frame)
        let hubY: CGFloat = neckY - height * 0.03
        let arm: CGFloat = height * 0.38
        let wood: UInt32 = builtHex(body, 0.55)
        for index in 0..<4 {
            let angle: CGFloat = Kit.deg(24 + 90 * CGFloat(index))
            Art.group(&context, x: cx, y: hubY, rotate: angle) { g in
                builtSail(&g, length: arm, cloth: sails, wood: wood)
            }
        }
        Art.fill(&context, Art.circle(cx, hubY, max(2, height * 0.022)), Art.color(wood))
    }

    /// A small bridge spanning x0…x1 at deckY: a single low stone arch whose feet stand
    /// `rise` below the deck (the deck humps up by about a quarter of `rise`), or (`plank`
    /// true) a flat plank bridge on posts `rise` long with a handrail.
    static func bridge(_ context: inout GraphicsContext, x0: CGFloat, x1: CGFloat, deckY: CGFloat, rise: CGFloat, color: UInt32, plank: Bool = false) {
        let span: CGFloat = x1 - x0
        guard span > 0, rise > 0 else { return }
        if plank {
            builtPlankBridge(&context, x0: x0, span: span, deckY: deckY, rise: rise, color: color)
            return
        }
        let mid: CGFloat = x0 + span / 2
        let footY: CGFloat = deckY + rise
        let pier: CGFloat = span * 0.14
        let lift: CGFloat = rise * 0.85 * 4 / 3
        let humpY: CGFloat = deckY - rise * 0.5
        var deck = Path()
        deck.move(to: CGPoint(x: x0, y: deckY))
        deck.addQuadCurve(to: CGPoint(x: x1, y: deckY), control: CGPoint(x: mid, y: humpY))
        var ring = Path()
        ring.move(to: CGPoint(x: x1 - pier, y: footY))
        ring.addCurve(to: CGPoint(x: x0 + pier, y: footY), control1: CGPoint(x: x1 - pier, y: footY - lift), control2: CGPoint(x: x0 + pier, y: footY - lift))
        var shape = Path()
        shape.move(to: CGPoint(x: x0, y: footY))
        shape.addLine(to: CGPoint(x: x0, y: deckY))
        shape.addQuadCurve(to: CGPoint(x: x1, y: deckY), control: CGPoint(x: mid, y: humpY))
        shape.addLine(to: CGPoint(x: x1, y: footY))
        shape.addLine(to: CGPoint(x: x1 - pier, y: footY))
        shape.addCurve(to: CGPoint(x: x0 + pier, y: footY), control1: CGPoint(x: x1 - pier, y: footY - lift), control2: CGPoint(x: x0 + pier, y: footY - lift))
        shape.closeSubpath()
        Kit.solid(&context, shape, Art.color(color), light: 0.26, shade: 0.22, rim: 2)
        let marks = builtCourses(CGRect(x: x0, y: deckY - rise * 0.2, width: span, height: rise * 1.2), seed: 53)
        Art.clipped(&context, to: shape) { g in
            Art.stroke(&g, marks, builtTone(color, 0.76).opacity(0.45), width: 1.2)
            Art.stroke(&g, ring, builtTone(color, 0.7), width: max(4, rise * 0.18))
            Art.stroke(&g, deck, builtTone(color, 1.2).opacity(0.8), width: max(3, rise * 0.12))
        }
    }

    /// A flat plank bridge: legs down to the water, a deck with plank ends, and a handrail.
    static func builtPlankBridge(_ context: inout GraphicsContext, x0: CGFloat, span: CGFloat, deckY: CGFloat, rise: CGFloat, color: UInt32) {
        let thick: CGFloat = max(3, rise * 0.16)
        let posts: Int = min(8, max(2, Int(span / 60) + 2))
        let railY: CGFloat = deckY - rise * 0.5
        var legs = Path()
        var rails = Path()
        for index in 0..<posts {
            let t: CGFloat = CGFloat(index) / CGFloat(posts - 1)
            let x: CGFloat = x0 + span * (0.04 + 0.92 * t)
            legs.addRect(CGRect(x: x - thick * 0.5, y: deckY, width: thick, height: rise))
            rails.move(to: CGPoint(x: x, y: deckY))
            rails.addLine(to: CGPoint(x: x, y: railY))
        }
        rails.move(to: CGPoint(x: x0, y: railY))
        rails.addLine(to: CGPoint(x: x0 + span, y: railY))
        Art.fill(&context, legs, builtTone(color, 0.62))
        Art.stroke(&context, rails, builtTone(color, 0.8), width: max(1.6, thick * 0.45))
        let deck = Art.rect(x0, deckY, span, thick, radius: 1)
        Kit.solid(&context, deck, Art.color(color), light: 0.28, shade: 0.2)
        var ends = Path()
        var x: CGFloat = x0 + 8
        while x < x0 + span {
            ends.move(to: CGPoint(x: x, y: deckY + 1))
            ends.addLine(to: CGPoint(x: x, y: deckY + thick - 1))
            x += 10
        }
        Art.stroke(&context, ends, builtTone(color, 0.7).opacity(0.6), width: 1, cap: .butt)
        Art.fill(&context, Art.rect(x0, deckY + thick, span, 2), ArtStyle.coolShade.opacity(0.18))
    }
}
