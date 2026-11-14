import SwiftUI
import OmramoCore

/// Concept art for "The Story of Urashima Taro", drawn in code.
///
/// Started from the locked design source (docs/design/source/src/lib/art-urashima.js): flat graded
/// haze, layered wave bands with seigaiha texture and foam fingers, a limited palette. The wave
/// bands are our own design. Concept art only; final art is to be commissioned and reviewed.
///
/// This file holds the entry point, the palette, the stages (how a scene grows with its
/// height), the sea (wave bands) and the landscape parts (sun, headlands, pines, houses).
/// - Figures (tortoise, Urashima, Otohime, boat, lacquer box): `UrashimaArt+Figures.swift`.
/// - The five unfolded scenes: `UrashimaArt+Scenes.swift`.
/// - The five folded scenes (their own compositions): `UrashimaArt+Folded.swift`.
/// - Palace parts, tap-to-see pictures, portraits, face chips, cover: `UrashimaArt+Pictures.swift`.
enum UrashimaArt {
    /// Draws the picture called `name`. Returns false for a name this story does not have.
    static func paint(_ name: String, role: ArtRole, in context: inout GraphicsContext, size: CGSize) -> Bool {
        let w = max(size.width, 1)
        let h = max(size.height, 1)
        switch (name, role) {
        case ("scene-shore", .sceneUnfolded):
            sceneBeach(&context, h: h, later: false)
        case ("scene-sea", .sceneUnfolded):
            sceneSea(&context, h: h)
        case ("scene-deep", .sceneUnfolded):
            sceneDeep(&context, h: h)
        case ("scene-palace", .sceneUnfolded):
            scenePalace(&context, h: h)
        case ("scene-return", .sceneUnfolded):
            sceneBeach(&context, h: h, later: true)

        case ("scene-shore", .sceneFolded):
            foldedBeach(&context, w: w, h: h, later: false)
        case ("scene-sea", .sceneFolded):
            foldedSea(&context, w: w, h: h)
        case ("scene-deep", .sceneFolded):
            foldedDeep(&context, w: w, h: h)
        case ("scene-palace", .sceneFolded):
            foldedPalace(&context, w: w, h: h)
        case ("scene-return", .sceneFolded):
            foldedBeach(&context, w: w, h: h, later: true)

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

    /// The same bands three hundred years on: still the story's blues, only quieter and a
    /// little cooler (round 3 used a grey-lavender here, which left the story's ramp).
    static let laterFills: [Color] = [
        Art.color(0xD6E4EC), Art.color(0xBBD0DF), Art.color(0x9DBAD0), Art.color(0x7C9FC0),
        Art.color(0x5C82AD), Art.color(0x45689A), Art.color(0x325084),
    ]

    static let daySky: [(Color, CGFloat)] = [
        (Art.color(0xE4F3FA), 0), (Art.color(0xF0F8FB), 0.45), (Art.color(0xFFF1E6), 0.7), (Art.color(0xFFE3D3), 0.9),
        (Art.color(0xFFE3D3), 1),
    ]

    static let eveningSky: [(Color, CGFloat)] = [
        (Art.color(0xEAF4FB), 0), (Art.color(0xF4F1EC), 0.5), (Art.color(0xFCE8DC), 0.8), (Art.color(0xFBDCCB), 1),
    ]

    /// The changed shore: a cooler, paler haze above, but the low sky still ends in the
    /// story's peach (the ending is sad, never cold).
    static let laterSky: [(Color, CGFloat)] = [
        (Art.color(0xE9F0F5), 0), (Art.color(0xF2EFEC), 0.5), (Art.color(0xF9E7DD), 0.8), (Art.color(0xFBDDCE), 1),
    ]

    /// The peach of the horizon band (the `glow` step of the story's ramp).
    static var horizonTint: Color { ArtStyle.urashima.glowColor }

    /// The last pass of every scene, picture, portrait and cover of this pale story.
    static func finish(_ context: inout GraphicsContext, _ w: CGFloat, _ h: CGFloat, wash: Double = 0.08, vignette: Double = 0.06) {
        ArtStyle.finish(&context, CGSize(width: w, height: h), wash: wash, vignette: vignette)
    }

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

    // MARK: - Stages

    /// How an unfolded scene (892 units wide, 400…1300 tall) is laid out.
    ///
    /// The picture is one block anchored to the bottom edge. It is designed 240 units deep
    /// (horizon to bottom edge) and grows with the canvas: the horizon always sits about 64%
    /// of the way down, so a tall iPad window gets a deeper sea, larger waves, trees and
    /// figures instead of a stretched sky, and a short window gets a smaller picture in
    /// which nothing collides. Positions are given in "units above the bottom at scale 1".
    struct Stage {
        let h: CGFloat
        /// Scale of the picture block: 1 at a height of about 667, 0.62…1.8.
        let s: CGFloat
        /// Scale of the figures: follows `s` but stops growing sooner.
        let fig: CGFloat
        /// The y of the horizon.
        let horizon: CGFloat

        init(_ height: CGFloat) {
            let depth: CGFloat = max(150, height * 0.36)
            let scale: CGFloat = min(1.8, max(0.62, depth / 240))
            h = height
            s = scale
            fig = min(scale, 1.5)
            horizon = height - 240 * scale
        }

        /// The y of a point `up` design units above the bottom edge.
        func y(_ up: CGFloat) -> CGFloat {
            h - up * s
        }
    }

    /// How a folded scene (432 units wide, 240…520 tall) is laid out: its own composition,
    /// anchored to the bottom above the caller's wave cut, scaled with the height.
    struct FoldedStage {
        let h: CGFloat
        /// 1 at a height of 420; 0.57…1.2.
        let s: CGFloat
        /// The lowest y that holds anything essential (the caller's wave cut is below it).
        let base: CGFloat

        init(_ height: CGFloat) {
            h = height
            s = min(1.2, max(0.57, height / 420))
            base = height - 24
        }

        /// The y of a point `up` design units above `base`.
        func y(_ up: CGFloat) -> CGFloat {
            base - up * s
        }

        /// The scale of a figure whose feet are at `footY` and whose face is `face` units
        /// above its feet (at scale 1): `preferred` × `s`, or less when the face would
        /// otherwise sit under the top controls (the top 118 units).
        func figure(_ preferred: CGFloat, footY: CGFloat, face: CGFloat) -> CGFloat {
            let room: CGFloat = (footY - 118) / max(face, 1)
            return max(0.3, min(preferred * s, room))
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

    /// How much of a swell each band takes: none at the horizon (which stays a straight,
    /// calm line), all of it in the nearest band.
    static let swellShare: [CGFloat] = [0, 0, 0.1, 0.35, 0.6, 0.8, 1]

    /// A sea of seven bands under a level horizon at `low`. The near bands may rise by
    /// `swell` between `riseStart` and `riseEnd` (the swell under the boat).
    struct Sea {
        var low: CGFloat
        /// Scales band spacing, crest height and crest length.
        var scale: CGFloat = 1
        var swell: CGFloat = 0
        var riseStart: CGFloat = 470
        var riseEnd: CGFloat = 760

        func top(_ index: Int, _ x: CGFloat) -> CGFloat {
            let last = UrashimaArt.bandSpecs.count - 1
            let i = min(max(index, 0), last)
            let spec = UrashimaArt.bandSpecs[i]
            var rise: CGFloat = 0
            let span = riseEnd - riseStart
            if swell != 0, span > 0, i < UrashimaArt.swellShare.count {
                let share: CGFloat = UrashimaArt.swellShare[i]
                rise = swell * share * UrashimaArt.smooth((x - riseStart) / span)
            }
            return low + spec.offset * scale - rise
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
        let depth = gap + 10
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
            let tint = texture == 1 ? Art.color(0xFFFFFF, 0.2) : Art.color(0x9CC8EE, 0.19)
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
                Art.stroke(&g, arcPath, tint, width: ArtStyle.detailLine * max(detail, 0.6))
            }
        }

        // The crest line is the story's signature: always pale, always the contour weight.
        Art.stroke(&context, crest, foam.opacity(foamOpacity), width: ArtStyle.contourLine * max(detail, 0.6))

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

    /// The veil over the leading pane of an unfolded sea scene, so that the sea can run under
    /// the words as one place and stay calm: a side-to-side haze that is gone before the
    /// trailing pane's picture, and a second veil that is strongest on the horizon (the far
    /// bands and the far shore stay close to the sky's value) and gone by the near bands
    /// (the bottom third keeps its stronger forms).
    static func leadingMist(
        _ context: inout GraphicsContext,
        _ w: CGFloat,
        _ h: CGFloat,
        _ tint: Color,
        horizon: CGFloat,
        s: CGFloat
    ) {
        let side: [(Color, CGFloat)] = [
            (tint.opacity(0.42), 0), (tint.opacity(0.28), 0.3), (tint.opacity(0), 0.6), (tint.opacity(0), 1),
        ]
        Art.fillLinear(&context, Art.rect(0, 0, w, h), side, from: pt(0, 0), to: pt(w, 0))

        let top: CGFloat = horizon - 40 * s
        let bottom: CGFloat = horizon + 150 * s
        let band = Art.rect(0, top, w, bottom - top)
        let maskStops: [(Color, CGFloat)] = [
            (Color.white.opacity(0), 0), (Color.white, 0.21), (Color.white.opacity(0.8), 0.45), (Color.white.opacity(0), 1),
        ]
        let across: [(Color, CGFloat)] = [
            (tint.opacity(0.5), 0), (tint.opacity(0.4), 0.35), (tint.opacity(0), 0.62), (tint.opacity(0), 1),
        ]
        var veil = context
        veil.clipToLayer { mask in
            Art.fillLinear(&mask, band, maskStops, from: CGPoint(x: 0, y: top), to: CGPoint(x: 0, y: bottom))
        }
        Art.fillLinear(&veil, band, across, from: pt(0, 0), to: pt(w, 0))
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
            Art.fill(&context, Art.rect(cx - 100 * k, cy - 12 * k, 192 * k, 4 * k, radius: 2 * k), haze.opacity(0.7))
            Art.fill(&context, Art.rect(cx - 70 * k, cy + 4 * k, 162 * k, 3 * k, radius: 1.5 * k), haze.opacity(0.6))
            Art.fill(&context, Art.rect(cx - 60 * k, cy - 26 * k, 130 * k, 3 * k, radius: 1.5 * k), haze.opacity(0.5))
        }
    }

    /// The pale sun of the changed shore: warm rather than white, no strips.
    static func paleSun(_ context: inout GraphicsContext, _ cx: CGFloat, _ cy: CGFloat, _ r: CGFloat) {
        Art.glow(&context, cx, cy, r * 3.8, Art.color(0xFFE9DC), alpha: 0.8)
        Art.fill(&context, Art.circle(cx, cy, r), Art.color(0xFFF3E6, 0.92))
    }

    // MARK: - Far shore, pines, gulls, houses

    /// A far headland sitting on the line `base`: one asymmetric rise between `x0` and `x1`,
    /// `rise` units high, its summit `peak` of the way along.
    static func headland(_ x0: CGFloat, _ x1: CGFloat, _ base: CGFloat, _ rise: CGFloat, peak: CGFloat = 0.4) -> Path {
        let span: CGFloat = x1 - x0
        let px: CGFloat = x0 + span * peak
        let after: CGFloat = x1 - px
        var land = Path()
        land.move(to: pt(x0, base + 2))
        land.addCurve(
            to: pt(px, base - rise),
            control1: pt(x0 + span * peak * 0.35, base - rise * 0.35),
            control2: pt(x0 + span * peak * 0.6, base - rise * 1.05)
        )
        land.addCurve(
            to: pt(x1, base + 2),
            control1: pt(px + after * 0.35, base - rise * 0.95),
            control2: pt(px + after * 0.6, base - rise * 0.18)
        )
        land.closeSubpath()
        return land
    }

    /// A woodblock pine: a tapered, bent trunk under flat cloud-shaped pads of needles with a
    /// broken upper edge, lit from the upper left. (x, y) is the foot of the trunk; the tree is
    /// about 56 × `s` units tall. `lean` tips it (negative leans left), `clumps` below 5 leaves
    /// bare branches, `snow` caps the pads, `lit` is the strength of the warm light on them.
    static func pine(
        _ context: inout GraphicsContext,
        _ x: CGFloat,
        _ y: CGFloat,
        _ s: CGFloat,
        _ color: Color,
        trunk: Color? = nil,
        lean: CGFloat = 0,
        clumps: Int = 5,
        snow: Bool = false,
        lit: Double = 0.22
    ) {
        let trunkColor = trunk ?? color
        let topX: CGFloat = x + (lean * 46 - 2) * s
        let topY: CGFloat = y - 46 * s
        let bendX: CGFloat = x + (lean * 20 + 4) * s
        let bendY: CGFloat = y - 22 * s
        var stem = Path()
        stem.move(to: pt(x - 2.4 * s, y))
        stem.addQuadCurve(to: pt(topX - 0.7 * s, topY), control: pt(bendX - 1.6 * s, bendY))
        stem.addLine(to: pt(topX + 0.7 * s, topY))
        stem.addQuadCurve(to: pt(x + 2.6 * s, y), control: pt(bendX + 1.6 * s, bendY))
        stem.closeSubpath()
        Art.fill(&context, stem, trunkColor)

        let pads: [(CGFloat, CGFloat, CGFloat)] = [(-12, -34, 17), (8, -42, 15), (-2, -50, 13), (-19, -24, 11), (13, -27, 11)]
        var foliage = Path()
        var glints = Path()
        var caps = Path()
        var twigs = Path()
        for (index, pad) in pads.enumerated() {
            let slant: CGFloat = -lean * pad.1
            let cx: CGFloat = x + (pad.0 + slant) * s
            let cy: CGFloat = y + pad.1 * s
            let r: CGFloat = pad.2 * s
            twigs.move(to: pt(x + slant * s, cy + 6 * s))
            twigs.addLine(to: pt(cx, cy))
            if index < clumps {
                foliage.addEllipse(in: CGRect(x: cx - r, y: cy - r * 0.34, width: r * 2, height: r * 0.68))
                foliage.addEllipse(in: CGRect(x: cx - r * 0.78, y: cy - r * 0.52, width: r * 0.8, height: r * 0.56))
                foliage.addEllipse(in: CGRect(x: cx - r * 0.1, y: cy - r * 0.58, width: r * 0.9, height: r * 0.6))
                glints.addEllipse(in: CGRect(x: cx - r * 0.7, y: cy - r * 0.46, width: r * 0.95, height: r * 0.26))
                caps.addEllipse(in: CGRect(x: cx - r * 0.8, y: cy - r * 0.58, width: r * 1.6, height: r * 0.36))
            }
        }
        Art.stroke(&context, twigs, trunkColor, width: 1.2 * s)
        Art.fill(&context, foliage, color)
        if lit > 0 {
            Art.fill(&context, glints, ArtStyle.warmLight.opacity(lit))
        }
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
        Art.stroke(&context, wings, color, width: ArtStyle.detailLine * max(s, 0.5))
    }

    /// A very small far house under a roof with turned-up eaves; `tiers: 2` adds an upper storey.
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
            Art.fill(&g, Art.svg("M-13,-5 C-9,-7 -7,-11 -6,-15 L6,-15 C7,-11 9,-7 13,-5 L12,-4 L-12,-4Z"), roof)
            if tiers > 1 {
                Art.fill(&g, Art.rect(-5, -21, 10, 7), wall)
                Art.fill(&g, Art.svg("M-10,-19 C-7,-21 -5,-24 -4,-27 L4,-27 C5,-24 7,-21 10,-19 L9,-18 L-9,-18Z"), roof)
            }
        }
    }

    /// A far sail. (x, y) is the stern at the waterline; `k` scales it.
    static func farSail(_ context: inout GraphicsContext, _ x: CGFloat, _ y: CGFloat, k: CGFloat = 1, alpha: Double = 0.85) {
        var hull = Path()
        hull.move(to: pt(x, y))
        hull.addLine(to: pt(x - 20 * k, y))
        hull.addQuadCurve(to: pt(x, y + 5 * k), control: pt(x - 12 * k, y + 7 * k))
        hull.closeSubpath()
        Art.fill(&context, hull, Art.color(0x6A7C92, alpha))
        var sail = Path()
        sail.move(to: pt(x - 10 * k, y - 1 * k))
        sail.addLine(to: pt(x - 10 * k, y - 18 * k))
        sail.addQuadCurve(to: pt(x, y - 4 * k), control: pt(x - 2 * k, y - 13 * k))
        sail.closeSubpath()
        Art.fill(&context, sail, Art.color(0xFFFFFF, alpha))
    }

    /// A rounded shore rock, lit from the upper left. (x, y) is the middle of its foot.
    static func rock(_ context: inout GraphicsContext, _ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat, _ color: Color) {
        let half: CGFloat = width / 2
        var shape = Path()
        shape.move(to: pt(x - half, y))
        shape.addCurve(
            to: pt(x - half * 0.1, y - height * 0.96),
            control1: pt(x - half, y - height * 0.6),
            control2: pt(x - half * 0.6, y - height)
        )
        shape.addCurve(
            to: pt(x + half, y),
            control1: pt(x + half * 0.42, y - height * 1.04),
            control2: pt(x + half * 0.92, y - height * 0.5)
        )
        shape.closeSubpath()
        Art.fill(&context, shape, color)
        ArtStyle.form(&context, shape, bounds: CGRect(x: x - half, y: y - height, width: width, height: height), light: 0.3, shade: 0.24)
    }
}
