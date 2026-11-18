import SwiftUI
import OmramoCore

// The tap-to-see pictures (432 × 404), the character-card portraits (432 × 400), the face
// chips (100 × 100) and the cover of "Sindbad's Second Voyage".

// MARK: - Tap pictures

extension SindbadArt {
    /// One dhow seen from the side on calm blue water, its white slanting sail filled.
    static func dhowPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let H: CGFloat = 258
        let sky: Kit.Stops = [(Art.color(0xBFE6EA), 0), (Art.color(0xDDF1EE), 0.6), (Art.color(0xFBE9BE), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, H + 2), sky, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: H))
        ArtStyle.horizonGlow(&context, width: w, y: H, rise: 70, color: Art.color(0xFBE3A6), alpha: 0.5)
        Kit.cloud(&context, 344, 96, scale: 0.6, color: Color.white.opacity(0.7))
        // A far low island on the horizon.
        Art.fill(&context, Art.svg("M300,258 C318,246 340,244 360,250 C372,252 384,254 394,258Z"), Art.color(0x9CC7B6))
        let sea: Kit.Stops = [(Art.color(0x8FD0D2), 0), (Art.color(0x5DBFC4), 0.4), (Art.color(0x1C6F80), 1)]
        Art.fillLinear(&context, Art.rect(0, H, w, h - H), sea, from: CGPoint(x: 0, y: H), to: CGPoint(x: 0, y: h))
        Art.fill(&context, Art.rect(0, H, w, 1.4), Color.white.opacity(0.5))
        Kit.rippleMarks(&context, x0: 0, x1: w, y0: H + 6, y1: h, count: 30, seed: 11, color: Color.white, alpha: 0.35)
        // The ship's soft reflection, then the ship.
        Art.fill(&context, Art.ellipse(216, 292, 124, 10), Color.white.opacity(0.14))
        Art.fill(&context, Art.ellipse(222, 284, 110, 5), ArtStyle.coolShade.opacity(0.18))
        Art.group(&context, x: 216, y: 274, scale: 1.15) { s in
            dhow(&s, full: true)
        }
        Kit.ripples(&context, 210, 278, 250, count: 2)
        Kit.ripples(&context, 84, 268, 30, count: 1)
        Kit.birds(&context, 300, 58, scale: 0.8, color: Art.color(0x6A8F8A, 0.6))
        Kit.sink(&context, size, card: 0x1C4F63)
    }

    /// The open handwritten book on its low folding stand, a small brass oil lamp burning
    /// beside it, on a deep violet ground.
    static func nightsPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let wall: Kit.Stops = [(Art.color(0x4A3672), 0), (Art.color(0x3E2D66), 0.6), (Art.color(0x33245A), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, h), wall, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: h))
        Art.glow(&context, 330, 236, 240, Art.color(0xFFC96B), alpha: 0.26)
        // The floor and a plain rug.
        Art.fill(&context, Art.rect(0, 298, w, h - 298), Art.color(0x2E2150))
        let rug = Art.rect(34, 300, 364, 30, radius: 4)
        Kit.solid(&context, rug, Art.color(0x7A3440), light: 0.2, shade: 0.2)
        Art.stroke(&context, Art.rect(42, 305, 348, 20, radius: 3), Art.color(0xE0A24A, 0.7), width: 1.6)
        // The folding stand: two boards crossed, the book resting in the V above.
        Kit.shadow(&context, 216, 302, width: 190, alpha: 0.3)
        Kit.propShaft(&context, 150, 300, 274, 206, wood: 0x7A4E30, width: 12)
        Kit.propShaft(&context, 282, 300, 158, 206, wood: 0x8A5B38, width: 12)
        Art.fill(&context, Art.circle(216, 253, 4), Art.color(0xC9964A))
        nightsBook(&context)
        nightsLamp(&context)
        Kit.sink(&context, size, card: 0x3A2A5E)
    }

    /// The open book of the Nights, its pages lined with plain strokes for the script.
    static func nightsBook(_ context: inout GraphicsContext) {
        let binding = Art.svg("M216,174 C178,156 132,152 94,158 L102,222 C140,216 182,222 216,242 C250,222 292,216 330,222 L338,158 C300,152 254,156 216,174Z")
        Kit.solid(&context, binding, Art.color(0x8A3A2E), light: 0.24, shade: 0.24)
        let left = Art.svg("M216,168 C180,150 136,146 100,152 L108,216 C142,210 184,216 216,236Z")
        let right = Art.svg("M216,168 C252,150 296,146 332,152 L324,216 C290,210 248,216 216,236Z")
        let paper: Kit.Stops = [(Art.color(0xFBF1D8), 0), (Art.color(0xEEDDB8), 1)]
        Kit.solid(&context, left, stops: paper, light: 0.3, shade: 0.1)
        Kit.solid(&context, right, stops: paper, light: 0.16, shade: 0.18)
        var leftLines = Path()
        var rightLines = Path()
        for i in 0..<6 {
            let dy: CGFloat = CGFloat(i) * 9
            leftLines.move(to: CGPoint(x: 118, y: 162 + dy))
            leftLines.addQuadCurve(to: CGPoint(x: 204, y: 178 + dy), control: CGPoint(x: 166, y: 158 + dy))
            rightLines.move(to: CGPoint(x: 228, y: 178 + dy))
            rightLines.addQuadCurve(to: CGPoint(x: 314, y: 162 + dy), control: CGPoint(x: 266, y: 158 + dy))
        }
        let ink: Color = Art.color(0x4A2E22, 0.6)
        Art.stroke(&context, leftLines, ink, width: 1.6, dash: [14, 4, 8, 4, 20, 5])
        Art.stroke(&context, rightLines, ink, width: 1.6, dash: [18, 5, 9, 4, 12, 4])
        Art.stroke(&context, Art.svg("M216,168 L216,236"), Art.color(0xC9B48C), width: 1.4)
        Art.stroke(&context, Art.svg("M216,236 C218,248 222,258 220,270"), Art.color(0xB33A2E), width: 2.4)
        ArtStyle.rimEdge(&context, left, bounds: CGRect(x: 100, y: 146, width: 116, height: 90), width: 2, alpha: 0.5)
    }

    /// The small brass oil lamp on the floor to the right, its flame at the spout.
    static func nightsLamp(_ context: inout GraphicsContext) {
        Kit.shadow(&context, 352, 300, width: 74, alpha: 0.3)
        let body = Art.svg("M322,298 C316,286 330,278 348,278 C362,278 372,282 384,274 C390,278 386,290 374,294 C364,298 352,300 340,300Z")
        let brass: Kit.Stops = [(Art.color(0xF2C35A), 0), (Art.color(0xB27A2C), 1)]
        Kit.solid(&context, body, stops: brass, light: 0.3, shade: 0.24, rim: 2)
        Art.stroke(&context, Art.svg("M326,290 C312,290 310,278 322,278"), Art.color(0xB27A2C), width: 3)
        Art.fill(&context, Art.ellipse(346, 279, 9, 2.6), Art.color(0x7A4E1E))
        Kit.lamp(&context, cx: 386, cy: 264, radius: 5)
    }

    /// A stretch of mud-brick quay with three tall date palms behind it and one dhow tied up,
    /// her sail furled, on a warm brown-gold ground.
    static func basraPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let H: CGFloat = 236
        let light = day()
        let sky: Kit.Stops = [(Art.color(0xF1E6C4), 0), (Art.color(0xF7E7BE), 0.6), (Art.color(0xFBE3A6), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, H + 2), sky, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: H))
        ArtStyle.horizonGlow(&context, width: w, y: H, rise: 60, color: Art.color(0xFBE3A6), alpha: 0.5)
        farPalms(&context, x0: 0, x1: w, baseY: H - 2, height: 30, count: 12, color: Art.color(0xC9BE96), seed: 5)
        Kit.house(&context, cx: 74, baseY: H, width: 92, wallHeight: 46, roofHeight: 8, wall: mudBrick, roof: mudRoof, style: .flat, door: 0x6A4630, windows: 1)
        Kit.palm(&context, x: 150, baseY: H, height: 172, lean: -10, fronds: palmGreen, trunk: 0x8A6A4A, seed: 4)
        Kit.palm(&context, x: 252, baseY: H, height: 198, lean: 8, fronds: 0x357A56, trunk: 0x8A6A4A, seed: 7)
        Kit.palm(&context, x: 364, baseY: H, height: 160, lean: -6, fronds: palmGreen, trunk: 0x8A6A4A, seed: 9)
        bale(&context, cx: 398, cy: H - 9, width: 34, height: 18)
        sealedJar(&context, cx: 370, baseY: H, height: 30)
        // The quay wall facing the river.
        let wallTop: CGFloat = H
        let wallBox = CGRect(x: 0, y: wallTop, width: w, height: 50)
        let quayWall = Path(wallBox)
        let brick: Kit.Stops = [(Art.color(0xDDBE8E), 0), (Art.color(0xB8925E), 1)]
        Art.fillLinear(&context, quayWall, brick, from: CGPoint(x: 0, y: wallTop), to: CGPoint(x: 0, y: wallTop + 50))
        let courses: Path = Kit.builtCourses(wallBox, seed: 19)
        Art.stroke(&context, courses, Art.color(0x9A764C, 0.5), width: 1.2)
        Art.stroke(&context, Art.line(0, wallTop + 1, w, wallTop + 1), Art.color(0xF8E9C4), width: 2.4)
        Art.fill(&context, Art.rect(0, wallTop + 38, w, 12), ArtStyle.coolShade.opacity(0.16))
        // The river, the moored ship and her rope to the post.
        Kit.water(&context, width: w, top: wallTop + 48, bottom: h, stops: riverStops(), light: light, ripples: 22, seed: 35)
        Art.fill(&context, Art.ellipse(232, 318, 116, 8), ArtStyle.coolShade.opacity(0.16))
        Art.group(&context, x: 232, y: 312, scale: 0.95) { s in
            dhow(&s, full: false)
        }
        Kit.ripples(&context, 232, 315, 220, count: 2)
        Kit.propShaft(&context, 92, wallTop + 6, 92, wallTop - 10, wood: sparWood, width: 6)
        var rope = Path()
        rope.move(to: CGPoint(x: 92, y: wallTop - 6))
        rope.addQuadCurve(to: CGPoint(x: 124, y: 274), control: CGPoint(x: 104, y: 262))
        Art.stroke(&context, rope, Art.color(0x8A6A48), width: 1.8)
        Kit.sink(&context, size, card: 0x6B4A1E)
    }
}

// MARK: - Portraits

extension SindbadArt {
    /// Sindbad to the waist, smiling, in his cream robe, sea-green sash and white turban, with
    /// pale turquoise sky and one slanting sail behind him.
    static func sindbadPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0xC9ECEC, bottom: 0x3E9EAA, halo: 0xFBE3A6, rays: false) { g in
            Kit.cloud(&g, 92, 300, scale: 0.5, color: Color.white.opacity(0.4))
            // One slanting sail behind him, far off on the right.
            let sail = Art.svg("M300,250 L398,70 C412,120 414,190 404,246 C370,252 334,252 300,250Z")
            Art.fill(&g, sail, Art.color(0xFBF6E8, 0.8))
            Art.fill(&g, Art.svg("M398,70 C412,120 414,190 404,246 L394,246 C402,190 402,120 398,70Z"), ArtStyle.coolShade.opacity(0.08))
            Art.stroke(&g, Art.line(296, 254, 402, 64), Art.color(0x6A4630, 0.5), width: 2)
            Art.fill(&g, Art.svg("M290,254 C300,262 390,262 410,250 L404,246 C370,252 334,252 300,250Z"), Art.color(0x8A5B38, 0.6))
            Kit.birds(&g, 56, 96, scale: 0.9, color: Art.color(0x3E9EAA, 0.5))
            Art.group(&g, x: 216, y: 150, scale: 2.2) { b in
                Kit.bust(&b, sindbadLook(), look: .zero, mouth: .smile, wave: false)
            }
        }
    }

    /// The Roc's white-and-gold head and one great wing filling the frame against warm gold
    /// sky, a tiny green island in a speck of sea far below.
    static func rocPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0xFBEBC2, bottom: 0xD79A3C, halo: 0xFFF6D8, rays: false) { g in
            // Far below: a speck of sea, a tiny island, a wisp of cloud.
            Art.fill(&g, Art.ellipse(92, 338, 64, 12), Art.color(0x5DBFC4, 0.85))
            Art.fill(&g, Art.ellipse(88, 335, 17, 5), Art.color(0x4A9E62))
            Art.fill(&g, Art.ellipse(85, 333, 8, 2.6), Art.color(0x86C46E))
            Kit.cloud(&g, 150, 368, scale: 0.4, color: Color.white.opacity(0.55))
            rocWing(&g, root: CGPoint(x: 330, y: 250), from: 192, to: 262, length: 300, count: 11)
            Art.group(&g, x: 262, y: 150, scale: 1.7) { r in
                rocHead(&r)
            }
        }
    }
}

// MARK: - Face chips

extension SindbadArt {
    static func sindbadFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xD3EEF0) { g in
            Art.group(&g, x: 0, y: 7, scale: 1.12) { f in
                Kit.personHead(&f, sindbadLook(), look: .zero, mouth: .smile)
            }
        }
    }

    static func rocFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xFBE9BF) { g in
            Art.group(&g, x: 8, y: 4, scale: 1) { f in
                rocHead(&f)
            }
        }
    }

    static func merchantFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xEEDDEA) { g in
            Art.group(&g, x: 0, y: 7, scale: 1.12) { f in
                Kit.personHead(&f, merchantLook(), look: .zero, mouth: .oh)
            }
        }
    }
}

// MARK: - Cover

extension SindbadArt {
    /// Sindbad, small, beside the huge smooth egg among green trees, looking up, as the shadow
    /// of a vast wing slides over the egg and the ground; pale turquoise sky above.
    static func cover(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.cover(&context, size) { g, frame in
            let H: CGFloat = frame.H
            let k: CGFloat = frame.k
            let hd: CGFloat = frame.hd
            let light = day()
            let box = CGSize(width: 240, height: hd)
            Kit.sky(&g, box, horizon: H, light: light)
            Kit.cloud(&g, 150, H * 0.34, scale: 0.35 * k, color: Color.white.opacity(0.6))
            let seaTop: CGFloat = H - 5 * k
            Art.fill(&g, Art.rect(0, seaTop, 240, H - seaTop + 1), Art.color(0x9ED5D3))
            Kit.farTrees(&g, x0: 70, x1: 240, baseY: H + 1, height: 18 * k, count: 9, color: Art.color(0xA6CDB4), seed: 6)
            ArtStyle.atmosphere(&g, width: 240, top: H - 30 * k, bottom: H + 2, color: light.haze, alpha: 0.3)
            Kit.ground(&g, width: 240, top: H, bottom: hd, stops: islandGround(), seed: 45)
            fruitTree(&g, x: 26, baseY: H + 10 * k, height: 80 * k, seed: 3)
            fruitTree(&g, x: 226, baseY: H + 12 * k, height: 96 * k, seed: 7)
            let groundShade = wingShadow(root: CGPoint(x: 250, y: H + 22 * k), from: 160, to: 200, length: 200 * k, count: 7, squash: 0.22)
            Art.fill(&g, groundShade, ArtStyle.coolShade.opacity(0.14))
            let eggBase: CGFloat = H + 18 * k
            Kit.shadow(&g, 158, eggBase, width: 126 * k, alpha: 0.3)
            let eggShade = wingShadow(root: CGPoint(x: 236, y: eggBase - 176 * k), from: 115, to: 175, length: 136 * k, count: 7, squash: 1)
            egg(&g, cx: 158, baseY: eggBase, width: 114 * k, height: 156 * k, shade: eggShade)
            Kit.bush(&g, x: 198, baseY: H + 26 * k, width: 34 * k, palette: islandGreens(), seed: 15)
            let sk: CGFloat = 0.26 * k
            let feetY: CGFloat = H + 26 * k
            Kit.shadow(&g, 80, feetY, width: 48 * sk)
            Art.group(&g, x: 80, y: feetY, scale: sk, scaleX: -1) { s in
                sindbadGazing(&s, mouth: .oh, mirrored: true)
            }
            let meadow = CGRect(x: 0, y: H + 22 * k, width: 240, height: max(6, hd - H - 26 * k))
            Kit.grass(&g, in: meadow, count: 18, seed: 12, color: Art.color(0x5E9A5E), height: 8 * k)
            // The edge of the Roc's wing in the top trailing corner.
            rocWing(&g, root: CGPoint(x: 262, y: -16), from: 118, to: 170, length: 100 * k, count: 8)
        }
    }
}
