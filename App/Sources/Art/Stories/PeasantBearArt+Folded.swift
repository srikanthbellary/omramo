import SwiftUI
import OmramoCore

// The four scenes of "The Peasant and the Bear" as the picture band of a folded phone: 432
// units wide, 240…520 high. Each is its own composition: the Bear's face in the middle of the
// band, the far forest line behind him, something of the season round him. Everything stands
// on `foldedFeet`, which stays above the wave edge, and is scaled by the band's `unit`.

extension PeasantBearArt {
    /// The ground line the subject stands on: in the lower ground, above the wave edge.
    static func foldedFeet(_ band: Kit.Band) -> CGFloat {
        min(band.floor - 4, band.H + band.ground * 0.62)
    }

    /// The far plane of a folded band: sky, a pale cloud, the far forest line, the veil.
    static func foldedFar(_ context: inout GraphicsContext, _ size: CGSize, band: Kit.Band, light: Kit.Light, seed: UInt32) {
        let w: CGFloat = size.width
        let H: CGFloat = band.H
        let u: CGFloat = band.unit
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.cloud(&context, 236, max(38, H * 0.34), scale: 0.6 * u, color: Art.color(0xFFFFFF, 0.6))
        let line: Path = Kit.ridge(width: w, y: H - 8 * u, amp: 4 * u, seed: seed, bottom: H + 4)
        Art.fill(&context, line, light.far.opacity(0.8))
        Kit.farTrees(&context, x0: -6, x1: w + 6, baseY: H + 2, height: 24 * u, count: 26, color: light.far, conifer: true, seed: seed)
        Kit.farTrees(&context, x0: -6, x1: w + 6, baseY: H + 2, height: 16 * u, count: 18, color: light.mid.opacity(0.8), conifer: false, seed: seed &+ 7)
        ArtStyle.atmosphere(&context, width: w, top: H - 48 * u, bottom: H + 4, color: light.haze, alpha: 0.42)
    }

    // MARK: scene-field

    /// scene-field (folded): the Bear up on his hind legs between two white birch trunks, his
    /// mouth an "O"; the Peasant, small, cap in hand, below him on the leading side, and the
    /// horse's head looking in from the trailing edge.
    static func fieldFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let feet: CGFloat = foldedFeet(band)
        let light = spring()
        foldedFar(&context, size, band: band, light: light, seed: 3)

        let meadow: Kit.Stops = [(Art.color(0xA6D272), 0), (Art.color(0x6FAE52), 1)]
        Kit.ground(&context, width: w, top: H, bottom: h, stops: meadow)
        let edge: CGFloat = H + 12 * u
        let earth: Kit.Stops = [(Art.color(0x7A5230), 0), (Art.color(0x5B3A1E), 0.5), (Art.color(0x43291A), 1)]
        Kit.ground(&context, width: w, top: edge, bottom: h, stops: earth, seed: 21, tooth: Art.color(0xE8C9A0))
        Kit.furrows(&context, x0: -90, x1: w + 90, top: edge, bottom: h, color: 0x5B3A1E, count: 11)
        let verge = CGRect(x: 0, y: H + 4, width: w, height: 8 * u)
        Kit.grass(&context, in: verge, count: 40, seed: 5, color: Art.color(0x4F8F45), height: 6)

        // The forest edge: spruces at the sides, two birches framing the Bear.
        let fresh: Kit.Greens = Kit.springGreens()
        let pines: Kit.Greens = Kit.pineGreens()
        let tree: CGFloat = max(120, feet - 16)
        Kit.conifer(&context, x: 34, baseY: H + 8 * u, height: tree * 0.5, palette: pines, seed: 3)
        Kit.conifer(&context, x: 404, baseY: H + 10 * u, height: tree * 0.56, palette: pines, seed: 5)
        Kit.conifer(&context, x: 356, baseY: H + 6 * u, height: tree * 0.42, palette: pines, seed: 7)
        Kit.birch(&context, x: 124, baseY: feet - 8 * u, height: tree * 0.94, palette: fresh, seed: 2)
        Kit.birch(&context, x: 312, baseY: feet - 4 * u, height: tree, palette: fresh, seed: 5)

        // The horse looks in from the trailing edge.
        Kit.shadow(&context, 410, feet + 2, width: 100 * u)
        Art.group(&context, x: 412, y: feet + 2, scale: 0.62 * u) { a in
            horse(&a, mood: .surprised, look: CGPoint(x: -0.6, y: -0.2))
        }

        // The Bear.
        Kit.shadow(&context, 216, feet, width: 110 * u)
        Art.group(&context, x: 216, y: feet, scale: u) { b in
            bear(&b, pose: .rear, mood: .surprised, look: CGPoint(x: -0.7, y: 0.5), brow: 1)
        }
        Kit.bush(&context, x: 270, baseY: feet + 12 * u, width: 66 * u, palette: fresh, seed: 14)

        // The Peasant: he does not run. He takes off his cap.
        Kit.shadow(&context, 84, feet + 3, width: 36 * u)
        Art.group(&context, x: 84, y: feet + 3, scale: 0.6 * u, scaleX: -1) { p in
            peasant(&p, pose: .carry, look: CGPoint(x: -0.6, y: -0.7), mouth: .smile, capInHand: true, mirrored: true)
        }
        ArtStyle.finish(&context, size)
    }

    // MARK: scene-turnips

    /// scene-turnips (folded): the Bear sits in the middle, a turnip leaf hanging from his
    /// mouth, eyeing the cart of round roots on the leading side; his heap of green tops is
    /// beside him, and yellow birch leaves come down.
    static func turnipsFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let feet: CGFloat = foldedFeet(band)
        let light = autumn()
        foldedFar(&context, size, band: band, light: light, seed: 11)

        let verge: Kit.Stops = [(Art.color(0xCFC46A), 0), (Art.color(0xA99A4A), 1)]
        Kit.ground(&context, width: w, top: H, bottom: h, stops: verge)
        let edge: CGFloat = H + 12 * u
        let soil: Kit.Stops = [(Art.color(0x9A7442), 0), (Art.color(0x7A5230), 0.55), (Art.color(0x5B3A1E), 1)]
        Kit.ground(&context, width: w, top: edge, bottom: h, stops: soil, seed: 23, tooth: Art.color(0xF2D9A8))
        Kit.furrows(&context, x0: -90, x1: w + 90, top: edge, bottom: h, color: 0x7A5230, count: 9)

        // Yellow birches behind, a dark spruce between them.
        let gold: Kit.Greens = Kit.autumnLeaves()
        let tree: CGFloat = max(120, feet - 16)
        Kit.conifer(&context, x: 392, baseY: H + 8 * u, height: tree * 0.5, palette: Kit.pineGreens(), seed: 5)
        Kit.birch(&context, x: 132, baseY: H + 16 * u, height: tree * 0.86, palette: gold, seed: 3)
        Kit.birch(&context, x: 330, baseY: H + 20 * u, height: tree * 0.96, palette: gold, seed: 6)
        let fall = CGRect(x: 60, y: 40, width: 330, height: max(10, H - 50))
        Kit.flecks(&context, in: fall, count: 12, seed: 9, color: Art.color(0xF2B93A), radius: 1.6...3.2)

        // The cart on the leading side, heaped with roots.
        let L: CGFloat = 124 * u
        let cartY: CGFloat = feet - 2
        Kit.cart(&context, cx: 44, baseY: cartY, length: L, color: cartHex, load: turnipHex)
        let topY: CGFloat = cartY - L * 0.596
        let load: [(CGFloat, CGFloat, CGFloat)] = [(-0.24, 0, 0.08), (0.02, -0.03, 0.085), (0.28, 0, 0.08), (-0.1, -0.13, 0.09), (0.16, -0.14, 0.09), (0.03, -0.25, 0.095)]
        for item in load {
            turnip(&context, x: 44 + item.0 * L, y: topY - L * 0.11 + item.1 * L, r: item.2 * L, tops: false)
        }

        // The Bear and his heap of tops.
        Kit.shadow(&context, 244, feet, width: 140 * u)
        Art.group(&context, x: 244, y: feet, scale: 1.08 * u) { b in
            bear(&b, pose: .sit, mood: .calm, look: CGPoint(x: -0.8, y: 0.1), brow: 1, sprig: .leaf)
        }
        leafHeap(&context, cx: 356, baseY: feet + 3, width: 100 * u, seed: 4)
        turnip(&context, x: 150, y: feet + 4 * u, r: 9 * u, tops: true, tilt: -0.7)
        ArtStyle.finish(&context, size)
    }

    // MARK: scene-rye

    /// scene-rye (folded): golden rye across the lower half, and the Bear's hopeful face
    /// rising out of it in the middle, a stalk in his mouth; pale blue sky above.
    static func ryeFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let feet: CGFloat = foldedFeet(band)
        let light = summer()
        foldedFar(&context, size, band: band, light: light, seed: 19)
        Art.glow(&context, 30, 20, 200, light.glow, alpha: 0.4)
        Kit.birds(&context, 92, max(50, H * 0.42), scale: 0.9 * u, color: Art.color(0x55707E))

        let gold: Kit.Stops = [(Art.color(0xF4DA86), 0), (Art.color(0xE9C050), 0.5), (Art.color(0xD9A632), 1)]
        Kit.ground(&context, width: w, top: H, bottom: h, stops: gold, seed: 41, tooth: Art.color(0xFFF3C4))
        Kit.grainField(&context, x0: -6, x1: w + 6, baseY: H + 18 * u, height: 22 * u, color: 0xF2D272, seed: 1)

        // The Bear stands in the rye: a first stand behind him, the tall one in front.
        let s: CGFloat = 1.15 * u
        let back: CGFloat = feet - 150 * s
        Kit.grainField(&context, x0: -6, x1: w + 6, baseY: h + 4, height: h + 4 - back, color: 0xECC458, seed: 2)
        Art.group(&context, x: 216, y: feet, scale: s) { b in
            bear(&b, pose: .rear, mood: .happy, look: CGPoint(x: -0.3, y: 0.7), brow: 0.6, sprig: .rye)
        }
        let front: CGFloat = feet - 104 * s
        Kit.grainField(&context, x0: -6, x1: w + 6, baseY: h + 4, height: h + 4 - front, color: 0xE3B23C, seed: 3)
        let near: CGFloat = feet - 44 * s
        Kit.grainField(&context, x0: -6, x1: w + 6, baseY: h + 4, height: h + 4 - near, color: 0xD9A632, seed: 5)
        let blue = CGRect(x: 20, y: near + 14 * u, width: w - 40, height: max(6, band.floor - near - 20 * u))
        Kit.flowers(&context, in: blue, count: 9, seed: 4, petal: 0x4F7FD9, heart: 0x2E3F8A)
        ArtStyle.finish(&context, size)
    }

    // MARK: scene-harvest

    /// scene-harvest (folded): the Bear in his heap of thin dry roots, holding one up and
    /// pulling a face; behind him the cart stacked with golden sheaves; a tiny log house and
    /// its thread of smoke on the horizon.
    static func harvestFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let feet: CGFloat = foldedFeet(band)
        let light = harvest()
        foldedFar(&context, size, band: band, light: light, seed: 27)
        Art.group(&context, x: 74, y: H + 2, scale: 0.24 * u) { g in
            village(&g, light: light)
        }
        ArtStyle.atmosphere(&context, width: w, top: H - 50 * u, bottom: H + 4, color: light.haze, alpha: 0.18)

        let stubble: Kit.Stops = [(Art.color(0xEBD08A), 0), (Art.color(0xD2A648), 0.55), (Art.color(0xA97E2E), 1)]
        Kit.ground(&context, width: w, top: H, bottom: h, stops: stubble, seed: 31)
        Kit.furrows(&context, x0: -90, x1: w + 90, top: H + 5, bottom: h, color: 0xC99A3A, count: 10)
        let field = CGRect(x: 0, y: H + 8, width: w, height: max(1, band.ground - 8))
        Kit.grass(&context, in: field, count: 70, seed: 3, color: Art.color(0xF6E2A6), height: 5)
        Kit.grass(&context, in: field, count: 50, seed: 4, color: Art.color(0x9A7428, 0.8), height: 6)
        stook(&context, x: 60, baseY: H + band.ground * 0.36, height: 34 * u)
        stook(&context, x: 150, baseY: H + band.ground * 0.14, height: 20 * u)

        // The cart of sheaves, behind the Bear on the trailing side.
        let L: CGFloat = 122 * u
        let cartY: CGFloat = feet - 6 * u
        Kit.cart(&context, cx: 366, baseY: cartY, length: L, color: cartHex, load: ryeHex)
        let topY: CGFloat = cartY - L * 0.596
        Kit.sheaf(&context, cx: 366 - L * 0.3, baseY: topY + 3, height: L * 0.5, color: ryeHex)
        Kit.sheaf(&context, cx: 366 + L * 0.3, baseY: topY + 3, height: L * 0.48, color: ryeHex)
        Kit.sheaf(&context, cx: 366, baseY: topY + 2, height: L * 0.58, color: 0xEBBE4A)

        // The Bear and his roots.
        let s: CGFloat = 1.06 * u
        Kit.shadow(&context, 196, feet, width: 120 * u)
        Art.group(&context, x: 196, y: feet, scale: s, scaleX: -1) { b in
            bear(&b, pose: .rear, mood: .sad, look: CGPoint(x: -0.8, y: 0.4), brow: 1, sprig: .root, mirrored: true)
        }
        rootHeap(&context, cx: 196, baseY: feet + 8 * u, width: 170 * u)
        ArtStyle.finish(&context, size)
    }
}
