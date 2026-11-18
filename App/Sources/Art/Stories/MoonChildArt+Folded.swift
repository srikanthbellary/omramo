import SwiftUI
import OmramoCore

// The four scenes of "The Bamboo-Cutter and the Moon-Child" as the picture band of a folded
// phone: 432 units wide and about 240…520 high. Each is its own composition for the band, not
// a crop: the subject glows in the middle (x 86…346), below the two top controls and above
// the wave edge. Dark story: every band is night, with one glowing source.

extension MoonChildArt {
    // MARK: scene-grove

    /// scene-grove (folded): the cut stem glowing in the middle of the band, the tiny girl in
    /// the hollow, and the old man kneeling in beside it, his face lit gold; dark stems round.
    static func groveFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let w: CGFloat = size.width
        let light = night()
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.stars(&context, width: w, maxY: H - 110 * u, count: 26, seed: 61)
        let tops = Kit.ridge(width: w, y: H - 40 * u, amp: 18 * u, seed: 62, bottom: H + 8)
        Art.fill(&context, tops, Art.color(0x0E2230))
        caneRank(&context, x0: -10, x1: 442, baseY: H + 4, top: -20, count: 15, half: 3 * u, tone: caneFarHex, seed: 63)
        ArtStyle.atmosphere(&context, width: w, top: H - 200 * u, bottom: H + 8, color: light.haze, alpha: 0.22)
        let earth: Kit.Stops = Kit.stops(0x12302A, 0x0A1A1C)
        Kit.ground(&context, width: w, top: H, bottom: size.height, stops: earth, tooth: Art.color(0x9FC2A6))
        floorLitter(&context, size, top: H, color: Art.color(0x2A5A44), seed: 64)
        caneRank(&context, x0: -10, x1: 442, baseY: H + 10, top: -20, count: 7, half: 5 * u, tone: caneMidHex, seed: 67)
        let sprayX: [CGFloat] = [60, 150, 280, 380]
        for (i, x) in sprayX.enumerated() {
            leafSpray(&context, x: x, y: 8, reach: 70 * u, count: 14, color: Art.color(0x0C2024), seed: 200 &+ UInt32(i), droop: 0.7)
        }
        groveFoldedSubject(&context, band)
        groveFoldedFrame(&context, band)
        ArtStyle.finish(&context, size, wash: 0.04, vignette: 0.14)
    }

    /// The stem cut open, the tiny girl in it, and the kneeling old man, in band units.
    static func groveFoldedSubject(_ context: inout GraphicsContext, _ band: Kit.Band) {
        let u: CGFloat = band.unit
        let base: CGFloat = band.H + 22 * u
        let reach: CGFloat = 200 * u
        cane(&context, x: 112, baseY: base + 6 * u, top: -20, half: 8 * u, tone: caneNearHex, lean: -6, glowSide: 1, glow: 0.4, reach: reach, seed: 65)
        cane(&context, x: 334, baseY: base + 10 * u, top: -20, half: 9 * u, tone: caneNearHex, lean: 8, glowSide: -1, glow: 0.3, reach: reach, seed: 66)
        // The pool of gold light on the ground.
        Art.group(&context, x: 204, y: base + 2, scale: 0.3, scaleX: 3.2) { p in
            Art.glow(&p, 0, 0, 150 * u, ramp.glowColor, alpha: 0.36)
        }
        let stemScale: CGFloat = 1.25 * u
        Art.group(&context, x: 184, y: base, scale: stemScale) { s in
            cutStem(&s)
        }
        // The old man kneels in from the right, facing the stem.
        let manScale: CGFloat = 1.0 * u
        Kit.shadow(&context, 262, base, width: 70 * u, alpha: 0.34)
        Art.group(&context, x: 262, y: base, scale: manScale) { c in
            cutter(&c, pose: .kneel, look: CGPoint(x: -0.7, y: 0.3), mouth: .oh)
        }
        // The gold light finds his face.
        let faceY: CGFloat = base - 92 * u
        Art.glow(&context, 246, faceY, 46 * u, ramp.glowColor, alpha: 0.22)
    }

    /// The near plane of the folded grove: dark canes and hanging leaves at both edges.
    static func groveFoldedFrame(_ context: inout GraphicsContext, _ band: Kit.Band) {
        let u: CGFloat = band.unit
        let low: CGFloat = band.h + 10
        cane(&context, x: 10, baseY: low, top: -20, half: 13 * u, tone: 0x0A1A1C, lean: 6, seed: 68)
        cane(&context, x: 424, baseY: low, top: -20, half: 15 * u, tone: 0x0A1A1C, lean: -8, seed: 69)
        leafSpray(&context, x: 418, y: 12, reach: 110 * u, count: 20, color: Art.color(0x08161A), seed: 210, droop: 0.8)
        leafSpray(&context, x: 12, y: 8, reach: 90 * u, count: 16, color: Art.color(0x08161A), seed: 211, droop: 0.8)
        leafSpray(&context, x: 20, y: band.h - 12, reach: 80 * u, count: 14, color: Art.color(0x08161A), seed: 212, droop: 0.05)
    }

    // MARK: scene-house

    /// scene-house (folded): Kaguya-hime sitting in the open doorway in the middle of the band,
    /// her hair down her back; the light that fills the house is hers.
    static func houseFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let w: CGFloat = size.width
        let light = dusk()
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.stars(&context, width: w, maxY: H - 140 * u, count: 20, seed: 71)
        let farTops = Kit.ridge(width: w, y: H - 46 * u, amp: 22 * u, seed: 72, bottom: H + 8)
        Art.fill(&context, farTops, light.far)
        caneRank(&context, x0: -10, x1: 442, baseY: H + 4, top: -20, count: 12, half: 3 * u, tone: 0x0E1A2A, seed: 73)
        ArtStyle.atmosphere(&context, width: w, top: H - 200 * u, bottom: H + 8, color: light.haze, alpha: 0.2)
        let nearTops = Kit.ridge(width: w, y: H - 18 * u, amp: 12 * u, seed: 74, bottom: H + 8)
        Art.fill(&context, nearTops, light.mid)
        let earth: Kit.Stops = Kit.stops(0x1A2440, 0x0E1730)
        Kit.ground(&context, width: w, top: H, bottom: size.height, stops: earth, tooth: Art.color(0xA8B8E0))
        floorLitter(&context, size, top: H + 10, color: Art.color(0x2A3A5E), seed: 75)
        houseFoldedSubject(&context, band)
        // The near plane: the woven fence low on both sides, dark canes at the edges.
        let fenceY: CGFloat = band.floor - 2
        let fenceH: CGFloat = 26 * u
        wovenFence(&context, x0: -10, x1: 118, y: fenceY, height: fenceH, tone: 0x1A2236)
        wovenFence(&context, x0: 314, x1: 442, y: fenceY, height: fenceH, tone: 0x1A2236)
        cane(&context, x: 8, baseY: band.h + 10, top: -20, half: 12 * u, tone: 0x0A1220, lean: 6, seed: 76)
        cane(&context, x: 426, baseY: band.h + 10, top: -20, half: 14 * u, tone: 0x0A1220, lean: -6, seed: 77)
        leafSpray(&context, x: 420, y: 10, reach: 100 * u, count: 18, color: Art.color(0x0A1220), seed: 220, droop: 0.8)
        leafSpray(&context, x: 10, y: 8, reach: 84 * u, count: 14, color: Art.color(0x0A1220), seed: 221, droop: 0.8)
        ArtStyle.finish(&context, size, wash: 0.04, vignette: 0.14)
    }

    /// The house, its doorway filled with her light, and Kaguya-hime seated on the porch.
    static func houseFoldedSubject(_ context: inout GraphicsContext, _ band: Kit.Band) {
        let u: CGFloat = band.unit
        let base: CGFloat = band.H + 26 * u
        let hs: CGFloat = 1.4 * u
        let ks: CGFloat = 0.7 * u
        Art.group(&context, x: 208, y: base, scale: hs) { h in
            thatchHouse(&h, glow: 1)
        }
        let seatY: CGFloat = base - 17 * hs
        let seatX: CGFloat = 208 + 8 * hs
        Art.group(&context, x: seatX, y: seatY, scale: ks) { k in
            Art.glow(&k, 0, -70, 130, Art.color(0xFFFBE4), alpha: 0.7)
            kaguya(&k, seated: true, look: CGPoint(x: -0.2, y: -0.1), mouth: .smile)
        }
        // Her light on the door posts and the porch boards.
        let postY: CGFloat = base - 56 * hs
        Art.glow(&context, 208 - 52 * hs, postY, 30 * hs, ramp.glowColor, alpha: 0.22)
        Art.glow(&context, 208 + 52 * hs, postY, 30 * hs, ramp.glowColor, alpha: 0.22)
        Art.glow(&context, seatX, seatY + 4, 70 * hs, Art.color(0xFFF3C8), alpha: 0.16)
    }

    // MARK: scene-moon

    /// scene-moon (folded): the shining cloud and its tall figures in the middle of the band,
    /// the great full moon behind them, and small dark archers on the roof ridge below.
    static func moonFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let w: CGFloat = size.width
        let light = moonNight()
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.stars(&context, width: w, maxY: H - 60 * u, count: 34, seed: 81)
        let cloudY: CGFloat = H - 80 * u
        let moonY: CGFloat = cloudY - 60 * u
        Kit.moon(&context, 228, moonY, 66 * u, color: Art.color(0xFFF6DC))
        let farTops = Kit.ridge(width: w, y: H - 30 * u, amp: 18 * u, seed: 82, bottom: H + 8)
        Art.fill(&context, farTops, light.far)
        ArtStyle.atmosphere(&context, width: w, top: H - 80 * u, bottom: H + 8, color: light.haze, alpha: 0.2)
        let earth: Kit.Stops = Kit.stops(0x131A33, 0x0A1026)
        Kit.ground(&context, width: w, top: H, bottom: size.height, stops: earth, tooth: Art.color(0xA8B8E0))
        floorLitter(&context, size, top: H + 10, color: Art.color(0x24305A), seed: 83)
        let trail = CGPoint(x: 12, y: moonY - cloudY)
        moonVisitors(&context, x: 216, y: cloudY, width: 200 * u, trail: trail)
        moonFoldedRoof(&context, band)
        // The near plane: a dark cane and leaves at the trailing edge, grass at the leading foot.
        cane(&context, x: 424, baseY: band.h + 10, top: -20, half: 13 * u, tone: 0x0A102A, lean: -6, seed: 84)
        leafSpray(&context, x: 420, y: 10, reach: 96 * u, count: 16, color: Art.color(0x0A102A), seed: 230, droop: 0.8)
        nightGrass(&context, x: 18, y: band.h + 6, height: 80 * u, seed: 85)
        ArtStyle.finish(&context, size, wash: 0.03, vignette: 0.14)
    }

    /// The roof of the house just below the cloud, its ridge lined with astonished archers.
    static func moonFoldedRoof(_ context: inout GraphicsContext, _ band: Kit.Band) {
        let u: CGFloat = band.unit
        let rs: CGFloat = 0.8 * u
        let ridgeY: CGFloat = band.H + 4 * u
        let roofY: CGFloat = ridgeY + 204 * rs
        Art.glow(&context, 216, ridgeY - 10 * u, 140 * u, Art.color(0xFFF3C8), alpha: 0.14)
        Art.group(&context, x: 216, y: roofY, scale: rs) { r in
            houseRoof(&r, glow: 0.55)
        }
        let men: [(CGFloat, CGFloat)] = [(150, 0.5), (186, -0.3), (250, 0.6), (286, 0.3)]
        let ms: CGFloat = 0.3 * u
        for man in men {
            Art.group(&context, x: man.0, y: ridgeY, scale: ms) { a in
                archer(&a, slack: man.1)
            }
        }
    }

    // MARK: scene-fuji

    /// scene-fuji (folded): the snowy top of Fuji in the middle of the band, one thin thread
    /// of smoke rising from it to a pale moon above, dark hills below.
    static func fujiFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let light = beforeDawn()
        Kit.sky(&context, size, horizon: H, light: light)
        let peakY: CGFloat = (h * 0.42).rounded()
        let moonY: CGFloat = peakY - 74 * u
        Kit.stars(&context, width: w, maxY: peakY - 20 * u, count: 26, seed: 91)
        Kit.moon(&context, 172, moonY, 12 * u, color: Art.color(0xE9EEF8))
        let baseY: CGFloat = h + 20
        let rise: CGFloat = baseY - peakY
        let span: CGFloat = rise * 1.75
        fuji(&context, cx: 216, baseY: baseY, width: span, height: rise)
        let mouth = CGPoint(x: 216, y: peakY + 1)
        let end = CGPoint(x: 176, y: moonY + 14 * u)
        smokeThread(&context, from: mouth, to: end)
        // Low bands of cloud across the mountain's shoulders.
        let bandY: CGFloat = peakY + 44 * u
        Art.blurred(&context, radius: 5, opacity: 0.26) { c in
            var bands = Path()
            bands.addPath(Art.rect(40, bandY, 220, 12 * u, radius: 6))
            bands.addPath(Art.rect(200, bandY + 20 * u, 240, 10 * u, radius: 5))
            Art.fill(&c, bands, Art.color(0x9FB2DE))
        }
        ArtStyle.atmosphere(&context, width: w, top: peakY, bottom: H + 8, color: light.haze, alpha: 0.16)
        let farHills = Kit.ridge(width: w, y: H - 24 * u, amp: 16 * u, seed: 92, bottom: H + 8)
        Art.fill(&context, farHills, light.far)
        ArtStyle.atmosphere(&context, width: w, top: H - 50 * u, bottom: H + 8, color: light.haze, alpha: 0.14)
        let nearHills = Kit.ridge(width: w, y: H - 8 * u, amp: 12 * u, seed: 93, bottom: H + 8)
        Art.fill(&context, nearHills, light.mid)
        let earth: Kit.Stops = Kit.stops(0x16233F, 0x0C1630)
        Kit.ground(&context, width: w, top: H, bottom: h, stops: earth, tooth: Art.color(0xA8B8E0))
        floorLitter(&context, size, top: H + 10, color: Art.color(0x2A3A66), seed: 94)
        // One small torch far down on the slope: the Emperor's men on their way.
        Art.group(&context, x: 300, y: H - 6 * u, scale: 0.5 * u) { t in
            flame(&t)
        }
        nightGrass(&context, x: 408, y: h + 6, height: 110 * u, seed: 95, plumes: true)
        nightGrass(&context, x: 20, y: h + 6, height: 80 * u, seed: 96)
        ArtStyle.finish(&context, size, wash: 0.03, vignette: 0.14)
    }
}
