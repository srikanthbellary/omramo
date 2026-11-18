import SwiftUI
import OmramoCore

// The four scenes of "The Old Man Who Moved the Mountains" as the picture band of a folded
// phone: 432 units wide and about 240…520 high. Each is its own composition, not a crop of the
// wide scene: the faces stand inside the middle 60% of the width (x 86…346), below the two top
// controls and above the wave edge; everything hangs on the band's horizon and the people
// scale with the band's height (`band.unit`).

extension MountainsArt {
    /// Where the people of a folded scene stand: just above the wave edge on a squat band,
    /// a little over half-way down the ground on a tall one.
    static func foldedFeet(_ band: Kit.Band) -> CGFloat {
        min(band.floor - 2, band.H + band.ground * 0.56)
    }

    // MARK: scene-mountains

    /// scene-mountains (folded): Yu Gong outside his door in the middle of the band, seen
    /// from the side, his head tipped back; Taihang and Wangwu rise behind the thatched roof.
    static func mountainsFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        let h = size.height
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let light = day()

        Kit.sky(&context, size, horizon: H, light: light)
        Kit.sun(&context, 58, H - 40 * u, 20 * u, light: light)
        farRanges(&context, width: w, horizon: H, scale: 0.7 * u, light: light)
        let peakH: CGFloat = H * 0.86
        let peakW: CGFloat = min(peakH * 1.25, 250)
        twoMountains(
            &context, width: w, baseY: H + 3, height: peakH,
            taihangX: 150, wangwuX: 296, peakWidth: peakW, light: light
        )

        Kit.ground(&context, width: w, top: H, bottom: h, stops: loess())
        Kit.grainField(&context, x0: 0, x1: 170, baseY: H + 12 * u, height: 8 * u, color: milletGreen, seed: 3)
        Kit.ribbon(
            &context, nearX: 96, nearY: h, nearWidth: 70 * u,
            farX: 30, farY: H + 6, farWidth: 4, stops: pathStops()
        )

        // The yard: the peach tree, a piece of the earth wall, the house.
        let yardY: CGFloat = H + band.ground * 0.36
        peachTree(&context, x: 84, baseY: yardY - 2 * u, height: 96 * u, seed: 7)
        yardWall(&context, x0: 14, x1: 122, baseY: yardY + 6 * u, height: 15 * u)
        farmhouse(&context, x: 318, baseY: yardY, scale: 0.62 * u)
        Kit.grassTuft(&context, x: 128, baseY: yardY + 8 * u, height: 14 * u, color: 0x93AC64, seed: 5)

        // Yu Gong.
        let feet: CGFloat = foldedFeet(band)
        let k: CGFloat = 0.92 * u
        basketsSetDown(&context, x: 130, baseY: feet + 2, scale: 0.5 * u)
        Kit.shadow(&context, 222, feet, width: 60 * k)
        Art.group(&context, x: 222, y: feet, scale: k) { p in
            yuGong(&p, pose: .stand, look: CGPoint(x: -0.6, y: -0.9), mouth: .smile, nod: 0.3)
        }

        // Near plane.
        Kit.grassTuft(&context, x: 18, baseY: h - 18, height: 40 * u, color: 0x6F8E58, seed: 3)
        Kit.grassTuft(&context, x: 414, baseY: h - 16, height: 34 * u, color: 0x6F8E58, seed: 9)
        ArtStyle.finish(&context, size)
    }

    // MARK: scene-digging

    /// scene-digging (folded): Yu Gong in the middle with the pole across his shoulders, the
    /// little boy beside him looking up, a basket his own size in his arms; the diggers small
    /// behind, at the pale foot of the mountain.
    static func diggingFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        let h = size.height
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let light = day()

        Kit.sky(&context, size, horizon: H, light: light)
        Kit.sun(&context, 54, H - 36 * u, 18 * u, light: light)
        farRanges(&context, width: 210, horizon: H, scale: 0.7 * u, light: light)
        greatPeak(&context, cx: 300, baseY: H + 3, width: 540, height: H * 1.25, color: peakBack, seed: 5, pines: true)
        mountainAir(&context, width: w, baseY: H + 3, height: H, light: light)
        Kit.ground(&context, width: w, top: H, bottom: h, stops: loess())

        let feet: CGFloat = foldedFeet(band)
        // The path.
        var path = Path()
        path.move(to: CGPoint(x: -10, y: feet - 22 * u))
        path.addQuadCurve(to: CGPoint(x: 442, y: feet - 14 * u), control: CGPoint(x: 216, y: feet - 30 * u))
        path.addLine(to: CGPoint(x: 442, y: feet + 18 * u))
        path.addQuadCurve(to: CGPoint(x: -10, y: feet + 12 * u), control: CGPoint(x: 216, y: feet + 4 * u))
        path.closeSubpath()
        Art.fillLinear(&context, path, pathStops(), from: CGPoint(x: 0, y: feet - 30 * u), to: CGPoint(x: 0, y: feet + 18 * u))

        // The diggers, small behind.
        let digY: CGFloat = H + band.ground * 0.2
        let s: CGFloat = 0.36 * u
        Kit.rock(&context, cx: 424, baseY: digY, width: 64 * u, height: 38 * u, color: 0xA9B6B8, seed: 2)
        Kit.shadow(&context, 376, digY + 2, width: 44 * s)
        Art.group(&context, x: 376, y: digY + 2, scale: s, scaleX: -1) { p in
            digger(&p, grownLook(0), mirrored: true)
        }
        Kit.shadow(&context, 62, digY + 6, width: 34 * s)
        Art.group(&context, x: 62, y: digY + 6, scale: s, scaleX: -1) { p in
            kin(&p, grandchildLook(0), pose: .kneel, look: CGPoint(x: -0.4, y: 0.7), mouth: .grin, mirrored: true)
        }
        Kit.basket(&context, cx: 62 + 38 * s, baseY: digY + 8, width: 24 * s, height: 17 * s, color: wicker)

        // Yu Gong and the little boy.
        let k: CGFloat = 0.95 * u
        let boyX: CGFloat = 176 + 127 * u
        Kit.shadow(&context, 176, feet, width: 70 * k)
        Art.group(&context, x: 176, y: feet, scale: k) { p in
            yuGongCarrying(&p, walking: true, look: CGPoint(x: -0.2, y: 0), mouth: .smile)
        }
        Kit.shadow(&context, boyX, feet + 2 * u, width: 44 * k)
        Art.group(&context, x: boyX, y: feet + 2 * u, scale: k) { p in
            boy(&p, pose: .carry, look: CGPoint(x: -0.7, y: -0.7), mouth: .grin, basket: true)
        }

        Kit.grassTuft(&context, x: 16, baseY: h - 18, height: 38 * u, color: 0x6F8E58, seed: 4)
        ArtStyle.finish(&context, size)
    }

    // MARK: scene-river-bend

    /// scene-river-bend (folded): Zhi Sou laughing on his stool under the willow on the left,
    /// Yu Gong calm on the right, both faces in the middle of the band; the river bends
    /// behind them.
    static func riverBendFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        let h = size.height
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let light = day()

        Kit.sky(&context, size, horizon: H, light: light)
        // The sun is out of frame on the left here: it would sit between the two faces.
        greatPeak(&context, cx: 372, baseY: H, width: 84 * u, height: 58 * u, color: peakBack, seed: 9, pines: false)
        greatPeak(&context, cx: 322, baseY: H, width: 96 * u, height: 70 * u, color: peakFront, seed: 3, pines: false)
        mountainAir(&context, width: w, baseY: H, height: 70 * u, light: light)
        Kit.ranges(&context, width: w, horizon: H, scale: 0.6 * u, light: light, mountains: false, seed: 7)

        Kit.water(&context, width: w, top: H, bottom: h, stops: silt(), light: light, ripples: 20, seed: 31)
        riverSandbar(&context, x: 330, y: H + 9 * u, width: 80 * u, reeds: 4)

        // The bank the river bends round.
        let yb: CGFloat = H + band.ground * 0.3
        var bank = Path()
        bank.move(to: CGPoint(x: -10, y: yb + 12 * u))
        bank.addQuadCurve(to: CGPoint(x: 442, y: yb - 2 * u), control: CGPoint(x: 190, y: yb - 18 * u))
        bank.addLine(to: CGPoint(x: 442, y: h + 10))
        bank.addLine(to: CGPoint(x: -10, y: h + 10))
        bank.closeSubpath()
        Art.fill(&context, bank.applying(CGAffineTransform(translationX: 0, y: -4 * u)), Art.color(0xF3E6B8))
        Art.fillLinear(&context, bank, loess(), from: CGPoint(x: 0, y: yb - 10 * u), to: CGPoint(x: 0, y: h))
        Kit.reeds(&context, x: 236, baseY: yb - 2 * u, count: 6, height: 34 * u, seed: 5, color: 0x7FA066)
        Kit.reeds(&context, x: 404, baseY: yb + 2 * u, count: 5, height: 28 * u, seed: 8, color: 0x6F9460)

        let feet: CGFloat = foldedFeet(band)
        let treeY: CGFloat = yb + 10 * u
        let treeH: CGFloat = min(treeY - 24, 330 * u)
        willow(&context, x: 44, baseY: treeY, height: treeH, seed: 4)

        let k: CGFloat = 0.95 * u
        // Zhi Sou (he faces right, toward Yu Gong).
        Art.group(&context, x: 146, y: feet, scale: k, scaleX: -1) { p in
            zhiSouSeated(&p, laughing: true, mirrored: true)
        }
        // Yu Gong, calm.
        Kit.shadow(&context, 288, feet + 2 * u, width: 60 * k)
        Art.group(&context, x: 288, y: feet + 2 * u, scale: k) { p in
            yuGongResting(&p, look: CGPoint(x: -0.6, y: 0))
        }
        basketsSetDown(&context, x: 374, baseY: feet + 4 * u, scale: 0.52 * u)

        Kit.reeds(&context, x: 416, baseY: h - 12, count: 6, height: 52 * u, seed: 41, color: 0x55784E)
        ArtStyle.finish(&context, size)
    }

    // MARK: scene-open-road

    /// scene-open-road (folded): Yu Gong with his hoe and the little boy, hopping, either
    /// side of the gate; between them the pale road runs dead straight across the golden
    /// plain to an empty horizon.
    static func openRoadFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        let h = size.height
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let light = goldenMorning()

        Kit.sky(&context, size, horizon: H, light: light)
        Kit.sun(&context, 92, H - 46 * u, 24 * u, light: light)
        Kit.cloud(&context, 300, H * 0.5, scale: 0.6 * u, color: Art.color(0xFFFFFF, 0.65))
        let low = Kit.ridge(width: w, y: H - 4 * u, amp: 4 * u, seed: 3, bottom: H + 4)
        Art.fill(&context, low, light.far.opacity(0.8))
        Kit.farTrees(&context, x0: 10, x1: 190, baseY: H + 2, height: 9 * u, count: 4, color: Art.color(0xC9C89A), seed: 4)
        Kit.farTrees(&context, x0: 250, x1: 425, baseY: H + 2, height: 9 * u, count: 4, color: Art.color(0xC9C89A), seed: 9)

        Kit.ground(&context, width: w, top: H, bottom: h, stops: goldPlain())
        Kit.grainField(&context, x0: 0, x1: w, baseY: H + 9 * u, height: 6 * u, color: milletGold, seed: 2)
        Kit.grainField(&context, x0: 0, x1: w, baseY: H + band.ground * 0.3, height: 12 * u, color: 0xE8BE4E, seed: 6)

        // The road.
        let reach: CGFloat = 150 * u
        let road: [CGPoint] = [
            Kit.pt(214, H + 2), Kit.pt(218, H + 2), Kit.pt(216 + reach, h + 10), Kit.pt(216 - reach, h + 10),
        ]
        Art.fillLinear(&context, Art.polygon(road), pathStops(), from: CGPoint(x: 0, y: H), to: CGPoint(x: 0, y: h))
        Art.stroke(&context, Art.line(214, H + 2, 216 - reach, h + 10), Color.white.opacity(0.35), width: 1.4)
        Art.stroke(&context, Art.line(218, H + 2, 216 + reach, h + 10), ArtStyle.coolShade.opacity(0.14), width: 1.6)

        // The gate: two posts and the earth wall running off both ways.
        let gateY: CGFloat = H + band.ground * 0.42
        let gap: CGFloat = 50 * u + 34
        yardWall(&context, x0: -10, x1: 216 - gap, baseY: gateY, height: 20 * u)
        yardWall(&context, x0: 216 + gap, x1: 442, baseY: gateY, height: 20 * u)
        Art.group(&context, x: 216 - gap, y: gateY + 2, scale: 0.72 * u) { g in
            gatePost(&g, x: 0, baseY: 0, height: 62)
        }
        Art.group(&context, x: 216 + gap, y: gateY + 2, scale: 0.72 * u) { g in
            gatePost(&g, x: 0, baseY: 0, height: 62)
        }

        // Yu Gong (he faces right, down the road) and the little boy.
        let feet: CGFloat = foldedFeet(band)
        let k: CGFloat = 0.95 * u
        let off: CGFloat = 44 * u + 24
        Kit.shadow(&context, 216 - off, feet, width: 58 * k)
        Art.group(&context, x: 216 - off, y: feet, scale: k, scaleX: -1) { p in
            yuGongWithHoe(&p, look: CGPoint(x: -0.7, y: -0.3), mouth: .open, mirrored: true)
        }
        Kit.shadow(&context, 216 + off, feet, width: 34 * k, alpha: 0.2)
        Art.group(&context, x: 216 + off, y: feet - 10 * u, scale: k) { p in
            boy(&p, pose: .wave, look: CGPoint(x: -0.7, y: -0.3), mouth: .grin)
        }

        // Near plane: ears of millet cropped by the bottom corners.
        Kit.crop(&context, x0: -6, x1: 64, baseY: h - 16, height: 42 * u, tops: false, color: 0xB98A2C, seed: 5)
        Kit.crop(&context, x0: 372, x1: 438, baseY: h - 16, height: 36 * u, tops: false, color: 0xB98A2C, seed: 7)
        ArtStyle.finish(&context, size)
    }
}
