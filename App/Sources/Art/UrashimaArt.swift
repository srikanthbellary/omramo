import SwiftUI
import OmramoCore

/// Concept art for "The Story of Urashima Taro", drawn in code.
///
/// Ported from the locked design source (docs/design/source/src/lib/art-urashima.js): flat graded
/// haze, layered wave bands with seigaiha texture and foam fingers, a limited palette. The wave
/// bands are our own design. Concept art only; final art is to be commissioned and reviewed.
///
/// This file holds the entry point, the palette, the sea (wave bands) and the figures.
/// The scenes are in `UrashimaArt+Scenes.swift`, the tap-to-see pictures, portraits, faces and
/// cover in `UrashimaArt+Pictures.swift`.
enum UrashimaArt {
    /// Draws the picture called `name`. Returns false for a name this story does not have.
    static func paint(_ name: String, role: ArtRole, in context: inout GraphicsContext, size: CGSize) -> Bool {
        let w = max(size.width, 1)
        let h = max(size.height, 1)
        switch (name, role) {
        case ("scene-shore", .sceneUnfolded):
            sceneBeach(&context, h: h, folded: false, later: false)
        case ("scene-sea", .sceneUnfolded):
            sceneSea(&context, h: h, folded: false)
        case ("scene-deep", .sceneUnfolded):
            sceneDeep(&context, h: h, folded: false)
        case ("scene-palace", .sceneUnfolded):
            scenePalace(&context, h: h, folded: false)
        case ("scene-return", .sceneUnfolded):
            sceneBeach(&context, h: h, folded: false, later: true)

        case ("scene-shore", .sceneFolded):
            foldedScene(&context, width: w, height: h, tail: dayFills[4], crest: true) { g, vh in
                sceneBeach(&g, h: vh, folded: true, later: false)
            }
        case ("scene-sea", .sceneFolded):
            foldedScene(&context, width: w, height: h, tail: dayFills[5], crest: true) { g, vh in
                sceneSea(&g, h: vh, folded: true)
            }
        case ("scene-deep", .sceneFolded):
            foldedScene(&context, width: w, height: h, tail: deepFloor, crest: false) { g, vh in
                sceneDeep(&g, h: vh, folded: true)
            }
        case ("scene-palace", .sceneFolded):
            foldedScene(&context, width: w, height: h, tail: palaceFloor, crest: false) { g, vh in
                scenePalace(&g, h: vh, folded: true)
            }
        case ("scene-return", .sceneFolded):
            foldedScene(&context, width: w, height: h, tail: duskFills[4], crest: true) { g, vh in
                sceneBeach(&g, h: vh, folded: true, later: true)
            }

        case ("see-fishing-boats", .picture):
            seeFishingBoats(&context, w: w, h: h)
        case ("see-rin-gin", .picture):
            seeRinGin(&context, w: w, h: h)
        case ("see-tamatebako", .picture):
            seeTamatebako(&context, w: w, h: h)

        case ("char-urashima", .portrait):
            portraitUrashima(&context, w: w, h: h)
        case ("char-tortoise", .portrait):
            portraitTortoise(&context, w: w, h: h)
        case ("char-otohime", .portrait):
            portraitOtohime(&context, w: w, h: h)

        case ("face-urashima", .face):
            faceUrashima(&context, w: w, h: h)
        case ("face-tortoise", .face):
            faceTortoise(&context, w: w, h: h)
        case ("face-otohime", .face):
            faceOtohime(&context, w: w, h: h)

        case ("cover", .cover):
            cover(&context, w: w, h: h)

        default:
            return false
        }
        return true
    }

    // MARK: - Palette

    static let white = Art.color(0xFFFFFF)
    static let ink = Art.color(0x1E1B2E)
    static let skin = Art.color(0xF6D2AC)
    static let gold = Art.color(0xF4C95A)
    static let red = Art.color(0xE0453A)
    static let coatBlue = Art.color(0x274F99)

    /// The seven wave-band colours of the design, far to near.
    static let dayFills: [Color] = [
        Art.color(0xCDE7F0), Art.color(0xA9D3E6), Art.color(0x7FB9DB), Art.color(0x4F93CB),
        Art.color(0x2B6BB3), Art.color(0x1B4C93), Art.color(0x12356F),
    ]

    /// The same bands under a grey-lavender haze (the changed shore).
    static let duskFills: [Color] = [
        Art.color(0xDCDEEC), Art.color(0xC3C9DF), Art.color(0xA3ADCD), Art.color(0x8290BA),
        Art.color(0x6272A5), Art.color(0x4A5A8E), Art.color(0x364476),
    ]

    static let daySky: [(Color, CGFloat)] = [
        (Art.color(0xE4F3FA), 0), (Art.color(0xF0F8FB), 0.45), (Art.color(0xFFF1E6), 0.7), (Art.color(0xFFE3D3), 0.9),
        (Art.color(0xFFE3D3), 1),
    ]

    static let eveningSky: [(Color, CGFloat)] = [
        (Art.color(0xEAF4FB), 0), (Art.color(0xF4F1EC), 0.5), (Art.color(0xFCE8DC), 0.8), (Art.color(0xFBDCCB), 1),
    ]

    static let duskSky: [(Color, CGFloat)] = [
        (Art.color(0xECEBF5), 0), (Art.color(0xF1EEF1), 0.5), (Art.color(0xEFE4E8), 0.8), (Art.color(0xE7DCE6), 1),
    ]

    static let deepFloor = Art.color(0x8FD0C8)
    static let palaceFloor = Art.color(0xC9E6DC)

    // MARK: - Small helpers

    static func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        CGPoint(x: x, y: y)
    }

    /// Degrees to radians.
    static func rad(_ degrees: CGFloat) -> CGFloat {
        degrees * CGFloat.pi / 180
    }

    static func smooth(_ value: CGFloat) -> CGFloat {
        let t = max(0, min(1, value))
        return t * t * (3 - 2 * t)
    }

    static func fillBackground(_ context: inout GraphicsContext, _ w: CGFloat, _ h: CGFloat, _ stops: [(Color, CGFloat)]) {
        Art.fillLinear(&context, Art.rect(0, 0, w, h), stops, from: pt(0, 0), to: pt(0, h))
    }

    /// The upper half of a circle, as one stroke segment (seigaiha and maki-e arcs).
    static func addArch(_ path: inout Path, _ cx: CGFloat, _ cy: CGFloat, _ r: CGFloat) {
        let lift = r * 4 / 3
        path.move(to: pt(cx - r, cy))
        path.addCurve(to: pt(cx + r, cy), control1: pt(cx - r, cy - lift), control2: pt(cx + r, cy - lift))
    }

    // MARK: - Folded scenes

    /// Draws an unfolded scene's trailing-pane picture into the folded picture band. The scene is
    /// drawn in its own 892-wide space, anchored to the bottom-right, and scaled down when the band
    /// is short. The last 20 units are plain `tail` colour for the caller's wave cut.
    static func foldedScene(
        _ context: inout GraphicsContext,
        width: CGFloat,
        height: CGFloat,
        tail: Color,
        crest: Bool,
        _ scene: (inout GraphicsContext, CGFloat) -> Void
    ) {
        let tailHeight: CGFloat = 20
        let usable = max(height - tailHeight, 60)
        let k = min(1, usable / 330)
        let virtualHeight = usable / k
        let shift = 892 - width / k
        Art.fill(&context, Art.rect(0, 0, width, height), tail)
        let frame = Art.rect(0, 0, width, usable)
        Art.clipped(&context, to: frame) { g in
            Art.group(&g, x: -shift * k, y: 0, scale: k) { inner in
                scene(&inner, virtualHeight)
            }
        }
        if crest {
            let line = usable - 5
            waveBand(
                &context, x0: 0, x1: width, bottom: height, amp: 6, length: 48, phase: 9,
                fill: tail, foamOpacity: 0.85
            ) { _ in line }
        }
    }

    // MARK: - Sea

    struct BandSpec: Sendable {
        let offset: CGFloat
        let amp: CGFloat
        let length: CGFloat
        let foamOpacity: Double
        let fingers: Bool
        /// 0 none, 1 fine white seigaiha, 2 larger pale-blue seigaiha.
        let texture: Int
    }

    static let bandSpecs: [BandSpec] = [
        BandSpec(offset: 0, amp: 3, length: 30, foamOpacity: 0.7, fingers: false, texture: 0),
        BandSpec(offset: 16, amp: 4, length: 36, foamOpacity: 0.8, fingers: false, texture: 0),
        BandSpec(offset: 36, amp: 5, length: 44, foamOpacity: 0.85, fingers: false, texture: 1),
        BandSpec(offset: 62, amp: 7, length: 54, foamOpacity: 0.92, fingers: true, texture: 0),
        BandSpec(offset: 96, amp: 9, length: 66, foamOpacity: 0.92, fingers: true, texture: 2),
        BandSpec(offset: 140, amp: 11, length: 80, foamOpacity: 0.92, fingers: true, texture: 0),
        BandSpec(offset: 200, amp: 13, length: 96, foamOpacity: 0.92, fingers: true, texture: 2),
    ]

    /// The swell of the design's `seaScene`: band crests sit at `low` where the sea is calm and
    /// rise by `lift` between `riseStart` and `riseEnd`.
    struct Sea {
        var low: CGFloat
        var lift: CGFloat = 0
        var riseStart: CGFloat = 300
        var riseEnd: CGFloat = 640
        /// Scales band spacing, crest height and crest length (small pictures).
        var scale: CGFloat = 1

        func top(_ index: Int, _ x: CGFloat) -> CGFloat {
            let last = UrashimaArt.bandSpecs.count - 1
            let spec = UrashimaArt.bandSpecs[min(max(index, 0), last)]
            var rise: CGFloat = 0
            let span = riseEnd - riseStart
            if lift != 0, span > 0 {
                rise = lift * UrashimaArt.smooth((x - riseStart) / span)
            }
            let share = 1 - CGFloat(index) * 0.09
            return low + spec.offset * scale - rise * share
        }
    }

    /// One band of `sea`, filled down to `bottom`. Returns the band's shape.
    @discardableResult
    static func seaBand(
        _ context: inout GraphicsContext,
        _ sea: Sea,
        _ index: Int,
        fills: [Color],
        x0: CGFloat = 0,
        x1: CGFloat = 892,
        bottom: CGFloat,
        textured: Bool = true
    ) -> Path {
        guard index >= 0, index < bandSpecs.count, index < fills.count else { return Path() }
        let spec = bandSpecs[index]
        var nextOffset = spec.offset + 70
        if index + 1 < bandSpecs.count {
            nextOffset = bandSpecs[index + 1].offset
        }
        let gap = (nextOffset - spec.offset) * sea.scale
        let depth = gap + sea.lift * 0.09 + 10
        return waveBand(
            &context, x0: x0, x1: x1, bottom: bottom,
            amp: spec.amp * sea.scale, length: spec.length * sea.scale, phase: CGFloat(index) * 17,
            fill: fills[index], foamOpacity: spec.foamOpacity, fingers: spec.fingers, seed: UInt32(index + 3),
            texture: textured ? spec.texture : 0, textureDepth: depth, detail: sea.scale
        ) { x in
            sea.top(index, x)
        }
    }

    /// One woodblock wave band across x0…x1 (design `waveBand`): the top edge follows `base(x)`
    /// with scalloped crests, a white foam line, optional foam fingers and seigaiha texture.
    @discardableResult
    static func waveBand(
        _ context: inout GraphicsContext,
        x0: CGFloat,
        x1: CGFloat,
        bottom: CGFloat,
        amp: CGFloat,
        length: CGFloat,
        phase: CGFloat = 0,
        fill: Color,
        foam: Color = UrashimaArt.white,
        foamOpacity: Double = 0.9,
        fingers: Bool = false,
        seed: UInt32 = 1,
        texture: Int = 0,
        textureDepth: CGFloat = 40,
        detail: CGFloat = 1,
        base: (CGFloat) -> CGFloat
    ) -> Path {
        let len = max(length, 4)
        var shape = Path()
        var crest = Path()
        shape.move(to: pt(x0, bottom))
        shape.addLine(to: pt(x0, base(x0)))
        var x = x0
        var first = true
        var minTop = base(x0)
        var maxTop = minTop
        while x <= x1 {
            var m = (x + phase).truncatingRemainder(dividingBy: len)
            if m < 0 {
                m += len
            }
            let t = m / len
            let wave: CGFloat = sin(CGFloat.pi * t)
            let lobe: CGFloat = pow(max(wave, 0), 0.7)
            let level = base(x)
            minTop = min(minTop, level)
            maxTop = max(maxTop, level)
            let point = pt(x, level - amp * lobe)
            shape.addLine(to: point)
            if first {
                crest.move(to: point)
                first = false
            } else {
                crest.addLine(to: point)
            }
            x += 3
        }
        shape.addLine(to: pt(x1, bottom))
        shape.closeSubpath()
        Art.fill(&context, shape, fill)

        if texture != 0 {
            let radius: CGFloat = (texture == 1 ? 16 : 20) * max(detail, 0.5)
            let tint = texture == 1 ? Art.color(0xFFFFFF, 0.26) : Art.color(0x9CC8EE, 0.24)
            let rowStep = radius / 2
            let colStep = radius * 2
            let firstRow = Int(((minTop - amp) / rowStep).rounded(.down))
            let lowest = min(maxTop + textureDepth, bottom + radius)
            let lastRow = Int((lowest / rowStep).rounded(.up))
            var arcs = Path()
            var motifs = 0
            if lastRow >= firstRow {
                for row in firstRow...lastRow {
                    let cy = CGFloat(row) * rowStep
                    let odd = row % 2 != 0
                    var cx = (x0 / colStep).rounded(.down) * colStep
                    if odd {
                        cx += radius
                    }
                    while cx <= x1 + radius, motifs < 170 {
                        let level = base(min(max(cx, x0), x1))
                        if cy >= level - 2, cy <= level + textureDepth, cy - radius < bottom {
                            addArch(&arcs, cx, cy, radius)
                            addArch(&arcs, cx, cy, radius * 0.52)
                            motifs += 1
                        }
                        cx += colStep
                    }
                }
            }
            let arcPath = arcs
            Art.clipped(&context, to: shape) { g in
                Art.stroke(&g, arcPath, tint, width: 1.1)
            }
        }

        Art.stroke(&context, crest, foam.opacity(foamOpacity), width: 2.2 * max(detail, 0.6))

        if fingers {
            var random = ArtRandom(seed)
            var curls = Path()
            var dots = Path()
            var m = phase.truncatingRemainder(dividingBy: len)
            if m < 0 {
                m += len
            }
            var fx = x0 + (len - m)
            while fx <= x1 {
                let level = base(fx)
                let s = (0.7 + CGFloat(random.next()) * 0.6) * detail
                let start = pt(fx - 9 * s, level - amp * 0.7)
                let mid = pt(start.x + 11 * s, start.y - 6 * s)
                let end = pt(mid.x - 4 * s, mid.y + 6 * s)
                curls.move(to: start)
                curls.addQuadCurve(to: mid, control: pt(start.x + 4 * s, start.y - 9 * s))
                curls.addQuadCurve(to: end, control: pt(mid.x - 5 * s, mid.y + s))
                curls.closeSubpath()
                let r1: CGFloat = 1.5 * s
                let r2: CGFloat = s
                let crestY: CGFloat = level - amp
                let dot1X: CGFloat = fx + 5 * s
                let dot1Y: CGFloat = crestY - 6 * s
                let dot2X: CGFloat = fx + 10 * s
                let dot2Y: CGFloat = crestY - 2 * s
                dots.addPath(Art.circle(dot1X, dot1Y, r1))
                dots.addPath(Art.circle(dot2X, dot2Y, r2))
                fx += len
            }
            Art.fill(&context, curls, foam.opacity(foamOpacity))
            Art.fill(&context, dots, foam.opacity(foamOpacity * 0.75))
        }
        return shape
    }

    /// The red sun in haze (design `rsun` / `rsung` and the three haze strips).
    static func sun(_ context: inout GraphicsContext, _ cx: CGFloat, _ cy: CGFloat, _ r: CGFloat, strips: Bool = true) {
        let halo = Art.color(0xFFB199)
        let glowRadius = r * 2.6
        Art.fillRadial(
            &context, Art.circle(cx, cy, glowRadius),
            [(halo.opacity(0.7), 0), (halo.opacity(0), 1)],
            center: pt(cx, cy), radius: glowRadius
        )
        let body = Art.color(0xF4503F)
        Art.fillRadial(
            &context, Art.circle(cx, cy, r),
            [(Art.color(0xFF6A52, 0.92), 0), (body.opacity(0.92), 0.8), (body.opacity(0), 1)],
            center: pt(cx, cy), radius: r
        )
        if strips {
            let k = r / 50
            let haze = Art.color(0xFFF1E6)
            Art.fill(&context, Art.rect(cx - 100 * k, cy - 12 * k, 192 * k, 4 * k), haze.opacity(0.7))
            Art.fill(&context, Art.rect(cx - 70 * k, cy + 4 * k, 162 * k, 3 * k), haze.opacity(0.6))
            Art.fill(&context, Art.rect(cx - 60 * k, cy - 26 * k, 130 * k, 3 * k), haze.opacity(0.5))
        }
    }

    // MARK: - Tortoise

    /// The tortoise (design `tortoise`): an old sea tortoise trailing a seaweed tail. Faces left;
    /// the origin is the shell centre at the waterline.
    static func tortoise(
        _ context: inout GraphicsContext,
        tail: Bool = true,
        lookX: CGFloat = 0,
        lookY: CGFloat = 0,
        smile: Bool = true
    ) {
        if tail {
            for i in 0..<5 {
                let f = CGFloat(i)
                var strand = Path()
                strand.move(to: pt(34, -4 + f * 2))
                strand.addCurve(to: pt(92, -2 + f * 5), control1: pt(54, -10 + f * 4), control2: pt(70, 6 + f * 3))
                strand.addCurve(to: pt(124, f * 5), control1: pt(104, -6 + f * 4), control2: pt(112, 4 + f * 3))
                let tint = i % 2 == 1 ? Art.color(0x3F8F5E, 0.9) : Art.color(0x2F7A52, 0.9)
                Art.stroke(&context, strand, tint, width: 2.2)
            }
        }
        // Flippers.
        Art.fill(&context, Art.svg("M-30,6 C-44,10 -52,20 -50,26 C-40,26 -30,18 -24,10Z"), Art.color(0x6E9A54))
        Art.fill(&context, Art.svg("M20,8 C30,16 34,24 30,28 C22,26 14,18 12,10Z"), Art.color(0x5E8A4A))
        // Neck and head.
        let skinStops: [(Color, CGFloat)] = [(Art.color(0xA9C873), 0), (Art.color(0x6E9A54), 1)]
        Art.fillLinear(
            &context,
            Art.svg("M-30,-2 C-42,-8 -48,-22 -50,-34 C-44,-40 -36,-38 -34,-30 C-32,-20 -26,-12 -20,-8Z"),
            skinStops, from: pt(-50, -40), to: pt(-20, -2)
        )
        Art.stroke(&context, Art.svg("M-42,-18 q5,-1 8,2 M-44,-26 q5,-2 9,1"), Art.color(0x4F7A3E, 0.6), width: 1, cap: .butt)
        Art.group(&context, x: -52, y: -40, rotate: rad(-14)) { g in
            Art.fillLinear(&g, Art.ellipse(0, 0, 14, 11), skinStops, from: pt(-14, -11), to: pt(14, 11))
        }
        Art.fill(&context, Art.circle(-56, -43, 4.2), white)
        Art.fill(&context, Art.circle(-57 + lookX, -43 + lookY, 2.6), Art.color(0x1B2B1D))
        Art.fill(&context, Art.circle(-57.8 + lookX, -44 + lookY, 0.9), white)
        Art.stroke(&context, Art.svg("M-61,-48 q5,-4 10,-1"), Art.color(0x3F6B35), width: 1.6)
        if smile {
            Art.stroke(&context, Art.svg("M-65,-36 q5,5 12,2"), Art.color(0x2F5A3A), width: 1.6)
        }
        Art.fill(&context, Art.circle(-64.5, -41, 0.9), Art.color(0x2F5A3A))
        // Shell.
        let shell = Art.svg("M-38,4 C-38,-22 -16,-34 4,-34 C24,-34 40,-20 40,4 C24,10 -22,10 -38,4Z")
        Art.fillLinear(&context, shell, [(Art.color(0x7FB05A), 0), (Art.color(0x3F6B45), 1)], from: pt(0, -34), to: pt(0, 9))
        let centres: [(CGFloat, CGFloat)] = [(-14, -16), (6, -18), (-24, -6), (-4, -7), (16, -8), (-14, 2), (6, 1), (26, 0)]
        var hexes = Path()
        for (hx, hy) in centres {
            hexes.move(to: pt(hx - 7, hy))
            hexes.addLine(to: pt(hx - 3.5, hy - 5))
            hexes.addLine(to: pt(hx + 3.5, hy - 5))
            hexes.addLine(to: pt(hx + 7, hy))
            hexes.addLine(to: pt(hx + 3.5, hy + 5))
            hexes.addLine(to: pt(hx - 3.5, hy + 5))
            hexes.closeSubpath()
        }
        let hexPath = hexes
        Art.clipped(&context, to: shell) { g in
            Art.stroke(&g, hexPath, Art.color(0x2F5A3A, 0.75), width: 1.4, cap: .butt, join: .miter)
            Art.stroke(&g, Art.svg("M-34,-8 C-24,-26 -6,-32 8,-31"), Art.color(0xC7E88A, 0.4), width: 4)
        }
        Art.fill(
            &context,
            Art.svg("M-38,4 C-22,10 24,10 40,4 C40,8 38,10 34,11 C16,15 -16,15 -34,11 C-37,10 -38,8 -38,4Z"),
            Art.color(0xE8C76A)
        )
    }

    // MARK: - Urashima

    enum Rod {
        /// No rod.
        case absent
        /// Held out over the water, as in the design.
        case cast
        /// Resting on his shoulder (the portrait).
        case shoulder
    }

    enum Pose {
        case standing
        case kneeling
    }

    /// Urashima's head (design `urashimaHead`, and the tilted head of `urashima`), centred on the face.
    static func urashimaHead(_ context: inout GraphicsContext, frontal: Bool) {
        Art.fill(&context, Art.ellipse(0, 0, 13, 14), skin)
        Art.fill(
            &context,
            Art.svg("M-13,-2 C-15,-14 -6,-18 2,-17 C10,-17 15,-10 13,0 C10,-8 4,-11 -3,-10 C-8,-9 -11,-6 -13,-2Z"),
            ink
        )
        Art.fill(&context, Art.svg("M1,-17 C0,-24 5,-27 8,-23 C9,-20 6,-17 4,-16Z"), ink)
        let blush = Art.color(0xF58A7A, 0.5)
        let lips = Art.color(0xB5533A)
        if frontal {
            Art.fill(&context, Art.circle(-5, 1, 1.7), ink)
            Art.fill(&context, Art.circle(4, 1, 1.7), ink)
            Art.stroke(&context, Art.svg("M-4,7 q4,3.5 8,0"), lips, width: 1.5)
            Art.fill(&context, Art.ellipse(-8, 5, 2.6, 1.8), blush)
            Art.fill(&context, Art.ellipse(8, 5, 2.6, 1.8), blush)
        } else {
            Art.stroke(&context, Art.line(1.5, -18, 7.5, -18), red, width: 1.8, cap: .butt)
            Art.fill(&context, Art.circle(-6.5, 1, 1.7), ink)
            Art.fill(&context, Art.circle(2.5, 1.5, 1.7), ink)
            Art.stroke(&context, Art.svg("M-6,7 q4,3.5 8,.5"), lips, width: 1.5)
            Art.fill(&context, Art.ellipse(-9, 5, 2.6, 1.8), blush)
            Art.fill(&context, Art.ellipse(6, 6, 2.6, 1.8), blush)
        }
    }

    /// Urashima Taro (design `urashima`). Faces left; the origin is at his feet (or, kneeling,
    /// the ground under him).
    static func urashima(
        _ context: inout GraphicsContext,
        rod: Rod = .cast,
        pose: Pose = .standing,
        holdsBox: Bool = false,
        hat: Bool = false
    ) {
        let legSkin = Art.color(0xF2C9A0)
        let footSkin = Art.color(0xE0B088)
        switch pose {
        case .standing:
            if rod == .cast {
                Art.stroke(&context, Art.line(-14, -66, -104, -134), Art.color(0x8A6A3A), width: 2.2)
                Art.stroke(&context, Art.svg("M-104,-134 C-112,-80 -118,-30 -120,22"), Art.color(0xFFFFFF, 0.8), width: 0.8, cap: .butt)
            }
            Art.stroke(&context, Art.svg("M-7,-22 L-9,0 M6,-22 L8,0"), legSkin, width: 6.5)
            Art.stroke(&context, Art.svg("M-13,0 h9 M4,0 h9"), footSkin, width: 5)
            urashimaUpper(&context, rod: rod, reach: false, holdsBox: holdsBox, hat: hat)
        case .kneeling:
            Art.stroke(&context, Art.svg("M2,-5 L24,-4"), legSkin, width: 6.5)
            Art.stroke(&context, Art.svg("M22,-1 h9"), footSkin, width: 5)
            Art.group(&context, y: 18) { g in
                urashimaUpper(&g, rod: rod, reach: !holdsBox, holdsBox: holdsBox, hat: hat)
            }
        }
    }

    /// Coat, straw skirt, arms and head: everything above the knees.
    static func urashimaUpper(_ context: inout GraphicsContext, rod: Rod, reach: Bool, holdsBox: Bool, hat: Bool) {
        if rod == .shoulder {
            Art.stroke(&context, Art.line(10, -44, 36, -146), Art.color(0x8A6A3A), width: 2.2)
            Art.stroke(&context, Art.svg("M36,-146 q7,20 2,46"), Art.color(0x7C8DA6, 0.7), width: 0.7, cap: .butt)
        }
        // Happi coat.
        Art.fillLinear(
            &context,
            Art.svg("M-14,-80 C-18,-66 -18,-52 -16,-42 L16,-42 C18,-52 18,-66 14,-80 C6,-86 -6,-86 -14,-80Z"),
            [(Art.color(0x2F5FB0), 0), (Art.color(0x1B3A7A), 1)],
            from: pt(-18, -86), to: pt(18, -42)
        )
        let pale = Art.color(0xF4F7FB)
        Art.stroke(&context, Art.svg("M-2,-84 L4,-42 M2,-84 L-6,-60"), pale, width: 2.4, cap: .butt, join: .miter)
        let spots: [(CGFloat, CGFloat)] = [(-10, -70), (-11, -58), (10, -66), (11, -54), (-8, -48), (8, -76)]
        var spotPath = Path()
        for (sx, sy) in spots {
            spotPath.addEllipse(in: CGRect(x: sx - 1.5, y: sy - 1.5, width: 3, height: 3))
        }
        Art.fill(&context, spotPath, pale.opacity(0.85))
        Art.stroke(&context, Art.line(-17, -48, 17, -48), red, width: 4.5)
        // Straw skirt.
        for i in 0..<15 {
            let x = -15 + CGFloat(i) * 2.1
            let tint = i % 2 == 1 ? Art.color(0xE9C877) : Art.color(0xD4A94F)
            Art.stroke(&context, Art.line(x * 0.6, -44, x * 1.15, -20), tint, width: 2.6)
        }
        // Arms.
        if holdsBox {
            Art.stroke(&context, Art.svg("M-12,-76 C-20,-72 -25,-66 -27,-60"), coatBlue, width: 8)
            Art.stroke(&context, Art.svg("M12,-76 C15,-66 6,-58 -8,-57"), coatBlue, width: 8)
            Art.group(&context, x: -21, y: -50, scale: 0.24) { g in
                lacquerBox(&g, wisp: false)
            }
            Art.fill(&context, Art.circle(-32, -56, 3.6), legSkin)
            Art.fill(&context, Art.circle(-9, -56, 4), legSkin)
        } else {
            if reach {
                Art.stroke(&context, Art.svg("M-12,-76 C-22,-70 -28,-62 -30,-52"), coatBlue, width: 8)
                Art.fill(&context, Art.circle(-30, -50, 4), legSkin)
            } else {
                Art.stroke(&context, Art.svg("M-12,-76 C-20,-72 -22,-66 -16,-64"), coatBlue, width: 8)
                Art.fill(&context, Art.circle(-15, -65, 4), legSkin)
            }
            Art.stroke(&context, Art.svg("M12,-76 C20,-68 20,-60 14,-56"), coatBlue, width: 8)
            Art.fill(&context, Art.circle(13, -55, 4), legSkin)
        }
        // Head.
        Art.group(&context, x: -1, y: -98, rotate: rad(-6)) { g in
            urashimaHead(&g, frontal: false)
        }
        if hat {
            let brim = Art.svg("M-22,-106 L-1,-124 L20,-104 C6,-110 -8,-110 -22,-106Z")
            Art.fill(&context, brim, Art.color(0xE9C877))
            Art.stroke(&context, brim, Art.color(0xC99A3F), width: 1, cap: .butt, join: .miter)
        }
    }

    // MARK: - Boat

    /// The wooden fishing boat (design `boat`). The origin is the centre of the waterline.
    static func boat(_ context: inout GraphicsContext) {
        Art.fillLinear(
            &context,
            Art.svg("M-92,-22 C-70,-10 -40,-6 0,-6 C44,-6 76,-12 98,-26 C92,-4 78,10 60,12 L-52,12 C-70,10 -86,-4 -92,-22Z"),
            [(Art.color(0xC08A54), 0), (Art.color(0x7A4E2E), 1)],
            from: pt(0, -26), to: pt(0, 12)
        )
        Art.fill(
            &context,
            Art.svg("M-92,-22 C-70,-10 -40,-6 0,-6 C44,-6 76,-12 98,-26 L96,-20 C74,-6 44,0 0,0 C-40,0 -68,-4 -90,-16Z"),
            Art.color(0xE2B27A)
        )
        Art.stroke(
            &context,
            Art.svg("M-80,-4 C-40,4 40,4 84,-8 M-66,6 C-30,10 30,10 70,2"),
            Art.color(0x6A4326, 0.6), width: 1.2, cap: .butt
        )
        Art.stroke(&context, Art.line(98, -26, 108, -35), Art.color(0x8A5A34), width: 4)
    }

    /// The straw fish basket that sits in the boat.
    static func basket(_ context: inout GraphicsContext) {
        Art.fill(&context, Art.svg("M-10,0 C-12,-12 12,-12 10,0Z"), Art.color(0xC99A3F))
        Art.stroke(&context, Art.svg("M-10,0 h20 M-8,-5 h16"), Art.color(0x8A6A2A), width: 1, cap: .butt)
    }

    /// Urashima standing in his boat with his rod (the group of design `seaScene`).
    /// The origin is the boat's waterline centre.
    static func boatWithUrashima(_ context: inout GraphicsContext, tortoiseAboard: Bool = false) {
        Art.group(&context, x: -10, y: -8) { g in
            urashima(&g, rod: .cast)
        }
        Art.group(&context, x: 46, y: -12) { g in
            basket(&g)
        }
        if tortoiseAboard {
            Art.group(&context, x: -52, y: -12, scale: 0.6) { g in
                tortoise(&g, tail: false, lookX: 1.5, lookY: -1.5)
            }
        }
        boat(&context)
    }

    /// Urashima on the tortoise's back, heading right (the rider of design `palaceScene`).
    /// The origin is the tortoise's shell centre.
    static func rider(_ context: inout GraphicsContext, seated: Bool) {
        Art.group(&context, x: 6, y: -30, scale: 0.8, scaleX: -1) { g in
            urashima(&g, rod: .absent, pose: seated ? .kneeling : .standing)
        }
        Art.group(&context, scaleX: -1) { g in
            tortoise(&g)
        }
    }

    // MARK: - Pines, gulls, far shore

    /// A flat woodblock pine (design `pine`), with an optional lean, missing clumps (bare
    /// branches) and snow caps.
    static func pine(
        _ context: inout GraphicsContext,
        _ x: CGFloat,
        _ y: CGFloat,
        _ s: CGFloat,
        _ color: Color,
        trunk: Color? = nil,
        lean: CGFloat = 0,
        clumps: Int = 5,
        snow: Bool = false
    ) {
        let trunkColor = trunk ?? color
        var stem = Path()
        stem.move(to: pt(x, y))
        let stemTopX: CGFloat = x + (lean * 30 - 2) * s
        let stemTopY: CGFloat = y - 30 * s
        let stemBendX: CGFloat = x + (lean * 14 + 3) * s
        let stemBendY: CGFloat = y - 14 * s
        stem.addQuadCurve(to: pt(stemTopX, stemTopY), control: pt(stemBendX, stemBendY))
        Art.stroke(&context, stem, trunkColor, width: 2.2 * s, cap: .butt)
        let offsets: [(CGFloat, CGFloat, CGFloat)] = [(-10, -30, 16), (6, -36, 14), (-2, -42, 12), (-16, -22, 10), (10, -24, 10)]
        var foliage = Path()
        var caps = Path()
        var twigs = Path()
        for (index, item) in offsets.enumerated() {
            let slant = -lean * item.1
            let cx = x + (item.0 + slant) * s
            let cy = y + item.1 * s
            let r = item.2 * s
            if index < clumps {
                foliage.addEllipse(in: CGRect(x: cx - r, y: cy - r * 0.36, width: r * 2, height: r * 0.72))
                let capR = r * 0.78
                caps.addEllipse(in: CGRect(x: cx - capR, y: cy - r * 0.46, width: capR * 2, height: r * 0.34))
            } else {
                twigs.move(to: pt(x + slant * s, cy + 6 * s))
                twigs.addLine(to: pt(cx, cy))
            }
        }
        Art.stroke(&context, twigs, trunkColor, width: 1.1 * s)
        Art.fill(&context, foliage, color)
        if snow {
            Art.fill(&context, caps, white)
        }
    }

    /// A far gull (design `gull`).
    static func gull(_ context: inout GraphicsContext, _ x: CGFloat, _ y: CGFloat, _ s: CGFloat, _ color: Color) {
        var wings = Path()
        wings.move(to: pt(x - 8 * s, y))
        wings.addQuadCurve(to: pt(x, y), control: pt(x - 4 * s, y - 6 * s))
        wings.addQuadCurve(to: pt(x + 8 * s, y), control: pt(x + 4 * s, y - 6 * s))
        Art.stroke(&context, wings, color, width: 1.6 * s)
    }

    /// The far headland of design `seaScene`, sitting on the first band of `sea`.
    static func headlandPath(_ sea: Sea) -> Path {
        let a = sea.top(0, 520)
        let b = sea.top(0, 560)
        let d = sea.top(0, 600)
        let e = sea.top(0, 620)
        let f = sea.top(0, 640)
        let g = sea.top(0, 650)
        var land = Path()
        land.move(to: pt(470, a + 2))
        land.addCurve(to: pt(610, d - 10), control1: pt(500, a - 22), control2: pt(560, b - 26))
        land.addCurve(to: pt(660, g + 4), control1: pt(630, e - 4), control2: pt(650, f))
        land.closeSubpath()
        return land
    }

    /// A very small far house; `tiers: 2` adds an upper storey.
    static func tinyHouse(
        _ context: inout GraphicsContext,
        _ x: CGFloat,
        _ y: CGFloat,
        _ s: CGFloat,
        wall: Color,
        roof: Color,
        tiers: Int = 1
    ) {
        Art.group(&context, x: x, y: y, scale: s) { g in
            Art.fill(&g, Art.rect(-8, -7, 16, 8), wall)
            Art.fill(&g, Art.polygon([pt(-12, -6), pt(-6, -15), pt(6, -15), pt(12, -6)]), roof)
            if tiers > 1 {
                Art.fill(&g, Art.rect(-5, -21, 10, 7), wall)
                Art.fill(&g, Art.polygon([pt(-9, -20), pt(-4, -27), pt(4, -27), pt(9, -20)]), roof)
            }
        }
    }

    // MARK: - Otohime

    /// Princess Otohime's head, centred on the face.
    static func otohimeHead(_ context: inout GraphicsContext) {
        // Two looped knots of hair behind the crown.
        Art.stroke(&context, Art.ellipse(-6, -19, 4.5, 6.5), ink, width: 2.6)
        Art.stroke(&context, Art.ellipse(6, -19, 4.5, 6.5), ink, width: 2.6)
        Art.fill(&context, Art.ellipse(0, 0, 12, 13), Art.color(0xF8DCC0))
        Art.fill(
            &context,
            Art.svg("M-12.6,1 C-15,-13 -7,-17.5 0,-17 C7,-17.5 15,-13 12.6,1 C11,-6 6,-10 0,-11 C-6,-10 -11,-6 -12.6,1Z"),
            ink
        )
        Art.fill(&context, Art.svg("M-12.8,-2 C-14,6 -13.5,13 -12,18 L-9.6,18 C-10.6,12 -10.8,5 -10.4,-3Z"), ink)
        Art.fill(&context, Art.svg("M12.8,-2 C14,6 13.5,13 12,18 L9.6,18 C10.6,12 10.8,5 10.4,-3Z"), ink)
        // Crown ornament.
        Art.fill(&context, Art.svg("M-7,-15 L-5,-21 L-2.5,-17 L0,-23 L2.5,-17 L5,-21 L7,-15Z"), gold)
        Art.fill(&context, Art.circle(0, -18.2, 1.3), red)
        Art.fill(&context, Art.circle(-8.6, -13, 1.2), gold)
        Art.fill(&context, Art.circle(8.6, -13, 1.2), gold)
        // A composed face.
        Art.fill(&context, Art.ellipse(-4.8, 1.8, 1.5, 1.2), ink)
        Art.fill(&context, Art.ellipse(4.8, 1.8, 1.5, 1.2), ink)
        Art.stroke(&context, Art.svg("M-7,1 q2.2,-1.7 4.4,0 M2.6,1 q2.2,-1.7 4.4,0"), ink, width: 0.9)
        Art.stroke(&context, Art.svg("M-7,-3 q2,-1 4,-0.4 M3,-3.4 q2,-0.6 4,0.4"), ink.opacity(0.55), width: 0.7)
        Art.fill(&context, Art.svg("M-2.2,7 q2.2,2 4.4,0 q-2.2,-1 -4.4,0Z"), Art.color(0xC8463C))
        Art.fill(&context, Art.ellipse(-7, 5, 2.4, 1.5), Art.color(0xF58A7A, 0.35))
        Art.fill(&context, Art.ellipse(7, 5, 2.4, 1.5), Art.color(0xF58A7A, 0.35))
    }

    /// Princess Otohime in layered robes of coral, white and jade. The origin is the centre of
    /// her hem on the ground; she is about 146 units tall.
    static func otohime(_ context: inout GraphicsContext) {
        let jade: [(Color, CGFloat)] = [(Art.color(0x6CC7B3), 0), (Art.color(0x2E8F86), 1)]
        // Long hair down her back.
        Art.fill(
            &context,
            Art.svg("M-13,-126 C-24,-106 -27,-70 -25,-34 C-16,-30 16,-30 25,-34 C27,-70 24,-106 13,-126Z"),
            ink
        )
        // Outer robe.
        Art.fillLinear(
            &context,
            Art.svg("M-20,-70 C-26,-40 -34,-14 -42,0 C-20,6 24,6 46,0 C36,-16 26,-44 20,-70Z"),
            [(Art.color(0xF58A7A), 0), (Art.color(0xDE5F52), 1)],
            from: pt(0, -70), to: pt(0, 4)
        )
        Art.stroke(&context, Art.svg("M-40,-3 C-20,3 24,3 44,-3"), Art.color(0xFFFFFF, 0.8), width: 2, cap: .butt)
        // White under-robe showing at the front.
        Art.fill(&context, Art.svg("M-5,-70 C-7,-40 -9,-16 -10,3 L12,3 C10,-16 8,-40 6,-70Z"), Art.color(0xFBF6EE))
        Art.stroke(&context, Art.svg("M-10,3 C-9,-16 -7,-40 -5,-70 M12,3 C10,-16 8,-40 6,-70"), Art.color(0x2E8F86, 0.55), width: 1, cap: .butt)
        // Sleeves.
        let leftSleeve = Art.svg("M-14,-104 C-28,-98 -36,-78 -38,-48 C-32,-43 -22,-45 -17,-52 C-17,-68 -13,-84 -9,-94Z")
        let rightSleeve = Art.svg("M14,-104 C28,-98 36,-78 38,-48 C32,-43 22,-45 17,-52 C17,-68 13,-84 9,-94Z")
        Art.fillLinear(&context, leftSleeve, jade, from: pt(-38, -104), to: pt(-12, -46))
        Art.fillLinear(&context, rightSleeve, jade, from: pt(12, -104), to: pt(38, -46))
        Art.stroke(&context, Art.svg("M-38,-48 C-32,-43 -22,-45 -17,-52 M38,-48 C32,-43 22,-45 17,-52"), Art.color(0xFBF6EE), width: 2.2)
        // Bodice.
        Art.fillLinear(
            &context,
            Art.svg("M-15,-104 C-19,-92 -19,-80 -17,-66 L17,-66 C19,-80 19,-92 15,-104 C7,-109 -7,-109 -15,-104Z"),
            jade, from: pt(0, -108), to: pt(0, -66)
        )
        Art.stroke(&context, Art.svg("M-7,-108 L0,-90 L7,-108"), Art.color(0xFBF6EE), width: 3, cap: .butt, join: .miter)
        Art.stroke(&context, Art.svg("M-4,-108 L0,-97 L4,-108"), Art.color(0xF58A7A), width: 1.4, cap: .butt, join: .miter)
        // Sash.
        Art.fill(&context, Art.svg("M-3,-66 L-6,-34 L-1,-34 L0,-66Z M3,-66 L6,-38 L1,-38 L0,-66Z"), Art.color(0xF7DE9A))
        Art.fill(&context, Art.rect(-18, -77, 36, 11, radius: 2), gold)
        Art.stroke(&context, Art.line(-18, -71.5, 18, -71.5), red, width: 1.6, cap: .butt)
        Art.fill(&context, Art.circle(0, -71.5, 2.6), red)
        // Hair falling forward over each shoulder.
        Art.fill(&context, Art.svg("M-12,-118 C-17,-104 -18,-88 -16,-70 L-12.5,-70 C-13,-88 -12,-104 -9,-116Z"), ink)
        Art.fill(&context, Art.svg("M12,-118 C17,-104 18,-88 16,-70 L12.5,-70 C13,-88 12,-104 9,-116Z"), ink)
        // Neck and head.
        Art.fill(&context, Art.rect(-3.5, -113, 7, 7), Art.color(0xF2CFB0))
        Art.group(&context, y: -122) { g in
            otohimeHead(&g)
        }
    }

    // MARK: - The tamate-bako

    /// The lacquer box (design `lacquerBox`). The origin is the centre of the box's base.
    static func lacquerBox(_ context: inout GraphicsContext, wisp: Bool = true, wispColor: Color = UrashimaArt.white) {
        if wisp {
            let curl = Art.svg("M10,-64 C-10,-84 24,-100 4,-124 C-8,-138 10,-150 4,-162")
            Art.blurred(&context, radius: 2.5, opacity: 0.35) { g in
                Art.stroke(&g, curl, wispColor, width: 5)
            }
        }
        Art.fill(&context, Art.ellipse(0, 2, 62, 7), Art.color(0x000000, 0.22))
        Art.fillLinear(
            &context, Art.svg("M-52,-40 L52,-40 L50,0 L-50,0Z"),
            [(Art.color(0x2B2338), 0), (Art.color(0x14101C), 0.5), (Art.color(0x0A0810), 1)],
            from: pt(-52, -40), to: pt(52, 0)
        )
        Art.fillLinear(
            &context, Art.svg("M-56,-58 L56,-58 L56,-40 L-56,-40Z"),
            [(Art.color(0x3A3048), 0), (Art.color(0x1A1524), 0.4), (Art.color(0x0E0B16), 1)],
            from: pt(-56, 0), to: pt(56, 0)
        )
        Art.stroke(&context, Art.line(-56, -58, 56, -58), Art.color(0xFFFFFF, 0.35), width: 1.6, cap: .butt)
        // Gold maki-e: wave arcs along the base, two plum blossoms.
        var makie = Path()
        let arcCentres: [CGFloat] = [-40, -22, 22, 40]
        for ax in arcCentres {
            addArch(&makie, ax, -6, 9)
            addArch(&makie, ax, -6, 6)
            addArch(&makie, ax, -6, 3)
        }
        makie.move(to: pt(-50, -6))
        makie.addLine(to: pt(50, -6))
        Art.stroke(&context, makie, gold.opacity(0.95), width: 1.3, cap: .butt)
        let blossoms: [(CGFloat, CGFloat)] = [(-38, -24), (34, -27)]
        for (bx, by) in blossoms {
            var petals = Path()
            for step in 0..<5 {
                let angle = rad(CGFloat(step) * 72)
                let px = bx + cos(angle) * 4
                let py = by + sin(angle) * 4
                petals.addEllipse(in: CGRect(x: px - 2.4, y: py - 2.4, width: 4.8, height: 4.8))
            }
            Art.fill(&context, petals, gold)
            Art.fill(&context, Art.circle(bx, by, 1.4), red)
        }
        // The red silk cord.
        Art.fill(&context, Art.rect(-6, -58, 12, 58), red)
        Art.fill(&context, Art.rect(-6, -58, 4, 58), Art.color(0xFF7A6B, 0.6))
        Art.fill(
            &context,
            Art.svg("M0,-60 C-16,-76 -30,-66 -22,-58 C-16,-54 -6,-56 0,-60 C16,-76 30,-66 22,-58 C16,-54 6,-56 0,-60Z"),
            red
        )
        Art.fill(&context, Art.circle(0, -60, 4.6), Art.color(0xB3261E))
        Art.stroke(&context, Art.svg("M-3,-58 C-12,-46 -16,-38 -20,-26 M3,-58 C12,-46 16,-38 20,-26"), red, width: 2.6)
        Art.fill(&context, Art.svg("M-23,-27 l6,2 l-5,14 l-5,-2Z M23,-27 l-6,2 l5,14 l5,-2Z"), gold)
    }
}
