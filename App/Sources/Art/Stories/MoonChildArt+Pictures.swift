import SwiftUI
import OmramoCore

// The tap-to-see pictures (432 × 404) of "The Bamboo-Cutter and the Moon-Child": one subject
// each, centred a little above the middle, on the card's own dark colour, sunk into it at
// the bottom. Then the two character-card portraits, the three face chips and the cover.

extension MoonChildArt {
    // MARK: see-bamboo-work

    /// A round woven bamboo basket, a split green stem and the short knife lying before it,
    /// on a deep green ground under a soft lamplight.
    static func bambooWorkPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let back: Kit.Stops = [(Art.color(0x0E2620), 0), (Art.color(0x17382C), 0.6), (Art.color(0x1F4A3A), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, h), back, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: h))
        cane(&context, x: 40, baseY: h, top: -10, half: 14, tone: 0x10282C, lean: 4, seed: 301)
        cane(&context, x: 394, baseY: h, top: -10, half: 16, tone: 0x10282C, lean: -6, seed: 302)
        leafSpray(&context, x: 400, y: 20, reach: 90, count: 16, color: Art.color(0x0C2024), seed: 303, droop: 0.8)
        Art.glow(&context, 150, 140, 250, ramp.glowColor, alpha: 0.16)
        let deck = Art.svg("M0,250 C120,232 312,232 432,250 L432,404 L0,404Z")
        let mat: Kit.Stops = Kit.stops(0x2A5A44, 0x17382C)
        Kit.solid(&context, deck, stops: mat, light: 0.14, shade: 0.2)
        var weft = Path()
        let rows: [CGFloat] = [258, 272, 290, 312]
        for y in rows {
            weft.move(to: Kit.pt(0, y))
            weft.addLine(to: Kit.pt(w, y))
        }
        Art.stroke(&context, weft, Art.color(0x0F2A26, 0.5), width: 1.2, cap: .butt)
        Kit.shadow(&context, 216, 262, width: 230, alpha: 0.4)
        wovenBasket(&context, x: 216, y: 262)
        splitStem(&context, x: 214, y: 290)
        Art.group(&context, x: 318, y: 298, rotate: Kit.deg(-8), scale: 2.0) { k in
            nata(&k)
        }
        Kit.sink(&context, size, card: 0x17382C)
    }

    /// A round basket woven of split bamboo, its foot at (x, y): 200 wide, 108 high.
    static func wovenBasket(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat) {
        Art.group(&context, x: x, y: y) { g in
            let rimY: CGFloat = -108
            Art.stroke(&g, Art.svg("M-98,-108 Q0,-148 98,-108"), Art.color(0x8A6A3A), width: 7)
            Art.fill(&g, Art.ellipse(0, rimY, 94, 18), Art.color(0x3A2A16))
            Art.glow(&g, -10, rimY - 4, 60, Art.color(0x6A4A26), alpha: 0.4)
            let body = Art.svg("M-96,-108 C-100,-60 -84,-12 -50,-2 C-20,4 20,4 50,-2 C84,-12 100,-60 96,-108 Q0,-68 -96,-108Z")
            let straw: Kit.Stops = [(Art.color(0xC9A45E), 0), (Art.color(0xA8823E), 0.6), (Art.color(0x7A5A2A), 1)]
            Kit.solid(&g, body, stops: straw, light: 0.22, shade: 0.26)
            var stakes = Path()
            var lit = Path()
            for row in 0..<11 {
                let yy: CGFloat = -98 + CGFloat(row) * 9
                let t: CGFloat = (yy + 108) / 108
                let squeeze: CGFloat = 1 - 0.5 * t * t
                for col in -6..<6 {
                    let xa: CGFloat = CGFloat(col) * 16 * squeeze
                    let xb: CGFloat = xa + 16 * squeeze
                    if (row + col) % 2 == 0 {
                        lit.addRect(CGRect(x: xa + 1, y: yy - 3.5, width: xb - xa - 2, height: 7))
                    }
                }
            }
            for col in -6...6 {
                let top: CGFloat = CGFloat(col) * 16
                stakes.move(to: Kit.pt(top, -104))
                stakes.addLine(to: Kit.pt(top * 0.5, -2))
            }
            let shape = body
            let panes = lit
            let ribs = stakes
            Art.clipped(&g, to: shape) { c in
                Art.fill(&c, panes, Art.color(0xE6CC88, 0.32))
                Art.stroke(&c, ribs, Art.color(0x5A4020, 0.6), width: 1.6, cap: .butt)
            }
            Art.stroke(&g, Art.svg("M-98,-108 Q0,-68 98,-108"), Art.color(0xD8B870), width: 7)
            Art.stroke(&g, Art.svg("M-92,-110 Q0,-72 60,-98"), Art.color(0xFFF0C0, 0.4), width: 1.6)
        }
    }

    /// A length of green bamboo and its split half lying in front, centred on (x, y).
    static func splitStem(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat) {
        let whole = Art.rect(x - 124, y - 24, 134, 20, radius: 8)
        Kit.solid(&context, whole, Art.color(0x4E8A4A), light: 0.26, shade: 0.24)
        var rings = Path()
        rings.addPath(Art.line(x - 84, y - 24, x - 84, y - 4))
        rings.addPath(Art.line(x - 34, y - 24, x - 34, y - 4))
        Art.stroke(&context, rings, Art.color(0x2A5A3A), width: 2.4, cap: .butt)
        Art.stroke(&context, Art.line(x - 118, y - 19, x + 4, y - 19), Art.color(0xC8E0A8, 0.4), width: 2)
        // The split half: pale inside, a green edge.
        let half = Art.rect(x - 100, y - 4, 150, 14, radius: 6)
        Art.fill(&context, half, Art.color(0x3E7A3E))
        let inner = Art.rect(x - 96, y - 2, 142, 8, radius: 4)
        let pale: Kit.Stops = [(Art.color(0xF2E8B8), 0), (Art.color(0xD8C888), 1)]
        Art.fillLinear(&context, inner, pale, from: CGPoint(x: x, y: y - 2), to: CGPoint(x: x, y: y + 6))
        Art.stroke(&context, Art.line(x - 60, y - 2, x - 60, y + 6), Art.color(0xA89A5A), width: 2, cap: .butt)
        Kit.shadow(&context, x - 24, y + 11, width: 170, alpha: 0.3)
    }

    // MARK: see-old-capital

    /// The great gate of the old capital seen from the front, at the end of a broad straight
    /// avenue, under a night sky; warm light in its open passages.
    static func oldCapitalPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let horizon: CGFloat = 250
        let sky: Kit.Stops = [(Art.color(0x0E1236), 0), (Art.color(0x1C1A48), 0.55), (Art.color(0x3A2E68), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, horizon), sky, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: horizon))
        Kit.stars(&context, width: w, maxY: 160, count: 30, seed: 311)
        Art.glow(&context, 216, horizon - 10, 230, Art.color(0x6A4A8A), alpha: 0.3)
        let earth: Kit.Stops = Kit.stops(0x2A2350, 0x1A1638)
        Art.fillLinear(&context, Art.rect(0, horizon - 4, w, h - horizon + 4), earth, from: CGPoint(x: 0, y: horizon), to: CGPoint(x: 0, y: h))
        let avenue: Path = Art.polygon([Kit.pt(164, horizon), Kit.pt(268, horizon), Kit.pt(430, h), Kit.pt(2, h)])
        let gravel: Kit.Stops = [(Art.color(0x5A5088), 0), (Art.color(0x3A3266), 1)]
        Art.fillLinear(&context, avenue, gravel, from: CGPoint(x: 216, y: horizon), to: CGPoint(x: 216, y: h))
        let ruts = Art.svg("M200,250 L130,404 M232,250 L302,404 M216,250 L216,404")
        Art.stroke(&context, ruts, Art.color(0x2A2450, 0.5), width: 1.4)
        Art.stroke(&context, Art.svg("M164,250 L2,404 M268,250 L430,404"), Art.color(0x8A80B8, 0.4), width: 1.6)
        cityWall(&context, x0: -4, x1: 110, y: horizon)
        cityWall(&context, x0: 322, x1: 436, y: horizon)
        palaceGate(&context, x: 216, y: horizon)
        Art.glow(&context, 216, horizon + 30, 120, Art.color(0xFFC65A), alpha: 0.14)
        Kit.sink(&context, size, card: 0x2A2350)
    }

    /// A stretch of the white city wall with its dark tiled cap, standing on `y`.
    static func cityWall(_ context: inout GraphicsContext, x0: CGFloat, x1: CGFloat, y: CGFloat) {
        let span: CGFloat = x1 - x0
        Kit.solid(&context, Art.rect(x0, y - 44, span, 44), Art.color(0x8E88A8), light: 0.16, shade: 0.2)
        Art.fill(&context, Art.rect(x0, y - 8, span, 8), Art.color(0x4A4468))
        let cap = Art.rect(x0 - 2, y - 54, span + 4, 11, radius: 3)
        Kit.solid(&context, cap, Art.color(0x22203A), light: 0.2, shade: 0.2)
        Art.stroke(&context, Art.line(x0, y - 54, x1, y - 54), Art.color(0x8A80B8, 0.5), width: 1.2)
    }

    /// A wide hipped roof with gently upturned ends: eaves at `eave`, ridge `rise` above it.
    static func gateRoof(_ context: inout GraphicsContext, half W: CGFloat, eave E: CGFloat, rise R: CGFloat) {
        var roof = Path()
        roof.move(to: Kit.pt(-W - 12, E - 9))
        roof.addQuadCurve(to: Kit.pt(-W + 40, E), control: Kit.pt(-W + 8, E + 2))
        roof.addLine(to: Kit.pt(W - 40, E))
        roof.addQuadCurve(to: Kit.pt(W + 12, E - 9), control: Kit.pt(W - 8, E + 2))
        roof.addQuadCurve(to: Kit.pt(W - 30, E - R), control: Kit.pt(W - 20, E - R * 0.4))
        roof.addLine(to: Kit.pt(-W + 30, E - R))
        roof.addQuadCurve(to: Kit.pt(-W - 12, E - 9), control: Kit.pt(-W + 20, E - R * 0.4))
        roof.closeSubpath()
        Kit.solid(&context, roof, Art.color(0x2A2840), light: 0.22, shade: 0.22, rim: 2)
        var tiles = Path()
        var tx: CGFloat = -W + 4
        while tx < W {
            tiles.move(to: Kit.pt(tx * 0.8, E - R + 2))
            tiles.addLine(to: Kit.pt(tx, E - 1))
            tx += 9
        }
        let shape = roof
        let lines = tiles
        Art.clipped(&context, to: shape) { c in
            Art.stroke(&c, lines, Art.color(0x4A4868, 0.7), width: 1.4, cap: .butt)
        }
        let ridge = Art.rect(-W + 24, E - R - 6, W * 2 - 48, 8, radius: 3)
        Kit.solid(&context, ridge, Art.color(0x1A1830), light: 0.2, shade: 0.2)
        // The curled ridge-end ornaments.
        let fin = Art.svg("M0,8 C-6,-4 0,-10 8,-8 L10,8Z")
        let finY: CGFloat = E - R - 6
        Art.group(&context, x: -W + 24, y: finY) { f in
            Art.fill(&f, fin, Art.color(0x6A5A3A))
        }
        Art.group(&context, x: W - 24, y: finY, scaleX: -1) { f in
            Art.fill(&f, fin, Art.color(0x6A5A3A))
        }
    }

    /// The great two-storey gate, the middle of its foot at (x, y): red pillars, white walls,
    /// two wide dark roofs; about 300 wide and 230 high.
    static func palaceGate(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat) {
        Art.group(&context, x: x, y: y) { g in
            Kit.shadow(&g, 0, 2, width: 300, alpha: 0.36)
            Kit.solid(&g, Art.rect(-132, -10, 264, 12, radius: 2), Art.color(0x5A5478), light: 0.2, shade: 0.2)
            // Outer bays: white wall. Middle bays: open passages with warm light beyond.
            Art.fill(&g, Art.rect(-110, -96, 220, 86), Art.color(0xA8A0BC))
            let passages: [CGFloat] = [-61, -17, 27]
            for px in passages {
                let door = Art.rect(px, -94, 34, 84)
                let warm: Kit.Stops = [(Art.color(0x3A2438), 0), (Art.color(0xC88A4A), 1)]
                Art.fillLinear(&g, door, warm, from: CGPoint(x: 0, y: -94), to: CGPoint(x: 0, y: -10))
            }
            Art.glow(&g, 0, -30, 90, Art.color(0xFFC65A), alpha: 0.3)
            let pillarX: [CGFloat] = [-110, -66, -22, 22, 66, 110]
            for px in pillarX {
                Kit.solid(&g, Art.rect(px - 5, -98, 10, 88), Art.color(0xB8403A), light: 0.24, shade: 0.24)
            }
            Kit.solid(&g, Art.rect(-118, -106, 236, 10), Art.color(0x8A2E2E), light: 0.2, shade: 0.2)
            Art.fill(&g, Art.rect(-122, -114, 244, 8), Art.color(0x4A2E36))
            gateRoof(&g, half: 140, eave: -112, rise: 30)
            // The upper storey.
            Art.fill(&g, Art.rect(-96, -172, 192, 32), Art.color(0xA8A0BC))
            Art.stroke(&g, Art.svg("M-96,-172 L-96,-140 M-48,-172 L-48,-140 M0,-172 L0,-140 M48,-172 L48,-140 M96,-172 L96,-140"), Art.color(0xB8403A), width: 7, cap: .butt)
            Art.stroke(&g, Art.line(-104, -142, 104, -142), Art.color(0x8A2E2E), width: 4, cap: .butt)
            Art.stroke(&g, Art.line(-100, -150, 100, -150), Art.color(0x8A2E2E, 0.8), width: 2, cap: .butt)
            Art.fill(&g, Art.rect(-100, -178, 200, 6), Art.color(0x4A2E36))
            gateRoof(&g, half: 128, eave: -176, rise: 44)
        }
    }

    // MARK: see-court-poem

    /// A folded poem on pale paper tied with a thin cord to a sprig of autumn grass, a writing
    /// brush lying beside it, on deep indigo in a soft lamplight.
    static func courtPoemPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let back: Kit.Stops = [(Art.color(0x141640), 0), (Art.color(0x2B2A5E), 0.7), (Art.color(0x23224E), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, h), back, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: h))
        Art.glow(&context, 140, 120, 280, Art.color(0xFFE9B8), alpha: 0.14)
        Art.group(&context, x: 216, y: 300, scale: 0.3, scaleX: 3.4) { p in
            Art.glow(&p, 0, 0, 120, Art.color(0x6A6AB8), alpha: 0.3)
        }
        poemSprig(&context)
        poemLetter(&context, x: 205, y: 176)
        writingBrush(&context, x: 236, y: 292)
        Kit.sink(&context, size, card: 0x2B2A5E)
    }

    /// The sprig of autumn pampas grass: stem, long blades and a feathery plume at the top.
    static func poemSprig(_ context: inout GraphicsContext) {
        var stem = Path()
        stem.move(to: Kit.pt(146, 300))
        stem.addQuadCurve(to: Kit.pt(278, 64), control: Kit.pt(190, 160))
        Art.stroke(&context, stem, Art.color(0x8A7A3E), width: 4)
        Art.stroke(&context, stem, Art.color(0xE8D8A0, 0.4), width: 1.2)
        var blades = Path()
        leaf(&blades, 160, 262, 82, 190, 5)
        leaf(&blades, 174, 232, 300, 176, 5)
        leaf(&blades, 196, 178, 122, 106, 4)
        leaf(&blades, 232, 126, 330, 98, 3.5)
        Kit.solid(&context, blades, Art.color(0x9A8A4A), light: 0.22, shade: 0.24)
        var plume = Path()
        for i in 0..<9 {
            let t: CGFloat = CGFloat(i) / 8
            let sx: CGFloat = 278 - 16 * t
            let sy: CGFloat = 64 + 30 * t
            let ex: CGFloat = sx + 34 + 10 * t
            let ey: CGFloat = sy + 40 - 6 * t
            plume.move(to: Kit.pt(sx, sy))
            plume.addQuadCurve(to: Kit.pt(ex, ey), control: Kit.pt(sx + 30, sy - 6))
        }
        Art.glow(&context, 294, 92, 64, Art.color(0xF6E8C8), alpha: 0.2)
        Art.stroke(&context, plume, Art.color(0xEADCB8, 0.85), width: 2.2)
        Art.stroke(&context, plume, Art.color(0xFFFFFF, 0.3), width: 0.8)
    }

    /// The folded letter tied to the stem, its middle at (x, y), lying along the stem.
    static func poemLetter(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat) {
        Art.group(&context, x: x, y: y, rotate: Kit.deg(28)) { g in
            Art.glow(&g, 0, 0, 110, Art.color(0xFFF3D8), alpha: 0.18)
            let sheet = Art.rect(-24, -74, 48, 148, radius: 3)
            let paper: Kit.Stops = [(Art.color(0xFBF5E6), 0), (Art.color(0xE6DCC4), 1)]
            Kit.solid(&g, sheet, stops: paper, light: 0.2, shade: 0.24)
            let flap: Path = Art.polygon([Kit.pt(-24, -74), Kit.pt(24, -74), Kit.pt(24, -50)])
            Art.fill(&g, flap, Art.color(0xD8CCB0))
            Art.stroke(&g, Art.line(-24, -74, 24, -50), Art.color(0xB8AA8A), width: 1.2)
            Art.stroke(&g, Art.line(0, -46, 0, 72), Art.color(0xC8BCA0, 0.7), width: 1)
            // The cord round the letter and the stem, and its bow.
            Art.stroke(&g, Art.line(-26, -6, 26, -6), Art.color(0x9A3A5A), width: 2.4)
            Art.stroke(&g, Art.line(-26, 2, 26, 2), Art.color(0x9A3A5A), width: 2.4)
            Art.stroke(&g, Art.svg("M26,-2 C40,-16 46,-2 34,2 C46,8 40,20 26,4"), Art.color(0xB84A6A), width: 2)
            Art.stroke(&g, Art.svg("M28,2 L40,34 M28,2 L50,26"), Art.color(0xB84A6A), width: 1.6)
        }
    }

    /// A writing brush lying a little aslant, its middle at (x, y), the tip to the right.
    static func writingBrush(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat) {
        Kit.shadow(&context, x, y + 10, width: 220, alpha: 0.3)
        Art.group(&context, x: x, y: y, rotate: Kit.deg(-6)) { g in
            Art.stroke(&g, Art.svg("M-104,0 C-116,-8 -118,8 -106,4"), Art.color(0x9A3A5A), width: 1.6)
            let handle = Art.rect(-104, -5, 170, 10, radius: 5)
            Kit.solid(&g, handle, Art.color(0xC9A45E), light: 0.26, shade: 0.24)
            Art.stroke(&g, Art.svg("M-60,-5 L-60,5 M0,-5 L0,5"), Art.color(0x8A6A3A), width: 1.6, cap: .butt)
            Art.fill(&g, Art.rect(62, -6, 10, 12, radius: 2), Art.color(0x2A1E2A))
            let tip = Art.svg("M72,-6 C86,-7 102,-2 112,0 C102,2 86,7 72,6Z")
            Kit.solid(&g, tip, Art.color(0x1A1626), light: 0.2, shade: 0.1)
            Art.stroke(&g, Art.line(-98, -2.5, 60, -2.5), Art.color(0xFFF0C0, 0.4), width: 1.2)
        }
    }

    // MARK: see-moon-viewing

    /// A small wooden stand with a pile of round white rice dumplings, a vase of pampas grass
    /// beside it on the veranda, and the full moon above.
    static func moonViewingPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let deckY: CGFloat = 262
        let sky: Kit.Stops = [(Art.color(0x0C1438), 0), (Art.color(0x16224A), 0.6), (Art.color(0x24346A), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, deckY), sky, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: deckY))
        Kit.stars(&context, width: w, maxY: 220, count: 22, seed: 331)
        Kit.moon(&context, 150, 88, 42, color: Art.color(0xFFF6DC))
        Art.blurred(&context, radius: 4, opacity: 0.4) { c in
            Art.fill(&c, Art.rect(90, 116, 150, 9, radius: 4.5), Art.color(0xC9D6F2))
        }
        let hills = Kit.ridge(width: w, y: 238, amp: 14, seed: 332, bottom: deckY + 4)
        Art.fill(&context, hills, Art.color(0x131A3C))
        let boards: Kit.Stops = Kit.stops(0x4A3C4A, 0x2A2236)
        Art.fillLinear(&context, Art.rect(0, deckY, w, h - deckY), boards, from: CGPoint(x: 0, y: deckY), to: CGPoint(x: 0, y: h))
        var seams = Path()
        let seamY: [CGFloat] = [278, 300, 328, 362]
        for y in seamY {
            seams.move(to: Kit.pt(0, y))
            seams.addLine(to: Kit.pt(w, y))
        }
        Art.stroke(&context, seams, Art.color(0x1A1626, 0.6), width: 1.4, cap: .butt)
        Art.stroke(&context, Art.line(0, deckY, w, deckY), Art.color(0xC9D6F2, 0.3), width: 1.6, cap: .butt)
        pampasVase(&context, x: 316, y: 290)
        dumplingStand(&context, x: 186, y: 292)
        Kit.sink(&context, size, card: 0x1C2A52)
    }

    /// The plain wooden offering stand with its neat pile of ten dumplings, foot at (x, y).
    static func dumplingStand(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat) {
        Kit.shadow(&context, x, y, width: 120, alpha: 0.4)
        Art.group(&context, x: x, y: y) { g in
            let wood = Art.color(0xA88A66)
            let foot = Art.svg("M-44,0 L-38,-40 L38,-40 L44,0Z")
            Kit.solid(&g, foot, wood, light: 0.24, shade: 0.26)
            let hole = Art.svg("M-14,-20 C-8,-30 8,-30 14,-20 C8,-12 -8,-12 -14,-20Z")
            Art.fill(&g, hole, Art.color(0x2A2236))
            let tray = Art.rect(-62, -52, 124, 12, radius: 2)
            Kit.solid(&g, tray, Art.color(0xC0A27A), light: 0.26, shade: 0.2)
            Art.stroke(&g, Art.line(-60, -51, 60, -51), Art.color(0xF0E2C8, 0.5), width: 1.4)
            let sheet: Path = Art.polygon([Kit.pt(-54, -52), Kit.pt(54, -52), Kit.pt(46, -56), Kit.pt(-46, -56)])
            Art.fill(&g, sheet, Art.color(0xF4F0E6))
            let rows: [(CGFloat, CGFloat, Int)] = [(-65, -39, 4), (-87, -26, 3), (-109, -13, 2), (-131, 0, 1)]
            for row in rows {
                for i in 0..<row.2 {
                    let cx: CGFloat = row.1 + CGFloat(i) * 26
                    Kit.solid(&g, Art.circle(cx, row.0, 13), Art.color(0xF6F2E6), light: 0.3, shade: 0.3)
                }
            }
            Art.glow(&g, -16, -120, 40, Color.white, alpha: 0.16)
        }
    }

    /// A glazed vase with three plumes of pampas grass, its foot at (x, y).
    static func pampasVase(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat) {
        Kit.shadow(&context, x, y, width: 70, alpha: 0.4)
        Art.group(&context, x: x, y: y) { g in
            let tips: [(CGFloat, CGFloat)] = [(-34, -228), (6, -244), (40, -214)]
            var stems = Path()
            for tip in tips {
                stems.move(to: Kit.pt(0, -66))
                stems.addQuadCurve(to: Kit.pt(tip.0, tip.1), control: Kit.pt(tip.0 * 0.3, -150))
            }
            Art.stroke(&g, stems, Art.color(0x8A7A4E), width: 2.4)
            var blades = Path()
            leaf(&blades, -2, -70, -70, -150, 3.5)
            leaf(&blades, 2, -70, 64, -134, 3.5)
            leaf(&blades, 0, -72, -20, -176, 3)
            Art.fill(&g, blades, Art.color(0x6A6A3E))
            var plumes = Path()
            for tip in tips {
                for j in 0..<6 {
                    let s: CGFloat = CGFloat(j) * 7
                    plumes.move(to: Kit.pt(tip.0 - s * 0.1, tip.1 + s))
                    plumes.addQuadCurve(to: Kit.pt(tip.0 + 16 + s * 0.2, tip.1 + s + 30), control: Kit.pt(tip.0 + 14, tip.1 + s - 2))
                }
            }
            Art.glow(&g, 6, -220, 70, Art.color(0xF6E8C8), alpha: 0.16)
            Art.stroke(&g, plumes, Art.color(0xE6D8B8, 0.85), width: 2.2)
            Art.stroke(&g, plumes, Art.color(0xFFFFFF, 0.3), width: 0.8)
            let pot = Art.svg("M-24,0 C-34,-20 -30,-46 -14,-56 L-10,-68 L10,-68 L14,-56 C30,-46 34,-20 24,0Z")
            let glaze: Kit.Stops = [(Art.color(0x5A6A8A), 0), (Art.color(0x34405E), 1)]
            Kit.solid(&g, pot, stops: glaze, light: 0.28, shade: 0.26, rim: 1.6)
            Art.fill(&g, Art.ellipse(0, -68, 10, 3), Art.color(0x1A1E34))
        }
    }
}

// MARK: - Portraits, face chips and the cover

extension MoonChildArt {
    /// Kaguya-hime, half figure, turned a little toward the full moon behind her shoulder; a
    /// soft glow round her; calm and a little sad. Deep indigo behind.
    static func kaguyaPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0x4A5AA8, bottom: 0x141A4A, halo: 0xFFE9B8, rays: false) { g in
            Kit.stars(&g, width: 432, maxY: 260, count: 22, seed: 341)
            Kit.moon(&g, 340, 112, 58, color: Art.color(0xFFF6DC))
            Art.glow(&g, 214, 180, 210, Art.color(0xFFF3C8), alpha: 0.26)
            Art.group(&g, x: 212, y: 130, scale: 2.1) { b in
                kaguyaBust(&b, look: CGPoint(x: 0.5, y: -0.3))
            }
            var motes = Path()
            let places: [(CGFloat, CGFloat)] = [(84, 196), (100, 262), (118, 318), (330, 300), (356, 240), (74, 140)]
            for place in places {
                motes.addPath(Art.circle(place.0, place.1, 2.2))
            }
            Art.fill(&g, motes, Art.color(0xFFF6D8, 0.6))
        }
    }

    /// The old Bamboo-Cutter, half figure in his hemp jacket, holding his short knife low and
    /// looking down in wonder, a gold light on his face from below; dark stems behind.
    static func cutterPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0x3F7D5A, bottom: 0x0F2A26, halo: 0xFFE08A, rays: false) { g in
            cane(&g, x: 46, baseY: 420, top: -20, half: 18, tone: 0x1F4A3A, lean: 6, seed: 351)
            cane(&g, x: 112, baseY: 420, top: -20, half: 11, tone: 0x17382C, lean: -4, seed: 352)
            cane(&g, x: 330, baseY: 420, top: -20, half: 12, tone: 0x17382C, lean: 4, seed: 353)
            cane(&g, x: 392, baseY: 420, top: -20, half: 19, tone: 0x1F4A3A, lean: -8, seed: 354)
            leafSpray(&g, x: 60, y: 30, reach: 100, count: 16, color: Art.color(0x0F2A26), seed: 355, droop: 0.7)
            leafSpray(&g, x: 380, y: 24, reach: 100, count: 16, color: Art.color(0x0F2A26), seed: 356, droop: 0.7)
            Art.group(&g, x: 216, y: 132, scale: 2.1) { b in
                Kit.bust(&b, cutterLook(), look: CGPoint(x: -0.2, y: 0.8), mouth: .oh)
            }
            // The gold light from below, from the shining stem out of the picture.
            Art.glow(&g, 216, 404, 230, ramp.glowColor, alpha: 0.3)
            Art.glow(&g, 214, 178, 72, ramp.glowColor, alpha: 0.14)
            // His big careful hand, holding the knife low.
            Art.group(&g, x: 150, y: 352) { k in
                Art.group(&k, rotate: Kit.deg(-20), scale: 2.4) { n in
                    nata(&n)
                }
                let fist = Art.svg("M-12,-14 C0,-20 22,-18 30,-8 C34,2 30,14 18,17 C4,19 -12,14 -14,2 C-15,-6 -14,-11 -12,-14Z")
                Kit.solid(&k, fist, Kit.personTone(0xD9A77C, 1), light: 0.26, shade: 0.24)
                Art.stroke(&k, Art.svg("M0,-12 C2,-4 2,6 0,14 M10,-13 C12,-4 12,6 10,15"), Kit.personTone(0xD9A77C, 0.72), width: 1.4)
                Art.stroke(&k, Art.svg("M-12,-14 C-4,-10 6,-8 14,-10"), Kit.personTone(0xD9A77C, 1.12), width: 1.6)
            }
        }
    }

    /// Kaguya-hime's face chip: her calm face framed by the long straight hair, softly lit.
    static func kaguyaFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0x4A4FA8) { g in
            Art.glow(&g, 0, 0, 52, Art.color(0xFFF3C8), alpha: 0.3)
            Art.group(&g, x: 0, y: 6, scale: 1.3) { f in
                let fall = Art.svg("M-31,-8 C-33,-36 -15,-40 0,-40 C15,-40 33,-36 31,-8 L36,60 L-36,60Z")
                Art.fill(&f, fall, Art.color(hairHex))
                Kit.personHead(&f, kaguyaLook(), mouth: .smile)
                kaguyaLocks(&f)
            }
        }
    }

    /// The Bamboo-Cutter's face chip: white topknot and beard, kind eyes, a gold light below.
    static func cutterFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0x2F6B4A) { g in
            Art.glow(&g, 0, 46, 54, ramp.glowColor, alpha: 0.3)
            Art.group(&g, x: 0, y: 8, scale: 1.25) { f in
                Kit.personHead(&f, cutterLook(), look: CGPoint(x: -0.2, y: 0.3), mouth: .smile)
            }
        }
    }

    /// The Emperor's face chip: a grave, gentle young face under the tall black court cap.
    static func emperorFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0x6A3A8E) { g in
            Art.group(&g, x: 0, y: 16, scale: 1.05) { f in
                Kit.personHead(&f, emperorLook(), mouth: .flat)
                courtCap(&f)
            }
        }
    }

    /// The cover: night in the grove, the old man kneeling by the one cut stem that glows
    /// gold, the tiny girl inside it looking up at him; dark bamboo and indigo sky all round.
    static func coverPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.cover(&context, size, wash: 0.03, vignette: 0.14) { g, frame in
            coverGrove(&g, frame)
            coverSubject(&g, frame)
        }
    }

    /// The sky, the far and middle canes and the floor of the cover, in cover units.
    static func coverGrove(_ g: inout GraphicsContext, _ frame: Kit.CoverFrame) {
        let H: CGFloat = frame.H
        let hd: CGFloat = frame.hd
        let box = CGSize(width: 240, height: hd)
        let light = night()
        Kit.sky(&g, box, horizon: H, light: light)
        Kit.stars(&g, width: 240, maxY: H - 50, count: 22, seed: 361)
        caneRank(&g, x0: -6, x1: 246, baseY: H + 2, top: -10, count: 12, half: 2.4, tone: caneFarHex, seed: 362)
        ArtStyle.atmosphere(&g, width: 240, top: H - 120, bottom: H + 6, color: light.haze, alpha: 0.2)
        let earth: Kit.Stops = Kit.stops(0x12302A, 0x0A1A1C)
        Kit.ground(&g, width: 240, top: H, bottom: hd, stops: earth, tooth: Art.color(0x9FC2A6))
        floorLitter(&g, box, top: H, color: Art.color(0x2A5A44), seed: 363)
        caneRank(&g, x0: -6, x1: 246, baseY: H + 6, top: -10, count: 6, half: 4, tone: caneMidHex, seed: 364)
        let sprayX: [CGFloat] = [30, 110, 190]
        for (i, x) in sprayX.enumerated() {
            leafSpray(&g, x: x, y: 4, reach: 50, count: 12, color: Art.color(0x0C2024), seed: 368 &+ UInt32(i), droop: 0.7)
        }
    }

    /// The shining stem, the tiny girl and the kneeling old man, and the near framing.
    static func coverSubject(_ g: inout GraphicsContext, _ frame: Kit.CoverFrame) {
        let k: CGFloat = frame.k
        let base: CGFloat = frame.H + 12 * k
        Art.group(&g, x: 112, y: base, scale: 0.3, scaleX: 3) { p in
            Art.glow(&p, 0, 0, 90 * k, ramp.glowColor, alpha: 0.4)
        }
        cane(&g, x: 62, baseY: base + 4, top: -10, half: 5 * k, tone: caneNearHex, lean: -3, glowSide: 1, glow: 0.4, reach: 120 * k, seed: 365)
        Art.group(&g, x: 104, y: base, scale: 0.95 * k) { s in
            cutStem(&s)
        }
        Kit.shadow(&g, 150, base, width: 46 * k, alpha: 0.34)
        Art.group(&g, x: 150, y: base, scale: 0.62 * k) { c in
            cutter(&c, pose: .kneel, look: CGPoint(x: -0.7, y: 0.4), mouth: .oh)
        }
        let faceY: CGFloat = base - 58 * k
        Art.glow(&g, 140, faceY, 30 * k, ramp.glowColor, alpha: 0.2)
        let edge: CGFloat = frame.hd + 6
        cane(&g, x: 232, baseY: edge, top: -10, half: 8, tone: 0x0A1A1C, lean: -4, seed: 366)
        leafSpray(&g, x: 230, y: 6, reach: 70, count: 16, color: Art.color(0x08161A), seed: 367, droop: 0.8)
    }
}
