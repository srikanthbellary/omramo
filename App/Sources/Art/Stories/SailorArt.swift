import SwiftUI
import OmramoCore

/// Concept art for "The Shipwrecked Sailor", drawn in code (round 5; composed from the shared kit).
///
/// This file: the entry point and the four unfolded scenes. The cast (the Sailor, the Captain,
/// the golden Serpent, the ship, the fig tree) is in `SailorArt+Cast.swift`, the folded scenes
/// in `SailorArt+Folded.swift`, the tap pictures, portraits, face chips and the cover in
/// `SailorArt+Pictures.swift`.
enum SailorArt {
    /// Draws the picture called `name`. Returns false for a name this story does not have.
    static func paint(_ name: String, role: ArtRole, in context: inout GraphicsContext, size: CGSize) -> Bool {
        guard size.width > 0, size.height > 0 else { return false }
        switch (name, role) {
        case ("scene-ship", .sceneUnfolded): shipScene(&context, size)
        case ("scene-ship", .sceneFolded): shipFolded(&context, size)
        case ("scene-island", .sceneUnfolded): islandScene(&context, size)
        case ("scene-island", .sceneFolded): islandFolded(&context, size)
        case ("scene-serpent", .sceneUnfolded): serpentScene(&context, size)
        case ("scene-serpent", .sceneFolded): serpentFolded(&context, size)
        case ("scene-home", .sceneUnfolded): homeScene(&context, size)
        case ("scene-home", .sceneFolded): homeFolded(&context, size)
        case ("see-red-sea", .picture): redSeaPicture(&context, size)
        case ("see-incense", .picture): incensePicture(&context, size)
        case ("see-papyrus", .picture): papyrusPicture(&context, size)
        case ("char-sailor", .portrait): sailorPortrait(&context, size)
        case ("char-serpent", .portrait): serpentPortrait(&context, size)
        case ("face-sailor", .face): sailorChip(&context, size)
        case ("face-serpent", .face): serpentChip(&context, size)
        case ("face-captain", .face): captainChip(&context, size)
        case ("cover", .cover): coverPicture(&context, size)
        default:
            return false
        }
        return true
    }
}

// MARK: - scene-ship (unfolded)

extension SailorArt {
    /// The great ship on the Red Sea: a pale silver-lilac sky, one darker bank of storm cloud
    /// low on the trailing side, long rolling swells, and the ship large on the trailing pane
    /// with its wide square sail full and its oars out.
    static func shipScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 170)
        let light = storm()
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.sun(&context, 150, st.H - 46 * st.far, 24 * st.far, light: light)
        Kit.cloud(&context, 210, st.H * 0.36, scale: 0.8 * st.far, color: Color.white.opacity(0.6))
        stormBank(&context, st)
        Kit.water(&context, width: st.w, top: st.H, bottom: st.h, stops: seaStops(), light: light, ripples: 70)
        Kit.glints(&context, x: 150, top: st.H, depth: st.depth, color: Art.color(0xFFF3C8), count: 28)
        let rows: Int = 7 + Int(st.tall * 5)
        Kit.swells(&context, width: st.w, top: st.H + 10, bottom: st.h, rows: rows, crest: Color.white)
        Kit.birds(&context, 262, st.H - 38 * st.far, scale: st.far, color: Art.color(0x7C86A8))
        // A second sail, tiny and far off on the leading side: the sea is one place.
        Kit.boat(&context, cx: 96, waterY: st.H + 5, length: 30 * st.far, hull: 0x8A6A5A, sail: 0xF4EEDC, style: .nile)

        Kit.designSpace(&context, st) { v in
            Kit.nearSpace(&v, st, anchorX: 670) { n in
                rollers(&n, x0: 430, x1: 900, y: st.Hv + 54, height: 12)
                ship(&n, cx: 670, waterY: st.Hv + 80, length: 300, sailUp: true, bow: 0)
                rollers(&n, x0: 380, x1: 900, y: st.Hv + 112, height: 16)
            }
        }
        nearWave(&context, x0: -20, x1: 300, bottom: st.h, height: 44 * st.grow, seed: 3)
        nearWave(&context, x0: 560, x1: 912, bottom: st.h, height: 52 * st.grow, seed: 8)
        if st.tall > 0.25 {
            let top: CGFloat = st.H + st.depth * 0.62
            Kit.swells(&context, width: st.w, top: top, bottom: st.h, rows: 4, crest: Art.color(0xCFEAF2), seed: 40)
        }
        ArtStyle.finish(&context, size)
    }

    /// The storm, far off: a bank of grey-lilac cloud low on the trailing side with a veil of
    /// rain under it. The sky over the words stays light.
    static func stormBank(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let f: CGFloat = st.far
        let base: CGFloat = st.H - 26 * f
        // Rain: soft slanting streaks from the bank down to the horizon.
        var rain = Path()
        for i in 0..<16 {
            let x: CGFloat = 600 + CGFloat(i) * 19
            rain.move(to: CGPoint(x: x, y: base - 4))
            rain.addLine(to: CGPoint(x: x - 9 * f, y: st.H))
        }
        Art.stroke(&context, rain, Art.color(0x8E91B4, 0.3), width: 2.2)
        let puffs: [(CGFloat, CGFloat, CGFloat, UInt32)] = [
            (612, 0, 1.3, 0xB7B9D4), (716, -8, 1.8, 0xA7A9C8), (838, -2, 2.0, 0x9C9EC0), (770, 4, 1.2, 0x8E91B4), (892, 6, 1.4, 0x8E91B4),
        ]
        for puff in puffs {
            Kit.cloud(&context, puff.0, base + puff.1 * f, scale: puff.2 * f, color: Art.color(puff.3))
        }
        Art.fill(&context, Art.rect(560, base - 3, 340, 7 * f, radius: 3), Art.color(0x8E91B4, 0.55))
        ArtStyle.atmosphere(&context, width: st.w, top: st.H - 120 * f, bottom: st.H, color: Art.color(0xE8E6EE), alpha: 0.18)
    }

    /// A row of rolling wave backs between x0 and x1 at `y`, each with a pale crest: the
    /// middle-plane sea round the ship.
    static func rollers(_ context: inout GraphicsContext, x0: CGFloat, x1: CGFloat, y: CGFloat, height: CGFloat) {
        var backs = Path()
        var crests = Path()
        let run: CGFloat = height * 7
        var x: CGFloat = x0
        backs.move(to: CGPoint(x: x0, y: y + height))
        backs.addLine(to: CGPoint(x: x0, y: y))
        while x < x1 {
            let peak = CGPoint(x: x + run * 0.5, y: y - height)
            backs.addQuadCurve(to: CGPoint(x: x + run, y: y), control: peak)
            crests.move(to: CGPoint(x: x + run * 0.12, y: y - height * 0.2))
            crests.addQuadCurve(to: CGPoint(x: x + run * 0.7, y: y - height * 0.36), control: CGPoint(x: x + run * 0.4, y: y - height * 0.95))
            x += run
        }
        backs.addLine(to: CGPoint(x: x, y: y + height))
        backs.closeSubpath()
        let tone: Kit.Stops = [(Art.color(0x2A8DB0, 0.9), 0), (Art.color(0x1C7FA6, 0), 1)]
        Art.fillLinear(&context, backs, tone, from: CGPoint(x: 0, y: y - height), to: CGPoint(x: 0, y: y + height))
        Art.stroke(&context, crests, Color.white.opacity(0.7), width: max(1.4, height * 0.14))
    }

    /// Near-plane framing for the sea scenes: one dark, cropped wave rising from the bottom
    /// edge between x0 and x1, with foam on its crest.
    static func nearWave(_ context: inout GraphicsContext, x0: CGFloat, x1: CGFloat, bottom: CGFloat, height: CGFloat, seed: UInt32) {
        let span: CGFloat = x1 - x0
        guard span > 0, height > 0 else { return }
        var random = ArtRandom(seed)
        let lean: CGFloat = 0.3 + Kit.rnd(&random) * 0.3
        let top: CGFloat = bottom - height
        var wave = Path()
        wave.move(to: CGPoint(x: x0, y: bottom + 2))
        wave.addQuadCurve(to: CGPoint(x: x0 + span * lean, y: top), control: CGPoint(x: x0 + span * lean * 0.5, y: top + height * 0.1))
        wave.addQuadCurve(to: CGPoint(x: x1, y: bottom + 2), control: CGPoint(x: x0 + span * (lean + 0.3), y: top + height * 0.2))
        wave.closeSubpath()
        let tone: Kit.Stops = [(Art.color(0x14608F), 0), (Art.color(0x0B3F68), 1)]
        Art.fillLinear(&context, wave, tone, from: CGPoint(x: 0, y: top), to: CGPoint(x: 0, y: bottom))
        var foam = Path()
        foam.move(to: CGPoint(x: x0 + span * lean * 0.45, y: top + height * 0.34))
        foam.addQuadCurve(to: CGPoint(x: x0 + span * (lean + 0.22), y: top + height * 0.2), control: CGPoint(x: x0 + span * lean, y: top - height * 0.08))
        Art.stroke(&context, foam, Art.color(0xE8F6F8, 0.85), width: max(2, height * 0.08))
        let specks = CGRect(x: x0 + span * lean * 0.6, y: top - 4, width: span * 0.3, height: height * 0.3)
        Art.stipple(&context, in: specks, count: 14, seed: seed &+ 2, color: Color.white, alpha: 0.7, size: 0.8...2)
    }
}

// MARK: - scene-island (unfolded)

extension SailorArt {
    /// The island of plenty: an empty sea, the curve of a sandy shore with turquoise
    /// shallows and the plank at the water's edge, and on the trailing pane the fig trees
    /// heavy with fruit, with the Sailor sitting small beneath them, looking out to sea.
    static func islandScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 160)
        let light = day()
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.sun(&context, 120, st.H - 54 * st.far, 27 * st.far, light: light)
        Kit.cloud(&context, 270, st.H * 0.4, scale: 0.8 * st.far, color: Color.white.opacity(0.7))
        Kit.water(&context, width: st.w, top: st.H, bottom: st.h, stops: seaStops(), light: light, ripples: 50)
        Kit.glints(&context, x: 120, top: st.H, depth: st.depth, color: Art.color(0xFFF3C8), count: 34)
        Kit.swells(&context, width: st.w, top: st.H + 8, bottom: st.h, rows: 5, crest: Color.white)
        Kit.birds(&context, 300, st.H - 58 * st.far, scale: st.far, color: Art.color(0x5F97A8))

        Kit.designSpace(&context, st) { v in
            islandShore(&v, st)
            // The palm does not grow with the grove on a tall window: its fronds must stay
            // off the leading pane.
            datePalm(&v, x: 604, baseY: st.Hv + 20, height: 236, lean: -30, seed: 4)
            Kit.nearSpace(&v, st) { n in
                Art.group(&n, y: st.Hv) { g in
                    islandGrove(&g)
                }
            }
            islandNear(&v, st)
        }
        ArtStyle.finish(&context, size)
    }

    /// The outline of the beach in design units: everything right of and below a shore line
    /// that curves from the bottom of the leading pane up to the horizon on the trailing
    /// edge. `shift` moves the line to the left (for the bands of shallow water).
    static func shorePath(_ st: Kit.Stage, shift: CGFloat) -> Path {
        let Hv: CGFloat = st.Hv
        let hv: CGFloat = st.hv + 4
        var path = Path()
        path.move(to: CGPoint(x: 900, y: hv))
        path.addLine(to: CGPoint(x: 60 - shift, y: hv))
        path.addLine(to: CGPoint(x: 150 - shift, y: Hv + 150))
        path.addCurve(
            to: CGPoint(x: 560 - shift, y: Hv + 26),
            control1: CGPoint(x: 300 - shift, y: Hv + 90),
            control2: CGPoint(x: 420 - shift, y: Hv + 40)
        )
        path.addCurve(
            to: CGPoint(x: 900, y: Hv + 8),
            control1: CGPoint(x: 680 - shift * 0.5, y: Hv + 16),
            control2: CGPoint(x: 800, y: Hv + 10)
        )
        path.closeSubpath()
        return path
    }

    /// The shallows, the sand, the plank and a white heron fishing.
    static func islandShore(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        let hv: CGFloat = st.hv
        Art.fill(&context, shorePath(st, shift: 58), Art.color(0x6FD0CC, 0.6))
        Art.fill(&context, shorePath(st, shift: 30), Art.color(0xA6E6D8, 0.75))
        let sand: Path = shorePath(st, shift: 0)
        Art.stroke(&context, shorePath(st, shift: 6), Color.white.opacity(0.75), width: 3)
        Art.fillLinear(&context, sand, sandStops(), from: CGPoint(x: 0, y: Hv), to: CGPoint(x: 0, y: hv))
        let depth: CGFloat = max(1, hv - Hv)
        Art.clipped(&context, to: sand) { g in
            // Wet sand along the water's edge, and tooth over the dry.
            Art.stroke(&g, sand, Art.color(0xD9BE86, 0.55), width: 16)
            ArtStyle.tooth(&g, in: CGRect(x: 60, y: Hv, width: 840, height: depth), seed: 19, color: Art.color(0xB8935A), alpha: 0.16)
        }
        plank(&context, x: 392, y: Hv + 62, length: 68, tilt: -0.3)
        Kit.ripples(&context, 372, Hv + 74, 46, count: 2)
        // The heron stands in the shallows, low on the leading side.
        Kit.ripples(&context, 316, Hv + 82, 30, count: 2)
        Art.group(&context, x: 316, y: Hv + 80, scale: 0.5) { b in
            Kit.bird(&b, Kit.heronLook(), pose: .perch)
        }
    }

    /// The grove on the trailing pane, in units measured from the horizon (y 0): bushes and
    /// palms behind, the great fig tree, and the Sailor on a stone beneath it.
    static func islandGrove(_ context: inout GraphicsContext) {
        let greens: Kit.Greens = figGreens()
        // A low green rise behind the beach.
        let rise: Path = Art.svg("M560,26 C640,-4 760,-10 900,-6 L900,40 C780,30 660,30 560,26Z")
        Kit.solid(&context, rise, stops: meadowStops(), light: 0.2, shade: 0.16)
        figTree(&context, x: 872, baseY: 16, height: 250, spread: 210, seed: 8)
        Kit.bush(&context, x: 706, baseY: 22, width: 120, palette: greens, seed: 3)
        Kit.bush(&context, x: 842, baseY: 26, width: 110, palette: greens, seed: 6)
        figTree(&context, x: 772, baseY: 46, height: 350, spread: 340, seed: 2)
        // Fallen figs on the sand.
        var fallen = Path()
        let spots: [(CGFloat, CGFloat)] = [(716, 60), (742, 70), (806, 58), (690, 78)]
        for spot in spots {
            fallen.addEllipse(in: CGRect(x: spot.0 - 4, y: spot.1 - 4, width: 8, height: 7.4))
        }
        Art.fill(&context, fallen, Art.color(figPurple))

        // The Sailor, on a stone in the shade, looking out over the empty sea.
        Kit.rock(&context, cx: 668, baseY: 76, width: 62, height: 30, color: 0xC8B690, seed: 5)
        Kit.shadow(&context, 646, 76, width: 70)
        Art.group(&context, x: 656, y: 73, scale: 0.8) { s in
            sailor(&s, pose: .sit, look: CGPoint(x: -0.8, y: -0.1), mouth: .flat)
        }
        melon(&context, x: 806, baseY: 96, width: 46)
        melon(&context, x: 848, baseY: 86, width: 34)
    }

    /// The near plane and what fills the deep sand of a tall window.
    static func islandNear(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        let hv: CGFloat = st.hv
        let top: CGFloat = Hv + 104 * st.grow
        let room: CGFloat = hv - top
        if room > 24 {
            let field = CGRect(x: 380, y: top, width: 500, height: room - 8)
            Kit.pebbles(&context, in: field, count: 6 + Int(room / 16), seed: 12, color: 0xD9C7A8)
        }
        if st.tall > 0.25 {
            // Deep sand: driftwood, a second melon vine, tufts of beach grass, shells.
            plank(&context, x: 470, y: top + room * 0.42, length: 96, tilt: 0.2)
            melon(&context, x: 640, baseY: top + room * 0.36, width: 60)
            Kit.grassTuft(&context, x: 560, baseY: top + room * 0.7, height: 54, color: 0x6FA85A, seed: 3)
            Kit.grassTuft(&context, x: 760, baseY: top + room * 0.56, height: 46, color: 0x6FA85A, seed: 7)
            Kit.grassTuft(&context, x: 330, baseY: top + room * 0.86, height: 50, color: 0x6FA85A, seed: 9)
            let shells = CGRect(x: 300, y: top + room * 0.3, width: 540, height: room * 0.6)
            Kit.pebbles(&context, in: shells, count: 9, seed: 31, color: 0xF2C6B8)
        }
        let frame = CGSize(width: 892, height: hv)
        Kit.cornerLeaves(&context, size: frame, corner: 3, color: Art.color(0x14503C), scale: 1.15 * st.grow, seed: 4)
    }
}

// MARK: - scene-serpent (unfolded)

extension SailorArt {
    /// The clearing: far palms under a pale sky, fig trees on the trailing edge, and low
    /// across both panes the golden Serpent — his body along the ground, his coils on the
    /// trailing side, his head bent down to the level of the small Sailor, who greets him.
    static func serpentScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 150)
        let light = day()
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.sun(&context, 112, st.H - 56 * st.far, 26 * st.far, light: light)
        Kit.cloud(&context, 300, st.H * 0.42, scale: 0.75 * st.far, color: Color.white.opacity(0.7))
        // Far: a strip of sea at the horizon, the island's soft green hills, small palms.
        Kit.ranges(&context, width: st.w, horizon: st.H, scale: st.far * 0.8, light: light, seed: 6)
        Kit.farTrees(&context, x0: 150, x1: 440, baseY: st.H + 2, height: 34 * st.far, count: 6, color: Art.color(0x7FC4A6), seed: 3)
        datePalm(&context, x: 64, baseY: st.H + 6, height: 62 * st.far, lean: 8 * st.far, seed: 5)
        datePalm(&context, x: 108, baseY: st.H + 8, height: 50 * st.far, lean: -6 * st.far, seed: 8)
        ArtStyle.atmosphere(&context, width: 440, top: st.H - 80 * st.far, bottom: st.H + 8, color: light.haze, alpha: 0.3)
        Kit.ground(&context, width: st.w, top: st.H, bottom: st.h, stops: meadowStops())
        Kit.grass(&context, in: CGRect(x: 0, y: st.H + 6, width: st.w, height: st.depth * 0.5), count: 60, seed: 4, color: Art.color(0x3C9A5A, 0.7), height: 7)

        Kit.designSpace(&context, st) { v in
            clearingFloor(&v, st)
            // The palm keeps its place on a tall window (its fronds stay off the leading pane).
            datePalm(&v, x: 585, baseY: st.Hv + 14, height: 226, lean: -15, seed: 2)
            Kit.nearSpace(&v, st) { n in
                Art.group(&n, y: st.Hv) { g in
                    clearingGrove(&g)
                }
            }
            // The pair grow about the Sailor's side, so he stays on the trailing pane.
            Kit.nearSpace(&v, st, anchorX: 560) { n in
                Art.group(&n, y: st.Hv) { g in
                    clearingHero(&g)
                }
            }
            clearingNear(&v, st)
        }
        ArtStyle.finish(&context, size)
    }

    /// The pale sand of the clearing and, on a tall window, a sandy path toward the viewer.
    static func clearingFloor(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        let hv: CGFloat = st.hv
        let g: CGFloat = st.grow
        let patch: Path = Art.ellipse(892 - 400 * g, Hv + 96 * g, 420 * g, 44 * g)
        let tone: Kit.Stops = [(Art.color(0xFBEFC4, 0.95), 0), (Art.color(0xF4E3B0, 0.6), 0.7), (Art.color(0xF4E3B0, 0), 1)]
        Art.fillRadial(&context, patch, tone, center: CGPoint(x: 892 - 400 * g, y: Hv + 96 * g), radius: 420 * g)
        if st.extra > 60 {
            Kit.ribbon(&context, nearX: 330, nearY: hv + 6, nearWidth: 260, farX: 892 - 400 * g, farY: Hv + 120 * g, farWidth: 90, stops: sandStops())
        }
    }

    /// Behind the Serpent, in units measured from the horizon: a palm, bushes and a fig tree
    /// on the trailing edge.
    static func clearingGrove(_ context: inout GraphicsContext) {
        let greens: Kit.Greens = figGreens()
        Kit.bush(&context, x: 640, baseY: 20, width: 130, palette: greens, seed: 2)
        figTree(&context, x: 852, baseY: 30, height: 336, spread: 300, seed: 5)
        Kit.bush(&context, x: 742, baseY: 24, width: 100, palette: greens, seed: 7)
    }

    /// The Serpent and the Sailor, in units measured from the horizon (y 0; the ground they
    /// stand on is about y 110).
    static func clearingHero(_ context: inout GraphicsContext) {
        // The long body along the ground, tail on the leading side.
        ArtStyle.contactShadow(&context, 400, 108, 300, 9, alpha: 0.22)
        serpentTail(&context, from: CGPoint(x: 156, y: 84), tip: CGPoint(x: 46, y: 102), width: 44, lift: -8)
        let spine: Path = Art.svg("M150,84 C230,60 300,108 400,84 C500,62 590,104 668,88")
        serpentBody(&context, spine, width: 44)
        // The coils, on the trailing side.
        serpentCoils(&context, cx: 748, baseY: 114, width: 250, thick: 58, turns: 3)
        // The neck arches up from the coils and bends the head down to the Sailor's level.
        let headAt = CGPoint(x: 630, y: -22)
        let neck: Path = serpentNeck(from: CGPoint(x: 764, y: -4), to: headAt, rise: 150)
        serpentBody(&context, neck, width: 50)
        Art.group(&context, x: headAt.x, y: headAt.y, scale: 1.2) { h in
            serpentHead(&h, look: CGPoint(x: -0.75, y: 0.2))
        }
        // The Sailor, small, in front of the golden body, waving up at his friend.
        Kit.shadow(&context, 502, 124, width: 64)
        Art.group(&context, x: 500, y: 122, scale: 0.85, scaleX: -1) { s in
            sailor(&s, pose: .wave, look: CGPoint(x: -0.7, y: -0.15), mouth: .grin, mirrored: true)
        }
        // A little heap of figs he has gathered.
        Kit.heap(&context, cx: 566, baseY: 128, width: 34, count: 6, color: figPurple, leaf: nil, seed: 4)
    }

    /// Flowers and tufts in the grass; the deeper ground of a tall window; corner leaves.
    static func clearingNear(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        let hv: CGFloat = st.hv
        let top: CGFloat = Hv + 132 * st.grow
        let room: CGFloat = max(0, hv - top)
        Kit.flowers(&context, in: CGRect(x: 20, y: Hv + 30, width: 400, height: 60), count: 9, seed: 5, petal: 0xFFFFFF)
        if room > 30 {
            let field = CGRect(x: 0, y: top, width: 892, height: room)
            Kit.grass(&context, in: field, count: 30 + Int(room / 4), seed: 21, color: Art.color(0x2E8A50, 0.8), height: 10)
            Kit.grass(&context, in: field, count: 20 + Int(room / 6), seed: 23, color: Art.color(0xA5DE7A, 0.7), height: 8)
            Kit.flowers(&context, in: field, count: 6 + Int(room / 14), seed: 9, petal: 0xFFF3C4)
        }
        if st.tall > 0.25 {
            Kit.grassTuft(&context, x: 120, baseY: top + room * 0.6, height: 60, color: 0x2E8A50, seed: 2)
            Kit.grassTuft(&context, x: 640, baseY: top + room * 0.5, height: 52, color: 0x2E8A50, seed: 6)
            Kit.bush(&context, x: 800, baseY: top + room * 0.78, width: 150, palette: figGreens(), seed: 12)
            melon(&context, x: 520, baseY: top + room * 0.72, width: 56)
        }
        let frame = CGSize(width: 892, height: hv)
        let dark: Color = Art.color(0x14503C)
        Kit.cornerLeaves(&context, size: frame, corner: 3, color: dark, scale: 1.1 * st.grow, seed: 6)
        Kit.cornerLeaves(&context, size: frame, corner: 2, color: dark, scale: 0.9 * st.grow, seed: 9)
    }
}

// MARK: - scene-home (unfolded)

extension SailorArt {
    /// Home: pale desert hills and a morning sky, the wide Nile, the mud-brick quay with
    /// flat-roofed houses, date palms and papyrus on the trailing pane, the children running
    /// along the bank — and the ship gliding in low on the leading side, sail furled, the
    /// Sailor at the bow with his arm raised.
    static func homeScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 170)
        let light = homeMorning()
        let f: CGFloat = st.far
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.sun(&context, 130, st.H - 52 * f, 26 * f, light: light)
        Kit.cloud(&context, 330, st.H * 0.4, scale: 0.7 * f, color: Color.white.opacity(0.65))
        Kit.ranges(&context, width: st.w, horizon: st.H, scale: f * 0.9, light: light, seed: 9)
        // The far bank: a thin green strip of fields, small palms and two far houses.
        Art.fill(&context, Art.rect(0, st.H - 5 * f, st.w, 6 * f + 2), Art.color(0x9CC48A))
        Kit.farTrees(&context, x0: 16, x1: 450, baseY: st.H - 3 * f, height: 26 * f, count: 7, color: Art.color(0x86B88A), seed: 5)
        let farWall: Color = Art.color(0xEFDDBC)
        let farRoof: Color = Art.color(0xC9AE86)
        Kit.farHouse(&context, cx: 214, baseY: st.H - 3 * f, width: 44 * f, height: 20 * f, wall: farWall, roof: farRoof, flat: true)
        Kit.farHouse(&context, cx: 352, baseY: st.H - 3 * f, width: 34 * f, height: 16 * f, wall: farWall, roof: farRoof, flat: true)
        ArtStyle.atmosphere(&context, width: st.w, top: st.H - 60 * f, bottom: st.H + 2, color: light.haze, alpha: 0.22)
        Kit.water(&context, width: st.w, top: st.H, bottom: st.h, stops: nileStops(), light: light, ripples: 64)
        Kit.glints(&context, x: 130, top: st.H, depth: st.depth, color: Art.color(0xFFF3C8), count: 30)

        Kit.designSpace(&context, st) { v in
            // The palms keep their place on a tall window (fronds stay off the leading pane).
            datePalm(&v, x: 612, baseY: st.Hv + 14, height: 214, lean: -16, seed: 3)
            datePalm(&v, x: 742, baseY: st.Hv + 12, height: 252, lean: 14, seed: 6)
            datePalm(&v, x: 878, baseY: st.Hv + 12, height: 204, lean: -10, seed: 9)
            Kit.nearSpace(&v, st) { n in
                Art.group(&n, y: st.Hv) { g in
                    homeTown(&g)
                    homeFolk(&g)
                }
            }
            // The ship sails to the right: the kit's ship, mirrored.
            Kit.nearSpace(&v, st, anchorX: 215) { n in
                Art.group(&n, x: 215, y: 0, scaleX: -1) { s in
                    ship(&s, cx: 0, waterY: st.Hv + 114, length: 250, sailUp: false, bow: 2, crewSize: 0.34, heads: true, mirrored: true)
                }
            }
            homeNear(&v, st)
        }
        ArtStyle.finish(&context, size)
    }

    /// The bank, the quay and the houses, in units measured from the horizon (y 0).
    static func homeTown(_ context: inout GraphicsContext) {
        // Green fields behind the town.
        let fields: Path = Art.svg("M540,14 C640,2 780,0 900,2 L900,22 L540,22Z")
        Kit.solid(&context, fields, Art.color(0x7FB86A), light: 0.2, shade: 0.14)
        // The top of the bank: trodden earth.
        let bank: Path = Art.svg("M900,10 L610,14 C546,16 502,32 490,58 L490,68 L900,68Z")
        let earth: Kit.Stops = [(Art.color(0xEAD3A4), 0), (Art.color(0xD9BC8A), 1)]
        Kit.solid(&context, bank, stops: earth, light: 0.2, shade: 0.14)
        // The quay's face of mud brick and stone, standing in the water.
        let face: Path = Art.svg("M490,64 L900,64 L900,98 L500,98 C494,88 490,76 490,64Z")
        Kit.solid(&context, face, Art.color(0xB88C5E), light: 0.2, shade: 0.24)
        let courses: Path = Kit.builtCourses(CGRect(x: 494, y: 68, width: 400, height: 28), seed: 14)
        Art.clipped(&context, to: face) { g in
            Art.stroke(&g, courses, Art.color(0x7A5636, 0.55), width: 1.2)
        }
        Art.stroke(&context, Art.line(492, 64, 900, 64), Art.color(0xF0DDB6), width: 3.4)
        Art.fill(&context, Art.rect(500, 98, 400, 12), ArtStyle.coolShade.opacity(0.14))

        Kit.house(&context, cx: 812, baseY: 34, width: 124, wallHeight: 96, roofHeight: 14, wall: mudBrick, roof: 0x9A7A56, style: .flat, door: 0x6A4630, windows: 1)
        // A small upper room on the roof, as on a Nile town house.
        Kit.wall(&context, rect: CGRect(x: 824, y: -106, width: 48, height: 30), color: mudBrick)
        Art.stroke(&context, Art.line(822, -106, 874, -106), Art.color(0x9A7A56), width: 3)
        Kit.house(&context, cx: 676, baseY: 30, width: 96, wallHeight: 72, roofHeight: 12, wall: whitewash, roof: 0xB89A72, style: .flat, door: 0x6A4630, windows: 2)
        // Water jars by the door, a mooring post on the quay.
        Kit.pot(&context, cx: 742, baseY: 40, width: 18, height: 24, color: 0xB5683A)
        Kit.pot(&context, cx: 760, baseY: 42, width: 14, height: 18, color: 0xC27A48)
        Kit.propShaft(&context, 522, 64, 522, 40, wood: 0x6A4630, width: 5)
        // Papyrus at the water's edge, and a small reed boat tied up.
        Kit.reeds(&context, x: 482, baseY: 96, count: 7, height: 96, seed: 4, color: 0x4F9A5A, papyrus: true)
        Kit.boat(&context, cx: 600, waterY: 112, length: 76, hull: 0xC9A860, style: .canoe)
        Kit.reeds(&context, x: 548, baseY: 106, count: 5, height: 64, seed: 11, color: 0x3F8A5A, papyrus: true)
    }

    /// The Sailor's children running along the bank to meet the ship, and their mother.
    static func homeFolk(_ context: inout GraphicsContext) {
        Kit.shadow(&context, 742, 58, width: 44)
        Art.group(&context, x: 740, y: 57, scale: 0.56) { m in
            Kit.person(&m, motherLook(), pose: .wave, look: CGPoint(x: -0.6, y: 0), mouth: .grin)
        }
        Kit.shadow(&context, 612, 60, width: 36)
        Art.group(&context, x: 610, y: 59, scale: 0.62) { c in
            Kit.person(&c, childLook(1), pose: .wave, look: CGPoint(x: -0.6, y: 0), mouth: .grin)
        }
        Kit.shadow(&context, 562, 56, width: 36)
        Art.group(&context, x: 560, y: 55, scale: 0.62) { c in
            Kit.person(&c, childLook(0), pose: .walk, look: CGPoint(x: -0.6, y: 0), mouth: .open)
        }
    }

    /// Papyrus cropped by the trailing corner; lily pads and a duck on the deep water of a
    /// tall window.
    static func homeNear(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        let hv: CGFloat = st.hv
        let top: CGFloat = Hv + 150 * st.grow
        let room: CGFloat = max(0, hv - top)
        if st.tall > 0.25 {
            Kit.lilyPad(&context, cx: 520, cy: top + room * 0.3, r: 26, flower: true)
            Kit.lilyPad(&context, cx: 584, cy: top + room * 0.44, r: 20)
            Kit.lilyPad(&context, cx: 300, cy: top + room * 0.7, r: 24)
            Kit.lilyPad(&context, cx: 690, cy: top + room * 0.72, r: 30, flower: true)
            let duck = Kit.Bird(kind: .duck, body: 0x8A6A4A, belly: 0xD9C7A0, wing: 0x4F7A8A, beak: 0xE8A21C)
            let dy: CGFloat = top + room * 0.2
            // A duck standing on a lily pad.
            Kit.lilyPad(&context, cx: 402, cy: dy + 2, r: 38)
            Art.group(&context, x: 400, y: dy, scale: 0.9) { b in
                Kit.bird(&b, duck, pose: .perch)
            }
        }
        let reedHeight: CGFloat = 150 * st.grow
        Kit.reeds(&context, x: 846, baseY: hv + 12, count: 8, height: reedHeight, seed: 21, color: 0x2E6A48, papyrus: true)
        Kit.reeds(&context, x: 40, baseY: hv + 14, count: 5, height: reedHeight * 0.6, seed: 23, color: 0x2E6A48, papyrus: true)
    }
}
