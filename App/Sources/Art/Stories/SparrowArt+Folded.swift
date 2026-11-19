import SwiftUI
import OmramoCore

// The four scenes of "The Tongue-Cut Sparrow" as the picture band of a folded phone: 432 units
// wide and about 240…520 high. Each is its own composition for that frame, not a crop of the
// wide scene: the subject's face in the middle 60% of the width, clear of the two top
// controls, above the wave edge that cuts the bottom 30 units; far, middle and near planes.
// Everything hangs on the band's horizon and scales with `band.unit`.

extension SparrowArt {
    // MARK: scene-cottage

    /// scene-cottage (folded): the porch close up — the old man sitting on its edge in the
    /// middle of the band, the Sparrow on the boards at his hand, the thick thatch above, the
    /// bamboo and the pale morning sky to the leading side.
    static func cottageFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let light = day()
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.sun(&context, 58, H - 36 * u, 20 * u, light: light)
        Kit.ranges(&context, width: size.width, horizon: H, scale: 0.8 * u, light: light, seed: 4)
        Kit.bamboo(&context, x: 4, baseY: H + 3, width: 110, height: 96 * u, count: 7, palette: farBamboo(), seed: 3)
        Kit.ground(&context, width: size.width, top: H, bottom: size.height, stops: meadow())
        let lawn = CGRect(x: 0, y: H + 6, width: size.width, height: band.ground)
        Kit.grass(&context, in: lawn, count: 44, seed: 5, color: Art.color(ramp.shade, 0.55), height: 7 * u)
        Kit.flowers(&context, in: lawn, count: 5, seed: 8, petal: 0xFFFFFF)

        // The man's feet are the anchor; everything near is drawn in his units.
        let ms: CGFloat = 1.2 * u
        let fy: CGFloat = min(band.floor - 6, H + 46 * u)
        Art.group(&context, x: 200, y: fy, scale: ms) { g in
            Kit.bamboo(&g, x: -136, baseY: -26, width: 130, height: 300, count: 6, palette: Kit.bambooGreens(), seed: 5)
            Art.group(&g, x: 126, y: 0, scale: 1.5) { h in
                minka(&h)
            }
            Kit.bowl(&g, cx: 46, baseY: -39, width: 26, color: 0x3F5E7A, filling: riceWhite)
            Art.group(&g, x: 88, y: 8, rotate: 0.1, scale: 1.1) { w in
                Kit.shadow(&w, 4, 0, width: 34, alpha: 0.22)
                firewood(&w)
            }
            Kit.shadow(&g, -18, 1, width: 56, alpha: 0.24)
            oldMan(&g, rig: manSitRig(), look: CGPoint(x: -0.7, y: 0.5), mouth: .smile, rice: true)
            ArtStyle.contactShadow(&g, -78, -38, 20, 3, alpha: 0.3)
            Art.group(&g, x: -80, y: -39, scale: 1.3, scaleX: -1) { s in
                sparrow(&s, pose: .perch, look: CGPoint(x: -0.5, y: -0.6), mirrored: true)
            }
        }
        Kit.grassTuft(&context, x: 26, baseY: size.height - 16, height: 44 * u, color: ramp.deep, seed: 2)
        ArtStyle.finish(&context, size)
    }

    // MARK: scene-bamboo

    /// scene-bamboo (folded): the old man in the middle among the bamboo stems, a hand to his
    /// mouth, calling; the clear stream low across the band with the white heron standing in
    /// it; pale sky on the leading side.
    static func bambooFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let light = day()
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.ranges(&context, width: size.width, horizon: H, scale: 0.8 * u, light: light, seed: 11)
        Kit.bamboo(&context, x: 236, baseY: H + 3, width: 200, height: H * 0.86, count: 9, palette: farBamboo(), seed: 14)
        Kit.bamboo(&context, x: 10, baseY: H + 3, width: 90, height: 50 * u, count: 5, palette: farBamboo(), seed: 15)
        ArtStyle.atmosphere(&context, width: size.width, top: 0, bottom: H + 8, color: light.haze, alpha: 0.16)
        Kit.ground(&context, width: size.width, top: H, bottom: size.height, stops: meadow())
        let bank: CGFloat = H + band.ground * 0.3
        let streamTop: CGFloat = H + band.ground * 0.42
        Kit.grass(&context, in: CGRect(x: 0, y: H + 4, width: size.width, height: band.ground * 0.3), count: 30, seed: 6, color: Art.color(ramp.shade, 0.6), height: 7 * u)
        stream(&context, width: size.width, top: streamTop, bottom: size.height + 6, light: light, seed: 41)

        // The grove behind him, its tops out of the frame.
        Kit.bamboo(&context, x: 150, baseY: bank - 4, width: 290, height: bank + 30, count: 8, palette: Kit.bambooGreens(), seed: 2)
        let ms: CGFloat = 1.15 * u
        Kit.shadow(&context, 230, bank + 1, width: 80 * ms, alpha: 0.26)
        Art.group(&context, x: 226, y: bank, scale: ms) { m in
            oldMan(&m, rig: manCallRig(), look: CGPoint(x: -0.8, y: -0.2), mouth: .open)
        }
        // The heron, low on the leading side, standing in the shallows.
        let wade: CGFloat = min(band.floor - 2, H + band.ground * 0.58)
        Art.group(&context, x: 92, y: wade, scale: 0.85 * u, scaleX: -1) { b in
            heron(&b, mirrored: true)
        }
        Kit.ripples(&context, 92, wade + 1, 36 * u, count: 2, color: Color.white, opacity: 0.7)
        Kit.reeds(&context, x: 20, baseY: streamTop + 8, count: 5, height: 34 * u, seed: 5, color: 0x4E9A5B)
        // Near canes on the trailing edge.
        Kit.bamboo(&context, x: 394, baseY: band.floor + 10, width: 46, height: size.height, count: 2, palette: hillGreens(), seed: 12)
        ArtStyle.finish(&context, size)
    }

    // MARK: scene-sparrow-house

    /// scene-sparrow-house (folded): the Sparrow in the middle of her porch, bowing with her
    /// wings a little open, the big wicker box on one side of her and the small one on the
    /// other; the pale wooden house behind, bamboo and sky above.
    static func sparrowHouseFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let light = day()
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.ranges(&context, width: size.width, horizon: H, scale: 0.8 * u, light: light, seed: 23)
        Kit.bamboo(&context, x: 0, baseY: H + 3, width: 432, height: H * 0.8, count: 14, palette: farBamboo(), seed: 18)
        ArtStyle.atmosphere(&context, width: size.width, top: 0, bottom: H + 8, color: light.haze, alpha: 0.18)
        Kit.ground(&context, width: size.width, top: H, bottom: size.height, stops: meadow())
        Kit.bamboo(&context, x: 6, baseY: H + 12, width: 96, height: H * 0.96, count: 4, palette: Kit.bambooGreens(), seed: 7)
        Kit.bamboo(&context, x: 336, baseY: H + 12, width: 92, height: H * 1.02, count: 4, palette: Kit.bambooGreens(), seed: 9)

        // The house, large, its porch deck across the band above the wave edge.
        let hs: CGFloat = 2.6 * u
        let fy: CGFloat = band.floor + 4
        let deckY: CGFloat = fy - 20 * hs
        Art.group(&context, x: 216, y: fy, scale: hs) { h in
            sparrowHouse(&h)
            // In this close view the sliding door is shut: a pale screen behind the Sparrow.
            let screen = Art.rect(-14, -59.5, 28, 43.5, radius: 1)
            Kit.solid(&h, screen, Art.color(0xF8ECD0), light: 0.2, shade: 0.1)
            let bars = Art.svg("M-14,-45 L14,-45 M-14,-31 L14,-31 M-5,-59 L-5,-16 M5,-59 L5,-16")
            Art.stroke(&h, bars, Art.color(0xD9B67E), width: 0.8, cap: .butt)
            Art.stroke(&h, screen, Art.color(0xC9A46E), width: 1.4)
        }
        let k: CGFloat = 1.25 * u
        tsuzura(&context, cx: 84, baseY: deckY, width: 92 * k, height: 90 * k)
        tsuzura(&context, cx: 356, baseY: deckY, width: 46 * k, height: 44 * k)
        // The Sparrow, bowing as politely as ever.
        let bs: CGFloat = 2.2 * u
        ArtStyle.contactShadow(&context, 230, deckY + 1, 24 * bs, 3.4 * bs, alpha: 0.28)
        Art.group(&context, x: 224, y: deckY, scale: bs) { s in
            sparrow(&s, pose: .peck, look: CGPoint(x: -0.3, y: 0.4), wings: true)
        }
        Kit.grassTuft(&context, x: 24, baseY: size.height - 14, height: 40 * u, color: ramp.deep, seed: 6)
        Kit.grassTuft(&context, x: 412, baseY: size.height - 14, height: 36 * u, color: ramp.deep, seed: 8)
        ArtStyle.finish(&context, size)
    }

    // MARK: scene-road

    /// scene-road (folded): the old woman in the middle, puffing, the very big wicker box
    /// rising behind her head; the pale earth road, a cloud pine on the trailing edge, two
    /// bees and the toad; the pale pink early-evening sky above.
    static func roadFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let light = evening()
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.sun(&context, 62, H - 22 * u, 18 * u, light: light)
        Kit.cloud(&context, 120, 96 * u + 30, scale: 0.6 * u, color: Art.color(0xFFF0F0, 0.7))
        Kit.ranges(&context, width: size.width, horizon: H, scale: 0.8 * u, light: light, seed: 31)
        Kit.farTrees(&context, x0: 250, x1: 432, baseY: H + 3, height: 22 * u, count: 7, color: Art.color(0x86A088), conifer: true, seed: 3)
        ArtStyle.atmosphere(&context, width: size.width, top: H - 90 * u, bottom: H + 8, color: light.haze, alpha: 0.22)
        let field: Kit.Stops = [(Art.color(0xC6D29C), 0), (Art.color(0xA6BC86), 0.4), (Art.color(0x86A277), 1)]
        Kit.ground(&context, width: size.width, top: H, bottom: size.height, stops: field)
        let verge = CGRect(x: 0, y: H + 6, width: size.width, height: band.ground)
        Kit.grass(&context, in: verge, count: 40, seed: 71, color: Art.color(0x5F8A66, 0.6), height: 7 * u)
        let earth: Kit.Stops = [(Art.color(0xF0DCC0), 0), (Art.color(0xE2C49A), 0.5), (Art.color(0xD2AE84), 1)]
        Kit.ribbon(&context, nearX: 170, nearY: size.height + 8, nearWidth: 230 * u, farX: 350, farY: H + 4, farWidth: 18 * u, stops: earth)

        Kit.cloudPine(&context, x: 396, baseY: H + 16 * u, height: 210 * u, palette: Kit.pineGreens(), seed: 4)
        let ws: CGFloat = 1.2 * u
        let fy: CGFloat = min(band.floor - 4, H + 40 * u)
        Kit.shadow(&context, 233 + 24 * ws, fy + 2, width: 150 * ws, alpha: 0.26)
        Art.group(&context, x: 233, y: fy, scale: ws) { w in
            oldWomanLoaded(&w, look: CGPoint(x: -0.6, y: 0.3), mouth: .oh)
            var puffs = Path()
            puffs.addPath(Art.ellipse(-64, -110, 6, 4.2))
            puffs.addPath(Art.ellipse(-76, -117, 4.2, 3))
            puffs.addPath(Art.ellipse(-85, -123, 2.8, 2))
            Art.fill(&w, puffs, Color.white.opacity(0.75))
            // Two bees about the lid.
            Art.group(&w, x: 92, y: -196, scale: 1.4) { b in
                Kit.critterBee(&b)
            }
            Art.group(&w, x: 118, y: -168, scale: 1.3, scaleX: -1) { b in
                Kit.critterBee(&b)
            }
        }
        // The toad by the roadside, low on the leading side.
        let ty: CGFloat = min(band.floor - 2, fy + 12 * u)
        Kit.shadow(&context, 112, ty, width: 44 * u, alpha: 0.24)
        Art.group(&context, x: 110, y: ty, scale: 1.4 * u) { f in
            Kit.critterFrog(&f, body: toadBrown)
        }
        ArtStyle.finish(&context, size)
    }
}
