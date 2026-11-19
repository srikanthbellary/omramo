import SwiftUI
import OmramoCore

// The Eiffel Tower by day: our own drawing (no photograph, nothing traced). The brown-bronze
// iron tower seen from the Champ de Mars: four splayed feet with the great arch between them,
// the first and second platforms, the long slender upper shaft, the small top and its antenna;
// its lattice drawn as simple criss-cross diagonals clipped to the shape. The trees of the
// Champ de Mars at its feet, a pale far city, a pale blue sky with a few clouds. Never lit at
// night. Card background #2A3A4A.

extension LandmarkArt {
    /// eiffel: the bronze lattice tower over the trees and lawns of the Champ de Mars, by day.
    static func paintEiffel(_ context: inout GraphicsContext) {
        eiffelSky(&context)
        eiffelCity(&context)
        eiffelGround(&context)
        eiffelBackTrees(&context)
        eiffelLegs(&context)
        eiffelMiddle(&context)
        eiffelUpper(&context)
        eiffelPlatforms(&context)
        eiffelTop(&context)
        // Warm sun lying on the iron, from the upper left.
        Art.glow(&context, 176, 150, 160, Art.color(0xFFE6BE), alpha: 0.16)
        eiffelFrontTrees(&context)
        eiffelPeople(&context)
        eiffelNear(&context)
        eiffelFinish(&context)
    }

    // MARK: Iron

    /// Bronze iron in the one light: warm on the left, deeper toward the right.
    static func eiffelIron(_ context: inout GraphicsContext, _ path: Path, from x0: CGFloat, to x1: CGFloat) {
        let stops: [(Color, CGFloat)] = [
            (Art.color(0xB88458), 0),
            (Art.color(0x92603E), 0.5),
            (Art.color(0x684036), 1),
        ]
        fillHorizontal(&context, path, stops, from: x0, to: x1)
    }

    /// The criss-cross lattice inside `shape`: pale gaps where the sky shows through and darker
    /// girders between them, then the shape's own edge girders.
    static func eiffelLattice(_ context: inout GraphicsContext, _ shape: Path, spacing: CGFloat) {
        let box = shape.boundingRect
        let half: CGFloat = spacing / 2
        let shifted = box.offsetBy(dx: half, dy: 0)
        let gaps = diagonals(in: box, spacing: spacing, rising: true)
        let gapsBack = diagonals(in: box, spacing: spacing, rising: false)
        let bars = diagonals(in: shifted, spacing: spacing, rising: true)
        let barsBack = diagonals(in: shifted, spacing: spacing, rising: false)
        Art.clipped(&context, to: shape) { g in
            Art.stroke(&g, gaps, Art.color(0xDCE8F0, 0.34), width: 1.0, cap: .butt)
            Art.stroke(&g, gapsBack, Art.color(0xDCE8F0, 0.34), width: 1.0, cap: .butt)
            Art.stroke(&g, bars, Art.color(0x4E302C, 0.32), width: 0.7, cap: .butt)
            Art.stroke(&g, barsBack, Art.color(0x4E302C, 0.32), width: 0.7, cap: .butt)
        }
        Art.stroke(&context, shape, Art.color(0x5A3A30, 0.7), width: 1.0)
    }

    // MARK: Sky and far city

    static func eiffelSky(_ context: inout GraphicsContext) {
        let sky: [(Color, CGFloat)] = [
            (Art.color(0x6EAEE0), 0),
            (Art.color(0xA6CFEC), 0.35),
            (Art.color(0xDCEAF0), 0.62),
            (Art.color(0xF6EAD2), 0.74),
            (Art.color(0xF6EAD2), 1),
        ]
        backdrop(&context, sky)
        // A few soft clouds, clear of the close button and of the tower's top.
        var clouds = Path()
        clouds.addPath(cloudBand(276, 70, width: 92, height: 18))
        clouds.addPath(cloudBand(346, 112, width: 62, height: 12))
        clouds.addPath(cloudBand(92, 104, width: 70, height: 13))
        clouds.addPath(cloudBand(40, 168, width: 54, height: 10))
        Art.fill(&context, clouds, Art.color(0xFFFFFF, 0.74))
        var undersides = Path()
        undersides.addPath(cloudBand(288, 71, width: 70, height: 5))
        undersides.addPath(cloudBand(104, 105, width: 52, height: 4))
        Art.fill(&context, undersides, Art.color(0xB4C4DA, 0.35))
        Art.glow(&context, 118, 60, 120, Art.color(0xFFF2D8), alpha: 0.22)
    }

    /// The far plane: pale grey-blue roofs and domes of the city along the horizon.
    static func eiffelCity(_ context: inout GraphicsContext) {
        var random = ArtRandom(419)
        var roofs = Path()
        var x: CGFloat = -24
        while x < 456 {
            let w: CGFloat = random.next(in: 10...26)
            let h: CGFloat = random.next(in: 6...16)
            roofs.addRect(CGRect(x: x, y: 286 - h, width: w, height: h + 8))
            x += w
        }
        roofs.addPath(Art.ellipse(84, 270, 9, 8))
        roofs.addRect(CGRect(x: 80, y: 256, width: 8, height: 8))
        roofs.addPath(Art.ellipse(352, 272, 7, 6))
        Art.fill(&context, roofs, Art.color(0xA8B4C4))
        // Mansard roof tops, a shade darker.
        var random2 = ArtRandom(421)
        var tops = Path()
        var tx: CGFloat = -24
        while tx < 456 {
            let w: CGFloat = random2.next(in: 14...30)
            tops.addRect(CGRect(x: tx + 2, y: 278, width: w - 4, height: 2))
            tx += w
        }
        Art.fill(&context, tops, Art.color(0x8A98AC, 0.5))
        haze(&context, top: 250, bottom: 292, hex: 0xF6EAD2, alpha: 0.45)
    }

    // MARK: Ground

    static func eiffelGround(_ context: inout GraphicsContext) {
        let ground = Art.rect(-24, 290, unitWidth + 48, unitHeight - 290 + 24)
        let lawn: [(Color, CGFloat)] = [
            (Art.color(0xB0C880), 0),
            (Art.color(0x84A462), 0.35),
            (Art.color(0x4A6A50), 0.75),
            (Art.color(0x2A3A4A), 1),
        ]
        fillVertical(&context, ground, lawn, from: 290, to: unitHeight)
        horizon(&context, y: 290, rise: 36, hex: 0xFFE4BA, alpha: 0.28)

        // The gravel walks of the Champ de Mars, opening toward the viewer.
        let walks = Art.svg("M150,296 L176,296 L120,404 L60,404 Z M256,296 L282,296 L372,404 L312,404 Z M176,312 L256,312 L262,320 L170,320 Z")
        let gravel: [(Color, CGFloat)] = [
            (Art.color(0xEEDCB8), 0),
            (Art.color(0xC8AE88), 1),
        ]
        fillVertical(&context, walks, gravel, from: 296, to: 404)
        // The tower's long shadow falls away to the lower right.
        let shadow = Art.polygon([pt(200, 298), pt(236, 298), pt(430, 346), pt(400, 352)])
        Art.fill(&context, shadow, ArtStyle.coolShade.opacity(0.1))
    }

    // MARK: Trees

    /// A row of rounded crowns: dark in the body, lit along the top on the upper left.
    static func eiffelTreeRow(_ context: inout GraphicsContext, from x0: CGFloat, to x1: CGFloat, baseY: CGFloat, height: CGFloat, seed: UInt32, dark: UInt32, lit: UInt32) {
        let crowns = canopy(from: x0, to: x1, baseY: baseY, height: height, bump: 22, depth: 12, seed: seed)
        let stops: [(Color, CGFloat)] = [
            (Art.color(lit), 0),
            (Art.color(dark), 1),
        ]
        let top: CGFloat = baseY - height - 10
        fillVertical(&context, crowns, stops, from: top, to: baseY + 12)
        model(&context, crowns, light: 0.16, shade: 0.2)
        var random = ArtRandom(seed &+ 7)
        var dabs = Path()
        let count: Int = Int((x1 - x0) / 9)
        for _ in 0..<max(0, count) {
            let x: CGFloat = x0 + (x1 - x0) * random.next(in: 0...1)
            let y: CGFloat = baseY - height * random.next(in: 0.2...0.9)
            dabs.addEllipse(in: CGRect(x: x - 3, y: y - 2, width: 6, height: 4))
        }
        Art.clipped(&context, to: crowns) { g in
            Art.fill(&g, dabs, Art.color(0xD4E0A4, 0.22))
        }
    }

    static func eiffelBackTrees(_ context: inout GraphicsContext) {
        // Trees beyond the tower, seen through the great arch.
        eiffelTreeRow(&context, from: -24, to: 456, baseY: 292, height: 16, seed: 503, dark: 0x5A7A5A, lit: 0x9AB488)
        haze(&context, top: 270, bottom: 296, hex: 0xF6EAD2, alpha: 0.25)
    }

    static func eiffelFrontTrees(_ context: inout GraphicsContext) {
        // The clipped trees either side of the lawn, hiding the tower's feet.
        eiffelTreeRow(&context, from: -24, to: 150, baseY: 306, height: 30, seed: 509, dark: 0x3E5A44, lit: 0x8AAA6A)
        eiffelTreeRow(&context, from: 282, to: 456, baseY: 306, height: 30, seed: 521, dark: 0x34503E, lit: 0x7E9C62)
        ArtStyle.contactShadow(&context, 60, 312, 90, 4, alpha: 0.24)
        ArtStyle.contactShadow(&context, 372, 312, 90, 4, alpha: 0.26)
    }

    // MARK: The tower

    /// The four splayed feet (two seen from the side), joined under the first platform by the
    /// great arch.
    static func eiffelLegs(_ context: inout GraphicsContext) {
        let legs = Art.svg("M158,228 C150,250 128,270 92,296 L146,296 C150,262 180,244 216,244 C252,244 282,262 286,296 L340,296 C304,270 282,250 274,228 Z")
        ArtStyle.contactShadow(&context, 222, 297, 130, 4, alpha: 0.24)
        eiffelIron(&context, legs, from: 92, to: 340)
        model(&context, legs, light: 0.14, shade: 0.2)
        eiffelLattice(&context, legs, spacing: 6)

        // The girders that run down the middle of each leg, and the great arch itself.
        let girders = Art.svg("M180,228 C170,252 150,274 119,296 M252,228 C262,252 282,274 313,296")
        Art.stroke(&context, girders, Art.color(0x6A4434, 0.7), width: 1.4)
        let arch = Art.svg("M146,296 C150,262 180,244 216,244 C252,244 282,262 286,296")
        Art.stroke(&context, arch, Art.color(0x7A4C38), width: 3)
        let archLit = Art.svg("M147,292 C152,261 181,242.6 216,242.6")
        Art.stroke(&context, archLit, Art.color(0xE0B080, 0.55), width: 1)
        // The feet stand on pale stone piers.
        var piers = Path()
        piers.addRect(CGRect(x: 88, y: 294, width: 62, height: 5))
        piers.addRect(CGRect(x: 282, y: 294, width: 62, height: 5))
        let stone: [(Color, CGFloat)] = [
            (Art.color(0xEEDCC0), 0),
            (Art.color(0xB8A48C), 1),
        ]
        fillHorizontal(&context, piers, stone, from: 88, to: 344)
    }

    /// The section between the first and second platforms: two legs leaning together.
    static func eiffelMiddle(_ context: inout GraphicsContext) {
        let middle = Art.svg("M194,158 L238,158 C240,180 250,204 262,216 L234,216 C230,204 222,186 216,172 C210,186 202,204 198,216 L170,216 C182,204 192,180 194,158 Z")
        eiffelIron(&context, middle, from: 170, to: 262)
        model(&context, middle, light: 0.14, shade: 0.2)
        eiffelLattice(&context, middle, spacing: 5)
        let braces = Art.svg("M186,190 L246,190 M180,204 L252,204")
        Art.clipped(&context, to: middle) { g in
            Art.stroke(&g, braces, Art.color(0x5A3A30, 0.5), width: 0.9, cap: .butt)
        }
    }

    /// The long slender shaft from the second platform up to the top.
    static func eiffelUpper(_ context: inout GraphicsContext) {
        let upper = Art.svg("M210,66 L222,66 C224,100 228,130 234,150 L198,150 C204,130 208,100 210,66 Z")
        eiffelIron(&context, upper, from: 198, to: 234)
        model(&context, upper, light: 0.14, shade: 0.2)
        eiffelLattice(&context, upper, spacing: 4)
        // A pale seam of sky down the middle, where the two faces of the shaft part.
        let seam = Art.polygon([pt(215.2, 96), pt(216.8, 96), pt(220, 150), pt(212, 150)])
        Art.fill(&context, seam, Art.color(0xDCE8F0, 0.3))
        var braces = Path()
        for index in 0..<5 {
            let y: CGFloat = 80 + CGFloat(index) * 15
            braces.move(to: pt(196, y))
            braces.addLine(to: pt(236, y))
        }
        Art.clipped(&context, to: upper) { g in
            Art.stroke(&g, braces, Art.color(0x5A3A30, 0.5), width: 0.8, cap: .butt)
        }
    }

    /// The first and second platforms: decks with railings, lit along the top, the first
    /// with its fringe of small arches.
    static func eiffelPlatforms(_ context: inout GraphicsContext) {
        let first = Art.rect(150, 216, 132, 12)
        eiffelIron(&context, first, from: 150, to: 282)
        model(&context, first, light: 0.16, shade: 0.2)
        var fringe = Path()
        for index in 0..<16 {
            let x: CGFloat = 152 + CGFloat(index) * 8
            fringe.move(to: pt(x, 228))
            fringe.addQuadCurve(to: pt(x + 8, 228), control: pt(x + 4, 220.5))
        }
        Art.stroke(&context, fringe, Art.color(0x5A3A30, 0.6), width: 0.8)
        Art.fill(&context, Art.rect(158, 228, 116, 3), ArtStyle.coolShade.opacity(0.25))

        let second = Art.rect(188, 150, 56, 8)
        eiffelIron(&context, second, from: 188, to: 244)
        model(&context, second, light: 0.16, shade: 0.2)
        Art.fill(&context, Art.rect(194, 158, 44, 2), ArtStyle.coolShade.opacity(0.25))

        // Railings and the sunlit top edges.
        var rails = Path()
        rails.move(to: pt(152, 213))
        rails.addLine(to: pt(280, 213))
        rails.move(to: pt(190, 147.4))
        rails.addLine(to: pt(242, 147.4))
        for index in 0..<17 {
            let x: CGFloat = 152 + CGFloat(index) * 8
            rails.move(to: pt(x, 213))
            rails.addLine(to: pt(x, 216))
        }
        for index in 0..<8 {
            let x: CGFloat = 190 + CGFloat(index) * 7.4
            rails.move(to: pt(x, 147.4))
            rails.addLine(to: pt(x, 150))
        }
        Art.stroke(&context, rails, Art.color(0x6A4434, 0.8), width: 0.7, cap: .butt)
        var lit = Art.line(150, 216.5, 282, 216.5)
        lit.move(to: pt(188, 150.5))
        lit.addLine(to: pt(244, 150.5))
        Art.stroke(&context, lit, Art.color(0xF0C890, 0.75), width: 0.9, cap: .butt)
    }

    /// The small top: the third platform, the lantern above it and the slender antenna.
    static func eiffelTop(_ context: inout GraphicsContext) {
        var top = Path()
        top.addRect(CGRect(x: 208, y: 60, width: 16, height: 6))
        top.addPath(Art.svg("M211,60 L211,52 Q216,45 221,52 L221,60 Z"))
        top.addRect(CGRect(x: 215, y: 32, width: 2, height: 15))
        eiffelIron(&context, top, from: 208, to: 224)
        model(&context, top, light: 0.18, shade: 0.2)
        Art.stroke(&context, Art.line(216, 18, 216, 33), Art.color(0x7A5A4A), width: 1)
        Art.stroke(&context, Art.line(208, 60.5, 224, 60.5), Art.color(0xF0C890, 0.7), width: 0.8, cap: .butt)
        Art.stroke(&context, Art.line(212.4, 59, 212.4, 52.6), Art.color(0xF0C890, 0.5), width: 0.7)
    }

    // MARK: People

    /// A few tiny walkers on the gravel walks, each with a soft shadow.
    static func eiffelPeople(_ context: inout GraphicsContext) {
        let places: [(CGFloat, CGFloat, CGFloat)] = [
            (158, 336, 1), (172, 346, 1.1), (214, 318, 0.85), (268, 336, 1), (300, 354, 1.2),
        ]
        let coats: [UInt32] = [0x3E4A6A, 0x8A3A3A, 0x4A5A3A, 0x6A4A6A, 0x2E5A6A]
        for (index, place) in places.enumerated() {
            let x: CGFloat = place.0
            let y: CGFloat = place.1
            let s: CGFloat = place.2
            ArtStyle.contactShadow(&context, x + 1.5 * s, y, 3.4 * s, 1 * s, alpha: 0.3)
            let shoulder: CGFloat = 1.6 * s
            let hem: CGFloat = 2.2 * s
            let neck: CGFloat = y - 7 * s
            let body = Art.polygon([pt(x - shoulder, neck), pt(x + shoulder, neck), pt(x + hem, y), pt(x - hem, y)])
            let hex: UInt32 = coats[index % coats.count]
            Art.fill(&context, body, Art.color(hex))
            Art.fill(&context, Art.circle(x, y - 8.4 * s, 1.4 * s), Art.color(0xE8C0A0))
            Art.fill(&context, Art.rect(x - 1.6 * s, y - 7 * s, 1 * s, 7 * s), Art.color(0xFFE8C8, 0.3))
        }
    }

    // MARK: The near plane

    /// Dark leaves hanging in at the top right, and a dark shrub at the lower left edge.
    static func eiffelNear(_ context: inout GraphicsContext) {
        cornerSpray(&context, seed: 811, dark: Art.color(0x2A3A30), lit: Art.color(0x8AA070, 0.55))
        let shrub = canopy(from: -24, to: 58, baseY: 396, height: 56, bump: 24, depth: 30, seed: 817)
        let stops: [(Color, CGFloat)] = [
            (Art.color(0x3A5040), 0),
            (Art.color(0x1E2C2C), 1),
        ]
        fillVertical(&context, shrub, stops, from: 330, to: 410)
        model(&context, shrub, light: 0.08, shade: 0.24, rim: 0.4)
    }

    // MARK: Finish

    static func eiffelFinish(_ context: inout GraphicsContext) {
        bottomFade(&context, 0x2A3A4A, from: 300, alpha: 0.9)
        tooth(&context, seed: 823, light: 0.05, dark: 0.04)
        finish(&context, wash: 0.10, vignette: 0.10)
    }
}
