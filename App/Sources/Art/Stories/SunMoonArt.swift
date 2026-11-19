import SwiftUI
import OmramoCore

/// Concept art for "Why the Sun and the Moon Live in the Sky", drawn in code (round 5;
/// composed from the shared kit).
///
/// An Efik tale from Calabar and the Cross River. The cast and the shared parts are in
/// `SunMoonArt+Cast.swift`, the folded-phone scenes in `SunMoonArt+Folded.swift`, the
/// tap-to-see pictures, portraits, face chips and the cover in `SunMoonArt+Pictures.swift`.
/// This file holds the entry point and the four unfolded scenes. Every sky is pale; the land
/// and the cloth carry the colour. Cultural review (an Efik reader) is required and pending.
enum SunMoonArt {
    /// Draws the picture called `name`. Returns false for a name this story does not have.
    static func paint(_ name: String, role: ArtRole, in context: inout GraphicsContext, size: CGSize) -> Bool {
        guard size.width > 0, size.height > 0 else { return false }
        switch (name, role) {
        case ("scene-visit", .sceneUnfolded): visitScene(&context, size)
        case ("scene-visit", .sceneFolded): visitFolded(&context, size)
        case ("scene-building", .sceneUnfolded): buildingScene(&context, size)
        case ("scene-building", .sceneFolded): buildingFolded(&context, size)
        case ("scene-flood", .sceneUnfolded): floodScene(&context, size)
        case ("scene-flood", .sceneFolded): floodFolded(&context, size)
        case ("scene-sky", .sceneUnfolded): skyScene(&context, size)
        case ("scene-sky", .sceneFolded): skyFolded(&context, size)
        case ("see-cross-river", .picture): crossRiverPicture(&context, size)
        case ("see-compound", .picture): compoundPicture(&context, size)
        case ("see-tide", .picture): tidePicture(&context, size)
        case ("char-sun", .portrait): sunPortrait(&context, size)
        case ("char-moon", .portrait): moonPortrait(&context, size)
        case ("char-water", .portrait): waterPortrait(&context, size)
        case ("face-sun", .face): sunFace(&context, size)
        case ("face-moon", .face): moonFace(&context, size)
        case ("face-water", .face): waterFace(&context, size)
        case ("cover", .cover): cover(&context, size)
        default:
            return false
        }
        return true
    }

    /// A low bank of river mud lying in the water: a lens `width` long whose crest is about
    /// `height` above `y`, with a wet, bright edge.
    static func mudBank(_ context: inout GraphicsContext, x0: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        guard width > 0, height > 0 else { return }
        let x1: CGFloat = x0 + width
        var bank = Path()
        bank.move(to: CGPoint(x: x0, y: y))
        bank.addCurve(
            to: CGPoint(x: x1, y: y),
            control1: CGPoint(x: x0 + width * 0.2, y: y - height * 1.3),
            control2: CGPoint(x: x1 - width * 0.3, y: y - height * 1.3)
        )
        bank.addCurve(
            to: CGPoint(x: x0, y: y),
            control1: CGPoint(x: x1 - width * 0.2, y: y + height * 0.7),
            control2: CGPoint(x: x0 + width * 0.2, y: y + height * 0.7)
        )
        bank.closeSubpath()
        let under = Art.ellipse(x0 + width * 0.52, y + height * 0.4, width * 0.52, height * 0.5)
        Art.fill(&context, under, ArtStyle.coolShade.opacity(0.14))
        Kit.solid(&context, bank, stops: mudStops(), light: 0.24, shade: 0.2, rim: 2)
        var wet = Path()
        wet.move(to: CGPoint(x: x0 + width * 0.08, y: y + height * 0.2))
        wet.addQuadCurve(to: CGPoint(x: x1 - width * 0.08, y: y + height * 0.2), control: CGPoint(x: x0 + width / 2, y: y + height * 0.62))
        Art.stroke(&context, wet, Color.white.opacity(0.5), width: 1.4)
    }
}

// MARK: - scene-visit: where the wide river meets the sea

extension SunMoonArt {
    /// scene-visit (unfolded): the pale sky and the bright line where the river meets the
    /// sea; a mud bank with mangroves and palms on the trailing side; low across the trailing
    /// pane the Sun in his dugout canoe, leaning toward the Water, who rises laughing from
    /// the river beside him.
    static func visitScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 150)
        let light = day()
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let H: CGFloat = st.H
        let s: CGFloat = st.far
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.cloud(&context, 600, H * 0.36, scale: 0.9 * s, color: Art.color(0xFFFFFF, 0.7))
        Kit.cloud(&context, 330, H * 0.74, scale: 0.5 * s, color: Art.color(0xFFFFFF, 0.45))
        farShore(&context, x0: -60, x1: 230, horizon: H, height: 15 * s, light: light, seed: 3)
        farShore(&context, x0: 500, x1: 960, horizon: H, height: 20 * s, light: light, seed: 8)
        ArtStyle.atmosphere(&context, width: w, top: H - 60 * s, bottom: H + 4, color: light.haze, alpha: 0.3)
        Kit.birds(&context, 262, H - 44 * s, scale: s, color: Art.color(0x5E8F96))
        Kit.water(&context, width: w, top: H, bottom: h, stops: riverStops(), light: light, ripples: 60)
        Kit.glints(&context, x: 350, top: H, depth: st.depth * 0.5, color: Art.color(0xFFF8DC), count: 26)
        Kit.swells(&context, width: w, top: H + 24, bottom: h, rows: 5 + Int(st.tall * 4), crest: Color.white)
        visitLeading(&context, st)
        let Hv: CGFloat = st.Hv
        Kit.designSpace(&context, st) { v in
            Kit.nearSpace(&v, st, anchorX: 800) { n in
                visitShore(&n, Hv)
                visitFriends(&n, Hv)
            }
        }
        visitNear(&context, st)
        ArtStyle.finish(&context, size)
    }

    /// Low on the leading side: a mud bar with a few reeds and a white egret.
    static func visitLeading(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let s: CGFloat = st.far
        let y: CGFloat = st.H + 40 * s
        mudBank(&context, x0: 96, y: y, width: 130 * s, height: 9 * s)
        Kit.reeds(&context, x: 96 + 28 * s, baseY: y - 2 * s, count: 5, height: 34 * s, seed: 14)
        Art.group(&context, x: 96 + 78 * s, y: y - 4 * s, scale: 0.55 * s) { b in
            Kit.bird(&b, Kit.heronLook())
        }
    }

    /// The shore on the trailing side: oil palms behind, a mud bank, mangroves on their long
    /// legs with their toes in the water.
    static func visitShore(_ n: inout GraphicsContext, _ Hv: CGFloat) {
        palm(&n, x: 716, baseY: Hv + 8, height: 190, lean: -14, seed: 11)
        let tall: CGFloat = min(480, Hv * 0.82)
        palm(&n, x: 852, baseY: Hv + 20, height: tall, lean: -22, seed: 4)
        mudBank(&n, x0: 668, y: Hv + 30, width: 300, height: 26)
        crab(&n, 716, Hv + 22, scale: 0.6)
        Kit.mangrove(&n, x: 784, waterY: Hv + 46, height: 190, palette: mangroveGreens(), seed: 2)
        Kit.mangrove(&n, x: 874, waterY: Hv + 60, height: 250, palette: mangroveGreens(), seed: 6)
    }

    /// The two friends: the Water rising from the river, and the Sun in his canoe.
    static func visitFriends(_ n: inout GraphicsContext, _ Hv: CGFloat) {
        Art.group(&n, x: 506, y: Hv + 72, scale: 0.85) { g in
            waterFigure(&g, look: CGPoint(x: 0.7, y: -0.1), laugh: true, wave: true)
        }
        Art.group(&n, x: 652, y: Hv + 86) { g in
            sunInCanoe(&g, look: CGPoint(x: -0.6, y: 0.2), mouth: .grin)
        }
        fish(&n, 596, Hv + 118, scale: 0.9, rotate: -0.3)
        Kit.ripples(&n, 596, Hv + 130, 40, count: 1, opacity: 0.45)
    }

    /// The near plane: dark leaves in the trailing corners and, on a tall window, a mud spit
    /// with reeds and a crab across the foot of the picture.
    static func visitNear(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let dark = Art.color(0x0E4A40)
        Kit.cornerLeaves(&context, size: st.size, corner: 1, color: dark, scale: 1.2 * st.far, seed: 9)
        Kit.cornerLeaves(&context, size: st.size, corner: 3, color: dark, scale: 1.1 * st.far, seed: 5)
        let h: CGFloat = st.h
        if st.tall > 0.25 {
            let band = CGRect(x: 60, y: st.H + st.depth * 0.44, width: 520, height: st.depth * 0.2)
            waterPeople(&context, in: band, count: 5, seed: 6, scale: 1.3)
            mudBank(&context, x0: -60, y: h - 44, width: 460, height: 40)
            Kit.reeds(&context, x: 70, baseY: h - 50, count: 7, height: 130, seed: 4)
            crab(&context, 270, h - 60, scale: 1.7)
            Kit.grassTuft(&context, x: 372, baseY: h - 42, height: 70, color: 0x2C9462, seed: 3)
        } else {
            let y: CGFloat = st.H + st.depth * 0.62
            fish(&context, 300, y, scale: st.far)
            Kit.ripples(&context, 300, y + 12 * st.far, 40 * st.far, count: 1, opacity: 0.4)
        }
    }
}

// MARK: - scene-building: the great compound goes up

extension SunMoonArt {
    /// scene-building (unfolded): pale sky and a line of palms; on the trailing side the
    /// compound going up — red earth walls round a wide swept yard, one great roof half
    /// covered in golden thatch; the Moon passing palm leaves up to the Sun on his ladder.
    static func buildingScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 160)
        let light = day()
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let H: CGFloat = st.H
        let s: CGFloat = st.far
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.cloud(&context, 520, H * 0.3, scale: 0.8 * s, color: Art.color(0xFFFFFF, 0.7))
        Kit.farTrees(&context, x0: -20, x1: w + 20, baseY: H + 2, height: 34 * s, count: 30, color: light.far, seed: 5)
        let farPalms: [(CGFloat, CGFloat)] = [(48, 58), (176, 64), (392, 54)]
        for item in farPalms {
            Kit.palm(&context, x: item.0, baseY: H + 2, height: item.1 * s, lean: 6 * s, fronds: 0x6FB68E, trunk: 0x9A8A70, seed: 3)
        }
        ArtStyle.atmosphere(&context, width: w, top: H - 80 * s, bottom: H + 4, color: light.haze, alpha: 0.38)
        Kit.ground(&context, width: w, top: H, bottom: h, stops: yardStops())
        yardMarks(&context, st, seed: 12)
        buildingLeading(&context, st)
        let Hv: CGFloat = st.Hv
        Kit.designSpace(&context, st) { v in
            Kit.nearSpace(&v, st, anchorX: 620) { n in
                buildingCompound(&n, Hv)
                buildingWorkers(&n, Hv)
            }
        }
        buildingNear(&context, st)
        ArtStyle.finish(&context, size)
    }

    /// The marks of the broom on the swept yard: pale, shallow arcs, longer toward the viewer.
    static func yardMarks(_ context: inout GraphicsContext, _ st: Kit.Stage, seed: UInt32) {
        var random = ArtRandom(seed)
        var sweeps = Path()
        let count: Int = 12 + Int(st.tall * 16)
        let depth: CGFloat = max(1, st.depth - 30)
        for _ in 0..<count {
            let t: CGFloat = Kit.rnd(&random)
            let y: CGFloat = st.H + 22 + depth * t
            let x: CGFloat = st.w * Kit.rnd(&random)
            let length: CGFloat = 30 + 50 * t
            sweeps.move(to: CGPoint(x: x, y: y))
            sweeps.addQuadCurve(to: CGPoint(x: x + length, y: y + 2), control: CGPoint(x: x + length / 2, y: y - 5 - 6 * t))
        }
        Art.stroke(&context, sweeps, Art.color(0xFFE9CC, 0.5), width: 1.6)
    }

    /// Low on the leading side: the compound's far wall with its gateway, and a water pot.
    static func buildingLeading(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let s: CGFloat = st.far
        let baseY: CGFloat = st.H + 16 * s
        Kit.longWall(&context, x0: -10, x1: 212, baseY: baseY, height: 30 * s, color: earth)
        Kit.longWall(&context, x0: 262, x1: 420, baseY: baseY, height: 30 * s, color: earth)
        Kit.gateway(&context, cx: 237, baseY: baseY, width: 56 * s, height: 56 * s, color: earth)
        Kit.pot(&context, cx: 112, baseY: baseY + 10 * s, width: 22 * s, height: 26 * s, color: 0xB5683A)
    }

    /// The compound on the trailing side: the back wall, a finished house, palms, and the
    /// great house with its roof frame half thatched and a ladder against the eaves.
    static func buildingCompound(_ n: inout GraphicsContext, _ Hv: CGFloat) {
        let tall: CGFloat = min(430, Hv * 0.74)
        palm(&n, x: 760, baseY: Hv, height: tall, lean: 18, seed: 5)
        palm(&n, x: 884, baseY: Hv + 2, height: tall * 0.66, lean: -12, seed: 9)
        Kit.longWall(&n, x0: 440, x1: 980, baseY: Hv + 10, height: 52, color: earth)
        earthHouse(&n, cx: 836, baseY: Hv + 26, width: 120, wallHeight: 66, roofHeight: 56)
        // The great house: thick walls of pressed red earth, a doorway, the roof going on.
        Kit.shadow(&n, 690, Hv + 50, width: 216)
        Kit.wall(&n, rect: CGRect(x: 590, y: Hv - 50, width: 200, height: 100), color: earth)
        Kit.opening(&n, rect: CGRect(x: 706, y: Hv - 12, width: 34, height: 62), arched: false, color: 0x5A3A2A)
        roofFrame(&n, cx: 690, eaveY: Hv - 50, width: 248, height: 84)
        Art.clipped(&n, to: Art.rect(540, Hv - 170, 166, 140)) { c in
            thatchRoof(&c, cx: 690, eaveY: Hv - 50, width: 248, height: 84)
        }
        Art.group(&n, x: 724, y: Hv - 92, rotate: -0.5, scale: 0.9) { b in
            palmBundle(&b)
        }
        ladder(&n, footX: 552, footY: Hv + 62, topX: 574, topY: Hv - 56)
        // Things of the work in the yard.
        Kit.tool(&n, .broom, x: 782, baseY: Hv + 52, height: 70)
        Kit.pot(&n, cx: 816, baseY: Hv + 60, width: 30, height: 36, color: 0xB5683A)
        Kit.basket(&n, cx: 642, baseY: Hv + 66, width: 34, height: 26)
        Art.group(&n, x: 600, y: Hv + 96, scale: 1.2) { b in
            palmBundle(&b)
        }
    }

    /// The Sun on the ladder, reaching up to the roof; the Moon below, lifting a bundle of
    /// palm leaves to him.
    static func buildingWorkers(_ n: inout GraphicsContext, _ Hv: CGFloat) {
        Art.group(&n, x: 578, y: Hv - 4, scaleX: -1) { p in
            sunFigure(&p, pose: .reach, look: CGPoint(x: -0.5, y: -0.4), mouth: .grin, mirrored: true)
        }
        Art.group(&n, x: 630, y: Hv - 144, rotate: -0.3, scale: 0.8, scaleX: -1) { b in
            palmBundle(&b)
        }
        Kit.shadow(&n, 512, Hv + 80, width: 58)
        Art.group(&n, x: 512, y: Hv + 80, scaleX: -1) { p in
            moonFigure(&p, pose: .carry, look: CGPoint(x: -0.4, y: -0.6), mouth: .smile, mirrored: true)
        }
        Art.group(&n, x: 548, y: Hv - 14, rotate: -0.8, scale: 0.9, scaleX: -1) { b in
            palmBundle(&b)
        }
    }

    /// The near plane: palm fronds in the top trailing corner, grass at the yard's edge, and
    /// on a tall window the wide swept yard with the things of the work lying in it.
    static func buildingNear(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let h: CGFloat = st.h
        Kit.cornerLeaves(&context, size: st.size, corner: 1, color: Art.color(0x0F4A3C), scale: 1.3 * st.far, seed: 4)
        Kit.grassTuft(&context, x: 26, baseY: h + 4, height: 64 * st.far, color: 0x2E8F56, seed: 2)
        if st.tall > 0.25 {
            Kit.pebbles(&context, in: CGRect(x: 40, y: h - 220, width: 800, height: 170), count: 14, seed: 3, color: 0xB98A6A)
            Art.group(&context, x: 190, y: h - 96, scale: 2.2) { b in
                palmBundle(&b)
            }
            Art.group(&context, x: 262, y: h - 70, rotate: 0.3, scale: 2) { b in
                palmBundle(&b)
            }
            Kit.basket(&context, cx: 356, baseY: h - 168, width: 64, height: 48)
            Kit.pot(&context, cx: 448, baseY: h - 84, width: 70, height: 84, color: 0xB5683A)
            Kit.shadow(&context, 566, h - 118, width: 84)
            stool(&context, cx: 566, baseY: h - 118, width: 80)
        }
    }
}

// MARK: - scene-flood: the Water comes to visit

extension SunMoonArt {
    /// scene-flood (unfolded): a bright day. The Water flows in at the gate of the compound,
    /// his kind face in the flow, and clear water spreads across the yard with fish, prawns
    /// and sideways crabs; the Sun and the Moon are up on the thatched roof.
    static func floodScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 170)
        let light = day()
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let H: CGFloat = st.H
        let s: CGFloat = st.far
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.cloud(&context, 610, H * 0.26, scale: 0.8 * s, color: Art.color(0xFFFFFF, 0.7))
        Kit.farTrees(&context, x0: -20, x1: w + 20, baseY: H + 2, height: 30 * s, count: 30, color: light.far, seed: 7)
        let farPalms: [(CGFloat, CGFloat)] = [(92, 60), (330, 54)]
        for item in farPalms {
            Kit.palm(&context, x: item.0, baseY: H + 2, height: item.1 * s, lean: -5 * s, fronds: 0x6FB68E, trunk: 0x9A8A70, seed: 5)
        }
        ArtStyle.atmosphere(&context, width: w, top: H - 80 * s, bottom: H + 4, color: light.haze, alpha: 0.38)
        Kit.water(&context, width: w, top: H, bottom: h, stops: floodStops(), light: light, ripples: 70, seed: 41)
        Kit.glints(&context, x: 300, top: H + 14 * s, depth: st.depth * 0.4, color: Art.color(0xFFFBE6), count: 20)
        floodLeading(&context, st)
        let Hv: CGFloat = st.Hv
        Kit.designSpace(&context, st) { v in
            Kit.nearSpace(&v, st, anchorX: 760) { n in
                floodGate(&n, Hv)
                floodRoof(&n, Hv)
            }
        }
        floodNear(&context, st)
        ArtStyle.finish(&context, size)
    }

    /// Low on the leading side: the far wall standing in still water, and a few of the
    /// Water's people.
    static func floodLeading(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let s: CGFloat = st.far
        let H: CGFloat = st.H
        Kit.longWall(&context, x0: -10, x1: 436, baseY: H + 12 * s, height: 30 * s, color: earth)
        shallows(&context, x0: -10, x1: 440, y: H + 3 * s, depth: 12 * s)
        let band = CGRect(x: 50, y: H + st.depth * 0.36, width: 360, height: st.depth * 0.34)
        waterPeople(&context, in: band, count: 4, seed: 9, scale: s)
    }

    /// The gate with the Water flowing in, the water spreading over the yard, his people,
    /// and the Moon's stool afloat with a crab sitting on it.
    static func floodGate(_ n: inout GraphicsContext, _ Hv: CGFloat) {
        Kit.longWall(&n, x0: 420, x1: 494, baseY: Hv + 40, height: 92, color: earth)
        Kit.longWall(&n, x0: 656, x1: 980, baseY: Hv + 40, height: 92, color: earth)
        Kit.gateway(&n, cx: 575, baseY: Hv + 40, width: 170, height: 150, color: earth)
        var flow = Path()
        flow.move(to: CGPoint(x: 518, y: Hv + 34))
        flow.addLine(to: CGPoint(x: 632, y: Hv + 34))
        flow.addCurve(to: CGPoint(x: 770, y: Hv + 108), control1: CGPoint(x: 652, y: Hv + 60), control2: CGPoint(x: 724, y: Hv + 86))
        flow.addLine(to: CGPoint(x: 400, y: Hv + 108))
        flow.addCurve(to: CGPoint(x: 518, y: Hv + 34), control1: CGPoint(x: 446, y: Hv + 86), control2: CGPoint(x: 498, y: Hv + 60))
        flow.closeSubpath()
        let pour: Kit.Stops = [(Art.color(0xDDF8F2, 0.8), 0), (Art.color(0x9FE2DC, 0), 1)]
        Art.fillLinear(&n, flow, pour, from: CGPoint(x: 0, y: Hv + 34), to: CGPoint(x: 0, y: Hv + 108))
        shallows(&n, x0: 420, x1: 494, y: Hv + 24, depth: 18)
        shallows(&n, x0: 656, x1: 980, y: Hv + 24, depth: 18)
        Kit.rippleMarks(&n, x0: 430, x1: 760, y0: Hv + 44, y1: Hv + 112, count: 26, seed: 5, color: Color.white, alpha: 0.5)
        Art.group(&n, x: 575, y: Hv + 44, scale: 0.66) { g in
            waterFigure(&g, look: CGPoint(x: 0.6, y: -0.5), laugh: false, wave: true)
        }
        let band = CGRect(x: 462, y: Hv + 64, width: 60, height: 40)
        waterPeople(&n, in: band, count: 2, seed: 3, scale: 0.9)
        fish(&n, 640, Hv + 72, scale: 0.8, flip: true)
        prawn(&n, 610, Hv + 112, scale: 1.1)
        crab(&n, 500, Hv + 122, scale: 0.9)
        // A crab sits down on the Moon's best stool.
        stool(&n, cx: 556, baseY: Hv + 96, width: 46)
        crab(&n, 556, Hv + 73, scale: 0.7)
        Kit.ripples(&n, 556, Hv + 97, 62, count: 2)
    }

    /// The house with the Sun and the Moon up on its roof, water at its door.
    static func floodRoof(_ n: inout GraphicsContext, _ Hv: CGFloat) {
        let tall: CGFloat = min(440, Hv * 0.78)
        palm(&n, x: 880, baseY: Hv + 30, height: tall, lean: -30, seed: 6)
        earthHouse(&n, cx: 762, baseY: Hv + 120, width: 176, wallHeight: 112, roofHeight: 88)
        shallows(&n, x0: 640, x1: 900, y: Hv + 90, depth: 36)
        fish(&n, 724, Hv + 106, scale: 0.8)
        Kit.ripples(&n, 724, Hv + 116, 36, count: 1, opacity: 0.5)
        Art.group(&n, x: 724, y: Hv - 46) { p in
            sunFigure(&p, pose: .sit, look: CGPoint(x: -0.7, y: 0.6), mouth: .oh)
        }
        Art.group(&n, x: 808, y: Hv - 46) { p in
            moonFigure(&p, pose: .sit, look: CGPoint(x: -0.6, y: 0.6), mouth: .smile)
        }
    }

    /// The near plane: palm fronds in the top trailing corner and, on a tall window, the
    /// deep bright water full of the Water's people, with a pot bobbing in it.
    static func floodNear(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let h: CGFloat = st.h
        Kit.cornerLeaves(&context, size: st.size, corner: 1, color: Art.color(0x0F4A3C), scale: 1.2 * st.far, seed: 7)
        Kit.swells(&context, width: st.w, top: st.H + st.depth * 0.5, bottom: h, rows: 3 + Int(st.tall * 4), crest: Color.white)
        if st.tall > 0.25 {
            let band = CGRect(x: 60, y: h - 290, width: 760, height: 190)
            waterPeople(&context, in: band, count: 8, seed: 8, scale: 1.6)
            Art.group(&context, x: 250, y: h - 70, rotate: 0.22) { g in
                Kit.pot(&g, cx: 0, baseY: 0, width: 76, height: 90, color: 0xB5683A)
            }
            shallows(&context, x0: 196, x1: 306, y: h - 96, depth: 40)
            Kit.ripples(&context, 250, h - 92, 120, count: 2)
            Kit.cornerLeaves(&context, size: st.size, corner: 2, color: Art.color(0x0F4A3C), scale: 1.3, seed: 3)
        }
    }
}

// MARK: - scene-sky: plenty of room up here

extension SunMoonArt {
    /// scene-sky (unfolded): a pale, wide, calm sky. High on the trailing side the Sun and the
    /// Moon sit side by side, his gold glow and her silver halo together; far below, calm
    /// wide water with only the tip of the roof and a few palm tops showing, and the Water's
    /// face, small and peaceful, low on the leading side.
    static func skyScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 120)
        let light = day()
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let H: CGFloat = st.H
        let s: CGFloat = st.far
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.cloud(&context, 250, H - 34 * s, scale: 0.5 * s, color: Art.color(0xFFFFFF, 0.5))
        Kit.cloud(&context, 840, H - 70 * s, scale: 0.7 * s, color: Art.color(0xFFFFFF, 0.6))
        farShore(&context, x0: -90, x1: 210, horizon: H, height: 7 * s, light: light, seed: 4)
        ArtStyle.atmosphere(&context, width: w, top: H - 40 * s, bottom: H + 4, color: light.haze, alpha: 0.4)
        Kit.water(&context, width: w, top: H, bottom: h, stops: floodStops(), light: light, ripples: 40, seed: 52)
        // The gold and the silver lying on the water under the two of them.
        let shift: CGFloat = 892 * (1 - st.fit)
        Kit.glints(&context, x: shift + 580 * st.fit, top: H, depth: st.depth, color: Art.color(0xFFE08A), count: 30, seed: 8)
        Kit.glints(&context, x: shift + 700 * st.fit, top: H, depth: st.depth, color: Art.color(0xF4F6FF), count: 22, seed: 15)
        Kit.swells(&context, width: w, top: H + 20, bottom: h, rows: 4 + Int(st.tall * 4), crest: Color.white)
        skyWaterFace(&context, st)
        let Hv: CGFloat = st.Hv
        let seat: CGFloat = max(220, Hv * 0.5)
        let k: CGFloat = st.grow * (st.fit < 1 ? 1 : 1.05)
        Kit.designSpace(&context, st) { v in
            skyDrowned(&v, Hv)
            Kit.birds(&v, 548, seat + 150 * k, scale: 1.2, color: Art.color(0x5E8F96))
            Art.group(&v, x: 630, y: seat, scale: k) { g in
                skyPair(&g, look: CGPoint(x: -0.5, y: 0.7))
            }
        }
        skyNear(&context, st)
        ArtStyle.finish(&context, size)
    }

    /// The Water's face in the ripples, low on the leading side: only his head and one
    /// waving arm above the calm water.
    static func skyWaterFace(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let s: CGFloat = st.far
        let line: CGFloat = st.H + 58 * s
        Art.clipped(&context, to: Art.rect(0, 0, st.w, line)) { c in
            Art.group(&c, x: 300, y: line + 46 * s, scale: 0.5 * s) { g in
                waterFigure(&g, look: CGPoint(x: 0.6, y: -0.8), laugh: false, wave: true, critters: false)
            }
        }
        let skirt: Path = Kit.personScallop(cx: 300, cy: line, rx: 46 * s, ry: 2 * s, from: 180, to: 360, count: 7, r: 5 * s)
        Art.fill(&context, skirt, Art.color(foam, 0.92))
        Kit.ripples(&context, 300, line + 5 * s, 120 * s, count: 2)
        fish(&context, 196, line + 10 * s, scale: 0.8 * s, flip: true)
    }

    /// What still shows above the water: the tip of the thatched roof and three palm tops,
    /// each cut at its own waterline with a ring of ripples.
    static func skyDrowned(_ v: inout GraphicsContext, _ Hv: CGFloat) {
        Art.clipped(&v, to: Art.rect(0, 0, 892, Hv + 14)) { c in
            palm(&c, x: 724, baseY: Hv + 84, height: 124, lean: 8, seed: 12)
        }
        Kit.ripples(&v, 730, Hv + 15, 30, count: 1)
        Art.clipped(&v, to: Art.rect(0, 0, 892, Hv + 28)) { c in
            palm(&c, x: 540, baseY: Hv + 124, height: 196, lean: -12, seed: 8)
        }
        Kit.ripples(&v, 532, Hv + 29, 40, count: 2)
        Art.clipped(&v, to: Art.rect(0, 0, 892, Hv + 44)) { c in
            palm(&c, x: 812, baseY: Hv + 156, height: 250, lean: 16, seed: 5)
        }
        Kit.ripples(&v, 824, Hv + 45, 48, count: 2)
        Art.clipped(&v, to: Art.rect(0, 0, 892, Hv + 60)) { c in
            thatchRoof(&c, cx: 648, eaveY: Hv + 108, width: 240, height: 84)
        }
        Kit.ripples(&v, 648, Hv + 62, 150, count: 2)
        Kit.rippleMarks(&v, x0: 560, x1: 740, y0: Hv + 62, y1: Hv + 76, count: 8, seed: 3, color: Color.white, alpha: 0.5)
    }

    /// The near plane: the crowns of two drowned palms at the foot of the picture, and on a
    /// tall window a few of the Water's people in the deep calm water.
    static func skyNear(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let h: CGFloat = st.h
        let s: CGFloat = st.far
        palm(&context, x: 862, baseY: h + 250 * s, height: 340 * s, lean: 20 * s, seed: 15)
        palm(&context, x: 30, baseY: h + 190 * s, height: 250 * s, lean: -10 * s, seed: 21)
        if st.tall > 0.25 {
            let band = CGRect(x: 80, y: st.H + st.depth * 0.4, width: 620, height: st.depth * 0.3)
            waterPeople(&context, in: band, count: 5, seed: 17, scale: 1.4)
        }
    }
}
