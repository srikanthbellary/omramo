import SwiftUI
import OmramoCore

// The smaller pictures of "The Monkey and the Crocodile": the two tap-to-see pictures, the
// Monkey's character-card portrait, the face chips and the cover.

extension JatakaArt {
    // MARK: Tap-to-see pictures (432 × 404)

    /// see-river-bank: a grassy bank beside a wide river, with a tall tree leaning over the
    /// water. The bottom of the picture sinks into the card colour #0A6585.
    static func riverBankPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        let h = size.height
        let H: CGFloat = 186
        let cardBlue = Art.color(0x0A6585)

        let sky: [(Color, CGFloat)] = [
            (Art.color(0xBDEFE9), 0), (Art.color(0xDDF8EC), 0.5), (Art.color(0xF6FBD9), 0.86), (Art.color(0xFFF2B5), 1),
        ]
        Art.fillLinear(&context, Art.rect(0, 0, w, h), sky, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: H))
        let glowStops: [(Color, CGFloat)] = [
            (Art.color(0xFFF7C2, 0.95), 0), (Art.color(0xFFEE9E, 0.5), 0.45), (Art.color(0xFFEE9E, 0), 1),
        ]
        Art.fillRadial(&context, Art.circle(96, H - 30, 150), glowStops, center: CGPoint(x: 96, y: H - 30), radius: 150)
        ArtStyle.horizonGlow(&context, width: w, y: H, rise: 70, color: ArtStyle.jataka.glowColor, alpha: 0.5)
        Art.fill(&context, Art.circle(96, H - 34, 30), Art.color(0xFFF9D6))
        cloud(&context, 30, 70, scale: 0.9, color: Art.color(0xFFFFFF, 0.55))

        // The far shore: the river is wide.
        Art.fill(&context, hills(width: w, y: H - 18, amp: 20, seed: 4, bottom: H + 6), Art.color(0xA8DDCF))
        Art.fill(&context, hills(width: w, y: H - 6, amp: 12, seed: 9, bottom: H + 6), Art.color(0x7CCAB2))
        let palmXs: [CGFloat] = [24, 60, 150, 196]
        for (i, x) in palmXs.enumerated() {
            let lean: CGFloat = i % 2 == 1 ? 4 : -4
            palm(&context, x, H - 1, 0.42 + CGFloat(i % 3) * 0.08, lean: lean, color: Art.color(0x3FA088))
        }
        Art.fill(&context, hills(width: w, y: H + 2, amp: 5, seed: 15, bottom: H + 6, step: 5), Art.color(0x3FA088))

        // The river.
        let water: [(Color, CGFloat)] = [
            (Art.color(0xA9E9D4), 0), (Art.color(0x4CC4B4), 0.12), (Art.color(0x1596A0), 0.46), (cardBlue, 0.78), (cardBlue, 1),
        ]
        Art.fillLinear(&context, Art.rect(0, H, w, h - H), water, from: CGPoint(x: 0, y: H), to: CGPoint(x: 0, y: h))
        Art.fill(&context, Art.rect(0, H, w, 7), Art.color(0x2B8C7E, 0.35))
        var random = ArtRandom(8)
        for _ in 0..<30 {
            let dy = 5 + power(rnd(&random), 1.3) * 96
            let spread = 12 + dy * 0.5
            let x = 96 + (rnd(&random) - 0.5) * spread * 2
            let ww = 5 + rnd(&random) * 18 * (0.5 + dy / 120)
            let alpha = 0.35 + random.next() * 0.5
            Art.fill(&context, Art.rect(x - ww / 2, H + dy, ww, 1.3 + dy / 80, radius: 1), Art.color(0xFFF6C8, alpha))
        }
        waterRipples(&context, x0: 0, x1: w, y0: H + 8, y1: 300, count: 44, seed: 31)

        // The grassy bank, with its reflection under it.
        Art.blurred(&context, radius: 5, opacity: 0.4) { g in
            Art.fill(&g, Art.svg("M226,270 C260,300 340,312 432,316 L432,346 C340,340 250,322 226,270Z"), Art.color(0x0B4B55))
        }
        let turf = Art.svg(
            "M432,146 C392,150 350,168 318,192 C286,216 262,228 232,258 C224,268 240,280 274,286 C330,294 380,292 432,300Z"
        )
        let turfStops: [(Color, CGFloat)] = [
            (Art.color(0x8FD662), 0), (Art.color(0x4BAA5A), 0.35), (Art.color(0x1F6B50), 1),
        ]
        Art.fillLinear(&context, turf, turfStops, from: CGPoint(x: 0, y: 146), to: CGPoint(x: 0, y: 300))
        let earth = Art.svg(
            "M232,258 C224,268 240,280 274,286 C330,294 380,292 432,300 L432,314 C380,308 326,308 270,298 C236,292 214,274 232,258Z"
        )
        Art.fill(&context, earth, Art.color(0x7A5638))
        Art.clipped(&context, to: turf) { g in
            // Sun on the top of the slope, and blades of grass.
            Art.fill(&g, Art.ellipse(360, 150, 90, 22), Art.color(0xD6F08C, 0.35))
            var blades = Path()
            var grass = ArtRandom(41)
            for _ in 0..<70 {
                let t = rnd(&grass)
                let x = 244 + t * 190
                let top = 262 - t * 116
                let room: CGFloat = (278 - top) * 0.9
                let y = top + 8 + rnd(&grass) * room
                let lean = (rnd(&grass) - 0.5) * 6
                blades.move(to: CGPoint(x: x, y: y))
                blades.addLine(to: CGPoint(x: x + lean, y: y - 7))
                blades.move(to: CGPoint(x: x + 3, y: y))
                blades.addLine(to: CGPoint(x: x + 4 + lean, y: y - 5))
            }
            Art.stroke(&g, blades, Art.color(0xB4E86B, 0.55), width: 1.2)
            // A few small flowers.
            let flowers: [(CGFloat, CGFloat)] = [(300, 236), (338, 214), (372, 246), (404, 206), (350, 266), (410, 262)]
            for flower in flowers {
                Art.fill(&g, Art.circle(flower.0, flower.1, 2.6), Art.color(0xFFF3C0))
                Art.fill(&g, Art.circle(flower.0, flower.1, 1.1), Art.color(0xFFB62E))
            }
        }
        reeds(&context, 252, 272, count: 8, seed: 4, height: 50)
        reeds(&context, 300, 290, count: 5, seed: 12, height: 38)

        // The tall tree, leaning out over the water.
        let trunk = Art.svg(
            "M352,236 C346,188 320,130 262,84 L288,64 C340,114 380,172 396,232 C402,246 382,250 370,244 C364,240 356,240 352,236Z"
        )
        let bark: [(Color, CGFloat)] = [
            (Art.color(0x9A6549), 0), (Art.color(0x6B4138), 0.45), (Art.color(0x3E2532), 1),
        ]
        Art.fillLinear(&context, trunk, bark, from: CGPoint(x: 280, y: 120), to: CGPoint(x: 372, y: 170))
        Art.stroke(&context, Art.svg("M344,206 C336,166 314,124 276,90"), Art.color(0xC68A62, 0.55), width: ArtStyle.contourLine)
        var limbs = Path()
        limbs.addPath(Art.svg("M300,112 C262,104 226,104 176,96"))
        limbs.addPath(Art.svg("M322,134 C340,104 350,84 356,56"))
        Art.stroke(&context, limbs, Art.color(0x6B4138), width: 9)
        Art.stroke(&context, Art.svg("M352,238 C340,250 326,254 310,256 M388,240 C396,250 408,254 420,254"), Art.color(0x5B3B36), width: 6)
        let hanging = Art.svg("M196,96 q4,34 -2,70 M232,100 q-4,26 2,52 M158,92 q3,22 -1,44")
        Art.stroke(&context, hanging, Art.color(0x5B3B36, 0.85), width: ArtStyle.detailLine)
        let crown: [Blob] = [
            (240, 58, 58), (160, 80, 44), (304, 30, 50), (108, 108, 30), (200, 22, 40), (356, 56, 38), (136, 46, 30),
            (400, 22, 34), (84, 78, 22),
        ]
        canopy(&context, crown, seed: 7)

        // Kept above the bottom quarter, which the card fades into its own colour.
        lotusPad(&context, 74, 272, 24, flower: true)
        lotusPad(&context, 136, 288, 17)
        dragonfly(&context, 150, 226, scale: 0.9)
        ripples(&context, 250, 292, 90, count: 2, color: .white, opacity: 0.45)

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
            }
            let shine = CGAffineTransform(translationX: -11, y: -11).rotated(by: deg(24))
            Art.fill(&g, Art.ellipse(0, 0, 4.6, 11).applying(shine), Art.color(0xFFFFFF, 0.5))
            Art.fill(&g, Art.circle(-3, -25, 2), Art.color(0xFFFFFF, 0.6))
            Art.fill(&g, Art.circle(2, -33, 3.2), Art.color(0x5B3B36))
        }
    }

    /// see-ripe-fruit: a branch heavy with golden mangoes, close up. The bottom of the
    /// picture sinks into the card colour #1F6B50.
    static func ripeFruitPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        let h = size.height
        let cardGreen = Art.color(0x1F6B50)
        let ground: [(Color, CGFloat)] = [
            (Art.color(0xF6FBD2), 0), (Art.color(0xC6ECA4), 0.34), (Art.color(0x62B67A), 0.7), (cardGreen, 1),
        ]
        Art.fillLinear(&context, Art.rect(0, 0, w, h), ground, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: h))
        Art.glow(&context, 330, 66, 240, Art.color(0xFFF7C2), alpha: 0.9)

        // Far leaves, out of focus.
        Art.blurred(&context, radius: 14, opacity: 0.8) { g in
            let far: [(CGFloat, CGFloat, CGFloat, UInt32)] = [
                (40, 30, 70, 0x22966A), (150, 10, 50, 0x52BF72), (420, 150, 70, 0x22966A), (30, 250, 80, 0x16695A),
                (400, 320, 90, 0x16695A), (230, 330, 60, 0x22966A), (250, 20, 40, 0xB4E86B),
            ]
            for blob in far {
                Art.fill(&g, Art.circle(blob.0, blob.1, blob.2), Art.color(blob.3, 0.55))
            }
        }
        // Flecks of light through the leaves.
        let flecks: [(CGFloat, CGFloat, CGFloat)] = [(300, 150, 16), (366, 220, 10), (60, 210, 12), (212, 300, 9), (400, 60, 14)]
        for fleck in flecks {
            Art.glow(&context, fleck.0, fleck.1, fleck.2, Art.color(0xFFFDE0), alpha: 0.55)
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

        // The branch.
        let branch = Art.svg("M-20,96 C80,70 170,110 250,84 C320,62 380,70 452,40")
        Art.stroke(&context, branch, Art.color(0x4A2C30), width: 18)
        Art.stroke(&context, branch, Art.color(0x6B4138), width: 14)
        let branchLight = branch.applying(CGAffineTransform(translationX: 0, y: -4))
        Art.stroke(&context, branchLight, Art.color(0xB37A58, 0.7), width: 3)

        // The fruit: x, y, scale, turn, and where its stalk leaves the branch.
        let fruit: [(CGFloat, CGFloat, CGFloat, CGFloat, CGFloat, CGFloat)] = [
            (52, 168, 1.1, -14, 58, 90), (390, 132, 1.0, 8, 386, 60), (328, 178, 1.25, 10, 322, 72),
            (112, 214, 1.5, -8, 118, 90), (256, 206, 1.45, -4, 252, 86), (182, 250, 1.7, 6, 176, 96),
        ]
        for item in fruit {
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

        // Sunlit leaves in front.
        let frontLeaves: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
            (14, 94, 92, 58), (222, 86, 84, 18), (346, 66, 86, 142), (424, 46, 72, 96), (148, 94, 70, -28),
        ]
        for (i, leaf) in frontLeaves.enumerated() {
            let fill = i % 2 == 0 ? pal[3] : pal[4]
            bigLeaf(&context, leaf.0, leaf.1, length: leaf.2, angle: deg(leaf.3), fill: fill, rib: pal[2])
        }
        Art.fill(&context, Art.spark(292, 250, 7), Art.color(0xFFFFFF, 0.7))
        Art.fill(&context, Art.spark(88, 262, 5), Art.color(0xFFFFFF, 0.6))

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

        let corners: [Blob] = [(30, 40, 60), (110, 10, 44), (410, 30, 62), (330, 6, 40), (-6, 130, 34), (440, 130, 30)]
        canopy(&context, corners, seed: 12)

        let branch = Art.svg("M-10,338 C100,326 300,330 442,318 L442,346 C300,352 100,352 -10,362Z")
        let bark: [(Color, CGFloat)] = [(Art.color(0x8E5B45), 0), (Art.color(0x5B3A36), 1)]
        Art.fillLinear(&context, branch, bark, from: CGPoint(x: -10, y: 0), to: CGPoint(x: 442, y: 0))
        Art.stroke(&context, Art.svg("M-10,338 C100,326 300,330 442,318"), Art.color(0xC68A62, 0.7), width: ArtStyle.contourLine, cap: .butt)
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
            Art.fill(&g, hills(width: 240, y: H - 4, amp: 14 * k, seed: 6, bottom: H + 4), Art.color(0x7CCAB2))

            let water: [(Color, CGFloat)] = [(Art.color(0x4CC4B4), 0), (Art.color(0x0A6585), 1)]
            Art.fillLinear(&g, Art.rect(0, H, 240, max(1, hd - H)), water, from: CGPoint(x: 0, y: H), to: CGPoint(x: 0, y: hd))
            island(&g, x: 136, y: H - 13 * k, scale: 0.42 * k)
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

            let leaves: [Blob] = [(20 * k, 6 * k, 44 * k), (80 * k, -8 * k, 34 * k), (-6 * k, 60 * k, 26 * k), (240 - 10 * k, 0, 30 * k)]
            canopy(&g, leaves, seed: 4)
        }
        ArtStyle.finish(&context, size)
    }
}
