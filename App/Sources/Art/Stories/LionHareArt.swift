import SwiftUI
import OmramoCore

/// Concept art for "The Lion and the Hare", drawn in code (round 5; composed from the shared kit).
///
/// The cast, the palette and the old stone well are in `LionHareArt+Cast.swift`; the four
/// folded-phone compositions in `LionHareArt+Folded.swift`; the tap-to-see pictures, the
/// portraits, the face chips and the cover in `LionHareArt+Pictures.swift`. This file holds the
/// entry point and the four unfolded scenes.
enum LionHareArt {
    /// Draws the picture called `name`. Returns false for a name this story does not have.
    static func paint(_ name: String, role: ArtRole, in context: inout GraphicsContext, size: CGSize) -> Bool {
        guard size.width > 0, size.height > 0 else { return false }
        switch (name, role) {
        case ("scene-valley", .sceneUnfolded): valleyScene(&context, size)
        case ("scene-valley", .sceneFolded): valleyFolded(&context, size)
        case ("scene-council", .sceneUnfolded): councilScene(&context, size)
        case ("scene-council", .sceneFolded): councilFolded(&context, size)
        case ("scene-hills", .sceneUnfolded): hillsScene(&context, size)
        case ("scene-hills", .sceneFolded): hillsFolded(&context, size)
        case ("scene-well", .sceneUnfolded): wellScene(&context, size)
        case ("scene-well", .sceneFolded): wellFolded(&context, size)
        case ("see-persia", .picture): persiaPicture(&context, size)
        case ("see-wild-hare", .picture): harePicture(&context, size)
        case ("see-well", .picture): wellPicture(&context, size)
        case ("char-hare", .portrait): harePortrait(&context, size)
        case ("char-lion", .portrait): lionPortrait(&context, size)
        case ("face-hare", .face): hareChip(&context, size)
        case ("face-lion", .face): lionChip(&context, size)
        case ("face-gazelle", .face): gazelleChip(&context, size)
        case ("face-tortoise", .face): tortoiseChip(&context, size)
        case ("cover", .cover): cover(&context, size)
        default:
            return false
        }
        return true
    }
}

// MARK: - scene-valley: the Lion on his rock above the green valley

extension LionHareArt {
    static func valleyScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 150)
        let light = day()
        valleyFar(&context, st, light)
        Kit.designSpace(&context, st) { v in
            Kit.nearSpace(&v, st) { n in
                lionRock(&n, st.Hv)
            }
            Kit.nearSpace(&v, st, anchorX: 560) { n in
                valleyFriends(&n, st.Hv)
            }
        }
        valleyNear(&context, st)
        ArtStyle.finish(&context, size)
    }

    /// Sky, gold hills, the green valley floor, the stream with its poplars and the small
    /// deer and gazelle drinking (low on the leading side, under the words).
    static func valleyFar(_ context: inout GraphicsContext, _ st: Kit.Stage, _ light: Kit.Light) {
        let w: CGFloat = st.w
        let H: CGFloat = st.H
        let f: CGFloat = st.far
        Kit.sky(&context, st.size, horizon: H, light: light)
        Kit.sun(&context, 118, H - 96 * f, 24 * f, light: light)
        Kit.cloud(&context, 560, 150 * st.fit, scale: 0.9, color: Art.color(0xFFFFFF, 0.7))
        Kit.cloud(&context, 250, 96 * st.fit, scale: 0.55, color: Art.color(0xFFFFFF, 0.5))
        farLand(&context, width: w, horizon: H, scale: f, light: light, seed: 4)
        Kit.ground(&context, width: w, top: H, bottom: st.h, stops: greenGround())
        Kit.farTrees(&context, x0: 20, x1: 430, baseY: H + 3, height: 20 * f, count: 9, color: Art.color(0x8DB86A), seed: 6)
        Kit.farTrees(&context, x0: 470, x1: 600, baseY: H + 3, height: 18 * f, count: 4, color: Art.color(0x8DB86A), seed: 16)
        Kit.grass(&context, in: CGRect(x: 0, y: H + 16, width: w, height: st.depth - 16), count: 80, seed: 21, color: valleyGrass().opacity(0.5), height: 9)
        Kit.ribbon(&context, nearX: 300, nearY: st.h, nearWidth: 170, farX: 216, farY: H + 5, farWidth: 8, stops: streamStops())
        Kit.ripples(&context, 322, st.h - 30, 64, count: 2, color: Color.white, opacity: 0.5)
        poplar(&context, x: 96, baseY: H + 24 * f, height: 76 * f, seed: 11)
        poplar(&context, x: 150, baseY: H + 16 * f, height: 68 * f, seed: 12)
        poplar(&context, x: 268, baseY: H + 12 * f, height: 58 * f, seed: 13)
        Kit.tree(&context, x: 394, baseY: H + 30 * f, height: 62 * f, spread: 70 * f, palette: Kit.springGreens(), bark: 0x7A6048, seed: 5)
        Art.group(&context, x: 196, y: H + 60 * f, scale: 0.3 * f, scaleX: -1) { g in
            deer(&g, pose: .stand, mirrored: true)
        }
        Art.group(&context, x: 352, y: H + 66 * f, scale: 0.3 * f) { g in
            gazelle(&g, pose: .stand)
        }
        Art.group(&context, x: 62, y: H + 44 * f, scale: 0.22 * f, scaleX: -1) { g in
            deer(&g, pose: .walk, mirrored: true)
        }
        wildFlowers(&context, in: CGRect(x: 20, y: H + 40, width: 400, height: max(20, st.depth - 80)), count: 12, seed: 14)
    }

    /// The Lion's flat-topped rock with the dark mouth of his den, and the Lion roaring on it.
    static func lionRock(_ context: inout GraphicsContext, _ Hv: CGFloat) {
        let top: CGFloat = Hv - 58
        var rock = Path()
        rock.move(to: CGPoint(x: 592, y: Hv + 84))
        rock.addCurve(to: CGPoint(x: 622, y: top + 8), control1: CGPoint(x: 600, y: Hv + 30), control2: CGPoint(x: 604, y: top + 30))
        rock.addQuadCurve(to: CGPoint(x: 700, y: top), control: CGPoint(x: 640, y: top - 6))
        rock.addLine(to: CGPoint(x: 800, y: top - 6))
        rock.addQuadCurve(to: CGPoint(x: 900, y: top - 14), control: CGPoint(x: 850, y: top - 2))
        rock.addLine(to: CGPoint(x: 900, y: Hv + 96))
        rock.addQuadCurve(to: CGPoint(x: 592, y: Hv + 84), control: CGPoint(x: 740, y: Hv + 104))
        rock.closeSubpath()
        ArtStyle.contactShadow(&context, 760, Hv + 94, 190, 14, alpha: 0.26)
        let rockStops: Kit.Stops = [(Art.color(0xDDB49C), 0), (Art.color(rockHex), 0.5), (Art.color(0xA87C68), 1)]
        Kit.solid(&context, rock, stops: rockStops, light: 0.3, shade: 0.26, rim: 2.4)
        var strata = Path()
        strata.move(to: CGPoint(x: 606, y: top + 34))
        strata.addQuadCurve(to: CGPoint(x: 900, y: top + 22), control: CGPoint(x: 750, y: top + 40))
        strata.move(to: CGPoint(x: 598, y: top + 74))
        strata.addQuadCurve(to: CGPoint(x: 740, y: top + 70), control: CGPoint(x: 670, y: top + 80))
        strata.move(to: CGPoint(x: 640, y: top + 12))
        strata.addLine(to: CGPoint(x: 652, y: top + 34))
        strata.move(to: CGPoint(x: 706, y: top + 38))
        strata.addLine(to: CGPoint(x: 700, y: top + 72))
        var den = Path()
        den.move(to: CGPoint(x: 730, y: Hv + 96))
        den.addCurve(to: CGPoint(x: 792, y: Hv + 16), control1: CGPoint(x: 728, y: Hv + 50), control2: CGPoint(x: 752, y: Hv + 16))
        den.addCurve(to: CGPoint(x: 858, y: Hv + 98), control1: CGPoint(x: 834, y: Hv + 16), control2: CGPoint(x: 860, y: Hv + 52))
        den.closeSubpath()
        let dark: Kit.Stops = [(Art.color(0x6A4438), 0), (Art.color(0x3A2638), 1)]
        Art.clipped(&context, to: rock) { g in
            Art.stroke(&g, strata, Art.color(0x8A5E50, 0.5), width: ArtStyle.detailLine)
            ArtStyle.tooth(&g, in: CGRect(x: 590, y: top - 16, width: 310, height: 180), seed: 19, alpha: 0.06)
            Art.fillLinear(&g, den, dark, from: CGPoint(x: 0, y: Hv + 16), to: CGPoint(x: 0, y: Hv + 98))
            Art.stroke(&g, den, Art.color(0xE8C4AC, 0.5), width: ArtStyle.detailLine)
        }
        Kit.rock(&context, cx: 600, baseY: Hv + 90, width: 64, height: 36, color: rockHex, seed: 3)
        Kit.grassTuft(&context, x: 708, baseY: Hv + 98, height: 30, color: 0x3F7F45, seed: 9)
        Art.group(&context, x: 742, y: top - 2, scale: 1.22) { g in
            lion(&g, pose: .stand, roar: true)
        }
    }

    /// The fox, the Hare and the slow old Tortoise low in the grass at the foot of the rock.
    static func valleyFriends(_ context: inout GraphicsContext, _ Hv: CGFloat) {
        wildFlowers(&context, in: CGRect(x: 470, y: Hv + 70, width: 150, height: 60), count: 7, seed: 31)
        Art.group(&context, x: 494, y: Hv + 96, scale: 0.55, scaleX: -1) { g in
            fox(&g, pose: .sit, mood: .surprised, look: CGPoint(x: -0.6, y: -0.7), mirrored: true)
        }
        Art.group(&context, x: 618, y: Hv + 130, scale: 0.72) { g in
            tortoise(&g)
        }
        Art.group(&context, x: 552, y: Hv + 126, scale: 0.55, scaleX: -1) { g in
            hare(&g, pose: .rear, mood: .calm, look: CGPoint(x: -0.5, y: -0.8), mirrored: true)
        }
        Kit.grassTuft(&context, x: 520, baseY: Hv + 134, height: 22, color: 0x3F7F45, seed: 5)
        Kit.grassTuft(&context, x: 588, baseY: Hv + 138, height: 20, color: 0x3F7F45, seed: 6)
    }

    /// Near framing, and the deeper foreground of a tall window.
    static func valleyNear(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        if st.tall > 0.25 {
            let floor: CGFloat = st.h
            wildFlowers(&context, in: CGRect(x: 440, y: floor - 150, width: 380, height: 110), count: 16, seed: 12)
            Kit.rock(&context, cx: 520, baseY: floor - 44, width: 90, height: 46, color: stoneHex, seed: 6)
            Kit.reeds(&context, x: 396, baseY: floor - 20, count: 7, height: 110, seed: 8, color: 0x3F8A5A)
            Kit.bush(&context, x: 800, baseY: floor - 4, width: 200, palette: Kit.summerGreens(), seed: 4)
            Kit.grassTuft(&context, x: 640, baseY: floor - 30, height: 46, color: 0x3F7F45, seed: 7)
            Kit.grassTuft(&context, x: 180, baseY: floor - 60, height: 40, color: 0x3F7F45, seed: 8)
        }
        Kit.grassTuft(&context, x: 470, baseY: st.h + 6, height: 54 * st.grow, color: 0x2F6E40, seed: 3)
        Kit.grassTuft(&context, x: 40, baseY: st.h + 8, height: 48 * st.grow, color: 0x2F6E40, seed: 4)
        Kit.cornerLeaves(&context, size: st.size, corner: 3, color: Art.color(0x24573A), scale: 0.9 * st.grow, seed: 2)
    }
}

// MARK: - scene-council: the animals under the great plane tree, the Hare thinking

extension LionHareArt {
    static func councilScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 170)
        let light = evening()
        councilFar(&context, st, light)
        // The plane tree grows taller on a tall window but never wider: its crown must stay
        // off the leading pane, where the words are.
        let treeHeight: CGFloat = 450 * st.grow
        let treeBase: CGFloat = st.Hv + 64 * st.grow
        Kit.designSpace(&context, st) { v in
            ArtStyle.contactShadow(&v, 760, st.Hv + 84, 250, 34, alpha: 0.16)
            councilRing(&v, st.Hv)
            Kit.greatTree(&v, x: 806, baseY: treeBase, height: treeHeight, spread: 520, palette: planeGreens(), bark: 0xB9AE98, seed: 7)
            Kit.nearSpace(&v, st, anchorX: 560) { n in
                councilFriends(&n, st.Hv)
            }
        }
        councilNear(&context, st)
        ArtStyle.finish(&context, size)
    }

    /// Evening sky, soft hills, the valley floor and a far glimpse of the stream.
    static func councilFar(_ context: inout GraphicsContext, _ st: Kit.Stage, _ light: Kit.Light) {
        let w: CGFloat = st.w
        let H: CGFloat = st.H
        let f: CGFloat = st.far
        Kit.sky(&context, st.size, horizon: H, light: light)
        Kit.sun(&context, 132, H - 64 * f, 28 * f, light: light)
        Kit.cloud(&context, 330, 120 * st.fit, scale: 0.6, color: Art.color(0xFFF6E0, 0.55))
        Kit.birds(&context, 250, H - 150 * f, scale: 0.8, color: Art.color(0x8A6A3A, 0.5))
        farLand(&context, width: w, horizon: H, scale: f, light: light, seed: 23)
        Kit.ground(&context, width: w, top: H, bottom: st.h, stops: eveningGround())
        Kit.farTrees(&context, x0: 10, x1: 440, baseY: H + 3, height: 20 * f, count: 8, color: Art.color(0x9DB868), seed: 26)
        Kit.ribbon(&context, nearX: 40, nearY: H + 74 * f, nearWidth: 70 * f, farX: 168, farY: H + 6, farWidth: 6, stops: streamStops())
        poplar(&context, x: 214, baseY: H + 16 * f, height: 66 * f, seed: 14)
        poplar(&context, x: 108, baseY: H + 26 * f, height: 74 * f, seed: 15)
        Kit.grass(&context, in: CGRect(x: 0, y: H + 16, width: w, height: st.depth - 16), count: 90, seed: 27, color: Art.color(0x4E7F3A, 0.5), height: 10)
        wildFlowers(&context, in: CGRect(x: 20, y: H + 50, width: 420, height: max(20, st.depth - 90)), count: 10, seed: 28)
    }

    /// The far side of the ring: two deer and the fox, sitting low in the grass.
    static func councilRing(_ context: inout GraphicsContext, _ Hv: CGFloat) {
        Art.group(&context, x: 214, y: Hv + 56, scale: 0.36, scaleX: -1) { g in
            deer(&g, pose: .stand, mirrored: true)
        }
        Art.group(&context, x: 306, y: Hv + 82, scale: 0.5, scaleX: -1) { g in
            deer(&g, pose: .sit, mood: .calm, mirrored: true)
        }
        Art.group(&context, x: 398, y: Hv + 104, scale: 0.55, scaleX: -1) { g in
            fox(&g, pose: .sit, mood: .calm, look: CGPoint(x: -0.6, y: -0.2), mirrored: true)
        }
        Kit.grassTuft(&context, x: 350, baseY: Hv + 112, height: 24, color: 0x4E7F3A, seed: 12)
    }

    /// The Gazelle standing to speak, the Tortoise chewing, and the Hare a little apart in
    /// the long grass under the tree, ears up, thinking.
    static func councilFriends(_ context: inout GraphicsContext, _ Hv: CGFloat) {
        Art.group(&context, x: 556, y: Hv + 62, scale: 0.8) { g in
            gazelle(&g, pose: .stand, mood: .calm, look: CGPoint(x: -0.4, y: 0.2))
        }
        Art.group(&context, x: 600, y: Hv + 130, scale: 0.75) { g in
            tortoise(&g)
        }
        Kit.grassTuft(&context, x: 690, baseY: Hv + 104, height: 46, color: 0x3F7F45, seed: 21)
        Art.group(&context, x: 672, y: Hv + 116, scale: 0.64) { g in
            hare(&g, pose: .rear, mood: .calm, look: CGPoint(x: -0.4, y: -0.7))
        }
        Kit.grassTuft(&context, x: 640, baseY: Hv + 126, height: 34, color: 0x4E8A45, seed: 22)
        Kit.grassTuft(&context, x: 704, baseY: Hv + 128, height: 38, color: 0x4E8A45, seed: 23)
        wildFlowers(&context, in: CGRect(x: 470, y: Hv + 86, width: 110, height: 40), count: 5, seed: 33)
    }

    static func councilNear(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        if st.tall > 0.25 {
            let floor: CGFloat = st.h
            Kit.grass(&context, in: CGRect(x: 0, y: floor - 150, width: st.w, height: 130), count: 60, seed: 41, color: Art.color(0x3F7036, 0.6), height: 16)
            wildFlowers(&context, in: CGRect(x: 60, y: floor - 150, width: 700, height: 110), count: 20, seed: 42)
            Kit.rock(&context, cx: 470, baseY: floor - 50, width: 84, height: 40, color: stoneHex, seed: 9)
            Kit.grassTuft(&context, x: 300, baseY: floor - 40, height: 50, color: 0x3F7F45, seed: 13)
            Kit.grassTuft(&context, x: 660, baseY: floor - 24, height: 56, color: 0x3F7F45, seed: 14)
        }
        Kit.grassTuft(&context, x: 36, baseY: st.h + 8, height: 50 * st.grow, color: 0x2F6238, seed: 5)
        Kit.grassTuft(&context, x: 452, baseY: st.h + 8, height: 44 * st.grow, color: 0x2F6238, seed: 6)
        Kit.grassTuft(&context, x: 864, baseY: st.h + 8, height: 60 * st.grow, color: 0x2F6238, seed: 7)
    }
}

// MARK: - scene-hills: the Hare leads the Lion up the dusty path at noon

extension LionHareArt {
    static func hillsScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 180)
        let light = noon()
        hillsFar(&context, st, light)
        Kit.designSpace(&context, st) { v in
            hillsMiddle(&v, st)
            Kit.nearSpace(&v, st, anchorX: 640) { n in
                hillsSubject(&n, st.Hv)
            }
        }
        hillsNear(&context, st)
        ArtStyle.finish(&context, size, wash: 0.12, vignette: 0.08)
    }

    /// The pale hot sky, bare gold ridges and the dry slope on the leading side.
    static func hillsFar(_ context: inout GraphicsContext, _ st: Kit.Stage, _ light: Kit.Light) {
        let w: CGFloat = st.w
        let H: CGFloat = st.H
        let f: CGFloat = st.far
        Kit.sky(&context, st.size, horizon: H, light: light)
        Kit.cloud(&context, 600, 130 * st.fit, scale: 0.7, color: Art.color(0xFFFFFF, 0.6))
        farLand(&context, width: w, horizon: H, scale: f, light: light, seed: 9)
        Kit.ground(&context, width: w, top: H, bottom: st.h, stops: dryGround())
        Kit.mound(&context, x0: -40, x1: 500, baseY: H + 6, height: 44 * f, bottom: H + 6, stops: dryGround(), crest: 0.4)
        Kit.cypress(&context, x: 304, baseY: H + 22 * f, height: 84 * f)
        Kit.cypress(&context, x: 214, baseY: H + 12 * f, height: 58 * f)
        Kit.rock(&context, cx: 150, baseY: H + 70 * f, width: 72 * f, height: 38 * f, color: stoneHex, seed: 2)
        Kit.rock(&context, cx: 380, baseY: H + 46 * f, width: 44 * f, height: 24 * f, color: stoneHex, seed: 4)
        Kit.grass(&context, in: CGRect(x: 0, y: H + 20, width: w, height: st.depth - 20), count: 36, seed: 51, color: Art.color(0xA8843A, 0.7), height: 9)
        Kit.pebbles(&context, in: CGRect(x: 0, y: H + 30, width: w, height: st.depth - 30), count: 26, seed: 52, color: stoneHex)
    }

    /// The dusty path climbing between grey rocks and tall dark cypresses (design units).
    static func hillsMiddle(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        Kit.ribbon(&context, nearX: 640, nearY: st.hv, nearWidth: 300, farX: 372, farY: Hv + 6, farWidth: 12, stops: pathStops())
        Kit.cypress(&context, x: 486, baseY: Hv + 30, height: 124 * st.grow)
        Kit.cypress(&context, x: 596, baseY: Hv + 14, height: 150 * st.grow)
        Kit.rock(&context, cx: 804, baseY: Hv + 34, width: 116, height: 62, color: stoneHex, seed: 7)
        Kit.cypress(&context, x: 846, baseY: Hv + 52, height: 300 * st.grow)
        Kit.rock(&context, cx: 474, baseY: Hv + 72, width: 78, height: 42, color: stoneHex, seed: 11)
        Kit.grassTuft(&context, x: 870, baseY: Hv + 60, height: 26, color: dryGrassHex, seed: 3)
    }

    /// The Hare hopping ahead, looking back over his shoulder, and the Lion stamping along
    /// behind him, puffing, with small clouds of dust at his paws.
    static func hillsSubject(_ context: inout GraphicsContext, _ Hv: CGFloat) {
        dustPuff(&context, 800, Hv + 104, scale: 0.42)
        dustPuff(&context, 690, Hv + 106, scale: 0.34)
        Art.group(&context, x: 728, y: Hv + 100, scale: 1.2) { g in
            lion(&g, pose: .walk, mood: .surprised, look: CGPoint(x: -0.6, y: 0.1))
        }
        dustPuff(&context, 620, Hv + 108, scale: 0.26)
        Art.group(&context, x: 545, y: Hv + 110, scale: 0.6) { g in
            hare(&g, pose: .run, mood: .happy, look: CGPoint(x: 0.9, y: 0))
        }
        dustPuff(&context, 584, Hv + 116, scale: 0.16)
    }

    static func hillsNear(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        if st.tall > 0.25 {
            let floor: CGFloat = st.h
            Kit.rock(&context, cx: 500, baseY: floor - 60, width: 110, height: 56, color: stoneHex, seed: 15)
            Kit.rock(&context, cx: 250, baseY: floor - 90, width: 80, height: 40, color: stoneHex, seed: 16)
            Kit.pebbles(&context, in: CGRect(x: 380, y: floor - 160, width: 460, height: 130), count: 30, seed: 17, color: stoneHex)
            Kit.grassTuft(&context, x: 420, baseY: floor - 30, height: 44, color: dryGrassHex, seed: 18)
            Kit.grassTuft(&context, x: 130, baseY: floor - 50, height: 40, color: dryGrassHex, seed: 19)
        }
        Kit.rock(&context, cx: 872, baseY: st.h + 14, width: 130 * st.grow, height: 70 * st.grow, color: 0x8A8074, seed: 21)
        Kit.grassTuft(&context, x: 40, baseY: st.h + 8, height: 44 * st.grow, color: 0xA8843A, seed: 8)
        Kit.grassTuft(&context, x: 800, baseY: st.h + 8, height: 40 * st.grow, color: 0xA8843A, seed: 9)
    }
}

// MARK: - scene-well: the Lion and the Hare look down the old stone well

extension LionHareArt {
    static func wellScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 170)
        let light = noon()
        wellFar(&context, st, light)
        Kit.designSpace(&context, st) { v in
            wellMiddle(&v, st)
            Kit.nearSpace(&v, st, anchorX: 676) { n in
                Art.group(&n, x: 676, y: st.Hv + 30) { g in
                    wellEnsemble(&g, ry: 66, wall: 36, lionScale: 1.7, hareScale: 0.8, lionMood: .surprised, hareMood: .sly)
                }
            }
        }
        wellNear(&context, st)
        ArtStyle.finish(&context, size, wash: 0.12, vignette: 0.08)
    }

    /// Noon in the dry hills: gold ridges, a bare slope and a few stones on the leading side.
    static func wellFar(_ context: inout GraphicsContext, _ st: Kit.Stage, _ light: Kit.Light) {
        let w: CGFloat = st.w
        let H: CGFloat = st.H
        let f: CGFloat = st.far
        Kit.sky(&context, st.size, horizon: H, light: light)
        Kit.cloud(&context, 300, 110 * st.fit, scale: 0.6, color: Art.color(0xFFFFFF, 0.5))
        farLand(&context, width: w, horizon: H, scale: f, light: light, seed: 13)
        Kit.ground(&context, width: w, top: H, bottom: st.h, stops: dryGround())
        Kit.mound(&context, x0: -60, x1: 420, baseY: H + 6, height: 36 * f, bottom: H + 6, stops: dryGround(), crest: 0.55)
        Kit.cypress(&context, x: 96, baseY: H + 14 * f, height: 56 * f)
        Kit.rock(&context, cx: 240, baseY: H + 64 * f, width: 80 * f, height: 42 * f, color: stoneHex, seed: 3)
        Kit.rock(&context, cx: 360, baseY: H + 100 * f, width: 46 * f, height: 24 * f, color: stoneHex, seed: 5)
        Kit.grass(&context, in: CGRect(x: 0, y: H + 20, width: w, height: st.depth - 20), count: 40, seed: 61, color: Art.color(0xA8843A, 0.7), height: 9)
        Kit.pebbles(&context, in: CGRect(x: 0, y: H + 30, width: w, height: st.depth - 30), count: 30, seed: 62, color: stoneHex)
    }

    /// The hollow's far side, a lone cypress and scattered rocks behind the well (design units).
    static func wellMiddle(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        Kit.mound(&context, x0: 446, x1: 980, baseY: Hv + 8, height: 46, bottom: Hv + 8, stops: dryGround(), crest: 0.62)
        Kit.cypress(&context, x: 512, baseY: Hv + 26, height: 190 * st.grow)
        Kit.rock(&context, cx: 856, baseY: Hv + 28, width: 92, height: 52, color: stoneHex, seed: 6)
        Kit.grassTuft(&context, x: 470, baseY: Hv + 70, height: 26, color: dryGrassHex, seed: 4)
        if st.tall > 0.25 {
            let from: CGFloat = Hv + 150 * st.grow
            Kit.ribbon(&context, nearX: 590, nearY: st.hv, nearWidth: 260, farX: 676, farY: from, farWidth: 150, stops: pathStops())
        }
    }

    static func wellNear(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        if st.tall > 0.25 {
            let floor: CGFloat = st.h
            Kit.rock(&context, cx: 300, baseY: floor - 70, width: 100, height: 50, color: stoneHex, seed: 25)
            Kit.pebbles(&context, in: CGRect(x: 420, y: floor - 150, width: 440, height: 120), count: 26, seed: 27, color: stoneHex)
            Kit.grassTuft(&context, x: 470, baseY: floor - 36, height: 46, color: dryGrassHex, seed: 28)
            Kit.grassTuft(&context, x: 160, baseY: floor - 40, height: 40, color: dryGrassHex, seed: 29)
        }
        Kit.grassTuft(&context, x: 40, baseY: st.h + 8, height: 46 * st.grow, color: 0xA8843A, seed: 10)
        Kit.grassTuft(&context, x: 470, baseY: st.h + 8, height: 40 * st.grow, color: 0xA8843A, seed: 11)
        Kit.rock(&context, cx: 884, baseY: st.h + 12, width: 110 * st.grow, height: 56 * st.grow, color: 0x8A8074, seed: 31)
    }
}
