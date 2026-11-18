import SwiftUI
import OmramoCore

/// Concept art for "The Old Man Who Moved the Mountains", drawn in code (round 5; composed
/// from the shared kit).
///
/// The cast, the palette and the shared parts (the two mountains, the farmhouse, the willow,
/// the carrying pole) live in `MountainsArt+Cast.swift`; the four folded-phone compositions in
/// `MountainsArt+Folded.swift`; the tap-to-see pictures, the portraits, the faces and the
/// cover in `MountainsArt+Pictures.swift`. This file holds the entry point and the four
/// unfolded scenes. The Lord of the Sky and the two giants appear in no picture.
enum MountainsArt {
    /// Draws the picture called `name`. Returns false for a name this story does not have.
    static func paint(_ name: String, role: ArtRole, in context: inout GraphicsContext, size: CGSize) -> Bool {
        guard size.width > 0, size.height > 0 else { return false }
        switch (name, role) {
        case ("scene-mountains", .sceneUnfolded): mountainsScene(&context, size)
        case ("scene-mountains", .sceneFolded): mountainsFolded(&context, size)
        case ("scene-digging", .sceneUnfolded): diggingScene(&context, size)
        case ("scene-digging", .sceneFolded): diggingFolded(&context, size)
        case ("scene-river-bend", .sceneUnfolded): riverBendScene(&context, size)
        case ("scene-river-bend", .sceneFolded): riverBendFolded(&context, size)
        case ("scene-open-road", .sceneUnfolded): openRoadScene(&context, size)
        case ("scene-open-road", .sceneFolded): openRoadFolded(&context, size)
        case ("see-north-china-mountains", .picture): northChinaMountainsPicture(&context, size)
        case ("see-big-family", .picture): bigFamilyPicture(&context, size)
        case ("see-carrying-pole", .picture): carryingPolePicture(&context, size)
        case ("char-yu-gong", .portrait): yuGongPortrait(&context, size)
        case ("char-zhi-sou", .portrait): zhiSouPortrait(&context, size)
        case ("face-yu-gong", .face): yuGongFace(&context, size)
        case ("face-wife", .face): wifeFace(&context, size)
        case ("face-boy", .face): boyFace(&context, size)
        case ("face-zhi-sou", .face): zhiSouFace(&context, size)
        case ("cover", .cover): cover(&context, size)
        default:
            return false
        }
        return true
    }
}

// MARK: - scene-mountains (unfolded)

extension MountainsArt {
    /// scene-mountains: Taihang and Wangwu fill the trailing side as high as the clouds; low
    /// in front of them the little farmhouse, and Yu Gong outside his door looking up. The
    /// path to market has to bend away round the mountains. The leading side is calm sky over
    /// far pale ranges.
    static func mountainsScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        let h = size.height
        let st = Kit.stage(size, ground: 150)
        let light = day()
        let far: CGFloat = st.far

        // Far plane.
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.sun(&context, 118, st.H - 78 * far, 30 * far, light: light)
        Kit.cloud(&context, 330, st.H * 0.2 + 44, scale: 0.9 * far, color: Art.color(0xFFFFFF, 0.7))
        farRanges(&context, width: 470, horizon: st.H, scale: far, light: light)
        let peakH: CGFloat = min(st.H * 0.78, 520 * far)
        let peakW: CGFloat = min(peakH * 1.2, 450)
        twoMountains(
            &context, width: w, baseY: st.H + 4, height: peakH,
            taihangX: 612, wangwuX: 792, peakWidth: peakW, light: light
        )
        Kit.birds(&context, 236, st.H - 58 * far, scale: far, color: Art.color(0x6F8E9A))
        let hazyWall = Art.color(0xD9C9A0)
        let hazyRoof = Art.color(0xC4B488)
        Kit.farHouse(&context, cx: 300, baseY: st.H + 3, width: 26 * far, height: 15 * far, wall: hazyWall, roof: hazyRoof)
        Kit.farTrees(&context, x0: 316, x1: 400, baseY: st.H + 3, height: 20 * far, count: 4, color: Art.color(0xA9BE9A), seed: 6)

        // The plain: yellow earth, strips of young millet, the path that goes the long way.
        Kit.ground(&context, width: w, top: st.H, bottom: h, stops: loess())
        Kit.grainField(&context, x0: 0, x1: 270, baseY: st.H + 22 * far, height: 13 * far, color: milletGreen, seed: 3)
        Kit.grainField(&context, x0: 330, x1: 600, baseY: st.H + 16 * far, height: 10 * far, color: milletGreen, seed: 14)
        let nearWidth: CGFloat = 120 * st.grow
        Kit.ribbon(
            &context, nearX: 500, nearY: h, nearWidth: nearWidth,
            farX: 150, farY: st.H + 7, farWidth: 6, stops: pathStops()
        )
        foreground(&context, st, grass: 0xB9A050, flowers: 0xFFF2D0)

        mountainsHome(&context, st)

        // Near plane: a bough of the jujube tree in the top trailing corner.
        Kit.cornerLeaves(&context, size: size, corner: 1, color: Art.color(0x3F6B58), scale: 1.25 * st.grow, seed: 4)
        ArtStyle.finish(&context, size)
    }

    /// The farmhouse, its yard and Yu Gong at the door, on the trailing side.
    static func mountainsHome(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        Kit.designSpace(&context, st) { v in
            Kit.nearSpace(&v, st) { n in
                // The packed-earth yard.
                let yard = Art.ellipse(760, Hv + 92, 190, 34)
                Art.fill(&n, yard, Art.color(0xF0DDA6, 0.7))
                peachTree(&n, x: 608, baseY: Hv + 52, height: 170, seed: 7)
                yardWall(&n, x0: 540, x1: 664, baseY: Hv + 76, height: 26)
                farmhouse(&n, x: 772, baseY: Hv + 62, scale: 1)
                Kit.tool(&n, .hoe, x: 872, baseY: Hv + 66, height: 92, wood: 0x8A5A3A, metal: 0x8E979E)
                basketsSetDown(&n, x: 838, baseY: Hv + 92, scale: 0.7)
                Kit.grassTuft(&n, x: 548, baseY: Hv + 82, height: 26, color: 0x93AC64, seed: 5)
                Kit.grassTuft(&n, x: 660, baseY: Hv + 80, height: 20, color: 0x7E9A5A, seed: 9)
                // Yu Gong, small against the mountains, his head tipped back to see their tops.
                Kit.shadow(&n, 688, Hv + 100, width: 52)
                Art.group(&n, x: 688, y: Hv + 100, scale: 0.76) { p in
                    yuGong(&p, pose: .stand, look: CGPoint(x: -0.5, y: -0.9), mouth: .smile, nod: 0.22)
                }
                Kit.pebbles(&n, in: CGRect(x: 560, y: Hv + 96, width: 300, height: 30), count: 9, seed: 13, color: 0xB8A680)
            }
        }
    }
}

// MARK: - scene-digging (unfolded)

extension MountainsArt {
    /// scene-digging: the family at the foot of the mountain. The sons break rock and the
    /// grandchildren dig on the trailing side; along the path walk the carriers, each with a
    /// pole and two baskets — Yu Gong in front, the little boy just behind him with a basket
    /// his own size, a son far ahead on the way to the sea.
    static func diggingScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        let h = size.height
        let st = Kit.stage(size, ground: 160)
        let light = day()
        let far: CGFloat = st.far

        // Far plane: sky, far ranges under the words, the huge pale foot of the mountain.
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.sun(&context, 96, st.H - 62 * far, 28 * far, light: light)
        Kit.cloud(&context, 270, st.H * 0.22 + 40, scale: 0.8 * far, color: Art.color(0xFFFFFF, 0.7))
        farRanges(&context, width: 470, horizon: st.H, scale: far, light: light)
        let peakH: CGFloat = st.H * 1.12
        let peakW: CGFloat = min(720, peakH * 1.3)
        greatPeak(&context, cx: 742, baseY: st.H + 4, width: peakW, height: peakH, color: peakBack, seed: 5, pines: true)
        mountainAir(&context, width: w, baseY: st.H + 4, height: peakH * 0.8, light: light)

        Kit.ground(&context, width: w, top: st.H, bottom: h, stops: loess())
        Kit.grainField(&context, x0: 0, x1: 300, baseY: st.H + 18 * far, height: 11 * far, color: milletGreen, seed: 5)
        foreground(&context, st, grass: 0xB9A050, flowers: 0xFFE9A8)

        let Hv: CGFloat = st.Hv
        Kit.designSpace(&context, st) { v in
            Kit.nearSpace(&v, st) { n in
                // The path to the sea: it runs out of the picture on both sides.
                var path = Path()
                path.move(to: CGPoint(x: -700, y: Hv + 40))
                path.addCurve(to: CGPoint(x: 560, y: Hv + 96), control1: CGPoint(x: -200, y: Hv + 44), control2: CGPoint(x: 300, y: Hv + 70))
                path.addLine(to: CGPoint(x: 900, y: Hv + 92))
                path.addLine(to: CGPoint(x: 900, y: Hv + 136))
                path.addLine(to: CGPoint(x: 560, y: Hv + 134))
                path.addCurve(to: CGPoint(x: -700, y: Hv + 62), control1: CGPoint(x: 300, y: Hv + 104), control2: CGPoint(x: -200, y: Hv + 70))
                path.closeSubpath()
                Art.fillLinear(&n, path, pathStops(), from: CGPoint(x: 0, y: Hv + 40), to: CGPoint(x: 0, y: Hv + 136))
                diggingCrew(&n, Hv)
                diggingWalkers(&n, Hv)
            }
        }

        // Near plane: a dark boulder and grass cropped by the trailing bottom corner.
        Kit.rock(&context, cx: w - 4, baseY: h + 14, width: 130 * st.grow, height: 64 * st.grow, color: 0x6E7F86, seed: 6)
        Kit.grassTuft(&context, x: w - 84 * st.grow, baseY: h + 8, height: 50 * st.grow, color: 0x5E8058, seed: 21)
        ArtStyle.finish(&context, size)
    }

    /// The diggers at the mountain's foot (middle plane, trailing side), in near-space units.
    static func diggingCrew(_ n: inout GraphicsContext, _ Hv: CGFloat) {
        // The cut they have made: fresh earth and broken rock.
        let earth: Kit.Stops = [(Art.color(0xB98A58), 0), (Art.color(dugEarth), 1)]
        Kit.mound(&n, x0: 636, x1: 790, baseY: Hv + 42, height: 20, bottom: Hv + 48, stops: earth, crest: 0.4)
        Kit.rock(&n, cx: 842, baseY: Hv + 34, width: 120, height: 62, color: 0xA9B6B8, seed: 2)
        Kit.rock(&n, cx: 772, baseY: Hv + 40, width: 58, height: 30, color: 0xB4BFC0, seed: 7)
        Kit.heap(&n, cx: 800, baseY: Hv + 56, width: 50, count: 6, color: 0xB9BDB6, seed: 3)
        let s: CGFloat = 0.6
        // A son swings his hoe at the rock (he faces it, to the right).
        Kit.shadow(&n, 716, Hv + 50, width: 44)
        Art.group(&n, x: 716, y: Hv + 50, scale: s, scaleX: -1) { p in
            digger(&p, grownLook(0), mirrored: true)
        }
        // His brother bends to lift a stone.
        Kit.shadow(&n, 866, Hv + 62, width: 44)
        Art.group(&n, x: 866, y: Hv + 62, scale: s) { p in
            kin(&p, grownLook(1), pose: .bow, look: CGPoint(x: -0.4, y: 0.6))
        }
        // The grandchildren dig the earth.
        Kit.shadow(&n, 668, Hv + 64, width: 34)
        Art.group(&n, x: 668, y: Hv + 64, scale: s, scaleX: -1) { p in
            kin(&p, grandchildLook(0), pose: .kneel, look: CGPoint(x: -0.4, y: 0.7), mouth: .grin, mirrored: true)
        }
        Kit.tool(&n, .spade, x: 700, baseY: Hv + 66, height: 40, wood: 0x8A5A3A, metal: 0x8E979E)
        Kit.shadow(&n, 780, Hv + 74, width: 34)
        Art.group(&n, x: 780, y: Hv + 74, scale: s) { p in
            kin(&p, grandchildLook(1), pose: .kneel, look: CGPoint(x: -0.3, y: 0.7))
        }
        Kit.basket(&n, cx: 748, baseY: Hv + 76, width: 24, height: 17, color: wicker)
        earthLoad(&n, x: 748, rimY: Hv + 59, width: 24)
        // Dust from the digging.
        let dust = Art.color(0xF3E3B4)
        Art.glow(&n, 742, Hv + 30, 30, dust, alpha: 0.5)
        Art.glow(&n, 812, Hv + 20, 24, dust, alpha: 0.4)
    }

    /// The carriers on the path, in near-space units.
    static func diggingWalkers(_ n: inout GraphicsContext, _ Hv: CGFloat) {
        // Far ahead, tiny: somebody already well on the way.
        Art.group(&n, x: 120, y: Hv + 58, scale: 0.3, opacity: 0.85) { p in
            loadedPole(&p, cx: -4, cy: -108, length: 150, drop: 84)
            kin(&p, grownLook(0), pose: .walk)
        }
        // A son, ahead on the leading side, low under the words.
        Kit.shadow(&n, 318, Hv + 82, width: 46)
        Art.group(&n, x: 318, y: Hv + 82, scale: 0.6) { p in
            loadedPole(&p, cx: -4, cy: -108, length: 150, drop: 84)
            kin(&p, grownLook(1), pose: .walk, look: CGPoint(x: -0.4, y: 0))
        }
        // Yu Gong in front on the trailing side.
        Kit.shadow(&n, 566, Hv + 112, width: 70)
        Art.group(&n, x: 566, y: Hv + 112) { p in
            yuGongCarrying(&p, walking: true, look: CGPoint(x: -0.4, y: 0), mouth: .smile)
        }
        // The little boy just behind him, looking up, a basket his own size in his arms.
        Kit.shadow(&n, 708, Hv + 114, width: 44)
        Art.group(&n, x: 708, y: Hv + 114) { p in
            boy(&p, pose: .carry, look: CGPoint(x: -0.7, y: -0.6), mouth: .grin, basket: true)
        }
    }
}

// MARK: - scene-river-bend (unfolded)

extension MountainsArt {
    /// scene-river-bend: the wide, silty river curves round a sandy bank. Under the willow
    /// Zhi Sou sits on his stool and laughs, one hand up; Yu Gong has set his baskets down
    /// and stands calm on the path, facing him, rubbing his sore shoulder. Far off stand the
    /// two grey peaks; the leading side is sky and far water.
    static func riverBendScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        let h = size.height
        let st = Kit.stage(size, ground: 170)
        let light = day()
        let far: CGFloat = st.far

        // Far plane: the two peaks, small with distance, behind low hills.
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.sun(&context, 110, st.H - 66 * far, 30 * far, light: light)
        Kit.cloud(&context, 300, st.H * 0.22 + 36, scale: 0.85 * far, color: Art.color(0xFFFFFF, 0.7))
        greatPeak(&context, cx: 664, baseY: st.H, width: 150 * far, height: 104 * far, color: peakBack, seed: 9, pines: false)
        greatPeak(&context, cx: 584, baseY: st.H, width: 168 * far, height: 124 * far, color: peakFront, seed: 3, pines: false)
        mountainAir(&context, width: w, baseY: st.H, height: 124 * far, light: light)
        Kit.ranges(&context, width: w, horizon: st.H, scale: far * 0.8, light: light, mountains: false, seed: 7)
        Kit.birds(&context, 230, st.H - 52 * far, scale: far, color: Art.color(0x6F8E9A))

        // The river, yellow-brown with silt.
        Kit.water(&context, width: w, top: st.H, bottom: h, stops: silt(), light: light, ripples: 46, seed: 31)
        Kit.glints(&context, x: 110, top: st.H, depth: st.depth, color: Art.color(0xFFF6D8, 0.7), count: 26)
        riverSandbar(&context, x: 214, y: st.H + 30 * far, width: 150 * far, reeds: 7)
        riverSandbar(&context, x: 392, y: st.H + 14 * far, width: 84 * far, reeds: 4)

        riverBendBank(&context, st)

        // Near plane: dark reeds cropped by the bottom corners.
        Kit.reeds(&context, x: 38, baseY: h + 14, count: 9, height: 110 * st.grow, seed: 41, color: 0x55784E)
        Kit.reeds(&context, x: w - 30, baseY: h + 16, count: 8, height: 96 * st.grow, seed: 43, color: 0x4E6E4A)
        if st.tall > 0.25 {
            Kit.reeds(&context, x: 150, baseY: h + 10, count: 7, height: 150, seed: 47, color: 0x5E8254)
            Kit.rippleMarks(&context, x0: 0, x1: 430, y0: st.H + st.depth * 0.5, y1: h, count: 30, seed: 9, color: Color.white)
        }
        ArtStyle.finish(&context, size)
    }

    /// A low sandbar out in the river with a tuft of reeds.
    static func riverSandbar(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, width: CGFloat, reeds count: Int) {
        let half: CGFloat = width / 2
        var bar = Path()
        bar.move(to: CGPoint(x: x - half, y: y + 2))
        bar.addQuadCurve(to: CGPoint(x: x + half, y: y + 2), control: CGPoint(x: x - half * 0.2, y: y - width * 0.1))
        bar.addQuadCurve(to: CGPoint(x: x - half, y: y + 2), control: CGPoint(x: x, y: y + width * 0.06))
        bar.closeSubpath()
        Art.fill(&context, Art.ellipse(x + 3, y + 5, half, max(2, width * 0.03)), ArtStyle.coolShade.opacity(0.14))
        Kit.solid(&context, bar, Art.color(0xEEDDA6), light: 0.3, shade: 0.16)
        Kit.reeds(&context, x: x + half * 0.3, baseY: y + 1, count: count, height: width * 0.24, seed: 27, color: 0x7FA066)
        Kit.ripples(&context, x, y + 6, width * 1.05, count: 2, color: Color.white, opacity: 0.4)
    }

    /// The near bank with the willow, Zhi Sou and Yu Gong, on the trailing side.
    static func riverBendBank(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        Kit.designSpace(&context, st) { v in
            Kit.nearSpace(&v, st) { n in
                // The bank the river bends round: sandy at the water's edge.
                var bank = Path()
                bank.move(to: CGPoint(x: 900, y: Hv + 8))
                bank.addCurve(to: CGPoint(x: 600, y: Hv + 44), control1: CGPoint(x: 800, y: Hv + 8), control2: CGPoint(x: 680, y: Hv + 22))
                bank.addCurve(to: CGPoint(x: 430, y: Hv + 200), control1: CGPoint(x: 530, y: Hv + 64), control2: CGPoint(x: 470, y: Hv + 130))
                bank.addLine(to: CGPoint(x: 380, y: Hv + 1000))
                bank.addLine(to: CGPoint(x: 900, y: Hv + 1000))
                bank.closeSubpath()
                let sand = bank.applying(CGAffineTransform(translationX: -14, y: 5))
                Art.fill(&n, sand, Art.color(0xF3E6B8))
                Art.fillLinear(&n, bank, loess(), from: CGPoint(x: 0, y: Hv + 8), to: CGPoint(x: 0, y: Hv + 260))
                Art.clipped(&n, to: bank) { c in
                    ArtStyle.tooth(&c, in: CGRect(x: 430, y: Hv + 8, width: 470, height: 240), seed: 19, alpha: 0.07)
                    // The trodden path along the bank.
                    Art.fill(&c, Art.ellipse(720, Hv + 118, 260, 24), Art.color(0xF3E3B4, 0.75))
                }
                Kit.reeds(&n, x: 612, baseY: Hv + 46, count: 7, height: 46, seed: 3, color: 0x7FA066)
                Kit.reeds(&n, x: 512, baseY: Hv + 100, count: 8, height: 62, seed: 5, color: 0x6F9460)
                Kit.reeds(&n, x: 462, baseY: Hv + 166, count: 9, height: 80, seed: 8, color: 0x628858)
                Kit.grass(&n, in: CGRect(x: 640, y: Hv + 40, width: 250, height: 50), count: 18, seed: 23, color: Art.color(0x9DB58A), height: 8)

                willow(&n, x: 806, baseY: Hv + 40, height: 340, seed: 4)
                // The cool shade under the willow.
                Art.fill(&n, Art.ellipse(800, Hv + 92, 110, 20), ArtStyle.coolShade.opacity(0.1))

                // Zhi Sou on his stool, laughing.
                Art.group(&n, x: 776, y: Hv + 96, scale: 0.98) { p in
                    zhiSouSeated(&p, laughing: true)
                }
                // Yu Gong, calm, facing him.
                Kit.shadow(&n, 606, Hv + 112, width: 60)
                Art.group(&n, x: 606, y: Hv + 112, scaleX: -1) { p in
                    yuGongResting(&p, look: CGPoint(x: -0.6, y: -0.1), mirrored: true)
                }
                basketsSetDown(&n, x: 690, baseY: Hv + 138, scale: 0.8)
                Kit.pebbles(&n, in: CGRect(x: 520, y: Hv + 120, width: 330, height: 40), count: 10, seed: 31, color: 0xB8A680)
                Kit.grassTuft(&n, x: 868, baseY: Hv + 132, height: 34, color: 0x7E9A5A, seed: 6)
            }
        }
    }
}

// MARK: - scene-open-road (unfolded)

extension MountainsArt {
    /// scene-open-road: morning, and the mountains are gone. Only sky, and a wide golden plain
    /// of ripe millet; a pale road runs dead straight from the farmhouse gate to the horizon.
    /// At the gate stand Yu Gong with his hoe, his wife, the family, and the little boy hopping.
    static func openRoadScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        let h = size.height
        let st = Kit.stage(size, ground: 170)
        let light = goldenMorning()
        let far: CGFloat = st.far

        // Far plane: nothing but a low, wide horizon under a huge sky.
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.sun(&context, 150, st.H - 74 * far, 36 * far, light: light)
        Kit.cloud(&context, 310, st.H * 0.2 + 40, scale: 0.8 * far, color: Art.color(0xFFFFFF, 0.75))
        Kit.cloud(&context, 650, st.H * 0.34 + 30, scale: 1.1 * far, color: Art.color(0xFFFFFF, 0.6))
        let low = Kit.ridge(width: w, y: st.H - 5 * far, amp: 5 * far, seed: 3, bottom: st.H + 4)
        Art.fill(&context, low, light.far.opacity(0.8))
        let treeColor = Art.color(0xC9C89A)
        Kit.farTrees(&context, x0: 20, x1: 420, baseY: st.H + 2, height: 12 * far, count: 7, color: treeColor, seed: 4)
        Kit.farTrees(&context, x0: 600, x1: 880, baseY: st.H + 2, height: 12 * far, count: 5, color: treeColor, seed: 9)
        ArtStyle.atmosphere(&context, width: w, top: st.H - 30 * far, bottom: st.H + 4, color: light.haze, alpha: 0.3)
        Kit.birds(&context, 560, st.H - 120 * far, scale: far, color: Art.color(0x8FA2A8))

        // The plain: ripe millet in bands, larger toward the viewer.
        Kit.ground(&context, width: w, top: st.H, bottom: h, stops: goldPlain())
        Kit.grainField(&context, x0: 0, x1: w, baseY: st.H + 12 * far, height: 8 * far, color: milletGold, seed: 2)
        Kit.grainField(&context, x0: 0, x1: w, baseY: st.H + 36 * far, height: 16 * far, color: 0xE8BE4E, seed: 6)
        Kit.grainField(&context, x0: 0, x1: w, baseY: st.H + 76 * far, height: 28 * far, color: 0xE0B040, seed: 9)
        if st.tall > 0.25 {
            let d: CGFloat = st.depth
            Kit.grainField(&context, x0: 0, x1: w, baseY: st.H + d * 0.52, height: 44, color: 0xDDAA3C, seed: 12)
            Kit.grainField(&context, x0: 0, x1: w, baseY: st.H + d * 0.78, height: 58, color: 0xD6A236, seed: 15)
        }

        openRoadGate(&context, st)

        // Near plane: dark ears of millet cropped by the bottom corners.
        Kit.crop(&context, x0: -10, x1: 150, baseY: h + 8, height: 74 * st.grow, tops: false, color: 0xB98A2C, seed: 5)
        Kit.crop(&context, x0: w - 110, x1: w + 10, baseY: h + 8, height: 60 * st.grow, tops: false, color: 0xB98A2C, seed: 7)
        ArtStyle.finish(&context, size)
    }

    /// The straight road, the gate and the family, on the trailing side.
    static func openRoadGate(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        Kit.designSpace(&context, st) { v in
            Kit.nearSpace(&v, st) { n in
                // The road: one straight wedge from the horizon to far below the frame.
                let road: [CGPoint] = [
                    Kit.pt(557, Hv + 3), Kit.pt(563, Hv + 3), Kit.pt(2231, Hv + 1200), Kit.pt(161, Hv + 1200),
                ]
                let roadShape = Art.polygon(road)
                Art.fillLinear(&n, roadShape, pathStops(), from: CGPoint(x: 0, y: Hv), to: CGPoint(x: 0, y: Hv + 240))
                Art.stroke(&n, Art.line(557, Hv + 3, 161, Hv + 1200), Color.white.opacity(0.35), width: 1.6)
                Art.stroke(&n, Art.line(563, Hv + 3, 2231, Hv + 1200), ArtStyle.coolShade.opacity(0.14), width: 1.8)
                // Two faint cart ruts running to the same far point.
                var tracks = Path()
                tracks.move(to: CGPoint(x: 559.5, y: Hv + 6))
                tracks.addLine(to: CGPoint(x: 860, y: Hv + 1200))
                tracks.move(to: CGPoint(x: 560.5, y: Hv + 6))
                tracks.addLine(to: CGPoint(x: 1530, y: Hv + 1200))
                Art.stroke(&n, tracks, Art.color(0xD9BE84, 0.6), width: 2)

                // The yard: the house on the trailing edge, the earth wall, the gate posts.
                Kit.tree(&n, x: 722, baseY: Hv + 54, height: 150, spread: 120, palette: Kit.springGreens(), bark: 0x6E4A3C, seed: 5)
                farmhouse(&n, x: 850, baseY: Hv + 50, scale: 0.9)
                yardWall(&n, x0: 668, x1: 900, baseY: Hv + 74, height: 28)
                yardWall(&n, x0: 474, x1: 528, baseY: Hv + 74, height: 28)
                gatePost(&n, x: 528, baseY: Hv + 76, height: 62)
                gatePost(&n, x: 668, baseY: Hv + 76, height: 62)
                openRoadFamily(&n, Hv)
            }
        }
    }

    /// A wooden gate post with a rounded cap, its foot at (x, baseY).
    static func gatePost(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, height: CGFloat) {
        Kit.shadow(&context, x, baseY, width: 26, alpha: 0.2)
        let post = Art.rect(x - 6, baseY - height, 12, height, radius: 3)
        Kit.solid(&context, post, Art.color(0x8A5E38), light: 0.3, shade: 0.24)
        let cap = Art.rect(x - 9, baseY - height - 5, 18, 8, radius: 4)
        Kit.solid(&context, cap, Art.color(0x6E4A2C), light: 0.3, shade: 0.2)
        Art.stroke(&context, Art.line(x + 2, baseY - height + 8, x + 2, baseY - 6), Art.color(0x6E4A2C, 0.5), width: 1.2)
    }

    /// The family at the gate, all looking down the road (near-space units).
    static func openRoadFamily(_ n: inout GraphicsContext, _ Hv: CGFloat) {
        let away = CGPoint(x: -0.8, y: -0.2)
        // A son and a grandchild behind.
        Kit.shadow(&n, 842, Hv + 100, width: 54)
        Art.group(&n, x: 842, y: Hv + 100, scale: 0.94) { p in
            kin(&p, grownLook(0), pose: .stand, look: away, mouth: .open)
        }
        // Yu Gong's wife.
        Kit.shadow(&n, 774, Hv + 108, width: 56)
        Art.group(&n, x: 774, y: Hv + 108) { p in
            wife(&p, pose: .stand, look: away, mouth: .oh)
        }
        // Yu Gong with his hoe.
        Kit.shadow(&n, 702, Hv + 114, width: 58)
        Art.group(&n, x: 702, y: Hv + 114) { p in
            yuGongWithHoe(&p, look: away, mouth: .open)
        }
        Kit.shadow(&n, 868, Hv + 122, width: 40)
        Art.group(&n, x: 868, y: Hv + 122) { p in
            kin(&p, grandchildLook(2), pose: .reach, look: away, mouth: .grin)
        }
        // The little boy, hopping in the gateway.
        Kit.shadow(&n, 594, Hv + 112, width: 34, alpha: 0.2)
        Art.group(&n, x: 594, y: Hv + 100) { p in
            boy(&p, pose: .wave, look: CGPoint(x: -0.7, y: -0.3), mouth: .grin)
        }
    }
}
