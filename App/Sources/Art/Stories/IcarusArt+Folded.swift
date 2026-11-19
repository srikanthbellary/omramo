import SwiftUI
import OmramoCore

// The four folded-phone bands of "Daedalus and Icarus" (432 wide, about 240…520 high): each
// its own composition, the subject's face in the middle third, the bottom 30 cut by the wave.

// MARK: - Workshop

extension IcarusArt {
    /// Icarus kneeling in the lower middle among rows of feathers, one small feather floating
    /// above his hand; a pale wall and the window of white sky and sea above.
    static func workshopFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let wallStops: Kit.Stops = [(Art.color(0xF5EFE2), 0), (Art.color(0xE7D9BF), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, H), wallStops, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: H))
        let winTop: CGFloat = 30
        let winBottom: CGFloat = max(winTop + 40, H - 64 * u)
        let winH: CGFloat = winBottom - winTop
        Kit.solid(&context, Art.rect(70, winTop - 12, 292, winH + 22, radius: 3), Art.color(0xE3D5BB), light: 0.2, shade: 0.12)
        let seaTop: CGFloat = winTop + winH * 0.7
        let sky: Kit.Stops = [(Art.color(0xFBFBF7), 0), (Art.color(0xF6EFDD), 1)]
        Art.fillLinear(&context, Art.rect(82, winTop, 268, seaTop - winTop), sky, from: CGPoint(x: 0, y: winTop), to: CGPoint(x: 0, y: seaTop))
        let sea: Kit.Stops = [(Art.color(0xC3DDEB), 0), (Art.color(0xA6CBE1), 1)]
        Art.fillLinear(&context, Art.rect(82, seaTop, 268, winBottom - seaTop), sea, from: CGPoint(x: 0, y: seaTop), to: CGPoint(x: 0, y: winBottom))
        Art.fill(&context, Art.rect(334, winTop, 16, winH), ArtStyle.coolShade.opacity(0.08))
        Kit.solid(&context, Art.rect(62, winBottom, 308, 10, radius: 3), Art.color(0xDDCDAE), light: 0.3, shade: 0.18)
        gull(&context, x: 270, y: winTop + winH * 0.35, scale: 0.4, up: true)
        Kit.ground(&context, width: w, top: H, bottom: h, stops: Kit.stops(0xDCC7A2, 0xC4A77E), seed: 47)
        Art.fill(&context, Art.rect(0, H - 6, w, 7), ArtStyle.coolShade.opacity(0.08))
        var beam = Path()
        beam.move(to: CGPoint(x: 90, y: H + 4))
        beam.addLine(to: CGPoint(x: 350, y: H + 4))
        beam.addLine(to: CGPoint(x: 420, y: h))
        beam.addLine(to: CGPoint(x: 170, y: h))
        beam.closeSubpath()
        Art.fill(&context, beam, Art.color(0xFFF3CF, 0.22))
        // The bench cropped by the trailing edge, with the wax pot and a candle.
        bench(&context, x0: 352, x1: 470, topY: H - 22 * u, floorY: H + 18 * u)
        waxPot(&context, cx: 396, baseY: H - 22 * u, scale: 0.75 * u)
        candle(&context, x: 424, baseY: H - 22 * u, height: 22 * u)
        featherSack(&context, cx: 40, baseY: H + 20 * u, scale: 0.75 * u)
        let feet: CGFloat = H + 26 * u
        featherRows(&context, x0: 96, y0: H + 4 * u, rows: 3, count: 7, scale: u)
        Kit.shadow(&context, 236, feet, width: 70 * u)
        Art.group(&context, x: 236, y: feet, scale: 1.4 * u) { b in
            person(&b, .icarus, pose: .kneel, look: CGPoint(x: -0.6, y: -0.9), mouth: .oh)
        }
        let headY: CGFloat = feet - 122 * u
        feather(&context, x: 196, y: headY - 6 * u, length: 22 * u, angle: -36, tone: 0xFBFAF6)
        var breath = Path()
        breath.move(to: CGPoint(x: 208, y: headY + 20 * u))
        breath.addQuadCurve(to: CGPoint(x: 198, y: headY + 2 * u), control: CGPoint(x: 198, y: headY + 14 * u))
        Art.stroke(&context, breath, Color.white.opacity(0.6), width: 1.2)
        feather(&context, x: 320, y: feet + 10 * u, length: 18 * u, angle: -100, tone: darkFeathers[1])
        ArtStyle.finish(&context, size)
    }
}

// MARK: - Palace

extension IcarusArt {
    /// Minos and Daedalus at the parapet between two red columns, a strip of sea beyond.
    static func palaceFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let light = day()
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.cloud(&context, 250, H * 0.35, scale: 0.45, color: Color.white.opacity(0.5))
        let seaLine: CGFloat = H - 40 * u
        let cape = Kit.ridge(width: 160, y: seaLine, amp: 12 * u, seed: 4, bottom: seaLine + 2, x0: 30)
        Art.fill(&context, cape, light.far)
        let strip: Kit.Stops = [(Art.color(0xB9D6E7), 0), (Art.color(0x8DB9D6), 1)]
        Art.fillLinear(&context, Art.rect(0, seaLine, w, H - seaLine + 4), strip, from: CGPoint(x: 0, y: seaLine), to: CGPoint(x: 0, y: H))
        minoanShip(&context, cx: 110, waterY: seaLine + 18 * u, length: 34 * u)
        ArtStyle.atmosphere(&context, width: w, top: seaLine - 20 * u, bottom: H, color: light.haze, alpha: 0.3)
        Kit.ground(&context, width: w, top: H, bottom: h, stops: Kit.stops(0xE6D9BE, 0xD2BF9C), seed: 49)
        // Two red columns frame the pair; a lintel across their tops.
        let colBase: CGFloat = H + 30 * u
        let colTop: CGFloat = 22
        let colH: CGFloat = colBase - colTop
        minoanColumn(&context, cx: 34, baseY: colBase, height: colH, width: 24 * u)
        minoanColumn(&context, cx: 400, baseY: colBase, height: colH, width: 24 * u)
        Kit.solid(&context, Art.rect(-10, 0, w + 20, colTop, radius: 0), Art.color(0xE6D9BF), light: 0.2, shade: 0.2)
        Art.fill(&context, Art.rect(-10, colTop - 5, w + 20, 4), Art.color(minoanRed, 0.75))
        Kit.olive(&context, x: 120, baseY: H + 4, height: 46 * u, seed: 5)
        let feet: CGFloat = H + 24 * u
        Art.group(&context, x: 262, y: feet - 2 * u, scale: 0.82 * u) { b in
            person(&b, .daedalus, pose: .stand, look: CGPoint(x: -0.8, y: 0), mouth: .flat)
        }
        Art.group(&context, x: 196, y: feet, scale: 0.86 * u) { b in
            person(&b, .minos, pose: .reach, look: CGPoint(x: -0.9, y: -0.1), mouth: .smile)
        }
        let parapetTop: CGFloat = H - 6 * u
        Kit.solid(&context, Art.rect(60, parapetTop, 312, 34 * u, radius: 2), Art.color(0xECE1CA), light: 0.28, shade: 0.18)
        Art.fill(&context, Art.rect(56, parapetTop - 4, 320, 5, radius: 2), Art.color(0xF4ECDA))
        fresco(&context, rect: CGRect(x: 70, y: parapetTop + 8 * u, width: 292, height: 20 * u))
        ArtStyle.finish(&context, size)
    }
}

// MARK: - Tower

extension IcarusArt {
    /// Father and son at the tower edge at dawn, the boy's arms half spread in his wings, the
    /// father bending toward him; the gold sky above, the sea far below.
    static func towerFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let light = dawn()
        let seaLine: CGFloat = H - 34 * u
        Kit.sky(&context, size, horizon: seaLine, light: light)
        Kit.cloud(&context, 300, seaLine * 0.4, scale: 0.5, color: Art.color(0xFBE7DA, 0.6))
        Kit.sun(&context, 54, seaLine + 3, 15 * u, light: light)
        let sea: Kit.Stops = [(Art.color(0xE9C9A6), 0), (Art.color(0x8FA9C0), 0.3), (Art.color(0x5A88AE), 1)]
        Kit.water(&context, width: w, top: seaLine, bottom: h, stops: sea, light: light, ripples: 6, seed: 41)
        Kit.glints(&context, x: 54, top: seaLine, depth: h - seaLine, color: Art.color(0xFFE7B0), count: 26, seed: 43)
        let places: [(CGFloat, CGFloat, CGFloat)] = [(150, seaLine * 0.55, 0.32), (196, seaLine * 0.42, 0.26)]
        gulls(&context, places: places)
        // The tower top: a stone slab across most of the band and its flank falling away.
        let top: CGFloat = H + 20 * u
        let roof: [CGPoint] = [CGPoint(x: 96, y: top - 16 * u), CGPoint(x: 440, y: top - 16 * u), CGPoint(x: 440, y: top), CGPoint(x: 80, y: top)]
        Kit.solid(&context, Art.polygon(roof), Art.color(0xE9DCC2), light: 0.3, shade: 0.16)
        Kit.wall(&context, rect: CGRect(x: 86, y: top, width: 360, height: h - top + 10), color: 0xDCCBAE)
        Art.fill(&context, Art.rect(86, top, 4, h - top), Art.color(0xFFE6C0, 0.45))
        var courses = Path()
        var y: CGFloat = top + 22 * u
        while y < h {
            courses.move(to: CGPoint(x: 86, y: y))
            courses.addLine(to: CGPoint(x: 446, y: y))
            y += 22 * u
        }
        Art.stroke(&context, courses, Art.color(0xA8916E, 0.4), width: 1.1)
        let feet: CGFloat = top - 6 * u
        Kit.shadow(&context, 280, feet, width: 70 * u)
        Art.group(&context, x: 280, y: feet, scale: 0.78 * u) { b in
            winged(&b, .daedalus, rig: bendRig(), look: CGPoint(x: -0.7, y: 0.6), mouth: .flat, headTilt: -4)
        }
        Kit.shadow(&context, 186, feet + 2, width: 50 * u)
        Art.group(&context, x: 186, y: feet + 2, scale: 0.95 * u) { b in
            winged(&b, .icarus, rig: spreadRig(lift: 4), look: CGPoint(x: -0.3, y: -0.9), mouth: .open, headTilt: 4)
        }
        ArtStyle.finish(&context, size)
    }
}

// MARK: - Sea

extension IcarusArt {
    /// Daedalus flying low over a bright sea, looking down at the scatter of feathers on the
    /// water below him; pale noon sky above, far islands.
    static func seaFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.42, least: 96, most: 210)
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let light = noon()
        Kit.sky(&context, size, horizon: H, light: light)
        Art.glow(&context, 20, 0, 220, Art.color(0xFFF6DC), alpha: 0.35)
        Kit.cloud(&context, 330, H * 0.3, scale: 0.4, color: Color.white.opacity(0.5))
        Kit.water(&context, width: w, top: H, bottom: h, stops: seaStops(), light: light, ripples: 8, seed: 51)
        island(&context, cx: 60, baseY: H + 2, width: 50 * u, height: 9 * u, seed: 3)
        island(&context, cx: 380, baseY: H + 3, width: 70 * u, height: 12 * u, seed: 7, green: true)
        ArtStyle.atmosphere(&context, width: w, top: H - 16, bottom: H + 16, color: light.haze, alpha: 0.4)
        Kit.glints(&context, x: 110, top: H, depth: h - H, color: Color.white, count: 30, seed: 53)
        Kit.swells(&context, width: w, top: H + 16, bottom: h, rows: 5, crest: Color.white.opacity(0.35), seed: 55)
        let drift: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
            (176, 34, 15, -80), (204, 44, 12, -110), (230, 30, 14, -64), (256, 50, 11, -96),
            (160, 56, 12, -120), (280, 38, 12, -72), (220, 62, 10, -100)
        ]
        var index: Int = 0
        for f in drift {
            let fx: CGFloat = f.0
            let fy: CGFloat = H + f.1 * u
            let len: CGFloat = f.2 * u * 1.2
            Art.stroke(&context, Art.ellipse(fx + 2, fy + 2, len * 0.9, len * 0.18), Color.white.opacity(0.35), width: 0.8)
            let tones: [UInt32] = index % 3 == 0 ? darkFeathers : paleFeathers
            feather(&context, x: fx - len * 0.5, y: fy, length: len, angle: f.3, tone: tones[index % tones.count])
            index += 1
        }
        Art.group(&context, x: 246, y: H - 12 * u, scale: 0.8 * u) { b in
            flyer(&b, .daedalus, tilt: -72, look: CGPoint(x: 0.4, y: 1), mouth: .oh)
        }
        ArtStyle.finish(&context, size)
    }
}
