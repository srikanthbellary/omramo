import SwiftUI
import OmramoCore

/// Concept art for "The Long Day at Fish Camp", drawn in code (round 5; composed from the shared kit).
///
/// A present-day Yup'ik summer fish camp on the Kuskokwim: pale gold and peach evenings that
/// never go dark, a wide silty river, flat tundra, plywood cabins, a skiff, drying racks under
/// a blue tarp. No snow, no snow houses, no fur clothing anywhere (CONTENT_PLAN §1.4).
enum FishCampArt {
    /// Draws the picture called `name`. Returns false for a name this story does not have.
    static func paint(_ name: String, role: ArtRole, in context: inout GraphicsContext, size: CGSize) -> Bool {
        guard size.width > 0, size.height > 0 else { return false }
        switch (name, role) {
        case ("scene-camp", .sceneUnfolded): campScene(&context, size)
        case ("scene-camp", .sceneFolded): campFolded(&context, size)
        case ("scene-net", .sceneUnfolded): netScene(&context, size)
        case ("scene-net", .sceneFolded): netFolded(&context, size)
        case ("scene-bank", .sceneUnfolded): bankScene(&context, size)
        case ("scene-bank", .sceneFolded): bankFolded(&context, size)
        case ("scene-porch", .sceneUnfolded): porchScene(&context, size)
        case ("scene-porch", .sceneFolded): porchFolded(&context, size)
        case ("see-drying-rack", .picture): rackPicture(&context, size)
        case ("see-kuskokwim", .picture): riverPicture(&context, size)
        case ("see-first-catch", .picture): firstCatchPicture(&context, size)
        case ("see-sod-house", .picture): sodHousePicture(&context, size)
        case ("char-nick", .portrait): nickPortrait(&context, size)
        case ("char-grandma", .portrait): grandmaPortrait(&context, size)
        case ("face-nick", .face): nickFace(&context, size)
        case ("face-grandma", .face): grandmaFace(&context, size)
        case ("face-lena", .face): lenaFace(&context, size)
        case ("cover", .cover): cover(&context, size)
        default:
            return false
        }
        return true
    }

    /// The far plane every unfolded scene shares: the pale sky, long thin clouds, the low far
    /// shore of the tundra, and the wide brown river from the horizon to the bottom edge.
    static func riverBackdrop(_ context: inout GraphicsContext, _ st: Kit.Stage, light: Kit.Light, ripples: Int, seed: UInt32) {
        Kit.sky(&context, st.size, horizon: st.H, light: light)
        cloudStreaks(&context, width: st.w, horizon: st.H, color: Color.white)
        farShore(&context, width: st.w, horizon: st.H, scale: st.far, light: light, seed: seed)
        Kit.water(&context, width: st.w, top: st.H, bottom: st.h, stops: riverStops(), light: light, ripples: ripples, seed: seed &+ 3)
    }
}

// MARK: - scene-camp (unfolded): the family's camp on the low bank

extension FishCampArt {
    static func campScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 150)
        let light = evening()
        riverBackdrop(&context, st, light: light, ripples: 46 + Int(st.tall * 40), seed: 11)
        // The sun is just out of the picture on the left: only its glow on the sky and water.
        Art.glow(&context, 0, st.H - 30 * st.far, 240 * st.far, light.glow, alpha: 0.4)
        Kit.glints(&context, x: 130, top: st.H, depth: st.depth, color: Art.color(0xFFF6E0), count: 30, seed: 8)
        Kit.designSpace(&context, st) { v in
            bank(&v, st, x0: 540, run: 1)
            campGround(&v, st)
            Kit.nearSpace(&v, st, anchorX: 700) { n in
                campBuildings(&n, st)
                campPeople(&n, st)
            }
            campNear(&v, st)
        }
        ArtStyle.finish(&context, size)
    }

    /// Grass on the bank, the worn path to the table, the skiff pulled up on the mud.
    static func campGround(_ v: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        let hv: CGFloat = st.hv
        let far = CGRect(x: 530, y: Hv + 2, width: 362, height: 56)
        Kit.grass(&v, in: far, count: 60, seed: 5, color: Art.color(0x6F8C54, 0.7), height: 7)
        let near = CGRect(x: 420, y: Hv + 62, width: 472, height: max(20, hv - Hv - 62))
        let more: Int = 46 + Int(st.tall * 90)
        Kit.grass(&v, in: near, count: more, seed: 6, color: Art.color(0x5F7F4A, 0.75), height: 11)
        Kit.grass(&v, in: near, count: more / 2, seed: 7, color: Art.color(0xC4D494, 0.7), height: 9)
        let dirt: Kit.Stops = [(Art.color(0xB8A27C, 0.9), 0), (Art.color(0x9A8664, 0.95), 1)]
        Kit.ribbon(&v, nearX: 590, nearY: hv + 12, nearWidth: 96, farX: 640, farY: Hv + 108, farWidth: 28, stops: dirt)
        let pebbleBox = CGRect(x: 170, y: Hv + 110, width: 110, height: 36)
        Kit.pebbles(&v, in: pebbleBox, count: 7, seed: 4, color: 0x7F796E)
        Kit.shadow(&v, 272, Hv + 132, width: 210, alpha: 0.22)
        Art.group(&v, x: 270, y: Hv + 124, rotate: Kit.deg(-2), scale: 0.8) { b in
            skiff(&b, motor: true)
        }
        Kit.ripples(&v, 176, Hv + 132, 60, count: 2, color: Color.white, opacity: 0.4)
        if st.tall > 0.2 {
            Kit.grassTuft(&v, x: 470, baseY: Hv + 220, height: 44, color: 0x6F8C54, seed: 12)
            Kit.grassTuft(&v, x: 760, baseY: Hv + 250, height: 52, color: 0x6F8C54, seed: 13)
            fireweed(&v, x: 520, baseY: Hv + 262, height: 84, seed: 3)
            fireweed(&v, x: 544, baseY: Hv + 270, height: 66, seed: 5)
        }
    }

    /// Two plywood cabins, the grey smokehouse with its smoke, the long rack under the tarp.
    static func campBuildings(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        Art.group(&n, x: 560, y: Hv + 2) { g in
            cabin(&g, width: 44, height: 88, rise: 14, wall: greyBoard, roof: 0x6A6660, boards: true, door: false, pipe: false)
        }
        smoke(&n, x: 566, y: Hv - 98, scale: 1)
        Art.group(&n, x: 642, y: Hv) { g in
            cabin(&g, width: 84, height: 46, rise: 14, wall: plywood, roof: 0x4E5258, boards: false, door: true, pipe: true)
        }
        Art.group(&n, x: 838, y: Hv + 6) { g in
            cabin(&g, width: 112, height: 58, rise: 18, wall: 0xC4AC84, roof: 0xA9B4B8, boards: false, door: true, pipe: true)
        }
        Art.group(&n, x: 772, y: Hv + 12) { g in
            fuelCan(&g)
        }
        Art.group(&n, x: 735, y: Hv + 54) { g in
            rack(&g, width: 150, height: 60, rows: 2, tarp: true, seed: 3)
        }
        var dog = Kit.dogLook()
        dog.body = 0x8E8A88
        dog.belly = 0xF1ECE4
        dog.dark = 0x3A3438
        dog.ears = .pointed
        dog.tail = .bushy
        dog.showsEyeWhite = false
        let husky = dog
        Kit.shadow(&n, 856, Hv + 36, width: 70, alpha: 0.2)
        Art.group(&n, x: 856, y: Hv + 36, scale: 0.42) { g in
            Kit.beast(&g, husky, pose: .sleep, mood: .sleepy)
        }
    }

    /// Grandma at the plank table with her uluaq, Nick carrying a bucket of strips.
    static func campPeople(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        let ground: CGFloat = Hv + 100
        Art.group(&n, x: 516, y: ground + 6) { g in
            tote(&g)
        }
        Art.group(&n, x: 578, y: ground) { g in
            cuttingTable(&g, width: 92, height: 48)
        }
        Art.group(&n, x: 566, y: ground - 51) { g in
            fillet(&g)
        }
        Art.group(&n, x: 482, y: ground + 14, scale: 0.9) { g in
            gull(&g)
        }
        Kit.shadow(&n, 642, ground, width: 62)
        Art.group(&n, x: 640, y: ground, scale: 0.82) { g in
            grandma(&g, act: .cut, look: CGPoint(x: -0.5, y: 0.5), mouth: .smile)
        }
        Kit.shadow(&n, 754, Hv + 94, width: 48)
        Art.group(&n, x: 752, y: Hv + 94, scale: 0.82) { g in
            nick(&g, act: .bucket, look: CGPoint(x: -0.6, y: 0), mouth: .smile)
        }
    }

    /// The near plane: dark grass and fireweed in the bottom corners.
    static func campNear(_ v: inout GraphicsContext, _ st: Kit.Stage) {
        let hv: CGFloat = st.hv
        Kit.reeds(&v, x: 52, baseY: hv + 8, count: 5, height: 58, seed: 9, color: 0x55744A)
        Kit.grassTuft(&v, x: 862, baseY: hv + 10, height: 74, color: 0x4F6A44, seed: 3)
        Kit.grassTuft(&v, x: 806, baseY: hv + 14, height: 52, color: 0x4F6A44, seed: 4)
        fireweed(&v, x: 884, baseY: hv + 6, height: 104, seed: 2)
    }
}

// MARK: - scene-net (unfolded): the first net, out on the wide river

extension FishCampArt {
    static func netScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 170)
        let light = evening()
        riverBackdrop(&context, st, light: light, ripples: 60 + Int(st.tall * 50), seed: 21)
        Art.glow(&context, 40, st.H - 24 * st.far, 220 * st.far, light.glow, alpha: 0.36)
        Kit.glints(&context, x: 170, top: st.H, depth: st.depth, color: Art.color(0xFFF6E0), count: 44, seed: 18)
        Kit.glints(&context, x: 560, top: st.H, depth: st.depth * 0.5, color: Art.color(0xFFF6E0, 0.7), count: 16, seed: 19)
        Kit.designSpace(&context, st) { v in
            Kit.nearSpace(&v, st, anchorX: 680) { n in
                netBoat(&n, st)
                netAndFish(&n, st)
            }
            netNear(&v, st)
        }
        ArtStyle.finish(&context, size)
    }

    /// The skiff from the side with Uncle Joe small at the outboard and Nick braced in the middle.
    static func netBoat(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let water: CGFloat = st.Hv + 84
        Art.fill(&n, Art.ellipse(696, water + 12, 176, 10), ArtStyle.coolShade.opacity(0.16))
        Art.group(&n, x: 806, y: water - 8, scale: 0.74) { g in
            uncle(&g)
        }
        Art.group(&n, x: 655, y: water - 6) { g in
            nick(&g, act: .haul, look: CGPoint(x: -0.5, y: 0.7), mouth: .open, vest: true)
        }
        Art.group(&n, x: 690, y: water, scale: 1.25) { g in
            skiff(&g, motor: true)
        }
        let foot = Art.rect(540, water + 4, 320, 10, radius: 5)
        Art.fill(&n, foot, Art.color(0x9C8A6E, 0.55))
        Kit.ripples(&n, 690, water + 6, 310, count: 2, color: Color.white, opacity: 0.5)
        Kit.ripples(&n, 858, water + 8, 50, count: 2, color: Color.white, opacity: 0.45)
    }

    /// The short net with its white floats, and the king salmon coming over the side.
    static func netAndFish(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let water: CGFloat = st.Hv + 84
        let fist = nickHand(.haul)
        let hx: CGFloat = 655 + fist.x
        let hy: CGFloat = water - 6 + fist.y
        let line: [CGPoint] = [
            CGPoint(x: 566, y: water + 9), CGPoint(x: 524, y: water + 15), CGPoint(x: 478, y: water + 19),
            CGPoint(x: 430, y: water + 20), CGPoint(x: 384, y: water + 18), CGPoint(x: 340, y: water + 13),
            CGPoint(x: 300, y: water + 7),
        ]
        // The web between his fists and the gunwale, then down into the water.
        var web = Path()
        let drops: [CGFloat] = [578, 588, 598, 608, 618]
        for x in drops {
            web.move(to: CGPoint(x: hx, y: hy))
            web.addLine(to: CGPoint(x: x, y: water - 33))
            web.addLine(to: CGPoint(x: x - 14, y: water + 6))
        }
        web.addPath(Art.line(585, water - 22, 622, water - 26))
        web.addPath(Art.line(572, water - 8, 612, water - 12))
        Art.stroke(&n, web, Art.color(0xEDF2E2, 0.8), width: 0.9)
        var rope = Path()
        rope.move(to: CGPoint(x: hx, y: hy))
        rope.addQuadCurve(to: CGPoint(x: 566, y: water + 9), control: CGPoint(x: 580, y: water - 44))
        rope.addPath(Art.polygon(line, closed: false))
        Art.stroke(&n, rope, Art.color(0xE9E0C8), width: 1.6)
        for point in line {
            Kit.ripples(&n, point.x, point.y + 3, 18, count: 1, color: Color.white, opacity: 0.4)
            let float = Art.ellipse(point.x, point.y, 7.5, 4.4)
            Kit.solid(&n, float, Art.color(0xFBF8F0), light: 0.1, shade: 0.24)
        }
        // The salmon: tail still in the water, head over the gunwale.
        Kit.ripples(&n, 580, water + 12, 44, count: 2, color: Color.white, opacity: 0.7)
        Art.group(&n, x: 600, y: water - 22, rotate: Kit.deg(-60), scale: 0.8, scaleX: -1) { g in
            salmon(&g)
        }
        let spray: [(CGFloat, CGFloat, CGFloat)] = [(566, -4, 2), (574, -14, 1.5), (592, 8, 1.8), (560, 6, 1.4), (604, -2, 1.3), (584, -24, 1.2)]
        var beads = Path()
        for bead in spray {
            beads.addPath(Art.circle(bead.0, water + bead.1, bead.2))
        }
        Art.fill(&n, beads, Color.white.opacity(0.85))
        Art.fill(&n, Art.circle(hx, hy, 4.2), Art.color(nickLook().skin))
    }

    /// The deep foreground water on a tall window, and dark sedge in the bottom-right corner.
    static func netNear(_ v: inout GraphicsContext, _ st: Kit.Stage) {
        let hv: CGFloat = st.hv
        if st.tall > 0.15 {
            let extra: Int = Int(st.tall * 70)
            Kit.rippleMarks(&v, x0: 0, x1: 892, y0: st.Hv + 190, y1: hv, count: extra, seed: 44, color: Color.white, alpha: 0.28)
            Kit.swells(&v, width: 892, top: st.Hv + 200, bottom: hv, rows: 4, crest: Art.color(0xE9DCC0), seed: 12)
        }
        Kit.reeds(&v, x: 850, baseY: hv + 10, count: 6, height: 78, seed: 14, color: 0x55744A)
        Kit.reeds(&v, x: 806, baseY: hv + 12, count: 4, height: 52, seed: 15, color: 0x4F6A44)
    }
}

// MARK: - scene-bank (unfolded): the path along the top of the bank

extension FishCampArt {
    static func bankScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 160)
        let light = peach()
        riverBackdrop(&context, st, light: light, ripples: 50 + Int(st.tall * 40), seed: 31)
        Kit.sun(&context, 34, st.H - 40 * st.far, 19 * st.far, light: light)
        Kit.glints(&context, x: 70, top: st.H, depth: st.depth, color: Art.color(0xFFF1DC), count: 36, seed: 28)
        Kit.designSpace(&context, st) { v in
            bank(&v, st, x0: 500, run: 0.45)
            bankPlants(&v, st)
            Kit.nearSpace(&v, st, anchorX: 705) { n in
                bankNick(&n, st)
            }
            bankNear(&v, st)
        }
        ArtStyle.finish(&context, size)
    }

    /// Tall grass, the narrow dirt path, low willow and fireweed just turning pink.
    static func bankPlants(_ v: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        let hv: CGFloat = st.hv
        let far = CGRect(x: 500, y: Hv + 4, width: 392, height: 54)
        Kit.grass(&v, in: far, count: 70, seed: 51, color: Art.color(0x6F8C54, 0.75), height: 9)
        let near = CGRect(x: 440, y: Hv + 60, width: 452, height: max(20, hv - Hv - 60))
        let more: Int = 60 + Int(st.tall * 100)
        Kit.grass(&v, in: near, count: more, seed: 52, color: Art.color(0x587848, 0.8), height: 15)
        Kit.grass(&v, in: near, count: more / 2, seed: 53, color: Art.color(0xC9D898, 0.75), height: 12)
        let dirt: Kit.Stops = [(Art.color(0xC2A988, 0.95), 0), (Art.color(0xA08A68), 1)]
        Kit.ribbon(&v, nearX: 690, nearY: hv + 12, nearWidth: 132, farX: 872, farY: Hv - 2, farWidth: 8, stops: dirt)
        Kit.bush(&v, x: 640, baseY: Hv, width: 64, palette: willowGreens(), seed: 6)
        Kit.bush(&v, x: 560, baseY: Hv + 16, width: 112, palette: willowGreens(), seed: 4)
        Kit.bush(&v, x: 852, baseY: Hv + 22, width: 120, palette: willowGreens(), seed: 9)
        let stems: [(CGFloat, CGFloat, CGFloat)] = [
            (536, 66, 66), (560, 82, 84), (588, 74, 62), (612, 100, 78), (818, 70, 74), (846, 92, 92), (872, 78, 70), (880, 116, 98),
        ]
        var seed: UInt32 = 60
        for stem in stems {
            fireweed(&v, x: stem.0, baseY: Hv + stem.1, height: stem.2, seed: seed)
            seed += 1
        }
        if st.tall > 0.2 {
            Kit.grassTuft(&v, x: 520, baseY: Hv + 240, height: 60, color: 0x6F8C54, seed: 21)
            fireweed(&v, x: 556, baseY: Hv + 256, height: 110, seed: 71)
            fireweed(&v, x: 584, baseY: Hv + 268, height: 86, seed: 72)
            Kit.grassTuft(&v, x: 846, baseY: Hv + 280, height: 70, color: 0x6F8C54, seed: 22)
        }
    }

    /// Nick walking away downriver with the green bundle, and his mosquitoes.
    static func bankNick(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let ground: CGFloat = st.Hv + 108
        Kit.shadow(&n, 708, ground, width: 76)
        Art.group(&n, x: 705, y: ground, scale: 1.2, scaleX: -1) { g in
            nick(&g, act: .walkHug, look: CGPoint(x: -0.5, y: 0.4), mouth: .flat, mirrored: true)
        }
        mosquitoes(&n, cx: 716, cy: ground - 168, scale: 1.2)
        Kit.grassTuft(&n, x: 652, baseY: ground + 12, height: 34, color: 0x6F8C54, seed: 31)
        Kit.grassTuft(&n, x: 770, baseY: ground + 8, height: 30, color: 0x7F9A5E, seed: 32)
    }

    /// The near plane: dark grass and tall fireweed at the bottom corners.
    static func bankNear(_ v: inout GraphicsContext, _ st: Kit.Stage) {
        let hv: CGFloat = st.hv
        Kit.grassTuft(&v, x: 400, baseY: hv + 12, height: 56, color: 0x4F6A44, seed: 41)
        Kit.grassTuft(&v, x: 868, baseY: hv + 12, height: 86, color: 0x4A6440, seed: 42)
        fireweed(&v, x: 826, baseY: hv + 8, height: 124, seed: 81)
        fireweed(&v, x: 886, baseY: hv + 4, height: 150, seed: 82)
        Kit.reeds(&v, x: 60, baseY: hv + 8, count: 4, height: 50, seed: 43, color: 0x55744A)
    }
}

// MARK: - scene-porch (unfolded): Lena's small grey cabin

extension FishCampArt {
    static func porchScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 150)
        let light = peach()
        riverBackdrop(&context, st, light: light, ripples: 46 + Int(st.tall * 40), seed: 41)
        Art.glow(&context, 20, st.H - 20 * st.far, 230 * st.far, light.glow, alpha: 0.36)
        Kit.glints(&context, x: 150, top: st.H, depth: st.depth, color: Art.color(0xFFF1DC), count: 32, seed: 38)
        Kit.designSpace(&context, st) { v in
            bank(&v, st, x0: 620, run: 0.8)
            porchGround(&v, st)
            Kit.nearSpace(&v, st, anchorX: 720) { n in
                porchCabin(&n, st)
                porchLena(&n, st)
            }
            porchNear(&v, st)
        }
        ArtStyle.finish(&context, size)
    }

    static func porchGround(_ v: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        let hv: CGFloat = st.hv
        let far = CGRect(x: 612, y: Hv + 2, width: 280, height: 40)
        Kit.grass(&v, in: far, count: 40, seed: 91, color: Art.color(0x6F8C54, 0.7), height: 7)
        let near = CGRect(x: 500, y: Hv + 96, width: 392, height: max(20, hv - Hv - 96))
        let more: Int = 34 + Int(st.tall * 90)
        Kit.grass(&v, in: near, count: more, seed: 92, color: Art.color(0x5F7F4A, 0.75), height: 11)
        Kit.grass(&v, in: near, count: more / 2, seed: 93, color: Art.color(0xC4D494, 0.7), height: 9)
        let dirt: Kit.Stops = [(Art.color(0xB8A27C, 0.9), 0), (Art.color(0x9A8664, 0.95), 1)]
        Kit.ribbon(&v, nearX: 640, nearY: hv + 12, nearWidth: 90, farX: 716, farY: Hv + 84, farWidth: 30, stops: dirt)
        Kit.bush(&v, x: 872, baseY: Hv + 20, width: 90, palette: willowGreens(), seed: 14)
        if st.tall > 0.2 {
            Kit.grassTuft(&v, x: 540, baseY: Hv + 250, height: 50, color: 0x6F8C54, seed: 95)
            fireweed(&v, x: 800, baseY: Hv + 260, height: 96, seed: 96)
            fireweed(&v, x: 824, baseY: Hv + 272, height: 74, seed: 97)
        }
    }

    /// The weathered cabin with its stovepipe, the porch step, one short rack, the table by the water.
    static func porchCabin(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        Art.group(&n, x: 590, y: Hv + 44) { g in
            rack(&g, width: 84, height: 56, rows: 1, tarp: false, seed: 9)
        }
        Art.group(&n, x: 770, y: Hv + 34) { g in
            cabin(&g, width: 180, height: 100, rise: 24, wall: greyBoard, roof: 0x7C776E, boards: true, door: true, pipe: true)
        }
        smoke(&n, x: 813, y: Hv - 112, scale: 0.8)
        // The porch: a plank deck and one lower step.
        let board = Art.color(0xB3AC9C)
        let riser = Art.color(0x7E7A70)
        Art.fill(&n, Art.rect(688, Hv + 42, 124, 10), riser)
        Kit.solid(&n, Art.rect(684, Hv + 34, 132, 8, radius: 1.5), board, light: 0.24, shade: 0.16)
        Art.fill(&n, Art.rect(700, Hv + 58, 96, 12), riser)
        Kit.solid(&n, Art.rect(696, Hv + 51, 104, 8, radius: 1.5), board, light: 0.24, shade: 0.16)
        Kit.shadow(&n, 750, Hv + 70, width: 130, alpha: 0.2)
        Art.group(&n, x: 792, y: Hv + 34) { g in
            kettle(&g)
        }
        Art.group(&n, x: 540, y: Hv + 86) { g in
            cuttingTable(&g, width: 72, height: 44)
        }
        Art.group(&n, x: 552, y: Hv + 27, scale: 0.55) { g in
            uluaq(&g)
        }
        Art.group(&n, x: 500, y: Hv + 92) { g in
            tote(&g)
        }
    }

    /// Old Lena on the step with her mug of tea, watching the river.
    static func porchLena(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let ground: CGFloat = st.Hv + 70
        Kit.shadow(&n, 728, ground, width: 60, alpha: 0.2)
        Art.group(&n, x: 735, y: ground) { g in
            lena(&g, look: CGPoint(x: -0.7, y: 0.1), mouth: .smile)
        }
    }

    static func porchNear(_ v: inout GraphicsContext, _ st: Kit.Stage) {
        let hv: CGFloat = st.hv
        Kit.reeds(&v, x: 56, baseY: hv + 8, count: 5, height: 56, seed: 99, color: 0x55744A)
        Kit.grassTuft(&v, x: 866, baseY: hv + 12, height: 78, color: 0x4A6440, seed: 98)
        Kit.grassTuft(&v, x: 812, baseY: hv + 14, height: 50, color: 0x4F6A44, seed: 94)
        fireweed(&v, x: 886, baseY: hv + 6, height: 112, seed: 90)
    }
}
