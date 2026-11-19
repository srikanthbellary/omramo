import SwiftUI
import OmramoCore

// The four scenes of "Why the Sun and the Moon Live in the Sky" as the picture band at the top
// of a phone: 432 wide, about 240…520 high. Each is its own composition, not a crop: the faces
// sit inside x 86…346, clear of the two top controls and above the wave edge, and everything
// scales with the band (`band.unit`) and stands on its horizon.

extension SunMoonArt {
    // MARK: scene-visit

    /// scene-visit (folded): the Sun's glowing face in the middle of the band, in his canoe;
    /// the Water's face rising from the river just below and beside him; mangroves on their
    /// long legs framing the edges.
    static func visitFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let h: CGFloat = size.height
        let light = day()
        Kit.sky(&context, size, horizon: H, light: light)
        farShore(&context, x0: -40, x1: 150, horizon: H, height: 12 * u, light: light, seed: 3)
        farShore(&context, x0: 250, x1: 480, horizon: H, height: 16 * u, light: light, seed: 8)
        ArtStyle.atmosphere(&context, width: 432, top: H - 50 * u, bottom: H + 4, color: light.haze, alpha: 0.3)
        Kit.water(&context, width: 432, top: H, bottom: h, stops: riverStops(), light: light, ripples: 30)
        palm(&context, x: 392, baseY: H + 6 * u, height: 250 * u, lean: -14 * u, seed: 4)
        Kit.mangrove(&context, x: 404, waterY: H + 20 * u, height: 190 * u, palette: mangroveGreens(), seed: 6)
        Kit.mangrove(&context, x: 16, waterY: H + 14 * u, height: 120 * u, palette: mangroveGreens(), seed: 2)
        let waterY: CGFloat = H + band.ground * 0.42
        Art.group(&context, x: 130, y: waterY + 8 * u, scale: 0.52 * u) { g in
            waterFigure(&g, look: CGPoint(x: 0.7, y: -0.3), laugh: true, wave: true)
        }
        Art.group(&context, x: 250, y: waterY, scale: 0.8 * u) { g in
            sunInCanoe(&g, look: CGPoint(x: -0.6, y: 0.3), mouth: .grin)
        }
        ArtStyle.finish(&context, size)
    }

    // MARK: scene-building

    /// scene-building (folded): the Sun and the Moon face to face on the roof, tying palm
    /// thatch onto it — his gold glow and her silver halo side by side — with the red wall
    /// below them.
    static func buildingFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let h: CGFloat = size.height
        let light = day()
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.farTrees(&context, x0: -10, x1: 442, baseY: H + 2, height: 30 * u, count: 16, color: light.far, seed: 5)
        ArtStyle.atmosphere(&context, width: 432, top: H - 50 * u, bottom: H + 4, color: light.haze, alpha: 0.35)
        palm(&context, x: 36, baseY: H + 4 * u, height: 120 * u, lean: 8 * u, seed: 3)
        palm(&context, x: 404, baseY: H + 4 * u, height: 170 * u, lean: -12 * u, seed: 7)
        Kit.ground(&context, width: 432, top: H, bottom: h, stops: yardStops())

        // The house: its red earth wall fills the foot of the band, the roof is half thatched.
        let eaveY: CGFloat = H + 14 * u
        let roofH: CGFloat = 62 * u
        Kit.wall(&context, rect: CGRect(x: 66, y: eaveY, width: 300, height: h - eaveY + 10), color: earth)
        let window = CGRect(x: 104, y: eaveY + 22 * u, width: 28 * u, height: 28 * u)
        Kit.opening(&context, rect: window, arched: false, color: 0x5A3A2A)
        Art.fill(&context, Art.rect(66, eaveY, 300, 8 * u), ArtStyle.coolShade.opacity(0.16))
        roofFrame(&context, cx: 216, eaveY: eaveY, width: 372, height: roofH)
        Art.clipped(&context, to: Art.rect(0, 0, 226, h)) { c in
            thatchRoof(&c, cx: 216, eaveY: eaveY, width: 372, height: roofH)
        }

        // The two of them, kneeling on the roof, with the thatch between their hands.
        let s: CGFloat = 0.66 * u
        let y0: CGFloat = eaveY - 8 * u
        let headY: CGFloat = y0 - 120 * s
        sunGlow(&context, 168 + 15 * s, headY + 10 * s, 86 * s)
        moonGlow(&context, 268 - 15 * s, headY - 4 * s, 56 * s)
        Art.group(&context, x: 168, y: y0, scale: s, scaleX: -1) { p in
            sunFigure(&p, pose: .kneel, look: CGPoint(x: -0.6, y: 0.3), mouth: .grin, mirrored: true, glow: 0)
        }
        Art.group(&context, x: 268, y: y0, scale: s) { p in
            moonFigure(&p, pose: .kneel, look: CGPoint(x: -0.6, y: 0.3), mouth: .smile, glow: 0)
        }
        Art.group(&context, x: 208, y: y0 - 16 * s, scale: 0.9 * u) { b in
            palmBundle(&b)
        }
        ArtStyle.finish(&context, size)
    }

    // MARK: scene-flood

    /// scene-flood (folded): the Sun and the Moon sitting on the roof ridge in the middle of
    /// the band, looking down; shining water and fish rising round the roof; the Water's
    /// friendly face at the bottom.
    static func floodFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let h: CGFloat = size.height
        let light = day()
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.cloud(&context, 96, H * 0.5, scale: 0.5 * u, color: Art.color(0xFFFFFF, 0.6))
        Kit.farTrees(&context, x0: -10, x1: 442, baseY: H + 2, height: 26 * u, count: 16, color: light.far, seed: 7)
        ArtStyle.atmosphere(&context, width: 432, top: H - 50 * u, bottom: H + 4, color: light.haze, alpha: 0.35)
        palm(&context, x: 410, baseY: H + 30 * u, height: 150 * u, lean: -16 * u, seed: 6)
        Kit.water(&context, width: 432, top: H, bottom: h, stops: floodStops(), light: light, ripples: 34, seed: 41)

        let s: CGFloat = 0.62 * u
        let ridge: CGFloat = H - 6 * u
        let roofH: CGFloat = 54 * u
        let eaveY: CGFloat = ridge + roofH
        let half: CGFloat = 140 * u
        thatchRoof(&context, cx: 240, eaveY: eaveY, width: half * 2, height: roofH)
        shallows(&context, x0: 240 - half - 6, x1: 240 + half + 6, y: eaveY - 2 * u, depth: 16 * u)
        Kit.rippleMarks(&context, x0: 0, x1: 432, y0: eaveY, y1: h, count: 16, seed: 9, color: Color.white, alpha: 0.45)

        let seatY: CGFloat = ridge + 34 * s
        let headY: CGFloat = seatY - 128 * s
        sunGlow(&context, 204 + 6 * s, headY + 12 * s, 86 * s)
        moonGlow(&context, 280 + 6 * s, headY - 4 * s, 56 * s)
        Art.group(&context, x: 204, y: seatY, scale: s) { p in
            sunFigure(&p, pose: .sit, look: CGPoint(x: -0.7, y: 0.7), mouth: .oh, glow: 0)
        }
        Art.group(&context, x: 280, y: seatY, scale: s) { p in
            moonFigure(&p, pose: .sit, look: CGPoint(x: -0.6, y: 0.7), mouth: .smile, glow: 0)
        }

        // The Water and his people, rising below them.
        fish(&context, 372, eaveY + 8 * u, scale: 0.8 * u, flip: true)
        fish(&context, 330, H + 16 * u, scale: 0.6 * u)
        prawn(&context, 388, band.floor - 10 * u, scale: 0.9 * u, flip: true)
        crab(&context, 184, eaveY + 30 * u, scale: 0.7 * u)
        Art.group(&context, x: 100, y: band.floor + 8, scale: 0.5 * u) { g in
            waterFigure(&g, look: CGPoint(x: 0.7, y: -0.7), laugh: true, wave: true)
        }
        ArtStyle.finish(&context, size)
    }

    // MARK: scene-sky

    /// scene-sky (folded): the Sun and the Moon together in the middle of a pale sky, gold
    /// and silver glows touching; a strip of calm water and one palm top at the very bottom.
    static func skyFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.2, least: 46, most: 100)
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let h: CGFloat = size.height
        let light = day()
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.cloud(&context, 70, H - 24 * u, scale: 0.45 * u, color: Art.color(0xFFFFFF, 0.55))
        Kit.water(&context, width: 432, top: H, bottom: h, stops: floodStops(), light: light, ripples: 20, seed: 52)
        Kit.glints(&context, x: 196, top: H, depth: band.ground, color: Art.color(0xFFE08A), count: 14, seed: 8)
        Kit.glints(&context, x: 250, top: H, depth: band.ground, color: Art.color(0xF4F6FF), count: 10, seed: 15)
        let cut: CGFloat = H + 10 * u
        Art.clipped(&context, to: Art.rect(0, 0, 432, cut)) { c in
            palm(&c, x: 368, baseY: H + 90 * u, height: 150 * u, lean: -8 * u, seed: 5)
        }
        Kit.ripples(&context, 362, cut + 1, 34 * u, count: 2)
        Kit.birds(&context, 60, H - 70 * u, scale: 0.8 * u, color: Art.color(0x5E8F96))
        let s: CGFloat = 0.8 * u
        Art.group(&context, x: 216, y: H - 52 * u, scale: s) { g in
            skyPair(&g, look: CGPoint(x: -0.3, y: 0.6))
        }
        ArtStyle.finish(&context, size)
    }
}
