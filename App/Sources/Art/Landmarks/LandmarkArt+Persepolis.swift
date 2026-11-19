import SwiftUI
import OmramoCore

// Persepolis by day: our own drawing (no photograph, nothing traced).
// The stone terrace below the bare tawny hills: in the middle, the two great piers of a
// gateway, each carved with a winged bull guardian; tall slender fluted columns stand on
// either side (two still carry their double-bull capitals, two are broken off), smaller far
// columns show through the gateway, and in front the broad double stairway rises, its side
// panels carved with rows of small walking figures in low relief. Card background #4A2E1C.

extension LandmarkArt {
    /// persepolis: the gateway with its winged bulls, tall columns whole and broken, and the
    /// carved double stairway of the terrace below bare hills, in warm daylight.
    static func paintPersepolis(_ context: inout GraphicsContext) {
        persepolisSky(&context)
        persepolisHills(&context)
        persepolisFarColumns(&context)
        persepolisGround(&context)
        persepolisTerrace(&context)
        persepolisStairs(&context)
        persepolisGateway(&context)
        persepolisColumns(&context)
        // Warm light lying on the stone, from the upper left.
        Art.glow(&context, 170, 170, 160, Art.color(0xFFE6BC), alpha: 0.18)
        persepolisVisitors(&context)
        persepolisNear(&context)
        persepolisFinish(&context)
    }

    // MARK: Stone

    /// Pale limestone in the one light: warm cream on the left, deeper tawny grey to the right.
    static func persepolisStone(_ context: inout GraphicsContext, _ path: Path, from x0: CGFloat, to x1: CGFloat) {
        let stops: [(Color, CGFloat)] = [
            (Art.color(0xF0DCB8), 0),
            (Art.color(0xD4B58C), 0.45),
            (Art.color(0xA88866), 1),
        ]
        fillHorizontal(&context, path, stops, from: x0, to: x1)
    }

    /// An SVG shape drawn about its own origin, moved to (`x`, `y`), scaled, and mirrored left
    /// to right when `flip` is -1. Built as a path so the light stays on the upper left.
    static func persepolisPlace(_ data: String, x: CGFloat, y: CGFloat, scale: CGFloat, flip: CGFloat) -> Path {
        let sx: CGFloat = scale * flip
        let transform = CGAffineTransform(a: sx, b: 0, c: 0, d: scale, tx: x, ty: y)
        return Art.svg(data).applying(transform)
    }

    // MARK: Sky and hills

    static func persepolisSky(_ context: inout GraphicsContext) {
        let sky: [(Color, CGFloat)] = [
            (Art.color(0x8FC0E0), 0),
            (Art.color(0xC9E0EA), 0.18),
            (Art.color(0xF8E6C8), 0.42),
            (Art.color(0xF6DFBA), 1),
        ]
        backdrop(&context, sky)
        Art.glow(&context, 120, 70, 160, Art.color(0xFFF4DC), alpha: 0.4)
        let cloudHigh = cloudBand(240, 52, width: 140, height: 14)
        Art.fill(&context, cloudHigh, Art.color(0xFFFFFF, 0.4))
        let cloudLow = cloudBand(330, 84, width: 90, height: 9)
        Art.fill(&context, cloudLow, Art.color(0xFFFFFF, 0.3))
    }

    /// The far plane: the bare tawny mountain behind the terrace and a nearer, lower ridge.
    static func persepolisHills(_ context: inout GraphicsContext) {
        let far = Art.svg("M-24,262 L-24,172 C20,160 50,142 90,138 C130,134 150,112 190,104 C230,96 260,122 300,118 C340,114 380,96 420,100 C440,102 450,110 456,114 L456,262 Z")
        let farStops: [(Color, CGFloat)] = [
            (Art.color(0xE2B88E), 0),
            (Art.color(0xCC9A70), 1),
        ]
        fillVertical(&context, far, farStops, from: 96, to: 262)
        model(&context, far, light: 0.16, shade: 0.12)
        // Dry gullies running down the bare slopes, lit on one side.
        let gullies = Art.svg("M96,140 C100,160 94,180 102,206 M150,118 C146,140 156,166 150,196 M196,106 C200,130 192,156 200,186 M262,118 C258,140 266,168 260,198 M330,112 C334,136 326,160 334,190 M396,100 C392,124 400,150 394,180")
        let ridgesLit = Art.svg("M92,140 C96,160 90,180 98,206 M192,106 C196,130 188,156 196,186 M326,112 C330,136 322,160 330,190")
        Art.clipped(&context, to: far) { g in
            Art.stroke(&g, gullies, Art.color(0xA87450, 0.35), width: 1.6)
            Art.stroke(&g, ridgesLit, Art.color(0xFFE6C0, 0.35), width: 1.4)
        }
        haze(&context, top: 90, bottom: 262, hex: 0xF6DFBA, alpha: 0.42)

        let near = Art.svg("M-24,262 L-24,214 C40,204 90,222 150,214 C200,208 240,226 300,220 C360,214 410,226 456,218 L456,262 Z")
        let nearStops: [(Color, CGFloat)] = [
            (Art.color(0xC9946A), 0),
            (Art.color(0xB58058), 1),
        ]
        fillVertical(&context, near, nearStops, from: 206, to: 262)
        haze(&context, top: 200, bottom: 262, hex: 0xF6DFBA, alpha: 0.25)
    }

    /// Small far columns of the halls behind, standing in the haze.
    static func persepolisFarColumns(_ context: inout GraphicsContext) {
        let places: [(CGFloat, CGFloat)] = [(40, 168), (60, 176), (206, 150), (226, 156), (376, 164), (398, 172)]
        for place in places {
            persepolisColumn(&context, cx: place.0, base: 252, top: place.1, width: 5, whole: true)
        }
        haze(&context, top: 120, bottom: 256, hex: 0xF6DFBA, alpha: 0.4)
    }

    // MARK: Ground

    static func persepolisGround(_ context: inout GraphicsContext) {
        let ground = Art.rect(-24, 250, unitWidth + 48, unitHeight - 250 + 24)
        let dust: [(Color, CGFloat)] = [
            (Art.color(0xEED2A6), 0),
            (Art.color(0xDDB486), 0.35),
            (Art.color(0x8E5E3C), 0.75),
            (Art.color(0x4A2E1C), 1),
        ]
        fillVertical(&context, ground, dust, from: 250, to: unitHeight)
        horizon(&context, y: 254, rise: 40, hex: 0xFFE2B0, alpha: 0.3)
        Kit.rippleMarks(&context, x0: 30, x1: 400, y0: 318, y1: 360, count: 14, seed: 83, color: Art.color(0xA87450), alpha: 0.26)
        ArtStyle.contactShadow(&context, 216, 313, 170, 6, alpha: 0.26)
    }

    // MARK: The terrace and its carved stairway

    /// The small walking figure of the reliefs, facing right, its feet at the origin.
    static func persepolisFigureData() -> String {
        "M-2.4,0 L-1.8,-7 C-2.2,-8.5 -2,-10 -1.2,-10.6 L-0.8,-12 C-1.2,-13 -0.8,-14.4 0.4,-14.6 L0.4,-16.4 L2.2,-16.4 L2.2,-14.4 C2.8,-14 3,-13 2.6,-12 L2.4,-10.4 L3.4,-8 L2.6,-7.6 L2.2,-6.6 L2.8,0 Z"
    }

    /// The front of the stone terrace: its pale top, the wall with a band of rosettes, and two
    /// registers of figures walking toward the stairs on each side.
    static func persepolisTerrace(_ context: inout GraphicsContext) {
        let topCorners: [CGPoint] = [pt(66, 254), pt(366, 254), pt(372, 266), pt(60, 266)]
        let topStops: [(Color, CGFloat)] = [
            (Art.color(0xF4E2C2), 0),
            (Art.color(0xE2C79E), 1),
        ]
        fillVertical(&context, Art.polygon(topCorners), topStops, from: 254, to: 266)
        let wall = Art.rect(60, 266, 312, 46)
        persepolisStone(&context, wall, from: 60, to: 372)
        model(&context, wall, light: 0.12, shade: 0.18)
        Art.stroke(&context, Art.line(60, 266.4, 372, 266.4), Art.color(0xFFF0D4, 0.8), width: 1, cap: .butt)
        Art.fill(&context, Art.rect(60, 267, 312, 2.4), ArtStyle.coolShade.opacity(0.12))

        // The band of small rosettes along the top of the wall.
        var rosettes = Path()
        var x: CGFloat = 66
        while x < 368 {
            rosettes.addEllipse(in: CGRect(x: x - 1.3, y: 269.6, width: 2.6, height: 2.6))
            x += 7
        }
        Art.fill(&context, rosettes, Art.color(0x9E8062, 0.4))
        // The joints of the big blocks, and the line between the two registers.
        let joints = Art.svg("M60,290.5 L372,290.5 M96,290.5 L96,312 M336,290.5 L336,312 M60,274 L60,312 M372,274 L372,312")
        Art.stroke(&context, joints, Art.color(0x8E6E50, 0.35), width: 0.7, cap: .butt)

        persepolisProcession(&context, x0: 62, x1: 130, baseY: 288.5, facing: 1)
        persepolisProcession(&context, x0: 62, x1: 130, baseY: 309.5, facing: 1)
        persepolisProcession(&context, x0: 302, x1: 370, baseY: 288.5, facing: -1)
        persepolisProcession(&context, x0: 302, x1: 370, baseY: 309.5, facing: -1)
    }

    /// One register of small figures in low relief, walking in step: each a pale figure with
    /// its carved shadow down and to the right.
    static func persepolisProcession(_ context: inout GraphicsContext, x0: CGFloat, x1: CGFloat, baseY: CGFloat, facing: CGFloat) {
        let figure: String = persepolisFigureData()
        var shadows = Path()
        var bodies = Path()
        var x: CGFloat = x0 + 5
        while x < x1 - 3 {
            shadows.addPath(persepolisPlace(figure, x: x + 0.7, y: baseY + 0.7, scale: 0.88, flip: facing))
            bodies.addPath(persepolisPlace(figure, x: x, y: baseY, scale: 0.88, flip: facing))
            x += 8
        }
        Art.fill(&context, shadows, ArtStyle.coolShade.opacity(0.26))
        Art.fill(&context, bodies, Art.color(0xE8D0A8))
    }

    /// The double stairway in the middle of the terrace: two flights rising toward each other,
    /// their sides carved with figures climbing, stepped battlements along their parapets, and
    /// a middle panel with two guards and a rosette.
    static func persepolisStairs(_ context: inout GraphicsContext) {
        // The stairway stands out from the wall and throws a little shade to its right.
        let castCorners: [CGPoint] = [pt(302, 312), pt(232, 266), pt(239, 266), pt(309, 312)]
        Art.fill(&context, Art.polygon(castCorners), ArtStyle.coolShade.opacity(0.18))

        let leftCorners: [CGPoint] = [pt(130, 312), pt(200, 312), pt(200, 266)]
        let rightCorners: [CGPoint] = [pt(302, 312), pt(232, 312), pt(232, 266)]
        let left = Art.polygon(leftCorners)
        let right = Art.polygon(rightCorners)
        let middle = Art.rect(200, 264, 32, 48)
        persepolisStone(&context, left, from: 130, to: 302)
        persepolisStone(&context, middle, from: 130, to: 302)
        persepolisStone(&context, right, from: 130, to: 302)
        Art.fill(&context, left, Art.color(0xFFF0D4, 0.16))
        Art.fill(&context, right, ArtStyle.coolShade.opacity(0.06))
        var edges = Art.line(200, 266, 200, 312)
        edges.move(to: pt(232, 266))
        edges.addLine(to: pt(232, 312))
        Art.stroke(&context, edges, Art.color(0x8E6E50, 0.4), width: 0.8, cap: .butt)

        Art.clipped(&context, to: left) { g in
            persepolisClimbers(&g, fromX: 130, toX: 200, facing: 1)
        }
        Art.clipped(&context, to: right) { g in
            persepolisClimbers(&g, fromX: 302, toX: 232, facing: -1)
        }
        persepolisMerlons(&context, fromX: 130, toX: 200)
        persepolisMerlons(&context, fromX: 302, toX: 232)

        // The middle panel: two guards facing each other below a rosette.
        let figure: String = persepolisFigureData()
        var guards = persepolisPlace(figure, x: 207, y: 307, scale: 1.5, flip: 1)
        guards.addPath(persepolisPlace(figure, x: 225, y: 307, scale: 1.5, flip: -1))
        let guardShade = guards.applying(CGAffineTransform(translationX: 0.8, y: 0.8))
        Art.fill(&context, guardShade, ArtStyle.coolShade.opacity(0.26))
        Art.fill(&context, guards, Art.color(0xE8D0A8))
        var petals = Path()
        for index in 0..<8 {
            let angle: CGFloat = CGFloat(index) * CGFloat.pi / 4
            petals.addPath(leaf(216, 273, length: 4.4, width: 1.4, angle: angle))
        }
        Art.fill(&context, petals, Art.color(0x9E8062, 0.5))
        Art.fill(&context, Art.circle(216, 273, 1.2), Art.color(0xF4E2C2))
    }

    /// Figures climbing the side of one flight, each standing a little higher than the last.
    /// The flight rises from its foot at `fromX` (y 312) to its top at `toX` (y 266).
    static func persepolisClimbers(_ context: inout GraphicsContext, fromX: CGFloat, toX: CGFloat, facing: CGFloat) {
        let figure: String = persepolisFigureData()
        let run: CGFloat = toX - fromX
        var shadows = Path()
        var bodies = Path()
        var t: CGFloat = 0.3
        while t < 0.97 {
            let x: CGFloat = fromX + run * t
            let slopeY: CGFloat = 312 - 46 * t
            let footY: CGFloat = slopeY + 21
            if footY < 310 {
                shadows.addPath(persepolisPlace(figure, x: x + 0.7, y: footY + 0.7, scale: 0.88, flip: facing))
                bodies.addPath(persepolisPlace(figure, x: x, y: footY, scale: 0.88, flip: facing))
            }
            t += 0.115
        }
        Art.fill(&context, shadows, ArtStyle.coolShade.opacity(0.26))
        Art.fill(&context, bodies, Art.color(0xEAD4AE))
    }

    /// The parapet along the slope of one flight: a lit stone edge with small stepped
    /// battlements standing on it.
    static func persepolisMerlons(_ context: inout GraphicsContext, fromX: CGFloat, toX: CGFloat) {
        let run: CGFloat = toX - fromX
        var teeth = Path()
        var t: CGFloat = 0.06
        while t < 0.98 {
            let x: CGFloat = fromX + run * t
            let y: CGFloat = 312 - 46 * t
            let corners: [CGPoint] = [
                pt(x - 3, y + 1), pt(x - 3, y - 2), pt(x - 1.5, y - 2), pt(x - 1.5, y - 4),
                pt(x + 1.5, y - 4), pt(x + 1.5, y - 2), pt(x + 3, y - 2), pt(x + 3, y + 1),
            ]
            teeth.addPath(Art.polygon(corners))
            t += 0.105
        }
        persepolisStone(&context, teeth, from: 130, to: 302)
        Art.fill(&context, teeth, Art.color(0xFFF0D4, 0.2))
        let slope = Art.line(fromX, 312, toX, 266)
        Art.stroke(&context, slope, Art.color(0xFFF0D4, 0.75), width: 1.6)
    }

    // MARK: The gateway

    static func persepolisGateway(_ context: inout GraphicsContext) {
        persepolisPier(&context, x0: 148, x1: 196, top: 112)
        persepolisPier(&context, x0: 236, x1: 284, top: 116)
        persepolisBull(&context, x: 172, y: 256, flip: 1)
        persepolisBull(&context, x: 260, y: 256, flip: -1)
    }

    /// One great stone pier of the gateway, its top broken and weathered.
    static func persepolisPier(_ context: inout GraphicsContext, x0: CGFloat, x1: CGFloat, top: CGFloat) {
        let base: CGFloat = 258
        let w: CGFloat = x1 - x0
        let shadowX: CGFloat = x0 + w * 0.5 + 4
        ArtStyle.contactShadow(&context, shadowX, base, w * 0.7, 3, alpha: 0.28)
        let corners: [CGPoint] = [
            pt(x0, base), pt(x0, top + 6), pt(x0 + w * 0.3, top), pt(x0 + w * 0.55, top + 5),
            pt(x0 + w * 0.8, top + 2), pt(x1, top + 8), pt(x1, base),
        ]
        let block = Art.polygon(corners)
        persepolisStone(&context, block, from: x0, to: x1)
        model(&context, block, light: 0.18, shade: 0.2, rim: 0.5)
        // The courses of the masonry, and the shaded right side of the pier.
        var joints = Path()
        var y: CGFloat = top + 20
        while y < base - 4 {
            joints.move(to: pt(x0, y))
            joints.addLine(to: pt(x1, y))
            y += 22
        }
        let sideW: CGFloat = w * 0.2
        let side = Art.rect(x1 - sideW, top, sideW, base - top)
        Art.clipped(&context, to: block) { g in
            Art.stroke(&g, joints, Art.color(0x8E6E50, 0.3), width: 0.7, cap: .butt)
            Art.fill(&g, side, ArtStyle.coolShade.opacity(0.16))
        }
    }

    /// A winged bull guardian carved on a pier, simplified: a crowned, bearded head, a great
    /// wing swept up and back, a strong body on four legs. `flip` -1 makes it face right.
    static func persepolisBull(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, flip: CGFloat) {
        let bodyData = "M-16,-40 C-18,-32 -17,-24 -14,-20 L-14,0 L-9,0 L-9,-18 L9,-18 L10,0 L15,0 L15,-16 C18,-20 19,-28 18,-36 C16,-40 10,-42 4,-42 L-8,-42 Z"
        let headData = "M-11,-40 L-20,-40 C-23,-42 -23,-46 -22,-48 L-22,-54 C-22,-57 -19,-58 -16,-58 L-13,-58 L-10,-50 Z M-22,-58 L-21.5,-66 L-13.5,-66 L-13,-58 Z"
        let wingData = "M-8,-42 C-4,-52 4,-62 20,-70 C21,-62 18,-52 12,-44 Z"
        let detailData = "M-21,-46 L-14,-46 M-21,-43 L-14,-43 M-21,-62 L-14,-62 M-4,-46 L15,-61 M-1,-44 L17,-55 M3,-43 L16,-49 M-14,-6 L-9,-6 M10,-6 L15,-6"
        let torso = persepolisPlace(bodyData, x: x, y: y, scale: 1, flip: flip)
        let head = persepolisPlace(headData, x: x, y: y, scale: 1, flip: flip)
        let wing = persepolisPlace(wingData, x: x, y: y, scale: 1, flip: flip)
        let details = persepolisPlace(detailData, x: x, y: y, scale: 1, flip: flip)
        var whole = Path()
        whole.addPath(torso)
        whole.addPath(head)
        whole.addPath(wing)

        // The carving stands out of the pier: its shadow falls down and to the right.
        let carvedShade = whole.applying(CGAffineTransform(translationX: 1.8, y: 1.8))
        Art.fill(&context, carvedShade, ArtStyle.coolShade.opacity(0.3))
        let x0: CGFloat = x - 24
        let x1: CGFloat = x + 24
        persepolisStone(&context, wing, from: x0, to: x1)
        persepolisStone(&context, torso, from: x0, to: x1)
        persepolisStone(&context, head, from: x0, to: x1)
        Art.fill(&context, whole, Art.color(0xFFF0D4, 0.12))
        model(&context, whole, light: 0.22, shade: 0.2, rim: 0.6)
        Art.stroke(&context, details, Art.color(0x8E6E50, 0.55), width: 0.8)

        // A calm eye in the bearded face.
        let eyeX: CGFloat = x - 18 * flip
        Art.fill(&context, Art.ellipse(eyeX, y - 52, 1.1, 0.8), Art.color(0x7A5A40))
    }

    // MARK: Columns

    static func persepolisColumns(_ context: inout GraphicsContext) {
        persepolisColumn(&context, cx: 92, base: 258, top: 98, width: 9, whole: true)
        persepolisColumn(&context, cx: 122, base: 258, top: 172, width: 9, whole: false)
        persepolisColumn(&context, cx: 314, base: 258, top: 102, width: 9, whole: true)
        persepolisColumn(&context, cx: 346, base: 258, top: 150, width: 9, whole: false)
    }

    /// One tall slender fluted column on its bell-shaped base. A whole one carries a capital;
    /// a broken one ends in a jagged top.
    static func persepolisColumn(_ context: inout GraphicsContext, cx: CGFloat, base: CGFloat, top: CGFloat, width: CGFloat, whole: Bool) {
        let half: CGFloat = width / 2
        let height: CGFloat = base - top
        let scale: CGFloat = width / 9
        ArtStyle.contactShadow(&context, cx + 3 * scale, base, 10 * scale, 2 * scale, alpha: 0.26)
        let shaft: Path
        if whole {
            shaft = Art.rect(cx - half, top, width, height)
        } else {
            let corners: [CGPoint] = [
                pt(cx - half, base), pt(cx - half, top + 3), pt(cx - half * 0.3, top - 2),
                pt(cx + half * 0.2, top + 4), pt(cx + half, top + 1), pt(cx + half, base),
            ]
            shaft = Art.polygon(corners)
        }
        persepolisStone(&context, shaft, from: cx - half, to: cx + half)
        // Flutes, the lit left of the shaft and its shaded right.
        var flutes = Path()
        let offsets: [CGFloat] = [-0.4, -0.13, 0.13, 0.4]
        for offset in offsets {
            let fx: CGFloat = cx + width * offset
            flutes.move(to: pt(fx, top + 4))
            flutes.addLine(to: pt(fx, base - 8 * scale))
        }
        let litW: CGFloat = width * 0.3
        let shadeW: CGFloat = half * 0.7
        let litStrip = Art.rect(cx - half, top - 4, litW, height + 4)
        let shadeStrip = Art.rect(cx + half - shadeW, top - 4, shadeW, height + 4)
        Art.clipped(&context, to: shaft) { g in
            Art.stroke(&g, flutes, Art.color(0x9E8062, 0.45), width: 0.6 * scale)
            Art.fill(&g, litStrip, Art.color(0xFFF0D4, 0.38))
            Art.fill(&g, shadeStrip, ArtStyle.coolShade.opacity(0.18))
        }

        // The bell-shaped base with its round moulding.
        let footData = "M-8,0 L8,0 L7,-2 C6,-5 4,-7 4.5,-9 L-4.5,-9 C-4,-7 -6,-5 -7,-2 Z M-5.5,-11 L5.5,-11 L5.5,-9 L-5.5,-9 Z"
        let foot = persepolisPlace(footData, x: cx, y: base, scale: scale, flip: 1)
        persepolisStone(&context, foot, from: cx - 8 * scale, to: cx + 8 * scale)
        model(&context, foot, light: 0.2, shade: 0.2)
        if whole {
            persepolisCapital(&context, cx: cx, y: top, scale: scale)
        }
    }

    /// The tall capital of a whole column: a flared bell, a block with paired scrolls, and
    /// two bull foreparts kneeling back to back, the saddle between them for the roof beam.
    static func persepolisCapital(_ context: inout GraphicsContext, cx: CGFloat, y: CGFloat, scale: CGFloat) {
        let bellData = "M-3.5,0 C-4,-4 -6,-7 -7,-10 L7,-10 C6,-7 4,-4 3.5,0 Z M-5,-10 L5,-10 L5,-20 L-5,-20 Z"
        let bullsData = "M0,-20 L-12,-20 L-13,-17 L-16,-17 L-16,-20 L-17,-22 C-19,-23 -21,-25 -20,-28 L-18,-31 L-17,-35 L-15,-31 C-12,-31 -8,-30 -4,-28 L0,-28 Z M0,-20 L12,-20 L13,-17 L16,-17 L16,-20 L17,-22 C19,-23 21,-25 20,-28 L18,-31 L17,-35 L15,-31 C12,-31 8,-30 4,-28 L0,-28 Z"
        let scrollData = "M-5,-13 C-8,-13 -8,-17 -5,-17 M5,-13 C8,-13 8,-17 5,-17 M-14,-24 L-9,-24 M14,-24 L9,-24"
        let bell = persepolisPlace(bellData, x: cx, y: y, scale: scale, flip: 1)
        let bulls = persepolisPlace(bullsData, x: cx, y: y, scale: scale, flip: 1)
        let scrolls = persepolisPlace(scrollData, x: cx, y: y, scale: scale, flip: 1)
        let span: CGFloat = 20 * scale
        persepolisStone(&context, bell, from: cx - span, to: cx + span)
        model(&context, bell, light: 0.2, shade: 0.2)
        persepolisStone(&context, bulls, from: cx - span, to: cx + span)
        model(&context, bulls, light: 0.22, shade: 0.22, rim: 0.6)
        Art.stroke(&context, scrolls, Art.color(0x8E6E50, 0.55), width: 0.8 * scale)
        let eyes = Art.svg("M-17.6,-28.6 L-17,-28.6 M17,-28.6 L17.6,-28.6")
        let placedEyes = eyes.applying(CGAffineTransform(a: scale, b: 0, c: 0, d: scale, tx: cx, ty: y))
        Art.stroke(&context, placedEyes, Art.color(0x7A5A40), width: 0.9 * scale)
    }

    // MARK: Visitors

    /// A few tiny visitors: one in the gateway, the rest on the ground before the terrace.
    static func persepolisVisitors(_ context: inout GraphicsContext) {
        let people: [(CGFloat, CGFloat, UInt32, CGFloat)] = [
            (214, 257, 0x3E5A8A, 0.9), (48, 334, 0xC8563A, 1), (64, 338, 0xE0B040, 0.9),
            (262, 328, 0x2E7A6A, 1), (384, 340, 0x6A4A90, 1.05),
        ]
        for person in people {
            persepolisVisitor(&context, x: person.0, y: person.1, coat: person.2, scale: person.3)
        }
    }

    /// One tiny standing person, about three heads tall.
    static func persepolisVisitor(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, coat: UInt32, scale: CGFloat) {
        let s: CGFloat = scale
        ArtStyle.contactShadow(&context, x + 1.5 * s, y + 0.4, 4.2 * s, 1.1 * s, alpha: 0.3)
        let hem: CGFloat = 2.4 * s
        let shoulder: CGFloat = 1.8 * s
        let waistY: CGFloat = y - 4.4 * s
        let neckY: CGFloat = y - 9 * s
        // Legs, then the coat over them.
        let legW: CGFloat = 0.9 * s
        var legs = Art.rect(x - 1.5 * s, waistY, legW, y - waistY)
        legs.addRect(CGRect(x: x + 0.6 * s, y: waistY, width: legW, height: y - waistY))
        Art.fill(&context, legs, Art.color(0x4A3A44))
        let coatCorners: [CGPoint] = [pt(x - hem, waistY), pt(x - shoulder, neckY), pt(x + shoulder, neckY), pt(x + hem, waistY)]
        Art.fill(&context, Art.polygon(coatCorners), Art.color(coat))
        let litEdge: CGFloat = x - shoulder + 0.9 * s
        let litFoot: CGFloat = x - hem + 0.9 * s
        let litCorners: [CGPoint] = [pt(x - hem, waistY), pt(x - shoulder, neckY), pt(litEdge, neckY), pt(litFoot, waistY)]
        Art.fill(&context, Art.polygon(litCorners), Art.color(0xFFF2DC, 0.35))
        let shadeTop: CGFloat = x + shoulder * 0.3
        let shadeFoot: CGFloat = x + hem * 0.3
        let shadeCorners: [CGPoint] = [pt(shadeFoot, waistY), pt(shadeTop, neckY), pt(x + shoulder, neckY), pt(x + hem, waistY)]
        Art.fill(&context, Art.polygon(shadeCorners), ArtStyle.coolShade.opacity(0.22))
        let headR: CGFloat = 1.5 * s
        let headY: CGFloat = neckY - headR
        Art.fill(&context, Art.circle(x, headY, headR), Art.color(0x9A6A4E))
        let hair = Art.ellipse(x + 0.2 * s, headY - headR * 0.5, headR * 0.95, headR * 0.55)
        Art.fill(&context, hair, Art.color(0x4A3030))
    }

    // MARK: The near plane

    /// A broken column stump in the lower right and a weathered rock in the lower left, dark
    /// and cropped by the frame.
    static func persepolisNear(_ context: inout GraphicsContext) {
        let stump = Art.svg("M352,428 L354,362 L362,356 L370,360 L380,350 L392,354 L404,348 L418,352 L456,346 L456,428 Z")
        Kit.solid(&context, stump, stops: Kit.stops(0x7A5A40, 0x3E2616), light: 0.1, shade: 0.22, rim: 2)
        let stumpFlutes = Art.svg("M366,360 C364,380 366,400 364,428 M382,354 C380,378 382,400 380,428 M398,352 C396,376 398,400 396,428 M414,352 C412,378 414,402 412,428 M430,350 C428,376 430,402 428,428")
        Art.clipped(&context, to: stump) { g in
            Art.stroke(&g, stumpFlutes, Art.color(0x4A3020, 0.5), width: ArtStyle.detailLine)
            Art.fill(&g, Art.rect(352, 344, 104, 6), Art.color(0xE8C8A0, 0.35))
        }

        let rock = Art.svg("M-24,428 L-24,340 C-8,334 10,338 24,348 C34,356 38,372 40,428 Z")
        Kit.solid(&context, rock, stops: Kit.stops(0x6E4A30, 0x3A2214), light: 0.1, shade: 0.2, rim: 2)
        let tufts = Art.svg("M30,352 L27,340 M32,352 L33,338 M34,353 L39,342 M-6,338 L-9,328 M-4,337 L-2,326")
        Art.stroke(&context, tufts, Art.color(0x8A7A44, 0.8), width: 1.2)
    }

    // MARK: Finish

    static func persepolisFinish(_ context: inout GraphicsContext) {
        bottomFade(&context, 0x4A2E1C, from: 300, alpha: 0.9)
        tooth(&context, seed: 827, light: 0.06, dark: 0.05)
        finish(&context, wash: 0.10, vignette: 0.10)
    }
}
