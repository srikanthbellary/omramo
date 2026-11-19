import SwiftUI
import OmramoCore

/// Concept art for "The Eloquent Peasant", drawn in code (round 5; composed from the shared kit).
/// Middle Kingdom Egypt: salt white and sand gold under wide pale skies, barley green and the
/// slow blue of the Nile in the lower third. Advanced tier: text in the top of both panes, so
/// every unfolded scene keeps a low horizon and a calm pale sky across the whole width.
enum EloquentArt {
    /// Draws the picture called `name`. Returns false for a name this story does not have.
    static func paint(_ name: String, role: ArtRole, in context: inout GraphicsContext, size: CGSize) -> Bool {
        guard size.width > 0, size.height > 0 else { return false }
        switch (name, role) {
        case ("scene-oasis", .sceneUnfolded): oasisScene(&context, size)
        case ("scene-oasis", .sceneFolded): oasisFolded(&context, size)
        case ("scene-path", .sceneUnfolded): pathScene(&context, size)
        case ("scene-path", .sceneFolded): pathFolded(&context, size)
        case ("scene-river", .sceneUnfolded): riverScene(&context, size)
        case ("scene-river", .sceneFolded): riverFolded(&context, size)
        case ("scene-hall", .sceneUnfolded): hallScene(&context, size)
        case ("scene-hall", .sceneFolded): hallFolded(&context, size)
        case ("see-salt-field", .picture): saltFieldPicture(&context, size)
        case ("see-donkey-caravan", .picture): donkeyPicture(&context, size)
        case ("see-maat", .picture): maatPicture(&context, size)
        case ("see-scribe", .picture): scribePicture(&context, size)
        case ("char-khunanup", .portrait): khunanupPortrait(&context, size)
        case ("char-rensi", .portrait): rensiPortrait(&context, size)
        case ("face-khunanup", .face): khunanupFace(&context, size)
        case ("face-rensi", .face): rensiFace(&context, size)
        case ("face-nemtynakht", .face): nemtynakhtFace(&context, size)
        case ("cover", .cover): cover(&context, size)
        default:
            return false
        }
        return true
    }

    /// The size of the figures in the unfolded scenes (an adult 121 tall) and of the donkeys.
    static let figure: CGFloat = 0.72
    static let donkeyScale: CGFloat = 0.56
}

// MARK: - Scene 1: the Salt Field (early morning, white-gold)

extension EloquentArt {
    static func oasisScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 220)
        let light = morning()
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.sun(&context, 120, st.H - 30 * st.far, 14 * st.far, light: light)
        Kit.cloud(&context, 640, st.H - 150 * st.far, scale: 0.9 * st.far, color: Art.color(0xFFFFFF, 0.5))
        Kit.ranges(&context, width: size.width, horizon: st.H, scale: st.far, light: light, mountains: false, seed: 11)
        let farGreen: Color = Art.color(0xA8B496)
        let farPalms: [(CGFloat, CGFloat, CGFloat)] = [(262, 40, -4), (284, 50, 5), (546, 36, 3)]
        for palm in farPalms {
            farPalm(&context, x: palm.0, baseY: st.H + 2, height: palm.1 * st.far, color: farGreen, lean: palm.2 * st.far)
        }
        ArtStyle.atmosphere(&context, width: size.width, top: st.H - 70 * st.far, bottom: st.H + 4, color: light.haze, alpha: 0.3)
        let sand: Kit.Stops = Kit.stops(0xEFE2C2, sandHex, sandDeepHex)
        Kit.ground(&context, width: size.width, top: st.H, bottom: size.height, stops: sand, seed: 41)
        Kit.designSpace(&context, st) { v in
            oasisMiddle(&v, st)
            Kit.nearSpace(&v, st, anchorX: 640) { n in
                oasisGroup(&n, st)
            }
            oasisNear(&v, st)
        }
        ArtStyle.finish(&context, size, wash: 0.08, vignette: 0.06)
    }

    /// The lake with its crust of salt, reeds at the water, two palms on the far bank.
    static func oasisMiddle(_ v: inout GraphicsContext, _ st: Kit.Stage) {
        let Y: CGFloat = st.Hv
        saltLake(&v, x0: -460, x1: 720, top: Y + 8, depth: 50, seed: 5)
        Kit.palm(&v, x: 318, baseY: Y + 14, height: 78, lean: -9, fronds: 0x7E9C72, trunk: 0xA08A70, seed: 2)
        Kit.palm(&v, x: 350, baseY: Y + 12, height: 64, lean: 7, fronds: 0x86A27A, trunk: 0xA08A70, seed: 3)
        Kit.reeds(&v, x: 150, baseY: Y + 34, count: 5, height: 34, seed: 3, color: 0x7A9458)
        Kit.reeds(&v, x: 430, baseY: Y + 36, count: 4, height: 30, seed: 4, color: 0x7A9458)
        Kit.reeds(&v, x: -120, baseY: Y + 32, count: 6, height: 36, seed: 6, color: 0x7A9458)
        // Gravel and a few stones on the sand between the lake and us.
        Kit.pebbles(&v, in: CGRect(x: -300, y: Y + 64, width: 1300, height: 40), count: 26, seed: 12, color: 0xBBA584)
    }

    /// The house, the palms leaning over it, the family at the door, the donkeys and Khunanup.
    static func oasisGroup(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let Y: CGFloat = st.Hv
        let s: CGFloat = figure
        let d: CGFloat = donkeyScale
        Kit.palm(&n, x: 742, baseY: Y + 50, height: 156, lean: -24, fronds: palmHex, trunk: palmTrunkHex, seed: 7)
        Kit.palm(&n, x: 858, baseY: Y + 46, height: 138, lean: 16, fronds: palmHex, trunk: palmTrunkHex, seed: 8)
        mudHouse(&n, cx: 800, baseY: Y + 70, width: 124, height: 84)
        Kit.pot(&n, cx: 727, baseY: Y + 76, width: 22, height: 30, color: 0xB5683A)
        Kit.sack(&n, cx: 704, baseY: Y + 98, width: 20, height: 24, color: 0xCDB68A)
        // His wife in the doorway, the two children beside her, watching him go.
        Art.group(&n, x: 760, y: Y + 82, scale: s * 0.9) { g in child(&g, girl: true) }
        Art.group(&n, x: 792, y: Y + 80, scale: s * 0.9) { g in wife(&g, mouth: .flat, look: CGPoint(x: -0.6, y: 0)) }
        Art.group(&n, x: 828, y: Y + 84, scale: s * 0.9) { g in child(&g, girl: false) }
        // The donkeys, loaded and waiting, heads toward the valley road.
        Art.group(&n, x: 352, y: Y + 92, scale: d) { g in donkey(&g, pack: 1) }
        Art.group(&n, x: 470, y: Y + 96, scale: d) { g in donkey(&g, pack: 2) }
        Art.group(&n, x: 592, y: Y + 100, scale: d) { g in donkey(&g, pack: 1, mood: .sleepy) }
        // Khunanup tying the net of salt on the last one.
        Art.group(&n, x: 642, y: Y + 106, scale: s) { g in
            khunanup(&g, pose: .reach, mouth: .flat, look: CGPoint(x: -0.6, y: 0.3), stick: false)
        }
        Art.group(&n, x: 676, y: Y + 108, scale: s) { g in
            // His stick laid against the sack while he works.
            Art.stroke(&g, Art.line(30, -2, 46, -78), Art.color(0x8A6440), width: 3.4)
        }
    }

    /// The near plane: a strip of cracked salt crust, reeds in the corners, gravel; on a tall
    /// window, more crust and stones down the deeper ground.
    static func oasisNear(_ v: inout GraphicsContext, _ st: Kit.Stage) {
        let Y: CGFloat = st.Hv
        let hv: CGFloat = st.hv
        if st.tall > 0.25 {
            saltLake(&v, x0: -300, x1: 520, top: Y + 168, depth: 70, seed: 21)
            Kit.pebbles(&v, in: CGRect(x: -200, y: Y + 250, width: 1100, height: max(10, hv - Y - 290)), count: 40, seed: 14, color: 0xB09A78)
            Kit.grass(&v, in: CGRect(x: 520, y: Y + 200, width: 360, height: max(10, hv - Y - 240)), count: 18, seed: 15, color: Art.color(0x8E9A5E), height: 12)
        }
        let strip = Art.rect(-500, hv - 54, 900, 40, radius: 20)
        Art.fill(&v, strip, Art.color(saltHex, 0.85))
        let cracks: Path = Kit.placed("M-60,-36 l14,3 l10,-2 M40,-30 l12,2 l8,-3 M150,-34 l10,3 l12,-1 M250,-28 l14,2", x: 0, y: hv)
        Art.stroke(&v, cracks, Art.color(0xC9B2A4, 0.7), width: 1)
        Kit.reeds(&v, x: 36, baseY: hv + 8, count: 7, height: 120, seed: 9, color: 0x5E7E44)
        Kit.reeds(&v, x: 884, baseY: hv + 10, count: 5, height: 96, seed: 10, color: 0x5E7E44)
        Kit.grassTuft(&v, x: 120, baseY: hv - 8, height: 40, color: 0x7A8E4E, seed: 4)
    }
}

// MARK: - Scene 2: the raised path between the canal and the barley (pale gold morning)

extension EloquentArt {
    static func pathScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 220)
        let light = goldMorning()
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.sun(&context, 96, st.H - 34 * st.far, 13 * st.far, light: light)
        Kit.cloud(&context, 300, st.H - 190 * st.far, scale: 0.7 * st.far, color: Art.color(0xFFFFFF, 0.45))
        Kit.ranges(&context, width: size.width, horizon: st.H, scale: st.far * 0.8, light: light, mountains: false, seed: 23)
        // A far line of palms along the valley.
        var random = ArtRandom(31)
        let farTone: Color = Art.color(0x9DAA7A, 0.85)
        for index in 0..<11 {
            let jitter: CGFloat = Kit.rnd(&random) * 30
            let x: CGFloat = 20 + CGFloat(index) * 84 + jitter
            let h: CGFloat = (30 + Kit.rnd(&random) * 16) * st.far
            farPalm(&context, x: x, baseY: st.H + 2, height: h, color: farTone, lean: (Kit.rnd(&random) - 0.5) * 8)
        }
        ArtStyle.atmosphere(&context, width: size.width, top: st.H - 60 * st.far, bottom: st.H + 4, color: light.haze, alpha: 0.32)
        let fields: Kit.Stops = Kit.stops(0xC2CB92, 0xA3B670, 0x86A259)
        Kit.ground(&context, width: size.width, top: st.H, bottom: size.height, stops: fields, seed: 43)
        Kit.designSpace(&context, st) { v in
            // The path carries the figures, so it grows with them on a tall window.
            Kit.nearSpace(&v, st, anchorX: 620) { n in
                pathMiddle(&n, st)
                pathEstate(&n, st)
                pathGroup(&n, st)
                Kit.grainField(&n, x0: -500, x1: 1400, baseY: st.Hv + 134, height: 40, color: barleyHex, seed: 3)
            }
            pathNear(&v, st)
        }
        ArtStyle.finish(&context, size, wash: 0.08, vignette: 0.06)
    }

    /// The square fields of the valley, the straight canal and the raised earth path.
    static func pathMiddle(_ v: inout GraphicsContext, _ st: Kit.Stage) {
        let Y: CGFloat = st.Hv
        // Square fields toward the river: barley, emmer and blue-flowered flax.
        let tones: [UInt32] = [0x9DB46A, 0xB5C27E, 0x8FAA5E, 0xA9B887]
        for index in 0..<12 {
            let x0: CGFloat = -500 + CGFloat(index) * 160
            let field = Art.polygon([
                CGPoint(x: x0 + 8, y: Y + 4), CGPoint(x: x0 + 150, y: Y + 4),
                CGPoint(x: x0 + 156, y: Y + 30), CGPoint(x: x0, y: Y + 30),
            ])
            Art.fill(&v, field, Art.color(tones[index % 4]))
        }
        Kit.flowers(&v, in: CGRect(x: 140, y: Y + 8, width: 150, height: 18), count: 20, seed: 7, petal: 0x8FA6E0, heart: 0xE9C46A)
        // The canal, straight as a ruled line.
        let canal = Art.rect(-500, Y + 32, 1900, 18)
        let water: Kit.Stops = [(Art.color(0xB8D0D6), 0), (Art.color(nileHex), 1)]
        Art.fillLinear(&v, canal, water, from: CGPoint(x: 0, y: Y + 32), to: CGPoint(x: 0, y: Y + 50))
        Kit.rippleMarks(&v, x0: -300, x1: 900, y0: Y + 35, y1: Y + 48, count: 26, seed: 9, color: Color.white, alpha: 0.5)
        Art.fill(&v, Art.rect(-500, Y + 30, 1900, 2.5), Art.color(0x8E8460, 0.5))
        Kit.reeds(&v, x: 90, baseY: Y + 52, count: 4, height: 30, seed: 5, color: 0x6F8F4E, papyrus: true)
        Kit.reeds(&v, x: 330, baseY: Y + 52, count: 3, height: 26, seed: 8, color: 0x6F8F4E)
        // The raised path along it.
        let path = Art.rect(-500, Y + 50, 1900, 40)
        let earth: Kit.Stops = [(Art.color(0xE6D3A6), 0), (Art.color(0xD6BE8C), 1)]
        Art.fillLinear(&v, path, earth, from: CGPoint(x: 0, y: Y + 50), to: CGPoint(x: 0, y: Y + 90))
        ArtStyle.tooth(&v, in: CGRect(x: -300, y: Y + 52, width: 1300, height: 36), seed: 17, color: Art.color(0x8A6A42), alpha: 0.12)
        Art.fill(&v, Art.rect(-500, Y + 90, 1900, 10), Art.color(0xB49464))
        Art.fill(&v, Art.rect(-500, Y + 50, 1900, 2), Art.color(0xFFF3D8, 0.6))
    }

    /// Nemtynakht's estate: whitewashed house, garden wall and gate, palms behind the wall.
    static func pathEstate(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let Y: CGFloat = st.Hv
        Kit.palm(&n, x: 690, baseY: Y + 26, height: 130, lean: -18, fronds: palmHex, trunk: palmTrunkHex, seed: 11)
        Kit.palm(&n, x: 900, baseY: Y + 24, height: 124, lean: 14, fronds: palmHex, trunk: palmTrunkHex, seed: 12)
        Kit.house(&n, cx: 800, baseY: Y + 40, width: 150, wallHeight: 80, roofHeight: 8, wall: 0xF6F0E2, roof: 0xC8B48C, style: .flat, door: 0x6A4A32, windows: 2)
        Kit.acacia(&n, x: 612, baseY: Y + 36, height: 70, spread: 80, palette: Kit.oliveGreens(), bark: 0x5A4632)
        Kit.longWall(&n, x0: 600, x1: 1300, baseY: Y + 56, height: 38, color: 0xEFE6D2)
        Kit.gateway(&n, cx: 640, baseY: Y + 58, width: 44, height: 52, color: 0xE6DAC2)
    }

    /// The donkeys halted in a line, Khunanup at the front, the cloth across the whole path,
    /// Nemtynakht beside it with his switch.
    static func pathGroup(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let Y: CGFloat = st.Hv
        let s: CGFloat = figure
        let d: CGFloat = donkeyScale
        fringedCloth(&n, x0: 578, x1: 642, y: Y + 54, depth: 33, skew: 8)
        Art.group(&n, x: 268, y: Y + 80, scale: d, scaleX: -1) { g in donkey(&g, pack: 1, mirrored: true) }
        Art.group(&n, x: 376, y: Y + 82, scale: d, scaleX: -1) { g in donkey(&g, pack: 2, mirrored: true) }
        Art.group(&n, x: 556, y: Y + 66, scale: s, scaleX: -1) { g in
            khunanup(&g, pose: .stand, mouth: .oh, look: CGPoint(x: -0.5, y: 0.2), mirrored: true)
        }
        Art.group(&n, x: 490, y: Y + 86, scale: d, scaleX: -1) { g in donkey(&g, pack: 1, mood: .surprised, mirrored: true) }
        Art.group(&n, x: 694, y: Y + 78, scale: s) { g in
            nemtynakht(&g, mouth: .smile, look: CGPoint(x: -0.5, y: 0.1))
        }
    }

    /// Barley standing in front of the path, a tuft in each corner; on a tall window more
    /// rows of barley and a field ditch running toward us.
    static func pathNear(_ v: inout GraphicsContext, _ st: Kit.Stage) {
        let Y: CGFloat = st.Hv
        let hv: CGFloat = st.hv
        let lift: CGFloat = 46 * st.grow
        Kit.grainField(&v, x0: -500, x1: 1400, baseY: Y + 180 * st.grow, height: 50, color: 0x76994F, seed: 4)
        if st.tall > 0.25 {
            let rows: Int = Int((hv - Y - 180 * st.grow) / 60)
            for index in 0..<max(0, min(6, rows)) {
                let baseY: CGFloat = Y + 180 * st.grow + lift + CGFloat(index) * 60
                let tone: UInt32 = index % 2 == 0 ? 0x6E914A : 0x82A257
                Kit.grainField(&v, x0: -500, x1: 1400, baseY: baseY, height: 56, color: tone, seed: UInt32(index + 5))
            }
        }
        Kit.grainField(&v, x0: -500, x1: 1400, baseY: hv + 4, height: 46, color: 0x5F8442, seed: 9)
        Kit.grassTuft(&v, x: 40, baseY: hv, height: 70, color: 0x557A3E, seed: 2)
        Kit.grassTuft(&v, x: 870, baseY: hv + 2, height: 62, color: 0x557A3E, seed: 3)
    }
}

// MARK: - Scene 3: the river landing at Herakleopolis (pale rose-gold afternoon)

extension EloquentArt {
    static func riverScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 220)
        let light = afternoon()
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.sun(&context, 170, st.H - 28 * st.far, 14 * st.far, light: light)
        Kit.cloud(&context, 700, st.H - 170 * st.far, scale: 0.8 * st.far, color: Art.color(0xFFFFFF, 0.4))
        riverFar(&context, st, light)
        let water: Kit.Stops = Kit.stops(0xD8DCD8, 0xA9C4CA, 0x80A6B4)
        Kit.water(&context, width: size.width, top: st.H, bottom: size.height, stops: water, light: light, ripples: 46, seed: 33)
        Kit.glints(&context, x: 170, top: st.H, depth: st.depth * 0.7, color: Art.color(0xFFF2DA), count: 34, seed: 8)
        Kit.designSpace(&context, st) { v in
            Kit.nearSpace(&v, st, anchorX: 700) { n in
                riverBankLeft(&n, st)
                riverLanding(&n, st)
            }
            riverNear(&v, st)
        }
        ArtStyle.finish(&context, size, wash: 0.08, vignette: 0.06)
    }

    /// Faint desert cliffs, the far bank with its green fields and palms, a far sail.
    static func riverFar(_ context: inout GraphicsContext, _ st: Kit.Stage, _ light: Kit.Light) {
        let w: CGFloat = st.w
        let H: CGFloat = st.H
        let s: CGFloat = st.far
        var cliffs = Path()
        cliffs.move(to: CGPoint(x: 0, y: H + 4))
        cliffs.addLine(to: CGPoint(x: 0, y: H - 30 * s))
        cliffs.addLine(to: CGPoint(x: w * 0.3, y: H - 34 * s))
        cliffs.addQuadCurve(to: CGPoint(x: w * 0.42, y: H - 22 * s), control: CGPoint(x: w * 0.38, y: H - 34 * s))
        cliffs.addLine(to: CGPoint(x: w * 0.62, y: H - 26 * s))
        cliffs.addQuadCurve(to: CGPoint(x: w * 0.7, y: H - 40 * s), control: CGPoint(x: w * 0.64, y: H - 40 * s))
        cliffs.addLine(to: CGPoint(x: w, y: H - 38 * s))
        cliffs.addLine(to: CGPoint(x: w, y: H + 4))
        cliffs.closeSubpath()
        Art.fill(&context, cliffs, light.far)
        Art.fill(&context, Art.rect(0, H - 12 * s, w, 14 * s), Art.color(0xC9C0A0))
        ArtStyle.atmosphere(&context, width: w, top: H - 60 * s, bottom: H + 2, color: light.haze, alpha: 0.4)
        Art.fill(&context, Art.rect(0, H - 8 * s, w, 9 * s), light.mid)
        let palmTone: Color = Art.color(0x8E9E6E)
        var random = ArtRandom(52)
        for index in 0..<9 {
            let x: CGFloat = 40 + CGFloat(index) * 100 + Kit.rnd(&random) * 40
            let h: CGFloat = (22 + Kit.rnd(&random) * 12) * s
            farPalm(&context, x: x, baseY: H - 4 * s, height: h, color: palmTone, lean: (Kit.rnd(&random) - 0.5) * 6)
        }
        // A far boat under sail, small and pale.
        let mast: Path = Art.svg("M0,0 L0,-26 M-10,-24 L10,-24")
        Art.group(&context, x: 330, y: H + 6 * s, scale: s) { g in
            Art.fill(&g, Art.svg("M-14,0 Q0,5 14,0 L11,-3 L-11,-3Z"), Art.color(0x9A8A72))
            Art.fill(&g, Art.svg("M-9,-23 L9,-23 L8,-6 L-8,-6Z"), Art.color(0xF6EEE2, 0.85))
            Art.stroke(&g, mast, Art.color(0x8A7A62), width: 1)
        }
    }

    /// Our bank on the left: green fields along the water, and small on the path a man
    /// leading loaded donkeys away north (the last page).
    static func riverBankLeft(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let Y: CGFloat = st.Hv
        var bank = Path()
        bank.move(to: CGPoint(x: -600, y: Y + 30))
        bank.addLine(to: CGPoint(x: 300, y: Y + 34))
        bank.addQuadCurve(to: CGPoint(x: 420, y: Y + 58), control: CGPoint(x: 400, y: Y + 36))
        bank.addQuadCurve(to: CGPoint(x: 330, y: Y + 74), control: CGPoint(x: 410, y: Y + 72))
        bank.addLine(to: CGPoint(x: -600, y: Y + 80))
        bank.closeSubpath()
        Kit.solid(&n, bank, stops: Kit.stops(0xBFC48C, 0x9CB06A), light: 0.18, shade: 0.14)
        Kit.grainField(&n, x0: -600, x1: 330, baseY: Y + 46, height: 14, color: 0xB4B060, seed: 13)
        Art.fill(&n, Art.rect(-600, Y + 47, 930, 7, radius: 3), Art.color(0xDCC79A))
        Kit.palm(&n, x: 70, baseY: Y + 38, height: 74, lean: -6, fronds: 0x6E8E5E, trunk: 0x9A7E62, seed: 4)
        Kit.palm(&n, x: 98, baseY: Y + 36, height: 60, lean: 6, fronds: 0x76966A, trunk: 0x9A7E62, seed: 6)
        let far: CGFloat = figure * 0.42
        Art.group(&n, x: 226, y: Y + 53, scale: far * 0.78) { g in donkey(&g, pack: 3) }
        Art.group(&n, x: 272, y: Y + 53, scale: far * 0.78) { g in donkey(&g, pack: 3) }
        Art.group(&n, x: 190, y: Y + 53, scale: far) { g in
            khunanup(&g, pose: .walk, mouth: .smile)
        }
        Kit.reeds(&n, x: 396, baseY: Y + 66, count: 4, height: 26, seed: 3, color: 0x6F8F4E, papyrus: true)
    }

    /// The stone landing with Rensi's boat tied at the steps, Rensi and his officials above.
    static func riverLanding(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let Y: CGFloat = st.Hv
        let s: CGFloat = figure
        landing(&n, x0: 662, x1: 1100, top: Y + 64, waterY: Y + 104, bottom: st.hv + 40)
        Art.group(&n, x: 708, y: Y + 64, scale: s) { g in
            rensi(&g, seated: false, mouth: .flat, look: CGPoint(x: -0.4, y: 0))
        }
        Art.group(&n, x: 776, y: Y + 62, scale: s) { g in official(&g, variant: 1) }
        Art.group(&n, x: 838, y: Y + 64, scale: s) { g in official(&g, variant: 2) }
        stewardBoat(&n, cx: 520, waterY: Y + 108, length: 236)
        // The mooring rope from the post to the stern.
        var rope = Path()
        rope.move(to: CGPoint(x: 674, y: Y + 52))
        rope.addQuadCurve(to: CGPoint(x: 630, y: Y + 40), control: CGPoint(x: 650, y: Y + 58))
        Art.stroke(&n, rope, Art.color(ropeHex), width: 1.6)
        Kit.ripples(&n, 520, Y + 112, 200, count: 2)
    }

    /// Near papyrus at the left corner, blue lotus pads on the water; on a tall window more
    /// pads and the long reflection of the boat.
    static func riverNear(_ v: inout GraphicsContext, _ st: Kit.Stage) {
        let Y: CGFloat = st.Hv
        let hv: CGFloat = st.hv
        let pads: [(CGFloat, CGFloat, CGFloat)] = [(250, Y + 150, 15), (318, Y + 172, 11), (120, Y + 190, 18)]
        for pad in pads {
            Kit.lilyPad(&v, cx: pad.0, cy: pad.1, r: pad.2, pad: 0x4E8A5A)
        }
        blueLotus(&v, x: 248, y: Y + 148, size: 10)
        blueLotus(&v, x: 118, y: Y + 186, size: 12)
        if st.tall > 0.25 {
            let more: [(CGFloat, CGFloat, CGFloat)] = [(380, Y + 290, 20), (200, Y + 330, 24), (470, Y + 360, 16)]
            for pad in more {
                Kit.lilyPad(&v, cx: pad.0, cy: pad.1, r: pad.2, pad: 0x4E8A5A)
            }
            blueLotus(&v, x: 198, y: Y + 326, size: 14)
            Kit.swells(&v, width: 892, top: Y + 220, bottom: hv, rows: 5, crest: Color.white, seed: 4)
        }
        Kit.reeds(&v, x: 40, baseY: hv + 10, count: 8, height: 150, seed: 12, color: 0x4E7A44, papyrus: true)
    }

    /// The blue lotus (the cool note of the palette): a pointed blue flower on the water.
    static func blueLotus(_ g: inout GraphicsContext, x: CGFloat, y: CGFloat, size: CGFloat) {
        let back: Path = Art.svg("M0,0 L-6,-9 L-2,-1 Z M0,0 L0,-12 L2,-1Z M0,0 L6,-9 L2,-1Z")
        let front: Path = Art.svg("M0,0 L-4,-8 L0,-2 L4,-8 Z")
        Art.group(&g, x: x, y: y, scale: size / 10) { f in
            Art.fill(&f, back, Art.color(0x6F8FD6))
            Art.fill(&f, front, Art.color(0xB8C9F2))
            Art.fill(&f, Art.ellipse(0, -1, 2, 1.2), Art.color(0xE9C46A))
        }
    }
}

// MARK: - Scene 4: Rensi's courtyard (soft cream daylight)

extension EloquentArt {
    static func hallScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 220)
        let light = courtyard()
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.cloud(&context, 560, st.H - 230 * st.far, scale: 0.8 * st.far, color: Art.color(0xFFFFFF, 0.45))
        let floor: Kit.Stops = Kit.stops(0xEFE3CB, 0xE2D1B0, 0xD2BC96)
        Kit.ground(&context, width: size.width, top: st.H, bottom: size.height, stops: floor, seed: 47, tooth: Art.color(0xFFFFFF))
        Kit.designSpace(&context, st) { v in
            hallWalls(&v, st)
            Kit.nearSpace(&v, st, anchorX: 700) { n in
                hallGroup(&n, st)
            }
            hallNear(&v, st)
        }
        ArtStyle.finish(&context, size, wash: 0.08, vignette: 0.06)
    }

    /// The courtyard's pale plastered wall with its painted dado, the gate, two pigeons on the
    /// coping, and the portico of lotus-bud columns on the trailing side.
    static func hallWalls(_ v: inout GraphicsContext, _ st: Kit.Stage) {
        let Y: CGFloat = st.Hv
        let wall = CGRect(x: -600, y: Y - 116, width: 2000, height: 118)
        Kit.wall(&v, rect: wall, color: plasterHex)
        let coping = Art.rect(-600, Y - 122, 2000, 8, radius: 3)
        Kit.solid(&v, coping, Art.color(plasterShadeHex), light: 0.24, shade: 0.2)
        let dado: [(UInt32, CGFloat)] = [(0xC8553D, 30), (0x2F6F9E, 24), (0x3FA27A, 18)]
        for band in dado {
            Art.fill(&v, Art.rect(-600, Y - band.1, 2000, 4), Art.color(band.0, 0.5))
        }
        Kit.gateway(&v, cx: 236, baseY: Y + 2, width: 74, height: 98, color: 0xE6D8BE)
        // The portico: its shade, the beam, the columns.
        let shade = Art.rect(476, Y - 196, 1000, 198)
        Art.fill(&v, shade, Art.color(plasterShadeHex, 0.75))
        Art.fill(&v, Art.rect(476, Y - 196, 1000, 26), ArtStyle.coolShade.opacity(0.06))
        let beam = Art.rect(470, Y - 210, 1000, 16, radius: 2)
        Kit.solid(&v, beam, Art.color(0xEDE2CC), light: 0.24, shade: 0.18)
        Art.fill(&v, Art.rect(470, Y - 198, 1000, 2.4), Art.color(0x2F6F9E, 0.3))
        let columns: [CGFloat] = [540, 700, 860]
        for cx in columns {
            // The painted ties stay faint: they stand behind the trailing words.
            budColumn(&v, cx: cx, baseY: Y + 6, width: 26, height: 212, color: 0xEDE1C8, paint: 0.22)
        }
    }

    /// Rensi silent on his lion chair, the scribe on his mat with the roll spilling across the
    /// floor, Khunanup standing before them with one hand raised, two officials behind.
    static func hallGroup(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let Y: CGFloat = st.Hv
        let s: CGFloat = figure
        Art.group(&n, x: 852, y: Y + 40, scale: s * 0.92) { g in official(&g, variant: 0) }
        Art.group(&n, x: 900, y: Y + 44, scale: s * 0.92) { g in official(&g, variant: 1) }
        reedMat(&n, cx: 556, y: Y + 108, width: 100)
        Art.group(&n, x: 806, y: Y + 94, scale: s) { g in
            rensi(&g, seated: true, mouth: .flat, look: CGPoint(x: -0.6, y: 0))
        }
        Art.group(&n, x: 682, y: Y + 104, scale: s) { g in
            scribe(&g)
        }
        Art.group(&n, x: 560, y: Y + 108, scale: s, scaleX: -1) { g in
            khunanup(&g, pose: .wave, mouth: .open, look: CGPoint(x: -0.4, y: -0.1), mirrored: true)
        }
        // The roll runs from the scribe's knees down across the floor in front of them.
        var spill = Path()
        spill.move(to: CGPoint(x: 664, y: Y + 82))
        spill.addLine(to: CGPoint(x: 676, y: Y + 82))
        spill.addLine(to: CGPoint(x: 660, y: Y + 118))
        spill.addLine(to: CGPoint(x: 648, y: Y + 118))
        spill.closeSubpath()
        Art.fill(&n, spill, Art.color(0xEFE0B8))
        papyrusRun(&n, x0: 330, x1: 660, y: Y + 118, depth: 9)
        // A loaf and a jug of beer left by the gate for him (the hidden kindness).
        Kit.pot(&n, cx: 300, baseY: Y + 46, width: 14, height: 22, color: 0xB0703E)
        let loaf = Art.ellipse(318, Y + 43, 8, 4)
        Kit.solid(&n, loaf, Art.color(0xD9A860), light: 0.3, shade: 0.24)
    }

    /// Big storage jars cropped in the near left corner, the shade of the roof on the near
    /// floor; on a tall window, the papyrus runs on and mats lie on the deeper floor.
    static func hallNear(_ v: inout GraphicsContext, _ st: Kit.Stage) {
        let Y: CGFloat = st.Hv
        let hv: CGFloat = st.hv
        if st.tall > 0.25 {
            let deep: CGFloat = hv - Y
            reedMat(&v, cx: 260, y: Y + deep * 0.62, width: 220)
            reedMat(&v, cx: 700, y: Y + deep * 0.74, width: 260)
            Kit.pebbles(&v, in: CGRect(x: 380, y: Y + deep * 0.5, width: 300, height: deep * 0.3), count: 10, seed: 3, color: 0xD6C4A0)
        }
        let edge: Kit.Stops = [(ArtStyle.coolShade.opacity(0), 0), (ArtStyle.coolShade.opacity(0.12), 1)]
        Art.fillLinear(&v, Art.rect(-600, hv - 60, 2000, 60), edge, from: CGPoint(x: 0, y: hv - 60), to: CGPoint(x: 0, y: hv))
        Kit.pot(&v, cx: 26, baseY: hv + 20, width: 64, height: 96, color: 0xB06A3C, band: 0x2F6F9E)
        Kit.pot(&v, cx: 92, baseY: hv + 26, width: 46, height: 70, color: 0xA65E34)
        Kit.cornerLeaves(&v, size: CGSize(width: 892, height: hv), corner: 3, color: Art.color(0x4E7A44), scale: 0.8, seed: 5)
    }
}
