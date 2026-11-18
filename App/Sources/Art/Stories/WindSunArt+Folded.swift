import SwiftUI
import OmramoCore

// The four folded-phone compositions of "The North Wind and the Sun": each its own picture for
// the band at the top of a phone (432 wide, 240…520 high), not a crop of the wide scene.

extension WindSunArt {
    /// Where the traveller's feet stand in a folded band: on the hill, above the wave edge.
    static func foldedFeet(_ band: Kit.Band) -> CGFloat {
        min(band.floor - 4, band.H + band.ground * 0.62)
    }

    /// The traveller's size in a folded band.
    static func foldedSize(_ band: Kit.Band) -> CGFloat {
        1.4 * band.unit
    }

    // MARK: scene-sky

    /// The North Wind's puffed face in the middle, the Sun's calm face just to its upper left,
    /// a strip of blue sea and islands below.
    static func skyFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band: Kit.Band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let light: Kit.Light = day()
        Kit.sky(&context, size, horizon: band.H, light: light)
        islandRow(&context, width: 432, horizon: band.H, scale: 0.7 * u, light: light)
        Kit.water(&context, width: 432, top: band.H, bottom: size.height, stops: calmSea(), light: light, ripples: 36)
        // Islands in the sea below, and a small boat.
        let nearIsle: CGFloat = band.H + band.ground * 0.42
        Art.fill(&context, Art.ellipse(96, nearIsle + 4 * u, 62 * u, 5 * u), Art.color(0x0B4F7A, 0.22))
        island(&context, x: 92, y: nearIsle, width: 110 * u, height: 28 * u, color: Art.color(0xA9BC8C))
        Kit.farTree(&context, x: 84, baseY: nearIsle - 20 * u, height: 11 * u, color: Art.color(0x6E8A6C))
        Kit.ripples(&context, 92, nearIsle + 5 * u, 100 * u, count: 2, color: Color.white, opacity: 0.4)
        island(&context, x: 236, y: band.H + band.ground * 0.2, width: 60 * u, height: 14 * u, color: light.mid)
        Kit.boat(&context, cx: 214, waterY: band.H + band.ground * 0.5, length: 30 * u, hull: 0x8A5A3A, sail: 0xF4EAD0, style: .nile)
        // The coast in the trailing corner, with its pale road.
        let coastBase: CGFloat = band.H + band.ground * 0.5
        Kit.mound(&context, x0: 290, x1: 520, baseY: coastBase, height: 16 * u, bottom: size.height, stops: hillStops(), crest: 0.6)
        Kit.ribbon(&context, nearX: 380, nearY: size.height, nearWidth: 40 * u, farX: 428, farY: coastBase - 12 * u, farWidth: 6, stops: roadStops())
        Kit.farTree(&context, x: 352, baseY: coastBase - 6 * u, height: 13 * u, color: Art.color(0x7C947A))
        Kit.farTree(&context, x: 408, baseY: coastBase - 13 * u, height: 16 * u, color: Art.color(0x4E6E58), conifer: true)
        // The two friends in the sky.
        let ws: CGFloat = 0.8 * u
        let windY: CGFloat = band.H - 14 - 106 * ws
        let sunX: CGFloat = 262 - 124 * u
        let sunY: CGFloat = windY - 56 * u
        Art.group(&context, x: sunX, y: sunY, scale: 0.78 * u) { g in
            sunHero(&g, mood: .smiling)
        }
        Art.group(&context, x: 262, y: windY, scale: ws) { g in
            windHero(&g, mood: .puffing)
        }
        ArtStyle.finish(&context, size)
    }

    // MARK: scene-wind

    /// The traveller's face in the middle, chin tucked into his cloak, one bent olive behind
    /// him, white waves below.
    static func windFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band: Kit.Band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let s: CGFloat = foldedSize(band)
        let feetY: CGFloat = foldedFeet(band)
        let feetX: CGFloat = 216 + 35 * s
        let light: Kit.Light = gale()
        Kit.sky(&context, size, horizon: band.H, light: light)
        islandRow(&context, width: 432, horizon: band.H, scale: 0.7 * u, light: light)
        Kit.water(&context, width: 432, top: band.H, bottom: size.height, stops: galeSea(), light: light, ripples: 20)
        Kit.swells(&context, width: 432, top: band.H + 4, bottom: size.height, rows: 5, crest: Color.white, seed: 12)
        whitecaps(&context, x0: 0, x1: 300, top: band.H + 6, bottom: size.height - 20, count: 26, seed: 43)
        Art.group(&context, x: 70, y: band.H + band.ground * 0.3, rotate: Kit.deg(7)) { g in
            Kit.boat(&g, cx: 0, waterY: 0, length: 30 * u, hull: 0x7A5236, sail: 0xEDE4CC, style: .nile)
        }
        gust(&context, x: 14, y: band.H - 30 * u, length: 150 * u, width: 4, color: Color.white)
        // The hill and the road under his feet.
        Kit.mound(&context, x0: 60, x1: 540, baseY: feetY + 30 * u, height: 34 * u, bottom: size.height, stops: hillStops(), crest: 0.75)
        Art.fill(&context, Art.ellipse(feetX + 10 * u, feetY + 5 * u, 120 * u, 9 * u), Art.color(roadHex))
        // One olive, bent hard over by the wind, behind him.
        let lean = CGAffineTransform(a: 1, b: 0, c: -0.38, d: 1, tx: 0, ty: 0)
        Art.group(&context, x: feetX + 84 * s, y: feetY - 8 * s) { t in
            t.concatenate(lean)
            Kit.olive(&t, x: 0, baseY: 0, height: 118 * s, seed: 4)
        }
        let air = CGRect(x: 120, y: feetY - 170 * s, width: 300, height: 150 * s)
        leafFlurry(&context, in: air, count: 16, seed: 54, size: 7 * s)
        thyme(&context, x: 110, baseY: feetY + 12 * u, width: 40 * u, seed: 33)
        gust(&context, x: 60, y: feetY - 150 * s, length: 130 * s, width: 5, color: Color.white)
        Kit.shadow(&context, feetX + 2, feetY + 2, width: 70 * s)
        Art.group(&context, x: feetX, y: feetY, scale: s) { g in
            traveller(&g, state: .gale, mouth: .flat)
        }
        gust(&context, x: 40, y: feetY - 56 * s, length: 90 * s, width: 4, color: Color.white)
        ArtStyle.finish(&context, size, wash: 0.06, vignette: 0.08)
    }

    // MARK: scene-sun

    /// The traveller's face in the middle, smiling, hat pushed back, one hand up; gold light on
    /// the dry-stone wall behind him.
    static func sunFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band: Kit.Band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let s: CGFloat = foldedSize(band)
        let feetY: CGFloat = foldedFeet(band)
        let feetX: CGFloat = 222
        let light: Kit.Light = gold()
        Kit.sky(&context, size, horizon: band.H, light: light)
        // The Sun's warmth pouring in from the upper left (the Sun himself is just out of frame).
        Art.glow(&context, 20, 10, 230 * u, Art.color(0xFFE38A), alpha: 0.55)
        islandRow(&context, width: 432, horizon: band.H, scale: 0.7 * u, light: light)
        Kit.water(&context, width: 432, top: band.H, bottom: size.height, stops: calmSea(), light: light, ripples: 30)
        Kit.glints(&context, x: 90, top: band.H, depth: band.ground, color: Art.color(0xFFF1C9), count: 18, seed: 8)
        Kit.mound(&context, x0: 40, x1: 540, baseY: feetY + 30 * u, height: 34 * u, bottom: size.height, stops: hillStops(), crest: 0.75)
        Art.fill(&context, Art.ellipse(feetX + 10 * u, feetY + 5 * u, 130 * u, 9 * u), Art.color(roadHex))
        // An upright olive and the warm wall behind him.
        Kit.olive(&context, x: feetX + 104 * s, baseY: feetY - 12 * s, height: 118 * s, seed: 4)
        let wallY: CGFloat = feetY - 6 * s
        let wallH: CGFloat = 26 * s
        Kit.fence(&context, x0: 150, x1: 440, baseY: wallY, height: wallH, color: stoneHex, stone: true)
        Art.stroke(&context, Art.line(154, wallY - wallH, 430, wallY - wallH), Art.color(0xFFE9A8, 0.7), width: 3)
        Art.group(&context, x: 372, y: wallY - wallH - 2, scale: 1.2 * u) { g in
            Kit.critterLizard(&g, body: 0x7FA85A)
        }
        thyme(&context, x: 108, baseY: feetY + 12 * u, width: 46 * u, seed: 33)
        Art.group(&context, x: 100, y: feetY - 26 * u, scale: u) { g in
            Kit.critterBee(&g)
        }
        Art.group(&context, x: 134, y: feetY - 12 * u, scale: 0.8 * u) { g in
            Kit.critterBee(&g)
        }
        Kit.shadow(&context, feetX + 4, feetY + 2, width: 70 * s, alpha: 0.3)
        Art.group(&context, x: feetX, y: feetY, scale: s) { g in
            traveller(&g, state: .phew, mouth: .grin)
        }
        ArtStyle.finish(&context, size, wash: 0.14, vignette: 0.08)
    }

    // MARK: scene-rest

    /// The traveller's contented face in the middle, resting against the olive trunk, the
    /// folded red-brown cloak beside him and a glimpse of the harbour below.
    static func restFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band: Kit.Band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let s: CGFloat = foldedSize(band)
        let feetY: CGFloat = foldedFeet(band)
        let feetX: CGFloat = 196 - 6 * s
        let light: Kit.Light = afternoon()
        Kit.sky(&context, size, horizon: band.H, light: light)
        islandRow(&context, width: 432, horizon: band.H, scale: 0.7 * u, light: light)
        Kit.water(&context, width: 432, top: band.H, bottom: size.height, stops: lateSea(), light: light, ripples: 30)
        harbour(&context, x: 0, y: band.H + band.ground * 0.36, scale: 0.5 * u, bottom: size.height)
        Kit.mound(&context, x0: 70, x1: 560, baseY: feetY + 20 * u, height: 30 * u, bottom: size.height, stops: hillStops(), crest: 0.7)
        // The old olive: low, wide, to the right; its shade on the ground.
        ArtStyle.contactShadow(&context, feetX + 50 * s, feetY + 6 * s, 150 * s, 14 * s, alpha: 0.22)
        let treeX: CGFloat = feetX + 92 * s
        let treeBase: CGFloat = feetY - 6 * s
        Kit.olive(&context, x: treeX, baseY: treeBase, height: 230 * s, seed: 7)
        let crown: [Kit.Blob] = [
            (treeX - 50 * s, treeBase - 170 * s, 46 * s), (treeX + 10 * s, treeBase - 190 * s, 50 * s),
            (treeX + 70 * s, treeBase - 166 * s, 48 * s), (treeX + 30 * s, treeBase - 140 * s, 40 * s),
        ]
        Kit.canopy(&context, crown, seed: 71, palette: Kit.oliveGreens(), density: 2)
        thyme(&context, x: 96, baseY: feetY + 10 * u, width: 40 * u, seed: 36)
        // His seat, himself, and the folded cloak beside him.
        Kit.rock(&context, cx: feetX + 10 * s, baseY: feetY + 2, width: 66 * s, height: 37 * s, color: 0xB8B09C, seed: 2)
        Kit.shadow(&context, feetX - 14 * s, feetY + 3, width: 64 * s)
        Art.group(&context, x: feetX, y: feetY, scale: s) { g in
            traveller(&g, state: .resting, mouth: .smile)
        }
        Art.group(&context, x: feetX - 72 * s, y: feetY - 2, scale: s) { g in
            foldedCloak(&g)
        }
        ArtStyle.finish(&context, size)
    }
}
