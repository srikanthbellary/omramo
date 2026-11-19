import SwiftUI
import OmramoCore

// The Palace of Knossos by day, as visitors see it: our own drawing (no photograph, nothing
// traced). The restored north entrance: a portico of red Minoan columns, wider at the top than
// at the bottom, with dark cushion capitals, standing on a stone terrace under a flat roof
// with horns of consecration; on the back wall a fresco panel of a charging bull, red-brown on
// pale plaster; broad stone stairs in front, cypresses and olive trees, the hills of Crete
// behind under a bright sun. Card background #5A2A1E.

extension LandmarkArt {
    /// knossos: the red-columned north portico with its charging-bull fresco, the stairs and
    /// the terrace, among cypresses and olives below the hills of Crete, by day.
    static func paintKnossos(_ context: inout GraphicsContext) {
        knossosSky(&context)
        knossosHills(&context)
        knossosGround(&context)
        knossosTrees(&context)
        knossosBackWall(&context)
        knossosFresco(&context)
        knossosWallShadows(&context)
        knossosColumns(&context)
        knossosRoof(&context)
        knossosBastion(&context)
        knossosStairs(&context)
        knossosOlives(&context)
        // Warm sun lying on the portico, from the upper left.
        Art.glow(&context, 170, 150, 170, Art.color(0xFFE6B8), alpha: 0.18)
        knossosNear(&context)
        knossosFinish(&context)
    }

    // MARK: Stone

    /// Pale Cretan limestone in the one light: warm on the left, deeper and cooler on the right.
    static func knossosStone(_ context: inout GraphicsContext, _ path: Path, from x0: CGFloat, to x1: CGFloat) {
        let stops: [(Color, CGFloat)] = [
            (Art.color(0xF6E2BA), 0),
            (Art.color(0xE2C496), 0.5),
            (Art.color(0xBE9A78), 1),
        ]
        fillHorizontal(&context, path, stops, from: x0, to: x1)
    }

    // MARK: Sky and far hills

    static func knossosSky(_ context: inout GraphicsContext) {
        let sky: [(Color, CGFloat)] = [
            (Art.color(0x5DA6DE), 0),
            (Art.color(0x9FCDEB), 0.28),
            (Art.color(0xE4EEE6), 0.48),
            (Art.color(0xFCE8C4), 0.6),
            (Art.color(0xFCE8C4), 1),
        ]
        backdrop(&context, sky)
        // A few small fair-weather clouds, clear of the close button.
        var clouds = Path()
        clouds.addPath(cloudBand(252, 54, width: 72, height: 14))
        clouds.addPath(cloudBand(336, 76, width: 54, height: 10))
        clouds.addPath(cloudBand(124, 64, width: 46, height: 9))
        Art.fill(&context, clouds, Art.color(0xFFFFFF, 0.72))
        var undersides = Path()
        undersides.addPath(cloudBand(262, 55, width: 56, height: 4))
        undersides.addPath(cloudBand(344, 77, width: 40, height: 3))
        Art.fill(&context, undersides, Art.color(0xB8C8DC, 0.35))
    }

    static func knossosHills(_ context: inout GraphicsContext) {
        // The far ridge with the long hump of Mount Juktas on the right.
        let far = Art.svg("M-24,250 L-24,196 C20,186 50,190 80,180 C120,170 160,182 200,176 C250,168 290,150 330,136 C356,128 380,132 404,146 C420,154 440,160 456,164 L456,250 Z")
        let farStops: [(Color, CGFloat)] = [
            (Art.color(0xB4B8B0), 0),
            (Art.color(0xC8C0A8), 1),
        ]
        fillVertical(&context, far, farStops, from: 130, to: 250)
        haze(&context, top: 120, bottom: 250, hex: 0xFCE8C4, alpha: 0.45)

        // The nearer hills, tawny and dotted with olive groves.
        let near = Art.svg("M-24,262 L-24,214 C30,204 70,214 110,206 C170,196 230,210 290,200 C340,192 390,204 456,196 L456,262 Z")
        let nearStops: [(Color, CGFloat)] = [
            (Art.color(0xB8AC78), 0),
            (Art.color(0x9A9A68), 1),
        ]
        fillVertical(&context, near, nearStops, from: 196, to: 262)
        model(&context, near, light: 0.14, shade: 0.12)
        var random = ArtRandom(271)
        var groves = Path()
        for _ in 0..<46 {
            let x: CGFloat = random.next(in: -10...440)
            let y: CGFloat = random.next(in: 214...258)
            let r: CGFloat = random.next(in: 1.6...3.2)
            groves.addEllipse(in: CGRect(x: x - r, y: y - r * 0.7, width: r * 2, height: r * 1.4))
        }
        Art.clipped(&context, to: near) { g in
            Art.fill(&g, groves, Art.color(0x5E6E48, 0.55))
        }
        haze(&context, top: 196, bottom: 262, hex: 0xFCE8C4, alpha: 0.22)
    }

    // MARK: Ground

    static func knossosGround(_ context: inout GraphicsContext) {
        let ground = Art.rect(-24, 262, unitWidth + 48, unitHeight - 262 + 24)
        let earth: [(Color, CGFloat)] = [
            (Art.color(0xEED8B0), 0),
            (Art.color(0xD8B48C), 0.3),
            (Art.color(0x9A5A40), 0.75),
            (Art.color(0x5A2A1E), 1),
        ]
        fillVertical(&context, ground, earth, from: 262, to: unitHeight)
        horizon(&context, y: 262, rise: 40, hex: 0xFFE2B0, alpha: 0.3)

        // The joints of the old paving, opening toward the viewer.
        let joints = Art.svg("M60,276 L420,276 M30,294 L432,294 M0,316 L432,316 M150,264 L120,316 M290,264 L330,316 M96,276 L70,316 M360,276 L396,316")
        Art.stroke(&context, joints, Art.color(0xB08A66, 0.4), width: 0.9)
        // The sunlit patch in front of the stairs.
        let patch = Art.polygon([pt(150, 290), pt(282, 290), pt(316, 332), pt(116, 332)])
        let sun: [(Color, CGFloat)] = [
            (Art.color(0xFFEBC6, 0.4), 0),
            (Art.color(0xFFEBC6, 0), 1),
        ]
        fillVertical(&context, patch, sun, from: 290, to: 332)
        ArtStyle.contactShadow(&context, 222, 264.5, 150, 4, alpha: 0.24)
    }

    // MARK: Trees

    /// A cypress: a tall dark flame from `baseY`, `height` tall and `width` wide.
    static func knossosCypressPath(_ cx: CGFloat, _ baseY: CGFloat, height: CGFloat, width: CGFloat) -> Path {
        let top: CGFloat = baseY - height
        let upper: CGFloat = baseY - height * 0.7
        let lower: CGFloat = baseY - height * 0.3
        let half: CGFloat = width / 2
        var path = Path()
        path.move(to: pt(cx, top))
        path.addCurve(to: pt(cx + half, baseY), control1: pt(cx + half * 1.2, upper), control2: pt(cx + width, lower))
        path.addLine(to: pt(cx - half, baseY))
        path.addCurve(to: pt(cx, top), control1: pt(cx - width, lower), control2: pt(cx - half * 1.2, upper))
        path.closeSubpath()
        return path
    }

    static func knossosCypress(_ context: inout GraphicsContext, _ cx: CGFloat, _ baseY: CGFloat, height: CGFloat, width: CGFloat, seed: UInt32) {
        let shape = knossosCypressPath(cx, baseY, height: height, width: width)
        let green: [(Color, CGFloat)] = [
            (Art.color(0x5E7A44), 0),
            (Art.color(0x3A5634), 0.5),
            (Art.color(0x223A2C), 1),
        ]
        ArtStyle.contactShadow(&context, cx + 4, baseY, width * 0.9, 2.4, alpha: 0.28)
        fillHorizontal(&context, shape, green, from: cx - width, to: cx + width)
        model(&context, shape, light: 0.16, shade: 0.22)
        // Short upward strokes of sunlit foliage on the left.
        var random = ArtRandom(seed)
        var tufts = Path()
        for index in 0..<9 {
            let t: CGFloat = 0.12 + CGFloat(index) * 0.09
            let y: CGFloat = baseY - height * (1 - t)
            let dx: CGFloat = random.next(in: 0.15...0.4) * width
            tufts.move(to: pt(cx - dx, y + 5))
            tufts.addQuadCurve(to: pt(cx - dx * 0.4, y - 3), control: pt(cx - dx * 1.1, y))
        }
        Art.clipped(&context, to: shape) { g in
            Art.stroke(&g, tufts, Art.color(0x9AB070, 0.5), width: 1.2)
        }
    }

    /// An olive tree: a gnarled twin trunk and a clumped, silvery crown.
    static func knossosOlive(_ context: inout GraphicsContext, _ cx: CGFloat, _ baseY: CGFloat, size s: CGFloat, seed: UInt32) {
        ArtStyle.contactShadow(&context, cx + 6, baseY, s * 0.8, 3, alpha: 0.26)
        let crownY: CGFloat = baseY - s * 0.75
        var trunk = Path()
        trunk.move(to: pt(cx - s * 0.08, baseY))
        trunk.addQuadCurve(to: pt(cx - s * 0.22, crownY + s * 0.2), control: pt(cx - s * 0.02, baseY - s * 0.3))
        trunk.addLine(to: pt(cx - s * 0.14, crownY + s * 0.19))
        trunk.addQuadCurve(to: pt(cx + s * 0.02, baseY - s * 0.2), control: pt(cx - s * 0.06, baseY - s * 0.35))
        trunk.addQuadCurve(to: pt(cx + s * 0.2, crownY + s * 0.17), control: pt(cx + s * 0.12, baseY - s * 0.35))
        trunk.addLine(to: pt(cx + s * 0.27, crownY + s * 0.2))
        trunk.addQuadCurve(to: pt(cx + s * 0.1, baseY), control: pt(cx + s * 0.1, baseY - s * 0.3))
        trunk.closeSubpath()
        let bark: [(Color, CGFloat)] = [
            (Art.color(0x9A8268), 0),
            (Art.color(0x5E4A44), 1),
        ]
        fillHorizontal(&context, trunk, bark, from: cx - s * 0.22, to: cx + s * 0.27)

        // The crown: overlapping clumps, lit on their upper left.
        var random = ArtRandom(seed)
        var crown = Path()
        var lit = Path()
        for _ in 0..<10 {
            let x: CGFloat = cx + s * random.next(in: -0.42...0.42)
            let y: CGFloat = crownY + s * random.next(in: -0.16...0.14)
            let r: CGFloat = s * random.next(in: 0.15...0.23)
            crown.addEllipse(in: CGRect(x: x - r, y: y - r * 0.8, width: r * 2, height: r * 1.6))
            let lr: CGFloat = r * 0.6
            let lx: CGFloat = x - r * 0.3
            let ly: CGFloat = y - r * 0.35
            lit.addEllipse(in: CGRect(x: lx - lr, y: ly - lr * 0.7, width: lr * 2, height: lr * 1.4))
        }
        let leaves: [(Color, CGFloat)] = [
            (Art.color(0x8C9C6C), 0),
            (Art.color(0x6A7A56), 0.55),
            (Art.color(0x46523E), 1),
        ]
        fillHorizontal(&context, crown, leaves, from: cx - s * 0.6, to: cx + s * 0.6)
        model(&context, crown, light: 0.14, shade: 0.2)
        Art.clipped(&context, to: crown) { g in
            Art.fill(&g, lit, Art.color(0xC4CEA4, 0.4))
        }
    }

    static func knossosTrees(_ context: inout GraphicsContext) {
        // Cypresses standing behind the terrace, either side of the palace.
        knossosCypress(&context, 30, 262, height: 118, width: 11, seed: 12)
        knossosCypress(&context, 58, 260, height: 170, width: 15, seed: 11)
        knossosCypress(&context, 392, 260, height: 156, width: 14, seed: 13)
        knossosCypress(&context, 414, 262, height: 104, width: 10, seed: 14)
    }

    static func knossosOlives(_ context: inout GraphicsContext) {
        knossosOlive(&context, 34, 280, size: 56, seed: 31)
        knossosOlive(&context, 394, 282, size: 62, seed: 37)
    }

    // MARK: The portico

    /// The plastered back wall of the portico and the two square piers at its ends.
    static func knossosBackWall(_ context: inout GraphicsContext) {
        let wall = Art.rect(94, 118, 244, 108)
        let plaster: [(Color, CGFloat)] = [
            (Art.color(0xF6E0B4), 0),
            (Art.color(0xE8C892), 0.5),
            (Art.color(0xCCA078), 1),
        ]
        fillHorizontal(&context, wall, plaster, from: 94, to: 338)
        // The painted red dado along the foot of the wall.
        let dado = Art.rect(94, 206, 244, 20)
        Art.fill(&context, dado, Art.color(0xB0503E, 0.6))
        let dadoLine = Art.line(94, 206.4, 338, 206.4)
        Art.stroke(&context, dadoLine, Art.color(0x3A2A3A, 0.45), width: 1.2, cap: .butt)
        // The roof keeps the top of the wall in shade.
        let soffit: [(Color, CGFloat)] = [
            (ArtStyle.coolShade.opacity(0.34), 0),
            (ArtStyle.coolShade.opacity(0), 1),
        ]
        fillVertical(&context, Art.rect(94, 118, 244, 22), soffit, from: 118, to: 140)

        // The piers: the left one faces the sun, the right one turns away from it.
        let leftPier = Art.rect(80, 118, 14, 108)
        knossosStone(&context, leftPier, from: 80, to: 94)
        Art.fill(&context, Art.rect(80, 118, 4, 108), Art.color(0xFFF0D0, 0.45))
        let rightPier = Art.rect(338, 118, 14, 108)
        knossosStone(&context, rightPier, from: 338, to: 352)
        Art.fill(&context, rightPier, ArtStyle.coolShade.opacity(0.2))
        var courses = Path()
        for index in 1..<6 {
            let y: CGFloat = 118 + CGFloat(index) * 18
            courses.move(to: pt(80, y))
            courses.addLine(to: pt(94, y))
            courses.move(to: pt(338, y))
            courses.addLine(to: pt(352, y))
        }
        Art.stroke(&context, courses, Art.color(0xA88A6A, 0.45), width: 0.8, cap: .butt)
    }

    /// The fresco panel of the charging bull, set into the back wall between the columns.
    static func knossosFresco(_ context: inout GraphicsContext) {
        Art.fill(&context, Art.rect(180, 136, 72, 60), Art.color(0x34587A))
        Art.fill(&context, Art.rect(183, 139, 66, 54), Art.color(0xD9A04A))
        let field = Art.rect(185, 141, 62, 50)
        let pale: [(Color, CGFloat)] = [
            (Art.color(0xFAEED6), 0),
            (Art.color(0xEAD4AE), 1),
        ]
        fillHorizontal(&context, field, pale, from: 185, to: 247)
        Art.clipped(&context, to: field) { g in
            Art.group(&g, x: 216, y: 168, scale: 0.95) { b in
                LandmarkArt.knossosBull(&b)
            }
        }
        // The panel is set back a little: its top and left inner edges are in shade.
        Art.fill(&context, Art.rect(185, 141, 62, 2.4), ArtStyle.coolShade.opacity(0.18))
        Art.fill(&context, Art.rect(185, 141, 2, 50), ArtStyle.coolShade.opacity(0.14))
    }

    /// The bull in the Minoan manner, in its own space round (0, 0): charging to the left in a
    /// flying gallop, head low, tail up, red-brown with pale patches.
    static func knossosBull(_ context: inout GraphicsContext) {
        let ground = Art.svg("M-36,20 C-24,16 -14,22 -4,18 C6,14 16,20 26,16 L36,16 L36,30 L-36,30 Z")
        Art.fill(&context, ground, Art.color(0x7E9CB0, 0.55))
        let farLegs = Art.svg("M-10,5 L-20,16 L-22.5,16 L-13,3.5 Z M14,5 L26,14 L24,15.5 L11,6 Z")
        Art.fill(&context, farLegs, Art.color(0x7A2E22))

        let body = Art.svg("M-14,-11 C-6,-13 10,-12 18,-9 C22,-8 24,-4 23,0 L31,10 L33,13 L30,14 L19,5 C12,7 2,7 -6,6 L-22,14 L-25,14 L-24,11 L-14,2 C-18,2 -22,4 -26,8 L-30,7 C-31,3 -28,-3 -24,-6 C-21,-9 -18,-11 -14,-11 Z")
        let hide: [(Color, CGFloat)] = [
            (Art.color(0xC65E3E), 0),
            (Art.color(0xA4442E), 0.5),
            (Art.color(0x80301F), 1),
        ]
        fillHorizontal(&context, body, hide, from: -32, to: 33)
        model(&context, body, light: 0.16, shade: 0.18)
        var patches = Path()
        patches.addEllipse(in: CGRect(x: -1, y: -7, width: 10, height: 6))
        patches.addEllipse(in: CGRect(x: -11, y: -4.4, width: 6, height: 4.8))
        patches.addEllipse(in: CGRect(x: 11, y: -2, width: 6, height: 4))
        Art.clipped(&context, to: body) { g in
            Art.fill(&g, patches, Art.color(0xF4E4C4, 0.8))
        }

        let horns = Art.svg("M-23,-6 C-26,-12 -30,-14 -32,-12 M-21,-8 C-22,-14 -25,-17 -28,-17")
        Art.stroke(&context, horns, Art.color(0xF2E2BC), width: ArtStyle.detailLine)
        let tail = Art.svg("M22,-7 C27,-12 28,-18 33,-19")
        Art.stroke(&context, tail, Art.color(0xA4442E), width: 1.4)
        Art.fill(&context, Art.circle(-24.6, -2, 1.1), Art.color(0x3A1E22))
    }

    /// The shadows the columns and the left pier throw onto the back wall, falling right.
    static func knossosWallShadows(_ context: inout GraphicsContext) {
        let wall = Art.rect(94, 118, 244, 108)
        var shadows = Path()
        let xs: [CGFloat] = [118, 160, 272, 314]
        for cx in xs {
            shadows.addPath(Art.polygon([pt(cx + 5, 134), pt(cx + 15, 134), pt(cx + 31, 226), pt(cx + 21, 226)]))
        }
        shadows.addPath(Art.polygon([pt(94, 130), pt(104, 130), pt(122, 226), pt(94, 226)]))
        Art.clipped(&context, to: wall) { g in
            Art.fill(&g, shadows, ArtStyle.coolShade.opacity(0.14))
        }
    }

    static func knossosColumns(_ context: inout GraphicsContext) {
        let xs: [CGFloat] = [118, 160, 272, 314]
        for cx in xs {
            knossosColumn(&context, cx)
        }
    }

    /// One Minoan column: a red shaft wider at the top, a dark cushion capital under a square
    /// abacus, and a low stone base.
    static func knossosColumn(_ context: inout GraphicsContext, _ cx: CGFloat) {
        let shaft = Art.polygon([pt(cx - 7, 132), pt(cx + 7, 132), pt(cx + 5, 222), pt(cx - 5, 222)])
        let red: [(Color, CGFloat)] = [
            (Art.color(0xE0664A), 0),
            (Art.color(0xC0402C), 0.4),
            (Art.color(0x8A2A2C), 1),
        ]
        fillHorizontal(&context, shaft, red, from: cx - 7, to: cx + 7)
        let lit = Art.polygon([pt(cx - 5.4, 132), pt(cx - 2.6, 132), pt(cx - 1.8, 222), pt(cx - 3.8, 222)])
        Art.fill(&context, lit, Art.color(0xFFC8A0, 0.35))
        Art.fill(&context, Art.rect(cx - 7, 132, 14, 4), ArtStyle.coolShade.opacity(0.25))

        let base = Art.rect(cx - 8, 222, 16, 4, radius: 1.5)
        knossosStone(&context, base, from: cx - 8, to: cx + 8)
        ArtStyle.contactShadow(&context, cx + 4, 226, 11, 1.6, alpha: 0.26)

        // The capital: a neck ring, a round cushion and a square slab, all near-black.
        var capital = Path()
        capital.addRect(CGRect(x: cx - 7.5, y: 129.5, width: 15, height: 2.5))
        capital.move(to: pt(cx - 7.5, 130))
        capital.addCurve(to: pt(cx - 10, 122), control1: pt(cx - 11, 128.5), control2: pt(cx - 11.2, 123.5))
        capital.addLine(to: pt(cx + 10, 122))
        capital.addCurve(to: pt(cx + 7.5, 130), control1: pt(cx + 11.2, 123.5), control2: pt(cx + 11, 128.5))
        capital.closeSubpath()
        capital.addRect(CGRect(x: cx - 11, y: 118, width: 22, height: 4))
        let dark: [(Color, CGFloat)] = [
            (Art.color(0x4A3A46), 0),
            (Art.color(0x2E2030), 0.5),
            (Art.color(0x201A2C), 1),
        ]
        fillHorizontal(&context, capital, dark, from: cx - 11, to: cx + 11)
        var shine = Path()
        shine.move(to: pt(cx - 9.4, 123.6))
        shine.addQuadCurve(to: pt(cx - 6.6, 128.4), control: pt(cx - 9.8, 127))
        shine.move(to: pt(cx - 10.4, 118.6))
        shine.addLine(to: pt(cx + 4, 118.6))
        Art.stroke(&context, shine, Art.color(0xB8A0A0, 0.5), width: 0.9)
    }

    /// The flat roof over the portico: a painted edge band, a low parapet and three pairs of
    /// horns of consecration.
    static func knossosRoof(_ context: inout GraphicsContext) {
        let parapet = Art.rect(80, 92, 272, 8)
        knossosStone(&context, parapet, from: 80, to: 352)
        model(&context, parapet, light: 0.16, shade: 0.18)
        let places: [CGFloat] = [140, 216, 292]
        for cx in places {
            Art.group(&context, x: cx, y: 92) { g in
                LandmarkArt.knossosHorns(&g)
            }
        }

        let slab = Art.rect(74, 100, 284, 18)
        let ochre: [(Color, CGFloat)] = [
            (Art.color(0xD0704E), 0),
            (Art.color(0xB0503A), 0.5),
            (Art.color(0x86383A), 1),
        ]
        fillHorizontal(&context, slab, ochre, from: 74, to: 358)
        model(&context, slab, light: 0.16, shade: 0.2)
        Art.fill(&context, Art.rect(74, 104, 284, 3), Art.color(0xF0DDB4, 0.85))
        Art.fill(&context, Art.rect(74, 110, 284, 2.5), Art.color(0x3A2A3A, 0.7))
        Art.stroke(&context, Art.line(74, 100.4, 358, 100.4), Art.color(0xFFE6C4, 0.85), width: 0.9, cap: .butt)
        Art.stroke(&context, Art.line(74, 117.6, 358, 117.6), Art.color(0x5A2A30, 0.5), width: 0.9, cap: .butt)
    }

    /// One pair of horns of consecration standing on (0, 0), in pale stone.
    static func knossosHorns(_ context: inout GraphicsContext) {
        let horns = Art.svg("M-7,0 L-7,-3 C-7,-7 -8,-10 -6,-12 C-5,-8 -3,-5 0,-5 C3,-5 5,-8 6,-12 C8,-10 7,-7 7,-3 L7,0 Z")
        knossosStone(&context, horns, from: -8, to: 8)
        model(&context, horns, light: 0.2, shade: 0.2)
        let edge = Art.svg("M-6,-12 C-5,-8 -3,-5 0,-5")
        Art.stroke(&context, edge, Art.color(0xFFF2D8, 0.7), width: 0.8)
    }

    // MARK: Terrace and stairs

    /// The stone terrace the portico stands on: a lit floor slab over a wall of big blocks.
    static func knossosBastion(_ context: inout GraphicsContext) {
        let floor = Art.rect(72, 226, 288, 5)
        knossosStone(&context, floor, from: 72, to: 360)
        Art.stroke(&context, Art.line(72, 226.4, 360, 226.4), Art.color(0xFFF2D8, 0.85), width: 0.9, cap: .butt)

        let wall = Art.rect(74, 231, 284, 33)
        knossosStone(&context, wall, from: 74, to: 358)
        model(&context, wall, light: 0.14, shade: 0.2)
        Art.fill(&context, Art.rect(74, 231, 284, 3), ArtStyle.coolShade.opacity(0.2))

        var joints = Path()
        var tops = Path()
        for row in 0..<3 {
            let y0: CGFloat = 231 + CGFloat(row) * 11
            let offset: CGFloat = row % 2 == 0 ? 0 : 18
            joints.move(to: pt(74, y0))
            joints.addLine(to: pt(358, y0))
            tops.move(to: pt(74, y0 + 1))
            tops.addLine(to: pt(358, y0 + 1))
            var x: CGFloat = 86 + offset
            while x < 358 {
                joints.move(to: pt(x, y0))
                joints.addLine(to: pt(x, y0 + 11))
                x += 36
            }
        }
        Art.clipped(&context, to: wall) { g in
            Art.stroke(&g, joints, Art.color(0xA88A6A, 0.45), width: 0.8, cap: .butt)
            Art.stroke(&g, tops, Art.color(0xFFF0D0, 0.3), width: 0.7, cap: .butt)
        }
    }

    /// The broad stairs coming down from the terrace toward the viewer, between low cheek walls.
    static func knossosStairs(_ context: inout GraphicsContext) {
        let rise: CGFloat = 8.4
        for index in 0..<7 {
            let i: CGFloat = CGFloat(index)
            let top: CGFloat = 231 + i * rise
            let half: CGFloat = 40 + i * 1.6
            let left: CGFloat = 216 - half
            let width: CGFloat = half * 2
            let riser = Art.rect(left, top, width, rise)
            knossosStone(&context, riser, from: left, to: left + width)
            Art.fill(&context, riser, ArtStyle.coolShade.opacity(0.1))
            Art.fill(&context, Art.rect(left, top, width, 2.6), Art.color(0xFFF0D2, 0.75))
        }
        // The right-hand end of each step is turned from the sun.
        let shade = Art.polygon([pt(244, 231), pt(256, 231), pt(266, 290), pt(252, 290)])
        Art.fill(&context, shade, ArtStyle.coolShade.opacity(0.12))

        let leftCheek = Art.polygon([pt(168, 226), pt(177, 226), pt(166.4, 290), pt(157, 290)])
        knossosStone(&context, leftCheek, from: 157, to: 177)
        Art.fill(&context, leftCheek, Art.color(0xFFF0D0, 0.2))
        let rightCheek = Art.polygon([pt(255, 226), pt(264, 226), pt(275, 290), pt(265.6, 290)])
        knossosStone(&context, rightCheek, from: 255, to: 275)
        Art.fill(&context, rightCheek, ArtStyle.coolShade.opacity(0.24))
        let rims = Art.svg("M168,226.4 L177,226.4 M255,226.4 L264,226.4 M168,226.4 L157,290")
        Art.stroke(&context, rims, Art.color(0xFFF2D8, 0.7), width: 0.9)
        ArtStyle.contactShadow(&context, 222, 290.5, 64, 3, alpha: 0.22)
    }

    // MARK: The near plane

    /// A fallen palace block at the lower left and dark olive leaves hanging in at the right.
    static func knossosNear(_ context: inout GraphicsContext) {
        let block = Art.svg("M-24,428 L-24,338 C-4,330 24,332 46,340 C62,346 74,360 78,380 C82,396 80,412 84,428 Z")
        let rock: [(Color, CGFloat)] = [
            (Art.color(0x8A5A40), 0),
            (Art.color(0x3E2018), 1),
        ]
        fillVertical(&context, block, rock, from: 332, to: 420)
        model(&context, block, light: 0.08, shade: 0.24)
        let blockEdge = Art.svg("M-24,338 C-4,330 24,332 46,340")
        Art.stroke(&context, blockEdge, Art.color(0xD8A880, 0.5), width: 1.4)

        let twigs = Art.svg("M446,330 C420,340 404,356 392,380 M446,372 C428,380 416,392 410,410")
        Art.stroke(&context, twigs, Art.color(0x2E3A26), width: ArtStyle.contourLine)
        let anchors: [(CGFloat, CGFloat)] = [
            (436, 334), (424, 340), (412, 348), (402, 360), (394, 374),
            (438, 376), (426, 384), (416, 396), (410, 410),
        ]
        var random = ArtRandom(733)
        var leaves = Path()
        var glints = Path()
        for anchor in anchors {
            for side in 0..<2 {
                let base: CGFloat = side == 0 ? 1.9 : 2.8
                let angle: CGFloat = base + random.next(in: -0.35...0.35)
                let length: CGFloat = random.next(in: 14...22)
                leaves.addPath(leaf(anchor.0, anchor.1, length: length, width: length * 0.22, angle: angle))
                if side == 1 {
                    glints.addPath(leaf(anchor.0 - 1, anchor.1 - 0.6, length: length * 0.8, width: length * 0.07, angle: angle + 0.1))
                }
            }
        }
        Art.fill(&context, leaves, Art.color(0x2E3A26))
        Art.fill(&context, glints, Art.color(0x8A9A6A, 0.6))
    }

    // MARK: Finish

    static func knossosFinish(_ context: inout GraphicsContext) {
        bottomFade(&context, 0x5A2A1E, from: 300, alpha: 0.9)
        tooth(&context, seed: 719, light: 0.05, dark: 0.04)
        finish(&context, wash: 0.10, vignette: 0.10)
    }
}
