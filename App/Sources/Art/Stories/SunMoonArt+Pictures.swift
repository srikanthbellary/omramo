import SwiftUI
import OmramoCore

// The tap-to-see pictures, the character-card portraits, the face chips and the cover of
// "Why the Sun and the Moon Live in the Sky".

// MARK: - Tap-to-see pictures (432 × 404)

extension SunMoonArt {
    /// see-cross-river: the wide calm river opening into the sea, seen from a little above,
    /// with mangroves on their stilt roots along the near bank. No people, no boats.
    static func crossRiverPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let light = day()
        let H: CGFloat = 120
        Kit.sky(&context, size, horizon: H, light: light)
        farShore(&context, x0: -60, x1: 150, horizon: H, height: 10, light: light, seed: 3)
        farShore(&context, x0: 290, x1: 500, horizon: H, height: 12, light: light, seed: 8)
        ArtStyle.atmosphere(&context, width: 432, top: H - 40, bottom: H + 4, color: light.haze, alpha: 0.3)
        Kit.water(&context, width: 432, top: H, bottom: 404, stops: riverStops(), light: light, ripples: 40)
        Kit.glints(&context, x: 216, top: H, depth: 120, color: Art.color(0xFFF8DC), count: 28)

        // The two green banks the river runs between, closing toward the sea.
        let green: Kit.Stops = [(Art.color(0x8CCBA8), 0), (Art.color(0x3F9A78), 1)]
        let leftBank = Art.svg("M0,126 L132,123 C112,150 70,190 0,228Z")
        let rightBank = Art.svg("M432,126 L298,123 C322,154 366,196 432,238Z")
        Kit.solid(&context, leftBank, stops: green, light: 0.2, shade: 0.14)
        Kit.solid(&context, rightBank, stops: green, light: 0.2, shade: 0.18)
        let mudEdges = Art.svg("M132,123 C112,150 70,190 0,228 M298,123 C322,154 366,196 432,238")
        Art.stroke(&context, mudEdges, Art.color(0xD9B68A, 0.9), width: 3)
        Kit.farTrees(&context, x0: 0, x1: 120, baseY: 128, height: 20, count: 6, color: Art.color(0x4FA583), seed: 4)
        Kit.farTrees(&context, x0: 312, x1: 432, baseY: 128, height: 22, count: 6, color: Art.color(0x4FA583), seed: 9)
        Kit.swells(&context, width: 432, top: 150, bottom: 300, rows: 5, crest: Color.white)

        // The near bank: mud, and the mangroves standing on their long legs.
        mudBank(&context, x0: -30, y: 276, width: 230, height: 20)
        mudBank(&context, x0: 246, y: 280, width: 230, height: 20)
        Kit.mangrove(&context, x: 150, waterY: 258, height: 118, palette: mangroveGreens(), seed: 3)
        Kit.mangrove(&context, x: 300, waterY: 262, height: 128, palette: mangroveGreens(), seed: 7)
        Kit.mangrove(&context, x: 84, waterY: 272, height: 164, palette: mangroveGreens(), seed: 2)
        Kit.mangrove(&context, x: 360, waterY: 276, height: 170, palette: mangroveGreens(), seed: 5)
        Kit.ripples(&context, 222, 236, 36, count: 2, opacity: 0.5)
        Kit.sink(&context, size, card: 0x0E5F66)
    }

    /// see-compound: earth-walled houses with palm-thatch roofs standing round a swept yard,
    /// one clay pot by a door. No people.
    static func compoundPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let light = day()
        let H: CGFloat = 152
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.farTrees(&context, x0: -10, x1: 442, baseY: H + 2, height: 30, count: 16, color: light.far, seed: 5)
        ArtStyle.atmosphere(&context, width: 432, top: H - 50, bottom: H + 4, color: light.haze, alpha: 0.35)
        palm(&context, x: 214, baseY: H + 4, height: 118, lean: 8, seed: 3)
        palm(&context, x: 376, baseY: H + 6, height: 134, lean: -10, seed: 7)
        Kit.ground(&context, width: 432, top: H, bottom: 404, stops: yardStops())
        // The marks of the broom on the yard.
        let sweeps = Art.svg("M150,226 q30,-7 60,0 M196,244 q34,-8 68,0 M150,262 q40,-8 80,0 M214,280 q36,-8 72,0 M170,296 q30,-6 60,0")
        Art.stroke(&context, sweeps, Art.color(0xFFE9CC, 0.6), width: 1.8)
        // Two houses at the back of the yard, two at its sides, nearer.
        earthHouse(&context, cx: 160, baseY: 198, width: 96, wallHeight: 44, roofHeight: 40)
        earthHouse(&context, cx: 282, baseY: 202, width: 84, wallHeight: 42, roofHeight: 38)
        earthHouse(&context, cx: 92, baseY: 266, width: 104, wallHeight: 54, roofHeight: 48)
        earthHouse(&context, cx: 342, baseY: 270, width: 108, wallHeight: 56, roofHeight: 50)
        Kit.pot(&context, cx: 136, baseY: 274, width: 24, height: 28, color: 0xB5683A)
        Kit.shadow(&context, 226, 258, width: 34)
        stool(&context, cx: 226, baseY: 258, width: 30)
        Kit.tool(&context, .broom, x: 286, baseY: 276, height: 52)
        Kit.sink(&context, size, card: 0x8A4A22)
    }

    /// see-tide: the edge of the sea sliding up a muddy shore toward mangrove roots, a wet
    /// line on the mud showing how far it comes, one small crab at the water's edge.
    static func tidePicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let light = day()
        let H: CGFloat = 96
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.water(&context, width: 432, top: H, bottom: 404, stops: riverStops(), light: light, ripples: 30)
        Kit.swells(&context, width: 432, top: H + 16, bottom: 300, rows: 5, crest: Color.white)

        // The mud of the shore, rising to the right.
        let mud = Art.svg("M432,150 C330,170 250,215 190,262 C150,292 90,330 0,350 L0,404 L432,404Z")
        Kit.solid(&context, mud, stops: mudStops(), light: 0.22, shade: 0.16)
        let edge = Art.svg("M432,150 C330,170 250,215 190,262 C150,292 90,330 0,350")
        let wetBand = edge.applying(CGAffineTransform(translationX: 12, y: 16))
        let wetLine = edge.applying(CGAffineTransform(translationX: 26, y: 34))
        Art.clipped(&context, to: mud) { g in
            Art.stroke(&g, wetBand, Art.color(0x7A5238, 0.5), width: 30)
            Art.stroke(&g, wetLine, Color.white.opacity(0.45), width: 2)
            ArtStyle.tooth(&g, in: CGRect(x: 0, y: 150, width: 432, height: 254), seed: 21, alpha: 0.07)
        }
        // The wave sliding up: a thin sheet of water, its foam edge, and the line behind it.
        Art.stroke(&context, edge.applying(CGAffineTransform(translationX: 4, y: 5)), Art.color(0xBFEDE8, 0.7), width: 9)
        Art.stroke(&context, edge, Art.color(foam), width: 4.5)
        let behind = edge.applying(CGAffineTransform(translationX: -16, y: -20))
        Art.stroke(&context, behind, Color.white.opacity(0.5), width: 2)

        Kit.mangrove(&context, x: 428, waterY: 214, height: 150, palette: mangroveGreens(), seed: 4)
        Kit.mangrove(&context, x: 338, waterY: 240, height: 196, palette: mangroveGreens(), seed: 6)
        Kit.shadow(&context, 228, 262, width: 56)
        crab(&context, 226, 262, scale: 1.7)
        Kit.sink(&context, size, card: 0x14607A)
    }
}

// MARK: - Portraits (432 × 400) and face chips (100 × 100)

extension SunMoonArt {
    /// char-sun: the Sun, laughing, his arms opening in welcome, his golden glow behind him.
    static func sunPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0xFFD35A, bottom: 0xFF8A4D, halo: 0xFFF3C4, rays: true) { g in
            sunGlow(&g, 216, 150, 176)
            let p = sunLook()
            let skin = Art.color(p.skin)
            Art.group(&g, x: 216, y: 142, scale: 2.2) { b in
                // His other arm, raised too: both arms open.
                Art.group(&b, scaleX: -1) { m in
                    Art.stroke(&m, Art.svg("M50,72 Q96,66 72,6"), skin, width: 21)
                    Kit.bodyHand(&m, Kit.pt(71, 0), 10.5, skin, open: true)
                }
                Kit.bust(&b, p, look: .zero, mouth: .grin, wave: true)
            }
        }
    }

    /// char-moon: the Moon, calm, with a bundle of palm leaves in her arms and her pale halo.
    static func moonPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0xC9D2F7, bottom: 0x6C7BD0, halo: 0xF4F6FF, rays: true) { g in
            moonGlow(&g, 216, 146, 150)
            let p = moonLook()
            let skin = Art.color(p.skin)
            Art.group(&g, x: 216, y: 158, scale: 2.1) { b in
                Kit.bust(&b, p, look: .zero, mouth: .smile, wave: false)
            }
            // Her forearms, the bundle lying across them, her hands over it.
            let arms = Art.svg("M84,404 Q112,366 172,354 M356,404 Q332,362 288,346")
            Art.stroke(&g, arms, Kit.personTone(p.skin, 0.94), width: 40)
            Art.group(&g, x: 222, y: 340, rotate: -0.1, scale: 3.4) { b in
                palmBundle(&b)
            }
            Kit.bodyHand(&g, Kit.pt(176, 356), 19, skin, open: false)
            Kit.bodyHand(&g, Kit.pt(292, 348), 19, skin, open: false)
        }
    }

    /// char-water: the Water's broad kind face and rounded shoulders rising out of a rolling
    /// blue-green wave, two silver fish and a small crab swimming in him.
    static func waterPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0x8FE0DC, bottom: 0x147F92, halo: 0xE9FFFA, rays: true) { g in
            let back = Art.svg("M0,300 C60,270 120,268 180,290 C250,316 330,262 432,282 L432,400 L0,400Z")
            Art.fill(&g, back, Art.color(0x3FB6BE, 0.8))
            Art.group(&g, x: 216, y: 362, scale: 1.75) { w in
                waterFigure(&w, look: .zero, laugh: false, wave: true)
            }
            let front = Art.svg("M0,352 C70,330 130,372 216,356 C300,340 360,372 432,348 L432,400 L0,400Z")
            let tone: Kit.Stops = [(Art.color(0x5CC2C6), 0), (Art.color(0x1E8F96), 1)]
            Kit.solid(&g, front, stops: tone, light: 0.2, shade: 0.14)
            let crestLine = Art.svg("M0,352 C70,330 130,372 216,356 C300,340 360,372 432,348")
            Art.stroke(&g, crestLine, Art.color(foam, 0.9), width: 4)
            fish(&g, 64, 378, scale: 1.2)
            fish(&g, 372, 380, scale: 1, flip: true)
        }
    }

    static func sunFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xFFE2A8) { g in
            sunGlow(&g, 0, 2, 58)
            Art.group(&g, x: 0, y: 5, scale: 1.3) { f in
                Kit.personHead(&f, sunLook(), mouth: .grin)
            }
        }
    }

    static func moonFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xE3E6FA) { g in
            moonGlow(&g, 0, 2, 56)
            Art.group(&g, x: 0, y: 12, scale: 1.15) { f in
                Kit.personHead(&f, moonLook(), mouth: .smile)
            }
        }
    }

    static func waterFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xBDEBEF) { g in
            Art.group(&g, x: -2, y: 5, scale: 0.94) { f in
                waterHead(&f)
            }
        }
    }
}

// MARK: - Cover (300 wide, 150…375 high)

extension SunMoonArt {
    /// The cover: the Sun and the Moon sitting close together on the ridge of their thatched
    /// roof, looking down with round eyes as bright water full of little fish and crabs
    /// rises round the house; pale sky above; the Water's friendly face in the ripples below.
    static func cover(_ context: inout GraphicsContext, _ size: CGSize) {
        let light = day()
        Kit.cover(&context, size) { g, frame in
            let k: CGFloat = frame.k
            let H: CGFloat = frame.H
            let hd: CGFloat = frame.hd
            let unit = CGSize(width: 240, height: hd)
            let line: CGFloat = H - 8 * k
            Kit.sky(&g, unit, horizon: line, light: light)
            Kit.cloud(&g, 66, line * 0.5, scale: 0.42 * k, color: Art.color(0xFFFFFF, 0.65))
            Kit.farTrees(&g, x0: -10, x1: 250, baseY: line + 1, height: 16 * k, count: 12, color: light.far, seed: 5)
            palm(&g, x: 222, baseY: H + 30 * k, height: 112 * k, lean: -10 * k, seed: 6)
            Kit.water(&g, width: 240, top: line, bottom: hd, stops: floodStops(), light: light, ripples: 18, seed: 41)

            // The roof, the water at its eaves.
            let ridge: CGFloat = H + 8 * k
            let roofH: CGFloat = 40 * k
            let eaveY: CGFloat = ridge + roofH
            thatchRoof(&g, cx: 130, eaveY: eaveY, width: 150 * k, height: roofH)
            shallows(&g, x0: 130 - 80 * k, x1: 130 + 80 * k, y: eaveY - k, depth: 10 * k)

            // The two of them on the ridge.
            let s: CGFloat = 0.5 * k
            let seatY: CGFloat = ridge + 34 * s
            let headY: CGFloat = seatY - 128 * s
            let sunX: CGFloat = 130 - 17 * k
            let moonX: CGFloat = 130 + 20 * k
            sunGlow(&g, sunX + 6 * s, headY + 12 * s, 86 * s)
            moonGlow(&g, moonX + 6 * s, headY - 4 * s, 56 * s)
            Art.group(&g, x: sunX, y: seatY, scale: s) { p in
                sunFigure(&p, pose: .sit, look: CGPoint(x: -0.6, y: 0.8), mouth: .oh, glow: 0)
            }
            Art.group(&g, x: moonX, y: seatY, scale: s) { p in
                moonFigure(&p, pose: .sit, look: CGPoint(x: -0.6, y: 0.8), mouth: .smile, glow: 0)
            }

            // The Water's people, and his friendly face in the ripples below.
            fish(&g, 206, eaveY + 14 * k, scale: 0.5 * k, flip: true)
            fish(&g, 150, eaveY + 24 * k, scale: 0.42 * k)
            crab(&g, 100, eaveY + 20 * k, scale: 0.42 * k)
            Art.group(&g, x: 44, y: H + 72 * k, scale: 0.34 * k) { w in
                waterFigure(&w, look: CGPoint(x: 0.7, y: -0.7), laugh: true, wave: true)
            }
            Kit.cornerLeaves(&g, size: unit, corner: 1, color: Art.color(0x0F4A3C), scale: 0.5 * k, seed: 3)
        }
    }
}
