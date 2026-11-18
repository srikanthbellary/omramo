import SwiftUI
import OmramoCore

// The four folded scenes of "Iktomi and the Muskrat": each its own composition for the
// picture band at the top of a phone (432 wide, 240…520 high). The subject's face sits in
// x 86…346, between the two top controls and above the wavy bottom edge. Cultural care as in
// `IktomiArt+Cast.swift`: plain deerskin, braids with red ties, no sacred object, no tipi.

// MARK: - Shared band parts

extension IktomiArt {
    /// Sky, the level grass horizon and the lake down to the bottom of the band.
    static func foldedBackdrop(_ context: inout GraphicsContext, _ b: Kit.Band, light: Kit.Light, water: Kit.Stops, seed: UInt32) {
        Kit.sky(&context, b.size, horizon: b.H, light: light)
        farPrairie(&context, width: b.w, horizon: b.H, scale: b.unit, light: light, seed: seed)
        Kit.water(&context, width: b.w, top: b.H, bottom: b.h, stops: water, light: light, ripples: 22, seed: seed &+ 3)
    }

    /// The near bank across the band: a muddy edge at the water, then grass to the bottom.
    /// Its edge is at `top + 22` on the leading side and `top - 4` on the trailing side.
    static func foldedBank(_ context: inout GraphicsContext, _ b: Kit.Band, top: CGFloat, evening: Bool) {
        let h: CGFloat = b.h
        var edge = Path()
        edge.move(to: CGPoint(x: -10, y: top + 22))
        edge.addCurve(to: CGPoint(x: 442, y: top - 4), control1: CGPoint(x: 110, y: top + 2), control2: CGPoint(x: 300, y: top + 4))
        edge.addLine(to: CGPoint(x: 442, y: h + 2))
        edge.addLine(to: CGPoint(x: -10, y: h + 2))
        edge.closeSubpath()
        let shape: Path = edge
        Art.fill(&context, shape.applying(CGAffineTransform(translationX: 0, y: -4)), Art.color(0x9A8660))
        let grass: Kit.Stops = [(Art.color(0xBAC670), 0), (Art.color(0x9DB15C), 0.45), (Art.color(0x7C9650), 1)]
        Art.fillLinear(&context, shape, grass, from: CGPoint(x: 0, y: top), to: CGPoint(x: 0, y: h))
        let depth: CGFloat = max(1, h - top + 6)
        let box = CGRect(x: -10, y: top - 4, width: 452, height: depth)
        ArtStyle.form(&context, shape, bounds: box, light: 0.16, shade: 0.14)
        if evening {
            Art.fill(&context, shape, Art.color(0xF9DC9A, 0.14))
        }
        let blades: CGFloat = 8 * b.unit
        let field = CGRect(x: 0, y: top + 4, width: 432, height: max(10, h - top))
        Art.clipped(&context, to: shape) { c in
            ArtStyle.tooth(&c, in: box, seed: 41, alpha: 0.07)
            Kit.grass(&c, in: field, count: 60, seed: 3, color: Art.color(0x6E8C48), height: blades)
            Kit.grass(&c, in: field, count: 36, seed: 9, color: Art.color(0xD6DC8C), height: blades * 0.75)
        }
    }
}

// MARK: - scene-lake (folded): humming over the pot

extension IktomiArt {
    /// Iktomi on his stone in the middle, bent over the pot with the spoon; the muskrat
    /// standing dripping at his elbow and looking up; wild rice behind, pale sky above.
    static func lakeFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let b = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = b.unit
        let light = day()
        foldedBackdrop(&context, b, light: light, water: dayWater(), seed: 4)
        cumulus(&context, 330, b.H * 0.42, scale: 0.6 * u)
        Kit.cloud(&context, 96, b.H * 0.3, scale: 0.5 * u, color: Color.white.opacity(0.75))
        farDuck(&context, x: 64, y: b.H + 10 * u, scale: u)
        farDuck(&context, x: 90, y: b.H + 13 * u, scale: u * 0.9)
        Kit.reeds(&context, x: 30, baseY: b.H + 20 * u, count: 6, height: 80 * u, seed: 8, color: reedGreen)
        wildRice(&context, x: 128, baseY: b.H + 16 * u, count: 8, height: 70 * u, seed: 41)
        wildRice(&context, x: 384, baseY: b.H + 14 * u, count: 7, height: 64 * u, seed: 44)
        let s: CGFloat = 1.2 * u
        let fy: CGFloat = b.H + b.ground * 0.36
        foldedBank(&context, b, top: fy - 26 * s, evening: false)
        Art.group(&context, x: 250, y: fy, scale: s) { p in
            lakeFoldedGroup(&p)
        }
        Kit.grassTuft(&context, x: 40, baseY: b.floor + 4, height: 40 * u, color: 0x6F8E4A, seed: 4)
        Kit.reeds(&context, x: 420, baseY: b.floor + 10, count: 6, height: 110 * u, seed: 31, color: 0x4E7A44)
        ArtStyle.finish(&context, size)
    }

    /// The folded lake group in Iktomi's own units (origin at his feet): the stone seat, the
    /// pot with its steam, the spoon in his hand, and the muskrat at his elbow.
    static func lakeFoldedGroup(_ p: inout GraphicsContext) {
        Kit.rock(&p, cx: 14, baseY: 3, width: 64, height: 36, color: stoneGrey, seed: 7)
        let seat: Path = Art.svg("M-30,-34 C-20,-40 18,-40 30,-33 C32,-26 30,-20 28,-16 C10,-22 -12,-22 -30,-17Z")
        Art.group(&p, x: 14, y: 3) { t in
            Kit.solid(&t, seat, Art.color(blanketTan), light: 0.24, shade: 0.24)
            Art.stroke(&t, Art.svg("M24,-34 C27,-28 27,-22 25,-17"), Art.color(0xD94F3D), width: 3, cap: .butt)
        }
        Kit.shadow(&p, -10, 2, width: 100)
        let rig = iktomiRig(.sit)
        iktomi(&p, rig: rig, look: CGPoint(x: -0.8, y: 0.9), mouth: .smile)
        Kit.shadow(&p, -52, 5, width: 54)
        Art.group(&p, x: -52, y: 4) { q in
            pot(&q)
            steam(&q, x: 0, y: -40, height: 40)
        }
        let grip = Kit.hand(iktomiLook(), pose: .sit)
        Art.group(&p, x: grip.x, y: grip.y, rotate: Kit.deg(-110)) { t in
            spoon(&t)
        }
        Kit.bodyHand(&p, grip, 5.5, Art.color(iktomiLook().skin), open: false)
        Kit.shadow(&p, -100, 1, width: 50)
        Art.group(&p, x: -100, y: 0, scale: 1.05, scaleX: -1) { m in
            muskrat(&m, look: CGPoint(x: -0.4, y: -0.8), mirrored: true)
        }
        Kit.ripples(&p, -118, 6, 50, count: 1, color: Color.white, opacity: 0.4)
    }
}

// MARK: - scene-race (folded): puffing under the stone

extension IktomiArt {
    /// Iktomi's puffing face in the middle, cheeks blown out, the blanket-wrapped stone
    /// rising behind his shoulders; reeds at each side and pale sky above.
    static func raceFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let b = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = b.unit
        let light = day()
        foldedBackdrop(&context, b, light: light, water: dayWater(), seed: 9)
        cumulus(&context, 310, b.H * 0.52, scale: 0.85 * u)
        Kit.cloud(&context, 110, b.H * 0.34, scale: 0.55 * u, color: Color.white.opacity(0.8))
        smoke(&context, x: 96, baseY: b.H - 3 * u, height: 40 * u)
        Kit.reeds(&context, x: 52, baseY: b.H + 18 * u, count: 7, height: 96 * u, seed: 33, color: reedGreen)
        Kit.reeds(&context, x: 392, baseY: b.H + 16 * u, count: 7, height: 92 * u, seed: 34, color: reedGreen)
        let s: CGFloat = 1.15 * u
        let fy: CGFloat = b.H + b.ground * 0.4
        foldedBank(&context, b, top: fy - 22 * s, evening: false)
        let ix: CGFloat = 216 + 35 * s
        var mud = Path()
        mud.addEllipse(in: CGRect(x: ix - 70 * s, y: fy - 6 * s, width: 140 * s, height: 18 * s))
        mud.addEllipse(in: CGRect(x: ix + 46 * s, y: fy - 1 * s, width: 60 * s, height: 12 * s))
        Art.fill(&context, mud, Art.color(0x9A8660, 0.85))
        Art.group(&context, x: ix, y: fy, scale: s) { p in
            raceFoldedRunner(&p)
        }
        Kit.reeds(&context, x: 14, baseY: b.floor + 8, count: 5, height: 110 * u, seed: 37, color: 0x4E7A44)
        Kit.reeds(&context, x: 424, baseY: b.floor + 8, count: 5, height: 104 * u, seed: 38, color: 0x4E7A44)
        ArtStyle.finish(&context, size)
    }

    /// Iktomi running under the stone, in his own units: blown-out cheeks, puffs of breath,
    /// splashes of mud at his feet and the mosquitoes about his head.
    static func raceFoldedRunner(_ p: inout GraphicsContext) {
        Kit.shadow(&p, 0, 2, width: 120)
        let rig = iktomiRunRig()
        iktomi(&p, rig: rig, look: CGPoint(x: -0.6, y: 0.2), mouth: .oh, load: true)
        let c = iktomiHeadCentre(rig)
        let tilt: CGFloat = -Kit.deg(rig.lean) * 0.45
        Art.group(&p, x: c.x, y: c.y, rotate: tilt) { f in
            ArtStyle.cheek(&f, -14, 10, 10, alpha: 0.42)
            ArtStyle.cheek(&f, 13, 10, 9, alpha: 0.36)
            let puff: Path = Art.svg("M-34,14 C-40,8 -48,10 -48,16 C-54,14 -60,20 -54,25 C-48,28 -40,24 -40,20")
            Art.stroke(&f, puff, Color.white.opacity(0.85), width: 2)
            Art.stroke(&f, Art.svg("M-62,6 q-6,-2 -10,2 M-64,30 q-6,2 -10,-1"), Color.white.opacity(0.6), width: 1.6)
        }
        var splash = Path()
        splash.addEllipse(in: CGRect(x: rig.farFoot.x - 12, y: -5, width: 20, height: 8))
        splash.addEllipse(in: CGRect(x: rig.nearFoot.x - 10, y: -5, width: 20, height: 8))
        splash.addEllipse(in: CGRect(x: rig.nearFoot.x + 12, y: -14, width: 5, height: 4))
        splash.addEllipse(in: CGRect(x: rig.farFoot.x - 20, y: -10, width: 4, height: 3))
        Art.fill(&p, splash, Art.color(0x8C7A5A))
        let swarm = CGRect(x: c.x - 46, y: c.y - 60, width: 92, height: 40)
        Kit.flecks(&p, in: swarm, count: 8, seed: 5, color: ramp.deepColor.opacity(0.7), radius: 0.7...1.2)
    }
}

// MARK: - scene-swim (folded): coming straight across

extension IktomiArt {
    /// The muskrat's head in the middle, seen from the front and a little above, swimming
    /// toward us with whiskers spread and a V of ripples opening behind him; pale water and
    /// sky above, the lodge small at the trailing edge.
    static func swimFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let b = Kit.band(size, share: 0.62, least: 140, most: 330)
        let u: CGFloat = b.unit
        let light = day()
        foldedBackdrop(&context, b, light: light, water: dayWater(), seed: 14)
        cumulus(&context, 120, b.H * 0.56, scale: 0.55 * u)
        Kit.cloud(&context, 330, b.H * 0.34, scale: 0.5 * u, color: Color.white.opacity(0.8))
        farWillow(&context, x: 300, baseY: b.H - 1, height: 14 * u, color: light.near.opacity(0.85))
        smoke(&context, x: 322, baseY: b.H - 2, height: 38 * u)
        let glints: [(CGFloat, CGFloat, CGFloat)] = [(110, 0.12, 70), (300, 0.2, 90), (60, 0.42, 60)]
        for place in glints {
            let gy: CGFloat = b.H + b.ground * place.1
            let ry: CGFloat = 3 + 2 * u
            Art.fill(&context, Art.ellipse(place.0, gy, place.2 * u, ry), Color.white.opacity(0.24))
        }
        Kit.reeds(&context, x: 404, baseY: b.H + 26 * u, count: 6, height: 58 * u, seed: 51, color: reedGreen)
        lodge(&context, cx: 392, waterY: b.H + 30 * u, width: 74 * u)
        Kit.reeds(&context, x: 430, baseY: b.H + 36 * u, count: 4, height: 50 * u, seed: 53, color: 0x5C8A4A)
        let s: CGFloat = 1.25 * u
        let mx: CGFloat = 216
        let my: CGFloat = b.H + (b.floor - b.H) * 0.5
        swimFoldedWake(&context, mx: mx, my: my, s: s, far: b.H + 10)
        Art.fill(&context, Art.ellipse(mx, my + 26 * s, 24 * s, 12 * s), Art.color(muskratFur, 0.3))
        let above: Path = Art.rect(0, 0, 432, my + 13 * s)
        Art.clipped(&context, to: above) { c in
            Art.group(&c, x: mx, y: my, scale: s) { f in
                muskratFace(&f, look: CGPoint(x: 0, y: 0.3))
            }
        }
        Art.stroke(&context, Art.ellipse(mx, my + 13 * s, 34 * s, 6 * s), Color.white.opacity(0.8), width: 2 * u)
        Kit.ripples(&context, mx, my + 22 * s, 110 * s, count: 2, color: Color.white, opacity: 0.55)
        Kit.reeds(&context, x: 22, baseY: b.floor + 8, count: 6, height: 110 * u, seed: 26, color: 0x4E7A44)
        Kit.ripples(&context, 22, b.floor + 10, 70, count: 1, color: Color.white, opacity: 0.4)
        ArtStyle.finish(&context, size)
    }

    /// The V of ripples behind a swimmer coming toward the viewer: it opens away from him,
    /// up the water toward `far`.
    static func swimFoldedWake(_ context: inout GraphicsContext, mx: CGFloat, my: CGFloat, s: CGFloat, far: CGFloat) {
        let rise: CGFloat = max(10, my - far)
        let open: CGFloat = 150 * s
        var outer = Path()
        outer.move(to: CGPoint(x: mx - 22 * s, y: my + 4 * s))
        outer.addQuadCurve(to: CGPoint(x: mx - open, y: my - rise), control: CGPoint(x: mx - open * 0.4, y: my - rise * 0.3))
        outer.move(to: CGPoint(x: mx + 22 * s, y: my + 4 * s))
        outer.addQuadCurve(to: CGPoint(x: mx + open, y: my - rise), control: CGPoint(x: mx + open * 0.4, y: my - rise * 0.3))
        Art.stroke(&context, outer, Color.white.opacity(0.8), width: 2)
        Art.stroke(&context, outer, ramp.shadeColor.opacity(0.16), width: 0.8)
        var inner = Path()
        inner.move(to: CGPoint(x: mx - 30 * s, y: my - rise * 0.2))
        inner.addQuadCurve(to: CGPoint(x: mx - open * 0.6, y: my - rise * 0.85), control: CGPoint(x: mx - open * 0.34, y: my - rise * 0.45))
        inner.move(to: CGPoint(x: mx + 30 * s, y: my - rise * 0.2))
        inner.addQuadCurve(to: CGPoint(x: mx + open * 0.6, y: my - rise * 0.85), control: CGPoint(x: mx + open * 0.34, y: my - rise * 0.45))
        Art.stroke(&context, inner, Color.white.opacity(0.4), width: 1.4)
    }
}

// MARK: - scene-tree (folded): the bone from above

extension IktomiArt {
    /// Iktomi in the lower middle on his knees, head tipped back and mouth open; the muskrat
    /// above him on the willow's limb with the pot, holding one small fish bone over him;
    /// pale gold sky behind the leaves.
    static func treeFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let b = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = b.unit
        let light = evening()
        foldedBackdrop(&context, b, light: light, water: eveningWater(), seed: 19)
        let gold: Color = Art.color(0xFFF3CF, 0.85)
        Kit.cloud(&context, 120, b.H * 0.42, scale: 0.7 * u, color: gold)
        Kit.cloud(&context, 40, b.H * 0.7, scale: 0.4 * u, color: gold.opacity(0.7))
        Kit.farTrees(&context, x0: 30, x1: 150, baseY: b.H - 1, height: 8 * u, count: 3, color: light.mid, seed: 3)
        Kit.reeds(&context, x: 70, baseY: b.H + 14 * u, count: 6, height: 60 * u, seed: 4, color: reedGreen)
        foldedBank(&context, b, top: b.H + 8, evening: true)
        let hh: CGFloat = min(250, b.h * 0.56)
        let wx: CGFloat = 420
        let wb: CGFloat = b.H + 10
        willow(&context, x: wx, baseY: wb, height: hh, seed: 11)
        let perch = willowPerch(x: wx, baseY: wb, height: hh)
        let sm: CGFloat = 0.95 * u
        Art.group(&context, x: perch.x, y: perch.y + 2 * sm, scale: sm) { m in
            muskratWithPot(&m, laugh: true, bone: true)
        }
        let s: CGFloat = 1.05 * u
        let fy: CGFloat = b.H + b.ground * 0.42
        let ix: CGFloat = 160
        Art.group(&context, x: 52, y: fy - 2, scale: 0.7 * s) { t in
            droppedStone(&t)
        }
        Kit.shadow(&context, ix - 4 * s, fy + 2, width: 120 * s, alpha: 0.3)
        let rig = iktomiRig(.kneel, lean: 4)
        Art.group(&context, x: ix, y: fy, scale: s, scaleX: -1) { p in
            iktomi(&p, rig: rig, look: CGPoint(x: -0.6, y: -0.9), mouth: .open, headTurn: 0.35, mirrored: true)
        }
        Kit.grassTuft(&context, x: 230, baseY: fy + 18 * u, height: 26 * u, color: 0x7E9A50, seed: 7)
        Kit.reeds(&context, x: 424, baseY: b.floor + 8, count: 6, height: 100 * u, seed: 39, color: 0x4E7A44)
        ArtStyle.finish(&context, size)
    }
}
