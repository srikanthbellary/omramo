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
        Art.fill(&context, Art.ellipse(x, -3, 7.4, 8.6), .white)
        Art.fill(&context, Art.circle(x + lookX, -2.4 + lookY, 5.2), Art.color(0x2B160D))
        Art.fill(&context, Art.circle(x + lookX - 1.8, -4.6 + lookY, 1.9), .white)
        Art.fill(&context, Art.circle(x + lookX + 2, -0.4 + lookY, 0.9), Art.color(0xFFFFFF, 0.8))
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
        Art.stroke(&context, Art.svg("M-37,-6 q5,3 3,9"), earLine, width: 1.8)
        Art.fill(&context, Art.circle(33, -3, 13), fur)
        Art.fill(&context, Art.circle(33, -3, 8), earPink)
        Art.stroke(&context, Art.svg("M37,-6 q-5,3 -3,9"), earLine, width: 1.8)

        // Tuft.
        Art.fill(&context, Art.svg("M-6,-33 C-8,-42 -2,-46 -1,-40 C1,-48 8,-46 6,-38 C11,-43 14,-38 10,-32Z"), furDark)

        Art.fillRadial(&context, Art.ellipse(0, 0, 34, 31.5), furStops(), center: CGPoint(x: -8.2, y: -12.6), radius: 52)
        let chinShade = Art.svg("M-30,6 C-26,22 -12,30 0,30 C12,30 26,22 30,6 C24,26 -24,26 -30,6Z")
        Art.fill(&context, chinShade, furDark.opacity(0.35))
        let face = Art.svg("M0,-15 C-9,-27 -30,-19 -27,0 C-25,17 -12,25 0,25 C12,25 25,17 27,0 C30,-19 9,-27 0,-15Z")
        Art.fillRadial(&context, face, faceStops(), center: CGPoint(x: -2.7, y: -5.5), radius: 38)

        if blush {
            let pink = Art.color(0xFF8A7A, 0.5)
            Art.fill(&context, Art.ellipse(-17, 9, 5.5, 3.6), pink)
            Art.fill(&context, Art.ellipse(17, 9, 5.5, 3.6), pink)
        }
        monkeyEye(&context, -11, lookX, lookY)
        monkeyEye(&context, 11, lookX, lookY)

        // Brows and nose.
        Art.stroke(&context, Art.svg("M-17,-14 q6,-4 11,-1"), furDark, width: 2)
        Art.stroke(&context, Art.svg("M6,-15 q6,-3 11,1"), furDark, width: 2)
        Art.stroke(&context, Art.svg("M-2.6,7 q2.6,2.2 5.2,0"), Art.color(0x8A4A2C), width: 2)

        switch mouth {
        case .smile:
            Art.stroke(&context, Art.svg("M-9,12.5 Q0,21 9,12.5"), mouthBrown, width: 2.4)
        case .grin:
            Art.fill(&context, Art.svg("M-11,11 Q0,25 11,11 Q0,15 -11,11Z"), mouthBrown)
            Art.fill(&context, Art.svg("M-7,13.2 Q0,16 7,13.2 L6,15 Q0,18 -6,15Z"), .white)
        case .open:
            Art.fill(&context, Art.svg("M-8,11 Q0,8 8,11 Q9,24 0,25 Q-9,24 -8,11Z"), mouthBrown)
            Art.fill(&context, Art.ellipse(0, 21, 4.6, 3), Art.color(0xF2788A))
        case .oh:
            Art.fill(&context, Art.ellipse(0, 16, 4.6, 5.6), mouthBrown)
        case .smirk:
            Art.stroke(&context, Art.svg("M-7,14 Q2,19 10,11"), mouthBrown, width: 2.4)
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
    /// the lines of age.
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
        elder: Bool = false
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
        Art.stroke(&context, scutes, skin.line, width: 0.8)

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

        // Mouth line, teeth, nostril.
        Art.stroke(&context, Art.svg("M-3,7 C30,8 70,8.5 94,7 C100,6 104,2 106,-3"), skin.jaw, width: 2)
        var teeth = Path()
        var tx: CGFloat = 8
        while tx < 82 {
            let ty = 6 - tx * 0.012
            teeth.move(to: CGPoint(x: tx, y: ty))
            teeth.addLine(to: CGPoint(x: tx + 3.2, y: ty + 6.5))
            teeth.addLine(to: CGPoint(x: tx + 6.4, y: ty))
            teeth.closeSubpath()
            tx += 9
        }
        Art.fill(&context, teeth, .white)
        if tooth {
            let fang = Art.svg("M22,8.5 l3.5,-8 l3.5,8Z")
            Art.fill(&context, fang, .white)
            Art.stroke(&context, fang, Art.color(0xDCE8C0), width: 0.5)
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

        // Eye.
        Art.fill(&context, Art.svg("M78,-17 C82,-30 104,-34 112,-20 C104,-9 84,-8 78,-17Z"), skin.socket)
        if lid == .shut {
            Art.fill(&context, Art.circle(95, -19, 9), skin.socket)
        } else {
            Art.fill(&context, Art.circle(95, -19, 9), skin.eye)
            Art.stroke(&context, Art.circle(95, -19, 9), skin.line, width: 1.4)
            Art.fill(&context, Art.ellipse(95 + lookX, -18.5 + lookY, 2.8, 6), Art.color(0x1D2B1D))
            Art.fill(&context, Art.circle(93 + lookX, -22 + lookY, 1.7), .white)
        }
        switch lid {
        case .sleepy:
            Art.fill(&context, Art.svg("M84,-22 Q94,-33 106,-23 Q95,-25 84,-22Z"), skin.scute)
            Art.stroke(&context, Art.svg("M84.5,-21 Q95,-25 105.5,-22"), skin.line, width: 1.6)
        case .sly:
            Art.fill(&context, Art.svg("M83,-26 Q96,-34 107,-22 Q96,-27 83,-24Z"), skin.scute)
            Art.stroke(&context, Art.svg("M83.5,-24 Q96,-27 106,-21"), skin.line, width: 1.8)
        case .wide:
            break
        case .shut:
            Art.stroke(&context, Art.svg("M85,-19 Q95,-13 105,-19"), skin.line, width: 2.2)
        }
        if elder {
            // A heavy brow and the creases of age under the eye.
            Art.fill(&context, Art.svg("M77,-23 Q94,-39 114,-22 Q112,-27 106,-28 Q94,-32 80,-21Z"), skin.line)
            var creases = Path()
            creases.addPath(Art.svg("M82,-8 Q94,-3 108,-9"))
            creases.addPath(Art.svg("M86,-4 Q95,0 104,-4"))
            creases.addPath(Art.svg("M112,-14 Q118,-10 124,-12"))
            Art.stroke(&context, creases, skin.line.opacity(0.6), width: 1.3)
        }
    }
}
