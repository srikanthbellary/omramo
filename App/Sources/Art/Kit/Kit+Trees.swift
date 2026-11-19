import SwiftUI
import OmramoCore

// The kit's trees and bushes (round 5): leaf palettes, the leafy `canopy`, and one painter per
// kind of tree the ten regions need. Every tree stands at (x, baseY) — the middle of its foot —
// and rises `height` units; all its parts are sized from `height`, so any scale works.
// One light from the upper left: bark runs light to dark from left to right, crowns carry
// their sunlit leaves on the upper left of every clump.

// MARK: - Palettes and small tools

extension Kit {
    /// Five leaf tones, darkest first (deep, shade, mid, light, sunlit).
    typealias Greens = [Color]

    static func greens(_ deep: UInt32, _ shade: UInt32, _ mid: UInt32, _ light: UInt32, _ sunlit: UInt32) -> Greens {
        [Art.color(deep), Art.color(shade), Art.color(mid), Art.color(light), Art.color(sunlit)]
    }

    /// Rich broadleaf summer.
    static func summerGreens() -> Greens { greens(0x0F4A3C, 0x1B6B4A, 0x2E8F56, 0x6BBF59, 0xC4E86B) }
    /// Fresh yellow-greens.
    static func springGreens() -> Greens { greens(0x2B6B3F, 0x4A9A4A, 0x7CC257, 0xB4E06A, 0xE8F59A) }
    /// Gold, amber, russet.
    static func autumnLeaves() -> Greens { greens(0x7A2E1E, 0xB4481F, 0xDB7A22, 0xF2A92F, 0xFFD86B) }
    /// Blue-dark conifer greens.
    static func pineGreens() -> Greens { greens(0x0C3540, 0x14504F, 0x1F6B5C, 0x3D8F6E, 0x8FC79A) }
    /// Grey-silver greens.
    static func oliveGreens() -> Greens { greens(0x3C5247, 0x587060, 0x7C947A, 0xA8BB98, 0xD6E0C0) }
    static func bambooGreens() -> Greens { greens(0x1F5A3A, 0x3A8048, 0x62A84E, 0x9CCB5A, 0xD9EE8E) }

    /// Lighter (k > 1) or darker (k < 1) tone of a hex colour.
    static func treeTone(_ hex: UInt32, _ k: CGFloat) -> Color {
        let r: CGFloat = CGFloat((hex >> 16) & 0xFF) * k
        let g: CGFloat = CGFloat((hex >> 8) & 0xFF) * k
        let b: CGFloat = CGFloat(hex & 0xFF) * k
        let rr: UInt32 = UInt32(clamp(r, 0, 255))
        let gg: UInt32 = UInt32(clamp(g, 0, 255))
        let bb: UInt32 = UInt32(clamp(b, 0, 255))
        let mixed: UInt32 = (rr << 16) | (gg << 8) | bb
        return Art.color(mixed)
    }

    static func treePow(_ value: CGFloat, _ exponent: Double) -> CGFloat {
        CGFloat(pow(Double(value), exponent))
    }

    /// A point `u` along and `v` across a direction given by its cosine and sine, from (x, y).
    static func treeTurn(_ x: CGFloat, _ y: CGFloat, _ u: CGFloat, _ v: CGFloat, _ c: CGFloat, _ s: CGFloat) -> CGPoint {
        CGPoint(x: x + u * c - v * s, y: y + u * s + v * c)
    }

    /// Adds one pointed leaf that starts at (x, y) and points along angle `a`; it is
    /// 1.25 × r long. `slim` below 1 gives a blade (palm, bamboo, olive).
    static func treeLeaf(_ path: inout Path, _ x: CGFloat, _ y: CGFloat, _ r: CGFloat, _ a: CGFloat, slim: CGFloat = 1) {
        let c: CGFloat = cos(a)
        let s: CGFloat = sin(a)
        let wide: CGFloat = r * 0.42 * slim
        let narrow: CGFloat = r * 0.26 * slim
        let start = CGPoint(x: x, y: y)
        let tip = treeTurn(x, y, r * 1.25, 0, c, s)
        path.move(to: start)
        path.addCurve(to: tip, control1: treeTurn(x, y, r * 0.45, -wide, c, s), control2: treeTurn(x, y, r * 0.95, -narrow, c, s))
        path.addCurve(to: start, control1: treeTurn(x, y, r * 0.95, narrow, c, s), control2: treeTurn(x, y, r * 0.45, wide, c, s))
        path.closeSubpath()
    }

    /// Points along a quadratic curve from `p0` to `p1` (both included): `steps` + 1 points.
    static func treeCurve(_ p0: CGPoint, _ control: CGPoint, _ p1: CGPoint, steps: Int) -> [CGPoint] {
        var points: [CGPoint] = []
        let n: Int = max(1, steps)
        for i in 0...n {
            let t: CGFloat = CGFloat(i) / CGFloat(n)
            let u: CGFloat = 1 - t
            let k0: CGFloat = u * u
            let k1: CGFloat = 2 * u * t
            let k2: CGFloat = t * t
            let px: CGFloat = k0 * p0.x + k1 * control.x + k2 * p1.x
            let py: CGFloat = k0 * p0.y + k1 * control.y + k2 * p1.y
            points.append(CGPoint(x: px, y: py))
        }
        return points
    }

    /// A tapered ribbon along a centre line that climbs (`w0` wide at the first point, `w1` at
    /// the last), and its left (lit) edge as an open path.
    static func treeRibbon(_ points: [CGPoint], _ w0: CGFloat, _ w1: CGFloat) -> (shape: Path, edge: Path) {
        let n: Int = points.count
        guard n >= 2 else { return (Path(), Path()) }
        var left: [CGPoint] = []
        var right: [CGPoint] = []
        for i in 0..<n {
            let a = points[max(0, i - 1)]
            let b = points[min(n - 1, i + 1)]
            let dx: CGFloat = b.x - a.x
            let dy: CGFloat = b.y - a.y
            let length: CGFloat = max(0.001, (dx * dx + dy * dy).squareRoot())
            let t: CGFloat = CGFloat(i) / CGFloat(n - 1)
            let half: CGFloat = mix(w0, w1, t) / 2
            let nx: CGFloat = dy / length * half
            let ny: CGFloat = -dx / length * half
            left.append(CGPoint(x: points[i].x + nx, y: points[i].y + ny))
            right.append(CGPoint(x: points[i].x - nx, y: points[i].y - ny))
        }
        var outline: [CGPoint] = left
        outline.append(contentsOf: right.reversed())
        return (Art.polygon(outline), Art.polygon(left, closed: false))
    }

    /// A tapered trunk that flares at the foot: from (x, baseY), half-width `foot`, up to
    /// (topX, topY), half-width `top`; and its left (lit) edge as an open path.
    static func treeTrunk(_ x: CGFloat, _ baseY: CGFloat, _ topX: CGFloat, _ topY: CGFloat, _ foot: CGFloat, _ top: CGFloat) -> (shape: Path, edge: Path) {
        let rise: CGFloat = baseY - topY
        let midX: CGFloat = mix(x, topX, 0.5)
        let lowY: CGFloat = baseY - rise * 0.16
        let highY: CGFloat = baseY - rise * 0.6
        let leftFoot = CGPoint(x: x - foot, y: baseY)
        let leftTop = CGPoint(x: topX - top, y: topY)
        let leftLow = CGPoint(x: x - foot * 0.4, y: lowY)
        let leftHigh = CGPoint(x: midX - top * 1.08, y: highY)
        var shape = Path()
        shape.move(to: leftFoot)
        shape.addCurve(to: leftTop, control1: leftLow, control2: leftHigh)
        shape.addLine(to: CGPoint(x: topX + top, y: topY))
        shape.addCurve(
            to: CGPoint(x: x + foot, y: baseY),
            control1: CGPoint(x: midX + top * 1.08, y: highY),
            control2: CGPoint(x: x + foot * 0.4, y: lowY)
        )
        shape.addQuadCurve(to: leftFoot, control: CGPoint(x: x, y: baseY + foot * 0.3))
        shape.closeSubpath()
        var edge = Path()
        edge.move(to: leftFoot)
        edge.addCurve(to: leftTop, control1: leftLow, control2: leftHigh)
        return (shape, edge)
    }

    /// Fills a trunk with the bark gradient (light on the left, shade on the right) and lays
    /// the thin warm lit edge along `edge`.
    static func treeBark(_ context: inout GraphicsContext, _ shape: Path, _ edge: Path, _ bark: UInt32) {
        let bounds = shape.boundingRect
        guard bounds.width > 0, bounds.height > 0 else { return }
        let stops: Stops = [(treeTone(bark, 1.2), 0), (Art.color(bark), 0.45), (treeTone(bark, 0.7), 1)]
        let from = CGPoint(x: bounds.minX, y: bounds.midY)
        let to = CGPoint(x: bounds.maxX, y: bounds.midY)
        Art.fillLinear(&context, shape, stops, from: from, to: to)
        let lit: CGFloat = clamp(bounds.width * 0.1, 1.2, 5)
        Art.clipped(&context, to: shape) { g in
            Art.stroke(&g, edge, ArtStyle.warmLight.opacity(0.42), width: lit)
        }
    }

    /// Adds a tapered, slightly bent limb from (x0, y0), `w0` wide, to (x1, y1), `w1` wide.
    static func treeBough(_ path: inout Path, _ x0: CGFloat, _ y0: CGFloat, _ x1: CGFloat, _ y1: CGFloat, _ w0: CGFloat, _ w1: CGFloat, bend: CGFloat = 0) {
        let dx: CGFloat = x1 - x0
        let dy: CGFloat = y1 - y0
        let length: CGFloat = max(0.001, (dx * dx + dy * dy).squareRoot())
        let nx: CGFloat = -dy / length
        let ny: CGFloat = dx / length
        let cx: CGFloat = (x0 + x1) / 2 + nx * bend
        let cy: CGFloat = (y0 + y1) / 2 + ny * bend
        let h0: CGFloat = w0 / 2
        let h1: CGFloat = w1 / 2
        let hm: CGFloat = (h0 + h1) / 2
        path.move(to: CGPoint(x: x0 + nx * h0, y: y0 + ny * h0))
        path.addQuadCurve(to: CGPoint(x: x1 + nx * h1, y: y1 + ny * h1), control: CGPoint(x: cx + nx * hm, y: cy + ny * hm))
        path.addLine(to: CGPoint(x: x1 - nx * h1, y: y1 - ny * h1))
        path.addQuadCurve(to: CGPoint(x: x0 - nx * h0, y: y0 - ny * h0), control: CGPoint(x: cx - nx * hm, y: cy - ny * hm))
        path.closeSubpath()
    }
}

// MARK: - Canopy

extension Kit {
    /// How many leaves a blob of radius `r` carries at `density`.
    static func treeLeafCount(_ r: CGFloat, _ density: CGFloat) -> CGFloat {
        let big: CGFloat = max(1, r / 40)
        return 22 * density * (r / 40) * big
    }

    /// The dark base of one clump: a core and a ring of bumps, so the edge is never one circle.
    static func treeClump(_ path: inout Path, _ bx: CGFloat, _ by: CGFloat, _ br: CGFloat, _ random: inout ArtRandom) {
        let core: CGFloat = br * 0.8
        path.addEllipse(in: CGRect(x: bx - core, y: by - core * 0.94, width: core * 2, height: core * 1.88))
        for i in 0..<7 {
            let a: CGFloat = CGFloat(i) * 0.9 + rnd(&random) * 0.5
            let r: CGFloat = br * (0.24 + rnd(&random) * 0.1)
            let d: CGFloat = br * 0.68
            let x: CGFloat = bx + cos(a) * d
            let y: CGFloat = by + sin(a) * d * 0.94
            path.addEllipse(in: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2))
        }
    }

    /// A mass of leaves built from blobs: a dark base clump per blob, then small pointed
    /// leaves scattered over it — darker at the lower right, sunlit on the upper left — with a
    /// broken edge. `density` 1 is about 22 leaves a blob of radius 40; the total is capped at
    /// about 900 leaves. `palette` must have 5 colours.
    static func canopy(_ context: inout GraphicsContext, _ blobs: [Blob], seed: UInt32, palette: Greens, density: CGFloat = 1) {
        guard palette.count >= 5 else { return }
        var wanted: CGFloat = 0
        for blob in blobs where blob.2 > 0 {
            wanted += treeLeafCount(blob.2, density)
        }
        let thin: CGFloat = wanted > 900 ? 900 / wanted : 1
        var random = ArtRandom(seed)
        var deep = Path()
        var shade = Path()
        var mid = Path()
        var light = Path()
        var sunlit = Path()
        for blob in blobs {
            let bx: CGFloat = blob.0
            let by: CGFloat = blob.1
            let br: CGFloat = blob.2
            guard br > 0 else { continue }
            treeClump(&deep, bx, by, br, &random)
            let leaves: CGFloat = (treeLeafCount(br, density) * thin).rounded()
            let count: Int = max(0, Int(leaves))
            let size: CGFloat = clamp(br * 0.24, 3, 11)
            for _ in 0..<count {
                let a: CGFloat = rnd(&random) * 6.283
                let d: CGFloat = treePow(rnd(&random), 0.45) * br * 1.04
                let x: CGFloat = bx + cos(a) * d
                let y: CGFloat = by + sin(a) * d * 0.92
                let turn: CGFloat = x < bx ? 2.6 : 0.5
                let la: CGFloat = (rnd(&random) - 0.5) * 2.4 + turn
                let sz: CGFloat = size * (0.7 + rnd(&random) * 0.7)
                let lit: CGFloat = ((bx - x) + (by - y) * 1.3) / br
                let score: CGFloat = lit + rnd(&random) * 0.9
                if score > 1.3 {
                    treeLeaf(&sunlit, x, y, sz, la)
                } else if score > 0.85 {
                    treeLeaf(&light, x, y, sz, la)
                } else if score > 0.1 {
                    treeLeaf(&mid, x, y, sz, la)
                } else {
                    treeLeaf(&shade, x, y, sz * 1.1, la)
                }
            }
        }
        Art.fill(&context, deep, palette[0])
        Art.fill(&context, shade, palette[1])
        Art.fill(&context, mid, palette[2])
        Art.fill(&context, light, palette[3])
        Art.fill(&context, sunlit, palette[4])
    }

    /// The clumps of a rounded crown centred on (cx, cy) with radii rx, ry: one in the middle
    /// and `count` − 1 around it.
    static func treeCrown(_ cx: CGFloat, _ cy: CGFloat, _ rx: CGFloat, _ ry: CGFloat, count: Int, seed: UInt32) -> [Blob] {
        var random = ArtRandom(seed)
        var blobs: [Blob] = []
        let base: CGFloat = min(rx, ry)
        let centre: Blob = (cx, cy, base * 0.8)
        blobs.append(centre)
        let ring: Int = max(1, count - 1)
        for i in 0..<ring {
            let a: CGFloat = CGFloat(i) / CGFloat(ring) * 6.283 + rnd(&random) * 0.5
            let r: CGFloat = base * (0.5 + rnd(&random) * 0.16)
            let far: CGFloat = 0.86 + rnd(&random) * 0.14
            let px: CGFloat = cx + cos(a) * max(0, rx - r * 0.9) * far
            let py: CGFloat = cy + sin(a) * max(0, ry - r * 0.9) * far
            let blob: Blob = (px, py, r)
            blobs.append(blob)
        }
        return blobs
    }
}

// MARK: - Broadleaf trees and bushes

extension Kit {
    /// A broadleaf tree standing at (x, baseY): a tapered trunk that flares at the foot, two
    /// or three boughs, and a crown of five to seven clumps (seeded) about `spread` wide whose
    /// top is `height` above baseY.
    static func tree(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, height: CGFloat, spread: CGFloat, palette: Greens, bark: UInt32 = 0x6B4138, seed: UInt32 = 1) {
        let h: CGFloat = max(1, height)
        var random = ArtRandom(seed)
        let ry: CGFloat = h * 0.34
        let rx: CGFloat = max(spread / 2, h * 0.1)
        let cy: CGFloat = baseY - h + ry
        let foot: CGFloat = max(2.5, h * 0.055)
        let forkY: CGFloat = cy + ry * 0.5
        let topX: CGFloat = x + (rnd(&random) - 0.5) * h * 0.05
        shadow(&context, x, baseY, width: rx * 1.3, alpha: 0.2)
        let trunk = treeTrunk(x, baseY, topX, forkY, foot, foot * 0.5)
        var boughs = Path()
        let boughCount: Int = 2 + Int(rnd(&random) * 2)
        for i in 0..<boughCount {
            let side: CGFloat = i == 0 ? -1 : (i == 1 ? 1 : 0.2)
            let ex: CGFloat = topX + side * rx * (0.42 + rnd(&random) * 0.2)
            let ey: CGFloat = cy - ry * rnd(&random) * 0.3
            treeBough(&boughs, topX, forkY + foot * 1.5, ex, ey, foot * 0.8, foot * 0.25, bend: side * foot)
        }
        Art.fill(&context, boughs, treeTone(bark, 0.82))
        treeBark(&context, trunk.shape, trunk.edge, bark)
        let clumps: Int = 5 + Int(rnd(&random) * 3)
        let blobs: [Blob] = treeCrown(topX, cy, rx, ry, count: clumps, seed: seed &+ 11)
        canopy(&context, blobs, seed: seed &+ 23, palette: palette)
    }

    /// A low bush of three or four clumps, `width` wide, sitting on baseY at x (its middle).
    static func bush(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, width: CGFloat, palette: Greens, seed: UInt32 = 1) {
        let w: CGFloat = max(1, width)
        var random = ArtRandom(seed)
        let count: Int = 3 + Int(rnd(&random) * 2)
        var blobs: [Blob] = []
        for i in 0..<count {
            let t: CGFloat = (CGFloat(i) + 0.5) / CGFloat(count)
            let middle: CGFloat = 1 - abs(t - 0.5) * 0.9
            let r: CGFloat = w * (0.2 + rnd(&random) * 0.05) * middle
            let bx: CGFloat = x - w / 2 + w * (0.14 + t * 0.72)
            let blob: Blob = (bx, baseY - r * 0.82, r)
            blobs.append(blob)
        }
        shadow(&context, x, baseY, width: w * 1.1, alpha: 0.2)
        canopy(&context, blobs, seed: seed &+ 5, palette: palette, density: 1.2)
    }
}

// MARK: - Conifer and birch (the northern woods)

extension Kit {
    /// One tier of drooping conifer boughs: apex at (x, top), tips at (x ± half, bottom), a
    /// scalloped hanging lower edge.
    static func treeTier(_ x: CGFloat, _ top: CGFloat, _ bottom: CGFloat, _ half: CGFloat) -> Path {
        let drop: CGFloat = bottom - top
        let step: CGFloat = half / 2
        var path = Path()
        path.move(to: CGPoint(x: x, y: top))
        path.addQuadCurve(to: CGPoint(x: x - half, y: bottom), control: CGPoint(x: x - half * 0.3, y: top + drop * 0.62))
        for k in 1...4 {
            let ex: CGFloat = x - half + step * CGFloat(k)
            let lift: CGFloat = (k == 2) ? 0.1 : 0.05
            let ey: CGFloat = (k == 4) ? bottom : bottom - drop * lift
            path.addQuadCurve(to: CGPoint(x: ex, y: ey), control: CGPoint(x: ex - step / 2, y: bottom + drop * 0.12))
        }
        path.addQuadCurve(to: CGPoint(x: x, y: top), control: CGPoint(x: x + half * 0.3, y: top + drop * 0.62))
        path.closeSubpath()
        return path
    }

    /// The snow lying on the upper-left of a conifer tier (same arguments as `treeTier`).
    static func treeSnowCap(_ x: CGFloat, _ top: CGFloat, _ bottom: CGFloat, _ half: CGFloat) -> Path {
        let drop: CGFloat = bottom - top
        var path = Path()
        path.move(to: CGPoint(x: x, y: top))
        path.addQuadCurve(to: CGPoint(x: x - half * 0.8, y: top + drop * 0.84), control: CGPoint(x: x - half * 0.28, y: top + drop * 0.56))
        path.addQuadCurve(to: CGPoint(x: x - half * 0.42, y: top + drop * 0.64), control: CGPoint(x: x - half * 0.6, y: top + drop * 0.98))
        path.addQuadCurve(to: CGPoint(x: x - half * 0.06, y: top + drop * 0.5), control: CGPoint(x: x - half * 0.22, y: top + drop * 0.86))
        path.addQuadCurve(to: CGPoint(x: x + half * 0.24, y: top + drop * 0.42), control: CGPoint(x: x + half * 0.1, y: top + drop * 0.7))
        path.addQuadCurve(to: CGPoint(x: x, y: top), control: CGPoint(x: x + half * 0.2, y: top + drop * 0.2))
        path.closeSubpath()
        return path
    }

    /// A conifer (spruce/fir): a narrow trunk and five to seven tiers of drooping boughs
    /// narrowing to the top; `snow` lays a pale cap on the upper-left of each tier.
    static func conifer(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, height: CGFloat, palette: Greens, snow: Bool = false, seed: UInt32 = 1) {
        guard palette.count >= 5 else { return }
        let h: CGFloat = max(1, height)
        var random = ArtRandom(seed)
        let tiers: Int = 5 + Int(rnd(&random) * 3)
        let foot: CGFloat = max(1.5, h * 0.028)
        let skirt: CGFloat = baseY - h * 0.12
        let tierH: CGFloat = h * 0.88 / (CGFloat(tiers) + 0.5)
        shadow(&context, x, baseY, width: h * 0.42, alpha: 0.2)
        let trunk = treeTrunk(x, baseY, x, baseY - h * 0.3, foot, foot * 0.6)
        treeBark(&context, trunk.shape, trunk.edge, 0x5A3A30)
        let stops: Stops = [(palette[3], 0), (palette[2], 0.3), (palette[1], 0.62), (palette[0], 1)]
        let snowColor = Art.color(0xF6F9FF)
        let under = CGAffineTransform(translationX: 0, y: tierH * 0.16)
        for i in 0..<tiers {
            let t: CGFloat = CGFloat(i) / CGFloat(tiers - 1)
            let bottom: CGFloat = skirt - tierH * CGFloat(i)
            let top: CGFloat = bottom - tierH * 1.5
            let wobble: CGFloat = 0.94 + rnd(&random) * 0.12
            let half: CGFloat = h * 0.24 * (1 - 0.78 * t) * wobble
            let tier: Path = treeTier(x, top, bottom, half)
            Art.fill(&context, tier.applying(under), palette[0])
            Art.fillLinear(&context, tier, stops, from: CGPoint(x: x - half, y: bottom), to: CGPoint(x: x + half, y: bottom))
            if snow {
                Art.fill(&context, treeSnowCap(x, top, bottom, half), snowColor)
            }
        }
    }

    /// A birch: a slim white trunk with dark horizontal marks, fine branches and a light airy
    /// crown of small clumps.
    static func birch(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, height: CGFloat, palette: Greens, seed: UInt32 = 1) {
        let h: CGFloat = max(1, height)
        var random = ArtRandom(seed)
        let foot: CGFloat = max(1.6, h * 0.022)
        let topX: CGFloat = x + (rnd(&random) - 0.5) * h * 0.08
        let rise: CGFloat = h * 0.9
        shadow(&context, x, baseY, width: h * 0.3, alpha: 0.18)
        let trunk = treeTrunk(x, baseY, topX, baseY - rise, foot, foot * 0.3)
        var twigs = Path()
        var marks = Path()
        var blobs: [Blob] = []
        for i in 0..<7 {
            let t: CGFloat = 0.42 + CGFloat(i) * 0.08
            let side: CGFloat = (i % 2 == 0) ? -1 : 1
            let sx: CGFloat = mix(x, topX, t)
            let sy: CGFloat = baseY - rise * t
            let out: CGFloat = h * (0.09 + rnd(&random) * 0.1) * (1.25 - t)
            let ex: CGFloat = sx + side * out
            let ey: CGFloat = sy - h * (0.07 + rnd(&random) * 0.07)
            twigs.move(to: CGPoint(x: sx, y: sy))
            twigs.addQuadCurve(to: CGPoint(x: ex, y: ey), control: CGPoint(x: mix(sx, ex, 0.6), y: sy - h * 0.01))
            let blob: Blob = (ex, ey, h * (0.065 + rnd(&random) * 0.03))
            blobs.append(blob)
        }
        let crownTop: Blob = (topX, baseY - h * 0.92, h * 0.075)
        blobs.append(crownTop)
        for _ in 0..<11 {
            let t: CGFloat = 0.04 + rnd(&random) * 0.8
            let half: CGFloat = mix(foot, foot * 0.3, t)
            let mx: CGFloat = mix(x, topX, t) + (rnd(&random) - 0.5) * half * 1.6
            let my: CGFloat = baseY - rise * t
            marks.move(to: CGPoint(x: mx - half * 0.6, y: my))
            marks.addLine(to: CGPoint(x: mx + half * 0.6, y: my + half * 0.15))
        }
        Art.stroke(&context, twigs, Art.color(0x6A5A5E), width: max(0.8, foot * 0.36))
        let stops: Stops = [(Art.color(0xFFFFFF), 0), (Art.color(0xF3EFE6), 0.5), (Art.color(0xC2C0D2), 1)]
        Art.fillLinear(&context, trunk.shape, stops, from: CGPoint(x: x - foot, y: baseY), to: CGPoint(x: x + foot, y: baseY))
        Art.clipped(&context, to: trunk.shape) { g in
            Art.stroke(&g, marks, Art.color(0x4A4350, 0.85), width: max(0.8, foot * 0.3), cap: .butt)
        }
        canopy(&context, blobs, seed: seed &+ 7, palette: palette, density: 0.9)
    }
}

// MARK: - Palm, bamboo, cloud pine (the warm south and the far east)

extension Kit {
    /// Adds the leaflets of one palm frond along its spine (points from the crown outward).
    static func treeFrond(_ path: inout Path, _ spine: [CGPoint], leaflet: CGFloat) {
        let n: Int = spine.count
        guard n >= 2 else { return }
        for j in 1..<n {
            let p = spine[j]
            let q = spine[j - 1]
            let along: CGFloat = atan2(p.y - q.y, p.x - q.x)
            let t: CGFloat = CGFloat(j) / CGFloat(n - 1)
            let r: CGFloat = leaflet * (1 - 0.5 * t)
            treeLeaf(&path, p.x, p.y, r, along + 1.0, slim: 0.5)
            treeLeaf(&path, p.x, p.y, r, along - 1.0, slim: 0.5)
            if j == n - 1 {
                treeLeaf(&path, p.x, p.y, r, along, slim: 0.5)
            }
        }
    }

    /// A palm (date / coconut): a curved ringed trunk leaning by `lean` units at the top, and
    /// seven to nine arching fronds with leaflets.
    static func palm(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, height: CGFloat, lean: CGFloat = 0, fronds: UInt32 = 0x2E8A5A, trunk: UInt32 = 0x7A5A40, seed: UInt32 = 1) {
        let h: CGFloat = max(1, height)
        var random = ArtRandom(seed)
        let top = CGPoint(x: x + lean, y: baseY - h * 0.8)
        let bend = CGPoint(x: x + lean * 0.15, y: baseY - h * 0.45)
        let line: [CGPoint] = treeCurve(CGPoint(x: x, y: baseY), bend, top, steps: 12)
        let w0: CGFloat = max(3, h * 0.06)
        shadow(&context, x, baseY, width: h * 0.3, alpha: 0.2)
        let stem = treeRibbon(line, w0, w0 * 0.6)
        treeBark(&context, stem.shape, stem.edge, trunk)
        var rings = Path()
        for i in 1..<12 {
            let p = line[i]
            let half: CGFloat = mix(w0, w0 * 0.6, CGFloat(i) / 12) / 2
            rings.move(to: CGPoint(x: p.x - half, y: p.y))
            rings.addQuadCurve(to: CGPoint(x: p.x + half, y: p.y), control: CGPoint(x: p.x, y: p.y + half * 0.7))
        }
        Art.clipped(&context, to: stem.shape) { g in
            Art.stroke(&g, rings, treeTone(trunk, 0.6).opacity(0.8), width: max(0.8, w0 * 0.12))
        }
        let count: Int = 7 + Int(rnd(&random) * 3)
        var tones: [Path] = [Path(), Path(), Path()]
        var ribs = Path()
        for i in 0..<count {
            let t: CGFloat = CGFloat(i) / CGFloat(count - 1)
            let a: CGFloat = mix(-3.5, 0.36, t) + (rnd(&random) - 0.5) * 0.2
            let reach: CGFloat = h * 0.36 * (0.85 + rnd(&random) * 0.3)
            let ca: CGFloat = cos(a) * reach
            let sa: CGFloat = sin(a) * reach
            let archX: CGFloat = top.x + ca * 0.55
            let archY: CGFloat = top.y + sa * 0.55 - reach * 0.3
            let tipX: CGFloat = top.x + ca
            let tipY: CGFloat = top.y + sa * 0.6 + reach * 0.22
            let arch = CGPoint(x: archX, y: archY)
            let tip = CGPoint(x: tipX, y: tipY)
            let spine: [CGPoint] = treeCurve(top, arch, tip, steps: 8)
            ribs.addLines(spine)
            let tone: Int = (t < 0.55 && i % 2 == 1) ? 2 : (i % 2)
            treeFrond(&tones[tone], spine, leaflet: reach * 0.2)
        }
        Art.fill(&context, tones[0], treeTone(fronds, 0.68))
        Art.stroke(&context, ribs, treeTone(fronds, 0.55), width: max(0.8, h * 0.008))
        var nuts = Path()
        let nut: CGFloat = w0 * 0.42
        nuts.addEllipse(in: CGRect(x: top.x - nut * 1.7, y: top.y - nut * 0.2, width: nut * 2, height: nut * 2))
        nuts.addEllipse(in: CGRect(x: top.x - nut * 0.2, y: top.y + nut * 0.1, width: nut * 2, height: nut * 2))
        nuts.addEllipse(in: CGRect(x: top.x - nut, y: top.y - nut * 1.2, width: nut * 2, height: nut * 2))
        Art.fill(&context, nuts, treeTone(trunk, 0.62))
        Art.fill(&context, tones[1], Art.color(fronds))
        Art.fill(&context, tones[2], treeTone(fronds, 1.35))
    }

    /// Adds one jointed bamboo cane to `stem`, its joint rings to `joints` and its lit line
    /// to `shine`. The cane stands at (sx, baseY), `sh` tall, and leans by `lean` at the top.
    static func treeCane(_ stem: inout Path, _ joints: inout Path, _ shine: inout Path, _ sx: CGFloat, _ baseY: CGFloat, _ sh: CGFloat, _ half: CGFloat, _ lean: CGFloat) {
        let segments: Int = 9
        for k in 0..<segments {
            let t0: CGFloat = CGFloat(k) / CGFloat(segments)
            let t1: CGFloat = CGFloat(k + 1) / CGFloat(segments)
            let x0: CGFloat = sx + lean * t0 * t0
            let x1: CGFloat = sx + lean * t1 * t1
            let y0: CGFloat = baseY - sh * t0
            let y1: CGFloat = baseY - sh * t1
            let h0: CGFloat = half * (1 - 0.45 * t0)
            let h1: CGFloat = half * (1 - 0.45 * t1)
            stem.move(to: CGPoint(x: x0 - h0, y: y0))
            stem.addLine(to: CGPoint(x: x1 - h1 * 0.92, y: y1))
            stem.addLine(to: CGPoint(x: x1 + h1 * 0.92, y: y1))
            stem.addLine(to: CGPoint(x: x0 + h0, y: y0))
            stem.closeSubpath()
            joints.move(to: CGPoint(x: x1 - h1 * 1.25, y: y1))
            joints.addLine(to: CGPoint(x: x1 + h1 * 1.25, y: y1))
            shine.move(to: CGPoint(x: x0 - h0 * 0.45, y: y0 - sh * 0.012))
            shine.addLine(to: CGPoint(x: x1 - h1 * 0.45, y: y1 + sh * 0.012))
        }
    }

    /// A stand of bamboo between x and x + width: `count` jointed stems of slightly different
    /// heights and tones, with sprays of narrow leaves near the tops.
    static func bamboo(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, width: CGFloat, height: CGFloat, count: Int, palette: Greens, seed: UInt32 = 1) {
        guard palette.count >= 5, count > 0 else { return }
        let h: CGFloat = max(1, height)
        var random = ArtRandom(seed)
        var stems: [Path] = [Path(), Path(), Path()]
        var leaves: [Path] = [Path(), Path(), Path()]
        var joints = Path()
        var shine = Path()
        let gap: CGFloat = width / CGFloat(count)
        for i in 0..<count {
            let sx: CGFloat = x + gap * (CGFloat(i) + 0.5) + (rnd(&random) - 0.5) * gap * 0.6
            let sh: CGFloat = h * (0.72 + rnd(&random) * 0.28)
            let half: CGFloat = max(1, h * 0.011) * (0.75 + rnd(&random) * 0.5)
            let lean: CGFloat = (rnd(&random) - 0.5) * h * 0.09
            treeCane(&stems[i % 3], &joints, &shine, sx, baseY, sh, half, lean)
            for spray in 0..<3 {
                let t: CGFloat = 0.6 + CGFloat(spray) * 0.18
                let side: CGFloat = ((i + spray) % 2 == 0) ? -1 : 1
                let ox: CGFloat = sx + lean * t * t
                let oy: CGFloat = baseY - sh * t
                let aim: CGFloat = side < 0 ? 2.5 : 0.64
                for blade in 0..<4 {
                    let fan: CGFloat = (CGFloat(blade) - 1.5) * 0.36
                    let a: CGFloat = aim + fan + (rnd(&random) - 0.5) * 0.2
                    let r: CGFloat = h * (0.045 + rnd(&random) * 0.025)
                    let tone: Int = side < 0 ? (blade % 2 + 1) : (blade % 2)
                    treeLeaf(&leaves[tone], ox, oy, r, a, slim: 0.45)
                }
            }
        }
        shadow(&context, x + width / 2, baseY, width: width, alpha: 0.18)
        for tone in 0..<3 {
            Art.fill(&context, stems[tone], palette[tone + 1])
        }
        Art.stroke(&context, joints, palette[0], width: max(0.8, h * 0.004), cap: .butt)
        Art.stroke(&context, shine, palette[4].opacity(0.5), width: max(0.6, h * 0.003))
        for tone in 0..<3 {
            Art.fill(&context, leaves[tone], palette[tone + 2])
        }
    }

    /// Adds one flat cloud-like pad of pine needles, `w` wide, whose flat base lies on `cy`:
    /// `tones` are five paths, darkest first.
    static func treePad(_ tones: inout [Path], _ cx: CGFloat, _ cy: CGFloat, _ w: CGFloat, _ random: inout ArtRandom) {
        guard tones.count >= 5 else { return }
        tones[0].addPath(Art.rect(cx - w * 0.46, cy - w * 0.03, w * 0.96, w * 0.11, radius: w * 0.05))
        tones[1].addPath(Art.rect(cx - w * 0.5, cy - w * 0.07, w, w * 0.11, radius: w * 0.055))
        for k in 0..<4 {
            let u: CGFloat = (CGFloat(k) + 0.5) / 4
            let edge: CGFloat = 1 - abs(u - 0.5) * 0.7
            let bx: CGFloat = cx - w / 2 + w * u
            let rx: CGFloat = w * 0.18
            let ry: CGFloat = w * (0.11 + rnd(&random) * 0.05) * edge
            let by: CGFloat = cy - w * 0.03 - ry * 0.5
            tones[1].addEllipse(in: CGRect(x: bx - rx, y: by - ry, width: rx * 2, height: ry * 2))
            let mx: CGFloat = bx - w * 0.025
            let my: CGFloat = by - ry * 0.22
            tones[2].addEllipse(in: CGRect(x: mx - rx * 0.8, y: my - ry * 0.78, width: rx * 1.6, height: ry * 1.56))
            let lx: CGFloat = bx - w * 0.05
            let ly: CGFloat = by - ry * 0.45
            tones[3].addEllipse(in: CGRect(x: lx - rx * 0.5, y: ly - ry * 0.46, width: rx, height: ry * 0.92))
            if k < 2 {
                tones[4].addEllipse(in: CGRect(x: lx - rx * 0.4, y: ly - ry * 0.4, width: rx * 0.5, height: ry * 0.4))
            }
        }
    }

    /// A Japanese-style pine: a leaning, twisting dark-red trunk with three to five flat
    /// cloud-like pads of needles.
    static func cloudPine(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, height: CGFloat, palette: Greens, seed: UInt32 = 1) {
        guard palette.count >= 5 else { return }
        let h: CGFloat = max(1, height)
        var random = ArtRandom(seed)
        let dir: CGFloat = rnd(&random) < 0.5 ? -1 : 1
        let lean: CGFloat = dir * h * (0.16 + rnd(&random) * 0.1)
        let phase: CGFloat = rnd(&random) * 3
        var line: [CGPoint] = []
        for i in 0...10 {
            let t: CGFloat = CGFloat(i) / 10
            let twist: CGFloat = sin(t * 5.4 + phase) * h * 0.05 * t
            line.append(CGPoint(x: x + lean * t + twist, y: baseY - h * 0.8 * t))
        }
        let w0: CGFloat = max(3, h * 0.075)
        let bark: UInt32 = 0x6E3530
        shadow(&context, x, baseY, width: h * 0.45, alpha: 0.2)
        let pads: Int = 3 + Int(rnd(&random) * 3)
        var tones: [Path] = [Path(), Path(), Path(), Path(), Path()]
        var boughs = Path()
        for i in 0..<pads {
            let isTop: Bool = i == pads - 1
            let climb: CGFloat = 0.45 + 0.45 * CGFloat(i) / CGFloat(pads - 1)
            let t: CGFloat = isTop ? 1 : climb
            let anchor = line[min(10, Int(t * 10))]
            let turn: CGFloat = (i % 2 == 0) ? -dir : dir
            let side: CGFloat = isTop ? dir * 0.2 : turn
            let px: CGFloat = anchor.x + side * h * (0.17 + rnd(&random) * 0.09)
            let py: CGFloat = anchor.y - h * (0.05 + rnd(&random) * 0.05)
            let w: CGFloat = h * (0.3 + rnd(&random) * 0.1) * (1.1 - 0.3 * t)
            treeBough(&boughs, anchor.x, anchor.y, px, py, w0 * (0.6 - 0.25 * t), w0 * 0.14, bend: -side * h * 0.02)
            treePad(&tones, px, py, w, &random)
        }
        Art.fill(&context, boughs, treeTone(bark, 0.8))
        let stem = treeRibbon(line, w0, w0 * 0.3)
        treeBark(&context, stem.shape, stem.edge, bark)
        for tone in 0..<5 {
            Art.fill(&context, tones[tone], palette[tone])
        }
    }
}

// MARK: - Acacia, cypress, olive, great tree (savanna, garden, grove, village green)

extension Kit {
    /// A row of clumps from x − half to x + half along y, close enough to read as one layer.
    static func treeRow(_ x: CGFloat, _ y: CGFloat, half: CGFloat, r: CGFloat, arch: CGFloat) -> [Blob] {
        let fit: CGFloat = (half * 2 / max(1, r * 1.15)).rounded()
        let count: Int = max(3, min(11, Int(fit)))
        var blobs: [Blob] = []
        for i in 0..<count {
            let u: CGFloat = CGFloat(i) / CGFloat(count - 1) * 2 - 1
            let size: CGFloat = r * (1 - 0.22 * abs(u))
            let bx: CGFloat = x + max(0, half - size * 0.9) * u
            let blob: Blob = (bx, y - arch * (1 - u * u), size)
            blobs.append(blob)
        }
        return blobs
    }

    /// A flat-topped acacia / umbrella tree: forked trunk, a wide shallow layered crown.
    static func acacia(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, height: CGFloat, spread: CGFloat, palette: Greens, bark: UInt32 = 0x4A3A30) {
        let h: CGFloat = max(1, height)
        let half: CGFloat = max(spread / 2, h * 0.2)
        let foot: CGFloat = max(2.5, h * 0.045)
        let forkY: CGFloat = baseY - h * 0.42
        let crownY: CGFloat = baseY - h * 0.85
        shadow(&context, x, baseY, width: half * 1.5, alpha: 0.2)
        var boughs = Path()
        let ends: [(CGFloat, CGFloat)] = [(-0.74, 0.02), (-0.3, -0.02), (0.22, -0.01), (0.72, 0.03)]
        for end in ends {
            let ex: CGFloat = x + half * end.0
            let ey: CGFloat = crownY + h * (0.03 + end.1)
            treeBough(&boughs, x, forkY + foot, ex, ey, foot * 0.9, foot * 0.25, bend: end.0 * h * 0.06)
        }
        Art.fill(&context, boughs, treeTone(bark, 0.85))
        let trunk = treeTrunk(x, baseY, x, forkY, foot, foot * 0.55)
        treeBark(&context, trunk.shape, trunk.edge, bark)
        var blobs: [Blob] = treeRow(x, crownY, half: half, r: h * 0.1, arch: h * 0.03)
        blobs.append(contentsOf: treeRow(x - half * 0.05, crownY - h * 0.07, half: half * 0.62, r: h * 0.075, arch: h * 0.015))
        canopy(&context, blobs, seed: 17, palette: palette, density: 1.1)
    }

    /// A tall narrow cypress (Mediterranean / Persian garden).
    static func cypress(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, height: CGFloat, color: UInt32 = 0x1F4E3A) {
        let h: CGFloat = max(1, height)
        let half: CGFloat = h * 0.1
        let foot: CGFloat = max(1.5, h * 0.02)
        let top: CGFloat = baseY - h
        let hem: CGFloat = baseY - h * 0.07
        shadow(&context, x, baseY, width: h * 0.24, alpha: 0.2)
        let trunk = treeTrunk(x, baseY, x, baseY - h * 0.2, foot, foot * 0.7)
        treeBark(&context, trunk.shape, trunk.edge, 0x5A4034)
        var shape = Path()
        shape.move(to: CGPoint(x: x, y: top))
        shape.addCurve(to: CGPoint(x: x - half * 0.55, y: hem), control1: CGPoint(x: x - half * 0.5, y: top + h * 0.25), control2: CGPoint(x: x - half * 1.45, y: hem - h * 0.3))
        shape.addQuadCurve(to: CGPoint(x: x + half * 0.55, y: hem), control: CGPoint(x: x, y: hem + h * 0.035))
        shape.addCurve(to: CGPoint(x: x, y: top), control1: CGPoint(x: x + half * 1.45, y: hem - h * 0.3), control2: CGPoint(x: x + half * 0.5, y: top + h * 0.25))
        shape.closeSubpath()
        let stops: Stops = [(treeTone(color, 1.4), 0), (Art.color(color), 0.4), (treeTone(color, 0.6), 1)]
        Art.fillLinear(&context, shape, stops, from: CGPoint(x: x - half, y: baseY), to: CGPoint(x: x + half, y: baseY))
        var dark = Path()
        var pale = Path()
        let offsets: [CGFloat] = [-0.3, 0.3, -0.1, 0.55, -0.45, 0.1, 0.45, -0.25]
        for k in 0..<offsets.count {
            let t: CGFloat = (CGFloat(k) + 0.5) / CGFloat(offsets.count)
            let y: CGFloat = mix(top + h * 0.2, hem - h * 0.02, t)
            let sx: CGFloat = x + half * offsets[k]
            let to = CGPoint(x: sx + half * 0.14, y: y - h * 0.1)
            let control = CGPoint(x: sx - half * 0.28, y: y - h * 0.045)
            if offsets[k] < 0 {
                pale.move(to: CGPoint(x: sx, y: y))
                pale.addQuadCurve(to: to, control: control)
            } else {
                dark.move(to: CGPoint(x: sx, y: y))
                dark.addQuadCurve(to: to, control: control)
            }
        }
        let line: CGFloat = max(1, h * 0.012)
        Art.clipped(&context, to: shape) { g in
            Art.stroke(&g, dark, treeTone(color, 0.5).opacity(0.7), width: line)
            Art.stroke(&g, pale, treeTone(color, 1.8).opacity(0.55), width: line)
        }
    }

    /// An old olive tree: a short, thick, twisted grey trunk and a rounded silver-green crown.
    static func olive(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, height: CGFloat, seed: UInt32 = 1) {
        let h: CGFloat = max(1, height)
        var random = ArtRandom(seed)
        let bark: UInt32 = 0x8A8478
        let w0: CGFloat = max(4, h * 0.2)
        let topX: CGFloat = x + (rnd(&random) - 0.5) * h * 0.16
        let phase: CGFloat = rnd(&random) * 3
        var line: [CGPoint] = []
        var groove = Path()
        for i in 0...8 {
            let t: CGFloat = CGFloat(i) / 8
            let twist: CGFloat = sin(t * 4.2 + phase) * h * 0.05 * t
            let p = CGPoint(x: mix(x, topX, t) + twist, y: baseY - h * 0.5 * t)
            line.append(p)
            let inner: CGFloat = sin(t * 5 + phase) * w0 * 0.2
            if i == 0 {
                groove.move(to: CGPoint(x: p.x + inner, y: p.y))
            } else {
                groove.addLine(to: CGPoint(x: p.x + inner, y: p.y))
            }
        }
        shadow(&context, x, baseY, width: h * 0.8, alpha: 0.2)
        var roots = Path()
        roots.move(to: CGPoint(x: x - w0 * 0.9, y: baseY))
        roots.addQuadCurve(to: CGPoint(x: x + w0 * 0.9, y: baseY), control: CGPoint(x: x, y: baseY - w0 * 0.9))
        roots.addQuadCurve(to: CGPoint(x: x - w0 * 0.9, y: baseY), control: CGPoint(x: x, y: baseY + w0 * 0.16))
        roots.closeSubpath()
        Art.fill(&context, roots, treeTone(bark, 0.86))
        var boughs = Path()
        let fork = line[8]
        treeBough(&boughs, fork.x, fork.y + w0 * 0.3, fork.x - h * 0.24, baseY - h * 0.68, w0 * 0.5, w0 * 0.14, bend: -h * 0.03)
        treeBough(&boughs, fork.x, fork.y + w0 * 0.3, fork.x + h * 0.22, baseY - h * 0.7, w0 * 0.46, w0 * 0.14, bend: h * 0.03)
        Art.fill(&context, boughs, treeTone(bark, 0.8))
        let stem = treeRibbon(line, w0, w0 * 0.55)
        treeBark(&context, stem.shape, stem.edge, bark)
        Art.clipped(&context, to: stem.shape) { g in
            Art.stroke(&g, groove, treeTone(bark, 0.58).opacity(0.6), width: max(1, w0 * 0.09))
        }
        let blobs: [Blob] = treeCrown(topX, baseY - h * 0.7, h * 0.48, h * 0.3, count: 6, seed: seed &+ 3)
        canopy(&context, blobs, seed: seed &+ 9, palette: oliveGreens(), density: 1.1)
    }

    /// A plane tree / oak with a very wide crown and a thick pale mottled trunk — a tree to
    /// meet under.
    static func greatTree(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, height: CGFloat, spread: CGFloat, palette: Greens, bark: UInt32 = 0x8A7A66, seed: UInt32 = 1) {
        let h: CGFloat = max(1, height)
        var random = ArtRandom(seed)
        let rx: CGFloat = max(spread / 2, h * 0.3)
        let ry: CGFloat = h * 0.3
        let cy: CGFloat = baseY - h + ry
        let foot: CGFloat = max(4, h * 0.1)
        let forkY: CGFloat = cy + ry * 0.6
        shadow(&context, x, baseY, width: rx * 1.5, alpha: 0.22)
        var boughs = Path()
        let ends: [CGFloat] = [-0.62, 0.06, 0.64]
        for end in ends {
            let ex: CGFloat = x + rx * end
            treeBough(&boughs, x, forkY + foot, ex, cy + ry * 0.1, foot * 0.9, foot * 0.3, bend: end * foot)
        }
        Art.fill(&context, boughs, treeTone(bark, 0.82))
        let trunk = treeTrunk(x, baseY, x, forkY, foot, foot * 0.55)
        treeBark(&context, trunk.shape, trunk.edge, bark)
        var pale = Path()
        var dark = Path()
        for i in 0..<12 {
            let px: CGFloat = x + (rnd(&random) - 0.5) * foot * 1.5
            let py: CGFloat = mix(baseY, forkY, rnd(&random))
            let pw: CGFloat = foot * (0.16 + rnd(&random) * 0.2)
            let patch = CGRect(x: px - pw, y: py - pw * 1.6, width: pw * 2, height: pw * 3.2)
            if i % 2 == 0 {
                pale.addEllipse(in: patch)
            } else {
                dark.addEllipse(in: patch)
            }
        }
        Art.clipped(&context, to: trunk.shape) { g in
            Art.fill(&g, pale, treeTone(bark, 1.38).opacity(0.55))
            Art.fill(&g, dark, treeTone(bark, 0.72).opacity(0.45))
        }
        var blobs: [Blob] = treeRow(x, cy + ry * 0.3, half: rx, r: ry * 0.62, arch: ry * 0.2)
        let lift: CGFloat = (rnd(&random) - 0.5) * rx * 0.1
        blobs.append(contentsOf: treeRow(x + lift, cy - ry * 0.3, half: rx * 0.72, r: ry * 0.6, arch: ry * 0.1))
        canopy(&context, blobs, seed: seed &+ 13, palette: palette)
    }
}

// MARK: - Mangrove, bare tree, far trees

extension Kit {
    /// A mangrove standing on arching stilt roots over water at waterY.
    static func mangrove(_ context: inout GraphicsContext, x: CGFloat, waterY: CGFloat, height: CGFloat, palette: Greens, seed: UInt32 = 1) {
        let h: CGFloat = max(1, height)
        var random = ArtRandom(seed)
        let bark: UInt32 = 0x6A5548
        let hubY: CGFloat = waterY - h * 0.3
        let foot: CGFloat = max(2.5, h * 0.05)
        let topX: CGFloat = x + (rnd(&random) - 0.5) * h * 0.1
        var back = Path()
        var front = Path()
        for i in 0..<8 {
            let u: CGFloat = (CGFloat(i) + 0.5) / 8 * 2 - 1
            let ex: CGFloat = x + (u + (rnd(&random) - 0.5) * 0.16) * h * 0.32
            let sy: CGFloat = hubY + h * 0.06 * rnd(&random)
            let start = CGPoint(x: x + u * foot * 0.6, y: sy)
            let control = CGPoint(x: ex, y: sy - h * 0.02)
            if i % 2 == 0 {
                back.move(to: start)
                back.addQuadCurve(to: CGPoint(x: ex, y: waterY + 1), control: control)
            } else {
                front.move(to: start)
                front.addQuadCurve(to: CGPoint(x: ex, y: waterY + 1), control: control)
            }
        }
        shadow(&context, x, waterY, width: h * 0.7, alpha: 0.2)
        let root: CGFloat = max(1.4, h * 0.022)
        Art.stroke(&context, back, treeTone(bark, 0.68), width: root * 0.85)
        Art.stroke(&context, front, Art.color(bark), width: root)
        let shifted: Path = front.applying(CGAffineTransform(translationX: -root * 0.28, y: 0))
        Art.stroke(&context, shifted, treeTone(bark, 1.4).opacity(0.7), width: root * 0.3)
        ripples(&context, x, waterY + 2, h * 0.6, count: 2)
        let trunk = treeTrunk(x, hubY + h * 0.07, topX, waterY - h * 0.62, foot, foot * 0.6)
        treeBark(&context, trunk.shape, trunk.edge, bark)
        let blobs: [Blob] = treeCrown(topX, waterY - h * 0.74, h * 0.36, h * 0.26, count: 6, seed: seed &+ 3)
        canopy(&context, blobs, seed: seed &+ 9, palette: palette)
    }

    /// A bare winter tree (trunk and branching twigs only).
    static func bareTree(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, height: CGFloat, bark: UInt32 = 0x4A3A44, seed: UInt32 = 1) {
        let h: CGFloat = max(1, height)
        var random = ArtRandom(seed)
        let foot: CGFloat = max(2, h * 0.045)
        let forkY: CGFloat = baseY - h * 0.42
        let topX: CGFloat = x + (rnd(&random) - 0.5) * h * 0.06
        let up: CGFloat = -CGFloat.pi / 2
        shadow(&context, x, baseY, width: h * 0.4, alpha: 0.18)
        var tips: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [(topX, forkY + foot, up, h * 0.25)]
        var girth: CGFloat = foot * 0.9
        for level in 0..<4 {
            var next: [(CGFloat, CGFloat, CGFloat, CGFloat)] = []
            var limbs = Path()
            let kids: Int = level == 0 ? 3 : 2
            let fanWide: CGFloat = level == 0 ? 0.62 : 0.95
            for tip in tips {
                for k in 0..<kids {
                    let fan: CGFloat = CGFloat(k) - CGFloat(kids - 1) / 2
                    let a: CGFloat = tip.2 + fan * fanWide + (rnd(&random) - 0.5) * 0.3
                    let reach: CGFloat = tip.3 * (0.8 + rnd(&random) * 0.3)
                    let ex: CGFloat = tip.0 + cos(a) * reach
                    let ey: CGFloat = tip.1 + sin(a) * reach
                    let control = CGPoint(x: mix(tip.0, ex, 0.5), y: mix(tip.1, ey, 0.5) + reach * 0.12)
                    limbs.move(to: CGPoint(x: tip.0, y: tip.1))
                    limbs.addQuadCurve(to: CGPoint(x: ex, y: ey), control: control)
                    let child: (CGFloat, CGFloat, CGFloat, CGFloat) = (ex, ey, a * 0.8 + up * 0.2, tip.3 * 0.64)
                    next.append(child)
                }
            }
            Art.stroke(&context, limbs, treeTone(bark, 0.9), width: max(0.7, girth))
            girth *= 0.55
            tips = next
        }
        let trunk = treeTrunk(x, baseY, topX, forkY, foot, foot * 0.5)
        treeBark(&context, trunk.shape, trunk.edge, bark)
    }

    /// Adds the flat shape of one far tree to `path`.
    static func treeFarShape(_ path: inout Path, _ x: CGFloat, _ baseY: CGFloat, _ height: CGFloat, conifer: Bool) {
        let h: CGFloat = max(1, height)
        let stickTop: CGFloat = baseY - h * (conifer ? 0.2 : 0.5)
        path.move(to: CGPoint(x: x - h * 0.018, y: stickTop))
        path.addLine(to: CGPoint(x: x + h * 0.018, y: stickTop))
        path.addLine(to: CGPoint(x: x + h * 0.035, y: baseY))
        path.addLine(to: CGPoint(x: x - h * 0.035, y: baseY))
        path.closeSubpath()
        if conifer {
            for k in 0..<3 {
                let bottom: CGFloat = baseY - h * 0.1 - h * 0.26 * CGFloat(k)
                let half: CGFloat = h * 0.24 * (1 - 0.28 * CGFloat(k))
                path.move(to: CGPoint(x: x, y: bottom - h * 0.38))
                path.addLine(to: CGPoint(x: x + half, y: bottom))
                path.addQuadCurve(to: CGPoint(x: x - half, y: bottom), control: CGPoint(x: x, y: bottom - h * 0.05))
                path.closeSubpath()
            }
        } else {
            path.addEllipse(in: CGRect(x: x - h * 0.26, y: baseY - h, width: h * 0.52, height: h * 0.62))
            path.addEllipse(in: CGRect(x: x - h * 0.4, y: baseY - h * 0.72, width: h * 0.4, height: h * 0.38))
            path.addEllipse(in: CGRect(x: x + h * 0.02, y: baseY - h * 0.76, width: h * 0.38, height: h * 0.38))
        }
    }

    /// A small far tree for the far plane, in one flat colour (already hazy): a clump on a
    /// stick, or a small triangle stack when `conifer`.
    static func farTree(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, height: CGFloat, color: Color, conifer: Bool = false) {
        var path = Path()
        treeFarShape(&path, x, baseY, height, conifer: conifer)
        Art.fill(&context, path, color)
    }

    /// A far tree line: `count` far trees of varied heights between x0 and x1.
    static func farTrees(_ context: inout GraphicsContext, x0: CGFloat, x1: CGFloat, baseY: CGFloat, height: CGFloat, count: Int, color: Color, conifer: Bool = false, seed: UInt32 = 1) {
        guard count > 0 else { return }
        var random = ArtRandom(seed)
        var path = Path()
        let gap: CGFloat = (x1 - x0) / CGFloat(count)
        for i in 0..<count {
            let jitter: CGFloat = (rnd(&random) - 0.5) * 0.7
            let tx: CGFloat = x0 + gap * (CGFloat(i) + 0.5 + jitter)
            let th: CGFloat = height * (0.62 + rnd(&random) * 0.45)
            treeFarShape(&path, tx, baseY, th, conifer: conifer)
        }
        Art.fill(&context, path, color)
    }
}
