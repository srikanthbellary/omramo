import SwiftUI
import OmramoCore

// The Monkey and the Crocodile themselves. Ported from docs/design/source/src/lib/art-jataka.js.
//
// The Monkey is drawn around his seat: (0, 0) is where he sits, his head is near (0, −84) and
// he is about 150 units tall. The Crocodile faces left: (0, 0) is the tip of the snout, the
// tail ends near x = 356, and the waterline is at y = `waterline`.

extension JatakaArt {
    enum MonkeyPose {
        case sit, ride, wave, call
    }

    enum MonkeyMouth {
        case smile, grin, open, oh, smirk
    }

    enum CrocLid {
        case sleepy, sly, wide, shut
    }

    static let fur = Art.color(0xB5683A)
    static let furDark = Art.color(0x7E4426)
    static let furLight = Art.color(0xD98C52)
    static let earPink = Art.color(0xEDA584)
    static let mouthBrown = Art.color(0x5A2A17)

    static func furStops() -> [(Color, CGFloat)] {
        [(furLight, 0), (fur, 0.55), (furDark, 1)]
    }

    static func faceStops() -> [(Color, CGFloat)] {
        [(Art.color(0xFFEAC4), 0), (Art.color(0xF2C68E), 1)]
    }

    // MARK: Monkey

    private static func monkeyEye(_ context: inout GraphicsContext, _ x: CGFloat, _ lookX: CGFloat, _ lookY: CGFloat) {
        // The shared eye (ArtStyle): large, with a white, catchlight on the upper left.
        // `lookX` / `lookY` are the design's offsets in head units (about −3…3).
        let look = CGPoint(x: lookX / 3, y: lookY / 3)
        ArtStyle.eye(&context, x, -3, 8.2, look: look, iris: Art.color(0x2B160D), showsWhite: true)
    }

    /// The Monkey's head, centred on (0, 0); about 92 wide with the ears and 78 tall.
    static func monkeyHead(
        _ context: inout GraphicsContext,
        lookX: CGFloat = 0,
        lookY: CGFloat = 0,
        mouth: MonkeyMouth = .smile,
        blush: Bool = true
    ) {
        let earLine = Art.color(0xC97D5E)
        Art.fill(&context, Art.circle(-33, -3, 13), fur)
        Art.fill(&context, Art.circle(-33, -3, 8), earPink)
        Art.stroke(&context, Art.svg("M-37,-6 q5,3 3,9"), earLine, width: ArtStyle.detailLine)
        Art.fill(&context, Art.circle(33, -3, 13), fur)
        Art.fill(&context, Art.circle(33, -3, 8), earPink)
        Art.stroke(&context, Art.svg("M37,-6 q-5,3 -3,9"), earLine, width: ArtStyle.detailLine)

        // Tuft.
        Art.fill(&context, Art.svg("M-6,-33 C-8,-42 -2,-46 -1,-40 C1,-48 8,-46 6,-38 C11,-43 14,-38 10,-32Z"), furDark)

        Art.fillRadial(&context, Art.ellipse(0, 0, 34, 31.5), furStops(), center: CGPoint(x: -8.2, y: -12.6), radius: 52)
        let chinShade = Art.svg("M-30,6 C-26,22 -12,30 0,30 C12,30 26,22 30,6 C24,26 -24,26 -30,6Z")
        Art.fill(&context, chinShade, furDark.opacity(0.35))
        let face = Art.svg("M0,-15 C-9,-27 -30,-19 -27,0 C-25,17 -12,25 0,25 C12,25 25,17 27,0 C30,-19 9,-27 0,-15Z")
        Art.fillRadial(&context, face, faceStops(), center: CGPoint(x: -2.7, y: -5.5), radius: 38)

        if blush {
            ArtStyle.cheek(&context, -17.5, 9.5, 7.5, alpha: 0.62)
            ArtStyle.cheek(&context, 17.5, 9.5, 7.5, alpha: 0.62)
        }
        monkeyEye(&context, -11, lookX, lookY)
        monkeyEye(&context, 11, lookX, lookY)

        // Brows and nose.
        Art.stroke(&context, Art.svg("M-17,-14.5 q6,-4 11,-1"), furDark, width: ArtStyle.contourLine)
        Art.stroke(&context, Art.svg("M6,-15.5 q6,-3 11,1"), furDark, width: ArtStyle.contourLine)
        Art.stroke(&context, Art.svg("M-2.6,7 q2.6,2.2 5.2,0"), Art.color(0x8A4A2C), width: ArtStyle.detailLine)

        switch mouth {
        case .smile:
            ArtStyle.smile(&context, 0, 12.5, width: 18, curve: 4.25, color: mouthBrown, lineWidth: ArtStyle.contourLine)
        case .grin:
            Art.fill(&context, Art.svg("M-11,11 Q0,25 11,11 Q0,15 -11,11Z"), mouthBrown)
            Art.fill(&context, Art.svg("M-7,13.2 Q0,16 7,13.2 L6,15 Q0,18 -6,15Z"), .white)
        case .open:
            Art.fill(&context, Art.svg("M-8,11 Q0,8 8,11 Q9,24 0,25 Q-9,24 -8,11Z"), mouthBrown)
            Art.fill(&context, Art.ellipse(0, 21, 4.6, 3), Art.color(0xF2788A))
        case .oh:
            Art.fill(&context, Art.ellipse(0, 16, 4.6, 5.6), mouthBrown)
        case .smirk:
            Art.stroke(&context, Art.svg("M-7,14 Q2,19 10,11"), mouthBrown, width: ArtStyle.contourLine)
        }

        // Soft light on the brow.
        let tilt = CGAffineTransform(translationX: -12, y: -22).rotated(by: deg(-24))
        Art.fill(&context, Art.ellipse(0, 0, 12, 5).applying(tilt), Art.color(0xFFFFFF, 0.16))
    }

    private static func limb(_ context: inout GraphicsContext, _ data: String, _ width: CGFloat, _ color: Color) {
        Art.stroke(&context, Art.svg(data), color, width: width)
    }

    private static func paw(_ context: inout GraphicsContext, _ x: CGFloat, _ y: CGFloat, _ r: CGFloat = 6.5) {
        Art.fill(&context, Art.circle(x, y, r), furDark)
    }

    private static func monkeyTorso(_ context: inout GraphicsContext) {
        Art.fillRadial(&context, Art.ellipse(0, -32, 21, 27), furStops(), center: CGPoint(x: -5, y: -42.8), radius: 38)
        Art.fillRadial(&context, Art.ellipse(-2, -28, 13, 18.5), faceStops(), center: CGPoint(x: -3.3, y: -33.5), radius: 23)
    }

    /// The two legs most poses share: knees out, feet resting just below the seat.
    private static func monkeySeatedLegs(_ context: inout GraphicsContext) {
        limb(&context, "M-8,-9 C-22,-10 -30,-2 -28,13", 12, fur)
        Art.fill(&context, Art.ellipse(-30, 17, 9, 6), furDark)
        limb(&context, "M10,-9 C22,-8 28,0 25,15", 12, fur)
        Art.fill(&context, Art.ellipse(24, 19, 9, 6), furDark)
    }

    /// The whole Monkey. (0, 0) is his seat.
    static func monkey(
        _ context: inout GraphicsContext,
        pose: MonkeyPose,
        lookX: CGFloat = 0,
        lookY: CGFloat = 0,
        mouth: MonkeyMouth = .smile
    ) {
        switch pose {
        case .sit:
            limb(&context, "M12,-8 C40,-2 54,30 42,64 C35,84 14,84 13,68 C12,59 22,56 26,63", 6.5, furDark)
            limb(&context, "M17,-46 C32,-44 38,-30 34,-14", 10, furDark)
            monkeyTorso(&context)
            monkeySeatedLegs(&context)
            limb(&context, "M-17,-45 C-31,-38 -38,-22 -36,-7", 10, fur)
            paw(&context, -36, -5)
            paw(&context, 34, -12)
            Art.group(&context, x: -3, y: -84, rotate: deg(-6)) { g in
                monkeyHead(&g, lookX: lookX, lookY: lookY, mouth: mouth)
            }
        case .ride:
            limb(&context, "M14,-8 C44,-10 60,-34 52,-62 C48,-76 34,-74 36,-62", 6.5, furDark)
            limb(&context, "M16,-48 C32,-56 40,-72 38,-88", 10, furDark)
            paw(&context, 38, -90)
            monkeyTorso(&context)
            limb(&context, "M-6,-9 C-20,-6 -30,2 -34,10", 12, fur)
            Art.fill(&context, Art.ellipse(-37, 13, 9, 6), furDark)
            limb(&context, "M8,-9 C20,-4 24,4 22,12", 12, fur)
            Art.fill(&context, Art.ellipse(22, 15, 9, 6), furDark)
            limb(&context, "M-17,-48 C-32,-58 -40,-74 -40,-90", 10, fur)
            paw(&context, -40, -92)
            Art.group(&context, x: -2, y: -86, rotate: deg(-4)) { g in
                monkeyHead(&g, lookX: lookX, lookY: lookY, mouth: mouth)
            }
        case .wave:
            limb(&context, "M14,-8 C46,-4 58,26 46,56 C40,72 22,70 23,58", 6.5, furDark)
            limb(&context, "M16,-46 C30,-40 34,-26 28,-14", 10, furDark)
            monkeyTorso(&context)
            monkeySeatedLegs(&context)
            limb(&context, "M-17,-48 C-36,-52 -48,-70 -50,-92", 10, fur)
            paw(&context, -50, -94, 7)
            paw(&context, 27, -12)
            Art.group(&context, x: -1, y: -86, rotate: deg(5)) { g in
                monkeyHead(&g, lookX: lookX, lookY: lookY, mouth: mouth)
            }
        case .call:
            // One hand cupped to the mouth, the other gripping a branch above.
            limb(&context, "M12,-8 C40,-2 54,30 42,64 C35,84 14,84 13,68 C12,59 22,56 26,63", 6.5, furDark)
            limb(&context, "M17,-48 C34,-56 42,-78 40,-100", 10, furDark)
            paw(&context, 40, -102)
            monkeyTorso(&context)
            monkeySeatedLegs(&context)
            Art.group(&context, x: -6, y: -84, rotate: deg(-12)) { g in
                monkeyHead(&g, lookX: lookX, lookY: lookY, mouth: mouth)
            }
            limb(&context, "M-17,-46 C-34,-46 -44,-58 -40,-68", 10, fur)
            paw(&context, -39, -70, 7)
        }
    }

    // MARK: Crocodile

    /// The colours of one crocodile.
    struct CrocSkin {
        var top: Color
        var mid: Color
        var low: Color
        var scute: Color
        var line: Color
        var socket: Color
        var sheen: Color
        var jaw: Color
        var bellyTop: Color
        var bellyLow: Color
        var eye: Color
    }

    /// The little Crocodile of the design.
    static func youngCrocSkin() -> CrocSkin {
        CrocSkin(
            top: Art.color(0x8FD05E),
            mid: Art.color(0x4FA650),
            low: Art.color(0x2C6E47),
            scute: Art.color(0x3E9150),
            line: Art.color(0x2C6E47),
            socket: Art.color(0x58AE55),
            sheen: Art.color(0xC8F28A),
            jaw: Art.color(0x235B3B),
            bellyTop: Art.color(0xF1F3B4),
            bellyLow: Art.color(0xC9DA8C),
            eye: Art.color(0xFFE46B)
        )
    }

    /// His mother: older and darker, in the teal-green family of her speech colour.
    static func motherCrocSkin() -> CrocSkin {
        CrocSkin(
            top: Art.color(0x5FA882),
            mid: Art.color(0x23796A),
            low: Art.color(0x0E5A55),
            scute: Art.color(0x17695C),
            line: Art.color(0x0A423F),
            socket: Art.color(0x2F8A72),
            sheen: Art.color(0xA8E0B4),
            jaw: Art.color(0x0A3F3C),
            bellyTop: Art.color(0xE6EBB4),
            bellyLow: Art.color(0xB4CC92),
            eye: Art.color(0xF4D04E)
        )
    }

    static let crocBody = "M-3,5 C-3,-5 5,-10 14,-9 C21,-8 23,-5 31,-5 L60,-7 C72,-9 75,-23 87,-29 C99,-34 113,-30 117,-20 C132,-18 152,-21 172,-25 C216,-33 266,-23 302,-7 C322,2 338,7 356,9 C338,22 318,30 300,36 C262,48 200,52 122,45 C80,41 30,31 0,17 C-3,14 -3,9 -3,5Z"

    /// The height of the Crocodile's back at `x`.
    static func crocBack(_ x: CGFloat) -> CGFloat {
        if x > 215 {
            let t = (x - 215) / 88
            return -30 + t * t * 24
        }
        let t = (215 - x) / 70
        return -30 + t * t * 7
    }

    /// The Crocodile, facing left, snout tip at (0, 0). Everything below `waterline` is
    /// washed with `water`, so the animal sits in the river. `elder` adds a heavy brow and
    /// the lines of age. Pass `mirrored: true` when the caller flips the animal left to right
    /// (`scaleX: -1`), so the eye's catchlight stays on the upper left of the picture.
    static func croc(
        _ context: inout GraphicsContext,
        skin: CrocSkin,
        lid: CrocLid = .sleepy,
        lookX: CGFloat = 0,
        lookY: CGFloat = 0,
        waterline: CGFloat = 12,
        water: Color = Art.color(0x19A39E),
        waterOpacity: Double = 0.78,
        tooth: Bool = true,
        elder: Bool = false,
        mirrored: Bool = false
    ) {
        // Ridges along the back, behind the body.
        var scutes = Path()
        var sx: CGFloat = 150
        while sx <= 296 {
            let y = crocBack(sx)
            scutes.move(to: CGPoint(x: sx - 7, y: y + 3))
            scutes.addLine(to: CGPoint(x: sx + 1, y: y - 9))
            scutes.addLine(to: CGPoint(x: sx + 8, y: y + 3))
            scutes.closeSubpath()
            sx += 14.5
        }
        Art.fill(&context, scutes, skin.scute)
        Art.stroke(&context, scutes, skin.line.opacity(0.6), width: ArtStyle.detailLine)

        let body = Art.svg(crocBody)
        let skinStops: [(Color, CGFloat)] = [(skin.top, 0), (skin.mid, 0.45), (skin.low, 1)]
        Art.fillLinear(&context, body, skinStops, from: CGPoint(x: 0, y: -33), to: CGPoint(x: 0, y: 48))

        Art.clipped(&context, to: body) { g in
            let jawBelly = Art.svg("M-5,8 C30,9 70,9 96,7 C110,20 60,40 0,24Z")
            let jawStops: [(Color, CGFloat)] = [(skin.bellyTop, 0), (skin.bellyLow, 1)]
            Art.fillLinear(&g, jawBelly, jawStops, from: CGPoint(x: 0, y: 7), to: CGPoint(x: 0, y: 33))
            let underside = Art.svg("M110,44 C180,52 262,50 320,28 L330,60 L100,60Z")
            let underStops: [(Color, CGFloat)] = [(skin.bellyTop.opacity(0.85), 0), (skin.bellyLow.opacity(0.85), 1)]
            Art.fillLinear(&g, underside, underStops, from: CGPoint(x: 0, y: 28), to: CGPoint(x: 0, y: 60))

            var random = ArtRandom(11)
            var spots = Path()
            for _ in 0..<16 {
                let x = 128 + rnd(&random) * 170
                let y = crocBack(x) + 9 + rnd(&random) * 16
                let rx = 3 + rnd(&random) * 4
                let ry = 2 + rnd(&random) * 2
                spots.addEllipse(in: CGRect(x: x - rx, y: y - ry, width: rx * 2, height: ry * 2))
            }
            Art.fill(&g, spots, skin.line.opacity(0.35))

            let sheen = Art.svg("M-3,-2 C30,-10 60,-12 80,-28 C100,-40 116,-30 118,-22 C160,-30 230,-36 300,-10")
            Art.stroke(&g, sheen, skin.sheen.opacity(0.45), width: 5)
            if waterOpacity > 0 {
                Art.fill(&g, Art.rect(-20, waterline, 400, 80), water.opacity(waterOpacity))
            }
        }

        // Mouth: the shared round-capped curve along the jaw, and a friendly upturned corner.
        ArtStyle.smile(&context, 44, 7, width: 94, curve: 0.75, color: skin.jaw, lineWidth: ArtStyle.contourLine)
        Art.stroke(&context, Art.svg("M91,7 C98,6.6 104,2 106,-3"), skin.jaw, width: ArtStyle.contourLine)
        // Teeth: small round bumps, comic rather than sharp.
        var teeth = Path()
        var tx: CGFloat = 9
        while tx < 82 {
            let ty = 7.2 - tx * 0.004
            teeth.move(to: CGPoint(x: tx, y: ty))
            teeth.addQuadCurve(to: CGPoint(x: tx + 5.6, y: ty), control: CGPoint(x: tx + 2.8, y: ty + 9))
            teeth.closeSubpath()
            tx += 9
        }
        Art.fill(&context, teeth, .white)
        if tooth {
            // The one tooth that sticks up over the lip, rounded too.
            Art.fill(&context, Art.svg("M21.6,7.6 q3.4,-13 6.8,0Z"), .white)
        }
        Art.fill(&context, Art.ellipse(11, -5.5, 2.6, 1.8), skin.jaw)
        if elder {
            // Bumps along an old snout.
            var bumps = Path()
            let places: [CGFloat] = [34, 48, 62]
            for x in places {
                bumps.addEllipse(in: CGRect(x: x - 3, y: -9.5, width: 6, height: 3.4))
            }
            Art.fill(&context, bumps, skin.line.opacity(0.45))
        }

        // A soft blush under the eye, quieter on the old mother.
        ArtStyle.cheek(&context, 101, -3.5, 7, alpha: elder ? 0.26 : 0.4)

        // Eye.
        Art.fill(&context, Art.svg("M78,-17 C82,-30 104,-34 112,-20 C104,-9 84,-8 78,-17Z"), skin.socket)
        if lid == .shut {
            Art.fill(&context, Art.circle(95, -19, 9), skin.socket)
        } else {
            // A yellow rim (the crocodile's own colour) around the shared eye of ArtStyle.
            Art.fill(&context, Art.circle(95, -19, 9), skin.eye)
            Art.stroke(&context, Art.circle(95, -19, 9), skin.line, width: ArtStyle.detailLine)
            let eyeRadius: CGFloat = 7.6
            let crocIris = Art.color(0x1D2B1D)
            let look = CGPoint(x: lookX / 2.5, y: lookY / 2.5)
            if mirrored {
                // Un-flip the eye so its catchlight is on the upper left of the picture.
                let flipped = CGPoint(x: -look.x, y: look.y)
                Art.group(&context, x: 95, y: -19, scaleX: -1) { e in
                    ArtStyle.eye(&e, 0, 0, eyeRadius, look: flipped, iris: crocIris, showsWhite: true)
                }
            } else {
                ArtStyle.eye(&context, 95, -19, eyeRadius, look: look, iris: crocIris, showsWhite: true)
            }
        }
        switch lid {
        case .sleepy:
            Art.fill(&context, Art.svg("M84,-22 Q94,-33 106,-23 Q95,-25 84,-22Z"), skin.scute)
            Art.stroke(&context, Art.svg("M84.5,-21 Q95,-25 105.5,-22"), skin.line, width: ArtStyle.detailLine)
        case .sly:
            Art.fill(&context, Art.svg("M83,-26 Q96,-34 107,-22 Q96,-27 83,-24Z"), skin.scute)
            Art.stroke(&context, Art.svg("M83.5,-24 Q96,-27 106,-21"), skin.line, width: ArtStyle.detailLine)
        case .wide:
            break
        case .shut:
            ArtStyle.smile(&context, 95, -19, width: 20, curve: 3, color: skin.line, lineWidth: ArtStyle.contourLine)
        }
        if elder {
            // A heavy brow and the creases of age under the eye.
            Art.fill(&context, Art.svg("M77,-23 Q94,-39 114,-22 Q112,-27 106,-28 Q94,-32 80,-21Z"), skin.line)
            var creases = Path()
            creases.addPath(Art.svg("M82,-8 Q94,-3 108,-9"))
            creases.addPath(Art.svg("M86,-4 Q95,0 104,-4"))
            creases.addPath(Art.svg("M112,-14 Q118,-10 124,-12"))
            Art.stroke(&context, creases, skin.line.opacity(0.5), width: ArtStyle.detailLine)
        }
    }
}
