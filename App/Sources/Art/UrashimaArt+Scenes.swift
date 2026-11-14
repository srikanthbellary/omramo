import SwiftUI
import OmramoCore

// The five reading scenes of "The Story of Urashima Taro".
//
// Every scene is drawn in the unfolded space: 892 units wide, `h` units tall, anchored to the
// bottom edge. Text lies over both panes, so everything above the low waves on the leading pane
// (bottom 110 units) and above the picture on the trailing pane (bottom 300 units) stays pale.
// The folded picture band reuses the same painters (see `foldedScene`).

extension UrashimaArt {
    // MARK: - scene-sea (design screen 05)

    static func sceneSea(_ context: inout GraphicsContext, h: CGFloat, folded: Bool) {
        let w: CGFloat = 892
        let sea = Sea(low: h - 72, lift: 196)
        fillBackground(&context, w, h, daySky)
        sun(&context, 800, h - 268, 50)

        // Far headland with pines.
        let land = headlandPath(sea)
        let farTint = Art.color(0x7FAAB5)
        Art.layer(&context, opacity: 0.7) { g in
            Art.fill(&g, land, Art.color(0x9DC3CF))
            pine(&g, 520, sea.top(0, 520) - 14, 0.7, farTint)
            pine(&g, 548, sea.top(0, 548) - 20, 0.9, farTint)
            pine(&g, 590, sea.top(0, 590) - 14, 0.6, farTint)
        }
        let gullTint = Art.color(0x5A7C96)
        gull(&context, 500, h - 280, 0.8, gullTint)
        gull(&context, 522, h - 290, 0.6, gullTint)

        let seaShape = seaBand(&context, sea, 0, fills: dayFills, bottom: h)
        seaBand(&context, sea, 1, fills: dayFills, bottom: h)
        farSail(&context, 852, sea.top(1, 852) - 3)
        seaBand(&context, sea, 2, fills: dayFills, bottom: h)
        seaBand(&context, sea, 3, fills: dayFills, bottom: h)

        let boatX: CGFloat = 716
        let boatY = sea.top(3, boatX) + 4
        Art.group(&context, x: boatX, y: boatY, rotate: rad(-5)) { g in
            boatWithUrashima(&g)
        }
        seaBand(&context, sea, 4, fills: dayFills, bottom: h)

        // The tortoise in the waves beside the boat, looking up.
        let tortoiseY = sea.top(4, 578) + 6
        Art.group(&context, x: 578, y: tortoiseY, rotate: rad(4), scale: 1.05) { g in
            tortoise(&g, lookX: 1, lookY: -1)
        }
        let rippleY = sea.top(4, 520) + 12
        var ripple = Path()
        ripple.move(to: pt(520, rippleY))
        ripple.addQuadCurve(to: pt(560, rippleY), control: pt(540, rippleY - 7))
        ripple.addQuadCurve(to: pt(600, rippleY), control: pt(580, rippleY + 7))
        ripple.addQuadCurve(to: pt(640, rippleY), control: pt(620, rippleY - 7))
        Art.stroke(&context, ripple, Art.color(0xFFFFFF, 0.8), width: 2)

        seaBand(&context, sea, 5, fills: dayFills, bottom: h)
        seaBand(&context, sea, 6, fills: dayFills, bottom: h)

        if !folded {
            leadingMist(&context, w, h, Art.color(0xF3F9FB))
        }
        Art.clipped(&context, to: seaShape) { g in
            Art.stipple(&g, in: CGRect(x: 0, y: h - 340, width: w, height: 340), count: 380, seed: 11, color: white, alpha: 0.14, size: 0.4...1.1)
        }
    }

    /// The design's `mist`: a pale veil over the leading pane that fades out across the hinge,
    /// so the low waves under the text stay soft.
    static func leadingMist(_ context: inout GraphicsContext, _ w: CGFloat, _ h: CGFloat, _ tint: Color) {
        let stops: [(Color, CGFloat)] = [
            (tint.opacity(0.52), 0), (tint.opacity(0.33), 0.3), (tint.opacity(0), 0.62), (tint.opacity(0), 1),
        ]
        Art.fillLinear(&context, Art.rect(0, 0, w, h), stops, from: pt(0, 0), to: pt(w, 0))
    }

    /// The far sail of design `seaScene`. (x, y) is the stern at the waterline.
    static func farSail(_ context: inout GraphicsContext, _ x: CGFloat, _ y: CGFloat) {
        var hull = Path()
        hull.move(to: pt(x, y))
        hull.addLine(to: pt(x - 20, y))
        hull.addQuadCurve(to: pt(x, y + 5), control: pt(x - 12, y + 7))
        hull.closeSubpath()
        Art.fill(&context, hull, Art.color(0x6A7C92, 0.85))
        let sail = Art.polygon([pt(x - 10, y), pt(x - 10, y - 17), pt(x, y - 4)])
        Art.fill(&context, sail, Art.color(0xFFFFFF, 0.85))
    }

    // MARK: - scene-shore and scene-return

    /// The beach. `later: false` is the evening Urashima frees the tortoise; `later: true` is the
    /// same shore three hundred years on: bare pines, strange roofs, a grey-lavender haze.
    static func sceneBeach(_ context: inout GraphicsContext, h: CGFloat, folded: Bool, later: Bool) {
        let w: CGFloat = 892
        let sea = Sea(low: h - 72, lift: 120)
        let fills = later ? duskFills : dayFills
        fillBackground(&context, w, h, later ? duskSky : eveningSky)

        if later {
            Art.glow(&context, 730, h - 214, 84, white, alpha: 0.75)
            Art.fill(&context, Art.circle(730, h - 214, 22), Art.color(0xFBF7F4, 0.9))
        } else {
            sun(&context, 730, h - 198, 34)
        }

        // The far shore with the village roofs.
        let land = headlandPath(sea)
        let landTint = later ? Art.color(0xB7B6CE) : Art.color(0x9DC3CF)
        let wallTint = later ? Art.color(0xD3D1E3) : Art.color(0xC9DEE3)
        let roofTint = later ? Art.color(0x8E8CB0) : Art.color(0x6F9AA6)
        let y505 = sea.top(0, 505)
        let y532 = sea.top(0, 532)
        let y566 = sea.top(0, 566)
        let y598 = sea.top(0, 598)
        Art.layer(&context, opacity: 0.75) { g in
            Art.fill(&g, land, landTint)
            if later {
                tinyHouse(&g, 524, y532 - 16, 1.25, wall: wallTint, roof: roofTint, tiers: 2)
                tinyHouse(&g, 566, y566 - 17, 0.95, wall: wallTint, roof: roofTint)
                tinyHouse(&g, 600, y598 - 9, 1.35, wall: wallTint, roof: roofTint, tiers: 2)
                pine(&g, 548, y532 - 16, 0.7, roofTint, clumps: 2)
            } else {
                pine(&g, 520, y505 - 13, 0.8, roofTint)
                pine(&g, 584, y566 - 15, 0.7, roofTint)
                tinyHouse(&g, 505, y505 - 12, 0.9, wall: wallTint, roof: roofTint)
                tinyHouse(&g, 534, y532 - 17, 1.1, wall: wallTint, roof: roofTint)
                tinyHouse(&g, 564, y566 - 17, 0.85, wall: wallTint, roof: roofTint)
                tinyHouse(&g, 598, y598 - 10, 1.0, wall: wallTint, roof: roofTint)
            }
        }
        let gullTint = later ? Art.color(0x8483A2) : Art.color(0x5A7C96)
        gull(&context, 640, h - 262, 0.7, gullTint)
        if !later {
            gull(&context, 662, h - 272, 0.55, gullTint)
        }

        // Gentle wave bands.
        let seaShape = seaBand(&context, sea, 0, fills: fills, bottom: h)
        for index in 1...6 {
            seaBand(&context, sea, index, fills: fills, bottom: h)
        }
        if !folded {
            leadingMist(&context, w, h, later ? Art.color(0xF1EEF3) : Art.color(0xF6F3EF))
        }
        Art.clipped(&context, to: seaShape) { g in
            Art.stipple(&g, in: CGRect(x: 0, y: h - 260, width: w, height: 260), count: 260, seed: 17, color: white, alpha: 0.13, size: 0.4...1.1)
        }

        // Sand, with a wet edge and a foam line where the water meets it.
        var sand = Path()
        sand.move(to: pt(500, h + 4))
        sand.addCurve(to: pt(660, h - 128), control1: pt(540, h - 50), control2: pt(590, h - 104))
        sand.addCurve(to: pt(896, h - 164), control1: pt(740, h - 152), control2: pt(820, h - 150))
        sand.addLine(to: pt(896, h + 4))
        sand.closeSubpath()
        let wet = sand.applying(CGAffineTransform(translationX: -16, y: 3))
        Art.fill(&context, wet, later ? Art.color(0xC9C4D4) : Art.color(0xE0D0B2))
        var edge = Path()
        edge.move(to: pt(480, h + 6))
        edge.addCurve(to: pt(640, h - 124), control1: pt(520, h - 46), control2: pt(570, h - 100))
        Art.stroke(&context, edge, Art.color(0xFFFFFF, 0.85), width: 3)
        let sandStops: [(Color, CGFloat)] = later
            ? [(Art.color(0xEAE5E8), 0), (Art.color(0xD6CDD5), 1)]
            : [(Art.color(0xF7EDD9), 0), (Art.color(0xEAD7B6), 1)]
        Art.fillLinear(&context, sand, sandStops, from: pt(0, h - 170), to: pt(0, h))
        let grainTint = later ? Art.color(0x6E6480) : Art.color(0x9A7A4A)
        Art.clipped(&context, to: sand) { g in
            Art.stipple(&g, in: CGRect(x: 500, y: h - 170, width: 392, height: 170), count: 170, seed: 5, color: grainTint, alpha: 0.12, size: 0.4...1.0)
        }

        // Pines on the ridge.
        if later {
            let bare = Art.color(0x8A8AA6)
            let bark = Art.color(0x746A7E)
            pine(&context, 824, h - 150, 2.6, bare, trunk: bark, lean: -0.38, clumps: 2)
            pine(&context, 872, h - 158, 2.0, bare, trunk: bark, lean: -0.34, clumps: 1)
            // A stump where the third pine stood.
            Art.fill(&context, Art.rect(766, h - 156, 7, 10, radius: 2), bark)
        } else {
            let bark = Art.color(0x7A5A44)
            pine(&context, 772, h - 146, 1.3, Art.color(0x5E9A8A), trunk: bark, lean: -0.2)
            pine(&context, 872, h - 158, 2.0, Art.color(0x3F7F74), trunk: bark, lean: -0.3)
            pine(&context, 824, h - 150, 2.6, Art.color(0x4E8C7E), trunk: bark, lean: -0.28)
            // His boat, drawn up on the sand.
            Art.group(&context, x: 786, y: h - 112, rotate: rad(5), scale: 0.5) { g in
                boat(&g)
            }
        }

        if later {
            // A few fallen leaves on the empty sand.
            let leaves: [(CGFloat, CGFloat)] = [(700, 96), (752, 70), (716, 44), (792, 120), (668, 60)]
            var leafPath = Path()
            for (lx, up) in leaves {
                leafPath.addEllipse(in: CGRect(x: lx - 3, y: h - up - 1.4, width: 6, height: 2.8))
            }
            Art.fill(&context, leafPath, Art.color(0xB98A7C, 0.6))

            // Urashima alone, the box in his hands, the first violet mist curling from it.
            Art.fill(&context, Art.ellipse(640, h - 77, 22, 4), Art.color(0x4A4266, 0.16))
            Art.group(&context, x: 640, y: h - 78) { g in
                urashima(&g, rod: .absent, holdsBox: true)
            }
            let curl = Art.svg("M4,-2 C-8,-14 14,-24 2,-38 C-6,-48 8,-58 3,-72")
            let mist = curl.applying(CGAffineTransform(translationX: 619, y: h - 146))
            Art.blurred(&context, radius: 3, opacity: 0.55) { g in
                Art.stroke(&g, mist, Art.color(0x9B7BD8), width: 5)
            }
            Art.stroke(&context, mist, Art.color(0xB79CFF, 0.75), width: 1.2)
        } else {
            // The tortoise going back into the water; Urashima kneeling to let it go.
            Art.group(&context, x: 566, y: h - 74, rotate: rad(-4), scale: 0.8) { g in
                tortoise(&g, lookX: 0.5, lookY: 0)
            }
            var ripple = Path()
            ripple.move(to: pt(506, h - 62))
            ripple.addQuadCurve(to: pt(530, h - 62), control: pt(518, h - 67))
            ripple.addQuadCurve(to: pt(554, h - 62), control: pt(542, h - 57))
            Art.stroke(&context, ripple, Art.color(0xFFFFFF, 0.8), width: 1.8)
            Art.fill(&context, Art.ellipse(634, h - 79, 24, 4), Art.color(0x7A5A34, 0.16))
            Art.group(&context, x: 628, y: h - 80) { g in
                urashima(&g, rod: .absent, pose: .kneeling)
            }
        }
    }

    // MARK: - scene-deep

    /// Going down: Urashima on the tortoise's back in pale aqua water.
    static func sceneDeep(_ context: inout GraphicsContext, h: CGFloat, folded: Bool) {
        let w: CGFloat = 892
        let water: [(Color, CGFloat)] = [
            (Art.color(0xE6F6F4), 0), (Art.color(0xDDF3F0), 0.45), (Art.color(0xCDEDEA), 0.75), (Art.color(0xB9E4E0), 1),
        ]
        fillBackground(&context, w, h, water)
        lightShafts(&context, h: h, strength: 1)

        // The first far roofs of the palace.
        Art.glow(&context, 812, h - 170, 170, Art.color(0xFFF6DC), alpha: 0.55)
        Art.layer(&context, opacity: 0.85) { g in
            palaceSilhouette(&g, 812, h - 88, 1, Art.color(0xA3D6D1))
        }

        // Sea floor.
        var back = Path()
        back.move(to: pt(0, h - 58))
        back.addCurve(to: pt(460, h - 66), control1: pt(150, h - 80), control2: pt(300, h - 50))
        back.addCurve(to: pt(892, h - 92), control1: pt(600, h - 82), control2: pt(760, h - 110))
        back.addLine(to: pt(892, h))
        back.addLine(to: pt(0, h))
        back.closeSubpath()
        Art.fill(&context, back, Art.color(0xA9DDD6))
        var front = Path()
        front.move(to: pt(0, h - 30))
        front.addCurve(to: pt(560, h - 38), control1: pt(200, h - 48), control2: pt(380, h - 22))
        front.addCurve(to: pt(892, h - 44), control1: pt(700, h - 52), control2: pt(800, h - 30))
        front.addLine(to: pt(892, h))
        front.addLine(to: pt(0, h))
        front.closeSubpath()
        Art.fill(&context, front, deepFloor)

        let kelpDark = Art.color(0x4FAE98)
        let kelpLight = Art.color(0x74C8B2)
        kelp(&context, 40, h, 88, seed: 3, dark: kelpDark, light: kelpLight)
        kelp(&context, 384, h, 98, seed: 9, dark: kelpDark, light: kelpLight)
        kelp(&context, 478, h, 190, seed: 5, dark: kelpDark, light: kelpLight)
        kelp(&context, 524, h, 118, seed: 12, dark: kelpDark, light: kelpLight)
        kelp(&context, 874, h, 150, seed: 7, dark: kelpDark, light: kelpLight)
        coral(&context, 120, h - 18, 0.9, Art.color(0xF4A9A0), seed: 4)
        coral(&context, 330, h - 14, 0.8, Art.color(0xFFFFFF), seed: 10)
        coral(&context, 604, h - 22, 1.0, Art.color(0xF7BDB4), seed: 6)

        // Small fish.
        let shoal: [(CGFloat, CGFloat, CGFloat)] = [
            (716, 262, 0.7), (742, 250, 0.6), (698, 244, 0.55), (760, 268, 0.6), (730, 232, 0.5),
        ]
        for (fx, up, fs) in shoal {
            fish(&context, fx, h - up, fs, Art.color(0x7FB5C9), flip: 1, eye: white)
        }
        fish(&context, 520, h - 118, 0.8, Art.color(0xF0907F), flip: -1, eye: white)
        fish(&context, 552, h - 98, 0.6, Art.color(0xF5AFA2), flip: -1, eye: white)

        // The rider.
        Art.group(&context, x: 600, y: h - 150, rotate: rad(8), scale: 0.9) { g in
            rider(&g, seated: true)
        }
        bubbles(&context, count: 9, seed: 5, x: 486, y: h - 262, w: 70, h: 96, fill: white, ring: white, strength: 2.4)
        bubbles(&context, count: 16, seed: 21, x: 0, y: h - 300, w: w, h: 300, fill: white, ring: white, strength: 1.8)
    }

    /// Soft slanting shafts of light from the surface.
    static func lightShafts(_ context: inout GraphicsContext, h: CGFloat, strength: Double) {
        let shafts: [(CGFloat, CGFloat, Double)] = [
            (120, 70, 0.22), (290, 46, 0.16), (560, 90, 0.24), (740, 56, 0.18), (860, 40, 0.14),
        ]
        let drift = h * 0.21
        for (x, width, alpha) in shafts {
            let footRight: CGFloat = x + width * 1.6 - drift
            let footLeft: CGFloat = x - width * 0.6 - drift
            let corners: [CGPoint] = [pt(x, -10), pt(x + width, -10), pt(footRight, h), pt(footLeft, h)]
            let shaft = Art.polygon(corners)
            Art.fill(&context, shaft, Art.color(0xFFFFFF, alpha * strength))
        }
    }

    /// The far palace as one pale shape: three tiers, two wings and a spire. (x, y) is the
    /// middle of its base.
    static func palaceSilhouette(_ context: inout GraphicsContext, _ x: CGFloat, _ y: CGFloat, _ s: CGFloat, _ color: Color) {
        Art.group(&context, x: x, y: y, scale: s) { g in
            let tiers: [(CGFloat, CGFloat, CGFloat)] = [(56, 28, 18), (36, 22, 16), (20, 16, 14)]
            var level: CGFloat = 0
            for (half, body, roofHeight) in tiers {
                let top = level - body
                Art.fill(&g, Art.rect(-half, top, half * 2, body + 2), color)
                let cap = roofShape(half * 1.36, roofHeight).applying(CGAffineTransform(translationX: 0, y: top))
                Art.fill(&g, cap, color)
                level = top - roofHeight
            }
            let sides: [CGFloat] = [-1, 1]
            for side in sides {
                let cx = side * 94
                Art.fill(&g, Art.rect(cx - 22, -18, 44, 20), color)
                let cap = roofShape(31, 12).applying(CGAffineTransform(translationX: cx, y: -18))
                Art.fill(&g, cap, color)
            }
            Art.fill(&g, Art.rect(-1.2, level - 16, 2.4, 18), color)
            Art.fill(&g, Art.circle(0, level - 17, 2.6), color)
            // The sea floor the palace stands on.
            Art.fill(&g, Art.rect(-140, 0, 280, 8), color)
        }
    }

    // MARK: - scene-palace

    /// Rin Gin's gardens: pearl light, a red-and-white hall with jade roofs, coral trees, the four
    /// seasons at once, and Princess Otohime greeting Urashima.
    static func scenePalace(_ context: inout GraphicsContext, h: CGFloat, folded: Bool) {
        let w: CGFloat = 892
        let light: [(Color, CGFloat)] = [
            (Art.color(0xEEF7F4), 0), (Art.color(0xE6F6F4), 0.4), (Art.color(0xD9F1EC), 0.75), (Art.color(0xCDEDEA), 1),
        ]
        fillBackground(&context, w, h, light)
        lightShafts(&context, h: h, strength: 0.7)
        Art.glow(&context, 560, h - 170, 190, Art.color(0xFFF6DC), alpha: 0.7)

        // Garden floor.
        var floor = Path()
        floor.move(to: pt(0, h - 40))
        floor.addCurve(to: pt(460, h - 80), control1: pt(150, h - 56), control2: pt(320, h - 44))
        floor.addCurve(to: pt(892, h - 124), control1: pt(560, h - 118), control2: pt(700, h - 132))
        floor.addLine(to: pt(892, h))
        floor.addLine(to: pt(0, h))
        floor.closeSubpath()
        Art.fillLinear(&context, floor, [(Art.color(0xE6F2E8), 0), (palaceFloor, 1)], from: pt(0, h - 132), to: pt(0, h - 24))

        // The hall on its terrace.
        Art.fill(&context, Art.rect(496, h - 110, 128, 30, radius: 3), Art.color(0xF4F6F1))
        Art.fill(&context, Art.rect(496, h - 110, 128, 3), gold.opacity(0.8))
        hall(&context, 560, h - 108, 50, 34, 20, windows: 4, style: HallStyle.pearl)
        hall(&context, 560, h - 162, 30, 22, 16, windows: 2, style: HallStyle.pearl)
        Art.stroke(&context, Art.line(560, h - 200, 560, h - 216), gold, width: 2.2)
        Art.fill(&context, Art.circle(560, h - 218, 3.6), Art.color(0xFFE9A8))

        // Coral trees along the floor.
        coral(&context, 70, h - 26, 1.2, Art.color(0xF6A79C), seed: 4)
        coral(&context, 170, h - 18, 0.8, Art.color(0xFBD3CB), seed: 8)
        coral(&context, 392, h - 28, 1.4, Art.color(0xF28E86), seed: 6)
        coral(&context, 548, h - 30, 0.9, Art.color(0xF6A79C), seed: 14)
        coral(&context, 596, h - 22, 0.7, Art.color(0xFFFFFF), seed: 10)

        // The four seasons at once, left to right.
        let bark = Art.color(0x7A5A4E)
        // Spring: cherry blossom.
        seasonTree(
            &context, x: 486, y: h - 72, s: 1.3, trunk: bark,
            dark: Art.color(0xF4B9C6), light: Art.color(0xFCDDE4), drift: Art.color(0xF4A9BA), seed: 31
        )
        // Summer: green leaves.
        seasonTree(
            &context, x: 634, y: h - 118, s: 0.95, trunk: bark,
            dark: Art.color(0x4F9F78), light: Art.color(0x7FC29A), drift: nil, seed: 32
        )
        // Autumn: red maple.
        seasonTree(
            &context, x: 806, y: h - 116, s: 1.1, trunk: bark,
            dark: Art.color(0xD9573F), light: Art.color(0xF0895C), drift: Art.color(0xE0704C), seed: 33
        )
        // Winter: snow on a pine.
        pine(&context, 858, h - 92, 1.9, Art.color(0x3F7F78), trunk: bark, snow: true)
        var flakes = Path()
        var random = ArtRandom(34)
        for _ in 0..<12 {
            let fx = 812 + random.next(in: 0...78)
            let fy = h - 190 + random.next(in: 0...90)
            flakes.addEllipse(in: CGRect(x: fx - 1.2, y: fy - 1.2, width: 2.4, height: 2.4))
        }
        Art.fill(&context, flakes, Art.color(0xFFFFFF, 0.9))

        // Otohime greeting Urashima.
        Art.fill(&context, Art.ellipse(678, h - 57, 40, 5), Art.color(0x3F7F78, 0.14))
        Art.fill(&context, Art.ellipse(744, h - 57, 20, 4), Art.color(0x3F7F78, 0.14))
        Art.group(&context, x: 676, y: h - 58) { g in
            otohime(&g)
        }
        Art.group(&context, x: 744, y: h - 58) { g in
            urashima(&g, rod: .absent)
        }

        bubbles(&context, count: 12, seed: 23, x: 0, y: h - 280, w: w, h: 280, fill: white, ring: white, strength: 1.8)
    }

    /// A flat woodblock tree: a forked trunk under cloud-shaped foliage in two tones, with a few
    /// drifting petals or leaves. (x, y) is the foot of the trunk.
    static func seasonTree(
        _ context: inout GraphicsContext,
        x: CGFloat,
        y: CGFloat,
        s: CGFloat,
        trunk: Color,
        dark: Color,
        light: Color,
        drift: Color?,
        seed: UInt32
    ) {
        Art.group(&context, x: x, y: y, scale: s) { g in
            let limbs = Art.svg("M0,0 C-2,-14 3,-24 -1,-40 M-1,-26 C-8,-34 -14,-36 -20,-46 M0,-30 C8,-38 14,-40 20,-52")
            Art.stroke(&g, limbs, trunk, width: 3.2)
            let masses: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
                (-20, -48, 18, 8), (18, -54, 20, 8.5), (0, -64, 22, 9), (-6, -41, 14, 6),
            ]
            var darkPath = Path()
            var lightPath = Path()
            for (cx, cy, rx, ry) in masses {
                darkPath.addEllipse(in: CGRect(x: cx - rx, y: cy - ry, width: rx * 2, height: ry * 2))
                let lx = rx * 0.66
                let ly = ry * 0.5
                lightPath.addEllipse(in: CGRect(x: cx - lx + 2, y: cy - ry * 0.9, width: lx * 2, height: ly * 2))
            }
            Art.fill(&g, darkPath, dark)
            Art.fill(&g, lightPath, light)
            if let drift {
                var random = ArtRandom(seed)
                var specks = Path()
                for _ in 0..<9 {
                    let px = random.next(in: -34...34)
                    let py = random.next(in: -34...(-2))
                    specks.addEllipse(in: CGRect(x: px - 1.3, y: py - 1, width: 2.6, height: 2))
                }
                Art.fill(&g, specks, drift.opacity(0.85))
            }
        }
    }
}
