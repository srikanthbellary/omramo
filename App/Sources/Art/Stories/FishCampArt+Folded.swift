import SwiftUI
import OmramoCore

// The four scenes of "The Long Day at Fish Camp" as the picture band of a folded phone: 432
// wide, about 240…520 high. Each is its own close composition, not a crop: the subject's face
// in the middle (x 86…346, below the two top controls), the pale sky kept at the top, the far
// shore and the river behind, a near plane of grass or sedge at the bottom corners.

extension FishCampArt {
    /// The far plane every folded scene shares: sky, thin clouds, far shore and river.
    static func foldedSky(_ context: inout GraphicsContext, _ band: Kit.Band, light: Kit.Light, seed: UInt32) {
        Kit.sky(&context, band.size, horizon: band.H, light: light)
        cloudStreaks(&context, width: 432, horizon: band.H, color: Color.white)
        farShore(&context, width: 432, horizon: band.H, scale: band.unit * 0.8, light: light, seed: seed)
        Kit.water(&context, width: 432, top: band.H, bottom: band.h, stops: riverStops(), light: light, ripples: 30, seed: seed &+ 3)
    }

    /// The near bank in a band: grass from just under the horizon to the bottom, with its lit lip.
    static func foldedBank(_ context: inout GraphicsContext, _ band: Kit.Band, top: CGFloat, seed: UInt32) {
        Kit.ground(&context, width: 432, top: top, bottom: band.h, stops: grassStops(), seed: seed)
        Art.stroke(&context, Art.line(0, top, 432, top), Art.color(0xD4E0A0, 0.7), width: 1.4)
        let far = CGRect(x: 0, y: top + 2, width: 432, height: max(10, band.h - top - 2))
        Kit.grass(&context, in: far, count: 70, seed: seed &+ 1, color: Art.color(0x5F7F4A, 0.7), height: 9 * band.unit)
    }
}

// MARK: - scene-camp (folded): Grandma at the cutting table

extension FishCampArt {
    static func campFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let light = evening()
        foldedSky(&context, band, light: light, seed: 51)
        Art.glow(&context, 0, band.H - 20 * u, 160 * u, light.glow, alpha: 0.4)
        let shore: CGFloat = band.H + 12 * u
        foldedBank(&context, band, top: shore, seed: 52)
        Art.group(&context, x: 40, y: shore + 2, scale: 0.55 * u) { g in
            cabin(&g, width: 84, height: 46, rise: 14, wall: plywood, roof: 0x4E5258, boards: false, door: true, pipe: true)
        }
        Art.group(&context, x: 300, y: shore + 4 * u, scale: 1.1 * u) { g in
            rack(&g, width: 260, height: 90, rows: 2, tarp: true, seed: 7)
        }
        campFoldedFront(&context, band)
        Kit.grassTuft(&context, x: 14, baseY: band.h + 6, height: 60 * u, color: 0x4F6A44, seed: 3)
        fireweed(&context, x: 418, baseY: band.h + 4, height: 150 * u, seed: 9)
        Kit.grassTuft(&context, x: 404, baseY: band.h + 8, height: 54 * u, color: 0x4A6440, seed: 4)
        ArtStyle.finish(&context, size)
    }

    /// Grandma close up, the uluaq in her fist over an open side of salmon on the planks.
    static func campFoldedFront(_ context: inout GraphicsContext, _ band: Kit.Band) {
        let u: CGFloat = band.unit
        let s: CGFloat = 1.2 * u
        let gx: CGFloat = 236
        let gy: CGFloat = band.floor + 14 * u
        Art.group(&context, x: 92, y: gy - 10 * u, scale: 1.3 * u) { g in
            gull(&g)
        }
        Art.group(&context, x: gx, y: gy, scale: s) { g in
            Kit.shadow(&g, -70, 0, width: 130, alpha: 0.2)
            Art.group(&g, x: -76, y: 0) { t in
                cuttingTable(&t, width: 112, height: 56)
            }
            Art.group(&g, x: -62, y: -60, scale: 1.2) { f in
                fillet(&f)
            }
            Kit.shadow(&g, 2, 0, width: 70)
            Art.group(&g, x: 34, y: 0, scale: 1.3) { b in
                bucket(&b, strips: true)
            }
            grandma(&g, act: .cut, look: CGPoint(x: -0.3, y: 0.4), mouth: .smile)
        }
    }
}

// MARK: - scene-net (folded): the salmon comes over the side

extension FishCampArt {
    static func netFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.32, least: 80, most: 170)
        let u: CGFloat = band.unit
        let light = evening()
        foldedSky(&context, band, light: light, seed: 61)
        Art.glow(&context, 20, band.H - 16 * u, 150 * u, light.glow, alpha: 0.36)
        Kit.glints(&context, x: 90, top: band.H, depth: band.ground, color: Art.color(0xFFF6E0), count: 24, seed: 62)
        let s: CGFloat = 1.3 * min(1, u)
        let water: CGFloat = band.H + 34 * u
        Art.group(&context, x: 232, y: water, scale: s) { g in
            netFoldedBoat(&g)
        }
        Kit.ripples(&context, 232, water + 6 * s, 270 * s, count: 2, color: Color.white, opacity: 0.45)
        if band.h > 360 {
            Kit.swells(&context, width: 432, top: water + 30 * s, bottom: band.h, rows: 3, crest: Art.color(0xE9DCC0), seed: 64)
        }
        Kit.reeds(&context, x: 414, baseY: band.h + 8, count: 5, height: 70 * u, seed: 63, color: 0x55744A)
        Kit.reeds(&context, x: 16, baseY: band.h + 10, count: 3, height: 44 * u, seed: 65, color: 0x4F6A44)
        ArtStyle.finish(&context, size)
    }

    /// The skiff, Uncle Joe and Nick hauling, the net and the salmon, in the skiff's own units
    /// (origin at the middle of the waterline, as `skiff`).
    static func netFoldedBoat(_ g: inout GraphicsContext) {
        Art.fill(&g, Art.ellipse(0, 9, 140, 7), ArtStyle.coolShade.opacity(0.16))
        Art.group(&g, x: 93, y: -6.4, scale: 0.59) { b in
            uncle(&b)
        }
        Art.group(&g, x: -28, y: -4.8, scale: 0.8) { b in
            nick(&b, act: .haul, look: CGPoint(x: -0.4, y: 0.7), mouth: .open, vest: true)
        }
        skiff(&g, motor: true)
        let fist = nickHand(.haul)
        let hx: CGFloat = -28 + fist.x * 0.8
        let hy: CGFloat = -4.8 + fist.y * 0.8
        var web = Path()
        let drops: [CGFloat] = [-89.6, -81.6, -73.6, -65.6, -57.6]
        for x in drops {
            web.move(to: CGPoint(x: hx, y: hy))
            web.addLine(to: CGPoint(x: x, y: -26.4))
            web.addLine(to: CGPoint(x: x - 11.2, y: 4.8))
        }
        web.addPath(Art.line(-84, -17.6, -54.4, -20.8))
        web.addPath(Art.line(-94.4, -6.4, -62.4, -9.6))
        Art.stroke(&g, web, Art.color(0xEDF2E2, 0.8), width: 0.8)
        let floats: [CGPoint] = [
            CGPoint(x: -99, y: 7), CGPoint(x: -133, y: 12), CGPoint(x: -170, y: 15), CGPoint(x: -208, y: 16),
            CGPoint(x: -245, y: 14), CGPoint(x: -280, y: 10), CGPoint(x: -312, y: 5),
        ]
        var rope = Path()
        rope.move(to: CGPoint(x: hx, y: hy))
        rope.addQuadCurve(to: CGPoint(x: -99, y: 7), control: CGPoint(x: -88, y: -35))
        rope.addPath(Art.polygon(floats, closed: false))
        Art.stroke(&g, rope, Art.color(0xE9E0C8), width: 1.4)
        for point in floats {
            Kit.ripples(&g, point.x, point.y + 2.4, 14, count: 1, color: Color.white, opacity: 0.4)
            Kit.solid(&g, Art.ellipse(point.x, point.y, 6, 3.5), Art.color(0xFBF8F0), light: 0.1, shade: 0.24)
        }
        Kit.ripples(&g, -88, 9.6, 35, count: 2, color: Color.white, opacity: 0.7)
        Art.group(&g, x: -72, y: -17.6, rotate: Kit.deg(-60), scale: 0.64, scaleX: -1) { f in
            salmon(&f)
        }
        let spray: [(CGFloat, CGFloat, CGFloat)] = [(-99, -3, 1.6), (-93, -11, 1.2), (-78, 6, 1.4), (-104, 5, 1.1), (-69, -2, 1), (-85, -19, 1)]
        var beads = Path()
        for bead in spray {
            beads.addPath(Art.circle(bead.0, bead.1, bead.2))
        }
        Art.fill(&g, beads, Color.white.opacity(0.85))
        Art.fill(&g, Art.circle(hx, hy, 3.4), Art.color(nickLook().skin))
    }
}

// MARK: - scene-bank (folded): Nick with the bundle, waist up

extension FishCampArt {
    static func bankFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let light = peach()
        foldedSky(&context, band, light: light, seed: 71)
        Kit.sun(&context, 26, band.H - 22 * u, 11 * u, light: light)
        Kit.glints(&context, x: 40, top: band.H, depth: 12 * u, color: Art.color(0xFFF1DC), count: 10, seed: 72)
        let shore: CGFloat = band.H + 10 * u
        foldedBank(&context, band, top: shore, seed: 73)
        Kit.bush(&context, x: 336, baseY: shore + 6 * u, width: 120 * u, palette: willowGreens(), seed: 74)
        Kit.bush(&context, x: 74, baseY: shore + 4 * u, width: 90 * u, palette: willowGreens(), seed: 75)
        let back: [(CGFloat, CGFloat, UInt32)] = [(112, 120, 76), (138, 96, 77), (300, 110, 78), (326, 130, 79)]
        for stem in back {
            fireweed(&context, x: stem.0, baseY: shore + 30 * u, height: stem.1 * u, seed: stem.2)
        }
        let tall = CGRect(x: 0, y: shore + 16 * u, width: 432, height: max(10, band.h - shore - 16 * u))
        Kit.grass(&context, in: tall, count: 90, seed: 80, color: Art.color(0x587848, 0.8), height: 18 * u)
        // Nick from the waist up: his hips sit on the wave edge.
        let s: CGFloat = 3 * u
        let feet: CGFloat = band.floor + 5 + 40.6 * s
        Art.group(&context, x: 216, y: feet, scale: s) { g in
            nick(&g, act: .hug, look: CGPoint(x: -0.2, y: 0.6), mouth: .flat)
        }
        let headY: CGFloat = feet - 101 * s
        mosquitoes(&context, cx: 224, cy: headY - 30 * s, scale: 0.6 * s)
        bankFoldedNear(&context, band)
        ArtStyle.finish(&context, size)
    }

    /// Tall fireweed and dark grass on both sides of Nick.
    static func bankFoldedNear(_ context: inout GraphicsContext, _ band: Kit.Band) {
        let u: CGFloat = band.unit
        let h: CGFloat = band.h
        fireweed(&context, x: 36, baseY: h + 4, height: 170 * u, seed: 81)
        fireweed(&context, x: 74, baseY: h + 8, height: 128 * u, seed: 82)
        fireweed(&context, x: 372, baseY: h + 4, height: 150 * u, seed: 83)
        fireweed(&context, x: 406, baseY: h + 6, height: 190 * u, seed: 84)
        Kit.grassTuft(&context, x: 20, baseY: h + 10, height: 70 * u, color: 0x4A6440, seed: 85)
        Kit.grassTuft(&context, x: 414, baseY: h + 10, height: 76 * u, color: 0x4A6440, seed: 86)
        Kit.grassTuft(&context, x: 352, baseY: h + 12, height: 50 * u, color: 0x4F6A44, seed: 87)
    }
}

// MARK: - scene-porch (folded): Lena on her step

extension FishCampArt {
    static func porchFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let light = peach()
        foldedSky(&context, band, light: light, seed: 81)
        Art.glow(&context, 10, band.H - 16 * u, 150 * u, light.glow, alpha: 0.36)
        Kit.glints(&context, x: 70, top: band.H, depth: 12 * u, color: Art.color(0xFFF1DC), count: 10, seed: 82)
        let shore: CGFloat = band.H + 12 * u
        foldedBank(&context, band, top: shore, seed: 83)
        let s: CGFloat = 1.6 * u
        Art.group(&context, x: 212, y: band.floor + 6 * u, scale: s) { g in
            porchFoldedSet(&g)
        }
        Kit.grassTuft(&context, x: 16, baseY: band.h + 8, height: 56 * u, color: 0x4A6440, seed: 88)
        Kit.grassTuft(&context, x: 410, baseY: band.h + 10, height: 66 * u, color: 0x4A6440, seed: 89)
        fireweed(&context, x: 422, baseY: band.h + 4, height: 130 * u, seed: 90)
        ArtStyle.finish(&context, size)
    }

    /// Lena's cabin, step, kettle and table, in Lena's own units (origin on the ground under
    /// her seat; the step is 34 high).
    static func porchFoldedSet(_ g: inout GraphicsContext) {
        Art.group(&g, x: 70, y: -16) { c in
            cabin(&c, width: 260, height: 125, rise: 22, wall: greyBoard, roof: 0x7C776E, boards: true, door: true, pipe: true)
        }
        smoke(&g, x: 133, y: -190, scale: 0.8)
        let board = Art.color(0xB3AC9C)
        let riser = Art.color(0x7E7A70)
        Art.fill(&g, Art.rect(-50, -26, 120, 26), riser)
        Kit.solid(&g, Art.rect(-56, -34, 132, 9, radius: 1.5), board, light: 0.24, shade: 0.16)
        Art.stroke(&g, Art.line(-56, -33.4, 76, -33.4), Art.color(0xF3E9D2, 0.5), width: 1)
        Kit.shadow(&g, 10, 0, width: 140, alpha: 0.2)
        Art.group(&g, x: 52, y: -34) { k in
            kettle(&k)
        }
        Art.group(&g, x: -150, y: 0) { t in
            cuttingTable(&t, width: 100, height: 52)
        }
        Art.group(&g, x: -140, y: -74, scale: 0.7) { k in
            uluaq(&k)
        }
        Kit.shadow(&g, -4, -34, width: 60, alpha: 0.16)
        lena(&g, look: CGPoint(x: -0.2, y: 0.2), mouth: .smile)
    }
}
