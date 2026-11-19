import SwiftUI
import OmramoCore

// The folded (phone) bands of "Savitri and Satyavan": 432 wide, 240…520 high. Each is its own
// composition: the far plane in band units, then the group of figures drawn about the band's
// middle on its horizon at `band.unit`, faces inside x 86…346 and above the wave edge.

extension SavitriArt {
    /// Draws `body` about the middle of the band on its horizon, scaled by the band's unit.
    static func onBand(_ context: inout GraphicsContext, _ band: Kit.Band, _ body: (inout GraphicsContext) -> Void) {
        Art.group(&context, x: 216, y: band.H, scale: band.unit, body)
    }

    /// The lowest local y the group may fill down to (the bottom edge, in band-local units).
    static func bandReach(_ band: Kit.Band) -> CGFloat {
        (band.h - band.H) / band.unit
    }

    /// Savitri on the terrace in saffron, her father seated, Narada beside him, the lotus pool
    /// at their feet; pale morning sky above.
    static func palaceFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let light = morning()
        let u: CGFloat = band.unit
        Kit.sky(&context, size, horizon: band.H, light: light)
        Kit.sun(&context, 64, band.H - 46 * u, 9 * u, light: light)
        Kit.cloud(&context, 300, band.H - 120 * u, scale: 0.5 * u, color: Color.white.opacity(0.45))
        Kit.ranges(&context, width: size.width, horizon: band.H, scale: u * 0.5, light: light, seed: 21)
        farPavilion(&context, cx: 34, baseY: band.H + 2, width: 40 * u, height: 26 * u, color: 0xE9DDC0)
        torana(&context, cx: 92, baseY: band.H + 2, height: 38 * u, color: 0xE4D4B2)
        farPavilion(&context, cx: 150, baseY: band.H + 2, width: 30 * u, height: 20 * u, color: 0xE9DDC0)
        ArtStyle.atmosphere(&context, width: size.width, top: band.H - 60 * u, bottom: band.H + 4, color: light.haze, alpha: 0.3)
        let lawn: Kit.Stops = [(Art.color(0xDCD6A4), 0), (Art.color(0x9EA866), 1)]
        Kit.ground(&context, width: size.width, top: band.H, bottom: size.height, stops: lawn, seed: 71)
        let reach: CGFloat = bandReach(band)
        onBand(&context, band) { g in
            for x in [CGFloat(-30), 50, 130, 210] {
                timberPillar(&g, cx: x, baseY: -6, height: 84, width: 10)
            }
            Kit.solid(&g, Art.rect(-50, -96, 290, 10, radius: 3), Art.color(0xC79A68), light: 0.2, shade: 0.18)
            Kit.fence(&g, x0: -60, x1: 260, baseY: -4, height: 18, color: 0xD7B488)
            let top = Art.polygon([CGPoint(x: -300, y: -8), CGPoint(x: 300, y: -8), CGPoint(x: 300, y: 22), CGPoint(x: -300, y: 22)])
            Kit.solid(&g, top, stops: Kit.stops(0xF6ECD4, 0xEFE3C6), light: 0.16, shade: 0.1)
            Kit.solid(&g, Art.rect(-300, 22, 600, 16), Art.color(0xDCCBA4), light: 0.14, shade: 0.2)
            king(&g, x: 46, y: 12, scale: 0.72)
            narada(&g, x: 116, y: 8, scale: 0.72, right: false)
            savitri(&g, x: -62, y: 16, scale: 0.72, right: true, bark: false, pose: .stand, pot: false)
            foldedPool(&g, top: 40, reach: reach)
        }
        Kit.cornerLeaves(&context, size: size, corner: 2, color: Art.color(ramp.deep, 0.9), scale: 0.6 * u, seed: 4)
        ArtStyle.finish(&context, size, wash: 0.10, vignette: 0.08)
    }

    /// The stepped lotus pool across the band from local `top` down to `reach`.
    static func foldedPool(_ g: inout GraphicsContext, top: CGFloat, reach: CGFloat) {
        let deep: CGFloat = max(30, reach - top)
        Kit.solid(&g, Art.rect(-300, top, 600, deep), Art.color(0xD8C9A6), light: 0.14, shade: 0.14)
        let water = Art.rect(-300, top + 10, 600, deep - 10)
        let pond: Kit.Stops = [(Art.color(0xA8D2C2), 0), (Art.color(0x6FA79A), 1)]
        Art.fillLinear(&g, water, pond, from: CGPoint(x: 0, y: top + 10), to: CGPoint(x: 0, y: top + deep))
        Kit.rippleMarks(&g, x0: -260, x1: 260, y0: top + 14, y1: top + deep, count: 14, seed: 6, color: Color.white, alpha: 0.35)
        let pads: [(CGFloat, CGFloat, CGFloat, Bool)] = [(-150, 22, 10, true), (-80, 36, 12, false), (-10, 24, 9, true), (70, 40, 13, false), (150, 26, 10, true)]
        for pad in pads {
            Kit.lilyPad(&g, cx: pad.0, cy: top + pad.1, r: pad.2, flower: pad.3, pad: 0x5E8E4E)
        }
        Kit.groundLotus(&g, x: -40, y: top + 30, size: 11)
        Kit.groundLotus(&g, x: 110, y: top + 34, size: 12)
        Art.stroke(&g, Art.line(-300, top + 1, 300, top + 1), Color.white.opacity(0.5), width: 1.4)
    }

    /// Savitri with the water pot beside the old king and queen at the fire altar, a hut
    /// behind; soft gold sky above.
    static func hermitageFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let light = goldLight()
        let u: CGFloat = band.unit
        Kit.sky(&context, size, horizon: band.H, light: light)
        Kit.sun(&context, 58, band.H - 40 * u, 9 * u, light: light)
        let farH: CGFloat = 52 * u
        Kit.farTrees(&context, x0: -10, x1: 442, baseY: band.H + 2, height: farH, count: 12, color: light.far, seed: 7)
        ArtStyle.atmosphere(&context, width: size.width, top: band.H - farH * 1.3, bottom: band.H + 4, color: light.haze, alpha: 0.4)
        Kit.farTrees(&context, x0: -10, x1: 442, baseY: band.H + 4, height: farH * 0.7, count: 10, color: light.mid, seed: 17)
        let earth: Kit.Stops = [(Art.color(0xE4D09E), 0), (Art.color(0xB49A62), 1)]
        Kit.ground(&context, width: size.width, top: band.H, bottom: size.height, stops: earth, seed: 73)
        let reach: CGFloat = bandReach(band)
        onBand(&context, band) { g in
            hut(&g, cx: 136, baseY: 0, width: 96, height: 94, lamps: false)
            hut(&g, cx: -150, baseY: -6, width: 60, height: 60, lamps: false)
            chital(&g, x: -210, y: 6, scale: 0.34, right: true)
            fireAltar(&g, cx: -12, baseY: 22, width: 36, smoke: true)
            seatedElder(&g, queenLook(), x: 40, y: 26, scale: 0.7, right: false, gaze: CGPoint(x: -0.5, y: 0), staff: false)
            seatedElder(&g, oldKingLook(), x: 104, y: 24, scale: 0.7, right: false, gaze: CGPoint(x: -0.2, y: -0.7), staff: true)
            savitri(&g, x: -86, y: 30, scale: 0.72, right: true, bark: true, pose: .walk, pot: true)
            if reach > 50 {
                meadowFill(&g, x0: -260, x1: 260, top: 44, bottom: reach, seed: 45)
            }
        }
        Kit.cornerLeaves(&context, size: size, corner: 3, color: Art.color(ramp.deep, 0.9), scale: 0.6 * u, seed: 5)
        ArtStyle.finish(&context, size, wash: 0.10, vignette: 0.08)
    }

    /// Satyavan with his axe and bundle of wood and Savitri beside him under the hanging roots
    /// of the banyan; pale light above.
    static func forestFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let light = afternoon()
        let u: CGFloat = band.unit
        Kit.sky(&context, size, horizon: band.H, light: light)
        let farH: CGFloat = 40 * u
        Kit.farTrees(&context, x0: -10, x1: 442, baseY: band.H + 2, height: farH, count: 12, color: light.far, seed: 23)
        ArtStyle.atmosphere(&context, width: size.width, top: band.H - farH * 1.4, bottom: band.H + 4, color: light.haze, alpha: 0.38)
        let dust: Kit.Stops = [(Art.color(0xDCC48E), 0), (Art.color(0x9A8452), 1)]
        Kit.ground(&context, width: size.width, top: band.H, bottom: size.height, stops: dust, seed: 75)
        let reach: CGFloat = bandReach(band)
        onBand(&context, band) { g in
            banyan(&g, x: 64, baseY: 12, height: 172, spread: 380, seed: 14)
            woodBundle(&g, cx: -44, baseY: 30, width: 54)
            satyavan(&g, x: 8, y: 24, scale: 0.72, right: false, pose: .stand, axe: true)
            savitri(&g, x: 80, y: 26, scale: 0.72, right: false, bark: true, pose: .stand, pot: false, mouth: .flat)
            peacock(&g, x: -150, y: 34, scale: 0.6, right: false)
            if reach > 50 {
                fallenLeaves(&g, in: CGRect(x: -240, y: 44, width: 480, height: reach - 44), seed: 53)
            }
        }
        let fade: Kit.Stops = [(Color.white.opacity(0.14), 0), (Color.white.opacity(0), 1)]
        let shaft = Art.polygon([CGPoint(x: 40, y: 0), CGPoint(x: 90, y: 0), CGPoint(x: 190, y: band.H), CGPoint(x: 120, y: band.H)])
        Art.fillLinear(&context, shaft, fade, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: band.H))
        Kit.cornerLeaves(&context, size: size, corner: 2, color: Art.color(ramp.deep, 0.92), scale: 0.6 * u, seed: 8)
        ArtStyle.finish(&context, size, wash: 0.10, vignette: 0.09)
    }

    /// Savitri following Yama along the path through the gold grass, the small light glowing
    /// in his hand; pale rose sky above.
    static func southRoadFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let light = evening()
        let u: CGFloat = band.unit
        Kit.sky(&context, size, horizon: band.H, light: light)
        Kit.sun(&context, 62, band.H - 26 * u, 11 * u, light: light)
        Kit.cloud(&context, 320, band.H - 130 * u, scale: 0.5 * u, color: Art.color(0xFFF2EC, 0.5))
        Kit.ranges(&context, width: size.width, horizon: band.H, scale: u * 0.32, light: light, seed: 33)
        Kit.farTrees(&context, x0: -10, x1: 120, baseY: band.H + 2, height: 26 * u, count: 5, color: light.far, seed: 3)
        let field: Kit.Stops = [(Art.color(0xEACB92), 0), (Art.color(0xB88E54), 1)]
        Kit.ground(&context, width: size.width, top: band.H, bottom: size.height, stops: field, seed: 77)
        let reach: CGFloat = bandReach(band)
        onBand(&context, band) { g in
            goldGrass(&g, x0: -320, x1: 320, baseY: 6, height: 8, seed: 11)
            let path: Kit.Stops = [(Art.color(0xE6C49A), 0), (Art.color(0xF0D6B2), 1)]
            Kit.ribbon(&g, nearX: -60, nearY: reach + 10, nearWidth: 120, farX: 190, farY: 4, farWidth: 10, stops: path)
            goldGrass(&g, x0: -320, x1: -40, baseY: 22, height: 16, seed: 12)
            Art.glow(&g, 70, -40, 80, Art.color(0xFFD27A), alpha: 0.2)
            yama(&g, x: 62, y: 18, scale: 0.62, right: true, pose: .walk, light: true)
            savitri(&g, x: -46, y: 30, scale: 0.68, right: true, bark: true, pose: .walk, pot: false, mouth: .flat)
            goldGrass(&g, x0: -320, x1: 320, baseY: 42, height: 26, seed: 13)
            if reach > 70 {
                goldGrass(&g, x0: -320, x1: 320, baseY: reach - 6, height: 34, seed: 14)
            }
        }
        Kit.cornerLeaves(&context, size: size, corner: 2, color: Art.color(0x6A5A32, 0.9), scale: 0.6 * u, seed: 12)
        ArtStyle.finish(&context, size, wash: 0.10, vignette: 0.08)
    }
}
