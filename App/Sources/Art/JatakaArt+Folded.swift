import SwiftUI
import OmramoCore

// The four scenes of "The Monkey and the Crocodile" as the picture band of a folded phone:
// 432 units wide and about 240…520 high. Each is its own composition for that tall-ish frame,
// not a crop of the wide scene: the subject's face is inside the middle 60% of the width
// (x 86…346), below the two top controls where it stands beside them, and above the wave edge
// that cuts the bottom 24–30 units; far hills, the subject and a near tree or bank give the
// three planes. Everything is anchored to the horizon, which is set for the band, and the
// subject scales with the height.
//
// The big parts (banyan, bank, shore tree) are drawn by the same painters as the unfolded
// scenes, in their own 892-wide units, hung on the band's trailing edge at a scale chosen for
// the band (`hung`). The river, the far plane and the animals in the water are placed in the
// band's own units.

extension JatakaArt {
    /// The numbers a folded band derives from its height.
    struct Band {
        /// 0.6…1.15: the size of the subject against the reference band (420 high).
        let unit: CGFloat
        /// The horizon line.
        let H: CGFloat
        /// The depth of the river, of which the bottom 30 units are cut by the wave edge.
        let water: CGFloat
    }

    /// `share` is the part of the height given to the river; it is kept between `least`
    /// and `most` units.
    static func band(_ size: CGSize, share: CGFloat, least: CGFloat, most: CGFloat) -> Band {
        let h = size.height
        let unit: CGFloat = max(0.6, min(1.15, h / 420))
        let water: CGFloat = max(least, min(most, h * share))
        let horizon: CGFloat = (h - water).rounded()
        return Band(unit: unit, H: horizon, water: h - horizon)
    }

    /// Draws `body` in the 892-wide units of the unfolded painters, scaled by `k` and hung on
    /// the band's trailing edge: x 892 lands on x 432, and y 0 stays at the top.
    static func hung(_ context: inout GraphicsContext, scale k: CGFloat, _ body: (inout GraphicsContext) -> Void) {
        Art.group(&context, x: 432 - 892 * k, y: 0, scale: k) { v in
            body(&v)
        }
    }

    /// How far a shore tree's crown is lifted when the horizon (in its own units) is high.
    static func shoreLift(horizon Hv: CGFloat) -> CGFloat {
        min(1, max(0.5, (Hv - 190) / 230))
    }

    // MARK: scene-river

    /// scene-river (folded): the Monkey on his branch in the middle of the band, the banyan's
    /// trunk and bank on the trailing edge, the little Crocodile in the water below him,
    /// looking up, and the fruit island far off on the leading side.
    static func riverFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let h = size.height
        let frame = band(size, share: 0.26, least: 62, most: 140)
        let u = frame.unit
        let H = frame.H
        let mood = morningMood()
        let palms: [CGFloat] = [22, 150, 196, 300]
        backdrop(
            &context,
            size: size,
            horizon: H,
            mood: mood,
            sunX: 92,
            sunRadius: 30 * u,
            hillScale: 0.8 * u,
            palms: palms,
            ripples: 40,
            palmScale: u
        )
        island(&context, x: 6, y: H - 8 * u, scale: 0.5 * u, haze: 0.14)
        birds(&context, 150, H - 46 * u, color: Art.color(0x3B6E79))

        // The banyan, hung on the trailing edge. The Monkey's seat is at 60% of the height.
        let k: CGFloat = 0.78 * max(0.7, min(1.15, h / 420))
        let hv: CGFloat = h / k
        let Hv: CGFloat = H / k
        let seat: CGFloat = h * 0.6 / k
        let dy: CGFloat = seat - 306
        let branchY: CGFloat = 330 + dy
        hung(&context, scale: k) { v in
            nearBank(&v, horizon: Hv, dusk: false)
            reeds(&v, 676, Hv + 34, count: 9, seed: 4, height: 64)
            reeds(&v, 742, Hv + 54, count: 7, seed: 12, height: 52)
            banyan(&v, height: hv, horizon: Hv, branchY: branchY)
            ArtStyle.contactShadow(&v, 609, seat + 5, 36, 5, alpha: 0.32)
            Art.group(&v, x: 606, y: seat, scale: 0.98) { m in
                monkey(&m, pose: .sit, lookX: -2.4, lookY: 2.4, mouth: .smile)
            }
            Art.group(&v, y: dy) { f in
                canopy(&f, banyanFrontBlobs, seed: 9)
            }
        }

        // The little Crocodile, in the band's own units: his face is under the Monkey.
        let crocScale: CGFloat = 0.5 * u
        let crocY: CGFloat = H + 10 + (frame.water - 40) * 0.5
        let skin = youngCrocSkin()
        Art.group(&context, x: 186, y: crocY, scale: crocScale, scaleX: -1) { c in
            croc(&c, skin: skin, lid: .wide, lookX: -1.5, lookY: -2, waterline: 9, water: Art.color(0x2AA9A6), mirrored: true)
        }
        ripples(&context, 186 - 157 * crocScale, crocY + 5 * u, 290 * crocScale, count: 2)
        dragonfly(&context, 112, H + 2, scale: 0.8 * u)
        ArtStyle.finish(&context, size)
    }

    // MARK: scene-ride

    /// scene-ride (folded): screen 10 of the designs. The riders fill the band; the fruit
    /// island waits on the far side.
    static func rideFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let h = size.height
        let H = (h * 0.56).rounded()
        let depth = h - H
        let k: CGFloat = max(0.5, min(1.18, depth / 150))
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
        island(&context, x: 250, y: H - 37, scale: 0.8, withPalm: false, haze: 0.08)
        birds(&context, 150, H - 70, color: Art.color(0x3B6E79))

        // The near plane: a few leaves of the home tree in the top trailing corner.
        let corner: [Blob] = [(436, -4, 40), (392, -22, 30), (452, 52, 24)]
        canopy(&context, corner, seed: 4)

        let crocX: CGFloat = 60 + (1 - k) * 90
        let crocY: CGFloat = H + 86 * k
        let skin = youngCrocSkin()
        Art.group(&context, x: crocX, y: crocY, scale: 0.92 * k) { g in
            croc(&g, skin: skin, lid: .sleepy, lookX: -1, lookY: 0, waterline: 12, water: Art.color(0x1596A0))
            ArtStyle.contactShadow(&g, 204, -19, 40, 6, alpha: 0.26)
            Art.group(&g, x: 206, y: -26, scale: 1.02) { m in
                monkey(&m, pose: .ride, lookX: -2, lookY: 0, mouth: .grin)
            }
        }
        ripples(&context, crocX + 140 * k, crocY + 14 * k, 300 * k, count: 3)
        let bowWave = placed("M-26,10 q-14,-4 -24,2 M-30,20 q-16,0 -26,8", x: crocX, y: crocY, scale: k)
        Art.stroke(&context, bowWave, Art.color(0xFFFFFF, 0.8), width: ArtStyle.contourLine)
        ArtStyle.finish(&context, size)
    }

    // MARK: scene-island

    /// scene-island (folded): the Monkey in mid-hop in the middle of the band, between the
    /// fruit tree on the bank (trailing edge) and the stepping-stone rock; the island full
    /// of fruit behind the rock, and the Crocodile low in the water in front.
    static func islandFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let h = size.height
        let frame = band(size, share: 0.3, least: 70, most: 150)
        let u = frame.unit
        let H = frame.H
        let mood = morningMood()
        let palms: [CGFloat] = [150, 196, 250]
        backdrop(
            &context,
            size: size,
            horizon: H,
            mood: mood,
            sunX: 216,
            sunRadius: 30 * u,
            hillScale: 0.8 * u,
            palms: palms,
            ripples: 44,
            palmScale: u
        )
        island(&context, x: -12, y: H - 10 * u, scale: 0.64 * u, rich: true)

        // The bank and its tree, hung on the trailing edge.
        let k: CGFloat = 0.7 * max(0.7, min(1.15, h / 420))
        let hv: CGFloat = h / k
        let Hv: CGFloat = H / k
        let lift = shoreLift(horizon: Hv)
        hung(&context, scale: k) { v in
            nearBank(&v, horizon: Hv, dusk: false)
            reeds(&v, 690, Hv + 38, count: 6, seed: 6, height: 50)
            shoreTree(&v, height: hv, baseY: Hv - 24, palette: figGreens, fruit: true, dusk: false, crownLift: lift)
        }

        // The rock, in the band's own units.
        let rockY: CGFloat = H + 10 + (frame.water - 40) * 0.45
        let rockHeight: CGFloat = 40 * u
        rock(&context, cx: 140, waterY: rockY, width: 120 * u, height: rockHeight, flat: false, dusk: false)

        // The hop: from the bank to the rock, the Monkey at the top of it.
        let hopFrom = CGPoint(x: 432 - 176 * k, y: H - 34 * k)
        let hopTo = CGPoint(x: 146, y: rockY - rockHeight - 3)
        let hopPeak = CGPoint(x: (hopFrom.x + hopTo.x) / 2, y: min(hopFrom.y, hopTo.y) - 110 * u)
        var arc = Path()
        arc.move(to: hopFrom)
        arc.addQuadCurve(to: hopTo, control: hopPeak)
        Art.stroke(&context, arc, Art.color(0xFFFFFF, 0.75), width: ArtStyle.contourLine, dash: [1, 8])
        ArtStyle.contactShadow(&context, 144, rockY - rockHeight + 4, 26 * u, 3.5, alpha: 0.22)
        let midX: CGFloat = 0.25 * hopFrom.x + 0.5 * hopPeak.x + 0.25 * hopTo.x
        let midY: CGFloat = 0.25 * hopFrom.y + 0.5 * hopPeak.y + 0.25 * hopTo.y
        let monkeyScale: CGFloat = 0.8 * u
        Art.group(&context, x: midX, y: midY + 28 * monkeyScale, rotate: deg(-10), scale: monkeyScale) { m in
            monkey(&m, pose: .ride, lookX: -2, lookY: 2, mouth: .open)
        }

        // The Crocodile, only his eyes and back above the water, watching the hop.
        let crocScale: CGFloat = 0.46 * u
        let wantedY: CGFloat = H + 10 + (frame.water - 40) * 0.82
        let crocY: CGFloat = min(wantedY, h - 34)
        let skin = youngCrocSkin()
        Art.group(&context, x: 238, y: crocY, scale: crocScale) { c in
            croc(&c, skin: skin, lid: .sly, lookX: -1.5, lookY: -2.5, waterline: 0, water: Art.color(0x2AA9A6), waterOpacity: 0.8)
        }
        ripples(&context, 238 + 143 * crocScale, crocY + 3, 283 * crocScale, count: 2)
        dragonfly(&context, 96, H - 30 * u, scale: 0.8 * u)
        ArtStyle.finish(&context, size)
    }

    // MARK: scene-dusk

    /// scene-dusk (folded): evening. The Monkey sits at the water's edge on the trailing
    /// side of the middle and looks at the rock; the Crocodile lies flat on it, on the
    /// leading side of the middle. The sky stays pale.
    static func duskFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        let h = size.height
        let frame = band(size, share: 0.3, least: 70, most: 150)
        let u = frame.unit
        let H = frame.H
        let mood = duskMood()
        let palms: [CGFloat] = [30, 76, 190, 236]
        backdrop(
            &context,
            size: size,
            horizon: H,
            mood: mood,
            sunX: 120,
            sunRadius: 36 * u,
            hillScale: 0.8 * u,
            palms: palms,
            ripples: 40,
            palmScale: u
        )
        island(&context, x: 150, y: H - 8 * u, scale: 0.42 * u, dusk: true, haze: 0.14)
        birds(&context, 200, H - 60 * u, color: Art.color(0x6A5A86))

        // The bank, its tree and the Monkey, hung on the trailing edge.
        let k: CGFloat = 0.74 * max(0.82, min(1.1, h / 420))
        let hv: CGFloat = h / k
        let Hv: CGFloat = H / k
        let lift = shoreLift(horizon: Hv)
        hung(&context, scale: k) { v in
            nearBank(&v, horizon: Hv, dusk: true)
            reeds(
                &v, 690, Hv + 38,
                count: 7,
                seed: 6,
                height: 54,
                dark: Art.color(0x3F7A66),
                light: Art.color(0x6FA07A),
                head: Art.color(0x5A3A40)
            )
            shoreTree(&v, height: hv, baseY: Hv - 24, palette: duskGreens, fruit: false, dusk: true, crownLift: lift)
            ArtStyle.contactShadow(&v, 708, Hv + 20, 40, 6, alpha: 0.3)
            Art.group(&v, x: 708, y: Hv + 2, scale: 0.9) { m in
                monkey(&m, pose: .sit, lookX: -3, lookY: 1.6, mouth: .oh)
            }
        }

        // The rock and the Crocodile on it, in the band's own units.
        let rockY: CGFloat = H + 10 + (frame.water - 40) * 0.55
        sleepingRock(&context, cx: 126, waterY: rockY, scale: 0.78 * u)

        // Evening warmth over the lower part of the picture.
        let warm: [(Color, CGFloat)] = [(Art.color(0xFF9E7A, 0), 0), (Art.color(0xFF9E7A, 0.1), 1)]
        let warmTop: CGFloat = max(0, H - 120)
        Art.fillLinear(&context, Art.rect(0, warmTop, w, h - warmTop), warm, from: CGPoint(x: 0, y: warmTop), to: CGPoint(x: 0, y: h))
        ArtStyle.finish(&context, size, wash: 0.08, vignette: 0.10)
    }
}
