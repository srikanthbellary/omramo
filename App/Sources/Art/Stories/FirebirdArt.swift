import SwiftUI
import OmramoCore

/// Concept art for "The Fire-Bird and the Horse of Power", drawn in code (round 5; composed
/// from the shared kit). A DARK, Advanced story: every picture is night, candlelight, torchlight
/// or the grey midnight of a white night; the words sit in the deep, quiet sky of both panes and
/// the Fire-Bird's gold is the strongest light wherever it is.
enum FirebirdArt {
    /// Draws the picture called `name`. Returns false for a name this story does not have.
    static func paint(_ name: String, role: ArtRole, in context: inout GraphicsContext, size: CGSize) -> Bool {
        guard size.width > 0, size.height > 0 else { return false }
        switch (name, role) {
        case ("scene-forest", .sceneUnfolded): forestScene(&context, size)
        case ("scene-forest", .sceneFolded): forestFolded(&context, size)
        case ("scene-palace", .sceneUnfolded): palaceScene(&context, size)
        case ("scene-palace", .sceneFolded): palaceFolded(&context, size)
        case ("scene-sea", .sceneUnfolded): seaScene(&context, size)
        case ("scene-sea", .sceneFolded): seaFolded(&context, size)
        case ("scene-cauldron", .sceneUnfolded): cauldronScene(&context, size)
        case ("scene-cauldron", .sceneFolded): cauldronFolded(&context, size)
        case ("see-taiga", .picture): taigaPicture(&context, size)
        case ("see-tsar-title", .picture): crownPicture(&context, size)
        case ("see-firebird-in-art", .picture): firebirdPicture(&context, size)
        case ("see-white-sea", .picture): whiteSeaPicture(&context, size)
        case ("char-archer", .portrait): archerPortrait(&context, size)
        case ("char-horse", .portrait): horsePortrait(&context, size)
        case ("face-archer", .face): archerFace(&context, size)
        case ("face-horse", .face): horseFace(&context, size)
        case ("face-vasilissa", .face): vasilissaFace(&context, size)
        case ("face-tsar", .face): tsarFace(&context, size)
        case ("cover", .cover): coverPicture(&context, size)
        default:
            return false
        }
        return true
    }
}

// MARK: - Unfolded: the taiga at night

extension FirebirdArt {
    /// Night in the taiga: deep blue sky with faint stars over the spruce tops across both
    /// panes; low on the trailing pane the archer leans from the saddle of the great horse
    /// toward the golden feather glowing on the needle path.
    static func forestScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 220)
        let light = night()
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.stars(&context, width: size.width, maxY: st.H - 110 * st.far, count: 80, seed: 11)
        let farTop: CGFloat = st.H - 50 * st.far
        Kit.farTrees(&context, x0: -10, x1: 900, baseY: st.H + 4, height: 70 * st.far, count: 46, color: Art.color(0x101E2A), conifer: true, seed: 3)
        ArtStyle.atmosphere(&context, width: size.width, top: farTop, bottom: st.H + 6, color: light.haze, alpha: 0.35)
        Kit.farTrees(&context, x0: -10, x1: 900, baseY: st.H + 10, height: 110 * st.far, count: 30, color: Art.color(0x0B161C), conifer: true, seed: 8)
        Kit.ground(&context, width: size.width, top: st.H, bottom: size.height, stops: Kit.stops(0x14221A, 0x0A130E), seed: 21)
        Kit.designSpace(&context, st) { v in
            forestMiddle(&v, st)
            Kit.nearSpace(&v, st, anchorX: 700) { n in
                forestSubject(&n, st)
            }
        }
        ArtStyle.finish(&context, size, wash: 0.04, vignette: 0.16)
    }

    /// The middle plane of the forest: spruces and pale birches along the whole width, the
    /// mossy floor and the needle path winding in from the trailing pane.
    static func forestMiddle(_ v: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        let hv: CGFloat = st.hv
        let spruce = nightSpruce()
        let trees: [(CGFloat, CGFloat, CGFloat)] = [(40, 8, 230), (150, 2, 190), (250, 12, 250), (380, 4, 170), (500, 6, 200)]
        var seed: UInt32 = 40
        for tree in trees {
            Kit.conifer(&v, x: tree.0, baseY: Hv + tree.1, height: tree.2, palette: spruce, seed: seed)
            seed = seed &+ 3
        }
        Kit.birch(&v, x: 205, baseY: Hv + 14, height: 140, palette: nightBirch(), seed: 5)
        Kit.birch(&v, x: 440, baseY: Hv + 10, height: 120, palette: nightBirch(), seed: 9)
        Art.layer(&v, opacity: 0.5) { veil in
            Art.fill(&veil, Art.rect(0, Hv - 260, 892, 270), Art.color(0x0B1424, 0.55))
        }
        let path: Kit.Stops = [(Art.color(0x2E2618), 0), (Art.color(0x3A2E1C), 1)]
        Kit.ribbon(&v, nearX: 640, nearY: hv + 20, nearWidth: 260, farX: 560, farY: Hv + 4, farWidth: 26, stops: path)
        let moss: Color = Art.color(0x1E3226)
        Kit.grass(&v, in: CGRect(x: 0, y: Hv + 6, width: 892, height: hv - Hv), count: 220, seed: 14, color: moss, height: 7)
        Kit.grass(&v, in: CGRect(x: 0, y: Hv + 30, width: 892, height: hv - Hv), count: 160, seed: 15, color: Art.color(0x2A4430), height: 9)
        Kit.rock(&v, cx: 120, baseY: Hv + 96, width: 70, height: 34, color: 0x3A4044, seed: 4)
        Kit.rock(&v, cx: 330, baseY: Hv + 70, width: 46, height: 22, color: 0x343A3E, seed: 6)
        Kit.grassTuft(&v, x: 70, baseY: Hv + 150, height: 40, color: 0x1E3A2A, seed: 2)
        Kit.grassTuft(&v, x: 260, baseY: Hv + 130, height: 34, color: 0x24402C, seed: 3)
        if st.tall > 0.25 {
            Kit.pebbles(&v, in: CGRect(x: 40, y: Hv + 180, width: 380, height: hv - Hv - 200), count: 18, seed: 7, color: 0x3A3E3A)
            Kit.grassTuft(&v, x: 160, baseY: hv - 60, height: 60, color: 0x1A3426, seed: 6)
            Kit.grassTuft(&v, x: 380, baseY: hv - 90, height: 50, color: 0x1E3A2A, seed: 8)
            Kit.rock(&v, cx: 60, baseY: hv - 30, width: 110, height: 50, color: 0x2E3436, seed: 9)
        }
    }

    /// The archer leaning from the saddle toward the feather; its light on his face, on the
    /// horse's chest and on the nearest trunks.
    static func forestSubject(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        let feetY: CGFloat = Hv + 110
        let featherX: CGFloat = 612
        let featherY: CGFloat = feetY - 4
        Art.glow(&n, featherX, featherY - 40, 210, Art.color(fireAmber), alpha: 0.3)
        var trunks = Path()
        trunks.addPath(Art.rect(548, Hv - 60, 11, 130, radius: 3))
        trunks.addPath(Art.rect(786, Hv - 40, 12, 120, radius: 3))
        Kit.solid(&n, trunks, Art.color(0x6A3E22), light: 0.3, shade: 0.2)
        Kit.conifer(&n, x: 554, baseY: Hv + 70, height: 160, palette: litSpruce(), seed: 61)
        Art.group(&n, x: 728, y: feetY, scale: 0.62) { h in
            horse(&h, bend: 12, warm: CGPoint(x: -190, y: -60), warmAlpha: 0.55)
            rider(&h, lean: 30, look: CGPoint(x: -0.6, y: 0.9))
            Art.glow(&h, -45, -232, 40, Art.color(fireAmber), alpha: 0.35)
        }
        Art.group(&n, x: featherX, y: featherY, scale: 0.7) { f in
            feather(&f)
        }
        Kit.conifer(&n, x: 880, baseY: st.hv + 30, height: 560, palette: nightSpruce(), seed: 77)
        Kit.grassTuft(&n, x: 560, baseY: feetY + 70, height: 46, color: 0x2A4A30, seed: 12)
        Kit.grassTuft(&n, x: 700, baseY: feetY + 90, height: 40, color: 0x1E3A2A, seed: 13)
        Kit.flecks(&n, in: CGRect(x: 560, y: feetY - 120, width: 120, height: 100), count: 10, seed: 4, color: Art.color(fireCore), radius: 0.6...1.6, glow: true)
    }
}

// MARK: - Unfolded: the tsar's hall

extension FirebirdArt {
    /// Night in the tsar's wooden hall: log walls and roof beams fade into brown shadow
    /// across the top of both panes; low on the trailing pane the green-tiled stove, the old
    /// tsar on his carved chair gazing at the golden cage, and the archer bowing.
    static func palaceScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 220)
        let light = hall()
        let w: CGFloat = size.width
        Kit.sky(&context, size, horizon: st.H, light: light)
        let wall = CGRect(x: 0, y: 0, width: w, height: st.H)
        Art.layer(&context, opacity: 0.55) { logs in
            Kit.builtLogs(&logs, rect: wall, color: logMid)
        }
        let dusk: Kit.Stops = [(Art.color(0x0C0705, 0.94), 0), (Art.color(0x140B07, 0.7), 0.5), (Art.color(0x1A0F0A, 0), 0.92)]
        Art.fillLinear(&context, Art.rect(0, 0, w, st.H), dusk, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: st.H))
        let floor: Kit.Stops = [(Art.color(0x4A2C18), 0), (Art.color(0x2A170C), 0.6), (Art.color(0x1A0E08), 1)]
        Kit.ground(&context, width: w, top: st.H, bottom: size.height, stops: floor, seed: 23)
        var planks = Path()
        for index in 0..<12 {
            let x: CGFloat = CGFloat(index) * 80 - 20
            let spread: CGFloat = (x - 446) * 1.8
            planks.move(to: CGPoint(x: x, y: st.H))
            planks.addLine(to: CGPoint(x: x + spread, y: size.height))
        }
        Art.stroke(&context, planks, Art.color(0x140A06, 0.6), width: 1.4)
        Kit.designSpace(&context, st) { v in
            palaceWallSide(&v, st)
            Kit.nearSpace(&v, st, anchorX: 700) { n in
                palaceSubject(&n, st)
            }
        }
        ArtStyle.finish(&context, size, wash: 0.04, vignette: 0.18)
    }

    /// The hall's leading side: carved posts rising into the dark, benches along the wall,
    /// candles in iron holders low down.
    static func palaceWallSide(_ v: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        Art.layer(&v, opacity: 0.8) { posts in
            Art.group(&posts, x: 96, y: Hv + 6) { p in
                carvedPost(&p, height: Hv + 20)
            }
            Art.group(&posts, x: 468, y: Hv + 6) { p in
                carvedPost(&p, height: Hv + 20)
            }
        }
        let shadowTop: Kit.Stops = [(Art.color(0x0C0705, 0.9), 0), (Art.color(0x0C0705, 0), 1)]
        Art.fillLinear(&v, Art.rect(0, 0, 892, Hv - 120), shadowTop, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: Hv - 120))
        var benches = Path()
        benches.addPath(Art.rect(0, Hv - 28, 420, 14, radius: 3))
        Kit.solid(&v, benches, Art.color(0x5A3018), light: 0.3, shade: 0.3, rim: 1.2)
        var feet = Path()
        let legs: [CGFloat] = [30, 140, 250, 360]
        for x in legs {
            feet.addPath(Art.rect(x, Hv - 14, 10, 20, radius: 2))
        }
        Art.fill(&v, feet, Art.color(0x2A170C))
        let candles: [CGFloat] = [40, 196, 340]
        for x in candles {
            Art.stroke(&v, Art.line(x, Hv - 28, x, Hv - 70), Art.color(0x2A2220), width: 2.4)
            Art.stroke(&v, Art.line(x - 9, Hv - 70, x + 9, Hv - 70), Art.color(0x2A2220), width: 2.4)
            Art.fill(&v, Art.rect(x - 3, Hv - 84, 6, 14, radius: 1.5), Art.color(0xEDE2C6))
            Kit.lamp(&v, cx: x, cy: Hv - 90, radius: 3.2, color: 0xFFC96B)
        }
        Kit.shadow(&v, 210, Hv + 8, width: 420, alpha: 0.3)
        if st.tall > 0.25 {
            let rug: Path = Art.svg("M150,0 L470,0 L520,90 L90,90Z").applying(CGAffineTransform(translationX: 0, y: Hv + 150))
            Art.fill(&v, rug, Art.color(0x6A1E1A, 0.8))
            Art.stroke(&v, rug, Art.color(0xC9A050, 0.5), width: 3)
        }
    }

    /// The stove, the tsar on his chair, the cage on its carved stand, the archer bowing.
    static func palaceSubject(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let floorY: CGFloat = st.Hv + 100
        Art.group(&n, x: 852, y: floorY - 6, scale: 0.8) { s in
            stove(&s)
        }
        Art.glow(&n, 660, floorY - 110, 240, Art.color(fireAmber), alpha: 0.32)
        Art.group(&n, x: 770, y: floorY, scale: 0.9) { t in
            tsarSeated(&t)
        }
        let stand: Path = Art.svg("M-22,0 L-14,-12 L-8,-50 L-26,-58 L26,-58 L8,-50 L14,-12 L22,0Z")
        Art.group(&n, x: 668, y: floorY + 4, scale: 0.9) { c in
            Kit.shadow(&c, 0, 0, width: 60)
            Kit.solid(&c, stand, stops: Kit.stops(0x7A4626, 0x3A2010), light: 0.3, shade: 0.3, rim: 1.2)
            Art.group(&c, x: 0, y: -58) { cg in
                cage(&cg)
            }
        }
        Art.group(&n, x: 566, y: floorY + 6, scale: 0.9) { a in
            Kit.shadow(&a, 0, 0, width: 70)
            Art.group(&a, scaleX: -1) { m in
                archer(&m, pose: .bow, look: CGPoint(x: 0, y: 0.6), mouth: .flat, mirrored: true)
            }
        }
        Kit.lamp(&n, cx: 720, cy: floorY - 150, radius: 3, color: 0xFFC96B)
        Art.stroke(&n, Art.line(720, floorY - 140, 720, floorY - 6), Art.color(0x2A2220), width: 2.6)
        Art.fill(&n, Art.rect(716, floorY - 146, 8, 10, radius: 1.5), Art.color(0xEDE2C6))
    }
}

// MARK: - Unfolded: the shore at the end of the world

extension FirebirdArt {
    /// The white night: a soft grey-blue midnight sky with one faint star over a still pewter
    /// sea across both panes; Vasilissa rows her silver boat far out on the leading side, and
    /// low on the trailing pane the gold-roofed tent and the dark horse stand on pale sand.
    static func seaScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 220)
        let light = whiteNight()
        let w: CGFloat = size.width
        Kit.sky(&context, size, horizon: st.H, light: light)
        let starX: CGFloat = 640
        let starY: CGFloat = st.H - 300 * st.far
        Art.glow(&context, starX, starY, 9, Art.color(0xF2EEE2), alpha: 0.35)
        Art.fill(&context, Art.circle(starX, starY, 1.4), Art.color(0xF2EEE2, 0.8))
        Kit.cloud(&context, 760, st.H - 150 * st.far, scale: 1.1 * st.far, color: Art.color(0x4E586C, 0.5))
        let headland: Path = Kit.ridge(width: 300, y: st.H - 10 * st.far, amp: 16 * st.far, seed: 5, bottom: st.H + 2)
        Art.fill(&context, headland, light.far)
        ArtStyle.atmosphere(&context, width: w, top: st.H - 40 * st.far, bottom: st.H + 4, color: light.haze, alpha: 0.4)
        let sea: Kit.Stops = [(Art.color(0x3A4456), 0), (Art.color(0x222C3C), 0.4), (Art.color(0x141C28), 1)]
        Kit.water(&context, width: w, top: st.H, bottom: size.height, stops: sea, light: light, ripples: 46, seed: 9)
        Kit.glints(&context, x: 300, top: st.H, depth: size.height - st.H, color: Art.color(0x9AA4B4), count: 26, seed: 4)
        Kit.designSpace(&context, st) { v in
            seaShore(&v, st)
            Art.group(&v, x: 290, y: st.Hv + 70, scale: 0.8) { b in
                vasilissaBoat(&b)
            }
            Kit.ripples(&v, 290, st.Hv + 72, 90, count: 2, color: Art.color(0xAEB8C4), opacity: 0.4)
            Kit.nearSpace(&v, st, anchorX: 720) { n in
                seaSubject(&n, st)
            }
        }
        ArtStyle.finish(&context, size, wash: 0.04, vignette: 0.14)
    }

    /// The long pale sand shore curving in from the trailing edge, with its wet margin.
    static func seaShore(_ v: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        let hv: CGFloat = st.hv
        var sand = Path()
        sand.move(to: CGPoint(x: 892, y: Hv + 8))
        sand.addQuadCurve(to: CGPoint(x: 540, y: Hv + 50), control: CGPoint(x: 660, y: Hv + 18))
        sand.addQuadCurve(to: CGPoint(x: 380, y: hv + 10), control: CGPoint(x: 420, y: Hv + 110))
        sand.addLine(to: CGPoint(x: 892, y: hv + 10))
        sand.closeSubpath()
        Kit.solid(&v, sand, stops: Kit.stops(0xBDB4A2, 0x8E8676, 0x5E584E), light: 0.18, shade: 0.24)
        var wet = Path()
        wet.move(to: CGPoint(x: 892, y: Hv + 10))
        wet.addQuadCurve(to: CGPoint(x: 540, y: Hv + 52), control: CGPoint(x: 660, y: Hv + 20))
        wet.addQuadCurve(to: CGPoint(x: 380, y: hv + 10), control: CGPoint(x: 420, y: Hv + 112))
        Art.stroke(&v, wet, Art.color(0xE6E2D6, 0.45), width: 2)
        Art.stroke(&v, wet.applying(CGAffineTransform(translationX: -6, y: 6)), Art.color(0x5A6476, 0.6), width: 3)
        ArtStyle.tooth(&v, in: CGRect(x: 420, y: Hv + 10, width: 472, height: hv - Hv), seed: 44, color: Color.white, alpha: 0.08)
        if st.tall > 0.25 {
            Kit.pebbles(&v, in: CGRect(x: 520, y: Hv + 200, width: 340, height: hv - Hv - 240), count: 22, seed: 12, color: 0x7A7468)
            Kit.rock(&v, cx: 470, baseY: hv - 40, width: 120, height: 54, color: 0x4A5058, seed: 13)
            Kit.grassTuft(&v, x: 860, baseY: hv - 60, height: 70, color: 0x3A4A3E, seed: 14)
        }
    }

    /// The tent, the horse beside it, rocks and a small crab.
    static func seaSubject(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        Kit.rock(&n, cx: 580, baseY: Hv + 62, width: 60, height: 30, color: 0x4A5058, seed: 21)
        Art.group(&n, x: 652, y: Hv + 84, scale: 0.84) { t in
            tent(&t)
        }
        Art.group(&n, x: 800, y: Hv + 104, scale: 0.55) { h in
            horse(&h, bend: 22, saddled: true, warm: CGPoint(x: -200, y: -120), warmAlpha: 0.22)
        }
        Kit.rock(&n, cx: 878, baseY: Hv + 116, width: 90, height: 46, color: 0x3E444C, seed: 22)
        Art.group(&n, x: 560, y: Hv + 128, scale: 0.28) { c in
            crab(&c)
        }
        Kit.grassTuft(&n, x: 872, baseY: Hv + 150, height: 44, color: 0x34443A, seed: 23)
    }
}

// MARK: - Unfolded: the cauldron in the courtyard

extension FirebirdArt {
    /// Night in the palace courtyard: carved gables and tented roofs against a black sky, a
    /// soft column of steam rising into the calm dark top of both panes; low on the trailing
    /// pane the great cauldron over its fire, the archer at the rim by the ladder, the horse
    /// bending his head to breathe on the water, and the crowd in shadow by torchlight.
    static func cauldronScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 220)
        let light = courtyard()
        let w: CGFloat = size.width
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.stars(&context, width: w, maxY: st.H - 200 * st.far, count: 24, seed: 31, color: Art.color(0xE6DCC8))
        let yard: Kit.Stops = [(Art.color(0x3A2418), 0), (Art.color(0x22140E), 0.5), (Art.color(0x120A08), 1)]
        Kit.ground(&context, width: w, top: st.H, bottom: size.height, stops: yard, seed: 25)
        Kit.designSpace(&context, st) { v in
            courtyardSkyline(&v, st)
            courtyardCrowd(&v, st)
            Kit.nearSpace(&v, st, anchorX: 700) { n in
                cauldronSubject(&n, st)
            }
        }
        ArtStyle.finish(&context, size, wash: 0.03, vignette: 0.2)
    }

    /// The palace round the courtyard: log halls with steep plank roofs, a tower with a tent
    /// roof, darkening upward so the words keep a quiet ground.
    static func courtyardSkyline(_ v: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        Art.group(&v, x: 70, y: Hv + 10) { t in
            woodTower(&t, width: 76, height: 250, roof: 0x3A2A22, lit: true)
        }
        Kit.house(&v, cx: 240, baseY: Hv + 14, width: 170, wallHeight: 80, roofHeight: 96, wall: logMid, roof: 0x3A2A22, style: .plank, door: 0x1A0F0A, windows: 2, lit: true, timber: logLit)
        Kit.house(&v, cx: 440, baseY: Hv + 8, width: 140, wallHeight: 70, roofHeight: 84, wall: logMid, roof: 0x34261E, style: .plank, door: 0x1A0F0A, windows: 1, lit: false, timber: logLit)
        Art.group(&v, x: 872, y: Hv + 12) { t in
            woodTower(&t, width: 90, height: 280, roof: 0x3A2A22, lit: false)
        }
        let shade: Kit.Stops = [(Art.color(0x060509, 0.92), 0), (Art.color(0x060509, 0.55), 0.6), (Art.color(0x060509, 0), 1)]
        Art.fillLinear(&v, Art.rect(0, 0, 892, Hv - 40), shade, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: Hv - 40))
        Kit.shadow(&v, 300, Hv + 20, width: 600, alpha: 0.3)
    }

    /// Townsfolk in shadow along the leading side, lit by two torches.
    static func courtyardCrowd(_ v: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        Art.group(&v, x: 150, y: Hv + 56, scale: 0.6) { t in
            torch(&t, height: 130)
        }
        Art.group(&v, x: 420, y: Hv + 60, scale: 0.6) { t in
            torch(&t, height: 130)
        }
        let people: [(CGFloat, CGFloat, UInt32, UInt32)] = [
            (60, 44, 0x2A2440, 0x3A2A22), (110, 62, 0x4A1E1A, 0x2A1E18), (200, 50, 0x24302A, 0x3A2A22),
            (262, 66, 0x3A2A3A, 0x4A3828), (330, 52, 0x4A2A1A, 0x2A1E18), (380, 70, 0x22283A, 0x3A2A22),
        ]
        Art.layer(&v, opacity: 0.85) { crowd in
            for one in people {
                Art.group(&crowd, x: one.0, y: Hv + one.1, scale: 0.5) { p in
                    onlooker(&p, cloth: one.2, cap: one.3, mirrored: true)
                }
            }
            Art.fill(&crowd, Art.rect(0, Hv - 80, 470, 160), Art.color(0x0E0A10, 0.35))
        }
        if st.tall > 0.25 {
            let hv: CGFloat = st.hv
            Kit.pebbles(&v, in: CGRect(x: 30, y: Hv + 160, width: 420, height: hv - Hv - 200), count: 20, seed: 33, color: 0x4A3A30)
            Kit.rock(&v, cx: 80, baseY: hv - 40, width: 120, height: 46, color: 0x3A3034, seed: 34)
        }
    }

    /// The cauldron (its ladder on the archer's side), the archer at the rim, the horse
    /// bending his head over the water.
    static func cauldronSubject(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        Art.group(&n, x: 690, y: Hv + 110, scale: 0.75) { c in
            Art.group(&c, scaleX: -1) { m in
                cauldron(&m, steam: 0.85)
            }
        }
        Art.group(&n, x: 596, y: Hv + 116, scale: 0.8) { a in
            Kit.shadow(&a, 0, 0, width: 70)
            Art.group(&a, scaleX: -1) { m in
                archer(&m, pose: .stand, look: CGPoint(x: -0.6, y: 0.3), mouth: .flat, mirrored: true)
            }
            Art.glow(&a, 6, -140, 36, Art.color(0xFF9A3C), alpha: 0.3)
        }
        Art.group(&n, x: 830, y: Hv + 90, scale: 0.68) { h in
            horse(&h, bend: 30, saddled: false, warm: CGPoint(x: -170, y: -100), warmAlpha: 0.45)
        }
        Art.group(&n, x: 540, y: Hv + 104, scale: 0.6) { t in
            torch(&t, height: 140)
        }
    }
}
