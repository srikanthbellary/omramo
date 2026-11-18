import SwiftUI
import OmramoCore

/// Concept art for "The North Wind and the Sun", drawn in code (round 5; composed from the shared kit).
///
/// The cast (the Sun, the North Wind, the traveller and his cloak) is in `WindSunArt+Cast.swift`,
/// the folded-phone compositions in `WindSunArt+Folded.swift`, the tap-to-see pictures, the
/// portraits, the face chips and the cover in `WindSunArt+Pictures.swift`. This file holds the
/// entry point and the four unfolded scenes.
enum WindSunArt {
    /// Draws the picture called `name`. Returns false for a name this story does not have.
    static func paint(_ name: String, role: ArtRole, in context: inout GraphicsContext, size: CGSize) -> Bool {
        guard size.width > 0, size.height > 0 else { return false }
        switch (name, role) {
        case ("scene-sky", .sceneUnfolded): skyScene(&context, size)
        case ("scene-sky", .sceneFolded): skyFolded(&context, size)
        case ("scene-wind", .sceneUnfolded): windScene(&context, size)
        case ("scene-wind", .sceneFolded): windFolded(&context, size)
        case ("scene-sun", .sceneUnfolded): sunScene(&context, size)
        case ("scene-sun", .sceneFolded): sunFolded(&context, size)
        case ("scene-rest", .sceneUnfolded): restScene(&context, size)
        case ("scene-rest", .sceneFolded): restFolded(&context, size)
        case ("see-fable", .picture): fablePicture(&context, size)
        case ("see-aegean-sea", .picture): aegeanPicture(&context, size)
        case ("see-cloak", .picture): cloakPicture(&context, size)
        case ("char-north-wind", .portrait): windPortrait(&context, size)
        case ("char-sun", .portrait): sunPortrait(&context, size)
        case ("face-north-wind", .face): windFace(&context, size)
        case ("face-sun", .face): sunFace(&context, size)
        case ("face-traveller", .face): travellerFace(&context, size)
        case ("cover", .cover): cover(&context, size)
        default:
            return false
        }
        return true
    }
}

// MARK: - Shared by the unfolded scenes

extension WindSunArt {
    /// The bottom edge of the picture in the units of `Kit.nearSpace` (anchored on the horizon).
    static func nearFloor(_ st: Kit.Stage) -> CGFloat {
        let below: CGFloat = (st.hv - st.Hv) / st.grow
        return st.Hv + below + 6
    }

    /// How big the two sky heroes are drawn: smaller when the sky is low (a phone held sideways).
    static func skyScale(_ st: Kit.Stage) -> CGFloat {
        Kit.clamp((st.Hv - 60) / 490, 0.75, 1)
    }

    /// Short white crests scattered over a stretch of sea, larger toward the viewer.
    static func whitecaps(_ context: inout GraphicsContext, x0: CGFloat, x1: CGFloat, top: CGFloat, bottom: CGFloat, count: Int, seed: UInt32) {
        guard x1 > x0, bottom > top else { return }
        var random = ArtRandom(seed)
        var caps = Path()
        for _ in 0..<max(0, count) {
            let t: CGFloat = Kit.rnd(&random)
            let y: CGFloat = top + (bottom - top) * t * t
            let x: CGFloat = x0 + (x1 - x0) * Kit.rnd(&random)
            let w: CGFloat = 8 + 22 * t
            let lift: CGFloat = 2 + 5 * t
            caps.move(to: CGPoint(x: x, y: y))
            caps.addQuadCurve(to: CGPoint(x: x + w, y: y), control: CGPoint(x: x + w * 0.35, y: y - lift * 2))
            caps.addQuadCurve(to: CGPoint(x: x, y: y), control: CGPoint(x: x + w * 0.5, y: y - lift * 0.4))
            caps.closeSubpath()
        }
        Art.fill(&context, caps, Color.white.opacity(0.85))
    }
}

// MARK: - scene-sky: high above the Aegean

extension WindSunArt {
    /// A high view: mostly sky, the sea and its islands low, the coast road in the trailing
    /// corner, and the two friends in the sky on the trailing pane — the Sun smiling, the
    /// North Wind mid-boast beside it.
    static func skyScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st: Kit.Stage = Kit.stage(size, ground: 170)
        let light: Kit.Light = day()
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.cloud(&context, 150, st.H - 92 * st.far, scale: 0.7 * st.far, color: Art.color(0xFFFFFF, 0.6))
        Kit.cloud(&context, 330, st.H - 44 * st.far, scale: 0.45 * st.far, color: Art.color(0xFFFFFF, 0.5))
        Kit.birds(&context, 250, st.H - 58 * st.far, scale: st.far, color: Art.color(0x6E8FAE, 0.7))
        islandRow(&context, width: 892, horizon: st.H, scale: st.far, light: light)
        Kit.water(&context, width: 892, top: st.H, bottom: size.height, stops: calmSea(), light: light, ripples: 80)
        skySea(&context, st, light: light)
        Kit.designSpace(&context, st) { v in
            skyCoast(&v, st)
            skyHeroes(&v, st)
        }
        Kit.cornerLeaves(&context, size: size, corner: 2, color: Art.color(0x3C5247), scale: 0.8 * st.grow, seed: 5)
        ArtStyle.finish(&context, size)
    }

    /// The islands scattered over the sea as seen from high up, and one small square-sailed boat.
    static func skySea(_ context: inout GraphicsContext, _ st: Kit.Stage, light: Kit.Light) {
        // x, how far down the sea (0…1), width.
        let places: [(CGFloat, CGFloat, CGFloat)] = [
            (560, 0.13, 86), (130, 0.2, 120), (410, 0.3, 70), (285, 0.5, 150), (70, 0.74, 96),
        ]
        for place in places {
            let y: CGFloat = st.H + st.depth * place.1
            let w: CGFloat = place.2 * st.far
            let near: Bool = place.1 > 0.4
            let color: Color = near ? Art.color(0xA9BC8C) : light.mid
            Art.fill(&context, Art.ellipse(place.0 + w * 0.03, y + w * 0.035, w * 0.56, w * 0.05), Art.color(0x0B4F7A, 0.22))
            island(&context, x: place.0, y: y, width: w, height: w * 0.26, color: color)
            if near {
                Kit.farTree(&context, x: place.0 - w * 0.1, baseY: y - w * 0.2, height: w * 0.1, color: Art.color(0x6E8A6C))
                Kit.farTree(&context, x: place.0 + w * 0.08, baseY: y - w * 0.14, height: w * 0.08, color: Art.color(0x6E8A6C))
            }
            Kit.ripples(&context, place.0, y + w * 0.05, w * 0.9, count: 2, color: Color.white, opacity: 0.4)
        }
        let boatY: CGFloat = st.H + st.depth * 0.36
        Kit.boat(&context, cx: 190, waterY: boatY, length: 36 * st.far, hull: 0x8A5A3A, sail: 0xF4EAD0, style: .nile)
    }

    /// The coast in the trailing corner, seen from above: a dry headland, the pale road
    /// winding along it, small olives and terrace walls, and one tiny cloaked figure.
    static func skyCoast(_ v: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        let floorN: CGFloat = nearFloor(st)
        Kit.nearSpace(&v, st) { n in
            var land = Path()
            land.move(to: CGPoint(x: 470, y: floorN))
            land.addQuadCurve(to: CGPoint(x: 690, y: Hv + 50), control: CGPoint(x: 540, y: Hv + 66))
            land.addQuadCurve(to: CGPoint(x: 900, y: Hv + 12), control: CGPoint(x: 800, y: Hv + 16))
            land.addLine(to: CGPoint(x: 900, y: floorN))
            land.closeSubpath()
            let shape: Path = land
            var surf = Path()
            surf.move(to: CGPoint(x: 462, y: floorN))
            surf.addQuadCurve(to: CGPoint(x: 690, y: Hv + 46), control: CGPoint(x: 534, y: Hv + 60))
            Art.stroke(&n, surf, Color.white.opacity(0.6), width: 3)
            Art.fillLinear(&n, shape, hillStops(), from: CGPoint(x: 0, y: Hv + 12), to: CGPoint(x: 0, y: floorN))
            Kit.model(&n, shape, light: 0.2, shade: 0.16, rim: 2.4)
            Kit.ribbon(&n, nearX: 600, nearY: floorN, nearWidth: 46, farX: 884, farY: Hv + 26, farWidth: 8, stops: roadStops())
            // Terrace walls: pale lines across the slope.
            let walls: Path = Art.svg("M0,0 C40,-10 90,-14 150,-12 M30,34 C70,22 120,18 170,22")
            let wallShift = CGAffineTransform(translationX: 700, y: Hv + 62)
            Art.stroke(&n, walls.applying(wallShift), Art.color(stoneHex, 0.8), width: 2.2)
            let olive: Color = Art.color(0x7C947A)
            let dark: Color = Art.color(0x4E6E58)
            let trees: [(CGFloat, CGFloat, CGFloat)] = [
                (716, 52, 15), (752, 46, 17), (836, 40, 16), (868, 74, 19), (700, 96, 18), (848, 112, 21), (560, 120, 15),
            ]
            for tree in trees {
                Kit.farTree(&n, x: tree.0, baseY: Hv + tree.1 + 14, height: tree.2, color: olive)
            }
            Kit.farTree(&n, x: 806, baseY: Hv + 48, height: 26, color: dark, conifer: true)
            Kit.farTree(&n, x: 888, baseY: Hv + 44, height: 30, color: dark, conifer: true)
            Kit.pebbles(&n, in: CGRect(x: 500, y: Hv + 110, width: 380, height: max(10, floorN - Hv - 120)), count: 14, seed: 9, color: 0xE4DCC4)
            // The traveller, very small, on the road.
            Kit.shadow(&n, 785, Hv + 82, width: 16, alpha: 0.3)
            Art.group(&n, x: 785, y: Hv + 82, scale: 0.24) { g in
                traveller(&g, state: .wrapped)
            }
        }
    }

    /// The Sun and the North Wind in the sky of the trailing pane.
    static func skyHeroes(_ v: inout GraphicsContext, _ st: Kit.Stage) {
        let k: CGFloat = skyScale(st)
        let sunY: CGFloat = st.Hv - 300 * k
        Kit.nearSpace(&v, st, anchorX: 600) { n in
            Art.group(&n, x: 560, y: sunY, scale: 1.1 * k) { g in
                sunHero(&g, mood: .smiling)
            }
            // The small cloud the Sun will slip behind.
            Kit.cloud(&n, 520, sunY + 100 * k, scale: 0.6 * k, color: Art.color(0xFFFFFF, 0.92))
            Art.group(&n, x: 742, y: sunY + 92 * k, scale: 0.85 * k) { g in
                windHero(&g, mood: .boasting)
            }
        }
    }
}

// MARK: - The hill road (scene-wind and scene-sun: the same place, the same viewpoint)

extension WindSunArt {
    /// The dry headland on the trailing side with the pale earth road climbing it, the
    /// dry-stone wall along its crest, stones and — on a tall window — the deeper foot of the
    /// slope. Drawn in near-space units; the traveller stands at (650, Hv + 86).
    static func roadLand(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        let floorN: CGFloat = nearFloor(st)
        var hill = Path()
        hill.move(to: CGPoint(x: 290, y: floorN))
        hill.addQuadCurve(to: CGPoint(x: 470, y: Hv + 58), control: CGPoint(x: 350, y: Hv + 70))
        hill.addQuadCurve(to: CGPoint(x: 700, y: Hv + 10), control: CGPoint(x: 590, y: Hv + 52))
        hill.addQuadCurve(to: CGPoint(x: 900, y: Hv - 78), control: CGPoint(x: 820, y: Hv - 30))
        hill.addLine(to: CGPoint(x: 900, y: floorN))
        hill.closeSubpath()
        let shape: Path = hill
        Art.fillLinear(&n, shape, hillStops(), from: CGPoint(x: 0, y: Hv - 78), to: CGPoint(x: 0, y: floorN))
        Kit.model(&n, shape, light: 0.2, shade: 0.16, rim: 2.4)
        // Pale limestone showing where the headland falls to the sea.
        let rockFace: Path = Art.svg("M0,0 C10,-34 30,-62 62,-80 M22,4 C30,-22 46,-44 72,-58 M-14,30 C-8,10 0,-6 10,-18")
        let faceShift = CGAffineTransform(translationX: 330, y: Hv + 150)
        Art.stroke(&n, rockFace.applying(faceShift), Art.color(0xF2ECD8, 0.7), width: 3)
        // The road: up from the viewer to the traveller, then on along the slope.
        Kit.ribbon(&n, nearX: 560, nearY: floorN, nearWidth: 170, farX: 650, farY: Hv + 92, farWidth: 96, stops: roadStops())
        Kit.ribbon(&n, nearX: 650, nearY: Hv + 92, nearWidth: 96, farX: 900, farY: Hv - 10, farWidth: 30, stops: roadStops())
        Kit.pebbles(&n, in: CGRect(x: 560, y: Hv + 70, width: 150, height: 44), count: 9, seed: 14, color: 0xCFC6A8)
        // The dry-stone wall along the crest.
        Art.group(&n, x: 700, y: Hv + 16, rotate: -Kit.deg(23)) { w in
            Kit.fence(&w, x0: 0, x1: 216, baseY: 0, height: 20, color: stoneHex, stone: true)
        }
        let dry: Color = Art.color(0x9A9A58)
        Kit.grass(&n, in: CGRect(x: 380, y: Hv + 84, width: 180, height: 60), count: 16, seed: 21, color: dry, height: 9)
        Kit.grass(&n, in: CGRect(x: 720, y: Hv + 6, width: 150, height: 24), count: 10, seed: 22, color: dry, height: 8)
        let extra: CGFloat = floorN - (Hv + 156)
        if extra > 30 {
            // A tall window: the foot of the slope comes toward the viewer.
            Kit.rock(&n, cx: 440, baseY: Hv + 190, width: 70, height: 34, color: 0xC9C2AC, seed: 3)
            thyme(&n, x: 700, baseY: Hv + 176, width: 60, seed: 31)
            thyme(&n, x: 410, baseY: floorN - 40, width: 74, seed: 32)
            Kit.rock(&n, cx: 760, baseY: floorN - 30, width: 96, height: 44, color: 0xBDB6A0, seed: 5)
            Kit.grass(&n, in: CGRect(x: 320, y: Hv + 170, width: 220, height: extra), count: 26, seed: 23, color: dry, height: 11)
            Kit.pebbles(&n, in: CGRect(x: 470, y: Hv + 170, width: 200, height: extra), count: 16, seed: 15, color: 0xCFC6A8)
            Kit.flowers(&n, in: CGRect(x: 690, y: Hv + 190, width: 170, height: max(10, extra - 60)), count: 9, seed: 24, petal: 0xF4D35E)
        }
    }

    /// The dark near framing of the road scenes: a boulder and dry grasses in the trailing
    /// bottom corner (near-space units).
    static func roadNear(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let floorN: CGFloat = nearFloor(st)
        Kit.rock(&n, cx: 860, baseY: floorN + 4, width: 130, height: 54, color: 0x7C7868, seed: 8)
        Kit.grassTuft(&n, x: 790, baseY: floorN + 2, height: 46, color: 0x6E7A46, seed: 4)
        Kit.grassTuft(&n, x: 884, baseY: floorN - 30, height: 40, color: 0x5E6E44, seed: 6)
    }
}

// MARK: - scene-wind: the gale on the hill road

extension WindSunArt {
    /// The gale: a pale silver sky, a white-capped sea, a fishing boat running for shore, the
    /// olive bent hard over, leaves and a hat in the air, and the traveller leaning into the
    /// wind with both fists in his cloak. The North Wind howls, small and low, over the sea.
    static func windScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st: Kit.Stage = Kit.stage(size, ground: 150)
        let light: Kit.Light = gale()
        Kit.sky(&context, size, horizon: st.H, light: light)
        islandRow(&context, width: 892, horizon: st.H, scale: st.far, light: light)
        // The Wind himself, low over the water on the leading side, blowing to the right.
        let ws: CGFloat = 0.36 * st.far
        Art.group(&context, x: 104, y: st.H - 42 * st.far, scale: ws, scaleX: -1) { g in
            windHero(&g, mood: .howling, streams: true, mirrored: true)
        }
        Kit.water(&context, width: 892, top: st.H, bottom: size.height, stops: galeSea(), light: light, ripples: 40)
        Kit.swells(&context, width: 892, top: st.H + 6, bottom: size.height, rows: 8, crest: Color.white, seed: 12)
        whitecaps(&context, x0: 0, x1: 892, top: st.H + 8, bottom: size.height, count: 60, seed: 41)
        let boatY: CGFloat = st.H + st.depth * 0.3
        Art.group(&context, x: 236, y: boatY, rotate: Kit.deg(7)) { g in
            Kit.boat(&g, cx: 0, waterY: 0, length: 50 * st.far, hull: 0x7A5236, sail: 0xEDE4CC, style: .nile)
        }
        whitecaps(&context, x0: 200, x1: 280, top: boatY + 2, bottom: boatY + 8, count: 4, seed: 42)
        gust(&context, x: 160, y: st.H - 26 * st.far, length: 230 * st.far, width: 5, color: Color.white)
        gust(&context, x: 30, y: st.H + st.depth * 0.5, length: 260, width: 5, color: Color.white)
        Kit.designSpace(&context, st) { v in
            Kit.nearSpace(&v, st) { n in
                roadLand(&n, st)
                windMiddle(&n, st)
                windSubject(&n, st)
                roadNear(&n, st)
            }
        }
        ArtStyle.finish(&context, size, wash: 0.06, vignette: 0.08)
    }

    /// The bent trees, the goats and the dust on the slope.
    static func windMiddle(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        // Wind from the left: everything that grows leans hard to the right.
        let lean = CGAffineTransform(a: 1, b: 0, c: -0.38, d: 1, tx: 0, ty: 0)
        let sway = CGAffineTransform(a: 1, b: 0, c: -0.16, d: 1, tx: 0, ty: 0)
        Art.group(&n, x: 874, y: Hv - 50) { t in
            t.concatenate(sway)
            Kit.cypress(&t, x: 0, baseY: 0, height: 150)
        }
        Art.group(&n, x: 786, y: Hv - 14) { t in
            t.concatenate(lean)
            Kit.olive(&t, x: 0, baseY: 0, height: 150, seed: 4)
        }
        // Leaves streaming off the crown, flashing silver.
        leafFlurry(&n, in: CGRect(x: 800, y: Hv - 190, width: 100, height: 90), count: 16, seed: 51, size: 10)
        leafFlurry(&n, in: CGRect(x: 500, y: Hv - 210, width: 380, height: 250), count: 24, seed: 52, size: 9)
        Art.group(&n, x: 528, y: Hv + 92, scale: 0.32) { g in
            goat(&g, pose: .stand)
        }
        Art.group(&n, x: 592, y: Hv + 66, scale: 0.26, scaleX: -1) { g in
            goat(&g, pose: .walk)
        }
        thyme(&n, x: 470, baseY: Hv + 124, width: 46, seed: 33)
        thyme(&n, x: 744, baseY: Hv + 104, width: 40, seed: 34)
        // Dust skipping along the road.
        Kit.flecks(&n, in: CGRect(x: 560, y: Hv + 30, width: 300, height: 70), count: 26, seed: 53, color: Art.color(0xF6EED6, 0.9), radius: 0.9...2.4)
        gust(&n, x: 690, y: Hv + 70, length: 150, width: 5, color: Art.color(0xF6EED6))
    }

    /// The traveller in the gale, his hat in the air behind him.
    static func windSubject(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        gust(&n, x: 470, y: Hv - 150, length: 250, width: 6, color: Color.white)
        gust(&n, x: 500, y: Hv - 40, length: 120, width: 5, color: Color.white)
        Kit.shadow(&n, 652, Hv + 88, width: 90)
        Art.group(&n, x: 650, y: Hv + 86, scale: 1.25) { g in
            traveller(&g, state: .gale, mouth: .flat)
        }
        gust(&n, x: 700, y: Hv - 96, length: 170, width: 5, color: Color.white)
        // "Off flew the traveller's hat."
        Art.group(&n, x: 716, y: Hv - 192, rotate: Kit.deg(-28), scale: 1.15) { g in
            strawHat(&g, cord: true)
        }
        let whoosh: Path = Art.svg("M0,0 q10,-5 20,0 M4,10 q10,-5 20,0")
        let whooshShift = CGAffineTransform(translationX: 644, y: Hv - 190)
        Art.stroke(&n, whoosh.applying(whooshShift), Color.white.opacity(0.8), width: 2)
    }
}

// MARK: - scene-sun: the same road in warm gold light

extension WindSunArt {
    /// The Sun's turn: gold light, a smooth blue sea, upright olives, bees in the thyme, a
    /// lizard on the wall, and the traveller walking easily with his hat pushed back and his
    /// cloak hanging loose. The Sun glows over the road; the Wind watches from a far hilltop.
    static func sunScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st: Kit.Stage = Kit.stage(size, ground: 150)
        let light: Kit.Light = gold()
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.cloud(&context, 300, st.H - 60 * st.far, scale: 0.5 * st.far, color: Art.color(0xFFFFFF, 0.55))
        islandRow(&context, width: 892, horizon: st.H, scale: st.far, light: light)
        // The Wind, out of breath, flopped on the far island's hilltop.
        Art.group(&context, x: 96, y: st.H - 44 * st.far, scale: 0.3 * st.far) { g in
            windHero(&g, mood: .oh)
        }
        Kit.water(&context, width: 892, top: st.H, bottom: size.height, stops: calmSea(), light: light, ripples: 60)
        Kit.glints(&context, x: 330, top: st.H, depth: st.depth, color: Art.color(0xFFF1C9), count: 30, seed: 8)
        let boatY: CGFloat = st.H + st.depth * 0.28
        Kit.boat(&context, cx: 170, waterY: boatY, length: 44 * st.far, hull: 0x8A5A3A, sail: 0xF4EAD0, style: .nile)
        Kit.designSpace(&context, st) { v in
            let k: CGFloat = skyScale(st)
            let sunY: CGFloat = st.Hv - 300 * k
            Kit.nearSpace(&v, st, anchorX: 600) { n in
                Art.group(&n, x: 552, y: sunY, scale: 0.95 * k) { g in
                    sunHero(&g, mood: .glowing)
                }
            }
            Kit.nearSpace(&v, st) { n in
                roadLand(&n, st)
                sunMiddle(&n, st)
                sunSubject(&n, st)
                roadNear(&n, st)
            }
        }
        Kit.cornerLeaves(&context, size: size, corner: 1, color: Art.color(0x3C5247), scale: 1.1 * st.far, seed: 3)
        ArtStyle.finish(&context, size, wash: 0.14, vignette: 0.08)
    }

    /// Upright trees, the lizard on the warm wall, bees in the thyme, a goat at rest.
    static func sunMiddle(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        Kit.cypress(&n, x: 874, baseY: Hv - 50, height: 150)
        Kit.olive(&n, x: 792, baseY: Hv - 14, height: 150, seed: 4)
        // Warm light lying on the top of the wall, and a lizard basking there.
        Art.group(&n, x: 700, y: Hv + 16, rotate: -Kit.deg(23)) { w in
            Art.stroke(&w, Art.line(4, -20, 120, -20), Art.color(0xFFE9A8, 0.6), width: 3)
            Art.group(&w, x: 62, y: -22, scale: 1.1) { g in
                Kit.critterLizard(&g, body: 0x7FA85A)
            }
        }
        Art.group(&n, x: 528, y: Hv + 92, scale: 0.32) { g in
            goat(&g, pose: .sit)
        }
        thyme(&n, x: 470, baseY: Hv + 124, width: 46, seed: 33)
        thyme(&n, x: 744, baseY: Hv + 104, width: 44, seed: 34)
        thyme(&n, x: 580, baseY: Hv + 132, width: 50, seed: 35)
        let bees: [(CGFloat, CGFloat, CGFloat)] = [(566, 96, 1.0), (598, 82, 0.8), (742, 68, 0.9)]
        for bee in bees {
            Art.group(&n, x: bee.0, y: Hv + bee.1, scale: bee.2) { g in
                Kit.critterBee(&g)
            }
        }
        Kit.flowers(&n, in: CGRect(x: 400, y: Hv + 96, width: 130, height: 40), count: 6, seed: 25, petal: 0xF4D35E)
    }

    /// The traveller walking in the sun.
    static func sunSubject(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        Kit.shadow(&n, 656, Hv + 88, width: 96, alpha: 0.3)
        Art.group(&n, x: 650, y: Hv + 86, scale: 1.25) { g in
            traveller(&g, state: .easy, mouth: .grin)
        }
    }
}

// MARK: - scene-rest: under the old olive tree above the harbour

extension WindSunArt {
    /// Late afternoon: the small harbour below on the leading side, the old olive low on the
    /// trailing side with the traveller resting in its shade, his cloak folded beside him.
    /// Over the islands the Sun smiles and the North Wind goes pink with pleasure.
    static func restScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st: Kit.Stage = Kit.stage(size, ground: 160)
        let light: Kit.Light = afternoon()
        Kit.sky(&context, size, horizon: st.H, light: light)
        islandRow(&context, width: 892, horizon: st.H, scale: st.far, light: light)
        Art.group(&context, x: 300, y: st.H - 50 * st.far, scale: 0.42 * st.far) { g in
            sunHero(&g, mood: .smiling)
        }
        Art.group(&context, x: 122, y: st.H - 46 * st.far, scale: 0.32 * st.far) { g in
            windHero(&g, mood: .pleased, pink: true)
        }
        Kit.water(&context, width: 892, top: st.H, bottom: size.height, stops: lateSea(), light: light, ripples: 60)
        Kit.glints(&context, x: 300, top: st.H, depth: st.depth * 0.5, color: Art.color(0xFFF1C9), count: 24, seed: 9)
        harbour(&context, x: 0, y: st.H + st.depth * 0.42, scale: st.far, bottom: size.height)
        Kit.designSpace(&context, st) { v in
            Kit.nearSpace(&v, st) { n in
                restLand(&n, st)
                restSubject(&n, st)
            }
        }
        ArtStyle.finish(&context, size)
    }

    /// The little harbour seen from the hill: a low spit of land from the left edge with a few
    /// low stone and mud-brick houses, a stone mole, and fishing boats. (x, y) is the left end
    /// of its shore line; about 330 wide at scale 1.
    static func harbour(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, scale s: CGFloat, bottom: CGFloat) {
        var land = Path()
        land.move(to: CGPoint(x: x - 4, y: y + 30 * s))
        land.addLine(to: CGPoint(x: x - 4, y: y - 14 * s))
        land.addQuadCurve(to: CGPoint(x: x + 210 * s, y: y - 6 * s), control: CGPoint(x: x + 110 * s, y: y - 26 * s))
        land.addQuadCurve(to: CGPoint(x: x + 300 * s, y: y + 12 * s), control: CGPoint(x: x + 270 * s, y: y - 2 * s))
        land.addQuadCurve(to: CGPoint(x: x - 4, y: y + 30 * s), control: CGPoint(x: x + 150 * s, y: y + 22 * s))
        land.closeSubpath()
        let shape: Path = land
        Art.fill(&context, Art.ellipse(x + 150 * s, y + 22 * s, 170 * s, 9 * s), Art.color(0x0B4F7A, 0.2))
        Kit.solid(&context, shape, stops: hillStops(), light: 0.2, shade: 0.14)
        // Low houses of stone and mud brick, flat-roofed or tiled: far off and plain.
        let stone: Color = Art.color(0xE2D6BC)
        let brick: Color = Art.color(0xD9BE96)
        let tile: Color = Art.color(0xC07A52)
        let flatRoof: Color = Art.color(0xB9A888)
        Kit.farHouse(&context, cx: x + 46 * s, baseY: y - 12 * s, width: 34 * s, height: 20 * s, wall: stone, roof: tile)
        Kit.farHouse(&context, cx: x + 88 * s, baseY: y - 15 * s, width: 30 * s, height: 22 * s, wall: brick, roof: flatRoof, flat: true)
        Kit.farHouse(&context, cx: x + 128 * s, baseY: y - 11 * s, width: 36 * s, height: 19 * s, wall: stone, roof: tile)
        Kit.farHouse(&context, cx: x + 170 * s, baseY: y - 7 * s, width: 26 * s, height: 17 * s, wall: brick, roof: flatRoof, flat: true)
        Kit.farTree(&context, x: x + 16 * s, baseY: y - 12 * s, height: 20 * s, color: Art.color(0x7C947A))
        Kit.farTree(&context, x: x + 150 * s, baseY: y - 12 * s, height: 16 * s, color: Art.color(0x7C947A))
        Kit.farTree(&context, x: x + 108 * s, baseY: y - 16 * s, height: 26 * s, color: Art.color(0x4E6E58), conifer: true)
        // The mole: a low arm of piled stone sheltering the boats.
        Kit.fence(&context, x0: x + 230 * s, x1: x + 372 * s, baseY: y + 16 * s, height: 8 * s, color: stoneHex, stone: true)
        Kit.boat(&context, cx: x + 250 * s, waterY: y + 36 * s, length: 44 * s, hull: 0x8A5A3A, style: .rowing)
        Kit.boat(&context, cx: x + 330 * s, waterY: y + 46 * s, length: 52 * s, hull: 0x7A5236, sail: nil, style: .nile)
        if bottom - y > 110 * s {
            Kit.boat(&context, cx: x + 150 * s, waterY: y + 78 * s, length: 60 * s, hull: 0x9A6A44, style: .rowing)
        }
    }

    /// The terrace above the harbour and the old olive tree (near-space units).
    static func restLand(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        let floorN: CGFloat = nearFloor(st)
        var hill = Path()
        hill.move(to: CGPoint(x: 330, y: floorN))
        hill.addQuadCurve(to: CGPoint(x: 520, y: Hv + 56), control: CGPoint(x: 400, y: Hv + 66))
        hill.addQuadCurve(to: CGPoint(x: 900, y: Hv + 18), control: CGPoint(x: 700, y: Hv + 48))
        hill.addLine(to: CGPoint(x: 900, y: floorN))
        hill.closeSubpath()
        let shape: Path = hill
        Art.fillLinear(&n, shape, hillStops(), from: CGPoint(x: 0, y: Hv + 18), to: CGPoint(x: 0, y: floorN))
        Kit.model(&n, shape, light: 0.2, shade: 0.16, rim: 2.4)
        Kit.ribbon(&n, nearX: 560, nearY: floorN, nearWidth: 130, farX: 640, farY: Hv + 104, farWidth: 50, stops: roadStops())
        Kit.fence(&n, x0: 470, x1: 600, baseY: Hv + 76, height: 16, color: stoneHex, stone: true)
        Kit.cypress(&n, x: 506, baseY: Hv + 62, height: 96)
        // The shade of the old tree, then the tree: low, wide, to the right.
        ArtStyle.contactShadow(&n, 760, Hv + 96, 190, 24, alpha: 0.24)
        Kit.olive(&n, x: 806, baseY: Hv + 72, height: 300, seed: 7)
        let crown: [Kit.Blob] = [
            (736, Hv - 152, 58), (806, Hv - 184, 64), (872, Hv - 150, 60), (776, Hv - 116, 46), (846, Hv - 108, 50),
        ]
        Kit.canopy(&n, crown, seed: 71, palette: Kit.oliveGreens(), density: 2)
        let dry: Color = Art.color(0x9A9A58)
        Kit.grass(&n, in: CGRect(x: 400, y: Hv + 84, width: 150, height: 50), count: 14, seed: 26, color: dry, height: 9)
        thyme(&n, x: 456, baseY: Hv + 128, width: 46, seed: 36)
        let extra: CGFloat = floorN - (Hv + 166)
        if extra > 30 {
            Kit.rock(&n, cx: 450, baseY: Hv + 200, width: 76, height: 36, color: 0xC9C2AC, seed: 3)
            thyme(&n, x: 720, baseY: Hv + 196, width: 64, seed: 37)
            thyme(&n, x: 420, baseY: floorN - 36, width: 76, seed: 38)
            Kit.grass(&n, in: CGRect(x: 340, y: Hv + 180, width: 220, height: extra), count: 26, seed: 27, color: dry, height: 11)
            Kit.flowers(&n, in: CGRect(x: 680, y: Hv + 200, width: 190, height: max(10, extra - 50)), count: 10, seed: 28, petal: 0xF4D35E)
            Kit.rock(&n, cx: 800, baseY: floorN - 20, width: 110, height: 48, color: 0x8A8474, seed: 6)
        }
    }

    /// The traveller sitting against the trunk on a stone, the folded cloak beside him, his
    /// stick against the tree; a small cool breeze lifts his hair.
    static func restSubject(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        let floorN: CGFloat = nearFloor(st)
        Art.stroke(&n, Art.line(776, Hv + 80, 796, Hv - 60), Art.color(0x8A6642), width: 5)
        Kit.rock(&n, cx: 730, baseY: Hv + 88, width: 84, height: 46, color: 0xB8B09C, seed: 2)
        Kit.shadow(&n, 700, Hv + 90, width: 80)
        Art.group(&n, x: 718, y: Hv + 86, scale: 1.25) { g in
            traveller(&g, state: .resting, mouth: .smile)
        }
        Art.group(&n, x: 628, y: Hv + 96, scale: 1.25) { g in
            foldedCloak(&g)
        }
        // The small breeze from the sea: one soft curl, nothing more.
        gust(&n, x: 520, y: Hv - 80, length: 130, width: 4, color: Color.white)
        Art.stroke(&n, Art.svg("M0,0 q8,-6 16,-2 M4,8 q8,-5 15,0").applying(CGAffineTransform(translationX: 736, y: Hv - 122)), Art.color(0x2A1E1A), width: 2.4)
        // Near framing: dry grasses in the trailing bottom corner.
        Kit.grassTuft(&n, x: 872, baseY: floorN + 2, height: 50, color: 0x6E7A46, seed: 4)
        Kit.grassTuft(&n, x: 820, baseY: floorN + 4, height: 36, color: 0x5E6E44, seed: 9)
    }
}
