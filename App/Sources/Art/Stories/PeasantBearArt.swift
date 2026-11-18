import SwiftUI
import OmramoCore

/// Concept art for "The Peasant and the Bear", drawn in code (round 5; composed from the shared kit).
///
/// A Russian village tale in four seasons of light: a spring field of dark turned earth, an
/// autumn field of turnips under yellow birches, a high-summer sea of rye, and the harvest.
/// The cast and the story's own parts are in `PeasantBearArt+Cast.swift`, the folded scenes in
/// `PeasantBearArt+Folded.swift`, the small pictures in `PeasantBearArt+Pictures.swift`.
enum PeasantBearArt {
    /// Draws the picture called `name`. Returns false for a name this story does not have.
    static func paint(_ name: String, role: ArtRole, in context: inout GraphicsContext, size: CGSize) -> Bool {
        guard size.width > 0, size.height > 0 else { return false }
        switch (name, role) {
        case ("scene-field", .sceneUnfolded): fieldScene(&context, size)
        case ("scene-field", .sceneFolded): fieldFolded(&context, size)
        case ("scene-turnips", .sceneUnfolded): turnipsScene(&context, size)
        case ("scene-turnips", .sceneFolded): turnipsFolded(&context, size)
        case ("scene-rye", .sceneUnfolded): ryeScene(&context, size)
        case ("scene-rye", .sceneFolded): ryeFolded(&context, size)
        case ("scene-harvest", .sceneUnfolded): harvestScene(&context, size)
        case ("scene-harvest", .sceneFolded): harvestFolded(&context, size)
        case ("see-forest", .picture): forestPicture(&context, size)
        case ("see-turnip", .picture): turnipPicture(&context, size)
        case ("see-rye", .picture): ryePicture(&context, size)
        case ("char-peasant", .portrait): peasantPortrait(&context, size)
        case ("char-bear", .portrait): bearPortrait(&context, size)
        case ("face-peasant", .face): peasantFace(&context, size)
        case ("face-bear", .face): bearFace(&context, size)
        case ("face-wife", .face): wifeFace(&context, size)
        case ("cover", .cover): cover(&context, size)
        default:
            return false
        }
        return true
    }
}

// MARK: - The far plane every scene shares

extension PeasantBearArt {
    /// Sky, one or two pale clouds, the low far forest line along the horizon and its veil of
    /// air. `sunX` non-nil puts a small low sun on the leading side.
    static func farPlane(_ context: inout GraphicsContext, _ size: CGSize, stage st: Kit.Stage, light: Kit.Light, sunX: CGFloat?, seed: UInt32) {
        let w: CGFloat = size.width
        let H: CGFloat = st.H
        let far: CGFloat = st.far
        Kit.sky(&context, size, horizon: H, light: light)
        if let sunX {
            Kit.sun(&context, sunX, H - 42 * far, 20 * far, light: light)
        }
        let cloudY: CGFloat = H * 0.3 + 10
        Kit.cloud(&context, 618, cloudY, scale: 0.9 * far, color: Art.color(0xFFFFFF, 0.72))
        Kit.cloud(&context, 318, H * 0.46, scale: 0.55 * far, color: Art.color(0xFFFFFF, 0.5))
        let band: Path = Kit.ridge(width: w, y: H - 11 * far, amp: 5 * far, seed: seed, bottom: H + 4)
        Art.fill(&context, band, light.far.opacity(0.8))
        Kit.farTrees(&context, x0: -10, x1: w + 10, baseY: H + 2, height: 30 * far, count: 48, color: light.far, conifer: true, seed: seed)
        Kit.farTrees(&context, x0: -10, x1: w + 10, baseY: H + 2, height: 20 * far, count: 36, color: light.mid.opacity(0.8), conifer: false, seed: seed &+ 7)
        ArtStyle.atmosphere(&context, width: w, top: H - 60 * far, bottom: H + 4, color: light.haze, alpha: 0.42)
    }

    /// The dark framing of the near plane: long grass in the two bottom corners.
    static func nearFrame(_ context: inout GraphicsContext, _ size: CGSize, stage st: Kit.Stage, color: UInt32) {
        let k: CGFloat = st.fit * st.grow
        Kit.grassTuft(&context, x: 26, baseY: size.height + 8, height: 96 * k, color: color, seed: 3)
        Kit.grassTuft(&context, x: 96, baseY: size.height + 10, height: 62 * k, color: color, seed: 8)
        Kit.cornerLeaves(&context, size: size, corner: 3, color: Art.color(color), scale: 0.9 * k, seed: 4)
    }
}

// MARK: - scene-field (unfolded): a spring morning

extension PeasantBearArt {
    /// scene-field: spring. Dark turned earth in furrows right up to the forest edge; the
    /// Peasant, cap in hand, beside his plough and his small horse; the Bear up on his hind
    /// legs, just out of the bushes. The leading pane is pale morning sky with a few birds.
    static func fieldScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let st = Kit.stage(size, ground: 150)
        let H: CGFloat = st.H
        let light = spring()
        farPlane(&context, size, stage: st, light: light, sunX: 128, seed: 3)

        // A strip of new grass under the far trees, then the turned earth.
        let meadow: Kit.Stops = [(Art.color(0xA6D272), 0), (Art.color(0x6FAE52), 1)]
        Kit.ground(&context, width: w, top: H, bottom: h, stops: meadow)
        let edge: CGFloat = H + 20 * st.fit
        let earth: Kit.Stops = [(Art.color(0x7A5230), 0), (Art.color(0x5B3A1E), 0.5), (Art.color(0x43291A), 1)]
        Kit.ground(&context, width: w, top: edge, bottom: h, stops: earth, seed: 21, tooth: Art.color(0xE8C9A0))
        Kit.furrows(&context, x0: -180, x1: w + 180, top: edge, bottom: h, color: 0x5B3A1E, count: 18)
        let verge = CGRect(x: 0, y: H + 5, width: w, height: 13 * st.fit)
        Kit.grass(&context, in: verge, count: 80, seed: 5, color: Art.color(0x4F8F45), height: 7)
        Kit.grass(&context, in: verge, count: 50, seed: 6, color: Art.color(0xC4E88A), height: 5)
        Kit.flowers(&context, in: verge, count: 16, seed: 7, petal: 0xFFF3A0)

        // Small things low on the leading side: two far birches, birds over the field.
        Kit.farTree(&context, x: 64, baseY: H + 3, height: 58 * st.far, color: light.mid)
        Kit.farTree(&context, x: 96, baseY: H + 3, height: 44 * st.far, color: light.mid.opacity(0.85))
        Kit.birds(&context, 236, H - 92 * st.far, scale: st.far, color: Art.color(0x6E8E96))
        Kit.birds(&context, 372, H - 44 * st.far, scale: 0.7 * st.far, color: Art.color(0x6E8E96, 0.8))
        // Two rooks walk the new furrows, looking for worms.
        let rook = Kit.crowLook()
        let rookY: CGFloat = H + st.depth * 0.42
        Kit.shadow(&context, 300, rookY, width: 26 * st.far)
        Art.group(&context, x: 300, y: rookY, scale: 0.5 * st.far) { c in
            Kit.bird(&c, rook, pose: .peck)
        }
        Kit.shadow(&context, 358, rookY + 14 * st.fit, width: 28 * st.far)
        Art.group(&context, x: 358, y: rookY + 14 * st.fit, scale: 0.56 * st.far, scaleX: -1) { c in
            Kit.bird(&c, rook, pose: .perch, mirrored: true)
        }

        if st.tall > 0.25 {
            // A tall window: the field runs toward the reader; a sack of seed waits on it.
            let low = CGRect(x: 30, y: H + st.depth * 0.5, width: w - 60, height: st.depth * 0.4)
            Kit.pebbles(&context, in: low, count: 22, seed: 9, color: 0x8A7A68)
            Kit.sack(&context, cx: 228, baseY: h - st.depth * 0.3, width: 74, height: 88, color: 0xC8B088)
            Kit.grassTuft(&context, x: 330, baseY: h - st.depth * 0.14, height: 54, color: 0x4F8F45, seed: 12)
        }

        Kit.designSpace(&context, st) { v in
            Kit.nearSpace(&v, st, anchorX: 800) { n in
                fieldCast(&n, horizon: st.Hv)
            }
        }
        nearFrame(&context, size, stage: st, color: 0x2F6B3A)
        ArtStyle.finish(&context, size)
    }

    /// The forest edge and the cast of scene-field, in design units.
    static func fieldCast(_ n: inout GraphicsContext, horizon Hv: CGFloat) {
        let fresh: Kit.Greens = Kit.springGreens()
        forestEdge(&n, horizon: Hv, leaves: fresh, bushes: Kit.summerGreens())

        // The Bear, up on his hind legs: his first great roar (an "O", never teeth).
        let bearY: CGFloat = Hv + 64
        Kit.shadow(&n, 822, bearY, width: 124)
        Art.group(&n, x: 822, y: bearY, scale: 1.12) { b in
            bear(&b, pose: .rear, mood: .surprised, look: CGPoint(x: -0.7, y: 0.3), brow: 1)
        }
        // The bushes he has just come through.
        Kit.bush(&n, x: 884, baseY: Hv + 86, width: 96, palette: fresh, seed: 14)

        // The horse has stopped and looks back; the wooden plough stands in its furrow.
        let teamY: CGFloat = Hv + 92
        Kit.shadow(&n, 550, teamY, width: 124)
        Art.group(&n, x: 546, y: teamY, scale: 0.8) { a in
            horse(&a, mood: .surprised, look: CGPoint(x: 0.8, y: 0))
        }
        let traces: Path = Art.svg("M528,\(teamY - 68) L604,\(teamY - 28) M530,\(teamY - 62) L604,\(teamY - 26)")
        Art.stroke(&n, traces, Art.color(0x6B4A32), width: 1.8)
        Kit.tool(&n, .plough, x: 642, baseY: teamY + 2, height: 78, wood: 0xA87844, metal: 0x8A8F98)

        // The Peasant has turned round. He does not run: he takes off his cap.
        let manY: CGFloat = Hv + 88
        Kit.shadow(&n, 700, manY, width: 58)
        Art.group(&n, x: 700, y: manY, scale: 0.95, scaleX: -1) { p in
            peasant(&p, pose: .carry, look: CGPoint(x: -0.6, y: -0.6), mouth: .smile, capInHand: true, mirrored: true)
        }
        // A few sods at the plough's foot.
        let sods = CGRect(x: 590, y: teamY + 2, width: 90, height: 14)
        Kit.pebbles(&n, in: sods, count: 7, seed: 4, color: 0x6B4A32)
    }
}

// MARK: - scene-turnips (unfolded): autumn

extension PeasantBearArt {
    /// scene-turnips: autumn. Yellow birches, the pulled field with turnips lying on the
    /// soil, the cart heaped with round roots, the Peasant lifting one in, and the Bear
    /// sitting by his heap of green tops with a leaf in his mouth.
    static func turnipsScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let st = Kit.stage(size, ground: 150)
        let H: CGFloat = st.H
        let light = autumn()
        farPlane(&context, size, stage: st, light: light, sunX: 150, seed: 11)
        // Far birches in their gold along the horizon, seen through the air.
        Kit.farTrees(&context, x0: 10, x1: 440, baseY: H + 3, height: 44 * st.far, count: 7, color: Art.color(0xE6C25A, 0.85), conifer: false, seed: 5)
        ArtStyle.atmosphere(&context, width: w, top: H - 60 * st.far, bottom: H + 4, color: light.haze, alpha: 0.18)

        let verge: Kit.Stops = [(Art.color(0xCFC46A), 0), (Art.color(0xA99A4A), 1)]
        Kit.ground(&context, width: w, top: H, bottom: h, stops: verge)
        let edge: CGFloat = H + 18 * st.fit
        let soil: Kit.Stops = [(Art.color(0x9A7442), 0), (Art.color(0x7A5230), 0.55), (Art.color(0x5B3A1E), 1)]
        Kit.ground(&context, width: w, top: edge, bottom: h, stops: soil, seed: 23, tooth: Art.color(0xF2D9A8))
        Kit.furrows(&context, x0: -180, x1: w + 180, top: edge, bottom: h, color: 0x7A5230, count: 14)
        let strip = CGRect(x: 0, y: H + 5, width: w, height: 11 * st.fit)
        Kit.grass(&context, in: strip, count: 70, seed: 5, color: Art.color(0x8A8A3A), height: 7)
        turnipRows(&context, width: w, top: edge, bottom: h, scale: st.fit * st.grow)
        driftingLeaves(&context, horizon: H, far: st.far)

        if st.tall > 0.25 {
            // A tall window: a basket of turnips stands on the near soil.
            let by: CGFloat = h - st.depth * 0.26
            turnip(&context, x: 214, y: by - 70, r: 17)
            turnip(&context, x: 246, y: by - 76, r: 18)
            turnip(&context, x: 276, y: by - 68, r: 16)
            Kit.basket(&context, cx: 244, baseY: by, width: 104, height: 64, color: 0xC89A54, lid: false, handles: true)
        }

        Kit.designSpace(&context, st) { v in
            Kit.nearSpace(&v, st, anchorX: 760) { n in
                turnipsCast(&n, horizon: st.Hv)
            }
        }
        nearFrame(&context, size, stage: st, color: 0x7A6A2A)
        ArtStyle.finish(&context, size)
    }

    /// Pulled turnips lying in rows on the soil, larger toward the reader.
    static func turnipRows(_ context: inout GraphicsContext, width w: CGFloat, top: CGFloat, bottom: CGFloat, scale k: CGFloat) {
        var random = ArtRandom(17)
        let depth: CGFloat = bottom - top
        for row in 0..<4 {
            let t: CGFloat = (CGFloat(row) + 0.6) / 4.4
            let y: CGFloat = top + depth * t * t * 0.95 + 8 * k
            let r: CGFloat = (4.5 + 7 * t) * k
            let gap: CGFloat = r * 10
            var x: CGFloat = gap * Kit.rnd(&random)
            while x < w {
                let tilt: CGFloat = (Kit.rnd(&random) - 0.5) * 1.7
                ArtStyle.contactShadow(&context, x + r * 0.2, y + r * 0.9, r * 1.3, r * 0.32, alpha: 0.2)
                turnip(&context, x: x, y: y, r: r, tops: true, tilt: tilt)
                x += gap * (0.8 + Kit.rnd(&random) * 0.5)
            }
        }
    }

    /// A few yellow birch leaves coming down: more on the trailing side, low on the leading.
    static func driftingLeaves(_ context: inout GraphicsContext, horizon H: CGFloat, far: CGFloat) {
        let spots: [(CGFloat, CGFloat, CGFloat)] = [
            (118, 0.9, 40), (262, 0.94, 110), (398, 0.89, 200), (520, 0.56, 20),
            (604, 0.42, 150), (676, 0.3, 80), (742, 0.6, 250), (836, 0.2, 320), (566, 0.74, 60),
        ]
        var gold = Path()
        var amber = Path()
        var index: Int = 0
        for spot in spots {
            let base = CGPoint(x: spot.0, y: H * spot.1)
            let a: CGFloat = Kit.deg(spot.2)
            if index % 2 == 0 {
                Kit.groundLeaf(&gold, base: base, angle: a, length: 10 * far, width: 6 * far)
            } else {
                Kit.groundLeaf(&amber, base: base, angle: a, length: 9 * far, width: 5 * far)
            }
            index += 1
        }
        Art.fill(&context, gold, Art.color(0xF2B93A))
        Art.fill(&context, amber, Art.color(0xE08A2A))
    }

    /// The forest edge and the cast of scene-turnips, in design units.
    static func turnipsCast(_ n: inout GraphicsContext, horizon Hv: CGFloat) {
        let gold: Kit.Greens = Kit.autumnLeaves()
        forestEdge(&n, horizon: Hv, leaves: gold, bushes: gold, shift: 14)

        // The cart, heaped with round roots (their tops are cut: those are the Bear's).
        let cartY: CGFloat = Hv + 86
        Kit.cart(&n, cx: 792, baseY: cartY, length: 150, color: cartHex, load: turnipHex)
        let topY: CGFloat = cartY - 89.4
        let load: [(CGFloat, CGFloat, CGFloat)] = [
            (734, 2, 11), (848, 0, 11), (776, -4, 12), (806, -2, 12), (760, -14, 13), (822, -13, 13), (791, -26, 14),
        ]
        for item in load {
            turnip(&n, x: item.0, y: topY - 16 + item.1, r: item.2, tops: false)
        }
        Kit.heap(&n, cx: 850, baseY: Hv + 114, width: 72, count: 6, color: turnipHex, leaf: topsHex, seed: 3)

        // The Peasant lifts one more turnip in, and looks round at the Bear.
        let manY: CGFloat = Hv + 92
        let p = peasantLook()
        let hand: CGPoint = Kit.hand(p, pose: .reach)
        Kit.shadow(&n, 694, manY, width: 58)
        Art.group(&n, x: 694, y: manY, scale: 0.95, scaleX: -1) { g in
            peasant(&g, pose: .reach, look: CGPoint(x: 0.7, y: 0.2), mouth: .smile, mirrored: true)
            turnip(&g, x: hand.x - 3, y: hand.y - 9, r: 11, tops: false)
        }

        // The Bear sits by his heap of tops and chews one. It is tough. It is bitter.
        let bearY: CGFloat = Hv + 100
        Kit.shadow(&n, 560, bearY, width: 156)
        Art.group(&n, x: 560, y: bearY, scale: 1.15, scaleX: -1) { b in
            bear(&b, pose: .sit, mood: .calm, look: CGPoint(x: -0.8, y: -0.1), brow: 1, sprig: .leaf, mirrored: true)
        }
        leafHeap(&n, cx: 490, baseY: Hv + 116, width: 116)
    }
}

// MARK: - scene-rye (unfolded): high summer

extension PeasantBearArt {
    /// scene-rye: high summer. A sea of golden rye across both panes, in the lower part
    /// only; on the trailing side it stands tall and near, and the Bear peers over it with a
    /// stalk in his mouth, watching his "roots" grow.
    static func ryeScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let st = Kit.stage(size, ground: 150)
        let H: CGFloat = st.H
        let depth: CGFloat = st.depth
        let light = summer()
        farPlane(&context, size, stage: st, light: light, sunX: nil, seed: 19)
        // The sun is high and out of the picture: only its warmth in the upper left.
        Art.glow(&context, 40, 30, 300, light.glow, alpha: 0.4)
        Kit.birds(&context, 214, H - 104 * st.far, scale: 1.1 * st.far, color: Art.color(0x55707E))

        // The field: ripe rye to the horizon, in three bands that grow toward the reader.
        let gold: Kit.Stops = [(Art.color(0xF4DA86), 0), (Art.color(0xE9C050), 0.5), (Art.color(0xD9A632), 1)]
        Kit.ground(&context, width: w, top: H, bottom: h, stops: gold, seed: 41, tooth: Art.color(0xFFF3C4))
        Kit.grainField(&context, x0: -10, x1: w + 10, baseY: H + 26 * st.fit, height: 30 * st.fit, color: 0xF2D272, seed: 1)
        Kit.grainField(&context, x0: -10, x1: w + 10, baseY: H + depth * 0.56, height: depth * 0.4, color: 0xECC458, seed: 2)
        Kit.grainField(&context, x0: -10, x1: w + 10, baseY: h + 4, height: depth * 0.5, color: 0xE3B23C, seed: 3)
        // Cornflowers among the near stalks.
        let blue = CGRect(x: 12, y: h - depth * 0.4, width: 430, height: depth * 0.24)
        Kit.flowers(&context, in: blue, count: 14, seed: 4, petal: 0x4F7FD9, heart: 0x2E3F8A)

        if st.tall > 0.25 {
            // A tall window: one more, nearer band, and loose ears in front of it.
            Kit.grainField(&context, x0: -10, x1: w + 10, baseY: h + 4, height: depth * 0.24, color: 0xD9A632, seed: 5)
            Kit.crop(&context, x0: 16, x1: 440, baseY: h + 12, height: 120, tops: false, color: 0xC9982E, seed: 6)
        }

        let floor: CGFloat = st.Hv + (st.hv - st.Hv) / st.grow
        Kit.designSpace(&context, st) { v in
            Kit.nearSpace(&v, st, anchorX: 760) { n in
                ryeCast(&n, horizon: st.Hv, floor: floor)
            }
        }
        ArtStyle.finish(&context, size)
    }

    /// The Bear and the tall near rye of scene-rye, in design units; `floor` is the bottom
    /// edge of the picture in those units.
    static func ryeCast(_ n: inout GraphicsContext, horizon Hv: CGFloat, floor: CGFloat) {
        let green: Kit.Greens = Kit.summerGreens()
        forestEdge(&n, horizon: Hv, leaves: green, bushes: green, shift: 96)

        // The Bear, chest-deep, paws together. He never once looks at the tops.
        let bearY: CGFloat = Hv + 72
        Art.group(&n, x: 716, y: bearY, scale: 1.25) { b in
            bear(&b, pose: .rear, mood: .happy, look: CGPoint(x: -0.4, y: 0.7), brow: 0.6, sprig: .rye)
        }

        // The near rye, in steps that rise toward the trailing edge; each hides the foot of
        // the one behind it.
        let steps: [(CGFloat, CGFloat, UInt32)] = [(628, -50, 0xECC050), (566, -16, 0xE6B844), (512, 20, 0xDFAE3A), (462, 56, 0xD8A432)]
        var seed: UInt32 = 21
        let base: CGFloat = floor + 6
        for step in steps {
            let top: CGFloat = Hv + step.1
            Kit.grainField(&n, x0: step.0, x1: 990, baseY: base, height: base - top, color: step.2, seed: seed)
            seed = seed &+ 3
        }
        // Loose stalks where the field ends, so its edge is soft.
        Kit.crop(&n, x0: 430, x1: 520, baseY: base, height: 86, tops: false, color: 0xC9982E, seed: 8)
        Kit.crop(&n, x0: 600, x1: 660, baseY: Hv - 2, height: 60, tops: false, color: 0xD9A632, seed: 9)
    }
}

// MARK: - scene-harvest (unfolded): late summer

extension PeasantBearArt {
    /// scene-harvest: stubble and standing sheaves; far off on the leading side the log
    /// house, the well pole and the village roofs with a thread of smoke; near, the Peasant
    /// with his sickle by the cart of sheaves and sacks, and the Bear in his heap of thin dry
    /// roots, holding one up. On a stump: a loaf and a basket of turnips.
    static func harvestScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let st = Kit.stage(size, ground: 150)
        let H: CGFloat = st.H
        let light = harvest()
        farPlane(&context, size, stage: st, light: light, sunX: 84, seed: 27)
        Art.group(&context, x: 236, y: H + 3, scale: 0.44 * st.far) { g in
            village(&g, light: light)
        }
        ArtStyle.atmosphere(&context, width: w, top: H - 84 * st.far, bottom: H + 4, color: light.haze, alpha: 0.2)

        let stubble: Kit.Stops = [(Art.color(0xEBD08A), 0), (Art.color(0xD2A648), 0.55), (Art.color(0xA97E2E), 1)]
        Kit.ground(&context, width: w, top: H, bottom: h, stops: stubble, seed: 31)
        Kit.furrows(&context, x0: -180, x1: w + 180, top: H + 6, bottom: h, color: 0xC99A3A, count: 16)
        let field = CGRect(x: 0, y: H + 10, width: w, height: max(1, st.depth - 10))
        Kit.grass(&context, in: field, count: 150, seed: 3, color: Art.color(0xF6E2A6), height: 6)
        Kit.grass(&context, in: field, count: 110, seed: 4, color: Art.color(0x9A7428, 0.8), height: 7)

        // Sheaves stood up in small stacks across the field, larger toward the reader.
        let stooks: [(CGFloat, CGFloat, CGFloat)] = [(60, 0.16, 26), (196, 0.1, 22), (330, 0.3, 38), (96, 0.52, 56), (404, 0.62, 66), (520, 0.12, 24)]
        for place in stooks {
            stook(&context, x: place.0, baseY: H + st.depth * place.1, height: place.2 * st.far)
        }
        if st.tall > 0.25 {
            // A tall window: full sacks and one more stack on the near stubble.
            stook(&context, x: 250, baseY: h - st.depth * 0.2, height: 120)
            Kit.sack(&context, cx: 372, baseY: h - st.depth * 0.12, width: 70, height: 84, color: 0xC8B088)
        }

        Kit.designSpace(&context, st) { v in
            Kit.nearSpace(&v, st, anchorX: 760) { n in
                harvestCast(&n, horizon: st.Hv)
            }
        }
        nearFrame(&context, size, stage: st, color: 0x7A6A2A)
        ArtStyle.finish(&context, size)
    }

    /// Three sheaves leaning together, standing on (x, baseY).
    static func stook(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, height tall: CGFloat) {
        Kit.sheaf(&context, cx: x - tall * 0.24, baseY: baseY - tall * 0.04, height: tall * 0.94, color: 0xD9A632)
        Kit.sheaf(&context, cx: x + tall * 0.24, baseY: baseY - tall * 0.04, height: tall * 0.94, color: 0xD9A632)
        Kit.sheaf(&context, cx: x, baseY: baseY, height: tall, color: ryeHex)
    }

    /// The forest edge and the cast of scene-harvest, in design units.
    static func harvestCast(_ n: inout GraphicsContext, horizon Hv: CGFloat) {
        forestEdge(&n, horizon: Hv, leaves: turningGreens(), bushes: Kit.summerGreens(), shift: 30)

        // The cart: golden sheaves stacked in it, full sacks at its wheel.
        let cartY: CGFloat = Hv + 84
        Kit.cart(&n, cx: 792, baseY: cartY, length: 150, color: cartHex, load: ryeHex)
        let topY: CGFloat = cartY - 89.4
        Kit.sheaf(&n, cx: 746, baseY: topY + 4, height: 74, color: ryeHex)
        Kit.sheaf(&n, cx: 838, baseY: topY + 4, height: 72, color: ryeHex)
        Kit.sheaf(&n, cx: 792, baseY: topY + 2, height: 86, color: 0xEBBE4A)
        Kit.sack(&n, cx: 724, baseY: Hv + 104, width: 46, height: 58, color: 0xC8B088)
        Kit.sack(&n, cx: 760, baseY: Hv + 110, width: 42, height: 52, color: 0xBFA67C)

        // The Peasant, sickle in hand: "I don't do it, Bear. The crop does."
        let manY: CGFloat = Hv + 90
        let p = peasantLook()
        let hand: CGPoint = Kit.hand(p, pose: .stand)
        Kit.shadow(&n, 676, manY, width: 58)
        Art.group(&n, x: 676, y: manY, scale: 0.95) { g in
            peasant(&g, pose: .stand, look: CGPoint(x: -0.6, y: 0.1), mouth: .grin)
            Kit.tool(&g, .sickle, x: hand.x - 1, baseY: hand.y + 10, height: 46, wood: 0x8A5A3A, metal: 0xB8C0C8)
            Art.fill(&g, Art.circle(hand.x, hand.y, 5.5), Art.color(p.skin))
        }

        // The Bear, up to his middle in his heap of roots, holds one up: thin and dry as string.
        let bearY: CGFloat = Hv + 104
        Kit.shadow(&n, 540, bearY, width: 130)
        Art.group(&n, x: 540, y: bearY, scale: 1.15, scaleX: -1) { b in
            bear(&b, pose: .rear, mood: .sad, look: CGPoint(x: -0.8, y: 0.4), brow: 1, sprig: .root, mirrored: true)
        }
        rootHeap(&n, cx: 540, baseY: Hv + 120, width: 184)

        // On a stump: a warm loaf of black bread and a basket of turnips.
        stumpGift(&n, x: 622, baseY: Hv + 130, scale: 0.9)
    }
}
