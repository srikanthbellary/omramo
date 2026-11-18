import SwiftUI
import OmramoCore

// The tap-to-see pictures, the character-card portraits, the face chips and the cover of
// "The Snow House".

// MARK: - Tap-to-see pictures (432 × 404)

extension SnowHouseArt {
    /// Nunavut: a wide land of snow and bare rock beside a frozen sea, under a low gold sun.
    /// No people, no buildings, no trees.
    static func nunavutPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let light = day()
        let H: CGFloat = 204
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.sun(&context, 116, 152, 20, light: light)
        Kit.cloud(&context, 312, 92, scale: 0.6, color: Art.color(0xFFFFFF, 0.55))
        let hills: [(CGFloat, CGFloat, CGFloat)] = [(0.44, 0.84, 40), (0.78, 1.14, 58)]
        farLand(&context, width: size.width, horizon: H, scale: 1, light: light, hills: hills, seed: 44)
        Kit.ground(&context, width: size.width, top: H, bottom: size.height, stops: snowStops(dusk: false), seed: 75)
        flatGlow(&context, 116, H + 14, rx: 170, ry: 20, color: light.glow, alpha: 0.45)
        // The frozen sea: a wide pale band, with a line of broken ice along its shore.
        iceBand(&context, x0: -70, x1: 330, y: H + 18, depth: 30)
        let floes: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [(60, 252, 26, 0.3), (104, 258, 20, -0.2), (150, 260, 24, 0.16), (206, 256, 18, -0.3), (250, 248, 22, 0.24)]
        for floe in floes {
            Kit.snowBlock(&context, x: floe.0, baseY: floe.1, width: floe.2, height: floe.2 * 0.5, tilt: floe.3)
        }
        // The land: bare rock showing through the snow, drifts and wind-ripples.
        rockHill(&context, x0: 214, x1: 470, y: 250, height: 34)
        windRipples(&context, x0: 0, x1: 432, y0: 262, y1: 330, count: 22, seed: 45)
        softDrift(&context, x0: 20, x1: 230, baseY: 292, height: 14)
        Kit.rock(&context, cx: 318, baseY: 296, width: 84, height: 34, color: rockHex, seed: 46)
        Art.fill(&context, Art.ellipse(308, 264, 26, 7), Art.color(0xF8FAFE))
        Kit.pebbles(&context, in: CGRect(x: 236, y: 288, width: 60, height: 10), count: 5, seed: 47, color: rockHex)
        Kit.flecks(&context, in: CGRect(x: 0, y: 236, width: 432, height: 70), count: 18, seed: 48, color: Color.white, radius: 0.7...1.5)
        Kit.sink(&context, size, card: 0x1B4F7A)
    }

    /// The snow knife: long, straight and flat, with a plain wooden handle, standing in hard
    /// snow beside one clean-cut block.
    static func snowKnifePicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let light = day()
        let H: CGFloat = 222
        Kit.sky(&context, size, horizon: H, light: light)
        let hills: [(CGFloat, CGFloat, CGFloat)] = [(0.56, 1.06, 30)]
        farLand(&context, width: size.width, horizon: H, scale: 0.8, light: light, hills: hills, seed: 50)
        Kit.ground(&context, width: size.width, top: H, bottom: size.height, stops: snowStops(dusk: false), seed: 77)
        flatGlow(&context, 60, H + 12, rx: 170, ry: 20, color: light.glow, alpha: 0.4)
        windRipples(&context, x0: 0, x1: 432, y0: H + 14, y1: 320, count: 18, seed: 51)
        // The block, cut clean, with the slot it came from beside it.
        cuttingPit(&context, x0: 246, x1: 372, y: 262, depth: 14)
        castShadow(&context, 300, 258, length: 150, alpha: 0.3)
        Kit.snowBlock(&context, x: 216, baseY: 258, width: 132, height: 78, tilt: -0.03)
        // The knife, standing in the snow.
        castShadow(&context, 158, 252, length: 70, alpha: 0.3)
        Art.group(&context, x: 154, y: 86, rotate: CGFloat.pi + 0.05, scale: 2.3) { k in
            snowKnife(&k, length: 66)
        }
        var lip = Path()
        lip.addEllipse(in: CGRect(x: 114, y: 240, width: 64, height: 20))
        lip.addEllipse(in: CGRect(x: 136, y: 236, width: 40, height: 16))
        Art.fill(&context, lip, Art.color(0xF4F8FD))
        Art.stroke(&context, Art.svg("M120,248 Q146,236 174,246"), Art.color(snowCream), width: 2)
        Kit.flecks(&context, in: CGRect(x: 110, y: 250, width: 260, height: 26), count: 12, seed: 52, color: Color.white, radius: 1...2.4)
        Kit.sink(&context, size, card: 0x2A5D86)
    }

    /// The seams of the snow wall, seen from inside: sloping, never level.
    static func insideSeams(_ context: inout GraphicsContext, width w: CGFloat, top: CGFloat, bottom: CGFloat) {
        var seams = Path()
        var joints = Path()
        var row: Int = 0
        var y: CGFloat = top - 40
        while y < bottom {
            seams.move(to: pt(-10, y + 46))
            seams.addQuadCurve(to: pt(w + 10, y), control: pt(w * 0.5, y + 14))
            let shift: CGFloat = row % 2 == 0 ? 40 : 96
            var x: CGFloat = shift
            while x < w {
                let lift: CGFloat = 46 * (1 - x / w)
                joints.move(to: pt(x, y + lift - 8))
                joints.addLine(to: pt(x + 8, y + lift + 58))
                x += 118
            }
            y += 70
            row += 1
        }
        Art.stroke(&context, joints, Art.color(0xD9963F, 0.4), width: 2)
        Art.stroke(&context, seams, Art.color(0xD9963F, 0.55), width: 2.4)
        let lit: Path = seams.applying(CGAffineTransform(translationX: 0, y: 3))
        Art.stroke(&context, lit, Art.color(0xFFFBE8, 0.7), width: 1.6)
    }

    /// The qulliq itself: a shallow half-moon lamp of grey stone, its straight edge toward
    /// the viewer, with a low, even line of flame along that edge. Origin: the middle of the
    /// straight edge; about 230 wide.
    static func qulliqLamp(_ context: inout GraphicsContext) {
        let stone: UInt32 = 0x8C9097
        ArtStyle.contactShadow(&context, 6, 20, 130, 12, alpha: 0.3)
        // The thickness of the stone under the straight edge.
        let side: Path = Art.svg("M-115,0 L115,0 C114,10 108,17 98,18 L-98,18 C-108,17 -114,10 -115,0Z")
        Kit.solid(&context, side, Kit.propTone(stone, 0.8), light: 0.2, shade: 0.26)
        // The top of the dish: straight in front, a round back.
        let dish: Path = Art.svg("M-115,0 C-112,-34 -62,-50 0,-50 C62,-50 112,-34 115,0Z")
        Kit.solid(&context, dish, Art.color(stone), light: 0.3, shade: 0.2)
        let hollow: Path = Art.svg("M-101,-3 C-98,-30 -54,-42 0,-42 C54,-42 98,-30 101,-3Z")
        let oil: Kit.Stops = [(Art.color(0x6B6F78), 0), (Art.color(0x8A6A3C), 0.5), (Art.color(0xE2A548), 1)]
        Art.fillLinear(&context, hollow, oil, from: pt(0, -42), to: pt(0, -3))
        Art.stroke(&context, Art.svg("M-70,-22 C-30,-30 30,-30 70,-22"), Art.color(0xFFE9B0, 0.5), width: 2)
        Art.stroke(&context, dish, Kit.propTone(stone, 1.25).opacity(0.7), width: 1.6)
        let grain = CGRect(x: -115, y: -50, width: 230, height: 68)
        Art.stipple(&context, in: grain, count: 60, seed: 61, color: Art.color(0x55585F), alpha: 0.18, size: 0.6...1.4)
        // The wick and its low row of flame.
        Art.stroke(&context, Art.line(-100, -3, 100, -3), Art.color(0x5A4A3A), width: 3)
        flatGlow(&context, 0, -8, rx: 150, ry: 34, color: Art.color(0xFFE9A0), alpha: 0.75)
        var outer = Path()
        var inner = Path()
        for i in 0..<15 {
            let x: CGFloat = -98 + CGFloat(i) * 14
            let tall: CGFloat = i % 3 == 1 ? 17 : 13
            outer.addPath(Kit.propFlame(x, -2, 11, tall, 1))
            inner.addPath(Kit.propFlame(x, -2, 5.5, tall * 0.55, 0.5))
        }
        Art.fill(&context, outer, Art.color(0xFFB84A))
        Art.fill(&context, inner, Art.color(0xFFF4C8))
    }

    /// The qulliq on a ledge of snow inside the house, a soft gold glow on the wall behind.
    static func qulliqPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let wall: Kit.Stops = [(Art.color(0xFFF3D2), 0), (Art.color(0xFBD796), 0.6), (Art.color(0xE8B56C), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, h), wall, from: pt(0, 0), to: pt(0, h))
        insideSeams(&context, width: w, top: 0, bottom: 240)
        Art.glow(&context, 216, 176, 200, Art.color(0xFFF8D8), alpha: 0.85)
        // The ledge of snow.
        var ledge = Path()
        ledge.move(to: pt(0, 238))
        ledge.addQuadCurve(to: pt(w, 232), control: pt(w * 0.5, 222))
        ledge.addLine(to: pt(w, h))
        ledge.addLine(to: pt(0, h))
        ledge.closeSubpath()
        let shelf: Path = ledge
        Art.fillLinear(&context, shelf, Kit.stops(0xFFFCF0, 0xF0CF98), from: pt(0, 226), to: pt(0, h))
        Art.stroke(&context, Art.svg("M0,238 Q216,222 432,232"), Color.white.opacity(0.9), width: 2.4)
        Art.group(&context, x: 216, y: 232) { g in
            qulliqLamp(&g)
        }
        Kit.sink(&context, size, card: 0x4A2F1E)
    }
}

// MARK: - Portraits (432 × 400) and face chips (100 × 100)

extension SnowHouseArt {
    /// A steel cup of hot tea. Origin: the middle of its foot; about 30 wide and 30 high.
    static func teaCup(_ context: inout GraphicsContext) {
        Art.stroke(&context, Art.svg("M13,-24 q11,1 9,10 q-2,7 -9,6"), Kit.propTone(steelHex, 0.8), width: 3.4)
        let cup: Path = Art.svg("M-14,-30 L14,-30 L12,-3 Q12,0 8,0 L-8,0 Q-12,0 -12,-3Z")
        Kit.solid(&context, cup, Art.color(steelHex), light: 0.3, shade: 0.24)
        Art.fill(&context, Art.ellipse(0, -30, 14, 4), Kit.propTone(steelHex, 1.12))
        Art.fill(&context, Art.ellipse(0, -30, 11.5, 2.8), Art.color(0xB5703A))
        Art.stroke(&context, Art.line(-9, -24, -8, -6), Color.white.opacity(0.7), width: 1.6)
        let steam: Path = Art.svg("M-4,-37 q-5,-7 0,-13 q5,-6 0,-12 M5,-39 q-4,-6 0,-11 q4,-5 0,-10")
        Art.stroke(&context, steam, Color.white.opacity(0.75), width: 2)
    }

    /// Elisapie from the waist up, hood back, braids out, hugging a snow block and grinning.
    static func elisapiePortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0xCFE9F7, bottom: 0xF2876B, halo: 0xFFF3D6, rays: true) { g in
            Art.group(&g, x: 216, y: 140, scale: 2.2) { b in
                hoodBack(&b)
                Kit.bust(&b, elisapieLook(), look: .zero, mouth: .grin)
            }
            // The block, nearly as big as her chest, and her arms round it.
            Kit.snowBlock(&g, x: 104, baseY: 424, width: 224, height: 150, tilt: -0.04)
            Art.stroke(&g, Art.svg("M92,296 C74,336 96,372 146,364"), Art.color(parkaRed), width: 36)
            Art.stroke(&g, Art.svg("M340,296 C358,336 336,372 286,364"), Kit.personTone(parkaRed, 0.86), width: 36)
            Art.stroke(&g, Art.svg("M128,348 L140,384"), Art.color(furPale), width: 12, cap: .butt)
            Art.stroke(&g, Art.svg("M304,348 L292,384"), Kit.personTone(furPale, 0.9), width: 12, cap: .butt)
            let mitt: UInt32 = 0x8E97A6
            let leftMitt: Path = Art.svg("M140,346 C162,338 184,348 184,366 C184,384 162,392 142,384Z")
            let rightMitt: Path = Art.svg("M292,346 C270,338 248,348 248,366 C248,384 270,392 290,384Z")
            Kit.solid(&g, leftMitt, Art.color(mitt), light: 0.24, shade: 0.2)
            Kit.solid(&g, rightMitt, Kit.personTone(mitt, 0.9), light: 0.16, shade: 0.24)
            Kit.flecks(&g, in: CGRect(x: 110, y: 262, width: 210, height: 16), count: 10, seed: 71, color: Color.white, radius: 1.4...3)
        }
    }

    /// Grandfather from the waist up: the snow knife resting on one shoulder, a steel cup of
    /// tea in the other hand, his sunglasses pushed up on his hood.
    static func grandfatherPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0xBFE0F5, bottom: 0x2F6FA8, halo: 0xFFF3D6, rays: true) { g in
            Art.group(&g, x: 216, y: 148, scale: 2.1) { b in
                Kit.bust(&b, grandfatherLook(), look: .zero, mouth: .smile)
                sunglasses(&b)
            }
            let leather: UInt32 = 0x8A6A4A
            // The knife hand (on the picture's right): sleeve, knife over the shoulder, mitt.
            Art.stroke(&g, Art.svg("M352,410 C352,380 340,360 326,346"), Kit.personTone(parkaBlue, 0.9), width: 42)
            Art.group(&g, x: 322, y: 332, rotate: 0.42, scale: 2.4) { k in
                snowKnife(&k, length: 70)
            }
            let knifeMitt: Path = Art.svg("M300,318 C316,306 344,312 346,334 C348,354 326,362 306,352Z")
            Kit.solid(&g, knifeMitt, Art.color(leather), light: 0.22, shade: 0.24)
            // The tea hand (on the picture's left): sleeve, mitt, cup.
            Art.stroke(&g, Art.svg("M80,410 C80,382 92,362 106,350"), Art.color(parkaBlue), width: 42)
            let teaMitt: Path = Art.svg("M92,318 C110,308 136,316 138,338 C140,358 116,366 96,356Z")
            Kit.solid(&g, teaMitt, Art.color(leather), light: 0.24, shade: 0.2)
            Art.group(&g, x: 112, y: 330, scale: 1.7) { c in
                teaCup(&c)
            }
        }
    }

    static func elisapieFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xFFE1D6) { g in
            Art.group(&g, x: -2, y: 5, scale: 1.45) { f in
                hoodBack(&f)
                Kit.personHead(&f, elisapieLook(), mouth: .grin)
            }
        }
    }

    static func grandfatherFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xD6EAF8) { g in
            Art.group(&g, x: 0, y: 5, scale: 1.15) { f in
                Kit.personHead(&f, grandfatherLook(), mouth: .smile)
                sunglasses(&f)
            }
        }
    }
}

// MARK: - Cover (300 wide, 150…375 high)

extension SnowHouseArt {
    /// The half-built snow house, its spiral wall clear to see: Elisapie reaches up to press
    /// snow into a seam and Grandfather looks out over the top with the snow knife.
    static func cover(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.cover(&context, size) { g, frame in
            let light = day()
            let H: CGFloat = frame.H
            let k: CGFloat = frame.k
            let hd: CGFloat = frame.hd
            Art.fillLinear(&g, Art.rect(0, 0, 240, hd), light.sky, from: pt(0, 0), to: pt(0, H))
            ArtStyle.horizonGlow(&g, width: 240, y: H, rise: 40 * k, color: light.glow, alpha: 0.5)
            Kit.sun(&g, 46, H - 24 * k, 11 * k, light: light)
            let hills: [(CGFloat, CGFloat, CGFloat)] = [(-0.1, 0.3, 18), (0.64, 1.1, 24)]
            farLand(&g, width: 240, horizon: H, scale: k * 0.7, light: light, hills: hills, seed: 54)
            Kit.ground(&g, width: 240, top: H, bottom: hd, stops: snowStops(dusk: false), seed: 76)
            flatGlow(&g, 46, H + 6 * k, rx: 80 * k, ry: 9 * k, color: light.glow, alpha: 0.4)
            windRipples(&g, x0: 0, x1: 240, y0: H + 8, y1: hd - 4, count: 14, seed: 55)
            coverSubject(&g, frame)
            nearBank(&g, x0: 150, x1: 300, baseY: hd + 3, height: 15 * k)
        }
    }

    static func coverSubject(_ g: inout GraphicsContext, _ frame: Kit.CoverFrame) {
        let k: CGFloat = frame.k
        let cx: CGFloat = 122
        let baseY: CGFloat = frame.H + 30 * k
        let d = Dome(cx: cx, baseY: baseY, radius: 84 * k, rise: 76 * k)
        castShadow(&g, cx + 16 * k, baseY + 9 * k, length: 170 * k, alpha: 0.36)
        snowWallBack(&g, d, courses: 2)
        Art.group(&g, x: cx + 6 * k, y: baseY + 8 * k, scale: 0.5 * k) { m in
            grandfather(&m, pose: .reach, look: CGPoint(x: 0.5, y: 0.5), mouth: .smile)
            let hand = grandfatherHand(.reach)
            Art.group(&m, x: hand.x, y: hand.y, rotate: -0.3) { n in
                snowKnife(&n, length: 46)
            }
            Art.fill(&m, Art.circle(hand.x, hand.y, 6), Kit.personTone(parkaBlue, 0.7))
        }
        snowWall(&g, d, courses: 2, blockLength: 30 * k)
        // A spare block and the pat of soft snow under Elisapie's mitt.
        Kit.snowBlock(&g, x: 22, baseY: baseY + 22 * k, width: 28 * k, height: 15 * k, tilt: 0.06)
        let patX: CGFloat = cx + 42 * k
        let patY: CGFloat = baseY - 31 * k
        Art.fill(&g, Art.ellipse(patX, patY, 6 * k, 4.6 * k), Color.white)
        castShadow(&g, cx + 63 * k, baseY + 19 * k, length: 32 * k)
        Art.group(&g, x: cx + 62 * k, y: baseY + 18 * k, scale: 0.52 * k) { e in
            elisapie(&e, pose: .reach, look: CGPoint(x: -0.6, y: -0.5), mouth: .smile, tongue: true)
        }
    }
}
