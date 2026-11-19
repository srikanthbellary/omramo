import SwiftUI
import OmramoCore

/// Concept art for "Iktomi and the Muskrat", drawn in code (round 5; composed from the shared kit).
///
/// A Dakota story, flagged for cultural review: the pictures keep to the spec's artBrief —
/// plain deerskin, two braids with red ties, plain two-colour bead bands, no face paint, no
/// feathers, no sacred object, no tipi. The cast and the lake's own parts are in
/// `IktomiArt+Cast.swift`, the folded scenes in `IktomiArt+Folded.swift`, the tap pictures,
/// portraits, faces and cover in `IktomiArt+Pictures.swift`.
enum IktomiArt {
    /// Draws the picture called `name`. Returns false for a name this story does not have.
    static func paint(_ name: String, role: ArtRole, in context: inout GraphicsContext, size: CGSize) -> Bool {
        guard size.width > 0, size.height > 0 else { return false }
        switch (name, role) {
        case ("scene-lake", .sceneUnfolded): lakeScene(&context, size)
        case ("scene-lake", .sceneFolded): lakeFolded(&context, size)
        case ("scene-race", .sceneUnfolded): raceScene(&context, size)
        case ("scene-race", .sceneFolded): raceFolded(&context, size)
        case ("scene-swim", .sceneUnfolded): swimScene(&context, size)
        case ("scene-swim", .sceneFolded): swimFolded(&context, size)
        case ("scene-tree", .sceneUnfolded): treeScene(&context, size)
        case ("scene-tree", .sceneFolded): treeFolded(&context, size)
        case ("see-great-plains", .picture): greatPlainsPicture(&context, size)
        case ("see-guest-custom", .picture): guestCustomPicture(&context, size)
        case ("see-reed-lodge", .picture): reedLodgePicture(&context, size)
        case ("see-storyteller", .picture): storytellerPicture(&context, size)
        case ("char-iktomi", .portrait): iktomiPortrait(&context, size)
        case ("char-muskrat", .portrait): muskratPortrait(&context, size)
        case ("face-iktomi", .face): iktomiFaceChip(&context, size)
        case ("face-muskrat", .face): muskratFaceChip(&context, size)
        case ("cover", .cover): cover(&context, size)
        default:
            return false
        }
        return true
    }
}

// MARK: - The far plane every unfolded scene shares

extension IktomiArt {
    /// Sky, the level grass horizon and the lake from the horizon to the bottom edge.
    static func backdrop(_ context: inout GraphicsContext, _ st: Kit.Stage, light: Kit.Light, water: Kit.Stops, seed: UInt32) {
        Kit.sky(&context, st.size, horizon: st.H, light: light)
        farPrairie(&context, width: st.w, horizon: st.H, scale: st.far, light: light, seed: seed)
        Kit.water(&context, width: st.w, top: st.H, bottom: st.h, stops: water, light: light, ripples: 46, seed: seed &+ 3)
    }

    /// Soft reflections of the clouds lying on the water, palest far away.
    static func cloudReflections(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let places: [(CGFloat, CGFloat, CGFloat)] = [(230, 0.24, 130), (560, 0.36, 170), (120, 0.6, 150), (720, 0.16, 90)]
        for place in places {
            let y: CGFloat = st.H + st.depth * place.1
            let half: CGFloat = place.2 * st.far
            Art.fill(&context, Art.ellipse(place.0, y, half, 5 + st.depth * 0.03), Color.white.opacity(0.24))
        }
    }
}

// MARK: - scene-lake: the pot of fish and the visitor

extension IktomiArt {
    static func lakeScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 150)
        let light = day()
        backdrop(&context, st, light: light, water: dayWater(), seed: 4)
        cumulus(&context, 300, st.H * 0.26 + 20, scale: st.far * 0.55)
        cumulus(&context, 640, st.H * 0.36, scale: st.far * 0.95)
        Kit.cloud(&context, 96, st.H * 0.5, scale: st.far * 0.6, color: Color.white.opacity(0.7))
        Kit.farTrees(&context, x0: 600, x1: 760, baseY: st.H - 2 * st.far, height: 11 * st.far, count: 3, color: light.mid, seed: 6)
        farDuck(&context, x: 170, y: st.H + 16 * st.far, scale: st.far)
        farDuck(&context, x: 204, y: st.H + 20 * st.far, scale: st.far * 0.9)
        cloudReflections(&context, st)
        Kit.designSpace(&context, st) { v in
            wildRice(&v, x: 96, baseY: st.Hv + 30, count: 9, height: 44, seed: 3)
            Kit.reeds(&v, x: 318, baseY: st.Hv + 44, count: 6, height: 52, seed: 8, color: reedGreen)
            wildRice(&v, x: 392, baseY: st.Hv + 60, count: 7, height: 62, seed: 14)
            Art.group(&v, x: 372, y: st.Hv + 22) { d in
                dragonfly(&d)
            }
            if st.tall > 0.25 {
                Kit.reeds(&v, x: 84, baseY: st.Hv + 250, count: 7, height: 120, seed: 21, color: reedGreen)
                wildRice(&v, x: 250, baseY: st.Hv + 300, count: 10, height: 110, seed: 22)
                Kit.ripples(&v, 250, st.Hv + 304, 120, count: 2)
            }
            Kit.nearSpace(&v, st) { n in
                bank(&n, Hv: st.Hv)
                willow(&n, x: 856, baseY: st.Hv + 36, height: 300, seed: 11)
                bankFill(&n, Hv: st.Hv)
                lakeSubject(&n, Hv: st.Hv)
                Kit.reeds(&n, x: 872, baseY: st.Hv + 168, count: 7, height: 120, seed: 31, color: 0x4E7A44)
            }
        }
        Kit.cornerLeaves(&context, size: size, corner: 2, color: Art.color(0x3F6A46), scale: 0.8 * st.far, seed: 5)
        ArtStyle.finish(&context, size)
    }

    /// Iktomi on a stone by his small fire, stirring the pot and looking only into it; the
    /// muskrat rising, dripping, from the wild rice at the water's edge.
    static func lakeSubject(_ n: inout GraphicsContext, Hv: CGFloat) {
        let fy: CGFloat = Hv + 100
        wildRice(&n, x: 474, baseY: Hv + 82, count: 8, height: 74, seed: 41)
        Kit.shadow(&n, 500, Hv + 86, width: 60)
        Art.group(&n, x: 500, y: Hv + 86, scale: 1.05, scaleX: -1) { m in
            muskrat(&m, look: CGPoint(x: 0.7, y: -0.5), mirrored: true)
        }
        wildRice(&n, x: 486, baseY: Hv + 98, count: 6, height: 40, seed: 43)
        Kit.ripples(&n, 462, Hv + 96, 60, count: 2)
        Kit.campfire(&n, cx: 548, baseY: fy + 2, scale: 0.55)
        Kit.rock(&n, cx: 664, baseY: fy + 3, width: 64, height: 36, color: stoneGrey, seed: 7)
        let seat: Path = Art.svg("M-30,-34 C-20,-40 18,-40 30,-33 C32,-26 30,-20 28,-16 C10,-22 -12,-22 -30,-17Z")
        Art.group(&n, x: 664, y: fy + 3) { s in
            Kit.solid(&s, seat, Art.color(blanketTan), light: 0.24, shade: 0.24)
            Art.stroke(&s, Art.svg("M24,-34 C27,-28 27,-22 25,-17"), Art.color(0xD94F3D), width: 3, cap: .butt)
        }
        Kit.shadow(&n, 640, fy + 2, width: 100)
        let rig = iktomiRig(.sit)
        Art.group(&n, x: 650, y: fy) { p in
            iktomi(&p, rig: rig, look: CGPoint(x: -0.8, y: 0.9), mouth: .smile)
        }
        Kit.shadow(&n, 598, fy + 5, width: 54)
        Art.group(&n, x: 598, y: fy + 4) { p in
            pot(&p)
            steam(&p, x: 0, y: -40, height: 46)
        }
        let grip = Kit.hand(iktomiLook(), pose: .sit)
        Art.group(&n, x: 650 + grip.x, y: fy + grip.y, rotate: Kit.deg(-110)) { s in
            spoon(&s)
        }
        Kit.bodyHand(&n, CGPoint(x: 650 + grip.x, y: fy + grip.y), 5.5, Art.color(iktomiLook().skin), open: false)
        Kit.grassTuft(&n, x: 566, baseY: fy + 34, height: 26, color: 0x7E9A50, seed: 3)
    }
}

// MARK: - scene-race: the long way round, with a stone

extension IktomiArt {
    static func raceScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 150)
        let light = day()
        backdrop(&context, st, light: light, water: dayWater(), seed: 9)
        cumulus(&context, 620, st.H * 0.46, scale: st.far * 1.3)
        cumulus(&context, 800, st.H * 0.2 + 40, scale: st.far * 0.8)
        cumulus(&context, 330, st.H * 0.3 + 10, scale: st.far * 0.5)
        Kit.cloud(&context, 130, st.H * 0.62, scale: st.far * 0.7, color: Color.white.opacity(0.7))
        smoke(&context, x: 236, baseY: st.H - 3 * st.far, height: 58 * st.far)
        Kit.birds(&context, 420, st.H - 46 * st.far, scale: st.far, color: ramp.shadeColor.opacity(0.5))
        cloudReflections(&context, st)
        Kit.designSpace(&context, st) { v in
            shoreArc(&v, Hv: st.Hv)
            Kit.rock(&v, cx: 404, baseY: st.Hv + 74, width: 36, height: 16, color: stoneGrey, seed: 3)
            Kit.ripples(&v, 404, st.Hv + 76, 50, count: 2)
            Kit.rock(&v, cx: 352, baseY: st.Hv + 104, width: 28, height: 12, color: stoneGrey, seed: 8)
            Kit.ripples(&v, 352, st.Hv + 106, 40, count: 2)
            wildRice(&v, x: 70, baseY: st.Hv + 54, count: 8, height: 46, seed: 5)
            if st.tall > 0.25 {
                Kit.rock(&v, cx: 210, baseY: st.Hv + 230, width: 60, height: 26, color: stoneGrey, seed: 12)
                Kit.ripples(&v, 210, st.Hv + 234, 84, count: 2)
                Kit.reeds(&v, x: 96, baseY: st.Hv + 300, count: 8, height: 130, seed: 24, color: reedGreen)
            }
            Kit.nearSpace(&v, st) { n in
                bank(&n, Hv: st.Hv)
                bankFill(&n, Hv: st.Hv)
                raceSubject(&n, Hv: st.Hv)
            }
        }
        Kit.cornerLeaves(&context, size: size, corner: 2, color: Art.color(0x3F6A46), scale: 0.8 * st.far, seed: 9)
        ArtStyle.finish(&context, size)
    }

    /// The far shore of the lake curving away to the left in a long arc of mud, reeds and grass.
    static func shoreArc(_ v: inout GraphicsContext, Hv: CGFloat) {
        var arc = Path()
        arc.move(to: CGPoint(x: 900, y: Hv + 20))
        arc.addCurve(to: CGPoint(x: 150, y: Hv + 3), control1: CGPoint(x: 700, y: Hv + 13), control2: CGPoint(x: 420, y: Hv + 9))
        arc.addCurve(to: CGPoint(x: 640, y: Hv + 60), control1: CGPoint(x: 380, y: Hv + 15), control2: CGPoint(x: 560, y: Hv + 34))
        arc.addLine(to: CGPoint(x: 900, y: Hv + 92))
        arc.closeSubpath()
        let shape: Path = arc
        Art.fill(&v, shape.applying(CGAffineTransform(translationX: -6, y: 4)), Art.color(0x9A8660))
        let grass: Kit.Stops = [(Art.color(0xC6CC86), 0), (Art.color(0xAEBB68), 1)]
        Art.fillLinear(&v, shape, grass, from: CGPoint(x: 0, y: Hv), to: CGPoint(x: 0, y: Hv + 90))
        Kit.reeds(&v, x: 300, baseY: Hv + 10, count: 5, height: 14, seed: 2, color: 0x8FA86A)
        Kit.reeds(&v, x: 452, baseY: Hv + 17, count: 6, height: 22, seed: 4, color: 0x86A062)
        Kit.reeds(&v, x: 560, baseY: Hv + 34, count: 6, height: 34, seed: 6, color: 0x7C9A5A)
        Art.clipped(&v, to: shape) { c in
            Kit.grass(&c, in: CGRect(x: 520, y: Hv + 24, width: 380, height: 50), count: 40, seed: 5, color: Art.color(0x8FA35A), height: 6)
        }
    }

    /// Iktomi running bent double under the stone in his blanket, through mud and reeds, with
    /// the mosquitoes about his head.
    static func raceSubject(_ n: inout GraphicsContext, Hv: CGFloat) {
        let fy: CGFloat = Hv + 104
        let x: CGFloat = 662
        Kit.reeds(&n, x: 792, baseY: Hv + 92, count: 7, height: 92, seed: 33, color: reedGreen)
        wildRice(&n, x: 520, baseY: Hv + 96, count: 7, height: 66, seed: 35)
        var mud = Path()
        mud.addEllipse(in: CGRect(x: x - 66, y: fy - 7, width: 132, height: 20))
        mud.addEllipse(in: CGRect(x: x + 40, y: fy - 2, width: 70, height: 14))
        mud.addEllipse(in: CGRect(x: x - 120, y: fy + 4, width: 60, height: 12))
        Art.fill(&n, mud, Art.color(0x9A8660, 0.85))
        Kit.shadow(&n, x, fy + 2, width: 120)
        let rig = iktomiRunRig()
        Art.group(&n, x: x, y: fy) { p in
            iktomi(&p, rig: rig, look: CGPoint(x: -0.6, y: 0.3), mouth: .open, load: true)
        }
        var splash = Path()
        splash.addEllipse(in: CGRect(x: x + rig.farFoot.x - 12, y: fy - 5, width: 20, height: 8))
        splash.addEllipse(in: CGRect(x: x + rig.nearFoot.x - 10, y: fy - 5, width: 20, height: 8))
        splash.addEllipse(in: CGRect(x: x + rig.nearFoot.x + 12, y: fy - 14, width: 5, height: 4))
        splash.addEllipse(in: CGRect(x: x + rig.nearFoot.x + 20, y: fy - 8, width: 4, height: 3))
        splash.addEllipse(in: CGRect(x: x + rig.farFoot.x - 20, y: fy - 10, width: 4, height: 3))
        Art.fill(&n, splash, Art.color(0x8C7A5A))
        let head = iktomiHeadCentre(rig)
        let swarm = CGRect(x: x + head.x - 50, y: fy + head.y - 62, width: 100, height: 46)
        Kit.flecks(&n, in: swarm, count: 9, seed: 5, color: ramp.deepColor.opacity(0.7), radius: 0.7...1.2)
        Art.stroke(&n, Art.svg("M-70,-150 q-8,3 -12,9 M-74,-128 q-9,1 -15,6").applying(CGAffineTransform(translationX: x, y: fy)), Color.white.opacity(0.8), width: 1.6)
        Kit.reeds(&n, x: 868, baseY: Hv + 170, count: 8, height: 150, seed: 37, color: 0x4E7A44)
        Kit.grassTuft(&n, x: 560, baseY: fy + 40, height: 30, color: 0x7E9A50, seed: 5)
    }
}

// MARK: - scene-swim: straight across the middle

extension IktomiArt {
    static func swimScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 190)
        let light = day()
        backdrop(&context, st, light: light, water: dayWater(), seed: 14)
        cumulus(&context, 610, st.H * 0.42, scale: st.far * 1.1)
        cumulus(&context, 210, st.H * 0.3 + 16, scale: st.far * 0.5)
        Kit.cloud(&context, 800, st.H * 0.24 + 60, scale: st.far * 0.8, color: Color.white.opacity(0.8))
        farWillow(&context, x: 372, baseY: st.H - 2 * st.far, height: 17 * st.far, color: light.near.opacity(0.85))
        smoke(&context, x: 398, baseY: st.H - 3 * st.far, height: 54 * st.far)
        farDuck(&context, x: 140, y: st.H + 20 * st.far, scale: st.far)
        farDuck(&context, x: 178, y: st.H + 26 * st.far, scale: st.far * 1.1)
        cloudReflections(&context, st)
        Kit.designSpace(&context, st) { v in
            wildRice(&v, x: 60, baseY: st.Hv + 62, count: 8, height: 44, seed: 7)
            Kit.ripples(&v, 60, st.Hv + 64, 70, count: 2)
            Art.group(&v, x: 330, y: st.Hv + 40) { d in
                dragonfly(&d)
            }
            if st.tall > 0.25 {
                Kit.reeds(&v, x: 110, baseY: st.Hv + 300, count: 9, height: 140, seed: 26, color: reedGreen)
                Kit.ripples(&v, 110, st.Hv + 304, 130, count: 2)
                wildRice(&v, x: 330, baseY: st.Hv + 330, count: 9, height: 100, seed: 27)
            }
            Kit.nearSpace(&v, st) { n in
                swimSubject(&n, Hv: st.Hv, tall: st.tall > 0.25)
            }
        }
        Kit.cornerLeaves(&context, size: size, corner: 2, color: Art.color(0x3F6A46), scale: 0.75 * st.far, seed: 13)
        ArtStyle.finish(&context, size)
    }

    /// The round lodge among its cattails at the trailing edge, and the muskrat swimming
    /// straight across, a long V of ripples opening behind him.
    static func swimSubject(_ n: inout GraphicsContext, Hv: CGFloat, tall: Bool) {
        Kit.reeds(&n, x: 838, baseY: Hv + 44, count: 9, height: 96, seed: 51, color: reedGreen)
        Kit.reeds(&n, x: 742, baseY: Hv + 48, count: 5, height: 70, seed: 52, color: 0x7FA860)
        lodge(&n, cx: 804, waterY: Hv + 54, width: 150)
        Kit.reeds(&n, x: 884, baseY: Hv + 70, count: 6, height: 84, seed: 53, color: 0x5C8A4A)
        wildRice(&n, x: 716, baseY: Hv + 64, count: 5, height: 46, seed: 54)
        let mx: CGFloat = 560
        let my: CGFloat = Hv + 94
        wake(&n, x: mx - 40, y: my + 1, length: 300, spread: 64)
        Art.fill(&n, Art.ellipse(mx + 34, my + 6, 86, 7), ramp.deepColor.opacity(0.16))
        Art.group(&n, x: mx, y: my, scale: 1.5) { m in
            muskratSwim(&m)
        }
        Kit.ripples(&n, mx - 30, my + 6, 70, count: 2, color: Color.white, opacity: 0.6)
        Kit.reeds(&n, x: 872, baseY: Hv + 192, count: 6, height: 130, seed: 55, color: 0x4E7A44)
        if tall {
            Kit.reeds(&n, x: 540, baseY: Hv + 236, count: 6, height: 84, seed: 56, color: reedGreen)
            Kit.ripples(&n, 540, Hv + 240, 90, count: 2)
            wildRice(&n, x: 708, baseY: Hv + 250, count: 8, height: 96, seed: 57)
        }
    }
}

// MARK: - scene-tree: the picture in the water

extension IktomiArt {
    static func treeScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 150)
        let light = evening()
        backdrop(&context, st, light: light, water: eveningWater(), seed: 19)
        let gold: Color = Art.color(0xFFF3CF, 0.85)
        Kit.cloud(&context, 250, st.H * 0.34 + 10, scale: st.far * 0.9, color: gold)
        Kit.cloud(&context, 520, st.H * 0.5, scale: st.far * 1.3, color: gold)
        Kit.cloud(&context, 110, st.H * 0.6, scale: st.far * 0.6, color: gold.opacity(0.7))
        Kit.farTrees(&context, x0: 60, x1: 200, baseY: st.H - 2 * st.far, height: 10 * st.far, count: 3, color: light.mid, seed: 3)
        cloudReflections(&context, st)
        Kit.designSpace(&context, st) { v in
            Kit.reeds(&v, x: 110, baseY: st.Hv + 40, count: 6, height: 50, seed: 4, color: reedGreen)
            wildRice(&v, x: 280, baseY: st.Hv + 58, count: 7, height: 52, seed: 6)
            if st.tall > 0.25 {
                Kit.reeds(&v, x: 90, baseY: st.Hv + 290, count: 8, height: 130, seed: 28, color: reedGreen)
                Kit.ripples(&v, 90, st.Hv + 294, 120, count: 2)
            }
            Kit.nearSpace(&v, st) { n in
                treeReflection(&n, Hv: st.Hv)
                bank(&n, Hv: st.Hv, shift: 20, evening: true)
                willow(&n, x: 856, baseY: st.Hv + 36, height: 330, seed: 11)
                bankFill(&n, Hv: st.Hv)
                treeSubject(&n, Hv: st.Hv)
                Kit.reeds(&n, x: 874, baseY: st.Hv + 170, count: 7, height: 120, seed: 39, color: 0x4E7A44)
            }
        }
        Kit.cornerLeaves(&context, size: size, corner: 2, color: Art.color(0x46683F), scale: 0.8 * st.far, seed: 15)
        ArtStyle.finish(&context, size)
    }

    /// The muskrat and the pot, upside down in the still water: only his picture.
    static func treeReflection(_ n: inout GraphicsContext, Hv: CGFloat) {
        Art.layer(&n, opacity: 0.4) { l in
            Art.group(&l, x: 410, y: Hv + 92, rotate: CGFloat.pi, scale: 0.9, scaleX: -1) { r in
                muskratWithPot(&r, laugh: false, bone: false)
            }
        }
        Kit.ripples(&n, 410, Hv + 100, 96, count: 3, color: Color.white, opacity: 0.6)
        Art.stroke(&n, Art.svg("M374,0 q18,-4 36,0 M392,22 q20,-4 40,0 M380,44 q16,-3 32,0").applying(CGAffineTransform(translationX: 0, y: Hv + 112)), Color.white.opacity(0.45), width: 1.4)
    }

    /// The muskrat sitting up with the pot held between his paws. Origin under him.
    static func muskratWithPot(_ g: inout GraphicsContext, laugh: Bool, bone: Bool) {
        muskrat(&g, laugh: laugh, look: CGPoint(x: -0.5, y: 0.8), paws: false)
        Art.group(&g, x: -20, y: -6, scale: 0.62) { p in
            pot(&p, fish: true, handle: false)
        }
        let arms: Path = Art.svg("M-20,-40 Q-34,-34 -34,-22 M6,-40 Q0,-30 -8,-24")
        Art.stroke(&g, arms, Kit.personTone(muskratFur, 0.82), width: 5.5)
        var hands = Path()
        hands.addPath(Art.circle(-34, -21, 3.2))
        hands.addPath(Art.circle(-8, -23, 3.2))
        Art.fill(&g, hands, Art.color(0x8E6652))
        if bone {
            Art.group(&g, x: -44, y: -20, rotate: Kit.deg(70)) { b in
                fishBone(&b)
            }
        }
    }

    /// The muskrat laughing on the willow's limb with the pot; Iktomi on his knees at the
    /// water's edge, staring down; the dropped stone, the blanket and the cold ashes.
    static func treeSubject(_ n: inout GraphicsContext, Hv: CGFloat) {
        let fy: CGFloat = Hv + 96
        let perch = willowPerch(x: 856, baseY: Hv + 36, height: 330)
        Art.group(&n, x: perch.x, y: perch.y + 2) { m in
            muskratWithPot(&m, laugh: true, bone: false)
        }
        Art.group(&n, x: 742, y: Hv + 86) { s in
            droppedStone(&s)
        }
        Art.group(&n, x: 652, y: Hv + 106) { a in
            ashes(&a)
        }
        Art.group(&n, x: 694, y: Hv + 112, rotate: Kit.deg(96)) { s in
            spoon(&s)
        }
        Art.group(&n, x: 812, y: Hv + 62, scale: 0.9) { b in
            meadowlark(&b)
        }
        Kit.shadow(&n, 812, Hv + 63, width: 26, alpha: 0.2)
        Kit.shadow(&n, 556, fy + 2, width: 130, alpha: 0.3)
        let rig = iktomiRig(.kneel, lean: 30)
        Art.group(&n, x: 548, y: fy) { p in
            iktomi(&p, rig: rig, look: CGPoint(x: -0.6, y: 0.9), mouth: .oh)
        }
        Kit.grassTuft(&n, x: 600, baseY: fy + 36, height: 28, color: 0x7E9A50, seed: 7)
        Kit.grassTuft(&n, x: 488, baseY: Hv + 92, height: 22, color: 0x86A256, seed: 8)
    }
}
