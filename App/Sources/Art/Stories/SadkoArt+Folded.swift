import SwiftUI
import OmramoCore

// The four folded scenes of "Sadko": each its own composition for the picture band at the top
// of a phone (432 wide, 240…520 high). All dark, the subject glowing in the middle.

extension SadkoArt {
    // MARK: scene-novgorod (folded)

    /// Sadko on the river bank at dusk with the gusli on his knees; the white cathedral and
    /// lamplit log houses behind his shoulder; dark starry sky above.
    static func novgorodFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let light = dusk()
        let u: CGFloat = band.unit
        Kit.sky(&context, size, horizon: band.H, light: light)
        Kit.stars(&context, width: 432, maxY: band.H - 70 * u, count: 40, seed: 21)
        let forest: Path = Kit.ridge(width: 432, y: band.H - 6 * u, amp: 5 * u, seed: 6, bottom: band.H + 6, step: 6)
        Art.fill(&context, forest, light.far)
        let river: Kit.Stops = [(Art.color(0x2B4468), 0), (Art.color(0x17294A), 0.3), (Art.color(0x0C1730), 1)]
        Kit.water(&context, width: 432, top: band.H, bottom: size.height, stops: river, light: light, ripples: 14, seed: 31)
        // The city on the far bank, in units scaled by the band, origin on the horizon.
        Art.group(&context, x: 216, y: band.H, scale: u) { g in
            Art.fill(&g, Art.rect(-380, -7, 760, 18, radius: 6), Art.color(0x182038))
            Art.glow(&g, 104, -70, 100, Art.color(0x6F8FC0), alpha: 0.16)
            Art.group(&g, x: 104, y: -8, scale: 0.6) { c in
                cathedral(&c)
            }
            rampart(&g, x0: 20, x1: 380, y: -2)
            Art.group(&g, x: 34, y: -2, scale: 0.62) { c in
                woodTower(&c)
            }
            let houses: [(CGFloat, CGFloat, CGFloat)] = [(-168, 5, 0.8), (-112, 8, 0.95), (176, 8, 0.9)]
            for house in houses {
                Art.group(&g, x: house.0, y: house.1, scale: house.2) { c in
                    logHouse(&c, w: 52, wall: 30, lit: true)
                }
            }
            let gold: Color = Art.color(0xFFC65A, 0.5)
            Kit.glints(&g, x: -112, top: 12, depth: 40, color: gold, count: 7, seed: 3)
            Kit.glints(&g, x: 176, top: 12, depth: 40, color: gold, count: 6, seed: 14)
        }
        // The near bank, the torch and Sadko.
        let fy: CGFloat = band.floor - 4
        let s: CGFloat = u * 0.95
        var bank = Path()
        bank.move(to: CGPoint(x: 0, y: fy + 12))
        bank.addQuadCurve(to: CGPoint(x: 432, y: fy - 6), control: CGPoint(x: 216, y: fy - 22))
        bank.addLine(to: CGPoint(x: 432, y: size.height))
        bank.addLine(to: CGPoint(x: 0, y: size.height))
        bank.closeSubpath()
        let turf: Kit.Stops = [(Art.color(0x26383A), 0), (Art.color(0x0E1620), 1)]
        Art.fillLinear(&context, bank, turf, from: CGPoint(x: 0, y: fy - 16), to: CGPoint(x: 0, y: size.height))
        let dark: Color = Art.color(0x0A101C)
        reedClump(&context, 30, fy + 10, count: 7, height: 44 * u, seed: 4, color: dark)
        reedClump(&context, 404, fy + 2, count: 6, height: 40 * u, seed: 12, color: dark)
        Art.group(&context, x: 222 - 84 * s, y: fy - 2, scale: s * 0.9) { g in
            torch(&g)
        }
        Art.glow(&context, 216, fy - 80 * s, 110 * s, Art.color(0xFFC65A), alpha: 0.16)
        Art.group(&context, x: 222, y: fy, scale: s) { g in
            let seat: Path = Art.rect(-16, -34, 60, 34, radius: 12)
            Kit.shadow(&g, 4, 1, width: 96, alpha: 0.4)
            Kit.solid(&g, seat, stops: Kit.stops(0x7A5A40, 0x3A2A24), light: 0.3, shade: 0.3)
            Art.stroke(&g, Art.ellipse(-8, -17, 6, 13), Art.color(0x2A1E1C, 0.6), width: 1.2)
            sadkoPlaying(&g, look: CGPoint(x: -0.3, y: -0.2))
        }
        ArtStyle.finish(&context, size, wash: 0.05, vignette: 0.14)
    }

    // MARK: scene-lake (folded)

    /// The Sea Tsar's crowned head and streaming green beard filling the band; Sadko on the
    /// white stone in the lower right, looking up as he plays; stars above.
    static func lakeFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let light = night()
        let u: CGFloat = band.unit
        Kit.sky(&context, size, horizon: band.H, light: light)
        Kit.stars(&context, width: 432, maxY: band.H - 12 * u, count: 90, seed: 33)
        let shore: Path = Kit.ridge(width: 432, y: band.H - 4 * u, amp: 3 * u, seed: 15, bottom: band.H + 6, step: 6)
        Art.fill(&context, shore, light.far)
        let lake: Kit.Stops = [(Art.color(0x1D3F62), 0), (Art.color(0x10294A), 0.3), (Art.color(0x070E22), 1)]
        Kit.water(&context, width: 432, top: band.H, bottom: size.height, stops: lake, light: light, ripples: 12, seed: 12)
        Kit.swells(&context, width: 432, top: band.H + 8, bottom: size.height, rows: 5, crest: Art.color(0xBFD3E6), seed: 12)
        // The Sea Tsar, risen to the chest.
        let s: CGFloat = u * 0.95
        let waterY: CGFloat = band.H + 12
        Art.glow(&context, 170, waterY - 100 * s, 190 * s, Art.color(0x4FAE9E), alpha: 0.22)
        Art.group(&context, x: 170, y: waterY - 120 * s, scale: s) { g in
            tsarRising(&g, waterline: 120)
        }
        Art.glow(&context, 62, waterY + 16 * u, 22 * u, Art.color(0xFFC65A), alpha: 0.25)
        Art.group(&context, x: 62, y: waterY + 16 * u, rotate: Kit.deg(-18), scale: 0.7 * u) { g in
            fish(&g)
        }
        // The near shore, the white stone and Sadko.
        let fy: CGFloat = band.floor - 2
        let k: CGFloat = u * 0.78
        var bank = Path()
        bank.move(to: CGPoint(x: 432, y: fy - 10))
        bank.addLine(to: CGPoint(x: 300, y: fy - 5))
        bank.addQuadCurve(to: CGPoint(x: 212, y: size.height), control: CGPoint(x: 244, y: fy + 4))
        bank.addLine(to: CGPoint(x: 432, y: size.height))
        bank.closeSubpath()
        let turf: Kit.Stops = [(Art.color(0x1C2C3A), 0), (Art.color(0x070C18), 1)]
        Art.fillLinear(&context, bank, turf, from: CGPoint(x: 0, y: fy - 10), to: CGPoint(x: 0, y: size.height))
        let dark: Color = Art.color(0x050A18)
        reedClump(&context, 262, fy + 6, count: 6, height: 36 * u, seed: 3, color: dark)
        reedClump(&context, 410, fy - 4, count: 6, height: 44 * u, seed: 13, color: dark)
        Art.glow(&context, 320, fy - 80 * k, 90 * k, Art.color(0xBFD3E6), alpha: 0.14)
        Art.group(&context, x: 318, y: fy, scale: k) { g in
            whiteStone(&g)
            sadkoPlaying(&g, look: CGPoint(x: -0.7, y: -0.7), mouth: .oh)
        }
        ArtStyle.finish(&context, size, wash: 0.04, vignette: 0.14)
    }

    // MARK: scene-ship (folded)

    /// The nearest ship's side and red sail; Sadko at the rail with the gusli under his arm,
    /// looking down at the oak plank on the dark water.
    static func shipFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let light = night()
        let u: CGFloat = band.unit
        Kit.sky(&context, size, horizon: band.H, light: light)
        Kit.stars(&context, width: 432, maxY: band.H - 30 * u, count: 60, seed: 41)
        let sea: Kit.Stops = [(Art.color(0x1B2F52), 0), (Art.color(0x0B1A33), 0.5), (Art.color(0x070E22), 1)]
        Kit.water(&context, width: 432, top: band.H, bottom: size.height, stops: sea, light: light, ripples: 10, seed: 19)
        Kit.swells(&context, width: 432, top: band.H + 6, bottom: size.height, rows: 6, crest: Art.color(0xE9EEF2), seed: 5)
        // A far ship of the fleet, small on the horizon.
        Art.group(&context, x: 392, y: band.H + 5 * u, scale: 0.16 * u, opacity: 0.8) { g in
            ship(&g)
        }
        let s: CGFloat = u * 1.5
        let waterY: CGFloat = band.H + band.ground * 0.3
        Art.blurred(&context, radius: 8, opacity: 0.85) { g in
            Art.fill(&g, Art.ellipse(236, waterY + 6 * s, 150 * s, 14 * s), Art.color(0x0B1A33))
        }
        Art.group(&context, x: 240, y: waterY, scale: s) { g in
            shipSail(&g)
            Art.glow(&g, -30, -60, 80, Art.color(0xFFC65A), alpha: 0.3)
            Art.group(&g, x: 44, y: -12, scale: 0.46) { p in
                Kit.person(&p, sailorLook(), pose: .stand, look: CGPoint(x: -0.6, y: 0.6), mouth: .flat)
            }
            Art.group(&g, x: -50, y: -12, scale: 0.5) { p in
                sadkoStanding(&p, look: CGPoint(x: -0.4, y: 0.9), mouth: .flat)
            }
            shipHull(&g)
            // The oak plank on the water below him, still on its two ropes.
            Art.stroke(&g, Art.svg("M-92,-26 L-88,11 M-22,-22 L-20,11"), Art.color(0xC9B79A), width: 1.3)
            let plank: Path = Art.rect(-98, 10, 86, 7, radius: 2)
            Kit.solid(&g, plank, Art.color(0xB08A5A), light: 0.34, shade: 0.24)
            Kit.ripples(&g, -55, 18, 100, count: 1, color: Art.color(0xE9EEF2), opacity: 0.5)
        }
        ArtStyle.finish(&context, size, wash: 0.04, vignette: 0.14)
    }

    // MARK: scene-palace (folded)

    /// The Sea Tsar dancing in the middle, robe swirling and beard flying, in green
    /// underwater light; Sadko small at his feet with the gusli.
    static func palaceFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        seaDeep(&context, size, floorY: band.H, lightX: 216, spread: band.H * 0.9)
        lightShafts(&context, x0: 130, x1: 340, bottom: band.H + 10)
        Art.group(&context, x: 318, y: band.H + 6, scale: 0.5 * u, opacity: 0.75) { g in
            palace(&g)
        }
        let dark: Color = Art.color(0x061C20)
        weed(&context, 26, size.height, count: 4, height: 90 * u, seed: 3, color: dark)
        weed(&context, 414, size.height, count: 3, height: 60 * u, seed: 8, color: dark)
        bubbles(&context, x: 60, y0: band.H * 0.4, y1: band.H, count: 5, seed: 5)
        let s: CGFloat = u * 0.75
        let fy: CGFloat = band.floor - 8
        Art.glow(&context, 210, fy - 170 * s, 220 * s, Art.color(0xC9E6A0), alpha: 0.16)
        Art.group(&context, x: 210, y: fy, scale: s) { g in
            Kit.shadow(&g, -10, 3, width: 190, alpha: 0.4)
            tsarDancing(&g)
        }
        let swimmers: [(CGFloat, CGFloat, CGFloat, Bool)] = [(92, 150, 20, true), (118, 60, -14, false), (344, 196, -24, true)]
        for place in swimmers {
            Art.group(&context, x: place.0, y: fy - place.1 * s, rotate: Kit.deg(place.2), scale: 0.62 * u) { g in
                fish(&g, gold: place.3)
            }
        }
        let stone: Kit.Stops = [(Art.color(0xE9EEF2), 0), (Art.color(0x9FC4B4), 0.6), (Art.color(0x5E9488), 1)]
        Art.group(&context, x: 326, y: fy + 2, scale: u * 0.5) { g in
            Kit.shadow(&g, 10, 2, width: 130, alpha: 0.35)
            let step: Path = Art.rect(-22, -34, 96, 34, radius: 3)
            Kit.solid(&g, step, stops: stone, light: 0.32, shade: 0.3, rim: 1.6)
            sadkoPlaying(&g, merchant: true, look: CGPoint(x: -0.6, y: -0.7))
        }
        ArtStyle.finish(&context, size, wash: 0.05, vignette: 0.16)
    }
}
