import SwiftUI
import OmramoCore

// The cast and the shared parts of "The Old Man Who Moved the Mountains": the palette, the two
// lights, the four named characters and the family, the two great mountains, the farmhouse,
// the willow and the carrying pole. Every picture of the story composes from these.

// MARK: - Palette and light

extension MountainsArt {
    /// Hazy blue-grey mountains, yellow earth, soft green millet, one touch of red-orange.
    static let ramp = ArtStyle.Ramp(deep: 0x2F4A5C, shade: 0x5E7F8C, mid: 0x9DB58A, light: 0xE9F1E4, glow: 0xFFD98A, accent: 0xD9573C)

    static let loessLight: UInt32 = 0xEBD494
    static let loessMid: UInt32 = 0xDDBB70
    static let loessDeep: UInt32 = 0xC29A52
    static let earthWall: UInt32 = 0xD9B36C
    static let thatch: UInt32 = 0xC9A24E
    static let doorWood: UInt32 = 0x7A5232
    static let wicker: UInt32 = 0xC89A54
    static let milletGreen: UInt32 = 0xA9BF7E
    static let milletGold: UInt32 = 0xE3B645
    static let peakFront: UInt32 = 0xA3B8BF
    static let peakBack: UInt32 = 0xB6C8CD
    static let dugEarth: UInt32 = 0x9A6E44

    /// The clear, dry morning of every picture but the last scene.
    static func day() -> Kit.Light {
        let sky: Kit.Stops = [
            (Art.color(0xBFDDEE), 0), (Art.color(0xDCEDF2), 0.5), (Art.color(0xF6F1D6), 0.84), (Art.color(0xFFE2A6), 1),
        ]
        return Kit.Light(sky: sky, sun: 0xFFF4C8, glow: 0xFFD98A, haze: 0xEEF0DC, far: 0xBFD0D2, mid: 0xB4C49A, near: 0x8FA77A)
    }

    /// The golden morning after the mountains have gone.
    static func goldenMorning() -> Kit.Light {
        let sky: Kit.Stops = [
            (Art.color(0xC6E2F2), 0), (Art.color(0xE4F1F0), 0.5), (Art.color(0xFFF0C4), 0.85), (Art.color(0xFFDD94), 1),
        ]
        return Kit.Light(sky: sky, sun: 0xFFF6D2, glow: 0xFFD98A, haze: 0xFBF0CC, far: 0xDDD3A4, mid: 0xD9BE6A, near: 0xC9A44E)
    }

    /// The yellow loess earth of the plain and the yard.
    static func loess() -> Kit.Stops {
        [(Art.color(loessLight), 0), (Art.color(loessMid), 0.5), (Art.color(loessDeep), 1)]
    }

    /// The slow, silty river.
    static func silt() -> Kit.Stops {
        [(Art.color(0xDCCB98), 0), (Art.color(0xC8AE70), 0.55), (Art.color(0xAE9052), 1)]
    }

    /// The plain of ripe millet.
    static func goldPlain() -> Kit.Stops {
        [(Art.color(0xF2D77E), 0), (Art.color(0xE6BE55), 0.5), (Art.color(0xCFA040), 1)]
    }

    /// A trodden path of pale earth.
    static func pathStops() -> Kit.Stops {
        [(Art.color(0xF3E3B4), 0), (Art.color(0xEBD59C), 1)]
    }
}

// MARK: - Looks

extension MountainsArt {
    static func yuGongLook() -> Kit.Person {
        Kit.Person(
            age: .elder, skin: 0xE8B98A, hair: 0xF6F3EC, hairStyle: .topknot, beard: .long,
            garment: .robe, cloth: 0xE4D0A0, trim: 0x8A5A32, legs: 0x9A8A6A
        )
    }

    static func wifeLook() -> Kit.Person {
        Kit.Person(
            age: .elder, skin: 0xE9B990, hair: 0xBDBAB8, hairStyle: .bun,
            garment: .robe, cloth: 0x7E4C56, trim: 0xF0E4C8, legs: 0x5A3A40
        )
    }

    static func boyLook() -> Kit.Person {
        Kit.Person(
            age: .child, skin: 0xEDBE92, hair: 0x2A1F1A, hairStyle: .short,
            garment: .tunic, cloth: 0x62AC6C, trim: 0x2F6B45, legs: 0xEDBE92
        )
    }

    static func zhiSouLook() -> Kit.Person {
        Kit.Person(
            age: .elder, skin: 0xEBC09A, hair: 0xC4C8CE, hairStyle: .topknot, beard: .long,
            garment: .robe, cloth: 0x9CC4E4, trim: 0x3F6FA8, legs: 0x6A86A8
        )
    }

    /// The grown sons (0, 1) and the daughter-in-law (2).
    static func grownLook(_ index: Int) -> Kit.Person {
        switch index {
        case 0:
            return Kit.Person(skin: 0xDDA878, hair: 0x2A1F1A, hairStyle: .topknot, garment: .tunic, cloth: 0xB89A6A, trim: 0x6B4A32, legs: 0x8A7A5E)
        case 1:
            return Kit.Person(skin: 0xE0AC80, hair: 0x30241E, hairStyle: .topknot, beard: .short, garment: .tunic, cloth: 0x7F96B4, trim: 0x4A5E7A, legs: 0x8A7A5E)
        default:
            return Kit.Person(skin: 0xEBBB92, hair: 0x2A1F1A, hairStyle: .bun, garment: .robe, cloth: 0xC98E6E, trim: 0xF0E4C8, legs: 0x7A5A48)
        }
    }

    /// The grandchildren.
    static func grandchildLook(_ index: Int) -> Kit.Person {
        switch index {
        case 0:
            return Kit.Person(age: .child, skin: 0xEBBB90, hair: 0x2A1F1A, hairStyle: .topknot, garment: .tunic, cloth: 0xD9A860, trim: 0x8A5A32, legs: 0x8A7A5E)
        case 1:
            return Kit.Person(age: .child, skin: 0xEDBE96, hair: 0x30241E, hairStyle: .bun, garment: .tunic, cloth: 0xC9786A, trim: 0xF0E4C8, legs: 0x7A5A48)
        default:
            return Kit.Person(age: .child, skin: 0xE6B488, hair: 0x2A1F1A, hairStyle: .topknot, garment: .tunic, cloth: 0x8FA4C0, trim: 0x4A5E7A, legs: 0x8A7A5E)
        }
    }
}

// MARK: - The figure painter and the head details

extension MountainsArt {
    /// Any person in any rig (the kit's own body and head), then `extras` drawn in the head's
    /// own units (skull x −26…26, y −28…28) — a hair tie, a pin, a missing tooth. Origin at
    /// the feet, facing LEFT. `nod` (radians) tips the face up when positive.
    static func figure(
        _ context: inout GraphicsContext,
        _ p: Kit.Person,
        rig r: Kit.BodyRig,
        look: CGPoint,
        mouth: Kit.Mouth,
        closedEyes: Bool,
        mirrored: Bool,
        nod: CGFloat = 0,
        _ extras: (inout GraphicsContext) -> Void
    ) {
        let f = Kit.bodyFrame(p)
        Art.group(&context, scale: f.k) { g in
            Kit.bodyFigure(&g, p, r, mirrored: mirrored)
        }
        let c = Kit.bodyHeadCentre(f, r)
        let lean: CGFloat = -Kit.deg(r.lean) * 0.45
        let tilt: CGFloat = lean + nod
        let isChild: Bool = p.age == .child
        let sy: CGFloat = isChild ? 50.0 / 56.0 : 1
        let sx: CGFloat = isChild ? (48.0 / 52.0) / (50.0 / 56.0) : 1
        Art.group(&context, x: c.x, y: c.y, rotate: tilt, scale: f.headScale) { g in
            Kit.personHead(&g, p, look: look, mouth: mouth, closedEyes: closedEyes, mirrored: mirrored)
            Art.group(&g, scale: sy, scaleX: sx) { e in
                extras(&e)
            }
        }
    }

    /// Yu Gong's signature: the faded red-orange cloth that ties his topknot (head units).
    static func yuGongTie(_ context: inout GraphicsContext) {
        let cloth = ramp.accentColor
        Art.stroke(&context, Art.svg("M3.6,-33.4 q7,0.4 9.6,6.4 M3.6,-33.4 q8,-2.4 12,1.6"), cloth, width: 2.4)
        Art.fill(&context, Art.rect(-4.8, -35.6, 9.6, 4.6, radius: 2), cloth)
        Art.stroke(&context, Art.line(-3.4, -34.6, 2.2, -34.6), Art.color(0xF2906E), width: 1)
    }

    /// The wooden pin through the wife's bun (head units).
    static func wifePin(_ context: inout GraphicsContext) {
        Art.stroke(&context, Art.line(-2, -42, 20, -30.5), Art.color(0x8A5A32), width: 2)
        Art.fill(&context, Art.circle(-2.4, -42.2, 2), Art.color(0xB07A46))
    }

    /// The little boy's two tufts of hair, tied on top of his head (head units).
    static func boyTufts(_ context: inout GraphicsContext) {
        let p = boyLook()
        var tufts = Path()
        tufts.addPath(Art.ellipse(-15, -31.5, 6.6, 5.8))
        tufts.addPath(Art.ellipse(15, -31.5, 6.2, 5.6))
        Art.fill(&context, tufts, Art.color(p.hair))
        var shine = Path()
        shine.addPath(Art.ellipse(-16.6, -33.4, 2.8, 2))
        shine.addPath(Art.ellipse(13.4, -33.4, 2.6, 1.9))
        Art.fill(&context, shine, Kit.personTone(p.hair, 1.5))
        Art.stroke(&context, Art.svg("M-18,-27.4 L-11,-26.4 M11,-26.4 L18,-27.4"), ramp.accentColor, width: 2)
    }

    /// The gap where a milk tooth has gone, over the kit's grin (head units).
    static func boyGap(_ context: inout GraphicsContext) {
        Art.fill(&context, Art.rect(-2.7, 12.8, 3.4, 4.2, radius: 1), Art.color(0x7A2E24))
    }
}

// MARK: - The named characters

extension MountainsArt {
    /// Yu Gong: origin at the feet, 160 tall, facing LEFT.
    static func yuGong(
        _ context: inout GraphicsContext,
        pose: Kit.Pose = .stand,
        look: CGPoint = .zero,
        mouth: Kit.Mouth = .smile,
        mirrored: Bool = false,
        nod: CGFloat = 0
    ) {
        let p = yuGongLook()
        let rig = Kit.bodyRig(p, pose)
        figure(&context, p, rig: rig, look: look, mouth: mouth, closedEyes: false, mirrored: mirrored, nod: nod) { e in
            yuGongTie(&e)
        }
    }

    /// Yu Gong with the carrying pole across his shoulders and a full basket at each end.
    static func yuGongCarrying(
        _ context: inout GraphicsContext,
        walking: Bool,
        look: CGPoint = .zero,
        mouth: Kit.Mouth = .smile,
        mirrored: Bool = false
    ) {
        loadedPole(&context, cx: -4, cy: -101, length: 150, drop: 80)
        yuGong(&context, pose: walking ? .walk : .stand, look: look, mouth: mouth, mirrored: mirrored)
    }

    /// Yu Gong standing calm, one hand rubbing his sore shoulder.
    static func yuGongResting(_ context: inout GraphicsContext, look: CGPoint = .zero, mirrored: Bool = false) {
        let p = yuGongLook()
        var rig = Kit.bodyStandRig(p)
        rig.nearElbow = Kit.pt(8, 24)
        rig.nearHand = Kit.pt(38, 4)
        figure(&context, p, rig: rig, look: look, mouth: .smile, closedEyes: false, mirrored: mirrored) { e in
            yuGongTie(&e)
        }
    }

    /// Yu Gong standing with his hoe upright in his leading hand.
    static func yuGongWithHoe(
        _ context: inout GraphicsContext,
        look: CGPoint = .zero,
        mouth: Kit.Mouth = .smile,
        mirrored: Bool = false
    ) {
        let p = yuGongLook()
        var rig = Kit.bodyStandRig(p)
        rig.nearElbow = Kit.pt(-10, 18)
        rig.nearHand = Kit.pt(-22, 24)
        let f = Kit.bodyFrame(p)
        let s = Kit.bodyShoulder(rig, near: true)
        let hx: CGFloat = (s.x + rig.nearHand.x) * f.k
        Kit.tool(&context, .hoe, x: hx, baseY: 2, height: 150, wood: 0x8A5A3A, metal: 0x8E979E)
        figure(&context, p, rig: rig, look: look, mouth: mouth, closedEyes: false, mirrored: mirrored) { e in
            yuGongTie(&e)
        }
    }

    /// Yu Gong's wife, sturdy and upright, with her cream apron.
    static func wife(
        _ context: inout GraphicsContext,
        pose: Kit.Pose = .stand,
        look: CGPoint = .zero,
        mouth: Kit.Mouth = .smile,
        mirrored: Bool = false
    ) {
        let p = wifeLook()
        let rig = Kit.bodyRig(p, pose)
        figure(&context, p, rig: rig, look: look, mouth: mouth, closedEyes: false, mirrored: mirrored) { e in
            wifePin(&e)
        }
        if pose == .stand {
            let apron = Art.rect(-15, -63, 27, 44, radius: 6)
            Kit.solid(&context, apron, Art.color(0xF3E8CC), light: 0.18, shade: 0.14)
            Art.stroke(&context, Art.svg("M-4,-56 q-2,16 0,32"), Art.color(0xD9C9A4), width: 1.4)
        }
    }

    /// The little boy from next door: 126 tall, facing LEFT. With `basket` he holds a
    /// child-sized basket of earth in front of him (use pose `.carry`).
    static func boy(
        _ context: inout GraphicsContext,
        pose: Kit.Pose = .stand,
        look: CGPoint = .zero,
        mouth: Kit.Mouth = .grin,
        mirrored: Bool = false,
        basket: Bool = false
    ) {
        let p = boyLook()
        let rig = Kit.bodyRig(p, pose)
        let gap: Bool = mouth == .grin
        figure(&context, p, rig: rig, look: look, mouth: mouth, closedEyes: false, mirrored: mirrored) { e in
            boyTufts(&e)
            if gap {
                boyGap(&e)
            }
        }
        if basket {
            let hand = Kit.hand(p, pose: pose)
            let bx: CGFloat = hand.x - 8
            let by: CGFloat = hand.y + 17
            Kit.propBasketBody(&context, cx: bx, baseY: by, width: 28, height: 21, color: wicker, lid: false, handles: true)
            earthLoad(&context, x: bx, rimY: by - 21, width: 28)
        }
    }

    /// Zhi Sou on his low stool: origin on the ground under the stool, facing LEFT. Laughing,
    /// his eyes shut and one hand raised; otherwise open-mouthed, with nothing to say.
    static func zhiSouSeated(_ context: inout GraphicsContext, laughing: Bool, mirrored: Bool = false) {
        let p = zhiSouLook()
        Kit.shadow(&context, 10, 1, width: 60)
        Art.stroke(&context, Art.svg("M-2,-31 L-5,0 M27,-31 L30,0"), Art.color(0x6B4A32), width: 4.5)
        Kit.solid(&context, Art.rect(-8, -36, 42, 7, radius: 3), Art.color(0x9A6B3E), light: 0.3, shade: 0.2)
        var rig = Kit.bodySitRig(p)
        if laughing {
            rig.nearElbow = Kit.pt(-20, 4)
            rig.nearHand = Kit.pt(-30, -24)
            rig.openHand = true
        }
        let mouth: Kit.Mouth = laughing ? .grin : .oh
        figure(&context, p, rig: rig, look: .zero, mouth: mouth, closedEyes: laughing, mirrored: mirrored) { _ in
        }
    }

    /// One of the family in a kit pose (no head details).
    static func kin(
        _ context: inout GraphicsContext,
        _ p: Kit.Person,
        pose: Kit.Pose,
        look: CGPoint = .zero,
        mouth: Kit.Mouth = .smile,
        mirrored: Bool = false
    ) {
        Kit.person(&context, p, pose: pose, look: look, mouth: mouth, mirrored: mirrored)
    }

    /// A son breaking rock: bent forward, the hoe swung up in both hands. Origin at the feet,
    /// facing LEFT.
    static func digger(_ context: inout GraphicsContext, _ p: Kit.Person, mirrored: Bool = false) {
        var rig = Kit.bodyStandRig(p)
        rig.lean = 14
        rig.nearElbow = Kit.pt(-14, -6)
        rig.nearHand = Kit.pt(-26, -28)
        rig.farElbow = Kit.pt(-8, -2)
        rig.farHand = Kit.pt(-16, -18)
        let f = Kit.bodyFrame(p)
        let s = Kit.bodyShoulder(rig, near: true)
        let hx: CGFloat = (s.x + rig.nearHand.x) * f.k
        let hy: CGFloat = (s.y + rig.nearHand.y) * f.k
        Kit.propShaft(&context, hx + 30, hy + 30, hx - 22, hy - 32, wood: 0x8A5A3A, width: 4.5)
        let blade: [CGPoint] = [
            Kit.pt(hx - 20, hy - 37), Kit.pt(hx - 44, hy - 27), Kit.pt(hx - 42, hy - 15), Kit.pt(hx - 24, hy - 27),
        ]
        Kit.solid(&context, Art.polygon(blade), Art.color(0x8E979E), light: 0.3, shade: 0.2)
        figure(&context, p, rig: rig, look: CGPoint(x: -0.6, y: 0.5), mouth: .smile, closedEyes: false, mirrored: mirrored) { _ in
        }
    }
}

// MARK: - The carrying pole

extension MountainsArt {
    /// The springy carrying pole with a FULL basket on a cord at each end: the pole's middle
    /// at (cx, cy), `length` long, the baskets' feet `drop` below its ends.
    static func loadedPole(_ context: inout GraphicsContext, cx: CGFloat, cy: CGFloat, length: CGFloat, drop: CGFloat) {
        Kit.carryingPole(&context, cx: cx, cy: cy, length: length, drop: drop, basket: wicker)
        let endY: CGFloat = cy + length * 0.04
        let bw: CGFloat = length * 0.27
        let bh: CGFloat = min(bw * 0.72, drop * 0.6)
        let rimY: CGFloat = endY + drop - bh
        earthLoad(&context, x: cx - length * 0.5, rimY: rimY, width: bw)
        earthLoad(&context, x: cx + length * 0.5, rimY: rimY, width: bw)
    }

    /// The heap of earth and stones that fills a basket `w` wide whose rim is at `rimY`.
    static func earthLoad(_ context: inout GraphicsContext, x: CGFloat, rimY: CGFloat, width w: CGFloat) {
        var heap = Path()
        heap.move(to: CGPoint(x: x - w * 0.44, y: rimY))
        heap.addQuadCurve(to: CGPoint(x: x + w * 0.44, y: rimY), control: CGPoint(x: x - w * 0.06, y: rimY - w * 0.62))
        heap.closeSubpath()
        Kit.solid(&context, heap, Art.color(dugEarth), light: 0.3, shade: 0.24)
        var stones = Path()
        stones.addPath(Art.ellipse(x - w * 0.14, rimY - w * 0.11, w * 0.1, w * 0.07))
        stones.addPath(Art.ellipse(x + w * 0.16, rimY - w * 0.08, w * 0.08, w * 0.06))
        stones.addPath(Art.ellipse(x + w * 0.01, rimY - w * 0.21, w * 0.07, w * 0.05))
        Art.fill(&context, stones, Art.color(0xC2BDAE))
    }

    /// Two full baskets set down on the ground with the pole laid across them.
    static func basketsSetDown(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, scale: CGFloat) {
        Art.group(&context, x: x, y: baseY, scale: scale) { g in
            Kit.basket(&g, cx: -24, baseY: 0, width: 40, height: 29, color: wicker)
            Kit.basket(&g, cx: 26, baseY: 3, width: 40, height: 29, color: wicker)
            earthLoad(&g, x: -24, rimY: -29, width: 40)
            earthLoad(&g, x: 26, rimY: -26, width: 40)
            Kit.propShaft(&g, -78, -34, 76, -40, wood: 0x9A6B3E, width: 3.4)
        }
    }
}

// MARK: - The mountains

extension MountainsArt {
    /// One of the two great mountains: the kit's hero peak with the Taihang's cliff bands
    /// (a shaded ledge and a lit edge at each level) and, if asked, pines along its foot.
    static func greatPeak(
        _ context: inout GraphicsContext,
        cx: CGFloat,
        baseY: CGFloat,
        width: CGFloat,
        height: CGFloat,
        color: UInt32,
        seed: UInt32,
        pines: Bool
    ) {
        Kit.mountain(&context, cx: cx, baseY: baseY, width: width, height: height, color: Art.color(color), seed: seed)
        let half: CGFloat = width / 2
        var bands = Path()
        var ledges = Path()
        let levels: [CGFloat] = [0.16, 0.3, 0.44, 0.58, 0.72]
        var random = ArtRandom(seed &+ 3)
        for level in levels {
            let reach: CGFloat = half * (1 - level) * 0.74
            let y: CGFloat = baseY - height * level
            let x0: CGFloat = cx - reach * (0.7 + Kit.rnd(&random) * 0.3)
            let x1: CGFloat = cx + reach * (0.6 + Kit.rnd(&random) * 0.4)
            let dip: CGFloat = height * 0.02
            let mx: CGFloat = (x0 + x1) / 2
            bands.move(to: CGPoint(x: x0, y: y))
            bands.addQuadCurve(to: CGPoint(x: x1, y: y + dip), control: CGPoint(x: mx, y: y - dip))
            let ly: CGFloat = y - height * 0.012
            let lx: CGFloat = (x0 + cx) / 2
            ledges.move(to: CGPoint(x: x0, y: ly))
            ledges.addQuadCurve(to: CGPoint(x: cx, y: ly - dip * 0.4), control: CGPoint(x: lx, y: ly - dip))
        }
        Art.stroke(&context, bands, ArtStyle.coolShade.opacity(0.1), width: max(2, height * 0.012))
        Art.stroke(&context, ledges, ArtStyle.warmLight.opacity(0.32), width: max(1, height * 0.005))
        if pines {
            let pineColor = Art.color(0x7F9E93, 0.8)
            Kit.farTrees(
                &context, x0: cx - half * 0.62, x1: cx + half * 0.62, baseY: baseY - height * 0.02,
                height: max(6, height * 0.05), count: 16, color: pineColor, conifer: true, seed: seed
            )
        }
    }

    /// The air round the great mountains: haze lying on their feet and a pale veil over their
    /// tops, so they stay hazy where the chrome and the words are. Full width, no hard edge.
    static func mountainAir(_ context: inout GraphicsContext, width w: CGFloat, baseY: CGFloat, height: CGFloat, light: Kit.Light) {
        let footTop: CGFloat = baseY - height * 0.42
        let foot: Kit.Stops = [(light.haze.opacity(0), 0), (light.haze.opacity(0.5), 0.6), (light.haze.opacity(0.9), 1)]
        Art.fillLinear(
            &context, Art.rect(0, footTop, w, baseY - footTop + 2), foot,
            from: CGPoint(x: 0, y: footTop), to: CGPoint(x: 0, y: baseY)
        )
        let pale = Art.color(0xEAF4F8)
        let crownTop: CGFloat = baseY - height * 1.16
        let crownDepth: CGFloat = height * 0.62
        let crown: Kit.Stops = [(pale.opacity(0), 0), (pale.opacity(0.42), 0.3), (pale.opacity(0), 1)]
        Art.fillLinear(
            &context, Art.rect(0, crownTop, w, crownDepth), crown,
            from: CGPoint(x: 0, y: crownTop), to: CGPoint(x: 0, y: crownTop + crownDepth)
        )
    }

    /// Taihang and Wangwu side by side on `baseY`: Wangwu behind on the right, Taihang in
    /// front on the left, then the air (which lies across the whole `width`).
    static func twoMountains(
        _ context: inout GraphicsContext,
        width w: CGFloat,
        baseY: CGFloat,
        height: CGFloat,
        taihangX: CGFloat,
        wangwuX: CGFloat,
        peakWidth: CGFloat,
        light: Kit.Light
    ) {
        greatPeak(&context, cx: wangwuX, baseY: baseY, width: peakWidth * 0.92, height: height * 0.86, color: peakBack, seed: 9, pines: false)
        greatPeak(&context, cx: taihangX, baseY: baseY, width: peakWidth, height: height, color: peakFront, seed: 3, pines: true)
        mountainAir(&context, width: w, baseY: baseY, height: height, light: light)
    }

    /// The far, very pale ranges low under the words on the leading side.
    static func farRanges(
        _ context: inout GraphicsContext,
        width w: CGFloat,
        horizon H: CGFloat,
        scale s: CGFloat,
        light: Kit.Light,
        x0: CGFloat = 0
    ) {
        let back = Kit.peaks(width: w, y: H - 4 * s, amp: 50 * s, seed: 21, bottom: H + 6, sharp: 0.45, x0: x0)
        Art.fill(&context, back, light.far.opacity(0.5))
        let front = Kit.peaks(width: w, y: H - 2 * s, amp: 28 * s, seed: 8, bottom: H + 6, sharp: 0.3, x0: x0)
        Art.fill(&context, front, light.far.opacity(0.9))
        ArtStyle.atmosphere(&context, width: x0 + w, top: H - 60 * s, bottom: H + 6, color: light.haze, alpha: 0.3)
    }
}

// MARK: - The farmhouse, the yard, the trees

extension MountainsArt {
    /// The farmhouse: walls of rammed yellow earth, a thatch of millet straw, a wooden door.
    /// (x, baseY) is the middle of the foot of its front wall; at scale 1 the wall is 190 wide
    /// (236 with the eaves) and the house 180 tall.
    static func farmhouse(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, scale: CGFloat) {
        Art.group(&context, x: x, y: baseY, scale: scale) { g in
            Kit.house(
                &g, cx: 0, baseY: 0, width: 190, wallHeight: 110, roofHeight: 70,
                wall: earthWall, roof: thatch, style: .thatch, door: doorWood, windows: 1
            )
            // The courses of rammed earth, broken where the door and the window are.
            let courses = Art.svg("M-93,-92 L93,-92 M-93,-66 L-53,-66 M-7,-66 L20,-66 M56,-66 L93,-66 M-93,-40 L-53,-40 M-7,-40 L93,-40")
            Art.stroke(&g, courses, Kit.builtTone(earthWall, 0.8).opacity(0.5), width: 1.4)
            Kit.sheaf(&g, cx: 78, baseY: 2, height: 52, color: 0xD9B550)
        }
    }

    /// The low wall of packed earth round the yard.
    static func yardWall(_ context: inout GraphicsContext, x0: CGFloat, x1: CGFloat, baseY: CGFloat, height: CGFloat) {
        Kit.longWall(&context, x0: x0, x1: x1, baseY: baseY, height: height, color: 0xCFA85E)
    }

    /// The peach tree by the house, its peaches ripe.
    static func peachTree(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, height h: CGFloat, seed: UInt32) {
        let spread: CGFloat = h * 0.84
        Kit.tree(&context, x: x, baseY: baseY, height: h, spread: spread, palette: Kit.springGreens(), bark: 0x6E4A3C, seed: seed)
        let cy: CGFloat = baseY - h * 0.66
        let spots: [(CGFloat, CGFloat)] = [(-0.3, 0.08), (-0.12, -0.14), (0.1, 0.1), (0.28, -0.04), (0.02, -0.02), (-0.22, 0.2), (0.2, 0.2)]
        var fruit = Path()
        var shine = Path()
        let r: CGFloat = max(2, h * 0.032)
        for spot in spots {
            let fx: CGFloat = x + spot.0 * spread
            let fy: CGFloat = cy + spot.1 * h
            fruit.addPath(Art.circle(fx, fy, r))
            shine.addPath(Art.circle(fx - r * 0.3, fy - r * 0.34, r * 0.34))
        }
        Art.fill(&context, fruit, Art.color(0xFF9C78))
        Art.fill(&context, shine, Art.color(0xFFE0C8, 0.8))
    }

    /// A willow at the river: a leaning grey trunk, a small crown and long hanging strands
    /// that reach about 0.52 × `height` above the ground at their longest.
    static func willow(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, height h: CGFloat, seed: UInt32) {
        let greens: Kit.Greens = Kit.greens(0x4E7A4A, 0x6B9A52, 0x8DB85E, 0xB4D472, 0xDDEB9A)
        let bark: UInt32 = 0x7A6450
        let topY: CGFloat = baseY - h * 0.62
        let topX: CGFloat = x - h * 0.04
        let crownY: CGFloat = baseY - h * 0.86
        Kit.shadow(&context, x, baseY, width: h * 0.5, alpha: 0.22)
        var boughs = Path()
        Kit.treeBough(&boughs, topX, topY + h * 0.06, topX - h * 0.3, crownY, h * 0.05, h * 0.012, bend: -h * 0.03)
        Kit.treeBough(&boughs, topX, topY + h * 0.04, topX + h * 0.26, crownY - h * 0.04, h * 0.05, h * 0.012, bend: h * 0.03)
        Kit.treeBough(&boughs, topX, topY + h * 0.02, topX - h * 0.04, crownY - h * 0.12, h * 0.045, h * 0.012)
        Art.fill(&context, boughs, Kit.treeTone(bark, 0.82))
        let trunk = Kit.treeTrunk(x, baseY, topX, topY, h * 0.07, h * 0.035)
        Kit.treeBark(&context, trunk.shape, trunk.edge, bark)
        let blob0: Kit.Blob = (topX - h * 0.28, crownY + h * 0.02, h * 0.14)
        let blob1: Kit.Blob = (topX, crownY - h * 0.05, h * 0.17)
        let blob2: Kit.Blob = (topX + h * 0.26, crownY, h * 0.14)
        let blob3: Kit.Blob = (topX - h * 0.12, crownY + h * 0.06, h * 0.12)
        let blob4: Kit.Blob = (topX + h * 0.12, crownY + h * 0.07, h * 0.12)
        let blobs: [Kit.Blob] = [blob0, blob1, blob2, blob3, blob4]
        Kit.canopy(&context, blobs, seed: seed, palette: greens, density: 1.6)
        var random = ArtRandom(seed &+ 7)
        var dark = Path()
        var mid = Path()
        var lit = Path()
        for i in 0..<36 {
            let t: CGFloat = (CGFloat(i) + Kit.rnd(&random)) / 36
            let arch: CGFloat = 1 - abs(t - 0.5) * 2
            let sx: CGFloat = topX + (t - 0.5) * h * 0.86
            let drop: CGFloat = Kit.rnd(&random) * h * 0.08
            let sy: CGFloat = crownY - h * 0.06 * arch + drop
            let length: CGFloat = h * (0.2 + Kit.rnd(&random) * 0.2)
            let drift: CGFloat = (t - 0.5) * h * 0.1
            let jitter: CGFloat = (Kit.rnd(&random) - 0.5) * h * 0.03
            let sway: CGFloat = drift + jitter
            let end = CGPoint(x: sx + sway, y: sy + length)
            let control = CGPoint(x: sx + sway * 0.2, y: sy + length * 0.5)
            switch i % 3 {
            case 0:
                dark.move(to: CGPoint(x: sx, y: sy))
                dark.addQuadCurve(to: end, control: control)
            case 1:
                mid.move(to: CGPoint(x: sx, y: sy))
                mid.addQuadCurve(to: end, control: control)
            default:
                lit.move(to: CGPoint(x: sx, y: sy))
                lit.addQuadCurve(to: end, control: control)
            }
        }
        let leaf: CGFloat = max(2, h * 0.012)
        let dash: [CGFloat] = [leaf * 1.9, leaf * 1.2]
        Art.stroke(&context, dark, greens[1].opacity(0.8), width: max(0.7, leaf * 0.25))
        Art.stroke(&context, dark, greens[1], width: leaf, dash: dash)
        Art.stroke(&context, mid, greens[2].opacity(0.8), width: max(0.7, leaf * 0.25))
        Art.stroke(&context, mid, greens[2], width: leaf, dash: dash)
        Art.stroke(&context, lit, greens[3].opacity(0.8), width: max(0.7, leaf * 0.25))
        Art.stroke(&context, lit, greens[4], width: leaf, dash: dash)
    }
}

// MARK: - The foot of a scene

extension MountainsArt {
    /// The near ground of an unfolded scene: dry grass and small stones over the lower part of
    /// the earth and, on a tall window, flowers, big tufts and a stone so the foot of the
    /// picture is not empty. `grass` is the colour of the dry blades.
    static func foreground(_ context: inout GraphicsContext, _ st: Kit.Stage, grass: UInt32, flowers petal: UInt32) {
        let top: CGFloat = st.H + st.depth * 0.42
        let rect = CGRect(x: 0, y: top, width: st.w, height: max(1, st.h - top - 6))
        let extra: Int = Int(40 * st.tall)
        Kit.grass(&context, in: rect, count: 22 + extra, seed: 11, color: Kit.groundTone(grass, 0.82), height: 9 * st.grow)
        Kit.grass(&context, in: rect, count: 16 + extra, seed: 29, color: Kit.groundTone(grass, 1.12), height: 7 * st.grow)
        Kit.pebbles(&context, in: rect, count: 10 + extra / 3, seed: 5, color: 0xB8A680)
        Kit.grassTuft(&context, x: 34, baseY: st.h + 6, height: 54 * st.grow, color: 0x7E9A5A, seed: 3)
        Kit.grassTuft(&context, x: 86, baseY: st.h + 10, height: 40 * st.grow, color: 0x93AC64, seed: 8)
        guard st.tall > 0.25 else { return }
        let low: CGFloat = st.H + st.depth * 0.6
        let bed = CGRect(x: 20, y: low, width: 400, height: max(1, st.h - low - 30))
        Kit.flowers(&context, in: bed, count: 14, seed: 9, petal: petal)
        Kit.rock(&context, cx: 250, baseY: st.h - 46, width: 96, height: 46, color: 0xB9AC8E, seed: 4)
        Kit.grassTuft(&context, x: 316, baseY: st.h - 40, height: 58, color: 0x7E9A5A, seed: 12)
        Kit.grassTuft(&context, x: 180, baseY: st.h - 12, height: 66, color: 0x93AC64, seed: 17)
    }
}
