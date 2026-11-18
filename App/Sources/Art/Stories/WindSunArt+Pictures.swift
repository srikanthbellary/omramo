import SwiftUI
import OmramoCore

// The tap-to-see pictures, the two character-card portraits, the three face chips and the
// cover of "The North Wind and the Sun".

// MARK: - Tap-to-see: a fable

extension WindSunArt {
    /// A storyteller of old Greece — nobody in particular, and not a portrait of Aesop.
    static func storytellerLook() -> Kit.Person {
        Kit.Person(
            age: .adult,
            skin: 0xC08A5E,
            hair: 0x6E625A,
            hairStyle: .short,
            beard: .short,
            garment: .chiton,
            cloth: 0xEFE6D2,
            trim: 0x3F7F92,
            legs: 0xC08A5E,
            showsEyeWhite: true
        )
    }

    /// The storyteller sitting (origin: the ground under his seat, the seat 34 above), facing
    /// LEFT, one open hand raised in the middle of a tale.
    static func storyteller(_ context: inout GraphicsContext) {
        let p: Kit.Person = storytellerLook()
        var rig: Kit.BodyRig = Kit.bodySitRig(p)
        rig.nearElbow = Kit.pt(-24, 4)
        rig.nearHand = Kit.pt(-34, -26)
        rig.openHand = true
        let r: Kit.BodyRig = rig
        let frame: Kit.BodyFrame = Kit.bodyFrame(p)
        Art.group(&context, scale: frame.k) { g in
            Kit.bodyFigure(&g, p, r, mirrored: false)
        }
        let c: CGPoint = Kit.bodyHeadCentre(frame, r)
        Art.group(&context, x: c.x, y: c.y, scale: frame.headScale) { g in
            Kit.personHead(&g, p, look: CGPoint(x: -0.4, y: -0.1), mouth: .open)
        }
    }

    /// "A fable": a Greek storyteller on a stone step, one hand raised, mid-tale.
    static func fablePicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let air: Kit.Stops = [(Art.color(0xFFF4D6), 0), (Art.color(0xF8E2AE), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, h), air, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: h))
        Art.glow(&context, 216, 150, 200, Art.color(0xFFFDF0), alpha: 0.6)
        // A hazy olive behind, so the step stands somewhere.
        Kit.olive(&context, x: 356, baseY: 286, height: 170, seed: 5)
        ArtStyle.atmosphere(&context, width: w, top: 60, bottom: 290, color: Art.color(0xFFF4D6), alpha: 0.45)
        let earth: Kit.Stops = [(Art.color(0xE8D4A2), 0), (Art.color(0xCDB67E), 1)]
        Kit.ground(&context, width: w, top: 284, bottom: h, stops: earth)
        // Two worn stone steps.
        ArtStyle.contactShadow(&context, 230, 298, 150, 10, alpha: 0.24)
        let lower: Path = Art.rect(100, 262, 244, 36, radius: 7)
        Kit.solid(&context, lower, Art.color(0xD8CFB8), light: 0.28, shade: 0.22, rim: 2)
        let upper: Path = Art.rect(194, 216, 136, 48, radius: 7)
        Kit.solid(&context, upper, Art.color(0xCFC5AC), light: 0.28, shade: 0.24, rim: 2)
        let cracks: Path = Art.svg("M130,270 q6,10 2,22 M300,268 q-4,12 4,24 M214,224 q5,12 0,30 M312,222 q-3,10 2,20")
        Art.stroke(&context, cracks, Art.color(0xA89E86, 0.7), width: 1.4)
        Art.stroke(&context, Art.line(104, 264, 196, 264), Color.white.opacity(0.5), width: 1.6)
        Kit.grassTuft(&context, x: 96, baseY: 300, height: 24, color: 0x8A8A4A, seed: 3)
        thyme(&context, x: 350, baseY: 302, width: 44, seed: 39)
        // The storyteller.
        Art.group(&context, x: 226, y: 262, scale: 1.35) { g in
            storyteller(&g)
        }
        // The tale in the air: three small sparks by his raised hand.
        var sparks = Path()
        sparks.addPath(Art.spark(140, 92, 7))
        sparks.addPath(Art.spark(118, 122, 4.5))
        sparks.addPath(Art.spark(160, 64, 4))
        Art.fill(&context, sparks, Art.color(0xF08A12, 0.9))
        Kit.sink(&context, size, card: 0x6B3A1E)
    }
}

// MARK: - Tap-to-see: the Aegean Sea

extension WindSunArt {
    /// One island of the Aegean picture, seen from above: its shade on the water, the rock,
    /// a pale beach, a ring of surf and a few olives.
    static func aegeanIsle(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, width w: CGFloat, color: Color, trees: Bool) {
        Art.fill(&context, Art.ellipse(x + w * 0.04, y + w * 0.04, w * 0.58, w * 0.06), Art.color(0x0B4F7A, 0.28))
        Art.fill(&context, Art.ellipse(x, y + w * 0.01, w * 0.54, w * 0.045), Art.color(0xBFEFF2, 0.55))
        island(&context, x: x, y: y, width: w, height: w * 0.3, color: color)
        var beach = Path()
        beach.move(to: CGPoint(x: x - w * 0.44, y: y - 1))
        beach.addQuadCurve(to: CGPoint(x: x + w * 0.1, y: y - 1), control: CGPoint(x: x - w * 0.16, y: y - w * 0.05))
        Art.stroke(&context, beach, Art.color(0xF6EED6, 0.85), width: max(1.2, w * 0.022))
        if trees {
            let green: Color = Art.color(0x6E8A6C)
            Kit.farTree(&context, x: x - w * 0.14, baseY: y - w * 0.2, height: w * 0.1, color: green)
            Kit.farTree(&context, x: x + w * 0.02, baseY: y - w * 0.19, height: w * 0.09, color: green)
            Kit.farTree(&context, x: x + w * 0.2, baseY: y - w * 0.09, height: w * 0.08, color: green)
        }
    }

    /// "Aegean Sea": a bright blue sea dotted with rocky islands, seen from high above, with
    /// one tiny square-sailed boat for scale.
    static func aegeanPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let light: Kit.Light = day()
        let horizon: CGFloat = 78
        Kit.sky(&context, size, horizon: horizon, light: light)
        Kit.cloud(&context, 320, 50, scale: 0.5, color: Art.color(0xFFFFFF, 0.7))
        islandRow(&context, width: w, horizon: horizon, scale: 0.6, light: light)
        let sea: Kit.Stops = [(Art.color(0x6CC6D6), 0), (Art.color(0x2A9DB8), 0.3), (Art.color(0x1380AE), 0.7), (Art.color(0x0B5F92), 1)]
        Kit.water(&context, width: w, top: horizon, bottom: h, stops: sea, light: light, ripples: 70)
        // The shallows glow turquoise round the islands; far ones are paler.
        let rock: Color = Art.color(0xB7C296)
        let rockFar: Color = Art.color(0xA9C4B8)
        aegeanIsle(&context, x: 236, y: 112, width: 46, color: rockFar, trees: false)
        aegeanIsle(&context, x: 118, y: 128, width: 64, color: rockFar, trees: false)
        aegeanIsle(&context, x: 338, y: 142, width: 78, color: rock, trees: true)
        aegeanIsle(&context, x: 204, y: 206, width: 168, color: rock, trees: true)
        aegeanIsle(&context, x: 84, y: 232, width: 84, color: rock, trees: true)
        aegeanIsle(&context, x: 350, y: 250, width: 104, color: rock, trees: true)
        // A few low houses on the big island, far too small for detail.
        let wall: Color = Art.color(0xE8DCC0)
        let roof: Color = Art.color(0xC07A52)
        Kit.farHouse(&context, cx: 236, baseY: 196, width: 12, height: 8, wall: wall, roof: roof)
        Kit.farHouse(&context, cx: 252, baseY: 199, width: 10, height: 7, wall: wall, roof: roof)
        // The boat, and its wake.
        Kit.boat(&context, cx: 286, waterY: 186, length: 30, hull: 0x8A5A3A, sail: 0xF8F0DC, style: .nile)
        Art.stroke(&context, Art.svg("M304,190 q14,3 30,1 M306,194 q10,3 20,2"), Color.white.opacity(0.6), width: 1.3)
        Kit.birds(&context, 132, 176, scale: 0.7, color: Color.white.opacity(0.8))
        Kit.sink(&context, size, card: 0x0B4F7A)
    }
}

// MARK: - Tap-to-see: the woollen cloak

extension WindSunArt {
    /// "Woollen cloak": the red-brown cloak draped as if from a shoulder, its round bronze
    /// pin catching the light.
    static func cloakPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let air: Kit.Stops = [(Art.color(0xFBEFD2), 0), (Art.color(0xEBCF9E), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, h), air, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: h))
        Art.glow(&context, 190, 150, 210, Art.color(0xFFFBEA), alpha: 0.65)
        let k: CGFloat = 1.12
        Art.group(&context, x: 216 - 216 * k, y: 186 - 186 * k, scale: k) { g in
            cloakDrape(&g)
        }
        Kit.sink(&context, size, card: 0x5A2A2A)
    }

    /// The draped cloak of the picture, in picture units: about 214 wide, hanging from its pin
    /// at (150, 104).
    static func cloakDrape(_ g: inout GraphicsContext) {
        let cloak: Path = Art.svg("M150,96 C190,80 250,84 290,110 C316,150 326,210 318,270 C290,284 250,290 216,284 C180,292 140,286 112,272 C104,210 116,140 150,96Z")
        // Its soft shadow on the wall behind, down and to the right.
        let cast = CGAffineTransform(translationX: 10, y: 9)
        Art.blurred(&g, radius: 8, opacity: 0.22) { b in
            Art.fill(&b, cloak.applying(cast), ArtStyle.coolShade)
        }
        let wool: Kit.Stops = [(Art.color(cloakLightHex), 0), (Art.color(cloakHex), 0.45), (Art.color(cloakDarkHex), 1)]
        Kit.solid(&g, cloak, stops: wool, light: 0.3, shade: 0.24, rim: 2.4)
        Art.clipped(&g, to: cloak) { c in
            // Deep folds falling from the pin, each with a lit edge beside it.
            let folds: Path = Art.svg("M152,112 C160,170 150,230 130,276 M160,108 C190,160 200,230 196,288 M168,104 C220,140 250,210 262,286 M176,100 C240,116 290,170 310,266")
            Art.stroke(&c, folds, Art.color(0x6E2416, 0.55), width: 7)
            let lit = CGAffineTransform(translationX: -7, y: 1)
            Art.stroke(&c, folds.applying(lit), Art.color(0xE88A66, 0.5), width: 3.4)
            // The woven band along the hem.
            let hem: Path = Art.svg("M108,262 C140,276 180,282 216,274 C250,280 290,274 322,260")
            Art.stroke(&c, hem, Art.color(0xF0D9A8), width: 9)
            Art.stroke(&c, hem, Art.color(cloakDarkHex), width: 2.4, dash: [7, 6])
            // Wool: a soft tooth.
            Art.stipple(&c, in: CGRect(x: 104, y: 84, width: 224, height: 208), count: 260, seed: 19, color: Art.color(0xFFD9B0), alpha: 0.16, size: 0.6...1.6)
        }
        // The gathered wool at the pin.
        let gather: Path = Art.svg("M132,112 C140,96 162,92 172,104 C168,118 150,124 138,120Z")
        Kit.solid(&g, gather, Art.color(cloakLightHex), light: 0.3, shade: 0.2)
        Art.glow(&g, 150, 104, 40, Art.color(0xFFE9A8), alpha: 0.6)
        bronzePin(&g, x: 150, y: 104, r: 15)
        Art.fill(&g, Art.spark(139, 92, 6), Color.white.opacity(0.95))
    }
}

// MARK: - Portraits

extension WindSunArt {
    /// A strip of sea across the foot of a portrait, with a soft horizon.
    static func portraitSea(_ g: inout GraphicsContext, top: CGFloat, stops: Kit.Stops, rough: Bool) {
        Art.fillLinear(&g, Art.rect(0, top, 432, 400 - top), stops, from: CGPoint(x: 0, y: top), to: CGPoint(x: 0, y: 400))
        Art.fill(&g, Art.rect(0, top, 432, 3), Color.white.opacity(0.35))
        island(&g, x: 60, y: top + 1, width: 90, height: 18, color: Art.color(0xA9CCDA, 0.9))
        island(&g, x: 372, y: top + 1, width: 70, height: 14, color: Art.color(0xA9CCDA, 0.8))
        if rough {
            Kit.swells(&g, width: 432, top: top + 6, bottom: 400, rows: 4, crest: Color.white, seed: 12)
            whitecaps(&g, x0: 0, x1: 432, top: top + 8, bottom: 396, count: 30, seed: 44)
        } else {
            Kit.rippleMarks(&g, x0: 0, x1: 432, y0: top + 8, y1: 400, count: 30, seed: 45, color: Color.white)
        }
    }

    /// The North Wind full face, cheeks puffed and brows up, mid-boast, over white-capped sea.
    static func windPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0xC4DCEC, bottom: 0x5F8FB8, halo: 0xFFF4DC, rays: true) { g in
            portraitSea(&g, top: 326, stops: galeSea(), rough: true)
            Art.group(&g, x: 212, y: 170, scale: 1.25) { b in
                windHero(&b, mood: .boasting)
            }
            // A few olive leaves he has blown along.
            leafFlurry(&g, in: CGRect(x: 20, y: 250, width: 120, height: 60), count: 5, seed: 55, size: 12)
        }
    }

    /// The Sun full face with a calm smile and soft short rays, over a smooth blue sea.
    static func sunPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0xFFE38A, bottom: 0xFF9E4D, halo: 0xFFF8DC, rays: true) { g in
            portraitSea(&g, top: 322, stops: calmSea(), rough: false)
            Kit.glints(&g, x: 216, top: 322, depth: 78, color: Art.color(0xFFF1C9), count: 26, seed: 8)
            Art.group(&g, x: 216, y: 158, scale: 1.95) { b in
                sunHero(&b, mood: .smiling)
            }
        }
    }
}

// MARK: - Face chips

extension WindSunArt {
    static func windFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xD6E6F2) { g in
            Art.group(&g, x: 0, y: 2, scale: 0.46) { f in
                windHero(&f, mood: .puffing)
            }
        }
    }

    static func sunFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xFFE7A8) { g in
            Art.group(&g, x: 0, y: 0, scale: 0.7) { f in
                sunHero(&f, mood: .smiling, halo: false)
            }
        }
    }

    static func travellerFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xDDF0DC) { g in
            Art.group(&g, x: 0, y: 7, scale: 1.18) { f in
                Kit.personHead(&f, travellerLook(hat: true), mouth: .smile)
            }
        }
    }
}

// MARK: - Cover

extension WindSunArt {
    /// The traveller on the hill road above the blue sea: the smiling Sun at the upper left
    /// warms one side of him while the North Wind puffs from the right and blows half his
    /// cloak out.
    static func cover(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.cover(&context, size) { g, frame in
            let H: CGFloat = frame.H
            let k: CGFloat = frame.k
            let hd: CGFloat = frame.hd
            let light: Kit.Light = day()
            let area = CGSize(width: 240, height: hd)
            Kit.sky(&g, area, horizon: H, light: light)
            islandRow(&g, width: 240, horizon: H, scale: 0.5 * k, light: light)
            Kit.water(&g, width: 240, top: H, bottom: hd, stops: calmSea(), light: light, ripples: 14)
            // The hill and its road.
            var hill = Path()
            hill.move(to: CGPoint(x: -10, y: hd + 4))
            hill.addLine(to: CGPoint(x: -10, y: H + 40 * k))
            hill.addQuadCurve(to: CGPoint(x: 120, y: H + 12 * k), control: CGPoint(x: 50, y: H + 14 * k))
            hill.addQuadCurve(to: CGPoint(x: 250, y: H - 8 * k), control: CGPoint(x: 190, y: H + 10 * k))
            hill.addLine(to: CGPoint(x: 250, y: hd + 4))
            hill.closeSubpath()
            let shape: Path = hill
            Kit.solid(&g, shape, stops: hillStops(), light: 0.2, shade: 0.16, rim: 1.6)
            Kit.ribbon(&g, nearX: 104, nearY: hd + 2, nearWidth: 70 * k, farX: 236, farY: H + 4 * k, farWidth: 10 * k, stops: roadStops())
            Kit.olive(&g, x: 226, baseY: H + 2 * k, height: 50 * k, seed: 4)
            // The two friends in the sky.
            Art.group(&g, x: 58, y: H - 70 * k, scale: 0.42 * k) { s in
                sunHero(&s, mood: .smiling)
            }
            Art.group(&g, x: 192, y: H - 70 * k, scale: 0.4 * k) { s in
                windHero(&s, mood: .puffing, streams: true)
            }
            coverTraveller(&g, frame)
            Kit.cornerLeaves(&g, size: area, corner: 2, color: Art.color(0x3C5247), scale: 0.42, seed: 5)
        }
    }

    /// The traveller of the cover: facing the Wind, leaning into it, the cloak blown out
    /// behind him toward the Sun, olive leaves flying past.
    static func coverTraveller(_ g: inout GraphicsContext, _ frame: Kit.CoverFrame) {
        let H: CGFloat = frame.H
        let k: CGFloat = frame.k
        let feetY: CGFloat = H + 26 * k
        let s: CGFloat = 0.62 * k
        thyme(&g, x: 60, baseY: feetY + 8 * k, width: 26 * k, seed: 33)
        Kit.shadow(&g, 118, feetY + 1, width: 54 * k)
        Art.group(&g, x: 116, y: feetY, scale: s, scaleX: -1) { p in
            traveller(&p, state: .gale, mouth: .flat, mirrored: true)
        }
        leafFlurry(&g, in: CGRect(x: 40, y: H - 60 * k, width: 120, height: 60 * k), count: 7, seed: 56, size: 5 * k)
    }
}
