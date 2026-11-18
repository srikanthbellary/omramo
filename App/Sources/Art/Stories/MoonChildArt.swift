import SwiftUI
import OmramoCore

/// Concept art for "The Bamboo-Cutter and the Moon-Child", drawn in code (round 5; composed
/// from the shared kit). A dark story: every picture is night, with one glowing source.
enum MoonChildArt {
    /// Draws the picture called `name`. Returns false for a name this story does not have.
    static func paint(_ name: String, role: ArtRole, in context: inout GraphicsContext, size: CGSize) -> Bool {
        guard size.width > 0, size.height > 0 else { return false }
        switch (name, role) {
        case ("scene-grove", .sceneUnfolded): groveScene(&context, size)
        case ("scene-grove", .sceneFolded): groveFolded(&context, size)
        case ("scene-house", .sceneUnfolded): houseScene(&context, size)
        case ("scene-house", .sceneFolded): houseFolded(&context, size)
        case ("scene-moon", .sceneUnfolded): moonScene(&context, size)
        case ("scene-moon", .sceneFolded): moonFolded(&context, size)
        case ("scene-fuji", .sceneUnfolded): fujiScene(&context, size)
        case ("scene-fuji", .sceneFolded): fujiFolded(&context, size)
        case ("see-bamboo-work", .picture): bambooWorkPicture(&context, size)
        case ("see-old-capital", .picture): oldCapitalPicture(&context, size)
        case ("see-court-poem", .picture): courtPoemPicture(&context, size)
        case ("see-moon-viewing", .picture): moonViewingPicture(&context, size)
        case ("char-kaguya", .portrait): kaguyaPortrait(&context, size)
        case ("char-bamboo-cutter", .portrait): cutterPortrait(&context, size)
        case ("face-kaguya", .face): kaguyaFace(&context, size)
        case ("face-bamboo-cutter", .face): cutterFace(&context, size)
        case ("face-emperor", .face): emperorFace(&context, size)
        case ("cover", .cover): coverPicture(&context, size)
        default:
            return false
        }
        return true
    }
}

// MARK: - Scene 1: the grove at night (unfolded)

extension MoonChildArt {
    /// Night in the grove: the Bamboo-Cutter bends with his knife toward the one stem that
    /// glows gold from inside. The leading pane is calm indigo sky above low dark leaves.
    static func groveScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 140)
        let light = night()
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.stars(&context, width: size.width, maxY: st.H - 90 * st.far, count: 46, seed: 11)
        // Far: low dark tops right across, and thin far canes behind the trailing pane.
        let tops = Kit.ridge(width: size.width, y: st.H - 44 * st.far, amp: 24 * st.far, seed: 9, bottom: st.H + 8)
        Art.fill(&context, tops, Art.color(0x0E2230))
        farSpace(&context, st) { f in
            caneRank(&f, x0: 430, x1: 900, baseY: st.H + 6, top: st.H - 1400, count: 16, half: 3.4, tone: caneFarHex, seed: 31)
            var random = ArtRandom(17)
            for i in 0..<10 {
                let x: CGFloat = 450 + 440 * Kit.rnd(&random)
                let y: CGFloat = st.H - 90 - 230 * Kit.rnd(&random)
                leafSpray(&f, x: x, y: y, reach: 46, count: 12, color: Art.color(0x143036, 0.9), seed: 60 &+ UInt32(i))
            }
        }
        ArtStyle.atmosphere(&context, width: size.width, top: st.H - 220 * st.far, bottom: st.H + 8, color: light.haze, alpha: 0.22)
        let earth: Kit.Stops = Kit.stops(0x12302A, 0x0A1A1C)
        Kit.ground(&context, width: size.width, top: st.H, bottom: size.height, stops: earth, tooth: Art.color(0x9FC2A6))
        floorLitter(&context, size, top: st.H, color: Art.color(0x2A5A44), seed: 41)
        // Low dark leaves along the leading side.
        let lowX: [CGFloat] = [36, 128, 214, 300, 392]
        for (i, x) in lowX.enumerated() {
            let reach: CGFloat = (48 + CGFloat(i % 2) * 14) * st.far
            leafSpray(&context, x: x, y: st.H + 4, reach: reach, count: 14, color: Art.color(0x0C1F26), seed: 80 &+ UInt32(i), droop: 0.12)
        }
        Kit.designSpace(&context, st) { v in
            groveMiddle(&v, st)
            Kit.nearSpace(&v, st, anchorX: 660) { n in
                groveSubject(&n, st)
            }
            groveFrame(&v, st)
        }
        leafSpray(&context, x: 8, y: size.height - 4, reach: 120, count: 18, color: Art.color(0x08161A), seed: 93, droop: 0.05)
        ArtStyle.finish(&context, size, wash: 0.04, vignette: 0.14)
    }

    /// The middle rank of canes and their leaves, on the trailing half.
    static func groveMiddle(_ v: inout GraphicsContext, _ st: Kit.Stage) {
        caneRank(&v, x0: 452, x1: 900, baseY: st.Hv + 14, top: -40, count: 9, half: 6.5, tone: caneMidHex, seed: 7)
        var random = ArtRandom(29)
        let span: CGFloat = max(60, st.Hv - 220)
        for i in 0..<9 {
            let x: CGFloat = 470 + 410 * Kit.rnd(&random)
            let y: CGFloat = 50 + span * Kit.rnd(&random)
            leafSpray(&v, x: x, y: y, reach: 72, count: 15, color: Art.color(0x12302E), seed: 120 &+ UInt32(i))
        }
        let topX: [CGFloat] = [480, 560, 650, 740, 830]
        for (i, x) in topX.enumerated() {
            leafSpray(&v, x: x, y: 14, reach: 92, count: 16, color: Art.color(0x0C2024), seed: 140 &+ UInt32(i), droop: 0.7)
        }
    }

    /// The near canes, the shining stem and the old man, standing on the horizon line.
    static func groveSubject(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let base: CGFloat = st.Hv
        cane(&n, x: 520, baseY: base + 44, top: -700, half: 10, tone: caneNearHex, lean: -14, glowSide: 1, glow: 0.3, seed: 3)
        cane(&n, x: 586, baseY: base + 34, top: -700, half: 8, tone: caneMidHex, lean: 8, glowSide: 1, glow: 0.42, seed: 4)
        cane(&n, x: 772, baseY: base + 38, top: -700, half: 11, tone: caneNearHex, lean: 16, glowSide: -1, glow: 0.34, seed: 6)
        cane(&n, x: 838, baseY: base + 58, top: -700, half: 12, tone: caneNearHex, lean: -6, glowSide: -1, glow: 0.2, seed: 8)
        // The pool of gold light on the ground.
        Art.group(&n, x: 646, y: base + 56, scale: 0.3, scaleX: 3.4) { p in
            Art.glow(&p, 0, 0, 170, ramp.glowColor, alpha: 0.34)
        }
        Art.group(&n, x: 640, y: base + 50) { s in
            shiningCane(&s, half: 13, height: base + 760, from: 54, to: 150)
        }
        // Two young shoots by the stem, and a bundle of cut lengths behind the old man.
        var shoot = Path()
        shoot.move(to: Kit.pt(598, base + 60))
        shoot.addQuadCurve(to: Kit.pt(606, base + 34), control: Kit.pt(598, base + 44))
        shoot.addQuadCurve(to: Kit.pt(616, base + 60), control: Kit.pt(615, base + 44))
        shoot.closeSubpath()
        shoot.move(to: Kit.pt(672, base + 70))
        shoot.addQuadCurve(to: Kit.pt(678, base + 52), control: Kit.pt(672, base + 58))
        shoot.addQuadCurve(to: Kit.pt(685, base + 70), control: Kit.pt(684, base + 58))
        shoot.closeSubpath()
        Kit.solid(&n, shoot, Art.color(0x4A3A2E), light: 0.3, shade: 0.2)
        var bundle = Path()
        bundle.move(to: Kit.pt(770, base + 72))
        bundle.addLine(to: Kit.pt(862, base + 66))
        bundle.move(to: Kit.pt(774, base + 80))
        bundle.addLine(to: Kit.pt(868, base + 76))
        bundle.move(to: Kit.pt(780, base + 64))
        bundle.addLine(to: Kit.pt(856, base + 58))
        Art.stroke(&n, bundle, Art.color(0x2A5A3A), width: 7)
        Art.stroke(&n, bundle, Art.color(0xC8E0A8, 0.18), width: 2)
        Art.stroke(&n, Art.line(812, base + 56, 816, base + 82), Art.color(0x8A6A3E), width: 2.4)
        // The Bamboo-Cutter, bending in with his knife.
        Kit.shadow(&n, 724, base + 62, width: 78, alpha: 0.34)
        Art.group(&n, x: 722, y: base + 62) { c in
            cutter(&c, pose: .bow, look: CGPoint(x: -0.7, y: 0.1), mouth: .oh)
        }
        Art.glow(&n, 676, base - 52, 60, ramp.glowColor, alpha: 0.2)
    }

    /// The near plane: a dark cane and hanging leaves at the trailing edge.
    static func groveFrame(_ v: inout GraphicsContext, _ st: Kit.Stage) {
        cane(&v, x: 886, baseY: st.hv + 20, top: -40, half: 16, tone: 0x0A1A1C, lean: -10, seed: 12)
        leafSpray(&v, x: 866, y: 22, reach: 130, count: 22, color: Art.color(0x08161A), seed: 95, droop: 0.8)
        leafSpray(&v, x: 880, y: st.hv - 10, reach: 110, count: 16, color: Art.color(0x08161A), seed: 96, droop: 0.05)
    }

    /// A dark clump of long grass standing on (x, y), for the near plane of the open scenes.
    static func nightGrass(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, height: CGFloat, seed: UInt32, plumes: Bool = false) {
        var random = ArtRandom(seed)
        var blades = Path()
        var heads = Path()
        for i in 0..<16 {
            let lean: CGFloat = (Kit.rnd(&random) - 0.5) * height * 1.1
            let tall: CGFloat = height * (0.55 + Kit.rnd(&random) * 0.45)
            let rootX: CGFloat = x + (Kit.rnd(&random) - 0.5) * height * 0.24
            let tipX: CGFloat = rootX + lean
            let tipY: CGFloat = y - tall
            blades.move(to: Kit.pt(rootX, y))
            blades.addQuadCurve(to: Kit.pt(tipX, tipY), control: Kit.pt(rootX + lean * 0.15, y - tall * 0.8))
            if plumes && i % 4 == 0 {
                leaf(&heads, tipX, tipY, tipX + lean * 0.22, tipY + tall * 0.2, tall * 0.045)
            }
        }
        Art.stroke(&context, blades, Art.color(0x0A1228), width: max(1.6, height * 0.022))
        Art.fill(&context, heads, Art.color(0x9FB2DE, 0.5))
    }
}

// MARK: - Scene 2: the house at deep dusk (unfolded)

extension MoonChildArt {
    /// Deep dusk: pale light pours from the open doors of the thatched house as if a moon
    /// were inside, and the lords' ox-carts wait at the fence. The leading pane is dark sky.
    static func houseScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 150)
        let light = dusk()
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.stars(&context, width: size.width, maxY: st.H - 150 * st.far, count: 30, seed: 21)
        let farTops = Kit.ridge(width: size.width, y: st.H - 52 * st.far, amp: 30 * st.far, seed: 14, bottom: st.H + 8)
        Art.fill(&context, farTops, light.far)
        farSpace(&context, st) { f in
            caneRank(&f, x0: 440, x1: 900, baseY: st.H + 6, top: st.H - 1400, count: 12, half: 3.6, tone: 0x0E1A2A, seed: 33)
            var random = ArtRandom(19)
            for i in 0..<8 {
                let x: CGFloat = 450 + 440 * Kit.rnd(&random)
                let y: CGFloat = st.H - 120 - 210 * Kit.rnd(&random)
                leafSpray(&f, x: x, y: y, reach: 50, count: 12, color: Art.color(0x101E2E, 0.9), seed: 160 &+ UInt32(i))
            }
        }
        ArtStyle.atmosphere(&context, width: size.width, top: st.H - 240 * st.far, bottom: st.H + 8, color: light.haze, alpha: 0.2)
        let nearTops = Kit.ridge(width: size.width, y: st.H - 20 * st.far, amp: 16 * st.far, seed: 15, bottom: st.H + 8)
        Art.fill(&context, nearTops, light.mid)
        let earth: Kit.Stops = Kit.stops(0x1A2440, 0x0E1730)
        Kit.ground(&context, width: size.width, top: st.H, bottom: size.height, stops: earth, tooth: Art.color(0xA8B8E0))
        floorLitter(&context, size, top: st.H + 20, color: Art.color(0x2A3A5E), seed: 43)
        Kit.designSpace(&context, st) { v in
            Kit.nearSpace(&v, st) { n in
                houseStead(&n, st)
                houseLane(&n, st)
            }
            cane(&v, x: 888, baseY: st.hv + 20, top: -40, half: 14, tone: 0x0A1220, lean: -8, seed: 13)
            leafSpray(&v, x: 868, y: 20, reach: 124, count: 20, color: Art.color(0x0A1220), seed: 97, droop: 0.8)
        }
        nightGrass(&context, x: 22, y: size.height + 6, height: 96, seed: 51)
        ArtStyle.finish(&context, size, wash: 0.04, vignette: 0.14)
    }

    /// The bamboo behind, the shining house, its fence and gate.
    static func houseStead(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let base: CGFloat = st.Hv
        caneRank(&n, x0: 476, x1: 904, baseY: base + 12, top: -700, count: 8, half: 6, tone: 0x13222E, seed: 9)
        var random = ArtRandom(37)
        for i in 0..<7 {
            let x: CGFloat = 480 + 400 * Kit.rnd(&random)
            let y: CGFloat = base - 240 - 150 * Kit.rnd(&random)
            leafSpray(&n, x: x, y: y, reach: 70, count: 14, color: Art.color(0x101C2A), seed: 170 &+ UInt32(i))
        }
        Art.group(&n, x: 690, y: base + 34) { h in
            thatchHouse(&h, glow: 1)
        }
        // Kaguya-hime, small and bright in the doorway: the light is hers.
        Art.group(&n, x: 698, y: base + 17, scale: 0.5) { k in
            Art.glow(&k, 0, -70, 120, Art.color(0xFFFBE4), alpha: 0.7)
            kaguya(&k, seated: true)
        }
        // The step stone under the porch.
        let stone = Art.svg("M-26,0 C-26,-9 -14,-12 0,-12 C14,-12 26,-9 26,0Z")
        Art.group(&n, x: 690, y: base + 42) { s in
            Kit.solid(&s, stone, Art.color(0x4A4A66), light: 0.3, shade: 0.2)
        }
        // The woven fence, with a gate gap before the door.
        let fenceY: CGFloat = base + 88
        wovenFence(&n, x0: -420, x1: 646, y: fenceY, height: 34, tone: 0x1A2236)
        wovenFence(&n, x0: 736, x1: 910, y: fenceY, height: 34, tone: 0x1A2236)
        let posts = Art.svg("M646,0 L646,-46 M736,0 L736,-46")
        Art.group(&n, x: 0, y: fenceY) { p in
            Art.stroke(&p, posts, Art.color(0x241E30), width: 6, cap: .butt)
            Art.stroke(&p, Art.svg("M648,-2 L648,-44 M738,-2 L738,-44"), ramp.glowColor.opacity(0.4), width: 1.6, cap: .butt)
        }
        Art.glow(&n, 690, fenceY - 10, 130, ramp.glowColor, alpha: 0.14)
    }

    /// The lane outside the fence: two ox-carriages and the five lords who would not go home.
    static func houseLane(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let base: CGFloat = st.Hv
        Art.group(&n, x: 640, y: base + 130, scale: 0.55) { c in
            oxCart(&c)
        }
        Art.group(&n, x: 858, y: base + 122, scale: 0.55) { c in
            oxCart(&c)
        }
        let lords: [(CGFloat, CGFloat, UInt32)] = [
            (478, 118, 0x2A2440), (500, 110, 0x24304A), (676, 112, 0x3A2448), (698, 120, 0x26283E), (718, 110, 0x2E2A52),
        ]
        for place in lords {
            let y: CGFloat = base + place.1
            Kit.shadow(&n, place.0, y, width: 26, alpha: 0.3)
            Art.group(&n, x: place.0, y: y, scale: 0.4) { g in
                lord(&g, cloth: place.2)
            }
        }
        // The light from the door finds their shoulders.
        Art.glow(&n, 696, base + 60, 110, ramp.glowColor, alpha: 0.12)
    }
}

// MARK: - Scene 3: the night of the full moon (unfolded)

extension MoonChildArt {
    /// A shining cloud of tall calm figures glides down from a huge moon toward the house,
    /// whose roof and wall are lined with archers. The leading pane is open deep-blue sky.
    static func moonScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 130)
        let light = moonNight()
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.stars(&context, width: size.width, maxY: st.H - 120 * st.far, count: 54, seed: 5)
        let moonX: CGFloat = 892 - 176 * st.fit
        let moonY: CGFloat = st.H * 0.36
        Kit.moon(&context, moonX, moonY, 96 * st.far, color: Art.color(0xFFF6DC))
        let farTops = Kit.ridge(width: size.width, y: st.H - 40 * st.far, amp: 26 * st.far, seed: 24, bottom: st.H + 8)
        Art.fill(&context, farTops, light.far)
        ArtStyle.atmosphere(&context, width: size.width, top: st.H - 90 * st.far, bottom: st.H + 8, color: light.haze, alpha: 0.2)
        let nearTops = Kit.ridge(width: size.width, y: st.H - 16 * st.far, amp: 14 * st.far, seed: 25, bottom: st.H + 8)
        Art.fill(&context, nearTops, light.mid)
        let earth: Kit.Stops = Kit.stops(0x131A33, 0x0A1026)
        Kit.ground(&context, width: size.width, top: st.H, bottom: size.height, stops: earth, tooth: Art.color(0xA8B8E0))
        floorLitter(&context, size, top: st.H + 20, color: Art.color(0x24305A), seed: 45)
        Kit.designSpace(&context, st) { v in
            let cloudY: CGFloat = max(150, st.Hv * 0.46)
            let trail = CGPoint(x: 120, y: st.Hv * 0.36 - cloudY)
            moonVisitors(&v, x: 596, y: cloudY, width: 230, trail: trail)
            Kit.nearSpace(&v, st) { n in
                moonHouse(&n, st)
            }
            cane(&v, x: 889, baseY: st.hv + 20, top: -40, half: 12, tone: 0x0A102A, lean: -6, seed: 14)
            leafSpray(&v, x: 884, y: st.hv - 150, reach: 90, count: 14, color: Art.color(0x0A102A), seed: 98, droop: 0.6)
        }
        nightGrass(&context, x: 20, y: size.height + 6, height: 90, seed: 52)
        ArtStyle.finish(&context, size, wash: 0.03, vignette: 0.14)
    }

    /// The bank of cloud at (x, y) with five of the Moon people on it, and the light it sheds.
    static func moonVisitors(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, width: CGFloat, trail: CGPoint) {
        let k: CGFloat = width / 230
        Art.group(&context, x: x, y: y) { c in
            let beam: Path = Art.polygon([Kit.pt(-90 * k, 10), Kit.pt(90 * k, 10), Kit.pt(200 * k, 430 * k), Kit.pt(-30 * k, 430 * k)])
            let shed: Kit.Stops = [(Art.color(0xFFF3C8, 0.14), 0), (Art.color(0xFFF3C8, 0), 1)]
            Art.fillLinear(&c, beam, shed, from: CGPoint(x: 0, y: 10), to: CGPoint(x: 80 * k, y: 430 * k))
            moonCloud(&c, width: width, trail: trail)
            let places: [(CGFloat, CGFloat, CGFloat)] = [(-82, 5, 0.48), (82, 6, 0.46), (-42, 2, 0.56), (42, 2, 0.54), (0, 1, 0.64)]
            for place in places {
                Art.group(&c, x: place.0 * k, y: place.1) { m in
                    moonPerson(&m, tall: place.2 * k)
                }
            }
            // The robe of feathers, held up by the one in the middle.
            let mantle = Art.svg("M-22,-66 C-14,-74 14,-74 22,-66 C26,-48 22,-30 16,-20 C6,-26 -6,-26 -16,-20 C-22,-30 -26,-48 -22,-66Z")
            Art.group(&c, x: 0, y: 1, scale: 0.64 * k) { r in
                Art.fill(&r, mantle, Art.color(0xFFFFFF, 0.9))
                let barbs = Art.svg("M-14,-62 q2,10 -1,22 M-5,-66 q2,12 0,26 M5,-66 q-2,12 0,26 M14,-62 q-2,10 1,22")
                Art.stroke(&r, barbs, Art.color(0xC9D6F2), width: 1.4)
            }
            // The cloud laps their feet.
            var lap = Path()
            lap.addEllipse(in: CGRect(x: -104 * k, y: 4, width: 96 * k, height: 15))
            lap.addEllipse(in: CGRect(x: -30 * k, y: 6, width: 90 * k, height: 15))
            lap.addEllipse(in: CGRect(x: 36 * k, y: 4, width: 70 * k, height: 14))
            Art.fill(&c, lap, Art.color(0xFFFCEC, 0.86))
        }
    }

    /// The house with its doors standing open, archers on the ridge and along the wall.
    static func moonHouse(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let base: CGFloat = st.Hv
        caneRank(&n, x0: 500, x1: 904, baseY: base + 12, top: base - 150, count: 7, half: 5, tone: 0x0F1634, seed: 10)
        Art.group(&n, x: 700, y: base + 36, scale: 0.9) { h in
            thatchHouse(&h, glow: 0.55)
        }
        let ridgeY: CGFloat = base + 36 - 204 * 0.9
        let roofMen: [(CGFloat, CGFloat)] = [(642, 0.5), (674, -0.3), (708, 0.7), (744, 0.4)]
        for man in roofMen {
            Art.group(&n, x: man.0, y: ridgeY, scale: 0.36) { a in
                archer(&a, slack: man.1)
            }
        }
        Art.glow(&n, 670, ridgeY - 30, 130, Art.color(0xFFF3C8), alpha: 0.12)
        let fenceY: CGFloat = base + 90
        wovenFence(&n, x0: -420, x1: 910, y: fenceY, height: 36, tone: 0x1A2240)
        let wallMen: [(CGFloat, CGFloat)] = [(300, 0.4), (384, -0.4), (482, 0.6), (530, 0.3), (580, -0.2), (624, 0.5)]
        for man in wallMen {
            Kit.shadow(&n, man.0, fenceY + 14, width: 28, alpha: 0.3)
            Art.group(&n, x: man.0, y: fenceY + 14, scale: 0.42) { a in
                archer(&a, slack: man.1)
            }
        }
    }
}

// MARK: - Scene 4: Mount Fuji before dawn (unfolded)

extension MoonChildArt {
    /// Deep blue before dawn: the great cone of Fuji, one thin thread of smoke rising toward
    /// a pale moon, and tiny figures with one torch on the lower slope.
    static func fujiScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 150)
        let light = beforeDawn()
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.stars(&context, width: size.width, maxY: st.H - 170 * st.far, count: 34, seed: 3)
        farSpace(&context, st) { f in
            let h0: CGFloat = st.H
            Kit.moon(&f, 600, h0 - 338, 19, color: Art.color(0xE9EEF8))
            fuji(&f, cx: 704, baseY: h0 + 8, width: 470, height: 272)
            smokeThread(&f, from: CGPoint(x: 705, y: h0 - 264), to: CGPoint(x: 630, y: h0 - 334))
            Art.blurred(&f, radius: 5, opacity: 0.26) { c in
                var bands = Path()
                bands.addPath(Art.rect(470, h0 - 98, 310, 14, radius: 7))
                bands.addPath(Art.rect(566, h0 - 74, 330, 12, radius: 6))
                bands.addPath(Art.rect(360, h0 - 56, 280, 10, radius: 5))
                Art.fill(&c, bands, Art.color(0x9FB2DE))
            }
        }
        ArtStyle.atmosphere(&context, width: size.width, top: st.H - 300 * st.far, bottom: st.H + 8, color: light.haze, alpha: 0.16)
        let farHills = Kit.ridge(width: size.width, y: st.H - 34 * st.far, amp: 28 * st.far, seed: 6, bottom: st.H + 8)
        Art.fill(&context, farHills, light.far)
        ArtStyle.atmosphere(&context, width: size.width, top: st.H - 70 * st.far, bottom: st.H + 8, color: light.haze, alpha: 0.14)
        let nearHills = Kit.ridge(width: size.width, y: st.H - 14 * st.far, amp: 20 * st.far, seed: 16, bottom: st.H + 8)
        Art.fill(&context, nearHills, light.mid)
        let earth: Kit.Stops = Kit.stops(0x16233F, 0x0C1630)
        Kit.ground(&context, width: size.width, top: st.H, bottom: size.height, stops: earth, tooth: Art.color(0xA8B8E0))
        floorLitter(&context, size, top: st.H + 20, color: Art.color(0x2A3A66), seed: 47)
        Kit.designSpace(&context, st) { v in
            Kit.nearSpace(&v, st) { n in
                fujiClimbers(&n, st)
            }
            nightGrass(&v, x: 862, y: st.hv + 8, height: 150, seed: 53, plumes: true)
            nightGrass(&v, x: 806, y: st.hv + 10, height: 84, seed: 54)
        }
        nightGrass(&context, x: 24, y: size.height + 6, height: 92, seed: 55, plumes: true)
        ArtStyle.finish(&context, size, wash: 0.03, vignette: 0.14)
    }

    /// The near slope, and the Emperor's men climbing it with the letter, the jar and a torch.
    static func fujiClimbers(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let base: CGFloat = st.Hv
        let slope: Kit.Stops = Kit.stops(0x1C2C52, 0x0E1832)
        Kit.mound(&n, x0: 452, x1: 1000, baseY: base + 70, height: 54, bottom: st.hv + 60, stops: slope, crest: 0.6)
        var rocks = Path()
        rocks.addPath(Art.svg("M0,0 C0,-12 10,-18 20,-16 C30,-14 36,-8 36,0Z").applying(CGAffineTransform(translationX: 724, y: base + 34)))
        rocks.addPath(Art.svg("M0,0 C0,-8 7,-12 14,-10 C20,-9 24,-5 24,0Z").applying(CGAffineTransform(translationX: 506, y: base + 66)))
        rocks.addPath(Art.svg("M0,0 C0,-10 8,-14 16,-13 C24,-12 28,-6 28,0Z").applying(CGAffineTransform(translationX: 792, y: base + 52)))
        Kit.solid(&n, rocks, Art.color(0x22325A), light: 0.2, shade: 0.24)
        // The pool of torchlight on the slope.
        Art.group(&n, x: 650, y: base + 26, scale: 0.3, scaleX: 3.2) { p in
            Art.glow(&p, 0, 0, 90, Art.color(0xFFC65A), alpha: 0.3)
        }
        let men: [(CGFloat, CGFloat, UInt32)] = [(552, 42, 0x2A2E52), (584, 35, 0x33284A), (616, 29, 0x24304A), (650, 24, 0x3A2448)]
        var p = emperorLook()
        let grip = Kit.hand(p, pose: .walk)
        for (i, man) in men.enumerated() {
            p.cloth = man.2
            p.trim = Kit.personToneHex(man.2, 1.4)
            let who = p
            let y: CGFloat = base + man.1
            Kit.shadow(&n, man.0, y, width: 20, alpha: 0.3)
            Art.group(&n, x: man.0, y: y, scale: 0.28, scaleX: -1) { g in
                Kit.person(&g, who, pose: .walk, mouth: .flat, mirrored: true)
                Art.group(&g, x: -2, y: -138) { c in
                    courtCap(&c)
                }
                if i == 3 {
                    Art.stroke(&g, Art.line(grip.x, grip.y + 6, grip.x - 6, grip.y - 30), Art.color(0x6A4A2E), width: 4)
                    Art.group(&g, x: grip.x - 6, y: grip.y - 30, scale: 1.8) { t in
                        flame(&t)
                    }
                } else if i == 2 {
                    let jar = Art.svg("M-7,0 C-10,-6 -9,-14 -4,-16 L4,-16 C9,-14 10,-6 7,0Z")
                    Art.group(&g, x: grip.x, y: grip.y) { j in
                        Kit.solid(&j, jar, Art.color(0xD8DEEE), light: 0.3, shade: 0.2)
                        Art.fill(&j, Art.rect(-5, -19, 10, 4, radius: 1.5), Art.color(0xB8C0D8))
                    }
                }
            }
        }
    }
}
