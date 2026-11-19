import SwiftUI
import OmramoCore

// The Sydney Opera House by day: our own drawing (no photograph, nothing traced, no logo, no
// lettering). White sail-like roof shells in three groups of different heights stand on a
// broad stepped podium on a point of land; blue harbour in front, a hazy far shore behind.
// Card background #10355C.

extension LandmarkArt {
    /// The top of the podium: every shell stands on this line.
    private static let sydneyBaseY: CGFloat = 228

    /// A shell: (x of the foot under its mouth, x of its back foot, tip x, tip y). A shell
    /// whose back foot is right of its mouth foot opens to the left, and the other way round.
    /// The far hall, behind and to the right.
    private static let sydneyFarShells: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
        (220, 280, 210, 112), (256, 314, 244, 104), (344, 308, 349, 158),
    ]
    /// The near hall: three shells that open to the harbour and one that opens to the land.
    private static let sydneyNearShells: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
        (88, 150, 79, 172), (128, 198, 116, 130), (174, 234, 158, 94), (270, 228, 276, 152),
    ]
    /// The small pair at the landward end.
    private static let sydneySmallShells: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
        (306, 334, 301, 200), (356, 330, 360, 204),
    ]

    /// sydney-opera-house: the white roof shells on their podium at the edge of a blue harbour.
    static func paintSydneyOperaHouse(_ context: inout GraphicsContext) {
        sydneySky(&context)
        sydneyHarbour(&context)
        for shell in sydneyFarShells {
            sydneyDrawShell(&context, shell, far: true, rim: 0)
        }
        for index in 0..<sydneyNearShells.count {
            let rim: Double = (index == 1 || index == 2) ? 0.6 : 0
            sydneyDrawShell(&context, sydneyNearShells[index], far: false, rim: rim)
        }
        for shell in sydneySmallShells {
            sydneyDrawShell(&context, shell, far: false, rim: 0)
        }
        sydneyPodium(&context)
        sydneyBoat(&context, x: 46, y: 288, scale: 1)
        sydneyBoat(&context, x: 408, y: 268, scale: 0.5)
        sydneyNearPlane(&context)
        sydneyFinish(&context)
    }

    // MARK: Sky and far shore

    private static func sydneySky(_ context: inout GraphicsContext) {
        let sky: [(Color, CGFloat)] = [
            (Art.color(0x2F7FCC), 0),
            (Art.color(0x5FA8E0), 0.3),
            (Art.color(0x9CCBEA), 0.5),
            (Art.color(0xFFE6BF), 0.62),
            (Art.color(0xFFE6BF), 1),
        ]
        backdrop(&context, sky)
        // The day's light comes from beyond the upper-left corner.
        Art.glow(&context, -10, 30, 210, Art.color(0xFFF4D6), alpha: 0.3)
        horizon(&context, y: 250, rise: 70, hex: 0xFFE2B0, alpha: 0.35)

        Kit.cloud(&context, 292, 62, scale: 0.6, color: Art.color(0xFFFFFF, 0.92))
        Kit.cloud(&context, 40, 128, scale: 0.4, color: Art.color(0xFFFFFF, 0.85))
        Kit.birds(&context, 318, 114, scale: 0.6, color: Art.color(0x2E4F7E, 0.55))

        // The far plane: the far shore of the harbour, two low wooded rises, then a veil of
        // the sky's own colour so they sit well behind the white roofs.
        let farShore = Kit.ridge(width: 480, y: 236, amp: 10, seed: 9, bottom: 254, step: 8, x0: -24)
        Art.fill(&context, farShore, Art.color(0x5E93B4, 0.85))
        let nearShore = Kit.ridge(width: 480, y: 244, amp: 5, seed: 14, bottom: 254, step: 8, x0: -24)
        Art.fill(&context, nearShore, Art.color(0x4C83A4, 0.8))
        haze(&context, top: 214, bottom: 254, hex: 0xFFE6BF, alpha: 0.3)
    }

    // MARK: Harbour

    private static func sydneyHarbour(_ context: inout GraphicsContext) {
        let sea = Art.rect(-24, 250, unitWidth + 48, unitHeight - 250 + 24)
        let water: [(Color, CGFloat)] = [
            (Art.color(0xA6D4EA), 0),
            (Art.color(0x3F8FCB), 0.2),
            (Art.color(0x1C5C96), 0.6),
            (Art.color(0x10355C), 1),
        ]
        fillVertical(&context, sea, water, from: 250, to: unitHeight)

        // The roofs and the podium lie on the water, upside down, squashed and soft.
        let mirror = CGAffineTransform(a: 1, b: 0, c: 0, d: -0.5, tx: 0, ty: 376.5)
        let shells: [(CGFloat, CGFloat, CGFloat, CGFloat)] = sydneyFarShells + sydneyNearShells + sydneySmallShells
        let podium = Art.rect(54, 228, 332, 22).applying(mirror)
        Art.clipped(&context, to: sea) { g in
            Art.blurred(&g, radius: 2, opacity: 0.4) { layer in
                for shell in shells {
                    Art.fill(&layer, sydneyShell(shell).applying(mirror), Art.color(0xF4F6FB))
                }
                Art.fill(&layer, podium, Art.color(0xCDB6B0))
            }
        }

        let farBand = CGRect(x: 0, y: 253, width: unitWidth, height: 24)
        let nearBand = CGRect(x: 0, y: 276, width: unitWidth, height: 110)
        ripples(&context, in: farBand, count: 46, seed: 3, color: Art.color(0xFFFFFF, 0.4), width: 0.6, length: 6...24)
        ripples(&context, in: nearBand, count: 44, seed: 9, color: Art.color(0xCFE6FA, 0.2), width: 0.9, length: 10...38)
        ripples(&context, in: nearBand, count: 20, seed: 23, color: Art.color(0x10355C, 0.22), width: 0.9, length: 12...40)
        // The sun's light lying on the water toward the left.
        let sunPath = CGRect(x: 6, y: 254, width: 90, height: 40)
        ripples(&context, in: sunPath, count: 18, seed: 13, color: Art.color(0xFFF1CF, 0.5), width: 0.9, length: 5...20)
    }

    // MARK: Shells

    private static func sydneyRidgeControl(_ s: (CGFloat, CGFloat, CGFloat, CGFloat)) -> CGPoint {
        let dx: CGFloat = s.1 - s.0
        let dy: CGFloat = sydneyBaseY - s.3
        return pt(s.1 - dx * 0.3, s.3 + dy * 0.22)
    }

    private static func sydneyMouthControl(_ s: (CGFloat, CGFloat, CGFloat, CGFloat)) -> CGPoint {
        let dx: CGFloat = s.1 - s.0
        let dy: CGFloat = sydneyBaseY - s.3
        return pt(s.0 + dx * 0.16, s.3 + dy * 0.6)
    }

    /// One roof shell seen from the side: a round back that climbs to a point, and the edge
    /// of its mouth falling from the point to the podium.
    private static func sydneyShell(_ s: (CGFloat, CGFloat, CGFloat, CGFloat)) -> Path {
        var path = Path()
        path.move(to: pt(s.1, sydneyBaseY))
        path.addQuadCurve(to: pt(s.2, s.3), control: sydneyRidgeControl(s))
        path.addQuadCurve(to: pt(s.0, sydneyBaseY), control: sydneyMouthControl(s))
        path.closeSubpath()
        return path
    }

    /// The sliver of the shell's open mouth that shows from the side.
    private static func sydneyMouth(_ s: (CGFloat, CGFloat, CGFloat, CGFloat)) -> Path {
        let dx: CGFloat = s.1 - s.0
        let dy: CGFloat = sydneyBaseY - s.3
        let tip = pt(s.2, s.3)
        var path = Path()
        path.move(to: tip)
        path.addQuadCurve(to: pt(s.0, sydneyBaseY), control: sydneyMouthControl(s))
        path.addLine(to: pt(s.0 + dx * 0.2, sydneyBaseY))
        path.addQuadCurve(to: tip, control: pt(s.0 + dx * 0.42, s.3 + dy * 0.62))
        path.closeSubpath()
        return path
    }

    private static func sydneyQuadPoint(_ a: CGPoint, _ c: CGPoint, _ b: CGPoint, _ t: CGFloat) -> CGPoint {
        let u: CGFloat = 1 - t
        let wa: CGFloat = u * u
        let wc: CGFloat = 2 * u * t
        let wb: CGFloat = t * t
        let x: CGFloat = wa * a.x + wc * c.x + wb * b.x
        let y: CGFloat = wa * a.y + wc * c.y + wb * b.y
        return pt(x, y)
    }

    private static func sydneyDrawShell(
        _ context: inout GraphicsContext,
        _ s: (CGFloat, CGFloat, CGFloat, CGFloat),
        far: Bool,
        rim: Double
    ) {
        let base: CGFloat = sydneyBaseY
        let dx: CGFloat = s.1 - s.0
        let tip = pt(s.2, s.3)
        let backFoot = pt(s.1, base)
        let mouthFoot = pt(s.0, base)
        let shape = sydneyShell(s)
        let x0: CGFloat = min(min(s.0, s.1), s.2)
        let x1: CGFloat = max(max(s.0, s.1), s.2)

        // Pale tiles: cream on the side of the light, a soft blue away from it.
        let nearTiles: [(Color, CGFloat)] = [
            (Art.color(0xFFFBF0), 0),
            (Art.color(0xF6F3EC), 0.45),
            (Art.color(0xCBD5EA), 1),
        ]
        let farTiles: [(Color, CGFloat)] = [
            (Art.color(0xF1F3F4), 0),
            (Art.color(0xDDE5F0), 0.45),
            (Art.color(0xB2C2DE), 1),
        ]
        let tiles: [(Color, CGFloat)] = far ? farTiles : nearTiles
        fillHorizontal(&context, shape, tiles, from: x0, to: x1)
        model(&context, shape, light: 0.14, shade: far ? 0.26 : 0.18, rim: rim)

        // The ribs under the tiles fan from the foot of the shell up to its ridge.
        let ridgeControl = sydneyRidgeControl(s)
        let fanFoot = pt(s.0 + dx * 0.62, base)
        var ribs = Path()
        let stations: [CGFloat] = [0.2, 0.32, 0.44, 0.56, 0.68, 0.8]
        for station in stations {
            ribs.move(to: fanFoot)
            ribs.addLine(to: sydneyQuadPoint(backFoot, ridgeControl, tip, station))
        }
        Art.clipped(&context, to: shape) { g in
            Art.stroke(&g, ribs, Art.color(0x9FAECB, far ? 0.3 : 0.4), width: 0.6, cap: .butt)
        }

        // The mouth: soft shade under the roof, warm glass low down, a few slim mullions.
        let mouth = sydneyMouth(s)
        let glass: [(Color, CGFloat)] = [
            (Art.color(0x97A9CF), 0),
            (Art.color(0x6480B2), 0.55),
            (Art.color(0xC7A683), 1),
        ]
        fillVertical(&context, mouth, glass, from: s.3, to: base)
        var mullions = Path()
        let feet: [CGFloat] = [0.06, 0.11, 0.16]
        for foot in feet {
            mullions.move(to: tip)
            mullions.addLine(to: pt(s.0 + dx * foot, base))
        }
        Art.clipped(&context, to: mouth) { g in
            Art.stroke(&g, mullions, Art.color(0xFFFFFF, 0.3), width: 0.5, cap: .butt)
        }

        // The thick lip of the shell catches the light; the ridge is a quiet darker tone.
        var lip = Path()
        lip.move(to: tip)
        lip.addQuadCurve(to: mouthFoot, control: sydneyMouthControl(s))
        Art.stroke(&context, lip, Art.color(0xFFFFFF, far ? 0.7 : 0.95), width: 1.2)
        var ridge = Path()
        ridge.move(to: backFoot)
        ridge.addQuadCurve(to: tip, control: ridgeControl)
        Art.stroke(&context, ridge, Art.color(0x8E9FC4, 0.45), width: 0.7)
    }

    // MARK: Podium

    private static func sydneyPodium(_ context: inout GraphicsContext) {
        ArtStyle.contactShadow(&context, 228, 252, 176, 5, alpha: 0.3)
        let stone: [(Color, CGFloat)] = [
            (Art.color(0xF2DEC4), 0),
            (Art.color(0xD9C0A8), 0.5),
            (Art.color(0xA8929A), 1),
        ]
        let upper = Art.polygon([pt(66, 239), pt(72, 228), pt(372, 228), pt(378, 239)])
        fillHorizontal(&context, upper, stone, from: 66, to: 378)
        model(&context, upper, light: 0.14, shade: 0.2)
        let lower = Art.polygon([pt(54, 250), pt(58, 239), pt(382, 239), pt(386, 250)])
        fillHorizontal(&context, lower, stone, from: 54, to: 386)
        model(&context, lower, light: 0.12, shade: 0.24)

        // The broad steps of the upper level.
        var steps = Path()
        let levels: [CGFloat] = [231.6, 235.2]
        for level in levels {
            steps.move(to: pt(70, level))
            steps.addLine(to: pt(374, level))
        }
        Art.stroke(&context, steps, Art.color(0x8E7A8C, 0.4), width: 0.6, cap: .butt)

        // The shaded walk under the edge of the lower level.
        var openings = Path()
        for index in 0..<22 {
            let x: CGFloat = 66 + CGFloat(index) * 14.4
            openings.addRect(CGRect(x: x, y: 242.4, width: 8, height: 5))
        }
        Art.fill(&context, openings, Art.color(0x4A4670, 0.45))

        Art.fill(&context, Art.rect(71, 227.2, 302, 1.6), Art.color(0xFFFFFF, 0.85))
        Art.fill(&context, Art.rect(57, 238.4, 326, 1.3), Art.color(0xFFFFFF, 0.6))
        Art.fill(&context, Art.rect(54, 249, 332, 1.4), Art.color(0x2E4A78, 0.45))
    }

    // MARK: Boats

    /// A small sailing boat, far enough off to have nobody to see in it.
    private static func sydneyBoat(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, scale: CGFloat) {
        Art.group(&context, x: x, y: y, scale: scale) { g in
            ArtStyle.contactShadow(&g, 2, 4, 16, 2.2, alpha: 0.3)
            Art.stroke(&g, Art.line(0, -2, 0, -25), Art.color(0x6A4A3A), width: 1)
            var sails = Path()
            sails.addPath(Art.svg("M1.5,-24 C8,-16 11,-9 12,-4 L1.5,-4 Z"))
            sails.addPath(Art.svg("M-1.5,-20 C-5,-13 -8,-8 -10,-4 L-1.5,-4 Z"))
            Art.fill(&g, sails, Art.color(0xFFF8EA))
            model(&g, sails, light: 0.1, shade: 0.22)
            let hull = Art.svg("M-12,-3 L14,-3 C12,2 8,4 2,4 L-6,4 C-9,4 -11,1 -12,-3 Z")
            Art.fill(&g, hull, Art.color(0xD8583F))
            model(&g, hull, light: 0.16, shade: 0.24)
            Art.stroke(&g, Art.line(-11, -2.4, 13, -2.4), Art.color(0xFFE2C4, 0.8), width: 0.8)
        }
    }

    // MARK: Near plane

    /// The near plane: a spray of leaves in the top-right corner and dark harbour rocks with
    /// a few blades of grass in the bottom-right corner. Nothing lies over the building.
    private static func sydneyNearPlane(_ context: inout GraphicsContext) {
        cornerSpray(&context, seed: 523, dark: Art.color(0x1B4650, 0.94), lit: Art.color(0xFFE9B8, 0.32))

        let rocks = Art.svg("M456,322 C436,318 420,326 408,340 C398,338 386,346 378,360 C366,372 358,390 352,412 L456,412 Z")
        let rockStops: [(Color, CGFloat)] = [
            (Art.color(0x2F5578), 0),
            (Art.color(0x143A5E), 0.5),
            (Art.color(0x0C2A4A), 1),
        ]
        fillVertical(&context, rocks, rockStops, from: 320, to: unitHeight)
        model(&context, rocks, light: 0.2, shade: 0.2, rim: 0.5)
        let facets = Art.svg("M408,340 L416,366 M378,360 L392,384 M430,326 L436,352 M400,372 L404,398")
        Art.clipped(&context, to: rocks) { g in
            Art.stroke(&g, facets, Art.color(0x081E38, 0.35), width: 0.9)
        }

        var blades = Path()
        let tufts: [(CGFloat, CGFloat)] = [(412, 337), (424, 327), (384, 354), (440, 322)]
        let leans: [CGFloat] = [-2.0, -1.6, -1.2]
        for tuft in tufts {
            for lean in leans {
                blades.addPath(leaf(tuft.0, tuft.1, length: 15, width: 2, angle: lean))
            }
        }
        Art.fill(&context, blades, Art.color(0x1E5A52))
    }

    // MARK: Finish

    private static func sydneyFinish(_ context: inout GraphicsContext) {
        bottomFade(&context, 0x10355C, from: 300, alpha: 0.9)
        tooth(&context, seed: 521, light: 0.06, dark: 0.05)
        finish(&context, wash: 0.10, vignette: 0.10)
    }
}
