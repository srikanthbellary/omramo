import SwiftUI
import OmramoCore

// The figures of "The Story of Urashima Taro": the tortoise, Urashima, Princess Otohime, the
// boat and the lacquer box.
//
// Urashima and Otohime stand about three heads tall (docs/ART_DIRECTION.md §4), like the
// people of the other two stories. Their bodies are drawn for that proportion (a short coat
// and skirt, short robe, hands and feet in scale); the heads are not simply enlarged. They stay
// grown-up in feel: plain dark eyes with one catchlight, level brows, a small mouth, restrained
// colour. One light from the upper left models every form.

extension UrashimaArt {
    // MARK: - Tortoise

    /// The tortoise (design `tortoise`): an old sea tortoise trailing a seaweed tail. Faces left;
    /// the origin is the shell centre at the waterline.
    static func tortoise(
        _ context: inout GraphicsContext,
        tail: Bool = true,
        lookX: CGFloat = 0,
        lookY: CGFloat = 0,
        smile: Bool = true
    ) {
        if tail {
            for i in 0..<5 {
                let f = CGFloat(i)
                var strand = Path()
                strand.move(to: pt(34, -4 + f * 2))
                strand.addCurve(to: pt(92, -2 + f * 5), control1: pt(54, -10 + f * 4), control2: pt(70, 6 + f * 3))
                strand.addCurve(to: pt(124, f * 5), control1: pt(104, -6 + f * 4), control2: pt(112, 4 + f * 3))
                let tint = i % 2 == 1 ? Art.color(0x3F8F5E, 0.9) : Art.color(0x2F7A52, 0.9)
                Art.stroke(&context, strand, tint, width: 2.2)
            }
        }
        // Flippers.
        Art.fill(&context, Art.svg("M-30,6 C-44,10 -52,20 -50,26 C-40,26 -30,18 -24,10Z"), Art.color(0x6E9A54))
        Art.fill(&context, Art.svg("M20,8 C30,16 34,24 30,28 C22,26 14,18 12,10Z"), Art.color(0x5E8A4A))
        // Neck and head.
        let skinStops: [(Color, CGFloat)] = [(Art.color(0xA9C873), 0), (Art.color(0x6E9A54), 1)]
        Art.fillLinear(
            &context,
            Art.svg("M-30,-2 C-42,-8 -48,-22 -50,-34 C-44,-40 -36,-38 -34,-30 C-32,-20 -26,-12 -20,-8Z"),
            skinStops, from: pt(-50, -40), to: pt(-20, -2)
        )
        Art.stroke(&context, Art.svg("M-42,-18 q5,-1 8,2 M-44,-26 q5,-2 9,1"), Art.color(0x4F7A3E, 0.5), width: ArtStyle.detailLine)
        Art.group(&context, x: -52, y: -40, rotate: rad(-14)) { g in
            Art.fillLinear(&g, Art.ellipse(0, 0, 14, 11), skinStops, from: pt(-14, -11), to: pt(14, 11))
            ArtStyle.rimLight(&g, 0, 0, 12, alpha: 0.25)
        }
        // The shared eye, with its white, at the modest size of design screen 05. The design's
        // iris rests one unit toward the nose; `lookX` / `lookY` move it from there.
        let eyeLook = CGPoint(x: (lookX - 1) / 1.44, y: lookY / 1.44)
        ArtStyle.eye(&context, -56, -43, 4.2, look: eyeLook, iris: Art.color(0x1B2B1D), showsWhite: true)
        ArtStyle.cheek(&context, -49, -35.5, 3.6, alpha: 0.3)
        Art.stroke(&context, Art.svg("M-61,-48 q5,-4 10,-1"), Art.color(0x3F6B35), width: ArtStyle.detailLine)
        if smile {
            Art.stroke(&context, Art.svg("M-65,-36 q5,5 12,2"), Art.color(0x2F5A3A), width: ArtStyle.detailLine)
        }
        Art.fill(&context, Art.circle(-64.5, -41, 0.9), Art.color(0x2F5A3A))
        // Shell.
        let shell = Art.svg("M-38,4 C-38,-22 -16,-34 4,-34 C24,-34 40,-20 40,4 C24,10 -22,10 -38,4Z")
        Art.fillLinear(&context, shell, [(Art.color(0x7FB05A), 0), (Art.color(0x3F6B45), 1)], from: pt(0, -34), to: pt(0, 9))
        let centres: [(CGFloat, CGFloat)] = [(-14, -16), (6, -18), (-24, -6), (-4, -7), (16, -8), (-14, 2), (6, 1), (26, 0)]
        var hexes = Path()
        for (hx, hy) in centres {
            hexes.move(to: pt(hx - 7, hy))
            hexes.addLine(to: pt(hx - 3.5, hy - 5))
            hexes.addLine(to: pt(hx + 3.5, hy - 5))
            hexes.addLine(to: pt(hx + 7, hy))
            hexes.addLine(to: pt(hx + 3.5, hy + 5))
            hexes.addLine(to: pt(hx - 3.5, hy + 5))
            hexes.closeSubpath()
        }
        let hexPath = hexes
        Art.clipped(&context, to: shell) { g in
            Art.stroke(&g, hexPath, Art.color(0x2F5A3A, 0.7), width: ArtStyle.detailLine)
            // The key light on the upper left of the shell, the core shadow on its lower right.
            Art.stroke(&g, Art.svg("M-34,-8 C-24,-26 -6,-32 8,-31"), Art.color(0xC7E88A, 0.4), width: 4)
            Art.glow(&g, -16, -24, 26, ArtStyle.warmLight, alpha: 0.22)
            Art.glow(&g, 30, 2, 30, ArtStyle.coolShade, alpha: 0.22)
        }
        Art.fill(
            &context,
            Art.svg("M-38,4 C-22,10 24,10 40,4 C40,8 38,10 34,11 C16,15 -16,15 -34,11 C-37,10 -38,8 -38,4Z"),
            Art.color(0xE8C76A)
        )
    }

    // MARK: - Urashima

    enum Rod {
        /// No rod.
        case absent
        /// Held out over the water, as in the design.
        case cast
        /// Resting on his shoulder (the portrait).
        case shoulder
    }

    enum Pose {
        case standing
        case kneeling
    }

    /// Urashima's head, centred on the face: about 26 × 28 units, plus the topknot.
    /// `frontal: true` is the face chip; false is the head as it sits on the figure.
    static func urashimaHead(_ context: inout GraphicsContext, frontal: Bool) {
        let earTint = Art.color(0xEBC09A)
        if frontal {
            Art.fill(&context, Art.ellipse(-12.8, 2.5, 2.4, 3.4), earTint)
        }
        Art.fill(&context, Art.ellipse(12.8, 2.5, 2.4, 3.4), earTint)
        // A soft jaw rather than a plain ellipse.
        let face = Art.svg("M-13,-2 C-13,-10 -7,-14 0,-14 C7,-14 13,-10 13,-2 C13,6 8,14 0,14 C-8,14 -13,6 -13,-2Z")
        Art.fill(&context, face, skin)
        ArtStyle.form(&context, face, bounds: CGRect(x: -13, y: -14, width: 26, height: 28), light: 0.22, shade: 0.1)
        // Hair: a full fringe swept to one side, and the topknot.
        Art.fill(
            &context,
            Art.svg("M-13,-2 C-15,-14 -6,-18 2,-17 C10,-17 15,-10 13,0 C10,-8 4,-11 -3,-10 C-8,-9 -11,-6 -13,-2Z"),
            ink
        )
        Art.fill(&context, Art.svg("M1,-17 C0,-24 5,-27 8,-23 C9,-20 6,-17 4,-16Z"), ink)
        Art.stroke(&context, Art.svg("M-9,-13 C-5,-16 1,-16.6 6,-15"), Art.color(0x5A5678, 0.7), width: 1.2)
        // The shared face: plain dark eyes with an upper-left catchlight, level brows, a quiet
        // blush, one round-capped mouth in a darker tone of the skin.
        let lips = Art.color(0xB5533A)
        let brow = Art.color(0x3A3144, 0.6)
        if frontal {
            ArtStyle.cheek(&context, -7.5, 5.5, 3.2, alpha: 0.28)
            ArtStyle.cheek(&context, 7.5, 5.5, 3.2, alpha: 0.28)
            Art.stroke(&context, Art.svg("M-7.4,-2.6 q2.4,-1 4.6,-0.2 M2.4,-2.8 q2.4,-0.8 4.6,0.2"), brow, width: 1.1)
            ArtStyle.eye(&context, -5, 1, 1.9, showsWhite: false)
            ArtStyle.eye(&context, 4.5, 1, 1.9, showsWhite: false)
            ArtStyle.smile(&context, 0, 7.2, width: 7, curve: 1.3, color: lips)
        } else {
            Art.stroke(&context, Art.line(1.5, -18, 7.5, -18), red, width: ArtStyle.detailLine, cap: .butt)
            ArtStyle.cheek(&context, -8.5, 5.5, 3.2, alpha: 0.28)
            ArtStyle.cheek(&context, 6, 6, 3.2, alpha: 0.28)
            Art.stroke(&context, Art.svg("M-8.8,-2.6 q2.4,-1 4.6,-0.2 M0.4,-2.4 q2.4,-0.8 4.6,0.2"), brow, width: 1.1)
            ArtStyle.eye(&context, -6.5, 1, 1.9, showsWhite: false)
            ArtStyle.eye(&context, 2.5, 1.5, 1.9, showsWhite: false)
            ArtStyle.smile(&context, -2, 7.2, width: 7, curve: 1.3, color: lips)
        }
    }

    /// Urashima Taro. Faces left; the origin is at his feet (or, kneeling, the ground under
    /// him). Standing he is about 104 units tall to the crown of his head (three heads of 35),
    /// 120 to the tip of the topknot; his face is about 87 units above his feet (76 kneeling).
    static func urashima(
        _ context: inout GraphicsContext,
        rod: Rod = .cast,
        pose: Pose = .standing,
        holdsBox: Bool = false,
        hat: Bool = false
    ) {
        let legSkin = Art.color(0xF2C9A0)
        let footSkin = Art.color(0xE0B088)
        switch pose {
        case .standing:
            if rod == .cast {
                Art.stroke(&context, Art.line(-13, -52, -104, -120), Art.color(0x8A6A3A), width: ArtStyle.contourLine)
                Art.stroke(&context, Art.svg("M-104,-120 C-112,-72 -118,-26 -120,22"), Art.color(0xFFFFFF, 0.8), width: 0.8, cap: .butt)
            }
            Art.stroke(&context, Art.svg("M-7,-16 L-8,-3 M6,-16 L7,-3"), legSkin, width: 7)
            Art.fill(&context, Art.ellipse(-10.5, -1.8, 6.5, 3), footSkin)
            Art.fill(&context, Art.ellipse(4.5, -1.8, 6.5, 3), footSkin)
            urashimaUpper(&context, rod: rod, reach: false, holdsBox: holdsBox, hat: hat)
        case .kneeling:
            Art.stroke(&context, Art.svg("M2,-5 L22,-4"), legSkin, width: 7)
            Art.fill(&context, Art.ellipse(27, -3, 5.5, 3), footSkin)
            Art.group(&context, y: 11) { g in
                urashimaUpper(&g, rod: rod, reach: !holdsBox, holdsBox: holdsBox, hat: hat)
            }
        }
    }

    /// Coat, straw skirt, arms and head: everything above the knees.
    static func urashimaUpper(_ context: inout GraphicsContext, rod: Rod, reach: Bool, holdsBox: Bool, hat: Bool) {
        let handSkin = Art.color(0xF2C9A0)
        if rod == .shoulder {
            Art.stroke(&context, Art.line(10, -38, 32, -124), Art.color(0x8A6A3A), width: ArtStyle.contourLine)
            Art.stroke(&context, Art.svg("M32,-124 q7,18 2,42"), Art.color(0x7C8DA6, 0.7), width: 0.7, cap: .butt)
        }
        // Straw skirt, flaring to a soft hem.
        for i in 0..<15 {
            let x: CGFloat = -15 + CGFloat(i) * 2.14
            let tint = i % 2 == 1 ? Art.color(0xE9C877) : Art.color(0xD4A94F)
            Art.stroke(&context, Art.line(x * 0.7, -39, x * 1.25, -14), tint, width: 2.8)
        }
        Art.stroke(&context, Art.svg("M-18,-22 C-8,-19 8,-19 18,-22"), Art.color(0xB98F3F, 0.45), width: ArtStyle.detailLine)
        // Happi coat: one soft shape, modelled by the light.
        let coat = Art.svg("M-15,-71 C-19,-60 -19,-48 -17,-36 L17,-36 C19,-48 19,-60 15,-71 C7,-76 -7,-76 -15,-71Z")
        Art.fillLinear(
            &context, coat,
            [(Art.color(0x2F5FB0), 0), (Art.color(0x1B3A7A), 1)],
            from: pt(-18, -76), to: pt(18, -36)
        )
        ArtStyle.form(&context, coat, bounds: CGRect(x: -19, y: -76, width: 38, height: 40), light: 0.2, shade: 0.2)
        let pale = Art.color(0xF4F7FB)
        Art.stroke(&context, Art.svg("M-2,-74 L4,-37 M2,-74 L-6,-55"), pale, width: ArtStyle.contourLine, cap: .butt, join: .miter)
        let spots: [(CGFloat, CGFloat)] = [(-10, -63), (-11.5, -52), (10, -60), (11.5, -50), (8.5, -68)]
        var spotPath = Path()
        for (sx, sy) in spots {
            spotPath.addEllipse(in: CGRect(x: sx - 1.5, y: sy - 1.5, width: 3, height: 3))
        }
        Art.fill(&context, spotPath, pale.opacity(0.85))
        Art.stroke(&context, Art.line(-17, -42, 17, -42), red, width: 5)
        Art.stroke(&context, Art.line(-15, -43.4, 2, -43.4), Art.color(0xFF8A7A, 0.6), width: 1.2)
        // Arms and hands.
        if holdsBox {
            Art.stroke(&context, Art.svg("M-13,-66 C-21,-62 -26,-56 -28,-50"), coatBlue, width: 9)
            Art.stroke(&context, Art.svg("M13,-66 C16,-56 7,-48 -8,-47"), coatBlue, width: 9)
            Art.group(&context, x: -21, y: -41, scale: 0.26) { g in
                lacquerBox(&g, wisp: false, shadow: false)
            }
            Art.fill(&context, Art.circle(-34, -47, 4.2), handSkin)
            Art.fill(&context, Art.circle(-8, -47, 4.4), handSkin)
        } else {
            if reach {
                Art.stroke(&context, Art.svg("M-13,-66 C-23,-60 -29,-52 -31,-43"), coatBlue, width: 9)
                Art.fill(&context, Art.circle(-31, -40.5, 4.4), handSkin)
            } else {
                Art.stroke(&context, Art.svg("M-13,-66 C-21,-62 -23,-55 -18,-51"), coatBlue, width: 9)
                Art.fill(&context, Art.circle(-16.5, -50, 4.4), handSkin)
            }
            Art.stroke(&context, Art.svg("M13,-66 C21,-59 21,-51 15,-47"), coatBlue, width: 9)
            Art.fill(&context, Art.circle(14, -45.5, 4.4), handSkin)
        }
        // Head: a third of his height. The chin rests on the collar.
        let headScale: CGFloat = 1.25
        let headY: CGFloat = -86
        Art.group(&context, x: -1, y: headY, rotate: rad(-6), scale: headScale) { g in
            urashimaHead(&g, frontal: false)
        }
        if hat {
            // The straw hat sits on the head, in the head's own space.
            let brim = Art.svg("M-21,-8 L0,-26 L21,-6 C7,-12 -7,-12 -21,-8Z")
            Art.group(&context, x: -1, y: headY, scale: headScale) { g in
                Art.fill(&g, brim, Art.color(0xE9C877))
                Art.stroke(&g, brim, Art.color(0xC99A3F), width: ArtStyle.detailLine)
                Art.stroke(&g, Art.svg("M-17,-10 L0,-24"), ArtStyle.warmLight.opacity(0.5), width: 1.2)
            }
        }
    }

    // MARK: - Boat

    /// The wooden fishing boat (design `boat`). The origin is the centre of the waterline.
    static func boat(_ context: inout GraphicsContext) {
        let hull = Art.svg("M-92,-22 C-70,-10 -40,-6 0,-6 C44,-6 76,-12 98,-26 C92,-4 78,10 60,12 L-52,12 C-70,10 -86,-4 -92,-22Z")
        Art.fillLinear(
            &context, hull,
            [(Art.color(0xC08A54), 0), (Art.color(0x7A4E2E), 1)],
            from: pt(0, -26), to: pt(0, 12)
        )
        ArtStyle.form(&context, hull, bounds: CGRect(x: -92, y: -26, width: 190, height: 38), light: 0.16, shade: 0.26)
        Art.fill(
            &context,
            Art.svg("M-92,-22 C-70,-10 -40,-6 0,-6 C44,-6 76,-12 98,-26 L96,-20 C74,-6 44,0 0,0 C-40,0 -68,-4 -90,-16Z"),
            Art.color(0xE2B27A)
        )
        Art.stroke(
            &context,
            Art.svg("M-80,-4 C-40,4 40,4 84,-8 M-66,6 C-30,10 30,10 70,2"),
            Art.color(0x6A4326, 0.5), width: ArtStyle.detailLine
        )
        // The key light along the upper-left gunwale.
        Art.stroke(&context, Art.svg("M-90,-20 C-70,-9 -40,-5 0,-5"), ArtStyle.warmLight.opacity(0.5), width: ArtStyle.detailLine)
        Art.stroke(&context, Art.line(98, -26, 108, -35), Art.color(0x8A5A34), width: 4)
    }

    /// The straw fish basket that sits in the boat.
    static func basket(_ context: inout GraphicsContext) {
        Art.fill(&context, Art.svg("M-10,0 C-12,-12 12,-12 10,0Z"), Art.color(0xC99A3F))
        Art.stroke(&context, Art.svg("M-10,0 h20 M-8,-5 h16"), Art.color(0x8A6A2A, 0.8), width: ArtStyle.detailLine)
    }

    /// Urashima standing in his boat with his rod (the group of design `seaScene`).
    /// The origin is the boat's waterline centre; his face is about 94 units above it.
    static func boatWithUrashima(_ context: inout GraphicsContext, tortoiseAboard: Bool = false) {
        Art.group(&context, x: -10, y: -8) { g in
            urashima(&g, rod: .cast)
        }
        Art.group(&context, x: 46, y: -12) { g in
            basket(&g)
        }
        if tortoiseAboard {
            Art.group(&context, x: -52, y: -12, scale: 0.6) { g in
                tortoise(&g, tail: false, lookX: 1.5, lookY: -1.5)
            }
        }
        boat(&context)
    }

    /// Urashima on the tortoise's back, heading right (the rider of design `palaceScene`).
    /// The origin is the tortoise's shell centre; his face is about 90 units above it.
    static func rider(_ context: inout GraphicsContext, seated: Bool) {
        Art.group(&context, x: 6, y: -30, scale: 0.8, scaleX: -1) { g in
            urashima(&g, rod: .absent, pose: seated ? .kneeling : .standing)
        }
        Art.group(&context, scaleX: -1) { g in
            tortoise(&g)
        }
    }

    // MARK: - Otohime

    /// Princess Otohime's head, centred on the face.
    static func otohimeHead(_ context: inout GraphicsContext) {
        // Two looped knots of hair behind the crown.
        Art.stroke(&context, Art.ellipse(-6, -19, 4.5, 6.5), ink, width: 2.6)
        Art.stroke(&context, Art.ellipse(6, -19, 4.5, 6.5), ink, width: 2.6)
        let face = Art.svg("M-12,-1 C-12,-9 -7,-13 0,-13 C7,-13 12,-9 12,-1 C12,6 7,13 0,13 C-7,13 -12,6 -12,-1Z")
        Art.fill(&context, face, Art.color(0xF8DCC0))
        ArtStyle.form(&context, face, bounds: CGRect(x: -12, y: -13, width: 24, height: 26), light: 0.2, shade: 0.08)
        Art.fill(
            &context,
            Art.svg("M-12.6,1 C-15,-13 -7,-17.5 0,-17 C7,-17.5 15,-13 12.6,1 C11,-6 6,-10 0,-11 C-6,-10 -11,-6 -12.6,1Z"),
            ink
        )
        Art.fill(&context, Art.svg("M-12.8,-2 C-14,6 -13.5,13 -12,18 L-9.6,18 C-10.6,12 -10.8,5 -10.4,-3Z"), ink)
        Art.fill(&context, Art.svg("M12.8,-2 C14,6 13.5,13 12,18 L9.6,18 C10.6,12 10.8,5 10.4,-3Z"), ink)
        Art.stroke(&context, Art.svg("M-9,-13.4 C-5,-16 2,-16.4 7,-14.6"), Art.color(0x5A5678, 0.7), width: 1.2)
        // Crown ornament.
        Art.fill(&context, Art.svg("M-7,-15 L-5,-21 L-2.5,-17 L0,-23 L2.5,-17 L5,-21 L7,-15Z"), gold)
        Art.fill(&context, Art.circle(0, -18.2, 1.3), red)
        Art.fill(&context, Art.circle(-8.6, -13, 1.2), gold)
        Art.fill(&context, Art.circle(8.6, -13, 1.2), gold)
        // A composed face, built like every face in the app: plain dark eyes with an upper-left
        // catchlight, a quiet blush, one small round-capped mouth.
        ArtStyle.cheek(&context, -6.8, 5.4, 3, alpha: 0.28)
        ArtStyle.cheek(&context, 6.8, 5.4, 3, alpha: 0.28)
        Art.stroke(&context, Art.svg("M-7,-1.6 q2.2,-1 4.2,-0.4 M2.8,-2 q2.2,-0.6 4.2,0.4"), Art.color(0x3A3144, 0.5), width: 1)
        ArtStyle.eye(&context, -4.8, 1.8, 1.7, showsWhite: false)
        ArtStyle.eye(&context, 4.8, 1.8, 1.7, showsWhite: false)
        ArtStyle.smile(&context, 0, 7.4, width: 5, curve: 1, color: Art.color(0xC8463C))
    }

    /// Princess Otohime in layered robes of coral, white and jade. The origin is the centre of
    /// her hem on the ground. She is about 105 units tall to the crown of her head (three
    /// heads of 35), 121 to the top of her hair knots; her face is about 87 units above the hem.
    static func otohime(_ context: inout GraphicsContext) {
        let jade: [(Color, CGFloat)] = [(Art.color(0x6CC7B3), 0), (Art.color(0x2E8F86), 1)]
        // Long hair down her back.
        Art.fill(
            &context,
            Art.svg("M-15,-92 C-25,-76 -27,-52 -25,-26 C-16,-22 16,-22 25,-26 C27,-52 25,-76 15,-92Z"),
            ink
        )
        // Outer robe, its hem trailing a little behind her.
        let robe = Art.svg("M-19,-48 C-24,-30 -30,-12 -36,-1 C-18,5 22,6 46,2 C36,-6 26,-28 19,-48Z")
        Art.fillLinear(
            &context, robe,
            [(Art.color(0xF58A7A), 0), (Art.color(0xDE5F52), 1)],
            from: pt(0, -48), to: pt(0, 4)
        )
        ArtStyle.form(&context, robe, bounds: CGRect(x: -36, y: -48, width: 82, height: 54), light: 0.2, shade: 0.2)
        Art.stroke(&context, Art.svg("M-34,-3 C-18,3 22,4 44,0"), Art.color(0xFFFFFF, 0.8), width: ArtStyle.contourLine)
        // White under-robe showing at the front.
        Art.fill(&context, Art.svg("M-5,-48 C-7,-30 -9,-12 -10,3 L11,3.6 C9,-12 7,-30 6,-48Z"), Art.color(0xFBF6EE))
        Art.stroke(&context, Art.svg("M-10,3 C-9,-12 -7,-30 -5,-48 M11,3.6 C9,-12 7,-30 6,-48"), Art.color(0x2E8F86, 0.4), width: ArtStyle.detailLine)
        // Hands, just showing under the cuffs.
        let handSkin = Art.color(0xF2CFB0)
        Art.fill(&context, Art.ellipse(-26, -27.5, 3.6, 3), handSkin)
        Art.fill(&context, Art.ellipse(26, -27.5, 3.6, 3), handSkin)
        // Sleeves.
        let leftSleeve = Art.svg("M-13,-72 C-26,-67 -34,-52 -36,-30 C-30,-25 -21,-27 -16,-33 C-16,-45 -12,-56 -9,-64Z")
        let rightSleeve = Art.svg("M13,-72 C26,-67 34,-52 36,-30 C30,-25 21,-27 16,-33 C16,-45 12,-56 9,-64Z")
        Art.fillLinear(&context, leftSleeve, jade, from: pt(-36, -72), to: pt(-12, -28))
        Art.fillLinear(&context, rightSleeve, jade, from: pt(12, -72), to: pt(36, -28))
        ArtStyle.form(&context, leftSleeve, bounds: CGRect(x: -36, y: -72, width: 27, height: 47), light: 0.24, shade: 0.1)
        ArtStyle.form(&context, rightSleeve, bounds: CGRect(x: 9, y: -72, width: 27, height: 47), light: 0.08, shade: 0.24)
        Art.stroke(&context, Art.svg("M-36,-30 C-30,-25 -21,-27 -16,-33 M36,-30 C30,-25 21,-27 16,-33"), Art.color(0xFBF6EE), width: ArtStyle.contourLine)
        // Bodice.
        Art.fillLinear(
            &context,
            Art.svg("M-14,-72 C-18,-64 -18,-56 -16,-46 L16,-46 C18,-56 18,-64 14,-72 C7,-76 -7,-76 -14,-72Z"),
            jade, from: pt(0, -76), to: pt(0, -46)
        )
        Art.stroke(&context, Art.svg("M-7,-75 L0,-61 L7,-75"), Art.color(0xFBF6EE), width: 3, cap: .butt, join: .miter)
        Art.stroke(&context, Art.svg("M-4,-75 L0,-66 L4,-75"), Art.color(0xF58A7A), width: ArtStyle.detailLine, cap: .butt, join: .miter)
        // Sash.
        Art.fill(&context, Art.svg("M-3,-45 L-6,-22 L-1,-22 L0,-45Z M3,-45 L6,-25 L1,-25 L0,-45Z"), Art.color(0xF7DE9A))
        Art.fill(&context, Art.rect(-17, -55, 34, 10, radius: 2), gold)
        Art.stroke(&context, Art.line(-17, -50, 17, -50), red, width: 1.6, cap: .butt)
        Art.fill(&context, Art.circle(0, -50, 2.4), red)
        // Hair falling forward over each shoulder.
        Art.fill(&context, Art.svg("M-13,-82 C-17,-72 -18,-60 -16,-48 L-12.5,-48 C-13,-60 -12,-72 -10,-80Z"), ink)
        Art.fill(&context, Art.svg("M13,-82 C17,-72 18,-60 16,-48 L12.5,-48 C13,-60 12,-72 10,-80Z"), ink)
        // Neck and head: a third of her height. The chin rests on the collar.
        Art.fill(&context, Art.rect(-3.5, -77, 7, 7), Art.color(0xF2CFB0))
        Art.group(&context, y: -87, scale: 1.35) { g in
            otohimeHead(&g)
        }
    }

    // MARK: - The tamate-bako

    /// The lacquer box (design `lacquerBox`). The origin is the centre of the box's base.
    static func lacquerBox(
        _ context: inout GraphicsContext,
        wisp: Bool = true,
        wispColor: Color = UrashimaArt.white,
        shadow: Bool = true
    ) {
        if wisp {
            let curl = Art.svg("M10,-64 C-10,-84 24,-100 4,-124 C-8,-138 10,-150 4,-162")
            // A soft wisp only: pale, thin, and fading as it rises.
            Art.blurred(&context, radius: 2.5, opacity: 0.3) { g in
                Art.stroke(&g, curl, wispColor, width: 4)
            }
        }
        if shadow {
            // The contact shadow falls a little to the lower right, away from the key light.
            ArtStyle.contactShadow(&context, 5, 2, 64, 7, alpha: 0.3)
        }
        let body = Art.svg("M-52,-40 L52,-40 L50,0 L-50,0Z")
        Art.fillLinear(
            &context, body,
            [(Art.color(0x2B2338), 0), (Art.color(0x14101C), 0.5), (Art.color(0x0A0810), 1)],
            from: pt(-52, -40), to: pt(52, 0)
        )
        let lid = Art.rect(-56, -58, 112, 18, radius: 2)
        Art.fillLinear(
            &context, lid,
            [(Art.color(0x3A3048), 0), (Art.color(0x1A1524), 0.4), (Art.color(0x0E0B16), 1)],
            from: pt(-56, 0), to: pt(56, 0)
        )
        // Lacquer takes the light softly: a warm sheen on the upper left of lid and body.
        ArtStyle.form(&context, lid, bounds: CGRect(x: -56, y: -58, width: 112, height: 18), light: 0.2, shade: 0)
        ArtStyle.form(&context, body, bounds: CGRect(x: -52, y: -40, width: 104, height: 40), light: 0.12, shade: 0)
        // The lid catches the warm key light, strongest at its upper-left end.
        Art.fillLinear(
            &context, Art.rect(-54, -58, 108, ArtStyle.detailLine),
            [(ArtStyle.warmLight.opacity(0.6), 0), (ArtStyle.warmLight.opacity(0.18), 1)],
            from: pt(-56, 0), to: pt(56, 0)
        )
        // Gold maki-e: wave arcs along the base, two plum blossoms.
        var makie = Path()
        let arcCentres: [CGFloat] = [-40, -22, 22, 40]
        for ax in arcCentres {
            addArch(&makie, ax, -6, 9)
            addArch(&makie, ax, -6, 6)
            addArch(&makie, ax, -6, 3)
        }
        makie.move(to: pt(-50, -6))
        makie.addLine(to: pt(50, -6))
        Art.stroke(&context, makie, gold.opacity(0.9), width: ArtStyle.detailLine, cap: .butt)
        let blossoms: [(CGFloat, CGFloat)] = [(-38, -24), (34, -27)]
        for (bx, by) in blossoms {
            var petals = Path()
            for step in 0..<5 {
                let angle = rad(CGFloat(step) * 72)
                let px = bx + cos(angle) * 4
                let py = by + sin(angle) * 4
                petals.addEllipse(in: CGRect(x: px - 2.4, y: py - 2.4, width: 4.8, height: 4.8))
            }
            Art.fill(&context, petals, gold)
            Art.fill(&context, Art.circle(bx, by, 1.4), red)
        }
        // The red silk cord.
        Art.fill(&context, Art.rect(-6, -58, 12, 58), red)
        Art.fill(&context, Art.rect(-6, -58, 4, 58), Art.color(0xFF7A6B, 0.6))
        Art.fill(
            &context,
            Art.svg("M0,-60 C-16,-76 -30,-66 -22,-58 C-16,-54 -6,-56 0,-60 C16,-76 30,-66 22,-58 C16,-54 6,-56 0,-60Z"),
            red
        )
        Art.fill(&context, Art.circle(0, -60, 4.6), Art.color(0xB3261E))
        Art.stroke(&context, Art.svg("M-3,-58 C-12,-46 -16,-38 -20,-26 M3,-58 C12,-46 16,-38 20,-26"), red, width: ArtStyle.contourLine)
        Art.fill(&context, Art.svg("M-23,-27 l6,2 l-5,14 l-5,-2Z M23,-27 l-6,2 l5,14 l5,-2Z"), gold)
    }
}
