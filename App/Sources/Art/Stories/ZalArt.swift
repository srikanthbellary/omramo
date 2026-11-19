import SwiftUI
import OmramoCore

/// Concept art for "Zal and the Simurgh", drawn in code (round 5; composed from the shared kit).
/// An Advanced, LIGHT story: text on both panes, a low horizon and calm pale skies above it,
/// in the clear colours of a Persian painted manuscript opened in morning light.
enum ZalArt {
    /// Draws the picture called `name`. Returns false for a name this story does not have.
    static func paint(_ name: String, role: ArtRole, in context: inout GraphicsContext, size: CGSize) -> Bool {
        guard size.width > 0, size.height > 0 else { return false }
        switch (name, role) {
        case ("scene-court", .sceneUnfolded): courtScene(&context, size)
        case ("scene-court", .sceneFolded): courtFolded(&context, size)
        case ("scene-mountain", .sceneUnfolded): mountainScene(&context, size)
        case ("scene-mountain", .sceneFolded): mountainFolded(&context, size)
        case ("scene-nest", .sceneUnfolded): nestScene(&context, size)
        case ("scene-nest", .sceneFolded): nestFolded(&context, size)
        case ("scene-meeting", .sceneUnfolded): meetingScene(&context, size)
        case ("scene-meeting", .sceneFolded): meetingFolded(&context, size)
        case ("see-shahnameh", .picture): shahnamehPicture(&context, size)
        case ("see-alborz", .picture): alborzPicture(&context, size)
        case ("see-simurgh-feather", .picture): featherPicture(&context, size)
        case ("see-naqqali", .picture): naqqaliPicture(&context, size)
        case ("char-zal", .portrait): zalPortrait(&context, size)
        case ("char-simurgh", .portrait): simurghPortrait(&context, size)
        case ("face-zal", .face): zalFace(&context, size)
        case ("face-simurgh", .face): simurghFace(&context, size)
        case ("face-sam", .face): samFace(&context, size)
        case ("cover", .cover): coverPicture(&context, size)
        default:
            return false
        }
        return true
    }
}

// MARK: - Scene 1: Sam's garden in Zabulistan at pale dawn

extension ZalArt {
    static func courtScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 220)
        let light = dawn()
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.sun(&context, 236, st.H - 38 * st.far, 17 * st.far, light: light)
        Kit.cloud(&context, 650, 118, scale: 0.9, color: Art.color(0xFBEDE8, 0.5))
        Kit.cloud(&context, 830, 214, scale: 0.6, color: Art.color(0xFCEFE6, 0.45))
        Kit.cloud(&context, 110, 84, scale: 0.7, color: Art.color(0xFBEDE8, 0.35))
        Kit.ranges(&context, width: 892, horizon: st.H, scale: st.far, light: light, mountains: false, seed: 21)
        Kit.farTrees(&context, x0: 0, x1: 892, baseY: st.H + 2, height: 38 * st.far, count: 30, color: light.near.opacity(0.5), conifer: true, seed: 9)
        ArtStyle.atmosphere(&context, width: 892, top: st.H - 60 * st.far, bottom: st.H + 4, color: light.haze, alpha: 0.3)
        let earth: Kit.Stops = Kit.stops(0xC8C493, 0x9DAE7C, 0x6E8E6A)
        Kit.ground(&context, width: 892, top: st.H, bottom: size.height, stops: earth, seed: 41)
        Kit.designSpace(&context, st) { v in
            courtGarden(&v, st)
            Kit.nearSpace(&v, st) { n in
                courtPavilionSide(&n, st.Hv)
            }
            Kit.nearSpace(&v, st, anchorX: 620) { n in
                courtFigures(&n, st.Hv)
            }
            if st.tall > 0.25 {
                courtNearFill(&v, st)
            }
            let frame = CGSize(width: 892, height: st.hv)
            Kit.cornerLeaves(&v, size: frame, corner: 2, color: Art.color(0x2F5A44), scale: 0.9 * st.grow, seed: 3)
            Kit.cornerLeaves(&v, size: frame, corner: 3, color: Art.color(0x24503E), scale: 0.8 * st.grow, seed: 4)
        }
        ArtStyle.finish(&context, size, wash: 0.08, vignette: 0.06)
    }

    /// The paved walk, the long pool with its fountains and reflections, the tiled channel
    /// running toward the viewer, the rose beds and the middle cypresses.
    static func courtGarden(_ g: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        let paving: Kit.Stops = Kit.stops(0xEEDFC6, 0xDCC6A4)
        let walkTop: CGFloat = Hv + 6
        Art.fillLinear(&g, Art.rect(-10, walkTop, 912, 74), paving, from: CGPoint(x: 0, y: walkTop), to: CGPoint(x: 0, y: walkTop + 74))
        ArtStyle.tooth(&g, in: CGRect(x: 0, y: walkTop, width: 892, height: 74), seed: 17, color: Art.color(0xA88A64), alpha: 0.08)
        // Middle cypresses: only their tips rise into the pale sky.
        Kit.cypress(&g, x: 112, baseY: Hv + 10, height: 64, color: 0x3E6450)
        Kit.cypress(&g, x: 384, baseY: Hv + 12, height: 82, color: 0x335A48)
        Kit.cypress(&g, x: 452, baseY: Hv + 12, height: 86, color: 0x2E5242)
        Kit.cypress(&g, x: 512, baseY: Hv + 10, height: 74, color: 0x335A48)
        courtPool(&g, Hv)
        // The tiled channel that runs from the pool toward the viewer.
        let bottom: CGFloat = st.hv + 10
        let channel: Path = Art.polygon([Kit.pt(288, Hv + 60), Kit.pt(312, Hv + 60), Kit.pt(352, bottom), Kit.pt(248, bottom)])
        let channelWater: Kit.Stops = Kit.stops(0xEFCDB8, 0xF5E3DA)
        Art.fillLinear(&g, channel, channelWater, from: CGPoint(x: 0, y: Hv + 60), to: CGPoint(x: 0, y: bottom))
        Art.stroke(&g, channel, Art.color(0x3FA7B0), width: 3)
        Art.stroke(&g, channel, Art.color(0xF4F1EA, 0.6), width: 1)
        // Rose beds either side of the channel.
        let roses: Kit.Greens = roseGreens()
        Kit.bush(&g, x: 196, baseY: Hv + 112, width: 74, palette: roses, seed: 2)
        Kit.bush(&g, x: 404, baseY: Hv + 110, width: 66, palette: roses, seed: 6)
        Kit.flowers(&g, in: CGRect(x: 158, y: Hv + 82, width: 80, height: 24), count: 9, seed: 5, petal: 0xD9707A, heart: 0xF2B544)
        Kit.flowers(&g, in: CGRect(x: 370, y: Hv + 82, width: 70, height: 22), count: 8, seed: 8, petal: 0xE58A8F, heart: 0xF2B544)
        Kit.grass(&g, in: CGRect(x: 0, y: Hv + 84, width: 150, height: 30), count: 26, seed: 12, color: Art.color(0x6E8E6A), height: 9)
        Kit.grass(&g, in: CGRect(x: 60, y: Hv + 120, width: 180, height: 40), count: 30, seed: 13, color: Art.color(0x5C7E5A), height: 11)
    }

    /// The long rectangular pool, low across the picture, reflecting the rose-gold dawn.
    static func courtPool(_ g: inout GraphicsContext, _ Hv: CGFloat) {
        let top: CGFloat = Hv + 18
        let depth: CGFloat = 42
        let pool: Path = Art.rect(-10, top, 622, depth)
        let water: Kit.Stops = Kit.stops(0xEAC4AE, 0xF6E2D8)
        Art.fillLinear(&g, pool, water, from: CGPoint(x: 0, y: top), to: CGPoint(x: 0, y: top + depth))
        Art.clipped(&g, to: pool) { w in
            // Reflections of the cypresses and the pale sun.
            let marks: [(CGFloat, CGFloat)] = [(112, 10), (384, 13), (452, 14), (512, 12)]
            for mark in marks {
                Art.fill(&w, Art.ellipse(mark.0, top + 12, 5, mark.1), Art.color(0x2E5242, 0.22))
            }
            Art.glow(&w, 236, top + 6, 50, Art.color(0xFFF4DA), alpha: 0.5)
            Kit.rippleMarks(&w, x0: 0, x1: 600, y0: top + 4, y1: top + depth - 2, count: 22, seed: 7, color: Color.white, alpha: 0.4)
            Kit.glints(&w, x: 236, top: top, depth: depth, color: Art.color(0xFFF4DA), count: 14, seed: 3)
        }
        // Stone coping with a line of turquoise tile inside it.
        Art.stroke(&g, Art.line(-10, top, 612, top), Art.color(0xF1E6D2), width: 3)
        Art.stroke(&g, Art.line(-10, top + depth, 612, top + depth), Art.color(0xF1E6D2), width: 6)
        Art.stroke(&g, Art.line(612, top, 612, top + depth), Art.color(0xE3D3B8), width: 5)
        Art.stroke(&g, Art.line(-10, top + depth - 3, 609, top + depth - 3), Art.color(0x3FA7B0), width: 2)
        Art.fill(&g, Art.rect(-10, top + depth + 3, 625, 4), ArtStyle.coolShade.opacity(0.12))
        // Three low fountain jets.
        let jets: [CGFloat] = [140, 330, 520]
        for x in jets {
            let jet: Path = Kit.placed("M0,0 C-2,-16 -9,-20 -15,-7 M0,0 C2,-16 9,-20 15,-7 M0,0 L0,-17", x: x, y: top + 22)
            Art.stroke(&g, jet, Color.white.opacity(0.75), width: 1.3)
            Kit.ripples(&g, x, top + 22, 26, count: 2, color: Color.white, opacity: 0.5)
        }
    }

    /// The tiled pavilion on the trailing side and the near cypress at the edge.
    static func courtPavilionSide(_ g: inout GraphicsContext, _ Hv: CGFloat) {
        pavilion(&g, x0: 640, baseY: Hv + 36, width: 236, height: 120)
        Kit.cypress(&g, x: 886, baseY: Hv + 44, height: 88, color: 0x24503E)
    }

    /// Sam at the pool's edge, turned away; the old nurse behind him holding out the baby; the
    /// mother kneeling at one side.
    static func courtFigures(_ g: inout GraphicsContext, _ Hv: CGFloat) {
        Kit.shadow(&g, 546, Hv + 92, width: 66)
        Art.group(&g, x: 546, y: Hv + 92, scale: 0.72) { p in
            sam(&p, pose: .stand, white: false, helmet: true, look: CGPoint(x: -0.8, y: 0.4), mouth: .flat)
        }
        Kit.shadow(&g, 628, Hv + 96, width: 60)
        Art.group(&g, x: 628, y: Hv + 96, scale: 0.7) { p in
            nurse(&p)
        }
        Kit.shadow(&g, 714, Hv + 102, width: 66)
        Art.group(&g, x: 714, y: Hv + 102, scale: 0.7) { p in
            mother(&p, pose: .kneel)
        }
    }

    /// The deeper garden on a tall window: paving stones along the channel, more roses, grass.
    static func courtNearFill(_ g: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        let low: CGFloat = st.hv
        let span: CGFloat = max(40, low - Hv - 150)
        let roses: Kit.Greens = roseGreens()
        Kit.bush(&g, x: 150, baseY: Hv + 150 + span * 0.45, width: 96, palette: roses, seed: 21)
        Kit.bush(&g, x: 470, baseY: Hv + 150 + span * 0.5, width: 104, palette: roses, seed: 22)
        Kit.bush(&g, x: 640, baseY: Hv + 160 + span * 0.3, width: 90, palette: roses, seed: 23)
        let bedTop: CGFloat = Hv + 140 + span * 0.3
        Kit.flowers(&g, in: CGRect(x: 90, y: bedTop, width: 130, height: 40), count: 12, seed: 24, petal: 0xD9707A, heart: 0xF2B544)
        Kit.flowers(&g, in: CGRect(x: 420, y: bedTop, width: 140, height: 40), count: 12, seed: 25, petal: 0xF4F1EA, heart: 0xF2B544)
        Kit.grass(&g, in: CGRect(x: 0, y: Hv + 150, width: 892, height: span + 40), count: 80, seed: 26, color: Art.color(0x5C7E5A), height: 12)
        var random = ArtRandom(27)
        for i in 0..<6 {
            let t: CGFloat = CGFloat(i) / 5
            let y: CGFloat = Hv + 120 + (low - Hv - 130) * t
            let wobble: CGFloat = (Kit.rnd(&random) - 0.5) * 20
            let w: CGFloat = 30 + 30 * t
            Art.fill(&g, Art.rect(208 + wobble - w * 0.5, y, w, 6 + 4 * t, radius: 3), Art.color(0xE6D6BA, 0.9))
            Art.fill(&g, Art.rect(392 + wobble - w * 0.5, y + 6, w, 6 + 4 * t, radius: 3), Art.color(0xE6D6BA, 0.9))
        }
    }
}

// MARK: - Scene 2: the Alborz, the crag, the bundle on the rock

extension ZalArt {
    static func mountainScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 220)
        let light = highDay()
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.cloud(&context, 600, 96, scale: 0.8, color: Art.color(0xF6F9FC, 0.6))
        Kit.cloud(&context, 300, 150, scale: 0.6, color: Art.color(0xF6F9FC, 0.45))
        Kit.cloud(&context, 830, 236, scale: 0.5, color: Art.color(0xF6F9FC, 0.5))
        damavand(&context, cx: 150, baseY: st.H - 12 * st.far, scale: st.far)
        alborzWall(&context, width: 892, horizon: st.H, scale: st.far, seed: 14, light: light)
        let slope: Kit.Stops = Kit.stops(0xCFC39C, 0xB2A682, 0x8E8470)
        Kit.ground(&context, width: 892, top: st.H, bottom: size.height, stops: slope, seed: 43)
        Kit.designSpace(&context, st) { v in
            mountainRoad(&v, st.Hv)
            Kit.nearSpace(&v, st) { n in
                mountainCrag(&n, st.Hv)
            }
            Kit.nearSpace(&v, st, anchorX: 640) { n in
                mountainRock(&n, st.Hv)
            }
            if st.tall > 0.25 {
                mountainNearFill(&v, st)
            }
            mountainNearFrame(&v, st)
        }
        ArtStyle.finish(&context, size, wash: 0.08, vignette: 0.06)
    }

    /// The old caravan road along the foot of the range, with a string of far camels (page 8).
    static func mountainRoad(_ g: inout GraphicsContext, _ Hv: CGFloat) {
        let road: Path = Kit.placed("M-10,30 C150,20 300,36 480,22 C560,16 640,26 700,20", x: 0, y: Hv)
        Art.stroke(&g, road, Art.color(0xE8DEC4), width: 7)
        Art.stroke(&g, road, Art.color(0xF4ECD8, 0.7), width: 2)
        let places: [CGFloat] = [128, 170, 212, 254]
        for x in places {
            Art.group(&g, x: x, y: Hv + 27, scale: 0.6) { c in
                camel(&c, color: Art.color(0x9A7650, 0.85), bags: Art.color(rose, 0.85))
            }
        }
        // The driver walking ahead, in a turban and a long coat.
        let driver: Path = Art.svg("M-3,0 L-4,-12 C-4,-15 4,-15 4,-12 L3,0Z")
        Art.fill(&g, driver.applying(CGAffineTransform(translationX: 100, y: Hv + 27)), Art.color(0x5A4A6A, 0.85))
        Art.fill(&g, Art.circle(100, Hv + 10, 2.6), Art.color(0xF0E6D6, 0.9))
        Kit.grass(&g, in: CGRect(x: 0, y: Hv + 36, width: 460, height: 24), count: 40, seed: 31, color: Art.color(0xA0946E), height: 7)
    }

    /// The crag on the trailing side with the great nest on its top, chicks peering out.
    static func mountainCrag(_ g: inout GraphicsContext, _ Hv: CGFloat) {
        let rise: Kit.Stops = Kit.stops(0xBDB18C, 0x9C9078)
        Kit.mound(&g, x0: 560, x1: 960, baseY: Hv + 82, height: 46, bottom: Hv + 260, stops: rise, crest: 0.6)
        crag(&g, cx: 806, baseY: Hv + 52, topY: Hv - 54, width: 112, color: 0xC6CCD2, seed: 6)
        nestBack(&g, cx: 806, y: Hv - 56, width: 118)
        Art.group(&g, x: 788, y: Hv - 54, scale: 0.36) { c in
            chick(&c)
        }
        Art.group(&g, x: 824, y: Hv - 54, scale: 0.32) { c in
            chick(&c)
        }
        nestFront(&g, cx: 806, y: Hv - 56, width: 118)
        let dry: Kit.Greens = dryGreens()
        Kit.bush(&g, x: 712, baseY: Hv + 66, width: 40, palette: dry, seed: 3)
        Kit.bush(&g, x: 872, baseY: Hv + 74, width: 46, palette: dry, seed: 4)
    }

    /// The flat sunlit rock with the bundled baby, the lizard, the hoofprints leading away,
    /// and the Simurgh sliding down the air toward him.
    static func mountainRock(_ g: inout GraphicsContext, _ Hv: CGFloat) {
        Kit.shadow(&g, 690, Hv + 100, width: 200, alpha: 0.1)
        var prints = Path()
        let steps: [(CGFloat, CGFloat)] = [(556, 104), (536, 112), (514, 121), (490, 132), (464, 144)]
        for step in steps {
            prints.addPath(Art.ellipse(step.0, Hv + step.1, 3.4, 2))
        }
        Art.fill(&g, prints, Art.color(0x6E6450, 0.5))
        Kit.rock(&g, cx: 612, baseY: Hv + 96, width: 120, height: 36, color: 0xD2C2A2, seed: 3)
        Art.fill(&g, Art.ellipse(604, Hv + 63, 42, 5), Art.color(0xFFF1D0, 0.5))
        Kit.shadow(&g, 614, Hv + 62, width: 50, alpha: 0.2)
        Art.group(&g, x: 612, y: Hv + 56, scale: 1.15) { b in
            baby(&b)
        }
        lizard(&g, x: 664, y: Hv + 72)
        Kit.grass(&g, in: CGRect(x: 540, y: Hv + 88, width: 150, height: 16), count: 22, seed: 32, color: Art.color(0x9C8E64), height: 8)
        Art.group(&g, x: 702, y: Hv + 4, scale: 0.42) { s in
            simurgh(&s, pose: .glide, look: CGPoint(x: -0.6, y: 0.8))
        }
    }

    /// The deeper slope of a tall window: stones, thorn bushes, dry grass, wild tulips.
    static func mountainNearFill(_ g: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        let span: CGFloat = max(40, st.hv - Hv - 160)
        let dry: Kit.Greens = dryGreens()
        Kit.rock(&g, cx: 220, baseY: Hv + 150 + span * 0.3, width: 70, height: 26, color: 0xB8AC90, seed: 12)
        Kit.rock(&g, cx: 520, baseY: Hv + 170 + span * 0.5, width: 90, height: 30, color: 0xAFA388, seed: 13)
        Kit.bush(&g, x: 360, baseY: Hv + 160 + span * 0.4, width: 60, palette: dry, seed: 14)
        Kit.bush(&g, x: 700, baseY: Hv + 180 + span * 0.6, width: 70, palette: dry, seed: 15)
        Kit.grass(&g, in: CGRect(x: 0, y: Hv + 140, width: 892, height: span + 40), count: 90, seed: 16, color: Art.color(0x9A8C62), height: 11)
        Kit.flowers(&g, in: CGRect(x: 120, y: Hv + 150 + span * 0.5, width: 300, height: 40), count: 9, seed: 17, petal: 0xD9443A, heart: 0x3A2A22)
    }

    /// Dark rocks cropped by the bottom corners.
    static func mountainNearFrame(_ g: inout GraphicsContext, _ st: Kit.Stage) {
        let low: CGFloat = st.hv + 24
        Kit.rock(&g, cx: 30, baseY: low, width: 170, height: 70 * st.grow, color: 0x6F6A62, seed: 9)
        Kit.rock(&g, cx: 880, baseY: low, width: 190, height: 80 * st.grow, color: 0x66625C, seed: 10)
        Kit.grass(&g, in: CGRect(x: 0, y: low - 40, width: 120, height: 30), count: 18, seed: 18, color: Art.color(0x5E5A44), height: 12)
    }
}

// MARK: - Scene 3: the nest above the floor of cloud

extension ZalArt {
    static func nestScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 220)
        let light = cloudDay()
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.cloud(&context, 520, 90, scale: 0.7, color: Art.color(0xFFFFFF, 0.45))
        Kit.cloud(&context, 180, 170, scale: 0.5, color: Art.color(0xFFFFFF, 0.4))
        Kit.birds(&context, 250, st.H - 60 * st.far, scale: 0.8, color: Art.color(0x7E98AE, 0.6))
        damavand(&context, cx: 120, baseY: st.H + 4, scale: st.far * 0.8)
        let peaks: Path = Kit.peaks(width: 892, y: st.H + 6, amp: 46 * st.far, seed: 23, bottom: st.H + 20, sharp: 0.85)
        let snowy: Kit.Stops = [(Art.color(0xF7F9FB), 0), (Art.color(0xE4EEF4), 0.45), (light.far, 1)]
        Art.fillLinear(&context, peaks, snowy, from: CGPoint(x: 0, y: st.H - 40 * st.far), to: CGPoint(x: 0, y: st.H + 10))
        ArtStyle.atmosphere(&context, width: 892, top: st.H - 70 * st.far, bottom: st.H + 10, color: light.haze, alpha: 0.3)
        cloudFloor(&context, width: 892, top: st.H, bottom: size.height, scale: st.far)
        Kit.designSpace(&context, st) { v in
            Kit.nearSpace(&v, st) { n in
                nestCrag(&n, st.Hv)
                nestFamily(&n, st.Hv)
            }
            if st.tall > 0.25 {
                nestNearFill(&v, st)
            }
        }
        ArtStyle.finish(&context, size, wash: 0.08, vignette: 0.05)
    }

    /// The crag top rising out of the cloud, and the great nest of ebony and sandalwood.
    static func nestCrag(_ g: inout GraphicsContext, _ Hv: CGFloat) {
        crag(&g, cx: 742, baseY: Hv + 240, topY: Hv + 34, width: 360, color: 0xCFCFCB, seed: 8)
        Kit.cloud(&g, 560, Hv + 150, scale: 1.4, color: Art.color(0xFFFFFF, 0.9))
        Kit.cloud(&g, 900, Hv + 170, scale: 1.2, color: Art.color(0xF8FBFB, 0.9))
        nestBack(&g, cx: 712, y: Hv + 40, width: 300)
    }

    /// The Simurgh standing in the nest, her near wing spread like a roof over two chicks and
    /// the white-haired boy, who sits looking out over the cloud; then the nest's front rim.
    static func nestFamily(_ g: inout GraphicsContext, _ Hv: CGFloat) {
        Art.group(&g, x: 812, y: Hv + 50, scale: 0.5) { s in
            simurghPerchBack(&s)
        }
        Art.group(&g, x: 742, y: Hv + 50, scale: 0.8) { c in
            chick(&c, look: CGPoint(x: -0.5, y: 0))
        }
        Art.group(&g, x: 600, y: Hv + 46, scale: 0.68) { c in
            chick(&c, look: CGPoint(x: -0.8, y: 0.2))
        }
        Art.group(&g, x: 660, y: Hv + 50, scale: 0.5) { z in
            zal(&z, child: true, pose: .sit, feather: false, look: CGPoint(x: -0.9, y: 0.1), mouth: .smile)
        }
        Art.group(&g, x: 776, y: Hv + 54, scale: 0.72) { c in
            chick(&c, look: CGPoint(x: -0.6, y: -0.2))
        }
        Art.group(&g, x: 812, y: Hv + 50, scale: 0.5) { s in
            simurghPerchFront(&s, wing: 270, look: CGPoint(x: -0.7, y: 0.5), mirrored: false)
        }
        nestFront(&g, cx: 712, y: Hv + 40, width: 300)
    }

    /// More cloud toward the viewer on a tall window.
    static func nestNearFill(_ g: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        let span: CGFloat = max(60, st.hv - Hv - 200)
        let rows: [(CGFloat, CGFloat, CGFloat)] = [(120, 0.35, 1.6), (380, 0.55, 1.9), (90, 0.85, 2.2), (520, 0.95, 2.0)]
        for row in rows {
            let y: CGFloat = Hv + 200 + span * row.1
            Kit.cloud(&g, row.0, y, scale: row.2, color: Art.color(0xFFFFFF, 0.85))
        }
    }
}

// MARK: - Scene 4: the meeting at the foot of the mountain

extension ZalArt {
    static func meetingScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 220)
        let light = morning()
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.sun(&context, 110, st.H - 50 * st.far, 15 * st.far, light: light)
        Kit.cloud(&context, 700, 110, scale: 0.7, color: Art.color(0xFFFFFF, 0.45))
        Kit.cloud(&context, 420, 60, scale: 0.6, color: Art.color(0xFFFFFF, 0.35))
        damavand(&context, cx: 260, baseY: st.H - 14 * st.far, scale: st.far * 0.9)
        let cragTop: CGFloat = st.H - 120 * st.far
        crag(&context, cx: 868, baseY: st.H + 6, topY: cragTop, width: 96 * st.far, color: 0xD3D9DF, seed: 31)
        alborzWall(&context, width: 892, horizon: st.H, scale: st.far, seed: 29, light: light)
        let field: Kit.Stops = Kit.stops(0xD6D2A6, 0xB5B68C, 0x8E9A7E)
        Kit.ground(&context, width: 892, top: st.H, bottom: size.height, stops: field, seed: 47)
        Kit.designSpace(&context, st) { v in
            meetingColumn(&v, st.Hv)
            Kit.nearSpace(&v, st, anchorX: 640) { n in
                meetingCompany(&n, st.Hv)
                meetingArrival(&n, st.Hv)
            }
            if st.tall > 0.25 {
                meetingNearFill(&v, st)
            }
            let frame = CGSize(width: 892, height: st.hv)
            Kit.cornerLeaves(&v, size: frame, corner: 2, color: Art.color(0x4E5A3A), scale: 0.8 * st.grow, seed: 7)
            Kit.rock(&v, cx: 884, baseY: st.hv + 20, width: 170, height: 64 * st.grow, color: 0x6E6A5E, seed: 33)
        }
        ArtStyle.finish(&context, size, wash: 0.08, vignette: 0.06)
    }

    /// Far along the leading pane, the rest of Sam's column waits with its pennants.
    static func meetingColumn(_ g: inout GraphicsContext, _ Hv: CGFloat) {
        let road: Path = Kit.placed("M-10,40 C120,30 260,44 420,36", x: 0, y: Hv)
        Art.stroke(&g, road, Art.color(0xE6DEC2), width: 8)
        let riders: [(CGFloat, UInt32, UInt32, UInt32)] = [
            (96, 0x8A5A3A, lapis, saffron), (178, 0xB9AFA4, saffron, lapis), (262, 0x5A3A2A, lapis, saffron), (346, 0xA8703E, rose, lapis),
        ]
        for rider in riders {
            Art.group(&g, x: rider.0, y: Hv + 36, scale: 0.24, scaleX: -1) { r in
                horseman(&r, coat: rider.1, cloth: rider.2, skin: 0xD2A07A, pennant: rider.3, mirrored: true)
            }
        }
        Kit.grass(&g, in: CGRect(x: 0, y: Hv + 44, width: 440, height: 30), count: 44, seed: 51, color: Art.color(0x9AA078), height: 8)
    }

    /// Two riders waiting behind Sam, the flat rock, and Sam kneeling on it, helmet off, white
    /// beard, looking up.
    static func meetingCompany(_ g: inout GraphicsContext, _ Hv: CGFloat) {
        Art.group(&g, x: 486, y: Hv + 44, scale: 0.36, scaleX: -1) { r in
            horseman(&r, coat: 0x7A4A30, cloth: saffron, skin: 0xC9946E, pennant: lapis, mirrored: true)
        }
        Art.group(&g, x: 540, y: Hv + 62, scale: 0.4, scaleX: -1) { r in
            horseman(&r, coat: 0xB9AFA4, cloth: lapis, skin: 0xD9A57E, pennant: saffron, mirrored: true)
        }
        Kit.rock(&g, cx: 640, baseY: Hv + 104, width: 152, height: 26, color: 0xCBC2AC, seed: 5)
        Art.fill(&g, Art.ellipse(630, Hv + 81, 60, 4), Art.color(0xFFF3D6, 0.4))
        Kit.shadow(&g, 634, Hv + 80, width: 72)
        Art.group(&g, x: 634, y: Hv + 80, scale: 0.62, scaleX: -1) { s in
            sam(&s, pose: .kneel, white: true, helmet: false, look: CGPoint(x: -0.5, y: -0.9), mouth: .sad, mirrored: true)
        }
        // His helmet, set down on the stone.
        Kit.shadow(&g, 588, Hv + 80, width: 24)
        Art.group(&g, x: 588, y: Hv + 82, scale: 0.34) { h in
            samHelmet(&h, mirrored: false)
        }
    }

    /// The Simurgh gliding down onto the rock with the grown Zal on her back; the wind of her
    /// wings lays the grass flat.
    static func meetingArrival(_ g: inout GraphicsContext, _ Hv: CGFloat) {
        Kit.shadow(&g, 772, Hv + 108, width: 190, alpha: 0.14)
        var wind = Path()
        let sweeps: [(CGFloat, CGFloat)] = [(700, 96), (740, 112), (800, 100), (850, 116), (680, 118)]
        for sweep in sweeps {
            wind.move(to: CGPoint(x: sweep.0, y: Hv + sweep.1))
            wind.addQuadCurve(to: CGPoint(x: sweep.0 + 34, y: Hv + sweep.1 + 2), control: CGPoint(x: sweep.0 + 16, y: Hv + sweep.1 - 5))
        }
        Art.stroke(&g, wind, Art.color(0x7E8A62, 0.6), width: 1.4)
        Art.group(&g, x: 790, y: Hv + 22, rotate: 0.1, scale: 0.56) { s in
            simurgh(&s, pose: .glide, rider: true, look: CGPoint(x: -0.8, y: 0.7))
        }
    }

    /// The deeper field of a tall window: grass, mountain tulips, stones.
    static func meetingNearFill(_ g: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        let span: CGFloat = max(40, st.hv - Hv - 160)
        Kit.grass(&g, in: CGRect(x: 0, y: Hv + 130, width: 892, height: span + 30), count: 90, seed: 52, color: Art.color(0x7E8A62), height: 12)
        Kit.flowers(&g, in: CGRect(x: 80, y: Hv + 150 + span * 0.3, width: 360, height: 50), count: 12, seed: 53, petal: 0xD9443A, heart: 0x3A2A22)
        Kit.flowers(&g, in: CGRect(x: 480, y: Hv + 160 + span * 0.55, width: 260, height: 40), count: 8, seed: 54, petal: saffron, heart: 0x8A4A00)
        Kit.rock(&g, cx: 300, baseY: Hv + 170 + span * 0.6, width: 80, height: 28, color: 0xB9B09A, seed: 55)
    }
}
