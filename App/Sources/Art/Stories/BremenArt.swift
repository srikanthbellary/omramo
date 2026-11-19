import SwiftUI
import OmramoCore

/// Concept art for "The Bremen Town Musicians", drawn in code (round 5; composed from the shared kit).
///
/// The cast, the tower of four and the timber house live in `BremenArt+Cast.swift`; the four
/// folded-phone compositions in `BremenArt+Folded.swift`; the tap-to-see pictures, the
/// portraits, the faces and the cover in `BremenArt+Pictures.swift`. This file holds the entry
/// point and the four unfolded scenes.
enum BremenArt {
    /// Draws the picture called `name`. Returns false for a name this story does not have.
    static func paint(_ name: String, role: ArtRole, in context: inout GraphicsContext, size: CGSize) -> Bool {
        guard size.width > 0, size.height > 0 else { return false }
        switch (name, role) {
        case ("scene-road", .sceneUnfolded): roadScene(&context, size)
        case ("scene-road", .sceneFolded): roadFolded(&context, size)
        case ("scene-forest", .sceneUnfolded): forestScene(&context, size)
        case ("scene-forest", .sceneFolded): forestFolded(&context, size)
        case ("scene-window", .sceneUnfolded): windowScene(&context, size)
        case ("scene-window", .sceneFolded): windowFolded(&context, size)
        case ("scene-home", .sceneUnfolded): homeScene(&context, size)
        case ("scene-home", .sceneFolded): homeFolded(&context, size)
        case ("see-mill", .picture): millPicture(&context, size)
        case ("see-town-musician", .picture): townMusicianPicture(&context, size)
        case ("see-timber-house", .picture): timberHousePicture(&context, size)
        case ("char-donkey", .portrait): donkeyPortrait(&context, size)
        case ("char-rooster", .portrait): roosterPortrait(&context, size)
        case ("face-donkey", .face): donkeyFace(&context, size)
        case ("face-dog", .face): dogFace(&context, size)
        case ("face-cat", .face): catFace(&context, size)
        case ("face-rooster", .face): roosterFace(&context, size)
        case ("cover", .cover): cover(&context, size)
        default:
            return false
        }
        return true
    }
}

// MARK: - Shared ground cover of the unfolded scenes

extension BremenArt {
    /// Grass over the ground of an unfolded scene, thicker and with flowers on a tall window,
    /// so the foot of the picture is never empty. In the picture's own units.
    static func groundCover(_ context: inout GraphicsContext, _ st: Kit.Stage, dark: UInt32, lit: UInt32, petal: UInt32) {
        let top: CGFloat = st.H + 14 * st.fit
        let depth: CGFloat = max(1, st.h - top)
        let field = CGRect(x: 0, y: top, width: st.w, height: depth)
        let more: CGFloat = 1 + st.tall * 1.6
        let tufts: Int = Int(70 * more)
        Kit.grass(&context, in: field, count: tufts, seed: 21, color: Art.color(dark, 0.55), height: 9 * st.grow)
        Kit.grass(&context, in: field, count: tufts / 2, seed: 37, color: Art.color(lit, 0.7), height: 7 * st.grow)
        let low = CGRect(x: 0, y: top + depth * 0.35, width: 430, height: depth * 0.6)
        let blooms: Int = Int(10 * more)
        Kit.flowers(&context, in: low, count: blooms, seed: 9, petal: petal)
        if st.tall > 0.25 {
            let foot: CGFloat = st.h - depth * 0.18
            Kit.grassTuft(&context, x: 250, baseY: foot, height: 54 * st.grow, color: dark, seed: 4)
            Kit.grassTuft(&context, x: 420, baseY: st.h - 8, height: 62 * st.grow, color: dark, seed: 6)
            Kit.pebbles(&context, in: CGRect(x: 120, y: foot - 40, width: 300, height: 60), count: 9, seed: 15)
        }
    }
}

// MARK: - scene-road

extension BremenArt {
    /// scene-road: flat northern fields under a huge pale sky; the pale road runs to the far
    /// town; the Donkey walks toward it with the Dog beside him, the Cat a step behind and
    /// the Rooster crowing on a gate post. A windmill, small, on the leading horizon.
    static func roadScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st: Kit.Stage = Kit.stage(size, ground: 170)
        let light: Kit.Light = day()
        let H: CGFloat = st.H
        let far: CGFloat = st.far
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.sun(&context, 118, H - 48 * far, 20 * far, light: light)
        Kit.cloud(&context, 640, H * 0.27, scale: 0.9, color: Art.color(0xFFFFFF, 0.75))
        Kit.cloud(&context, 300, H * 0.16, scale: 0.55, color: Art.color(0xFFFFFF, 0.5))
        Kit.cloud(&context, 520, H * 0.5, scale: 0.5, color: Art.color(0xFFFFFF, 0.55))

        // The far plane: a low tree line, the mill, and Bremen where the road ends.
        let roadEnd: CGFloat = 760 - 55 * st.grow
        let townX: CGFloat = 892 * (1 - st.fit) + roadEnd * st.fit
        Kit.farTrees(&context, x0: 0, x1: 892, baseY: H + 2, height: 15 * far, count: 44, color: light.far, seed: 5)
        Kit.windmill(&context, cx: 190, baseY: H + 2, height: 58 * far, body: 0x9AA8B0, sails: 0xF4F4EC)
        farTown(&context, x: townX, baseY: H + 1, scale: far, color: Art.color(0x9DB8CC))
        Kit.birds(&context, 330, H - 58 * far, scale: far, color: Art.color(0x7C93A0, 0.8))
        ArtStyle.atmosphere(&context, width: 892, top: H - 76 * far, bottom: H + 4, color: light.haze, alpha: 0.3)

        Kit.ground(&context, width: 892, top: H, bottom: size.height, stops: meadowStops())
        roadFields(&context, st)

        Kit.designSpace(&context, st) { v in
            roadMiddle(&v, st)
            Kit.nearSpace(&v, st, anchorX: 760) { n in
                roadNear(&n, st)
            }
        }
        groundCover(&context, st, dark: 0x4F8A4A, lit: 0xC9E08A, petal: 0xFFFFFF)
        Kit.cornerLeaves(&context, size: size, corner: 2, color: Art.color(0x3F6B45), scale: 0.9 * st.grow, seed: 3)
        ArtStyle.finish(&context, size)
    }

    /// The rye and meadow strips of the flat land, just under the horizon (picture units).
    static func roadFields(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.H
        let f: CGFloat = st.far
        let rye: Color = Art.color(0xE9D27C, 0.85)
        Art.fill(&context, Art.rect(0, H + 3 * f, 892, 7 * f), rye)
        let strip: [CGPoint] = [
            CGPoint(x: 0, y: H + 20 * f), CGPoint(x: 330, y: H + 15 * f),
            CGPoint(x: 470, y: H + 24 * f), CGPoint(x: 0, y: H + 46 * f),
        ]
        Art.fill(&context, Art.polygon(strip), rye)
        let green: [CGPoint] = [
            CGPoint(x: 892, y: H + 14 * f), CGPoint(x: 780, y: H + 13 * f),
            CGPoint(x: 800, y: H + 30 * f), CGPoint(x: 892, y: H + 40 * f),
        ]
        Art.fill(&context, Art.polygon(green), Art.color(0x7FAE5C, 0.7))
        var lines = Path()
        for index in 0..<7 {
            let t: CGFloat = CGFloat(index) / 6
            lines.move(to: CGPoint(x: 0, y: H + (24 + 20 * t) * f))
            lines.addLine(to: CGPoint(x: 330 + 120 * t, y: H + (16 + 8 * t) * f))
        }
        Art.stroke(&context, lines, Art.color(0xC9AE54, 0.5), width: 1)
    }

    /// The middle plane on the leading side: a ditch with pollarded willows (design units).
    static func roadMiddle(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        var ditch = Path()
        ditch.move(to: CGPoint(x: -10, y: Hv + 40))
        ditch.addQuadCurve(to: CGPoint(x: 440, y: Hv + 30), control: CGPoint(x: 220, y: Hv + 26))
        Art.stroke(&context, ditch, Art.color(0x5F8F4E, 0.6), width: 9)
        Art.stroke(&context, ditch, Art.color(0xD6ECF2, 0.95), width: 5)
        willow(&context, x: 92, baseY: Hv + 30, height: 60, seed: 3)
        willow(&context, x: 232, baseY: Hv + 25, height: 50, seed: 5)
        willow(&context, x: 356, baseY: Hv + 24, height: 44, seed: 9)
        Kit.reeds(&context, x: 300, baseY: Hv + 34, count: 5, height: 22, seed: 8, color: 0x5F8F4E)
    }

    /// The road, the poplars, the signpost, the gate and the four friends (near space).
    static func roadNear(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        Kit.ribbon(&context, nearX: 620, nearY: Hv + 280, nearWidth: 520, farX: 705, farY: Hv + 3, farWidth: 10, stops: roadStops())
        // Two wheel ruts fading up the road.
        let ruts: Path = Art.svg("M-34,0 C-20,-50 6,-104 28,-150 M34,0 C40,-50 44,-104 40,-150")
        let moved: Path = ruts.applying(CGAffineTransform(translationX: 650, y: Hv + 190))
        Art.stroke(&context, moved, Art.color(0xC4A878, 0.5), width: 4)

        // Poplars along the road, smaller with distance.
        poplar(&context, x: 648, baseY: Hv + 8, height: 58, seed: 14)
        poplar(&context, x: 724, baseY: Hv + 10, height: 70, seed: 15)
        poplar(&context, x: 626, baseY: Hv + 18, height: 96, seed: 12)
        poplar(&context, x: 600, baseY: Hv + 32, height: 150, seed: 11)
        poplar(&context, x: 556, baseY: Hv + 54, height: 228, seed: 10)

        // The blank finger post and the farm gate with its tall post.
        Kit.signpost(&context, cx: 782, baseY: Hv + 52, height: 128, color: 0x8A6A4A, boards: 2)
        Kit.fence(&context, x0: 856, x1: 900, baseY: Hv + 84, height: 48, color: 0x9A7A56)
        let post: Path = Art.rect(845, Hv + 12, 13, 74, radius: 3)
        Kit.solid(&context, post, Art.color(0x8A6A4A), light: 0.28, shade: 0.24)
        Art.group(&context, x: 852, y: Hv + 13, scale: 0.85) { g in
            rooster(&g, crowing: true, look: CGPoint(x: -0.4, y: 0))
        }

        // The Cat, a step behind.
        Kit.shadow(&context, 538, Hv + 94, width: 80)
        Art.group(&context, x: 538, y: Hv + 94, scale: 0.8, scaleX: -1) { g in
            cat(&g, pose: .walk, mood: .calm, look: CGPoint(x: -0.4, y: 0), mirrored: true)
        }
        // The Donkey, walking toward the town.
        Kit.shadow(&context, 665, Hv + 86, width: 170)
        Art.group(&context, x: 668, y: Hv + 86, scale: 0.95, scaleX: -1) { g in
            donkey(&g, pose: .walk, mood: .happy, look: CGPoint(x: -0.5, y: -0.1), mirrored: true)
        }
        // The Dog beside him, tongue out.
        Kit.shadow(&context, 762, Hv + 104, width: 120)
        Art.group(&context, x: 764, y: Hv + 104, scale: 0.8, scaleX: -1) { g in
            dog(&g, pose: .walk, mood: .happy, look: CGPoint(x: 0.4, y: -0.4), mirrored: true, puffing: true)
        }
    }
}

// MARK: - scene-forest

extension BremenArt {
    /// scene-forest: a pale evening at the edge of the forest. The broad old oak on the
    /// trailing side with the Rooster at its very top and the Cat on a bough; the Donkey and
    /// the Dog lying at its foot; one tiny yellow light far off among the trunks.
    static func forestScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st: Kit.Stage = Kit.stage(size, ground: 150)
        let light: Kit.Light = dusk()
        let H: CGFloat = st.H
        let far: CGFloat = st.far
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.cloud(&context, 250, H * 0.3, scale: 0.6, color: Art.color(0xFFFFFF, 0.45))
        Kit.cloud(&context, 120, H * 0.52, scale: 0.4, color: Art.color(0xFFF3E4, 0.5))

        // The far plane: flat open fields fading to the left, a low line of trees.
        let rise: Path = Kit.ridge(width: 892, y: H - 5 * far, amp: 4 * far, seed: 3, bottom: H + 6)
        Art.fill(&context, rise, light.far)
        Kit.farTrees(&context, x0: 0, x1: 470, baseY: H + 1, height: 15 * far, count: 20, color: light.far, seed: 8)
        Kit.birds(&context, 300, H - 54 * far, scale: far, color: Art.color(0x8A93A8, 0.8))
        ArtStyle.atmosphere(&context, width: 892, top: H - 70 * far, bottom: H + 6, color: light.haze, alpha: 0.32)

        let fields: Kit.Stops = [(Art.color(0xBFCB9C), 0), (Art.color(0x8FA878), 0.45), (Art.color(0x5A7656), 1)]
        Kit.ground(&context, width: 892, top: H, bottom: size.height, stops: fields)
        Art.fill(&context, Art.rect(0, H + 4 * far, 440, 8 * far), Art.color(0xE2CF8A, 0.7))

        Kit.designSpace(&context, st) { v in
            let Hv: CGFloat = st.Hv
            // Sheaves standing in the stubble on the leading side.
            Kit.sheaf(&v, cx: 138, baseY: Hv + 44, height: 36, color: 0xD9BE6E)
            Kit.sheaf(&v, cx: 176, baseY: Hv + 50, height: 40, color: 0xD9BE6E)
            Kit.sheaf(&v, cx: 318, baseY: Hv + 34, height: 28, color: 0xD9BE6E)
            // The dark edge of the forest, and deep among its trunks one small yellow light.
            let wood: CGFloat = min(250, Hv * 0.5)
            forestEdge(&v, x0: 458, x1: 910, baseY: Hv + 6, height: wood, seed: 31)
            Art.glow(&v, 548, Hv - 22, 34, Art.color(0xFFD25A), alpha: 0.5)
            Kit.lamp(&v, cx: 548, cy: Hv - 22, radius: 3.4, color: 0xFFD25A)
            Kit.nearSpace(&v, st, anchorX: 700) { n in
                forestNear(&n, st)
            }
        }
        groundCover(&context, st, dark: 0x3F6650, lit: 0xA9C48A, petal: 0xF4E9C4)
        // Brown leaves on the forest floor, on the trailing side.
        let floorTop: CGFloat = H + st.depth * 0.3
        let leafBed = CGRect(x: 470, y: floorTop, width: 422, height: max(1, size.height - floorTop))
        Kit.pebbles(&context, in: leafBed, count: 26, seed: 19, color: 0xB07A42)
        Kit.cornerLeaves(&context, size: size, corner: 2, color: Art.color(0x355A48), scale: 0.85 * st.grow, seed: 5)
        Kit.cornerLeaves(&context, size: size, corner: 3, color: Art.color(0x2F4F40), scale: 0.8 * st.grow, seed: 7)
        ArtStyle.finish(&context, size)
    }

    /// The oak and the four friends (near space of scene-forest).
    static func forestNear(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        let baseY: CGFloat = Hv + 50
        let treeH: CGFloat = min(430, Hv - 20)
        let ry: CGFloat = treeH * 0.3
        let cy: CGFloat = baseY - treeH + ry
        let greens: Kit.Greens = duskGreens()
        let barkHex: UInt32 = 0x7E6E5E
        Kit.greatTree(&context, x: 772, baseY: baseY, height: treeH, spread: 400, palette: greens, bark: barkHex, seed: 7)
        // A second layer of leaves, so the hero crown is full.
        let more: [Kit.Blob] = Kit.treeRow(768, cy + ry * 0.05, half: 176, r: ry * 0.5, arch: ry * 0.16)
        Kit.canopy(&context, more, seed: 29, palette: greens, density: 1.6)

        // The Cat's bough.
        let boughY: CGFloat = baseY - treeH * 0.37
        var bough = Path()
        Kit.treeBough(&bough, 750, boughY + 6, 578, boughY - 6, 26, 9, bend: -8)
        Kit.solid(&context, bough, Kit.treeTone(barkHex, 0.86), light: 0.2, shade: 0.24)
        Art.stroke(&context, Art.line(736, boughY - 6, 590, boughY - 11), Art.color(0xD9C2A0, 0.55), width: 1.6)
        let twig: [Kit.Blob] = [(578, boughY - 12, 24), (606, boughY - 26, 17), (560, boughY + 6, 15)]
        Kit.canopy(&context, twig, seed: 33, palette: greens, density: 1.8)
        ArtStyle.contactShadow(&context, 646, boughY - 6, 30, 4, alpha: 0.24)
        Art.group(&context, x: 642, y: boughY - 8, scale: 0.78) { g in
            cat(&g, pose: .sit, mood: .calm, look: CGPoint(x: -0.6, y: 0.2))
        }

        // The Rooster at the very top, looking toward the light.
        let topY: CGFloat = baseY - treeH + ry * 0.1 + 6
        Art.group(&context, x: 738, y: topY, scale: 0.75) { g in
            rooster(&g, crowing: false, look: CGPoint(x: -0.8, y: 0.2))
        }

        // The Donkey and the Dog lying at the foot of the oak.
        Kit.shadow(&context, 685, baseY + 12, width: 200)
        Art.group(&context, x: 690, y: baseY + 10, scale: 0.95) { g in
            donkey(&g, pose: .sleep)
        }
        Kit.shadow(&context, 588, baseY + 42, width: 140)
        Art.group(&context, x: 590, y: baseY + 40, scale: 0.8) { g in
            dog(&g, pose: .sleep)
        }
        // Ferns at the roots.
        Kit.grassTuft(&context, x: 838, baseY: baseY + 26, height: 46, color: 0x3F6650, seed: 3)
        Kit.grassTuft(&context, x: 716, baseY: baseY + 8, height: 26, color: 0x4F7A5A, seed: 8)
    }
}

// MARK: - scene-window

extension BremenArt {
    /// scene-window: the timber house in the forest at pale dusk, its small-paned window
    /// glowing gold; beside the wall the tower of four, all facing the window, mid-song.
    static func windowScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st: Kit.Stage = Kit.stage(size, ground: 150)
        let light: Kit.Light = dusk()
        let H: CGFloat = st.H
        let far: CGFloat = st.far
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.cloud(&context, 230, H * 0.34, scale: 0.55, color: Art.color(0xFFFFFF, 0.45))
        Kit.farTrees(&context, x0: 0, x1: 470, baseY: H + 1, height: 24 * far, count: 15, color: light.far, seed: 12)
        ArtStyle.atmosphere(&context, width: 892, top: H - 70 * far, bottom: H + 6, color: light.haze, alpha: 0.34)
        Kit.ground(&context, width: 892, top: H, bottom: size.height, stops: forestFloorStops())

        Kit.designSpace(&context, st) { v in
            let Hv: CGFloat = st.Hv
            // Thin birch tops at the two edges of the leading pane, soft with distance.
            let tallBirch: CGFloat = min(300, Hv * 0.6)
            Art.layer(&v, opacity: 0.7) { b in
                Kit.birch(&b, x: 18, baseY: Hv + 28, height: tallBirch, palette: duskGreens(), seed: 2)
                Kit.birch(&b, x: 424, baseY: Hv + 20, height: tallBirch * 0.86, palette: duskGreens(), seed: 6)
            }
            let wood: CGFloat = min(270, Hv * 0.55)
            forestEdge(&v, x0: 446, x1: 910, baseY: Hv + 6, height: wood, seed: 17)
            Kit.nearSpace(&v, st, anchorX: 560) { n in
                windowNear(&n, st)
            }
        }
        groundCover(&context, st, dark: 0x3F6650, lit: 0xA9C48A, petal: 0xF4E9C4)
        let leafTop: CGFloat = H + st.depth * 0.35
        let leafBed = CGRect(x: 40, y: leafTop, width: 560, height: max(1, size.height - leafTop))
        Kit.pebbles(&context, in: leafBed, count: 24, seed: 23, color: 0xB07A42)
        Kit.cornerLeaves(&context, size: size, corner: 2, color: Art.color(0x2F4F40), scale: 0.95 * st.grow, seed: 9)
        Kit.cornerLeaves(&context, size: size, corner: 3, color: Art.color(0x2F4F40), scale: 0.7 * st.grow, seed: 11)
        ArtStyle.finish(&context, size)
    }

    /// The house and the tower of four (near space of scene-window).
    static func windowNear(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        let houseBase: CGFloat = Hv + 40
        let houseX: CGFloat = 790
        let glowColor: Color = Art.color(0xFFCB6B)
        timberHouse(&context, cx: houseX, baseY: houseBase, lit: true)
        // A little straw by the wall, and ferns at the corner of the house.
        strawHeap(&context, cx: 872, baseY: houseBase + 22, width: 92, height: 30)
        Kit.grassTuft(&context, x: 662, baseY: houseBase + 8, height: 30, color: 0x3F6650, seed: 5)
        // The window's light in the air in front of the wall.
        let wx: CGFloat = houseX + windowDX
        let wy: CGFloat = houseBase + windowDY
        Art.glow(&context, wx - 36, wy + 10, 150, glowColor, alpha: 0.22)

        // The tower of four, facing the window.
        Art.group(&context, x: 535, y: Hv + 60, scale: 1.1, scaleX: -1) { g in
            tower(&g, mirrored: true, singing: true)
        }
        // Their faces catch the gold.
        Art.glow(&context, 628, Hv - 84, 70, glowColor, alpha: 0.16)
        Art.glow(&context, 580, Hv - 190, 60, glowColor, alpha: 0.1)
        Kit.grassTuft(&context, x: 468, baseY: Hv + 86, height: 40, color: 0x355A48, seed: 2)
    }
}

// MARK: - scene-home

extension BremenArt {
    /// scene-home: a fresh morning in the yard of the timber house. The Donkey on his straw,
    /// the Dog by the open door, the Cat on the window sill in the sun, the Rooster crowing
    /// on the roof ridge, a thin thread of smoke from the chimney.
    static func homeScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st: Kit.Stage = Kit.stage(size, ground: 160)
        let light: Kit.Light = morning()
        let H: CGFloat = st.H
        let far: CGFloat = st.far
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.sun(&context, 112, H - 62 * far, 22 * far, light: light)
        Kit.cloud(&context, 330, H * 0.2, scale: 0.6, color: Art.color(0xFFFFFF, 0.6))
        Kit.cloud(&context, 560, H * 0.36, scale: 0.7, color: Art.color(0xFFFFFF, 0.7))

        // The far plane: sunlit forest tops.
        Kit.farTrees(&context, x0: 0, x1: 892, baseY: H + 2, height: 30 * far, count: 30, color: Art.color(0xA9CDA4), seed: 4)
        Kit.farTrees(&context, x0: 150, x1: 470, baseY: H + 2, height: 20 * far, count: 12, color: Art.color(0x93C08C), seed: 14)
        Kit.birds(&context, 250, H - 70 * far, scale: far, color: Art.color(0x7C9AA8, 0.8))
        ArtStyle.atmosphere(&context, width: 892, top: H - 70 * far, bottom: H + 4, color: light.haze, alpha: 0.3)

        let yard: Kit.Stops = [(Art.color(0xC6DF8E), 0), (Art.color(0x9CC66A), 0.45), (Art.color(0x6FA052), 1)]
        Kit.ground(&context, width: 892, top: H, bottom: size.height, stops: yard)

        Kit.designSpace(&context, st) { v in
            let Hv: CGFloat = st.Hv
            // The yard fence and a bush on the leading side, low.
            Kit.fence(&v, x0: 24, x1: 404, baseY: Hv + 36, height: 30, color: 0xA98A62)
            Kit.bush(&v, x: 78, baseY: Hv + 44, width: 76, palette: Kit.springGreens(), seed: 2)
            Kit.sack(&v, cx: 330, baseY: Hv + 70, width: 36, height: 42)
            Kit.sack(&v, cx: 362, baseY: Hv + 76, width: 30, height: 34, color: 0xD9C49A)
            let wood: CGFloat = min(230, Hv * 0.5)
            forestEdge(&v, x0: 600, x1: 910, baseY: Hv + 4, height: wood, seed: 23)
            Kit.nearSpace(&v, st, anchorX: 640) { n in
                homeNear(&n, st)
            }
        }
        groundCover(&context, st, dark: 0x4F8A4A, lit: 0xD4EA94, petal: 0xFFE9A0)
        Kit.cornerLeaves(&context, size: size, corner: 2, color: Art.color(0x3F6B45), scale: 0.9 * st.grow, seed: 13)
        ArtStyle.finish(&context, size)
    }

    /// The house by morning and the four at ease (near space of scene-home).
    static func homeNear(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        let houseBase: CGFloat = Hv + 36
        let houseX: CGFloat = 760
        timberHouse(&context, cx: houseX, baseY: houseBase, lit: false, smoke: true)
        let bed = CGRect(x: 640, y: houseBase + 2, width: 80, height: 16)
        Kit.flowers(&context, in: bed, count: 8, seed: 6, petal: 0xFFD25A, heart: 0xC8452C)

        // The Rooster on the roof ridge, crowing at the morning.
        let ridgeY: CGFloat = houseBase - houseWall - houseRoof - 2
        Art.group(&context, x: 716, y: ridgeY, scale: 0.8) { g in
            rooster(&g, crowing: true, look: CGPoint(x: -0.3, y: -0.3))
        }
        // The Cat on the window sill, dozing in the sun.
        let sillX: CGFloat = houseX + windowDX + 6
        let sillY: CGFloat = houseBase + windowDY + 29
        Art.group(&context, x: sillX, y: sillY, scale: 0.6) { g in
            cat(&g, pose: .sit, mood: .sleepy)
        }
        // The Dog sitting by the open door.
        Kit.shadow(&context, 822, houseBase + 16, width: 90)
        Art.group(&context, x: 820, y: houseBase + 16, scale: 0.85) { g in
            dog(&g, pose: .sit, mood: .happy, look: CGPoint(x: -0.6, y: 0.1))
        }
        // The Donkey on his heap of golden straw.
        strawHeap(&context, cx: 548, baseY: Hv + 84, width: 250, height: 44)
        Art.group(&context, x: 544, y: Hv + 68, scale: 1.0, scaleX: -1) { g in
            donkey(&g, pose: .sleep, mirrored: true)
        }
        // Straw in front of him, so he lies in it.
        var front = Path()
        let blades: [(CGFloat, CGFloat)] = [(470, -10), (498, 8), (530, -6), (566, 10), (600, -8), (630, 6)]
        for blade in blades {
            front.move(to: CGPoint(x: blade.0, y: Hv + 86))
            front.addLine(to: CGPoint(x: blade.0 + blade.1, y: Hv + 66))
        }
        Art.stroke(&context, front, Art.color(0xF6DA7C), width: 2.2)
    }
}
