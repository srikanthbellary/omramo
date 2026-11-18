import SwiftUI
import OmramoCore

// The four scenes of "The Herd Boy and the Weaving Maiden" as the picture band at the top of a
// phone (432 wide, about 240…520 high). Each is its own composition: the subject's face in the
// middle of the band, glowing against the dark, clear of the top corners and of the wave edge.
// All four are night or deep dusk, like the wide scenes.

extension WeaverArt {
    // MARK: scene-loom

    /// scene-loom (folded): Zhinü's face in the middle, bent a little over her work; the warp
    /// threads of the loom rise behind her, and a band of rose-gold silk runs through her hands
    /// across the bottom.
    static func loomFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let h: CGFloat = size.height
        let u: CGFloat = band.unit
        let light = dusk()
        Kit.sky(&context, size, horizon: band.H, light: light)
        Kit.stars(&context, width: 432, maxY: band.H * 0.5, count: 26, seed: 3, color: Art.color(0xE8E4FF))
        let farBank: Path = Kit.ridge(width: 432, y: band.H - 14 * u, amp: 10 * u, seed: 7, bottom: band.H + 8)
        Art.fill(&context, farBank, light.far)
        ArtStyle.atmosphere(&context, width: 432, top: band.H - 50 * u, bottom: band.H + 8, color: light.haze, alpha: 0.3)
        let floor: Kit.Stops = [(Art.color(0x2A2156), 0), (Art.color(0x14123A), 1)]
        Kit.ground(&context, width: 432, top: band.H, bottom: h, stops: floor, seed: 21, tooth: Art.color(silver))

        let cy: CGFloat = max(122, h * 0.52)
        let s: CGFloat = 0.72 + (u - 0.6) * 1.2
        let silkY: CGFloat = cy + 96 * s
        loomWarp(&context, cy: cy, scale: s, foot: silkY)

        Art.glow(&context, 216, cy + 40 * s, 150 * s, Art.color(rose), alpha: 0.2)
        let spec = zhinuLook()
        Art.group(&context, x: 216, y: cy, rotate: 0.05, scale: s) { b in
            Kit.bust(&b, spec, look: CGPoint(x: -0.2, y: 0.8), mouth: .smile)
            zhinuPin(&b)
        }
        // Her sleeves, coming forward to the cloth.
        let cloth: Color = Art.color(spec.cloth)
        let leftHand = CGPoint(x: 216 - 34 * s, y: silkY - 3 * s)
        let rightHand = CGPoint(x: 216 + 38 * s, y: silkY - 5 * s)
        var sleeves = Path()
        sleeves.move(to: CGPoint(x: 216 - 54 * s, y: cy + 56 * s))
        sleeves.addQuadCurve(to: leftHand, control: CGPoint(x: 216 - 64 * s, y: cy + 88 * s))
        sleeves.move(to: CGPoint(x: 216 + 56 * s, y: cy + 58 * s))
        sleeves.addQuadCurve(to: rightHand, control: CGPoint(x: 216 + 68 * s, y: cy + 88 * s))
        Art.stroke(&context, sleeves, cloth, width: 22 * s)
        Art.stroke(&context, sleeves.trimmedPath(from: 0.02, to: 0.4), Art.color(0xFFE0E0, 0.3), width: 4 * s)

        // The dark cloud she works above, the silk across it, and her hands on the silk.
        cloudBank(&context, x: 216, y: silkY + 16 * s, width: 520, height: 20 * s, color: 0x2E2664, edge: silver, seed: 5, bottom: h + 10)
        var ribbon = Path()
        ribbon.move(to: CGPoint(x: -12, y: silkY + 8 * s))
        ribbon.addCurve(to: CGPoint(x: 444, y: silkY - 6 * s), control1: CGPoint(x: 120, y: silkY - 8 * s), control2: CGPoint(x: 300, y: silkY + 10 * s))
        silkRibbon(&context, ribbon, width: 15 * s, glow: 1)
        let skin: Color = Art.color(spec.skin)
        Art.fill(&context, Art.circle(leftHand.x, leftHand.y, 8 * s), skin)
        Art.fill(&context, Art.circle(rightHand.x, rightHand.y, 8 * s), skin)
        Art.group(&context, x: rightHand.x + 4 * s, y: rightHand.y - 5 * s, rotate: -0.3, scale: s * 1.2) { g in
            shuttle(&g)
        }
        Art.glow(&context, 216, cy + 20 * s, 60 * s, Art.color(gold), alpha: 0.12)
        ArtStyle.finish(&context, size, wash: 0.05, vignette: 0.12)
    }

    /// The loom behind her in the folded band: the top beam, two posts and the warp threads
    /// running from the beam down to the cloth at `foot`.
    static func loomWarp(_ context: inout GraphicsContext, cy: CGFloat, scale s: CGFloat, foot: CGFloat) {
        let beamY: CGFloat = max(14, cy - 150 * s)
        let wood: UInt32 = 0x6A4A40
        let left: CGFloat = 236 - 64 * s
        let right: CGFloat = 236 + 64 * s
        Kit.propShaft(&context, left - 8 * s, beamY, 216 - 118 * s, foot + 20 * s, wood: wood, width: 8 * s)
        Kit.propShaft(&context, right + 8 * s, beamY, 216 + 126 * s, foot + 20 * s, wood: wood, width: 8 * s)
        var threads = Path()
        for i in 0...16 {
            let d: CGFloat = CGFloat(i) - 8
            threads.move(to: CGPoint(x: 236 + d * 8 * s, y: beamY))
            threads.addLine(to: CGPoint(x: 216 + d * 13 * s, y: foot))
        }
        Art.stroke(&context, threads, Art.color(silver, 0.5), width: max(0.7, 0.9 * s))
        Kit.propShaft(&context, left - 14 * s, beamY, right + 14 * s, beamY, wood: wood, width: 10 * s)
        // The heddle bar across the threads.
        let barY: CGFloat = Kit.mix(beamY, foot, 0.36)
        Kit.propShaft(&context, 216 - 96 * s, barY, 216 + 104 * s, barY, wood: wood, width: 5 * s)
    }

    // MARK: scene-meadow

    /// scene-meadow (folded): Niulang in the middle with his hand on the Old Ox's neck, the
    /// thatch of the hut behind one shoulder, a mulberry at the leading side, stars above.
    static func meadowFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let h: CGFloat = size.height
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let light = night()
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.stars(&context, width: 432, maxY: H * 0.82, count: 70, seed: 11)
        Kit.ranges(&context, width: 432, horizon: H, scale: 0.7 * u, light: light, seed: 6)
        let land: Kit.Stops = [(Art.color(0x1B3442), 0), (Art.color(0x163030), 0.5), (Art.color(0x0D2024), 1)]
        Kit.ground(&context, width: 432, top: H, bottom: h, stops: land, seed: 31, tooth: Art.color(0x8FC7A8))
        // The slow river under the hills.
        let water: Kit.Stops = [(Art.color(0x4A5E9A), 0), (Art.color(0x26386E), 1)]
        let top: CGFloat = H + 5 * u
        Art.fillLinear(&context, Art.rect(0, top, 432, 11 * u), water, from: CGPoint(x: 0, y: top), to: CGPoint(x: 0, y: top + 11 * u))
        Kit.rippleMarks(&context, x0: 0, x1: 432, y0: top + 1, y1: top + 10 * u, count: 18, seed: 5, color: Art.color(silver), alpha: 0.4)
        Kit.reeds(&context, x: 150, baseY: top + 14 * u, count: 5, height: 22 * u, seed: 42, color: 0x2A5A54)

        let k: CGFloat = 1.25 * u
        let feet: CGFloat = H + band.ground * 0.45
        mulberry(&context, x: 60, baseY: H + band.ground * 0.22, height: 90 * k, seed: 4)
        let hutY: CGFloat = H + band.ground * 0.28
        Kit.shadow(&context, 354, hutY + 3, width: 150 * k, alpha: 0.3)
        Art.group(&context, x: 352, y: hutY, scale: 0.95 * k) { g in
            hut(&g)
        }
        Kit.shadow(&context, 238 + 44 * k, feet + 2, width: 172 * k, alpha: 0.34)
        Art.group(&context, x: 236 + 44 * k, y: feet, scale: k) { o in
            ox(&o)
        }
        Kit.shadow(&context, 238, feet + 6 * k, width: 58 * k, alpha: 0.32)
        Art.group(&context, x: 236, y: feet + 5 * k, scale: k) { p in
            niulang(&p, pose: .stand, look: CGPoint(x: -0.3, y: 0), mouth: .smile)
        }
        Art.glow(&context, 216, feet - 110 * k, 110 * k, Art.color(silver), alpha: 0.07)
        // Near plane: grass in front of their feet.
        let near = CGRect(x: 0, y: feet + 6, width: 432, height: max(1, h - feet - 6))
        Kit.grass(&context, in: near, count: 36, seed: 5, color: Art.color(0x2A5650), height: 9 * u)
        Kit.grass(&context, in: near, count: 16, seed: 14, color: Art.color(0x4E8A7A), height: 7 * u)
        ArtStyle.finish(&context, size, wash: 0.05, vignette: 0.12)
    }
}

extension WeaverArt {
    // MARK: scene-river

    /// scene-river (folded): Zhinü from the shoulders up at the trailing side, looking across
    /// the wide band of stars to a very small figure and ox on the far bank.
    static func riverFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.26, least: 60, most: 130)
        let h: CGFloat = size.height
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let light = night()
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.stars(&context, width: 432, maxY: H * 0.9, count: 50, seed: 21)
        let p0 = CGPoint(x: 470, y: H * 0.3)
        let p1 = CGPoint(x: -30, y: H)
        silverRiver(&context, from: p0, to: p1, width0: 150 * u, width1: 60 * u, count: 440, seed: 5, mist0: 0.15, mist1: 0.06)

        // The far bank: a low cloud, the tiny Herd Boy and his ox, and Altair above them.
        let fx: CGFloat = 132
        let fy: CGFloat = max(78, H * 0.773 - 62 * u)
        let tiny: CGFloat = 0.2 * u + 0.04
        cloudBank(&context, x: fx, y: fy, width: 112 * u, height: 10 * u, color: 0x1D2A63, edge: silver, seed: 4, bottom: fy + 12 * u)
        Art.group(&context, x: fx + 8 * u, y: fy - 3 * u, scale: tiny) { o in
            ox(&o)
        }
        Art.group(&context, x: fx - 20 * u, y: fy - 2 * u, scale: tiny, scaleX: -1) { p in
            niulang(&p, pose: .stand, mirrored: true)
        }
        brightStar(&context, fx - 4, fy - 48 * u, 5 * u + 1, color: 0xFFF1D6)

        let midBank: Path = Kit.ridge(width: 432, y: H - 6 * u, amp: 8 * u, seed: 17, bottom: H + 8)
        Art.fill(&context, midBank, light.mid)
        let floor: Kit.Stops = [(Art.color(0x1D2460), 0), (Art.color(0x0B0E2C), 1)]
        Kit.ground(&context, width: 432, top: H, bottom: h, stops: floor, seed: 21, tooth: Art.color(silver))

        // Zhinü, near, on her own bank.
        let cx: CGFloat = 300
        let cy: CGFloat = h * 0.56
        let s: CGFloat = 0.7 + (u - 0.6)
        brightStar(&context, cx + 34 * s, cy - 88 * s, 6 * u + 1, color: 0xE6F0FF)
        Art.glow(&context, cx, cy, 90 * s, Art.color(silver), alpha: 0.1)
        let spec = zhinuLook()
        Art.group(&context, x: cx, y: cy, scale: s) { b in
            Kit.bust(&b, spec, look: CGPoint(x: -0.9, y: -0.3), mouth: .flat)
            zhinuPin(&b)
            // Her scarf, the one warm note.
            let scarf: Path = Art.svg("M-60,68 C-30,96 30,96 60,68")
            silkRibbon(&b, scarf, width: 9, glow: 0.7)
        }
        cloudBank(&context, x: cx - 10, y: cy + 108 * s, width: 400, height: 22 * u, color: 0x262C6C, edge: silver, seed: 14, bottom: h + 10)
        ArtStyle.finish(&context, size, wash: 0.04, vignette: 0.12)
    }

    // MARK: scene-bridge

    /// scene-bridge (folded): Zhinü and Niulang in the middle, taking hands, with magpie wings
    /// overlapping like tiles under their feet and stars all round them.
    static func bridgeFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let h: CGFloat = size.height
        let u: CGFloat = band.unit
        let light = night()
        // All sky: the horizon is put at the foot of the band.
        Kit.sky(&context, size, horizon: h, light: light)
        Kit.stars(&context, width: 432, maxY: h * 0.9, count: 80, seed: 33)

        let feetY: CGFloat = min(band.floor - 18, h * 0.8)
        let fitted: CGFloat = (feetY - 64) / 168 * 0.85
        let k: CGFloat = min(1.35, max(0.5, fitted))
        let p0 = CGPoint(x: 470, y: feetY - 14 * u)
        let p1 = CGPoint(x: -40, y: feetY + 18 * u)
        silverRiver(&context, from: p0, to: p1, width0: 96 * u, width1: 70 * u, count: 420, seed: 9, mist0: 0.12, mist1: 0.09)

        let rise: CGFloat = 52 * u
        magpieArch(&context, x0: -40, x1: 472, baseY: feetY + 10 + rise, rise: rise, thick: 28 * u)

        // Two of the nearest birds, and a bright star on each side.
        Art.group(&context, x: 66, y: feetY - 72 * u, rotate: -0.2, scale: 0.5 * u, scaleX: -1) { m in
            magpie(&m)
        }
        Art.group(&context, x: 374, y: feetY - 86 * u, rotate: 0.2, scale: 0.5 * u) { m in
            magpie(&m)
        }
        brightStar(&context, 112, feetY - 132 * u, 5 * u + 1, color: 0xE6F0FF)
        brightStar(&context, 326, feetY - 140 * u, 5 * u + 1, color: 0xFFF1D6)

        // The meeting.
        Art.glow(&context, 216, feetY - 100 * k, 130 * k, Art.color(rose), alpha: 0.18)
        Art.glow(&context, 216, feetY - 90 * k, 60 * k, Art.color(gold), alpha: 0.14)
        Art.group(&context, x: 216 - 38 * k, y: feetY, scale: k, scaleX: -1) { z in
            zhinu(&z, pose: .carry, look: CGPoint(x: -0.7, y: 0), mouth: .smile, mirrored: true)
        }
        Art.group(&context, x: 216 + 38 * k, y: feetY, scale: k) { p in
            niulang(&p, pose: .carry, look: CGPoint(x: -0.7, y: 0), mouth: .smile)
        }
        ArtStyle.finish(&context, size, wash: 0.04, vignette: 0.12)
    }
}
