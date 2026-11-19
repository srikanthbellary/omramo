import SwiftUI
import OmramoCore

// The tap-to-see pictures (432 × 404), the character-card portraits (432 × 400), the face
// chips (100 × 100) and the cover of "Savitri and Satyavan".

// MARK: - Tap-to-see pictures

extension SavitriArt {
    /// A pale sky and a forest edge for the pictures, ground from `groundY` down.
    static func pictureBackdrop(_ context: inout GraphicsContext, _ size: CGSize, groundY: CGFloat, light: Kit.Light, ground: Kit.Stops) {
        Kit.sky(&context, size, horizon: groundY, light: light)
        Kit.farTrees(&context, x0: -10, x1: size.width + 10, baseY: groundY + 2, height: 56, count: 12, color: light.far, seed: 19)
        ArtStyle.atmosphere(&context, width: size.width, top: groundY - 80, bottom: groundY + 4, color: light.haze, alpha: 0.4)
        Kit.farTrees(&context, x0: -10, x1: size.width + 10, baseY: groundY + 4, height: 34, count: 10, color: light.mid, seed: 29)
        Kit.ground(&context, width: size.width, top: groundY, bottom: size.height, stops: ground, seed: 81)
    }

    /// The look of the chariot's white horses.
    static func whiteHorseLook() -> Kit.Beast {
        var look = Kit.horseLook()
        look.body = 0xF4F0E6
        look.belly = 0xFFFDF6
        look.dark = 0xB8AE9E
        look.mane = true
        look.showsEyeWhite = false
        return look
    }

    /// "Her own choice": one gold-painted two-wheeled chariot with two white horses, on a pale
    /// forest road.
    static func chariotPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let groundY: CGFloat = 214
        let road: Kit.Stops = [(Art.color(0xD8C08A), 0), (Art.color(0x9A8452), 1)]
        pictureBackdrop(&context, size, groundY: groundY, light: morning(), ground: road)
        let path: Kit.Stops = [(Art.color(0xF0E0BC), 0), (Art.color(0xE6D2A4), 1)]
        Kit.ribbon(&context, nearX: 200, nearY: 420, nearWidth: 300, farX: 300, farY: groundY + 4, farWidth: 40, stops: path)
        salTree(&context, x: 30, baseY: groundY + 20, height: 190, seed: 3)
        salTree(&context, x: 404, baseY: groundY + 14, height: 170, seed: 9)
        let horse = whiteHorseLook()
        let k: CGFloat = 0.6
        let back: CGPoint = Kit.beastBack(horse, pose: .walk)
        Kit.shadow(&context, 168, 268, width: 120)
        Art.group(&context, x: 172, y: 256, scale: k * 0.96, opacity: 0.94) { b in
            Kit.beast(&b, horse, pose: .walk, mood: .calm, look: .zero, mirrored: false)
        }
        chariotBody(&context, cx: 300, groundY: 270, yokeX: 150 + back.x * k, yokeY: 266 + back.y * k)
        Kit.shadow(&context, 150, 272, width: 120)
        Art.group(&context, x: 150, y: 270, scale: k) { b in
            Kit.beast(&b, horse, pose: .walk, mood: .calm, look: .zero, mirrored: false)
            let harness = Art.svg("M-30,-96 C-14,-90 6,-90 22,-96")
            Art.stroke(&b, harness.applying(CGAffineTransform(translationX: back.x, y: back.y + 96)), Art.color(0xB0322A), width: 5)
        }
        Kit.sink(&context, size, card: 0x5A3A12)
    }

    /// The chariot itself: a gold-painted box with a curved front rail, one big spoked wheel
    /// (the near one) and the pole running forward to the yoke.
    static func chariotBody(_ context: inout GraphicsContext, cx: CGFloat, groundY: CGFloat, yokeX: CGFloat, yokeY: CGFloat) {
        let r: CGFloat = 36
        Kit.shadow(&context, cx + 4, groundY, width: 96)
        Kit.propWheel(&context, x: cx + 16, y: groundY - r - 6, r: r * 0.9, color: 0x9A6A2A)
        Art.stroke(&context, Art.line(cx - 40, groundY - r - 4, yokeX, yokeY), Art.color(0x7A4E26), width: 5)
        Art.stroke(&context, Art.line(cx - 40, groundY - r - 5, yokeX, yokeY - 1), Art.color(0xC89A5A, 0.6), width: 1.4)
        let box = Art.svg("M-44,-36 C-50,-60 -40,-80 -22,-84 L34,-84 C40,-84 44,-78 44,-70 L44,-36Z")
        let placed = box.applying(CGAffineTransform(translationX: cx, y: groundY - r + 8))
        Kit.solid(&context, placed, stops: Kit.stops(0xF0C858, 0xC8962E), light: 0.34, shade: 0.24, rim: 1.6)
        var rails = Path()
        rails.move(to: CGPoint(x: cx - 40, y: groundY - r - 42))
        rails.addQuadCurve(to: CGPoint(x: cx + 40, y: groundY - r - 52), control: CGPoint(x: cx - 6, y: groundY - r - 64))
        Art.stroke(&context, rails, Art.color(0x9A6A1A), width: 2.4)
        var lotusBand = Path()
        var x: CGFloat = cx - 34
        while x < cx + 40 {
            lotusBand.addPath(Art.circle(x, groundY - r - 14, 3.2))
            x += 12
        }
        Art.stroke(&context, lotusBand, Art.color(0xB0322A), width: 1.4)
        Kit.propWheel(&context, x: cx - 6, y: groundY - r, r: r, color: 0xB07A32)
        Art.fill(&context, Art.circle(cx - 6, groundY - r, 5), Art.color(0xE9BE3A))
    }

    /// "Forest hermitage": one hut of reed and leaf beside a small square fire altar with a thin
    /// thread of smoke, in a clearing.
    static func hermitagePicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let groundY: CGFloat = 222
        let earth: Kit.Stops = [(Art.color(0xE4D09E), 0), (Art.color(0xA8925A), 1)]
        pictureBackdrop(&context, size, groundY: groundY, light: goldLight(), ground: earth)
        salTree(&context, x: 24, baseY: groundY + 16, height: 200, seed: 4)
        salTree(&context, x: 410, baseY: groundY + 10, height: 186, seed: 8)
        Kit.bush(&context, x: 380, baseY: groundY + 24, width: 70, palette: salGreens(), seed: 5)
        let clearing = Art.ellipse(216, 262, 190, 34)
        Art.fill(&context, clearing, Art.color(0xF0E0B4, 0.7))
        hut(&context, cx: 262, baseY: 268, width: 150, height: 150, lamps: false)
        grassMat(&context, cx: 150, baseY: 286, width: 70)
        fireAltar(&context, cx: 128, baseY: 274, width: 64, smoke: true)
        Kit.pot(&context, cx: 350, baseY: 278, width: 22, height: 24, color: 0xB5683A)
        Kit.pot(&context, cx: 372, baseY: 282, width: 16, height: 18, color: 0xA85A30)
        Kit.grass(&context, in: CGRect(x: 0, y: 256, width: 432, height: 60), count: 30, seed: 7, color: Art.color(0x7E8A46, 0.6), height: 8)
        Kit.sink(&context, size, card: 0x2F4A24)
    }

    /// "Banyan tree": one broad banyan with many hanging roots, some grown into pillars, on
    /// open ground.
    static func banyanPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let groundY: CGFloat = 236
        let grass: Kit.Stops = [(Art.color(0xCFCB8E), 0), (Art.color(0x8E9A5A), 1)]
        pictureBackdrop(&context, size, groundY: groundY, light: afternoon(), ground: grass)
        banyan(&context, x: 216, baseY: 280, height: 230, spread: 360, seed: 21)
        Kit.grass(&context, in: CGRect(x: 0, y: 262, width: 432, height: 50), count: 34, seed: 9, color: Art.color(0x6E8A44, 0.6), height: 8)
        Kit.flowers(&context, in: CGRect(x: 30, y: 280, width: 372, height: 30), count: 10, seed: 10, petal: 0xFFE8A8, heart: 0xE07A1A)
        Kit.sink(&context, size, card: 0x3A4A1C)
    }

    /// "A boon": two cupped hands holding a small clay oil lamp with one steady flame, on a
    /// dark saffron ground.
    static func boonPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let full = Art.rect(0, 0, size.width, size.height)
        let ground: Kit.Stops = [(Art.color(0xC0682A), 0), (Art.color(0x8E3E16), 0.6), (Art.color(0x6A2E10), 1)]
        Art.fillRadial(&context, full, ground, center: CGPoint(x: 200, y: 170), radius: 300)
        Art.glow(&context, 196, 160, 170, Art.color(0xFFD27A), alpha: 0.45)
        ArtStyle.tooth(&context, in: CGRect(x: 0, y: 0, width: size.width, height: size.height), seed: 12, alpha: 0.05)
        cupHands(&context, back: true)
        diya(&context, cx: 216, cy: 204)
        cupHands(&context, back: false)
        Kit.sink(&context, size, card: 0x6A2E10)
    }

    /// The two cupped hands: the far parts (palms) with `back`, the near fingers without.
    static func cupHands(_ context: inout GraphicsContext, back: Bool) {
        let skin: Kit.Stops = Kit.stops(0xD69A6A, 0xA86E44)
        if back {
            let palms = Art.svg("M96,330 C92,290 110,246 150,226 C180,212 252,212 282,226 C322,246 340,290 336,330 Z")
            Kit.solid(&context, palms, stops: skin, light: 0.26, shade: 0.3)
            return
        }
        let left = Art.svg("M84,336 C78,292 94,250 130,230 C140,226 150,230 150,240 C138,250 128,262 134,276 C150,290 186,296 216,296 L216,336 Z")
        let right = Art.svg("M348,336 C354,292 338,250 302,230 C292,226 282,230 282,240 C294,250 304,262 298,276 C282,290 246,296 216,296 L216,336 Z")
        Kit.solid(&context, left, stops: skin, light: 0.3, shade: 0.24, rim: 1.6)
        Kit.solid(&context, right, stops: skin, light: 0.22, shade: 0.3)
        let fingers = Art.svg("M132,236 C122,248 118,262 124,276 M144,234 C136,246 134,260 140,272 M300,236 C310,248 314,262 308,276 M288,234 C296,246 298,260 292,272 M216,300 L216,334")
        Art.stroke(&context, fingers, Art.color(0x8E5A36, 0.7), width: ArtStyle.detailLine)
        let thumbs = Art.svg("M150,244 C164,236 182,238 192,246 M282,244 C268,236 250,238 240,246")
        Art.stroke(&context, thumbs, Art.color(0xC48A5A), width: 9)
        Art.stroke(&context, thumbs, Art.color(0xE0AC7C, 0.6), width: 2.4)
    }

    /// A small clay oil lamp (diya) with a pinched spout and one steady flame.
    static func diya(_ context: inout GraphicsContext, cx: CGFloat, cy: CGFloat) {
        let move = CGAffineTransform(translationX: cx, y: cy)
        let bowl = Art.svg("M-58,-6 C-50,26 50,26 58,-6 Q0,6 -58,-6Z").applying(move)
        Kit.solid(&context, bowl, stops: Kit.stops(0xC87444, 0x8E4424), light: 0.3, shade: 0.28)
        let spout = Art.svg("M-50,-8 Q-66,-14 -76,-22 Q-60,-22 -42,-12Z").applying(move)
        Kit.solid(&context, spout, Art.color(0xB8643A), light: 0.3, shade: 0.2)
        Art.fill(&context, Art.ellipse(cx, cy - 6, 56, 8), Art.color(0xD8884E))
        Art.fill(&context, Art.ellipse(cx + 2, cy - 5, 48, 5.5), Art.color(0x7A4A1E))
        Art.fill(&context, Art.ellipse(cx - 6, cy - 6.5, 26, 2.2), Art.color(0xE8B868, 0.6))
        let wickX: CGFloat = cx - 72
        let wickY: CGFloat = cy - 22
        Art.glow(&context, wickX, wickY - 16, 70, Art.color(0xFFD27A), alpha: 0.6)
        let outer = Kit.propFlame(wickX, wickY, 14, 40, 1)
        Art.fill(&context, outer, Art.color(0xFFB43A))
        let inner = Kit.propFlame(wickX, wickY, 7, 22, 0.5)
        Art.fill(&context, inner, Art.color(0xFFF2C4))
        Art.fill(&context, Art.ellipse(wickX, wickY - 2, 2.2, 3), Art.color(0x6A3A1A))
    }
}

// MARK: - Portraits

extension SavitriArt {
    /// Savitri: half figure in her saffron and gold drape, the braid over one shoulder,
    /// standing very straight and looking out steadily; pale gold sky behind.
    static func savitriPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0xFFF3DC, bottom: 0xE4A85C, halo: 0xFFF8E6, rays: false) { g in
            torana(&g, cx: 66, baseY: 404, height: 130, color: 0xF2DDB4)
            farPavilion(&g, cx: 376, baseY: 404, width: 90, height: 70, color: 0xF2DDB4)
            Art.group(&g, x: 216, y: 142, scale: 2.2) { b in
                let look = savitriLook(bark: false)
                Kit.bust(&b, look, look: CGPoint(x: 0, y: -0.1), mouth: .smile, wave: false)
                let pallu = Art.svg("M-60,66 C-50,50 -34,40 -16,36 L-4,38 C-18,70 -30,110 -36,152 L-60,152Z")
                Kit.solid(&b, pallu, Art.color(0xF0A228), light: 0.3, shade: 0.24)
                Art.stroke(&b, Art.svg("M-4,38 C-18,70 -30,110 -36,152"), Art.color(0xE9BE3A), width: 4)
                Art.stroke(&b, Art.svg("M-10,40 C-24,74 -34,112 -40,152"), Art.color(0xB8862A), width: 1.2)
                var braid = Path()
                braid.move(to: CGPoint(x: 20, y: 22))
                braid.addQuadCurve(to: CGPoint(x: 36, y: 128), control: CGPoint(x: 44, y: 70))
                Art.stroke(&b, braid, Art.color(0x1E1612), width: 11)
                var plaits = Path()
                let steps: [CGFloat] = [40, 56, 72, 88, 104, 118]
                for t in steps {
                    let px: CGFloat = 30 + (t - 22) * 0.07
                    plaits.move(to: CGPoint(x: px - 5, y: t - 3))
                    plaits.addQuadCurve(to: CGPoint(x: px + 5, y: t + 2), control: CGPoint(x: px, y: t + 3))
                }
                Art.stroke(&b, plaits, Art.color(0x4A3A30), width: 1.4)
                Art.fill(&b, Art.circle(36, 132, 3.6), Art.color(0xE9BE3A))
                let gold: Color = Art.color(0xE9BE3A)
                var necklace = Path()
                necklace.move(to: CGPoint(x: -17, y: 36))
                necklace.addQuadCurve(to: CGPoint(x: 17, y: 36), control: CGPoint(x: 0, y: 60))
                Art.stroke(&b, necklace, gold, width: 3)
                Art.fill(&b, Art.circle(0, 49, 3.4), Art.color(0xB0322A))
                Art.fill(&b, Art.circle(-26.5, 12, 2.8), gold)
                Art.fill(&b, Art.circle(26.5, 12, 2.8), gold)
            }
        }
    }

    /// Satyavan: half figure, bare-chested with the ochre shoulder cloth, the axe on his
    /// shoulder, smiling; leaf-green forest light behind.
    static func satyavanPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0xF1F6E4, bottom: 0x93BF72, halo: 0xF8FBEA, rays: false) { g in
            salTree(&g, x: 40, baseY: 420, height: 300, seed: 6)
            salTree(&g, x: 396, baseY: 420, height: 270, seed: 10)
            Art.group(&g, x: 216, y: 142, scale: 2.2) { b in
                Kit.bust(&b, satyavanLook(), look: .zero, mouth: .grin, wave: false)
                Art.group(&b, scaleX: -1) { a in
                    axeShape(&a, from: CGPoint(x: -66, y: 150), to: CGPoint(x: -40, y: -6))
                }
                Kit.bodyHand(&b, CGPoint(x: 60, y: 118), 10, Art.color(0xB27848), open: false)
            }
            Kit.cornerLeaves(&g, size: size, corner: 0, color: Art.color(0x3E5A26, 0.85), scale: 0.8, seed: 3)
        }
    }
}

// MARK: - Face chips

extension SavitriArt {
    static func savitriFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xFFE1C2) { g in
            Art.group(&g, x: 0, y: 4, scale: 1.25) { f in
                Kit.personHead(&f, savitriLook(bark: false), look: .zero, mouth: .smile)
                Art.fill(&f, Art.circle(-26.5, 12, 2.8), Art.color(0xE9BE3A))
                Art.fill(&f, Art.circle(26, 12, 2.6), Art.color(0xE9BE3A))
            }
        }
    }

    static func satyavanFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xDDEFCF) { g in
            Art.group(&g, x: 0, y: 7, scale: 1.2) { f in
                Kit.personHead(&f, satyavanLook(), look: .zero, mouth: .grin)
            }
        }
    }

    static func yamaFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xF3D9D2) { g in
            Art.group(&g, x: 0, y: 11, scale: 1.08) { f in
                Kit.personHead(&f, yamaLook(), look: .zero, mouth: .flat)
                yamaCrown(&f, at: CGPoint(x: 0, y: 0))
            }
        }
    }
}

// MARK: - Cover

extension SavitriArt {
    /// The south road at evening: Savitri in plain ochre following tall, calm Yama in red
    /// through gold grass, the small gold light in his hand, under a pale rose-gold sky.
    static func coverArt(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.cover(&context, size) { g, frame in
            let light = evening()
            let k: CGFloat = frame.k
            let H: CGFloat = frame.H
            let area = CGSize(width: 240, height: frame.hd)
            Kit.sky(&g, area, horizon: H, light: light)
            Kit.sun(&g, 40, H - 16 * k, 9 * k, light: light)
            Kit.cloud(&g, 170, H - 70 * k, scale: 0.4 * k, color: Art.color(0xFFF2EC, 0.5))
            Kit.ranges(&g, width: 240, horizon: H, scale: 0.3 * k, light: light, seed: 33)
            Kit.farTrees(&g, x0: -6, x1: 70, baseY: H + 2, height: 22 * k, count: 5, color: light.far, seed: 3)
            let field: Kit.Stops = [(Art.color(0xEACB92), 0), (Art.color(0xB88E54), 1)]
            Kit.ground(&g, width: 240, top: H, bottom: frame.hd, stops: field, seed: 85)
            goldGrass(&g, x0: 0, x1: 240, baseY: H + 4, height: 5 * k, seed: 21)
            let path: Kit.Stops = [(Art.color(0xE6C49A), 0), (Art.color(0xF0D6B2), 1)]
            Kit.ribbon(&g, nearX: 80, nearY: frame.hd + 6, nearWidth: 70, farX: 214, farY: H + 2, farWidth: 6, stops: path)
            Art.glow(&g, 150, H - 30 * k, 50 * k, Art.color(0xFFD27A), alpha: 0.22)
            yama(&g, x: 150, y: H + 12 * k, scale: 0.36 * k, right: true, pose: .walk, light: true)
            savitri(&g, x: 100, y: H + 20 * k, scale: 0.5 * k, right: true, bark: true, pose: .walk, pot: false, mouth: .flat)
            goldGrass(&g, x0: 0, x1: 240, baseY: H + 26 * k, height: 14 * k, seed: 22)
            if frame.hd > 180 {
                goldGrass(&g, x0: 0, x1: 240, baseY: frame.hd - 4, height: 26, seed: 23)
            }
            Kit.cornerLeaves(&g, size: area, corner: 1, color: Art.color(0x5E5A2E, 0.9), scale: 0.5, seed: 7)
        }
    }
}
