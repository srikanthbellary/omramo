import SwiftUI
import OmramoCore

// Concept art for the landmark cards (CONTENT_PLAN §5–6). Every picture is our own drawing,
// made in code: nothing is a photograph and nothing is traced. A lost wonder is drawn as our
// own reconstruction and is given a sketched look so that it reads as an idea, not a record.
//
// Each painter works in the 432 × 404 space of `ArtRole.picture`. The pictures live in
// `LandmarkArt+TajMahal.swift`, `LandmarkArt+Lighthouse.swift`, `LandmarkArt+Asante.swift`
// and `LandmarkArt+Skytree.swift`; this file holds the entry point and the shared helpers.

/// Concept art for the landmark cards, drawn in code.
enum LandmarkArt {
    /// The width of the space every landmark painter draws in.
    static let unitWidth: CGFloat = 432
    /// The height of the space every landmark painter draws in.
    static let unitHeight: CGFloat = 404

    /// Draws the landmark picture called `name` (the landmark's art asset name).
    /// Returns false for a landmark it does not know.
    static func paint(_ name: String, role: ArtRole, in context: inout GraphicsContext, size: CGSize) -> Bool {
        let painter: (inout GraphicsContext) -> Void
        switch name {
        case "taj-mahal":
            painter = { g in LandmarkArt.paintTajMahal(&g) }
        case "lighthouse-of-alexandria":
            painter = { g in LandmarkArt.paintLighthouse(&g) }
        case "asante-traditional-buildings":
            painter = { g in LandmarkArt.paintAsante(&g) }
        case "tokyo-skytree":
            painter = { g in LandmarkArt.paintSkytree(&g) }
        default:
            return false
        }
        guard size.width > 0, size.height > 0 else { return true }

        // The pictures are composed for 432 × 404. Any other shape is covered, never stretched.
        let scale = max(size.width / unitWidth, size.height / unitHeight)
        let dx = (size.width - unitWidth * scale) / 2
        let dy = (size.height - unitHeight * scale) / 2
        let frame = Art.rect(0, 0, size.width, size.height)
        Art.clipped(&context, to: frame) { clip in
            Art.group(&clip, x: dx, y: dy, scale: scale, painter)
        }
        return true
    }
}

// MARK: - Shared helpers

extension LandmarkArt {
    static func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        CGPoint(x: x, y: y)
    }

    /// Fills `path` with a gradient that runs straight down from `y0` to `y1`.
    static func fillVertical(
        _ context: inout GraphicsContext,
        _ path: Path,
        _ stops: [(Color, CGFloat)],
        from y0: CGFloat,
        to y1: CGFloat
    ) {
        Art.fillLinear(&context, path, stops, from: CGPoint(x: 0, y: y0), to: CGPoint(x: 0, y: y1))
    }

    /// Fills `path` with a gradient that runs straight across from `x0` to `x1`.
    static func fillHorizontal(
        _ context: inout GraphicsContext,
        _ path: Path,
        _ stops: [(Color, CGFloat)],
        from x0: CGFloat,
        to x1: CGFloat
    ) {
        Art.fillLinear(&context, path, stops, from: CGPoint(x: x0, y: 0), to: CGPoint(x: x1, y: 0))
    }

    /// Fills the whole picture (and a margin around it) with a top-to-bottom gradient.
    static func backdrop(_ context: inout GraphicsContext, _ stops: [(Color, CGFloat)]) {
        let path = Art.rect(-24, -24, unitWidth + 48, unitHeight + 48)
        fillVertical(&context, path, stops, from: 0, to: unitHeight)
    }

    /// Leads the bottom of the picture toward the card's background colour.
    static func bottomFade(_ context: inout GraphicsContext, _ hex: UInt32, from y: CGFloat, alpha: Double) {
        let path = Art.rect(-24, y, unitWidth + 48, unitHeight + 24 - y)
        let stops: [(Color, CGFloat)] = [
            (Art.color(hex, 0), 0),
            (Art.color(hex, alpha * 0.55), 0.5),
            (Art.color(hex, alpha), 1),
        ]
        fillVertical(&context, path, stops, from: y, to: unitHeight)
    }

    /// Small stars, thickest at the top of the sky and thinning toward `maxY`.
    static func stars(_ context: inout GraphicsContext, count: Int, seed: UInt32, maxY: CGFloat, color: Color) {
        var random = ArtRandom(seed)
        var dim = Path()
        var bright = Path()
        for index in 0..<max(0, count) {
            let x = unitWidth * random.next(in: 0...1)
            let fall = random.next(in: 0...1)
            let y = 6 + (maxY - 6) * fall * fall
            let r = random.next(in: 0.4...1.1)
            let dot = CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)
            if index % 4 == 0 {
                bright.addEllipse(in: dot)
            } else {
                dim.addEllipse(in: dot)
            }
        }
        Art.fill(&context, dim, color.opacity(0.45))
        Art.fill(&context, bright, color.opacity(0.9))
    }

    /// A pointed arch standing on `baseY`, `width` wide and `height` tall.
    static func pointedArch(_ cx: CGFloat, _ baseY: CGFloat, width: CGFloat, height: CGFloat) -> Path {
        let half = width / 2
        let spring = baseY - height * 0.55
        let top = baseY - height
        let shoulder = spring - height * 0.25
        let crown = top + height * 0.1
        var path = Path()
        path.move(to: pt(cx - half, baseY))
        path.addLine(to: pt(cx - half, spring))
        path.addCurve(to: pt(cx, top), control1: pt(cx - half, shoulder), control2: pt(cx - half * 0.35, crown))
        path.addCurve(to: pt(cx + half, spring), control1: pt(cx + half * 0.35, crown), control2: pt(cx + half, shoulder))
        path.addLine(to: pt(cx + half, baseY))
        path.closeSubpath()
        return path
    }

    /// An onion dome sitting on `baseY`: it swells past its base and comes to a point.
    static func onionDome(_ cx: CGFloat, _ baseY: CGFloat, halfWidth: CGFloat, height: CGFloat) -> Path {
        let swell = halfWidth * 2.05
        let neck = halfWidth * 0.55
        let low = baseY - height * 0.42
        let high = baseY - height * 0.78
        var path = Path()
        path.move(to: pt(cx - halfWidth, baseY))
        path.addCurve(to: pt(cx, baseY - height), control1: pt(cx - swell, low), control2: pt(cx - neck, high))
        path.addCurve(to: pt(cx + halfWidth, baseY), control1: pt(cx + neck, high), control2: pt(cx + swell, low))
        path.closeSubpath()
        return path
    }

    /// An open spiral that winds inward from its rim. `start` is the angle of the rim point.
    static func spiral(_ cx: CGFloat, _ cy: CGFloat, _ radius: CGFloat, turns: CGFloat, start: CGFloat, clockwise: Bool) -> Path {
        var path = Path()
        let steps = 40
        let direction: CGFloat = clockwise ? 1 : -1
        let sweep = turns * 2 * CGFloat.pi
        for index in 0...steps {
            let t = CGFloat(index) / CGFloat(steps)
            let angle = start + direction * t * sweep
            let r = radius * (1 - t * 0.9)
            let point = CGPoint(x: cx + cos(angle) * r, y: cy + sin(angle) * r)
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        return path
    }

    /// A row of soft tree crowns from `x0` to `x1`, closed `depth` below `baseY`.
    static func canopy(
        from x0: CGFloat,
        to x1: CGFloat,
        baseY: CGFloat,
        height: CGFloat,
        bump: CGFloat,
        depth: CGFloat,
        seed: UInt32
    ) -> Path {
        var random = ArtRandom(seed)
        var path = Path()
        var x = x0
        var y = baseY - height * random.next(in: 0.3...1)
        path.move(to: pt(x0, baseY + depth))
        path.addLine(to: pt(x, y))
        while x < x1 {
            let w = bump * random.next(in: 0.6...1.4)
            let nextY = baseY - height * random.next(in: 0.35...1)
            let lift = bump * random.next(in: 0.25...0.55)
            let control = pt(x + w / 2, min(y, nextY) - lift)
            path.addQuadCurve(to: pt(x + w, nextY), control: control)
            x += w
            y = nextY
        }
        path.addLine(to: pt(x, baseY + depth))
        path.closeSubpath()
        return path
    }

    /// Short level strokes scattered over `rect`: ripples and glints on water.
    static func ripples(
        _ context: inout GraphicsContext,
        in rect: CGRect,
        count: Int,
        seed: UInt32,
        color: Color,
        width: CGFloat,
        length: ClosedRange<Double>
    ) {
        var random = ArtRandom(seed)
        var path = Path()
        for _ in 0..<max(0, count) {
            let x = rect.minX + rect.width * random.next(in: 0...1)
            let y = rect.minY + rect.height * random.next(in: 0...1)
            let half = random.next(in: length) / 2
            path.move(to: pt(x - half, y))
            path.addLine(to: pt(x + half, y))
        }
        Art.stroke(&context, path, color, width: width)
    }

    /// Parallel slanting lines that cover `rect` (clip to the shape they should fill).
    static func diagonals(in rect: CGRect, spacing: CGFloat, rising: Bool) -> Path {
        var path = Path()
        let step = max(0.5, spacing)
        var x = rect.minX - rect.height
        while x < rect.maxX {
            if rising {
                path.move(to: pt(x, rect.maxY))
                path.addLine(to: pt(x + rect.height, rect.minY))
            } else {
                path.move(to: pt(x, rect.minY))
                path.addLine(to: pt(x + rect.height, rect.maxY))
            }
            x += step
        }
        return path
    }

    /// Paper tooth over the whole picture: pale and dark specks.
    static func tooth(_ context: inout GraphicsContext, seed: UInt32, light: Double, dark: Double) {
        let whole = CGRect(x: 0, y: 0, width: unitWidth, height: unitHeight)
        Art.stipple(&context, in: whole, count: 260, seed: seed, color: Art.color(0xFFFFFF), alpha: light)
        Art.stipple(&context, in: whole, count: 200, seed: seed &+ 101, color: Art.color(0x0A1030), alpha: dark)
    }
}
