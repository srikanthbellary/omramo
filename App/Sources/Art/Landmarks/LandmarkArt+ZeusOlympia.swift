import SwiftUI
import OmramoCore

// The Statue of Zeus at Olympia: a lost wonder, so this is OUR OWN RECONSTRUCTION, not a
// record. Nothing of the statue remains. The drawing shows the inside of the dim temple hall,
// framed by two dark columns: a huge, calm, seated, bearded figure on a high-backed throne,
// robe and sandals in gold, skin in warm ivory, a wreath on the head close under the roof
// beams, a tall staff with a small bird on top in the left hand and a small winged figure on
// the open right hand; a shallow dark pool of oil on the floor reflects the gold, and one
// small visitor stands at the base for scale. It keeps its construction lines, a height rule
// and loose ink edges, so that it reads as an artist's idea. Our own drawing (no photograph,
// nothing traced, and not copied from any modern reconstruction). Card background #3A2A55.

extension LandmarkArt {
    /// The statue's centre line: the middle of the picture.
    private static let zeusX: CGFloat = 216
    /// Where the back wall meets the floor.
    private static let zeusFloorY: CGFloat = 284

    /// statue-of-zeus-olympia: our reconstruction of the seated gold-and-ivory figure in its hall.
    static func paintZeusOlympia(_ context: inout GraphicsContext) {
        zeusHall(&context)
        zeusColonnades(&context)
        zeusRoof(&context)
        zeusFloor(&context)
        zeusLight(&context)
        zeusGuides(&context)
        zeusBase(&context)
        zeusThrone(&context)
        zeusRobe(&context)
        zeusTorso(&context)
        zeusSceptre(&context)
        zeusArms(&context)
        zeusHead(&context)
        zeusVictory(&context)
        zeusInk(&context)
        zeusPool(&context)
        zeusVisitor(&context)
        zeusNearColumns(&context)
        zeusFinish(&context)
    }

    // MARK: Materials

    /// Gold in the one light: bright on the left, a warm plum-brown shade on the right.
    private static func zeusGold(_ context: inout GraphicsContext, _ path: Path, light: Double, shade: Double) {
        let stops: Kit.Stops = [
            (Art.color(0xFBE3A0), 0),
            (Art.color(0xE9BE62), 0.5),
            (Art.color(0xB98A5A), 1),
        ]
        fillHorizontal(&context, path, stops, from: 150, to: 290)
        model(&context, path, light: light, shade: shade)
    }

    /// Warm ivory: cream on the left, a soft mauve shade on the right.
    private static func zeusIvory(_ context: inout GraphicsContext, _ path: Path, light: Double, shade: Double) {
        let stops: Kit.Stops = [
            (Art.color(0xFFF6E2), 0),
            (Art.color(0xF3E3C8), 0.5),
            (Art.color(0xCDB8B4), 1),
        ]
        fillHorizontal(&context, path, stops, from: 150, to: 290)
        model(&context, path, light: light, shade: shade)
    }

    private static func zeusLimb(_ data: String, width: CGFloat) -> Path {
        Art.svg(data).strokedPath(StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round))
    }

    // MARK: The hall (far plane)

    private static func zeusHall(_ context: inout GraphicsContext) {
        let wall: Kit.Stops = [
            (Art.color(0x4E3E6C), 0),
            (Art.color(0x6C5A88), 0.35),
            (Art.color(0x8A7698), 0.7),
            (Art.color(0x8A7698), 1),
        ]
        backdrop(&context, wall)
        // The courses of the back wall, barely seen.
        var courses = Path()
        for index in 0..<9 {
            let y: CGFloat = 64 + CGFloat(index) * 26
            courses.move(to: pt(120, y))
            courses.addLine(to: pt(312, y))
        }
        Art.stroke(&context, courses, Art.color(0x3E3060, 0.2), width: 0.6, cap: .butt)
        // The dim side aisles behind the inner columns.
        var aisles = Path()
        aisles.addRect(CGRect(x: -24, y: 40, width: 148, height: 250))
        aisles.addRect(CGRect(x: 308, y: 40, width: 148, height: 250))
        Art.fill(&context, aisles, Art.color(0x44355F, 0.5))
    }

    /// Two tiers of inner columns down each side of the hall, closing up as they go back.
    private static func zeusColonnades(_ context: inout GraphicsContext) {
        // (centre x on the left side, width, foot y, gallery y)
        let places: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
            (70, 13, 290, 148), (96, 10.5, 287, 153), (117, 8.5, 285, 157),
        ]
        var shafts = Path()
        var lights = Path()
        var shades = Path()
        for side in 0..<2 {
            for place in places {
                let x: CGFloat = side == 0 ? place.0 : unitWidth - place.0
                let w: CGFloat = place.1
                let upperW: CGFloat = w * 0.8
                let lowTop: CGFloat = place.3 + 5
                let lowH: CGFloat = place.2 - lowTop
                let upTop: CGFloat = 40
                let upH: CGFloat = place.3 - 5 - upTop
                shafts.addRect(CGRect(x: x - w / 2, y: lowTop, width: w, height: lowH))
                shafts.addRect(CGRect(x: x - upperW / 2, y: upTop, width: upperW, height: upH))
                lights.addRect(CGRect(x: x - w / 2, y: lowTop, width: w * 0.26, height: lowH))
                lights.addRect(CGRect(x: x - upperW / 2, y: upTop, width: upperW * 0.26, height: upH))
                shades.addRect(CGRect(x: x + w * 0.14, y: lowTop, width: w * 0.36, height: lowH))
                shades.addRect(CGRect(x: x + upperW * 0.14, y: upTop, width: upperW * 0.36, height: upH))
            }
        }
        let stone: Kit.Stops = [(Art.color(0x8E7CA4), 0), (Art.color(0xA894B0), 1)]
        fillVertical(&context, shafts, stone, from: 40, to: 290)
        Art.fill(&context, lights, Art.color(0xFFE2BC, 0.26))
        Art.fill(&context, shades, ArtStyle.coolShade.opacity(0.22))

        // The gallery beams between the two tiers.
        var beams = Path()
        beams.addPath(Art.polygon([pt(58, 141), pt(124, 152), pt(124, 162), pt(58, 155)]))
        beams.addPath(Art.polygon([pt(374, 141), pt(308, 152), pt(308, 162), pt(374, 155)]))
        Art.fill(&context, beams, Art.color(0x9A88AC))
        let beamTops = Art.svg("M58,141 L124,152 M374,141 L308,152")
        Art.stroke(&context, beamTops, Art.color(0xFFE2BC, 0.4), width: 0.8, cap: .butt)
        haze(&context, top: 40, bottom: 290, hex: 0x8A7698, alpha: 0.3)
    }

    /// The dark timber roof close over the statue's head.
    private static func zeusRoof(_ context: inout GraphicsContext) {
        let ceiling = Art.rect(-24, -24, unitWidth + 48, 58)
        let dark: Kit.Stops = [(Art.color(0x30244C), 0), (Art.color(0x44355E), 1)]
        fillVertical(&context, ceiling, dark, from: 0, to: 34)
        var joists = Path()
        for index in 0..<15 {
            let x: CGFloat = 44 + CGFloat(index) * 25
            joists.addRect(CGRect(x: x, y: 24, width: 9, height: 10))
        }
        Art.fill(&context, joists, Art.color(0x6A5684))
        let beam = Art.rect(-24, 34, unitWidth + 48, 8)
        let timber: Kit.Stops = [(Art.color(0x66527E), 0), (Art.color(0x4A3A66), 1)]
        fillVertical(&context, beam, timber, from: 34, to: 42)
        Art.stroke(&context, Art.line(60, 34.4, 440, 34.4), Art.color(0xFFE2BC, 0.3), width: 0.7, cap: .butt)
        let under: Kit.Stops = [
            (ArtStyle.coolShade.opacity(0.34), 0),
            (ArtStyle.coolShade.opacity(0), 1),
        ]
        fillVertical(&context, Art.rect(-24, 42, unitWidth + 48, 16), under, from: 42, to: 58)
    }

    private static func zeusFloor(_ context: inout GraphicsContext) {
        let top: CGFloat = zeusFloorY
        let floor = Art.rect(-24, top, unitWidth + 48, unitHeight - top + 24)
        let stone: Kit.Stops = [
            (Art.color(0xA692AC), 0),
            (Art.color(0x7C688C), 0.3),
            (Art.color(0x3A2A55), 1),
        ]
        fillVertical(&context, floor, stone, from: top, to: unitHeight)
        // The paving: joints that run back toward the statue, and across.
        let feet: [CGFloat] = [-80, 30, 126, 216, 306, 402, 512]
        var joints = Path()
        for x in feet {
            let farX: CGFloat = zeusX + (x - zeusX) * 0.4
            joints.move(to: pt(x, unitHeight))
            joints.addLine(to: pt(farX, top))
        }
        let rows: [CGFloat] = [295, 311, 336, 374]
        for y in rows {
            joints.move(to: pt(-24, y))
            joints.addLine(to: pt(unitWidth + 24, y))
        }
        Art.stroke(&context, joints, Art.color(0x4A3A66, 0.3), width: 0.6, cap: .butt)
        Art.stroke(&context, Art.line(-24, top, unitWidth + 24, top), Art.color(0x4A3A66, 0.4), width: 0.8, cap: .butt)
    }

    /// The light from the doorway, falling from the upper left across the statue.
    private static func zeusLight(_ context: inout GraphicsContext) {
        Art.blurred(&context, radius: 10, opacity: 1) { g in
            let wide = Art.polygon([pt(40, 44), pt(118, 44), pt(336, 300), pt(150, 300)])
            Art.fill(&g, wide, Art.color(0xFFE2B0, 0.12))
            let narrow = Art.polygon([pt(60, 44), pt(96, 44), pt(280, 300), pt(196, 300)])
            Art.fill(&g, narrow, Art.color(0xFFE9C0, 0.1))
        }
        // The gold answers the light: a warm glow about the figure.
        Art.glow(&context, 206, 170, 170, Art.color(0xFFD9A0), alpha: 0.2)
    }

    // MARK: The sketch

    /// A draughtsman's lines: each stroke is drawn twice, a little off and a little long.
    private static func zeusSketch(_ segments: [(CGPoint, CGPoint)], seed: UInt32, overshoot: CGFloat, wobble: Double) -> Path {
        var random = ArtRandom(seed)
        var path = Path()
        let shake: Double = max(0.01, wobble)
        for segment in segments {
            let a = segment.0
            let b = segment.1
            let dx: CGFloat = b.x - a.x
            let dy: CGFloat = b.y - a.y
            let squared: CGFloat = dx * dx + dy * dy
            let length: CGFloat = max(1, squared.squareRoot())
            let ux: CGFloat = dx / length
            let uy: CGFloat = dy / length
            for _ in 0..<2 {
                let over: CGFloat = overshoot * random.next(in: 0.3...1)
                let ax: CGFloat = a.x - ux * over + random.next(in: -shake...shake)
                let ay: CGFloat = a.y - uy * over + random.next(in: -shake...shake)
                let bx: CGFloat = b.x + ux * over + random.next(in: -shake...shake)
                let by: CGFloat = b.y + uy * over + random.next(in: -shake...shake)
                path.move(to: pt(ax, ay))
                path.addLine(to: pt(bx, by))
            }
        }
        return path
    }

    /// Faint chalk guide lines behind the statue: a centre line, level lines (crown,
    /// shoulders, seat, base) and a height rule with ten divisions.
    private static func zeusGuides(_ context: inout GraphicsContext) {
        let cx: CGFloat = zeusX
        let chalk = Art.color(0xF2E8FA, 0.3)
        let axis = Art.line(cx, 46, cx, 300)
        Art.stroke(&context, axis, chalk, width: 0.5, cap: .butt, dash: [7, 3, 1.5, 3])

        var guides: [(CGPoint, CGPoint)] = []
        let levels: [CGFloat] = [276, 198, 104, 56]
        for level in levels {
            guides.append((pt(cx - 92, level), pt(cx + 112, level)))
        }
        guides.append((pt(cx - 66, 276), pt(cx - 50, 80)))
        guides.append((pt(cx + 66, 276), pt(cx + 50, 80)))
        let lines = zeusSketch(guides, seed: 7, overshoot: 7, wobble: 0.35)
        Art.stroke(&context, lines, chalk, width: 0.5)

        let ruleX: CGFloat = cx + 108
        var rule = Art.line(ruleX, 276, ruleX, 56)
        for index in 0...10 {
            let y: CGFloat = 276 - CGFloat(index) * 22
            rule.move(to: pt(ruleX - 3, y))
            rule.addLine(to: pt(ruleX + 3, y))
        }
        Art.stroke(&context, rule, chalk, width: 0.6, cap: .butt)
    }

    /// Loose edges over the throne and the base, so that the picture stays a drawing.
    private static func zeusInk(_ context: inout GraphicsContext) {
        var edges: [(CGPoint, CGPoint)] = []
        edges.append((pt(124, 276), pt(308, 276)))
        edges.append((pt(124, 298), pt(308, 298)))
        edges.append((pt(124, 276), pt(124, 298)))
        edges.append((pt(308, 276), pt(308, 298)))
        edges.append((pt(160, 80), pt(272, 80)))
        edges.append((pt(166, 88), pt(166, 150)))
        edges.append((pt(266, 88), pt(266, 150)))
        edges.append((pt(148, 198), pt(284, 198)))
        edges.append((pt(150, 208), pt(150, 274)))
        edges.append((pt(282, 208), pt(282, 274)))
        edges.append((pt(174, 268), pt(258, 268)))
        let ink = zeusSketch(edges, seed: 33, overshoot: 2.6, wobble: 0.45)
        Art.stroke(&context, ink, Art.color(0x3A2850, 0.45), width: 0.6)
        let chalk = zeusSketch(edges, seed: 49, overshoot: 1.4, wobble: 0.7)
        Art.stroke(&context, chalk, Art.color(0xFFF3D8, 0.34), width: 0.5)
    }
}

// MARK: - Base and throne

extension LandmarkArt {
    /// The low, wide base of dark stone, with a band of small gold figures along its front.
    private static func zeusBase(_ context: inout GraphicsContext) {
        ArtStyle.contactShadow(&context, 226, 299, 112, 5, alpha: 0.34)
        let top = Art.polygon([pt(130, 271), pt(302, 271), pt(308, 276), pt(124, 276)])
        Art.fill(&context, top, Art.color(0x8474A0))
        let front = Art.rect(124, 276, 184, 22)
        Kit.solid(&context, front, stops: Kit.stops(0x5E5282, 0x3E3460), light: 0.16, shade: 0.24)
        var band = Path()
        for index in 0..<13 {
            let x: CGFloat = 136 + CGFloat(index) * 13.4
            band.addRect(CGRect(x: x - 1, y: 284.6, width: 2, height: 6.4))
            band.addEllipse(in: CGRect(x: x - 1.2, y: 281.8, width: 2.4, height: 2.4))
        }
        Art.fill(&context, band, Art.color(0xE9BE62, 0.7))
        var trims = Art.line(124, 276.5, 308, 276.5)
        trims.move(to: pt(124, 294.5))
        trims.addLine(to: pt(308, 294.5))
        Art.stroke(&context, trims, Art.color(0xF3D088, 0.6), width: 0.8, cap: .butt)
    }

    /// The high-backed throne of dark wood and gold.
    private static func zeusThrone(_ context: inout GraphicsContext) {
        let back = Art.rect(166, 86, 100, 114)
        Kit.solid(&context, back, stops: Kit.stops(0x74506A, 0x523652), light: 0.14, shade: 0.24)
        var panels = Path()
        panels.addRect(CGRect(x: 172, y: 92, width: 88, height: 100))
        panels.addRect(CGRect(x: 176, y: 96, width: 80, height: 92))
        Art.stroke(&context, panels, Art.color(0xE9BE62, 0.45), width: 0.7, cap: .butt, join: .miter)

        // Between the legs: the dark panel under the seat.
        let panel = Art.rect(163, 206, 106, 70)
        Kit.solid(&context, panel, stops: Kit.stops(0x5A3E5A, 0x3E2A4A), light: 0.06, shade: 0.2)

        var gilt = Path()
        gilt.addRect(CGRect(x: 160, y: 80, width: 112, height: 7))
        gilt.addRect(CGRect(x: 152, y: 160, width: 10, height: 38))
        gilt.addRect(CGRect(x: 270, y: 160, width: 10, height: 38))
        gilt.addRect(CGRect(x: 148, y: 198, width: 136, height: 8))
        gilt.addRect(CGRect(x: 150, y: 206, width: 13, height: 70))
        gilt.addRect(CGRect(x: 269, y: 206, width: 13, height: 70))
        zeusGold(&context, gilt, light: 0.16, shade: 0.2)
        var rests = Path()
        rests.addPath(Art.rect(146, 154, 26, 6.4, radius: 2))
        rests.addPath(Art.rect(260, 154, 26, 6.4, radius: 2))
        rests.addRect(CGRect(x: 163, y: 238, width: 106, height: 5))
        zeusGold(&context, rests, light: 0.2, shade: 0.16)
        // The knobs on the corners of the back.
        var knobs = Path()
        knobs.addEllipse(in: CGRect(x: 158.5, y: 69, width: 11, height: 11))
        knobs.addEllipse(in: CGRect(x: 262.5, y: 69, width: 11, height: 11))
        zeusGold(&context, knobs, light: 0.2, shade: 0.2)

        // Dark bands on the gold legs, and the shade the seat throws below itself.
        var bands = Path()
        let rows: [CGFloat] = [220, 234, 256]
        for row in rows {
            bands.addRect(CGRect(x: 150, y: row, width: 13, height: 2.4))
            bands.addRect(CGRect(x: 269, y: row, width: 13, height: 2.4))
        }
        Art.fill(&context, bands, Art.color(0x5A3A52, 0.6))
        Art.fill(&context, Art.rect(150, 206, 132, 3.4), ArtStyle.coolShade.opacity(0.24))
        Art.stroke(&context, Art.line(160, 80.4, 272, 80.4), Art.color(0xFFF3D0, 0.8), width: 0.8, cap: .butt)
        Art.stroke(&context, Art.line(148, 198.4, 284, 198.4), Art.color(0xFFF3D0, 0.7), width: 0.8, cap: .butt)
    }
}

// MARK: - The figure

extension LandmarkArt {
    /// The gold robe over the lap and legs, the footstool, and the feet in gold sandals.
    private static func zeusRobe(_ context: inout GraphicsContext) {
        let stool = Art.rect(174, 268, 84, 8)
        Kit.solid(&context, stool, stops: Kit.stops(0xCFA066, 0x8E6658), light: 0.16, shade: 0.22)

        let robe = Art.svg("M182,170 C200,176 232,176 250,170 C262,178 270,190 270,202 C268,222 262,244 260,262 L172,262 C170,244 164,222 162,202 C162,190 170,178 182,170 Z")
        zeusGold(&context, robe, light: 0.24, shade: 0.24)
        ArtStyle.rimEdge(&context, robe, bounds: robe.boundingRect, width: 1.2, alpha: 0.5)
        // The knees catch the light; the robe hangs in long folds between and below them.
        Art.glow(&context, 188, 200, 16, Art.color(0xFFF3C8), alpha: 0.4)
        Art.glow(&context, 240, 200, 14, Art.color(0xFFF3C8), alpha: 0.26)
        let falls = Art.svg("M180,210 C178,228 180,246 177,260 M192,208 C190,226 193,246 190,260 M205,206 C205,226 207,244 205,260 M216,192 C214,214 218,240 216,260 M229,206 C229,226 227,244 229,260 M242,208 C244,226 241,246 244,260 M253,210 C255,228 252,246 255,260")
        Art.stroke(&context, falls, Art.color(0x9A6A4A, 0.42), width: 0.9)
        let swags = Art.svg("M192,197 C204,209 228,209 240,197 M197,186 C207,195 225,195 235,186 M186,176 C202,183 230,183 246,176")
        Art.stroke(&context, swags, Art.color(0x9A6A4A, 0.42), width: 0.9)
        let hem = Art.svg("M172,262 C186,259 200,263 216,260 C232,263 246,259 260,262")
        Art.stroke(&context, hem, Art.color(0xFFF3D0, 0.6), width: 0.9)

        // The feet on the footstool.
        let leftFoot = Art.svg("M187,261 L205,261 C207,264 208,266 208,268 L183,268 C183,265 185,263 187,261 Z")
        let rightFoot = Art.svg("M227,261 L245,261 C247,263 249,265 249,268 L224,268 C224,266 225,264 227,261 Z")
        zeusIvory(&context, leftFoot, light: 0.12, shade: 0.1)
        zeusIvory(&context, rightFoot, light: 0.08, shade: 0.18)
        let straps = Art.svg("M186,263.4 L207,263.4 M189,261.4 L201,267.6 M226,263.4 L247,263.4 M230,261.4 L242,267.6 M183,267.6 L208,267.6 M224,267.6 L249,267.6")
        Art.stroke(&context, straps, Art.color(0xE2B050), width: 0.9)
    }

    /// The bare ivory chest and neck, and the gold robe over the left shoulder.
    private static func zeusTorso(_ context: inout GraphicsContext) {
        let neck = Art.rect(208, 88, 16, 14)
        zeusIvory(&context, neck, light: 0.06, shade: 0.2)
        let torso = Art.svg("M176,108 C182,101 200,99 216,99 C232,99 250,101 256,108 C258,128 252,150 248,176 L184,176 C180,150 174,128 176,108 Z")
        zeusIvory(&context, torso, light: 0.26, shade: 0.2)
        ArtStyle.rimEdge(&context, torso, bounds: torso.boundingRect, width: 1.2, alpha: 0.5)
        let chest = Art.svg("M189,131 C197,138 210,138 215,132 M217,132 C222,138 235,138 243,131 M216,112 L216,162 M202,152 C207,155 212,155 215,153 M217,153 C220,155 225,155 230,152")
        Art.stroke(&context, chest, Art.color(0xA08478, 0.4), width: 0.8)

        // The robe comes over the far shoulder and down to the lap.
        let drape = Art.svg("M238,100 C249,100 258,104 260,113 C259,136 254,158 251,178 L226,178 C233,152 238,126 238,100 Z")
        zeusGold(&context, drape, light: 0.14, shade: 0.24)
        let drapeFolds = Art.svg("M244,104 C244,130 239,156 233,176 M252,106 C252,132 248,156 243,176")
        Art.stroke(&context, drapeFolds, Art.color(0x9A6A4A, 0.42), width: 0.9)
    }

    /// The tall staff in the left hand, with a small bird on its top.
    private static func zeusSceptre(_ context: inout GraphicsContext) {
        let staff = Art.rect(286.6, 56, 2.8, 216)
        zeusGold(&context, staff, light: 0.1, shade: 0.1)
        Art.stroke(&context, Art.line(287.1, 58, 287.1, 270), Art.color(0xFFF6D8, 0.8), width: 0.6, cap: .butt)
        var rings = Path()
        let places: [CGFloat] = [58, 96, 150, 210, 266]
        for y in places {
            rings.addRect(CGRect(x: 285.6, y: y, width: 4.8, height: 2))
        }
        Art.fill(&context, rings, Art.color(0xC8963E))

        // The bird: a body, a head with a beak, a folded wing and a tail.
        var bird = Path()
        bird.addEllipse(in: CGRect(x: 282.4, y: 47.6, width: 11.4, height: 7.4))
        bird.addEllipse(in: CGRect(x: 291, y: 45, width: 4.8, height: 4.8))
        Art.fill(&context, bird, Art.color(0xE9BE62))
        let beak = Art.polygon([pt(295.2, 46.6), pt(298, 47.8), pt(295.2, 48.8)])
        Art.fill(&context, beak, Art.color(0xE9BE62))
        let tail = Art.polygon([pt(283.6, 50), pt(277.6, 54), pt(284.6, 53.6)])
        Art.fill(&context, tail, Art.color(0xE9BE62))
        let wing = leaf(291, 50, length: 9, width: 2.4, angle: Kit.deg(168))
        Art.fill(&context, wing, Art.color(0xB98A5A))
        Art.fill(&context, Art.ellipse(286.4, 49.6, 2.6, 1.2), Art.color(0xFFF3C8, 0.7))
    }

    /// The two ivory arms: the left one raised to hold the staff, the right one held out
    /// with an open palm.
    private static func zeusArms(_ context: inout GraphicsContext) {
        // The robe hangs behind and below the raised arm.
        let hang = Art.svg("M262,116 C270,126 276,138 279,152 C276,168 272,184 270,198 C265,192 262,196 258,190 C260,166 262,140 262,116 Z")
        zeusGold(&context, hang, light: 0.08, shade: 0.26)
        let hangFolds = Art.svg("M266,128 C268,150 266,172 263,190 M272,142 C273,160 270,178 268,192")
        Art.stroke(&context, hangFolds, Art.color(0x9A6A4A, 0.42), width: 0.9)
        let raised = zeusLimb("M257,111 C268,121 278,134 282,148 C285,138 287,128 288,119", width: 12)
        zeusIvory(&context, raised, light: 0.12, shade: 0.24)
        let grip = Art.ellipse(288, 116, 6, 5.4)
        zeusIvory(&context, grip, light: 0.1, shade: 0.2)
        let fingers = Art.svg("M283.4,114 L292.6,114 M283.4,116.6 L292.6,116.6 M283.6,119 L292.4,119")
        Art.stroke(&context, fingers, Art.color(0xA08478, 0.5), width: 0.6)

        let held = zeusLimb("M177,111 C169,123 164,138 163,151 C155,157 147,159 140,159", width: 12)
        zeusIvory(&context, held, light: 0.26, shade: 0.12)
        let palm = Art.ellipse(135, 159.4, 8, 3.6)
        zeusIvory(&context, palm, light: 0.2, shade: 0.1)
        Art.fill(&context, Art.rect(128, 162, 16, 1.6, radius: 0.8), ArtStyle.coolShade.opacity(0.2))
    }

    /// The calm bearded head, with gold hair and beard and a wreath of small leaves.
    private static func zeusHead(_ context: inout GraphicsContext) {
        let cx: CGFloat = zeusX
        let hair = Art.ellipse(cx, 74, 17, 19)
        zeusGold(&context, hair, light: 0.2, shade: 0.24)
        let face = Art.ellipse(cx, 76, 12, 15)
        zeusIvory(&context, face, light: 0.24, shade: 0.16)
        let beard = Art.svg("M203,79 C203,96 209,106 216,107 C223,106 229,96 229,79 C225,86 221,88.500 216,88.500 C211,88.500 207,86 203,79 Z")
        zeusGold(&context, beard, light: 0.14, shade: 0.24)
        let cap = Art.svg("M202,77 C200,63 207,56 216,56 C225,56 232,63 230,77 C227,69 222,66 216,66 C210,66 205,69 202,77 Z")
        zeusGold(&context, cap, light: 0.24, shade: 0.16)
        let curls = Art.svg("M207,92 C209,96 211,99 213,102 M216,91 L216,104 M225,92 C223,96 221,99 219,102 M206,64 C210,61 213,60 216,60 M226,64 C222,61 219,60 216,60")
        Art.stroke(&context, curls, Art.color(0x9A6A4A, 0.45), width: 0.8)

        // The wreath: small leaves laid up both sides of the head toward the crown.
        var wreath = Path()
        for index in 0..<8 {
            let degrees: CGFloat = 196 + CGFloat(index) * 21
            let a: CGFloat = Kit.deg(degrees)
            let lx: CGFloat = cx + cos(a) * 15
            let ly: CGFloat = 73 + sin(a) * 16
            let turn: CGFloat = degrees < 270 ? Kit.deg(70) : Kit.deg(-70)
            wreath.addPath(leaf(lx, ly, length: 7, width: 2.2, angle: a + turn))
        }
        Art.fill(&context, wreath, Art.color(0xFFE9A0))
        Art.stroke(&context, wreath, Art.color(0xB98A5A, 0.5), width: 0.4)

        // The face is drawn broadly: level brows, closed calm eyes, the line of the nose.
        let features = Art.svg("M208,72.500 C210,71.500 212.500,71.500 214.500,72.500 M217.500,72.500 C219.500,71.500 222,71.500 224,72.500 M209,76 C211,77.200 213,77.200 214.600,76 M217.400,76 C219,77.200 221,77.200 223,76 M216,75 L215.200,83 L217.200,83.400")
        Art.stroke(&context, features, Art.color(0x8A6A5A, 0.6), width: 0.7)
        Art.fill(&context, Art.rect(207, 100, 18, 2, radius: 1), ArtStyle.coolShade.opacity(0.14))
    }

    /// The small winged figure standing on the open right hand, suggested simply.
    private static func zeusVictory(_ context: inout GraphicsContext) {
        var wings = Path()
        wings.addPath(leaf(134, 146, length: 15, width: 4, angle: Kit.deg(-142)))
        wings.addPath(leaf(136, 146, length: 15, width: 4, angle: Kit.deg(-38)))
        Art.fill(&context, wings, Art.color(0xFFE9A0))
        Art.stroke(&context, wings, Art.color(0xB98A5A, 0.5), width: 0.4)
        let gown = Art.polygon([pt(133.2, 143), pt(136.800, 143), pt(139, 157), pt(131, 157)])
        Art.fill(&context, gown, Art.color(0xE9BE62))
        Art.fill(&context, Art.polygon([pt(135.6, 143), pt(136.800, 143), pt(139, 157), pt(136.4, 157)]), ArtStyle.coolShade.opacity(0.2))
        Art.fill(&context, Art.circle(135, 140.4, 2.5), Art.color(0xFBEBD0))
        Art.fill(&context, Art.ellipse(135, 139, 2.6, 1.5), Art.color(0xD9A850))
    }
}

// MARK: - Pool, visitor, near plane, finish

extension LandmarkArt {
    /// The shallow pool of dark oil on the floor in front of the base, holding the gold.
    private static func zeusPool(_ context: inout GraphicsContext) {
        let kerb = Art.ellipse(216, 326, 124, 17)
        Art.fill(&context, kerb, Art.color(0xA898B4, 0.7))
        let pool = Art.ellipse(216, 326.6, 119, 14.4)
        let oil: Kit.Stops = [(Art.color(0x2A1E48), 0), (Art.color(0x3E2E5C), 1)]
        fillVertical(&context, pool, oil, from: 312, to: 341)
        Art.clipped(&context, to: pool) { g in
            let goldRect = CGRect(x: 176, y: 313, width: 84, height: 26)
            ripples(&g, in: goldRect, count: 34, seed: 21, color: Art.color(0xF3C680, 0.5), width: 1, length: 5...22)
            let ivoryRect = CGRect(x: 190, y: 316, width: 52, height: 12)
            ripples(&g, in: ivoryRect, count: 10, seed: 27, color: Art.color(0xFFF3D8, 0.5), width: 0.9, length: 4...14)
            let dimRect = CGRect(x: 100, y: 313, width: 232, height: 28)
            ripples(&g, in: dimRect, count: 22, seed: 35, color: Art.color(0x9A88B8, 0.3), width: 0.7, length: 8...26)
            Art.glow(&g, 214, 322, 60, Art.color(0xF3C680), alpha: 0.22)
        }
        let lip = Art.svg("M97,326 C110,316 160,311.500 216,311.500")
        Art.stroke(&context, lip, ArtStyle.warmLight.opacity(0.5), width: 0.8)
    }

    /// One small visitor beside the base, looking up: a robe, a head, an arm.
    private static func zeusVisitor(_ context: inout GraphicsContext) {
        let x: CGFloat = 340
        let y: CGFloat = 303
        ArtStyle.contactShadow(&context, x + 5, y + 0.6, 10, 2, alpha: 0.36)
        let robe = Art.polygon([pt(x - 3.4, y - 19), pt(x + 3.4, y - 19), pt(x + 5.4, y), pt(x - 5.4, y)])
        Kit.solid(&context, robe, stops: Kit.stops(0xB86A5A, 0x8A4A56), light: 0.2, shade: 0.24)
        let fold = Art.line(x - 0.6, y - 16, x - 1.4, y - 1)
        Art.stroke(&context, fold, Art.color(0x6A3848, 0.5), width: 0.6)
        let arm = Art.line(x - 2.6, y - 17, x - 6.4, y - 22)
        Art.stroke(&context, arm, Art.color(0xB07A5E), width: 1.8)
        Art.fill(&context, Art.circle(x - 0.4, y - 22.6, 3.3), Art.color(0xB07A5E))
        let hair = Art.svg("M336.4,280.6 C336.6,276.6 342.6,276 342.9,280 C343,282 342.4,283.4 341.6,284 C341.8,281.6 339.4,279.6 336.4,280.6 Z")
        Art.fill(&context, hair, Art.color(0x4A3040))
    }

    /// The near plane: the two dark columns the viewer looks between.
    private static func zeusNearColumns(_ context: inout GraphicsContext) {
        let left = Art.svg("M-24,-24 L48,-24 L46,60 L50,428 L-24,428 Z")
        Kit.solid(&context, left, stops: Kit.stops(0x43345F, 0x2A1E46), light: 0.04, shade: 0.2)
        let right = Art.svg("M456,-24 L390,-24 L392,60 L386,428 L456,428 Z")
        Kit.solid(&context, right, stops: Kit.stops(0x4E3D6A, 0x2A1E46), light: 0.1, shade: 0.22, rim: 2.5)

        let leftFlutes = Art.svg("M8,-24 L7,428 M22,-24 L22,428 M35,-24 L37,428")
        let rightFlutes = Art.svg("M402,-24 L399,428 M416,-24 L414,428 M430,-24 L429,428")
        Art.clipped(&context, to: left) { g in
            Art.stroke(&g, leftFlutes, Art.color(0x1E1438, 0.4), width: 1.6, cap: .butt)
        }
        Art.clipped(&context, to: right) { g in
            Art.stroke(&g, rightFlutes, Art.color(0x1E1438, 0.4), width: 1.6, cap: .butt)
            Art.stroke(&g, Art.line(391.4, -24, 387, 428), ArtStyle.warmLight.opacity(0.4), width: 1.4, cap: .butt)
        }
    }

    // MARK: Finish

    private static func zeusFinish(_ context: inout GraphicsContext) {
        bottomFade(&context, 0x3A2A55, from: 300, alpha: 0.9)
        // Heavier tooth than a standing building: this one is a drawing on paper.
        tooth(&context, seed: 619, light: 0.08, dark: 0.07)
        let paper = CGRect(x: 0, y: 0, width: unitWidth, height: 300)
        Art.stipple(&context, in: paper, count: 180, seed: 643, color: Art.color(0xFFF6E0), alpha: 0.08, size: 0.4...1)
        finish(&context, wash: 0.10, vignette: 0.08)
    }
}
