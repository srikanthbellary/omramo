import SwiftUI
import OmramoCore

// The four folded-phone compositions of "Androcles and the Lion": each is its own picture for
// the band at the top of one pane (432 wide, 240…520 high), not a crop of the wide scene.

extension AndroclesArt {
    /// The far plane of a folded band in the hills: sky, the thin far sea and wheat plain,
    /// and the ground.
    static func bandFar(_ context: inout GraphicsContext, _ band: Kit.Band, light: Kit.Light, ground: Kit.Stops, town: Bool) {
        let u: CGFloat = band.unit
        Kit.sky(&context, band.size, horizon: band.H, light: light)
        farPlain(&context, width: band.w, horizon: band.H, scale: u, town: town)
        Kit.ground(&context, width: band.w, top: band.H, bottom: band.h, stops: ground)
    }

    // MARK: scene-hills

    /// Androcles in the middle, climbing to the right among hot ochre rocks and thorn bushes,
    /// his head turned to look back; the far sea a thin blue line behind him.
    static func hillsFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let light = day()
        bandFar(&context, band, light: light, ground: ochreGround(), town: true)
        Kit.cloud(&context, 300, H * 0.32, scale: 0.5, color: Art.color(0xFFFFFF, 0.5))
        let fold = Kit.ridge(width: band.w, y: H - 2 * u, amp: 8 * u, seed: 7, bottom: H + 20 * u)
        Art.fill(&context, fold, light.mid)
        Kit.farTrees(&context, x0: 10, x1: 420, baseY: H + 4, height: 8 * u, count: 7, color: Art.color(0x9AA070), seed: 6)
        let feetY: CGFloat = H + 36 * u
        hillsFoldedSlope(&context, band, feetY: feetY)
        // The dust his heels kick up, behind him.
        var dust = Path()
        dust.addEllipse(in: CGRect(x: 216 - 52 * u, y: feetY - 9 * u, width: 22 * u, height: 11 * u))
        dust.addEllipse(in: CGRect(x: 216 - 66 * u, y: feetY - 4 * u, width: 15 * u, height: 8 * u))
        Art.fill(&context, dust, Art.color(0xF6E3BC, 0.55))
        let s: CGFloat = 0.78 * u
        Kit.shadow(&context, 218, feetY, width: 70 * s)
        Art.group(&context, x: 216, y: feetY, scale: s, scaleX: -1) { g in
            androcles(&g, pose: .walk, look: CGPoint(x: 0.9, y: 0.1), mouth: .oh, mirrored: true)
        }
        // Near framing at the bottom corners.
        Kit.rock(&context, cx: 36, baseY: band.h - 6, width: 110 * u, height: 48 * u, color: 0xCF9850, seed: 9)
        thornBush(&context, x: 404, baseY: band.h - 4, width: 92 * u, seed: 6)
        ArtStyle.finish(&context, size)
    }

    /// The flank of the hill rising to the right, its rocks, scrub and the olive tree.
    static func hillsFoldedSlope(_ context: inout GraphicsContext, _ band: Kit.Band, feetY: CGFloat) {
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        var slope = Path()
        slope.move(to: CGPoint(x: -10, y: feetY + 30 * u))
        slope.addQuadCurve(to: CGPoint(x: 442, y: H - 26 * u), control: CGPoint(x: 220, y: feetY + 10 * u))
        slope.addLine(to: CGPoint(x: 442, y: band.h + 4))
        slope.addLine(to: CGPoint(x: -10, y: band.h + 4))
        slope.closeSubpath()
        Kit.solid(&context, slope, stops: ochreGround(), light: 0.24, shade: 0.12, rim: 2.4)
        var folds = Path()
        folds.move(to: CGPoint(x: 0, y: feetY + 52 * u))
        folds.addQuadCurve(to: CGPoint(x: 432, y: H + 10 * u), control: CGPoint(x: 230, y: feetY + 36 * u))
        Art.stroke(&context, folds, Art.color(0xA9743F, 0.3), width: ArtStyle.detailLine)
        Kit.olive(&context, x: 404, baseY: H - 10 * u, height: 120 * u, seed: 3)
        thornBush(&context, x: 330, baseY: H + 12 * u, width: 54 * u, seed: 2)
        Kit.palm(&context, x: 40, baseY: feetY + 22 * u, height: 46 * u, lean: 4, fronds: 0x7C8F5A, trunk: 0x8A6A48, seed: 4)
        Kit.rock(&context, cx: 118, baseY: feetY + 30 * u, width: 76 * u, height: 38 * u, color: rockHex, seed: 3)
        Kit.rock(&context, cx: 300, baseY: feetY + 18 * u, width: 64 * u, height: 30 * u, color: 0xD3A566, seed: 5)
        let dry = CGRect(x: 0, y: feetY - 6 * u, width: 432, height: max(10, band.h - feetY))
        Kit.grass(&context, in: dry, count: 26, seed: 8, color: Art.color(0xB8935A, 0.7), height: 9 * u)
        Kit.pebbles(&context, in: dry, count: 14, seed: 5, color: 0xC9A070)
    }

    // MARK: scene-cave

    /// Close on the two friends at the cave mouth: the great paw held out to Androcles, who
    /// kneels to it, the Lion's dark mane and patient face beside him, sunlit rock above.
    static func caveFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let light = goldDay()
        Kit.sky(&context, band.size, horizon: H, light: light)
        Kit.sun(&context, 48, H - 66 * u, 12 * u, light: light)
        Kit.ranges(&context, width: band.w, horizon: H, scale: u * 0.8, light: light, seed: 5)
        Kit.ground(&context, width: band.w, top: H, bottom: band.h, stops: caveGround())
        let pale: Kit.Stops = [(Art.color(0xF6E2B4), 0), (Art.color(0xE6C088), 1)]
        Kit.mound(&context, x0: -30, x1: 180, baseY: H + 6, height: 20 * u, bottom: H + 8, stops: pale, crest: 0.4)
        Kit.palm(&context, x: 54, baseY: H + 26 * u, height: 50 * u, lean: -4, fronds: 0x7C8F5A, trunk: 0x8A6A48, seed: 7)
        let feetY: CGFloat = H + 30 * u
        let k: CGFloat = 0.95 * u
        let gx: CGFloat = 216 - 660 * k
        let gy: CGFloat = feetY - 76 * k
        Art.group(&context, x: gx, y: gy, scale: k) { g in
            caveRock(&g, 0)
            caveFriends(&g, 0, paw: 1)
        }
        Kit.cornerLeaves(&context, size: band.size, corner: 2, color: Art.color(0x6B5A3A), scale: 0.6 * u, seed: 7)
        ArtStyle.finish(&context, size)
    }

    // MARK: scene-arena

    /// Androcles alone on the pale sand, facing the lion a few steps away, the high wall and
    /// its row of tiny spectators across the top of the band.
    static func arenaFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let light = morning()
        Kit.sky(&context, band.size, horizon: H, light: light)
        Kit.cloud(&context, 300, H * 0.34, scale: 0.5, color: Art.color(0xFFFFFF, 0.5))
        arenaBandWall(&context, band)
        Kit.ground(&context, width: band.w, top: H, bottom: band.h, stops: sandGround())
        var rake = Path()
        for i in 0..<5 {
            let t: CGFloat = (CGFloat(i) + 0.6) / 5
            let y: CGFloat = H + band.ground * t * t
            rake.move(to: CGPoint(x: -10, y: y + 4 * t))
            rake.addQuadCurve(to: CGPoint(x: 442, y: y - 3 * t), control: CGPoint(x: 210, y: y + 9 * t))
        }
        Art.stroke(&context, rake, Art.color(0xCDAE78, 0.35), width: 1.2)
        let feetY: CGFloat = H + 40 * u
        arenaBandPrints(&context, from: CGPoint(x: -6, y: band.h - 20), to: CGPoint(x: 120, y: feetY + 4))
        let s: CGFloat = 0.62 * u
        Kit.shadow(&context, 142, feetY, width: 60 * s, alpha: 0.3)
        Art.group(&context, x: 140, y: feetY, scale: s, scaleX: -1) { g in
            androcles(&g, pose: .stand, look: CGPoint(x: -0.8, y: 0), mouth: .oh, bag: false, mirrored: true)
        }
        let ls: CGFloat = 0.66 * u
        Kit.shadow(&context, 300, feetY - 2 * u, width: 150 * ls, alpha: 0.3)
        Art.group(&context, x: 298, y: feetY - 2 * u, scale: ls) { g in
            lion(&g, pose: .stand, mood: .calm, look: CGPoint(x: -0.8, y: -0.2), thin: true)
        }
        // The shade of the doorway he came through.
        var wedge = Path()
        wedge.move(to: CGPoint(x: 0, y: band.h - band.ground * 0.5))
        wedge.addLine(to: CGPoint(x: 0, y: band.h))
        wedge.addLine(to: CGPoint(x: 120, y: band.h))
        wedge.closeSubpath()
        Art.fill(&context, wedge, ArtStyle.coolShade.opacity(0.1))
        ArtStyle.finish(&context, size, wash: 0.1, vignette: 0.07)
    }

    /// The plain high wall at the back of the sand, the stands above it with three tiers of
    /// tiny spectators, the awnings on their poles and the barred gate.
    static func arenaBandWall(_ context: inout GraphicsContext, _ band: Kit.Band) {
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let w: CGFloat = band.w
        let wallTop: CGFloat = H - 44 * u
        let standTop: CGFloat = H - 78 * u
        let seats: Kit.Stops = [(Art.color(0xE3D0AC), 0), (Art.color(0xD3BB94), 1)]
        Art.fillLinear(&context, Art.rect(0, standTop, w, wallTop - standTop), seats, from: CGPoint(x: 0, y: standTop), to: CGPoint(x: 0, y: wallTop))
        let crowd = CGRect(x: 0, y: standTop + 4 * u, width: w, height: wallTop - standTop - 6 * u)
        spectators(&context, in: crowd, rows: 3, seed: 71)
        var poles = Path()
        for i in 0..<7 {
            let x0: CGFloat = CGFloat(i) * 72 - 10
            let x1: CGFloat = x0 + 72
            let midX: CGFloat = (x0 + x1) / 2
            let top: CGFloat = standTop - 10 * u
            let low: CGFloat = standTop + 1 * u
            var cloth = Path()
            cloth.move(to: CGPoint(x: x0, y: top))
            cloth.addQuadCurve(to: CGPoint(x: x1, y: top), control: CGPoint(x: midX, y: top + 6 * u))
            cloth.addLine(to: CGPoint(x: x1, y: low))
            cloth.addQuadCurve(to: CGPoint(x: x0, y: low), control: CGPoint(x: midX, y: low + 5 * u))
            cloth.closeSubpath()
            let color: Color = i % 2 == 1 ? Art.color(0xCB6B4C, 0.9) : Art.color(0xF8EED6)
            Art.fill(&context, cloth, color)
            poles.move(to: CGPoint(x: x0, y: wallTop))
            poles.addLine(to: CGPoint(x: x0, y: top))
        }
        Art.stroke(&context, poles, Art.color(0x8A6A48, 0.7), width: 1.4)
        let wall = Art.rect(0, wallTop, w, H - wallTop + 1)
        let wallStops: Kit.Stops = [(Art.color(0xF4E8CC), 0), (Art.color(0xE4D0A8), 1)]
        Art.fillLinear(&context, wall, wallStops, from: CGPoint(x: 0, y: wallTop), to: CGPoint(x: 0, y: H))
        Art.clipped(&context, to: wall) { g in
            ArtStyle.tooth(&g, in: CGRect(x: 0, y: wallTop, width: w, height: H - wallTop), seed: 72, alpha: 0.06)
            Art.fill(&g, Art.rect(0, H - 6, w, 6), ArtStyle.coolShade.opacity(0.1))
        }
        Art.fill(&context, Art.rect(0, wallTop - 1.5 * u, w, 3 * u), Art.color(0xFFF8E6))
        Art.fill(&context, Art.rect(0, wallTop + 1.5 * u, w, 1.2), Art.color(0xB89A70, 0.5))
        arenaGate(&context, x: 380, horizon: H, scale: u)
    }

    /// Bare footprints across the raked sand from `from` to `to`.
    static func arenaBandPrints(_ context: inout GraphicsContext, from: CGPoint, to: CGPoint) {
        var prints = Path()
        for i in 0..<7 {
            let t: CGFloat = CGFloat(i) / 6
            let x: CGFloat = Kit.mix(from.x, to.x, t)
            let y: CGFloat = Kit.mix(from.y, to.y, t)
            let side: CGFloat = i % 2 == 0 ? -3 : 3
            let r: CGFloat = 4.5 - 2 * t
            prints.addEllipse(in: CGRect(x: x - r * 1.5, y: y + side - r * 0.5, width: r * 3, height: r))
        }
        Art.fill(&context, prints, Art.color(0xB8956A, 0.4))
    }

    // MARK: scene-street

    /// Androcles in his clean tunic and the Lion walking side by side, the thin leash slack
    /// between them, petals falling, a shop awning and a pale wall behind.
    static func streetFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let light = morning()
        Kit.sky(&context, band.size, horizon: H, light: light)
        streetBandWall(&context, band)
        Kit.ground(&context, width: band.w, top: H, bottom: band.h, stops: pavingGround())
        streetPaving(&context, width: band.w, top: H, bottom: band.h, scale: u, seed: 3)
        let floorPetals = CGRect(x: 10, y: H + 8 * u, width: 412, height: max(10, band.ground - 34))
        petals(&context, in: floorPetals, count: 26, seed: 81)
        let feetY: CGFloat = H + 36 * u
        let s: CGFloat = 0.7 * u
        Art.group(&context, x: 170, y: feetY, scale: s) { g in
            streetPair(&g)
        }
        let falling = CGRect(x: 40, y: H - 150 * u, width: 360, height: 140 * u)
        petals(&context, in: falling, count: 30, seed: 82)
        Kit.cornerLeaves(&context, size: band.size, corner: 2, color: Art.color(0x5E6B3E), scale: 0.5 * u, seed: 5)
        ArtStyle.finish(&context, size)
    }

    /// The pale stucco wall behind the street band: a shuttered window with a pot of roses
    /// on the left, the baker's open shop front with its striped awning on the right.
    static func streetBandWall(_ context: inout GraphicsContext, _ band: Kit.Band) {
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let top: CGFloat = H - 150 * u
        Kit.wall(&context, rect: CGRect(x: -4, y: top, width: 440, height: H - top + 2), color: creamHex)
        Kit.roof(&context, cx: 216, eaveY: top + 2, width: 470, height: 16 * u, color: tileHex, style: .tile)
        streetWindow(&context, x: 40, y: top + 30 * u, width: 50 * u, height: 62 * u, shutter: 0x7A8F6A)
        Kit.pot(&context, cx: 65, baseY: top + 92 * u, width: 22 * u, height: 18 * u, color: 0xB5683A)
        Kit.flowers(&context, in: CGRect(x: 52, y: top + 66 * u, width: 26 * u, height: 8 * u), count: 4, seed: 4, petal: 0xDB5A6E)
        let shop = CGRect(x: 250, y: H - 92 * u, width: 190, height: 92 * u + 1)
        let dark: Kit.Stops = [(Art.color(0x6B4A3C), 0), (Art.color(0x8A6450), 1)]
        Art.fillLinear(&context, Art.rect(shop.minX, shop.minY, shop.width, shop.height), dark, from: CGPoint(x: 0, y: shop.minY), to: CGPoint(x: 0, y: shop.maxY))
        let counterTop: CGFloat = H - 34 * u
        let counter = Art.rect(shop.minX - 4, counterTop, shop.width + 8, H - counterTop + 1)
        Kit.solid(&context, counter, Art.color(0xE6D6B6), light: 0.24, shade: 0.18)
        for i in 0..<4 {
            let lx: CGFloat = shop.minX + 24 + CGFloat(i) * 40
            loaf(&context, x: lx, y: counterTop - 4 * u, r: 13 * u)
        }
        streetAwning(&context, x0: shop.minX - 10, x1: 442, y: shop.minY, depth: 22 * u)
    }
}
