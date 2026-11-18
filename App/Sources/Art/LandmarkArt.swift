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
        // Round 5, batch 1 (App/Sources/Art/Landmarks/).
        case "sydney-opera-house":
            painter = { g in LandmarkArt.paintSydneyOperaHouse(&g) }
        case "himeji-castle":
            painter = { g in LandmarkArt.paintHimejiCastle(&g) }
        case "great-wall-of-china":
            painter = { g in LandmarkArt.paintGreatWall(&g) }
        case "machu-picchu":
            painter = { g in LandmarkArt.paintMachuPicchu(&g) }
        case "hagia-sophia":
            painter = { g in LandmarkArt.paintHagiaSophia(&g) }
        case "saint-basils-cathedral":
            painter = { g in LandmarkArt.paintSaintBasils(&g) }
        case "bremen-town-hall-roland":
            painter = { g in LandmarkArt.paintBremenRoland(&g) }
        case "colossus-of-rhodes":
            painter = { g in LandmarkArt.paintColossus(&g) }
        case "statue-of-liberty":
            painter = { g in LandmarkArt.paintStatueOfLiberty(&g) }
        case "petra":
            painter = { g in LandmarkArt.paintPetra(&g) }
        // Round 5, batch 2.
        case "great-pyramid-giza":
            painter = { g in LandmarkArt.paintGreatPyramid(&g) }
        case "chichen-itza":
            painter = { g in LandmarkArt.paintChichenItza(&g) }
        case "mount-fuji":
            painter = { g in LandmarkArt.paintMountFuji(&g) }
        case "golden-gate-bridge":
            painter = { g in LandmarkArt.paintGoldenGate(&g) }
        case "novgorod-kremlin":
            painter = { g in LandmarkArt.paintNovgorod(&g) }
        case "christ-the-redeemer":
            painter = { g in LandmarkArt.paintChristRedeemer(&g) }
        case "colosseum":
            painter = { g in LandmarkArt.paintColosseum(&g) }
        case "temple-of-artemis-ephesus":
            painter = { g in LandmarkArt.paintTempleOfArtemis(&g) }
        case "parthenon":
            painter = { g in LandmarkArt.paintParthenon(&g) }
        case "statue-of-zeus-olympia":
            painter = { g in LandmarkArt.paintZeusOlympia(&g) }
        case "hanging-gardens-babylon":
            painter = { g in LandmarkArt.paintHangingGardens(&g) }
        case "burj-khalifa":
            painter = { g in LandmarkArt.paintBurjKhalifa(&g) }
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

    /// Paper tooth over the whole picture: pale and dark specks, through the shared stipple
    /// (`ArtStyle.tooth`) so the density and dot size match the story pictures. The dark specks
    /// are the shared shadow tint, never black.
    static func tooth(_ context: inout GraphicsContext, seed: UInt32, light: Double, dark: Double) {
        let whole = CGRect(x: 0, y: 0, width: unitWidth, height: unitHeight)
        ArtStyle.tooth(&context, in: whole, seed: seed, color: Art.color(0xFFFFFF), alpha: light)
        ArtStyle.tooth(&context, in: whole, seed: seed &+ 101, color: ArtStyle.coolShade, alpha: dark)
    }

    /// The warm band at a landmark's horizon (art direction §1), across the whole picture.
    static func horizon(_ context: inout GraphicsContext, y: CGFloat, rise: CGFloat, hex: UInt32, alpha: Double) {
        var wide = context
        wide.translateBy(x: -24, y: 0)
        ArtStyle.horizonGlow(&wide, width: unitWidth + 48, y: y, rise: rise, color: Art.color(hex), alpha: alpha)
    }

    /// Models a filled shape with the one light: warm on its upper left, indigo core shadow
    /// toward its lower right and, when `rim` is above zero, a thin warm edge on the lit side.
    /// Call it straight after filling the shape. The rim costs one layer: use it sparingly.
    static func model(_ context: inout GraphicsContext, _ shape: Path, light: Double, shade: Double, rim: Double = 0) {
        let bounds = shape.boundingRect
        ArtStyle.form(&context, shape, bounds: bounds, light: light, shade: shade)
        if rim > 0 {
            ArtStyle.rimEdge(&context, shape, bounds: bounds, width: 1.2, alpha: rim)
        }
    }

    /// A long, low evening cloud: a flat underside and a softly humped top, `width` wide and
    /// `height` tall, starting at its left tip (`x`, `y`).
    static func cloudBand(_ x: CGFloat, _ y: CGFloat, width w: CGFloat, height h: CGFloat) -> Path {
        var path = Path()
        path.move(to: pt(x, y))
        path.addCurve(to: pt(x + w * 0.34, y - h * 0.7), control1: pt(x + w * 0.1, y - h * 0.1), control2: pt(x + w * 0.2, y - h * 0.8))
        path.addCurve(to: pt(x + w * 0.62, y - h), control1: pt(x + w * 0.42, y - h * 0.6), control2: pt(x + w * 0.5, y - h * 1.15))
        path.addCurve(to: pt(x + w, y), control1: pt(x + w * 0.8, y - h * 0.8), control2: pt(x + w * 0.9, y - h * 0.1))
        path.addQuadCurve(to: pt(x, y), control: pt(x + w * 0.5, y + h * 0.35))
        path.closeSubpath()
        return path
    }

    /// One almond leaf growing from (`x`, `y`) along `angle` (radians).
    static func leaf(_ x: CGFloat, _ y: CGFloat, length: CGFloat, width: CGFloat, angle: CGFloat) -> Path {
        let dx: CGFloat = cos(angle)
        let dy: CGFloat = sin(angle)
        let tip = pt(x + dx * length, y + dy * length)
        let mx: CGFloat = x + dx * length * 0.45
        let my: CGFloat = y + dy * length * 0.45
        var path = Path()
        path.move(to: pt(x, y))
        path.addQuadCurve(to: tip, control: pt(mx - dy * width, my + dx * width))
        path.addQuadCurve(to: pt(x, y), control: pt(mx + dy * width, my - dx * width))
        path.closeSubpath()
        return path
    }

    /// The near plane of a garden or forest picture: a dark spray of leaves hanging in from the
    /// top-right corner (the close button is top left), each with a sliver of the key light.
    static func cornerSpray(_ context: inout GraphicsContext, seed: UInt32, dark: Color, lit: Color) {
        var random = ArtRandom(seed)
        let twigs = Art.svg("M446,-6 C420,10 396,14 368,34 M446,22 C426,30 410,40 394,62")
        Art.stroke(&context, twigs, dark, width: ArtStyle.contourLine)
        let anchors: [(CGFloat, CGFloat)] = [
            (432, 2), (418, 9), (404, 14), (390, 21), (378, 28), (368, 34),
            (436, 26), (422, 32), (410, 40), (400, 52), (394, 62),
        ]
        var leaves = Path()
        var glints = Path()
        for anchor in anchors {
            for side in 0..<2 {
                // One leaf hangs down, one reaches out to the left.
                let base: CGFloat = side == 0 ? 1.9 : 2.8
                let angle: CGFloat = base + random.next(in: -0.35...0.35)
                let length: CGFloat = random.next(in: 14...22)
                leaves.addPath(leaf(anchor.0, anchor.1, length: length, width: length * 0.3, angle: angle))
                if side == 1 {
                    glints.addPath(leaf(anchor.0 - 1, anchor.1 - 0.6, length: length * 0.8, width: length * 0.09, angle: angle + 0.1))
                }
            }
        }
        Art.fill(&context, leaves, dark)
        Art.fill(&context, glints, lit)
    }

    /// The veil of sky colour that pushes the far plane back (art direction §3), across the
    /// whole picture between `top` and `bottom`.
    static func haze(_ context: inout GraphicsContext, top: CGFloat, bottom: CGFloat, hex: UInt32, alpha: Double) {
        var wide = context
        wide.translateBy(x: -24, y: 0)
        ArtStyle.atmosphere(&wide, width: unitWidth + 48, top: top, bottom: bottom, color: Art.color(hex), alpha: alpha)
    }

    /// The last pass of every landmark picture: the shared warm wash and soft vignette.
    static func finish(_ context: inout GraphicsContext, wash: Double, vignette: Double) {
        ArtStyle.finish(&context, CGSize(width: unitWidth, height: unitHeight), wash: wash, vignette: vignette)
    }
}
