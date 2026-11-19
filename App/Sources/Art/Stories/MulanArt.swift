import SwiftUI
import OmramoCore

/// Concept art for "The Ballad of Mulan", drawn in code (round 5; composed from the shared kit).
///
/// An Advanced, LIGHT story: the words sit in the top of both panes, so every unfolded scene is
/// a wide northern landscape with a low horizon (`Kit.stage(size, ground: 220)`), a calm pale sky
/// across the whole width, and the figures low in the bottom band. Loess yellow, willow and
/// millet green, the iron grey of armour; vermilion only in small strong places.
enum MulanArt {
    /// Draws the picture called `name`. Returns false for a name this story does not have.
    static func paint(_ name: String, role: ArtRole, in context: inout GraphicsContext, size: CGSize) -> Bool {
        guard size.width > 0, size.height > 0 else { return false }
        switch (name, role) {
        case ("scene-loom", .sceneUnfolded): loomScene(&context, size)
        case ("scene-loom", .sceneFolded): loomFolded(&context, size)
        case ("scene-river", .sceneUnfolded): riverScene(&context, size)
        case ("scene-river", .sceneFolded): riverFolded(&context, size)
        case ("scene-frontier", .sceneUnfolded): frontierScene(&context, size)
        case ("scene-frontier", .sceneFolded): frontierFolded(&context, size)
        case ("scene-home", .sceneUnfolded): homeScene(&context, size)
        case ("scene-home", .sceneFolded): homeFolded(&context, size)
        case ("see-loom", .picture): loomPicture(&context, size)
        case ("see-yellow-river", .picture): riverPicture(&context, size)
        case ("see-northern-grasslands", .picture): grasslandsPicture(&context, size)
        case ("see-the-ballad", .picture): balladPicture(&context, size)
        case ("char-mulan", .portrait): mulanPortrait(&context, size)
        case ("char-father", .portrait): fatherPortrait(&context, size)
        case ("face-mulan", .face): mulanFace(&context, size)
        case ("face-father", .face): fatherFace(&context, size)
        case ("face-comrade", .face): comradeFace(&context, size)
        case ("cover", .cover): coverPicture(&context, size)
        default:
            return false
        }
        return true
    }

    /// The bottom of the picture in the units of `Kit.nearSpace` (the design bottom, ungrown).
    static func nearFloor(_ st: Kit.Stage) -> CGFloat {
        let below: CGFloat = (st.hv - st.Hv) / st.grow
        return st.Hv + below
    }

    // MARK: - scene-loom: the courtyard on a spring morning (pages 1–4)

    static func loomScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 220)
        let light = day()
        let w: CGFloat = size.width
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.sun(&context, 92, st.H - 64 * st.far, 17 * st.far, light: light)
        Kit.cloud(&context, 250, st.H - 300 * st.far, scale: 0.7 * st.far, color: Color.white.opacity(0.55))
        Kit.cloud(&context, 690, st.H - 340 * st.far, scale: 0.55 * st.far, color: Color.white.opacity(0.5))
        loessHills(&context, width: w, horizon: st.H, scale: st.far, light: light, seed: 3)
        Kit.farTrees(&context, x0: 30, x1: 250, baseY: st.H - 3 * st.far, height: 30 * st.far, count: 7, color: light.mid.opacity(0.55), seed: 4)
        Kit.farHouse(&context, cx: 120, baseY: st.H - 2 * st.far, width: 34 * st.far, height: 16 * st.far, wall: light.far, roof: light.mid.opacity(0.7), flat: true)
        Kit.farHouse(&context, cx: 170, baseY: st.H - 2 * st.far, width: 28 * st.far, height: 14 * st.far, wall: light.far, roof: light.mid.opacity(0.7), flat: true)
        ArtStyle.atmosphere(&context, width: w, top: st.H - 120 * st.far, bottom: st.H, color: light.haze, alpha: 0.3)
        Kit.ground(&context, width: w, top: st.H, bottom: size.height, stops: Kit.stops(0xE6CB92, 0xD8B67A, 0xC29C62))
        Kit.designSpace(&context, st) { v in
            loomBackWall(&v, st)
            Kit.nearSpace(&v, st) { n in
                loomHouse(&n, st)
                loomYard(&n, st)
                loomNear(&n, st)
            }
        }
        ArtStyle.finish(&context, size, wash: 0.08, vignette: 0.08)
    }

    /// The courtyard's back wall across both panes, the tiled gate and the willow over it, and
    /// the well on the leading side: all low, under the words.
    static func loomBackWall(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        earthWall(&context, x0: -20, x1: 600, baseY: H + 20, height: 34, color: wallTone, seed: 2)
        tileGate(&context, cx: 360, baseY: H + 22, width: 66, height: 62)
        willow(&context, x: 430, baseY: H + 18, height: 118, seed: 5)
        Kit.well(&context, cx: 196, baseY: H + 46, width: 40, height: 54, stone: 0xA89A80, roofed: true)
        Kit.shadow(&context, 196, H + 46, width: 52)
        // A woodpile against the wall, left of the gate.
        var logs = Path()
        let ends: [(CGFloat, CGFloat)] = [(262, 34), (274, 34), (286, 34), (268, 25), (280, 25)]
        for end in ends {
            logs.addPath(Art.ellipse(end.0, H + end.1, 6.4, 5.4))
        }
        Kit.shadow(&context, 274, H + 40, width: 44)
        Kit.solid(&context, logs, Art.color(0x9A7048), light: 0.3, shade: 0.24)
        var rings = Path()
        for end in ends {
            rings.addPath(Art.circle(end.0 - 0.6, H + end.1 - 0.4, 2.4))
        }
        Art.stroke(&context, rings, Art.color(0x6B4A2E, 0.6), width: 0.9)
        Kit.grass(&context, in: CGRect(x: 0, y: H + 24, width: 600, height: 14), count: 40, seed: 7, color: Art.color(0x8C9A5A, 0.7), height: 7)
    }

    /// The low earth house on the trailing pane: its open doorway, the loom set in it and Mulan
    /// at the loom, shuttle in hand.
    static func loomHouse(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        let foot: CGFloat = H + 112
        let wallTop: CGFloat = H - 50
        Kit.shadow(&context, 760, foot, width: 330)
        Kit.wall(&context, rect: CGRect(x: 590, y: wallTop, width: 320, height: foot - wallTop), color: houseTone)
        earthCourses(&context, CGRect(x: 590, y: wallTop + 8, width: 320, height: foot - wallTop - 14), seed: 9)
        Kit.roof(&context, cx: 760, eaveY: wallTop, width: 370, height: 26, color: tileTone, style: .tile)
        // The doorway: warm dusk inside, a timber frame.
        let door = CGRect(x: 640, y: H - 30, width: 150, height: foot - (H - 30))
        let inside: Kit.Stops = [(Art.color(0x5A3E2A), 0), (Art.color(0x6E4E34), 1)]
        Art.fillLinear(&context, Path(door), inside, from: CGPoint(x: door.minX, y: door.minY), to: CGPoint(x: door.maxX, y: door.maxY))
        Art.glow(&context, 700, foot - 40, 90, Art.color(0xF6DFA8), alpha: 0.28)
        var frame = Path()
        frame.addRect(CGRect(x: door.minX - 7, y: door.minY - 8, width: 7, height: door.height + 8))
        frame.addRect(CGRect(x: door.maxX, y: door.minY - 8, width: 7, height: door.height + 8))
        frame.addRect(CGRect(x: door.minX - 12, y: door.minY - 12, width: door.width + 24, height: 8))
        Kit.solid(&context, frame, Art.color(0x7A5A3A), light: 0.3, shade: 0.24)
        // A small lattice window with paper panes.
        latticeWindow(&context, CGRect(x: 820, y: H - 14, width: 46, height: 42))
        // The loom in the doorway, Mulan on her stool behind its breast beam.
        loom(&context, x: 716, baseY: foot, scale: 0.62, cloth: 0.55)
        let seatX: CGFloat = 752
        stool(&context, x: seatX + 4, baseY: foot, height: 24.5, width: 26)
        Art.group(&context, x: seatX, y: foot, scale: 0.72) { g in
            Kit.person(&g, mulanHomeLook(), pose: .sit, look: CGPoint(x: -0.6, y: 0.4), mouth: .flat)
            hairPins(&g, head: CGPoint(x: 6, y: -128))
            let hand: CGPoint = Kit.hand(mulanHomeLook(), pose: .sit)
            shuttle(&g, x: hand.x - 4, y: hand.y - 2, scale: 1.2)
        }
        // Morning light falling in across the threshold.
        let spill = Art.polygon([CGPoint(x: 640, y: foot), CGPoint(x: 790, y: foot), CGPoint(x: 760, y: foot + 14), CGPoint(x: 610, y: foot + 14)])
        Art.fill(&context, spill, Art.color(0xFFF0C8, 0.35))
    }

    /// The yard: Father on the chopping block in the shade of the wall mending a halter, and
    /// the hens scratching in the dust.
    static func loomYard(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        let blockY: CGFloat = H + 92
        Kit.shadow(&context, 540, blockY, width: 52, alpha: 0.3)
        let block: Path = Art.svg("M520,\(blockY) L522,\(blockY - 22) C530,\(blockY - 26) 552,\(blockY - 26) 560,\(blockY - 22) L562,\(blockY) Z")
        Kit.solid(&context, block, Art.color(0x8E6A44), light: 0.28, shade: 0.26)
        Art.fill(&context, Art.ellipse(541, blockY - 23, 19, 4), Art.color(0xC9A878))
        Kit.shadow(&context, 548, blockY, width: 80, alpha: 0.18)
        Art.group(&context, x: 540, y: blockY + 2, scale: 0.66, scaleX: -1) { g in
            Kit.person(&g, fatherLook(), pose: .sit, look: CGPoint(x: -0.5, y: 0.3), mouth: .flat, mirrored: true)
            let hand: CGPoint = Kit.hand(fatherLook(), pose: .sit)
            halter(&g, x: hand.x - 6, y: hand.y + 2, scale: 1)
        }
        let hens: [(CGFloat, CGFloat, CGFloat, Bool)] = [(462, 100, 0.46, false), (506, 116, 0.42, true), (604, 126, 0.4, false)]
        for hen in hens {
            Kit.shadow(&context, hen.0, H + hen.1, width: 30 * hen.2 * 2)
            let flip: CGFloat = hen.3 ? -1 : 1
            Art.group(&context, x: hen.0, y: H + hen.1, scale: hen.2, scaleX: flip) { g in
                Kit.bird(&g, henLook(), pose: .peck, mirrored: hen.3)
            }
        }
        Kit.pebbles(&context, in: CGRect(x: 440, y: H + 104, width: 180, height: 30), count: 14, seed: 12, color: 0xB89A70)
    }

    /// The foreground: a trodden path toward the viewer on a tall window, tufts at the corners.
    static func loomNear(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        let floor: CGFloat = nearFloor(st)
        if floor - H > 150 {
            let path = Art.svg("M600,\(H + 130) C560,\(H + 170) 470,\(floor - 60) 380,\(floor + 4) L560,\(floor + 4) C600,\(floor - 70) 640,\(H + 170) 660,\(H + 130) Z")
            Art.fill(&context, path, Art.color(0xEAD3A0, 0.6))
            Kit.pebbles(&context, in: CGRect(x: 420, y: H + 150, width: 240, height: floor - H - 160), count: 18, seed: 14, color: 0xB0946A)
            Kit.grass(&context, in: CGRect(x: 20, y: H + 140, width: 360, height: floor - H - 150), count: 26, seed: 15, color: Art.color(0x7E9A5C, 0.8), height: 10)
            Kit.flowers(&context, in: CGRect(x: 60, y: H + 160, width: 260, height: floor - H - 180), count: 12, seed: 16, petal: 0xF4EEDC)
            Kit.bush(&context, x: 120, baseY: floor - 10, width: 120, palette: willowGreens(), seed: 17)
        }
        Kit.grassTuft(&context, x: 30, baseY: floor + 2, height: 70, color: 0x5E7A3A, seed: 18)
        Kit.grassTuft(&context, x: 878, baseY: floor + 2, height: 64, color: 0x5E7A3A, seed: 19)
    }

    // MARK: - scene-river: the Yellow River at a pale gold evening (pages 5, 9, 10)

    static func riverScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 220)
        let light = evening()
        let w: CGFloat = size.width
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.sun(&context, 150, st.H - 84 * st.far, 19 * st.far, light: light)
        Kit.cloud(&context, 330, st.H - 310 * st.far, scale: 0.6 * st.far, color: Color.white.opacity(0.45))
        Kit.cloud(&context, 760, st.H - 360 * st.far, scale: 0.5 * st.far, color: Color.white.opacity(0.4))
        loessCliffs(&context, width: w, horizon: st.H, scale: st.far, light: light)
        ArtStyle.atmosphere(&context, width: w, top: st.H - 90 * st.far, bottom: st.H, color: light.haze, alpha: 0.32)
        let flow: Kit.Stops = [(Art.color(0xCDA866), 0), (Art.color(0xB68C4C), 0.5), (Art.color(0x9A743C), 1)]
        Kit.water(&context, width: w, top: st.H, bottom: size.height, stops: flow, light: light, ripples: 70, seed: 33)
        Kit.glints(&context, x: 150, top: st.H, depth: 130 * st.fit, color: Art.color(0xFFF0C8), count: 34, seed: 9)
        Kit.swells(&context, width: w, top: st.H + 8, bottom: size.height, rows: 7, crest: Art.color(0xF2D9A0), seed: 21)
        Kit.designSpace(&context, st) { v in
            riverDrift(&v, st)
            Kit.nearSpace(&v, st) { n in
                riverBank(&n, st)
                riverCamp(&n, st)
            }
        }
        ArtStyle.finish(&context, size, wash: 0.08, vignette: 0.08)
    }

    /// A whole tree carried past on the brown water, roots and all, and a sandbar far off on
    /// the leading side where two comrades rest with their horses (pages 9 and 10).
    static func riverDrift(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        Art.fill(&context, Art.ellipse(122, H + 36, 92, 9), Art.color(0xD8BC86))
        Art.fill(&context, Art.ellipse(130, H + 34, 70, 5), Art.color(0xE6CE9C))
        Art.group(&context, x: 96, y: H + 35, scale: 0.3) { g in
            Kit.shadow(&g, 0, 0, width: 150)
            Kit.beast(&g, bayLook(), pose: .stand, mood: .calm)
        }
        Art.group(&context, x: 150, y: H + 36, scale: 0.3) { g in
            Kit.person(&g, comradeLook(), pose: .sit, mouth: .smile)
        }
        Art.group(&context, x: 176, y: H + 36, scale: 0.28, scaleX: -1) { g in
            Kit.person(&g, mulanSoldierLook(), pose: .stand, mouth: .flat, mirrored: true)
        }
        // The drifting tree.
        let tx: CGFloat = 290
        let ty: CGFloat = H + 74
        let log = Art.svg("M\(tx - 70),\(ty) C\(tx - 40),\(ty - 7) \(tx + 20),\(ty - 8) \(tx + 50),\(ty - 4) L\(tx + 52),\(ty + 4) C\(tx + 20),\(ty + 4) \(tx - 40),\(ty + 6) \(tx - 70),\(ty + 4) Z")
        Kit.solid(&context, log, Art.color(0x5E4632), light: 0.3, shade: 0.26)
        let limbs = Art.svg("M\(tx - 40),\(ty - 4) C\(tx - 52),\(ty - 18) \(tx - 60),\(ty - 22) \(tx - 72),\(ty - 24) M\(tx - 10),\(ty - 6) C\(tx - 14),\(ty - 22) \(tx - 6),\(ty - 30) \(tx - 2),\(ty - 36) M\(tx + 52),\(ty) C\(tx + 62),\(ty - 12) \(tx + 70),\(ty - 8) \(tx + 78),\(ty - 16) M\(tx + 52),\(ty + 2) C\(tx + 64),\(ty + 4) \(tx + 72),\(ty - 2) \(tx + 80),\(ty + 2)")
        Art.stroke(&context, limbs, Art.color(0x5E4632), width: 2.6)
        Kit.ripples(&context, tx - 8, ty + 4, 150, count: 2, color: Art.color(0xF2D9A0), opacity: 0.6)
    }

    /// The near bank of yellow earth, rising from the water to the trailing edge.
    static func riverBank(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        let floor: CGFloat = nearFloor(st) + 60
        let bank = Art.svg("M1000,\(H + 4) L900,\(H + 4) C760,\(H + 10) 620,\(H + 34) 530,\(H + 64) C470,\(H + 86) 420,\(H + 124) 300,\(H + 142) C160,\(H + 154) 0,\(H + 152) -400,\(H + 158) L-400,\(floor) L1000,\(floor) Z")
        let earth: Kit.Stops = [(Art.color(0xE2C288), 0), (Art.color(0xCDA66C), 0.5), (Art.color(0xAE8650), 1)]
        Kit.solid(&context, bank, stops: earth, light: 0.22, shade: 0.2)
        let lip = Art.svg("M900,\(H + 5) C760,\(H + 11) 620,\(H + 35) 530,\(H + 65) C470,\(H + 87) 420,\(H + 125) 300,\(H + 143) C160,\(H + 155) 0,\(H + 153) -400,\(H + 159)")
        Art.stroke(&context, lip, Art.color(0xF4DFAE, 0.8), width: 2.2)
        Kit.ripples(&context, 470, H + 92, 90, count: 2, color: Art.color(0xF2D9A0), opacity: 0.5)
        Kit.grass(&context, in: CGRect(x: 520, y: H + 40, width: 372, height: 80), count: 30, seed: 25, color: Art.color(0x9A8A4A, 0.7), height: 9)
        Kit.pebbles(&context, in: CGRect(x: 440, y: H + 130, width: 300, height: 30), count: 14, seed: 26, color: 0xA88A5E)
        let bottom: CGFloat = nearFloor(st)
        if bottom - H > 190 {
            Kit.grass(&context, in: CGRect(x: 0, y: H + 170, width: 892, height: bottom - H - 180), count: 40, seed: 27, color: Art.color(0x8C8A4A, 0.75), height: 11)
            Kit.rock(&context, cx: 160, baseY: bottom - 30, width: 90, height: 40, color: 0xB8945E, seed: 28)
            Kit.pebbles(&context, in: CGRect(x: 240, y: H + 180, width: 400, height: bottom - H - 200), count: 22, seed: 29, color: 0xA88A5E)
        }
        Kit.reeds(&context, x: 26, baseY: bottom + 4, count: 7, height: 96, seed: 30, color: 0x6E7A3A)
        Kit.grassTuft(&context, x: 880, baseY: bottom + 2, height: 66, color: 0x7A7A3A, seed: 31)
    }

    /// The camp: the hobbled bay, the small fire with its thread of smoke, the armour laid on
    /// the bank, and Mulan sitting by the fire listening to the river.
    static func riverCamp(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        let horseY: CGFloat = H + 88
        Kit.shadow(&context, 812, horseY, width: 170)
        Art.group(&context, x: 812, y: horseY, scale: 0.74) { g in
            bayHorse(&g, pose: .stand, mood: .calm, saddled: false)
            Art.stroke(&g, Art.svg("M-62,-6 C-56,-2 -50,-2 -44,-6"), Art.color(0x8A6A44), width: 2.4)
        }
        // The armour laid on the bank beside her, the helmet by it.
        let laid = Art.svg("M548,\(H + 118) C552,\(H + 106) 600,\(H + 104) 612,\(H + 112) L606,\(H + 124) C584,\(H + 128) 560,\(H + 128) 548,\(H + 118) Z")
        Kit.shadow(&context, 580, H + 124, width: 76)
        lamellar(&context, laid, box: CGRect(x: 548, y: H + 104, width: 64, height: 24), row: 5.4, frost: false)
        Art.group(&context, x: 534, y: H + 112, scale: 0.5) { g in
            helmet(&g, head: .zero, frost: false)
        }
        // The fire and its smoke.
        let fireX: CGFloat = 640
        let fireY: CGFloat = H + 116
        var smoke = Path()
        smoke.move(to: CGPoint(x: fireX, y: fireY - 34))
        smoke.addCurve(to: CGPoint(x: fireX + 30, y: H - 40), control1: CGPoint(x: fireX - 16, y: H + 20), control2: CGPoint(x: fireX + 40, y: H + 10))
        Art.stroke(&context, smoke, Art.color(0xF6EEDC, 0.55), width: 5)
        Kit.campfire(&context, cx: fireX, baseY: fireY, scale: 0.6)
        // Mulan on a low stone, her face lit by the fire, in her soldier's tunic.
        Kit.rock(&context, cx: 706, baseY: H + 112, width: 40, height: 24, color: 0xA88A64, seed: 34)
        Kit.shadow(&context, 696, H + 112, width: 70)
        Art.group(&context, x: 700, y: H + 112, scale: 0.78) { g in
            Kit.person(&g, mulanSoldierLook(), pose: .sit, look: CGPoint(x: -0.7, y: 0.2), mouth: .flat)
        }
        Art.glow(&context, 664, H + 70, 60, Art.color(0xFFB45A), alpha: 0.22)
    }

    // MARK: - scene-frontier: the earth wall at a white-blue winter dawn (pages 6–8)

    static func frontierScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 220)
        let light = dawn()
        let w: CGFloat = size.width
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.sun(&context, 110, st.H - 70 * st.far, 16 * st.far, light: light)
        Kit.cloud(&context, 560, st.H - 330 * st.far, scale: 0.5 * st.far, color: Color.white.opacity(0.4))
        snowRange(&context, horizon: st.H, scale: st.far, light: light)
        ArtStyle.atmosphere(&context, width: w, top: st.H - 120 * st.far, bottom: st.H, color: light.haze, alpha: 0.4)
        Kit.ground(&context, width: w, top: st.H, bottom: size.height, stops: Kit.stops(0xC9CBB4, 0xB4B292, 0x9C9676))
        Kit.flecks(&context, in: CGRect(x: 0, y: st.H + 4, width: w, height: size.height - st.H), count: 60, seed: 50, color: Color.white.opacity(0.6), radius: 0.6...1.4)
        Kit.designSpace(&context, st) { v in
            frontierWall(&v, st)
            Kit.nearSpace(&v, st) { n in
                frontierSoldiers(&n, st)
                frontierNear(&n, st)
            }
        }
        ArtStyle.finish(&context, size, wash: 0.07, vignette: 0.08)
    }

    /// Bare mountains streaked with snow along the horizon, in pale far tones.
    static func snowRange(_ context: inout GraphicsContext, horizon H: CGFloat, scale s: CGFloat, light: Kit.Light) {
        let snow: Color = Art.color(0xF4F6F8)
        let peaks: [(CGFloat, CGFloat, CGFloat, UInt32)] = [(100, 300, 70, 3), (380, 360, 96, 5), (650, 320, 84, 7), (880, 300, 66, 9)]
        for peak in peaks {
            Kit.mountain(&context, cx: peak.0, baseY: H + 2, width: peak.1 * s, height: peak.2 * s, color: light.far, snow: snow, seed: peak.3)
        }
        let low: Path = Kit.ridge(width: 900, y: H - 18 * s, amp: 12 * s, seed: 11, bottom: H + 4, step: 12)
        Art.fill(&context, low, light.mid.opacity(0.55))
    }

    /// A rider far off, as a small silhouette in one hazy colour (horse, rider and spear).
    static func tinyRider(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, scale: CGFloat, color: Color) {
        let shape = Art.svg("M-20,-14 C-22,-20 -18,-24 -14,-22 L-8,-14 L10,-14 C14,-14 16,-10 15,-4 L14,0 L11,0 L11,-6 L-7,-6 L-9,0 L-12,0 L-12,-8 C-15,-10 -18,-11 -20,-14 Z M-2,-14 L-3,-24 C-3,-28 3,-28 3,-24 L4,-14 Z")
        Art.group(&context, x: x, y: y, scale: scale) { g in
            Art.fill(&g, shape, color)
            Art.stroke(&g, Art.line(-6, -34, 4, -10), color, width: 1.2)
        }
    }

    /// The long earth wall zig-zagging over the land, its watch-towers with red pennants, and
    /// a thin line of riders far off on the leading side.
    static func frontierWall(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        earthWall(&context, x0: -200, x1: 440, baseY: H + 14, height: 18, color: 0xC8AE80, seed: 52)
        watchTower(&context, cx: 168, baseY: H + 16, scale: 0.4, seed: 53)
        let riders: [CGFloat] = [36, 64, 90, 118, 150, 176]
        for (index, rx) in riders.enumerated() {
            let bob: CGFloat = CGFloat(index % 2) * 1.5
            tinyRider(&context, x: rx, y: H + 40 + bob, scale: 0.7, color: Art.color(0x6E7276, 0.75))
        }
        Kit.shadow(&context, 120, H + 41, width: 200, alpha: 0.12)
    }

    /// The near stretch of wall and its tower, the comrade on foot, and Mulan on her bay in her
    /// father's iron, frost on the plates and her breath white.
    static func frontierSoldiers(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        earthWall(&context, x0: 430, x1: 1000, baseY: H + 44, height: 38, color: wallTone, seed: 54)
        watchTower(&context, cx: 470, baseY: H + 48, scale: 0.86, seed: 55)
        Kit.shadow(&context, 600, H + 92, width: 60)
        Art.group(&context, x: 600, y: H + 92, scale: 0.56, scaleX: -1) { g in
            soldier(&g, comradeLook(), pose: .stand, gaze: CGPoint(x: -0.4, y: 0), mouth: .smile, frost: true, mirrored: true)
            Art.stroke(&g, Art.line(-30, -40, -40, -230), Art.color(0x6E5236), width: 3.4)
            Art.fill(&g, Art.svg("M-40,-230 L-45,-248 L-37,-246 Z"), Art.color(ironHex))
        }
        let horseX: CGFloat = 724
        let foot: CGFloat = H + 130
        Kit.shadow(&context, horseX, foot, width: 180, alpha: 0.3)
        Art.group(&context, x: horseX, y: foot, scale: 0.74) { g in
            rider(&g, mulanSoldierLook(), pose: .stand, armoured: true, frost: true)
            breath(&g, x: -14, y: -198, scale: 1)
            Art.stroke(&g, Art.line(40, -40, 30, -250), Art.color(0x6E5236), width: 3.2)
            Art.fill(&g, Art.svg("M30,-250 L26,-268 L34,-266 Z"), Art.color(ironHex))
        }
        Kit.pebbles(&context, in: CGRect(x: 520, y: H + 110, width: 140, height: 30), count: 10, seed: 56, color: 0x8E8A7C)
    }

    /// Frost and snow in the foreground: drifts in the corners, frosty tufts, stones.
    static func frontierNear(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        let floor: CGFloat = nearFloor(st)
        if floor - H > 180 {
            Kit.grass(&context, in: CGRect(x: 0, y: H + 160, width: 892, height: floor - H - 170), count: 44, seed: 57, color: Art.color(0x8E8C6A, 0.8), height: 11)
            Kit.rock(&context, cx: 300, baseY: floor - 40, width: 110, height: 46, color: 0x8E8A80, seed: 58)
            Kit.drift(&context, x0: 220, x1: 420, baseY: floor - 34, height: 10, bottom: floor - 20, snow: true)
            Kit.pebbles(&context, in: CGRect(x: 420, y: H + 170, width: 300, height: floor - H - 190), count: 20, seed: 59, color: 0x8E8A7C)
        }
        Kit.drift(&context, x0: -40, x1: 200, baseY: floor + 4, height: 26, bottom: floor + 40, snow: true)
        Kit.drift(&context, x0: 760, x1: 940, baseY: floor + 4, height: 22, bottom: floor + 40, snow: true)
        Kit.grassTuft(&context, x: 40, baseY: floor - 10, height: 60, color: 0x7E7A5A, seed: 60)
        Kit.grassTuft(&context, x: 876, baseY: floor - 8, height: 56, color: 0x7E7A5A, seed: 61)
    }

    // MARK: - scene-home: the village in late spring (pages 11–14)

    static func homeScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 220)
        let light = afternoon()
        let w: CGFloat = size.width
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.sun(&context, 70, st.H - 120 * st.far, 18 * st.far, light: light)
        Kit.cloud(&context, 380, st.H - 320 * st.far, scale: 0.65 * st.far, color: Color.white.opacity(0.5))
        Kit.cloud(&context, 800, st.H - 290 * st.far, scale: 0.5 * st.far, color: Color.white.opacity(0.45))
        loessHills(&context, width: w, horizon: st.H, scale: st.far, light: light, seed: 13)
        Kit.farTrees(&context, x0: 480, x1: 880, baseY: st.H - 2 * st.far, height: 34 * st.far, count: 9, color: light.mid.opacity(0.6), seed: 14)
        ArtStyle.atmosphere(&context, width: w, top: st.H - 110 * st.far, bottom: st.H, color: light.haze, alpha: 0.3)
        Kit.ground(&context, width: w, top: st.H, bottom: size.height, stops: Kit.stops(0xC4C892, 0xA6B676, 0x86A062))
        Kit.designSpace(&context, st) { v in
            homeField(&v, st)
            Kit.nearSpace(&v, st) { n in
                homeGate(&n, st)
                homeHouse(&n, st)
                homeNear(&n, st)
            }
        }
        ArtStyle.finish(&context, size, wash: 0.08, vignette: 0.08)
    }

    /// The field beyond: rows of young green millet across the leading pane and the two hares
    /// running side by side through them.
    static func homeField(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        Kit.furrows(&context, x0: -200, x1: 440, top: H + 4, bottom: H + 80, color: 0x8A7A4A, count: 14)
        let rows: [(CGFloat, CGFloat, UInt32)] = [(H + 14, 9, 0x8CA662), (H + 30, 12, 0x7E9A5C), (H + 50, 15, 0x6E8C50), (H + 74, 18, 0x5E7E44)]
        for (index, row) in rows.enumerated() {
            Kit.crop(&context, x0: -200, x1: 440, baseY: row.0, height: row.1, tops: false, color: row.2, seed: UInt32(70 + index))
        }
        Art.group(&context, x: 196, y: H + 58, scale: 0.42) { g in
            Kit.shadow(&g, 0, 0, width: 90)
            hare(&g)
        }
        Art.group(&context, x: 236, y: H + 62, scale: 0.42) { g in
            Kit.shadow(&g, 0, 0, width: 90)
            hare(&g)
        }
        Kit.crop(&context, x0: 140, x1: 300, baseY: H + 66, height: 10, tops: false, color: 0x6E8C50, seed: 75)
    }

    /// The old earth wall and its gate, the willow by it, and the family coming out: Father and
    /// Mother arm in arm, the sister in her red skirt, the tall younger brother.
    static func homeGate(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        earthWall(&context, x0: 300, x1: 660, baseY: H + 44, height: 34, color: wallTone, seed: 76)
        tileGate(&context, cx: 500, baseY: H + 46, width: 70, height: 66)
        willow(&context, x: 372, baseY: H + 44, height: 112, seed: 77)
        let feet: CGFloat = H + 100
        let family: [(CGFloat, Int)] = [(440, 0), (464, 1), (536, 2), (574, 3)]
        for member in family {
            Kit.shadow(&context, member.0, feet, width: 40)
        }
        Art.group(&context, x: 464, y: feet, scale: 0.6) { g in
            Kit.person(&g, motherLook(), pose: .walk, look: CGPoint(x: -0.4, y: 0), mouth: .smile)
        }
        Art.group(&context, x: 440, y: feet, scale: 0.6) { g in
            Kit.person(&g, fatherLook(), pose: .walk, look: CGPoint(x: -0.4, y: 0), mouth: .smile)
            Art.stroke(&g, Art.svg("M12,-92 C24,-88 34,-86 44,-90"), Art.color(0x3D5A6E), width: 9)
        }
        Art.group(&context, x: 536, y: feet, scale: 0.6) { g in
            Kit.person(&g, sisterLook(), pose: .stand, look: CGPoint(x: -0.5, y: 0), mouth: .smile)
        }
        Art.group(&context, x: 574, y: feet, scale: 0.64) { g in
            Kit.person(&g, brotherLook(), pose: .stand, look: CGPoint(x: -0.5, y: 0), mouth: .grin)
        }
    }

    /// The low house on the trailing pane and, at its open window, Mulan in a soft red jacket
    /// combing out her long dark hair, the yellow flower on her forehead.
    static func homeHouse(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        let foot: CGFloat = H + 104
        let top: CGFloat = H - 40
        Kit.shadow(&context, 780, foot, width: 290)
        Kit.wall(&context, rect: CGRect(x: 660, y: top, width: 250, height: foot - top), color: houseTone)
        earthCourses(&context, CGRect(x: 660, y: top + 8, width: 250, height: foot - top - 14), seed: 78)
        Kit.roof(&context, cx: 790, eaveY: top, width: 300, height: 24, color: tileTone, style: .tile)
        let window = CGRect(x: 712, y: H - 20, width: 96, height: 74)
        windowWithMulan(&context, window)
        Kit.opening(&context, rect: CGRect(x: 846, y: H - 4, width: 40, height: foot - H + 4), arched: false, color: 0x7A5A3A)
    }

    /// The fresh grass of the foreground; on a tall window, flowers and a band of millet.
    static func homeNear(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        let floor: CGFloat = nearFloor(st)
        Kit.grass(&context, in: CGRect(x: 280, y: H + 104, width: 600, height: 30), count: 30, seed: 80, color: Art.color(0x6E8C50, 0.8), height: 9)
        if floor - H > 170 {
            Kit.flowers(&context, in: CGRect(x: 300, y: H + 150, width: 420, height: floor - H - 170), count: 18, seed: 81, petal: 0xF4EEDC)
            Kit.grass(&context, in: CGRect(x: 0, y: H + 140, width: 892, height: floor - H - 150), count: 40, seed: 82, color: Art.color(0x5E7E44, 0.8), height: 12)
            Kit.crop(&context, x0: -200, x1: 260, baseY: floor - 16, height: 40, tops: false, color: 0x5E7E44, seed: 83)
        }
        Kit.grassTuft(&context, x: 30, baseY: floor + 2, height: 70, color: 0x4E6E3A, seed: 84)
        Kit.grassTuft(&context, x: 878, baseY: floor + 2, height: 62, color: 0x4E6E3A, seed: 85)
    }
}
