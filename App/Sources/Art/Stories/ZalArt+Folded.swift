import SwiftUI
import OmramoCore

// Zal and the Simurgh: the story's places (Damavand, the Alborz wall, the crag, the nest, the
// garden pavilion, the floor of cloud) and the four folded phone bands.

extension ZalArt {
    // MARK: Places

    /// Dry mountain scrub: thorn bushes and grass of the lower Alborz.
    static func dryGreens() -> Kit.Greens {
        Kit.greens(0x4A5A3A, 0x5E6E44, 0x7A8650, 0xA3A86A, 0xCFCB8E)
    }

    /// Damavand: one smooth white volcanic cone, its lower slopes blue, far off.
    static func damavand(_ g: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, scale s: CGFloat) {
        let half: CGFloat = 115 * s
        let h: CGFloat = 128 * s
        let top: CGFloat = baseY - h
        let lip: CGFloat = 12 * s
        var cone = Path()
        cone.move(to: CGPoint(x: cx - half, y: baseY))
        cone.addQuadCurve(to: CGPoint(x: cx - lip, y: top), control: CGPoint(x: cx - half * 0.3, y: baseY - h * 0.7))
        cone.addLine(to: CGPoint(x: cx + lip, y: top + 1))
        cone.addQuadCurve(to: CGPoint(x: cx + half, y: baseY), control: CGPoint(x: cx + half * 0.3, y: baseY - h * 0.7))
        cone.closeSubpath()
        let snowStops: Kit.Stops = [(Art.color(0xFAFBFC), 0), (Art.color(0xEDF2F7), 0.5), (Art.color(0xC3D2E2), 0.8), (Art.color(0xB2C4D8), 1)]
        Art.fillLinear(&g, cone, snowStops, from: CGPoint(x: cx, y: top), to: CGPoint(x: cx, y: baseY))
        Art.clipped(&g, to: cone) { c in
            let face: Path = Art.polygon([Kit.pt(cx + lip, top), Kit.pt(cx + half, baseY), Kit.pt(cx + half * 0.15, baseY)])
            Art.fill(&c, face, ArtStyle.coolShade.opacity(0.1))
            var streaks = Path()
            let offsets: [CGFloat] = [-0.5, -0.28, -0.08, 0.16, 0.36]
            for offset in offsets {
                let x0: CGFloat = cx + offset * half * 0.4
                streaks.move(to: CGPoint(x: x0, y: top + h * 0.3))
                streaks.addLine(to: CGPoint(x: cx + offset * half, y: top + h * 0.72))
            }
            Art.stroke(&c, streaks, Color.white.opacity(0.55), width: 2.2 * s)
        }
    }

    /// The Alborz: a jagged wall of blue-grey peaks with snow on the tops, a veil of air, and a
    /// nearer line of bare foothills.
    static func alborzWall(_ g: inout GraphicsContext, width w: CGFloat, horizon H: CGFloat, scale s: CGFloat, seed: UInt32, light: Kit.Light) {
        let wall: Path = Kit.peaks(width: w, y: H - 34 * s, amp: 72 * s, seed: seed, bottom: H + 8, sharp: 0.85)
        let top: CGFloat = H - 108 * s
        let snowStops: Kit.Stops = [(Art.color(0xF8FAFC), 0), (Art.color(0xEEF3F8), 0.28), (light.far, 0.48), (light.far, 1)]
        Art.fillLinear(&g, wall, snowStops, from: CGPoint(x: 0, y: top), to: CGPoint(x: 0, y: H))
        Kit.model(&g, wall, light: 0.12, shade: 0.12)
        ArtStyle.atmosphere(&g, width: w, top: H - 120 * s, bottom: H + 8, color: light.haze, alpha: 0.28)
        let foot: Path = Kit.peaks(width: w, y: H - 6 * s, amp: 32 * s, seed: seed &+ 7, bottom: H + 8, sharp: 0.7)
        Art.fill(&g, foot, light.mid)
        let crest: Kit.Stops = [(light.glow.opacity(0.26), 0), (light.glow.opacity(0), 1)]
        Art.clipped(&g, to: foot) { c in
            Art.fillLinear(&c, Art.rect(0, H - 40 * s, w, 34 * s), crest, from: CGPoint(x: 0, y: H - 40 * s), to: CGPoint(x: 0, y: H - 6 * s))
        }
    }

    /// A sheer pillar of pale rock built of soft stacked slabs, as rocks are drawn in Persian
    /// painted pages, from `baseY` up to `topY`.
    static func crag(_ g: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, topY: CGFloat, width: CGFloat, color: UInt32, seed: UInt32) {
        let span: CGFloat = baseY - topY
        guard span > 0, width > 0 else { return }
        var random = ArtRandom(seed)
        let slabs: Int = 5
        for i in 0..<slabs {
            let t0: CGFloat = CGFloat(i) / CGFloat(slabs)
            let t1: CGFloat = CGFloat(i + 1) / CGFloat(slabs)
            let y0: CGFloat = baseY - span * t0 + 4
            let y1: CGFloat = baseY - span * t1
            let midY: CGFloat = (y0 + y1) / 2
            let half0: CGFloat = width * 0.5 * (1 - 0.22 * t0)
            let half1: CGFloat = width * 0.5 * (1 - 0.22 * t1)
            let dx: CGFloat = (Kit.rnd(&random) - 0.5) * width * 0.12
            let x: CGFloat = cx + dx
            var slab = Path()
            slab.move(to: CGPoint(x: x - half0, y: y0))
            slab.addQuadCurve(to: CGPoint(x: x - half1, y: y1 + 8), control: CGPoint(x: x - half0 - 6, y: midY))
            slab.addQuadCurve(to: CGPoint(x: x + half1, y: y1 + 6), control: CGPoint(x: x, y: y1 - 10))
            slab.addQuadCurve(to: CGPoint(x: x + half0, y: y0), control: CGPoint(x: x + half0 + 6, y: midY))
            slab.closeSubpath()
            let tone: CGFloat = i % 2 == 0 ? 1.03 : 0.95
            Kit.solid(&g, slab, Kit.personTone(color, tone), light: 0.3, shade: 0.3, rim: 1.6)
            let strata: Path = Art.line(x - half1 * 0.6, y1 + 15, x + half1 * 0.4, y1 + 17)
            Art.stroke(&g, strata, Kit.personTone(color, 0.8).opacity(0.5), width: 1.2)
        }
    }

    /// The dark hollow and the back rim of the great nest; `y` is the rim line.
    static func nestBack(_ g: inout GraphicsContext, cx: CGFloat, y: CGFloat, width w: CGFloat) {
        let k: CGFloat = w / 300
        Art.fill(&g, Art.ellipse(cx, y, w * 0.47, 12 * k), Art.color(0x3A2A24))
        var random = ArtRandom(91)
        var dark = Path()
        var pale = Path()
        for i in 0..<18 {
            let t: CGFloat = CGFloat(i) / 17
            let x0: CGFloat = cx - w * 0.54 + w * t * 0.92
            let len: CGFloat = w * (0.14 + 0.1 * Kit.rnd(&random))
            let y0: CGFloat = y - 4 * k - 16 * k * Kit.rnd(&random)
            let tilt: CGFloat = (Kit.rnd(&random) - 0.5) * 14 * k
            var stick = Path()
            stick.move(to: CGPoint(x: x0, y: y0))
            stick.addQuadCurve(to: CGPoint(x: x0 + len, y: y0 + tilt), control: CGPoint(x: x0 + len / 2, y: y0 - 6 * k))
            if i % 2 == 0 {
                dark.addPath(stick)
            } else {
                pale.addPath(stick)
            }
        }
        Art.stroke(&g, dark, Art.color(0x2E2220), width: 5 * k)
        Art.stroke(&g, pale, Art.color(0xD6B788), width: 4 * k)
    }

    /// The front of the great nest: a deep bowl of crossed ebony and sandalwood branches.
    static func nestFront(_ g: inout GraphicsContext, cx: CGFloat, y: CGFloat, width w: CGFloat) {
        let k: CGFloat = w / 300
        let half: CGFloat = w * 0.52
        var bowl = Path()
        bowl.move(to: CGPoint(x: cx - half, y: y - 2 * k))
        bowl.addQuadCurve(to: CGPoint(x: cx + half, y: y - 2 * k), control: CGPoint(x: cx, y: y + 10 * k))
        bowl.addQuadCurve(to: CGPoint(x: cx, y: y + 54 * k), control: CGPoint(x: cx + w * 0.46, y: y + 50 * k))
        bowl.addQuadCurve(to: CGPoint(x: cx - half, y: y - 2 * k), control: CGPoint(x: cx - w * 0.46, y: y + 50 * k))
        bowl.closeSubpath()
        Kit.shadow(&g, cx, y + 54 * k, width: w * 0.9, alpha: 0.2)
        Kit.solid(&g, bowl, Art.color(0x4A3428), light: 0.2, shade: 0.3)
        var random = ArtRandom(57)
        var ebony = Path()
        var middle = Path()
        var sandal = Path()
        for i in 0..<34 {
            let x: CGFloat = cx - w * 0.5 + w * 0.92 * Kit.rnd(&random)
            let yy: CGFloat = y + 2 * k + 40 * k * Kit.rnd(&random)
            let len: CGFloat = w * (0.16 + 0.12 * Kit.rnd(&random))
            let a: CGFloat = (Kit.rnd(&random) - 0.5) * 0.8
            let ex: CGFloat = x + cos(a) * len
            let ey: CGFloat = yy + sin(a) * len * 0.5
            var stick = Path()
            stick.move(to: CGPoint(x: x, y: yy))
            stick.addLine(to: CGPoint(x: ex, y: ey))
            switch i % 3 {
            case 0: ebony.addPath(stick)
            case 1: middle.addPath(stick)
            default: sandal.addPath(stick)
            }
        }
        Art.clipped(&g, to: bowl) { c in
            Art.stroke(&c, ebony, Art.color(0x2A1E1C), width: 5 * k)
            Art.stroke(&c, middle, Art.color(0x7A5638), width: 4 * k)
            Art.stroke(&c, sandal, Art.color(0xD9B98A), width: 3.6 * k)
        }
        let twigs: Path = Art.svg("M-120,0 l-14,-12 M-70,2 l-6,-14 M-10,4 l4,-13 M60,2 l10,-12 M118,0 l16,-10 M140,-2 l12,4 M-142,-2 l-12,6")
        let place = CGAffineTransform(translationX: cx, y: y).scaledBy(x: k, y: k)
        Art.stroke(&g, twigs.applying(place), Art.color(0x3A2A24), width: 3 * k)
        let rim: Path = Kit.placed("M-150,-1 Q0,10 150,-1", x: cx, y: y, scale: k)
        Art.stroke(&g, rim, Art.color(0xF4D9A0, 0.55), width: 2.4 * k)
        Kit.model(&g, bowl, light: 0.14, shade: 0.2)
    }

    /// A small lizard come out onto the warm stone, about 34 long.
    static func lizard(_ g: inout GraphicsContext, x: CGFloat, y: CGFloat) {
        Art.group(&g, x: x, y: y) { l in
            Art.stroke(&l, Art.svg("M8,0 C14,1 18,4 25,2"), Art.color(0x7A8A4E), width: 2)
            Art.stroke(&l, Art.svg("M-5,0 l-2,3 M-4,-2 l-2,-3 M4,0 l2,3 M5,-2 l2,-3"), Art.color(0x6A7A44), width: 1.2)
            Kit.solid(&l, Art.svg("M-8,-1 C-4,-3.5 4,-3.5 9,-1 C4,1.5 -4,1.5 -8,-1Z"), Art.color(0x8A9A56), light: 0.3, shade: 0.2)
            Art.fill(&l, Art.ellipse(-10, -1.2, 3.4, 2.2), Art.color(0x8A9A56))
            Art.fill(&l, Art.circle(-11, -1.8, 0.7), Art.color(0x1C1630))
        }
    }

    /// The floor of white cloud the nest's crag rises out of, from `top` down to `bottom`.
    static func cloudFloor(_ g: inout GraphicsContext, width w: CGFloat, top: CGFloat, bottom: CGFloat, scale s: CGFloat) {
        let depth: CGFloat = max(1, bottom - top)
        let cloudStops: Kit.Stops = Kit.stops(0xFDFEFD, 0xEEF5F5, 0xDCE9EC)
        Art.fillLinear(&g, Art.rect(0, top, w, depth), cloudStops, from: CGPoint(x: 0, y: top), to: CGPoint(x: 0, y: bottom))
        var random = ArtRandom(61)
        var billows = Path()
        var x: CGFloat = -30
        while x < w + 40 {
            let r: CGFloat = (26 + 22 * Kit.rnd(&random)) * max(0.5, s)
            billows.addPath(Art.circle(x, top + r * 0.55, r))
            x += r * 1.3
        }
        Art.fill(&g, billows, Art.color(0xFFFFFF))
        Art.clipped(&g, to: billows) { c in
            Art.fill(&c, Art.rect(0, top + 10 * s, w, 40 * s), Art.color(0xD3E3E8, 0.35))
        }
        let rows: [(CGFloat, CGFloat)] = [(0.24, 1.3), (0.5, 1.7), (0.78, 2.1)]
        for row in rows {
            let y: CGFloat = top + depth * row.0
            var px: CGFloat = 60 * Kit.rnd(&random)
            while px < w + 60 {
                Kit.cloud(&g, px, y, scale: row.1 * s, color: Art.color(0xFFFFFF, 0.8))
                px += 150 * row.1 * s
            }
        }
        ArtStyle.tooth(&g, in: CGRect(x: 0, y: top, width: w, height: depth), seed: 63, color: Art.color(0x9FC0D2), alpha: 0.05)
    }

    /// The garden pavilion: a raised open hall on tiled piers with pointed arches, in turquoise,
    /// lapis and white, a carpet and a cushioned seat within. A flat roof; no domes.
    static func pavilion(_ g: inout GraphicsContext, x0: CGFloat, baseY: CGFloat, width w: CGFloat, height h: CGFloat) {
        let floorY: CGFloat = baseY - 14
        let top: CGFloat = baseY - h
        let inside: CGFloat = floorY - top
        guard inside > 30, w > 40 else { return }
        Kit.shadow(&g, x0 + w * 0.5, baseY + 2, width: w + 30, alpha: 0.18)
        Art.fill(&g, Art.rect(x0 - 16, baseY - 5, w + 32, 7, radius: 2), Art.color(0xD9C7A6))
        Kit.solid(&g, Art.rect(x0 - 10, floorY, w + 20, 10, radius: 2), Art.color(0xE6D7BC), light: 0.3, shade: 0.24)
        // The shaded hall within: a tiled back wall, the carpet, a cushioned seat.
        Art.fill(&g, Art.rect(x0, top + 16, w, inside - 16), Art.color(0x2E3F74))
        Art.fill(&g, Art.rect(x0, floorY - 26, w, 26), Art.color(0x3A5A92))
        var dots = Path()
        let count: Int = max(4, Int(w / 14))
        for i in 0..<count {
            let x: CGFloat = x0 + 7 + CGFloat(i) * 14
            dots.addPath(Art.polygon([Kit.pt(x, floorY - 20), Kit.pt(x + 3, floorY - 16), Kit.pt(x, floorY - 12), Kit.pt(x - 3, floorY - 16)]))
        }
        Art.fill(&g, dots, Art.color(turquoise, 0.8))
        Art.fill(&g, Art.rect(x0 + 10, floorY - 5, w - 20, 5), Art.color(0xB8464E))
        Art.stroke(&g, Art.line(x0 + 10, floorY - 5, x0 + w - 10, floorY - 5), Art.color(saffron), width: 1)
        Kit.solid(&g, Art.rect(x0 + w * 0.5, floorY - 15, w * 0.26, 10, radius: 4), Art.color(saffron), light: 0.3, shade: 0.24)
        // The façade. Each arch is wound against the wall's rectangle, so it is left open.
        let bays: Int = 4
        let bw: CGFloat = w / CGFloat(bays)
        let spring: CGFloat = floorY - inside * 0.46
        var arches = Path()
        for i in 0..<bays {
            let l: CGFloat = x0 + CGFloat(i) * bw + 5
            let r: CGFloat = l + bw - 10
            let mid: CGFloat = (l + r) / 2
            let rise: CGFloat = (r - l) * 0.65
            let apex: CGFloat = spring - rise
            var arch = Path()
            arch.move(to: CGPoint(x: r, y: floorY))
            arch.addLine(to: CGPoint(x: r, y: spring))
            arch.addCurve(to: CGPoint(x: mid, y: apex), control1: CGPoint(x: r, y: spring - rise * 0.6), control2: CGPoint(x: mid + rise * 0.2, y: apex + rise * 0.3))
            arch.addCurve(to: CGPoint(x: l, y: spring), control1: CGPoint(x: mid - rise * 0.2, y: apex + rise * 0.3), control2: CGPoint(x: l, y: spring - rise * 0.6))
            arch.addLine(to: CGPoint(x: l, y: floorY))
            arch.closeSubpath()
            arches.addPath(arch)
        }
        let wallBox = CGRect(x: x0, y: top, width: w, height: inside)
        var face = Path()
        face.move(to: CGPoint(x: x0, y: top))
        face.addLine(to: CGPoint(x: x0 + w, y: top))
        face.addLine(to: CGPoint(x: x0 + w, y: floorY))
        face.addLine(to: CGPoint(x: x0, y: floorY))
        face.closeSubpath()
        face.addPath(arches)
        g.fill(face, with: .color(Art.color(0xEEE6D6)), style: FillStyle(eoFill: true))
        ArtStyle.form(&g, face, bounds: wallBox, light: 0.22, shade: 0.2)
        Art.fill(&g, Art.rect(x0, top, w, 16), Art.color(turquoise))
        var diamonds = Path()
        let n: Int = max(4, Int(w / 12))
        for i in 0..<n {
            let x: CGFloat = x0 + 6 + CGFloat(i) * 12
            diamonds.addPath(Art.polygon([Kit.pt(x, top + 3), Kit.pt(x + 4, top + 8), Kit.pt(x, top + 13), Kit.pt(x - 4, top + 8)]))
        }
        Art.fill(&g, diamonds, Art.color(snow, 0.85))
        Art.stroke(&g, Art.line(x0, top + 16, x0 + w, top + 16), Art.color(lapis), width: 2.4)
        Art.stroke(&g, arches, Art.color(lapis), width: 3)
        Art.stroke(&g, arches, Art.color(saffron, 0.7), width: 1)
        var rosettes = Path()
        var hearts = Path()
        for i in 0...bays {
            let x: CGFloat = x0 + CGFloat(i) * bw
            rosettes.addPath(Art.circle(x, top + 26, 3.6))
            hearts.addPath(Art.circle(x, top + 26, 1.4))
        }
        Art.fill(&g, rosettes, Art.color(lapis))
        Art.fill(&g, hearts, Art.color(saffron))
        Kit.solid(&g, Art.rect(x0 - 8, top - 8, w + 16, 9, radius: 2), Art.color(0xC9A27A), light: 0.3, shade: 0.3)
        Art.fill(&g, Art.rect(x0, top + 1, w, 3), ArtStyle.coolShade.opacity(0.18))
        ArtStyle.rimEdge(&g, face, bounds: wallBox, width: 1.6, alpha: 0.4)
    }
}

// MARK: - Folded bands

extension ZalArt {
    /// Sam turned away at the pool; the nurse beyond him holding out the white-haired baby.
    static func courtFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let light = dawn()
        Kit.sky(&context, size, horizon: band.H, light: light)
        Kit.sun(&context, 70, band.H - 30 * u, 12 * u, light: light)
        Kit.ranges(&context, width: 432, horizon: band.H, scale: u, light: light, mountains: false, seed: 22)
        Kit.farTrees(&context, x0: 0, x1: 432, baseY: band.H + 2, height: 30 * u, count: 16, color: light.near.opacity(0.5), conifer: true, seed: 10)
        ArtStyle.atmosphere(&context, width: 432, top: band.H - 50 * u, bottom: band.H + 4, color: light.haze, alpha: 0.3)
        let earth: Kit.Stops = Kit.stops(0xE8D8BC, 0xC9C493, 0x8EA474)
        Kit.ground(&context, width: 432, top: band.H, bottom: size.height, stops: earth, seed: 42)
        pavilion(&context, x0: 304, baseY: band.H + 8 * u, width: 170 * u, height: 112 * u)
        Kit.cypress(&context, x: 40, baseY: band.H + 6, height: 90 * u, color: 0x335A48)
        Kit.cypress(&context, x: 286, baseY: band.H + 6, height: 100 * u, color: 0x2E5242)
        let top: CGFloat = band.H + 10 * u
        let depth: CGFloat = 22 * u
        let pool: Path = Art.rect(-10, top, 300, depth)
        Art.fillLinear(&context, pool, Kit.stops(0xEAC4AE, 0xF6E2D8), from: CGPoint(x: 0, y: top), to: CGPoint(x: 0, y: top + depth))
        Art.clipped(&context, to: pool) { w in
            Art.glow(&w, 70, top + 4, 40 * u, Art.color(0xFFF4DA), alpha: 0.5)
            Kit.rippleMarks(&w, x0: 0, x1: 290, y0: top + 3, y1: top + depth - 2, count: 12, seed: 7, color: Color.white, alpha: 0.4)
        }
        Art.stroke(&context, Art.line(-10, top + depth, 290, top + depth), Art.color(0xF1E6D2), width: 4)
        Art.stroke(&context, Art.line(-10, top + depth - 2, 288, top + depth - 2), Art.color(turquoise), width: 1.6)
        let feet: CGFloat = band.H + band.ground * 0.45
        let k: CGFloat = 0.95 * u
        Kit.shadow(&context, 158, feet, width: 66 * k)
        Art.group(&context, x: 158, y: feet, scale: k) { p in
            sam(&p, pose: .stand, white: false, helmet: true, look: CGPoint(x: -0.8, y: 0.4), mouth: .flat)
        }
        Kit.shadow(&context, 262, feet + 4 * u, width: 60 * k)
        Art.group(&context, x: 262, y: feet + 4 * u, scale: k * 0.96) { p in
            nurse(&p)
        }
        Kit.flowers(&context, in: CGRect(x: 10, y: feet - 4 * u, width: 90, height: 20 * u), count: 7, seed: 9, petal: rose, heart: saffron)
        Kit.cornerLeaves(&context, size: size, corner: 3, color: Art.color(0x24503E), scale: 0.7 * u, seed: 5)
        ArtStyle.finish(&context, size, wash: 0.08, vignette: 0.06)
    }

    /// The bundled baby on a sunlit rock, the Simurgh's wide wings and long tail above him.
    static func mountainFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let light = highDay()
        Kit.sky(&context, size, horizon: band.H, light: light)
        Kit.cloud(&context, 330, 20 + 40 * u, scale: 0.5, color: Art.color(0xF6F9FC, 0.5))
        damavand(&context, cx: 80, baseY: band.H - 8 * u, scale: 0.7 * u)
        alborzWall(&context, width: 432, horizon: band.H, scale: 0.8 * u, seed: 15, light: light)
        let slope: Kit.Stops = Kit.stops(0xCFC39C, 0xB2A682, 0x8E8470)
        Kit.ground(&context, width: 432, top: band.H, bottom: size.height, stops: slope, seed: 44)
        crag(&context, cx: 420, baseY: band.H + 30 * u, topY: band.H - 120 * u, width: 90 * u, color: 0xC6CCD2, seed: 7)
        nestBack(&context, cx: 420, y: band.H - 122 * u, width: 100 * u)
        nestFront(&context, cx: 420, y: band.H - 122 * u, width: 100 * u)
        let rockBase: CGFloat = band.H + band.ground * 0.5
        let rockTop: CGFloat = rockBase - 34 * u
        Kit.shadow(&context, 220, rockBase + 2, width: 190 * u, alpha: 0.1)
        Kit.rock(&context, cx: 210, baseY: rockBase, width: 130 * u, height: 34 * u, color: 0xD2C2A2, seed: 3)
        Art.fill(&context, Art.ellipse(204, rockTop + 4 * u, 46 * u, 5 * u), Art.color(0xFFF1D0, 0.5))
        Art.group(&context, x: 212, y: rockTop - 3 * u, scale: 1.5 * u) { b in
            baby(&b)
        }
        lizard(&context, x: 262, y: rockTop + 12 * u)
        Art.group(&context, x: 228, y: band.H - 26 * u, scale: 0.55 * u) { s in
            simurgh(&s, pose: .glide, look: CGPoint(x: -0.5, y: 0.9))
        }
        Kit.rock(&context, cx: 10, baseY: size.height + 10, width: 120 * u, height: 50 * u, color: 0x6F6A62, seed: 9)
        ArtStyle.finish(&context, size, wash: 0.08, vignette: 0.06)
    }

    /// The boy in the nest among the chicks, under the curve of the Simurgh's wing.
    static func nestFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let light = cloudDay()
        Kit.sky(&context, size, horizon: band.H, light: light)
        Kit.cloud(&context, 90, 30 + 30 * u, scale: 0.5, color: Art.color(0xFFFFFF, 0.45))
        damavand(&context, cx: 70, baseY: band.H + 4, scale: 0.6 * u)
        let peaks: Path = Kit.peaks(width: 432, y: band.H + 6, amp: 36 * u, seed: 24, bottom: band.H + 20, sharp: 0.85)
        let snowy: Kit.Stops = [(Art.color(0xF7F9FB), 0), (Art.color(0xE4EEF4), 0.45), (light.far, 1)]
        Art.fillLinear(&context, peaks, snowy, from: CGPoint(x: 0, y: band.H - 30 * u), to: CGPoint(x: 0, y: band.H + 10))
        ArtStyle.atmosphere(&context, width: 432, top: band.H - 50 * u, bottom: band.H + 10, color: light.haze, alpha: 0.3)
        cloudFloor(&context, width: 432, top: band.H, bottom: size.height, scale: 0.7 * u)
        let k: CGFloat = 1.25 * u
        let Hv: CGFloat = (band.H + 2) / k - 40
        Art.group(&context, x: 216 - 712 * k, y: 0, scale: k) { v in
            nestCrag(&v, Hv)
            nestFamily(&v, Hv)
        }
        ArtStyle.finish(&context, size, wash: 0.08, vignette: 0.05)
    }

    /// Sam kneeling on the rock, looking up, as the Simurgh comes down before him with Zal.
    static func meetingFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let light = morning()
        Kit.sky(&context, size, horizon: band.H, light: light)
        Kit.sun(&context, 60, band.H - 30 * u, 10 * u, light: light)
        damavand(&context, cx: 130, baseY: band.H - 10 * u, scale: 0.6 * u)
        crag(&context, cx: 412, baseY: band.H + 4, topY: band.H - 110 * u, width: 70 * u, color: 0xD3D9DF, seed: 31)
        alborzWall(&context, width: 432, horizon: band.H, scale: 0.8 * u, seed: 30, light: light)
        let field: Kit.Stops = Kit.stops(0xD6D2A6, 0xB5B68C, 0x8E9A7E)
        Kit.ground(&context, width: 432, top: band.H, bottom: size.height, stops: field, seed: 48)
        let far: [CGFloat] = [26, 62]
        for x in far {
            Art.group(&context, x: x, y: band.H + 14 * u, scale: 0.2 * u, scaleX: -1) { r in
                horseman(&r, coat: 0x8A5A3A, cloth: lapis, skin: 0xD2A07A, pennant: saffron, mirrored: true)
            }
        }
        let rockBase: CGFloat = band.H + band.ground * 0.52
        let rockTop: CGFloat = rockBase - 24 * u
        Kit.rock(&context, cx: 130, baseY: rockBase, width: 140 * u, height: 24 * u, color: 0xCBC2AC, seed: 5)
        let k: CGFloat = 0.9 * u
        Kit.shadow(&context, 126, rockTop + 1, width: 72 * k)
        Art.group(&context, x: 126, y: rockTop + 1, scale: k, scaleX: -1) { s in
            sam(&s, pose: .kneel, white: true, helmet: false, look: CGPoint(x: -0.5, y: -0.9), mouth: .sad, mirrored: true)
        }
        Kit.shadow(&context, 280, rockBase + 4, width: 170 * u, alpha: 0.14)
        Art.group(&context, x: 292, y: band.H - 8 * u, rotate: 0.1, scale: 0.5 * u) { s in
            simurgh(&s, pose: .glide, rider: true, look: CGPoint(x: -0.8, y: 0.7))
        }
        Kit.cornerLeaves(&context, size: size, corner: 2, color: Art.color(0x4E5A3A), scale: 0.6 * u, seed: 8)
        ArtStyle.finish(&context, size, wash: 0.08, vignette: 0.06)
    }
}
