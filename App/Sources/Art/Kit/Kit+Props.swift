import SwiftUI
import OmramoCore

// The shared illustration kit: props, boats and small objects (round 5).
//
// Everything here is drawn in the units of the picture it is placed in, lit from the upper
// left (`Kit.solid`), with a contact shadow where it stands on the ground. Boats float: they
// get a short reflection instead. Helper names start with `prop`.

// MARK: - Tones and small helpers

extension Kit {
    /// Lighter (k > 1) or darker (k < 1) tone of a hex colour.
    static func propTone(_ hex: UInt32, _ k: CGFloat) -> Color {
        Art.color(propToneHex(hex, k))
    }

    /// The hex value behind `propTone`: each RGB component scaled by `k`, clamped to 0…255.
    static func propToneHex(_ hex: UInt32, _ k: CGFloat) -> UInt32 {
        let r: CGFloat = CGFloat((hex >> 16) & 0xFF) * k
        let g: CGFloat = CGFloat((hex >> 8) & 0xFF) * k
        let b: CGFloat = CGFloat(hex & 0xFF) * k
        let r8: UInt32 = UInt32(min(255, max(0, r)).rounded())
        let g8: UInt32 = UInt32(min(255, max(0, g)).rounded())
        let b8: UInt32 = UInt32(min(255, max(0, b)).rounded())
        return (r8 << 16) | (g8 << 8) | b8
    }

    /// A wooden shaft (a handle, a mast, a pole): a round-ended stroke with a thin lit side.
    static func propShaft(
        _ context: inout GraphicsContext,
        _ x0: CGFloat,
        _ y0: CGFloat,
        _ x1: CGFloat,
        _ y1: CGFloat,
        wood: UInt32,
        width: CGFloat
    ) {
        Art.stroke(&context, Art.line(x0, y0, x1, y1), Art.color(wood), width: width)
        let off: CGFloat = width * 0.24
        let lit = Art.line(x0 - off, y0 - off, x1 - off, y1 - off)
        Art.stroke(&context, lit, propTone(wood, 1.4).opacity(0.6), width: max(0.6, width * 0.3))
    }

    /// A flame tongue: a leaf shape standing on (x, baseY), `w` wide and `h` tall, its tip
    /// leaning `lean` units to the right.
    static func propFlame(_ x: CGFloat, _ baseY: CGFloat, _ w: CGFloat, _ h: CGFloat, _ lean: CGFloat) -> Path {
        let tipX: CGFloat = x + lean
        let tipY: CGFloat = baseY - h
        var path = Path()
        path.move(to: CGPoint(x: x - w / 2, y: baseY))
        path.addCurve(
            to: CGPoint(x: tipX, y: tipY),
            control1: CGPoint(x: x - w * 0.7, y: baseY - h * 0.45),
            control2: CGPoint(x: tipX - w * 0.1, y: baseY - h * 0.7)
        )
        path.addCurve(
            to: CGPoint(x: x + w / 2, y: baseY),
            control1: CGPoint(x: tipX + w * 0.25, y: baseY - h * 0.6),
            control2: CGPoint(x: x + w * 0.75, y: baseY - h * 0.3)
        )
        path.addQuadCurve(to: CGPoint(x: x - w / 2, y: baseY), control: CGPoint(x: x, y: baseY + w * 0.25))
        path.closeSubpath()
        return path
    }
}

// MARK: - Boats

extension Kit {
    enum BoatStyle: Sendable { case rowing, nile, dhow, junk, canoe }

    /// A boat seen from the side floating with its waterline at waterY, the hull `length` long,
    /// centred on cx, bow to the LEFT. `sail` nil = no sail (rowing and canoe never have one;
    /// the others then show a bare mast). Draws the hull (planks, a lit gunwale), mast and sail
    /// (full and rounded, with seam lines and a little shade), and a short soft reflection
    /// under the hull.
    static func boat(
        _ context: inout GraphicsContext,
        cx: CGFloat,
        waterY: CGFloat,
        length: CGFloat,
        hull: UInt32,
        sail: UInt32? = nil,
        style: BoatStyle = .rowing
    ) {
        let L: CGFloat = max(8, length)
        let dark = propTone(hull, 0.55)
        Art.fill(&context, Art.ellipse(cx + L * 0.02, waterY + L * 0.05, L * 0.46, L * 0.034), dark.opacity(0.3))
        switch style {
        case .nile:
            propRigNile(&context, cx: cx, waterY: waterY, L: L, hull: hull, sail: sail)
        case .dhow:
            propRigDhow(&context, cx: cx, waterY: waterY, L: L, hull: hull, sail: sail)
        case .junk:
            propRigJunk(&context, cx: cx, waterY: waterY, L: L, hull: hull, sail: sail)
        case .rowing, .canoe:
            break
        }
        propHull(&context, style, cx: cx, waterY: waterY, L: L, hull: hull)
        propBoatFittings(&context, style, cx: cx, waterY: waterY, L: L, hull: hull)
        // The waterline: a pale line over the hull's foot and two short ripples beside it.
        let wy: CGFloat = waterY + L * 0.03
        var marks = Path()
        marks.move(to: CGPoint(x: cx - L * 0.4, y: wy))
        marks.addQuadCurve(to: CGPoint(x: cx + L * 0.4, y: wy), control: CGPoint(x: cx, y: wy + L * 0.012))
        marks.move(to: CGPoint(x: cx - L * 0.6, y: wy + L * 0.03))
        marks.addLine(to: CGPoint(x: cx - L * 0.44, y: wy + L * 0.03))
        marks.move(to: CGPoint(x: cx + L * 0.3, y: wy + L * 0.055))
        marks.addLine(to: CGPoint(x: cx + L * 0.56, y: wy + L * 0.055))
        Art.stroke(&context, marks, Color.white.opacity(0.5), width: max(1, L * 0.012))
    }

    /// The side silhouette of a hull, bow to the left. Unit space: x in hull lengths from the
    /// middle, y in hull lengths from the waterline (up is negative).
    static func propHullPath(_ style: BoatStyle, cx: CGFloat, waterY: CGFloat, L: CGFloat) -> Path {
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: cx + x * L, y: waterY + y * L)
        }
        var path = Path()
        switch style {
        case .rowing:
            path.move(to: p(-0.5, -0.15))
            path.addQuadCurve(to: p(0.5, -0.13), control: p(0, -0.06))
            path.addQuadCurve(to: p(0.36, 0.03), control: p(0.47, 0))
            path.addLine(to: p(-0.34, 0.03))
            path.addQuadCurve(to: p(-0.5, -0.15), control: p(-0.46, 0))
        case .nile:
            path.move(to: p(-0.5, -0.28))
            path.addCurve(to: p(0.5, -0.32), control1: p(-0.3, 0.02), control2: p(0.3, 0.02))
            path.addCurve(to: p(-0.5, -0.28), control1: p(0.36, 0.16), control2: p(-0.36, 0.16))
        case .dhow:
            path.move(to: p(-0.56, -0.17))
            path.addQuadCurve(to: p(0.42, -0.13), control: p(0, -0.07))
            path.addLine(to: p(0.5, -0.2))
            path.addQuadCurve(to: p(0.3, 0.035), control: p(0.47, 0.03))
            path.addLine(to: p(-0.25, 0.035))
            path.addQuadCurve(to: p(-0.56, -0.17), control: p(-0.42, 0.02))
        case .junk:
            path.move(to: p(-0.5, -0.18))
            path.addQuadCurve(to: p(0.3, -0.12), control: p(-0.1, -0.06))
            path.addLine(to: p(0.34, -0.24))
            path.addLine(to: p(0.52, -0.27))
            path.addQuadCurve(to: p(0.38, 0.035), control: p(0.5, -0.02))
            path.addLine(to: p(-0.32, 0.035))
            path.addQuadCurve(to: p(-0.46, -0.06), control: p(-0.42, 0.03))
            path.addLine(to: p(-0.5, -0.18))
        case .canoe:
            path.move(to: p(-0.52, -0.085))
            path.addQuadCurve(to: p(0.52, -0.085), control: p(0, -0.03))
            path.addQuadCurve(to: p(0.3, 0.025), control: p(0.44, 0.02))
            path.addLine(to: p(-0.3, 0.025))
            path.addQuadCurve(to: p(-0.52, -0.085), control: p(-0.44, 0.02))
        }
        path.closeSubpath()
        return path
    }

    /// The hull: a lit gunwale along the sheer, the body, two plank lines, light and shade.
    static func propHull(_ context: inout GraphicsContext, _ style: BoatStyle, cx: CGFloat, waterY: CGFloat, L: CGFloat, hull: UInt32) {
        let shape = propHullPath(style, cx: cx, waterY: waterY, L: L)
        let band: CGFloat = L * 0.026
        let body = shape.applying(CGAffineTransform(translationX: 0, y: band))
        var planks = Path()
        planks.addPath(shape.applying(CGAffineTransform(translationX: 0, y: band + L * 0.04)))
        planks.addPath(shape.applying(CGAffineTransform(translationX: 0, y: band + L * 0.08)))
        let lw: CGFloat = min(ArtStyle.detailLine, max(0.8, L * 0.012))
        Art.fill(&context, shape, propTone(hull, 1.35))
        Art.clipped(&context, to: shape) { g in
            Art.fill(&g, body, Art.color(hull))
            Art.stroke(&g, planks, propTone(hull, 0.68).opacity(0.75), width: lw)
        }
        Kit.model(&context, shape, light: 0.22, shade: 0.28)
    }

    /// What sits on a hull: an oar, a steering oar, rope bindings, a stern band.
    static func propBoatFittings(_ context: inout GraphicsContext, _ style: BoatStyle, cx: CGFloat, waterY: CGFloat, L: CGFloat, hull: UInt32) {
        let lw: CGFloat = max(1, L * 0.016)
        let woodHex: UInt32 = propToneHex(hull, 0.62)
        var ties: [CGFloat] = []
        switch style {
        case .rowing:
            propShaft(&context, cx + L * 0.02, waterY - L * 0.14, cx + L * 0.22, waterY - L * 0.005, wood: woodHex, width: lw)
            let blade = Art.line(cx + L * 0.2, waterY - L * 0.02, cx + L * 0.27, waterY + L * 0.028)
            Art.stroke(&context, blade, propTone(hull, 0.8), width: lw * 2.4)
            Art.fill(&context, Art.circle(cx + L * 0.03, waterY - L * 0.125, lw * 0.9), propTone(hull, 0.5))
            ties = [-0.41]
        case .nile:
            propShaft(&context, cx + L * 0.33, waterY - L * 0.3, cx + L * 0.46, waterY + L * 0.01, wood: woodHex, width: lw)
            let blade = Art.line(cx + L * 0.43, waterY - L * 0.06, cx + L * 0.47, waterY + L * 0.03)
            Art.stroke(&context, blade, propTone(hull, 0.75), width: lw * 2.4)
            var tufts = Path()
            tufts.addPath(Art.ellipse(cx - L * 0.505, waterY - L * 0.295, L * 0.022, L * 0.03))
            tufts.addPath(Art.ellipse(cx + L * 0.505, waterY - L * 0.335, L * 0.022, L * 0.03))
            Art.fill(&context, tufts, propTone(hull, 1.3))
            ties = [-0.44, -0.38, -0.32, 0.32, 0.38, 0.44]
        case .dhow, .junk:
            ties = [0.4, 0.44]
        case .canoe:
            ties = [-0.42, -0.38, 0.38, 0.42]
        }
        var bands = Path()
        for tie in ties {
            let x: CGFloat = cx + tie * L
            bands.move(to: CGPoint(x: x, y: waterY - L * 0.36))
            bands.addLine(to: CGPoint(x: x, y: waterY + L * 0.1))
        }
        let shape = propHullPath(style, cx: cx, waterY: waterY, L: L)
        Art.clipped(&context, to: shape) { g in
            Art.stroke(&g, bands, propTone(hull, 1.5).opacity(0.7), width: lw * 0.8, cap: .butt)
        }
    }

    /// A sail: the cloth modelled by the light, its seams in a darker tone, kept inside it.
    static func propCloth(_ context: inout GraphicsContext, _ cloth: Path, seams: Path, sail: UInt32, lineWidth: CGFloat) {
        Kit.solid(&context, cloth, Art.color(sail), light: 0.3, shade: 0.24, rim: 0)
        Art.clipped(&context, to: cloth) { g in
            Art.stroke(&g, seams, propTone(sail, 0.74).opacity(0.75), width: lineWidth)
        }
    }

    /// The Nile boat's rig: a central mast, two stays, a yard and one wide square sail.
    static func propRigNile(_ context: inout GraphicsContext, cx: CGFloat, waterY: CGFloat, L: CGFloat, hull: UInt32, sail: UInt32?) {
        let woodHex: UInt32 = propToneHex(hull, 0.62)
        let lw: CGFloat = max(1.2, L * 0.018)
        let mastTop: CGFloat = waterY - L * 0.68
        let yardY: CGFloat = waterY - L * 0.61
        let footY: CGFloat = waterY - L * 0.24
        let midY: CGFloat = (yardY + footY) / 2
        let half: CGFloat = L * 0.31
        var stays = Path()
        stays.move(to: CGPoint(x: cx, y: mastTop))
        stays.addLine(to: CGPoint(x: cx - L * 0.42, y: waterY - L * 0.17))
        stays.move(to: CGPoint(x: cx, y: mastTop))
        stays.addLine(to: CGPoint(x: cx + L * 0.42, y: waterY - L * 0.19))
        Art.stroke(&context, stays, propTone(hull, 0.62).opacity(0.55), width: lw * 0.4)
        propShaft(&context, cx, waterY - L * 0.04, cx, mastTop, wood: woodHex, width: lw * 1.3)
        if let sail {
            var cloth = Path()
            cloth.move(to: CGPoint(x: cx - half, y: yardY))
            cloth.addLine(to: CGPoint(x: cx + half, y: yardY))
            cloth.addQuadCurve(to: CGPoint(x: cx + half * 0.94, y: footY), control: CGPoint(x: cx + half * 1.14, y: midY))
            cloth.addQuadCurve(to: CGPoint(x: cx - half * 0.94, y: footY), control: CGPoint(x: cx, y: footY + L * 0.07))
            cloth.addQuadCurve(to: CGPoint(x: cx - half, y: yardY), control: CGPoint(x: cx - half * 1.14, y: midY))
            cloth.closeSubpath()
            var seams = Path()
            let offsets: [CGFloat] = [-0.5, 0, 0.5]
            for offset in offsets {
                let x: CGFloat = cx + half * offset
                seams.move(to: CGPoint(x: x, y: yardY))
                seams.addQuadCurve(to: CGPoint(x: x, y: footY + L * 0.08), control: CGPoint(x: x + half * 0.12 * offset, y: midY))
            }
            propCloth(&context, cloth, seams: seams, sail: sail, lineWidth: lw * 0.6)
        }
        propShaft(&context, cx - half * 1.08, yardY, cx + half * 1.08, yardY, wood: woodHex, width: lw)
    }

    /// The dhow's rig: a short mast raked toward the bow and a lateen sail on a slanted yard.
    static func propRigDhow(_ context: inout GraphicsContext, cx: CGFloat, waterY: CGFloat, L: CGFloat, hull: UInt32, sail: UInt32?) {
        let woodHex: UInt32 = propToneHex(hull, 0.62)
        let lw: CGFloat = max(1.2, L * 0.018)
        let low = CGPoint(x: cx - L * 0.5, y: waterY - L * 0.24)
        let peak = CGPoint(x: cx + L * 0.26, y: waterY - L * 0.86)
        let clew = CGPoint(x: cx + L * 0.4, y: waterY - L * 0.2)
        propShaft(&context, cx - L * 0.04, waterY - L * 0.06, cx - L * 0.1, waterY - L * 0.6, wood: woodHex, width: lw * 1.3)
        if let sail {
            var cloth = Path()
            cloth.move(to: low)
            cloth.addLine(to: peak)
            cloth.addQuadCurve(to: clew, control: CGPoint(x: cx + L * 0.47, y: waterY - L * 0.54))
            cloth.addQuadCurve(to: low, control: CGPoint(x: cx - L * 0.02, y: waterY - L * 0.13))
            cloth.closeSubpath()
            var seams = Path()
            let steps: [CGFloat] = [0.3, 0.52, 0.76]
            for t in steps {
                let fromX: CGFloat = mix(low.x, peak.x, t)
                let fromY: CGFloat = mix(low.y, peak.y, t)
                let toX: CGFloat = mix(low.x, clew.x, t)
                let toY: CGFloat = mix(low.y, clew.y, t) + L * 0.04
                let bulge: CGFloat = L * 0.07 * t
                seams.move(to: CGPoint(x: fromX, y: fromY))
                seams.addQuadCurve(to: CGPoint(x: toX, y: toY), control: CGPoint(x: (fromX + toX) / 2 + bulge, y: (fromY + toY) / 2))
            }
            propCloth(&context, cloth, seams: seams, sail: sail, lineWidth: lw * 0.6)
        }
        propShaft(&context, low.x - L * 0.02, low.y + L * 0.016, peak.x + L * 0.03, peak.y - L * 0.024, wood: woodHex, width: lw)
    }

    /// The junk's rig: a tall mast and a mat sail stiffened by ribs (battens).
    static func propRigJunk(_ context: inout GraphicsContext, cx: CGFloat, waterY: CGFloat, L: CGFloat, hull: UInt32, sail: UInt32?) {
        let woodHex: UInt32 = propToneHex(hull, 0.62)
        let lw: CGFloat = max(1.2, L * 0.018)
        let mastX: CGFloat = cx + L * 0.02
        propShaft(&context, mastX, waterY - L * 0.06, mastX, waterY - L * 0.78, wood: woodHex, width: lw * 1.3)
        guard let sail else { return }
        let left: CGFloat = cx - L * 0.2
        let right: CGFloat = cx + L * 0.26
        let topL: CGFloat = waterY - L * 0.6
        let topR: CGFloat = waterY - L * 0.74
        let footL: CGFloat = waterY - L * 0.2
        let footR: CGFloat = waterY - L * 0.22
        var cloth = Path()
        cloth.move(to: CGPoint(x: left, y: topL))
        cloth.addQuadCurve(to: CGPoint(x: right, y: topR), control: CGPoint(x: cx - L * 0.02, y: waterY - L * 0.77))
        cloth.addQuadCurve(to: CGPoint(x: right, y: footR), control: CGPoint(x: right + L * 0.06, y: waterY - L * 0.48))
        cloth.addLine(to: CGPoint(x: left, y: footL))
        cloth.addQuadCurve(to: CGPoint(x: left, y: topL), control: CGPoint(x: left - L * 0.035, y: waterY - L * 0.4))
        cloth.closeSubpath()
        var ribs = Path()
        for index in 1...5 {
            let t: CGFloat = CGFloat(index) / 6
            let y0: CGFloat = mix(topL, footL, t)
            let y1: CGFloat = mix(topR, footR, t)
            ribs.move(to: CGPoint(x: left - L * 0.05, y: y0))
            ribs.addQuadCurve(to: CGPoint(x: right + L * 0.08, y: y1), control: CGPoint(x: cx, y: (y0 + y1) / 2 - L * 0.012))
        }
        propCloth(&context, cloth, seams: ribs, sail: sail, lineWidth: lw * 0.75)
        let pennant: [CGPoint] = [
            CGPoint(x: mastX, y: waterY - L * 0.79),
            CGPoint(x: mastX + L * 0.1, y: waterY - L * 0.765),
            CGPoint(x: mastX, y: waterY - L * 0.74),
        ]
        Art.fill(&context, Art.polygon(pennant), Art.color(0xD9483B))
    }
}

// MARK: - Containers

extension Kit {
    /// A woven basket standing on baseY: slightly flared, with woven rows, a rim, optional lid;
    /// `handles` adds two small loops.
    static func basket(
        _ context: inout GraphicsContext,
        cx: CGFloat,
        baseY: CGFloat,
        width: CGFloat,
        height: CGFloat,
        color: UInt32 = 0xC89A54,
        lid: Bool = false,
        handles: Bool = false
    ) {
        Kit.shadow(&context, cx, baseY, width: width * 0.86)
        propBasketBody(&context, cx: cx, baseY: baseY, width: width, height: height, color: color, lid: lid, handles: handles)
    }

    /// The basket itself, without a contact shadow (so it can hang from a pole).
    static func propBasketBody(
        _ context: inout GraphicsContext,
        cx: CGFloat,
        baseY: CGFloat,
        width w: CGFloat,
        height h: CGFloat,
        color: UInt32,
        lid: Bool,
        handles: Bool
    ) {
        let lidH: CGFloat = lid ? h * 0.2 : 0
        let top: CGFloat = baseY - h + lidH
        let bodyH: CGFloat = baseY - top
        let lw: CGFloat = min(ArtStyle.detailLine, max(0.7, w * 0.03))
        let dark = propTone(color, 0.68)
        if handles {
            var loops = Path()
            loops.addPath(Art.ellipse(cx - w * 0.5, top + bodyH * 0.2, w * 0.08, bodyH * 0.12))
            loops.addPath(Art.ellipse(cx + w * 0.5, top + bodyH * 0.2, w * 0.08, bodyH * 0.12))
            Art.stroke(&context, loops, propTone(color, 0.8), width: lw * 1.6)
        }
        var body = Path()
        body.move(to: CGPoint(x: cx - w * 0.5, y: top))
        body.addLine(to: CGPoint(x: cx + w * 0.5, y: top))
        body.addQuadCurve(to: CGPoint(x: cx + w * 0.3, y: baseY), control: CGPoint(x: cx + w * 0.46, y: baseY - bodyH * 0.1))
        body.addLine(to: CGPoint(x: cx - w * 0.3, y: baseY))
        body.addQuadCurve(to: CGPoint(x: cx - w * 0.5, y: top), control: CGPoint(x: cx - w * 0.46, y: baseY - bodyH * 0.1))
        body.closeSubpath()
        Kit.solid(&context, body, Art.color(color), light: 0.26, shade: 0.26)
        // The weave: bowed rows and short staggered uprights, one path.
        var weave = Path()
        let rows: Int = 5
        let rowH: CGFloat = bodyH / CGFloat(rows)
        for row in 1..<rows {
            let y: CGFloat = top + rowH * CGFloat(row)
            weave.move(to: CGPoint(x: cx - w * 0.5, y: y))
            weave.addQuadCurve(to: CGPoint(x: cx + w * 0.5, y: y), control: CGPoint(x: cx, y: y + bodyH * 0.06))
        }
        for row in 0..<rows {
            let y: CGFloat = top + rowH * CGFloat(row) + bodyH * 0.02
            let shift: CGFloat = row % 2 == 0 ? 0 : w * 0.07
            for column in 0..<7 {
                let x: CGFloat = cx - w * 0.44 + shift + w * 0.14 * CGFloat(column)
                weave.move(to: CGPoint(x: x, y: y + rowH * 0.15))
                weave.addLine(to: CGPoint(x: x, y: y + rowH * 0.85))
            }
        }
        Art.clipped(&context, to: body) { g in
            Art.stroke(&g, weave, dark.opacity(0.6), width: lw)
        }
        if lid {
            var dome = Path()
            dome.move(to: CGPoint(x: cx - w * 0.5, y: top))
            dome.addQuadCurve(to: CGPoint(x: cx + w * 0.5, y: top), control: CGPoint(x: cx, y: top - lidH * 1.8))
            dome.closeSubpath()
            Kit.solid(&context, dome, propTone(color, 1.08), light: 0.3, shade: 0.2)
            Art.fill(&context, Art.ellipse(cx, top - lidH * 0.92, w * 0.07, lidH * 0.2), dark)
        }
        let rimH: CGFloat = max(2, bodyH * 0.1)
        let rim = Art.rect(cx - w * 0.53, top - rimH * 0.5, w * 1.06, rimH, radius: rimH * 0.5)
        Kit.solid(&context, rim, propTone(color, 1.18), light: 0.3, shade: 0.2)
    }

    /// A clay pot / jar standing on baseY: round belly, neck and lip, optional painted band.
    static func pot(
        _ context: inout GraphicsContext,
        cx: CGFloat,
        baseY: CGFloat,
        width w: CGFloat,
        height h: CGFloat,
        color: UInt32 = 0xB5683A,
        band: UInt32? = nil
    ) {
        Kit.shadow(&context, cx, baseY, width: w * 0.8)
        let top: CGFloat = baseY - h
        let neckY: CGFloat = top + h * 0.06
        let bellyY: CGFloat = baseY - h * 0.42
        var body = Path()
        body.move(to: CGPoint(x: cx - w * 0.21, y: neckY))
        body.addLine(to: CGPoint(x: cx + w * 0.21, y: neckY))
        body.addCurve(
            to: CGPoint(x: cx + w * 0.5, y: bellyY),
            control1: CGPoint(x: cx + w * 0.21, y: top + h * 0.26),
            control2: CGPoint(x: cx + w * 0.5, y: baseY - h * 0.66)
        )
        body.addCurve(
            to: CGPoint(x: cx + w * 0.2, y: baseY),
            control1: CGPoint(x: cx + w * 0.5, y: baseY - h * 0.16),
            control2: CGPoint(x: cx + w * 0.36, y: baseY)
        )
        body.addLine(to: CGPoint(x: cx - w * 0.2, y: baseY))
        body.addCurve(
            to: CGPoint(x: cx - w * 0.5, y: bellyY),
            control1: CGPoint(x: cx - w * 0.36, y: baseY),
            control2: CGPoint(x: cx - w * 0.5, y: baseY - h * 0.16)
        )
        body.addCurve(
            to: CGPoint(x: cx - w * 0.21, y: neckY),
            control1: CGPoint(x: cx - w * 0.5, y: baseY - h * 0.66),
            control2: CGPoint(x: cx - w * 0.21, y: top + h * 0.26)
        )
        body.closeSubpath()
        Kit.solid(&context, body, Art.color(color), light: 0.3, shade: 0.3)
        let lw: CGFloat = min(ArtStyle.detailLine, max(0.7, w * 0.03))
        Art.clipped(&context, to: body) { g in
            if let band {
                Art.fill(&g, Art.rect(cx - w * 0.5, baseY - h * 0.62, w, h * 0.11), Art.color(band, 0.9))
                let thin = Art.line(cx - w * 0.5, baseY - h * 0.47, cx + w * 0.5, baseY - h * 0.47)
                Art.stroke(&g, thin, Art.color(band, 0.8), width: lw)
            }
            var foot = Path()
            foot.move(to: CGPoint(x: cx - w * 0.4, y: baseY - h * 0.12))
            foot.addQuadCurve(to: CGPoint(x: cx + w * 0.4, y: baseY - h * 0.12), control: CGPoint(x: cx, y: baseY - h * 0.05))
            Art.stroke(&g, foot, propTone(color, 0.7).opacity(0.5), width: lw)
        }
        let r: CGFloat = min(w, h * 0.9) * 0.4
        ArtStyle.rimLight(&context, cx - w * 0.06, bellyY, r, alpha: 0.3)
        let lipH: CGFloat = max(2, h * 0.08)
        let lip = Art.rect(cx - w * 0.27, top, w * 0.54, lipH, radius: lipH * 0.5)
        Kit.solid(&context, lip, propTone(color, 1.15), light: 0.3, shade: 0.24)
    }

    /// A tied sack standing on baseY.
    static func sack(
        _ context: inout GraphicsContext,
        cx: CGFloat,
        baseY: CGFloat,
        width w: CGFloat,
        height h: CGFloat,
        color: UInt32 = 0xC8B088
    ) {
        Kit.shadow(&context, cx, baseY, width: w * 0.9)
        let top: CGFloat = baseY - h
        let neckY: CGFloat = top + h * 0.2
        var ruff = Path()
        ruff.move(to: CGPoint(x: cx - w * 0.13, y: neckY + h * 0.02))
        ruff.addLine(to: CGPoint(x: cx - w * 0.25, y: top + h * 0.03))
        ruff.addQuadCurve(to: CGPoint(x: cx + w * 0.23, y: top), control: CGPoint(x: cx, y: top + h * 0.1))
        ruff.addLine(to: CGPoint(x: cx + w * 0.13, y: neckY + h * 0.02))
        ruff.closeSubpath()
        Kit.solid(&context, ruff, propTone(color, 1.1), light: 0.26, shade: 0.2)
        var body = Path()
        body.move(to: CGPoint(x: cx - w * 0.13, y: neckY))
        body.addCurve(
            to: CGPoint(x: cx - w * 0.5, y: baseY - h * 0.3),
            control1: CGPoint(x: cx - w * 0.3, y: top + h * 0.28),
            control2: CGPoint(x: cx - w * 0.52, y: baseY - h * 0.6)
        )
        body.addCurve(
            to: CGPoint(x: cx - w * 0.3, y: baseY),
            control1: CGPoint(x: cx - w * 0.5, y: baseY - h * 0.08),
            control2: CGPoint(x: cx - w * 0.42, y: baseY)
        )
        body.addLine(to: CGPoint(x: cx + w * 0.32, y: baseY))
        body.addCurve(
            to: CGPoint(x: cx + w * 0.5, y: baseY - h * 0.26),
            control1: CGPoint(x: cx + w * 0.44, y: baseY),
            control2: CGPoint(x: cx + w * 0.5, y: baseY - h * 0.06)
        )
        body.addCurve(
            to: CGPoint(x: cx + w * 0.13, y: neckY),
            control1: CGPoint(x: cx + w * 0.5, y: baseY - h * 0.58),
            control2: CGPoint(x: cx + w * 0.3, y: top + h * 0.3)
        )
        body.closeSubpath()
        Kit.solid(&context, body, Art.color(color), light: 0.28, shade: 0.28)
        let lw: CGFloat = min(ArtStyle.detailLine, max(0.7, w * 0.03))
        var folds = Path()
        folds.move(to: CGPoint(x: cx - w * 0.06, y: neckY + h * 0.04))
        folds.addQuadCurve(to: CGPoint(x: cx - w * 0.22, y: baseY - h * 0.34), control: CGPoint(x: cx - w * 0.1, y: baseY - h * 0.56))
        folds.move(to: CGPoint(x: cx + w * 0.05, y: neckY + h * 0.04))
        folds.addQuadCurve(to: CGPoint(x: cx + w * 0.2, y: baseY - h * 0.28), control: CGPoint(x: cx + w * 0.08, y: baseY - h * 0.5))
        folds.move(to: CGPoint(x: cx - w * 0.3, y: baseY - h * 0.06))
        folds.addQuadCurve(to: CGPoint(x: cx + w * 0.1, y: baseY - h * 0.05), control: CGPoint(x: cx - w * 0.1, y: baseY - h * 0.1))
        Art.stroke(&context, folds, propTone(color, 0.72).opacity(0.6), width: lw)
        let tie = Art.line(cx - w * 0.14, neckY + h * 0.01, cx + w * 0.14, neckY + h * 0.01)
        Art.stroke(&context, tie, propTone(color, 0.5), width: max(1.4, h * 0.035))
        let tail = Art.line(cx + w * 0.1, neckY + h * 0.02, cx + w * 0.2, neckY + h * 0.12)
        Art.stroke(&context, tail, propTone(color, 0.5), width: max(0.8, h * 0.018))
    }

    /// A bowl (of rice, of food) seen from the side at (cx, baseY): the bowl and a rounded heap
    /// of `filling` above the rim when non-nil.
    static func bowl(
        _ context: inout GraphicsContext,
        cx: CGFloat,
        baseY: CGFloat,
        width w: CGFloat,
        color: UInt32 = 0x8A2A22,
        filling: UInt32? = nil
    ) {
        Kit.shadow(&context, cx, baseY, width: w * 0.7, alpha: 0.22)
        let rimY: CGFloat = baseY - w * 0.42
        if let filling {
            var mound = Path()
            mound.move(to: CGPoint(x: cx - w * 0.44, y: rimY + w * 0.02))
            mound.addQuadCurve(to: CGPoint(x: cx + w * 0.44, y: rimY + w * 0.02), control: CGPoint(x: cx - w * 0.02, y: rimY - w * 0.46))
            mound.closeSubpath()
            Kit.solid(&context, mound, Art.color(filling), light: 0.3, shade: 0.18)
            var grains = Path()
            let spots: [(CGFloat, CGFloat)] = [(-0.2, -0.08), (-0.05, -0.16), (0.12, -0.1), (0.24, -0.04), (-0.3, -0.02), (0.02, -0.05)]
            for spot in spots {
                grains.addPath(Art.ellipse(cx + spot.0 * w, rimY + spot.1 * w, w * 0.028, w * 0.016))
            }
            Art.fill(&context, grains, propTone(filling, 0.8).opacity(0.55))
        }
        let foot = Art.rect(cx - w * 0.17, baseY - w * 0.07, w * 0.34, w * 0.07, radius: w * 0.02)
        Art.fill(&context, foot, propTone(color, 0.7))
        var body = Path()
        body.move(to: CGPoint(x: cx - w * 0.5, y: rimY))
        body.addLine(to: CGPoint(x: cx + w * 0.5, y: rimY))
        body.addCurve(
            to: CGPoint(x: cx + w * 0.16, y: baseY - w * 0.05),
            control1: CGPoint(x: cx + w * 0.48, y: rimY + w * 0.22),
            control2: CGPoint(x: cx + w * 0.32, y: baseY - w * 0.05)
        )
        body.addLine(to: CGPoint(x: cx - w * 0.16, y: baseY - w * 0.05))
        body.addCurve(
            to: CGPoint(x: cx - w * 0.5, y: rimY),
            control1: CGPoint(x: cx - w * 0.32, y: baseY - w * 0.05),
            control2: CGPoint(x: cx - w * 0.48, y: rimY + w * 0.22)
        )
        body.closeSubpath()
        Kit.solid(&context, body, Art.color(color), light: 0.32, shade: 0.28)
        let lip = Art.line(cx - w * 0.47, rimY + w * 0.02, cx + w * 0.47, rimY + w * 0.02)
        Art.stroke(&context, lip, propTone(color, 1.5).opacity(0.7), width: max(0.8, w * 0.03))
    }
}

// MARK: - Fire and light

extension Kit {
    /// A campfire on baseY: crossed logs, flame tongues (orange to yellow), a warm glow, a few
    /// sparks. About 64 units wide and 62 tall at scale 1.
    static func campfire(_ context: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, scale: CGFloat = 1) {
        Art.group(&context, x: cx, y: baseY, scale: scale) { g in
            Art.glow(&g, 0, -24, 78, Art.color(0xFF9A3C), alpha: 0.42)
            Kit.shadow(&g, 0, 1, width: 64, alpha: 0.2)
            let bark: UInt32 = 0x5A3524
            Art.stroke(&g, Art.line(-27, -3, 24, -12), Art.color(bark), width: 8)
            Art.stroke(&g, Art.line(-24, -12, 27, -3), propTone(bark, 1.25), width: 8)
            var ends = Path()
            ends.addPath(Art.ellipse(-27, -3, 2.6, 3.4))
            ends.addPath(Art.ellipse(27, -3, 2.6, 3.4))
            Art.fill(&g, ends, Art.color(0xD9A66A))
            Art.stroke(&g, Art.line(-18, -12.5, 2, -9), ArtStyle.warmLight.opacity(0.45), width: 1.6)
            var outer = Path()
            outer.addPath(propFlame(-10, -6, 20, 38, -5))
            outer.addPath(propFlame(10, -6, 20, 32, 6))
            outer.addPath(propFlame(0, -6, 27, 56, 3))
            Art.fill(&g, outer, Art.color(0xF2742B))
            var middle = Path()
            middle.addPath(propFlame(1, -6, 17, 38, 2))
            middle.addPath(propFlame(-8, -6, 10, 21, -3))
            middle.addPath(propFlame(9, -6, 9, 18, 3))
            Art.fill(&g, middle, Art.color(0xFFB43A))
            Art.fill(&g, propFlame(1, -6, 9, 21, 1), Art.color(0xFFF0A8))
            Art.glow(&g, 0, -16, 22, Art.color(0xFFE08A), alpha: 0.5)
            var sparks = Path()
            let places: [(CGFloat, CGFloat, CGFloat)] = [(-14, -52, 1.6), (12, -62, 1.3), (-4, -72, 1.1), (20, -46, 1.2), (-22, -38, 1)]
            for place in places {
                sparks.addPath(Art.spark(place.0, place.1, place.2 * 1.6))
            }
            Art.fill(&g, sparks, Art.color(0xFFD27A, 0.9))
        }
    }

    /// A small warm light with a halo (a lamp flame, a lit window far away).
    static func lamp(_ context: inout GraphicsContext, cx: CGFloat, cy: CGFloat, radius: CGFloat, color: UInt32 = 0xFFC96B) {
        let r: CGFloat = max(0.5, radius)
        Art.glow(&context, cx, cy, r * 5, Art.color(color), alpha: 0.5)
        Art.glow(&context, cx, cy, r * 2.2, Art.color(color), alpha: 0.85)
        Art.fill(&context, propFlame(cx, cy + r, r * 1.5, r * 2.3, 0), Art.color(color))
        Art.fill(&context, Art.ellipse(cx, cy + r * 0.3, r * 0.42, r * 0.6), Color.white.opacity(0.85))
    }
}

// MARK: - Cart, well, signpost, carrying pole

extension Kit {
    /// A spoked wooden wheel centred on (x, y): rim, eight spokes, hub, a lit upper-left arc.
    static func propWheel(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, r: CGFloat, color: UInt32) {
        let ring: CGFloat = r * 0.9
        var spokes = Path()
        for index in 0..<8 {
            let a: CGFloat = CGFloat(index) * CGFloat.pi / 4 + 0.2
            spokes.move(to: CGPoint(x: x, y: y))
            spokes.addLine(to: CGPoint(x: x + cos(a) * ring, y: y + sin(a) * ring))
        }
        Art.stroke(&context, spokes, propTone(color, 0.85), width: max(0.8, r * 0.09))
        Art.stroke(&context, Art.circle(x, y, ring), Art.color(color), width: max(1.2, r * 0.2))
        var lit = Path()
        lit.move(to: CGPoint(x: x - ring, y: y))
        lit.addCurve(
            to: CGPoint(x: x, y: y - ring),
            control1: CGPoint(x: x - ring, y: y - ring * 0.552),
            control2: CGPoint(x: x - ring * 0.552, y: y - ring)
        )
        Art.stroke(&context, lit, ArtStyle.warmLight.opacity(0.45), width: max(0.6, r * 0.07))
        Kit.solid(&context, Art.circle(x, y, r * 0.2), propTone(color, 1.25), light: 0.3, shade: 0.25)
        Art.fill(&context, Art.circle(x, y, r * 0.07), propTone(color, 0.55))
    }

    /// A two-wheeled farm cart seen from the side on baseY, shafts to the LEFT, the box
    /// `length` long; `load` non-nil heaps the box with rounded things in that colour.
    static func cart(
        _ context: inout GraphicsContext,
        cx: CGFloat,
        baseY: CGFloat,
        length: CGFloat,
        color: UInt32 = 0x8A5A3A,
        load: UInt32? = nil
    ) {
        let L: CGFloat = max(8, length)
        let r: CGFloat = L * 0.28
        let floorY: CGFloat = baseY - r * 1.2
        let topY: CGFloat = floorY - L * 0.26
        let lw: CGFloat = min(ArtStyle.detailLine, max(0.7, L * 0.014))
        Kit.shadow(&context, cx, baseY, width: L * 1.1)
        propWheel(&context, x: cx + L * 0.13, y: baseY - r, r: r * 0.95, color: propToneHex(color, 0.58))
        let shaftW: CGFloat = max(1.6, L * 0.03)
        propShaft(&context, cx - L * 0.48, floorY - L * 0.02, cx - L * 1.05, floorY + L * 0.07, wood: propToneHex(color, 0.82), width: shaftW)
        if let load {
            let lumps: [(CGFloat, CGFloat, CGFloat)] = [(-0.31, 0.01, 0.13), (0.33, 0.02, 0.12), (-0.09, -0.05, 0.16), (0.15, -0.03, 0.15), (0.03, -0.17, 0.12)]
            for lump in lumps {
                let item = Art.ellipse(cx + lump.0 * L, topY + lump.1 * L, lump.2 * L, lump.2 * L * 0.92)
                Kit.solid(&context, item, Art.color(load), light: 0.3, shade: 0.26)
            }
        }
        let box: [CGPoint] = [
            CGPoint(x: cx - L * 0.52, y: topY),
            CGPoint(x: cx + L * 0.52, y: topY),
            CGPoint(x: cx + L * 0.47, y: floorY),
            CGPoint(x: cx - L * 0.47, y: floorY),
        ]
        let boxPath = Art.polygon(box)
        Kit.solid(&context, boxPath, Art.color(color), light: 0.24, shade: 0.26)
        var planks = Path()
        var cleats = Path()
        let third: CGFloat = (floorY - topY) / 3
        planks.addPath(Art.line(cx - L * 0.52, topY + third, cx + L * 0.52, topY + third))
        planks.addPath(Art.line(cx - L * 0.52, topY + third * 2, cx + L * 0.52, topY + third * 2))
        let posts: [CGFloat] = [-0.36, 0, 0.36]
        for post in posts {
            cleats.addPath(Art.line(cx + post * L, topY, cx + post * L, floorY))
        }
        Art.clipped(&context, to: boxPath) { g in
            Art.stroke(&g, planks, propTone(color, 0.68).opacity(0.7), width: lw)
            Art.stroke(&g, cleats, propTone(color, 1.2).opacity(0.8), width: L * 0.035, cap: .butt)
        }
        let railH: CGFloat = max(2, L * 0.035)
        let rail = Art.rect(cx - L * 0.54, topY - railH * 0.5, L * 1.08, railH, radius: railH * 0.5)
        Kit.solid(&context, rail, propTone(color, 1.25), light: 0.3, shade: 0.2)
        propWheel(&context, x: cx + L * 0.04, y: baseY - r, r: r, color: propToneHex(color, 0.76))
    }

    /// A stone well on baseY: a round coursed wall seen from the side (an ellipse top showing
    /// the dark mouth), and, when `roofed`, two posts, a little roof, a windlass and a rope.
    static func well(
        _ context: inout GraphicsContext,
        cx: CGFloat,
        baseY: CGFloat,
        width w: CGFloat,
        height h: CGFloat,
        stone: UInt32 = 0x9A9488,
        roofed: Bool = true
    ) {
        let wallH: CGFloat = roofed ? h * 0.4 : h
        let e: CGFloat = w * 0.09
        let wallTop: CGFloat = baseY - wallH
        let frameH: CGFloat = h - wallH
        let lw: CGFloat = min(ArtStyle.detailLine, max(0.7, w * 0.02))
        Kit.shadow(&context, cx, baseY, width: w * 1.05)
        if roofed {
            propWellFrame(&context, cx: cx, wallTop: wallTop, w: w, frameH: frameH)
        }
        var wall = Path()
        wall.move(to: CGPoint(x: cx - w * 0.5, y: wallTop))
        wall.addLine(to: CGPoint(x: cx - w * 0.5, y: baseY - e))
        wall.addQuadCurve(to: CGPoint(x: cx + w * 0.5, y: baseY - e), control: CGPoint(x: cx, y: baseY + e))
        wall.addLine(to: CGPoint(x: cx + w * 0.5, y: wallTop))
        wall.closeSubpath()
        Kit.solid(&context, wall, Art.color(stone), light: 0.26, shade: 0.3)
        // Courses: bowed rows and staggered joints, one path.
        var courses = Path()
        let rows: Int = 4
        let rowH: CGFloat = wallH / CGFloat(rows)
        for row in 0..<rows {
            let y: CGFloat = wallTop + rowH * CGFloat(row)
            if row > 0 {
                courses.move(to: CGPoint(x: cx - w * 0.5, y: y - e))
                courses.addQuadCurve(to: CGPoint(x: cx + w * 0.5, y: y - e), control: CGPoint(x: cx, y: y + e))
            }
            let shift: CGFloat = row % 2 == 0 ? 0.12 : 0.26
            for column in 0..<4 {
                let t: CGFloat = shift + 0.25 * CGFloat(column)
                let bow: CGFloat = e * (4 * t * (1 - t) - 1)
                let x: CGFloat = cx - w * 0.5 + w * t
                courses.move(to: CGPoint(x: x, y: y + bow))
                courses.addLine(to: CGPoint(x: x, y: y + rowH + bow))
            }
        }
        Art.clipped(&context, to: wall) { g in
            Art.stroke(&g, courses, propTone(stone, 0.66).opacity(0.6), width: lw)
        }
        Art.fill(&context, Art.ellipse(cx, wallTop, w * 0.5, e), propTone(stone, 1.22))
        let mouth = Art.ellipse(cx, wallTop + e * 0.12, w * 0.39, e * 0.66)
        Art.fill(&context, mouth, propTone(stone, 0.34))
        Art.fill(&context, mouth, ArtStyle.coolShade.opacity(0.4))
        if roofed {
            let rope = Art.line(cx, wallTop - frameH * 0.34, cx, wallTop + e * 0.1)
            Art.stroke(&context, rope, Art.color(0xD9C49A), width: max(0.8, w * 0.018))
        }
    }

    /// The frame over a well: two posts, a windlass with a crank, and a small gabled roof.
    static func propWellFrame(_ context: inout GraphicsContext, cx: CGFloat, wallTop: CGFloat, w: CGFloat, frameH: CGFloat) {
        let wood: UInt32 = 0x8A5A3A
        let postW: CGFloat = max(2, w * 0.07)
        let roofBase: CGFloat = wallTop - frameH * 0.6
        let roofTop: CGFloat = wallTop - frameH
        let windY: CGFloat = wallTop - frameH * 0.34
        propShaft(&context, cx - w * 0.42, wallTop, cx - w * 0.42, roofBase, wood: wood, width: postW)
        propShaft(&context, cx + w * 0.42, wallTop, cx + w * 0.42, roofBase, wood: propToneHex(wood, 0.85), width: postW)
        var crank = Path()
        crank.move(to: CGPoint(x: cx + w * 0.42, y: windY))
        crank.addLine(to: CGPoint(x: cx + w * 0.56, y: windY))
        crank.addLine(to: CGPoint(x: cx + w * 0.56, y: windY + frameH * 0.1))
        Art.stroke(&context, crank, propTone(wood, 0.7), width: max(1, postW * 0.4))
        propShaft(&context, cx - w * 0.4, windY, cx + w * 0.4, windY, wood: propToneHex(wood, 1.2), width: postW * 1.2)
        var wraps = Path()
        let turns: [CGFloat] = [-0.05, 0, 0.05]
        for turn in turns {
            wraps.addPath(Art.line(cx + turn * w, windY - postW * 0.6, cx + turn * w, windY + postW * 0.6))
        }
        Art.stroke(&context, wraps, Art.color(0xD9C49A), width: max(0.8, w * 0.02), cap: .butt)
        var roof = Path()
        roof.move(to: CGPoint(x: cx - w * 0.66, y: roofBase))
        roof.addQuadCurve(to: CGPoint(x: cx, y: roofTop), control: CGPoint(x: cx - w * 0.28, y: roofTop + frameH * 0.16))
        roof.addQuadCurve(to: CGPoint(x: cx + w * 0.66, y: roofBase), control: CGPoint(x: cx + w * 0.28, y: roofTop + frameH * 0.16))
        roof.addQuadCurve(to: CGPoint(x: cx - w * 0.66, y: roofBase), control: CGPoint(x: cx, y: roofBase + frameH * 0.05))
        roof.closeSubpath()
        let tile: UInt32 = 0xA65A3C
        Kit.solid(&context, roof, Art.color(tile), light: 0.28, shade: 0.26, rim: 2)
        var rows = Path()
        let drop: CGFloat = (roofBase - roofTop) / 3
        rows.addPath(roof.applying(CGAffineTransform(translationX: 0, y: -drop)))
        rows.addPath(roof.applying(CGAffineTransform(translationX: 0, y: -drop * 2)))
        Art.clipped(&context, to: roof) { g in
            Art.stroke(&g, rows, propTone(tile, 0.7).opacity(0.6), width: min(ArtStyle.detailLine, max(0.7, w * 0.02)))
        }
    }

    /// A wooden signpost with one or two blank pointing boards (NO lettering). The first board
    /// points right, the second left.
    static func signpost(
        _ context: inout GraphicsContext,
        cx: CGFloat,
        baseY: CGFloat,
        height h: CGFloat,
        color: UInt32 = 0x8A5A3A,
        boards: Int = 1
    ) {
        Kit.shadow(&context, cx, baseY, width: h * 0.26)
        let postW: CGFloat = max(2, h * 0.07)
        let post = Art.rect(cx - postW / 2, baseY - h, postW, h, radius: postW * 0.4)
        Kit.solid(&context, post, Art.color(color), light: 0.26, shade: 0.28)
        Art.fill(&context, Art.ellipse(cx, baseY, postW * 1.5, postW * 0.5), propTone(color, 0.6).opacity(0.6))
        let boardH: CGFloat = h * 0.15
        let tip: CGFloat = h * 0.09
        var grain = Path()
        var nails = Path()
        for index in 0..<min(2, max(1, boards)) {
            let y: CGFloat = baseY - h * (0.84 - 0.21 * CGFloat(index))
            let dir: CGFloat = index == 0 ? 1 : -1
            let x0: CGFloat = cx - dir * h * 0.13
            let x1: CGFloat = cx + dir * h * 0.46
            let board: [CGPoint] = [
                CGPoint(x: x0, y: y - boardH / 2),
                CGPoint(x: x1 - dir * tip, y: y - boardH / 2),
                CGPoint(x: x1, y: y),
                CGPoint(x: x1 - dir * tip, y: y + boardH / 2),
                CGPoint(x: x0, y: y + boardH / 2),
            ]
            Kit.solid(&context, Art.polygon(board), propTone(color, 1.3), light: 0.28, shade: 0.22)
            grain.addPath(Art.line(x0 + dir * h * 0.04, y + boardH * 0.18, x1 - dir * tip * 1.3, y + boardH * 0.18))
            nails.addPath(Art.circle(cx, y, max(0.8, h * 0.012)))
        }
        Art.stroke(&context, grain, propTone(color, 0.8).opacity(0.5), width: min(ArtStyle.detailLine, max(0.6, h * 0.012)))
        Art.fill(&context, nails, propTone(color, 0.5))
    }

    /// A shoulder pole with a basket hanging from each end (East Asian carrying pole): the
    /// pole's middle at (cx, cy), `length` long, baskets hanging `drop` below.
    static func carryingPole(
        _ context: inout GraphicsContext,
        cx: CGFloat,
        cy: CGFloat,
        length: CGFloat,
        drop: CGFloat,
        basket: UInt32 = 0xC89A54
    ) {
        let L: CGFloat = max(8, length)
        let endY: CGFloat = cy + L * 0.04
        let bw: CGFloat = L * 0.27
        let bh: CGFloat = min(bw * 0.72, drop * 0.6)
        let rimY: CGFloat = endY + drop - bh
        let poleW: CGFloat = max(1.6, L * 0.022)
        var ropes = Path()
        let ends: [CGFloat] = [cx - L * 0.5, cx + L * 0.5]
        for x in ends {
            ropes.move(to: CGPoint(x: x - bw * 0.42, y: rimY))
            ropes.addLine(to: CGPoint(x: x, y: endY))
            ropes.addLine(to: CGPoint(x: x + bw * 0.42, y: rimY))
            ropes.move(to: CGPoint(x: x, y: endY))
            ropes.addLine(to: CGPoint(x: x, y: rimY))
        }
        Art.stroke(&context, ropes, propTone(basket, 0.62), width: max(0.7, poleW * 0.35))
        for x in ends {
            propBasketBody(&context, cx: x, baseY: endY + drop, width: bw, height: bh, color: basket, lid: false, handles: false)
        }
        var pole = Path()
        pole.move(to: CGPoint(x: cx - L * 0.53, y: endY + L * 0.006))
        pole.addQuadCurve(to: CGPoint(x: cx + L * 0.53, y: endY + L * 0.006), control: CGPoint(x: cx, y: cy - L * 0.04))
        let wood: UInt32 = 0x9A6B3E
        Art.stroke(&context, pole, Art.color(wood), width: poleW)
        let lit = pole.applying(CGAffineTransform(translationX: 0, y: -poleW * 0.28))
        Art.stroke(&context, lit, propTone(wood, 1.45).opacity(0.6), width: max(0.6, poleW * 0.3))
    }
}

// MARK: - Tools

extension Kit {
    /// Farm and house tools, each drawn upright with its foot at (x, baseY), about `height`
    /// tall: a hoe and a spade (blade on the ground), a sickle (handle down, blade curved like
    /// a new moon), a wooden plough (lying, `height` = its length, share to the left), a staff,
    /// a broom (bristles down), an oar (blade up).
    enum Tool: Sendable { case hoe, spade, sickle, plough, staff, broom, oar }

    static func tool(
        _ context: inout GraphicsContext,
        _ tool: Tool,
        x: CGFloat,
        baseY: CGFloat,
        height: CGFloat,
        wood: UInt32 = 0x8A5A3A,
        metal: UInt32 = 0x9AA4AE
    ) {
        let h: CGFloat = max(4, height)
        let sw: CGFloat = max(1.4, h * 0.035)
        switch tool {
        case .hoe:
            Kit.shadow(&context, x + h * 0.06, baseY, width: h * 0.24, alpha: 0.2)
            propShaft(&context, x, baseY - h * 0.08, x, baseY - h, wood: wood, width: sw)
            propBlade(&context, .hoe, x: x, baseY: baseY, h: h, metal: metal)
        case .spade:
            Kit.shadow(&context, x, baseY, width: h * 0.22, alpha: 0.2)
            propShaft(&context, x, baseY - h * 0.28, x, baseY - h * 0.97, wood: wood, width: sw)
            propShaft(&context, x - h * 0.06, baseY - h * 0.97, x + h * 0.06, baseY - h * 0.97, wood: wood, width: sw)
            propBlade(&context, .spade, x: x, baseY: baseY, h: h, metal: metal)
        case .sickle:
            propBlade(&context, .sickle, x: x, baseY: baseY, h: h, metal: metal)
            propShaft(&context, x, baseY - h * 0.02, x, baseY - h * 0.4, wood: wood, width: sw * 1.5)
        case .plough:
            propPlough(&context, x: x, baseY: baseY, length: h, wood: wood, metal: metal)
        case .staff:
            Kit.shadow(&context, x, baseY, width: h * 0.12, alpha: 0.2)
            var bend = Path()
            bend.move(to: CGPoint(x: x, y: baseY))
            bend.addQuadCurve(to: CGPoint(x: x + h * 0.03, y: baseY - h * 0.96), control: CGPoint(x: x - h * 0.04, y: baseY - h * 0.5))
            Art.stroke(&context, bend, Art.color(wood), width: sw)
            let lit = bend.applying(CGAffineTransform(translationX: -sw * 0.25, y: 0))
            Art.stroke(&context, lit, propTone(wood, 1.4).opacity(0.6), width: max(0.6, sw * 0.3))
            Kit.solid(&context, Art.ellipse(x + h * 0.03, baseY - h * 0.97, sw * 0.9, sw * 1.1), propTone(wood, 1.1))
        case .broom:
            Kit.shadow(&context, x, baseY, width: h * 0.3, alpha: 0.2)
            propShaft(&context, x, baseY - h * 0.3, x, baseY - h, wood: wood, width: sw)
            propBroomHead(&context, x: x, baseY: baseY, h: h, wood: wood)
        case .oar:
            Kit.shadow(&context, x, baseY, width: h * 0.12, alpha: 0.2)
            propShaft(&context, x, baseY, x, baseY - h * 0.64, wood: wood, width: sw)
            propBlade(&context, .oar, x: x, baseY: baseY, h: h, metal: propToneHex(wood, 1.25))
        }
    }

    /// The working end of a hoe, spade, sickle or oar, in `metal`, modelled by the light.
    static func propBlade(_ context: inout GraphicsContext, _ tool: Tool, x: CGFloat, baseY: CGFloat, h: CGFloat, metal: UInt32) {
        func p(_ dx: CGFloat, _ dy: CGFloat) -> CGPoint {
            CGPoint(x: x + dx * h, y: baseY - dy * h)
        }
        var blade = Path()
        switch tool {
        case .hoe:
            blade.move(to: p(-0.02, 0.17))
            blade.addLine(to: p(0.05, 0.18))
            blade.addQuadCurve(to: p(0.2, 0), control: p(0.19, 0.15))
            blade.addLine(to: p(0.12, 0))
            blade.addQuadCurve(to: p(-0.02, 0.1), control: p(0.1, 0.09))
        case .spade:
            blade.move(to: p(-0.1, 0.3))
            blade.addLine(to: p(0.1, 0.3))
            blade.addLine(to: p(0.1, 0.12))
            blade.addQuadCurve(to: p(0, 0), control: p(0.09, 0.01))
            blade.addQuadCurve(to: p(-0.1, 0.12), control: p(-0.09, 0.01))
        case .sickle:
            blade.move(to: p(0, 0.38))
            blade.addCurve(to: p(-0.22, 0.78), control1: p(0.42, 0.5), control2: p(0.2, 1.08))
            blade.addCurve(to: p(0, 0.45), control1: p(0.1, 0.96), control2: p(0.28, 0.56))
        case .oar:
            blade.move(to: p(-0.02, 0.62))
            blade.addCurve(to: p(0, 1), control1: p(-0.08, 0.7), control2: p(-0.07, 1))
            blade.addCurve(to: p(0.02, 0.62), control1: p(0.07, 1), control2: p(0.08, 0.7))
        case .plough, .staff, .broom:
            return
        }
        blade.closeSubpath()
        Kit.solid(&context, blade, Art.color(metal), light: 0.34, shade: 0.26)
        if tool == .oar || tool == .spade {
            let top: CGFloat = tool == .oar ? 0.95 : 0.28
            let foot: CGFloat = tool == .oar ? 0.66 : 0.06
            let ridge = Art.line(x, baseY - top * h, x, baseY - foot * h)
            Art.stroke(&context, ridge, propTone(metal, 0.72).opacity(0.6), width: max(0.6, h * 0.01))
        }
    }

    /// A broom's head: a flared bundle of straw with strands and two bindings.
    static func propBroomHead(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, h: CGFloat, wood: UInt32) {
        let straw: UInt32 = 0xD8B25A
        let topY: CGFloat = baseY - h * 0.33
        var head = Path()
        head.move(to: CGPoint(x: x - h * 0.035, y: topY))
        head.addLine(to: CGPoint(x: x + h * 0.035, y: topY))
        head.addQuadCurve(to: CGPoint(x: x + h * 0.14, y: baseY), control: CGPoint(x: x + h * 0.12, y: baseY - h * 0.17))
        head.addQuadCurve(to: CGPoint(x: x - h * 0.14, y: baseY), control: CGPoint(x: x, y: baseY + h * 0.02))
        head.addQuadCurve(to: CGPoint(x: x - h * 0.035, y: topY), control: CGPoint(x: x - h * 0.12, y: baseY - h * 0.17))
        head.closeSubpath()
        Kit.solid(&context, head, Art.color(straw), light: 0.28, shade: 0.26)
        var strands = Path()
        let fans: [CGFloat] = [-0.7, -0.35, 0, 0.35, 0.7]
        for fan in fans {
            strands.move(to: CGPoint(x: x + fan * h * 0.03, y: topY + h * 0.06))
            strands.addLine(to: CGPoint(x: x + fan * h * 0.13, y: baseY - h * 0.01))
        }
        var ties = Path()
        ties.addPath(Art.line(x - h * 0.045, topY + h * 0.03, x + h * 0.045, topY + h * 0.03))
        ties.addPath(Art.line(x - h * 0.06, topY + h * 0.08, x + h * 0.06, topY + h * 0.08))
        Art.stroke(&context, strands, propTone(straw, 0.68).opacity(0.6), width: max(0.6, h * 0.01))
        Art.stroke(&context, ties, propTone(wood, 0.7), width: max(1, h * 0.018))
    }

    /// A wooden plough lying on baseY, centred on x: beam, curved handle, brace, iron share.
    static func propPlough(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, length L: CGFloat, wood: UInt32, metal: UInt32) {
        Kit.shadow(&context, x, baseY, width: L * 0.8, alpha: 0.2)
        let sw: CGFloat = max(1.6, L * 0.05)
        propShaft(&context, x - L * 0.5, baseY - L * 0.4, x + L * 0.22, baseY - L * 0.24, wood: wood, width: sw)
        var stilt = Path()
        stilt.move(to: CGPoint(x: x - L * 0.08, y: baseY - L * 0.05))
        stilt.addQuadCurve(to: CGPoint(x: x + L * 0.5, y: baseY - L * 0.62), control: CGPoint(x: x + L * 0.3, y: baseY - L * 0.12))
        Art.stroke(&context, stilt, propTone(wood, 0.85), width: sw)
        let lit = stilt.applying(CGAffineTransform(translationX: -sw * 0.2, y: -sw * 0.2))
        Art.stroke(&context, lit, propTone(wood, 1.4).opacity(0.55), width: max(0.6, sw * 0.3))
        let brace = Art.line(x - L * 0.12, baseY - L * 0.32, x + L * 0.02, baseY - L * 0.08)
        Art.stroke(&context, brace, propTone(wood, 0.7), width: sw * 0.7)
        let share: [CGPoint] = [
            CGPoint(x: x - L * 0.32, y: baseY),
            CGPoint(x: x - L * 0.02, y: baseY - L * 0.17),
            CGPoint(x: x + L * 0.06, y: baseY - L * 0.02),
        ]
        Kit.solid(&context, Art.polygon(share), Art.color(metal), light: 0.34, shade: 0.26)
        Art.fill(&context, Art.ellipse(x + L * 0.5, baseY - L * 0.62, sw * 0.7, sw * 0.7), propTone(wood, 1.15))
    }
}

// MARK: - Harvest, furniture, treasure

extension Kit {
    /// A sheaf of grain standing on baseY (tied in the middle, ears fanning at the top).
    static func sheaf(_ context: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, height h: CGFloat, color: UInt32 = 0xE0B040) {
        Kit.shadow(&context, cx, baseY, width: h * 0.42)
        var body = Path()
        body.move(to: CGPoint(x: cx - h * 0.2, y: baseY))
        body.addQuadCurve(to: CGPoint(x: cx - h * 0.07, y: baseY - h * 0.45), control: CGPoint(x: cx - h * 0.09, y: baseY - h * 0.2))
        body.addQuadCurve(to: CGPoint(x: cx - h * 0.26, y: baseY - h * 0.88), control: CGPoint(x: cx - h * 0.1, y: baseY - h * 0.7))
        body.addQuadCurve(to: CGPoint(x: cx + h * 0.26, y: baseY - h * 0.88), control: CGPoint(x: cx, y: baseY - h * 0.98))
        body.addQuadCurve(to: CGPoint(x: cx + h * 0.07, y: baseY - h * 0.45), control: CGPoint(x: cx + h * 0.1, y: baseY - h * 0.7))
        body.addQuadCurve(to: CGPoint(x: cx + h * 0.2, y: baseY), control: CGPoint(x: cx + h * 0.09, y: baseY - h * 0.2))
        body.closeSubpath()
        Kit.solid(&context, body, Art.color(color), light: 0.28, shade: 0.26)
        var stalks = Path()
        var ears = Path()
        let fans: [CGFloat] = [-1, -0.6, -0.2, 0.2, 0.6, 1]
        for fan in fans {
            stalks.move(to: CGPoint(x: cx + fan * h * 0.16, y: baseY - h * 0.02))
            stalks.addQuadCurve(to: CGPoint(x: cx + fan * h * 0.21, y: baseY - h * 0.86), control: CGPoint(x: cx + fan * h * 0.02, y: baseY - h * 0.45))
            let lift: CGFloat = (1 - abs(fan)) * h * 0.07
            ears.addPath(Art.ellipse(cx + fan * h * 0.25, baseY - h * 0.9 - lift, h * 0.03, h * 0.075))
        }
        Art.stroke(&context, stalks, propTone(color, 0.7).opacity(0.6), width: min(ArtStyle.detailLine, max(0.6, h * 0.014)))
        Art.fill(&context, ears, propTone(color, 1.12))
        Art.stroke(&context, ears, propTone(color, 0.74).opacity(0.5), width: max(0.5, h * 0.008))
        let tieH: CGFloat = max(2, h * 0.07)
        let tie = Art.rect(cx - h * 0.085, baseY - h * 0.45 - tieH / 2, h * 0.17, tieH, radius: tieH * 0.4)
        Kit.solid(&context, tie, propTone(color, 0.66), light: 0.2, shade: 0.2)
    }

    /// A heap of round things (turnips, fruit, stones) on baseY: `count` rounded items (at most
    /// 21) stacked in a low pile about `width` wide; each item gets a small leaf tuft in `leaf`
    /// when non-nil.
    static func heap(
        _ context: inout GraphicsContext,
        cx: CGFloat,
        baseY: CGFloat,
        width: CGFloat,
        count: Int,
        color: UInt32,
        leaf: UInt32? = nil,
        seed: UInt32 = 1
    ) {
        let total: Int = min(21, max(1, count))
        var base: Int = 1
        while base * (base + 1) / 2 < total {
            base += 1
        }
        let r: CGFloat = width / (CGFloat(base) * 1.8 + 0.2)
        var random = ArtRandom(seed)
        Kit.shadow(&context, cx, baseY, width: width)
        var shine = Path()
        var remaining: Int = total
        var row: Int = 0
        while remaining > 0 && row < base {
            let inRow: Int = min(remaining, base - row)
            let span: CGFloat = CGFloat(inRow - 1) * r * 1.8
            let y: CGFloat = baseY - r * 0.9 - CGFloat(row) * r * 1.45
            var tufts = Path()
            for index in 0..<inRow {
                let jitter: CGFloat = (rnd(&random) - 0.5) * r * 0.24
                let x: CGFloat = cx - span / 2 + CGFloat(index) * r * 1.8 + jitter
                let wide: CGFloat = r * (0.92 + rnd(&random) * 0.16)
                let tint: CGFloat = 0.92 + rnd(&random) * 0.16
                Kit.solid(&context, Art.ellipse(x, y, wide, r * 0.9), propTone(color, tint), light: 0.3, shade: 0.3)
                shine.addPath(Art.ellipse(x - r * 0.34, y - r * 0.38, r * 0.2, r * 0.13))
                tufts.addPath(Art.ellipse(x - r * 0.14, y - r * 0.96, r * 0.12, r * 0.3))
                tufts.addPath(Art.ellipse(x + r * 0.16, y - r * 0.9, r * 0.11, r * 0.25))
            }
            if let leaf {
                Art.fill(&context, tufts, Art.color(leaf))
            }
            remaining -= inRow
            row += 1
        }
        Art.fill(&context, shine, Color.white.opacity(0.3))
    }

    /// A small table or low stand seen from the side on baseY with a top `width` wide.
    static func table(
        _ context: inout GraphicsContext,
        cx: CGFloat,
        baseY: CGFloat,
        width w: CGFloat,
        height h: CGFloat,
        color: UInt32 = 0x8A5A3A
    ) {
        Kit.shadow(&context, cx, baseY, width: w * 0.95)
        let th: CGFloat = max(2.5, h * 0.14)
        let topY: CGFloat = baseY - h
        let under: CGFloat = topY + th
        var legs = Path()
        let sides: [CGFloat] = [-1, 1]
        for side in sides {
            let leg: [CGPoint] = [
                CGPoint(x: cx + side * w * 0.4, y: under),
                CGPoint(x: cx + side * w * 0.32, y: under),
                CGPoint(x: cx + side * w * 0.36, y: baseY),
                CGPoint(x: cx + side * w * 0.43, y: baseY),
            ]
            legs.addPath(Art.polygon(leg))
        }
        Art.fill(&context, Art.rect(cx - w * 0.37, baseY - h * 0.36, w * 0.74, max(1.5, h * 0.07)), propTone(color, 0.6))
        Kit.solid(&context, legs, propTone(color, 0.78), light: 0.2, shade: 0.24)
        Art.fill(&context, Art.rect(cx - w * 0.42, under, w * 0.84, th * 0.7), propTone(color, 0.86))
        let top = Art.rect(cx - w * 0.5, topY, w, th, radius: th * 0.35)
        Kit.solid(&context, top, propTone(color, 1.12), light: 0.3, shade: 0.24)
        let edge = Art.line(cx - w * 0.46, topY + th * 0.22, cx + w * 0.4, topY + th * 0.22)
        Art.stroke(&context, edge, ArtStyle.warmLight.opacity(0.4), width: max(0.6, th * 0.16))
    }

    /// A treasure spill: a little pile of gold ovals, a roll of cloth and a red branch of coral
    /// — small, bright. About 80 units wide and 34 tall at scale 1, centred on cx.
    static func treasure(_ context: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, scale: CGFloat = 1) {
        Art.group(&context, x: cx, y: baseY, scale: scale) { g in
            Kit.shadow(&g, 0, 0, width: 80, alpha: 0.22)
            let coral: UInt32 = 0xE0453A
            let branch = Art.svg("M 24 0 C 24 -10 28 -16 28 -27 M 26 -11 C 31 -13 35 -18 36 -25 M 25 -9 C 21 -14 20 -20 18 -25 M 28 -19 C 25 -23 25 -27 23 -32")
            Art.stroke(&g, branch, Art.color(coral), width: 3.4)
            let glint = branch.applying(CGAffineTransform(translationX: -0.8, y: -0.4))
            Art.stroke(&g, glint, propTone(coral, 1.3).opacity(0.7), width: 1)
            // The roll of cloth, lying to the left, its end toward the reader.
            let silk: UInt32 = 0x3F7FC4
            Kit.solid(&g, Art.rect(-40, -13, 30, 13, radius: 6), Art.color(silk), light: 0.3, shade: 0.26)
            var bands = Path()
            bands.addPath(Art.line(-32, -12, -32, -1))
            bands.addPath(Art.line(-24, -12, -24, -1))
            Art.stroke(&g, bands, Art.color(0xFFE08A, 0.8), width: 1.4, cap: .butt)
            Art.fill(&g, Art.ellipse(-11, -6.5, 4, 6.5), propTone(silk, 1.35))
            Art.stroke(&g, Art.ellipse(-11, -6.5, 1.8, 3.2), propTone(silk, 0.7), width: 1)
            // The gold: darker edges first, then the coins, then one glint on each.
            let coins: [(CGFloat, CGFloat)] = [(-4, -3), (6, -3), (16, -3), (1, -8), (11, -8), (6, -13), (-12, -2.5), (25, -2.5)]
            var edges = Path()
            var faces = Path()
            var glints = Path()
            for coin in coins {
                edges.addPath(Art.ellipse(coin.0, coin.1 + 1.3, 5.6, 3.3))
                faces.addPath(Art.ellipse(coin.0, coin.1, 5.6, 3.3))
                glints.addPath(Art.ellipse(coin.0 - 1.8, coin.1 - 1, 1.8, 0.8))
            }
            Art.fill(&g, edges, Art.color(0xB9821C))
            Art.fill(&g, faces, Art.color(0xF4C63E))
            Art.fill(&g, glints, Color.white.opacity(0.65))
            var sparks = Path()
            sparks.addPath(Art.spark(8, -20, 3.2))
            sparks.addPath(Art.spark(-18, -18, 2.2))
            Art.fill(&g, sparks, Art.color(0xFFF6DC, 0.9))
        }
    }
}
