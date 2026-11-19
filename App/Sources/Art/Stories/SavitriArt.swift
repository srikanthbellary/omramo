import SwiftUI
import OmramoCore

/// Concept art for "Savitri and Satyavan", drawn in code (round 5; composed from the shared kit).
///
/// Advanced tier, a LIGHT story: the words sit in the top of BOTH panes, so every unfolded
/// scene keeps a low horizon (`ground: 220`) under a wide pale sky, and the figures stand low
/// on the trailing pane. Ancient India of the epic, after the gateways of Sanchi and the
/// paintings of Ajanta: draped unstitched cloth, carved timber on pale stone, reed huts, sal
/// forest and a banyan. Yama is tall, calm and dignified, never menacing.
enum SavitriArt {
    /// Draws the picture called `name`. Returns false for a name this story does not have.
    static func paint(_ name: String, role: ArtRole, in context: inout GraphicsContext, size: CGSize) -> Bool {
        guard size.width > 0, size.height > 0 else { return false }
        switch (name, role) {
        case ("scene-palace", .sceneUnfolded): palaceScene(&context, size)
        case ("scene-palace", .sceneFolded): palaceFolded(&context, size)
        case ("scene-hermitage", .sceneUnfolded): hermitageScene(&context, size)
        case ("scene-hermitage", .sceneFolded): hermitageFolded(&context, size)
        case ("scene-forest", .sceneUnfolded): forestScene(&context, size)
        case ("scene-forest", .sceneFolded): forestFolded(&context, size)
        case ("scene-south-road", .sceneUnfolded): southRoadScene(&context, size)
        case ("scene-south-road", .sceneFolded): southRoadFolded(&context, size)
        case ("see-her-own-choice", .picture): chariotPicture(&context, size)
        case ("see-hermitage", .picture): hermitagePicture(&context, size)
        case ("see-banyan-tree", .picture): banyanPicture(&context, size)
        case ("see-boon", .picture): boonPicture(&context, size)
        case ("char-savitri", .portrait): savitriPortrait(&context, size)
        case ("char-satyavan", .portrait): satyavanPortrait(&context, size)
        case ("face-savitri", .face): savitriFace(&context, size)
        case ("face-satyavan", .face): satyavanFace(&context, size)
        case ("face-yama", .face): yamaFace(&context, size)
        case ("cover", .cover): coverArt(&context, size)
        default:
            return false
        }
        return true
    }
}

// MARK: - Scene 1: the palace of Madra (pale morning)

extension SavitriArt {
    /// The palace of Madra: a far skyline of barrel roofs and a torana on the left under a wide
    /// pale-gold sky; low on the right the timber terrace above the stepped lotus pool, the king
    /// seated, Narada with his staff, and Savitri standing straight before them.
    static func palaceScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 220)
        let light = morning()
        Kit.sky(&context, size, horizon: st.H, light: light)
        let sunY: CGFloat = st.H - 44 * st.far
        Kit.sun(&context, 262, sunY, 14 * st.far, light: light)
        let cloudHigh: CGFloat = st.H - 360 * st.far
        let cloudLow: CGFloat = st.H - 300 * st.far
        Kit.cloud(&context, 140, cloudHigh, scale: 0.6 * st.far, color: Color.white.opacity(0.42))
        Kit.cloud(&context, 700, cloudLow, scale: 0.8 * st.far, color: Color.white.opacity(0.5))
        Kit.ranges(&context, width: size.width, horizon: st.H, scale: st.far * 0.55, light: light, seed: 21)
        palaceSkyline(&context, st)
        let veilTop: CGFloat = st.H - 90 * st.far
        ArtStyle.atmosphere(&context, width: size.width, top: veilTop, bottom: st.H + 4, color: light.haze, alpha: 0.34)
        let lawn: Kit.Stops = [(Art.color(0xDCD6A4), 0), (Art.color(0xBCC07E), 0.45), (Art.color(0x8E9A5A), 1)]
        Kit.ground(&context, width: size.width, top: st.H, bottom: size.height, stops: lawn, seed: 61)
        Kit.designSpace(&context, st) { v in
            palaceGarden(&v, st)
            Kit.nearSpace(&v, st) { n in
                palaceTerrace(&n, st)
                palaceCourt(&n, st)
                palacePool(&n, st)
                if st.tall > 0.25 {
                    palaceNearFill(&n, st)
                }
            }
        }
        Kit.cornerLeaves(&context, size: size, corner: 2, color: Art.color(ramp.deep, 0.9), scale: 0.8, seed: 3)
        ArtStyle.finish(&context, size, wash: 0.10, vignette: 0.08)
    }

    /// The far city on the leading side: barrel-roofed halls and one carved gateway, pale with
    /// distance, standing on the horizon. In picture units, scaled by the far plane.
    static func palaceSkyline(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let s: CGFloat = st.far
        let base: CGFloat = st.H + 2
        let halls: [(CGFloat, CGFloat, CGFloat)] = [(64, 58, 30), (140, 80, 44), (290, 72, 38), (384, 50, 28), (560, 44, 22)]
        for hall in halls {
            farPavilion(&context, cx: hall.0, baseY: base, width: hall.1 * s, height: hall.2 * s, color: 0xE9DDC0)
        }
        torana(&context, cx: 214, baseY: base, height: 56 * s, color: 0xE4D4B2)
        let treeTone: Color = Art.color(0xC6C597)
        let treeH: CGFloat = 22 * s
        Kit.farTrees(&context, x0: 0, x1: 460, baseY: base + 2, height: treeH, count: 10, color: treeTone, seed: 5)
        Kit.farTrees(&context, x0: 600, x1: 892, baseY: base + 2, height: treeH * 1.2, count: 7, color: treeTone, seed: 15)
    }

    /// The middle ground of the leading pane: garden trees, a sand path to the terrace,
    /// flowering beds and far parakeets low in the sky.
    static func palaceGarden(_ v: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        let greens = gardenGreens()
        Kit.tree(&v, x: 58, baseY: H + 36, height: 62, spread: 64, palette: greens, bark: 0x7A5A40, seed: 3)
        Kit.tree(&v, x: 352, baseY: H + 22, height: 50, spread: 54, palette: greens, bark: 0x7A5A40, seed: 7)
        Kit.bush(&v, x: 196, baseY: H + 30, width: 56, palette: greens, seed: 4)
        let path: Kit.Stops = [(Art.color(0xEDE0C0), 0), (Art.color(0xF4EAD2), 1)]
        Kit.ribbon(&v, nearX: 300, nearY: st.hv + 10, nearWidth: 150, farX: 500, farY: H + 46, farWidth: 30, stops: path)
        let bed = CGRect(x: 16, y: H + 62, width: 250, height: 70)
        Kit.flowers(&v, in: bed, count: 20, seed: 12, petal: 0xF2A6B8, heart: 0xFFC94A)
        let bed2 = CGRect(x: 380, y: H + 70, width: 60, height: 50)
        Kit.flowers(&v, in: bed2, count: 8, seed: 14, petal: 0xFFF2DA, heart: 0xFFB62E)
        Kit.grass(&v, in: CGRect(x: 0, y: H + 30, width: 470, height: 120), count: 40, seed: 8, color: Art.color(0x8E9A5A, 0.6), height: 7)
        Kit.birds(&v, 96, H - 58, scale: 0.7, color: Art.color(0x6E8A4A, 0.55))
        if st.tall > 0.25 {
            meadowFill(&v, x0: 0, x1: 470, top: H + 150, bottom: st.hv, seed: 31)
        }
    }

    /// The terrace: a pale stone platform with a carved front band, steps down on its left
    /// toward the pool, a low rail and a row of carved timber pillars holding a beam.
    static func palaceTerrace(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        let stone: UInt32 = 0xEFE3C6
        let backY: CGFloat = H + 24
        let frontY: CGFloat = H + 64
        // Pillars and beam behind the figures (soft timber, low contrast against the sky).
        let pillarXs: [CGFloat] = [598, 694, 790, 886]
        for x in pillarXs {
            timberPillar(&n, cx: x, baseY: backY + 4, height: 92, width: 12)
        }
        let beam = Art.rect(572, H - 76, 340, 12, radius: 3)
        Kit.solid(&n, beam, Art.color(0xC79A68), light: 0.2, shade: 0.18)
        let eave = Art.svg("M560,-76 Q726,-92 900,-80 L900,-74 Q726,-84 560,-70Z").applying(CGAffineTransform(translationX: 0, y: H))
        Kit.solid(&n, eave, Art.color(0xDDAE82), light: 0.18, shade: 0.12)
        // The rail along the back edge.
        Kit.fence(&n, x0: 560, x1: 900, baseY: backY + 2, height: 22, color: 0xD7B488)
        // The platform's top surface and its carved front face.
        let top = Art.svg("M520,24 L900,24 L900,64 L500,64Z").applying(CGAffineTransform(translationX: 0, y: H))
        Kit.solid(&n, top, stops: Kit.stops(0xF6ECD4, stone), light: 0.16, shade: 0.1)
        let face = Art.rect(500, frontY, 400, 26)
        Kit.solid(&n, face, Art.color(0xDCCBA4), light: 0.14, shade: 0.2)
        var carving = Path()
        var x: CGFloat = 512
        while x < 900 {
            carving.addPath(Art.circle(x, frontY + 13, 5))
            x += 22
        }
        Art.stroke(&n, carving, Art.color(0xB9A47C), width: ArtStyle.detailLine)
        Art.stroke(&n, Art.line(500, frontY + 1, 900, frontY + 1), Color.white.opacity(0.5), width: 1.4)
        // Steps on the left end, down toward the garden.
        let steps: [(CGFloat, CGFloat)] = [(0, 0), (12, 9), (24, 18)]
        for step in steps {
            let r = Art.rect(468 - step.0, frontY - 6 + step.1, 40, 10, radius: 2)
            Kit.solid(&n, r, Art.color(0xE6D7B4), light: 0.18, shade: 0.16)
        }
    }

    /// The three figures on the terrace: King Ashvapati seated, Narada beside him with his
    /// staff and vina, Savitri in saffron standing before them, chin raised.
    static func palaceCourt(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let feet: CGFloat = st.Hv + 50
        let sc: CGFloat = 0.66
        king(&n, x: 778, y: feet, scale: sc)
        narada(&n, x: 852, y: feet - 4, scale: sc, right: false)
        savitri(&n, x: 640, y: feet + 4, scale: sc, right: true, bark: false, pose: .stand, pot: false)
    }

    /// The stepped lotus pool in front of the terrace: three courses of pale stone round green
    /// water with pink and white lotuses.
    static func palacePool(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        let top: CGFloat = H + 96
        let deep: CGFloat = 120
        Kit.solid(&n, Art.rect(396, top - 6, 520, deep + 12, radius: 4), Art.color(0xEADFC2), light: 0.16, shade: 0.12)
        Kit.solid(&n, Art.rect(414, top + 4, 500, deep - 4, radius: 3), Art.color(0xD8C9A6), light: 0.14, shade: 0.14)
        Kit.solid(&n, Art.rect(432, top + 14, 480, deep - 22, radius: 3), Art.color(0xC5B58F), light: 0.12, shade: 0.16)
        let water = Art.rect(450, top + 24, 460, deep - 36, radius: 2)
        let pond: Kit.Stops = [(Art.color(0xA8D2C2), 0), (Art.color(0x6FA79A), 1)]
        Art.fillLinear(&n, water, pond, from: CGPoint(x: 0, y: top + 24), to: CGPoint(x: 0, y: top + deep - 12))
        Kit.rippleMarks(&n, x0: 460, x1: 900, y0: top + 30, y1: top + deep - 16, count: 16, seed: 4, color: Color.white, alpha: 0.35)
        let pads: [(CGFloat, CGFloat, CGFloat, Bool)] = [
            (482, 34, 9, false), (520, 52, 12, true), (566, 40, 8, false), (612, 62, 13, false),
            (668, 46, 10, true), (724, 70, 12, false), (780, 50, 9, true), (842, 64, 13, false), (884, 42, 8, false),
        ]
        for pad in pads {
            Kit.lilyPad(&n, cx: pad.0, cy: top + pad.1, r: pad.2, flower: pad.3, pad: 0x5E8E4E)
        }
        let blooms: [(CGFloat, CGFloat, CGFloat)] = [(540, 50, 13), (700, 44, 11), (812, 60, 14)]
        for bloom in blooms {
            Kit.groundLotus(&n, x: bloom.0, y: top + bloom.1, size: bloom.2)
        }
        Art.stroke(&n, Art.line(396, top - 5, 916, top - 5), Color.white.opacity(0.55), width: 1.6)
    }

    /// The deeper ground of a tall window: the near pool coping, lotus leaves standing out of
    /// the water's edge, and a flowering border.
    static func palaceNearFill(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        let reach: CGFloat = (st.hv - st.Hv) / st.grow
        let top: CGFloat = H + 222
        guard reach > 230 else { return }
        Kit.solid(&n, Art.rect(380, top, 540, 14, radius: 3), Art.color(0xE4D6B4), light: 0.18, shade: 0.14)
        let band = CGRect(x: 380, y: top + 16, width: 540, height: max(10, reach - 238))
        Kit.grass(&n, in: band, count: 50, seed: 19, color: Art.color(0x6E8A44), height: 10)
        Kit.flowers(&n, in: band, count: 18, seed: 23, petal: 0xF6B0C0, heart: 0xFFC94A)
        Kit.reeds(&n, x: 420, baseY: top + 4, count: 6, height: 40, seed: 5, color: 0x5E7E3E)
    }
}

// MARK: - Scene 2: the forest hermitage (soft gold light)

extension SavitriArt {
    /// The hermitage: pale sky between far sal tops; low on the right two reed huts, the
    /// square fire altar with its thread of smoke, the blind old king and the queen seated on
    /// grass mats, Savitri in ochre walking toward them with the water pot on her hip, and
    /// spotted deer grazing low on the leading side.
    static func hermitageScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 220)
        let light = goldLight()
        Kit.sky(&context, size, horizon: st.H, light: light)
        let sunY: CGFloat = st.H - 52 * st.far
        Kit.sun(&context, 196, sunY, 13 * st.far, light: light)
        let cloudY: CGFloat = st.H - 320 * st.far
        Kit.cloud(&context, 610, cloudY, scale: 0.7 * st.far, color: Color.white.opacity(0.45))
        hermitageFarForest(&context, st, light: light)
        let earth: Kit.Stops = [(Art.color(0xE4D09E), 0), (Art.color(0xCDB077), 0.5), (Art.color(0x9A8A52), 1)]
        Kit.ground(&context, width: size.width, top: st.H, bottom: size.height, stops: earth, seed: 63)
        Kit.designSpace(&context, st) { v in
            hermitageClearing(&v, st)
            Kit.nearSpace(&v, st) { n in
                hermitageCamp(&n, st)
                if st.tall > 0.25 {
                    let reach: CGFloat = (st.hv - st.Hv) / st.grow
                    meadowFill(&n, x0: 460, x1: 900, top: st.Hv + 140, bottom: st.Hv + reach, seed: 41)
                }
            }
        }
        Kit.cornerLeaves(&context, size: size, corner: 3, color: Art.color(ramp.deep, 0.9), scale: 0.85, seed: 6)
        ArtStyle.finish(&context, size, wash: 0.10, vignette: 0.08)
    }

    /// The sal forest beyond the clearing: pale crowns on the horizon all across, a nearer
    /// row a little fuller, both veiled by the gold air.
    static func hermitageFarForest(_ context: inout GraphicsContext, _ st: Kit.Stage, light: Kit.Light) {
        let w: CGFloat = st.w
        let farH: CGFloat = 70 * st.far
        let nearH: CGFloat = 50 * st.far
        Kit.farTrees(&context, x0: -10, x1: w + 10, baseY: st.H + 2, height: farH, count: 22, color: light.far, seed: 7)
        ArtStyle.atmosphere(&context, width: w, top: st.H - farH * 1.3, bottom: st.H + 4, color: light.haze, alpha: 0.4)
        Kit.farTrees(&context, x0: -10, x1: w + 10, baseY: st.H + 4, height: nearH, count: 18, color: light.mid, seed: 17)
        let crest: Kit.Stops = [(light.glow.opacity(0), 0), (light.glow.opacity(0.22), 1)]
        Art.fillLinear(&context, Art.rect(0, st.H - nearH, w, nearH), crest, from: CGPoint(x: 0, y: st.H - nearH), to: CGPoint(x: 0, y: st.H))
    }

    /// The leading side of the clearing: a far small hut, grazing deer, a swept path and pots.
    static func hermitageClearing(_ v: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        hut(&v, cx: 92, baseY: H + 20, width: 54, height: 52, lamps: false)
        Kit.bush(&v, x: 30, baseY: H + 24, width: 50, palette: salGreens(), seed: 9)
        Kit.bush(&v, x: 400, baseY: H + 16, width: 44, palette: salGreens(), seed: 13)
        chital(&v, x: 196, y: H + 44, scale: 0.4, right: true)
        chital(&v, x: 296, y: H + 58, scale: 0.44, right: false)
        chital(&v, x: 360, y: H + 36, scale: 0.34, right: true)
        let path: Kit.Stops = [(Art.color(0xEFDDB0), 0), (Art.color(0xF4E6C4), 1)]
        Kit.ribbon(&v, nearX: 260, nearY: st.hv + 10, nearWidth: 170, farX: 560, farY: H + 60, farWidth: 60, stops: path)
        Kit.grass(&v, in: CGRect(x: 0, y: H + 10, width: 470, height: 120), count: 44, seed: 21, color: Art.color(0x8E9A52, 0.6), height: 7)
        Kit.flowers(&v, in: CGRect(x: 10, y: H + 80, width: 200, height: 60), count: 10, seed: 22, petal: 0xFFF0D0, heart: 0xE07A1A)
        Kit.birds(&v, 300, H - 48, scale: 0.6, color: Art.color(0x7A8A4A, 0.5))
        if st.tall > 0.25 {
            meadowFill(&v, x0: 0, x1: 470, top: H + 150, bottom: st.hv, seed: 44)
        }
    }

    /// The trailing side: two huts, the fire altar, the old king and queen on their mats and
    /// Savitri walking toward them with the water pot.
    static func hermitageCamp(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        hut(&n, cx: 600, baseY: H + 22, width: 78, height: 80, lamps: false)
        hut(&n, cx: 836, baseY: H + 46, width: 112, height: 108, lamps: true)
        Kit.pot(&n, cx: 884, baseY: H + 56, width: 18, height: 20, color: 0xB5683A)
        Kit.pot(&n, cx: 560, baseY: H + 30, width: 14, height: 16, color: 0xA85A30)
        fireAltar(&n, cx: 664, baseY: H + 76, width: 44, smoke: true)
        let sc: CGFloat = 0.64
        seatedElder(&n, queenLook(), x: 722, y: H + 84, scale: sc, right: false, gaze: CGPoint(x: -0.5, y: 0), staff: false)
        seatedElder(&n, oldKingLook(), x: 796, y: H + 80, scale: sc, right: false, gaze: CGPoint(x: -0.2, y: -0.7), staff: true)
        savitri(&n, x: 560, y: H + 88, scale: sc, right: true, bark: true, pose: .walk, pot: true, mouth: .smile)
        Kit.grass(&n, in: CGRect(x: 470, y: H + 60, width: 430, height: 70), count: 30, seed: 27, color: Art.color(0x7E8A46, 0.6), height: 8)
        Kit.pebbles(&n, in: CGRect(x: 620, y: H + 92, width: 120, height: 20), count: 6, seed: 28, color: 0xB8A47E)
    }
}

// MARK: - Scene 3: the forest and the banyan (afternoon)

extension SavitriArt {
    /// The deep forest: pale shafts of afternoon sun between far trunks under a high pale sky;
    /// a stream over flat stones low on the leading side; low on the right the great banyan,
    /// Satyavan with his axe and the bundle of wood, Savitri beside him, a peacock in the dust.
    static func forestScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 220)
        let light = afternoon()
        Kit.sky(&context, size, horizon: st.H, light: light)
        forestFar(&context, st, light: light)
        let dust: Kit.Stops = [(Art.color(0xDCC48E), 0), (Art.color(0xB89C62), 0.5), (Art.color(0x7A6A40), 1)]
        Kit.ground(&context, width: size.width, top: st.H, bottom: size.height, stops: dust, seed: 65)
        Kit.designSpace(&context, st) { v in
            forestStream(&v, st)
            Kit.nearSpace(&v, st) { n in
                banyan(&n, x: 800, baseY: st.Hv + 46, height: 150, spread: 380, seed: 12)
                forestPair(&n, st)
                if st.tall > 0.25 {
                    let reach: CGFloat = (st.hv - st.Hv) / st.grow
                    meadowFill(&n, x0: 460, x1: 900, top: st.Hv + 130, bottom: st.Hv + reach, seed: 51)
                    fallenLeaves(&n, in: CGRect(x: 470, y: st.Hv + 130, width: 420, height: reach - 130), seed: 52)
                }
            }
        }
        sunShafts(&context, size, st)
        Kit.cornerLeaves(&context, size: size, corner: 2, color: Art.color(ramp.deep, 0.92), scale: 0.9, seed: 8)
        Kit.cornerLeaves(&context, size: size, corner: 3, color: Art.color(ramp.deep, 0.92), scale: 0.8, seed: 9)
        ArtStyle.finish(&context, size, wash: 0.10, vignette: 0.09)
    }

    /// The far forest: pale trunks rising into the high pale sky, a faint fringe of canopy at
    /// the top edge, undergrowth on the horizon with a few flame-of-the-forest blossoms.
    static func forestFar(_ context: inout GraphicsContext, _ st: Kit.Stage, light: Kit.Light) {
        let w: CGFloat = st.w
        var random = ArtRandom(71)
        var trunks = Path()
        var x: CGFloat = 12
        while x < w {
            let half: CGFloat = (3 + Kit.rnd(&random) * 4) * st.far
            trunks.addPath(Art.rect(x - half, 0, half * 2, st.H + 4))
            x += 58 + Kit.rnd(&random) * 40
        }
        Art.fill(&context, trunks, light.far.opacity(0.34))
        var fringe = Path()
        var fx: CGFloat = -20
        while fx < w + 20 {
            let r: CGFloat = 26 + Kit.rnd(&random) * 22
            fringe.addPath(Art.ellipse(fx, -6 + Kit.rnd(&random) * 10, r * 1.4, r))
            fx += r * 1.6
        }
        Art.fill(&context, fringe, light.far.opacity(0.32))
        let underH: CGFloat = 44 * st.far
        Kit.farTrees(&context, x0: -10, x1: w + 10, baseY: st.H + 2, height: underH, count: 22, color: light.far, seed: 23)
        let blossoms = CGRect(x: 0, y: st.H - underH * 0.8, width: w, height: underH * 0.7)
        Kit.flecks(&context, in: blossoms, count: 26, seed: 24, color: Art.color(0xF08A3A, 0.6), radius: 1.2...2.6)
        ArtStyle.atmosphere(&context, width: w, top: st.H - underH * 1.4, bottom: st.H + 4, color: light.haze, alpha: 0.38)
        Kit.farTrees(&context, x0: -10, x1: w + 10, baseY: st.H + 4, height: underH * 0.6, count: 16, color: light.mid, seed: 25)
    }

    /// Pale shafts of afternoon sun falling from the upper left, over everything, very soft.
    static func sunShafts(_ context: inout GraphicsContext, _ size: CGSize, _ st: Kit.Stage) {
        let bottom: CGFloat = st.H + 0.25 * st.depth
        let drift: CGFloat = bottom * 0.32
        let shafts: [(CGFloat, CGFloat)] = [(60, 46), (250, 30), (470, 56), (690, 38)]
        for shaft in shafts {
            let top0: CGFloat = shaft.0
            let top1: CGFloat = shaft.0 + shaft.1
            let beam = Art.polygon([
                CGPoint(x: top0, y: 0), CGPoint(x: top1, y: 0),
                CGPoint(x: top1 + drift + shaft.1, y: bottom), CGPoint(x: top0 + drift, y: bottom),
            ])
            let fade: Kit.Stops = [(Color.white.opacity(0.16), 0), (Color.white.opacity(0.1), 0.7), (Color.white.opacity(0), 1)]
            Art.fillLinear(&context, beam, fade, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: bottom))
        }
    }

    /// The leading side: a stream sliding over flat brown stones, teak scrub and chital
    /// lifting their heads to watch.
    static func forestStream(_ v: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        let stream: Kit.Stops = [(Art.color(0xBFDCCF), 0), (Art.color(0x8FBDB0), 1)]
        Kit.ribbon(&v, nearX: 150, nearY: H + 230, nearWidth: 220, farX: 400, farY: H + 22, farWidth: 26, stops: stream)
        Kit.rippleMarks(&v, x0: 120, x1: 380, y0: H + 40, y1: H + 200, count: 16, seed: 9, color: Color.white, alpha: 0.4)
        let stones: [(CGFloat, CGFloat, CGFloat)] = [(330, 50, 22), (262, 86, 30), (196, 130, 40), (110, 176, 50), (380, 34, 14)]
        for (index, s) in stones.enumerated() {
            Kit.rock(&v, cx: s.0, baseY: H + s.1, width: s.2, height: s.2 * 0.28, color: 0x9A7A56, seed: UInt32(index + 3))
        }
        Kit.bush(&v, x: 40, baseY: H + 40, width: 70, palette: salGreens(), seed: 31)
        Kit.bush(&v, x: 440, baseY: H + 30, width: 60, palette: salGreens(), seed: 33)
        teakLeaves(&v, x: 20, baseY: H + 70, scale: 1)
        chital(&v, x: 250, y: H + 34, scale: 0.36, right: true)
        chital(&v, x: 318, y: H + 28, scale: 0.32, right: false)
        Kit.grass(&v, in: CGRect(x: 0, y: H + 20, width: 470, height: 140), count: 40, seed: 34, color: Art.color(0x7E8A46, 0.6), height: 8)
        if st.tall > 0.25 {
            meadowFill(&v, x0: 0, x1: 470, top: H + 160, bottom: st.hv, seed: 35)
        }
    }

    /// A few broad teak leaves standing up from the ground (a near, cropped plant).
    static func teakLeaves(_ v: inout GraphicsContext, x: CGFloat, baseY: CGFloat, scale: CGFloat) {
        var leaves = Path()
        var veins = Path()
        let set: [(CGFloat, CGFloat, CGFloat)] = [(0, -1.9, 34), (14, -1.3, 30), (-6, -2.4, 26), (22, -0.8, 24)]
        for leaf in set {
            let bx: CGFloat = x + leaf.0 * scale
            Kit.treeLeaf(&leaves, bx, baseY, leaf.2 * scale, leaf.1, slim: 0.8)
            let tipX: CGFloat = bx + cos(leaf.1) * leaf.2 * scale * 1.6
            let tipY: CGFloat = baseY + sin(leaf.1) * leaf.2 * scale * 1.6
            veins.move(to: CGPoint(x: bx, y: baseY))
            veins.addLine(to: CGPoint(x: tipX, y: tipY))
        }
        Kit.solid(&v, leaves, Art.color(0x5E7A34), light: 0.3, shade: 0.26)
        Art.stroke(&v, veins, Art.color(0x9AB05E, 0.7), width: 1)
    }

    /// Under the banyan: the bundle of wood, Satyavan with his axe, Savitri beside him with
    /// her basket, and a peacock walking through the dust.
    static func forestPair(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        let feet: CGFloat = H + 76
        let sc: CGFloat = 0.6
        woodBundle(&n, cx: 628, baseY: feet + 8, width: 62)
        satyavan(&n, x: 700, y: feet, scale: sc, right: false, pose: .stand, axe: true, mouth: .grin)
        savitri(&n, x: 770, y: feet + 2, scale: sc, right: false, bark: true, pose: .stand, pot: false, mouth: .flat)
        Kit.basket(&n, cx: 806, baseY: feet + 6, width: 24, height: 14, color: 0xC89A54, handles: true)
        peacock(&n, x: 536, y: H + 98, scale: 0.55, right: false)
        Kit.pebbles(&n, in: CGRect(x: 480, y: H + 100, width: 160, height: 20), count: 7, seed: 36, color: 0xB09A74)
    }

    /// Fallen leaves of teak and sal on the forest floor (tall windows).
    static func fallenLeaves(_ n: inout GraphicsContext, in rect: CGRect, seed: UInt32) {
        guard rect.width > 0, rect.height > 0 else { return }
        var random = ArtRandom(seed)
        var brown = Path()
        var gold = Path()
        for i in 0..<18 {
            let lx: CGFloat = rect.minX + rect.width * Kit.rnd(&random)
            let ly: CGFloat = rect.minY + rect.height * Kit.rnd(&random)
            let a: CGFloat = Kit.rnd(&random) * 6.2
            let r: CGFloat = 5 + Kit.rnd(&random) * 6
            if i % 2 == 0 {
                Kit.treeLeaf(&brown, lx, ly, r, a, slim: 0.7)
            } else {
                Kit.treeLeaf(&gold, lx, ly, r, a, slim: 0.7)
            }
        }
        Art.fill(&n, brown, Art.color(0x9A6A3A, 0.85))
        Art.fill(&n, gold, Art.color(0xC89A4A, 0.85))
    }
}

// MARK: - Scene 4: the south road (late evening, pale rose-gold)

extension SavitriArt {
    /// The south road: a pale rose-gold sky over flat land; a narrow path leaves the last trees
    /// on the left and runs into tall gold grass; low on the right tall, calm Yama walks away
    /// with the small gold light in his hand, and Savitri follows a few steps behind.
    static func southRoadScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 220)
        let light = evening()
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.sun(&context, 150, st.H - 30 * st.far, 16 * st.far, light: light)
        let cloudA: CGFloat = st.H - 350 * st.far
        let cloudB: CGFloat = st.H - 290 * st.far
        Kit.cloud(&context, 520, cloudA, scale: 0.7 * st.far, color: Art.color(0xFFF2EC, 0.5))
        Kit.cloud(&context, 800, cloudB, scale: 0.55 * st.far, color: Art.color(0xFFF2EC, 0.45))
        Kit.ranges(&context, width: size.width, horizon: st.H, scale: st.far * 0.35, light: light, seed: 33)
        Kit.farTrees(&context, x0: -10, x1: 330, baseY: st.H + 2, height: 30 * st.far, count: 9, color: light.far, seed: 3)
        let veilTop: CGFloat = st.H - 60 * st.far
        ArtStyle.atmosphere(&context, width: size.width, top: veilTop, bottom: st.H + 4, color: light.haze, alpha: 0.34)
        let field: Kit.Stops = [(Art.color(0xEACB92), 0), (Art.color(0xD6AA68), 0.5), (Art.color(0xA8804A), 1)]
        Kit.ground(&context, width: size.width, top: st.H, bottom: size.height, stops: field, seed: 67)
        Kit.designSpace(&context, st) { v in
            roadFields(&v, st)
            Kit.nearSpace(&v, st) { n in
                roadWalkers(&n, st)
            }
        }
        Kit.cornerLeaves(&context, size: size, corner: 2, color: Art.color(0x6A5A32, 0.9), scale: 0.8, seed: 12)
        ArtStyle.finish(&context, size, wash: 0.10, vignette: 0.08)
    }

    /// The last thinning trees low on the left, the path and the bands of gold grass.
    static func roadFields(_ v: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        salTree(&v, x: 34, baseY: H + 44, height: 84, seed: 3)
        salTree(&v, x: 112, baseY: H + 30, height: 70, seed: 5)
        salTree(&v, x: 196, baseY: H + 20, height: 58, seed: 7)
        Kit.bush(&v, x: 70, baseY: H + 48, width: 60, palette: salGreens(), seed: 37)
        goldGrass(&v, x0: 0, x1: 900, baseY: H + 12, height: 8, seed: 1)
        let path: Kit.Stops = [(Art.color(0xE6C49A), 0), (Art.color(0xF0D6B2), 1)]
        Kit.ribbon(&v, nearX: 300, nearY: H + 240, nearWidth: 160, farX: 870, farY: H + 8, farWidth: 12, stops: path)
        goldGrass(&v, x0: 230, x1: 740, baseY: H + 40, height: 18, seed: 2)
        goldGrass(&v, x0: 0, x1: 500, baseY: H + 120, height: 34, seed: 4)
        Kit.birds(&v, 260, H - 40, scale: 0.6, color: Art.color(0x9A6A5A, 0.5))
        if st.tall > 0.25 {
            var y: CGFloat = H + 170
            var seed: UInt32 = 50
            while y < st.hv + 20 {
                goldGrass(&v, x0: 0, x1: 900, baseY: y, height: 40, seed: seed)
                y += 46
                seed = seed &+ 1
            }
        }
    }

    /// Yama ahead with the light, Savitri a few steps behind, both walking away to the south
    /// (to the right), the tall grass round their legs.
    static func roadWalkers(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        Art.glow(&n, 760, H + 60, 90, Art.color(0xFFD27A), alpha: 0.18)
        yama(&n, x: 744, y: H + 72, scale: 0.56, right: true, pose: .walk, light: true)
        savitri(&n, x: 636, y: H + 90, scale: 0.6, right: true, bark: true, pose: .walk, pot: false, mouth: .flat)
        goldGrass(&n, x0: 560, x1: 900, baseY: H + 104, height: 30, seed: 9)
    }
}
