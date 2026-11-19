import SwiftUI
import OmramoCore

// Zal and the Simurgh: the four tap-to-see pictures, the two character-card portraits, the
// three face chips and the cover.

// MARK: - Tap-to-see pictures (432 × 404)

extension ZalArt {
    /// The Book of Kings: an open old Persian book, neat columns of script around a small
    /// painted picture of a rider, on a deep lapis ground.
    static func shahnamehPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        let h = size.height
        let ground: Kit.Stops = Kit.stops(0x2A3E74, 0x1E2F5E)
        Art.fillLinear(&context, Art.rect(0, 0, w, h), ground, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: h))
        Art.glow(&context, 216, 180, 200, Art.color(0xF2D79A), alpha: 0.22)
        ArtStyle.contactShadow(&context, 222, 272, 150, 14, alpha: 0.4)
        // The leather binding under the pages, tooled in gold.
        let binding: Path = Art.svg("M216,118 C178,104 112,102 72,112 L72,276 C112,266 178,266 216,280 C254,266 320,266 360,276 L360,112 C320,102 254,104 216,118Z")
        Kit.solid(&context, binding, Art.color(0x7A2A2A), light: 0.24, shade: 0.3)
        Art.stroke(&context, binding, Art.color(0xC9A24A, 0.8), width: 1.6)
        let left: Path = Art.svg("M216,114 C180,100 120,100 84,108 L84,264 C120,254 180,254 216,268Z")
        let right: Path = Art.svg("M216,114 C252,100 312,100 348,108 L348,264 C312,254 252,254 216,268Z")
        let paper: Kit.Stops = Kit.stops(0xF6EDD6, 0xEADBB8)
        Kit.solid(&context, left, stops: paper, light: 0.2, shade: 0.14)
        Kit.solid(&context, right, stops: paper, light: 0.16, shade: 0.2)
        Art.fill(&context, Art.rect(210, 108, 12, 160), ArtStyle.coolShade.opacity(0.1))
        bookPage(&context, x0: 98, x1: 204, panel: false)
        bookPage(&context, x0: 228, x1: 334, panel: true)
        // The painted picture: a rider under a lapis sky, framed in gold.
        let panel = CGRect(x: 246, y: 150, width: 70, height: 72)
        Art.clipped(&context, to: Art.rect(panel.minX, panel.minY, panel.width, panel.height)) { p in
            Art.fill(&p, Art.rect(panel.minX, panel.minY, panel.width, 40), Art.color(0x3A5AA0))
            Art.fill(&p, Art.rect(panel.minX, panel.minY + 40, panel.width, 32), Art.color(0x7FA866))
            Art.fill(&p, Art.circle(panel.minX + 14, panel.minY + 12, 5), Art.color(0xF2D79A))
            Art.group(&p, x: panel.midX + 2, y: panel.maxY - 8, scale: 0.2) { r in
                horseman(&r, coat: 0xF4F1EA, cloth: 0xB8464E, skin: 0xE2B48C, pennant: saffron)
            }
        }
        Art.stroke(&context, Art.rect(panel.minX, panel.minY, panel.width, panel.height), Art.color(0xC9A24A), width: 2.4)
        Art.stroke(&context, Art.rect(panel.minX - 4, panel.minY - 4, panel.width + 8, panel.height + 8), Art.color(0xB33A1C, 0.7), width: 1)
        Kit.flecks(&context, in: CGRect(x: 60, y: 80, width: 312, height: 200), count: 18, seed: 71, color: Art.color(0xF2D79A), radius: 0.6...1.4, glow: true)
        Kit.sink(&context, size, card: 0x1E2F5E)
    }

    /// One page of the book: two columns of flowing script between gold rules, a rubric in red;
    /// with `panel`, the middle lines leave room for the painting.
    static func bookPage(_ g: inout GraphicsContext, x0: CGFloat, x1: CGFloat, panel: Bool) {
        let mid: CGFloat = (x0 + x1) / 2
        let ruleTone: Color = Art.color(0xC9A24A)
        Art.stroke(&g, Art.rect(x0 - 4, 120, x1 - x0 + 8, 132), ruleTone, width: 1.2)
        Art.stroke(&g, Art.line(mid, 120, mid, 252), ruleTone, width: 1)
        var script = Path()
        var rubric = Path()
        var random = ArtRandom(panel ? 81 : 82)
        for row in 0..<13 {
            let y: CGFloat = 130 + CGFloat(row) * 9.6
            let inPanel: Bool = panel && y > 142 && y < 230
            var columns: [(CGFloat, CGFloat)] = [(x0, mid - 4), (mid + 4, x1)]
            if inPanel {
                columns = [(x0, x0 + 12)]
            }
            for column in columns {
                var x: CGFloat = column.0 + 2
                var line = Path()
                line.move(to: CGPoint(x: x, y: y))
                while x < column.1 - 4 {
                    let step: CGFloat = 4 + 4 * Kit.rnd(&random)
                    let lift: CGFloat = (Kit.rnd(&random) - 0.3) * 5
                    line.addQuadCurve(to: CGPoint(x: x + step, y: y), control: CGPoint(x: x + step / 2, y: y - lift))
                    x += step
                }
                if row == 0 {
                    rubric.addPath(line)
                } else {
                    script.addPath(line)
                }
            }
        }
        Art.stroke(&g, script, Art.color(0x2A2220, 0.78), width: 1.1)
        Art.stroke(&g, rubric, Art.color(0xB33A1C, 0.85), width: 1.3)
    }

    /// The Alborz: the white snow cone of Damavand above a ridge of jagged blue mountains.
    static func alborzPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        let h = size.height
        let sky: Kit.Stops = [(Art.color(0xB9D2EA), 0), (Art.color(0xDCE8F3), 0.55), (Art.color(0xF4E8CE), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, h), sky, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: 262))
        Kit.cloud(&context, 330, 70, scale: 0.6, color: Art.color(0xFFFFFF, 0.5))
        Kit.cloud(&context, 300, 150, scale: 0.9, color: Art.color(0xFFFFFF, 0.6))
        damavand(&context, cx: 216, baseY: 262, scale: 1.14)
        ArtStyle.atmosphere(&context, width: w, top: 180, bottom: 262, color: Art.color(0xE6EEF5), alpha: 0.25)
        let ridge: Path = Kit.peaks(width: w, y: 268, amp: 64, seed: 73, bottom: h, sharp: 0.9)
        let ridgeStops: Kit.Stops = [(Art.color(0xF2F5F8), 0), (Art.color(0x8DA6C4), 0.3), (Art.color(0x4A6A90), 0.6), (Art.color(0x2E4A6A), 1)]
        Art.fillLinear(&context, ridge, ridgeStops, from: CGPoint(x: 0, y: 204), to: CGPoint(x: 0, y: 330))
        Kit.model(&context, ridge, light: 0.18, shade: 0.2)
        let near: Path = Kit.peaks(width: w, y: 318, amp: 44, seed: 74, bottom: h, sharp: 0.8)
        Art.fill(&context, near, Art.color(0x24405E))
        Kit.model(&context, near, light: 0.14, shade: 0.2)
        Kit.sink(&context, size, card: 0x163A5A)
    }

    /// The Simurgh's feather: one long feather striped turquoise, saffron and rose, lying
    /// across a deep blue ground.
    static func featherPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        let h = size.height
        let ground: Kit.Stops = Kit.stops(0x2A3E74, 0x1E2F5E, 0x3A2A4A)
        Art.fillLinear(&context, Art.rect(0, 0, w, h), ground, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: h))
        Art.glow(&context, 230, 180, 190, Art.color(0x3FA7B0), alpha: 0.2)
        var rosettes = Path()
        let places: [(CGFloat, CGFloat)] = [(60, 300), (372, 70), (380, 260), (120, 220)]
        for place in places {
            rosettes.addPath(Kit.personScallop(cx: place.0, cy: place.1, rx: 9, ry: 9, from: 0, to: 315, count: 8, r: 4))
        }
        Art.fill(&context, rosettes, Art.color(0x4A62A0, 0.35))
        Art.blurred(&context, radius: 8, opacity: 0.5) { s in
            Art.group(&s, x: 92, y: 284, rotate: -0.55) { f in
                Art.fill(&f, Art.ellipse(160, 0, 150, 26), ArtStyle.coolShade)
            }
        }
        Art.group(&context, x: 78, y: 268, rotate: -0.55) { f in
            simurghFeather(&f, length: 300)
        }
        Kit.flecks(&context, in: CGRect(x: 60, y: 60, width: 320, height: 220), count: 16, seed: 75, color: Art.color(0xF2D79A), radius: 0.6...1.6, glow: true)
        Kit.sink(&context, size, card: 0x5A2A3A)
    }

    /// Naqqali: a storyteller in a long coat, stick raised, before a large painted scroll of a
    /// rider and a great bird, in a tea-house.
    static func naqqaliPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        let h = size.height
        let wall: Kit.Stops = Kit.stops(0xEFDDB6, 0xD9BE8E)
        Art.fillLinear(&context, Art.rect(0, 0, w, h), wall, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: 300))
        Art.glow(&context, 140, 120, 220, Art.color(0xFFF1D0), alpha: 0.4)
        Art.fill(&context, Art.rect(0, 296, w, h - 296), Art.color(0x8A2A2A))
        Art.stroke(&context, Art.line(0, 300, w, 300), Art.color(saffron, 0.7), width: 2)
        // The painted scroll (pardeh), hung on the wall.
        let scroll = CGRect(x: 86, y: 54, width: 226, height: 186)
        ArtStyle.contactShadow(&context, scroll.midX + 8, scroll.maxY + 4, 130, 8, alpha: 0.25)
        Kit.solid(&context, Art.rect(scroll.minX - 8, scroll.minY - 8, scroll.width + 16, scroll.height + 16, radius: 3), Art.color(0x7A2A2A), light: 0.2, shade: 0.26)
        let inner: Path = Art.rect(scroll.minX, scroll.minY, scroll.width, scroll.height)
        Art.clipped(&context, to: inner) { p in
            Art.fill(&p, inner, Art.color(0xF2E4C4))
            Art.fill(&p, Art.rect(scroll.minX, scroll.minY + 124, scroll.width, 62), Art.color(0xB9C48E))
            Art.group(&p, x: 140, y: 228, scale: 0.26) { r in
                horseman(&r, coat: 0xF4F1EA, cloth: lapis, skin: 0xE2B48C, pennant: rose)
            }
            Art.group(&p, x: 236, y: 120, scale: 0.32) { s in
                simurgh(&s, pose: .glide, look: CGPoint(x: -0.4, y: 0.6))
            }
        }
        Art.stroke(&context, inner, Art.color(0xC9A24A), width: 2)
        Art.fill(&context, Art.rect(scroll.minX - 14, scroll.minY - 12, scroll.width + 28, 6, radius: 3), Art.color(0x5A3A22))
        // The naqqal, facing his painting, his stick lifted toward it.
        let teller = Kit.Person(age: .adult, skin: 0xD2A07A, hair: 0x2A2022, hairStyle: .short, beard: .short, headwear: .cap, headwearColor: 0x7A2A2A, garment: .robe, cloth: 0x3A4E6A, trim: saffron, legs: 0x2A2A3A, showsEyeWhite: false)
        let feet: CGFloat = 318
        let k: CGFloat = 1.12
        Kit.shadow(&context, 344, feet, width: 80)
        Art.group(&context, x: 344, y: feet, scale: k) { p in
            Kit.person(&p, teller, pose: .reach, look: CGPoint(x: -0.8, y: -0.4), mouth: .open)
            let hand = Kit.hand(teller, pose: .reach)
            Art.stroke(&p, Art.line(hand.x + 8, hand.y + 30, hand.x - 18, hand.y - 52), Art.color(0x6A4A2A), width: 3)
        }
        Kit.sink(&context, size, card: 0x6A4210)
    }
}

// MARK: - Portraits (432 × 400) and face chips (100 × 100)

extension ZalArt {
    /// Zal grown: long white hair blowing, the saffron robe, the striped feather at his chest,
    /// on a high rock with white cloud below and pale sky behind.
    static func zalPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0xEEF4FB, bottom: 0x8FB8E0, halo: 0xFFF3DC, rays: false) { g in
            Kit.birds(&g, 60, 96, scale: 1.1, color: Art.color(0x6F8FB8, 0.6))
            Kit.cloud(&g, 70, 360, scale: 1.8, color: Art.color(0xFFFFFF, 0.9))
            Kit.cloud(&g, 372, 372, scale: 2.0, color: Art.color(0xFFFFFF, 0.9))
            // Long white locks blowing out behind him in the high wind.
            Art.group(&g, x: 216, y: 126, scale: 2.15) { hair in
                let locks: Path = Art.svg("M18,-30 C44,-34 70,-18 96,-28 C80,-10 58,-2 30,-2Z M22,-6 C46,-4 68,10 92,4 C74,20 50,24 26,16Z")
                Art.fill(&hair, locks, Art.color(0xF7F5EF))
                Art.stroke(&hair, Art.svg("M30,-20 C50,-20 66,-14 84,-20 M34,4 C52,8 66,12 80,10"), Art.color(0xC9D3E0), width: 1)
            }
            Art.group(&g, x: 216, y: 126, scale: 2.15) { b in
                Kit.bust(&b, zalLook(child: false), look: .zero, mouth: .smile)
            }
            Art.group(&g, x: 250, y: 262, rotate: -1.2, scale: 0.8) { f in
                simurghFeather(&f, length: 110)
            }
        }
    }

    /// The Simurgh: head, neck and one sweep of wing, the crest, the curved beak, the calm
    /// gold-rimmed eye, her tail curling into the frame; pale turquoise sky behind.
    static func simurghPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0xE6F6F4, bottom: 0x7FC6C0, halo: 0xFFF3DC, rays: false) { g in
            Art.group(&g, x: 300, y: 340, rotate: -0.5) { t in
                simurghTail(&t, length: 230, drop: -70)
            }
            simurghWing(&g, pivot: CGPoint(x: 300, y: 330), from: 205, to: 290, count: 8, length: 230, near: true)
            let neck: Path = Art.svg("M140,410 C140,330 168,246 188,182 L262,178 C262,250 300,330 336,410Z")
            Kit.solid(&g, neck, stops: Kit.stops(0x56BCC2, turquoise, 0x2F8E9A), light: 0.28, shade: 0.24, rim: 2)
            var scales = Path()
            for row in 0..<6 {
                for col in 0..<5 {
                    let x: CGFloat = 176 + CGFloat(col) * 22 + CGFloat(row % 2) * 11
                    let y: CGFloat = 220 + CGFloat(row) * 30
                    scales.move(to: CGPoint(x: x - 9, y: y))
                    scales.addQuadCurve(to: CGPoint(x: x + 9, y: y), control: CGPoint(x: x, y: y + 10))
                }
            }
            Art.clipped(&g, to: neck) { c in
                Art.stroke(&c, scales, Art.color(paleTurquoise, 0.7), width: 2)
            }
            Art.group(&g, x: 224, y: 130, scale: 2.6) { h in
                simurghHead(&h, look: CGPoint(x: -0.4, y: 0.1))
            }
        }
    }

    static func zalFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xDCEBFB) { g in
            Art.group(&g, x: 0, y: 4, scale: 1.25) { f in
                Kit.personHead(&f, zalLook(child: false), mouth: .smile)
            }
        }
    }

    static func simurghFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xD6F3EF) { g in
            Art.group(&g, x: 8, y: 8, scale: 1.4) { f in
                simurghHead(&f, look: CGPoint(x: -0.3, y: 0))
            }
        }
    }

    static func samFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xFFE7C7) { g in
            Art.group(&g, x: 0, y: 6, scale: 1.05) { f in
                Kit.personHead(&f, samLook(white: false), mouth: .flat)
                samHelmet(&f, mirrored: false)
            }
        }
    }
}

// MARK: - Cover (300 wide, 150…375 high)

extension ZalArt {
    /// The Simurgh gliding down past snowy Alborz peaks in pale morning light, wings wide and
    /// tail streaming, the white-haired Zal on her back looking down toward the ground.
    static func coverPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.cover(&context, size, wash: 0.08, vignette: 0.08) { g, frame in
            let light = morning()
            let k: CGFloat = frame.k
            let hd: CGFloat = frame.hd
            let H: CGFloat = frame.H
            Kit.sky(&g, CGSize(width: 240, height: hd), horizon: H, light: light)
            Kit.sun(&g, 40, H - 20 * k, 8 * k, light: light)
            damavand(&g, cx: 70, baseY: H - 6 * k, scale: 0.6 * k)
            alborzWall(&g, width: 240, horizon: H, scale: 0.75 * k, seed: 41, light: light)
            let field: Kit.Stops = Kit.stops(0xD6D2A6, 0xB5B68C, 0x8E9A7E)
            Kit.ground(&g, width: 240, top: H, bottom: hd, stops: field, seed: 49)
            Kit.cloud(&g, 54, H + 4, scale: 0.6 * k, color: Art.color(0xFFFFFF, 0.8))
            Kit.cloud(&g, 170, H + 10, scale: 0.5 * k, color: Art.color(0xFFFFFF, 0.7))
            // Near framing: the foot of the crag, cropped by the top-right corner.
            crag(&g, cx: 246, baseY: hd + 10, topY: -10, width: 40, color: 0x8E98A6, seed: 43)
            Kit.shadow(&g, 126, H + 30 * k, width: 120 * k, alpha: 0.12)
            Art.group(&g, x: 128, y: H - 18 * k, rotate: 0.14, scale: 0.42 * k) { s in
                simurgh(&s, pose: .glide, rider: true, look: CGPoint(x: -0.7, y: 0.8))
            }
        }
    }
}
