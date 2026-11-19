import SwiftUI
import OmramoCore

// The cast of "Savitri and Satyavan": palette, lights, the people, and the story's own parts
// (props, buildings, trees and animals) shared by the scenes, the pictures and the cover.

// MARK: - Palette and light

extension SavitriArt {
    /// Forest gold and sandalwood, leaf green and saffron (artBrief palette).
    static let ramp = ArtStyle.Ramp(deep: 0x1E2A14, shade: 0x4E5A2A, mid: 0x9AAE5E, light: 0xFBF2DC, glow: 0xFFD27A, accent: 0xE07A1A)

    /// The palace: a clear pale morning, cream to pale gold.
    static func morning() -> Kit.Light {
        let sky: Kit.Stops = [
            (Art.color(0xF2F0E2), 0), (Art.color(0xF8F0D8), 0.45), (Art.color(0xFCEBC6), 0.8), (Art.color(0xFFE2A6), 1),
        ]
        return Kit.Light(sky: sky, sun: 0xFFF6DE, glow: 0xFFD27A, haze: 0xFAEFD6, far: 0xDCD6BC, mid: 0xC2C292, near: 0x8E9A5A)
    }

    /// The hermitage: soft gold light that reads as morning or early evening.
    static func goldLight() -> Kit.Light {
        let sky: Kit.Stops = [
            (Art.color(0xF3F1DC), 0), (Art.color(0xF8EDCC), 0.45), (Art.color(0xFCE3AE), 0.8), (Art.color(0xFFD893), 1),
        ]
        return Kit.Light(sky: sky, sun: 0xFFF2D0, glow: 0xFFD27A, haze: 0xF8EACA, far: 0xCDD2A8, mid: 0xA9B47A, near: 0x6E8044)
    }

    /// The forest: pale afternoon light high above the canopy.
    static func afternoon() -> Kit.Light {
        let sky: Kit.Stops = [
            (Art.color(0xEEF1DE), 0), (Art.color(0xF4F1D6), 0.45), (Art.color(0xF8EAC0), 0.8), (Art.color(0xFFE09A), 1),
        ]
        return Kit.Light(sky: sky, sun: 0xFFF8E2, glow: 0xFFD27A, haze: 0xF3EDCF, far: 0xC6D0A2, mid: 0x9AAE5E, near: 0x5E7A3C)
    }

    /// The south road: a late evening, pale rose-gold, never night.
    static func evening() -> Kit.Light {
        let sky: Kit.Stops = [
            (Art.color(0xF6E8E4), 0), (Art.color(0xFADFD2), 0.45), (Art.color(0xFDD3B8), 0.8), (Art.color(0xFFC890), 1),
        ]
        return Kit.Light(sky: sky, sun: 0xFFF0DA, glow: 0xFFC48A, haze: 0xFBE2D2, far: 0xE4C8B8, mid: 0xCBA684, near: 0x9A7A52)
    }

    static func gardenGreens() -> Kit.Greens { Kit.greens(0x2E4A22, 0x4E6A30, 0x7A9A4A, 0xA9C06A, 0xDCE49A) }
    static func salGreens() -> Kit.Greens { Kit.greens(0x24381A, 0x3E5A26, 0x63803A, 0x93AE5A, 0xCFDC8E) }
    static func banyanGreens() -> Kit.Greens { Kit.greens(0x1E3418, 0x34502A, 0x55763A, 0x86A452, 0xC6D682) }
}

// MARK: - The people (draped, unstitched cloth; plain eyes for the Advanced tier)

extension SavitriArt {
    /// Savitri. Part I: a saffron and gold drape, long black hair. From page 6: plain ochre
    /// bark-cloth, hair knotted simply, no jewels.
    static func savitriLook(bark: Bool) -> Kit.Person {
        if bark {
            return Kit.Person(
                age: .adult, skin: 0xC68A5C, hair: 0x1E1612, hairStyle: .bun,
                garment: .wrapper, cloth: 0xB8884E, trim: 0x8E6236, legs: 0xC68A5C, showsEyeWhite: false
            )
        }
        return Kit.Person(
            age: .adult, skin: 0xC68A5C, hair: 0x1E1612, hairStyle: .long,
            garment: .wrapper, cloth: 0xEE9A1E, trim: 0xE9BE3A, legs: 0xC68A5C, showsEyeWhite: false
        )
    }

    /// Satyavan: bare-chested, an ochre lower cloth and a cloth over one shoulder, hair in a knot.
    static func satyavanLook() -> Kit.Person {
        Kit.Person(
            age: .adult, skin: 0xB27848, hair: 0x1E1612, hairStyle: .topknot,
            garment: .wrapper, cloth: 0xC4823A, trim: 0x96602A, legs: 0xB27848, showsEyeWhite: false
        )
    }

    /// King Ashvapati: white cloth, a gold band on his knotted hair, a short beard.
    static func kingLook() -> Kit.Person {
        Kit.Person(
            age: .adult, skin: 0xBE8456, hair: 0x2E2420, hairStyle: .topknot, beard: .short,
            headwear: .circlet, headwearColor: 0xE2B23A,
            garment: .wrapper, cloth: 0xF5EEDC, trim: 0xD9A830, legs: 0xBE8456, showsEyeWhite: false
        )
    }

    /// Narada: an old sage, white beard and hair piled on top, a pale cloth over one shoulder.
    static func naradaLook() -> Kit.Person {
        Kit.Person(
            age: .elder, skin: 0xC89268, hair: 0xF1ECE2, hairStyle: .topknot, beard: .long,
            garment: .wrapper, cloth: 0xF2E8D2, trim: 0xE0C79A, legs: 0xC89268, showsEyeWhite: false
        )
    }

    /// Dyumatsena, the blind old king, in plain ochre.
    static func oldKingLook() -> Kit.Person {
        Kit.Person(
            age: .elder, skin: 0xB98458, hair: 0xDCD6CC, hairStyle: .topknot, beard: .long,
            garment: .wrapper, cloth: 0xC29256, trim: 0x8E6236, legs: 0xB98458, showsEyeWhite: false
        )
    }

    /// His queen, in plain ochre, her grey hair in a knot.
    static func queenLook() -> Kit.Person {
        Kit.Person(
            age: .elder, skin: 0xC08C60, hair: 0xD2CBC0, hairStyle: .bun,
            garment: .wrapper, cloth: 0xB4824A, trim: 0x8A5A30, legs: 0xC08C60, showsEyeWhite: false
        )
    }

    /// Yama: dark as rain clouds, a red garment draped like a king's, gold at the edges.
    /// The crown is drawn by `yamaCrown`. Sober and calm (the Hindu reviewer decides).
    static func yamaLook() -> Kit.Person {
        Kit.Person(
            age: .adult, skin: 0x4C566C, hair: 0x15171F, hairStyle: .long,
            garment: .wrapper, cloth: 0xB0322A, trim: 0xD9A830, legs: 0x4C566C, showsEyeWhite: false
        )
    }

    /// One standing or walking person placed at (x, y) (the feet) at `scale`, facing left, or
    /// right when `right` is true; with a contact shadow. `behind` draws under the body and
    /// `front` over it, both in the person's own units (and mirrored with it).
    static func figure(
        _ context: inout GraphicsContext,
        _ look: Kit.Person,
        x: CGFloat,
        y: CGFloat,
        scale: CGFloat,
        right: Bool,
        pose: Kit.Pose,
        mouth: Kit.Mouth,
        gaze: CGPoint,
        behind: (inout GraphicsContext) -> Void,
        front: (inout GraphicsContext) -> Void
    ) {
        let shadowW: CGFloat = 62 * scale
        Kit.shadow(&context, x, y, width: shadowW)
        let flip: CGFloat = right ? -1 : 1
        Art.group(&context, x: x, y: y, scale: scale, scaleX: flip) { g in
            behind(&g)
            Kit.person(&g, look, pose: pose, look: gaze, mouth: mouth, mirrored: right)
            front(&g)
        }
    }

    /// The head centre of an adult (or elder) in its own units for a pose.
    static func headCentre(_ pose: Kit.Pose, elder: Bool) -> CGPoint {
        if elder {
            return CGPoint(x: -5, y: -132)
        }
        switch pose {
        case .walk: return CGPoint(x: -3, y: -140)
        default: return CGPoint(x: 0, y: -140)
        }
    }

    /// Savitri, always very straight, chin a little raised.
    static func savitri(
        _ context: inout GraphicsContext,
        x: CGFloat, y: CGFloat, scale: CGFloat, right: Bool,
        bark: Bool, pose: Kit.Pose, pot: Bool, mouth: Kit.Mouth = .smile
    ) {
        let look = savitriLook(bark: bark)
        let hand: CGPoint = Kit.hand(look, pose: pose)
        let head: CGPoint = headCentre(pose, elder: false)
        figure(
            &context, look, x: x, y: y, scale: scale, right: right, pose: pose, mouth: mouth,
            gaze: CGPoint(x: -0.2, y: -0.25),
            behind: { g in
                if !bark {
                    savitriBraid(&g, head: head)
                }
            },
            front: { g in
                if !bark {
                    savitriJewels(&g, head: head, hand: hand)
                }
                if pot {
                    waterPot(&g, cx: -20, cy: -66, r: 14)
                    Art.stroke(&g, Art.svg("M-30,-82 Q-34,-64 -24,-54"), Art.color(look.skin), width: 8)
                }
            }
        )
    }

    /// The thick black braid down her back.
    static func savitriBraid(_ g: inout GraphicsContext, head: CGPoint) {
        let hx: CGFloat = head.x
        let hy: CGFloat = head.y
        var braid = Path()
        braid.move(to: CGPoint(x: hx + 8, y: hy + 14))
        braid.addQuadCurve(to: CGPoint(x: hx + 16, y: hy + 92), control: CGPoint(x: hx + 22, y: hy + 50))
        Art.stroke(&g, braid, Art.color(0x1E1612), width: 10)
        var plaits = Path()
        let steps: [CGFloat] = [24, 38, 52, 66, 80]
        for t in steps {
            let px: CGFloat = hx + 14 + t * 0.04
            plaits.move(to: CGPoint(x: px - 4, y: hy + t - 3))
            plaits.addQuadCurve(to: CGPoint(x: px + 4, y: hy + t + 2), control: CGPoint(x: px, y: hy + t + 3))
        }
        Art.stroke(&g, plaits, Art.color(0x4A3A30), width: 1.4)
        Art.fill(&g, Art.circle(hx + 16, hy + 95, 3.2), Art.color(0xE9BE3A))
    }

    /// Gold earrings, a necklace and bangles (Part I only).
    static func savitriJewels(_ g: inout GraphicsContext, head: CGPoint, hand: CGPoint) {
        let gold: Color = Art.color(0xE9BE3A)
        let ear = Art.circle(head.x - 26.5, head.y + 12, 2.8)
        Art.fill(&g, ear, gold)
        Art.fill(&g, Art.circle(head.x - 27.2, head.y + 11.2, 1), Color.white.opacity(0.7))
        var necklace = Path()
        necklace.move(to: CGPoint(x: head.x - 9, y: head.y + 30))
        necklace.addQuadCurve(to: CGPoint(x: head.x + 9, y: head.y + 30), control: CGPoint(x: head.x, y: head.y + 40))
        Art.stroke(&g, necklace, gold, width: 2.4)
        let bangle = Art.ellipse(hand.x, hand.y - 6, 4.6, 2)
        Art.stroke(&g, bangle, gold, width: 1.8)
        let bangle2 = Art.ellipse(hand.x, hand.y - 9, 4.4, 1.9)
        Art.stroke(&g, bangle2, Art.color(0xC99A28), width: 1.6)
    }

    /// Satyavan, easy and upright; with `axe` the axe stands head-up in his leading hand.
    static func satyavan(
        _ context: inout GraphicsContext,
        x: CGFloat, y: CGFloat, scale: CGFloat, right: Bool,
        pose: Kit.Pose, axe: Bool, mouth: Kit.Mouth = .grin
    ) {
        let look = satyavanLook()
        let hand: CGPoint = Kit.hand(look, pose: pose)
        figure(
            &context, look, x: x, y: y, scale: scale, right: right, pose: pose, mouth: mouth,
            gaze: CGPoint(x: -0.3, y: 0),
            behind: { _ in },
            front: { g in
                Art.stroke(&g, Art.svg("M-16,-104 Q-4,-112 9,-102"), Art.color(0x8A5A2A), width: 1.6)
                if axe {
                    let butt = CGPoint(x: hand.x - 3, y: -2)
                    let top = CGPoint(x: hand.x + 2, y: hand.y - 34)
                    axeShape(&g, from: butt, to: top)
                    Kit.bodyHand(&g, hand, 5.5, Art.color(look.skin), open: false)
                }
            }
        )
    }

    /// The axe: a simple iron head on a wooden haft, from the butt to the head end.
    static func axeShape(_ g: inout GraphicsContext, from butt: CGPoint, to top: CGPoint) {
        Art.stroke(&g, Art.line(butt.x, butt.y, top.x, top.y), Art.color(0x6E4426), width: 4.6)
        Art.stroke(&g, Art.line(butt.x - 0.8, butt.y, top.x - 0.8, top.y), Art.color(0xA87A4A), width: 1.6)
        let head = Art.svg("M0,-3 L-15,-8 Q-19,0 -16,9 L0,5Z").applying(CGAffineTransform(translationX: top.x, y: top.y + 5))
        Kit.solid(&g, head, Art.color(0x6E747E), light: 0.34, shade: 0.24)
        Art.stroke(&g, Art.svg("M-15,-7 Q-18.5,0 -15.5,8").applying(CGAffineTransform(translationX: top.x, y: top.y + 5)), Art.color(0xC9CED6), width: 1.4)
    }

    /// King Ashvapati seated on a cushioned seat, facing left.
    static func king(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, scale: CGFloat) {
        let look = kingLook()
        Art.group(&context, x: x, y: y, scale: scale) { g in
            Kit.shadow(&g, 0, 0, width: 96)
            cushionSeat(&g, cx: 10, baseY: 0, width: 58, height: Kit.seatHeight(look))
            Kit.person(&g, look, pose: .sit, look: CGPoint(x: -0.4, y: 0), mouth: .flat, mirrored: false)
            var necklace = Path()
            necklace.move(to: CGPoint(x: -4, y: -100))
            necklace.addQuadCurve(to: CGPoint(x: 14, y: -100), control: CGPoint(x: 5, y: -90))
            Art.stroke(&g, necklace, Art.color(0xE2B23A), width: 2.6)
            Art.stroke(&g, Art.line(-12, -84, -7, -84), Art.color(0xE2B23A), width: 3)
        }
    }

    /// A low carved wooden seat with a saffron-red cushion.
    static func cushionSeat(_ g: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, width: CGFloat, height: CGFloat) {
        let half: CGFloat = width / 2
        let wood: Color = Art.color(0x8E5A34)
        Kit.solid(&g, Art.rect(cx - half + 3, baseY - height * 0.7, 7, height * 0.7, radius: 2), wood)
        Kit.solid(&g, Art.rect(cx + half - 10, baseY - height * 0.7, 7, height * 0.7, radius: 2), wood)
        Kit.solid(&g, Art.rect(cx - half, baseY - height * 0.78, width, 7, radius: 2), Art.color(0xA8703E))
        let cushion = Art.rect(cx - half - 2, baseY - height - 2, width + 4, height * 0.3 + 4, radius: 6)
        Kit.solid(&g, cushion, Art.color(0xC2502E), light: 0.3, shade: 0.24)
        Art.stroke(&g, Art.line(cx - half + 2, baseY - height + 5, cx + half - 2, baseY - height + 5), Art.color(0xE9BE3A), width: 1.6)
    }

    /// Narada, standing with his tall staff, the vina slung on his back.
    static func narada(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, scale: CGFloat, right: Bool) {
        let look = naradaLook()
        let hand: CGPoint = Kit.hand(look, pose: .stand)
        figure(
            &context, look, x: x, y: y, scale: scale, right: right, pose: .stand, mouth: .smile,
            gaze: CGPoint(x: -0.5, y: 0.1),
            behind: { g in
                Art.stroke(&g, Art.line(26, -44, -4, -176), Art.color(0x7A4E2C), width: 4)
                Kit.solid(&g, Art.circle(23, -54, 10), Art.color(0xD9B070), light: 0.3, shade: 0.24)
                Kit.solid(&g, Art.circle(0, -162, 7), Art.color(0xD9B070), light: 0.3, shade: 0.24)
            },
            front: { g in
                Art.stroke(&g, Art.line(hand.x - 1, -1, hand.x - 3, -178), Art.color(0x8E6034), width: 3.6)
                Art.fill(&g, Art.circle(hand.x - 3, -180, 3.2), Art.color(0xA8784A))
                Kit.bodyHand(&g, hand, 5.2, Art.color(look.skin), open: false)
            }
        )
    }

    /// An old person seated on a low reed stool on a grass mat, facing left (or right).
    static func seatedElder(
        _ context: inout GraphicsContext, _ look: Kit.Person,
        x: CGFloat, y: CGFloat, scale: CGFloat, right: Bool, gaze: CGPoint, staff: Bool
    ) {
        let flip: CGFloat = right ? -1 : 1
        Art.group(&context, x: x, y: y, scale: scale, scaleX: flip) { g in
            grassMat(&g, cx: -6, baseY: 0, width: 100)
            Kit.shadow(&g, 0, 0, width: 84)
            let stool = Art.rect(-6, -Kit.seatHeight(look), 36, Kit.seatHeight(look), radius: 5)
            Kit.solid(&g, stool, Art.color(0xB89A62), light: 0.22, shade: 0.24)
            Art.stroke(&g, Art.svg("M-4,-24 L28,-24 M-4,-14 L28,-14"), Art.color(0x8E7444), width: 1.4)
            Kit.person(&g, look, pose: .sit, look: gaze, mouth: .smile, mirrored: right)
            if staff {
                Art.stroke(&g, Art.line(-31, -2, -21, -150), Art.color(0x8E6034), width: 3.4)
                let grip: CGPoint = Kit.hand(look, pose: .sit)
                Kit.bodyHand(&g, grip, 5.2, Art.color(look.skin), open: false)
            }
        }
    }

    /// A woven grass mat lying on the ground (seen at a low angle).
    static func grassMat(_ g: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, width: CGFloat) {
        let half: CGFloat = width / 2
        let shape = Art.polygon([
            CGPoint(x: cx - half, y: baseY + 4), CGPoint(x: cx - half + 12, y: baseY - 8),
            CGPoint(x: cx + half + 6, y: baseY - 8), CGPoint(x: cx + half - 4, y: baseY + 4),
        ])
        Kit.solid(&g, shape, Art.color(0xD8BE7E), light: 0.2, shade: 0.16)
        var weave = Path()
        var x: CGFloat = cx - half + 8
        while x < cx + half {
            weave.move(to: CGPoint(x: x - 3, y: baseY + 3))
            weave.addLine(to: CGPoint(x: x + 6, y: baseY - 7))
            x += 9
        }
        Art.stroke(&g, weave, Art.color(0xB89C5E), width: 1)
    }

    /// Yama, tall (a head and a half above Savitri) and calm, the crown on his head; with
    /// `light` the small gold light glows in his leading hand. The looped rope hangs loosely
    /// at his side.
    static func yama(
        _ context: inout GraphicsContext,
        x: CGFloat, y: CGFloat, scale: CGFloat, right: Bool, pose: Kit.Pose, light: Bool
    ) {
        let look = yamaLook()
        let hand: CGPoint = Kit.hand(look, pose: pose)
        let head: CGPoint = headCentre(pose, elder: false)
        figure(
            &context, look, x: x, y: y, scale: scale * 1.42, right: right, pose: pose, mouth: .flat,
            gaze: CGPoint(x: -0.3, y: 0.1),
            behind: { g in
                yamaRope(&g, at: CGPoint(x: 16, y: -66))
            },
            front: { g in
                yamaCrown(&g, at: head)
                var necklace = Path()
                necklace.move(to: CGPoint(x: head.x - 10, y: head.y + 30))
                necklace.addQuadCurve(to: CGPoint(x: head.x + 10, y: head.y + 30), control: CGPoint(x: head.x, y: head.y + 42))
                Art.stroke(&g, necklace, Art.color(0xD9A830), width: 2.6)
                if light {
                    soulLight(&g, x: hand.x - 3, y: hand.y - 5, r: 4.5)
                }
            }
        )
    }

    /// A simple gold crown (a tall band rising to three soft points), set on the head at `c`.
    static func yamaCrown(_ g: inout GraphicsContext, at c: CGPoint) {
        let move = CGAffineTransform(translationX: c.x, y: c.y)
        let crown = Art.svg("M-21,-15 L-22,-33 Q-15,-31 -11,-39 Q-5,-33 0,-47 Q5,-33 11,-39 Q15,-31 22,-33 L21,-15 Q0,-21 -21,-15Z").applying(move)
        Kit.solid(&g, crown, Art.color(0xD9A830), light: 0.34, shade: 0.24, rim: 1.4)
        let band = Art.svg("M-21,-18 Q0,-24 21,-18").applying(move)
        Art.stroke(&g, band, Art.color(0x9A6E1A), width: 2)
        Art.fill(&g, Art.circle(c.x, c.y - 28, 2.8), Art.color(0x8A2A2A))
        Art.fill(&g, Art.circle(c.x - 0.8, c.y - 28.8, 0.9), Color.white.opacity(0.7))
    }

    /// The looped rope, hanging loosely from his sash on the far side.
    static func yamaRope(_ g: inout GraphicsContext, at p: CGPoint) {
        let move = CGAffineTransform(translationX: p.x, y: p.y)
        let loops = Art.svg("M0,0 C-8,12 -4,30 6,30 C16,30 16,12 4,4 M2,2 C-4,16 2,40 10,40 C20,38 18,18 6,6").applying(move)
        Art.stroke(&g, loops, Art.color(0x9A7A4A), width: 3)
        Art.stroke(&g, loops, Art.color(0xC9A46A), width: 1.4)
    }

    /// The small gold light: a soft glow, not a flame.
    static func soulLight(_ g: inout GraphicsContext, x: CGFloat, y: CGFloat, r: CGFloat) {
        Art.glow(&g, x, y, r * 7, Art.color(0xFFD27A), alpha: 0.5)
        Art.glow(&g, x, y, r * 2.6, Art.color(0xFFE9A8), alpha: 0.9)
        Art.fill(&g, Art.circle(x, y, r), Art.color(0xFFF8E6))
    }
}

// MARK: - Props

extension SavitriArt {
    /// A round clay water pot centred on (cx, cy), `r` the radius of its belly.
    static func waterPot(_ g: inout GraphicsContext, cx: CGFloat, cy: CGFloat, r: CGFloat) {
        let neckW: CGFloat = r * 0.5
        var body = Path()
        body.move(to: CGPoint(x: cx - neckW, y: cy - r * 0.92))
        body.addCurve(to: CGPoint(x: cx, y: cy + r), control1: CGPoint(x: cx - r * 1.5, y: cy - r * 0.6), control2: CGPoint(x: cx - r * 1.1, y: cy + r))
        body.addCurve(to: CGPoint(x: cx + neckW, y: cy - r * 0.92), control1: CGPoint(x: cx + r * 1.1, y: cy + r), control2: CGPoint(x: cx + r * 1.5, y: cy - r * 0.6))
        body.closeSubpath()
        Kit.solid(&g, body, stops: Kit.stops(0xD07A44, 0x9A4A2A), light: 0.3, shade: 0.26)
        let rim = Art.ellipse(cx, cy - r * 0.95, neckW * 1.3, r * 0.2)
        Kit.solid(&g, rim, Art.color(0xDE9060), light: 0.3, shade: 0.2)
        Art.fill(&g, Art.ellipse(cx, cy - r * 0.97, neckW * 0.8, r * 0.1), Art.color(0x5A2A18))
        Art.stroke(&g, Art.svg("M0,0 Q10,3 20,0").applying(CGAffineTransform(translationX: cx - r * 0.7, y: cy - r * 0.2).scaledBy(x: r / 14, y: r / 14)), Art.color(0xF2C08A, 0.7), width: 1.2)
    }

    /// Firewood tied in a bundle with a vine, lying on the ground at (cx, baseY).
    static func woodBundle(_ g: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, width: CGFloat) {
        let half: CGFloat = width / 2
        let log: CGFloat = width * 0.13
        Kit.shadow(&g, cx, baseY, width: width * 1.1)
        let rows: [(CGFloat, CGFloat)] = [(0, 0), (0, 1), (0, 2), (1, 0.5), (1, 1.5), (2, 1)]
        for row in rows {
            let ly: CGFloat = baseY - log * (row.0 * 0.85 + 1)
            let lx: CGFloat = cx - half + row.1 * 2
            let rect = Art.rect(lx, ly, width - 4, log, radius: log / 2)
            Kit.solid(&g, rect, Art.color(row.0 == 1 ? 0x8A5A34 : 0x7A4E2C), light: 0.26, shade: 0.24)
            Art.fill(&g, Art.ellipse(lx + 2, ly + log / 2, log * 0.32, log * 0.46), Art.color(0xD9AE76))
        }
        let tieX: CGFloat = cx - half * 0.3
        let tieX2: CGFloat = cx + half * 0.45
        let top: CGFloat = baseY - log * 3.6
        Art.stroke(&g, Art.line(tieX, top, tieX + 2, baseY), Art.color(0x4E6A2C), width: 2.2)
        Art.stroke(&g, Art.line(tieX2, top, tieX2 + 2, baseY), Art.color(0x4E6A2C), width: 2.2)
    }

    /// A carved timber pillar standing on `baseY`: pot base, shaft, carved bands and a bracket.
    static func timberPillar(_ g: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, height: CGFloat, width: CGFloat) {
        let half: CGFloat = width / 2
        let wood: Color = Art.color(0xC9965E)
        Kit.solid(&g, Art.rect(cx - half, baseY - height, width, height, radius: 2), wood, light: 0.24, shade: 0.22)
        let foot = Art.ellipse(cx, baseY - 6, half * 1.5, 7)
        Kit.solid(&g, foot, Art.color(0xB88450), light: 0.26, shade: 0.24)
        let bracket = Art.svg("M-14,0 Q-8,-8 0,-8 Q8,-8 14,0 L10,5 L-10,5Z").applying(CGAffineTransform(translationX: cx, y: baseY - height))
        Kit.solid(&g, bracket, Art.color(0xB8844E), light: 0.24, shade: 0.2)
        var bands = Path()
        let ys: [CGFloat] = [0.22, 0.26, 0.7, 0.74]
        for t in ys {
            let y: CGFloat = baseY - height * t
            bands.move(to: CGPoint(x: cx - half, y: y))
            bands.addLine(to: CGPoint(x: cx + half, y: y))
        }
        Art.stroke(&g, bands, Art.color(0x9A6A3E), width: 1.4, cap: .butt)
        Art.stroke(&g, Art.line(cx - half + 2, baseY - height + 6, cx - half + 2, baseY - 12), Color.white.opacity(0.28), width: 1.4)
    }

    /// A carved stone gateway (torana): two posts and three curved crossbars with rolled ends.
    static func torana(_ g: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, height: CGFloat, color: UInt32) {
        let h: CGFloat = height
        let span: CGFloat = h * 0.42
        let post: CGFloat = h * 0.09
        let tone: Color = Art.color(color)
        Kit.solid(&g, Art.rect(cx - span - post / 2, baseY - h * 0.86, post, h * 0.86), tone, light: 0.2, shade: 0.16)
        Kit.solid(&g, Art.rect(cx + span - post / 2, baseY - h * 0.86, post, h * 0.86), tone, light: 0.2, shade: 0.16)
        let bars: [CGFloat] = [0.62, 0.78, 0.94]
        var ends = Path()
        for t in bars {
            let y: CGFloat = baseY - h * t
            let reach: CGFloat = span + h * 0.16
            var bar = Path()
            bar.move(to: CGPoint(x: cx - reach, y: y))
            bar.addQuadCurve(to: CGPoint(x: cx + reach, y: y), control: CGPoint(x: cx, y: y - h * 0.06))
            Art.stroke(&g, bar, tone, width: h * 0.055)
            ends.addPath(Art.circle(cx - reach, y + h * 0.01, h * 0.035))
            ends.addPath(Art.circle(cx + reach, y + h * 0.01, h * 0.035))
        }
        Art.fill(&g, ends, Art.color(Kit.builtHex(color, 0.9)))
    }

    /// A far hall with a barrel roof (pale, small): plinth, wall, vaulted roof and a finial.
    static func farPavilion(_ g: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, width: CGFloat, height: CGFloat, color: UInt32) {
        let half: CGFloat = width / 2
        let wallTop: CGFloat = baseY - height * 0.55
        let tone: Color = Art.color(color)
        Art.fill(&g, Art.rect(cx - half - 3, baseY - height * 0.1, width + 6, height * 0.1 + 2), Art.color(Kit.builtHex(color, 0.94)))
        Art.fill(&g, Art.rect(cx - half, wallTop, width, height * 0.46), tone)
        var vault = Path()
        vault.move(to: CGPoint(x: cx - half - 4, y: wallTop + 1))
        vault.addCurve(to: CGPoint(x: cx + half + 4, y: wallTop + 1), control1: CGPoint(x: cx - half, y: wallTop - height * 0.55), control2: CGPoint(x: cx + half, y: wallTop - height * 0.55))
        vault.closeSubpath()
        Art.fill(&g, vault, Art.color(Kit.builtHex(color, 0.92)))
        Art.fill(&g, Art.circle(cx, wallTop - height * 0.42, max(1.5, height * 0.05)), Art.color(Kit.builtHex(color, 0.88)))
        var windows = Path()
        let count: Int = max(2, Int(width / 14))
        for i in 0..<count {
            let wx: CGFloat = cx - half + width * (CGFloat(i) + 0.5) / CGFloat(count)
            windows.addPath(Art.rect(wx - 1.5, wallTop + height * 0.12, 3, height * 0.18, radius: 1.5))
        }
        Art.fill(&g, windows, Art.color(Kit.builtHex(color, 0.8)))
    }
}

// MARK: - The hermitage and the forest

extension SavitriArt {
    /// A hut of reed and leaf on a bamboo frame, standing on (cx, baseY), `width` wide (the
    /// wall) and `height` tall to the ridge. `lamps` lights the doorway (page 14).
    static func hut(_ g: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, width: CGFloat, height: CGFloat, lamps: Bool) {
        let half: CGFloat = width / 2
        let wallH: CGFloat = height * 0.44
        let wallTop: CGFloat = baseY - wallH
        Kit.shadow(&g, cx, baseY, width: width * 1.3)
        let wall = Art.rect(cx - half, wallTop, width, wallH)
        Kit.solid(&g, wall, stops: Kit.stops(0xD6B678, 0xB8945A), light: 0.2, shade: 0.24)
        var reeds = Path()
        var x: CGFloat = cx - half + 4
        while x < cx + half - 2 {
            reeds.move(to: CGPoint(x: x, y: wallTop + 3))
            reeds.addLine(to: CGPoint(x: x + 0.6, y: baseY - 1))
            x += 4.5
        }
        Art.stroke(&g, reeds, Art.color(0x9A7A46, 0.7), width: 1)
        Art.stroke(&g, Art.line(cx - half, wallTop + wallH * 0.45, cx + half, wallTop + wallH * 0.45), Art.color(0x7A6236), width: 2)
        let posts: [CGFloat] = [cx - half, cx + half]
        for px in posts {
            Kit.solid(&g, Art.rect(px - 2.5, wallTop - 2, 5, wallH + 2, radius: 2), Art.color(0x9A8A4E), light: 0.3, shade: 0.2)
        }
        let doorW: CGFloat = width * 0.26
        let door = CGRect(x: cx - doorW * 0.2, y: baseY - wallH * 0.86, width: doorW, height: wallH * 0.86)
        Kit.opening(&g, rect: door, arched: false, color: 0x8A6A3E, glow: lamps ? 0.7 : 0)
        Kit.roof(&g, cx: cx, eaveY: wallTop + 2, width: width * 1.34, height: height - wallH, color: 0xBCA064, style: .thatch)
        var leaves = Path()
        let leafXs: [CGFloat] = [-0.42, -0.2, 0.04, 0.26, 0.46]
        for t in leafXs {
            Kit.treeLeaf(&leaves, cx + width * t, wallTop - (height - wallH) * 0.3, width * 0.07, 1.4, slim: 0.5)
        }
        Art.fill(&g, leaves, Art.color(0x8E9A52, 0.75))
        if lamps {
            Kit.lamp(&g, cx: door.minX - 6, cy: baseY - 6, radius: 2.6)
            Kit.lamp(&g, cx: door.maxX + 6, cy: baseY - 6, radius: 2.6)
        }
    }

    /// The small square brick fire altar (vedi), with a low fire and a thin thread of smoke.
    static func fireAltar(_ g: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, width: CGFloat, smoke: Bool) {
        let half: CGFloat = width / 2
        let faceH: CGFloat = width * 0.34
        let topDepth: CGFloat = width * 0.22
        Kit.shadow(&g, cx, baseY, width: width * 1.2)
        let face = Art.rect(cx - half, baseY - faceH, width, faceH, radius: 1)
        Kit.solid(&g, face, Art.color(0xB8653A), light: 0.2, shade: 0.28)
        var courses = Path()
        let rows: [CGFloat] = [0.33, 0.66]
        for t in rows {
            courses.move(to: CGPoint(x: cx - half, y: baseY - faceH * t))
            courses.addLine(to: CGPoint(x: cx + half, y: baseY - faceH * t))
        }
        Art.stroke(&g, courses, Art.color(0x8A4426, 0.7), width: 1, cap: .butt)
        let top = Art.polygon([
            CGPoint(x: cx - half, y: baseY - faceH), CGPoint(x: cx - half + topDepth * 0.6, y: baseY - faceH - topDepth),
            CGPoint(x: cx + half + topDepth * 0.6, y: baseY - faceH - topDepth), CGPoint(x: cx + half, y: baseY - faceH),
        ])
        Kit.solid(&g, top, Art.color(0xD08A58), light: 0.3, shade: 0.12)
        let pitY: CGFloat = baseY - faceH - topDepth * 0.5
        Art.fill(&g, Art.ellipse(cx + topDepth * 0.3, pitY, half * 0.6, topDepth * 0.3), Art.color(0x5A2A18))
        Art.glow(&g, cx + topDepth * 0.3, pitY - 4, width * 0.6, Art.color(0xFFB45A), alpha: 0.4)
        let flame = Kit.propFlame(cx + topDepth * 0.3, pitY, width * 0.16, width * 0.22, -1)
        Art.fill(&g, flame, Art.color(0xFFB040))
        let core = Kit.propFlame(cx + topDepth * 0.3, pitY, width * 0.07, width * 0.12, 0)
        Art.fill(&g, core, Art.color(0xFFF0C0))
        if smoke {
            let sx: CGFloat = cx + topDepth * 0.3
            var thread = Path()
            thread.move(to: CGPoint(x: sx, y: pitY - width * 0.2))
            thread.addCurve(to: CGPoint(x: sx + width * 0.1, y: pitY - width * 1.6), control1: CGPoint(x: sx - width * 0.25, y: pitY - width * 0.7), control2: CGPoint(x: sx + width * 0.35, y: pitY - width * 1.0))
            Art.stroke(&g, thread, Color.white.opacity(0.5), width: 2.4)
            Art.stroke(&g, thread, Art.color(0xB8B0A0, 0.25), width: 1)
        }
    }

    /// A tall straight sal tree: a long trunk and a high crown of long oval leaves.
    static func salTree(_ g: inout GraphicsContext, x: CGFloat, baseY: CGFloat, height: CGFloat, seed: UInt32) {
        var random = ArtRandom(seed)
        let lean: CGFloat = (Kit.rnd(&random) - 0.5) * height * 0.04
        let crownY: CGFloat = baseY - height * 0.8
        let trunk = Kit.treeTrunk(x, baseY, x + lean, crownY, height * 0.035, height * 0.016)
        Kit.treeBark(&g, trunk.shape, trunk.edge, 0x6E5A44)
        var boughs = Path()
        Kit.treeBough(&boughs, x + lean, crownY + height * 0.08, x + lean - height * 0.12, crownY - height * 0.02, height * 0.012, height * 0.004, bend: -4)
        Kit.treeBough(&boughs, x + lean, crownY + height * 0.04, x + lean + height * 0.11, crownY - height * 0.05, height * 0.012, height * 0.004, bend: 4)
        Art.fill(&g, boughs, Art.color(0x5E4A38))
        let blobs = Kit.treeCrown(x + lean, crownY - height * 0.04, height * 0.15, height * 0.12, count: 6, seed: seed &+ 3)
        Kit.canopy(&g, blobs, seed: seed &+ 7, palette: salGreens(), density: 1.6)
    }

    /// The great banyan: a broad crown on a thick trunk, pillar roots grown down from its
    /// boughs and many thin roots hanging like the ropes of a tent.
    static func banyan(_ g: inout GraphicsContext, x: CGFloat, baseY: CGFloat, height: CGFloat, spread: CGFloat, seed: UInt32) {
        let half: CGFloat = spread / 2
        let crownY: CGFloat = baseY - height * 0.66
        let bark: UInt32 = 0x8A7A62
        let pillars: [CGFloat] = [-0.78, -0.52, 0.5, 0.8]
        for t in pillars {
            let px: CGFloat = x + half * t
            let trunk = Kit.treeTrunk(px, baseY, px + t * 4, crownY + height * 0.06, height * 0.03, height * 0.018)
            Kit.treeBark(&g, trunk.shape, trunk.edge, Kit.builtHex(bark, 0.92))
        }
        let main = Kit.treeTrunk(x, baseY, x + 4, crownY, height * 0.11, height * 0.07)
        Kit.treeBark(&g, main.shape, main.edge, bark)
        var boughs = Path()
        Kit.treeBough(&boughs, x, crownY + height * 0.06, x - half * 0.9, crownY + height * 0.02, height * 0.05, height * 0.016, bend: -10)
        Kit.treeBough(&boughs, x + 4, crownY + height * 0.04, x + half * 0.9, crownY, height * 0.05, height * 0.016, bend: 10)
        Kit.solid(&g, boughs, Art.color(Kit.builtHex(bark, 0.9)), light: 0.2, shade: 0.24)
        var blobs: [Kit.Blob] = Kit.treeRow(x, crownY - height * 0.06, half: half, r: height * 0.17, arch: height * 0.1)
        let top: [Kit.Blob] = Kit.treeCrown(x, crownY - height * 0.22, half * 0.62, height * 0.15, count: 7, seed: seed)
        blobs.append(contentsOf: top)
        Kit.canopy(&g, blobs, seed: seed &+ 11, palette: banyanGreens(), density: 2.2)
        banyanRoots(&g, x: x, baseY: baseY, half: half, crownY: crownY, height: height, seed: seed)
    }

    /// The hanging roots of the banyan, from the underside of the crown toward the ground.
    static func banyanRoots(_ g: inout GraphicsContext, x: CGFloat, baseY: CGFloat, half: CGFloat, crownY: CGFloat, height: CGFloat, seed: UInt32) {
        var random = ArtRandom(seed &+ 29)
        var roots = Path()
        var lit = Path()
        for i in 0..<26 {
            let u: CGFloat = CGFloat(i) / 25 * 2 - 1
            let rx: CGFloat = x + u * half * 0.92 + (Kit.rnd(&random) - 0.5) * 10
            let start: CGFloat = crownY + height * 0.04 + abs(u) * height * 0.03
            let reach: CGFloat = (baseY - start) * (0.35 + Kit.rnd(&random) * 0.65)
            let sway: CGFloat = (Kit.rnd(&random) - 0.5) * 6
            roots.move(to: CGPoint(x: rx, y: start))
            roots.addQuadCurve(to: CGPoint(x: rx + sway, y: start + reach), control: CGPoint(x: rx - sway, y: start + reach * 0.5))
            if i % 3 == 0 {
                lit.move(to: CGPoint(x: rx - 0.8, y: start + 4))
                lit.addLine(to: CGPoint(x: rx - 0.8 + sway * 0.5, y: start + reach * 0.6))
            }
        }
        Art.stroke(&g, roots, Art.color(0x7A6A50, 0.85), width: max(1, height * 0.006))
        Art.stroke(&g, lit, ArtStyle.warmLight.opacity(0.35), width: 0.9)
    }
}

// MARK: - Animals and ground cover

extension SavitriArt {
    /// An Indian peacock walking, feet at (x, y), facing left (or right), its long train
    /// trailing behind along the ground. About 80 tall and 130 long at scale 1.
    static func peacock(_ g: inout GraphicsContext, x: CGFloat, y: CGFloat, scale: CGFloat, right: Bool) {
        let flip: CGFloat = right ? -1 : 1
        let shadowX: CGFloat = x + 36 * scale * flip
        Kit.shadow(&g, shadowX, y, width: 110 * scale, alpha: 0.16)
        Art.group(&g, x: x, y: y, scale: scale, scaleX: flip) { p in
            let train = Art.svg("M8,-30 C40,-34 80,-18 112,-4 C116,-1 112,2 106,1 C76,-2 40,-6 6,-16Z")
            Kit.solid(&p, train, stops: Kit.stops(0x4E8A3E, 0x2E5E2E), light: 0.24, shade: 0.24)
            var rings = Path()
            var eyes = Path()
            let spots: [(CGFloat, CGFloat)] = [(36, -21), (56, -15), (76, -10), (96, -4), (46, -25), (66, -19), (86, -12)]
            for s in spots {
                rings.addPath(Art.ellipse(s.0, s.1, 4, 3))
                eyes.addPath(Art.ellipse(s.0, s.1, 2, 1.6))
            }
            Art.fill(&p, rings, Art.color(0xD9B23A))
            Art.fill(&p, eyes, Art.color(0x1E3A7A))
            Art.stroke(&p, Art.svg("M-2,-16 L-5,0 M6,-16 L7,0"), Art.color(0x8A7A6A), width: 2)
            let body = Art.svg("M-14,-30 C-16,-44 -6,-48 2,-46 C14,-44 18,-30 12,-18 C6,-12 -8,-14 -14,-30Z")
            Kit.solid(&p, body, Art.color(0x2A5AB0), light: 0.3, shade: 0.24)
            let wing = Art.svg("M-2,-40 C10,-40 16,-30 12,-20 C4,-22 -2,-30 -2,-40Z")
            Kit.solid(&p, wing, Art.color(0xB08A5A), light: 0.24, shade: 0.2)
            let neck = Art.svg("M-13,-34 C-17,-46 -15,-58 -12,-64 L-5,-64 C-7,-56 -7,-46 -2,-40Z")
            Kit.solid(&p, neck, Art.color(0x2A5AB0), light: 0.34, shade: 0.2)
            Kit.solid(&p, Art.circle(-9, -66, 5), Art.color(0x2E62B8), light: 0.3, shade: 0.2)
            Art.fill(&p, Art.ellipse(-10, -66.6, 2.6, 1.5), Color.white.opacity(0.8))
            ArtStyle.eye(&p, -10.6, -66.6, 1.2, showsWhite: false)
            Art.fill(&p, Art.svg("M-13,-66 L-18,-64.6 L-13,-63.4Z"), Art.color(0x9A8A7A))
            Art.stroke(&p, Art.svg("M-8,-71 L-11,-78 M-7,-71 L-7,-79 M-6,-71 L-4,-77"), Art.color(0x2A5AB0), width: 0.8)
            var tips = Path()
            tips.addPath(Art.circle(-11, -78.5, 1.3))
            tips.addPath(Art.circle(-7, -79.5, 1.3))
            tips.addPath(Art.circle(-4, -77.5, 1.3))
            Art.fill(&p, tips, Art.color(0x2E62B8))
        }
    }

    /// A spotted deer (chital), calm, at a distance.
    static func chitalLook() -> Kit.Beast {
        var look = Kit.gazelleLook()
        look.body = 0xC4823E
        look.belly = 0xF6E8CE
        look.dark = 0x5A3A22
        look.showsEyeWhite = false
        return look
    }

    /// A chital standing on (x, y), facing left (or right), white spots along its flank.
    static func chital(_ g: inout GraphicsContext, x: CGFloat, y: CGFloat, scale: CGFloat, right: Bool) {
        let look = chitalLook()
        let flip: CGFloat = right ? -1 : 1
        Kit.shadow(&g, x, y, width: 110 * scale, alpha: 0.2)
        Art.group(&g, x: x, y: y, scale: scale, scaleX: flip) { b in
            Kit.beast(&b, look, pose: .stand, mood: .calm, look: .zero, mirrored: right)
            let back: CGPoint = Kit.beastBack(look, pose: .stand)
            var spots = Path()
            let marks: [(CGFloat, CGFloat)] = [(-24, 9), (-12, 7), (0, 8), (12, 7), (22, 10), (-18, 17), (-5, 16), (8, 17), (19, 18)]
            for m in marks {
                spots.addPath(Art.circle(back.x + m.0, back.y + m.1, 2))
            }
            Art.fill(&b, spots, Color.white.opacity(0.8))
        }
    }

    /// Tall gold grass standing on `baseY` from x0 to x1, two tones and seed heads.
    static func goldGrass(_ g: inout GraphicsContext, x0: CGFloat, x1: CGFloat, baseY: CGFloat, height: CGFloat, seed: UInt32) {
        var random = ArtRandom(seed)
        var back = Path()
        var front = Path()
        var heads = Path()
        let blade: CGFloat = max(2, height * 0.07)
        var x: CGFloat = x0
        while x < x1 {
            let length: CGFloat = height * (0.6 + Kit.rnd(&random) * 0.5)
            let lean: CGFloat = (Kit.rnd(&random) - 0.35) * height * 0.3
            if Kit.rnd(&random) < 0.5 {
                Kit.groundBlade(&back, x: x, baseY: baseY, width: blade, length: length, lean: lean)
            } else {
                Kit.groundBlade(&front, x: x, baseY: baseY + 1, width: blade, length: length * 0.9, lean: lean)
            }
            if Kit.rnd(&random) < 0.3 {
                heads.addPath(Art.ellipse(x + lean, baseY - length - 1, blade * 0.45, blade * 1.1))
            }
            x += blade * (1.2 + Kit.rnd(&random) * 1.4)
        }
        Art.fill(&g, back, Art.color(0xC4954C))
        Art.fill(&g, front, Art.color(0xE4BC6A))
        Art.fill(&g, heads, Art.color(0xF2D48A))
    }

    /// The deeper ground of a tall window: two tones of grass, a few flowers and pebbles.
    static func meadowFill(_ v: inout GraphicsContext, x0: CGFloat, x1: CGFloat, top: CGFloat, bottom: CGFloat, seed: UInt32) {
        guard bottom > top + 4, x1 > x0 else { return }
        let rect = CGRect(x: x0, y: top, width: x1 - x0, height: bottom - top)
        Kit.grass(&v, in: rect, count: 60, seed: seed, color: Art.color(0x7E9A4A), height: 10)
        Kit.grass(&v, in: rect, count: 40, seed: seed &+ 1, color: Art.color(0x5E7A3C), height: 13)
        Kit.flowers(&v, in: rect, count: 14, seed: seed &+ 2, petal: 0xFFE8A8, heart: 0xE07A1A)
        Kit.pebbles(&v, in: rect, count: 10, seed: seed &+ 3, color: 0xB8A88A)
    }
}
