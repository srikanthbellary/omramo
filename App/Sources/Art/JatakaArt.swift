import SwiftUI
import OmramoCore

/// Concept art for "The Monkey and the Crocodile", drawn in code.
///
/// Ported and extended from the locked design source (docs/design/source/src/lib/art-jataka.js).
/// The characters and the riverbank parts live in `JatakaArt+Characters.swift` and
/// `JatakaArt+Nature.swift`; the tap-to-see pictures, the portrait, the faces and the cover in
/// `JatakaArt+Pictures.swift`. This file holds the entry point and the four story scenes.
enum JatakaArt {
    /// Draws the picture called `name`. Returns false for a name this story does not have.
    static func paint(_ name: String, role: ArtRole, in context: inout GraphicsContext, size: CGSize) -> Bool {
        guard size.width > 0, size.height > 0 else { return false }
        switch (name, role) {
        case ("scene-river", .sceneUnfolded):
            riverScene(&context, size, folded: false)
        case ("scene-river", .sceneFolded):
            foldedCrop(&context, size) { g, virtual in
                riverScene(&g, virtual, folded: true)
            }
        case ("scene-ride", .sceneUnfolded):
            rideScene(&context, size)
        case ("scene-ride", .sceneFolded):
            rideFolded(&context, size)
        case ("scene-island", .sceneUnfolded):
            islandScene(&context, size, folded: false)
        case ("scene-island", .sceneFolded):
            foldedCrop(&context, size) { g, virtual in
                islandScene(&g, virtual, folded: true)
            }
        case ("scene-dusk", .sceneUnfolded):
            duskScene(&context, size, folded: false)
        case ("scene-dusk", .sceneFolded):
            foldedCrop(&context, size) { g, virtual in
                duskScene(&g, virtual, folded: true)
            }
        case ("see-river-bank", .picture):
            riverBankPicture(&context, size)
        case ("see-ripe-fruit", .picture):
            ripeFruitPicture(&context, size)
        case ("char-monkey", .portrait):
            monkeyPortrait(&context, size)
        case ("face-monkey", .face):
            monkeyFace(&context, size)
        case ("face-crocodile", .face):
            crocFace(&context, size, mother: false)
        case ("face-mother-crocodile", .face):
            crocFace(&context, size, mother: true)
        case ("cover", .cover):
            cover(&context, size)
        default:
            return false
        }
        return true
    }
}

// MARK: - Scenes

extension JatakaArt {
    /// The picture band of a folded phone shows the trailing part of the unfolded scene:
    /// the scene is drawn 892 units wide at a smaller scale, with its trailing edge on the
    /// band's trailing edge. `body` gets the size of that wider, taller canvas.
    static func foldedCrop(
        _ context: inout GraphicsContext,
        _ size: CGSize,
        _ body: (inout GraphicsContext, CGSize) -> Void
    ) {
        let smallest: CGFloat = size.width / 892
        let wanted: CGFloat = size.height / 540
        let k = max(smallest, min(0.62, wanted))
        let virtual = CGSize(width: 892, height: size.height / k)
        Art.group(&context, x: size.width - 892 * k, y: 0, scale: k) { g in
            body(&g, virtual)
        }
    }

    static let banyanBlobs: [Blob] = [
        (835, 60, 95), (720, 50, 80), (610, 78, 70), (520, 60, 62), (440, 46, 50), (386, 30, 34),
        (880, 170, 70), (760, 140, 66), (660, 150, 46), (560, 132, 40), (480, 112, 34), (870, 260, 44),
        (660, 96, 50), (570, 40, 50), (800, 200, 40), (700, 190, 30), (610, 170, 26), (420, 96, 22),
        (392, 70, 18), (520, 150, 22),
    ]

    static let banyanFrontBlobs: [Blob] = [
        (505, 302, 26), (472, 316, 22), (536, 318, 18), (440, 302, 16), (486, 290, 16),
        (760, 236, 30), (726, 252, 22), (800, 262, 26),
    ]

    /// The great banyan: trunk, the Monkey's branch, hanging roots and the crown. The crown
    /// hangs from the top edge, the roots of the trunk stand on the bank at the horizon, and
    /// the trunk between them stretches. The top of the branch is near `branchY − 30`.
    static func banyan(_ context: inout GraphicsContext, height h: CGFloat, horizon H: CGFloat, branchY: CGFloat) {
        let dy = branchY - 330
        // The design's trunk runs from y 150 to y 574 (horizon 584); stretch it to this height.
        let s = max(0.2, (H - 160) / 424)
        let stretch = CGAffineTransform(a: 1, b: 0, c: 0, d: s, tx: 0, ty: 150 - 150 * s)
        let drop = CGAffineTransform(translationX: 0, y: dy)
        let ground = CGAffineTransform(translationX: 0, y: H - 584)
        let bark: [(Color, CGFloat)] = [
            (Art.color(0x8E5B45), 0), (Art.color(0x6B4138), 0.35), (Art.color(0x3E2532), 1),
        ]

        let trunk = Art.svg(
            "M770,574 C792,470 790,380 800,300 C806,250 800,200 790,150 L880,150 C872,230 878,330 872,420 C868,480 880,520 892,540 L892,604 C850,594 800,590 752,594 C760,588 766,582 770,574Z"
        ).applying(stretch)
        Art.fillLinear(&context, trunk, bark, from: CGPoint(x: 752, y: 0), to: CGPoint(x: 892, y: 0))

        let branch = Art.svg(
            "M806,330 C760,326 700,330 640,326 C590,322 540,318 492,316 C470,315 452,312 436,306 L438,298 C470,304 520,304 560,306 C640,308 720,300 800,286Z"
        ).applying(drop)
        Art.fillLinear(&context, branch, bark, from: CGPoint(x: 436, y: 0), to: CGPoint(x: 806, y: 0))
        let branchLight = Art.svg("M800,286 C720,300 640,308 560,306 C520,304 470,304 438,298").applying(drop)
        Art.stroke(&context, branchLight, Art.color(0xB37A58, 0.7), width: 2.5)

        let furrows = Art.svg(
            "M812,520 C818,420 814,330 822,200 M842,540 C846,430 840,330 850,190 M790,584 C800,500 802,470 806,420"
        ).applying(stretch)
        Art.stroke(&context, furrows, Art.color(0x3A2230, 0.45), width: 2)
        let trunkLight = Art.svg("M796,470 C800,400 798,340 806,270").applying(stretch)
        Art.stroke(&context, trunkLight, Art.color(0xC68A62, 0.5), width: 3)
        let feet = Art.svg("M770,574 C756,588 740,594 720,598 M800,588 C790,600 780,606 764,612").applying(ground)
        Art.stroke(&context, feet, Art.color(0x5B3B36), width: 7)

        // Aerial roots. The last number is 1 for a root that hangs from the branch itself.
        let roots: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
            (560, 150, 150, 0), (574, 160, 120, 0), (690, 200, 190, 0), (703, 190, 130, 0),
            (800, 250, 120, 0), (650, 180, 90, 0), (742, 286, 140, 1), (520, 150, 100, 0),
        ]
        let rootScale = min(2.4, max(0.55, 1 + dy / 330))
        var random = ArtRandom(21)
        for root in roots {
            let onBranch = root.3 > 0.5
            let x = root.0
            let y0 = onBranch ? root.1 + dy : root.1
            let length = onBranch ? root.2 : root.2 * rootScale
            let sway = (rnd(&random) - 0.5) * 14
            let width = 1.6 + rnd(&random) * 1.6
            var line = Path()
            line.move(to: CGPoint(x: x, y: y0))
            line.addQuadCurve(to: CGPoint(x: x + sway * 0.4, y: y0 + length), control: CGPoint(x: x + sway, y: y0 + length * 0.5))
            Art.stroke(&context, line, Art.color(0x5B3B36, 0.9), width: width)
        }

        canopy(&context, stretched(banyanBlobs, height: h, minX: 640), seed: 5)
    }

    /// scene-river: morning. The banyan on the bank, the Monkey on his branch, the
    /// crocodiles in the water, the fruit island far off. Screen 03 of the designs.
    static func riverScene(_ context: inout GraphicsContext, _ size: CGSize, folded: Bool) {
        let w = size.width
        let h = size.height
        let H = h - 136
        let mood = morningMood()
        let palms: [CGFloat] = [40, 92, 330, 372, 470, 512, 596]
        backdrop(
            &context,
            size: size,
            horizon: H,
            mood: mood,
            sunX: folded ? 300 : 120,
            sunRadius: 38,
            hillScale: 1,
            palms: palms,
            ripples: 110
        )
        let cloudWhite = Art.color(0xFFFFFF, 0.55)
        cloud(&context, 60, 150, scale: 1.1, color: cloudWhite)
        cloud(&context, 300, 96, scale: 0.8, color: cloudWhite)
        birds(&context, 236, H - 38, color: Art.color(0x3B6E79))

        island(&context, x: 196, y: H + 4, scale: 1)

        nearBank(&context, horizon: H, dusk: false)
        reeds(&context, 676, H + 34, count: 9, seed: 4, height: 64)
        reeds(&context, 742, H + 54, count: 7, seed: 12, height: 52)

        let wanted = folded ? min(h * 0.52, H - 110) : min(h * 0.46, h - 330)
        let branchY = max(250, wanted)
        let dy = branchY - 330
        banyan(&context, height: h, horizon: H, branchY: branchY)

        // The Monkey on the branch.
        Art.fill(&context, Art.ellipse(607, 310 + dy, 30, 4), Art.color(0x2A1820, 0.35))
        Art.group(&context, x: 606, y: 306 + dy, scale: 0.98) { g in
            monkey(&g, pose: .sit, lookX: -2.2, lookY: 2.2, mouth: .smile)
        }
        Art.group(&context, y: dy) { g in
            canopy(&g, banyanFrontBlobs, seed: 9)
        }
        if !folded {
            // Shade under the status bar of the trailing pane.
            let shade: [(Color, CGFloat)] = [(Art.color(0x06302E, 0.55), 0), (Art.color(0x06302E, 0), 1)]
            Art.fillLinear(&context, Art.rect(460, 0, w - 460, 70), shade, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: 70))
        }

        // The crocodiles: the mother near the bank, her little son out in the river.
        let skin = youngCrocSkin()
        Art.group(&context, x: 716, y: H + 62, scale: 0.8, scaleX: -1) { g in
            croc(&g, skin: skin, lid: .sly, lookX: -1, lookY: -2, waterline: 9, water: Art.color(0x1596A0))
        }
        ripples(&context, 594, H + 72, 230, count: 3)
        Art.group(&context, x: 412, y: H + 78, scale: 0.42, scaleX: -1) { g in
            croc(&g, skin: skin, lid: .wide, lookX: -1.5, lookY: -1, waterline: 9, water: Art.color(0x2AA9A6))
        }
        ripples(&context, 346, H + 83, 120, count: 2)

        if folded {
            lotusPad(&context, 520, H + 30, 20, flower: true)
        } else {
            lotusPad(&context, 60, H + 112, 34, flower: true)
            lotusPad(&context, 124, H + 132, 26)
            lotusPad(&context, 24, H + 138, 22)
            lotusPad(&context, 820, H + 106, 30, flower: true)
            lotusPad(&context, 760, H + 120, 22)
            cornerLeaves(&context, width: w, height: h, color: Art.color(0x0E5A55))
        }
        dragonfly(&context, 300, H + 30, scale: 1)
        dragonfly(&context, 520, H + 20, scale: 0.8)
    }

    /// scene-ride (unfolded): mid-river. The Monkey rides the Crocodile across the trailing
    /// pane toward the fruit island, which lies far ahead under the reading side.
    static func rideScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let h = size.height
        let H = h - 150
        let mood = morningMood()
        let palms: [CGFloat] = [30, 84, 520, 566, 700, 852]
        backdrop(
            &context,
            size: size,
            horizon: H,
            mood: mood,
            sunX: 214,
            sunRadius: 40,
            hillScale: 0.9,
            palms: palms,
            ripples: 130
        )
        let cloudWhite = Art.color(0xFFFFFF, 0.55)
        cloud(&context, 60, 150, scale: 1.1, color: cloudWhite)
        cloud(&context, 300, 96, scale: 0.8, color: cloudWhite)
        cloud(&context, 520, h * 0.3, scale: 1.3, color: cloudWhite)
        cloud(&context, 716, h * 0.44, scale: 1.0, color: cloudWhite)
        birds(&context, 560, H - 118, color: Art.color(0x3B6E79))

        island(&context, x: 96, y: H - 4, scale: 0.8)

        // A few leaves of the home tree still overhang the corner.
        let corner: [Blob] = [(880, 14, 62), (800, -12, 46), (905, 96, 36), (740, -20, 30)]
        canopy(&context, corner, seed: 4)

        // The riders.
        let crocX: CGFloat = 482
        let crocY = H + 84
        let scale: CGFloat = 1.05
        let skin = youngCrocSkin()
        Art.group(&context, x: crocX, y: crocY, scale: scale) { g in
            croc(&g, skin: skin, lid: .sleepy, lookX: -1, lookY: 0, waterline: 12, water: Art.color(0x1596A0))
            Art.group(&g, x: 206, y: -26, scale: 1.02) { m in
                monkey(&m, pose: .ride, lookX: -2, lookY: 0, mouth: .grin)
            }
        }
        ripples(&context, crocX + 150, crocY + 14, 320, count: 3)
        let bowWave = placed("M-26,10 q-14,-4 -24,2 M-30,20 q-16,0 -26,8", x: crocX, y: crocY, scale: scale)
        Art.stroke(&context, bowWave, Art.color(0xFFFFFF, 0.8), width: 2.2)
        let wake = placed("M362,16 q16,-5 30,1 M366,28 q18,-2 30,6", x: crocX, y: crocY, scale: scale)
        Art.stroke(&context, wake, Art.color(0xFFFFFF, 0.6), width: 2)

        lotusPad(&context, 56, H + 122, 30, flower: true)
        lotusPad(&context, 120, H + 138, 22)
        dragonfly(&context, 360, H + 44, scale: 0.9)
    }

    /// scene-ride (folded): screen 10 of the designs.
    static func rideFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let h = size.height
        let H = (h * 0.56).rounded()
        let depth = h - H
        let k = min(1, depth / 150)
        let mood = morningMood()
        let palms: [CGFloat] = [30, 90, 250, 400]
        backdrop(
            &context,
            size: size,
            horizon: H,
            mood: mood,
            sunX: 330,
            sunRadius: 30,
            hillScale: 0.77,
            palms: palms,
            ripples: 46
        )
        island(&context, x: 250, y: H - 37, scale: 0.8, withPalm: false)

        let crocX = 60 + (1 - k) * 90
        let crocY = H + 86 * k
        let skin = youngCrocSkin()
        Art.group(&context, x: crocX, y: crocY, scale: 0.92 * k) { g in
            croc(&g, skin: skin, lid: .sleepy, lookX: -1, lookY: 0, waterline: 12, water: Art.color(0x1596A0))
            Art.group(&g, x: 206, y: -26, scale: 1.02) { m in
                monkey(&m, pose: .ride, lookX: -2, lookY: 0, mouth: .grin)
            }
        }
        ripples(&context, crocX + 140 * k, crocY + 14 * k, 300 * k, count: 3)
        let bowWave = placed("M-26,10 q-14,-4 -24,2 M-30,20 q-16,0 -26,8", x: crocX, y: crocY, scale: k)
        Art.stroke(&context, bowWave, Art.color(0xFFFFFF, 0.8), width: 2.2)
    }

    /// scene-island: a new tree downriver, a stepping-stone rock halfway across, the island
    /// full of fruit, the Monkey in mid-hop and the Crocodile watching, low in the water.
    static func islandScene(_ context: inout GraphicsContext, _ size: CGSize, folded: Bool) {
        let w = size.width
        let h = size.height
        let H = h - 136
        let mood = morningMood()
        let palms: [CGFloat] = [30, 80, 470, 530, 610]
        backdrop(
            &context,
            size: size,
            horizon: H,
            mood: mood,
            sunX: folded ? 250 : 96,
            sunRadius: 36,
            hillScale: 1,
            palms: palms,
            ripples: 110
        )
        let cloudWhite = Art.color(0xFFFFFF, 0.55)
        cloud(&context, 40, 132, scale: 1.0, color: cloudWhite)
        cloud(&context, 280, 84, scale: 0.9, color: cloudWhite)
        birds(&context, 540, H - 76, color: Art.color(0x3B6E79))

        island(&context, x: 140, y: H + 4, scale: 1.15, rich: true)

        nearBank(&context, horizon: H, dusk: false)
        reeds(&context, 690, H + 38, count: 6, seed: 6, height: 50)
        shoreTree(&context, height: h, baseY: H - 24, palette: figGreens, fruit: true, dusk: false)

        rock(&context, cx: 566, waterY: H + 72, width: 132, height: 46, flat: false, dusk: false)

        // The hop: from the bank to the rock.
        var arc = Path()
        arc.move(to: CGPoint(x: 716, y: H - 34))
        arc.addQuadCurve(to: CGPoint(x: 576, y: H + 22), control: CGPoint(x: 640, y: H - 190))
        Art.stroke(&context, arc, Art.color(0xFFFFFF, 0.75), width: 2.6, dash: [1, 9])
        Art.group(&context, x: 644, y: H - 70, rotate: deg(-10), scale: 0.9) { g in
            monkey(&g, pose: .ride, lookX: -2, lookY: 2, mouth: .open)
        }

        // The Crocodile, only his eyes and back above the water.
        let skin = youngCrocSkin()
        Art.group(&context, x: 412, y: H + 90, scale: 0.46, scaleX: -1) { g in
            croc(&g, skin: skin, lid: .sly, lookX: -1.5, lookY: -2.5, waterline: 0, water: Art.color(0x2AA9A6), waterOpacity: 0.8)
        }
        ripples(&context, 346, H + 93, 130, count: 2)

        if folded {
            lotusPad(&context, 470, H + 28, 18, flower: true)
        } else {
            lotusPad(&context, 60, H + 112, 34, flower: true)
            lotusPad(&context, 124, H + 132, 26)
            lotusPad(&context, 24, H + 138, 22)
            lotusPad(&context, 790, H + 112, 26, flower: true)
            cornerLeaves(&context, width: w, height: h, color: Art.color(0x0E5A55))
        }
        dragonfly(&context, 470, H + 44, scale: 0.9)
    }

    /// scene-dusk: evening. The Crocodile lies very flat on the rock; the Monkey sits at the
    /// water's edge and looks at it. The sky stays pale for the story text.
    static func duskScene(_ context: inout GraphicsContext, _ size: CGSize, folded: Bool) {
        let w = size.width
        let h = size.height
        let H = h - 136
        let mood = duskMood()
        let palms: [CGFloat] = [36, 84, 300, 470, 520, 600]
        backdrop(
            &context,
            size: size,
            horizon: H,
            mood: mood,
            sunX: folded ? 330 : 128,
            sunRadius: 46,
            hillScale: 1,
            palms: palms,
            ripples: 100
        )
        let cloudWarm = Art.color(0xFFF6EA, 0.6)
        cloud(&context, 70, 160, scale: 1.1, color: cloudWarm)
        cloud(&context, 290, 104, scale: 0.8, color: cloudWarm)
        birds(&context, 560, H - 84, color: Art.color(0x6A5A86))

        island(&context, x: 214, y: H + 2, scale: 0.9, dusk: true)

        nearBank(&context, horizon: H, dusk: true)
        reeds(
            &context, 690, H + 38,
            count: 7,
            seed: 6,
            height: 54,
            dark: Art.color(0x3F7A66),
            light: Art.color(0x6FA07A),
            head: Art.color(0x5A3A40)
        )
        shoreTree(&context, height: h, baseY: H - 24, palette: duskGreens, fruit: false, dusk: true)

        // The rock, and the Crocodile pretending to be part of it.
        rock(&context, cx: 560, waterY: H + 76, width: 200, height: 40, flat: true, dusk: true)
        let skin = youngCrocSkin()
        let lyingFlat = Art.rect(440, H - 30, 240, 72)
        Art.clipped(&context, to: lyingFlat) { g in
            Art.group(&g, x: 650, y: H + 31, scale: 0.5, scaleX: -1) { c in
                croc(&c, skin: skin, lid: .shut, waterline: 200, waterOpacity: 0)
            }
        }
        Art.stroke(&context, Art.line(482, H + 42.5, 644, H + 42.5), Art.color(0x3A2F66, 0.3), width: 2)

        // The Monkey at the water's edge.
        Art.fill(&context, Art.ellipse(708, H + 20, 34, 5), Art.color(0x1B3A40, 0.3))
        Art.group(&context, x: 708, y: H + 2, scale: 0.9) { g in
            monkey(&g, pose: .sit, lookX: -3, lookY: 1.2, mouth: .oh)
        }

        if folded {
            lotusPad(&context, 430, H + 30, 18, pad: Art.color(0x3F8A7A), vein: Art.color(0xA9D6A0))
        } else {
            let padColor = Art.color(0x3F8A7A)
            let veinColor = Art.color(0xA9D6A0)
            lotusPad(&context, 60, H + 112, 34, flower: true, pad: padColor, vein: veinColor)
            lotusPad(&context, 124, H + 132, 26, pad: padColor, vein: veinColor)
            lotusPad(&context, 24, H + 138, 22, pad: padColor, vein: veinColor)
            lotusPad(&context, 800, H + 114, 26, flower: true, pad: padColor, vein: veinColor)
            cornerLeaves(&context, width: w, height: h, color: Art.color(0x2A3F5A))
        }

        // Evening warmth over the lower part of the picture.
        let warm: [(Color, CGFloat)] = [(Art.color(0xFF9E7A, 0), 0), (Art.color(0xFF9E7A, 0.1), 1)]
        Art.fillLinear(&context, Art.rect(0, H - 160, w, h - H + 160), warm, from: CGPoint(x: 0, y: H - 160), to: CGPoint(x: 0, y: h))
    }
}
