import SwiftUI
import OmramoCore

/// Concept art for "The Horse and the Olive", drawn in code (round 5; composed from the shared kit).
///
/// Ancient Athens before it had a name: a steep, flat-topped rock of pale limestone above a dry
/// plain, a thin band of blue sea far off, and a bright Attic sky that stays pale behind the
/// words in every scene. The cast and the story's own parts are in `OliveArt+Cast.swift`, the
/// folded scenes in `OliveArt+Folded.swift`, the small pictures in `OliveArt+Pictures.swift`.
enum OliveArt {
    /// Draws the picture called `name`. Returns false for a name this story does not have.
    static func paint(_ name: String, role: ArtRole, in context: inout GraphicsContext, size: CGSize) -> Bool {
        guard size.width > 0, size.height > 0 else { return false }
        switch (name, role) {
        case ("scene-hill", .sceneUnfolded): hillScene(&context, size)
        case ("scene-hill", .sceneFolded): hillFolded(&context, size)
        case ("scene-gods", .sceneUnfolded): godsScene(&context, size)
        case ("scene-gods", .sceneFolded): godsFolded(&context, size)
        case ("scene-horse", .sceneUnfolded): horseScene(&context, size)
        case ("scene-horse", .sceneFolded): horseFolded(&context, size)
        case ("scene-olive", .sceneUnfolded): oliveScene(&context, size)
        case ("scene-olive", .sceneFolded): oliveFolded(&context, size)
        case ("see-acropolis", .picture): acropolisPicture(&context, size)
        case ("see-greek-gods", .picture): godsJarPicture(&context, size)
        case ("see-olive-oil", .picture): oilPicture(&context, size)
        case ("see-olive-wreath", .picture): wreathPicture(&context, size)
        case ("char-athena", .portrait): athenaPortrait(&context, size)
        case ("char-poseidon", .portrait): poseidonPortrait(&context, size)
        case ("face-athena", .face): athenaFace(&context, size)
        case ("face-poseidon", .face): poseidonFace(&context, size)
        case ("face-cecrops", .face): cecropsFace(&context, size)
        case ("cover", .cover): cover(&context, size)
        default:
            return false
        }
        return true
    }
}

// MARK: - What every scene shares

extension OliveArt {
    /// The dry plain under the rock.
    static func plainStops() -> Kit.Stops {
        [(Art.color(0xE4D4AA), 0), (Art.color(0xD4BC8C), 0.5), (Art.color(0xBFA070), 1)]
    }

    /// The bare limestone of the hilltop.
    static func rockStops() -> Kit.Stops {
        [(Art.color(0xECE1C6), 0), (Art.color(0xDDCDA8), 0.5), (Art.color(0xC6B188), 1)]
    }

    /// One low bare hill of the ring round the plain, from x0 to x1, `height` above baseY.
    static func bareHill(_ context: inout GraphicsContext, x0: CGFloat, x1: CGFloat, baseY: CGFloat, height: CGFloat, color: Color) {
        let span: CGFloat = x1 - x0
        guard span > 0, height > 0 else { return }
        let peakX: CGFloat = x0 + span * 0.46
        var shape = Path()
        shape.move(to: CGPoint(x: x0, y: baseY + 4))
        shape.addQuadCurve(to: CGPoint(x: peakX, y: baseY - height), control: CGPoint(x: x0 + span * 0.2, y: baseY - height * 1.02))
        shape.addQuadCurve(to: CGPoint(x: x1, y: baseY + 4), control: CGPoint(x: x0 + span * 0.76, y: baseY - height * 0.98))
        shape.closeSubpath()
        Art.fill(&context, shape, color)
        let bounds = CGRect(x: x0, y: baseY - height, width: span, height: height + 4)
        ArtStyle.form(&context, shape, bounds: bounds, light: 0.16, shade: 0.12)
    }

    /// The far plane of every picture of the story: the pale sky, far islands, the thin band
    /// of blue sea, the low bare hills that ring the plain (the sea shows in the gap between
    /// them), a few far cypresses and the veil of air. `f` is the scale of the far plane.
    static func farPlane(_ context: inout GraphicsContext, _ size: CGSize, horizon H: CGFloat, far f: CGFloat, light: Kit.Light, seed: UInt32) {
        let w: CGFloat = size.width
        Kit.sky(&context, size, horizon: H, light: light)
        let seaTop: CGFloat = H - 12 * f
        let isles: Path = Kit.ridge(width: w, y: seaTop - 5 * f, amp: 9 * f, seed: seed &+ 3, bottom: seaTop + 2, step: 10)
        Art.fill(&context, isles, light.far.opacity(0.55))
        let sea: Kit.Stops = [(Art.color(0x6FA6CF), 0), (Art.color(seaHex), 1)]
        let band: Path = Art.rect(0, seaTop, w, H - seaTop + 2)
        Art.fillLinear(&context, band, sea, from: CGPoint(x: 0, y: seaTop), to: CGPoint(x: 0, y: H + 2))
        Art.fill(&context, Art.rect(0, seaTop, w, max(1, 1.4 * f)), Art.color(0xFFFFFF, 0.45))
        bareHill(&context, x0: w * 0.2, x1: w * 0.52, baseY: H, height: 21 * f, color: light.far)
        bareHill(&context, x0: -w * 0.1, x1: w * 0.34, baseY: H, height: 31 * f, color: light.mid)
        bareHill(&context, x0: w * 0.78, x1: w * 1.12, baseY: H, height: 26 * f, color: light.far)
        bareHill(&context, x0: w * 0.62, x1: w * 0.96, baseY: H, height: 35 * f, color: light.mid)
        let trees: Color = Art.color(0x6E8A78, 0.7)
        Kit.farTrees(&context, x0: w * 0.03, x1: w * 0.3, baseY: H + 2, height: 15 * f, count: 5, color: trees, conifer: true, seed: seed)
        Kit.farTrees(&context, x0: w * 0.7, x1: w * 0.98, baseY: H + 2, height: 13 * f, count: 4, color: trees, conifer: true, seed: seed &+ 9)
        ArtStyle.atmosphere(&context, width: w, top: H - 70 * f, bottom: H + 4, color: light.haze, alpha: 0.36)
    }

    /// The bare top of the rock from the horizon down: limestone, cracks, loose stones, a
    /// little thorny scrub and dry grass, all low and quiet.
    static func hilltop(_ context: inout GraphicsContext, _ size: CGSize, stage st: Kit.Stage, seed: UInt32) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let H: CGFloat = st.H
        let k: CGFloat = st.fit * st.grow
        Kit.ground(&context, width: w, top: H, bottom: h, stops: rockStops(), seed: 41, tooth: Art.color(0xFFF6DC))
        rockCracks(&context, x0: -20, x1: w, top: H + 6, bottom: h, count: 24, seed: seed, scale: k)
        let field = CGRect(x: 0, y: H + 10, width: w, height: max(10, st.depth - 24))
        Kit.pebbles(&context, in: field, count: 26, seed: seed &+ 2, color: 0xCDBE9C)
        scrub(&context, x: 330, baseY: H + st.depth * 0.34, width: 46 * k, seed: seed &+ 4)
        scrub(&context, x: 96, baseY: H + st.depth * 0.22, width: 32 * k, seed: seed &+ 6)
        Kit.grassTuft(&context, x: 176, baseY: H + st.depth * 0.56, height: 28 * k, color: strawHex, seed: seed &+ 1)
        Kit.grassTuft(&context, x: 404, baseY: H + st.depth * 0.7, height: 24 * k, color: strawHex, seed: seed &+ 5)
        if st.tall > 0.25 {
            // A tall window: the rock runs on toward the reader.
            Kit.rock(&context, cx: 112, baseY: h - st.depth * 0.16, width: 132, height: 62, color: 0xC4B592, seed: seed &+ 7)
            scrub(&context, x: 262, baseY: h - st.depth * 0.26, width: 96, seed: seed &+ 8)
            Kit.grassTuft(&context, x: 372, baseY: h - st.depth * 0.12, height: 58, color: strawHex, seed: seed &+ 9)
            let low = CGRect(x: 20, y: H + st.depth * 0.5, width: w - 40, height: st.depth * 0.42)
            Kit.pebbles(&context, in: low, count: 22, seed: seed &+ 11, color: 0xBFAE8A)
        }
    }

    /// The dark framing of the near plane: dry grass in the bottom-left corner and a cropped
    /// boulder with thorn in the bottom-right one.
    static func nearFrame(_ context: inout GraphicsContext, _ size: CGSize, stage st: Kit.Stage) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let k: CGFloat = st.fit * st.grow
        Kit.grassTuft(&context, x: 24, baseY: h + 8, height: 92 * k, color: 0x8A7A3E, seed: 3)
        Kit.grassTuft(&context, x: 92, baseY: h + 10, height: 58 * k, color: 0x9A8A46, seed: 8)
        Kit.rock(&context, cx: w - 30, baseY: h + 16 * k, width: 170 * k, height: 62 * k, color: 0x9A8A6A, seed: 6)
        Kit.grassTuft(&context, x: w - 118 * k, baseY: h + 8, height: 54 * k, color: 0x8A7A3E, seed: 12)
    }
}

// MARK: - scene-hill (unfolded): the town with no name

extension OliveArt {
    /// scene-hill: the steep, flat-topped rock above the dry plain, the first huts on it and
    /// under it, a man and a woman lifting a stone for the half-built wall, King Cecrops with
    /// his staff, goats, the spring. The leading pane is pale sky over a low line of hills.
    static func hillScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let st = Kit.stage(size, ground: 160)
        let H: CGFloat = st.H
        let k: CGFloat = st.fit * st.grow
        let light = day()
        farPlane(&context, size, horizon: H, far: st.far, light: light, seed: 4)
        Kit.cloud(&context, 300, H * 0.36 + 10, scale: 0.55 * st.far, color: Art.color(0xFFFFFF, 0.55))
        Kit.cloud(&context, 596, H * 0.22 + 14, scale: 0.8 * st.far, color: Art.color(0xFFFFFF, 0.7))

        Kit.ground(&context, width: w, top: H, bottom: h, stops: plainStops(), seed: 31, tooth: Art.color(0xFFF2D0))
        // The dusty track that winds across the plain to the rock.
        let dust: Kit.Stops = [(Art.color(0xEFE2BE), 0), (Art.color(0xDCC89A), 1)]
        Kit.ribbon(&context, nearX: 236, nearY: h, nearWidth: 150 * k, farX: 566, farY: H + 26 * st.fit, farWidth: 12, stops: dust)
        let field = CGRect(x: 0, y: H + 12, width: w, height: max(10, st.depth - 26))
        Kit.pebbles(&context, in: field, count: 24, seed: 5, color: 0xC9B894)
        Kit.grass(&context, in: field, count: 46, seed: 7, color: Art.color(strawHex, 0.8), height: 7)

        // Small things low on the leading side: two cypresses, thyme, two goats grazing.
        Kit.cypress(&context, x: 84, baseY: H + 12 * st.fit, height: 60 * st.far, color: 0x4E6E5A)
        Kit.cypress(&context, x: 112, baseY: H + 14 * st.fit, height: 42 * st.far, color: 0x567660)
        scrub(&context, x: 190, baseY: H + st.depth * 0.3, width: 40 * k, seed: 3)
        scrub(&context, x: 404, baseY: H + st.depth * 0.52, width: 52 * k, seed: 9)
        let herdY: CGFloat = H + st.depth * 0.36
        Kit.shadow(&context, 318, herdY, width: 40 * st.far)
        Art.group(&context, x: 318, y: herdY, scale: 0.3 * st.far) { g in
            goat(&g, dark: true, pose: .stand)
        }
        Kit.shadow(&context, 362, herdY + 9 * st.fit, width: 36 * st.far)
        Art.group(&context, x: 362, y: herdY + 9 * st.fit, scale: 0.26 * st.far, scaleX: -1) { g in
            goat(&g, dark: false, pose: .walk, mirrored: true)
        }

        if st.tall > 0.25 {
            // A tall window: jars and a basket wait beside the track, among the stones.
            let by: CGFloat = h - st.depth * 0.24
            Kit.pot(&context, cx: 96, baseY: by, width: 62, height: 84, color: clayHex, band: 0x6E3A22)
            Kit.pot(&context, cx: 152, baseY: by + 16, width: 48, height: 60, color: 0xB86E42)
            Kit.basket(&context, cx: 392, baseY: h - st.depth * 0.14, width: 84, height: 52, color: 0xC89A54, lid: false, handles: true)
            scrub(&context, x: 330, baseY: h - st.depth * 0.34, width: 88, seed: 14)
            let low = CGRect(x: 30, y: H + st.depth * 0.5, width: w - 60, height: st.depth * 0.4)
            Kit.pebbles(&context, in: low, count: 20, seed: 9, color: 0xB7A47C)
        }

        Kit.designSpace(&context, st) { v in
            Kit.nearSpace(&v, st, anchorX: 700) { n in
                hillCast(&n, horizon: st.Hv)
            }
        }
        nearFrame(&context, size, stage: st)
        ArtStyle.finish(&context, size)
    }

    /// The first huts and the piled wall on the flat top of the rock, tiny, in the rock's units.
    static func hilltopTown(_ r: inout GraphicsContext) {
        let wall: Color = Art.color(brickHex)
        let roof: Color = Art.color(thatchHex)
        Art.fill(&r, Art.rect(-124, -167, 44, 5, radius: 2), Art.color(0xBDB09A))
        Art.fill(&r, Art.rect(72, -169, 52, 5, radius: 2), Art.color(0xBDB09A))
        Kit.farHouse(&r, cx: -62, baseY: -165, width: 30, height: 22, wall: wall, roof: roof)
        Kit.farHouse(&r, cx: -24, baseY: -165, width: 24, height: 18, wall: wall, roof: roof)
        Kit.farHouse(&r, cx: 38, baseY: -164, width: 28, height: 21, wall: wall, roof: roof)
        // A thread of cooking smoke.
        Art.stroke(&r, Art.svg("M-20,-184 C-26,-196 -12,-204 -18,-218 C-22,-226 -14,-232 -16,-240"), Art.color(0xFFFFFF, 0.5), width: 2.4)
    }

    /// The rock and the people under it, in design units.
    static func hillCast(_ n: inout GraphicsContext, horizon Hv: CGFloat) {
        Kit.shadow(&n, 668, Hv + 30, width: 440, alpha: 0.16)
        Art.group(&n, x: 660, y: Hv + 28, scale: 1.02) { r in
            acropolis(&r)
            hilltopTown(&r)
        }
        // The wall the people are piling up, half built, and the huts under the rock.
        Kit.fence(&n, x0: 486, x1: 600, baseY: Hv + 84, height: 24, color: 0xC4B79C, stone: true)
        Kit.fence(&n, x0: 600, x1: 634, baseY: Hv + 84, height: 12, color: 0xC4B79C, stone: true)
        stone(&n, cx: 648, baseY: Hv + 88, width: 18, seed: 3)
        hut(&n, cx: 722, baseY: Hv + 72, width: 84)
        hut(&n, cx: 822, baseY: Hv + 92, width: 108)

        // King Cecrops watches the work.
        Kit.shadow(&n, 676, Hv + 104, width: 40)
        Art.group(&n, x: 676, y: Hv + 104, scale: 0.66) { p in
            cecrops(&p, pose: .stand, look: CGPoint(x: -0.7, y: 0.2), mouth: .smile)
        }
        // A man and a woman lift one stone together.
        let feet: CGFloat = Hv + 122
        stone(&n, cx: 596, baseY: feet - 47, width: 36, seed: 7)
        Kit.shadow(&n, 562, feet, width: 40)
        Art.group(&n, x: 562, y: feet, scale: 0.62, scaleX: -1) { p in
            folk(&p, 4, pose: .carry, look: CGPoint(x: -0.5, y: 0.5), mouth: .smile, mirrored: true)
        }
        Kit.shadow(&n, 630, feet, width: 40)
        Art.group(&n, x: 630, y: feet, scale: 0.62) { p in
            folk(&p, 1, pose: .carry, look: CGPoint(x: -0.5, y: 0.5), mouth: .smile)
        }
        // The goats, and the spring of cold water with its bucket.
        Kit.shadow(&n, 520, Hv + 142, width: 56)
        Art.group(&n, x: 520, y: Hv + 142, scale: 0.42) { g in
            goat(&g, dark: true, pose: .stand, mood: .happy)
        }
        Kit.shadow(&n, 596, Hv + 152, width: 50)
        Art.group(&n, x: 596, y: Hv + 152, scale: 0.38, scaleX: -1) { g in
            goat(&g, dark: false, pose: .walk, mood: .calm, mirrored: true)
        }
        springPool(&n, cx: 760, cy: Hv + 136, width: 70)
        bucket(&n, x: 812, baseY: Hv + 140, scale: 1.1)
        scrub(&n, x: 858, baseY: Hv + 124, width: 44, seed: 5)
    }
}

// MARK: - scene-gods (unfolded): two tall shining figures on the hilltop

extension OliveArt {
    /// One of the townspeople standing at (x, y) in design units, at the people's scale.
    /// `right` turns the person to face right (toward something on the trailing side).
    static func placeFolk(
        _ n: inout GraphicsContext,
        _ kind: Int,
        x: CGFloat,
        y: CGFloat,
        right: Bool,
        pose: Kit.Pose = .stand,
        look: CGPoint = CGPoint(x: -0.7, y: -0.6),
        mouth: Kit.Mouth = .smile,
        scale: CGFloat = 0.74
    ) {
        Kit.shadow(&n, x, y, width: 46 * scale / 0.74)
        Art.group(&n, x: x, y: y, scale: scale, scaleX: right ? -1 : 1) { p in
            folk(&p, kind, pose: pose, look: look, mouth: mouth, mirrored: right)
        }
    }

    /// scene-gods: the bare hilltop under a bright pale sky; white cloud piled high like a
    /// throne with light behind it; Poseidon with his trident and Athena with helmet pushed
    /// back, spear and shield, twice the height of the townspeople, who stand in a half circle.
    /// Two plain clay jars wait on the ground near the king.
    static func godsScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 160)
        let H: CGFloat = st.H
        let light = day()
        farPlane(&context, size, horizon: H, far: st.far, light: light, seed: 6)
        cloudThrone(&context, cx: 664, baseY: H * 0.5, scale: 0.8 * st.far, light: light)
        Kit.cloud(&context, 250, H * 0.42, scale: 0.5 * st.far, color: Art.color(0xFFFFFF, 0.5))
        hilltop(&context, size, stage: st, seed: 5)

        // Small things low on the leading side: a piece of the piled wall, and the goats, who ran.
        Kit.fence(&context, x0: 30, x1: 150, baseY: H + 16 * st.fit, height: 13 * st.far, color: 0xC4B79C, stone: true)
        let runY: CGFloat = H + st.depth * 0.4
        Kit.shadow(&context, 250, runY, width: 44 * st.far)
        Art.group(&context, x: 250, y: runY, scale: 0.3 * st.far) { g in
            goat(&g, dark: true, pose: .run, mood: .surprised)
        }
        Kit.shadow(&context, 198, runY - 12 * st.fit, width: 36 * st.far)
        Art.group(&context, x: 198, y: runY - 12 * st.fit, scale: 0.24 * st.far) { g in
            goat(&g, dark: false, pose: .run, mood: .surprised)
        }

        Kit.designSpace(&context, st) { v in
            Kit.nearSpace(&v, st, anchorX: 690) { n in
                godsCast(&n, horizon: st.Hv)
            }
        }
        nearFrame(&context, size, stage: st)
        ArtStyle.finish(&context, size)
    }

    /// The two gods and the half circle of people, in design units.
    static func godsCast(_ n: inout GraphicsContext, horizon Hv: CGFloat) {
        // The edge of the huts.
        hut(&n, cx: 884, baseY: Hv + 36, width: 92)

        // A faint bronze brightness round the two of them.
        Art.glow(&n, 690, Hv - 60, 230, Art.color(0xFBE7B0), alpha: 0.4)
        let godsY: CGFloat = Hv + 84
        Kit.shadow(&n, 628, godsY, width: 96)
        Art.group(&n, x: 628, y: godsY, scale: 1.5) { p in
            poseidon(&p, pose: .stand, look: CGPoint(x: -0.5, y: 0.4), mouth: .grin, trident: true)
        }
        Kit.shadow(&n, 762, godsY, width: 110)
        Art.group(&n, x: 756, y: godsY, scale: 1.5) { p in
            athena(&p, pose: .stand, look: CGPoint(x: -0.5, y: 0.4), mouth: .smile, armed: true)
        }

        // The people, small and very still, in a half circle before them.
        Kit.shadow(&n, 548, Hv + 104, width: 44)
        Art.group(&n, x: 548, y: Hv + 104, scale: 0.74, scaleX: -1) { p in
            cecrops(&p, pose: .stand, look: CGPoint(x: -0.6, y: -0.7), mouth: .flat, mirrored: true)
        }
        placeFolk(&n, 0, x: 500, y: Hv + 112, right: true, mouth: .oh)
        placeFolk(&n, 5, x: 874, y: Hv + 110, right: false, mouth: .oh)
        placeFolk(&n, 1, x: 468, y: Hv + 124, right: true, mouth: .flat)
        placeFolk(&n, 4, x: 836, y: Hv + 126, right: false, mouth: .flat)
        placeFolk(&n, 2, x: 522, y: Hv + 134, right: true, mouth: .flat)
        placeFolk(&n, 3, x: 568, y: Hv + 138, right: true, mouth: .oh)

        // The two plain jars for the pebbles.
        Kit.pot(&n, cx: 604, baseY: Hv + 150, width: 34, height: 44, color: clayHex)
        Kit.pot(&n, cx: 644, baseY: Hv + 154, width: 34, height: 44, color: 0xB86E42)
    }
}

// MARK: - scene-horse (unfolded): Poseidon's gift

extension OliveArt {
    /// scene-horse: Poseidon has struck the rock; the stone has split in a jagged line, and out
    /// of it, in a fan of white spray, leaps the white horse with his mane flying. The people
    /// fall back, a child behind her mother. A few flecks of spray drift over the pale sky.
    static func horseScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 160)
        let H: CGFloat = st.H
        let light = day()
        farPlane(&context, size, horizon: H, far: st.far, light: light, seed: 8)
        Kit.cloud(&context, 610, H * 0.24 + 12, scale: 0.7 * st.far, color: Art.color(0xFFFFFF, 0.65))
        let drift = CGRect(x: 250, y: H - 160 * st.far, width: 200, height: 130 * st.far)
        Kit.flecks(&context, in: drift, count: 9, seed: 21, color: Art.color(0xFFFFFF, 0.85), radius: 1.0...2.4)
        hilltop(&context, size, stage: st, seed: 9)
        // A hut far back on the leading side, and its wall.
        Kit.fence(&context, x0: 180, x1: 300, baseY: H + 14 * st.fit, height: 12 * st.far, color: 0xC4B79C, stone: true)
        hut(&context, cx: 96, baseY: H + 18 * st.fit, width: 56 * st.far)

        Kit.designSpace(&context, st) { v in
            Kit.nearSpace(&v, st, anchorX: 700) { n in
                horseCast(&n, horizon: st.Hv)
            }
        }
        nearFrame(&context, size, stage: st)
        ArtStyle.finish(&context, size)
    }

    /// Poseidon, the split rock, the spray, the horse and the people, in design units.
    static func horseCast(_ n: inout GraphicsContext, horizon Hv: CGFloat) {
        // Poseidon has turned to his gift, the trident still planted where it struck.
        let seaY: CGFloat = Hv + 92
        Kit.shadow(&n, 548, seaY, width: 96)
        Art.group(&n, x: 548, y: seaY, scale: 1.45, scaleX: -1) { p in
            poseidon(&p, pose: .stand, look: CGPoint(x: -0.7, y: 0), mouth: .grin, trident: true, mirrored: true)
        }

        let gapY: CGFloat = Hv + 112
        Art.group(&n, x: 716, y: gapY, scale: 1.1) { r in
            splitRock(&r)
        }
        sprayBurst(&n, cx: 716, baseY: gapY - 4, r: 150)

        // The horse, up on his hind legs in the gap.
        Kit.shadow(&n, 724, gapY + 2, width: 120, alpha: 0.2)
        Art.group(&n, x: 722, y: gapY + 2, scale: 1.15) { a in
            horse(&a, pose: .rear, mood: .happy, look: CGPoint(x: -0.4, y: -0.2))
        }
        // Spray in front of his legs.
        let front = CGRect(x: 640, y: Hv + 30, width: 170, height: 76)
        Kit.flecks(&n, in: front, count: 16, seed: 27, color: Art.color(0xFFFFFF, 0.95), radius: 1.2...3.0)

        // The people fall back in wonder; a child hides behind her mother.
        placeFolk(&n, 3, x: 874, y: Hv + 108, right: false, look: CGPoint(x: -0.7, y: -0.4), mouth: .oh)
        placeFolk(&n, 1, x: 838, y: Hv + 124, right: false, pose: .wave, look: CGPoint(x: -0.7, y: -0.5), mouth: .oh)
        placeFolk(&n, 0, x: 632, y: Hv + 136, right: true, pose: .wave, look: CGPoint(x: -0.7, y: -0.6), mouth: .open)
    }
}

// MARK: - scene-olive (unfolded): Athena's gift

extension OliveArt {
    /// scene-olive: pale gold late afternoon. Athena kneels, her spear laid down, beside the
    /// young grey-green olive tree that grows from a crack in the bare rock, heavy with small
    /// fruit; an old woman and a small girl step near, the girl holding one olive up to the
    /// light. The people stand back in a loose group; one small owl watches from a rock.
    static func oliveScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 160)
        let H: CGFloat = st.H
        let light = gold()
        farPlane(&context, size, horizon: H, far: st.far, light: light, seed: 10)
        Kit.sun(&context, 128, H - 50 * st.far, 17 * st.far, light: light)
        Kit.cloud(&context, 640, H * 0.26 + 10, scale: 0.75 * st.far, color: Art.color(0xFFFFFF, 0.6))
        hilltop(&context, size, stage: st, seed: 13)
        Kit.fence(&context, x0: 220, x1: 330, baseY: H + 14 * st.fit, height: 12 * st.far, color: 0xC4B79C, stone: true)

        Kit.designSpace(&context, st) { v in
            Kit.nearSpace(&v, st, anchorX: 720) { n in
                oliveCast(&n, horizon: st.Hv)
            }
        }
        nearFrame(&context, size, stage: st)
        ArtStyle.finish(&context, size)
    }

    /// The tree, Athena, the old woman, the girl, the watchers and the owl, in design units.
    static func oliveCast(_ n: inout GraphicsContext, horizon Hv: CGFloat) {
        // The people stand back in a loose group. Nobody cheers.
        placeFolk(&n, 4, x: 486, y: Hv + 40, right: true, look: CGPoint(x: -0.7, y: 0), mouth: .flat, scale: 0.56)
        placeFolk(&n, 5, x: 524, y: Hv + 46, right: true, look: CGPoint(x: -0.7, y: 0), mouth: .flat, scale: 0.56)
        placeFolk(&n, 0, x: 566, y: Hv + 42, right: true, look: CGPoint(x: -0.7, y: 0), mouth: .smile, scale: 0.56)
        placeFolk(&n, 6, x: 600, y: Hv + 52, right: true, look: CGPoint(x: -0.7, y: 0), mouth: .oh, scale: 0.56)

        // The owl on its rock, once.
        Kit.rock(&n, cx: 512, baseY: Hv + 132, width: 76, height: 42, color: 0xC4B592, seed: 5)
        Art.group(&n, x: 514, y: Hv + 90, scale: 0.72) { b in
            Kit.bird(&b, owlLook(), pose: .perch)
        }

        // Her shield, set down behind her, and her spear, laid on the rock.
        shield(&n, cx: 862, cy: Hv + 66, r: 36)
        spear(&n, x: 632, y: Hv + 150, length: 214, lean: Kit.deg(87))

        // The young olive tree.
        Art.group(&n, x: 722, y: Hv + 106, scale: 0.92) { t in
            oliveTree(&t, fruit: true, seed: 5)
        }

        // Athena kneels to be level with the people, and holds out one olive on her palm.
        let lady = athenaLook()
        let palm: CGPoint = Kit.hand(lady, pose: .kneel)
        Kit.shadow(&n, 812, Hv + 112, width: 130)
        Art.group(&n, x: 808, y: Hv + 110, scale: 1.45) { p in
            athena(&p, pose: .kneel, look: CGPoint(x: -0.6, y: 0.3), mouth: .smile)
            olive(&p, x: palm.x - 1, y: palm.y - 8, r: 4.6, ripe: false)
        }

        // The old woman steps close to touch the leaves.
        placeFolk(&n, 2, x: 640, y: Hv + 110, right: true, pose: .reach, look: CGPoint(x: -0.6, y: -0.5), mouth: .smile)
        // The small girl holds one olive up to the light.
        let girl = folkLook(3)
        let up: CGPoint = Kit.hand(girl, pose: .reach)
        Kit.shadow(&n, 680, Hv + 120, width: 36)
        Art.group(&n, x: 680, y: Hv + 120, scale: 0.74, scaleX: -1) { p in
            folk(&p, 3, pose: .reach, look: CGPoint(x: -0.5, y: -0.8), mouth: .smile, mirrored: true)
            olive(&p, x: up.x - 2, y: up.y - 9, r: 6, ripe: false)
        }
    }
}
