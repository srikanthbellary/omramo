import SwiftUI
import OmramoCore

// The tap-to-see pictures (432 × 404), the two character-card portraits (432 × 400), the
// three face chips (100 × 100) and the cover of "The Long Day at Fish Camp".

// MARK: - see-drying-rack

extension FishCampArt {
    /// One drying rack of peeled poles, two rows of red salmon strips, the blue tarp roof.
    static func rackPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let light = evening()
        let H: CGFloat = 252
        Kit.sky(&context, size, horizon: H, light: light)
        cloudStreaks(&context, width: 432, horizon: H, color: Color.white)
        Art.glow(&context, 0, H - 30, 180, light.glow, alpha: 0.36)
        farShore(&context, width: 432, horizon: H, scale: 0.9, light: light, seed: 91)
        let earth: Kit.Stops = [(Art.color(0x9C8A5C), 0), (Art.color(0x8A4E36), 0.45), (Art.color(0x7A2E22), 1)]
        Kit.ground(&context, width: 432, top: H, bottom: size.height, stops: earth, seed: 92)
        let fringe = CGRect(x: 0, y: H + 2, width: 432, height: 34)
        Kit.grass(&context, in: fringe, count: 60, seed: 93, color: Art.color(0x6F8C54, 0.8), height: 8)
        Art.group(&context, x: 216, y: 266, scale: 1.2) { g in
            rack(&g, width: 190, height: 120, rows: 2, tarp: true, seed: 5)
        }
        Kit.shadow(&context, 112, 272, width: 30, alpha: 0.24)
        Art.group(&context, x: 110, y: 272, scale: 1.6) { g in
            bucket(&g, strips: true)
        }
        Art.group(&context, x: 334, y: 278, scale: 1.4) { g in
            gull(&g)
        }
        Kit.grassTuft(&context, x: 66, baseY: 286, height: 26, color: 0x6F8C54, seed: 94)
        Kit.grassTuft(&context, x: 378, baseY: 290, height: 30, color: 0x6F8C54, seed: 95)
        Kit.sink(&context, size, card: 0x7A2E22)
    }
}

// MARK: - see-kuskokwim

extension FishCampArt {
    /// The river from high up: a brown-silver ribbon looping over flat tundra dotted with ponds,
    /// one tiny skiff and its wake in the middle.
    static func riverPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let light = evening()
        let H: CGFloat = 64
        Kit.sky(&context, size, horizon: H, light: light)
        let tundra: Kit.Stops = [(Art.color(0xC4CB98), 0), (Art.color(0x9DB07A), 0.35), (Art.color(0x6F8C54), 1)]
        Kit.ground(&context, width: 432, top: H, bottom: size.height, stops: tundra, seed: 94)
        let field = CGRect(x: 0, y: H + 30, width: 432, height: 300)
        Kit.flecks(&context, in: field, count: 120, seed: 95, color: Art.color(0x587848, 0.45), radius: 1...3)
        Kit.flecks(&context, in: field, count: 60, seed: 96, color: Art.color(0xD4E0A0, 0.5), radius: 0.8...2)
        riverPonds(&context)
        let ribbon = Kit.treeRibbon(riverLoop(), 74, 10)
        Art.stroke(&context, ribbon.shape, Art.color(0x8A7458, 0.6), width: 5)
        let water: Kit.Stops = [(Art.color(0xD9C7A4), 0), (Art.color(0xAE9B7C), 0.5), (Art.color(0x8A785E), 1)]
        Art.fillLinear(&context, ribbon.shape, water, from: CGPoint(x: 0, y: H), to: CGPoint(x: 0, y: 404))
        Art.stroke(&context, ribbon.edge, Art.color(0xEFE6CE, 0.7), width: 1.6)
        let centre = Art.polygon(riverLoop(), closed: false)
        Art.stroke(&context, centre, Color.white.opacity(0.3), width: 2, dash: [10, 18])
        ArtStyle.atmosphere(&context, width: 432, top: H, bottom: H + 90, color: light.haze, alpha: 0.4)
        Art.group(&context, x: 240, y: 185, rotate: Kit.deg(-57)) { b in
            Art.stroke(&b, Art.svg("M-7,0 L-44,-10 M-7,0 L-44,10"), Color.white.opacity(0.65), width: 1.4)
            Kit.solid(&b, Art.svg("M-7,-3 L5,-3 L9,0 L5,3 L-7,3Z"), Art.color(aluminium), light: 0.3, shade: 0.2)
            Art.fill(&b, Art.rect(-5, -1.6, 9, 3.2, radius: 1), Art.color(0x6E7A80))
            Art.fill(&b, Art.circle(-4, 0, 1.6), Art.color(0xE8862E))
        }
        Kit.sink(&context, size, card: 0x1F4A5C)
    }

    /// The centre line of the looping river, from the bottom of the picture to the horizon.
    static func riverLoop() -> [CGPoint] {
        let a = Kit.treeCurve(CGPoint(x: 300, y: 430), CGPoint(x: 430, y: 330), CGPoint(x: 250, y: 300), steps: 12)
        let b = Kit.treeCurve(CGPoint(x: 250, y: 300), CGPoint(x: 60, y: 270), CGPoint(x: 170, y: 222), steps: 12)
        let c = Kit.treeCurve(CGPoint(x: 170, y: 222), CGPoint(x: 300, y: 180), CGPoint(x: 200, y: 140), steps: 10)
        let d = Kit.treeCurve(CGPoint(x: 200, y: 140), CGPoint(x: 110, y: 110), CGPoint(x: 180, y: 84), steps: 8)
        let e = Kit.treeCurve(CGPoint(x: 180, y: 84), CGPoint(x: 230, y: 72), CGPoint(x: 210, y: 64), steps: 4)
        var points: [CGPoint] = a
        points.append(contentsOf: b.dropFirst())
        points.append(contentsOf: c.dropFirst())
        points.append(contentsOf: d.dropFirst())
        points.append(contentsOf: e.dropFirst())
        return points
    }

    /// Small tundra ponds, flattened by the view from high up, smaller toward the horizon.
    static func riverPonds(_ context: inout GraphicsContext) {
        let ponds: [(CGFloat, CGFloat, CGFloat)] = [
            (70, 360, 22), (30, 296, 13), (390, 372, 18), (380, 250, 15), (312, 250, 9), (60, 196, 12),
            (340, 140, 10), (100, 126, 8), (384, 98, 7), (290, 92, 6), (60, 90, 6), (400, 170, 8),
        ]
        var water = Path()
        var sky = Path()
        for pond in ponds {
            water.addPath(Art.ellipse(pond.0, pond.1, pond.2, pond.2 * 0.42))
            sky.addPath(Art.ellipse(pond.0 - pond.2 * 0.25, pond.1 - pond.2 * 0.1, pond.2 * 0.5, pond.2 * 0.14))
        }
        Art.stroke(&context, water, Art.color(0x587848, 0.5), width: 2)
        Art.fill(&context, water, Art.color(0xBFCFCB))
        Art.fill(&context, sky, Art.color(0xFCE9C4, 0.7))
    }
}

// MARK: - see-first-catch

extension FishCampArt {
    /// Two hands in hoodie cuffs holding out the grass-wrapped salmon.
    static func firstCatchPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let back: Kit.Stops = [(Art.color(0x5A6E9E), 0), (Art.color(0x3E5286), 0.5), (Art.color(0x2E3F6E), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, h), back, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: h))
        Art.glow(&context, 216, 172, 210, Art.color(0xFFD08A), alpha: 0.36)
        Art.glow(&context, 110, 50, 150, Color.white, alpha: 0.1)
        let p = nickLook()
        let sleeve = Art.color(p.cloth)
        let cuff = Art.color(p.trim)
        let skin = Art.color(p.skin)
        let skinFar = Kit.personTone(p.skin, 0.88)
        Art.stroke(&context, Art.svg("M60,430 C80,340 110,262 150,214"), sleeve, width: 46)
        Art.stroke(&context, Art.svg("M372,430 C352,340 322,262 282,214"), sleeve, width: 46)
        Art.stroke(&context, Art.svg("M137,230 L151,213"), cuff, width: 48, cap: .butt)
        Art.stroke(&context, Art.svg("M295,230 L281,213"), cuff, width: 48, cap: .butt)
        Kit.solid(&context, Art.ellipse(158, 204, 22, 13), skinFar, light: 0.2, shade: 0.2)
        Kit.solid(&context, Art.ellipse(274, 204, 22, 13), skin, light: 0.2, shade: 0.2)
        Art.group(&context, x: 216, y: 168, rotate: Kit.deg(-4), scale: 2.6) { b in
            bundle(&b)
        }
        let leftFingers: [(CGFloat, CGFloat)] = [(144, 197), (154, 194), (164, 193)]
        let rightFingers: [(CGFloat, CGFloat)] = [(268, 191), (278, 192), (288, 195)]
        var fingers = Path()
        for f in leftFingers {
            fingers.addPath(Art.ellipse(f.0, f.1, 5, 7.5))
        }
        var near = Path()
        for f in rightFingers {
            near.addPath(Art.ellipse(f.0, f.1, 5, 7.5))
        }
        Kit.solid(&context, fingers, skinFar, light: 0.2, shade: 0.16)
        Kit.solid(&context, near, skin, light: 0.22, shade: 0.16)
        let drops: [(CGFloat, CGFloat, CGFloat)] = [(196, 228, 2.2), (232, 240, 1.8), (214, 252, 1.5), (250, 226, 1.6)]
        var beads = Path()
        for drop in drops {
            beads.addPath(Art.circle(drop.0, drop.1, drop.2))
        }
        Art.fill(&context, beads, Color.white.opacity(0.7))
        Kit.sink(&context, size, card: 0x2E3F6E)
    }
}

// MARK: - see-sod-house

extension FishCampArt {
    /// A sod house of long ago on autumn tundra: a low grass-covered mound framed with
    /// driftwood, partly in the ground, its short entrance tunnel toward us, a thread of smoke
    /// from the top. No snow: this was never a snow house.
    static func sodHousePicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let H: CGFloat = 230
        let sky: Kit.Stops = [(Art.color(0xF3EBD8), 0), (Art.color(0xF6E0BC), 0.6), (Art.color(0xF7C998), 1)]
        let light = Kit.Light(sky: sky, sun: 0xFFF4DC, glow: 0xF7C998, haze: 0xF2DCC0, far: 0xB8A47A, mid: 0x9A8A5A, near: 0x6E6A3E)
        Kit.sky(&context, size, horizon: H, light: light)
        cloudStreaks(&context, width: 432, horizon: H, color: Color.white)
        Kit.birds(&context, 300, 72, scale: 0.8, color: Art.color(0x6A5E58, 0.6))
        let farLand = Kit.ridge(width: 432, y: H - 5, amp: 3, seed: 96, bottom: H + 4)
        Art.fill(&context, farLand, light.far)
        ArtStyle.atmosphere(&context, width: 432, top: H - 20, bottom: H + 4, color: light.haze, alpha: 0.3)
        let autumn: Kit.Stops = [(Art.color(0xC29A52), 0), (Art.color(0x9A6A36), 0.45), (Art.color(0x3D4A2A), 1)]
        Kit.ground(&context, width: 432, top: H, bottom: size.height, stops: autumn, seed: 97)
        let tundra = CGRect(x: 0, y: H + 6, width: 432, height: 110)
        Kit.flecks(&context, in: tundra, count: 90, seed: 98, color: Art.color(0xB8402E, 0.7), radius: 0.8...2)
        Kit.flecks(&context, in: tundra, count: 60, seed: 99, color: Art.color(0xE8B848, 0.6), radius: 0.8...1.8)
        sodMound(&context)
        sodEntrance(&context)
        smoke(&context, x: 246, y: 136, scale: 0.9)
        let wood = Art.color(0xA29E94)
        Art.stroke(&context, Art.line(296, 272, 352, 276), Kit.personTone(0xA29E94, 0.7), width: 7)
        Art.stroke(&context, Art.line(296, 271, 352, 275), wood, width: 4.4)
        Art.stroke(&context, Art.line(60, 266, 92, 262), wood, width: 4)
        Kit.sink(&context, size, card: 0x3D4A2A)
    }

    /// The main mound: layers of sod over a driftwood frame, grass on top, a smoke hole.
    static func sodMound(_ context: inout GraphicsContext) {
        Kit.shadow(&context, 238, 246, width: 300, alpha: 0.26)
        let mound: Path = Art.svg("M98,246 C102,196 158,148 236,146 C312,148 364,196 370,246Z")
        let grass: Kit.Stops = [(Art.color(0xA8A860), 0), (Art.color(0x7E8A48), 0.5), (Art.color(0x5A6236), 1)]
        Kit.solid(&context, mound, stops: grass, light: 0.26, shade: 0.24, rim: 1.4)
        var layers = Path()
        for i in 0..<5 {
            let y: CGFloat = 172 + CGFloat(i) * 15
            layers.move(to: CGPoint(x: 90, y: y + 22))
            layers.addQuadCurve(to: CGPoint(x: 380, y: y + 22), control: CGPoint(x: 236, y: y - 14))
        }
        let sod = layers
        Art.clipped(&context, to: mound) { c in
            Art.stroke(&c, sod, Art.color(0x4E5630, 0.35), width: 1.2)
            Art.stroke(&c, Art.svg("M180,168 L182,180 M262,166 L260,178 M150,196 L152,208 M300,192 L298,206 M210,214 L212,228 M330,222 L328,236"), Art.color(0x4E5630, 0.3), width: 1)
        }
        let tops: [(CGFloat, CGFloat, UInt32)] = [(150, 178, 1), (188, 156, 2), (226, 148, 3), (286, 153, 4), (330, 176, 5), (356, 210, 6)]
        for top in tops {
            Kit.grassTuft(&context, x: top.0, baseY: top.1, height: 14, color: 0x8E8A48, seed: top.2)
        }
        Art.fill(&context, Art.rect(234, 141, 22, 8, radius: 1), Art.color(0x3A3028))
        Art.stroke(&context, Art.svg("M230,141 L260,140 M231,149 L259,149"), Art.color(0xA29E94), width: 2.4)
        Art.stroke(&context, Art.line(354, 246, 334, 194), Kit.personTone(0xA29E94, 0.7), width: 7)
        Art.stroke(&context, Art.line(353, 245, 333, 194), Art.color(0xA29E94), width: 4.4)
        let base = CGRect(x: 96, y: 236, width: 276, height: 12)
        Kit.grass(&context, in: base, count: 40, seed: 7, color: Art.color(0x8E8A48, 0.9), height: 8)
    }

    /// The short entrance tunnel toward the viewer, its doorway framed in grey driftwood.
    static func sodEntrance(_ context: inout GraphicsContext) {
        Kit.shadow(&context, 170, 264, width: 120, alpha: 0.26)
        let tunnel: Path = Art.svg("M118,264 C120,232 140,214 168,212 C196,212 216,230 220,264Z")
        let grass: Kit.Stops = [(Art.color(0xA0A05A), 0), (Art.color(0x6E7A40), 1)]
        Kit.solid(&context, tunnel, stops: grass, light: 0.28, shade: 0.22, rim: 1.2)
        let doorway: Path = Art.svg("M152,264 L152,240 C152,234 158,231 168,231 C178,231 184,234 184,240 L184,264Z")
        Art.fill(&context, doorway, Art.color(0x2E2620))
        let posts: Path = Art.svg("M149,266 L151,232 M187,266 L185,232")
        Art.stroke(&context, posts, Kit.personTone(0xA29E94, 0.66), width: 7)
        Art.stroke(&context, posts, Art.color(0xA29E94), width: 4.4)
        let lintel = Art.line(142, 231, 194, 228)
        Art.stroke(&context, lintel, Kit.personTone(0xA29E94, 0.66), width: 8)
        Art.stroke(&context, lintel, Art.color(0xB6B2A8), width: 5)
        Art.stroke(&context, Art.svg("M150,236 L150.6,252 M186,240 L185.6,256 M150,229.6 L170,228.4"), Art.color(0xE4E0D6, 0.6), width: 1)
        Kit.grassTuft(&context, x: 134, baseY: 222, height: 12, color: 0x8E8A48, seed: 11)
        Kit.grassTuft(&context, x: 204, baseY: 224, height: 12, color: 0x8E8A48, seed: 12)
    }
}

// MARK: - Portraits

extension FishCampArt {
    /// Nick hugging the grass-wrapped king salmon against his blue hoodie, proud and a little unsure.
    static func nickPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0xFFE3B0, bottom: 0xD98A5A, halo: 0xFFF2D6, rays: false) { g in
            fireweed(&g, x: 38, baseY: 410, height: 250, seed: 21)
            fireweed(&g, x: 72, baseY: 420, height: 186, seed: 22)
            fireweed(&g, x: 396, baseY: 414, height: 230, seed: 23)
            Kit.grassTuft(&g, x: 30, baseY: 404, height: 70, color: 0x6F8C54, seed: 24)
            Kit.grassTuft(&g, x: 404, baseY: 404, height: 64, color: 0x6F8C54, seed: 25)
            Art.group(&g, x: 216, y: 140, scale: 2.4) { b in
                nickBust(&b)
            }
        }
    }

    /// Nick's bust in bust units (origin at the head centre): hood, cap, bundle and both arms.
    static func nickBust(_ b: inout GraphicsContext) {
        let p = nickLook()
        Kit.bust(&b, p, look: CGPoint(x: 0, y: 0.1), mouth: .smile)
        Art.group(&b, scale: 0.9) { c in
            capShape(&c, hex: capFaded)
        }
        let collar: Path = Art.svg("M-34,40 C-28,30 28,30 34,40 C24,52 -24,52 -34,40Z")
        Kit.solid(&b, collar, Kit.personTone(p.cloth, 0.86), light: 0.2, shade: 0.2)
        Art.stroke(&b, Art.svg("M-7,46 L-8,64 M6,46 L7,65"), Art.color(0xE8EEF4), width: 1.6)
        Art.group(&b, x: 2, y: 80, rotate: Kit.deg(-8), scale: 1.3) { f in
            bundle(&f)
        }
        let sleeve = Art.color(p.cloth)
        let cuff = Art.color(p.trim)
        Art.stroke(&b, Art.svg("M-58,64 C-70,92 -54,104 -26,98"), sleeve, width: 22)
        Art.stroke(&b, Art.svg("M58,64 C70,88 56,98 30,94"), sleeve, width: 22)
        Art.stroke(&b, Art.svg("M-34,101 L-30,91 M38,97 L34,87"), cuff, width: 3)
        Kit.solid(&b, Art.ellipse(-22, 96, 8.5, 7.5), Art.color(p.skin), light: 0.2, shade: 0.18)
        Kit.solid(&b, Art.ellipse(26, 92, 8.5, 7.5), Art.color(p.skin), light: 0.2, shade: 0.18)
    }

    /// Grandma at the plank cutting table, the uluaq in her fist, a calm asking half-smile;
    /// the red strips and the blue tarp soft behind her.
    static func grandmaPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0xCFE6E4, bottom: 0x4E8C96, halo: 0xFFF2D6, rays: false) { g in
            Art.group(&g, opacity: 0.55) { r in
                Kit.solid(&r, Art.rect(-10, 16, 452, 30, radius: 6), Art.color(tarpBlue), light: 0.2, shade: 0.2)
                Art.stroke(&r, Art.line(-10, 52, 442, 50), Art.color(peeledPole), width: 4)
                strips(&r, x0: 0, x1: 128, y: 52, length: 70, seed: 4)
                strips(&r, x0: 304, x1: 432, y: 51, length: 70, seed: 6)
            }
            Art.group(&g, x: 216, y: 142, scale: 2.2) { b in
                grandmaBust(&b)
            }
            grandmaTable(&g)
        }
    }

    /// Grandma's bust in bust units: the hood behind her neck, the flowered qaspeq, the apron.
    static func grandmaBust(_ b: inout GraphicsContext) {
        let p = grandmaLook()
        Kit.solid(&b, Art.ellipse(0, 36, 42, 11), Kit.personTone(p.cloth, 0.84), light: 0.16, shade: 0.2)
        Kit.bust(&b, p, look: CGPoint(x: 0, y: -0.15), mouth: .smile)
        scarfDots(&b)
        let shoulders: Path = Art.svg("M-60,150 L-60,62 C-60,44 -40,36 -14,34 L14,34 C40,36 60,44 60,62 L60,150Z")
        var petals = Path()
        var hearts = Path()
        for row in 0..<5 {
            for col in 0..<8 {
                let shift: CGFloat = row % 2 == 0 ? 0 : 7
                let x: CGFloat = -54 + CGFloat(col) * 15.5 + shift
                let y: CGFloat = 54 + CGFloat(row) * 20
                petals.addPath(Art.circle(x, y, 2.2))
                hearts.addPath(Art.circle(x, y, 0.8))
            }
        }
        let flowers = petals
        let middles = hearts
        Art.clipped(&b, to: shoulders) { c in
            Art.fill(&c, flowers, Color.white.opacity(0.85))
            Art.fill(&c, middles, Art.color(0xFFD08A))
        }
        let cream = Art.color(0xF3EAD6)
        Art.stroke(&b, Art.svg("M-20,72 L-30,46 M20,72 L30,46"), cream, width: 4)
        Kit.solid(&b, Art.svg("M-20,72 L20,72 L24,150 L-24,150Z"), cream, light: 0.16, shade: 0.16)
    }

    /// The plank table across the foot of the portrait, the open salmon, her hands and the uluaq.
    static func grandmaTable(_ g: inout GraphicsContext) {
        let p = grandmaLook()
        let wood: UInt32 = 0xB7A07A
        Kit.solid(&g, Art.rect(-10, 328, 452, 14, radius: 3), Art.color(wood), light: 0.28, shade: 0.16)
        Art.fill(&g, Art.rect(-10, 342, 452, 70), Kit.personTone(wood, 0.62))
        Art.stroke(&g, Art.line(-10, 335, 442, 335), Kit.personTone(wood, 0.78), width: 1)
        Art.stroke(&g, Art.line(-10, 329.5, 442, 329.5), Art.color(0xF3E6C8, 0.6), width: 1.2)
        Art.group(&g, x: 178, y: 334, scale: 2.4) { f in
            fillet(&f)
        }
        let sleeve = Art.color(p.cloth)
        let skin = Art.color(p.skin)
        Art.stroke(&g, Art.svg("M88,282 C84,310 92,326 104,330 L150,334"), sleeve, width: 30)
        Kit.solid(&g, Art.ellipse(160, 333, 15, 8), Kit.personTone(p.skin, 0.9), light: 0.2, shade: 0.18)
        Art.stroke(&g, Art.svg("M346,280 C356,312 336,316 306,296"), sleeve, width: 30)
        Art.group(&g, x: 292, y: 288, scale: 1.6) { u in
            uluaq(&u)
        }
        Kit.solid(&g, Art.circle(294, 286, 12.5), skin, light: 0.24, shade: 0.2)
        Art.stroke(&g, Art.svg("M286,280 L298,279 M286,286 L299,285"), Kit.personTone(p.skin, 0.74), width: 1.2)
    }
}

// MARK: - Face chips

extension FishCampArt {
    static func nickFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xD6E9F7) { g in
            Art.group(&g, x: 0, y: 8, scale: 1.4) { f in
                Kit.personHead(&f, nickLook(), look: .zero, mouth: .grin)
                Art.group(&f, scale: 0.9) { c in
                    capShape(&c, hex: capFaded)
                }
            }
        }
    }

    static func grandmaFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xFFE2A8) { g in
            Art.group(&g, x: 0, y: 0, scale: 1.05) { f in
                Kit.personHead(&f, grandmaLook(), look: .zero, mouth: .smile)
                scarfDots(&f)
            }
        }
    }

    static func lenaFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xF6DCE7) { g in
            Art.group(&g, x: 0, y: 0, scale: 1.05) { f in
                Kit.personHead(&f, lenaLook(), look: .zero, mouth: .smile)
                glasses(&f)
            }
        }
    }
}

// MARK: - Cover

extension FishCampArt {
    /// Nick on the bank path hugging his first salmon, looking down the river, the camp small
    /// behind him under the wide pale gold sky.
    static func cover(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.cover(&context, size) { g, frame in
            let H: CGFloat = frame.H
            let hd: CGFloat = frame.hd
            let light = evening()
            Kit.sky(&g, CGSize(width: 240, height: hd), horizon: H, light: light)
            cloudStreaks(&g, width: 240, horizon: H, color: Color.white)
            Art.glow(&g, 10, H - 8, 90, light.glow, alpha: 0.42)
            farShore(&g, width: 240, horizon: H, scale: 0.5, light: light, seed: 5)
            Kit.water(&g, width: 240, top: H, bottom: hd, stops: riverStops(), light: light, ripples: 16, seed: 6)
            Kit.glints(&g, x: 40, top: H, depth: hd - H, color: Art.color(0xFFF6E0), count: 16, seed: 7)
            coverBank(&g, frame)
            coverNick(&g, frame)
        }
    }

    /// The bank from the middle to the trailing edge, the path, the camp small on it.
    static func coverBank(_ g: inout GraphicsContext, _ frame: Kit.CoverFrame) {
        let H: CGFloat = frame.H
        let hd: CGFloat = frame.hd
        let k: CGFloat = frame.k
        var land = Path()
        land.move(to: CGPoint(x: 250, y: H - 1))
        land.addLine(to: CGPoint(x: 96, y: H - 1))
        land.addQuadCurve(to: CGPoint(x: 20, y: hd + 4), control: CGPoint(x: 60, y: H + 10))
        land.addLine(to: CGPoint(x: 250, y: hd + 4))
        land.closeSubpath()
        Art.fillLinear(&g, land, grassStops(), from: CGPoint(x: 0, y: H), to: CGPoint(x: 0, y: hd))
        var face = Path()
        face.move(to: CGPoint(x: 96, y: H))
        face.addQuadCurve(to: CGPoint(x: 19, y: hd + 4), control: CGPoint(x: 59, y: H + 11))
        Art.stroke(&g, face, Art.color(0x8A7458), width: 3)
        Art.stroke(&g, Art.line(98, H - 0.5, 240, H - 0.5), Art.color(0xD4E0A0, 0.7), width: 1)
        Art.group(&g, x: 230, y: H + 1, scale: 0.35 * k) { c in
            cabin(&c, width: 84, height: 46, rise: 14, wall: plywood, roof: 0x4E5258, boards: false, door: true, pipe: true)
        }
        Art.group(&g, x: 192, y: H + 3, scale: 0.4 * k) { r in
            rack(&r, width: 110, height: 60, rows: 2, tarp: true, seed: 8)
        }
        let dirt: Kit.Stops = [(Art.color(0xB8A27C, 0.9), 0), (Art.color(0x9A8664, 0.95), 1)]
        Kit.ribbon(&g, nearX: 124, nearY: hd + 6, nearWidth: 70 * k, farX: 172, farY: H + 4, farWidth: 8, stops: dirt)
        let near = CGRect(x: 60, y: H + 4, width: 180, height: max(8, hd - H - 4))
        Kit.grass(&g, in: near, count: 40, seed: 9, color: Art.color(0x5F7F4A, 0.75), height: 6 * k)
    }

    /// Nick with the bundle, fireweed and grass round his boots, and tall fireweed framing the
    /// top trailing corner.
    static func coverNick(_ g: inout GraphicsContext, _ frame: Kit.CoverFrame) {
        let H: CGFloat = frame.H
        let hd: CGFloat = frame.hd
        let k: CGFloat = frame.k
        let feet: CGFloat = H + 34 * k
        Kit.shadow(&g, 122, feet, width: 50 * k)
        Art.group(&g, x: 120, y: feet, scale: 0.95 * k) { n in
            nick(&n, act: .hug, look: CGPoint(x: -0.7, y: 0.1), mouth: .smile)
        }
        fireweed(&g, x: 92, baseY: feet + 6 * k, height: 54 * k, seed: 31)
        fireweed(&g, x: 152, baseY: feet + 8 * k, height: 46 * k, seed: 32)
        Kit.grassTuft(&g, x: 104, baseY: feet + 6 * k, height: 20 * k, color: 0x6F8C54, seed: 33)
        Kit.grassTuft(&g, x: 140, baseY: feet + 7 * k, height: 18 * k, color: 0x6F8C54, seed: 34)
        fireweed(&g, x: 233, baseY: hd + 4, height: hd * 0.92, seed: 35)
        fireweed(&g, x: 219, baseY: hd + 8, height: hd * 0.68, seed: 36)
        Kit.grassTuft(&g, x: 234, baseY: hd + 4, height: 40 * k, color: 0x4A6440, seed: 37)
    }
}
