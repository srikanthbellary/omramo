import SwiftUI
import OmramoCore

// The smaller pictures of "The Monkey and the Crocodile": the two tap-to-see pictures, the
// Monkey's character-card portrait, the face chips and the cover.

extension JatakaArt {
    // MARK: Tap-to-see pictures (432 × 404)

    /// see-river-bank: the bank itself, as one centred form — a rounded grassy bank with its
    /// leaning tree, meeting the water. The far shore is pale and far away, the top-left
    /// corner (the close button) is open sky, and the bottom quarter is quiet water that
    /// sinks into the card colour #0A6585.
    static func riverBankPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        let h = size.height
        let H: CGFloat = 214
        let cardBlue = Art.color(0x0A6585)

        // Far plane: sky, the warm horizon, a pale far shore seen through the air.
        let sky: [(Color, CGFloat)] = [
            (Art.color(0xBDEFE9), 0), (Art.color(0xDDF8EC), 0.5), (Art.color(0xF6FBD9), 0.86), (Art.color(0xFFF2B5), 1),
        ]
        Art.fillLinear(&context, Art.rect(0, 0, w, h), sky, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: H))
        Art.glow(&context, 64, H - 26, 150, Art.color(0xFFF7C2), alpha: 0.8)
        ArtStyle.horizonGlow(&context, width: w, y: H, rise: 76, color: ArtStyle.jataka.glowColor, alpha: 0.5)
        cloud(&context, 300, 64, scale: 0.9, color: Art.color(0xFFFFFF, 0.5))
        Art.fill(&context, hills(width: w, y: H - 16, amp: 16, seed: 4, bottom: H + 6), Art.color(0xA8DDCF))
        Art.fill(&context, hills(width: w, y: H - 5, amp: 9, seed: 9, bottom: H + 6), Art.color(0x7CCAB2))
        ArtStyle.atmosphere(&context, width: w, top: H - 54, bottom: H + 6, color: Art.color(0xF6FBD9), alpha: 0.42)

        // The river.
        let water: [(Color, CGFloat)] = [
            (Art.color(0xA9E9D4), 0), (Art.color(0x4CC4B4), 0.14), (Art.color(0x1596A0), 0.48), (cardBlue, 0.8), (cardBlue, 1),
        ]
        Art.fillLinear(&context, Art.rect(0, H, w, h - H), water, from: CGPoint(x: 0, y: H), to: CGPoint(x: 0, y: h))
        Art.fill(&context, Art.rect(0, H, w, 6), Art.color(0x2B8C7E, 0.3))
        waterRipples(&context, x0: 0, x1: w, y0: H + 8, y1: 290, count: 30, seed: 31)

        // Middle plane, behind the subject: the land runs on along the river, paler.
        let spit = Art.svg("M318,216 C352,204 396,198 432,196 L432,230 C398,230 360,230 330,236Z")
        Art.fill(&context, spit, Art.color(0x7CCB8A))
        Art.fill(&context, Art.svg("M330,234 C360,230 398,229 432,229 L432,236 C398,236 362,238 336,240Z"), Art.color(0x8A6A4A, 0.7))
        ArtStyle.atmosphere(&context, width: w, top: 190, bottom: 242, color: Art.color(0xDDF8EC), alpha: 0.22)

        // The subject: the bank. First its reflection and the shade it throws on the water.
        Art.blurred(&context, radius: 6, opacity: 0.42) { g in
            Art.fill(&g, Art.ellipse(220, 284, 132, 13), Art.color(0x0B4B55))
        }
        let earth = Art.svg(
            "M82,254 C140,272 300,270 352,256 C357,262 353,268 344,272 C290,287 150,289 90,270 C80,266 78,260 82,254Z"
        )
        let earthStops: [(Color, CGFloat)] = [(Art.color(0x8E6844), 0), (Art.color(0x5E4030), 1)]
        Art.fillLinear(&context, earth, earthStops, from: CGPoint(x: 0, y: 256), to: CGPoint(x: 0, y: 288))
        let turf = Art.svg(
            "M82,254 C92,218 134,180 190,170 C244,160 312,170 344,208 C356,224 358,242 352,256 C300,270 140,272 82,254Z"
        )
        let turfStops: [(Color, CGFloat)] = [
            (Art.color(0x9BDD66), 0), (Art.color(0x4BAA5A), 0.42), (Art.color(0x1F6B50), 1),
        ]
        Art.fillLinear(&context, turf, turfStops, from: CGPoint(x: 0, y: 164), to: CGPoint(x: 0, y: 268))
        let turfBounds = CGRect(x: 82, y: 163, width: 276, height: 106)
        ArtStyle.form(&context, turf, bounds: turfBounds, light: 0.3, shade: 0.26)
        ArtStyle.rimEdge(&context, turf, bounds: turfBounds, width: 2.6, alpha: 0.5)
        Art.clipped(&context, to: turf) { g in
            ArtStyle.tooth(&g, in: turfBounds, seed: 43, color: Art.color(0xD6F08C), alpha: 0.14)
            // Blades of grass.
            var blades = Path()
            var grass = ArtRandom(41)
            for _ in 0..<64 {
                let t = rnd(&grass)
                let x: CGFloat = 100 + t * 240
                let off: CGFloat = (x - 216) / 134
                let top: CGFloat = 172 + off * off * 50
                let room: CGFloat = max(4, 252 - top)
                let y: CGFloat = top + 8 + rnd(&grass) * room
                let lean = (rnd(&grass) - 0.5) * 6
                blades.move(to: CGPoint(x: x, y: y))
                blades.addLine(to: CGPoint(x: x + lean, y: y - 7))
                blades.move(to: CGPoint(x: x + 3, y: y))
                blades.addLine(to: CGPoint(x: x + 4 + lean, y: y - 5))
            }
            Art.stroke(&g, blades, Art.color(0xC4EE7A, 0.55), width: 1.2)
            // The tree's shade on the grass, to its lower right.
            ArtStyle.contactShadow(&g, 276, 226, 62, 16, alpha: 0.3)
            // A few small flowers.
            let flowers: [(CGFloat, CGFloat)] = [(138, 228), (172, 204), (306, 204), (322, 238), (214, 248), (120, 248)]
            for flower in flowers {
                Art.fill(&g, Art.circle(flower.0, flower.1, 2.6), Art.color(0xFFF3C0))
                Art.fill(&g, Art.circle(flower.0, flower.1, 1.1), Art.color(0xFFB62E))
            }
        }
        reeds(&context, 328, 264, count: 7, seed: 4, height: 44)
        reeds(&context, 106, 262, count: 4, seed: 12, height: 30)

        // The tall tree, leaning out over the water toward the light.
        let hazy: [Blob] = [(136, 108, 30), (252, 116, 24), (186, 122, 22)]
        canopy(&context, hazy, seed: 3, palette: hazyGreens, density: 0.5)
        var limbs = Path()
        limbs.addPath(Art.svg("M222,136 C196,122 168,120 138,114"))
        limbs.addPath(Art.svg("M238,152 C252,130 258,110 262,88"))
        Art.stroke(&context, limbs, Art.color(0x6B4138), width: 7)
        let trunk = Art.svg(
            "M240,214 C238,186 228,156 206,124 L226,110 C250,142 264,176 268,210 C270,220 250,224 240,214Z"
        )
        let bark: [(Color, CGFloat)] = [
            (Art.color(0x9A6549), 0), (Art.color(0x6B4138), 0.45), (Art.color(0x3E2532), 1),
        ]
        Art.fillLinear(&context, trunk, bark, from: CGPoint(x: 214, y: 150), to: CGPoint(x: 268, y: 176))
        Art.clipped(&context, to: trunk) { g in
            // The warm edge of the one light, all the way down the trunk's upper-left side.
            let lit = Art.svg("M240,214 C238,186 228,156 206,124")
            Art.stroke(&g, lit, ArtStyle.warmLight.opacity(0.5), width: 7)
            ArtStyle.tooth(&g, in: CGRect(x: 204, y: 108, width: 68, height: 114), seed: 61, color: Art.color(0xFFD9B0), alpha: 0.12)
        }
        let feet = Art.svg("M242,212 C232,220 222,224 210,225 M266,212 C274,220 284,223 294,223")
        Art.stroke(&context, feet, Art.color(0x5B3B36), width: 5)
        let hanging = Art.svg("M150,112 q3,24 -1,46 M178,118 q-3,18 1,36")
        Art.stroke(&context, hanging, Art.color(0x5B3B36, 0.85), width: ArtStyle.detailLine)
        let crown: [Blob] = [
            (196, 72, 50), (146, 92, 36), (244, 60, 38), (180, 36, 34), (118, 76, 22), (268, 98, 24), (226, 108, 20),
        ]
        canopy(&context, crown, seed: 7)

        // Where the bank meets the water. Everything stays above the quiet bottom quarter.
        ripples(&context, 218, 281, 300, count: 2, color: .white, opacity: 0.45)
        lotusPad(&context, 50, 264, 17, flower: true)

        // Sink into the card.
        let sink: [(Color, CGFloat)] = [(cardBlue.opacity(0), 0), (cardBlue.opacity(0.9), 1)]
        Art.fillLinear(&context, Art.rect(0, h - 120, w, 120), sink, from: CGPoint(x: 0, y: h - 120), to: CGPoint(x: 0, y: h))
        ArtStyle.tooth(&context, in: CGRect(x: 0, y: 0, width: w, height: h), seed: 5, alpha: 0.05)
        ArtStyle.finish(&context, size)
    }

    /// One ripe mango hanging at (x, y), turned by `rotate` degrees.
    static func mango(_ context: inout GraphicsContext, _ x: CGFloat, _ y: CGFloat, scale: CGFloat, rotate: CGFloat) {
        Art.group(&context, x: x, y: y, rotate: deg(rotate), scale: scale) { g in
            let shape = Art.svg("M2,-32 C18,-33 28,-14 26,6 C24,24 11,34 -3,33 C-19,32 -28,15 -25,-5 C-22,-22 -12,-31 2,-32Z")
            let stops: [(Color, CGFloat)] = [
                (Art.color(0xFFF2A6), 0), (Art.color(0xFFCB3D), 0.42), (Art.color(0xFF9F2E), 0.82), (Art.color(0xF27A2A), 1),
            ]
            Art.fillRadial(&g, shape, stops, center: CGPoint(x: -9, y: -12), radius: 52)
            Art.clipped(&g, to: shape) { c in
                Art.fill(&c, Art.ellipse(18, 22, 20, 18), Art.color(0xFF5A3C, 0.28))
                Art.fill(&c, Art.ellipse(-24, 28, 16, 12), Art.color(0x9BC53D, 0.28))
                // The core shadow of the one light, low on the right.
                Art.fill(&c, Art.ellipse(24, 30, 18, 14), ArtStyle.coolShade.opacity(0.14))
            }
            let shine = CGAffineTransform(translationX: -11, y: -11).rotated(by: deg(24))
            Art.fill(&g, Art.ellipse(0, 0, 4.6, 11).applying(shine), Art.color(0xFFFFFF, 0.5))
            Art.fill(&g, Art.circle(-3, -25, 2), Art.color(0xFFFFFF, 0.6))
            Art.fill(&g, Art.circle(2, -33, 3.2), Art.color(0x5B3B36))
        }
    }

    /// see-ripe-fruit: one cluster of three golden mangoes hanging from a branch, close up
    /// and centred a little above the middle. The bottom of the picture sinks into the card
    /// colour #1F6B50.
    static func ripeFruitPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        let h = size.height
        let cardGreen = Art.color(0x1F6B50)
        let ground: [(Color, CGFloat)] = [
            (Art.color(0xF6FBD2), 0), (Art.color(0xC6ECA4), 0.34), (Art.color(0x62B67A), 0.7), (cardGreen, 1),
        ]
        Art.fillLinear(&context, Art.rect(0, 0, w, h), ground, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: h))
        // The light comes through the leaves from the upper left.
        Art.glow(&context, 110, 60, 250, Art.color(0xFFF7C2), alpha: 0.9)

        // Far plane: leaves and two more fruit, out of focus.
        Art.blurred(&context, radius: 14, opacity: 0.8) { g in
            let far: [(CGFloat, CGFloat, CGFloat, UInt32)] = [
                (40, 30, 70, 0x22966A), (150, 10, 50, 0x52BF72), (420, 150, 70, 0x22966A), (30, 250, 80, 0x16695A),
                (400, 320, 90, 0x16695A), (230, 330, 60, 0x22966A), (250, 20, 40, 0xB4E86B),
                (52, 186, 22, 0xFFB62E), (388, 196, 19, 0xFF9F2E),
            ]
            for blob in far {
                Art.fill(&g, Art.circle(blob.0, blob.1, blob.2), Art.color(blob.3, 0.55))
            }
        }
        // Flecks of light through the leaves.
        let flecks: [(CGFloat, CGFloat, CGFloat)] = [(330, 150, 14), (366, 236, 9), (64, 130, 12), (400, 60, 12)]
        for fleck in flecks {
            Art.glow(&context, fleck.0, fleck.1, fleck.2, Art.color(0xFFFDE0), alpha: 0.5)
        }

        let pal = leafGreens
        guard pal.count >= 5 else { return }

        // Leaves behind the branch.
        let backLeaves: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
            (90, 88, 124, 70), (150, 92, 112, 115), (230, 88, 122, 60), (300, 74, 112, 100), (360, 62, 112, 55),
            (30, 90, 104, 120), (410, 50, 92, 110), (130, 88, 100, -60), (210, 90, 92, -110), (290, 76, 100, -50),
            (380, 60, 92, -70), (60, 86, 92, -120),
        ]
        for (i, leaf) in backLeaves.enumerated() {
            let fill = i % 2 == 0 ? pal[1] : pal[2]
            bigLeaf(&context, leaf.0, leaf.1, length: leaf.2, angle: deg(leaf.3), fill: fill, rib: pal[3])
        }

        // The branch, lit along its top.
        let branch = Art.svg("M-20,96 C80,70 170,110 250,84 C320,62 380,70 452,40")
        Art.stroke(&context, branch, Art.color(0x4A2C30), width: 18)
        Art.stroke(&context, branch, Art.color(0x6B4138), width: 14)
        let branchLight = branch.applying(CGAffineTransform(translationX: 0, y: -4))
        Art.stroke(&context, branchLight, Art.color(0xC68A62, 0.75), width: 3)

        // The fruit, back to front: x, y, scale, turn, and where its stalk leaves the branch.
        let fruit: [(CGFloat, CGFloat, CGFloat, CGFloat, CGFloat, CGFloat)] = [
            (152, 194, 1.4, -10, 158, 94), (268, 184, 1.35, 8, 262, 82), (212, 236, 1.55, 3, 208, 96),
        ]
        for (i, item) in fruit.enumerated() {
            if i == fruit.count - 1 {
                // The front fruit throws a soft shade on the two behind it.
                ArtStyle.contactShadow(&context, 222, 222, 62, 44, alpha: 0.22)
            }
            let turn = deg(item.3)
            let s = item.2
            let c = cos(turn)
            let n = sin(turn)
            let offsetX: CGFloat = 2 * c + 33 * n
            let offsetY: CGFloat = 2 * n - 33 * c
            let topX = item.0 + offsetX * s
            let topY = item.1 + offsetY * s
            var stalk = Path()
            stalk.move(to: CGPoint(x: item.4, y: item.5))
            stalk.addQuadCurve(to: CGPoint(x: topX, y: topY), control: CGPoint(x: item.4 + 4, y: (item.5 + topY) / 2))
            Art.stroke(&context, stalk, Art.color(0x5B3B36), width: 3)
            mango(&context, item.0, item.1, scale: s, rotate: item.3)
        }

        // Sunlit leaves in front, along the branch only.
        let frontLeaves: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
            (14, 94, 92, 58), (222, 86, 70, 18), (346, 66, 86, 142), (424, 46, 72, 96), (104, 92, 60, -28),
        ]
        for (i, leaf) in frontLeaves.enumerated() {
            let fill = i % 2 == 0 ? pal[3] : pal[4]
            bigLeaf(&context, leaf.0, leaf.1, length: leaf.2, angle: deg(leaf.3), fill: fill, rib: pal[2])
        }
        Art.fill(&context, Art.spark(306, 150, 6), Art.color(0xFFFFFF, 0.7))
        Art.fill(&context, Art.spark(118, 246, 5), Art.color(0xFFFFFF, 0.6))

        // Sink into the card.
        let sink: [(Color, CGFloat)] = [(cardGreen.opacity(0), 0), (cardGreen.opacity(0.9), 1)]
        Art.fillLinear(&context, Art.rect(0, h - 110, w, 110), sink, from: CGPoint(x: 0, y: h - 110), to: CGPoint(x: 0, y: h))
        ArtStyle.tooth(&context, in: CGRect(x: 0, y: 0, width: w, height: h), seed: 9, alpha: 0.05)
        ArtStyle.finish(&context, size)
    }

    // MARK: Character card (432 × 400)

    /// char-monkey: the Monkey waving from a branch on a warm sunburst. Screen 07.
    static func monkeyPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        let h = size.height
        let warm: [(Color, CGFloat)] = [
            (Art.color(0xFFD35A), 0), (Art.color(0xFFAE45), 0.5), (Art.color(0xFF8A4D), 1),
        ]
        Art.fillLinear(&context, Art.rect(0, 0, w, h), warm, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: h))

        var rays = Path()
        for i in 0..<14 {
            let a = CGFloat(i) * 0.4488
            let b = a + 0.2
            rays.move(to: CGPoint(x: 216, y: 230))
            rays.addLine(to: CGPoint(x: 216 + cos(a) * 520, y: 230 + sin(a) * 520))
            rays.addLine(to: CGPoint(x: 216 + cos(b) * 520, y: 230 + sin(b) * 520))
            rays.closeSubpath()
        }
        Art.fill(&context, rays, Art.color(0xFFE27A, 0.25))
        let halo: [(Color, CGFloat)] = [(Art.color(0xFFF6C8, 0.95), 0), (Art.color(0xFFF6C8, 0), 1)]
        Art.fillRadial(&context, Art.circle(216, 224, 170), halo, center: CGPoint(x: 216, y: 224), radius: 170)
        ArtStyle.tooth(&context, in: CGRect(x: 0, y: 0, width: w, height: h), seed: 33, alpha: 0.05)

        let corners: [Blob] = [(30, 40, 60), (110, 10, 44), (410, 30, 62), (330, 6, 40), (-6, 130, 34), (440, 130, 30)]
        canopy(&context, corners, seed: 12)

        let branch = Art.svg("M-10,338 C100,326 300,330 442,318 L442,346 C300,352 100,352 -10,362Z")
        let bark: [(Color, CGFloat)] = [(Art.color(0x8E5B45), 0), (Art.color(0x5B3A36), 1)]
        Art.fillLinear(&context, branch, bark, from: CGPoint(x: -10, y: 0), to: CGPoint(x: 442, y: 0))
        let branchBounds = CGRect(x: -10, y: 318, width: 452, height: 44)
        ArtStyle.form(&context, branch, bounds: branchBounds, light: 0.2, shade: 0.24)
        Art.clipped(&context, to: branch) { g in
            // Shade along the underside, and tooth.
            let under: [(Color, CGFloat)] = [(ArtStyle.coolShade.opacity(0), 0), (ArtStyle.coolShade.opacity(0.28), 1)]
            Art.fillLinear(&g, Art.rect(-10, 336, 452, 26), under, from: CGPoint(x: 0, y: 336), to: CGPoint(x: 0, y: 362))
            ArtStyle.tooth(&g, in: branchBounds, seed: 61, color: Art.color(0xFFD9B0), alpha: 0.12)
        }
        Art.stroke(&context, Art.svg("M-10,338 C100,326 300,330 442,318"), Art.color(0xD9A070, 0.75), width: ArtStyle.contourLine, cap: .butt)
        ArtStyle.contactShadow(&context, 222, 338, 84, 10, alpha: 0.32)

        Art.group(&context, x: 220, y: 330, scale: 2.15) { g in
            monkey(&g, pose: .wave, lookX: 0, lookY: 0.5, mouth: .grin)
        }
        let front: [Blob] = [(70, 348, 26), (36, 330, 20), (392, 326, 24)]
        canopy(&context, front, seed: 18)
        ArtStyle.finish(&context, size)
    }

    // MARK: Faces (100 × 100)

    /// face-monkey: the Monkey's head on #FFE2A8.
    static func monkeyFace(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        let h = size.height
        Art.fill(&context, Art.rect(0, 0, w, h), Art.color(0xFFE2A8))
        let s = w / 84
        Art.group(&context, x: 42 * s, y: h / 2 + 2 * s, scale: s) { g in
            monkeyHead(&g)
        }
    }

    /// face-crocodile on #BDEFE0, and face-mother-crocodile (bigger, older, darker) on #FFE2A8.
    /// Both have the yellow eye of the scenes.
    static func crocFace(_ context: inout GraphicsContext, _ size: CGSize, mother: Bool) {
        let w = size.width
        let h = size.height
        Art.fill(&context, Art.rect(0, 0, w, h), mother ? Art.color(0xFFE2A8) : Art.color(0xBDEFE0))
        if mother {
            // Closer in, so her head fills more of the chip.
            let s = w / 68
            let skin = motherCrocSkin()
            Art.group(&context, x: w / 2 - 91 * s, y: h / 2 + 14 * s, scale: s) { g in
                croc(&g, skin: skin, lid: .sly, lookX: -0.6, lookY: 0.4, waterline: 60, waterOpacity: 0, elder: true)
            }
        } else {
            let s = w / 78
            let skin = youngCrocSkin()
            Art.group(&context, x: -52 * s, y: h / 2 + 19 * s, scale: s) { g in
                croc(&g, skin: skin, lid: .sleepy, waterline: 60, waterOpacity: 0)
            }
        }
    }

    // MARK: Cover (300 wide, 150…375 tall)

    /// cover: the Monkey riding the Crocodile across the river, the island behind. The riders
    /// sit around the vertical middle, so the wide crop and the tall crop both hold them.
    static func cover(_ context: inout GraphicsContext, _ size: CGSize) {
        // The design cover is 240 units wide; draw in those units.
        let u = size.width / 240
        let hd = size.height / u
        let lift = max(0, hd - 150) * 0.24
        let H = (hd * 0.5 + 14 + lift).rounded()
        let k = min(1, max(0.55, hd / 210))
        Art.group(&context, scale: u) { g in
            let sky: [(Color, CGFloat)] = [
                (Art.color(0x7FE3D3), 0), (Art.color(0xD9F7C8), 0.8), (Art.color(0xFFF0A0), 1),
            ]
            Art.fillLinear(&g, Art.rect(0, 0, 240, hd), sky, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: H))
            ArtStyle.horizonGlow(&g, width: 240, y: H, rise: 44 * k, color: ArtStyle.jataka.glowColor, alpha: 0.5)
            Art.fill(&g, Art.circle(176, H - 50 * k, 80 * k), Art.color(0xFFF3A8, 0.4))
            Art.fill(&g, Art.circle(176, H - 50 * k, 46 * k), Art.color(0xFFF9D6))
            // Far plane: two ranges, veiled by the air; then the darker near shore.
            Art.fill(&g, hills(width: 240, y: H - 12 * k, amp: 16 * k, seed: 4, bottom: H + 4), Art.color(0xA8DDCF))
            ArtStyle.atmosphere(&g, width: 240, top: H - 34 * k, bottom: H + 4, color: Art.color(0xF6FBD9), alpha: 0.3)
            Art.fill(&g, hills(width: 240, y: H - 4, amp: 14 * k, seed: 6, bottom: H + 4), Art.color(0x7CCAB2))
            Art.fill(&g, hills(width: 240, y: H + 1, amp: 4 * k, seed: 15, bottom: H + 4, step: 5), Art.color(0x3FA088))

            let water: [(Color, CGFloat)] = [(Art.color(0x4CC4B4), 0), (Art.color(0x0A6585), 1)]
            let depth: CGFloat = max(1, hd - H)
            Art.fillLinear(&g, Art.rect(0, H, 240, depth), water, from: CGPoint(x: 0, y: H), to: CGPoint(x: 0, y: hd))
            ArtStyle.tooth(&g, in: CGRect(x: 0, y: H + 4, width: 240, height: depth), seed: 77)
            island(&g, x: 136, y: H - 13 * k, scale: 0.42 * k, haze: 0.08)
            waterRipples(&g, x0: 0, x1: 240, y0: H + 6, y1: hd, count: 26, seed: 5)

            let crocX = 18 + (1 - k) * 70
            let crocY = H + 38 * k
            let skin = youngCrocSkin()
            Art.group(&g, x: crocX, y: crocY, scale: 0.62 * k) { c in
                croc(&c, skin: skin, lid: .sleepy, waterline: 12, water: Art.color(0x1596A0))
                ArtStyle.contactShadow(&c, 204, -19, 44, 6, alpha: 0.26)
                Art.group(&c, x: 206, y: -26, scale: 1.15) { m in
                    monkey(&m, pose: .ride, lookX: -1.5, lookY: 0, mouth: .grin)
                }
            }
            ripples(&g, crocX + 102 * k, crocY + 12 * k, 190 * k, count: 2)

            // Near plane: leaves of the home tree over the top corners.
            let leafA: Blob = (20 * k, 6 * k, 44 * k)
            let leafB: Blob = (80 * k, -8 * k, 34 * k)
            let leafC: Blob = (-6 * k, 60 * k, 26 * k)
            let leafD: Blob = (240 - 10 * k, 0, 30 * k)
            let leaves: [Blob] = [leafA, leafB, leafC, leafD]
            canopy(&g, leaves, seed: 4)
        }
        ArtStyle.finish(&context, size)
    }
}
