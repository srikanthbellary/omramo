import SwiftUI
import OmramoCore

// The four scenes of "The Horse and the Olive" as the picture band of a folded phone: 432 units
// wide and about 240…520 high. Each is its own composition for the band, not a crop of the wide
// scene: the pale Attic sky and the thin sea band behind (the shared `farPlane`, scaled by the
// band's unit), the bare limestone of the hilltop, the subject in the middle of the band with
// its face inside x 86…346, and dry grass and a boulder cropped at the bottom corners.

extension OliveArt {
    // MARK: Shared ground of the band

    /// The bare hilltop from the band's horizon down: limestone, cracks, pebbles, a tuft.
    static func foldedGround(_ context: inout GraphicsContext, _ size: CGSize, band b: Kit.Band, seed: UInt32) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let H: CGFloat = b.H
        let u: CGFloat = b.unit
        Kit.ground(&context, width: w, top: H, bottom: h, stops: rockStops(), seed: seed, tooth: Art.color(0xFFF6DC))
        rockCracks(&context, x0: -10, x1: w, top: H + 4, bottom: h, count: 12, seed: seed &+ 1, scale: u * 0.8)
        let field = CGRect(x: 0, y: H + 6, width: w, height: max(8, b.ground - 10))
        Kit.pebbles(&context, in: field, count: 16, seed: seed &+ 2, color: 0xCDBE9C)
        Kit.grassTuft(&context, x: 140, baseY: H + b.ground * 0.42, height: 20 * u, color: strawHex, seed: seed &+ 3)
        scrub(&context, x: 300, baseY: H + b.ground * 0.3, width: 30 * u, seed: seed &+ 4)
    }

    /// The dark near framing of the band: dry grass bottom-left, a cropped boulder bottom-right.
    static func foldedNear(_ context: inout GraphicsContext, _ size: CGSize, band b: Kit.Band) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let u: CGFloat = b.unit
        Kit.grassTuft(&context, x: 16, baseY: h + 4, height: 64 * u, color: 0x8A7A3E, seed: 3)
        Kit.grassTuft(&context, x: 54, baseY: h + 6, height: 40 * u, color: 0x9A8A46, seed: 8)
        Kit.rock(&context, cx: w - 20, baseY: h + 10 * u, width: 110 * u, height: 44 * u, color: 0x9A8A6A, seed: 6)
        Kit.grassTuft(&context, x: w - 78 * u, baseY: h + 4, height: 36 * u, color: 0x8A7A3E, seed: 12)
    }

    // MARK: scene-hill

    /// scene-hill (folded): the hilltop close up: two huts and the half-built stone wall, a man
    /// and a woman lifting one stone together in the middle, goats by the spring, pale sky above.
    static func hillFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let b = Kit.band(size, share: 0.3, least: 70, most: 150)
        let H: CGFloat = b.H
        let u: CGFloat = b.unit
        let light = day()
        farPlane(&context, size, horizon: H, far: u, light: light, seed: 14)
        Kit.cloud(&context, 300, H * 0.3 + 6, scale: 0.5 * u, color: Art.color(0xFFFFFF, 0.6))
        foldedGround(&context, size, band: b, seed: 21)

        // The wall, half built, on the leading side; two huts on the trailing side.
        Kit.fence(&context, x0: 24, x1: 150, baseY: H + 16 * u, height: 22 * u, color: 0xC4B79C, stone: true)
        Kit.fence(&context, x0: 150, x1: 186, baseY: H + 16 * u, height: 11 * u, color: 0xC4B79C, stone: true)
        hut(&context, cx: 318, baseY: H + 12 * u, width: 92 * u)
        hut(&context, cx: 404, baseY: H + 24 * u, width: 74 * u)

        // The spring with its bucket, and the goats.
        springPool(&context, cx: 82, cy: H + 48 * u, width: 76 * u)
        bucket(&context, x: 132, baseY: H + 50 * u, scale: 1.1 * u)
        let goatY: CGFloat = H + 34 * u
        Kit.shadow(&context, 44, goatY, width: 48 * u)
        Art.group(&context, x: 44, y: goatY, scale: 0.36 * u) { g in
            goat(&g, dark: true, pose: .stand, mood: .happy)
        }
        let goat2Y: CGFloat = H + 60 * u
        Kit.shadow(&context, 378, goat2Y, width: 44 * u)
        Art.group(&context, x: 378, y: goat2Y, scale: 0.34 * u, scaleX: -1) { g in
            goat(&g, dark: false, pose: .walk, mood: .calm, mirrored: true)
        }

        // A man and a woman lift one stone together.
        let s: CGFloat = 0.8 * u
        let feet: CGFloat = H + 44 * u
        let cx: CGFloat = 222
        let manX: CGFloat = cx - 55 * s
        let womanX: CGFloat = cx + 55 * s
        stone(&context, cx: cx, baseY: feet - 76 * s, width: 58 * s, seed: 7)
        Kit.shadow(&context, manX, feet, width: 64 * s)
        Art.group(&context, x: manX, y: feet, scale: s, scaleX: -1) { p in
            folk(&p, 4, pose: .carry, look: CGPoint(x: -0.5, y: 0.5), mouth: .smile, mirrored: true)
        }
        Kit.shadow(&context, womanX, feet, width: 64 * s)
        Art.group(&context, x: womanX, y: feet, scale: s) { p in
            folk(&p, 1, pose: .carry, look: CGPoint(x: -0.5, y: 0.5), mouth: .smile)
        }

        foldedNear(&context, size, band: b)
        ArtStyle.finish(&context, size)
    }

    // MARK: scene-gods

    /// scene-gods (folded): Poseidon with his trident and Athena with spear and shield side by
    /// side in the middle, faintly bronze-bright, the cloud throne above; the townspeople's
    /// heads and shoulders low in the band, as if we stood among them.
    static func godsFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let b = Kit.band(size, share: 0.26, least: 62, most: 136)
        let H: CGFloat = b.H
        let u: CGFloat = b.unit
        let light = day()
        farPlane(&context, size, horizon: H, far: u, light: light, seed: 16)
        cloudThrone(&context, cx: 236, baseY: H * 0.42, scale: 0.5 * u, light: light)
        foldedGround(&context, size, band: b, seed: 23)
        hut(&context, cx: 420, baseY: H + 6 * u, width: 80 * u)

        // The two gods, twice the people's height.
        let gs: CGFloat = 0.88 * u
        let feet: CGFloat = H + 30 * u
        Art.glow(&context, 216, feet - 110 * gs, 170 * gs, Art.color(0xFBE7B0), alpha: 0.45)
        let seaX: CGFloat = 216 - 52 * gs
        let wiseX: CGFloat = 216 + 44 * gs
        Kit.shadow(&context, seaX, feet, width: 70 * gs)
        Art.group(&context, x: seaX, y: feet, scale: gs) { p in
            poseidon(&p, pose: .stand, look: CGPoint(x: -0.3, y: 0.4), mouth: .grin, trident: true)
        }
        Kit.shadow(&context, wiseX + 6 * gs, feet, width: 80 * gs)
        Art.group(&context, x: wiseX, y: feet, scale: gs) { p in
            athena(&p, pose: .stand, look: CGPoint(x: -0.3, y: 0.4), mouth: .smile, armed: true)
        }

        // The two plain jars for the pebbles.
        Kit.pot(&context, cx: 296, baseY: feet + 12 * u, width: 22 * u, height: 28 * u, color: clayHex)
        Kit.pot(&context, cx: 320, baseY: feet + 15 * u, width: 22 * u, height: 28 * u, color: 0xB86E42)

        // The people, nearer and lower: heads and shoulders above the wave edge, looking up.
        let ps: CGFloat = 0.6 * u
        let low: CGFloat = b.floor + 60 * ps
        let up = CGPoint(x: -0.3, y: -0.9)
        placeFolk(&context, 0, x: 40, y: low, right: true, look: up, mouth: .oh, scale: ps)
        placeFolk(&context, 2, x: 96, y: low + 6 * u, right: true, look: up, mouth: .flat, scale: ps)
        Kit.shadow(&context, 150, low - 4 * u, width: 44 * ps)
        Art.group(&context, x: 150, y: low - 4 * u, scale: ps, scaleX: -1) { p in
            cecrops(&p, pose: .stand, look: CGPoint(x: -0.4, y: -0.8), mouth: .flat, mirrored: true)
        }
        placeFolk(&context, 3, x: 288, y: low - 8 * u, right: false, look: up, mouth: .oh, scale: ps)
        placeFolk(&context, 5, x: 340, y: low + 2 * u, right: false, look: up, mouth: .flat, scale: ps)
        placeFolk(&context, 4, x: 394, y: low + 8 * u, right: false, look: up, mouth: .flat, scale: ps)

        foldedNear(&context, size, band: b)
        ArtStyle.finish(&context, size)
    }

    // MARK: scene-horse

    /// scene-horse (folded): the white horse rearing in the middle of the band out of the
    /// cracked rock in a fan of spray; Poseidon's trident and bare arm at the trailing edge; a
    /// mother and her child falling back on the leading side; pale sky above.
    static func horseFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let b = Kit.band(size, share: 0.26, least: 62, most: 136)
        let H: CGFloat = b.H
        let u: CGFloat = b.unit
        let light = day()
        farPlane(&context, size, horizon: H, far: u, light: light, seed: 18)
        Kit.cloud(&context, 330, H * 0.26 + 6, scale: 0.5 * u, color: Art.color(0xFFFFFF, 0.6))
        let drift = CGRect(x: 40, y: H - 120 * u, width: 140, height: 90 * u)
        Kit.flecks(&context, in: drift, count: 8, seed: 19, color: Art.color(0xFFFFFF, 0.85), radius: 1.0...2.2)
        foldedGround(&context, size, band: b, seed: 25)
        Kit.fence(&context, x0: 70, x1: 150, baseY: H + 10 * u, height: 10 * u, color: 0xC4B79C, stone: true)
        hut(&context, cx: 46, baseY: H + 8 * u, width: 54 * u)

        // The split rock, the spray and the horse.
        let gapY: CGFloat = H + 34 * u
        Art.group(&context, x: 216, y: gapY, scale: 0.8 * u) { r in
            splitRock(&r)
        }
        sprayBurst(&context, cx: 216, baseY: gapY - 4, r: 118 * u)
        Kit.shadow(&context, 220, gapY + 2, width: 100 * u, alpha: 0.2)
        Art.group(&context, x: 222, y: gapY + 2, scale: u) { a in
            horse(&a, pose: .rear, mood: .happy, look: CGPoint(x: -0.4, y: -0.2))
        }
        let front = CGRect(x: 216 - 74 * u, y: gapY - 70 * u, width: 148 * u, height: 60 * u)
        Kit.flecks(&context, in: front, count: 14, seed: 27, color: Art.color(0xFFFFFF, 0.95), radius: 1.2...2.8)

        horseFoldedEdge(&context, gapY: gapY, unit: u)

        // A mother and her child fall back; the child hides behind her.
        let folkY: CGFloat = H + 40 * u
        placeFolk(&context, 3, x: 50, y: folkY - 4 * u, right: true, look: CGPoint(x: -0.6, y: -0.5), mouth: .oh, scale: 0.5 * u)
        placeFolk(&context, 1, x: 86, y: folkY, right: true, pose: .wave, look: CGPoint(x: -0.6, y: -0.6), mouth: .oh, scale: 0.55 * u)

        foldedNear(&context, size, band: b)
        ArtStyle.finish(&context, size)
    }

    /// Poseidon at the trailing edge of the horse band: only his deep-blue cloak, his bare arm
    /// and fist, and the trident planted where it struck, with a little spray round it.
    static func horseFoldedEdge(_ context: inout GraphicsContext, gapY: CGFloat, unit u: CGFloat) {
        let tx: CGFloat = 398
        let ty: CGFloat = gapY + 14 * u
        let lean: CGFloat = -0.12
        Art.group(&context, x: tx, y: ty, scale: u) { t in
            trident(&t, x: 0, y: 0, length: 170, lean: lean)
        }
        // Where the fist closes on the shaft, 110 units up it.
        let reach: CGFloat = 110 * u
        let handX: CGFloat = tx + sin(lean) * reach
        let handY: CGFloat = ty - cos(lean) * reach
        let skin: UInt32 = poseidonLook().skin
        let cloak: Path = Art.svg("M452,0 L424,40 L420,120 L452,120Z")
        let fold = CGAffineTransform(a: u, b: 0, c: 0, d: u, tx: -452 * u + 452, ty: handY - 30 * u)
        Kit.solid(&context, cloak.applying(fold), Art.color(0x1F5F8B), light: 0.2, shade: 0.3)
        var arm = Path()
        arm.move(to: CGPoint(x: 446, y: handY + 26 * u))
        arm.addQuadCurve(to: CGPoint(x: handX + 5 * u, y: handY + 1 * u), control: CGPoint(x: 424, y: handY + 4 * u))
        Art.stroke(&context, arm, Art.color(skin), width: 15 * u)
        Art.stroke(&context, arm, Kit.personTone(skin, 1.2).opacity(0.5), width: 4 * u)
        let fist: Path = Art.ellipse(handX + 2 * u, handY, 9 * u, 8 * u)
        Kit.solid(&context, fist, Art.color(skin), light: 0.3, shade: 0.24)
        spray(&context, in: CGRect(x: 356, y: handY - 64 * u, width: 76, height: 80 * u), seed: 41)
    }

    // MARK: scene-olive

    /// scene-olive (folded): the young olive tree in the middle, silver undersides showing,
    /// Athena kneeling beside it with one olive on her palm and the small girl reaching up to a
    /// fruit; her shield set down behind, her spear laid in front; pale gold sky above.
    static func oliveFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let b = Kit.band(size, share: 0.26, least: 62, most: 136)
        let H: CGFloat = b.H
        let u: CGFloat = b.unit
        let light = gold()
        farPlane(&context, size, horizon: H, far: u, light: light, seed: 20)
        Kit.sun(&context, 56, H - 34 * u, 12 * u, light: light)
        Kit.cloud(&context, 330, H * 0.28 + 6, scale: 0.5 * u, color: Art.color(0xFFFFFF, 0.6))
        foldedGround(&context, size, band: b, seed: 27)

        let ts: CGFloat = 0.95 * u
        let base: CGFloat = H + 28 * u
        let treeX: CGFloat = 196
        shield(&context, cx: 396, cy: base - 30 * ts, r: 30 * ts)
        Art.group(&context, x: treeX, y: base, scale: ts) { t in
            oliveTree(&t, fruit: true, seed: 7)
        }

        // Athena kneels beside it and holds out one olive on her palm.
        let lady = athenaLook()
        let palm: CGPoint = Kit.hand(lady, pose: .kneel)
        let ax: CGFloat = treeX + 104 * ts
        let aScale: CGFloat = 1.5 * ts
        Kit.shadow(&context, ax + 4 * ts, base + 4 * ts, width: 120 * ts)
        Art.group(&context, x: ax, y: base + 4 * ts, scale: aScale) { p in
            athena(&p, pose: .kneel, look: CGPoint(x: -0.6, y: 0.2), mouth: .smile)
            olive(&p, x: palm.x - 1, y: palm.y - 8, r: 4.6, ripe: false)
        }

        // The small girl reaches up to a fruit.
        let girl = folkLook(3)
        let hand: CGPoint = Kit.hand(girl, pose: .reach)
        let gx: CGFloat = treeX - 50 * ts
        let gy: CGFloat = base + 14 * ts
        let gScale: CGFloat = 0.8 * ts
        Kit.shadow(&context, gx, gy, width: 40 * ts)
        Art.group(&context, x: gx, y: gy, scale: gScale, scaleX: -1) { p in
            folk(&p, 3, pose: .reach, look: CGPoint(x: -0.5, y: -0.8), mouth: .smile, mirrored: true)
            olive(&p, x: hand.x - 2, y: hand.y - 9, r: 6, ripe: false)
        }

        // Her spear, laid down on the rock in front.
        Art.group(&context, x: 60, y: base + 14 * u, scale: ts) { s in
            spear(&s, x: 0, y: 0, length: 200, lean: Kit.deg(87))
        }

        foldedNear(&context, size, band: b)
        ArtStyle.finish(&context, size)
    }
}
