import SwiftUI
import OmramoCore

// The Two Sisters: the four folded scenes (the picture band at the top of a phone, 432 wide,
// 240…520 high). Each is its own composition, scaled by `band.unit`.

extension SistersArt {
    // MARK: Bridge

    /// One green bridge tower and its cables low in the frame, mist above, and the two small
    /// snowy peaks side by side on the far ridge behind.
    static func bridgeFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let light = mist()
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let w: CGFloat = size.width
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.cloud(&context, 320, H - 150 * u, scale: 0.7 * u, color: Color.white.opacity(0.45))
        twinPeaks(&context, cx: 300, baseY: H - 34 * u, scale: 0.9 * u, rock: Art.color(0xA9B9B8), snow: Art.color(0xF6F8F6), seed: 3)
        let farRange = Kit.peaks(width: w, y: H - 26 * u, amp: 34 * u, seed: 11, bottom: H + 6, sharp: 0.25)
        Art.fill(&context, farRange, light.far.opacity(0.6))
        ArtStyle.atmosphere(&context, width: w, top: H - 90 * u, bottom: H + 6, color: light.haze, alpha: 0.4)
        northShore(&context, width: w, horizon: H, scale: u * 0.8, light: light)
        mistBand(&context, width: w, y: H - 8 * u, height: 20 * u, alpha: 0.5)
        let sea: Kit.Stops = Kit.stops(0xA9C2B8, 0x5E8A7E, 0x2F5A55)
        Kit.water(&context, width: w, top: H, bottom: size.height, stops: sea, light: light, ripples: 40, seed: 41)
        // The ship slides under the deck; the near tower rises over it.
        let k: CGFloat = 1.6 * u
        Art.group(&context, x: 170, y: H, scale: k) { g in
            containerShip(&g, x: 80, waterY: 10, length: 64)
            bridge(&g, south: -150, north: 300, towerA: 0, towerB: 180, deckY: -24, top: -76, waterY: 4)
            Art.fill(&g, Art.rect(-200, -84, 520, 60), Art.color(0xEEF2EF, 0.1))
        }
        gull(&context, x: 108, y: H - 64 * u, scale: 1.1 * u, glide: true)
        gull(&context, x: 300, y: H - 30 * u, scale: 0.8 * u, glide: false)
        Kit.swells(&context, width: w, top: H + 24 * u, bottom: band.floor + 20, rows: 5, crest: Color.white, seed: 3)
        Kit.rock(&context, cx: 24, baseY: size.height + 6, width: 90 * u, height: 50 * u, color: 0x3E4A46, seed: 5)
        ArtStyle.finish(&context, size, wash: 0.08, vignette: 0.08)
    }

    // MARK: Village

    /// The chief and his two daughters at the water's edge, the sisters' shoulders touching,
    /// a plank house and a drawn-up canoe behind them, pale mist above.
    static func villageFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let light = silver()
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.cloud(&context, 120, H - 160 * u, scale: 0.7 * u, color: Color.white.opacity(0.4))
        Kit.ranges(&context, width: w, horizon: H, scale: u, light: light, mountains: true, seed: 7)
        mistBand(&context, width: w, y: H - 6 * u, height: 24 * u, alpha: 0.55)
        let sea: Kit.Stops = Kit.stops(0xBCCEC8, 0x7E9E96, 0x3E6A62)
        Kit.water(&context, width: w, top: H, bottom: h, stops: sea, light: light, ripples: 30, seed: 43)
        // The forest and the house behind the beach.
        let firs = firGreens()
        Kit.farTrees(&context, x0: 220, x1: 440, baseY: H + 4, height: 40 * u, count: 14, color: Art.color(0x2F4E46, 0.85), conifer: true, seed: 33)
        Kit.conifer(&context, x: 262, baseY: H + 6, height: 64 * u, palette: firs, seed: 4)
        Kit.conifer(&context, x: 414, baseY: H + 6, height: 74 * u, palette: firs, seed: 7)
        ArtStyle.atmosphere(&context, width: w, top: H - 80 * u, bottom: H + 6, color: light.haze, alpha: 0.22)
        let beach = Art.svg("M440,\(h) L440,\(H + 2) L250,\(H + 6) C190,\(H + 10) 150,\(H + 24) 110,\(H + 50) C80,\(H + 70) 50,\(h - 40) 30,\(h) Z")
        Kit.solid(&context, beach, stops: Kit.stops(0xB2AEA2, 0x8E8A7E, 0x77736A), light: 0.18, shade: 0.18)
        let foam = Art.svg("M250,\(H + 7) C190,\(H + 11) 150,\(H + 25) 110,\(H + 51) C80,\(H + 71) 50,\(h - 39) 30,\(h)")
        Art.stroke(&context, foam, Color.white.opacity(0.55), width: 1.5)
        plankHouse(&context, x: 336, baseY: H + 10, width: 120 * u, height: 50 * u, depth: 26 * u)
        smoke(&context, x: 350, y: H - 44 * u, height: 50 * u, seed: 3)
        canoe(&context, cx: 300, waterY: H + 22 * u, length: 110 * u, riders: [], paddlesUp: false, beached: true)
        Kit.pebbles(&context, in: CGRect(x: 120, y: H + 30 * u, width: 312, height: max(20, h - H - 40)), count: 34, seed: 21, color: 0x9A9488)
        // The three of them, low and in the middle of the band.
        let k: CGFloat = 0.9 * u
        let feet: CGFloat = min(band.floor - 2, H + band.ground * 0.55)
        Kit.shadow(&context, 176, feet, width: 46 * k, alpha: 0.26)
        Art.group(&context, x: 176, y: feet, scale: k, scaleX: -1) { g in
            chief(&g, look: CGPoint(x: -0.6, y: 0.1), mouth: .flat, mirrored: true)
        }
        Art.group(&context, x: 262, y: feet + 4 * u, scale: k * 0.98) { g in
            sisters(&g, look: CGPoint(x: -0.7, y: -0.1), mouth: .flat)
        }
        Kit.bush(&context, x: 410, baseY: h - 10, width: 70 * u, palette: berryGreens(), seed: 5)
        Kit.flowers(&context, in: CGRect(x: 384, y: h - 46 * u, width: 50 * u, height: 26 * u), count: 6, seed: 6, petal: 0xE8708E, heart: 0xF6D27A)
        ArtStyle.finish(&context, size, wash: 0.08, vignette: 0.08)
    }

    // MARK: Canoes

    /// Long canoes gliding in close, a child leaning over the side, the beach and the waiting
    /// people just beyond; pale sky above.
    static func canoesFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let light = bright()
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.sun(&context, 70, H - 18 * u, 10 * u, light: light)
        Kit.ranges(&context, width: w, horizon: H, scale: u, light: light, mountains: true, seed: 12)
        mistBand(&context, width: w, y: H - 4 * u, height: 18 * u, alpha: 0.5)
        let sea: Kit.Stops = Kit.stops(0xC6D8D2, 0x86AAA0, 0x3E6A62)
        Kit.water(&context, width: w, top: H, bottom: h, stops: sea, light: light, ripples: 40, seed: 47)
        Kit.glints(&context, x: 70, top: H, depth: h - H, color: Art.color(0xFFF4DC), count: 20, seed: 5)
        // The far beach and the people waiting on it.
        let shore = Art.svg("M300,\(H + 3) C340,\(H) 400,\(H - 1) 440,\(H - 1) L440,\(H + 18 * u) C400,\(H + 18 * u) 340,\(H + 14 * u) 300,\(H + 3) Z")
        Art.fill(&context, shore, Art.color(0xA8A498))
        Kit.farTrees(&context, x0: 310, x1: 440, baseY: H + 1, height: 30 * u, count: 10, color: Art.color(0x2F4E46, 0.8), conifer: true, seed: 43)
        let crowdXs: [CGFloat] = [330, 346, 362, 384, 400, 418]
        for (i, cx) in crowdXs.enumerated() {
            Art.group(&context, x: cx, y: H + 8 * u, scale: 0.2 * u) { g in
                Kit.person(&g, villagerLook(i % 3), pose: .stand, look: CGPoint(x: -0.8, y: 0), mouth: .flat)
            }
        }
        // Three canoes, the nearest one big and low in the band.
        let few: [Rider] = [(x: -26, cloth: bark, kind: 0), (x: -6, cloth: wool, kind: 1), (x: 14, cloth: 0x8C6A4A, kind: 0), (x: 32, cloth: bark, kind: 0)]
        inboundCanoe(&context, x: 120, y: H + 8 * u, length: 120 * u, riders: few, up: true)
        inboundCanoe(&context, x: 270, y: H + 20 * u, length: 170 * u, riders: few, up: true)
        let family: [Rider] = [(x: -34, cloth: bark, kind: 0), (x: -18, cloth: wool, kind: 1), (x: -2, cloth: 0x9A7652, kind: 2), (x: 14, cloth: 0xC9BCA0, kind: 1), (x: 30, cloth: 0x7A5A40, kind: 0)]
        let nearY: CGFloat = min(band.floor - 6, H + band.ground * 0.5)
        inboundCanoe(&context, x: 196, y: nearY, length: 280 * u, riders: family, up: true)
        Kit.swells(&context, width: w, top: nearY + 8, bottom: h, rows: 3, crest: Color.white, seed: 2)
        ArtStyle.finish(&context, size, wash: 0.08, vignette: 0.08)
    }

    // MARK: Peaks

    /// The two rounded peaks side by side, glowing rose-gold, filling the lower half of the
    /// band; a pale rose sky above.
    static func peaksFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let light = evening()
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.sun(&context, 44, H - 12 * u, 11 * u, light: light)
        twinPeaks(&context, cx: 222, baseY: H - 6 * u, scale: 2.3 * u, rock: Art.color(0xB2ACBE), snow: Art.color(0xF8D2BE), glow: Art.color(0xFFE0B4), seed: 6)
        Art.glow(&context, 200, H - 100 * u, 140 * u, Art.color(0xFFD9B0), alpha: 0.16)
        let range = Kit.peaks(width: w, y: H - 14 * u, amp: 26 * u, seed: 15, bottom: H + 6, sharp: 0.3)
        Art.fill(&context, range, light.far)
        ArtStyle.atmosphere(&context, width: w, top: H - 50 * u, bottom: H + 6, color: light.haze, alpha: 0.3)
        let slopes = Kit.ridge(width: w, y: H - 6 * u, amp: 6 * u, seed: 29, bottom: H + 6)
        Art.fill(&context, slopes, light.mid)
        Kit.farTrees(&context, x0: 0, x1: w, baseY: H - 1, height: 8 * u, count: 30, color: light.near.opacity(0.4), conifer: true, seed: 37)
        let sea: Kit.Stops = Kit.stops(0xD2C4C6, 0x8E8E9E, 0x4A5066)
        Kit.water(&context, width: w, top: H, bottom: h, stops: sea, light: light, ripples: 30, seed: 51)
        Kit.glints(&context, x: 44, top: H, depth: h - H, color: Art.color(0xFFE6C8), count: 22, seed: 9)
        var random = ArtRandom(63)
        var lights = Path()
        for _ in 0..<24 {
            let lx: CGFloat = 10 + Kit.rnd(&random) * 412
            let ly: CGFloat = H + 1 + Kit.rnd(&random) * 5 * u
            lights.addPath(Art.circle(lx, ly, 0.8 + Kit.rnd(&random) * 0.6))
        }
        Art.fill(&context, lights, Art.color(0xFFD98A, 0.95))
        Art.group(&context, opacity: 0.85) { g in
            let riders: [Rider] = [(x: -20, cloth: bark, kind: 0), (x: 4, cloth: wool, kind: 1), (x: 24, cloth: 0x8C6A4A, kind: 0)]
            inboundCanoe(&g, x: 150, y: H + band.ground * 0.45, length: 60 * u, riders: riders, up: false)
        }
        Kit.swells(&context, width: w, top: H + 16 * u, bottom: h, rows: 4, crest: Art.color(0xF6E0D0), seed: 4)
        Kit.cornerLeaves(&context, size: size, corner: 3, color: Art.color(0x2A3446), scale: 0.7 * u, seed: 2)
        ArtStyle.finish(&context, size, wash: 0.08, vignette: 0.1)
    }
}
