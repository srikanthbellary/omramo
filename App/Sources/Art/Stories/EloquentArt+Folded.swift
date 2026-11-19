import SwiftUI
import OmramoCore

// The folded (phone) scenes of "The Eloquent Peasant": 432 wide, 240…520 high, each its own
// composition for the picture band at the top of a phone. Pale sky above; the subject low,
// its face inside x 86…346 and below y 110; everything important above `band.floor`.

extension EloquentArt {
    /// Figure scales in a folded band: an adult (`person`) and a donkey.
    static func foldedPerson(_ band: Kit.Band) -> CGFloat {
        band.unit * 0.86
    }

    static func foldedDonkey(_ band: Kit.Band) -> CGFloat {
        band.unit * 0.86 * 0.78
    }

    // MARK: The Salt Field

    static func oasisFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let light = morning()
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.sun(&context, 56, H - 44 * u, 10 * u, light: light)
        Kit.ranges(&context, width: size.width, horizon: H, scale: u, light: light, mountains: false, seed: 11)
        farPalm(&context, x: 120, baseY: H + 2, height: 34 * u, color: Art.color(0xA8B496), lean: -3)
        let sand: Kit.Stops = Kit.stops(0xEFE2C2, sandHex, sandDeepHex)
        Kit.ground(&context, width: size.width, top: H, bottom: size.height, stops: sand, seed: 41)
        saltLake(&context, x0: -80, x1: 300, top: H + 3 * u, depth: 28 * u, seed: 5)
        let p: CGFloat = foldedPerson(band)
        let d: CGFloat = foldedDonkey(band)
        Kit.palm(&context, x: 336, baseY: H + 16 * u, height: 128 * u, lean: -16 * u, fronds: palmHex, trunk: palmTrunkHex, seed: 7)
        mudHouse(&context, cx: 382, baseY: H + 28 * u, width: 96 * u, height: 66 * u)
        Art.group(&context, x: 370, y: H + 32 * u, scale: p * 0.86) { g in
            wife(&g, mouth: .flat, look: CGPoint(x: -0.7, y: 0))
        }
        Kit.pot(&context, cx: 318, baseY: H + 32 * u, width: 18 * u, height: 24 * u, color: 0xB5683A)
        Art.group(&context, x: 150, y: H + 34 * u, scale: d) { g in
            donkey(&g, pack: 1, mood: .sleepy)
        }
        Art.group(&context, x: 220, y: H + 38 * u, scale: p) { g in
            khunanup(&g, pose: .reach, mouth: .flat, look: CGPoint(x: -0.6, y: 0.3), stick: false)
        }
        Kit.reeds(&context, x: 14, baseY: size.height + 4, count: 6, height: 74 * u, seed: 9, color: 0x5E7E44)
        Kit.grassTuft(&context, x: 420, baseY: size.height, height: 40 * u, color: 0x7A8E4E, seed: 4)
        ArtStyle.finish(&context, size, wash: 0.08, vignette: 0.06)
    }

    // MARK: The path and the cloth

    static func pathFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let w: CGFloat = size.width
        let light = goldMorning()
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.sun(&context, 50, H - 46 * u, 9 * u, light: light)
        Kit.ranges(&context, width: w, horizon: H, scale: u * 0.8, light: light, mountains: false, seed: 23)
        let farTone: Color = Art.color(0x9DAA7A, 0.85)
        let palms: [(CGFloat, CGFloat)] = [(30, 30), (96, 24), (170, 34), (236, 26)]
        for palm in palms {
            farPalm(&context, x: palm.0, baseY: H + 2, height: palm.1 * u, color: farTone, lean: 2)
        }
        let fields: Kit.Stops = Kit.stops(0xC2CB92, 0xA3B670, 0x86A259)
        Kit.ground(&context, width: w, top: H, bottom: size.height, stops: fields, seed: 43)
        // Canal, then the raised path.
        let canal = Art.rect(0, H + 5 * u, w, 11 * u)
        Art.fillLinear(&context, canal, Kit.stops(0xB8D0D6, nileHex), from: CGPoint(x: 0, y: H + 5 * u), to: CGPoint(x: 0, y: H + 16 * u))
        Kit.rippleMarks(&context, x0: 0, x1: w, y0: H + 7 * u, y1: H + 15 * u, count: 12, seed: 9, color: Color.white, alpha: 0.5)
        let path = Art.rect(0, H + 16 * u, w, 26 * u)
        Art.fillLinear(&context, path, Kit.stops(0xE6D3A6, 0xD6BE8C), from: CGPoint(x: 0, y: H + 16 * u), to: CGPoint(x: 0, y: H + 42 * u))
        Art.fill(&context, Art.rect(0, H + 42 * u, w, 6 * u), Art.color(0xB49464))
        // The estate behind its wall.
        Kit.palm(&context, x: 300, baseY: H + 8 * u, height: 112 * u, lean: -12 * u, fronds: palmHex, trunk: palmTrunkHex, seed: 11)
        Kit.house(&context, cx: 384, baseY: H + 10 * u, width: 100 * u, wallHeight: 52 * u, roofHeight: 6 * u, wall: 0xF6F0E2, roof: 0xC8B48C, style: .flat, door: 0x6A4A32, windows: 1)
        Kit.longWall(&context, x0: 282, x1: 460, baseY: H + 18 * u, height: 26 * u, color: 0xEFE6D2)
        let p: CGFloat = foldedPerson(band)
        let d: CGFloat = foldedDonkey(band)
        fringedCloth(&context, x0: 158, x1: 226, y: H + 18 * u, depth: 22 * u, skew: 6 * u)
        Art.group(&context, x: 84, y: H + 38 * u, scale: d, scaleX: -1) { g in
            donkey(&g, pack: 1, mood: .surprised, mirrored: true)
        }
        Art.group(&context, x: 268, y: H + 36 * u, scale: p) { g in
            nemtynakht(&g, mouth: .smile, look: CGPoint(x: -0.6, y: 0.2))
        }
        Kit.grainField(&context, x0: -10, x1: w + 10, baseY: H + 84 * u, height: 36 * u, color: barleyHex, seed: 3)
        Kit.grainField(&context, x0: -10, x1: w + 10, baseY: size.height + 6, height: 34 * u, color: 0x5F8442, seed: 9)
        ArtStyle.finish(&context, size, wash: 0.08, vignette: 0.06)
    }

    // MARK: The courtyard: the peasant speaks, the scribe writes

    static func hallFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let w: CGFloat = size.width
        let light = courtyard()
        Kit.sky(&context, size, horizon: H, light: light)
        // The pale wall with its coping and painted dado.
        let wallTop: CGFloat = H - 92 * u
        Kit.wall(&context, rect: CGRect(x: -10, y: wallTop, width: w + 20, height: H - wallTop + 2), color: plasterHex)
        Kit.solid(&context, Art.rect(-10, wallTop - 6 * u, w + 20, 7 * u, radius: 3), Art.color(plasterShadeHex), light: 0.24, shade: 0.2)
        let dado: [(UInt32, CGFloat)] = [(0xC8553D, 24), (0x2F6F9E, 19), (0x3FA27A, 14)]
        for stripe in dado {
            Art.fill(&context, Art.rect(-10, H - stripe.1 * u, w + 20, 3 * u), Art.color(stripe.0, 0.5))
        }
        Kit.gateway(&context, cx: 40, baseY: H + 2, width: 54 * u, height: 76 * u, color: 0xE6D8BE)
        let floor: Kit.Stops = Kit.stops(0xEFE3CB, 0xE2D1B0, 0xD2BC96)
        Kit.ground(&context, width: w, top: H, bottom: size.height, stops: floor, seed: 47)
        budColumn(&context, cx: 404, baseY: H + 8 * u, width: 26 * u, height: 210 * u, color: 0xEDE1C8, paint: 0.5)
        let p: CGFloat = foldedPerson(band)
        reedMat(&context, cx: 276, y: H + 38 * u, width: 96 * u)
        Art.group(&context, x: 272, y: H + 38 * u, scale: p) { g in
            scribe(&g)
        }
        Art.group(&context, x: 150, y: H + 34 * u, scale: p, scaleX: -1) { g in
            khunanup(&g, pose: .wave, mouth: .open, look: CGPoint(x: -0.4, y: -0.1), mirrored: true)
        }
        papyrusRun(&context, x0: 40, x1: 258, y: H + 44 * u, depth: 6 * u)
        Kit.pot(&context, cx: 8, baseY: size.height + 14, width: 46 * u, height: 70 * u, color: 0xB06A3C, band: 0x2F6F9E)
        ArtStyle.finish(&context, size, wash: 0.08, vignette: 0.06)
    }

    // MARK: The landing: Rensi's boat at the steps

    static func riverFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let w: CGFloat = size.width
        let light = afternoon()
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.sun(&context, 60, H - 40 * u, 10 * u, light: light)
        var cliffs = Path()
        cliffs.move(to: CGPoint(x: 0, y: H + 2))
        cliffs.addLine(to: CGPoint(x: 0, y: H - 22 * u))
        cliffs.addLine(to: CGPoint(x: w * 0.5, y: H - 26 * u))
        cliffs.addQuadCurve(to: CGPoint(x: w * 0.62, y: H - 16 * u), control: CGPoint(x: w * 0.58, y: H - 26 * u))
        cliffs.addLine(to: CGPoint(x: w, y: H - 20 * u))
        cliffs.addLine(to: CGPoint(x: w, y: H + 2))
        cliffs.closeSubpath()
        Art.fill(&context, cliffs, light.far)
        ArtStyle.atmosphere(&context, width: w, top: H - 40 * u, bottom: H + 2, color: light.haze, alpha: 0.4)
        Art.fill(&context, Art.rect(0, H - 6 * u, w, 7 * u), light.mid)
        let palmTone: Color = Art.color(0x8E9E6E)
        let palms: [(CGFloat, CGFloat)] = [(40, 22), (120, 28), (210, 20), (300, 26), (390, 22)]
        for palm in palms {
            farPalm(&context, x: palm.0, baseY: H - 3 * u, height: palm.1 * u, color: palmTone, lean: 2)
        }
        let water: Kit.Stops = Kit.stops(0xD8DCD8, 0xA9C4CA, 0x80A6B4)
        Kit.water(&context, width: w, top: H, bottom: size.height, stops: water, light: light, ripples: 24, seed: 33)
        Kit.glints(&context, x: 60, top: H, depth: band.ground * 0.7, color: Art.color(0xFFF2DA), count: 18, seed: 8)
        let p: CGFloat = foldedPerson(band)
        landing(&context, x0: 304, x1: 470, top: H + 14 * u, waterY: H + 40 * u, bottom: size.height + 10)
        Art.group(&context, x: 330, y: H + 14 * u, scale: p * 0.9) { g in official(&g, variant: 1) }
        Art.group(&context, x: 380, y: H + 14 * u, scale: p * 0.9) { g in rensi(&g, seated: false, look: CGPoint(x: -0.5, y: 0)) }
        stewardBoat(&context, cx: 176, waterY: H + 46 * u, length: 214 * u)
        Kit.ripples(&context, 176, H + 50 * u, 170 * u, count: 2)
        Kit.reeds(&context, x: 10, baseY: size.height + 6, count: 6, height: 80 * u, seed: 12, color: 0x4E7A44, papyrus: true)
        ArtStyle.finish(&context, size, wash: 0.08, vignette: 0.06)
    }
}
