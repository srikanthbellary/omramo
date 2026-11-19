import SwiftUI
import OmramoCore

// The tap-to-see pictures (432 × 404), the character-card portraits (432 × 400), the face
// chips (100 × 100) and the cover of "Daedalus and Icarus". Landmark pictures live elsewhere.

// MARK: - Crete from above

extension IcarusArt {
    /// The long island of Crete seen from high above: a ridge of brown-green mountains down
    /// its middle, pale shallows along the coast, pale blue sea all round.
    static func cretePicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let sea: Kit.Stops = [(Art.color(0xB4D8EA), 0), (Art.color(0x7FB3D5), 0.5), (Art.color(0x3F7FB2), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, h), sea, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: h))
        Art.glow(&context, 90, 40, 260, Art.color(0xFFF6DC), alpha: 0.3)
        Kit.rippleMarks(&context, x0: 10, x1: w - 10, y0: 30, y1: h - 40, count: 60, seed: 7, color: Color.white, alpha: 0.22)
        let coast: [CGPoint] = [
            CGPoint(x: 46, y: 190), CGPoint(x: 64, y: 172), CGPoint(x: 100, y: 168), CGPoint(x: 128, y: 156),
            CGPoint(x: 166, y: 162), CGPoint(x: 204, y: 150), CGPoint(x: 236, y: 156), CGPoint(x: 268, y: 144),
            CGPoint(x: 306, y: 152), CGPoint(x: 340, y: 142), CGPoint(x: 376, y: 150), CGPoint(x: 392, y: 166),
            CGPoint(x: 378, y: 182), CGPoint(x: 346, y: 186), CGPoint(x: 316, y: 196), CGPoint(x: 282, y: 192),
            CGPoint(x: 244, y: 204), CGPoint(x: 206, y: 198), CGPoint(x: 168, y: 210), CGPoint(x: 128, y: 204),
            CGPoint(x: 92, y: 206), CGPoint(x: 62, y: 202)
        ]
        let crete = Kit.bodyRound(coast)
        Art.stroke(&context, crete, Art.color(0xDDF0F4, 0.5), width: 16)
        Art.stroke(&context, crete, Art.color(0xEAF6F6, 0.8), width: 6)
        Art.fill(&context, crete.offsetBy(dx: 4, dy: 5), ArtStyle.coolShade.opacity(0.14))
        let land: Kit.Stops = Kit.stops(0xB7A276, 0x8E9A64)
        Kit.solid(&context, crete, stops: land, light: 0.28, shade: 0.26, rim: 1.6)
        creteMountains(&context)
        // Small islands to the north and one ship on the sea road.
        let isles: [(CGFloat, CGFloat, CGFloat)] = [(150, 92, 14), (262, 76, 10), (320, 104, 8), (96, 262, 7)]
        for isle in isles {
            let blob: [CGPoint] = [
                CGPoint(x: isle.0 - isle.2, y: isle.1), CGPoint(x: isle.0 - isle.2 * 0.3, y: isle.1 - isle.2 * 0.6),
                CGPoint(x: isle.0 + isle.2, y: isle.1 - isle.2 * 0.3), CGPoint(x: isle.0 + isle.2 * 0.6, y: isle.1 + isle.2 * 0.5),
                CGPoint(x: isle.0 - isle.2 * 0.4, y: isle.1 + isle.2 * 0.5)
            ]
            let shape = Kit.bodyRound(blob)
            Art.stroke(&context, shape, Art.color(0xEAF6F6, 0.7), width: 4)
            Kit.solid(&context, shape, Art.color(0x9C9A6C), light: 0.3, shade: 0.2)
        }
        Art.group(&context, x: 300, y: 250, rotate: Kit.deg(-20), scale: 0.6) { b in
            Art.fill(&b, Art.ellipse(0, 0, 14, 4), Art.color(0x7A5234))
            Art.fill(&b, Art.rect(-6, -3, 12, 3), Art.color(linen))
            Art.stroke(&b, Art.svg("M14,1 C24,2 34,5 44,10"), Color.white.opacity(0.5), width: 2)
        }
        Kit.sink(&context, size, card: 0x1F4A6B)
    }

    /// The three mountain massifs down Crete's spine (west, Ida in the middle, east), seen
    /// from above: lit on their north-west faces, shaded to the south-east.
    static func creteMountains(_ g: inout GraphicsContext) {
        let massifs: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [(104, 186, 34, 11), (214, 178, 44, 14), (318, 168, 32, 10)]
        for m in massifs {
            let ridge: [CGPoint] = [
                CGPoint(x: m.0 - m.2, y: m.1 + 2), CGPoint(x: m.0 - m.2 * 0.4, y: m.1 - m.3),
                CGPoint(x: m.0 + m.2 * 0.3, y: m.1 - m.3 * 0.8), CGPoint(x: m.0 + m.2, y: m.1 - 2),
                CGPoint(x: m.0 + m.2 * 0.4, y: m.1 + m.3 * 0.9), CGPoint(x: m.0 - m.2 * 0.5, y: m.1 + m.3 * 0.8)
            ]
            let shape = Kit.bodyRound(ridge)
            Kit.solid(&g, shape, Art.color(0x7E6E50), light: 0.34, shade: 0.36)
            var crest = Path()
            crest.move(to: CGPoint(x: m.0 - m.2 * 0.8, y: m.1 + 1))
            crest.addQuadCurve(to: CGPoint(x: m.0 + m.2 * 0.8, y: m.1 - 3), control: CGPoint(x: m.0, y: m.1 - m.3 * 0.9))
            Art.stroke(&g, crest, Art.color(0xEDE0C4, 0.75), width: 2)
        }
        Art.fill(&g, Art.circle(206, 172, 4), Art.color(0xF4EEE2, 0.8))
    }
}

// MARK: - The Labyrinth

extension IcarusArt {
    /// A round maze of pale stone walls seen from directly above, its paths winding in toward
    /// an empty, sunlit centre.
    static func labyrinthPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let ground: Kit.Stops = [(Art.color(0xE2C69A), 0), (Art.color(0xC9A274), 0.6), (Art.color(0x8A6440), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, h), ground, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: h))
        ArtStyle.tooth(&context, in: CGRect(x: 0, y: 0, width: w, height: h), seed: 61, color: Art.color(0x6A4A2A), alpha: 0.08)
        let cx: CGFloat = 216
        let cy: CGFloat = 178
        Art.glow(&context, cx, cy, 70, Art.color(0xFFF1C4), alpha: 0.7)
        let rings: [(CGFloat, CGFloat, CGFloat)] = [(28, 200, 40), (50, 20, 36), (72, 250, 30), (94, 110, 26), (116, 300, 22), (138, 160, 20)]
        var walls = Path()
        for ring in rings {
            let start: Angle = .degrees(Double(ring.1 + ring.2 * 0.5))
            let end: Angle = .degrees(Double(ring.1 + 360 - ring.2 * 0.5))
            var arc = Path()
            arc.addArc(center: CGPoint(x: cx, y: cy), radius: ring.0, startAngle: start, endAngle: end, clockwise: false)
            walls.addPath(arc)
        }
        let spokes: [(CGFloat, CGFloat, CGFloat)] = [(28, 50, 170), (50, 72, 300), (72, 94, 60), (94, 116, 200), (116, 138, 30), (50, 72, 120), (94, 116, 330)]
        for spoke in spokes {
            let a: CGFloat = Kit.deg(spoke.2)
            walls.move(to: CGPoint(x: cx + cos(a) * spoke.0, y: cy + sin(a) * spoke.0))
            walls.addLine(to: CGPoint(x: cx + cos(a) * spoke.1, y: cy + sin(a) * spoke.1))
        }
        Art.stroke(&context, walls.offsetBy(dx: 3, dy: 4), ArtStyle.coolShade.opacity(0.28), width: 10)
        Art.stroke(&context, walls, Art.color(0xD9CAB0), width: 10)
        Art.stroke(&context, walls.offsetBy(dx: -1.2, dy: -1.5), Art.color(0xF6EEDC), width: 5)
        Art.stroke(&context, walls, Art.color(0xFFF8E8, 0.5), width: 1.4)
        Kit.flecks(&context, in: CGRect(x: cx - 140, y: cy - 140, width: 280, height: 280), count: 40, seed: 13, color: Art.color(0x8A6A48), radius: 0.6...1.4)
        Art.fill(&context, Art.circle(cx, cy, 6), Art.color(0xFFF6DA, 0.6))
        Kit.sink(&context, size, card: 0x5A3A24)
    }
}

// MARK: - Beeswax

extension IcarusArt {
    /// One small round clay pot full of golden beeswax, a thumbprint in its surface, with one
    /// honeybee resting on the rim.
    static func beeswaxPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let wall: Kit.Stops = [(Art.color(0xF4E6C8), 0), (Art.color(0xE6CF9E), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, 250), wall, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: 250))
        Art.glow(&context, 120, 70, 220, Art.color(0xFFF6DC), alpha: 0.5)
        let table: Kit.Stops = [(Art.color(0xA87A50), 0), (Art.color(0x7A5234), 1)]
        Art.fillLinear(&context, Art.rect(0, 250, w, h - 250), table, from: CGPoint(x: 0, y: 250), to: CGPoint(x: 0, y: h))
        Art.fill(&context, Art.rect(0, 250, w, 3), Art.color(0xFFE3B0, 0.5))
        let cx: CGFloat = 216
        let rimY: CGFloat = 150
        let base: CGFloat = 276
        Kit.shadow(&context, cx + 6, base, width: 200, alpha: 0.32)
        var pot = Path()
        pot.move(to: CGPoint(x: cx - 96, y: rimY))
        pot.addCurve(to: CGPoint(x: cx - 58, y: base), control1: CGPoint(x: cx - 128, y: rimY + 50), control2: CGPoint(x: cx - 104, y: base))
        pot.addLine(to: CGPoint(x: cx + 58, y: base))
        pot.addCurve(to: CGPoint(x: cx + 96, y: rimY), control1: CGPoint(x: cx + 104, y: base), control2: CGPoint(x: cx + 128, y: rimY + 50))
        pot.closeSubpath()
        Kit.solid(&context, pot, Art.color(0xB5683A), light: 0.32, shade: 0.34, rim: 2)
        Art.clipped(&context, to: pot) { g in
            Art.fill(&g, Art.rect(cx - 130, rimY + 44, 260, 12), Art.color(0x6A3A22, 0.85))
            var waves = Path()
            var x: CGFloat = cx - 130
            while x < cx + 130 {
                waves.move(to: CGPoint(x: x, y: rimY + 70))
                waves.addQuadCurve(to: CGPoint(x: x + 20, y: rimY + 70), control: CGPoint(x: x + 10, y: rimY + 60))
                x += 20
            }
            Art.stroke(&g, waves, Art.color(0x6A3A22, 0.8), width: 2.2)
        }
        let rim = Art.ellipse(cx, rimY, 98, 22)
        Kit.solid(&context, rim, Art.color(0xC97C4C), light: 0.3, shade: 0.2)
        let waxTop = Art.ellipse(cx, rimY + 3, 86, 17)
        let gold: Kit.Stops = [(Art.color(0xF6D06A), 0), (Art.color(0xE8B84A), 0.6), (Art.color(0xC9922E), 1)]
        Kit.solid(&context, waxTop, stops: gold, light: 0.34, shade: 0.24)
        var whorl = Path()
        let radii: [CGFloat] = [5, 9, 13, 17]
        for r in radii {
            whorl.addEllipse(in: CGRect(x: cx + 20 - r, y: rimY - r * 0.36, width: r * 2, height: r * 0.72))
        }
        Art.stroke(&context, whorl, Art.color(0xC9922E, 0.7), width: 1.2)
        Art.fill(&context, Art.ellipse(cx - 34, rimY - 2, 26, 5), Color.white.opacity(0.35))
        Art.group(&context, x: cx + 82, y: rimY - 18, scale: 3.2) { b in
            Kit.critterBee(&b)
        }
        Kit.sink(&context, size, card: 0x6A4A12)
    }
}

// MARK: - The Icarian Sea

extension IcarusArt {
    /// A steep green island (Ikaria) rising from calm blue water, a few white feathers
    /// floating in the foreground.
    static func icarianSeaPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let light = noon()
        let H: CGFloat = 214
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.cloud(&context, 330, 60, scale: 0.5, color: Color.white.opacity(0.55))
        let farIsle = Kit.ridge(width: 120, y: H - 6, amp: 6, seed: 9, bottom: H + 2, x0: 330)
        Art.fill(&context, farIsle, light.far)
        var mountain = Path()
        mountain.move(to: CGPoint(x: 70, y: H + 4))
        mountain.addCurve(to: CGPoint(x: 176, y: 92), control1: CGPoint(x: 104, y: 170), control2: CGPoint(x: 136, y: 104))
        mountain.addQuadCurve(to: CGPoint(x: 214, y: 74), control: CGPoint(x: 196, y: 76))
        mountain.addQuadCurve(to: CGPoint(x: 256, y: 104), control: CGPoint(x: 236, y: 82))
        mountain.addCurve(to: CGPoint(x: 364, y: H + 4), control1: CGPoint(x: 290, y: 130), control2: CGPoint(x: 330, y: 176))
        mountain.closeSubpath()
        let slopes: Kit.Stops = Kit.stops(0x7FA46A, 0x4F7A4E, 0x3E6446)
        Kit.solid(&context, mountain, stops: slopes, light: 0.32, shade: 0.34, rim: 2)
        Art.clipped(&context, to: mountain) { g in
            var gullies = Path()
            gullies.move(to: CGPoint(x: 200, y: 86))
            gullies.addQuadCurve(to: CGPoint(x: 180, y: H), control: CGPoint(x: 206, y: 150))
            gullies.move(to: CGPoint(x: 244, y: 100))
            gullies.addQuadCurve(to: CGPoint(x: 272, y: H), control: CGPoint(x: 250, y: 160))
            Art.stroke(&g, gullies, Art.color(0x2E5440, 0.35), width: 3)
            Art.fill(&g, Art.rect(60, H - 18, 320, 22), Art.color(0xCFC0A0, 0.7))
        }
        Kit.cypress(&context, x: 150, baseY: H - 12, height: 30, color: 0x2A4E3C)
        Kit.cypress(&context, x: 162, baseY: H - 10, height: 24, color: 0x2A4E3C)
        let sea: Kit.Stops = [(Art.color(0x9CC6E0), 0), (Art.color(0x4F8FC0), 0.5), (Art.color(0x2F6A9A), 1)]
        Kit.water(&context, width: w, top: H, bottom: h, stops: sea, light: light, ripples: 6, seed: 71)
        Art.fill(&context, Art.ellipse(216, H + 3, 156, 4), Color.white.opacity(0.4))
        let drift: [(CGFloat, CGFloat, CGFloat, CGFloat, UInt32)] = [
            (150, 262, 30, -76, 0xF8F7F2), (200, 274, 24, -104, 0xE6E4DC), (246, 258, 28, -64, 0xFBFAF5), (292, 276, 22, -96, 0xD9D7CF)
        ]
        for f in drift {
            Art.stroke(&context, Art.ellipse(f.0 + 4, f.1 + 3, f.2 * 0.75, f.2 * 0.16), Color.white.opacity(0.4), width: 1)
            feather(&context, x: f.0 - f.2 * 0.5, y: f.1, length: f.2, angle: f.3, tone: f.4)
        }
        Kit.sink(&context, size, card: 0x1B4A6E)
    }
}

// MARK: - Portraits

extension IcarusArt {
    /// Daedalus at his bench, holding a long grey feather up to the window light and studying
    /// it; pale sky and sea in the window behind.
    static func daedalusPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0x3E6E9A, bottom: 0x12263F, halo: 0xF6E6BE, rays: false) { g in
            let win = Art.rect(286, 36, 120, 170, radius: 3)
            Kit.solid(&g, Art.rect(276, 26, 140, 190, radius: 4), Art.color(0x9FB4C4), light: 0.2, shade: 0.2)
            let pane: Kit.Stops = [(Art.color(0xF6F7F2), 0), (Art.color(0xE9F0F1), 0.7), (Art.color(0xA9CDE2), 0.72), (Art.color(0x8DBBD8), 1)]
            Art.fillLinear(&g, win, pane, from: CGPoint(x: 0, y: 36), to: CGPoint(x: 0, y: 206))
            Art.fill(&g, Art.rect(286, 36, 120, 8), ArtStyle.coolShade.opacity(0.1))
            Art.group(&g, x: 206, y: 146, scale: 2.1) { b in
                Kit.bust(&b, daedalusLook(), look: CGPoint(x: 0.8, y: -0.7), mouth: .flat, wave: true)
                apron(&b)
                head(&b, .daedalus, look: CGPoint(x: 0.8, y: -0.7), mouth: .flat)
                feather(&b, x: 72, y: -4, length: 56, angle: 10, tone: 0xA9A6A0)
                Kit.solid(&b, Art.circle(71, 0, 9), Art.color(daedalusLook().skin), light: 0.3, shade: 0.2)
            }
            Art.group(&g, x: 60, y: 330, scale: 1) { b in
                Kit.solid(&b, Art.rect(-70, 0, 190, 80, radius: 4), Art.color(timber), light: 0.3, shade: 0.24, rim: 1.4)
            }
            featherRows(&g, x0: 24, y0: 322, rows: 1, count: 7, scale: 1.3)
        }
    }

    /// The working leather apron over the bust, in bust units.
    static func apron(_ g: inout GraphicsContext) {
        let bib = Art.svg("M-34,150 L-30,78 C-22,70 22,70 30,78 L34,150Z")
        Kit.solid(&g, bib, Art.color(0x8A5A36), light: 0.26, shade: 0.24)
        Art.stroke(&g, Art.svg("M-27,78 L-15,38 M27,78 L15,38"), Art.color(0x6A4228), width: 4)
        Art.stroke(&g, Art.svg("M-22,96 L22,96"), Art.color(0x6A4228, 0.6), width: 1.2, dash: [3, 3])
    }

    /// Icarus laughing, a small white feather pinched between finger and thumb, his curls
    /// lifting in the wind; pale sky behind.
    static func icarusPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0x5E9FCB, bottom: 0x173B5E, halo: 0xFBF1D8, rays: false) { g in
            Kit.cloud(&g, 110, 90, scale: 0.7, color: Color.white.opacity(0.3))
            Kit.cloud(&g, 350, 230, scale: 0.6, color: Color.white.opacity(0.22))
            Art.group(&g, x: 216, y: 150, scale: 2.2) { b in
                Kit.bust(&b, icarusLook(), look: CGPoint(x: 0.5, y: -0.3), mouth: .grin, wave: true)
                let zig = Art.svg("M-60,128 L-50,120 L-40,128 L-30,120 L-20,128 L-10,120 L0,128 L10,120 L20,128 L30,120 L40,128 L50,120 L60,128")
                Art.stroke(&b, zig, Art.color(0xF6F1E6, 0.9), width: 3)
                head(&b, .icarus, look: CGPoint(x: 0.5, y: -0.3), mouth: .grin)
                let locks = Art.svg("M26,-18 C38,-24 46,-20 52,-28 M28,-4 C40,-8 48,-2 56,-10 M24,10 C34,8 42,14 50,8")
                Art.stroke(&b, locks, Art.color(0x2B1D16), width: 4)
                feather(&b, x: 70, y: -6, length: 26, angle: 24, tone: 0xFBFAF6)
                Kit.solid(&b, Art.ellipse(68, -2, 5, 7), Art.color(icarusLook().skin), light: 0.3, shade: 0.2)
            }
        }
    }
}

// MARK: - Face chips

extension IcarusArt {
    static func daedalusFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xFFE9B8) { g in
            Art.group(&g, x: 0, y: 2, scale: 1.22) { f in
                head(&f, .daedalus, look: .zero, mouth: .smile)
            }
        }
    }

    static func icarusFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xDCE9FA) { g in
            Art.group(&g, x: 0, y: 2, scale: 1.34) { f in
                head(&f, .icarus, look: .zero, mouth: .grin)
            }
        }
    }

    static func minosFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xF6DCD6) { g in
            Art.group(&g, x: 0, y: 4, scale: 1.18) { f in
                head(&f, .minos, look: .zero, mouth: .smile)
            }
        }
    }
}

// MARK: - Cover

extension IcarusArt {
    /// Father and son flying side by side over a pale blue sea with small islands below:
    /// Icarus a little higher, face tipped up toward the sun; Daedalus looking up at him, one
    /// wing reaching toward him.
    static func cover(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.cover(&context, size) { g, frame in
            let k: CGFloat = frame.k
            let H: CGFloat = frame.H
            let hd: CGFloat = frame.hd
            let light = noon()
            let box = CGSize(width: 240, height: hd)
            Kit.sky(&g, box, horizon: H, light: light)
            Art.glow(&g, 0, 0, 150, Art.color(0xFFF2C8), alpha: 0.6)
            Kit.cloud(&g, 190, H - 60 * k, scale: 0.3 * k, color: Color.white.opacity(0.5))
            Kit.water(&g, width: 240, top: H, bottom: hd, stops: seaStops(), light: light, ripples: 6, seed: 81)
            island(&g, cx: 40, baseY: H + 2, width: 30, height: 6, seed: 3)
            island(&g, cx: 186, baseY: H + 3, width: 40, height: 8, seed: 5, green: true)
            island(&g, cx: 112, baseY: H + 18 * k, width: 46, height: 9, seed: 7)
            ArtStyle.atmosphere(&g, width: 240, top: H - 12, bottom: H + 12, color: light.haze, alpha: 0.35)
            Kit.swells(&g, width: 240, top: H + 10, bottom: hd, rows: 4, crest: Color.white.opacity(0.3), seed: 83)
            Art.group(&g, x: 156, y: H - 14 * k, scale: 0.68 * k) { b in
                flyer(&b, .daedalus, tilt: -66, look: CGPoint(x: -0.8, y: -0.8), mouth: .flat)
            }
            Art.group(&g, x: 98, y: H - 44 * k, scale: 0.72 * k) { b in
                flyer(&b, .icarus, tilt: -54, look: CGPoint(x: -0.5, y: -1), mouth: .grin)
            }
            gull(&g, x: 230, y: 12, scale: 1.3, up: true)
        }
    }
}
