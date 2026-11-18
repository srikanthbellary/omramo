import SwiftUI
import OmramoCore

/// Concept art for "Why the Possum's Tail Is Bare", drawn in code (round 5; composed from the shared kit).
///
/// A Cherokee animal story (cultural review required and pending). Every picture shows only
/// animals and the forest of the Great Smoky Mountains: no people, no drums, fire, masks,
/// feathers, patterns or lettering. The dance is the animals' own, in a forest clearing.
///
/// This file: the entry point and the four unfolded scenes. The cast and the woods are in
/// `PossumArt+Cast.swift`, the folded scenes in `PossumArt+Folded.swift`, the tap pictures,
/// portraits, faces and cover in `PossumArt+Pictures.swift`.
enum PossumArt {
    /// Draws the picture called `name`. Returns false for a name this story does not have.
    static func paint(_ name: String, role: ArtRole, in context: inout GraphicsContext, size: CGSize) -> Bool {
        guard size.width > 0, size.height > 0 else { return false }
        switch (name, role) {
        case ("scene-woods", .sceneUnfolded): woodsScene(&context, size)
        case ("scene-woods", .sceneFolded): woodsFolded(&context, size)
        case ("scene-combing", .sceneUnfolded): combingScene(&context, size)
        case ("scene-combing", .sceneFolded): combingFolded(&context, size)
        case ("scene-dance", .sceneUnfolded): danceScene(&context, size)
        case ("scene-dance", .sceneFolded): danceFolded(&context, size)
        case ("scene-grin", .sceneUnfolded): grinScene(&context, size)
        case ("scene-grin", .sceneFolded): grinFolded(&context, size)
        case ("see-smoky-mountains", .picture): smokyMountainsPicture(&context, size)
        case ("see-cricket-barber", .picture): cricketPicture(&context, size)
        case ("see-opossum", .picture): opossumPicture(&context, size)
        case ("char-possum", .portrait): possumPortrait(&context, size)
        case ("char-rabbit", .portrait): rabbitPortrait(&context, size)
        case ("face-possum", .face): possumFaceChip(&context, size)
        case ("face-rabbit", .face): rabbitFaceChip(&context, size)
        case ("face-cricket", .face): cricketFaceChip(&context, size)
        case ("cover", .cover): cover(&context, size)
        default:
            return false
        }
        return true
    }
}

// MARK: - Scene 1: the morning woods (Possum combs his splendid tail)

extension PossumArt {
    static func woodsScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 150)
        let light = morning()
        let w: CGFloat = size.width
        // Far: the pale morning sky, a low sun on the leading side, the blue ridges in mist.
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.sun(&context, 150, st.H - 64 * st.far, 24 * st.far, light: light)
        Kit.cloud(&context, 640, 100 * st.fit, scale: 0.8, color: Art.color(0xFFFFFF, 0.7))
        ridges(&context, width: w, horizon: st.H, scale: st.far, light: light)
        Kit.farTrees(&context, x0: 470, x1: 892, baseY: st.H + 4, height: 54 * st.far, count: 12, color: Art.color(0x5E947F), seed: 3)
        Kit.farTrees(&context, x0: 0, x1: 300, baseY: st.H + 4, height: 26 * st.far, count: 9, color: Art.color(0x7FAE9A), seed: 5)
        ArtStyle.atmosphere(&context, width: w, top: st.H - 70 * st.far, bottom: st.H + 6, color: light.haze, alpha: 0.25)
        Kit.ground(&context, width: w, top: st.H, bottom: size.height, stops: grassStops())
        woodsStream(&context, st)
        meadow(&context, st, seed: 11, flower: 0xFFFFFF)
        Kit.designSpace(&context, st) { v in
            woodsMiddle(&v, st)
            Kit.nearSpace(&v, st, anchorX: 700) { n in
                woodsSubject(&n, st)
            }
            // Near: the dark boughs of the great tree hang into the top trailing corner.
            let boughs: [Kit.Blob] = [(850, 40, 84), (756, 24, 62), (900, 136, 64), (690, 10, 44)]
            Kit.canopy(&v, boughs, seed: 52, palette: Kit.pineGreens(), density: 2)
        }
        ArtStyle.finish(&context, size)
    }

    /// A clear rocky stream low on the leading side, so the wide picture is one place.
    static func woodsStream(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let water: Kit.Stops = [(Art.color(0xE4F4F4), 0), (Art.color(0xA9D6E4), 1)]
        let nearWidth: CGFloat = 150 * st.far
        Kit.ribbon(&context, nearX: 120, nearY: st.h + 4, nearWidth: nearWidth, farX: 330, farY: st.H + 8, farWidth: 8, stops: water)
        let midY: CGFloat = st.H + st.depth * 0.5
        Kit.rippleMarks(&context, x0: 150, x1: 290, y0: midY, y1: st.h, count: 14, seed: 6, color: Color.white, alpha: 0.5)
        Kit.rock(&context, cx: 64, baseY: st.H + st.depth * 0.6, width: 74 * st.far, height: 36 * st.far, color: 0x8E9486, seed: 2)
        Kit.rock(&context, cx: 318, baseY: st.H + st.depth * 0.42, width: 44 * st.far, height: 22 * st.far, color: 0x9A9E90, seed: 5)
        Kit.rock(&context, cx: 372, baseY: st.H + st.depth * 0.82, width: 58 * st.far, height: 26 * st.far, color: 0x8E9486, seed: 8)
        fern(&context, x: 30, baseY: st.H + st.depth * 0.42, height: 30 * st.far, seed: 12)
        fern(&context, x: 404, baseY: st.H + st.depth * 0.6, height: 34 * st.far, color: 0x2F7A4A, seed: 13)
    }

    /// The middle plane: tall trunks and rhododendron thinning toward a sunny gap.
    static func woodsMiddle(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        let greens: Kit.Greens = Kit.summerGreens()
        let tallTree: CGFloat = max(300, Hv - 30)
        Kit.tree(&context, x: 874, baseY: Hv + 26, height: tallTree, spread: 300, palette: greens, bark: 0x6B4E40, seed: 7)
        Kit.tree(&context, x: 546, baseY: Hv + 8, height: 250 * st.grow, spread: 150 * st.grow, palette: greens, bark: 0x7A5A48, seed: 9)
        let laurel: Kit.Greens = Kit.greens(0x1F4A3A, 0x2F6A4A, 0x3F8A5A, 0x6FAE6A, 0xB9DE8A)
        Kit.bush(&context, x: 806, baseY: Hv + 36, width: 170, palette: laurel, seed: 4)
        Kit.flowers(&context, in: CGRect(x: 738, y: Hv - 26, width: 130, height: 44), count: 14, seed: 21, petal: 0xF2A0C8)
        Kit.bush(&context, x: 478, baseY: Hv + 24, width: 78, palette: laurel, seed: 6)
    }

    /// The subject: Possum on his mossy log, chin up, singing, combing the plume; Rabbit low
    /// in the ferns, watching.
    static func woodsSubject(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        Art.group(&context, x: 700, y: Hv + 92) { g in
            mossyLog(&g, length: 250)
        }
        Art.group(&context, x: 712, y: Hv + 48) { g in
            Kit.shadow(&g, 6, 0, width: 96)
            possumCombing(&g)
        }
        Kit.shadow(&context, 548, Hv + 104, width: 70)
        Art.group(&context, x: 548, y: Hv + 104, scale: 0.82, scaleX: -1) { g in
            rabbit(&g, pose: .sit, mood: .calm, look: CGPoint(x: -0.7, y: -0.5), mirrored: true)
        }
        fern(&context, x: 500, baseY: Hv + 124, height: 52, seed: 2)
        fern(&context, x: 598, baseY: Hv + 130, height: 58, color: 0x2F7A4A, seed: 3)
        fern(&context, x: 852, baseY: Hv + 122, height: 66, seed: 4)
        Kit.grassTuft(&context, x: 650, baseY: Hv + 140, height: 36, color: 0x3F7A5A, seed: 5)
        Kit.grassTuft(&context, x: 790, baseY: Hv + 136, height: 30, color: 0x4F8F63, seed: 6)
    }

    /// Possum sitting (origin where he sits), the high plume behind him, one arm reaching back
    /// with the small wooden comb, mouth open in song.
    static func possumCombing(_ context: inout GraphicsContext) {
        plume(&context, proudTail(.sit))
        possum(&context, pose: .sit, mood: .proud, singing: true)
        let coat: Color = Art.color(possumLook().body)
        Art.stroke(&context, Art.svg("M-8,-58 C14,-70 40,-72 62,-66"), coat, width: 11)
        Art.stroke(&context, Art.svg("M-6,-61 C14,-72 38,-74 58,-69"), Art.color(0xFFFFFF, 0.2), width: 2)
        pinkPaw(&context, 66, -65, 6)
        comb(&context, x: 74, y: -70, turn: -35)
    }

    /// The small wooden comb, about 16 long, centred on (x, y), turned by `turn` degrees.
    static func comb(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, turn: CGFloat) {
        Art.group(&context, x: x, y: y, rotate: Kit.deg(turn)) { g in
            let back = Art.rect(-8, -5, 16, 4.5, radius: 1.6)
            Kit.solid(&g, back, Art.color(0xC99A5A), light: 0.3, shade: 0.2)
            Art.stroke(&g, Art.svg("M-6.5,0 v6 M-3.9,0 v6 M-1.3,0 v6 M1.3,0 v6 M3.9,0 v6 M6.5,0 v6"), Art.color(0xA9783E), width: 1.3)
        }
    }
}

// MARK: - Scene 2: late afternoon at the den (Cricket winds the red string)

extension PossumArt {
    static func combingScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 180)
        let light = afternoon()
        let w: CGFloat = size.width
        // Far: a pale warm sky, one soft ridge in mist, a line of far woods.
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.sun(&context, 96, st.H - 92 * st.far, 22 * st.far, light: light)
        Kit.cloud(&context, 600, 130 * st.fit, scale: 0.7, color: Art.color(0xFFFFFF, 0.65))
        ridges(&context, width: w, horizon: st.H, scale: st.far, light: light, layers: 2)
        Kit.farTrees(&context, x0: 0, x1: 892, baseY: st.H + 4, height: 38 * st.far, count: 22, color: Art.color(0x7FAE8A), seed: 8)
        ArtStyle.atmosphere(&context, width: w, top: st.H - 60 * st.far, bottom: st.H + 6, color: light.haze, alpha: 0.28)
        Kit.ground(&context, width: w, top: st.H, bottom: size.height, stops: grassStops())
        combingLeading(&context, st)
        meadow(&context, st, seed: 23, flower: 0xFFE27A)
        Kit.designSpace(&context, st) { v in
            let greens: Kit.Greens = Kit.summerGreens()
            Kit.tree(&v, x: 520, baseY: st.Hv + 6, height: 220 * st.grow, spread: 140 * st.grow, palette: greens, bark: 0x7A5A48, seed: 15)
            Kit.nearSpace(&v, st, anchorX: 700) { n in
                combingSubject(&n, st)
            }
            // The crown of the hollow tree fills the top trailing corner.
            let crown: [Kit.Blob] = [(880, 30, 92), (786, 18, 72), (700, 34, 52), (896, 132, 60), (628, 10, 38)]
            Kit.canopy(&v, crown, seed: 61, palette: greens, density: 2)
        }
        ArtStyle.finish(&context, size)
    }

    /// Low on the leading side: thin pale leaves at the top corner, stones and ferns below.
    static func combingLeading(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        Kit.cornerLeaves(&context, size: st.size, corner: 0, color: Art.color(0x7FB08A, 0.3), scale: 0.9, seed: 3)
        Kit.rock(&context, cx: 110, baseY: st.H + st.depth * 0.5, width: 86 * st.far, height: 38 * st.far, color: 0x8E9486, seed: 3)
        Kit.rock(&context, cx: 176, baseY: st.H + st.depth * 0.56, width: 40 * st.far, height: 20 * st.far, color: 0x9A9E90, seed: 6)
        fern(&context, x: 52, baseY: st.H + st.depth * 0.56, height: 32 * st.far, seed: 21)
        fern(&context, x: 300, baseY: st.H + st.depth * 0.72, height: 36 * st.far, color: 0x2F7A4A, seed: 22)
        Kit.grassTuft(&context, x: 390, baseY: st.H + st.depth * 0.4, height: 26 * st.far, color: 0x4F8F63, seed: 4)
        Art.group(&context, x: 240, y: st.H + st.depth * 0.36, scale: 0.7 * st.far) { g in
            Kit.critterButterfly(&g, wing: 0xFFD25A)
        }
    }

    /// The hollow tree with the den, Possum stretched out with his eyes shut, his tail laid
    /// out toward the viewer, half wrapped; Cricket on it; loose tufts in the grass.
    static func combingSubject(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        let laurel: Kit.Greens = Kit.greens(0x1F4A3A, 0x2F6A4A, 0x3F8A5A, 0x6FAE6A, 0xB9DE8A)
        Kit.bush(&context, x: 624, baseY: Hv + 22, width: 130, palette: laurel, seed: 12)
        Art.group(&context, x: 30, y: 0) { g in
            hollowTree(&g, baseY: Hv + 30, top: -260)
        }
        fern(&context, x: 792, baseY: Hv + 58, height: 46, seed: 31)
        fern(&context, x: 876, baseY: Hv + 74, height: 56, color: 0x2F7A4A, seed: 32)
        // A squat window has less room over the page button: lift the subject a little.
        let lift: CGFloat = (1 - st.fit) * 60
        let tail: [CGPoint] = tailFrom(.sleep, CGPoint(x: 50, y: -6), CGPoint(x: 70, y: 50), CGPoint(x: 0, y: 74))
        Art.group(&context, x: 650, y: Hv + 84 - lift, scale: 1.05) { g in
            possumAsleep(&g, tail: tail, cricketScale: 0.75)
            Art.group(&g, x: 142, y: 8) { f in
                fluff(&f, count: 6, seed: 9)
            }
            Art.group(&g, x: -20, y: 40, scale: 0.7) { f in
                fluff(&f, count: 3, seed: 14)
            }
        }
    }

    /// Possum asleep in the sun (origin on the ground under him, facing LEFT), his tail along
    /// `tail`: thin and wrapped in red string for the first half, still bushy beyond; Cricket
    /// stands on it close behind the string with his comb, the end of the string in his leg.
    static func possumAsleep(_ context: inout GraphicsContext, tail: [CGPoint], cricketScale: CGFloat) {
        Kit.shadow(&context, 0, 1, width: 150)
        possum(&context, pose: .sleep, mood: .sleepy)
        plume(&context, tail, from: 0.46)
        cord(&context, tail, to: 0.5, wrapped: true)
        guard tail.count > 26 else { return }
        let stand: CGPoint = tail[19]
        let wound: CGPoint = tail[25]
        let s: CGFloat = cricketScale
        let foot = CGPoint(x: stand.x, y: stand.y - 5)
        var string = Path()
        string.move(to: CGPoint(x: foot.x - 20 * s, y: foot.y - 6 * s))
        string.addQuadCurve(to: wound, control: CGPoint(x: foot.x - 30 * s, y: wound.y - 26 * s))
        Art.stroke(&context, string, Art.color(stringRed), width: 2)
        Art.group(&context, x: foot.x, y: foot.y, scale: s) { c in
            cricket(&c, comb: true)
        }
    }
}

// MARK: - The clearing (scenes 3 and 4)

extension PossumArt {
    /// The far plane and the ground of the clearing in the early evening: a pale peach sky,
    /// one soft ridge, dark-green treetops all round, and the trodden ring in the grass.
    static func clearing(_ context: inout GraphicsContext, _ st: Kit.Stage, light: Kit.Light) {
        let w: CGFloat = st.w
        Kit.sky(&context, st.size, horizon: st.H, light: light)
        Kit.sun(&context, 70, st.H - 40 * st.far, 20 * st.far, light: light)
        Kit.cloud(&context, 300, 90 * st.fit, scale: 0.6, color: Art.color(0xFFF6EA, 0.6))
        Kit.cloud(&context, 610, 150 * st.fit, scale: 0.75, color: Art.color(0xFFF6EA, 0.6))
        ridges(&context, width: w, horizon: st.H, scale: st.far, light: light, layers: 2)
        Kit.farTrees(&context, x0: -10, x1: 902, baseY: st.H + 4, height: 58 * st.far, count: 24, color: Art.color(0x6E9A80), seed: 17)
        ArtStyle.atmosphere(&context, width: w, top: st.H - 80 * st.far, bottom: st.H + 6, color: light.haze, alpha: 0.3)
        Kit.farTrees(&context, x0: -10, x1: 902, baseY: st.H + 6, height: 34 * st.far, count: 30, color: Art.color(0x5B8A6A), seed: 18)
        Kit.ground(&context, width: w, top: st.H, bottom: st.h, stops: eveningGrassStops())
        // The ring the dancers have trodden: a paler oval in the grass.
        let ringY: CGFloat = st.H + st.depth * 0.5
        let ring = Art.ellipse(500, ringY, 420, st.depth * 0.36)
        Art.fill(&context, ring, Art.color(0xE6E9B0, 0.28))
        Art.stroke(&context, ring, Art.color(0xF4F0C4, 0.3), width: 3)
    }

    /// The trees that stand at the trailing edge of the clearing, and the near boughs.
    static func clearingEdge(_ context: inout GraphicsContext, _ st: Kit.Stage, seed: UInt32) {
        let greens: Kit.Greens = Kit.summerGreens()
        let tallTree: CGFloat = max(280, st.Hv - 40)
        Kit.tree(&context, x: 880, baseY: st.Hv + 14, height: tallTree, spread: 280, palette: greens, bark: 0x6B4E40, seed: seed)
        Kit.tree(&context, x: 528, baseY: st.Hv + 4, height: 190 * st.grow, spread: 110 * st.grow, palette: greens, bark: 0x7A5A48, seed: seed &+ 3)
    }

    /// The animals on the leading side of the ring, low in the picture: Rabbit at the edge,
    /// two Raccoons and slow old Turtle, all turned toward the middle. `rabbitLooksUp` is the
    /// last scene's Rabbit, studying the sky.
    static func ringLeading(_ context: inout GraphicsContext, _ st: Kit.Stage, rabbit showRabbit: Bool) {
        let Hv: CGFloat = st.Hv
        if showRabbit {
            Kit.shadow(&context, 86, Hv + 84, width: 60)
            Art.group(&context, x: 86, y: Hv + 84, scale: 0.7, scaleX: -1) { g in
                rabbit(&g, pose: .sit, mood: .sly, look: CGPoint(x: -0.6, y: 0), mirrored: true)
            }
        }
        Kit.shadow(&context, 170, Hv + 56, width: 58)
        Art.group(&context, x: 170, y: Hv + 56, scale: 0.56, scaleX: -1) { g in
            raccoon(&g, pose: .sit, mirrored: true)
        }
        Kit.shadow(&context, 252, Hv + 72, width: 62)
        Art.group(&context, x: 252, y: Hv + 72, scale: 0.6, scaleX: -1) { g in
            raccoon(&g, pose: .sit, mirrored: true)
        }
        Kit.shadow(&context, 334, Hv + 102, width: 66)
        Art.group(&context, x: 334, y: Hv + 102, scale: 0.8, scaleX: -1) { g in
            turtle(&g)
        }
        Kit.grassTuft(&context, x: 30, baseY: Hv + 120, height: 34, color: 0x4F7A5A, seed: 3)
        Kit.grassTuft(&context, x: 300, baseY: Hv + 128, height: 26, color: 0x4F7A5A, seed: 4)
    }

    /// The far side of the ring, paler: Deer standing, a row of Squirrels.
    static func ringFar(_ context: inout GraphicsContext, _ st: Kit.Stage, deerX: CGFloat, squirrels spots: [CGFloat]) {
        let Hv: CGFloat = st.Hv
        Art.layer(&context, opacity: 0.86) { g in
            for spot in spots {
                Art.group(&g, x: spot, y: Hv + 20, scale: 0.4, scaleX: -1) { s in
                    Kit.beast(&s, squirrelLook(), pose: .sit, mood: .happy, mirrored: true)
                }
            }
            Art.group(&g, x: deerX - 76, y: Hv + 18, scale: 0.4) { s in
                Kit.beast(&s, squirrelLook(), pose: .sit, mood: .happy)
            }
            Kit.shadow(&g, deerX, Hv + 24, width: 70, alpha: 0.18)
            Art.group(&g, x: deerX, y: Hv + 24, scale: 0.62) { d in
                Kit.beast(&d, deerLook(), pose: .stand, mood: .happy)
            }
        }
    }
}

// MARK: - Scene 3: the dance (Possum steps into the ring)

extension PossumArt {
    static func danceScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 150)
        let light = evening()
        clearing(&context, st, light: light)
        meadow(&context, st, seed: 37, flower: 0xFFF2B8)
        Kit.designSpace(&context, st) { v in
            clearingEdge(&v, st, seed: 19)
            Kit.nearSpace(&v, st, anchorX: 0) { n in
                ringLeading(&n, st, rabbit: true)
            }
            Kit.nearSpace(&v, st, anchorX: 700) { n in
                let row: [CGFloat] = [508, 540, 572]
                ringFar(&n, st, deerX: 770, squirrels: row)
                danceSubject(&n, st)
            }
        }
        Kit.cornerLeaves(&context, size: size, corner: 1, color: ramp.deepColor, scale: 1.2, seed: 6)
        ArtStyle.finish(&context, size)
    }

    /// Bear on the trailing side of the ring, and Possum stepping into the middle, chest out,
    /// his tail in its red string held up behind him.
    static func danceSubject(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        Kit.shadow(&context, 836, Hv + 84, width: 130)
        Art.group(&context, x: 836, y: Hv + 84, scale: 0.85) { g in
            Kit.beast(&g, bearLook(), pose: .sit, mood: .happy, look: CGPoint(x: -0.5, y: 0))
        }
        Kit.shadow(&context, 630, Hv + 96, width: 84)
        Art.group(&context, x: 628, y: Hv + 96) { g in
            possumDancing(&g)
        }
        Kit.grassTuft(&context, x: 560, baseY: Hv + 134, height: 28, color: 0x4F7A5A, seed: 7)
        Kit.grassTuft(&context, x: 730, baseY: Hv + 140, height: 34, color: 0x3F6A4E, seed: 8)
    }

    /// Possum up on his hind legs, mid-step, singing (origin at his feet, facing LEFT), the
    /// wrapped tail held high behind him like a red ribbon.
    static func possumDancing(_ context: inout GraphicsContext) {
        let tail: [CGPoint] = tailFrom(.rear, CGPoint(x: 40, y: -4), CGPoint(x: 74, y: -60), CGPoint(x: 48, y: -112))
        cord(&context, tail, wrapped: true)
        // The loose end of the string, ready to be pulled.
        if let tip = tail.last {
            let end = Art.svg("M0,0 C8,-8 14,2 20,-6").applying(CGAffineTransform(translationX: tip.x, y: tip.y))
            Art.stroke(&context, end, Art.color(stringRed), width: 2)
        }
        possum(&context, pose: .rear, mood: .proud, singing: true)
    }
}

// MARK: - Scene 4: the grin (Possum flat on his back)

extension PossumArt {
    static func grinScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 160)
        let light = evening()
        clearing(&context, st, light: light)
        meadow(&context, st, seed: 43, flower: 0xFFF2B8)
        Kit.designSpace(&context, st) { v in
            clearingEdge(&v, st, seed: 27)
            Kit.nearSpace(&v, st, anchorX: 0) { n in
                ringLeading(&n, st, rabbit: false)
            }
            Kit.nearSpace(&v, st, anchorX: 660) { n in
                let row: [CGFloat] = [586, 616]
                ringFar(&n, st, deerX: 726, squirrels: row)
                grinSubject(&n, st)
            }
        }
        Kit.cornerLeaves(&context, size: size, corner: 1, color: ramp.deepColor, scale: 1.1, seed: 9)
        ArtStyle.finish(&context, size)
    }

    /// Possum on his back in the grass, grinning, the loose string and a drift of grey fluff
    /// beside him; Bear sitting down with a wide smile; Rabbit studying the sky.
    static func grinSubject(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        Kit.shadow(&context, 534, Hv + 46, width: 62)
        Art.group(&context, x: 534, y: Hv + 46, scale: 0.8, scaleX: -1) { g in
            rabbit(&g, pose: .sit, mood: .calm, look: CGPoint(x: 0.3, y: -1), mirrored: true)
        }
        Kit.shadow(&context, 830, Hv + 64, width: 130)
        Art.group(&context, x: 830, y: Hv + 64, scale: 0.85) { g in
            Kit.beast(&g, bearLook(), pose: .sit, mood: .proud, look: CGPoint(x: -0.4, y: 0.4))
            // His paws on his round sides: he laughed until he had to sit down.
            let paw: Color = Kit.beastTone(bearLook().body, 1.1)
            Art.stroke(&g, Art.svg("M-14,-74 C-2,-66 4,-56 0,-46"), paw, width: 15)
            Art.fill(&g, Art.ellipse(0, -44, 9, 7), Art.color(bearLook().dark))
        }
        let lift: CGFloat = (1 - st.fit) * 50
        Art.group(&context, x: 644, y: Hv + 106 - lift, scale: 1.15) { g in
            possumOnBack(&g)
            Art.group(&g, x: 56, y: 20) { s in
                looseString(&s)
            }
            Art.group(&g, x: 104, y: 4) { f in
                fluff(&f, count: 7, seed: 5)
            }
        }
        Kit.grassTuft(&context, x: 560, baseY: Hv + 140, height: 26, color: 0x4F7A5A, seed: 11)
    }
}
