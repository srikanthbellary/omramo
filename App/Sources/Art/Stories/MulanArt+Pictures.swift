import SwiftUI
import OmramoCore

// The tap-to-see pictures (432 × 404), the two character-card portraits (432 × 400), the face
// chips (100 × 100) and the cover of "The Ballad of Mulan".

extension MulanArt {
    // MARK: - see-loom

    static func loomPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let wall: Kit.Stops = [(Art.color(0xEAD6AA), 0), (Art.color(0xD2B07A), 0.7), (Art.color(0xB8905E), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, 300), wall, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: 300))
        earthCourses(&context, CGRect(x: 0, y: 20, width: w, height: 270), seed: 101)
        Art.glow(&context, 110, 90, 240, Art.color(0xFFF2CC), alpha: 0.4)
        Kit.ground(&context, width: w, top: 296, bottom: h, stops: Kit.stops(0x9A7048, 0x7A5634, 0x5A3A1E), seed: 102)
        loom(&context, x: 322, baseY: 304, scale: 1.8, cloth: 0.55)
        shuttle(&context, x: 286, y: 150, scale: 2.2)
        // Two hanks of hemp thread on the floor, ready for the shuttle.
        let hanks: [(CGFloat, CGFloat)] = [(86, 312), (118, 318)]
        for hank in hanks {
            Kit.shadow(&context, hank.0, hank.1 + 8, width: 40)
            let skein = Art.ellipse(hank.0, hank.1, 18, 10)
            Kit.solid(&context, skein, Art.color(0xE6D6AE), light: 0.3, shade: 0.24)
            Art.stroke(&context, Art.svg("M\(hank.0 - 14),\(hank.1 - 3) C\(hank.0 - 4),\(hank.1 + 4) \(hank.0 + 6),\(hank.1 + 4) \(hank.0 + 15),\(hank.1 - 3)"), Art.color(0xB8A27A), width: 1.2)
        }
        Kit.sink(&context, size, card: 0x5A3A1E)
    }

    // MARK: - see-yellow-river

    static func riverPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let light = evening()
        let horizon: CGFloat = 170
        Kit.sky(&context, size, horizon: horizon, light: light)
        Kit.sun(&context, 200, horizon - 30, 14, light: light)
        Kit.mountain(&context, cx: 216, baseY: horizon + 2, width: 260, height: 30, color: light.far.opacity(0.8))
        ArtStyle.atmosphere(&context, width: w, top: horizon - 50, bottom: horizon, color: light.haze, alpha: 0.4)
        let river = Art.polygon([CGPoint(x: 180, y: horizon), CGPoint(x: 252, y: horizon), CGPoint(x: 432, y: h), CGPoint(x: 0, y: h)])
        let flow: Kit.Stops = [(Art.color(0xD6B272), 0), (Art.color(0xB68C4C), 0.4), (Art.color(0x8E6A34), 1)]
        Art.fillLinear(&context, river, flow, from: CGPoint(x: 0, y: horizon), to: CGPoint(x: 0, y: h))
        Art.clipped(&context, to: river) { g in
            Kit.glints(&g, x: 206, top: horizon, depth: 120, color: Art.color(0xFFF0C8), count: 30, seed: 103)
            Kit.swells(&g, width: w, top: horizon + 6, bottom: h, rows: 9, crest: Art.color(0xF2D9A0), seed: 104)
        }
        // The two cliffs of yellow earth.
        let left = Art.svg("M0,60 L120,70 C140,72 150,90 156,110 L196,\(horizon) C150,240 90,320 40,404 L0,404 Z")
        let right = Art.svg("M432,80 L320,92 C300,94 294,112 288,130 L240,\(horizon) C290,240 360,320 410,404 L432,404 Z")
        cliffFace(&context, left, light: light, seed: 105)
        cliffFace(&context, right, light: light, seed: 106)
        // Driftwood carried down the middle.
        let log = Art.svg("M180,262 C200,256 240,256 262,260 L262,266 C240,266 200,268 180,268 Z")
        Kit.solid(&context, log, Art.color(0x5E4632), light: 0.3, shade: 0.26)
        Art.stroke(&context, Art.svg("M262,262 C270,252 276,254 282,246 M262,264 C272,266 278,262 286,266 M196,258 C190,248 186,246 178,244"), Art.color(0x5E4632), width: 2)
        Kit.ripples(&context, 220, 268, 110, count: 2, color: Art.color(0xF2D9A0), opacity: 0.6)
        Kit.birds(&context, 150, 112, scale: 0.6, color: Art.color(0x8A7050, 0.7))
        Kit.sink(&context, size, card: 0x6A4A1C)
    }

    /// A loess cliff face: the earth's own gradient, vertical weathering cracks, a lit edge.
    static func cliffFace(_ context: inout GraphicsContext, _ shape: Path, light: Kit.Light, seed: UInt32) {
        let earth: Kit.Stops = [(Art.color(0xE6C88C), 0), (Art.color(0xCFA868), 0.6), (Art.color(0xA88048), 1)]
        Kit.solid(&context, shape, stops: earth, light: 0.3, shade: 0.28, rim: 2.4)
        let box = shape.boundingRect
        var random = ArtRandom(seed)
        Art.clipped(&context, to: shape) { g in
            var cracks = Path()
            for _ in 0..<26 {
                let cx: CGFloat = box.minX + box.width * Kit.rnd(&random)
                let cy: CGFloat = box.minY + box.height * Kit.rnd(&random) * 0.8
                let length: CGFloat = 20 + Kit.rnd(&random) * 50
                cracks.addPath(Art.line(cx, cy, cx + 2, cy + length))
            }
            Art.stroke(&g, cracks, Art.color(0x8A6436, 0.35), width: 1.4)
            var ledges = Path()
            var y: CGFloat = box.minY + 30
            while y < box.maxY {
                ledges.addPath(Art.line(box.minX, y, box.maxX, y + 4))
                y += 34
            }
            Art.stroke(&g, ledges, Art.color(0xF2DCA8, 0.35), width: 2)
        }
        _ = light
    }

    // MARK: - see-northern-grasslands

    static func grasslandsPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let light = afternoon()
        let horizon: CGFloat = 236
        Kit.sky(&context, size, horizon: horizon, light: light)
        Kit.cloud(&context, 300, 70, scale: 0.6, color: Color.white.opacity(0.55))
        let far: Path = Kit.ridge(width: w, y: horizon - 10, amp: 8, seed: 107, bottom: horizon + 4, step: 16)
        Art.fill(&context, far, light.far)
        ArtStyle.atmosphere(&context, width: w, top: horizon - 30, bottom: horizon, color: light.haze, alpha: 0.4)
        Kit.ground(&context, width: w, top: horizon, bottom: h, stops: Kit.stops(0xB8BC80, 0x8E9C58, 0x5E6E34), seed: 108)
        windGrass(&context, in: CGRect(x: 0, y: horizon + 4, width: w, height: h - horizon), count: 110, seed: 109)
        var look = bayLook()
        look.body = 0xA8804E
        look.belly = 0xD8BC8C
        let horseY: CGFloat = 312
        Kit.shadow(&context, 222, horseY, width: 230, alpha: 0.3)
        Art.group(&context, x: 230, y: horseY, scale: 1.25) { g in
            Kit.beast(&g, look, pose: .stand, mood: .proud, look: CGPoint(x: -0.3, y: 0))
            let head: CGPoint = Kit.beastHeadCentre(look, pose: .stand)
            let mane = Art.svg("M\(head.x + 14),\(head.y - 16) C\(head.x + 30),\(head.y - 10) \(head.x + 44),\(head.y + 6) \(head.x + 62),\(head.y + 18) M\(head.x + 20),\(head.y - 8) C\(head.x + 36),\(head.y) \(head.x + 50),\(head.y + 16) \(head.x + 70),\(head.y + 26)")
            Art.stroke(&g, mane, Art.color(0x2A1C16, 0.85), width: 3)
        }
        windGrass(&context, in: CGRect(x: 0, y: 300, width: w, height: h - 300), count: 70, seed: 110)
        Kit.sink(&context, size, card: 0x3E4A26)
    }

    /// Grass bent by a wind from the left: long blades all leaning right.
    static func windGrass(_ context: inout GraphicsContext, in rect: CGRect, count: Int, seed: UInt32) {
        var random = ArtRandom(seed)
        var dark = Path()
        var lit = Path()
        for index in 0..<max(0, count) {
            let t: CGFloat = Kit.rnd(&random)
            let x: CGFloat = rect.minX + rect.width * Kit.rnd(&random)
            let y: CGFloat = rect.minY + rect.height * t * t
            let length: CGFloat = 8 + 22 * t
            var blade = Path()
            blade.move(to: CGPoint(x: x, y: y))
            blade.addQuadCurve(to: CGPoint(x: x + length * 0.8, y: y - length * 0.6), control: CGPoint(x: x + length * 0.1, y: y - length * 0.7))
            if index % 3 == 0 {
                lit.addPath(blade)
            } else {
                dark.addPath(blade)
            }
        }
        Art.stroke(&context, dark, Art.color(0x5E6E34, 0.8), width: 1.4)
        Art.stroke(&context, lit, Art.color(0xD8D49A, 0.8), width: 1.4)
    }

    // MARK: - see-the-ballad

    static func balladPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let table: Kit.Stops = [(Art.color(0x8A4A3A), 0), (Art.color(0x6A3430), 0.6), (Art.color(0x4A2430), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, h), table, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: h))
        Art.glow(&context, 140, 90, 260, Art.color(0xFFE0B0), alpha: 0.3)
        Kit.shadow(&context, 216, 292, width: 380, alpha: 0.35)
        // Indigo cover boards under the pages, then the two pages bowing up to the gutter.
        let boards = Art.polygon([CGPoint(x: 52, y: 92), CGPoint(x: 380, y: 92), CGPoint(x: 392, y: 290), CGPoint(x: 40, y: 290)])
        Kit.solid(&context, boards, Art.color(0x2E3A5E), light: 0.24, shade: 0.24)
        let leftPage = Art.svg("M60,100 C110,92 170,94 214,108 L214,284 C170,272 110,270 52,280 Z")
        let rightPage = Art.svg("M218,108 C262,94 322,92 372,100 L380,280 C322,270 262,272 218,284 Z")
        let paper: Kit.Stops = [(Art.color(0xF6EBD0), 0), (Art.color(0xEADBB8), 1)]
        Kit.solid(&context, leftPage, stops: paper, light: 0.2, shade: 0.14)
        Kit.solid(&context, rightPage, stops: paper, light: 0.16, shade: 0.2)
        let gutter: Kit.Stops = [(ArtStyle.coolShade.opacity(0), 0), (ArtStyle.coolShade.opacity(0.22), 1)]
        Art.fillLinear(&context, Art.rect(184, 100, 32, 186), gutter, from: CGPoint(x: 184, y: 0), to: CGPoint(x: 216, y: 0))
        Art.stroke(&context, Art.line(216, 108, 216, 284), Art.color(0xB8A47A), width: 1.4)
        // Ruled columns and brush strokes running top to bottom, read right to left.
        brushColumns(&context, x0: 76, x1: 200, top: 116, bottom: 266, seed: 111)
        brushColumns(&context, x0: 300, x1: 362, top: 116, bottom: 266, seed: 112)
        // The small ink drawing of the two hares running side by side.
        inkHare(&context, x: 262, y: 196, scale: 0.9)
        inkHare(&context, x: 270, y: 214, scale: 0.9)
        Art.stroke(&context, Art.svg("M228,232 C246,229 270,231 292,228"), Art.color(0x2A1E1A, 0.45), width: 1.2)
        Art.fill(&context, Art.rect(344, 240, 14, 14, radius: 2), Art.color(0xC8352B, 0.85))
        Kit.sink(&context, size, card: 0x4A2430)
    }

    /// Vertical columns of brush-written strokes between x0 and x1 (suggestion, not real text).
    static func brushColumns(_ context: inout GraphicsContext, x0: CGFloat, x1: CGFloat, top: CGFloat, bottom: CGFloat, seed: UInt32) {
        var random = ArtRandom(seed)
        var rules = Path()
        var strokes = Path()
        var x: CGFloat = x1
        while x > x0 {
            rules.addPath(Art.line(x + 8, top - 4, x + 8, bottom + 4))
            var y: CGFloat = top
            while y < bottom - 8 {
                let kind: CGFloat = Kit.rnd(&random)
                if kind < 0.35 {
                    strokes.addPath(Art.line(x - 4, y + 2, x + 4, y + 1))
                    strokes.addPath(Art.line(x, y - 1, x - 1, y + 7))
                } else if kind < 0.7 {
                    strokes.addPath(Art.line(x - 4, y, x + 3, y + 5))
                    strokes.addPath(Art.line(x + 3, y, x - 3, y + 7))
                } else {
                    strokes.addPath(Art.line(x - 4, y + 1, x + 4, y + 1))
                    strokes.addPath(Art.line(x - 3, y + 5, x + 3, y + 5))
                }
                y += 12
            }
            x -= 17
        }
        Art.stroke(&context, rules, Art.color(0xC8452B, 0.25), width: 0.8)
        Art.stroke(&context, strokes, Art.color(0x2A1E1A, 0.82), width: 1.9)
    }

    /// A hare running left, drawn in a few ink strokes, about 44 long at scale 1.
    static func inkHare(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, scale: CGFloat) {
        Art.group(&context, x: x, y: y, scale: scale) { g in
            let ink: Color = Art.color(0x2A1E1A, 0.8)
            let body = Art.svg("M-18,-4 C-14,-12 4,-14 14,-8 C20,-4 20,2 14,4 C4,6 -10,4 -18,-4 Z")
            Art.fill(&g, body, ink.opacity(0.65))
            Art.fill(&g, Art.ellipse(-20, -8, 6, 5), ink.opacity(0.75))
            let limbs = Art.svg("M-22,-11 C-16,-18 -8,-20 0,-20 M-21,-12 C-14,-21 -6,-23 2,-23 M-12,2 L-26,6 M10,2 C18,6 24,6 30,4 M14,0 C20,-2 26,-4 30,-8")
            Art.stroke(&g, limbs, ink, width: 1.6)
        }
    }

    // MARK: - Portraits

    static func mulanPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0xC8452B, bottom: 0x3A1814, halo: 0xF2DCA0, rays: false) { g in
            Art.group(&g, x: 216, y: 150, scale: 2.2) { b in
                Kit.bust(&b, mulanSoldierLook(), look: .zero, mouth: .flat)
                // The tunic's crossed collar and belt.
                Art.stroke(&b, Art.svg("M-14,36 L8,70 M14,36 L-2,52"), Art.color(0x3A2A22), width: 3)
                Art.fill(&b, Art.rect(-60, 118, 120, 9), Art.color(0x3A2418))
                // The bridle held against her chest: leather straps, the iron bit ring.
                let straps = Art.svg("M-70,60 C-50,70 -34,84 -20,96 M-70,74 C-52,84 -36,96 -22,104 M-16,104 C-10,120 -14,136 -22,150")
                Art.stroke(&b, straps, Art.color(0x4A2A1A), width: 4)
                Art.stroke(&b, Art.circle(-30, 116, 8), Art.color(0x6A7078), width: 3)
                let hand = Art.svg("M-28,90 C-20,84 -6,86 -2,96 C0,104 -6,110 -16,110 C-26,110 -32,100 -28,90 Z")
                Kit.solid(&b, hand, Art.color(0xC99468), light: 0.3, shade: 0.24)
                Art.stroke(&b, Art.svg("M-24,96 L-6,98 M-24,102 L-8,104"), Art.color(0xA87450), width: 1)
            }
            Kit.flecks(&g, in: CGRect(x: 20, y: 30, width: 392, height: 120), count: 18, seed: 120, color: Art.color(0xF6E8C8, 0.6), radius: 0.6...1.6)
        }
    }

    static func fatherPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0x4E6B7A, bottom: 0x18242E, halo: 0xE8D8B8, rays: false) { g in
            Art.group(&g, x: 216, y: 150, scale: 2.2) { b in
                Kit.bust(&b, fatherLook(), look: CGPoint(x: -0.1, y: 0.7), mouth: .flat)
                Art.fill(&b, Art.rect(-60, 122, 120, 8), Art.color(0x26343E))
                // His old helmet, battered and rusty, held in both hands.
                Art.group(&b, x: 0, y: 150, scale: 1.05) { m in
                    helmet(&m, head: .zero, frost: false)
                    var rust = Path()
                    rust.addPath(Art.ellipse(-14, -26, 5, 3))
                    rust.addPath(Art.ellipse(10, -18, 4, 2.6))
                    rust.addPath(Art.ellipse(-22, -12, 3, 2))
                    Art.fill(&m, rust, Art.color(rustHex, 0.6))
                    Art.stroke(&m, Art.svg("M4,-38 L8,-30 L5,-24"), Art.color(ironDarkHex), width: 1.4)
                }
                var hands = Path()
                hands.addPath(Art.svg("M-44,120 C-40,110 -28,110 -24,120 C-22,130 -30,138 -38,136 C-44,134 -46,126 -44,120 Z"))
                hands.addPath(Art.svg("M44,120 C40,110 28,110 24,120 C22,130 30,138 38,136 C44,134 46,126 44,120 Z"))
                Kit.solid(&b, hands, Art.color(0xD49E76), light: 0.3, shade: 0.24)
            }
        }
    }

    // MARK: - Face chips

    static func mulanFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xFADAD3) { g in
            Art.group(&g, x: 0, y: 6, scale: 1.2) { f in
                Kit.personHead(&f, mulanSoldierLook(), mouth: .smile)
            }
        }
    }

    static func fatherFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xDCE6EC) { g in
            Art.group(&g, x: 0, y: 2, scale: 1.12) { f in
                Kit.personHead(&f, fatherLook(), mouth: .smile)
            }
        }
    }

    static func comradeFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xE6EBCF) { g in
            Art.group(&g, x: 0, y: 8, scale: 1.18) { f in
                Art.group(&f, x: 8, y: -12, rotate: 0.32) { m in
                    helmet(&m, head: .zero, frost: false)
                }
                Kit.personHead(&f, comradeLook(), mouth: .grin)
            }
        }
    }

    // MARK: - Cover

    static func coverPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.cover(&context, size) { g, frame in
            let light = dawn()
            let H: CGFloat = frame.H
            let k: CGFloat = frame.k
            let area = CGSize(width: 240, height: frame.hd)
            Kit.sky(&g, area, horizon: H, light: light)
            Kit.sun(&g, 40, H - 26 * k, 8 * k, light: light)
            let peaks: [(CGFloat, CGFloat, CGFloat, UInt32)] = [(40, 120, 40, 3), (130, 150, 58, 5), (220, 120, 42, 7)]
            for peak in peaks {
                Kit.mountain(&g, cx: peak.0, baseY: H + 1, width: peak.1 * k, height: peak.2 * k, color: light.far, snow: Art.color(0xF4F6F8), seed: peak.3)
            }
            ArtStyle.atmosphere(&g, width: 240, top: H - 60 * k, bottom: H, color: light.haze, alpha: 0.4)
            Kit.ground(&g, width: 240, top: H, bottom: frame.hd, stops: Kit.stops(0xC9CBB4, 0xB4B292, 0x9C9676))
            earthWall(&g, x0: -10, x1: 250, baseY: H + 10 * k, height: 18 * k, color: wallTone, seed: 130)
            watchTower(&g, cx: 200, baseY: H + 12 * k, scale: 0.5 * k, seed: 131)
            watchTower(&g, cx: 30, baseY: H + 6 * k, scale: 0.28 * k, seed: 132)
            let foot: CGFloat = H + 40 * k
            Kit.shadow(&g, 124, foot, width: 90 * k, alpha: 0.3)
            Art.group(&g, x: 124, y: foot, scale: 0.42 * k) { r in
                rider(&r, mulanSoldierLook(), pose: .walk, armoured: true, frost: true)
                breath(&r, x: -14, y: -198, scale: 1)
            }
            Kit.flecks(&g, in: CGRect(x: 0, y: H + 2, width: 240, height: frame.hd - H), count: 20, seed: 133, color: Color.white.opacity(0.6), radius: 0.5...1.1)
            let twig = Art.svg("M250,-4 C226,10 210,14 192,12 M226,8 C220,0 214,-2 206,-4 M210,13 C204,20 198,22 190,22")
            Art.stroke(&g, twig, Art.color(0x3A3036, 0.85), width: 2.2)
        }
    }
}
