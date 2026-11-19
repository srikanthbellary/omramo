import SwiftUI
import OmramoCore

// The shared illustration kit (round 5): ground cover and natural objects.
//
// Grass, reeds, flowers, crops, furrows, rocks, drifts, snow blocks, corner framing, flecks,
// lily pads and winding ribbons. Everything stands on a `baseY` or is scattered over a `rect`,
// in the units of the picture's role, and is deterministic (seeded `ArtRandom` only). Repeated
// marks are batched into one `Path` per tone.

// MARK: - Small tools

extension Kit {
    /// Lighter (k > 1) or darker (k < 1) tone of a hex colour.
    static func groundTone(_ hex: UInt32, _ k: CGFloat) -> Color {
        let r: CGFloat = CGFloat((hex >> 16) & 0xFF) * k
        let g: CGFloat = CGFloat((hex >> 8) & 0xFF) * k
        let b: CGFloat = CGFloat(hex & 0xFF) * k
        let rr: UInt32 = UInt32(min(255, max(0, r)).rounded())
        let gg: UInt32 = UInt32(min(255, max(0, g)).rounded())
        let bb: UInt32 = UInt32(min(255, max(0, b)).rounded())
        let mixed: UInt32 = (rr << 16) | (gg << 8) | bb
        return Art.color(mixed)
    }

    /// Adds one tapered blade standing at (x, baseY): `width` at the foot, a point at the tip,
    /// `length` tall, its tip `lean` units to the side.
    static func groundBlade(_ path: inout Path, x: CGFloat, baseY: CGFloat, width: CGFloat, length: CGFloat, lean: CGFloat) {
        let half: CGFloat = width / 2
        let midY: CGFloat = baseY - length * 0.55
        let tip = CGPoint(x: x + lean, y: baseY - length)
        path.move(to: CGPoint(x: x - half, y: baseY))
        path.addQuadCurve(to: tip, control: CGPoint(x: x - half + lean * 0.15, y: midY))
        path.addQuadCurve(to: CGPoint(x: x + half, y: baseY), control: CGPoint(x: x + half + lean * 0.35, y: midY))
        path.closeSubpath()
    }

    /// Adds one rounded leaf growing from `base` along `angle` (radians; 0 points right,
    /// −π/2 points up), `length` long and `width` across its middle.
    static func groundLeaf(_ path: inout Path, base: CGPoint, angle: CGFloat, length: CGFloat, width: CGFloat) {
        let dx: CGFloat = cos(angle)
        let dy: CGFloat = sin(angle)
        let tip = CGPoint(x: base.x + dx * length, y: base.y + dy * length)
        let mx: CGFloat = base.x + dx * length * 0.5
        let my: CGFloat = base.y + dy * length * 0.5
        path.move(to: base)
        path.addQuadCurve(to: tip, control: CGPoint(x: mx - dy * width, y: my + dx * width))
        path.addQuadCurve(to: base, control: CGPoint(x: mx + dy * width, y: my - dx * width))
        path.closeSubpath()
    }

    /// The point at `t` (0…1) on the quadratic curve from `a` to `b` with control `c`.
    static func groundQuad(_ a: CGPoint, _ c: CGPoint, _ b: CGPoint, _ t: CGFloat) -> CGPoint {
        let u: CGFloat = 1 - t
        let k0: CGFloat = u * u
        let k1: CGFloat = 2 * u * t
        let k2: CGFloat = t * t
        let x: CGFloat = k0 * a.x + k1 * c.x + k2 * b.x
        let y: CGFloat = k0 * a.y + k1 * c.y + k2 * b.y
        return CGPoint(x: x, y: y)
    }

    /// A closed, rounded shape through `points` (the corners are cut by curves); the last
    /// point joins the first with a straight line (the flat foot of a rock).
    static func groundSmooth(_ points: [CGPoint]) -> Path {
        guard points.count > 2 else { return Art.polygon(points) }
        var path = Path()
        path.move(to: points[0])
        let last: Int = points.count - 2
        for index in 1...last {
            let p = points[index]
            let q = points[index + 1]
            let mid = CGPoint(x: (p.x + q.x) / 2, y: (p.y + q.y) / 2)
            path.addQuadCurve(to: index == last ? q : mid, control: p)
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - Grass, reeds, flowers

extension Kit {
    /// Blades of grass in small tufts scattered over `rect` (3–5 blades a tuft, leaning both ways), batched into one Path. `height` is the blade length.
    static func grass(_ context: inout GraphicsContext, in rect: CGRect, count: Int, seed: UInt32, color: Color, height: CGFloat = 8) {
        guard rect.width > 0, rect.height > 0 else { return }
        var random = ArtRandom(seed)
        var blades = Path()
        for _ in 0..<max(0, count) {
            let tx: CGFloat = rect.minX + rect.width * rnd(&random)
            let ty: CGFloat = rect.minY + rect.height * rnd(&random)
            let n: Int = 3 + min(2, Int(rnd(&random) * 3))
            for blade in 0..<n {
                let spread: CGFloat = CGFloat(blade) - CGFloat(n - 1) / 2
                let length: CGFloat = height * (0.6 + rnd(&random) * 0.4)
                let sway: CGFloat = (rnd(&random) - 0.5) * height * 0.2
                let lean: CGFloat = spread * height * 0.28 + sway
                let bx: CGFloat = tx + spread * height * 0.12
                blades.move(to: CGPoint(x: bx, y: ty))
                blades.addQuadCurve(to: CGPoint(x: bx + lean, y: ty - length), control: CGPoint(x: bx + lean * 0.15, y: ty - length * 0.6))
            }
        }
        Art.stroke(&context, blades, color, width: max(1, height * 0.14))
    }

    /// One big near tuft of long grass standing at (x, baseY), about `height` tall — for the near plane.
    static func grassTuft(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, height: CGFloat, color: UInt32 = 0x3F8A5A, seed: UInt32 = 1) {
        var random = ArtRandom(seed)
        var back = Path()
        var middle = Path()
        var lit = Path()
        let count: Int = 12
        for index in 0..<count {
            let t: CGFloat = CGFloat(index) / CGFloat(count - 1) - 0.5
            let bx: CGFloat = x + t * height * 0.42 + (rnd(&random) - 0.5) * height * 0.05
            let lean: CGFloat = t * height * 0.9 + (rnd(&random) - 0.5) * height * 0.16
            let reach: CGFloat = (0.6 + rnd(&random) * 0.4) * (1 - abs(t) * 0.5)
            let width: CGFloat = height * (0.07 + rnd(&random) * 0.04)
            let foot: CGFloat = baseY + height * 0.03
            switch index % 3 {
            case 0: groundBlade(&back, x: bx, baseY: foot, width: width, length: height * reach, lean: lean)
            case 1: groundBlade(&middle, x: bx, baseY: foot, width: width, length: height * reach * 0.92, lean: lean)
            default: groundBlade(&lit, x: bx, baseY: foot, width: width * 0.8, length: height * reach * 0.8, lean: lean * 0.8)
            }
        }
        Kit.shadow(&context, x, baseY + height * 0.02, width: height * 0.6, alpha: 0.18)
        Art.fill(&context, back, groundTone(color, 0.68))
        Art.fill(&context, middle, Art.color(color))
        Art.fill(&context, lit, groundTone(color, 1.28))
    }

    /// Tall reeds standing at (x, baseY): `count` stems with long leaves and brown heads; `papyrus` gives each stem an umbrella of fine rays instead (Nile).
    static func reeds(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, count: Int, height: CGFloat, seed: UInt32, color: UInt32 = 0x3F8A5A, papyrus: Bool = false) {
        var random = ArtRandom(seed)
        var stems = Path()
        var darkLeaves = Path()
        var litLeaves = Path()
        var heads = Path()
        var shine = Path()
        var tips = Path()
        let n: Int = max(0, count)
        for index in 0..<n {
            let offset: CGFloat = CGFloat(index) - CGFloat(n - 1) / 2
            let sx: CGFloat = x + offset * height * 0.08 + (rnd(&random) - 0.5) * height * 0.04
            let rise: CGFloat = height * (0.68 + rnd(&random) * 0.32)
            let lean: CGFloat = (rnd(&random) - 0.5) * height * 0.22 + offset * height * 0.02
            let foot = CGPoint(x: sx, y: baseY)
            let top = CGPoint(x: sx + lean, y: baseY - rise)
            let bend = CGPoint(x: sx + lean * 0.15, y: baseY - rise * 0.55)
            stems.move(to: foot)
            stems.addQuadCurve(to: top, control: bend)
            let leafWidth: CGFloat = max(2, height * 0.035)
            let outL: CGFloat = -height * (0.08 + rnd(&random) * 0.1)
            let outR: CGFloat = height * (0.08 + rnd(&random) * 0.1)
            groundBlade(&darkLeaves, x: sx - leafWidth * 0.4, baseY: baseY, width: leafWidth, length: rise * 0.62, lean: outL)
            groundBlade(&litLeaves, x: sx + leafWidth * 0.4, baseY: baseY, width: leafWidth, length: rise * 0.5, lean: outR)
            if papyrus {
                groundPapyrus(&heads, &tips, at: top, reach: height * 0.16)
            } else {
                let a = groundQuad(foot, bend, top, 0.72)
                let b = groundQuad(foot, bend, top, 0.92)
                heads.move(to: a)
                heads.addLine(to: b)
                let shift: CGFloat = max(0.6, height * 0.01)
                shine.move(to: CGPoint(x: a.x - shift, y: a.y - shift))
                shine.addLine(to: CGPoint(x: b.x - shift, y: b.y + shift))
            }
        }
        Art.fill(&context, darkLeaves, groundTone(color, 0.7))
        Art.stroke(&context, stems, groundTone(color, 0.82), width: max(1.2, height * 0.014))
        Art.fill(&context, litLeaves, groundTone(color, 1.12))
        if papyrus {
            Art.stroke(&context, heads, groundTone(color, 1.2), width: max(0.8, height * 0.008))
            Art.fill(&context, tips, Art.color(0xD9B35A))
        } else {
            let thick: CGFloat = max(2.4, height * 0.045)
            Art.stroke(&context, heads, Art.color(0x7A4A2A), width: thick)
            Art.stroke(&context, shine, Art.color(0xB98552, 0.8), width: thick * 0.3)
        }
    }

    /// Adds the umbrella of a papyrus head at `top`: fine drooping rays and a dot on each tip.
    static func groundPapyrus(_ rays: inout Path, _ tips: inout Path, at top: CGPoint, reach: CGFloat) {
        let count: Int = 11
        for index in 0..<count {
            let a: CGFloat = Kit.deg(-168 + 156 * CGFloat(index) / CGFloat(count - 1))
            let droop: CGFloat = reach * 0.3 * abs(cos(a))
            let end = CGPoint(x: top.x + cos(a) * reach, y: top.y + sin(a) * reach * 0.8 + droop)
            let control = CGPoint(x: top.x + cos(a) * reach * 0.5, y: top.y + sin(a) * reach * 0.95)
            rays.move(to: top)
            rays.addQuadCurve(to: end, control: control)
            let r: CGFloat = max(0.7, reach * 0.035)
            tips.addEllipse(in: CGRect(x: end.x - r, y: end.y - r, width: r * 2, height: r * 2))
        }
    }

    /// Small flowers scattered over `rect`: four or five petals round a heart, a short stem.
    static func flowers(_ context: inout GraphicsContext, in rect: CGRect, count: Int, seed: UInt32, petal: UInt32, heart: UInt32 = 0xFFB62E) {
        guard rect.width > 0, rect.height > 0 else { return }
        var random = ArtRandom(seed)
        var stems = Path()
        var petals = Path()
        var shaded = Path()
        var hearts = Path()
        for _ in 0..<max(0, count) {
            let fx: CGFloat = rect.minX + rect.width * rnd(&random)
            let fy: CGFloat = rect.minY + rect.height * rnd(&random)
            let r: CGFloat = 2.2 + rnd(&random) * 1.4
            let n: Int = rnd(&random) < 0.5 ? 4 : 5
            let turn: CGFloat = rnd(&random) * CGFloat.pi
            let stemLean: CGFloat = (rnd(&random) - 0.5) * r * 2
            stems.move(to: CGPoint(x: fx + stemLean, y: fy + r * 3.2))
            stems.addQuadCurve(to: CGPoint(x: fx, y: fy), control: CGPoint(x: fx + stemLean, y: fy + r * 1.4))
            for index in 0..<n {
                let a: CGFloat = turn + 2 * CGFloat.pi * CGFloat(index) / CGFloat(n)
                let px: CGFloat = fx + cos(a) * r * 0.78
                let py: CGFloat = fy + sin(a) * r * 0.78
                let pr: CGFloat = r * 0.62
                let dot = CGRect(x: px - pr, y: py - pr, width: pr * 2, height: pr * 2)
                // Petals on the lower right sit in the flower's own shade.
                if cos(a) + sin(a) > 0.6 {
                    shaded.addEllipse(in: dot)
                } else {
                    petals.addEllipse(in: dot)
                }
            }
            let hr: CGFloat = r * 0.42
            hearts.addEllipse(in: CGRect(x: fx - hr, y: fy - hr, width: hr * 2, height: hr * 2))
        }
        Art.stroke(&context, stems, Art.color(0x3F8A5A), width: 1.1)
        Art.fill(&context, shaded, groundTone(petal, 0.84))
        Art.fill(&context, petals, Art.color(petal))
        Art.fill(&context, hearts, Art.color(heart))
    }
}

// MARK: - Crops and ploughed earth

extension Kit {
    /// A row crop seen from the side from x0 to x1 standing on baseY: `tops` true = leafy tops of a root crop (turnip, beet: rosettes of rounded leaves); false = ears of grain (rye, wheat: thin stalks with bending ears), `height` tall.
    static func crop(_ context: inout GraphicsContext, x0: CGFloat, x1: CGFloat, baseY: CGFloat, height: CGFloat, tops: Bool, color: UInt32, seed: UInt32 = 1) {
        guard x1 > x0, height > 0 else { return }
        if tops {
            groundRosettes(&context, x0: x0, x1: x1, baseY: baseY, height: height, color: color, seed: seed)
        } else {
            groundEars(&context, x0: x0, x1: x1, baseY: baseY, height: height, color: color, seed: seed)
        }
    }

    /// The leafy tops of a root crop: a fan of five rounded leaves every `height` or so.
    static func groundRosettes(_ context: inout GraphicsContext, x0: CGFloat, x1: CGFloat, baseY: CGFloat, height: CGFloat, color: UInt32, seed: UInt32) {
        var random = ArtRandom(seed)
        var back = Path()
        var front = Path()
        var ribs = Path()
        let step: CGFloat = max(4, height * 0.95)
        var px: CGFloat = x0 + step * 0.5
        while px < x1 {
            let base = CGPoint(x: px + (rnd(&random) - 0.5) * step * 0.15, y: baseY)
            for index in 0..<5 {
                let fan: CGFloat = -160 + 35 * CGFloat(index)
                let a: CGFloat = Kit.deg(fan + (rnd(&random) - 0.5) * 14)
                let upright: CGFloat = abs(sin(a))
                let length: CGFloat = height * (0.62 + 0.38 * upright) * (0.85 + rnd(&random) * 0.15)
                if index % 2 == 0 {
                    groundLeaf(&back, base: base, angle: a, length: length, width: length * 0.5)
                } else {
                    groundLeaf(&front, base: base, angle: a, length: length, width: length * 0.5)
                }
                ribs.move(to: base)
                ribs.addLine(to: CGPoint(x: base.x + cos(a) * length * 0.8, y: base.y + sin(a) * length * 0.8))
            }
            px += step
        }
        Art.fill(&context, back, groundTone(color, 0.76))
        Art.fill(&context, front, Art.color(color))
        Art.stroke(&context, ribs, groundTone(color, 1.3).opacity(0.6), width: max(0.8, height * 0.03))
    }

    /// Standing grain: thin stalks, each with a bending ear and a whisker.
    static func groundEars(_ context: inout GraphicsContext, x0: CGFloat, x1: CGFloat, baseY: CGFloat, height: CGFloat, color: UInt32, seed: UInt32) {
        var random = ArtRandom(seed)
        var stalks = Path()
        var ears = Path()
        var awns = Path()
        let step: CGFloat = max(3, height * 0.14)
        var px: CGFloat = x0 + step * 0.5
        while px < x1 {
            let rise: CGFloat = height * (0.8 + rnd(&random) * 0.2)
            let lean: CGFloat = (rnd(&random) - 0.35) * height * 0.3
            let neck = CGPoint(x: px + lean * 0.5, y: baseY - rise * 0.72)
            stalks.move(to: CGPoint(x: px, y: baseY))
            stalks.addQuadCurve(to: neck, control: CGPoint(x: px, y: baseY - rise * 0.45))
            let a: CGFloat = Kit.deg(-90) + lean / height * 2.2
            let earLength: CGFloat = rise * 0.3
            groundLeaf(&ears, base: neck, angle: a, length: earLength, width: max(2, height * 0.07))
            let tip = CGPoint(x: neck.x + cos(a) * earLength, y: neck.y + sin(a) * earLength)
            awns.move(to: tip)
            awns.addLine(to: CGPoint(x: tip.x + cos(a) * earLength * 0.4, y: tip.y + sin(a) * earLength * 0.4))
            px += step * (0.8 + rnd(&random) * 0.4)
        }
        Art.stroke(&context, stalks, groundTone(color, 0.76), width: max(0.9, height * 0.02))
        Art.fill(&context, ears, Art.color(color))
        Art.stroke(&context, awns, groundTone(color, 1.15), width: 0.8)
    }

    /// A field of standing grain as a mass: a band from x0 to x1 whose top edge is a soft bristly line `height` above baseY, with ears along the top — cheaper than `crop` for a whole field.
    static func grainField(_ context: inout GraphicsContext, x0: CGFloat, x1: CGFloat, baseY: CGFloat, height: CGFloat, color: UInt32 = 0xE0B040, seed: UInt32 = 1) {
        guard x1 > x0, height > 0 else { return }
        var random = ArtRandom(seed)
        let top: CGFloat = baseY - height
        let step: CGFloat = max(4, height * 0.1)
        let earLength: CGFloat = min(16, height * 0.22)
        var mass = Path()
        var ears = Path()
        var stalks = Path()
        mass.move(to: CGPoint(x: x0, y: baseY))
        var px: CGFloat = x0
        var up = true
        while px <= x1 {
            let dip: CGFloat = up ? 0 : height * 0.07
            let y: CGFloat = top + dip + rnd(&random) * height * 0.06
            mass.addLine(to: CGPoint(x: px, y: y))
            if up {
                let a: CGFloat = Kit.deg(-90 + (rnd(&random) - 0.5) * 50)
                groundLeaf(&ears, base: CGPoint(x: px, y: y + earLength * 0.25), angle: a, length: earLength, width: max(1.6, earLength * 0.3))
                let sway: CGFloat = (rnd(&random) - 0.5) * step
                stalks.move(to: CGPoint(x: px, y: y + earLength * 0.5))
                stalks.addLine(to: CGPoint(x: px + sway, y: y + height * 0.7))
            }
            px += step
            up.toggle()
        }
        mass.addLine(to: CGPoint(x: x1, y: top + height * 0.05))
        mass.addLine(to: CGPoint(x: x1, y: baseY))
        mass.closeSubpath()
        let fill: Stops = [(groundTone(color, 1.1), 0), (Art.color(color), 0.4), (groundTone(color, 0.74), 1)]
        solid(&context, mass, stops: fill, light: 0.16, shade: 0.12)
        let stalkColor: Color = groundTone(color, 0.68).opacity(0.35)
        let stalkLines: Path = stalks
        Art.clipped(&context, to: mass) { g in
            Art.stroke(&g, stalkLines, stalkColor, width: 1)
        }
        Art.fill(&context, ears, groundTone(color, 1.2))
    }

    /// Ploughed furrows from x0 to x1 between top and bottom: dark and light earth lines converging slightly toward the top.
    static func furrows(_ context: inout GraphicsContext, x0: CGFloat, x1: CGFloat, top: CGFloat, bottom: CGFloat, color: UInt32 = 0x6B4A32, count: Int = 9) {
        guard x1 > x0, bottom > top, count > 0 else { return }
        let cx: CGFloat = (x0 + x1) / 2
        let gap: CGFloat = (x1 - x0) / CGFloat(count)
        let wb: CGFloat = gap * 0.24
        let wt: CGFloat = gap * 0.1
        var dark = Path()
        var lit = Path()
        for index in 0..<count {
            let bx: CGFloat = x0 + gap * (CGFloat(index) + 0.5)
            let tx: CGFloat = cx + (bx - cx) * 0.72
            // The lit side of each ridge faces the light (left); its shaded side lies to the right.
            let shadeSide: [CGPoint] = [pt(tx, top), pt(tx + wt, top), pt(bx + wb, bottom), pt(bx, bottom)]
            let lightSide: [CGPoint] = [pt(tx - wt, top), pt(tx, top), pt(bx, bottom), pt(bx - wb, bottom)]
            dark.addPath(Art.polygon(shadeSide))
            lit.addPath(Art.polygon(lightSide))
        }
        Art.fill(&context, dark, groundTone(color, 0.7))
        Art.fill(&context, lit, groundTone(color, 1.32).opacity(0.75))
    }
}

// MARK: - Rocks and stones

extension Kit {
    /// A boulder standing on baseY: an irregular built shape (seeded), lit upper-left, shaded lower-right, one or two cracks, a contact shadow.
    static func rock(_ context: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, width: CGFloat, height: CGFloat, color: UInt32 = 0x8A8478, seed: UInt32 = 1) {
        guard width > 0, height > 0 else { return }
        var random = ArtRandom(seed)
        let shape = groundLump(cx: cx, baseY: baseY, width: width, height: height, random: &random)
        let half: CGFloat = width / 2
        let top: CGFloat = baseY - height * 1.05
        let ridgeX: CGFloat = cx + (rnd(&random) - 0.5) * width * 0.2
        let twoCracks: Bool = rnd(&random) > 0.4
        let knee = CGPoint(x: ridgeX - width * 0.08, y: baseY - height * 0.52)
        Kit.shadow(&context, cx, baseY, width: width)
        solid(&context, shape, Art.color(color), light: 0.3, shade: 0.3, rim: 2.4)
        let litFacet: [CGPoint] = [pt(cx - half, top), pt(ridgeX + width * 0.12, top), knee, pt(cx - half, baseY - height * 0.38)]
        let shadeFacet: [CGPoint] = [pt(ridgeX + width * 0.12, top), pt(cx + half, top), pt(cx + half, baseY), pt(ridgeX + width * 0.2, baseY), knee]
        var cracks = Path()
        cracks.move(to: knee)
        cracks.addLine(to: CGPoint(x: ridgeX - width * 0.02, y: baseY - height * 0.3))
        cracks.addLine(to: CGPoint(x: ridgeX - width * 0.1, y: baseY - height * 0.12))
        if twoCracks {
            cracks.move(to: CGPoint(x: cx + width * 0.2, y: baseY - height * 0.62))
            cracks.addLine(to: CGPoint(x: cx + width * 0.27, y: baseY - height * 0.36))
        }
        let crackLines: Path = cracks
        let crackColor: Color = groundTone(color, 0.6).opacity(0.7)
        let bounds = CGRect(x: cx - half, y: top, width: width, height: height * 1.05)
        Art.clipped(&context, to: shape) { g in
            Art.fill(&g, Art.polygon(litFacet), ArtStyle.warmLight.opacity(0.14))
            Art.fill(&g, Art.polygon(shadeFacet), ArtStyle.coolShade.opacity(0.14))
            Art.stroke(&g, crackLines, crackColor, width: ArtStyle.detailLine)
            ArtStyle.tooth(&g, in: bounds, seed: seed &+ 9, alpha: 0.06)
        }
        // A small stone at its foot, on the lit side, so the boulder is not one lone lump.
        let small = groundLump(cx: cx - half * 0.92, baseY: baseY + height * 0.02, width: width * 0.26, height: height * 0.2, random: &random)
        solid(&context, small, groundTone(color, 1.06), light: 0.3, shade: 0.26, rim: 1.4)
    }

    /// The outline of a boulder: a flat foot and a seeded, rounded, slightly flat-topped back.
    static func groundLump(cx: CGFloat, baseY: CGFloat, width: CGFloat, height: CGFloat, random: inout ArtRandom) -> Path {
        let half: CGFloat = width / 2
        let steps: Int = 7
        var points: [CGPoint] = [CGPoint(x: cx - half, y: baseY)]
        for index in 1..<steps {
            let a: CGFloat = CGFloat.pi * (1 + CGFloat(index) / CGFloat(steps))
            let jitter: CGFloat = 0.82 + rnd(&random) * 0.22
            let lift: CGFloat = min(1, abs(sin(a)) * 1.3)
            let px: CGFloat = cx + cos(a) * half * jitter
            let py: CGFloat = baseY - height * lift * jitter
            points.append(CGPoint(x: px, y: py))
        }
        points.append(CGPoint(x: cx + half, y: baseY))
        return groundSmooth(points)
    }

    /// A few small stones scattered over `rect`.
    static func pebbles(_ context: inout GraphicsContext, in rect: CGRect, count: Int, seed: UInt32, color: UInt32 = 0x9A9488) {
        guard rect.width > 0, rect.height > 0 else { return }
        var random = ArtRandom(seed)
        var shadows = Path()
        var stones = Path()
        var lights = Path()
        for _ in 0..<max(0, count) {
            let x: CGFloat = rect.minX + rect.width * rnd(&random)
            let y: CGFloat = rect.minY + rect.height * rnd(&random)
            let rx: CGFloat = 2 + rnd(&random) * 3.2
            let ry: CGFloat = rx * (0.5 + rnd(&random) * 0.25)
            let shadowX: CGFloat = x - rx + 1.2
            let shadowY: CGFloat = y - ry * 0.4 + 1
            shadows.addEllipse(in: CGRect(x: shadowX, y: shadowY, width: rx * 2.1, height: ry * 1.7))
            stones.addEllipse(in: CGRect(x: x - rx, y: y - ry, width: rx * 2, height: ry * 2))
            // A second, smaller lobe makes each stone a built shape, not an ellipse.
            stones.addEllipse(in: CGRect(x: x - rx * 0.2, y: y - ry * 1.15, width: rx * 1.1, height: ry * 1.5))
            lights.addEllipse(in: CGRect(x: x - rx * 0.7, y: y - ry * 0.8, width: rx * 0.9, height: ry * 0.7))
        }
        Art.fill(&context, shadows, ArtStyle.coolShade.opacity(0.2))
        Art.fill(&context, stones, Art.color(color))
        Art.fill(&context, lights, groundTone(color, 1.3).opacity(0.7))
    }
}

// MARK: - Drifts, dunes and snow blocks

extension Kit {
    /// A snow drift (`snow` true: white with blue-lilac shade) or a sand dune (false: warm sand with a sharp lit crest) from x0 to x1 on baseY, filled down to `bottom`.
    static func drift(_ context: inout GraphicsContext, x0: CGFloat, x1: CGFloat, baseY: CGFloat, height: CGFloat, bottom: CGFloat, snow: Bool) {
        guard x1 > x0 else { return }
        let span: CGFloat = x1 - x0
        let crest: CGFloat = snow ? 0.45 : 0.6
        let peak = CGPoint(x: x0 + span * crest, y: baseY - height)
        let run: CGFloat = x1 - peak.x
        let c1: CGPoint
        let c2: CGPoint
        if snow {
            // A soft round back: level tangents at the crest.
            c1 = CGPoint(x: x0 + span * crest * 0.5, y: baseY - height)
            c2 = CGPoint(x: peak.x + run * 0.5, y: baseY - height)
        } else {
            // A hollow windward slope and a steep lee slope meet in a sharp crest.
            c1 = CGPoint(x: x0 + span * crest * 0.6, y: baseY - height * 0.2)
            c2 = CGPoint(x: peak.x + run * 0.3, y: baseY - height * 0.3)
        }
        let start = CGPoint(x: x0, y: baseY)
        var shape = Path()
        shape.move(to: CGPoint(x: x0, y: bottom))
        shape.addLine(to: start)
        shape.addQuadCurve(to: peak, control: c1)
        shape.addQuadCurve(to: CGPoint(x: x1, y: baseY), control: c2)
        shape.addLine(to: CGPoint(x: x1, y: bottom))
        shape.closeSubpath()
        if snow {
            groundSnowDrift(&context, shape, peak: peak, x1: x1, baseY: baseY, bottom: bottom)
        } else {
            groundSandDune(&context, shape, start: start, control: c1, peak: peak, x1: x1, bottom: bottom)
        }
    }

    /// The paint of a snow drift: white going to pale lilac, and a blue-lilac hollow on the lee side.
    static func groundSnowDrift(_ context: inout GraphicsContext, _ shape: Path, peak: CGPoint, x1: CGFloat, baseY: CGFloat, bottom: CGFloat) {
        let fill: Stops = [(Art.color(0xFFFFFF), 0), (Art.color(0xEEF1FC), 0.45), (Art.color(0xCDD3F2), 1)]
        solid(&context, shape, stops: fill, light: 0.08, shade: 0.14, rim: 2.4)
        let run: CGFloat = x1 - peak.x
        let drop: CGFloat = max(1, baseY - peak.y)
        let from = CGPoint(x: peak.x + run * 0.12, y: peak.y + drop * 0.22)
        var hollow = Path()
        hollow.move(to: from)
        hollow.addQuadCurve(to: CGPoint(x: x1, y: baseY + drop * 0.1), control: CGPoint(x: peak.x + run * 0.7, y: peak.y + drop * 0.25))
        hollow.addLine(to: CGPoint(x: x1, y: bottom))
        hollow.addLine(to: CGPoint(x: peak.x + run * 0.45, y: bottom))
        hollow.addQuadCurve(to: from, control: CGPoint(x: peak.x + run * 0.2, y: baseY + drop * 0.3))
        hollow.closeSubpath()
        let shadeColor: Color = Art.color(0xB4BAEE, 0.28)
        Art.clipped(&context, to: shape) { g in
            Art.fill(&g, hollow, shadeColor)
        }
    }

    /// The paint of a sand dune: warm sand, a shaded slip face right of the crest, a bright
    /// line along the windward edge up to the crest, and a few wind ripples.
    static func groundSandDune(_ context: inout GraphicsContext, _ shape: Path, start: CGPoint, control: CGPoint, peak: CGPoint, x1: CGFloat, bottom: CGFloat) {
        let fill: Stops = [(Art.color(0xF4D592), 0), (Art.color(0xE6BA6E), 0.5), (Art.color(0xD09B56), 1)]
        solid(&context, shape, stops: fill, light: 0.2, shade: 0.1)
        let run: CGFloat = x1 - peak.x
        let drop: CGFloat = max(1, start.y - peak.y)
        var lee = Path()
        lee.move(to: peak)
        lee.addLine(to: CGPoint(x: x1, y: peak.y))
        lee.addLine(to: CGPoint(x: x1, y: bottom))
        lee.addLine(to: CGPoint(x: peak.x + run * 0.14, y: bottom))
        lee.addQuadCurve(to: peak, control: CGPoint(x: peak.x - run * 0.1, y: Kit.mix(peak.y, bottom, 0.5)))
        lee.closeSubpath()
        var windward = Path()
        windward.move(to: start)
        windward.addQuadCurve(to: peak, control: control)
        var marks = Path()
        for index in 0..<4 {
            let t: CGFloat = 0.22 + 0.17 * CGFloat(index)
            let p = groundQuad(start, control, peak, t)
            let y: CGFloat = p.y + drop * (0.22 + 0.08 * CGFloat(index))
            let length: CGFloat = (peak.x - start.x) * 0.16
            marks.move(to: CGPoint(x: p.x - length / 2, y: y))
            marks.addQuadCurve(to: CGPoint(x: p.x + length / 2, y: y - length * 0.12), control: CGPoint(x: p.x, y: y + 2))
        }
        Art.clipped(&context, to: shape) { g in
            Art.fill(&g, lee, Art.color(0xB67A44, 0.42))
            Art.stroke(&g, marks, Art.color(0xC08A4C, 0.35), width: 1.2)
            Art.stroke(&g, windward, Art.color(0xFFF3CC, 0.85), width: 2.4)
        }
    }

    /// A block of cut snow (for a snow house): a slightly tapered slab `width` × `height` standing on (x, baseY) (x = its left), white with a pale blue shaded right/bottom face.
    /// `tilt` turns it (radians, clockwise) about the middle of its foot.
    static func snowBlock(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, width: CGFloat, height: CGFloat, tilt: CGFloat = 0) {
        guard width > 0, height > 0 else { return }
        let half: CGFloat = width / 2
        let inset: CGFloat = width * 0.04
        let side: CGFloat = width * 0.14
        let foot: CGFloat = height * 0.16
        let outline: [CGPoint] = [pt(-half, 0), pt(-half + inset, -height), pt(half - inset, -height), pt(half, 0)]
        let right: [CGPoint] = [pt(half - inset - side, -height), pt(half - inset, -height), pt(half, 0), pt(half - side, 0)]
        let slab: Path = Art.polygon(outline)
        Art.group(&context, x: x + half, y: baseY, rotate: tilt) { g in
            Art.fill(&g, slab, Art.color(0xFAFCFF))
            Art.clipped(&g, to: slab) { face in
                Art.fill(&face, Art.rect(-half, -foot, width, foot), Art.color(0xDCE8F8))
                Art.fill(&face, Art.polygon(right), Art.color(0xC9DCF2))
                Art.stroke(&face, Art.line(-half, -height, half, -height), Color.white, width: 3)
            }
            Kit.model(&g, slab, light: 0.12, shade: 0.12, rim: 1.6)
            Art.stroke(&g, slab, Art.color(0xA9BEDD, 0.55), width: 1.2)
        }
    }
}

// MARK: - Near-plane framing and specks

extension Kit {
    /// Near-plane framing: dark leaves on a bough hanging into a top corner, or blades and leaves standing up from a bottom corner. `corner`: 0 top-left, 1 top-right, 2 bottom-left, 3 bottom-right. About 150 × 120 units at scale 1.
    static func cornerLeaves(_ context: inout GraphicsContext, size: CGSize, corner: Int, color: Color, scale: CGFloat = 1, seed: UInt32 = 1) {
        let onLeft: Bool
        let onTop: Bool
        switch corner {
        case 0:
            onLeft = true
            onTop = true
        case 1:
            onLeft = false
            onTop = true
        case 2:
            onLeft = true
            onTop = false
        default:
            onLeft = false
            onTop = false
        }
        let ox: CGFloat = onLeft ? 0 : size.width
        let oy: CGFloat = onTop ? 0 : size.height
        let flip: CGFloat = onLeft ? 1 : -1
        // Drawn as a left corner with the origin in the corner; a right corner is its mirror.
        Art.group(&context, x: ox, y: oy, scale: scale, scaleX: flip) { g in
            if onTop {
                groundBough(&g, color: color, seed: seed)
            } else {
                groundCornerBlades(&g, color: color, seed: seed)
            }
        }
    }

    /// A bough hanging into the top-left corner (origin in the corner, y down).
    static func groundBough(_ context: inout GraphicsContext, color: Color, seed: UInt32) {
        var random = ArtRandom(seed)
        let a = CGPoint(x: -12, y: 14)
        let c = CGPoint(x: 62, y: 16)
        let b = CGPoint(x: 128, y: 58)
        var bough = Path()
        bough.move(to: a)
        bough.addQuadCurve(to: b, control: c)
        var back = Path()
        var front = Path()
        var lit = Path()
        let count: Int = 13
        for index in 0..<count {
            let t: CGFloat = 0.06 + 0.94 * CGFloat(index) / CGFloat(count - 1)
            let p = groundQuad(a, c, b, t)
            let side: CGFloat = index % 2 == 0 ? 1 : -1
            let hang: CGFloat = 78 + side * 34 + (rnd(&random) - 0.5) * 24
            let length: CGFloat = 30 + rnd(&random) * 16 - t * 6
            switch index % 3 {
            case 0: groundLeaf(&back, base: p, angle: Kit.deg(hang), length: length, width: length * 0.5)
            case 1: groundLeaf(&front, base: p, angle: Kit.deg(hang), length: length, width: length * 0.5)
            default: groundLeaf(&lit, base: p, angle: Kit.deg(hang), length: length * 0.9, width: length * 0.45)
            }
            if index < 5 {
                // Leaves above the bough, cut by the frame, close the corner.
                let up: CGFloat = -24 - rnd(&random) * 44
                groundLeaf(&back, base: p, angle: Kit.deg(up), length: 32, width: 16)
            }
        }
        groundLeaf(&front, base: b, angle: Kit.deg(42), length: 34, width: 16)
        Art.stroke(&context, bough, color, width: 5)
        groundFramePaint(&context, back: back, front: front, lit: lit, color: color)
    }

    /// Blades and two broad leaves standing up from the bottom-left corner (origin in the
    /// corner, y up is negative).
    static func groundCornerBlades(_ context: inout GraphicsContext, color: Color, seed: UInt32) {
        var random = ArtRandom(seed)
        var back = Path()
        var front = Path()
        var lit = Path()
        groundLeaf(&back, base: CGPoint(x: 10, y: 6), angle: Kit.deg(-62), length: 86, width: 34)
        groundLeaf(&front, base: CGPoint(x: 54, y: 8), angle: Kit.deg(-36), length: 66, width: 28)
        let count: Int = 10
        for index in 0..<count {
            let t: CGFloat = CGFloat(index) / CGFloat(count - 1)
            let bx: CGFloat = -6 + t * 120 + (rnd(&random) - 0.5) * 8
            let length: CGFloat = (112 - 62 * t) * (0.8 + rnd(&random) * 0.2)
            let lean: CGFloat = (t - 0.25) * 60 + (rnd(&random) - 0.5) * 14
            let width: CGFloat = 9 + rnd(&random) * 5
            switch index % 3 {
            case 0: groundBlade(&back, x: bx, baseY: 8, width: width, length: length, lean: lean)
            case 1: groundBlade(&front, x: bx, baseY: 8, width: width, length: length * 0.9, lean: lean)
            default: groundBlade(&lit, x: bx, baseY: 8, width: width * 0.8, length: length * 0.72, lean: lean * 0.8)
            }
        }
        groundFramePaint(&context, back: back, front: front, lit: lit, color: color)
    }

    /// Three tones from one colour: the back leaves in shade, the front ones plain, a few lit.
    static func groundFramePaint(_ context: inout GraphicsContext, back: Path, front: Path, lit: Path, color: Color) {
        Art.fill(&context, back, color)
        Art.fill(&context, back, ArtStyle.coolShade.opacity(0.26))
        Art.fill(&context, front, color)
        Art.fill(&context, lit, color)
        Art.fill(&context, lit, ArtStyle.warmLight.opacity(0.16))
    }

    /// Still specks over `rect`: falling snow, drifting dust motes, fireflies (with `glow`: each gets a soft halo via `Art.glow`).
    static func flecks(_ context: inout GraphicsContext, in rect: CGRect, count: Int, seed: UInt32, color: Color, radius: ClosedRange<Double> = 0.8...2.2, glow: Bool = false) {
        guard rect.width > 0, rect.height > 0 else { return }
        var random = ArtRandom(seed)
        var dots = Path()
        for _ in 0..<max(0, count) {
            let x: CGFloat = rect.minX + rect.width * rnd(&random)
            let y: CGFloat = rect.minY + rect.height * rnd(&random)
            let r: CGFloat = random.next(in: radius)
            if glow {
                Art.glow(&context, x, y, r * 4.5, color, alpha: 0.45)
            }
            dots.addEllipse(in: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2))
        }
        Art.fill(&context, dots, color)
    }
}

// MARK: - On and through the ground: lily pads, streams and paths

extension Kit {
    /// A lily pad on water at (cx, cy), `r` wide, with an optional flower.
    /// `r` is the pad's half-width; it lies flat, about 0.38 as deep as it is wide.
    static func lilyPad(_ context: inout GraphicsContext, cx: CGFloat, cy: CGFloat, r: CGFloat, flower: Bool = false, pad: UInt32 = 0x2E8A5A) {
        guard r > 0 else { return }
        let ry: CGFloat = r * 0.38
        let centre = CGPoint(x: cx, y: cy)
        // A round leaf with a notch cut toward the upper right.
        var points: [CGPoint] = [centre]
        let steps: Int = 28
        for index in 0...steps {
            let a: CGFloat = Kit.deg(-40 + 320 * CGFloat(index) / CGFloat(steps))
            points.append(CGPoint(x: cx + cos(a) * r, y: cy + sin(a) * ry))
        }
        let leafShape: Path = Art.polygon(points)
        var veins = Path()
        for index in 0..<6 {
            let a: CGFloat = Kit.deg(10 + 50 * CGFloat(index))
            veins.move(to: centre)
            veins.addLine(to: CGPoint(x: cx + cos(a) * r * 0.86, y: cy + sin(a) * ry * 0.86))
        }
        var rim = Path()
        for index in 0...8 {
            let a: CGFloat = Kit.deg(165 + 10 * CGFloat(index))
            let p = CGPoint(x: cx + cos(a) * r * 0.96, y: cy + sin(a) * ry * 0.96)
            if index == 0 {
                rim.move(to: p)
            } else {
                rim.addLine(to: p)
            }
        }
        Art.fill(&context, Art.ellipse(cx + r * 0.06, cy + ry * 0.3, r, ry), ArtStyle.coolShade.opacity(0.18))
        solid(&context, leafShape, Art.color(pad), light: 0.3, shade: 0.2)
        Art.stroke(&context, veins, groundTone(pad, 0.74).opacity(0.6), width: max(0.7, r * 0.03))
        Art.stroke(&context, rim, groundTone(pad, 1.4).opacity(0.8), width: max(0.8, r * 0.05))
        if flower {
            groundLotus(&context, x: cx - r * 0.12, y: cy - ry * 0.1, size: r * 0.58)
        }
    }

    /// A small water-lily flower sitting at (x, y): three pink petals behind, two pale ones
    /// in front, a yellow heart. `size` is the length of a petal.
    static func groundLotus(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, size: CGFloat) {
        let base = CGPoint(x: x, y: y)
        var back = Path()
        var front = Path()
        let backAngles: [CGFloat] = [-140, -90, -40]
        let frontAngles: [CGFloat] = [-116, -64]
        for angle in backAngles {
            groundLeaf(&back, base: base, angle: Kit.deg(angle), length: size, width: size * 0.5)
        }
        for angle in frontAngles {
            groundLeaf(&front, base: base, angle: Kit.deg(angle), length: size * 0.78, width: size * 0.46)
        }
        Art.fill(&context, back, Art.color(0xFF9EC0))
        Art.fill(&context, front, Art.color(0xFFD9E6))
        Art.fill(&context, Art.ellipse(x, y - size * 0.1, size * 0.16, size * 0.1), Art.color(0xFFC93C))
    }

    /// A winding stream or path seen in perspective: a ribbon from (nearX, nearY) `nearWidth` wide to (farX, farY) `farWidth` wide, with one soft S-bend, filled with `stops` top to bottom.
    static func ribbon(_ context: inout GraphicsContext, nearX: CGFloat, nearY: CGFloat, nearWidth: CGFloat, farX: CGFloat, farY: CGFloat, farWidth: CGFloat, stops: Stops) {
        let rise: CGFloat = farY - nearY
        let bend: CGFloat = nearWidth * 0.7
        let nh: CGFloat = nearWidth / 2
        let fh: CGFloat = farWidth / 2
        // The ribbon narrows faster than it climbs, as a flat thing seen in perspective does.
        let w1: CGFloat = Kit.mix(nearWidth, farWidth, 0.5) / 2
        let w2: CGFloat = Kit.mix(nearWidth, farWidth, 0.85) / 2
        let c1 = CGPoint(x: nearX + bend, y: nearY + rise * 0.35)
        let c2 = CGPoint(x: farX - bend * 0.6, y: nearY + rise * 0.72)
        var leftEdge = Path()
        leftEdge.move(to: CGPoint(x: nearX - nh, y: nearY))
        leftEdge.addCurve(to: CGPoint(x: farX - fh, y: farY), control1: CGPoint(x: c1.x - w1, y: c1.y), control2: CGPoint(x: c2.x - w2, y: c2.y))
        var rightEdge = Path()
        rightEdge.move(to: CGPoint(x: farX + fh, y: farY))
        rightEdge.addCurve(to: CGPoint(x: nearX + nh, y: nearY), control1: CGPoint(x: c2.x + w2, y: c2.y), control2: CGPoint(x: c1.x + w1, y: c1.y))
        var shape = Path()
        shape.move(to: CGPoint(x: nearX - nh, y: nearY))
        shape.addCurve(to: CGPoint(x: farX - fh, y: farY), control1: CGPoint(x: c1.x - w1, y: c1.y), control2: CGPoint(x: c2.x - w2, y: c2.y))
        shape.addLine(to: CGPoint(x: farX + fh, y: farY))
        shape.addCurve(to: CGPoint(x: nearX + nh, y: nearY), control1: CGPoint(x: c2.x + w2, y: c2.y), control2: CGPoint(x: c1.x + w1, y: c1.y))
        shape.closeSubpath()
        let topY: CGFloat = min(nearY, farY)
        let bottomY: CGFloat = max(nearY, farY)
        Art.fillLinear(&context, shape, stops, from: CGPoint(x: 0, y: topY), to: CGPoint(x: 0, y: bottomY))
        // The bank toward the light catches it; the other lies in a little shade.
        Art.stroke(&context, leftEdge, Color.white.opacity(0.22), width: 1.4)
        Art.stroke(&context, rightEdge, ArtStyle.coolShade.opacity(0.14), width: 1.6)
    }
}
