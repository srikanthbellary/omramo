import SwiftUI
import OmramoCore

// The Bibliotheca Alexandrina on a bright day: our own drawing (no photograph, nothing traced).
// The great tilted disc of its roof, tiled with rows of small slanted glass-and-aluminium
// panels, leans down toward the blue Mediterranean like a rising sun; below it the curved grey
// granite wall is carved with rows of signs from many alphabets (drawn as small abstract marks,
// never words) and rises out of a pool. Palms stand on the plaza. Card background #1C3A4A.

extension LandmarkArt {
    /// bibliotheca-alexandrina: the tilted disc roof and carved granite drum by the pool, the
    /// Mediterranean behind, palms on the plaza, by day.
    static func paintBibliotheca(_ context: inout GraphicsContext) {
        biblioSky(&context)
        biblioSea(&context)
        biblioPlaza(&context)
        biblioWall(&context)
        biblioRoof(&context)
        // The warm sun lying on the roof and the drum, from the upper left.
        Art.glow(&context, 150, 150, 150, Art.color(0xFFE6B8), alpha: 0.14)
        biblioPool(&context)
        biblioPalms(&context)
        biblioPeople(&context)
        biblioNear(&context)
        biblioFinish(&context)
    }

    // MARK: Sky and sea

    static func biblioSky(_ context: inout GraphicsContext) {
        let sky: [(Color, CGFloat)] = [
            (Art.color(0x3F94D6), 0),
            (Art.color(0x7CB8E4), 0.22),
            (Art.color(0xCDE6F0), 0.42),
            (Art.color(0xF4EEDC), 0.48),
            (Art.color(0xF4EEDC), 1),
        ]
        backdrop(&context, sky)
        Art.glow(&context, 70, 110, 120, Art.color(0xFFF2D4), alpha: 0.35)
        let cloudA = cloudBand(230, 58, width: 110, height: 12)
        let cloudB = cloudBand(320, 86, width: 80, height: 8)
        let cloudC = cloudBand(96, 120, width: 76, height: 7)
        Art.fill(&context, cloudA, Art.color(0xFFFFFF, 0.6))
        Art.fill(&context, cloudB, Art.color(0xFFFFFF, 0.5))
        Art.fill(&context, cloudC, Art.color(0xFFFFFF, 0.45))
        Art.fill(&context, cloudA, ArtStyle.coolShade.opacity(0.04))
    }

    /// The Mediterranean behind the library, with far sails and the far shore of the bay.
    static func biblioSea(_ context: inout GraphicsContext) {
        let sea = Art.rect(-24, 186, unitWidth + 48, 50)
        let water: [(Color, CGFloat)] = [
            (Art.color(0x5AA6CC), 0),
            (Art.color(0x2E7FB0), 0.6),
            (Art.color(0x2A6E9C), 1),
        ]
        fillVertical(&context, sea, water, from: 186, to: 236)
        let shore = Art.svg("M300,187 C330,182 360,184 390,180 C410,178 440,181 456,180 L456,187 Z")
        Art.fill(&context, shore, Art.color(0xB8C4C4))
        ripples(&context, in: CGRect(x: 0, y: 190, width: unitWidth, height: 42), count: 46, seed: 17, color: Art.color(0xE8F6FA, 0.55), width: 0.7, length: 3...11)

        // Two far sails out in the bay.
        var sails = Path()
        sails.addPath(Art.polygon([pt(44, 200), pt(49, 189), pt(50, 200)]))
        sails.addPath(Art.polygon([pt(112, 196), pt(116, 188), pt(117, 196)]))
        var hulls = Path()
        hulls.addRect(CGRect(x: 42, y: 200, width: 10, height: 1.6))
        hulls.addRect(CGRect(x: 110, y: 196, width: 8, height: 1.4))
        Art.fill(&context, sails, Art.color(0xFFF8EA))
        Art.fill(&context, hulls, Art.color(0x2A4A66))
        haze(&context, top: 160, bottom: 236, hex: 0xEAF0EC, alpha: 0.4)
        horizon(&context, y: 186, rise: 30, hex: 0xFFEBC8, alpha: 0.25)
    }

    // MARK: Plaza

    static func biblioPlaza(_ context: inout GraphicsContext) {
        let plaza = Art.rect(-24, 232, unitWidth + 48, unitHeight - 232 + 24)
        let stone: [(Color, CGFloat)] = [
            (Art.color(0xF0E6D0), 0),
            (Art.color(0xD8CCB4), 0.35),
            (Art.color(0x7A8A90), 0.75),
            (Art.color(0x1C3A4A), 1),
        ]
        fillVertical(&context, plaza, stone, from: 232, to: unitHeight)
        // The low sea wall of the corniche along the back of the plaza.
        let seaWall = Art.rect(-24, 230, unitWidth + 48, 4)
        Art.fill(&context, seaWall, Art.color(0xD6CCB8))
        Art.stroke(&context, Art.line(-24, 230.4, 456, 230.4), Art.color(0xFFF6E4, 0.8), width: 0.8, cap: .butt)
        // Joints of the paving, closer together toward the back.
        var joints = Path()
        let rows: [CGFloat] = [240, 252, 268, 290, 318, 352]
        for y in rows {
            joints.move(to: pt(-24, y))
            joints.addLine(to: pt(456, y))
        }
        Art.stroke(&context, joints, Art.color(0x9A9484, 0.3), width: 0.6, cap: .butt)
    }

    // MARK: The granite drum

    /// A point on the rim of the tilted roof disc. `phi` runs round the rim: 0 is the high
    /// right end, pi/2 the front (lowest on screen), pi the low left end toward the sea.
    static func biblioRimPoint(_ phi: CGFloat) -> CGPoint {
        let tiltSin: CGFloat = -0.2955
        let tiltCos: CGFloat = 0.9553
        let lx: CGFloat = 150 * cos(phi)
        let ly: CGFloat = 34 * sin(phi)
        let x: CGFloat = 216 + lx * tiltCos - ly * tiltSin
        let y: CGFloat = 176 + lx * tiltSin + ly * tiltCos
        return pt(x, y)
    }

    /// The curved wall: from the roof's front rim down to the front of the base circle.
    static func biblioWallPath() -> Path {
        var path = Path()
        for index in 0...24 {
            let t: CGFloat = CGFloat(index) / 24
            let point = biblioRimPoint(CGFloat.pi * (1 - t))
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        for index in 0...24 {
            let t: CGFloat = CGFloat(index) / 24
            let phi: CGFloat = CGFloat.pi * t
            let x: CGFloat = 216 + 143.3 * cos(phi)
            let y: CGFloat = 230 + 22 * sin(phi)
            path.addLine(to: pt(x, y))
        }
        path.closeSubpath()
        return path
    }

    /// The granite drum, lit on the left and turning into shade on the right, with its rows
    /// of carved signs.
    static func biblioWall(_ context: inout GraphicsContext) {
        ArtStyle.contactShadow(&context, 230, 248, 150, 8, alpha: 0.2)
        let wall = biblioWallPath()
        let granite: [(Color, CGFloat)] = [
            (Art.color(0xA6A49E), 0),
            (Art.color(0xD2CEC4), 0.18),
            (Art.color(0xA8A8A6), 0.55),
            (Art.color(0x6C7284), 1),
        ]
        fillHorizontal(&context, wall, granite, from: 73, to: 360)
        model(&context, wall, light: 0.12, shade: 0.2)
        let marks = biblioMarks(seed: 29)
        Art.clipped(&context, to: wall) { g in
            Art.group(&g, x: -0.5, y: -0.5) { lit in
                Art.stroke(&lit, marks, Art.color(0xF2EEE4, 0.4), width: 0.7)
            }
            Art.stroke(&g, marks, Art.color(0x4E5264, 0.5), width: 0.8)
            // The shadow the roof's overhang throws onto the top of the wall.
            Art.group(&g, y: 5) { band in
                Art.stroke(&band, biblioFrontRim(), ArtStyle.coolShade.opacity(0.22), width: 8)
            }
        }
    }

    /// The front half of the roof rim, left to right.
    static func biblioFrontRim() -> Path {
        var path = Path()
        for index in 0...24 {
            let t: CGFloat = CGFloat(index) / 24
            let point = biblioRimPoint(CGFloat.pi * (1 - t))
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        return path
    }

    /// Rows of small carved signs: bars, rings, angles, crosses, hooks and waves, in no
    /// order, so they suggest many scripts and spell nothing.
    static func biblioMarks(seed: UInt32) -> Path {
        var random = ArtRandom(seed)
        var path = Path()
        var y: CGFloat = 132
        while y < 252 {
            var x: CGFloat = 76
            while x < 358 {
                let jitter: CGFloat = random.next(in: -1...1)
                let cx: CGFloat = x + jitter
                let kind: Int = min(5, Int(random.next() * 6))
                switch kind {
                case 0:
                    path.move(to: pt(cx, y - 2.5))
                    path.addLine(to: pt(cx, y + 2.5))
                case 1:
                    path.addPath(Art.circle(cx, y, 1.8))
                case 2:
                    path.move(to: pt(cx - 2, y + 2.5))
                    path.addLine(to: pt(cx, y - 2.5))
                    path.addLine(to: pt(cx + 2, y + 2.5))
                case 3:
                    path.move(to: pt(cx - 2, y))
                    path.addLine(to: pt(cx + 2, y))
                    path.move(to: pt(cx, y - 2.5))
                    path.addLine(to: pt(cx, y + 2.5))
                case 4:
                    path.move(to: pt(cx - 1.8, y - 2.5))
                    path.addLine(to: pt(cx + 1.8, y - 2.5))
                    path.addLine(to: pt(cx + 1.8, y + 2.5))
                default:
                    path.move(to: pt(cx - 2.2, y + 1))
                    path.addQuadCurve(to: pt(cx + 2.2, y + 1), control: pt(cx, y - 4))
                }
                x += 7.5
            }
            y += 9
        }
        return path
    }

    // MARK: The tilted roof

    /// The great disc of the roof, tilted down toward the sea: its edge, its glass, its panels.
    static func biblioRoof(_ context: inout GraphicsContext) {
        Art.group(&context, x: 216, y: 176, rotate: -0.3) { g in
            // The thickness of the roof's edge, showing below its front rim.
            let edge = Art.ellipse(0, 4.5, 150, 34)
            Art.fill(&g, edge, Art.color(0x5E6C7C))
            Art.fill(&g, edge, ArtStyle.coolShade.opacity(0.12))
            let disc = Art.ellipse(0, 0, 150, 34)
            let glass: [(Color, CGFloat)] = [
                (Art.color(0xEEF4F2), 0),
                (Art.color(0xBCCED8), 0.4),
                (Art.color(0x7E98AE), 1),
            ]
            fillHorizontal(&g, disc, glass, from: -150, to: 150)
            model(&g, disc, light: 0.3, shade: 0.22, rim: 0.7)
            biblioPanels(&g)
            Art.stroke(&g, disc, Art.color(0x6E7E8E, 0.5), width: 0.8)
        }
    }

    /// The rows of small slanted panels (drawn in the roof's own tilted frame): the sunlit ones
    /// gather on the left, the ones that mirror the deep sky on the right.
    static func biblioPanels(_ context: inout GraphicsContext) {
        let disc = Art.ellipse(0, 0, 150, 34)
        let rowStep: CGFloat = 4.25
        let slant: CGFloat = 0.75
        var rows = Path()
        var rowLights = Path()
        for index in 1..<16 {
            let y: CGFloat = -34 + CGFloat(index) * rowStep
            rows.move(to: pt(-152, y))
            rows.addLine(to: pt(152, y))
            rowLights.move(to: pt(-152, y + 1.1))
            rowLights.addLine(to: pt(152, y + 1.1))
        }
        var cols = Path()
        // Start on a multiple of the 9-unit panel width so the lit panels sit in the grid.
        var x: CGFloat = -180
        while x < 160 {
            cols.move(to: pt(x, -34))
            cols.addLine(to: pt(x + 12, 34))
            x += 9
        }

        var random = ArtRandom(43)
        var bright = Path()
        var deep = Path()
        for _ in 0..<80 {
            let row: CGFloat = CGFloat(min(15, Int(random.next() * 16)))
            let col: CGFloat = random.next(in: -150...140)
            let snapped: CGFloat = (col / 9).rounded(.down) * 9
            let y0: CGFloat = -34 + row * rowStep
            let shift: CGFloat = row * slant
            let left: CGFloat = snapped + shift
            let corners: [CGPoint] = [
                pt(left, y0), pt(left + 9, y0), pt(left + 9 + slant, y0 + rowStep), pt(left + slant, y0 + rowStep),
            ]
            if col < 20 {
                bright.addPath(Art.polygon(corners))
            } else {
                deep.addPath(Art.polygon(corners))
            }
        }
        Art.clipped(&context, to: disc) { g in
            Art.fill(&g, bright, Art.color(0xFFF2D0, 0.5))
            Art.fill(&g, deep, Art.color(0x4E6A86, 0.3))
            Art.stroke(&g, rows, Art.color(0x55697E, 0.55), width: 0.6, cap: .butt)
            Art.stroke(&g, rowLights, Art.color(0xFFFFFF, 0.4), width: 0.5, cap: .butt)
            Art.stroke(&g, cols, Art.color(0x55697E, 0.4), width: 0.5, cap: .butt)
        }
    }

    // MARK: Pool

    /// The pool the drum rises out of, the drum mirrored in it.
    static func biblioPool(_ context: inout GraphicsContext) {
        let pool = Art.svg("M36,250 C120,243 300,243 404,250 C414,268 404,288 382,296 C280,304 140,304 52,296 C30,288 26,266 36,250 Z")
        let water: [(Color, CGFloat)] = [
            (Art.color(0x9AD4E4), 0),
            (Art.color(0x5AACCC), 0.5),
            (Art.color(0x3A88AE), 1),
        ]
        fillVertical(&context, pool, water, from: 244, to: 302)
        Art.clipped(&context, to: pool) { g in
            // Mirrored about y = 248, the waterline.
            Art.group(&g, y: 496, rotate: CGFloat.pi, scaleX: -1, opacity: 0.32) { m in
                biblioWall(&m)
            }
            let glints = CGRect(x: 30, y: 250, width: 380, height: 48)
            ripples(&g, in: glints, count: 40, seed: 21, color: Art.color(0xF4FCFF, 0.6), width: 0.8, length: 4...14)
            Art.group(&g, y: 1.8) { inner in
                Art.stroke(&inner, pool, ArtStyle.coolShade.opacity(0.2), width: 1.4)
            }
        }
        Art.stroke(&context, pool, Art.color(0xF2EADA), width: 2.4)
        ArtStyle.contactShadow(&context, 224, 304, 170, 4, alpha: 0.16)
    }

    // MARK: Palms

    /// One arching date-palm frond from (`x`, `y`) along `angle`, drooping toward its tip.
    static func biblioFrond(_ x: CGFloat, _ y: CGFloat, length: CGFloat, angle: CGFloat, width: CGFloat) -> Path {
        let dx: CGFloat = cos(angle)
        let dy: CGFloat = sin(angle)
        let tipX: CGFloat = x + dx * length
        let tipY: CGFloat = y + dy * length + length * 0.45
        let midX: CGFloat = x + dx * length * 0.55
        let midY: CGFloat = y + dy * length * 0.55 - length * 0.12
        var path = Path()
        path.move(to: pt(x, y))
        path.addQuadCurve(to: pt(tipX, tipY), control: pt(midX, midY - width))
        path.addQuadCurve(to: pt(x, y), control: pt(midX, midY + width))
        path.closeSubpath()
        return path
    }

    /// One date palm: a ringed, gently curving trunk and an arching crown.
    static func biblioPalm(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, height: CGFloat, lean: CGFloat, size: CGFloat) {
        let topX: CGFloat = x + lean
        let topY: CGFloat = baseY - height
        let bendX: CGFloat = x + lean * 0.15
        let bendY: CGFloat = baseY - height * 0.5
        var trunk = Path()
        trunk.move(to: pt(x, baseY))
        trunk.addQuadCurve(to: pt(topX, topY), control: pt(bendX, bendY))
        ArtStyle.contactShadow(&context, x + 4, baseY, 10, 1.8, alpha: 0.28)
        Art.stroke(&context, trunk, Art.color(0x7A5E44), width: 3.6)
        Art.group(&context, x: -1) { g in
            Art.stroke(&g, trunk, Art.color(0xE0C090, 0.45), width: 1)
        }
        var rings = Path()
        for index in 1..<12 {
            let t: CGFloat = CGFloat(index) / 12
            let a: CGFloat = (1 - t) * (1 - t)
            let b: CGFloat = 2 * t * (1 - t)
            let c: CGFloat = t * t
            let rx: CGFloat = a * x + b * bendX + c * topX
            let ry: CGFloat = a * baseY + b * bendY + c * topY
            rings.move(to: pt(rx - 1.9, ry))
            rings.addLine(to: pt(rx + 1.9, ry))
        }
        Art.stroke(&context, rings, Art.color(0x5A4434, 0.6), width: 0.6, cap: .butt)

        let angles: [CGFloat] = [-2.95, -2.45, -1.95, -1.5, -1.05, -0.6, -0.15, 2.7, 0.45]
        var fronds = Path()
        var lit = Path()
        for angle in angles {
            fronds.addPath(biblioFrond(topX, topY, length: size, angle: angle, width: size * 0.16))
            if angle < -1.2 {
                lit.addPath(biblioFrond(topX, topY - 0.6, length: size * 0.9, angle: angle, width: size * 0.05))
            }
        }
        Art.fill(&context, fronds, Art.color(0x3E6A3C))
        model(&context, fronds, light: 0.16, shade: 0.2)
        Art.fill(&context, lit, Art.color(0x8CB060, 0.55))
        Art.fill(&context, Art.circle(topX, topY + 1, 2.2), Art.color(0x8A6A3A))
    }

    static func biblioPalms(_ context: inout GraphicsContext) {
        biblioPalm(&context, x: 30, baseY: 312, height: 150, lean: 4, size: 28)
        biblioPalm(&context, x: 54, baseY: 306, height: 118, lean: -6, size: 24)
        biblioPalm(&context, x: 396, baseY: 310, height: 160, lean: 4, size: 28)
        biblioPalm(&context, x: 418, baseY: 316, height: 118, lean: -2, size: 24)
    }

    // MARK: People

    /// A few tiny visitors on the plaza by the pool.
    static func biblioPeople(_ context: inout GraphicsContext) {
        let people: [(CGFloat, CGFloat, UInt32)] = [
            (150, 308, 0xD8604A), (158, 309, 0x2E5E8E), (262, 310, 0xF0E4C8), (290, 307, 0x6A8A3A),
        ]
        for person in people {
            let x: CGFloat = person.0
            let feet: CGFloat = person.1
            ArtStyle.contactShadow(&context, x + 1, feet + 0.3, 3, 0.7, alpha: 0.3)
            let corners: [CGPoint] = [pt(x - 1.5, feet), pt(x + 1.5, feet), pt(x + 1, feet - 5.6), pt(x - 1, feet - 5.6)]
            Art.fill(&context, Art.polygon(corners), Art.color(person.2))
            Art.fill(&context, Art.rect(x - 1.4, feet - 5.2, 0.8, 5), Art.color(0xFFF0D0, 0.35))
            Art.fill(&context, Art.circle(x, feet - 7.1, 1.25), Art.color(0x6A4A3A))
        }
    }

    // MARK: The near plane

    /// Low dark hedges cropped by the two bottom corners.
    static func biblioNear(_ context: inout GraphicsContext) {
        let left = canopy(from: -24, to: 72, baseY: 378, height: 24, bump: 16, depth: 40, seed: 5)
        let right = canopy(from: 360, to: 456, baseY: 372, height: 26, bump: 16, depth: 40, seed: 19)
        Kit.solid(&context, left, stops: Kit.stops(0x2E5A4A, 0x14303A), light: 0.12, shade: 0.2)
        Kit.solid(&context, right, stops: Kit.stops(0x2E5A4A, 0x14303A), light: 0.1, shade: 0.22)
        let anchors: [(CGFloat, CGFloat)] = [(8, 358), (30, 362), (52, 366), (378, 352), (402, 350), (426, 356)]
        var glints = Path()
        for anchor in anchors {
            glints.addPath(leaf(anchor.0, anchor.1, length: 10, width: 2.4, angle: -2.4))
        }
        Art.fill(&context, glints, Art.color(0x7EA67A, 0.45))
    }

    // MARK: Finish

    static func biblioFinish(_ context: inout GraphicsContext) {
        bottomFade(&context, 0x1C3A4A, from: 300, alpha: 0.9)
        tooth(&context, seed: 727, light: 0.06, dark: 0.05)
        finish(&context, wash: 0.10, vignette: 0.10)
    }
}
