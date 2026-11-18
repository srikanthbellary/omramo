import SwiftUI
import OmramoCore

// The four scenes of "The Shipwrecked Sailor" as the picture band at the top of a phone:
// 432 units wide, 240…520 high. Each is its own composition: the subject's face inside
// x 86…346, above the wave edge that cuts the bottom 30 units, everything hung on the band's
// own horizon and scaled by `band.unit`.

extension SailorArt {
    // MARK: scene-ship

    /// The ship from the side in the middle of the band, its wide square sail filling the
    /// centre, the Sailor and the Captain small at the bow; a pale sky, the storm bank low on
    /// the trailing side, blue waves below.
    static func shipFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let light = storm()
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.sun(&context, 64, H - 28 * u, 15 * u, light: light)
        // The storm, far off and low on the trailing side.
        var rain = Path()
        for i in 0..<8 {
            let x: CGFloat = 318 + CGFloat(i) * 15
            rain.move(to: CGPoint(x: x, y: H - 18 * u))
            rain.addLine(to: CGPoint(x: x - 5 * u, y: H))
        }
        Art.stroke(&context, rain, Art.color(0x8E91B4, 0.3), width: 1.8)
        Kit.cloud(&context, 322, H - 14 * u, scale: 0.7 * u, color: Art.color(0xB7B9D4))
        Kit.cloud(&context, 384, H - 16 * u, scale: 1.0 * u, color: Art.color(0xA7A9C8))
        Kit.cloud(&context, 432, H - 12 * u, scale: 0.9 * u, color: Art.color(0x9395B8))
        Kit.water(&context, width: 432, top: H, bottom: size.height, stops: seaStops(), light: light, ripples: 30)
        Kit.glints(&context, x: 64, top: H, depth: band.ground, color: Art.color(0xFFF3C8), count: 14)
        Kit.swells(&context, width: 432, top: H + 6, bottom: size.height, rows: 5, crest: Color.white)

        let waterY: CGFloat = H + band.ground * 0.36
        let length: CGFloat = 252 * u
        rollers(&context, x0: -10, x1: 440, y: waterY - 12 * u, height: 6 * u)
        ship(&context, cx: 222, waterY: waterY, length: length, sailUp: true, bow: 2, crewSize: 0.3, heads: true)
        rollers(&context, x0: -30, x1: 440, y: waterY + 24 * u, height: 8 * u)
        nearWave(&context, x0: 262, x1: 452, bottom: size.height, height: 26 + 22 * u, seed: 5)
        nearWave(&context, x0: -20, x1: 130, bottom: size.height, height: 22 + 16 * u, seed: 9)
        ArtStyle.finish(&context, size)
    }

    // MARK: scene-island

    /// The Sailor sitting on a stone under the fig tree, his face in the middle of the band,
    /// figs above him, the sand and a strip of empty sea below and beyond.
    static func islandFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.34, least: 76, most: 160)
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let h: CGFloat = size.height
        let light = day()
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.sun(&context, 150, H - 24 * u, 15 * u, light: light)
        Kit.water(&context, width: 432, top: H, bottom: h, stops: seaStops(), light: light, ripples: 18)
        Kit.glints(&context, x: 150, top: H, depth: band.ground * 0.3, color: Art.color(0xFFF3C8), count: 10)
        Kit.birds(&context, 196, H - 44 * u, scale: 0.8 * u, color: Art.color(0x5F97A8))

        // The beach: turquoise shallows, a line of foam, pale sand.
        let sandY: CGFloat = H + band.ground * 0.3
        var sand = Path()
        sand.move(to: CGPoint(x: -10, y: h + 4))
        sand.addLine(to: CGPoint(x: -10, y: sandY + 10 * u))
        sand.addCurve(
            to: CGPoint(x: 200, y: sandY),
            control1: CGPoint(x: 60, y: sandY + 12 * u),
            control2: CGPoint(x: 130, y: sandY - 2 * u)
        )
        sand.addCurve(
            to: CGPoint(x: 442, y: sandY - 6 * u),
            control1: CGPoint(x: 290, y: sandY + 4 * u),
            control2: CGPoint(x: 370, y: sandY - 6 * u)
        )
        sand.addLine(to: CGPoint(x: 442, y: h + 4))
        sand.closeSubpath()
        let shore: Path = sand
        Art.fill(&context, shore.applying(CGAffineTransform(translationX: 0, y: -9 * u)), Art.color(0x6FD0CC, 0.6))
        Art.fill(&context, shore.applying(CGAffineTransform(translationX: 0, y: -4 * u)), Art.color(0xA6E6D8, 0.8))
        Art.stroke(&context, shore.applying(CGAffineTransform(translationX: 0, y: -1.5)), Color.white.opacity(0.8), width: 2.4)
        Art.fillLinear(&context, shore, sandStops(), from: CGPoint(x: 0, y: sandY), to: CGPoint(x: 0, y: h))
        ArtStyle.tooth(&context, in: CGRect(x: 0, y: sandY + 10 * u, width: 432, height: max(1, h - sandY)), seed: 19, color: Art.color(0xB8935A), alpha: 0.14)

        let gy: CGFloat = H + band.ground * 0.55
        datePalm(&context, x: 56, baseY: sandY + 12 * u, height: 150 * u, lean: 14 * u, seed: 4)
        plank(&context, x: 118, y: sandY + 6 * u, length: 42 * u, tilt: -0.25)
        Kit.bush(&context, x: 404, baseY: gy - 10 * u, width: 92 * u, palette: figGreens(), seed: 6)
        let treeBase: CGFloat = gy - 8 * u
        let treeHeight: CGFloat = min(treeBase - 10, 330 * u)
        figTree(&context, x: 318, baseY: treeBase, height: treeHeight, spread: 300 * u, seed: 2)

        // The Sailor on his stone, looking out to sea.
        let s: CGFloat = 0.62 * u
        Kit.rock(&context, cx: 204 + 14 * s, baseY: gy, width: 72 * s, height: 37 * s, color: 0xC8B690, seed: 5)
        Kit.shadow(&context, 196, gy, width: 80 * s)
        Art.group(&context, x: 204, y: gy - 2 * s, scale: s) { p in
            sailor(&p, pose: .sit, look: CGPoint(x: -0.8, y: -0.1), mouth: .flat)
        }
        melon(&context, x: 384, baseY: gy + 6 * u, width: 32 * u)
        Kit.pebbles(&context, in: CGRect(x: 20, y: gy, width: 300, height: max(4, band.floor - gy)), count: 6, seed: 12, color: 0xD9C7A8)
        ArtStyle.finish(&context, size)
    }

    // MARK: scene-serpent

    /// The Serpent's kind face in the middle of the band, lapis brows and beard clear, his
    /// coils on the trailing side; the Sailor sits just below, on a loop of the golden body.
    static func serpentFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let h: CGFloat = size.height
        let light = day()
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.sun(&context, 96, H - 30 * u, 15 * u, light: light)
        Kit.ranges(&context, width: 432, horizon: H, scale: 0.6 * u, light: light, seed: 6)
        datePalm(&context, x: 40, baseY: H + 5, height: 78 * u, lean: 6 * u, seed: 5)
        datePalm(&context, x: 398, baseY: H + 6, height: 104 * u, lean: -10 * u, seed: 3)
        Kit.ground(&context, width: 432, top: H, bottom: h, stops: meadowStops())
        Kit.bush(&context, x: 22, baseY: H + 14 * u, width: 70 * u, palette: figGreens(), seed: 2)

        let gy: CGFloat = H + band.ground * 0.5
        let patch: Path = Art.ellipse(216, gy, 220, band.ground * 0.34)
        let tone: Kit.Stops = [(Art.color(0xFBEFC4, 0.95), 0), (Art.color(0xF4E3B0, 0.6), 0.7), (Art.color(0xF4E3B0, 0), 1)]
        Art.fillRadial(&context, patch, tone, center: CGPoint(x: 216, y: gy), radius: 220)
        Kit.flowers(&context, in: CGRect(x: 10, y: H + 8, width: 410, height: band.ground * 0.2), count: 6, seed: 5, petal: 0xFFFFFF)

        // The body along the ground, the coils, the neck and the head.
        let tb: CGFloat = 38 * u
        let spineY: CGFloat = gy - tb / 2
        ArtStyle.contactShadow(&context, 200, gy + 2, 130, 6 * u, alpha: 0.22)
        serpentTail(&context, from: CGPoint(x: 98, y: spineY), tip: CGPoint(x: 26, y: gy - 6 * u), width: tb, lift: -4 * u)
        var spine = Path()
        spine.move(to: CGPoint(x: 94, y: spineY))
        spine.addQuadCurve(to: CGPoint(x: 300, y: spineY), control: CGPoint(x: 200, y: spineY + 5 * u))
        serpentBody(&context, spine, width: tb)
        serpentCoils(&context, cx: 330, baseY: gy + 4 * u, width: 170 * u, thick: 44 * u, turns: 2)
        let headAt = CGPoint(x: 226, y: H - 66 * u)
        let neck: Path = serpentNeck(from: CGPoint(x: 336, y: gy - 50 * u), to: headAt, rise: 64 * u)
        serpentBody(&context, neck, width: 40 * u)
        Art.group(&context, x: headAt.x, y: headAt.y, scale: 0.92 * u) { g in
            serpentHead(&g, look: CGPoint(x: -0.6, y: 0.5))
        }

        // The Sailor, sitting on the golden loop, looking up at his friend.
        let s: CGFloat = 0.6 * u
        let seatY: CGFloat = gy - tb + 34 * s
        Art.group(&context, x: 132, y: seatY, scale: s, scaleX: -1) { p in
            sailor(&p, pose: .sit, look: CGPoint(x: -0.6, y: -0.6), mouth: .grin, mirrored: true)
        }
        ArtStyle.finish(&context, size)
    }

    // MARK: scene-home

    /// The Sailor at the bow of the ship, his face in the middle of the band, waving; behind
    /// him the bank of his town: palms, flat roofs and his children running to meet him.
    static func homeFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.32, least: 74, most: 150)
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let h: CGFloat = size.height
        let light = homeMorning()
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.sun(&context, 70, H - 30 * u, 15 * u, light: light)
        Kit.ranges(&context, width: 432, horizon: H, scale: 0.6 * u, light: light, seed: 9)
        Art.fill(&context, Art.rect(0, H - 4 * u, 432, 5 * u + 2), Art.color(0x9CC48A))
        Kit.farTrees(&context, x0: 8, x1: 230, baseY: H - 2 * u, height: 22 * u, count: 5, color: Art.color(0x86B88A), seed: 5)
        Kit.water(&context, width: 432, top: H, bottom: h, stops: nileStops(), light: light, ripples: 26)
        homeBank(&context, top: H - 2 * u, unit: u)

        // The ship, sailing to the right (mirrored), sail furled; the Sailor's face at x 216.
        let length: CGFloat = 380 * u
        let shipX: CGFloat = 216 - 0.338 * length
        let waterY: CGFloat = H + band.ground * 0.52
        Art.group(&context, x: shipX, y: 0, scaleX: -1) { s in
            ship(&s, cx: 0, waterY: waterY, length: length, sailUp: false, bow: 1, crewSize: 0.36, heads: true, mirrored: true)
        }
        Kit.reeds(&context, x: 412, baseY: h + 6, count: 6, height: 92 * u, seed: 21, color: 0x2E6A48, papyrus: true)
        ArtStyle.finish(&context, size)
    }

    /// The town's bank on the trailing side of the folded band: earth, a brick quay, two
    /// flat-roofed houses, palms, papyrus, and two children running. `top` is the back edge
    /// of the bank; `u` the band's unit.
    static func homeBank(_ context: inout GraphicsContext, top: CGFloat, unit u: CGFloat) {
        var bank = Path()
        bank.move(to: CGPoint(x: 442, y: top))
        bank.addLine(to: CGPoint(x: 304, y: top + 2 * u))
        bank.addQuadCurve(to: CGPoint(x: 264, y: top + 16 * u), control: CGPoint(x: 272, y: top + 4 * u))
        bank.addLine(to: CGPoint(x: 442, y: top + 16 * u))
        bank.closeSubpath()
        let earth: Kit.Stops = [(Art.color(0xEAD3A4), 0), (Art.color(0xD9BC8A), 1)]
        Kit.solid(&context, bank, stops: earth, light: 0.2, shade: 0.14)
        let face: Path = Art.rect(266, top + 15 * u, 180, 9 * u, radius: 2)
        Kit.solid(&context, face, Art.color(0xB88C5E), light: 0.2, shade: 0.24)
        Art.stroke(&context, Art.line(266, top + 15 * u, 442, top + 15 * u), Art.color(0xF0DDB6), width: 2)

        datePalm(&context, x: 356, baseY: top + 4 * u, height: 124 * u, lean: -8 * u, seed: 3)
        datePalm(&context, x: 420, baseY: top + 3 * u, height: 146 * u, lean: 6 * u, seed: 6)
        Kit.house(&context, cx: 392, baseY: top + 8 * u, width: 62 * u, wallHeight: 46 * u, roofHeight: 7 * u, wall: mudBrick, roof: 0x9A7A56, style: .flat, door: 0x6A4630, windows: 1)
        Kit.house(&context, cx: 326, baseY: top + 7 * u, width: 44 * u, wallHeight: 34 * u, roofHeight: 6 * u, wall: whitewash, roof: 0xB89A72, style: .flat, door: 0x6A4630, windows: 1)
        Kit.reeds(&context, x: 262, baseY: top + 22 * u, count: 5, height: 44 * u, seed: 4, color: 0x4F9A5A, papyrus: true)

        let k: CGFloat = 0.3 * u
        Kit.shadow(&context, 320, top + 14 * u, width: 18 * u)
        Art.group(&context, x: 320, y: top + 13.5 * u, scale: k) { c in
            Kit.person(&c, childLook(1), pose: .wave, look: CGPoint(x: -0.6, y: 0), mouth: .grin)
        }
        Kit.shadow(&context, 301, top + 15 * u, width: 18 * u)
        Art.group(&context, x: 300, y: top + 14.5 * u, scale: k) { c in
            Kit.person(&c, childLook(0), pose: .walk, look: CGPoint(x: -0.6, y: 0), mouth: .open)
        }
    }
}
