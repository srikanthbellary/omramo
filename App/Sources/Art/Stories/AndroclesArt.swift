import SwiftUI
import OmramoCore

/// Concept art for "Androcles and the Lion", drawn in code (round 5; composed from the shared kit).
///
/// A Medium story with a LIGHT theme: every scene keeps a pale sky behind the dark words on
/// the leading pane. Part I is the dry hills of Roman North Africa; Part II is Rome: the long
/// racing ground (not the Colosseum, which was not yet built) and a street of painted stucco.
/// The cast and shared parts are in `AndroclesArt+Cast.swift`, the folded scenes in
/// `AndroclesArt+Folded.swift`, the cards, faces and cover in `AndroclesArt+Pictures.swift`.
enum AndroclesArt {
    /// Draws the picture called `name`. Returns false for a name this story does not have.
    static func paint(_ name: String, role: ArtRole, in context: inout GraphicsContext, size: CGSize) -> Bool {
        guard size.width > 0, size.height > 0 else { return false }
        switch (name, role) {
        case ("scene-hills", .sceneUnfolded): hillsScene(&context, size)
        case ("scene-hills", .sceneFolded): hillsFolded(&context, size)
        case ("scene-cave", .sceneUnfolded): caveScene(&context, size)
        case ("scene-cave", .sceneFolded): caveFolded(&context, size)
        case ("scene-arena", .sceneUnfolded): arenaScene(&context, size)
        case ("scene-arena", .sceneFolded): arenaFolded(&context, size)
        case ("scene-street", .sceneUnfolded): streetScene(&context, size)
        case ("scene-street", .sceneFolded): streetFolded(&context, size)
        case ("see-slavery", .picture): slaveryPicture(&context, size)
        case ("see-north-africa", .picture): northAfricaPicture(&context, size)
        case ("see-old-book", .picture): oldBookPicture(&context, size)
        case ("char-androcles", .portrait): androclesPortrait(&context, size)
        case ("char-lion", .portrait): lionPortrait(&context, size)
        case ("face-androcles", .face): androclesFace(&context, size)
        case ("face-lion", .face): lionFace(&context, size)
        case ("face-emperor", .face): emperorFace(&context, size)
        case ("cover", .cover): cover(&context, size)
        default:
            return false
        }
        return true
    }
}

// MARK: - scene-hills: Androcles hurries up into the dry hills

extension AndroclesArt {
    static func hillsScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 150)
        let light = day()
        hillsFar(&context, st, light)
        Kit.designSpace(&context, st) { v in
            Kit.nearSpace(&v, st) { n in
                hillsSlope(&n, st.Hv)
            }
        }
        hillsNear(&context, st)
        ArtStyle.finish(&context, size)
    }

    /// The far strip of blue sea and the band of golden wheat plain under the horizon line
    /// `H`, with the small white town of page 1 on the shore when `town` is true.
    static func farPlain(_ context: inout GraphicsContext, width w: CGFloat, horizon H: CGFloat, scale s: CGFloat, town: Bool) {
        let seaTop: CGFloat = H - 34 * s
        let seaBottom: CGFloat = H - 18 * s
        let sea: Kit.Stops = [(Art.color(0xB7DBE6), 0), (Art.color(0x7DB6D0), 1)]
        Art.fillLinear(&context, Art.rect(0, seaTop, w, seaBottom - seaTop), sea, from: CGPoint(x: 0, y: seaTop), to: CGPoint(x: 0, y: seaBottom))
        Art.fill(&context, Art.rect(0, seaTop, w, 1.2), Art.color(0xFFFFFF, 0.5))
        let wheat: Kit.Stops = [(Art.color(0xF0D588), 0), (Art.color(0xE2B95A), 1)]
        let wheatDepth: CGFloat = H - seaBottom + 2
        Art.fillLinear(&context, Art.rect(0, seaBottom, w, wheatDepth), wheat, from: CGPoint(x: 0, y: seaBottom), to: CGPoint(x: 0, y: H + 2))
        let shore = Kit.ridge(width: w, y: seaBottom, amp: 2.5 * s, seed: 3, bottom: seaBottom + 4 * s)
        Art.fill(&context, shore, Art.color(0xF0D588))
        var rows = Path()
        for i in 0..<10 {
            let x: CGFloat = w * (CGFloat(i) + 0.5) / 10
            rows.move(to: CGPoint(x: x, y: seaBottom + 3 * s))
            rows.addLine(to: CGPoint(x: x - 26 * s, y: H))
        }
        Art.stroke(&context, rows, Art.color(0xC99A3E, 0.35), width: 1)
        if town {
            let white = Art.color(0xFBF6EA)
            let roof = Art.color(0xD9A27A)
            let baseY: CGFloat = seaBottom + 3 * s
            Kit.farHouse(&context, cx: 150, baseY: baseY, width: 14 * s, height: 9 * s, wall: white, roof: roof, flat: true)
            Kit.farHouse(&context, cx: 150 + 15 * s, baseY: baseY + s, width: 12 * s, height: 7 * s, wall: Art.color(0xF3E2BC), roof: roof, flat: true)
            Kit.farHouse(&context, cx: 150 - 14 * s, baseY: baseY + s, width: 11 * s, height: 7 * s, wall: white, roof: roof)
        }
        ArtStyle.atmosphere(&context, width: w, top: seaTop - 10, bottom: H, color: Art.color(0xF6E8C8), alpha: 0.22)
    }

    /// Sky, the far sea and wheat plain, the folds of dry hill and the quiet leading side.
    static func hillsFar(_ context: inout GraphicsContext, _ st: Kit.Stage, _ light: Kit.Light) {
        let w: CGFloat = st.w
        let H: CGFloat = st.H
        let f: CGFloat = st.far
        let d: CGFloat = st.depth
        Kit.sky(&context, st.size, horizon: H, light: light)
        Kit.cloud(&context, 610, 140 * st.fit, scale: 0.8, color: Art.color(0xFFFFFF, 0.6))
        Kit.cloud(&context, 300, 90 * st.fit, scale: 0.5, color: Art.color(0xFFFFFF, 0.4))
        farPlain(&context, width: w, horizon: H, scale: f, town: true)
        Kit.birds(&context, 330, H - 62 * f, scale: 0.8, color: Art.color(0x8A7A6A, 0.7))
        Kit.ground(&context, width: w, top: H, bottom: st.h, stops: ochreGround())
        let fold = Kit.ridge(width: w, y: H - 2 * f, amp: 10 * f, seed: 7, bottom: H + 28)
        Art.fill(&context, fold, light.mid)
        Kit.farTrees(&context, x0: 10, x1: 440, baseY: H + 5, height: 9 * f, count: 9, color: Art.color(0x9AA070), seed: 6)
        let lower = Kit.ridge(width: w, y: H + 24, amp: 8 * f, seed: 12, bottom: H + 64)
        Art.fill(&context, lower, light.near.opacity(0.45))
        Kit.farTrees(&context, x0: 40, x1: 420, baseY: H + 34, height: 12 * f, count: 5, color: Art.color(0x8A9264), seed: 9)
        Kit.rock(&context, cx: 96, baseY: H + d * 0.56, width: 70 * f, height: 34 * f, color: 0xD3A566, seed: 21)
        thornBush(&context, x: 262, baseY: H + d * 0.46, width: 54 * f, seed: 22)
        let dry = CGRect(x: 0, y: H + 34, width: 440, height: max(10, d - 54))
        Kit.grass(&context, in: dry, count: 30, seed: 23, color: Art.color(0xBF9A5E, 0.6), height: 8)
        Kit.pebbles(&context, in: dry, count: 12, seed: 24, color: 0xC9A070)
    }

    /// The near flank of the hill on the trailing side: the olive tree, thorn scrub, hot
    /// rocks, and Androcles hurrying up it with his empty water skin, glancing back.
    static func hillsSlope(_ context: inout GraphicsContext, _ Hv: CGFloat) {
        var slope = Path()
        slope.move(to: CGPoint(x: 430, y: Hv + 44))
        slope.addQuadCurve(to: CGPoint(x: 900, y: Hv - 70), control: CGPoint(x: 640, y: Hv + 30))
        slope.addLine(to: CGPoint(x: 900, y: Hv + 420))
        slope.addLine(to: CGPoint(x: 300, y: Hv + 420))
        slope.addQuadCurve(to: CGPoint(x: 430, y: Hv + 44), control: CGPoint(x: 400, y: Hv + 200))
        slope.closeSubpath()
        Kit.solid(&context, slope, stops: ochreGround(), light: 0.24, shade: 0.12, rim: 2.4)
        var folds = Path()
        folds.move(to: CGPoint(x: 470, y: Hv + 74))
        folds.addQuadCurve(to: CGPoint(x: 900, y: Hv - 20), control: CGPoint(x: 680, y: Hv + 66))
        folds.move(to: CGPoint(x: 440, y: Hv + 130))
        folds.addQuadCurve(to: CGPoint(x: 900, y: Hv + 60), control: CGPoint(x: 660, y: Hv + 130))
        Art.stroke(&context, folds, Art.color(0xA9743F, 0.3), width: ArtStyle.detailLine)
        thornBush(&context, x: 716, baseY: Hv + 6, width: 62, seed: 2)
        Kit.olive(&context, x: 806, baseY: Hv - 20, height: 190, seed: 3)
        Kit.palm(&context, x: 506, baseY: Hv + 48, height: 58, lean: 4, fronds: 0x7C8F5A, trunk: 0x8A6A48, seed: 4)
        Kit.rock(&context, cx: 548, baseY: Hv + 98, width: 96, height: 52, color: rockHex, seed: 3)
        let dry = CGRect(x: 470, y: Hv + 52, width: 400, height: 90)
        Kit.grass(&context, in: dry, count: 26, seed: 8, color: Art.color(0xB8935A, 0.7), height: 9)
        Kit.pebbles(&context, in: CGRect(x: 480, y: Hv + 84, width: 380, height: 60), count: 14, seed: 5, color: 0xC9A070)
        // The dust his heels kick up, behind him (he climbs to the right).
        var dust = Path()
        dust.addEllipse(in: CGRect(x: 578, y: Hv + 54, width: 26, height: 14))
        dust.addEllipse(in: CGRect(x: 560, y: Hv + 60, width: 18, height: 10))
        dust.addEllipse(in: CGRect(x: 594, y: Hv + 46, width: 16, height: 10))
        Art.fill(&context, dust, Art.color(0xF6E3BC, 0.55))
        Kit.shadow(&context, 642, Hv + 72, width: 72)
        Art.group(&context, x: 640, y: Hv + 70, scaleX: -1) { g in
            androcles(&g, pose: .walk, look: CGPoint(x: 0.9, y: 0.1), mouth: .oh, mirrored: true)
        }
        Kit.rock(&context, cx: 762, baseY: Hv + 110, width: 130, height: 64, color: 0xCF9850, seed: 9)
        thornBush(&context, x: 858, baseY: Hv + 98, width: 104, seed: 6)
    }

    /// Near framing, and the deeper foreground of a tall window.
    static func hillsNear(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        Kit.cornerLeaves(&context, size: st.size, corner: 2, color: Art.color(0x6B5A3A), scale: 0.9, seed: 3)
        if st.tall > 0.25 {
            let floor: CGFloat = st.h
            Kit.rock(&context, cx: 130, baseY: floor - 70, width: 120, height: 60, color: 0xCF9850, seed: 14)
            thornBush(&context, x: 316, baseY: floor - 40, width: 130, seed: 11)
            Kit.pebbles(&context, in: CGRect(x: 20, y: floor - 240, width: 400, height: 150), count: 24, seed: 15, color: 0xC9A070)
            Kit.grass(&context, in: CGRect(x: 10, y: floor - 230, width: 420, height: 180), count: 34, seed: 16, color: Art.color(0xB8935A, 0.7), height: 11)
        }
    }
}

// MARK: - scene-cave: the thorn, seen from outside in full sun

extension AndroclesArt {
    static func caveGround() -> Kit.Stops {
        [(Art.color(0xF2DDAE), 0), (Art.color(0xE2B878), 0.5), (Art.color(0xC9914E), 1)]
    }

    static func caveScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 150)
        let light = goldDay()
        caveFar(&context, st, light)
        Kit.designSpace(&context, st) { v in
            Kit.nearSpace(&v, st) { n in
                caveRock(&n, st.Hv)
                caveFriends(&n, st.Hv, paw: 1)
            }
        }
        caveNear(&context, st)
        ArtStyle.finish(&context, size)
    }

    /// Pale gold sky, a far ochre ridge, and the low line of pale sunlit rock on the leading
    /// side with a little scrub and a dwarf palm under the words.
    static func caveFar(_ context: inout GraphicsContext, _ st: Kit.Stage, _ light: Kit.Light) {
        let w: CGFloat = st.w
        let H: CGFloat = st.H
        let f: CGFloat = st.far
        let d: CGFloat = st.depth
        Kit.sky(&context, st.size, horizon: H, light: light)
        Kit.sun(&context, 96, H - 118 * f, 20 * f, light: light)
        Kit.cloud(&context, 520, 120 * st.fit, scale: 0.6, color: Art.color(0xFFFFFF, 0.45))
        Kit.ranges(&context, width: w, horizon: H, scale: f, light: light, seed: 5)
        Kit.ground(&context, width: w, top: H, bottom: st.h, stops: caveGround())
        let pale: Kit.Stops = [(Art.color(0xF6E2B4), 0), (Art.color(0xE6C088), 1)]
        Kit.mound(&context, x0: -30, x1: 250, baseY: H + 8, height: 28 * f, bottom: H + 10, stops: pale, crest: 0.4)
        Kit.mound(&context, x0: 196, x1: 470, baseY: H + 14, height: 20 * f, bottom: H + 16, stops: pale, crest: 0.6)
        Kit.farTrees(&context, x0: 20, x1: 430, baseY: H + 20, height: 10 * f, count: 6, color: Art.color(0x9AA070), seed: 8)
        thornBush(&context, x: 156, baseY: H + d * 0.44, width: 60 * f, seed: 31)
        Kit.palm(&context, x: 352, baseY: H + d * 0.4, height: 54 * f, lean: -4, fronds: 0x7C8F5A, trunk: 0x8A6A48, seed: 7)
        Kit.rock(&context, cx: 70, baseY: H + d * 0.72, width: 80 * f, height: 36 * f, color: 0xDDB070, seed: 33)
        let dry = CGRect(x: 0, y: H + 30, width: 450, height: max(10, d - 50))
        Kit.grass(&context, in: dry, count: 26, seed: 34, color: Art.color(0xBF9A5E, 0.6), height: 8)
        Kit.pebbles(&context, in: dry, count: 12, seed: 35, color: 0xC9A070)
    }

    /// The two friends in front of the cave: the big Lion sitting with one paw held out and
    /// Androcles kneeling to it, his fingers on the thorn (`paw` 1) or the paw bound (`paw` 2).
    static func caveFriends(_ context: inout GraphicsContext, _ Hv: CGFloat, paw: Int) {
        thornBush(&context, x: 520, baseY: Hv + 64, width: 72, seed: 4)
        let mood: Kit.BeastMood = paw == 1 ? .sad : .calm
        Kit.shadow(&context, 762, Hv + 74, width: 200)
        Art.group(&context, x: 745, y: Hv + 72, scale: 1.2) { g in
            lionSitting(&g, mood: mood, look: CGPoint(x: -0.6, y: 0.6), paw: paw, nod: -8)
        }
        Kit.shadow(&context, 566, Hv + 78, width: 90)
        Art.group(&context, x: 570, y: Hv + 76, scaleX: -1) { g in
            androcles(&g, pose: .kneel, look: CGPoint(x: -0.4, y: 0.7), mouth: .flat, mirrored: true)
        }
        Kit.rock(&context, cx: 498, baseY: Hv + 116, width: 110, height: 56, color: 0xCF9850, seed: 12)
        // The flat rock where he lays his share for the noon sun to cook.
        Kit.rock(&context, cx: 672, baseY: Hv + 126, width: 124, height: 24, color: 0xDDB070, seed: 13)
        thornBush(&context, x: 874, baseY: Hv + 112, width: 96, seed: 9)
        Kit.pebbles(&context, in: CGRect(x: 480, y: Hv + 90, width: 390, height: 50), count: 12, seed: 14, color: 0xC9A070)
    }

    /// Near framing, and the deeper foreground of a tall window.
    static func caveNear(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        Kit.cornerLeaves(&context, size: st.size, corner: 2, color: Art.color(0x6B5A3A), scale: 0.9, seed: 7)
        if st.tall > 0.25 {
            let floor: CGFloat = st.h
            Kit.rock(&context, cx: 150, baseY: floor - 60, width: 130, height: 62, color: 0xCF9850, seed: 41)
            thornBush(&context, x: 330, baseY: floor - 36, width: 120, seed: 42)
            Kit.pebbles(&context, in: CGRect(x: 20, y: floor - 240, width: 420, height: 160), count: 24, seed: 43, color: 0xC9A070)
            Kit.grass(&context, in: CGRect(x: 10, y: floor - 230, width: 430, height: 180), count: 30, seed: 44, color: Art.color(0xB8935A, 0.7), height: 11)
        }
    }
}

// MARK: - scene-arena: the long racing ground of Rome

extension AndroclesArt {
    /// The height of wall and stands together at `x`: low and far on the leading side,
    /// near and high on the trailing side.
    static func arenaRise(_ x: CGFloat, _ f: CGFloat) -> CGFloat {
        let t: CGFloat = max(0, min(1.1, x / 892))
        return (40 + 150 * t * t) * f
    }

    static func arenaScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 170)
        let light = morning()
        let H: CGFloat = st.H
        let f: CGFloat = st.far
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.cloud(&context, 250, 100 * st.fit, scale: 0.6, color: Art.color(0xFFFFFF, 0.5))
        arenaStands(&context, horizon: H, scale: f)
        arenaBox(&context, horizon: H, scale: f)
        arenaSand(&context, st)
        arenaGate(&context, x: 838, horizon: H, scale: f)
        arenaBoard(&context, x: 300, horizon: H, scale: f)
        Kit.designSpace(&context, st) { v in
            Kit.nearSpace(&v, st) { n in
                arenaPair(&n, st.Hv)
            }
        }
        arenaNear(&context, st)
        ArtStyle.finish(&context, size, wash: 0.1, vignette: 0.07)
    }

    /// The plain high wall and, above it, the tiers of tiny spectators under cloth awnings.
    static func arenaStands(_ context: inout GraphicsContext, horizon H: CGFloat, scale f: CGFloat) {
        var stands = Path()
        var wall = Path()
        var coping = Path()
        stands.move(to: CGPoint(x: 0, y: H))
        wall.move(to: CGPoint(x: 0, y: H))
        var x: CGFloat = 0
        while x <= 900 {
            let rise: CGFloat = arenaRise(x, f)
            stands.addLine(to: CGPoint(x: x, y: H - rise))
            wall.addLine(to: CGPoint(x: x, y: H - rise * 0.55))
            if x == 0 {
                coping.move(to: CGPoint(x: x, y: H - rise * 0.55))
            } else {
                coping.addLine(to: CGPoint(x: x, y: H - rise * 0.55))
            }
            x += 20
        }
        stands.addLine(to: CGPoint(x: 900, y: H))
        stands.closeSubpath()
        wall.addLine(to: CGPoint(x: 900, y: H))
        wall.closeSubpath()
        let seatStops: Kit.Stops = [(Art.color(0xE3D0AC), 0), (Art.color(0xD3BB94), 1)]
        Art.fillLinear(&context, stands, seatStops, from: CGPoint(x: 0, y: H - 190 * f), to: CGPoint(x: 0, y: H))
        arenaCrowd(&context, horizon: H, scale: f)
        arenaAwnings(&context, horizon: H, scale: f)
        let wallStops: Kit.Stops = [(Art.color(0xF4E8CC), 0), (Art.color(0xE4D0A8), 1)]
        Art.fillLinear(&context, wall, wallStops, from: CGPoint(x: 0, y: H - 105 * f), to: CGPoint(x: 0, y: H))
        Art.clipped(&context, to: wall) { g in
            let side: Kit.Stops = [(ArtStyle.coolShade.opacity(0), 0), (ArtStyle.coolShade.opacity(0.1), 1)]
            Art.fillLinear(&g, Art.rect(0, H - 110 * f, 900, 110 * f), side, from: CGPoint(x: 500, y: 0), to: CGPoint(x: 900, y: 0))
            Art.fill(&g, Art.rect(0, H - 7, 900, 7), ArtStyle.coolShade.opacity(0.1))
            ArtStyle.tooth(&g, in: CGRect(x: 440, y: H - 110 * f, width: 460, height: 110 * f), seed: 52, alpha: 0.06)
        }
        Art.stroke(&context, coping, Art.color(0xFFF8E6, 0.9), width: 2.2 * f)
        let under = coping.applying(CGAffineTransform(translationX: 0, y: 2.4 * f))
        Art.stroke(&context, under, Art.color(0xB89A70, 0.5), width: 1.2)
    }

    /// Three curved tiers of far spectators between the wall top and the top of the stands.
    static func arenaCrowd(_ context: inout GraphicsContext, horizon H: CGFloat, scale f: CGFloat) {
        var random = ArtRandom(61)
        var white = Path()
        var ochre = Path()
        var red = Path()
        var blue = Path()
        var tiers = Path()
        for row in 0..<3 {
            let part: CGFloat = 0.62 + 0.13 * CGFloat(row)
            var x: CGFloat = 4
            tiers.move(to: CGPoint(x: 0, y: H - arenaRise(0, f) * (part - 0.06)))
            while x < 896 {
                let rise: CGFloat = arenaRise(x, f)
                let y: CGFloat = H - rise * part
                let r: CGFloat = max(1.1, rise * 0.035)
                let dot = CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2.3)
                let pick: CGFloat = Kit.rnd(&random)
                if pick < 0.42 {
                    white.addEllipse(in: dot)
                } else if pick < 0.7 {
                    ochre.addEllipse(in: dot)
                } else if pick < 0.86 {
                    red.addEllipse(in: dot)
                } else {
                    blue.addEllipse(in: dot)
                }
                tiers.addLine(to: CGPoint(x: x, y: H - rise * (part - 0.06)))
                x += r * (2.4 + Kit.rnd(&random) * 1.4)
            }
        }
        Art.stroke(&context, tiers, Art.color(0xB89A70, 0.45), width: 1)
        Art.fill(&context, white, Art.color(0xFBF4E4))
        Art.fill(&context, ochre, Art.color(0xD9A45F))
        Art.fill(&context, red, Art.color(0xC8472E, 0.8))
        Art.fill(&context, blue, Art.color(0x7F93AD))
    }

    /// Cloth awnings slung between poles along the top of the stands: plain and pale far
    /// away on the leading side, striped cream and dull red where they are near.
    static func arenaAwnings(_ context: inout GraphicsContext, horizon H: CGFloat, scale f: CGFloat) {
        let posts: [CGFloat] = [0, 60, 125, 195, 270, 350, 436, 528, 626, 730, 840, 960]
        var poles = Path()
        for i in 0..<(posts.count - 1) {
            let x0: CGFloat = posts[i]
            let x1: CGFloat = posts[i + 1]
            let r0: CGFloat = arenaRise(x0, f)
            let r1: CGFloat = arenaRise(x1, f)
            let top0: CGFloat = H - r0 * 1.2
            let top1: CGFloat = H - r1 * 1.2
            let low0: CGFloat = H - r0 * 1.04
            let low1: CGFloat = H - r1 * 1.04
            let midX: CGFloat = (x0 + x1) / 2
            var cloth = Path()
            cloth.move(to: CGPoint(x: x0, y: top0))
            cloth.addQuadCurve(to: CGPoint(x: x1, y: top1), control: CGPoint(x: midX, y: (top0 + top1) / 2 + r1 * 0.07))
            cloth.addLine(to: CGPoint(x: x1, y: low1))
            cloth.addQuadCurve(to: CGPoint(x: x0, y: low0), control: CGPoint(x: midX, y: (low0 + low1) / 2 + r1 * 0.05))
            cloth.closeSubpath()
            let near: Double = Double(min(1, max(0.4, x1 / 700)))
            let striped: Bool = i % 2 == 1 && x0 >= 436
            let color: Color = striped ? Art.color(0xCB6B4C, 0.9) : Art.color(0xF8EED6, near)
            Art.fill(&context, cloth, color)
            poles.move(to: CGPoint(x: x0, y: H - r0 * 0.98))
            poles.addLine(to: CGPoint(x: x0, y: top0))
        }
        Art.stroke(&context, poles, Art.color(0x8A6A48, 0.7), width: 1.4)
    }

    /// The Emperor's roofed stone box in the stands: two plain columns, a purple cloth over
    /// the front rail, and the small Emperor in his white toga lifting one finger.
    static func arenaBox(_ context: inout GraphicsContext, horizon H: CGFloat, scale f: CGFloat) {
        let cx: CGFloat = 742
        let rise: CGFloat = arenaRise(cx, f)
        let floorY: CGFloat = H - rise * 0.55
        let topY: CGFloat = H - rise * 1.16
        let half: CGFloat = 52 * f
        let inside = Art.rect(cx - half, topY, half * 2, floorY - topY)
        let shadeStops: Kit.Stops = [(Art.color(0x8E6A62), 0), (Art.color(0xB08A74), 1)]
        Art.fillLinear(&context, inside, shadeStops, from: CGPoint(x: 0, y: topY), to: CGPoint(x: 0, y: floorY))
        Art.group(&context, x: cx + 6 * f, y: floorY + 16 * f, scale: 0.36 * f) { g in
            emperor(&g, pose: .reach)
        }
        Kit.column(&context, cx: cx - half, baseY: floorY, width: 9 * f, height: floorY - topY, color: 0xF1E4C8)
        Kit.column(&context, cx: cx + half, baseY: floorY, width: 9 * f, height: floorY - topY, color: 0xF1E4C8)
        let gable = Art.polygon([
            CGPoint(x: cx - half - 10 * f, y: topY), CGPoint(x: cx, y: topY - 18 * f), CGPoint(x: cx + half + 10 * f, y: topY),
        ])
        Kit.solid(&context, gable, Art.color(tileHex), light: 0.26, shade: 0.2)
        let slab = Art.rect(cx - half - 9 * f, topY - 2 * f, half * 2 + 18 * f, 6 * f, radius: 1.5)
        Kit.solid(&context, slab, Art.color(0xF1E4C8), light: 0.24, shade: 0.16)
        let rail = Art.rect(cx - half - 4 * f, floorY - 9 * f, half * 2 + 8 * f, 7 * f, radius: 1.5)
        Kit.solid(&context, rail, Art.color(0xEBDDBE), light: 0.24, shade: 0.16)
        var cloth = Path()
        let left: CGFloat = cx - half + 10 * f
        let right: CGFloat = cx + half - 10 * f
        cloth.move(to: CGPoint(x: left, y: floorY - 10 * f))
        cloth.addLine(to: CGPoint(x: right, y: floorY - 10 * f))
        cloth.addLine(to: CGPoint(x: right, y: floorY + 22 * f))
        cloth.addQuadCurve(to: CGPoint(x: cx, y: floorY + 24 * f), control: CGPoint(x: (cx + right) / 2, y: floorY + 32 * f))
        cloth.addQuadCurve(to: CGPoint(x: left, y: floorY + 22 * f), control: CGPoint(x: (cx + left) / 2, y: floorY + 32 * f))
        cloth.closeSubpath()
        Kit.solid(&context, cloth, Art.color(purpleHex), light: 0.26, shade: 0.24)
        let border = Art.line(left + 2 * f, floorY + 16 * f, right - 2 * f, floorY + 16 * f)
        Art.stroke(&context, border, Art.color(0xE3BC52, 0.9), width: max(1, 1.6 * f), cap: .butt)
    }

    /// The pale raked sand, from the foot of the wall to the bottom edge.
    static func arenaSand(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.H
        let d: CGFloat = st.depth
        Kit.ground(&context, width: st.w, top: H, bottom: st.h, stops: sandGround())
        var rake = Path()
        for i in 0..<8 {
            let t: CGFloat = (CGFloat(i) + 0.6) / 8
            let y: CGFloat = H + d * t * t
            rake.move(to: CGPoint(x: -10, y: y + 6 * t))
            rake.addQuadCurve(to: CGPoint(x: 902, y: y - 4 * t), control: CGPoint(x: 420, y: y + 14 * t))
        }
        Art.stroke(&context, rake, Art.color(0xCDAE78, 0.35), width: 1.2)
        let foot: Kit.Stops = [(ArtStyle.coolShade.opacity(0.1), 0), (ArtStyle.coolShade.opacity(0), 1)]
        Art.fillLinear(&context, Art.rect(0, H, st.w, 16), foot, from: CGPoint(x: 0, y: H), to: CGPoint(x: 0, y: H + 16))
    }

    /// The barred wooden gate low in the wall.
    static func arenaGate(_ context: inout GraphicsContext, x: CGFloat, horizon H: CGFloat, scale f: CGFloat) {
        let rise: CGFloat = arenaRise(x, f)
        let w: CGFloat = 40 * f
        let h: CGFloat = rise * 0.4
        let left: CGFloat = x - w / 2
        let top: CGFloat = H - h
        let frame = Art.rect(left - 4 * f, top - 4 * f, w + 8 * f, h + 4 * f, radius: 2)
        Kit.solid(&context, frame, Art.color(0xD9C29A), light: 0.2, shade: 0.14)
        Art.fill(&context, Art.rect(left, top, w, h), Art.color(0x4A3530))
        var bars = Path()
        for i in 0..<5 {
            let bx: CGFloat = left + w * (CGFloat(i) + 0.5) / 5
            bars.move(to: CGPoint(x: bx, y: top))
            bars.addLine(to: CGPoint(x: bx, y: H))
        }
        bars.move(to: CGPoint(x: left, y: top + h * 0.3))
        bars.addLine(to: CGPoint(x: left + w, y: top + h * 0.3))
        bars.move(to: CGPoint(x: left, y: top + h * 0.74))
        bars.addLine(to: CGPoint(x: left + w, y: top + h * 0.74))
        Art.stroke(&context, bars, Art.color(0x8A5E3C), width: max(1.6, 3 * f), cap: .butt)
    }

    /// The story written on a whitened board, carried along the foot of the wall (page 9).
    static func arenaBoard(_ context: inout GraphicsContext, x: CGFloat, horizon H: CGFloat, scale f: CGFloat) {
        let attendant = Kit.Person(skin: 0xC99A72, hair: 0x3A2A22, garment: .tunic, cloth: 0xB98A5A, trim: 0x7A5234, legs: 0xC99A72, showsEyeWhite: false)
        Kit.shadow(&context, x, H + 9 * f, width: 16 * f, alpha: 0.2)
        Art.group(&context, x: x, y: H + 8 * f, scale: 0.2 * f) { g in
            Kit.person(&g, attendant, pose: .carry, mouth: .smile)
        }
        Kit.propShaft(&context, x - 9 * f, H + 2 * f, x - 9 * f, H - 46 * f, wood: 0x8A6A48, width: max(1.2, 1.6 * f))
        let board = Art.rect(x - 22 * f, H - 60 * f, 26 * f, 17 * f, radius: 1)
        Kit.solid(&context, board, Art.color(0xFBF6EA), light: 0.1, shade: 0.12)
        var lines = Path()
        for i in 0..<3 {
            let y: CGFloat = H - 56 * f + CGFloat(i) * 4.4 * f
            let short: CGFloat = i == 2 ? 9 : 0
            lines.move(to: CGPoint(x: x - 19 * f, y: y))
            lines.addLine(to: CGPoint(x: x - short * f, y: y))
        }
        Art.stroke(&context, lines, Art.color(0x4A3A34, 0.7), width: max(0.8, 1.1 * f), cap: .butt, dash: [2.5, 1.5])
    }

    /// The man and the lion, small and alone on the sand, a few steps apart.
    static func arenaPair(_ context: inout GraphicsContext, _ Hv: CGFloat) {
        Kit.shadow(&context, 584, Hv + 88, width: 56, alpha: 0.3)
        Art.group(&context, x: 580, y: Hv + 86, scale: 0.74, scaleX: -1) { g in
            androcles(&g, pose: .stand, look: CGPoint(x: -0.8, y: 0), mouth: .oh, bag: false, mirrored: true)
        }
        Kit.shadow(&context, 774, Hv + 80, width: 150, alpha: 0.3)
        Art.group(&context, x: 770, y: Hv + 78, scale: 0.86) { g in
            lion(&g, pose: .stand, mood: .calm, look: CGPoint(x: -0.8, y: -0.2), thin: true)
        }
    }

    /// The shade of the doorway he came through and his footprints across the raked sand.
    static func arenaNear(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let floor: CGFloat = st.h
        var wedge = Path()
        wedge.move(to: CGPoint(x: 892, y: floor - st.depth * 0.5))
        wedge.addLine(to: CGPoint(x: 892, y: floor))
        wedge.addLine(to: CGPoint(x: 690, y: floor))
        wedge.closeSubpath()
        Art.fill(&context, wedge, ArtStyle.coolShade.opacity(0.12))
        let px: CGFloat = 892 - 312 * st.grow * st.fit
        let py: CGFloat = st.H + 88 * st.grow * st.fit
        let endY: CGFloat = min(floor - 8, py + 70)
        var prints = Path()
        for i in 0..<8 {
            let t: CGFloat = CGFloat(i) / 7
            let x: CGFloat = Kit.mix(px + 34, 872, t)
            let y: CGFloat = Kit.mix(py + 2, endY, t * t)
            let side: CGFloat = i % 2 == 0 ? -3 : 3
            let r: CGFloat = 3 + 2.5 * t
            prints.addEllipse(in: CGRect(x: x - r * 1.5, y: y + side - r * 0.5, width: r * 3, height: r))
        }
        Art.fill(&context, prints, Art.color(0xB8956A, 0.4))
        if st.tall > 0.25 {
            let grains = CGRect(x: 0, y: st.H + 60, width: 892, height: st.depth - 70)
            Kit.flecks(&context, in: grains, count: 70, seed: 53, color: Art.color(0xFFFFFF, 0.4), radius: 0.8...1.8)
            Art.fill(&context, Art.ellipse(180, floor - 60, 220, 26), ArtStyle.coolShade.opacity(0.05))
        }
    }
}

// MARK: - scene-street: the last walk through Rome

extension AndroclesArt {
    static func streetScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 150)
        let light = morning()
        streetFar(&context, st, light)
        Kit.designSpace(&context, st) { v in
            streetFronts(&v, st.Hv)
            let falling = CGRect(x: 470, y: st.Hv - 250, width: 410, height: 290)
            petals(&v, in: falling, count: 50, seed: 61)
            Kit.nearSpace(&v, st, anchorX: 700) { n in
                Art.group(&n, x: 640, y: st.Hv + 80) { g in
                    streetPair(&g)
                }
            }
        }
        streetNear(&context, st)
        ArtStyle.finish(&context, size)
    }

    /// Pale morning sky, the far jumble of low tiled roofs, the paving, and the one low
    /// plain cream wall across the leading side under the words.
    static func streetFar(_ context: inout GraphicsContext, _ st: Kit.Stage, _ light: Kit.Light) {
        let w: CGFloat = st.w
        let H: CGFloat = st.H
        let f: CGFloat = st.far
        Kit.sky(&context, st.size, horizon: H, light: light)
        Kit.cloud(&context, 280, 96 * st.fit, scale: 0.55, color: Art.color(0xFFFFFF, 0.5))
        Kit.cloud(&context, 610, 150 * st.fit, scale: 0.7, color: Art.color(0xFFFFFF, 0.55))
        streetRoofs(&context, width: w, horizon: H, scale: f)
        ArtStyle.atmosphere(&context, width: w, top: H - 130 * f, bottom: H, color: light.haze, alpha: 0.34)
        Kit.ground(&context, width: w, top: H, bottom: st.h, stops: pavingGround())
        streetPaving(&context, width: w, top: H, bottom: st.h, scale: f, seed: 9)
        streetLowWall(&context, horizon: H, scale: f)
    }

    /// Far low houses with pale walls and tiled roofs, and a few dark cypresses among them.
    static func streetRoofs(_ context: inout GraphicsContext, width w: CGFloat, horizon H: CGFloat, scale f: CGFloat) {
        var random = ArtRandom(91)
        let base: CGFloat = H - 40 * f
        let roof = Art.color(0xD69A7A)
        Kit.farTrees(&context, x0: 60, x1: 860, baseY: base - 4 * f, height: 40 * f, count: 5, color: Art.color(0xA8AE88), conifer: true, seed: 92)
        var x: CGFloat = -10
        while x < w + 20 {
            let bw: CGFloat = (34 + Kit.rnd(&random) * 40) * f
            let bh: CGFloat = (26 + Kit.rnd(&random) * 40) * f
            let pick: CGFloat = Kit.rnd(&random)
            var wall: Color = Art.color(0xF1DDB6)
            if pick > 0.75 {
                wall = Art.color(0xE6B8A0)
            } else if pick > 0.4 {
                wall = Art.color(0xEBCB9E)
            }
            Kit.farHouse(&context, cx: x + bw / 2, baseY: base, width: bw, height: bh, wall: wall, roof: roof)
            x += bw * 0.8
        }
    }

    /// The one low plain cream wall with its tiled coping, across the leading pane.
    static func streetLowWall(_ context: inout GraphicsContext, horizon H: CGFloat, scale f: CGFloat) {
        let top: CGFloat = H - 56 * f
        let rect = CGRect(x: -4, y: top, width: 480, height: H - top + 4)
        Kit.wall(&context, rect: rect, color: creamHex)
        let coping = Art.rect(-4, top - 5 * f, 482, 7 * f, radius: 2)
        Kit.solid(&context, coping, Art.color(tileHex), light: 0.26, shade: 0.2)
        Art.fill(&context, Art.rect(-4, top + 2 * f, 482, 2.5 * f), ArtStyle.coolShade.opacity(0.1))
    }

    /// Big paving stones laid in rows that widen toward the viewer.
    static func streetPaving(_ context: inout GraphicsContext, width w: CGFloat, top: CGFloat, bottom: CGFloat, scale s: CGFloat, seed: UInt32) {
        let depth: CGFloat = bottom - top
        guard depth > 4 else { return }
        var random = ArtRandom(seed)
        var joints = Path()
        var y: CGFloat = top + 6 * s
        var row: Int = 0
        let k: CGFloat = max(0.6, s)
        while y < bottom && row < 16 {
            let t: CGFloat = (y - top) / depth
            let rowH: CGFloat = (8 + 30 * t) * k
            joints.move(to: CGPoint(x: 0, y: y))
            joints.addLine(to: CGPoint(x: w, y: y))
            let stone: CGFloat = rowH * 2.2
            var x: CGFloat = -Kit.rnd(&random) * stone
            while x < w {
                joints.move(to: CGPoint(x: x, y: y))
                joints.addLine(to: CGPoint(x: x - rowH * 0.15, y: y + rowH))
                x += stone * (0.8 + Kit.rnd(&random) * 0.5)
            }
            y += rowH
            row += 1
        }
        Art.stroke(&context, joints, Art.color(0xA88E6A, 0.4), width: 1.2)
    }

    /// The street on the trailing side: three stuccoed houses with shops, neighbours at the
    /// windows throwing roses, and the small stone fountain.
    static func streetFronts(_ context: inout GraphicsContext, _ Hv: CGFloat) {
        let base: CGFloat = Hv + 12
        streetHouse(&context, x0: 466, width: 140, base: base, storeys: 3, wall: stuccoHex)
        streetHouse(&context, x0: 606, width: 150, base: base, storeys: 4, wall: redWallHex)
        streetHouse(&context, x0: 756, width: 150, base: base, storeys: 3, wall: creamHex)
        Art.fill(&context, Art.rect(466, base - 3, 440, 6), ArtStyle.coolShade.opacity(0.12))
        // The baker's shop is the last one, clear of the man and the lion in front.
        streetShop(&context, x0: 480, width: 112, base: base, baker: false)
        streetShop(&context, x0: 622, width: 118, base: base, baker: false)
        streetShop(&context, x0: 822, width: 76, base: base, baker: true)
        let woman = Kit.Person(skin: 0x8A5A3C, hair: 0x2A1E1A, hairStyle: .bun, garment: .dress, cloth: 0x7F93AD, trim: 0xE3D3AC, legs: 0x8A5A3C, showsEyeWhite: false)
        let man = Kit.Person(skin: 0xD9A47C, hair: 0x5A3A2A, beard: .short, garment: .tunic, cloth: 0xC99A5A, trim: 0x8A6A44, legs: 0xD9A47C, showsEyeWhite: false)
        let child = Kit.Person(age: .child, skin: 0xB67A50, hair: 0x2B1D19, hairStyle: .curly, garment: .tunic, cloth: 0xE3D3AC, trim: 0xA9743F, legs: 0xB67A50, showsEyeWhite: false)
        windowNeighbour(&context, window: streetWindowRect(x0: 466, width: 140, base: base, storey: 1, index: 1), person: woman)
        windowNeighbour(&context, window: streetWindowRect(x0: 606, width: 150, base: base, storey: 2, index: 0), person: child)
        windowNeighbour(&context, window: streetWindowRect(x0: 606, width: 150, base: base, storey: 1, index: 1), person: man)
        windowNeighbour(&context, window: streetWindowRect(x0: 756, width: 150, base: base, storey: 1, index: 0), person: woman)
        streetFountain(&context, x: 494, baseY: Hv + 44)
    }

    /// Where window `index` (0 or 1) of storey `storey` (1 is the first floor up) sits.
    static func streetWindowRect(x0: CGFloat, width: CGFloat, base: CGFloat, storey: Int, index: Int) -> CGRect {
        let w: CGFloat = 26
        let h: CGFloat = 40
        let part: CGFloat = index == 0 ? 0.3 : 0.7
        let cx: CGFloat = x0 + width * part
        let top: CGFloat = base - 84 * CGFloat(storey + 1) + 20
        return CGRect(x: cx - w / 2, y: top, width: w, height: h)
    }

    /// One house front of painted stucco, storeys 84 high, a low tiled roof, shuttered windows.
    static func streetHouse(_ context: inout GraphicsContext, x0: CGFloat, width: CGFloat, base: CGFloat, storeys: Int, wall: UInt32) {
        let count: Int = max(1, storeys)
        let top: CGFloat = base - 84 * CGFloat(count)
        Kit.wall(&context, rect: CGRect(x: x0, y: top, width: width, height: base - top), color: wall)
        Kit.roof(&context, cx: x0 + width / 2, eaveY: top + 2, width: width + 16, height: 22, color: tileHex, style: .tile)
        Art.fill(&context, Art.rect(x0, top + 2, width, 8), ArtStyle.coolShade.opacity(0.14))
        guard count > 1 else { return }
        var bands = Path()
        for i in 1..<count {
            let y: CGFloat = base - 84 * CGFloat(i)
            bands.move(to: CGPoint(x: x0, y: y))
            bands.addLine(to: CGPoint(x: x0 + width, y: y))
            for index in 0..<2 {
                let r = streetWindowRect(x0: x0, width: width, base: base, storey: i, index: index)
                streetWindow(&context, x: r.minX, y: r.minY, width: r.width, height: r.height, shutter: 0x7A8F6A)
            }
        }
        Art.stroke(&context, bands, Kit.propTone(wall, 0.84), width: 2.4)
    }
}
