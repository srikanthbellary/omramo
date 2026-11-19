import SwiftUI
import OmramoCore

// The four folded scenes of "The Snow House": each its own composition for the picture band at
// the top of a phone (432 wide, 240…520 high), the subject's face in the middle.

extension SnowHouseArt {
    /// The far plane and the snow of a folded band. `sunX` nil leaves the sun out (the spring
    /// night, when it has just dipped: a peach band lies on the horizon instead).
    static func foldedLand(
        _ context: inout GraphicsContext,
        _ band: Kit.Band,
        dusk isDusk: Bool,
        sunX: CGFloat?,
        hills: [(CGFloat, CGFloat, CGFloat)],
        seed: UInt32
    ) {
        let light: Kit.Light = isDusk ? dusk() : day()
        let u: CGFloat = band.unit
        Kit.sky(&context, band.size, horizon: band.H, light: light)
        if let sunX {
            Kit.sun(&context, sunX, band.H - 26 * u, 15 * u, light: light)
        } else {
            flatGlow(&context, 80, band.H - 3, rx: 170 * u, ry: 40 * u, color: Art.color(0xFFDDB0), alpha: 0.6)
        }
        Kit.cloud(&context, 318, band.H * 0.42, scale: 0.5 * u, color: Art.color(0xFFFFFF, 0.5))
        farLand(&context, width: band.w, horizon: band.H, scale: u * 0.8, light: light, hills: hills, seed: seed)
        Kit.ground(&context, width: band.w, top: band.H, bottom: band.h, stops: snowStops(dusk: isDusk), seed: seed &+ 60)
        if let sunX {
            flatGlow(&context, sunX, band.H + 9 * u, rx: 130 * u, ry: 15 * u, color: light.glow, alpha: 0.4)
        }
        iceBand(&context, x0: -30, x1: 300, y: band.H + 8 * u, depth: 10 * u, dusk: isDusk)
        windRipples(&context, x0: 0, x1: band.w, y0: band.H + 16 * u, y1: band.h - 8, count: 18, seed: seed &+ 3)
    }

    // MARK: Scene 1: the trail

    /// Elisapie rides on the load of the qamutiik, her hood blown back, shouting; the back of
    /// the snowmobile and Grandfather's hood are just ahead of her.
    static func trailFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let hills: [(CGFloat, CGFloat, CGFloat)] = [(0.3, 0.7, 26), (0.8, 1.1, 34)]
        foldedLand(&context, band, dusk: false, sunX: 70, hills: hills, seed: 4)
        let k: CGFloat = band.unit * 1.1
        let base: CGFloat = band.H + band.ground * 0.35
        Art.group(&context, x: 216, y: base, scale: k) { g in
            // The tracks run from under the sled down to the bottom edge.
            tracks(&g, from: pt(236, 74), round: pt(190, 14), to: pt(112, 3), gap: 16)
            castShadow(&g, -170, 3, length: 150)
            castShadow(&g, 30, 3, length: 200)
            Art.group(&g, x: -176, y: 0) { m in
                snowmobile(&m, rider: true)
            }
            Art.stroke(&g, Art.line(-98, -24, -79, -24), Art.color(0x8A7A66), width: 1.8)
            Art.group(&g, x: 25, y: 0) { s in
                qamutiik(&s)
                Art.group(&s, x: 55, y: -40) { e in
                    elisapie(&e, pose: .sit, look: CGPoint(x: -0.7, y: -0.1), mouth: .open)
                }
            }
            var spray = Path()
            spray.addEllipse(in: CGRect(x: -104, y: -12, width: 18, height: 10))
            spray.addEllipse(in: CGRect(x: -92, y: -7, width: 12, height: 7))
            spray.addEllipse(in: CGRect(x: 120, y: -9, width: 16, height: 9))
            spray.addEllipse(in: CGRect(x: 132, y: -5, width: 10, height: 6))
            Art.fill(&g, spray, Color.white.opacity(0.85))
        }
        softDrift(&context, x0: 10, x1: 170, baseY: band.floor - 4, height: 10 * band.unit)
        ArtStyle.finish(&context, size)
    }

    // MARK: Scene 2: cutting

    /// The two halves of a cracked block, in Elisapie's mitts. Origin: between her hands.
    static func heldHalves(_ context: inout GraphicsContext) {
        let left: [CGPoint] = [pt(-16, 2), pt(-15, -22), pt(12, -22), pt(7, -10), pt(13, 2)]
        let right: [CGPoint] = [pt(-12, 2), pt(-7, -11), pt(-13, -22), pt(14, -22), pt(15, 2)]
        let leftHalf: Path = Art.polygon(left)
        let rightHalf: Path = Art.polygon(right)
        let edge: Color = Art.color(0xA9BEDD, 0.75)
        Art.group(&context, x: -19, y: 6, rotate: -0.34) { g in
            Kit.solid(&g, leftHalf, Art.color(0xFAFCFF), light: 0.14, shade: 0.12)
            Art.stroke(&g, leftHalf, edge, width: 1.2)
        }
        Art.group(&context, x: 17, y: 4, rotate: 0.3) { g in
            Kit.solid(&g, rightHalf, Art.color(0xEEF3FB), light: 0.1, shade: 0.2)
            Art.stroke(&g, rightHalf, edge, width: 1.2)
        }
        let marks: Path = Art.svg("M-1,-22 L-1,-34 M-8,-21 L-14,-31 M6,-21 L12,-31")
        Art.stroke(&context, marks, Art.color(ramp.shade, 0.9), width: 2)
        var mitts = Path()
        mitts.addPath(Art.circle(-7, 8, 4.6))
        mitts.addPath(Art.circle(6, 7, 4.6))
        Art.fill(&context, mitts, Kit.personTone(parkaRed, 0.7))
        let fall = CGRect(x: -14, y: 2, width: 28, height: 44)
        Kit.flecks(&context, in: fall, count: 9, seed: 12, color: Color.white, radius: 1.2...2.8)
    }

    /// Elisapie holds the two halves of her cracked block, mouth open; behind her shoulder
    /// Grandfather calmly cuts with the snow knife; crumbs lie at the bottom.
    static func cuttingFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let hills: [(CGFloat, CGFloat, CGFloat)] = [(-0.06, 0.26, 22), (0.5, 0.86, 28)]
        foldedLand(&context, band, dusk: false, sunX: 64, hills: hills, seed: 14)
        let k: CGFloat = band.unit * 1.2
        let base: CGFloat = band.H + band.ground * 0.4
        Art.group(&context, x: 216, y: base, scale: k) { g in
            // Behind: the pit, a clean block, and Grandfather bending to his knife.
            cuttingPit(&g, x0: 92, x1: 168, y: -27, depth: 12)
            Kit.snowBlock(&g, x: 150, baseY: -32, width: 46, height: 26, tilt: 0.04)
            castShadow(&g, 80, -24, length: 76)
            Art.group(&g, x: 78, y: -26, scale: 0.82, scaleX: -1) { m in
                grandfather(&m, pose: .bow, look: CGPoint(x: -0.2, y: 0.8), mouth: .smile, mirrored: true)
                let hand = grandfatherHand(.bow)
                Art.group(&m, x: hand.x, y: hand.y, rotate: CGFloat.pi) { n in
                    snowKnife(&n, length: 58)
                }
                Art.fill(&m, Art.circle(hand.x, hand.y, 6), Kit.personTone(parkaBlue, 0.7))
            }
            // In front: Elisapie and her heap.
            crumbHeap(&g, cx: -112, baseY: 2, width: 60, seed: 13)
            castShadow(&g, -38, 2, length: 64)
            Art.group(&g, x: -40, y: 0) { e in
                elisapie(&e, pose: .carry, look: CGPoint(x: -0.3, y: 0.7), mouth: .open)
            }
            Art.group(&g, x: -64, y: -70) { b in
                heldHalves(&b)
            }
            let crumbs = CGRect(x: -100, y: 0, width: 110, height: 12)
            Kit.flecks(&g, in: crumbs, count: 12, seed: 16, color: Color.white, radius: 1.4...3.2)
        }
        ArtStyle.finish(&context, size)
    }

    // MARK: Scene 3: the spiral

    /// Elisapie pats soft snow into a gap, close to the curving wall, its sloping seams
    /// behind her; Grandfather's hood and the tip of his knife show over the top.
    static func spiralFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let hills: [(CGFloat, CGFloat, CGFloat)] = [(0.12, 0.5, 24)]
        foldedLand(&context, band, dusk: false, sunX: 58, hills: hills, seed: 24)
        let k: CGFloat = band.unit * 1.2
        let base: CGFloat = band.H + band.ground * 0.3
        Art.group(&context, x: 216, y: base, scale: k) { g in
            let d = Dome(cx: 90, baseY: 0, radius: 210, rise: 190)
            castShadow(&g, 130, 20, length: 300, alpha: 0.3)
            snowWallBack(&g, d, courses: 2)
            Art.group(&g, x: 108, y: 22) { m in
                grandfather(&m, pose: .reach, look: CGPoint(x: -0.6, y: 0.4), mouth: .smile)
                let hand = grandfatherHand(.reach)
                Art.group(&m, x: hand.x, y: hand.y, rotate: -0.3) { n in
                    snowKnife(&n, length: 46)
                }
                Art.fill(&m, Art.circle(hand.x, hand.y, 6), Kit.personTone(parkaBlue, 0.7))
            }
            snowWall(&g, d, courses: 2, blockLength: 74)
            // The pat of soft snow under her mitts, then Elisapie.
            var pat = Path()
            pat.addEllipse(in: CGRect(x: -102, y: -52, width: 26, height: 20))
            pat.addEllipse(in: CGRect(x: -108, y: -38, width: 14, height: 11))
            Art.fill(&g, pat, Color.white)
            castShadow(&g, -60, 28, length: 64)
            crumbHeap(&g, cx: -8, baseY: 34, width: 44, seed: 26)
            Art.group(&g, x: -62, y: 26) { e in
                elisapie(&e, pose: .carry, look: CGPoint(x: -0.6, y: 0.1), mouth: .smile, tongue: true)
            }
        }
        ArtStyle.finish(&context, size)
    }

    // MARK: Scene 4: the night

    /// The round snow house glows gold from inside in the pale blue dusk; the door is a
    /// bright gold shape low in the wall and the sled rests beside it.
    static func nightFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let hills: [(CGFloat, CGFloat, CGFloat)] = [(0.0, 0.34, 20), (0.7, 1.06, 26)]
        foldedLand(&context, band, dusk: true, sunX: nil, hills: hills, seed: 34)
        let k: CGFloat = band.unit * 1.1
        let base: CGFloat = band.H + band.ground * 0.3
        Art.group(&context, x: 216, y: base, scale: k) { g in
            let d = Dome(cx: -16, baseY: 0, radius: 130, rise: 122)
            castShadow(&g, 10, 16, length: 250, alpha: 0.2)
            snowDome(&g, d, glow: true, blockLength: 48)
            var prints = Path()
            let steps: [(CGFloat, CGFloat)] = [(-96, 28), (-112, 34), (-132, 37), (-150, 44)]
            for step in steps {
                prints.addEllipse(in: CGRect(x: step.0 - 5, y: step.1 - 2.4, width: 10, height: 4.8))
            }
            Art.fill(&g, prints, Art.color(snowLine, 0.55))
            castShadow(&g, 112, 26, length: 110, alpha: 0.22)
            Art.group(&g, x: 108, y: 24, scale: 0.6) { s in
                qamutiik(&s)
            }
            Art.group(&g, x: -120, y: 2, rotate: CGFloat.pi + 0.1) { n in
                snowKnife(&n, length: 36)
            }
        }
        ArtStyle.finish(&context, size, wash: 0.06, vignette: 0.1)
    }
}
