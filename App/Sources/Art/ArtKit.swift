import SwiftUI
import UIKit
import OmramoCore

// Shared drawing kit for the concept illustrations that are drawn in code.
//
// The pictures are our own (ported and extended from the locked design sources in
// docs/design/source/src/lib/art-*.js). They are concept art, not final art: every `review.art`
// field stays `pending`, and a real image file dropped at the path the content names replaces
// the drawing with no code change (see `StoryArt`, and Content/ART_PLACEHOLDERS.md).
//
// A painter never knows the size of the screen. `ArtCanvas` scales the drawing context so that
// a painter always works in the coordinate space of its role (see `ArtRole`).

/// What a picture is for. The role fixes the coordinate space a painter draws in.
enum ArtRole: Hashable {
    /// One scene under both panes and the hinge. Width is always 892 units: the leading pane is
    /// x 0…432, the hinge strip 432…460, the trailing pane 460…892. Height varies with the
    /// window (720 on the reference Duo; about 520…1300 on iPad windows), so a painter anchors
    /// ground and water to the bottom edge, canopies and sky to the top, and lets the sky
    /// between them stretch.
    case sceneUnfolded
    /// The picture band at the top of a single pane. Width is always 432 units; height is
    /// about 340 (240…440). The caller cuts the wave edge along the bottom.
    case sceneFolded
    /// A tap-to-see or landmark picture: 432 × 404 units. The caller fades the bottom quarter
    /// into the card's background colour.
    case picture
    /// A character-card portrait: 432 × 400 units.
    case portrait
    /// A face chip or avatar: 100 × 100 units; the caller clips it to a circle.
    case face
    /// A cover. Width is always 300 units; height varies from about 150 (the wide
    /// "Keep reading" card) to 375 (a tall cover), so the subject sits around the middle.
    case cover

    /// The fixed width of the role's coordinate space.
    var unitWidth: CGFloat {
        switch self {
        case .sceneUnfolded: return 892
        case .sceneFolded, .picture, .portrait: return 432
        case .face: return 100
        case .cover: return 300
        }
    }
}

/// A function that draws one named picture. `size` is in the role's units (see `ArtRole`).
/// Returns false when it does not know the name, so the caller can fall back.
typealias ArtPainter = (_ name: String, _ role: ArtRole, _ context: inout GraphicsContext, _ size: CGSize) -> Bool

// MARK: - Deterministic random numbers

/// The seeded generator of the design source (`rng` in base.js), so procedural details
/// (leaves, ripples, fireflies) are the same on every draw and match the designs.
struct ArtRandom {
    private var state: UInt32

    init(_ seed: UInt32) {
        state = seed
    }

    /// The next value in 0..<1.
    mutating func next() -> Double {
        state = state &+ 0x6D2B79F5
        var t = (state ^ (state >> 15)) &* (1 | state)
        t = (t &+ ((t ^ (t >> 7)) &* (61 | t))) ^ t
        return Double(t ^ (t >> 14)) / 4294967296
    }

    /// The next value in `range`.
    mutating func next(in range: ClosedRange<Double>) -> CGFloat {
        CGFloat(range.lowerBound + (range.upperBound - range.lowerBound) * next())
    }
}

// MARK: - Helpers

/// Small drawing helpers. Every painter uses these instead of calling `GraphicsContext`
/// in its own way, so the art files read alike.
enum Art {
    // Colours

    /// `Art.color(0x16695A)` or `Art.color(0xFFFFFF, 0.5)`.
    static func color(_ hex: UInt32, _ alpha: Double = 1) -> Color {
        Color(rgba: RGBA(hex: hex, alpha: alpha))
    }

    /// A content colour string (`#RRGGBB` / `#RRGGBBAA`), or `fallback` when it does not parse.
    static func color(string: String, fallback: UInt32) -> Color {
        Color(rgba: RGBA(string: string) ?? RGBA(hex: fallback))
    }

    // Shapes

    static func circle(_ cx: CGFloat, _ cy: CGFloat, _ r: CGFloat) -> Path {
        Path(ellipseIn: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2))
    }

    static func ellipse(_ cx: CGFloat, _ cy: CGFloat, _ rx: CGFloat, _ ry: CGFloat) -> Path {
        Path(ellipseIn: CGRect(x: cx - rx, y: cy - ry, width: rx * 2, height: ry * 2))
    }

    static func rect(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat, radius: CGFloat = 0) -> Path {
        let rect = CGRect(x: x, y: y, width: w, height: h)
        if radius <= 0 {
            return Path(rect)
        }
        return Path(roundedRect: rect, cornerRadius: min(radius, min(abs(w), abs(h)) / 2), style: .continuous)
    }

    static func line(_ x0: CGFloat, _ y0: CGFloat, _ x1: CGFloat, _ y1: CGFloat) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: x0, y: y0))
        path.addLine(to: CGPoint(x: x1, y: y1))
        return path
    }

    static func polygon(_ points: [CGPoint], closed: Bool = true) -> Path {
        var path = Path()
        guard let first = points.first else { return path }
        path.move(to: first)
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        if closed {
            path.closeSubpath()
        }
        return path
    }

    /// A path from SVG path data, as written in the design sources. Supports the commands
    /// M L H V C S Q T Z in absolute and relative form. Arcs (A) are not supported: use
    /// `circle` / `ellipse` instead.
    static func svg(_ data: String) -> Path {
        SVGPathBuilder.path(from: data)
    }

    /// A four-point spark (the tap-word spark and the "motes" of the designs), centred.
    static func spark(_ cx: CGFloat, _ cy: CGFloat, _ r: CGFloat) -> Path {
        let unit: [(CGFloat, CGFloat)] = [
            (0, -1), (0.24, -0.24), (1, 0), (0.24, 0.24), (0, 1), (-0.24, 0.24), (-1, 0), (-0.24, -0.24),
        ]
        return polygon(unit.map { CGPoint(x: cx + $0.0 * r, y: cy + $0.1 * r) })
    }

    // Filling and stroking

    static func fill(_ context: inout GraphicsContext, _ path: Path, _ color: Color) {
        context.fill(path, with: .color(color))
    }

    /// Fills with a straight gradient. `stops` are (colour, location 0…1) pairs.
    static func fillLinear(
        _ context: inout GraphicsContext,
        _ path: Path,
        _ stops: [(Color, CGFloat)],
        from start: CGPoint,
        to end: CGPoint
    ) {
        let gradient = Gradient(stops: stops.map { Gradient.Stop(color: $0.0, location: $0.1) })
        context.fill(path, with: .linearGradient(gradient, startPoint: start, endPoint: end))
    }

    /// Fills with a round gradient from `center` out to `radius`.
    static func fillRadial(
        _ context: inout GraphicsContext,
        _ path: Path,
        _ stops: [(Color, CGFloat)],
        center: CGPoint,
        radius: CGFloat
    ) {
        let gradient = Gradient(stops: stops.map { Gradient.Stop(color: $0.0, location: $0.1) })
        context.fill(path, with: .radialGradient(gradient, center: center, startRadius: 0, endRadius: radius))
    }

    static func stroke(
        _ context: inout GraphicsContext,
        _ path: Path,
        _ color: Color,
        width: CGFloat,
        cap: CGLineCap = .round,
        join: CGLineJoin = .round,
        dash: [CGFloat] = []
    ) {
        context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: width, lineCap: cap, lineJoin: join, dash: dash))
    }

    /// A soft round glow: `color` at `alpha` in the middle, fading to nothing at `radius`.
    static func glow(_ context: inout GraphicsContext, _ cx: CGFloat, _ cy: CGFloat, _ radius: CGFloat, _ color: Color, alpha: Double = 1) {
        fillRadial(
            &context,
            circle(cx, cy, radius),
            [(color.opacity(alpha), 0), (color.opacity(alpha * 0.45), 0.5), (color.opacity(0), 1)],
            center: CGPoint(x: cx, y: cy),
            radius: radius
        )
    }

    // Groups

    /// Draws `body` moved, turned (radians), scaled and faded, like an SVG `<g transform>`.
    /// Order: translate, then rotate, then scale. Nothing leaks out to `context`.
    static func group(
        _ context: inout GraphicsContext,
        x: CGFloat = 0,
        y: CGFloat = 0,
        rotate: CGFloat = 0,
        scale: CGFloat = 1,
        scaleX: CGFloat = 1,
        opacity: Double = 1,
        _ body: (inout GraphicsContext) -> Void
    ) {
        var inner = context
        inner.translateBy(x: x, y: y)
        if rotate != 0 {
            inner.rotate(by: Angle(radians: Double(rotate)))
        }
        if scale != 1 || scaleX != 1 {
            // `scaleX: -1` mirrors the group left to right.
            inner.scaleBy(x: scale * scaleX, y: scale)
        }
        if opacity < 1 {
            inner.opacity = context.opacity * opacity
        }
        body(&inner)
    }

    /// Draws `body` only inside `path`.
    static func clipped(_ context: inout GraphicsContext, to path: Path, _ body: (inout GraphicsContext) -> Void) {
        var inner = context
        inner.clip(to: path)
        body(&inner)
    }

    /// Draws `body` blurred, as one layer (soft shadows, haze, light).
    static func blurred(_ context: inout GraphicsContext, radius: CGFloat, opacity: Double = 1, _ body: (inout GraphicsContext) -> Void) {
        var inner = context
        inner.opacity = context.opacity * opacity
        inner.addFilter(.blur(radius: radius))
        inner.drawLayer { layer in
            body(&layer)
        }
    }

    /// Draws `body` as one layer at `opacity`, so overlapping shapes inside do not show through
    /// each other.
    static func layer(_ context: inout GraphicsContext, opacity: Double, _ body: (inout GraphicsContext) -> Void) {
        var inner = context
        inner.opacity = context.opacity * opacity
        inner.drawLayer { layer in
            body(&layer)
        }
    }

    /// Paint tooth: small soft dots scattered over `rect`, so flat shapes do not look
    /// computer-flat. Cheap; use a few hundred dots at most.
    static func stipple(
        _ context: inout GraphicsContext,
        in rect: CGRect,
        count: Int,
        seed: UInt32,
        color: Color,
        alpha: Double = 0.08,
        size: ClosedRange<Double> = 0.5...1.6
    ) {
        var random = ArtRandom(seed)
        var dots = Path()
        for _ in 0..<max(0, count) {
            let x = rect.minX + rect.width * CGFloat(random.next())
            let y = rect.minY + rect.height * CGFloat(random.next())
            let r = random.next(in: size)
            dots.addEllipse(in: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2))
        }
        context.fill(dots, with: .color(color.opacity(alpha)))
    }
}

// MARK: - SVG path data

/// Turns SVG path data into a `Path`. Small and forgiving: unknown commands end the parse.
enum SVGPathBuilder {
    static func path(from data: String) -> Path {
        var path = Path()
        var scanner = Cursor(data)
        var current = CGPoint.zero
        var start = CGPoint.zero
        var lastControl: CGPoint?
        var lastCommand: Character = " "
        var command: Character = " "

        while true {
            scanner.skipSeparators()
            if scanner.isAtEnd { break }
            if let letter = scanner.letter() {
                command = letter
            } else if command == " " {
                break
            } else if command == "M" {
                command = "L"
            } else if command == "m" {
                command = "l"
            }
            let relative = command.isLowercase
            let base = relative ? current : CGPoint.zero

            switch command {
            case "M", "m":
                guard let p = scanner.point() else { return path }
                current = CGPoint(x: base.x + p.x, y: base.y + p.y)
                start = current
                path.move(to: current)
                lastControl = nil
            case "L", "l":
                guard let p = scanner.point() else { return path }
                current = CGPoint(x: base.x + p.x, y: base.y + p.y)
                path.addLine(to: current)
                lastControl = nil
            case "H", "h":
                guard let x = scanner.number() else { return path }
                current = CGPoint(x: (relative ? current.x : 0) + x, y: current.y)
                path.addLine(to: current)
                lastControl = nil
            case "V", "v":
                guard let y = scanner.number() else { return path }
                current = CGPoint(x: current.x, y: (relative ? current.y : 0) + y)
                path.addLine(to: current)
                lastControl = nil
            case "C", "c":
                guard let c1 = scanner.point(), let c2 = scanner.point(), let p = scanner.point() else { return path }
                let control1 = CGPoint(x: base.x + c1.x, y: base.y + c1.y)
                let control2 = CGPoint(x: base.x + c2.x, y: base.y + c2.y)
                current = CGPoint(x: base.x + p.x, y: base.y + p.y)
                path.addCurve(to: current, control1: control1, control2: control2)
                lastControl = control2
            case "S", "s":
                guard let c2 = scanner.point(), let p = scanner.point() else { return path }
                let previousWasCurve = "CcSs".contains(lastCommand)
                let control1 = reflect(previousWasCurve ? lastControl : nil, around: current)
                let control2 = CGPoint(x: base.x + c2.x, y: base.y + c2.y)
                current = CGPoint(x: base.x + p.x, y: base.y + p.y)
                path.addCurve(to: current, control1: control1, control2: control2)
                lastControl = control2
            case "Q", "q":
                guard let c = scanner.point(), let p = scanner.point() else { return path }
                let control = CGPoint(x: base.x + c.x, y: base.y + c.y)
                current = CGPoint(x: base.x + p.x, y: base.y + p.y)
                path.addQuadCurve(to: current, control: control)
                lastControl = control
            case "T", "t":
                guard let p = scanner.point() else { return path }
                let previousWasQuad = "QqTt".contains(lastCommand)
                let control = reflect(previousWasQuad ? lastControl : nil, around: current)
                current = CGPoint(x: base.x + p.x, y: base.y + p.y)
                path.addQuadCurve(to: current, control: control)
                lastControl = control
            case "Z", "z":
                path.closeSubpath()
                current = start
                lastControl = nil
                // A number after Z would loop for ever; a new command letter is required.
                lastCommand = command
                command = " "
                continue
            default:
                return path
            }
            lastCommand = command
        }
        return path
    }

    private static func reflect(_ control: CGPoint?, around point: CGPoint) -> CGPoint {
        guard let control else { return point }
        return CGPoint(x: 2 * point.x - control.x, y: 2 * point.y - control.y)
    }

    private struct Cursor {
        private let characters: [Character]
        private var index = 0

        init(_ text: String) {
            characters = Array(text)
        }

        var isAtEnd: Bool { index >= characters.count }

        mutating func skipSeparators() {
            while index < characters.count, characters[index] == " " || characters[index] == "," || characters[index].isNewline || characters[index] == "\t" {
                index += 1
            }
        }

        /// A command letter at the cursor, consumed. Nil when the cursor is at a number.
        mutating func letter() -> Character? {
            guard index < characters.count else { return nil }
            let character = characters[index]
            guard character.isLetter, character != "e", character != "E" else { return nil }
            index += 1
            return character
        }

        mutating func number() -> CGFloat? {
            skipSeparators()
            var text = ""
            var seenDot = false
            var seenDigit = false
            if index < characters.count, characters[index] == "-" || characters[index] == "+" {
                text.append(characters[index])
                index += 1
            }
            while index < characters.count {
                let character = characters[index]
                if character.isASCII, character.isNumber {
                    seenDigit = true
                } else if character == ".", !seenDot {
                    seenDot = true
                } else {
                    break
                }
                text.append(character)
                index += 1
            }
            guard seenDigit else { return nil }
            // ".5" and "-.5" are valid SVG numbers; give them their leading zero.
            if text.hasPrefix(".") {
                text = "0" + text
            } else if text.hasPrefix("-.") {
                text = "-0" + text.dropFirst()
            } else if text.hasPrefix("+") {
                text = String(text.dropFirst())
            }
            guard let value = Double(text) else { return nil }
            return CGFloat(value)
        }

        mutating func point() -> CGPoint? {
            guard let x = number(), let y = number() else { return nil }
            return CGPoint(x: x, y: y)
        }
    }
}

// MARK: - Canvas

/// Draws one named picture with a painter, scaled so the painter works in its role's units.
/// The drawing fills the view: the width maps to the role's unit width, and the height in units
/// follows from the view's shape.
struct ArtCanvas: View {
    let name: String
    let role: ArtRole
    let painter: ArtPainter
    /// Drawn when the painter does not know `name`.
    var fallback: Color = Art.color(0xE8E4FF)

    var body: some View {
        let name = self.name
        let role = self.role
        let painter = self.painter
        let fallback = self.fallback
        Canvas(rendersAsynchronously: false) { context, size in
            guard size.width > 0, size.height > 0 else { return }
            let scale = size.width / role.unitWidth
            let units = CGSize(width: role.unitWidth, height: size.height / scale)
            var scaled = context
            scaled.scaleBy(x: scale, y: scale)
            if !painter(name, role, &scaled, units) {
                context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(fallback))
            }
        }
    }
}

// MARK: - Grain

/// The film-grain overlay of the designs ("paint tooth"), as a small tiled noise image blended
/// in soft light. One image is made per process.
@MainActor
enum GrainTexture {
    private static var cached: UIImage?

    static var image: UIImage {
        if let cached { return cached }
        let side = 128
        var random = ArtRandom(7)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = false
        let made = UIGraphicsImageRenderer(size: CGSize(width: side, height: side), format: format).image { rendererContext in
            let cg = rendererContext.cgContext
            for y in 0..<side {
                for x in 0..<side {
                    let value = random.next()
                    // Mid-grey leaves soft light unchanged; lighter and darker specks push it.
                    let grey = CGFloat(0.5 + (value - 0.5) * 0.9)
                    cg.setFillColor(UIColor(white: grey, alpha: 0.55).cgColor)
                    cg.fill(CGRect(x: x, y: y, width: 1, height: 1))
                }
            }
        }
        cached = made
        return made
    }
}

/// Lays grain over a picture.
struct GrainOverlay: View {
    var opacity: Double = 0.35

    var body: some View {
        Image(uiImage: GrainTexture.image)
            .resizable(resizingMode: .tile)
            .blendMode(.softLight)
            .opacity(opacity)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}
