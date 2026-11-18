import SwiftUI
import OmramoCore

// The shared art direction, as code (docs/ART_DIRECTION.md).
//
// One warm light from the upper left, one indigo shadow tint, two line weights, one way to
// build a face, one horizon glow, one finish. The three stories keep their own palettes
// (`Ramp`), and draw with these helpers so they read as one app.
//
// Like the rest of `App/Sources/Art`, everything here is drawn in the units of the picture's
// role (see `ArtRole`), and is deterministic.

enum ArtStyle {
    // MARK: Light

    /// The one key light: low, warm, from the upper left. Never pure white.
    static let warmLightHex: UInt32 = 0xFFD9A0
    /// The one shadow tint: the brand's indigo, used at low alpha. Never black or grey.
    static let coolShadeHex: UInt32 = 0x2A2466

    static var warmLight: Color { Art.color(warmLightHex) }
    static var coolShade: Color { Art.color(coolShadeHex) }

    // MARK: Line (units of the 432-wide pane)

    /// Inner detail: a mouth, a fold, a wave crest.
    static let detailLine: CGFloat = 1.6
    /// The few contours that carry a shape.
    static let contourLine: CGFloat = 2.4

    // MARK: Palette ramps

    /// A story's own colours: deep → shade → mid → light → glow, and one accent. The glow step
    /// is always warm; that is what the three stories share.
    struct Ramp: Sendable {
        let deep: UInt32
        let shade: UInt32
        let mid: UInt32
        let light: UInt32
        let glow: UInt32
        let accent: UInt32

        var deepColor: Color { Art.color(deep) }
        var shadeColor: Color { Art.color(shade) }
        var midColor: Color { Art.color(mid) }
        var lightColor: Color { Art.color(light) }
        var glowColor: Color { Art.color(glow) }
        var accentColor: Color { Art.color(accent) }
    }

    /// The Monkey and the Crocodile: bright river morning.
    static let jataka = Ramp(deep: 0x0E5A6B, shade: 0x1F8F7A, mid: 0x2FB58A, light: 0xBFEFE4, glow: 0xFFF3B8, accent: 0xFF9F2E)
    /// How Wisdom Became the Property of the Human Race: dusk and lamplight.
    static let anansi = Ramp(deep: 0x1A1147, shade: 0x35206B, mid: 0x6A2F7A, light: 0xE2694F, glow: 0xFFC96B, accent: 0x2E9E5B)
    /// The Story of Urashima Taro: pale washes and a patterned sea.
    static let urashima = Ramp(deep: 0x1F4E96, shade: 0x3F7FC4, mid: 0x9CC9E6, light: 0xEEF4FB, glow: 0xFFE3D2, accent: 0xF4503F)

    // MARK: Shared passes

    /// The warm band every outdoor scene has at its horizon: strongest on the line, fading
    /// upward over `rise` units and a little way down over the water or ground.
    static func horizonGlow(
        _ context: inout GraphicsContext,
        width: CGFloat,
        y: CGFloat,
        rise: CGFloat,
        color: Color,
        alpha: Double = 0.5
    ) {
        let lift = max(1, rise)
        Art.fillLinear(
            &context,
            Art.rect(0, y - lift, width, lift),
            [(color.opacity(0), 0), (color.opacity(alpha * 0.45), 0.6), (color.opacity(alpha), 1)],
            from: CGPoint(x: 0, y: y - lift),
            to: CGPoint(x: 0, y: y)
        )
        let fall = lift * 0.22
        Art.fillLinear(
            &context,
            Art.rect(0, y, width, fall),
            [(color.opacity(alpha * 0.5), 0), (color.opacity(0), 1)],
            from: CGPoint(x: 0, y: y),
            to: CGPoint(x: 0, y: y + fall)
        )
    }

    /// The soft shadow under anything that stands or sits on something.
    static func contactShadow(
        _ context: inout GraphicsContext,
        _ cx: CGFloat,
        _ cy: CGFloat,
        _ rx: CGFloat,
        _ ry: CGFloat,
        alpha: Double = 0.22
    ) {
        let radius = max(rx, 1)
        var inner = context
        inner.translateBy(x: cx, y: cy)
        inner.scaleBy(x: 1, y: max(ry, 0.5) / radius)
        Art.fillRadial(
            &inner,
            Art.circle(0, 0, radius),
            [(coolShade.opacity(alpha), 0), (coolShade.opacity(alpha * 0.55), 0.55), (coolShade.opacity(0), 1)],
            center: .zero,
            radius: radius
        )
    }

    /// A rim of warm light on the upper-left side of a round form (a head, a pot, a shell).
    static func rimLight(
        _ context: inout GraphicsContext,
        _ cx: CGFloat,
        _ cy: CGFloat,
        _ r: CGFloat,
        alpha: Double = 0.35
    ) {
        let shape = Art.circle(cx, cy, r)
        Art.clipped(&context, to: shape) { inner in
            Art.fillRadial(
                &inner,
                Art.circle(cx - r * 0.45, cy - r * 0.5, r * 1.1),
                [(warmLight.opacity(alpha), 0), (warmLight.opacity(alpha * 0.3), 0.55), (warmLight.opacity(0), 1)],
                center: CGPoint(x: cx - r * 0.45, y: cy - r * 0.5),
                radius: r * 1.1
            )
        }
    }

    // MARK: Form and depth (round 4)

    /// Models any flat shape with the one light: a warm rim on its upper-left side and an
    /// indigo core shadow toward its lower right, both clipped to the shape. `bounds` is the
    /// shape's rough bounding box. Call it straight after filling the shape.
    static func form(
        _ context: inout GraphicsContext,
        _ shape: Path,
        bounds: CGRect,
        light: Double = 0.28,
        shade: Double = 0.22
    ) {
        guard bounds.width > 0, bounds.height > 0 else { return }
        let reach = max(bounds.width, bounds.height)
        Art.clipped(&context, to: shape) { inner in
            if shade > 0 {
                let from = CGPoint(x: bounds.midX, y: bounds.midY)
                let to = CGPoint(x: bounds.maxX, y: bounds.maxY)
                Art.fillLinear(
                    &inner,
                    Path(bounds),
                    [(coolShade.opacity(0), 0), (coolShade.opacity(shade * 0.5), 0.55), (coolShade.opacity(shade), 1)],
                    from: from,
                    to: to
                )
            }
            if light > 0 {
                let center = CGPoint(x: bounds.minX + bounds.width * 0.18, y: bounds.minY + bounds.height * 0.12)
                Art.fillRadial(
                    &inner,
                    Path(bounds),
                    [(warmLight.opacity(light), 0), (warmLight.opacity(light * 0.35), 0.5), (warmLight.opacity(0), 1)],
                    center: center,
                    radius: reach * 0.75
                )
            }
        }
    }

    /// A thin warm edge of light along the upper-left contour of a shape: the shape's own
    /// outline stroked in the key light, kept only inside the shape and only on the lit side.
    static func rimEdge(
        _ context: inout GraphicsContext,
        _ shape: Path,
        bounds: CGRect,
        width: CGFloat = 3,
        alpha: Double = 0.5
    ) {
        guard bounds.width > 0, bounds.height > 0 else { return }
        Art.clipped(&context, to: shape) { inner in
            // Only the upper-left half is lit: mask the stroke with a diagonal gradient.
            var lit = inner
            lit.clipToLayer { mask in
                Art.fillLinear(
                    &mask,
                    Path(bounds.insetBy(dx: -width * 2, dy: -width * 2)),
                    [(Color.white, 0), (Color.white.opacity(0.5), 0.4), (Color.white.opacity(0), 0.62)],
                    from: CGPoint(x: bounds.minX, y: bounds.minY),
                    to: CGPoint(x: bounds.maxX, y: bounds.maxY)
                )
            }
            Art.stroke(&lit, shape, warmLight.opacity(alpha), width: width * 2)
        }
    }

    /// Atmospheric perspective: a veil of the sky's own colour over everything drawn so far
    /// between `top` and `bottom`. Draw the far plane, veil it, then draw the middle plane, so
    /// distance reads as paler and closer in value to the sky.
    static func atmosphere(
        _ context: inout GraphicsContext,
        width: CGFloat,
        top: CGFloat,
        bottom: CGFloat,
        color: Color,
        alpha: Double = 0.35
    ) {
        guard bottom > top else { return }
        Art.fillLinear(
            &context,
            Art.rect(0, top, width, bottom - top),
            [(color.opacity(alpha * 0.4), 0), (color.opacity(alpha), 0.7), (color.opacity(alpha * 0.6), 1)],
            from: CGPoint(x: 0, y: top),
            to: CGPoint(x: 0, y: bottom)
        )
    }

    /// The shared stipple ("paint tooth") for large flat areas: the same density and dot size
    /// in every story. About one dot for every 260 square units, capped.
    static func tooth(
        _ context: inout GraphicsContext,
        in rect: CGRect,
        seed: UInt32,
        color: Color = Color.white,
        alpha: Double = 0.07
    ) {
        guard rect.width > 0, rect.height > 0 else { return }
        let wanted = Int(rect.width * rect.height / 260)
        Art.stipple(&context, in: rect, count: min(420, max(24, wanted)), seed: seed, color: color, alpha: alpha, size: 0.5...1.5)
    }

    /// The last pass of every scene, picture, portrait and cover: a faint warm wash from the
    /// upper left (the key light) and a soft indigo vignette toward the lower-right corner.
    /// `strength` 1 is the default; a dark scene uses less wash, a pale one less vignette.
    static func finish(
        _ context: inout GraphicsContext,
        _ size: CGSize,
        wash: Double = 0.10,
        vignette: Double = 0.10
    ) {
        guard size.width > 0, size.height > 0 else { return }
        let full = Art.rect(0, 0, size.width, size.height)
        let reach = max(size.width, size.height)
        if wash > 0 {
            Art.fillRadial(
                &context,
                full,
                [(warmLight.opacity(wash), 0), (warmLight.opacity(wash * 0.35), 0.5), (warmLight.opacity(0), 1)],
                center: CGPoint(x: size.width * 0.12, y: size.height * 0.08),
                radius: reach * 0.85
            )
        }
        if vignette > 0 {
            Art.fillRadial(
                &context,
                full,
                [(coolShade.opacity(0), 0), (coolShade.opacity(0), 0.62), (coolShade.opacity(vignette), 1)],
                center: CGPoint(x: size.width * 0.42, y: size.height * 0.4),
                radius: reach * 0.95
            )
        }
    }

    // MARK: Faces

    /// The one eye of the app: round, a dark iris, one catchlight on the upper left.
    ///
    /// - Parameters:
    ///   - r: radius of the whole eye.
    ///   - look: where the iris sits inside the eye, −1…1 on each axis (0, 0 looks at the reader).
    ///   - showsWhite: true for the large, friendly eye of the Low story; false for the plain
    ///     dark eye of the older tiers (the same construction, smaller and calmer).
    static func eye(
        _ context: inout GraphicsContext,
        _ cx: CGFloat,
        _ cy: CGFloat,
        _ r: CGFloat,
        look: CGPoint = .zero,
        iris: Color = Art.color(0x2A1A12),
        showsWhite: Bool = true
    ) {
        let lookX = min(1, max(-1, look.x))
        let lookY = min(1, max(-1, look.y))
        if showsWhite {
            Art.fill(&context, Art.circle(cx, cy, r), Color.white)
            let irisRadius = r * 0.62
            let ix = cx + lookX * (r - irisRadius) * 0.9
            let iy = cy + lookY * (r - irisRadius) * 0.9
            Art.fill(&context, Art.circle(ix, iy, irisRadius), iris)
            Art.fill(&context, Art.circle(ix - irisRadius * 0.34, iy - irisRadius * 0.38, irisRadius * 0.34), Color.white)
            Art.fill(&context, Art.circle(ix + irisRadius * 0.3, iy + irisRadius * 0.34, irisRadius * 0.14), Color.white.opacity(0.7))
        } else {
            let ix = cx + lookX * r * 0.18
            let iy = cy + lookY * r * 0.18
            Art.fill(&context, Art.circle(ix, iy, r), iris)
            Art.fill(&context, Art.circle(ix - r * 0.32, iy - r * 0.36, r * 0.3), Color.white.opacity(0.92))
        }
    }

    /// The soft warm blush of every face. Quieter on the older tiers (`alpha` about 0.3).
    static func cheek(
        _ context: inout GraphicsContext,
        _ cx: CGFloat,
        _ cy: CGFloat,
        _ r: CGFloat,
        color: Color = Art.color(0xFF8A6B),
        alpha: Double = 0.5
    ) {
        Art.glow(&context, cx, cy, r, color, alpha: alpha)
    }

    /// A mouth: one round-capped curve. `curve` is how far the middle dips below the ends
    /// (positive smiles; 0 is a level mouth).
    static func smile(
        _ context: inout GraphicsContext,
        _ cx: CGFloat,
        _ cy: CGFloat,
        width: CGFloat,
        curve: CGFloat,
        color: Color,
        lineWidth: CGFloat = ArtStyle.detailLine
    ) {
        var path = Path()
        path.move(to: CGPoint(x: cx - width / 2, y: cy))
        path.addQuadCurve(to: CGPoint(x: cx + width / 2, y: cy), control: CGPoint(x: cx, y: cy + curve * 2))
        Art.stroke(&context, path, color, width: lineWidth)
    }

    // MARK: Framing

    /// What stands behind a character on a portrait: the card's own two colours, top to bottom,
    /// a soft halo behind the head, and — for the Low tier only — quiet rays (screen 07).
    static func portraitBackdrop(
        _ context: inout GraphicsContext,
        _ size: CGSize,
        top: Color,
        bottom: Color,
        halo: Color,
        rays: Bool
    ) {
        let w = size.width
        let h = size.height
        Art.fillLinear(
            &context,
            Art.rect(0, 0, w, h),
            [(top, 0), (bottom, 1)],
            from: CGPoint(x: 0, y: 0),
            to: CGPoint(x: 0, y: h)
        )
        let cx = w * 0.5
        let cy = h * 0.42
        if rays {
            let count = 14
            let reach = max(w, h) * 1.1
            var fan = Path()
            for index in 0..<count {
                let a0 = (CGFloat(index) / CGFloat(count)) * 2 * CGFloat.pi
                let a1 = a0 + CGFloat.pi / CGFloat(count) * 0.9
                fan.move(to: CGPoint(x: cx, y: cy))
                fan.addLine(to: CGPoint(x: cx + cos(a0) * reach, y: cy + sin(a0) * reach))
                fan.addLine(to: CGPoint(x: cx + cos(a1) * reach, y: cy + sin(a1) * reach))
                fan.closeSubpath()
            }
            Art.fill(&context, fan, halo.opacity(0.16))
        }
        Art.glow(&context, cx, cy, min(w, h) * 0.62, halo, alpha: 0.55)
    }
}
