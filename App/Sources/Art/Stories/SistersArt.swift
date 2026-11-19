import SwiftUI
import OmramoCore

/// Concept art for "The Two Sisters", drawn in code (round 5; composed from the shared kit).
///
/// Advanced tier, a LIGHT story: the words sit in the top of BOTH panes, so every unfolded
/// scene keeps its horizon low (`Kit.stage(size, ground: 220)`) under a pale Pacific-coast
/// mist, and the place — the narrows, the cedar-plank village, the canoes, the two peaks —
/// fills the lower band across the whole width.
enum SistersArt {
    /// Draws the picture called `name`. Returns false for a name this story does not have.
    static func paint(_ name: String, role: ArtRole, in context: inout GraphicsContext, size: CGSize) -> Bool {
        guard size.width > 0, size.height > 0 else { return false }
        switch (name, role) {
        case ("scene-bridge", .sceneUnfolded): bridgeScene(&context, size)
        case ("scene-bridge", .sceneFolded): bridgeFolded(&context, size)
        case ("scene-village", .sceneUnfolded): villageScene(&context, size)
        case ("scene-village", .sceneFolded): villageFolded(&context, size)
        case ("scene-canoes", .sceneUnfolded): canoesScene(&context, size)
        case ("scene-canoes", .sceneFolded): canoesFolded(&context, size)
        case ("scene-peaks", .sceneUnfolded): peaksScene(&context, size)
        case ("scene-peaks", .sceneFolded): peaksFolded(&context, size)
        case ("see-burrard-inlet", .picture): inletPicture(&context, size)
        case ("see-salmon", .picture): salmonPicture(&context, size)
        case ("see-feast", .picture): feastPicture(&context, size)
        case ("see-cedar-canoe", .picture): canoePicture(&context, size)
        case ("char-sisters", .portrait): sistersPortrait(&context, size)
        case ("char-chief", .portrait): chiefPortrait(&context, size)
        case ("face-sisters", .face): sistersFace(&context, size)
        case ("face-chief", .face): chiefFace(&context, size)
        case ("cover", .cover): coverPicture(&context, size)
        default:
            return false
        }
        return true
    }
}

// MARK: - Scene 1: the bridge today (early morning mist over the First Narrows)

extension SistersArt {
    static func bridgeScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 220)
        let light = mist()
        let w: CGFloat = size.width
        let H: CGFloat = st.H
        let s: CGFloat = st.far
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.cloud(&context, 760, H - 250 * s, scale: 1.1 * s, color: Color.white.opacity(0.5))
        Kit.cloud(&context, 330, H - 300 * s, scale: 0.8 * s, color: Color.white.opacity(0.4))
        // The two peaks, far and small above the right-hand ridges.
        let peakTone: Color = Art.color(0xA9B9B8)
        twinPeaks(&context, cx: 716, baseY: H - 48 * s, scale: 0.78 * s, rock: peakTone, snow: Art.color(0xF6F8F6), seed: 2)
        // The North Shore: a pale far range, mist, then the near ridges rising to the right.
        let farRange = Kit.peaks(width: w, y: H - 34 * s, amp: 46 * s, seed: 11, bottom: H + 6, sharp: 0.25)
        Art.fill(&context, farRange, light.far.opacity(0.6))
        ArtStyle.atmosphere(&context, width: w, top: H - 110 * s, bottom: H + 6, color: light.haze, alpha: 0.4)
        northShore(&context, width: w, horizon: H, scale: s, light: light)
        mistBand(&context, width: w, y: H - 10 * s, height: 26 * s, alpha: 0.55)
        // The narrows: fast green water.
        let sea: Kit.Stops = Kit.stops(0xA9C2B8, 0x5E8A7E, 0x2F5A55)
        Kit.water(&context, width: w, top: H, bottom: size.height, stops: sea, light: light, ripples: 70, seed: 41)
        Kit.designSpace(&context, st) { v in
            bridgeMiddle(&v, st)
            Kit.nearSpace(&v, st) { n in
                bridgeNear(&n, st)
            }
        }
        ArtStyle.finish(&context, size, wash: 0.08, vignette: 0.08)
    }

    /// The middle plane of the bridge scene, in design units: Stanley Park's cedars on the left
    /// shore, the green bridge across the trailing pane, the ship and its wake, the gulls.
    static func bridgeMiddle(_ v: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        let parkTone: Color = Art.color(0x3E5E57)
        // Stanley Park: a low wooded point reaching from the left to the bridge's south end.
        let point = Art.svg("M-10,\(Hv + 26) L-10,\(Hv - 6) C120,\(Hv - 14) 300,\(Hv - 16) 420,\(Hv - 14) C470,\(Hv - 13) 520,\(Hv - 4) 548,\(Hv + 10) L548,\(Hv + 26) Z")
        Art.fill(&v, point, parkTone.opacity(0.75))
        Kit.farTrees(&v, x0: 0, x1: 420, baseY: Hv - 6, height: 26, count: 22, color: parkTone.opacity(0.8), conifer: true, seed: 5)
        Kit.farTrees(&v, x0: 380, x1: 540, baseY: Hv + 2, height: 34, count: 9, color: Art.color(0x2F4E48), conifer: true, seed: 9)
        ArtStyle.atmosphere(&v, width: 892, top: Hv - 50, bottom: Hv + 26, color: Art.color(0xE6ECE8), alpha: 0.3)
        let firs = firGreens()
        Kit.conifer(&v, x: 486, baseY: Hv + 16, height: 62, palette: firs, seed: 3)
        Kit.conifer(&v, x: 512, baseY: Hv + 20, height: 50, palette: firs, seed: 6)
        Kit.conifer(&v, x: 462, baseY: Hv + 18, height: 44, palette: firs, seed: 8)
        // The ship passes under the main span, heading out to sea (to the left).
        containerShip(&v, x: 640, waterY: Hv + 22, length: 120)
        // The bridge.
        bridge(&v, south: 530, north: 900, towerA: 606, towerB: 780, deckY: Hv - 30, top: Hv - 84, waterY: Hv + 10)
        Art.fill(&v, Art.rect(0, Hv - 92, 892, 70), Art.color(0xEEF2EF, 0.12))
        // Gulls hanging in the wind beside the railing.
        gull(&v, x: 560, y: Hv - 52, scale: 0.9, glide: true)
        gull(&v, x: 596, y: Hv - 40, scale: 0.7, glide: false)
        Kit.birds(&v, 250, Hv - 44, scale: 0.7, color: Art.color(0x6E8F86, 0.6))
    }

    /// The near plane of the bridge scene: a strip of the near shore with drift logs and rocks.
    static func bridgeNear(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        let bottom: CGFloat = st.hv + 40
        let rise: CGFloat = min(90, st.extra * 0.45)
        let beachTop: CGFloat = Hv + 190 - rise
        Kit.swells(&n, width: 892, top: Hv + 40, bottom: beachTop, rows: 6, crest: Color.white, seed: 4)
        // The near shore, a grey pebble beach across the bottom left.
        let beach = Art.svg("M-20,\(bottom) L-20,\(beachTop + 4) C80,\(beachTop - 8) 220,\(beachTop - 2) 330,\(beachTop + 14) C380,\(beachTop + 22) 420,\(beachTop + 40) 440,\(bottom) Z")
        Kit.solid(&n, beach, stops: Kit.stops(0xB9B6AA, 0x8A877C), light: 0.2, shade: 0.2)
        let pebbleBox = CGRect(x: 0, y: beachTop + 6, width: 400, height: max(10, bottom - beachTop - 6))
        Kit.pebbles(&n, in: pebbleBox, count: 40, seed: 13, color: 0x9A9488)
        Kit.ripples(&n, 330, beachTop + 10, 90, count: 2, color: Color.white, opacity: 0.5)
        driftLog(&n, x: 150, y: beachTop + 22, length: 150, tilt: -0.04)
        Kit.rock(&n, cx: 300, baseY: beachTop + 34, width: 46, height: 26, color: 0x6E6A62, seed: 3)
        if st.tall > 0.25 {
            Kit.rock(&n, cx: 60, baseY: beachTop + 70, width: 60, height: 34, color: 0x6A665E, seed: 7)
            driftLog(&n, x: 250, y: beachTop + 80, length: 120, tilt: 0.05)
            Kit.grass(&n, in: CGRect(x: 0, y: beachTop + 40, width: 260, height: 50), count: 30, seed: 2, color: Art.color(0x5E7A5A), height: 12)
        }
        // A dark rock cropped by the bottom-right corner frames the trailing edge.
        Kit.rock(&n, cx: 870, baseY: nearBottom(st) + 20, width: 120, height: 70, color: 0x3E4A46, seed: 11)
    }
}

// MARK: - Scene 2: the village long ago (soft silver morning)

extension SistersArt {
    static func villageScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 220)
        let light = silver()
        let w: CGFloat = size.width
        let H: CGFloat = st.H
        let s: CGFloat = st.far
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.cloud(&context, 640, H - 280 * s, scale: 1.2 * s, color: Color.white.opacity(0.45))
        Kit.cloud(&context, 180, H - 330 * s, scale: 0.9 * s, color: Color.white.opacity(0.35))
        // Forested mountains across the inlet, no city, no bridge.
        Kit.ranges(&context, width: w, horizon: H, scale: s, light: light, mountains: true, seed: 7)
        Kit.farTrees(&context, x0: 0, x1: w, baseY: H - 4 * s, height: 12 * s, count: 50, color: light.near.opacity(0.3), conifer: true, seed: 27)
        mistBand(&context, width: w, y: H - 8 * s, height: 34 * s, alpha: 0.6)
        let sea: Kit.Stops = Kit.stops(0xBCCEC8, 0x7E9E96, 0x3E6A62)
        Kit.water(&context, width: w, top: H, bottom: size.height, stops: sea, light: light, ripples: 60, seed: 43)
        mistBand(&context, width: w, y: H + 10, height: 22, alpha: 0.45)
        Kit.designSpace(&context, st) { v in
            villageWater(&v, st)
            Kit.nearSpace(&v, st, anchorX: 700) { n in
                villageShore(&n, st)
                villagePeople(&n, st)
            }
            Kit.nearSpace(&v, st, anchorX: 0) { n in
                Kit.rock(&n, cx: 30, baseY: nearBottom(st) + 16, width: 110, height: 58, color: 0x3E4A46, seed: 5)
                Kit.rock(&n, cx: 110, baseY: nearBottom(st) + 24, width: 70, height: 34, color: 0x4A5652, seed: 9)
            }
        }
        ArtStyle.finish(&context, size, wash: 0.08, vignette: 0.08)
    }

    /// The open water before the village: a far point of firs, a fishing canoe, herring
    /// flashing in the shallows.
    static func villageWater(_ v: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        let point = Art.svg("M60,\(Hv + 8) C110,\(Hv - 4) 220,\(Hv - 8) 330,\(Hv + 2) C350,\(Hv + 5) 360,\(Hv + 8) 362,\(Hv + 10) Z")
        Art.fill(&v, point, Art.color(0x4E6E66, 0.7))
        Kit.farTrees(&v, x0: 100, x1: 320, baseY: Hv + 2, height: 22, count: 14, color: Art.color(0x3E5E57, 0.75), conifer: true, seed: 31)
        ArtStyle.atmosphere(&v, width: 892, top: Hv - 30, bottom: Hv + 12, color: Art.color(0xE6ECE8), alpha: 0.35)
        let riders: [Rider] = [(x: -24, cloth: bark, kind: 0), (x: 14, cloth: 0x8C6A4A, kind: 0)]
        canoe(&v, cx: 300, waterY: Hv + 46, length: 64, riders: riders, paddlesUp: false, beached: false)
        Kit.flecks(&v, in: CGRect(x: 120, y: Hv + 90, width: 220, height: 60), count: 18, seed: 7, color: Color.white, radius: 0.8...1.8)
        Kit.swells(&v, width: 892, top: Hv + 60, bottom: st.hv, rows: 6, crest: Color.white, seed: 6)
    }

    /// The near shore on the trailing side: the pebble beach, the forest behind, the long
    /// cedar-plank houses facing the water, smoke, drawn-up canoes, salmonberry in flower.
    static func villageShore(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        let bottom: CGFloat = st.hv + 60
        let firs = firGreens()
        Kit.farTrees(&n, x0: 590, x1: 960, baseY: Hv + 18, height: 46, count: 24, color: Art.color(0x2F4E46, 0.85), conifer: true, seed: 33)
        let trees: [(CGFloat, CGFloat, UInt32)] = [(612, 62, 2), (700, 76, 4), (760, 66, 5), (842, 84, 7), (900, 72, 8)]
        for tree in trees {
            Kit.conifer(&n, x: tree.0, baseY: Hv + 20, height: tree.1, palette: firs, seed: tree.2)
        }
        ArtStyle.atmosphere(&n, width: 1000, top: Hv - 70, bottom: Hv + 20, color: Art.color(0xE6ECE8), alpha: 0.22)
        let beach = Art.svg("M1000,\(bottom) L1000,\(Hv + 14) L640,\(Hv + 22) C580,\(Hv + 26) 540,\(Hv + 60) 520,\(Hv + 110) C505,\(Hv + 150) 470,\(Hv + 190) 440,\(bottom) Z")
        Kit.solid(&n, beach, stops: Kit.stops(0xB2AEA2, 0x8E8A7E, 0x77736A), light: 0.18, shade: 0.18)
        let foam = Art.svg("M640,\(Hv + 23) C580,\(Hv + 27) 540,\(Hv + 61) 520,\(Hv + 111) C505,\(Hv + 151) 470,\(Hv + 191) 440,\(bottom)")
        Art.stroke(&n, foam, Color.white.opacity(0.55), width: 1.6)
        let berm = Art.svg("M1000,\(Hv + 14) L640,\(Hv + 22) C624,\(Hv + 25) 612,\(Hv + 34) 604,\(Hv + 48) L1000,\(Hv + 48) Z")
        Art.fill(&n, berm, Art.color(0x6A7458))
        Kit.grass(&n, in: CGRect(x: 610, y: Hv + 30, width: 390, height: 18), count: 40, seed: 3, color: Art.color(0x55684A), height: 7)
        plankHouse(&n, x: 664, baseY: Hv + 47, width: 112, height: 46, depth: 26)
        plankHouse(&n, x: 796, baseY: Hv + 46, width: 128, height: 54, depth: 30)
        plankHouse(&n, x: 938, baseY: Hv + 47, width: 120, height: 50, depth: 28)
        smoke(&n, x: 690, y: Hv - 2, height: 64, seed: 3)
        smoke(&n, x: 830, y: Hv - 10, height: 70, seed: 5)
        Kit.bush(&n, x: 596, baseY: Hv + 50, width: 46, palette: berryGreens(), seed: 3)
        Kit.flowers(&n, in: CGRect(x: 578, y: Hv + 32, width: 40, height: 16), count: 7, seed: 4, petal: 0xE8708E, heart: 0xF6D27A)
        let canoes: [(CGFloat, CGFloat, CGFloat)] = [(700, 74, 92), (810, 70, 104), (920, 76, 98)]
        for c in canoes {
            canoe(&n, cx: c.0, waterY: Hv + c.1, length: c.2, riders: [], paddlesUp: false, beached: true)
        }
        Kit.pebbles(&n, in: CGRect(x: 540, y: Hv + 84, width: 400, height: 120), count: 60, seed: 21, color: 0x9A9488)
        if st.tall > 0.25 {
            driftLog(&n, x: 760, y: Hv + 178, length: 140, tilt: 0.03)
            Kit.rock(&n, cx: 640, baseY: Hv + 214, width: 60, height: 30, color: 0x6E6A62, seed: 4)
            Kit.bush(&n, x: 880, baseY: Hv + 232, width: 90, palette: berryGreens(), seed: 8)
            Kit.flowers(&n, in: CGRect(x: 840, y: Hv + 196, width: 80, height: 30), count: 10, seed: 9, petal: 0xE8708E, heart: 0xF6D27A)
        }
    }

    /// The chief and his two daughters at the water's edge: he has turned to them; they have
    /// come across the pebbles together, shoulders touching.
    static func villagePeople(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        Kit.shadow(&n, 562, Hv + 128, width: 40, alpha: 0.26)
        Art.group(&n, x: 562, y: Hv + 128, scale: 0.8, scaleX: -1) { g in
            chief(&g, look: CGPoint(x: -0.6, y: 0.1), mouth: .flat, mirrored: true)
        }
        Art.group(&n, x: 640, y: Hv + 132, scale: 0.78) { g in
            sisters(&g, look: CGPoint(x: -0.7, y: -0.1), mouth: .flat)
        }
        Kit.ripples(&n, 520, Hv + 132, 40, count: 1, color: Color.white, opacity: 0.4)
    }
}

// MARK: - Scene 3: the canoes come in (bright pale morning)

extension SistersArt {
    static func canoesScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 220)
        let light = bright()
        let w: CGFloat = size.width
        let H: CGFloat = st.H
        let s: CGFloat = st.far
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.sun(&context, 150, H - 24 * s, 13 * s, light: light)
        Kit.cloud(&context, 520, H - 320 * s, scale: 0.9 * s, color: Color.white.opacity(0.4))
        Kit.ranges(&context, width: w, horizon: H, scale: s, light: light, mountains: true, seed: 12)
        mistBand(&context, width: w, y: H - 4 * s, height: 22 * s, alpha: 0.5)
        let sea: Kit.Stops = Kit.stops(0xC6D8D2, 0x86AAA0, 0x3E6A62)
        Kit.water(&context, width: w, top: H, bottom: size.height, stops: sea, light: light, ripples: 70, seed: 47)
        Kit.glints(&context, x: 150, top: H, depth: size.height - H, color: Art.color(0xFFF4DC), count: 30, seed: 5)
        Kit.designSpace(&context, st) { v in
            canoesFar(&v, st)
            Kit.nearSpace(&v, st, anchorX: 700) { n in
                canoesBeach(&n, st)
                canoesNear(&n, st)
            }
        }
        ArtStyle.finish(&context, size, wash: 0.08, vignette: 0.08)
    }

    /// One canoe coming in toward the beach on the right: the hull mirrored so its bow leads.
    static func inboundCanoe(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, length: CGFloat, riders: [Rider], up: Bool) {
        Art.group(&context, x: x, y: y, scaleX: -1) { g in
            canoe(&g, cx: 0, waterY: 0, length: length, riders: riders, paddlesUp: up, beached: false)
        }
    }

    /// The long line of canoes from the far mouth of the inlet (left) toward the beach, and a
    /// welcome fire's smoke on a headland.
    static func canoesFar(_ v: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        let headland = Art.svg("M330,\(Hv + 6) C380,\(Hv - 10) 450,\(Hv - 16) 520,\(Hv - 6) C540,\(Hv - 2) 556,\(Hv + 4) 560,\(Hv + 8) Z")
        Art.fill(&v, headland, Art.color(0x4E7068, 0.75))
        Kit.farTrees(&v, x0: 370, x1: 520, baseY: Hv - 2, height: 20, count: 10, color: Art.color(0x3A5A52, 0.75), conifer: true, seed: 41)
        smoke(&v, x: 432, y: Hv - 14, height: 70, seed: 8)
        Kit.campfire(&v, cx: 432, baseY: Hv - 12, scale: 0.12)
        ArtStyle.atmosphere(&v, width: 892, top: Hv - 40, bottom: Hv + 10, color: Art.color(0xEAF1EE), alpha: 0.3)
        // The far marks on the water, the line growing longer.
        let far: [(CGFloat, CGFloat, CGFloat)] = [(40, 8, 22), (84, 11, 26), (130, 10, 24), (176, 15, 30), (226, 19, 36), (278, 24, 42)]
        let few: [Rider] = [(x: -20, cloth: bark, kind: 0), (x: 6, cloth: wool, kind: 1), (x: 26, cloth: 0x8C6A4A, kind: 0)]
        for c in far {
            inboundCanoe(&v, x: c.0, y: Hv + c.1, length: c.2, riders: few, up: true)
        }
        let families: [Rider] = [(x: -32, cloth: bark, kind: 0), (x: -14, cloth: wool, kind: 1), (x: 2, cloth: 0x9A7652, kind: 2), (x: 18, cloth: 0x7A5A40, kind: 0), (x: 34, cloth: 0x8C6A4A, kind: 0)]
        inboundCanoe(&v, x: 336, y: Hv + 34, length: 62, riders: families, up: true)
        inboundCanoe(&v, x: 404, y: Hv + 56, length: 80, riders: families, up: true)
        inboundCanoe(&v, x: 470, y: Hv + 40, length: 72, riders: few, up: true)
        Kit.birds(&v, 600, Hv - 56, scale: 0.7, color: Art.color(0x6A9088, 0.5))
    }

    /// The pebble beach on the right: forest and a house corner behind, people waiting at the
    /// top of the beach, the feast fires with salmon on cedar stakes, the chief and his
    /// daughters at the front.
    static func canoesBeach(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        let bottom: CGFloat = st.hv + 60
        let firs = firGreens()
        Kit.farTrees(&n, x0: 700, x1: 980, baseY: Hv + 40, height: 44, count: 16, color: Art.color(0x2F4E46, 0.85), conifer: true, seed: 43)
        let trees: [(CGFloat, CGFloat, UInt32)] = [(744, 58, 3), (812, 70, 5), (868, 64, 9)]
        for tree in trees {
            Kit.conifer(&n, x: tree.0, baseY: Hv + 42, height: tree.1, palette: firs, seed: tree.2)
        }
        plankHouse(&n, x: 900, baseY: Hv + 62, width: 120, height: 48, depth: 26)
        let beach = Art.svg("M1000,\(bottom) L1000,\(Hv + 40) L770,\(Hv + 46) C710,\(Hv + 50) 670,\(Hv + 80) 650,\(Hv + 120) C636,\(Hv + 150) 620,\(Hv + 190) 606,\(bottom) Z")
        Kit.solid(&n, beach, stops: Kit.stops(0xB6B2A6, 0x928E82, 0x7A766C), light: 0.18, shade: 0.18)
        let foam = Art.svg("M770,\(Hv + 47) C710,\(Hv + 51) 670,\(Hv + 81) 650,\(Hv + 121) C636,\(Hv + 151) 620,\(Hv + 191) 606,\(bottom)")
        Art.stroke(&n, foam, Color.white.opacity(0.6), width: 1.6)
        Kit.pebbles(&n, in: CGRect(x: 660, y: Hv + 70, width: 300, height: 140), count: 50, seed: 23, color: 0x9A9488)
        // Cedar mats and the fires of the feast at the top of the beach.
        Art.fill(&n, Art.rect(774, Hv + 76, 46, 9, radius: 2), Art.color(bark))
        Art.stroke(&n, Art.svg("M778,\(Hv + 80.5) L816,\(Hv + 80.5)"), Art.color(barkDark), width: 0.8, dash: [2, 1.4])
        Kit.campfire(&n, cx: 846, baseY: Hv + 84, scale: 0.3)
        salmonStake(&n, x: 834, baseY: Hv + 86, scale: 0.5)
        salmonStake(&n, x: 860, baseY: Hv + 86, scale: 0.5)
        // The village waiting at the top of the beach: no weapons in any hand.
        let crowd: [(CGFloat, CGFloat, Int)] = [(760, 66, 0), (790, 64, 1), (878, 70, 2), (910, 72, 0), (940, 70, 1)]
        for person in crowd {
            Kit.shadow(&n, person.0, Hv + person.1, width: 26, alpha: 0.22)
            Art.group(&n, x: person.0, y: Hv + person.1, scale: 0.46) { g in
                Kit.person(&g, villagerLook(person.2), pose: .stand, look: CGPoint(x: -0.8, y: 0), mouth: .flat)
            }
        }
        // The chief, his hands empty, and his daughters at the water's edge.
        Kit.shadow(&n, 676, Hv + 120, width: 34, alpha: 0.26)
        Art.group(&n, x: 676, y: Hv + 120, scale: 0.68) { g in
            chief(&g, look: CGPoint(x: -0.8, y: 0), mouth: .flat, mirrored: false)
        }
        Art.group(&n, x: 728, y: Hv + 116, scale: 0.64) { g in
            sisters(&g, look: CGPoint(x: -0.8, y: 0), mouth: .smile)
        }
    }

    /// The nearest canoe running in to the beach, a child leaning over the side; near swells.
    static func canoesNear(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        let riders: [Rider] = [(x: -34, cloth: bark, kind: 0), (x: -18, cloth: wool, kind: 1), (x: -4, cloth: 0x9A7652, kind: 2), (x: 10, cloth: 0xC9BCA0, kind: 1), (x: 24, cloth: 0x7A5A40, kind: 0), (x: 38, cloth: 0x8C6A4A, kind: 0)]
        inboundCanoe(&n, x: 556, y: Hv + 98, length: 128, riders: riders, up: true)
        Kit.swells(&n, width: 640, top: Hv + 120, bottom: st.hv + 40, rows: 5, crest: Color.white, seed: 9)
        if st.tall > 0.25 {
            let riders2: [Rider] = [(x: -26, cloth: bark, kind: 0), (x: -6, cloth: wool, kind: 1), (x: 14, cloth: 0x9A7652, kind: 2), (x: 32, cloth: 0x8C6A4A, kind: 0)]
            inboundCanoe(&n, x: 400, y: Hv + 196, length: 150, riders: riders2, up: true)
            Kit.rock(&n, cx: 20, baseY: nearBottom(st) + 30, width: 120, height: 60, color: 0x3E4A46, seed: 13)
        }
    }
}

// MARK: - Scene 4: the two peaks at evening (pale rose and gold)

extension SistersArt {
    static func peaksScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 220)
        let light = evening()
        let w: CGFloat = size.width
        let H: CGFloat = st.H
        let s: CGFloat = st.far
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.sun(&context, 96, H - 10 * s, 16 * s, light: light)
        Kit.cloud(&context, 300, H - 300 * s, scale: 1.0 * s, color: Art.color(0xFBEDE6, 0.5))
        // The two peaks, high above the inlet, catching the last light.
        twinPeaks(&context, cx: 690, baseY: H - 30 * s, scale: 1.55 * s, rock: Art.color(0xB2ACBE), snow: Art.color(0xF8D2BE), glow: Art.color(0xFFE0B4), seed: 6)
        Art.glow(&context, 660, H - 110 * s, 120 * s, Art.color(0xFFD9B0), alpha: 0.18)
        // The mountains below them already in blue shadow.
        let range = Kit.peaks(width: w, y: H - 22 * s, amp: 40 * s, seed: 15, bottom: H + 6, sharp: 0.3)
        Art.fill(&context, range, light.far)
        ArtStyle.atmosphere(&context, width: w, top: H - 80 * s, bottom: H + 6, color: light.haze, alpha: 0.3)
        let slopes = Kit.ridge(width: w, y: H - 10 * s, amp: 10 * s, seed: 29, bottom: H + 6)
        Art.fill(&context, slopes, light.mid)
        Kit.farTrees(&context, x0: 0, x1: w, baseY: H - 2 * s, height: 10 * s, count: 50, color: light.near.opacity(0.4), conifer: true, seed: 37)
        let sea: Kit.Stops = Kit.stops(0xD2C4C6, 0x8E8E9E, 0x4A5066)
        Kit.water(&context, width: w, top: H, bottom: size.height, stops: sea, light: light, ripples: 60, seed: 51)
        Kit.glints(&context, x: 96, top: H, depth: size.height - H, color: Art.color(0xFFE6C8), count: 34, seed: 9)
        Kit.designSpace(&context, st) { v in
            peaksShore(&v, st)
            Kit.nearSpace(&v, st, anchorX: 0) { n in
                peaksNear(&n, st)
            }
        }
        ArtStyle.finish(&context, size, wash: 0.08, vignette: 0.1)
    }

    /// The far shore at evening: the city's first lights, the bridge far and small, a canoe
    /// coming home, one eagle.
    static func peaksShore(_ v: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        // The city on the near side of the narrows: low pale towers on the leading pane.
        var towers = Path()
        let blocks: [(CGFloat, CGFloat, CGFloat)] = [(40, 16, 18), (62, 26, 12), (80, 20, 16), (102, 34, 12), (120, 24, 14), (140, 30, 10), (156, 18, 16), (178, 22, 12), (196, 14, 18), (220, 10, 20)]
        for b in blocks {
            towers.addPath(Art.rect(b.0, Hv + 8 - b.1, b.2, b.1 + 2))
        }
        Art.fill(&v, towers, Art.color(0x8A8EA4, 0.7))
        Art.fill(&v, Art.rect(0, Hv + 4, 420, 8), Art.color(0x6E7690, 0.6))
        var random = ArtRandom(61)
        var lights = Path()
        for _ in 0..<46 {
            let lx: CGFloat = 20 + Kit.rnd(&random) * 860
            let ly: CGFloat = Hv + 2 + Kit.rnd(&random) * 9
            lights.addPath(Art.circle(lx, ly, 0.9 + Kit.rnd(&random) * 0.7))
        }
        Art.fill(&v, lights, Art.color(0xFFD98A, 0.95))
        Art.glow(&v, 140, Hv + 6, 90, Art.color(0xFFD08A), alpha: 0.16)
        // The bridge, far and small, its lamps on.
        bridge(&v, south: 452, north: 650, towerA: 488, towerB: 574, deckY: Hv - 2, top: Hv - 26, waterY: Hv + 12)
        var lamps = Path()
        var lampX: CGFloat = 456
        while lampX < 648 {
            lamps.addPath(Art.circle(lampX, Hv - 3, 0.8))
            lampX += 9
        }
        Art.fill(&v, lamps, Art.color(0xFFE2A0))
        let riders: [Rider] = [(x: -20, cloth: bark, kind: 0), (x: 4, cloth: wool, kind: 1), (x: 24, cloth: 0x8C6A4A, kind: 0)]
        Art.group(&v, opacity: 0.85) { g in
            inboundCanoe(&g, x: 330, y: Hv + 62, length: 58, riders: riders, up: false)
        }
        eagle(&v, x: 556, y: Hv - 34, scale: 0.8)
        Kit.swells(&v, width: 892, top: Hv + 40, bottom: st.hv, rows: 6, crest: Art.color(0xF6E0D0), seed: 14)
    }

    /// Dark near rocks and a cedar bough at the bottom-left; a deeper shore on tall windows.
    static func peaksNear(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let foot: CGFloat = nearBottom(st)
        Kit.rock(&n, cx: 40, baseY: foot + 20, width: 130, height: 70, color: 0x3A4256, seed: 3)
        Kit.rock(&n, cx: 140, baseY: foot + 30, width: 80, height: 40, color: 0x444C60, seed: 8)
        if st.tall > 0.25 {
            driftLog(&n, x: 230, y: foot - 30, length: 130, tilt: -0.05)
            Kit.rock(&n, cx: 330, baseY: foot + 10, width: 70, height: 36, color: 0x4A5266, seed: 12)
        }
        let frame = CGSize(width: 892, height: foot)
        Kit.cornerLeaves(&n, size: frame, corner: 2, color: Art.color(0x2A3446), scale: 0.9, seed: 4)
    }

    /// The bottom edge of the picture in the units inside `Kit.nearSpace` (it grows about the
    /// horizon, so the frame's foot lies higher there on a tall window).
    static func nearBottom(_ st: Kit.Stage) -> CGFloat {
        let below: CGFloat = (st.hv - st.Hv) / st.grow
        return st.Hv + below
    }
}
