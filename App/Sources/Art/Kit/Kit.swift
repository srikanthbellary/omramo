import SwiftUI
import OmramoCore

// The shared illustration kit (round 5).
//
// Rounds 2–4 drew three stories with three bespoke sets of helpers. The catalog is 32 stories,
// so round 5 adds this kit: the parts every story needs — a frame for each picture shape, sky
// and light, land and water, a way to model any shape with the one light — written once, on
// top of `Art` and `ArtStyle`. A story's painter composes its scenes from the kit and draws
// its own heroes and its own region-true details (docs/ART_DIRECTION.md §11, and
// docs/agent-runs/r5-batch-notes.md for the conventions).
//
// This file: small tools, the frames (`Stage`, `Band`, `CoverFrame`), light, sky, land, water
// and the "solid" helper. People are in `Kit+People.swift`, animals in `Kit+Creatures.swift`,
// plants in `Kit+Flora.swift`, buildings and objects in `Kit+Built.swift`.
//
// Like every painter, the kit draws in the units of the picture's role (`ArtRole`) and is
// deterministic (seeded `ArtRandom` only).

enum Kit {
    /// Gradient stops: (colour, location 0…1).
    typealias Stops = [(Color, CGFloat)]
    /// A round clump (of leaves, of cloud, of snow): centre x, centre y, radius.
    typealias Blob = (CGFloat, CGFloat, CGFloat)

    // MARK: Small tools

    /// The next random value as a `CGFloat` in 0..<1.
    static func rnd(_ random: inout ArtRandom) -> CGFloat {
        CGFloat(random.next())
    }

    /// Degrees to radians.
    static func deg(_ degrees: CGFloat) -> CGFloat {
        degrees * CGFloat.pi / 180
    }

    static func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        CGPoint(x: x, y: y)
    }

    static func clamp(_ value: CGFloat, _ low: CGFloat, _ high: CGFloat) -> CGFloat {
        min(high, max(low, value))
    }

    /// `a` at t = 0, `b` at t = 1.
    static func mix(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat {
        a + (b - a) * t
    }

    /// SVG path data drawn around the origin, then scaled and moved to (x, y).
    static func placed(_ data: String, x: CGFloat, y: CGFloat, scale: CGFloat = 1) -> Path {
        let transform = CGAffineTransform(translationX: x, y: y).scaledBy(x: scale, y: scale)
        return Art.svg(data).applying(transform)
    }

    /// Two-stop vertical gradient stops, top colour to bottom colour.
    static func stops(_ top: UInt32, _ bottom: UInt32) -> Stops {
        [(Art.color(top), 0), (Art.color(bottom), 1)]
    }

    /// Three-stop gradient stops.
    static func stops(_ top: UInt32, _ middle: UInt32, _ bottom: UInt32) -> Stops {
        [(Art.color(top), 0), (Art.color(middle), 0.5), (Art.color(bottom), 1)]
    }
}

// MARK: - Frames: one per picture shape (ART_DIRECTION §5a)

extension Kit {
    /// The numbers an unfolded scene (892 wide, about 400…1300 high) derives from its height.
    ///
    /// - 560…720 high: the scene as designed; the sky stretches.
    /// - Taller (an iPad in portrait): `tall` runs 0…1 and `grow` 1…1.35; the horizon rises to
    ///   about 70% of the height, and the near plane and the subject grow by `grow`.
    /// - Shorter than 560 (a phone held sideways): `fit` falls below 1 and the trailing
    ///   ensemble is drawn smaller about the top trailing corner (`designSpace`).
    struct Stage {
        let w: CGFloat
        let h: CGFloat
        /// 0 on the designed shapes, 1 on the tallest portrait window.
        let tall: CGFloat
        /// 1…1.35: how much the near plane and the subject grow on a tall window.
        let grow: CGFloat
        /// 0.6…1: how much the trailing ensemble shrinks on a squat window.
        let fit: CGFloat
        /// The horizon line, in the picture's own units.
        let H: CGFloat
        /// From the horizon to the bottom edge.
        let depth: CGFloat
        /// How much deeper the ground or water is than designed, in design units.
        let extra: CGFloat
        /// The scale of the far plane (hills, sun, far trees).
        let far: CGFloat

        /// The height in design units (inside `designSpace`).
        var hv: CGFloat { h / fit }
        /// The horizon in design units (inside `designSpace`).
        var Hv: CGFloat { H / fit }
        var size: CGSize { CGSize(width: w, height: h) }
    }

    /// `ground` is the designed depth of the ground or water under the horizon at the
    /// reference height (720): 136 puts the horizon at 584.
    static func stage(_ size: CGSize, ground: CGFloat) -> Stage {
        let h = size.height
        let tall: CGFloat = max(0, min(1, (h - 720) / 470))
        let grow: CGFloat = 1 + 0.35 * tall
        let fit: CGFloat = max(0.6, min(1, h / 560))
        let wanted: CGFloat = max(0, h * 0.30 - ground)
        let deep: CGFloat = ground * fit + tall * wanted
        let horizon: CGFloat = (h - deep).rounded()
        let depth: CGFloat = h - horizon
        let extra: CGFloat = max(0, depth / fit - ground)
        let far: CGFloat = fit * (1 + 0.35 * tall)
        return Stage(w: size.width, h: h, tall: tall, grow: grow, fit: fit, H: horizon, depth: depth, extra: extra, far: far)
    }

    /// Draws `body` in the units of the designed composition (892 wide, horizon at
    /// `stage.Hv`, height `stage.hv`): on a squat window everything inside shrinks about the
    /// top trailing corner, so the trailing ensemble keeps its distances. On the designed
    /// shapes and on tall windows it is the identity.
    static func designSpace(_ context: inout GraphicsContext, _ stage: Stage, _ body: (inout GraphicsContext) -> Void) {
        Art.group(&context, x: 892 * (1 - stage.fit), y: 0, scale: stage.fit, body)
    }

    /// Inside `designSpace`: draws `body` grown by `stage.grow` about the point
    /// (`anchorX`, horizon), so the near plane and the subject get bigger on a tall window
    /// while they keep standing on the horizon. Use `anchorX` 892 for things on the trailing
    /// edge and the subject's own x for a subject in the middle of the trailing pane.
    static func nearSpace(
        _ context: inout GraphicsContext,
        _ stage: Stage,
        anchorX: CGFloat = 892,
        _ body: (inout GraphicsContext) -> Void
    ) {
        Art.group(&context, x: anchorX * (1 - stage.grow), y: stage.Hv * (1 - stage.grow), scale: stage.grow, body)
    }

    /// The numbers a folded band (432 wide, about 240…520 high) derives from its height.
    struct Band {
        let w: CGFloat
        let h: CGFloat
        /// 0.6…1.15: the size of the subject against the reference band (420 high).
        let unit: CGFloat
        /// The horizon line.
        let H: CGFloat
        /// The depth of the ground or water; the bottom 30 units are cut by the wave edge.
        let ground: CGFloat

        var size: CGSize { CGSize(width: w, height: h) }
        /// The lowest y anything important may reach (above the wave edge).
        var floor: CGFloat { h - 30 }
    }

    /// `share` is the part of the height given to the ground or water; it is kept between
    /// `least` and `most` units.
    static func band(_ size: CGSize, share: CGFloat, least: CGFloat, most: CGFloat) -> Band {
        let h = size.height
        let unit: CGFloat = max(0.6, min(1.15, h / 420))
        let ground: CGFloat = max(least, min(most, h * share))
        let horizon: CGFloat = (h - ground).rounded()
        return Band(w: size.width, h: h, unit: unit, H: horizon, ground: h - horizon)
    }

    /// Draws `body` in the 892-wide units of an unfolded painter, scaled by `k` and hung on
    /// the band's trailing edge: x 892 lands on x 432, and y 0 stays at the top.
    static func hung(_ context: inout GraphicsContext, scale k: CGFloat, _ body: (inout GraphicsContext) -> Void) {
        Art.group(&context, x: 432 - 892 * k, y: 0, scale: k, body)
    }

    /// The numbers a cover derives from its shape. A cover is drawn in units 240 wide (the
    /// design's cover width); its height `hd` runs from about 120 (the wide "Keep reading"
    /// card) to 300 (a tall cover).
    struct CoverFrame {
        /// Height in cover units.
        let hd: CGFloat
        /// The horizon line: a little below the middle, lower on a tall cover.
        let H: CGFloat
        /// 0.55…1: the size of the subject (smaller on the wide card).
        let k: CGFloat
        /// Always 240.
        let w: CGFloat
    }

    /// Draws a cover in cover units (240 wide) and adds the finish. The subject belongs around
    /// (120, `frame.H`), at scale `frame.k`, so the wide crop and the tall crop both hold it.
    static func cover(
        _ context: inout GraphicsContext,
        _ size: CGSize,
        wash: Double = 0.10,
        vignette: Double = 0.10,
        _ body: (inout GraphicsContext, CoverFrame) -> Void
    ) {
        guard size.width > 0, size.height > 0 else { return }
        let u: CGFloat = size.width / 240
        let hd: CGFloat = size.height / u
        let lift: CGFloat = max(0, hd - 150) * 0.24
        let horizon: CGFloat = (hd * 0.5 + 14 + lift).rounded()
        let k: CGFloat = min(1, max(0.55, hd / 210))
        let frame = CoverFrame(hd: hd, H: horizon, k: k, w: 240)
        Art.group(&context, scale: u) { g in
            body(&g, frame)
        }
        ArtStyle.finish(&context, size, wash: wash, vignette: vignette)
    }

    /// A face chip (100 × 100 units, clipped to a circle by the caller): fills the chip with
    /// `background` and draws `body` with the origin at the chip's centre, in chip units. A
    /// head of radius about 38 fills the chip as ART_DIRECTION §7 asks.
    static func faceChip(
        _ context: inout GraphicsContext,
        _ size: CGSize,
        background: UInt32,
        _ body: (inout GraphicsContext) -> Void
    ) {
        let w = size.width
        let h = size.height
        Art.fill(&context, Art.rect(0, 0, w, h), Art.color(background))
        Art.glow(&context, w * 0.34, h * 0.28, w * 0.6, Color.white, alpha: 0.22)
        Art.group(&context, x: w / 2, y: h / 2, scale: w / 100, body)
    }

    /// A character-card portrait (432 × 400): the shared backdrop (the card's own colours and a
    /// halo; rays for the Low tier only), then `body`, then the finish. The head belongs with
    /// its top near y 60 and the eyes near y 135; the figure is cut at the waist by the frame.
    static func portrait(
        _ context: inout GraphicsContext,
        _ size: CGSize,
        top: UInt32,
        bottom: UInt32,
        halo: UInt32,
        rays: Bool,
        _ body: (inout GraphicsContext) -> Void
    ) {
        ArtStyle.portraitBackdrop(
            &context,
            size,
            top: Art.color(top),
            bottom: Art.color(bottom),
            halo: Art.color(halo),
            rays: rays
        )
        ArtStyle.tooth(&context, in: CGRect(x: 0, y: 0, width: size.width, height: size.height), seed: 33, alpha: 0.05)
        body(&context)
        ArtStyle.finish(&context, size)
    }

    /// The last pass of a tap-to-see picture (432 × 404): the bottom sinks into the card's own
    /// colour, then tooth and the finish. Call it last.
    static func sink(_ context: inout GraphicsContext, _ size: CGSize, card: UInt32, from top: CGFloat = 284) {
        let w = size.width
        let h = size.height
        let color = Art.color(card)
        let fade: Stops = [(color.opacity(0), 0), (color.opacity(0.9), 1)]
        Art.fillLinear(&context, Art.rect(0, top, w, h - top), fade, from: CGPoint(x: 0, y: top), to: CGPoint(x: 0, y: h))
        ArtStyle.tooth(&context, in: CGRect(x: 0, y: 0, width: w, height: h), seed: 5, alpha: 0.05)
        ArtStyle.finish(&context, size)
    }
}

// MARK: - Light

extension Kit {
    /// The light of one scene: its sky, its sun, the colour of its air and its three planes.
    /// A story keeps one or two of these (a day and an evening, say) and every scene, cover and
    /// picture of the story uses them, so the story has one light.
    struct Light {
        /// The sky from the top of the picture down to the horizon. At most four stops; the
        /// last one is the story ramp's warm `glow`.
        var sky: Stops
        /// The disc of the sun or the moon.
        var sun: Color
        /// The warm band at the horizon and the halo round the sun.
        var glow: Color
        /// The colour of the air: the veil over the far plane (usually the sky near the horizon).
        var haze: Color
        /// The farthest range, the middle range and the near range (or far shore).
        var far: Color
        var mid: Color
        var near: Color
        /// True for a night or deep-dusk scene: stars may be drawn and the finish uses less wash.
        var isNight: Bool

        init(sky: Stops, sun: UInt32, glow: UInt32, haze: UInt32, far: UInt32, mid: UInt32, near: UInt32, isNight: Bool = false) {
            self.sky = sky
            self.sun = Art.color(sun)
            self.glow = Art.color(glow)
            self.haze = Art.color(haze)
            self.far = Art.color(far)
            self.mid = Art.color(mid)
            self.near = Art.color(near)
            self.isNight = isNight
        }
    }

    /// The sky down to the horizon `H`, with the shared warm band on the horizon. Fills the
    /// whole picture (what lies under the horizon is painted over by land or water).
    static func sky(_ context: inout GraphicsContext, _ size: CGSize, horizon H: CGFloat, light: Light) {
        let w = size.width
        let h = size.height
        Art.fillLinear(&context, Art.rect(0, 0, w, h), light.sky, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: max(1, H)))
        let rise: CGFloat = min(150, max(36, H * 0.3))
        ArtStyle.horizonGlow(&context, width: w, y: H, rise: rise, color: light.glow, alpha: light.isNight ? 0.4 : 0.5)
        let top: CGFloat = max(0, H - 170)
        ArtStyle.tooth(&context, in: CGRect(x: 0, y: top, width: w, height: H - top), seed: 78, alpha: 0.05)
    }

    /// The sun: a plain disc with one soft halo. No rays.
    static func sun(_ context: inout GraphicsContext, _ x: CGFloat, _ y: CGFloat, _ r: CGFloat, light: Light) {
        let reach: CGFloat = r * 4.5
        let halo: Stops = [(light.glow.opacity(0.9), 0), (light.glow.opacity(0.4), 0.45), (light.glow.opacity(0), 1)]
        Art.fillRadial(&context, Art.circle(x, y, reach), halo, center: CGPoint(x: x, y: y), radius: reach)
        Art.fill(&context, Art.circle(x, y, r), light.sun)
    }

    /// The moon: a disc with a halo, two quiet marks and, if `crescent` is above 0, the dark
    /// part of a crescent in `shade` (0.35 is a fat crescent, 0.7 a thin one).
    static func moon(
        _ context: inout GraphicsContext,
        _ x: CGFloat,
        _ y: CGFloat,
        _ r: CGFloat,
        color: Color = Art.color(0xFFF1C4),
        crescent: CGFloat = 0,
        shade: Color = Art.color(0x1A1147)
    ) {
        Art.glow(&context, x, y, r * 3.6, color, alpha: 0.35)
        let disc = Art.circle(x, y, r)
        Art.fill(&context, disc, color)
        if crescent > 0 {
            Art.clipped(&context, to: disc) { g in
                Art.fill(&g, Art.circle(x + r * (1.6 - crescent), y - r * 0.12, r * 1.08), shade)
            }
        } else {
            Art.fill(&context, Art.circle(x - r * 0.3, y - r * 0.28, r * 0.2), Art.color(0xE8D49A, 0.45))
            Art.fill(&context, Art.circle(x + r * 0.34, y + r * 0.3, r * 0.26), Art.color(0xE8D49A, 0.35))
            ArtStyle.rimLight(&context, x, y, r, alpha: 0.3)
        }
    }

    /// Small stars over the sky, thickest at the top and thinning toward `maxY`.
    static func stars(
        _ context: inout GraphicsContext,
        width w: CGFloat,
        maxY: CGFloat,
        count: Int,
        seed: UInt32,
        color: Color = Art.color(0xFFF6DC)
    ) {
        var random = ArtRandom(seed)
        var dim = Path()
        var bright = Path()
        for index in 0..<max(0, count) {
            let x: CGFloat = w * rnd(&random)
            let fall: CGFloat = rnd(&random)
            let y: CGFloat = 6 + max(0, maxY - 6) * fall * fall
            let r: CGFloat = 0.5 + rnd(&random) * 0.9
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

    /// A soft cloud with a flat base: five overlapping puffs, lit from the upper left.
    /// About 120 units wide at scale 1; (x, y) is the middle of its base.
    static func cloud(_ context: inout GraphicsContext, _ x: CGFloat, _ y: CGFloat, scale: CGFloat, color: Color) {
        Art.group(&context, x: x, y: y, scale: scale) { g in
            var puff = Path()
            puff.addEllipse(in: CGRect(x: -60, y: -18, width: 50, height: 22))
            puff.addEllipse(in: CGRect(x: -38, y: -34, width: 46, height: 38))
            puff.addEllipse(in: CGRect(x: -8, y: -42, width: 50, height: 46))
            puff.addEllipse(in: CGRect(x: 22, y: -28, width: 40, height: 32))
            puff.addPath(Art.rect(-50, -12, 100, 12, radius: 6))
            Art.fill(&g, puff, color)
            Art.clipped(&g, to: puff) { lit in
                Art.glow(&lit, -24, -36, 46, Color.white, alpha: 0.35)
                Art.fill(&lit, Art.rect(-60, -5, 124, 8), ArtStyle.coolShade.opacity(0.06))
            }
        }
    }

    /// Three far birds on the wing, the first at (x, y).
    static func birds(_ context: inout GraphicsContext, _ x: CGFloat, _ y: CGFloat, scale: CGFloat = 1, color: Color) {
        let places: [(CGFloat, CGFloat, CGFloat)] = [(0, 0, 1), (26, -12, 0.8), (50, 4, 0.7)]
        var wings = Path()
        for place in places {
            let s: CGFloat = place.2 * scale
            let bx: CGFloat = x + place.0 * scale
            let by: CGFloat = y + place.1 * scale
            wings.move(to: CGPoint(x: bx - 9 * s, y: by))
            wings.addQuadCurve(to: CGPoint(x: bx, y: by + 1.5 * s), control: CGPoint(x: bx - 4.5 * s, y: by - 6 * s))
            wings.addQuadCurve(to: CGPoint(x: bx + 9 * s, y: by), control: CGPoint(x: bx + 4.5 * s, y: by - 6 * s))
        }
        Art.stroke(&context, wings, color, width: ArtStyle.detailLine)
    }
}

// MARK: - Land

extension Kit {
    /// A soft rolling skyline from `x0` across `w` around height `y`, filled down to `bottom`.
    static func ridge(
        width w: CGFloat,
        y: CGFloat,
        amp: CGFloat,
        seed: UInt32,
        bottom: CGFloat,
        step: CGFloat = 8,
        x0: CGFloat = 0
    ) -> Path {
        var random = ArtRandom(seed)
        let p1: CGFloat = rnd(&random) * 6
        let p2: CGFloat = rnd(&random) * 6
        let p3: CGFloat = rnd(&random) * 6
        var path = Path()
        path.move(to: CGPoint(x: x0, y: bottom))
        path.addLine(to: CGPoint(x: x0, y: y))
        let advance: CGFloat = max(1, step)
        var x: CGFloat = x0
        var lastY: CGFloat = y
        while x <= x0 + w {
            let a: CGFloat = 0.5 * sin(x / 97 + p1)
            let b: CGFloat = 0.32 * sin(x / 41 + p2)
            let c: CGFloat = 0.18 * sin(x / 17 + p3)
            lastY = y - amp * (a + b + c)
            path.addLine(to: CGPoint(x: x, y: lastY))
            x += advance
        }
        path.addLine(to: CGPoint(x: x0 + w, y: lastY))
        path.addLine(to: CGPoint(x: x0 + w, y: bottom))
        path.closeSubpath()
        return path
    }

    /// A far mountain range: a skyline of peaks of about `amp` units above `y`, filled down to
    /// `bottom`. `sharp` 0 gives rounded old mountains, 1 gives pointed ones.
    static func peaks(
        width w: CGFloat,
        y: CGFloat,
        amp: CGFloat,
        seed: UInt32,
        bottom: CGFloat,
        sharp: CGFloat = 0.6,
        x0: CGFloat = 0
    ) -> Path {
        var random = ArtRandom(seed)
        var path = Path()
        path.move(to: CGPoint(x: x0, y: bottom))
        var x: CGFloat = x0 - 20
        var valley: CGFloat = y - amp * 0.15 * rnd(&random)
        path.addLine(to: CGPoint(x: x, y: valley))
        while x < x0 + w + 20 {
            let run: CGFloat = max(24, amp * (0.9 + rnd(&random) * 1.1))
            let top: CGFloat = y - amp * (0.55 + rnd(&random) * 0.45)
            let peakX: CGFloat = x + run * (0.4 + rnd(&random) * 0.2)
            let nextValley: CGFloat = y - amp * 0.2 * rnd(&random)
            let pull: CGFloat = run * 0.22 * (1 - sharp)
            path.addQuadCurve(to: CGPoint(x: peakX, y: top), control: CGPoint(x: peakX - pull - run * 0.08, y: mix(valley, top, 0.75)))
            path.addQuadCurve(to: CGPoint(x: x + run, y: nextValley), control: CGPoint(x: peakX + pull + run * 0.08, y: mix(nextValley, top, 0.75)))
            valley = nextValley
            x += run
        }
        path.addLine(to: CGPoint(x: x0 + w, y: bottom))
        path.closeSubpath()
        return path
    }

    /// The far plane of most outdoor scenes: a pale farthest range, a far range, a veil of
    /// air, and a middle range whose crest catches the light. `scale` is the stage's `far`.
    /// `mountains` draws peaks instead of rolling hills for the two far ranges.
    static func ranges(
        _ context: inout GraphicsContext,
        width w: CGFloat,
        horizon H: CGFloat,
        scale: CGFloat,
        light: Light,
        mountains: Bool = false,
        seed: UInt32 = 4
    ) {
        let s = scale
        let farthest: Path
        let far: Path
        if mountains {
            farthest = peaks(width: w, y: H - 30 * s, amp: 92 * s, seed: seed &+ 19, bottom: H + 8, sharp: 0.7)
            far = peaks(width: w, y: H - 14 * s, amp: 58 * s, seed: seed, bottom: H + 8, sharp: 0.5)
        } else {
            farthest = ridge(width: w, y: H - 38 * s, amp: 30 * s, seed: seed &+ 19, bottom: H + 8, step: 10)
            far = ridge(width: w, y: H - 22 * s, amp: 26 * s, seed: seed, bottom: H + 8)
        }
        Art.fill(&context, farthest, light.far.opacity(0.55))
        Art.fill(&context, far, light.far)
        let veilTop: CGFloat = H - (mountains ? 130 : 84) * s
        ArtStyle.atmosphere(&context, width: w, top: veilTop, bottom: H + 8, color: light.haze, alpha: 0.3)
        let middle = ridge(width: w, y: H - 8 * s, amp: 16 * s, seed: seed &+ 5, bottom: H + 8)
        Art.fill(&context, middle, light.mid)
        let crest: Stops = [(light.glow.opacity(0.28), 0), (light.glow.opacity(0), 1)]
        Art.clipped(&context, to: middle) { lit in
            Art.fillLinear(
                &lit,
                Art.rect(0, H - 26 * s, w, 22 * s),
                crest,
                from: CGPoint(x: 0, y: H - 26 * s),
                to: CGPoint(x: 0, y: H - 4 * s)
            )
        }
    }

    /// One mountain standing on `baseY`: a lit left face, a shaded right face and, if asked, a
    /// snow cap. For a hero peak (the Taihang range, a volcano); far ranges use `peaks`.
    static func mountain(
        _ context: inout GraphicsContext,
        cx: CGFloat,
        baseY: CGFloat,
        width: CGFloat,
        height: CGFloat,
        color: Color,
        snow: Color? = nil,
        seed: UInt32 = 3
    ) {
        var random = ArtRandom(seed)
        let half: CGFloat = width / 2
        let topX: CGFloat = cx + (rnd(&random) - 0.5) * width * 0.12
        let topY: CGFloat = baseY - height
        let shoulderL = CGPoint(x: cx - half * 0.52, y: baseY - height * (0.42 + rnd(&random) * 0.1))
        let shoulderR = CGPoint(x: cx + half * 0.5, y: baseY - height * (0.36 + rnd(&random) * 0.12))
        var shape = Path()
        shape.move(to: CGPoint(x: cx - half, y: baseY))
        shape.addQuadCurve(to: shoulderL, control: CGPoint(x: cx - half * 0.8, y: baseY - height * 0.16))
        shape.addQuadCurve(to: CGPoint(x: topX, y: topY), control: CGPoint(x: cx - half * 0.2, y: baseY - height * 0.86))
        shape.addQuadCurve(to: shoulderR, control: CGPoint(x: cx + half * 0.2, y: baseY - height * 0.82))
        shape.addQuadCurve(to: CGPoint(x: cx + half, y: baseY), control: CGPoint(x: cx + half * 0.82, y: baseY - height * 0.12))
        shape.closeSubpath()
        Art.fill(&context, shape, color)
        let bounds = CGRect(x: cx - half, y: topY, width: width, height: height)
        Art.clipped(&context, to: shape) { g in
            // The shaded right face: everything to the right of a ridge line from the top.
            var face = Path()
            face.move(to: CGPoint(x: topX, y: topY))
            face.addQuadCurve(to: CGPoint(x: cx + half * 0.18, y: baseY), control: CGPoint(x: topX + half * 0.3, y: baseY - height * 0.45))
            face.addLine(to: CGPoint(x: cx + half, y: baseY))
            face.addLine(to: CGPoint(x: cx + half, y: topY))
            face.closeSubpath()
            Art.fill(&g, face, ArtStyle.coolShade.opacity(0.2))
            ArtStyle.tooth(&g, in: bounds, seed: seed &+ 40, color: Color.white, alpha: 0.06)
            if let snow {
                var cap = Path()
                let capY: CGFloat = topY + height * 0.3
                cap.move(to: CGPoint(x: cx - half, y: topY - 4))
                cap.addLine(to: CGPoint(x: cx + half, y: topY - 4))
                cap.addLine(to: CGPoint(x: cx + half, y: capY))
                var x: CGFloat = cx + half
                var down = true
                while x > cx - half {
                    let stepX: CGFloat = width * (0.05 + rnd(&random) * 0.05)
                    let y: CGFloat = capY + (down ? height * 0.07 : -height * 0.05)
                    cap.addLine(to: CGPoint(x: x - stepX, y: y))
                    x -= stepX
                    down.toggle()
                }
                cap.closeSubpath()
                Art.fill(&g, cap, snow)
                Art.fill(&g, face, ArtStyle.coolShade.opacity(0.1))
            }
        }
        ArtStyle.rimEdge(&context, shape, bounds: bounds, width: 2.4, alpha: 0.4)
    }

    /// Flat land from `top` down to `bottom`: a vertical gradient, a thin darker line where it
    /// meets the far plane, and tooth.
    static func ground(
        _ context: inout GraphicsContext,
        width w: CGFloat,
        top: CGFloat,
        bottom: CGFloat,
        stops: Stops,
        seed: UInt32 = 77,
        tooth: Color = Color.white
    ) {
        let depth: CGFloat = max(1, bottom - top)
        Art.fillLinear(&context, Art.rect(0, top, w, depth), stops, from: CGPoint(x: 0, y: top), to: CGPoint(x: 0, y: bottom))
        Art.fill(&context, Art.rect(0, top, w, 5), ArtStyle.coolShade.opacity(0.08))
        ArtStyle.tooth(&context, in: CGRect(x: 0, y: top + 6, width: w, height: depth), seed: seed, color: tooth, alpha: 0.07)
    }

    /// A rise of land in the foreground or middle ground: a soft mound from `x0` to `x1`
    /// whose crest is `height` above `baseY`, filled down to `bottom`, modelled by the light.
    static func mound(
        _ context: inout GraphicsContext,
        x0: CGFloat,
        x1: CGFloat,
        baseY: CGFloat,
        height: CGFloat,
        bottom: CGFloat,
        stops: Stops,
        crest: CGFloat = 0.5
    ) {
        let span: CGFloat = x1 - x0
        guard span > 0 else { return }
        var shape = Path()
        shape.move(to: CGPoint(x: x0, y: bottom))
        shape.addLine(to: CGPoint(x: x0, y: baseY))
        let peak = CGPoint(x: x0 + span * crest, y: baseY - height)
        shape.addQuadCurve(to: peak, control: CGPoint(x: x0 + span * crest * 0.5, y: baseY - height * 1.05))
        shape.addQuadCurve(to: CGPoint(x: x1, y: baseY), control: CGPoint(x: x0 + span * (crest + (1 - crest) * 0.5), y: baseY - height * 1.05))
        shape.addLine(to: CGPoint(x: x1, y: bottom))
        shape.closeSubpath()
        let topY: CGFloat = baseY - height * 1.05
        Art.fillLinear(&context, shape, stops, from: CGPoint(x: 0, y: topY), to: CGPoint(x: 0, y: bottom))
        let bounds = CGRect(x: x0, y: topY, width: span, height: max(1, bottom - topY))
        ArtStyle.form(&context, shape, bounds: bounds, light: 0.22, shade: 0.18)
        ArtStyle.rimEdge(&context, shape, bounds: bounds, width: 2.4, alpha: 0.4)
    }
}

// MARK: - Water

extension Kit {
    /// Water from `top` (the horizon or a shore) down to `bottom`: a vertical gradient, the far
    /// shore's shade on its first stretch, the light of the horizon lying on it, short ripple
    /// marks, and tooth.
    static func water(
        _ context: inout GraphicsContext,
        width w: CGFloat,
        top: CGFloat,
        bottom: CGFloat,
        stops: Stops,
        light: Light,
        ripples count: Int,
        seed: UInt32 = 31
    ) {
        let depth: CGFloat = max(1, bottom - top)
        Art.fillLinear(&context, Art.rect(0, top, w, depth), stops, from: CGPoint(x: 0, y: top), to: CGPoint(x: 0, y: bottom))
        Art.fill(&context, Art.rect(0, top, w, 8), light.near.opacity(0.3))
        let lie: Stops = [(light.glow.opacity(0.24), 0), (light.glow.opacity(0), 1)]
        let reach: CGFloat = min(depth, 36)
        Art.fillLinear(&context, Art.rect(0, top + 8, w, reach), lie, from: CGPoint(x: 0, y: top + 8), to: CGPoint(x: 0, y: top + 8 + reach))
        rippleMarks(&context, x0: 0, x1: w, y0: top + 8, y1: bottom, count: count, seed: seed, color: Color.white)
        ArtStyle.tooth(&context, in: CGRect(x: 0, y: top + 10, width: w, height: depth), seed: 77)
    }

    /// The sun's (or the moon's) path on the water under it: short bright bars that widen
    /// toward the viewer.
    static func glints(
        _ context: inout GraphicsContext,
        x: CGFloat,
        top: CGFloat,
        depth: CGFloat,
        color: Color,
        count: Int = 40,
        seed: UInt32 = 8
    ) {
        var random = ArtRandom(seed)
        for _ in 0..<max(0, count) {
            let t: CGFloat = rnd(&random)
            let dy: CGFloat = 6 + t * t * depth * 0.95
            let spread: CGFloat = 16 + dy * 0.5
            let bx: CGFloat = x + (rnd(&random) - 0.5) * spread * 2
            let bw: CGFloat = 6 + rnd(&random) * 22 * (0.5 + dy / 150)
            let alpha: Double = 0.35 + random.next() * 0.5
            Art.fill(&context, Art.rect(bx - bw / 2, top + dy, bw, 1.4 + dy / 90, radius: 1), color.opacity(alpha))
        }
    }

    /// Short horizontal ripple marks scattered over a stretch of water, finer far away.
    static func rippleMarks(
        _ context: inout GraphicsContext,
        x0: CGFloat,
        x1: CGFloat,
        y0: CGFloat,
        y1: CGFloat,
        count: Int,
        seed: UInt32,
        color: Color,
        alpha: Double = 0.3
    ) {
        guard x1 > x0, y1 > y0 else { return }
        var random = ArtRandom(seed)
        var marks = Path()
        for _ in 0..<max(0, count) {
            let t: CGFloat = rnd(&random)
            let y: CGFloat = y0 + (y1 - y0) * t * t
            let x: CGFloat = x0 + (x1 - x0) * rnd(&random)
            let length: CGFloat = 8 + 26 * t + rnd(&random) * 10
            marks.move(to: CGPoint(x: x, y: y))
            marks.addQuadCurve(to: CGPoint(x: x + length, y: y), control: CGPoint(x: x + length / 2, y: y - 1.6 - 2 * t))
        }
        Art.stroke(&context, marks, color.opacity(alpha), width: 1.3)
    }

    /// The rings on the water round something that stands or floats in it, centred on (x, y).
    static func ripples(
        _ context: inout GraphicsContext,
        _ x: CGFloat,
        _ y: CGFloat,
        _ width: CGFloat,
        count: Int = 2,
        color: Color = Color.white,
        opacity: Double = 0.55
    ) {
        for index in 0..<max(0, count) {
            let grow: CGFloat = 1 + CGFloat(index) * 0.22
            let half: CGFloat = width / 2 * grow
            let dy: CGFloat = CGFloat(index) * 6
            var ring = Path()
            ring.move(to: CGPoint(x: x - half, y: y + dy))
            ring.addQuadCurve(to: CGPoint(x: x + half, y: y + dy), control: CGPoint(x: x, y: y + dy + 7 + CGFloat(index) * 2))
            Art.stroke(&context, ring, color.opacity(opacity / Double(index + 1)), width: ArtStyle.detailLine)
        }
    }

    /// Rolling sea swells from `top` to `bottom`: rows of soft wave crests, larger toward the
    /// viewer, in `crest` over whatever is already painted (call `water` first).
    static func swells(
        _ context: inout GraphicsContext,
        width w: CGFloat,
        top: CGFloat,
        bottom: CGFloat,
        rows: Int,
        crest: Color,
        seed: UInt32 = 12
    ) {
        guard bottom > top, rows > 0 else { return }
        var random = ArtRandom(seed)
        for row in 0..<rows {
            let t: CGFloat = (CGFloat(row) + 0.5) / CGFloat(rows)
            let y: CGFloat = top + (bottom - top) * t * t
            let length: CGFloat = 26 + 60 * t
            let lift: CGFloat = 2 + 6 * t
            var line = Path()
            var x: CGFloat = -length * rnd(&random)
            line.move(to: CGPoint(x: x, y: y))
            while x < w {
                line.addQuadCurve(to: CGPoint(x: x + length, y: y), control: CGPoint(x: x + length * 0.5, y: y - lift))
                x += length
            }
            Art.stroke(&context, line, crest.opacity(0.18 + 0.3 * Double(t)), width: 1.2 + 1.4 * t)
        }
    }
}

// MARK: - Solids: any shape, modelled by the one light

extension Kit {
    /// Fills `path` with one colour and models it with the one light: a warm rim on its
    /// upper-left side, an indigo core shadow toward its lower right and, if `rim` is above 0,
    /// a thin lit contour of that width. The workhorse for bodies, roofs, pots, hulls, rocks.
    static func solid(
        _ context: inout GraphicsContext,
        _ path: Path,
        _ color: Color,
        light: Double = 0.26,
        shade: Double = 0.22,
        rim: CGFloat = 0
    ) {
        Art.fill(&context, path, color)
        model(&context, path, light: light, shade: shade, rim: rim)
    }

    /// As `solid`, filled with a top-to-bottom gradient over the shape's own height.
    static func solid(
        _ context: inout GraphicsContext,
        _ path: Path,
        stops: Stops,
        light: Double = 0.26,
        shade: Double = 0.22,
        rim: CGFloat = 0
    ) {
        let bounds = path.boundingRect
        Art.fillLinear(
            &context,
            path,
            stops,
            from: CGPoint(x: bounds.midX, y: bounds.minY),
            to: CGPoint(x: bounds.midX, y: bounds.maxY)
        )
        model(&context, path, light: light, shade: shade, rim: rim)
    }

    /// The light and shade of `solid`, for a shape that is already filled.
    static func model(_ context: inout GraphicsContext, _ path: Path, light: Double = 0.26, shade: Double = 0.22, rim: CGFloat = 0) {
        let bounds = path.boundingRect
        guard bounds.width > 0, bounds.height > 0 else { return }
        ArtStyle.form(&context, path, bounds: bounds, light: light, shade: shade)
        if rim > 0 {
            ArtStyle.rimEdge(&context, path, bounds: bounds, width: rim, alpha: 0.5)
        }
    }

    /// The contact shadow under something `width` wide that stands at (x, y).
    static func shadow(_ context: inout GraphicsContext, _ x: CGFloat, _ y: CGFloat, width: CGFloat, alpha: Double = 0.26) {
        ArtStyle.contactShadow(&context, x + width * 0.04, y, width * 0.55, max(2, width * 0.08), alpha: alpha)
    }

    /// A limb, a stem, a rope or a tail: SVG path data stroked with round ends.
    static func limb(_ context: inout GraphicsContext, _ data: String, _ width: CGFloat, _ color: Color) {
        Art.stroke(&context, Art.svg(data), color, width: width)
    }
}
