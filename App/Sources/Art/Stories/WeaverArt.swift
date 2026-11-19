import SwiftUI
import OmramoCore

/// Concept art for "The Herd Boy and the Weaving Maiden", drawn in code (round 5; composed from the shared kit).
///
/// A DARK story: all four scenes are night or deep dusk, with the leading pane kept deep and
/// quiet for the cream words. The warm note everywhere is the rose-gold of Zhinü's silk.
enum WeaverArt {
    /// Draws the picture called `name`. Returns false for a name this story does not have.
    static func paint(_ name: String, role: ArtRole, in context: inout GraphicsContext, size: CGSize) -> Bool {
        guard size.width > 0, size.height > 0 else { return false }
        switch (name, role) {
        case ("scene-loom", .sceneUnfolded): loomScene(&context, size)
        case ("scene-loom", .sceneFolded): loomFolded(&context, size)
        case ("scene-meadow", .sceneUnfolded): meadowScene(&context, size)
        case ("scene-meadow", .sceneFolded): meadowFolded(&context, size)
        case ("scene-river", .sceneUnfolded): riverScene(&context, size)
        case ("scene-river", .sceneFolded): riverFolded(&context, size)
        case ("scene-bridge", .sceneUnfolded): bridgeScene(&context, size)
        case ("scene-bridge", .sceneFolded): bridgeFolded(&context, size)
        case ("see-silk", .picture): silkPicture(&context, size)
        case ("see-silver-river", .picture): silverRiverPicture(&context, size)
        case ("see-qixi", .picture): qixiPicture(&context, size)
        case ("see-two-stars", .picture): twoStarsPicture(&context, size)
        case ("char-zhinu", .portrait): zhinuPortrait(&context, size)
        case ("char-niulang", .portrait): niulangPortrait(&context, size)
        case ("face-zhinu", .face): zhinuChip(&context, size)
        case ("face-niulang", .face): niulangChip(&context, size)
        case ("face-ox", .face): oxChip(&context, size)
        case ("cover", .cover): coverPicture(&context, size)
        default:
            return false
        }
        return true
    }

    // MARK: Shared by the sky scenes

    /// The floor of the sky country: dark cloud from the horizon to the foot of the picture.
    static func cloudGround(_ context: inout GraphicsContext, _ st: Kit.Stage, top: UInt32, bottom: UInt32) {
        let floor: Kit.Stops = [(Art.color(top), 0), (Kit.personTone(top, 0.72), 0.55), (Art.color(bottom), 1)]
        Kit.ground(&context, width: st.w, top: st.H, bottom: st.h, stops: floor, seed: 21, tooth: Art.color(silver))
    }

    /// Cloud banks with scroll edges over the cloud floor: two more in the deep ground of a
    /// tall window, and a dark near bank in each bottom corner. In the picture's own units.
    static func cloudFloor(_ context: inout GraphicsContext, _ st: Kit.Stage, seed: UInt32) {
        let h: CGFloat = st.h
        if st.depth > 190 {
            let y1: CGFloat = st.H + st.depth * 0.42
            cloudBank(&context, x: 250, y: y1, width: 420, height: 30, color: 0x211D52, edge: silver, seed: seed, bottom: y1 + 70)
            let y2: CGFloat = st.H + st.depth * 0.68
            cloudBank(&context, x: 660, y: y2, width: 480, height: 34, color: 0x1A1746, edge: silver, seed: seed &+ 3, bottom: h)
        }
        cloudBank(&context, x: 70, y: h - 28, width: 320, height: 22, color: 0x121034, edge: silver, seed: seed &+ 5, bottom: h + 12)
        cloudBank(&context, x: 830, y: h - 38, width: 300, height: 26, color: 0x0F0D2E, edge: silver, seed: seed &+ 7, bottom: h + 12)
    }

    /// The plain gateway of the sky country, far off: pale posts under a tiled roof. Origin at
    /// the middle of its foot; about 70 wide and 62 tall.
    static func skyGate(_ context: inout GraphicsContext) {
        let stone: Color = Art.color(0x8A82B4)
        Art.fill(&context, Art.rect(-24, -44, 7, 44), stone)
        Art.fill(&context, Art.rect(17, -44, 7, 44), stone)
        Art.fill(&context, Art.rect(-28, -36, 56, 5), Art.color(0x7A72A6))
        let roof: Path = Art.svg("M-38,-44 C-26,-48 -14,-56 0,-62 C14,-56 26,-48 38,-44 C30,-42 -30,-42 -38,-44Z")
        Kit.solid(&context, roof, Art.color(0x5A4E8C), light: 0.24, shade: 0.24)
        Art.stroke(&context, Art.svg("M-30,-46 C-12,-50 12,-50 30,-46"), Art.color(0x3E3470), width: 1.2)
    }

    // MARK: scene-loom

    /// scene-loom: the sky country at deep dusk. Zhinü sits at her tall loom on dark cloud on
    /// the trailing pane, and the cloud-silk trails away from it, glowing; the leading pane is
    /// calm dark violet sky with a few early stars and the silk as one thin low glow.
    static func loomScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 150)
        let w: CGFloat = size.width
        let light = dusk()
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.stars(&context, width: w, maxY: st.H * 0.62, count: 44, seed: 3, color: Art.color(0xE8E4FF))

        // Far: low banks of dark cloud and the gateway, small and far off.
        let farBank: Path = Kit.ridge(width: w, y: st.H - 30 * st.far, amp: 16 * st.far, seed: 7, bottom: st.H + 8, step: 12)
        Art.fill(&context, farBank, light.far)
        Art.group(&context, x: 506, y: st.H - 24 * st.far, scale: 0.5 * st.far) { g in
            skyGate(&g)
        }
        ArtStyle.atmosphere(&context, width: w, top: st.H - 90 * st.far, bottom: st.H + 8, color: light.haze, alpha: 0.32)
        let midBank: Path = Kit.ridge(width: w, y: st.H - 9 * st.far, amp: 12 * st.far, seed: 12, bottom: st.H + 8)
        Art.fill(&context, midBank, light.mid)

        // The silk reaches the leading pane only as a thin low glow along the horizon.
        let joinX: CGFloat = 892 * (1 - st.fit) + 480 * st.fit
        let lowY: CGFloat = st.H - 7 * st.far
        var low = Path()
        low.move(to: CGPoint(x: -10, y: lowY + 5))
        low.addQuadCurve(to: CGPoint(x: joinX, y: lowY - 2), control: CGPoint(x: joinX * 0.5, y: lowY - 9))
        silkRibbon(&context, low, width: 2.6 * st.far, glow: 0.9)

        cloudGround(&context, st, top: 0x2A2156, bottom: 0x0F0E30)
        cloudFloor(&context, st, seed: 40)

        let ground: CGFloat = st.Hv + 70
        Kit.designSpace(&context, st) { v in
            Kit.nearSpace(&v, st, anchorX: 700) { n in
                loomGroup(&n, groundY: ground)
            }
        }
        ArtStyle.finish(&context, size, wash: 0.05, vignette: 0.12)
    }

    /// The loom, Zhinü at it and the silk leaving it, in design units; the loom's weaver-side
    /// foot is at (742, `y`).
    static func loomGroup(_ context: inout GraphicsContext, groundY y: CGFloat) {
        let lx: CGFloat = 742
        cloudBank(&context, x: 712, y: y - 6, width: 430, height: 30, color: 0x2E2664, edge: silver, seed: 5, bottom: y + 64)
        // The silk that runs back along the horizon toward the leading pane.
        var back = Path()
        back.move(to: CGPoint(x: lx - 96, y: y - 34))
        back.addCurve(to: CGPoint(x: 470, y: y - 77), control1: CGPoint(x: lx - 170, y: y - 30), control2: CGPoint(x: 560, y: y - 84))
        silkRibbon(&context, back, width: 5, glow: 0.9)
        // The finished cloth leaves the cloth beam in two long soft bands, rose and gold.
        var away = Path()
        away.move(to: CGPoint(x: lx + 12, y: y - 80))
        away.addCurve(to: CGPoint(x: lx + 92, y: y - 20), control1: CGPoint(x: lx + 52, y: y - 72), control2: CGPoint(x: lx + 60, y: y - 30))
        away.addCurve(to: CGPoint(x: lx + 200, y: y - 56), control1: CGPoint(x: lx + 132, y: y - 8), control2: CGPoint(x: lx + 156, y: y - 62))
        var high = Path()
        high.move(to: CGPoint(x: lx + 20, y: y - 88))
        high.addCurve(to: CGPoint(x: lx + 196, y: y - 150), control1: CGPoint(x: lx + 80, y: y - 96), control2: CGPoint(x: lx + 120, y: y - 164))
        Art.glow(&context, lx + 20, y - 90, 170, Art.color(rose), alpha: 0.16)
        silkRibbon(&context, high, width: 9, glow: 0.8)
        silkRibbon(&context, away, width: 16, glow: 1)
        Art.group(&context, x: lx, y: y) { l in
            loom(&l)
        }
        // Her seat: a small puff of cloud.
        cloudBank(&context, x: lx + 36, y: y - 28, width: 66, height: 16, color: 0x3A3074, edge: silver, seed: 9, bottom: y)
        Kit.shadow(&context, lx + 30, y + 3, width: 74, alpha: 0.3)
        let spec = zhinuLook()
        let hand: CGPoint = Kit.hand(spec, pose: .sit)
        Art.group(&context, x: lx + 30, y: y) { z in
            zhinu(&z, pose: .sit, look: CGPoint(x: -0.6, y: 0.5), mouth: .smile)
            Art.group(&z, x: hand.x - 5, y: hand.y - 3, rotate: -0.4) { s in
                shuttle(&s)
            }
        }
        // The warm light of the cloth on her face and hands.
        Art.glow(&context, lx + 14, y - 96, 44, Art.color(gold), alpha: 0.16)
    }
}

// MARK: - scene-meadow

extension WeaverArt {
    /// scene-meadow: the river meadow at night. Niulang stands with his hand on the Old Ox's
    /// neck near the straw-roofed hut and the row of mulberry trees, on the trailing pane; the
    /// leading pane is calm starry sky over a low line of dark hills, the slow river a paler
    /// band under it.
    static func meadowScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 160)
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let light = night()
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.stars(&context, width: w, maxY: st.H * 0.8, count: 64, seed: 11)
        let maxY: CGFloat = st.H * 0.86
        Art.group(&context, x: 460) { s in
            Kit.stars(&s, width: 432, maxY: maxY, count: 120, seed: 12)
        }
        Kit.ranges(&context, width: w, horizon: st.H, scale: st.far, light: light, seed: 6)
        Kit.farTrees(&context, x0: 16, x1: 430, baseY: st.H + 2, height: 15 * st.far, count: 9, color: light.mid, seed: 3)

        let land: Kit.Stops = [(Art.color(0x1B3442), 0), (Art.color(0x163030), 0.5), (Art.color(0x0D2024), 1)]
        Kit.ground(&context, width: w, top: st.H, bottom: h, stops: land, seed: 31, tooth: Art.color(0x8FC7A8))
        meadowRiver(&context, st)
        meadowFill(&context, st)

        Kit.designSpace(&context, st) { v in
            Kit.nearSpace(&v, st, anchorX: 700) { n in
                meadowGroup(&n, horizon: st.Hv)
            }
        }
        // Near plane: dark reeds cropped by the bottom corners.
        let reach: CGFloat = 84 + 70 * st.tall
        Kit.reeds(&context, x: 26, baseY: h + 8, count: 9, height: reach, seed: 21, color: 0x0E2A2C)
        Kit.reeds(&context, x: 872, baseY: h + 8, count: 8, height: reach * 0.9, seed: 27, color: 0x0E2A2C)
        ArtStyle.finish(&context, size, wash: 0.05, vignette: 0.12)
    }

    /// The slow river just under the hills: a paler band that catches the starlight, with
    /// reeds along its near bank. In the picture's own units.
    static func meadowRiver(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let w: CGFloat = st.w
        let top: CGFloat = st.H + 9 * st.far
        let deep: CGFloat = (24 + 22 * st.tall) * st.far
        let water: Kit.Stops = [(Art.color(0x4A5E9A), 0), (Art.color(0x2E4480), 0.5), (Art.color(0x1F3264), 1)]
        Art.fillLinear(&context, Art.rect(0, top, w, deep), water, from: CGPoint(x: 0, y: top), to: CGPoint(x: 0, y: top + deep))
        Kit.rippleMarks(&context, x0: 0, x1: w, y0: top + 2, y1: top + deep - 2, count: 46, seed: 5, color: Art.color(silver), alpha: 0.4)
        let bankY: CGFloat = top + deep
        let bank: Path = Kit.ridge(width: w, y: bankY + 2, amp: 3 * st.far, seed: 9, bottom: bankY + 14)
        Art.fill(&context, bank, Art.color(0x17323A))
        let tall: CGFloat = 30 * st.far
        let places: [(CGFloat, CGFloat, Int)] = [(64, 1, 6), (212, 0.8, 5), (352, 1.1, 7), (486, 0.9, 5), (566, 0.7, 4)]
        for place in places {
            let seed: UInt32 = UInt32(place.2) &+ 40
            Kit.reeds(&context, x: place.0, baseY: bankY + 5, count: place.2, height: tall * place.1, seed: seed, color: 0x2A5A54)
        }
    }

    /// The ground of the meadow: tufts everywhere, and on a tall window a path that winds
    /// from the hut toward the viewer, stones and weeds. In the picture's own units.
    static func meadowFill(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let w: CGFloat = st.w
        let h: CGFloat = st.h
        let top: CGFloat = st.H + (40 + 24 * st.tall) * st.far
        if st.tall > 0.25 {
            let y0: CGFloat = st.H + st.depth * 0.5
            var path = Path()
            path.move(to: CGPoint(x: 742, y: y0))
            path.addCurve(to: CGPoint(x: 520, y: h), control1: CGPoint(x: 700, y: y0 + (h - y0) * 0.4), control2: CGPoint(x: 560, y: y0 + (h - y0) * 0.5))
            path.addLine(to: CGPoint(x: 700, y: h))
            path.addCurve(to: CGPoint(x: 792, y: y0), control1: CGPoint(x: 700, y: y0 + (h - y0) * 0.5), control2: CGPoint(x: 800, y: y0 + (h - y0) * 0.36))
            path.closeSubpath()
            Art.fill(&context, path, Art.color(0x34485A, 0.55))
            Kit.rock(&context, cx: 470, baseY: h - 120, width: 46, height: 22, color: 0x3A4660, seed: 3)
            Kit.rock(&context, cx: 760, baseY: h - 70, width: 34, height: 16, color: 0x3A4660, seed: 8)
        }
        let rect = CGRect(x: 0, y: top, width: w, height: max(1, h - top))
        let count: Int = 80 + Int(st.tall * 140)
        Kit.grass(&context, in: rect, count: count, seed: 5, color: Art.color(0x2A5650), height: 9)
        Kit.grass(&context, in: rect, count: count / 2, seed: 14, color: Art.color(0x4E8A7A), height: 7)
        Kit.flecks(&context, in: rect, count: 10 + Int(st.tall * 14), seed: 6, color: Art.color(0xC9D3F2, 0.7), radius: 0.8...1.6)
    }

    /// The hut, the mulberry row, the Old Ox and Niulang, in design units.
    static func meadowGroup(_ context: inout GraphicsContext, horizon Hv: CGFloat) {
        let feet: CGFloat = Hv + 96
        mulberry(&context, x: 546, baseY: Hv + 44, height: 118, seed: 4)
        mulberry(&context, x: 626, baseY: Hv + 40, height: 132, seed: 8)
        mulberry(&context, x: 706, baseY: Hv + 43, height: 122, seed: 13)
        Kit.shadow(&context, 814, Hv + 59, width: 160, alpha: 0.3)
        Art.group(&context, x: 812, y: Hv + 56, scale: 1.06) { g in
            hut(&g)
        }
        // A hoe leaning on the wall.
        Kit.propShaft(&context, 862, Hv + 56, 846, Hv + 2, wood: 0x6A5440, width: 3)
        Art.fill(&context, Art.svg("M0,0 L10,3 L8,12 L-3,8Z").applying(CGAffineTransform(translationX: 842, y: Hv - 2)), Art.color(0x7A86A8))
        // The ox, and Niulang with his hand on the old beast's neck.
        Kit.shadow(&context, 744, feet + 2, width: 176, alpha: 0.34)
        Art.group(&context, x: 742, y: feet) { o in
            ox(&o)
        }
        Kit.shadow(&context, 696, feet + 8, width: 60, alpha: 0.32)
        Art.group(&context, x: 694, y: feet + 6) { p in
            niulang(&p, pose: .stand, look: CGPoint(x: -0.5, y: 0.1), mouth: .smile)
        }
        // Starlight on the two of them.
        Art.glow(&context, 676, feet - 100, 120, Art.color(silver), alpha: 0.07)
    }
}

// MARK: - scene-river

extension WeaverArt {
    /// The middle of the Silver River at `x` when the horizon is `H` (scene-river): it sweeps
    /// from the upper right down to the horizon at the leading edge.
    static func riverLine(_ x: CGFloat, _ H: CGFloat) -> CGFloat {
        let t: CGFloat = (930 - x) / 970
        return H * (0.42 + 0.56 * t)
    }

    /// scene-river: deep night. The Silver River pours across the sky, widest and brightest on
    /// the trailing pane; Zhinü stands small on the near bank of dark cloud, and far across, on
    /// the other bank, a tiny Niulang waits with the ox, one bright star above each of them.
    /// On the leading pane the river thins to a pale mist low down.
    static func riverScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 130)
        let w: CGFloat = size.width
        let light = night()
        let f: CGFloat = st.far
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.stars(&context, width: w, maxY: st.H * 0.9, count: 70, seed: 21)

        let p0 = CGPoint(x: 930, y: riverLine(930, st.H))
        let p1 = CGPoint(x: -40, y: riverLine(-40, st.H))
        silverRiver(&context, from: p0, to: p1, width0: 190 * f, width1: 54 * f, count: 900, seed: 5, mist0: 0.15, mist1: 0.03)

        // The far bank, across the stars: a low bank of cloud, Niulang and the ox, and Altair.
        let bx: CGFloat = 588
        let by: CGFloat = riverLine(bx, st.H) - 80 * f
        cloudBank(&context, x: bx, y: by, width: 150 * f, height: 13 * f, color: 0x1D2A63, edge: silver, seed: 4, bottom: by + 15 * f)
        Art.group(&context, x: bx + 12 * f, y: by - 5 * f, scale: 0.2 * f) { o in
            ox(&o)
        }
        Art.group(&context, x: bx - 16 * f, y: by - 4 * f, scale: 0.2 * f, scaleX: -1) { p in
            niulang(&p, pose: .stand, mirrored: true)
        }
        brightStar(&context, bx - 4 * f, by - 62 * f, 7 * f, color: 0xFFF1D6)

        let midBank: Path = Kit.ridge(width: w, y: st.H - 8 * f, amp: 10 * f, seed: 17, bottom: st.H + 8)
        Art.fill(&context, midBank, light.mid)
        cloudGround(&context, st, top: 0x1D2460, bottom: 0x0B0E2C)
        cloudFloor(&context, st, seed: 60)

        Kit.designSpace(&context, st) { v in
            Kit.nearSpace(&v, st, anchorX: 780) { n in
                riverGroup(&n, horizon: st.Hv)
            }
        }
        ArtStyle.finish(&context, size, wash: 0.04, vignette: 0.12)
    }

    /// The near bank and Zhinü on it, looking across; Vega stands above her. Design units.
    static func riverGroup(_ context: inout GraphicsContext, horizon Hv: CGFloat) {
        cloudBank(&context, x: 772, y: Hv + 44, width: 340, height: 30, color: 0x262C6C, edge: silver, seed: 14, bottom: Hv + 116)
        brightStar(&context, 812, Hv - 150, 9, color: 0xE6F0FF)
        let feet: CGFloat = Hv + 64
        Art.glow(&context, 790, feet - 90, 110, Art.color(silver), alpha: 0.1)
        Kit.shadow(&context, 792, feet + 3, width: 56, alpha: 0.32)
        Art.group(&context, x: 790, y: feet, scale: 0.85) { z in
            zhinu(&z, pose: .stand, look: CGPoint(x: -0.9, y: -0.5), mouth: .flat)
        }
        // A skein she has let fall: she will not weave.
        Art.group(&context, x: 742, y: feet + 2, rotate: 0.2, scale: 0.16) { s in
            skein(&s)
        }
    }
}

// MARK: - scene-bridge

extension WeaverArt {
    /// scene-bridge: deep night. The river of stars runs low across both panes; on the
    /// trailing pane one clear arch of magpies rises over it, and Zhinü and Niulang take hands
    /// at the top, one bright star at each foot of the bridge. On the leading pane a few last
    /// magpies fly up from the bottom corner.
    static func bridgeScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 120)
        let w: CGFloat = size.width
        let light = night()
        let f: CGFloat = st.far
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.stars(&context, width: w, maxY: st.H * 0.84, count: 84, seed: 33)

        let p0 = CGPoint(x: 930, y: st.H - 80 * f)
        let p1 = CGPoint(x: -40, y: st.H - 44 * f)
        silverRiver(&context, from: p0, to: p1, width0: 124 * f, width1: 62 * f, count: 760, seed: 9, mist0: 0.13, mist1: 0.06)
        let midBank: Path = Kit.ridge(width: w, y: st.H - 6 * f, amp: 8 * f, seed: 23, bottom: st.H + 8)
        Art.fill(&context, midBank, light.mid)
        cloudGround(&context, st, top: 0x1D2460, bottom: 0x0B0E2C)
        cloudFloor(&context, st, seed: 80)

        // The last magpies, flying up from the leading pane's bottom corner toward the bridge.
        let base: CGFloat = st.H + st.depth * 0.5
        let flock: [(CGFloat, CGFloat, CGFloat)] = [
            (84, base + 14, 0.56), (176, base - 26, 0.46), (262, base - 6, 0.4), (338, st.H - 26 * f, 0.32), (404, st.H - 54 * f, 0.26),
        ]
        for bird in flock {
            Art.group(&context, x: bird.0, y: bird.1, rotate: -0.32, scale: bird.2 * f, scaleX: -1) { m in
                magpie(&m)
            }
        }

        Kit.designSpace(&context, st) { v in
            Kit.nearSpace(&v, st, anchorX: 685) { n in
                bridgeGroup(&n, horizon: st.Hv)
            }
        }
        ArtStyle.finish(&context, size, wash: 0.04, vignette: 0.12)
    }

    /// The arch, the birds round it, and the two who meet on top. Design units; the arch
    /// springs from x 500 and x 870 and its crown is 160 above the horizon.
    static func bridgeGroup(_ context: inout GraphicsContext, horizon Hv: CGFloat) {
        let baseY: CGFloat = Hv + 30
        cloudBank(&context, x: 496, y: baseY - 4, width: 120, height: 22, color: 0x232A66, edge: silver, seed: 31, bottom: baseY + 50)
        cloudBank(&context, x: 876, y: baseY - 4, width: 120, height: 22, color: 0x232A66, edge: silver, seed: 35, bottom: baseY + 50)
        magpieArch(&context, x0: 500, x1: 870, baseY: baseY, rise: 190, thick: 26)
        brightStar(&context, 486, Hv + 6, 8, color: 0xE6F0FF)
        brightStar(&context, 884, Hv + 6, 8, color: 0xFFF1D6)
        // The nearest birds, drawn as birds: (x, y above the horizon, scale, facing right).
        let near: [(CGFloat, CGFloat, CGFloat, Bool)] = [
            (548, 64, 0.5, true), (846, 76, 0.5, false), (640, 34, 0.42, true), (752, 14, 0.4, false),
            (596, 204, 0.34, true), (792, 214, 0.34, false), (700, 78, 0.36, false),
        ]
        for bird in near {
            let flip: CGFloat = bird.3 ? -1 : 1
            let tilt: CGFloat = bird.3 ? -0.2 : 0.2
            Art.group(&context, x: bird.0, y: Hv - bird.1, rotate: tilt, scale: bird.2, scaleX: flip) { m in
                magpie(&m)
            }
        }
        // The meeting at the very top.
        let top: CGFloat = Hv - 168
        Art.glow(&context, 685, top - 60, 120, Art.color(rose), alpha: 0.16)
        Art.glow(&context, 685, top - 50, 60, Art.color(gold), alpha: 0.14)
        Art.group(&context, x: 663, y: top, scale: 0.58, scaleX: -1) { z in
            zhinu(&z, pose: .carry, look: CGPoint(x: -0.7, y: 0), mouth: .smile, mirrored: true)
        }
        Art.group(&context, x: 707, y: top, scale: 0.58) { p in
            niulang(&p, pose: .carry, look: CGPoint(x: -0.7, y: 0), mouth: .smile)
        }
    }
}
